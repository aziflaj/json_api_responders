module JsonApiResponders
  class Responder
    module Sanitizers
      def self.status(status)
        if status.is_a?(Integer)
          status = Rack::Utils::SYMBOL_TO_STATUS_CODE.invert[status]
        end

        if status.nil? || !status.is_a?(Symbol) ||
           Rack::Utils::SYMBOL_TO_STATUS_CODE[status].nil?
          raise(Errors::UnknownHTTPStatus, status)
        end

        status
      end
    end
  end
end
