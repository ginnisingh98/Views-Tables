--------------------------------------------------------
--  DDL for Package Body HRI_OPL_GEO_LOCHR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_GEO_LOCHR" AS
/* $Header: hripglh.pkb 120.8 2006/10/11 15:34:48 jtitmas noship $ */
--
-- Holds the range for which the collection is to be run.
--
g_start_date                  DATE;
g_end_date                    DATE;
g_full_refresh                VARCHAR2(10);
--
-- The HRI schema
--
g_schema                      VARCHAR2(400);
--
-- 115.15 4278978
-- created as globals as require these in each collection procedure
-- user calling the load proces used in who columnc
g_user_id                     NUMBER  DEFAULT -1;
-- Start time of load process used in who columns
g_current_time                DATE    DEFAULT SYSDATE;
--
-- General purpose sql string buffer
--  saves having to re-declare in each local proc
g_sql_stmt                    VARCHAR2(2000);
--
-- Bug 4105868: Global to store msg_sub_group
--
g_msg_sub_group               VARCHAR2(400) := '';
--
-- Global DBI collection start date initialization
--
g_dbi_collection_start_date DATE := TRUNC(TO_DATE(fnd_profile.value
                                        ('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY'));
--
-- CONSTANTS
-- =========
--
-- @@ Code specific to this view/table below
-- @@ in the call to hri_bpl_conc_log.get_last_collect_to_date
-- @@ change param1/2 to be the concurrent program short name,
-- @@ and the target table name respectively.
--
-- 115.15 4278978
-- New tables
-- changed data types to constants from defaults
g_target_lochr_table          CONSTANT VARCHAR2(30) := 'HRI_CS_GEO_LOCHR_CT';
g_target_region_table         CONSTANT VARCHAR2(30) := 'HRI_CS_GEO_REGION_CT';
g_target_country_table        CONSTANT VARCHAR2(30) := 'HRI_CS_GEO_COUNTRY_CT';
--
g_cncrnt_prgrm_shrtnm         CONSTANT VARCHAR2(30) := 'HRIGLOCHR';
--
-- @@ Code specific to this view/table below ENDS
-- constants that hold the value that indicates to full refresh or not.
--
g_is_full_refresh    VARCHAR2(5) DEFAULT 'Y';
g_not_full_refresh   VARCHAR2(5) DEFAULT 'N';
--
-- -------------------------------------------------------------------------
-- Inserts row into concurrent program log when the g_conc_request_flag has
-- been set to TRUE, otherwise does nothing
-- -------------------------------------------------------------------------
--
PROCEDURE output(p_text  VARCHAR2) IS
--
BEGIN
  --
  -- Bug 4105868: Global to store msg_sub_group
  --
  HRI_BPL_CONC_LOG.output(p_text);
  --
END output;
--
-- -------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -------------------------------------------------------------------------
--
PROCEDURE dbg(p_text  VARCHAR2) IS
--
BEGIN
  --
  -- Bug 4105868: Collection Diagnostics
  --
  HRI_BPL_CONC_LOG.dbg(p_text);
  --
END dbg;
--
-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -----------------------------------------------------------------------------
--
PROCEDURE dbg_time(p_text  VARCHAR2) IS
--
BEGIN
  --
  -- Bug 4105868: Collection Diagnostics
  --
  dbg(' *TIME* :'|| to_char(SYSDATE, 'HH24:MI:SS') ||' -> '||p_text);
  --
END dbg_time;
--
-- -----------------------------------------------------------------------------
-- 3601662
-- Runs given sql statement dynamically without raising an error
-- -----------------------------------------------------------------------------
--
PROCEDURE run_sql_stmt_noerr(p_sql_stmt   VARCHAR2) IS
--
BEGIN
  --
  dbg('Commencing -> run_sql_stmt_noerr');
  --
  EXECUTE IMMEDIATE p_sql_stmt;
  --
  dbg('Exiting -> run_sql_stmt_noerr');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    dbg('Error running sql:');
    output(SUBSTR(p_sql_stmt,1,230));
    --
    -- Bug 4105868: Collection Diagnostic Call
    --
    hri_bpl_conc_log.log_process_info
            (p_package_name      => 'HRI_OPL_GEO_LOCHR'
            ,p_msg_type          => 'WARNING'
            ,p_msg_group         => 'GEOGRAPHY'
            ,p_msg_sub_group     => 'RUN_SQL_STMT_NOERR'
            ,p_sql_err_code      => SQLCODE
            ,p_note              => SUBSTR(p_sql_stmt,1, 3900));
    --
END run_sql_stmt_noerr;
--
-- -----------------------------------------------------------------------------
-- Checks if the Target table is Empty
-- -----------------------------------------------------------------------------
--
FUNCTION Target_table_is_Empty RETURN BOOLEAN IS
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ Change the table in the FROM clause below to be the same as  your
  -- @@ target table.
  --
  -- Bug 2834228 added rownum condition to stop FTS
  --
  CURSOR csr_recs_exist IS
  SELECT 'x'
  FROM   hri_cs_geo_lochr_ct
  WHERE  rownum < 2;
  --
  -- @@ Code specific to this view/table ENDS
  --
  l_exists_chr    VARCHAR2(1);
  l_exists        BOOLEAN;
  --
BEGIN
  --
  dbg('Commencing -> Target_table_is_Empty');
  --
  OPEN csr_recs_exist;
  --
  FETCH csr_recs_exist INTO l_exists_chr;
  --
  IF (csr_recs_exist%NOTFOUND) THEN
    --
    l_exists := TRUE;
    --
   dbg('no data in table hri_cs_geo_lochr_ct');
    --
  ELSE
    --
    l_exists := FALSE;
    --
    dbg('data exists in table hri_cs_geo_lochr_ct');
    --
  END IF;
  --
  CLOSE csr_recs_exist;
  --
  dbg('Exiting -> Target_table_is_Empty');
  --
  RETURN l_exists;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    IF csr_recs_exist%ISOPEN THEN
      --
      CLOSE csr_recs_exist;
      --
    END IF;
    --
    -- Bug 4105868: Collection Diagnostics
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'TARGET_TABLE_IS_EMPTY');
    --
    RAISE;
    --
  --
