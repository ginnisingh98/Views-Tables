--------------------------------------------------------
--  DDL for Package Body ISC_DBI_BOOK_SUM2_REF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_BOOK_SUM2_REF_PKG" AS
/* $Header: ISCRF70B.pls 120.3 2006/02/27 17:26:18 scheung noship $ */

g_login_id    NUMBER;
g_user_id     NUMBER;
g_commit_size                  NUMBER          := 500;
g_errbuf	VARCHAR2(2000)	:= NULL;
g_retcode	VARCHAR2(200)	:= NULL;

FUNCTION REFRESH_MV(p_mview_name VARCHAR2) RETURN NUMBER IS

l_row_count		NUMBER;
l_sql_stmt		VARCHAR2(2000);
l_degree		NUMBER := 0;

BEGIN

 l_degree := bis_common_parameters.get_degree_of_parallelism;
  BIS_COLLECTION_UTILITIES.put_line('The degree of parallelism is '|| l_degree);

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Start to Refresh '|| p_mview_name);

  FII_UTIL.Start_Timer;

  DBMS_MVIEW.REFRESH(
		list => p_mview_name,
	     	method => '?',
		parallelism => l_degree
  );

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer(p_mview_name || ' has been refreshed in ');

  l_sql_stmt := 'SELECT count(*) FROM ' || p_mview_name ;
  EXECUTE IMMEDIATE l_sql_stmt INTO l_row_count;

  BIS_COLLECTION_UTILITIES.put_line(p_mview_name ||' has '||l_row_count||' rows.');

  RETURN(l_row_count);

EXCEPTION

  WHEN OTHERS THEN
    BIS_COLLECTION_UTILITIES.put_line('Errored while refreshing '|| p_mview_name);
    g_errbuf := sqlerrm ||' - '||sqlcode;
    RETURN(-1);

END refresh_mv;

PROCEDURE refresh_past_due(errbuf		IN OUT NOCOPY  VARCHAR2,
                           retcode		IN OUT NOCOPY  VARCHAR2) IS

l_start			DATE		:= NULL;
l_end			DATE		:= NULL;
l_period_from		DATE  		:= NULL;
l_from_date		DATE		:= NULL;
l_to_date		DATE		:= NULL;
l_failure		EXCEPTION;
l_row_count		NUMBER		:= 0;

BEGIN
  errbuf  := NULL;
  retcode := '0';

  IF (Not BIS_COLLECTION_UTILITIES.setup('ISC_BOOK_SUM2_PDUE_F')) THEN
    RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
    return;
  END IF;

  BIS_COLLECTION_UTILITIES.get_last_refresh_dates('ISC_BOOK_SUM2_PDUE_F', l_start, l_end, l_period_from, l_from_date);
  l_to_date := sysdate;

  BIS_COLLECTION_UTILITIES.put_line('Updating ISC_BOOK_SUM2_PDUE_F');

  FII_UTIL.Start_Timer;

  UPDATE isc_book_sum2_pdue_f
     SET time_snapshot_date_id = to_date('1000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS')
   WHERE time_snapshot_date_id = trunc(sysdate);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Obsoleted ' || sql%rowcount || ' rows in ISC_BOOK_SUM2_PDUE_F in');

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Inserting data into ISC_BOOK_SUM2_PDUE_F');

  FII_UTIL.Start_Timer;

  INSERT INTO isc_book_sum2_pdue_f(
	INV_ORG_ID,
	INVENTORY_ITEM_ID,
	CUSTOMER_ID,
	TIME_BOOKED_DATE_ID,
	ORDER_NUMBER,
	HEADER_ID,
	PDUE_LINE_CNT,
	PDUE_QTY,
	UOM,
	LINE_NUMBER,
	DAYS_LATE,
	TIME_SNAPSHOT_DATE_ID,
	SOLD_TO_ORG_ID,
	SHIP_TO_ORG_ID,
        LINE_ID)
  SELECT NULL, NULL, NULL, NULL, -1, -1, 0, 0, NULL, NULL, 0, trunc(sysdate), NULL, NULL, NULL
    FROM dual
  UNION ALL
  SELECT inv_org_id,
    	 inventory_item_id,
	 customer_id,
	 time_booked_date_id,
	 order_number,
	 header_id,
	 count_pdue_line PDUE_LINE_CNT,
         pdue_qty,
	 uom,
	 line_number,
	 (trunc(sysdate) - time_schedule_date_id) DAYS_LATE,
         trunc(sysdate) TIME_SNAPSHOT_DATE_ID,
	 sold_to_org_id,
	 ship_to_org_id,
         line_id
    FROM isc_dbi_fm_0004_mv
   WHERE time_schedule_date_id < trunc(sysdate);

  l_row_count := l_row_count + sql%rowcount;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Inserted ' || l_row_count || ' rows into ISC_BOOK_SUM2_PDUE_F in');

  BIS_COLLECTION_UTILITIES.WRAPUP(
  TRUE,
  l_row_count,
  NULL,
  l_from_date,
  l_to_date
  );

 EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    l_row_count,
    g_errbuf,
    l_from_date,
    l_to_date
    );

  WHEN OTHERS THEN
    ROLLBACK;
    errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| errbuf);
    retcode := -1;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    l_row_count,
    errbuf,
    l_from_date,
    l_to_date
    );

