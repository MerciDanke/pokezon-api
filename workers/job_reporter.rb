# frozen_string_literal: true

require_relative 'progress_publisher'

module SearchProducts
  # Reports job progress to client
  class JobReporter
    attr_accessor :poke_name

    def initialize(request_json, config)
      # search_request = MerciDanke::Representer::SearchRequest
      #   .new(OpenStruct.new)
      #   .from_json(request_json)

      @poke_name = request_json.split(',')[0]
      @publisher = ProgressPublisher.new(config, request_json.split(',')[1])
    end

    def report(msg)
      @publisher.publish msg
    end

    def report_each_second(seconds, &operation)
      seconds.times do
        sleep(1)
        report(operation.call)
      end
    end
  end
end
