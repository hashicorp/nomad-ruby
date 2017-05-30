require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {Status} methods.
    # @return [Status]
    def status
      @status ||= Status.new(self)
    end
  end

  class Status < Request
    # Get the address and port of the current leader for this region
    #
    # @example
    #   Nomad.status.leader #=> "1.2.3.4:4647"
    #
    # @option [String] :region
    #   the region to query (by default, the region of the agent is queried)
    #
    # @return [String]
    def leader(options = {})
      return client.get("/v1/status/leader", options)
    end

    # Get the set of raft peers in the region.
    #
    # @example
    #   Nomad.status.peers #=> ["1.2.3.4:4647", "5.6.7.8:4647"]
    #
    # @option [String] :region
    #   the region to query (by default, the region of the agent is queried)
    #
    # @return [Array<String>]
    def peers(options = [])
      return client.get("/v1/status/peers", options)
    end
  end
end
