# frozen_string_literal: true

require 'sequel'

module MerciDanke
  module Database
    # Object Relational Mapper for Type Entities
    class TypeOrm < Sequel::Model(:types)
      many_to_many :types_pokemons,
                   class: :'MerciDanke::Database::PokemonOrm',
                   join_table: :pokemons_types,
                   left_key: :type_id, right_key: :poke_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(type_info)
        first(type_name: type_info[:type_name]) || create(type_info)
      end
    end
  end
end
