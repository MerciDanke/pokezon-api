# frozen_string_literal: true

module MerciDanke
  module Representer
    # OpenStruct for deserializing json with hypermedia
    class OpenStructWithLinks < OpenStruct
      attr_reader :links
    end
  end
end
