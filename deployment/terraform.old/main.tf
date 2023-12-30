provider "google" {
  credentials = file("../../.env/credentials.json")
  project     = "playground-s-11-31b7751f"
  region      = "europe-west1"
}

resource "google_container_cluster" "my_cluster" {
  name                = "cluster-1"
  location            = "europe-west1"
  deletion_protection = false

  # master_auth {
  #   client_certificate_config = {}
  # }
  initial_node_count       = 1
  remove_default_node_pool = true

  network = "default"

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    # kubernetes_dashboard {
    #   disabled = true
    # }

    dns_cache_config {
      enabled = true
    }

    # gce_persistent_disk_csi_driver_config {
    #   enabled = true
    # }

    # gcs_fuse_csi_driver_config {
    #   enabled = true
    # }
  }

  subnetwork = "default"

  network_policy {
    enabled = true
  }

  ip_allocation_policy {
    # use_ip_aliases = true
    stack_type = "IPV4"
  }

  master_authorized_networks_config {
  }

  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  # autoscaling {
  # 
  # }

  # network_config {
  #   datapath_provider = "LEGACY_DATAPATH"
  # }

  # default_max_pods_constraint {
  #   max_pods_per_node = "110"
  # }

  # authenticator_groups_config {
  # }

  # database_encryption {
  #   state = "DECRYPTED"
  # }

  # shielded_nodes {
  #   enabled = true
  # }

  # release_channel {
  #   channel = "REGULAR"
  # }

  # notification_config {
  #   pubsub {
  #   }
  # }

  # initial_cluster_version = "1.27.3-gke.100"

  # logging_config {
  #   component_config {
  #     enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  #   }
  # }

  # monitoring_config {
  #   component_config {
  #     enable_components = ["SYSTEM_COMPONENTS"]
  #   }

  #   managed_prometheus_config {
  #     enabled = true
  #   }
  # }

  # security_posture_config {
  #   mode               = "BASIC"
  #   vulnerability_mode = "VULNERABILITY_DISABLED"
  # }
}
resource "google_container_node_pool" "np" {
  name    = "default-pool"
  cluster = google_container_cluster.my_cluster.name
  node_config {
    machine_type = "e2-micro"
    disk_size_gb = 10

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    image_type = "COS_CONTAINERD"
    disk_type  = "pd-balanced"

    shielded_instance_config {
      enable_integrity_monitoring = true
    }

  }

  initial_node_count = 1

  autoscaling {
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  network_config {
  }

  upgrade_settings {
    max_surge = 1
    strategy  = "SURGE"
  }
}

