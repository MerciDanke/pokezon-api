# frozen_string_literal: false

module MerciDanke
  module Pokemon
    # Data Mapper: evolution chain intro -> evolution chain entity
    class EvochainMapper
      def initialize(gateway_class = Pokemon::Api)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
      end

      def find_by_url(evo_url)
        # data = all data
        evo_data = @gateway.evo_data(evo_url)
        EvochainMapper.build_entity(evo_data)
      end

      def self.build_entity(evo_data)
        DataMapper.new(evo_data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(evo_data)
          @evo_data = evo_data
        end

        def build_entity
          MerciDanke::Entity::Evochain.new(
            id: nil,
            origin_id: origin_id,
            chain_species_name: chain_species_name,
            evolves_to: evolves_to,
            evolves_to_second: evolves_to_second
          )
        end

        def origin_id
          @evo_data['id']
        end

        def chain_species_name
          @evo_data['chain']['species']['name']
        end

        def evolves_to
          evo_to = @evo_data['chain']['evolves_to'][0]
          evo_to['species']['name'] if evo_to
        end

        def evolves_to_second
          evo_to = @evo_data['chain']['evolves_to'][0]
          # rubocop:disable Style/EmptyElse
          if evo_to
            ev_second = evo_to['evolves_to'][0]
            return ev_second['species']['name'] if ev_second
          else
            nil
          end
          # rubocop:enable Style/EmptyElse
        end
      end
    end
  end
end
