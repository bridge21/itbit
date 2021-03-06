require 'rest_client'

module Itbit
  class ApiError < StandardError; end
  class Api
    def self.request(verb, path, options = { })
      timestamp = (Time.now.to_f * 1000).round.to_s
      nonce = timestamp
      payload = options.empty? || verb == :get ? nil : JSON.dump(options)
      query = options.any? && verb == :get ? "?#{options.to_query}" : ''
      url = "#{api_url}#{path}#{query}"

      signature = sign_message(verb, url, payload, nonce, timestamp)
      headers = {
        authorization: "#{Itbit.client_key}:#{signature}",
        x_auth_timestamp: timestamp,
        x_auth_nonce: nonce,
        content_type: 'application/json'
      }
      response = RestClient::Request.execute(
        :method => verb,
        :url => url,
        :payload => payload,
        :headers => headers,
        :ssl_version => 'SSLv23')
      JSON.parse(response.to_str) if response.to_str.presence
    end
    
    def self.api_url
      prefix = Itbit.sandbox ? 'beta-api' : 'api'
      "https://#{prefix}.itbit.com/v1"
    end

    def self.sign_message(verb, url, json_body, nonce, timestamp)
      message = JSON.dump([verb.upcase, url, json_body || '', nonce, timestamp])
      hash_digest = OpenSSL::Digest::SHA256.digest(nonce + message)
      hmac_digest = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA512.new, Itbit.secret, url + hash_digest)
      Base64.strict_encode64(hmac_digest)
    end
  end
end
