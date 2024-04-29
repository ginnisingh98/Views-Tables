--------------------------------------------------------
--  DDL for Package Body FII_AR_COLLECTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_COLLECTORS_PKG" AS
/* $Header: FIIARCOLLB.pls 120.7.12000000.2 2007/03/16 20:51:22 vkazhipu ship $ */

        g_phase                VARCHAR2(120);
        g_schema_name          VARCHAR2(120)   := 'FII';
        g_retcode              VARCHAR2(20)    := NULL;
        g_debug_mode           VARCHAR2(1)
                     := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
 --added by vkazhipu for bug 5763652
        g_collection_to_date DATE := SYSDATE;
-- *******************************************************************
--   Initialize (get log file directory and login details)

   PROCEDURE Initialize  IS
         l_dir        VARCHAR2(160);

   BEGIN

     IF (FIIDIM_Debug) THEN
	FII_MESSAGE.Func_Ent ('FII_AR_COLLECTORS_PKG.Initialize');
     END IF;

     g_phase := 'Do set up for log file';
     ----------------------------------------------
     -- Do set up for log file
     ----------------------------------------------

     l_dir := fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY');
     ------------------------------------------------------
     -- Set default directory in case if the profile option
     -- BIS_DEBUG_LOG_DIRECTORY is not set up
     ------------------------------------------------------
     IF l_dir IS NULL then
       l_dir := FII_UTIL.get_utl_file_dir;
     END IF;

     ----------------------------------------------------------------
     -- FII_UTIL.initialize will set up the directory where
     -- the log files and output files are written to
     ----------------------------------------------------------------
     FII_UTIL.initialize('FII_AR_COLLECTORS_PKG.log',
                         'FII_AR_COLLECTORS_PKG.out',l_dir,'FII_AR_COLLECTORS_PKG');


       -- Obtain FII schema name
     g_phase := 'Obtain Schema name, User ID, Login ID';
     g_schema_name := FII_UTIL.get_schema_name ('FII');

     -- Obtain user ID, login ID and initialize package variables
     FII_USER_ID 	:= FND_GLOBAL.USER_ID;
     FII_LOGIN_ID	:= FND_GLOBAL.LOGIN_ID;

     -- If any of the above values is not set, error out
     IF (FII_USER_ID is NULL OR FII_LOGIN_ID is NULL) THEN
       FII_UTIL.Write_Log ('>>> Failed Initialization');
       RAISE CODIM_fatal_err;
     END IF;

     -- Turn trace on if process is running in debug mode
     IF (FIIDIM_Debug) THEN
       -- Program running in debug mode, turning trace on
       EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';
       FII_UTIL.Write_Log ('Initialize: Set Trace On');
	FII_MESSAGE.Func_Succ ('FII_AR_COLLECTORS_PKG.Initialize');
     END IF;

   EXCEPTION

  WHEN CODIM_fatal_err THEN
       FII_UTIL.Write_Log ('FII_AR_COLLECTORS_PKG.Initialize : '|| 'User defined error');
       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name => 'FII_AR_COLLECTORS_PKG.Initialize');
       RAISE;

     WHEN OTHERS THEN
        FII_UTIL.Write_Log ('Unexpected error when calling Initialize...');
        FII_UTIL.Write_Log ( 'g_phase: ' || g_phase);
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
        RAISE;

   END Initialize;

 -- **************************************************************************
