# frozen_string_literal: true

require 'aws-sdk-sqs'

module MerciDanke
  module Messaging
    ## Queue wrapper for AWS SQS
    # Requires: AWS credentials loaded in ENV or through config file
    class Queue
      IDLE_TIMEOUT = 5 # seconds

      def initialize(queue_url, config)
        @queue_url = queue_url
        sqs = Aws::SQS::Client.new(
          access_key_id: config.AWS_ACCESS_KEY_ID,
          secret_access_key: config.AWS_SECRET_ACCESS_KEY,
          region: config.AWS_REGION
        )
        @queue = Aws::SQS::Queue.new(url: queue_url, client: sqs)
      end

      ## Sends message to queue
      # Usage:
      #   q = Messaging::Queue.new(App.config.SEARCH_QUEUE_URL)
      #   q.send({data: "hello"}.to_json)
      def send(message)
        @queue.send_message({ message_group_id: 'search_request',
                              message_body: "#{message[:poke_name]},#{message[:request_id]}",
                              message_attributes: {
                                'poke_name' => {
                                  string_value: message[:poke_name],
                                  data_type: 'String' # required
                                },
                                'request_id' =>{
                                  string_value: message[:request_id].to_s,
                                  data_type: 'String' # required
                                }
                              },
                              message_deduplication_id: Random.rand(20000).to_s})
      end

      ## Polls queue, yielding each messge
      # Usage:
      #   q = Messaging::Queue.new(App.config.SEARCH_QUEUE_URL)
      #   q.poll { |msg| print msg.body.to_s }
      def poll
        poller = Aws::SQS::QueuePoller.new(@queue_url)
        poller.poll(idle_timeout: IDLE_TIMEOUT) do |msg|
          yield msg.body if block_given?
        end
      end
    end
  end
end
