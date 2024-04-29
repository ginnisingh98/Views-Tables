--------------------------------------------------------
--  DDL for Package Body FII_PA_COST_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PA_COST_F_C" AS
/* $Header: FIIPA10B.pls 120.1 2002/11/22 20:21:53 svermett ship $ */

 g_debug_flag  VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

 G_PUSH_DATE_RANGE1         Date := Null;
 G_PUSH_DATE_RANGE2         Date := Null;
 g_row_count                Number := 0;
 g_exception_msg            varchar2(2000) := Null;
 g_errbuf	            varchar2(2000) := Null;
 g_retcode	            varchar2(2000) := Null;
 g_missing_rates      Number:=0;

/* NEW Procedures for new push architecture */

-----------------------------------------------------------
--  FUNCTION TRUNCATE_PK
-----------------------------------------------------------

 FUNCTION TRUNCATE_PK RETURN BOOLEAN
 IS

  l_fii_schema      VARCHAR2(30);
  l_stmt                VARCHAR2(200);
  l_status              VARCHAR2(30);
  l_industry            VARCHAR2(30);

 BEGIN

      IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema)) THEN
         l_stmt := 'TRUNCATE TABLE ' || l_fii_schema ||'.FII_PA_COST_PK';
         EXECUTE IMMEDIATE l_stmt;
      END IF;

      RETURN TRUE;

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN FALSE;
 END;

-----------------------------------------------------------
--  PROCEDURE TRUNCATE_STG
-----------------------------------------------------------

 PROCEDURE TRUNCATE_STG
 IS

  l_fii_schema          VARCHAR2(30);
  l_stmt       VARCHAR2(200);
  l_status     VARCHAR2(30);
  l_industry      VARCHAR2(30);

 BEGIN
      IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema)) THEN
         l_stmt := 'TRUNCATE TABLE ' || l_fii_schema ||'.FII_PA_COST_FSTG';
         EXECUTE IMMEDIATE l_stmt;
      END IF;
 END;

-----------------------------------------------------------
--  PROCEDURE DELETE_STG
-----------------------------------------------------------

 PROCEDURE DELETE_STG
 IS

 BEGIN
   DELETE FII_PA_COST_FSTG
   WHERE  COLLECTION_STATUS = 'LOCAL READY'OR ( COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR COLLECTION_STATUS = 'INVALID CURRENCY')
   AND    INSTANCE = (SELECT INSTANCE_CODE
                     FROM   EDW_LOCAL_INSTANCE);
 END;

------------------------------------------------------------
--PROCEDURE INSERT_MISSING_RATES_IN_TMP
-------------------------------------------------------------
--Identify records that have missing rates and insert them in a temp table

PROCEDURE INSERT_MISSING_RATES_IN_TMP
IS
 rows2                   Number:=0;

 BEGIN
   INSERT INTO fii_pa_cost_pk(
               Primary_Key1,
               Primary_Key2  )
   SELECT
              TO_NUMBER(SUBSTR (COST_PK, 1, INSTR(COST_PK, '-' )-1)),
              TO_NUMBER(SUBSTR (COST_PK, INSTR(COST_PK, '-')+1,INSTR(COST_PK,'-',1,2)-(INSTR(COST_PK,'-')+1)))

   FROM  FII_PA_COST_FSTG fcf

   WHERE

               fcf.COLLECTION_STATUS = 'RATE NOT AVAILABLE'
   OR
               fcf.COLLECTION_STATUS = 'INVALID CURRENCY';

   IF (sql%rowcount > 0) THEN
        g_retcode := 1;
        g_missing_rates := 1;
   END IF;
--Generates "Warning" message in the Status column of Concurrent Manager "Requests" table
      select count(*) into rows2 from FII_PA_COST_FSTG;

      if g_debug_flag = 'Y' then
        edw_log.put_line('Number of rows in stg'||rows2 );
        edw_log.put_line(' ');
        edw_log.put_line('INSERTING ' || to_char(sql%rowcount) || ' rows from staging table');
        edw_log.put_line('g_retcode is  '||g_retcode);
        edw_log.put_line('g_missing_rates is  '||g_missing_rates);
      end if;

 END;


