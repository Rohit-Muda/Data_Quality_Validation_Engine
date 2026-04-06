# server.R
# Handles all reactive state and output rendering for DataSeal.
# All computation is delegated to the modules in R/:
#   audit_data()      : R/audit.R
#   entropy_score()   : R/entropy.R
#   calculate_score() : R/score.R
#   clean_data()      : R/clean.R
#   make_bar()        : R/helpers.R
#   render_metrics()  : R/helpers.R
# ----------------------------------------------------------------------------

library(shiny)
library(readr)

server <- function(input, output, session) {

  # Reactive state
  rv <- reactiveValues(
    raw     = NULL,
    cleaned = NULL,
    audit_b = NULL, ent_b = NULL, score_b = NULL,   # before cleaning
    audit_a = NULL, ent_a = NULL, score_a = NULL    # after  cleaning
  )

  # 1. Upload
  observeEvent(input$upload, {
    req(input$upload)
    rv$raw     <- read_csv(input$upload$datapath, show_col_types = FALSE)
    rv$cleaned <- rv$audit_b <- rv$ent_b <- rv$score_b <- NULL
    rv$audit_a <- rv$ent_a   <- rv$score_a <- NULL
  })

  # 2. Run Audit
  observeEvent(input$go, {
    req(rv$raw)
    rv$audit_b <- audit_data(rv$raw)
    rv$ent_b   <- entropy_score(rv$raw)
    rv$score_b <- calculate_score(rv$audit_b, rv$ent_b, rv$raw)
    rv$cleaned <- rv$audit_a <- rv$ent_a <- rv$score_a <- NULL
  })

  # 3. Clean Data
  observeEvent(input$clean_btn, {
    req(rv$raw)
    # Run audit first if not already done
    if (is.null(rv$audit_b)) {
      rv$audit_b <- audit_data(rv$raw)
      rv$ent_b   <- entropy_score(rv$raw)
      rv$score_b <- calculate_score(rv$audit_b, rv$ent_b, rv$raw)
    }
    rv$cleaned <- clean_data(rv$raw)
    rv$audit_a <- audit_data(rv$cleaned)
    rv$ent_a   <- entropy_score(rv$cleaned)
    rv$score_a <- calculate_score(rv$audit_a, rv$ent_a, rv$cleaned)
  })

  # Output: Score header
  output$score_ui <- renderUI({
    if (is.null(rv$score_b)) {
      return(div(class = "score-card",
                 div(class = "empty-state",
                     div(class = "empty-icon", "📂"),
                     div("Upload a CSV file and click  Run Audit  to begin.")
                 )
      ))
    }

    s   <- rv$score_b
    s2  <- rv$score_a
    cls  <- if (s$score >= 80) "green" else if (s$score >= 50) "yellow" else "red"
    bcls <- if (s$score >= 80) "badge-green" else if (s$score >= 50) "badge-yellow" else "badge-red"

    after_score_html <- if (!is.null(s2)) {
      cls2  <- if (s2$score >= 80) "green" else if (s2$score >= 50) "yellow" else "red"
      bcls2 <- if (s2$score >= 80) "badge-green" else if (s2$score >= 50) "badge-yellow" else "badge-red"
      div(class = "score-block",
          div(class = "score-context-label", "After Cleaning"),
          div(class = paste("score-num", cls2), sprintf("%.1f", s2$score)),
          tags$span(class = paste("badge", bcls2), s2$status)
      )
    } else tags$span()

    div(class = "score-card",
        div(class = "score-card-title", "Quality Score"),
        div(class = "score-grid",
            div(class = "score-block",
                div(class = "score-context-label", "Before Cleaning"),
                div(class = paste("score-num", cls), sprintf("%.1f", s$score)),
                tags$span(class = paste("badge", bcls), s$status),
                tags$span(class = "badge badge-grey", paste("Severity:", s$severity))
            ),
            after_score_html,
            div(class = "bar-wrap",
                make_bar("Missing values penalty", s$pen_miss, 40),
                make_bar("Duplicate rows penalty", s$pen_dup,  35),
                make_bar("Outliers penalty",       s$pen_out,  30),
                make_bar("Format errors penalty",  s$pen_fmt,  20),
                make_bar("Entropy penalty",        s$pen_ent,  10)
            )
        )
    )
  })

  # Output: Before / After metric cards
  output$metrics_before <- renderUI({
    if (is.null(rv$audit_b))
      return(div(class = "empty-state", "Run audit first."))
    render_metrics(rv$audit_b, rv$score_b)
  })

  output$metrics_after <- renderUI({
    if (is.null(rv$audit_a))
      return(div(class = "empty-state", "Run Clean Data to see results."))
    render_metrics(rv$audit_a, rv$score_a)
  })

  # Output: Data preview
  output$preview_ui <- renderUI({
    if (is.null(rv$raw))
      return(div(class = "empty-state", "No data loaded."))

    df  <- if (!is.null(rv$cleaned)) rv$cleaned else rv$raw
    tbl <- head(df, 15)

    th_cells <- lapply(names(tbl), function(n) tags$th(n))
    rows <- lapply(seq_len(nrow(tbl)), function(i)
      tags$tr(lapply(names(tbl), function(n)
        tags$td(as.character(tbl[i, n, drop = TRUE])))))

    tags$table(tags$thead(tags$tr(th_cells)), tags$tbody(rows))
  })

  # Output: Download button (disabled until cleaning is done)
  output$download_ui <- renderUI({
    if (is.null(rv$cleaned))
      return(tags$div(
        actionButton("_noop", "⬇  Download CSV", class = "btn-download",
                     disabled = "disabled",
                     style = "opacity:.35; cursor:not-allowed;")
      ))
    downloadButton("dl", "⬇  Download Cleaned CSV", class = "btn-download")
  })

  output$dl <- downloadHandler(
    filename = function() paste0("cleaned_", Sys.Date(), ".csv"),
    content  = function(f) write.csv(rv$cleaned, f, row.names = FALSE)
  )
}
