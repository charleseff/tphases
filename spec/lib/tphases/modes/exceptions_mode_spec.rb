require 'spec_helper'
require 'active_record'
require 'tphases/modes/exceptions_mode'

describe TPhases::Modes::ExceptionsMode do
  subject { Module.new { include TPhases::Modes::ExceptionsMode } }

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

  describe "nested phases" do
    context "read_phase inside of a no_transactions_phase" do
      it "should allow read transactions" do
        expect {
          subject.no_transactions_phase do
            subject.read_phase do
              ActiveRecord::Base.connection.select_all(read_sql)
            end
          end
        }.to_not raise_error

      end
    end

    context "no_transactions_phase inside a read_phase" do
      it "should disallow read transactions" do
        expect {
          subject.read_phase do
            subject.no_transactions_phase do
              ActiveRecord::Base.connection.select_all(read_sql)
            end
          end
        }.to raise_error(ActiveRecord::StatementInvalid, "TransactionalViolation: #{read_sql} ran inside of a 'no_transactions_phase' block.: #{read_sql}")


      end
    end

    it "should have the right phase_stack sizes" do
      subject.instance_variable_get("@phase_stack").should be_empty
      subject.read_phase do
        subject.instance_variable_get("@phase_stack").size.should == 1
        subject.no_transactions_phase do
          subject.instance_variable_get("@phase_stack").size.should == 2
        end
        subject.instance_variable_get("@phase_stack").size.should == 1
      end
      subject.instance_variable_get("@phase_stack").should be_empty
    end
  end
end