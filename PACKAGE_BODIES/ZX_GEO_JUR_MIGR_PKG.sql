--------------------------------------------------------
--  DDL for Package Body ZX_GEO_JUR_MIGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_GEO_JUR_MIGR_PKG" AS
/* $Header: zxgeojurmigrb.pls 120.24.12010000.3 2009/02/09 18:50:52 sachandr ship $ */


PROCEDURE CREATE_ZONE_RANGE(p_zone_type IN VARCHAR2,
                            p_zone_name IN VARCHAR2,
                            p_zone_code IN VARCHAR2,
                            p_zone_code_type IN VARCHAR2,
                            p_zone_name_prefix IN VARCHAR2,
                            p_start_date IN DATE,
                            p_end_date IN DATE,
                            p_zone_relation_tbl IN HZ_GEOGRAPHY_PUB.ZONE_RELATION_TBL_TYPE,
                            x_zone_geography_id OUT NOCOPY NUMBER) IS

 l_geography_range_rec HZ_GEOGRAPHY_PUB.GEOGRAPHY_RANGE_REC_TYPE;
 l_zone_name VARCHAR2(360);
 i BINARY_INTEGER;
 x_msg_count NUMBER;
 x_msg_data VARCHAR2(2000);
 x_return_status VARCHAR2(1);
 l_count  NUMBER;
 l_zone_exists VARCHAR2(6);
BEGIN
  l_zone_name := p_zone_name_prefix || ' '||p_zone_name;
  --
  BEGIN
    SELECT geography_id
    INTO   x_zone_geography_id
    FROM hz_geographies
    WHERE geography_type = p_zone_type
    AND geography_name = l_zone_name;
    --
    l_zone_exists := 'TRUE';
    --
  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_zone_exists := 'FALSE';
  END;

  IF l_zone_exists = 'FALSE' THEN
    HZ_GEOGRAPHY_PUB.create_zone(
    p_init_msg_list             => 'T',
    p_zone_type                 => p_zone_type,
    p_zone_name                 => l_zone_name,
    p_zone_code                 => p_zone_code,
    p_zone_code_type            => 'FIPS_CODE',
    p_start_date                => to_date('01-01-1952', 'MM-DD-YYYY'),
    p_end_date                  => null,
    p_geo_data_provider         => NULL,
    p_language_code             => NULL,
    p_zone_relation_tbl         => p_zone_relation_tbl,
    p_geometry                  => NULL,
    p_timezone_code             => NULL,
    x_geography_id              => x_zone_geography_id,
    p_created_by_module         => 'EBTAX_MIGRAION',
    p_application_id            => 235,
    x_return_status             => x_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data
    );
  END IF;
--

END;


PROCEDURE CREATE_GEO_TYPE IS

  CURSOR geo_type IS
    SELECT segment_attribute_type
    FROM fnd_segment_attribute_values seg, ar_system_parameters_all sys
    WHERE seg.id_flex_code = 'RLOC'
    AND seg.id_flex_num = sys.location_structure_id
    AND seg.attribute_value = 'Y'
    AND segment_attribute_type NOT IN ('TAX_ACCOUNT', 'EXEMPT_LEVEL')
    GROUP BY segment_attribute_type;

  l_geo_type  VARCHAR2(30);
  l_geography_type_rec HZ_GEOGRAPHY_STRUCTURE_PUB.GEOGRAPHY_TYPE_REC_TYPE;
  x_geography_type VARCHAR2(30);
  x_return_status VARCHAR2(1);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(2000);
  BEGIN
     OPEN geo_type;
     LOOP
       FETCH geo_type INTO l_geography_type_rec.geography_type;
       EXIT WHEN geo_type%NOTFOUND;
       l_geography_type_rec.created_by_module := 'EBTAX_MIGRATION';
       l_geography_type_rec.application_id := 235;

  -- Create Postal Code also though it is not in use in any structure.

       HZ_GEOGRAPHY_STRUCTURE_PUB.create_geography_type('T',
                                                   l_geography_type_rec,
                                                   x_return_status,
                                                   x_msg_count,
                                                   x_msg_data);
     END LOOP;
     l_geography_type_rec.geography_type := 'REGION';
     l_geography_type_rec.created_by_module := 'EBTAX_MIGRATION';
     l_geography_type_rec.application_id := 235;


     HZ_GEOGRAPHY_STRUCTURE_PUB.create_geography_type('T',
                                                   l_geography_type_rec,
                                                   x_return_status,
                                                   x_msg_count,
                                                   x_msg_data);
  --EXCEPTION WHEN OTHERS THEN
  -- NULL;

  END;

