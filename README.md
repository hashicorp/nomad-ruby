# Nomad Ruby Client

Nomad Ruby is the official Ruby client for interacting with [Nomad](https://www.nomadproject.io) by HashiCorp.

**The documentation in this README corresponds to the master branch of the Nomad Ruby client. It may contain unreleased features or different APIs than the most recently released version. Please see the Git tag that corresponds to your version of the Nomad Ruby client for the proper documentation.**

## Quick Start

Install Ruby 2.0+: [Guide](https://www.ruby-lang.org/en/documentation/installation/).

Install via Rubygems:

```
$ gem install nomad
```

or add it to your Gemfile if you're using Bundler:

```ruby
gem "nomad", "~> 0.1"
```

and then run the `bundle` command to install.

Connect to a Nomad API. For most API calls, it does not matter if you are
connecting to a client or server node. In general, try to connect to the node
with the lowest latency.

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

[yarddoc]: http://www.rubydoc.info/github/hashicorp/nomad-ruby