END Target_table_is_Empty;
--
-- -----------------------------------------------------------------------------
--
-- INCREMENTAL REFRESH PROCEDURES
--
-- -----------------------------------------------------------------------------
-- Procedure to incremental refresh the location structure table
-- -----------------------------------------------------------------------------
PROCEDURE Incr_Refresh_Lochr_Struct IS
 --
 -- PL/SQL table of updated location records
 TYPE l_number_tab_type IS TABLE OF hri_cs_geo_lochr_ct.location_id%TYPE;
 l_upd_location_ids        L_NUMBER_TAB_TYPE;
 --
BEGIN
  --
  dbg('Commencing -> Incremental Refresh LocHR Struct');
  --
  dbg(' Table:'||g_schema||'.'||g_target_lochr_table);
  --
  dbg_time('Insert Start');
  INSERT
  INTO   hri_cs_geo_lochr_ct
         (area_code
         ,country_code
         ,region_code
         ,city_cid
         ,location_id
         ,geo_area_id
         ,geo_country_id
         ,geo_region_id
         ,city_src_town_or_city_txt
         ,effective_start_date
         ,effective_end_date
         ,business_group_id
         ,last_change_date
         )
  SELECT area_code,
         country_code,
         region_code,
         city_cid,
         location_id,
         geo_area_id,
         geo_country_id,
         geo_region_id,
         city_src_town_or_city_txt,
         effective_start_date,
         effective_end_date,
         business_group_id,
         NVL(last_change_date, g_dbi_collection_start_date)
  FROM   hri_cs_geo_lochr_v svw
  --
  -- 4303724, Used TRUNC function
  --
  WHERE  TRUNC(last_change_date) BETWEEN g_start_date
                                 AND     g_end_date
  AND    NOT EXISTS (SELECT 'x'
                     FROM   hri_cs_geo_lochr_ct tbl
                     WHERE  svw.location_id        = tbl.location_id
                     AND    effective_start_date   = tbl.effective_start_date
                     AND    effective_end_date     = tbl.effective_end_date)
  ;
  dbg_time('Insert End');
  --
  dbg('Insert >'||TO_CHAR(sql%rowcount));
  --
  dbg_time('Update Start');
  --
  -- UPDATE -> Rows where PK has stayed the same but other attributes / parents
  --           have changed
  --           Results from -> Regions that have had any of these change:
  --             1) Area changed
  --             2) Country changed
  --             3) Region changed
  --             4) City changed
  --
  -- 4546781 - JRHyde
  -- Change the where predicate to test all FKS for changes not just PK
  -- Removed the date clause as a delete will not give a date hence
  --  last_change_date is effectively useless
  -- Removed effective start and end date predicate as the dimension is not
  -- slowly changing - if it was then the PK index should be composite.
  --
  UPDATE hri_cs_geo_lochr_ct tbl
    SET
    (       area_code
           ,country_code
           ,region_code
           ,city_cid
           ,location_id
           ,geo_area_id
           ,geo_country_id
           ,geo_region_id
           ,city_src_town_or_city_txt
           ,effective_start_date
           ,effective_end_date
           ,business_group_id
           ,last_change_date
    ) =
    (SELECT svw.area_code,
            svw.country_code,
            svw.region_code,
            svw.city_cid,
            svw.location_id,
            svw.geo_area_id,
            svw.geo_country_id,
            svw.geo_region_id,
            svw.city_src_town_or_city_txt,
            svw.effective_start_date,
            svw.effective_end_date,
            svw.business_group_id,
            NVL(svw.last_change_date, g_dbi_collection_start_date)
       FROM hri_cs_geo_lochr_v svw
      WHERE svw.location_id            = tbl.location_id
        AND (   svw.area_code         <> tbl.area_code
             OR svw.country_code      <> tbl.country_code
             OR svw.region_code       <> tbl.region_code
             OR svw.city_cid          <> tbl.city_cid
            )
    )
  WHERE EXISTS
        (SELECT 'X'
           FROM hri_cs_geo_lochr_v     svw
          WHERE svw.location_id            = tbl.location_id
            AND svw.effective_start_date   = tbl.effective_start_date
            AND svw.effective_end_date     = tbl.effective_end_date
            AND (   svw.area_code         <> tbl.area_code
                 OR svw.country_code      <> tbl.country_code
                 OR svw.region_code       <> tbl.region_code
                 OR svw.city_cid          <> tbl.city_cid
                )
        )
  RETURNING tbl.location_id BULK COLLECT INTO l_upd_location_ids
  ;
  dbg_time('Update End');
  --
  dbg('Update >'||TO_CHAR(sql%rowcount));
  --
  -- DELETE -> PKs / Rows that are old
  --           , i.e. in table but no longer in source view
  --           Results from -> All hr locations deleted
  --
  dbg_time('Delete Start');
  DELETE
    FROM hri_cs_geo_lochr_ct tbl
   WHERE NOT EXISTS
         (SELECT 'x'
            FROM hri_cs_geo_lochr_v svw
           WHERE svw.location_id          = tbl.location_id
         )
  ;
  dbg_time('Delete End');
  --
  dbg('Delete >'||TO_CHAR(sql%rowcount));
  --
  dbg('Commiting');
  COMMIT;
  --
  -- If the location details of any of the existing records is changed then
  -- the corresponding changes should be reflected in the assingment delta table
  -- also.
  -- So insert the LOCATION_ID of the updated records into the assingment delta
  -- table so that the changes can be made to the assignment delta table by the
  -- incr process
  --
  -- NOTE: JUSTIN HYDE 30th August 2005
  -- This is not a scaleable design. As each new fact will require the dimension
  -- to be updated to insert into their respective EQ.  Suggest this needs to be
  -- a passive model not an active model and hence the dimension pushes to 1
  --  event queue only and that can be reference / subscribed to base on the
  -- fact and the customers subscription to dimensions usage in the fact.
  -- Suggest we need to put this in a dimension change table
  -- this is a bit like an MV log :-)
  -- The alternative is a single event repository but I get the feeling indexing
  -- on such a 'flexible' repository may be a nightmare.
  -- Perhaps also flagging at what level the change occurs from, so as to not
  -- have to change the levels that don't reflect that level FK in them
  --
  dbg_time('Update Event Queue Start');
  IF (l_upd_location_ids.LAST > 0 AND
      fnd_profile.value('HRI_IMPL_DBI') = 'Y') THEN
      --
      BEGIN
        --
        FORALL i IN 1..l_upd_location_ids.LAST SAVE EXCEPTIONS
          INSERT INTO HRI_EQ_ASG_SUP_WRFC
           (SOURCE_TYPE,
            SOURCE_ID)
        VALUES
           ('LOCATION',
            l_upd_location_ids(i));
        --
      EXCEPTION WHEN OTHERS THEN
        --
        dbg(sql%bulk_exceptions.COUNT
            || ' location records already exists in the event queue ');
        --
      END;
      -- Commit changes
      COMMIT;
      --
    END IF;
  dbg_time('Update Event Queue End');
  --
  dbg('Exiting -> Incremental Refresh LocHR Struct');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    output('Failure in location structure incremental refresh process.');
    output(SQLERRM);
    -- Bug 4105868: Collection Diagnostic
    g_msg_sub_group := NVL(g_msg_sub_group, 'INCR_REFRESH_LOCHR_STRUCT');
    --
    --   115.15 - 4278978: Require rollbacks for each structure collection
    ROLLBACK;
    --
    RAISE;
    --
  --
