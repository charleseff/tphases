module TPhases
  module Config
    extend ActiveSupport::Concern

    module ClassMethods
      # allow for configuration of TPhases
      def configure(&block)
        yield config
      end

      # the config
      # settings options are:
      #
      # - mode
      # - collect_mode_failures_on - defaults to true, but can be turned off temporarily to disable failures on
      #        transaction violations
      #
      # sets default value `mode` value based on presence of Rails and environment type
      # the default setting is the safest, :pass_through, which means TPhases does nothing.
      #
      def config
        @config ||= begin

          default_mode = begin
            if defined? Rails
              case Rails.env
                when 'production', 'staging', 'demo'
                  :pass_through
                when 'development'
                  :exceptions
                when 'test'
                  :collect
                else
                  :pass_through
              end
            else
              :pass_through
            end
          end

          Struct.new(:mode, :collect_mode_failures_on).new(default_mode, true)
        end
      end

    end
  end
end