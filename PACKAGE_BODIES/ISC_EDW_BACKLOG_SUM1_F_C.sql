--------------------------------------------------------
--  DDL for Package Body ISC_EDW_BACKLOG_SUM1_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_EDW_BACKLOG_SUM1_F_C" AS
/* $Header: ISCSCF3B.pls 120.0 2005/05/25 17:42:59 appldev noship $ */


TYPE instance_rec IS RECORD (
	instance_code	VARCHAR2(30),
	db_link		VARCHAR2(128),
	same_inst	BOOLEAN,
	valid		BOOLEAN,
	source_instance	VARCHAR2(200));

TYPE Instance_Tab IS TABLE OF Instance_Rec INDEX BY BINARY_INTEGER;

g_rec			INSTANCE_TAB;
g_isc_schema 		VARCHAR2(30);
g_tablespace    	VARCHAR2(30);
g_errbuf		VARCHAR2(2000) 	:= NULL;
g_retcode		VARCHAR2(200) 	:= NULL;
g_exception_msg		VARCHAR2(200);

g_drop_table_failure	EXCEPTION;
g_trunc_table_failure	EXCEPTION;
g_collect_back_failure	EXCEPTION;
g_pop_back_sum_failure	EXCEPTION;
g_table_not_exist	EXCEPTION;
g_synonym_not_exist	EXCEPTION;

PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);
PRAGMA EXCEPTION_INIT(G_SYNONYM_NOT_EXIST, -1434);


-- ---------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-- ---------------------------------

-------------------
-- PROCEDURE Init
-------------------
PROCEDURE Init IS
  l_stmt  		VARCHAR2(200);
  l_status		VARCHAR2(30);
  l_industry		VARCHAR2(30);
  l_db_name1		VARCHAR2(30);
  l_db_name2		VARCHAR2(30);
  l_dummy		NUMBER := NULL;
  i			NUMBER := 0;
  j			NUMBER := 0;

  CURSOR source_instance IS
    SELECT edw.instance_code,
	   edw.warehouse_to_instance_link
    FROM   edw_source_instances edw
    WHERE  edw.enabled_flag = 'Y';

BEGIN

  -- --------------------------------------------------------
  -- Find the schema owner and tablespace
  -- ISC_EDW_BACK_SUM1_F is using
  -- --------------------------------------------------------
  IF (FND_INSTALLATION.Get_App_Info('ISC', l_status, l_industry, g_isc_schema))
    THEN NULL;
  END IF;

  SELECT tablespace_name
  INTO   g_tablespace
  FROM   all_tables
  WHERE  table_name = 'ISC_EDW_BACKLOG_SUM1_F'
  AND    owner = g_isc_schema;



  -- ----------------------------
  -- Findwarehouse database name
  -- ----------------------------
  select  name
  into	  l_db_name1
  from    v$database;


  -- --------------------------------------------------------
  -- Loop the complete set of instances
  -- --------------------------------------------------------
  FOR c in source_instance LOOP

    i := i + 1;
    g_rec(i).instance_code := c.instance_code;
    g_rec(i).db_link := c.warehouse_to_instance_link;

    BEGIN
      l_stmt := 'SELECT SET_OF_BOOKS_ID FROM ISCBV_EDW_BACKLOG_SUM1_FCV@'
		      ||g_rec(i).db_link
		      ||' WHERE ROWNUM < 2';
      EDW_LOG.Debug_Line('');
      EDW_LOG.Debug_Line(l_stmt);
      EXECUTE IMMEDIATE l_stmt INTO l_dummy;
      IF l_dummy IS NOT NULL
        THEN g_rec(i).valid := TRUE;
        ELSE g_rec(i).valid := FALSE;
      END IF;


      IF  g_rec(i).valid = TRUE
	THEN
	  BEGIN
	    l_stmt := 'SELECT instance_code from edw_local_instance@'||g_rec(i).db_link;
	    EDW_LOG.Debug_Line('');
	    EDW_LOG.Debug_Line(l_stmt);
	    EXECUTE IMMEDIATE l_stmt INTO g_rec(i).source_instance;

	    IF i > 1
	      THEN
	        FOR j IN 1..(i-1) LOOP
	          IF g_rec(j).source_instance = g_rec(i).source_instance
		    THEN g_rec(i).valid := FALSE;
		  END IF;
	        END LOOP;
	      END IF;
	  END;
      END IF;

   EXCEPTION
     WHEN OTHERS
       THEN g_rec(i).valid := FALSE;

    END;

    -- ----------------------------
    -- Check if same instance
    -- ----------------------------
    IF g_rec(i).valid
      THEN  l_stmt := 'SELECT name '||'FROM v$database@'||g_rec(i).db_link;

     	EDW_LOG.Debug_Line('');
      	EDW_LOG.Debug_Line(l_stmt);
      	EXECUTE IMMEDIATE l_stmt INTO l_db_name2;

     	IF (l_db_name1 = l_db_name2)
	  THEN g_rec(i).same_inst := TRUE;
     	  ELSE g_rec(i).same_inst := FALSE;
    	END IF;

    END IF;

  END LOOP;

