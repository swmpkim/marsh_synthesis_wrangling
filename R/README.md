# THOUGHTS on working with template data  
### originated 2022-02-15  
### latest update 2022-02-15  

## Sheets  

+  Need to remove 'Example' or 'TEMPLATE' from the worksheet names in final version - otherwise the code won't work the same for every reserve's file.  
+  We are transferring the heights and densities into the 'cover' sheet in the Excel sheet itself? If so, one of my checks will be to verify the numbers match what they should and alert the user if something is "off". (other situation would be "I'll set the code up to calculate these and combine with cover" - but it looks like they're already separate columns in the cover sheet)    



## Data formats/column issues  

+  need to ensure the fields all paste together properly into the unique ID. In the 'Example' sheet, the date was October 8, 2010 and although the 8 was displaying as "08" in the month field, it pasted into the ID field as only "8" - so the ID included "2010108" rather than "20101008".  
+  Will transect number *always* be a number? Or should I format this as text? I'd bet somebody uses A, B, C rather than 1, 2, 3. (am proceeding with this as text)    
+  Plot number is 1, 2, 3 in the 'Cover' sheet, but BC1-1, BC1-2, BC1-3 in the density and height sheets. Need to be consistent. My guess is that we meant this to be 1, 2, 3, and then pasted together with the rest of the ID fields (and am proceeding under this assumption).  
+  Does the CDMO template specify what 'density' units are? I think at GND the numbers in the spreadsheet represent the counts in the plot (which is 0.25m x 0.25m = 0.0625m^2); not stems/m^2. Need to make sure this is consistent or at least known across sites, so everything can get converted to stems/m^2.  
+  Need to figure out how to check each column to make sure it's coercible to the correct class. At some point, a letter will be entered into a column that's supposed to be a number, and I need to figure out how to alert the user rather than everything just stopping with an uninterpretable error.  
+  Also need to figure out how to "proofread" what's in the columns (e.g. in Plot_Number, it should just be 1, 2, 3 or A, B, C; not the pasted site-transect-plot - so it can all get glued together to be the unique ID later)  


