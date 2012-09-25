require "tphases/version"
require "tphases/config"
require "tphases/initialization"

module TPhases
  extend self
  include TPhases::Config
  include TPhases::Initialization
end
