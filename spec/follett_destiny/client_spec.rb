# frozen_string_literal: true

require_relative '../spec_helper'

describe FollettDestiny::Client do
  around do |example|
    with_env { example.run }
  end

  it 'inherits API' do
    expect(described_class.ancestors).to include(FollettDestiny::API)
  end

  it 'implements singleton' do
    expect(described_class.ancestors).to include(Singleton)
  end

  it 'is a working single' do
    client1 = described_class.instance
    client2 = described_class.instance

    expect(client1).to be(client2)
  end
end
