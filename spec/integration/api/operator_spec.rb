require "spec_helper"

module Nomad
  describe Operator do
    subject { nomad_test_client.operator }

    describe "#raft_configuration" do
      it "reads the raft configuration" do
        result = subject.raft_configuration
        expect(result).to be_a(Operator::RaftConfiguration)
        expect(result.servers.size).to be > 0
      end
    end

    describe "#remove_raft_peer" do
      it "raises an error when no addresses are given" do
        expect {
          subject.remove_raft_peer
        }.to raise_error(RuntimeError)
      end

      it "returns an error when not found" do
        expect {
          subject.remove_raft_peer("300.300.300.300")
        }.to raise_error(HTTPServerError)
      end
    end
  end
end