END Incr_Refresh_Lochr_Struct;
-- -----------------------------------------------------------------------------
-- Procedure to incremental refresh the region structure table
-- -----------------------------------------------------------------------------
PROCEDURE Incr_Refresh_Region_Struct
  IS
BEGIN
  --
  dbg('Commencing -> Incremental Refresh Region Structure');
  --
  dbg(' Table:'||g_schema||'.'||g_target_region_table);
  --
  dbg_time('Update Start');
  --
  -- UPDATE -> Rows where PK has stayed the same but other attributes / parents
  --           have changed
  --           Results from -> Regions that have had any of these change:
  --             1) Area changed
  --             2) Country changed
  --             3) Start Date
  --             4) End Date
  -- 4546781
  -- Changed predicates of set select statement where and update where clause.
  --
  UPDATE hri_cs_geo_region_ct tbl
    SET
   (       geo_area_code
         , geo_country_code
         , geo_region_code
         , geo_region_sk_pk
         , start_date
         , end_date
         , last_change_date
   ) =
   (SELECT csr.geo_area_code
         , csr.geo_country_code
         , csr.geo_region_code
         , csr.geo_region_sk_pk
         , csr.start_date
         , csr.end_date
         , csr.last_change_date
      FROM hri_dbi_cs_geo_region_v     csr
     WHERE csr.geo_region_sk_pk       = tbl.geo_region_sk_pk
       AND (   csr.geo_area_code     <> tbl.geo_area_code
            OR csr.geo_country_code  <> tbl.geo_country_code
            OR csr.start_date        <> tbl.start_date
            OR csr.end_date          <> tbl.end_date
           )
   )
   WHERE EXISTS
         (SELECT 'X'
            FROM hri_dbi_cs_geo_region_v csr
           WHERE csr.geo_region_sk_pk       = tbl.geo_region_sk_pk
             AND (   csr.geo_area_code     <> tbl.geo_area_code
                  OR csr.geo_country_code  <> tbl.geo_country_code
                  OR csr.start_date        <> tbl.start_date
                  OR csr.end_date          <> tbl.end_date
                 )
         )
  ;
  dbg_time('Update End');
  --
  dbg('Update >'||TO_CHAR(sql%rowcount));
  --
  -- DELETE -> PKs / Rows that are old
  --           , i.e. in table but no longer in source view
  --           Results from -> Regions being removed for all hr locations, via:
  --             1) Location attribution to Region
  --
  dbg_time('Delete Start');
  DELETE
    FROM hri_cs_geo_region_ct tbl
   WHERE NOT EXISTS
         (SELECT 'X'
            FROM hri_dbi_cs_geo_region_v csr
           WHERE csr.geo_region_sk_pk       = tbl.geo_region_sk_pk
         )
  ;
  dbg_time('Delete End');
  --
  dbg('Delete >'||TO_CHAR(sql%rowcount));
  --
  -- INSERT -> PKs / Rows that are new
  --           , i.e. in source view but not so far in the table
  --           Results from -> New Regions being brought in via:
  --             1) Location attribution to Region
  --
  dbg_time('Insert Start');
  INSERT
      INTO hri_cs_geo_region_ct
         ( geo_area_code
         , geo_country_code
         , geo_region_code
         , geo_region_sk_pk
         , start_date
         , end_date
         , last_change_date
         )
    SELECT csr.geo_area_code
         , csr.geo_country_code
         , csr.geo_region_code
         , csr.geo_region_sk_pk
         , csr.start_date
         , csr.end_date
         , csr.last_change_date
      FROM hri_dbi_cs_geo_region_v csr
     WHERE NOT EXISTS
           (SELECT 'x'
              FROM hri_cs_geo_region_ct tbl
             WHERE csr.geo_region_sk_pk       = tbl.geo_region_sk_pk
           )
  ;
  dbg_time('Insert End');
  --
  dbg('Insert >'||TO_CHAR(sql%rowcount));
  --
  -- @@ Code specific to this view/table below ENDS
  --
  dbg('Committing');
  COMMIT;
  --
  dbg('Exiting -> Incremental Refresh Region Structure');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    Output('Failure in region structure incremental update process.');
    output(SQLERRM);
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'INCR_REFRESH_REGION_STRUCT');
    --
    ROLLBACK;
    --
    RAISE;
    --
  --
