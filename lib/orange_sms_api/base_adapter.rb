module OrangeSmsApi
  class BaseAdapter
    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def authenticate
      raise NotImplementedError
    end

    def authenticate_url
      "#{config.base_url}/oauth/v3/token"
    end
  end
end
