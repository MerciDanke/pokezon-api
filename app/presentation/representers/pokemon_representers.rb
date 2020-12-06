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
      attribute :back_default, Strict::String
      attribute :back_shiny, Strict::String
      attribute :front_default, Strict::String
      attribute :front_shiny, Strict::String
      attribute :habitat, Strict::String
      attribute :color, Strict::String
      attribute :flavor_text_entries, Strict::String
      attribute :genera, Strict::String
      # Evochain
      attribute :evochain, Evochain
      # Ability
      attribute :abilities, Strict::Array.of(Ability)

      def to_attr_hash
        to_hash.reject { |key, _| %i[id evochain abilities types].include? key }
      end
    end
  end
end
