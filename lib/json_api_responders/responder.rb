require 'json_api_responders/responder/actions'
require 'json_api_responders/responder/sanitizers'

module JsonApiResponders
  class Responder
    include Actions

    attr_accessor :errors
    attr_accessor :status
    attr_reader :resource
    attr_reader :options
    attr_reader :params
    attr_reader :controller
    attr_reader :namespace

    def initialize(resource, options = {})
      @resource = resource
      @options = options
      self.status = @options[:status] if @options[:status]
      @params = @options[:params]
      @controller = @options[:controller]
      @namespace = @options[:namespace]
    end

    def respond!
      render_response
    end

    def error
      self.errors = {
        errors: [
          {
            title: I18n.t("json_api.errors.#{status}.title"),
            detail: @options[:error_detail] || I18n.t("json_api.errors.#{status}.detail"),
            status: status_code
          }
        ]
      }

      render_error
    end

    private

    def status=(status)
      @status = Sanitizers.status(status)
    end

    def status_code
      Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    end

    def render_error
      controller.render(error_render_options)
    end

    def action
      params[:action]
    end

    def render_response
      return send("respond_to_#{action}_action") if action.in?(ACTIONS)
      fail JsonApiResponders::Errors::UnknownAction, action
    end

    def error_render_options
      render_options.merge(
        json: error_response, status: 400
      )
    end

    def render_options
      {
        status: status,
        content_type: 'application/vnd.api+json'
      }
    end

    def error_response
      return errors if errors

      errors ||= {}
      errors[:errors] ||= []

      resource.errors.each do |attribute, message|
        errors[:errors] << {
          title: I18n.t("json_api.errors.#{status}.title"),
          detail: resource.errors.full_message(attribute, message),
          status: status_code.to_s,
          source: {
            parameter: attribute,
            pointer: "data/attributes/#{attribute}"
          }
        }
      end

      errors
    end
  end
end
