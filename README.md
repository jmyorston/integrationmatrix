# Integration Matrix
A simple R script to output a csv file of Codat's supported datatypes by accounting integration.

# Set Up
### Download R & Rstudio
Download and install R and RStudio [from here](https://posit.co/download/rstudio-desktop/)

### Clone the repository into R Studio
Open R studio and select 
1. "File" from the menu
1. "New Project..." 
1. "Version Control" then "Git"

and import the repo using the https link
```
https://github.com/jmyorston/integrationmatrix.git
```

###  Install dependencies
In Rstudio, run the following commands to install the required packages
```
install.packages(c('httr', 'tidyverse', 'tidyjson'))
```

### Add API Key
Add your authorization key from the portal in the Auth details section -
``` R
# Auth Details ------------------------------------------------------------
authKey <-
  "Basic xxxxxx"
headers <-
  c("authorization" = authKey, "accept" = "application/json")

```
By default the api key is stored in an actions secret, but you can replace `Sys.getenv("APIKEY")` with your api key from Codat.

### Run matrix.R
Open matrix.R and click run code, this should generate a CSV table of the integration matrix in the project file.


### Keeping `integrationMatrix.csv` up to date
This repo uses github actions to keep the .csv up to date with the latest supported datatypes. 
To use actions in your own repo, create two variables in the actions secrets and variables:
- `APIKEY` - this should be your api key for Codat 
- `GITHUB` - this should be your github token which will allow the action to commit to the repo
  - See [here](https://docs.github.com/en/enterprise-server@3.4/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for more info on creating a token
  - When you create a new personal access token, you should assign the repo scope to it. The repo scope includes all the necessary permissions for working with repositories, including pushing changes.
  
The action then runs a cron job at the specified time e.g. `'0 0 * * *'` is daily and if there are any changes in supported datatypes, these are reflected and committed to the repo via the `integrationMatrix.csv` file - so it is always up to date.