PROCEDURE CREATE_ZONE_TYPE IS
  l_zone_type_rec HZ_GEOGRAPHY_STRUCTURE_PUB.ZONE_TYPE_REC_TYPE;
  TYPE seg_attr_type_tbl IS TABLE OF VARCHAR2(30) INDEX BY binary_integer;
  l_segment_attribute_type_tbl seg_attr_type_tbl;
  TYPE country_code_tbl IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;
  l_country_code_tbl country_code_tbl;
  TYPE location_structure_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_location_structure_id_tbl location_structure_id_tbl;
  TYPE geography_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_geography_id_tbl geography_id_tbl;
  l_incl_geo_type   HZ_GEOGRAPHY_STRUCTURE_PUB.INCL_GEO_TYPE_TBL_TYPE;
  l_incl_geo_type1   HZ_GEOGRAPHY_STRUCTURE_PUB.INCL_GEO_TYPE_TBL_TYPE;
  l_geo_rel_type_rec HZ_GEOGRAPHY_STRUCTURE_PUB.GEO_REL_TYPE_REC_TYPE;
  n BINARY_INTEGER;
  l_geography_id NUMBER;
  l_prev_structure_id NUMBER := -99;
  l_prev_country_code VARCHAR2(10) := '-1';
  x_relationship_type_id  NUMBER;
  x_return_status VARCHAR2(1);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(2000);
  BEGIN
    --Create city tax zone type for all countries with location based tax code.
    --Create override geo type for state and county in case of US
    SELECT sys.location_structure_id,
           SUBSTRB(sys.default_country,1, 2) default_country,
           attr.segment_attribute_type,
           geo.geography_id
    BULK COLLECT INTO
           l_location_structure_id_tbl, l_country_code_tbl,
           l_segment_attribute_type_tbl, l_geography_id_tbl
    FROM fnd_id_flex_structures struct, fnd_id_flex_segments_vl seg, fnd_segment_attribute_values attr,
         ar_system_parameters_all sys, hz_geographies geo
    WHERE struct.application_id = seg.application_id
    AND struct.id_flex_code = seg.id_flex_code
    AND struct.id_flex_num = seg.id_flex_num
    AND struct.freeze_flex_definition_flag = 'Y'
    AND struct.enabled_flag = 'Y'
    AND seg.application_id = attr.application_id
    AND seg.id_flex_code = attr.id_flex_code
    AND seg.id_flex_num =  attr.id_flex_num
    AND seg.application_column_name = attr.application_column_name
    AND seg.id_flex_num = sys.location_structure_id
    AND seg.id_flex_code = 'RLOC'
    AND seg.enabled_flag = 'Y'
    AND segment_attribute_type NOT IN ('TAX_ACCOUNT', 'EXEMPT_LEVEL')
    AND attr.attribute_value = 'Y'
    AND sys.default_country = geo.country_code
    AND geo.geography_type = 'COUNTRY'
    GROUP BY sys.location_structure_id, sys.default_country,
             segment_attribute_type, geo.geography_id
    ORDER BY sys.location_structure_id, sys.default_country,
             segment_attribute_type, geo.geography_id;
  --
 IF l_segment_attribute_type_tbl.count > 0 THEN
 FOR i IN l_segment_attribute_type_tbl.first..l_segment_attribute_type_tbl.last LOOP
        l_incl_geo_type(1) := l_segment_attribute_type_tbl(i);
        IF l_segment_attribute_type_tbl(i) = 'CITY' THEN
          l_incl_geo_type(2) := 'POSTAL_CODE';
        END IF;
        l_zone_type_rec.geography_type := substrb(l_country_code_tbl(i)||'_'||
                                          l_segment_attribute_type_tbl(i)||'_ZONE_TYPE_'||
                                          substrb(to_char(l_location_structure_id_tbl(i)), 1, 6),1,30);
        l_zone_type_rec.included_geography_type := l_incl_geo_type;
        l_zone_type_rec.postal_code_range_flag := 'Y';
        l_zone_type_rec.geography_use := 'TAX';
        IF l_incl_geo_type(1) = 'COUNTRY' THEN
          l_zone_type_rec.limited_by_geography_id := null;
        ELSE
          l_zone_type_rec.limited_by_geography_id := l_geography_id_tbl(i);
        END IF;
        l_zone_type_rec.created_by_module := 'EBTAX_MIGRATION';
        l_zone_type_rec.application_id := 235;
        HZ_GEOGRAPHY_STRUCTURE_PUB.create_zone_type('F',l_zone_type_rec,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data);
        IF l_country_code_tbl(i) = 'US' THEN
          l_incl_geo_type(1) := 'COUNTY';
          l_incl_geo_type(2) := 'CITY';
          l_incl_geo_type(3) := 'STATE';
          l_zone_type_rec.geography_type := substrb('US' || '_'|| 'OVERRIDE_ZONE_TYPE_' ||
           substrb(to_char(l_location_structure_id_tbl(i)), 1, 6),1,30);
          l_zone_type_rec.included_geography_type := l_incl_geo_type;
          l_zone_type_rec.postal_code_range_flag := 'Y';
          l_zone_type_rec.geography_use := 'TAX';
          l_zone_type_rec.limited_by_geography_id := l_geography_id_tbl(i);
          l_zone_type_rec.created_by_module := 'EBTAX_MIGRATION';
          l_zone_type_rec.application_id := 235;
          HZ_GEOGRAPHY_STRUCTURE_PUB.create_zone_type('F',l_zone_type_rec,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data);
        END IF;
        l_incl_geo_type.delete;
        IF l_prev_country_code <> l_country_code_tbl(i) THEN
          IF l_country_code_tbl(i) <> 'US' THEN
            l_incl_geo_type1(1) := l_segment_attribute_type_tbl(i);
            l_zone_type_rec.geography_type := substrb(l_country_code_tbl(i)||'_'|| 'OVERRIDE_ZONE_TYPE_' ||
                                          substrb(to_char(l_location_structure_id_tbl(i)), 1, 6),1,30);
            l_zone_type_rec.included_geography_type := l_incl_geo_type1;
            l_zone_type_rec.postal_code_range_flag := 'Y';
            l_zone_type_rec.geography_use := 'TAX';
            l_zone_type_rec.limited_by_geography_id := l_geography_id_tbl(i);
            l_zone_type_rec.created_by_module := 'EBTAX_MIGRATION';
            l_zone_type_rec.application_id := 235;
            HZ_GEOGRAPHY_STRUCTURE_PUB.create_zone_type('F',l_zone_type_rec,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data);
          END IF;
          l_prev_country_code := l_country_code_tbl(i);
        ELSE
          IF l_country_code_tbl(i) <> 'US' THEN
          l_geo_rel_type_rec.geography_type := l_segment_attribute_type_tbl(i);
          l_geo_rel_type_rec.parent_geography_type :=
                substrb(l_country_code_tbl(i)||'_'|| 'OVERRIDE_ZONE_TYPE_' ||
                substrb(to_char(l_location_structure_id_tbl(i)), 1, 6),1,30);
          l_geo_rel_type_rec.status   := 'A';
          l_geo_rel_type_rec.created_by_module  := 'EBTAX_MIGRATION';
          l_geo_rel_type_rec.application_id     := 235;


          HZ_GEOGRAPHY_STRUCTURE_PUB.create_geo_rel_type(
          p_init_msg_list               =>  'F',
          p_geo_rel_type_rec              => l_geo_rel_type_rec,
          x_relationship_type_id          => x_relationship_type_id,
          x_return_status               => x_return_status,
          x_msg_count                   => x_msg_count,
          x_msg_data                     => x_msg_data
          );
          END IF;
          l_prev_country_code := l_country_code_tbl(i);



        END IF;
  END LOOP;
  END IF;
END;

END;

/
