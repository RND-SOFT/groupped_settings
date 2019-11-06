$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'groupped/settings/version'

Gem::Specification.new 'groupped_settings' do |spec|
  spec.version       = ENV['BUILDVERSION'].to_i > 0 ? "#{Groupped::Settings::VERSION}.#{ENV['BUILDVERSION'].to_i}" : Groupped::Settings::VERSION
  spec.authors       = ['Samoilenko Yuri']
  spec.email         = ['kinnalru@gmail.com']
  spec.description   = spec.summary = '!!!!'
  spec.homepage      = 'https://github.com/RnD-Soft/GrouppedSettings'
  spec.license       = 'MIT'

  spec.files         = %w[
    lib/groupped.rb
    lib/groupped/settings.rb
    lib/groupped/settings/version.rb
    lib/groupped/settings/configuration.rb
    lib/groupped/settings/group.rb
    lib/groupped/settings/settingsable.rb
    lib/groupped/settings/record.rb
    README.md LICENSE
  ].reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.add_development_dependency 'activerecord', '~>5.0'
  spec.add_development_dependency 'bundler', '~> 2.0', '>= 2.0.1'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'sqlite3'
end

