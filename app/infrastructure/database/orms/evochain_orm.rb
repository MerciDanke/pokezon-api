# frozen_string_literal: true

require 'sequel'

module MerciDanke
  module Database
    # Object Relational Mapper for Evolutionchain Entities
    class EvochainOrm < Sequel::Model(:evochains)
      one_to_many :evochain_pokemons,
                  class: :'MerciDanke::Database::PokemonOrm',
                  key: :evochain_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(evochain_info)
        first(origin_id: evochain_info[:origin_id]) || create(evochain_info)
      end
    end
  end
end
