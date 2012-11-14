module TPhases
  module Rails
    module NoTransactionsInController
      extend ActiveSupport::Concern
      module ClassMethods

        def ensure_no_transactions_on(*actions)
          actions_array = *actions
          class_variable_set(:@@no_transaction_actions, actions_array.flatten)
        end

      end
    end

  end
end
