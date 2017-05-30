job "job" {
  type = "service"

  datacenters = ["dc1"]

  group "group" {
    task "task" {
      driver = "raw_exec"

      config {
        command = "/bin/sleep"
        args    = ["1000"]
      }
    }
  }
}
