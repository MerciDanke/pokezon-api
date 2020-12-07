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

      routing.on 'type' do
        routing.is do
          routing.get do
            color_name = routing.params['color'].nil? ? '' : routing.params['color'].downcase
            type_name = routing.params['type'].nil? ? '' : routing.params['type'].downcase
            habitat_name = routing.params['habitat'].nil? ? '' : routing.params['habitat'].downcase
            low_h = routing.params['low_h'].nil? ? '' : (routing.params['low_h'].downcase).to_f * 10
            high_h = routing.params['high_h'].nil? ? '' : (routing.params['high_h'].downcase).to_f * 10
            low_w = routing.params['low_w'].nil? ? '' : (routing.params['low_w'].downcase).to_f * 10
            high_w = routing.params['high_w'].nil? ? '' : (routing.params['high_w'].downcase).to_f * 10

            advance_hash = {
              :'color' => color_name,
              :'type_name' => type_name,
              :'habitat' => habitat_name,
              :'weight' => (low_w..high_w),
              :'height' => (low_h..high_h)
            }

            newhash = advance_hash.select { |_key, value| value != '' }
            newnewhash = newhash.select { |_key, value| value != (0.0..0.0) }

            pokemon = SearchRecord::ForPoke.klass(Entity::Pokemon)
                .find_all_advances(newnewhash)
            popularities = Popularities.new(pokemon).call

            viewable_pokemons = Views::PokemonsList.new(pokemon, advance_hash, popularities)
            view 'home', locals: { pokemons: viewable_pokemons }
          end
        end
      end
      routing.on 'products' do
        routing.is do
          # GET /products/
          routing.post do
            poke_name = routing.params['poke_name'].downcase
            routing.params['poke_name'] = routing.params['poke_name'].downcase
            poke_request = Forms::SearchProduct.new.call(routing.params)
            products_show = Service::ShowProducts.new.call(poke_request)

            if products_show.failure?
              flash[:error] = products_show.failure
              routing.redirect '/'
            end

            session[:watching].insert(0, poke_name).uniq!
            flash[:notice] = 'Pokemon added to your list'
            routing.redirect "products/#{poke_name}"
          end
        end

        routing.on String do |poke_name|
          # GET /products/poke_name, apikey
          routing.get do
            # Get pokemon and products from database
            pokemon = SearchRecord::ForPoke.klass(Entity::Pokemon)
              .find_full_name(poke_name)
            products = Service::ShowProducts.new
              .products_in_database(poke_name)

            viewable_products = Views::ProductsList.new(products, poke_name, pokemon)
            view 'products', locals: { products: viewable_products }
          end
        end
      end
    end
  end
end