END Incr_Refresh_Region_Struct;
-- -----------------------------------------------------------------------------
-- Procedure to Incremental Refresh the country structure table
-- -----------------------------------------------------------------------------
PROCEDURE Incr_Refresh_Country_Struct
  IS
BEGIN
  --
  dbg('Commencing -> Incremental refresh of Country Structure');
  --
  dbg(' Table:'||g_schema||'.'||g_target_country_table);
  --
  dbg_time('Update Start');
  --
  -- UPDATE -> Rows where PK has stayed the same but other attributes / parents
  --           have changed
  --           Results from -> Countries that have had any of these change:
  --             1) Area changed
  --             2) Start Date
  --             3) End Date
  -- 4546781
  -- Changed predicates of set select statement where and update where clause.
  --
  UPDATE hri_cs_geo_country_ct tbl
     SET
   (       geo_area_code
         , geo_country_code
         , start_date
         , end_date
         , last_change_date
   ) =
   (SELECT csc.geo_area_code
         , csc.geo_country_code
         , csc.start_date
         , csc.end_date
         , csc.last_change_date
      FROM hri_dbi_cs_geo_country_v csc
     WHERE csc.geo_country_code       = tbl.geo_country_code
       AND (   csc.geo_area_code     <> tbl.geo_area_code
            OR csc.start_date        <> tbl.start_date
            OR csc.end_date          <> tbl.end_date
           )
   )
   WHERE EXISTS
         (SELECT 'X'
            FROM hri_dbi_cs_geo_country_v csc
           WHERE csc.geo_country_code       = tbl.geo_country_code
             AND (   csc.geo_area_code     <> tbl.geo_area_code
                  OR csc.start_date        <> tbl.start_date
                  OR csc.end_date          <> tbl.end_date
                 )
         )
  ;
  dbg_time('Update End');
  --
  dbg('Update >'||TO_CHAR(sql%rowcount));
  --
  -- DELETE -> PKs / Rows that are old
  --           , i.e. in table but no longer in source view
  --           Results from -> Country being removed for all hr locations, via:
  --             1) Location attribution to a country
  --             2) Location attribution to a region
  --             3) Region attribution to Country (with at least 1 Location
  --                 having that Region)
  --
  dbg_time('Delete Start');
  DELETE
    FROM hri_cs_geo_country_ct tbl
   WHERE NOT EXISTS
         (SELECT 'x'
            FROM hri_dbi_cs_geo_country_v csc
           WHERE csc.geo_country_code       = tbl.geo_country_code
         )
  ;
  dbg_time('Delete End');
  --
  dbg('Delete >'||TO_CHAR(sql%rowcount));
  --
  -- INSERT -> PKs / Rows that are new
  --           , i.e. in source view but not so far in the table
  --           Results from -> New Countries being brought in via:
  --             1) Location attributed to country
  --             2) Location attributed to region (with Country not in list)
  --             3) Region attributed to Country (with at least 1 Location
  --                  having that Region)
  --
  dbg_time('Insert Start');
  INSERT
      INTO hri_cs_geo_country_ct
         ( geo_area_code
         , geo_country_code
         , start_date
         , end_date
         , last_change_date
         )
    SELECT csc.geo_area_code
         , csc.geo_country_code
         , csc.start_date
         , csc.end_date
         , csc.last_change_date
      FROM hri_dbi_cs_geo_country_v csc
     WHERE NOT EXISTS
           (SELECT 'x'
              FROM hri_cs_geo_country_ct tbl
             WHERE csc.geo_country_code       = tbl.geo_country_code
           )
  ;
  dbg_time('Insert End');
  --
  dbg('Insert >'||TO_CHAR(sql%rowcount));
  --
  -- @@ Code specific to this view/table below ENDS
  --
  dbg('Committing');
  COMMIT;
  --
  dbg('Exiting -> Incremental Refresh Region Structure');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    Output('Failure in country structure incremental update process.');
    output(SQLERRM);
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'INCR_REFRESH_COUNTRY_STRUCT');
    --
    ROLLBACK;
    --
    RAISE;
    --
  --
