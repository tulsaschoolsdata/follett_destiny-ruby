Gem::Specification.new do |s|
  s.name        = 'follett_destiny'
  s.version     = '0.0.0'
  s.summary     = 'Follett Destiny API client library for Ruby'
  s.description = 'Client library for working with Follett Destiny API in Ruby'
  s.authors     = ['Tulsa Public Schools - DEV Team']
  s.email       = 'devteam@tulsaschools.org'
  s.files       = ['lib/follett_destiny.rb']
  s.homepage    = 'https://github.com/tulsaschoolsdata/follett_destiny-ruby'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.0.0'

  s.add_runtime_dependency 'http', '~> 5.1'
  s.add_runtime_dependency 'httparty', '~> 0.21.0'
end
