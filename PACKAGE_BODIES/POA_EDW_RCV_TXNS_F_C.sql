--------------------------------------------------------
--  DDL for Package Body POA_EDW_RCV_TXNS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_RCV_TXNS_F_C" AS
/* $Header: poafprtb.pls 115.19 2003/12/09 03:11:58 jhou ship $ */
 g_push_from_date         Date:=Null;
 g_push_to_date           Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_errbuf			VARCHAR2(2000) := NULL;
 g_retcode			VARCHAR2(200) := NULL;
 g_seq_id			NUMBER:=0;

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
       l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_EDW_RCV_TXNS_INC';
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
   INSERT INTO poa_edw_rcv_txns_inc(primary_key)
   SELECT  TO_NUMBER(SUBSTR(RCV_TXN_PK, 1, INSTR(RCV_TXN_PK, '-' )-1))
   FROM  POA_EDW_RCV_TXNS_FSTG
   where COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR
         COLLECTION_STATUS = 'INVALID CURRENCY';
   IF (sql%rowcount > 0) THEN
        g_retcode := 1;
   END IF;

-- Generates "Warning" message in the Status column
-- of Concurrent Manager "Requests" table
      edw_log.put_line(' ');
      edw_log.put_line('INSERTING ' || to_char(sql%rowcount) ||
           ' rows into poa_edw_rcv_txns_inc table');
 END;

-----------------------------------------------------------
--  PROCEDURE DELETE_STG_MISSING_RATES
-----------------------------------------------------------
-- Procedure to remove rows from local staging table that have
-- collection status of either rate not available or invalid currency.
 PROCEDURE DELETE_STG_MISSING_RATES
 IS
 BEGIN
   DELETE FROM POA_EDW_RCV_TXNS_FSTG
   WHERE  COLLECTION_STATUS = 'RATE NOT AVAILABLE'
      OR COLLECTION_STATUS = 'INVALID CURRENCY'
     AND    INSTANCE_FK = (SELECT INSTANCE_CODE
                        FROM   EDW_LOCAL_INSTANCE);
 END;

