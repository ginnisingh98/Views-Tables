--------------------------------------------------------
--  DDL for Package Body CSF_TDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_TDS_PUB" as
/* $Header: CSFPTDSB.pls 120.2.12010000.8 2009/05/15 09:00:36 ppillai noship $ */

   PROCEDURE dbgl (p_msg_data VARCHAR2);

   PROCEDURE put_stream (p_handle IN NUMBER, p_msg_data IN VARCHAR2);

PROCEDURE CACHED_ROUTE_EXISTS
(  l_config_string VARCHAR2,
   l_from_segment_id csf_tds_route_cache.to_segment_id%TYPE,
   l_from_spot csf_tds_route_cache.to_segment_position%TYPE,
   l_from_side csf_tds_route_cache.to_segment_side%TYPE,
   l_to_segment_id csf_tds_route_cache.to_segment_id%TYPE,
   l_to_spot csf_tds_route_cache.to_segment_position%TYPE,
   l_to_side csf_tds_route_cache.to_segment_side%TYPE,
   multiDataSetProfileValue VARCHAR2,
   x_return_status OUT NOCOPY boolean
   )
IS

 return_val boolean;

 route_cache_cursor t_crs;

 route_cache_qry VARCHAR2(1000);

 l_segment_id csf_tds_route_cache.to_segment_id%TYPE;

BEGIN
return_val := false;


route_cache_qry := 'SELECT  distinct  FROM_SEGMENT_ID
                    FROM csf_tds_route_cache'||multiDataSetProfileValue ||'
                     WHERE CONFIG = '''||l_config_string||'''   AND
                     FROM_SEGMENT_ID = '||l_from_segment_id||'   AND
                     FROM_SEGMENT_SIDE = '''|| l_from_side ||'''  AND
                     FROM_SEGMENT_POSITION = '''|| l_from_spot ||'''  AND
                     TO_SEGMENT_ID = '||l_to_segment_id||'  AND
                     TO_SEGMENT_SIDE  = '''||l_to_side || '''  AND
                     TO_SEGMENT_POSITION  = '''||l_to_spot||'''';

l_segment_id := NULL;

 OPEN route_cache_cursor FOR route_cache_qry;
 LOOP
    FETCH route_cache_cursor into l_segment_id;
    IF route_cache_cursor%FOUND AND l_segment_id IS NOT NULL
    THEN
      return_val := true;
    END IF;
    EXIT WHEN route_cache_cursor%notfound;
 END LOOP;
 CLOSE route_cache_cursor;

 x_return_status := return_val;
END CACHED_ROUTE_EXISTS;



PROCEDURE TDS_ROUTES_TO_BE_CALCULATED(query_id IN NUMBER,config_string IN
VARCHAR2, user_id IN NUMBER,status OUT NOCOPY  NUMBER , msg OUT NOCOPY VARCHAR2) IS

  CURSOR QueryWhereClause(qid NUMBER) IS
   SELECT where_clause
   FROM csf_dc_queries_b
   WHERE query_id = qid;

--  CURSOR ResourceAddressCursor IS
--   SELECT DISTINCT  csf_locus_pub.get_locus_segmentid(geometry) AS  segment_id,
--    csf_locus_pub.get_locus_spot(geometry) AS  spot,
--    csf_locus_pub.get_locus_side(geometry) AS  side,
--    csf_locus_pub.get_locus_lat(geometry) AS  lat,
--    csf_locus_pub.get_locus_lon(geometry) AS  lon,
--    csf_locus_pub.get_locus_srid(geometry) AS  srid,
--    tile_id
--   FROM hz_locations loc,
--    csf_tds_segments seg,
--    jtf_terr_rsc_all rsc,
--    jtf_terr_usgs_all usg,
--    jtf_rs_resource_extns extn,
--    hz_party_sites site,
--    per_all_people_f ppl
--   WHERE  usg.source_id = -1002
--    AND rsc.terr_id = usg.terr_id
--    AND rsc.resource_id = extn.resource_id
--    AND extn.source_id = ppl.person_id
--    AND ppl.party_id  = site.party_id
--    AND site.location_id = loc.location_id
--    AND csf_locus_pub.get_locus_segmentid(geometry) = seg.SEGMENT_ID
--    AND geometry IS NOT NULL
--    AND loc.location_id > 0
--    ;

   wClause VARCHAR2(1000);

   task_address_cursor t_crs;
   task_address_cursor_inner t_crs;

   res_address_Cursor  t_crs;
   res_address_Cursor_inner  t_crs;

