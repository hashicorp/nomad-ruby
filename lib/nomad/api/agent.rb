require_relative "../client"
require_relative "../request"
require_relative "../stringify"

module Nomad
  class Client
    # A proxy to the {Agent} methods.
    # @return [Agent]
    def agent
      @agent ||= Agent.new(self)
    end
  end

  class Agent < Request
    # Join a new member to the gossip pool.
    #
    # @example
    #   Nomad.agent.join("1.2.3.4", "5.6.7.8") #=> #<AgentJoin...>
    #
    # @param [String] address the addresses of the agents to join - this may
    #   be specified multiple times.
    #
    # @return [AgentJoin]
    def join(*addresses, **options)
      raise "Missing address(es)!" if addresses.empty?
      qs = addresses.map { |v| "address=#{CGI.escape(v)}" }.join("&")[/.+/]
      json = client.post("/v1/agent/join?#{qs}", options)
      return AgentJoin.decode(json)
    end

    # Force a node to leave the gossip pool.
    #
    # @example
    #   Nomad.agent.force_leave("client-ab2e23dc")
    #
    # @overload force_leave(node, ...)
    #   @param [String] node A node ID to remove
    #   @param [String] ... Additional nodes to remove
    #   @return [Boolean]
    def force_leave(*nodes, **options)
      raise "Missing node(s)!" if nodes.empty?
      qs = nodes.map { |v| "node=#{CGI.escape(v)}" }.join("&")[/.+/]
      client.post("/v1/agent/force-leave?#{qs}", options)
      return true
    end

    # Get the list of known agent names.
    #
    # @example
    #   Nomad.agent.members #=> ["region1", "region2"]
    #
    # @return [AgentMembers]
    def members(options = {})
      json = client.get("/v1/agent/members", options)
      return AgentMembers.decode(json)
    end

    # Get information about the current agent (self).
    #
    # @example
    #   Nomad.agent.self #=> TODO
    #
    # @return [Agent]
    def self(options = {})
      json = client.get("/v1/agent/self", options)
      return AgentSelf.decode(json)
    end

    # Get the list of servers.
    #
    # @example
    #   Nomad.agent.servers #=> ["127.0.0.1:4647", "..."]
    def servers(options = {})
      return client.get("/v1/agent/servers", options)
    end

    # Updates the list of servers.
    #
    # @example
    #   Nomad.agent.update_servers(addresses: ["1.2.3.4:4647"])
    #
    # @return [Boolean]
    def update_servers(*addresses, **options)
      raise "Missing address(es)!" if addresses.empty?
      qs = addresses.map { |v| "address=#{CGI.escape(v)}" }.join("&")[/.+/]
      client.post("/v1/agent/servers?#{qs}", options)
      return true
    end
  end

  class AgentSelf < Response
    # @!attribute [r] config
    #   The agent configuration. This has preset fields, but they change based
    #   on different versions of Nomad, so this returns a Hash instead.
    #   @return [Hash<String,Object>]
    field :config, load: :stringify_keys

    # @!attribute [r] member
    #   The agent member information
    #   @return [AgentMember]
    field :member, load: ->(item) { AgentMember.decode(item) }

    # @!attribute [r] stats
    #   The agent configuration
    #   @return [Hash<String,Hash<String,String>>]
    field :stats, load: :stringify_keys
  end

  class AgentMembers < Response
    # @!attribute [r] server_name
    #   The name of this agent being queried
    #   @return [String]
    field :ServerName, as: :server_name

    # @!attribute [r] server_region
    #   The region of the agent being queried
    #   @return [String]
    field :ServerRegion, as: :server_region

    # @!attribute [r] server_datacenter
    #   The datacenter of the server being queried
    #   @return [String]
    field :ServerDC, as: :server_datacenter

    # @!attribute [r] members
    #   The list of known peer members
    #   @return [Array<AgentMember>]
    field :Members, as: :members, load: ->(item) {
      Array(item).map { |i| AgentMember.decode(i) }
    }
  end

  class AgentMember < Response
    # The text for an "alive" member
    STATUS_ALIVE = "alive".freeze

    # @!attribute [r] name
    #   The name of the member
    #   @return [String]
    field :Name, as: :name

    # @!attribute [r] address
    #   The address of the member
    #   @return [String]
    field :Addr, as: :address

    # @!attribute [r] port
    #   The rpc port of the member
    #   @return [Integer]
    field :Port, as: :port

    # @!attribute [r] tags
    #   The tags of the member (arbitary)
    #   @return [Hash<String,String>]
    field :Tags, as: :tags, load: :stringify_keys

    # @!attribute [r] status
    #   The status
    #   @return [String]
    field :Status, as: :status

    # @!attribute [r] protocol_min
    #   The protocol_min
    #   @return [Integer]
    field :ProtocolMin, as: :protocol_min

    # @!attribute [r] protocol_max
    #   The protocol_max
    #   @return [Integer]
    field :ProtocolMax, as: :protocol_max

    # @!attribute [r] protocol_cur
    #   The protocol_cur
    #   @return [Integer]
    field :ProtocolCur, as: :protocol_cur

    # @!attribute [r] delegate_min
    #   The delegate_min
    #   @return [Integer]
    field :DelegateMin, as: :delegate_min

    # @!attribute [r] delegate_max
    #   The delegate_max
    #   @return [Integer]
    field :DelegateMax, as: :delegate_max

    # @!attribute [r] delegate_cur
    #   The delegate_cur
    #   @return [Integer]
    field :DelegateCur, as: :delegate_cur

    # Determines if this member is alive.
    #
    # @return [Boolean]
    def alive?
      self.status == STATUS_ALIVE
    end
  end

  class AgentJoin < Response
    # @!attribute [r] error
    #   The agent configuration
    #   @return [String]
    field :error, load: :string_as_nil

    # @!attribute [r] num_joined
    #   The agent configuration
    #   @return [Integer]
    field :num_joined
  end
end
