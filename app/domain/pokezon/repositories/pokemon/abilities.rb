# frozen_string_literal: true

module MerciDanke
  module SearchRecord
    # SearchRecord for Abilities
    class Abilities
      def self.find_id(id)
        rebuild_entity Database::AbilityOrm.first(id: id)
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_abilities|
          Abilities.rebuild_entity(db_abilities)
        end
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        db_record_ability_pokemons_array = JSON.parse(db_record.ability_pokemons)
        Entity::Ability.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          ability_name: db_record.ability_name,
          flavor_text_entries: db_record.flavor_text_entries,
          ability_pokemons: db_record_ability_pokemons_array
        )
      end

      def self.db_find_or_create(entity)
        entity_hash = entity.to_attr_hash
        entity_hash[:ability_pokemons] = entity_hash[:ability_pokemons].to_s
        Database::AbilityOrm.find_or_create(entity_hash)
      end
    end
  end
end
