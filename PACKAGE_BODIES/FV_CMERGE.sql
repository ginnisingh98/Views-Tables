--------------------------------------------------------
--  DDL for Package Body FV_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_CMERGE" AS
-- $Header: FVARCMGB.pls 120.10 2004/05/06 18:03:05 manumand ship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_CMERGE.';

 PROCEDURE FV_CUST_FINANCE_CHRGS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);


 PROCEDURE FV_CUST_VEND_XREFS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

 PROCEDURE FV_INTERAGENCY_FUNDS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

 PROCEDURE FV_INTERIM_CASH_RECEIPTS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

 PROCEDURE FV_INVOICE_FINANCE_CHRGS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

 PROCEDURE FV_IPAC_TRX (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);



------------------------------------------------------------------------------
-- Merge Routine for FV_CUST_FINANCE_CHRGS table
------------------------------------------------------------------------------
PROCEDURE FV_CUST_FINANCE_CHRGS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'FV_CUST_FINANCE_CHRGS';
  l_errbuf      VARCHAR2(1024);

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         FV_CUST_FINANCE_CHRGS_ALL.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CHARGE_ID_LIST_TYPE IS TABLE OF
         FV_CUST_FINANCE_CHRGS_ALL.CHARGE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY2_LIST CHARGE_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE1 IS TABLE OF
         FV_CUST_FINANCE_CHRGS_ALL.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE1;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE1;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,yt.CUSTOMER_ID
              ,yt.CHARGE_ID
              ,yt.CUSTOMER_ID
         FROM FV_CUST_FINANCE_CHRGS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FV_CUST_FINANCE_CHRGS',FALSE);
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;

    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    --remove records from table that will be duplicates when merged.
    delete from fv_cust_finance_chrgs
                where (customer_id, charge_id) in
                                (select duplicate_id, charge_id
                                   from ra_customer_merges racm,
                                        fv_cust_finance_chrgs fcfc
                                     where  racm.process_flag = 'N'
                                       and racm.request_id = req_id
                                       and racm.set_number = set_num
                             and racm.customer_id = fcfc.customer_id
                             and fcfc.charge_id in
                                (select charge_id
                                   from fv_cust_finance_chrgs
                                  where customer_id = racm.duplicate_id));

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY1_LIST
          , PRIMARY_KEY2_LIST
          , NUM_COL1_ORIG_LIST
          limit 1000
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'FV_CUST_FINANCE_CHRGS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FV_CUST_FINANCE_CHRGS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE CUSTOMER_ID=PRIMARY_KEY1_LIST(I)
      AND CHARGE_ID=PRIMARY_KEY2_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception', l_errbuf);
    arp_message.set_line( 'FV_CUST_FINANCE_CHRGS');
    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
    END IF;
    RAISE;
END FV_CUST_FINANCE_CHRGS;

------------------------------------------------------------------------------
-- Merge Routine for FV_CUST_VEND_XREFS table
-----------------------------------------------------------------------------

PROCEDURE FV_CUST_VEND_XREFS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'FV_CUST_VEND_XREFS';
  l_errbuf      VARCHAR2(1024);

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CUST_VEND_XREF_ID_LIST_TYPE IS TABLE OF
        FV.FV_CUST_VEND_XREFS.CUST_VEND_XREF_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST CUST_VEND_XREF_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         FV.FV_CUST_VEND_XREFS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,CUST_VEND_XREF_ID
              ,yt.CUSTOMER_ID
         FROM FV_CUST_VEND_XREFS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
  g_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FV_CUST_VEND_XREFS',FALSE);
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    -- remove the records that will be duplicates when merged.
    delete from fv_cust_vend_xrefs
                 where customer_id IN (select  duplicate_id
                                        from ra_customer_merges racm,
                                             fv_cust_vend_xrefs t
                                      where  racm.process_flag = 'N'
                                        and racm.request_id =  req_id
                                        and racm.set_number = set_num
                                        and racm.customer_id = t.customer_id);

     g_count := SQL%ROWCOUNT;

    arp_message.set_name('AR','AR_ROWS_DELETED');
    arp_message.set_token('NUM_ROWS',to_char(g_count));
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          limit 1000
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
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
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'FV_CUST_VEND_XREFS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FV_CUST_VEND_XREFS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE CUST_VEND_XREF_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception', l_errbuf);
    arp_message.set_line( 'FV_CUST_VEND_XREFS');
    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
    END IF;
    RAISE;
