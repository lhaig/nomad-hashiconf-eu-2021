job "example" {
  datacenters = ["tpi-dc1"]
  ## Run in the QA environments
  namespace = "web-qa"
  type = "service"
  group "cache" {
    count = 6
    network {
      port "db" {
        to = 6379
      }
    }
    task "redis" {
      driver = "docker"
      config {
        image = "redis:3.2"
        ports = ["db"]
      }
      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
