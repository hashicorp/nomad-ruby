require "open-uri"
require "singleton"
require "timeout"
require "tempfile"

module RSpec
  class NomadServer
    include Singleton

    def self.method_missing(m, *args, &block)
      self.instance.public_send(m, *args, &block)
    end

    def initialize
      return

      io = Tempfile.new("nomad-server")
      pid = Process.spawn({}, "sudo nomad agent -dev", out: io.to_i, err: io.to_i)

      at_exit do
        Process.kill("INT", pid)
        Process.waitpid2(pid)

        io.close
        io.unlink
      end

      begin
        Timeout.timeout(5) do
          begin
            open("#{address}/v1/status/leader")
          rescue Errno::ECONNREFUSED
            sleep(0.25)
            retry
          end
        end
      rescue Timeout::Error
        raise "Nomad did not start in 5 seconds!"
      end
    end

    def address
      "http://127.0.0.1:4646"
    end
  end
end
