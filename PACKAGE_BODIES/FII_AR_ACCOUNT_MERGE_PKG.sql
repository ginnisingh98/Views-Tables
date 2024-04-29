--------------------------------------------------------
--  DDL for Package Body FII_AR_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_ACCOUNT_MERGE_PKG" AS
/* $Header: FIIAR21B.pls 120.0.12000000.1 2007/02/23 02:27:35 applrt ship $ */

PROCEDURE MERGE_ACCOUNTS
 (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS
 BEGIN
    MERGE_FACT_ACCOUNTS (req_id, set_num, process_mode);
    MERGE_COLLECTOR_ACCOUNTS (req_id, set_num, process_mode);
    MERGE_CUSTOMER_ACCOUNTS (req_id, set_num, process_mode);
 END MERGE_ACCOUNTS;


PROCEDURE MERGE_FACT_ACCOUNTS
 (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE PAYMENT_SCHEDULE_ID_LIST_TYPE IS TABLE OF FII_AR_PMT_SCHEDULES_F.PAYMENT_SCHEDULE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST PAYMENT_SCHEDULE_ID_LIST_TYPE;

  TYPE BILL_TO_CUSTOMER_ID_LIST_TYPE IS TABLE OF FII_AR_PMT_SCHEDULES_F.BILL_TO_CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST BILL_TO_CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST BILL_TO_CUSTOMER_ID_LIST_TYPE;

  TYPE BILL_TO_SITE_USE_ID_LIST_TYPE IS TABLE OF FII_AR_PMT_SCHEDULES_F.BILL_TO_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST BILL_TO_SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST BILL_TO_SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID,
              yt.PAYMENT_SCHEDULE_ID,
              yt.BILL_TO_CUSTOMER_ID,
              yt.BILL_TO_SITE_USE_ID,
              m.CUSTOMER_ID,
              m.customer_site_id
         FROM FII_AR_PMT_SCHEDULES_F yt,
              ra_customer_merges m
         WHERE (yt.BILL_TO_CUSTOMER_ID = m.duplicate_id
                AND yt.BILL_TO_SITE_USE_ID = m.duplicate_site_id)
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FII_AR_PMT_SCHEDULES_F',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP

      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST,
         PRIMARY_KEY_ID_LIST,
         NUM_COL1_ORIG_LIST,
         NUM_COL2_ORIG_LIST,
         NUM_COL1_NEW_LIST,
         NUM_COL2_NEW_LIST;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;


      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG, NUM_COL1_NEW,
           NUM_COL2_ORIG, NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'FII_AR_PMT_SCHEDULES_F',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I), NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I), NUM_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;

    --FII_AR_PAYMENT_SCHEDULES_F
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FII_AR_PMT_SCHEDULES_F yt
      SET BILL_TO_CUSTOMER_ID=NUM_COL1_NEW_LIST(I),
          BILL_TO_SITE_USE_ID=NUM_COL2_NEW_LIST(I)
      WHERE PAYMENT_SCHEDULE_ID=PRIMARY_KEY_ID_LIST(I);

    --FII_AR_TRANSACTIONS_F
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FII_AR_TRANSACTIONS_F yt
      SET BILL_TO_CUSTOMER_ID = NUM_COL1_NEW_LIST(I),
          BILL_TO_SITE_USE_ID = NUM_COL2_NEW_LIST(I)
      WHERE BILL_TO_CUSTOMER_ID = NUM_COL1_ORIG_LIST(I)
      AND BILL_TO_SITE_USE_ID = NUM_COL2_ORIG_LIST(I);

    --FII_AR_RECEIPTS_F
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FII_AR_RECEIPTS_F yt
      SET BILL_TO_CUSTOMER_ID = NUM_COL1_NEW_LIST(I),
          BILL_TO_SITE_USE_ID = NUM_COL2_NEW_LIST(I)
      WHERE BILL_TO_CUSTOMER_ID = NUM_COL1_ORIG_LIST(I)
      AND BILL_TO_SITE_USE_ID = NUM_COL2_ORIG_LIST(I);

    --FII_AR_RECEIPTS_F (Collector_bill_to)
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FII_AR_RECEIPTS_F yt
      SET COLLECTOR_BILL_TO_CUSTOMER_ID = NUM_COL1_NEW_LIST(I),
          COLLECTOR_BILL_TO_SITE_USE_ID = NUM_COL2_NEW_LIST(I)
      WHERE COLLECTOR_BILL_TO_CUSTOMER_ID = NUM_COL1_ORIG_LIST(I)
      AND COLLECTOR_BILL_TO_SITE_USE_ID = NUM_COL2_ORIG_LIST(I);

    --FII_AR_ADJUSTMENTS_F
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FII_AR_ADJUSTMENTS_F yt
      SET BILL_TO_CUSTOMER_ID = NUM_COL1_NEW_LIST(I),
          BILL_TO_SITE_USE_ID = NUM_COL2_NEW_LIST(I)
      WHERE BILL_TO_CUSTOMER_ID = NUM_COL1_ORIG_LIST(I)
      AND BILL_TO_SITE_USE_ID = NUM_COL2_ORIG_LIST(I);

    --FII_AR_DISPUTE_HISTORY_F
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FII_AR_DISPUTE_HISTORY_F yt
      SET BILL_TO_CUSTOMER_ID = NUM_COL1_NEW_LIST(I),
          BILL_TO_SITE_USE_ID = NUM_COL2_NEW_LIST(I)
      WHERE BILL_TO_CUSTOMER_ID = NUM_COL1_ORIG_LIST(I)
      AND BILL_TO_SITE_USE_ID = NUM_COL2_ORIG_LIST(I);

    --FII_AR_AGING_RECEIVABLES
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FII_AR_AGING_RECEIVABLES yt
      SET BILL_TO_CUSTOMER_ID = NUM_COL1_NEW_LIST(I),
          BILL_TO_SITE_USE_ID = NUM_COL2_NEW_LIST(I)
      WHERE BILL_TO_CUSTOMER_ID = NUM_COL1_ORIG_LIST(I)
      AND BILL_TO_SITE_USE_ID = NUM_COL2_ORIG_LIST(I);

    --FII_AR_AGING_RECEIPTS
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FII_AR_AGING_RECEIPTS yt
      SET BILL_TO_CUSTOMER_ID = NUM_COL1_NEW_LIST(I),
          BILL_TO_SITE_USE_ID = NUM_COL2_NEW_LIST(I)
      WHERE BILL_TO_CUSTOMER_ID = NUM_COL1_ORIG_LIST(I)
      AND BILL_TO_SITE_USE_ID = NUM_COL2_ORIG_LIST(I);

    --FII_AR_AGING_DISPUTES
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FII_AR_AGING_DISPUTES yt
      SET BILL_TO_CUSTOMER_ID = NUM_COL1_NEW_LIST(I),
          BILL_TO_SITE_USE_ID = NUM_COL2_NEW_LIST(I)
      WHERE BILL_TO_CUSTOMER_ID = NUM_COL1_ORIG_LIST(I)
      AND BILL_TO_SITE_USE_ID = NUM_COL2_ORIG_LIST(I);

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
    arp_message.set_line('MERGE_FACT_ACCOUNTS');
    RAISE;
