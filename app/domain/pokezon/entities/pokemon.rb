# frozen_string_literal: false

require_relative 'ability'
require_relative 'evochain'
require_relative 'type'

module MerciDanke
  module Entity
    # Domain entity for pokemons
    class Pokemon < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :origin_id, Strict::Integer
      attribute :poke_name, Strict::String
      attribute :types, Strict::Array.of(Type)
      attribute :height, Strict::Integer
      attribute :weight, Strict::Integer
      attribute :back_default, String.optional
      attribute :back_shiny, String.optional
      attribute :front_default, String.optional
      attribute :front_shiny, String.optional
      attribute :habitat, String.optional
      attribute :color, String.optional
      attribute :flavor_text_entries, String.optional
      attribute :genera, String.optional
      # Evochain
      attribute :evochain, Evochain
      # Ability
      attribute :abilities, Strict::Array.of(Ability)
      attribute :poke_likes, Integer.optional

      def to_attr_hash
        to_hash.reject { |key, _value| %i[id evochain abilities types].include? key }
      end
    end
  end
end