END Incr_Refresh_Country_Struct;
-- -----------------------------------------------------------------------------
--
-- FULL REFRESH PROCEDURES
--
-- -----------------------------------------------------------------------------
-- Procedure to full refresh the hr location structure table
-- -----------------------------------------------------------------------------
PROCEDURE Full_Refresh_Lochr_Struct IS
BEGIN
  --
  dbg('Commencing -> Full Refresh LocHR Struct');
  --
  dbg(' Table:'||g_schema||'.'||g_target_lochr_table);
  --
  dbg('Disabling trigger');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_GEO_LOCHR_CT_WHO DISABLE');
  --
  dbg('Truncating table prior to full refresh');
  g_sql_stmt := 'TRUNCATE TABLE ' || g_schema || '.'||g_target_lochr_table;
  dbg_time('Truncate Start');
  EXECUTE IMMEDIATE(g_sql_stmt);
  dbg_time('Truncate End');
  --
  -- Main Insert
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ 1/ Change the select beloe to select all the columns from your view
  -- @@ 2/ Change the FROM statement to point at the relevant source view
  -- (Bug 2950564: Uses APPEND hint to disable MV Log)
  --
  dbg_time('Insert Start');
  INSERT /*+ APPEND */
  INTO   hri_cs_geo_lochr_ct
         (area_code
         ,country_code
         ,region_code
         ,city_cid
         ,location_id
         ,geo_area_id
         ,geo_country_id
         ,geo_region_id
         ,city_src_town_or_city_txt
         ,effective_start_date
         ,effective_end_date
         ,business_group_id
         ,last_change_date
         ,last_update_date
         ,last_update_login
         ,last_updated_by
         ,created_by
         ,creation_date
         )
  SELECT area_code,
         country_code,
         region_code,
         city_cid,
         location_id,
         geo_area_id,
         geo_country_id,
         geo_region_id,
         city_src_town_or_city_txt,
         effective_start_date,
         effective_end_date,
         business_group_id,
         NVL(last_change_date, g_dbi_collection_start_date),
         g_current_time,
         g_user_id,
         g_user_id,
         g_user_id,
         g_current_time
    FROM hri_cs_geo_lochr_v svw
  ;
  dbg_time('Insert End');
  --
  -- @@Code specific to this view/table below ENDS
  --
  COMMIT;
  --
  dbg('Re-Enabling Who Trigger');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_GEO_LOCHR_CT_WHO ENABLE');
  --
  dbg_time('Gather Stats Start');
  fnd_stats.gather_table_stats(g_schema, g_target_lochr_table);
  dbg_time('Gather Stats End');
  --
  dbg('Exiting -> Full Refresh LocHR Struct');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    Output('Failure in location structure full refresh process.');
    output(SQLERRM);
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'FULL_REFRESH_LOCHR_STRUCT');
    --
    --   115.15 - 4278978: Require rollbacks for each structure collection
    ROLLBACK;
    --
    RAISE;
    --
END Full_Refresh_Lochr_Struct;
-- -----------------------------------------------------------------------------
-- Procedure to full refresh the region structure table
-- -----------------------------------------------------------------------------
PROCEDURE Full_Refresh_Region_Struct
  IS
