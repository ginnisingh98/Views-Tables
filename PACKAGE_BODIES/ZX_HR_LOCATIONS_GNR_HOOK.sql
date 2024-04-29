--------------------------------------------------------
--  DDL for Package Body ZX_HR_LOCATIONS_GNR_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_HR_LOCATIONS_GNR_HOOK" AS
/* $Header: zxlocgnrb.pls 120.2 2006/07/14 21:45:09 akaran ship $*/

PROCEDURE create_geography(p_geography_type IN VARCHAR2,
                           p_geography_value IN VARCHAR2,
                           p_parent_geography_id IN NUMBER,
                           l_geography_id OUT NOCOPY NUMBER,
                           l_return_status OUT NOCOPY VARCHAR2) AS
  l_master_geo_rec  HZ_GEOGRAPHY_PUB.MASTER_GEOGRAPHY_REC_TYPE;
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(2000);

BEGIN
  l_master_geo_rec.geography_type := p_geography_type;
  l_master_geo_rec.geography_name := p_geography_value;
  IF p_geography_type in ('STATE','PROVINCE') THEN
    l_master_geo_rec.geography_code := p_geography_value;
  ELSE
    l_master_geo_rec.geography_code := null;
  END IF;
  l_master_geo_rec.start_date := to_date('01-01-1879','MM-DD-YYYY');
  l_master_geo_rec.end_date := to_date('12-31-4712','MM-DD-YYYY');
  l_master_geo_rec.geography_code_type:= 'FIPS_CODE';
  l_master_geo_rec.created_by_module := 'EBTAX_MIGRATION';
  l_master_geo_rec.application_id := 235;
  l_master_geo_rec.parent_geography_id(1):= p_parent_geography_id;

  HZ_GEOGRAPHY_PUB.create_master_geography('T',
                                                  l_master_geo_rec,
                                                  l_geography_id,
                                                  l_return_status,
                                                  x_msg_count,
                                                  x_msg_data);
  IF l_return_status = 'E' THEN
    --dbms_output.put_line(x_msg_data);
    null;
  END IF;
END;

PROCEDURE check_geography( p_location_id IN NUMBER,
                      p_country     IN VARCHAR2,
                      p_region_1    IN VARCHAR2,
                      p_region_2    IN VARCHAR2,
                      p_region_3    IN VARCHAR2,
                      p_town_or_city  IN VARCHAR2,
                      p_postal_code IN VARCHAR2,
                      p_style       IN VARCHAR2
) IS
  TYPE id_type IS TABLE OF NUMBER INDEX BY binary_integer;
  TYPE code_type IS TABLE OF VARCHAR2(30) INDEX BY binary_integer;
  l_loc_component_tbl code_type;
  l_geography_type code_type;
  l_geography_id_tbl id_type;
  l_country_geography_id NUMBER;
  l_geography_id NUMBER;
  l_geography_value VARCHAR2(150);
  l_return_status  VARCHAR2(1);
BEGIN
  IF p_location_id IS NOT NULL THEN
    SELECT map_dtl.loc_component, map_dtl.geography_type
    BULK COLLECT INTO l_loc_component_tbl, l_geography_type
    FROM hz_geo_struct_map map, hz_geo_struct_map_dtl map_dtl, hz_address_usages usage, hz_address_usage_dtls usage_dtls
   WHERE map.loc_tbl_name = 'HR_LOCATIONS_ALL'
   AND  map.address_style = p_style
   AND  map.country_code = p_country
   AND  map.map_id = map_dtl.map_id
   AND  map_dtl.map_id = usage.map_id
   AND  usage.usage_code = 'TAX'
   AND  usage.usage_id = usage_dtls.usage_id
   AND  map_dtl.geography_type = usage_dtls.geography_type
   ORDER BY map_dtl.loc_seq_num;

   SELECT geography_id
   INTO l_country_geography_id
   FROM hz_geographies
   WHERE geography_type = 'COUNTRY'
   AND  geography_code = p_country;

   FOR i IN l_loc_component_tbl.first..l_loc_component_tbl.last LOOP
     IF l_geography_type(i) <> 'COUNTRY' THEN

       IF l_country_geography_id IS NOT NULL THEN

           IF l_loc_component_tbl(i) = 'REGION_1' THEN
              l_geography_value := p_region_1;
           ELSIF l_loc_component_tbl(i) = 'REGION_2' THEN
              l_geography_value := p_region_2;
           ELSIF l_loc_component_tbl(i) = 'REGION_3' THEN
              l_geography_value := p_region_3;
           ELSIF l_loc_component_tbl(i) = 'TOWN_OR_CITY' THEN
              l_geography_value := p_town_or_city;
           ELSIF l_loc_component_tbl(i) = 'POSTAL_CODE' THEN
              l_geography_value := p_postal_code;
           END IF;

           BEGIN
             SELECT child_id
             INTO l_geography_id_tbl(i)
             FROM hz_hierarchy_nodes nodes, hz_geographies geo
             WHERE parent_id = l_geography_id_tbl(i-1)
             AND  parent_object_type = l_geography_type(i-1)
             AND  child_object_type = l_geography_type(i)
             AND  nodes.child_id = geo.geography_id
             AND  UPPER(geo.geography_name) = UPPER(l_geography_value)
             AND  nodes.level_number = 1;

           EXCEPTION WHEN NO_DATA_FOUND THEN
             l_geography_id_tbl(i) := null;

           END;
           IF l_geography_id_tbl(i) IS NULL AND l_geography_id_tbl(i-1) IS NOT NULL THEN
                create_geography( l_geography_type(i),
                                  l_geography_value,
                                  l_geography_id_tbl(i-1),
                                  l_geography_id,
                                  l_return_status);
              IF l_return_status = 'S' THEN
                l_geography_id_tbl(i) := l_geography_id;
              END IF;
           END IF;

        ELSE -- l_country_geography_id is null
          null;
        END IF;
     ELSE
       l_geography_id_tbl(i) := l_country_geography_id;
     END IF;

  END LOOP;
  END IF;
