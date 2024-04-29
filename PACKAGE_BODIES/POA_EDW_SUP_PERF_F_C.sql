--------------------------------------------------------
--  DDL for Package Body POA_EDW_SUP_PERF_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_SUP_PERF_F_C" AS
/* $Header: poafpspb.pls 120.0 2005/06/02 02:02:22 appldev noship $ */
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
         l_stmt := 'TRUNCATE TABLE ' || l_poa_schema ||'.POA_EDW_SUP_PERF_INC';
         EXECUTE IMMEDIATE l_stmt;
      END IF;

 END;


-------------------------------------------------------------
-- PROCEDURE INSERT_MISSING_RATES
-------------------------------------------------------------
--Identify records that have missing rates and insert them in a temp table

PROCEDURE INSERT_MISSING_RATES
IS
 BEGIN
   INSERT INTO poa_edw_sup_perf_inc(primary_key)
   SELECT  TO_NUMBER(SUBSTR(sup_perf_pk, 1, INSTR(sup_perf_pk, '-' )-1))
   FROM  POA_EDW_SUP_PERF_FSTG
   where COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR
         COLLECTION_STATUS = 'INVALID CURRENCY';
   IF (sql%rowcount > 0) THEN
        g_retcode := 1;
   END IF;

-- Generates "Warning" message in the Status column
-- of Concurrent Manager "Requests" table
      edw_log.put_line(' ');
      edw_log.put_line('INSERTING ' || to_char(sql%rowcount) ||
           ' rows into poa_edw_sup_perf_inc table');
 END;

-----------------------------------------------------------
--  PROCEDURE DELETE_STG_MISSING_RATES
-----------------------------------------------------------
-- Procedure to remove rows from local staging table that have
-- collection status of either rate not available or invalid currency.
 PROCEDURE DELETE_STG_MISSING_RATES
 IS
 BEGIN
   DELETE FROM POA_EDW_SUP_PERF_FSTG
   WHERE  COLLECTION_STATUS = 'RATE NOT AVAILABLE'
      OR COLLECTION_STATUS = 'INVALID CURRENCY'
     AND    INSTANCE_FK = (SELECT INSTANCE_CODE
                        FROM   EDW_LOCAL_INSTANCE);
 END;



-----------------------------------------------------------
--PROCEDURE PUSH_TO_LOCAL
-----------------------------------------------------------

FUNCTION PUSH_TO_LOCAL(p_view_id NUMBER, p_seq_id NUMBER) RETURN NUMBER IS

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

