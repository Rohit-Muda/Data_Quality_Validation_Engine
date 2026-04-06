# entropy.R
# Measures how evenly distributed values are across categorical columns.
# A score close to 1 = high diversity; close to 0 = near-constant column.
# Called by: server.R (feeds into calculate_score)
# ----------------------------------------------------------------------------

# Normalised Shannon entropy for a single vector (ignores NAs).
entropy_normalized <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return(1)
  tab <- table(x)
  p   <- as.numeric(tab) / length(x)
  p   <- p[p > 0]
  k   <- length(tab)
  if (k <= 1) return(0)
  -sum(p * log2(p)) / log2(k)
}

# Mean normalised entropy across all character columns in a data frame.
entropy_score <- function(df) {
  chars <- df[sapply(df, is.character)]
  if (ncol(chars) == 0) return(1)
  mean(vapply(chars, entropy_normalized, numeric(1)))
}
