module TPhases
  module Config
    # allow for configuration of TPhases
    def configure(&block)
      yield config
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
              when 'production', 'demo', 'staging' then
                :pass_through
              when 'development' then
                :exceptions
              when 'test' then
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