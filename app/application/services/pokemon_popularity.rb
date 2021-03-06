# frozen_string_literal: true

require 'dry/transaction'

module MerciDanke
  module Service
    # Transaction to store product from Amazon API to database
    class PokemonPopularity
      include Dry::Transaction

      step :find_pokemon
      step :find_products

      private

      POKE_ERR_MSG = 'Could not find that pokemon!'
      DB_ERR_MSG = 'Having trouble accessing the database'

      def find_pokemon(input)
        pokemon = correct_pokemon_name(input[:requested].poke_name)
        fail_msg = Failure(Response::ApiResult.new(status: :not_found, message: POKE_ERR_MSG))

        if pokemon
          Success(pokemon)
        else
          fail_msg
        end
      rescue StandardError
        fail_msg
      end

      def find_products(pokemon)
        products = products_in_database(pokemon[:poke_name])
        popularity = Mapper::Popularities.new(pokemon, products).build_entity
        poke_popu = [pokemon, popularity]
        Response::PokemonPopularity.new(poke_popu[0], poke_popu[1])
          .then do |pokemon_popu|
            Success(Response::ApiResult.new(status: :ok, message: pokemon_popu))
          end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
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
