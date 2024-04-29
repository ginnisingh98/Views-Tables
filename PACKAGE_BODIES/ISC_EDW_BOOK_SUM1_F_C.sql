--------------------------------------------------------
--  DDL for Package Body ISC_EDW_BOOK_SUM1_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_EDW_BOOK_SUM1_F_C" AS
/* $Header: ISCSCF2B.pls 115.14 2003/03/11 02:32:57 blindaue ship $ */

 g_errbuf			VARCHAR2(2000) 	:= NULL;
 g_retcode			VARCHAR2(200) 	:= NULL;
 g_row_count         		NUMBER		:= 0;
 g_push_from_date		DATE 		:= NULL;
 g_push_to_date			DATE 		:= NULL;
 g_push_from_booked_date	DATE 		:= NULL;
 g_push_to_booked_date		DATE 		:= NULL;
 g_exception_msg		VARCHAR2(2000)	:= NULL;

-----------------------------------------------------------
--  PROCEDURE TRUNCATE_STG
-----------------------------------------------------------

PROCEDURE TRUNCATE_STG IS
 l_isc_schema          	VARCHAR2(30);
 l_stmt  		VARCHAR2(200);
 l_status		VARCHAR2(30);
 l_industry		VARCHAR2(30);

BEGIN
      	IF (FND_INSTALLATION.GET_APP_INFO('ISC', l_status, l_industry, l_isc_schema))
	THEN  	l_stmt := 'TRUNCATE TABLE ' || l_isc_schema ||'.ISC_EDW_BOOK_SUM1_FSTG';
         	EXECUTE IMMEDIATE l_stmt;
      	END IF;
END;


-----------------------------------------------------------
--  PROCEDURE DELETE_STG
-----------------------------------------------------------

PROCEDURE DELETE_STG  IS

BEGIN
   	DELETE ISC_EDW_BOOK_SUM1_FSTG
   	WHERE  COLLECTION_STATUS = 'LOCAL READY'
   	  AND  INSTANCE = (SELECT INSTANCE_CODE
                     	   FROM EDW_LOCAL_INSTANCE);
END;


--------------------------------------------------
--FUNCTION LOCAL_SAME_AS_REMOTE
---------------------------------------------------

FUNCTION LOCAL_SAME_AS_REMOTE RETURN BOOLEAN IS

 l_instance1                VARCHAR2(100) := NULL;
 l_instance2                VARCHAR2(100) := NULL;

BEGIN
	SELECT instance_code
   	INTO   l_instance1
   	FROM   edw_local_instance;

   	SELECT instance_code
   	INTO   l_instance2
   	FROM   edw_local_instance@edw_apps_to_wh;

   	IF (l_instance1 = l_instance2)
	THEN RETURN TRUE;
   	END IF;

RETURN FALSE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
   	g_errbuf  := sqlerrm;
     	g_retcode := sqlcode;
     	RETURN FALSE;
END;


--------------------------------------------------
--PROCEDURE SET_STATUS_READY
---------------------------------------------------

FUNCTION SET_STATUS_READY RETURN NUMBER IS

BEGIN

   	UPDATE ISC_EDW_BOOK_SUM1_FSTG
   	SET    COLLECTION_STATUS = 'READY'
   	WHERE  COLLECTION_STATUS = 'LOCAL READY'
   	AND    INSTANCE = (SELECT INSTANCE_CODE
                     	   FROM EDW_LOCAL_INSTANCE);

RETURN(sql%rowcount);

EXCEPTION
   WHEN OTHERS THEN
     	g_errbuf  := sqlerrm;
     	g_retcode := sqlcode;
   RETURN(-1);

END;


-----------------------------------------------------------
--PROCEDURE PUSH_TO_LOCAL
-----------------------------------------------------------

FUNCTION PUSH_TO_LOCAL(p_seq_id IN NUMBER) RETURN NUMBER IS

