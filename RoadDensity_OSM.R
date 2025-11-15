## https://stackoverflow.com/questions/69035297/calculating-road-density-raster-from-road-shapefile

library(terra)


v <- vect("source/CaminosCR_OSM2.shp")

crs(v, warn=FALSE)<-"EPSG:5367"

roads <- as.lines(v)
rs <- rast(v, resolution= 10000)

values(rs) <- 1:ncell(rs)
names(rs) <- "rast"    
rsp <- as.polygons(rs)

rp <- intersect(roads, rsp)

rp$length <- perim(rp)/1000 #km
x <- tapply(rp$length, rp$rast, sum)

r <- rast(rs)
r[as.integer(names(x))] <- as.vector(x)


plot(r)
lines(roads)

t <- rast("source/TiposBosqueCR2021.tif")
r2 <- resample(r, t)

plot(r2)
lines(roads)
writeRaster(r, "results/RoadDensity4.tif")
writeRaster(r2, "results/RoadDensity2.tif", overwrite=TRUE)

