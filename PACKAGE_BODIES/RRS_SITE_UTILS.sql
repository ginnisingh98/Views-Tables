--------------------------------------------------------
--  DDL for Package Body RRS_SITE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_SITE_UTILS" AS
/* $Header: RRSUTILB.pls 120.15.12010000.11 2010/02/18 22:11:21 jijiao ship $ */

FUNCTION GET_LOCATION_ADDRESS
(
	p_site_id IN NUMBER
) RETURN VARCHAR2
IS
l_address1 hz_locations.address1%type;
l_city hz_locations.city%type;
l_state hz_locations.city%type;
l_postal_code hz_locations.postal_code%type;
l_ret varchar2(2000);

BEGIN

select  hl.address1,
	hl.city,
	hl.state,
	nvl(hl.postal_code,' ')
into
	l_address1,
	l_city,
	l_state,
	l_postal_code
from
	hz_locations hl,
	rrs_sites_b rs
where
	rs.location_id = hl.location_id
	and rs.site_id = p_site_id;

IF(l_address1 is not null) THEN
	l_ret := l_address1;
END IF;
IF(l_ret is not null) THEN
	IF(l_city is not null) THEN
		l_ret := l_ret  || ', '||l_city;
	END IF;
ELSE
	l_ret := l_city;
END IF;

IF(l_ret is not null) THEN
	IF(l_state is not null) THEN
		l_ret := l_ret || ', '||l_state ||' '||l_postal_code;
	END IF;
ELSE
	l_ret := l_state;
END IF;
RETURN l_ret;
END GET_LOCATION_ADDRESS;

FUNCTION GET_SITE_DISPLAY_NAME
(
	p_site_id IN NUMBER
) RETURN VARCHAR2
IS
l_ret varchar2(2000);

BEGIN
select     rs.site_identification_number
into       l_ret
from	   rrs_sites_b rs
where      rs.site_id = p_site_id;

RETURN l_ret;
END GET_SITE_DISPLAY_NAME;

FUNCTION GET_USER_ATTR_VAL
(
	p_attr_grp_type IN VARCHAR2,
	p_attr_grp_name IN VARCHAR2,
	p_attr_name IN VARCHAR2,
	p_object_name IN VARCHAR2,
	p_pk_col_val IN VARCHAR2
)RETURN VARCHAR2
IS
l_user_attr_val       VARCHAR2(1000);

BEGIN
IF(p_object_name = 'RRS_SITE') THEN
	l_user_attr_val := EGO_USER_ATTRS_DATA_PVT.Get_User_Attr_Val
	(
	 p_appl_id              => 718
	,p_attr_grp_type        => p_attr_grp_type
	,p_attr_grp_name        => p_attr_grp_name
	,p_attr_name            => p_attr_name
	,p_object_name          => p_object_name
	,p_pk_col1              => 'SITE_ID'
	,p_pk_value1            => p_pk_col_val
	);
ELSIF(p_object_name = 'RRS_LOCATION') THEN
	l_user_attr_val := EGO_USER_ATTRS_DATA_PVT.Get_User_Attr_Val
	(
	 p_appl_id		=> 718
	,p_attr_grp_type        => p_attr_grp_type
	,p_attr_grp_name        => p_attr_grp_name
	,p_attr_name            => p_attr_name
	,p_object_name          => p_object_name
	,p_pk_col1              => 'LOCATION_ID'
	,p_pk_value1            => p_pk_col_val
	);
ELSIF(p_object_name = 'RRS_TRADE_AREA') THEN
	l_user_attr_val := EGO_USER_ATTRS_DATA_PVT.Get_User_Attr_Val
	(
	 p_appl_id              => 718
	,p_attr_grp_type        => p_attr_grp_type
	,p_attr_grp_name        => p_attr_grp_name
	,p_attr_name            => p_attr_name
	,p_object_name          => p_object_name
	,p_pk_col1              => 'TRADE_AREA_ID'
	,p_pk_value1            => p_pk_col_val
	);
END IF;

RETURN l_user_attr_val;
END Get_User_Attr_Val;

