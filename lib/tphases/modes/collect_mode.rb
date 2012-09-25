# the default 'test' mode, Collect Mode collects incidents of
# immediately inside of a TPhase block if a transactional violation occurs
module TPhases
  module Modes
    module CollectMode
      include Helpers::TransactionalViolationsHelper

      attr_reader :violations

      def initialize
        @violations = []
      end

      def read_phase(&block)
        ActiveSupport::Notifications.subscribed(block, "sql.active_record") do |name, date, date2, sha, args|
          if read_transactional_violation?(args[:sql])
            @violations << { :type => :read, :caller => caller.first, :sql => args[:sql] }
          end
        end
      end

      def write_phase(&block)
        ActiveSupport::Notifications.subscribed(block, "sql.active_record") do |name, date, date2, sha, args|
          if write_transactional_violation?(args[:sql])
            @violations << { :type => :write, :caller => caller.first, :sql => args[:sql] }
          end
        end
      end

      def no_transactions_phase(&block)
        ActiveSupport::Notifications.subscribed(block, "sql.active_record") do |name, date, date2, sha, args|
          @violations << { :type => :no_transactions, :caller => caller.first, :sql => args[:sql] }
        end
      end

      private
      # adds an after block for all rspec tests that causes them to fail if
      def add_rspec_after!
        RSpec.configure do |config|
          config.after(:each) do
            begin
              unless @violations.empty?
                fail "This spec had #{@violations.count} transactional violations: \n\t#{@violations.map(&:inspect).join("\n\t")}"
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