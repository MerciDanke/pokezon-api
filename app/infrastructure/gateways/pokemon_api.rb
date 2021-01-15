# frozen_string_literal: false

require 'http'

module MerciDanke
  module Pokemon
    # Library for Pokemon API
    class Api
      def poke_data(poke_name)
        Request.new.pokemon(poke_name).parse
      end

      def pokeform_data(poke_name)
        Request.new.pokemon_form(poke_name).parse
      end

      def species_data(poke_name)
        Request.new.species(poke_name).parse
      end

      def ability_data(ability_url)
        Request.new.get(ability_url).parse
      end

      def evo_data(evo_url)
        Request.new.get(evo_url).parse
      end

      # Sends out HTTP requests to pokemon
      class Request
        POKE_PATH = 'https://pokeapi.co/api/v2/pokemon/'.freeze
        FORM_PATH = 'https://pokeapi.co/api/v2/pokemon-form/'.freeze
        SPECIES_PATH = 'https://pokeapi.co/api/v2/pokemon-species/'.freeze

        def pokemon(poke_name)
          get(POKE_PATH + poke_name)
        end

        def pokemon_form(poke_name)
          get(FORM_PATH + poke_name)
        end

        def species(poke_name)
          get(SPECIES_PATH + poke_name)
        end

        def get(url)
          http_response = HTTP.get(url)
          Response.new(http_response).tap do |response|
            raise(response.error) unless response.successful?
          end
        end
      end

      # Decorates HTTP responses from Pokemon with success/error
      class Response < SimpleDelegator
        # Response Unauthorized
        # Unauthorized = Class.new(StandardError)
        # Response NotFound
        NotFound = Class.new(StandardError)

        # HTTP_ERROR = {
        #   401 => Unauthorized,
        #   404 => NotFound
        # }.freeze
        HTTP_ERROR = {
          404 => NotFound
        }.freeze

        def successful?
          HTTP_ERROR.keys.include?(code) ? false : true
        end

        def error
          HTTP_ERROR[code]
        end
      end
    end
  end
end
