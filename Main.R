# Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of CohortDiagnosticsModule
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Module methods -------------------------
validate <- function(jobContext) {
  # Verify the job context details - this feels like a task to centralize for
  # all modules
  checkmate::assert_list(x = jobContext)
  if (is.null(jobContext$settings)) {
    stop("Analysis settings not found in job context")
  }
  if (is.null(jobContext$sharedResources)) {
    stop("Shared resources not found in job context")
  }
  if (is.null(jobContext$moduleExecutionSettings)) {
    stop("Execution settings not found in job context")
  }
  
  # Validate that the analysis specification will work when we 
  # enter the execute statement. Bad thing here: we're doing
  # double work to construct the cohort definition set but I'm
  # unsure if validate() should potentially change the jobContext
  # to add any necessary elements to the executionSettings list?
  cohortDefinitionSet <- createCohortDefinitionSetFromJobContext(sharedResources = jobContext$sharedResources)
  invisible(cohortDefinitionSet)
}

execute <- function(jobContext) {
  message("Generating cohort definition set")
  cohortDefinitionSet <- createCohortDefinitionSetFromJobContext(sharedResources = jobContext$sharedResources)

  message("Executing cohort diagnostics")
  args <- jobContext$settings
  args$cohortDefinitionSet <- cohortDefinitionSet
  args$exportFolder <- jobContext$moduleExecutionSettings$resultsSubFolder
  args$databaseId <- jobContext$moduleExecutionSettings$databaseId
  args$connectionDetails <- jobContext$moduleExecutionSettings$connectionDetails
  args$cdmDatabaseSchema <- jobContext$moduleExecutionSettings$cdmDatabaseSchema
  args$cohortDatabaseSchema <- jobContext$moduleExecutionSettings$workDatabaseSchema
  args$cohortTableNames <- jobContext$moduleExecutionSettings$cohortTableNames
  args$incrementalFolder <- jobContext$moduleExecutionSettings$workSubFolder
  args$minCellCount <- jobContext$moduleExecutionSettings$minCellCount
  do.call(CohortDiagnostics::executeDiagnostics, args)
}

# Private methods -------------------------
createCohortDefinitionSetFromJobContext <- function(sharedResources) {
  cohortDefinitions <- list()
  if (length(sharedResources) <= 0) {
    stop("No shared resources found")
  }
  for (i in 1:length(sharedResources)) {
    if (which(class(jobContext$sharedResources[[i]]) %in% "CohortDefinitionSharedResources") > 0) {
      cohortDefinitions <- jobContext$sharedResources[[i]]$cohortDefinitions
      break;
    }
  }
  if (length(cohortDefinitions) <= 0) {
    stop("No cohort definitions found")
  }
  cohortDefinitionSet <- CohortGenerator::createEmptyCohortDefinitionSet()
  for (i in 1:length(cohortDefinitions)) {
    cohortJson <- cohortDefinitions[[i]]$cohortDefinition
    cohortExpression <- CirceR::cohortExpressionFromJson(cohortJson)
    cohortSql <- CirceR::buildCohortQuery(cohortExpression, options = CirceR::createGenerateOptions(generateStats = FALSE))    
    cohortDefinitionSet <- rbind(cohortDefinitionSet, data.frame(cohortId = as.integer(cohortDefinitions[[i]]$cohortId),
                                                                 cohortName = cohortDefinitions[[i]]$cohortName, 
                                                                 sql = cohortSql,
                                                                 cohortJson = cohortJson,
                                                                 stringsAsFactors = FALSE))    
  }
  return(cohortDefinitionSet)
}
