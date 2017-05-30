require "spec_helper"

module Nomad
  describe Region do
    subject { nomad_test_client.region }

    describe "#all" do
      it "returns all regions" do
        expect(subject.list).to include("global")
      end
    end
  end
end
