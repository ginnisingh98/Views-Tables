--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPM_JOB_RSRC_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPM_JOB_RSRC_F_C" AS
/* $Header: OPIMOJRB.pls 115.13 2004/01/02 19:06:05 bthammin noship $ */
 g_errbuf	   	      VARCHAR2(2000) := NULL;
 g_retcode		      VARCHAR2(200) := NULL;
 g_row_count         	NUMBER:=0;
 g_push_from_date	      DATE := NULL;
 g_push_to_date		DATE := NULL;
 g_seq_id               NUMBER:=0;
-- ---------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-- ---------------------------------
/* Find if Source and target are on same instance */
FUNCTION LOCAL_SAME_AS_REMOTE RETURN BOOLEAN
 IS
 l_source                Varchar2(100) :=Null;
 l_Target                Varchar2(100) :=Null;
 BEGIN
   SELECT instance_code INTO   l_source
   FROM   edw_local_instance;

   SELECT instance_code INTO   l_target
   FROM   edw_local_instance@edw_apps_to_wh;

   IF (l_source = l_target) THEN
      RETURN TRUE;
   END IF;
   RETURN FALSE;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN FALSE;
 END LOCAL_SAME_AS_REMOTE;


/* Procedure to Print Missing Rows */
PROCEDURE PRINT_MISSING_ROWS
IS
/* Define Missing Rate Cursor for Job Detail */
Cursor Missing_Rate is
SELECT JOB_RSRC_PK,TRX_DATE_FK,SOB_CURRENCY_FK
FROM
   OPI_EDW_JOB_RSRC_FSTG
WHERE
    COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
AND JOB_RSRC_PK like '%OPM'
AND SUBSTRB(JOB_RSRC_PK,instrB(JOB_RSRC_PK,'-',-1,3)+1,
                      instrB(JOB_RSRC_PK,'-',-1,2)-1-instrB(JOB_RSRC_PK,'-',-1,3))
    in (select PRIMARY_KEY from
                              OPI_EDW_OPM_JOB_RSRC_INC
                              WHERE SEQ_ID is NULL);

