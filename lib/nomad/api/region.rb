require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {Region} methods.
    # @return [Region]
    def region
      @region ||= Region.new(self)
    end
  end

  class Region < Request
    # Get the list of known region names.
    #
    # @example
    #   Nomad.region.list #=> ["region1", "region2"]
    #
    # @return [Array<String>]
    def list(**options)
      return client.get("/v1/regions", options)
    end
  end
end
