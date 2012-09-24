module TPhases
  module Modes
    module Helpers
      module TransactionalViolationsHelper
        private

        # retrieves the first word in the string:
        REGEX = /(.+)\s?/

        # determines if this query is a read transactional violation (if it is anything besides a read)
        def read_transactional_violation?(sql)
          %w{update commit insert delete}.include?(sql.split(' ').first.downcase)
        end

        # determines if this query is a write transactional violation (if it is anything besides a write)
        def write_transactional_violation?(sql)
          %w{show select}.include?(sql.split(' ').first.downcase)
        end

      end
    end
  end
end