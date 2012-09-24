require "tphases/version"
require "tphases/config"
require "tphases/phase_methods"
require 'ostruct'

module TPhases
  extend self
  include TPhases::Config
  include TPhases::PhaseMethods

  def initiate_for_rspec!
    RSpec.configure do |config|
      config.after(:each) { |data| after_each! data.example.metadata }
    end
  end
end
