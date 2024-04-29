--------------------------------------------------------
--  DDL for Package Body XDP_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_PARTY_MERGE" AS
/* $Header: XDPMERGB.pls 120.3 2006/04/10 23:21:02 dputhiye noship $ */

-- PL/SQL Specification

PROCEDURE account_merge( request_id NUMBER,
		     set_number NUMBER,
	             process_mode VARCHAR2 )
IS
l_request_id NUMBER:= request_id;

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ORDER_ID_LIST_TYPE IS TABLE OF
         XDP_ORDER_HEADERS.ORDER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ORDER_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         XDP_ORDER_HEADERS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ORDER_ID
              ,CUST_ACCOUNT_ID
         FROM XDP_ORDER_HEADERS yt, ra_customer_merges m
         WHERE (
            yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = request_id
         AND    m.set_number = set_number;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;

  TYPE LINE_ITEM_ID_LIST_TYPE IS TABLE OF
         XDP_ORDER_LINE_ITEMS.LINE_ITEM_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST1 LINE_ITEM_ID_LIST_TYPE;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
         XDP_ORDER_LINE_ITEMS.SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST1 SITE_USE_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST1 SITE_USE_ID_LIST_TYPE;

  CURSOR merged_records1 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,LINE_ITEM_ID
              ,SITE_USE_ID
         FROM XDP_ORDER_LINE_ITEMS yt, ra_customer_merges m
         WHERE (
            yt.SITE_USE_ID = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = request_id
         AND    m.set_number = set_number;


BEGIN

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','XDP_ORDER_HEADERS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_number, request_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          limit 1000;
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
         'XDP_ORDER_HEADERS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         request_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
      FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE XDP_ORDER_HEADERS yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
--          , REQUEST_ID=request_id
--          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
--          , PROGRAM_ID=arp_standard.profile.program_id
--          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ORDER_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','XDP_ORDER_LINE_ITEMS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_number, request_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records1;
    LOOP
      FETCH merged_records1 BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST1
          , NUM_COL1_ORIG_LIST1
          limit 1000;
      IF merged_records1%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST1(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST1(I));
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
         'XDP_ORDER_LINE_ITEMS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST1(I),
         NUM_COL1_ORIG_LIST1(I),
         NUM_COL1_NEW_LIST1(I),
         'U',
         request_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
      FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE XDP_ORDER_LINE_ITEMS yt SET
           SITE_USE_ID=NUM_COL1_NEW_LIST1(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
--          , REQUEST_ID=request_id
--          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
--          , PROGRAM_ID=arp_standard.profile.program_id
--          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE LINE_ITEM_ID=PRIMARY_KEY_ID_LIST1(I)
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
    /* Report the error in the log table and reraise the exception */
    /* The exception MUST be reraised */
    arp_message.set_error('CRM_MERGE.XDP_PARTY_MERGE');
    raise;

END account_merge;

END XDP_PARTY_MERGE;

/
