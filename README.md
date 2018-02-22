# Nomad Ruby Client

Nomad Ruby is the official Ruby client for interacting with [Nomad](https://www.nomadproject.io) by HashiCorp.

**The documentation in this README corresponds to the master branch of the Nomad Ruby client. It may contain unreleased features or different APIs than the most recently released version. Please see the Git tag that corresponds to your version of the Nomad Ruby client for the proper documentation.**

## Quick Start

Install Ruby 2.4+: [Guide](https://www.ruby-lang.org/en/documentation/installation/).

Install via Rubygems:

```
$ gem install nomad
```

or add it to your Gemfile if you're using Bundler:

```ruby
gem "nomad", "~> 0.1"
```

and then run the `bundle` command to install.

Connect to a Nomad API using ```Nomad::Client```. For most API calls, it does not matter if you are connecting to a client or server node. In general, try to connect to the node with the lowest latency.

List all jobs in the system

```ruby
Nomad.job.list
#=> []
```

Join the agent being queried to another agent

```ruby
Nomad.agent.join("1.2.3.4")
#=> #<Nomad::AgentJoin:0x007fc40f9f60c0 @error=nil, @num_joined=1>
```

Create (run) a job (this must be a JSON job definition, not HCL)

```ruby
Nomad.job.create(File.read("my-job.nomad"))
#=> #<Nomad::JobCreate:0x007fc40f9ac8a8
 @eval_create_index=11,
 @eval_id="7bd1a289-06b4-fc4a-5574-940ca4af6a8e",
 @index=11,
 @job_modify_index=10,
 @known_leader=true,
 @last_contact=0,
 @warnings=nil>
```

For more examples, return types, and possible errors, please see the
[YardDoc][yarddoc].

## Internals & Normalization

Because Nomad's API is in active development, there are some inconsistencies in
API responses. This client attempts to normalize those responses as best as
possible. This includes providing utility classes for sizes, speed, and time
that does conversion automatically.

#### `Nomad::Duration`

The `Nomad::Duration` class provides convenience functions for converting
timestamps to different orders of magnitude.

```ruby
evals = Nomad.evaluation.list
dur = evals[0].wait

dur
#=> #<Nomad::Duration:0x7fc4109d07e8 @duration="12s">

dur.seconds #=> 12.0
dur.milliseconds #=> 12_000.0
dur.days #=> 0.0001388888888888889
```

For more information and examples, see the [YardDoc][yarddoc].

### `Nomad::Size`

The `Nomad::Size` is used to covert metric sizes based on prefix, such as
converting 1GB to MB.

```ruby
job = Nomad.job.read("my-job")
disk = job.groups[0].ephemeral_disk

disk.size #=> #<Nomad::Size:0x7fc41213d340 @size="10MB">
disk.size.gigabytes #=> 0.01
```

For more information and examples, see the [YardDoc][yarddoc].

## Development

1. Clone the project on GitHub
2. Create a feature branch
3. Submit a Pull Request

Important Notes:

- **All new features must include test coverage.** At a bare minimum, Unit tests are required. It is preferred if you include acceptance tests as well.
- **The tests must be be idempotent.** The HTTP calls made during a test should be able to be run over and over.
- **Tests are order independent.** The default RSpec configuration randomizes the test order, so this should not be a problem.
- **Integration tests require Nomad**  Nomad must be available in the path for the integration tests to pass.

### How To Run The Tests

```
$ bundle install
$ bundle exec rake
```

### How To Get Started

First make sure you have a running Nomad cluster to be able to work against. The [Nomad README](https://github.com/hashicorp/nomad#developing-nomad) describes how to quickly get up and running with a Nomad node running in dev mode (this mean the single node is operating as both a Nomad server and client node).

Once that's running, you can establish a connection by simply loading ```lib/nomad.rb```:

```$ pry
[1] pry(main)> load './lib/nomad.rb'
=> true
[2] pry(main)> Nomad.client
=> #<Nomad::Client:0x00007f8baeba8330
 @address="http://127.0.0.1:4646",
 @connection=#<Net::HTTP 127.0.0.1:4646 open=false>,
 @hostname=nil,
 @open_timeout=nil,
 @pool_size=16,
 @proxy_address=nil,
 @proxy_password=nil,
 @proxy_port=nil,
 @proxy_username=nil,
 @read_timeout=nil,
 @ssl_ca_cert=nil,
 @ssl_ca_path=nil,
 @ssl_cert_store=nil,
 @ssl_ciphers="TLSv1.2:!aNULL:!eNULL",
 @ssl_pem_contents=nil,
 @ssl_pem_file=nil,
 @ssl_pem_passphrase=nil,
 @ssl_timeout=nil,
 @ssl_verify=true,
 @timeout=nil>
```

If you ran the example Nomad job as described in the Nomad README, you should be able to see it in the jobs list:

```
[3] pry(main)> Nomad.job.list
=> [#<Nomad::JobItem:0x00007f8baeb12218
  @create_index=8,
  @id="example",
  @job_modify_index=8,
  @job_summary=
   #<Nomad::JobSummary:0x00007f8baeb11c78
    @children=#<Nomad::JobChildren:0x00007f8baeb11a98 @dead=0, @pending=0, @running=0>,
    @create_index=8,
    @job_id="example",
    @modify_index=12,
    @summary={"cache"=>#<Nomad::JobTaskGroupSummary:0x00007f8baeb11520 @complete=0, @failed=0, @lost=0, @queued=3, @running=0, @starting=0>}>,
  @modify_index=8,
  @name="example",
  @parameterized=nil,
  @parent_id=nil,
  @periodic=false,
  @priority=50,
  @status="pending",
  @status_description=nil,
  @stop=false,
  @type="service">]
  ```



[yarddoc]: http://www.rubydoc.info/github/hashicorp/nomad-ruby
