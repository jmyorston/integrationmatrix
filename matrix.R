# Load packages -----------------------------------------------------------
library(httr)
library(tidyverse)
library(tidyjson)
#library(plyr)
#library(lubridate)


# Auth Details ------------------------------------------------------------
authKey <-
  "Basic xxx"
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

integrations_df <- data.frame()

for (result in 1:length(integrations)) {
  if (integrations[[result]][["sourceType"]] == "Accounting") {
    for (dtf in 1:length(integrations[[result]][["datatypeFeatures"]])) {
      for (sf in 1:length(integrations[[result]][["datatypeFeatures"]][[dtf]][["supportedFeatures"]])) {
        integrations_df <- rbind.data.frame(integrations_df,
                                            c(integrations[[result]][["name"]],
                                              if (is.na(integrations[[result]][["datatypeFeatures"]][[dtf]][["datatype"]])) {
                                                "N/A"
                                              } else {
                                                integrations[[result]][["datatypeFeatures"]][[dtf]][["datatype"]]
                                              },
                                              if (is.na(integrations[[result]][["datatypeFeatures"]][[dtf]][["supportedFeatures"]][[sf]][["featureType"]])) {
                                                "N/A"
                                              } else {
                                                integrations[[result]][["datatypeFeatures"]][[dtf]][["supportedFeatures"]][[sf]][["featureType"]]
                                              },
                                              if (is.na(integrations[[result]][["datatypeFeatures"]][[dtf]][["supportedFeatures"]][[sf]][["featureState"]])) {
                                                "N/A"
                                              } else {
                                                integrations[[result]][["datatypeFeatures"]][[dtf]][["supportedFeatures"]][[sf]][["featureState"]]
                                              }))
      }
    }
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
