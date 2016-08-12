require 'json_api_responders/version'
require 'json_api_responders/errors'
require 'json_api_responders/responder'

module JsonApiResponders
  def self.included(base)
    base.rescue_from ActiveRecord::RecordNotFound, with: :record_not_found!
    base.rescue_from ActionController::ParameterMissing, with: :parameter_missing!
  end

  def respond_with_error(error_type, detail = nil)
    case error_type
    when :unauthorized
      Responder.new(self, status: :forbidden, on_error: { error: detail }).error
    when :not_found
      Responder.new(self, status: :not_found).error
    when :parameter_missing
      Responder.new(self, status: :unprocessable_entity, on_error: { error: detail }).error
    end
  end

  def respond_with(resource, options = {})
    options = { params: params }.merge(options)

    Responder.new(self, resource, options).respond!
  end

  def deserialized_params
    @_deserialized_options ||=
      ActionController::Parameters.new(
        ActiveModelSerializers::Deserialization.jsonapi_parse(
          params, json_api_parse_options
        )
      )
  end

  private

  def record_not_found!
    respond_with_error(:not_found)
  end

  def parameter_missing!(reason)
    respond_with_error(:parameter_missing, reason.message)
  end

  def json_api_parse_options
    {}
  end
end
