# the default 'production' mode, PassThrough mode does nothing but called the yielded block
module TPhases
  module Modes
    module PassThroughMode
      def read_phase
        yield
      end

      def write_phase
        yield
      end

      def no_transactions_phase
        yield
      end
    end
  end
end
