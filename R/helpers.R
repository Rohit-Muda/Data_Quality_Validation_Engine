# helpers.R
# Small, reusable UI-building helpers shared between ui.R and server.R.
#   make_bar()       — renders one penalty bar in the score card
#   metric_row()     — renders one labelled metric row in a report card
#   render_metrics() — builds the full metric list for a before/after card
# Called by: server.R (output$score_ui, output$metrics_before, output$metrics_after)
# ----------------------------------------------------------------------------

# Penalty progress bar
make_bar <- function(label, penalty, max_pen) {
  pct <- round(penalty / max_pen * 100)
  div(class = "bar-row",
      div(class = "bar-label",
          span(label),
          span(sprintf("−%.1f pts", penalty))
      ),
      div(class = "bar-track",
          div(class = "bar-fill",
              style = sprintf("width:%d%%; background-position: -%dpx 0;",
                              pct, round((1 - pct / 100) * 100)))
      )
  )
}

# Single metric row (label + coloured value)
metric_row <- function(label, value, cls = "ok") {
  div(class = "metric-row",
      span(class = "metric-label", label),
      span(class = paste("metric-val", cls), value)
  )
}

# Full metric list for one before/after card
render_metrics <- function(audit, score_obj) {
  vc <- function(v) if (v == 0) "ok" else if (v < 5) "warn" else "bad"

  tagList(
    metric_row("Score",
               sprintf("%.1f / 100", score_obj$score),
               if (score_obj$score >= 80) "ok" else if (score_obj$score >= 50) "warn" else "bad"),
    metric_row("Total rows",        as.character(audit$n_rows),         "ok"),
    metric_row("Total columns",     as.character(audit$n_cols),         "ok"),
    metric_row("Missing cells (%)", sprintf("%.2f%%", audit$missing_total), vc(audit$missing_total)),
    metric_row("Exact duplicates",  as.character(audit$exact_dup),      vc(audit$exact_dup)),
    metric_row("Outlier cells",     as.character(audit$outliers),
               if (audit$outliers == 0) "ok" else if (audit$outliers < 10) "warn" else "bad"),
    metric_row("Invalid emails",    as.character(audit$invalid_email),  vc(audit$invalid_email)),
    metric_row("Invalid phones",    as.character(audit$invalid_phone),  vc(audit$invalid_phone)),
    metric_row("Entropy stability", sprintf("%.3f", score_obj$entropy_val),
               if (score_obj$entropy_val >= 0.7) "ok" else if (score_obj$entropy_val >= 0.4) "warn" else "bad"),
    metric_row("Status",            score_obj$status,
               if (score_obj$status == "Approved") "ok" else if (score_obj$status == "Needs Improvement") "warn" else "bad")
  )
}
