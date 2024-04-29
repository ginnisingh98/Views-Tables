--------------------------------------------------------
--  DDL for Package Body POA_EDW_PO_DIST_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_PO_DIST_F_C" AS
/* $Header: poafpdbb.pls 120.0 2005/06/02 03:03:20 appldev noship $ */
 g_push_from_date         	Date:=Null;
 g_push_to_date         	Date:=Null;
 g_row_count         		Number:=0;
 g_errbuf			VARCHAR2(2000) := NULL;
 g_retcode			VARCHAR2(200) := NULL;
 g_seq_id			NUMBER:=0;

-- ---------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE TRUNCATE_INC
-----------------------------------------------------------

 PROCEDURE TRUNCATE_INC
 IS

  l_poa_schema          VARCHAR2(30);
  l_stmt  		VARCHAR2(200);
  l_status		VARCHAR2(30);
  l_industry		VARCHAR2(30);

 BEGIN

      IF (FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema)) THEN
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_EDW_PO_DIST_INC';
         EXECUTE IMMEDIATE l_stmt;
      END IF;

 END;

-------------------------------------------------------------
-- PROCEDURE DELETE_INC
-------------------------------------------------------------

 PROCEDURE DELETE_INC
 IS

 BEGIN

      DELETE from poa_edw_po_dist_inc
      WHERE  batch_id <> 0;

 END;

-------------------------------------------------------------
-- PROCEDURE INSERT_MISSING_RATES
-------------------------------------------------------------
--Identify records that have missing rates and insert them in a temp table

PROCEDURE INSERT_MISSING_RATES
IS
 BEGIN
   INSERT INTO poa_edw_po_dist_inc(primary_key,batch_id)
   SELECT  DESTRIBUTION_ID,0
   FROM  POA_EDW_PO_DIST_FSTG fstg
   WHERE fstg.COLLECTION_STATUS = 'RATE NOT AVAILABLE'
      OR fstg.COLLECTION_STATUS = 'INVALID CURRENCY';

   IF (sql%rowcount > 0) THEN
	g_retcode := 1;
   END IF;

-- Generates "Warning" message in the Status column
-- of Concurrent Manager "Requests" table
      edw_log.put_line(' ');
      edw_log.put_line('INSERTING ' || to_char(sql%rowcount) ||
           ' rows into poa_edw_po_dist_inc table');
 END;

-----------------------------------------------------------
--  PROCEDURE DELETE_STG_MISSING_RATES
-----------------------------------------------------------
-- Procedure to remove rows from local staging table that have
-- collection status of either rate not available or invalid currency.
 PROCEDURE DELETE_STG_MISSING_RATES
 IS
 BEGIN
--   DELETE FROM POA_EDW_PO_DIST_FSTG
--   WHERE  COLLECTION_STATUS = 'RATE NOT AVAILABLE'
--      OR COLLECTION_STATUS = 'INVALID CURRENCY'
--     AND    INSTANCE_FK = (SELECT INSTANCE_CODE
--                        FROM   EDW_LOCAL_INSTANCE);
  RETURN;
 END;

-----------------------------------------------------------
--PROCEDURE PUSH_TO_LOCAL
-----------------------------------------------------------

 FUNCTION PUSH_TO_LOCAL(p_view_id NUMBER, p_seq_id NUMBER) RETURN NUMBER IS

  l_temp_date DATE:=NULL;
  l_duration  NUMBER;
  tmp_count   NUMBER;
  l_mau       NUMBER;   -- minimum accountable unit of global warehouse currency


BEGIN