END Init;



---------------------------------------------------
-- PROCEDURE DROP_TABLE
---------------------------------------------------
PROCEDURE Drop_Table (p_table_name IN varchar2) IS
  l_stmt varchar2(400);

BEGIN

  l_stmt:='DROP TABLE '||g_isc_schema||'.'||p_table_name;

  EDW_LOG.Debug_Line('');
  EDW_LOG.Debug_Line(l_stmt);
  EXECUTE IMMEDIATE l_stmt;


EXCEPTION
  WHEN G_TABLE_NOT_EXIST
    THEN NULL;   -- ORA 942: table not exist, no actions
  WHEN OTHERS
    THEN RAISE g_drop_table_failure;

END Drop_Table;


---------------------------------------------------
-- PROCEDURE TRUNCATE_TABLE
---------------------------------------------------
PROCEDURE Truncate_Table (p_table_name in varchar2) IS
  l_stmt varchar2(400);

BEGIN

  l_stmt:='TRUNCATE TABLE '||g_isc_schema||'.'||p_table_name;

  EDW_LOG.Debug_Line('');
  EDW_LOG.Debug_Line(l_stmt);
  EXECUTE IMMEDIATE l_stmt;

EXCEPTION
  WHEN OTHERS
    THEN
      g_errbuf  := sqlerrm;
      g_retcode := sqlcode;
      RAISE g_trunc_table_failure;

END Truncate_Table;


---------------------------------------------------
-- PROCEDURE Collect_Backlog
---------------------------------------------------
Procedure Collect_Backlog IS
  l_stmt varchar2(1000);

BEGIN

  -- ------------------------
  -- Create the table needed
  -- ------------------------
  l_stmt := 'CREATE TABLE '||g_isc_schema||'.ISC_EDW_BACK_SUM1_SUMM(
	BACKLOG_SUM1_PK		VARCHAR2(240),
	CUSTOMER_ID		VARCHAR2(80),
	FUNCTIONAL_CURRENCY	VARCHAR2(80),
	INSTANCE_CODE		VARCHAR2(80),
	SET_OF_BOOKS_ID		VARCHAR2(80),
	OPERATING_UNIT_ID	VARCHAR2(80),
	DAYS_OPEN		NUMBER,
	DLQT_BKLG_AMT_B		NUMBER,
	DLQT_BKLG_AMT_G		NUMBER,
	DLQT_BKLG_LINE_COUNT	NUMBER,
	MAX_DAYS_LATE		NUMBER,
	SHIP_BKLG_AMT_B		NUMBER,
	SHIP_BKLG_AMT_G		NUMBER,
	SHIP_BKLG_LINE_COUNT	NUMBER,
	DATE_BOOKED		DATE,
	DATE_OF_SNAPSHOT	DATE,
	HEADER_ID		VARCHAR2(80),
	ORDER_NUMBER		VARCHAR2(80))
    TABLESPACE '||g_tablespace||'
    NOLOGGING PCTFREE 5
    STORAGE (INITIAL 4K NEXT 32K)';

  EDW_LOG.Debug_Line('');
  EDW_LOG.Debug_Line(l_stmt);
  EXECUTE IMMEDIATE l_stmt;


  -- ------------------------
  -- Populate the table from
  -- all the valid sources
  -- ------------------------

  FOR i IN 1..g_rec.count LOOP

    IF (g_rec(i).valid)
      THEN
      l_stmt := 'INSERT INTO '||g_isc_schema||'.ISC_EDW_BACK_SUM1_SUMM T
	(BACKLOG_SUM1_PK,
	CUSTOMER_ID,
	FUNCTIONAL_CURRENCY,
	INSTANCE_CODE,
	SET_OF_BOOKS_ID,
	OPERATING_UNIT_ID,
	DAYS_OPEN,
	DLQT_BKLG_AMT_B,
	DLQT_BKLG_AMT_G,
	DLQT_BKLG_LINE_COUNT,
	MAX_DAYS_LATE,
	SHIP_BKLG_AMT_B,
	SHIP_BKLG_AMT_G,
	SHIP_BKLG_LINE_COUNT,
	DATE_BOOKED,
	DATE_OF_SNAPSHOT,
	HEADER_ID,
	ORDER_NUMBER)
      SELECT /*+ DRIVING_SITE(BACK) */
	BACKLOG_SUM1_PK,
	CUSTOMER_ID,
	FUNCTIONAL_CURRENCY,
	INSTANCE_CODE,
	SET_OF_BOOKS_ID,
	OPERATING_UNIT_ID,
	DAYS_OPEN,
	DLQT_BKLG_AMT_B,
	DLQT_BKLG_AMT_G,
	DLQT_BKLG_LINE_COUNT,
	MAX_DAYS_LATE,
	SHIP_BKLG_AMT_B,
	SHIP_BKLG_AMT_G,
	SHIP_BKLG_LINE_COUNT,
	DATE_BOOKED,
	DATE_OF_SNAPSHOT,
	HEADER_ID,
	ORDER_NUMBER
      FROM ISCBV_EDW_BACKLOG_SUM1_FCV';

      IF (g_rec(i).same_inst)
        THEN l_stmt := l_stmt||' BACK ';
        ELSE l_stmt := l_stmt||'@'||g_rec(i).db_link||' BACK ';
      END IF;

    EDW_LOG.Debug_Line('');
    EDW_LOG.Debug_Line(l_stmt);
    EXECUTE IMMEDIATE l_stmt;

    COMMIT;

    END IF;  -- g_rec(i).valid

  END LOOP;

