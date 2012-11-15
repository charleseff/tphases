module TPhases
  module Rails
    module NoTransactionsInController
      extend ActiveSupport::Concern
      module ClassMethods

        def ensure_no_transactions_on(*actions)
          actions_array = *actions
          class_variable_set(:@@no_transaction_actions, actions_array.flatten)
          around_filter :no_transactions_around_filter, :only => actions_array
        end

      end

      private
      def no_transactions_around_filter
        TPhases.no_transactions_phase { yield }
      end
    end

  end

end
