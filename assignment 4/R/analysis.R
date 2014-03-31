# getting the imports
library("epitools")

# reading input file (expecting the file on buildinfo.csv)
buildinfo = read.csv("buildinfo.csv")

# creating matrix OUT which will be saved to a file
OUT <- matrix(numeric(0), 0, 8) 
colnames(OUT) = 
  c("slug", "p of ct", "residual 1", "residual 2", "residual 3", "residual 4",
    "measure of or", "p of or")

for (i in 1:nrow(buildinfo)) {

  # reading the buildinfo for row i
  X <- matrix(c(buildinfo[i, 'commits.passed'], buildinfo[i, 'commits.failed'],
    buildinfo[i, 'pr.passed'], buildinfo[i, 'pr.failed']), 2, 2)

  if (X[1, 1] < 5 || X[1, 2] < 5 || X[2, 1] < 5 || X[2, 2] < 5) {
    # too few builds
    row <- c(NA, NA, NA, NA, NA, NA, NA)
  } else { # there are enough builds
    # calculating values
    ct <- chisq.test(X)
    or <- oddsratio(X)

    # creating output data
    row <- c(ct$p.value, ct$residual[1, 1], ct$residual[1, 2],
      ct$residual[2, 1], ct$residual[2, 2], or$measure[2, 1], or$p.value[2, 1])
  }

  # creating a row for the output data
  slug <- as.character(buildinfo[i, 'slug'])
  ADD <- matrix(c(slug, row), ncol = ncol(OUT))
  OUT <- rbind(OUT, ADD) 
}

rdata <- as.table(OUT)
write.csv(rdata, "rdata.csv", quote = FALSE, row.names = FALSE)
