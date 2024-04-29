--------------------------------------------------------
--  DDL for Package Body CS_CH_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CH_ACCOUNT_MERGE_PKG" AS
/* $Header: cschmagb.pls 115.0 2003/05/08 21:21:22 mviswana noship $ */


PROCEDURE MERGE_CUST_ACCOUNTS (req_id       IN NUMBER,
                               set_number   IN NUMBER,
                               process_mode IN VARCHAR2 ) IS

   message_text          varchar2(255);
   number_of_rows        NUMBER;

BEGIN

  ---Put the header in the report to identify the block to be run

  arp_message.set_line('CRM_MERGE.SR_MERGE()+');

  IF ( process_mode = 'LOCK' ) Then
       arp_message.set_name('AR', 'AR_LOCKING_TABLE');
       arp_message.set_token('TABLE_NAME', 'CS_ESTIMATE_DETAILS',FALSE );
  ELSE
     arp_message.set_name('AR', 'AR_UPDATING_TABLE');
   	arp_message.set_token('TABLE_NAME', 'CS_ESTIMATE_DETAILS',FALSE );

  END IF;

  ----Merge the CS_ESTIMATE_DETAILS table update the account_id

  message_text := '***-- Procedure CS_CH_MERGE_CUST_ACCOUNT_ID --**';
  arp_message.set_line(message_text);

  ---dbms_output.put_line('am going to call small proc');

  CS_CH_MERGE_CUST_ACCOUNT_ID( req_id, set_number, process_mode );

  message_text := '***-- End CS_CH_MERGE_CUST_ACCOUNT_ID --**';
  arp_message.set_line(message_text);


  ---Report that the process for CS_ESTIMATE_DETAILS is complete

  IF ( process_mode = 'LOCK' ) Then
    message_text := '** LOCKING completed for table CS_ESTIMATE_DETAILS **';
    arp_message.set_line(message_text);
  ELSE
    message_text := '** MERGE completed for table CS_ESTIMATE_DETAILS **';
    arp_message.set_line(message_text);
  END IF;

  arp_message.set_line('CRM_MERGE.SR_MERGE()-');

END MERGE_CUST_ACCOUNTS;

-- The following procedure merges the following columns from CS_ESTIMATE_DETAILS
-- account_id
-- invoice_to_account_id - added for 11.5.9
-- ship_to_account_id - added for 11.5.9

