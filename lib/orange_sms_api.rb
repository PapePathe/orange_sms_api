# frozen_string_literal: true

require_relative "orange_sms_api/version"
require_relative "orange_sms_api/config"
require_relative "orange_sms_api/configuration"
require_relative "orange_sms_api/net_http_adapter"
require "uri"
require "net/http"

module OrangeSmsApi
  extend Config

  class Error < StandardError; end
  class InvalidBaseUrl < Error; end
  class HttpRequestFailed < Error; end
  ApiResponse = Struct.new(:success?, :status, :body)

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
    adapter = NetHttpAdapter.new(config)

    adapter.authenticate
  end
end
