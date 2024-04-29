--------------------------------------------------------
--  DDL for Package Body ARP_CMERGE_ARTRX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CMERGE_ARTRX" as
/* $Header: ARPLTRXB.pls 120.15.12010000.3 2009/12/10 12:35:02 rvelidi ship $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count		NUMBER := 0;


/*--------------------------- PRIVATE ROUTINES ------------------------------*/

PROCEDURE ar_cr (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE cash_receipt_id_LIST_TYPE IS TABLE OF
         AR_CASH_RECEIPTS.cash_receipt_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST cash_receipt_id_LIST_TYPE;

  TYPE pay_from_customer_LIST_TYPE IS TABLE OF
         AR_CASH_RECEIPTS.pay_from_customer%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST pay_from_customer_LIST_TYPE;
  NUM_COL1_NEW_LIST pay_from_customer_LIST_TYPE;

  TYPE customer_site_use_id_LIST_TYPE IS TABLE OF
         AR_CASH_RECEIPTS.customer_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST customer_site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST customer_site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,cash_receipt_id
              ,pay_from_customer
              ,customer_site_use_id
         FROM AR_CASH_RECEIPTS yt, ra_customer_merges m
         WHERE (   (yt.pay_from_customer = m.DUPLICATE_ID AND
                    nvl(yt.customer_site_use_id,m.DUPLICATE_SITE_ID) = m.DUPLICATE_SITE_ID))
         AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','AR_CASH_RECEIPTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
            LIMIT ARP_CMERGE.max_array_size;/*Additional changes for 2447449*/
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
         'AR_CASH_RECEIPTS',
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
      UPDATE AR_CASH_RECEIPTS yt SET
           pay_from_customer=NUM_COL1_NEW_LIST(I)
          ,customer_site_use_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE cash_receipt_id=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'ar_cr');
    RAISE;
END ar_cr;

PROCEDURE ar_ps (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE payment_schedule_id_LIST_TYPE IS TABLE OF
         AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST payment_schedule_id_LIST_TYPE;

  TYPE customer_id_LIST_TYPE IS TABLE OF
         AR_PAYMENT_SCHEDULES.customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST customer_id_LIST_TYPE;

  TYPE customer_site_use_id_LIST_TYPE IS TABLE OF
         AR_PAYMENT_SCHEDULES.customer_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST customer_site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST customer_site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,payment_schedule_id
              ,yt.customer_id
              ,customer_site_use_id
         FROM AR_PAYMENT_SCHEDULES yt, ra_customer_merges m
         WHERE ( yt.customer_id = m.DUPLICATE_ID AND
                 nvl(yt.customer_site_use_id, m.DUPLICATE_SITE_ID) = m.DUPLICATE_SITE_ID)
         AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','AR_PAYMENT_SCHEDULES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
            LIMIT ARP_CMERGE.max_array_size;/*Additional changes for 2447449*/
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
         'AR_PAYMENT_SCHEDULES',
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
      UPDATE AR_PAYMENT_SCHEDULES yt SET
           customer_id=NUM_COL1_NEW_LIST(I)
          ,customer_site_use_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE payment_schedule_id=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'ar_ps');
    RAISE;
END ar_ps;