PROCEDURE INSERT_TEMP_FOR_MAP
(
	x_theme_id OUT NOCOPY NUMBER,
	p_session_id IN VARCHAR2,
	p_context_flag IN VARCHAR2,
	p_site_ids IN RRS_NUMBER_TBL_TYPE DEFAULT NULL,
	p_tag_code IN NUMBER DEFAULT NULL,
	p_x_coord IN NUMBER DEFAULT NULL,
	p_y_coord IN NUMBER DEFAULT NULL
)
IS
l_geometry RRS_SITE_TMP.geometry%type;
l_trade_area_number_code rrs_group_trade_areas.trade_area_number_code%type;
--Bug 4903895 - Start Code
/*
CURSOR primary_tag_cursor IS
		select
			SDO_UTIL.CIRCLE_POLYGON(l.GEOMETRY.SDO_POINT.X , l.GEOMETRY.SDO_POINT.Y ,
			DECODE(rtag.unit_of_measure_code,'KILOMETER',rgta.outer_bound*1000,'MILE',rgta.outer_bound*1609.344),   10),
			rgta.trade_area_number_code
		from
			rrs_trade_area_groups_b rtag,
			rrs_group_trade_areas rgta,
			rrs_loc_trade_area_grps rltag,
			hz_locations l,
			rrs_sites_b rs
		where
			rltag.is_primary_flag	= 'Y' and
			rtag.group_id 		= rltag.group_id and
			rgta.group_id 		= rltag.group_id and
			rltag.location_id 	= l.location_id and
			l.location_id 		= rs.location_id and
			rs.site_id in (select site_id from RRS_SITE_TMP where session_id = p_session_id and geometry is null)
		order by
			rgta.trade_area_number_code desc;
CURSOR other_tag_cursor IS
		select
			SDO_UTIL.CIRCLE_POLYGON(l.GEOMETRY.SDO_POINT.X , l.GEOMETRY.SDO_POINT.Y ,
			DECODE(rtag.unit_of_measure_code,'KILOMETER',rgta.outer_bound*1000,'MILE',rgta.outer_bound*1609.344),   10),
			rgta.trade_area_number_code
		from
			rrs_trade_area_groups_b rtag,
			rrs_group_trade_areas rgta,
			rrs_loc_trade_area_grps rltag,
			hz_locations l,
			rrs_sites_b rs
		where
			rgta.group_id		= p_tag_code and
			rtag.group_id 		= rltag.group_id and
			rgta.group_id 		= rltag.group_id and
			rltag.location_id 	= l.location_id and
			l.location_id 		= rs.location_id and
			rs.site_id in (select site_id from RRS_SITE_TMP where session_id = p_session_id and geometry is null)
		order by
			rgta.trade_area_number_code desc;
*/
CURSOR primary_tag_cursor IS
		select
			SDO_UTIL.CIRCLE_POLYGON(l.GEOMETRY.SDO_POINT.X , l.GEOMETRY.SDO_POINT.Y ,
			DECODE(rtag.unit_of_measure_code,'KILOMETER',rgta.outer_bound*1000,'MILE',rgta.outer_bound*1609.344),   10),
			rgta.trade_area_number_code
		from
			rrs_trade_area_groups_b rtag,
			rrs_group_trade_areas rgta,
			rrs_loc_trade_area_grps rltag,
			hz_locations l,
			rrs_sites_b rs,
			rrs_site_tmp tmp
		where
			rltag.is_primary_flag	= 'Y' and
			rtag.group_id 		= rltag.group_id and
			rgta.group_id 		= rltag.group_id and
			rltag.location_id 	= l.location_id and
			l.location_id 		= rs.location_id and
			rs.site_id = tmp.site_id and
			tmp.session_id = p_session_id and
			tmp.geometry is null
		order by
			rgta.trade_area_number_code desc;
CURSOR other_tag_cursor IS
		select
			SDO_UTIL.CIRCLE_POLYGON(l.GEOMETRY.SDO_POINT.X , l.GEOMETRY.SDO_POINT.Y ,
			DECODE(rtag.unit_of_measure_code,'KILOMETER',rgta.outer_bound*1000,'MILE',rgta.outer_bound*1609.344),   10),
			rgta.trade_area_number_code
		from
			rrs_trade_area_groups_b rtag,
			rrs_group_trade_areas rgta,
			rrs_loc_trade_area_grps rltag,
			hz_locations l,
			rrs_sites_b rs,
			rrs_site_tmp   tmp
		where
			rgta.group_id = p_tag_code and
			rtag.group_id = rltag.group_id and
			rgta.group_id = rltag.group_id and
			rltag.location_id = l.location_id and
			l.location_id = rs.location_id
			and rs.site_id = tmp.site_id
			and tmp.session_id = p_session_id
			and tmp.geometry is null
		order by rgta.trade_area_number_code desc;
