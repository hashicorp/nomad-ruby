require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {Node} methods.
    # @return [Node]
    def node
      @node ||= Node.new(self)
    end
  end

  class Node < Request
    # Get the address and port of the current leader for this region
    #
    # @example
    #   Nomad.node.list #=> [#<Node ...>]
    #
    # @option [String] :prefix
    #   an optional prefix to filter nodes
    #
    # @return [String]
    def list(**options)
      json = client.get("/v1/nodes", options)
      return json.map { |item| NodeItem.decode(item) }
    end

    # Get detailed information about the node.
    #
    # @param [String] node_id The ID of the ndoe
    #
    # @example
    #   Nomad.node.read("abcd1234") #=> #<Node ...>
    #
    # @return [NodeItem, nil]
    def read(node_id, **options)
      json = client.get("/v1/node/#{CGI.escape(node_id)}", options)
      return NodeItem.decode(json)
    rescue Nomad::HTTPError => e
      # This is really jank, but Nomad doesn't return a 404 and returns a 500
      # instead, so we have to inspect the output.
      if e.errors.any? { |err| err.include?("node lookup failed") }
        return nil
      else
        raise
      end
    end

    # Create a new evaluation for the given node.
    #
    # @example
    #   Nomad.node.evaluate("abcd1234")
    #
    # @param [String] node_id The ID of the node
    #
    # @return [NodeEvaluation]
    def evaluate(node_id, **options)
      json = client.post("/v1/node/#{CGI.escape(node_id)}/evaluate", options)
      return NodeEvaluation.decode(json)
    end

    # Toggle drain mode for the node.
    #
    # @example
    #   Nomad.node.drain("abcd1234", true) #=> #<NodeEvaluation ...>
    #   Nomad.node.drain("abcd1234", false)
    #
    # @param [String] node_id The node ID to drain
    # @param [Boolean] enable whether to enable or disable drain mode
    #
    # @return [NodeEvaluation]
    def drain(node_id, enable = true, **options)
      url = "/v1/node/#{CGI.escape(node_id)}/drain?enable=#{enable}"
      json = client.post(url, options)
      return NodeEvaluation.decode(json)
    end
  end

  class NodeItem < Response
    STATUS_READY = "ready"

    # @!attribute [r] id
    #   The node ID.
    #   @return [String]
    field :ID, as: :id

    # @!attribute [r] secret_id
    #   The node secret_id.
    #   @return [String]
    field :SecretID, as: :secret_id, load: :string_as_nil

    # @!attribute [r] datacenter
    #   The node datacenter.
    #   @return [String]
    field :Datacenter, as: :datacenter

    # @!attribute [r] name
    #   The node name.
    #   @return [String]
    field :Name, as: :name

    # @!attribute [r] http_addr
    #   The node http_addr.
    #   @return [String]
    field :HTTPAddr, as: :http_addr

    # @!attribute [r] tls_enabled
    #   The node tls_enabled.
    #   @return [Boolean]
    field :TLSEnabled, as: :tls_enabled

    # @!attribute [r] attributes
    #   The node attributes.
    #   @return [Hash<String,String>]
    field :Attributes, as: :attributes, load: :stringify_keys

    # @!attribute [r] resources
    #   The node resources.
    #   @return [Resources]
    field :Resources, as: :resources, load: ->(item) { Resources.decode(item) }

    # @!attribute [r] reserved
    #   The node reserved.
    #   @return [String]
    field :Reserved, as: :reserved, load: ->(item) { Resources.decode(item) }

    # @!attribute [r] links
    #   The node links.
    #   @return [Hash<String,String>]
    field :Links, as: :links, load: :stringify_keys

    # @!attribute [r] meta
    #   The node meta.
    #   @return [Hash<String,String>]
    field :Meta, as: :meta, load: :stringify_keys

    # @!attribute [r] node_class
    #   The node node_class.
    #   @return [String]
    field :NodeClass, as: :node_class, load: :string_as_nil

    # @!attribute [r] computed_class
    #   The node computed_class.
    #   @return [String]
    field :ComputedClass, as: :computed_class, load: :string_as_nil

    # @!attribute [r] drain
    #   The node drain
    #   @return [Boolean]
    field :Drain, as: :drain

    # @!attribute [r] status
    #   The node status.
    #   @return [String]
    field :Status, as: :status

    # @!attribute [r] status_description
    #   The evaluation status_description.
    #   @return [String]
    field :StatusDescription, as: :status_description, load: :string_as_nil

    # @!attribute [r] status_updated_at
    #   The node status_updated_at.
    #   @return [Time]
    field :StatusUpdatedAt, as: :status_updated_at, load: :date_as_timestamp

    # @!attribute [r] create_index
    #   The evaluation create_index.
    #   @return [Fixnum]
    field :CreateIndex, as: :create_index

    # @!attribute [r] modify_index
    #   The evaluation modify_index.
    #   @return [Fixnum]
    field :ModifyIndex, as: :modify_index

    # Determines if the ndoe is ready.
    # @return [Boolean]
    def ready?
      self.status == STATUS_READY
    end
  end

  class Resources < Response
    # @!attribute [r] cpu
    #   The node cpu.
    #   @return [Fixnum]
    field :CPU, as: :cpu

    # @!attribute [r] memory
    #   The node memory.
    #   @return [Size]
    field :MemoryMB, as: :memory, load: :int_as_size_in_megabytes

    # @!attribute [r] disk
    #   The node disk.
    #   @return [Size]
    field :DiskMB, as: :disk, load: :int_as_size_in_megabytes

    # @!attribute [r] iops
    #   The node iops.
    #   @return [Fixnum]
    field :IOPS, as: :iops

    # @!attribute [r] networks
    #   The node networks.
    #   @return [Array<Network>]
    field :Networks, as: :networks, load: ->(items) {
      Array(items).map { |i| Network.decode(i) }
    }
  end

  class Network < Response
    # @!attribute [r] device
    #   The network device.
    #   @return [String]
    field :Device, as: :device, load: :string_as_nil

    # @!attribute [r] cidr
    #   The network cidr.
    #   @return [String]
    field :CIDR, as: :cidr, load: :string_as_nil

    # @!attribute [r] ip
    #   The network ip.
    #   @return [String]
    field :IP, as: :ip, load: :string_as_nil

    # @!attribute [r] megabits
    #   The network megabits.
    #   @return [Fixnum]
    field :MBits, as: :megabits, load: :int_as_size_in_megabits

    # @!attribute [r] reserved_ports
    #   The network reserved_ports.
    #   @return [Array<Port>]
    field :ReservedPorts, as: :reserved_ports, load: ->(items) {
      Array(items).map { |i| Port.decode(i) }
    }

    # @!attribute [r] dynamic_ports
    #   The network dynamic_ports.
    #   @return [Array<Port>]
    field :DynamicPorts, as: :dynamic_ports, load: ->(items) {
      Array(items).map { |i| Port.decode(i) }
    }
  end

  class Port < Response
    # @!attribute [r] label
    #   The port label.
    #   @return [String]
    field :Label, as: :label

    # @!attribute [r] value
    #   The port value.
    #   @return [Fixnum]
    field :Value, as: :value
  end

  class NodeEvaluation < Response
    # @!attribute [r] heartbeat_ttl
    #   The evaluation heartbeat_ttl.
    #   @return [Fixnum]
    field :HeartbeatTTL, as: :heartbeat_ttl

    # @!attribute [r] eval_ids
    #   The evaluation ids.
    #   @return [Array<String>]
    field :EvalIDs, as: :eval_ids, load: :nil_as_array

    # @!attribute [r] eval_create_index
    #   The evaluation eval_create_index.
    #   @return [Fixnum]
    field :EvalCreateIndex, as: :eval_create_index

    # @!attribute [r] node_modify_index
    #   The evaluation node_modify_index.
    #   @return [Fixnum]
    field :NodeModifyIndex, as: :node_modify_index

    # @!attribute [r] leader_rpc_addr
    #   The evaluation leader_rpc_addr.
    #   @return [String]
    field :LeaderRPCAddr, as: :leader_rpc_addr

    # @!attribute [r] num_nodes
    #   The evaluation num_nodes.
    #   @return [Fixnum]
    field :NumNodes, as: :num_nodes

    # @!attribute [r] servers
    #   The evaluation servers.
    #   @return [Array<Server>]
    field :Servers, as: :servers, load: ->(items) {
      Array(items).map { |i| Server.decode(i) }
    }

    # @!attribute [r] index
    #   The evaluation index.
    #   @return [Fixnum]
    field :Index, as: :index

    # @!attribute [r] last_contact
    #   The evaluation last_contact.
    #   @return [Fixnum]
    field :LastContact, as: :last_contact

    # @!attribute [r] known_leader
    #   The evaluation known_leader.
    #   @return [Boolean]
    field :KnownLeader, as: :known_leader
  end

  class Server < Response
    # @!attribute [r] rpc_advertise_addr
    #   The evaluation rpc_advertise_addr.
    #   @return [String]
    field :RPCAdvertiseAddr, as: :rpc_advertise_addr

    # @!attribute [r] rpc_major_version
    #   The evaluation rpc_major_version.
    #   @return [Fixnum]
    field :RPCMajorVersion, as: :rpc_major_version

    # @!attribute [r] rpc_minor_version
    #   The evaluation rpc_minor_version.
    #   @return [Fixnum]
    field :RPCMinorVersion, as: :rpc_minor_version

    # @!attribute [r] datacenter
    #   The evaluation datacenter.
    #   @return [String]
    field :Datacenter, as: :datacenter
  end
end
