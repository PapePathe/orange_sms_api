require_relative "base_adapter"

module OrangeSmsApi
  class NetHttpAdapter < BaseAdapter
    def authenticate
      url = URI(authenticate_url)
      client = http_client(url)

      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = "application/x-www-form-urlencoded"
      request["Authorization"] = config.basic_auth_token
      request.body = "grant_type=client_credentials"

      response = client.request(request)

      if response.code == "200"
        return ApiResponse.new true, response.code, JSON.parse(response.body)
      end

      ApiResponse.new false, response.code, JSON.parse(response.body)
    rescue ArgumentError => e
      raise InvalidBaseUrl, "invalid base url please check your configuration"
    rescue *ALL_NET_HTTP_ERRORS => e
      raise HttpRequestFailed, e.message
    end

    def http_client(url)
      client = Net::HTTP.new(url.host, url.port)
      client.use_ssl = true
      client.read_timeout = config.read_timeout
      client.write_timeout = config.write_timeout
      client
    end
  end
end
