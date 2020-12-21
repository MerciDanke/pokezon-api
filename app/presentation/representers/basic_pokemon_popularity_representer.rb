# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'basic_pokemon_representer'
require_relative 'popularity_representer'

module MerciDanke
  module Representer
    # Represents pokemon intro and it's popularity level
    class BasicPokemonPopularity < Roar::Decorator
      include Roar::JSON

      property :basic_pokemon, extend: Representer::BasicPokemon, class: OpenStruct
      property :popularity, extend: Representer::Popularity, class: OpenStruct
    end
  end
end
