--------------------------------------------------------
--  DDL for Package Body AR_CMGT_ACCOUNT_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_ACCOUNT_MERGE" AS
/* $Header: ARCMGAMB.pls 120.4.12000000.3 2007/07/23 10:26:38 cuddagir ship $ */
/*-------------------------------------------------------------
|
|  PROCEDURE
|      CASE_FOLDER_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, AR_CMGT_CASE_FOLDERS
|
|--------------------------------------------------------------*/

PROCEDURE CASE_FOLDER_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CASE_FOLDER_ID_LIST_TYPE IS TABLE OF
         AR_CMGT_CASE_FOLDERS.CASE_FOLDER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST CASE_FOLDER_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         AR_CMGT_CASE_FOLDERS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
         AR_CMGT_CASE_FOLDERS.SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,CASE_FOLDER_ID
              ,CUST_ACCOUNT_ID
              ,SITE_USE_ID
         FROM  ar_cmgt_case_folders yt,
	       ra_customer_merges m
         WHERE yt.cust_account_id = m.duplicate_id
           AND DECODE( yt.site_use_id , -99, m.duplicate_site_id,
		yt.site_use_id ) = m.duplicate_site_id
           AND m.process_flag = 'N'
           AND m.request_id = req_id
           AND m.set_number = set_num;

  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','AR_CMGT_CASE_FOLDERS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
           limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'AR_CMGT_CASE_FOLDERS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
        DELETE FROM ar_cmgt_cf_dtls
        WHERE  case_folder_id in (
                SELECT case_folder_id
                FROM   ar_cmgt_case_folders
                WHERE  case_folder_id = PRIMARY_KEY_ID_LIST(I)
                AND    type = 'DATA');

    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
        DELETE FROM ar_cmgt_case_folders
        WHERE  case_folder_id = PRIMARY_KEY_ID_LIST(I)
        AND    type = 'DATA';

    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE AR_CMGT_CASE_FOLDERS yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          ,SITE_USE_ID=DECODE( SITE_USE_ID, -99,-99,NUM_COL2_NEW_LIST(I))
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE CASE_FOLDER_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'CASE_FOLDER_ACCOUNT_MERGE');
    RAISE;
END CASE_FOLDER_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      CREDIT_REQUEST_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, AR_CMGT_CREDIT_REQUESTS

|--------------------------------------------------------------*/

PROCEDURE CREDIT_REQUEST_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CREDIT_REQUEST_ID_LIST_TYPE IS TABLE OF
         AR_CMGT_CREDIT_REQUESTS.CREDIT_REQUEST_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST CREDIT_REQUEST_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         AR_CMGT_CREDIT_REQUESTS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
         AR_CMGT_CREDIT_REQUESTS.SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,CREDIT_REQUEST_ID
              ,CUST_ACCOUNT_ID
              ,SITE_USE_ID
         FROM  AR_CMGT_CREDIT_REQUESTS yt,
	       ra_customer_merges m
         WHERE yt.cust_account_id = m.DUPLICATE_ID
           AND DECODE( yt.site_use_id , -99, m.duplicate_site_id,
                yt.site_use_id ) = m.duplicate_site_id
           AND m.process_flag = 'N'
           AND m.request_id = req_id
           AND m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','AR_CMGT_CREDIT_REQUESTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'AR_CMGT_CREDIT_REQUESTS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE AR_CMGT_CREDIT_REQUESTS yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          ,SITE_USE_ID=DECODE(SITE_USE_ID,-99,-99, NUM_COL2_NEW_LIST(I))
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE CREDIT_REQUEST_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'CREDIT_REQUEST_ACCOUNT_MERGE');
    RAISE;
END CREDIT_REQUEST_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      TRX_BAL_SUMMARY_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, AR_TRX_BAL_SUMMARY
|
|
|--------------------------------------------------------------*/

PROCEDURE TRX_BAL_SUMMARY_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         AR_TRX_BAL_SUMMARY.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
         AR_TRX_BAL_SUMMARY.SITE_USE_ID%TYPE
            INDEX BY BINARY_INTEGER;
  PRIMARY_KEY2_LIST SITE_USE_ID_LIST_TYPE;

  TYPE CURRENCY_LIST_TYPE IS TABLE OF
         AR_TRX_BAL_SUMMARY.CURRENCY%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY3_LIST CURRENCY_LIST_TYPE;

  TYPE ORG_ID_LIST_TYPE IS TABLE OF
         AR_TRX_BAL_SUMMARY.ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY4_LIST ORG_ID_LIST_TYPE;

  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;


  NUM_COL2_ORIG_LIST SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SITE_USE_ID_LIST_TYPE;

  TYPE DATE_LIST_TYPE IS TABLE OF DATE
        INDEX BY BINARY_INTEGER;

  TYPE PAYMENT_NUMBER_LIST_TYPE IS TABLE OF
        AR_TRX_BAL_SUMMARY.LAST_PAYMENT_NUMBER%type
        INDEX BY BINARY_INTEGER;

  TYPE NUMBER_LIST_TYPE IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;

    DEL_BEST_CURRENT_RECEIVABLES		  NUMBER_LIST_TYPE;
    DEL_TOTAL_DSO_DAYS_CREDIT	          NUMBER_LIST_TYPE;
    DEL_OP_INVOICES_VALUE	              NUMBER_LIST_TYPE;
    DEL_OP_INVOICES_COUNT	              NUMBER_LIST_TYPE;
    DEL_OP_DEBIT_MEMOS_VALUE	          NUMBER_LIST_TYPE;
    DEL_OP_DEBIT_MEMOS_COUNT	          NUMBER_LIST_TYPE;
    DEL_OP_DEPOSITS_VALUE	              NUMBER_LIST_TYPE;
    DEL_OP_DEPOSITS_COUNT	              NUMBER_LIST_TYPE;
    DEL_OP_BILLS_RECEIVABLES_VALUE	      NUMBER_LIST_TYPE;
    DEL_OP_BILLS_RECEIVABLES_COUNT	      NUMBER_LIST_TYPE;
    DEL_OP_CHARGEBACK_VALUE	              NUMBER_LIST_TYPE;
    DEL_OP_CHARGEBACK_COUNT	              NUMBER_LIST_TYPE;
    DEL_OP_CREDIT_MEMOS_VALUE	          NUMBER_LIST_TYPE;
    DEL_OP_CREDIT_MEMOS_COUNT	          NUMBER_LIST_TYPE;
    DEL_UNRESOLVED_CASH_VALUE	          NUMBER_LIST_TYPE;
    DEL_UNRESOLVED_CASH_COUNT	          NUMBER_LIST_TYPE;
    DEL_RECEIPTS_AT_RISK_VALUE	          NUMBER_LIST_TYPE;
    DEL_INV_AMT_IN_DISPUTE	              NUMBER_LIST_TYPE;
    DEL_DISPUTED_INV_COUNT	              NUMBER_LIST_TYPE;
    DEL_PENDING_ADJ_VALUE	              NUMBER_LIST_TYPE;
    DEL_LAST_DUNNING_DATE	              DATE_LIST_TYPE;
    DEL_DUNNING_COUNT	                  NUMBER_LIST_TYPE;
    DEL_PAST_DUE_INV_VALUE	              NUMBER_LIST_TYPE;
    DEL_PAST_DUE_INV_INST_COUNT	          NUMBER_LIST_TYPE;
    DEL_LAST_PAYMENT_AMOUNT	              NUMBER_LIST_TYPE;
    DEL_LAST_PAYMENT_DATE	              DATE_LIST_TYPE;
    DEL_LAST_PAYMENT_NUMBER	              PAYMENT_NUMBER_LIST_TYPE;


  l_profile_val VARCHAR2(30);
