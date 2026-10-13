output "dashboard_url" {
  description = "URL of the service dashboard."
  value       = "https://app.datadoghq.com/dashboard/${datadog_dashboard.service.id}"
}

output "error_monitor_id" {
  description = "ID of the high error rate monitor."
  value       = datadog_monitor.high_error_rate.id
}

output "latency_monitor_id" {
  description = "ID of the high latency monitor."
  value       = datadog_monitor.high_latency.id
}

output "slo_id" {
  description = "ID of the availability SLO."
  value       = datadog_service_level_objective.availability.id
}

output "workflow_id" {
  description = "ID of the alert triage workflow."
  value       = datadog_workflow_automation.alert_triage.id
}
