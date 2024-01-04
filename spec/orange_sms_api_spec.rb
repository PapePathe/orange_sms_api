# frozen_string_literal: true

RSpec.describe OrangeSmsApi do
  it "has a version number" do
    expect(OrangeSmsApi::VERSION).not_to be nil
  end

  def with_config url:, token:
    OrangeSmsApi.configure do |config|
      config.base_url = url || "https://api.orange.com"
      config.basic_auth_token = token
      config.read_timeout = 5
      config.write_timeout = 5
    end
  end

  it "will not authenticate with an invalid token" do
    with_config url: nil, token: "Basic false"

    VCR.use_cassette("authentification/invalid_token") do
      expected_json = JSON.parse "{\"error\":\"invalid_client\",\"error_description\":\"Unable to decode Basic authorization.\"}"
      expected_response = OrangeSmsApi::ApiResponse.new(false, "401", expected_json)

      expect(OrangeSmsApi.authenticate).to eq(expected_response)
    end
  end

  it "will not authenticate with an invalid credentials" do
    with_config url: nil, token: "Basic dGVzdDp0ZXN0"

    VCR.use_cassette("authentification/invalid_credentials") do
      expected_json = JSON.parse "{\"error\":\"invalid_client\",\"error_description\":\"The requested service needs credentials, but the ones provided were invalid.\"}"
      expected_response = OrangeSmsApi::ApiResponse.new(false, "401", expected_json)

      expect(OrangeSmsApi.authenticate).to eq(expected_response)
    end
  end

  it "will raise custom exception when socket error" do
    with_config url: "http://404-test.api.orange.com/oauth/v3/token", token: "Basic dGVzdDp0ZXN0"

    VCR.use_cassette("authentification/socket_error") do
      expect { OrangeSmsApi.authenticate }.to raise_error OrangeSmsApi::HttpRequestFailed
    end
  end

  it "will will raise invalid base url when it cannot parse the url" do
    with_config url: "", token: "Basic ORANGE_SMS_API_TOKEN"

    expect { OrangeSmsApi.authenticate }.to raise_error OrangeSmsApi::InvalidBaseUrl
  end


  it "will authenticate with a valid token" do
    with_config url: nil, token: "Basic ORANGE_SMS_API_TOKEN"

    VCR.use_cassette("authentification/valid_credentials", erb: {basic_auth_token: "Basic ORANGE_SMS_API_TOKEN"}) do
      expected_json = JSON.parse "\n{\n  \"token_type\": \"Bearer\",\n  \"access_token\": \"eyJ2ZXIiOiIxLjAiLCJ0eXAiOiJKV1QiLCJhbGciOiJFUzM4NCIsImtpZCI6ImRzRUN2TDVaTENQbTl1R081RHltUjZCRTdMcnFGak5hX1VKbl9Ody1zdVUifQ.eyJhcHBfbmFtZSI6ImVuZ2FnZW1lbnQuaW8iLCJzdWIiOiJqamZHSnpFSEtsR0E4b2ZFd0gyR1VWVU5oNWplbm1iUyIsImlzcyI6Imh0dHBzOlwvXC9hcGkub3JhbmdlLmNvbVwvb2F1dGhcL3YzIiwiZXhwIjoxNzA0MTY4NjgzLCJhcHBfaWQiOiJtMnJrSG45TDVxRHhBbDFTIiwiaWF0IjoxNzA0MTY1MDgzLCJjbGllbnRfaWQiOiJqamZHSnpFSEtsR0E4b2ZFd0gyR1VWVU5oNWplbm1iUyIsImp0aSI6IjgyZTFlZTViLTFhMTUtNDg2MC1iMmExLWY0NTY5Y2RiYzc0YSJ9.Q6AAKDCy2ajo3d_GDekhWeSRxc4-FdeHxoUNLW_s0TDJ4EnJI8LZIvK2ZPsSrT8oHieZSDi_NRRvoDkh0Hzh5SjVymtbfp4bytD0BxUscDfKYE-JCOBMzlh83WX3jmaO\",\n  \"expires_in\": 3600\n}\n        "
      expected_response = OrangeSmsApi::ApiResponse.new(true, "200", expected_json)
      expect(OrangeSmsApi.authenticate).to eq(expected_response)
    end
  end
end
