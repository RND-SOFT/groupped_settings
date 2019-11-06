# frozen_string_literal: true

require 'logger'

module GrouppedSettings
  class Configuration
    attr_accessor :base, :key_field, :value_field, :logger

    # Override defaults for configuration
    # @param cookie [String] cookie name to store encrypted data
    # @param secret [String] secret key(shared between applications) to use in ActiveSupport::MessageEncryptor
    def initialize
      @logger = Logger.new(STDOUT, level: Logger::INFO, progname: 'GrouppedSettings')
      @base = ::ActiveRecord::Base
      @key_field = :id
      @value_field = :value
    end
  end
end
