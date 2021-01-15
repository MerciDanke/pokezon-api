# frozen_string_literal: false

module MerciDanke
  module GoogleShopping
    # Data Mapper: Amazon product -> Product entity
    class ProductMapper
      def initialize(gateway_class = GoogleShopping::Api)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
      end

      def find(poke_name, apikey)
        # data = all data
        data = @gateway.product_data(poke_name, apikey)
        build_entity(data, poke_name)
      end

      def build_entity(products, poke_name)
        # rubocop:disable Style/NonNilCheck, Style/GuardClause
        if products != nil
          products.map do |product|
            DataMapper.new(product, poke_name).build_entity
          end
        end
        # rubocop:enable Style/NonNilCheck, Style/GuardClause
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(product_detail, poke_name)
          @data = product_detail
          @poke_name = poke_name
        end

        def build_entity
          MerciDanke::Entity::Product.new(
            id: nil,
            origin_id: origin_id,
            poke_name: @poke_name,
            title: title,
            link: link,
            image: image,
            rating: rating,
            ratings_total: ratings_total,
            price: price,
            product_likes: 0
          )
        end

        def origin_id
          product_id = @data[:product_id]
          product_id.nil? ? 'nil' : product_id
        end

        def title
          @data[:title]
        end

        def link
          @data[:link]
        end

        def image
          @data[:thumbnail]
        end

        def ratings_total
          reviews = @data[:reviews]
          reviews.nil? ? 0 : reviews.to_i
        end

        def rating
          rating = @data[:rating]
          rating.nil? ? 0.0 : rating.to_f
        end

        def price
          @data[:price]
        end
      end
    end
  end
end
