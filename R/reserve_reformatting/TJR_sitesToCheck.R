library(tidyverse)
library(readxl)
source(here::here("R", "sourced", "00_helper_functions.R"))

# read in wrangled TJR site info table  
tjr_sites <- read_xlsx(here::here("wrangled_data", "NMST", "TJR_NMST.xlsx"),
                       sheet = "Station_Table") %>% 
    select(Reserve, SiteID, TransectID, PlotID, Type)

# read in 2012 TJR file  
tjr_2012 <- read_cdmo("TJRVEG2012.xlsx")

# get unique lat/longs by site from TJR file  
tjr_meta <- tjr_2012 %>% 
    select(SiteID, TransectID, PlotID,
           Type, Lat, Long, 
           Distance, Elevation) %>% 
    group_by(SiteID, TransectID, PlotID) %>% 
    distinct() %>% 
    arrange(SiteID, TransectID, PlotID)
    

# is there only one per site?  
janitor::get_dupes(tjr_meta, SiteID, TransectID, PlotID)
# V3 Northwest 41 has two rows. Must be similar, based on what's printed.


# join with site info from wrangled file  
tjr_all <- full_join(tjr_sites, tjr_meta,
                     by = c("SiteID", "TransectID", "PlotID")) %>% 
    arrange(SiteID, TransectID, PlotID)


# write back out and send to Jeff for verification  
writexl::write_xlsx(tjr_all, path = "TJR_sitesToCheck.xlsx")
