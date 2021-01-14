# frozen_string_literal: true

require 'dry/transaction'

module MerciDanke
  module Service
    # Transaction to store product from Amazon API to database
    class Advance
      include Dry::Transaction

      step :find_pokemon
      step :create_popularity

      private

      DB_ERR_MSG = 'Having trouble accessing the database'

      def find_pokemon(input)
        advance_hash = select_hash(input)
        pokemon = find_advance_pokemon(advance_hash)
        Success(pokemon)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def create_popularity(all_pokemon)
        popularity_list = []
        all_pokemon.each do |basic_pokemon|
          products = products_in_database(basic_pokemon[:poke_name])
          popularity = Mapper::Popularities.new(basic_pokemon, products).build_entity
          popularity_list.push(popularity)
        end
        Response::BasicPokemonList.new(all_pokemon, popularity_list)
          .then do |pokemon_popu|
            Success(Response::ApiResult.new(status: :ok, message: pokemon_popu))
          end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Support methods for steps

      def find_advance_pokemon(advance_hash)
        SearchRecord::ForPoke.klass(Entity::Pokemon)
          .find_all_advances(advance_hash)
      end

      def select_hash(input)
        requested = input[:requested]
        rhigh_h = requested.high_h
        rlow_h = requested.low_h
        rhigh_w = requested.high_w
        rlow_w = requested.low_w

        low_w = rlow_w.nil? ? 0.0 : rlow_w.to_f * 10
        high_w = rhigh_w.nil? ? 0.0 : rhigh_w.to_f * 10
        low_h = rlow_h.nil? ? 0.0 : rlow_h.to_f * 10
        high_h = rhigh_h.nil? ? 0.0 : rhigh_h.to_f * 10

        hash = {
          'color': requested.color,
          'type_name': requested.type,
          'habitat': requested.habitat,
          'weight': (low_w..high_w),
          'height': (low_h..high_h)
        }
        new_hash = hash.reject { |_key, value| value == (0.0..0.0) }
        new_hash.reject { |_key, value| value == '' }
      end

      def products_in_database(input)
        SearchRecord::For.klass(Entity::Product)
          .find_full_name(input)
      end
    end
  end
end
