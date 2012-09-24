require 'spec_helper'

describe TPhases do

  describe '.no_transactions_phase' do
    it "should disallow all transactions from running in this phase"
  end

  describe '.read_phase' do
    it "should allow read transactions"
    it "should disallow write transactions"
  end

  describe '.write_phase' do
    it "should allow write transactions"
    it "should disallow read transactions"
  end
end