--------------------------------------------------------
--  DDL for Package Body OPI_EDW_COGS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_COGS_F_C" as
/* $Header: OPIMCOGB.pls 120.1 2006/05/31 23:40:41 julzhang noship $ */
 g_push_from_date          Date:=Null;
 g_push_to_date            Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_errbuf            VARCHAR2(2000):=NULL;
 g_retcode           VARCHAR2(200) :=NULL;


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
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;

     RETURN FALSE;

 END;

---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE by checking last_update_date
---------------------------------------------------
/*--------------------------------------------------------------+
| Date: 03-Nov-2003
| Developer: ADWAJAN
| Comments: Additional condition in the where clause to
|           calculate COGS for the logical txns in the
|           Drop Ship scenario - 11.5.10 Impact Analysis
+-------------------------------------------------------------*/

FUNCTION IDENTIFY_CHANGE( p_view_id   IN NUMBER,
			  p_count OUT NOCOPY NUMBER) RETURN NUMBER
  IS

     l_seq_id         NUMBER := -1;
     l_opi_schema     VARCHAR2(30);
     l_status         VARCHAR2(30);
     l_industry       VARCHAR2(30);
BEGIN

   p_count := 0;

   SELECT opi_edw_cogs_inc_s.NEXTVAL INTO l_seq_id FROM dual;

   IF p_view_id = 1 THEN
      INSERT
	INTO opi_edw_cogs_inc(primary_key1, seq_id, view_id)
	SELECT   /*+ parallel(mmt) */
	DISTINCT mmt.transaction_id, l_seq_id, 1
	FROM
        oe_order_headers_all 		h,
        oe_order_lines_all 		pl,
        oe_order_lines_all 		l,
        mtl_transaction_accounts   	mta,
        mtl_material_transactions  	mmt
	where 	( (mmt.transaction_source_type_id = 2
                   and   mta.transaction_source_type_id = 2)
                or
                   (mmt.transaction_source_type_id = 13
                    and   mmt.transaction_action_id = 9
                    and   mta.transaction_source_type_id = 13)
                )
	and   mmt.transaction_id = mta.transaction_id
	and   mta.accounting_line_type in (2, 35)
	and   pl.org_id = l.org_id
	and   h.org_id = l.org_id
	and   l.line_id = mmt.trx_source_line_id
	and   l.line_category_code = 'ORDER'
	and   pl.line_category_code = 'ORDER'
	and   pl.line_id = nvl(l.top_model_line_id, l.line_id)
	and   h.header_id = l.header_id
	and   h.header_id = pl.header_id
	AND   greatest(
	nvl(l.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
	nvl(pl.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
	nvl(mta.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
	nvl(mmt.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
	nvl(h.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')))
	BETWEEN g_push_from_date and g_push_to_date
	UNION
	SELECT primary_key1, l_seq_id, 1
	FROM opi_edw_cogs_inc
	WHERE view_id =1;

    ELSIF p_view_id = 2 THEN
      INSERT
	INTO opi_edw_cogs_inc(primary_key1, seq_id, view_id)
	SELECT  /*+ parallel(mmt) */
	DISTINCT mmt.transaction_id, l_seq_id, 2
	FROM
        oe_order_headers_all            h,
        oe_order_lines_all              pl,
        oe_order_lines_all              cl,
        oe_order_lines_all              l,
        mtl_transaction_accounts        mta,
        mtl_material_transactions       mmt
	where    ( (mmt.transaction_source_type_id = 12
                    and   mta.transaction_source_type_id = 12)
                 or
                    (mmt.transaction_source_type_id = 13
                     and mmt.transaction_action_id = 14
                     and   mta.transaction_source_type_id = 13)
                 )
	and   mmt.transaction_id = mta.transaction_id
	and   mta.accounting_line_type in (2, 35)
	and   h.org_id = l.org_id
	and   l.line_id = mmt.trx_source_line_id
	and   l.line_category_code = 'RETURN'
	and   cl.line_id (+) = l.link_to_line_id
	and   pl.line_id (+) = nvl(cl.top_model_line_id, cl.line_id)
	and   h.header_id = l.header_id
	AND greatest(
	      nvl(l.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
	      nvl(pl.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
	      nvl(pl.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
	      nvl(mta.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
	      nvl(mmt.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
	      nvl(h.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')))
	BETWEEN g_push_from_date and g_push_to_date
	UNION
	SELECT primary_key1, l_seq_id, 2
	FROM opi_edw_cogs_inc
	WHERE view_id =2;
    ELSIF p_view_id = 3 THEN
      INSERT
	INTO opi_edw_cogs_inc(primary_key1, primary_key2, seq_id, view_id)
	SELECT   /*+ parallel(aid) */
	DISTINCT aid.invoice_id,
	aid.distribution_line_number,
	l_seq_id, 3
	FROM
        oe_order_headers_all            h,
        oe_order_lines_all              pl,     /*  parent line  */
        oe_order_lines_all              l,      /*  child line   */
        ra_customer_trx_lines_all       rcl,
	ap_invoice_distributions_all    aid,
	ap_invoices_all                 ai,
	mtl_material_transactions       mmt,
    mtl_parameters                  mp
	WHERE ai.source = 'Intercompany'
	AND aid.invoice_id = ai.invoice_id
	and translate( lower(aid.REFERENCE_1), 'abcdefghijklmnopqrstuvwxyz_ -+0123456789',
		       'abcdefghijklmnopqrstuvwxyz_ -+') is null
	and   aid.org_id = ai.org_id
	and   rcl.CUSTOMER_TRX_LINE_ID  = to_number(aid.REFERENCE_1)
	and   aid.line_type_lookup_code = 'ITEM'
	and   rcl.interface_line_attribute6 = l.line_id
	and   pl.line_id = nvl(l.top_model_line_id, l.line_id)
	and   pl.org_id = l.org_id
	and   h.org_id = l.org_id
	and   h.header_id = l.header_id
	and   h.header_id = pl.header_id
	and   l.line_category_code  = 'ORDER'
	and   pl.line_category_code = 'ORDER'
	and   rcl.interface_line_attribute7 = mmt.transaction_id
	and   nvl(mmt.logical_transaction,0) <> 1
    and   mmt.organization_id = mp.organization_id
    and   mp.process_enabled_flag <> 'Y'
	AND greatest(
        nvl(aid.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
        nvl(ai.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
        nvl(l.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
        nvl(pl.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')),
        nvl(h.last_update_date, to_date('01/01/1000 00:00:00','MM/DD/YYYY hh24:mi:ss')))
	BETWEEN g_push_from_date and g_push_to_date
	UNION
	SELECT primary_key1, primary_key2, l_seq_id, 3
	FROM opi_edw_cogs_inc
	WHERE view_id =3;
   END IF;

   p_count := SQL%rowcount;

   DELETE opi_edw_cogs_inc WHERE view_id = p_view_id AND seq_id <> l_seq_id;

   COMMIT;
--dbms_output.put_line('Identified '|| p_count || ' changed records in view type '|| p_view_id);
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

   Insert Into opi_edw_cogs_fstg
     (
      ACCOUNT,
      BASE_CURRENCY_FK,
      BASE_UOM_FK,
      BILL_TO_LOC_FK,
      BILL_TO_SITE_FK,
      CAMPAIGN_ACTL_FK,
      CAMPAIGN_INIT_FK,
      campaign_status_actl_fk,
      campaign_status_init_fk,
      COGS_B,
      cogs_date,
      cogs_date_fk,
      COGS_G,
      COGS_PK,
      COGS_T,
      COST_ELEMENT,
      CUSTOMER_FK,
      DATE_BOOKED_FK,
      DATE_PROMISED_FK,
      DATE_REQUESTED_FK,
      DATE_SCHEDULED_FK,
      DATE_SHIPPED_FK,
      ICAP_QTY_B,
      INSTANCE_FK,
      INV_ORG_FK,
      ITEM_ORG_FK,
      LOCATOR_FK,
      LOT,
      MARKET_SEGMENT_FK,
      MEDCHN_ACTL_FK,
      MEDCHN_INIT_FK,
      MONTH_BOOKED_FK,
      OFFER_HDR_FK,
      OFFER_LINE_FK,
      OPERATING_UNIT_FK,
      ORDER_CATEGORY_FK,
      order_date,
      ORDER_LEAD_TIME,
      order_line_id,
      ORDER_NUMBER,
      ORDER_SOURCE_FK,
      ORDER_TYPE_FK,
      PRIM_SALES_REP_FK,
      prim_salesresource_fk,
      PROJECT_FK,
      PROMISE_LEAD_TIME,
      PROM_EARLY_COUNT,
      PROM_EARLY_VAL_G,
      PROM_LATE_COUNT,
      PROM_LATE_VAL_G,
      REQUEST_LEAD_TIME,
      REQ_EARLY_COUNT,
      REQ_EARLY_VAL_G,
      REQ_LATE_COUNT,
     REQ_LATE_VAL_G,
     REVISION,
     RMA_QTY_B,
     RMA_VAL_G,
     RMA_VAL_T,
     SALES_CHANNEL_FK,
     SERIAL_NUMBER,
     SET_OF_BOOKS_FK,
     ship_inv_locator_fk,
     SHIPPED_QTY_B,
     SHIP_TO_LOC_FK,
     SHIP_TO_SITE_FK,
     TARGET_SEGMENT_ACTL_FK,
     TARGET_SEGMENT_INIT_FK,
     TASK_FK,
     TOP_MODEL_ITEM_FK,
     TRX_CURRENCY_FK,
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
     WAYBILL_NUMBER,
     OPERATION_CODE,
     collection_status,
     creation_date,
     last_update_date
     ,delivery_id )
     SELECT /*+ ALL_ROWS */
     ACCOUNT,
     NVL(BASE_CURRENCY_FK,'NA_EDW'),
     NVL(BASE_UOM_FK,'NA_EDW'),
     NVL(BILL_TO_LOC_FK,'NA_EDW'),
     NVL(BILL_TO_SITE_FK,'NA_EDW'),
     NVL(CAMPAIGN_ACTL_FK,'NA_EDW'),
     NVL(CAMPAIGN_INIT_FK,'NA_EDW'),
     Nvl(campaign_status_actl_fk, 'NA_EDW'),
     Nvl(campaign_status_init_fk, 'NA_EDW'),
     COGS_B,
     cogs_date,
     cogs_date_fk,
     global_currency_rate* cogs_b  cogs_g,
     COGS_PK,
     COGS_T,
     COST_ELEMENT,
     NVL(CUSTOMER_FK,'NA_EDW'),
     DATE_BOOKED_FK,
     DATE_PROMISED_FK,
     DATE_REQUESTED_FK,
     DATE_SCHEDULED_FK,
     DATE_SHIPPED_FK,
     ICAP_QTY_B,
     NVL(INSTANCE_FK,'NA_EDW'),
     NVL(INV_ORG_FK,'NA_EDW'),
     NVL(ITEM_ORG_FK,'NA_EDW'),
     NVL(LOCATOR_FK,'NA_EDW'),
     LOT,
     NVL(MARKET_SEGMENT_FK,'NA_EDW'),
     NVL(MEDCHN_ACTL_FK,'NA_EDW'),
     NVL(MEDCHN_INIT_FK,'NA_EDW'),
     MONTH_BOOKED_FK,
     NVL(OFFER_HDR_FK,'NA_EDW'),
     NVL(OFFER_LINE_FK,'NA_EDW'),
     NVL(OPERATING_UNIT_FK,'NA_EDW'),
     NVL(ORDER_CATEGORY_FK,'NA_EDW'),
     order_date,
     ORDER_LEAD_TIME,
     order_line_id,
     ORDER_NUMBER,
     NVL(ORDER_SOURCE_FK,'NA_EDW'),
     NVL(ORDER_TYPE_FK,'NA_EDW'),
     NVL(PRIM_SALES_REP_FK,'NA_EDW'),
     Nvl(prim_salesresource_fk, 'NA_EDW'),
     NVL(PROJECT_FK,'NA_EDW'),
     PROMISE_LEAD_TIME,
     PROM_EARLY_COUNT,
     prom_early_val_g * global_currency_rate,
     PROM_LATE_COUNT,
     prom_late_val_g  * global_currency_rate,
     REQUEST_LEAD_TIME,
     REQ_EARLY_COUNT,
     req_early_val_g  * global_currency_rate,
     REQ_LATE_COUNT,
     req_late_val_g   * global_currency_rate,
     REVISION,
     RMA_QTY_B,
     rma_val_t * global_currency_rate rma_val_g,
     RMA_VAL_T,
     NVL(SALES_CHANNEL_FK,'NA_EDW'),
     SERIAL_NUMBER,
     NVL(SET_OF_BOOKS_FK,'NA_EDW'),
     Nvl(ship_inv_locator_fk,'NA_EDW'),
     SHIPPED_QTY_B,
     NVL(SHIP_TO_LOC_FK,'NA_EDW'),
     NVL(SHIP_TO_SITE_FK,'NA_EDW'),
     NVL(TARGET_SEGMENT_ACTL_FK,'NA_EDW'),
     NVL(TARGET_SEGMENT_INIT_FK,'NA_EDW'),
     NVL(TASK_FK,'NA_EDW'),
     NVL(TOP_MODEL_ITEM_FK,'NA_EDW'),
     NVL(TRX_CURRENCY_FK,'NA_EDW'),
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
     WAYBILL_NUMBER,
     NULL, -- OPERATION_CODE
     Decode( global_currency_rate,
	     -1, 'RATE NOT AVAILABLE',
	     -2, 'INVALID CURRENCY',
	     'LOCAL READY'),
     Sysdate,
     Sysdate
     ,delivery_id
     FROM opi_edw_cogs_fcv
     WHERE view_id = p_view_id
     AND seq_id = p_seq_id;

--dbms_output.put_line('Inserted ' || Nvl(SQL%rowcount,0) ||' rows into local staging table for view type ' || p_view_id || ' with seq_id ' || p_seq_id);
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
PROCEDURE  Push(Errbuf      in out NOCOPY   Varchar2,
                Retcode     in out NOCOPY Varchar2,
                p_from_date  IN   varchar2,
                p_to_date    IN   varchar2) IS

  l_fact_name       VARCHAR2(30)  :='OPI_EDW_COGS_F'  ;
  l_staging_table   VARCHAR2(30)  :='OPI_EDW_COGS_FSTG';
  l_opi_schema      VARCHAR2(30);
  l_status          VARCHAR2(30);
  l_industry        VARCHAR2(30);
  l_exception_msg   VARCHAR2(2000):=Null;

  l_seq_id_view1    NUMBER := 0;
  l_seq_id_view2    NUMBER := 0;
  l_seq_id_view3    NUMBER := 0;
  l_row_count_view1 NUMBER := 0;
  l_row_count_view2 NUMBER := 0;
  l_row_count_view3 NUMBER := 0;
  l_row_count       NUMBER := 0;

  l_push_local_failure      EXCEPTION;
  l_iden_change_failure EXCEPTION;

  l_missing_rate_count NUMBER :=0;
  currency_conv_rate_not_exist  EXCEPTION;

  CURSOR missing_rate_csr IS
     SELECT DISTINCT
       base_currency_fk from_currency,
       Substr(cogs_date_fk, 1,10) c_date,
       collection_status
       FROM opi_edw_cogs_fstg
       WHERE collection_status IN ('RATE NOT AVAILABLE','INVALID CURRENCY')
       AND Substr(cogs_pk,0,3) <> 'OPM'
       ORDER BY from_currency, c_date;

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

   g_push_from_date  := To_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
   g_push_to_date    := To_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');





 --  Start of code change for bug fix 2140267.
  -- --------------------------------------------
  -- Taking care of cases where the input from/to
  -- date is NULL.
  -- --------------------------------------------

   g_push_from_date := nvl(g_push_from_date,
          EDW_COLLECTION_UTIL.G_local_last_push_start_date -
          EDW_COLLECTION_UTIL.g_offset);
   g_push_to_date := nvl(g_push_to_date,
          EDW_COLLECTION_UTIL.G_local_curr_push_start_date);


  --  End of code change for bug fix 2140267.









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
   --  --------------------------------------------------------
   --  Identify Change for View Type 2
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Identifying change in view type 2');
   l_row_count := 0;
   l_seq_id_view2 := identify_change( p_view_id => 2,
				      p_count => l_row_count );
   IF (l_seq_id_view2 = -1 ) THEN
      RAISE l_iden_change_failure;
   END IF;

   edw_log.put_line('Identified '|| l_row_count
		    || ' changed records in view type 2. ');

   --  --------------------------------------------------------
   --  Identify Change for View Type 3
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Identifying change in view type 3');
   l_row_count := 0;
   l_seq_id_view3 := identify_change( p_view_id => 3,
				      p_count => l_row_count );
   IF (l_seq_id_view3 = -1 ) THEN
      RAISE l_iden_change_failure;
   END IF;

   edw_log.put_line('Identified '|| l_row_count
		    || ' changed records in view type 3. ');

--RAISE l_iden_change_failure;
   --  --------------------------------------------------------
   --  Analyze the incremental table
   --  --------------------------------------------------------
   IF fnd_installation.get_app_info( 'OPI', l_status,
				      l_industry, l_opi_schema) THEN
       fnd_stats.gather_table_stats(ownname=> l_opi_schema,
				    tabname=> 'OPI_EDW_COGS_INC' );
   END IF;

   --  --------------------------------------------------------
   --  . Pushing data to local staging table
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
   edw_log.put_line(' ');
   edw_log.put_line('Inserting into local staging table for view type 2');

   l_row_count_view2 := push_to_local( p_view_id => 2,
				       p_seq_id  => l_seq_id_view2 );
   IF l_row_count_view2 = -1 THEN
      RAISE l_push_local_failure;
   END IF;
   edw_log.put_line('Inserted ' || Nvl(l_row_count_view2,0) ||
		    ' rows into local staging table for view type 2');
   edw_log.put_line('  ');


   --
   edw_log.put_line(' ');
   edw_log.put_line('Inserting into local staging table for view type 3');

   l_row_count_view3 := push_to_local( p_view_id => 3,
				       p_seq_id  => l_seq_id_view3 );
   IF l_row_count_view3 = -1 THEN
      RAISE l_push_local_failure;
   END IF;
   edw_log.put_line('Inserted ' || Nvl(l_row_count_view3,0) ||
		    ' rows into local staging table for view type 3');
   edw_log.put_line('  ');

   --
   g_row_count := l_row_count_view1 + l_row_count_view2 + l_row_count_view3;

   edw_log.put_line('For all view types, inserted ' || Nvl(g_row_count,0)
		    || ' rows into local staging table.');
   edw_log.put_line('  ');



   --  --------------------------------------------------------
   --  Delete all incremental table's record
   --  --------------------------------------------------------

   execute immediate 'truncate table '||l_opi_schema||'.opi_edw_cogs_inc ';

   --  --------------------------------------------------------
   --  insert missing rate/invalid currency into incremental table
   --  --------------------------------------------------------
   INSERT INTO opi_edw_cogs_inc(view_id, primary_key1, primary_key2 )
     SELECT Decode(Substr(cogs_pk,0,3), 'INV', 1, 'RMA', 2, 'ICI', 3 ) view_id,
     Decode(Substr(cogs_pk,0,3),
	    'INV', Substr(cogs_pk,5,Instr(cogs_pk,'-',1,2) -5),
	    'RMA', Substr(cogs_pk,5,Instr(cogs_pk,'-',1,2) -5),
	    'ICI', Substr(cogs_pk,Instr(cogs_pk, '-',1,2)+1,
			  Instr(cogs_pk,'-', 1, 3)- Instr(cogs_pk, '-',1,2)-1)
	    ) primary_key1,
     Decode(Substr(cogs_pk,0,3), 'INV', NULL, 'RMA', NULL,
	    'ICI', Substr(cogs_pk,5,Instr(cogs_pk,'-',1,2) -5)) primary_key2
     FROM opi_edw_cogs_fstg
     WHERE collection_status IN ('RATE NOT AVAILABLE','INVALID CURRENCY')
     AND Substr(cogs_pk,0,3) <> 'OPM'
     ;

   l_missing_rate_count := SQL%rowcount;

   COMMIT;

   --  --------------------------------------------------------
   --  report missing rate/invalid currency
   --  --------------------------------------------------------

   IF l_missing_rate_count > 0 THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FROM CURRENCY   CONVERSION DATE    COLLECTION STATUS');
      FOR ms_rate IN missing_rate_csr LOOP
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, Rpad(ms_rate.from_currency,16,' ')||
			   Rpad(ms_rate.c_date,19, ' ')|| ms_rate.collection_status );
      END LOOP;
   END IF;

   --  --------------------------------------------------------
   --  if on single instance, delete records with
   --  'RATE NOT AVAILABLE','INVALID CURRENCY' from fstg
   --  --------------------------------------------------------
   IF local_same_as_remote THEN
      DELETE opi_edw_cogs_fstg
	WHERE collection_status IN ('RATE NOT AVAILABLE','INVALID CURRENCY')
	AND Substr(cogs_pk,0,3) <> 'OPM';
   END IF;



   -- --------------------------------------------
   -- No exception raised so far. Call wrapup to transport
   -- data to target database, and insert messages into logs
   -- -----------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Inserted '||nvl(g_row_count,0)||
		    ' rows into the staging table');
   edw_log.put_line(' ');

   EDW_COLLECTION_UTIL.wrapup(TRUE,
			      g_row_count,
			      l_exception_msg,
			      g_push_from_date,
			      g_push_to_date);


   IF l_missing_rate_count > 0 THEN
      RAISE currency_conv_rate_not_exist;
   END IF;
--dbms_output.put_line( 'l_opi_schema  after wrapup true ' || l_opi_schema);


-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

EXCEPTION
   WHEN currency_conv_rate_not_exist THEN
      Errbuf:= 'No conversion rate existed. Please check log file for details.';

      Retcode:= 1; -- completed with warning
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line( l_exception_msg);
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
                                 g_push_from_date, g_push_to_date);

   WHEN L_PUSH_LOCAL_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;   -- Rollback insert into local staging
      edw_log.put_line('Inserting into local staging have failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
				 g_push_from_date, g_push_to_date);
      raise;

   WHEN L_IDEN_CHANGE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;

      IF fnd_installation.get_app_info( 'OPI', l_status,
					l_industry, l_opi_schema) THEN
	 execute immediate 'truncate table ' || l_opi_schema
	   || '.opi_edw_cogs_inc ';
      END IF;
      edw_log.put_line('Identifying changed records have Failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
				 g_push_from_date, g_push_to_date);
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

End OPI_EDW_COGS_F_C;

/
