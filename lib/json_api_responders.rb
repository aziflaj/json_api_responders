require 'json_api_responders/version'
require 'json_api_responders/errors'
require 'json_api_responders/responder'

module JsonApiResponders
  def self.included(base)
    base.rescue_from ActiveRecord::RecordNotFound, with: :record_not_found!
    base.rescue_from ActionController::ParameterMissing, with: :parameter_missing!
    redefine_authorization(base)
  end

  def self.redefine_authorization(base)
    return unless base.instance_methods.include?(:authenticate_user_from_token!)

    base.class_eval do
      alias_method(:_authenticate_from_token!, :authenticate_user_from_token!)

      define_method :authenticate_user_from_token! do
        result = catch(:warden) { _authenticate_from_token! }

        return unless result
        respond_with_error(:unauthorized)
      end
    end
  end

  private

  def respond_with_error(error_type, error_detail = nil)
    Responder.new(nil, controller: self, status: error_type, error_detail: error_detail).error
  end

  def respond_with(resource, options = {})
    options = {
      namespace: self.class.parent,
      params: params,
      controller: self
    }.merge(options)

    Responder.new(resource, options).respond!
  end

  def record_not_found!
    respond_with_error(:not_found)
  end

  def parameter_missing!(reason)
    respond_with_error(:parameter_missing, reason.message)
  end

  def deserialized_params
    @_deserialized_options ||=
      ActionController::Parameters.new(
        ActiveModelSerializers::Deserialization.jsonapi_parse(
          params, json_api_parse_options
        )
      )
  end

  def json_api_parse_options
    {}
  end
end
