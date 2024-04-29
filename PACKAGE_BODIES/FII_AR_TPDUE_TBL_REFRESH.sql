--------------------------------------------------------
--  DDL for Package Body FII_AR_TPDUE_TBL_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_TPDUE_TBL_REFRESH" AS
/*$Header: FIIARTPB.pls 120.1.12000000.1 2007/02/23 02:29:32 applrt ship $*/

   g_phase         VARCHAR2(80);
   g_debug_flag    VARCHAR2(1)  := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
   g_retcode       VARCHAR2(20) := NULL;
   g_fii_user_id   NUMBER;
   g_fii_login_id  NUMBER;
   g_fii_sysdate   DATE;
   g_schema_name   VARCHAR2(120) := 'FII';
   l_profile	   VARCHAR2(1);
   g_self_msg      VARCHAR2(50):= FND_MESSAGE.get_string('FII', 'FII_AR_SELF');
   G_LOGIN_INFO_NOT_AVABLE EXCEPTION;

   --We use a un-shipped profile option FII_TEST_SYSDATE ("FII: Test Sysdate")
   --to reset different sysdate so that we can test for snapshot tables.
   g_test_sysdate  DATE := to_date(FND_PROFILE.value('FII_TEST_SYSDATE'), 'DD/MM/YYYY');

----------------------------------------------------
-- PROCEDURE Initialize  (private)
--
----------------------------------------------------

   PROCEDURE Initialize  IS

     l_count      NUMBER(15) := 0;
     l_dir        VARCHAR2(160);
     l_check      NUMBER;

   BEGIN

     g_phase := 'Do set up for log file';
     ----------------------------------------------
     -- Do set up for log file
     ----------------------------------------------

     l_dir := fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY');
     ------------------------------------------------------
     -- Set default directory in CASE if the profile option
     -- BIS_DEBUG_LOG_DIRECTORY is not set up
     ------------------------------------------------------
     if l_dir is NULL THEN
       l_dir := FII_UTIL.get_utl_file_dir;
     end if;

     ----------------------------------------------------------------
     -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
     -- AND BIS_DEBUG_LOG_DIRECTORY AND set up the directory WHERE
     -- the log files AND output files are written to
     ----------------------------------------------------------------
     FII_UTIL.initialize('FII_AR_TPDUE_TBL_REFRESH.log',
                         'FII_AR_TPDUE_TBL_REFRESH.out',l_dir,
                         'FII_AR_TPDUE_TBL_REFRESH');

     g_phase := 'Obtain FII schema name AND other info';

     -- Obtain FII schema name
     g_schema_name := FII_UTIL.get_schema_name ('FII');

     -- Obtain user ID, login ID AND sysdate
     g_fii_user_id 	:= FND_GLOBAL.USER_ID;
     g_fii_login_id	:= FND_GLOBAL.LOGIN_ID;

     SELECT sysdate INTO g_fii_sysdate FROM dual;

     g_phase := 'Check FII schema name AND other info';
     -- If any of the above values is not set, error out
     IF (g_fii_user_id is NULL OR g_fii_login_id is NULL) THEN
       FII_UTIL.Write_Log ('>>> Failed Intialization (login info not available)');
       RAISE G_LOGIN_INFO_NOT_AVABLE;
     END IF;

     -- Determine if process will be run in debug mode
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Debug On');
     ELSE
       FII_UTIL.Write_Log ('Debug Off');
     END IF;

     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Initialize: Now start processing... ');
     End If;

   Exception

     When others THEN
        FII_UTIL.Write_Log ('Unexpected error WHEN calling Initialize...');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
	      FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
        RAISE;

   END Initialize;


