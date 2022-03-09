# qc codes won't always be "ok" but they'll always be characters
# numbers are entirely made up

qcs <- c("ok", "ok", "ok")

# what I have
helpme <- tibble(
    "id" = c("sample 1", "sample 2", "sample 3"),
    "Spartina alterniflora" = c(55, 57, 52),
    "Spartina patens" = c(5, 4, 6),
    "Density_Spartina alterniflora" = c(80, 85, 78),
    "Density_Spartina patens" = c(8, 9, 8),
    "Height_Spartina alterniflora" = c(0.9, 1, 1.1),
    "Height_Spartina patens" = c(0.3, 0.35, 0.32),
    "F_Spartina alterniflora" = qcs,
    "F_Spartina patens" = qcs,
    "F_Density_Spartina alterniflora" = qcs,
    "F_Density_Spartina patens" = qcs,
    "F_Height_Spartina alterniflora" = qcs,
    "F_Height_Spartina patens" = qcs
)


# what i want
please <- tibble(
    "id" = c(rep("sample 1", 2), rep("sample 2", 2), rep("sample 3", 2)),
    "Species" = rep(c("Spartina alterniflora", "Spartina patens"), 3),
    "Cover" = c(55, 5, 57, 4, 52, 6),
    "F_Cover" = rep("ok", 6),
    "Density" = c(80, 8, 85, 9, 78, 8),
    "F_Density" = rep("ok", 6),
    "Height" = c(0.9, 0.3, 1, 0.35, 1.1, 0.32),
    "F_Height" = rep("ok", 6)
)






# think i can make it work with some modifications
testwide <- tibble(
    "id" = c("sample 1", "sample 2", "sample 3"),
    "Cover_Spartina alterniflora" = c(55, 57, 52),
    "Cover_Spartina patens" = c(5, 4, 6),
    "Density_Spartina alterniflora" = c(80, 85, 78),
    "Density_Spartina patens" = c(8, 9, 8),
    "Height_Spartina alterniflora" = c(0.9, 1, 1.1),
    "Height_Spartina patens" = c(0.3, 0.35, 0.32),
    "F-Cover_Spartina alterniflora" = qcs,
    "F-Cover_Spartina patens" = qcs,
    "F-Density_Spartina alterniflora" = qcs,
    "F-Density_Spartina patens" = qcs,
    "F-Height_Spartina alterniflora" = qcs,
    "F-Height_Spartina patens" = qcs
)

# this is like the 'family' example in the pivoting article
# but 'species' is my equivalent of 'child'
# https://tidyr.tidyverse.org/articles/pivot.html#many-variables-in-column-names

testlong <- pivot_longer(testwide,
                         -id,
                         names_to = c(".value", "species"),
                         names_sep = "_")

# find the names that aren't ID columns, and don't start with F_,
# and add "Cover_" as a prefix
# also find F_species (e.g. NOT F_Density or F_Height) and 
# make that "F-Cover_species"