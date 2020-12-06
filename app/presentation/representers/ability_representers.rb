# frozen_string_literal: false

module MerciDanke
  module Entity
    # Domain entity for pokemons' abilities
    class Ability < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :origin_id, Strict::Integer
      attribute :ability_name, Strict::String
      attribute :flavor_text_entries, Strict::String
      # attribute :ability_pokemons, Strict::String
      attribute :ability_pokemons, Strict::Array.of(String)

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
