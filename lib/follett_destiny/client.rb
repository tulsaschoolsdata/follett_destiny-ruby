# frozen_string_literal: true

require 'singleton'

module FollettDestiny
  class Client < API
    include Singleton

    def self.configure(...)
      instance.configure(...)
    end
  end
end
