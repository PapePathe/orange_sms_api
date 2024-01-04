module OrangeSmsApi
  module Config
    def config
      @config ||= Configuration.new
    end

    def configure
      yield(config)
    end
  end
end
