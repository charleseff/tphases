require 'spec_helper'
require 'active_record'
require 'tphases/modes/helpers/transactional_violations_helper'

describe TPhases::Modes::Helpers::TransactionalViolationsHelper do
  include_context "setup mode specs"

  subject { Module.new { include TPhases::Modes::Helpers::TransactionalViolationsHelper } }

  let(:write_queries) {
    [
        "UPDATE `users` SET `email` = 'woifjwe@owiejf.com' WHERE `users`.`id` = 1",
        "INSERT INTO tablename (col1, col2) VALUES('data1', 'data2' )",
        "COMMIT",
        "DELETE FROM example WHERE age='15'"
    ]
  }
  let(:read_queries) {
    [
        "select * from foobar",
        "show variables like 'version'"
    ]
  }

  describe "#read_transactional_violation?" do
    it "should detect correctly" do
      read_queries.each { |read_query| expect(subject.send(:read_violation?, read_query)).to eq(false) }
      write_queries.each { |write_query| expect(subject.send(:read_violation?, write_query)).to eq(true) }
    end
  end

  describe "#write_violation?" do
    it "should detect correctly" do
      read_queries.each { |read_query| expect(subject.send(:write_violation?, read_query)).to be_true }
      write_queries.each { |write_query| expect(subject.send(:write_violation?, write_query)).to be_false }
    end

    context "describe queries" do
      context "when Rails is present" do
        it "should detect correctly" do
          Object.should_receive(:const_defined?).with(:Rails).and_return(true)
          expect(subject.send(:write_violation?, "describe foo")).to be_false
        end
      end
      context "when Rails is not present" do
        it "should detect correctly" do
          Object.should_receive(:const_defined?).with(:Rails).and_return(false)
          expect(subject.send(:write_violation?, "describe foo")).to be_true
        end
      end
    end

  end

  describe "#no_transactions_violation?" do
    context "when Rails is present" do
      it "should detect correctly" do
        Object.stub(:const_defined?).with(:Rails).and_return(true)
        expect(subject.send(:no_transactions_violation?, "describe foo")).to be_false
        expect(subject.send(:no_transactions_violation?, "select * from foo")).to be_true
      end
    end
    context "when Rails is not present" do
      it "should detect correctly" do
        Object.stub(:const_defined?).with(:Rails).and_return(false)
        expect(subject.send(:no_transactions_violation?, "describe foo")).to be_true
        expect(subject.send(:no_transactions_violation?, "select * from foo")).to be_true
      end
    end
  end


  describe '.no_transactions_phase' do
    it "should send a no_transactions_violation_action for reads" do
      subject.should_receive :no_transactions_violation_action
      subject.no_transactions_phase { ActiveRecord::Base.connection.select_all(read_sql) }
    end

    it "should send a no_transactions_violation_action for writes" do
      subject.should_receive :no_transactions_violation_action
      subject.no_transactions_phase { ActiveRecord::Base.connection.select_all(write_sql) }
    end
  end

  describe '.read_phase' do
    it "should allow read transactions" do
      subject.should_not_receive :read_violation_action
      subject.read_phase { ActiveRecord::Base.connection.select_all(read_sql) }
    end
    it "should disallow write transactions" do
      subject.should_receive :read_violation_action
      subject.read_phase { ActiveRecord::Base.connection.select_all(write_sql) }
    end
  end

  describe '.write_phase' do
    it "should allow write transactions" do
      subject.should_not_receive :write_violation_action
      subject.write_phase { ActiveRecord::Base.connection.select_all(write_sql) }
    end
    it "should disallow read transactions" do
      subject.should_receive :write_violation_action
      subject.write_phase { ActiveRecord::Base.connection.select_all(read_sql) }
    end
  end

  describe "nested phases" do
    context "read_phase inside of a no_transactions_phase" do
      it "should allow read transactions" do
        subject.should_not_receive :no_transactions_violation_action
        subject.no_transactions_phase do
          subject.read_phase { ActiveRecord::Base.connection.select_all(read_sql) }
        end
      end
    end

    context "no_transactions_phase inside a read_phase" do
      it "should disallow transactions" do
        subject.should_receive :no_transactions_violation_action
        subject.read_phase do
          subject.no_transactions_phase do
            ActiveRecord::Base.connection.select_all(read_sql)
          end
        end
      end
    end

    it "should have the right phase_stack sizes" do
      subject.send(:phase_stack).should be_empty
      subject.read_phase do
        subject.send(:phase_stack).size.should == 1
        subject.no_transactions_phase do
          subject.send(:phase_stack).size.should == 2
        end
        subject.send(:phase_stack).size.should == 1
      end
      subject.send(:phase_stack).should be_empty
    end

    context "ignore_phases inside of a no_transactions_phase" do
      it "should disallow transactions after the ignore phase" do
        subject.should_receive :no_transactions_violation_action
        subject.no_transactions_phase do
          subject.ignore_phases { }
          ActiveRecord::Base.connection.select_all(read_sql)
        end
      end
      it "should allow transactions in the ignore phase" do
        subject.should_not_receive :no_transactions_violation_action
        subject.no_transactions_phase do
          subject.ignore_phases do
            ActiveRecord::Base.connection.select_all(read_sql)
          end
        end

      end
    end

    context "no_transactions_phase inside of a ignore_phases" do
      it "should allow transactions inside the no_transactions_phase block" do
        subject.should_not_receive :no_transactions_violation_action
        subject.ignore_phases do
          subject.no_transactions_phase { ActiveRecord::Base.connection.select_all(read_sql) }
        end
      end
      it "should allow transactions after the no_transactions_phase block" do
        subject.should_not_receive :no_transactions_violation_action
        subject.ignore_phases do
          subject.no_transactions_phase { }
          ActiveRecord::Base.connection.select_all(read_sql)
        end

      end

    end
  end

end
