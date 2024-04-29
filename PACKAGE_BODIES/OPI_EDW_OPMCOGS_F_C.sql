--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPMCOGS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPMCOGS_F_C" AS
/* $Header: OPIMPCGB.pls 115.14 2004/01/02 19:06:12 bthammin noship $ */
 g_errbuf		VARCHAR2(2000) := NULL;
 g_retcode		VARCHAR2(200) := NULL;
 g_row_count         	NUMBER:=0;
 g_push_from_date	DATE := NULL;
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
SELECT COGS_PK,COGS_DATE,BASE_CURRENCY_FK
FROM
   OPI_EDW_COGS_FSTG
WHERE
    COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
AND COGS_PK like '%OPM%';

BEGIN
  /* Print Header */
  edw_log.put_line(' ');
  edw_log.put_line ('Identified Missing Rows              Date:'||SYSDATE);

  edw_log.put_line (' ');
  edw_log.put_line (' ');

  edw_log.put_line ('Primary Key is IC_TRAN_PND/IC_TRAN_CMP-Transaction_id,Line_id');
  edw_log.put_line ('-----------------------------------------');
  edw_log.put_line ('Primary Key / Currency / Transaction Date');
  edw_log.put_line ('-----------------------------------------');
  /* Print Rows */

  For l_rows in missing_rate loop
      edw_log.put_line (l_rows.COGS_PK||' / '||l_rows.BASE_CURRENCY_FK||' / '||l_rows.COGS_DATE);
  end loop;
  edw_log.put_line(' ');
  edw_log.put_line(' ');
EXCEPTION
 WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     edw_log.put_line('Raised Exception from PRINT_MISSING_RATE '||sqlerrm);
END;

PROCEDURE PUSH_MISSING_ROWS
 IS
l_count number;
 BEGIN
  /* Delete the incremental table before inserting new data */
      DELETE OPI_EDW_OPMCOGS_INC WHERE SEQ_ID IS NOT NULL;
  edw_log.put_line(' ');
  SELECT count(*) into l_count from OPI_EDW_COGS_FSTG
     WHERE COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
               AND COGS_PK like '%OPM%';
  IF l_count > 0 THEN
      edw_log.put_line(' ');
      edw_log.Put_line('Identifying Missing Rate Rows ');
      edw_log.put_line(' ');
        /* insert into Incremental table all line_id where Currency is missing */
	INSERT /*+ parallel(OPI_EDW_OPMCOGS_INC) */
  	into OPI_EDW_OPMCOGS_INC (LINE_ID,view_id,seq_id)
      SELECT
        SUBSTRB(ORDER_LINE_ID,1,instrB(ORDER_LINE_ID,'-',1,1)-1),
        1,
        NULL
      FROM
         OPI_EDW_OPMCOGS_FCV
      WHERE
          VIEW_ID=1 AND
          COGS_PK in ( SELECT COGS_PK
               FROM  OPI_EDW_COGS_FSTG
               WHERE COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
               AND COGS_PK like '%OPM%');

    edw_log.Put_line(to_char(sql%rowcount) ||' rows missing Currency Rate Conversion for View Type 1');

    INSERT /*+ parallel(OPI_EDW_OPMCOGS_INC) */
        	into OPI_EDW_OPMCOGS_INC (LINE_ID,view_id,seq_id)
      SELECT
        SUBSTRB(ORDER_LINE_ID,1,instrB(ORDER_LINE_ID,'-',1,1)-1),
        2,
        NULL
      FROM
         OPI_EDW_OPMCOGS_FCV
      WHERE
          VIEW_ID=2 AND
          COGS_PK in ( SELECT COGS_PK
               FROM  OPI_EDW_COGS_FSTG
               WHERE COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
               AND COGS_PK like '%OPM%');
    edw_log.Put_line(to_char(sql%rowcount) ||' rows missing Currency Rate Conversion for View Type 2');
    edw_log.put_line(' ');
    Commit;
    edw_log.put_line ('Printing Missing Rate Rows Output');
    edw_log.put_line(' ');
    PRINT_MISSING_ROWS;
    edw_log.put_line ('Output Printed. You can view the output using ''View output'' option from Request page');
    edw_log.put_line(' ');

    /*Delete all missing rows from FSTG table if source and target are on same instance*/
     IF (LOCAL_SAME_AS_REMOTE) THEN
         DELETE OPI_EDW_COGS_FSTG
               WHERE COLLECTION_STATUS in ('RATE NOT AVAILABLE','INVALID CURRENCY')
               AND COGS_PK like '%OPM%';
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

