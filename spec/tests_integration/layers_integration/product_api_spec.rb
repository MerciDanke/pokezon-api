# frozen_string_literal: false

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'

describe 'Tests Product API library' do
  before do
    VcrHelper.configure_vcr_for_apikey
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Product information' do
    it 'HAPPY: should provide correct product datatype' do
      products = MerciDanke::GoogleShopping::ProductMapper.new.find(POKE_NAME, API_KEY)
      products.each do |product|
        _(product.origin_id.class).must_equal String
        _(product.poke_name.class).must_equal String
        _(product.title.class).must_equal String
        _(product.link.class).must_equal String
        _(product.image.class).must_equal String
        _(product.rating.class).wont_be_nil
        _(product.ratings_total.class).wont_be_nil
        _(product.price.class).must_equal String
        _(product.product_likes.class).must_equal Integer
      end
    end
  end
end