--   l_location_id hz_locations.location_id%TYPE;
   l_segment_id csf_tds_route_cache.from_segment_id%TYPE;
   l_spot csf_tds_route_cache.from_segment_position%TYPE;
   l_side csf_tds_route_cache.from_segment_side%TYPE;
   l_lat NUMBER;
   l_lon NUMBER;
   l_SRID NUMBER;
   l_tile_id NUMBER;
   l_hr_ctry_code VARCHAR2(10);


--   l_location_id_inner hz_locations.location_id%TYPE;
   l_segment_id_inner csf_tds_route_cache.to_segment_id%TYPE;
   l_spot_inner csf_tds_route_cache.to_segment_position%TYPE;
   l_side_inner csf_tds_route_cache.to_segment_side%TYPE;
   l_lat_inner NUMBER;
   l_lon_inner NUMBER;
   l_SRID_inner NUMBER;
   l_tile_id_inner NUMBER;
   l_hr_ctry_code_inner VARCHAR2(10);

   l_seg_From csf_tds_route_cache.from_segment_id%TYPE;

   task_qry_stmt VARCHAR2(2000);
   res_qry_stmt VARCHAR2(2000);

   config_string_trimmed varchar2 (100);

   distance NUMBER;
   threshhold NUMBER;

   multiDataSetProfileValue VARCHAR2(10);
   x_status boolean;

   multiDataSetProfileEnabled VARCHAR2(2);
   type mdsListType is table of csf_spatial_ctry_mappings.SPATIAL_DATASET%type;
   mdsList mdsListType;
  BEGIN
    status := 1;
    msg := 'SUCCESS';

