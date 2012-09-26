require 'spec_helper'
require 'tphases/modes/helpers/transactional_violations_helper'

describe TPhases::Modes::Helpers::TransactionalViolationsHelper do
  describe TPhases::Modes::Helpers::TransactionalViolationsHelper do
    subject { Class.new { include TPhases::Modes::Helpers::TransactionalViolationsHelper }.new }

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
        read_queries.each { |read_query| expect(subject.send(:read_transactional_violation?, read_query)).to eq(false) }
        write_queries.each { |write_query| expect(subject.send(:read_transactional_violation?, write_query)).to eq(true) }
      end
    end

    describe " #write_transactional_violation?" do
      it "should detect correctly" do
        read_queries.each { |read_query| expect(subject.send(:write_transactional_violation?, read_query)).to be_true }
        write_queries.each { |write_query| expect(subject.send(:write_transactional_violation?, write_query)).to be_false }
      end
    end

  end
end