--------------------------------------------------
--FUNCTION LOCAL_SAME_AS_REMOTE
---------------------------------------------------

 FUNCTION LOCAL_SAME_AS_REMOTE RETURN BOOLEAN
 IS

 l_instance1                Varchar2(100) :=Null;
 l_instance2                Varchar2(100) :=Null;

 BEGIN


   SELECT instance_code
   INTO   l_instance1
   FROM   edw_local_instance;

   SELECT instance_code
   INTO   l_instance2
   FROM   edw_local_instance@edw_apps_to_wh;

   IF (l_instance1 = l_instance2) THEN
      RETURN TRUE;
   END IF;

   RETURN FALSE;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN

     RETURN FALSE;

 END;


--------------------------------------------------
--FUNCTION SET_STATUS_READY
---------------------------------------------------

 FUNCTION SET_STATUS_READY RETURN NUMBER
 IS

 BEGIN

   UPDATE FII_PA_COST_FSTG
   SET    COLLECTION_STATUS = 'READY'
   WHERE  COLLECTION_STATUS = 'LOCAL READY'
   AND    INSTANCE = (SELECT INSTANCE_CODE
                     FROM   EDW_LOCAL_INSTANCE);

   RETURN(sql%rowcount);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);

 END;

-----------------------------------------------------------
--FUNCTION PUSH_TO_LOCAL
-----------------------------------------------------------
FUNCTION PUSH_TO_LOCAL RETURN NUMBER IS

  l_mau                 number;   -- minimum accountable unit of
                                  -- global warehouse currency

  L_MAU_NOT_AVAILABLE  exception;

