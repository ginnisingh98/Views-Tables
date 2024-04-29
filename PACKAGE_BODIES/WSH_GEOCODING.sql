--------------------------------------------------------
--  DDL for Package Body WSH_GEOCODING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_GEOCODING" AS
/*$Header: WSHGEOCB.pls 120.2 2006/09/06 06:27:30 skattama noship $*/

/*======================================================================+
 | PROCEDURE                                                            |
 |              Get_Lat_Long_and_TimeZone                               |
 |                                                                      |
 | DESCRIPTION                                                          |
 |              Get Lat, Long, Geometry and Timezone code given the     |
 |              address element.                                        |
 |                                                                      |
 |                                                                      |
 | ARGUMENTS  : IN:                                                     |
 |                    p_api_version                                     |
 |                    p_init_msg_list                                   |
 |              OUT:                                                    |
 |                    x_msg_count                                       |
 |                    x_msg_data                                        |
 |                    x_return_status                                   |
 |          IN/ OUT:                                                    |
 |                    l_location                                        |
 |                                                                      |
 |  NOTES:                                                              |
 |     The following hierarchy is used to get the latitude, longitude,  |
 |     timezone code and geometry for a location                        |
 |          1. City and Zip code                                        |
 |          2. Zip code                                                 |
 |          3. City and County                                          |
 |          4. City and State                                           |
 |          5. County and State                                         |
 |          6. State                                                    |
 |                                                                      |
 | MODIFICATION HISTORY                                                 |
 |     jnhuang -  Mar 10, 2003                                          |
 |              Initial creation                                        |
 |     musriniv - Aug 1, 2003                                           |
 |              Modified API to use WSH_LOCATIONS RECORD type           |
 |     musriniv -  Sep 20, 2003                                         |
 |              Modified based on table definition from NavTech         |
 |                                                                      |
 +---------------------------------------------------------------------*/

G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_GEOCODING';

Procedure Get_Lat_Long_and_TimeZone(p_api_version IN NUMBER
, p_init_msg_list IN VARCHAR2 default fnd_api.g_false
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY VARCHAR2
, x_msg_data OUT NOCOPY VARCHAR2
, l_location IN OUT NOCOPY WSH_LOCATIONS_PKG.LOCATION_REC_TYPE
) is

  x_latitude                  NUMBER;
  x_longitude                 NUMBER;
  x_dst_flag                  VARCHAR2(1);
  x_gmt_offset                NUMBER;
  x_begin_dst_month           VARCHAR2(3);
  x_begin_dst_day             NUMBER;
  x_begin_dst_week_of_month   NUMBER;
  x_begin_dst_day_of_week     NUMBER;
  x_begin_dst_hour            NUMBER;
  x_end_dst_month             VARCHAR2(3);
  x_end_dst_day               NUMBER;
  x_end_dst_week_of_month     NUMBER;
  x_end_dst_day_of_week       NUMBER;
  x_end_dst_hour              NUMBER;
  x_timezone_id               NUMBER;
  x_timezone_name             VARCHAR2(50);
  x_timezone_code             VARCHAR2(50);
  x_geometry                  MDSYS.SDO_GEOMETRY;
  x_record_found              BOOLEAN := FALSE;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Lat_Long_and_TimeZone';

  p_SqlErrM                   VARCHAR2(2400);

