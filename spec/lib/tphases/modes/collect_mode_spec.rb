require 'spec_helper'
require 'active_record'
require 'tphases/modes/collect_mode'

describe TPhases::Modes::CollectMode do
  subject { Module.new { extend TPhases::Modes::CollectMode } }

  include_context "setup mode specs"

  after do
    # somewhat hacky: todo fix:
    subject.send :clear_violations
  end

  describe '.no_transactions_phase' do
    it "should add to the violations list for all violations" do
      expect {
        subject.no_transactions_phase do
          ActiveRecord::Base.connection.select_all(read_sql)
        end
      }.to change { subject.send(:violations).size }.from(0).to(1)
    end

    it "should add multiple violations if there are multiple" do
      expect {
        subject.no_transactions_phase do
          ActiveRecord::Base.connection.select_all(read_sql)
          ActiveRecord::Base.connection.select_all(write_sql)
        end
      }.to change { subject.send(:violations).size }.from(0).to(2)
    end
  end

  describe '.read_phase' do
    it "should not add a violation for read transactions" do
      expect {
        subject.read_phase do
          ActiveRecord::Base.connection.select_all(read_sql)
        end
      }.to_not change { subject.send(:violations).size }
    end
    it "should add a violation for write transactions" do
      expect {
        subject.read_phase do
          ActiveRecord::Base.connection.select_all(write_sql)
        end
      }.to change { subject.send(:violations).size }.from(0).to(1)

    end
  end

  describe '.write_phase' do
    it "should not add a violation for write transactions" do
      expect {
        subject.write_phase do
          ActiveRecord::Base.connection.select_all(write_sql)
        end
      }.to_not change { subject.send(:violations).size }
    end
    it "should add a violation for read transactions" do
      expect {
        subject.write_phase do
          ActiveRecord::Base.connection.select_all(read_sql)
        end
      }.to change { subject.send(:violations).size }.from(0).to(1)

    end
  end

end