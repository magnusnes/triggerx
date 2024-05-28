#' Set up job-runner
#' 
#' Set up a job runner.
#'
#' @param name 
#' @param alerts 
#'
#' @return `function` which can be used to 
#' @export
#'
#' @examples
#' 
#' init()
#' register_job("test",run_frequencies$daily())
#' job_runner <- set_up_job_runner(name = "test",alerts = c())
#' job_runner({
#'   Sys.sleep(1)
#' })
#' job_runner <- set_up_job_runner(name = "test",alerts = c())
#' job_runner({
#'   Sys.sleep(1)
#'   warning("Warning event")
#' })
#' job_runner <- set_up_job_runner(name = "test",alerts = c())
#' job_runner({
#'   Sys.sleep(2)
#'   stop("Error event")
#' })
#' get_table("runs",get_trigger_dbc())
#' get_table("events",get_trigger_dbc())
set_up_job_runner <- function(name, alerts){
  
  verify_job_name <- function(name,dbc){
    n_jobs <- get_table(table = "jobs",dbc = dbc,filter = glue::glue("NAME = '{name}'")) %>% nrow()
    if (n_jobs == 0){
      cli::cli_abort(c("x" = "Fant ikke jobben",
                       "i" = "Registrer jobben med register_job(\"{name}\")"))
    }
    return(name)
  }
  get_run_id <- function(name,dbc){
    past_runs <- get_table(table = "runs",filter = glue::glue("job_name = '{name}'"),dbc = dbc) %>% nrow()
    run_id <- past_runs + 1
  }
  
  trigger_dbc <- get_trigger_dbc()
  verified_name <- verify_job_name(name,trigger_dbc)
  run_id <- get_run_id(verified_name,trigger_dbc)
  
  
  purrr::partial(
    .f = run_job_template,
    name = verified_name,
    run_id = run_id,
    dbc = trigger_dbc,
    alerts = alerts
  )
}

run_job_template <- function(expr,name,run_id,dbc,alerts,...){
  
  detect_outcome <- function(x){
    
    dplyr::case_when(
      "error" %in% class(x) ~ "error",
      "warning" %in% class(x) ~ "warning",
      TRUE ~ "success"
      
    )
  }
  register_run <- function(name,run_id,dbc){
    insert_into_runs(
      job_name = name,
      run_id = run_id,
      log_path = get_log_path(name,run_id),
      dbc = dbc
    )
  }  
  
  register_run(name,run_id,dbc)
  log_path <- get_log_path(name,run_id)
  insert_start_event(name,run_id,dbc)
  
  runner_function <- function(run_id){
    eval(expr)
  }
  
  eval_outcome <- 
    tryCatch(
      expr = expr,
      error = function(e) e,
      warning = function(w) w
    )
  outcome_status <- eval_outcome %>% detect_outcome()
  
  if (outcome_status == "error"){
    insert_error_event(name,run_id,dbc)
    eval_outcome$message %>% write_log(log_path)
    cli::cli_alert_danger("Job completed with error. See log file here: {log_path}")
  } else if (outcome_status == "warning") {
    insert_warning_event(name,run_id,dbc)
    eval_outcome$message %>% write_log(log_path)
    cli::cli_alert_warning("Job completed with warning. See log file here: {log_path}")
  } else {
    insert_success_event(name,run_id,dbc)
    cli::cli_alert_success("Job completed successfully.")
  }
  
  
}
get_log_path <- function(name,run_id){
  fs::path(get_path(),"logfiles","test",glue::glue("log_{run_id}.log"))
}
write_log <- function(message,log_file){
  if (!fs::dir_exists(fs::path_dir(log_file))) fs::dir_create(fs::path_dir(log_file))
  if (!fs::file_exists(log_file)) fs::file_create(log_file)
  writeLines(con = log_file,message)
}
