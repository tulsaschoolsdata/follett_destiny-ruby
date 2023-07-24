# frozen_string_literal: true

module FollettDestiny
  class API # :nodoc:
    def sites
      get('/sites').parse['value']
    end
  end
end