BEGIN

  -- initialize flex cache

  fii_flex_mapping.init_cache('FII_PA_COST_F');

  -- get minimum accountable unit of the warehouse currency;

  l_mau := nvl( edw_currency.get_mau, 0.01 );


  -- insert records from the source view into the local staging table

  Insert into FII_PA_COST_FSTG (
     	COST_PK,
 	INSTANCE_FK,
 	SET_OF_BOOKS_FK,
 	PROJECT_FK,
 	PROJECT_ORG_FK,
 	EXPENDITURE_ORG_FK,
 	EXPENDITURE_TYPE_FK,
 	CURRENCY_GL_FK,
 	CURRENCY_TRX_FK,
 	EMPLOYEE_FK,
 	GL_DATE_FK,
 	PA_DATE_FK,
 	TRANSACTION_DATE_FK,
 	UNIT_OF_MEASURE_FK,
 	GL_ACCT1_FK,
 	GL_ACCT2_FK,
 	GL_ACCT3_FK,
 	GL_ACCT4_FK,
 	GL_ACCT5_FK,
 	GL_ACCT6_FK,
 	GL_ACCT7_FK,
 	GL_ACCT8_FK,
 	GL_ACCT9_FK,
 	GL_ACCT10_FK,
 	RAW_COST_G,
 	RAW_COST_B,
 	RAW_COST_T,
 	BURDENED_COST_G,
 	BURDENED_COST_B,
 	BURDENED_COST_T,
 	QUANTITY,
 	BILLABLE_FLAG,
 	USER_MEASURE1,
 	USER_MEASURE2,
 	USER_MEASURE3,
 	USER_MEASURE4,
 	USER_MEASURE5,
 	USER_ATTRIBUTE1,
 	USER_ATTRIBUTE2,
 	USER_ATTRIBUTE3,
 	USER_ATTRIBUTE4,
 	USER_ATTRIBUTE5,
 	USER_ATTRIBUTE6,
 	USER_ATTRIBUTE7,
 	USER_ATTRIBUTE8,
 	USER_ATTRIBUTE9,
 	USER_ATTRIBUTE10,
 	USER_FK1,
 	USER_FK2,
 	USER_FK3,
 	USER_FK4,
 	USER_FK5,
 	CREATION_DATE,
 	LAST_UPDATE_DATE,
 	INSTANCE,
 	OPERATION_CODE,
 	COLLECTION_STATUS,
 	EDW_RECORD_TYPE,
        FROM_CURRENCY,
	TRANSACTION_DATE )
  select
	COST_PK,
 	NVL(INSTANCE_FK,'NA_EDW'),
 	NVL(SET_OF_BOOKS_FK,'NA_EDW'),
 	NVL(PROJECT_FK,'NA_EDW'),
 	'NA_EDW'   PROJECT_ORG_FK,
 	NVL(EXPENDITURE_ORG_FK,'NA_EDW'),
 	NVL(EXPENDITURE_TYPE_FK,'NA_EDW'),
 	NVL(CURRENCY_GL_FK,'NA_EDW'),
 	NVL(CURRENCY_TRX_FK,'NA_EDW'),
 	NVL(EMPLOYEE_FK,'NA_EDW'),
 	NVL(GL_DATE_FK,'NA_EDW'),
 	NVL(PA_DATE_FK,'NA_EDW'),
 	NVL(TRANSACTION_DATE_FK,'NA_EDW'),
 	NVL(UNIT_OF_MEASURE_FK,'NA_EDW'),
 	NVL(GL_ACCT1_FK,'NA_EDW'),
     	NVL(GL_ACCT2_FK,'NA_EDW'),
     	NVL(GL_ACCT3_FK,'NA_EDW'),
     	NVL(GL_ACCT4_FK,'NA_EDW'),
     	NVL(GL_ACCT5_FK,'NA_EDW'),
     	NVL(GL_ACCT6_FK,'NA_EDW'),
     	NVL(GL_ACCT7_FK,'NA_EDW'),
     	NVL(GL_ACCT8_FK,'NA_EDW'),
     	NVL(GL_ACCT9_FK,'NA_EDW'),
 	NVL(GL_ACCT10_FK,'NA_EDW'),
        round( ( RAW_COST_B * GLOBAL_CURRENCY_RATE ) / l_mau ) * l_mau,
 	RAW_COST_B,
 	RAW_COST_T,
        round( ( BURDENED_COST_B * GLOBAL_CURRENCY_RATE ) / l_mau ) * l_mau,
 	BURDENED_COST_B,
 	BURDENED_COST_T,
 	QUANTITY,
 	BILLABLE_FLAG,
 	USER_MEASURE1,
 	USER_MEASURE2,
 	USER_MEASURE3,
 	USER_MEASURE4,
 	USER_MEASURE5,
 	USER_ATTRIBUTE1,
 	USER_ATTRIBUTE2,
 	USER_ATTRIBUTE3,
 	USER_ATTRIBUTE4,
 	USER_ATTRIBUTE5,
 	USER_ATTRIBUTE6,
 	USER_ATTRIBUTE7,
 	USER_ATTRIBUTE8,
 	USER_ATTRIBUTE9,
 	USER_ATTRIBUTE10,
 	NVL(USER_FK1,'NA_EDW'),
     	NVL(USER_FK2,'NA_EDW'),
     	NVL(USER_FK3,'NA_EDW'),
     	NVL(USER_FK4,'NA_EDW'),
     	NVL(USER_FK5,'NA_EDW'),
     	SYSDATE,
     	SYSDATE,
     	INSTANCE_FK,
 	NULL,
        decode(GLOBAL_CURRENCY_RATE,
	  NULL, 'RATE NOT AVAILABLE',
          -1, 'RATE NOT AVAILABLE',
          -2, 'RATE NOT AVAILABLE',
         'LOCAL READY'
        ),
        'ORACLE',
        FROM_CURRENCY,
        TRANSACTION_DATE
  from FII_PA_COST_F_FCV;

  -- drop flex cache

  fii_flex_mapping.free_mem_all;

  -- return
  if g_debug_flag = 'Y' then
     edw_log.put_line('g_row_count is');
     edw_log.put_line(TO_CHAR(sql%rowcount));
  end if;

  RETURN(sql%rowcount);

EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);
END;


