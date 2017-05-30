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

Development
-----------
1. Clone the project on GitHub
2. Create a feature branch
3. Submit a Pull Request

Important Notes:

- **All new features must include test coverage.** At a bare minimum, Unit tests are required. It is preferred if you include acceptance tests as well.
- **The tests must be be idempotent.** The HTTP calls made during a test should be able to be run over and over.
- **Tests are order independent.** The default RSpec configuration randomizes the test order, so this should not be a problem.
- **Integration tests require Nomad**  Nomad must be available in the path for the integration tests to pass.
