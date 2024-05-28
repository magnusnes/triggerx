get_trigger_dbc <- function(){
  path <- get_path()
  db_path <- fs::path(path, "database", "trigger.sqlite")
  DBI::dbConnect(RSQLite::SQLite(), db_path)
}