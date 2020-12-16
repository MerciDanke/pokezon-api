# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'pokemon_representer'
require_relative 'popularity_representer'

module MerciDanke
  module Representer
    # Represents pokemon intro and it's popularity level
    class PokemonPopularity < Roar::Decorator
      include Roar::JSON

      property :pokemon, extend: Representer::Pokemon, class: OpenStruct
      property :popularity, extend: Representer::Popularity, class: OpenStruct
    end
  end
end