--   SELECT NVL( TO_NUMBER(fnd_profile.value('CSR_MAX_TRAVEL_DIST_FOR_ESTIMATION')) ,100)
--   ,NVL(fnd_profile.value('CSF_SPATIAL_DATASET_NAME'),'')
--   INTO threshhold, multiDataSetProfileValue
--   FROM dual;
-- Commented for bug 8289413

   SELECT NVL( TO_NUMBER(CSR_SCHEDULER_PUB.GET_SCH_PARAMETER_VALUE('spMaxDistToSkipActual')) ,100)
   ,NVL(fnd_profile.value('CSF_SPATIAL_MULTIDATASET_ENABLED'),'N')
   INTO threshhold, multiDataSetProfileEnabled
   FROM dual;

   IF UPPER(multiDataSetProfileEnabled) = 'N' OR multiDataSetProfileEnabled IS NULL
   THEN
       select '' SPATIAL_DATASET bulk collect into mdsList from dual;
   ELSIF  UPPER(multiDataSetProfileEnabled) = 'Y'
   THEN
      select distinct SPATIAL_DATASET bulk collect into mdsList from csf_spatial_ctry_mappings;
   END IF;

   --Loop though all the data set
   FOR i IN mdsList.first .. mdsList.last loop
    multiDataSetProfileValue := trim(mdsList(i));
    threshhold := threshhold *1000;
    config_string_trimmed := trim(config_string);
      -- Getting the where clause for the taks's query
    OPEN QueryWhereClause(query_id);

    FETCH QueryWhereClause
    INTO wClause;
    CLOSE QueryWhereClause;
    --Query used for resource address
    res_qry_stmt := ' SELECT DISTINCT  csf_locus_pub.get_locus_segmentid(geometry) AS  segment_id,
    csf_locus_pub.get_locus_spot(geometry) AS  spot,
    csf_locus_pub.get_locus_side(geometry) AS  side,
    csf_locus_pub.get_locus_lat(geometry) AS  lat,
    csf_locus_pub.get_locus_lon(geometry) AS  lon,
    csf_locus_pub.get_locus_srid(geometry) AS  srid,
    tile_id,
    loc.country hr_country_code
   FROM hz_locations loc,
    csf_tds_segments'||multiDataSetProfileValue ||' seg,
    jtf_terr_rsc_all rsc,
    jtf_terr_usgs_all usg,
    jtf_rs_resource_extns extn,
    hz_party_sites site,
    per_all_people_f ppl
   WHERE  usg.source_id = -1002
    AND rsc.terr_id = usg.terr_id
    AND rsc.resource_id = extn.resource_id
    AND extn.source_id = ppl.person_id
    AND ppl.party_id  = site.party_id
    AND site.location_id = loc.location_id
    AND csf_locus_pub.get_locus_segmentid(geometry) = seg.SEGMENT_ID
    AND geometry IS NOT NULL
    AND loc.location_id > 0';

       -- Query used for tasks
   task_qry_stmt := 'SELECT  DISTINCT  csf_locus_pub.get_locus_segmentid(geometry) AS   segment_id,
                csf_locus_pub.get_locus_spot(geometry) AS spot,
                csf_locus_pub.get_locus_side(geometry) AS side,
                csf_locus_pub.get_locus_lat(geometry) AS LAT,
                csf_locus_pub.get_locus_lon(geometry) AS LON,
                csf_locus_pub.GET_LOCUS_SRID(geometry) AS SRID,
                tile_id,
                a.country hr_country_code
                FROM hz_locations a,csf_tds_segments'||multiDataSetProfileValue ||'  seg
                WHERE  geometry is not null
                AND  a.location_id > 0
                AND  csf_locus_pub.get_locus_segmentid(geometry) = seg.SEGMENT_ID
                AND a.location_id IN (SELECT location_id
                FROM csf_ct_tasks WHERE ' || wClause || '   )';


    -- Now for all the resource address to task address --
    OPEN task_address_cursor FOR task_qry_stmt;
    LOOP
       FETCH task_address_cursor into  l_segment_id,l_spot,l_side,l_lat, l_lon, l_SRID,l_tile_id, l_hr_ctry_code;
       EXIT WHEN task_address_cursor%notfound;

          --FOR res IN ResourceAddressCursor
          OPEN res_address_cursor FOR res_qry_stmt;
          LOOP
             FETCH res_address_cursor into  l_segment_id_inner,
             l_spot_inner,l_side_inner,l_lat_inner, l_lon_inner, l_SRID_inner,l_tile_id_inner, l_hr_ctry_code_inner;
             EXIT WHEN res_address_cursor%notfound;

             CACHED_ROUTE_EXISTS( config_string_trimmed,l_segment_id_inner,
               l_spot_inner, l_side_inner, l_segment_id , l_spot, l_side,
                multiDataSetProfileValue,x_status);

              IF NOT x_status THEN

               IF l_segment_id <> l_segment_id_inner AND l_SRID = l_SRID_inner
               THEN
                distance := 0;
                GEO_DISTANCE(l_SRID_inner,l_lon_inner,l_lat_inner,l_lon,l_lat,distance);

                IF distance < threshhold
                THEN

                  INSERT INTO csf_tds_route_to_be_calculated
                 (SEGMENT_ID_FROM, SIDE_FROM, SPOT_FROM, SRID_FROM,
                  LATITUDE_FROM, LONGITUDE_FROM, SEGMENT_ID_TO, SIDE_TO,
                  SPOT_TO, SRID_TO, LATITUDE_TO, LONGITUDE_TO, USER_ID,
                  FROM_TILE_ID,  TO_TILE_ID,DATASET_NAME,
                  FROM_HR_CTRY_CODE, TO_HR_CTRY_CODE)
                  VALUES (l_segment_id_inner, -- SEGMENT_ID_FROM
                  l_side_inner, --SIDE_FROM
                  l_spot_inner, --SPOT_FROM
                  l_SRID_inner, --SRID_FROM
                  l_lat_inner,  --LATITUDE_FROM
                  l_lon_inner,  --LONGITUDE_FROM
                  l_segment_id, --SEGMENT_ID_TO
                  l_side, -- SIDE_TO
                  l_spot, -- SPOT_TO
                  l_SRID, --SRID_TO
                  l_lat, --LATITUDE_TO
                  l_lon, -- LONGITUDE_TO
                  user_id,  -- USER_ID
                  l_tile_id_inner, -- FROM_SEGMENT_TILE_ID
                  l_tile_id, -- TO_SEGMENT_TILE_ID
                  multiDataSetProfileValue,--DATASET_NAME
                  l_hr_ctry_code_inner,
                  l_hr_ctry_code
                  );

                  END IF;
               END IF;
            END IF;
          END LOOP;
          CLOSE res_address_cursor;
    END LOOP;
    CLOSE task_address_cursor;
    COMMIT;

        -- Now for all the task address to other task address --
    OPEN task_address_cursor FOR task_qry_stmt;
    LOOP
      FETCH task_address_cursor into  l_segment_id,l_spot,l_side,l_lat, l_lon, l_SRID,l_tile_id, l_hr_ctry_code;
      EXIT WHEN task_address_cursor%notfound;

      OPEN task_address_cursor_inner FOR task_qry_stmt;
      LOOP
         FETCH task_address_cursor_inner into  l_segment_id_inner,
         l_spot_inner,l_side_inner,l_lat_inner, l_lon_inner, l_SRID_inner,l_tile_id_inner, l_hr_ctry_code_inner;
         EXIT WHEN task_address_cursor_inner%notfound;

        CACHED_ROUTE_EXISTS( config_string_trimmed,l_segment_id , l_spot, l_side,
           l_segment_id_inner,l_spot_inner, l_side_inner, multiDataSetProfileValue
           ,x_status);

       IF NOT x_status
       THEN

         IF l_segment_id <> l_segment_id_inner AND l_SRID = l_SRID_inner
         THEN
           -- IF l_seg_From IS NULL
           --  THEN
            distance := 0;
            GEO_DISTANCE(l_SRID,l_lon,l_lat,l_lon_inner,l_lat_inner,distance);

            IF distance < threshhold
            THEN

              INSERT INTO csf_tds_route_to_be_calculated
               (SEGMENT_ID_FROM, SIDE_FROM, SPOT_FROM, SRID_FROM,
                LATITUDE_FROM, LONGITUDE_FROM, SEGMENT_ID_TO, SIDE_TO,
                SPOT_TO, SRID_TO, LATITUDE_TO, LONGITUDE_TO, USER_ID,
                FROM_TILE_ID,  TO_TILE_ID,DATASET_NAME,
                FROM_HR_CTRY_CODE, TO_HR_CTRY_CODE)
                VALUES (l_segment_id, -- SEGMENT_ID_FROM
                l_side, --SIDE_FROM
                l_spot, --SPOT_FROM
                l_SRID, --SRID_FROM
                l_lat,  --LATITUDE_FROM
                l_lon,  --LONGITUDE_FROM
                l_segment_id_inner, --SEGMENT_ID_TO
                l_side_inner, -- SIDE_TO
                l_spot_inner, -- SPOT_TO
                l_SRID_inner, --SRID_TO
                l_lat_inner, --LATITUDE_TO
                l_lon_inner, -- LONGITUDE_TO
                user_id,  -- USER_ID
                l_tile_id, -- FROM_SEGMENT_TILE_ID
                l_tile_id_inner, -- TO_SEGMENT_TILE_ID
                multiDataSetProfileValue,--DATASET_NAME
                l_hr_ctry_code,
                l_hr_ctry_code_inner
                );

            END IF;
          END IF;
         END IF;
      END LOOP;
      CLOSE task_address_cursor_inner;

    END LOOP;
    CLOSE task_address_cursor;
