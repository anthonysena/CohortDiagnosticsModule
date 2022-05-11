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

# Format and check code:
styler::style_pkg()
OhdsiRTools::updateCopyrightYearFolder()
OhdsiRTools::findNonAsciiStringsInFolder()
devtools::spell_check()


# Copy results data model specs from CohortDiagnostics package
resultsDataModel <- readr::read_csv(file = system.file("settings", "resultsDataModelSpecification.csv", package = "CohortDiagnostics"),
                                    show_col_types = FALSE)
readr::write_csv(resultsDataModel, "resultsDataModelSpecification.csv")


# Generate renv lock file and activate renv:
OhdsiRTools::createRenvLockFile(rootPackage = "CohortDiagnostics",
                                includeRootPackage = TRUE,
                                mode = "description",
                                additionalRequiredPackages = c("checkmate", "CirceR", "CohortGenerator"))
renv::init()