BEGIN
  /* Print Header */
  edw_log.put_line(' ');
  edw_log.put_line ('Identified Missing Rows              Date:'||SYSDATE);

  edw_log.put_line (' ');
  edw_log.put_line (' ');

  edw_log.put_line ('Primary Key is PM_BTCH_HDR.Batch_id - PM_MATL_DTL.line_id -
                                     PM_OPRN_DTL.BATCHSTEP_NO - PM_OPRN_DTL.RESOURCES - PM_OPRN_DTL.ACTIVITY
                                     - PM_OPRN_DTL.BATCHSTEPLINE_ID - instance_code - OPM');
  edw_log.put_line ('-----------------------------------------');
  edw_log.put_line ('Primary Key / Currency / Transaction Date');
  edw_log.put_line ('-----------------------------------------');
  /* Print Rows */

  For l_rows in missing_rate loop
      edw_log.put_line (l_rows.JOB_RSRC_PK||' / '||l_rows.SOB_CURRENCY_FK||' / '||l_rows.TRX_DATE_FK);
  end loop;
  edw_log.put_line(' ');
  edw_log.put_line(' ');
EXCEPTION
 WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     edw_log.put_line('Raised Exception from PRINT_MISSING_RATE '||sqlerrm);
END;

/* Procedure to Push missing rows */
PROCEDURE PUSH_MISSING_ROWS
 IS
l_count number;
 BEGIN
 /* Delete the incremental table before inserting new data */
  DELETE OPI_EDW_OPM_JOB_RSRC_INC;
  edw_log.put_line(' ');
  edw_log.Put_line('Identifying Missing Rate Rows ');
  edw_log.put_line(' ');
  SELECT count(*) into l_count from OPI_EDW_JOB_RSRC_FSTG where
       COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
       AND JOB_RSRC_PK like '%OPM';
  IF l_count > 0 THEN

      /* insert into Incremental table all line_id where Currency is missing */
	INSERT /*+ parallel(OPI_EDW_OPM_JOB_RSRC_INC) */
  	into OPI_EDW_OPM_JOB_RSRC_INC(PRIMARY_KEY,view_id,seq_id)
      SELECT
        BATCHSTEPLINE_ID,
        1,
        NULL
      FROM
         PM_OPRN_DTL
      WHERE
         BATCHSTEPLINE_ID
          in ( SELECT SUBSTRB(JOB_RSRC_PK,instrB(JOB_RSRC_PK,'-',-1,3)+1,
                      instrB(JOB_RSRC_PK,'-',-1,2)-1-instrB(JOB_RSRC_PK,'-',-1,3))
                 from OPI_EDW_JOB_RSRC_FSTG
                 WHERE  COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
                 AND JOB_RSRC_PK like '%OPM');
         /* The above Sub selcet has a reverse string traverse as the batchlineid is 3 from right in PK KEY */
    edw_log.Put_line(to_char(sql%rowcount) ||' rows missing Currency Rate Conversion');
    edw_log.put_line(' ');
    Commit;
    edw_log.put_line ('Printing Missing Rate Rows Output');
    edw_log.put_line(' ');
    PRINT_MISSING_ROWS;
    edw_log.put_line ('Output Printed. You can view the output using ''View output'' option from Request page');
    edw_log.put_line(' ');

    /*Delete all missing rows from FSTG table if source and target are on same instance*/
     IF (LOCAL_SAME_AS_REMOTE) THEN
         DELETE OPI_EDW_JOB_RSRC_FSTG
               WHERE COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
                 AND JOB_RSRC_PK like '%OPM';
        edw_log.Put_line(to_char(sql%rowcount) ||' missing Currency Rate Conversion rows deleted from Staging table');
     END IF;
    /* Deletion completed */
  ELSE
     edw_log.Put_line('0 rows missing Currency Rate Conversion');
  END IF;
 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
edw_log.put_line('Raised Exception '||sqlerrm);
END;

-----------------------------------------------------------
--PROCEDURE PUSH_TO_LOCAL
-----------------------------------------------------------
 FUNCTION PUSH_TO_LOCAL(p_view_id NUMBER, p_seq_id NUMBER) RETURN NUMBER IS
   l_no_rows number;
 BEGIN
   -- ------------------------------------------------
   -- We set the COLLECTION_STATUS to 'LOCAL READY'.
   -- In case of source=target, we need to separate
   -- out the records in progress vs the records which
   -- is ready to be picked up by collection enginee.
   -- In our case, we consider the records to be in
   -- progress until the push_to_local procedure for
   -- all view types  has  completed successfully.
   -- ------------------------------------------------
     INSERT INTO OPI_EDW_JOB_RSRC_FSTG(
      ACTIVITY_FK,
ACT_CMPL_DATE ,
ACT_RSRC_COUNT,
ACT_RSRC_QTY  ,
ACT_RSRC_USAGE  ,
ACT_RSRC_USAGE_VAL_B ,
ACT_RSRC_USAGE_VAL_G  ,
ACT_RSRC_VAL_B  ,
ACT_RSRC_VAL_G ,
ACT_STRT_DATE ,
AVL_RSRC  ,
COLLECTION_STATUS,
CREATION_DATE ,
DEPARTMENT,
EXTD_RSRC_COST ,
INSTANCE_FK,
ITEM_FK ,
JOB_NO,
JOB_RSRC_PK ,
LAST_UPDATE_DATE,
LOCATOR_FK ,
OPERATION_CODE ,
OPERATION_SEQ_NO ,
OPRN_FK ,
PLN_CMPL_DATE,
PLN_RSRC_COUNT  ,
PLN_RSRC_QTY ,
PLN_RSRC_USAGE  ,
PLN_RSRC_USAGE_VAL_B,
PLN_RSRC_USAGE_VAL_G,
PLN_RSRC_VAL_B  ,
PLN_RSRC_VAL_G ,
PLN_STRT_DATE ,
QTY_UOM_FK ,
RSRC_FK ,
SOB_CURRENCY_FK ,
STND_RSRC_USAGE,
TRX_DATE_FK ,
USAGE_UOM_FK ,
USER_ATTRIBUTE1 ,
USER_ATTRIBUTE10 ,
USER_ATTRIBUTE11 ,
USER_ATTRIBUTE12 ,
USER_ATTRIBUTE13,
USER_ATTRIBUTE14 ,
USER_ATTRIBUTE15 ,
USER_ATTRIBUTE2 ,
USER_ATTRIBUTE3 ,
USER_ATTRIBUTE4 ,
USER_ATTRIBUTE5 ,
USER_ATTRIBUTE6 ,
USER_ATTRIBUTE7 ,
USER_ATTRIBUTE8 ,
USER_ATTRIBUTE9 ,
USER_FK1 ,
USER_FK2 ,
USER_FK3 ,
USER_FK4 ,
USER_FK5 ,
USER_MEASURE1  ,
USER_MEASURE2 ,
USER_MEASURE3  ,
USER_MEASURE4 ,
USER_MEASURE5
)
  SELECT /*+ ALL_ROWS */
ACTIVITY_FK,
ACT_CMPL_DATE ,
ACT_RSRC_COUNT,
ACT_RSRC_QTY  ,
ACT_RSRC_USAGE  ,
ACT_RSRC_USAGE_VAL_B ,
ACT_RSRC_USAGE_VAL_G  ,
ACT_RSRC_VAL_B  ,
ACT_RSRC_VAL_G ,
ACT_STRT_DATE ,
AVL_RSRC  ,
DECODE(PLN_RSRC_USAGE_VAL_G,-1,'RATE NOT AVAILABLE',-2,'INVALID CURRENCY','LOCAL READY'),
NULL ,
DEPARTMENT,
EXTD_RSRC_COST ,
INSTANCE_FK,
ITEM_FK ,
JOB_NO,
JOB_RSRC_PK ,
LAST_UPDATE_DATE,
LOCATOR_FK ,
NULL OPERATION_CODE ,
OPERATION_SEQ_NO ,
OPRN_FK ,
PLN_CMPL_DATE,
PLN_RSRC_COUNT  ,
PLN_RSRC_QTY ,
PLN_RSRC_USAGE  ,
PLN_RSRC_USAGE_VAL_B,
PLN_RSRC_USAGE_VAL_G  ,
PLN_RSRC_VAL_B  ,
PLN_RSRC_VAL_G ,
PLN_STRT_DATE ,
QTY_UOM_FK ,
RSRC_FK ,
SOB_CURRENCY_FK ,
STND_RSRC_USAGE,
TRX_DATE_FK ,
USAGE_UOM_FK ,
USER_ATTRIBUTE1 ,
USER_ATTRIBUTE10 ,
USER_ATTRIBUTE11 ,
USER_ATTRIBUTE12 ,
USER_ATTRIBUTE13,
USER_ATTRIBUTE14 ,
USER_ATTRIBUTE15 ,
USER_ATTRIBUTE2 ,
USER_ATTRIBUTE3 ,
USER_ATTRIBUTE4 ,
USER_ATTRIBUTE5 ,
USER_ATTRIBUTE6 ,
USER_ATTRIBUTE7 ,
USER_ATTRIBUTE8 ,
USER_ATTRIBUTE9 ,
USER_FK1 ,
USER_FK2 ,
USER_FK3 ,
USER_FK4 ,
USER_FK5 ,
USER_MEASURE1 ,
USER_MEASURE2 ,
USER_MEASURE3 ,
USER_MEASURE4 ,
USER_MEASURE5
    FROM OPI_EDW_OPM_JOB_RSRC_FCV
    WHERE view_id   = p_view_id
    AND   seq_id    = p_seq_id;
COMMIT;
   l_no_rows := sql%rowcount;
/* Push Currency Conversion Missing Rows */
   PUSH_MISSING_ROWS;
   RETURN l_no_rows;
 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);
 END;