END MERGE_FACT_ACCOUNTS;

PROCEDURE MERGE_COLLECTOR_ACCOUNTS
 (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF FII_COLLECTORS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF FII_COLLECTORS.SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID2_LIST SITE_USE_ID_LIST_TYPE;

  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  NUM_COL2_ORIG_LIST SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SITE_USE_ID_LIST_TYPE;

  TYPE PARTY_ID_LIST_TYPE IS TABLE OF FII_COLLECTORS.PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PARTY_ID_LIST PARTY_ID_LIST_TYPE;

  TYPE COLLECTOR_ID_LIST_TYPE IS TABLE OF FII_COLLECTORS.COLLECTOR_ID%TYPE
        INDEX BY BINARY_INTEGER;
  COLLECTOR_ID_LIST COLLECTOR_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID,
              yt.cust_account_id,
              yt.site_use_id,
              yt.cust_account_id,
              yt.site_use_id,
              m.CUSTOMER_ID,
              m.customer_site_id
         FROM FII_COLLECTORS yt,
              ra_customer_merges m
         WHERE (yt.cust_account_id = m.duplicate_id
                AND yt.site_use_id = m.duplicate_site_id)
         AND (m.customer_id, m.customer_site_id) not in
             (select cust_account_id, site_use_id
              from fii_collectors)
         AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;

  CURSOR deleted_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID,
              yt.cust_account_id,
              yt.site_use_id,
              yt.party_id,
              yt.collector_id
         FROM FII_COLLECTORS yt,
              ra_customer_merges m
         WHERE yt.cust_account_id = m.duplicate_id
         AND m.customer_id in
             (select cust_account_id
              from fii_collectors)
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FII_COLLECTORS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    /*
    The following code will update records, which when updated with the surviving account/site_use
    will not result in a primary key violation, since the surviving account/site_use combination
    is new to fii_collectors.
    */
    open merged_records;
    LOOP

      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST,
         PRIMARY_KEY_ID1_LIST,
         PRIMARY_KEY_ID2_LIST,
         NUM_COL1_ORIG_LIST,
         NUM_COL2_ORIG_LIST,
         NUM_COL1_NEW_LIST,
         NUM_COL2_NEW_LIST;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           PRIMARY_KEY_ID1, PRIMARY_KEY_ID2,
           NUM_COL1_ORIG, NUM_COL1_NEW,
           NUM_COL2_ORIG, NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'FII_COLLECTORS',
         MERGE_HEADER_ID_LIST(I),
         null,
         PRIMARY_KEY_ID1_LIST(I), PRIMARY_KEY_ID2_LIST(I),
         NUM_COL1_ORIG_LIST(I), NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I), NUM_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;

    --FII_COLLECTORS
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FII_COLLECTORS yt
      SET CUST_ACCOUNT_ID = NUM_COL1_NEW_LIST(I),
          SITE_USE_ID = NUM_COL2_NEW_LIST(I)
      WHERE CUST_ACCOUNT_ID = PRIMARY_KEY_ID1_LIST(I)
      AND SITE_USE_ID = PRIMARY_KEY_ID2_LIST(I);


      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));


    /*
    The following code will delete records, which if updated with the surviving account/site_use
    would have resulted in a primary key violation, since the surviving account/site_use combination
    already exists in fii_collectors.
    */
    l_last_fetch := FALSE;

    open deleted_records;
    LOOP

      FETCH deleted_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST,
         PRIMARY_KEY_ID1_LIST,
         PRIMARY_KEY_ID2_LIST,
         PARTY_ID_LIST,
         COLLECTOR_ID_LIST;

      IF deleted_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1, PRIMARY_KEY_ID2,
           DEL_COL1,
           DEL_COL2,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'FII_COLLECTORS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID1_LIST(I), PRIMARY_KEY_ID2_LIST(I),
         PARTY_ID_LIST(I),
         COLLECTOR_ID_LIST(I),
         'D',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;

    --FII_COLLECTORS
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      DELETE FROM FII_COLLECTORS
      WHERE CUST_ACCOUNT_ID = PRIMARY_KEY_ID1_LIST(I);


      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    --arp_message.set_name('AR','AR_ROWS_UPDATED');
    --arp_message.set_token('NUM_ROWS',to_char(l_count));

  END IF;

