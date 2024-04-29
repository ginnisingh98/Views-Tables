--------------------------------------------------------
--  DDL for Package Body FII_PARTY_MKT_CLASS_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PARTY_MKT_CLASS_C" AS
/* $Header: FIIPCLSB.pls 120.11 2006/10/26 19:17:52 mmanasse noship $ */

  g_bis_setup_exception       EXCEPTION;
  g_user_id                   NUMBER            := fnd_global.user_id;
  g_login_id                  NUMBER            := fnd_global.login_id;
  g_run_date                  DATE              := sysdate;
  g_collection_from_date      DATE;
  g_collection_to_date        DATE;
  g_process_type              VARCHAR2(30)      := NULL;
  g_class_type                VARCHAR2(100);

  /* Last Collection Details */
  g_last_collection_from_date DATE              := NULL;
  g_last_collection_to_date   DATE              := NULL;
  g_last_process_type         VARCHAR2(30)      := NULL;
  g_last_success_flag         VARCHAR2(30)      := NULL;

  /* Global return Variable  */
  g_errbuf                    VARCHAR2(4000);
  g_retcode                   VARCHAR2(10)      := 0;

  /* Debugging variable*/
  g_phase           varchar2(500);

  PROCEDURE last_collection_detail;
  FUNCTION  non_hierarchical_class  RETURN BOOLEAN;
  PROCEDURE initial_load;
  PROCEDURE incremental_load;

  PROCEDURE load
  ( errbuf      IN OUT NOCOPY VARCHAR2
  , retcode     IN OUT NOCOPY VARCHAR2
  , p_load_mode IN VARCHAR2 DEFAULT 'INCRE'
  ) as

  l_exception exception;
  l_error_message varchar2(4000);
  l_setup_ok     BOOLEAN;

  BEGIN
   l_setup_ok := FALSE;
   -- Retrieve last collection details
   last_collection_detail();

   IF (g_retcode <> 0)
   THEN
      RAISE l_exception;
   END IF;

   -- Check classification category profile value.
   -- If the classification is hierarchical or allows multiple assignments
   -- Then exit with error.

   IF NOT non_hierarchical_class( )
   THEN
      bis_collection_utilities.log('Error in  Party Market Classification Type  global setup ');
      bis_collection_utilities.log('Make sure that  Party Market Classification Type profile is  non hierarchical and does not allow multiple parent code or multiple class code assignment. ');
      raise g_bis_setup_exception;
   END IF;

   IF (g_retcode <> 0)
   THEN
      RAISE l_exception;
   END IF;

   l_setup_ok := BIS_COLLECTION_UTILITIES.setup('FII_PARTY_MKT_CLASS');
   IF (NOT l_setup_ok) THEN
      errbuf := fnd_message.get;
      bis_collection_utilities.log( 'BIS Setup Failure ',0);
      RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
   END IF;

   -- check to see whether initial load or incremental load.
   -- p_load_mode = 'INIT'   initial load
   -- p_load_mode = 'INCRE'  incremental load
   IF (upper(p_load_mode) = 'INIT')
   THEN
      -- Current request is for initial
      -- OR
      --  Last Initial is unseccessfull
      g_phase := 'Setting dates for initial load.';
      bis_collection_utilities.log('Setting dates for initial load. ');
      g_collection_from_date  := bis_common_parameters.get_GLOBAL_START_DATE; --global start date
      if (g_collection_from_date is null) then
         raise g_bis_setup_exception;
      end if;
      g_collection_to_date    := g_run_date;
      g_process_type          := 'INIT';
      initial_load();
   ELSIF (upper(p_load_mode) = 'INCRE')
   THEN
      IF( g_last_success_flag = 'Y')
      THEN
         -- Last Load is successfull
         bis_collection_utilities.log('Setting dates for incremental load. ');
         g_collection_from_date  := g_last_collection_to_date;
         g_collection_to_date    := g_run_date;
      ELSE
         -- Last Load is unsuccessfull
         bis_collection_utilities.log('Unsuccessfull initial load. Contact Administrator to complete initial load of party market classification');
         RAISE l_exception;
      END IF;
      g_process_type          := 'INCRE';
      incremental_load();
  ELSE
    bis_collection_utilities.log('Please enter a valid parameter for load mode. Use INIT for initial load and INCRE for incremental load.');
    RAISE l_exception;
  END IF;

   IF (g_retcode <> 0)
   THEN
      RAISE l_exception;
   END IF;

   bis_collection_utilities.log('Current  Collection Details: ');
   bis_collection_utilities.log('     Process Type         : ' || g_process_type );
   bis_collection_utilities.log('     Collection From Date : ' || to_char(g_collection_from_date,'DD-MON-YYYY HH24:MI:SS'));
   bis_collection_utilities.log('     Collection To Date   : ' || to_char(g_collection_to_date,'DD-MON-YYYY HH24:MI:SS'));
   bis_collection_utilities.log('     Success Flag         : ' || 'Y');

   COMMIT;

     bis_collection_utilities.log('SUCCESS: Load Program Successfully completed ' ||
           fnd_date.date_to_displayDT(sysdate),0);

     BIS_COLLECTION_UTILITIES.wrapup(TRUE,
                                     -1,
                                     'FII_PARTY_MKT_CLASS  COLLECTION SUCCEEFULL',
                                     g_collection_from_date,
                                     g_collection_to_date
                                     );
  EXCEPTION
    WHEN l_exception THEN
        errbuf  := sqlerrm;
        retcode := 2;
    WHEN g_bis_setup_exception THEN
      bis_collection_utilities.log('Error partner classification load program ');
      bis_collection_utilities.log('Phase  : ' || g_phase);
      retcode := -1;
      rollback;
    WHEN OTHERS THEN
      l_error_message  := sqlerrm;
      bis_collection_utilities.log('Error partner classification load program ');
      bis_collection_utilities.log('Error Message  : ' || l_error_message);
      bis_collection_utilities.log('Phase  : ' || g_phase);
      errbuf  := l_error_message;
      retcode := 2;
  END load;

  PROCEDURE last_collection_detail IS
     l_error_message  VARCHAR2(1000);
     l_period_from    DATE;
     l_period_to      DATE;

  BEGIN
     g_phase := 'Getting last refresh dates';

     BIS_COLLECTION_UTILITIES.get_last_refresh_dates(
        p_object_name => 'FII_PARTY_MKT_CLASS',
        p_start_date  => l_period_from,
        p_end_date    => l_period_to,
        p_period_from => g_last_collection_from_date,
        p_period_to   => g_last_collection_to_date);

     IF (g_last_collection_from_date IS NULL)
     THEN
        g_last_success_flag := NULL;
     ELSE
        g_last_success_flag := 'Y';
     END IF;

      bis_collection_utilities.log('Last Collection Details: ');
      bis_collection_utilities.log('     Collection From Date : ' || to_char(g_last_collection_from_date,'DD-MON-YYYY HH24:MI:SS'));
      bis_collection_utilities.log('     Collection To Date   : ' || to_char(g_last_collection_to_date,'DD-MON-YYYY HH24:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN
      l_error_message  := sqlerrm;
      bis_collection_utilities.log('Error While collecting last log information ');
      bis_collection_utilities.log('Error Message  : ' || l_error_message);
      bis_collection_utilities.log('Phase  : ' || g_phase);
      g_errbuf         := l_error_message;
      g_retcode        := 2;
  END last_collection_detail;

  FUNCTION  non_hierarchical_class  RETURN BOOLEAN IS
     l_ret_val         NUMBER;
     l_error_message   VARCHAR2(1000);
  BEGIN
     l_ret_val := 0;
     -- Select Classification type
     SELECT nvl(bis_common_parameters.GET_BIS_CUST_CLASS_TYPE, -1)
     INTO   g_class_type
     FROM   DUAL;

    -- Check if the classification type is non_hierarchical.
    g_phase := 'Check if the classification type is non_hierarchical';

   SELECT count(b.CLASS_CATEGORY) INTO l_ret_val
   FROM hz_class_categories c,hz_class_code_relations b -- changes for bug 4130053
   Where c.CLASS_CATEGORY = g_class_type
   AND b.class_category = g_class_type
   AND b.START_DATE_ACTIVE <= g_run_date
   AND NVL(b.END_DATE_ACTIVE, g_run_date+1) > g_run_date;

/*
    -- Temporary for testing
    g_class_type := 'CUSTOMER_CATEGORY';
    l_ret_val    := 1;
    -- END temporary
*/
    IF (l_ret_val <> 0)
    THEN
       RETURN  FALSE;
       bis_collection_utilities.log('Classification  Category is hierarchical. ');
    ELSE
       bis_collection_utilities.log('Classification  Category is  non-hierarchical. ');

    END IF;
    -- Checks if multiple parent flag is set to Y or multiple class code assignment flag is set to 'Y'.
    g_phase := 'Checks if multiple parent flag is set to Y or multiple class code assignment flag is set to Yes';

  SELECT count(c.CLASS_CATEGORY) INTO l_ret_val
   FROM hz_class_categories c  -- changes for bug 4207952
   Where c.CLASS_CATEGORY = g_class_type
   AND (c.allow_multi_parent_flag ='Y'
   OR c.allow_multi_assign_flag = 'Y');

 IF (l_ret_val <> 0)
    THEN
       RETURN  FALSE;
       bis_collection_utilities.log('Classification  Category allows multiple parent code or multiple class code assignment. ');
    ELSE
       RETURN TRUE;
       bis_collection_utilities.log('Classification  Category is non-hierarchial and does not allow multiple parent code or multiple class code assignment . ');

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      l_error_message  := sqlerrm;
      bis_collection_utilities.log('Error while verifying partner classification global setup ');
      bis_collection_utilities.log('Error Message  : ' || l_error_message);
      bis_collection_utilities.log('Phase  : ' || g_phase);
      g_errbuf         := l_error_message;
      g_retcode        := 2;
  END non_hierarchical_class;

  -- Load FII_PARTY_MKT_CLASS in initial mode
  -- Find the latest class code that was assigned to a party
  -- If no class code assignment was found for a customer a record with class code '-1' will be
  --    created for the customer
  PROCEDURE initial_load IS
     l_sql_string     VARCHAR2(1000);
     l_fii_schema     VARCHAR2(100);
     l_error_message  VARCHAR2(4000);
     l_max_batch_party_id NUMBER(15);

  BEGIN
     l_fii_schema  := 'FII';

     g_phase := 'Populating IND_MAX_BATCH_PARTY_ID in fii_change_log';
     FII_UTIL.Write_Log(g_phase);

          select nvl(max(batch_party_id), -1)
          into l_max_batch_party_id
          from hz_merge_party_history m,
               hz_merge_dictionary d
          where m.merge_dict_id = d.merge_dict_id
          and d.entity_name = 'HZ_PARTIES';

          INSERT INTO fii_change_log
          (log_item, item_value, CREATION_DATE, CREATED_BY,
           LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
          (SELECT 'IND_MAX_BATCH_PARTY_ID',
                l_max_batch_party_id,
                sysdate,        --CREATION_DATE,
                g_user_id,  --CREATED_BY,
                sysdate,        --LAST_UPDATE_DATE,
                g_user_id,  --LAST_UPDATED_BY,
                g_login_id  --LAST_UPDATE_LOGIN
           FROM DUAL
           WHERE NOT EXISTS
              (select 1 from fii_change_log
               where log_item = 'IND_MAX_BATCH_PARTY_ID'));

          IF (SQL%ROWCOUNT = 0) THEN
              UPDATE fii_change_log
              SET item_value = l_max_batch_party_id,
                  last_update_date  = sysdate,
                  last_update_login = g_login_id,
                  last_updated_by   = g_user_id
              WHERE log_item = 'IND_MAX_BATCH_PARTY_ID';
          END IF;

    --  Identify Last valid class code for each party and create a record in FII_PARTY_MKT_CLASS table
    g_phase := 'Identify Last valid class code for each party and create a record in FII_PARTY_MKT_CLASS table';

     bis_collection_utilities.log('Truncating FII_PARTY_MKT_CLASS Table ');

     l_sql_string := 'TRUNCATE TABLE ' || l_fii_schema ||'.FII_PARTY_MKT_CLASS';
     EXECUTE IMMEDIATE l_sql_string;

     bis_collection_utilities.log('Bis log file was reset for FII_PARTY_MKT_CLASS. ');
     BIS_COLLECTION_UTILITIES.DeleteLogForObject('FII_PARTY_MKT_CLASS');

     bis_collection_utilities.log('Populating FII_PARTY_MKT_CLASS table');
     g_phase := 'Populating FII_PARTY_MKT_CLASS table';

    INSERT /*+ APPEND */ INTO fii_party_mkt_class
    (
       party_id,
       class_category,
       class_code,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login
    )
    SELECT
         party_id,
         class_category,
         MAX(class_code) KEEP (DENSE_RANK LAST ORDER BY party_id, active_priority, last_update_date) class_code,
         sysdate,
         g_user_id,
         sysdate,
         g_user_id,
         g_login_id
    FROM
    (
    SELECT /*+ PARALLEL(HZ_CODE_ASSIGNMENTS) */
          owner_table_id party_id,
          class_category,
          class_code,
          creation_date,
          last_update_date,
          CASE WHEN primary_flag = 'Y'
          THEN 2 ELSE 1 END  active_priority
    FROM  hz_code_assignments
    WHERE class_category = g_class_type
    AND   owner_table_name = 'HZ_PARTIES'
    AND   g_collection_to_date BETWEEN start_date_active AND nvl(end_date_active, g_collection_to_date+1)
    ORDER BY owner_table_id
    )
    GROUP BY party_id, class_category;

    FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into fii_party_mkt_class');

    commit; --Added for ORA-12838: cannot read/modify an object after modifying it in parallel

    bis_collection_utilities.log('Populating FII_PARTY_MKT_CLASS table for unassigned customers');

    g_phase := 'Populating FII_PARTY_MKT_CLASS table for unassigned customers';

    INSERT /*+ APPEND */ INTO fii_party_mkt_class
        (
           party_id,
           class_category,
           class_code,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login
        )

         SELECT
            party_id,
            g_class_type class_category,
            '-1'         class_code,
            sysdate      creation_date,
            g_user_id    created_by,
            sysdate      last_update_date,
            g_user_id    last_updated_by,
            g_login_id   last_update_login
         FROM
          ( SELECT /*+ PARALLEL(HZ_CUST_ACCOUNTS) */
            DISTINCT party_id
            FROM     hz_cust_accounts
            WHERE    party_id NOT IN (SELECT /*+ PARALLEL(FII_PARTY_MKT_CLASS) */
					  party_id
                                   FROM   fii_party_mkt_class
                                   WHERE  class_category = g_class_type
                                   )
          );

	  FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into fii_party_mkt_class');

  EXCEPTION
    WHEN OTHERS THEN
      l_error_message  := sqlerrm;
      bis_collection_utilities.log('Error while doing initial population of partner classification table ');
      bis_collection_utilities.log('Error Message  : ' || l_error_message);
      bis_collection_utilities.log('Phase  : ' || g_phase);
      g_errbuf         := l_error_message;
      g_retcode        := 2;
  END initial_load;

  -- Load FII_PARTY_MKT_CLASS in incremental mode
  PROCEDURE incremental_load IS
     l_sql_string     VARCHAR2(1000);
     l_fii_schema     VARCHAR2(100);
     l_error_message  VARCHAR2(4000);
     lDateFormat      VARCHAR2(50);
     l_max_batch_party_id NUMBER(15);

  BEGIN
     l_fii_schema  := 'FII';

     g_phase := 'Getting maximum batch_party_id from fii_change_log table';
     FII_UTIL.Write_Log (g_phase);

        select item_value
        into l_max_batch_party_id
        from fii_change_log
        where log_item = 'IND_MAX_BATCH_PARTY_ID';

     FII_UTIL.Write_Log ('IND_MAX_BATCH_PARTY_ID = '||l_max_batch_party_id);

    g_phase := 'Deleting merged parties';
    FII_UTIL.Write_Log (g_phase);

        Delete from fii_party_mkt_class
        where party_id in
        (select from_entity_id
        from hz_merge_party_history m,
             hz_merge_dictionary d
        where m.merge_dict_id = d.merge_dict_id
        and d.entity_name = 'HZ_PARTIES'
        and batch_party_id > l_max_batch_party_id);

     g_phase := 'Logging maximum batch_party_id into fii_change_log table';
     FII_UTIL.Write_Log (g_phase);

    select nvl(max(batch_party_id), -1)
    into l_max_batch_party_id
    from hz_merge_party_history m,
         hz_merge_dictionary d
    where m.merge_dict_id = d.merge_dict_id
    and d.entity_name = 'HZ_PARTIES';

    INSERT INTO fii_change_log
    (log_item, item_value, CREATION_DATE, CREATED_BY,
     LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
    (SELECT 'IND_MAX_BATCH_PARTY_ID',
          l_max_batch_party_id,
          sysdate,        --CREATION_DATE,
          g_user_id,  --CREATED_BY,
          sysdate,        --LAST_UPDATE_DATE,
          g_user_id,  --LAST_UPDATED_BY,
          g_login_id  --LAST_UPDATE_LOGIN
     FROM DUAL
     WHERE NOT EXISTS
        (select 1 from fii_change_log
         where log_item = 'IND_MAX_BATCH_PARTY_ID'));

    IF (SQL%ROWCOUNT = 0) THEN
        UPDATE fii_change_log
        SET item_value = l_max_batch_party_id,
            last_update_date  = sysdate,
            last_update_login = g_login_id,
            last_updated_by   = g_user_id
        WHERE log_item = 'IND_MAX_BATCH_PARTY_ID';
    END IF;

    --  Identify Last valid class code for each party and create a record in FII_PARTY_MKT_CLASS table


     bis_collection_utilities.log('Truncating Staging table');

     l_sql_string := 'TRUNCATE TABLE ' || l_fii_schema ||'.FII_PARTY_MKT_CLASS_STG';
     EXECUTE IMMEDIATE l_sql_string;

     bis_collection_utilities.log('Populating Staging table with incremental records from hz_code_assignments table');
     g_phase := 'Populating Staging table with incremental records from hz_code_assignments table';

     -- Bug 5093260. Performance enhancement
     INSERT INTO fii_party_mkt_class_stg
     (
        owner_table_id,
        class_category,
        class_code,
        start_date,
        end_date,
        primary_flag,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
      )
      SELECT /*+ leading(v) use_nl(a) */
         a.OWNER_TABLE_ID,
	 a.CLASS_CATEGORY,
	 a.CLASS_CODE,
	 a.START_DATE_ACTIVE,
         a.END_DATE_ACTIVE,
	 a.PRIMARY_FLAG,
	 a.CREATION_DATE,
        g_user_id,
        a.LAST_UPDATE_DATE,
        g_user_id,
        g_login_id
      FROM HZ_CODE_ASSIGNMENTS a,
        (
         SELECT /*+ no_merge parallel(h) */ DISTINCT OWNER_TABLE_ID
         FROM HZ_CODE_ASSIGNMENTS h
         WHERE ( (LAST_UPDATE_DATE BETWEEN SYSDATE-1 AND SYSDATE)
                  OR
		  (START_DATE_ACTIVE BETWEEN SYSDATE-1 AND SYSDATE)
                  OR
		  (END_DATE_ACTIVE BETWEEN SYSDATE-1 AND SYSDATE) )
         AND CLASS_CATEGORY = g_class_type
         AND OWNER_TABLE_NAME = 'HZ_PARTIES'
        )  v
     WHERE a.OWNER_TABLE_ID = v.OWNER_TABLE_ID
     AND a.CLASS_CATEGORY = g_class_type;

     bis_collection_utilities.log('Populating staging table with customer_ids that are created after last collection');
     bis_collection_utilities.log('    and  that are not assigned to any class code' );
     g_phase := 'Populating staging table with customer_ids that are created after last collection
                 and  that are not assigned to any class code';

     -- Bug 5093260. Performance enhancement
     -- This is required to get the date format for the next query
     SELECT value INTO   lDateFormat
      FROM   v$parameter
      WHERE  name = 'nls_date_format';


     INSERT INTO fii_party_mkt_class_stg
     (
        owner_table_id,
        class_category,
        class_code,
        start_date,
        end_date,
        primary_flag,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
      )
      SELECT
         party_id,
         g_class_type class_category,
         '-1'         class_code,
         to_date(g_collection_to_date, lDateFormat) - 1 start_date_active,
         to_date(g_collection_to_date, lDateFormat) + 1 end_date_active,
         'N',
         g_run_date   creation_date,
         g_user_id    created_by,
         g_run_date   last_update_date,
         g_user_id    last_updated_by,
         g_login_id   last_update_login
       FROM (
             SELECT /*+ parallel(a) */ DISTINCT PARTY_ID
	     FROM HZ_CUST_ACCOUNTS  a
	     WHERE CREATION_DATE BETWEEN g_collection_from_date AND g_collection_to_date
	     AND PARTY_ID NOT IN (
			SELECT /*+ parallel(s) */ OWNER_TABLE_ID
			FROM FII_PARTY_MKT_CLASS_STG s
		        WHERE CLASS_CATEGORY =  g_class_type
                                  )
             );

       g_phase := 'gather_table_stats for FII_PARTY_MKT_CLASS_STG';
       FND_STATS.gather_table_stats
            (ownname	=> l_fii_schema,
             tabname	=> 'FII_PARTY_MKT_CLASS_STG');

     bis_collection_utilities.log('Merging records into  FII_PARTY_MKT_CLASS table ');
     g_phase := 'Merging records into  FII_PARTY_MKT_CLASS table';

    MERGE INTO fii_party_mkt_class cl
    USING
       (
          SELECT
            party_id,
            class_category,
            MAX(class_code) KEEP (DENSE_RANK LAST ORDER BY party_id, active_priority, last_update_date) class_code,
            sysdate    creation_date,
            g_user_id  created_by,
            sysdate    last_update_date,
            g_user_id  last_updated_by,
            g_login_id last_update_login
          FROM
          (
          SELECT
            owner_table_id party_id,
            class_category,
            class_code,
            creation_date,
            last_update_date,
            CASE WHEN primary_flag = 'Y'
            THEN 2 ELSE 1 END  active_priority
          FROM  FII_PARTY_MKT_CLASS_STG
          WHERE g_collection_to_date BETWEEN start_date AND nvl(end_date, g_collection_to_date+1)
          ORDER BY owner_table_id
          )
          GROUP BY party_id, class_category
       ) cu
    ON ( cl.party_id = cu.party_id  AND
         cl.class_category = cu.class_category )
    WHEN MATCHED THEN UPDATE
      SET
        cl.class_code = cu.class_code
    WHEN NOT MATCHED THEN
      INSERT
        (
           party_id,
           class_category,
           class_code,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login
        )
        VALUES
        (
           cu.party_id,
           cu.class_category,
           cu.class_code,
           cu.creation_date,
           cu.created_by,
           cu.last_update_date,
           cu.last_updated_by,
           cu.last_update_login
        );

  EXCEPTION
    WHEN OTHERS THEN
      l_error_message  := sqlerrm;
      bis_collection_utilities.log('Error while doing incremental population of partner classification table ');
      bis_collection_utilities.log('Error Message  : ' || l_error_message);
      bis_collection_utilities.log('Phase  : ' || g_phase);
      g_errbuf         := l_error_message;
      g_retcode        := 2;
  END incremental_load;


---------------------------------------------------
-- PUBLIC FUNCTION DEFAULT_LOAD_MODE
-- this function is used to return the default load
-- mode parameter of the concurrent program
---------------------------------------------------
FUNCTION DEFAULT_LOAD_MODE
return varchar2
is
   l_count           number;
   l_class_category  varchar2(30);
   l_period_from     DATE;
   l_period_to       DATE;
   l_count_party_marge number;

begin
 ----------------------------------------------------------------------------
 -- Run incremental/initial load based on the following:
 -- 1. Last run was successful or not: Yes INCRE and No INIT
 -- 2. Global parameter has been changed or not: Yes INIT and No INCRE
 -- 3. table fii_party_mkt_class is empty: INIT
 ----------------------------------------------------------------------------

 -- If the table is empty then run Initial load
 select count(*) into l_count
 from fii_party_mkt_class;

 IF (l_count = 0) THEN
  return 'INIT';
 ELSE
  -- If the global parameter has changed then run initial load
  select class_category into l_class_category
  from fii_party_mkt_class
  where rownum <2;

  IF  l_class_category <> nvl(bis_common_parameters.GET_BIS_CUST_CLASS_TYPE, -1) THEN
   return 'INIT';
  ELSE
       -- If the last run was unsuccessfull run initial else incremental
       BIS_COLLECTION_UTILITIES.get_last_refresh_dates(
        p_object_name => 'FII_PARTY_MKT_CLASS',
        p_start_date  => l_period_from,
        p_end_date    => l_period_to,
        p_period_from => g_last_collection_from_date,
        p_period_to   => g_last_collection_to_date);

     IF (g_last_collection_from_date IS NULL) THEN
        return 'INIT';
     ELSE
	    --Check if log_item = 'IND_MAX_BATCH_PARTY_ID' exists for party merge functionality.
	    select count(*) into l_count_party_marge
	    from fii_change_log
          where log_item = 'IND_MAX_BATCH_PARTY_ID';

 	    IF (l_count_party_marge = 0) THEN
		 return 'INIT';
	    ELSE
	       return 'INCRE';
	    END IF;
     END IF;

  END IF;
 END IF;

end DEFAULT_LOAD_MODE;

END fii_party_mkt_class_c;

/
