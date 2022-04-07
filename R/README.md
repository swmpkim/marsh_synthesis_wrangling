# Thoughts on working with template data  
### originated 2022-02-15  
### latest update 2022-04-07  

Have made changes to the template to make names more consistent with CDMO-format naming.  


I'm starting to dig into the `assertive` and `testthat` packages for some of these checks.  


Might be a good idea to have a separate script and/or shiny app just for data checks: make sure data will be able to be all combined; and tell people what (and where) the problem is so they can go back and fix it in the original spreadsheet. Then resume the rest of the process.  


Also see `assertr` - this allows for chained verifications etc. https://cran.r-project.org/web/packages/assertr/vignettes/assertr.html  


**CAREFUL about empty cells when pivoting longer - deal with 0s vs. NAs issue**  - may be possible to get general list of species definitely counted/assessed for each plot, and remove species that are not? (because columns contain species across all plots)  




## Sheets  

+  We are transferring the heights and densities into the 'cover' sheet in the Excel sheet itself?   
    +  YES - 'height' and 'density' sheets are only for replicates
    +  To check: verify the numbers match what they should and alert the user if something is "off". 
  



## Data formats/column issues  

+  Only one QAQC column in CDMO template (not one for each of cover, density, height)  
+  Height columns in CDMO template: max canopy ht; average canopy ht; "height". Figure out from each reserve which their numbers are. This may need to be something we build into the template, somehow.  
+  Will transect number *always* be a number? Or should I format this as text? I'd bet somebody uses A, B, C rather than 1, 2, 3. (am proceeding with this as text)  
    +  per convo with CP, yes, treat as text  
+  Plot number is 1, 2, 3 in the 'Cover' sheet, but BC1-1, BC1-2, BC1-3 in the density and height sheets. Need to be consistent. My guess is that we meant this to be 1, 2, 3, and then pasted together with the rest of the ID fields (and am proceeding under this assumption).  
    +  CP will fix in example spreadsheet; KC will **build in checks for matching and treat this column as text**  
+  Does the CDMO template specify what 'density' units are? I think at GND the numbers in the spreadsheet represent the counts in the plot (which is 0.25m x 0.25m = 0.0625m^2); not stems/m^2. Need to make sure this is consistent or at least known across sites, so everything can get converted to stems/m^2.  
    +  **"per m2, whole number; 0 if 0% cover, NA if not assessed"**  
+  Need to figure out how to check each column to make sure it's coercible to the correct class. At some point, a letter will be entered into a column that's supposed to be a number, and I need to figure out how to alert the user rather than everything just stopping with an uninterpretable error.  
+  Also need to figure out how to "proofread" what's in the columns (e.g. in Plot_Number, it should just be 1, 2, 3 or A, B, C; not the pasted site-transect-plot - so it can all get glued together to be the unique ID later)  