----------------------------------------------------
-- PROCEDURE REFRESH_AR_TPDUE_BASE_F  (private)
--
-- This procedure will (fully) refresh table FII_AR_TPDUE_BASE_F
-- FROM FII_AR_NET_REC_BASE_MV AND FII_AR_DISPUTES_BASE_MV
----------------------------------------------------
 PROCEDURE REFRESH_AR_TPDUE_BASE_F IS

   l_this_date     DATE;
   l_pp_this_date  DATE;
   l_pq_this_date  DATE;
   l_ly_this_date  DATE;
   l_min_start_date DATE;

 BEGIN
  g_self_msg := FND_MESSAGE.get_string('FII', 'FII_AR_SELF');
  g_phase := 'Entering FII_AR_TPDUE_BASE_F';
  IF g_debug_flag = 'Y' THEN
    FII_UTIL.Write_Log ('> Entering FII_AR_TPDUE_BASE_F');
    FII_UTIL.start_timer();
  END IF;


  g_phase := 'Populate l_this_date FROM BIS_SYSTEM_DATE';

  --We use a un-shipped profile option FII_TEST_SYSDATE ("FII: Test Sysdate")
  --to reset different sysdate so that we can test for snapshot tables.
  if g_test_sysdate is NULL THEN
    SELECT trunc(CURRENT_DATE_ID) INTO l_this_date
      FROM BIS_SYSTEM_DATE;
  ELSE
    l_this_date := g_test_sysdate;
  end if;

  -- SELECT MIN(start_date) INTO l_min_start_date
 --  FROM fii_time_ent_period;
  --------------------------------------------------

--  g_phase := 'Populate l_pp_this_date, l_pq_this_date, l_ly_this_date, l_this_date_gov';

/*
sysdate = 20-Jul-2006

l_pp_this_date = 19-Jun-2006
l_pq_this_date = 19-Apr-2006
l_ly_this_date = 20-Jul-2005
l_this_date_gov = 31-Jul-2006
*/

