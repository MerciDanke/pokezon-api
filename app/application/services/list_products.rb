# frozen_string_literal: true

require 'dry/monads/all'

module MerciDanke
  module Service
    # Retrieves array of all listed product entities
    class ListProducts
      include Dry::Monads::Result::Mixin

      private

      DB_ERR = 'list_products:Could not access database'

      def call(pokenames)
        products = SearchRecord::For.klass(Entity::Product)
          .find_full_names(pokenames)

        Success(products)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end
    end
  end
end
