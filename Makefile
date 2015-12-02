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
SMFILTER=/usr/local/bin/smfilter
SEAFILTERPBF=$(DATADIR)/japan.sea.filter.pbf


mkdir-work:
	mkdir -p $(WORK)
	mkdir -p $(DATADIR)

createdb:
	-sudo -u postgres createdb gis
	-sudo -u postgres psql -d gis -c "CREATE EXTENSION adminpack;"
	-sudo -u postgres psql -d gis -c "CREATE EXTENSION postgis;"
	-sudo -u postgres psql -d gis -c "CREATE EXTENSION postgis_topology;"
	-sudo -u postgres psql -d gis -c "CREATE EXTENSION hstore;"

dropdb:
	-sudo -u postgres dropdb gis

download-all-data: download-natural-earth download-pbf download-osm

download-natural-earth:
	wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries.zip  -O $(DATADIR)/ne_10m_admin_0_countries.zip
	cd $(DATADIR);unzip -o ne_10m_admin_0_countries.zip

	wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_bathymetry_all.zip -O $(DATADIR)/ne_10m_bathymetry_all.zip 
	cd $(DATADIR);unzip -o ne_10m_bathymetry_all.zip 


download-pbf:
	wget http://download.geofabrik.de/asia/japan-latest.osm.pbf -O $(RAWPBF)

download-osm:
	wget http://download.geofabrik.de/asia/japan-latest.osm.bz2 -O $(RAWBZ2)

coastline:
	osmcoastline --verbose --output-polygons=land -o $(DATADIR)/japancoast.db $(RAWPBF)

coastline-shp: 
	ogr2ogr -f "ESRI Shapefile" $(DATADIR)/land_polygons $(DATADIR)/japancoast.db land_polygons

filter-tokyo:
	osmosis --read-pbf $(RAWPBF) --write-xml file=- | osmosis --read-xml enableDateParsing=no file=-  --bounding-box top=35.5  left=139.5 bottom=35.0 right=134.2 --write-xml file=- | $(SMFILTER) -a 0.05 -d 20 -r 0.5  | osmosis --read-xml file=- --write-pbf file=$(SEAFILTERPBF)


filter-sea:
	osmosis --read-pbf $(RAWPBF) --write-xml file=- | $(SMFILTER) -a 0.05 -d 20 -r 0.5 -  | osmosis --read-xml file=- --write-pbf file=$(SEAFILTERPBF)




extract-sea:
	osmosis --read-pbf $(RAWPBF) \
		--tf accept-ways seamark:type=*	\
		--tf accept-node seamark:type=*	\
		--tf accept-relations seamark:type=* \
		--write-xml file=-  | 	\
		$(SMFILTER) -a 0.05 -d 20 -r 0.5 -  | \
		osmosis --read-xml file=- --write-pbf file=$(SEAFILTERPBF)
	osmosis --read-pbf $(SEAFILTERPBF) \
		--write-xml $(SEAOSM)


import-pbf:
	$(IMPOSM) import -connection postgis://mapbox:mapbox@localhost/gis \
    			-mapping mapping.json -read $(SEAFILTERPBF) -write -overwritecache 
	$(IMPOSM) import -connection postgis://mapbox:mapbox@localhost/gis \
   			 -mapping mapping.json -deployproduction


import-pbf-sea:
	$(IMPOSM) import -connection postgis://mapbox:mapbox@localhost/gis \
    			-mapping seamapping.json -read $(SEAFILTERPBF) -write -overwritecache 
	$(IMPOSM) import -connection postgis://mapbox:mapbox@localhost/gis \
   			 -mapping seamapping.json -deployproduction

#-----
install-seafilter:
	(cd /tmp; wget http://www.abenteuerland.at/download/smfilter/smfilter-r1233.tbz2; tar xvf smfilter-r1233.tbz2)


install-imposm:
	(cd /tmp; git clone https://github.com/omniscale/imposm; cd /tmp/imposm; python setup.py build; python setup.py install)


#----

fish-right-osm:
	python ../ksj2osm $(DATADIR)/KJS2/C21-59L-jgd.xml $(DATADIR)/fish.osm

import-pbf-imposm2:
	imposm -m imposm_sea.py --overwrite-cache --read  $(SEAFILTERPBF)
#	imposm --connection postgis://mapbox:mapbox@localhost/gis -d gis -m imposm_sea.py --read --write --optimize --overwrite-cache --deploy-production-tables $(SEAFILTERPBF)



#--------------

boot-docker:
	docker run  -p 3000:3000 -p 5432:5432 -v /Users/takeo/OSM:/WORK -t mapbox


