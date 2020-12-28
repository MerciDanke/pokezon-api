# frozen_string_literal: true

require 'roda'
require_relative 'lib/init'

module MerciDanke
  # Web App
  class App < Roda
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST
    plugin :halt
    plugin :caching
    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        5.times do |num|
          break if Database::PokemonOrm.find(id: 5)

          pokemons = Pokemon::PokemonMapper.new.find((num + 1).to_s)
          SearchRecord::ForPoke.entity(pokemons).create(pokemons)
        end
        message = "MerciDanke API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'products' do
          routing.on String do |poke_name|
            # GET /products/{poke_name}
            routing.get do
              Cache::Control.new(response).turn_on if Env.new(App).production?
              result =
              if routing.params == {}
                path_request = Request::ProductPath.new(poke_name, request)
                Service::ShowProducts.new.call(requested: path_request)
              else
                # GET /products/{poke_name}?sort=id
                # GET /products/{poke_name}?sort=likes_DESC(ASC)
                # GET /products/{poke_name}?sort=rating_DESC(ASC)
                # GET /products/{poke_name}?sort=price_DESC(ASC)
                path_request = Request::ProductsSortPath.new(poke_name, routing.params)
                Service::ProductsSort.new.call(requested: path_request)
              end

              Representer::For.new(result).status_and_body(response)
            end
          end
        end
        routing.on 'product' do
          routing.on String do |origin_id|
            routing.on 'likes' do
              # PUT /product/{origin_id}/likes
              routing.put do
                path_request = Request::LikePath.new(origin_id, request)
                result = Service::ProductLike.new.call(requested: path_request)

                Representer::For.new(result).status_and_body(response)
              end
            end
          end
        end
        routing.on 'pokemon' do
          routing.on String do |id_or_name|
            routing.on 'likes' do
              # PUT /pokemon/{id}/likes
              # id_or_name = id(id we create not origin_id)
              routing.put do
                path_request = Request::LikePath.new(id_or_name, request)
                result = Service::PokemonLike.new.call(requested: path_request)

                Representer::For.new(result).status_and_body(response)
              end
            end
            # GET /pokemon/{poke_name}
            # id_or_name = poke_name
            routing.get do
              path_request = Request::PokemonPath.new(id_or_name, request)

              result = Service::PokemonPopularity.new.call(requested: path_request)
              Representer::For.new(result).status_and_body(response)
            end
          end
          # GET /pokemon
          routing.get do
            Cache::Control.new(response).turn_on if Env.new(App).production?
            result =
            if routing.params == {}
              Service::BasicPokemonPopularity.new.call
            else
              # GET /pokemon?color=xx&type_name=xx&habitat=xx&low_h=xx&high_h&low_w=xx&high_w=xx
              path_request = Request::AdvancePath.new(routing.params)
              Service::Advance.new.call(requested: path_request)
            end

            Representer::For.new(result).status_and_body(response)
          end
        end
      end
    end
  end
end
