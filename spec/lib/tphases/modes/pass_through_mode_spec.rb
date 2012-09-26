require 'spec_helper'
require 'active_record'
require 'tphases/modes/pass_through_mode'

describe TPhases::Modes::PassThroughMode do
  subject { Module.new { extend TPhases::Modes::PassThroughMode } }

  include_context "setup mode specs"

  describe '.no_transactions_phase, .read_phase, .write_phase' do
    it "should allow anything" do
      subject.no_transactions_phase do
        ActiveRecord::Base.connection.select_all(read_sql)
        ActiveRecord::Base.connection.select_all(write_sql)
      end

      subject.write_phase do
        ActiveRecord::Base.connection.select_all(read_sql)
        ActiveRecord::Base.connection.select_all(write_sql)
      end

      subject.read_phase do
        ActiveRecord::Base.connection.select_all(read_sql)
        ActiveRecord::Base.connection.select_all(write_sql)
      end

    end

  end
end