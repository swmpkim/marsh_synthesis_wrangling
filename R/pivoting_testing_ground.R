library(tidyverse)
source(here::here("R", "01_read_data.R"))

# after sourcing 01_read_data, can use:
testnames <- names(covr)

# identify the id columns that shouldn't get "Cover_" pasted on
# want to use Reserve_Code:Notes as the id_cols
id_cols <- 1:which(testnames == "Notes")

# index the known non-cover columns
dens_vars <- str_which(testnames, "Density")
ht_vars <- str_which(testnames, "Height")
diam_vars <- str_which(testnames, "Diameter")
f_vars <- str_which(testnames, "F_")


# make a vector of all the indices above
big_index <- unique(c(dens_vars, ht_vars, diam_vars, f_vars))
# paste Cover_ to all the stuff *not* identified already
testnames[-c(big_index, id_cols)] <- paste0("Cover_",
                                            testnames[-c(big_index, id_cols)])

# Replace F_ with QAQC_ 
testnames <- str_replace(testnames, "F_", "QAQC_")


covr2 <- covr
names(covr2) <- testnames
covr_long <- pivot_longer(covr2,
                          -all_of(id_cols),
                          names_to = c(".value", "Species"),
                          names_sep = "_")

write.csv(covr_long, here::here("data", "cdmo_format_out", "cover_long.csv"), row.names = FALSE)
