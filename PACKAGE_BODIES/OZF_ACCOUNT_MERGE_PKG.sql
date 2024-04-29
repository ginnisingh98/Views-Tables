--------------------------------------------------------
--  DDL for Package Body OZF_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACCOUNT_MERGE_PKG" AS
/* $Header: ozfvcmrb.pls 115.6 2004/05/07 05:23:06 samaresh ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OZF_ACCOUNT_MERGE_PKG';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'ozfvcmrb.pls';
------------------------------------------------------------------------------

/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_acct_alloc
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_account_allocations
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_acct_alloc (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE account_alloc_id_LIST_TYPE IS TABLE OF
         ozf_account_allocations.account_allocation_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST account_alloc_id_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         ozf_account_allocations.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE bill_to_site_use_id_LIST_TYPE IS TABLE OF
         ozf_account_allocations.bill_to_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST bill_to_site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST bill_to_site_use_id_LIST_TYPE;

  TYPE site_use_id_LIST_TYPE IS TABLE OF
         ozf_account_allocations.site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST site_use_id_LIST_TYPE;
  NUM_COL3_NEW_LIST site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,account_allocation_id
              ,cust_account_id
              ,bill_to_site_use_id
              ,site_use_id
         FROM ozf_account_allocations yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.DUPLICATE_ADDRESS_ID
            OR yt.bill_to_site_use_id = m.DUPLICATE_SITE_ID
            OR yt.site_use_id = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_account_allocations',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL1_ORIG_LIST(I));

         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
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
         'ozf_account_allocations',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
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

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE ozf_account_allocations yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          ,bill_to_site_use_id=NUM_COL2_NEW_LIST(I)
          ,site_use_id=NUM_COL3_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE account_allocation_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_acct_alloc');
    RAISE;
END merge_acct_alloc;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_claim_lines
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_claim_lines
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_claim_lines (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE claim_line_id_LIST_TYPE IS TABLE OF
         ozf_claim_lines.claim_line_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST claim_line_id_LIST_TYPE;

  TYPE rel_cust_account_id_LIST_TYPE IS TABLE OF
         ozf_claim_lines.related_cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST rel_cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST rel_cust_account_id_LIST_TYPE;

  TYPE buy_grp_cust_acct_id_LIST_TYPE IS TABLE OF
         ozf_claim_lines.buy_group_cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST buy_grp_cust_acct_id_LIST_TYPE;
  NUM_COL2_NEW_LIST buy_grp_cust_acct_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,claim_line_id
              ,related_cust_account_id
              ,buy_group_cust_account_id
         FROM ozf_claim_lines yt, ra_customer_merges m
         WHERE (
            yt.related_cust_account_id = m.DUPLICATE_ID
            OR yt.buy_group_cust_account_id = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_claim_lines',FALSE);
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
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
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
         'ozf_claim_lines',
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
      UPDATE ozf_claim_lines yt SET
           related_cust_account_id=NUM_COL1_NEW_LIST(I)
          ,buy_group_cust_account_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE claim_line_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_claim_lines');
    RAISE;
END merge_claim_lines;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_claim_lines_hist
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_claim_lines_hist
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_claim_lines_hist (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE claim_line_hist_id_LIST_TYPE IS TABLE OF
         ozf_claim_lines_hist.claim_line_history_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST claim_line_hist_id_LIST_TYPE;

  TYPE rel_cust_account_id_LIST_TYPE IS TABLE OF
         ozf_claim_lines_hist.related_cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST rel_cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST rel_cust_account_id_LIST_TYPE;

  TYPE buy_grp_cust_acct_id_LIST_TYPE IS TABLE OF
         ozf_claim_lines_hist.buy_group_cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST buy_grp_cust_acct_id_LIST_TYPE;
  NUM_COL2_NEW_LIST buy_grp_cust_acct_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,claim_line_history_id
              ,related_cust_account_id
              ,buy_group_cust_account_id
         FROM ozf_claim_lines_hist yt, ra_customer_merges m
         WHERE (
            yt.related_cust_account_id = m.DUPLICATE_ID
            OR yt.buy_group_cust_account_id = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_claim_lines_hist',FALSE);
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
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
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
         'ozf_claim_lines_hist',
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
      UPDATE ozf_claim_lines_hist yt SET
           related_cust_account_id=NUM_COL1_NEW_LIST(I)
          ,buy_group_cust_account_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE claim_line_history_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_claim_lines_hist');
    RAISE;
END merge_claim_lines_hist;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_claims
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_claims
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_claims (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE claim_id_LIST_TYPE IS TABLE OF
         ozf_claims.claim_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST claim_id_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         ozf_claims.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE ship_to_cust_acct_id_LIST_TYPE IS TABLE OF
         ozf_claims.ship_to_cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ship_to_cust_acct_id_LIST_TYPE;
  NUM_COL2_NEW_LIST ship_to_cust_acct_id_LIST_TYPE;

  TYPE cb_acct_site_id_LIST_TYPE IS TABLE OF
         ozf_claims.cust_billto_acct_site_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST cb_acct_site_id_LIST_TYPE;
  NUM_COL3_NEW_LIST cb_acct_site_id_LIST_TYPE;

  TYPE cs_acct_site_id_LIST_TYPE IS TABLE OF
         ozf_claims.cust_shipto_acct_site_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST cs_acct_site_id_LIST_TYPE;
  NUM_COL4_NEW_LIST cs_acct_site_id_LIST_TYPE;

  TYPE rel_cust_account_id_LIST_TYPE IS TABLE OF
         ozf_claims.related_cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL5_ORIG_LIST rel_cust_account_id_LIST_TYPE;
  NUM_COL5_NEW_LIST rel_cust_account_id_LIST_TYPE;

  TYPE related_site_use_id_LIST_TYPE IS TABLE OF
         ozf_claims.related_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL6_ORIG_LIST related_site_use_id_LIST_TYPE;
  NUM_COL6_NEW_LIST related_site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,claim_id
              ,cust_account_id
              ,ship_to_cust_account_id
              ,cust_billto_acct_site_id
              ,cust_shipto_acct_site_id
              ,related_cust_account_id
              ,related_site_use_id
         FROM ozf_claims yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.DUPLICATE_ID
            OR yt.ship_to_cust_account_id = m.DUPLICATE_ID
            OR yt.cust_billto_acct_site_id = m.DUPLICATE_SITE_ID
            OR yt.cust_shipto_acct_site_id = m.DUPLICATE_SITE_ID
            OR yt.related_cust_account_id = m.DUPLICATE_ID
            OR yt.related_site_use_id = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_claims',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
          , NUM_COL4_ORIG_LIST
          , NUM_COL5_ORIG_LIST
          , NUM_COL6_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
         NUM_COL4_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL4_ORIG_LIST(I));
         NUM_COL5_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL5_ORIG_LIST(I));
         NUM_COL6_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL6_ORIG_LIST(I));
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
         'ozf_claims',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
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
      UPDATE ozf_claims yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          ,ship_to_cust_account_id=NUM_COL2_NEW_LIST(I)
          ,cust_billto_acct_site_id=NUM_COL3_NEW_LIST(I)
          ,cust_shipto_acct_site_id=NUM_COL4_NEW_LIST(I)
          ,related_cust_account_id=NUM_COL5_NEW_LIST(I)
          ,related_site_use_id=NUM_COL6_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE claim_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_claims');
    RAISE;
END merge_claims;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_claims_history
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_claims_history
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_claims_history (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE claim_history_id_LIST_TYPE IS TABLE OF
         ozf_claims_history.claim_history_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST claim_history_id_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         ozf_claims_history.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE ship_to_cust_acct_id_LIST_TYPE IS TABLE OF
         ozf_claims_history.ship_to_cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ship_to_cust_acct_id_LIST_TYPE;
  NUM_COL2_NEW_LIST ship_to_cust_acct_id_LIST_TYPE;

  TYPE cb_acct_site_id_LIST_TYPE IS TABLE OF
         ozf_claims_history.cust_billto_acct_site_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST cb_acct_site_id_LIST_TYPE;
  NUM_COL3_NEW_LIST cb_acct_site_id_LIST_TYPE;

  TYPE cs_acct_site_id_LIST_TYPE IS TABLE OF
         ozf_claims_history.cust_shipto_acct_site_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST cs_acct_site_id_LIST_TYPE;
  NUM_COL4_NEW_LIST cs_acct_site_id_LIST_TYPE;

  TYPE rel_cust_account_id_LIST_TYPE IS TABLE OF
         ozf_claims_history.related_cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL5_ORIG_LIST rel_cust_account_id_LIST_TYPE;
  NUM_COL5_NEW_LIST rel_cust_account_id_LIST_TYPE;

  TYPE related_site_use_id_LIST_TYPE IS TABLE OF
         ozf_claims_history.related_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL6_ORIG_LIST related_site_use_id_LIST_TYPE;
  NUM_COL6_NEW_LIST related_site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,claim_history_id
              ,cust_account_id
              ,ship_to_cust_account_id
              ,cust_billto_acct_site_id
              ,cust_shipto_acct_site_id
              ,related_cust_account_id
              ,related_site_use_id
         FROM ozf_claims_history yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.DUPLICATE_ID
            OR yt.ship_to_cust_account_id = m.DUPLICATE_ID
            OR yt.cust_billto_acct_site_id = m.DUPLICATE_SITE_ID
            OR yt.cust_shipto_acct_site_id = m.DUPLICATE_SITE_ID
            OR yt.related_cust_account_id = m.DUPLICATE_ID
            OR yt.related_site_use_id = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_claims_history',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
          , NUM_COL4_ORIG_LIST
          , NUM_COL5_ORIG_LIST
          , NUM_COL6_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
         NUM_COL4_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL4_ORIG_LIST(I));
         NUM_COL5_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL5_ORIG_LIST(I));
         NUM_COL6_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL6_ORIG_LIST(I));
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
         'ozf_claims_history',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
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
      UPDATE ozf_claims_history yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          ,ship_to_cust_account_id=NUM_COL2_NEW_LIST(I)
          ,cust_billto_acct_site_id=NUM_COL3_NEW_LIST(I)
          ,cust_shipto_acct_site_id=NUM_COL4_NEW_LIST(I)
          ,related_cust_account_id=NUM_COL5_NEW_LIST(I)
          ,related_site_use_id=NUM_COL6_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE claim_history_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_claims_history');
    RAISE;
END merge_claims_history;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_code_conversions
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_code_conversions
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_code_conversions (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE code_conversion_id_LIST_TYPE IS TABLE OF
         ozf_code_conversions.code_conversion_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST code_conversion_id_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         ozf_code_conversions.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,code_conversion_id
              ,cust_account_id
         FROM ozf_code_conversions yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_code_conversions',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
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
           PRIMARY_KEY_ID1,
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
         'ozf_code_conversions',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
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
      UPDATE ozf_code_conversions yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE code_conversion_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_code_conversions');
    RAISE;
END merge_code_conversions;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_cust_daily_facts
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_cust_daily_facts
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_cust_daily_facts (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE cust_daily_fact_id_LIST_TYPE IS TABLE OF
         ozf_cust_daily_facts.cust_daily_fact_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST cust_daily_fact_id_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         ozf_cust_daily_facts.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE bill_to_site_use_id_LIST_TYPE IS TABLE OF
         ozf_cust_daily_facts.bill_to_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST bill_to_site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST bill_to_site_use_id_LIST_TYPE;

  TYPE ship_to_site_use_id_LIST_TYPE IS TABLE OF
         ozf_cust_daily_facts.ship_to_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST ship_to_site_use_id_LIST_TYPE;
  NUM_COL3_NEW_LIST ship_to_site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,cust_daily_fact_id
              ,cust_account_id
              ,bill_to_site_use_id
              ,ship_to_site_use_id
         FROM ozf_cust_daily_facts yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.DUPLICATE_ADDRESS_ID
            OR yt.bill_to_site_use_id = m.DUPLICATE_SITE_ID
            OR yt.ship_to_site_use_id = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_cust_daily_facts',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL1_ORIG_LIST(I));

         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
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
         'ozf_cust_daily_facts',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
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

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE ozf_cust_daily_facts yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          ,bill_to_site_use_id=NUM_COL2_NEW_LIST(I)
          ,ship_to_site_use_id=NUM_COL3_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE cust_daily_fact_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_cust_daily_facts');
    RAISE;
END merge_cust_daily_facts;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_fund_utilization
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_funds_utilized_all_b
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_fund_utilization (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE utilization_id_LIST_TYPE IS TABLE OF
         ozf_funds_utilized_all_b.utilization_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST utilization_id_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         ozf_funds_utilized_all_b.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE bc_account_id_LIST_TYPE IS TABLE OF
         ozf_funds_utilized_all_b.billto_cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST bc_account_id_LIST_TYPE;
  NUM_COL2_NEW_LIST bc_account_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,utilization_id
              ,cust_account_id
              ,billto_cust_account_id
         FROM ozf_funds_utilized_all_b yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.DUPLICATE_ID
            OR yt.billto_cust_account_id = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_funds_utilized_all_b',FALSE);
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
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
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
         'ozf_funds_utilized_all_b',
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
      UPDATE ozf_funds_utilized_all_b yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          ,billto_cust_account_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE utilization_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_fund_utilization');
    RAISE;
END merge_fund_utilization;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_offer_denorm
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_activity_customers
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_offer_denorm (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE object_class_LIST_TYPE IS TABLE OF
         ozf_activity_customers.object_class%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST object_class_LIST_TYPE;

  TYPE object_id_LIST_TYPE IS TABLE OF
         ozf_activity_customers.object_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY2_LIST object_id_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         ozf_activity_customers.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE site_use_id_LIST_TYPE IS TABLE OF
         ozf_activity_customers.site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,object_class
              ,object_id
              ,cust_account_id
              ,site_use_id
         FROM ozf_activity_customers yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.DUPLICATE_ADDRESS_ID
            OR yt.site_use_id = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_activity_customers',FALSE);
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
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL1_ORIG_LIST(I));

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
         'ozf_activity_customers',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
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
      UPDATE ozf_activity_customers yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          ,site_use_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE object_class=PRIMARY_KEY1_LIST(I)
      AND object_id=PRIMARY_KEY2_LIST(I)
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
    arp_message.set_line( 'merge_offer_denorm');
    RAISE;
END merge_offer_denorm;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_offer_header
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_offers
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_offer_header (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE qp_list_header_id_LIST_TYPE IS TABLE OF
         ozf_offers.qp_list_header_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST qp_list_header_id_LIST_TYPE;

  TYPE ben_account_id_LIST_TYPE IS TABLE OF
         ozf_offers.beneficiary_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST ben_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST ben_account_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,qp_list_header_id
              ,beneficiary_account_id
         FROM ozf_offers yt, ra_customer_merges m
         WHERE (
            yt.beneficiary_account_id = m.DUPLICATE_ADDRESS_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_offers',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL1_ORIG_LIST(I));

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
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'ozf_offers',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
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
      UPDATE ozf_offers yt SET
           beneficiary_account_id=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE qp_list_header_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_offer_header');
    RAISE;
END merge_offer_header;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_request_header
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_request_headers_all_b
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_request_header (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE request_header_id_LIST_TYPE IS TABLE OF
         ozf_request_headers_all_b.request_header_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST request_header_id_LIST_TYPE;

  TYPE reseller_site_use_id_LIST_TYPE IS TABLE OF
         ozf_request_headers_all_b.reseller_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST reseller_site_use_id_LIST_TYPE;
  NUM_COL1_NEW_LIST reseller_site_use_id_LIST_TYPE;

  TYPE end_cust_site_use_id_LIST_TYPE IS TABLE OF
         ozf_request_headers_all_b.end_cust_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST end_cust_site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST end_cust_site_use_id_LIST_TYPE;

  TYPE partner_site_use_id_LIST_TYPE IS TABLE OF
         ozf_request_headers_all_b.partner_site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST partner_site_use_id_LIST_TYPE;
  NUM_COL3_NEW_LIST partner_site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,request_header_id
              ,reseller_site_use_id
              ,end_cust_site_use_id
              ,partner_site_use_id
         FROM ozf_request_headers_all_b yt, ra_customer_merges m
         WHERE (
            yt.reseller_site_use_id = m.DUPLICATE_SITE_ID
            OR yt.end_cust_site_use_id = m.DUPLICATE_SITE_ID
            OR yt.partner_site_use_id = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_request_headers_all_b',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
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
         'ozf_request_headers_all_b',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
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

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE ozf_request_headers_all_b yt SET
           reseller_site_use_id=NUM_COL1_NEW_LIST(I)
          ,end_cust_site_use_id=NUM_COL2_NEW_LIST(I)
          ,partner_site_use_id=NUM_COL3_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE request_header_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_request_header');
    RAISE;
END merge_request_header;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_retail_price_points
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_retail_price_points
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_retail_price_points (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE rp_point_id_LIST_TYPE IS TABLE OF
         ozf_retail_price_points.retail_price_point_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST rp_point_id_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         ozf_retail_price_points.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE site_use_id_LIST_TYPE IS TABLE OF
         ozf_retail_price_points.site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,retail_price_point_id
              ,cust_account_id
              ,site_use_id
         FROM ozf_retail_price_points yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.DUPLICATE_ADDRESS_ID
            OR yt.site_use_id = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_retail_price_points',FALSE);
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
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL1_ORIG_LIST(I));

         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
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
         'ozf_retail_price_points',
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
      UPDATE ozf_retail_price_points yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          ,site_use_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE retail_price_point_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_retail_price_points');
    RAISE;
END merge_retail_price_points;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_trade_profiles
|  DESCRIPTION :
|      Account merge procedure for the table, ozf_cust_trd_prfls
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_trade_profiles (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE trade_profile_id_LIST_TYPE IS TABLE OF
         ozf_cust_trd_prfls.trade_profile_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST trade_profile_id_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         ozf_cust_trd_prfls.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE cust_acct_site_id_LIST_TYPE IS TABLE OF
         ozf_cust_trd_prfls.cust_acct_site_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST cust_acct_site_id_LIST_TYPE;
  NUM_COL2_NEW_LIST cust_acct_site_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,trade_profile_id
              ,cust_account_id
              ,cust_acct_site_id
         FROM ozf_cust_trd_prfls yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.DUPLICATE_ID
            OR yt.cust_acct_site_id = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ozf_cust_trd_prfls',FALSE);
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
         'ozf_cust_trd_prfls',
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
      UPDATE ozf_cust_trd_prfls yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          ,cust_acct_site_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE trade_profile_id=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'merge_trade_profiles');
    RAISE;
END merge_trade_profiles;

END OZF_ACCOUNT_MERGE_PKG;

/