EXCEPTION

  WHEN OTHERS THEN
    arp_message.set_line('MERGE_COLLECTOR_ACCOUNTS');
    RAISE;

END MERGE_COLLECTOR_ACCOUNTS;



-- ******************************************************************
-- This procedure maintains FII_Cust_Accounts after an Account Merge.
-- ******************************************************************

PROCEDURE MERGE_CUSTOMER_ACCOUNTS (req_id       NUMBER,
                                   set_num      NUMBER,
	                           process_mode VARCHAR2) IS

     TYPE Merge_Header_ID_Type IS
     TABLE OF RA_CUSTOMER_MERGES.CUSTOMER_MERGE_HEADER_ID%TYPE
     INDEX BY BINARY_INTEGER;

     TYPE Cust_Account_ID_Type IS TABLE OF FII_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE
     INDEX BY BINARY_INTEGER;

     TYPE Party_ID_Type IS TABLE OF HZ_PARTIES.PARTY_ID%TYPE
     INDEX BY BINARY_INTEGER;

     TYPE PARTY_ID_LIST_TYPE IS TABLE OF FII_CUST_ACCOUNTS.PARENT_PARTY_ID%TYPE
     INDEX BY BINARY_INTEGER;

     Merge_Header_ID_List        Merge_Header_ID_Type;
     Cust_Account_ID_List        Cust_Account_ID_Type;
     Account_Owner_Party_ID_List Party_ID_Type;
     Parent_Party_ID_List        Party_ID_Type;

     l_profile_val               VARCHAR2(30);
     l_last_fetch                BOOLEAN := FALSE;

     CURSOR Account_Merge_Records IS
     SELECT M.Customer_Merge_Header_ID,
            CA.Cust_Account_ID,
            CA.Account_Owner_Party_ID,
            CA.Parent_Party_ID
     FROM FII_Cust_Accounts CA,
          RA_Customer_Merges M
     WHERE CA.Cust_Account_ID = M.Duplicate_ID
     AND   M.Process_Flag = 'N'
     AND   M.Request_ID = Req_ID
     AND   M.Set_Number = Set_Num
     AND   M.Delete_Duplicate_Flag = 'Y';


