require 'spec_helper'
require 'tphases/modes/helpers/transactional_violations_helper'

describe TPhases::Modes::Helpers::TransactionalViolationsHelper do
  describe TPhases::Modes::Helpers::TransactionalViolationsHelper do
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

    describe "#read_violation?" do
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

      context "describes" do
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

  end
end