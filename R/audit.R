# audit.R
# Inspects a data frame and returns a named list of quality metrics.
# Called by: server.R (on "Run Audit" and "Clean Data" events)
# ----------------------------------------------------------------------------

audit_data <- function(df) {
  n <- nrow(df)
  p <- ncol(df)

  # Missing values
  missing_col   <- colSums(is.na(df)) / n * 100
  missing_total <- sum(is.na(df)) / (n * p) * 100

  # Exact duplicate rows
  exact_dup <- sum(duplicated(df))

  # Outliers — IQR rule on every numeric column
  outliers <- 0
  for (col in names(df)[sapply(df, is.numeric)]) {
    x   <- df[[col]]
    q1  <- quantile(x, 0.25, na.rm = TRUE)
    q3  <- quantile(x, 0.75, na.rm = TRUE)
    iqr <- q3 - q1
    outliers <- outliers + sum(!is.na(x) & (x < q1 - 1.5 * iqr | x > q3 + 1.5 * iqr))
  }

  # Format checks — email & phone
  email_invalid <- 0L
  if ("email" %in% names(df))
    email_invalid <- sum(
      !is.na(df$email) &
        !grepl("^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$",
               df$email, perl = TRUE)
    )

  phone_invalid <- 0L
  pc <- names(df)[grepl("^phone$|^mobile$", names(df), ignore.case = TRUE)][1]
  if (!is.na(pc)) {
    x <- as.character(df[[pc]])
    phone_invalid <- sum(
      !is.na(x) & x != "" &
        !grepl("^\\+?[0-9][0-9\\s\\-\\(\\)]{7,}$", x, perl = TRUE)
    )
  }

  # Schema snapshot
  schema <- data.frame(
    Column = names(df),
    Type   = vapply(df, function(x) class(x)[1], character(1)),
    stringsAsFactors = FALSE
  )

  list(
    missing_col   = missing_col,
    missing_total = missing_total,
    exact_dup     = exact_dup,
    outliers      = outliers,
    invalid_email = email_invalid,
    invalid_phone = phone_invalid,
    schema        = schema,
    n_rows        = n,
    n_cols        = p
  )
}
