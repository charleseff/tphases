require 'active_support/notifications'
require 'tphases/transactional_violation'
require 'tphases/modes/helpers/transactional_violations_helper'

# the default 'development' mode, Exceptions Mode means that an exception will be raised
# immediately inside of a TPhase block if a transactional violation occurs
module TPhases
  module Modes
    class ExceptionsMode
      include Helpers::TransactionalViolationsHelper

      def read_phase(&block)
        ActiveSupport::Notifications.subscribed(block, "sql.active_record") do |name, date, date2, sha, args|
          if read_transactional_violation?(args[:sql])
            raise TransactionalViolation.new "#{args[:sql]} ran inside of a 'read_phase' block."
          end
        end
      end

      def write_phase(&block)
        ActiveSupport::Notifications.subscribed(block, "sql.active_record") do |name, date, date2, sha, args|
          if write_transactional_violation?(args[:sql])
            raise TransactionalViolation.new "#{args[:sql]} ran inside of a 'write_phase' block."
          end
        end
      end

      def no_transactions_phase(&block)
        ActiveSupport::Notifications.subscribed(block, "sql.active_record") do |name, date, date2, sha, args|
          raise TransactionalViolation.new "#{args[:sql]} ran inside of a 'no_transactions_phase' block."
        end
      end
    end
  end
end