BEGIN

   x_return_status := NULL;
   x_msg_count := NULL;
   x_msg_data := NULL;

  --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'WSH_LOCATION_ID',l_location.WSH_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'LOCATION_SOURCE_CODE',l_location.LOCATION_SOURCE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'COUNTRY',l_location.COUNTRY);
       WSH_DEBUG_SV.log(l_module_name,'PROVINCE',l_location.PROVINCE);
       WSH_DEBUG_SV.log(l_module_name,'STATE',l_location.STATE);
       WSH_DEBUG_SV.log(l_module_name,'COUNTY',l_location.COUNTY);
       WSH_DEBUG_SV.log(l_module_name,'CITY',l_location.CITY);
       WSH_DEBUG_SV.log(l_module_name,'POSTAL_CODE',l_location.POSTAL_CODE);
       WSH_DEBUG_SV.log(l_module_name,'LATITUDE',l_location.LATITUDE);
       WSH_DEBUG_SV.log(l_module_name,'LONGITUDE',l_location.LONGITUDE);
       WSH_DEBUG_SV.log(l_module_name,'TIMEZONE_CODE',l_location.TIMEZONE_CODE);
   END IF;

   IF (l_location.postal_code IS NOT NULL) THEN

       IF (l_location.city IS NOT NULL) THEN
          BEGIN
               x_record_found := TRUE;


               SELECT trunc(c.zip_centroid.sdo_point.y, 5),
                      trunc(c.zip_centroid.sdo_point.x, 5),
                      c.dst_indicator, c.gmt_offset,
                      --to_char( c.dst_start_date, 'MM'),
                      to_char( to_number( to_char( c.dst_start_date, 'MM') ) ),
                      to_number( to_char(c.dst_start_date, 'DD') ),
                      to_number( to_char(c.dst_start_date, 'W') ),
                      to_number( to_char(c.dst_start_date, 'D') ),
                      to_number( to_char(c.dst_start_date, 'HH24') ),
                      to_char( c.dst_end_date, 'MM'),
                      to_number( to_char(c.dst_end_date, 'DD') ),
                      to_number( to_char(c.dst_end_date, 'W') ),
                      to_number( to_char(c.dst_end_date, 'D') ),
                      to_number( to_char(c.dst_end_date, 'HH24') ),
                      c.zip_centroid
               INTO   x_latitude, x_longitude, x_dst_flag,
                      x_gmt_offset, x_begin_dst_month,
                      x_begin_dst_day, x_begin_dst_week_of_month,
                      x_begin_dst_day_of_week, x_begin_dst_hour,
                      x_end_dst_month, x_end_dst_day,
                      x_end_dst_week_of_month, x_end_dst_day_of_week,
                      x_end_dst_hour, x_geometry
               FROM   wsh_location_data_ext c
               WHERE  c.ZIP_CODE = upper(l_location.postal_code) AND
                      c.CITY = upper(l_location.city);



          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_record_found := FALSE;
          END;

       END IF;
       IF  ( (l_location.city IS NULL) OR (NOT x_record_found ) ) THEN
       --ELSIF  ( (l_location.city IS NULL) OR (NOT x_record_found ) ) THEN
          BEGIN
               x_record_found := TRUE;


               SELECT trunc(c.zip_centroid.sdo_point.y, 5),
                      trunc(c.zip_centroid.sdo_point.x, 5),
                      c.dst_indicator, c.gmt_offset,
                      --to_char( c.dst_start_date, 'MM'),
                      to_char( to_number(to_char(c.dst_start_date, 'MM') ) ),
                      to_number( to_char(c.dst_start_date, 'DD') ),
                      to_number( to_char(c.dst_start_date, 'W') ),
                      to_number( to_char(c.dst_start_date, 'D') ),
                      to_number( to_char(c.dst_start_date, 'HH24') ),
                      to_char( c.dst_end_date, 'MM'),
                      to_number( to_char(c.dst_end_date, 'DD') ),
                      to_number( to_char(c.dst_end_date, 'W') ),
                      to_number( to_char(c.dst_end_date, 'D') ),
                      to_number( to_char(c.dst_end_date, 'HH24') ),
                      c.zip_centroid
               INTO   x_latitude, x_longitude, x_dst_flag,
                      x_gmt_offset, x_begin_dst_month,
                      x_begin_dst_day, x_begin_dst_week_of_month,
                      x_begin_dst_day_of_week, x_begin_dst_hour,
                      x_end_dst_month, x_end_dst_day,
                      x_end_dst_week_of_month, x_end_dst_day_of_week,
                      x_end_dst_hour, x_geometry
               FROM   wsh_location_data_ext c
               WHERE  c.ZIP_CODE = upper(l_location.postal_code);

          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_record_found := FALSE;
          END;

       END IF;

   END IF;
   IF ( (l_location.postal_code IS NULL) AND (l_location.city IS NOT NULL) AND (NOT x_record_found ) ) THEN
   --ELSIF ( (l_location.city IS NOT NULL) AND (NOT x_record_found ) ) THEN

      IF (l_location.county IS NOT NULL) THEN
          BEGIN
               x_record_found := TRUE;

               -- We use AVG of latitude and longitude here since
               -- there will be multiple entries in NavTech for a
               -- city/county combination. The average will get the
               -- centroid


               SELECT trunc(AVG(c.zip_centroid.sdo_point.y), 5),
                      trunc(AVG(c.zip_centroid.sdo_point.x), 5),
                      MAX(c.dst_indicator), MAX(c.gmt_offset),
                      --MAX( to_char( c.dst_start_date, 'MM') ),
                      MAX( to_char( to_number( to_char( c.dst_start_date, 'MM') ) ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'DD') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'W') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'D') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'HH24') ) ),
                      MAX( to_char( c.dst_end_date, 'MM') ),
                      MAX( to_number( to_char(c.dst_end_date, 'DD') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'W') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'D') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'HH24') ) )
               INTO   x_latitude, x_longitude, x_dst_flag,
                      x_gmt_offset, x_begin_dst_month,
                      x_begin_dst_day, x_begin_dst_week_of_month,
                      x_begin_dst_day_of_week, x_begin_dst_hour,
                      x_end_dst_month, x_end_dst_day,
                      x_end_dst_week_of_month, x_end_dst_day_of_week,
                      x_end_dst_hour
               FROM   wsh_location_data_ext c
               WHERE  c.CITY = upper(l_location.city) AND
                      c.COUNTY = upper(l_location.county);

          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_record_found := FALSE;
          END;

      END IF;
      --ELSIF ( (l_location.county IS NULL AND l_location.state IS NOT NULL) OR
      IF ( (l_location.county IS NULL AND l_location.state IS NOT NULL) OR
              (NOT x_record_found ) ) THEN
          BEGIN
               x_record_found := TRUE;

               -- We use AVG of latitude and longitude here since
               -- there will be multiple entries in NavTech for a
               -- city/state combination. The average will get the
               -- centroid


               SELECT trunc(AVG(c.zip_centroid.sdo_point.y), 5),
                      trunc(AVG(c.zip_centroid.sdo_point.x), 5),
                      MAX(c.dst_indicator), MAX(c.gmt_offset),
                      --MAX( to_char( c.dst_start_date, 'MM') ),
                      MAX( to_char( to_number( to_char( c.dst_start_date, 'MM') ) ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'DD') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'W') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'D') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'HH24') ) ),
                      MAX( to_char( c.dst_end_date, 'MM') ),
                      MAX( to_number( to_char(c.dst_end_date, 'DD') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'W') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'D') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'HH24') ) )
               INTO   x_latitude, x_longitude, x_dst_flag,
                      x_gmt_offset, x_begin_dst_month,
                      x_begin_dst_day, x_begin_dst_week_of_month,
                      x_begin_dst_day_of_week, x_begin_dst_hour,
                      x_end_dst_month, x_end_dst_day,
                      x_end_dst_week_of_month, x_end_dst_day_of_week,
                      x_end_dst_hour
               FROM   wsh_location_data_ext c
               WHERE  c.CITY = upper(l_location.city) AND
                      c.STATE = upper(l_location.state);

          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_record_found := FALSE;
          END;

      END IF;

   END IF;
   --ELSIF ( (l_location.state IS NOT NULL) AND (NOT x_record_found ) ) THEN
   IF ( (l_location.postal_code IS NULL) AND (l_location.city IS NULL) AND (l_location.state IS NOT NULL) AND (NOT x_record_found ) ) THEN

      IF (l_location.county IS NOT NULL) THEN
          BEGIN
               x_record_found := TRUE;

               -- We use AVG of latitude and longitude here since
               -- there will be multiple entries in NavTech for a
               -- county/state combination. The average will get the
               -- centroid


               SELECT trunc(AVG(c.zip_centroid.sdo_point.y), 5),
                      trunc(AVG(c.zip_centroid.sdo_point.x), 5),
                      MAX(c.dst_indicator), MAX(c.gmt_offset),
                      --MAX( to_char( c.dst_start_date, 'MM') ),
                      MAX( to_char( to_number( to_char( c.dst_start_date, 'MM') ) ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'DD') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'W') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'D') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'HH24') ) ),
                      MAX( to_char( c.dst_end_date, 'MM') ),
                      MAX( to_number( to_char(c.dst_end_date, 'DD') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'W') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'D') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'HH24') ) )
               INTO   x_latitude, x_longitude, x_dst_flag,
                      x_gmt_offset, x_begin_dst_month,
                      x_begin_dst_day, x_begin_dst_week_of_month,
                      x_begin_dst_day_of_week, x_begin_dst_hour,
                      x_end_dst_month, x_end_dst_day,
                      x_end_dst_week_of_month, x_end_dst_day_of_week,
                      x_end_dst_hour
               FROM   wsh_location_data_ext c
               WHERE  c.STATE = upper(l_location.state) AND
                      c.COUNTY = upper(l_location.county);

          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_record_found := FALSE;
          END;

      END IF;
      --ELSIF ( (l_location.county IS NULL) OR (NOT x_record_found) ) THEN
      IF ( (l_location.county IS NULL) OR (NOT x_record_found) ) THEN
          BEGIN
               x_record_found := TRUE;

               -- We use AVG of latitude and longitude here since
               -- there will be multiple entries in NavTech for a
               -- state. The average will get the centroid


               SELECT trunc(AVG(c.zip_centroid.sdo_point.y), 5),
                      trunc(AVG(c.zip_centroid.sdo_point.x), 5),
                      MAX(c.dst_indicator), MAX(c.gmt_offset),
                      --MAX( to_char( c.dst_start_date, 'MM') ),
                      MAX( to_char( to_number( to_char( c.dst_start_date, 'MM') ) ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'DD') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'W') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'D') ) ),
                      MAX( to_number( to_char(c.dst_start_date, 'HH24') ) ),
                      MAX( to_char( c.dst_end_date, 'MM') ),
                      MAX( to_number( to_char(c.dst_end_date, 'DD') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'W') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'D') ) ),
                      MAX( to_number( to_char(c.dst_end_date, 'HH24') ) )
               INTO   x_latitude, x_longitude, x_dst_flag,
                      x_gmt_offset, x_begin_dst_month,
                      x_begin_dst_day, x_begin_dst_week_of_month,
                      x_begin_dst_day_of_week, x_begin_dst_hour,
                      x_end_dst_month, x_end_dst_day,
                      x_end_dst_week_of_month, x_end_dst_day_of_week,
                      x_end_dst_hour
               FROM   wsh_location_data_ext c
               WHERE  c.STATE = upper(l_location.state);

          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_record_found := FALSE;
          END;

      END IF;

   END IF;


   IF (x_record_found) THEN

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Calling program unit HZ_TIMEZONE_PUB.Get_Primary_Zone');
      END IF;

      /* Following workaround is because of non availability of NAVTECH data yet */
      x_begin_dst_hour := 2;
      x_end_dst_hour := 2;

      /* Following is a workaround untill HZ fixes their API, data */
      x_begin_dst_week_of_month := 1;
      x_end_dst_week_of_month := -1;
      -- Bug 5490063. Added below IF condition. For invalid locations or location with no ext setup all the below parameters would be null
      -- So need not call HZ_TIMEZONE_PUB.get_primary_zone
       IF(
          (x_gmt_offset IS NOT NULL) OR (x_dst_flag IS NOT NULL) OR (x_begin_dst_day IS NOT NULL) OR
          (x_begin_dst_day_of_week IS NOT NULL) OR (x_end_dst_month IS NOT NULL) OR (x_end_dst_day_of_week IS NOT NULL)
       ) THEN
      HZ_TIMEZONE_PUB.Get_Primary_Zone (
                p_api_version,
                p_init_msg_list,
                x_gmt_offset,
                x_dst_flag,
                x_begin_dst_month,
                --x_begin_dst_day,
                null,
                x_begin_dst_week_of_month,
                x_begin_dst_day_of_week,
                x_begin_dst_hour,
                x_end_dst_month,
                --x_end_dst_day,
                null,
                x_end_dst_week_of_month,
                x_end_dst_day_of_week,
                x_end_dst_hour,
                x_timezone_id,
                x_timezone_name,
                x_timezone_code,
                x_return_status,
                x_msg_count,
                x_msg_data );
      ELSE
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'No record found in wsh_location_data_ext');
        END IF;
      END IF;
      l_location.latitude := x_latitude;
      l_location.longitude := x_longitude;
      l_location.timezone_code := x_timezone_code;
      l_location.geometry := x_geometry;
      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'After calling HZ API ');
       WSH_DEBUG_SV.log(l_module_name,'latitude : ' || l_location.latitude);
       WSH_DEBUG_SV.log(l_module_name,'longitude : ' || l_location.longitude);
       WSH_DEBUG_SV.log(l_module_name,'timezone_code : ' || l_location.timezone_code);
      END IF;

   ELSE

      IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'No record found in wsh_location_data_ext');
      END IF;

   END IF;

   IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
   END IF;

   EXCEPTION
        WHEN NO_DATA_FOUND THEN
              p_SqlErrM := sqlerrm||'(Could not find entry for Location)';
              IF l_debug_on THEN
                 WSH_DEBUG_SV.pop(l_module_name);
              END IF;

END Get_Lat_Long_and_TimeZone;


END WSH_GEOCODING;


/
