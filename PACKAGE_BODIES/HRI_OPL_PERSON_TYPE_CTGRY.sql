--------------------------------------------------------
--  DDL for Package Body HRI_OPL_PERSON_TYPE_CTGRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_PERSON_TYPE_CTGRY" AS
/* $Header: hrioptct.pkb 120.5 2006/10/11 15:33:52 jtitmas noship $ */

/******************************************************************************/
/* This package populates the person type category table. This collection     */
/* process provides the solution to the problems raised in bug 3829100.       */
/* Customers can restrict the data in dbi based on person types by:           */
/*                                                                            */
/* 1. Create fast formulas                                                    */
/*       Name     = HRI_MAP_PERSON_TYPE                                       */
/*       FF Type  = QuickPaint                                                */
/*       BG       = Global FF defined in the setup bg.                        */
/*                  Can be overridden by formulas for particular BGs          */
/*       Inputs   = USER_PERSON_TYPE,                                         */
/*                  SYSTEM_PERSON_TYPE,                                       */
/*                  PRIMARY_FLAG,                                             */
/*                  EMPLOYMENT_CATEGORY                                       */
/*       Outputs  = INCLUDE_IN_REPORTS (Y/N),                                 */
/*                  WORKER_TYPE      (based on lookup HRI_CL_WKTH_WKTYP),     */
/*                  WORKER_TYPE_LVL1 (based on lookup HRI_CL_WKTH_LVL1),      */
/*                  WORKER_TYPE_LVL2 (based on lookup HRI_CL_WKTH_LVL2),      */
/*                                                                            */
/* With this formula users will be able to categorize the EMP and CWK system  */
/* person type for their setup. Furthermore if a certain person type should   */
/* be excluded from reporting, the INCLUDE_IN_REPORTS output can be set to    */
/* 'N'.                                                                       */
/******************************************************************************/

-- Simple table types
TYPE g_number_tab_type    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_varchar2_tab_type  IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
PROCEDURE output(p_text  VARCHAR2) IS

BEGIN
  HRI_BPL_CONC_LOG.output(p_text);
END output;

-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -----------------------------------------------------------------------------
PROCEDURE dbg(p_text  VARCHAR2) IS

BEGIN
  HRI_BPL_CONC_LOG.dbg(p_text);
END dbg;

-- ----------------------------------------------------------------------------
-- Runs given sql statement dynamically without raising an exception
-- ----------------------------------------------------------------------------
PROCEDURE run_sql_stmt_noerr( p_sql_stmt   VARCHAR2 ) IS

BEGIN
  EXECUTE IMMEDIATE p_sql_stmt;
EXCEPTION WHEN OTHERS THEN

  dbg('error encountered in running the sql');
  dbg(p_sql_stmt);
  dbg(sqlerrm);

  -- Bug 4105868: Collection Diagnostics
  hri_bpl_conc_log.log_process_info
          (p_msg_type      => 'WARNING'
          ,p_package_name  => 'HRI_OPL_PERSON_TYPE_CTGRY'
          ,p_msg_group     => 'PRSN_TYP_CNGS'
          ,p_msg_sub_group => 'RUN_SQL_STMT_NOERR'
          ,p_sql_err_code  => SQLCODE
          ,p_note          => SUBSTR(p_sql_stmt, 1, 3900));

END run_sql_stmt_noerr;

-- ----------------------------------------------------------------------------
-- Inserts records into base level HRI_CS_PRSNTYP_CT
-- ----------------------------------------------------------------------------
PROCEDURE insert_into_dim_levels(p_full_refresh   IN VARCHAR2) IS

  l_current_time         DATE := SYSDATE;
  l_user_id              NUMBER := fnd_global.user_id;
  l_sql_stmt             VARCHAR2(32000);
  l_incr_check           VARCHAR2(4000);
  l_lvl1_incr_check      VARCHAR2(4000);
  l_lvl2_incr_check      VARCHAR2(4000);

BEGIN

  -- Add an incremental check for running in incremental mode
  IF (p_full_refresh = 'N') THEN

    l_incr_check := '
WHERE NOT EXISTS
 (SELECT null
  FROM hri_cs_prsntyp_ct  dim
  WHERE dim.person_type_id = pty.person_type_id
  AND dim.primary_flag_code = pty.primary_flag_code
  AND dim.employment_category_code = pty.employment_category_code
  AND dim.assignment_type_code = pty.assignment_type_code)';

    l_lvl1_incr_check := '
 AND NOT EXISTS
  (SELECT null
   FROM hri_cs_wkth_lvl1_ct  dim
   WHERE dim.wkth_lvl1_sk_pk = tab.wkth_lvl1_sk_pk)';

    l_lvl2_incr_check := '
 AND NOT EXISTS
  (SELECT null
   FROM hri_cs_wkth_lvl2_ct  dim
   WHERE dim.wkth_lvl2_sk_pk = tab.wkth_lvl2_sk_pk)';

  END IF;

