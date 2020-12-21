# frozen_string_literal: true

require 'dry/transaction'

module MerciDanke
  module Service
    # Transaction to store product from Amazon API to database
    class BasicPokemonPopularity
      include Dry::Transaction

      step :find_all_pokemon
      step :create_popularity

      private

      DB_ERR_MSG = 'Having trouble accessing the database'

      def find_all_pokemon
        # all_pokemon
        #   .then { |pokemon_list| Response::BasicPokemonList.new(pokemon_list)}
        #   .then { |list| Success(Response::ApiResult.new(status: :ok, message: list))}
        Success(all_pokemon)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def create_popularity(all_pokemon)
        # poke_popu = []
        popularity_list = []
        all_pokemon.each do |basic_pokemon|
          products = products_in_database(basic_pokemon[:poke_name])
          popularity = Mapper::Popularities.new(basic_pokemon, products).build_entity
          # poke_popu_hash = {basic_pokemon: basic_pokemon, popularity: popularity}
          # poke_popu.push(poke_popu_hash)
          # poke_popu.push([basic_pokemon, popularity])
          popularity_list.push(popularity)
        end
        Response::BasicPokemonList.new(all_pokemon, popularity_list)
          .then do |pokemon_popu|
            Success(Response::ApiResult.new(status: :ok, message: pokemon_popu))
          end
        # poke_popu
        #   .then { |pokemon_list| Response::BasicPokemonList.new(pokemon_list)}
        #   .then { |list| Success(Response::ApiResult.new(status: :ok, message: list))}
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Support methods for steps

      def all_pokemon
        SearchRecord::ForPoke.klass(Entity::Pokemon).find_all
      end

      def products_in_database(input)
        SearchRecord::For.klass(Entity::Product)
          .find_full_name(input)
      end
    end
  end
end
