# getting the imports
library("epitools")

# reading input file (expecting the file on buildinfo.csv)
buildinfo = read.csv("buildinfo.csv")[,-1][,-1]
X <- as.matrix(buildinfo)

# doing the statistical computations
ct <- chisq.test(X)
or <- oddsratio(X)

# creating matrix OUT which will be saved to a file
OUT <- matrix(numeric(0), 0, 7) 
colnames(OUT) = 
  c("p of ct", "residual 1", "residual 2", "residual 3", "residual 4",
    "measure of or", "p of or")

for (i in 1:nrow(X)) {
  if (X[i,1] < 5 || X[i,2] < 5 || X[i,3] < 5 || X[i,4] < 5) {
    # too few builds
    row <- c(NA, NA, NA, NA, NA)
  } else { # there are enough builds
    row <- c(ct$p.value, ct$residual[i, 1], ct$residual[i, 2],
      ct$residual[i, 3], ct$residual[i, 4],
      or$measure[i, 1], or$p.value[i, 1])
  }

  ADD <- matrix(row, ncol = 7)
  OUT <- rbind(OUT, ADD) 
}

rdata <- as.table(OUT)
write.csv(rdata, "rdata.csv")
