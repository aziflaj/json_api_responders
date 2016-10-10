module JsonApiResponders
  class Config
    attr_reader :required_options

    def required_options=(opts = [])
      @required_options = opts
    end

    def check_required_options(options)
      return if @required_options.nil?
      @required_options.each do |key|
        raise JsonApiResponders::Errors::RequiredOptionMissingError, key unless options.key? key
      end
    end
  end
end
