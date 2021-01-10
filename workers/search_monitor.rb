# frozen_string_literal: true

module SearchProducts
  # Infrastructure to search amazon products while yielding progress
  module SearchMonitor
    SEARCH_PROGRESS = {
      'searching'=> 30,
      'creating' => 70,
      'FINISHED' => 100
    }.freeze

    def self.searching_percent
      SEARCH_PROGRESS['searching'].to_s
    end

    def self.creating_percent
      SEARCH_PROGRESS['creating'].to_s
    end

    def self.finished_percent
      SEARCH_PROGRESS['FINISHED'].to_s
    end
  end
end
