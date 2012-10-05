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
        add_cucumber_after! if defined?(Cucumber)
        @violations = []
      end


      module ClassMethods
        attr_accessor :violations

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

        # adds an after block for all rspec tests that cause them to fail if any transactional violations are present
        def add_rspec_after!
          RSpec.configure do |config|
            config.after(:each, &after_test_fail_if_violations_proc)
          end
        end

        def add_cucumber_after!
          require 'cucumber/rb_support/rb_dsl'
          Cucumber::RbSupport::RbDsl.register_rb_hook('after', [], after_test_fail_if_violations_proc)
        end

        # fails if there were any transactional violations
        def after_test_fail_if_violations_proc
          Proc.new do
            begin
              if TPhases.config.collect_mode_failures_on && !TPhases.violations.empty?
                fail <<-FAILURE_MESSAGE
                    This spec had #{TPhases.violations.count} transactional violations:
                      #{TPhases.violations.each_with_index.map do |violation, index|
                  "#{index}: Violation Type: #{violation[:type]},\nSQL: #{violation[:sql]}\nCall Stack:\n\t#{violation[:call_stack].join("\n\t")}"
                end.join("\n*********************************************************\n")}
                  end
                FAILURE_MESSAGE
              end
            ensure
              TPhases.violations = [] # reset violations list
            end
          end

        end

      end
    end
  end
end