PROCEDURE ra_ct (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE customer_trx_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX.customer_trx_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST customer_trx_id_LIST_TYPE;

  TYPE bill_to_customer_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX.bill_to_customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST bill_to_customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST bill_to_customer_id_LIST_TYPE;

  TYPE bill_to_site_use_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX.bill_to_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST bill_to_site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST bill_to_site_use_id_LIST_TYPE;

  TYPE paying_customer_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX.paying_customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST paying_customer_id_LIST_TYPE;
  NUM_COL3_NEW_LIST paying_customer_id_LIST_TYPE;

  TYPE paying_site_use_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX.paying_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST paying_site_use_id_LIST_TYPE;
  NUM_COL4_NEW_LIST paying_site_use_id_LIST_TYPE;

  TYPE ship_to_customer_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX.ship_to_customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL5_ORIG_LIST ship_to_customer_id_LIST_TYPE;
  NUM_COL5_NEW_LIST ship_to_customer_id_LIST_TYPE;

  TYPE ship_to_site_use_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX.ship_to_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL6_ORIG_LIST ship_to_site_use_id_LIST_TYPE;
  NUM_COL6_NEW_LIST ship_to_site_use_id_LIST_TYPE;

  TYPE sold_to_customer_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX.sold_to_customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL7_ORIG_LIST sold_to_customer_id_LIST_TYPE;
  NUM_COL7_NEW_LIST sold_to_customer_id_LIST_TYPE;

  TYPE sold_to_site_use_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX.sold_to_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL8_ORIG_LIST sold_to_site_use_id_LIST_TYPE;
  NUM_COL8_NEW_LIST sold_to_site_use_id_LIST_TYPE;
  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,customer_trx_id
              ,bill_to_customer_id
              ,bill_to_site_use_id
              ,paying_customer_id
              ,paying_site_use_id
              ,ship_to_customer_id
              ,ship_to_site_use_id
              ,sold_to_customer_id
              ,sold_to_site_use_id
         FROM RA_CUSTOMER_TRX yt, ra_customer_merges m
         WHERE (    (yt.bill_to_customer_id = m.DUPLICATE_ID AND
                     yt.bill_to_site_use_id = m.DUPLICATE_SITE_ID)
                 OR (yt.paying_customer_id = m.DUPLICATE_ID AND
                     yt.paying_site_use_id = m.DUPLICATE_SITE_ID)
                 OR (yt.ship_to_customer_id = m.DUPLICATE_ID AND
                     nvl(yt.ship_to_site_use_id,m.DUPLICATE_SITE_ID) = m.DUPLICATE_SITE_ID)
                 OR (yt.sold_to_customer_id = m.DUPLICATE_ID AND
                     nvl(yt.sold_to_site_use_id,m.DUPLICATE_SITE_ID) = m.DUPLICATE_SITE_ID))
         AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','RA_CUSTOMER_TRX',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
          , NUM_COL4_ORIG_LIST
          , NUM_COL5_ORIG_LIST
          , NUM_COL6_ORIG_LIST
          , NUM_COL7_ORIG_LIST
          , NUM_COL8_ORIG_LIST
            LIMIT ARP_CMERGE.max_array_size;/*Additional changes for 2447449*/
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL3_ORIG_LIST(I));
         NUM_COL4_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL4_ORIG_LIST(I));
         NUM_COL5_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL5_ORIG_LIST(I));
         NUM_COL6_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL6_ORIG_LIST(I));
         NUM_COL7_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL7_ORIG_LIST(I));
         NUM_COL8_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL8_ORIG_LIST(I));
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
           NUM_COL3_ORIG,
           NUM_COL3_NEW,
           NUM_COL4_ORIG,
           NUM_COL4_NEW,
           NUM_COL5_ORIG,
           NUM_COL5_NEW,
           NUM_COL6_ORIG,
           NUM_COL6_NEW,
           NUM_COL7_ORIG,
           NUM_COL7_NEW,
           NUM_COL8_ORIG,
           NUM_COL8_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'RA_CUSTOMER_TRX',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
         NUM_COL4_ORIG_LIST(I),
         NUM_COL4_NEW_LIST(I),
         NUM_COL5_ORIG_LIST(I),
         NUM_COL5_NEW_LIST(I),
         NUM_COL6_ORIG_LIST(I),
         NUM_COL6_NEW_LIST(I),
         NUM_COL7_ORIG_LIST(I),
         NUM_COL7_NEW_LIST(I),
         NUM_COL8_ORIG_LIST(I),
         NUM_COL8_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );
    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE RA_CUSTOMER_TRX yt SET
           bill_to_customer_id=NUM_COL1_NEW_LIST(I)
          ,bill_to_site_use_id=NUM_COL2_NEW_LIST(I)
          ,paying_customer_id=NUM_COL3_NEW_LIST(I)
          ,paying_site_use_id=NUM_COL4_NEW_LIST(I)
          ,ship_to_customer_id=NUM_COL5_NEW_LIST(I)
          ,ship_to_site_use_id=NUM_COL6_NEW_LIST(I)
          ,sold_to_customer_id=NUM_COL7_NEW_LIST(I)
          ,sold_to_site_use_id=NUM_COL8_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE customer_trx_id=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'ra_ct');
    RAISE;
