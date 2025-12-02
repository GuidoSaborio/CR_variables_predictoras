#https://stackoverflow.com/questions/69035297/calculating-road-density-raster-from-road-shapefile
library(terra)
library(sf)
rm(list=ls())
gc()

## Utilizar la variables Bio1 de WoldClim como referencia para la resolución
bio1 <- terra::rast("source/bio1_23.bil")
cr <- st_read("source/bordecr2008polycrtm05.shp", crs = 5367)
cr <- st_transform(cr, crs = 4326)
bio1 <- crop(bio1, cr)
bio1 <- mask(bio1, cr)


### DENSIDAD DE CAMINOS###

## Utilizar capa de caminos de Atlas2014
caminos <- st_read("source/redcaminos2014crtm05.shp", crs= 5367)
caminos <- st_transform(caminos, crs = 4326)



v <- vect(caminos)
roads <- as.lines(v)
rs <- rast(v, nrows=381, ncols=411, nlyrs=1, xmin=-84.68333, xmax=-82.70833, 
           ymin=8.041667, ymax=10.10833, crs= "+proj=longlat +datum=WGS84 +no_defs") 

values(rs) <- 1:ncell(rs)
names(rs) <- "rast"    
rsp <- as.polygons(rs)

rp <- intersect(roads, rsp)

rp$length <- perim(rp) / 1000 #km
x <- tapply(rp$length, rp$rast, sum)

Dencaminos <- rast(rs)
Dencaminos[as.integer(names(x))] <- as.vector(x)
Dencaminos[is.na(Dencaminos)]<- 0
plot(Dencaminos)

Dencaminos <- project(Dencaminos, bio1)
Dencaminos1 <- resample(Dencaminos, bio1)
Dencaminos2 <- crop(Dencaminos, bio1)
DencaminosF <- mask(Dencaminos2, bio1)

plot(DencaminosF)

writeRaster(DencaminosF, "results/DensidadCaminos_atlas.asc",overwrite=TRUE)