-- This is the main procedure of Collector dimension program in Initial mode.

   PROCEDURE Init_Load (errbuf		OUT NOCOPY VARCHAR2,
	 	        retcode		OUT NOCOPY VARCHAR2) IS

    ret_val      BOOLEAN := FALSE;
    l_max_batch_party_id NUMBER (15);

  BEGIN

     -- Determine if process will be run in debug mode
     IF (NVL(g_debug_mode, 'N') <> 'N') THEN
       FIIDIM_Debug := TRUE;
     ELSE
       FIIDIM_Debug := FALSE;
     END IF;

     IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Ent(func_name => 'FII_AR_COLLECTORS_PKG.Init_Load');
       FII_UTIL.Write_Log (' Debug On');
     ELSE
	FII_UTIL.Write_Log (' Debug Off');
      END IF;

    --First do the initialization

      Initialize;

   --Added by vkazhipu for customer bug 5763652
   --added for registering the program name
   --used in BIS_REFRESH_LOG

   IF(NOT BIS_COLLECTION_UTILITIES.setup('FII_DIM_COLL_INIT_C')) THEN
           raise_application_error(-20000, errbuf);
           return;
     END IF;


     g_phase := 'Populating COLL_BATCH_PARTY_ID in fii_change_log';
     IF (FIIDIM_Debug) THEN
       FII_UTIL.Write_Log(g_phase);
     End if;

          select nvl(max(batch_party_id), -1)
          into l_max_batch_party_id
          from hz_merge_party_history m,
               hz_merge_dictionary d
          where m.merge_dict_id = d.merge_dict_id
          and d.entity_name = 'HZ_PARTIES';

          INSERT INTO fii_change_log
          (log_item, item_value, CREATION_DATE, CREATED_BY,
           LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
          (SELECT 'COLL_MAX_BATCH_PARTY_ID',
                l_max_batch_party_id,
                sysdate,        --CREATION_DATE,
                fii_user_id,  --CREATED_BY,
                sysdate,        --LAST_UPDATE_DATE,
                fii_user_id,  --LAST_UPDATED_BY,
                fii_login_id  --LAST_UPDATE_LOGIN
           FROM DUAL
           WHERE NOT EXISTS
              (select 1 from fii_change_log
               where log_item = 'COLL_MAX_BATCH_PARTY_ID'));

          IF (SQL%ROWCOUNT = 0) THEN
              UPDATE fii_change_log
              SET item_value = l_max_batch_party_id,
                  last_update_date  = sysdate,
                  last_update_login = fii_login_id,
                  last_updated_by   = fii_user_id
              WHERE log_item = 'COLL_MAX_BATCH_PARTY_ID';
          END IF;


      IF (FIIDIM_Debug) THEN
       FII_UTIL.Write_Log ('Now start processing '|| 'Collector dimension');
      END IF;

      --Secondly populate the table FII_COLLECTORS

    g_phase := 'populating FII_COLLECTORS table';

    FII_UTIL.truncate_table ('FII_COLLECTORS', 'FII', g_retcode);

 /* For transactions, the AR UI requires the account and site use to be specified. However, for receipts,
 it can be created with just the account information. Hence, in first sql, apart from picking up
 non-null site_use_ids to get the collectors assigned at the site level, we do NVL(site_use_id, -2)
to get the collector for a receipt that has only a customer account assigned to it. */

 /* second sql gets all collectors assigned at the account level */

/* Bug 5019882. Records with cust_account_id = -2 may be seeded accounts and
we don't need to pick them up. So, added > 0 check to filter such records.. */


-- Added following statement for performance bug 5093270

   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
 --added last_update_date filter by vkazhipu for bug 5763652
	INSERT  /*+ APPEND PARALLEL(COLL) */ INTO FII_COLLECTORS COLL
		       (party_id,
			cust_account_id,
		        site_use_id,
			collector_id,
		        creation_date,
		        created_by,
		        last_update_date,
		        last_updated_by,
		        last_update_login)

		SELECT	/*+ PARALLEL(prof) */
			NVL(prof.party_id,-2),
			prof.cust_account_id,
			NVL(site_use_id,-2),
			prof.collector_id,
			SYSDATE,
			FII_USER_ID,
			SYSDATE,
			FII_USER_ID,
			FII_LOGIN_ID
		FROM	hz_customer_profiles prof
		WHERE   prof.cust_account_id > 0
		AND prof.last_update_date <= g_collection_to_date
		UNION ALL

		-- site_use_code DRAWEE is for Bills Receivable
SELECT	/*+ PARALLEL(prof) PARALLEL(acct) PARALLEL(sites) PARALLEL(uses) */
			NVL(prof.party_id,-2),
			prof.cust_account_id,
			uses.site_use_id,
			prof.collector_id,
			SYSDATE,
			FII_USER_ID,
			SYSDATE,
			FII_USER_ID,
			FII_LOGIN_ID
		FROM	hz_customer_profiles prof,
		        hz_cust_accounts acct,
		        hz_cust_acct_sites_all sites,
		        hz_cust_site_uses_all uses
		WHERE	prof.site_use_id IS NULL
			AND acct.cust_account_id = prof.cust_account_id
			AND acct.cust_account_id = sites.cust_account_id
			AND sites.cust_acct_site_id = uses.cust_acct_site_id
			AND uses.site_use_code IN ('BILL_TO','DRAWEE')
			AND prof.last_update_date <= g_collection_to_date
			AND NOT EXISTS (SELECT	/*+ PARALLEL(profs) */
						cust_account_id, site_use_id
					FROM	hz_customer_profiles profs
					WHERE	site_use_id IS NOT NULL
                            and acct.cust_account_id = profs.cust_account_id
                            and uses.site_use_id = profs.site_use_id
                            AND profs.last_update_date <= g_collection_to_date);

        IF (FIIDIM_Debug) THEN
        	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows IN FII_COLLECTORS');
        END IF;

-- Statistics for FII_COLLECTORS will be anyway gathered via RSG so NOT gathering stats in the program

-- Since FII_COLLECTORS is used in MV query,  we need to gather statistics for its MLOG as well

       g_phase := 'gather_table_stats for MLOG$_FII_COLLECTORS';
       FND_STATS.gather_table_stats
  	       (ownname	=> g_schema_name,
	        tabname	=> 'MLOG$_FII_COLLECTORS');

     FND_CONCURRENT.Af_Commit;

     IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Succ(func_name => 'FII_AR_COLLECTORS_PKG.Init_Load');
     END IF;

       --Added by vkazhipu for customer bug 5763652

      BIS_COLLECTION_UTILITIES.wrapup(
       p_status => TRUE,
       p_period_from => BIS_COMMON_PARAMETERS.Get_Global_Start_Date,
       p_period_to => g_collection_to_date);


    -- Exception handling

  EXCEPTION

    WHEN CODIM_fatal_err THEN

      FII_UTIL.Write_Log ('FII_AR_COLLECTORS_PKG.Init_Load: '||
                        'User defined error');

      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_AR_COLLECTORS_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN OTHERS THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log (
          'Other error IN FII_AR_COLLECTORS_PKG.Init_Load: ' || substr(sqlerrm,1,180));


      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_AR_COLLECTORS_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

   END Init_Load;

-- *****************************************************************

-- This is the main procedure of collector dimension program in Incremental mode.

   PROCEDURE Incre_Update (errbuf		OUT NOCOPY VARCHAR2,
	 	           retcode		OUT NOCOPY VARCHAR2) IS

	ret_val             BOOLEAN := FALSE;
	l_last_update_join VARCHAR2(300);
	l_last_update_join1 VARCHAR2(300);
	l_last_update_join2 VARCHAR2(300);
	l_last_start_date    DATE := NULL;
	l_last_end_date      DATE := NULL;
	l_last_period_from   DATE := NULL;
	l_last_period_to     DATE := NULL;
	l_last_period_to_incr     DATE := NULL;
	l_last_period_to_init     DATE := NULL;
	l_stmt VARCHAR2(32000);
        l_max_batch_party_id NUMBER(15);

   BEGIN

       -- Determine if process will be run in debug mode
     IF (NVL(g_debug_mode, 'N') <> 'N') THEN
       FIIDIM_Debug := TRUE;
     ELSE
       FIIDIM_Debug := FALSE;
     END IF;

     IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Ent(func_name => 'FII_AR_COLLECTORS_PKG.Incre_Update');
       FII_UTIL.Write_Log (' Debug On');
     ELSE
	FII_UTIL.Write_Log (' Debug Off');
      END IF;


    --First do the initialization

      Initialize;

     g_phase := 'Getting maximum batch_party_id from fii_change_log table';
     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log (g_phase);
     END IF;

        select item_value
        into l_max_batch_party_id
        from fii_change_log
        where log_item = 'COLL_MAX_BATCH_PARTY_ID';

     FII_UTIL.Write_Log ('COLL_MAX_BATCH_PARTY_ID = '||l_max_batch_party_id);

    g_phase := 'Deleting merged parties.';
    IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log (g_phase);
    END IF;

        Delete from fii_collectors
        where party_id in
        (select from_entity_id
        from hz_merge_party_history m,
             hz_merge_dictionary d
        where m.merge_dict_id = d.merge_dict_id
        and d.entity_name = 'HZ_PARTIES'
        and batch_party_id > l_max_batch_party_id);

    g_phase := 'Logging maximum batch_party_id into fii_change_log table';
     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log (g_phase);
     END IF;

    select nvl(max(batch_party_id), -1)
    into l_max_batch_party_id
    from hz_merge_party_history m,
         hz_merge_dictionary d
    where m.merge_dict_id = d.merge_dict_id
    and d.entity_name = 'HZ_PARTIES';



    INSERT INTO fii_change_log
    (log_item, item_value, CREATION_DATE, CREATED_BY,
     LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
    (SELECT 'COLL_MAX_BATCH_PARTY_ID',
          l_max_batch_party_id,
          sysdate,        --CREATION_DATE,
          fii_user_id,  --CREATED_BY,
          sysdate,        --LAST_UPDATE_DATE,
          fii_user_id,  --LAST_UPDATED_BY,
          fii_login_id  --LAST_UPDATE_LOGIN
     FROM DUAL
     WHERE NOT EXISTS
        (select 1 from fii_change_log
         where log_item = 'COLL_MAX_BATCH_PARTY_ID'));

    IF (SQL%ROWCOUNT = 0) THEN
        UPDATE fii_change_log
        SET item_value = l_max_batch_party_id,
            last_update_date  = sysdate,
            last_update_login = fii_login_id,
            last_updated_by   = fii_user_id
        WHERE log_item = 'COLL_MAX_BATCH_PARTY_ID';
    END IF;

    FND_CONCURRENT.Af_Commit;

    IF (FIIDIM_Debug) THEN
       FII_UTIL.Write_Log ('Now start processing Collector dimension');
    END IF;

	g_phase := 'Getting last refresh dates';

	IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log ( 'g_phase: ' || g_phase);
        END IF;

--Added by vkazhipu for customer bug 5763652

IF(NOT BIS_COLLECTION_UTILITIES.setup('FII_DIM_COLL_INCRE_C')) THEN
           raise_application_error(-20000, errbuf);
           return;
     END IF;

BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_DIM_COLL_INIT_C',
                                                   l_last_start_date, l_last_end_date,
                                                   l_last_period_from, l_last_period_to_init);


BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_DIM_COLL_INCRE_C',
                                                   l_last_start_date, l_last_end_date,
                                                   l_last_period_from, l_last_period_to_incr);


--BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_COLLECTORS',
--                                                  l_last_start_date,
 --                                                 l_last_end_date,
--                                                  l_last_period_from,
 --                                                 l_last_period_to);
	-- --------------------------------------------------------------------------
	-- l_last_period_to is the 'period to' parameter of the most recent initial load.
	-- If it is null, it is set to the global start date.
	-- The incremental load will not pick up collector assignments done before global start date.
	-- --------------------------------------------------------------------------

l_last_period_to := GREATEST(NVL(l_last_period_to_init, BIS_COMMON_PARAMETERS.Get_Global_Start_Date),
                           NVL(l_last_period_to_incr, BIS_COMMON_PARAMETERS.Get_Global_Start_Date));


	IF(l_last_period_to IS NULL) THEN
           l_last_period_to := bis_common_parameters.get_global_start_date;
        END IF;

	IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log ( 'last refresh date is ' || l_last_period_to);

        END IF;

	l_last_update_join := 'AND TRUNC(prof.last_update_date) >=''' ||l_last_period_to||''' AND TRUNC(prof.last_update_date) <=''' ||g_collection_to_date||'''';
	l_last_update_join1 := 'WHERE TRUNC(prof.last_update_date) >=''' ||l_last_period_to||''' AND TRUNC(prof.last_update_date) <=''' ||g_collection_to_date||'''';
	l_last_update_join2 := 'AND TRUNC(profs.last_update_date) >=''' ||l_last_period_to||''' AND TRUNC(profs.last_update_date) <=''' ||g_collection_to_date||'''';

 /* For transactions, the AR UI requires the account and site use to be specified. However, for receipts,
 it can be created with just the account information. Hence, in first sql, apart from picking up
 non-null site_use_ids to get the collectors assigned at the site level, we do NVL(site_use_id, -2)
to get the collector for a receipt that has only a customer account assigned to it. */

 /* second sql gets all collectors assigned at the account level */

     -- Incremental Dimension Maintence
     --	The sql in USING clause only considers the records changed after the
     -- date of last initial/incremental run. The records thus obtained are
     -- merged into the dimension table FII_COLLECTORS using MERGE command.
     -- The changed records are updated whereas new records are inserted into FII_COLLECTORS.

/* Bug 5019882. Records with cust_account_id = -2 may be seeded accounts and
we don't need to pick them up. So, added > 0 check to filter such records.. */

-- Added following statement for performance bug 5093270

   EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

	l_stmt := 'MERGE INTO FII_COLLECTORS dim
	USING (SELECT	NVL(prof.party_id,-2) party_id,
			prof.cust_account_id cust_account_id,
			NVL(site_use_id,-2) site_use_id,
			prof.collector_id collector_id,
			SYSDATE creation_date,
			'||FII_USER_ID||' created_by,
			SYSDATE last_update_date,
			'||FII_USER_ID||' last_updated_by,
			'||FII_LOGIN_ID||' last_update_login

		FROM	hz_customer_profiles prof

			'||l_last_update_join1||'
			AND prof.cust_account_id > 0

		UNION ALL

		SELECT	NVL(prof.party_id,-2) party_id,
			prof.cust_account_id cust_account_id,
			uses.site_use_id site_use_id,
			prof.collector_id collector_id,
			SYSDATE creation_date,
			'||FII_USER_ID||' created_by,
			SYSDATE last_update_date,
			'||FII_USER_ID||' last_updated_by,
			'||FII_LOGIN_ID||' last_update_login

		FROM	hz_customer_profiles prof,
		        hz_cust_accounts acct,
		        hz_cust_acct_sites_all sites,
		        hz_cust_site_uses_all uses

		WHERE	 prof.site_use_id IS NULL
			 AND acct.cust_account_id = prof.cust_account_id
			 AND acct.cust_account_id = sites.cust_account_id
			 AND sites.cust_acct_site_id = uses.cust_acct_site_id
			 AND uses.site_use_code IN (''BILL_TO'',''DRAWEE'')
			 AND NOT EXISTS (SELECT	  cust_account_id, site_use_id
					 FROM	  hz_customer_profiles profs
				         WHERE	  site_use_id IS NOT NULL
					          and acct.cust_account_id = profs.cust_account_id
			                          and uses.site_use_id = profs.site_use_id
					          '||l_last_update_join2||'
					)
			 '||l_last_update_join||') inline

	-- ON (dim.party_id = inline.party_id and dim.cust_account_id = inline.cust_account_id AND dim.site_use_id = inline.site_use_id)
	ON (dim.cust_account_id = inline.cust_account_id AND dim.site_use_id = inline.site_use_id)
	WHEN MATCHED THEN UPDATE SET	dim.collector_id = inline.collector_id,
					                dim.party_id = inline.party_id,
					dim.creation_date = inline.creation_date,
					dim.created_by = inline.created_by,
					dim.last_update_date = inline.last_update_date,
				        dim.last_updated_by = inline.last_updated_by,
				        dim.last_update_login = inline.last_update_login
	WHEN NOT MATCHED THEN INSERT (	dim.party_id,
					dim.cust_account_id,
					dim.site_use_id,
					dim.collector_id,
					dim.creation_date,
					dim.created_by,
					dim.last_update_date,
					dim.last_updated_by,
					dim.last_update_login)

				VALUES (inline.party_id,
					inline.cust_account_id,
					inline.site_use_id,
					inline.collector_id,
					inline.creation_date,
					inline.created_by,
					inline.last_update_date,
					inline.last_updated_by,
					inline.last_update_login)';

EXECUTE IMMEDIATE l_stmt;

	IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Modified (Updation + Insertion) ' || SQL%ROWCOUNT || ' rows into FII_COLLECTORS');
       END IF;

	-- Statistics for FII_COLLECTORS will be anyway gathered via RSG so NOT gathering stats in the program

	-- From past experience, perf team has suggested not to analyze MLOG in incremental run.
	-- So we will not be gathering stats for MLOG during incremental run.

      FND_CONCURRENT.Af_Commit;

      IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Succ(func_name => 'FII_AR_COLLECTORS_PKG.Incre_Update');
      END IF;

   --Added by vkazhipu for customer bug 5763652
    BIS_COLLECTION_UTILITIES.wrapup(
       p_status => TRUE,
       p_period_from => l_last_period_to,
       p_period_to => g_collection_to_date);

   -- Exception handling

   EXCEPTION
     WHEN CODIM_fatal_err THEN
       FII_UTIL.Write_Log ('FII_AR_COLLECTORS_PKG.Incre_Update'||
                         'User defined error');

       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name	=> 'FII_AR_COLLECTORS_PKG.Incre_Update');
       retcode := sqlcode;
       ret_val := FND_CONCURRENT.Set_Completion_Status
	        	(status	 => 'ERROR', message => substr(sqlerrm,1,180));

     WHEN OTHERS THEN
       FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
       FII_UTIL.Write_Log (
          'Other error IN FII_AR_COLLECTORS_PKG.Incre_Update: ' || substr(sqlerrm,1,180));

       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name	=> 'FII_AR_COLLECTORS_PKG.Incre_Update');
       retcode := sqlcode;
       ret_val := FND_CONCURRENT.Set_Completion_Status
	        	(status	 => 'ERROR', message => substr(sqlerrm,1,180));

   END Incre_Update;



END FII_AR_COLLECTORS_PKG;

/
