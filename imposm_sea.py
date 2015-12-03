# Copyright 2011 Omniscale (http://omniscale.com)
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from imposm.mapping import (
    Options,
    Points, LineStrings, Polygons,
    String, Bool, Integer, OneOfInt,
    set_default_name_type, LocalizedName,
    WayZOrder, ZOrder, Direction,
    GeneralizedTable, UnionView,
    PseudoArea, meter_to_mapunit, sqr_meter_to_mapunit,
)

# # internal configuration options
# # uncomment to make changes to the default values
import imposm.config
# 
# # import relations with missing rings
imposm.config.import_partial_relations = False
# 
# # select relation builder: union or contains
imposm.config.relation_builder = 'contains'
# 
# # log relation that take longer than x seconds
# imposm.config.imposm_multipolygon_report = 60
# 
# # skip relations with more rings (0 skip nothing)
# imposm.config.imposm_multipolygon_max_ring = 0


# # You can prefer a language other than the data's local language
# set_default_name_type(LocalizedName(['name:en', 'int_name', 'name']))

db_conf = Options(
    # db='osm',
    host='localhost',
    port=5432,
    user='osm',
    password='osm',
    sslmode='allow',
    prefix='osm_new_',
    proj='epsg:900913',
)

class Highway(LineStrings):
    fields = (
        ('tunnel', Bool()),
        ('bridge', Bool()),
        ('oneway', Direction()),
        ('ref', String()),
        ('layer', Integer()),
        ('z_order', WayZOrder()),
        ('access', String()),
    )
    field_filter = (
        ('area', Bool()),
    )

places = Points(
    name = 'places',
    mapping = {
        'place': (
            'country',
            'state',
            'region',
            'county',
            'city',
            'town',
            'village',
            'hamlet',
            'suburb',
            'neighbourhood',
            'locality',
        ),
    },
    fields = (
        ('z_order', ZOrder([
            'country',
            'state',
            'region',
            'county',
            'city',
            'town',
            'village',
            'hamlet',
            'suburb',
            'neighbourhood',
            'locality',
        ])),
        ('population', Integer()),
    ),
)

admin = Polygons(
    name = 'admin',
    mapping = {
        'boundary': (
            'administrative',
        ),
    },
    fields = (
        ('admin_level', OneOfInt('1 2 3 4 5 6'.split())),
    ),
)

motorways = Highway(
    name = 'motorways',
    mapping = {
        'highway': (
            'motorway',
            'motorway_link',
            'trunk',
            'trunk_link',
        ),
    }
)

mainroads = Highway(
    name = 'mainroads',
    mapping = {
        'highway': (
            'primary',
            'primary_link',
            'secondary',
            'secondary_link',
            'tertiary',
            'tertiary_link',
    )}
)

buildings = Polygons(
    name = 'buildings',
    fields = (
        ('area', PseudoArea()),
    ),
    mapping = {
        'building': (
            '__any__',
        ),
        'railway': (
            'station',
        ),
        'aeroway': (
            'terminal',
        ),
    }
)

minorroads = Highway(
    name = 'minorroads',
    mapping = {
        'highway': (
            'road',
            'path',
            'track',
            'service',
            'footway',
            'bridleway',
            'cycleway',
            'steps',
            'pedestrian',
            'living_street',
            'unclassified',
            'residential',
    )}
)

transport_points = Points(
    name = 'transport_points',
    fields = (
        ('ref', String()),
    ),
    mapping = {
        'highway': (
            'motorway_junction',
            'turning_circle',
            'bus_stop',
        ),
        'railway': (
            'station',
            'halt',
            'tram_stop',
            'crossing',
            'level_crossing',
            'subway_entrance',
        ),
        'aeroway': (
            'aerodrome',
            'terminal',
            'helipad',
            'gate',
    )}
)

railways = LineStrings (
    name = 'railways',
    fields = (
        ('tunnel', Bool()),
        ('bridge', Bool()),
        # ('ref', String()),
        ('layer', Integer()),
        ('z_order', WayZOrder()),
        ('access', String()),
    ),
    mapping = {
        'railway': (
            'rail',
            'tram',
            'light_rail',
            'subway',
            'narrow_gauge',
            'preserved',
            'funicular',
            'monorail',
    )}
)

