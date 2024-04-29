--------------------------------------------------------
--  DDL for Package Body ARP_CMERGE_ARTAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CMERGE_ARTAX" as
/* $Header: ARPLTAXB.pls 120.4 2005/10/30 04:24:46 appldev ship $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count		NUMBER := 0;


/*--------------------------- PRIVATE ROUTINES ------------------------------*/
PROCEDURE ra_te (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE TAX_EXEMPTION_ID_LIST_TYPE IS TABLE OF
         RA_TAX_EXEMPTIONS.TAX_EXEMPTION_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST TAX_EXEMPTION_ID_LIST_TYPE;

  TYPE customer_id_LIST_TYPE IS TABLE OF
         RA_TAX_EXEMPTIONS.customer_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST customer_id_LIST_TYPE;
  NUM_COL1_NEW_LIST customer_id_LIST_TYPE;

  TYPE site_use_id_LIST_TYPE IS TABLE OF
         RA_TAX_EXEMPTIONS.site_use_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST site_use_id_LIST_TYPE;
  NUM_COL2_NEW_LIST site_use_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,TAX_EXEMPTION_ID
              ,yt.customer_id
              ,site_use_id
         FROM RA_TAX_EXEMPTIONS yt, ra_customer_merges m
         WHERE ( yt.customer_id = m.DUPLICATE_ID  AND
                 nvl(yt.site_use_id,m.DUPLICATE_SITE_ID) = m.DUPLICATE_SITE_ID)
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','RA_TAX_EXEMPTIONS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
            LIMIT ARP_CMERGE.max_array_size;/*Additional changes for 2447449*/
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
         'RA_TAX_EXEMPTIONS',
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
      UPDATE RA_TAX_EXEMPTIONS yt SET
           customer_id=NUM_COL1_NEW_LIST(I)
          ,site_use_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , REQUEST_ID=req_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE TAX_EXEMPTION_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'ra_te');
    RAISE;
END ra_te;



/*---------------------------- PUBLIC ROUTINES ------------------------------*/
PROCEDURE merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
BEGIN

  arp_message.set_line( 'ARP_CMERGE_ARTAX.MERGE()+' );

  ra_te( req_id, set_num, process_mode );

  arp_message.set_line( 'ARP_CMERGE_ARTAX.MERGE()-' );

END merge;

end ARP_CMERGE_ARTAX;

/
