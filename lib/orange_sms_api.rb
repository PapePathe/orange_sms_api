# frozen_string_literal: true

require_relative "orange_sms_api/version"
require "uri"
require "net/http"

module OrangeSmsApi
  class Error < StandardError; end

  ALL_NET_HTTP_ERRORS = [
    SocketError,
    Timeout::Error,
    Errno::EINVAL,
    Errno::ECONNRESET,
    EOFError,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError
  ].freeze

  module_function

  def authenticate
    url = URI(config.base_url)

    client = Net::HTTP.new(url.host, url.port)
    client.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request["Authorization"] = config.basic_auth_token
    request.body = "grant_type=client_credentials"

    response = client.request(request)

    if response.code == "200"
      return [true, response.body]
    end

    [false, response.body]
  rescue *ALL_NET_HTTP_ERRORS
    [false, "http-request-error"]
  end

  def config
    @config ||= Config.new
  end

  def configure
    yield(config)
  end

  class Config
    attr_accessor :base_url, :basic_auth_token
  end
end
