# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MerciDanke
  module Representer
    # Represents about pokemons' type
    class Type < Roar::Decorator
      include Roar::JSON

      property :type_name
    end
  end
end