BEGIN

   -- ------------------------------------------------
   -- We set the COLLECTION_STATUS to 'LOCAL READY'.
   -- In case of source=target, we need to separate
   -- out the records in progress vs the records which
   -- is ready to be picked up by collection enginee.
   -- In our case, we consider the records to be in
   -- progress until all the child processes have
   -- completed successfully.
   -- ------------------------------------------------
	INSERT INTO ISC_EDW_BOOK_SUM1_FSTG(
		BOOKINGS_PK,
		BILL_TO_CUST_FK,
		CURRENCY_BASE_FK,
		DATE_BOOKED_FK,
		INSTANCE_FK,
		OPERATING_UNIT_FK,
		SET_OF_BOOKS_FK,
		BOOKED_AMT_B,
		BOOKED_AMT_G,
		BOOKED_LIST_AMT_B,
		BOOKED_LIST_AMT_G,
		FULFILLED_AMT_B,
		FULFILLED_AMT_G,
		INVOICED_AMT_B,
		INVOICED_AMT_G,
		SHIPPED_AMT_B,
		SHIPPED_AMT_G,
		DATE_BOOKED,
		DATE_LATEST_FULFILLED,
		DATE_LATEST_SHIP,
		DATE_ORDERED,
		HEADER_ID,
		INSTANCE,
		ORDER_NUMBER,
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
		USER_ATTRIBUTE11,
		USER_ATTRIBUTE12,
		USER_ATTRIBUTE13,
		USER_ATTRIBUTE14,
		USER_ATTRIBUTE15,
		USER_ATTRIBUTE16,
		USER_ATTRIBUTE17,
		USER_ATTRIBUTE18,
		USER_ATTRIBUTE19,
		USER_ATTRIBUTE20,
		USER_ATTRIBUTE21,
		USER_ATTRIBUTE22,
		USER_ATTRIBUTE23,
		USER_ATTRIBUTE24,
		USER_ATTRIBUTE25,
		USER_FK1,
		USER_FK2,
		USER_FK3,
		USER_FK4,
		USER_FK5,
		USER_MEASURE1,
		USER_MEASURE2,
		USER_MEASURE3,
		USER_MEASURE4,
		USER_MEASURE5,
		OPERATION_CODE,
		COLLECTION_STATUS)
	SELECT
		BOOKINGS_PK,
		BILL_TO_CUST_FK,
		CURRENCY_BASE_FK,
		DATE_BOOKED_FK,
		INSTANCE_FK,
		OPERATING_UNIT_FK,
		SET_OF_BOOKS_FK,
		BOOKED_AMT_B,
		BOOKED_AMT_G,
		BOOKED_LIST_AMT_B,
		BOOKED_LIST_AMT_G,
		FULFILLED_AMT_B,
		FULFILLED_AMT_G,
		INVOICED_AMT_B,
		INVOICED_AMT_G,
		SHIPPED_AMT_B,
		SHIPPED_AMT_G,
		DATE_BOOKED,
		DATE_LATEST_FULFILLED,
		DATE_LATEST_SHIP,
		DATE_ORDERED,
		HEADER_ID,
		INSTANCE,
		ORDER_NUMBER,
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
		USER_ATTRIBUTE11,
		USER_ATTRIBUTE12,
		USER_ATTRIBUTE13,
		USER_ATTRIBUTE14,
		USER_ATTRIBUTE15,
		USER_ATTRIBUTE16,
		USER_ATTRIBUTE17,
		USER_ATTRIBUTE18,
		USER_ATTRIBUTE19,
		USER_ATTRIBUTE20,
		USER_ATTRIBUTE21,
		USER_ATTRIBUTE22,
		USER_ATTRIBUTE23,
		USER_ATTRIBUTE24,
		USER_ATTRIBUTE25,
		USER_FK1,
		USER_FK2,
		USER_FK3,
		USER_FK4,
		USER_FK5,
		USER_MEASURE1,
		USER_MEASURE2,
		USER_MEASURE3,
		USER_MEASURE4,
		USER_MEASURE5,
		NULL, -- OPERATION_CODE
		'LOCAL READY'
	FROM ISC_EDW_BOOK_SUM1_F_FCV
	WHERE seq_id    = p_seq_id;
	COMMIT;

RETURN(sql%rowcount);

