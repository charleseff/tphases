# the default 'test' mode, Collect Mode collects incidents of
# immediately inside of a TPhase block if a transactional violation occurs
module TPhases
  module Modes
    module CollectMode
      include Helpers::TransactionalViolationsHelper

      private
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
              violations = []
            end
          end
        end
      end

      def violations
        @violations ||= []
      end

      def write_violation_action(sql, caller)
        violations << { :type => :write, :caller => caller, :sql => sql }
      end

      def read_violation_action(sql, caller)
        violations << { :type => :read, :caller => caller, :sql => sql }
      end


      def no_transactions_violation_action(sql, caller)
        violations << { :type => :no_transactions, :caller => caller, :sql => args[:sql] }
      end
    end
  end
end