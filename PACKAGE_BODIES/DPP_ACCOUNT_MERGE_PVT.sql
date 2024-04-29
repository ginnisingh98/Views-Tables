--------------------------------------------------------
--  DDL for Package Body DPP_ACCOUNT_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_ACCOUNT_MERGE_PVT" AS
/* $Header: dppvamgb.pls 120.1 2007/12/07 07:21:31 sdasan noship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'DPP_ACCOUNT_MERGE_PVT';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'dppvamgb.pls';
------------------------------------------------------------------------------

/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_claim_account
|  DESCRIPTION :
|      Account merge procedure for the table, dpp_customer_claims_all
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_claim_account (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;

  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CUSTOMER_INV_LINE_ID_LIST_TYPE IS TABLE OF
         DPP_CUSTOMER_CLAIMS_ALL.CUSTOMER_INV_LINE_ID%TYPE
        INDEX BY BINARY_INTEGER;

  PRIMARY_KEY_ID1_LIST CUSTOMER_INV_LINE_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;

  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
        SELECT DISTINCT m.customer_merge_header_id
              ,yt.customer_inv_line_id
              ,m.customer_id
         FROM dpp_customer_claims_all yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.duplicate_id
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','dpp_customer_claims_all',FALSE);
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
      ) VALUES ( HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'dpp_customer_claims_all',
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

    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT

      UPDATE dpp_customer_claims_all yt SET
           cust_account_id = TO_CHAR(NUM_COL1_NEW_LIST(I))
          , LAST_UPDATE_DATE = SYSDATE
          , last_updated_by = arp_standard.profile.user_id
          , last_update_login = arp_standard.profile.last_update_login
      WHERE customer_inv_line_id = PRIMARY_KEY_ID1_LIST(I);
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
    arp_message.set_line( 'merge_claim_account');
    RAISE;
END merge_claim_account;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      merge_claim_account_log
|  DESCRIPTION :
|      Account merge procedure for the table, dpp_customer_claims_log
|
|  NOTES:
|
|--------------------------------------------------------------*/

PROCEDURE merge_claim_account_log (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;

  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE LOG_ID_LIST_TYPE IS TABLE OF
         DPP_CUSTOMER_CLAIMS_LOG.LOG_ID%TYPE
        INDEX BY BINARY_INTEGER;

  PRIMARY_KEY_ID1_LIST LOG_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;

  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
        SELECT DISTINCT m.customer_merge_header_id
              ,yt.log_id
              ,m.customer_id
         FROM dpp_customer_claims_log yt, ra_customer_merges m
         WHERE (
            yt.cust_account_id = m.duplicate_id
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','dpp_customer_claims_log',FALSE);
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
      ) VALUES ( HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'dpp_customer_claims_log',
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

    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT

      UPDATE dpp_customer_claims_log yt SET
           cust_account_id = TO_CHAR(NUM_COL1_NEW_LIST(I))
          , LAST_UPDATE_DATE = SYSDATE
          , last_updated_by = arp_standard.profile.user_id
          , last_update_login = arp_standard.profile.last_update_login
      WHERE log_id = PRIMARY_KEY_ID1_LIST(I);
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
    arp_message.set_line( 'merge_claim_account_log');
    RAISE;
END merge_claim_account_log;


END DPP_ACCOUNT_MERGE_PVT;

/