END refresh_past_due;

PROCEDURE refresh_past_due2(errbuf		IN OUT NOCOPY  VARCHAR2,
                           retcode		IN OUT NOCOPY  VARCHAR2) IS

l_start			DATE		:= NULL;
l_end			DATE		:= NULL;
l_period_from		DATE  		:= NULL;
l_from_date		DATE		:= NULL;
l_to_date		DATE		:= NULL;
l_failure		EXCEPTION;
l_row_count		NUMBER		:= 0;

BEGIN
  errbuf  := NULL;
  retcode := '0';

  IF (Not BIS_COLLECTION_UTILITIES.setup('ISC_BOOK_SUM2_PDUE2_F')) THEN
    RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
    return;
  END IF;

  BIS_COLLECTION_UTILITIES.get_last_refresh_dates('ISC_BOOK_SUM2_PDUE2_F', l_start, l_end, l_period_from, l_from_date);
  l_to_date := sysdate;

  BIS_COLLECTION_UTILITIES.put_line('Updating ISC_BOOK_SUM2_PDUE2_F');

  FII_UTIL.Start_Timer;

  UPDATE isc_book_sum2_pdue2_f
     SET time_snapshot_date_id = to_date('1000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS')
   WHERE time_snapshot_date_id = trunc(sysdate);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Obsoleted ' || sql%rowcount || ' rows in ISC_BOOK_SUM2_PDUE2_F in');

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Inserting data into ISC_BOOK_SUM2_PDUE2_F');

  FII_UTIL.Start_Timer;

  INSERT INTO isc_book_sum2_pdue2_f(
	INV_ORG_ID,
	INVENTORY_ITEM_ID,
	CUSTOMER_ID,
	TIME_BOOKED_DATE_ID,
	ORDER_NUMBER,
	HEADER_ID,
	PDUE_LINE_CNT,
	PDUE_QTY,
	UOM,
	LINE_NUMBER,
	DAYS_LATE,
	DAYS_LATE_PROMISE,
	PDUE_AMT_F,
	PDUE_AMT_G,
	LATE_SCHEDULE_FLAG,
	LATE_PROMISE_FLAG,
	TIME_SNAPSHOT_DATE_ID,
	PDUE_AMT_G1,
	SOLD_TO_ORG_ID,
	SHIP_TO_ORG_ID,
	TOP_MODEL_LINE_ID,
	LINE_ID,
	ITEM_TYPE_CODE)
  SELECT NULL, NULL, NULL, NULL, -1, -1, 0, 0, NULL, NULL, 0, 0, 0, 0, -1, -1, trunc(sysdate),0, NULL, NULL, NULL, NULL, NULL
    FROM dual
  UNION ALL
  SELECT inv_org_id,
    	 inventory_item_id,
	 customer_id,
	 time_booked_date_id,
	 order_number,
	 header_id,
	 count_pdue_line PDUE_LINE_CNT,
         pdue_qty,
	 uom,
	 line_number,
	 (trunc(sysdate) - time_schedule_date_id) DAYS_LATE,
	 (trunc(sysdate) - time_promise_date_id) DAYS_LATE_PROMISE,
	 pdue_amt_f,
	 pdue_amt_g,
	 (CASE WHEN trunc(sysdate) > time_schedule_date_id THEN 1 ELSE 0 END)	LATE_SCHEDULE_FLAG,
	 (CASE WHEN trunc(sysdate) > time_promise_date_id THEN 1 ELSE 0 END)	LATE_PROMISE_FLAG,
         trunc(sysdate) TIME_SNAPSHOT_DATE_ID,
	 pdue_amt_g1,
	 sold_to_org_id,
	 ship_to_org_id,
	 top_model_line_id,
	 line_id,
         item_type_code
    FROM isc_dbi_cfm_006_mv
   WHERE (time_schedule_date_id < trunc(sysdate) OR time_promise_date_id < trunc(sysdate));

  l_row_count := l_row_count + sql%rowcount;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Inserted ' || l_row_count || ' rows into ISC_BOOK_SUM2_PDUE2_F in');

  BIS_COLLECTION_UTILITIES.WRAPUP(
  TRUE,
  l_row_count,
  NULL,
  l_from_date,
  l_to_date
  );

 EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    l_row_count,
    g_errbuf,
    l_from_date,
    l_to_date
    );

  WHEN OTHERS THEN
    ROLLBACK;
    errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| errbuf);
    retcode := -1;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    l_row_count,
    errbuf,
    l_from_date,
    l_to_date
    );

