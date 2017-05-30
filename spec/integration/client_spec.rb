require "spec_helper"

module Nomad
  describe Client do
    describe "#request" do
      it "raises HTTPConnectionError if it takes too long to read packets from the connection" do
        TCPServer.open('localhost', 0) do |server|
          Thread.new do
            loop do
              client = server.accept
              sleep 0.25
              client.close
            end
          end

          address = "http://%s:%s" % ["localhost", server.addr[1]]

          client = described_class.new(address: address, read_timeout: 0.01)

          expect {
            client.request(:get, "/", {}, {})
          }.to raise_error(HTTPConnectionError)

          server.close
        end
      end

      it "raises HTTPConnectionError if the port on the remote server is not open" do
        address = "http://%s:%s" % free_address

        client = described_class.new(address: address)

        expect { client.request(:get, "/", {}, {}) }.to raise_error(HTTPConnectionError)
      end
    end
  end
end
