--------------------------------------------------------
--  DDL for Package Body ISC_DBI_ACCT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_ACCT_MERGE_PKG" AS
/* $Header: ISCACMGB.pls 120.1 2006/02/27 17:25:23 scheung noship $ */

PROCEDURE ISC_BOOK_SUM2_PDUE_F_AM (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE LINE_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_PDUE_F.LINE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST LINE_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_PDUE_F.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL0_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE SOLD_TO_ORG_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_PDUE_F.SOLD_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST SOLD_TO_ORG_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST SOLD_TO_ORG_ID_LIST_TYPE;

  TYPE SHIP_TO_ORG_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_PDUE_F.SHIP_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SHIP_TO_ORG_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SHIP_TO_ORG_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  l_new_party_id HZ_CUST_ACCOUNTS.PARTY_ID%TYPE;
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,LINE_ID
              ,SOLD_TO_ORG_ID
              ,SHIP_TO_ORG_ID
         FROM ISC_BOOK_SUM2_PDUE_F yt, ra_customer_merges m
         WHERE (
            yt.SOLD_TO_ORG_ID = m.DUPLICATE_ID
            OR yt.SHIP_TO_ORG_ID = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ISC_BOOK_SUM2_PDUE_F',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
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

	 select party_id into l_new_party_id
	 from hz_cust_accounts
	 where cust_account_id = NUM_COL1_NEW_LIST(I);
	 NUM_COL0_NEW_LIST(I) := l_new_party_id;

      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
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
         'ISC_BOOK_SUM2_PDUE_F',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
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
      UPDATE ISC_BOOK_SUM2_PDUE_F yt SET
           SOLD_TO_ORG_ID=NUM_COL1_NEW_LIST(I)
          ,SHIP_TO_ORG_ID=NUM_COL2_NEW_LIST(I)
	  ,CUSTOMER_ID=NUM_COL0_NEW_LIST(I)
      WHERE LINE_ID=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'ISC_BOOK_SUM2_PDUE_F_AM');
    RAISE;
END ISC_BOOK_SUM2_PDUE_F_AM;

PROCEDURE ISC_BOOK_SUM2_PDUE2_F_AM (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE LINE_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_PDUE2_F.LINE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST LINE_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_PDUE2_F.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL0_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE SOLD_TO_ORG_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_PDUE2_F.SOLD_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST SOLD_TO_ORG_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST SOLD_TO_ORG_ID_LIST_TYPE;

  TYPE SHIP_TO_ORG_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_PDUE2_F.SHIP_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SHIP_TO_ORG_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SHIP_TO_ORG_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  l_new_party_id HZ_CUST_ACCOUNTS.PARTY_ID%TYPE;
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,LINE_ID
              ,SOLD_TO_ORG_ID
              ,SHIP_TO_ORG_ID
         FROM ISC_BOOK_SUM2_PDUE2_F yt, ra_customer_merges m
         WHERE (
            yt.SOLD_TO_ORG_ID = m.DUPLICATE_ID
            OR yt.SHIP_TO_ORG_ID = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ISC_BOOK_SUM2_PDUE2_F',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
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

	 select party_id into l_new_party_id
	 from hz_cust_accounts
	 where cust_account_id = NUM_COL1_NEW_LIST(I);
	 NUM_COL0_NEW_LIST(I) := l_new_party_id;

      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
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
         'ISC_BOOK_SUM2_PDUE2_F',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
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
      UPDATE ISC_BOOK_SUM2_PDUE2_F yt SET
           SOLD_TO_ORG_ID=NUM_COL1_NEW_LIST(I)
          ,SHIP_TO_ORG_ID=NUM_COL2_NEW_LIST(I)
	  ,CUSTOMER_ID=NUM_COL0_NEW_LIST(I)
      WHERE LINE_ID=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'ISC_BOOK_SUM2_PDUE2_F_AM');
    RAISE;
END ISC_BOOK_SUM2_PDUE2_F_AM;

PROCEDURE ISC_BOOK_SUM2_BKORD_F_AM (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE LINE_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_BKORD_F.LINE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST LINE_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_BKORD_F.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL0_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE SOLD_TO_ORG_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_BKORD_F.SOLD_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST SOLD_TO_ORG_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST SOLD_TO_ORG_ID_LIST_TYPE;

  TYPE SHIP_TO_ORG_ID_LIST_TYPE IS TABLE OF
         ISC_BOOK_SUM2_BKORD_F.SHIP_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SHIP_TO_ORG_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SHIP_TO_ORG_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  l_new_party_id HZ_CUST_ACCOUNTS.PARTY_ID%TYPE;
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,LINE_ID
              ,SOLD_TO_ORG_ID
              ,SHIP_TO_ORG_ID
         FROM ISC_BOOK_SUM2_BKORD_F yt, ra_customer_merges m
         WHERE (
            yt.SOLD_TO_ORG_ID = m.DUPLICATE_ID
            OR yt.SHIP_TO_ORG_ID = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ISC_BOOK_SUM2_BKORD_F',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
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

	 select party_id into l_new_party_id
	 from hz_cust_accounts
	 where cust_account_id = NUM_COL1_NEW_LIST(I);
	 NUM_COL0_NEW_LIST(I) := l_new_party_id;

      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
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
         'ISC_BOOK_SUM2_BKORD_F',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
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
      UPDATE ISC_BOOK_SUM2_BKORD_F yt SET
           SOLD_TO_ORG_ID=NUM_COL1_NEW_LIST(I)
          ,SHIP_TO_ORG_ID=NUM_COL2_NEW_LIST(I)
	  ,CUSTOMER_ID=NUM_COL0_NEW_LIST(I)
      WHERE LINE_ID=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'ISC_BOOK_SUM2_BKORD_F_AM');
    RAISE;
END ISC_BOOK_SUM2_BKORD_F_AM;


END  ISC_DBI_ACCT_MERGE_PKG;

/