EXCEPTION WHEN OTHERS THEN
  null;
END;

PROCEDURE create_gnr (p_location_id IN NUMBER,
                      p_country     IN VARCHAR2,
                      p_region_1    IN VARCHAR2,
                      p_region_2    IN VARCHAR2,
                      p_region_3    IN VARCHAR2,
                      p_town_or_city  IN VARCHAR2,
                      p_postal_code IN VARCHAR2,
                      p_style       IN VARCHAR2
                      ) IS
  p_init_msg_list VARCHAR2(1);
  x_return_status VARCHAR2(1);
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(2000);
BEGIN
  check_geography( p_location_id,
                   p_country,
                   p_region_1,
                   p_region_2,
                   p_region_3,
                   p_town_or_city,
                   p_postal_code,
                   p_style);

  IF p_location_id IS NOT NULL THEN
    HZ_GNR_PUB.process_gnr ('HR_LOCATIONS_ALL',
                            p_location_id,
                            'C',
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data);
  END IF;

END create_gnr;

PROCEDURE update_gnr (p_location_id IN NUMBER,
	              p_country     IN VARCHAR2,
                      p_region_1    IN VARCHAR2,
                      p_region_2    IN VARCHAR2,
                      p_region_3    IN VARCHAR2,
                      p_town_or_city  IN VARCHAR2,
                      p_postal_code IN VARCHAR2,
                      p_style_o     IN VARCHAR2,
                      p_country_o   IN VARCHAR2,
                      p_region_1_o  IN VARCHAR2,
                      p_region_2_o  IN VARCHAR2,
                      p_region_3_o  IN VARCHAR2,
                      p_town_or_city_o IN VARCHAR2,
	              p_postal_code_o  IN VARCHAR2) IS
  p_init_msg_list VARCHAR2(1);
  x_return_status VARCHAR2(1);
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(2000);
BEGIN
  IF p_location_id IS NOT NULL THEN
    IF NVL(p_country, 'X')  <>  NVL(p_country_o, 'X') OR
       NVL(p_region_1,'X')  <>  NVL(p_region_1_o,'X') OR
       NVL(p_region_2,'X')  <>  NVL(p_region_2_o,'X') OR
       NVL(p_region_3,'X')  <>  NVL(p_region_3_o,'X') OR
       NVL(p_town_or_city,'X')  <> NVL(p_town_or_city_o,'X') OR
       NVL(p_postal_code, 'X') <>  NVL(p_postal_code_o, 'X')  THEN

       check_geography( p_location_id,
                        p_country,
                        p_region_1,
                        p_region_2,
                        p_region_3,
                        p_town_or_city,
                        p_postal_code,
                        p_style_o);


       HZ_GNR_PUB.process_gnr ('HR_LOCATIONS_ALL',
                               p_location_id,
                               'U',
                               p_init_msg_list,
                               x_return_status,
                               x_msg_count,
                               x_msg_data);

    END IF;
  END IF;
END update_gnr;

END zx_hr_locations_gnr_hook;

/
