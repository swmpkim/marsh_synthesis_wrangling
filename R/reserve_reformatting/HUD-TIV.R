library(tidyverse)
library(readxl)
library(rgdal)

# Set up path and get file names  
path_tiv <- here::here("submitted_data", "data", 
                         "HUD",
                         "HUD Tivoli Veg Data")

csvs <- list.files(path_tiv, pattern = ".csv")
xlsxs <- list.files(path_tiv, pattern = ".xlsx")


# pull in and bind csv files  
csvs_in <- list()
for(i in seq_along(csvs)){
    csvs_in[[i]] <- read.csv(here::here(path_tiv, csvs[i]),
                             stringsAsFactors = FALSE) %>% 
        filter(row_number() != 1)
}

if(janitor::compare_df_cols_same(csvs_in) == TRUE){
    csvs <- bind_rows(csvs_in)
    message("csvs bound successfully")
} else {warning("CSVS WILL NOT BIND")}


# pull in and bind excel files
excels_in <- list()
for(i in seq_along(xlsxs)){
    tmp <- read_xlsx(here::here(path_tiv, xlsxs[i]),
                             sheet = "Data Entry",
                     guess_max = 2000) %>% 
        filter(row_number() != 1)
    names(tmp)[2] <- "Date"

    excels_in[[i]] <- tmp
}

if(janitor::compare_df_cols_same(excels_in) == TRUE){
    excels <- bind_rows(excels_in)
    message("excel files bound successfully")
} else {warning("EXCEL FILES WILL NOT BIND")}




# Copied from before - UTM to decimal degrees
## Also need to correct OTN-3B northing
hud_tiv <- hud_tiv %>% 
    mutate(northing = case_when(PlotID == "OTN-3B" ~ 4654284,
                                TRUE ~ northing))

points <- hud_tiv %>% 
    select(easting, northing)
# code below modified from stack overflow https://stackoverflow.com/a/30018607
sputm <- SpatialPoints(points, proj4string=CRS("+proj=utm +zone=18 +datum=WGS84")) 
spgeo <- spTransform(sputm, CRS("+proj=longlat +datum=WGS84"))
lnlt <- data.frame(coordinates(spgeo))

hud_tiv <- hud_tiv %>% 
    mutate(Lat = lnlt$northing,
           Long = lnlt$easting,
           Reserve = "HUD",
           SiteID = "TIV") %>% 
    separate(PlotID, into = c("TransectID", "PlotID"), sep = "-") %>% 
    select(Reserve, SiteID, TransectID, PlotID, Lat, Long, northing, easting)
