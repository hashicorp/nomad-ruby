require "spec_helper"

module Nomad
  describe Client do
    # TODO

    # def redirected_client
    #   Nomad::Client.new(address: RSpec::RedirectServer.address)
    # end
    #
    # before do
    #   RSpec::RedirectServer.start
    # end
    #
    # describe "#request" do
    #   it "handles redirections properly in GET requests" do
    #     expect(redirected_client.get("/v1/sys/policy")[:policies]).to include('root')
    #   end
    #
    #   it "handles redirections properly in PUT requests" do
    #     redirected_client.put("/v1/secret/redirect", { works: true }.to_json)
    #     expect(nomad_test_client.logical.read('secret/redirect').data[:works]).to eq(true)
    #   end
    #
    #   it "handles redirections properly in DELETE requests" do
    #     nomad_test_client.logical.write('secret/redirect', { deleted: false })
    #     redirected_client.delete("/v1/secret/redirect")
    #     expect(nomad_test_client.logical.read('secret/redirect')).to be_nil
    #   end
    #
    #   it "handles redirections properly in POST requests" do
    #     data = redirected_client.post("/v1/auth/token/create", "{}")
    #     expect(data).to include(:auth)
    #   end
    # end
  end
end
