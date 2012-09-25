module TPhases
  module Modes
    module Helpers
      module TransactionalViolationsHelper
        private

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