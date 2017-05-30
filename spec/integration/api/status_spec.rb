require "spec_helper"

module Nomad
  describe Status do
    subject { nomad_test_client.status }

    describe "#leader" do
      it "returns the leader" do
        expect(subject.leader).to eq("127.0.0.1:4647")
      end
    end

    describe "#peers" do
      it "returns the peers" do
        expect(subject.peers).to include("127.0.0.1:4647")
      end
    end
  end
end
