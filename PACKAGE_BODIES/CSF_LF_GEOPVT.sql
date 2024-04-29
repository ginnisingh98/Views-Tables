--------------------------------------------------------
--  DDL for Package Body CSF_LF_GEOPVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_LF_GEOPVT" AS
  /* $Header: CSFVGEOB.pls 120.5.12010000.3 2010/03/02 06:55:41 rajukum noship $*/

 /**
    * Returns the address components like country, state, city,street
    *and building after doing reverse geo coding.
 */
 PROCEDURE insert_geo_batch_address(
             p_task_rec    csf_task_address_pvt.task_rec_type
    )
    IS
    BEGIN
     INSERT INTO csf_geo_batch_address(
       ADDRESS1,
       ADDRESS2,
       ADDRESS3,
       ADDRESS4,
       POSTAL_CODE,
       CITY,
       COUNTY,
       STATE,
       COUNTRY,
       ADDRESS_ID)
       VALUES
       (initcap(p_task_rec.address1),
       initcap(p_task_rec.address2),
       initcap(p_task_rec.address3),
       initcap(p_task_rec.address4),
       p_task_rec.postal_code,
       initcap(p_task_rec.city),
       initcap(p_task_rec.county),
       initcap(p_task_rec.state),
       initcap(p_task_rec.country),
       p_task_rec.location_id
       );
    END;

    PROCEDURE update_geo_batch_address(
              p_task_rec    csf_task_address_pvt.task_rec_type
    )
    IS
    BEGIN
     UPDATE csf_geo_batch_address SET
       ADDRESS1 = initcap(p_task_rec.address1),
       ADDRESS2 = initcap(p_task_rec.address2),
       ADDRESS3 = initcap(p_task_rec.address3),
       ADDRESS4 = initcap(p_task_rec.address4),
       POSTAL_CODE = p_task_rec.postal_code,
       CITY = initcap(p_task_rec.city),
       COUNTY = initcap(p_task_rec.county),
       STATE = initcap(p_task_rec.state),
       COUNTRY = initcap(p_task_rec.country),
       ACCURACY = NULL,
       LATITUDE = NULL,
       LONGITUDE = NULL,
       SEGMENT_ID = NULL
     WHERE ADDRESS_ID = p_task_rec.location_id;
    END;

    PROCEDURE delete_valid_geo_batch_address
    IS
    BEGIN
     DELETE FROM csf_geo_batch_address
     WHERE ACCURACY >= fnd_profile.VALUE('CSF_LOC_ACC_LEVELS');
     commit;
    END;

    PROCEDURE move_invalid_to_geo_batch(
           p_task_rec    csf_task_address_pvt.task_rec_type
     )
     IS
     l_location_id  NUMBER;
     BEGIN
      l_location_id := 0;
      SELECT count(*) into l_location_id FROM csf_geo_batch_address WHERE address_id = p_task_rec.location_id;
      IF(l_location_id = 0)
      THEN
       insert_geo_batch_address(p_task_rec);
      ELSIF(l_location_id = 1)
      THEN
       update_geo_batch_address(p_task_rec);
      END IF;
     END;

