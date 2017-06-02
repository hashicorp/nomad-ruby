require "spec_helper"

module Nomad
  describe Job do
    subject { nomad_test_client.job }

    before(:context) {
      jobfile = File.read(File.expand_path("../../../support/jobs/job.json", __FILE__))
      nomad_test_client.post("/v1/jobs", jobfile)
    }

    describe "#list" do
      it "returns all jobs" do
        result = subject.list
        expect(result).to be
        expect(result[0].name).to eq("job")
        expect(result[0].job_summary).to be
      end
    end

    describe "#create" do
      it "creates a job" do
        job = JSON.parse(File.read(File.expand_path("../../../support/jobs/job.json", __FILE__)))
        job["ID"] = "new-job"
        job["Name"] = "new-job"
        result = subject.create(JSON.fast_generate(job))
        expect(result).to be_a(JobCreate)
      end
    end

    describe "#read" do
      it "reads a job" do
        job = subject.read("job")
        expect(job).to be_a(JobVersion)
        expect(job.all_at_once).to be(true)
        expect(job.constraints.size).to eq(0)
        expect(job.create_index).to be_a(Integer)
        expect(job.datacenters).to eq(["dc1"])
        expect(job.id).to eq("job")
        expect(job.job_modify_index).to be_a(Integer)
        expect(job.meta).to eq({"foo" => "bar"})
        expect(job.modify_index).to be_a(Integer)
        expect(job.name).to eq("job")
        expect(job.parameterized_job).to be(nil)
        expect(job.parent_id).to be(nil)
        expect(job.payload).to be(nil)
        expect(job.periodic).to be(nil)
        expect(job.region).to eq("global")
        expect(job.stable).to be(false)
        expect(job.status).to eq("running")
        expect(job.running?).to be(true)
        expect(job.status_description).to be(nil)
        expect(job.stop).to be(false)

        group = job.groups[0]
        expect(group).to be
        expect(group.constraints[0]).to be
        expect(group.constraints[0].l_target).to eq("${attr.os.signals}")
        expect(group.constraints[0].operand).to eq("set_contains")
        expect(group.constraints[0].r_target).to eq("SIGHUP")
        expect(group.count).to eq(3)
        expect(group.ephemeral_disk).to be
        expect(group.ephemeral_disk.migrate).to be(false)
        expect(group.ephemeral_disk.size).to eq(10*Size::MEGABYTE)
        expect(group.ephemeral_disk.sticky).to be(false)
        expect(group.meta).to eq({"zip" => "zap"})
        expect(group.name).to eq("group")
        expect(group.restart_policy).to be
        expect(group.restart_policy.attempts).to eq(10)
        expect(group.restart_policy.delay).to eq(25*Duration::SECOND)
        expect(group.restart_policy.interval).to eq(300*Duration::SECOND)
        expect(group.restart_policy.mode).to eq("delay")

        task = group.tasks[0]
        expect(task).to be
        expect(task.artifacts[0]).to be
        expect(task.artifacts[0].destination).to eq("local/")
        expect(task.artifacts[0].options).to eq({"checksum" => "md5:d2267250309a62b032b2b43312c81fec"})
        expect(task.artifacts[0].source).to eq("https://github.com/hashicorp/http-echo/releases/download/v0.2.3/http-echo_0.2.3_SHA256SUMS")
        expect(task.config).to eq({"args" => ["1000"], "command" => "/bin/sleep"})
        expect(task.constraints).to eq([])
        expect(task.dispatch_payload).to be(nil)
        expect(task.driver).to eq("raw_exec")
        expect(task.env).to eq({"key" => "value"})
        expect(task.kill_timeout).to eq(250*Duration::MILLI_SECOND)
        expect(task.leader).to be(false)
        expect(task.log_config.max_file_size).to eq(2*Size::MEGABYTE)
        expect(task.log_config.max_files).to eq(1)
        expect(task.meta).to eq({"zane" => "willow"})
        expect(task.name).to eq("task")

        resources = task.resources
        expect(resources).to be
        expect(resources.cpu).to eq(20)
        expect(resources.disk).to eq(0)
        expect(resources.iops).to eq(0)
        expect(resources.memory).to eq(12*Size::MEGABYTE)

        network = resources.networks[0]
        expect(network).to be
        expect(network.cidr).to be(nil)
        expect(network.device).to be(nil)
        expect(network.dynamic_ports[0].label).to eq("db")
        expect(network.dynamic_ports[0].value).to eq(0)
        expect(network.dynamic_ports[1].label).to eq("http")
        expect(network.dynamic_ports[1].value).to eq(0)
        expect(network.ip).to be(nil)
        expect(network.megabits).to eq(1*Size::MEGABIT)
        expect(network.reserved_ports).to eq([])

        service1 = task.services[0]
        expect(service1).to be
        expect(service1.name).to eq("service-1")
        expect(service1.port_label).to eq("db")
        expect(service1.tags).to eq(["tag1"])
        expect(service1.checks[0].args).to eq([])
        expect(service1.checks[0].command).to be(nil)
        expect(service1.checks[0].initial_status).to be(nil)
        expect(service1.checks[0].interval).to eq(10*Duration::SECOND)
        expect(service1.checks[0].name).to eq("alive")
        expect(service1.checks[0].path).to be(nil)
        expect(service1.checks[0].port_label).to be(nil)
        expect(service1.checks[0].protocol).to be(nil)
        expect(service1.checks[0].timeout).to eq(2*Duration::SECOND)
        expect(service1.checks[0].tls_skip_verify).to be(false)
        expect(service1.checks[0].type).to eq("tcp")
        expect(service1.checks[1].args).to eq([])
        expect(service1.checks[1].command).to be(nil)
        expect(service1.checks[1].initial_status).to be(nil)
        expect(service1.checks[1].interval).to eq(10*Duration::SECOND)
        expect(service1.checks[1].name).to eq("still-alive")
        expect(service1.checks[1].path).to eq("/")
        expect(service1.checks[1].port_label).to be(nil)
        expect(service1.checks[1].protocol).to be(nil)
        expect(service1.checks[1].timeout).to eq(2*Duration::SECOND)
        expect(service1.checks[1].tls_skip_verify).to be(false)
        expect(service1.checks[1].type).to eq("http")

        service2 = task.services[1]
        expect(service2).to be
        expect(service2.checks).to eq([])
        expect(service2.name).to eq("service-2")
        expect(service2.port_label).to eq("db")
        expect(service2.tags).to eq([])

        expect(task.templates[0].change_mode).to eq("signal")
        expect(task.templates[0].change_signal).to eq("SIGHUP")
        expect(task.templates[0].destination).to eq("local/file-1.yml")
        expect(task.templates[0].data).to eq("key: {{ key \"service/my-key\" }}")
        expect(task.templates[0].env).to be(false)
        expect(task.templates[0].left_delim).to eq("{{")
        expect(task.templates[0].permissions).to eq("0644")
        expect(task.templates[0].right_delim).to eq("}}")
        expect(task.templates[0].source).to be(nil)
        expect(task.templates[0].splay).to eq(5*Duration::SECOND)

        expect(task.templates[1].change_mode).to eq("signal")
        expect(task.templates[1].change_signal).to eq("SIGHUP")
        expect(task.templates[1].destination).to eq("local/file-2.yml")
        expect(task.templates[1].data).to be(nil)
        expect(task.templates[1].env).to be(false)
        expect(task.templates[1].left_delim).to eq("{{")
        expect(task.templates[1].permissions).to eq("0644")
        expect(task.templates[1].right_delim).to eq("}}")
        expect(task.templates[1].source).to eq("local/http-echo_0.2.3_SHA256SUMS")
        expect(task.templates[1].splay).to eq(5*Duration::SECOND)

        expect(task.user).to be(nil)
        expect(task.vault).to be(nil)

        expect(job.type).to eq("service")
        expect(job.vault_token).to be(nil)
        expect(job.version).to be_a(Integer)
      end
    end
  end
end
