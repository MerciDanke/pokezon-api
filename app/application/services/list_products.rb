# frozen_string_literal: true

require 'dry/monads/all'

module MerciDanke
  module Service
    # Retrieves array of all listed product entities
    class ListProducts
      include Dry::Monads::Result::Mixin

      # private

      DB_ERR = 'list_products:Could not access database'

      def call(poke_name)
        products = SearchRecord::For.klass(Entity::Product).find_full_name(poke_name)
        Response::ProductsList.new(products).then { |product| Success(Response::ApiResult.new(status: :ok, message: product)) }
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end
    end
  end
end