EXCEPTION
   WHEN OTHERS THEN
     	g_errbuf  := sqlerrm;
     	g_retcode := sqlcode;
   RETURN(-1);
END;


-----------------------------------------------------------
--  FUNCTION PUSH_REMOTE : GLOBAL PUSH thru DBLINK
-----------------------------------------------------------
FUNCTION PUSH_REMOTE RETURN NUMBER IS

BEGIN

	INSERT INTO ISC_EDW_BOOK_SUM1_FSTG@EDW_APPS_TO_WH(
		BOOKINGS_PK,
		BILL_TO_CUST_FK,
		CURRENCY_BASE_FK,
		DATE_BOOKED_FK,
		INSTANCE_FK,
		OPERATING_UNIT_FK,
		SET_OF_BOOKS_FK,
		BOOKED_AMT_B,
		BOOKED_AMT_G,
		BOOKED_LIST_AMT_B,
		BOOKED_LIST_AMT_G,
		FULFILLED_AMT_B,
		FULFILLED_AMT_G,
		INVOICED_AMT_B,
		INVOICED_AMT_G,
		SHIPPED_AMT_B,
		SHIPPED_AMT_G,
		DATE_BOOKED,
		DATE_LATEST_FULFILLED,
		DATE_LATEST_SHIP,
		DATE_ORDERED,
		HEADER_ID,
		INSTANCE,
		ORDER_NUMBER,
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
		USER_ATTRIBUTE11,
		USER_ATTRIBUTE12,
		USER_ATTRIBUTE13,
		USER_ATTRIBUTE14,
		USER_ATTRIBUTE15,
		USER_ATTRIBUTE16,
		USER_ATTRIBUTE17,
		USER_ATTRIBUTE18,
		USER_ATTRIBUTE19,
		USER_ATTRIBUTE20,
		USER_ATTRIBUTE21,
		USER_ATTRIBUTE22,
		USER_ATTRIBUTE23,
		USER_ATTRIBUTE24,
		USER_ATTRIBUTE25,
		USER_FK1,
		USER_FK2,
		USER_FK3,
		USER_FK4,
		USER_FK5,
		USER_MEASURE1,
		USER_MEASURE2,
		USER_MEASURE3,
		USER_MEASURE4,
		USER_MEASURE5,
		OPERATION_CODE,
		COLLECTION_STATUS)
	SELECT
		BOOKINGS_PK,
		BILL_TO_CUST_FK,
		CURRENCY_BASE_FK,
		DATE_BOOKED_FK,
		INSTANCE_FK,
		OPERATING_UNIT_FK,
		SET_OF_BOOKS_FK,
		BOOKED_AMT_B,
		BOOKED_AMT_G,
		BOOKED_LIST_AMT_B,
		BOOKED_LIST_AMT_G,
		FULFILLED_AMT_B,
		FULFILLED_AMT_G,
		INVOICED_AMT_B,
		INVOICED_AMT_G,
		SHIPPED_AMT_B,
		SHIPPED_AMT_G,
		DATE_BOOKED,
		DATE_LATEST_FULFILLED,
		DATE_LATEST_SHIP,
		DATE_ORDERED,
		HEADER_ID,
		INSTANCE,
		ORDER_NUMBER,
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
		USER_ATTRIBUTE11,
		USER_ATTRIBUTE12,
		USER_ATTRIBUTE13,
		USER_ATTRIBUTE14,
		USER_ATTRIBUTE15,
		USER_ATTRIBUTE16,
		USER_ATTRIBUTE17,
		USER_ATTRIBUTE18,
		USER_ATTRIBUTE19,
		USER_ATTRIBUTE20,
		USER_ATTRIBUTE21,
		USER_ATTRIBUTE22,
		USER_ATTRIBUTE23,
		USER_ATTRIBUTE24,
		USER_ATTRIBUTE25,
		NVL(USER_FK1,'NA_EDW'),
		NVL(USER_FK2,'NA_EDW'),
		NVL(USER_FK3,'NA_EDW'),
		NVL(USER_FK4,'NA_EDW'),
		NVL(USER_FK5,'NA_EDW'),
		USER_MEASURE1,
		USER_MEASURE2,
		USER_MEASURE3,
		USER_MEASURE4,
		USER_MEASURE5,
		NULL, -- OPERATION_CODE
		'READY'
	FROM ISC_EDW_BOOK_SUM1_FSTG;

