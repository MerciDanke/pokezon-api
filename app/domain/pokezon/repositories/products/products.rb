# frozen_string_literal: true

module MerciDanke
  module SearchRecord
    # Repository for Project Entities
    class Products
      def self.all
        Database::ProductOrm.all.map { |db_product| rebuild_entity(db_product) }
      end

      def self.find_full_name(poke_name)
        # SELECT * FROM `projects` LEFT JOIN `members`
        # ON (`members`.`id` = `projects`.`owner_id`)
        # WHERE ((`username` = 'owner_name') AND (`name` = 'project_name'))
        db_products = Database::ProductOrm
          .where(poke_name: poke_name)
          .all
        db_products.map do |db_product|
          rebuild_entity(db_product)
        end
      end

      def self.find_full_names(poke_names)
        poke_names.map do |pokename|
          find_full_name(pokename)
        end.compact
      end

      def self.order_by_desc_likes(poke_name)
        db_products = Database::ProductOrm
          .where(poke_name: poke_name)
          .order { product_likes.desc }.all
        db_products.map do |db_product|
          rebuild_entity(db_product)
        end
      end

      def self.order_by_asc_likes(poke_name)
        db_products = Database::ProductOrm
          .where(poke_name: poke_name)
          .order { product_likes.asc }.all
        db_products.map do |db_product|
          rebuild_entity(db_product)
        end
      end

      def self.order_by_desc_rating(poke_name)
        db_products = Database::ProductOrm
          .where(poke_name: poke_name)
          .order { rating.desc }.all
        db_products.map do |db_product|
          rebuild_entity(db_product)
        end
      end

      def self.order_by_asc_rating(poke_name)
        db_products = Database::ProductOrm
          .where(poke_name: poke_name)
          .order { rating.asc }.all
        db_products.map do |db_product|
          rebuild_entity(db_product)
        end
      end

      def self.order_by_desc_price(poke_name)
        db_products = Database::ProductOrm
          .where(poke_name: poke_name)
          .order { price.desc }.all
        db_products.map do |db_product|
          rebuild_entity(db_product)
        end
      end

      def self.order_by_asc_price(poke_name)
        db_products = Database::ProductOrm
          .where(poke_name: poke_name)
          .order { price.asc }.all
        db_products.map do |db_product|
          rebuild_entity(db_product)
        end
      end

      # update the num of product_likes
      def self.plus_like(origin_id)
        product_like_num = Database::ProductOrm.where(origin_id: origin_id).first.product_likes
        Database::ProductOrm.where(origin_id: origin_id).first.update(product_likes: product_like_num + 1)
      end

      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_id(id)
        db_record = Database::ProductOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::ProductOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        # raise 'Product already exists' if find(entity)

        db_product = PersistProduct.new(entity).create_product unless find(entity)
        rebuild_entity(db_product)
      end

      private

      def self.rebuild_entity(db_record)
        return nil unless db_record

        MerciDanke::Entity::Product.new(
          db_record.to_hash
        )
      end

      # Helper class to persist project to database
      class PersistProduct
        def initialize(entity)
          @entity = entity
        end

        def create_product
          Database::ProductOrm.create(@entity.to_attr_hash)
        end
      end
    end
  end
end
