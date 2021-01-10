# frozen_string_literal: true

require_relative '../init'
require_relative 'search_monitor'
require_relative 'job_reporter'

require 'econfig'
require 'shoryuken'

module SearchProducts
  # Shoryuken worker class to search products in parallel
  class Worker
    extend Econfig::Shortcut
    Econfig.env = ENV['RACK_ENV'] || 'development'
    Econfig.root = File.expand_path('..', File.dirname(__FILE__))

    Shoryuken.sqs_client = Aws::SQS::Client.new(
      access_key_id: config.AWS_ACCESS_KEY_ID,
      secret_access_key: config.AWS_SECRET_ACCESS_KEY,
      region: config.AWS_REGION
    )

    include Shoryuken::Worker
    Shoryuken.sqs_client_receive_message_opts = { wait_time_seconds: 20 }
    # Shoryuken.sqs_client_receive_message_opts = { queue_url: config.SEARCH_QUEUE_URL, # required
    # attribute_names: ["All"],
    # message_attribute_names: ["poke_name"],
    # max_number_of_messages: 1,
    # visibility_timeout: 1,
    # wait_time_seconds: 20}
    # receive_request_attempt_id: '18' }
    shoryuken_options queue: config.SEARCH_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      job = JobReporter.new(request, Worker.config)
      puts "sqs #{job.poke_name}"
      job.report_each_second(5) { SearchMonitor.searching_percent }
      job.report(SearchMonitor.searching_percent)
      products = MerciDanke::GoogleShopping::ProductMapper.new.find(job.poke_name, MerciDanke::App.config.API_KEY)
      job.report(SearchMonitor.creating_percent)
      products.map { |prod| MerciDanke::SearchRecord::For.entity(prod).create(prod) }

      # Keep sending finished status to any latecoming subscribers
      job.report_each_second(2) { SearchMonitor.finished_percent }
    rescue StandardError
      # worker should crash early & often - only catch errors we expect!
      puts 'PRODUCTS EXISTS -- ignoring request'
    end
  end
end
