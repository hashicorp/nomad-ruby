require "spec_helper"

module Nomad
  describe Agent do
    subject { nomad_test_client.agent }

    describe "#join" do
      it "joins listed addresses" do
        result = subject.join("127.0.0.1")
        expect(result).to be_a(AgentJoin)
        expect(result.error).to be(nil)
        expect(result.num_joined).to eq(1)
      end

      it "returns any errors" do
        result = subject.join("300.300.300.300")
        expect(result).to be_a(AgentJoin)
        expect(result.error).to match(/Failed to resolve/)
        expect(result.num_joined).to eq(0)
      end
    end

    describe "#force_leave" do
      it "raises an error when no nodes are supplied" do
        expect {
          result = subject.force_leave
        }.to raise_error(RuntimeError)
      end

      it "removes it from the cluster" do
        skip "no easy way to test"
      end
    end

    describe "#members" do
      it "returns all members" do
        result = subject.members
        expect(result).to be_a(AgentMembers)
        expect(result.members).to be_a(Array)

        member = result.members[0]
        expect(member).to be_a(AgentMember)
        expect(member.address).to eq("127.0.0.1")
        expect(member.port).to eq(4648)
        expect(member.tags).to be_a(Hash)
        expect(member.alive?).to be(true)
      end
    end

    describe "#self" do
      it "returns information about the queried agent" do
        skip "too many fields"
      end
    end

    describe "#servers" do
      it "returns all servers" do
        result = subject.servers
        expect(result).to be_a(Array)

        server = result[0]
        expect(server).to eq("127.0.0.1:4647")
      end
    end

    describe "#update_servers" do
      it "raises an error when no addresses are supplied" do
        expect {
          subject.update_servers
        }.to raise_error(RuntimeError)
      end

      it "raises an error when addresses are empty" do
        expect {
          subject.update_servers(*[])
        }.to raise_error(RuntimeError)
      end

      it "updates the servers list" do
        subject.update_servers(
          "1.2.3.4:4647",
          "127.0.0.1:4647",
        )
        result = subject.servers.sort

        subject.update_servers("127.0.0.1:4647") # reset

        expect(result).to eq([
          "1.2.3.4:4647",
          "127.0.0.1:4647",
        ])
      end
    end
  end
end
