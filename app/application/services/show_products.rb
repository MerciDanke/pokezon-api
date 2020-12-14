# frozen_string_literal: true

require 'dry/transaction'

module MerciDanke
  module Service
    # Transaction to store product from Amazon API to database
    class ShowProducts
      include Dry::Transaction

      step :find_pokemon
      step :find_store_products

      private

      POKE_ERR_MSG = 'Could not find that pokemon!'
      AM_ERR_MSG = 'Amazon products have some unknown problems. Please try again!'

      def find_pokemon(input)
        pokemon = correct_pokemon_name(input[:requested].poke_name)
        Success(pokemon)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: POKE_ERR_MSG))
      end

      def find_store_products(input)
        db_products = products_in_database(input[:poke_name])

        products =
          if db_products.length.zero?
            puts 'go to amazon'
            am_products = products_in_amazon(input[:poke_name])
            am_products.map { |prod| SearchRecord::For.entity(prod).create(prod) }
          else
            db_products
          end

        Response::ProductsList.new(products).then { |product| Success(Response::ApiResult.new(status: :ok, message: product)) }
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: AM_ERR_MSG))
      end

      # Support methods for steps

      def products_in_amazon(input)
        Amazon::ProductMapper.new.find(input, MerciDanke::App.config.API_KEY)
      end

      def correct_pokemon_name(input)
        Pokemon::PokemonMapper.new.find(input)
      end

      public

      def products_in_database(input)
        SearchRecord::For.klass(Entity::Product)
          .find_full_name(input)
      end
    end
  end
end