waterways = LineStrings(
    name = 'waterways',
    mapping = {  
        'barrier': (
            'ditch',
        ),
        'waterway': (
            'stream',
            'river',
            'canal',
            'drain',
            'ditch',
        ),
    },
    field_filter = (
        ('tunnel', Bool()),
    ),
)

waterareas = Polygons(
    name = 'waterareas',
    fields = (
        ('area', PseudoArea()),
    ),
    mapping = {
        'waterway': ('riverbank',),
        'natural': ('water',),
        'landuse': ('basin', 'reservoir'), 
    },
)

barrierpoints = Points(
    name = 'barrierpoints',
    mapping = {
        'barrier': (
            'block',
            'bollard',
            'cattle_grid',
            'chain',
            'cycle_barrier',
            'entrance',
            'horse_stile',
            'gate',
            'spikes',
            'lift_gate',
            'kissing_gate',
            'fence',
            'yes',
            'wire_fence',
            'toll_booth',
            'stile',
    )}
)
barrierways = LineStrings(
    name = 'barrierways',
    mapping = {
        'barrier': (
            'city_wall',
            'fence',
            'hedge',
            'retaining_wall',
            'wall',
            'bollard',
            'gate',
            'spikes',
            'lift_gate',
            'kissing_gate',
            'embankment',
            'yes',
            'wire_fence',
    )}
)

aeroways = LineStrings(
    name = 'aeroways',
    mapping = {
        'aeroway': (
            'runway',
            'taxiway',
    )}
)

landusages = Polygons(
    name = 'landusages',
    fields = (
        ('area', PseudoArea()),
        ('z_order', ZOrder([
            'pedestrian',
            'footway',
            'aerodrome',
            'helipad',
            'apron',
            'playground',
            'park',
            'forest',
            'cemetery',
            'farmyard',
            'farm',
            'farmland',
            'wood',
            'meadow',
            'grass',
            'wetland',
            'village_green',
            'recreation_ground',
            'garden',
            'sports_centre',
            'pitch',
            'common',
            'allotments',
            'golf_course',
            'university',
            'school',
            'college',
            'library',
            'fuel',
            'parking',
            'nature_reserve',
            'cinema',
            'theatre',
            'place_of_worship',
            'hospital',
            'scrub',
            'zoo',
            'quarry',
            'residential',
            'retail',
            'commercial',
            'industrial',
            'railway',
            'island',
            'land',
        ])),
    ),
    mapping = {
        'landuse': (
            'park',
            'forest',
            'residential',
            'retail',
            'commercial',
            'industrial',
            'railway',
            'cemetery',
            'grass',
            'farmyard',
            'farm',
            'farmland',
            'wood',
            'meadow',
            'village_green',
            'recreation_ground',
            'allotments',
            'quarry',
        ),
        'leisure': (
            'park',
            'garden',
            'playground',
            'golf_course',
            'sports_centre',
            'pitch',
            'stadium',
            'common',
            'nature_reserve',
        ),
        'natural': (
            'wood',
            'land',
            'scrub',
            'wetland',
        ),
        'highway': (
            'pedestrian',
            'footway',
        ),
        'amenity': (
            'university',
            'school',
            'college',
            'library',
            'fuel',
            'parking',
            'cinema',
            'theatre',
            'place_of_worship',
            'hospital',
        ),
        'place': (
            'island',
        ),
        'tourism': (
            'zoo',
        ),
        'aeroway': (
            'aerodrome',
            'helipad',
            'apron',
        ),
})

amenities = Points(
    name='amenities',
    mapping = {
        'amenity': (
            'university',
            'school',
            'library',
            'fuel',
            'hospital',
            'fire_station',
            'police',
            'townhall',
        ),
})





# Custom tables for OpenSeaMap features

manmade = Points(
  name = 'manmade',
  mapping = {
    'man_made': (
      'beacon',
      'chimney',
      'crane',
      'lighthouse',
      'monitoring_station',
      'storage_tank'
      'tower',
      'wastewater_plant',
      'water_tower',
      'water_works',
    ),
})

manmade_ways = LineStrings(
  name = 'manmade_ways',
  mapping = {
    'man_made': (
      'breakwater',
      'groyne',
      'pier',
      'pipeline',
    )
  }
)

