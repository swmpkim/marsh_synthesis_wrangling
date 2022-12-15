library(tidyverse)
library(readxl)
library(rgdal)

# Set up path, file names, and column names  
path_tiv <- here::here("submitted_data", "data", 
                         "HUD",
                         "HUD Tivoli Veg Data")

csvss <- list.files(path_tiv, pattern = ".csv")
xlsxs <- list.files(path_tiv, pattern = ".xlsx")


col_matching <- c("Orthometric_Height" = "Orthometric Height",
                  "Height_Relative_to_MLLW" = "Height Relative to MLLW",
                  "Ht" = "Canopy Height",
                  "Ht" = "Average Canopy Height",
                  "Ht" = "Maximum Canopy Height",
                  "Ht" = "Canopy Height (m)",
                  "Ht" = "Canopy.Height",
                  "Lat" = "Lat (2013)",
                  "Long" = "Long (2013)",
                  "Elevation" = "Elevation (2013)",
                  "Cover" = "X..Cover",
                  "Cover" = "% Cover")


# pull in and bind csv files  
csvs_in <- list()
for(i in seq_along(csvss)){
    csvs_in[[i]] <- read.csv(here::here(path_tiv, csvss[i]),
                             stringsAsFactors = FALSE) %>% 
        filter(row_number() != 1) %>% 
        rename(any_of(col_matching))
}

if(janitor::compare_df_cols_same(csvs_in)){
    csvs <- bind_rows(csvs_in) %>% 
        mutate(Date = lubridate::mdy(Date))
    message("csvs bound successfully")
} else {warning("CSVS WILL NOT BIND")}


# pull in and bind excel files
excels_in <- list()
for(i in seq_along(xlsxs)){
    tmp <- read_xlsx(here::here(path_tiv, xlsxs[i]),
                             sheet = "Data Entry",
                     guess_max = 2000) %>% 
        filter(row_number() != 1) %>% 
        rename(any_of(col_matching))
    names(tmp)[2] <- "Date"

    excels_in[[i]] <- tmp
}

if(janitor::compare_df_cols_same(excels_in)){
    excels <- bind_rows(excels_in) %>% 
        mutate(Date = lubridate::ymd(Date))
    message("excel files bound successfully")
} else {warning("EXCEL FILES WILL NOT BIND")}


# bind data frames from csv and excel together
if(janitor::compare_df_cols_same(csvs, excels)){
    hud_tiv <- bind_rows(csvs, excels) %>% 
        rename("northing" = "Lat",
               "easting" = "Long") %>% 
        mutate(across(c(northing,
                        easting,
                        Distance,
                        Elevation,
                        Cover,
                        Density,
                        Ht), as.numeric)
               )
    message("csv and excel data frames bound successfully")
} else {warning("CSV AND EXCEL DATA FRAMES WILL NOT BIND")}


# Copied from before - UTM to decimal degrees
## need to correct OTN-3B northing
hud_tiv <- hud_tiv %>% 
    mutate(northing = case_when(PlotID == "OTN-3B" & northing < 3000000 ~ 4654284,
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
    select(Reserve, SiteID, TransectID, PlotID, Lat, Long, 
           northing, easting, everything())
