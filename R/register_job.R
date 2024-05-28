#' Register job with trigger
#' 
#' Register job wit trigger. This ensures that the job has uniue run-ids, and
#' that runs can be associated. It is a pre-requeisit for running a job with 
#' `trigger`. 
#'
#' @param name `character`. Name of the job. All characters are allowed.
#' @param frequency `daily()` or `monthly()`. Assigned from `run_frequencies`.
#'
#' @return invisibly the record in jobs
#' @export
#'
#' @examples
#' 
#' x <- register_job("gralen_snm",run_frequencies$monthly())
#' 
register_job <- function(name,frequency, job_description = " ",...){
  
  approve_job_name <- function(name,dbc){
    x <- get_table(
      table = "jobs",
      filter = glue::glue("name LIKE '{name}'"),
      dbc = dbc
    ) %>% 
      nrow()
    approved <- x == 0
    
    if (!approved){
      
      names_in_use <- get_table(table = "jobs",dbc = dbc) %>% dplyr::pull(name) %>% paste(collapse = ", ")
      
      cli::cli_abort(c("x" = "The jobname is taken.",
                       "i" = "The following names are currently in use: {names_in_use}"))
    }
    
  }
  
  dbc_trigger <- get_trigger_dbc()
  
  approve_job_name(name,dbc_trigger)
    
  insert_into_jobs(
    job_name = name,
    run_frequency = frequency,
    job_description = job_description,
    dbc = dbc_trigger 
  )
  
  cli::cli_alert_info("Job registered. ")
  
}


