## Código basado en:
## https://stackoverflow.com/questions/69035297/calculating-road-density-raster-from-road-shapefile

library(terra)
library(sf)

rm(list=ls())
gc()

### DENSIDAD DE RIOS###

## Utilizar la variables Bio1 de WoldClim como referencia para la resolución
bio1 <- terra::rast("source/bio1_23.bil")
cr <- st_read("source/bordecr2008polycrtm05.shp", crs = 5367)
cr <- st_transform(cr, crs = "WGS84")
bio1 <- crop(bio1, cr)
bio1 <- mask(bio1, cr)

## Utilizar capa de ríos de OSM
rios <- st_read("source/CR_RiosOSM.shp")

v <- vect(rios)
rios <- as.lines(v)
rs <- rast(v, nrows=381, ncols=411, nlyrs=1, xmin=-84.68333, xmax=-82.70833, 
           ymin=8.041667, ymax=10.10833, crs= "+proj=longlat +datum=WGS84 +no_defs") 

values(rs) <- 1:ncell(rs)
names(rs) <- "rast"    
rsp <- as.polygons(rs)

rp <- intersect(rios, rsp)

rp$length <- perim(rp) / 1000 #km
x <- tapply(rp$length, rp$rast, sum)

rios_r <- rast(rs)
rios_r[as.integer(names(x))] <- as.vector(x)
rios_r[is.na(rios_r)]<- 0
plot(rios_r)

#Denrios <- project(rios, bio1)
riosF <- resample(rios_r, bio1)
riosF <- crop(riosF, bio1)
riosF <- mask(riosF, bio1)

plot(riosF)
writeRaster(riosF, "results/CR_RiosDensity.asc",overwrite=TRUE)





