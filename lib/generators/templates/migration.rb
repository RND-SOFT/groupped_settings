# frozen_string_literal: true

MIGRATION_BASE_CLASS = if ActiveRecord::VERSION::MAJOR >= 5
  ActiveRecord::Migration[5.0]
else
  ActiveRecord::Migration
end

class GrouppedSettingsMigration < MIGRATION_BASE_CLASS

  def self.up
    create_table :groupped_settings_records do |t|
      t.string :group, index: true, null: true

      if t.respond_to? :jsonb
        t.jsonb :settings, null: false, default: {}
      else
        t.json :settings, null: false, default: {}
      end

      t.belongs_to :target, polymorphic: true, type: :string, index: true, null: true
    end
  end

  def self.down
    drop_table :groupped_settings_records
  end

end

