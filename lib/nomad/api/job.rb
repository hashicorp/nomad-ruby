require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {Job} methods.
    # @return [Job]
    def job
      @job ||= Job.new(self)
    end
  end

  class Job < Request
    # Get the address and port of the current leader for this region
    #
    # @example
    #   Nomad.job.list #=> [#<JobItem ...>]
    #
    # @option [String] :prefix
    #   filter based on the given prefix
    #
    # @return [Array<JobItem>]
    def list(**options)
      json = client.get("/v1/jobs", options)
      return json.map { |item| JobItem.decode(item) }
    end

    # Create the job based on the given contents. The contents can be a string
    # or a hash.
    #
    # @param [String] contents
    #   the raw JSON contents
    # @param [Hash] contents
    #   a hash of the contents to convert to JSON
    #
    # @return [JobCreate]
    def create(contents, **options)
      body = contents.is_a?(Hash) ? JSON.fast_generate(contents) : contents
      json = client.post("/v1/jobs", body, options)
      return JobCreate.decode(json)
    end

    # Reads the job with the given name.
    #
    # @param [String] name The job name (ID).
    #
    # @return [JobVersion]
    def read(name, **options)
      json = client.get("/v1/job/#{CGI.escape(name)}", options)
      return JobVersion.decode(json)
    end
  end

  class JobItem < Response
    STATUS_RUNNING = "running".freeze

    # @!attribute [r] id
    #   The job id.
    #   @return [String]
    field :ID, as: :id, load: :string_as_nil

    # @!attribute [r] parent_id
    #   The job parent_id.
    #   @return [String]
    field :ParentID, as: :parent_id, load: :string_as_nil

    # @!attribute [r] name
    #   The job name.
    #   @return [String]
    field :Name, as: :name, load: :string_as_nil

    # @!attribute [r] type
    #   The job type.
    #   @return [String]
    field :Type, as: :type, load: :string_as_nil

    # @!attribute [r] priority
    #   The job priority.
    #   @return [Integer]
    field :Priority, as: :priority

    # @!attribute [r] periodic
    #   The job periodic.
    #   @return [Boolean]
    field :Periodic, as: :periodic

    # @!attribute [r] parameterized
    #   The job parameterized.
    #   @return [Boolean]
    field :Parameterized, as: :parameterized

    # @!attribute [r] stop
    #   The job stop.
    #   @return [Boolean]
    field :Stop, as: :stop

    # @!attribute [r] status
    #   The job status.
    #   @return [String]
    field :Status, as: :status, load: :string_as_nil

    # @!attribute [r] status_description
    #   The job status_description.
    #   @return [String]
    field :StatusDescription, as: :status_description, load: :string_as_nil

    # @!attribute [r] job_summary
    #   The job job_summary.
    #   @return [JobSummary]
    field :JobSummary, as: :job_summary, load: ->(item) { JobSummary.decode(item) }

    # @!attribute [r] create_index
    #   The job create_index.
    #   @return [Integer]
    field :CreateIndex, as: :create_index

    # @!attribute [r] modify_index
    #   The job modify_index.
    #   @return [Integer]
    field :ModifyIndex, as: :modify_index

    # @!attribute [r] job_modify_index
    #   The job job_modify_index.
    #   @return [Integer]
    field :JobModifyIndex, as: :job_modify_index

    # Determines if this job is running.
    # @return [Boolean]
    def running?
      self.status == STATUS_RUNNING
    end
  end

  class JobSummary < Response
    # @!attribute [r] job_id
    #   The job job_id.
    #   @return [String]
    field :JobID, as: :job_id, load: :string_as_nil

    # @!attribute [r] summary
    #   The job summary.
    #   @return [Hash<String, Object>]
    field :Summary, as: :summary, load: ->(item) {
      (item || {}).inject({}) do |h,(k,v)|
        h[k.to_s] = JobTaskGroupSummary.decode(v)
        h
      end
    }

    # @!attribute [r] children
    #   The job children.
    #   @return [Children]
    field :Children, as: :children, load: ->(item) { JobChildren.decode(item) }

    # @!attribute [r] create_index
    #   The job summary create_index.
    #   @return [Integer]
    field :CreateIndex, as: :create_index

    # @!attribute [r] modify_index
    #   The job summary modify_index.
    #   @return [Integer]
    field :ModifyIndex, as: :modify_index
  end

  class JobTaskGroupSummary < Response
    # @!attribute [r] queued
    #   The summary queued
    #   @return [Integer]
    field :Queued, as: :queued

    # @!attribute [r] complete
    #   The summary complete
    #   @return [Integer]
    field :Complete, as: :complete

    # @!attribute [r] failed
    #   The summary failed
    #   @return [Integer]
    field :Failed, as: :failed

    # @!attribute [r] running
    #   The summary running
    #   @return [Integer]
    field :Running, as: :running

    # @!attribute [r] starting
    #   The summary starting
    #   @return [Integer]
    field :Starting, as: :starting

    # @!attribute [r] lost
    #   The summary lost
    #   @return [Integer]
    field :Lost, as: :lost
  end

  class JobChildren < Response
    # @!attribute [r] pending
    #   The job pending.
    #   @return [Integer]
    field :Pending, as: :pending

    # @!attribute [r] running
    #   The job running.
    #   @return [Integer]
    field :Running, as: :running

    # @!attribute [r] dead
    #   The job dead.
    #   @return [Integer]
    field :Dead, as: :dead
  end

  class JobCreate < Response
    # @!attribute [r] eval_id
    #   The job eval_id.
    #   @return [String]
    field :EvalID, as: :eval_id, load: :string_as_nil

    # @!attribute [r] eval_create_index
    #   The job eval_create_index.
    #   @return [Integer]
    field :EvalCreateIndex, as: :eval_create_index

    # @!attribute [r] job_modify_index
    #   The job job_modify_index.
    #   @return [Integer]
    field :JobModifyIndex, as: :job_modify_index

    # @!attribute [r] warnings
    #   The job warnings.
    #   @return [String]
    field :Warnings, as: :warnings, load: :string_as_nil

    # @!attribute [r] index
    #   The job index.
    #   @return [Integer]
    field :Index, as: :index

    # @!attribute [r] last_contact
    #   The job last_contact.
    #   @return [Integer]
    field :LastContact, as: :last_contact

    # @!attribute [r] known_leader
    #   The job known_leader.
    #   @return [Boolean]
    field :KnownLeader, as: :known_leader
  end

  class JobVersion < Response
    STATUS_RUNNING = "running".freeze

    # @!attribute [r] stop
    #   The job stop.
    #   @return [Boolean]
    field :Stop, as: :stop

    # @!attribute [r] id
    #   The job id.
    #   @return [String]
    field :ID, as: :id, load: :string_as_nil

    # @!attribute [r] parent_id
    #   The job parent_id.
    #   @return [String]
    field :ParentID, as: :parent_id, load: :string_as_nil

    # @!attribute [r] name
    #   The job name.
    #   @return [String]
    field :Name, as: :name, load: :string_as_nil

    # @!attribute [r] type
    #   The job type.
    #   @return [String]
    field :Type, as: :type, load: :string_as_nil

    # @!attribute [r] priority
    #   The job priority.
    #   @return [Integer]
    field :Priority, as: :priority

    # @!attribute [r] all_at_once
    #   The job all_at_once.
    #   @return [Boolean]
    field :AllAtOnce, as: :all_at_once

    # @!attribute [r] region
    #   The job region.
    #   @return [String]
    field :Region, as: :region, load: :string_as_nil

    # @!attribute [r] datacenters
    #   The job datacenters.
    #   @return [Array<String>]
    field :Datacenters, as: :datacenters, load: :array_of_strings

    # @!attribute [r] constraints
    #   The job constraints.
    #   @return [Array<JobConstraint>]
    field :Constraints, as: :constraints, load: ->(item) {
      Array(item).map { |i| JobConstraint.decode(i) }
    }

    # @!attribute [r] groups
    #   The job groups.
    #   @return [Array<JobTaskGroup>]
    field :TaskGroups, as: :groups, load: ->(item) {
      Array(item).map { |i| JobTaskGroup.decode(i) }
    }

    # @!attribute [r] periodic
    #   The job periodic.
    #   @return [JobPeriodic]
    field :Periodic, as: :periodic, load: ->(item) { JobPeriodic.decode(item) }

    # @!attribute [r] parameterized_job
    #   The job parameterized_job.
    #   @return [String]
    field :ParameterizedJob, as: :parameterized_job, load: ->(item) { JobParameterizedJob.decode(item) }

    # @!attribute [r] payload_raw
    #   The job payload_raw.
    #   @return [String]
    field :Payload, as: :payload_raw

    # @!attribute [r] meta
    #   The job meta.
    #   @return [Hash<String,String>]
    field :Meta, as: :meta, load: :stringify_keys

    # @!attribute [r] vault_token
    #   The job vault_token.
    #   @return [String]
    field :VaultToken, as: :vault_token, load: :string_as_nil

    # @!attribute [r] stable
    #   The job stable.
    #   @return [Boolean]
    field :Stable, as: :stable

    # @!attribute [r] status
    #   The job status.
    #   @return [String]
    field :Status, as: :status, load: :string_as_nil

    # @!attribute [r] status_description
    #   The job status_description.
    #   @return [String]
    field :StatusDescription, as: :status_description, load: :string_as_nil

    # @!attribute [r] version
    #   The job version.
    #   @return [Integer]
    field :Version, as: :version

    # @!attribute [r] create_index
    #   The job create_index.
    #   @return [Integer]
    field :CreateIndex, as: :create_index

    # @!attribute [r] modify_index
    #   The job modify_index.
    #   @return [Integer]
    field :ModifyIndex, as: :modify_index

    # @!attribute [r] job_modify_index
    #   The job job_modify_index.
    #   @return [Integer]
    field :JobModifyIndex, as: :job_modify_index

    # Determines if this job is running.
    # @return [Boolean]
    def running?
      self.status == STATUS_RUNNING
    end

    # The base64-decoded payload
    # @return [String]
    def payload
      return nil if self.payload_raw.nil?
      Base64.decode64(self.payload_raw)
    end
  end

  class JobConstraint < Response
    # @!attribute [r] l_target
    #   The job l_target.
    #   @return [String]
    field :LTarget, as: :l_target

    # @!attribute [r] r_target
    #   The job r_target.
    #   @return [String]
    field :RTarget, as: :r_target

    # @!attribute [r] operand
    #   The job operand.
    #   @return [String]
    field :Operand, as: :operand
  end

  class JobTaskGroup < Response
    # @!attribute [r] name
    #   The group name.
    #   @return [String]
    field :Name, as: :name, load: :string_as_nil

    # @!attribute [r] count
    #   The group count.
    #   @return [Integer]
    field :Count, as: :count

    # @!attribute [r] constraints
    #   The group constraints.
    #   @return [Array<JobConstraint>]
    field :Constraints, as: :constraints, load: ->(item) {
      Array(item).map { |i| JobConstraint.decode(i) }
    }

    # @!attribute [r] tasks
    #   The group tasks.
    #   @return [Array<JobTask>]
    field :Tasks, as: :tasks, load: ->(item) {
      Array(item).map { |i| JobTask.decode(i) }
    }

    # @!attribute [r] restart_policy
    #   The group restart_policy.
    #   @return [JobRestartPolicy]
    field :RestartPolicy, as: :restart_policy, load: ->(item) { JobRestartPolicy.decode(item) }

    # @!attribute [r] ephemeral_disk
    #   The group ephemeral_disk.
    #   @return [JobEphemeralDisk]
    field :EphemeralDisk, as: :ephemeral_disk, load: ->(item) { JobEphemeralDisk.decode(item) }

    # @!attribute [r] update
    #   The group update.
    #   @return [JobUpdate]
    field :Update, as: :update, load: ->(item) { JobUpdate.decode(item) }

    # @!attribute [r] meta
    #   The group meta.
    #   @return [Hash<String,String>]
    field :Meta, as: :meta, load: :stringify_keys
  end

  class JobUpdate < Response
    # @!attribute [r] stagger
    #   The job stagger.
    #   @return [Duration]
    field :Stagger, as: :stagger, load: :nanoseconds_as_duration

    # @!attribute [r] max_parallel
    #   The job max_parallel.
    #   @return [Integer]
    field :MaxParallel, as: :max_parallel

    # @!attribute [r] health_check
    #   The job health_check.
    #   @return [String]
    field :HealthCheck, as: :health_check, load: :string_as_nil

    # @!attribute [r] min_healthy_time
    #   The job min_healthy_time.
    #   @return [Duration]
    field :MinHealthyTime, as: :min_healthy_time, load: :nanoseconds_as_duration

    # @!attribute [r] healthy_deadline
    #   The job healthy_deadline.
    #   @return [Duration]
    field :HealthyDeadline, as: :healthy_deadline, load: :nanoseconds_as_duration

    # @!attribute [r] auto_revert
    #   The job auto_revert.
    #   @return [Boolean]
    field :AutoRevert, as: :auto_revert

    # @!attribute [r] canary
    #   The job canary.
    #   @return [Integer]
    field :Canary, as: :canary
  end

  class JobPeriodic < Response
    # @!attribute [r] enabled
    #   The periodic enabled.
    #   @return [Boolean]
    field :Enabled, as: :enabled

    # @!attribute [r] spec
    #   The periodic spec.
    #   @return [String]
    field :Spec, as: :spec

    # @!attribute [r] spec_type
    #   The periodic spec_type.
    #   @return [String]
    field :SpecType, as: :spec_type

    # @!attribute [r] prohibit_overlap
    #   The periodic prohibit_overlap.
    #   @return [Boolean]
    field :ProhibitOverlap, as: :prohibit_overlap

    # @!attribute [r] timezone
    #   The periodic timezone.
    #   @return [String]
    field :TimeZone, as: :timezone
  end

  class JobParameterizedJob < Response
    PAYLOAD_REQUIRED = "required".freeze
    PAYLOAD_OPTIONAL = "optional".freeze
    PAYLOAD_NONE     = "none".freeze

    # @!attribute [r] payload
    #   The parameterized payload type.
    #   @return [String]
    field :Payload, as: :payload

    # @!attribute [r] meta_required
    #   The parameterized meta_required.
    #   @return [Array<String>]
    field :MetaRequired, as: :meta_required, load: :array_of_strings

    # @!attribute [r] meta_optional
    #   The parameterized meta_optional.
    #   @return [Array<String>]
    field :MetaOptional, as: :meta_optional, load: :array_of_strings

    # Determines if the payload is required.
    # @return [Boolean]
    def payload_required?
      self.payload == PAYLOAD_REQUIRED
    end

    # Determines if the payload is optional
    # @return [Boolean]
    def payload_optional?
      self.payload == PAYLOAD_OPTIONAL
    end

    # Determines if the payload is none
    # @return [Boolean]
    def payload_none?
      self.payload == PAYLOAD_NONE
    end
  end

  class JobRestartPolicy < Response
    # @!attribute [r] attempts
    #   The retry attempts.
    #   @return [Integer]
    field :Attempts, as: :attempts

    # @!attribute [r] interval
    #   The retry interval in nanoseconds.
    #   @return [Duration]
    field :Interval, as: :interval, load: :nanoseconds_as_duration

    # @!attribute [r] delay
    #   The retry delay in nanoseconds.
    #   @return [Duration]
    field :Delay, as: :delay, load: :nanoseconds_as_duration

    # @!attribute [r] mode
    #   The retry mode.
    #   @return [String]
    field :Mode, as: :mode, load: :string_as_nil
  end

  class JobEphemeralDisk < Response
    # @!attribute [r] sticky
    #   The ephemeral disk sticky.
    #   @return [Boolean]
    field :Sticky, as: :sticky

    # @!attribute [r] size
    #   The ephemeral disk size in MB.
    #   @return [Size]
    field :SizeMB, as: :size, load: :int_as_size_in_megabytes

    # @!attribute [r] migrate
    #   The ephemeral disk migrate.
    #   @return [Boolean]
    field :Migrate, as: :migrate
  end

  class JobTask < Response
    # @!attribute [r] name
    #   The task name.
    #   @return [String]
    field :Name, as: :name, load: :string_as_nil

    # @!attribute [r] driver
    #   The task driver.
    #   @return [String]
    field :Driver, as: :driver, load: :string_as_nil

    # @!attribute [r] user
    #   The task user.
    #   @return [String]
    field :User, as: :user, load: :string_as_nil

    # @!attribute [r] config
    #   The task config.
    #   @return [Hash<String,Object>]
    field :Config, as: :config, load: :stringify_keys

    # @!attribute [r] constraints
    #   The job constraints.
    #   @return [Array<JobConstraint>]
    field :Constraints, as: :constraints, load: ->(item) {
      Array(item).map { |i| JobConstraint.decode(i) }
    }

    # @!attribute [r] env
    #   The task env.
    #   @return [Hash<String,String>]
    field :Env, as: :env, load: :stringify_keys

    # @!attribute [r] services
    #   The job services.
    #   @return [Array<JobConstraint>]
    field :Services, as: :services, load: ->(item) {
      Array(item).map { |i| JobService.decode(i) }
    }

    # @!attribute [r] resources
    #   The task resources.
    #   @return [JobResources]
    field :Resources, as: :resources, load: ->(item) { Resources.decode(item) }

    # @!attribute [r] meta
    #   The task meta.
    #   @return [Hash<String,String>]
    field :Meta, as: :meta, load: :stringify_keys

    # @!attribute [r] kill_timeout
    #   The task kill_timeout.
    #   @return [Duration]
    field :KillTimeout, as: :kill_timeout, load: :nanoseconds_as_duration

    # @!attribute [r] log_config
    #   The task log_config.
    #   @return [JobLogConfig]
    field :LogConfig, as: :log_config, load: ->(item) { JobLogConfig.decode(item) }

    # @!attribute [r] artifacts
    #   The task artifacts.
    #   @return [Array<JobArtifact>]
    field :Artifacts, as: :artifacts, load: ->(item) {
      Array(item).map { |i| JobArtifact.decode(i) }
    }

    # @!attribute [r] vault
    #   The task vault configuration.
    #   @return [JobVault]
    field :Vault, as: :vault, load: ->(item) { JobVault.decode(item) }

    # @!attribute [r] templates
    #   The task templates.
    #   @return [Array<JobTemplate>]
    field :Templates, as: :templates, load: ->(item) {
      Array(item).map { |i| JobTemplate.decode(i) }
    }

    # @!attribute [r] dispatch_payload
    #   The template dispatch_payload.
    #   @return [String]
    field :DispatchPayload, as: :dispatch_payload, load: ->(item) { JobDispatchPayload.decode(item) }

    # @!attribute [r] leader
    #   The task leader.
    #   @return [Boolean]
    field :Leader, as: :leader
  end

  class JobLogConfig < Response
    # @!attribute [r] max_files
    #   The log config max_files.
    #   @return [Integer]
    field :MaxFiles, as: :max_files

    # @!attribute [r] max_file_size
    #   The log config max_file_size.
    #   @return [Size]
    field :MaxFileSizeMB, as: :max_file_size, load: :int_as_size_in_megabytes
  end

  class JobService < Response
    # @!attribute [r] name
    #   The service name.
    #   @return [String]
    field :Name, as: :name, load: :string_as_nil

    # @!attribute [r] tags
    #   The service tags.
    #   @return [Array<String>]
    field :Tags, as: :tags, load: :array_of_strings

    # @!attribute [r] port_label
    #   The service port_label.
    #   @return [String]
    field :PortLabel, as: :port_label, load: :string_as_nil

    # @!attribute [r] checks
    #   The service checks.
    #   @return [Array<JobServiceCheck>]
    field :Checks, as: :checks, load: ->(item) {
      Array(item).map { |i| JobServiceCheck.decode(i) }
    }
  end

  class JobServiceCheck < Response
    # @!attribute [r] name
    #   The check name.
    #   @return [String]
    field :Name, as: :name, load: :string_as_nil

    # @!attribute [r] type
    #   The check type.
    #   @return [String]
    field :Type, as: :type, load: :string_as_nil

    # @!attribute [r] command
    #   The check command.
    #   @return [String]
    field :Command, as: :command, load: :string_as_nil

    # @!attribute [r] args
    #   The check args.
    #   @return [String]
    field :Args, as: :args, load: :array_of_strings

    # @!attribute [r] path
    #   The check path.
    #   @return [String]
    field :Path, as: :path, load: :string_as_nil

    # @!attribute [r] protocol
    #   The check protocol.
    #   @return [String]
    field :Protocol, as: :protocol, load: :string_as_nil

    # @!attribute [r] port_label
    #   The check port_label.
    #   @return [String]
    field :PortLabel, as: :port_label, load: :string_as_nil

    # @!attribute [r] interval
    #   The check interval.
    #   @return [Duration]
    field :Interval, as: :interval, load: :nanoseconds_as_duration

    # @!attribute [r] timeout
    #   The check timeout.
    #   @return [Duration]
    field :Timeout, as: :timeout, load: :nanoseconds_as_duration

    # @!attribute [r] initial_status
    #   The check initial_status.
    #   @return [String]
    field :InitialStatus, as: :initial_status, load: :string_as_nil

    # @!attribute [r] tls_skip_verify
    #   The check tls_skip_verify.
    #   @return [Boolean]
    field :TLSSkipVerify, as: :tls_skip_verify
  end

  class JobArtifact < Response
    # @!attribute [r] source
    #   The task source.
    #   @return [String]
    field :GetterSource, as: :source, load: :string_as_nil

    # @!attribute [r] options
    #   The task options.
    #   @return [Hash<String,String>]
    field :GetterOptions, as: :options, load: :stringify_keys

    # @!attribute [r] destination
    #   The task destination.
    #   @return [String]
    field :RelativeDest, as: :destination, load: :string_as_nil
  end

  class JobVault < Response
    # @!attribute [r] policies
    #   The vault policies.
    #   @return [Array<String>]
    field :Policies, as: :policies, load: :array_of_strings

    # @!attribute [r] env
    #   The vault env.
    #   @return [Boolean]
    field :Env, as: :env

    # @!attribute [r] change_mode
    #   The vault change_mode.
    #   @return [String]
    field :ChangeMode, as: :change_mode, load: :string_as_nil

    # @!attribute [r] change_signal
    #   The vault change_signal.
    #   @return [String]
    field :ChangeSignal, as: :change_signal, load: :string_as_nil
  end

  class JobTemplate < Response
    # @!attribute [r] source
    #   The template source.
    #   @return [String]
    field :SourcePath, as: :source, load: :string_as_nil

    # @!attribute [r] destination
    #   The template destination.
    #   @return [String]
    field :DestPath, as: :destination, load: :string_as_nil

    # @!attribute [r] data
    #   The raw template data (will be nil if a path is given instead).
    #   @return [String]
    field :EmbeddedTmpl, as: :data, load: :string_as_nil

    # @!attribute [r] change_mode
    #   The template change_mode.
    #   @return [String]
    field :ChangeMode, as: :change_mode, load: :string_as_nil

    # @!attribute [r] change_signal
    #   The template change_signal.
    #   @return [String]
    field :ChangeSignal, as: :change_signal, load: :string_as_nil

    # @!attribute [r] splay
    #   The template splay.
    #   @return [Duration]
    field :Splay, as: :splay, load: :nanoseconds_as_duration

    # @!attribute [r] permissions
    #   The template permissions.
    #   @return [String]
    field :Perms, as: :permissions, load: :string_as_nil

    # @!attribute [r] left_delim
    #   The template left_delim.
    #   @return [String]
    field :LeftDelim, as: :left_delim, load: :string_as_nil

    # @!attribute [r] right_delim
    #   The template right_delim.
    #   @return [String]
    field :RightDelim, as: :right_delim, load: :string_as_nil

    # @!attribute [r] env
    #   The template env.
    #   @return [Boolean]
    field :Envvars, as: :env
  end

  class JobDispatchPayload < Response
    # @!attribute [r] file
    #   The dispatch payload file.
    #   @return [String]
    field :File, as: :file, load: :string_as_nil
  end
end
