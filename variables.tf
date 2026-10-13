variable "api_key" {
  description = "Datadog API key. Set via TF_VAR_api_key or a tfvars file, never in code."
  type        = string
  sensitive   = true
}

variable "app_key" {
  description = "Datadog application key. Set via TF_VAR_app_key or a tfvars file, never in code."
  type        = string
  sensitive   = true
}

variable "service" {
  description = "Service name used in dashboard and monitor tags."
  type        = string
  default     = "web"
}

variable "env" {
  description = "Environment tag, for example prod or staging."
  type        = string
  default     = "prod"
}

variable "team" {
  description = "Team that owns the service. Used in tags and monitor messages."
  type        = string
  default     = "platform"
}

variable "runbook_url" {
  description = "URL of the runbook linked from monitor notifications."
  type        = string
  default     = "https://example.com/runbooks/web-high-errors"
}

variable "notify_channel" {
  description = "Notification handle for monitors, for example @slack-alerts or an email."
  type        = string
  default     = "@slack-alerts"
}

variable "triage_email" {
  description = "Email address the triage workflow sends alert summaries to."
  type        = string
  default     = "oncall@example.com"
}
