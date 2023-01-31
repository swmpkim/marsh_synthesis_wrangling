# TJR site/transect/plots - for data request spreadsheet
# run TJR rmd through chunk 9

dat_all %>% 
    select(Reserve, SiteID, TransectID, PlotID) %>% 
    distinct() %>% 
    arrange(SiteID, TransectID, PlotID) %>% 
    knitr::kable()


tjr_plots <- dat_all %>% 
    select(Reserve, SiteID, TransectID, PlotID) %>% 
    distinct() %>% 
    arrange(SiteID, TransectID, PlotID)

write.csv(tjr_plots, here::here("wrangled_data",
                                "combined_with_issues",
                                "TJR_plots.csv"))
    