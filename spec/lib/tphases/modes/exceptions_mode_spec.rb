require 'spec_helper'
require 'active_record'
require 'tphases/modes/exceptions_mode'

describe TPhases::Modes::ExceptionsMode do
  subject { Module.new { extend TPhases::Modes::ExceptionsMode } }

  include_context "setup mode specs"

  describe '.no_transactions_phase' do
    it "should throw an exception disallow read and write transactions from running in this phase" do
      expect {
        subject.no_transactions_phase do
          ActiveRecord::Base.connection.select_all(read_sql)
        end
      }.to raise_error(ActiveRecord::StatementInvalid, "TransactionalViolation: #{read_sql} ran inside of a 'no_transactions_phase' block.: #{read_sql}")

      expect {
        subject.no_transactions_phase do
          ActiveRecord::Base.connection.select_all(write_sql)
        end
      }.to raise_error(ActiveRecord::StatementInvalid, "TransactionalViolation: #{write_sql} ran inside of a 'no_transactions_phase' block.: #{write_sql}")
    end
  end

  describe '.read_phase' do
    it "should allow read transactions" do
      expect {
        subject.read_phase do
          ActiveRecord::Base.connection.select_all(read_sql)
        end
      }.to_not raise_error
    end
    it "should disallow write transactions" do
      expect {
        subject.read_phase do
          ActiveRecord::Base.connection.select_all(write_sql)
        end
      }.to raise_error(ActiveRecord::StatementInvalid, "TransactionalViolation: #{write_sql} ran inside of a 'read_phase' block.: #{write_sql}")

    end
  end

  describe '.write_phase' do
    it "should allow write transactions" do
      expect {
        subject.write_phase do
          ActiveRecord::Base.connection.select_all(write_sql)
        end
      }.to_not raise_error
    end
    it "should disallow read transactions" do
      expect {
        subject.write_phase do
          ActiveRecord::Base.connection.select_all(read_sql)
        end
      }.to raise_error(ActiveRecord::StatementInvalid, "TransactionalViolation: #{read_sql} ran inside of a 'write_phase' block.: #{read_sql}")

    end
  end
end