# frozen_string_literal: true

require 'climate_control'
require 'follett_destiny'
require 'openapi3_parser'
require 'webmock/rspec'

def base_uri
  'https://tenant.follettdestiny.test/api/v1/rest/context/saas012_3456789'
end

def openapi_auth
  @openapi_auth ||= Openapi3Parser.load_file('openapi/auth-api.yaml')
end

def openapi_resources
  @openapi_resources ||= Openapi3Parser.load_file('openapi/resources-api.yaml')
end

def openapi_sites
  @openapi_sites ||= Openapi3Parser.load_file('openapi/sites-api.yaml')
end

def with_modified_env(options = {}, &block)
  ClimateControl.modify(options, &block)
end

def with_env(options = {}, &block)
  with_modified_env({
    FOLLETT_DESTINY_BASE_URI: base_uri,
    FOLLETT_DESTINY_CLIENT_ID: 'example-client-id',
    FOLLETT_DESTINY_CLIENT_SECRET: 'example-client-secret'
  }.merge(options), &block)
end

def without_env(options = {}, &block)
  with_modified_env({
    FOLLETT_DESTINY_BASE_URI: nil,
    FOLLETT_DESTINY_CLIENT_ID: nil,
    FOLLETT_DESTINY_CLIENT_SECRET: nil
  }.merge(options), &block)
end

def stub_openapi_request( # rubocop:disable Metrics/AbcSize
  api:,
  path:,
  method:,
  status:,
  content_type: 'application/json'
)
  openapi_path = api.paths[path.gsub(/\?.*/, '')]
  content = openapi_path[method].responses[status].content[content_type]
  example = content.example || content.schema.example
  body = example.to_json
  headers = { content_type: content_type }

  url = Addressable::Template.new "#{base_uri}#{path}"
  stub_request(method, url).to_return(status: status, body: body, headers: headers)
end

def stub_auth_api_request(**kwargs)
  stub_openapi_request(api: openapi_auth, **kwargs)
end

def stub_access_token_request
  stub_auth_api_request(path: '/auth/accessToken', method: :post, status: 200)
end

def stub_count_request(path:, count: 101)
  headers = { content_type: 'text/plain' }
  url = Addressable::Template.new "#{base_uri}#{path}?$count=true"
  stub_request(:get, url).to_return(status: 200, body: count.to_s, headers: headers)
end

def count_paths
  %w[
    /materials/resources/items
    /materials/resourcetypes/{id}/resources
    /materials/resources/{id}/items
    /materials/resourcetypes/{resourceType}/items
  ]
end

def stub_resources_api_request(**kwargs)
  path, status = kwargs.values_at(:path, :status)
  stub_access_token_request if [nil, 200].include? status

  stub = stub_openapi_request(api: openapi_resources, **kwargs)
  stub_count_request(path: path) if count_paths.include? path
  stub
end

def stub_sites_api_request(**kwargs)
  stub_access_token_request if [nil, 200].include? kwargs[:status]

  stub_openapi_request(api: openapi_sites, **kwargs)
end

RSpec.configure do |c|
  c.around(:example) do |example|
    with_env { example.run }
  end
end
