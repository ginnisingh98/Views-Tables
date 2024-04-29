--------------------------------------------------------
--  DDL for Package Body GMS_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_CMERGE" AS
-- $Header: gmscmrgb.pls 120.2 2006/04/03 23:48:04 lveerubh ship $


/*-------------------------------------------------------------
|
|  PROCEDURE
|      MERGE_AWARDS
|  DESCRIPTION :
|      Account merge procedure for the table, GMS_AWARDS
|
|--------------------------------------------------------------*/

PROCEDURE MERGE_AWARDS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE AWARD_ID_LIST_TYPE IS TABLE OF
         GMS_AWARDS.AWARD_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST AWARD_ID_LIST_TYPE;

  TYPE BILL_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
         GMS_AWARDS.BILL_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;

  TYPE SHIP_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
         GMS_AWARDS.SHIP_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;

  TYPE LOC_BILL_TO_ADD_ID_LIST_TYPE IS TABLE OF
         GMS_AWARDS.LOC_BILL_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST LOC_BILL_TO_ADD_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST LOC_BILL_TO_ADD_ID_LIST_TYPE;

  TYPE LOC_SHIP_TO_ADD_ID_LIST_TYPE IS TABLE OF
         GMS_AWARDS.LOC_SHIP_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST LOC_SHIP_TO_ADD_ID_LIST_TYPE;
  NUM_COL4_NEW_LIST LOC_SHIP_TO_ADD_ID_LIST_TYPE;

  TYPE BILL_TO_CUSTOMER_ID_LIST_TYPE IS TABLE OF
         GMS_AWARDS.BILL_TO_CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL5_ORIG_LIST BILL_TO_CUSTOMER_ID_LIST_TYPE;
  NUM_COL5_NEW_LIST BILL_TO_CUSTOMER_ID_LIST_TYPE;

  TYPE FUNDING_SOURCE_ID_LIST_TYPE IS TABLE OF
         GMS_AWARDS.FUNDING_SOURCE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL6_ORIG_LIST FUNDING_SOURCE_ID_LIST_TYPE;
  NUM_COL6_NEW_LIST FUNDING_SOURCE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,AWARD_ID
              ,BILL_TO_ADDRESS_ID
              ,SHIP_TO_ADDRESS_ID
              ,LOC_BILL_TO_ADDRESS_ID
              ,LOC_SHIP_TO_ADDRESS_ID
              ,BILL_TO_CUSTOMER_ID
              ,FUNDING_SOURCE_ID
         FROM GMS_AWARDS yt, ra_customer_merges m
         WHERE (
            yt.BILL_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.SHIP_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.LOC_BILL_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.LOC_SHIP_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.BILL_TO_CUSTOMER_ID = m.DUPLICATE_ID
            OR yt.FUNDING_SOURCE_ID = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','GMS_AWARDS',FALSE);
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
          LIMIT 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
	CLOSE merged_records;  --Bug 4710433
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL1_ORIG_LIST(I));

         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));

         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL3_ORIG_LIST(I));

         NUM_COL4_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL4_ORIG_LIST(I));

         NUM_COL5_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL5_ORIG_LIST(I));
         NUM_COL6_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL6_ORIG_LIST(I));
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
         'GMS_AWARDS',
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
      UPDATE GMS_AWARDS yt SET
           BILL_TO_ADDRESS_ID=NUM_COL1_NEW_LIST(I)
          ,SHIP_TO_ADDRESS_ID=NUM_COL2_NEW_LIST(I)
          ,LOC_BILL_TO_ADDRESS_ID=NUM_COL3_NEW_LIST(I)
          ,LOC_SHIP_TO_ADDRESS_ID=NUM_COL4_NEW_LIST(I)
          ,BILL_TO_CUSTOMER_ID=NUM_COL5_NEW_LIST(I)
          ,FUNDING_SOURCE_ID=NUM_COL6_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE AWARD_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'MERGE_AWARDS');
    RAISE;
END MERGE_AWARDS;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      MERGE_CONTACTS
|  DESCRIPTION :
|      Account merge procedure for the table, GMS_AWARDS_CONTACTS
|
|--------------------------------------------------------------*/

