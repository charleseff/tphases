module TPhases
  module Initialization
    extend ActiveSupport::Concern

    module ClassMethods
      # initiates TPhases.  Any overrides to config mode need to be made prior to running this.
      def initiate!
        add_mode_methods!
        add_rails_methods! if defined? ::Rails
      end

      private
      def add_mode_methods!
        case config.mode
          when :pass_through
            require 'tphases/modes/pass_through_mode'
            include TPhases::Modes::PassThroughMode
          when :exceptions
            require 'tphases/modes/exceptions_mode'
            include TPhases::Modes::ExceptionsMode
          when :collect
            require 'tphases/modes/collect_mode'
            include TPhases::Modes::CollectMode
          else
            raise "TPhases mode must be one of :pass_through, :exceptions, or :collect, but instead is #{config.mode}"
        end
      end

    end
  end
end