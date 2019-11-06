# frozen_string_literal: true

module GrouppedSettings
  class Adapter
    attr_reader :k, :value

    def initialize(key_field:, value_field:)
      @k = key_field
      @v = value_field
    end

    def with_transaction
      klass.transaction do
        yield
      end
    end

    def upsert!(key, value)
      klass.find_or_initialize_by(@k => key).update_attributes!(@v => value)
    end

    def list(group)
      Enumerator.new do |y|
        klass.where("#{klass.table_name}.#{@k} #{like_by_bd} '#{group}.%'").each do |model|
          y << { key: model[@k], value: model[@v] }
        end
      end
    end

    def klass
      GrouppedSettings::Setting
    end

    def like_by_bd
      env = ENV.fetch('RACK_ENV', ENV.fetch('RAILS_ENV', 'development'))
      ActiveRecord::Base.configurations[env]['adapter'] == 'postgresql' ? 'ILIKE' : 'LIKE'
    end
  end
end
