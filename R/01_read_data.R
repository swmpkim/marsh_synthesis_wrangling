library(tidyverse)
library(readxl)

## Read in all the worksheets ----

dat_file <- here::here("data", "template_2022-02-14", "Vegetation Dataset EXAMPLE.xlsx")

stns <- read_xlsx(dat_file,
                  sheet = "Station Table Example")


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
