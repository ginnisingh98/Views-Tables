--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPI_JOB_DETAIL_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPI_JOB_DETAIL_F_C" as
/* $Header: OPIMJDTB.pls 120.1 2006/05/11 02:51:39 vganeshk noship $ */
 g_push_from_date          Date:=Null;
 g_push_to_date            Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_errbuf            VARCHAR2(2000):=NULL;
 g_retcode           VARCHAR2(200) :=NULL;


---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE by checking last_update_date
---------------------------------------------------
FUNCTION IDENTIFY_CHANGE( p_view_id   IN NUMBER,
			  p_count OUT NOCOPY NUMBER) RETURN NUMBER
  IS

     l_seq_id         NUMBER := -1;
     l_opi_schema     VARCHAR2(30);
     l_status         VARCHAR2(30);
     l_industry       VARCHAR2(30);
BEGIN

  p_count := 0;

  SELECT OPI_EDW_JOB_DETAIL_INC_S.NEXTVAL INTO l_seq_id FROM dual;

  INSERT
    INTO OPI_EDW_OPI_JOB_DETAIL_INC(primary_key1, primary_key2, primary_key3, seq_id)
  SELECT
	primary_key1,
	primary_key2,
 	primary_key3,
        l_seq_id
  FROM
  (
   SELECT
	 JOBS.WIP_ENTITY_ID primary_key1,
         JOBS.REPETITIVE_SCHEDULE_ID primary_key2,
         JOBS.JOB_ID primary_key3
   FROM
   (
   SELECT
      EN.WIP_ENTITY_ID WIP_ENTITY_ID,
      TO_NUMBER(NULL) REPETITIVE_SCHEDULE_ID,
      EN.WIP_ENTITY_ID || '-' JOB_ID,
      MAX(GREATEST(EN.LAST_UPDATE_DATE, DI.LAST_UPDATE_DATE, WPB.LAST_UPDATE_DATE))  LAST_UPDATE_DATE
   FROM WIP_ENTITIES EN , WIP_DISCRETE_JOBS DI, WIP_PERIOD_BALANCES WPB
   WHERE
       DI.STATUS_TYPE IN (4,5,7,12) AND
       DI.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND DI.ORGANIZATION_ID = EN.ORGANIZATION_ID AND
       DI.WIP_ENTITY_ID = WPB.WIP_ENTITY_ID
   GROUP BY
       EN.WIP_ENTITY_ID
   UNION
   SELECT
      EN.WIP_ENTITY_ID WIP_ENTITY_ID,
      RE.REPETITIVE_SCHEDULE_ID REPETITIVE_SCHEDULE_ID,
      EN.WIP_ENTITY_ID || '-' || RE.REPETITIVE_SCHEDULE_ID  JOB_ID,
      MAX(GREATEST(EN.LAST_UPDATE_DATE, RE.LAST_UPDATE_DATE, WPB.LAST_UPDATE_DATE))  LAST_UPDATE_DATE
   FROM
      WIP_ENTITIES EN, WIP_REPETITIVE_SCHEDULES RE, WIP_PERIOD_BALANCES WPB
   WHERE
      RE.STATUS_TYPE IN (4,5,7,12) AND
      RE.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND RE.ORGANIZATION_ID = EN.ORGANIZATION_ID AND
      RE.WIP_ENTITY_ID = WPB.WIP_ENTITY_ID AND RE.REPETITIVE_SCHEDULE_ID = WPB.REPETITIVE_SCHEDULE_ID
   GROUP BY
      EN.WIP_ENTITY_ID, RE.REPETITIVE_SCHEDULE_ID
   UNION
   SELECT
      EN.WIP_ENTITY_ID WIP_ENTITY_ID,
      TO_NUMBER(NULL) REPETITIVE_SCHEDULE_ID,
      EN.WIP_ENTITY_ID  || '-' JOB_ID,
      MAX(GREATEST(EN.LAST_UPDATE_DATE, FL.LAST_UPDATE_DATE, WPB.LAST_UPDATE_DATE))  LAST_UPDATE_DATE
   FROM
      WIP_ENTITIES EN , WIP_FLOW_SCHEDULES FL, WIP_PERIOD_BALANCES WPB
   WHERE
      FL.STATUS = 2  AND
      FL.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND FL.ORGANIZATION_ID = EN.ORGANIZATION_ID AND
      FL.WIP_ENTITY_ID = WPB.WIP_ENTITY_ID
   GROUP BY
      EN.WIP_ENTITY_ID
   ) JOBS,
   (
   SELECT /*+ parallel(mmt) */
      MMTMMTA.TRANSACTION_SOURCE_ID WIP_ENTITY_ID,
      MMTMMTA.REPETITIVE_SCHEDULE_ID REPETITIVE_SCHEDULE_ID,
      MMTMMTA.JOB_ID,
      MAX(GREATEST(MMTMMTA.LAST_UPDATE_DATE, WRO.LAST_UPDATE_DATE)) LAST_UPDATE_DATE
   FROM
      (select MMT.TRANSACTION_SOURCE_ID,
 	      MMTA.REPETITIVE_SCHEDULE_ID ,
              MMT.TRANSACTION_SOURCE_ID ||'-'|| NVL(MMTA.REPETITIVE_SCHEDULE_ID,'') JOB_ID,
              GREATEST(NVL(MMT.LAST_UPDATE_DATE, TO_DATE('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
               NVL(MMTA.LAST_UPDATE_DATE, TO_DATE('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
               NVL(WSV.LAST_UPDATE_DATE,TO_DATE('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss'))) LAST_UPDATE_DATE
       from MTL_MATERIAL_TRANSACTIONS MMT, MTL_MATERIAL_TXN_ALLOCATIONS MMTA,
            WIP_SCRAP_VALUES WSV,
            MTL_PARAMETERS MP
       where
        (MMT.TRANSACTION_ACTION_ID IN (1, 27, 33, 34, 31, 32, 30)) AND
        MMT.TRANSACTION_SOURCE_TYPE_ID = 5 AND
        MMT.TRANSACTION_ID = MMTA.TRANSACTION_ID (+) AND
        MMT.TRANSACTION_ID = WSV.TRANSACTION_ID (+) AND
        MMT.ORGANIZATION_ID = MP.ORGANIZATION_ID AND
        MP.PROCESS_ENABLED_FLAG > 'Y'
      ) MMTMMTA,
      (select WRO.WIP_ENTITY_ID, WRO.REPETITIVE_SCHEDULE_ID, WRO.LAST_UPDATE_DATE,
              WRO.WIP_ENTITY_ID ||'-'|| NVL(WRO.REPETITIVE_SCHEDULE_ID,'') JOB_ID
       from WIP_REQUIREMENT_OPERATIONS WRO) WRO
   WHERE
     MMTMMTA.JOB_ID = WRO.JOB_ID (+)
   GROUP BY
     MMTMMTA.TRANSACTION_SOURCE_ID, MMTMMTA.REPETITIVE_SCHEDULE_ID, MMTMMTA.JOB_ID
   ) JOBITEMTOTAL_MAT_BPR_SCRAP
   WHERE
     JOBS.JOB_ID = JOBITEMTOTAL_MAT_BPR_SCRAP.JOB_ID (+) AND
     GREATEST(NVL(JOBITEMTOTAL_MAT_BPR_SCRAP.LAST_UPDATE_DATE,TO_DATE('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
              NVL(JOBS.LAST_UPDATE_DATE,TO_DATE('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')))
     BETWEEN g_push_from_date and g_push_to_date
  UNION
  SELECT
    primary_key1,
    primary_key2,
    primary_key3
  FROM
  OPI_EDW_OPI_JOB_DETAIL_INC
  );

  p_count := SQL%rowcount;

  DELETE FROM OPI_EDW_OPI_JOB_DETAIL_INC WHERE seq_id IS NULL;
  COMMIT;

  RETURN(l_seq_id);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf:=sqlerrm;
    g_retcode:=sqlcode;
    RETURN(-1);
END identify_change;

-----------------------------------------------------------
--FUNCTION PUSH_TO_LOCAL
-----------------------------------------------------------

FUNCTION PUSH_TO_LOCAL(p_view_id NUMBER,
		       p_seq_id NUMBER) RETURN NUMBER IS
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
         /* FIX for BUG # 1695577 */
	 /* Removed TO_NUMBER(NULL) and replaced with STANDARD_QTY */
	 /* in the Select statement */

   INSERT INTO OPI_EDW_JOB_DETAIL_FSTG
     (
 	 JOB_DETAIL_PK,
	 LOCATOR_FK,
	 ITEM_FK,
	 PRD_LINE_FK,
	 TRX_DATE_FK,
	 SOB_CURRENCY_FK,
	 BASE_UOM_FK,
	 INSTANCE_FK,
	 USER_FK1,
	 USER_FK2,
	 USER_FK3,
	 USER_FK4,
	 USER_FK5,
	 ACT_BPR_VAL_B,
	 ACT_BPR_VAL_G,
	 ACT_CMPL_DATE,
	 ACT_CNCL_DATE,
	 ACT_INP_VAL_B,
	 ACT_INP_VAL_G,
	 ACT_JOB_TIME,
	 ACT_MTL_INP_VAL_B,
	 ACT_MTL_INP_VAL_G,
	 ACT_OUT_QTY,
	 ACT_OUT_VAL_B,
	 ACT_OUT_VAL_G,
	 ACT_SCR_VAL_B,
	 ACT_SCR_VAL_G,
	 ACT_STRT_DATE,
	 CREATION_DATE,
	 FST_PASS_YLD,
	 JOB_NO,
	 JOB_STATUS,
	 LAST_UPDATE_DATE,
	 MFG_MODE,
	 MOVE_TIME,
	 NO_ADJ,
	 NO_TIME_RESH,
	 PLN_BPR_VAL_B,
	 PLN_BPR_VAL_G,
	 PLN_CMPL_DATE,
	 PLN_INP_VAL_B,
	 PLN_INP_VAL_G,
	 PLN_JOB_TIME,
	 PLN_MTL_INP_VAL_B,
	 PLN_MTL_INP_VAL_G,
	 PLN_OUT_QTY,
	 PLN_OUT_VAL_B,
	 PLN_OUT_VAL_G,
	 PLN_SCR_VAL_B,
	 PLN_SCR_VAL_G,
	 PLN_STRT_DATE,
	 QC_FAIL_QTY,
	 QC_TEST,
	 QUEUE_TIME,
	 RESH_REASON_CODE,
	 RES_LOOKUP_FK,
	 REWORK_QTY,
	 RUN_TIME,
	 SETUP_TIME,
	 SMPL_CNT,
	 STD_QTY,
	 STD_TIME,
	 STD_VAL_B,
	 STD_VAL_G,
	 STS_LOOKUP_FK,
	 USER_ATTRIBUTE1,
	 USER_ATTRIBUTE10,
	 USER_ATTRIBUTE11,
	 USER_ATTRIBUTE12,
	 USER_ATTRIBUTE13,
	 USER_ATTRIBUTE14,
	 USER_ATTRIBUTE15,
	 USER_ATTRIBUTE2,
	 USER_ATTRIBUTE3,
	 USER_ATTRIBUTE4,
	 USER_ATTRIBUTE5,
	 USER_ATTRIBUTE6,
	 USER_ATTRIBUTE7,
	 USER_ATTRIBUTE8,
	 USER_ATTRIBUTE9,
	 USER_MEASURE1,
	 USER_MEASURE2,
	 USER_MEASURE3,
	 USER_MEASURE4,
	 USER_MEASURE5,
	 OPERATION_CODE,
	 COLLECTION_STATUS)
     SELECT /*+ ALL_ROWS */
 	 JOB_DETAIL_PK,
	 NVL(LOCATOR_FK,'NA_EDW'),
	 NVL(ITEM_FK,'NA_EDW'),
	 NVL(PRD_LINE_FK,'NA_EDW'),
	 NVL(TRX_DATE_FK,'NA_EDW'),
	 NVL(SOB_CURRENCY_FK,'NA_EDW'),
	 NVL(BASE_UOM_FK,'NA_EDW'),
	 NVL(INSTANCE_FK,'NA_EDW'),
	 NVL(USER_FK1,'NA_EDW'),
	 NVL(USER_FK2,'NA_EDW'),
	 NVL(USER_FK3,'NA_EDW'),
	 NVL(USER_FK4,'NA_EDW'),
	 NVL(USER_FK5,'NA_EDW'),
	 ACT_BPR_VAL_B,
	 ACT_BPR_VAL_B * CONVERSION_RATE,
	 ACT_CMPL_DATE,
	 ACT_CNCL_DATE,
	 ACT_INP_VAL_B,
	 ACT_INP_VAL_B * CONVERSION_RATE,
	 ACT_JOB_TIME,
	 ACT_MTL_INP_VAL_B,
	 ACT_MTL_INP_VAL_B * CONVERSION_RATE,
	 ACT_OUT_QTY,
	 ACT_OUT_VAL_B,
	 ACT_OUT_VAL_B * CONVERSION_RATE,
	 ACT_SCR_VAL_B,
	 ACT_SCR_VAL_B * CONVERSION_RATE,
	 ACT_STRT_DATE,
	 CREATION_DATE,
	 TO_NUMBER(NULL),
	 JOB_NO,
	 JOB_STATUS,
	 LAST_UPDATE_DATE,
	 MFG_MODE,
	 TO_NUMBER(NULL),
	 TO_NUMBER(NULL),
	 TO_NUMBER(NULL),
	 PLN_BPR_VAL_B,
	 PLN_BPR_VAL_B * CONVERSION_RATE,
	 PLN_CMPL_DATE,
	 PLN_INP_VAL_B,
	 PLN_INP_VAL_B * CONVERSION_RATE,
	 PLN_JOB_TIME,
	 PLN_MTL_INP_VAL_B,
	 PLN_MTL_INP_VAL_B * CONVERSION_RATE,
	 PLN_OUT_QTY,
	 PLN_OUT_VAL_B,
	 PLN_OUT_VAL_B * CONVERSION_RATE,
	 PLN_SCR_VAL_B,
	 PLN_SCR_VAL_B * CONVERSION_RATE,
	 PLN_STRT_DATE,
	 TO_NUMBER(NULL),
	 NULL,
	 TO_NUMBER(NULL),
	 NULL,
	 'NA_EDW',
	 TO_NUMBER(NULL),
	 TO_NUMBER(NULL),
	 TO_NUMBER(NULL),
	 TO_NUMBER(NULL),
	 STANDARD_QTY,
	 STD_TIME,
	 STD_VAL_B,
	 STD_VAL_B * CONVERSION_RATE,
	 'NA_EDW',
	 USER_ATTRIBUTE1,
	 USER_ATTRIBUTE10,
	 USER_ATTRIBUTE11,
	 USER_ATTRIBUTE12,
	 USER_ATTRIBUTE13,
	 USER_ATTRIBUTE14,
	 USER_ATTRIBUTE15,
	 USER_ATTRIBUTE2,
	 USER_ATTRIBUTE3,
	 USER_ATTRIBUTE4,
	 USER_ATTRIBUTE5,
	 USER_ATTRIBUTE6,
	 USER_ATTRIBUTE7,
	 USER_ATTRIBUTE8,
	 USER_ATTRIBUTE9,
	 USER_MEASURE1,
	 USER_MEASURE2,
	 USER_MEASURE3,
	 USER_MEASURE4,
	 USER_MEASURE5,
         NULL, -- OPERATION_CODE
         DECODE( CONVERSION_RATE, -1, 'RATE NOT AVAILABLE', DECODE( CONVERSION_RATE, -2, 'INVALID CURRENCY', 'LOCAL READY') )
     FROM OPI_EDW_OPI_JOB_DETAIL_FCV
     WHERE view_id = p_view_id
     AND seq_id = p_seq_id;

   RETURN(sql%rowcount);

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:=sqlcode;
      RETURN(-1);
END PUSH_TO_LOCAL;


-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------
PROCEDURE  Push(Errbuf      in out  NOCOPY Varchar2,
                Retcode     in out  NOCOPY Varchar2,
                p_from_date  IN   varchar2,
                p_to_date    IN   varchar2) IS

  l_fact_name       VARCHAR2(30)  :='OPI_EDW_JOB_DETAIL_F'  ;
  l_staging_table   VARCHAR2(30)  :='OPI_EDW_JOB_DETAIL_FSTG';
  l_opi_schema      VARCHAR2(30);
  l_status          VARCHAR2(30);
  l_industry        VARCHAR2(30);
  l_exception_msg   VARCHAR2(2000):=Null;

  l_from_date       DATE := NULL;
  l_to_date         DATE := NULL;

  l_seq_id_view1    NUMBER := 0;
  l_row_count_view1 NUMBER := 0;
  l_row_count       NUMBER := 0;

  l_push_local_failure      EXCEPTION;
  l_iden_change_failure EXCEPTION;

  /*
  l_date1                Date:=Null;
  l_date2                Date:=Null;
  l_temp_date                Date:=Null;
  l_rows_inserted            Number:=0;
  l_duration                 Number:=0;
*/

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------

  CURSOR cur_missing_rates IS
   SELECT DISTINCT
	SOB_CURRENCY_FK FROM_CURRENCY,
        NVL(SUBSTR(ACT_CMPL_DATE,1,10),CREATION_DATE) C_DATE,
        COLLECTION_STATUS
   FROM
	OPI_EDW_JOB_DETAIL_FSTG
   WHERE
          SUBSTRB(JOB_DETAIL_PK,LENGTH(JOB_DETAIL_PK)-2,3) = 'OPI'
      AND COLLECTION_STATUS IN ('RATE NOT AVAILABLE', 'INVALID CURRENCY')
   ORDER BY FROM_CURRENCY, C_DATE;

  l_SOB_CURRENCY_FK    VARCHAR2(80);
  l_C_DATE 	       DATE;
  l_COLLECTION_STATUS  VARCHAR2(30);
  l_rows_deleted            Number:=0;

BEGIN
   Errbuf :=NULL;
   Retcode:=0;

   IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name,
				     l_staging_table,
				     l_staging_table,
				     l_exception_msg)) THEN
      errbuf := fnd_message.get;
      Return;
   END IF;

   l_from_date  := To_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
   l_to_date    := To_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

   g_push_from_date
     := nvl(l_from_date,
	    EDW_COLLECTION_UTIL.G_local_last_push_start_date
	    - EDW_COLLECTION_UTIL.g_offset);

   g_push_to_date:=  nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

--l_date1 := g_push_date_range1;
--l_date2 := g_push_date_range2;

   edw_log.put_line( 'The collection range is from '||
        to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

   --  --------------------------------------------------------
   --  Identify Change for View Type 1
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Identifying change in view type 1');

   l_row_count := 0;
   l_seq_id_view1 := identify_change( p_view_id => 1,
				      p_count => l_row_count );
   IF (l_seq_id_view1 = -1 ) THEN
      RAISE l_iden_change_failure;
   END IF;

   edw_log.put_line('Identified '|| l_row_count
		    || ' changed records in view type 1. ');

--RAISE l_iden_change_failure;
   --  --------------------------------------------------------
   --  Analyze the incremental table
   --  --------------------------------------------------------
   IF fnd_installation.get_app_info( 'OPI', l_status,
				      l_industry, l_opi_schema) THEN
       fnd_stats.gather_table_stats(ownname=> l_opi_schema,
				    tabname=> 'OPI_EDW_OPI_JOB_DETAIL_INC' );
   END IF;

   --  --------------------------------------------------------
   --  Pushing data to local staging table
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Inserting into local staging table for view type 1');

   l_row_count_view1 := push_to_local( p_view_id => 1,
				       p_seq_id  => l_seq_id_view1 );
   IF l_row_count_view1 = -1 THEN
      RAISE l_push_local_failure;
   END IF;

   edw_log.put_line('Inserted ' || Nvl(l_row_count_view1,0) ||
		    ' rows into local staging table for view type 1');
   edw_log.put_line('  ');

   --
   g_row_count := l_row_count_view1;

   edw_log.put_line('For all view types, inserted ' || Nvl(g_row_count,0)
		    || ' rows into local staging table.');
   edw_log.put_line('  ');


   --  ---------------------------------------
   --  Delete all incremental table's records
   --  ---------------------------------------

   execute immediate 'truncate table '||l_opi_schema||'.OPI_EDW_OPI_JOB_DETAIL_INC ';

   --  --------------------------------------------------------------------------
   --  Insert missing currency rate/invalid currency rows into incremental table
   --  --------------------------------------------------------------------------

   INSERT
    INTO OPI_EDW_OPI_JOB_DETAIL_INC(primary_key1, primary_key2, primary_key3)
   SELECT distinct
    SUBSTRB(JOB_DETAIL_PK,INSTR(JOB_DETAIL_PK,'-',1,1)+1,INSTR(JOB_DETAIL_PK,'-',1,2)-INSTR(JOB_DETAIL_PK,'-',1,1)-1) primary_key1,
    SUBSTRB(JOB_DETAIL_PK,INSTR(JOB_DETAIL_PK,'-',1,2)+1,INSTR(JOB_DETAIL_PK,'-',1,3)-INSTR(JOB_DETAIL_PK,'-',1,2)-1) primary_key2,
    SUBSTRB(JOB_DETAIL_PK,INSTR(JOB_DETAIL_PK,'-',1,1)+1,INSTR(JOB_DETAIL_PK,'-',1,3)-INSTR(JOB_DETAIL_PK,'-',1,1)-1) primary_key3
   FROM
    OPI_EDW_JOB_DETAIL_FSTG
   WHERE
        SUBSTRB(JOB_DETAIL_PK,LENGTH(JOB_DETAIL_PK)-2,3) = 'OPI'
    AND COLLECTION_STATUS IN ('RATE NOT AVAILABLE', 'INVALID CURRENCY');

   -- Create output file
   OPEN cur_missing_rates;
   FETCH cur_missing_rates INTO L_SOB_CURRENCY_FK, L_C_DATE, l_COLLECTION_STATUS;
   IF cur_missing_rates%FOUND THEN

      edw_log.put_line(' ');
      edw_log.put_line('There are missing currency rates/invalid currencies. Please check the output file.');
      edw_log.put_line(' ');
      edw_log.put_line ('MISSING RATES');
      edw_log.put_line ('=============');
      edw_log.put_line ('             ');
      edw_log.put_line ('FROM CURRENCY     CONVERSION DATE     COLLECTION STATUS');
      edw_log.put_line ('=============     ===============     =================' );
      edw_log.put_line ( RPAD(L_SOB_CURRENCY_FK,13,' ') || '     ' || RPAD(L_C_DATE,15,' ') || '     ' || l_COLLECTION_STATUS);

      LOOP
         FETCH cur_missing_rates INTO L_SOB_CURRENCY_FK, L_C_DATE, l_COLLECTION_STATUS;
      	 EXIT WHEN cur_missing_rates%NOTFOUND;
         edw_log.put_line ( RPAD(L_SOB_CURRENCY_FK,13,' ') || '     ' || RPAD(L_C_DATE,15,' ') || '     ' || l_COLLECTION_STATUS);
      END LOOP;
      edw_log.put_line ('             ');
      edw_log.put_line ('--- END OF FILE ----');
   END IF;
   CLOSE cur_missing_rates;

   if EDW_COLLECTION_UTIL.source_same_as_target then
     DELETE FROM OPI_EDW_JOB_DETAIL_FSTG
     WHERE SUBSTRB(JOB_DETAIL_PK,LENGTH(JOB_DETAIL_PK)-2,3) = 'OPI'
       AND COLLECTION_STATUS IN ('RATE NOT AVAILABLE', 'INVALID CURRENCY');
     l_rows_deleted:= sql%rowcount;
     edw_log.put_line(' ');

     edw_log.put_line('Deleted '||nvl(l_rows_deleted,0)||
		    ' missing rate/invalid currency rows from local staging table');
     edw_log.put_line(' ');

     edw_log.put_line('There are ' || to_char(Nvl(g_row_count,0) - nvl(l_rows_deleted,0))
		    || ' remaining rows in local staging table.');
     edw_log.put_line('  ');
   end if;

   -- --------------------------------------------------------
   -- No exception raised so far. Call wrapup to transport
   -- data to target database, and insert messages into logs
   -- --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Inserted '|| to_char(nvl(g_row_count,0) - nvl(l_rows_deleted,0))||
		    ' rows into the staging table');
   edw_log.put_line(' ');

   EDW_COLLECTION_UTIL.wrapup(TRUE,
			      g_row_count,
			      l_exception_msg,
			      g_push_from_date,
			      g_push_to_date);

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

      IF fnd_installation.get_app_info( 'OPI', l_status,
					l_industry, l_opi_schema) THEN
	 execute immediate 'truncate table ' || l_opi_schema
	   || '.opi_edw_opi_job_detail_inc ';
      END IF;
      edw_log.put_line('Identifying changed records have Failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_from_date,g_push_to_date);
      raise;

   WHEN OTHERS THEN
      Errbuf:= Sqlerrm;
      Retcode:=sqlcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line('Other errors');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
				 g_push_from_date, g_push_to_date);
      raise;

END push;

End OPI_EDW_OPI_JOB_DETAIL_F_C;

/
