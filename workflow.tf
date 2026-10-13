# Alert triage workflow. When the error rate monitor fires, this workflow
# sends a short summary to the on-call email with the monitor name, a link
# to the monitor, and a pointer to the runbook. It does not page anyone and
# does not change anything. Triage stays a human decision.
#
# The workflow needs a registered application key. See the provider docs
# for app_key_registration. The spec shape below follows the provider's
# documented example for datadog_workflow_automation.
resource "datadog_workflow_automation" "alert_triage" {
  name        = "${var.service} alert triage (${var.env})"
  description = "Email a triage summary when the ${var.service} error monitor fires."
  tags        = ["service:${var.service}", "env:${var.env}", "team:${var.team}"]
  published   = true

  run_as = {
    type = "owner"
  }

  spec_json = jsonencode({
    triggers = [
      {
        startStepNames = ["Send_Triage_Email"]
        monitorTrigger = {}
      }
    ]
    steps = [
      {
        name     = "Send_Triage_Email"
        actionId = "com.datadoghq.email.send"
        parameters = [
          {
            name  = "to"
            value = var.triage_email
          },
          {
            name  = "subject"
            value = "Triage: monitor \"{{ Source.monitor.name }}\" alerted"
          },
          {
            name  = "message"
            value = <<-EOT
              Monitor {{ Source.monitor.name }} alerted.
              Monitor link: {{ Source.url }}
              Runbook: ${var.runbook_url}
              This is a triage summary. Confirm the alert in Datadog before acting.
            EOT
          }
        ]
        display = {
          bounds = {
            x = 0
            y = 216
          }
        }
      }
    ]
    handle = "${var.service}-alert-triage"
  })
}
