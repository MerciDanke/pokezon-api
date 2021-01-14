# frozen_string_literal: false

module MerciDanke
  module Pokemon
    # Data Mapper: Pokemon intro -> Pokemon entity
    class TypeMapper
      def initialize(gateway_class = Pokemon::Api)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
      end

      def build_entity(poke_data)
        DataMapper.new(poke_data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(poke_data)
          @poke_data = poke_data
        end

        def build_entity
          MerciDanke::Entity::Type.new(
            id: nil,
            type_name: type_name
          )
        end

        def type_name
          @poke_data
        end
      end
    end
  end
end