beacons = Points(
  name = 'beacons',
  mapping = {
    'seamark:type': (
      'beacon_cardinal',
      'beacon_isolated_danger',
      'beacon_lateral',
      'beacon_safe_water',
      'beacon_special_purpose',
    )
  },
  fields = (
    ('seamark:name', String()),
    ('seamark:beacon_lateral:shape', String()),
    ('seamark:beacon_lateral:category', String()),
    ('seamark:beacon_lateral:colour', String()),
    ('seamark:beacon_lateral:colour:pattern', String()),
    ('seamark:beacon_safe_water:shape', String()),
    ('seamark:beacon_safe_water:category', String()),
    ('seamark:beacon_safe_water:colour', String()),
    ('seamark:beacon_safe_water:colour:pattern', String()),
    ('seamark:beacon_cardinal:shape', String()),
    ('seamark:beacon_cardinal:category', String()),
    ('seamark:beacon_cardinal:colour', String()),
    ('seamark:beacon_cardinal:colour:pattern', String()),
    ('seamark:isolated_danger:shape', String()),
    ('seamark:isolated_danger:colour', String()),
    ('seamark:isolated_danger:colour:pattern', String()),
    ('seamark:beacon_special_purpose:shape', String()),
    ('seamark:beacon_special_purpose:colour', String()),
    ('seamark:radar_reflector', String()),
    ('seamark:light:colour', String()),
    ('seamark:topmark:shape', String()),
    ('seamark:topmark:colour', String()),
    ('seamark:fixme', String()),
  )
)

buoys = Points(
  name = 'buoys',
  mapping = {
    'seamark:type': (
      'buoy_cardinal',
      'buoy_installation',
      'buoy_isolated_danger',
      'buoy_lateral',
      'mooring',
      'buoy_safe_water',
      'buoy_special_purpose',
    )
  },
  fields = (
    ('seamark:name', String()),
    ('seamark:buoy_cardinal:shape', String()),
    ('seamark:buoy_cardinal:category', String()),
    ('seamark:buoy_cardinal:colour', String()),
    ('seamark:buoy_cardinal:colour_pattern', String()),

    ('seamark:buoy_installation:shape', String()),
    ('seamark:buoy_installation:category', String()),
    ('seamark:buoy_installation:colour', String()),
    ('seamark:buoy_installation:colour_pattern', String()),

    ('seamark:buoy_isolated_danger:shape', String()),
    ('seamark:buoy_isolated_danger:category', String()),
    ('seamark:buoy_isolated_danger:colour', String()),
    ('seamark:buoy_isolated_danger:colour_pattern', String()),

    ('seamark:buoy_lateral:shape', String()),
    ('seamark:buoy_lateral:category', String()),
    ('seamark:buoy_lateral:colour', String()),
    ('seamark:buoy_lateral:colour_pattern', String()),

    ('seamark:buoy_safe_water:shape', String()),
    ('seamark:buoy_safe_water:colour', String()),
    ('seamark:buoy_safe_water:colour_pattern', String()),

    ('seamark:buoy_special_purpose:shape', String()),
    ('seamark:buoy_special_purpose:colour', String()),

    ('seamark:seamark:buoy_installation:category', String()),
    
    ('seamark:radar_reflector', String()),
    ('seamark:topmark:shape', String()),
    ('seamark:topmark:colour', String()),
    ('seamark:light:colour', String()),
    ('seamark:fixme', String()),
  )
)

lights = Points(
  name = 'lights',
  mapping = {
    'seamark:type': (
      'light_major',
      'light_vessel',
      'light_float',
      'light_minor',

    )
  },
  fields = (
    ('seamark:name', String()),
    ('seamark:light:character', String()),
    ('seamark:light:colour', String()),
    ('seamark:light:sequence', String()),
    ('seamark:light:period', String()),
    ('seamark:light:category', String()),
    ('seamark:light:height', String()),
    ('seamark:light:multiple', String()),
    ('seamark:light:range', String()),
    ('seamark:light:group', String()),
    ('seamark:light_vessel:name', String()),
    ('seamark:light_vessel:colour', String()),
    ('seamark:light_vessel:colour_pattern', String()),
    ('seamark:light_float:name', String()),
    ('seamark:light_float:colour', String()),
    ('seamark:light_float:colour_pattern', String()),
    ('seamark:topmark:shape', String()),
    ('seamark:topmark:colour', String()),
    ('seamark:fixme', String()),
    )
)


