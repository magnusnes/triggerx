#' Klargjør trigger databasen
#' 
#' Klargjør triggerdatabasen. Tester også enkle transaksjoner i databasen.
#'
#' @param admin_email epostadresse som varsel sendes til dersom programvaren 
#' ikke virker som den skal.
#'
#' @return stien der databasen og programvaren finnes.
#' @export
#'
#' @examples
#' 
#' locate_database("/si/testing/trigger/")
#' init()
#' 
init <- function(admin_email = "admin@example.com") {

  # Operasjonsdefinisjoner --------------------------------------------------

  create_folder_structure <- function(path) {
    fs::dir_create(path)
    fs::dir_create(fs::path(path, "database"))
    fs::dir_create(fs::path(path, "logfiles"))
  }
  register_metadata <- function(path,admin_email){
    path <- fs::path(path,"META")
    fs::file_create(path)
    write.dcf(
      x = 
        data.frame(
          "admin_email" = admin_email,
          "version" = get_version()
          ) %>% 
        as.matrix(),
      file = path
    )
  }
  
  create_database <- function(path) {
    db_path <- fs::path(path, "database", "trigger.sqlite")
    if (fs::file_exists(db_path)) {
      cli::cli_abort(c(
        "trigger is already initiated",
        "i" = "Delete the current installation of trigger if you wish to re-inittiate it. Deleting the trigger folder will let you re-run init()",
        "!" = "This operation can not be undone.",
        "i" = "The database is located here: {db_path}"
        
      ))
    }
    dbc <- DBI::dbConnect(RSQLite::SQLite(), db_path)
    return(dbc)
  }
  create_database_tables <- function(dbc) {
    create_db_table_jobs <- function(dbc) {
      db_jobs <- "
CREATE TABLE jobs (
    name TEXT,
    job_description TEXT,
    created_at DATETIME,
    run_frequency TEXT
);

      "
      DBI::dbSendQuery(conn = dbc, statement = db_jobs)
    }
    create_db_table_runs <- function(dbc) {
      db_runs <- "
      CREATE TABLE runs (
    job_name TEXT,
    run_id INTEGER,
    time DATETIME,
    log_path TEXT
)
      "
      DBI::dbSendQuery(conn = dbc, statement = db_runs)
    }
    create_db_table_events <- function(dbc) {
      db_runs <- "
      CREATE TABLE events (
    job_name TEXT,
    run_id INTEGER,
    time DATETIME,
    status TEXT
)
      "
      DBI::dbSendQuery(conn = dbc, statement = db_runs)
    }

    create_db_table_jobs(dbc)
    create_db_table_runs(dbc)
    create_db_table_events(dbc)
  }
  
  test_init <- function(dbc) {
    
    test_insert_job <- function(dbc) {
      cli::cli_alert_info("Tester jobs tabellen.")
      sql <- "INSERT INTO jobs (name, job_description, created_at, run_frequency) VALUES ('Example Job','Example', '2024-05-23 12:34:56', 1.0)"
      DBI::dbSendQuery(conn = dbc, statement = sql)
      dtf <- "SELECT * FROM jobs where name = 'Example Job'" %>% DBI::dbGetQuery(conn = dbc)
      if (nrow(dtf) == 1){
        cli::cli_alert_success("Testing av jobs tabellen vellykket.")
      } else {
        cli::cli_alert_danger("Testing av jobs tabellen mislyktes. Fant ikke den innsatte raden.")
      }
    }
    test_insert_run <- function(dbc) {
      
      test_insert_run <- function(dbc) {
        cli::cli_alert_info("Tester runs tabellen med start-varsel.")
        sql <- "INSERT INTO runs (job_name, run_id, time,log_path) VALUES ('Example Job', 1, '2024-05-23 12:34:56','/si/testing/trigger/Example Job/run_20240523123456.log');"
        DBI::dbSendQuery(conn = dbc, statement = sql)
        dtf <- "SELECT * FROM runs where job_name = 'Example Job' and run_id = 1" %>% DBI::dbGetQuery(conn = dbc)
        if (nrow(dtf) == 1){
          cli::cli_alert_success("Testing av spørringen var vellykket.")
        } else {
          cli::cli_alert_danger("Testing av spørring etter start registrering mislyktes. Fant ikke den innsatte raden.")
        }
      }
      test_insert_run(dbc)
      
    }
    test_insert_event <- function(dbc) {
      
      test_insert_event_start <- function(dbc) {
        cli::cli_alert_info("Tester events tabellen med start-varsel.")
        sql <- "INSERT INTO events (job_name, run_id, time, status) VALUES ('Example Job', 1, '2024-05-23 12:34:56', 'started');"
        DBI::dbSendQuery(conn = dbc, statement = sql)
        dtf <- "SELECT * FROM events where job_name = 'Example Job' and run_id = 1" %>% DBI::dbGetQuery(conn = dbc)
        if (nrow(dtf) == 1){
          cli::cli_alert_success("Testing av spørringen var vellykket.")
        } else {
          cli::cli_alert_danger("Testing av spørring etter start registrering mislyktes. Fant ikke den innsatte raden.")
        }
      }
      test_insert_event_complete <- function(dbc) {
        cli::cli_alert_info("Tester events tabellen med slutt-varsel.")
        sql <- "INSERT INTO events (job_name, run_id, time, status) VALUES ('Example Job', 1, '2024-05-23 12:36:56', 'complete');"
        DBI::dbSendQuery(conn = dbc, statement = sql)
        dtf <- "SELECT * FROM events where job_name = 'Example Job' and run_id = 1" %>% DBI::dbGetQuery(conn = dbc)
        if (nrow(dtf) == 2){
          cli::cli_alert_success("Testing av spørringen var vellykket.")
        } else {
          cli::cli_alert_danger("Testing av spørring etter start registrering mislyktes. Fant ikke den innsatte raden.")
        }
      }
      test_insert_event_warning <- function(dbc) {
        cli::cli_alert_info("Tester events tabellen med slutt-varsel og advarsel status.")
        sql <- "INSERT INTO events (job_name, run_id, time, status) VALUES ('Example Job', 2, '2024-05-23 12:36:56', 'warning');"
        DBI::dbSendQuery(conn = dbc, statement = sql)
        dtf <- "SELECT * FROM events where job_name = 'Example Job' and run_id = 2" %>% DBI::dbGetQuery(conn = dbc)
        if (nrow(dtf) == 1){
          cli::cli_alert_success("Testing av spørringen var vellykket.")
        } else {
          cli::cli_alert_danger("Testing av spørring etter start registrering mislyktes. Fant ikke den innsatte raden.")
        }
      }
      test_insert_event_error <- function(dbc) {
        cli::cli_alert_info("Tester events tabellen med slutt-varsel og feil status.")
        sql <- "INSERT INTO events (job_name, run_id, time, status) VALUES ('Example Job', 3, '2024-05-23 12:36:56', 'error');"
        DBI::dbSendQuery(conn = dbc, statement = sql)
        dtf <- "SELECT * FROM events where job_name = 'Example Job' and run_id = 3" %>% DBI::dbGetQuery(conn = dbc)
        if (nrow(dtf) == 1){
          cli::cli_alert_success("Testing av spørringen var vellykket.")
        } else {
          cli::cli_alert_danger("Testing av spørring etter start registrering mislyktes. Fant ikke den innsatte raden.")
        }
      }
      
      
      test_insert_event_start(dbc)
      test_insert_event_complete(dbc)
      test_insert_event_warning(dbc)
      test_insert_event_error(dbc)
      
    }
    clean_database <- function(dbc){
      
      cli::cli_alert_info("Klargjør databasen for bruk etter testing.")
      sql <- "DELETE FROM jobs;"
      DBI::dbSendQuery(conn = dbc, statement = sql)
      sql <- "DELETE FROM runs;"
      DBI::dbSendQuery(conn = dbc, statement = sql)
      sql <- "DELETE FROM events;"
      DBI::dbSendQuery(conn = dbc, statement = sql)
      dtf <- "SELECT * FROM runs " %>% DBI::dbGetQuery(conn = dbc)
      if (nrow(dtf) > 0){
        cli::cli_abort("Tømming av runs mislyktes.")
      }
      dtf <- "SELECT * FROM jobs " %>% DBI::dbGetQuery(conn = dbc)
      if (nrow(dtf) > 0){
        cli::cli_abort("Tømming av runs mislyktes.")
      }
      dtf <- "SELECT * FROM events " %>% DBI::dbGetQuery(conn = dbc)
      if (nrow(dtf) > 0){
        cli::cli_abort("Tømming av events mislyktes.")
      }
      cli::cli_alert_success("Databasen er klar for bruk.")
    }
    
    test_insert_job(dbc)
    test_insert_run(dbc)
    test_insert_event(dbc)
    clean_database(dbc)
  }

  # Anvendelse --------------------------------------------------------------

  trigger_path <- get_path()
  trigger_path %>% create_folder_structure()
  trigger_path %>% register_metadata(admin_email)
  
  dbc <- trigger_path %>% create_database()
  dbc %>% create_database_tables()
  test_init(dbc)


  return(trigger_path)
}
