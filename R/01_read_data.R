library(tidyverse)
library(readxl)

## Read in all the worksheets ----

dat_file <- here::here("data", "template_2022-02-14", "Vegetation Dataset EXAMPLE.xlsx")

stns <- read_xlsx(dat_file,
                  sheet = "Station Table Example")

covr <- read_xlsx(dat_file,
                  sheet = "Cover Example")

dens <- read_xlsx(dat_file,
                  sheet = "Density Example")

hght <- read_xlsx(dat_file,
                  sheet = "Height Example 2")  # this one looks like it allows for replicates


# Species worksheet has a lot of steps ----
spps_index <- read_xlsx(dat_file, 
                  sheet = "Species Names Example",
                  col_names = FALSE)

# find the row that contains the headers
# apply the following to all the columns
non_na_spps <- apply(spps_index, MARGIN = 2, FUN = function(x) which(!is.na(x))[1])

# output should be 1 and a bunch of equal numbers
# might not be 1 if people insert rows, so maybe this check doesn't matter
sum(non_na_spps == 1) == 1

# but we do want the max of that; the number where the first non-NA position
# is the same for every column is our row of headers
# again though, people may do weird things, so I don't want to just pull out the 'max'
# i think i want to go for frequency
tabl_non_nas <- table(non_na_spps)

# because it's a named table - only uses column indices - can figure out
# which column has the highest count, and then find the name of that column
# and then turn it into a number
ind <- as.numeric(names(tabl_non_nas)[which(tabl_non_nas == max(tabl_non_nas))])

# now read in the species table starting with that row
spps <- read_xlsx(dat_file,
                  sheet = "Species Names Example",
                  skip = ind-1)

# clean up
rm(spps_index, non_na_spps, tabl_non_nas, ind)


## Make data formats consistent  ----
# make a function and then use it on all three data frames  

# this is going to throw errors if anything is wrong in the files though
# and eventually there WILL be things wrong in the files
# FIGURE OUT HOW TO TEST AND DEAL WITH THIS
### how to ask "is this coercible to the class I want?" 
format_veg_in <- function(x){
    to_form <- x
    to_form %>% 
        mutate(across(c(Reserve_Code, Site, Site_Code, Transect_Number,
                        Plot_Number, Unique_ID, Habitat_Type,
                        Vegetation_Zone, starts_with("F_")),
                      as.character),
               across(c(Year, Month, Day, Elevation_NAVD88, 
                        Elevation_Relative_to_MLLW, Distance_to_water_m),
                      as.numeric))
    
}

dens2 <- format_veg_in(dens)