END LOOP;  --End loop for MDS

 COMMIT;
 EXCEPTION
 WHEN OTHERS THEN
 status := 0;
 msg := sqlerrm;
 ROLLBACK;

END TDS_ROUTES_TO_BE_CALCULATED;

PROCEDURE GEO_DISTANCE (srId IN NUMBER,x1 IN NUMBER, y1 IN NUMBER,
                x2 IN NUMBER,y2 IN NUMBER , result OUT NOCOPY NUMBER) IS

EARTH_RADIUS NUMBER;
northDist NUMBER;
eastDist NUMBER;
PI NUMBER;
BEGIN


    IF srId <>  8307
    THEN
       result := SQRT( POWER((x1 - x2),2)+POWER((y1 - y2),2));

    ELSE
       EARTH_RADIUS := 6378137;
       PI := 3.14159265358979323846;

       northDist :=  (((y2 * PI )/ 180.0) - ((y1 * PI) / 180.0)) *
                EARTH_RADIUS;

       eastDist :=   (((x2 * PI )/ 180.0) - ((x1 * PI) / 180.0)) *
                 COS(((y2 * PI) / 180.0)) * EARTH_RADIUS;

       result := SQRT(POWER(northDist,2) + POWER (eastDist,2));


    END IF;


END GEO_DISTANCE;

