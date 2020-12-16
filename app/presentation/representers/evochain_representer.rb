# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MerciDanke
  module Representer
    # Represents about pokemons' evolution chain
    class Evochain < Roar::Decorator
      include Roar::JSON

      property :origin_id
      property :chain_species_name
      property :evolves_to
      property :evolves_to_second
    end
  end
end
