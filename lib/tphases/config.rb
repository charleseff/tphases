require 'active_support/concern'

module TPhases
  module Config
    extend ActiveSupport::Concern

    module ClassMethods
      # allow for configuration of TPhases
      def configure(&block)
        yield config
      end
    end
    private
    # the config
    # sets default value `mode` value based on presence of Rails and environment type
    # the default setting is the safest, :pass_through, which means TPhases does nothing.
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

        Struct.new(:mode).new(default_mode)
      end
    end

  end
end