provider "google" {
  project = "tactile-rigging-276418"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_instance" "poc" {
  name         = "tf-poc"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}

resource "google_bigquery_dataset" "public" {
  dataset_id                  = "public"
  friendly_name               = "test"
  description                 = "This dataset is public"
  location                    = "EU"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }

  access {
    role          = "OWNER"
    user_by_email = google_service_account.bqowner.email
  }

  #access {
  #  role   = "READER"
  #  domain = "hashicorp.com"
  #}
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "private"
  friendly_name               = "test"
  description                 = "This dataset is private"
  location                    = "EU"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }

  access {
    role          = "OWNER"
    user_by_email = google_service_account.bqowner.email
  }

  #access {
  #  role   = "READER"
  #  domain = "hashicorp.com"
  #}

  access {
    dataset {
      dataset {
        project_id = google_bigquery_dataset.public.project
        dataset_id = google_bigquery_dataset.public.dataset_id
      }
      target_types = ["VIEWS"]
    }
  }
}

resource "google_service_account" "bqowner" {
  account_id = "bqowner"
}

resource "google_storage_bucket" "airflow" {
  name          = "airflow-data-poc"
  location      = "US"

  uniform_bucket_level_access = true
}
