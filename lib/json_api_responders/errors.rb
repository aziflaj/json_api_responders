module JsonApiResponders
  module Errors
    class UnknownHTTPStatus < StandardError
      attr_reader :status

      def initialize(status)
        @status = status
        super(message)
      end

      def message
        status_symbols =
          Rack::Utils::SYMBOL_TO_STATUS_CODE.keys.map(&:to_s)
        status_codes =
          Rack::Utils::SYMBOL_TO_STATUS_CODE.invert.keys.map(&:to_s)
        statuses = (status_symbols + status_codes).join(', ')

        "Unknown HTTP status code '#{status}'.\n"\
        "Available status codes and symbols are: #{statuses}"
      end
    end

    class UnknownAction < StandardError
      attr_reader :action

      def initialize(action)
        @action = action
        super(message)
      end

      def message
        "Unknown controller action '#{action}'.\n"\
        "Accepted actions are #{JsonApi::Responder::ACTIONS.join(', ')}"
      end
    end

    class StatusNotDefined < StandardError
      def message
        'Status is not defined'
      end
    end
  end
end
