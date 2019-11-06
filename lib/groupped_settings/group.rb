# frozen_string_literal: true

module GrouppedSettings
  class Group
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Dirty
    extend ActiveModel::Translation
    include ActiveModel::Serializers::JSON

    def self.group_name
      to_s.demodulize.sub('Group', '').underscore
    end

    def self.group_class(group)
      "#{group}_group".camelize.safe_constantize
    end

    def self.attribute_names
      attribute_types.keys
    end

    def self.load
      new.reload
    end

    def self.to_group_key(key)
      "#{group_name}.#{key}".downcase
    end

    def self.from_group_key(key)
      key.downcase.gsub("#{group_name}.", '')
    end

    def initialize
      super({})
    end

    def to_h
      serializable_hash
    end

    def to_hash
      serializable_hash
    end

    def ==(other)
      attributes == other.attributes
    end

    def reload
      restore_attributes
      adapter.list(self.class.group_name).each do |s|
        key = self.class.from_group_key(s[:key])
        send("#{key}=", s[:value])
      end

      clear_changes_information
      self
    end

    def save
      save!
    rescue StandardError => e
      false
    end

    def save!
      adapter.with_transaction do
        validate!
        _save!
        clear_changes_information
      end
      true
    end

    private

    def adapter
      @adapter ||= GrouppedSettings::Adapter.new(
        key_field: GrouppedSettings.config.key_field,
        value_field: GrouppedSettings.config.value_field
      )
    end

    def _save!
      changes.each do |(id, (o, n))|
        db_key = self.class.to_group_key(id)
        adapter.upsert!(db_key, n) if o != n
      end
    end
  end
end
