require "spec_helper"

module Nomad
  describe Validate do
    subject { nomad_test_client.validate }

    describe "#job" do
      it "validates a good job" do
        jobfile = File.read(File.expand_path("../../../support/jobs/job.json", __FILE__))
        result = subject.job(jobfile)
        expect(result.error).to be(nil)
        expect(result.validation_errors.size).to eq(0)
        expect(result.errored?).to be(false)
      end

      it "validates a bad job" do
        jobfile = File.read(File.expand_path("../../../support/jobs/bad.json", __FILE__))
        result = subject.job(jobfile)
        expect(result.error).to match("Missing")
        expect(result.validation_errors.size).to be > 0
        expect(result.errored?).to be(true)
      end
    end
  end
end
