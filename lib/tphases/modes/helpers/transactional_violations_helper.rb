require 'active_support/notifications'
require 'active_support/version'

module TPhases
  module Modes
    module Helpers

      # this helper is included by the CollectMode and the ExceptionsMode modules.
      # methods expected to be implemented by those modes are #write_violation_action, #read_violation_action, and
      # #no_transactions_violation_action
      module TransactionalViolationsHelper
        extend ActiveSupport::Concern

        included do
          define_phase_methods!

          # used to keep track of nested phases.  a nested phase overrides any prior phase.
          @phase_stack = []
        end

        private
        module ClassMethods

          def define_phase_methods!
            define_singleton_method(:read_phase) do |&block|
              phase = Phase.new
              @phase_stack << phase
              begin
                subscriber = ActiveSupport::Notifications.subscribe("sql.active_record", &read_phase_subscription_callback(phase))
                block.call
              ensure
                ActiveSupport::Notifications.unsubscribe(subscriber)
                @phase_stack.pop
              end
            end

            define_singleton_method(:write_phase) do |&block|
              phase = Phase.new
              @phase_stack << phase
              begin
                subscriber = ActiveSupport::Notifications.subscribe("sql.active_record", &write_phase_subscription_callback(phase))
                block.call
              ensure
                ActiveSupport::Notifications.unsubscribe(subscriber)
                @phase_stack.pop
              end
            end

            define_singleton_method(:no_transactions_phase) do |&block|
              phase = Phase.new
              @phase_stack << phase
              begin
                subscriber = ActiveSupport::Notifications.subscribe("sql.active_record", &no_transactions_phase_subscription_callback(phase))
                block.call
              ensure
                ActiveSupport::Notifications.unsubscribe(subscriber)
                @phase_stack.pop
              end
            end
          end

          # the set of blocks that run when an ActiveSupport notification is fired on sql.active_record
          # each call *_violation_action methods which are defined in the implementing module
          # each will bail unless this transaction is the last on the stack, allowing for nested phases to override others

          def write_phase_subscription_callback(phase)
            Proc.new do |name, date, date2, sha, args|
              next unless @phase_stack.last == phase
              if write_transactional_violation?(args[:sql])
                write_violation_action(args[:sql], caller)
              end
            end
          end

          def read_phase_subscription_callback(phase)
            Proc.new do |name, date, date2, sha, args|
              next unless @phase_stack.last == phase
              if read_transactional_violation?(args[:sql])
                read_violation_action(args[:sql], caller)
              end
            end
          end

          def no_transactions_phase_subscription_callback(phase)
            Proc.new do |name, date, date2, sha, args|
              next unless @phase_stack.last == phase
              no_transactions_violation_action(args[:sql], caller)
            end
          end

          READ_QUERIES  = %w{update commit insert delete}
          WRITE_QUERIES = %w{show select}

          # determines if this query is a read transactional violation (if it is anything besides a read)
          def read_transactional_violation?(sql)
            READ_QUERIES.include?(first_word(sql))
          end

          # determines if this query is a write transactional violation (if it is anything besides a write)
          def write_transactional_violation?(sql)
            WRITE_QUERIES.include?(first_word(sql))
          end

          def first_word(str)
            str.split(' ').first.downcase
          end

        end

        # simple class to represent a phase on the stack of phases.  Used to determine which phase is active
        class Phase; end

      end
    end
  end
end