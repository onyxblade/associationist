require_relative './lib/associationist/version'

Gem::Specification.new do |spec|
  spec.name          = 'associationist'
  spec.version       = Associationist::VERSION
  spec.authors       = ['onyxblade']
  spec.email         = ['cichol@live.cn']
  spec.homepage      = 'https://github.com/onyxblade/associationist'
  spec.summary       = ''
  spec.description   = ''
  spec.license       = 'MIT'

  spec.files         = Dir.glob("lib/**/*.rb")

  spec.add_runtime_dependency 'activerecord', '>= 5.0', '< 7.2'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'rake'
end