/*
SELECT	NVL(fii_time_api.ent_sd_pper_end(l_this_date),l_min_start_date),
	NVL(fii_time_api.ent_sd_pqtr_end(l_this_date),l_min_start_date),
	NVL(fii_time_api.ent_sd_lyr_end(l_this_date),l_min_start_date),
	NVL( fii_time_api.ent_cper_end(l_this_date),l_min_start_date)

INTO	l_pp_this_date,
	l_pq_this_date,
	l_ly_this_date,
	l_this_date_gov

FROM	DUAL;*/

  IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('>> l_this_date = '     || l_this_date);
  END IF;

  --Always do a full refresh for snapshot tables
  g_phase := 'Truncate table FII_AR_TPDUE_BASE_F';
  FII_UTIL.truncate_table ('FII_AR_TPDUE_BASE_F', 'FII', g_retcode);

  g_phase := 'Starting to populate table FII_AR_TPDUE_BASE_F';
  IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('>> Starting to populate table FII_AR_TPDUE_BASE_F');
  END IF;


 --------------------------------------------------------------------------
 --Insert data FROM fii_ar_net_rec_base_mv  by joining
 -- to fii_time_structures, fii_customer_hierarchies, hz_parties
 --Here we calculate ITD amounts for date on which the job is run
 --fii_customer_hierarchies and hz_parties is used to avoid
 --costly GT table population while running the report
 --------------------------------------------------------------------------

 insert /*+ append */ INTO FII_AR_TPDUE_BASE_F
  ( parent_party_id,
		party_id,
		collector_id,
		org_id,
		IS_LEAF_FLAG,
		IS_SELF_FLAG,
		VIEW_BY,
		VIEWBY_CODE,
		CUST_NEXT_LEVEL_PARTY_ID,
		CUST_PARENT_PARTY_ID,
		CUST_CHILD_PARTY_ID,
		past_due_open_amount_func,
		past_due_open_amount_prim,
		past_due_open_amount_sec,
	  wtd_terms_out_open_num_func,
		wtd_terms_out_open_num_prim,
		wtd_terms_out_open_num_sec,
		wtd_DDSO_due_num_func,
    wtd_DDSO_due_num_prim,
    wtd_DDSO_due_num_sec,
    current_open_amount_func,
		current_open_amount_prim,
		current_open_amount_sec,
	  LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN)
    SELECT parent_party_id,
    party_id,
    collector_id,
    org_id,
    is_leaf_flag,
    is_self_flag,
    VIEW_BY,
		VIEWBY_CODE,
		CUST_NEXT_LEVEL_PARTY_ID,
		CUST_PARENT_PARTY_ID,
		CUST_CHILD_PARTY_ID,
		SUM(past_due_open_amount_func) past_due_open_amount_func,
    SUM(past_due_open_amount_prim)    past_due_open_amount_prim,
		SUM(past_due_open_amount_sec)     past_due_open_amount_sec,
	  SUM(wtd_terms_out_open_num_func) wtd_terms_out_open_num_func,
		SUM(wtd_terms_out_open_num_prim) wtd_terms_out_open_num_prim,
		SUM(wtd_terms_out_open_num_sec) wtd_terms_out_open_num_sec,
		SUM(wtd_DDSO_due_num_func) wtd_DDSO_due_num_func,
    SUM(wtd_DDSO_due_num_prim) wtd_DDSO_due_num_prim,
    SUM(wtd_DDSO_due_num_sec) wtd_DDSO_due_num_sec,
    SUM(current_open_amount_func)    current_open_amount_func,
		SUM(current_open_amount_prim)    current_open_amount_prim,
		SUM(current_open_amount_sec)     current_open_amount_sec,
    g_fii_sysdate,
    g_fii_user_id,
    g_fii_sysdate,
    g_fii_user_id,
    g_fii_login_id FROM (
 SELECT
       b.parent_party_id parent_party_id,
		   b.party_id party_id,
		   b.collector_id collector_id,
		   b.org_id org_id,
		   cust.next_level_is_leaf_flag is_leaf_flag,
		   case when cust.parent_party_id = hz.party_id
 				 and cust.next_level_is_leaf_flag <> 'Y'
			   then 'Y'
		 	   else 'N' end is_self_flag,
		 	 case when cust.parent_party_id = hz.party_id
 				 and cust.next_level_is_leaf_flag <> 'Y'
			   then hz.party_name ||g_self_msg
			   else hz.party_name end view_by,
			 hz.party_id viewby_code,
			 cust.next_level_party_id cust_next_level_party_id,
			 cust.parent_party_id cust_parent_party_id,
		   cust.child_party_id cust_child_party_id,
			 past_due_open_amount_func,
       past_due_open_amount_prim,
			 past_due_open_amount_sec,
	     wtd_terms_out_open_num_func,
		   wtd_terms_out_open_num_prim,
		   wtd_terms_out_open_num_sec,
		   wtd_DDSO_due_num_func,
       wtd_DDSO_due_num_prim,
       wtd_DDSO_due_num_sec,
       current_open_amount_func,
		   current_open_amount_prim,
		   current_open_amount_sec
FROM   fii_time_structures cal,
       fii_ar_net_rec_base_mv  b,
       FII_CUSTOMER_HIERARCHIES cust,
       HZ_PARTIES hz
WHERE   cal.report_date     = l_this_date
    AND cal.time_id         = b.time_id
    AND cal.period_type_id  = b.period_type_id
    AND bitand(cal.record_type_id, 512) = 512
    AND cust.parent_party_id = b.parent_party_id
    AND cust.child_party_id  = b.party_id
    AND cust.next_level_party_id = hz.party_id
    AND b.gid = 1025
 )
  GROUP BY parent_party_id,
    party_id,
    collector_id,
    org_id,
    is_leaf_flag,
    is_self_flag,
    VIEW_BY,
		VIEWBY_CODE,
		CUST_NEXT_LEVEL_PARTY_ID,
		CUST_PARENT_PARTY_ID,
		CUST_CHILD_PARTY_ID;




  IF g_debug_flag = 'Y' THEN
    FII_UTIL.stop_timer();
    FII_UTIL.Write_Log ('FII_AR_TPDUE_BASE_F from fii_ar_net_rec_base_mv has been populated successfully');
    FII_UTIL.Write_Log ('Inserted ' || SQL%ROWCOUNT || ' rows');
    FII_UTIL.print_timer();
  END IF;
 commit;
 --------------------------------------------------------------------------
 --Insert data FROM fii_ar_disputes_base_mv  by joining
 -- to fii_time_structures, fii_customer_hierarchies, hz_parties
 --Here we calculate ITD amounts for date on which the job is run
 --fii_customer_hierarchies and hz_parties is used to avoid
 --costly GT table population while running the report
 --------------------------------------------------------------------------


 insert /*+ append */ INTO FII_AR_TPDUE_BASE_F
  ( parent_party_id,
		party_id,
		collector_id,
		org_id,
		IS_LEAF_FLAG,
		IS_SELF_FLAG,
		VIEW_BY,
		VIEWBY_CODE,
		CUST_NEXT_LEVEL_PARTY_ID,
		CUST_PARENT_PARTY_ID,
		CUST_CHILD_PARTY_ID,
		past_due_dispute_amount_func,
    past_due_dispute_amount_prim,
    past_due_dispute_amount_sec,
		LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN)
    SELECT parent_party_id,
    party_id,
    collector_id,
    org_id,
    is_leaf_flag,
    is_self_flag,
    VIEW_BY,
		VIEWBY_CODE,
		CUST_NEXT_LEVEL_PARTY_ID,
		CUST_PARENT_PARTY_ID,
		CUST_CHILD_PARTY_ID,
	  SUM(past_due_dispute_amount_func)   past_due_dispute_amount_func,
    SUM(past_due_dispute_amount_prim)   past_due_dispute_amount_prim,
    SUM(past_due_dispute_amount_sec)    past_due_dispute_amount_sec,
    g_fii_sysdate,
    g_fii_user_id,
    g_fii_sysdate,
    g_fii_user_id,
    g_fii_login_id FROM (
 SELECT
       b.parent_party_id parent_party_id,
		   b.party_id party_id,
		   b.collector_id collector_id,
		   b.org_id org_id,
		   cust.next_level_is_leaf_flag is_leaf_flag,
		   case when cust.parent_party_id = hz.party_id
 				 and cust.next_level_is_leaf_flag <> 'Y'
			   then 'Y'
		 	 else 'N' end is_self_flag,
		 	  case when cust.parent_party_id = hz.party_id
 				 and cust.next_level_is_leaf_flag <> 'Y'
			   then hz.party_name ||g_self_msg else hz.party_name end view_by,
			 hz.party_id viewby_code,
			 cust.next_level_party_id cust_next_level_party_id,
			 cust.parent_party_id cust_parent_party_id,
		   cust.child_party_id cust_child_party_id,
			 past_due_dispute_amount_func,
       past_due_dispute_amount_prim,
       past_due_dispute_amount_sec
FROM   fii_time_structures cal,
       fii_ar_disputes_base_mv  b,
        FII_CUSTOMER_HIERARCHIES cust,
       HZ_PARTIES hz
WHERE  cal.report_date     = l_this_date
    AND cal.time_id        = b.time_id
    AND cal.period_type_id = b.period_type_id
    AND bitand(cal.record_type_id, 512) = 512
    AND cust.parent_party_id = b.parent_party_id
    AND cust.child_party_id  = b.party_id
    AND cust.next_level_party_id = hz.party_id
    )
  GROUP BY parent_party_id,
    party_id,
    collector_id,
    org_id,
    is_leaf_flag,
    is_self_flag,
    VIEW_BY,
		VIEWBY_CODE,
	  CUST_NEXT_LEVEL_PARTY_ID,
		CUST_PARENT_PARTY_ID,
		CUST_CHILD_PARTY_ID;



  IF g_debug_flag = 'Y' THEN
    FII_UTIL.stop_timer();
    FII_UTIL.Write_Log ('FII_AR_TPDUE_BASE_F has been populated from fii_ar_disputes_base_mv successfully');
    FII_UTIL.Write_Log ('Inserted ' || SQL%ROWCOUNT || ' rows');
    FII_UTIL.print_timer();
  END IF;

  g_phase := 'Gather table stats for FII_AR_TPDUE_BASE_F';
  fnd_stats.gather_table_stats (ownname=>g_schema_name,
                                tabname=>'FII_AR_TPDUE_BASE_F');

  g_phase := 'Commit the change';
  commit;

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.Write_Log ('< Leaving FII_AR_TPDUE_BASE_F');
    FII_UTIL.Write_Log (' ');
  END IF;

 EXCEPTION
  WHEN no_data_found THEN
    FII_MESSAGE.write_log(
			msg_name	=> 'Data Not Found',
			token_num	=> 0);
    raise;

  WHEN OTHERS THEN
    FII_UTIL.Write_Log ('Other error in REFRESH_AR_TPDUE_BASE_F ');
    FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
    FII_UTIL.Write_Log ('-->'|| sqlcode ||':'|| substr(sqlerrm,1,180));
    rollback;
    raise;

 END REFRESH_AR_TPDUE_BASE_F;


