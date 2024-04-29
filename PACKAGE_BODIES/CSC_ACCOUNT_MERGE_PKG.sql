--------------------------------------------------------
--  DDL for Package Body CSC_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_ACCOUNT_MERGE_PKG" AS
/* $Header: cscvmacb.pls 115.4 2003/06/26 14:50:23 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_ACCOUNT_MERGE
-- Purpose          : Merges duplicate customer accounts in the Customer
--                    Care tables.
--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-06-2000    dejoseph      Created.
-- 02-02-2001    dejoseph      Modified update stmt. to update the new columns that
--                             were added. ie. request_id, program_application_id,
--                             program_id, program_update_date.
-- 12-23-2002	 bhroy		All procedures body changed using the auto generated Perl script.
-- 02-12-2003	 bhroy		LAST_UPDATE_DATE, Last_updated_by, Last_update_login commented for CSC_CUSTOMIZED_PLANS table
-- 02-25-2003	 bhroy		l_count initialized, CSC_CUST_PLANS update where clause changed, delete redundant record
-- 04-28-2003	 bhroy		TCA sripts are inserting same record for ORIG and NEW columns, modified merge cursor
-- 06-26-2003	bhroy		Fixed cross party merge, Bug# 2930337
--
-- End of Comments
PROCEDURE CSC_MERGE_ALL_ACCOUNTS (
   req_id                 IN   NUMBER,
   set_num                 IN   NUMBER,
   process_mode               IN   VARCHAR2   := 'LOCK' )
IS
BEGIN
   CSC_CUSTOMERS_MERGE(
	 req_id              => req_id,
	 set_num              => set_num,
	 process_mode            => process_mode );

   CSC_CUSTOMERS_AUDIT_HIST_MERGE(
	 req_id              => req_id,
	 set_num              => set_num,
	 process_mode            => process_mode );

   CSC_CUSTOMIZED_PLANS_MERGE(
	 req_id              => req_id,
	 set_num              => set_num,
	 process_mode            => process_mode );

   CSC_CUST_PLANS_MERGE(
	 req_id              => req_id,
	 set_num              => set_num,
	 process_mode            => process_mode );

   CSC_CUST_PLANS_AUDIT_MERGE(
	 req_id              => req_id,
	 set_num              => set_num,
	 process_mode            => process_mode );

END CSC_MERGE_ALL_ACCOUNTS;

PROCEDURE CSC_CUSTOMERS_MERGE (
        req_id                     NUMBER,
        set_num                    NUMBER,
        process_mode               VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         CSC_CUSTOMERS.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE PARTY_ID_LIST_TYPE IS TABLE OF
         CSC_CUSTOMERS.PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST PARTY_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST PARTY_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
              ,m.customer_id, m.duplicate_id, hzca.party_id, yt.party_id
         FROM CSC_CUSTOMERS yt, ra_customer_merges m, hz_cust_accounts hzca
         WHERE ( yt.cust_account_id = m.duplicate_id AND m.customer_id = hzca.cust_account_id )
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CSC_CUSTOMERS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , NUM_COL1_NEW_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_NEW_LIST
          , NUM_COL2_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
--      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
--         NUM_COL1_NEW_LIST(I) := NUM_COL1_ORIG_LIST(I);
--      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
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
         'CSC_CUSTOMERS',
         MERGE_HEADER_ID_LIST(I),
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
      UPDATE CSC_CUSTOMERS yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          , party_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
		WHERE cust_account_id in ( SELECT m.duplicate_id FROM
		ra_customer_merges m WHERE
         	m.process_flag = 'N'
		AND    m.request_id = req_id
	        AND    m.set_number = set_num )
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
    arp_message.set_line( 'CSC_CUSTOMERS_MERGE');
    RAISE;
END CSC_CUSTOMERS_MERGE;

PROCEDURE CSC_CUSTOMERS_AUDIT_HIST_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         CSC_CUSTOMERS_AUDIT_HIST.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,m.customer_id, m.duplicate_id
         FROM CSC_CUSTOMERS_AUDIT_HIST yt, ra_customer_merges m , hz_cust_accounts hzca
         WHERE ( yt.cust_account_id = m.duplicate_id AND m.customer_id = hzca.cust_account_id )
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CSC_CUSTOMERS_AUDIT_HIST',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , NUM_COL1_NEW_LIST
          , NUM_COL1_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
--      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
--         NUM_COL1_NEW_LIST(I) := NUM_COL1_ORIG_LIST(I);
--      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
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
         'CSC_CUSTOMERS_AUDIT_HIST',
         MERGE_HEADER_ID_LIST(I),
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
      UPDATE CSC_CUSTOMERS_AUDIT_HIST yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
		WHERE cust_account_id in ( SELECT m.duplicate_id FROM
		ra_customer_merges m WHERE
         	m.process_flag = 'N'
		AND    m.request_id = req_id
	        AND    m.set_number = set_num )
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
    arp_message.set_line( 'CSC_CUSTOMERS_AUDIT_HIST_MERGE');
    RAISE;
END CSC_CUSTOMERS_AUDIT_HIST_MERGE;

PROCEDURE CSC_CUSTOMIZED_PLANS_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         CSC_CUSTOMIZED_PLANS.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE PARTY_ID_LIST_TYPE IS TABLE OF
         CSC_CUSTOMIZED_PLANS.PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST PARTY_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST PARTY_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
              ,m.customer_id, m.duplicate_id, hzca.party_id, yt.party_id
         FROM CSC_CUSTOMIZED_PLANS yt, ra_customer_merges m , hz_cust_accounts hzca
         WHERE ( yt.cust_account_id = m.duplicate_id AND m.customer_id = hzca.cust_account_id )
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CSC_CUSTOMIZED_PLANS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , NUM_COL1_NEW_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_NEW_LIST
          , NUM_COL2_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
--      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
--         NUM_COL1_NEW_LIST(I) := NUM_COL1_ORIG_LIST(I);
--      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
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
         'CSC_CUSTOMIZED_PLANS',
         MERGE_HEADER_ID_LIST(I),
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
      UPDATE CSC_CUSTOMIZED_PLANS yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          , party_id=NUM_COL2_NEW_LIST(I)
       --   , LAST_UPDATE_DATE=SYSDATE
       --   , last_updated_by=arp_standard.profile.user_id
        --  , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
		WHERE cust_account_id in ( SELECT m.duplicate_id FROM
		ra_customer_merges m WHERE
         	m.process_flag = 'N'
		AND    m.request_id = req_id
	        AND    m.set_number = set_num )
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
    arp_message.set_line( 'CSC_CUSTOMIZED_PLANS_MERGE');
    RAISE;
END CSC_CUSTOMIZED_PLANS_MERGE;

PROCEDURE CSC_CUST_PLANS_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CUST_PLAN_ID_LIST_TYPE IS TABLE OF
         CSC_CUST_PLANS.CUST_PLAN_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST CUST_PLAN_ID_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         CSC_CUST_PLANS.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE PARTY_ID_LIST_TYPE IS TABLE OF
         CSC_CUST_PLANS.PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST PARTY_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST PARTY_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
		,yt.cust_plan_id
              ,m.customer_id, m.duplicate_id, hzca.party_id, yt.party_id
         FROM CSC_CUST_PLANS yt, ra_customer_merges m , hz_cust_accounts hzca
         WHERE ( yt.cust_account_id = m.duplicate_id AND m.customer_id = hzca.cust_account_id )
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CSC_CUST_PLANS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_NEW_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_NEW_LIST
          , NUM_COL2_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
--      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
--         NUM_COL1_NEW_LIST(I) := NUM_COL1_ORIG_LIST(I);
--      END LOOP;
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
         'CSC_CUST_PLANS',
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
      UPDATE CSC_CUST_PLANS yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
          , party_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
		WHERE cust_account_id in ( SELECT m.duplicate_id FROM
		ra_customer_merges m WHERE
         	m.process_flag = 'N'
		AND    m.request_id = req_id
	        AND    m.set_number = set_num )
		AND plan_id not in ( SELECT yts.plan_id FROM
		csc_cust_plans yts, ra_customer_merges m WHERE
		yts.cust_account_id = m.customer_id
         	AND	m.process_flag = 'N'
		AND    	m.request_id = req_id
	        AND    	m.set_number = set_num )
         ;
      l_count := l_count + SQL%ROWCOUNT;

	DELETE FROM CSC_CUST_PLANS
		WHERE cust_account_id in ( SELECT m.duplicate_id FROM
		ra_customer_merges m WHERE
         	m.process_flag = 'N'
		AND    m.request_id = req_id
	        AND    m.set_number = set_num )
		AND plan_id in ( SELECT yts.plan_id FROM
		csc_cust_plans yts, ra_customer_merges m WHERE
		yts.cust_account_id = m.customer_id
         	AND	m.process_flag = 'N'
		AND    	m.request_id = req_id
	        AND    	m.set_number = set_num )
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
    arp_message.set_line( 'CSC_CUST_PLANS_MERGE');
    RAISE;
END CSC_CUST_PLANS_MERGE;

PROCEDURE CSC_CUST_PLANS_AUDIT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE PLAN_AUDIT_ID_LIST_TYPE IS TABLE OF
         CSC_CUST_PLANS_AUDIT.PLAN_AUDIT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST PLAN_AUDIT_ID_LIST_TYPE;

  TYPE cust_account_id_LIST_TYPE IS TABLE OF
         CSC_CUST_PLANS_AUDIT.cust_account_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
  NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

  TYPE PARTY_ID_LIST_TYPE IS TABLE OF
         CSC_CUST_PLANS.PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST PARTY_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST PARTY_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
		,yt.plan_audit_id
              ,m.customer_id, m.duplicate_id, hzca.party_id, yt.party_id
         FROM CSC_CUST_PLANS_AUDIT yt, ra_customer_merges m , hz_cust_accounts hzca
         WHERE ( yt.cust_account_id = m.duplicate_id AND m.customer_id = hzca.cust_account_id )
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CSC_CUST_PLANS_AUDIT',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_NEW_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_NEW_LIST
          , NUM_COL2_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
--      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
--         NUM_COL1_NEW_LIST(I) := NUM_COL1_ORIG_LIST(I);
--      END LOOP;
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
         'CSC_CUST_PLANS_AUDIT',
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
      UPDATE CSC_CUST_PLANS_AUDIT yt SET
           cust_account_id=NUM_COL1_NEW_LIST(I)
	  , party_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
		WHERE cust_account_id in ( SELECT m.duplicate_id FROM
		ra_customer_merges m WHERE
         	m.process_flag = 'N'
		AND    m.request_id = req_id
	        AND    m.set_number = set_num )
		AND plan_id not in ( SELECT yts.plan_id FROM
		csc_cust_plans_audit yts, ra_customer_merges m WHERE
		yts.cust_account_id = m.customer_id
         	AND	m.process_flag = 'N'
		AND    	m.request_id = req_id
	        AND    	m.set_number = set_num )
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
    arp_message.set_line( 'CSC_CUST_PLANS_AUDIT_MERGE');
    RAISE;
END CSC_CUST_PLANS_AUDIT_MERGE;

END CSC_ACCOUNT_MERGE_PKG;

/
