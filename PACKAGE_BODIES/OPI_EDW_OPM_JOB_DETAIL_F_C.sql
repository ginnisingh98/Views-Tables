--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPM_JOB_DETAIL_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPM_JOB_DETAIL_F_C" AS
/* $Header: OPIMOJDB.pls 115.16 2004/01/02 19:05:59 bthammin noship $ */
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
SELECT JOB_DETAIL_PK,TRX_DATE_FK,SOB_CURRENCY_FK,INSTANCE_FK
FROM
   OPI_EDW_JOB_DETAIL_FSTG
WHERE
    COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
AND JOB_DETAIL_PK like '%OPM'
AND SUBSTRB(JOB_DETAIL_PK,instrB(JOB_DETAIL_PK,'-',1,1)+1,
                      instrB(JOB_DETAIL_PK,'-',1,2)-1-instrB(JOB_DETAIL_PK,'-',1,1))
    in (select BATCH_ID from PM_MATL_DTL WHERE
               LINE_ID in (select PRIMARY_KEY from
                              OPI_EDW_OPM_JOB_DETAIL_INC
                              WHERE SEQ_ID is NULL));

BEGIN
  /* Print Header */
  edw_log.put_line(' ');
  edw_log.put_line ('Identified Missing Rows              Date:'||SYSDATE);

  edw_log.put_line (' ');
  edw_log.put_line (' ');

  edw_log.put_line ('Primary Key is PM_BTCH_HDR.Plant_code - PM_BTCH_HDR.Batch_id - PM_MATL_DTL.Item_id - instance_code - OPM');
  edw_log.put_line ('-----------------------------------------');
  edw_log.put_line ('Primary Key / Currency / Transaction Date');
  edw_log.put_line ('-----------------------------------------');
  /* Print Rows */

  For l_rows in missing_rate loop
      edw_log.put_line (l_rows.JOB_DETAIL_PK||' / '||l_rows.SOB_CURRENCY_FK||' / '||l_rows.TRX_DATE_FK);
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
      DELETE OPI_EDW_OPM_JOB_DETAIL_INC;
  edw_log.put_line(' ');
  edw_log.Put_line('Identifying Missing Rate Rows ');
  edw_log.put_line(' ');
  SELECT count(*) into l_count from OPI_EDW_JOB_DETAIL_FSTG where
       COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
       AND JOB_DETAIL_PK like '%OPM';
  IF l_count > 0 THEN


      /* insert into Incremental table all line_id where Currency is missing */
	INSERT /*+ parallel(OPI_EDW_OPM_JOB_DETAIL_INC) */
  	into OPI_EDW_OPM_JOB_DETAIL_INC(PRIMARY_KEY,view_id,seq_id)
      SELECT
        LINE_ID,
        1,
        NULL
      FROM
         PM_MATL_DTL
      WHERE
          LINE_TYPE=1 AND
          BATCH_ID
          in ( SELECT SUBSTRB(JOB_DETAIL_PK,instrB(JOB_DETAIL_PK,'-',1,1)+1,
                      instrB(JOB_DETAIL_PK,'-',1,2)-1-instrB(JOB_DETAIL_PK,'-',1,1))
               FROM  OPI_EDW_JOB_DETAIL_FSTG
               WHERE COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
                 AND JOB_DETAIL_PK like '%OPM');
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
         DELETE OPI_EDW_JOB_DETAIL_FSTG
               WHERE COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
                 AND JOB_DETAIL_PK like '%OPM';
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
     edw_log.put_line('Raised Exception from PUSH_MISSING_ROWS '||sqlerrm);
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
     INSERT INTO OPI_EDW_JOB_DETAIL_FSTG(
ACT_BPR_VAL_B ,
ACT_BPR_VAL_G ,
ACT_CMPL_DATE ,
ACT_CNCL_DATE ,
ACT_INP_VAL_B  ,
ACT_INP_VAL_G  ,
ACT_JOB_TIME ,
ACT_MTL_INP_VAL_B  ,
ACT_MTL_INP_VAL_G  ,
ACT_OUT_QTY ,
ACT_OUT_VAL_B  ,
ACT_OUT_VAL_G ,
ACT_SCR_VAL_B  ,
ACT_SCR_VAL_G ,
ACT_STRT_DATE ,
BASE_UOM_FK,
COLLECTION_STATUS ,
CREATION_DATE ,
FST_PASS_YLD  ,
INSTANCE_FK ,
ITEM_FK ,
JOB_DETAIL_PK ,
JOB_NO ,
JOB_STATUS ,
LAST_UPDATE_DATE ,
LOCATOR_FK ,
MFG_MODE ,
MOVE_TIME  ,
NO_ADJ  ,
NO_TIME_RESH  ,
OPERATION_CODE ,
PLN_BPR_VAL_B ,
PLN_BPR_VAL_G  ,
PLN_CMPL_DATE ,
PLN_INP_VAL_B  ,
PLN_INP_VAL_G ,
PLN_JOB_TIME  ,
PLN_MTL_INP_VAL_B  ,
PLN_MTL_INP_VAL_G  ,
PLN_OUT_QTY ,
PLN_OUT_VAL_B ,
PLN_OUT_VAL_G ,
PLN_SCR_VAL_B ,
PLN_SCR_VAL_G  ,
PLN_STRT_DATE ,
PRD_LINE_FK ,
QC_FAIL_QTY  ,
QC_TEST ,
QUEUE_TIME  ,
RESH_REASON_CODE ,
RES_LOOKUP_FK ,
REWORK_QTY  ,
ROUTING,
ROUTING_REVISION,
RUN_TIME  ,
SETUP_TIME  ,
SMPL_CNT  ,
SOB_CURRENCY_FK ,
STD_QTY  ,
STD_TIME  ,
STD_VAL_B  ,
STD_VAL_G  ,
STND_HRS_EARNED,
STS_LOOKUP_FK ,
TRX_DATE_FK ,
USER_ATTRIBUTE1 ,
USER_ATTRIBUTE10 ,
USER_ATTRIBUTE11 ,
USER_ATTRIBUTE12 ,
USER_ATTRIBUTE13 ,
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
USER_FK1,
USER_FK2 ,
USER_FK3 ,
USER_FK4 ,
USER_FK5 ,
USER_MEASURE1 ,
USER_MEASURE2  ,
USER_MEASURE3  ,
USER_MEASURE4  ,
USER_MEASURE5
)
  SELECT /*+ ALL_ROWS */