PROCEDURE resolve_address(
    p_api_version       IN        NUMBER
  , x_return_status    OUT NOCOPY VARCHAR2
  , x_msg_count        OUT NOCOPY NUMBER
  , x_msg_data         OUT NOCOPY VARCHAR2
  , p_location_id       IN        NUMBER
  , p_address1          IN        VARCHAR2
  , p_address2          IN        VARCHAR2
  , p_address3          IN        VARCHAR2
  , p_address4          IN        VARCHAR2
  , p_city              IN        VARCHAR2
  , p_postalcode        IN        VARCHAR2
  , p_county            IN        VARCHAR2
  , p_state             IN        VARCHAR2
  , p_province          IN        VARCHAR2
  , p_country           IN        VARCHAR2
  , p_accu_fac      OUT NOCOPY NUMBER
  , p_segment_id    OUT NOCOPY NUMBER
  , p_offset        OUT NOCOPY NUMBER
  , p_side          OUT NOCOPY NUMBER
  , p_lon           OUT NOCOPY NUMBER
  , p_lat           OUT NOCOPY NUMBER
  )
  IS
   l_country_code        hz_locations.country%TYPE;
   l_geometry                    mdsys.sdo_geometry;
   CURSOR c_country_code (p_country hz_locations.country%TYPE)
      IS
         SELECT ftt.territory_code country_code
           FROM fnd_territories_tl ftt
          WHERE UPPER (ftt.territory_short_name) = UPPER (p_country)
            AND ftt.language = 'US';
  BEGIN
    OPEN c_country_code (p_country);
     FETCH c_country_code
      INTO l_country_code;
     CLOSE c_country_code;

  csf_resource_address_pvt.resolve_address(
    p_api_version       =>  p_api_version
  , x_return_status     =>  x_return_status
  , x_msg_count         =>  x_msg_count
  , x_msg_data          =>  x_msg_data
  , p_location_id       =>  p_location_id
  , p_building_num      =>  '_'
  , p_address1          =>  p_address1
  , p_address2          =>  p_address2
  , p_address3          =>  p_address3
  , p_address4          =>  p_address4
  , p_city              =>  p_city
  , p_state             =>  p_state
  , p_postalcode        =>  p_postalcode
  , p_county            =>  p_county
  , p_province          =>  p_province
  , p_country           =>  p_country
  , p_country_code      =>  l_country_code
  , x_geometry          =>  l_geometry
  , p_commit            =>  'T'
  , p_update_address    =>  'T'
  );
      IF (x_return_status = 'S')THEN
                p_segment_id := l_geometry.sdo_ordinates(5);
                p_offset := l_geometry.sdo_ordinates(6);
                p_side := l_geometry.sdo_ordinates(7);
                p_lon   := l_geometry.sdo_ordinates(2);
                p_lat   := l_geometry.sdo_ordinates(1);
                p_accu_fac := l_geometry.sdo_ordinates(3);
      END IF;
  END;

PROCEDURE CSF_LF_ResolveGEOAddress
(  p_api_version   IN         NUMBER
 , p_init_msg_list IN         VARCHAR2 default FND_API.G_FALSE
 , p_latitude      IN         NUMBER
 , p_longitude     IN         NUMBER
 , p_dataset       IN         VARCHAR2
 , p_country       OUT NOCOPY VARCHAR2
 , p_state         OUT NOCOPY VARCHAR2
 , p_county        OUT NOCOPY VARCHAR2
 , p_city          OUT NOCOPY VARCHAR2
 , p_roadname      OUT NOCOPY VARCHAR2
 , p_postalcode    OUT NOCOPY VARCHAR2
 , p_bnum          OUT NOCOPY VARCHAR2
 , p_dist          OUT NOCOPY VARCHAR2
 , p_accuracy_lvl  OUT NOCOPY VARCHAR2
 , x_msg_count     OUT NOCOPY NUMBER
 , x_msg_data      OUT NOCOPY VARCHAR2
 , x_return_status OUT NOCOPY VARCHAR2
)

IS
  l_api_name    CONSTANT VARCHAR2(30) := 'CSF_LF_ResolveGEOAddress';
  l_api_version CONSTANT NUMBER       := 1.0;
  l_count           NUMBER := 0;
  l_dist            NUMBER := -1;
  l_within_dist     NUMBER := -1;
  l_parentid        VARCHAR2(40);
  l_place_lvl       VARCHAR2(10);
  l_countryid       VARCHAR2(40);
  l_name            VARCHAR2(100);
  l_prevname        VARCHAR2(100);
  l_roadsegmentid   VARCHAR2(40);
  l_accuracy_lvl    VARCHAR2(10) := NVL(fnd_profile.value('CSF_LOC_ACC_LEVELS'),''+0);
  l_profile         VARCHAR2(10);
  l_acc_dist        VARCHAR2(40);
  l_sql_stmt        VARCHAR2(2000);
  l_dyn_tbl_name    VARCHAR2(10) := NVL(fnd_profile.value('CSF_SPATIAL_DATASET_NAME'),'');

  TYPE ref_cursor_type IS REF CURSOR;

  --Cursor to find out the nearest geometry with in specified range from poi table
   cursor_poi_dist_chk ref_cursor_type;
   cursor_poi ref_cursor_type;

 --Cursor to find out the nearest geometry with in specified range from road segment table in case if not exist in poi table
    cursor_rdseg_dist_chk ref_cursor_type;
    cursor_rdseg ref_cursor_type;

