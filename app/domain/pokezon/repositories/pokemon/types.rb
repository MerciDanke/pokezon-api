# frozen_string_literal: true

module MerciDanke
  module SearchRecord
    # SearchRecord for Types
    class Types
      def self.find_id(id)
        rebuild_entity Database::TypeOrm.first(id: id)
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_types|
          Types.rebuild_entity(db_types)
        end
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Type.new(
          id: db_record.id,
          type_name: db_record.type_name
        )
      end

      def self.db_find_or_create(entity)
        Database::TypeOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end