END FV_CUST_VEND_XREFS;

------------------------------------------------------------------------------
-- Merge Routine for FV_INTERAGENCY_FUNDS table
------------------------------------------------------------------------------

PROCEDURE FV_INTERAGENCY_FUNDS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'FV_INTERAGENCY_FUNDS';
  l_errbuf      VARCHAR2(1024);

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE INTERAGENCY_FUND_ID_LIST_TYPE IS TABLE OF
         FV_INTERAGENCY_FUNDS_ALL.INTERAGENCY_FUND_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST INTERAGENCY_FUND_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         FV_INTERAGENCY_FUNDS_ALL.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,INTERAGENCY_FUND_ID
              ,yt.CUSTOMER_ID
         FROM FV_INTERAGENCY_FUNDS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FV_INTERAGENCY_FUNDS',FALSE);
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          limit 1000
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
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
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'FV_INTERAGENCY_FUNDS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FV_INTERAGENCY_FUNDS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE INTERAGENCY_FUND_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception', l_errbuf);
    arp_message.set_line( 'FV_INTERAGENCY_FUNDS');
    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
    END IF;
    RAISE;
END FV_INTERAGENCY_FUNDS;
------------------------------------------------------------------------------
-- Merge Routine for FV_INTERIM_CASH_RECEIPTS table
------------------------------------------------------------------------------
PROCEDURE FV_INTERIM_CASH_RECEIPTS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'FV_INTERIM_CASH_RECEIPTS';
  l_errbuf      VARCHAR2(1024);

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE BATCH_ID_LIST_TYPE IS TABLE OF
        FV_INTERIM_CASH_RECEIPTS_ALL.BATCH_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST BATCH_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         FV_INTERIM_CASH_RECEIPTS_ALL.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY2_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CUSTOMER_TRX_ID_LIST_TYPE IS TABLE OF
         FV_INTERIM_CASH_RECEIPTS_ALL.CUSTOMER_TRX_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY3_LIST CUSTOMER_TRX_ID_LIST_TYPE;

  TYPE RECEIPT_NUMBER_LIST_TYPE IS TABLE OF
         FV_INTERIM_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY4_LIST RECEIPT_NUMBER_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE1 IS TABLE OF
         FV_INTERIM_CASH_RECEIPTS_ALL.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE1;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE1;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
         FV_INTERIM_CASH_RECEIPTS_ALL.SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,BATCH_ID
              ,yt.CUSTOMER_ID
              ,CUSTOMER_TRX_ID
              ,RECEIPT_NUMBER
              ,yt.CUSTOMER_ID
              ,yt.SITE_USE_ID
         FROM FV_INTERIM_CASH_RECEIPTS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
            OR yt.SITE_USE_ID = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FV_INTERIM_CASH_RECEIPTS',FALSE);
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
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
          limit 1000
          ;
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
         'FV_INTERIM_CASH_RECEIPTS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
         PRIMARY_KEY3_LIST(I),
         PRIMARY_KEY4_LIST(I),
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
      UPDATE FV_INTERIM_CASH_RECEIPTS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          ,SITE_USE_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE BATCH_ID=PRIMARY_KEY1_LIST(I)
      AND CUSTOMER_ID=PRIMARY_KEY2_LIST(I)
      AND CUSTOMER_TRX_ID=PRIMARY_KEY3_LIST(I)
      AND RECEIPT_NUMBER=PRIMARY_KEY4_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception', l_errbuf);
    arp_message.set_line( 'FV_INTERIM_CASH_RECEIPTS');
    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
    END IF;
    RAISE;