-----------------------------------------------------------
--PROCEDURE PUSH_TO_LOCAL
-----------------------------------------------------------

 FUNCTION PUSH_TO_LOCAL(p_view_id NUMBER, p_seq_id NUMBER) RETURN NUMBER IS

  l_duration  NUMBER;

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

   Insert Into POA_EDW_RCV_TXNS_FSTG(
     DUNS_FK,
     UNSPSC_FK,
     SIC_CODE_FK,
     AP_TERMS_FK,
     BILL_OF_LADING,
     BUYER_FK,
     DELIVER_TO_FK,
     DELIV_LOCATION_FK,
     DESTIN_TYPE_FK,
     EDW_BASE_UOM_FK,
     EDW_UOM_FK,
     EXPCT_RCV_DATE_FK,
     FREIGHT_TERMS_FK,
     INSPECT_QUAL_FK,
     INSPECT_STATUS_FK,
     INSTANCE_FK,
     INVOICE_NUM,
     ITEM_REVISION_FK,
     LOCATOR_FK,
     LST_ACCPT_DATE_FK,
     NEED_BY_DATE_FK,
     NUM_DAYS_TO_FULL_DEL,
     PACKING_SLIP,
     PARNT_TXN_DATE_FK,
     PARNT_TXN_TYPE_FK,
     PO_LINE_TYPE_FK,
     PRICE_G,
     PRICE_T,
     PROMISED_DATE_FK,
     PURCHASE_CLASS_CODE_FK,
     QTY_ACCEPT,
     QTY_DELIVER,
     QTY_RECEIVED,
     QTY_REJECT,
     QTY_RETURN_TO_RECEIVING,
     QTY_RETURN_TO_VENDOR,
     QTY_TRANSFER,
     QTY_TXN,
     QTY_TXN_NET,
     RCV_DEL_TO_ORG_FK,
     RCV_LOCATION_FK,
     RCV_ROUTING_FK,
     RCV_TXN_PK,
     RECEIPT_NUM_INST,
     RECEIPT_SOURCE_FK,
     RECEIVE_EXCEP_FK,
     RMA_REFERENCE,
     SHIPMENT_NUM,
     SHIPPED_TO_DATE_FK,
     SHIP_HDR_COMMENTS,
     SOURCE_TXN_NUMBER,
     SRC_CREAT_DATE_FK,
     SUBST_UNORD_FK,
     SUPPLIER_ITEM_NUM_FK,
     SUPPLIER_SITE_FK,
     SUP_SITE_GEOG_FK,
     TXN_COMMENTS,
     TXN_CREAT_FK,
     TXN_CUR_CODE_FK,
     TXN_DATE_FK,
     TXN_REASON_FK,
     TXN_TYPE_FK,
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
     USER_ENTERED_FK,
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
     VENDOR_LOT_NUM,
     WAY_AIRBILL_NUM,
     po_distribution_id,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     NVL(DUNS_FK, 'NA_EDW'),
     NVL(UNSPSC_FK, 'NA_EDW'),
     NVL(SIC_CODE_FK, 'NA_EDW'),
     NVL(AP_TERMS_FK,'NA_EDW'),
     BILL_OF_LADING,
     NVL(BUYER_FK,'NA_EDW'),
     NVL(DELIVER_TO_FK,'NA_EDW'),
     NVL(DELIV_LOCATION_FK,'NA_EDW'),
     NVL(DESTIN_TYPE_FK,'NA_EDW'),
     NVL(EDW_BASE_UOM_FK,'NA_EDW'),
     NVL(EDW_UOM_FK,'NA_EDW'),
     NVL(EXPCT_RCV_DATE_FK,'NA_EDW'),
     NVL(FREIGHT_TERMS_FK,'NA_EDW'),
     NVL(INSPECT_QUAL_FK,'NA_EDW'),
     NVL(INSPECT_STATUS_FK,'NA_EDW'),
     NVL(INSTANCE_FK,'NA_EDW'),
     INVOICE_NUM,
     NVL(ITEM_REVISION_FK,'NA_EDW'),
     NVL(LOCATOR_FK,'NA_EDW'),
     NVL(LST_ACCPT_DATE_FK,'NA_EDW'),
     NVL(NEED_BY_DATE_FK,'NA_EDW'),
     NUM_DAYS_TO_FULL_DEL,
     PACKING_SLIP,
     NVL(PARNT_TXN_DATE_FK,'NA_EDW'),
     NVL(PARNT_TXN_TYPE_FK,'NA_EDW'),
     NVL(PO_LINE_TYPE_FK,'NA_EDW'),
     PRICE_G,
     PRICE_T,
     NVL(PROMISED_DATE_FK,'NA_EDW'),
     NVL(PURCHASE_CLASS_CODE_FK,'NA_EDW'),
     QTY_ACCEPT,
     QTY_DELIVER,
     QTY_RECEIVED,
     QTY_REJECT,
     QTY_RETURN_TO_RECEIVING,
     QTY_RETURN_TO_VENDOR,
     QTY_TRANSFER,
     QTY_TXN,
     QTY_TXN_NET,
     NVL(RCV_DEL_TO_ORG_FK,'NA_EDW'),
     NVL(RCV_LOCATION_FK,'NA_EDW'),
     NVL(RCV_ROUTING_FK,'NA_EDW'),
     RCV_TXN_PK,
     RECEIPT_NUM_INST,
     NVL(RECEIPT_SOURCE_FK,'NA_EDW'),
     NVL(RECEIVE_EXCEP_FK,'NA_EDW'),
     RMA_REFERENCE,
     SHIPMENT_NUM,
     NVL(SHIPPED_TO_DATE_FK,'NA_EDW'),
     SHIP_HDR_COMMENTS,
     SOURCE_TXN_NUMBER,
     NVL(SRC_CREAT_DATE_FK,'NA_EDW'),
     NVL(SUBST_UNORD_FK,'NA_EDW'),
     NVL(SUPPLIER_ITEM_NUM_FK,'NA_EDW'),
     NVL(SUPPLIER_SITE_FK,'NA_EDW'),
     NVL(SUP_SITE_GEOG_FK,'NA_EDW'),
     TXN_COMMENTS,
     NVL(TXN_CREAT_FK,'NA_EDW'),
     NVL(TXN_CUR_CODE_FK,'NA_EDW'),
     NVL(TXN_DATE_FK,'NA_EDW'),
     NVL(TXN_REASON_FK,'NA_EDW'),
     NVL(TXN_TYPE_FK,'NA_EDW'),
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
     NVL(USER_ENTERED_FK,'NA_EDW'),
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
     VENDOR_LOT_NUM,
     WAY_AIRBILL_NUM,
     po_distribution_id,
     NULL, -- OPERATION_CODE
     decode(PRICE_G,
             -1,   'RATE NOT AVAILABLE',
              -2, 'INVALID CURRENCY', 'LOCAL READY')
   from POA_EDW_RECEIVING_TXN_FCV
   WHERE view_id   = p_view_id
   AND   seq_id    = p_seq_id;


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
         FROM poa_edw_rcv_txns_inc
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
          DELETE FROM poa_edw_rcv_txns_inc
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
                            p_count           OUT NOCOPY NUMBER) RETURN NUMBER IS

 l_seq_id	       NUMBER := -1;
 l_poa_schema          VARCHAR2(30);
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);

 BEGIN

   p_count := 0;
   select poa_edw_rcv_txns_inc_s.nextval into l_seq_id from dual;

   /** Update the seq_id for records that had missing currency rates in
       the earlier PUSH. We need to repush these records again
    **/

        UPDATE poa_edw_rcv_txns_inc
        SET seq_id = l_seq_id
        WHERE seq_id IS NULL;

        p_count := sql%rowcount;
        edw_log.put_line( 'Updated ' ||  p_count  || ' records');

