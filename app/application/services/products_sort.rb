# frozen_string_literal: true

require 'dry/transaction'

module MerciDanke
  module Service
    # Transaction to store product from Amazon API to database
    class ProductsSort
      include Dry::Transaction

      step :recognize_sort
      step :show_products

      private

      DB_ERR_MSG = 'Having trouble accessing the database'

      # input = id/likes desc/likes asc/rating desc/rating asc/price desc/price asc
      def recognize_sort(input)
        sort_products = condition_sort(input[:requested])

        Success(sort_products)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def show_products(input)
        Response::ProductsList.new(input).then { |product| Success(Response::ApiResult.new(status: :ok, message: product)) }
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      # Support methods for steps

      def condition_sort(input)
        poke_name = input.poke_name
        product_db = SearchRecord::For.klass(Entity::Product)
        case input.sort
        when 'id'
          product_db.find_full_name(poke_name)
        when 'likes_DESC'
          product_db.order_by_desc_likes(poke_name)
        when 'likes_ASC'
          product_db.order_by_asc_likes(poke_name)
        when 'rating_DESC'
          product_db.order_by_desc_rating(poke_name)
        when 'rating_ASC'
          product_db.order_by_asc_rating(poke_name)
        when 'price_DESC'
          product_db.order_by_desc_price(poke_name)
        else
          # priceASC
          product_db.order_by_asc_price(poke_name)
        end
      end
    end
  end
end
