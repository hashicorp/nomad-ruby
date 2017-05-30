$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "nomad"

require "pathname"
require "webmock/rspec"

require_relative "support/nomad_server"
require_relative "support/redirect_server"

TEST_NOMAD_VERSION = Gem::Version.new(ENV["NOMAD_VERSION"])

RSpec.configure do |config|
  # Custom helper modules and extensions

  # Prohibit using the should syntax
  config.expect_with :rspec do |spec|
    spec.syntax = :expect
  end

  # Allow tests to isolate a specific test using +focus: true+. If nothing
  # is focused, then all tests are executed.
  config.filter_run_when_matching :focus
  config.filter_run_excluding nomad: lambda { |v|
    !Gem::Requirement.new(v).satisfied_by?(TEST_NOMAD_VERSION)
  }

  # Disable real connections.
  config.before(:suite) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  # Ensure our configuration is reset on each run.
  config.before(:each) { Nomad.setup! }
  config.after(:each)  { Nomad.setup! }

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

def tmp
  Pathname.new(File.expand_path("../tmp", __FILE__))
end

def nomad_test_client
  Nomad::Client.new(
    address: RSpec::NomadServer.address,
  )
end

def free_address
  server = TCPServer.new("localhost", 0)
  address = ["localhost", server.addr[1]]
  server.close
  address
end

def with_stubbed_env(env = {})
  old = ENV.to_hash
  env.each do |k,v|
    if v.nil?
      ENV.delete(k.to_s)
    else
      ENV[k.to_s] = v.to_s
    end
  end
  yield
ensure
  ENV.replace(old)
end