-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

FUNCTION IDENTIFY_OPM_CHANGE(p_view_id            IN          NUMBER,
                             p_count              OUT NOCOPY  NUMBER)
 RETURN NUMBER
 IS
 l_seq_id	           NUMBER := -1;
 l_opi_schema          VARCHAR2(30);
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);
 BEGIN
   p_count := 0;
   select OPI_EDW_JOB_RSRC_INC_S.nextval into l_seq_id from dual;
	INSERT /*+ parallel(OPI_EDW_OPM_JOB_RSRC_INC) */
  	into OPI_EDW_OPM_JOB_RSRC_INC(PRIMARY_KEY,view_id,seq_id)
      SELECT
        BATCHSTEPLINE_ID,
        1,
        l_seq_id
      FROM
             PM_OPRN_DTL POD,
             PM_BTCH_HDR PBH
            WHERE POD.BATCH_ID=PBH.BATCH_ID
            AND GREATEST(POD.LAST_UPDATE_DATE, PBH.LAST_UPDATE_DATE)
          BETWEEN g_push_from_date and g_push_to_date
            AND BATCHSTEPLINE_ID not in (
                SELECT PRIMARY_KEY
                 from  OPI_EDW_OPM_JOB_RSRC_INC
                 WHERE SEQ_ID is NULL);
          p_count := sql%rowcount;

          /* Update the Missing Currency convenrsion rows with new Sequence */
          Update OPI_EDW_OPM_JOB_RSRC_INC set view_id=1,seq_id=l_seq_id
                 WHERE seq_id is NULL;

          p_count:=p_count+sql%rowcount;

   Commit;

   IF (FND_INSTALLATION.GET_APP_INFO('OPI', l_status, l_industry, l_OPI_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_OPI_schema,
				  TABNAME => 'OPI_EDW_OPM_JOB_RSRC_INC');
   END IF;

   RETURN(l_seq_id);
 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);
 END;