EXCEPTION
  WHEN OTHERS
    THEN
      g_errbuf  := sqlerrm;
      g_retcode := sqlcode;
      RAISE g_collect_back_failure;

END Collect_Backlog;



--------------------------------------------------
-- PROCEDURE Populate_Backlog_Summary
---------------------------------------------------
PROCEDURE Populate_Backlog_Summary IS

  l_stmt 	VARCHAR2(4000);

BEGIN

  l_stmt := 'TRUNCATE TABLE '||g_isc_schema||'.ISC_EDW_BACKLOG_SUM1_F';

  EDW_LOG.Debug_Line('');
  EDW_LOG.Debug_Line(l_stmt);
  EXECUTE IMMEDIATE l_stmt;


  l_stmt := 'INSERT INTO ISC_EDW_BACKLOG_SUM1_F (
	 	  BACKLOG_SUM1_PK,
	 	  CREATION_DATE,
	 	  LAST_UPDATE_DATE,
	 	  CUSTOMER_FK_KEY,
	 	  FUNCTIONAL_CURRENCY_FK_KEY,
	 	  INSTANCE_FK_KEY,
	 	  SET_OF_BOOKS_FK_KEY,
	 	  OPERATING_UNIT_FK_KEY,
	 	  DAYS_OPEN,
	 	  DLQT_BKLG_AMT_B,
	 	  DLQT_BKLG_AMT_G,
	 	  DLQT_BKLG_LINE_COUNT,
	 	  MAX_DAYS_LATE,
	 	  SHIP_BKLG_AMT_B,
	 	  SHIP_BKLG_AMT_G,
	 	  SHIP_BKLG_LINE_COUNT,
	 	  CUSTOMER_NAME,
	 	  DATE_BOOKED,
	 	  DATE_OF_SNAPSHOT,
	 	  HEADER_ID,
	 	  INSTANCE_CODE,
	 	  OPERATING_UNIT_NAME,
	 	  ORDER_NUMBER)
	     SELECT summary.BACKLOG_SUM1_PK,
		    SYSDATE,
		    SYSDATE,
		    cust.TPRT_TRADE_PARTNER_PK_KEY,
		    curr.CRNC_CURRENCY_PK_KEY,
		    inst.INST_INSTANCE_PK_KEY,
		    sob.FABK_FA_BOOK_PK_KEY,
		    org.OPER_OPERATING_UNIT_PK_KEY,
		    summary.DAYS_OPEN,
		    summary.DLQT_BKLG_AMT_B,
		    summary.DLQT_BKLG_AMT_G,
		    summary.DLQT_BKLG_LINE_COUNT,
		    summary.MAX_DAYS_LATE,
		    summary.SHIP_BKLG_AMT_B,
		    summary.SHIP_BKLG_AMT_G,
		    summary.SHIP_BKLG_LINE_COUNT,
		    cust.TPRT_NAME,
		    summary.DATE_BOOKED,
		    summary.DATE_OF_SNAPSHOT,
		    summary.HEADER_ID,
		    summary.INSTANCE_CODE,
		    org.OPER_NAME,
		    summary.ORDER_NUMBER
	     FROM '||g_isc_schema||'.ISC_EDW_BACK_SUM1_SUMM 	summary,
		  edw_instance_m				inst,
		  edw_currency_m				curr,
		  edw_gl_book_m					sob,
		  edw_organization_m				org,
		  edw_trd_partner_m				cust
	     WHERE sob.fabk_fa_book_pk
		     = summary.set_of_books_id||''-''||summary.instance_code
	       AND inst.inst_instance_pk = summary.instance_code
	       AND cust.tplo_tpartner_loc_pk
		     = summary.customer_id||''-''||summary.instance_code||''-CUST_ACCT-TPRT''
	       AND org.orga_organization_pk
		     = summary.operating_unit_id||''-''||summary.instance_code
	       AND curr.crnc_currency_pk = summary.functional_currency';

  EDW_LOG.Debug_Line('');
  EDW_LOG.Debug_Line(l_stmt);
  EXECUTE IMMEDIATE l_stmt;