/* Currently, 2 tables are considered for last_update_date; we may
   need to pick more/less tables for this (DEBUG).
   Here RCV_TRANSACTIONS is the base table for the fact */

	INSERT INTO poa_edw_rcv_txns_inc(primary_key, seq_id)
	SELECT  rcv.transaction_id, l_seq_id
	  FROM  RCV_SHIPMENT_LINES    rsl,
                RCV_TRANSACTIONS      rcv
	 WHERE  rcv.SHIPMENT_LINE_ID    = rsl.SHIPMENT_LINE_ID
           AND  greatest(rcv.last_update_date,
                         rsl.last_update_date)
    		between  g_push_from_date and g_push_to_date;

   p_count := p_count + sql%rowcount;

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

  l_fact_name     Varchar2(30) :='POA_EDW_RCV_TXNS_F'  ;
  l_staging_table Varchar2(30) :='POA_EDW_RCV_TXNS_FSTG';

  l_temp_date                DATE:=NULL;
  l_duration                 NUMBER:=0;
  l_exception_msg            VARCHAR2(2000):=NULL;
  l_seq_id1	             NUMBER := -1;
  l_row_count                NUMBER := 0;
  l_row_count1               NUMBER := 0;

  l_push_local_failure       EXCEPTION;
  l_iden_change_failure      EXCEPTION;

  l_from_date                DATE;
  l_to_date                  DATE;

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
         FROM (select TO_NUMBER(SUBSTR(RCV_TXN_PK, 1,
                                       INSTR(RCV_TXN_PK, '-' )-1))
                           TRANSACTION_ID,
                      Collection_Status
               from POA_EDW_RCV_TXNS_FSTG
               where COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR
                     COLLECTION_STATUS = 'INVALID CURRENCY') fstg,
              RCV_TRANSACTIONS             RCV,
              PO_LINE_LOCATIONS_ALL        PLL,
              PO_HEADERS_ALL               POH,
              GL_SETS_OF_BOOKS             GSOB,
              FINANCIALS_SYSTEM_PARAMS_ALL FSP
        WHERE fstg.TRANSACTION_ID = RCV.TRANSACTION_ID
          AND RCV.PO_LINE_LOCATION_ID   = PLL.LINE_LOCATION_ID
          AND PLL.PO_HEADER_ID = POH.PO_HEADER_ID
          AND nvl(POH.ORG_ID, -999) = nvl(FSP.ORG_ID, -999)
          AND FSP.set_of_books_id   = GSOB.set_of_books_id;
 Begin

  Errbuf :=NULL;
  Retcode:=0;

   IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name, l_staging_table,
  		                     l_staging_table, l_exception_msg)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
   END IF;

  l_from_date := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  l_to_date := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

  g_push_from_date := NVL(l_from_date,
         EDW_COLLECTION_UTIL.G_local_last_push_start_date -
         EDW_COLLECTION_UTIL.g_offset);
  g_push_to_date := NVL(l_to_date,
         EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

   edw_log.put_line( 'The collection range is from '||
        to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

   l_temp_date := sysdate;

   --  --------------------------------------------
   --  Identify Change
   --  --------------------------------------------
      edw_log.put_line(' ');
      edw_log.put_line('Identifying changes...');
      l_seq_id1 := IDENTIFY_CHANGE1 (1, l_row_count);

      if (l_seq_id1 = -1) THEN
        RAISE l_iden_change_failure;
      end if;
      edw_log.put_line('Identified ' || l_row_count || ' changed records');

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

      edw_log.put_line('Inserted '|| nvl(l_row_count1, 0) ||
                       ' rows into the local staging table for view type 1');
      edw_log.put_line(' ');

    -- --------------------------------------------
    -- Delete all incremental tables' record
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
      g_row_count := g_row_count + l_row_count1;
      edw_log.put_line(' ');
      edw_log.put_line('Inserted '||nvl(g_row_count,0)||
                       ' rows into the staging table');
      l_duration := sysdate - l_temp_date;
      edw_log.put_line(' ');
      edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
      edw_log.put_line(' ');

      EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count,
                                 P_PERIOD_START => g_push_from_date,
                                 P_PERIOD_END   => g_push_to_date);

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

End;
End POA_EDW_RCV_TXNS_F_C;

/
