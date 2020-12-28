# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
class VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  CASSETTE_FILE = 'product_api'

  def self.setup_vcr
    VCR.configure do |vcr|
      vcr.cassette_library_dir = CASSETTES_FOLDER
      vcr.hook_into :webmock
      vcr.ignore_localhost = true
      vcr.ignore_hosts 'sqs.ap-northeast-1.amazonaws.com'
    end
  end

  def self.configure_vcr_for_apikey(recording: :new_episodes)
    VCR.configure do |vcr|
      vcr.filter_sensitive_data('<API_KEY>') { API_KEY }
      vcr.filter_sensitive_data('<API_KEY_ESC>') { CGI.escape(API_KEY) }
    end

    VCR.insert_cassette(
      CASSETTE_FILE,
      record: recording,
      match_requests_on: %i[method uri headers],
      allow_playback_repeats: true
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