-----------------------------------------------------------
--  FUNCTION PUSH_REMOTE
-----------------------------------------------------------
 FUNCTION PUSH_REMOTE RETURN NUMBER
 IS

  BEGIN
   Insert Into FII_PA_COST_FSTG@EDW_APPS_TO_WH
   (
	COST_PK,
 	INSTANCE_FK,
 	SET_OF_BOOKS_FK,
 	PROJECT_FK,
 	PROJECT_ORG_FK,
 	EXPENDITURE_ORG_FK,
 	EXPENDITURE_TYPE_FK,
 	CURRENCY_GL_FK,
 	CURRENCY_TRX_FK,
 	EMPLOYEE_FK,
 	GL_DATE_FK,
 	PA_DATE_FK,
 	TRANSACTION_DATE_FK,
 	UNIT_OF_MEASURE_FK,
 	GL_ACCT1_FK,
 	GL_ACCT2_FK,
 	GL_ACCT3_FK,
 	GL_ACCT4_FK,
 	GL_ACCT5_FK,
 	GL_ACCT6_FK,
 	GL_ACCT7_FK,
 	GL_ACCT8_FK,
 	GL_ACCT9_FK,
 	GL_ACCT10_FK,
 	RAW_COST_G,
 	RAW_COST_B,
 	RAW_COST_T,
 	BURDENED_COST_G,
 	BURDENED_COST_B,
 	BURDENED_COST_T,
 	QUANTITY,
 	BILLABLE_FLAG,
 	USER_MEASURE1,
 	USER_MEASURE2,
 	USER_MEASURE3,
 	USER_MEASURE4,
 	USER_MEASURE5,
 	USER_ATTRIBUTE1,
 	USER_ATTRIBUTE2,
 	USER_ATTRIBUTE3,
 	USER_ATTRIBUTE4,
 	USER_ATTRIBUTE5,
 	USER_ATTRIBUTE6,
 	USER_ATTRIBUTE7,
 	USER_ATTRIBUTE8,
 	USER_ATTRIBUTE9,
 	USER_ATTRIBUTE10,
 	USER_FK1,
 	USER_FK2,
 	USER_FK3,
 	USER_FK4,
 	USER_FK5,
 	CREATION_DATE,
 	LAST_UPDATE_DATE,
 	INSTANCE,
 	OPERATION_CODE,
 	COLLECTION_STATUS,
        EDW_RECORD_TYPE )
   select
   	COST_PK,
 	INSTANCE_FK,
 	SET_OF_BOOKS_FK,
 	PROJECT_FK,
 	PROJECT_ORG_FK,
 	EXPENDITURE_ORG_FK,
 	EXPENDITURE_TYPE_FK,
 	CURRENCY_GL_FK,
 	CURRENCY_TRX_FK,
 	EMPLOYEE_FK,
 	GL_DATE_FK,
 	PA_DATE_FK,
 	TRANSACTION_DATE_FK,
 	UNIT_OF_MEASURE_FK,
 	GL_ACCT1_FK,
 	GL_ACCT2_FK,
 	GL_ACCT3_FK,
 	GL_ACCT4_FK,
 	GL_ACCT5_FK,
 	GL_ACCT6_FK,
 	GL_ACCT7_FK,
 	GL_ACCT8_FK,
 	GL_ACCT9_FK,
 	GL_ACCT10_FK,
 	RAW_COST_G,
 	RAW_COST_B,
 	RAW_COST_T,
 	BURDENED_COST_G,
 	BURDENED_COST_B,
 	BURDENED_COST_T,
 	QUANTITY,
 	BILLABLE_FLAG,
 	USER_MEASURE1,
 	USER_MEASURE2,
 	USER_MEASURE3,
 	USER_MEASURE4,
 	USER_MEASURE5,
 	USER_ATTRIBUTE1,
 	USER_ATTRIBUTE2,
 	USER_ATTRIBUTE3,
 	USER_ATTRIBUTE4,
 	USER_ATTRIBUTE5,
 	USER_ATTRIBUTE6,
 	USER_ATTRIBUTE7,
 	USER_ATTRIBUTE8,
 	USER_ATTRIBUTE9,
 	USER_ATTRIBUTE10,
 	USER_FK1,
 	USER_FK2,
 	USER_FK3,
 	USER_FK4,
 	USER_FK5,
 	SYSDATE,
 	SYSDATE,
 	INSTANCE,
 	null,
	'READY',
 	EDW_RECORD_TYPE
   from FII_PA_COST_FSTG
    WHERE collection_status = 'LOCAL READY';
--ensures that only the records with collection status of local ready will be pushed to remote fstg
   RETURN(sql%rowcount);
 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);

END;