--Bug 4903895 - End Code

BEGIN
IF(p_context_flag = 'SITE') THEN

	select nvl(max(to_number(theme_id)),0) +1
	into x_theme_id
	from RRS_SITE_TMP
	where session_id= p_session_id and geometry is null;

	forall i in 1..p_site_ids.count
		insert into RRS_SITE_TMP
		(session_id,theme_id,site_id)
		values
		(p_session_id,x_theme_id,p_site_ids(i));

ELSIF(p_context_flag = 'TRADE_AREA') THEN
	IF(p_tag_code = 0) THEN
		OPEN primary_tag_cursor;
		LOOP
			FETCH primary_tag_cursor INTO l_geometry, l_trade_area_number_code;
			EXIT WHEN primary_tag_cursor%NOTFOUND;
			insert into RRS_SITE_TMP
			(session_id,geometry,theme_id)
			values
			(p_session_id,l_geometry,l_trade_area_number_code);
		END LOOP;
		CLOSE primary_tag_cursor;
	ELSIF(p_tag_code > 0) THEN
		OPEN other_tag_cursor;
		LOOP
			FETCH other_tag_cursor INTO l_geometry, l_trade_area_number_code;
			EXIT WHEN other_tag_cursor%NOTFOUND;
			insert into RRS_SITE_TMP
			(session_id,geometry,theme_id)
			values
			(p_session_id,l_geometry,l_trade_area_number_code);
		END LOOP;
		CLOSE other_tag_cursor;
	END IF;
	x_theme_id := 0;

ELSIF(p_context_flag = 'IDENTIFY' OR p_context_flag = 'POINT_FEATURE' OR p_context_flag = 'POINT_FEATURE_AT_LOCATION') THEN

	select SDO_GEOMETRY(2001,8307,SDO_POINT_TYPE(p_x_coord,p_y_coord,null),null,null)
	into l_geometry
	from dual;

	IF(p_context_flag = 'IDENTIFY') THEN
		insert into RRS_SITE_TMP
		(session_id,theme_id,geometry)
		values
		(p_session_id,'-1',l_geometry);
	ELSIF(p_context_flag = 'POINT_FEATURE') THEN
		insert into RRS_SITE_TMP
		(session_id,theme_id,geometry)
		values
		(p_session_id,'0',l_geometry);
	ELSIF(p_context_flag = 'POINT_FEATURE_AT_LOCATION') THEN
		insert into RRS_SITE_TMP
		(session_id,theme_id,geometry)
		values
		(p_session_id,'-2',l_geometry);
	END IF;
	x_theme_id := 0;

END IF;
EXCEPTION when others then
	x_theme_id := -1;

END INSERT_TEMP_FOR_MAP;

PROCEDURE CLEAR_TEMP_FOR_MAP
(
	p_session_id IN VARCHAR2,
	p_delete_theme IN VARCHAR2
)
IS
BEGIN
/*
p_delete_theme is a parameter used to define which themes to delete from the temporary table.
It can assume two values:
'ALL' -> Delete All themes for the given SessionId
'ALL_BUT_BASE' -> Delete All themes except the first(Base) theme for the given SessionId.
		  Also delete the themes added for Trade Area Mapping and for the Identify functionality.
'IDENTIFY' -> Delete the point-geometry theme added for the Identify functionality.
'POINT_FEATURE' -> Delete the point-geometry theme added for mapping the Point Feature.
'POINT_FEATURE_AT_LOCATION' -> Delete the point-geometry theme added for mapping the Point Feature at a Location.
*/

IF(p_delete_theme = 'ALL') THEN
    delete from RRS_SITE_TMP where session_id = p_session_id;
ELSIF(p_delete_theme = 'ALL_BUT_BASE') THEN
    delete from RRS_SITE_TMP where session_id = p_session_id
    and ((to_number(theme_id) > 1 and site_id is not null) or (theme_id <> '0' and site_id is null));
ELSIF(p_delete_theme = 'IDENTIFY') THEN
    delete from RRS_SITE_TMP where session_id = p_session_id and theme_id = '-1';
