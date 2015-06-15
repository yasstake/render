

WORK=../../WORK
DATADIR=$(WORK)/data
RAWPBF=$(DATADIR)/japan-latest.osm.pbf
RAWBZ2=$(DATADIR)/japan-latest.osm.bz2
IMPOSM=imposm

SEAOSM=$(DATADIR)/japan.sea.osm
SEAFILTEROSM=$(DATADIR)/japan.sea.filter.osm
SMFILTER=smfilter

mkdir-work:
	mkdir -p $(WORK)
	mkdir -p $(DATADIR)



download-natural-earth:
	wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries.zip -O $(DATADIR)/ne_10m_admin_0_countries.zip
	wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_bathymetry_K_200.zip -O $(DATADIR)/ne_10m_bathymetry_K_200.zip

download-pbf:
	wget http://download.geofabrik.de/asia/japan-latest.osm.pbf -O $(RAWPBF)

download-osm:
	wget http://download.geofabrik.de/asia/japan-latest.osm.bz2 -O $(RAWBZ2)

coastline:
	osmcoastline --verbose --output-polygons=land -o $(DATADIR)/japancoast.db $(RAWPBF)

coastline-shp: 
	ogr2ogr -f "ESRI Shapefile" $(DATADIR)/land_polygons $(DATADIR)/japancoast.db land_polygons


extract-sea:
	osmosis --read-pbf $(RAWPBF) \
		--tf accept-ways seamark:type=*	\
		--tf accept-node seamark:type=*	\
		--tf accept-relations seamark:type=* \
		--write-xml $(SEAOSM)

extract-pbf:
	osmosis --read-pbf $(RAWPBF) \
		--write-xml $(SEAOSM)


filter-sea:
	 $(SMFILTER) -a 0.05 -d 20 -r 0.5 < $(SEAOSM) > $(SEAFILTEROSM)

import-sea:
	$(IMPOSM) --connection postgis://yass:yass@localhost/gis -d gis -m imposm_sea.py --read --write --optimize --overwrite-cache --deploy-production-tables $(SEAFILTEROSM)

