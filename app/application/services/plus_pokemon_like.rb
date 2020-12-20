# frozen_string_literal: true

require 'dry/transaction'

module MerciDanke
  module Service
    # Transaction to store product from Amazon API to database
    class PokemonLike
      include Dry::Transaction

      step :plus_like

      private

      SUC_MSG = 'plus a like to pokemon successfully!'
      DB_ERR_MSG = 'Having trouble accessing the database'
      def plus_like(input)
        plus_db_like(input[:requested].target_id)
        Success(Response::ApiResult.new(status: :ok, message: SUC_MSG))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Support methods for steps

      def plus_db_like(input)
        SearchRecord::ForPoke.klass(Entity::Pokemon).plus_like(input)
      end
    end
  end
end