BEGIN

  if ( l_api_version <> p_api_version ) then
    raise csf_lf_version_error;
  end if;

  if ( p_init_msg_list = 'TRUE' ) then
    x_msg_count := 0; /* FND_MSG_PUB.initialize; */
  end if;

  l_dyn_tbl_name := p_dataset;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  p_accuracy_lvl  :=  l_accuracy_lvl;
  --
  -- Validate parameters
  --

  if ( p_latitude = NULL or p_latitude = '' ) then
    raise CSF_LF_LATITUDE_NOT_SET_ERROR;
  end if;

  if ( p_longitude = NULL or p_longitude = '' ) then
    raise CSF_LF_LONGITUDE_NOT_SET_ERROR;
  end if;

  --Initialize message count and mssage data. we will use var x_msg_data to store info which can be used for debug purpose
  x_msg_count := 0;
  x_msg_data := 'Success';

  if(l_accuracy_lvl = '2') then
    l_profile := '100';
  elsif (l_accuracy_lvl = '1') then
    l_profile := '2000';
  else
    l_profile := '10000';
  end if;

  l_acc_dist := 'distance=' || l_profile ;

  if(l_dyn_tbl_name = 'NONE') then
     l_dyn_tbl_name := '';
  end if;



   --Open cursor to check the nearest geometry with in specified range from poi table
   l_sql_stmt := 'SELECT 1  FROM csf_lf_pois' || l_dyn_tbl_name || ' r
    WHERE SDO_WITHIN_DISTANCE(r.poi_point, SDO_GEOMETRY(2004,8307,null,SDO_ELEM_INFO_ARRAY(1,1,1,3,0,5),
    SDO_ORDINATE_ARRAY(:1, :2)),:3) = ''TRUE''  and rownum = 1';

  OPEN cursor_poi_dist_chk for l_sql_stmt USING p_longitude,p_latitude,l_acc_dist;
   LOOP
    FETCH cursor_poi_dist_chk INTO l_within_dist;
    EXIT WHEN cursor_poi_dist_chk%NOTFOUND;
   END LOOP;
  CLOSE cursor_poi_dist_chk;

  --Open cursor to fetch the nearest geometry with in specified range from poi table
 IF(l_within_dist <> -1) THEN
  l_sql_stmt := 'SELECT /*+ INDEX(r CSF_LF_POIS_N2) */ ROADSEGMENT_ID, SDO_NN_DISTANCE(1) dist
                  FROM csf_lf_pois' || l_dyn_tbl_name || '  r
                  WHERE SDO_NN(r.poi_point, SDO_GEOMETRY(2004,8307,null,SDO_ELEM_INFO_ARRAY(1,1,1,3,0,5),
                  SDO_ORDINATE_ARRAY(:1, :2)), ''sdo_num_res=1'', 1) = ''TRUE'' ORDER BY dist';

   OPEN cursor_poi for l_sql_stmt USING p_longitude,p_latitude;
    LOOP
     FETCH cursor_poi INTO l_roadsegmentid, l_dist; -- fetch data into local variables
     EXIT WHEN cursor_poi%NOTFOUND;
    END LOOP;
   CLOSE cursor_poi;
 END IF;

  x_msg_count := 1;
  x_msg_data := ':acrcy_lvl:' || l_accuracy_lvl || ':profile_dist:' || l_profile || ':poi_dist:' || l_dist;

  --Open cursor to fetch the nearest geometry with in specified range from road segment table in case if not exist in poi table
 if(l_dist = -1) THEN
    l_within_dist := -1;
    l_sql_stmt := 'SELECT 1  FROM csf_lf_roadsegments' || l_dyn_tbl_name || '  r
    WHERE SDO_WITHIN_DISTANCE(r.ROADSEGMENT_GEOMETRY, SDO_GEOMETRY(2002,8307,null,SDO_ELEM_INFO_ARRAY(1,2,1),
    SDO_ORDINATE_ARRAY(:1, :2)),:3) = ''TRUE''  and rownum = 1';

    --Open cursor to check the nearest geometry with in specified range from road segmen table
   OPEN cursor_rdseg_dist_chk for l_sql_stmt USING p_longitude,p_latitude,l_acc_dist;
    LOOP
     FETCH cursor_rdseg_dist_chk INTO l_within_dist; -- fetch data into local variables
     EXIT WHEN cursor_rdseg_dist_chk%NOTFOUND;
    END LOOP;
   CLOSE cursor_rdseg_dist_chk;


  IF(l_within_dist <> -1) THEN
    l_sql_stmt := 'SELECT /*+ INDEX(r CSF_LF_RDSEGS_N2) */ ROADSEGMENT_ID, SDO_NN_DISTANCE(1) dist
  FROM csf_lf_roadsegments' || l_dyn_tbl_name || '  r
  WHERE SDO_NN(r.ROADSEGMENT_GEOMETRY, SDO_GEOMETRY(2002,8307,null,SDO_ELEM_INFO_ARRAY(1,2,1),
  SDO_ORDINATE_ARRAY(:1, :2, :3, :4)),
        ''sdo_num_res=1'', 1) = ''TRUE''  ORDER BY dist';

  OPEN cursor_rdseg for l_sql_stmt USING p_longitude,p_latitude,p_longitude,p_latitude;
    LOOP
   FETCH cursor_rdseg INTO l_roadsegmentid, l_dist; -- fetch data into local variables
     EXIT WHEN cursor_rdseg%NOTFOUND;
    END LOOP;
   CLOSE cursor_rdseg;
    x_msg_count := 1;
    x_msg_data := ':acrcy_lvl:' || l_accuracy_lvl || ':rd_dist:' || l_dist;
  END IF;
 END IF;

 p_dist := l_dist;

 --check if any nearest geometry found with in the specified range
 if (l_dist <> -1) THEN
  ---Query to find postal code for given roadsegmentId
    l_sql_stmt := 'select postal_code from csf_lf_roadsegm_posts' || l_dyn_tbl_name || '  rp, csf_lf_postcodes' || l_dyn_tbl_name || '  p where rp.postal_code_id =
  p.postal_code_id and rp.roadsegment_id = :1 and rownum = 1';

  EXECUTE IMMEDIATE l_sql_stmt into p_postalcode USING l_roadsegmentid;

  x_msg_data := x_msg_data || ':pc:' || p_postalcode;

  ---Query to find street name for given roadsegmentId
   l_sql_stmt := 'select n.name , p.place_id from csf_lf_names' || l_dyn_tbl_name || '   n,csf_lf_roadsegm_places' || l_dyn_tbl_name ||
  '   pn, csf_lf_places' || l_dyn_tbl_name || '   p, csf_lf_roadsegm_names' || l_dyn_tbl_name ||
  '  rn where rn.roadsegment_id = :1 and rn.name_id = n.name_id and rn.roadsegment_id =
  pn.roadsegment_id and pn.place_id = p.place_id and rownum = 1';

  EXECUTE IMMEDIATE l_sql_stmt into p_roadname, l_parentid USING l_roadsegmentid;

   x_msg_data := x_msg_data || ':st_name:' || p_roadname || ':pl_id:' || l_parentid;

  ---Query to find building number for given roadsegmentId
    l_sql_stmt := 'Select round((min(address_start) + max(address_end))/2) from (select   block_id, 1
  address_side,left_address_format address_format, left_address_scheme address_scheme, start_left_address
  address_start, end_left_address  address_end, address_type from  csf_lf_blocks' || l_dyn_tbl_name || '   where roadsegment_id = :1 union all
  select   block_id,  2,  right_address_format, right_address_scheme,start_right_address, end_right_address, address_type
  from csf_lf_blocks where roadsegment_id = :2 and rownum = 1)';

  EXECUTE IMMEDIATE l_sql_stmt into p_bnum USING l_roadsegmentid,l_roadsegmentid;

   x_msg_data := x_msg_data || ':bnum:' || p_bnum;

  ---Query to find parent place names for derived street name using its parentId
  while l_parentid <> -1 LOOP
   l_countryid := l_parentid;

   --Query to find name of place Id and its parent place Id
    l_sql_stmt := 'select  n.name, p.parent_place_id, p.place_parent_level from csf_lf_names' || l_dyn_tbl_name || '   n,
   csf_lf_place_names' || l_dyn_tbl_name || '   pn, csf_lf_places' || l_dyn_tbl_name || '   p where n.name_id = pn.name_id and
   pn.place_id = p.place_id and p.place_id = :1 and pn.name_type = ''O'' and rownum = 1';

   EXECUTE IMMEDIATE l_sql_stmt into l_name, l_parentid, l_place_lvl  USING l_parentid;


   x_msg_data := x_msg_data || ':parent_name_' || l_count || ':' || l_name || ':parent_id_' || l_count || ':' || l_parentid;

   if(l_count = 0) THEN
     p_city := l_name;
   ELSE
    if (l_prevname <> l_name and l_parentid <> -1 and l_place_lvl <> 0) THEN
      p_county := l_name;
    end if;

    if (l_prevname <> l_name and l_parentid <> -1) THEN
      p_state := l_name;
    end if;
  end if;

  l_count := l_count + 1;
  l_prevname := l_name;
 END LOOP;

  x_msg_data := x_msg_data || ':county:' || p_county || ':state:' || p_state;

  --Query to find out country name
  l_sql_stmt := 'select country_name from csf_sdm_ctry_profiles' || l_dyn_tbl_name || '   where place_id = :1 and
  NATIONAL_LANG_CODE = ''ENG''';

  EXECUTE IMMEDIATE l_sql_stmt into p_country USING l_countryid;


  x_msg_data := x_msg_data || ':country:' || p_country;

 ELSE
  x_return_status := FND_API.G_RET_STS_ERROR;
 end if; -- End of if (l_dist <> -1)

 x_msg_data := x_msg_data || ':ret_status:' || x_return_status;

EXCEPTION
  when CSF_LF_VERSION_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := 'Incompatibale version';
  when others then
    x_return_status := FND_API.G_RET_STS_ERROR;

END CSF_LF_ResolveGEOAddress;

PROCEDURE CSF_LF_ResolveAddress
( p_api_version   IN         NUMBER
, p_init_msg_list IN         VARCHAR2 default FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_country       IN         VARCHAR2
, p_state         IN         VARCHAR2 default NULL
, p_county        IN         VARCHAR2 DEFAULT NULL
, p_province      IN         VARCHAR2 DEFAULT NULL
, p_city          IN         VARCHAR2
, p_postalCode    IN         VARCHAR2 default NULL
, p_roadname      IN         VARCHAR2
, p_buildingnum   IN         VARCHAR2  default NULL
, p_alternate     IN         VARCHAR2  default NULL
, p_accu_fac      OUT NOCOPY NUMBER
, p_segment_id    OUT NOCOPY NUMBER
, p_offset        OUT NOCOPY NUMBER
, p_side          OUT NOCOPY NUMBER
, p_lon           OUT NOCOPY NUMBER
, p_lat           OUT NOCOPY NUMBER
, p_srid          OUT NOCOPY NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'CSF_LF_ResolveAddress';
  l_api_version CONSTANT NUMBER       := 1.0;
  l_retCode      NUMBER;
  l_numResults   NUMBER;
  l_return_status VARCHAR2(1);
  l_result_array   csf_lf_pub.csf_lf_resultarray;
BEGIN
  l_result_array := csf_lf_pub.csf_lf_resultarray();
           csf_lf_pub.csf_lf_resolveaddress(
                         p_api_version   => l_api_version
                       , p_init_msg_list => FND_API.G_FALSE
                       , x_return_status => x_return_status
                       , x_msg_count     => x_msg_count
                       , x_msg_data      => x_msg_data
                       , p_country       => p_country
                       , p_state         => p_state
                       , p_city          => p_city
                       , p_postalCode    => p_postalcode
                       , p_roadname      => p_roadname
                       , p_buildingnum   => p_buildingnum
                       , p_alternate     => p_alternate
                       , x_resultsArray  => l_result_array);
IF (x_return_status = 'S')THEN
  p_accu_fac := l_result_array(1).accuracy_factor;
  p_segment_id := l_result_array(1).locus.sdo_ordinates(5);
  p_offset  := l_result_array(1).locus.sdo_ordinates(6);
  p_side := l_result_array(1).locus.sdo_ordinates(7);
  p_lon := l_result_array(1).locus.sdo_ordinates(2);
  p_lat := l_result_array(1).locus.sdo_ordinates(1);
  p_srid := l_result_array(1).locus.sdo_srid;
END IF;
END CSF_LF_ResolveAddress;

END CSF_LF_GEOPVT;

/