PROCEDURE PURGE_UNUSED_CACHE (
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2,
      p_start_date   IN              VARCHAR2 DEFAULT NULL,
      p_end_date     IN              VARCHAR2 DEFAULT NULL
)
IS

   l_api_name      CONSTANT VARCHAR2 (30)      := 'PURGE_UNUSED_CACHE';
      l_api_version   CONSTANT NUMBER             := 1.0;
      -- predefined error codes for concurrent programs
      l_rc_succ       CONSTANT NUMBER             := 0;
      l_rc_warn       CONSTANT NUMBER             := 1;
      l_rc_err        CONSTANT NUMBER             := 2;
      -- predefined error buffer output strings (replaced by translated messages)
      l_msg_succ               VARCHAR2 (80);
      l_msg_warn               VARCHAR2 (80);
      l_msg_err                VARCHAR2 (80);
      --
      -- the date range
      --
      l_start_date             DATE;
      l_end_date               DATE;

      l_fmt                    VARCHAR2 (100);
      l_msg_data               VARCHAR2 (2000);

      l_del_qry      VARCHAR2(500);

      multiDataSetProfileValue VARCHAR2(10);


BEGIN

      SELECT NVL(fnd_profile.value('CSF_SPATIAL_DATASET_NAME'),'')
      INTO multiDataSetProfileValue
      FROM dual;

      IF UPPER(multiDataSetProfileValue) = 'NONE'
      THEN
         multiDataSetProfileValue :='';
      END IF;

      fnd_msg_pub.initialize;
      -- get termination messages
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_SUCC');
      l_msg_succ := fnd_message.get;
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_WARN');
      l_msg_warn := fnd_message.get;
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_ERR');
      l_msg_err := fnd_message.get;
      -- Initialize API return status to success
      -- API body

      fnd_message.set_name ('CSF', 'CSF_TDS_PUB');
      l_msg_data := fnd_message.get;
      put_stream (g_output, l_msg_data);

            -- start date defaults to today (truncated)
      -- later converted back to server timezone
      -- e.g. client timezone is CET (GMT+1)
      --      server timezone is PST (GMT-8)
      --      If it is 6-Aug 06:00 for the client, then it is 5-Aug 21:00 for the
      --      server, and trunc(sysdate) will give 5-Aug instead of 6-Aug.  Hence
      --      we need to convert to client timezone before truncating.
      --      When the parameter *is* specified, in the same case it will already
      --      read 6-aug-2003.
      --
      IF p_start_date IS NULL
      THEN
         l_start_date :=
                     TRUNC (csf_timezones_pvt.date_to_client_tz_date (SYSDATE - 14));
         -- convert to server timezone
         l_start_date :=
                        csf_timezones_pvt.date_to_server_tz_date (l_start_date);
      ELSE
         -- all fnd_date converts to server timezone so need for conversion
         l_start_date := fnd_date.canonical_to_date (p_start_date);
      END IF;

      --
      -- end date defaults to same day as start date (also truncated)
      --
      IF p_end_date IS NULL
      THEN
         IF p_start_date IS NULL
         THEN
         l_end_date := l_start_date - 7;
         ELSE
         l_end_date := l_start_date + 1;
         END IF;
         -- all fnd_date converts to server timezone so need for conversion
         l_end_date := csf_timezones_pvt.date_to_server_tz_date (l_end_date);

      ELSE
         l_end_date := fnd_date.canonical_to_date (p_end_date);
      END IF;

      --
      -- get date format
      l_fmt := fnd_profile.VALUE ('ICX_DATE_FORMAT_MASK');

      IF l_fmt IS NULL
      THEN
         l_fmt := 'dd-MON-yyyy';
      END IF;

      --
      -- feedback the date range
      fnd_message.set_name ('CSF', 'CSF_AUTO_COMMIT_DATE_RANGE');
      fnd_message.set_token ('P_START_DATE', TO_CHAR (l_start_date, l_fmt));
      fnd_message.set_token ('P_END_DATE', TO_CHAR (l_end_date, l_fmt));
      put_stream (g_output, fnd_message.get);
      --
      -- finally convert the date range to server timezone before processing
      --
      l_start_date := csf_timezones_pvt.date_to_server_tz_date (l_start_date);
      l_end_date := csf_timezones_pvt.date_to_server_tz_date (l_end_date);

       l_del_qry := 'DELETE FROM CSF_TDS_ROUTE_CACHE'||multiDataSetProfileValue
      ||'  WHERE HITCOUNT = 0
           AND CREATION_DATE >= :1
           AND CREATION_DATE <= :2';

      EXECUTE IMMEDIATE l_del_qry
      USING l_start_date,l_end_date;

      COMMIT;

      retcode := l_rc_succ;
      errbuf := l_msg_succ;


       put_stream (g_log, l_msg_succ);
       put_stream (g_output, l_msg_succ);

       fnd_message.set_name ('CSF', 'CSF_TDS_PUB_DEL_SCC');
       l_msg_data := fnd_message.get;
       put_stream (g_log, l_msg_data);