END ra_ct;

-- bug9095566

PROCEDURE ra_ctl (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE customer_trx_line_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX_LINES.customer_trx_line_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST customer_trx_line_id_LIST_TYPE;

  TYPE ship_to_customer_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX_LINES.ship_to_customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST ship_to_customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST ship_to_customer_id_LIST_TYPE;

  TYPE ship_to_site_use_id_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_TRX_LINES.ship_to_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ship_to_site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST ship_to_site_use_id_LIST_TYPE;


  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,customer_trx_line_id
              ,ship_to_customer_id
              ,ship_to_site_use_id

         FROM RA_CUSTOMER_TRX_LINES yt , ra_customer_merges m
         WHERE
                 yt.ship_to_customer_id = m.DUPLICATE_ID AND
                 nvl(yt.ship_to_site_use_id,m.DUPLICATE_SITE_ID) = m.DUPLICATE_SITE_ID

         AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','RA_CUSTOMER_TRX_LINES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST

            LIMIT ARP_CMERGE.max_array_size;/*Additional changes for 2447449*/
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
         'RA_CUSTOMER_TRX_LINES',
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
      UPDATE RA_CUSTOMER_TRX_LINES yt SET

          ship_to_customer_id=NUM_COL1_NEW_LIST(I)
          ,ship_to_site_use_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE customer_trx_line_id=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'ra_ctl');
    RAISE;
END ra_ctl;

