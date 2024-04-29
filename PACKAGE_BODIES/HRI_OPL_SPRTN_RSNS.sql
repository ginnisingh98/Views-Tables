--------------------------------------------------------
--  DDL for Package Body HRI_OPL_SPRTN_RSNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_SPRTN_RSNS" AS
/* $Header: hriosprn.pkb 120.1 2005/07/28 02:20:53 anmajumd noship $ */
--
-- Bug 4105868: Collection Diagnostics
--
g_msg_sub_group        VARCHAR2(400) := '';
--
-- -------------------------------------------------------------------------
-- Inserts row into concurrent program log when the g_conc_request_id has
-- been set to TRUE, otherwise does nothing
-- -------------------------------------------------------------------------
--
PROCEDURE output(p_text  VARCHAR2) IS
--
BEGIN
  --
  -- Bug 4105868: Collection Diagnostics
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
-- -------------------------------------------------------------------------
-- Load Separations Reason Table
-- -------------------------------------------------------------------------
--
PROCEDURE load_sprtn_rsns_tab
IS
  --
  l_formula_id        NUMBER;          -- Fast Formula Id of HR_MOVE_TYPE
  l_term_type         VARCHAR2(30);    -- Holds I(nvoluntary) or V(oluntary)
  --
  -- Cursor selects all separation reasons, and outer joins to the
  -- involuntary/voluntary categorization table to determine whether
  -- an insert or an update is needed
  -- 2448895 - Added the NA_EDW row to ensure that a separation
  -- category is obtained for the NULL separation reason from the
  -- fast formula
  --
  CURSOR leaving_reasons_csr IS
  SELECT hrl.lookup_code                      lookup_code,
         DECODE(spr.reason, null, 'N', 'Y')   exists_flag
  FROM   hr_standard_lookups  hrl,
         hri_inv_sprtn_rsns   spr
  WHERE  hrl.lookup_code = spr.reason (+)
  AND    hrl.lookup_type = 'LEAV_REAS'
  UNION  ALL
  SELECT 'NA_EDW'                             lookup_code,
         'N'                                  exists_flag
  FROM   dual
  WHERE  NOT EXISTS
         (SELECT -1
          FROM   hri_inv_sprtn_rsns spr
          WHERE  spr.reason = 'NA_EDW')
  UNION  ALL
  SELECT 'NA_EDW'                             lookup_code,
         'Y'                                  exists_flag
  FROM   dual
  WHERE  EXISTS
         (SELECT -1
          FROM   hri_inv_sprtn_rsns spr
          WHERE  spr.reason = 'NA_EDW');
  --
BEGIN
  --
  dbg('inside load_sprtn_rsns_tab');
  --
  -- Get formula id of fast formula to use
  --
  l_formula_id := hr_person_flex_logic.GetTermTypeFormula
                    ( p_business_group_id => 0 );
  --
  dbg('insert/update records in hri_inv_sprtn_rsns');
  --
  -- Loop through all the leaving reasons defined
  --
  FOR v_leaving_reason IN leaving_reasons_csr LOOP
    --
    -- Run fast formula for current leaving reason
    --
    l_term_type  := HR_PERSON_FLEX_LOGIC.GetTermType
                      ( p_term_formula_id => l_formula_id,
                        p_leaving_reason  => v_leaving_reason.lookup_code,
                        p_session_date    => SYSDATE );
    --
    dbg('code = '||v_leaving_reason.lookup_code||' , term_type = '||l_term_type);
    --
    -- If leaving reason not already in the categorization table
    --
    IF (v_leaving_reason.exists_flag = 'N') THEN
      --
      -- Insert the details into the table
      --
      INSERT
      INTO   hri_inv_sprtn_rsns
             (reason
             ,termination_type
             ,update_allowed_flag
             )
      VALUES (v_leaving_reason.lookup_code
             ,l_term_type
             ,'N'
             );
      --
    ELSE
      --
      -- Update the reason
      --
      UPDATE hri_inv_sprtn_rsns
      SET    termination_type = l_term_type
      WHERE  reason = v_leaving_reason.lookup_code;
      --
    END IF;
    --
  END LOOP;
  --
  COMMIT;
  --
  dbg('exiting load_sprtn_rsns_tab');
  --
  -- Bug 4105868: Collection Diagnostics
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'LOAD_SPRTN_RSNS_TAB');
    --
    RAISE;
    --
END load_sprtn_rsns_tab;
--
-- This procedure populates the separation reasons table in shared HRMS installations
--
PROCEDURE load_sprtn_rsns_shared_hrms

