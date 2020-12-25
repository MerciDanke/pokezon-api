# frozen_string_literal: true

require 'dry/transaction'

module MerciDanke
  module Service
    # Transaction to store product from Amazon API to database
    class ShowProducts
      include Dry::Transaction

      step :find_pokemon
      step :request_searching_worker
      step :show_products

      private

      POKE_ERR_MSG = 'Could not find that pokemon!'
      PROCESSING_MSG = 'Processing the summary request'
      DB_ERR = 'Having trouble accessing the database'

      def find_pokemon(input)
        pokemon = correct_pokemon_name(input[:requested].poke_name)
        if pokemon
          Success(pokemon)
        else
          Failure(Response::ApiResult.new(status: :not_found, message: POKE_ERR_MSG))
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: POKE_ERR_MSG))
      end

      def request_searching_worker(input)
        db_products = products_in_database(input[:poke_name])
        return Success(db_products) unless db_products.length.zero?

        Messaging::Queue
          .new(App.config.CLONE_QUEUE_URL, App.config)
          .send(input[:poke_name].to_json)

        Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      def show_products(input)
        Response::ProductsList.new(input).then { |product| Success(Response::ApiResult.new(status: :ok, message: product)) }
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      # Support methods for steps

      def correct_pokemon_name(input)
        SearchRecord::ForPoke.klass(Entity::Pokemon).find_full_name(input)
      end

      def products_in_database(input)
        SearchRecord::For.klass(Entity::Product)
          .find_full_name(input)
      end
    end
  end
end
