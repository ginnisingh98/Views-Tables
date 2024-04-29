--------------------------------------------------------
--  DDL for Package Body POA_EDW_CONTRACT_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_CONTRACT_F_C" AS
/* $Header: poafpctb.pls 120.1 2005/06/13 12:58:20 sriswami noship $ */
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
       l_stmt := 'TRUNCATE TABLE ' || l_poa_schema || '.POA_EDW_CONTRACT_INC';
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
   INSERT INTO poa_edw_contract_inc(primary_key)
   SELECT po_header_id
   FROM POA_EDW_CONTRACT_FSTG
   where COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR
         COLLECTION_STATUS = 'INVALID CURRENCY';

   IF (sql%rowcount > 0) THEN
        g_retcode := 1;
   END IF;


-- Generates "Warning" message in the Status column
-- of Concurrent Manager "Requests" table
      edw_log.put_line(' ');
      edw_log.put_line('INSERTING ' || to_char(sql%rowcount) ||
           ' rows into poa_edw_contract_inc table');
 END;

-----------------------------------------------------------
--  PROCEDURE DELETE_STG_MISSING_RATES
-----------------------------------------------------------
-- Procedure to remove rows from local staging table that have
-- collection status of either rate not available or invalid currency.
 PROCEDURE DELETE_STG_MISSING_RATES
 IS
 BEGIN
   DELETE FROM POA_EDW_CONTRACT_FSTG
   WHERE  COLLECTION_STATUS = 'RATE NOT AVAILABLE'
      OR COLLECTION_STATUS = 'INVALID CURRENCY'
     AND    INSTANCE_FK = (SELECT INSTANCE_CODE
                        FROM   EDW_LOCAL_INSTANCE);
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
   Insert Into POA_EDW_CONTRACT_FSTG(
     DUNS_FK,
     SIC_CODE_FK,
     CONTRACT_NUM,
     ACCPT_DUE_DATE_FK,
     ACCPT_REQUIRED_FK,
     AMT_AGREED_G,
     AMT_AGREED_T,
     AMT_LIMIT_G,
     AMT_LIMIT_T,
     AMT_MIN_RELEASE_G,
     AMT_MIN_RELEASE_T,
     AMT_RELEASED_G,
     AMT_RELEASED_T,
     APPROVED_DATE_FK,
     APPROVED_FK,
     APPROVER_FK,
     AP_TERMS_FK,
     BILL_LOCATION_FK,
     BUYER_FK,
     CANCELLED_FK,
     CLOSED_FK,
     COMMENTS,
     CONFIRM_ORDER_FK,
     CONTRACT_EFFECTIVE_FK,
     CONTRACT_PK,
     CREATION_DATE_FK,
     EDI_PROCESSED_FK,
     END_DATE_FK,
     FOB_FK,
     FREIGHT_TERMS_FK,
     FROZEN_FK,
     INSTANCE_FK,
     NUM_DAYS_APP_SEND_TO_ACCPT,
     NUM_DAYS_APP_TO_SEND,
     NUM_DAYS_CREATE_TO_APP,
     OPERATING_UNIT_FK,
     PO_HEADER_ID,
     PO_TYPE_FK,
     PRINTED_DATE_FK,
     RECEIVER_NOTE,
     REVISED_DATE_FK,
     REVISION_NUM,
     SHIP_LOCATION_FK,
     SHIP_VIA_FK,
     START_DATE_FK,
     SUPPLIER_NOTE,
     SUPPLIER_SITE_FK,
     SUP_SITE_GEOG_FK,
     TXN_CUR_CODE_FK,
     TXN_CUR_DATE_FK,
     TXN_CUR_RATE,
     TXN_CUR_RATE_TYPE,
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
     USER_HOLD_FK,
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     NVL(DUNS_FK, 'NA_EDW'),
     NVL(SIC_CODE_FK, 'NA_EDW'),
     CONTRACT_NUM,
     NVL(ACCPT_DUE_DATE_FK,'NA_EDW'),
     NVL(ACCPT_REQUIRED_FK,'NA_EDW'),
     AMT_AGREED_G,
     AMT_AGREED_T,
     AMT_LIMIT_G,
     AMT_LIMIT_T,
     AMT_MIN_RELEASE_G,
     AMT_MIN_RELEASE_T,
     AMT_RELEASED_G,
     AMT_RELEASED_T,
     NVL(APPROVED_DATE_FK,'NA_EDW'),
     NVL(APPROVED_FK,'NA_EDW'),
     NVL(APPROVER_FK,'NA_EDW'),
     NVL(AP_TERMS_FK,'NA_EDW'),
     NVL(BILL_LOCATION_FK,'NA_EDW'),
     NVL(BUYER_FK,'NA_EDW'),
     NVL(CANCELLED_FK,'NA_EDW'),
     NVL(CLOSED_FK,'NA_EDW'),
     COMMENTS,
     NVL(CONFIRM_ORDER_FK,'NA_EDW'),
     NVL(CONTRACT_EFFECTIVE_FK,'NA_EDW'),
     CONTRACT_PK,
     NVL(CREATION_DATE_FK,'NA_EDW'),
     NVL(EDI_PROCESSED_FK,'NA_EDW'),
     NVL(END_DATE_FK,'NA_EDW'),
     NVL(FOB_FK,'NA_EDW'),
     NVL(FREIGHT_TERMS_FK,'NA_EDW'),
     NVL(FROZEN_FK,'NA_EDW'),
     NVL(INSTANCE_FK,'NA_EDW'),
     NUM_DAYS_APP_SEND_TO_ACCPT,
     NUM_DAYS_APP_TO_SEND,
     NUM_DAYS_CREATE_TO_APP,
     NVL(OPERATING_UNIT_FK,'NA_EDW'),
     PO_HEADER_ID,
     NVL(PO_TYPE_FK,'NA_EDW'),
     NVL(PRINTED_DATE_FK,'NA_EDW'),
     RECEIVER_NOTE,
     NVL(REVISED_DATE_FK,'NA_EDW'),
     REVISION_NUM,
     NVL(SHIP_LOCATION_FK,'NA_EDW'),
     NVL(SHIP_VIA_FK,'NA_EDW'),
     NVL(START_DATE_FK,'NA_EDW'),
     SUPPLIER_NOTE,
     NVL(SUPPLIER_SITE_FK,'NA_EDW'),
     NVL(SUP_SITE_GEOG_FK,'NA_EDW'),
     NVL(TXN_CUR_CODE_FK,'NA_EDW'),
     NVL(TXN_CUR_DATE_FK,'NA_EDW'),
     TXN_CUR_RATE,
     TXN_CUR_RATE_TYPE,
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
     NVL(USER_HOLD_FK,'NA_EDW'),
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     NULL, -- OPERATION_CODE
     collection_status
   from POA_EDW_CONTRACT_AGRMNTS_FCV
   WHERE view_id   = p_view_id
   AND   seq_id    = p_seq_id;

   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('...Inserted ' || to_char(nvl(l_rows_inserted,0)) ||
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


-----------------------------------------------------------
--  PROCEDURE DELETE_DUPLICATES
-----------------------------------------------------------

 PROCEDURE DELETE_DUPLICATES IS

  -- Cursor to delete duplicates
  CURSOR Dup_Rec IS
        SELECT primary_key
         FROM poa_edw_contract_inc
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
          DELETE FROM poa_edw_contract_inc
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
   select poa_edw_contract_inc_s.nextval into l_seq_id from dual;

   /** Update the seq_id for records that had missing currency rates in
       the earlier PUSH. We need to repush these records again
    **/

        UPDATE poa_edw_contract_inc
        SET seq_id = l_seq_id
        WHERE seq_id IS NULL;

        p_count := sql%rowcount;
        edw_log.put_line( 'Updated ' ||  p_count  || ' records');

	INSERT INTO poa_edw_contract_inc(primary_key, seq_id)
	SELECT  po_header_id, l_seq_id
	  FROM  PO_HEADERS_ALL
	 WHERE  type_lookup_code            in ('CONTRACT', 'BLANKET')
           AND  approved_flag               = 'Y'
           AND  last_update_date between g_push_date_range1 and g_push_date_range2;

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

 Procedure Push(Errbuf       in out NOCOPY  Varchar2,
                Retcode      in out NOCOPY  Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS

  l_fact_name     Varchar2(30) := 'POA_EDW_CONTRACT_F';
  l_staging_table Varchar2(30) := 'POA_EDW_CONTRACT_FSTG';

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

 my_payment_currency    Varchar2(2000):=NULL;
 my_rate_date           Varchar2(2000) := NULL;
 my_collection_status   Varchar2(2000):=NULL;

  -- Cursor to get Missing rates
  CURSOR Invalid_Rates IS
         SELECT DISTINCT NVL(poh.rate_date, poh.creation_date) Rate_Date,
                         decode(poh.rate_type,
                                'User',gsob.currency_code,
                                NVL(poh.currency_code,
                                    gsob.currency_code)) From_Currency,
                         fstg.Collection_Status
         FROM POA_EDW_CONTRACT_FSTG        fstg,
              PO_HEADERS_ALL               POH,
              GL_SETS_OF_BOOKS             GSOB,
              FINANCIALS_SYSTEM_PARAMS_ALL FSP
         where (fstg.COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR
                fstg.COLLECTION_STATUS = 'INVALID CURRENCY')
          AND fstg.PO_HEADER_ID = POH.PO_HEADER_ID
          AND nvl(POH.ORG_ID, -999) = nvl(FSP.ORG_ID, -999)
          AND FSP.set_of_books_id   = GSOB.set_of_books_id;

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
      l_row_count1 := PUSH_TO_LOCAL(1, l_seq_id);

      IF (l_row_count1 = -1) THEN RAISE L_push_local_failure; END IF;

      edw_log.put_line('Inserted '|| nvl(l_row_count1, 0) ||
                       ' rows into the local staging table for view type 1');
      edw_log.put_line(' ');

    -- --------------------------------------------
    -- Delete all incremental tables' record
    -- --------------------------------------------

	TRUNCATE_INC;

      edw_log.put_line(' ');
      edw_log.put_line('truncated Increment Table');
      edw_log.put_line(' ');

    -- --------------------------------------------
    -- Insert Missing Rates from Local Staging Into Inc Tables
    -- to repush them next time
    -- --------------------------------------------
    INSERT_MISSING_RATES;

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
                                 P_PERIOD_START => g_push_date_range1,
                                 P_PERIOD_END   => g_push_date_range2);

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
                                 g_push_date_range1, g_push_date_range2);
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
                                 g_push_date_range1, g_push_date_range2);
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
                                 g_push_date_range1, g_push_date_range2);
      raise;

End;
End POA_EDW_CONTRACT_F_C;

/
