# figure out how many rows of headers there are
### function is modified from `check_num2` at https://stackoverflow.com/a/67532389
### to figure out which rows can't be converted to numeric
skip_fun <- function(x){
    y <- suppressWarnings(as.numeric(x))
    if(is.numeric(x)){  # if it's already a number, there was only one row of headers so that's all we need to skip (adding headers back in later)
        return(1)
    }
    max(which(is.na(y))) + 1
}

check_num2 <- function(x){
    y <- suppressWarnings(as.numeric(x))
    which(is.na(y))
}

# read in the file, figure out how much to skip, read it in again, and rename the columns from the first test file
read_cdmo_keepNAs <- function(file,
                      worksheet = NULL,
                      skip = NULL){
    # worksheet option if different worksheets of interest are in the file
    # skip option for reserves where the number to skip is known and the way to automate a guess *isn't* known  
    to_mod <- read_xlsx(file,
                        n_max = 10,
                        na = c("", "NA"),
                        sheet = worksheet)
    
    # which column has "Lat" in it? This should be numeric.
    lat <- str_which(names(to_mod), "Lat")
    lat_vec <- to_mod[[lat]]
    
    if(is.null(skip)){
        skip <- skip_fun(lat_vec)  
    }
    
    dat <- read_xlsx(file,
                     sheet = worksheet,
                     skip = skip,
                     col_names = FALSE) 
    names(dat) <- names(to_mod)
    dat <- dat %>% 
        mutate(SiteID = as.character(SiteID))
    return(dat)
}

# same as above but turning all typed NAs into blank cells 
read_cdmo <- function(file,
                      worksheet = NULL,
                      skip = NULL){
    # worksheet option if different worksheets of interest are in the file
    # skip option for reserves where the number to skip is known and the way to automate a guess *isn't* known  
    
    # headers are always top row; unknown number of explanatory rows below that
    
    to_mod <- read_xlsx(file,
                        n_max = 10,
                        na = c("", "NA", "N/A"),
                        sheet = worksheet)
    
    # which column has "Lat" in it? This should be numeric.
    lat <- str_which(names(to_mod), "Lat")
    lat_vec <- to_mod[[lat]]
    
    if(is.null(skip)){
        skip <- skip_fun(lat_vec)  
    }
    
    # read in sheet, skipping header and explanatory rows
    # this strips the column names
    dat <- read_xlsx(file,
                     sheet = worksheet,
                     skip = skip,
                     na = c("", "NA", "N/A"),
                     col_names = FALSE)
    
    # reassign names, from original sheet
    if(ncol(dat) == ncol(to_mod)){
        names(dat) <- names(to_mod)
    }
    
    
    # sometimes people have comments in additional columns
    if(ncol(dat) > ncol(to_mod)){
        # how many extra columns are there?
        extra_cols <- ncol(dat) - ncol(to_mod)
        
        # create extra names
        extra_names <- paste("Extra", seq(1:extra_cols), sep = "_")
        
        # use all the names
        names(dat) <- c(names(to_mod), extra_names)
    }
    
    
    # other times the last column or few columns are empty so don't get read in when headers are skipped
    if(ncol(dat) < ncol(to_mod)){
        # how many empty columns do we need?
        new_cols <- ncol(to_mod) - ncol(dat)
        
        # make dummy names
        new_names <- paste("Empty", seq(1:new_cols), sep = "_")
        
        # create them in 'dat'
        for(j in seq_along(new_names)){
            dat[[new_names[j]]] <- NA
        }
        
        # now combine names
        names(dat) <- names(to_mod)
    }
    
    
    dat <- dat %>% 
        mutate(SiteID = as.character(SiteID))
    return(dat)
}

# bind to `all_coords`
## don't do this twice; it doesn't check to see if these coordinates are already there
bind_coords <- function(df){
    to_bind <- df %>% 
        select(Reserve, SiteID, TransectID, PlotID, Lat, Long) %>%
        mutate_all(as.character) %>% 
        filter(Lat != "NA") %>% 
        mutate(Lat = str_trim(Lat),
               Long = str_trim(Long),
               Lat = as.numeric(Lat),
               Long = as.numeric(Long)) %>% 
        group_by(Reserve, SiteID, TransectID, PlotID) %>% 
        summarize(Lat = round(mean(Lat, na.rm = TRUE), 5),
                  Long = round(mean(Long, na.rm = TRUE), 5)) %>% 
        ungroup() %>% 
        select(Reserve, SiteID, TransectID, PlotID, Lat, Long)
    all_coords <<- bind_rows(all_coords, to_bind)  
    cat(paste(nrow(to_bind), "rows have been added to `all_coords`"))
}