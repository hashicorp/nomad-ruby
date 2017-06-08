require "webrick"
require "uri"

module RSpec
  class RedirectServer < WEBrick::HTTPServlet::AbstractServlet
    def service(req, res)
      res["Location"] = File.join(NomadServer.address, req.path)
      raise WEBrick::HTTPStatus[307]
    end

    def self.address
      'http://127.0.0.1:6789/'
    end

    def self.start
      @server ||= begin
        server = WEBrick::HTTPServer.new(
          Port: 6789,
          Logger: WEBrick::Log.new(File.open(File::NULL, "w")),
          AccessLog: [],
        )
        server.mount "/", self
        at_exit { server.shutdown }
        Thread.new { server.start }
        server
      end
    end
  end
end
