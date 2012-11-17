require 'spec_helper'
require 'active_record'
require 'tphases/modes/exceptions_mode'

describe TPhases::Modes::ExceptionsMode do
  subject { Module.new { include TPhases::Modes::ExceptionsMode } }

  let(:sql) { "SELECT 1 FROM foo" }
  let(:call_stack) { caller }

  context "violation actions" do
    describe '.write_violation_action' do
      it "should raise" do
        expect { subject.send(:write_violation_action, sql, call_stack) }.
            to raise_error(TransactionalViolation, "#{sql} ran inside of a 'write_phase' block.")
      end
    end

    describe '.read_violation_action' do
      it "should raise" do
        expect { subject.send(:read_violation_action, sql, call_stack) }.
            to raise_error(TransactionalViolation, "#{sql} ran inside of a 'read_phase' block.")
      end
    end

    describe '.no_transactions_violation_action' do
      it "should raise" do
        expect { subject.send(:no_transactions_violation_action, sql, call_stack) }.
            to raise_error(TransactionalViolation, "#{sql} ran inside of a 'no_transactions_phase' block.")
      end
    end

  end

end