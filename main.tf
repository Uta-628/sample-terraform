provider "google" {
  region  = "us-west1"
  zone    = "us-west1-a"
}

# task1
resource "google_storage_bucket" "bucket" {
    name = "qwiklabs-gcp-02-945fd0f769eb-bucket"
    location = "US-WEST1"
}
# task2
resource "google_pubsub_topic" "example" {
  name = "topic-memories-281"
  message_retention_duration = "86600s"
}
# task3
resource "google_service_account" "cloud_run_service_account" {
  account_id   = "cloud-run-service-account"
  display_name = "Cloud Run Service Account"
}

resource "google_cloudfunctions2_function" "memories_thumbnail_maker" {
  name        = "memories-thumbnail-maker"
  location      = "us-west1"
  build_config {
    runtime = "nodejs16"
    entry_point = "memories-thumbnail-maker"

    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        # todo: setup zip code
        # zip source.zip index.js package.json
        object = "source.zip" 
      }
    }
  }

  service_config {
    available_memory = "256M"
    timeout_seconds  = 60

    ingress_settings = "ALLOW_ALL"
  }

  event_trigger {
    event_type = "google.cloud.storage.object.v1.finalized"
    event_filters {
      attribute = "bucket"
      value = google_storage_bucket.bucket.name
    }
  }
}
