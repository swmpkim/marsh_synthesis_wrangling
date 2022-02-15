source(here::here("R", "01_read_data.R"))

# in theory, all plots should have a row for cover, density, and height
# right??? 
# so make sure those row numbers are equal

nrow(covr) == nrow(dens)
nrow(covr) == nrow(hght)



# are all the 'primary key' values the same across all three sheets?
# everything from Reserve_Code to Distance_to_water_m?
# if we add new columns, we'll need to put them in between these two
# and this will all still work
covr2 <- covr %>% 
    select(Reserve_Code:Distance_to_water_m)
dens2 <- dens %>% 
    select(Reserve_Code:Distance_to_water_m)
hght2 <- hght %>% 
    select(Reserve_Code:Distance_to_water_m)

anti_join(covr2, dens2)
anti_join(covr2, hght2)
# Error: Can't combine `Plot_Number` <double> and `Plot_Number` <character>.
# so need to go back to 01 and specify (and enforce?) data classes





# can all the species in heights and density be found in cover?  



# do the averages in the density and height sheets match what's pasted in the 'cover' sheet?  