ACT_BPR_VAL_B ,
DECODE(ACT_BPR_VAL_G,-1,NULL,-2,NULL,ACT_BPR_VAL_G) ,
ACT_CMPL_DATE ,
ACT_CNCL_DATE ,
ACT_INP_VAL_B  ,
DECODE(ACT_INP_VAL_G,-1,NULL,-2,NULL,ACT_INP_VAL_G) ,
ACT_JOB_TIME ,
ACT_MTL_INP_VAL_B  ,
DECODE(ACT_MTL_INP_VAL_G,-1,NULL,-2,NULL,ACT_MTL_INP_VAL_G) ,
ACT_OUT_QTY ,
ACT_OUT_VAL_B  ,
DECODE(ACT_OUT_VAL_G,-1,NULL,-2,NULL,ACT_OUT_VAL_G) ,
ACT_SCR_VAL_B  ,
ACT_SCR_VAL_G ,
ACT_STRT_DATE ,
BASE_UOM_FK ,
DECODE(PLN_OUT_VAL_G,-1,'RATE NOT AVAILABLE',-2,'INVALID CURRENCY','LOCAL READY') ,
CREATION_DATE ,
FST_PASS_YLD  ,
INSTANCE_FK ,
ITEM_FK ,
JOB_DETAIL_PK ,
JOB_NO ,
JOB_STATUS ,
LAST_UPDATE_DATE ,
LOCATOR_FK ,
MFG_MODE ,
MOVE_TIME  ,
NO_ADJ  ,
NO_TIME_RESH  ,
NULL OPERATION_CODE ,
PLN_BPR_VAL_B ,
DECODE(PLN_BPR_VAL_G,-1,NULL,-2,NULL,PLN_BPR_VAL_G)  ,
PLN_CMPL_DATE ,
PLN_INP_VAL_B  ,
DECODE(PLN_INP_VAL_G,-1,NULL,-2,NULL,PLN_INP_VAL_G) ,
PLN_JOB_TIME  ,
PLN_MTL_INP_VAL_B  ,
DECODE(PLN_MTL_INP_VAL_G,-1,NULL,-2,NULL,PLN_MTL_INP_VAL_G)  ,
PLN_OUT_QTY ,
PLN_OUT_VAL_B ,
DECODE(PLN_OUT_VAL_G,-1,NULL,-2,NULL,PLN_OUT_VAL_G) ,
PLN_SCR_VAL_B ,
PLN_SCR_VAL_G  ,
PLN_STRT_DATE ,
PRD_LINE_FK ,
QC_FAIL_QTY  ,
QC_TEST ,
QUEUE_TIME  ,
RESH_REASON_CODE ,
RES_LOOKUP_FK ,
REWORK_QTY  ,
ROUTING,
ROUTING_REVISION,
RUN_TIME  ,
SETUP_TIME  ,
SMPL_CNT  ,
SOB_CURRENCY_FK ,
STD_QTY  ,
STD_TIME  ,
STD_VAL_B  ,
DECODE(STD_VAL_G,-1,NULL,-2,NULL,STD_VAL_G)  ,
STND_HRS_EARNED,
STS_LOOKUP_FK ,
TRX_DATE_FK ,
USER_ATTRIBUTE1 ,
USER_ATTRIBUTE10 ,
USER_ATTRIBUTE11 ,
USER_ATTRIBUTE12 ,
USER_ATTRIBUTE13 ,
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
USER_FK1,
USER_FK2 ,
USER_FK3 ,
USER_FK4 ,
USER_FK5 ,
USER_MEASURE1 ,
USER_MEASURE2  ,
USER_MEASURE3  ,
USER_MEASURE4  ,
USER_MEASURE5
    FROM OPI_EDW_OPM_JOB_DETAIL_FCV
    WHERE view_id    = p_view_id
    AND   seq_id    = p_seq_id;