/* Faustina's addition */

   l_temp_date := sysdate;

   IF (fnd_profile.value('POA_TRACE')='Y') THEN
      dbms_session.set_sql_trace(TRUE);
   END IF;

   IF (fnd_profile.value('POA_DEBUG') = 'Y') THEN
     poa_log.g_debug := TRUE;
   END IF;

  IF(fnd_profile.value('POA_POPULATE_SAVINGS_TXN') = 'Y') then
     poa_savings_main.populate_savings(g_push_from_date, g_push_to_date+1, FALSE);
     edw_log.put_line('Populated Savings table');
  END IF;

   l_duration := sysdate - l_temp_date;
   edw_log.put_line('Process Time (populating saving table): '
                    || edw_log.duration(l_duration) || ', Current system time: ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
   l_temp_date := sysdate;

/* End Faustina's Addition */


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
   edw_log.put_line('Start inserting to local staging table... ');

-- Prepare all initial variables for POA_EDW_VARIABLES_PKG

      POA_EDW_VARIABLES_PKG.init;

--
-- To populate the columns for check_cut_date and invoice_received_date in the INC table.
--
-- No need to consider the order of records, just a massive update (seq_id is same).
--
-- This is used to replace the API calls "POA_EDW_SPEND_PKG.get_check_cut_date" and
--    "POA_EDW_SPEND_PKG.get_invoice_received_date" for performance improvement.
--

   UPDATE  poa_edw_po_dist_inc
      SET (check_cut_date, invoice_received_date) =
     (SELECT min(ack.check_date), min(ain.invoice_received_date)
        FROM ap_invoice_distributions_all   aid,
             ap_invoice_payments_all        aip,
             ap_checks_all                  ack,
             ap_invoices_all                ain
       WHERE aid.po_distribution_id = primary_key
         AND aid.invoice_id  = aip.invoice_id (+)
         AND aip.check_id    = ack.check_id (+)
         AND aid.invoice_id  = ain.invoice_id);
--------------------------------------------------------

  -- get minimum accountable unit of the warehouse currency;

  l_mau := nvl( edw_currency.get_mau, 0.01 );

   Insert Into POA_EDW_PO_DIST_FSTG(
	CHECK_CUT_DATE_FK,
	INV_RECEIVED_DATE_FK,
	INV_CREATION_DATE_FK,
	GOODS_RECEIVED_DATE_FK,
	DUNS_FK,
	UNSPSC_FK,
	SIC_CODE_FK,
	APPRV_SUPPLIER_FK,
	TASK_FK,
	PO_CREATION_CYCLE_TIME,
	ORDER_TO_PAY_CYCLE_TIME,
	RECEIVE_TO_PAY_CYCL_TIME,
	INV_CREATION_CYCLE_TIME,
	INV_TO_PAY_CYCLE_TIME,
	IPV_T,
	IPV_G,
	QTY_BILLED_B,
	QTY_CANCELLED_B,
	QTY_DELIVERED_B,
	QTY_ORDERED_B,
     ACCPT_DUE_DATE_FK,
     ACCPT_REQUIRED_FK,
     ACCRUED_FK,
     AMT_BILLED_G,
     AMT_BILLED_T,
     AMT_CONTRACT_G,
     AMT_CONTRACT_T,
     AMT_LEAKAGE_G,
     AMT_LEAKAGE_T,
     AMT_NONCONTRACT_G,
     AMT_NONCONTRACT_T,
     AMT_PURCHASED_G,
     AMT_PURCHASED_T,
     APPROVER_FK,
     AP_TERMS_FK,
     BILL_LOCATION_FK,
     BUYER_FK,
     CONFIRM_ORDER_FK,
     CONTRACT_NUM,
     CONTRACT_TYPE_FK,
     DELIVER_TO_FK,
     DELIV_LOCATION_FK,
     DESTIN_ORG_FK,
     DESTIN_TYPE_FK,
     DESTRIBUTION_ID,
     DST_CREAT_DATE_FK,
     DST_ENCUMB_FK,
     EDI_PROCESSED_FK,
     FOB_FK,
     FREIGHT_TERMS_FK,
     FROZEN_FK,
     INSPECTION_REQ_FK,
     INSTANCE_FK,
     ITEM_DESCRIPTION,
     ITEM_ID,
     ITEM_FK,
     LINE_LOCATION_ID,
	LIST_PRC_UNIT_T,
     	LIST_PRC_UNIT_G,
     LNE_CREAT_DATE_FK,
     LNE_SUPPLIER_NOTE,
     LST_ACCPT_DATE_FK,
	MARKET_PRICE_T,
     	MARKET_PRICE_G,
     NEED_BY_DATE_FK,
     NEG_BY_PREPARE_FK,
     ONLINE_REQ_FK,
     PCARD_PROCESS_FK,
     POTENTIAL_SVG_G,
     POTENTIAL_SVG_T,
     PO_ACCEPT_DATE_FK,
     PO_APP_DATE_FK,
     PO_COMMENTS,
     PO_CREATE_DATE_FK,
     PO_DIST_INST_PK,
     PO_HEADER_ID,
     PO_LINE_ID,
     PO_LINE_TYPE_FK,
     PO_NUMBER,
     PO_RECEIVER_NOTE,
     PO_RELEASE_ID,
     PRICE_BREAK_FK,
	PRICE_T,
     	PRICE_G,
     	PRICE_LIMIT_T,
	PRICE_LIMIT_G,
     PRICE_TYPE_FK,
     PRINTED_DATE_FK,
     PROMISED_DATE_FK,
     PURCH_CLASS_FK,
     RCV_ROUTING_FK,
     RECEIPT_REQ_FK,
     RELEASE_DATE_FK,
     RELEASE_HOLD_FK,
     RELEASE_NUM,
     REQ_APPRV_DATE_FK,
     REQ_CREAT_DATE_FK,
     REVISED_DATE_FK,
     REVISION_NUM,
     SHIPMENT_TYPE_FK,
     SHIP_LOCATION_FK,
     SHIP_TO_ORG_FK,
     SHIP_VIA_FK,
     SHP_APPROVED_FK,
     SHP_APP_DATE_FK,
     SHP_CANCELLED_FK,
     SHP_CANCEL_REASON,
     SHP_CLOSED_FK,
     SHP_CLOSED_REASON,
     SHP_CREAT_DATE_FK,
     SHP_SRC_SHIP_ID,
     SHP_TAXABLE_FK,
     SOB_FK,
     SOURCE_DIST_ID,
     SUB_RECEIPT_FK,
     SUPPLIER_ITEM_FK,
     SUPPLIER_NOTE,
     SUPPLIER_SITE_FK,
     SUP_SITE_GEOG_FK,
     TXN_CUR_CODE_FK,
     TXN_CUR_DATE_FK,
     TXN_REASON_FK,
     EDW_UOM_FK,
     EDW_BASE_UOM_FK,
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
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
	NVL(CHECK_CUT_DATE_FK,'NA_EDW'),
        NVL(INV_RECEIVED_DATE_FK,'NA_EDW'),
        NVL(INV_CREATION_DATE_FK,'NA_EDW'),
        NVL(GOODS_RECEIVED_DATE_FK,'NA_EDW'),
        NVL(DUNS_FK,'NA_EDW'),
        NVL(UNSPSC_FK,'NA_EDW'),
        NVL(SIC_CODE_FK,'NA_EDW'),
        NVL(APPRV_SUPPLIER_FK,'NA_EDW'),
        NVL(TASK_FK,'NA_EDW'),
        PO_CREATION_CYCLE_TIME,
        ORDER_TO_PAY_CYCLE_TIME,
        RECEIVE_TO_PAY_CYCL_TIME,
        INV_CREATION_CYCLE_TIME,
	INV_TO_PAY_CYCLE_TIME,
        IPV_T,
        round(IPV_G / l_mau) * l_mau,
	QTY_BILLED_B,
	QTY_CANCELLED_B,
	QTY_DELIVERED_B,
	QTY_ORDERED_B,
     NVL(ACCPT_DUE_DATE_FK,'NA_EDW'),
     NVL(ACCPT_REQUIRED_FK,'NA_EDW'),
     NVL(ACCRUED_FK,'NA_EDW'),
     round(AMT_BILLED_G / l_mau) * l_mau,
     AMT_BILLED_T,
     round(AMT_CONTRACT_G / l_mau) * l_mau,
     AMT_CONTRACT_T,
     round(AMT_LEAKAGE_G / l_mau) * l_mau,
     AMT_LEAKAGE_T,
     round(AMT_NONCONTRACT_G / l_mau) * l_mau,
     AMT_NONCONTRACT_T,
     round(AMT_PURCHASED_G / l_mau) * l_mau,
     AMT_PURCHASED_T,
     NVL(APPROVER_FK,'NA_EDW'),
     NVL(AP_TERMS_FK,'NA_EDW'),
     NVL(BILL_LOCATION_FK,'NA_EDW'),
     NVL(BUYER_FK,'NA_EDW'),
     NVL(CONFIRM_ORDER_FK,'NA_EDW'),
     CONTRACT_NUM,
     NVL(CONTRACT_TYPE_FK,'NA_EDW'),
     NVL(DELIVER_TO_FK,'NA_EDW'),
     NVL(DELIV_LOCATION_FK,'NA_EDW'),
     NVL(DESTIN_ORG_FK,'NA_EDW'),
     NVL(DESTIN_TYPE_FK,'NA_EDW'),
     DISTRIBUTION_ID,
     NVL(DST_CREAT_DATE_FK,'NA_EDW'),
     NVL(DST_ENCUMB_FK,'NA_EDW'),
     NVL(EDI_PROCESSED_FK,'NA_EDW'),
     NVL(FOB_FK,'NA_EDW'),
     NVL(FREIGHT_TERMS_FK,'NA_EDW'),
     NVL(FROZEN_FK,'NA_EDW'),
     NVL(INSPECTION_REQ_FK,'NA_EDW'),
     NVL(INSTANCE_FK,'NA_EDW'),
     ITEM_DESCRIPTION,
     ITEM_ID,
     NVL(ITEM_FK,'NA_EDW'),
     LINE_LOCATION_ID,
     	LIST_PRC_UNIT_T,
	round(LIST_PRC_UNIT_G / l_mau) * l_mau,
     NVL(LNE_CREAT_DATE_FK,'NA_EDW'),
     LNE_SUPPLIER_NOTE,
     NVL(LST_ACCPT_DATE_FK,'NA_EDW'),
     	MARKET_PRICE_T,
	round(MARKET_PRICE_G / l_mau) * l_mau,
     NVL(NEED_BY_DATE_FK,'NA_EDW'),
     NVL(NEG_BY_PREPARE_FK,'NA_EDW'),
     NVL(ONLINE_REQ_FK,'NA_EDW'),
     NVL(PCARD_PROCESS_FK,'NA_EDW'),
     round(POTENTIAL_SVG_G / l_mau) * l_mau,
     POTENTIAL_SVG_T,
     NVL(PO_ACCEPT_DATE_FK,'NA_EDW'),
     NVL(PO_APP_DATE_FK,'NA_EDW'),
     PO_COMMENTS,
     NVL(PO_CREATE_DATE_FK,'NA_EDW'),
     PO_DIST_INST_PK,
     PO_HEADER_ID,
     PO_LINE_ID,
     NVL(PO_LINE_TYPE_FK,'NA_EDW'),
     PO_NUMBER,
     PO_RECEIVER_NOTE,
     PO_RELEASE_ID,
     NVL(PRICE_BREAK_FK,'NA_EDW'),
	PRICE_T,
     	round(PRICE_G / l_mau) * l_mau,
     	PRICE_LIMIT_T,
	round(PRICE_LIMIT_G / l_mau) * l_mau,
     NVL(PRICE_TYPE_FK,'NA_EDW'),
     NVL(PRINTED_DATE_FK,'NA_EDW'),
     NVL(PROMISED_DATE_FK,'NA_EDW'),
	NVL(PURCH_CLASS_FK, 'NA_EDW'),
     NVL(RCV_ROUTING_FK,'NA_EDW'),
     NVL(RECEIPT_REQ_FK,'NA_EDW'),
     NVL(RELEASE_DATE_FK,'NA_EDW'),
     NVL(RELEASE_HOLD_FK,'NA_EDW'),
     RELEASE_NUM,
     NVL(REQ_APPRV_DATE_FK,'NA_EDW'),
     NVL(REQ_CREAT_DATE_FK,'NA_EDW'),
     NVL(REVISED_DATE_FK,'NA_EDW'),
     REVISION_NUM,
     NVL(SHIPMENT_TYPE_FK,'NA_EDW'),
     NVL(SHIP_LOCATION_FK,'NA_EDW'),
     NVL(SHIP_TO_ORG_FK,'NA_EDW'),
     NVL(SHIP_VIA_FK,'NA_EDW'),
     NVL(SHP_APPROVED_FK,'NA_EDW'),
     NVL(SHP_APP_DATE_FK,'NA_EDW'),
     NVL(SHP_CANCELLED_FK,'NA_EDW'),
     SHP_CANCEL_REASON,
     NVL(SHP_CLOSED_FK,'NA_EDW'),
     SHP_CLOSED_REASON,
     NVL(SHP_CREAT_DATE_FK,'NA_EDW'),
     SHP_SRC_SHIP_ID,
     NVL(SHP_TAXABLE_FK,'NA_EDW'),
     NVL(SOB_FK,'NA_EDW'),
     SOURCE_DIST_ID,
     NVL(SUB_RECEIPT_FK,'NA_EDW'),
	NVL(SUPPLIER_ITEM_FK,'NA_EDW'),
     SUPPLIER_NOTE,
     NVL(SUPPLIER_SITE_FK,'NA_EDW'),
     NVL(SUP_SITE_GEOG_FK,'NA_EDW'),
     NVL(TXN_CUR_CODE_FK,'NA_EDW'),
     NVL(TXN_CUR_DATE_FK,'NA_EDW'),
     NVL(TXN_REASON_FK,'NA_EDW'),
     NVL(EDW_UOM_FK,'NA_EDW'),
	NVL(EDW_BASE_UOM_FK,'NA_EDW'),
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
     NULL, -- OPERATION_CODE
     collection_status
   from POA_EDW_PO_DISTRIBUTIONS_FCV
   WHERE view_id   = p_view_id
   AND   seq_id    = p_seq_id;

   tmp_count := sql%rowcount;

   l_duration := sysdate - l_temp_date;
   edw_log.put_line('Process Time (inserting to local staging table): '
                    || edw_log.duration(l_duration) || ', Current system time: ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

   RETURN (tmp_count);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);

END;

-----------------------------------------------------------
--  PROCEDURE DELETE_DUPLICATES
-----------------------------------------------------------

 PROCEDURE DELETE_DUPLICATES IS

  -- Cursor to delete duplicates
  CURSOR Dup_Rec IS
        SELECT primary_key
         FROM poa_edw_po_dist_inc
        ORDER BY primary_key
  FOR UPDATE;

  v_prev_id NUMBER;
  v_cur_id NUMBER;

BEGIN
    OPEN Dup_Rec;

    LOOP

       FETCH Dup_Rec INTO v_cur_id;
       exit when Dup_Rec % NOTFOUND;

       -- Check if the PK already exists
       IF (v_prev_id = v_cur_id) THEN
          DELETE FROM poa_edw_po_dist_inc
          WHERE CURRENT OF Dup_Rec;
       ELSE
          v_prev_id := v_cur_id;
       END IF;
    END LOOP;

    close Dup_Rec;
EXCEPTION
    WHEN OTHERS THEN
     IF Dup_Rec%ISOPEN THEN
        close Dup_Rec;
     END IF;
END;

---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE1
---------------------------------------------------

 FUNCTION IDENTIFY_CHANGE1 (p_view_id         IN  NUMBER,
                            p_count           OUT NOCOPY NUMBER)
 RETURN NUMBER
 IS

 l_seq_id	       NUMBER := -1;
 l_batch_size          NUMBER := fnd_profile.value('POA_COLLECTION_BATCH_SIZE');
 TYPE plsqltable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 l_primary_key         plsqltable;
 l_batch_id            plsqltable;
 l_count               NUMBER;
 l_poa_schema          VARCHAR2(30);
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);

 CURSOR v_changed_rows(g_push_from_date date,
                       g_push_to_date date,
                       p_batch_size number) IS
  SELECT po_distribution_id, ceil(rownum/p_batch_size)
        FROM
        (SELECT  pod.PO_DISTRIBUTION_ID, pol.item_id, pod.creation_date
        FROM    po_lines_all                    pol,
                po_line_locations_all           pll,
                po_headers_all                  poh,
                po_distributions_all            pod
        WHERE   pod.line_location_id            = pll.line_location_id
        and     pod.po_line_id                  = pol.po_line_id
        and     pod.po_header_id                = poh.po_header_id
        and     pll.shipment_type               = 'STANDARD'
        and     pll.approved_flag               = 'Y'
        and     nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
        and     greatest(pol.last_update_date, pll.last_update_date,
                         poh.last_update_date, pod.last_update_date, nvl(pod.program_update_date, pod.last_update_date))
                between  g_push_from_date and g_push_to_date
        UNION ALL
        SELECT  pod.PO_DISTRIBUTION_ID, pol.item_id, pod.creation_date
        FROM    po_lines_all                    pol,
                po_line_locations_all           pll,
                po_headers_all                  poh,
                po_releases_all                 por,
                po_distributions_all            pod
        WHERE   pod.line_location_id            = pll.line_location_id
        and     pod.po_release_id               = por.po_release_id
        and     pod.po_line_id                  = pol.po_line_id
        and     pod.po_header_id                = poh.po_header_id
        and     pll.shipment_type               in ('BLANKET', 'SCHEDULED')
        and     pll.approved_flag               = 'Y'
        and     nvl(pod.distribution_type,'-99') <> 'AGREEMENT'
        and     greatest(pol.last_update_date,pll.last_update_date,
                   poh.last_update_date,por.last_update_date,pod.last_update_date, nvl(pod.program_update_date, pod.last_update_date))
                between  g_push_from_date and g_push_to_date)
        order by item_id, creation_date;

 BEGIN

   p_count := 0;
   select poa_edw_po_dist_inc_s.nextval into l_seq_id from dual;

   /** Update the seq_id for records that had missing currency rates in
       the earlier PUSH. We need to repush these records again
    **/

        UPDATE poa_edw_po_dist_inc
        SET seq_id = l_seq_id
        WHERE seq_id IS NULL;

        p_count := sql%rowcount;
        edw_log.put_line( 'Updated ' ||  p_count  || ' records');

        open v_changed_rows(g_push_from_date, g_push_to_date, l_batch_size);
        loop
          fetch v_changed_rows bulk collect into
            l_primary_key, l_batch_id limit l_batch_size;
          l_count := l_primary_key.count;
          forall i in 1..l_count
	    INSERT into poa_edw_po_dist_inc(primary_key, seq_id, batch_id)
                      values(l_primary_key(i), l_seq_id, l_batch_id(i));
          p_count := p_count + l_count;
          EXIT WHEN l_count < l_batch_size;
        end loop;
        close v_changed_rows;

        COMMIT;
        IF (FND_INSTALLATION.GET_APP_INFO('POA', l_status, l_industry, l_poa_schema)) THEN
          FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_poa_schema, TABNAME => 'POA_EDW_PO_DIST_INC') ;
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
                p_from_date  	IN 	Varchar2,
                p_to_date    	IN 	Varchar2) IS


 l_fact_name                Varchar2(30) :='POA_EDW_PO_DIST_F';
 l_staging_table            Varchar2(30) :='POA_EDW_PO_DIST_FSTG';
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date                Date:=Null;
 l_to_date                  Date:=Null;
 l_seq_id1	            NUMBER := -1;
 l_row_count                NUMBER := 0;
 l_row_count1               NUMBER := 0;

 l_push_local_failure       EXCEPTION;
 l_iden_change_failure      EXCEPTION;
 my_payment_currency	Varchar2(2000):=NULL;
 my_rate_date		Varchar2(2000) := NULL;
 my_collection_status	Varchar2(2000):=NULL;

  -- Cursor to get Missing rates
  CURSOR Invalid_Rates IS
         SELECT DISTINCT NVL(pod.rate_date, pod.creation_date) Rate_Date,
                         decode(poh.rate_type,
                                'User',gsob.currency_code,
                                NVL(poh.currency_code,
                                    gsob.currency_code)) From_Currency,
                         fstg.Collection_Status
         FROM POA_EDW_PO_DIST_FSTG fstg,
        po_distributions_all pod,
        po_headers_all       poh,
        gl_sets_of_books     gsob
   WHERE (fstg.COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR
          fstg.COLLECTION_STATUS = 'INVALID CURRENCY')
     AND fstg.DESTRIBUTION_ID = pod.po_distribution_id
     AND fstg.PO_HEADER_ID = poh.po_header_id
     AND pod.set_of_books_id = gsob.set_of_books_id
     AND nvl(pod.distribution_type,'-99')  <> 'AGREEMENT';

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------

 BEGIN

   Errbuf :=NULL;
   Retcode:=0;

   l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_date   :=to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

   IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name, l_staging_table,
		l_staging_table, l_exception_msg)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
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
   --   Deleting the incremental table
   --  --------------------------------------------

       edw_log.put_line('Deleting incremental table...');
       edw_log.put_line('System time at start of deletion of inc. table ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
       DELETE_INC;
       edw_log.put_line('System time at end of deletion of inc. table ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
       edw_log.put_line('Incremental table deleted');

   --  --------------------------------------------
   --  Identify Change
   --  --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Identifying changes...');
      edw_log.put_line('System time at start of identify change ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
      l_seq_id1 := IDENTIFY_CHANGE1(1,l_row_count);
      edw_log.put_line('System time at end of identify change ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));

      if (l_seq_id1 = -1) THEN
        RAISE l_iden_change_failure;
      end if;
      edw_log.put_line('Identified '||l_row_count||' changed records');

   -- -------------------------------------------
   -- Delete delicates in the Inc Table
   -- --------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Deleting duplicate records from inc. table...');
   edw_log.put_line('System time at start of delete duplicates ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
   DELETE_DUPLICATES;
   edw_log.put_line('System time at end of delete duplicates ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line('Duplicate records deleted in Inc Table');

   -- --------------------------------------------
   -- Push to local staging table for view type 1
   -- --------------------------------------------

      edw_log.put_line(' ');
      edw_log.put_line('Inserting into local staging table for view type 1');
      edw_log.put_line('System time at start of push to local ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
      l_row_count1 := PUSH_TO_LOCAL(1, l_seq_id1);
      edw_log.put_line('System time at end of push to local ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));

      IF (l_row_count1 = -1) THEN RAISE L_push_local_failure; END IF;

      edw_log.put_line('Inserted ' || nvl(l_row_count1,0) ||
         ' rows into the local staging table for view type 1');
      edw_log.put_line(' ');

      g_row_count := g_row_count + nvl(l_row_count1,0);

    -- --------------------------------------------
    -- Delete all incremental tables' record
    -- --------------------------------------------
        edw_log.put_line(' ');
        edw_log.put_line('Truncating incremental table...');
        edw_log.put_line('System time at start of truncate inc ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
	TRUNCATE_INC;
        edw_log.put_line('System time at end of truncate inc ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
        edw_log.put_line('truncated Increment Table');

    -- --------------------------------------------
    -- Insert Missing Rates from Local Staging Into Inc Tables
    -- to repush them next time
    -- --------------------------------------------
    edw_log.put_line(' ');
    edw_log.put_line('Inserting missing rates...');
    edw_log.put_line('System time at start of insert missing rates ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
    INSERT_MISSING_RATES;
    edw_log.put_line('System time at end of insert missing rates ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
      edw_log.put_line(' ');
      edw_log.put_line('Checked records for Missing Rates');
      edw_log.put_line(' ');

    OPEN Invalid_Rates;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                      'FROM CURRENCY   CONVERSION DATE    COLLECTION STATUS');
    loop
      FETCH Invalid_Rates INTO my_rate_date, my_payment_currency,
                               my_collection_status;
      exit when Invalid_Rates % NOTFOUND;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, my_payment_currency ||
                        '           '|| my_rate_date ||
                        '           '|| my_collection_status);
    end loop;

    close Invalid_Rates;

      edw_log.put_line(' ');
      edw_log.put_line('Report created for records with Missing Rates');
      edw_log.put_line(' ');

    -- --------------------------------------------
    -- Delete records with missing rates from local staging table
    -- --------------------------------------------
    edw_log.put_line(' ');
    edw_log.put_line('Deleting missing rates from local staging table...');
    edw_log.put_line('System time at start of delete stg missing rates ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));
    DELETE_STG_MISSING_RATES;
    edw_log.put_line('System time at end of delete stg missing rates ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'));

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

      if (Invalid_Rates%ISOPEN) THEN
          close Invalid_Rates;
      end if;

      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;   -- Rollback insert into local staging
      edw_log.put_line('Inserting into local staging have failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
       g_push_from_date, g_push_to_date);
      raise;

   WHEN L_IDEN_CHANGE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;

      if (Invalid_Rates%ISOPEN) THEN
          close Invalid_Rates;
      end if;

      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line('Identifying changed records have Failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
       g_push_from_date, g_push_to_date);
      raise;

   WHEN OTHERS THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;

      if (Invalid_Rates%ISOPEN) THEN
          close Invalid_Rates;
      end if;

      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line('Other errors');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
       g_push_from_date, g_push_to_date);
      raise;

 END;

End POA_EDW_PO_DIST_F_C;

/