PROCEDURE RA_INT (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ROWID_LIST_TYPE IS TABLE OF
                VARCHAR2(25)
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST ROWID_LIST_TYPE;

  TYPE ORIG_BILL_CUST_ID_LIST_TYPE IS TABLE OF
         RA_INTERFACE_LINES.ORIG_SYSTEM_BILL_CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST ORIG_BILL_CUST_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST ORIG_BILL_CUST_ID_LIST_TYPE;

  TYPE ORIG_SHIP_CUST_ID_LIST_TYPE IS TABLE OF
         RA_INTERFACE_LINES.ORIG_SYSTEM_SHIP_CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ORIG_SHIP_CUST_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST ORIG_SHIP_CUST_ID_LIST_TYPE;

  TYPE ORIG_SOLD_CUST_ID_LIST_TYPE IS TABLE OF
         RA_INTERFACE_LINES.ORIG_SYSTEM_SOLD_CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST ORIG_SOLD_CUST_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST ORIG_SOLD_CUST_ID_LIST_TYPE;

  TYPE ORIG_BILL_ADD_ID_LIST_TYPE IS TABLE OF
         RA_INTERFACE_LINES.ORIG_SYSTEM_BILL_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST ORIG_BILL_ADD_ID_LIST_TYPE;
  NUM_COL4_NEW_LIST ORIG_BILL_ADD_ID_LIST_TYPE;

  TYPE ORIG_SHIP_ADD_ID_LIST_TYPE IS TABLE OF
         RA_INTERFACE_LINES.ORIG_SYSTEM_SHIP_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL5_ORIG_LIST ORIG_SHIP_ADD_ID_LIST_TYPE;
  NUM_COL5_NEW_LIST ORIG_SHIP_ADD_ID_LIST_TYPE;

  TYPE ORIG_BILL_CUST_REF_LIST_TYPE IS TABLE OF
         RA_INTERFACE_LINES.ORIG_SYSTEM_BILL_CUSTOMER_REF%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL1_ORIG_LIST ORIG_BILL_CUST_REF_LIST_TYPE;
  VCHAR_COL1_NEW_LIST ORIG_BILL_CUST_REF_LIST_TYPE;

  TYPE ORIG_SHIP_CUST_REF_LIST_TYPE IS TABLE OF
         RA_INTERFACE_LINES.ORIG_SYSTEM_SHIP_CUSTOMER_REF%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL2_ORIG_LIST ORIG_SHIP_CUST_REF_LIST_TYPE;
  VCHAR_COL2_NEW_LIST ORIG_SHIP_CUST_REF_LIST_TYPE;

  TYPE ORIG_SOLD_CUST_REF_LIST_TYPE IS TABLE OF
         RA_INTERFACE_LINES.ORIG_SYSTEM_SOLD_CUSTOMER_REF%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL3_ORIG_LIST ORIG_SOLD_CUST_REF_LIST_TYPE;
  VCHAR_COL3_NEW_LIST ORIG_SOLD_CUST_REF_LIST_TYPE;

  TYPE ORIG_BILL_ADD_REF_LIST_TYPE IS TABLE OF
         RA_INTERFACE_LINES.ORIG_SYSTEM_BILL_ADDRESS_REF%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL4_ORIG_LIST ORIG_BILL_ADD_REF_LIST_TYPE;
  VCHAR_COL4_NEW_LIST ORIG_BILL_ADD_REF_LIST_TYPE;

  TYPE ORIG_SHIP_ADD_REF_LIST_TYPE IS TABLE OF
         RA_INTERFACE_LINES.ORIG_SYSTEM_SHIP_ADDRESS_REF%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL5_ORIG_LIST ORIG_SHIP_ADD_REF_LIST_TYPE;
  VCHAR_COL5_NEW_LIST ORIG_SHIP_ADD_REF_LIST_TYPE;

/* Bug3500125 : Added following table type and added CUSTOMER_REF to CURSOR merged_records*/

TYPE CUSTOMER_REF_LIST_TYPE IS TABLE OF
         RA_CUSTOMER_MERGES.CUSTOMER_REF%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL6_ORIG_LIST CUSTOMER_REF_LIST_TYPE;
  VCHAR_COL6_NEW_LIST CUSTOMER_REF_LIST_TYPE;

/*Additional change for ra_interface_lines under bug2447449*/
/* bug3667197: Modified the where clause of cursor merged_records to avoid
               FTS on table ra_customer_merges */
/* bug4075234: Replaced 'exists' clause in CURSOR merged_records with 'IN' for performance
               improvement */
 l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,rai.ROWID
              ,ORIG_SYSTEM_BILL_CUSTOMER_ID
              ,ORIG_SYSTEM_SHIP_CUSTOMER_ID
              ,ORIG_SYSTEM_SOLD_CUSTOMER_ID
              ,ORIG_SYSTEM_BILL_ADDRESS_ID
              ,ORIG_SYSTEM_SHIP_ADDRESS_ID
              ,ORIG_SYSTEM_BILL_CUSTOMER_REF
              ,ORIG_SYSTEM_SHIP_CUSTOMER_REF
              ,ORIG_SYSTEM_SOLD_CUSTOMER_REF
              ,ORIG_SYSTEM_BILL_ADDRESS_REF
              ,ORIG_SYSTEM_SHIP_ADDRESS_REF
              ,m.CUSTOMER_REF
        from  ra_interface_lines rai,
              ra_customer_merges m
        where  nvl(rai.interface_status,'N') <> 'P'  /* bug 1611619 : check interface_status */
        and   (
                 m.duplicate_id = rai.orig_system_bill_customer_id
                 or (m.duplicate_ref = rai.orig_system_bill_customer_ref)
                 or (m.duplicate_address_id = rai.orig_system_bill_address_id)
                 or (m.duplicate_id = rai.orig_system_ship_customer_id)
                 or (m.duplicate_ref = rai.orig_system_ship_customer_ref)
                 or (m.duplicate_address_id = rai.orig_system_ship_address_id)
                 or (m.duplicate_id = rai.orig_system_sold_customer_id)
                 or (m.duplicate_ref = rai.orig_system_sold_customer_ref)
                 or (rai.orig_system_bill_address_ref IN ( select
                                                          ra.orig_system_reference
                                                          from  hz_cust_acct_sites ra
                                                           where m.duplicate_address_id  = ra.cust_acct_site_id)
                    )
                 or (rai.orig_system_ship_address_ref IN (select
                                                          ra.orig_system_reference
                                                          from  hz_cust_acct_sites ra
                                                          where m.duplicate_address_id  = ra.cust_acct_site_id)
                    )
               )
         and   m.process_flag = 'N'
         and   m.request_id   = req_id
         and   m.set_number   = set_num ;


  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;


  BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','RA_INTERFACE_LINES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
/*Additional change for ra_interface_lines under bug2447449*/
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');
    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY1_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
          , NUM_COL4_ORIG_LIST
          , NUM_COL5_ORIG_LIST
          , VCHAR_COL1_ORIG_LIST
          , VCHAR_COL2_ORIG_LIST
          , VCHAR_COL3_ORIG_LIST
          , VCHAR_COL4_ORIG_LIST
          , VCHAR_COL5_ORIG_LIST
          , VCHAR_COL6_NEW_LIST
            LIMIT ARP_CMERGE.max_array_size;/*Additional changes for 2447449*/
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP

         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL3_ORIG_LIST(I));
         NUM_COL4_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL4_ORIG_LIST(I));
         NUM_COL5_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL5_ORIG_LIST(I));

