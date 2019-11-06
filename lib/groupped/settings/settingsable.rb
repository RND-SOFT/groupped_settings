# frozen_string_literal: true

module Groupped
  module Settings
    module Settingsable

      extend ActiveSupport::Concern

      included do |_klass|
        has_many :groupped_settings, as: :target, dependent: :destroy, class_name: Groupped::Settings::Record.to_s

        def settings_group(group, klass = Group)
          Groupped::Settings[group, klass, target: self]
        end
      end

      class_methods do
      end

    end
  end
end

