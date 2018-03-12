require_relative './lib/association_builder/version'

Gem::Specification.new do |spec|
  spec.name          = 'association_builder'
  spec.version       = AssociationBuilder::VERSION
  spec.authors       = ['CicholGricenchos']
  spec.email         = ['cichol@live.cn']
  spec.homepage      = 'https://github.com/CicholGricenchos/association_builder'
  spec.summary       = ''
  spec.description   = ''
  spec.license       = 'MIT'

  spec.files         = Dir.glob("lib/**/*.rb")

  spec.add_runtime_dependency 'activerecord', '>= 5.0', '< 6.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'rake'
end