BEGIN
  --
  dbg('Commencing -> Full Refresh Region Struct');
  --
  dbg(' Table:'||g_schema||'.'||g_target_region_table);
  --
  dbg('Disabling trigger');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_GEO_REGION_CT_WHO DISABLE');
  --
  dbg('Truncating table prior to full refresh');
  g_sql_stmt := 'TRUNCATE TABLE ' || g_schema || '.'||g_target_region_table;
  dbg_time('Truncate Start');
  EXECUTE IMMEDIATE(g_sql_stmt);
  dbg_time('Truncate End');
  --
  dbg_time('Insert Start');
  INSERT /*+APPEND */
    INTO hri_cs_geo_region_ct
         ( geo_area_code
         , geo_country_code
         , geo_region_code
         , geo_region_sk_pk
         , start_date
         , end_date
         , LAST_CHANGE_DATE
         , CREATION_DATE
         , CREATED_BY
         , LAST_UPDATE_DATE
         , LAST_UPDATED_BY
         , LAST_UPDATE_LOGIN
         )
    SELECT csr.geo_area_code                      geo_area_code
         , csr.geo_country_code                   geo_country_code
         , csr.geo_region_code                    geo_region_code
         , csr.geo_region_sk_pk                   geo_region_sk_pk
         , csr.start_date                         start_date
         , csr.end_date                           end_date
         , csr.last_change_date                   last_change_date
         , g_current_time                         CREATION_DATE
         , g_user_id                              CREATED_BY
         , g_current_time                         LAST_UPDADTE_DATE
         , g_user_id                              LAST_UPDATE_BY
         , g_user_id                              LAST_UPDATE_LOGIN
      FROM hri_dbi_cs_geo_region_v                csr
  ;
  dbg_time('Insert End');
  --
  -- @@Code specific to this view/table below ENDS
  --
  dbg('Commiting');
  COMMIT;
  --
  dbg('Re-Enabling Who Trigger');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_GEO_REGION_CT_WHO ENABLE');
  --
  dbg_time('Gather Stats Start');
  fnd_stats.gather_table_stats(g_schema, g_target_region_table);
  dbg_time('Gather Stats End');
  --
  dbg('Exiting -> Full Refresh Region Struct');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    Output('Failure in region structure full refresh process.');
    output(SQLERRM);
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'FULL_REFRESH_REGION_STRUCT');
    --
    ROLLBACK;
    --
    RAISE;
  --
END Full_Refresh_Region_Struct;
-- -----------------------------------------------------------------------------
-- Procedure to full refresh the country structure table
-- -----------------------------------------------------------------------------
PROCEDURE Full_Refresh_Country_Struct
  IS
BEGIN
  --
  dbg('Commencing -> Full Refresh Region Struct');
  --
  dbg(' Table : '||g_schema||'.'||g_target_country_table);
  --
  dbg('Disabling trigger');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_GEO_COUNTRY_CT_WHO DISABLE');
  --
  dbg('Truncating table prior to full refresh');
  g_sql_stmt := 'TRUNCATE TABLE ' || g_schema || '.'||g_target_country_table;
  dbg_time('Truncate Start');
  EXECUTE IMMEDIATE(g_sql_stmt);
  dbg_time('Truncate End');
  --
  dbg_time('Insert Start');
  INSERT /*+APPEND */
    INTO hri_cs_geo_country_ct
         ( geo_area_code
         , geo_country_code
         , start_date
         , end_date
         , LAST_CHANGE_DATE
         , CREATION_DATE
         , CREATED_BY
         , LAST_UPDATE_DATE
         , LAST_UPDATED_BY
         , LAST_UPDATE_LOGIN
         )
    SELECT csc.geo_area_code                        geo_area_code
         , csc.geo_country_code                     geo_country_code
         , csc.start_date                           start_date
         , csc.end_date                             end_date
         , csc.last_change_date                     last_change_date
         , g_current_time                           CREATION_DATE
         , g_user_id                                CREATED_BY
         , g_current_time                           LAST_UPDATE_DATE
         , g_user_id                                LAST_UPDATED_BY
         , g_user_id                                LAST_UPDATE_LOGIN
      FROM hri_dbi_cs_geo_country_v                 csc
  ;
  dbg_time('Insert End');
  --
  -- @@Code specific to this view/table below ENDS
  --
  dbg('Commiting');
  COMMIT;
  --
  -- Re-enable the WHO trigger
  --
  dbg('Re-Enabling Who Trigger');
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_GEO_COUNTRY_CT_WHO ENABLE');
  --
  dbg_time('Gather Stats Start');
  fnd_stats.gather_table_stats(g_schema, g_target_country_table);
  dbg_time('Gather Stats End');
  --
  dbg('Exiting -> Full Refresh Country Struct');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    Output('Failure in country structure full refresh process.');
    output(SQLERRM);
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'FULL_REFRESH_COUNTRY_STRUCT');
    --
    ROLLBACK;
    --
    RAISE;
  --
