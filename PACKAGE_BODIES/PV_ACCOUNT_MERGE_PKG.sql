--------------------------------------------------------
--  DDL for Package Body PV_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ACCOUNT_MERGE_PKG" AS
/* $Header: pvxvmrab.pls 115.0 2004/03/18 21:41:44 pklin ship $ */

-- Start of Comments
-- Package name     : PVX_ACCOUNT_MERGE_PKG
-- Purpose          : Merges duplicate accounts in PV tables. The

--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 03-16-2004    pklin         Created
--
-- End of Comments


/*-------------------------------------------------------------
|
|  PROCEDURE
|      MERGE_REFERRAL_ACCOUNT
|  DESCRIPTION :
|      Account merge procedure for the table, PV_REFERRALS_B
|
|--------------------------------------------------------------*/

PROCEDURE MERGE_REFERRAL_ACCOUNT (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE REFERRAL_ID_LIST_TYPE IS TABLE OF
         PV_REFERRALS_B.REFERRAL_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST REFERRAL_ID_LIST_TYPE;

  TYPE PARTNER_CUST_ACCOUNT_ID_TYPE IS TABLE OF
         PV_REFERRALS_B.PARTNER_CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;

  NUM_COL1_ORIG_LIST PARTNER_CUST_ACCOUNT_ID_TYPE;
  NUM_COL1_NEW_LIST PARTNER_CUST_ACCOUNT_ID_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,REFERRAL_ID
              ,PARTNER_CUST_ACCOUNT_ID
         FROM PV_REFERRALS_B yt, ra_customer_merges m
         WHERE (
            yt.PARTNER_CUST_ACCOUNT_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;

  l_last_fetch BOOLEAN := FALSE;
  l_count      NUMBER;

BEGIN
  IF process_mode='LOCK' THEN
    NULL;

  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PV_REFERRALS_B',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
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
         'PV_REFERRALS_B',
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

    END IF;

    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE PV_REFERRALS_B yt SET
           PARTNER_CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE REFERRAL_ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;

      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;

  -- -----------------------Exception----------------------------------
  EXCEPTION
     WHEN OTHERS THEN
        arp_message.set_line( 'MERGE_REFERRAL_ACCOUNT');
        RAISE;

END MERGE_REFERRAL_ACCOUNT;

END PV_ACCOUNT_MERGE_PKG ;

/