END FV_INTERIM_CASH_RECEIPTS;

------------------------------------------------------------------------------
-- Merge Routine for FV_INVOICE_FINANCE_CHRGS table
-----------------------------------------------------------------------------

PROCEDURE FV_INVOICE_FINANCE_CHRGS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'FV_INVOICE_FINANCE_CHRGS';
  l_errbuf      VARCHAR2(1024);

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CUSTOMER_TRX_ID_LIST_TYPE IS TABLE OF
         FV_INVOICE_FINANCE_CHRGS_ALL.CUSTOMER_TRX_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST CUSTOMER_TRX_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         FV_INVOICE_FINANCE_CHRGS_ALL.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY2_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CHARGE_ID_LIST_TYPE IS TABLE OF
         FV_INVOICE_FINANCE_CHRGS_ALL.CHARGE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY3_LIST CHARGE_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE1 IS TABLE OF
         FV_INVOICE_FINANCE_CHRGS_ALL.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE1;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE1;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,CUSTOMER_TRX_ID
              ,yt.CUSTOMER_ID
              ,CHARGE_ID
              ,yt.CUSTOMER_ID
         FROM FV_INVOICE_FINANCE_CHRGS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FV_INVOICE_FINANCE_CHRGS',FALSE);
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY1_LIST
          , PRIMARY_KEY2_LIST
          , PRIMARY_KEY3_LIST
          , NUM_COL1_ORIG_LIST
          limit 1000
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
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
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'FV_INVOICE_FINANCE_CHRGS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
         PRIMARY_KEY3_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FV_INVOICE_FINANCE_CHRGS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE CUSTOMER_TRX_ID=PRIMARY_KEY1_LIST(I)
      AND CUSTOMER_ID=PRIMARY_KEY2_LIST(I)
      AND CHARGE_ID=PRIMARY_KEY3_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception', l_errbuf);
    arp_message.set_line( 'FV_INVOICE_FINANCE_CHRGS');
    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
    END IF;
    RAISE;
END FV_INVOICE_FINANCE_CHRGS;

------------------------------------------------------------------------------
-- Merge Routine for FV_IPAC_TRX table
-----------------------------------------------------------------------------


PROCEDURE FV_IPAC_TRX (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'FV_IPAC_TRX';
  l_errbuf      VARCHAR2(1024);

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE IPAC_BILLING_ID_LIST_TYPE IS TABLE OF
         FV_IPAC_TRX_ALL.IPAC_BILLING_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST IPAC_BILLING_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         FV_IPAC_TRX_ALL.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,IPAC_BILLING_ID
              ,yt.CUSTOMER_ID
         FROM FV_IPAC_TRX yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FV_IPAC_TRX',FALSE);
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY1_LIST
          , NUM_COL1_ORIG_LIST
          limit 1000
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'FV_IPAC_TRX',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FV_IPAC_TRX yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE IPAC_BILLING_ID=PRIMARY_KEY1_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
    IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_EVENT, l_module_name);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception', l_errbuf);
    arp_message.set_line( 'FV_IPAC_TRX');
    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
    END IF;
    RAISE;
END FV_IPAC_TRX;

PROCEDURE merge(req_id IN Number,
                 set_num IN NUMBER,
                 process_mode IN VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'merge';
  l_errbuf      VARCHAR2(1024);

BEGIN
 FV_CUST_FINANCE_CHRGS(req_id, set_num, process_mode);
 FV_CUST_VEND_XREFS(req_id, set_num, process_mode);
 FV_INTERAGENCY_FUNDS(req_id, set_num, process_mode);
 FV_INTERIM_CASH_RECEIPTS(req_id, set_num, process_mode);
 FV_INVOICE_FINANCE_CHRGS(req_id, set_num, process_mode);
 FV_IPAC_TRX(req_id, set_num, process_mode);
EXCEPTION WHEN OTHERS THEN
  l_errbuf := SQLERRM;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.final_exception', l_errbuf);
  RAISE;
END merge;

END fv_cmerge;

/