edw_log.Put_line('Inserting Rows into Staging Table');
   Insert Into OPI_EDW_COGS_FSTG
      (COGS_PK
      ,COGS_DATE
      ,COGS_DATE_FK
      ,ORDER_LINE_ID
      ,SHIP_INV_LOCATOR_FK
      ,INSTANCE_FK
      ,TOP_MODEL_ITEM_FK
      ,ITEM_ORG_FK
      ,OPERATING_UNIT_FK
      ,INV_ORG_FK
      ,CUSTOMER_FK
      ,SALES_CHANNEL_FK
      ,PRIM_SALES_REP_FK
      ,PRIM_SALESRESOURCE_FK
      ,BILL_TO_LOC_FK
      ,SHIP_TO_LOC_FK
      ,PROJECT_FK
      ,TASK_FK
      ,ORDER_DATE
      ,BASE_UOM_FK
      ,TRX_CURRENCY_FK
      ,BASE_CURRENCY_FK
      ,ORDER_CATEGORY_FK
      ,ORDER_TYPE_FK
      ,BILL_TO_SITE_FK
      ,SHIP_TO_SITE_FK
      ,MONTH_BOOKED_FK
      ,DATE_BOOKED_FK
      ,DATE_PROMISED_FK
      ,DATE_REQUESTED_FK
      ,DATE_SCHEDULED_FK
      ,DATE_SHIPPED_FK
      ,LOCATOR_FK
      ,ORDER_SOURCE_FK
      ,SET_OF_BOOKS_FK
      ,CAMPAIGN_INIT_FK
      ,CAMPAIGN_ACTL_FK
      ,CAMPAIGN_STATUS_ACTL_FK
      ,CAMPAIGN_STATUS_INIT_FK
      ,MEDCHN_INIT_FK
      ,MEDCHN_ACTL_FK
      ,OFFER_HDR_FK
      ,OFFER_LINE_FK
      ,MARKET_SEGMENT_FK
      ,TARGET_SEGMENT_INIT_FK
      ,TARGET_SEGMENT_ACTL_FK
      ,PROM_EARLY_COUNT
      ,PROM_LATE_COUNT
      ,REQ_EARLY_COUNT
      ,REQ_LATE_COUNT
      ,PROM_EARLY_VAL_G
      ,PROM_LATE_VAL_G
      ,REQ_EARLY_VAL_G
      ,REQ_LATE_VAL_G
      ,REQUEST_LEAD_TIME
      ,PROMISE_LEAD_TIME
      ,ORDER_LEAD_TIME
      ,SHIPPED_QTY_B
      ,RMA_QTY_B
      ,ICAP_QTY_B
      ,COGS_T
      ,COGS_B
      ,COGS_G
      ,RMA_VAL_T
      ,RMA_VAL_G
      ,LAST_UPDATE_DATE
      ,COST_ELEMENT
      ,ACCOUNT
      ,ORDER_NUMBER
      ,WAYBILL_NUMBER
      ,LOT
      ,REVISION
      ,SERIAL_NUMBER
      ,USER_ATTRIBUTE1
      ,USER_ATTRIBUTE2
      ,USER_ATTRIBUTE3
      ,USER_ATTRIBUTE4
      ,USER_ATTRIBUTE5
      ,USER_ATTRIBUTE6
      ,USER_ATTRIBUTE7
      ,USER_ATTRIBUTE8
      ,USER_ATTRIBUTE9
      ,USER_ATTRIBUTE10
      ,USER_ATTRIBUTE11
      ,USER_ATTRIBUTE12
      ,USER_ATTRIBUTE13
      ,USER_ATTRIBUTE14
      ,USER_ATTRIBUTE15
      ,USER_MEASURE1
      ,USER_MEASURE2
      ,USER_MEASURE3
      ,USER_MEASURE4
      ,USER_MEASURE5
      ,USER_FK1
      ,USER_FK2
      ,USER_FK3
      ,USER_FK4
      ,USER_FK5
      ,OPERATION_CODE
      ,COLLECTION_STATUS
      ,CREATION_DATE)
   SELECT /*+ ALL_ROWS */
      COGS_PK
      ,COGS_DATE
      ,COGS_DATE_FK
      ,ORDER_LINE_ID
      ,SHIP_INV_LOCATOR_FK
      ,INSTANCE_FK
      ,TOP_MODEL_ITEM_FK
      ,ITEM_ORG_FK
      ,OPERATING_UNIT_FK
      ,INV_ORG_FK
      ,CUSTOMER_FK
      ,SALES_CHANNEL_FK
      ,PRIM_SALES_REP_FK
      ,PRIM_SALESRESOURCE_FK
      ,BILL_TO_LOC_FK
      ,SHIP_TO_LOC_FK
      ,PROJECT_FK
      ,TASK_FK
      ,ORDER_DATE
      ,BASE_UOM_FK
      ,TRX_CURRENCY_FK
      ,BASE_CURRENCY_FK
      ,ORDER_CATEGORY_FK
      ,ORDER_TYPE_FK
      ,BILL_TO_SITE_FK
      ,SHIP_TO_SITE_FK
      ,MONTH_BOOKED_FK
      ,DATE_BOOKED_FK
      ,DATE_PROMISED_FK
      ,DATE_REQUESTED_FK
      ,DATE_SCHEDULED_FK
      ,DATE_SHIPPED_FK
      ,LOCATOR_FK
      ,ORDER_SOURCE_FK
      ,SET_OF_BOOKS_FK
      ,CAMPAIGN_INIT_FK
      ,CAMPAIGN_ACTL_FK
      ,CAMPAIGN_STATUS_ACTL_FK
      ,CAMPAIGN_STATUS_INIT_FK
      ,MEDCHN_INIT_FK
      ,MEDCHN_ACTL_FK
      ,OFFER_HDR_FK
      ,OFFER_LINE_FK
      ,MARKET_SEGMENT_FK
      ,TARGET_SEGMENT_INIT_FK
      ,TARGET_SEGMENT_ACTL_FK
      ,PROM_EARLY_COUNT
      ,PROM_LATE_COUNT
      ,REQ_EARLY_COUNT
      ,REQ_LATE_COUNT
      ,PROM_EARLY_VAL_G
      ,PROM_LATE_VAL_G
      ,REQ_EARLY_VAL_G
      ,REQ_LATE_VAL_G
      ,REQUEST_LEAD_TIME
      ,PROMISE_LEAD_TIME
      ,ORDER_LEAD_TIME
      ,SHIPPED_QTY_B
      ,RMA_QTY_B
      ,ICAP_QTY_B
      ,COGS_T
      ,COGS_B
      ,COGS_G
      ,RMA_VAL_T
      ,RMA_VAL_G
      ,LAST_UPDATE_DATE
      ,COST_ELEMENT
      ,ACCOUNT
      ,ORDER_NUMBER
      ,WAYBILL_NUMBER
      ,LOT
      ,REVISION
      ,SERIAL_NUMBER
      ,USER_ATTRIBUTE1
      ,USER_ATTRIBUTE2
      ,USER_ATTRIBUTE3
      ,USER_ATTRIBUTE4
      ,USER_ATTRIBUTE5
      ,USER_ATTRIBUTE6
      ,USER_ATTRIBUTE7
      ,USER_ATTRIBUTE8
      ,USER_ATTRIBUTE9
      ,USER_ATTRIBUTE10
      ,USER_ATTRIBUTE11
      ,USER_ATTRIBUTE12
      ,USER_ATTRIBUTE13
      ,USER_ATTRIBUTE14
      ,USER_ATTRIBUTE15
      ,USER_MEASURE1
      ,USER_MEASURE2
      ,USER_MEASURE3
      ,USER_MEASURE4
      ,USER_MEASURE5
      ,USER_FK1
      ,USER_FK2
      ,USER_FK3
      ,USER_FK4
      ,USER_FK5
      ,NULL -- OPERATION_CODE
      ,DECODE(COGS_G,-1,'RATE NOT AVAILABLE',-2,'INVALID CURRENCY','LOCAL READY')
      ,LAST_UPDATE_DATE