ELSIF(p_delete_theme = 'POINT_FEATURE') THEN
    delete from RRS_SITE_TMP where session_id = p_session_id and theme_id = '0';
ELSIF(p_delete_theme = 'POINT_FEATURE_AT_LOCATION') THEN
    delete from RRS_SITE_TMP where session_id = p_session_id and theme_id = '-2';
END IF;

END CLEAR_TEMP_FOR_MAP;

FUNCTION GET_LOCATION_NAME
(
	p_site_id IN NUMBER
) RETURN VARCHAR2
IS
/*CURSOR c_location_type_code(c_site_id NUMBER) IS
SELECT pn.location_type_lookup_code
  FROM pn_locations_all pn
      ,rrs_sites_b site
 WHERE site.property_location_id = pn.location_id
   AND site.site_id = c_site_id ;

CURSOR c_building(c_site_id NUMBER) IS
SELECT pn.building
  FROM pn_locations_all pn
      ,rrs_sites_b site
 WHERE site.property_location_id = pn.location_id
   AND site.site_id = c_site_id ;

CURSOR c_floor(c_site_id NUMBER) IS
SELECT pn.floor
  FROM pn_locations_all pn
      ,rrs_sites_b site
 WHERE site.property_location_id = pn.location_id
   AND site.site_id = c_site_id ;

CURSOR c_office(c_site_id NUMBER) IS
SELECT pn.office
  FROM pn_locations_all pn
      ,rrs_sites_b site
 WHERE site.property_location_id = pn.location_id
   AND site.site_id = c_site_id ;

l_location_type_lookup_code pn_locations_all.location_type_lookup_code%TYPE ;
l_location_name VARCHAR2(30);

BEGIN
	OPEN c_location_type_code(p_site_id);
	FETCH c_location_type_code INTO l_location_type_lookup_code ;
	CLOSE c_location_type_code ;

	IF l_location_type_lookup_code IN ('BUILDING','LAND') THEN
		OPEN c_building(p_site_id) ;
		FETCH c_building INTO l_location_name ;
		CLOSE c_building ;
	ELSIF l_location_type_lookup_code IN ('FLOOR','PARCEL') THEN
		OPEN c_floor(p_site_id) ;
		FETCH c_floor INTO l_location_name ;
		CLOSE c_floor ;
	ELSIF l_location_type_lookup_code IN ('OFFICE','SECTION') THEN
		OPEN c_office(p_site_id) ;
		FETCH c_office INTO l_location_name ;
		CLOSE c_office ;
	END IF ;
	RETURN l_location_name ;*/
CURSOR c_location_code(c_site_id NUMBER) IS
SELECT pn.location_code
  FROM pn_locations_all pn
      ,rrs_sites_b site
 WHERE site.property_location_id = pn.location_id
   AND site.site_id = c_site_id ;

l_location_code pn_locations_all.location_code%TYPE ;

BEGIN
	OPEN c_location_code(p_site_id);
	FETCH c_location_code INTO l_location_code ;
	CLOSE c_location_code ;
	RETURN l_location_code ;
END GET_LOCATION_NAME;

FUNCTION GET_PROPERTY_NAME
(
	p_location_id IN NUMBER
) RETURN VARCHAR2
IS
CURSOR c_property_name(c_location_id NUMBER) IS
SELECT prop.property_name
  FROM pn_locations_all pn
      ,pn_properties_all prop
 WHERE pn.location_id = c_location_id
   AND prop.property_id = pn.property_id ;

l_property_name pn_properties_all.property_name%type ;

BEGIN
	OPEN c_property_name(p_location_id);
	FETCH c_property_name INTO l_property_name ;
	CLOSE c_property_name ;
	RETURN l_property_name ;
END GET_PROPERTY_NAME;

FUNCTION GET_UOM_COLUMN_PROMPT
(
	p_uom_class IN VARCHAR2
)RETURN VARCHAR2
IS

CURSOR UOM_CURSOR(c_uom_class VARCHAR2) IS
SELECT
	UNIT_OF_MEASURE
FROM
	MTL_UNITS_OF_MEASURE
