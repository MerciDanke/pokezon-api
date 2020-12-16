# frozen_string_literal: true

module MerciDanke
  module Request
    # Application value for the path of a requested pokemon
    class PokemonPath
      def initialize(poke_id, request)
        @poke_id = poke_id
        @request = request
      end

      attr_reader :poke_id
    end
  end
end
