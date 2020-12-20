# # frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
# require_relative 'basic_pokemon_popularity_representer'
require_relative 'basic_pokemon_representer'
require_relative 'popularity_representer'

module MerciDanke
  module Representer
    # Represents list of pokemons for API output
    class BasicPokemonList < Roar::Decorator
      include Roar::JSON

      # collection :pokemon_list, extend: Representer::BasicPokemonPopularity,
      #                           class: Representer::OpenStructWithLinks

      collection :pokemon_list, extend: Representer::BasicPokemon,
                                class: Representer::OpenStructWithLinks
      collection :popularity_list, extend: Representer::Popularity, class: OpenStruct
    end
  end
end