----------------------------------------------------
-- PROCEDURE REFRESH_AR_TPDUE_AGRT_F  (private)
--
-- This procedure will (fully) refresh table FII_AR_TPDUE_AGRT_F
-- FROM FII_AR_NET_REC_AGRT_MV AND FII_AR_DISPUTES_AGRT_MV
----------------------------------------------------
 PROCEDURE REFRESH_AR_TPDUE_AGRT_F IS

   l_this_date     DATE;
   l_pp_this_date  DATE;
   l_pq_this_date  DATE;
   l_ly_this_date  DATE;
   l_min_start_date DATE;

 BEGIN

  g_phase := 'Entering FII_AR_TPDUE_AGRT_F';
  IF g_debug_flag = 'Y' THEN
    FII_UTIL.Write_Log ('> Entering FII_AR_TPDUE_AGRT_F');
    FII_UTIL.start_timer();
  END IF;


  g_phase := 'Populate l_this_date FROM BIS_SYSTEM_DATE';

  --We use a un-shipped profile option FII_TEST_SYSDATE ("FII: Test Sysdate")
  --to reset different sysdate so that we can test for snapshot tables.
  if g_test_sysdate is NULL THEN
    SELECT trunc(CURRENT_DATE_ID) INTO l_this_date
      FROM BIS_SYSTEM_DATE;
  ELSE
    l_this_date := g_test_sysdate;
  end if;


