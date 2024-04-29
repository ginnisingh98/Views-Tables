--------------------------------------------------------
--  DDL for Package Body OKS_HZ_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_HZ_MERGE_PUB" AS
/* $Header: OKSPMRGB.pls 120.0 2005/05/25 18:02:52 appldev noship $ */
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
-- Start of Comments
-- API Name     :OKS_HZ_MERGE_PUB
-- Type         :Public
-- Purpose      :Manage customer and party merges
--
-- Modification History
-- 13-Dec-00    mconnors    created
-- 24-JUl-02    chkrishn   included logging for customer merge
-- 22-May-03    chkrishn   uptook tca logging changes for customer merge
-- 18-Mar-04    chkrishn   included quote_to_site_id update for rules rearchitecture
-- 17-Aug-04    chkrishn   OKS_QUALIFIERS update for bug 3816822
--
-- NOTES
-- Merging Rules:
--   OKS will not allow an account merge across parties when the source account
--   (the duplicate) is referenced in OKS_BILLING_PROFILES_B.  To do so will invalidate
--   the party - account relationship in this table.
--
--   OKS will allow an account merge in other cases.
--
--   When merging accounts, customer account ids are looked for in:
--      OKS_BILLING_PROFILES_B
--
--   When merging sites, customer site use ids are looked for in:
--      OKS_BILLING_PROFILES_B
--
-- JTF Objects:
--   The merge depends upon the proper usages being set for the JTF objects used
--   to represent parties, party site, accounts and account sites.
--   These usages are as follows:
--          OKX_PARTY       This object is based on a view which returns the
--                          party_id as id1.
--          OKX_P_SITE      This object is based on a view which returns
--                          party_site_id as id1.
--          OKX_P_SITE_USE  This object is based on a view which returns
--                          party_site_use_id as id1.
--          OKX_ACCOUNT     This object is based on a view which returns
--                          cust_account_id as id1.
--          OKX_C_SITE      This object is based on a view which returns
--                          cust_acct_site_id as id1.
--          OKX_C_SITE_USE  This object is based on a view which returns
--                          site_use_id as id1.
--   The usages are how the merge determines which jtot_object_codes are candidates
--   for the different types of merges.
--
--
-- End of comments


-- Global constants
c_party             CONSTANT VARCHAR2(20) := 'OKX_PARTY';
c_p_site            CONSTANT VARCHAR2(20) := 'OKX_P_SITE';
c_p_site_use        CONSTANT VARCHAR2(20) := 'OKX_P_SITE_USE';
c_account           CONSTANT VARCHAR2(20) := 'OKX_ACCOUNT';
c_c_site            CONSTANT VARCHAR2(20) := 'OKX_C_SITE';
c_c_site_use        CONSTANT VARCHAR2(20) := 'OKX_C_SITE_USE';

--
-- routine to lock tables when process mode = 'LOCK'
-- if table cannot be locked, goes back to caller as exception
PROCEDURE lock_tables (req_id IN NUMBER
                      ,set_number IN NUMBER) IS
--
-- cursors to lock tables
--
CURSOR c_lock_bpe IS
  SELECT 1
  FROM oks_billing_profiles_b bpe
  WHERE bpe.dependent_cust_acct_id1 IN (SELECT cme.duplicate_id
                                        FROM ra_customer_merges cme
                                        WHERE cme.process_flag = 'N'
                                          AND cme.request_id   = req_id
                                          AND cme.set_number   = set_number
                                        )
  FOR UPDATE NOWAIT;

BEGIN
  arp_message.set_line('OKS_HZ_MERGE_PUB.LOCK_TABLES()+');

  -- billing profiles
  arp_message.set_name('AR','AR_LOCKING_TABLE');
  arp_message.set_token('TABLE_NAME','OKS_BILLING_PROFILES_B',FALSE);
  open c_lock_bpe;
  close c_lock_bpe;

  arp_message.set_line('OKS_HZ_MERGE_PUB.LOCK_TABLES()-');

END; -- lock_tables

--
-- sub routine to merge accounts
-- exceptions are unhandled, sent back to caller
--
PROCEDURE account_merge(req_id IN NUMBER
                       ,set_number IN NUMBER) IS

