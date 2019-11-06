# frozen_string_literal: true

require 'active_record'
require 'protected_attributes' if ENV['PROTECTED_ATTRIBUTES'] == 'true'

I18n.enforce_available_locales = false if I18n.respond_to?(:enforce_available_locales=)

class User < ActiveRecord::Base
  # has_settings do |s|
  #   s.key :dashboard, :defaults => { :theme => 'blue', :view => 'monthly', :filter => true }
  #   s.key :calendar,  :defaults => { :scope => 'company'}
  # end
end

def setup_db
  ActiveRecord::Base.configurations = YAML.load_file(File.dirname(__FILE__) + '/database.yml')
  ActiveRecord::Base.establish_connection(:test)
  ActiveRecord::Migration.verbose = false

  print "Testing with ActiveRecord #{ActiveRecord::VERSION::STRING}"
  if ActiveRecord::VERSION::MAJOR == 4
    print " #{defined?(ProtectedAttributes) ? 'with' : 'without'} gem `protected_attributes`"
  end
  puts

  require File.expand_path("#{$root}/../lib/generators/templates/migration.rb", __FILE__)
  GrouppedSettingsMigration.migrate(:up)

  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string :type
      t.string :name
    end
  end
end

def clear_db
  User.delete_all
  # RailsSettings::SettingObject.delete_all
end

setup_db

