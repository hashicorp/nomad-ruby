module Nomad
  class NomadError < RuntimeError; end

  class HTTPConnectionError < NomadError
    attr_reader :address

    def initialize(address, exception)
      @address = address
      @exception = exception

      super <<-EOH
The Nomad server at `#{address}' is not currently
accepting connections. Please ensure that the server is running and that your
authentication information is correct.

The original error was `#{exception.class}'. Additional information (if any) is
shown below:

    #{exception.message}

Please refer to the documentation for more help.
EOH
    end

    def original_exception
      @exception
    end
  end

  class HTTPError < NomadError
    attr_reader :address, :response, :code, :errors

    def initialize(address, response, errors = [])
      @address, @response, @errors = address, response, errors
      @code  = response.code.to_i
      errors = errors.map { |error| "  * #{error}" }

      super <<-EOH
The Nomad server at `#{address}' responded with a #{code}.
Any additional information the server supplied is shown below:

#{errors.join("\n").rstrip}

Please refer to the documentation for help.
EOH
    end
  end

  class HTTPClientError < HTTPError; end
  class HTTPServerError < HTTPError; end
end
