--------------------------------------------------------
--  DDL for Package Body MRPP_CMERGE_FCST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRPP_CMERGE_FCST" as
		/* $Header: MRPPMGFB.pls 120.0 2005/05/25 03:55:15 appldev noship $ */

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

/*-------------------------------------------------------------
|
|  PROCEDURE
|      MRP_FD
|  DESCRIPTION :
|      Account merge procedure for the table, MRP_FORECAST_DATES
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE MRP_FD (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE TRANSACTION_ID_LIST_TYPE IS TABLE OF
         MRP_FORECAST_DATES.TRANSACTION_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST TRANSACTION_ID_LIST_TYPE;

  TYPE customer_id_LIST_TYPE IS TABLE OF
         MRP_FORECAST_DATES.customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST customer_id_LIST_TYPE;

  TYPE ship_id_LIST_TYPE IS TABLE OF
         MRP_FORECAST_DATES.ship_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ship_id_LIST_TYPE;
  NUM_COL2_NEW_LIST ship_id_LIST_TYPE;

  TYPE bill_id_LIST_TYPE IS TABLE OF
         MRP_FORECAST_DATES.bill_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST bill_id_LIST_TYPE;
  NUM_COL3_NEW_LIST bill_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
              ,yt.TRANSACTION_ID
              ,yt.customer_id
              ,yt.ship_id
              ,yt.bill_id
         FROM MRP_FORECAST_DATES yt, ra_customer_merges m
         WHERE (
            yt.customer_id = m.DUPLICATE_ID
            OR yt.ship_id = m.DUPLICATE_SITE_ID
            OR yt.bill_id = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    yt.origination_type = '10' /* Overconsumption */
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','MRP_FORECAST_DATES',FALSE);
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
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
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
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'MRP_FORECAST_DATES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
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
      UPDATE MRP_FORECAST_DATES yt SET
           customer_id=NUM_COL1_NEW_LIST(I)
          ,ship_id=NUM_COL2_NEW_LIST(I)
          ,bill_id=NUM_COL3_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE TRANSACTION_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'MRP_FD');
    RAISE;
END MRP_FD;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      MRP_FDE
|  DESCRIPTION :
|      Account merge procedure for the table, MRP_FORECAST_DESIGNATORS
|
|  NOTES:
|--------------------------------------------------------------*/

