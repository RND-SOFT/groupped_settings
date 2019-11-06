# frozen_string_literal: true

require 'groupped/settings/version'
require 'groupped/settings/configuration'
require 'groupped/settings/group'
require 'groupped/settings/settingsable'

module Groupped
  module Settings

    class << self

      attr_accessor :config

    end

    self.config ||= ::Groupped::Settings::Configuration.new

    class << self

      def [](group, klass = Group, target: nil)
        klass.new(Record.first_or_create!(group: group.downcase, target: target))
      end

      def configure
        self.config ||= ::Groupped::Settings::Configuration.new
        yield(config)
        require 'groupped/settings/record'
      end

    end

  end
end

