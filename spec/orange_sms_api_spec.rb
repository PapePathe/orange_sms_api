# frozen_string_literal: true

RSpec.describe OrangeSmsApi do
  it "has a version number" do
    expect(OrangeSmsApi::VERSION).not_to be nil
  end

  def with_config url:, token:
    OrangeSmsApi.configure do |config|
      config.base_url = url || "https://api.orange.com/oauth/v3/token"
      config.basic_auth_token = token
    end
  end

  it "will not authenticate with an invalid token" do
    with_config url: nil, token: "Basic false"

    VCR.use_cassette("authentification/invalid_token") do
      expected_response = "{\"error\":\"invalid_client\",\"error_description\":\"Unable to decode Basic authorization.\"}"
      expect(OrangeSmsApi.authenticate).to eq([false, expected_response])
    end
  end

  it "will not authenticate with an invalid credentials" do
    with_config url: nil, token: "Basic dGVzdDp0ZXN0"

    VCR.use_cassette("authentification/invalid_credentials") do
      expected_response = "{\"error\":\"invalid_client\",\"error_description\":\"The requested service needs credentials, but the ones provided were invalid.\"}"
      expect(OrangeSmsApi.authenticate).to eq([false, expected_response])
    end
  end

  it "will not authenticate when socket error" do
    with_config url: "http://404-test.api.orange.com/oauth/v3/token", token: "Basic dGVzdDp0ZXN0"

    VCR.use_cassette("authentification/socket_error") do
      expected_response = "http-request-error"
      expect(OrangeSmsApi.authenticate).to eq([false, expected_response])
    end
  end

  it "will authenticate with a valid token" do
    with_config url: nil, token: "Basic ORANGE_SMS_API_TOKEN"

    VCR.use_cassette("authentification/valid_credentials", erb: {basic_auth_token: "Basic ORANGE_SMS_API_TOKEN"}) do
      expected_response = "\n{\n  \"token_type\": \"Bearer\",\n  \"access_token\": \"eyJ2ZXIiOiIxLjAiLCJ0eXAiOiJKV1QiLCJhbGciOiJFUzM4NCIsImtpZCI6ImRzRUN2TDVaTENQbTl1R081RHltUjZCRTdMcnFGak5hX1VKbl9Ody1zdVUifQ.eyJhcHBfbmFtZSI6ImVuZ2FnZW1lbnQuaW8iLCJzdWIiOiJqamZHSnpFSEtsR0E4b2ZFd0gyR1VWVU5oNWplbm1iUyIsImlzcyI6Imh0dHBzOlwvXC9hcGkub3JhbmdlLmNvbVwvb2F1dGhcL3YzIiwiZXhwIjoxNzA0MTY4NjgzLCJhcHBfaWQiOiJtMnJrSG45TDVxRHhBbDFTIiwiaWF0IjoxNzA0MTY1MDgzLCJjbGllbnRfaWQiOiJqamZHSnpFSEtsR0E4b2ZFd0gyR1VWVU5oNWplbm1iUyIsImp0aSI6IjgyZTFlZTViLTFhMTUtNDg2MC1iMmExLWY0NTY5Y2RiYzc0YSJ9.Q6AAKDCy2ajo3d_GDekhWeSRxc4-FdeHxoUNLW_s0TDJ4EnJI8LZIvK2ZPsSrT8oHieZSDi_NRRvoDkh0Hzh5SjVymtbfp4bytD0BxUscDfKYE-JCOBMzlh83WX3jmaO\",\n  \"expires_in\": 3600\n}\n        "
      expect(OrangeSmsApi.authenticate).to eq([true, expected_response])
    end
  end
end
