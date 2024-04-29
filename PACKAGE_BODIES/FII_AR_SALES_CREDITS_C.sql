--------------------------------------------------------
--  DDL for Package Body FII_AR_SALES_CREDITS_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_SALES_CREDITS_C" AS
/* $Header: FIIARSCB.pls 120.1 2005/10/30 05:13:24 appldev noship $ */

 g_errbuf               VARCHAR2(2000) := NULL;
 g_retcode              VARCHAR2(20) := NULL;
 g_section              VARCHAR2(20) := NULL;
 g_fii_schema           VARCHAR2(30);
 g_fii_user_id          NUMBER(15);
 g_fii_login_id         NUMBER(15);
 g_debug_flag           VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
 g_program_type         VARCHAR2(1);

 g_default_salesrep	NUMBER(15) 	:= -3;
 g_default_salesgroup	NUMBER 		:= NULL;

 g_max_salescredit_pk	NUMBER		:= 0;

 G_TABLE_NOT_EXIST      EXCEPTION;
 PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);
 G_PROCEDURE_FAILURE    EXCEPTION;
 G_TRUNCATE_FAILURE     EXCEPTION;
 G_LOGIN_INFO_NOT_AVABLE  EXCEPTION;

-- ---------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-- ---------------------------------

-----------------------------------------------------------------------
-- PROCEDURE CLEAN_UP
-----------------------------------------------------------------------
PROCEDURE Clean_Up IS
  l_retcode VARCHAR2(20);
BEGIN
    --FII_UTIL.truncate_table(p_table_name => 'fii_ar_sales_credits_t', p_retcode => l_retcode);
    if l_retcode = -1 then
	g_retcode := -2;
	RAISE g_truncate_failure;
    end if;
EXCEPTION
   WHEN OTHERS Then
        g_retcode:=-1;
        g_errbuf := '
---------------------------------
Error in Procedure: Clean_Up
Message: ' || sqlerrm;
        RAISE g_procedure_failure;
END Clean_up;


------------------------------------------------------
-- PROCEDURE Init
------------------------------------------------------
PROCEDURE Init IS
  l_status      VARCHAR2(30);
  l_industry    VARCHAR2(30);
  l_stmt        VARCHAR2(50);
