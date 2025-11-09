
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

### DENSIDAD DE RIOS###
rios <- st_read("source/CR_RiosOSM.shp")

v1 <- vect(rios)
rios1 <- as.lines(v1)
rs1 <- rast(v1) 

values(rs1) <- 1:ncell(rs1)
names(rs1) <- "rast"    
rsp1 <- as.polygons(rs1)

rp1 <- intersect(rios1, rsp1)

rp1$length <- perim(rp1) / 1000 #km
x1 <- tapply(rp1$length, rp1$rast, sum)

rios1 <- rast(rs1)
rios1[as.integer(names(x1))] <- as.vector(x1)


#Denrios <- project(rios, bio1)
riosF <- resample(rios1, bio1)
riosF <- crop(riosF, bio1)
riosF <- mask(riosF, bio1)
writeRaster(riosF, "results/CR_RiosDensity.asc",overwrite=TRUE)




