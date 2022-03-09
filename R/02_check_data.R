source(here::here("R", "01_read_data.R"))

library(glue)
library(assertive)

# in theory, all plots should have a row for cover, density, and height
# so make sure those row numbers are equal

nrow(covr) == nrow(dens)
nrow(covr) == nrow(hght)

assert_all_are_equal_to(c(nrow(dens), nrow(hght), nrow(covr)), 
                        nrow(covr))

# are all the 'primary key' values the same across all three sheets?
# everything from Reserve_Code to Distance_to_water_m?
# if we add new columns, we'll need to put them in between these two
# and this will all still work
covr3 <- covr %>% 
    select(Reserve_Code:Distance_to_water)
dens3 <- dens %>% 
    select(Reserve_Code:Distance_to_water)
hght3 <- hght %>% 
    select(Reserve_Code:Distance_to_water)

# want anti-joins to be empty
left_join(covr3, dens3) %>% View()
janitor::compare_df_cols(covr3, hght3)  # checks column names and classes, but not the contents
dplyr::all_equal(dens3, hght3)  # these two ARE the same
dplyr::all_equal(covr3, hght3)
# janitor::compare_df_cols compares column names and classes, but not content
# dplyr::all_equal also checks content and tells you which rows don't match
# it doesn't tell you which columns don't match though
# maybe apply all_equal to each column of the data frames?


identical(dens3, hght3)
identical(covr3, hght3)

# HERE IT IS
test <- purrr::map2_lgl(covr3, dens3, identical)
test[which(test == FALSE)]
glue("Contents of the column `", names(test[which(test == FALSE)]), 
     "` do not match across data frames.")

# can all the species in heights and density be found in cover?  



# do the averages in the density and height sheets match what's pasted in the 'cover' sheet?  

dens_long <- dens %>% 
    select(-Notes) %>% 
    pivot_longer(-(Reserve_Code:Distance_to_water),
                 names_to = "species",
                 values_to = "density")
hght_long <- hght %>% 
    select(-Notes) %>% 
    pivot_longer(-(Reserve_Code:Distance_to_water),
                 names_to = c("genus", "species", "rep"),
                 names_sep = " ",
                 values_to = "height") 