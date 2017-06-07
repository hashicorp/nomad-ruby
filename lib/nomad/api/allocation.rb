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
    field :ID, as: :id, load: :string_as_nil

    # @!attribute [r] eval_id
    #   The full ID of the evaluation for this allocation.
    #   @return [String]
    field :EvalID, as: :eval_id, load: :string_as_nil

    # @!attribute [r] name
    #   The name of the job/allocation.
    #   @return [String]
    field :Name, as: :name, load: :string_as_nil

    # @!attribute [r] node_id
    #   The full ID of the node for this allocation.
    #   @return [String]
    field :NodeID, as: :node_id, load: :string_as_nil

    # @!attribute [r] job_id
    #   The name of the job for this allocation.
    #   @return [String]
    field :JobID, as: :job_id, load: :string_as_nil

    # @!attribute [r] job
    #   The full JSON definition of the job.
    #   @return [Hash]
    field :Job, as: :job, load: ->(item) { JobVersion.decode(item) }

    # @!attribute [r] task_group
    #   The task group for this allocation.
    #   @return [String]
    field :TaskGroup, as: :task_group

    # @!attribute [r] resources
    #   The resources for this allocation.
    #   @return [String]
    field :Resources, as: :resources, load: ->(item) { Resources.decode(item) }

    # @!attribute [r] shared_resources
    #   The shared_ esources for this allocation.
    #   @return [String]
    field :SharedResources, as: :shared_resources, load: ->(item) { Resources.decode(item) }

    # @!attribute [r] task_resources
    #   The task resources for this allocation.
    #   @return [Hash<String,Resources>]
    field :TaskResources, as: :task_resources, load: ->(item) {
      (item || {}).inject({}) do |h,(k,v)|
        h[k.to_s] = Resources.decode(v)
        h
      end
    }

    # @!attribute [r] metrics
    #   The metrics for this allocation.
    #   @return [String]
    field :Metrics, as: :metrics, load: ->(item) { AllocationMetric.decode(item) }

    # @!attribute [r] desired_status
    #   The desired allocation status.
    #   @return [String]
    field :DesiredStatus, as: :desired_status, load: :string_as_nil

    # @!attribute [r] desired_description
    #   The desired allocation description.
    #   @return [String]
    field :DesiredDescription, as: :desired_description, load: :string_as_nil

    # @!attribute [r] client_status
    #   The client allocation status.
    #   @return [String]
    field :ClientStatus, as: :client_status, load: :string_as_nil

    # @!attribute [r] client_description
    #   The client allocation description.
    #   @return [String]
    field :ClientDescription, as: :client_description, load: :string_as_nil

    # @!attribute [r] task_states
    #   The list of task states for this allocation.
    #   @return [Hash<String,TaskState>]
    field :TaskStates, as: :task_states, load: ->(item) {
      (item || {}).inject({}) do |h,(k,v)|
        h[k.to_s] = TaskState.decode(v)
        h
      end
    }

    # @!attribute [r] previous_allocation
    #   The previous allocation ID.
    #   @return [String]
    field :PreviousAllocation, as: :previous_allocation, load: :string_as_nil

    # @!attribute [r] deployment_id
    #   The deployment ID
    #   @return [String]
    field :DeploymentID, as: :deployment_id, load: :string_as_nil

    # @!attribute [r] deployment_status
    #   The deployment status
    #   @return [String]
    field :DeploymentStatus, as: :deployment_status, load: :string_as_nil

    # @!attribute [r] canary
    #   Whether this is a canary
    #   @return [Boolean]
    field :Canary, as: :canary

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
    #   @return [Timestamp]
    field :CreateTime, as: :create_time, load: :nanoseconds_as_timestamp
  end

  class AllocationMetric < Response
    # @!attribute [r] nodes_evaluated
    #   The number of nodes evaluated
    #   @return [Integer]
    field :NodesEvaluated, as: :nodes_evaluated

    # @!attribute [r] nodes_filtered
    #   The number of nodes filtered
    #   @return [Integer]
    field :NodesFiltered, as: :nodes_filtered

    # @!attribute [r] nodes_available
    #   The list of nodes available
    #   @return [Hash<String,Integer>]
    field :NodesAvailable, as: :nodes_available, load: :stringify_keys

    # @!attribute [r] class_filtered
    #   The list of classes filtered
    #   @return [Hash<String,Integer>]
    field :ClassFiltered, as: :class_filtered, load: :stringify_keys

    # @!attribute [r] constraint_filtered
    #   The list of constraints filtered
    #   @return [Hash<String,Integer>]
    field :ConstraintFiltered, as: :constraint_filtered, load: :stringify_keys

    # @!attribute [r] nodes_exhausted
    #   The list of nodes exhausted
    #   @return [Integer]
    field :NodesExhausted, as: :nodes_exhausted

    # @!attribute [r] class_exhausted
    #   The list of classes exhausted
    #   @return [Hash<String,Integer>]
    field :ClassExhausted, as: :class_exhausted, load: :stringify_keys

    # @!attribute [r] dimension_exhausted
    #   The list of dimensions exhausted
    #   @return [Hash<String,Integer>]
    field :DimensionExhausted, as: :dimension_exhausted, load: :stringify_keys

    # @!attribute [r] scores
    #   The list of scores
    #   @return [Hash<String,Float>]
    field :Scores, as: :scores, load: :stringify_keys

    # @!attribute [r] allocation_time
    #   The total allocation time
    #   @return [Duration]
    field :AllocationTime, as: :allocation_time, load: :nanoseconds_as_duration

    # @!attribute [r] coalesced_failures
    #   The number of coalesced failures
    #   @return [Integer]
    field :CoalescedFailures, as: :coalesced_failures
  end
end
