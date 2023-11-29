dat |> 
    summarize(.by = c(Year, Month, Day, SiteID, TransectID, PlotID),
              total = sum(Cover, na.rm = TRUE)) |> 
    arrange(total) |> 
    View()

dat |> 
    filter(Species == "Unvegetated") |> 
    View()


fixed <- read_csv(here::here("wrangled_data", "combined_with_issues",
                              "GND_fixedRound2.csv"))
fixed |> 
    summarize(.by = c(Year, Month, Day, SiteID, TransectID, PlotID),
              total = sum(Cover, na.rm = TRUE)) |> 
    arrange(total) |> 
    View()

unique(fixed$Species)


latest_cdmo <- read_xlsx(here::here("wrangled_data", "CDMO",
                                    "GND_CDMO.xlsx"))

latest_cdmo |> 
    summarize(.by = c(Year, Month, Day, SiteID, TransectID, PlotID),
              total = sum(Cover, na.rm = TRUE)) |> 
    filter(!is.na(Year)) |> 
    arrange(total) |> 
    View()

"Unvegetated" %in% unique(latest_cdmo$Species)

unique(fixed$SiteID)
unique(latest_cdmo$SiteID)

site_issues <- read_xlsx(here::here("wrangled_data", 
                                           "combined_with_issues",
                                           "GND_CDMO_SiteIssues.xlsx"),
                                na = c("", "NA")) 
unique(site_issues$SiteID)
"Unvegetated" %in% unique(site_issues$Species)

non100s <- latest_cdmo |> 
    summarize(.by = c(Year, Month, Day, SiteID, TransectID, PlotID),
              total = sum(Cover, na.rm = TRUE)) |> 
    filter(!is.na(Year),
           total != 100) 

non100s_full <- left_join(non100s, latest_cdmo) |> 
    select(Year:total,
           Species,
           Cover)
