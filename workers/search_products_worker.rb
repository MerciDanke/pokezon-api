# frozen_string_literal: true

require_relative '../init'

require 'econfig'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
class SearchProductsWorker
  extend Econfig::Shortcut
  Econfig.env = ENV['RACK_ENV'] || 'development'
  Econfig.root = File.expand_path('..', File.dirname(__FILE__))

  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.CLONE_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    # puts '_sqs_msg: ', _sqs_msg
    puts 'request: ', request
    puts 'request class: ', request.class
    am_products = MerciDanke::Amazon::ProductMapper.new.find(request, MerciDanke::App.config.API_KEY)
    puts 'am_products1: ', am_products
    am_products.map { |prod| MerciDanke::SearchRecord::For.entity(prod).create(prod) }
    puts 'am_products2: ', am_products
    # project = CodePraise::Representer::Project
    #   .new(OpenStruct.new).from_json(request)
    # CodePraise::GitRepo.new(project).clone!
  rescue StandardError
    puts 'AMAZON is busy. Please try again!'
  end
end