END Full_Refresh_Country_Struct;
--
-- -----------------------------------------------------------------------------
-- Incremental Refresh
--   Controller procedure for incremental refresh of all objects
--
--   115.15 - 4278978
--   Added as new structure require collecting
--   Note: Exceptions are handled in individual procedures
--   Renamed procedure to more standard name
--    FROM: Incremental_Update
--      TO: Incr_Refresh
-- -----------------------------------------------------------------------------
PROCEDURE Incr_Refresh IS
  --
BEGIN
  --
  output('Commencing Location Incremental                 : ' ||
         to_char(sysdate,'HH24:MI:SS'));
  Incr_Refresh_Lochr_Struct;
  output('Location incremental complete, commencing Region: '||
         to_char(sysdate,'HH24:MI:SS'));
  Incr_Refresh_Region_Struct;
  output('Region incremental complete, commencing Country : '||
         to_char(sysdate,'HH24:MI:SS'));
  Incr_Refresh_Country_Struct;
  output('Country incremental complete                    : '||
         to_char(sysdate,'HH24:MI:SS'));
  --
END Incr_Refresh;
--
-- -----------------------------------------------------------------------------
-- Full Refresh
--   Controller procedure for full refresh of all objects

--   115.15 - 4278978
--   Added as new structure require collecting
--   Note: Exceptions are handled in individual procedures
-- -----------------------------------------------------------------------------
PROCEDURE Full_Refresh
  IS
  --
BEGIN
  --
  output('Commencing Location Full                        : ' ||
         to_char(sysdate,'HH24:MI:SS'));
  Full_Refresh_Lochr_Struct;
  output('Location Full complete, commencing Region       : '||
         to_char(sysdate,'HH24:MI:SS'));
  Full_Refresh_Region_Struct;
  output('Region Full complete, commencing Country        : '||
         to_char(sysdate,'HH24:MI:SS'));
  Full_Refresh_Country_Struct;
  output('Country Full complete                           : '||
         to_char(sysdate,'HH24:MI:SS'));
  --
END Full_Refresh;
--
-- -------------------------------------------------------------------------
-- Checks what mode you are running in, and if g_full_refresh =
-- g_is_full_refresh calls
-- Full_Refresh procedure, otherwise Incremental_Update is called.
-- -------------------------------------------------------------------------
--
PROCEDURE Collect IS
  --
BEGIN
  --
  dbg('Commencing -> Collect');
  --
  dbg('Setup Globals');
  g_user_id      := fnd_global.user_id;
  dbg(' USER_ID : '|| to_char(g_user_id));
  g_current_time := SYSDATE;
  dbg(' Collection Date and Time : '||to_char(g_current_time));
  --
  -- If in full refresh mode chnage the dates so that the collection history
  -- is correctly maintained.
  --
  IF g_full_refresh = g_is_full_refresh THEN
    --
    g_start_date   := hr_general.start_of_time;
    g_end_date     := SYSDATE;
    --
    Full_Refresh;
    --
  ELSE
    --
    -- If the passed in date range is NULL default it.
    --
    IF g_start_date IS NULL OR
       g_end_date   IS NULL THEN
      --
      dbg('Before updating globals Start Date = '
          || g_start_date||', End Date = '||g_end_date);
      --
      g_start_date := fnd_date.displaydt_to_date
                              (hri_bpl_conc_log.get_last_collect_to_date
                                      (g_cncrnt_prgrm_shrtnm
                                      ,g_target_lochr_table
                                      )
                              );
      --
      g_end_date := SYSDATE;
      --
      dbg('After updating globals Start Date = '
          || g_start_date||', End Date = '||g_end_date);
      --
    END IF;
    --
    Incr_Refresh;
    --
  END IF;
  --
  dbg('Exiting -> Collect');
  --
  -- Bug 4105868: Collection Diagnostics
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'COLLECT');
    --
    RAISE;
    --
