# frozen_string_literal: false

require 'http'
require 'google_search_results'

module MerciDanke
  module GoogleShopping
    # Library for Amazon Web API
    class Api
      def product_data(poke_name, apikey)
        Request.new.product(poke_name, apikey)
      end

      # Sends out HTTP requests to Amazon
      class Request
        def product(poke_name, apikey)
          search = GoogleSearch.new(q: poke_name, tbm: 'shop', gl: 'us', hl: 'en', tbs: 'tbs=p_ord:rv', num: 25, serp_api_key: apikey)
          search.get_hash[:shopping_results]
        end
      end
    end
  end
end