-- -----------------------------------------------------------------------------
-- Base Level
-- -----------------------------------------------------------------------------

  -- Set dynamic SQL
  l_sql_stmt :=
'INSERT INTO hri_cs_prsntyp_ct
   (prsntyp_sk_pk
   ,wkth_wktyp_sk_fk
   ,wkth_lvl1_sk_fk
   ,wkth_lvl2_sk_fk
   ,wkth_wktyp_code
   ,wkth_lvl1_code
   ,wkth_lvl2_code
   ,person_type_id
   ,primary_flag_code
   ,assignment_type_code
   ,employment_category_code
   ,include_flag_code
   ,last_update_date
   ,last_updated_by
   ,last_update_login
   ,created_by
   ,creation_date)
  SELECT
   hri_cs_prsntyp_ct_s.nextval         prsntyp_sk_pk
  ,pty.wkth_wktyp_sk_fk
  ,pty.wkth_lvl1_sk_fk
  ,pty.wkth_lvl2_sk_fk
  ,pty.wkth_wktyp_code
  ,pty.wkth_lvl1_code
  ,pty.wkth_lvl2_code
  ,pty.person_type_id
  ,pty.primary_flag_code
  ,pty.assignment_type_code
  ,pty.employment_category_code
  ,pty.include_flag_code
  ,:l_current_time
  ,:l_user_id
  ,:l_user_id
  ,:l_user_id
  ,:l_current_time
  FROM
   hri_cs_prsntyp_v  pty' ||
  l_incr_check;

  EXECUTE IMMEDIATE l_sql_stmt USING
    l_current_time,
    l_user_id,
    l_user_id,
    l_user_id,
    l_current_time;

  -- Insert unassigned row in initial load only
  IF (p_full_refresh = 'Y') THEN

    INSERT INTO hri_cs_prsntyp_ct
     (prsntyp_sk_pk
     ,wkth_wktyp_sk_fk
     ,wkth_lvl1_sk_fk
     ,wkth_lvl2_sk_fk
     ,wkth_wktyp_code
     ,wkth_lvl1_code
     ,wkth_lvl2_code
     ,person_type_id
     ,primary_flag_code
     ,assignment_type_code
     ,employment_category_code
     ,include_flag_code
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,created_by
     ,creation_date)
    SELECT
     -1
    ,'NA_EDW'
    ,'NA_EDW-NA_EDW'
    ,'NA_EDW-NA_EDW-NA_EDW'
    ,'NA_EDW'
    ,'NA_EDW'
    ,'NA_EDW'
    ,-1
    ,'NA_EDW'
    ,'NA_EDW'
    ,'NA_EDW'
    ,'N'
    ,l_current_time
    ,l_user_id
    ,l_user_id
    ,l_user_id
    ,l_current_time
    FROM dual;

  END IF;

-- -----------------------------------------------------------------------------
-- Level 2
-- -----------------------------------------------------------------------------

  -- Set dynamic SQL
  l_sql_stmt :=
