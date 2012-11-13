# the default 'production' mode, PassThrough mode does nothing but called the yielded block
module TPhases
  module Modes
    module PassThroughMode
      extend ActiveSupport::Concern

      module ClassMethods
        def read_phase
          yield
        end

        def write_phase
          yield
        end

        def no_transactions_phase
          yield
        end

        def ignore_phases
          yield
        end

        private
        def add_rails_methods!
          require 'tphases/rails/no_transactions_in_controller_pass_through'
          ActionController::Base.send :include, TPhases::Rails::NoTransactionsInControllerPassThrough
        end
      end
    end
  end
end
