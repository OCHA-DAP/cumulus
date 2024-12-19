#' pg_creds
#'
#' @param stage db to access, either `prod` (default) or `dev`. `dev`
#' @param key_syntax_v `integer` 1 or 2 (default). 2 is the current env var
#'   naming status
#' @param write_access `logical` indicating if write access is needed
#'   default=TRUE
#'
#' @return list containing named env vars to use for authentication

pg_creds <- function(
    stage = "prod",
    key_syntax_v = 2,
    write_access = TRUE
    ) {
  stage_upper = toupper(stage)
  if(key_syntax_v == 1){
    l_creds <- list(
      user = "AZURE_DB_USER_ADMIN",
      host = "AZURE_{stage_upper}_DB_HOST",
      password = "AZURE_{stage_upper}_DB_PW",
      port = 5432,
      dbname = "postgres"
    )

  }
  if(key_syntax_v==2){
    l_creds <- list(
      user = "DS_AZ_DB_{stage_upper}_UID_WRITE",
      host = "DS_AZ_DB_{stage_upper}_HOST",
      password = "DS_AZ_DB_{stage_upper}_PW_WRITE",
      port = 5432,
      dbname = "postgres"
    )
  }
  if(!write_access){
    l_creds$user <-"DS_AZ_DB_{stage_upper}_UID"
    l_creds$password <-"DS_AZ_DB_{stage_upper}_PW"
  }

  purrr::map(l_creds,\(item){glue::glue(item)})
}

#' pg_con - connect to postgres DB. Either `prod` or `dev` stage
#'
#' @param stage db to access, either `prod` (default) or `dev`. `dev`
#' @param key_syntax_v `integer` 1 or 2 (default). 2 is the current env var
#'   naming status
#' @param write_access `logical` indicating if write access is needed
#'   default=TRUE
#'
#' @return `PqConnection` object
#' @export
#' @examples \dontrun{
#' library(cumulus)
#' con <-  pg_con() # prod
#' # connect to dev instead
#' con_dev <- pg_con(stage="dev")
#' }
pg_con <- function(
    stage="prod",
    key_syntax_v=2,
    write = TRUE
){

  creds <- pg_creds(
    stage=stage,
    key_syntax_v = key_syntax_v,
    write= write
    )

  DBI::dbConnect(
    drv = RPostgres::Postgres(),
    user = Sys.getenv(creds$user),
    host = Sys.getenv(creds$host),
    password = Sys.getenv(creds$password),
    port = creds$port,
    dbname = creds$dbname
  )
}
