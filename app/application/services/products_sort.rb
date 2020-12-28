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
        case input.sort
        when 'id'
          SearchRecord::For.klass(Entity::Product)
            .find_full_name(input.poke_name)
        when 'likes_DESC'
          SearchRecord::For.klass(Entity::Product)
            .order_by_desc_likes(input.poke_name)
        when 'likes_ASC'
          SearchRecord::For.klass(Entity::Product)
            .order_by_asc_likes(input.poke_name)
        when 'rating_DESC'
          SearchRecord::For.klass(Entity::Product)
            .order_by_desc_rating(input.poke_name)
        when 'rating_ASC'
          SearchRecord::For.klass(Entity::Product)
            .order_by_asc_rating(input.poke_name)
        when 'price_DESC'
          SearchRecord::For.klass(Entity::Product)
            .order_by_desc_price(input.poke_name)
        else
          # priceASC
          SearchRecord::For.klass(Entity::Product)
            .order_by_asc_price(input.poke_name)
        end
      end
    end
  end
end
