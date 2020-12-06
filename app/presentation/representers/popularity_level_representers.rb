# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module MerciDanke
  module Entity
    # 4 popularity level
    class PopularityLevel
      include Calculate::PopularityCalculator
      def initialize(pokemon_entity, products_entities)
        @pokemon = pokemon_entity
        @products = products_entities
      end

      # not sure this could call the PopularityCalculator method
      def average_rating
        cal_average_rating(@products)
      end

      def products_num
        cal_products_num(@products)
      end

      def poke_likes_num
        cal_poke_likes_num(@pokemon)
      end

      def products_likes_num
        cal_products_likes_num(@products)
      end

      # mapper should call popularity_level_hash
      def popularity_level_hash
        Value::PopularityLevels.new(
          @pokemon.origin_id,
          average_rating,
          products_num,
          poke_likes_num,
          products_likes_num
        ).popularity_level_hash
      end

      # mapper should call popularity_build_entity
      def popularity_build_entity(popularity_level_hash)
        Entity::Popularity.new(
          id: nil,
          poke_id: popularity_level_hash[:poke_id],
          popularity_level: popularity_level_hash[:popularity_level]
        )
      end
    end
  end
end
