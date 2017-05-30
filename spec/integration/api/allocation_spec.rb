require "spec_helper"

module Nomad
  describe Allocation do
    subject { nomad_test_client.allocation }

    before(:context) {
      jobfile = File.read(File.expand_path("../../../support/jobs/job.json", __FILE__))
      nomad_test_client.post("/v1/jobs", jobfile)
    }

    describe "#list" do
      it "lists all allocations" do
        result = subject.list
        expect(result).to be_a(Array)
        expect(result.size).to be >= 1
        expect(result[0]).to be_a(Alloc)
      end

      it "filters on prefix" do
        list = subject.list
        alloc_id = list.first.id.split("-", 2)[0]
        result = subject.list(prefix: alloc_id)
        expect(result[0]).to be_a(Alloc)
        expect(result).to include(list[0])
      end
    end

    describe "#read" do
      it "reads a specific allocation" do
        list = subject.list
        id = list[0].id
        result = subject.read(id)
        expect(result).to be
        expect(result.id).to eq(id)
      end
    end
  end
end
