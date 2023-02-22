# list the file and the sheet names  

print(fls[i])

# are sheet names correct (compare to sht_names from qmd file)
shts <- excel_sheets(fls2[i])
if(!identical(shts, sht_names)){
    cli::cli_warn(c("Sheet names do not match correctly",
                    "i" = "Sheet names should be: {sht_names}", 
                    "x" = "but are: {shts}"))
}


# read in Cover sheet  
# STOP IF THERE IS NO COVER SHEET
# don't want it to quit the loop though, just this script 
# how to make it return early......
if(!("Cover" %in% shts)){
    cli::cli_abort(c("!" = "There is no sheet named Cover"))
}

# are identifying column names correct
covr <- read_xlsx(fls2[i],
                  sheet = "Cover",
                  guess_max = 5000)
col_chk <- id_cols %in% names(covr)
if(sum(!(col_chk)) > 0){
    cli::cli_warn(c("Identifying columns are missing from the Cover sheet",
                    "x" = "Missing columns are: {id_cols[!col_chk]}"))
}

# check for duplicate rows  
janitor::get_dupes(covr,
                   Year, SiteID, TransectID, PlotID)


# species name checks  
# species columns start after Notes
spp_covr <- covr %>%
    filter(row_number() == 1) %>% 
    select(-(1:Notes),
           -starts_with("F_"))

# density columns from cover sheet
spp_cvr_dens <- spp_covr %>% 
    select(starts_with("Density")) %>% 
    names() %>% 
    str_remove("Density_")

# height columns from cover sheet
spp_cvr_ht <- spp_covr %>% 
    select(contains("Height")) %>% 
    names() 
ht_type <- str_split(spp_cvr_ht, pattern = "_")[[1]][1]
spp_cvr_ht <- str_remove(spp_cvr_ht, paste0(ht_type, "_"))
# what is reported
print(glue("Height is reported as '{ht_type}'"))

# density species are in the other cover species, right?
dens_check <- spp_cvr_dens %in% names(spp_covr)
if(sum(!dens_check) > 0){
    cli::cli_warn(c("Species with reported density measurements 
                    on the main (Cover) worksheet do not have
                    reported cover data; is something misspelled?",
                    "x" = "{spp_cvr_dens[!dens_check]}"))
}

# and height
ht_check <- spp_cvr_ht %in% names(spp_covr)
if(sum(!ht_check) > 0){
    cli::cli_warn(c("Species with reported height measurements 
                    on the main (Cover) worksheet do not have
                    reported cover data; is something misspelled?",
                    "x" = "{spp_cvr_ht[!ht_check]}"))
}


### now from the other worksheets  
######################## make sure to get rid of numbers for reps
##################################################################

## density
dens <- read_xlsx(fls2[i],
                  sheet = "Density",
                  guess_max = 5000)
col_chk <- id_cols %in% names(dens)
if(sum(!(col_chk)) > 0){
    cli::cli_warn(c("Identifying columns are missing from the Density sheet",
                    "x" = "Missing columns are: {id_cols[!col_chk]}"))
}
# species names
spp_dens <- dens %>%
    filter(row_number() == 1) %>% 
    select(-(1:Notes),
           -starts_with("F_")) %>% 
    names() %>% 
    str_remove("\\s\\d")

dens_covr <- spp_dens %in% names(spp_covr)
if(sum(!dens_covr) > 0){
    cli::cli_warn(c("Species with reported density measurements 
                    in the Density worksheet do not have
                    reported cover data; is something misspelled?",
                  "x" = "{spp_dens[!dens_covr]}"))
}
# dupes
dupes_dens <- janitor::get_dupes(dens,
                   Year, Month, Day, SiteID, TransectID, PlotID)
if(nrow(dupes_dens) > 0){
    cli::cli_warn("The Density sheet has duplicate rows:")
    print(dupes_dens)
}


## Heights
hts <- read_xlsx(fls2[i],
                  sheet = "Height",
                  guess_max = 5000)
col_chk <- id_cols %in% names(hts)
if(sum(!(col_chk)) > 0){
    cli::cli_warn(c("Identifying columns are missing from the Height sheet",
                    "x" = "Missing columns are: {id_cols[!col_chk]}"))
}
# species names
spp_hts <- hts %>%
    filter(row_number() == 1) %>% 
    select(-(1:Notes),
           -starts_with("F_")) %>% 
    names() %>% 
    str_remove("\\s\\d")
hts_covr <- spp_hts %in% names(spp_covr)
if(sum(!hts_covr) > 0){
    cli::cli_warn(c("Species with reported height measurements 
                    in the Height worksheet do not have
                    reported cover data; is something misspelled?",
                    "x" = "{spp_hts[!hts_covr]}"))
}
# dupes
dupes_hts <- janitor::get_dupes(hts,
                                 Year, Month, Day, SiteID, TransectID, PlotID)
if(nrow(dupes_hts) > 0){
    cli::cli_warn("The Height sheet has duplicate rows:")
    print(dupes_hts)
}