WHERE
	LANGUAGE = USERENV('LANG')
	and (BASE_UOM_FLAG = 'Y' or
	     exists (select 1 from  MTL_UOM_CONVERSIONS
		     where MTL_UNITS_OF_MEASURE .UOM_CLASS =  MTL_UOM_CONVERSIONS.UOM_CLASS
		     and MTL_UNITS_OF_MEASURE .UNIT_OF_MEASURE =  MTL_UOM_CONVERSIONS.UNIT_OF_MEASURE) )
	and (DISABLE_DATE is null or DISABLE_DATE >= sysdate)
	and UOM_CLASS = c_uom_class
ORDER BY
	BASE_UOM_FLAG DESC;
uom MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;

BEGIN

IF(p_uom_class IS NULL) THEN
	RETURN '';
ELSE
	OPEN UOM_CURSOR(p_uom_class);
	FETCH UOM_CURSOR INTO uom;
	CLOSE UOM_CURSOR;
END IF;

IF(uom IS NULL) THEN
	RETURN '';
ELSE
	RETURN ' (' || uom || ')';
END IF;

END GET_UOM_COLUMN_PROMPT;



PROCEDURE Update_geometry_for_locations
 (p_loc_id IN NUMBER,
  p_lat IN NUMBER,
  p_long IN NUMBER,
  p_status IN VARCHAR2,
  p_geo_source IN VARCHAR2 DEFAULT 'RRS_GOOGLE',
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data  OUT NOCOPY VARCHAR2
 )
 IS
 l_is_invalid_geocode NUMBER := 0; /* Bug 7143445 */
 BEGIN
   x_return_status := 'S';
   x_msg_data := null;
   /* Bug 7143445 check if lat, long = 0,0 */
  IF ((p_lat IS NOT NULL AND p_lat=0 AND p_long IS NOT NULL AND p_long=0 AND p_geo_source = 'RRS_GOOGLE') OR
       (p_lat IS NULL OR p_long IS NULL)) THEN
   	l_is_invalid_geocode := 1;
   END IF;

   /* Bug 7143445 Do not stamp 0,0 for geometry */
   UPDATE hz_locations
   SET
   geometry = decode(l_is_invalid_geocode, 1, NULL,
                     MDSYS.SDO_GEOMETRY(2001,
                                        8307,
                                        SDO_POINT_TYPE(p_long, p_lat, NULL),
                                        NULL,
                                        NULL)),
   geometry_status_code = p_status,
   geometry_source = p_geo_source,
   last_update_date = sysdate,
   last_updated_by = fnd_global.user_id,
   last_update_login = fnd_global.login_id,
   request_id = fnd_global.conc_request_id,
   program_application_id = fnd_global.prog_appl_id,
   program_id = fnd_global.conc_program_id,
   program_update_date = sysdate
   WHERE
   location_id = p_loc_id;

   if sql%rowcount = 0 THEN
     x_return_status := 'E';
     x_msg_count := 1;
     FND_MESSAGE.SET_NAME('RRS','RRS_UPD_LOC_FAILED');
     FND_MESSAGE.SET_TOKEN('LOCATION_ID',p_loc_id);
     x_msg_data := FND_MESSAGE.GET;
   END IF;

 EXCEPTION
   when others then
     x_return_status := 'E';
     x_msg_count := 1;
     x_msg_data := sqlerrm;

 END Update_geometry_for_locations;

 PROCEDURE get_geometry_for_location
 (p_loc_id IN NUMBER,
  x_geo_source OUT NOCOPY VARCHAR2,
  x_null_flag OUT NOCOPY VARCHAR2,
  x_latitude OUT NOCOPY NUMBER,
  x_longitude OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data  OUT NOCOPY VARCHAR2
 )
 IS
 l_is_invalid_geocode NUMBER := 0; /* Bug 7143445 */
 l_default_geosource VARCHAR2(30);
 l_loc_found VARCHAR2(1);
 BEGIN
   x_return_status := 'S';
   x_null_flag := 'F';
   x_msg_data := null;
   x_geo_source := null;
   x_latitude := null;
   x_longitude := null;

   select
   ROUND(HL.geometry.SDO_POINT.X,8) longitude,
   ROUND(HL.geometry.SDO_POINT.Y,8) latitude,
   HL.GEOMETRY_SOURCE
   into
   x_latitude,
   x_longitude,
   x_geo_source
   from hz_locations HL
   where location_id = p_loc_id;

   IF (sql%rowcount = 0) THEN
      x_return_status := 'E';
      x_msg_count := 1;
      FND_MESSAGE.SET_NAME('RRS','RRS_INVALID_OBJ_VALUE');
      FND_MESSAGE.SET_TOKEN('OBJECT_NAME','LOCATION');
      FND_MESSAGE.SET_TOKEN('OBJECT_VALUE',p_loc_id);
      x_msg_data := FND_MESSAGE.GET;
   END IF;

   IF x_latitude IS NULL THEN
      x_null_flag := 'T';
   END IF;

 EXCEPTION
   when others then
     x_return_status := 'E';
     x_msg_count := 1;
     x_msg_data := sqlerrm;

 END get_geometry_for_location;