BEGIN

   -----------------------------------------------
   -- Do the necessary setups for logging and output
   -----------------------------------------------
   g_section := 'Section 20';

  -- --------------------------------------------------------
  -- Find the schema owner and tablespace
  -- --------------------------------------------------------
  g_section := 'Section 30';
  IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema)) THEN
	NULL;
  END IF;

  g_section := 'Section 60';

  g_fii_user_id :=  FND_GLOBAL.User_Id;
  g_fii_login_id := FND_GLOBAL.Login_Id;

  IF (g_fii_user_id IS NULL OR g_fii_login_id IS NULL) THEN
        RAISE G_LOGIN_INFO_NOT_AVABLE;
  END IF;

  if g_debug_flag = 'Y' then
    fii_util.put_line('User ID: ' || g_fii_user_id || '  Login ID: ' || g_fii_login_id);
  end if;

  EXCEPTION
    WHEN G_LOGIN_INFO_NOT_AVABLE THEN
        if g_debug_flag = 'Y' then
                        fii_util.put_line('
Can not get User ID and Login ID, program exit');
       end if;
        g_retcode := -1;
    RAISE;

    WHEN OTHERS THEN
  	g_retcode := -2;
  	g_errbuf := '
  ---------------------------------
  Error in Procedure: INIT
           Section: '||g_section||'
           Message: '||sqlerrm;
  	raise g_procedure_failure;

END Init;

-----------------------------------------------------------
-- FUNCTION POPULATE_SC_INSERT
-- inserting new records
-----------------------------------------------------------
FUNCTION POPULATE_SC_INSERT RETURN NUMBER IS
  l_row_count    NUMBER;

BEGIN

  	if g_debug_flag = 'Y' then
  		fii_util.put_line(' ');
  		fii_util.start_timer;
  	end if;

	-- Populate FII_AR_SALES_CREDITS with AR Sales Credits that have been inserted since the last Run Date
 	insert into fii_ar_sales_credits (
		SALESCREDIT_PK, INVOICE_LINE_ID,
		SALESREP_ID, SALESGROUP_ID,
		REVENUE_PERCENT_SPLIT,
		CREATED_BY, LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATION_DATE, LAST_UPDATE_DATE)
	select 	CUST_TRX_LINE_SALESREP_ID, CUSTOMER_TRX_LINE_ID,
		SALESREP_ID, revenue_salesgroup_id,
		REVENUE_PERCENT_SPLIT,
		g_fii_user_id, g_fii_user_id,
		g_fii_login_id,
		SYSDATE, SYSDATE
	from 	ra_cust_trx_line_salesreps_all
	where	cust_trx_line_salesrep_id > g_max_salescredit_pk
	and	customer_trx_line_id is not null
	and	nvl(revenue_percent_split, 0) <> 0;

  	l_row_count := SQL%ROWCOUNT;

  	if g_debug_flag = 'Y' then
  		fii_util.put_line('');
 		fii_util.put_line('Inserted new AR Sales Credits');
  		fii_util.put_line('Processed '||l_row_count||' rows');
  		fii_util.stop_timer;
  		fii_util.print_timer('Duration');
	 	fii_util.put_line(' ');
  	end if;

  	RETURN(l_row_count);

EXCEPTION
  WHEN OTHERS THEN
    g_retcode := -2;
    g_errbuf := '
  ---------------------------------
  Error in Procedure: POPULATE_SC_INSERT
           Message: '||sqlerrm;
  raise g_procedure_failure;

END POPULATE_SC_INSERT;

-----------------------------------------------------------
--  PROCEDURE POPULATE_SC_UPDEL
--  processing updated and deleted Sales Credits
-----------------------------------------------------------
PROCEDURE POPULATE_SC_UPDEL IS

BEGIN

  	if g_debug_flag = 'Y' then
   		fii_util.put_line(' ');
   		fii_util.put_line('Processing updates and deletes');
   		fii_util.start_timer;
   		fii_util.put_line('');
  	end if;

	-- Mark rows updated and deleted in the AR application for processing
	UPDATE FII_AR_SALES_CREDITS_D_T
	SET STATUS_FLAG = 'P';

   	if g_debug_flag = 'Y' then
   		fii_util.put_line('Marked '||SQL%ROWCOUNT||' rows in FII_AR_SALES_CREDITS_D_T as updated / deleted in AR');
   		fii_util.stop_timer;
   		fii_util.print_timer('Duration');
   		fii_util.start_timer;
   		fii_util.put_line('');
   	end if;

	-- Merge the updated Sales Credits into FII_AR_SALES_CREDITS using FII_AR_SALESCREDIT_D_T.SALESCREDIT_PK to join with RA_CUST_TRX_LINE_SALESREPS_ALL
	-- (for existing rows, delete them if the new revenue percent is 0 else update them; for new rows, insert them if the revenue percent is non-0)

	-- For non-0 rows, update existing rows and insert new rows
 	MERGE INTO FII_AR_SALES_CREDITS f
          USING (SELECT sr.* FROM  FII_AR_SALES_CREDITS_D_T del, RA_CUST_TRX_LINE_SALESREPS_ALL sr
                  WHERE nvl(revenue_percent_split, 0) <> 0
		  AND 	del.salescredit_pk = sr.cust_trx_line_salesrep_id
		  AND	del.dml_type = 'U'
		  AND	sr.customer_trx_line_id is not null) stg
          ON (  stg.cust_trx_line_salesrep_id = f.salescredit_pk)
   	WHEN MATCHED THEN
          UPDATE SET
		f.INVOICE_LINE_ID = stg.CUSTOMER_TRX_LINE_ID,
		f.SALESREP_ID = stg.SALESREP_ID,
		f.SALESGROUP_ID = stg.revenue_salesgroup_id,
		f.REVENUE_PERCENT_SPLIT = stg.REVENUE_PERCENT_SPLIT,
                f.LAST_UPDATED_BY =  g_fii_user_id,
                f.LAST_UPDATE_LOGIN = g_fii_login_id,
                f.LAST_UPDATE_DATE = SYSDATE
   	WHEN NOT MATCHED THEN
          INSERT (
		f.SALESCREDIT_PK, f.INVOICE_LINE_ID,
		f.SALESREP_ID, f.SALESGROUP_ID,
		f.REVENUE_PERCENT_SPLIT,
		f.CREATED_BY, f.LAST_UPDATED_BY,
		f.LAST_UPDATE_LOGIN,
		f.CREATION_DATE, f.LAST_UPDATE_DATE)
          VALUES (
		stg.CUST_TRX_LINE_SALESREP_ID, stg.CUSTOMER_TRX_LINE_ID,
		stg.SALESREP_ID, stg.revenue_salesgroup_id,
		stg.REVENUE_PERCENT_SPLIT,
		g_fii_user_id, g_fii_user_id,
		g_fii_login_id,
		SYSDATE, SYSDATE);

   	if g_debug_flag = 'Y' then
   		fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows updated in AR for updation / insertion');
   		fii_util.stop_timer;
   		fii_util.print_timer('Duration');
   		fii_util.start_timer;
   		fii_util.put_line('');
   	end if;

	-- For rows updated in AR to have revenue_percent=0, delete them from FII
	DELETE FROM FII_AR_SALES_CREDITS
	  WHERE SALESCREDIT_PK in
		(select SALESCREDIT_PK from FII_AR_SALES_CREDITS_D_T del, RA_CUST_TRX_LINE_SALESREPS_ALL sr
		 where nvl(REVENUE_PERCENT_SPLIT, 0) = 0
		 and   del.salescredit_pk = sr.cust_trx_line_salesrep_id
		 and   del.dml_type = 'U');

   	if g_debug_flag = 'Y' then
   		fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows for deletion due to 0 / null revenue percent updates');
   		fii_util.stop_timer;
   		fii_util.print_timer('Duration');
   		fii_util.start_timer;
   		fii_util.put_line('');
   	end if;

	-- Process / Delete rows deleted from the AR application
	DELETE FROM FII_AR_SALES_CREDITS
	  WHERE SALESCREDIT_PK in
		(select SALESCREDIT_PK from FII_AR_SALES_CREDITS_D_T
		 where STATUS_FLAG = 'P'
		 and DML_TYPE = 'D');

   	if g_debug_flag = 'Y' then
   		fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows for deletion due to deletions within AR');
   		fii_util.stop_timer;
   		fii_util.print_timer('Duration');
   		fii_util.start_timer;
   		fii_util.put_line('');
   	end if;

	-- Delete deletions that have been processed
	DELETE FROM FII_AR_SALES_CREDITS_D_T
	 where STATUS_FLAG = 'P';

   	if g_debug_flag = 'Y' then
   		fii_util.put_line('Deleted '||SQL%ROWCOUNT||' rows in FII_AR_SALES_CREDITS_D_T as processed');
   		fii_util.stop_timer;
   		fii_util.print_timer('Duration');
	 	fii_util.put_line(' ');
   	end if;

EXCEPTION
 WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: POPULATE_SC_UPDEL
           Message: '||sqlerrm;
  ROLLBACK;
  RAISE g_procedure_failure;

END POPULATE_SC_UPDEL;


PROCEDURE CLEANUP_SC IS

BEGIN

	if g_debug_flag = 'Y' then
	  fii_util.put_line(' ');
          fii_util.put_line('Inserting dummy records for the deleted invoice lines');
          fii_util.start_timer;
        end if;

	-- Insert dummy records based on the 0 revenue percent rows deleted in the merge phase (using the Snapshot Log for FII_AR_SALES_CREDITS)
	insert into fii_ar_sales_credits (
		SALESCREDIT_PK, INVOICE_LINE_ID,
		SALESREP_ID, SALESGROUP_ID,
		REVENUE_PERCENT_SPLIT,
		CREATED_BY, LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATION_DATE, LAST_UPDATE_DATE)
	select 	distinct -INVOICE_LINE_ID, INVOICE_LINE_ID,
		g_default_salesrep, g_default_salesgroup,
		100,
		g_fii_user_id, g_fii_user_id,
		g_fii_login_id,
		SYSDATE, SYSDATE
	from 	mlog$_fii_ar_sales_credits sc_log
	--where	invoice_line_id not in (select distinct invoice_line_id from fii_ar_sales_credits)
	where	not exists (select 'X' from fii_ar_sales_credits where invoice_line_id = sc_log.invoice_line_id)
	and	dmltype$$ = 'D';

       if g_debug_flag = 'Y' then
         fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
         fii_util.stop_timer;
         fii_util.print_timer('Duration');
	 fii_util.put_line(' ');
         fii_util.put_line('Deleting dummy records for new invoice line sales credits');
         fii_util.start_timer;
       end if;

	-- Delete dummy records based on the Snapshot Log for FII_AR_SALES_CREDITS
	delete from fii_ar_sales_credits
	where	salescredit_pk in
	(select	-invoice_line_id
	from 	mlog$_fii_ar_sales_credits
	where	dmltype$$ = 'I'
	and	salescredit_pk > 0);

       if g_debug_flag = 'Y' then
         fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
         fii_util.stop_timer;
         fii_util.print_timer('Duration');
	 fii_util.put_line(' ');
         fii_util.put_line('Inserting dummy records for new posted invoice lines without sales credits');
         fii_util.start_timer;
       end if;

	-- Insert dummy records from the Snapshot Log for FII_AR_REVENUE_B
	insert into fii_ar_sales_credits (
		SALESCREDIT_PK, INVOICE_LINE_ID,
		SALESREP_ID, SALESGROUP_ID,
		REVENUE_PERCENT_SPLIT,
		CREATED_BY, LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATION_DATE, LAST_UPDATE_DATE)
	select 	distinct -INVOICE_LINE_ID, INVOICE_LINE_ID,
		g_default_salesrep, g_default_salesgroup,
		100,
		g_fii_user_id, g_fii_user_id,
		g_fii_login_id,
		SYSDATE, SYSDATE
	from 	mlog$_fii_ar_revenue_b rev_log
	--where	invoice_line_id not in (select distinct invoice_line_id from fii_ar_sales_credits)
	where	not exists (select 'X' from fii_ar_sales_credits where invoice_line_id = rev_log.invoice_line_id)
	and	dmltype$$ = 'I';

       if g_debug_flag = 'Y' then
         fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
         fii_util.stop_timer;
         fii_util.print_timer('Duration');
	 fii_util.put_line(' ');
       end if;

  EXCEPTION

    WHEN OTHERS THEN
  	g_retcode := -2;
  	g_errbuf := '
  ---------------------------------
  Error in Procedure: CLEANUP_SC
           Message: '||sqlerrm;
  	raise g_procedure_failure;

END CLEANUP_SC;

PROCEDURE AR_SC_INIT IS

BEGIN
	if g_debug_flag = 'Y' then
	  fii_util.put_line(' ');
          fii_util.put_line('Loading initial data from AR Sales Credits');
          fii_util.start_timer;
        end if;

	if g_debug_flag = 'Y' then
	  fii_util.put_line(' ');
          fii_util.put_line('start of first insert');
        end if;

	-- Insert a dummy record into FII_AR_SALES_CREDITS for all Adjustments
	insert  into fii_ar_sales_CREDITS F (
		SALESCREDIT_PK, INVOICE_LINE_ID,
		SALESREP_ID, SALESGROUP_ID,
		REVENUE_PERCENT_SPLIT,
		CREATED_BY, LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATION_DATE, LAST_UPDATE_DATE)
	values	(0, 0, g_default_salesrep, g_default_salesgroup, 100,
		g_fii_user_id, g_fii_user_id,
		g_fii_login_id,
		SYSDATE, SYSDATE);

commit;
	if g_debug_flag = 'Y' then
	  fii_util.put_line(' ');
          fii_util.put_line('start of second insert');
        end if;

	-- Initial Load from RA_CUST_TRX_LINE_SALESREPS_ALL
	insert /*+  APPEND PARALLEL(F) */ into fii_ar_sales_CREDITS F (
		SALESCREDIT_PK, INVOICE_LINE_ID,
		SALESREP_ID, SALESGROUP_ID,
		REVENUE_PERCENT_SPLIT,
		CREATED_BY, LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATION_DATE, LAST_UPDATE_DATE)
	select 	/*+ PARALLEL(S) */ CUST_TRX_LINE_SALESREP_ID, CUSTOMER_TRX_LINE_ID,
		SALESREP_ID, revenue_salesgroup_id,
		REVENUE_PERCENT_SPLIT,
		g_fii_user_id, g_fii_user_id,
		g_fii_login_id,
		SYSDATE, SYSDATE
	from 	ra_cust_trx_line_salesreps_all S
	where	revenue_percent_split <> 0
	and	customer_trx_line_id is not null;

       if g_debug_flag = 'Y' then
         fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
         fii_util.stop_timer;
         fii_util.print_timer('Duration');
	 fii_util.put_line(' ');
         fii_util.put_line('Loading initial dummy records');
         fii_util.start_timer;
       end if;

       commit;
	if g_debug_flag = 'Y' then
	  fii_util.put_line(' ');
          fii_util.put_line('start of third insert');
        end if;

	-- Initial Load of dummy records from FII_AR_REVENUE_B
     insert /*+ APPEND PARALLEL(F) */ into fii_ar_sales_CREDITS F (
         SALESCREDIT_PK, INVOICE_LINE_ID,
         SALESREP_ID, SALESGROUP_ID,
         REVENUE_PERCENT_SPLIT,
         CREATED_BY, LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATION_DATE, LAST_UPDATE_DATE)
     select     /*+ parallel(rev) */ distinct -INVOICE_LINE_ID, INVOICE_LINE_ID,
         g_default_salesrep, g_default_salesgroup,
         100,
         g_fii_user_id, g_fii_user_id,
         g_fii_login_id,
         SYSDATE, SYSDATE
     from     fii_ar_revenue_b rev
     where    transaction_class <> 'ADJ'
         and invoice_line_id is not null
         and invoice_line_id not in (
        select /*+ hash_aj parallel_index(b) index_ffs(b) */
         invoice_line_id
          from fii_ar_sales_CREDITS b
         where invoice_line_id is not null);

       if g_debug_flag = 'Y' then
         fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
         fii_util.stop_timer;
         fii_util.print_timer('Duration');
         fii_util.put_line('');
       end if;

       commit;

  EXCEPTION

    WHEN OTHERS THEN
  	g_retcode := -2;
  	g_errbuf := '
  ---------------------------------
  Error in Procedure: AR_SC_INIT
           Message: '||sqlerrm;
  raise g_procedure_failure;

END AR_SC_INIT;


-----------------------------------------------------------
--  PROCEDURE MAIN
-----------------------------------------------------------
PROCEDURE MAIN(Errbuf                  IN OUT  NOCOPY VARCHAR2,
               Retcode                 IN OUT  NOCOPY VARCHAR2,
               p_program_type          IN      VARCHAR2) IS

 l_count  	NUMBER := 0;
 l_section      VARCHAR2(20) := NULL;
 l_last_start_date    DATE :=NULL;
 l_last_end_date      DATE :=NULL;
 l_last_start_date1    DATE :=NULL;
 l_last_start_date2    DATE :=NULL;

 l_period_start_date    DATE :=NULL;
 l_period_end_date      DATE :=NULL;

 l_retcode		VARCHAR2(20);
 l_dir         VARCHAR2(150) := NULL;
BEGIN

  Errbuf := NULL;
  Retcode := 0;

  l_section := 'M-Section 10';

  g_program_type := p_program_type;

  IF l_dir is null THEN
       l_dir := FII_UTIL.get_utl_file_dir;
  END IF;

  ------------------------------------------------
  -- Initialize API will fetch the FII_DEBUG_MODE
  -- profile option and intialize g_debug variable
  -- accordingly.  It will also read in profile
  -- option BIS_DEBUG_LOG_DIRECTORY to find out
  -- the log directory
  ------------------------------------------------

  IF g_program_type = 'I'  THEN
   fii_util.initialize('FII_AR_SALES_CREDITS.log','FII_AR_SALES_CREDITS.out',l_dir, 'FII_AR_SALES_CREDITS_I');
  ELSIF g_program_type = 'L'  THEN
   fii_util.initialize('FII_AR_SALES_CREDITS.log','FII_AR_SALES_CREDITS.out',l_dir, 'FII_AR_SALES_CREDITS_L');
  END IF;

  IF g_program_type = 'I'  THEN
    	IF (NOT BIS_COLLECTION_UTILITIES.setup('FII_AR_SALES_CREDITS_I')) THEN
  	  fii_util.put_line('Error in BIS setup FII_AR_SALES_CREDITS_I');
 	  raise_application_error(-20000,errbuf);
      	  return;
      	END IF;
  ELSIF g_program_type = 'L'  THEN
      	IF (NOT BIS_COLLECTION_UTILITIES.setup('FII_AR_SALES_CREDITS_L')) THEN
  	  fii_util.put_line('Error in BIS setup FII_AR_SALES_CREDITS_L');
          raise_application_error(-20000,errbuf);
          return;
      	END IF;
  END IF;

  --------------------------------------------
  -- Initalization
  --------------------------------------------
  l_section := 'M-Section 12';

  IF g_debug_flag = 'Y' then
 	fii_util.put_line(' ');
  	fii_util.put_line('Initialization');
  END IF;
  INIT;

  -----------------------------------------------------
  -- Calling BIS API to do common set ups
  -- If it returns false, then program should error out
  -----------------------------------------------------
  l_section := 'M-Section 14';

  IF p_program_type = 'L' THEN
  	IF g_debug_flag = 'Y' then
          fii_util.put_line('Running Initial Load, truncate staging and base summary table.');
     	END IF;

        FII_UTIL.TRUNCATE_TABLE(p_table_name => 'FII_AR_SALES_CREDITS_D_T', p_retcode => l_retcode);
 	if l_retcode = -1 then
	  g_retcode := -2;
	  raise g_truncate_failure;
	end if;
      	FII_UTIL.TRUNCATE_TABLE(p_table_name => 'FII_AR_SALES_CREDITS', p_retcode => l_retcode);
 	if l_retcode = -1 then
	  g_retcode := -2;
	  raise g_truncate_failure;
	end if;
       	BIS_COLLECTION_UTILITIES.DELETELOGFOROBJECT('FII_AR_SALES_CREDITS_I');
       	BIS_COLLECTION_UTILITIES.DELETELOGFOROBJECT('FII_AR_SALES_CREDITS_L');
       	COMMIT;
   END IF;

  l_section := 'M-Section 30';

  CLEAN_UP;

  IF (g_program_type = 'L') THEN
  	if g_debug_flag = 'Y' then
 	  fii_util.put_line(' ');
          fii_util.put_timestamp;
    	  fii_util.put_line('INITIAL LOAD: populating FII_AR_SALES_CREDITS');
  	end if;
	AR_SC_INIT;
  ELSE
     	-----------------------------------------------------------------
     	-- obtain the largest salescredit_pk in fii_ar_sales_credits
     	-----------------------------------------------------------------
	select max(salescredit_pk) into g_max_salescredit_pk
	from fii_ar_sales_credits;

  	if g_debug_flag = 'Y' then
    	  fii_util.put_line(' ');
    	  fii_util.put_line('Largest salescredit_pk in fii_ar_sales_credits is '||
            to_char(g_max_salescredit_pk));
          fii_util.put_line(' ');
          fii_util.put_timestamp;
          fii_util.put_line('INCREMENTAL LOAD: populating FII_AR_SALES_CREDITS with new Sales Credits');
        end if;

	-- Insert Sales Credits records created in AR after the last run
      	l_count := POPULATE_SC_INSERT;

  	if g_debug_flag = 'Y' then
       	  fii_util.put_line('Inserted ' || l_count || ' new rows created after the last run');
    	  fii_util.put_line(' ');
          fii_util.put_timestamp;
    	  fii_util.put_line('INCREMENTAL LOAD: processing AR Sales Credits updates and deletes');
  	end if;

      	POPULATE_SC_UPDEL;

  	if g_debug_flag = 'Y' then
	  fii_util.put_line(' ');
       	  fii_util.put_timestamp;
    	  fii_util.put_line('INCREMENTAL LOAD: cleaning up dummy records in FII_AR_SALES_CREDITS');
  	end if;

	-- clean up the dummy records in FII_AR_SALES_CREDITS
      	CLEANUP_SC;

  END IF;

  if g_debug_flag = 'Y' then
  	fii_util.put_line(' ');
  	fii_util.put_timestamp;
  end if;

  CLEAN_UP;
  COMMIT;

  ----------------------------------------------------------------
  -- Calling BIS API to record the range we collect.  Only do this
  -- when we have a successful collection
  ----------------------------------------------------------------

  BIS_COLLECTION_UTILITIES.wrapup(p_status => TRUE);

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

EXCEPTION
  WHEN G_PROCEDURE_FAILURE THEN
    Errbuf := g_errbuf;
    Retcode := g_retcode;
    if g_debug_flag = 'Y' then
      fii_util.put_line(Errbuf);
    end if;
    CLEAN_UP;

  WHEN G_TRUNCATE_FAILURE THEN
    Errbuf := '
  ---------------------------------
  Error in fii_util.truncate_table
	   Message: '|| sqlerrm;
    Retcode := g_retcode;
    if g_debug_flag = 'Y' then
      fii_util.put_line(Errbuf);
    end if;
    CLEAN_UP;

  WHEN OTHERS THEN
    Retcode:= -1;
    Errbuf := '
  ---------------------------------
  Error in Procedure: MAIN
           Section: '||l_section||'
           Message: '||sqlerrm;
    if g_debug_flag = 'Y' then
      fii_util.put_line(Errbuf);
    end if;
    CLEAN_UP;

END MAIN;

FUNCTION delete_salescredit_sub (
  		p_subscription_guid IN RAW,
  		p_event IN OUT NOCOPY WF_EVENT_T)
  		RETURN VARCHAR2 IS
  l_key  VARCHAR2(240) := p_event.GetEventKey();
  l_pos  NUMBER;
BEGIN
  l_pos := instr(l_key, '_');
  l_key := substr(l_key, 1, l_pos - 1);
  insert into fii_ar_sales_credits_d_t (
	SALESCREDIT_PK,
	DML_TYPE,
	STATUS_FLAG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN
  )
  values( to_number(l_key), 'D', null, null, null, null, null, null );
  --commit;
  return 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    return 'ERROR';
END delete_salescredit_sub;

FUNCTION update_salescredit_sub (
  		p_subscription_guid IN RAW,
  		p_event IN OUT NOCOPY WF_EVENT_T)
  		RETURN VARCHAR2 IS
  l_key  VARCHAR2(240) := p_event.GetEventKey();
  l_pos  NUMBER;
  l_exists VARCHAR2(1) := 'N';
BEGIN
  l_pos := instr(l_key, '_');
  l_key := substr(l_key, 1, l_pos - 1);

  BEGIN
    select 'Y' into l_exists
    from fii_ar_sales_credits_d_t
    where salescredit_pk = to_number(l_key)
    and dml_type = 'U';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      insert into fii_ar_sales_credits_d_t (
	SALESCREDIT_PK,
	DML_TYPE,
	STATUS_FLAG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN
      )
      values( to_number(l_key), 'U', null, null, null, null, null, null );
      return 'SUCCESS';
  END;

  if l_exists = 'Y' then
    return 'SUCCESS';
  end if;

EXCEPTION
  WHEN OTHERS THEN
    return 'ERROR';
END update_salescredit_sub;

END FII_AR_SALES_CREDITS_C;

/
