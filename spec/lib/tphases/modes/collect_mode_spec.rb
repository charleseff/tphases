require 'spec_helper'
require 'active_record'
require 'tphases/modes/collect_mode'

describe TPhases::Modes::CollectMode do
  subject { Module.new { include TPhases::Modes::CollectMode } }

  let(:sql) { "SELECT 1 FROM foo" }
  let(:call_stack) { caller }

  context "violation actions" do
    describe '.write_violation_action' do
      it "should add to the violations list" do
        expect { subject.send(:write_violation_action, sql, call_stack) }.
            to change { subject.violations }.
                   from([]).
                   to([{ :type => :write, :call_stack => call_stack, :sql => sql }])
      end
    end

    describe '.read_violation_action' do
      it "should add to the violations list" do
        expect { subject.send(:read_violation_action, sql, call_stack) }.
            to change { subject.violations }.
                   from([]).
                   to([{ :type => :read, :call_stack => call_stack, :sql => sql }])
      end
    end

    describe '.no_transactions_violation_action' do
      it "should add to the violations list" do
        expect { subject.send(:no_transactions_violation_action, sql, call_stack) }.
            to change { subject.violations }.
                   from([]).
                   to([{ :type => :no_transactions, :call_stack => call_stack, :sql => sql }])
      end
    end

    context "multiple violation actions" do
      it "should add multiple values to the violations list" do
        expect {
          subject.send(:no_transactions_violation_action, sql, call_stack)
          subject.send(:read_violation_action, sql, call_stack)
          subject.send(:write_violation_action, sql, call_stack)
        }.
            to change { subject.violations }.
                   from([]).
                   to([
                          { :type => :no_transactions, :call_stack => call_stack, :sql => sql },
                          { :type => :read, :call_stack => call_stack, :sql => sql },
                          { :type => :write, :call_stack => call_stack, :sql => sql },
                      ])

      end
    end
  end


end