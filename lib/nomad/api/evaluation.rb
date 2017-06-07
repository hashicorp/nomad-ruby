require "cgi"

require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {Evaluation} methods.
    # @return [Evaluation]
    def evaluation
      @evaluation ||= Evaluation.new(self)
    end
  end

  class Evaluation < Request
    # List allocations.
    #
    # @param options [String] :prefix An optional prefix to filter
    #
    # @return [Array<Eval>]
    def list(**options)
      json = client.get("/v1/evaluations", options)
      return json.map { |item| Eval.decode(item) }
    end

    # Read a specific evaluation.
    #
    # @param [String] id The full ID of the evaluation to read
    #
    # @return [Eval]
    def read(id, **options)
      json = client.get("/v1/evaluation/#{CGI.escape(id)}", options)
      return Eval.decode(json)
    end

    # Get the list of allocations for the given evaluation.
    #
    # @param [String] id The full ID of the evaluation to get allocations
    #
    # @return [Array<Alloc>]
    def allocations_for(id, **options)
      json = client.get("/v1/evaluation/#{CGI.escape(id)}/allocations", options)
      return json.map { |item| Alloc.decode(item) }
    end
  end

  class Eval < Response
    # The status for a completed job.
    STATUS_COMPLETE = "complete".freeze

    # @!attribute [r] id
    #   The evaluation id.
    #   @return [String]
    field :ID, as: :id

    # @!attribute [r] priority
    #   The evaluation priority.
    #   @return [Integer]
    field :Priority, as: :priority

    # @!attribute [r] type
    #   The evaluation type.
    #   @return [String]
    field :Type, as: :type

    # @!attribute [r] triggered_by
    #   The evaluation triggered_by.
    #   @return [String]
    field :TriggeredBy, as: :triggered_by, load: :string_as_nil

    # @!attribute [r] job_id
    #   The evaluation job_id.
    #   @return [String]
    field :JobID, as: :job_id

    # @!attribute [r] job_modify_index
    #   The evaluation job_modify_index.
    #   @return [Integer]
    field :JobModifyIndex, as: :job_modify_index

    # @!attribute [r] node_id
    #   The evaluation node_id.
    #   @return [String]
    field :NodeID, as: :node_id, load: :string_as_nil

    # @!attribute [r] node_modify_index
    #   The evaluation node_modify_index.
    #   @return [String]
    field :NodeModifyIndex, as: :node_modify_index

    # @!attribute [r] status
    #   The evaluation status.
    #   @return [String]
    field :Status, as: :status

    # @!attribute [r] status_description
    #   The evaluation status_description.
    #   @return [String]
    field :StatusDescription, as: :status_description, load: :string_as_nil

    # @!attribute [r] wait
    #   The evaluation wait.
    #   @return [Duration]
    field :Wait, as: :wait, load: :nanoseconds_as_duration

    # @!attribute [r] next_eval
    #   The evaluation next_eval.
    #   @return [String]
    field :NextEval, as: :next_eval, load: :string_as_nil

    # @!attribute [r] previous_eval
    #   The evaluation previous_eval.
    #   @return [String]
    field :PreviousEval, as: :previous_eval, load: :string_as_nil

    # @!attribute [r] blocked_eval
    #   The evaluation blocked_eval.
    #   @return [String]
    field :BlockedEval, as: :blocked_eval, load: :string_as_nil

    # @!attribute [r] failed_tg_allocs
    #   The evaluation failed_tg_allocs.
    #   @return [Hash]
    field :FailedTGAllocs, as: :failed_tg_allocs

    # @!attribute [r] class_eligibility
    #   The evaluation class_eligibility.
    #   @return [String]
    field :ClassEligibility, as: :class_eligibility

    # @!attribute [r] escaped_computed_class
    #   The evaluation escaped_computed_class.
    #   @return [Boolean]
    field :EscaledComputedClass, as: :escaped_computed_class

    # @!attribute [r] annotate_plan
    #   The evaluation annotate_plan.
    #   @return [Boolean]
    field :AnnotatePlan, as: :annotate_plan

    # @!attribute [r] snapshot_index
    #   The evaluation snapshot_index.
    #   @return [Integer]
    field :ShapshotIndex, as: :snapshot_index

    # @!attribute [r] queued_allocations
    #   The evaluation queued_allocations.
    #   @return [Hash]
    field :QueuedAllocations, as: :queued_allocations

    # @!attribute [r] create_index
    #   The evaluation create_index.
    #   @return [Integer]
    field :CreateIndex, as: :create_index

    # @!attribute [r] modify_index
    #   The evaluation modify_index.
    #   @return [Integer]
    field :ModifyIndex, as: :modify_index

    # Determines if this evaluation is done.
    #
    # @return [Boolean]
    def complete?
      self.status == STATUS_COMPLETE
    end
  end
end