commit;
 l_no_rows := sql%rowcount;
edw_log.put_line('Sequence is '||to_char(p_seq_id));
edw_log.put_line('View ID is '||to_char(p_view_id));
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
FUNCTION IDENTIFY_OPM_CHANGE(p_view_id            IN  NUMBER,
                             p_count              OUT NOCOPY NUMBER)
 RETURN NUMBER
 IS
 l_seq_id	           NUMBER := -1;
 l_opi_schema          VARCHAR2(30);
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);
 BEGIN
   p_count := 0;
   select OPI_EDW_JOB_DETAIL_INC_S.nextval into l_seq_id from dual;
      /* insert into Incremental table all line_id but not part of missing currency convenrsion rows */
	INSERT /*+ parallel(OPI_EDW_OPM_JOB_DETAIL_INC) */
  	into OPI_EDW_OPM_JOB_DETAIL_INC(PRIMARY_KEY,view_id,seq_id)
      SELECT
        LINE_ID,
        1,
        l_seq_id
      FROM  PM_BTCH_HDR  BH,
         PM_MATL_DTL  BD
      WHERE BH.BATCH_ID   = BD.BATCH_ID
	  AND BH.BATCH_STATUS in (-1,0,1,2,3,4)
	  AND BD.LINE_TYPE=1
        AND GREATEST(BH.LAST_UPDATE_DATE, BD.LAST_UPDATE_DATE)
          BETWEEN g_push_from_date and g_push_to_date
        AND LINE_ID not in
           (SELECT PRIMARY_KEY
              from  OPI_EDW_OPM_JOB_DETAIL_INC
              WHERE SEQ_ID is NULL);

          p_count := sql%rowcount;

       /* Update the Missing Currency convenrsion rows with new Sequence */
          Update OPI_EDW_OPM_JOB_DETAIL_INC set view_id=1,seq_id=l_seq_id
                 WHERE seq_id is NULL;

          p_count:=p_count+sql%rowcount;

   Commit;

   IF (FND_INSTALLATION.GET_APP_INFO('OPI', l_status, l_industry, l_OPI_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_OPI_schema,
				  TABNAME => 'OPI_EDW_OPM_JOB_DETAIL_INC');
   END IF;

   edw_log.put_line('Sequence is '||to_char(l_seq_id));
   RETURN(l_seq_id);
 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
edw_log.put_line('Rasied Exception '||sqlerrm);

     RETURN(-1);
 END;


-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------
 PROCEDURE PUSH(Errbuf      	in out NOCOPY  Varchar2,
                Retcode     	in out NOCOPY  Varchar2,
                p_from_date  	IN             Varchar2,
                p_to_date    	IN 	       Varchar2) IS
 l_fact_name                Varchar2(30) :='OPI_EDW_JOB_DETAIL_F';
 l_staging_table            Varchar2(30) :='OPI_EDW_JOB_DETAIL_FSTG';
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date                Date:=Null;
 l_to_date                  Date:=Null;
 l_seq_id1	                NUMBER := -1;
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
    --  --------------------------------------------
   --  Identify OPM Net Changes
   --  --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Identifying changes in view type 1');
      l_seq_id1 := IDENTIFY_OPM_CHANGE(1,l_row_count);
     edw_log.put_line('Sequence is '||to_char(l_seq_id1));

      if (l_seq_id1 = -1) THEN
        RAISE l_iden_change_failure;
      end if;
      edw_log.put_line ('Identified '||l_row_count||' changed records in view type 1');
   -- --------------------------------------------
   -- Push to local staging table
   -- --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Inserting into local staging table ');
      l_row_count1 := PUSH_TO_LOCAL(1,l_seq_id1);
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
       commit;

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
END OPI_EDW_OPM_JOB_DETAIL_F_C ;

/
