# frozen_string_literal: false

require_relative '../../helpers/spec_helper_product'
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
      producttests = MerciDanke::Amazon::ProductMapper.new.find(POKENAME, API_KEY)
      producttests.each do |producttest|
        _(producttest.origin_id.class).must_equal String
        _(producttest.poke_name.class).must_equal String
        _(producttest.title.class).must_equal String
        _(producttest.link.class).must_equal String
        _(producttest.image.class).must_equal String
        _(producttest.rating.class).must_equal Float
        _(producttest.ratings_total.class).must_equal Integer
      end
    end
  end
end
