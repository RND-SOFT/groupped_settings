# frozen_string_literal: true

require 'groupped_settings/version'
require 'groupped_settings/configuration'
require 'groupped_settings/adapter'
require 'groupped_settings/group'

module GrouppedSettings
  class << self
    attr_accessor :config
  end

  self.config ||= GrouppedSettings::Configuration.new

  class << self
    def configure
      self.config ||= GrouppedSettings::Configuration.new
      yield(config)
    end
  end
end
