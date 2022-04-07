library(tidyverse)
library(readxl)

## Read in all the worksheets ----

dat_file <- here::here("data", "Vegetation Dataset EXAMPLE.xlsx")

stns <- read_xlsx(dat_file,
                  sheet = "Station_Table")

covr <- read_xlsx(dat_file,
                  sheet = "Cover")

dens <- read_xlsx(dat_file,
                  sheet = "Density")

hght <- read_xlsx(dat_file,
                  sheet = "Height")  


# Species worksheet has a lot of steps ----
spps <- read_xlsx(dat_file, 
                  sheet = "Species_Names")


## Make data formats consistent  ----
# make a function and then use it on all three data frames  

# this is going to throw errors if anything is wrong in the files though
# and eventually there WILL be things wrong in the files
# FIGURE OUT HOW TO TEST AND DEAL WITH THIS
### how to ask "is this coercible to the class I want?" 
format_veg_in <- function(x){
    to_form <- x
    to_form %>% 
        mutate(across(c(Reserve, SiteID, TransectID,
                        PlotID, Unique_ID, Type,
                        Vegetation_Zone, starts_with("F_")),
                      as.character),
               across(c(Year, Month, Day, Orthometric_Height, 
                        Height_Relative_to_MLLW, Distance_to_water,
                        starts_with("Average"),
                        starts_with("Diameter"),
                        starts_with("Height"),
                        starts_with("Density")),
                      as.numeric))
    
}

dens <- format_veg_in(dens)
covr <- format_veg_in(covr)
hght <- format_veg_in(hght)
