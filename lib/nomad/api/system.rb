require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {System} methods.
    # @return [System]
    def system
      @system ||= System.new(self)
    end
  end

  class System < Request
    # Initiates garbage collection of jobs, evaluations, allocations, and nodes.
    # This is an async operation that always returns true, unless an error is
    # encountered when communicating with the Nomad API.
    #
    # @example
    #   Nomad.system.gc #=> true
    #
    # @option [String] :region
    #   the region to query (by default, the region of the agent is queried)
    #
    # @return [true]
    def gc(**options)
      client.put("/v1/system/gc", options)
      return true
    end

    # Reconciles the summaries of all registered jobs.
    #
    # @example
    #   Nomad.system.reconcile_summaries #=> true
    #
    # @option [String] :region
    #   the region to query (by default, the region of the agent is queried)
    #
    # @return [true]
    def reconcile_summaries(**options)
      client.put("/v1/system/reconcile/summaries", options)
      return true
    end
  end
end
