provider "datadog" {
  api_key = var.api_key
  app_key = var.app_key
}

locals {
  service_filter = "service:${var.service},env:${var.env}"
}

# One dashboard per service. Three widgets answer the three questions an
# on-call engineer asks first: how slow, how broken, how saturated.
resource "datadog_dashboard" "service" {
  title        = "[${var.env}] ${var.service} overview"
  description  = "Latency, errors, and saturation for ${var.service} in ${var.env}."
  layout_type  = "ordered"
  notify_list  = []
  template_variables = [
    {
      name    = "service"
      prefix  = "service"
      default = var.service
    }
  ]

  widget {
    timeseries_definition {
      title = "Latency p50 / p95 / p99"
      request {
        q = "avg:trace.requests.latency.p50{${local.service_filter}}"
        display_type = "line"
      }
      request {
        q = "avg:trace.requests.latency.p95{${local.service_filter}}"
        display_type = "line"
      }
      request {
        q = "avg:trace.requests.latency.p99{${local.service_filter}}"
        display_type = "line"
      }
      yaxis {
        label = "seconds"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Error rate"
      request {
        q = "avg:trace.requests.errors{${local.service_filter}}.as_rate()"
        display_type = "line"
      }
      yaxis {
        label = "errors per second"
      }
    }
  }

  widget {
    toplist_definition {
      title = "Saturation: top hosts by CPU"
      request {
        q = "top(avg:system.cpu.user{${local.service_filter}} by {host}, 10, 'mean', 'desc')"
      }
    }
  }
}

# Error rate monitor. Thresholds are deliberately loose: a 5% error rate
# for 5 minutes is a real incident, not a blip.
resource "datadog_monitor" "high_error_rate" {
  name    = "[${var.env}] ${var.service} high error rate"
  type    = "metric alert"
  message = <<-EOT
    Error rate for ${var.service} in ${var.env} is above 5% for 5 minutes.
    Runbook: ${var.runbook_url}
    Team: ${var.team}
    ${var.notify_channel}
  EOT

  query = "avg(last_5m):(sum:trace.requests.errors{${local.service_filter}}.as_count() / sum:trace.requests.hits{${local.service_filter}}.as_count()) > 0.05"

  monitor_thresholds {
    critical = 0.05
    warning  = 0.02
  }

  notify_no_data    = false
  new_group_delay   = 60
  renotify_interval = 60
  tags              = ["service:${var.service}", "env:${var.env}", "team:${var.team}"]
}

# Latency monitor. p95 above 1 second for 10 minutes means users feel it.
resource "datadog_monitor" "high_latency" {
  name    = "[${var.env}] ${var.service} high latency"
  type    = "metric alert"
  message = <<-EOT
    p95 latency for ${var.service} in ${var.env} is above 1s for 10 minutes.
    Runbook: ${var.runbook_url}
    Team: ${var.team}
    ${var.notify_channel}
  EOT

  query = "avg(last_10m):avg:trace.requests.latency.p95{${local.service_filter}} > 1"

  monitor_thresholds {
    critical = 1
    warning  = 0.5
  }

  notify_no_data    = false
  new_group_delay   = 60
  renotify_interval = 60
  tags              = ["service:${var.service}", "env:${var.env}", "team:${var.team}"]
}

# SLO: 99.9% of requests succeed over a rolling 30 days. The monitor
# alerts on error ratio; the SLO is the contract the error budget tracks.
resource "datadog_service_level_objective" "availability" {
  name        = "${var.service} availability (${var.env})"
  description = "99.9% of requests succeed over 30 days."
  type        = "metric"

  query {
    numerator   = "sum:trace.requests.hits{${local.service_filter}}.as_count() - sum:trace.requests.errors{${local.service_filter}}.as_count()"
    denominator = "sum:trace.requests.hits{${local.service_filter}}.as_count()"
  }

  thresholds {
    timeframe = "30d"
    target    = 99.9
    warning   = 99.95
  }

  tags = ["service:${var.service}", "env:${var.env}", "team:${var.team}"]
}
