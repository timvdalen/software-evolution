# getting the imports
library("epitools")

# reading input file (expecting the file on buildinfo.csv)
buildinfo = read.csv("buildinfo.csv")[,-1]
x <- buildinfo[,-1]
ct <- chisq.test(x)