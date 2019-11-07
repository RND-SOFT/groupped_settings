# frozen_string_literal: true

module Groupped
  module Settings
    class Group

      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Dirty
      extend ActiveModel::Translation
      include ActiveModel::Serializers::JSON

      class << self

        attr_accessor :group_name

      end

      def self.attribute_names
        attribute_types.keys
      end

      def self.sanitize(settings)
        Record.sanitize(settings).slice(*self.attribute_names)
      end

      def self.load(target: nil, settings: {})
        Groupped::Settings[self.group_name, self, target: target, settings: settings]
      end

      def initialize(record)
        @settings_record = record
        super(self.class.sanitize(record.settings))
        clear_changes_information
      end

      def to_h
        serializable_hash
      end

      def to_hash
        serializable_hash
      end

      def group_name
        self.class.group_name
      end

      def ==(other)
        group_name == other.group_name && attributes == other.attributes
      end

      def save
        save!
      rescue StandardError => e
        false
      end

      def save!
        validate!
        _save!
        clear_changes_information
        true
      end

      private

        def _make_changes(changes)
          changes.each_with_object({}) do |(key, (o, n)), ret|
            ret[key.to_s.downcase] = n if o != n
          end
        end

        def _save!
          @settings_record.with_lock do
            @settings_record.settings.merge!(_make_changes(changes))
            @settings_record.save!
          end
        end

    end
  end
end

