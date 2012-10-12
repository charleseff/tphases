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

        module ClassMethods

          def define_phase_methods!
            %w{read write no_transactions}.each do |phase_type|
              define_singleton_method(:"#{phase_type}_phase") do |&block|
                phase = Phase.new
                @phase_stack << phase
                begin
                  subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |name, date, date2, sha, args|
                    next unless @phase_stack.last == phase
                    if send(:"#{phase_type}_violation?", args[:sql])
                      send(:"#{phase_type}_violation_action", args[:sql], caller)
                    end

                  end
                  block.call
                ensure
                  ActiveSupport::Notifications.unsubscribe(subscriber)
                  @phase_stack.pop
                end
              end
            end
          end

          private
          READ_QUERIES  = %w{update commit insert delete}
          WRITE_QUERIES = %w{show select}

          # determines if this query is a read transactional violation (if it is anything besides a read)
          def read_violation?(sql)
            READ_QUERIES.include?(first_word(sql))
          end

          # determines if this query is a write transactional violation (if it is anything besides a write)
          def write_violation?(sql)
            WRITE_QUERIES.include?(first_word(sql))
          end

          def no_transactions_violation?(sql)
            true
          end

          def first_word(str)
            str.split(' ').first.downcase
          end

        end

        # simple class to represent a phase on the stack of phases.  Used to determine which phase is active
        class Phase;
        end

      end
    end
  end
end
