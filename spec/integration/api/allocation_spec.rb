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
        expect(result.alloc_modify_index).to be_a(Integer)
        expect(result.canary).to be(false)
        expect(result).to respond_to(:client_description)
        expect(result).to respond_to(:client_status)
        expect(result.create_index).to be_a(Integer)
        expect(result.create_time).to be_a(Time)
        expect(result).to respond_to(:deployment_id)
        expect(result).to respond_to(:deployment_status)
        expect(result).to respond_to(:desired_description)
        expect(result).to respond_to(:desired_status)
        expect(result.eval_id).to be_a(String)
        expect(result.id).to eq(id)
        expect(result.job).to be_a(JobVersion)
        expect(result.job_id).to eq("job")
        expect(result.metrics.allocation_time).to be_a(Duration)
        expect(result.metrics.class_exhausted).to be_a(Hash)
        expect(result.metrics.class_filtered).to be_a(Hash)
        expect(result.metrics.coalesced_failures).to eq(0)
        expect(result.metrics.constraint_filtered).to be_a(Hash)
        expect(result.metrics.dimension_exhausted).to be_a(Hash)
        expect(result.metrics.nodes_available).to be_a(Hash)
        expect(result.metrics.nodes_evaluated).to eq(1)
        expect(result.metrics.nodes_exhausted).to eq(0)
        expect(result.metrics.nodes_filtered).to eq(0)
        expect(result.metrics.scores).to be_a(Hash)
        expect(result.modify_index).to be_a(Integer)
        expect(result.name).to include("job.group")
        expect(result.node_id).to be_a(String)
        expect(result).to respond_to(:previous_allocation)
        expect(result.resources).to be_a(Resources)
        expect(result.shared_resources).to be_a(Resources)
        expect(result.task_group).to eq("group")
        expect(result.task_resources).to be_a(Hash)
        expect(result.task_resources["task"]).to be_a(Resources)
        expect(result.task_states).to be_a(Hash)
      end
    end
  end
end
