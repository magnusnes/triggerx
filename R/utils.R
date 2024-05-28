findd <- function(...){
  system.file(...,package = "trigger")
}
get_version <- function(){
  as.vector(read.dcf(findd("DESCRIPTION"),"Version"))
}
get_package_name <- function(){
  as.vector(read.dcf(findd("DESCRIPTION"),"Title"))
}
update_pkgdown_config <- function(config_file = "_pkgdown.yml") {
  # Få brukernavnet fra systemet
  brukernavn <- Sys.info()["user"]
  
  # Bygg destination path og URL
  dest_path <- paste0("/home/", brukernavn, "/ShinyApps/doc/",get_package_name(),"/")
  url <- paste0("http://rserver_dev:3838/dev/", brukernavn, "/doc/",get_package_name(),"/")
  
  # Les eksisterende pkgdown konfigurasjon
  config <- yaml::read_yaml(config_file)
  
  # Oppdater destination og URL i konfigurasjonen
  config$destination <- dest_path
  config$url <- url
  
  # Skriv den oppdaterte konfigurasjonen tilbake til konfigurasjonsfilen
  yaml::write_yaml(config, config_file)
  
  cat("pkgdown configuration updated successfully.\n")
}
