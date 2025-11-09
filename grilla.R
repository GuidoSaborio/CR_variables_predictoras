library(terra)
library(sf)

pn <- st_read("source/pn_range_WGS84.shp")
grilla <- st_read("source/Grilla_1x1.shp")
grilla <- st_transform(grilla, crs = "WGS84")
grillapn <- st_crop(grilla, pn)

grilla_r <- raster(grillapn, )
grillapn <-st_mask(grilla, pn)  
  
  