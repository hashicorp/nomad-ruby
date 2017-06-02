require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {Operator} methods.
    # @return [Operator]
    def operator
      @operator ||= Operator.new(self)
    end
  end

  class Operator < Request
    # Queries the status of a nodes registered with Nomad in the Raft subsystem.
    #
    # @example
    #   Nomad.operator.raft_configuration #=> #<Operator::Raft::Configuration>
    #
    # @option [String] :region
    #   the region to query (by default, the region of the agent is queried)
    # @option [Boolean] :stale
    #   allow reading stale queries if there is no leader
    #
    # @return [Operator::Raft::Configuration]
    def raft_configuration(**options)
      json = client.get("/v1/operator/raft/configuration", options)
      return RaftConfiguration.decode(json)
    end

    # Queries the status of a nodes registered with Nomad in the Raft subsystem.
    #
    # @example
    #   Nomad.operator.remove_raft_peer("1.2.3.4") #=> true
    #
    # @param [String] address the address of the peer to remove
    #
    # @option [String] :region
    #   the region to query (by default, the region of the agent is queried)
    # @option [Boolean] :stale
    #   allow reading stale queries if there is no leader
    #
    # @return [Operator::Raft::Configuration]
    def remove_raft_peer(*addresses, **options)
      raise "Missing address(es)!" if addresses.empty?
      qs = addresses.map { |v| "address=#{CGI.escape(v)}" }.join("&")[/.+/]
      client.delete("/v1/operator/raft/peer?#{qs}", options)
      return true
    end

    class RaftConfiguration < Response
      # @!attribute [r] index
      #   The current raft index
      #   @return [Fixnum]
      field :Index, as: :index

      # @!attribute [r] servers
      #   The list of servers
      #   @return [Array<ConfigurationItem>]
      field :Servers, as: :servers, load: ->(item) {
        Array(item).map { |i| RaftConfigurationItem.decode(i) }
      }
    end

    class RaftConfigurationItem < Response
      # @!attribute [r] id
      #   The ID of the server. This may be the same as the address or a UUID,
      #   depending on the version of Nomad.
      #   @return [String]
      field :ID, as: :id

      # @!attribute [r] node
      #   The node name of the server, as known to Nomad. This will be
      #   "(unknown)" if the node is stale.
      #   @return [String]
      field :Node, as: :node

      # @!attribute [r] address
      #   The IP:Port of the server
      #   @return [String]
      field :Address, as: :address

      # @!attribute [r] leader
      #   Determines if this server is a leader in the raft subsystem.
      #   @return [Boolean]
      field :Leader, as: :leader

      # @!attribute [r] voter
      #   Indicates if the server has a vote in the raft configuration.
      #   @return [Boolean]
      field :Voter, as: :voter
    end
  end
end
