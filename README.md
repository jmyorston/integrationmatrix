# integration matrix
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

### Run matrix.R
Open matrix.R and click run code, this should generate a CSV table of the integration matrix in the project file.
