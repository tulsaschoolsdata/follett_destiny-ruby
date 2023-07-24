# frozen_string_literal: true

require 'http'
require_relative 'api/pagination'
require_relative 'api/resources'
require_relative 'api/sites'

module FollettDestiny
  class API # :nodoc:
    TOKEN_EXPIRATION_BUFFER = 10

    attr_accessor :base_uri, :client_id, :client_secret

    def configure(
      base_uri: nil,
      client_id: nil,
      client_secret: nil
    )
      @base_uri = base_uri || @base_uri || ENV.fetch('FOLLETT_DESTINY_BASE_URI')
      @client_id = client_id || @client_id || ENV.fetch('FOLLETT_DESTINY_CLIENT_ID')
      @client_secret = client_secret || @client_secret || ENV.fetch('FOLLETT_DESTINY_CLIENT_SECRET')
    end

    def initialize(...)
      configure(...)

      # NOTE: this is an issue with the response output from the Follett Destiny API
      # https://stackoverflow.com/questions/76183622/since-a-ruby-container-upgrade-we-expirience-a-lot-of-opensslsslsslerror
      # https://github.com/httprb/http/wiki/HTTPS#disabling-certificate-verification-ie-insecure-usage
      @ssl_context = OpenSSL::SSL::SSLContext.new
      @ssl_context.options += OpenSSL::SSL::OP_IGNORE_UNEXPECTED_EOF
    end

    def get(endpoint, params = {})
      url = uri(endpoint)
      resolve { request.get(url, params: params, ssl_context: @ssl_context) }
    end

    def post(endpoint, params = {})
      url = uri(endpoint)
      resolve { request.post(url, json: params, ssl_context: @ssl_context) }
    end

    def put(endpoint, params = {})
      url = uri(endpoint)
      resolve { request.put(url, json: params, ssl_context: @ssl_context) }
    end

    def patch(endpoint, params = {})
      url = uri(endpoint)
      resolve { request.patch(url, json: params, ssl_context: @ssl_context) }
    end

    def delete(endpoint)
      url = uri(endpoint)
      resolve { request.delete(url, ssl_context: @ssl_context) }
    end

    def request
      HTTP.headers(accept: 'application/json', content_type: 'application/json').auth(authorization)
    end

    def authorization
      @authorization = nil if !@expiration || @expiration < Time.now
      @authorization ||= authenticate
    end

    def authenticate
      form = {
        grant_type: 'client_credentials',
        client_id: client_id,
        client_secret: client_secret
      }
      url = uri('auth/accessToken')
      response = HTTP.post(url, form: form).parse
      access_token, token_type, expires_in = response.values_at('access_token', 'token_type', 'expires_in')

      @expiration = Time.now + (expires_in - TOKEN_EXPIRATION_BUFFER)

      "#{token_type} #{access_token}"
    end

    private

    def uri(endpoint)
      "#{base_uri}/#{endpoint.sub(%r{^/+}, '')}"
    end

    def token_expired_error(response)
      response.status == 401 && response.parse.dig('error', 'code') == 'CODE_EXPIRED_TOKEN'
    end

    def resolve(&block)
      begin
        response = block.call
      rescue HTTP::ConnectionError
        response = fresh_resolve(&block)
      end

      if token_expired_error(response)
        fresh_resolve(&block)
      else
        response
      end
    end

    def fresh_resolve(&block)
      @expiration = nil
      @authorization = nil

      block.call
    end
  end
end
