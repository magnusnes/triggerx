#' Les SQL
#' @description Leser innholdet fra en SQL-fil. Filen må være en .sql fil.
#'
#' @param filsti character string. Må angi en fil med endelse .sql eller .SQL.
#' @param params list. Optional. A list with the parameters in the corresponding sql file.
#' @importFrom glue glue
#' @return character string. Returnrerer SQL i filstien
#' @keywords internal
read_sql_file <- function(filsti,params=NULL){
  
  empty_space <- function(x){
    x[ ifelse(x=="", FALSE,TRUE)]
  }
  
  if (!is.character(filsti))
    stop("filsti må være tekststregnge")
  if (!file.exists(filsti))
    stop("Finner ikke filen")
  if (tolower(substr(filsti, (nchar(filsti) - 3), nchar(filsti))) != ".sql")
    stop("Filen må ende med .sql")
  sql_query <-
    filsti %>%
    file("r") %>%
    readLines() %>%
    gsub(pattern = '--.+$',replacement = '') %>%
    empty_space() %>%
    paste(collapse = " ") %>%
    glue::glue() %>% 
    as.character()
  
  sql_query
}
# TODO: Lag read_bash_script med variabler på samme måte som read_sql_file
