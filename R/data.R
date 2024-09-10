#' @name conceptSets
#' @title Concept set definitions by use case
#'
#' @description
#' ConceptSets related to PHEMS variables are defined in ./data_raw/conceptSetsPHEMS.R. The base Capr library is used to fetch all descendant concepts
#' for each defined concept set, ensuring comprehensive coverage of related medical concepts.
#'
#' @details The script initializes by defining multiple concept sets within a list structure. Each concept set contains unique identifiers for medical concepts,
#' which are expanded to include all descendant concepts using the Capr library's functionality. The expanded concept sets are then stored in a new list within
#' the `conceptSets` object. Finally, the script outputs a confirmation message indicating successful sourcing and expansion of concept sets.
#'
#' @note This script requires the Capr library to be installed and loaded for proper execution.
#' @note Duplicated concepts within the same UC have been removed; keeping the first occurrence.
"conceptSets"