---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE
---------------------------------------------------

 FUNCTION IDENTIFY_CHANGE RETURN BOOLEAN
 IS

   l_fii_schema          	VARCHAR2(30);
   l_status              	VARCHAR2(30);
   l_industry               VARCHAR2(30);
   l_stmt                   VARCHAR2(200);
   l_count                  NUMBER;

 BEGIN

   INSERT INTO fii_pa_cost_pk
   (
     Primary_Key1,
     Primary_Key2
   )
   SELECT
     expenditure_item_id,
     line_num
   FROM
     pa_cost_distribution_lines_all
   WHERE
         line_type = 'R'
     AND program_update_date BETWEEN g_push_date_range1 and g_push_date_range2;

   if g_debug_flag = 'Y' then
     edw_log.put_line(' ');
     edw_log.put_line('Inserted ' || nvl(SQL%ROWCOUNT,0) || ' records into primary key table' );
   end if;

   IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema)) THEN

     l_stmt := 'ANALYZE TABLE ' || l_fii_schema || '.FII_PA_COST_PK COMPUTE STATISTICS';
     EXECUTE IMMEDIATE l_stmt;

     if g_debug_flag = 'Y' then
       edw_log.put_line('Analyzed primary key table' );
     end if;

   END IF;

   RETURN TRUE;

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN FALSE;
END;


-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------

 Procedure Push(Errbuf      in out nocopy  Varchar2,
                Retcode     in out nocopy  Varchar2,
                p_from_date in      Varchar2,
                p_to_date    in     Varchar2) IS
 l_fact_name                Varchar2(30) :='FII_PA_COST_F';
 l_date1                    Date:=Null;
 l_date2                    Date:=Null;
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date                Date:=Null;
 l_to_date                  Date:=Null;
 temp			Boolean;
 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------
 l_push_local_failure       EXCEPTION;
 l_push_remote_failure      EXCEPTION;
 l_set_status_failure       EXCEPTION;
 l_iden_change_failure      EXCEPTION;
 l_truncate_tmp_pk_failure  EXCEPTION;
  my_payment_currency    Varchar2(2000):=NULL;
 my_inv_date            Varchar2(2000) := NULL;
 my_collection_status   Varchar2(2000):=NULL;
 rows                   Number:=0;
 rows1                   Number:=0;
   CURSOR c1 IS SELECT DISTINCT FROM_CURRENCY, substr(TRANSACTION_DATE,1,10 ) inv_dt, COLLECTION_STATUS
   FROM FII_PA_COST_FSTG
   WHERE COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR COLLECTION_STATUS = 'INVALID CURRENCY';

