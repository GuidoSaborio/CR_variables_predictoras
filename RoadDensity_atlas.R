
#https://stackoverflow.com/questions/69035297/calculating-road-density-raster-from-road-shapefile
library(terra)
library(sf)


## Utilizar la variables Bio1 de WoldClim como referencia para la resolución
bio1 <- terra::rast("source/bio1_23.bil")
cr <- st_read("source/bordecr2008polycrtm05.shp")
cr <- st_transform(cr, crs = "WGS84")
bio1 <- crop(bio1, cr)


### DENSIDAD DE CAMINOS###

## Utilizar capa de caminos de Atlas2014
caminos <- st_read("source/redcaminos2014crtm05.shp", crs= 5367)

v <- vect(caminos)
roads <- as.lines(v)
rs <- rast(v) 

values(rs) <- 1:ncell(rs)
names(rs) <- "rast"    
rsp <- as.polygons(rs)

rp <- intersect(roads, rsp)

rp$length <- perim(rp) / 1000 #km
x <- tapply(rp$length, rp$rast, sum)

Dencaminos <- rast(rs)
Dencaminos[as.integer(names(x))] <- as.vector(x)


Dencaminos <- project(Dencaminos, bio1)
DencaminosF <- resample(Dencaminos, bio1)

writeRaster(DencaminosF, "results/CR_RoadDensity.asc")

