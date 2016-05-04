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
      self.status = @options[:status]
      @params = @options[:params]
      @controller = @options[:controller]
      @namespace = @options[:namespace]
    end

    def respond!
      render_response
    end

    def not_found
      self.errors = {
        title: I18n.t('json_api.errors.not_found.title'),
        status: status
      }

      render_error
    end

    def unauthorized
      self.errors = {
        title: I18n.t('json_api.errors.unauthorized.title'),
        status: status
      }

      render_error
    end

    private

    def status=(status)
      @status = Sanitizers.status(status)
    end

    def action
      params[:action]
    end

    def render_response
      return send("respond_to_#{action}_action") if action.in?(ACTIONS)
      raise(JsonApi::Errors::UnknownAction, action)
    end

    def render_error
      controller.render(error_render_options)
    end

    def error_render_options
      render_options.merge(
        json: error_messages
      )
    end

    def render_options
      {
        status: status,
        content_type: 'application/vnd.api+json'
      }
    end

    def error_messages
      return errors if errors

      resource.errors.full_messages.map do |message|
        {
          title: message,
          status: status
        }
      end
    end
  end
end
