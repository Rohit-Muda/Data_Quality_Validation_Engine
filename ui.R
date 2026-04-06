# ui.R
# Defines the full page layout for DataSeal.
# All styling is inline via tags$style(); no external CSS file needed.
# Depends on: helpers.R (auto-sourced from R/ by Shiny before this file loads)
# ----------------------------------------------------------------------------

library(shiny)

ui <- fluidPage(
  tags$head(
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "stylesheet",
              href = "https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=DM+Mono:wght@400;500&display=swap"),
    tags$style(HTML("
      *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

      body {
        font-family: 'DM Sans', sans-serif;
        background: #111318;
        color: #dde3ee;
        min-height: 100vh;
        font-size: 15px;
      }

      /* ── Top bar ── */
      .topbar {
        background: #181c27;
        border-bottom: 1px solid #23293a;
        padding: 20px 36px;
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 32px;
      }
      .topbar-icon {
        width: 42px; height: 42px;
        background: #2563eb;
        border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        font-size: 20px; flex-shrink: 0;
      }
      .topbar h1 {
        font-size: 1.4rem; font-weight: 700; color: #f0f4ff;
        letter-spacing: -0.02em; line-height: 1.2;
      }
      .topbar p {
        font-size: 0.88rem; color: #6b7a99; margin-top: 2px;
      }

      /* ── Layout ── */
      .main-wrap { padding: 0 32px 48px; max-width: 1280px; margin: 0 auto; }

      /* ── Sidebar ── */
      .sidebar {
        background: #181c27;
        border: 1px solid #23293a;
        border-radius: 12px;
        padding: 24px 20px;
      }
      .sidebar h3 {
        font-size: 0.7rem; font-weight: 700; text-transform: uppercase;
        letter-spacing: 0.1em; color: #2563eb; margin-bottom: 20px;
      }

      /* ── Steps ── */
      .step-label {
        font-size: 0.72rem; font-weight: 700; text-transform: uppercase;
        letter-spacing: 0.08em; color: #4b5a7a; margin: 20px 0 8px;
      }
      .step-label:first-of-type { margin-top: 0; }
      .form-group { margin-bottom: 0 !important; }

      .form-control, input[type=file] {
        background: #111318 !important;
        border: 1px solid #2a3149 !important;
        border-radius: 8px !important;
        color: #dde3ee !important;
        font-family: 'DM Sans', sans-serif;
        font-size: 0.9rem !important;
      }

      /* ── Buttons ── */
      .btn-primary {
        background: #2563eb !important;
        border: none !important; border-radius: 8px !important;
        font-family: 'DM Sans', sans-serif !important;
        font-weight: 600 !important; font-size: 0.95rem !important;
        padding: 11px 18px !important;
        width: 100%; margin-bottom: 10px;
        color: #fff !important;
        transition: background .15s;
      }
      .btn-primary:hover { background: #1d4ed8 !important; }

      .btn-success {
        background: #16a34a !important;
        border: none !important; border-radius: 8px !important;
        font-family: 'DM Sans', sans-serif !important;
        font-weight: 600 !important; font-size: 0.95rem !important;
        padding: 11px 18px !important;
        width: 100%; margin-bottom: 10px;
        color: #fff !important;
        transition: background .15s;
      }
      .btn-success:hover { background: #15803d !important; }

      .btn-download {
        background: #111318 !important;
        border: 1px solid #2a3149 !important; border-radius: 8px !important;
        color: #7d8fad !important;
        font-family: 'DM Sans', sans-serif !important;
        font-size: 0.9rem !important; padding: 10px 14px !important;
        width: 100%;
      }

      /* ── Score card ── */
      .score-card {
        background: #181c27;
        border: 1px solid #23293a;
        border-radius: 12px;
        padding: 28px 28px 24px;
        margin-bottom: 20px;
      }
      .score-card-title {
        font-size: 0.72rem; font-weight: 700; text-transform: uppercase;
        letter-spacing: 0.1em; color: #4b5a7a; margin-bottom: 20px;
      }
      .score-grid { display: flex; gap: 32px; align-items: flex-start; flex-wrap: wrap; }

      .score-block { min-width: 140px; }
      .score-context-label {
        font-size: 0.78rem; font-weight: 600; text-transform: uppercase;
        letter-spacing: 0.07em; color: #4b5a7a; margin-bottom: 6px;
      }
      .score-num {
        font-size: 3.6rem; font-weight: 700; line-height: 1;
        letter-spacing: -0.04em;
      }
      .score-num.green  { color: #4ade80; }
      .score-num.yellow { color: #fbbf24; }
      .score-num.red    { color: #f87171; }

      .badge {
        display: inline-block; padding: 5px 14px;
        border-radius: 999px; font-size: 0.8rem; font-weight: 600;
        margin-top: 10px; margin-right: 8px;
      }
      .badge-green  { background: rgba(74,222,128,.12); color: #4ade80; border: 1px solid rgba(74,222,128,.25); }
      .badge-yellow { background: rgba(251,191,36,.12);  color: #fbbf24; border: 1px solid rgba(251,191,36,.25); }
      .badge-red    { background: rgba(248,113,113,.12); color: #f87171; border: 1px solid rgba(248,113,113,.25); }
      .badge-grey   { background: rgba(255,255,255,.05); color: #7d8fad; border: 1px solid #23293a; }

      /* ── Penalty bars ── */
      .bar-wrap { flex: 1; min-width: 220px; }
      .bar-row { margin-bottom: 13px; }
      .bar-label {
        display: flex; justify-content: space-between;
        font-size: 0.82rem; color: #7d8fad; margin-bottom: 5px;
      }
      .bar-track {
        height: 7px; background: #1e2535; border-radius: 99px; overflow: hidden;
      }
      .bar-fill {
        height: 100%; border-radius: 99px; background: #f87171;
        transition: width .5s ease;
      }

      /* ── Report grid ── */
      .report-grid {
        display: grid; grid-template-columns: 1fr 1fr;
        gap: 20px; margin-bottom: 20px;
      }
      .report-card {
        background: #181c27;
        border: 1px solid #23293a;
        border-radius: 12px;
        padding: 24px;
      }
      .report-card-title {
        font-size: 0.78rem; font-weight: 700; text-transform: uppercase;
        letter-spacing: 0.09em; margin-bottom: 16px;
      }
      .report-card.before .report-card-title { color: #fb923c; }
      .report-card.after  .report-card-title { color: #4ade80; }

      .metric-row {
        display: flex; justify-content: space-between; align-items: center;
        padding: 10px 0; border-bottom: 1px solid #1e2a3a; font-size: 0.93rem;
      }
      .metric-row:last-child { border-bottom: none; padding-bottom: 0; }
      .metric-label { color: #7d8fad; }
      .metric-val {
        font-weight: 600; font-family: 'DM Mono', monospace; font-size: 0.93rem;
      }
      .metric-val.bad  { color: #f87171; }
      .metric-val.warn { color: #fbbf24; }
      .metric-val.ok   { color: #4ade80; }

      /* ── Preview ── */
      .preview-card {
        background: #181c27;
        border: 1px solid #23293a;
        border-radius: 12px;
        padding: 24px;
        overflow-x: auto;
      }
      .preview-card-title {
        font-size: 0.72rem; font-weight: 700; text-transform: uppercase;
        letter-spacing: 0.1em; color: #4b5a7a; margin-bottom: 16px;
      }
      .preview-card table {
        width: 100%; border-collapse: collapse;
        font-size: 0.88rem; font-family: 'DM Mono', monospace;
      }
      .preview-card table th {
        background: #111318; color: #4a7cf7;
        padding: 10px 14px; text-align: left;
        font-weight: 600; font-family: 'DM Sans', sans-serif;
        font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.06em;
        border-bottom: 1px solid #23293a;
      }
      .preview-card table td {
        padding: 9px 14px; color: #c4cedf;
        border-bottom: 1px solid #1a2232;
      }
      .preview-card table tr:hover td { background: #1a2232; }

      /* ── Misc ── */
      .hint {
        font-size: 0.82rem; color: #3d4d6a;
        margin-top: 16px; line-height: 1.6;
      }
      .empty-state {
        text-align: center; padding: 48px 20px;
        color: #3d4d6a; font-size: 0.95rem;
      }
      .empty-icon { font-size: 2.8rem; margin-bottom: 12px; }

      .shiny-input-container { margin-bottom: 0 !important; }
      label { color: #7d8fad !important; font-size: 0.85rem !important; margin-bottom: 6px !important; }
    "))
  ),

  # ── Top bar ──────────────────────────────────────────────────────────────────
  div(class = "topbar",
      div(class = "topbar-icon", "🔍"),
      div(
        tags$h1("Data Quality & Validation Engine"),
        tags$p("Data Auditing, Scoring, Cleaning, Reporting in one place. ")
      )
  ),

  div(class = "main-wrap",
      fluidRow(

        # ── Sidebar ────────────────────────────────────────────────────────────
        column(3,
               div(class = "sidebar",
                   tags$h3("Controls"),
                   div(class = "step-label", "Step 1 — Upload"),
                   fileInput("upload", NULL, accept = c("text/csv", ".csv"),
                             buttonLabel = "Choose CSV…", placeholder = "No file selected"),
                   div(class = "step-label", "Step 2 — Audit"),
                   actionButton("go", "▶  Run Audit", class = "btn-primary"),
                   div(class = "step-label", "Step 3 — Clean"),
                   actionButton("clean_btn", "✦  Clean Data", class = "btn-success"),
                   div(class = "step-label", "Step 4 — Export"),
                   uiOutput("download_ui"),
                   div(class = "hint",
                       "Upload any CSV → Run Audit → Clean Data → Download.
                        Cleans: imputes missing values, removes exact duplicates,
                        caps numeric outliers, normalises text case.")
               )
        ),

        # ── Main content ────────────────────────────────────────────────────────
        column(9,
               uiOutput("score_ui"),

               div(class = "report-grid",
                   div(class = "report-card before",
                       div(class = "report-card-title", "⚠  Before Cleaning"),
                       uiOutput("metrics_before")
                   ),
                   div(class = "report-card after",
                       div(class = "report-card-title", "✔  After Cleaning"),
                       uiOutput("metrics_after")
                   )
               ),

               div(class = "preview-card",
                   div(class = "preview-card-title", "Data Preview — first 15 rows"),
                   uiOutput("preview_ui")
               )
        )
      )
  )
)
