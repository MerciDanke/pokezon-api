# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
# require 'vcr'
# require 'webmock'

require_relative '../../init'

POKE_NAME = 'pikachu'
API_KEY = MerciDanke::App.config.API_KEY
