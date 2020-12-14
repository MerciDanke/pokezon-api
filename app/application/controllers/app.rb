# frozen_string_literal: true

require 'roda'
require_relative 'helpers'

module MerciDanke
  # Web App
  class App < Roda
    include RouteHelpers

    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST
    plugin :halt
    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "MerciDanke API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      # routing.on 'plus_like' do
      #   routing.is do
      #     routing.get do
      #       poke_id = routing.params['poke_id']
      #       if poke_id.nil?
      #         product_id = routing.params['product_id']
      #         SearchRecord::For.klass(Entity::Product).plus_like(product_id)
      #       else
      #         SearchRecord::ForPoke.klass(Entity::Pokemon).plus_like(poke_id)
      #       end

      #       advance_hash = {
      #         :'color' => '',
      #         :'type_name' => '',
      #         :'habitat' => '',
      #         :'weight' => '',
      #         :'height' => ''
      #       }
      #       pokemon_all = SearchRecord::ForPoke.klass(Entity::Pokemon).all
      #       popularities = Popularities.new(pokemon_all).call

      #       viewable_pokemons = Views::PokemonsList.new(pokemon_all, advance_hash, popularities)
      #       view 'home', locals: { pokemons: viewable_pokemons }
      #     end
      #   end
      # end

      routing.on 'api/v1' do
        routing.on 'products' do
          routing.on String do |poke_name|
            # GET /products/{poke_name}
            routing.get do
              path_request = Request::ProductPath.new(poke_name, request)
              result = Service::ShowProducts.new.call(requested: path_request)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::ProductsList.new(result.value!.message).to_json
            end
          end
        end

        routing.on 'pokemons' do
          routing.on String do |poke_name|
            # GET /pokemon/{poke_name}
            routing.get do
              path_request = Request::PokemonPath.new(poke_name, request)

              result = Service::PokemonPopularity.new.call(requested: path_request)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::PokemonPopularity.new(
                result.value!.message
              ).to_json
            end
          end
        end
      end
    end
  end
end
