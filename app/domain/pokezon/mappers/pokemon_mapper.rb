# frozen_string_literal: false

require_relative 'ability_mapper'
require_relative 'evochain_mapper'
module MerciDanke
  module Pokemon
    # Data Mapper: Pokemon intro -> Pokemon entity
    class PokemonMapper
      def initialize(gateway_class = Pokemon::Api)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
      end

      def find(poke_name)
        # data = all data
        poke_data = @gateway.poke_data(poke_name)
        pokeform_data = @gateway.pokeform_data(poke_name)
        species_data = @gateway.species_data(poke_name)
        build_entity(poke_data, pokeform_data, species_data)
      end

      def build_entity(poke_data, pokeform_data, species_data)
        DataMapper.new(poke_data, pokeform_data, species_data, @gateway_class).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(poke_data, pokeform_data, species_data, gateway_class)
          @poke_data = poke_data
          @pokeform_data = pokeform_data
          @species_data = species_data
          @type_mapper = TypeMapper.new(gateway_class)
          @ability_mapper = AbilityMapper.new(gateway_class)
          @evochain_mapper = EvochainMapper.new(gateway_class)
        end

        def build_entity
          MerciDanke::Entity::Pokemon.new(
            id: nil,
            origin_id: origin_id,
            poke_name: poke_name,
            types: types,
            abilities: abilities,
            height: height,
            weight: weight,
            back_default: back_default,
            back_shiny: back_shiny,
            front_default: front_default,
            front_shiny: front_shiny,
            habitat: habitat,
            color: color,
            flavor_text_entries: flavor_text_entries,
            genera: genera,
            evochain: evochain,
            poke_likes: 0
          )
        end

        def origin_id
          @poke_data['id']
        end

        def poke_name
          @poke_data['name']
        end

        def types
          @poke_data['types'].map do |element|
            @type_mapper.build_entity(element['type']['name'])
          end
        end

        def height
          @poke_data['height']
        end

        def weight
          @poke_data['weight']
        end

        def back_default
          @pokeform_data['sprites']['back_default'] ||= nil
        end

        def front_default
          @pokeform_data['sprites']['front_default'] ||= nil
        end

        def back_shiny
          @pokeform_data['sprites']['back_shiny'] ||= nil
        end

        def front_shiny
          @pokeform_data['sprites']['front_shiny'] ||= nil
        end

        def habitat
          habitat = @species_data['habitat']
          habitat ? habitat['name'] : nil
        end

        def color
          @species_data['color']['name']
        end

        def flavor_text_entries
          @species_data['flavor_text_entries'][0]['flavor_text']
        end

        def genera
          @species_data['genera'][7]['genus']
        end

        def abilities
          @poke_data['abilities'].map do |element|
            @ability_mapper.find_by_url(element['ability']['url'])
          end
        end

        def evochain
          @evochain_mapper.find_by_url(@species_data['evolution_chain']['url'])
        end
      end
    end
  end
end
