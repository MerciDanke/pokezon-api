# frozen_string_literal: true

module MerciDanke
  module SearchRecord
    # SearchRecord for Evochains
    class Evochains
      def self.find_id(id)
        rebuild_entity Database::EvochainOrm.first(id: id)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        # error:db_record.evochain is nil
        MerciDanke::Entity::Evochain.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          chain_species_name: db_record.chain_species_name,
          evolves_to: db_record.evolves_to,
          evolves_to_second: db_record.evolves_to_second
        )
      end

      def self.db_find_or_create(entity)
        Database::EvochainOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end
