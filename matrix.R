# Load packages -----------------------------------------------------------
library(httr)
library(tidyr)
library(dplyr)


authKey <- Sys.getenv("APIKEY")

# Auth Details ------------------------------------------------------------
headers <-
  c("authorization" = authKey, "accept" = "application/json")


# GET Integrations ------------------------------------------------------------
getIntegrations <-  GET(
  paste(
    "https://api.codat.io/integrations?useDefaultKeys=false&page=1&pageSize=5000"
  ),
  add_headers(headers)
)
integrations <- content(getIntegrations, as = 'parsed')[["results"]]

# Process integrations using parallel execution
getIntegrations <-  GET("https://api.codat.io/integrations?useDefaultKeys=false&page=1&pageSize=5000", add_headers(headers))
integrations <- content(getIntegrations, as = 'parsed')[["results"]]

# Helper function to process each element
process_element <- function(result, sourceType) {
  tryCatch({
    if (result[["sourceType"]] == sourceType) {
      dtf_list <- lapply(result[["datatypeFeatures"]], function(dtf) {
        sf_list <- lapply(dtf[["supportedFeatures"]], function(sf) {
          data.frame(
            Platform = result[["name"]],
            DataType = ifelse(is.na(dtf[["datatype"]]), "N/A", dtf[["datatype"]]),
            HTTP = ifelse(is.na(sf[["featureType"]]), "N/A", sf[["featureType"]]),
            Status = ifelse(is.na(sf[["featureState"]]), "N/A", sf[["featureState"]])
          )
        })
        do.call(rbind, sf_list)
      })
      do.call(rbind, dtf_list)
    } else {
      NULL
    }
  }, error = function(e) {
    print(paste0("Error in processing ", sourceType, ": ", e))
    NULL
  })
}

# Apply helper function to integrations list
integrations_df_accounting <- do.call(rbind, lapply(integrations, process_element, sourceType = "Accounting"))
integrations_df_commerce <- do.call(rbind, lapply(integrations, process_element, sourceType = "Commerce"))


# helper function to reformat the dataframe
format_dataframe <- function(df) {
  names(df)[1] <- "Platform"
  names(df)[2] <- "DataType"
  names(df)[3] <- "HTTP"
  names(df)[4] <- "Status"
  
  df <- df %>% mutate(
    Status2 = case_when(
      Status == "Release" ~ TRUE,
      Status == "Beta" ~ TRUE,
      Status == "Alpha" ~ TRUE,
      Status == "NotImplemented" ~ FALSE,
      Status == "NA" ~ FALSE,
      TRUE ~ FALSE
    )
  ) %>% select(DataType, HTTP, Platform, Status2) %>%
    pivot_wider(names_from = Platform, values_from = Status2)
  
  return(df)
}

# reformat the dataframes
integrations_df_commerce <- format_dataframe(integrations_df_commerce)
integrations_df_accounting <- format_dataframe(integrations_df_accounting)


write.csv(integrations_df_commerce,"commerceIntegrationMatrix.csv")
write.csv(integrations_df_accounting,"accountingIntegrationMatrix.csv")