/* bug4727614: Modified cursor to prevent ORA errors */
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,CUST_ACCOUNT_ID
              ,SITE_USE_ID
              ,CURRENCY
              ,yt.ORG_ID
              ,CUST_ACCOUNT_ID
              ,SITE_USE_ID
              ,BEST_CURRENT_RECEIVABLES
              ,TOTAL_DSO_DAYS_CREDIT
              ,OP_INVOICES_VALUE
              ,OP_INVOICES_COUNT
              ,OP_DEBIT_MEMOS_VALUE
              ,OP_DEBIT_MEMOS_COUNT
              ,OP_DEPOSITS_VALUE
              ,OP_DEPOSITS_COUNT
              ,OP_BILLS_RECEIVABLES_VALUE
              ,OP_BILLS_RECEIVABLES_COUNT
    ,OP_CHARGEBACK_VALUE
    ,OP_CHARGEBACK_COUNT
    ,OP_CREDIT_MEMOS_VALUE
    ,OP_CREDIT_MEMOS_COUNT
    ,UNRESOLVED_CASH_VALUE
    ,UNRESOLVED_CASH_COUNT
    ,RECEIPTS_AT_RISK_VALUE
    ,INV_AMT_IN_DISPUTE
    ,DISPUTED_INV_COUNT
    ,PENDING_ADJ_VALUE
    ,LAST_DUNNING_DATE
    ,DUNNING_COUNT
    ,PAST_DUE_INV_VALUE
    ,PAST_DUE_INV_INST_COUNT
    ,LAST_PAYMENT_AMOUNT
    ,LAST_PAYMENT_DATE
    ,LAST_PAYMENT_NUMBER
         FROM AR_TRX_BAL_SUMMARY yt, ra_customer_merges m
         WHERE yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
           AND DECODE(yt.SITE_USE_ID , -99, m.DUPLICATE_SITE_ID,
		yt.SITE_USE_ID) = m.DUPLICATE_SITE_ID
           AND m.process_flag = 'N'
           AND m.request_id = req_id
           AND m.set_number = set_num
           AND m.DUPLICATE_ID <> m.CUSTOMER_ID
        UNION
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,CUST_ACCOUNT_ID
              ,SITE_USE_ID
              ,CURRENCY
              ,yt.ORG_ID
              ,CUST_ACCOUNT_ID
              ,SITE_USE_ID
              ,BEST_CURRENT_RECEIVABLES
              ,TOTAL_DSO_DAYS_CREDIT
              ,OP_INVOICES_VALUE
              ,OP_INVOICES_COUNT
              ,OP_DEBIT_MEMOS_VALUE
              ,OP_DEBIT_MEMOS_COUNT
              ,OP_DEPOSITS_VALUE
              ,OP_DEPOSITS_COUNT
              ,OP_BILLS_RECEIVABLES_VALUE
              ,OP_BILLS_RECEIVABLES_COUNT
    ,OP_CHARGEBACK_VALUE
    ,OP_CHARGEBACK_COUNT
    ,OP_CREDIT_MEMOS_VALUE
    ,OP_CREDIT_MEMOS_COUNT
    ,UNRESOLVED_CASH_VALUE
    ,UNRESOLVED_CASH_COUNT
    ,RECEIPTS_AT_RISK_VALUE
    ,INV_AMT_IN_DISPUTE
    ,DISPUTED_INV_COUNT
    ,PENDING_ADJ_VALUE
    ,LAST_DUNNING_DATE
    ,DUNNING_COUNT
    ,PAST_DUE_INV_VALUE
    ,PAST_DUE_INV_INST_COUNT
    ,LAST_PAYMENT_AMOUNT
    ,LAST_PAYMENT_DATE
    ,LAST_PAYMENT_NUMBER
         FROM AR_TRX_BAL_SUMMARY yt, ra_customer_merges m
         WHERE yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
           AND yt.SITE_USE_ID = m.DUPLICATE_SITE_ID
           AND m.process_flag = 'N'
           AND m.request_id = req_id
           AND m.set_number = set_num
           AND m.DUPLICATE_ID = m.CUSTOMER_ID;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','AR_TRX_BAL_SUMMARY',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY1_LIST
          , PRIMARY_KEY2_LIST
          , PRIMARY_KEY3_LIST
          , PRIMARY_KEY4_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          ,DEL_BEST_CURRENT_RECEIVABLES
    ,DEL_TOTAL_DSO_DAYS_CREDIT
    ,DEL_OP_INVOICES_VALUE
    ,DEL_OP_INVOICES_COUNT
    ,DEL_OP_DEBIT_MEMOS_VALUE
    ,DEL_OP_DEBIT_MEMOS_COUNT
    ,DEL_OP_DEPOSITS_VALUE
    ,DEL_OP_DEPOSITS_COUNT
    ,DEL_OP_BILLS_RECEIVABLES_VALUE
    ,DEL_OP_BILLS_RECEIVABLES_COUNT
    ,DEL_OP_CHARGEBACK_VALUE
    ,DEL_OP_CHARGEBACK_COUNT
    ,DEL_OP_CREDIT_MEMOS_VALUE
    ,DEL_OP_CREDIT_MEMOS_COUNT
    ,DEL_UNRESOLVED_CASH_VALUE
    ,DEL_UNRESOLVED_CASH_COUNT
    ,DEL_RECEIPTS_AT_RISK_VALUE
    ,DEL_INV_AMT_IN_DISPUTE
    ,DEL_DISPUTED_INV_COUNT
    ,DEL_PENDING_ADJ_VALUE
    ,DEL_LAST_DUNNING_DATE
    ,DEL_DUNNING_COUNT
    ,DEL_PAST_DUE_INV_VALUE
    ,DEL_PAST_DUE_INV_INST_COUNT
    ,DEL_LAST_PAYMENT_AMOUNT
    ,DEL_LAST_PAYMENT_DATE
    ,DEL_LAST_PAYMENT_NUMBER
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
    arp_message.set_line( 'Request Id ='||req_id);
    arp_message.set_line( 'NUM_COL1_NEW_LIST(I)='||NUM_COL1_NEW_LIST(I));
    arp_message.set_line( 'NUM_COL2_NEW_LIST(I)='||NUM_COL2_NEW_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
    arp_message.set_line( 'Inserting into HZ_CUSTOMER_MERGE_LOG');
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           PRIMARY_KEY3,
           PRIMARY_KEY4,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           DEL_COL1,
           DEL_COL2,
           DEL_COL3,
           DEL_COL4,
           DEL_COL5,
           DEL_COL6,
           DEL_COL7,
           DEL_COL8,
           DEL_COL9,
           DEL_COL10,
           DEL_COL11,
           DEL_COL12,
           DEL_COL13,
           DEL_COL14,
           DEL_COL15,
           DEL_COL16,
           DEL_COL17,
           DEL_COL18,
           DEL_COL19,
           DEL_COL20,
           DEL_COL21,
           DEL_COL22,
           DEL_COL23,
           DEL_COL24,
           DEL_COL25,
           DEL_COL26,
           DEL_COL27,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'AR_TRX_BAL_SUMMARY',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
         PRIMARY_KEY3_LIST(I),
         PRIMARY_KEY4_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         'D',
         req_id,
         DEL_BEST_CURRENT_RECEIVABLES(I)
    ,DEL_TOTAL_DSO_DAYS_CREDIT(I)
    ,DEL_OP_INVOICES_VALUE(I)
    ,DEL_OP_INVOICES_COUNT(I)
    ,DEL_OP_DEBIT_MEMOS_VALUE(I)
    ,DEL_OP_DEBIT_MEMOS_COUNT(I)
    ,DEL_OP_DEPOSITS_VALUE(I)
    ,DEL_OP_DEPOSITS_COUNT(I)
    ,DEL_OP_BILLS_RECEIVABLES_VALUE(I)
    ,DEL_OP_BILLS_RECEIVABLES_COUNT(I)
    ,DEL_OP_CHARGEBACK_VALUE(I)
    ,DEL_OP_CHARGEBACK_COUNT(I)
    ,DEL_OP_CREDIT_MEMOS_VALUE(I)
    ,DEL_OP_CREDIT_MEMOS_COUNT(I)
    ,DEL_UNRESOLVED_CASH_VALUE(I)
    ,DEL_UNRESOLVED_CASH_COUNT(I)
    ,DEL_RECEIPTS_AT_RISK_VALUE(I)
    ,DEL_INV_AMT_IN_DISPUTE(I)
    ,DEL_DISPUTED_INV_COUNT(I)
    ,DEL_PENDING_ADJ_VALUE(I)
    ,DEL_LAST_DUNNING_DATE(I)
    ,DEL_DUNNING_COUNT(I)
    ,DEL_PAST_DUE_INV_VALUE(I)
    ,DEL_PAST_DUE_INV_INST_COUNT(I)
    ,DEL_LAST_PAYMENT_AMOUNT(I)
    ,DEL_LAST_PAYMENT_DATE(I)
    ,DEL_LAST_PAYMENT_NUMBER(I),
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    arp_message.set_line( 'after Insert into HZ_CUSTOMER_MERGE_LOG');
    END IF;
    arp_message.set_line( 'before UPDATE AR_TRX_BAL_SUMMARY ');
  FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE AR_TRX_BAL_SUMMARY yt SET
           (BEST_CURRENT_RECEIVABLES
              ,TOTAL_DSO_DAYS_CREDIT
              ,OP_INVOICES_VALUE
              ,OP_INVOICES_COUNT
              ,OP_DEBIT_MEMOS_VALUE
              ,OP_DEBIT_MEMOS_COUNT
              ,OP_DEPOSITS_VALUE
              ,OP_DEPOSITS_COUNT
              ,OP_BILLS_RECEIVABLES_VALUE
              ,OP_BILLS_RECEIVABLES_COUNT
              ,OP_CHARGEBACK_VALUE
              ,OP_CHARGEBACK_COUNT
              ,OP_CREDIT_MEMOS_VALUE
              ,OP_CREDIT_MEMOS_COUNT
              ,UNRESOLVED_CASH_VALUE
              ,UNRESOLVED_CASH_COUNT
              ,RECEIPTS_AT_RISK_VALUE
              ,INV_AMT_IN_DISPUTE
              ,DISPUTED_INV_COUNT
              ,PENDING_ADJ_VALUE
              ,PAST_DUE_INV_VALUE
              ,PAST_DUE_INV_INST_COUNT
              ,LAST_PAYMENT_AMOUNT
              ,LAST_PAYMENT_DATE
              ,LAST_PAYMENT_NUMBER
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,LAST_UPDATE_LOGIN
)	=
                            ( SELECT  DECODE( yt.BEST_CURRENT_RECEIVABLES, null,
                                            DECODE(yt1.BEST_CURRENT_RECEIVABLES, null, null,
                                            nvl(yt.BEST_CURRENT_RECEIVABLES,0) +
                                            nvl(yt1.BEST_CURRENT_RECEIVABLES,0)),
                                         nvl(yt.BEST_CURRENT_RECEIVABLES,0) +
                                         nvl(yt1.BEST_CURRENT_RECEIVABLES,0)) ,
                                      DECODE( yt.TOTAL_DSO_DAYS_CREDIT, null,
                                            DECODE(yt1.TOTAL_DSO_DAYS_CREDIT, null, null,
                                            nvl(yt.TOTAL_DSO_DAYS_CREDIT,0) +
                                            nvl(yt1.TOTAL_DSO_DAYS_CREDIT,0)),
                                         nvl(yt.TOTAL_DSO_DAYS_CREDIT,0) +
                                         nvl(yt1.TOTAL_DSO_DAYS_CREDIT,0)) ,
                                      DECODE( yt.OP_INVOICES_VALUE, null,
                                            DECODE(yt1.OP_INVOICES_VALUE, null, null,
                                            nvl(yt.OP_INVOICES_VALUE,0) +
                                            nvl(yt1.OP_INVOICES_VALUE,0)),
                                         nvl(yt.OP_INVOICES_VALUE,0) +
                                         nvl(yt1.OP_INVOICES_VALUE,0)) ,
                                      DECODE( yt.OP_INVOICES_COUNT, null,
                                            DECODE(yt1.OP_INVOICES_COUNT, null, null,
                                            nvl(yt.OP_INVOICES_COUNT,0) +
                                            nvl(yt1.OP_INVOICES_COUNT,0)),
                                         nvl(yt.OP_INVOICES_COUNT,0) +
                                         nvl(yt1.OP_INVOICES_COUNT,0)) ,
                                      DECODE( yt.OP_DEBIT_MEMOS_VALUE, null,
                                            DECODE(yt1.OP_DEBIT_MEMOS_VALUE, null, null,
                                            nvl(yt.OP_DEBIT_MEMOS_VALUE,0) +
                                            nvl(yt1.OP_DEBIT_MEMOS_VALUE,0)),
                                         nvl(yt.OP_DEBIT_MEMOS_VALUE,0) +
                                         nvl(yt1.OP_DEBIT_MEMOS_VALUE,0)) ,
                                      DECODE( yt.OP_DEBIT_MEMOS_COUNT, null,
                                            DECODE(yt1.OP_DEBIT_MEMOS_COUNT, null, null,
                                            nvl(yt.OP_DEBIT_MEMOS_COUNT,0) +
                                            nvl(yt1.OP_DEBIT_MEMOS_COUNT,0)),
                                         nvl(yt.OP_DEBIT_MEMOS_COUNT,0) +
                                         nvl(yt1.OP_DEBIT_MEMOS_COUNT,0)) ,
                                      DECODE( yt.OP_DEPOSITS_VALUE, null,
                                            DECODE(yt1.OP_DEPOSITS_VALUE, null, null,
                                            nvl(yt.OP_DEPOSITS_VALUE,0) +
                                            nvl(yt1.OP_DEPOSITS_VALUE,0)),
                                         nvl(yt.OP_DEPOSITS_VALUE,0) +
                                         nvl(yt1.OP_DEPOSITS_VALUE,0)) ,
                                      DECODE( yt.OP_DEPOSITS_COUNT, null,
                                            DECODE(yt1.OP_DEPOSITS_COUNT, null, null,
                                            nvl(yt.OP_DEPOSITS_COUNT,0) +
                                            nvl(yt1.OP_DEPOSITS_COUNT,0)),
                                         nvl(yt.OP_DEPOSITS_COUNT,0) +
                                         nvl(yt1.OP_DEPOSITS_COUNT,0)) ,
                                      DECODE( yt.OP_BILLS_RECEIVABLES_VALUE, null,
                                            DECODE(yt1.OP_BILLS_RECEIVABLES_VALUE, null, null,
                                            nvl(yt.OP_BILLS_RECEIVABLES_VALUE,0) +
                                            nvl(yt1.OP_BILLS_RECEIVABLES_VALUE,0)),
                                         nvl(yt.OP_BILLS_RECEIVABLES_VALUE,0) +
                                         nvl(yt1.OP_BILLS_RECEIVABLES_VALUE,0)) ,
                                      DECODE( yt.OP_BILLS_RECEIVABLES_COUNT, null,
                                            DECODE(yt1.OP_BILLS_RECEIVABLES_COUNT, null, null,
                                            nvl(yt.OP_BILLS_RECEIVABLES_COUNT,0) +
                                            nvl(yt1.OP_BILLS_RECEIVABLES_COUNT,0)),
                                         nvl(yt.OP_BILLS_RECEIVABLES_COUNT,0) +
                                         nvl(yt1.OP_BILLS_RECEIVABLES_COUNT,0)) ,
                                      DECODE( yt.OP_CHARGEBACK_VALUE, null,
                                            DECODE(yt1.OP_CHARGEBACK_VALUE, null, null,
                                            nvl(yt.OP_CHARGEBACK_VALUE,0) +
                                            nvl(yt1.OP_CHARGEBACK_VALUE,0)),
                                         nvl(yt.OP_CHARGEBACK_VALUE,0) +
                                         nvl(yt1.OP_CHARGEBACK_VALUE,0)) ,
                                      DECODE( yt.OP_CHARGEBACK_COUNT, null,
                                            DECODE(yt1.OP_CHARGEBACK_COUNT, null, null,
                                            nvl(yt.OP_CHARGEBACK_COUNT,0) +
                                            nvl(yt1.OP_CHARGEBACK_COUNT,0)),
                                         nvl(yt.OP_CHARGEBACK_COUNT,0) +
                                         nvl(yt1.OP_CHARGEBACK_COUNT,0)) ,
                                      DECODE( yt.OP_CREDIT_MEMOS_VALUE, null,
                                            DECODE(yt1.OP_CREDIT_MEMOS_VALUE, null, null,
                                            nvl(yt.OP_CREDIT_MEMOS_VALUE,0) +
                                            nvl(yt1.OP_CREDIT_MEMOS_VALUE,0)),
                                         nvl(yt.OP_CREDIT_MEMOS_VALUE,0) +
                                         nvl(yt1.OP_CREDIT_MEMOS_VALUE,0)) ,
                                      DECODE( yt.OP_CREDIT_MEMOS_COUNT, null,
                                            DECODE(yt1.OP_CREDIT_MEMOS_COUNT, null, null,
                                            nvl(yt.OP_CREDIT_MEMOS_COUNT,0) +
                                            nvl(yt1.OP_CREDIT_MEMOS_COUNT,0)),
                                         nvl(yt.OP_CREDIT_MEMOS_COUNT,0) +
                                         nvl(yt1.OP_CREDIT_MEMOS_COUNT,0)) ,
                                      DECODE( yt.UNRESOLVED_CASH_VALUE, null,
                                            DECODE(yt1.UNRESOLVED_CASH_VALUE, null, null,
                                            nvl(yt.UNRESOLVED_CASH_VALUE,0) +
                                            nvl(yt1.UNRESOLVED_CASH_VALUE,0)),
                                         nvl(yt.UNRESOLVED_CASH_VALUE,0) +
                                         nvl(yt1.UNRESOLVED_CASH_VALUE,0)) ,
                                      DECODE( yt.UNRESOLVED_CASH_VALUE, null,
                                            DECODE(yt1.UNRESOLVED_CASH_COUNT, null, null,
                                            nvl(yt.UNRESOLVED_CASH_COUNT,0) +
                                            nvl(yt1.UNRESOLVED_CASH_COUNT,0)),
                                         nvl(yt.UNRESOLVED_CASH_COUNT,0) +
                                         nvl(yt1.UNRESOLVED_CASH_COUNT,0)) ,
                                       DECODE( yt.RECEIPTS_AT_RISK_VALUE, null,
                                            DECODE(yt1.RECEIPTS_AT_RISK_VALUE, null, null,
                                            nvl(yt.RECEIPTS_AT_RISK_VALUE,0) +
                                            nvl(yt1.RECEIPTS_AT_RISK_VALUE,0)),
                                         nvl(yt.RECEIPTS_AT_RISK_VALUE,0) +
                                         nvl(yt1.RECEIPTS_AT_RISK_VALUE,0)) ,
                                       DECODE( yt.INV_AMT_IN_DISPUTE, null,
                                            DECODE(yt1.INV_AMT_IN_DISPUTE, null, null,
                                            nvl(yt.INV_AMT_IN_DISPUTE,0) +
                                            nvl(yt1.INV_AMT_IN_DISPUTE,0)),
                                         nvl(yt.INV_AMT_IN_DISPUTE,0) +
                                         nvl(yt1.INV_AMT_IN_DISPUTE,0)) ,
                                       DECODE( yt.DISPUTED_INV_COUNT, null,
                                            DECODE(yt1.DISPUTED_INV_COUNT, null, null,
                                            nvl(yt.DISPUTED_INV_COUNT,0) +
                                            nvl(yt1.DISPUTED_INV_COUNT,0)),
                                         nvl(yt.DISPUTED_INV_COUNT,0) +
                                         nvl(yt1.DISPUTED_INV_COUNT,0)) ,
                                       DECODE( yt.PENDING_ADJ_VALUE, null,
                                            DECODE(yt1.PENDING_ADJ_VALUE, null, null,
                                            nvl(yt.PENDING_ADJ_VALUE,0) +
                                            nvl(yt1.PENDING_ADJ_VALUE,0)),
                                         nvl(yt.PENDING_ADJ_VALUE,0) +
                                         nvl(yt1.PENDING_ADJ_VALUE,0)) ,
                                       DECODE( yt.PAST_DUE_INV_VALUE, null,
                                            DECODE(yt1.PAST_DUE_INV_VALUE, null, null,
                                            nvl(yt.PAST_DUE_INV_VALUE,0) +
                                            nvl(yt1.PAST_DUE_INV_VALUE,0)),
                                         nvl(yt.PAST_DUE_INV_VALUE,0) +
                                         nvl(yt1.PAST_DUE_INV_VALUE,0)) ,
                                       DECODE( yt.PAST_DUE_INV_INST_COUNT, null,
                                            DECODE(yt1.PAST_DUE_INV_INST_COUNT, null, null,
                                            nvl(yt.PAST_DUE_INV_INST_COUNT,0) +
                                            nvl(yt1.PAST_DUE_INV_INST_COUNT,0)),
                                         nvl(yt.PAST_DUE_INV_INST_COUNT,0) +
                                         nvl(yt1.PAST_DUE_INV_INST_COUNT,0)) ,
                                       DECODE(GREATEST(nvl(yt.LAST_PAYMENT_DATE,yt1.last_payment_date),
                                                       nvl(yt1.LAST_PAYMENT_DATE, yt.last_payment_date)),
                                                yt.LAST_PAYMENT_DATE, yt.LAST_PAYMENT_AMOUNT,
                                                yt1.LAST_PAYMENT_AMOUNT),
                                       GREATEST(nvl(yt.LAST_PAYMENT_DATE,yt1.last_payment_date),
                                                       nvl(yt1.LAST_PAYMENT_DATE, yt.last_payment_date)),
                                       DECODE(GREATEST(nvl(yt.LAST_PAYMENT_DATE,yt1.last_payment_date),
                                                       nvl(yt1.LAST_PAYMENT_DATE, yt.last_payment_date)),
                                                yt.LAST_PAYMENT_DATE, yt.LAST_PAYMENT_NUMBER,
                                                yt1.LAST_PAYMENT_NUMBER),
                                       sysdate,
                                       FND_GLOBAL.user_id,
                                       FND_GLOBAL.login_id
                                FROM     ar_trx_bal_summary yt1
                                WHERE    yt1.cust_account_id = PRIMARY_KEY1_LIST(I)
                                AND   yt1.SITE_USE_ID=PRIMARY_KEY2_LIST(I)
                                AND   yt1.CURRENCY=PRIMARY_KEY3_LIST(I)
                                AND   yt1.ORG_ID=PRIMARY_KEY4_LIST(I)
                                AND   EXISTS ( SELECT 'X'
                                                FROM AR_TRX_BAL_SUMMARY yt2
                                                WHERE yt2.CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
                                                AND yt2.SITE_USE_ID=NUM_COL2_NEW_LIST(I)
                                                AND yt2.CURRENCY=PRIMARY_KEY3_LIST(I)
                                                AND yt2.ORG_ID=PRIMARY_KEY4_LIST(I) ))
        WHERE  yt.CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
           AND yt.SITE_USE_ID=NUM_COL2_NEW_LIST(I)
           AND yt.CURRENCY=PRIMARY_KEY3_LIST(I)
           AND yt.ORG_ID=PRIMARY_KEY4_LIST(I) ;

    arp_message.set_line( 'after UPDATE AR_TRX_BAL_SUMMARY ');
    arp_message.set_line( 'before DELETE AR_TRX_BAL_SUMMARY');
      FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
        DELETE  AR_TRX_BAL_SUMMARY yt
            WHERE    yt.cust_account_id = PRIMARY_KEY1_LIST(I)
                    AND   yt.SITE_USE_ID=PRIMARY_KEY2_LIST(I)
                    AND   yt.CURRENCY=PRIMARY_KEY3_LIST(I)
                    AND   yt.ORG_ID=PRIMARY_KEY4_LIST(I)
                    AND   EXISTS ( SELECT 'X'
                                                FROM AR_TRX_BAL_SUMMARY yt2
                                                WHERE yt2.CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
                                                AND yt2.SITE_USE_ID=NUM_COL2_NEW_LIST(I)
                                                AND yt2.CURRENCY=PRIMARY_KEY3_LIST(I)
                                                AND yt2.ORG_ID=PRIMARY_KEY4_LIST(I) );

    arp_message.set_line( 'after  DELETE  AR_TRX_BAL_SUMMARY');

    arp_message.set_line( 'before UPDATE AR_TRX_BAL_SUMMARY again');
/* bug4727614: Added not exists clause to prevent unique index error */
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE AR_TRX_BAL_SUMMARY yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          ,SITE_USE_ID=DECODE(SITE_USE_ID, -99, -99, NUM_COL2_NEW_LIST(I))
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE  CUST_ACCOUNT_ID=PRIMARY_KEY1_LIST(I)
        AND SITE_USE_ID=PRIMARY_KEY2_LIST(I)
        AND CURRENCY=PRIMARY_KEY3_LIST(I)
        AND ORG_ID=PRIMARY_KEY4_LIST(I)
        and not exists ( SELECT 'X'
                                                FROM AR_TRX_BAL_SUMMARY yt2
                                                WHERE yt2.CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
                                                AND yt2.SITE_USE_ID=NUM_COL2_NEW_LIST(I)
                                                AND yt2.CURRENCY=PRIMARY_KEY3_LIST(I)
                                                AND yt2.ORG_ID=PRIMARY_KEY4_LIST(I) );

    arp_message.set_line( 'after UPDATE AR_TRX_BAL_SUMMARY again');
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'TRX_BAL_SUMMARY_ACCOUNT_MERGE');
    arp_message.set_line( 'TRX_BAL_SUMMARY_ACCOUNT_MERGE: SQLERRM : ' || SQLERRM);
    RAISE;
