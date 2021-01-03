# frozen_string_literal: true

# require_relative '../app/domain/init'
# require_relative '../app/application/requests/init'
# require_relative '../app/infrastructure/gateways/init'
# require_relative '../app/presentation/representers/init'
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
    shoryuken_options queue: config.SEARCH_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      job = JobReporter.new(request, Worker.config)
      job.report(SearchMonitor.starting_percent)
      job.report(SearchMonitor.searching_percent)
      am_products = MerciDanke::Amazon::ProductMapper.new.find(job.poke_name, MerciDanke::App.config.API_KEY)
      job.report(SearchMonitor.creating_percent)
      am_products.map { |prod| MerciDanke::SearchRecord::For.entity(prod).create(prod) }

      # ?????????????????????????????
      # CodePraise::GitRepo.new(job.project, Worker.config).clone_locally do |line|
      #   job.report SearchMonitor.progress(line)
      # end

      # Keep sending finished status to any latecoming subscribers
      job.report_each_second(5) { SearchMonitor.finished_percent }
    rescue StandardError
      # worker should crash early & often - only catch errors we expect!
      puts 'PRODUCTS EXISTS -- ignoring request'
    #   am_products = MerciDanke::Amazon::ProductMapper.new.find(request, MerciDanke::App.config.API_KEY)
    #   am_products.map { |prod| MerciDanke::SearchRecord::For.entity(prod).create(prod) }
    # rescue StandardError
    #   puts 'AMAZON is busy. Please try again!'
    end
  end
end
