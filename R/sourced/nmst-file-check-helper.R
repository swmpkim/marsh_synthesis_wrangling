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
                   Year, Month, Day, SiteID, TransectID, PlotID)
