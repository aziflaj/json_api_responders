module JsonApiResponders
  class Config
    attr_reader :required_options

    def required_options=(opts = {})
      @required_options = opts
    end

    def check_required_options(options)
      return if @required_options.nil? || @required_options.empty?
      action = action(options)

      if action && @required_options.key?(action)
        @required_options[action].each do |key|
          raise JsonApiResponders::Errors::RequiredOptionMissingError, key unless options.key? key
        end
      end
    end

    private

    def action(options)
      options[:params][:action].to_sym if action_present?(options)
    end

    def action_present?(options)
      !options[:params].nil? &&
        !options[:params].empty? &&
          !options[:params][:action].nil? &&
            !options[:params][:action].empty?
    end
  end
end