light_arc = LineStrings (
    name='light_arc',
    mapping = {
        'seamark:light:object': (
            'light_major',
            'light_minor',
            )
        },
    fields = (
        ('seamark:arc_style', String()),
        ('seamark:light:object', String()),
        ('seamark:light:sector_nr', String()),
        ('seamark:light_arc', String()),
        ('seamark:light_radial', Integer()),
    )
)


sealane = LineStrings (
    name='sealane',
    mapping = {
        'seamark:type': (
            'separation_boundary',
            'separation_lane',
            'separation_zone',
        )
    },
    
    fields = (
        ('name', String()),
    )
)


marinefarm = LineStrings (
    name='marinefarm',
    mapping = {
        'seamark:type': (
            'marine_farm',
        )
    },
    
    fields = (
        ('seamark:marine_farm:category', String()),
        ('KSJ2:fish_right:product', String())
    )
)


landmarks = Points(
  name = 'landmarks',
  mapping = {
    'natural': (
      'bay',
      'beach',
      'cave_entrance',
      'cliff',
      'island',
      'stone',
      'ridge',
      'water',
      'wetland',
      'wood',
    )
  }
)


motorways_gen1 = GeneralizedTable(
    name = 'motorways_gen1',
    tolerance = meter_to_mapunit(50.0),
    origin = motorways,
)

mainroads_gen1 = GeneralizedTable(
    name = 'mainroads_gen1',
    tolerance = meter_to_mapunit(50.0),
    origin = mainroads,
)

railways_gen1 = GeneralizedTable(
    name = 'railways_gen1',
    tolerance = meter_to_mapunit(50.0),
    origin = railways,
)

motorways_gen0 = GeneralizedTable(
    name = 'motorways_gen0',
    tolerance = meter_to_mapunit(200.0),
    origin = motorways_gen1,
)

mainroads_gen0 = GeneralizedTable(
    name = 'mainroads_gen0',
    tolerance = meter_to_mapunit(200.0),
    origin = mainroads_gen1,
)

railways_gen0 = GeneralizedTable(
    name = 'railways_gen0',
    tolerance = meter_to_mapunit(200.0),
    origin = railways_gen1,
)

landusages_gen0 = GeneralizedTable(
    name = 'landusages_gen0',
    tolerance = meter_to_mapunit(200.0),
    origin = landusages,
    where = "ST_Area(geometry)>%f" % sqr_meter_to_mapunit(500000),
)

landusages_gen1 = GeneralizedTable(
    name = 'landusages_gen1',
    tolerance = meter_to_mapunit(50.0),
    origin = landusages,
    where = "ST_Area(geometry)>%f" % sqr_meter_to_mapunit(50000),
)

waterareas_gen0 = GeneralizedTable(
    name = 'waterareas_gen0',
    tolerance = meter_to_mapunit(200.0),
    origin = waterareas,
    where = "ST_Area(geometry)>%f" % sqr_meter_to_mapunit(500000),
)

waterareas_gen1 = GeneralizedTable(
    name = 'waterareas_gen1',
    tolerance = meter_to_mapunit(50.0),
    origin = waterareas,
    where = "ST_Area(geometry)>%f" % sqr_meter_to_mapunit(50000),
)

roads = UnionView(
    name = 'roads',
    fields = (
        ('bridge', 0),
        ('ref', None),
        ('tunnel', 0),
        ('oneway', 0),
        ('layer', 0),
        ('z_order', 0),
        ('access', None),
    ),
    mappings = [motorways, mainroads, minorroads, railways],
)

roads_gen1 = UnionView(
    name = 'roads_gen1',
    fields = (
        ('bridge', 0),
        ('ref', None),
        ('tunnel', 0),
        ('oneway', 0),
        ('z_order', 0),
        ('access', None),
    ),
    mappings = [railways_gen1, mainroads_gen1, motorways_gen1],
)

roads_gen0 = UnionView(
    name = 'roads_gen0',
    fields = (
        ('bridge', 0),
        ('ref', None),
        ('tunnel', 0),
        ('oneway', 0),
        ('z_order', 0),
        ('access', None),
    ),
    mappings = [railways_gen0, mainroads_gen0, motorways_gen0],
)
