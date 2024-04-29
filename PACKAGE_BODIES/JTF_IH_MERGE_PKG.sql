--------------------------------------------------------
--  DDL for Package Body JTF_IH_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_MERGE_PKG" AS
/* $Header: JTFIHAMB.pls 115.13 2003/02/20 15:24:04 ialeshin ship $ */
	G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_IH_MERGE_PKG';
PROCEDURE MERGE(req_id   IN NUMBER,
                set_number   IN NUMBER,
                process_mode IN VARCHAR2) IS

   error_message   varchar2(255);
   no_of_rows      NUMBER;
BEGIN
--   insert into testmerge(a1, a2) values (50,1);
   JTF_IH_MERGE(req_id, set_number, process_mode);

   error_message := ' Ending process for Interaction Activity Customer Account Merge ';
   arp_message.set_line(error_message);
END MERGE;

PROCEDURE JTF_IH_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ACTIVITY_ID_LIST_TYPE IS TABLE OF
         JTF_IH_ACTIVITIES.ACTIVITY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ACTIVITY_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         JTF_IH_ACTIVITIES.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ACTIVITY_ID
              ,CUST_ACCOUNT_ID
         FROM JTF_IH_ACTIVITIES yt, ra_customer_merges m
         WHERE (
            yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','JTF_IH_ACTIVITIES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);

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
         'JTF_IH_ACTIVITIES',
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

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE JTF_IH_ACTIVITIES yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ACTIVITY_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'JTF_IH_MERGE');
    RAISE;
END JTF_IH_MERGE;

END JTF_IH_MERGE_PKG;

/
