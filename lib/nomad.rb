module Nomad
  require_relative "nomad/errors"
  require_relative "nomad/client"
  require_relative "nomad/configurable"
  require_relative "nomad/duration"
  require_relative "nomad/defaults"
  require_relative "nomad/response"
  require_relative "nomad/size"
  require_relative "nomad/version"

  require_relative "nomad/api"

  class << self
    # API client object based off the configured options in {Configurable}.
    #
    # @return [Nomad::Client]
    attr_reader :client

    def setup!
      @client = Nomad::Client.new

      # Set secure SSL options
      OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options].tap do |opts|
        opts &= ~OpenSSL::SSL::OP_DONT_INSERT_EMPTY_FRAGMENTS if defined?(OpenSSL::SSL::OP_DONT_INSERT_EMPTY_FRAGMENTS)
        opts |= OpenSSL::SSL::OP_NO_COMPRESSION if defined?(OpenSSL::SSL::OP_NO_COMPRESSION)
        opts |= OpenSSL::SSL::OP_NO_SSLv2 if defined?(OpenSSL::SSL::OP_NO_SSLv2)
        opts |= OpenSSL::SSL::OP_NO_SSLv3 if defined?(OpenSSL::SSL::OP_NO_SSLv3)
      end

      self
    end

    # Delegate all methods to the client object, essentially making the module
    # object behave like a {Client}.
    def method_missing(m, *args, &block)
      if @client.respond_to?(m)
        @client.send(m, *args, &block)
      else
        super
      end
    end

    # Delegating +respond_to+ to the {Client}.
    def respond_to_missing?(m, include_private = false)
      @client.respond_to?(m, include_private) || super
    end
  end
end

# Load the initial default values
Nomad.setup!
