# frozen_string_literal: true

module GrouppedSettings
  class Setting < GrouppedSettings.config.base
    def self.[](group)
      GrouppedSettings::Group.group_class(group).load
    end
  end
end

# class Setting::GenericGroup < Setting::BaseGroup
#
#  attribute :key1, :integer
#  attribute :key2, :integer
#  attribute :key3, :integer
#
#
#  validates :key1, numericality: true
#
# end