-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------
 PROCEDURE PUSH(Errbuf      	in out NOCOPY  Varchar2,
                Retcode     	in out NOCOPY  Varchar2,
                p_from_date  	IN             Varchar2,
                p_to_date    	IN             Varchar2) IS
 l_fact_name                Varchar2(30) :='OPI_EDW_JOB_RSRC_F';
 l_staging_table            Varchar2(30) :='OPI_EDW_JOB_RSRC_FSTG';
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date                Date:=Null;
 l_to_date                  Date:=Null;
 l_seq_id	                NUMBER := -1;
 l_seq_id2         	    NUMBER := -1;
 l_row_count                NUMBER := 0;
 l_row_count1               NUMBER := 0;
 l_row_count2               NUMBER := 0;
 l_pmi_schema          	    VARCHAR2(30);
 l_status                   VARCHAR2(30);
 l_industry                 VARCHAR2(30);
 l_push_local_failure       EXCEPTION;
 l_iden_change_failure      EXCEPTION;
   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
 BEGIN
   Errbuf :=NULL;
   Retcode:=0;
   l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_date :=to_date(p_to_date,'YYYY/MM/DD HH24:MI:SS');
   IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name,l_staging_table,l_staging_table,l_exception_msg)) THEN
         errbuf := fnd_message.get;
         RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
         Return;
   END IF;
  -- --------------------------------------------
  -- Taking care of cases where the input from/to
  -- date is NULL.
  -- --------------------------------------------
   g_push_from_date := nvl(l_from_date,
          EDW_COLLECTION_UTIL.G_local_last_push_start_date -
          EDW_COLLECTION_UTIL.g_offset);
   g_push_to_date := nvl(l_to_date,
          EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');
      l_seq_id := IDENTIFY_OPM_CHANGE(1,l_row_count);
      if (l_seq_id = -1) THEN
        RAISE l_iden_change_failure;
      end if;

   -- --------------------------------------------
   -- Push to local staging table
   -- --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Inserting into local staging table ');
      l_row_count1 := PUSH_TO_LOCAL(1,l_seq_id);
      IF (l_row_count1 = -1) THEN RAISE L_push_local_failure; END IF;
      edw_log.put_line('Inserted '||nvl(l_row_count1,0)||
         ' rows into the local staging table ');
      edw_log.put_line(' ');
      g_row_count:= l_row_count1;
      edw_log.put_line(' ');
      edw_log.put_line('For all views types, inserted '||nvl(g_row_count,0)||
        ' rows into local staging table ');
    -- --------------------------------------------
    -- No exception raised so far. Call wrapup to transport
    -- data to target database, and insert messages into logs
    -- -----------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Inserted '||nvl(g_row_count,0)||
         ' rows into the staging table');
      edw_log.put_line(' ');
      EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, l_exception_msg,
        g_push_from_date, g_push_to_date);
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
 EXCEPTION
   WHEN L_PUSH_LOCAL_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;   -- Rollback insert into local staging
      edw_log.put_line('Inserting into local staging have failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_from_date,g_push_to_date);
      raise;
   WHEN L_IDEN_CHANGE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      edw_log.put_line('Identifying changed records have Failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_from_date,g_push_to_date);
      raise;
   WHEN OTHERS THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line('Other errors');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
       g_push_from_date, g_push_to_date);
      raise;
 END;
END OPI_EDW_OPM_JOB_RSRC_F_C ;

/
