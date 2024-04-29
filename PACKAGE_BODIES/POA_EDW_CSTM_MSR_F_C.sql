--------------------------------------------------------
--  DDL for Package Body POA_EDW_CSTM_MSR_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_CSTM_MSR_F_C" AS
/* $Header: poafpcmb.pls 120.1 2005/06/13 12:56:21 sriswami noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count                Number:=0;

 g_errbuf		VARCHAR2(2000) := NULL;
 g_retcode		VARCHAR2(200)  := NULL;

-- ---------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE TRUNCATE_INC
-----------------------------------------------------------

 PROCEDURE TRUNCATE_INC IS

  l_poa_schema          VARCHAR2(30);
  l_stmt  		VARCHAR2(200);
  l_status		VARCHAR2(30);
  l_industry		VARCHAR2(30);

 BEGIN

    IF (FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema)) THEN
       l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_EDW_CSTM_MSR_INC';
       EXECUTE IMMEDIATE l_stmt;
    END IF;

 END;

-----------------------------------------------------------
--PROCEDURE PUSH_TO_LOCAL
-----------------------------------------------------------

 FUNCTION PUSH_TO_LOCAL(p_view_id NUMBER, p_seq_id NUMBER) RETURN NUMBER IS

  l_duration             NUMBER;
  l_temp_date            DATE:=NULL;
  l_rows_inserted        Number:=0;

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

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data to local staging table...');

   l_temp_date := sysdate;
   Insert Into POA_EDW_CSTM_MSR_FSTG (
     DUNS_FK,
     UNSPSC_FK,
     SIC_CODE_FK,
     CRITERIA_CODE_FK,
     CSTM_MSR_PK,
     CUSTOM_MEASURE_FK,
     EVAL_COMMENTS,
     EVAL_DATE_FK,
     INSTANCE_FK,
     ITEM_FK,
     MAX_SCORE,
     MIN_SCORE,
     OPERATING_UNIT_FK,
     SCORE,
     SCORE_COMMENTS,
     SUPPLIER_SITE_FK,
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
     USER_NAME,
     WEIGHT,
     WEIGHTED_SCORE,
     OPERATION_CODE,
     COLLECTION_STATUS,
     	EVALUATION_ID)
   select
     NVL(DUNS_FK, 'NA_EDW'),
     NVL(UNSPSC_FK, 'NA_EDW'),
     NVL(SIC_CODE_FK, 'NA_EDW'),
     NVL(CRITERIA_CODE_FK,'NA_EDW'),
     CSTM_MSR_PK,
     NVL(CUSTOM_MEASURE_FK,'NA_EDW'),
     EVAL_COMMENTS,
     NVL(EVAL_DATE_FK,'NA_EDW'),
     NVL(INSTANCE_FK,'NA_EDW'),
     NVL(ITEM_FK,'NA_EDW'),
     MAX_SCORE,
     MIN_SCORE,
     NVL(OPERATING_UNIT_FK,'NA_EDW'),
     SCORE,
     SCORE_COMMENTS,
     NVL(SUPPLIER_SITE_FK,'NA_EDW'),
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
     USER_NAME,
     WEIGHT,
     WEIGHTED_SCORE,
     NULL, -- OPERATION_CODE
     'LOCAL READY',
     EVALUATION_ID
   from POA_EDW_CUSTOM_MEASURE_FCV
   WHERE view_id   = p_view_id
   AND   seq_id    = p_seq_id;

   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('...Inserted ' || to_char(nvl(l_rows_inserted,0))||
         ' rows into the local staging table');
   edw_log.put_line('Process Time: ' || edw_log.duration(l_duration));
   edw_log.put_line(' ');

   RETURN (l_rows_inserted);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf  := sqlerrm;
     g_retcode := sqlcode;
     RETURN(-1);

 END;

---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE1
---------------------------------------------------

 FUNCTION IDENTIFY_CHANGE1 (p_view_id         IN  NUMBER,
                            p_count           OUT NOCOPY NUMBER) RETURN NUMBER IS

 l_seq_id	       NUMBER := -1;
 l_poa_schema          VARCHAR2(30);
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);

 BEGIN

   p_count := 0;
   select poa_edw_cstm_msr_inc_s.nextval into l_seq_id from dual;

	INSERT INTO poa_edw_cstm_msr_inc(primary_key, seq_id)
	SELECT  pms.evaluation_score_id, l_seq_id
	  FROM  poa_cm_eval_scores              pms,
                poa_cm_evaluation               pme
	 WHERE  pms.evaluation_id    = pme.evaluation_id
           AND  greatest(pms.last_update_date, pme.last_update_date)
                       between g_push_date_range1 and g_push_date_range2;

   p_count := sql%rowcount;

   RETURN (l_seq_id);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);

 END;

-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------


 Procedure Push(Errbuf       out NOCOPY  Varchar2,
                Retcode      out NOCOPY  Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS

  l_fact_name   Varchar2(30)   := 'POA_EDW_CSTM_MSR_F';
  l_staging_table Varchar2(30) := 'POA_EDW_CSTM_MSR_FSTG';

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------

  l_temp_date                DATE:=NULL;
  l_duration                 NUMBER:=0;
  l_exception_msg            VARCHAR2(2000):=NULL;
  l_seq_id	             NUMBER := -1;
  l_row_count                NUMBER := 0;
  l_row_count1               NUMBER := 0;

  l_push_local_failure       EXCEPTION;
  l_iden_change_failure      EXCEPTION;

  l_from_date            date;
  l_to_date              date;

Begin

   Errbuf :=NULL;
   Retcode:=0;

   l_from_date := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
   l_to_date   := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

   IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name, l_staging_table,
                l_staging_table, l_exception_msg)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
   END IF;


  -- --------------------------------------------
  -- Taking care of cases where the input from/to
  -- date is NULL.
  -- --------------------------------------------

  g_push_date_range1 := nvl(l_from_date,
       EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

   edw_log.put_line( 'The collection range is from '||
        to_char(g_push_date_range1, 'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(g_push_date_range2, 'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

   l_temp_date := sysdate;

   --  --------------------------------------------
   --  Identify Change
   --  --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Identifying changes...');
      l_seq_id := IDENTIFY_CHANGE1 (1, l_row_count);

      if (l_seq_id = -1) THEN
        RAISE l_iden_change_failure;
      end if;
      edw_log.put_line('Identified ' || l_row_count || ' changed records');

   -- --------------------------------------------
   -- Push to local staging table for view type 1
   -- --------------------------------------------

      edw_log.put_line(' ');
      edw_log.put_line('Inserting into local staging table for view type 1');
      l_row_count1 := PUSH_TO_LOCAL(1, l_seq_id);

      IF (l_row_count1 = -1) THEN RAISE L_push_local_failure; END IF;

      edw_log.put_line('Inserted '|| nvl(l_row_count1, 0) ||
                       ' rows into the local staging table for view type 1');
      edw_log.put_line(' ');

    -- --------------------------------------------
    -- Delete all incremental tables' record
    -- --------------------------------------------

	TRUNCATE_INC;

    -- --------------------------------------------
    -- No exception raised so far. Call wrapup to transport
    -- data to target database, and insert messages into logs
    -- -----------------------------------------------
      g_row_count := g_row_count + l_row_count1;
      edw_log.put_line(' ');
      edw_log.put_line('Inserted '||nvl(g_row_count,0)||
                       ' rows into the staging table');
      l_duration := sysdate - l_temp_date;
      edw_log.put_line(' ');
      edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
      edw_log.put_line(' ');

      EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count,
                                 P_PERIOD_START => g_push_date_range1,
                                 P_PERIOD_END   => g_push_date_range2);

 EXCEPTION

   WHEN L_PUSH_LOCAL_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;   -- Rollback insert into local staging
      edw_log.put_line('Inserting into local staging have failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
                                 g_push_date_range1, g_push_date_range2);
      raise;

   WHEN L_IDEN_CHANGE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      TRUNCATE_INC;
      edw_log.put_line('Identifying changed records have Failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
                                 g_push_date_range1, g_push_date_range2);
      raise;

   WHEN OTHERS THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line('Other errors');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
                                 g_push_date_range1, g_push_date_range2);
      raise;

End;
End POA_EDW_CSTM_MSR_F_C;

/
