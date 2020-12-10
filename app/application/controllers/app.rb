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

      routing.on 'plus_like' do
        routing.is do
          routing.get do
            poke_id = routing.params['poke_id']
            if poke_id.nil?
              product_id = routing.params['product_id']
              SearchRecord::For.klass(Entity::Product).plus_like(product_id)
            else
              SearchRecord::ForPoke.klass(Entity::Pokemon).plus_like(poke_id)
            end

            advance_hash = {
              :'color' => '',
              :'type_name' => '',
              :'habitat' => '',
              :'weight' => '',
              :'height' => ''
            }
            pokemon_all = SearchRecord::ForPoke.klass(Entity::Pokemon).all
            popularities = Popularities.new(pokemon_all).call

            viewable_pokemons = Views::PokemonsList.new(pokemon_all, advance_hash, popularities)
            view 'home', locals: { pokemons: viewable_pokemons }
          end
        end
      end

      routing.on 'api/v1' do
        routing.on 'pokemons' do
          routing.on String do |poke_name|
            # GET /projects/{owner_name}/{project_name}[/folder_namepath/]
            routing.get do
              path_request = Request::PokemonPath.new(poke_name, request)

              # result = Service::AppraiseProject.new.call(requested: path_request)

              # if result.failure?
              #   failed = Representer::HttpResponse.new(result.failure)
              #   routing.halt failed.http_status_code, failed.to_json
              # end

              # http_response = Representer::HttpResponse.new(result.value!)
              # response.status = http_response.http_status_code

              # Representer::ProjectFolderContributions.new(
              #   result.value!.message
              # ).to_json
            end
          end

          routing.is do
            # GET /projects?list={base64 json array of project fullnames}
            routing.get do
              list_req = Request::EncodedPokemonList.new(routing.params)
              result = Service::ListPokemons.new.call(list_request: list_req)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::PokemonsList.new(result.value!.message).to_json
            end
          end
        end

        routing.on 'products' do
          routing.is do
            # GET /products/
            routing.post do
              products_show = Service::ShowProducts.new.call(poke_name: poke_name)

              if products_show.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Product.new(result.value!.message).to_json
            end
          end

          routing.on String do |poke_name|
            # GET /products/poke_name, apikey
            routing.get do
              # Get pokemon and products from database
              path_request = Request::PokemonPath.new(poke_name, request)
              pokemon = SearchRecord::ForPoke.klass(Entity::Pokemon)
                .find_full_name(poke_name)
              products = Service::ShowProducts.new
                .products_in_database(poke_name)

              # result = Service::AppraiseProject.new.call(requested: path_request)

              # if result.failure?
              #   failed = Representer::HttpResponse.new(result.failure)
              #   routing.halt failed.http_status_code, failed.to_json
              # end

              # http_response = Representer::HttpResponse.new(result.value!)
              # response.status = http_response.http_status_code

              # Representer::ProjectFolderContributions.new(
              #   result.value!.message
              # ).to_json
            end
          end
        end
      end
    end
  end
end
