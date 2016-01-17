library(knitr)

site <- "~/kaggleblog/_posts/"
rmdFiles <- "~/Dropbox/Programming/kaggle/rmd/"

createNewPost <- function(s) {
  today <- as.character(Sys.Date(), format = "%Y-%m-%d-")
  sink(paste0(rmdFiles, today, gsub(" ", "-", s), ".Rmd"))
  cat("---\nlayout: post\n")
  cat(paste0("title: ", s, "\n---\n"))
  sink()
}

publish <- function(f) {
  asMd <- gsub(".Rmd", ".md", f)
  asMd <- gsub(rmdFiles, site, asMd)

  knit(input = f, output = asMd )
}
