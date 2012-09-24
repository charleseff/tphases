module TPhases
  module PhaseMethods

    def read_phase(&block)
      mode.read_phase(&block)
    end

    def write_phase(&block)
      mode.write_phase(&block)
    end

    def no_transactions_phase(&block)
      mode.no_transactions_phase(&block)
    end

    private
    # the first time mode is called, which is when one of the phase methods is first called,
    # it is instantiated and cached.  after this point, changing the config mode value has no effect
    def mode
      @mode ||= begin
        case config.mode
          when :pass_through
            require 'tphases/modes/pass_through_mode'
            TPhases::Modes::PassThroughMode.new
          when :exceptions
            require 'tphases/modes/exceptions_mode'
            TPhases::Modes::ExceptionsMode.new
          when :collect
            require 'tphases/modes/collect_mode'
            TPhases::Modes::CollectMode.new
          else
            raise "TPhases mode must be one of :pass_through, :exceptions, or :collect, but instead is #{config.mode}"
        end

      end
    end
  end
end