/*
sysdate = 20-Jul-2006

l_pp_this_date = 19-Jun-2006
l_pq_this_date = 19-Apr-2006
l_ly_this_date = 20-Jul-2005
l_this_date_gov = 31-Jul-2006
*/

/*
SELECT	NVL(fii_time_api.ent_sd_pper_end(l_this_date),l_min_start_date),
	NVL(fii_time_api.ent_sd_pqtr_end(l_this_date),l_min_start_date),
	NVL(fii_time_api.ent_sd_lyr_end(l_this_date),l_min_start_date),
	NVL( fii_time_api.ent_cper_end(l_this_date),l_min_start_date)

INTO	l_pp_this_date,
	l_pq_this_date,
	l_ly_this_date,
	l_this_date_gov

FROM	DUAL;*/

  IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('>> l_this_date = '     || l_this_date);
 END IF;

  --Always do a full refresh for snapshot tables
  g_phase := 'Truncate table FII_AR_TPDUE_AGRT_F';
  FII_UTIL.truncate_table ('FII_AR_TPDUE_AGRT_F', 'FII', g_retcode);

  g_phase := 'Starting to populate table FII_AR_TPDUE_AGRT_F';
  IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('>> Starting to populate table FII_AR_TPDUE_AGRT_F');
  END IF;


 --------------------------------------------------------------------------
 --Insert data FROM fii_ar_net_rec_base_mv  by joining
 -- to fii_time_structures, fii_customer_hierarchies, hz_parties
 --Here we calculate ITD amounts for date on which the job is run
 --fii_customer_hierarchies and hz_parties is used to avoid
 --costly GT table population while running the report
 --------------------------------------------------------------------------

 insert /*+ append */ INTO FII_AR_TPDUE_AGRT_F
  ( parent_party_id,
		party_id,
		collector_id,
		org_id,
		IS_LEAF_FLAG,
		IS_SELF_FLAG,
		VIEW_BY,
		VIEWBY_CODE,
		CUST_NEXT_LEVEL_PARTY_ID,
		CUST_PARENT_PARTY_ID,
		CUST_CHILD_PARTY_ID,
	  past_due_open_amount_func,
		past_due_open_amount_prim,
		past_due_open_amount_sec,
	  wtd_terms_out_open_num_func,
		wtd_terms_out_open_num_prim,
		wtd_terms_out_open_num_sec,
		wtd_DDSO_due_num_func,
    wtd_DDSO_due_num_prim,
    wtd_DDSO_due_num_sec,
    current_open_amount_func,
		current_open_amount_prim,
		current_open_amount_sec,
	   LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN)
     SELECT
       parent_party_id,
		   party_id,
		   collector_id,
		   org_id,
		   IS_LEAF_FLAG,
			 IS_SELF_FLAG,
		   VIEW_BY,
		   VIEWBY_CODE,
		   CUST_NEXT_LEVEL_PARTY_ID,
			 CUST_PARENT_PARTY_ID,
		   CUST_CHILD_PARTY_ID,
		   SUM(past_due_open_amount_func) past_due_open_amount_func,
       SUM(past_due_open_amount_prim)    past_due_open_amount_prim,
			 SUM(past_due_open_amount_sec)     past_due_open_amount_sec,
	     SUM(wtd_terms_out_open_num_func) wtd_terms_out_open_num_func,
		   SUM(wtd_terms_out_open_num_prim) wtd_terms_out_open_num_prim,
		   SUM(wtd_terms_out_open_num_sec) wtd_terms_out_open_num_sec,
		   SUM(wtd_DDSO_due_num_func) wtd_DDSO_due_num_func,
       SUM(wtd_DDSO_due_num_prim) wtd_DDSO_due_num_prim,
       SUM(wtd_DDSO_due_num_sec) wtd_DDSO_due_num_sec,
       SUM(current_open_amount_func)    current_open_amount_func,
		   SUM(current_open_amount_prim)    current_open_amount_prim,
		   SUM(current_open_amount_sec)     current_open_amount_sec,
       g_fii_sysdate,
       g_fii_user_id,
       g_fii_sysdate,
       g_fii_user_id,
       g_fii_login_id FROM (
 			 SELECT
       b.parent_party_id,
		   b.party_id,
		   b.collector_id,
		   b.org_id,
		   cust.next_level_is_leaf_flag is_leaf_flag,
		   case when cust.parent_party_id = hz.party_id
 				 and cust.next_level_is_leaf_flag <> 'Y'
			   then 'Y'
		 	   else 'N' end is_self_flag,
		 	 case when cust.parent_party_id = hz.party_id
 				 and cust.next_level_is_leaf_flag <> 'Y'
			   then hz.party_name ||g_self_msg else hz.party_name end view_by,
			 hz.party_id viewby_code,
			 cust.next_level_party_id cust_next_level_party_id,
			 cust.parent_party_id cust_parent_party_id,
		   cust.child_party_id cust_child_party_id,
			 past_due_open_amount_func,
       past_due_open_amount_prim,
			 past_due_open_amount_sec,
	     wtd_terms_out_open_num_func,
		   wtd_terms_out_open_num_prim,
		   wtd_terms_out_open_num_sec,
		   wtd_DDSO_due_num_func,
       wtd_DDSO_due_num_prim,
       wtd_DDSO_due_num_sec,
       current_open_amount_func,
		   current_open_amount_prim,
		   current_open_amount_sec
FROM   fii_time_structures cal,
       fii_ar_net_rec_agrt_mv  b,
       FII_CUSTOMER_HIERARCHIES cust,
       HZ_PARTIES hz
WHERE  cal.report_date     = l_this_date
    AND cal.time_id        = b.time_id
    AND cal.period_type_id = b.period_type_id
    AND bitand(cal.record_type_id, 512) = 512
    AND cust.child_party_id = b.party_id
    AND b.parent_party_id in (SELECT decode (cust1.next_level_is_leaf_flag,
     													'Y', cust1.parent_party_id, cust.child_party_id)
     													FROM fii_customer_hierarchies cust1
     													WHERE cust1.next_level_party_id = cust.child_party_id
     													AND cust1.child_party_id 				= cust.child_party_id
     													AND cust1.child_party_id			 <> cust1.parent_party_id)
   AND cust.next_level_party_id = hz.party_id
   AND b.gid = 1025
   )
  GROUP BY parent_party_id,
		       party_id,
		       collector_id,
		       org_id,
		       IS_LEAF_FLAG,
					 IS_SELF_FLAG,
					 VIEW_BY,
					 VIEWBY_CODE,
					 CUST_NEXT_LEVEL_PARTY_ID,
		       CUST_PARENT_PARTY_ID,
		       CUST_CHILD_PARTY_ID;



  IF g_debug_flag = 'Y' THEN
    FII_UTIL.stop_timer();
    FII_UTIL.Write_Log ('FII_AR_TPDUE_AGRT_F from fii_ar_net_rec_agrt_mv has been populated successfully');
    FII_UTIL.Write_Log ('Inserted ' || SQL%ROWCOUNT || ' rows');
    FII_UTIL.print_timer();
  END IF;
  commit;
 --------------------------------------------------------------------------
 --Insert data FROM fii_ar_disputes_agrt_mv  by joining
 -- to fii_time_structures, fii_customer_hierarchies, hz_parties
 --Here we calculate ITD amounts for date on which the job is run
 --fii_customer_hierarchies and hz_parties is used to avoid
 --costly GT table population while running the report
 --------------------------------------------------------------------------


 insert /*+ append */ INTO FII_AR_TPDUE_AGRT_F
  ( parent_party_id,
		party_id,
		collector_id,
		org_id,
		IS_LEAF_FLAG,
		IS_SELF_FLAG,
		VIEW_BY,
		VIEWBY_CODE,
	  CUST_NEXT_LEVEL_PARTY_ID,
		CUST_PARENT_PARTY_ID,
		CUST_CHILD_PARTY_ID,
		past_due_dispute_amount_func,
    past_due_dispute_amount_prim,
    past_due_dispute_amount_sec,
		 LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN)
     SELECT
       parent_party_id,
		   party_id,
		   collector_id,
		   org_id,
		   IS_LEAF_FLAG,
			 IS_SELF_FLAG,
			 VIEW_BY,
			 VIEWBY_CODE,
	     CUST_NEXT_LEVEL_PARTY_ID,
		   CUST_PARENT_PARTY_ID,
		   CUST_CHILD_PARTY_ID,
			 SUM(past_due_dispute_amount_func)   past_due_dispute_amount_func,
       SUM(past_due_dispute_amount_prim)   past_due_dispute_amount_prim,
       SUM(past_due_dispute_amount_sec)    past_due_dispute_amount_sec,
       g_fii_sysdate,
       g_fii_user_id,
       g_fii_sysdate,
       g_fii_user_id,
       g_fii_login_id FROM(
     	 SELECT
       b.parent_party_id,
		   b.party_id,
		   b.collector_id,
		   b.org_id,
		   cust.next_level_is_leaf_flag is_leaf_flag,
		   case when cust.parent_party_id = hz.party_id
 				 and cust.next_level_is_leaf_flag <> 'Y'
			   then 'Y'
		 	 else 'N' end is_self_flag,
		 	 case when cust.parent_party_id = hz.party_id
 				 and cust.next_level_is_leaf_flag <> 'Y'
			   then hz.party_name  ||g_self_msg else hz.party_name end view_by,
			 hz.party_id viewby_code,
			 cust.next_level_party_id cust_next_level_party_id,
			 cust.parent_party_id cust_parent_party_id,
		   cust.child_party_id cust_child_party_id,
			 past_due_dispute_amount_func   past_due_dispute_amount_func,
       past_due_dispute_amount_prim   past_due_dispute_amount_prim,
       past_due_dispute_amount_sec    past_due_dispute_amount_sec
FROM   fii_time_structures cal,
       fii_ar_disputes_agrt_mv  b,
       FII_CUSTOMER_HIERARCHIES cust,
       HZ_PARTIES hz
WHERE  cal.report_date     = l_this_date
    AND cal.time_id        = b.time_id
    AND cal.period_type_id = b.period_type_id
    AND bitand(cal.record_type_id, 512) = 512
    AND cust.child_party_id = b.party_id
    AND b.parent_party_id in (SELECT decode (cust1.next_level_is_leaf_flag,
     													'Y', cust1.parent_party_id, cust.child_party_id)
     													FROM fii_customer_hierarchies cust1
     													WHERE cust1.next_level_party_id = cust.child_party_id
     													AND cust1.child_party_id 				= cust.child_party_id
     													AND cust1.child_party_id			 <> cust1.parent_party_id)
   AND cust.next_level_party_id = hz.party_id)
  GROUP BY parent_party_id,
		       party_id,
		       collector_id,
		       org_id,
		       IS_LEAF_FLAG,
					 IS_SELF_FLAG,
					 VIEW_BY,
					 VIEWBY_CODE,
					 CUST_NEXT_LEVEL_PARTY_ID,
		CUST_PARENT_PARTY_ID,
		CUST_CHILD_PARTY_ID;


  IF g_debug_flag = 'Y' THEN
    FII_UTIL.stop_timer();
    FII_UTIL.Write_Log ('FII_AR_TPDUE_AGRT_F has been populated from fii_ar_disputes_agrt_mv successfully');
    FII_UTIL.Write_Log ('Inserted ' || SQL%ROWCOUNT || ' rows');
    FII_UTIL.print_timer();
  END IF;

  g_phase := 'Gather table stats for FII_AR_TPDUE_AGRT_F';
  fnd_stats.gather_table_stats (ownname=>g_schema_name,
                                tabname=>'FII_AR_TPDUE_AGRT_F');

  g_phase := 'Commit the change';
  commit;

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.Write_Log ('< Leaving FII_AR_TPDUE_AGRT_F');
    FII_UTIL.Write_Log (' ');
  END IF;

 EXCEPTION
  WHEN no_data_found THEN
    FII_MESSAGE.write_log(
			msg_name	=> 'Data Not Found',
			token_num	=> 0);
    raise;

  WHEN OTHERS THEN
    FII_UTIL.Write_Log ('Other error in REFRESH_AR_TPDUE_AGRT_F ');
    FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
    FII_UTIL.Write_Log ('-->'|| sqlcode ||':'|| substr(sqlerrm,1,180));
    rollback;
    raise;

 END REFRESH_AR_TPDUE_AGRT_F;



