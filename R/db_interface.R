insert_into_jobs <- function(job_name, run_frequency,job_description,dbc,created_at = Sys.time()){
  params <- list(
    name = job_name, 
    created_at = created_at, 
    run_frequency = run_frequency,
    job_description = job_description
  )
  findd("sql","insert_job.sql") %>% 
    read_sql_file(params) %>% 
    DBI::dbSendQuery(conn = dbc)
  
}
insert_into_runs <- function(job_name, run_id,log_path,dbc,run_time = Sys.time()){
  params <- list(
    job_name = job_name, 
    run_id = run_id, 
    log_path = log_path,
    run_time = run_time
  )
  
  findd("sql","insert_run.sql") %>% 
    read_sql_file(params) %>% 
    DBI::dbSendQuery(conn = dbc)
  
}
insert_into_event <- function(job_name, run_id,status,dbc,event_time = Sys.time()){
  params <- list(
    job_name = job_name, 
    run_id = run_id, 
    status = status,
    time = event_time
  )
  findd("sql","insert_event.sql") %>% 
    read_sql_file(params) %>% 
    DBI::dbSendQuery(conn = dbc)
  
}
get_table <- function(table,dbc,filter = NULL){
  sql <- glue::glue("SELECT * FROM {table}")
  if (!is.null(filter)) {
    sql <- glue::glue("{sql} WHERE {filter}")
  }
  sql %>% as.character() %>% DBI::dbGetQuery(conn = dbc)
}