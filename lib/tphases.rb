require "tphases/version"
require "tphases/config"
require "tphases/initialization"

module TPhases
  extend self
  extend TPhases::Config
  extend TPhases::Initialization
end