'INSERT INTO hri_cs_wkth_lvl2_ct
  (wkth_lvl2_sk_pk
  ,wkth_lvl1_sk_fk
  ,wkth_wktyp_sk_fk
  ,wkth_lvl2_code
  ,wkth_lvl1_code
  ,wkth_wktyp_code
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
 SELECT
  tab.wkth_lvl2_sk_pk
 ,tab.wkth_lvl1_sk_fk
 ,tab.wkth_wktyp_sk_fk
 ,tab.wkth_lvl2_code
 ,tab.wkth_lvl1_code
 ,tab.wkth_wktyp_code
 ,:l_current_time
 ,:l_user_id
 ,:l_user_id
 ,:l_user_id
 ,:l_current_time
 FROM
  (SELECT
    wktyp.lookup_code || ''-'' || lvl1.lookup_code || ''-'' || lvl2.lookup_code
                                                     wkth_lvl2_sk_pk
   ,wktyp.lookup_code || ''-'' || lvl1.lookup_code   wkth_lvl1_sk_fk
   ,wktyp.lookup_code                                wkth_wktyp_sk_fk
   ,lvl2.lookup_code                                 wkth_lvl2_code
   ,lvl1.lookup_code                                 wkth_lvl1_code
   ,wktyp.lookup_code                                wkth_wktyp_code
   FROM
    hr_standard_lookups  lvl2
   ,hr_standard_lookups  lvl1
   ,hr_standard_lookups  wktyp
   WHERE lvl2.lookup_type = ''HRI_CL_WKTH_LVL2''
   AND lvl1.lookup_type = ''HRI_CL_WKTH_LVL1''
   AND wktyp.lookup_type = ''HRI_CL_WKTH_WKTYP''
  )  tab
 WHERE EXISTS
  (SELECT null
   FROM hri_cs_prsntyp_ct  ptyp
   WHERE ptyp.wkth_lvl2_sk_fk = tab.wkth_lvl2_sk_pk
   AND ptyp.wkth_lvl1_sk_fk = tab.wkth_lvl1_sk_fk
   AND ptyp.wkth_wktyp_sk_fk = tab.wkth_wktyp_sk_fk)' ||
 l_lvl2_incr_check;

  EXECUTE IMMEDIATE l_sql_stmt USING
    l_current_time,
    l_user_id,
    l_user_id,
    l_user_id,
    l_current_time;

-- -----------------------------------------------------------------------------
-- Level 1
-- -----------------------------------------------------------------------------

  -- Set dynamic SQL
  l_sql_stmt :=
'INSERT INTO hri_cs_wkth_lvl1_ct
  (wkth_lvl1_sk_pk
  ,wkth_wktyp_sk_fk
  ,wkth_lvl1_code
  ,wkth_wktyp_code
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
 SELECT
  tab.wkth_lvl1_sk_pk
 ,tab.wkth_wktyp_sk_fk
 ,tab.wkth_lvl1_code
 ,tab.wkth_wktyp_code
 ,:l_current_time
 ,:l_user_id
 ,:l_user_id
 ,:l_user_id
 ,:l_current_time
 FROM
  (SELECT
    wktyp.lookup_code || ''-'' || lvl1.lookup_code   wkth_lvl1_sk_pk
   ,wktyp.lookup_code                                wkth_wktyp_sk_fk
   ,lvl1.lookup_code                                 wkth_lvl1_code
   ,wktyp.lookup_code                                wkth_wktyp_code
   FROM
    hr_standard_lookups  lvl1
   ,hr_standard_lookups  wktyp
   WHERE lvl1.lookup_type = ''HRI_CL_WKTH_LVL1''
   AND wktyp.lookup_type = ''HRI_CL_WKTH_WKTYP''
  )  tab
 WHERE EXISTS
  (SELECT null
   FROM hri_cs_wkth_lvl2_ct  ptyp
   WHERE ptyp.wkth_lvl1_sk_fk = tab.wkth_lvl1_sk_pk
   AND ptyp.wkth_wktyp_sk_fk = tab.wkth_wktyp_sk_fk)' ||
 l_lvl1_incr_check;

  EXECUTE IMMEDIATE l_sql_stmt USING
    l_current_time,
    l_user_id,
    l_user_id,
    l_user_id,
    l_current_time;

END insert_into_dim_levels;

-- ----------------------------------------------------------------------------
-- Deletes records into base level HRI_CS_PRSNTYP_CT
-- ----------------------------------------------------------------------------
PROCEDURE delete_from_dim_levels(p_full_refresh   IN VARCHAR2) IS

  l_hri_schema           VARCHAR2(300);
  l_dummy1               VARCHAR2(2000);
  l_dummy2               VARCHAR2(2000);

BEGIN

  IF (p_full_refresh = 'N') THEN

    -- Delete any obsolete person types
    DELETE FROM hri_cs_prsntyp_ct  dim
    WHERE dim.prsntyp_sk_pk <> -1
    AND dim.person_type_id NOT IN
     (SELECT ppt.person_type_id
      FROM per_person_types  ppt
      WHERE ppt.system_person_type IN ('EMP','CWK'));

    -- Delete any obsolete employment categories
    DELETE FROM hri_cs_prsntyp_ct  dim
    WHERE dim.employment_category_code <> 'NA_EDW'
    AND dim.prsntyp_sk_pk <> -1
    AND dim.employment_category_code NOT IN
     (SELECT hrl.lookup_code
      FROM hr_standard_lookups  hrl
      WHERE hrl.lookup_type IN ('EMP_CAT','CWK_ASG_CATEGORY')
      AND hrl.enabled_flag = 'Y');

  ELSE

    -- Truncate the person type hierarchy table
    IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_hri_schema)) THEN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_hri_schema || '.HRI_CS_PRSNTYP_CT';
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_hri_schema || '.HRI_CS_WKTH_LVL2_CT';
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_hri_schema || '.HRI_CS_WKTH_LVL1_CT';
    END IF;

  END IF;

