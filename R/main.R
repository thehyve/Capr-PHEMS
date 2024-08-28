## Load libraries ==============================================================
library(RSQLite)
library(tibble)
library(DatabaseConnector)
library(CohortGenerator)
library(CirceR)
library(Capr)


## Set-up config ===============================================================
connectionConfig <- config::get(
  config = 'config', file = './inst/config/connection_config.yml')
config_oth <- config::get(
  config = 'config', file = './inst/config/config.yml')


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
source("./R/conceptSets.R")

# Establish connection
con <- connect(connectionDetails)

conceptSets$conceptSets <- conceptSets$conceptSets %>%
  # Add details for all concepts (excl. descendants)
  lapply(FUN = getConceptSetDetails,
         con = con,
         vocabularyDatabaseSchema = connectionConfig$vocabulary_schema)


## Concept counts ==============================================================

# Get countOccurrences function
source("./R/countOccurrences.R")

# Get links between tables and fields as input
source("./R/table_linked_to_concept_field.R")

uc1Counts <-
  countOccurrences(
    v = conceptSets$concepts$uc1,
    tables = names(links), # Query all CDM tables
    links = links, # Links between tables and concept_id fields (table:field)
    db_connection = con,
    cdm_schema = connectionConfig$cdm_schema,
    vocab_schema = connectionConfig$vocabulary_schema,
    save_path = config_oth$save_path_counts
  )


## Standard and non-standard concepts given a list of concept IDs ==============
# Return table of non-standard concepts
source('./R/isStandard.R')
nonStandard <- isStandard(
  db_connection = con,
  data_concepts_path = config_oth$concepts_path,
  vocab_schema = connectionConfig$vocabulary_schema,
  # (optional) Save the results (with standard and non-standard concepts)
  save_path = config_oth$save_path_isStandard
)


## Standard and non-standard concepts given a concept set ======================
# run for uc2 conceptSet
uc2 <- conceptSets$conceptSets$uc2

# check standardness across concept set
source('./R/isStandardCS.R')
nonStandardCS <- isStandardCS(
  db_connection = con,
  conceptSet = conceptSets$conceptSets$uc2,
  # (optional) Save the results (with standard and non-standard concepts)
  save_path = config_oth$save_path_isStandard
)

# Disconnect
disconnect(con)