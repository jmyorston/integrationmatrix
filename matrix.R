# Load packages -----------------------------------------------------------
library(httr)
library(tidyverse)
library(tidyjson)
library(foreach)
library(doParallel)

startTime <- Sys.time()

authKey <- Sys.getenv("APIKEY")

# Auth Details ------------------------------------------------------------
headers <-
  c("authorization" = authKey, "accept" = "application/json")


# GET Journals ------------------------------------------------------------
getIntegrations <-  GET(
  paste(
    "https://api.codat.io/integrations?useDefaultKeys=false&page=1&pageSize=5000"
  ),
  add_headers(headers)
)
integrations <- content(getIntegrations, as = 'parsed')[["results"]]

# Set up parallel backend
num_cores <- detectCores() - 1
registerDoParallel(cores = num_cores)

# Process integrations using parallel execution
integrations_df <- foreach(result = integrations, .combine = bind_rows) %dopar% {
  if (result[["sourceType"]] == "Accounting") {
    lapply(result[["datatypeFeatures"]], function(dtf) {
      lapply(dtf[["supportedFeatures"]], function(sf) {
        data.frame(Platform = result[["name"]],
                   DataType = ifelse(is.na(dtf[["datatype"]]), "N/A", dtf[["datatype"]]),
                   HTTP = ifelse(is.na(sf[["featureType"]]), "N/A", sf[["featureType"]]),
                   Status = ifelse(is.na(sf[["featureState"]]), "N/A", sf[["featureState"]]))
      })
    }) %>% bind_rows()
  }
}

names(integrations_df)[1] <- "Platform"
names(integrations_df)[2] <- "DataType"
names(integrations_df)[3] <- "HTTP"
names(integrations_df)[4] <- "Status"

integrationMatrix <- integrations_df  %>% mutate(
  Status2 = case_when(
    Status == "Release" ~ TRUE,
    Status == "Beta" ~ TRUE,
    Status == "Alpha" ~ TRUE,
    Status == "NotImplemented" ~ FALSE,
    Status == "NA" ~ FALSE,
    TRUE ~ FALSE,
  )
) %>% select(DataType, HTTP, Platform, Status2) %>%
  pivot_wider(names_from = Platform, values_from = Status2)

write.csv(integrationMatrix,"integrationMatrix.csv")

endTime <- Sys.time()

timeTaken <- round(endTime - startTime,2)

timeTaken

