require 'active_support/notifications'
require 'active_support/version'
require 'active_support/core_ext/object/try'

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

                if @phase_stack.last.try(:ignored?)
                  return block.call
                end

                phase = Phase.new
                @phase_stack << phase
                begin
                  subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |name, date, date2, sha, args|
                    next unless @phase_stack.last == phase
                    send(:"#{phase_type}_violation_action", args[:sql], caller) if send(:"#{phase_type}_violation?", args[:sql])
                  end
                  return block.call
                ensure
                  ActiveSupport::Notifications.unsubscribe(subscriber)
                  @phase_stack.pop
                end
              end
            end
          end

          def ignore_phases
            @phase_stack << Phase.new(ignore: true)
            yield
          ensure
            @phase_stack.pop
          end

          private
          READ_QUERIES            = %w{show select describe}
          WRITE_QUERIES           = %w{update commit insert delete}
          RAILS_IGNORABLE_QUERIES = %w{describe}

          def rails_ignorable_read_queries
            @rails_ignorable_read_queries ||= READ_QUERIES - RAILS_IGNORABLE_QUERIES
          end

          # determines if this query is a read transactional violation (if it is anything besides a read)
          def read_violation?(sql)
            WRITE_QUERIES.include?(first_word(sql))
          end

          # determines if this query is a write transactional violation (if it is anything besides a write)
          def write_violation?(sql)
            query_types = (Object.const_defined? :Rails) ? rails_ignorable_read_queries : READ_QUERIES
            query_types.include?(first_word(sql))
          end

          # violation unless it's Rails and we are running an ignorable query
          def no_transactions_violation?(sql)
            if Object.const_defined? :Rails
              !RAILS_IGNORABLE_QUERIES.include?(first_word(sql))
            else
              true
            end
          end

          def first_word(str)
            str.split(' ').first.downcase
          end

        end

        # simple class to represent a phase on the stack of phases.  Used to determine which phase is active
        class Phase;
          def initialize(opts={ ignore: false })
            @ignore = opts[:ignore]
          end

          def ignored?
            @ignore
          end
        end

      end
    end
  end
end
