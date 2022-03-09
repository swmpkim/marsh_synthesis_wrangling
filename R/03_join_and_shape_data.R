# only run this once checks from script 02 come out ok!
source(here::here("R", "01_read_data.R"))


# to pivot longer:  
# ignore Reserve_Code:Notes
# density: starts with "Density_" and "F_Density_"
# height: starts with "Height_" and "F_Height"
# everything else is cover (species name and F_species name)

# want F_ to be on the same row as the matching species/density/height

# columns I want in the final data frame are:
# Species, Cover, F_Cover, Density, F_Density, Height, F_Height
# 'Species' is buried in different places in the different columns



