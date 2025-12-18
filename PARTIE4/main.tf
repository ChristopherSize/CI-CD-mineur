terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "database" {
  name = "database"
}

resource "docker_volume" "mysql_data" {
  name = "mysql_data"
}

resource "docker_container" "frontend" {
  name  = "frontend_new"
  image = "christophersize/front-image-hub"
  ports {
    internal = 80
    external = 4200
  }

  depends_on = [
    docker_container.backend
  ]
}

resource "docker_container" "backend" {
  name  = "backend_new"
  image = "christophersize/api"
  env = [
    "DB_HOST=database",
    "DB_USER=test",
    "DB_PASSWORD=test",
    "DB_NAME=mangas"
  ]

  ports {
    internal = 3000
    external = 3000
  }

  networks_advanced {
    name = docker_network.database.name
  }

  depends_on = [
    docker_container.database
  ]
}

#################################
# MySQL
#################################

resource "docker_container" "database" {
  name  = "mysql_database_new"
  image = "mysql:8.0"

  env = [
    "MYSQL_ROOT_PASSWORD=myrootpassword",
    "MYSQL_DATABASE=mangas",
    "MYSQL_USER=test",
    "MYSQL_PASSWORD=test"
  ]

  ports {
    internal = 3306
    external = 3306
  }

  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }

  networks_advanced {
    name = docker_network.database.name
  }
}


resource "docker_container" "phpmyadmin" {
  name  = "phpmyadmin_new"
  image = "phpmyadmin/phpmyadmin:4.9"

  env = [
    "PMA_HOST=database",
    "PMA_USER=test",
    "PMA_PASSWORD=test"
  ]

  ports {
    internal = 80
    external = 8080
  }

  networks_advanced {
    name = docker_network.database.name
  }

  depends_on = [
    docker_container.database
  ]
}
