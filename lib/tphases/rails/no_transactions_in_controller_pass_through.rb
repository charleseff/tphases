module TPhases
  module Rails
    module NoTransactionsInControllerPassThrough
      extend ActiveSupport::Concern
      module ClassMethods
        def ensure_no_transactions_on(actions)
          # do nothing
        end
      end
    end
  end
end