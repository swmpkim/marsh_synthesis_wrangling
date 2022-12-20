library(tidyverse)
library(readxl)
library(rgdal)
library(writexl)

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
    tmp <- fill(tmp, Date, .direction = "up")
    
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
                        easting
                        # Distance,
                        # Elevation
                        # Cover,
                        # Density,
                        # Ht
                        ), as.numeric)
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
           Reserve = "HUD-TIV") %>% 
    rename(TransectID = Transect.ID) %>% 
    select(Reserve, SiteID, PlotID, Lat, Long, 
           northing, easting, everything())

# clean up
rm(csvs, csvs_in, excels, excels_in, lnlt, points,
   spgeo, sputm, tmp, col_matching, csvss, xlsxs)


############### CHECKS ##########################
dat_all <- hud_tiv
# Column names and types
names(dat_all)

# Duplicates in date-site-transect-plot-species
# we want to see an empty table
unique(dat_all$Subplot)

# subplot included
# dat_all %>% 
#     group_by(Date, SiteID, TransectID, PlotID, Subplot, Species) %>% 
#     tally() %>% 
#     filter(n > 1) %>% 
#     select(Date:Species, n)

# # no subplot included
dupes <- dat_all %>%
    select(Date, SiteID, TransectID, PlotID,  Species, Cover, Density, Ht) %>% 
    janitor::get_dupes(-c(Cover, Density, Ht))
write.csv(dupes, here::here("wrangled_data", "combined_with_issues", "HUD-TIV_dupes.csv"),
          row.names = FALSE)

# get rid of the 9 exact dupes
dat_all <- dat_all %>% 
    distinct(Date, SiteID, PlotID, Species, .keep_all = TRUE)

# Station/plot names
unique(dat_all$Reserve)
dat_all %>% 
    select(Reserve, SiteID, TransectID, PlotID) %>% 
    distinct() %>% 
    knitr::kable()
# some issues because of TransectID being labelled vs. NA


# Distance discrepancies
stn_dupes <- dat_all %>% 
    select(Reserve, SiteID, TransectID, PlotID,
           Distance) %>% 
    distinct() %>% 
    janitor::get_dupes(-Distance)
stn_dupes


# Check for mangroves/SAV - looking for something other than 'E' in 'Type'
unique(dat_all$Type)


# Check species names
dat_all$Species <- str_replace(dat_all$Species, pattern = "  ", replacement = " ")
spp <- dat_all %>% 
    group_by(Species) %>% 
    tally()
spp_out_path <- here::here("wrangled_data", "combined_with_issues", "HUD-TIV_species.csv") 
write.csv(spp, spp_out_path, row.names = FALSE)
# looks good


################ CDMO FORMATTING ######################
dat_all <- dat_all %>% 
    mutate(
        Year = lubridate::year(Date),
        Month = lubridate::month(Date),
        Day = lubridate::mday(Date),
        Date = format(Date, "%m/%d/%Y")
    ) 

dat_all$`SSAM-1` <- "Y"
dat_all$`Height Relative to MLLW` <- NA
dat_all$QAQC <- NA
dat_all$Diameter <- NA
dat_all$Height <- NA

dat_cdmo <- dat_all %>% 
    select(
        "Reserve",
        "Type",
        "Date",
        "Year",
        "Month",
        "Day",
        "SiteID",
        "TransectID",
        "PlotID",
        "Subplot",
        "Rep",
        "SSAM-1",
        "Lat",
        "Long",
        "Distance",
        "Orthometric Height" = "Elevation",
        "Height Relative to MLLW",
        "Species",
        "Cover",
        "Density",
        "Ht",
        "Diameter",
        "Height",
        "QAQC"
    )

write_xlsx(dat_cdmo, 
           path = here::here("wrangled_data", "CDMO", "HUD-TIV_CDMO.xlsx"),
           format_headers = TRUE)

##### NAMASTE TABLES #######
