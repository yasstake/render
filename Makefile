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

download-all-data: download-natural-earth download-pbf

download-natural-earth:
	wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries.zip  -O $(DATADIR)/ne_10m_admin_0_countries.zip
	cd $(DATADIR);unzip -o ne_10m_admin_0_countries.zip

	wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/physical/ne_10m_bathymetry_all.zip -O $(DATADIR)/ne_10m_bathymetry_all.zip 
	cd $(DATADIR);unzip -o ne_10m_bathymetry_all.zip 


download-pbf:
	wget http://download.geofabrik.de/asia/japan-latest.osm.pbf -O $(RAWPBF)


coastline:
	osmcoastline --verbose --output-polygons=land -o $(DATADIR)/japancoast.db $(RAWPBF)

coastline-shp: 
	ogr2ogr -f "ESRI Shapefile" $(DATADIR)/land_polygons $(DATADIR)/japancoast.db land_polygons





#-----
install-seafilter:
	(cd /tmp; wget http://www.abenteuerland.at/download/smfilter/smfilter-r1233.tbz2; tar xvf smfilter-r1233.tbz2)



#----



#
#	japan.latest.pbf
#		-> japan.land.pbf
#		-> japan.sea.osm
#
#	japan.sea.osm + /ORG/japan.sea.osm -> sea.osm -> smfilter -> sea.pbf
#	
#	imposm land.pbf
#	imposm sea.pbf
#
#

WORKDIR = $(DATADIR)/WORK

JAPAN_LAND_PBF=$(WORKDIR)/japan.land.pbf
JAPAN_SEA_PBF=$(WORKDIR)/japan.sea.pbf
ORG_SEA_PBF=$(DATADIR)/seafilter.pbf
MERGE_SEA_OSM=$(WORKDIR)/japan.mergesea.osm
JAPAN_FILTER_PBF=$(WORKDIR)/japan.mergefilter.pbf
JAPAN_FILTER_OSM=$(WORKDIR)/japan.mergefilter.osm
FISH_RIGHT_OSM=$(WORKDIR)/fish.osm
FISH_RIGHT_PBF=$(WORKDIR)/fish.osm
FISH_RIGHT_KJS2=$(DATADIR)/KJS2/C21-59L-jgd.xml

$(JAPAN_SEA_PBF):	$(RAWPBF)
	osmosis --read-pbf $(RAWPBF) \
		--tf accept-ways seamark:type=*	\
		--tf accept-node seamark:type=*	\
		--tf accept-relations seamark:type=* \
		--write-pbf file=$(JAPAN_SEA_PBF)

$(JAPAN_LAND_PBF):	$(RAWPBF)
	osmosis --read-pbf $(RAWPBF) \
		--tf reject-ways seamark:type=*	\
		--tf reject-node seamark:type=*	\
		--tf reject-relations seamark:type=* \
		--write-pbf file=$(JAPAN_LAND_PBF)

$(MERGE_SEA_OSM): $(ORG_SEA_PBF) $(JAPAN_SEA_PBF)
	osmosis --read-pbf $(ORG_SEA_PBF) \
		--read-pbf $(JAPAN_SEA_PBF)\
		--merge \
		--write-xml file=$(MERGE_SEA_OSM)

$(JAPAN_FILTER_PBF): $(MERGE_SEA_OSM)
	cat $(MERGE_SEA_OSM) | $(SMFILTER) -a 0.05 -d 20 -r 0.5  | osmosis --read-xml file=- --write-pbf file=$(JAPAN_FILTER_PBF)
	osmosis --read-pbf file=$(JAPAN_FILTER_PBF) --write-xml file=$(JAPAN_FILTER_OSM)

$(FISH_RIGHT_PBF):
	python ../ksj2osm/fish.py $(FISH_RIGHT_KJS2) $(FISH_RIGHT_OSM)
	osmosis --read-xml file=$(FISH_RIGHT_OSM) --write-pbf $(FISH_RIGHT_PBF)

import-pbf-imposm: $(JAPAN_LAND_PBF) $(JAPAN_SEA_PBF) $(JAPAN_FILTER_PBF)
	imposm -m imposm_sea.py --overwrite-cache --read  $(JAPAN_LAND_PBF)
	imposm -m imposm_sea.py --merge-cache --read $(JAPAN_SEA_PBF)
	imposm -m imposm_sea.py --merge-cache --read $(JAPAN_FILTER_PBF)
	imposm --connection postgis://mapbox:mapbox@localhost/gis -d gis -m imposm_sea.py \
		--write --optimize --overwrite-cache --deploy-production-tables


#--------------

boot-docker:
	docker run  -p 3000:3000 -p 5432:5432 -v /Users/takeo/OSM:/WORK -t mapbox


