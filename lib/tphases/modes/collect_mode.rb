require 'tphases/transactional_violation'
require 'tphases/modes/helpers/transactional_violations_helper'

# the default 'test' mode, Collect Mode collects incidents of
# immediately inside of a TPhase block if a transactional violation occurs
module TPhases
  module Modes
    module CollectMode
      include Helpers::TransactionalViolationsHelper

      private
      def violations
        @violations ||= []
      end

      def write_violation_action(sql, call_stack)
        violations << { :type => :write, :call_stack => call_stack, :sql => sql }
      end

      def read_violation_action(sql, call_stack)
        violations << { :type => :read, :call_stack => call_stack, :sql => sql }
      end

      def no_transactions_violation_action(sql, call_stack)
        violations << { :type => :no_transactions, :call_stack => call_stack, :sql => sql }
      end

      # adds an after block for all rspec tests that causes them to fail if
      def add_rspec_after!
        RSpec.configure do |config|
          config.after(:each) do
            begin
              unless violations.empty?
                fail "This spec had #{violations.count} transactional violations: \n\t#{violations.map(&:inspect).join("\n\t")}"
              end
            ensure
              # reset violations list:
              @violations = []
            end
          end
        end
      end

    end
  end
end