# frozen_string_literal: false

module MerciDanke
  module Entity
    # Represents about pokemons' type
    class Type < Dry::Struct
      include Dry.Types

      property :type_name
    end
  end
end