PROCEDURE MERGE_CONTACTS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE AWARD_ID_LIST_TYPE IS TABLE OF
         GMS_AWARDS_CONTACTS.AWARD_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST AWARD_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         GMS_AWARDS_CONTACTS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY2_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CONTACT_ID_LIST_TYPE IS TABLE OF
         GMS_AWARDS_CONTACTS.CONTACT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY3_LIST CONTACT_ID_LIST_TYPE;

  TYPE USAGE_CODE_LIST_TYPE IS TABLE OF
         GMS_AWARDS_CONTACTS.USAGE_CODE%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY4_LIST USAGE_CODE_LIST_TYPE;

  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,yt.AWARD_ID
              ,yt.CUSTOMER_ID
              ,yt.CONTACT_ID
              ,yt.USAGE_CODE
              ,yt.CUSTOMER_ID
         FROM GMS_AWARDS_CONTACTS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','GMS_AWARDS_CONTACTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY1_LIST
          , PRIMARY_KEY2_LIST
          , PRIMARY_KEY3_LIST
          , PRIMARY_KEY4_LIST
          , NUM_COL1_ORIG_LIST
          LIMIT 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
         CLOSE merged_records; --Bug 4710433
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
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           PRIMARY_KEY3,
           PRIMARY_KEY4,
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
         'GMS_AWARDS_CONTACTS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
         PRIMARY_KEY3_LIST(I),
         PRIMARY_KEY4_LIST(I),
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
      UPDATE GMS_AWARDS_CONTACTS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE AWARD_ID=PRIMARY_KEY1_LIST(I)
      AND CUSTOMER_ID=PRIMARY_KEY2_LIST(I)
      AND CONTACT_ID=PRIMARY_KEY3_LIST(I)
      AND USAGE_CODE=PRIMARY_KEY4_LIST(I)
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
    arp_message.set_line( 'MERGE_CONTACTS');
    RAISE;
END MERGE_CONTACTS;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      MERGE_REPORTS
|  DESCRIPTION :
|      Account merge procedure for the table, GMS_REPORTS
|
|--------------------------------------------------------------*/

PROCEDURE MERGE_REPORTS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE REPORT_ID_LIST_TYPE IS TABLE OF
         GMS_REPORTS.REPORT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST REPORT_ID_LIST_TYPE;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
         GMS_REPORTS.SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST SITE_USE_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,REPORT_ID
              ,SITE_USE_ID
         FROM GMS_REPORTS yt, ra_customer_merges m
         WHERE (
            yt.SITE_USE_ID = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','GMS_REPORTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          LIMIT 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
         CLOSE merged_records; --Bug 4710433
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST(I));
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
         'GMS_REPORTS',
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
      UPDATE GMS_REPORTS yt SET
           SITE_USE_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE REPORT_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'MERGE_REPORTS');
    RAISE;
END MERGE_REPORTS;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      MERGE_DEFAULT_REPORTS
|  DESCRIPTION :
|      Account merge procedure for the table, GMS_DEFAULT_REPORTS
|
|--------------------------------------------------------------*/

PROCEDURE MERGE_DEFAULT_REPORTS (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE DEFAULT_REPORT_ID_LIST_TYPE IS TABLE OF
         GMS_DEFAULT_REPORTS.DEFAULT_REPORT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST DEFAULT_REPORT_ID_LIST_TYPE;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
         GMS_DEFAULT_REPORTS.SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST SITE_USE_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,DEFAULT_REPORT_ID
              ,SITE_USE_ID
         FROM GMS_DEFAULT_REPORTS yt, ra_customer_merges m
         WHERE (
            yt.SITE_USE_ID = m.DUPLICATE_SITE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','GMS_DEFAULT_REPORTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          LIMIT 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
         CLOSE merged_records; --Bug 4710433
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST(I));
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
         'GMS_DEFAULT_REPORTS',
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
      UPDATE GMS_DEFAULT_REPORTS yt SET
           SITE_USE_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE DEFAULT_REPORT_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'MERGE_DEFAULT_REPORTS');
    RAISE;
END MERGE_DEFAULT_REPORTS;




  PROCEDURE MERGE ( req_id IN NUMBER, set_no IN NUMBER, process_mode IN VARCHAR2 ) IS
--
-- Calling the above procedures to update the tables with customer related data.
--

BEGIN

   MERGE_AWARDS(req_id =>  req_id,
                set_num => set_no,
                process_mode => process_mode);

   MERGE_CONTACTS(req_id =>  req_id,
                set_num => set_no,
                process_mode => process_mode);

   MERGE_REPORTS(req_id =>  req_id,
                set_num => set_no,
                process_mode => process_mode);

   MERGE_DEFAULT_REPORTS(req_id =>  req_id,
                set_num => set_no,
                process_mode => process_mode);

 END MERGE;

END GMS_CMERGE;

/
