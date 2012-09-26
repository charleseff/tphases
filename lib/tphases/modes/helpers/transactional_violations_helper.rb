require 'active_support/notifications'
require 'active_support/concern'
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
        end

        private
        module ClassMethods

          # if version of activesupport is 3.2.1, it has the subscribed method.  else, it doesn't
          def define_phase_methods!
            if ActiveSupport::VERSION::MAJOR > 3
              define_phase_methods_with_subscribed_method!
            elsif ActiveSupport::VERSION::MAJOR == 3
              if ActiveSupport::VERSION::MINOR > 2
                define_phase_methods_with_subscribed_method!
              elsif ActiveSupport::VERSION::MINOR == 2
                if ActiveSupport::VERSION::TINY >= 1
                  define_phase_methods_with_subscribed_method!
                else
                  define_phase_methods_without_subscribed_method!
                end
              else
                define_phase_methods_without_subscribed_method!
              end
              define_phase_methods_with_subscribed_method!
            else
              define_phase_methods_without_subscribed_method!
            end
          end

          # adds methods using the subscribed method
          def define_phase_methods_with_subscribed_method!
            define_method(:read_phase) do |&block|
              ActiveSupport::Notifications.subscribed(read_phase_block, "sql.active_record", &block)
            end

            define_method(:write_phase) do |&block|
              ActiveSupport::Notifications.subscribed(write_phase_block, "sql.active_record", &block)
            end

            define_method(:no_transactions_phase) do |&block|
              ActiveSupport::Notifications.subscribed(no_transactions_phase_block, "sql.active_record", &block)
            end
          end

          def define_phase_methods_without_subscribed_method!
            define_method(:read_phase) do
              begin
                subscriber = ActiveSupport::Notifications.subscribe("sql.active_record", read_phase_block)
              ensure
                ActiveSupport::Notifications.unsubscribe(subscriber)
              end
            end

            define_method(:write_phase) do
              begin
                subscriber = ActiveSupport::Notifications.subscribe("sql.active_record", write_phase_block)
              ensure
                ActiveSupport::Notifications.unsubscribe(subscriber)
              end
            end

            define_method(:no_transactions_phase) do
              begin
                subscriber = ActiveSupport::Notifications.subscribe("sql.active_record", no_transactions_phase_block)
              ensure
                ActiveSupport::Notifications.unsubscribe(subscriber)
              end
            end
          end

        end

        # the set of blocks that run when an ActiveSupport notification is fired on sql.active_record
        # each call *_violation_action methods which are defined in the implementing module

        def write_phase_block
          Proc.new do |name, date, date2, sha, args|
            if write_transactional_violation?(args[:sql])
              write_violation_action(args[:sql], caller.first)
            end
          end
        end

        def read_phase_block
          Proc.new do |name, date, date2, sha, args|
            if read_transactional_violation?(args[:sql])
              read_violation_action(args[:sql], caller.first)
            end
          end
        end

        def no_transactions_phase_block
          Proc.new do |name, date, date2, sha, args|
            no_transactions_violation_action(args[:sql], caller.first)
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
    end
  end
end