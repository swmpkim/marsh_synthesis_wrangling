library(tidyverse)
library(readxl)
library(rgdal)

# Set up path, file names, and column names  
path_tiv <- here::here("submitted_data", "data", 
                       "HUD",
                       "HUD Piermont Veg Data")

xlsxs <- list.files(path_tiv, pattern = ".xlsx")


col_matching <- c("Orthometric_Height" = "Orthometric Height",
                  "Height_Relative_to_MLLW" = "Height Relative to MLLW",
                  "Ht" = "Canopy Height",
                  "Ht" = "Average Canopy Height",
                  "Ht" = "Maximum Canopy Height",
                  "Ht" = "Canopy Height (m)",
                  "Ht" = "Canopy.Height",
                  "Lat" = "Lat (2013)",
                  "Lat" = "Lat (LiDAR2020)",
                  "Long" = "Long (2013)",
                  "Long" = "Long (LiDAR2020)",
                  "Elevation" = "Elevation (2013)",
                  "Elevation" = "Elevation (LiDAR2020)",
                  "Cover" = "X..Cover",
                  "Cover" = "% Cover")


# pull in and bind excel files
excels_in <- list()
for(i in seq_along(xlsxs)){
    tmp <- read_xlsx(here::here(path_tiv, xlsxs[i]),
                     sheet = "Data Entry",
                     guess_max = 2000) %>% 
        filter(row_number() != 1) %>% 
        rename(any_of(col_matching))
    
    excels_in[[i]] <- tmp
}

if(janitor::compare_df_cols_same(excels_in)){
    hud_pier <- bind_rows(excels_in) %>% 
        mutate(Date = lubridate::ymd(Date),
               across(c(Lat, Long, Elevation), 
                      as.numeric)) %>% 
        rename("northing" = "Lat",
               "easting" = "Long")
    message("excel files bound successfully")
} else {warning("EXCEL FILES WILL NOT BIND")}


# UTM to decimal degrees

# first need to get rid of NAs in easting and northing
hud_pier2 <- hud_pier %>% 
    filter(!is.na(easting),
           !is.na(northing))

points <- hud_pier2 %>% 
    select(easting, northing)
# code below modified from stack overflow https://stackoverflow.com/a/30018607
sputm <- SpatialPoints(points, proj4string=CRS("+proj=utm +zone=18 +datum=WGS84")) 
spgeo <- spTransform(sputm, CRS("+proj=longlat +datum=WGS84"))
lnlt <- data.frame(coordinates(spgeo))

hud_pier3 <- hud_pier2 %>% 
    mutate(Lat = lnlt$northing,
           Long = lnlt$easting)

hud_pier <- left_join(hud_pier, hud_pier3) %>% 
    mutate(Reserve = "HUD-PIER") %>% 
    select(Reserve, PlotID, Lat, Long, 
           northing, easting, everything())

# clean up
rm(excels_in, xlsxs, lnlt, points,
   spgeo, sputm, tmp, col_matching, 
   hud_pier2, hud_pier3)



############### CHECKS ##########################
dat_all <- hud_pier
# Column names and types
names(dat_all)

# Duplicates in date-site-transect-plot-species
# we want to see an empty table
# # no subplot included
dupes <- dat_all %>%
    select(Date, PlotID,  Species, Cover, Density, Ht) %>% 
    janitor::get_dupes(-c(Cover, Density, Ht))
# write.csv(dupes, here::here("wrangled_data", "combined_with_issues", "HUD-PIER_dupes.csv"),
#           row.names = FALSE)

# Station/plot names
unique(dat_all$Reserve)
dat_all %>% 
    select(Reserve, PlotID) %>% 
    distinct() %>% 
    knitr::kable()



# Check for mangroves/SAV - looking for something other than 'E' in 'Type'
unique(dat_all$`Plot Type`)


# Check species names
dat_all$Species <- str_replace(dat_all$Species, pattern = "  ", replacement = " ")
spp <- dat_all %>% 
    group_by(Species) %>% 
    tally()
spp_out_path <- here::here("wrangled_data", "combined_with_issues", "HUD-PIER_species.csv") 
write.csv(spp, spp_out_path, row.names = FALSE)
# looks good