/* Bug3500125:Modified code to assign values to original references with new reference values*/
         IF VCHAR_COL1_ORIG_LIST(I) IS NOT NULL THEN
               VCHAR_COL1_NEW_LIST(I) := VCHAR_COL6_NEW_LIST(I);
         ELSE
               VCHAR_COL1_NEW_LIST(I) := NULL;
         END IF;

         IF VCHAR_COL2_ORIG_LIST(I) IS NOT NULL THEN
               VCHAR_COL2_NEW_LIST(I) := VCHAR_COL6_NEW_LIST(I);
         ELSE
               VCHAR_COL2_NEW_LIST(I) := NULL;
         END IF;

         IF VCHAR_COL3_ORIG_LIST(I) IS NOT NULL THEN
               VCHAR_COL3_NEW_LIST(I) := VCHAR_COL6_NEW_LIST(I);
         ELSE
               VCHAR_COL3_NEW_LIST(I) := NULL;
         END IF;

         IF VCHAR_COL4_ORIG_LIST(I) IS NOT NULL THEN
               VCHAR_COL4_NEW_LIST(I) := VCHAR_COL6_NEW_LIST(I);
         ELSE
               VCHAR_COL4_NEW_LIST(I) := NULL;
         END IF;

         IF VCHAR_COL5_ORIG_LIST(I) IS NOT NULL THEN
               VCHAR_COL5_NEW_LIST(I) := VCHAR_COL6_NEW_LIST(I);
         ELSE
               VCHAR_COL5_NEW_LIST(I) := NULL;
         END IF;

      END LOOP;

