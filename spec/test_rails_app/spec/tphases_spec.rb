require 'spec_helper'

describe 'testing' do

  describe '.no_transactions_phase' do
    it ""
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