## Load libraries ==============================================================
library(RSQLite)
library(tibble)
library(DatabaseConnector)
library(CohortGenerator)
library(CirceR)
library(Capr)


## Set-up config ===============================================================
connectionConfig <- config::get(
  config = "config", file = "./inst/config/connection_config.yml"
)
config_oth <- config::get(
  config = "config", file = "./inst/config/config.yml"
)


## Connect to DB ===============================================================
#  Use connection details from configuration
connectionDetails <- createConnectionDetails(
  dbms = connectionConfig$dbms,
  user = connectionConfig$user,
  password = connectionConfig$password,
  server = connectionConfig$server,
  port = connectionConfig$port,
  oracleDriver = connectionConfig$oracleDriver,
  pathToDriver = connectionConfig$pathToDriver
)


## Concept sets ================================================================
data(conceptSets, package="CaprPHEMS")
# Establish connection
con <- connect(connectionDetails)

conceptSets$conceptSets <- conceptSets$conceptSets %>%
  # Add details for all concepts (excl. descendants)
  lapply(
    FUN = Capr::getConceptSetDetails,
    con = con,
    vocabularyDatabaseSchema = connectionConfig$vocabulary_schema
  )

# Disconnect
disconnect(con)


## Concept counts ==============================================================

# Establish connection
con <- connect(connectionDetails)

CaprPHEMS:::countOccurrences(
  v = conceptSets$concepts$uc1,
  tables = names(links), # Query all CDM tables
  links = CaprPHEMS:::links, # Links between tables and concept_id fields (table:field)
  db_connection = con,
  cdm_schema = connectionConfig$cdm_schema,
  vocab_schema = connectionConfig$vocabulary_schema,
  save_path = config_oth$save_path_counts
)

# Disconnect
disconnect(con)

## Standard and non-standard concepts given a database connection ==============
# Establish connection
con <- connect(connectionDetails)

# Return table of non-standard concepts
CaprPHEMS:::isStandardDB(
  db_connection = con,
  cdm_schema = connectionConfig$cdm_schema,
  vocab_schema = connectionConfig$vocabulary_schema,
  links = CaprPHEMS::links,
  # (optional) Save the results (with standard and non-standard concepts)
  save_path = config_oth$save_path_isStandard
)

# Disconnect
disconnect(con)

## Standard and non-standard concepts given a concept set ======================
# Establish connection
con <- connect(connectionDetails)

# UC2 used as an Example concept set
uc2 <- conceptSets$conceptSets$uc2

# check standardness across concept set
CaprPHEMS::isStandardCS(
  conceptSet = conceptSets$conceptSets$uc2,
  # (optional) Save the results (with standard and non-standard concepts)
  save_path = config_oth$save_path_isStandard
)

# Disconnect
disconnect(con)
