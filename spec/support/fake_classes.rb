module ActiveRecord
  class RecordNotFound < StandardError
  end
end

module ActionController
  class ParameterMissing
  end
end

class FakeController
  def self.rescue_from(*_args)
  end

  include JsonApiResponders

  def params
    {}
  end
end

class FakeModel
  def errors
    Message.new(name: 'cant be blank')
  end
end

class I18n
  def self.t(transaltion)
    transaltion
  end
end

class Message
  def initialize(array)
    @array = array
  end

  def each(&block)
    @array.each(&block)
  end

  def full_message(attribute, message)
    "#{attribute.to_s.capitalize} #{message}"
  end
end
