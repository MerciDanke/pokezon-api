# frozen_string_literal: true

module MerciDanke
  module Request
    # Application value for the path of a requested pokemon
    class AdvancePath
      def initialize(params)
        @color = params['color']
        @type = params['type']
        @habitat = params['habitat']
        @low_w = params['low_w']
        @high_w = params['high_w']
        @low_h = params['low_h']
        @high_h = params['high_h']
      end

      attr_reader :color, :type, :habitat, :low_w, :high_w, :low_h, :high_h
    end
  end
end
