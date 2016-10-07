require 'json_api_responders/responder/actions'
require 'json_api_responders/responder/sanitizers'

module JsonApiResponders
  class Responder
    include Actions

    attr_accessor :options
    attr_reader :resource
    attr_reader :controller

    def initialize(controller, resource = nil, options = {})
      @controller = controller
      @resource = resource
      @options = options
    end

    def respond!
      return send("respond_to_#{action}_action") if ACTIONS.include?(action)
      raise JsonApiResponders::Errors::UnknownAction, action
    end

    def respond_error
      render_error
    end

    def status
      return nil if @options[:status].nil?
      Sanitizers.status(@options[:status])
    end

    def status=(status)
      @options[:status] = status
    end

    private

    def render_error
      controller.render(
        render_options.merge(
          json: error_render_options,
          status: error_status
        )
      )
    end

    def error_status
      return Sanitizers.status(on_error(:status)) if on_error(:status)
      status
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
      errors = { errors: [] }

      errors[:errors] << { detail: on_error(:detail) } if on_error(:detail)

      resource.errors.each do |attribute, message|
        errors[:errors] << error_response(attribute, message)
      end if resource.respond_to?(:errors)

      errors
    end

    def error_response(attribute, message)
      {
        title: I18n.t("json_api.errors.#{status}.title"),
        detail: resource.errors.full_message(attribute, message),
        source: { parameter: attribute, pointer: "data/attributes/#{attribute}" }
      }
    end

    def on_error(key)
      @options.fetch(:on_error, {}).fetch(key, nil)
    end
  end
end