----------------------------------------------------------
-- PROCEDURE MAIN  (public)
--
-- This procedure will (fully) refresh all snapshot tables
----------------------------------------------------------
 PROCEDURE Main (errbuf                IN OUT NOCOPY VARCHAR2,
                 retcode               IN OUT NOCOPY VARCHAR2) IS

   ret_val             BOOLEAN := FALSE;

 Begin

     g_phase := 'Entering Main';
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Entering Main');
     END IF;

     g_phase := 'Calling Initialize';
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Calling Initialize');
     END IF;

   Initialize;

     g_phase := 'Populating FII_AR_TPDUE_BASE_F';
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Populating FII_AR_TPDUE_BASE_F');
     END IF;

   REFRESH_AR_TPDUE_BASE_F;

    g_phase := 'Populating FII_AR_TPDUE_AGRT_F';
     IF g_debug_flag = 'Y' THEN
       FII_UTIL.Write_Log ('Populating FII_AR_TPDUE_AGRT_F');
     END IF;

   REFRESH_AR_TPDUE_AGRT_F;


   g_phase := 'Exiting after successful completion';
   IF g_debug_flag = 'Y' THEN
     FII_UTIL.Write_Log ('Exiting after successful completion');
   END IF;


 EXCEPTION

  WHEN OTHERS THEN

    FII_UTIL.Write_Log ('Other error in Main ');
    FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
    FII_UTIL.Write_Log ('-->'|| sqlcode ||':'|| substr(sqlerrm,1,180));

    FND_CONCURRENT.Af_Rollback;
    retcode := sqlcode;
    errbuf  := sqlerrm;
    ret_val := FND_CONCURRENT.Set_Completion_Status
	           (status => 'ERROR', message => substr(errbuf,1,180));

 END Main;


END FII_AR_TPDUE_TBL_REFRESH;

/
