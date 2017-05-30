require "spec_helper"

module Nomad
  describe System do
    subject { nomad_test_client.system }

    describe "#gc" do
      it "forces a GC run" do
        expect(subject.gc).to be(true)
      end
    end

    describe "#reconcile_summaries" do
      it "reconciles peers" do
        expect(subject.reconcile_summaries).to be(true)
      end
    end
  end
end