END refresh_past_due2;

PROCEDURE refresh_backorder(errbuf		IN OUT NOCOPY  VARCHAR2,
                           retcode		IN OUT NOCOPY  VARCHAR2) IS

l_start			DATE		:= NULL;
l_end			DATE		:= NULL;
l_period_from		DATE  		:= NULL;
l_from_date		DATE		:= NULL;
l_to_date		DATE		:= NULL;
l_failure		EXCEPTION;
l_row_count		NUMBER		:= 0;

BEGIN
  errbuf  := NULL;
  retcode := '0';

  IF (Not BIS_COLLECTION_UTILITIES.setup('ISC_BOOK_SUM2_BKORD_F')) THEN
    RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
    return;
  END IF;

  BIS_COLLECTION_UTILITIES.get_last_refresh_dates('ISC_BOOK_SUM2_BKORD_F', l_start, l_end, l_period_from, l_from_date);
  l_to_date := sysdate;

  BIS_COLLECTION_UTILITIES.put_line('Updating ISC_BOOK_SUM2_BKORD_F');

  FII_UTIL.Start_Timer;

  UPDATE isc_book_sum2_bkord_f
     SET time_snapshot_date_id = to_date('1000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS')
   WHERE time_snapshot_date_id = trunc(sysdate);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Obsoleted ' || sql%rowcount || ' rows in ISC_BOOK_SUM2_BKORD_F in');

  BIS_COLLECTION_UTILITIES.put_line(' ');
  BIS_COLLECTION_UTILITIES.put_line('Inserting data into ISC_BOOK_SUM2_BKORD_F');

  FII_UTIL.Start_Timer;

  INSERT INTO isc_book_sum2_bkord_f(
	INV_ORG_ID,
	INVENTORY_ITEM_ID,
	CUSTOMER_ID,
	ORDER_NUMBER,
	HEADER_ID,
	TIME_REQUEST_DATE_ID,
	TIME_SCHEDULE_DATE_ID,
	LINE_NUMBER,
	DAYS_LATE_REQUEST,
	DAYS_LATE_SCHEDULE,
	BACKORDER_QTY,
	UOM,
	BACKORDER_LINE_CNT,
	TIME_SNAPSHOT_DATE_ID,
	SOLD_TO_ORG_ID,
	SHIP_TO_ORG_ID,
        LINE_ID)
  SELECT NULL, NULL, NULL, -1, -1, NULL, NULL, NULL, 0, 0, 0, NULL, 0, trunc(sysdate), NULL, NULL, NULL
    FROM dual
  UNION ALL
  SELECT fact.item_inv_org_id	INV_ORG_ID,
    	 fact.inventory_item_id,
	 fact.ship_to_party_id,
	 fact.order_number,
	 fact.header_id,
	 fact.time_request_date_id,
	 fact.time_schedule_date_id,
	 fact.line_number,
	 (trunc(sysdate) - fact.time_request_date_id) DAYS_LATE_REQUEST,
	 (trunc(sysdate) - fact.time_schedule_date_id) DAYS_LATE_SCHEDULE,
         fact.booked_qty_inv	BACKORDER_QTY,
	 fact.inv_uom_code	UOM,
	 1 		BACKORDER_LINE_CNT,
         trunc(sysdate) TIME_SNAPSHOT_DATE_ID,
	 fact.sold_to_org_id,
	 fact.ship_to_org_id,
         fact.line_id
    FROM isc_book_sum2_f fact,
	 wsh_delivery_details wdd
     WHERE  fact.line_id = wdd.source_line_id
         AND fact.flow_status_code in ('AWAITING_SHIPPING','PRODUCTION_COMPLETE','PRODUCTION_OPEN','PRODUCTION_PARTIAL','PRODUCTION_ELIGIBLE')
         AND wdd.released_status = 'B'
         AND fact.line_category_code <> 'RETURN'
         AND fact.open_flag = 'Y'
         AND fact.item_type_code <> 'SERVICE'
         AND fact.order_source_id <> 27
         AND fact.ordered_quantity <> 0
         AND fact.charge_periodicity_code is NULL;

  l_row_count := l_row_count + sql%rowcount;

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Inserted ' || l_row_count || ' rows into ISC_BOOK_SUM2_BKORD_F in');

  BIS_COLLECTION_UTILITIES.WRAPUP(
  TRUE,
  l_row_count,
  NULL,
  l_from_date,
  l_to_date
  );

 EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    l_row_count,
    g_errbuf,
    l_from_date,
    l_to_date
    );

  WHEN OTHERS THEN
    ROLLBACK;
    errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| errbuf);
    retcode := -1;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    l_row_count,
    errbuf,
    l_from_date,
    l_to_date
    );

END refresh_backorder;

END isc_dbi_book_sum2_ref_pkg;

/
