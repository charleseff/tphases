require 'tphases/transactional_violation'
require 'tphases/modes/helpers/transactional_violations_helper'

# the default 'development' mode, Exceptions Mode means that an exception will be raised
# immediately inside of a TPhase block if a transactional violation occurs
module TPhases
  module Modes
    module ExceptionsMode
      extend ActiveSupport::Concern

      include Helpers::TransactionalViolationsHelper

      private

      def write_violation_action(sql, caller)
        raise TransactionalViolation.new "#{sql} ran inside of a 'write_phase' block."
      end

      def read_violation_action(sql, caller)
        raise TransactionalViolation.new "#{sql} ran inside of a 'read_phase' block."
      end

      def no_transactions_violation_action(sql, caller)
        raise TransactionalViolation.new "#{sql} ran inside of a 'no_transactions_phase' block."
      end

    end
  end
end
