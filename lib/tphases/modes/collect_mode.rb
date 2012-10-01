require 'tphases/transactional_violation'
require 'tphases/modes/helpers/transactional_violations_helper'

# the default 'test' mode, Collect Mode collects incidents of
# immediately inside of a TPhase block if a transactional violation occurs
module TPhases
  module Modes
    module CollectMode
      extend ActiveSupport::Concern
      include Helpers::TransactionalViolationsHelper

      included do
        add_rspec_after! if defined?(RSpec)
      end

      module ClassMethods

        def violations
          @violations ||= []
        end

        private
        def write_violation_action(sql, call_stack)
          violations << { :type => :write, :call_stack => call_stack, :sql => sql }
        end

        def read_violation_action(sql, call_stack)
          violations << { :type => :read, :call_stack => call_stack, :sql => sql }
        end

        def no_transactions_violation_action(sql, call_stack)
          violations << { :type => :no_transactions, :call_stack => call_stack, :sql => sql }
        end

        # adds an after block for all rspec tests that causes them to fail if any transactional violations are present
        def add_rspec_after!
          RSpec.configure do |config|
            config.after(:each) do
              begin
                unless TPhases.violations.empty?
                  fail "This spec had #{TPhases.violations.count} transactional violations: \n\t#{TPhases.violations.map(&:inspect).join("\n\t")}"
                  fail <<-FAILURE_MESSAGE
                    This spec had #{TPhases.violations.count} transactional violations:
                      #{TPhases.violations.map do |v|
                    "- Violation Type: #{v.type},\nSQL: #{v.sql}\nCall Stack: #{v.call_stack.join("\n")}"
                  end.join("\n\t")}
                  end
                  FAILURE_MESSAGE
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
end