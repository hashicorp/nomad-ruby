require "spec_helper"

module Nomad
  describe Client do
    def redirected_client
      Nomad::Client.new(address: RSpec::RedirectServer.address)
    end

    before do
      RSpec::RedirectServer.start
    end

    describe "#request" do
      it "handles redirections properly in GET requests" do
        expect(redirected_client.get("/v1/status/leader")).to eq("127.0.0.1:4647")
      end
    end
  end
end