from OPI_EDW_OPMCOGS_FCV
WHERE view_id    = p_view_id
 AND  seq_id     = p_seq_id;

edw_log.Put_line('Insert completed in Staging tables');
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
---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE
---------------------------------------------------
 FUNCTION IDENTIFY_CHANGE(p_view_id            IN         NUMBER,
                          p_count              OUT NOCOPY NUMBER)
 RETURN NUMBER
 IS
 l_seq_id	           NUMBER := -1;
 l_pmi_schema          VARCHAR2(30);
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);
 BEGIN
   p_count := 0;
   select OPI_EDW_OPMCOGS_INC_S.nextval into l_seq_id from dual;
   IF p_view_id = 1 THEN
	INSERT /*+ parallel(OPI_EDW_OPMCOGS_INC) */
  	into OPI_EDW_OPMCOGS_INC (LINE_ID,view_id,seq_id)
      SELECT
        SD.LINE_ID,
        1,
        l_seq_id
     FROM
         OP_ORDR_HDR SH,
         OP_ORDR_DTL SD,
         SY_ORGN_MST OM,
         GL_PLCY_MST  PM
     WHERE SH.order_id = sd.order_id
      AND SH.orgn_code = OM.orgn_code
      AND OM.co_CODE  = PM.co_code
      AND SD.LINE_STATUS >= 20
      AND GREATEST(SH.LAST_UPDATE_DATE, SD.LAST_UPDATE_DATE,PM.LAST_UPDATE_DATE)
      between g_push_from_date and g_push_to_date and
      sd.line_id not in
          (select LINE_ID from OPI_EDW_OPMCOGS_INC
                  WHERE VIEW_ID = 1 AND SEQ_ID is NULL);
      p_count := sql%rowcount;

      UPDATE  OPI_EDW_OPMCOGS_INC set SEQ_Id=l_SEQ_ID
              WHERE VIEW_ID=1 AND SEQ_ID is NULL;

      p_count := P_count+sql%rowcount;

   ELSIF p_view_id =2 THEN
	INSERT /*+ parallel(OPI_EDW_OPMCOGS_INC) */
  	into OPI_EDW_OPMCOGS_INC (LINE_ID,view_id,seq_id)
      SELECT
        IT.LINE_ID,
        2,
        l_seq_id
     FROM
       OE_ORDER_HEADERS_ALL OOH,
       OE_ORDER_LINES_ALL OOL,
       IC_TRAN_VW1        IT
     WHERE OOH.HEADER_ID       = OOL.HEADER_ID  AND
       OOH.ORG_ID              = OOL.ORG_ID     AND
       OOL.LINE_CATEGORY_CODE  = 'ORDER'        AND
       IT.DOC_ID               = OOH.HEADER_ID  AND
       IT.LINE_ID              = OOL.LINE_ID    AND
       IT.DOC_TYPE             = 'OMSO'         AND
       GREATEST(OOL.LAST_UPDATE_DATE, OOH.LAST_UPDATE_DATE)
      between g_push_from_date and g_push_to_date AND
      IT.LINE_ID not in
       (select LINE_ID from OPI_EDW_OPMCOGS_INC
                  WHERE VIEW_ID = 2 AND SEQ_ID is NULL);
      p_count := sql%rowcount;

      UPDATE  OPI_EDW_OPMCOGS_INC set SEQ_Id=l_SEQ_ID
              WHERE VIEW_ID=2 AND SEQ_ID is NULL;
       p_count := P_count+sql%rowcount;
   END IF;

   Commit;

   IF (FND_INSTALLATION.GET_APP_INFO('OPI', l_status, l_industry, l_pmi_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pmi_schema,
				  TABNAME => 'OPI_EDW_OPMCOGS_INC');
   END IF;


   RETURN(l_seq_id);
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
 PROCEDURE PUSH(Errbuf      	in out NOCOPY  Varchar2,
                Retcode     	in out NOCOPY  Varchar2,
                p_from_date  	IN 	       Varchar2,
                p_to_date    	IN 	       Varchar2) IS
 l_fact_name                Varchar2(30) :='OPI_EDW_COGS_F';
 l_staging_table            Varchar2(30) :='OPI_EDW_COGS_FSTG';
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date                Date:=Null;
 l_to_date                  Date:=Null;
 l_seq_id1	                NUMBER := -1;
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
   --  --------------------------------------------
   --  Identify Change view 1 OP Data
   --  --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Identifying changes in view type 1');
      l_seq_id1 := IDENTIFY_CHANGE(1,l_row_count);
      if (l_seq_id1 = -1) THEN
        RAISE l_iden_change_failure;
      end if;
      edw_log.put_line ('Identified '||l_row_count||' changed records in view type 1');
   --  --------------------------------------------
   --  Identify Change view type 2 OM Data
   --  --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Identifying changes in view type 2');
      l_seq_id2 := IDENTIFY_CHANGE(2,l_row_count);
      if (l_seq_id2 = -1) THEN
        RAISE l_iden_change_failure;
      end if;
      edw_log.put_line ('Identified '||l_row_count||' changed records in view type 2');
   --  --------------------------------------------
   --  Analyze the incremental table
   --  --------------------------------------------
      IF (FND_INSTALLATION.GET_APP_INFO('OPI', l_status, l_industry, l_pmi_schema)) THEN
        FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pmi_schema,
				  TABNAME => 'OPI_EDW_OPMCOGS_INC');
      END IF;
   -- --------------------------------------------
   -- Push to local staging table
   -- --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Inserting into local staging table ');
      l_row_count1 := PUSH_TO_LOCAL(1, l_seq_id1);
      IF (l_row_count1 = -1) THEN RAISE L_push_local_failure; END IF;
      edw_log.put_line('Inserted '||nvl(l_row_count1,0)||
         ' rows into the local staging table ');
      edw_log.put_line(' ');
      g_row_count:= l_row_count1;
      edw_log.put_line(' ');
      edw_log.put_line('Inserting into local staging table ');
      l_row_count2 := PUSH_TO_LOCAL(2, l_seq_id2);
      IF (l_row_count2 = -1) THEN RAISE L_push_local_failure; END IF;
      edw_log.put_line('Inserted '||nvl(l_row_count2,0)||
         ' rows into the local staging table ');
      edw_log.put_line(' ');
      g_row_count:= l_row_count1 + l_row_count2;
      edw_log.put_line(' ');
      edw_log.put_line('For all views types, inserted '||nvl(g_row_count,0)||
        ' rows into local staging table ');

