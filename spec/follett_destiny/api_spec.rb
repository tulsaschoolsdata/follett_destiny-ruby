# frozen_string_literal: true

require_relative '../spec_helper'

describe FollettDestiny::API do
  let(:configuration) do
    {
      base_uri: 'https://tenant.follettdestiny.test/api/v1/rest/context/saas012_3456789',
      client_id: 'example-client-id',
      client_secret: 'example-client-secret'
    }
  end

  let(:api) { described_class.new **configuration }

  describe 'initialize' do
    %w[FOLLETT_DESTINY_BASE_URI FOLLETT_DESTINY_CLIENT_ID FOLLETT_DESTINY_CLIENT_SECRET].each do |key|
      it "fetches environment variable #{key}" do
        with_env do
          allow(ENV).to receive(:fetch).and_call_original
          described_class.new
          expect(ENV).to have_received(:fetch).with(key)
        end
      end
    end

    it 'ignores ssl unexpected eof' do # rubocop:disable RSpec/ExampleLength
      stub_sites_api_request(path: '/sites', method: :get, status: 200)

      request = api.request

      # Use and_wrap_original instead of and_call_original to Suppress warning:
      #
      #   WARNING: You're overriding a previous stub implementation of `get`
      #
      # https://github.com/rspec/rspec-mocks/issues/774#issuecomment-236318412
      #
      allow(request).to receive(:get).and_wrap_original do |original, url, options|
        ssl_context = options[:ssl_context]
        check = ssl_context.options & OpenSSL::SSL::OP_IGNORE_UNEXPECTED_EOF
        expect(check).to eq(OpenSSL::SSL::OP_IGNORE_UNEXPECTED_EOF)
        original.call(url, options)
      end

      allow(api).to receive(:request).and_return(request)

      api.get('/sites')
    end
  end

  describe 'configure' do
    it 'can modify configuration' do
      with_env do
        api = described_class.new
        expect do
          api.configure(client_id: "#{api.client_id} changed")
        end.to change { api.client_id }
      end
    end
  end

  describe 'sites' do
    it 'requests the sites endpoint' do
      stub = stub_sites_api_request(path: '/sites', method: :get, status: 200)
      value = JSON.parse(stub.response.body)['value']

      expect(api.sites).to eq(value)
    end
  end

  describe 'resource_item' do
    it 'errors if id or barcode are not provided' do
      expect { api.resource_item }.to raise_error(ArgumentError)
    end

    it 'errors if id and barcode are provided' do
      expect { api.resource_item(id: 'id', barcode: 'barcode') }.to raise_error(ArgumentError)
    end

    context 'with barcode argument' do
      let(:barcode) { 'barcode' }
      let(:path) { "/materials/resources/items?$top=1&itemBarcode=#{barcode}" }

      it 'requests top one resource item with barcode' do
        stub_resources_api_request(path: path, method: :get, status: 200)

        allow(api).to receive(:resource_items).and_call_original
        api.resource_item(barcode: barcode)

        expect(api).to have_received(:resource_items).with('itemBarcode' => barcode, '$top' => 1)
      end
    end

    context 'with id argument' do
      let(:id) { '{id}' }
      let(:path) { '/materials/resources/items/{id}' }

      it 'requests top one resource item with barcode' do
        stub_resources_api_request(path: path, method: :get, status: 200)

        allow(api).to receive(:get).and_call_original
        api.resource_item(id: id)

        expect(api).to have_received(:get).with(path)
      end
    end
  end

  describe 'resource_types' do
    it 'requests the resource types endpoint' do
      stub = stub_resources_api_request(path: '/materials/resourcetypes', method: :get, status: 200)
      value = JSON.parse(stub.response.body)

      expect(api.resource_types).to eq(value)
    end
  end

  describe 'resource_items' do
    it 'requests the resources items endpoint' do
      stub = stub_resources_api_request(path: '/materials/resources/items', method: :get, status: 200)
      value = JSON.parse(stub.response.body)['value']

      expect(api.resource_items).to eq(value)
    end
  end

  describe 'resource_type' do
    it 'requests the specific resource type endpoint' do
      stub = stub_resources_api_request(path: '/materials/resourcetypes/{resourceType}', method: :get, status: 200)
      value = JSON.parse(stub.response.body)

      expect(api.resource_type('{resourceType}')).to eq(value)
    end
  end

  describe 'resource_type_items' do
    it 'requests the specific resource type items endpoint' do
      skip 'figure out pagination stubbing'
    end
  end

  describe 'resource_types_list' do
    it 'returns a list of guid, name, and path' do
      stub_resources_api_request(path: '/materials/resourcetypes', method: :get, status: 200)

      expect(api.resource_types_list).to all(include(:guid, :name, :path))
    end
  end
end
