# frozen_string_literal: true

module MerciDanke
  module Request
    # Application value for the path of a requested product
    class ProductPath
      def initialize(poke_name, request)
        @poke_name = poke_name
        @request = request
        @path = request.remaining_path
      end

      attr_reader :poke_name

      def product_fullname
        @request.captures.join '/'
      end
    end
  end
end