Begin
  Errbuf :=NULL;
  Retcode:=0;

  l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
  l_to_date   :=to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

  IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name)) THEN
    errbuf := fnd_message.get;
    raise_application_error(-20000,'Error in EDW_COLLECTION_UTIL.SETUP: ' || errbuf);
  END IF;

  FII_PA_COST_F_C.g_push_date_range1 := nvl(l_from_date,
    EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);

  FII_PA_COST_F_C.g_push_date_range2 := nvl(l_to_date,
    EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
  l_date1 := g_push_date_range1;
  l_date2 := g_push_date_range2;

  if g_debug_flag = 'Y' then
     edw_log.put_line( 'The collection range is from '||
          to_char(l_date1,'MM/DD/YYYY HH24:MI:SS')||' to '||
          to_char(l_date2,'MM/DD/YYYY HH24:MI:SS'));
     edw_log.put_line(' ');
  end if;

 --  --------------------------------------------------------
 --  1. Clean up any records left from previous process in
 --     the local staging table.
 --  --------------------------------------------------------
   if g_debug_flag = 'Y' then
     edw_log.put_line(' ');
     edw_log.put_line('Cleaning up unprocessed records left in local staging table');
     fii_util.start_timer;
   end if;

   -- note that TRUNCATE statement does implicit commit;

   IF (NOT LOCAL_SAME_AS_REMOTE) THEN
    TRUNCATE_STG;
   ELSE
    DELETE_STG;
   END IF;
     select count(*) into rows1 from FII_PA_COST_FSTG;

   if g_debug_flag = 'Y' then
     edw_log.put_line('Number of rows in stg after truncating or deleting'||rows1 );
     fii_util.stop_timer;
     fii_util.print_timer('Process Time');
   end if;

 --  --------------------------------------------------------
 --  2. Identify Changed records in the
 --     PA_COST_DISTRIBUTION_LINES_ALL table
 --  --------------------------------------------------------

   -- note that IDENTIFY_CHANGE analyzes table and does implicit commit;

   if g_debug_flag = 'Y' then
     fii_util.start_timer;
   end if;

   if NOT IDENTIFY_CHANGE THEN
     RAISE l_iden_change_failure;
   end if;
    select count(*) into rows1 from FII_PA_COST_pk;

   if g_debug_flag = 'Y' then
     edw_log.put_line('Number of rows in pk after identify change'||rows1 );
     fii_util.stop_timer;
     fii_util.print_timer('Process Time');
   end if;

 --  --------------------------------------------------------
 --  3. Pushing data to local staging table
 --  --------------------------------------------------------

   if g_debug_flag = 'Y' then
     edw_log.put_line(' ');
     edw_log.put_line('Pushing data to local staging table');
     fii_util.start_timer;
   end if;

   g_row_count := PUSH_TO_LOCAL;

   if g_debug_flag = 'Y' then
     fii_util.stop_timer;
     fii_util.print_timer('Process Time');
   end if;

   IF (g_row_count = -1) THEN
   	RAISE L_push_local_failure;
   END IF;

   if g_debug_flag = 'Y' then
     edw_log.put_line('Inserted '||nvl(g_row_count,0)|| ' rows into the local staging table');
     edw_log.put_line(' ');
   end if;

 --  --------------------------------------------------------
 --  4. Clean up any records left from previous process in
 --     the FII_PA_COST_PK table
 --  --------------------------------------------------------

   if g_debug_flag = 'Y' then
     edw_log.put_line(' ');
     edw_log.put_line('Cleaning up unprocessed records left in primary key table');
   end if;

   -- note that TRUNCATE statement does implicit commit;

   IF NOT TRUNCATE_PK THEN
     RAISE l_truncate_tmp_pk_failure;
--     select count(*) into rows1 from FII_PA_COST_PK;
--     if g_debug_flag = 'Y' then
--       edw_log.put_line('rows in tmp_pk after truncating'||to_char(rows1));
--     end if;
  END IF;
--     select count(*) into rows1 from FII_PA_COST_PK;
--     if g_debug_flag = 'Y' then
--       edw_log.put_line('rows in tmp_pk after truncating'||to_char(rows1));
--     end if;


   --  ------------------------------------------------------------------------------------------------
   --  4A. Insert missing rates from local fstg into tmp_pk table  printing data to file
   --  ------------------------------------------------------------------------------------------------

   INSERT_MISSING_RATES_IN_TMP;
   if (g_missing_rates >0) then
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FROM CURRENCY   CONVERSION DATE    COLLECTION STATUS');
FOR c in c1 loop
my_payment_currency := c.FROM_CURRENCY;
my_inv_date := NVL(c.inv_dt, 'DATE NOT AVAILABLE');
my_collection_status := c.COLLECTION_STATUS;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, my_payment_currency||'                       '||
        my_inv_date||'                  '||my_collection_status);

end loop;
   end if;

   --  ------------------------------------------------------------------------------------------------------------
   --  4B. Delete records with missing rates from local staging table
   --  ------------------------------------------------------------------------------------------------------------

