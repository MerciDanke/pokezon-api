# frozen_string_literal: true

module SearchProducts
  # Infrastructure to search amazon products while yielding progress
  module SearchMonitor
    SEARCH_PROGRESS = {
      'STARTED'  => 15,
      '5'        => 30,
      '15'       => 50,
      '30'       => 70,
      '40'       => 90,
      'FINISHED' => 100
    }.freeze

    def self.starting_percent
      SEARCH_PROGRESS['STARTED'].to_s
    end

    def self.finished_percent
      SEARCH_PROGRESS['FINISHED'].to_s
    end

    # line???
    def self.progress(product)
      SEARCH_PROGRESS[product.position.to_s].to_s
    end

    def self.percent(stage)
      SEARCH_PROGRESS[stage].to_s
    end
  end
end
