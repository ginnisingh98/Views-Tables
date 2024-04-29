--------------------------------------------------------
--  DDL for Package Body HRI_OPL_JOB_JOB_ROLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_JOB_JOB_ROLE" AS
/* $Header: hriojbrl.pkb 120.5 2006/10/11 15:29:59 jtitmas noship $ */
--
/******************************************************************************/
/* This package populates the job role table. Customers can specify the job   */
/* role associated with a job through a fast formula with following details   */
/* Name             : HRI_MAP_JOB_JOB_ROLE                                    */
/* Fast formula Type: Quickpaint                                              */
/* Business group   : Global fast formula defined in the setup business group */
/* Inputs           : JOB_FAMILY_CODE, JOB_FUNCTION_CODE                      */
/* Output           : JOB_ROLE_CODE                                           */
/******************************************************************************/
--
--
-- HRI schema name
--
g_hri_schema              VARCHAR2(240);
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
--
-- -----------------------------------------------------------------------------
-- Collects job and the role associated with the job
-- -----------------------------------------------------------------------------
--
PROCEDURE collect_job_job_roles IS
  --
  l_current_time                    DATE    := SYSDATE;
  l_user_id                         NUMBER  := fnd_global.user_id;
  l_dummy1                          VARCHAR2(2000);
  l_dummy2                          VARCHAR2(2000);
  --
BEGIN
  --
  output('Fully refreshing the Job Role table.');
  --
  -- Truncate the table
  --
  IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, g_hri_schema)) THEN
    --
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_hri_schema || '.HRI_CS_JOB_JOB_ROLE_CT';
    --
  END IF;
  --
  dbg('Inserting into hri_cs_job_job_role_ct.');
  --
  INSERT INTO HRI_CS_JOB_JOB_ROLE_CT
    (job_id
    ,job_role_code
    ,primary_role_for_job_flag
    ,created_by
    ,creation_date
    ,last_update_date
    ,last_updated_by
    ,last_update_login)
  SELECT
  job_id
  --
  -- Job Role is determined through a fast formula
  --
  ,job_role_code
  --
  -- Currently only primary job role is implemented
  --
  ,'Y'
  --
  -- WHO columns
  --
  ,l_user_id
  ,l_current_time
  ,l_current_time
  ,l_user_id
  ,l_user_id
  FROM hri_cs_job_job_role_v;
  --
  dbg('Inserted '||sql%rowcount||' records.');
  --
  output('Finished Fully refreshing the Job Role table.');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    output('Error occurred in procedure collect_job_job_roles.');
    --
    RAISE;
    --
  --
END collect_job_job_roles;
--
-- -------------------------------------------------------------------------------
-- Incremental refresh
-- -------------------------------------------------------------------------------
--
PROCEDURE update_job_job_roles IS
--
l_current_time                    DATE    := SYSDATE;
l_user_id                         NUMBER  := fnd_global.user_id;
l_end_date                        DATE    := SYSDATE;
--
-- PL/SQL table of updated job records
--
TYPE l_number_tab_type IS TABLE OF hri_cs_job_job_role_ct.job_id%TYPE;
l_upd_job_ids        L_NUMBER_TAB_TYPE;
--
BEGIN
  --
  output('Incremetally refreshing the Job Role table.');
  --
  -- Insert the new job ids and the corresponding job roles
  --
  dbg('Incrementaly inserting into hri_cs_job_job_role_ct.');
  --
  INSERT INTO hri_cs_job_job_role_ct
    (job_id
    ,job_role_code
    ,primary_role_for_job_flag
    ,created_by
    ,creation_date
    ,last_update_date
    ,last_updated_by
    ,last_update_login)
  SELECT
     job_id
    --
    -- Job Role is determined through a fast formula
    --
    ,job_role_code
    --
    -- Currently only primary job role is implemented
    --
    ,'Y'
    --
    -- WHO columns
    --
    ,l_user_id
    ,l_current_time
    ,l_current_time
    ,l_user_id
    ,l_user_id
  FROM hri_cs_job_job_role_v jbrlv
  WHERE NOT EXISTS
    (SELECT null
     FROM hri_cs_job_job_role_ct jbrl
     WHERE jbrlv.job_id = jbrl.job_id);
  --
  -- Delete the non - existant job ids
  --
  dbg('Inserted '||sql%rowcount||' records.');
  --
  dbg('Incrementaly deleting from hri_cs_job_job_role_ct.');
  --
  DELETE FROM hri_cs_job_job_role_ct jbrl
  WHERE NOT EXISTS
    (SELECT null
     FROM hri_cs_job_job_role_v jbrlv
     WHERE jbrlv.job_id = jbrl.job_id);
  --
  dbg('Deleted '||sql%rowcount||' records.');
  --
  -- Update the records for which there was a change in job family/job function
  --
  dbg('Incrementaly updating hri_cs_job_job_role_ct.');
  --
  UPDATE hri_cs_job_job_role_ct jbrl
  SET (jbrl.job_role_code
      ,primary_role_for_job_flag) =
      (SELECT
        jbrlv.job_role_code
       ,primary_role_for_job_flag
       FROM hri_cs_job_job_role_v jbrlv
       WHERE jbrlv.job_id = jbrl.job_id)
  WHERE EXISTS
    (SELECT NULL
     FROM   hri_cs_job_job_role_v jbrlv
     WHERE  jbrlv.job_id = jbrl.job_id
     AND    (
             (jbrlv.job_role_code <> jbrl.job_role_code)
              OR
             (jbrlv.primary_role_for_job_flag <> jbrl.primary_role_for_job_flag)
            )
     )
  RETURNING jbrl.job_id BULK COLLECT INTO l_upd_job_ids;
  --
  dbg('Updated '||sql%rowcount||' records.');
  --
  -- If the job role details of any of the existing records is changed then
  -- the corresponding changes should be refelected in the assingment delta table also
  -- So insert the JOB_ID of the updated records into the assingment delta table
  -- so that the changes can be made to the assignment delta table by the incr process
  --
  IF (l_upd_job_ids.LAST > 0 AND
      fnd_profile.value('HRI_IMPL_DBI') = 'Y') THEN
    --
    dbg('Populating event queue HRI_EQ_ASG_SUP_WRFC.');
    --
    BEGIN
      --
      FORALL i IN 1..l_upd_job_ids.LAST SAVE EXCEPTIONS
        --
        INSERT INTO HRI_EQ_ASG_SUP_WRFC
         (SOURCE_TYPE,
          SOURCE_ID)
        VALUES
         ('PRIMARY_JOB_ROLE',
          l_upd_job_ids(i));
        --
      --
    EXCEPTION
      --
      WHEN OTHERS THEN
        --
        dbg(sql%bulk_exceptions.count|| ' role records already exists in the event queue ');
        --
    END;
    --
  END IF;
  --
  output('Finished incremetally refreshing the Job Role table.');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    dbg('Error encountered in update_job_job_roles.');
    --
    RAISE;
    --
END update_job_job_roles;
--
-- -----------------------------------------------------------------------
-- Full Refresh
-- -----------------------------------------------------------------------
--
PROCEDURE full_refresh IS
--
BEGIN
 --
 collect_job_job_roles;
 --
 -- Commit changes
 --
 COMMIT;
--
END full_refresh;
--
-- ------------------------------------------------------------------------
-- Incremental Refresh
-- ------------------------------------------------------------------------
--
PROCEDURE incr_refresh IS
--
BEGIN
  --
  update_job_job_roles;
  --
  -- Commit changes
  --
  COMMIT;
  --
END incr_refresh;
--
END HRI_OPL_JOB_JOB_ROLE;

/
