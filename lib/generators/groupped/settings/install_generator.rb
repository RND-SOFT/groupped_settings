# frozen_string_literal: true

require 'rails/generators/base'

module Groupped
  module Settings
    module Generators


      MissingORMError = Class.new(Thor::Error)

      class InstallGenerator < Rails::Generators::Base

        puts File.expand_path('../../templates', __dir__)
        source_root File.expand_path('../../templates', __dir__)

        desc 'Creates a Groupped::Settings initializer and copy locale files to your application.'

        def copy_initializer
          template 'groupped_settings.rb', 'config/initializers/groupped_settings.rb'
        end

      end


    end
  end
end