EXCEPTION
WHEN OTHERS
THEN
    retcode := l_rc_err;
    errbuf := l_msg_err;

     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
     THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
     END IF;

     put_stream (SQLCODE, SQLERRM);
     dbms_output.put_line(SQLCODE|| SQLERRM);

END PURGE_UNUSED_CACHE;


-- logging procedures

PROCEDURE put_stream (p_handle IN NUMBER, p_msg_data IN VARCHAR2)
   IS
   BEGIN
      IF p_handle = 0
      THEN
         dbgl (p_msg_data);
      ELSIF p_handle = -1
      THEN
         IF g_debug
         THEN
            dbgl (p_msg_data);
         END IF;
      ELSE
         fnd_file.put_line (p_handle, p_msg_data);
      END IF;
 END put_stream;


PROCEDURE dbgl (p_msg_data VARCHAR2)
   IS
      i       PLS_INTEGER;
      l_msg   VARCHAR2 (300);
   BEGIN
      i := 1;

      LOOP
         l_msg := SUBSTR (p_msg_data, i, 255);
         EXIT WHEN l_msg IS NULL;

         EXECUTE IMMEDIATE g_debug_p
                     USING l_msg;

         i := i + 255;
      END LOOP;
 END dbgl;


end CSF_TDS_PUB;

/