--   DELETE_STG;


 --  --------------------------------------------------------
 --  5. Pushing data to remote staging table
 --  --------------------------------------------------------
   IF (NOT LOCAL_SAME_AS_REMOTE) THEN
           -- -----------------------------------------------
           -- The target warehouse is not the same database
           -- as the source OLTP, which is the typical case.
           -- We move data from local to remote staging table
           -- and clean up local staging
           -- -----------------------------------------------

           if g_debug_flag = 'Y' then
             edw_log.put_line(' ');
             edw_log.put_line('g_row_count in LOCAL_SAME_AS_REMOTE'|| g_row_count);
             edw_log.put_line('Moving data from local staging table to remote staging table');
             fii_util.start_timer;
           end if;

           g_row_count := PUSH_REMOTE;

           if g_debug_flag = 'Y' then
             fii_util.stop_timer;
             fii_util.print_timer('Process time');
           end if;

           IF (g_row_count = -1) THEN RAISE l_push_remote_failure; END IF;

           if g_debug_flag = 'Y' then
             edw_log.put_line(' ');
             edw_log.put_line('Cleaning local staging table');
             fii_util.start_timer;
           end if;

           TRUNCATE_STG;

           if g_debug_flag = 'Y' then
             fii_util.stop_timer;
             fii_util.print_timer('Process time');
           end if;

    ELSE
           -- -----------------------------------------------
           -- The target warehouse is the same database
           -- as the source OLTP.  We set the status of all our
           -- records status 'LOCAL READY' to 'READY'
           -- -----------------------------------------------

           if g_debug_flag = 'Y' then
             edw_log.put_line(' ');
             edw_log.put_line('Marking records in staging table with READY status');
             fii_util.start_timer;
           end if;

           g_row_count := SET_STATUS_READY;

           if g_debug_flag = 'Y' then
             fii_util.stop_timer;
             fii_util.print_timer('Process time');
             edw_log.put_line('g_row_count from SET_STATUS_READY'|| g_row_count);
           end if;

           DELETE_STG;
           IF (g_row_count = -1) THEN RAISE l_set_status_failure; END IF;
     END IF;

     -- -----------------------------------------------
     -- Successful.  Commit and call
     -- wrapup to commit and insert messages into logs
     -- -----------------------------------------------

     COMMIT;

     --  --------------------------------------------------------
     --  Clean up any records in the FII_PA_COST_PK table
     --  --------------------------------------------------------

     if g_debug_flag = 'Y' then
       edw_log.put_line(' ');
       edw_log.put_line('Cleaning up primary key table');
     end if;

/*     IF NOT TRUNCATE_PK THEN
       -- Normally this error will not occur - Collection concurrent
       -- programs are defined as incompatible with themselves so that
       -- only one process can access _PK table at the same time.
       -- Since all records have already been transferred to warehouse
       -- we ignore this error. The primary key table will be truncated
       -- next time we run the program.

       NULL;

     END IF;
*/

     if g_debug_flag = 'Y' then
       edw_log.put_line(' ');
       edw_log.put_line('Inserted '||nvl(g_row_count,0)||
           ' rows into the staging table');
       edw_log.put_line(' ');
     end if;

     Retcode := g_retcode;
     EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, g_push_date_range1, g_push_date_range2);
 if (g_missing_rates >0) then

     if g_debug_flag = 'Y' then
       edw_log.put_line ('Records with missing rates identified in source and not loaded to warehouse');
     end if;

     end if;

 Exception
   WHEN L_IDEN_CHANGE_FAILURE THEN
      rollback;
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      if g_debug_flag = 'Y' then
        edw_log.put_line(' ');
        edw_log.put_line('ERROR: Identifying changed records have failed');
        edw_log.put_line(' ');
      end if;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_date_range1, g_push_date_range2);
   WHEN L_PUSH_LOCAL_FAILURE THEN
      rollback;
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      if g_debug_flag = 'Y' then
        edw_log.put_line(' ');
        edw_log.put_line('ERROR: Inserting into local staging have failed');
        edw_log.put_line(' ');
      end if;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_date_range1, g_push_date_range2);
   WHEN L_PUSH_REMOTE_FAILURE THEN
      rollback;
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      if g_debug_flag = 'Y' then
        edw_log.put_line(' ');
        edw_log.put_line('ERROR: Data migration from local to remote staging have failed');
        edw_log.put_line(' ');
      end if;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_date_range1, g_push_date_range2);
   WHEN L_SET_STATUS_FAILURE THEN
      rollback;
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      if g_debug_flag = 'Y' then
        edw_log.put_line(' ');
        edw_log.put_line('ERROR: Setting status to READY have failed');
        edw_log.put_line(' ');
      end if;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_date_range1, g_push_date_range2);
   WHEN L_TRUNCATE_TMP_PK_FAILURE THEN
      rollback;
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      if g_debug_flag = 'Y' then
        edw_log.put_line('ERROR: Clean-up of primary key table failed');
        edw_log.put_line(' ');
      end if;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_date_range1, g_push_date_range2);
   WHEN OTHERS THEN
      rollback;
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_date_range1, g_push_date_range2);
      raise;

End Push;

End FII_PA_COST_F_C;

/
