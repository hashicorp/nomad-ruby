require "spec_helper"

module Nomad
  describe Node do
    subject { nomad_test_client.node }

    describe "#list" do
      it "lists nodes" do
        result = subject.list[0]
        expect(result).to be_a(NodeItem)
        expect(result.datacenter).to eq("dc1")
        expect(result.ready?).to be(true)
      end
    end

    describe "#read" do
      it "reads a node" do
        node_id = subject.list[0].id
        result = subject.read(node_id)
        expect(result).to be_a(NodeItem)
        expect(result.datacenter).to eq("dc1")
        expect(result.ready?).to be(true)
      end

      it "returns nil for a non-existent node" do
        result = subject.read("nope-not-once-never")
        expect(result).to be(nil)
      end
    end

    describe "#evaluate" do
      it "forces a new evaluation" do
        node_id = subject.list[0].id
        result = subject.evaluate(node_id)
        expect(result).to be
        expect(result.num_nodes).to eq(1)
        expect(result.servers).to be
      end
    end

    describe "#drain" do
      it "enables/disables draining" do
        node_id = subject.list[0].id
        result = subject.drain(node_id)
        expect(result).to be
        expect(result.known_leader).to be(false)
        result = subject.drain(node_id, false)
        expect(result).to be
      end
    end
  end
end
