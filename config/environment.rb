# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'delegate'
require 'rack/cache'
require 'redis-rack-cache'

module MerciDanke
  # Environment-specific configuration
  class App < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    # use Rack::Session::Cookie, secret: config.SESSION_SECRET

    configure :development, :test, :app_test do
      ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
    end

    configure :app_test do
      require_relative '../spec/helpers/vcr_helper'
      VcrHelper.setup_vcr
      VcrHelper.configure_vcr_for_apikey(recording: :none)
    end

    configure :development do
      use Rack::Cache,
          verbose: true,
          metastore: 'file:_cache/rack/meta',
          entitystore: 'file:_cache/rack/body'
    end

    configure do
      require 'sequel'
      DB = Sequel.connect(ENV['DATABASE_URL'])

      def self.DB # rubocop:disable Naming/MethodName
        DB
      end
    end
  end
end
