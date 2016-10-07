require 'json_api_responders/version'
require 'json_api_responders/errors'
require 'json_api_responders/responder'

module JsonApiResponders
  def self.included(base)
    base.rescue_from ActiveRecord::RecordNotFound, with: :record_not_found!
    base.rescue_from ActionController::ParameterMissing, with: :parameter_missing!
  end

  def respond_with(resource, options = {})
    options = { params: params }.merge(options)
    Responder.new(self, resource, options).respond!
  end

  def respond_with_error(status, detail = nil)
    Responder.new(self, on_error: { status: status, error: detail }).respond_error
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
