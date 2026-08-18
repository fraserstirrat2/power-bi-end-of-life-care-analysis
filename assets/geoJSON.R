

install.packages('sf')


library(sf)
library(dplyr)

if (sessionInfo()$platform %in% c("x86_64-redhat-linux-gnu (64-bit)",
                                  "x86_64-pc-linux-gnu (64-bit)")) {
  platform <- "server"
} else {
  platform <- "locally"
}


hb <- st_read(
  "/conf/linkage/output/lookups/Unicode/Geography/Shapefiles/Health Board 2019/SG_NHS_HealthBoards_2019.shp"
)


hb_geojson <- hb |>
  st_transform(4326) |>
  mutate(
    HBR = HBCode,
    NHS_Health_Board = HBName,
    Board_Label = case_when(
      HBName == "Ayrshire and Arran" ~ "A",
      HBName == "Borders" ~ "B",
      HBName == "Dumfries and Galloway" ~ "Y",
      HBName == "Fife" ~ "F",
      HBName == "Forth Valley" ~ "V",
      HBName == "Grampian" ~ "N",
      HBName == "Greater Glasgow and Clyde" ~ "G",
      HBName == "Highland" ~ "H",
      HBName == "Lanarkshire" ~ "L",
      HBName == "Lothian" ~ "S",
      HBName == "Orkney" ~ "R",
      HBName == "Shetland" ~ "Z",
      HBName == "Tayside" ~ "T",
      HBName == "Western Isles" ~ "W",
      TRUE ~ NA_character_
    )
  ) |>
  select(HBR, NHS_Health_Board, Board_Label, geometry)

st_write(
  hb_geojson,
  "NHS_HealthBoards_2019.geojson",
  delete_dsn = TRUE
)

getwd()

list.files(pattern = "NHS_HealthBoards_2019.geojson")