BEGIN

  IF Process_Mode <> 'LOCK' THEN --Process_Mode = 'UPDATE'

     ARP_MESSAGE.SET_NAME('FII','FII_DELETING_TABLE');
     ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FII_CUST_ACCOUNTS',FALSE);
     l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

     OPEN Account_Merge_Records;
     LOOP

       FETCH Account_Merge_Records
       BULK COLLECT INTO Merge_Header_ID_List,
                         Cust_Account_ID_List,
                         Account_Owner_Party_ID_List,
                         Parent_Party_ID_List;

       IF Account_Merge_Records%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;

       IF Merge_Header_ID_List.COUNT = 0 and l_last_fetch THEN
         EXIT;
       END IF;

       IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
          FORALL i in 1..Merge_Header_ID_List.Count
           INSERT INTO HZ_Customer_Merge_Log(
             MERGE_LOG_ID,
             TABLE_NAME,
             MERGE_HEADER_ID,
             PRIMARY_KEY_ID1,
             PRIMARY_KEY_ID2,
             PRIMARY_KEY_ID3,
             DEL_COL1,
             DEL_COL2,
             DEL_COL3,
             ACTION_FLAG,
             REQUEST_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY)
           VALUES (
             HZ_Customer_Merge_Log_S.nextval,
             'FII_CUST_ACCOUNTS',
             Merge_Header_ID_List(i),
             Cust_Account_ID_List(i),
             Account_Owner_Party_ID_List(i),
             Parent_Party_ID_List(i),
             Cust_Account_ID_List(i),
             Account_Owner_Party_ID_List(i),
             Parent_Party_ID_List(i),
             'D',
             Req_ID,
             HZ_Utility_Pub.CREATED_BY,
             HZ_Utility_Pub.CREATION_DATE,
             HZ_Utility_Pub.LAST_UPDATE_LOGIN,
             HZ_Utility_Pub.LAST_UPDATE_DATE,
             HZ_Utility_Pub.LAST_UPDATED_BY);
       END IF;

       FORALL i in 1..Merge_Header_ID_List.Count
         DELETE FROM FII_Cust_Accounts
         WHERE Cust_Account_ID = Cust_Account_ID_List(i)
         AND Account_Owner_Party_ID = Account_Owner_Party_ID_List(i)
         AND Parent_Party_ID = Parent_Party_ID_List(i);

      IF l_last_fetch THEN
         EXIT;
      END IF;

     END LOOP;

     ARP_MESSAGE.SET_NAME('FII','FII_ROWS_DELETED');
     ARP_MESSAGE.SET_TOKEN('NUM_ROWS', To_Char(Merge_Header_ID_List.Count),FALSE);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ARP_MESSAGE.SET_LINE('MERGE_CUSTOMER_ACCOUNTS');
    RAISE;
END MERGE_CUSTOMER_ACCOUNTS;


End FII_AR_ACCOUNT_MERGE_PKG;

/
