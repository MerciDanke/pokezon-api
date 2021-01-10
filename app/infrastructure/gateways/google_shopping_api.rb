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

        # def get(url)
        #   http_response = HTTP.get(url)

        #   Response.new(http_response).tap do |response|
        #     raise(response.error) unless response.successful?
        #   end
        # end
      end

      # Decorates HTTP responses from Amazon with success/error
    #   class Response < SimpleDelegator
    #     # Response Unauthorized
    #     Unauthorized = Class.new(StandardError)
    #     # Response NotFound
    #     NotFound = Class.new(StandardError)

    #     HTTP_ERROR = {
    #       401 => Unauthorized,
    #       404 => NotFound
    #     }.freeze

    #     def successful?
    #       HTTP_ERROR.keys.include?(code) ? false : true
    #     end

    #     def error
    #       HTTP_ERROR[code]
    #     end
    #   end
    end
  end
end
