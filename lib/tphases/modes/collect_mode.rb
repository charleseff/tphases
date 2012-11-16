require 'tphases/transactional_violation'
require 'tphases/modes/helpers/transactional_violations_helper'
require 'tphases/modes/helpers/rails_helper'

# the default 'test' mode, Collect Mode collects incidents of
# immediately inside of a TPhase block if a transactional violation occurs
module TPhases
  module Modes
    module CollectMode
      extend ActiveSupport::Concern
      include Helpers::TransactionalViolationsHelper
      include Helpers::RailsHelper if defined? ::Rails

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
          # todo: get me working
          #require 'cucumber/rb_support/rb_dsl'
          #Cucumber::RbSupport::RbDsl.register_rb_hook('after', [], after_test_fail_if_violations_proc)
        end

        # fails if there were any transactional violations
        def after_test_fail_if_violations_proc
          Proc.new do
            begin
              if TPhases.config.collect_mode_failures_on && !TPhases.violations.empty?

                fail_message = "This spec had #{TPhases.violations.count} transactional violations:\n"
                TPhases.violations.each_with_index.map do |violation, index|
                  fail_message << "*"*50 + "\n"
                  fail_message << "Violation ##{index+1}, type: #{violation[:type]}\n"
                  fail_message << "SQL: #{violation[:sql]}\n"
                  fail_message << "Call Stack: \n\t\t#{TPhases.cleaned_call_stack(violation[:call_stack]).join("\n\t\t")}\n"
                end

                fail fail_message
              end
            ensure
              TPhases.violations = [] # reset violations list
            end
          end

        end

        public
        # taken from https://github.com/rails/rails/blob/77977f34a5a4ea899f59e31ad869b582285fa5c1/actionpack/lib/action_dispatch/middleware/show_exceptions.rb#L148 :
        # shows a cleaned stack for Rails apps by default
        def cleaned_call_stack(call_stack)
          defined?(::Rails) && ::Rails.respond_to?(:backtrace_cleaner) ?
            ::Rails.backtrace_cleaner.clean(call_stack, :silent) :
            call_stack
        end


      end
    end
  end
end