# frozen_string_literal: true

require 'dry/transaction'

module MerciDanke
  module Service
    # Transaction to store product from Amazon API to database
    class ShowProducts
      include Dry::Transaction

      step :find_pokemon
      step :find_products
      step :store_products

      private

      POKE_ERR_MSG = 'Could not find that pokemon!'
      AM_ERR_MSG = 'Amazon products have some unknown problems. Please try again!'
      DB_ERR_MSG = 'Having trouble accessing the database'

      def find_pokemon(input)
        pokemon = correct_pokemon_name(input[:poke_name])
        Success(pokemon)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: POKE_ERR_MSG))
      end

      def find_products(input)
        get_products = Array.new(2)
        products = products_in_database(input[:poke_name])
        if products.length.zero?
          get_products[1] = products_in_amazon(input[:poke_name])
        else
          get_products[0] = products
        end
        Success(get_products)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :not_found, message: AM_ERR_MSG))
      end

      def store_products(input)
        products =
          if (new_prods = input[1])
            new_prods.map { |prod| SearchRecord::For.entity(prod).create(prod) }
          else
            input[0]
          end
        Success(Response::ApiResult.new(status: :created, message: products))
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Support methods for steps

      def products_in_amazon(input)
        Amazon::ProductMapper.new.find(input, MerciDanke::App.config.API_KEY)
      end

      def correct_pokemon_name(input)
        Pokemon::PokemonMapper.new.find(input[:poke_name])
      end

      public

      def products_in_database(input)
        SearchRecord::For.klass(Entity::Product)
          .find_full_name(input)
      end
    end
  end
end