RETURN(sql%rowcount);

EXCEPTION
   WHEN OTHERS THEN
     	g_errbuf  := sqlerrm;
     	g_retcode := sqlcode;
   RETURN(-1);
END;


---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE
---------------------------------------------------

FUNCTION IDENTIFY_CHANGE( p_count           	OUT NOCOPY	NUMBER) RETURN NUMBER
IS

 l_seq_id	       NUMBER 		:= -1;
 l_isc_schema          VARCHAR2(30);
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);

BEGIN

 p_count := 0;

	SELECT isc_tmp_book_sum1_s.nextval
	INTO l_seq_id
	FROM dual;

   --  --------------------------------------------
   --  Populate rowid into isc_tmp_book_sum1 table based
   --  on header or line last update date and order booked date
   --  --------------------------------------------

	INSERT
	     INTO    isc_tmp_book_sum1(
	             PK1,
	             SEQ_ID)
	     SELECT  /*+ PARALLEL(h) */
		     distinct to_char(h.header_id),
	             l_seq_id
	     FROM    oe_order_headers_all h,
		     oe_order_lines_all l
	     WHERE   h.last_update_date between g_push_from_date AND g_push_to_date
	       AND   h.booked_date between g_push_from_booked_date AND g_push_to_booked_date
	       AND   l.header_id = h.header_id
	     UNION
	     SELECT  /*+ PARALLEL(l) */
		     distinct to_char(l.header_id),
	             l_seq_id
	     FROM    oe_order_lines_all l,
		     oe_order_headers_all h
	     WHERE   l.last_update_date between g_push_from_date AND g_push_to_date
	       AND   h.booked_date between g_push_from_booked_date AND g_push_to_booked_date
	       AND   l.header_id = h.header_id;


	p_count := sql%rowcount;

	COMMIT;

RETURN(l_seq_id);

EXCEPTION
   WHEN OTHERS THEN
	g_errbuf  := sqlerrm;
	g_retcode := sqlcode;
RETURN(-1);

END;


-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------

Procedure Push(	errbuf			IN OUT NOCOPY VARCHAR2,
                retcode			IN OUT NOCOPY VARCHAR2,
                p_from_date		IN	VARCHAR2,
                p_to_date		IN	VARCHAR2,
                p_from_booked_date	IN	VARCHAR2,
                p_to_booked_date	IN	VARCHAR2) IS

 l_fact_name		VARCHAR2(30)	:= 'ISC_EDW_BOOK_SUM1_F'  ;
 l_exception_msg	VARCHAR2(2000)	:= NULL;
 l_from_date		DATE		:= NULL;
 l_to_date	   	DATE		:= NULL;
 l_from_booked_date	DATE		:= NULL;
 l_to_booked_date	DATE		:= NULL;

 l_seq_id_line        	NUMBER		:= -1;

 l_row_count		NUMBER		:= 0;

 l_push_local_failure	EXCEPTION;
 l_push_remote_failure	EXCEPTION;
 l_set_status_failure	EXCEPTION;
 l_iden_change_failure	EXCEPTION;

/*  -------------------------------------------
    Put any additional developer variables here
    -------------------------------------------*/
