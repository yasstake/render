WORK=/WORK
DATADIR=$(WORK)/data
RAWPBF=$(DATADIR)/japan-latest.osm.pbf
RAWBZ2=$(DATADIR)/japan-latest.osm.bz2
INTER_PBF=$(DATADIR)/tokyo.pbf
INTER_OSM=$(DATADIR)/tokyo.osm
IMPORTFILE=$(INTER_PBF)
IMPOSM=/usr/local/imposm3

SEAOSM=$(DATADIR)/japan.sea.osm
SEAFILTEROSM=$(DATADIR)/japan.sea.filter.osm
SMFILTER=smrender

mkdir-work:
	mkdir -p $(WORK)
	mkdir -p $(DATADIR)

createdb:
	sudo -u postgres createdb gis
	sudo -u postgres psql -d gis -c "CREATE EXTENSION adminpack;"
	sudo -u postgres psql -d gis -c "CREATE EXTENSION postgis;"
	sudo -u postgres psql -d gis -c "CREATE EXTENSION postgis_topology;"
	sudo -u postgres psql -d gis -c "CREATE EXTENSION hstore;"

download-natural-earth:
	wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries.zip  -O $(DATADIR)/ne_10m_admin_0_countries.zip
	wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_bathymetry_all.zip -O $(DATADIR)/ne_10m_bathymetry_all.zip 
	cd $(DATADIR)
	unzip ne_10m_admin_0_countries.zip
	unzip ne_10m_bathymetry_all.zip 


download-pbf:
	wget http://download.geofabrik.de/asia/japan-latest.osm.pbf -O $(RAWPBF)

download-osm:
	wget http://download.geofabrik.de/asia/japan-latest.osm.bz2 -O $(RAWBZ2)

coastline:
	osmcoastline --verbose --output-polygons=land -o $(DATADIR)/japancoast.db $(RAWPBF)

coastline-shp: 
	ogr2ogr -f "ESRI Shapefile" $(DATADIR)/land_polygons $(DATADIR)/japancoast.db land_polygons


extract-tokyo:
	osmosis --read-pbf $(RAWPBF) --write-xml file=- | osmosis --read-xml enableDateParsing=no file=-  --bounding-box top=35.4 left=139.3 bottom=35.0 right=140.0 --write-pbf file=$(INTER_PBF)

extract-inter-osm:
	osmosis --read-pbf $(INTER_PBF) --write-xml file=$(INTER_OSM)

import-pbf:
	$(IMPOSM) import -connection postgis://mapbox:mapbox@localhost/gis \
    			-mapping mapping.json -read $(IMPORTFILE) -write -overwritecache
	$(IMPOSM) import -connection postgis://mapbox:mapbox@localhost/gis \
   			 -mapping mapping.json -deployproduction


import-coastline:
	ogr2ogr 

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
	(export LD_LIBRARY_PATH=/usr/local/lib/ && $(SMFILTER) -i $(INTER_OSM) -M -G -w $(SEAFILTEROSM))

import-sea:
	$(IMPOSM) --connection postgis://mapbox:mapbox@localhost/gis -d gis -m imposm_sea.py --read --write --optimize --overwrite-cache --deploy-production-tables $(SEAFILTEROSM)

boot-docker:
	docker run  -p 3000:3000 -p 5432:5432 -v /Users/takeo/OSM:/WORK -t mapbox