EXCEPTION
  WHEN OTHERS
    THEN
      g_errbuf  := sqlerrm;
      g_retcode := sqlcode;
      RAISE g_pop_back_sum_failure;

END Populate_Backlog_Summary;


-- ---------------------------------
-- Public PROCEDURES AND FUNCTIONS
-- ---------------------------------

--------------------------------------------------
-- PROCEDURE Populate
---------------------------------------------------
PROCEDURE Populate( errbuf	IN OUT NOCOPY VARCHAR2,
		    retcode	IN OUT NOCOPY VARCHAR2) IS

  l_errbuf		VARCHAR2(1000)  := NULL;
  l_retcode		VARCHAR2(200)   := NULL;
  l_dir			VARCHAR2(400);
  l_stmt		VARCHAR2(100);

BEGIN


  l_stmt := 'ALTER SESSION SET GLOBAL_NAMES = FALSE';
  EXECUTE IMMEDIATE l_stmt;

  IF (fnd_profile.value('EDW_DEBUG') = 'Y')
    THEN EDW_LOG.G_Debug := TRUE;
  END IF;

  l_dir := FND_PROFILE.Value('EDW_LOGFILE_DIR');
  IF l_dir IS NULL
    THEN  l_dir := '/sqlcom/log';
  END IF;
  EDW_LOG.Put_Names('ISC_EDW_BACKLOG_SUM1_F.log','ISC_EDW_BACKLOG_SUM1_F.out',l_dir);


  FII_UTIL.Put_Timestamp;
  EDW_LOG.Put_Line('');
  EDW_LOG.Put_Line('Initialization');

  FII_UTIL.Start_Timer;

  	Init;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Duration');

  EDW_LOG.Put_Line('');
  EDW_LOG.Put_Line('Dropping the Intermediary Summary Table');
  FII_UTIL.Start_Timer;

  	Drop_Table('ISC_EDW_BACK_SUM1_SUMM');

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Duration');

  EDW_LOG.Put_Line('');
  EDW_LOG.Put_Line('Truncating the Summary Table');
  FII_UTIL.Start_Timer;

	Truncate_Table('ISC_EDW_BACKLOG_SUM1_F');

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Duration');


  EDW_LOG.Put_Line('');
  EDW_LOG.Put_Line('Extracting Backlog information from all the source instances ');
  FII_UTIL.Start_Timer;

  	Collect_Backlog;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Duration');

  EDW_LOG.Put_Line('');
  EDW_LOG.Put_Line('Populate the Backlog Summary Table ');
  FII_UTIL.Start_Timer;

  	Populate_Backlog_Summary;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Duration');


EXCEPTION

  WHEN G_DROP_TABLE_FAILURE
    THEN
      errbuf  := g_errbuf;
      retcode := g_retcode;
      g_exception_msg  := retcode || ':' || errbuf;
      ROLLBACK;
      EDW_LOG.Put_Line('Drop Table has failed : '|| g_exception_msg);
      RAISE;


  WHEN G_TRUNC_TABLE_FAILURE
    THEN
      errbuf  := g_errbuf;
      retcode := g_retcode;
      g_exception_msg  := retcode || ':' || errbuf;
      ROLLBACK;
      EDW_LOG.Put_Line('Truncate Table has failed : '|| g_exception_msg);
      RAISE;


  WHEN G_COLLECT_BACK_FAILURE
    THEN
      errbuf  := g_errbuf;
      retcode := g_retcode;
      g_exception_msg  := retcode || ':' || errbuf;
      ROLLBACK;
      EDW_LOG.Put_Line('Collect Backlog has failed : '|| g_exception_msg);
      RAISE;

  WHEN G_POP_BACK_SUM_FAILURE
    THEN
      errbuf  := g_errbuf;
      retcode := g_retcode;
      g_exception_msg  := retcode || ':' || errbuf;
      ROLLBACK;
      EDW_LOG.Put_Line('Populate Backlog Summary has failed : '|| g_exception_msg);
      RAISE;

  WHEN OTHERS
    THEN
      errbuf  := g_errbuf;
      retcode := g_retcode;
      g_exception_msg  := retcode || ':' || errbuf;
      ROLLBACK;
      EDW_LOG.Put_Line('Other errors : '|| g_exception_msg);
      RAISE;


END Populate;

END ISC_EDW_BACKLOG_SUM1_F_C;

/
