# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'

require_relative '../../init'

POKE_ID = '1'
POKE_NAME = 'bulbasaur'
PRODUCT_OID = 'B07K4RC7Y5'
CORRECT = YAML.safe_load(File.read('spec/fixtures/poke_data/poke1_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'pokemon_api'

API_KEY = MerciDanke::App.config.API_KEY

# Helper methods
def homepage
  MerciDanke::App.config.APP_HOST
end
