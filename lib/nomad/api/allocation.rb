require "cgi"

require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {Allocation} methods.
    # @return [Allocation]
    def allocation
      @allocation ||= Allocation.new(self)
    end
  end

  class Allocation < Request
    # List allocations.
    #
    # @param options [String] :prefix An optional prefix to filter
    #
    # @return [Array<Alloc>]
    def list(**options)
      json = client.get("/v1/allocations", options)
      return json.map { |item| Alloc.decode(item) }
    end

    # Read a specific allocation.
    #
    # @param [String] id The full ID of the allocation to read
    #
    # @return [Alloc]
    def read(id, **options)
      json = client.get("/v1/allocation/#{CGI.escape(id)}", options)
      return Alloc.decode(json)
    end
  end

  class Alloc < Response
    # @!attribute [r] id
    #   The full allocation ID.
    #   @return [String]
    field :ID, as: :id

    # @!attribute [r] eval_id
    #   The full ID of the evaluation for this allocation.
    #   @return [String]
    field :EvalID, as: :eval_id

    # @!attribute [r] name
    #   The name of the job/allocation.
    #   @return [String]
    field :Name, as: :name

    # @!attribute [r] node_id
    #   The full ID of the node for this allocation.
    #   @return [String]
    field :NodeID, as: :node_id

    # @!attribute [r] job_id
    #   The name of the job for this allocation.
    #   @return [String]
    field :JobID, as: :job_id

    # @!attribute [r] job
    #   The full JSON definition of the job.
    #   @return [Hash]
    field :Job, as: :job

    # @!attribute [r] task_group
    #   The task group for this allocation.
    #   @return [String]
    field :task_group, as: :task_group

    # @!attribute [r] resources
    #   The resources for this allocation.
    #   @return [String]
    field :Resources, as: :resources

    # @!attribute [r] shared_resources
    #   The shared resources for this allocation.
    #   @return [String]
    field :SharedResources, as: :shared_resources

    # @!attribute [r] task_resources
    #   The task resources for this allocation.
    #   @return [String]
    field :TaskResources, as: :task_resources

    # @!attribute [r] metrics
    #   The metrics for this allocation.
    #   @return [String]
    field :Metrics, as: :metrics

    # @!attribute [r] desired_status
    #   The desired allocation status.
    #   @return [String]
    field :DesiredStatus, as: :desired_status

    # @!attribute [r] desired_description
    #   The desired allocation description.
    #   @return [String]
    field :DesiredDescription, as: :desired_description, load: :string_as_nil

    # @!attribute [r] client_status
    #   The client allocation status.
    #   @return [String]
    field :ClientStatus, as: :client_status

    # @!attribute [r] client_description
    #   The client allocation description.
    #   @return [String]
    field :ClientDescription, as: :client_description

    # @!attribute [r] task_states
    #   TODO
    #   @return [String]
    field :TaskStates, as: :task_states

    # @!attribute [r] previous_allocation
    #   The previous allocation ID.
    #   @return [String]
    field :PreviousAllocation, as: :previous_allocation, load: :string_as_nil

    # @!attribute [r] create_index
    #   The create index
    #   @return [Integer]
    field :CreateIndex, as: :create_index

    # @!attribute [r] modify_index
    #   The modify index
    #   @return [Integer]
    field :ModifyIndex, as: :modify_index

    # @!attribute [r] alloc_modify_index
    #   The allocation modify index.
    #   @return [Integer]
    field :AllocModifyIndex, as: :alloc_modify_index

    # @!attribute [r] create_time
    #   The time the allocation was created
    #   @return [DateTime]
    field :CreateTime, as: :create_time, load: :date_as_timestamp
  end
end
