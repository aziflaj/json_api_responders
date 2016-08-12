require 'json_api_responders/responder/actions'
require 'json_api_responders/responder/sanitizers'

module JsonApiResponders
  class Responder
    include Actions

    attr_accessor :errors
    attr_reader :status
    attr_reader :resource
    attr_reader :options
    attr_reader :params
    attr_reader :controller

    def initialize(controller, resource = nil, options = {})
      @controller = controller
      @resource = resource
      @options = options
      self.status = @options[:status]
    end

    def respond!
      return send("respond_to_#{action}_action") if action.in?(ACTIONS)
      raise Errors::UnknownAction, action
    end

    def error
      self.errors = { errors: [error_render_options] }
      render_error
    end

    private

    def status=(status)
      return if status.nil?
      @status = Sanitizers.status(status)
    end

    def status_code
      raise Errors::StatusNotDefined if status.nil?
      Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    end

    def render_error
      controller.render(
        render_options.merge(
          json: error_render_options
        )
      )
    end

    def action
      @options[:params][:action]
    end

    def render_options
      {
        status: status,
        content_type: 'application/vnd.api+json'
      }
    end

    def error_render_options
      return errors if errors

      errors ||= {}
      errors[:errors] ||= []

      resource.errors.each do |attribute, message|
        errors[:errors] << error_response(attribute, message)
      end

      errors
    end

    def error_response(attribute = nil, message = nil)
      error = {
        title: I18n.t("json_api.errors.#{status}.title"),
        status: status_code.to_s,
        detail: error_detail(attribute, message)
      }
      error.merge(
        source: { parameter: attribute, pointer: "data/attributes/#{attribute}" }
      ) if attribute
      error
    end

    def error_detail(attribute, message)
      @options.fetch(:on_error, {}).fetch(:detail, nil) ||
        (message && resource.errors.full_message(attribute, message)) ||
        I18n.t("json_api.errors.#{status}.detail")
    end
  end
end
