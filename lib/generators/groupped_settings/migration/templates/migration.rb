MIGRATION_BASE_CLASS = if ActiveRecord::VERSION::MAJOR >= 5
  ActiveRecord::Migration[5.0]
else
  ActiveRecord::Migration
end

class RailsSettingsMigration < MIGRATION_BASE_CLASS
  def self.up
    create_table :settings, id: 'string' do |t|
      t.string     :value
    end
  end

  def self.down
    drop_table :settings
  end
end