PROCEDURE CS_CH_MERGE_CUST_ACCOUNT_ID (
        req_id                       NUMBER,
        set_number                   NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ESTIMATE_DETAIL_ID_LIST_TYPE IS TABLE OF
        CS_ESTIMATE_DETAILS.ESTIMATE_DETAIL_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ESTIMATE_DETAIL_ID_LIST_TYPE;

  TYPE INVOICE_TO_ACCT_ID_LIST_TYPE IS TABLE OF
        CS_ESTIMATE_DETAILS.INVOICE_TO_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST INVOICE_TO_ACCT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST INVOICE_TO_ACCT_ID_LIST_TYPE;

  TYPE SHIP_TO_ACCT_ID_LIST_TYPE IS TABLE OF
        CS_ESTIMATE_DETAILS.SHIP_TO_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SHIP_TO_ACCT_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SHIP_TO_ACCT_ID_LIST_TYPE;

  CURSOR merged_records IS
         SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ESTIMATE_DETAIL_ID
              ,INVOICE_TO_ACCOUNT_ID
              ,SHIP_TO_ACCOUNT_ID
         FROM CS_ESTIMATE_DETAILS yt,
	      ra_customer_merges m
         WHERE (  yt.INVOICE_TO_ACCOUNT_ID = m.DUPLICATE_ID
                 OR yt.SHIP_TO_ACCOUNT_ID = m.DUPLICATE_ID)
         AND    m.process_flag = 'N'
         AND    m.request_id   = req_id
         AND    m.set_number   = set_number;

  CURSOR PARTY_CUR(p_cust_account_id NUMBER)is
         SELECT PARTY_ID
         FROM HZ_CUST_ACCOUNTS HCA
         WHERE cust_account_id = p_cust_account_id;

  CURSOR CUST_MERGE_CUR(req_id NUMBER, set_num NUMBER) IS
 	 select CUSTOMER_ID, DUPLICATE_ID
	 from   RA_CUSTOMER_MERGES RCM
	 Where  rcm.request_id   = req_id
	 And    rcm.set_number   = set_number
	 And    rcm.process_flag = 'N';

  l_profile_val                         VARCHAR2(30);
  g_customer_id				RA_CUSTOMER_MERGES.CUSTOMER_ID%TYPE;
  g_duplicate_id			RA_CUSTOMER_MERGES.DUPLICATE_ID%TYPE;

  g_cust_party_id			HZ_PARTIES.PARTY_ID%TYPE;
  g_dup_party_id			HZ_PARTIES.PARTY_ID%TYPE;

  g_different_parties		        VARCHAR2(1) := 'N';
  DIFFERENT_PARTIES			EXCEPTION;

  l_last_fetch                          BOOLEAN     := FALSE;
  l_count                               NUMBER;


BEGIN
   IF process_mode='LOCK' THEN
      NULL;
   ELSE
      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME',' CS_ESTIMATE_DETAILS',FALSE);

      HZ_ACCT_MERGE_UTIL.load_set(set_number, req_id);
      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');


      Open CUST_MERGE_CUR(Req_Id, Set_Number);
      Loop
         Fetch CUST_MERGE_CUR
         into  g_customer_id,g_duplicate_id;

         EXIT WHEN CUST_MERGE_CUR%NOTFOUND;

         Open  PARTY_CUR(g_customer_id);
         Fetch PARTY_CUR into g_cust_party_id;
         Close PARTY_CUR;

         Open  PARTY_CUR(g_duplicate_id);
         Fetch PARTY_CUR into g_dup_party_id;
         Close PARTY_CUR;

         If g_cust_party_id <> g_dup_party_id Then
            g_different_parties := 'Y';
         End If;
      End Loop;

      Close CUST_MERGE_CUR;

      open merged_records;

      LOOP
         FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          limit 1000;

         IF merged_records%NOTFOUND THEN
            l_last_fetch := TRUE;
         END IF;

         IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
           exit;
         END IF;

         IF (MERGE_HEADER_ID_LIST.COUNT > 0 AND g_different_parties = 'Y' ) THEN
         Close merged_records;
         Raise DIFFERENT_PARTIES;
         END IF;

         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
            NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
            NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
         END LOOP;

         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN

            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            INSERT INTO HZ_CUSTOMER_MERGE_LOG (
               MERGE_LOG_ID,                        TABLE_NAME,
	       MERGE_HEADER_ID,                     PRIMARY_KEY_ID,
	       NUM_COL1_ORIG,                       NUM_COL1_NEW,
               NUM_COL2_ORIG,                       NUM_COL2_NEW,
	       ACTION_FLAG,                         REQUEST_ID,
               CREATED_BY,                          CREATION_DATE,
	       LAST_UPDATE_LOGIN,                   LAST_UPDATE_DATE,
	       LAST_UPDATED_BY )
            VALUES (
	       HZ_CUSTOMER_MERGE_LOG_s.nextval,     'CS_ESTIMATE_DETAILS',
	       MERGE_HEADER_ID_LIST(I),             PRIMARY_KEY_ID_LIST(I),
	       NUM_COL1_ORIG_LIST(I),               NUM_COL1_NEW_LIST(I),
               NUM_COL2_ORIG_LIST(I),               NUM_COL2_NEW_LIST(I),
	       'U',                                 req_id,
               hz_utility_pub.CREATED_BY,           hz_utility_pub.CREATION_DATE,
	       hz_utility_pub.LAST_UPDATE_LOGIN,    hz_utility_pub.LAST_UPDATE_DATE,
	       hz_utility_pub.LAST_UPDATED_BY );

         END IF;

         FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            UPDATE CS_ESTIMATE_DETAILS  yt SET
               INVOICE_TO_ACCOUNT_ID      = NUM_COL1_NEW_LIST(I)
             , SHIP_TO_ACCOUNT_ID      = NUM_COL2_NEW_LIST(I)
             , LAST_UPDATE_DATE        = SYSDATE
             , last_updated_by         = arp_standard.profile.user_id
             , last_update_login       = arp_standard.profile.last_update_login
         WHERE ESTIMATE_DETAIL_ID=PRIMARY_KEY_ID_LIST(I) ;

         l_count := l_count + SQL%ROWCOUNT;

         IF l_last_fetch THEN
            EXIT;
         END IF;

       END LOOP;

       arp_message.set_name('AR','AR_ROWS_UPDATED');
       arp_message.set_token('NUM_ROWS',to_char(l_count));
   END IF;

EXCEPTION
   WHEN DIFFERENT_PARTIES THEN
      arp_message.set_name('CS','CS_ACCT_MERGE_NOT_ALLOWED');
      RAISE;

  WHEN OTHERS THEN
     arp_message.set_line( 'CS_CH_MERGE_CUST_ACCOUNT_ID');
     RAISE;

END CS_CH_MERGE_CUST_ACCOUNT_ID;

END CS_CH_ACCOUNT_MERGE_PKG  ;


/
