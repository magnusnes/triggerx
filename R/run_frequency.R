#' Run frequencies
#' 
#' List of run frequencies. Used when regisering a job.
#'
#' @export
#'
#' @examples 
#' run_frequencies$daily()
#' run_frequencies$monthly()
#' 
run_frequencies <- list(
  daily = function(){
    "daily"
  },
  monthly = function(){
    "monthly"
  }
)