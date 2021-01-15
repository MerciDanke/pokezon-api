# frozen_string_literal: false

module MerciDanke
  module Amazon
    # Data Mapper: Amazon product -> Product entity
    class ProductMapper
      def initialize(gateway_class = Amazon::Api)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
      end

      def find(poke_name, apikey)
        # data = all data
        data = @gateway.product_data(poke_name, apikey)
        build_entity(data['results'], data['requestDetails']['marketplaceUrl'])
      end

      def build_entity(products, marketplaceurl)
        # rubocop:disable Style/NonNilCheck, Style/GuardClause
        if products != nil
          products.map do |product|
            DataMapper.new(product, marketplaceurl).build_entity
          end
        end
        # rubocop:enable Style/NonNilCheck, Style/GuardClause
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(product_detail, marketplaceurl)
          @data = product_detail
          @url_data = marketplaceurl
        end

        def build_entity
          MerciDanke::Entity::Product.new(
            id: nil,
            origin_id: origin_id,
            poke_name: poke_name,
            title: title,
            link: link,
            image: image,
            rating: rating,
            ratings_total: ratings_total,
            price: price,
            product_likes: 0
          )
        end

        def poke_name
          @url_data.split('=')[1]
        end

        def origin_id
          @data['asin']
        end

        def title
          @data['title']
        end

        def link
          @data['link']
        end

        def image
          @data['image']
        end

        def ratings_total
          @data['ratingsTotal']
        end

        def rating
          @data['rating']
        end

        def price
          if @data.length < 11
            nil
          else
            @data['prices'][0]['price']
          end
        end
      end
    end
  end
end