l_count     NUMBER;


--CK add logging
TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKS_BILLING_PROFILES_B.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST ID_LIST_TYPE;

  TYPE DEP_CUST_ACCT_ID1_LIST_TYPE  IS TABLE OF
         OKS_BILLING_PROFILES_B.DEPENDENT_CUST_ACCT_ID1%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST DEP_CUST_ACCT_ID1_LIST_TYPE ;
  NUM_COL1_NEW_LIST DEP_CUST_ACCT_ID1_LIST_TYPE ;

  TYPE OBJECT_VER_NUMBER_LIST_TYPE IS TABLE OF
         OKS_BILLING_PROFILES_B.OBJECT_VERSION_NUMBER%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST OBJECT_VER_NUMBER_LIST_TYPE ;
  NUM_COL2_NEW_LIST OBJECT_VER_NUMBER_LIST_TYPE ;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,DEPENDENT_CUST_ACCT_ID1
              ,OBJECT_VERSION_NUMBER
         FROM OKS_BILLING_PROFILES_B yt, ra_customer_merges m
         WHERE (
            yt.DEPENDENT_CUST_ACCT_ID1 = m.DUPLICATE_ID
            OR yt.OBJECT_VERSION_NUMBER = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_number;
  l_last_fetch BOOLEAN := FALSE;
--

BEGIN
--CK new code with logging
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKS_BILLING_PROFILES_B',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_number, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
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
         'OKS_BILLING_PROFILES_B',
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
    END IF;
 FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKS_BILLING_PROFILES_B yt SET
           DEPENDENT_CUST_ACCT_ID1=NUM_COL1_NEW_LIST(I)
          ,OBJECT_VERSION_NUMBER=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE ID=PRIMARY_KEY_ID1_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
   -- billing profile
   /*CK old code
  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKS_BILLING_PROFILES_B',FALSE);
      INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       MERGE_HEADER_ID,
       TABLE_NAME,
       PRIMARY_KEY_ID,
       NUM_COL1_ORIG,
       NUM_COL1_NEW,
       NUM_COL2_ORIG,
       NUM_COL2_NEW,
       REQUEST_ID
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             CUSTOMER_MERGE_HEADER_ID,
             'OKS_BILLING_PROFILES_B',
             ID,
             DEPENDENT_CUST_ACCT_ID1,
             decode(yt.DEPENDENT_CUST_ACCT_ID1,m.DUPLICATE_ID,m.CUSTOMER_ID,yt.DEPENDENT_CUST_ACCT_ID1),
             OBJECT_VERSION_NUMBER,
             OBJECT_VERSION_NUMBER,
             request_id
     FROM OKS_BILLING_PROFILES_B yt, ra_customer_merges m
     WHERE (
          yt.DEPENDENT_CUST_ACCT_ID1 = m.DUPLICATE_ID
--          OR yt.BILL_TO_ADDRESS_ID1 = m.DUPLICATE_SITE_ID
     ) AND    m.process_flag = 'N'
     AND    m.request_id = req_id
     AND    m.set_number = set_number;

     UPDATE OKS_BILLING_PROFILES_B yt SET (
      DEPENDENT_CUST_ACCT_ID1, OBJECT_VERSION_NUMBER) = (
           SELECT NUM_COL1_NEW, NUM_COL2_NEW
           FROM HZ_CUSTOMER_MERGE_LOG l
           WHERE l.REQUEST_ID = req_id
           AND l.TABLE_NAME = 'OKS_BILLING_PROFILES_B'
           AND l.PRIMARY_KEY_ID = ID
           AND DEPENDENT_CUST_ACCT_ID1 = NUM_COL1_ORIG
           and rownum <2
      )
       , LAST_UPDATE_DATE=SYSDATE
       , last_updated_by=arp_standard.profile.user_id
       , last_update_login=arp_standard.profile.last_update_login
      WHERE (ID) in (
         SELECT PRIMARY_KEY_ID
         FROM HZ_CUSTOMER_MERGE_LOG l1, RA_CUSTOMER_MERGES h
         WHERE h.CUSTOMER_MERGE_HEADER_ID = l1.MERGE_HEADER_ID
         AND l1.TABLE_NAME = 'OKS_BILLING_PROFILES_B'
         AND l1.REQUEST_ID = req_id
         AND h.set_number = set_number);
    l_count := SQL%ROWCOUNT;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
    arp_message.set_line('OKS_HZ_MERGE_PUB.ACCOUNT_MERGE()-');CK old code*/
END; -- account_merge

--
-- sub routine to merge account sites and site uses
-- exceptions are unhandled, sent back to caller
--
PROCEDURE account_site_merge (req_id IN NUMBER
                             ,set_number  IN NUMBER) IS

l_count         NUMBER;
--CK logging
  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;
  TYPE ID_LIST_TYPE IS TABLE OF
         OKS_BILLING_PROFILES_B.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST ID_LIST_TYPE;

  TYPE BILL_TO_ADDRESS_ID1_LIST_TYPE IS TABLE OF
         OKS_BILLING_PROFILES_B.BILL_TO_ADDRESS_ID1%TYPE
        INDEX BY BINARY_INTEGER;

  NUM_COL3_ORIG_LIST BILL_TO_ADDRESS_ID1_LIST_TYPE;
  NUM_COL3_NEW_LIST BILL_TO_ADDRESS_ID1_LIST_TYPE;

  TYPE OBJECT_VERSION_NUM_LIST_TYPE IS TABLE OF
         OKS_BILLING_PROFILES_B.OBJECT_VERSION_NUMBER%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST OBJECT_VERSION_NUM_LIST_TYPE;
  NUM_COL4_NEW_LIST OBJECT_VERSION_NUM_LIST_TYPE;

  --03/15/2004
  MERGE_HEADER_ID_LIST_QUOTE MERGE_HEADER_ID_LIST_TYPE;
  PRIMARY_KEY_ID1_LIST_QUOTE ID_LIST_TYPE;
  TYPE QUOTE_TO_SITE_ID_LIST_TYPE IS TABLE OF
         OKS_K_HEADERS_B.QUOTE_TO_SITE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST_QUOTE QUOTE_TO_SITE_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST_QUOTE QUOTE_TO_SITE_ID_LIST_TYPE;
  TYPE OBJECT_VERSION_NUM_LIST_TYPE_Q IS TABLE OF
         OKS_K_HEADERS_B.OBJECT_VERSION_NUMBER%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST_QUOTE OBJECT_VERSION_NUM_LIST_TYPE_Q;
  NUM_COL2_NEW_LIST_QUOTE OBJECT_VERSION_NUM_LIST_TYPE_Q;

  --03/15/2004
  l_profile_val VARCHAR2(30);
CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,BILL_TO_ADDRESS_ID1
              ,OBJECT_VERSION_NUMBER
         FROM OKS_BILLING_PROFILES_B yt, ra_customer_merges m
         WHERE (
            yt.BILL_TO_ADDRESS_ID1 = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_number;
         l_last_fetch BOOLEAN := FALSE;

--03/15/2004
CURSOR merged_records_quote IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,QUOTE_TO_SITE_ID
              ,OBJECT_VERSION_NUMBER
         FROM OKS_K_HEADERS_B hdr, ra_customer_merges m
         WHERE (
            hdr.QUOTE_TO_SITE_ID = m.DUPLICATE_ADDRESS_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_number;
--03/15/2004
--CK

BEGIN
--ck new code with logging
   ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKS_BILLING_PROFILES_B',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_number, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');
    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL3_ORIG_LIST
          , NUM_COL4_ORIG_LIST
           limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
         NUM_COL4_NEW_LIST(I) := NUM_COL4_ORIG_LIST(I);
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
          FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL3_ORIG,
           NUM_COL3_NEW,
           NUM_COL4_ORIG,
           NUM_COL4_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKS_BILLING_PROFILES_B',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
         NUM_COL4_ORIG_LIST(I),
         NUM_COL4_NEW_LIST(I),
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
      UPDATE OKS_BILLING_PROFILES_B yt SET
           BILL_TO_ADDRESS_ID1=NUM_COL3_NEW_LIST(I)
          ,OBJECT_VERSION_NUMBER=NUM_COL4_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE ID=PRIMARY_KEY_ID1_LIST(I)
         ;

      --l_count := l_count + SQL%ROWCOUNT;
      l_count := SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;
    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

--03/15/2004 added code to update quote_to_site_id
   ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKS_K_HEADERS_B',FALSE);
    open merged_records_quote;
    LOOP
      FETCH merged_records_quote BULK COLLECT INTO
         MERGE_HEADER_ID_LIST_QUOTE
          , PRIMARY_KEY_ID1_LIST_QUOTE
          , NUM_COL1_ORIG_LIST_QUOTE
          , NUM_COL2_ORIG_LIST_QUOTE
           limit 1000;
      IF merged_records_quote%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST_QUOTE.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST_QUOTE.COUNT LOOP
--               NUM_COL1_NEW_LIST_QUOTE(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST_QUOTE(I));
         NUM_COL1_NEW_LIST_QUOTE(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL1_ORIG_LIST_QUOTE(I));
         NUM_COL2_NEW_LIST_QUOTE(I) := NUM_COL2_ORIG_LIST_QUOTE(I);
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
          FORALL I in 1..MERGE_HEADER_ID_LIST_QUOTE.COUNT
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
         'OKS_K_HEADERS_B',
         MERGE_HEADER_ID_LIST_QUOTE(I),
         PRIMARY_KEY_ID1_LIST_QUOTE(I),
         NUM_COL1_ORIG_LIST_QUOTE(I),
         NUM_COL1_NEW_LIST_QUOTE(I),
         NUM_COL2_ORIG_LIST_QUOTE(I),
         NUM_COL2_NEW_LIST_QUOTE(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;

     FORALL I in 1..MERGE_HEADER_ID_LIST_QUOTE.COUNT
      UPDATE OKS_K_HEADERS_B yt SET
           QUOTE_TO_SITE_ID=NUM_COL1_NEW_LIST_QUOTE(I)
          ,OBJECT_VERSION_NUMBER=NUM_COL2_NEW_LIST_QUOTE(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE ID=PRIMARY_KEY_ID1_LIST_QUOTE(I);

      l_count := SQL%ROWCOUNT;
    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    --Added for updating OKS_QUALIFIERS table during account merge
   ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
   ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKS_QUALIFIERS',FALSE);

    OKS_QP_INT_PVT.QUALIFIER_ACCOUNT_MERGE
    (req_id   =>req_id,
     set_num  =>set_number);

END; -- account_site_merge

--
-- main account merge routine
--
PROCEDURE merge_account (req_id IN NUMBER
                        ,set_number  IN NUMBER
                        ,process_mode IN VARCHAR2) is

--
-- cursor to get merge reason from merge header
-- to be used later
--
CURSOR c_reason IS
  SELECT cmh.merge_reason_code
  FROM ra_customer_merge_headers cmh
      ,ra_customer_merges cme
  WHERE cmh.customer_merge_header_id = cme.customer_merge_header_id
    AND cme.request_id               = req_id
    AND cme.set_number               = set_number
    AND cme.process_flag             = 'N'
  ;

--
-- cursor to determine if the merge is an account merge,
-- or a site merge within the same account
--
CURSOR c_site_merge(b_request_id NUMBER, b_set_number NUMBER) IS
  SELECT customer_id, duplicate_id
  FROM ra_customer_merges cme
  WHERE cme.request_id   = req_id
    AND cme.set_number   = set_number
    AND cme.process_flag = 'N'
  ;

--
-- cursort to find party id given the account id
--
CURSOR c_party_id (b_account_id NUMBER) IS
  SELECT party_id
  FROM hz_cust_accounts
  WHERE cust_account_id = b_account_id
;
--
-- cursor to find if any contract is with the party of the
-- merged account
--
CURSOR c_bpe (b_party_id NUMBER) IS
  SELECT 1
  FROM oks_billing_profiles_b bpe
  WHERE bpe.owned_party_id1 = b_party_id
  ;
--
-- local variables
--
l_merge_reason              ra_customer_merge_headers.merge_reason_code%type;
l_customer_id               ra_customer_merge_headers.customer_id%type;
l_duplicate_id              ra_customer_merge_headers.duplicate_id%type;
l_source_party_id           hz_parties.party_id%type;
l_target_party_id           hz_parties.party_id%type;
l_temp                      NUMBER;
l_error_msg                 VARCHAR2(2000);

l_merge_disallowed_excp     EXCEPTION;
l_no_data_found_excp        EXCEPTION;
l_lock_excp                 EXCEPTION;

BEGIN
  arp_message.set_line('OKS_HZ_MERGE_PUB.MERGE_ACCOUNT()+');

  --
  -- check process mode.  If LOCK, then just lock the tables
  --
  IF process_mode = 'LOCK' THEN
    lock_tables(req_id => req_id
               ,set_number => set_number);
    --
    -- that's it, exit
    --
    raise l_lock_excp;
  END IF;

  --
  -- determine if account merge or site merge within account
  --
  OPEN c_site_merge(req_id, set_number);
  FETCH c_site_merge INTO l_customer_id, l_duplicate_id;
  IF c_site_merge%NOTFOUND THEN
    CLOSE c_site_merge;
    RAISE l_no_data_found_excp;
  END IF;

  IF l_customer_id <> l_duplicate_id THEN -- this is an account merge
    --
    -- must first determine if accounts are merged within the same party
    -- so get the two party ids
    --
    OPEN c_party_id(l_duplicate_id);
    FETCH c_party_id INTO l_source_party_id;
    IF c_party_id%NOTFOUND THEN
      CLOSE c_party_id;
      RAISE l_no_data_found_excp;
    END IF;
    CLOSE c_party_id;

    OPEN c_party_id(l_customer_id);
    FETCH c_party_id INTO l_target_party_id;
    IF c_party_id%NOTFOUND THEN
      CLOSE c_party_id;
      RAISE l_no_data_found_excp;
    END IF;
    CLOSE c_party_id;

    IF l_source_party_id <> l_target_party_id THEN
      -- merge across parties, disallow if the party has a billing profile
      OPEN c_bpe(l_source_party_id);
      FETCH c_bpe INTO l_temp;
      IF c_bpe%FOUND THEN
        CLOSE c_bpe;
        RAISE l_merge_disallowed_excp;  -- do not allow merge
      END IF;
      CLOSE c_bpe;
      --
      -- party is not used in a billing profile
      --
    END IF; -- l_source_party_id <> l_target_party_id
    --
    -- to get here, either the party ids are the same
    -- or the "duplicate" party is not in a billing profile
    -- either way, do the account merge
    account_merge(req_id => req_id
                 ,set_number => set_number);
    account_site_merge(req_id => req_id
                      ,set_number => set_number);
  ELSE  -- customer ids the same, this is an account site merge
    account_site_merge(req_id => req_id
                      ,set_number => set_number);
  END IF; -- if customer ids the same

  arp_message.set_line('OKS_HZ_MERGE_PUB.MERGE_ACCOUNT()-');

EXCEPTION
  WHEN l_merge_disallowed_excp THEN
--    arp_message.set_line('Billing Profile exists for duplicate party, merge cannot proceed');
    arp_message.set_line('Cannot Merge Customer Accounts owned by different parties. Please run Party Merge first and then run Customer Merge');
    arp_message.set_error('OKS_HZ_MERGE_PUB.MERGE_ACCOUNT');
    RAISE;
  WHEN l_no_data_found_excp THEN
    arp_message.set_line('No data found for merge information');
    arp_message.set_error('OKS_HZ_MERGE_PUB.MERGE_ACCOUNT');
    RAISE;
  WHEN l_lock_excp THEN -- normal exit after locking
    arp_message.set_line('OKS_HZ_MERGE_PUB.MERGE_ACCOUNT()-');
  WHEN others THEN
    l_error_msg := substr(SQLERRM,1,70);
    arp_message.set_error('OKS_HZ_MERGE_PUB.MERGE_ACCOUNT', l_error_msg);
    RAISE;
END; -- merge_account

END; -- Package Body OKS_HZ_MERGE_PUB

/
