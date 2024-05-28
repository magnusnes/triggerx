#' Assign the location of the trigger-database.
#' 
#' Assign the location of the trigger-database. This is the databse where jobs 
#' and runs are registred. The function places this information in options.
#' 
#' @param path `path` where the database is located.
#'
#' @return intput is returned invisible
#' @export
locate_database <- function(path = "/si/computed/trigger/"){
  
  path <- fs::as_fs_path(path)
  
  options(trigger.path = path)  
  
  invisible(path)
  
}
get_path <- function(){
  
  getOption("trigger.path")
  
}