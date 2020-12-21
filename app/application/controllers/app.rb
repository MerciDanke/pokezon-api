# frozen_string_literal: true

require 'roda'

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
              response.cache_control public: true, max_age: 3600
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
        routing.on 'product' do
          routing.on String do |origin_id|
            routing.on 'likes' do
              # PUT /product/{origin_id}/likes
              routing.put do
                path_request = Request::LikePath.new(origin_id, request)
                result = Service::ProductLike.new.call(requested: path_request)
                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end
                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                http_response.to_json
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
                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end
                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                http_response.to_json
              end
            end
            # GET /pokemon/{poke_name}
            # id_or_name = poke_name
            routing.get do
              path_request = Request::PokemonPath.new(id_or_name, request)

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
          # GET /pokemon
          routing.get do
            response.cache_control public: true, max_age: 3600
            result =
            if routing.params == {}
              Service::BasicPokemonPopularity.new.call
            else
              # GET /pokemon?color=xx&type_name=xx&habitat=xx&height=xx&weight=xx
              path_request = Request::AdvancePath.new(routing.params)
              Service::Advance.new.call(requested: path_request)
            end

            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end

            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code

            Representer::BasicPokemonList.new(
              result.value!.message
            ).to_json
          end
        end
      end
    end
  end
end