/*Additional change for ra_interface_lines under bug2447449*/
 IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           NUM_COL3_ORIG,
           NUM_COL3_NEW,
           NUM_COL4_ORIG,
           NUM_COL4_NEW,
           NUM_COL5_ORIG,
           NUM_COL5_NEW,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           VCHAR_COL3_ORIG,
           VCHAR_COL3_NEW,
           VCHAR_COL4_ORIG,
           VCHAR_COL4_NEW,
           VCHAR_COL5_ORIG,
           VCHAR_COL5_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'RA_INTERFACE_LINES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
         NUM_COL4_ORIG_LIST(I),
         NUM_COL4_NEW_LIST(I),
         NUM_COL5_ORIG_LIST(I),
         NUM_COL5_NEW_LIST(I),
         VCHAR_COL1_ORIG_LIST(I),
         VCHAR_COL1_NEW_LIST(I),
         VCHAR_COL2_ORIG_LIST(I),
         VCHAR_COL2_NEW_LIST(I),
         VCHAR_COL3_ORIG_LIST(I),
         VCHAR_COL3_NEW_LIST(I),
         VCHAR_COL4_ORIG_LIST(I),
         VCHAR_COL4_NEW_LIST(I),
         VCHAR_COL5_ORIG_LIST(I),
         VCHAR_COL5_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

     END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE RA_INTERFACE_LINES yt SET
           ORIG_SYSTEM_BILL_CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          ,ORIG_SYSTEM_SHIP_CUSTOMER_ID=NUM_COL2_NEW_LIST(I)
          ,ORIG_SYSTEM_SOLD_CUSTOMER_ID=NUM_COL3_NEW_LIST(I)
          ,ORIG_SYSTEM_BILL_ADDRESS_ID=NUM_COL4_NEW_LIST(I)
          ,ORIG_SYSTEM_SHIP_ADDRESS_ID=NUM_COL5_NEW_LIST(I)
          ,ORIG_SYSTEM_BILL_CUSTOMER_REF=VCHAR_COL1_NEW_LIST(I)
          ,ORIG_SYSTEM_SHIP_CUSTOMER_REF=VCHAR_COL2_NEW_LIST(I)
          ,ORIG_SYSTEM_SOLD_CUSTOMER_REF=VCHAR_COL3_NEW_LIST(I)
          ,ORIG_SYSTEM_BILL_ADDRESS_REF=VCHAR_COL4_NEW_LIST(I)
          ,ORIG_SYSTEM_SHIP_ADDRESS_REF=VCHAR_COL5_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE ROWID=PRIMARY_KEY1_LIST(I)
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
    arp_message.set_line( 'RA_INT');
    RAISE;
END RA_INT;

PROCEDURE ar_ard (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE line_id_LIST_TYPE IS TABLE OF
         AR_DISTRIBUTIONS.line_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST line_id_LIST_TYPE;

  TYPE third_party_id_LIST_TYPE IS TABLE OF
         AR_DISTRIBUTIONS.third_party_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST third_party_id_LIST_TYPE;
  NUM_COL1_NEW_LIST third_party_id_LIST_TYPE;

  TYPE third_party_sub_id_LIST_TYPE IS TABLE OF
         AR_DISTRIBUTIONS.third_party_sub_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST third_party_sub_id_LIST_TYPE;
  NUM_COL2_NEW_LIST third_party_sub_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,line_id
              ,third_party_id
              ,third_party_sub_id
         FROM AR_DISTRIBUTIONS yt, ra_customer_merges m
         WHERE (   (yt.third_party_id = m.DUPLICATE_ID AND
                    nvl(yt.third_party_sub_id,m.DUPLICATE_SITE_ID) = m.DUPLICATE_SITE_ID))
         AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','AR_DISTRIBUTIONS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
            LIMIT ARP_CMERGE.max_array_size;/*Additional changes for 2447449*/
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
         'AR_DISTRIBUTIONS',
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
      UPDATE AR_DISTRIBUTIONS yt SET
           third_party_id=NUM_COL1_NEW_LIST(I)
          ,third_party_sub_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE line_id=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'ar_ard');
    RAISE;
END ar_ard;


/*---------------------------- PUBLIC ROUTINES ------------------------------*/
PROCEDURE merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
BEGIN

  arp_message.set_line( 'ARP_CMERGE_ARTRX.MERGE()+' );

  ar_cr( req_id, set_num, process_mode );
  ar_ps( req_id, set_num, process_mode );
  ra_ct( req_id, set_num, process_mode );
  ra_ctl ( req_id, set_num, process_mode );
  ra_int(req_id, set_num, process_mode );
  ar_ard(req_id, set_num, process_mode );

  arp_message.set_line( 'ARP_CMERGE_ARTRX.MERGE()-' );

EXCEPTION
  when others then
    raise;

END merge;

END ARP_CMERGE_ARTRX;

/