END delete_from_dim_levels;

-- ----------------------------------------------------------------------------
-- Updates records into base level HRI_CS_PRSNTYP_CT (Incremental only)
-- ----------------------------------------------------------------------------
PROCEDURE update_dim_levels IS
 --
 -- PL/SQL table of updated person type records
 --
 TYPE l_number_tab_type IS TABLE OF hri_cs_geo_lochr_ct.location_id%TYPE;
 l_upd_prsntyp_sks       L_NUMBER_TAB_TYPE;
 --
BEGIN
  --
  -- Update any changed records
  --
  UPDATE hri_cs_prsntyp_ct dim
  SET
   (wkth_wktyp_sk_fk
   ,wkth_lvl1_sk_fk
   ,wkth_lvl2_sk_fk
   ,wkth_wktyp_code
   ,wkth_lvl1_code
   ,wkth_lvl2_code
   ,include_flag_code) =
  (SELECT
    vw.wkth_wktyp_sk_fk
   ,vw.wkth_lvl1_sk_fk
   ,vw.wkth_lvl2_sk_fk
   ,vw.wkth_wktyp_code
   ,vw.wkth_lvl1_code
   ,vw.wkth_lvl2_code
   ,vw.include_flag_code
   FROM hri_cs_prsntyp_v  vw
   WHERE vw.person_type_id = dim.person_type_id
   AND vw.employment_category_code = dim.employment_category_code
   AND vw.primary_flag_code = dim.primary_flag_code
   AND vw.assignment_type_code = dim.assignment_type_code)
  WHERE EXISTS
   (SELECT null
    FROM hri_cs_prsntyp_v  vw
    WHERE vw.person_type_id = dim.person_type_id
    AND vw.employment_category_code = dim.employment_category_code
    AND vw.primary_flag_code = dim.primary_flag_code
    AND vw.assignment_type_code = dim.assignment_type_code
    AND (vw.wkth_wktyp_code   <> dim.wkth_wktyp_code
      OR vw.wkth_lvl1_code    <> dim.wkth_lvl1_code
      OR vw.wkth_lvl2_code    <> dim.wkth_lvl2_code
      OR vw.include_flag_code <> dim.include_flag_code))
  RETURNING dim.prsntyp_sk_pk BULK COLLECT INTO l_upd_prsntyp_sks;
      --
      -- If the person type details of any of the existing records is changed then
      -- the corresponding changes should be refelected in the assingment delta table also
      -- So insert the PRSNTYP_SK_PK of the updated records into the assingment delta table
      -- so that the changes can be made to the assignment delta table by the incr process
      --
      IF (l_upd_prsntyp_sks.LAST > 0 AND
          fnd_profile.value('HRI_IMPL_DBI') = 'Y') THEN
        --
        BEGIN
          --
          FORALL i IN 1..l_upd_prsntyp_sks.LAST SAVE EXCEPTIONS
            INSERT INTO HRI_EQ_ASG_SUP_WRFC
             (SOURCE_TYPE,
              SOURCE_ID)
          VALUES
             ('PERSON_TYPE',
              l_upd_prsntyp_sks(i));
          --
        EXCEPTION WHEN OTHERS THEN
          --
          dbg(sql%bulk_exceptions.count|| ' person type records already exists in the event queue ');
          --
        END;
        --
    END IF;
    --
END update_dim_levels;

-- ----------------------------------------------------------------------------
-- Full Refresh Entry Point
-- ----------------------------------------------------------------------------
PROCEDURE full_refresh IS

BEGIN

  -- 3601362 Disable the WHO Trigger
  run_sql_stmt_noerr('ALTER TRIGGER hri_cs_prsntyp_ct_who DISABLE');

  -- Truncate dimension levels
  delete_from_dim_levels(p_full_refresh => 'Y');

  -- Repopulate dimension levels
  insert_into_dim_levels(p_full_refresh => 'Y');

  -- Commit changes
  COMMIT;

  -- 3601362 Enable the WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER hri_cs_prsntyp_ct_who ENABLE');

END full_refresh;

-- ----------------------------------------------------------------------------
-- Incremental refresh entry point
-- ----------------------------------------------------------------------------
PROCEDURE incr_refresh IS

BEGIN

  -- Delete obsolete records from dimension levels
  delete_from_dim_levels(p_full_refresh => 'N');

  -- Insert new records into dimension levels
  insert_into_dim_levels(p_full_refresh => 'N');

  -- Update changed records in dimension levels
  update_dim_levels;

  -- Commit changes
  COMMIT;

END incr_refresh;

END hri_opl_person_type_ctgry;

/
