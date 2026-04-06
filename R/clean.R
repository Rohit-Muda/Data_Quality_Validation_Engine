# clean.R
# Applies a four-step cleaning pipeline to a data frame:
#   1. Trim whitespace + lowercase all character columns
#   2. Impute missing values  (median for numeric, mode for character)
#   3. Fix obviously bad email addresses (replace with most common valid one)
#   4. Remove exact duplicate rows
#   5. IQR cap — clamp numeric extremes instead of dropping rows
#
# Returns the cleaned data frame.
# Called by: server.R (on "Clean Data" button click)
# ----------------------------------------------------------------------------

library(dplyr)
library(stringr)

clean_data <- function(df) {

  # Step 1: Trim & normalise text
  df <- df %>%
    mutate(across(where(is.character), ~ str_to_lower(str_trim(.))))

  # Step 2: Impute missing values
  for (col in names(df)) {
    if (all(is.na(df[[col]]))) next

    if (is.numeric(df[[col]])) {
      df[[col]][is.na(df[[col]])] <- median(df[[col]], na.rm = TRUE)
    } else {
      mode_val <- names(sort(table(df[[col]]), decreasing = TRUE))[1]
      df[[col]][is.na(df[[col]])] <- mode_val
    }
  }

  # Step 3: Fix bad email addresses
  if ("email" %in% names(df)) {
    pat <- "^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$"
    ok  <- grepl(pat, df$email, perl = TRUE)
    if (any(ok)) {
      best <- names(sort(table(df$email[ok]), decreasing = TRUE))[1]
      df$email[!ok] <- best
    }
  }

  # Step 4: Remove exact duplicates
  df <- distinct(df)

  # Step 5: IQR cap — clamp rather than delete
  for (col in names(df)[sapply(df, is.numeric)]) {
    x   <- df[[col]]
    q1  <- quantile(x, 0.25, na.rm = TRUE)
    q3  <- quantile(x, 0.75, na.rm = TRUE)
    iqr <- q3 - q1
    df[[col]] <- pmin(pmax(x, q1 - 1.5 * iqr), q3 + 1.5 * iqr)
  }

  df
}
