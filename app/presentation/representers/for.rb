# frozen_string_literal: true

require_relative 'products_representer'
require_relative 'pokemon_popularity_representer'
require_relative 'basic_pokemonlist_representer'
require_relative 'http_response_representer'

module MerciDanke
  module Representer
    # Returns appropriate representer for response object
    class For
      REP_KLASS = {
        Response::ProductsList           => ProductsList,
        Response::BasicPokemonPopularity => BasicPokemonPopularity,
        Response::BasicPokemonList       => BasicPokemonList,
        Response::PokemonPopularity      => PokemonPopularity,
        String                           => HttpResponse
      }.freeze

      attr_reader :status_rep, :body_rep

      def initialize(result)
        if result.failure?
          @status_rep = Representer::HttpResponse.new(result.failure)
          @body_rep = @status_rep
        else
          value = result.value!
          message = value.message
          @status_rep = Representer::HttpResponse.new(value)
          @body_rep = REP_KLASS[message.class].new(message)
        end
      end

      def http_status_code
        @status_rep.http_status_code
      end

      def to_json(*args)
        @body_rep.to_json(*args)
      end

      def status_and_body(response)
        response.status = http_status_code
        to_json
      end
    end
  end
end
