regextract <- function(pattern, text) {
  match <- gregexpr(pattern, text, perl=TRUE)  
  vals <- length(attr(match[[1]],"capture.start")[])
  returner <- c()
  for (i in 1:vals) {
    start <- attr(match[[1]],"capture.start")[i]
    end <- attr(match[[1]],"capture.start")[i] + attr(match[[1]],"capture.length")[i] -1 
    extract <- substring(text, start, end)
    returner <- cbind(returner, extract)
  }
  colnames(returner) <- as.vector(attr(match[[1]],"capture.names"))
  returner
}

