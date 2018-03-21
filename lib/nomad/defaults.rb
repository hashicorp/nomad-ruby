require "pathname"

module Nomad
  module Defaults
    # The default nomad address.
    # @return [String]
    NOMAD_ADDRESS = "http://127.0.0.1:4646".freeze

    # The list of SSL ciphers to allow. You should not change this value unless
    # you absolutely know what you are doing!
    # @return [String]
    SSL_CIPHERS = "TLSv1.2:!aNULL:!eNULL".freeze

    # The default number of attempts.
    # @return [Integer]
    RETRY_ATTEMPTS = 2

    # The default backoff interval.
    # @return [Integer]
    RETRY_BASE = 0.05

    # The maximum amount of time for a single exponential backoff to sleep.
    RETRY_MAX_WAIT = 2.0

    # The default size of the connection pool
    DEFAULT_POOL_SIZE = 16

    # The set of exceptions that are detect and retried by default
    # with `with_retries`
    RETRIED_EXCEPTIONS = [HTTPServerError]

    class << self
      # The list of calculated options for this configurable.
      # @return [Hash]
      def options
        Hash[*Configurable.keys.map { |key| [key, public_send(key)] }.flatten]
      end

      # The address to communicate with Nomad.
      # @return [String]
      def address
        ENV["NOMAD_ADDR"] || NOMAD_ADDRESS
      end

      def nomad_token
        ENV["NOMAD_TOKEN"]
      end

      # The SNI host to use when connecting to Nomad via TLS.
      # @return [String, nil]
      def hostname
        ENV["NOMAD_TLS_SERVER_NAME"]
      end

      # The number of seconds to wait when trying to open a connection before
      # timing out
      # @return [String, nil]
      def open_timeout
        ENV["NOMAD_OPEN_TIMEOUT"]
      end

      # The size of the connection pool to communicate with Nomad
      # @return Integer
      def pool_size
        if var = ENV["NOMAD_POOL_SIZE"]
          return var.to_i
        else
          DEFAULT_POOL_SIZE
        end
      end

      # The HTTP Proxy server address as a string
      # @return [String, nil]
      def proxy_address
        ENV["NOMAD_PROXY_ADDRESS"]
      end

      # The HTTP Proxy server username as a string
      # @return [String, nil]
      def proxy_username
        ENV["NOMAD_PROXY_USERNAME"]
      end

      # The HTTP Proxy user password as a string
      # @return [String, nil]
      def proxy_password
        ENV["NOMAD_PROXY_PASSWORD"]
      end

      # The HTTP Proxy server port as a string
      # @return [String, nil]
      def proxy_port
        ENV["NOMAD_PROXY_PORT"]
      end

      # The number of seconds to wait when reading a response before timing out
      # @return [String, nil]
      def read_timeout
        ENV["NOMAD_READ_TIMEOUT"]
      end

      # The ciphers that will be used when communicating with nomad over ssl
      # You should only change the defaults if the ciphers are not available on
      # your platform and you know what you are doing
      # @return [String]
      def ssl_ciphers
        ENV["NOMAD_SSL_CIPHERS"] || SSL_CIPHERS
      end

      # The raw contents (as a string) for the pem file. To specify the path to
      # the pem file, use {#ssl_pem_file} instead. This value is preferred over
      # the value for {#ssl_pem_file}, if set.
      # @return [String, nil]
      def ssl_pem_contents
        ENV["NOMAD_SSL_PEM_CONTENTS"]
      end

      # The path to a pem on disk to use with custom SSL verification
      # @return [String, nil]
      def ssl_pem_file
        ENV["NOMAD_SSL_CERT"] || ENV["NOMAD_SSL_PEM_FILE"]
      end

      # Passphrase to the pem file on disk to use with custom SSL verification
      # @return [String, nil]
      def ssl_pem_passphrase
        ENV["NOMAD_SSL_CERT_PASSPHRASE"]
      end

      # The path to the CA cert on disk to use for certificate verification
      # @return [String, nil]
      def ssl_ca_cert
        ENV["NOMAD_CACERT"]
      end

      # The CA cert store to use for certificate verification
      # @return [OpenSSL::X509::Store, nil]
      def ssl_cert_store
        nil
      end

      # The path to the directory on disk holding CA certs to use
      # for certificate verification
      # @return [String, nil]
      def ssl_ca_path
        ENV["NOMAD_CAPATH"]
      end

      # Verify SSL requests (default: true)
      # @return [true, false]
      def ssl_verify
        # Nomad CLI uses this envvar, so accept it by precedence
        if !ENV["NOMAD_SKIP_VERIFY"].nil?
          return false
        end

        if ENV["NOMAD_SSL_VERIFY"].nil?
          true
        else
          %w[t y].include?(ENV["NOMAD_SSL_VERIFY"].downcase[0])
        end
      end

      # The number of seconds to wait for connecting and verifying SSL
      # @return [String, nil]
      def ssl_timeout
        ENV["NOMAD_SSL_TIMEOUT"]
      end

      # A default meta-attribute to set all timeout values - individually set
      # timeout values will take precedence
      # @return [String, nil]
      def timeout
        ENV["NOMAD_TIMEOUT"]
      end
    end
  end
end