/* Added for bugfix 8903725 */
PROCEDURE set_geometry_src_for_location
 (p_loc_id IN NUMBER,
  x_geo_source_was_null OUT NOCOPY VARCHAR2,
  x_geo_source_set_value OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data  OUT NOCOPY VARCHAR2
 )
 IS
 l_is_invalid_geocode NUMBER := 0; /* Bug 7143445 */
 l_default_geosource VARCHAR2(30);
 l_curr_geosource VARCHAR2(30);
 BEGIN
   x_return_status := 'S';
   x_msg_data := null;
   x_geo_source_was_null := 'N';

   l_default_geosource := FND_PROFILE.VALUE('RRS_GEOCODE_SRC_PREFERENCE');
   IF (l_default_geosource IS NULL) THEN
   	l_default_geosource := 'RRS_GOOGLE';
   END IF;

   select geometry_source
   into l_curr_geosource
   from hz_locations
   where location_id = p_loc_id;

   IF (sql%rowcount = 0) THEN
      x_return_status := 'E';
      x_msg_count := 1;
      FND_MESSAGE.SET_NAME('RRS','RRS_INVALID_OBJ_VALUE');
      FND_MESSAGE.SET_TOKEN('OBJECT_NAME','LOCATION');
      FND_MESSAGE.SET_TOKEN('OBJECT_VALUE',p_loc_id);
      x_msg_data := FND_MESSAGE.GET;
   ELSE

      UPDATE hz_locations
      SET geometry_source = l_default_geosource
      WHERE location_id = p_loc_id
      AND geometry_source is null;

      if sql%rowcount = 1 THEN
         x_geo_source_was_null := 'Y';
      end if;

   END IF;

   IF (x_geo_source_was_null = 'N') THEN
      x_geo_source_set_value := l_curr_geosource;
   ELSE
      x_geo_source_set_value := l_default_geosource;
   END IF;

 EXCEPTION
   when others then
     x_return_status := 'E';
     x_msg_count := 1;
     x_msg_data := sqlerrm;

 END set_geometry_src_for_location;



	FUNCTION get_ordinate
	(geom IN MDSYS.SDO_GEOMETRY,
	 indx IN NUMBER
	) RETURN NUMBER
 IS
 BEGIN
   if    ( geom.sdo_ordinates is null )     then return null;
   elsif ( geom.sdo_ordinates.count < indx) then return null;
   else  return geom.sdo_ordinates (indx);
   end if;
 END;

 FUNCTION get_address
 (p_loc_id IN NUMBER
 ) RETURN VARCHAR2
 IS

 l_address1    hz_locations.address1%type;
 l_city        hz_locations.city%type;
 l_state       hz_locations.city%type;
 l_postal_code hz_locations.postal_code%type;
 l_country     hz_locations.country%type;
 l_ret         varchar2(500) := null;

 BEGIN

  select  replace(hl.address1,' ','%20'),
          replace(hl.city,' ','%20'),
          replace(hl.state,' ','%20'),
          replace(hl.postal_code,' ','%20'),
          replace(hl.country,' ','%20')
  into    l_address1,
          l_city,
          l_state,
          l_postal_code,
          l_country
  from    hz_locations hl
  where   hl.location_id = p_loc_id;

  IF(l_address1 is not null) THEN
   l_ret := l_address1;
  END IF;

  IF(l_city is not null) THEN
   l_ret := l_ret||'+'||l_city;
  END IF;

  IF(l_state is not null) THEN
   l_ret := l_ret||'+'||l_state;
  END IF;

  IF(l_postal_code is not null) THEN
   l_ret := l_ret||'+'||l_postal_code;
  END IF;

  IF(l_country is not null) THEN
   l_ret := l_ret||'+'||l_country;
  END IF;

  RETURN l_ret;

 EXCEPTION
  when others then
   RETURN l_ret;

 END get_address;

