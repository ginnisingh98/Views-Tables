--------------------------------------------------------
--  DDL for Package Body OTAP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTAP_CMERGE" as
/* $Header: otapcmer.pkb 120.0 2005/05/29 06:58:12 appldev noship $ */
--
--
/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count		NUMBER := 0;
--
--
--
/*--------------------------- PRIVATE ROUTINES ------------------------------*/
/*-------------------------------------------------------------
|
|  PROCEDURE
|      OTA_TBD
|  DESCRIPTION :
|      Account merge procedure for the table, OTA_BOOKING_DEALS
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE OTA_TBD (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE BOOKING_DEAL_ID_LIST_TYPE IS TABLE OF
         OTA_BOOKING_DEALS.BOOKING_DEAL_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST BOOKING_DEAL_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         OTA_BOOKING_DEALS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,BOOKING_DEAL_ID
              ,yt.CUSTOMER_ID
         FROM OTA_BOOKING_DEALS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OTA_BOOKING_DEALS',FALSE);
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
         'OTA_BOOKING_DEALS',
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
      UPDATE OTA_BOOKING_DEALS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE BOOKING_DEAL_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'OTA_TBD');
    RAISE;
END OTA_TBD;

--
/*-------------------------------------------------------------
|
|  PROCEDURE
|      OTA_TDB
|  DESCRIPTION :
|      Account merge procedure for the table, OTA_DELEGATE_BOOKINGS
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE OTA_TDB (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE BOOKING_ID_LIST_TYPE IS TABLE OF
         OTA_DELEGATE_BOOKINGS.BOOKING_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST BOOKING_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         OTA_DELEGATE_BOOKINGS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE THIRD_PARTY_CUST_ID_LIST_TYPE IS TABLE OF
         OTA_DELEGATE_BOOKINGS.THIRD_PARTY_CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST THIRD_PARTY_CUST_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST THIRD_PARTY_CUST_ID_LIST_TYPE;

  TYPE CONTACT_ADDRESS_ID_LIST_TYPE IS TABLE OF
         OTA_DELEGATE_BOOKINGS.CONTACT_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST CONTACT_ADDRESS_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST CONTACT_ADDRESS_ID_LIST_TYPE;

  TYPE THIRD_PARTY_ADDR_ID_LIST_TYPE IS TABLE OF
         OTA_DELEGATE_BOOKINGS.THIRD_PARTY_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST THIRD_PARTY_ADDR_ID_LIST_TYPE;
  NUM_COL4_NEW_LIST THIRD_PARTY_ADDR_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,BOOKING_ID
              ,yt.CUSTOMER_ID
              ,THIRD_PARTY_CUSTOMER_ID
              ,CONTACT_ADDRESS_ID
              ,THIRD_PARTY_ADDRESS_ID
         FROM OTA_DELEGATE_BOOKINGS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
            OR yt.THIRD_PARTY_CUSTOMER_ID = m.DUPLICATE_ID
            OR yt.CONTACT_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.THIRD_PARTY_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER  := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OTA_DELEGATE_BOOKINGS',FALSE);
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
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL3_ORIG_LIST(I));

         NUM_COL4_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL4_ORIG_LIST(I));

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
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OTA_DELEGATE_BOOKINGS',
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
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OTA_DELEGATE_BOOKINGS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          ,THIRD_PARTY_CUSTOMER_ID=NUM_COL2_NEW_LIST(I)
          ,CONTACT_ADDRESS_ID=NUM_COL3_NEW_LIST(I)
          ,THIRD_PARTY_ADDRESS_ID=NUM_COL4_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE BOOKING_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'OTA_TDB');
    RAISE;
END OTA_TDB;

--
/*-------------------------------------------------------------
|
|  PROCEDURE
|      OTA_TFH
|  DESCRIPTION :
|      Account merge procedure for the table, OTA_FINANCE_HEADERS
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE OTA_TFH (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE FINANCE_HEADER_ID_LIST_TYPE IS TABLE OF
         OTA_FINANCE_HEADERS.FINANCE_HEADER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST FINANCE_HEADER_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         OTA_FINANCE_HEADERS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

-- Bug 3590109 Address Merge
  TYPE ADDRESS_ID_LIST_TYPE IS TABLE OF
         OTA_FINANCE_HEADERS.ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ADDRESS_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST  ADDRESS_ID_LIST_TYPE;

  TYPE INVOICE_ADDR_STR_LIST_TYPE IS TABLE OF
         OTA_FINANCE_HEADERS.INVOICE_ADDRESS%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL1_ORIG_LIST INVOICE_ADDR_STR_LIST_TYPE;
  VCHAR_COL1_NEW_LIST  INVOICE_ADDR_STR_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,FINANCE_HEADER_ID
              ,yt.CUSTOMER_ID
              ,yt.ADDRESS_ID
              ,yt.INVOICE_ADDRESS
         FROM OTA_FINANCE_HEADERS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;

-- Bug 3590109 Address Merge, Address concat csr
  CURSOR csr_new_invoice_addr_str(NEW_CUST_ACCT_SITE_ID NUMBER) IS
  SELECT DISTINCT LOC.ADDRESS1||DECODE(LOC.ADDRESS1,NULL,'',', ')||
      LOC.ADDRESS2||DECODE(LOC.ADDRESS2,NULL,'',', ')||
      LOC.ADDRESS3|| DECODE(LOC.ADDRESS3,NULL,'',', ')||
      LOC.ADDRESS4||DECODE(LOC.ADDRESS4,NULL,'',', ')||
      LOC.CITY||DECODE(LOC.CITY,NULL, '',', ')||
      LOC.STATE||DECODE(LOC.STATE,NULL,'',', ')||
      LOC.PROVINCE||DECODE(LOC.PROVINCE,NULL,'',', ')||
      LOC.COUNTY||DECODE(LOC.COUNTY,NULL,'',', ')||
      LOC.POSTAL_CODE||DECODE(LOC.POSTAL_CODE,NULL,'',', ')||
      LOC.COUNTRY ADDRESS
FROM
      HZ_PARTY_SITES PARTY_SITE,
      HZ_LOCATIONS LOC,
      HZ_CUST_ACCT_SITES_ALL ACCT_SITE
WHERE
      LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
  AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
  AND ACCT_SITE.STATUS = 'A'
  AND ACCT_SITE.CUST_ACCT_SITE_ID = NEW_CUST_ACCT_SITE_ID;

  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
  l_new_invoice_addr_str VARCHAR2(200);
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OTA_FINANCE_HEADERS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , VCHAR_COL1_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         -- Bug 3590109 Address Merge
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));

         --Retrieve concat address for NUM_COL2_NEW_LIST(I)
         OPEN csr_new_invoice_addr_str(NUM_COL2_NEW_LIST(I));
         FETCH csr_new_invoice_addr_str into l_new_invoice_addr_str;
         IF csr_new_invoice_addr_str%FOUND THEN
            VCHAR_COL1_NEW_LIST(I) := l_new_invoice_addr_str;
         END IF;
         CLOSE csr_new_invoice_addr_str;

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
           --address bug
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OTA_FINANCE_HEADERS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         -- Bug 3590109 Address Merge
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         VCHAR_COL1_ORIG_LIST(I),
         VCHAR_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OTA_FINANCE_HEADERS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          -- Bug 3590109 Address Merge
          , ADDRESS_ID=NUM_COL2_NEW_LIST(I)
          , INVOICE_ADDRESS=VCHAR_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE FINANCE_HEADER_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'OTA_TFH');
    RAISE;
END OTA_TFH;

--
/*-------------------------------------------------------------
|
|  PROCEDURE
|      OTA_TEA
|  DESCRIPTION :
|      Account merge procedure for the table, OTA_EVENT_ASSOCIATIONS
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE OTA_TEA (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE EVENT_ASSOCIATION_ID_LIST_TYPE IS TABLE OF
         OTA_EVENT_ASSOCIATIONS.EVENT_ASSOCIATION_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST EVENT_ASSOCIATION_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         OTA_EVENT_ASSOCIATIONS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE EVENT_ID_LIST_TYPE IS TABLE OF
         OTA_EVENT_ASSOCIATIONS.EVENT_ID%TYPE
        INDEX BY BINARY_INTEGER;

  EVENT_ID_LIST EVENT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,EVENT_ASSOCIATION_ID
              ,yt.CUSTOMER_ID
              ,EVENT_ID
         FROM OTA_EVENT_ASSOCIATIONS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;

  CURSOR csr_duplicate_record(EVENT_ID NUMBER
                              ,TO_CUSTOMER NUMBER) IS
        SELECT NULL
         FROM OTA_EVENT_ASSOCIATIONS tea
         WHERE    tea.event_id = event_id
              AND tea.CUSTOMER_ID = TO_CUSTOMER;

  CURSOR csr_evt_assoc(P_EVENT_ASSOCIATION_ID NUMBER) IS
    select *
    from ota_event_associations
    where EVENT_ASSOCIATION_ID = P_EVENT_ASSOCIATION_ID;

  l_duplicate_result VARCHAR2(30);
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
  l_del_count NUMBER := 0;
  l_evt_assoc_rec csr_evt_assoc%rowtype;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OTA_EVENT_ASSOCIATIONS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST
          , EVENT_ID_LIST
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
        FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         --Duplicate check
         OPEN csr_duplicate_record(EVENT_ID_LIST(I), NUM_COL1_NEW_LIST(I));
	     FETCH csr_duplicate_record into l_duplicate_result;

         IF csr_duplicate_record%FOUND THEN

         --Retrieve OTA_EVENT_ASSOCIATIONS data for HZ_CUSTOMER_MERGE_LOG record
         OPEN csr_evt_assoc(PRIMARY_KEY_ID1_LIST(I));
         FETCH csr_evt_assoc into l_evt_assoc_rec;

         IF csr_evt_assoc%FOUND THEN
            INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           -- tea cols
           DEL_COL1,
           DEL_COL2,
           DEL_COL3,
           DEL_COL4,
           DEL_COL5,
           DEL_COL6,
           DEL_COL7,
           DEL_COL8,
           DEL_COL9,
           DEL_COL10,
           DEL_COL11,
           DEL_COL12,
           DEL_COL13,
           DEL_COL14,
           DEL_COL15,
           DEL_COL16,
           DEL_COL17,
           DEL_COL18,
           DEL_COL19,
           DEL_COL20,
           DEL_COL21,
           DEL_COL22,
           DEL_COL23,
           DEL_COL24,
           DEL_COL25,
           DEL_COL26,
           DEL_COL27,
           DEL_COL28,
           DEL_COL29,
           DEL_COL30,
           DEL_COL31,
           DEL_COL32,
           DEL_COL33,
           DEL_COL34,
           DEL_COL35,
           DEL_COL36,
           DEL_COL37,
           DEL_COL38,
           DEL_COL39,
           DEL_COL40,
           DEL_COL41,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval
         , 'OTA_EVENT_ASSOCIATIONS'
         , MERGE_HEADER_ID_LIST(I)
         , PRIMARY_KEY_ID1_LIST(I)
         , NUM_COL1_ORIG_LIST(I)
         , NUM_COL1_NEW_LIST(I)
         , 'D'
         , req_id
         --tea cols
        , l_evt_assoc_rec.EVENT_ASSOCIATION_ID
        , l_evt_assoc_rec.event_id
        , l_evt_assoc_rec.JOB_ID
        , l_evt_assoc_rec.POSITION_ID
        , l_evt_assoc_rec.CUSTOMER_ID
        , l_evt_assoc_rec.COMMENTS
        , l_evt_assoc_rec.LAST_UPDATE_DATE
        , l_evt_assoc_rec.LAST_UPDATED_BY
        , l_evt_assoc_rec.LAST_UPDATE_LOGIN
        , l_evt_assoc_rec.CREATED_BY
        , l_evt_assoc_rec.CREATION_DATE
        , l_evt_assoc_rec.TEA_INFORMATION_CATEGORY
        , l_evt_assoc_rec.TEA_INFORMATION1
        , l_evt_assoc_rec.TEA_INFORMATION2
        , l_evt_assoc_rec.TEA_INFORMATION3
        , l_evt_assoc_rec.TEA_INFORMATION4
        , l_evt_assoc_rec.TEA_INFORMATION5
        , l_evt_assoc_rec.TEA_INFORMATION6
        , l_evt_assoc_rec.TEA_INFORMATION7
        , l_evt_assoc_rec.TEA_INFORMATION8
        , l_evt_assoc_rec.TEA_INFORMATION9
        , l_evt_assoc_rec.TEA_INFORMATION10
        , l_evt_assoc_rec.TEA_INFORMATION11
        , l_evt_assoc_rec.TEA_INFORMATION12
        , l_evt_assoc_rec.TEA_INFORMATION13
        , l_evt_assoc_rec.TEA_INFORMATION14
        , l_evt_assoc_rec.TEA_INFORMATION15
        , l_evt_assoc_rec.TEA_INFORMATION16
        , l_evt_assoc_rec.TEA_INFORMATION17
        , l_evt_assoc_rec.TEA_INFORMATION18
        , l_evt_assoc_rec.TEA_INFORMATION19
        , l_evt_assoc_rec.TEA_INFORMATION20
        , l_evt_assoc_rec.CATEGORY_USAGE_ID
        , l_evt_assoc_rec.ACTIVITY_VERSION_ID
        , l_evt_assoc_rec.OFFERING_ID
        , l_evt_assoc_rec.SELF_ENROLLMENT_FLAG
        , l_evt_assoc_rec.MATCH_TYPE
        , l_evt_assoc_rec.PERSON_ID
        , l_evt_assoc_rec.PARTY_ID
        , l_evt_assoc_rec.LEARNING_PATH_ID
        , l_evt_assoc_rec.ORGANIZATION_ID
        , hz_utility_pub.CREATED_BY
        , hz_utility_pub.CREATION_DATE
        , hz_utility_pub.LAST_UPDATE_LOGIN
        , hz_utility_pub.LAST_UPDATE_DATE
        , hz_utility_pub.LAST_UPDATED_BY
          );
         --Purge the "Merge From" record
           DELETE OTA_EVENT_ASSOCIATIONS
           WHERE EVENT_ASSOCIATION_ID=PRIMARY_KEY_ID1_LIST(I)
         ;
           l_del_count := l_del_count + SQL%ROWCOUNT;
           -- remove table entries
           NUM_COL1_ORIG_LIST.DELETE(I);
           NUM_COL1_NEW_LIST.DELETE(I);
           PRIMARY_KEY_ID1_LIST.DELETE(I);
           MERGE_HEADER_ID_LIST.DELETE(I);
           --commit;
         END IF;
         CLOSE csr_evt_assoc;
        ELSE
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
         'OTA_EVENT_ASSOCIATIONS',
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
      CLOSE csr_duplicate_record;
      END LOOP;
    -- if audit is not enabled just remove the dupl recs from the pl/sql tables.
    ELSE
         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         OPEN csr_duplicate_record(EVENT_ID_LIST(I), NUM_COL1_NEW_LIST(I));
	     FETCH csr_duplicate_record into l_duplicate_result;

         IF csr_duplicate_record%FOUND THEN
           --Purge the "Merge From" record
           DELETE OTA_EVENT_ASSOCIATIONS
           WHERE EVENT_ASSOCIATION_ID=PRIMARY_KEY_ID1_LIST(I)
             ;
           l_del_count := l_del_count + SQL%ROWCOUNT;
           -- remove pl/sql table entries
           NUM_COL1_ORIG_LIST.DELETE(I);
           NUM_COL1_NEW_LIST.DELETE(I);
           PRIMARY_KEY_ID1_LIST.DELETE(I);
           MERGE_HEADER_ID_LIST.DELETE(I);
           --commit;
         END IF;
         CLOSE csr_duplicate_record;
         END LOOP;
    END IF;

    arp_message.set_name('AR','AR_ROWS_DELETED');
    arp_message.set_token('NUM_ROWS',to_char(l_del_count));

    FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
      IF MERGE_HEADER_ID_LIST.COUNT = 0 THEN
       exit;
      END IF;
      UPDATE OTA_EVENT_ASSOCIATIONS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE EVENT_ASSOCIATION_ID=PRIMARY_KEY_ID1_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'OTA_TEA');
    RAISE;
END OTA_TEA;

--
/*-------------------------------------------------------------
|
|  PROCEDURE
|      OTA_TNH
|  DESCRIPTION :
|      Account merge procedure for the table, OTA_NOTRNG_HISTORIES
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE OTA_TNH (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE NOTA_HISTORY_ID_LIST_TYPE IS TABLE OF
         OTA_NOTRNG_HISTORIES.NOTA_HISTORY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST NOTA_HISTORY_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         OTA_NOTRNG_HISTORIES.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,NOTA_HISTORY_ID
              ,yt.CUSTOMER_ID
         FROM OTA_NOTRNG_HISTORIES yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER := 0;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OTA_NOTRNG_HISTORIES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
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
         'OTA_NOTRNG_HISTORIES',
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
      UPDATE OTA_NOTRNG_HISTORIES yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE NOTA_HISTORY_ID=PRIMARY_KEY_ID1_LIST(I)
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
    arp_message.set_line( 'OTA_TNH');
    RAISE;
END OTA_TNH;

--
/*---------------------------- PUBLIC ROUTINES ------------------------------*/
--
PROCEDURE merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
--
BEGIN
--
  arp_message.set_line( 'OTAP_CMERGE.MERGE()+' );
--
  OTA_TDB( req_id, set_num, process_mode );
  OTA_TBD( req_id, set_num, process_mode );
-- Bug 3561222
--  OTA_TEA( req_id, set_num, process_mode );
  OTA_TFH( req_id, set_num, process_mode );
  OTA_TNH( req_id, set_num, process_mode );
-- Bug 3561222
  OTA_TEA( req_id, set_num, process_mode );
--
  arp_message.set_line( 'OTAP_CMERGE.MERGE()-' );
--
END merge;
--
--
end OTAP_CMERGE;

/