END Collect;
-- -----------------------------------------------------------------------------
-- Main entry point to load the table.
-- -----------------------------------------------------------------------------
--
PROCEDURE Load(p_chunk_size    IN NUMBER
              ,p_start_date    IN VARCHAR2
              ,p_end_date      IN VARCHAR2
              ,p_full_refresh  IN VARCHAR2) IS
  --
  -- Variables required for table truncation.
  --
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  --
BEGIN
  --
  dbg('Commencing -> Load');
  --
  dbg_time('PL/SQL Start');
  --
  -- Set globals
  --
  g_start_date := to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
  g_end_date   := to_date(p_end_date,   'YYYY/MM/DD HH24:MI:SS');
  --
  IF p_full_refresh IS NULL THEN
    --
    g_full_refresh := g_not_full_refresh;
    --
  ELSE
    --
    g_full_refresh := p_full_refresh;
    --
  END IF;
  --
  -- If the target table is empty default to full refresh.
  --
  IF Target_table_is_Empty THEN
    --
    dbg('Target table '||g_target_lochr_table||
           ' is empty, so doing a full refresh.');
    --
    g_full_refresh := g_is_full_refresh;
    --
  END IF;
  --
  -- Find the schema we are running in.
  --
  IF NOT fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, g_schema) THEN
    --
    -- Could not find the schema raising exception.
    --
    dbg('Could not find schema to run in.');
    --
    RAISE NO_DATA_FOUND;
    --
  END IF;
  --
  -- Update information about collection
  --
  hri_bpl_conc_log.record_process_start(g_cncrnt_prgrm_shrtnm);
  --
  collect;
  --
  dbg_time('Completed table changes');
  /*
  115.15 4278978
  Commenting out gather table stats and moving to hr location structure collection
  procedure in order to be prepared for parent structure collections
  --
  -- Gather index stats
  --
  dbg('gather table stats Schema = '
      ||g_schema||', Table = '||g_target_lochr_table);
  --
  fnd_stats.gather_table_stats(g_schema, g_target_lochr_table);
  --
  dbg('Gathered stats:   '  ||
         to_char(sysdate,'HH24:MI:SS'));
  /**/
  --
  -- Bug 4105868: Collection Diagnostic Call
  --
  hri_bpl_conc_log.log_process_end(
        p_status         => TRUE,
        p_period_from    => TRUNC(g_start_date),
        p_period_to      => TRUNC(g_end_date),
        p_attribute1     => p_full_refresh,
        p_attribute2     => p_chunk_size);
  --
  dbg_time('PL/SQL End');
  --
  dbg('Exiting -> Load');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    -- 115.15 4278978
    -- Commentin out rollback as multiple structure are collected
    -- changing to localised exception handling and Rollbacks
    --ROLLBACK;
    --
    -- Insert the error into the log table
    -- Bug 4105868: Collection Diagnostic Call
    --
    g_msg_sub_group := nvl(g_msg_sub_group, 'LOAD');
    --
    hri_bpl_conc_log.log_process_info
            (p_package_name      => 'HRI_OPL_GEO_LOCHR'
            ,p_msg_type          => 'ERROR'
            ,p_msg_group         => 'GEOGRAPHY'
            ,p_msg_sub_group     => g_msg_sub_group
            ,p_sql_err_code      => SQLCODE
            ,p_note              => SQLERRM);
    --
    -- Insert Program failure details into the log tables
    -- Bug 4105868: Collection Diagnostic Call
    --
    hri_bpl_conc_log.log_process_end
            (p_status         => FALSE
            ,p_period_from    => TRUNC(g_start_date)
            ,p_period_to      => TRUNC(g_end_date)
            ,p_attribute1     => p_full_refresh
            ,p_attribute2     => p_chunk_size
            );
    --
    RAISE;
    --
  --
END Load;
--
-- -----------------------------------------------------------------------------
-- Entry point to be called from the concurrent manager
-- -----------------------------------------------------------------------------
--
PROCEDURE Load(errbuf          OUT NOCOPY VARCHAR2
              ,retcode         OUT NOCOPY VARCHAR2
              ,p_chunk_size    IN NUMBER
              ,p_start_date    IN VARCHAR2
              ,p_end_date      IN VARCHAR2
              ,p_full_refresh  IN VARCHAR2
              ) IS
--
BEGIN
  --
  load(p_chunk_size   => p_chunk_size
      ,p_start_date   => p_start_date
      ,p_end_date     => p_end_date
      ,p_full_refresh => p_full_refresh
      );
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    errbuf  := SQLERRM;
    retcode := SQLCODE;
    --
  --
END load;

PROCEDURE Load(errbuf          OUT NOCOPY VARCHAR2
              ,retcode         OUT NOCOPY VARCHAR2) IS

  l_start_date             VARCHAR2(80);
  l_end_date               VARCHAR2(80);
  l_full_refresh           VARCHAR2(10);

BEGIN

  l_full_refresh := hri_oltp_conc_param.get_parameter_value
                     (p_parameter_name     => 'FULL_REFRESH',
                      p_process_table_name => 'HRI_CS_GEO_LOCHR_CT');
  IF (l_full_refresh = 'Y') THEN
    l_start_date := hri_oltp_conc_param.get_parameter_value
                     (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
                      p_process_table_name => 'HRI_CS_GEO_LOCHR_CT');
  ELSE
    -- Bug 4704157 - converted displaydt to canonical
    l_start_date := fnd_date.date_to_canonical
                     (fnd_date.displaydt_to_date
                       (hri_bpl_conc_log.get_last_collect_to_date
                         ('HRI_OPL_GEO_LOCHR','HRI_CS_GEO_LOCHR_CT')));
  END IF;

  hri_bpl_conc_log.dbg('Full refresh:   ' || l_full_refresh);
  hri_bpl_conc_log.dbg('Collect from:   ' || l_start_date);

  --
  load(p_chunk_size   => 1500
      ,p_start_date   => l_start_date
      ,p_end_date     => trunc(sysdate)
      ,p_full_refresh => l_full_refresh
      );
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    errbuf  := SQLERRM;
    retcode := SQLCODE;
    --
  --
END load;
--
END HRI_OPL_GEO_LOCHR;

/