PROCEDURE default_site_numbers
 (p_result_format_usage_id IN NUMBER,
  p_site_number_col_name VARCHAR2,
  p_site_name_col_name VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data  OUT NOCOPY VARCHAR2
 )
 IS

 l_default_seq_num NUMBER;
 l_site_name VARCHAR2(1000);
 l_cursor_sql VARCHAR2(1000);

 TYPE EBI_CURSOR_TYP IS REF CURSOR;
 ebi_cursor EBI_CURSOR_TYP;

 BEGIN
   x_return_status := 'S';
   x_msg_data := null;

	l_cursor_sql := 'SELECT DISTINCT(' || p_site_name_col_name || ') AS SITE_NAME' ||
 		' FROM EGO_BULKLOAD_INTF WHERE RESULTFMT_USAGE_ID =' || TO_CHAR(p_result_format_usage_id) ||
 		' AND ' || p_site_number_col_name || ' IS NULL';

 	OPEN ebi_cursor FOR l_cursor_sql;
	LOOP
		FETCH ebi_cursor INTO l_site_name;
		-- l_default_seq_num := RRS_DEFAULT_SITE_NUMBER_S.NEXTVAL;
		SELECT 	RRS_DEFAULT_SITE_NUMBER_S.NEXTVAL
		INTO	l_default_seq_num
		FROM 	DUAL;

		EXIT WHEN ebi_cursor%NOTFOUND;

		EXECUTE IMMEDIATE
		'UPDATE EGO_BULKLOAD_INTF SET ' || p_site_number_col_name || ' = :1' ||
		' WHERE ' || p_site_name_col_name || ' = :2' ||
		' AND RESULTFMT_USAGE_ID = ' || TO_CHAR(p_result_format_usage_id) ||
		' AND ' || p_site_number_col_name || ' IS NULL'
		USING TO_CHAR(l_default_seq_num), l_site_name;

	END LOOP;
	CLOSE ebi_cursor;

 EXCEPTION
  when others then
     x_return_status := 'E';
     x_msg_data := sqlerrm;

 END default_site_numbers;

Procedure Add_Favorite_objects(P_OBJECT_TYPE IN VARCHAR2,
                               P_OBJECT_ID   IN VARCHAR2,
                               P_OBJECT_NAME IN VARCHAR2,
                               P_USER_ID     IN NUMBER,
                               X_RET_STATUS OUT NOCOPY VARCHAR2)
is
    type t_object_type is table of varchar2(20)  index by binary_integer;
    type t_object_id   is table of Number        index by binary_integer;
    type t_object_name is table of varchar2(300) index by binary_integer;

    v_object_type   t_object_type;
    v_object_id     t_object_id;
    v_object_name   t_object_name;
    obj_index       Number;
    str_index       Number;
    l_obj_type      Varchar2(20);
    l_obj_id        VARCHAR2(20);
    l_obj_name      VARCHAR2(300);
    l_ret_status    VARCHAR2(1);
    l_temp          Number;

