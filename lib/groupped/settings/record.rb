# frozen_string_literal: true

module Groupped
  module Settings
    class Record < Groupped::Settings.config.base

      self.table_name = 'groupped_settings_records'

      belongs_to :target, polymorphic: true, required: false

      def self.sanitize(settings)
        settings.deep_transform_keys{|key| key.to_s.downcase }
      end

      before_validation do
        self.settings = self.class.sanitize(self.settings)
      end

    end
  end
end

