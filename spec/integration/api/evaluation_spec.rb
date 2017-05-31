require "spec_helper"

module Nomad
  describe Evaluation do
    subject { nomad_test_client.evaluation }

    before(:context) {
      jobfile = File.read(File.expand_path("../../../support/jobs/job.json", __FILE__))
      nomad_test_client.post("/v1/jobs", jobfile)
    }

    describe "#list" do
      it "lists all evaluations" do
        result = subject.list
        expect(result).to be_a(Array)
        expect(result.size).to be >= 1
        expect(result[0]).to be_a(Eval)
      end

      it "filters on prefix" do
        list = subject.list
        eval_id = list.first.id.split("-", 2)[0]
        result = subject.list(prefix: eval_id)
        expect(result[0]).to be_a(Eval)
        expect(result).to include(list[0])
      end
    end

    describe "#read" do
      it "reads a specific evaluation" do
        list = subject.list
        id = list[0].id
        result = subject.read(id)
        expect(result).to be
        expect(result.id).to eq(id)
      end
    end
  end
end