/* Get the profile option for calculating the best_price (target_price).
   This could have been done inside the API poa_edw_supperf.find_best_price,
   but it would violate the PRAGMA restriction and the API colud not compile.

   Instead, we check the profile option here in the PUSH.
   When the value is 'Yes' (the first part of the IF statment), then we SELECT
   target_price from the source view which then calls the (expensive) API
   poa_edw_supperf.find_best_price.
   Otherwise, when the value is 'No' (the second part of the IF statment),
   we populate target_price by NULL, the API won't be called in the
   fact source view */


 IF(fnd_profile.value('POA_TARGET_PRICE_TXN') = 'Y') then

   edw_log.put_line('***The best price is calculated for target prices***');

   Insert Into POA_EDW_SUP_PERF_FSTG(
     DUNS_FK,
     UNSPSC_FK,
     SIC_CODE_FK,
     AMT_PURCHASED_G,
     AMT_PURCHASED_T,
     APPROVAL_DATE_FK,
     AP_TERMS_FK,
     BUYER_FK,
     CLOSED_CODE_FK,
     CONTRACT_NUM,
     CREATION_DATE_FK,
     DATE_DIM_FK,
     DAYS_EARLY_REC,
     DAYS_LATE_REC,
     EDW_BASE_UOM_FK,
     EDW_UOM_FK,
     FIRST_REC_DATE_FK,
     INSTANCE_FK,
     INVOICE_DATE_FK,
     IPV_G,
     IPV_T,
     ITEM_FK,
     LIST_PRICE_G,
     LIST_PRICE_T,
     LST_ACCPT_DATE_FK,
     MARKET_PRICE_G,
     MARKET_PRICE_T,
     NEED_BY_DATE_FK,
     NUM_DAYS_TO_INVOICE,
     NUM_EARLY_RECEIPT,
     NUM_LATE_RECEIPT,
     NUM_ONTIME_AFTDUE,
     NUM_ONTIME_BEFDUE,
     NUM_ONTIME_ONDUE,
     NUM_RECEIPT_LINES,
     NUM_SUBS_RECEIPT,
     PO_LINE_TYPE_FK,
     PO_NUMBER,
     PRICE_G,
     PRICE_T,
     PRICE_TYPE_FK,
     PROMISED_DATE_FK,
     PURCH_CLASS_FK,
     QTY_ACCEPTED_B,
     QTY_CANCELLED_B,
     QTY_DELIVERED_B,
     QTY_EARLY_RECEIPT_B,
     QTY_LATE_RECEIPT_B,
     QTY_ONTIME_AFTDUE_B,
     QTY_ONTIME_BEFDUE_B,
     QTY_ONTIME_ONDUE_B,
     QTY_ORDERED_B,
     QTY_PAST_DUE_B,
     QTY_RECEIVED_B,
     QTY_RECEIVED_TOL,
     QTY_REJECTED_B,
     QTY_SHIPPED_B,
     QTY_SUBS_RECEIPT_B,
     RCV_CLOSE_TOL,
     RELEASE_NUM,
     SHIP_LOCATION_FK,
     SHIP_TO_ORG_FK,
     SUPPLIER_ITEM_FK,
     SUPPLIER_SITE_FK,
     SUP_PERF_PK,
     SUP_SITE_GEOG_FK,
     TARGET_PRICE_G,
     TARGET_PRICE_T,
     TXN_CUR_CODE_FK,
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
     NVL(DUNS_FK, 'NA_EDW'),
     NVL(UNSPSC_FK, 'NA_EDW'),
     NVL(SIC_CODE_FK, 'NA_EDW'),
     AMT_PURCHASED_G,
     AMT_PURCHASED_T,
     NVL(APPROVAL_DATE_FK,'NA_EDW'),
     NVL(AP_TERMS_FK,'NA_EDW'),
     NVL(BUYER_FK,'NA_EDW'),
     NVL(CLOSED_CODE_FK,'NA_EDW'),
     CONTRACT_NUM,
     NVL(CREATION_DATE_FK,'NA_EDW'),
     NVL(DATE_DIM_FK,'NA_EDW'),
     DAYS_EARLY_REC,
     DAYS_LATE_REC,
     NVL(EDW_BASE_UOM_FK,'NA_EDW'),
     NVL(EDW_UOM_FK,'NA_EDW'),
     NVL(FIRST_REC_DATE_FK,'NA_EDW'),
     NVL(INSTANCE_FK,'NA_EDW'),
     NVL(INVOICE_DATE_FK,'NA_EDW'),
     IPV_G,
     IPV_T,
     NVL(ITEM_FK,'NA_EDW'),
     LIST_PRICE_G,
     LIST_PRICE_T,
     NVL(LST_ACCPT_DATE_FK,'NA_EDW'),
     MARKET_PRICE_G,
     MARKET_PRICE_T,
     NVL(NEED_BY_DATE_FK,'NA_EDW'),
     NUM_DAYS_TO_INVOICE,
     NUM_EARLY_RECEIPT,
     NUM_LATE_RECEIPT,
     NUM_ONTIME_AFTDUE,
     NUM_ONTIME_BEFDUE,
     NUM_ONTIME_ONDUE,
     NUM_RECEIPT_LINES,
     NUM_SUBS_RECEIPT,
     NVL(PO_LINE_TYPE_FK,'NA_EDW'),
     PO_NUMBER,
     PRICE_G,
     PRICE_T,
     NVL(PRICE_TYPE_FK,'NA_EDW'),
     NVL(PROMISED_DATE_FK,'NA_EDW'),
     NVL(PURCH_CLASS_FK,'NA_EDW'),
     QTY_ACCEPTED_B,
     QTY_CANCELLED_B,
     QTY_DELIVERED_B,
     QTY_EARLY_RECEIPT_B,
     QTY_LATE_RECEIPT_B,
     QTY_ONTIME_AFTDUE_B,
     QTY_ONTIME_BEFDUE_B,
     QTY_ONTIME_ONDUE_B,
     QTY_ORDERED_B,
     QTY_PAST_DUE_B,
     QTY_RECEIVED_B,
     QTY_RECEIVED_TOL,
     QTY_REJECTED_B,
     QTY_SHIPPED_B,
     QTY_SUBS_RECEIPT_B,
     RCV_CLOSE_TOL,
     RELEASE_NUM,
     NVL(SHIP_LOCATION_FK,'NA_EDW'),
     NVL(SHIP_TO_ORG_FK,'NA_EDW'),
     NVL(SUPPLIER_ITEM_FK,'NA_EDW'),
     NVL(SUPPLIER_SITE_FK,'NA_EDW'),
     SUP_PERF_PK,
     NVL(SUP_SITE_GEOG_FK,'NA_EDW'),
     TARGET_PRICE_G,
     TARGET_PRICE_T,
     NVL(TXN_CUR_CODE_FK,'NA_EDW'),
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
     COLLECTION_STATUS
   FROM POA_EDW_SUPPLIER_PERFORM_FCV
   WHERE view_id   = p_view_id
   AND   seq_id    = p_seq_id;

 ELSE

   edw_log.put_line('***The target prices are set to NULL***');

   Insert Into POA_EDW_SUP_PERF_FSTG(
     DUNS_FK,
     UNSPSC_FK,
     SIC_CODE_FK,
     AMT_PURCHASED_G,
     AMT_PURCHASED_T,
     APPROVAL_DATE_FK,
     AP_TERMS_FK,
     BUYER_FK,
     CLOSED_CODE_FK,
     CONTRACT_NUM,
     CREATION_DATE_FK,
     DATE_DIM_FK,
     DAYS_EARLY_REC,
     DAYS_LATE_REC,
     EDW_BASE_UOM_FK,
     EDW_UOM_FK,
     FIRST_REC_DATE_FK,
     INSTANCE_FK,
     INVOICE_DATE_FK,
     IPV_G,
     IPV_T,
     ITEM_FK,
     LIST_PRICE_G,
     LIST_PRICE_T,
     LST_ACCPT_DATE_FK,
     MARKET_PRICE_G,
     MARKET_PRICE_T,
     NEED_BY_DATE_FK,
     NUM_DAYS_TO_INVOICE,
     NUM_EARLY_RECEIPT,
     NUM_LATE_RECEIPT,
     NUM_ONTIME_AFTDUE,
     NUM_ONTIME_BEFDUE,
     NUM_ONTIME_ONDUE,
     NUM_RECEIPT_LINES,
     NUM_SUBS_RECEIPT,
     PO_LINE_TYPE_FK,
     PO_NUMBER,
     PRICE_G,
     PRICE_T,
     PRICE_TYPE_FK,
     PROMISED_DATE_FK,
     PURCH_CLASS_FK,
     QTY_ACCEPTED_B,
     QTY_CANCELLED_B,
     QTY_DELIVERED_B,
     QTY_EARLY_RECEIPT_B,
     QTY_LATE_RECEIPT_B,
     QTY_ONTIME_AFTDUE_B,
     QTY_ONTIME_BEFDUE_B,
     QTY_ONTIME_ONDUE_B,
     QTY_ORDERED_B,
     QTY_PAST_DUE_B,
     QTY_RECEIVED_B,
     QTY_RECEIVED_TOL,
     QTY_REJECTED_B,
     QTY_SHIPPED_B,
     QTY_SUBS_RECEIPT_B,
     RCV_CLOSE_TOL,
     RELEASE_NUM,
     SHIP_LOCATION_FK,
     SHIP_TO_ORG_FK,
     SUPPLIER_ITEM_FK,
     SUPPLIER_SITE_FK,
     SUP_PERF_PK,
     SUP_SITE_GEOG_FK,
     TARGET_PRICE_G,
     TARGET_PRICE_T,
     TXN_CUR_CODE_FK,
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
     NVL(DUNS_FK, 'NA_EDW'),
     NVL(UNSPSC_FK, 'NA_EDW'),
     NVL(SIC_CODE_FK, 'NA_EDW'),
     AMT_PURCHASED_G,
     AMT_PURCHASED_T,
     NVL(APPROVAL_DATE_FK,'NA_EDW'),
     NVL(AP_TERMS_FK,'NA_EDW'),
     NVL(BUYER_FK,'NA_EDW'),
     NVL(CLOSED_CODE_FK,'NA_EDW'),
     CONTRACT_NUM,
     NVL(CREATION_DATE_FK,'NA_EDW'),
     NVL(DATE_DIM_FK,'NA_EDW'),
     DAYS_EARLY_REC,
     DAYS_LATE_REC,
     NVL(EDW_BASE_UOM_FK,'NA_EDW'),
     NVL(EDW_UOM_FK,'NA_EDW'),
     NVL(FIRST_REC_DATE_FK,'NA_EDW'),
     NVL(INSTANCE_FK,'NA_EDW'),
     NVL(INVOICE_DATE_FK,'NA_EDW'),
     IPV_G,
     IPV_T,
     NVL(ITEM_FK,'NA_EDW'),
     LIST_PRICE_G,
     LIST_PRICE_T,
     NVL(LST_ACCPT_DATE_FK,'NA_EDW'),
     MARKET_PRICE_G,
     MARKET_PRICE_T,
     NVL(NEED_BY_DATE_FK,'NA_EDW'),
     NUM_DAYS_TO_INVOICE,
     NUM_EARLY_RECEIPT,
     NUM_LATE_RECEIPT,
     NUM_ONTIME_AFTDUE,
     NUM_ONTIME_BEFDUE,
     NUM_ONTIME_ONDUE,
     NUM_RECEIPT_LINES,
     NUM_SUBS_RECEIPT,
     NVL(PO_LINE_TYPE_FK,'NA_EDW'),
     PO_NUMBER,
     PRICE_G,
     PRICE_T,
     NVL(PRICE_TYPE_FK,'NA_EDW'),
     NVL(PROMISED_DATE_FK,'NA_EDW'),
     NVL(PURCH_CLASS_FK,'NA_EDW'),
     QTY_ACCEPTED_B,
     QTY_CANCELLED_B,
     QTY_DELIVERED_B,
     QTY_EARLY_RECEIPT_B,
     QTY_LATE_RECEIPT_B,
     QTY_ONTIME_AFTDUE_B,
     QTY_ONTIME_BEFDUE_B,
     QTY_ONTIME_ONDUE_B,
     QTY_ORDERED_B,
     QTY_PAST_DUE_B,
     QTY_RECEIVED_B,
     QTY_RECEIVED_TOL,
     QTY_REJECTED_B,
     QTY_SHIPPED_B,
     QTY_SUBS_RECEIPT_B,
     RCV_CLOSE_TOL,
     RELEASE_NUM,
     NVL(SHIP_LOCATION_FK,'NA_EDW'),
     NVL(SHIP_TO_ORG_FK,'NA_EDW'),
     NVL(SUPPLIER_ITEM_FK,'NA_EDW'),
     NVL(SUPPLIER_SITE_FK,'NA_EDW'),
     SUP_PERF_PK,
     NVL(SUP_SITE_GEOG_FK,'NA_EDW'),
     to_number(NULL), --TARGET_PRICE_G ,
     to_number(NULL), --TARGET_PRICE_T,
     NVL(TXN_CUR_CODE_FK,'NA_EDW'),
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
     COLLECTION_STATUS
   FROM POA_EDW_SUPPLIER_PERFORM_FCV
   WHERE view_id   = p_view_id
   AND   seq_id    = p_seq_id;

END IF;

   RETURN(sql%rowcount);


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
         FROM poa_edw_sup_perf_inc
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
          DELETE FROM poa_edw_sup_perf_inc
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

-----------------------------------------------------------
--  FUNCTION INSERT_RCPT
-----------------------------------------------------------

 FUNCTION INSERT_RCPT(p_seq_id       IN NUMBER)
 RETURN NUMBER
 IS

  l_count  NUMBER;
  BEGIN

  insert into poa_edw_sup_perf_inc(primary_key, seq_id)
   select rcv.po_line_location_id, p_seq_id
   from rcv_transactions rcv, po_line_locations_all pll
   where rcv.po_line_location_id = pll.line_location_id
   and rcv.last_update_date between g_push_from_date and
       g_push_to_date
   group by rcv.po_line_location_id
   having max(rcv.last_update_date) between g_push_from_date
       and g_push_to_date;

  l_count := sql%rowcount;

  return l_count;

  EXCEPTION
  WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);

 END;


---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE1
---------------------------------------------------

 FUNCTION IDENTIFY_CHANGE1(p_view_id            IN  NUMBER,
                          p_count           OUT NOCOPY NUMBER)
 RETURN NUMBER
 IS

 l_seq_id	       NUMBER := -1;

 BEGIN

   p_count := 0;
   select poa_edw_sup_perf_inc_s.nextval into l_seq_id from dual;

   /** Update the seq_id for records that had missing currency rates in
       the earlier PUSH. We need to repush these records again
    **/

        UPDATE poa_edw_sup_perf_inc
        SET seq_id = l_seq_id
        WHERE seq_id IS NULL;

        p_count := sql%rowcount;
        edw_log.put_line( 'Updated ' ||  p_count  || ' records');

	INSERT
  	into    poa_edw_sup_perf_inc(primary_key, seq_id)
	SELECT  pll.line_location_id, l_seq_id
	FROM 	po_lines_all			pol,
		po_line_locations_all		pll,
		po_headers_all			poh
	WHERE	poh.po_header_id	    	= pll.po_header_id
	AND	pol.po_line_id		    	= pll.po_line_id
 	AND 	(greatest(pol.last_update_date,pll.last_update_date,
			poh.last_update_date)
    		        between  g_push_from_date and g_push_to_date
                 OR nvl(pll.promised_date, pll.need_by_date) +
                    nvl(pll.days_late_receipt_allowed, 0)
                    between g_push_from_date and g_push_to_date);

   p_count := p_count + sql%rowcount;

   Commit;

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


 l_fact_name                Varchar2(30) :='POA_EDW_SUP_PERF_F';
 l_staging_table            Varchar2(30) :='POA_EDW_SUP_PERF_FSTG';
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date                Date:=Null;
 l_to_date                  Date:=Null;
 l_seq_id1	            NUMBER := -1;
 l_row_count                NUMBER := 0;
 l_row_count1               NUMBER := 0;
 l_no_rcpt                  NUMBER;

 l_push_local_failure       EXCEPTION;
 l_iden_change_failure      EXCEPTION;
 l_insert_rcpt_failure      EXCEPTION;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
 my_payment_currency    Varchar2(2000):=NULL;
 my_rate_date           Varchar2(2000) := NULL;
 my_collection_status   Varchar2(2000):=NULL;

  -- Cursor to get Missing rates
  CURSOR Invalid_Rates IS
         SELECT DISTINCT NVL(poh.rate_date, pll.creation_date) Rate_Date,
                         decode(poh.rate_type,
                                'User',gsob.currency_code,
                                NVL(poh.currency_code,
                                    gsob.currency_code)) From_Currency,
                         fstg.Collection_Status
         FROM (select TO_NUMBER(SUBSTR(sup_perf_pk, 1,
                                       INSTR(sup_perf_pk, '-' )-1))
                          Line_location_id,
                      Collection_Status
               from POA_EDW_SUP_PERF_FSTG
               where COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR
                     COLLECTION_STATUS = 'INVALID CURRENCY') fstg,
              po_line_locations_all        pll,
              PO_HEADERS_ALL               POH,
              GL_SETS_OF_BOOKS             GSOB,
              FINANCIALS_SYSTEM_PARAMS_ALL FSP
        WHERE fstg.Line_location_id = pll.line_location_id
          AND PLL.PO_HEADER_ID = POH.PO_HEADER_ID
          AND NVL(fsp.org_id, -999)       = NVL(pll.org_id, -999)
          AND FSP.set_of_books_id   = GSOB.set_of_books_id;

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
   --  Identify Change
   --  --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Identifying changes...');
      l_seq_id1 := IDENTIFY_CHANGE1(1,l_row_count);

      if (l_seq_id1 = -1) THEN
        RAISE l_iden_change_failure;
      end if;
      edw_log.put_line('Identified '||l_row_count||' changed records');

   --  -------------------------------------------------------------
   --  Identify line locations for which receipts have been modified
   --  -------------------------------------------------------------
      edw_log.put_line('Calling insert_rcpt...');
      l_no_rcpt := INSERT_RCPT(l_seq_id1);

      if (l_no_rcpt = -1) THEN
        RAISE l_insert_rcpt_failure;
      end if;
      edw_log.put_line('Inserted ' || l_no_rcpt || ' records');

   -- -------------------------------------------
   -- Delete delicates in the Inc Table
   -- --------------------------------------------
   DELETE_DUPLICATES;
   edw_log.put_line('Duplicate records deleted in Inc Table');

   -- --------------------------------------------
   -- Push to local staging table for view type 1
   -- --------------------------------------------

      edw_log.put_line(' ');
      edw_log.put_line('Inserting into local staging table for view type 1');
      l_row_count1 := PUSH_TO_LOCAL(1, l_seq_id1);

      IF (l_row_count1 = -1) THEN RAISE L_push_local_failure; END IF;

      edw_log.put_line('Inserted '||nvl(l_row_count1,0)||
         ' rows into the local staging table for view type 1');
      edw_log.put_line(' ');

      g_row_count := g_row_count + nvl(l_row_count1,0);

    -- --------------------------------------------
    -- Delete all incremental tables record
    -- --------------------------------------------

      TRUNCATE_INC;

    -- --------------------------------------------
    -- Insert Missing Rates from Local Staging Into Inc Tables
    -- to repush them next time
    -- --------------------------------------------
    INSERT_MISSING_RATES;

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
    DELETE_STG_MISSING_RATES;

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
      TRUNCATE_INC;
      edw_log.put_line('Identifying changed records have Failed');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
       g_push_from_date, g_push_to_date);
      raise;

   WHEN L_INSERT_RCPT_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;

      if (Invalid_Rates%ISOPEN) THEN
          close Invalid_Rates;
      end if;

      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line('Insert_rcpt has failed');
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

End POA_EDW_SUP_PERF_F_C;

/