PROCEDURE MRP_FDE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ORGANIZATION_ID_LIST_TYPE IS TABLE OF
         MRP_FORECAST_DESIGNATORS.ORGANIZATION_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST ORGANIZATION_ID_LIST_TYPE;

  TYPE FORECAST_DESIGNATOR_LIST_TYPE IS TABLE OF
         MRP_FORECAST_DESIGNATORS.FORECAST_DESIGNATOR%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY2_LIST FORECAST_DESIGNATOR_LIST_TYPE;

  TYPE customer_id_LIST_TYPE IS TABLE OF
         MRP_FORECAST_DESIGNATORS.customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST customer_id_LIST_TYPE;

  TYPE ship_id_LIST_TYPE IS TABLE OF
         MRP_FORECAST_DESIGNATORS.ship_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ship_id_LIST_TYPE;
  NUM_COL2_NEW_LIST ship_id_LIST_TYPE;

  TYPE bill_id_LIST_TYPE IS TABLE OF
         MRP_FORECAST_DESIGNATORS.bill_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST bill_id_LIST_TYPE;
  NUM_COL3_NEW_LIST bill_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
              ,yt.ORGANIZATION_ID
              ,yt.FORECAST_DESIGNATOR
              ,yt.customer_id
              ,yt.ship_id
              ,yt.bill_id
         FROM MRP_FORECAST_DESIGNATORS yt, ra_customer_merges m
         WHERE (
            yt.customer_id = m.DUPLICATE_ID
            OR yt.ship_id = m.DUPLICATE_SITE_ID
            OR yt.bill_id = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','MRP_FORECAST_DESIGNATORS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY1_LIST
          , PRIMARY_KEY2_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
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
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
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
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           NUM_COL3_ORIG,
           NUM_COL3_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'MRP_FORECAST_DESIGNATORS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
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
      UPDATE MRP_FORECAST_DESIGNATORS yt SET
           customer_id=NUM_COL1_NEW_LIST(I)
          ,ship_id=NUM_COL2_NEW_LIST(I)
          ,bill_id=NUM_COL3_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ORGANIZATION_ID=PRIMARY_KEY1_LIST(I)
      AND FORECAST_DESIGNATOR=PRIMARY_KEY2_LIST(I)
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
    arp_message.set_line( 'MRP_FDE');
    RAISE;
END MRP_FDE;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      MRP_FU
|  DESCRIPTION :
|      Account merge procedure for the table, MRP_FORECAST_UPDATES
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE MRP_FU (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE TRANSACTION_ID_LIST_TYPE IS TABLE OF
         MRP_FORECAST_UPDATES.TRANSACTION_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST TRANSACTION_ID_LIST_TYPE;

  TYPE customer_id_LIST_TYPE IS TABLE OF
         MRP_FORECAST_UPDATES.customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST customer_id_LIST_TYPE;

  TYPE ship_id_LIST_TYPE IS TABLE OF
         MRP_FORECAST_UPDATES.ship_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ship_id_LIST_TYPE;
  NUM_COL2_NEW_LIST ship_id_LIST_TYPE;

  TYPE bill_id_LIST_TYPE IS TABLE OF
         MRP_FORECAST_UPDATES.bill_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST bill_id_LIST_TYPE;
  NUM_COL3_NEW_LIST bill_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
              ,yt.TRANSACTION_ID
              ,yt.customer_id
              ,yt.ship_id
              ,yt.bill_id
         FROM MRP_FORECAST_UPDATES yt, ra_customer_merges m
         WHERE (
            yt.customer_id = m.DUPLICATE_ID
            OR yt.ship_id = m.DUPLICATE_SITE_ID
            OR yt.bill_id = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','MRP_FORECAST_UPDATES',FALSE);
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
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
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
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'MRP_FORECAST_UPDATES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
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
      UPDATE MRP_FORECAST_UPDATES yt SET
           customer_id=NUM_COL1_NEW_LIST(I)
          ,ship_id=NUM_COL2_NEW_LIST(I)
          ,bill_id=NUM_COL3_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE TRANSACTION_ID=PRIMARY_KEY_ID_LIST(I)
      AND   CUSTOMER_ID=NUM_COL1_ORIG_LIST(I)
      AND   NVL(SHIP_ID,-23453)=NVL(NUM_COL2_ORIG_LIST(I),-23453)
      AND   NVL(BILL_ID,-23453)=NVL(NUM_COL3_ORIG_LIST(I),-23453)
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
    arp_message.set_line( 'MRP_FU');
    RAISE;
END MRP_FU;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      MRP_SOU
|  DESCRIPTION :
|      Account merge procedure for the table, MRP_SALES_ORDER_UPDATES
|
|
|--------------------------------------------------------------*/

PROCEDURE MRP_SOU (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE UPDATE_SEQ_NUM_LIST_TYPE IS TABLE OF
         MRP_SALES_ORDER_UPDATES.UPDATE_SEQ_NUM%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST UPDATE_SEQ_NUM_LIST_TYPE;

  TYPE current_customer_id_LIST_TYPE IS TABLE OF
         MRP_SALES_ORDER_UPDATES.current_customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST current_customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST current_customer_id_LIST_TYPE;

  TYPE current_ship_id_LIST_TYPE IS TABLE OF
         MRP_SALES_ORDER_UPDATES.current_ship_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST current_ship_id_LIST_TYPE;
  NUM_COL2_NEW_LIST current_ship_id_LIST_TYPE;

  TYPE current_bill_id_LIST_TYPE IS TABLE OF
         MRP_SALES_ORDER_UPDATES.current_bill_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST current_bill_id_LIST_TYPE;
  NUM_COL3_NEW_LIST current_bill_id_LIST_TYPE;

  TYPE previous_customer_id_LIST_TYPE IS TABLE OF
         MRP_SALES_ORDER_UPDATES.previous_customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST previous_customer_id_LIST_TYPE;
  NUM_COL4_NEW_LIST previous_customer_id_LIST_TYPE;

  TYPE previous_bill_id_LIST_TYPE IS TABLE OF
         MRP_SALES_ORDER_UPDATES.previous_bill_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL5_ORIG_LIST previous_bill_id_LIST_TYPE;
  NUM_COL5_NEW_LIST previous_bill_id_LIST_TYPE;

  TYPE previous_ship_id_LIST_TYPE IS TABLE OF
         MRP_SALES_ORDER_UPDATES.previous_ship_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL6_ORIG_LIST previous_ship_id_LIST_TYPE;
  NUM_COL6_NEW_LIST previous_ship_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,UPDATE_SEQ_NUM
              ,current_customer_id
              ,current_ship_id
              ,current_bill_id
              ,previous_customer_id
              ,previous_bill_id
              ,previous_ship_id
         FROM MRP_SALES_ORDER_UPDATES yt, ra_customer_merges m
         WHERE (
            yt.current_customer_id = m.DUPLICATE_ID
            OR yt.current_ship_id = m.DUPLICATE_SITE_ID
            OR yt.current_bill_id = m.DUPLICATE_SITE_ID
            OR yt.previous_customer_id = m.DUPLICATE_ID
            OR yt.previous_bill_id = m.DUPLICATE_SITE_ID
            OR yt.previous_ship_id = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','MRP_SALES_ORDER_UPDATES',FALSE);
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
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
         NUM_COL4_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL4_ORIG_LIST(I));
         NUM_COL5_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL5_ORIG_LIST(I));
         NUM_COL6_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL6_ORIG_LIST(I));
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
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'MRP_SALES_ORDER_UPDATES',
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
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE MRP_SALES_ORDER_UPDATES yt SET
           current_customer_id=NUM_COL1_NEW_LIST(I)
          ,current_ship_id=NUM_COL2_NEW_LIST(I)
          ,current_bill_id=NUM_COL3_NEW_LIST(I)
          ,previous_customer_id=NUM_COL4_NEW_LIST(I)
          ,previous_bill_id=NUM_COL5_NEW_LIST(I)
          ,previous_ship_id=NUM_COL6_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE UPDATE_SEQ_NUM=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'MRP_SOU');
    RAISE;
END MRP_SOU;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      MRP_SA
|  DESCRIPTION :
|      Account merge procedure for the table, MRP_SR_ASSIGNMENTS
|
|  NOTES:
|--------------------------------------------------------------*/

PROCEDURE MRP_SA (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ASSIGNMENT_ID_LIST_TYPE IS TABLE OF
         MRP_SR_ASSIGNMENTS.ASSIGNMENT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ASSIGNMENT_ID_LIST_TYPE;

  TYPE customer_id_LIST_TYPE IS TABLE OF
         MRP_SR_ASSIGNMENTS.customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST customer_id_LIST_TYPE;

  TYPE ship_to_site_id_LIST_TYPE IS TABLE OF
         MRP_SR_ASSIGNMENTS.ship_to_site_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ship_to_site_id_LIST_TYPE;
  NUM_COL2_NEW_LIST ship_to_site_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
              ,yt.ASSIGNMENT_ID
              ,yt.customer_id
              ,yt.ship_to_site_id
         FROM MRP_SR_ASSIGNMENTS yt, ra_customer_merges m
         WHERE (
            yt.customer_id = m.DUPLICATE_ID
            OR yt.ship_to_site_id = m.DUPLICATE_SITE_ID
         ) AND yt.assignment_type in (4,5,6)
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','MRP_SR_ASSIGNMENTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
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
         'MRP_SR_ASSIGNMENTS',
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
      UPDATE MRP_SR_ASSIGNMENTS yt SET
           customer_id=NUM_COL1_NEW_LIST(I)
          ,ship_to_site_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ASSIGNMENT_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'MRP_SA');
    RAISE;
END MRP_SA;


/*---------------------------- PUBLIC ROUTINES ------------------------------*/

PROCEDURE MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
BEGIN

  arp_message.set_line( 'MRPP_CMERGE_FCST.MERGE()+' );

  MRP_FD( req_id, set_num, process_mode );
  MRP_FDE( req_id, set_num, process_mode );
  MRP_FU( req_id, set_num, process_mode );
  MRP_SOU( req_id, set_num, process_mode);
  MRP_SA( req_id, set_num, process_mode); /* Bug 1848916 */

  arp_message.set_line( 'MRPP_CMERGE_FCST.MERGE()-' );

END MERGE;

end MRPP_CMERGE_FCST;

/
