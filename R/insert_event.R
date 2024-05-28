insert_start_event <- function(name,run_id,dbc){
  insert_into_event(
    job_name = name,
    dbc = dbc,
    run_id = run_id,
    event_time = Sys.time(),
    status = "Start"
    
  )  
}
insert_wait_event <- function(name,run_id,dbc){
  insert_into_event(
    job_name = name,
    run_id = run_id,
    dbc = dbc,
    event_time = Sys.time(),
    status = "Wait"
    
  )  
}
insert_proceed_event <- function(name,run_id,dbc){
  insert_into_event(
    job_name = name,
    dbc = dbc,
    run_id = run_id,
    event_time = Sys.time(),
    status = "Proceed"
  )  
}
insert_warning_event <- function(name,run_id,dbc){
  insert_into_event(
    job_name = name,
    dbc = dbc,
    run_id = run_id,
    event_time = Sys.time(),
    status = "Warning"
  )  
  
}
insert_error_event <- function(name,run_id,dbc){
  insert_into_event(
    job_name = name,
    dbc = dbc,
    run_id = run_id,
    event_time = Sys.time(),
    status = "Error"
  )  
}
insert_success_event <- function(name,run_id,dbc){
  insert_into_event(
    job_name = name,
    dbc = dbc,
    run_id = run_id,
    event_time = Sys.time(),
    status = "Success"
  )  
}
insert_progress_event <- function(name,run_id,dbc){
  insert_into_event(
    job_name = name,
    run_id = run_id,
    dbc = dbc,
    event_time = Sys.time(),
    status = glue::glue("Manual: {status}")
  )  
}