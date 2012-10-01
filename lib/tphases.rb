require 'active_support/concern'
require "tphases/version"
require "tphases/config"
require "tphases/initialization"

module TPhases
  include TPhases::Config
  include TPhases::Initialization
end
