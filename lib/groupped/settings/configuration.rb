# frozen_string_literal: true

require 'logger'

module Groupped
  module Settings
    class Configuration

      attr_accessor :base, :logger

      def initialize
        @logger = Logger.new(STDOUT, level: Logger::INFO, progname: 'Groupped::Settings')
        @base = ::ActiveRecord::Base
      end

    end
  end
end