IS

  l_sysdate   Date;
  l_user      number;
  l_sql_stmt VARCHAR2(2000);
  l_dummy1 VARCHAR2(2000);
  l_dummy2 VARCHAR2(2000);
  l_schema VARCHAR2(2000);
  --
  BEGIN
    --
    dbg('inside load_sprtn_rsns_shared_hrms');
    --
    --
    -- Get HRI schema name - get_app_info populates l_schema
    --
    IF fnd_installation.get_app_info('HRI',l_dummy1,l_dummy2,l_schema) THEN
    --
      null;
    --
    END IF;
    --
    -- Truncate the table
    --
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_INV_SPRTN_RSNS';
    --
    EXECUTE IMMEDIATE(l_sql_stmt);
    --
    -- Assigning sysdate and user for who columns
    --
    l_sysdate := sysdate;
    l_user := fnd_global.user_id;
    --
    -- Insert into the table
    --
      INSERT /*+ APPEND */ INTO hri_inv_sprtn_rsns
      ( reason
      , termination_type
      , update_allowed_flag
      , last_update_date
      , last_updated_by
      , last_update_login
      , created_by
      , creation_date
      )
      SELECT
       lookup_code
       , 'V'
       , 'N'
       , l_sysdate
       , l_user
       , l_user
       , l_user
       , l_sysdate
      FROM hr_standard_lookups
      WHERE lookup_type = 'LEAV_REAS'
      UNION ALL
      SELECT
       'NA_EDW'                             lookup_code
       , 'V'
       , 'N'
       , l_sysdate
       , l_user
       , l_user
       , l_user
       , l_sysdate
      FROM
      dual;
      --
      COMMIT;
      --
      dbg('exiting load_sprtn_rsns_shared_hrms');
      --
END load_sprtn_rsns_shared_hrms;
--
--
-- ----------------------------------------------------------------------------
-- Entry point to be called from the concurrent manager
-- ----------------------------------------------------------------------------
--
PROCEDURE populate_sprtn_rsns(Errbuf       in out nocopy  Varchar2,
                              Retcode      in out  nocopy Varchar2)
IS
  --
  -- Bug 4105868: Collection Diagnostics
  --
  l_message       fnd_new_messages.message_text%type;
  --
  --
  l_foundation_hr_flag VARCHAR2(1);
  --
BEGIN
  --
  dbg('inside populate_sprtn_rsns');
  --
  --
  -- If full HR is not installed, then set the flag to 'Y'
  --
   IF hr_general.chk_product_installed(800) = 'FALSE' THEN
     --
     l_foundation_hr_flag := 'Y';
     --
   --
   -- If the profile HRI_DBI_FORCE_SHARED_HR has been set then
   -- set the flag to 'Y'
   --
   ELSIF NVL(fnd_profile.value('HRI_DBI_FORCE_SHARED_HR'),'N') ='Y' THEN
     --
     l_foundation_hr_flag := 'Y';
     --
   ELSE
     --
     l_foundation_hr_flag := 'N';
     --
   END IF;
   --
   -- Bug 4105868: Collection Diagnostics
   --
   hri_bpl_conc_log.record_process_start('HRI_INV_SPRTN_RSNS');
   --
   -- If the flag for foundation has been set then run the load in shared mode,
   -- else run in normal mode
   --
   IF l_foundation_hr_flag = 'Y' THEN
     --
     load_sprtn_rsns_shared_hrms;
     --
   ELSE
     --
    load_sprtn_rsns_tab;
     --
   END IF;
   --
   -- Bug 4105868: Collection Diagnostics
   --
   hri_bpl_conc_log.log_process_end(
          p_status         => TRUE,
          p_period_from    => hr_general.start_of_time,
          p_period_to      => hr_general.end_of_time);
   --
   dbg('exiting populate_sprtn_rsns');
   --
EXCEPTION
  WHEN OTHERS THEN
    --
    l_message := nvl(fnd_message.get,SQLERRM);
    --
    output(l_message);
    --
    errbuf  := sqlerrm;
    retcode := sqlcode;
    --
    -- Bug 4105868: Collection Diagnostics
    --
    g_msg_sub_group := NVL(g_msg_sub_group, 'POPULATE_SPRTN_RSNS');
    --
    hri_bpl_conc_log.log_process_info
            (p_msg_type      => 'ERROR'
            ,p_note          => l_message
            ,p_package_name  => 'HRI_OPL_SPRTN_RSNS'
            ,p_msg_sub_group => g_msg_sub_group
            ,p_sql_err_code  => SQLCODE
            ,p_msg_group     => 'SEP_RSN');
    --
    hri_bpl_conc_log.log_process_end
            (p_status        => FALSE
            ,p_period_from   => hr_general.start_of_time
            ,p_period_to     => hr_general.end_of_time);
    --
    RAISE;
    --
END populate_sprtn_rsns;
--
END hri_opl_sprtn_rsns;

/
