# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "active_support/core_ext/enumerable"
require "peatio"

module Peatio
  module Ndc
    require "bigdecimal"
    require "bigdecimal/util"

    require "peatio/ndc/blockchain"
    require "peatio/ndc/client"
    require "peatio/ndc/wallet"

    require "peatio/ndc/hooks"

    require "peatio/ndc/version"
  end
end
