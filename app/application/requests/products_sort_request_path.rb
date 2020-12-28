# frozen_string_literal: true

module MerciDanke
  module Request
    # Application value for the path of a requested pokemon
    class ProductsSortPath
      def initialize(poke_name, params)
        @poke_name = poke_name
        @sort = params['sort']
      end

      attr_reader :sort, :poke_name
    end
  end
end
