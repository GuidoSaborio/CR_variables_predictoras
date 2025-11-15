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






