# Datadog Dashboards as Code

Datadog dashboards, monitors, an SLO, and one alert triage workflow, all managed with the Terraform Datadog provider. The point is that observability config gets the same treatment as app code: reviewed, versioned, and reproducible.

## What it creates

- **One service dashboard:** latency (p50/p95/p99), error rate, saturation (top hosts by CPU). The three signals an on-call engineer checks first.
- **Two monitors:** error rate above 5% for 5 minutes, p95 latency above 1s for 10 minutes. Thresholds are loose on purpose. An alert should mean something.
- **One SLO:** 99.9% of requests succeed over a rolling 30 days. The SLO is the contract; the monitors are the early warning.
- **One workflow:** when the error monitor fires, the workflow emails a triage summary with the monitor link and the runbook. It does not page anyone and does not change anything. Triage stays a human decision.

## Setup

```bash
export TF_VAR_api_key="your-datadog-api-key"
export TF_VAR_app_key="your-datadog-app-key"
terraform init
terraform plan
terraform apply
```

Keys come from environment variables. They are never committed. The workflow resource needs a registered application key; see the provider docs for `app_key_registration`.

## Variables

| Variable | Default | Notes |
| --- | --- | --- |
| `service` | `web` | Service name in tags and queries |
| `env` | `prod` | Environment tag |
| `team` | `platform` | Owning team |
| `runbook_url` | example link | Replace with your real runbook |
| `notify_channel` | `@slack-alerts` | Where monitor notifications go |
| `triage_email` | `oncall@example.com` | Where the workflow sends summaries |

## Screenshots

No screenshot is committed yet. After applying, take one from the Datadog dashboard UI and add it here.

## Notes

- The metric names (`trace.requests.latency.p95`, `trace.requests.errors`, `trace.requests.hits`) assume APM traces with those metric names. Adjust the queries to your own metric names if yours differ.
- Keep thresholds in code review. Changing an alert threshold should go through the same review as changing app code, because a noisy monitor gets ignored and a quiet one gets you paged at 3am for nothing.
- For a second service, copy this stack and change `service`. Do not add a second service to the same state file.
