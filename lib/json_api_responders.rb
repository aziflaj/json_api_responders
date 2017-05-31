require 'json_api_responders/version'
require 'json_api_responders/errors'
require 'json_api_responders/responder'
require 'json_api_responders/config'

module JsonApiResponders
  class << self
    attr_writer :config
  end

  def self.configure
    yield(config) if block_given?
  end

  def self.config
    @config ||= JsonApiResponders::Config.new
  end

  def self.included(base)
    if self.config.adapter == :active_record
      base.rescue_from ActiveRecord::RecordNotFound, with: :record_not_found!
    elsif self.config.adapter == :mongoid
      base.rescue_from Mongoid::Errors::DocumentNotFound, with: :record_not_found!
    end
    base.rescue_from ActionController::ParameterMissing, with: :parameter_missing!
  end

  def respond_with(resource, options = {})
    options = { params: params }.merge(options)
    JsonApiResponders.config.check_required_options(options)
    Responder.new(self, resource, options).respond!
  end

  def respond_with_error(status, detail = nil)
    Responder.new(self, nil, on_error: { status: status, detail: detail }).respond_error
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