begin
    obj_index := 1;
    str_index := 1;
    l_ret_status := 'S';
    FND_MSG_PUB.Delete_Msg(null);
    WHILE str_index <= length(P_OBJECT_TYPE)
    LOOP
        IF ( substr(P_OBJECT_TYPE,str_index,4) = '~@#^') THEN
            v_object_type(obj_index) := l_obj_type;
            obj_index := obj_index + 1;
            l_obj_type := '';
            str_index := str_index + 4;
        ELSE
           l_obj_type := l_obj_type || substr(P_OBJECT_TYPE,str_index,1);
           str_index := str_index + 1;
        END IF;
    END LOOP;
    obj_index := 1;
    str_index := 1;

    WHILE str_index <= length(P_OBJECT_ID)
    LOOP
        IF ( substr(P_OBJECT_ID,str_index,4) = '~@#^') THEN
            v_object_id(obj_index) := to_number(l_obj_id);
            obj_index := obj_index + 1;
            l_obj_id := '';
            str_index := str_index + 4;
        ELSE
           l_obj_id := l_obj_id || substr(P_OBJECT_ID,str_index,1);
           str_index := str_index + 1;
        END IF;
    END LOOP;
    obj_index := 1;
    str_index := 1;
    WHILE str_index <= length(P_OBJECT_NAME)
    LOOP
        IF ( substr(P_OBJECT_NAME,str_index,4) = '~@#^') THEN
           v_object_name(obj_index) := l_obj_name;
            obj_index := obj_index + 1;
            l_obj_name := '';
            str_index := str_index + 4;
        ELSE
           l_obj_name := l_obj_name || substr(P_OBJECT_NAME,str_index,1);
           str_index := str_index + 1;
        END IF;
    END LOOP;

    obj_index := v_object_type.first;
    while obj_index <= v_object_type.last
    LOOP
        BEGIN
            select 1 into l_temp from rrs_user_favorites
            where object_type = v_object_type(obj_index) and
            object_id = v_object_id(obj_index) and
            user_id = P_USER_ID;

            v_object_type.delete(obj_index);
            v_object_id.delete(obj_index);
        EXCEPTION
            WHEN OTHERS THEN
                null;
        END;
        obj_index := v_object_type.next(obj_index);
    END LOOP;

    if l_ret_status = 'S' then
        forall ins_index in v_object_type.first..v_object_type.last
           insert into rrs_user_favorites
           (USER_FAVORITE_ID,
            OBJECT_TYPE,
            OBJECT_ID,
            USER_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN)
           values
           (RRS_FAVORITE_S.nextval,
            v_object_type(ins_index),
            v_object_id(ins_index),
            P_USER_ID,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id);
   end if;

   X_RET_STATUS := l_ret_status;

EXCEPTION
    when others then
        FND_MSG_PUB.Add_Exc_Msg('RRS_SITE_UTILS','Add_Favorite_objects',sqlerrm(sqlcode));
        X_RET_STATUS := 'E';
end  Add_Favorite_objects;



--Bug Fix 8502761: check whether the assigned attribute group has been populated for some site. - jijiao 1/29/2010
Procedure isAGAndClsAssocDeletable
(
	p_application_id	IN 		NUMBER,
	p_classification_code	IN 		VARCHAR2,
	p_attr_group_type	IN 		VARCHAR2,
	p_attr_group_name	IN 		VARCHAR2,
	x_is_ag_deletable	OUT NOCOPY 	VARCHAR2
)IS

l_attr_group_id	NUMBER;
l_num_of_rows	NUMBER;

BEGIN
	SELECT ATTR_GROUP_ID
	  INTO l_attr_group_id
	  FROM EGO_OBJ_ATTR_GRP_ASSOCS_V
	 WHERE APPLICATION_ID = p_application_id
	   AND CLASSIFICATION_CODE = p_classification_code
	   AND ATTR_GROUP_TYPE = p_attr_group_type
	   AND ATTR_GROUP_NAME = p_attr_group_name;

	IF p_attr_group_type = 'RRS_SITEMGMT_GROUP' THEN

		SELECT COUNT(*)
		  INTO l_num_of_rows
		  FROM RRS_SITES_EXT_VL
		 WHERE ATTR_GROUP_ID = l_attr_group_id
		   AND SITE_USE_TYPE_CODE = p_classification_code;

	ELSIF p_attr_group_type = 'RRS_LOCATION_GROUP' THEN

		SELECT COUNT(*)
		  INTO l_num_of_rows
		  FROM RRS_LOCATIONS_EXT_VL
		 WHERE ATTR_GROUP_ID = l_attr_group_id
		   AND COUNTRY = p_classification_code;

	ELSIF p_attr_group_type = 'RRS_TRADE_AREA_GROUP' THEN

		SELECT COUNT(*)
		  INTO l_num_of_rows
		  FROM RRS_TRADE_AREAS_EXT_VL
		 WHERE ATTR_GROUP_ID = l_attr_group_id
		   AND GROUP_ID = p_classification_code;

	ELSIF p_attr_group_type = 'RRS_HIERARCHY_GROUP' THEN

		SELECT COUNT(*)
		  INTO l_num_of_rows
		  FROM RRS_HIERARCHIES_EXT_VL
		 WHERE ATTR_GROUP_ID = l_attr_group_id
		   AND HIERARCHY_PURPOSE_CODE = p_classification_code;

	END IF;

	IF l_num_of_rows = 0 THEN
		x_is_ag_deletable := 'Y';
	ELSE
		x_is_ag_deletable := 'N';
	END IF;

END isAGAndClsAssocDeletable;



END RRS_SITE_UTILS;

/
