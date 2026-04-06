# score.R
# Converts raw audit metrics + entropy into a 0–100 quality score.
# Penalty weights are capped so no single issue can zero the score.
#
# Penalty caps:   missing → 40 pts | duplicates → 35 | outliers → 30
#                 format  → 20 pts | entropy    → 10
#
# Status thresholds:  ≥ 80 = Approved | ≥ 50 = Needs Improvement | < 50 = Rejected
# Called by: server.R
# ----------------------------------------------------------------------------

calculate_score <- function(audit, ent_val, df) {
  n     <- nrow(df)
  cells <- n * ncol(df)

  pen_miss <- min(40, audit$missing_total * 1.2)
  pen_dup  <- min(35, audit$exact_dup / max(n, 1) * 100 * 1.0)
  pen_out  <- min(30, audit$outliers   / max(cells, 1) * 100 * 1.2)
  pen_fmt  <- min(20, (audit$invalid_email + audit$invalid_phone) / max(n, 1) * 100 * 0.4)
  pen_ent  <- min(10, (1 - ent_val) * 100 * 0.10)

  score  <- max(0, min(100, 100 - pen_miss - pen_dup - pen_out - pen_fmt - pen_ent))
  status <- if (score >= 80) "Approved" else if (score >= 50) "Needs Improvement" else "Rejected"

  list(
    score       = round(score, 1),
    status      = status,
    severity    = if (score >= 80) "Info" else if (score >= 50) "Warning" else "Critical",
    pen_miss    = round(pen_miss, 1),
    pen_dup     = round(pen_dup,  1),
    pen_out     = round(pen_out,  1),
    pen_fmt     = round(pen_fmt,  1),
    pen_ent     = round(pen_ent,  1),
    entropy_val = round(ent_val,  3)
  )
}
