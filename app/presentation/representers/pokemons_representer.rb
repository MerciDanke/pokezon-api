# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'pokemon_representer'

module MerciDanke
  module Representer
    # Represents list of pokemons for API output
    class PokemonsList < Roar::Decorator
      include Roar::JSON

      collection :pokemons, extend: Representer::Pokemon,
                            class: Representer::OpenStructWithLinks
    end
  end
end
