# frozen_string_literal: false

module MerciDanke
  module Entity
    # Domain entity for pokemons' abilities
    class Type < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :type_name, Strict::String

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