--  -------------------------------------------
--  Update Sales rep FK with seles rep_id
--  if collection status is other than local ready
--  then we should not re-construct sales rep fk.
-- --------------------------------------------

      UPDATE OPI_EDW_COGS_FSTG cogs
      SET PRIM_SALESRESOURCE_FK =
             (select sr.salesrep_id||'-'||sr.org_id||'-'||cogs.instance_fk||'-SALESREP-PERS'
              FROM RA_SALESREPS_ALL sr
              WHERE sr.SALESREP_NUMBER = substrb(PRIM_SALESRESOURCE_FK,1,instrb(PRIM_SALESRESOURCE_FK,'-',-1,1)-1)
                AND sr.org_id =  substrb(PRIM_SALESRESOURCE_FK,instrb(PRIM_SALESRESOURCE_FK,'-',-1,1)+1))
      WHERE PRIM_SALESRESOURCE_FK <> 'NA_EDW'
        AND COLLECTION_STATUS = 'LOCAL READY';

    -- --------------------------------------------
    -- Delete all incremental tables record
    -- --------------------------------------------
      delete OPI_EDW_OPMCOGS_INC;
      commit;
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
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
       g_push_from_date, g_push_to_date);
      l_exception_msg  := Retcode || ':' || Errbuf;
      delete OPI_EDW_OPMCOGS_INC;
      commit;
      raise;
   WHEN L_IDEN_CHANGE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      delete OPI_EDW_OPMCOGS_INC;
      commit;
      edw_log.put_line('Identifying changed records have Failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
       g_push_from_date, g_push_to_date);
      raise;
   WHEN OTHERS THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line('Other errors');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
       g_push_from_date, g_push_to_date);
      l_exception_msg  := Retcode || ':' || Errbuf;
      delete OPI_EDW_OPMCOGS_INC;
      commit;
      raise;
 END;
END OPI_EDW_OPMCOGS_F_C;

/
