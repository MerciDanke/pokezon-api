# frozen_string_literal: false

module MerciDanke
  module Entity
    # Domain entity for pokemons' evolution chain
    class Evochain < Dry::Struct
      include Dry.Types
      attribute :id, Integer.optional
      attribute :origin_id, Strict::Integer
      attribute :chain_species_name, Strict::String
      attribute :evolves_to, String.optional
      attribute :evolves_to_second, String.optional

      def to_attr_hash
        to_hash.reject { |key, _value| [:id].include? key }
      end
    end
  end
end