BEGIN

 errbuf  := NULL;
 retcode := '0';

  	l_from_date 		:= to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
  	l_to_date   		:= to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  	l_from_booked_date 	:= to_date(p_from_booked_date,'YYYY/MM/DD HH24:MI:SS');
  	l_to_booked_date   	:= to_date(p_to_booked_date, 'YYYY/MM/DD HH24:MI:SS');

	IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name))
	THEN	errbuf := fnd_message.get;
	   	RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
	END IF;

	ISC_EDW_BOOK_SUM1_F_C.g_push_from_date := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);

	ISC_EDW_BOOK_SUM1_F_C.g_push_to_date := nvl(l_to_date,
		EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

	ISC_EDW_BOOK_SUM1_F_C.g_push_from_booked_date := nvl(l_from_booked_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);

	ISC_EDW_BOOK_SUM1_F_C.g_push_to_booked_date := nvl(l_to_booked_date,
		EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

	EDW_LOG.Put_Line( 'The collection range is from '||
	        to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
	        to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
	EDW_LOG.Put_Line( 'The booked date range is from '||
	        to_char(g_push_from_booked_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
	        to_char(g_push_to_booked_date,'MM/DD/YYYY HH24:MI:SS'));
	EDW_LOG.Put_Line(' ');

	IF (NOT LOCAL_SAME_AS_REMOTE)
	THEN   	TRUNCATE_STG;
	ELSE   	DELETE_STG;
	END IF;

      --  --------------------------------------------
      --  Identify Change for Booked Orders Lines
      --  --------------------------------------------

	EDW_LOG.Put_Line('Identifying changed Booked orders lines');

FII_UTIL.Start_Timer;

	l_seq_id_line := IDENTIFY_CHANGE(l_row_count);

FII_UTIL.Stop_Timer;
FII_UTIL.Print_Timer('Identified '||l_row_count||' changed records in');

      	IF (l_seq_id_line = -1)
	THEN
	RAISE l_iden_change_failure;
      	END IF;


      --  --------------------------------------------
      --  Push to Local staging table
      --  --------------------------------------------

      	EDW_LOG.Put_Line(' ');
      	EDW_LOG.Put_Line('Pushing data to local staging');

FII_UTIL.Start_Timer;

      	g_row_count := PUSH_TO_LOCAL(l_seq_id_line);

FII_UTIL.Stop_Timer;
FII_UTIL.Print_Timer('Process Time');

	IF (g_row_count = -1)
      	THEN RAISE L_push_local_failure;
      	END IF;

      	EDW_LOG.Put_Line('Inserted '||nvl(g_row_count,0)||' rows into the local staging table');
      	EDW_LOG.Put_Line(' ');

      	COMMIT;


      -- --------------------------------------------
      -- Delete all temp tables' record
      -- --------------------------------------------

      	DELETE isc_tmp_book_sum1
      	WHERE seq_id IN ( l_seq_id_line );
      	COMMIT;

      	IF (NOT LOCAL_SAME_AS_REMOTE) THEN
           -- -----------------------------------------------
           -- The target warehouse is not the same database
           -- as the source OLTP, which is the typical case.
           -- We move data from local to remote staging table
           -- and clean up local staging
           -- -----------------------------------------------

        EDW_LOG.Put_Line(' ');
        EDW_LOG.Put_Line('Moving data from local staging table to remote staging table');

FII_UTIL.Start_Timer;

      	g_row_count := PUSH_REMOTE;

FII_UTIL.Stop_Timer;
FII_UTIL.Print_Timer('Duration');

        IF (g_row_count = -1) THEN RAISE l_push_remote_failure; END IF;

        EDW_LOG.Put_Line(' ');
        EDW_LOG.Put_Line('Cleaning local staging table');

FII_UTIL.Start_Timer;

        TRUNCATE_STG;

FII_UTIL.Stop_Timer;
FII_UTIL.Print_Timer('Duration');

        ELSE
           -- -----------------------------------------------
           -- The target warehouse is the same database
           -- as the source OLTP.  We set the status of all our
           -- records status 'LOCAL READY' to 'READY'
           -- -----------------------------------------------

        EDW_LOG.Put_Line(' ');
        EDW_LOG.Put_Line('Marking records in staging table with READY status');

FII_UTIL.Start_Timer;

        g_row_count := SET_STATUS_READY;

FII_UTIL.Stop_Timer;
FII_UTIL.Print_Timer('Duration');

        IF (g_row_count = -1)
	THEN RAISE l_set_status_failure;
	END IF;

       	END IF;


      -----------------------------------------------
      -- No exception raised so far.  Successful.  Call
      -- wrapup to commit and insert messages into logs
      -- -----------------------------------------------
      	EDW_LOG.Put_Line(' ');
      	EDW_LOG.Put_Line('Inserted '||nvl(g_row_count,0)||' rows into the staging table');
      	EDW_LOG.Put_Line(' ');

      	EDW_COLLECTION_UTIL.Wrapup(
		TRUE,
		g_row_count,
		NULL,
		ISC_EDW_BOOK_SUM1_F_C.g_push_from_date,
		ISC_EDW_BOOK_SUM1_F_C.g_push_to_date);


/*--------------------------------------------------------------------------
 END OF Collection , Developer Customizable Section
 ---------------------------------------------------------------------------*/

EXCEPTION

   WHEN L_PUSH_LOCAL_FAILURE THEN
	errbuf  := g_errbuf;
      	retcode := g_retcode;
      	l_exception_msg  := errbuf;
      	ROLLBACK;   -- Rollback insert into local staging
      	EDW_LOG.Put_Line('Inserting into local staging has failed : '|| l_exception_msg);
      	EDW_COLLECTION_UTIL.Wrapup(
		FALSE,
		g_row_count,
		NULL,
		ISC_EDW_BOOK_SUM1_F_C.g_push_from_date,
		ISC_EDW_BOOK_SUM1_F_C.g_push_to_date);
      	RAISE;

   WHEN L_PUSH_REMOTE_FAILURE THEN
      	errbuf  := g_errbuf;
      	retcode := g_retcode;
      	l_exception_msg  := errbuf;
      	ROLLBACK;      -- rollback any insert into remote site
      	TRUNCATE_STG;  -- Cleanup local staging table
      	EDW_LOG.Put_Line('Data migration from local to remote staging has failed : '|| l_exception_msg);
      	EDW_COLLECTION_UTIL.Wrapup(
		FALSE,
		g_row_count,
		NULL,
		ISC_EDW_BOOK_SUM1_F_C.g_push_from_date,
		ISC_EDW_BOOK_SUM1_F_C.g_push_to_date);
      	RAISE;

   WHEN L_SET_STATUS_FAILURE THEN
      	errbuf  := g_errbuf;
      	retcode := g_retcode;
      	l_exception_msg  := errbuf;
      	ROLLBACK;      -- Rollback the status to 'LOCAL READY'
      	DELETE_STG;    -- Delete records in staging with status 'LOCAL READY'
      	COMMIT;
      	EDW_LOG.Put_Line('Setting status to READY has failed : '|| l_exception_msg);
      	EDW_COLLECTION_UTIL.Wrapup(
		FALSE,
		g_row_count,
		NULL,
		ISC_EDW_BOOK_SUM1_F_C.g_push_from_date,
		ISC_EDW_BOOK_SUM1_F_C.g_push_to_date);
      	RAISE;

   WHEN L_IDEN_CHANGE_FAILURE THEN
      	errbuf  := g_errbuf;
      	retcode := g_retcode;
      	l_exception_msg  := errbuf;
      	DELETE isc_tmp_book_sum1
      	WHERE seq_id IN ( l_seq_id_line);
      	COMMIT;
      	EDW_LOG.Put_Line('Identifying changed records has Failed : '|| l_exception_msg);
      	EDW_COLLECTION_UTIL.Wrapup(
		FALSE,
		g_row_count,
		NULL,
		ISC_EDW_BOOK_SUM1_F_C.g_push_from_date,
		ISC_EDW_BOOK_SUM1_F_C.g_push_to_date);
      	RAISE;

   WHEN OTHERS THEN
      	errbuf  := g_errbuf;
      	retcode := g_retcode;
      	l_exception_msg  := errbuf;
      	ROLLBACK;
      	EDW_LOG.Put_Line('Other errors : '|| l_exception_msg);
      	EDW_COLLECTION_UTIL.Wrapup(
		FALSE,
		g_row_count,
		NULL,
		ISC_EDW_BOOK_SUM1_F_C.g_push_from_date,
		ISC_EDW_BOOK_SUM1_F_C.g_push_to_date);
      	RAISE;
END;
END ISC_EDW_BOOK_SUM1_F_C;

/