END TRX_BAL_SUMMARY_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      TRX_SUMMARY_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, AR_TRX_SUMMARY
|   Bug4502961: Modified cursor merged_records to avoid error
|
|--------------------------------------------------------------*/

PROCEDURE TRX_SUMMARY_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         AR_TRX_SUMMARY.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
         AR_TRX_SUMMARY.SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY2_LIST SITE_USE_ID_LIST_TYPE;

  TYPE CURRENCY_LIST_TYPE IS TABLE OF
         AR_TRX_SUMMARY.CURRENCY%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY3_LIST CURRENCY_LIST_TYPE;

  TYPE AS_OF_DATE_LIST_TYPE IS TABLE OF
         AR_TRX_SUMMARY.AS_OF_DATE%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY4_LIST AS_OF_DATE_LIST_TYPE;

  TYPE ORG_ID_LIST_TYPE IS TABLE OF
         AR_TRX_SUMMARY.ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY5_LIST ORG_ID_LIST_TYPE;

  TYPE NUMBER_LIST_TYPE IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;



    DEL_OP_BAL_HIGH_WATERMARK	               NUMBER_LIST_TYPE;
    DEL_TOTAL_CASH_RECEIPTS_VALUE	          NUMBER_LIST_TYPE;
    DEL_TOTAL_CASH_RECEIPTS_COUNT	          NUMBER_LIST_TYPE;
    DEL_TOTAL_INVOICES_VALUE	              NUMBER_LIST_TYPE;
    DEL_TOTAL_INVOICES_COUNT	              NUMBER_LIST_TYPE;
    DEL_INV_PAID_AMOUNT	                      NUMBER_LIST_TYPE;
    DEL_INV_INST_PMT_DAYS_SUM	              NUMBER_LIST_TYPE;
    DEL_TOTAL_BILLS_REC_VALUE	              NUMBER_LIST_TYPE;
    DEL_TOTAL_BILLS_REC_COUNT	              NUMBER_LIST_TYPE;
    DEL_TOTAL_CREDIT_MEMOS_VALUE	          NUMBER_LIST_TYPE;
    DEL_TOTAL_CREDIT_MEMOS_COUNT	          NUMBER_LIST_TYPE;
    DEL_TOTAL_DEBIT_MEMOS_VALUE	              NUMBER_LIST_TYPE;
    DEL_TOTAL_DEBIT_MEMOS_COUNT	              NUMBER_LIST_TYPE;
    DEL_TOTAL_CHARGEBACK_VALUE	              NUMBER_LIST_TYPE;
    DEL_TOTAL_CHARGEBACK_COUNT	              NUMBER_LIST_TYPE;
    DEL_TOTAL_EARNED_DISC_VALUE	              NUMBER_LIST_TYPE;
    DEL_TOTAL_EARNED_DISC_COUNT	              NUMBER_LIST_TYPE;
    DEL_TOTAL_UNEARNED_DISC_VALUE	          NUMBER_LIST_TYPE;
    DEL_TOTAL_UNEARNED_DISC_COUNT	          NUMBER_LIST_TYPE;
    DEL_TOTAL_ADJUSTMENTS_VALUE	              NUMBER_LIST_TYPE;
    DEL_TOTAL_ADJUSTMENTS_COUNT	              NUMBER_LIST_TYPE;
    DEL_TOTAL_DEPOSITS_VALUE	              NUMBER_LIST_TYPE;
    DEL_TOTAL_DEPOSITS_COUNT	              NUMBER_LIST_TYPE;
    DEL_SUM_APP_AMT_DAYS_LATE	              NUMBER_LIST_TYPE;
    DEL_SUM_APP_AMT	                          NUMBER_LIST_TYPE;
    DEL_COUNT_OF_TOT_INV_INST_PAID	          NUMBER_LIST_TYPE;
    DEL_CNT_OF_INV_INST_PAID_LATE	          NUMBER_LIST_TYPE;
    DEL_COUNT_OF_DISC_INV_INST	              NUMBER_LIST_TYPE;
    DEL_LARGEST_INV_AMOUNT	                  NUMBER_LIST_TYPE;
    DEL_LARGEST_INV_DATE	                  AS_OF_DATE_LIST_TYPE;
    DEL_LARGEST_INV_CUST_TRX_ID	              NUMBER_LIST_TYPE;
    DEL_DAYS_CREDIT_GRANTED_SUM	              NUMBER_LIST_TYPE;
    DEL_NSF_STOP_PAYMENT_COUNT	              NUMBER_LIST_TYPE;
    DEL_NSF_STOP_PAYMENT_AMOUNT	              NUMBER_LIST_TYPE;


  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  NUM_COL2_ORIG_LIST SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,CUST_ACCOUNT_ID
              ,SITE_USE_ID
              ,CURRENCY
              ,AS_OF_DATE
              ,yt.ORG_ID
              ,CUST_ACCOUNT_ID
              ,SITE_USE_ID
              ,OP_BAL_HIGH_WATERMARK
              ,TOTAL_CASH_RECEIPTS_VALUE
              ,TOTAL_CASH_RECEIPTS_COUNT
              ,TOTAL_INVOICES_VALUE
              ,TOTAL_INVOICES_COUNT
              ,INV_PAID_AMOUNT
              ,INV_INST_PMT_DAYS_SUM
              ,TOTAL_BILLS_RECEIVABLES_VALUE
              ,TOTAL_BILLS_RECEIVABLES_COUNT
              ,TOTAL_CREDIT_MEMOS_VALUE
              ,TOTAL_CREDIT_MEMOS_COUNT
              ,TOTAL_DEBIT_MEMOS_VALUE
              ,TOTAL_DEBIT_MEMOS_COUNT
              ,TOTAL_CHARGEBACK_VALUE
              ,TOTAL_CHARGEBACK_COUNT
              ,TOTAL_EARNED_DISC_VALUE
              ,TOTAL_EARNED_DISC_COUNT
              ,TOTAL_UNEARNED_DISC_VALUE
              ,TOTAL_UNEARNED_DISC_COUNT
              ,TOTAL_ADJUSTMENTS_VALUE
              ,TOTAL_ADJUSTMENTS_COUNT
              ,TOTAL_DEPOSITS_VALUE
              ,TOTAL_DEPOSITS_COUNT
              ,SUM_APP_AMT_DAYS_LATE
              ,SUM_APP_AMT
              ,COUNT_OF_TOT_INV_INST_PAID
              ,COUNT_OF_INV_INST_PAID_LATE
              ,COUNT_OF_DISC_INV_INST
              ,LARGEST_INV_AMOUNT
              ,LARGEST_INV_DATE
              ,LARGEST_INV_CUST_TRX_ID
              ,DAYS_CREDIT_GRANTED_SUM
              ,NSF_STOP_PAYMENT_COUNT
              ,NSF_STOP_PAYMENT_AMOUNT
         FROM AR_TRX_SUMMARY yt, ra_customer_merges m
         WHERE yt.cust_account_id = m.duplicate_id
           AND DECODE( yt.site_use_id , -99, m.duplicate_site_id,
                yt.site_use_id ) = m.duplicate_site_id
         AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;


BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','AR_TRX_SUMMARY',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY1_LIST
          , PRIMARY_KEY2_LIST
          , PRIMARY_KEY3_LIST
          , PRIMARY_KEY4_LIST
          , PRIMARY_KEY5_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , DEL_OP_BAL_HIGH_WATERMARK
              ,DEL_TOTAL_CASH_RECEIPTS_VALUE
              ,DEL_TOTAL_CASH_RECEIPTS_COUNT
              ,DEL_TOTAL_INVOICES_VALUE
              ,DEL_TOTAL_INVOICES_COUNT
              ,DEL_INV_PAID_AMOUNT
              ,DEL_INV_INST_PMT_DAYS_SUM
              ,DEL_TOTAL_BILLS_REC_VALUE
              ,DEL_TOTAL_BILLS_REC_COUNT
              ,DEL_TOTAL_CREDIT_MEMOS_VALUE
              ,DEL_TOTAL_CREDIT_MEMOS_COUNT
              ,DEL_TOTAL_DEBIT_MEMOS_VALUE
              ,DEL_TOTAL_DEBIT_MEMOS_COUNT
              ,DEL_TOTAL_CHARGEBACK_VALUE
              ,DEL_TOTAL_CHARGEBACK_COUNT
              ,DEL_TOTAL_EARNED_DISC_VALUE
              ,DEL_TOTAL_EARNED_DISC_COUNT
              ,DEL_TOTAL_UNEARNED_DISC_VALUE
              ,DEL_TOTAL_UNEARNED_DISC_COUNT
              ,DEL_TOTAL_ADJUSTMENTS_VALUE
              ,DEL_TOTAL_ADJUSTMENTS_COUNT
              ,DEL_TOTAL_DEPOSITS_VALUE
              ,DEL_TOTAL_DEPOSITS_COUNT
              ,DEL_SUM_APP_AMT_DAYS_LATE
              ,DEL_SUM_APP_AMT
              ,DEL_COUNT_OF_TOT_INV_INST_PAID
              ,DEL_CNT_OF_INV_INST_PAID_LATE
              ,DEL_COUNT_OF_DISC_INV_INST
              ,DEL_LARGEST_INV_AMOUNT
              ,DEL_LARGEST_INV_DATE
              ,DEL_LARGEST_INV_CUST_TRX_ID
              ,DEL_DAYS_CREDIT_GRANTED_SUM
              ,DEL_NSF_STOP_PAYMENT_COUNT
              ,DEL_NSF_STOP_PAYMENT_AMOUNT
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));

      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           PRIMARY_KEY3,
           PRIMARY_KEY4,
           PRIMARY_KEY5,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           DEL_COL1,
           DEL_COL2,
           DEL_COL3,
           DEL_COL4,
           DEL_COL5,
           DEL_COL6,
           DEL_COL7,
           DEL_COL8,
           DEL_COL9,
           DEL_COL10,
           DEL_COL11,
           DEL_COL12,
           DEL_COL13,
           DEL_COL14,
           DEL_COL15,
           DEL_COL16,
           DEL_COL17,
           DEL_COL18,
           DEL_COL19,
           DEL_COL20,
           DEL_COL21,
           DEL_COL22,
           DEL_COL23,
           DEL_COL24,
           DEL_COL25,
           DEL_COL26,
           DEL_COL27,
           DEL_COL28,
           DEL_COL29,
           DEL_COL30,
           DEL_COL31,
           DEL_COL32,
           DEL_COL33,
           DEL_COL34,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'AR_TRX_SUMMARY',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
         PRIMARY_KEY3_LIST(I),
         PRIMARY_KEY4_LIST(I),
         PRIMARY_KEY5_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         'D',
         req_id,
          DEL_OP_BAL_HIGH_WATERMARK(I)
              ,DEL_TOTAL_CASH_RECEIPTS_VALUE(I)
              ,DEL_TOTAL_CASH_RECEIPTS_COUNT(I)
              ,DEL_TOTAL_INVOICES_VALUE(I)
              ,DEL_TOTAL_INVOICES_COUNT(I)
              ,DEL_INV_PAID_AMOUNT(I)
              ,DEL_INV_INST_PMT_DAYS_SUM(I)
              ,DEL_TOTAL_BILLS_REC_VALUE(I)
              ,DEL_TOTAL_BILLS_REC_COUNT(I)
              ,DEL_TOTAL_CREDIT_MEMOS_VALUE(I)
              ,DEL_TOTAL_CREDIT_MEMOS_COUNT(I)
              ,DEL_TOTAL_DEBIT_MEMOS_VALUE(I)
              ,DEL_TOTAL_DEBIT_MEMOS_COUNT(I)
              ,DEL_TOTAL_CHARGEBACK_VALUE(I)
              ,DEL_TOTAL_CHARGEBACK_COUNT(I)
              ,DEL_TOTAL_EARNED_DISC_VALUE(I)
              ,DEL_TOTAL_EARNED_DISC_COUNT(I)
              ,DEL_TOTAL_UNEARNED_DISC_VALUE(I)
              ,DEL_TOTAL_UNEARNED_DISC_COUNT(I)
              ,DEL_TOTAL_ADJUSTMENTS_VALUE(I)
              ,DEL_TOTAL_ADJUSTMENTS_COUNT(I)
              ,DEL_TOTAL_DEPOSITS_VALUE(I)
              ,DEL_TOTAL_DEPOSITS_COUNT(I)
              ,DEL_SUM_APP_AMT_DAYS_LATE(I)
              ,DEL_SUM_APP_AMT(I)
              ,DEL_COUNT_OF_TOT_INV_INST_PAID(I)
              ,DEL_CNT_OF_INV_INST_PAID_LATE(I)
              ,DEL_COUNT_OF_DISC_INV_INST(I)
              ,DEL_LARGEST_INV_AMOUNT(I)
              ,DEL_LARGEST_INV_DATE(I)
              ,DEL_LARGEST_INV_CUST_TRX_ID(I)
              ,DEL_DAYS_CREDIT_GRANTED_SUM(I)
              ,DEL_NSF_STOP_PAYMENT_COUNT(I)
              ,DEL_NSF_STOP_PAYMENT_AMOUNT(I)
         ,hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );
    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
        UPDATE AR_TRX_SUMMARY yt
         SET  ( OP_BAL_HIGH_WATERMARK
              ,TOTAL_CASH_RECEIPTS_VALUE
              ,TOTAL_CASH_RECEIPTS_COUNT
              ,TOTAL_INVOICES_VALUE
              ,TOTAL_INVOICES_COUNT
              ,INV_PAID_AMOUNT
              ,INV_INST_PMT_DAYS_SUM
              ,TOTAL_BILLS_RECEIVABLES_VALUE
              ,TOTAL_BILLS_RECEIVABLES_COUNT
              ,TOTAL_CREDIT_MEMOS_VALUE
              ,TOTAL_CREDIT_MEMOS_COUNT
              ,TOTAL_DEBIT_MEMOS_VALUE
              ,TOTAL_DEBIT_MEMOS_COUNT
              ,TOTAL_CHARGEBACK_VALUE
              ,TOTAL_CHARGEBACK_COUNT
              ,TOTAL_EARNED_DISC_VALUE
              ,TOTAL_EARNED_DISC_COUNT
              ,TOTAL_UNEARNED_DISC_VALUE
              ,TOTAL_UNEARNED_DISC_COUNT
              ,TOTAL_ADJUSTMENTS_VALUE
              ,TOTAL_ADJUSTMENTS_COUNT
              ,TOTAL_DEPOSITS_VALUE
              ,TOTAL_DEPOSITS_COUNT
              ,SUM_APP_AMT_DAYS_LATE
              ,SUM_APP_AMT
              ,COUNT_OF_TOT_INV_INST_PAID
              ,COUNT_OF_INV_INST_PAID_LATE
              ,COUNT_OF_DISC_INV_INST
              ,LARGEST_INV_AMOUNT
              ,LARGEST_INV_DATE
              ,LARGEST_INV_CUST_TRX_ID
              ,DAYS_CREDIT_GRANTED_SUM
              ,NSF_STOP_PAYMENT_COUNT
              ,NSF_STOP_PAYMENT_AMOUNT
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,LAST_UPDATE_LOGIN)	 =
                          ( SELECT  DECODE( yt.OP_BAL_HIGH_WATERMARK, null,
                                            DECODE(yt1.OP_BAL_HIGH_WATERMARK, null, null,
                                            nvl(yt.OP_BAL_HIGH_WATERMARK,0) +
                                            nvl(yt1.OP_BAL_HIGH_WATERMARK,0)),
                                       nvl(yt.OP_BAL_HIGH_WATERMARK,0) +
                                       nvl(yt1.OP_BAL_HIGH_WATERMARK,0)) ,
                                    DECODE( yt.TOTAL_CASH_RECEIPTS_VALUE, null,
                                            DECODE(yt1.TOTAL_CASH_RECEIPTS_VALUE, null, null,
                                            nvl(yt.TOTAL_CASH_RECEIPTS_VALUE,0) +
                                            nvl(yt1.TOTAL_CASH_RECEIPTS_VALUE,0)),
                                       nvl(yt.TOTAL_CASH_RECEIPTS_VALUE,0) +
                                       nvl(yt1.TOTAL_CASH_RECEIPTS_VALUE,0)),
                                    DECODE( yt.TOTAL_CASH_RECEIPTS_COUNT, null,
                                            DECODE(yt1.TOTAL_CASH_RECEIPTS_COUNT, null, null,
                                            nvl(yt.TOTAL_CASH_RECEIPTS_COUNT,0) +
                                            nvl(yt1.TOTAL_CASH_RECEIPTS_COUNT,0)),
                                       nvl(yt.TOTAL_CASH_RECEIPTS_COUNT,0) +
                                       nvl(yt1.TOTAL_CASH_RECEIPTS_COUNT,0)),
                                     DECODE( yt.TOTAL_INVOICES_VALUE, null,
                                            DECODE(yt1.TOTAL_INVOICES_VALUE, null, null,
                                            nvl(yt.TOTAL_INVOICES_VALUE,0) +
                                            nvl(yt1.TOTAL_INVOICES_VALUE,0)),
                                       nvl(yt.TOTAL_INVOICES_VALUE,0) +
                                       nvl(yt1.TOTAL_INVOICES_VALUE,0)),
                                     DECODE( yt.TOTAL_INVOICES_COUNT, null,
                                            DECODE(yt1.TOTAL_INVOICES_COUNT, null, null,
                                            nvl(yt.TOTAL_INVOICES_COUNT,0) +
                                            nvl(yt1.TOTAL_INVOICES_COUNT,0)),
                                       nvl(yt.TOTAL_INVOICES_COUNT,0) +
                                       nvl(yt1.TOTAL_INVOICES_COUNT,0)),
                                     DECODE( yt.INV_PAID_AMOUNT, null,
                                            DECODE(yt1.INV_PAID_AMOUNT, null, null,
                                            nvl(yt.INV_PAID_AMOUNT,0) +
                                            nvl(yt1.INV_PAID_AMOUNT,0)),
                                       nvl(yt.INV_PAID_AMOUNT,0) +
                                       nvl(yt1.INV_PAID_AMOUNT,0)),
                                     DECODE( yt.INV_INST_PMT_DAYS_SUM, null,
                                            DECODE(yt1.INV_INST_PMT_DAYS_SUM, null, null,
                                            nvl(yt.INV_INST_PMT_DAYS_SUM,0) +
                                            nvl(yt1.INV_INST_PMT_DAYS_SUM,0)),
                                       nvl(yt.INV_INST_PMT_DAYS_SUM,0) +
                                       nvl(yt1.INV_INST_PMT_DAYS_SUM,0)),
                                     DECODE( yt.TOTAL_BILLS_RECEIVABLES_VALUE, null,
                                            DECODE(yt1.TOTAL_BILLS_RECEIVABLES_VALUE, null, null,
                                            nvl(yt.TOTAL_BILLS_RECEIVABLES_VALUE,0) +
                                            nvl(yt1.TOTAL_BILLS_RECEIVABLES_VALUE,0)),
                                       nvl(yt.TOTAL_BILLS_RECEIVABLES_VALUE,0) +
                                       nvl(yt1.TOTAL_BILLS_RECEIVABLES_VALUE,0)),
                                     DECODE( yt.TOTAL_BILLS_RECEIVABLES_COUNT, null,
                                            DECODE(yt1.TOTAL_BILLS_RECEIVABLES_COUNT, null, null,
                                            nvl(yt.TOTAL_BILLS_RECEIVABLES_COUNT,0) +
                                            nvl(yt1.TOTAL_BILLS_RECEIVABLES_COUNT,0)),
                                       nvl(yt.TOTAL_BILLS_RECEIVABLES_COUNT,0) +
                                       nvl(yt1.TOTAL_BILLS_RECEIVABLES_COUNT,0)),
                                      DECODE( yt.TOTAL_CREDIT_MEMOS_VALUE, null,
                                            DECODE(yt1.TOTAL_CREDIT_MEMOS_VALUE, null, null,
                                            nvl(yt.TOTAL_CREDIT_MEMOS_VALUE,0) +
                                            nvl(yt1.TOTAL_CREDIT_MEMOS_VALUE,0)),
                                       nvl(yt.TOTAL_CREDIT_MEMOS_VALUE,0) +
                                       nvl(yt1.TOTAL_CREDIT_MEMOS_VALUE,0)),
                                      DECODE( yt.TOTAL_CREDIT_MEMOS_COUNT, null,
                                            DECODE(yt1.TOTAL_CREDIT_MEMOS_COUNT, null, null,
                                            nvl(yt.TOTAL_CREDIT_MEMOS_COUNT,0) +
                                            nvl(yt1.TOTAL_CREDIT_MEMOS_COUNT,0)),
                                       nvl(yt.TOTAL_CREDIT_MEMOS_COUNT,0) +
                                       nvl(yt1.TOTAL_CREDIT_MEMOS_COUNT,0)),
                                      DECODE( yt.TOTAL_DEBIT_MEMOS_VALUE, null,
                                            DECODE(yt1.TOTAL_DEBIT_MEMOS_VALUE, null, null,
                                            nvl(yt.TOTAL_DEBIT_MEMOS_VALUE,0) +
                                            nvl(yt1.TOTAL_DEBIT_MEMOS_VALUE,0)),
                                       nvl(yt.TOTAL_DEBIT_MEMOS_VALUE,0) +
                                       nvl(yt1.TOTAL_DEBIT_MEMOS_VALUE,0)),
                                      DECODE( yt.TOTAL_DEBIT_MEMOS_COUNT, null,
                                            DECODE(yt1.TOTAL_DEBIT_MEMOS_COUNT, null, null,
                                            nvl(yt.TOTAL_DEBIT_MEMOS_COUNT,0) +
                                            nvl(yt1.TOTAL_DEBIT_MEMOS_COUNT,0)),
                                       nvl(yt.TOTAL_DEBIT_MEMOS_COUNT,0) +
                                       nvl(yt1.TOTAL_DEBIT_MEMOS_COUNT,0)),
                                      DECODE( yt.TOTAL_CHARGEBACK_VALUE, null,
                                            DECODE(yt1.TOTAL_CHARGEBACK_VALUE, null, null,
                                            nvl(yt.TOTAL_CHARGEBACK_VALUE,0) +
                                            nvl(yt1.TOTAL_CHARGEBACK_VALUE,0)),
                                       nvl(yt.TOTAL_CHARGEBACK_VALUE,0) +
                                       nvl(yt1.TOTAL_CHARGEBACK_VALUE,0)),
                                      DECODE( yt.TOTAL_CHARGEBACK_COUNT, null,
                                            DECODE(yt1.TOTAL_CHARGEBACK_COUNT, null, null,
                                            nvl(yt.TOTAL_CHARGEBACK_COUNT,0) +
                                            nvl(yt1.TOTAL_CHARGEBACK_COUNT,0)),
                                       nvl(yt.TOTAL_CHARGEBACK_COUNT,0) +
                                       nvl(yt1.TOTAL_CHARGEBACK_COUNT,0)),
                                      DECODE( yt.TOTAL_EARNED_DISC_VALUE, null,
                                            DECODE(yt1.TOTAL_EARNED_DISC_VALUE, null, null,
                                            nvl(yt.TOTAL_EARNED_DISC_VALUE,0) +
                                            nvl(yt1.TOTAL_EARNED_DISC_VALUE,0)),
                                       nvl(yt.TOTAL_EARNED_DISC_VALUE,0) +
                                       nvl(yt1.TOTAL_EARNED_DISC_VALUE,0)),
                                      DECODE( yt.TOTAL_EARNED_DISC_COUNT, null,
                                            DECODE(yt1.TOTAL_EARNED_DISC_COUNT, null, null,
                                            nvl(yt.TOTAL_EARNED_DISC_COUNT,0) +
                                            nvl(yt1.TOTAL_EARNED_DISC_COUNT,0)),
                                       nvl(yt.TOTAL_EARNED_DISC_COUNT,0) +
                                       nvl(yt1.TOTAL_EARNED_DISC_COUNT,0)),
                                      DECODE( yt.TOTAL_UNEARNED_DISC_VALUE, null,
                                            DECODE(yt1.TOTAL_UNEARNED_DISC_VALUE, null, null,
                                            nvl(yt.TOTAL_UNEARNED_DISC_VALUE,0) +
                                            nvl(yt1.TOTAL_UNEARNED_DISC_VALUE,0)),
                                       nvl(yt.TOTAL_UNEARNED_DISC_VALUE,0) +
                                       nvl(yt1.TOTAL_UNEARNED_DISC_VALUE,0)),
                                      DECODE( yt.TOTAL_UNEARNED_DISC_COUNT, null,
                                            DECODE(yt1.TOTAL_UNEARNED_DISC_COUNT, null, null,
                                            nvl(yt.TOTAL_UNEARNED_DISC_COUNT,0) +
                                            nvl(yt1.TOTAL_UNEARNED_DISC_COUNT,0)),
                                       nvl(yt.TOTAL_UNEARNED_DISC_COUNT,0) +
                                       nvl(yt1.TOTAL_UNEARNED_DISC_COUNT,0)),
                                      DECODE( yt.TOTAL_ADJUSTMENTS_VALUE, null,
                                            DECODE(yt1.TOTAL_ADJUSTMENTS_VALUE, null, null,
                                            nvl(yt.TOTAL_ADJUSTMENTS_VALUE,0) +
                                            nvl(yt1.TOTAL_ADJUSTMENTS_VALUE,0)),
                                       nvl(yt.TOTAL_ADJUSTMENTS_VALUE,0) +
                                       nvl(yt1.TOTAL_ADJUSTMENTS_VALUE,0)),
                                      DECODE( yt.TOTAL_ADJUSTMENTS_COUNT, null,
                                            DECODE(yt1.TOTAL_ADJUSTMENTS_COUNT, null, null,
                                            nvl(yt.TOTAL_ADJUSTMENTS_COUNT,0) +
                                            nvl(yt1.TOTAL_ADJUSTMENTS_COUNT,0)),
                                       nvl(yt.TOTAL_ADJUSTMENTS_COUNT,0) +
                                       nvl(yt1.TOTAL_ADJUSTMENTS_COUNT,0)),
                                      DECODE( yt.TOTAL_DEPOSITS_VALUE, null,
                                            DECODE(yt1.TOTAL_DEPOSITS_VALUE, null, null,
                                            nvl(yt.TOTAL_DEPOSITS_VALUE,0) +
                                            nvl(yt1.TOTAL_DEPOSITS_VALUE,0)),
                                       nvl(yt.TOTAL_DEPOSITS_VALUE,0) +
                                       nvl(yt1.TOTAL_DEPOSITS_VALUE,0)),
                                      DECODE( yt.TOTAL_DEPOSITS_COUNT, null,
                                            DECODE(yt1.TOTAL_DEPOSITS_COUNT, null, null,
                                            nvl(yt.TOTAL_DEPOSITS_COUNT,0) +
                                            nvl(yt1.TOTAL_DEPOSITS_COUNT,0)),
                                       nvl(yt.TOTAL_DEPOSITS_COUNT,0) +
                                       nvl(yt1.TOTAL_DEPOSITS_COUNT,0)),
                                      DECODE( yt.SUM_APP_AMT_DAYS_LATE, null,
                                            DECODE(yt1.SUM_APP_AMT_DAYS_LATE, null, null,
                                            nvl(yt.SUM_APP_AMT_DAYS_LATE,0) +
                                            nvl(yt1.SUM_APP_AMT_DAYS_LATE,0)),
                                       nvl(yt.SUM_APP_AMT_DAYS_LATE,0) +
                                       nvl(yt1.SUM_APP_AMT_DAYS_LATE,0)),
                                      DECODE( yt.SUM_APP_AMT, null,
                                            DECODE(yt1.SUM_APP_AMT, null, null,
                                            nvl(yt.SUM_APP_AMT,0) +
                                            nvl(yt1.SUM_APP_AMT,0)),
                                       nvl(yt.SUM_APP_AMT,0) +
                                       nvl(yt1.SUM_APP_AMT,0)),
                                      DECODE( yt.COUNT_OF_TOT_INV_INST_PAID, null,
                                            DECODE(yt1.COUNT_OF_TOT_INV_INST_PAID, null, null,
                                            nvl(yt.COUNT_OF_TOT_INV_INST_PAID,0) +
                                            nvl(yt1.COUNT_OF_TOT_INV_INST_PAID,0)),
                                       nvl(yt.COUNT_OF_TOT_INV_INST_PAID,0) +
                                       nvl(yt1.COUNT_OF_TOT_INV_INST_PAID,0)),
                                      DECODE( yt.COUNT_OF_INV_INST_PAID_LATE, null,
                                            DECODE(yt1.COUNT_OF_INV_INST_PAID_LATE, null, null,
                                            nvl(yt.COUNT_OF_INV_INST_PAID_LATE,0) +
                                            nvl(yt1.COUNT_OF_INV_INST_PAID_LATE,0)),
                                       nvl(yt.COUNT_OF_INV_INST_PAID_LATE,0) +
                                       nvl(yt1.COUNT_OF_INV_INST_PAID_LATE,0)),
                                      DECODE( yt.COUNT_OF_DISC_INV_INST, null,
                                            DECODE(yt1.COUNT_OF_DISC_INV_INST, null, null,
                                            nvl(yt.COUNT_OF_DISC_INV_INST,0) +
                                            nvl(yt1.COUNT_OF_DISC_INV_INST,0)),
                                       nvl(yt.COUNT_OF_DISC_INV_INST,0) +
                                       nvl(yt1.COUNT_OF_DISC_INV_INST,0)),
                                       DECODE(GREATEST(nvl(yt.LARGEST_INV_DATE,yt1.LARGEST_INV_DATE),
                                                       nvl(yt1.LARGEST_INV_DATE, yt.LARGEST_INV_DATE)),
                                                yt.LARGEST_INV_DATE, yt.LARGEST_INV_AMOUNT,
                                                yt1.LARGEST_INV_AMOUNT),
                                       GREATEST(nvl(yt.LARGEST_INV_DATE,yt1.LARGEST_INV_DATE),
                                                       nvl(yt1.LARGEST_INV_DATE, yt.LARGEST_INV_DATE)),
                                       DECODE(GREATEST(nvl(yt.LARGEST_INV_DATE,yt1.LARGEST_INV_DATE),
                                                       nvl(yt1.LARGEST_INV_DATE, yt.LARGEST_INV_DATE)),
                                                yt.LARGEST_INV_DATE, yt.LARGEST_INV_CUST_TRX_ID,
                                                yt1.LARGEST_INV_CUST_TRX_ID),
                                      DECODE( yt.DAYS_CREDIT_GRANTED_SUM, null,
                                          DECODE(yt1.DAYS_CREDIT_GRANTED_SUM, null, null,
                                            nvl(yt.DAYS_CREDIT_GRANTED_SUM,0) +
                                            nvl(yt1.DAYS_CREDIT_GRANTED_SUM,0)),
                                       nvl(yt.DAYS_CREDIT_GRANTED_SUM,0) +
                                       nvl(yt1.DAYS_CREDIT_GRANTED_SUM,0)),
                                       DECODE( yt.NSF_STOP_PAYMENT_COUNT, null,
                                          DECODE(yt1.NSF_STOP_PAYMENT_COUNT, null, null,
                                            nvl(yt.NSF_STOP_PAYMENT_COUNT,0) +
                                            nvl(yt1.NSF_STOP_PAYMENT_COUNT,0)),
                                       nvl(yt.NSF_STOP_PAYMENT_COUNT,0) +
                                       nvl(yt1.NSF_STOP_PAYMENT_COUNT,0)),
                                      DECODE( yt.NSF_STOP_PAYMENT_AMOUNT, null,
                                          DECODE(yt1.NSF_STOP_PAYMENT_AMOUNT, null, null,
                                            nvl(yt.NSF_STOP_PAYMENT_AMOUNT,0) +
                                            nvl(yt1.NSF_STOP_PAYMENT_AMOUNT,0)),
                                       nvl(yt.NSF_STOP_PAYMENT_AMOUNT,0) +
                                       nvl(yt1.NSF_STOP_PAYMENT_AMOUNT,0)),
              	                       sysdate,
                                       FND_GLOBAL.user_id,
                                       FND_GLOBAL.login_id
                            FROM     ar_trx_summary yt1
                            WHERE    yt1.cust_account_id = PRIMARY_KEY1_LIST(I)
                            AND   yt1.SITE_USE_ID=PRIMARY_KEY2_LIST(I)
                            AND   yt1.CURRENCY=PRIMARY_KEY3_LIST(I)
                            AND   yt1.AS_OF_DATE=PRIMARY_KEY4_LIST(I)
                            AND   yt1.ORG_ID=PRIMARY_KEY5_LIST(I)
                            AND   EXISTS ( SELECT 'X'
                                                FROM AR_TRX_SUMMARY yt2
                                                WHERE yt2.CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
                                                AND yt2.SITE_USE_ID=NUM_COL2_NEW_LIST(I)
                                                AND yt2.CURRENCY=PRIMARY_KEY3_LIST(I)
                                                AND yt2.AS_OF_DATE=PRIMARY_KEY4_LIST(I)
                                                AND yt2.ORG_ID=PRIMARY_KEY5_LIST(I) ))
        WHERE  yt.CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
           AND yt.SITE_USE_ID=NUM_COL2_NEW_LIST(I)
           AND yt.CURRENCY=PRIMARY_KEY3_LIST(I)
           AND yt.AS_OF_DATE=PRIMARY_KEY4_LIST(I)
           AND yt.ORG_ID=PRIMARY_KEY5_LIST(I) ;

    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
        DELETE  AR_TRX_SUMMARY yt
            WHERE    yt.cust_account_id = PRIMARY_KEY1_LIST(I)
                    AND   yt.SITE_USE_ID=PRIMARY_KEY2_LIST(I)
                    AND   yt.CURRENCY=PRIMARY_KEY3_LIST(I)
                    AND   yt.AS_OF_DATE=PRIMARY_KEY4_LIST(I)
                    AND   yt.ORG_ID=PRIMARY_KEY5_LIST(I)
                    AND   EXISTS ( SELECT 'X'
                                                FROM AR_TRX_SUMMARY yt2
                                                WHERE yt2.CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
                                                AND yt2.SITE_USE_ID=NUM_COL2_NEW_LIST(I)
                                                AND yt2.CURRENCY=PRIMARY_KEY3_LIST(I)
                                                AND yt2.AS_OF_DATE=PRIMARY_KEY4_LIST(I)
                                                AND yt2.ORG_ID=PRIMARY_KEY5_LIST(I) );


    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE AR_TRX_SUMMARY yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          ,SITE_USE_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE  CUST_ACCOUNT_ID=PRIMARY_KEY1_LIST(I)
        AND SITE_USE_ID=PRIMARY_KEY2_LIST(I)
        AND CURRENCY=PRIMARY_KEY3_LIST(I)
        AND AS_OF_DATE=PRIMARY_KEY4_LIST(I)
        AND ORG_ID=PRIMARY_KEY5_LIST(I) ;


      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'TRX_SUMMARY_ACCOUNT_MERGE');
    RAISE;
END TRX_SUMMARY_ACCOUNT_MERGE;

END AR_CMGT_ACCOUNT_MERGE;

/
