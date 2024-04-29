--------------------------------------------------------
--  DDL for Package Body CS_SR_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_ACCOUNT_MERGE_PKG" AS
/* $Header: cssramgb.pls 115.2 2004/01/22 01:38:40 spusegao noship $ */

G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;

TYPE NUM_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_30_TBL IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

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
       arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS_ALL_B',FALSE );
  ELSE
     arp_message.set_name('AR', 'AR_UPDATING_TABLE');
   	arp_message.set_token('TABLE_NAME', 'CS_INCIDENTS_ALL_B',FALSE );

  END IF;

  ----Merge the CS_INCIDENTS table update the account_id

  message_text := '***-- Procedure CS_MERGE_CUSTOMER_ACCOUNT_ID --**';
  arp_message.set_line(message_text);

  ---dbms_output.put_line('am going to call small proc');

  CS_MERGE_CUST_ACCOUNT_ID( req_id, set_number, process_mode );

  message_text := '***-- End CS_MERGE_CUSTOMER_ACCOUNT_ID --**';
  arp_message.set_line(message_text);


  ---Report that the process for CS_INCIDENTS is complete

  IF ( process_mode = 'LOCK' ) Then
    message_text := '** LOCKING completed for table CS_INCIDENTS_ALL_B **';
    arp_message.set_line(message_text);
  ELSE
    message_text := '** MERGE completed for table CS_INCIDENTS_ALL_B **';
    arp_message.set_line(message_text);
  END IF;

  arp_message.set_line('CRM_MERGE.SR_MERGE()-');

END MERGE_CUST_ACCOUNTS;

-- The following procedure merges the following columns from CS_INCIDENTS_ALL_B
-- account_id
-- bill_to_account_id - added for 11.5.9
-- ship_to_account_id - added for 11.5.9

PROCEDURE CS_MERGE_CUST_ACCOUNT_ID (
        req_id                       NUMBER,
        set_number                   NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE INCIDENT_ID_LIST_TYPE IS TABLE OF
        CS_INCIDENTS_ALL_B.INCIDENT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST INCIDENT_ID_LIST_TYPE;

  TYPE ACCOUNT_ID_LIST_TYPE IS TABLE OF
        CS_INCIDENTS_ALL_B.ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST ACCOUNT_ID_LIST_TYPE;

  TYPE BILL_TO_ACCOUNT_ID_LIST_TYPE IS TABLE OF
        CS_INCIDENTS_ALL_B.BILL_TO_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST BILL_TO_ACCOUNT_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST BILL_TO_ACCOUNT_ID_LIST_TYPE;

  TYPE SHIP_TO_ACCOUNT_ID_LIST_TYPE IS TABLE OF
        CS_INCIDENTS_ALL_B.SHIP_TO_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST SHIP_TO_ACCOUNT_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST SHIP_TO_ACCOUNT_ID_LIST_TYPE;

  CURSOR merged_records IS
         SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,INCIDENT_ID
              ,ACCOUNT_ID
              ,BILL_TO_ACCOUNT_ID
              ,SHIP_TO_ACCOUNT_ID
              ,LAST_UPDATE_PROGRAM_CODE
         FROM CS_INCIDENTS_ALL_B yt,
	      ra_customer_merges m
         WHERE ( yt.ACCOUNT_ID = m.DUPLICATE_ID
	 OR yt.BILL_TO_ACCOUNT_ID = m.DUPLICATE_ID
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

  l_profile_val                VARCHAR2(30);
  g_customer_id		       RA_CUSTOMER_MERGES.CUSTOMER_ID%TYPE;
  g_duplicate_id	       RA_CUSTOMER_MERGES.DUPLICATE_ID%TYPE;

  g_cust_party_id	       HZ_PARTIES.PARTY_ID%TYPE;
  g_dup_party_id	       HZ_PARTIES.PARTY_ID%TYPE;

  g_different_parties	       VARCHAR2(1) := 'N';
  DIFFERENT_PARTIES	       EXCEPTION;
  l_last_fetch                 BOOLEAN     := FALSE;
  l_count                      NUMBER;
  l_last_update_program_code   VARCHAR2_30_TBL;
  l_audit_vals_rec             CS_ServiceRequest_PVT.SR_AUDIT_REC_TYPE;
  l_audit_id                   NUMBER ;
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(1000);
  l_return_status              VARCHAR2(3);

BEGIN
   IF process_mode='LOCK' THEN
      NULL;
   ELSE
      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CS_INCIDENTS_ALL_B',FALSE);

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
          , NUM_COL3_ORIG_LIST
          , L_LAST_UPDATE_PROGRAM_CODE
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
            NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL3_ORIG_LIST(I));
         END LOOP;

         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN

            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            INSERT INTO HZ_CUSTOMER_MERGE_LOG (
               MERGE_LOG_ID,                        TABLE_NAME,
	       MERGE_HEADER_ID,                     PRIMARY_KEY_ID,
	       NUM_COL1_ORIG,                       NUM_COL1_NEW,
               NUM_COL2_ORIG,                       NUM_COL2_NEW,
	       NUM_COL3_ORIG,                       NUM_COL3_NEW,
	       ACTION_FLAG,                         REQUEST_ID,
               CREATED_BY,                          CREATION_DATE,
	       LAST_UPDATE_LOGIN,                   LAST_UPDATE_DATE,
	       LAST_UPDATED_BY )
            VALUES (
	       HZ_CUSTOMER_MERGE_LOG_s.nextval,     'CS_INCIDENTS_ALL_B',
	       MERGE_HEADER_ID_LIST(I),             PRIMARY_KEY_ID_LIST(I),
	       NUM_COL1_ORIG_LIST(I),               NUM_COL1_NEW_LIST(I),
               NUM_COL2_ORIG_LIST(I),               NUM_COL2_NEW_LIST(I),
	       NUM_COL3_ORIG_LIST(I),               NUM_COL3_NEW_LIST(I),
	       'U',                                 req_id,
               hz_utility_pub.CREATED_BY,           hz_utility_pub.CREATION_DATE,
	       hz_utility_pub.LAST_UPDATE_LOGIN,    hz_utility_pub.LAST_UPDATE_DATE,
	       hz_utility_pub.LAST_UPDATED_BY );

         END IF;

         FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            UPDATE CS_INCIDENTS_ALL_B yt SET
               ACCOUNT_ID              = NUM_COL1_NEW_LIST(I)
             , BILL_TO_ACCOUNT_ID      = NUM_COL2_NEW_LIST(I)
             , SHIP_TO_ACCOUNT_ID      = NUM_COL3_NEW_LIST(I)
             , LAST_UPDATE_PROGRAM_CODE = 'ACCOUNT_MERGE'
             , INCIDENT_LAST_MODIFIED_DATE = SYSDATE
             , LAST_UPDATE_DATE        = SYSDATE
             , last_updated_by         = arp_standard.profile.user_id
             , last_update_login       = arp_standard.profile.last_update_login
             , REQUEST_ID              = req_id
             , PROGRAM_APPLICATION_ID  = arp_standard.profile.program_application_id
             , PROGRAM_ID              = arp_standard.profile.program_id
             , PROGRAM_UPDATE_DATE     = SYSDATE
         WHERE INCIDENT_ID=PRIMARY_KEY_ID_LIST(I) ;

         l_count := l_count + SQL%ROWCOUNT;
         -- create audit record in cs_incidents_audit_b table for each service
         -- request for which account_id, bill_to_account_id or ship_to_account_id is updated.

         FOR i IN 1..PRIMARY_KEY_ID_LIST.COUNT

            LOOP

                CS_Servicerequest_UTIL.Prepare_Audit_Record (
                      p_api_version          => 1,
                      p_request_id           => PRIMARY_KEY_ID_LIST(I),
                      x_return_status        => l_return_status,
                      x_msg_count            => l_msg_count,
                      x_msg_data             => l_msg_data,
                      x_audit_vals_rec       => l_audit_vals_rec );

                IF l_return_status <> FND_API.G_RET_STS_ERROR THEN

                   -- set the account_id /old_ account_id of audit record

                   IF NUM_COL1_ORIG_LIST(i) = NUM_COL1_NEW_LIST(i) THEN
                      l_audit_vals_rec.account_id		:= NUM_COL1_NEW_LIST(i) ;
                      l_audit_vals_rec.old_account_id	        := NUM_COL1_NEW_LIST(i);
                   ELSE
                      l_audit_vals_rec.account_id		:= NUM_COL1_NEW_LIST(i);
                      l_audit_vals_rec.old_account_id	        := NUM_COL1_ORIG_LIST(i);
                   END IF;

                   -- set the bill_to_account_id /old_bill_to_account_id of audit record

                   IF NUM_COL2_ORIG_LIST(i) = NUM_COL2_NEW_LIST(i) THEN
                      l_audit_vals_rec.bill_to_account_id	:= NUM_COL2_NEW_LIST(i);
                      l_audit_vals_rec.old_bill_to_account_id 	:= NUM_COL2_NEW_LIST(i);
                   ELSE
                      l_audit_vals_rec.bill_to_account_id	:= NUM_COL2_NEW_LIST(i);
                      l_audit_vals_rec.old_bill_to_account_id	:= NUM_COL2_ORIG_LIST(i);
                   END IF;

                   -- set the customer_email_id /old_customer_email_id of audit record

                   IF NUM_COL3_ORIG_LIST(i) = NUM_COL2_NEW_LIST(i)  THEN
                      l_audit_vals_rec.ship_to_account_id	:= NUM_COL2_NEW_LIST(i)  ;
                      l_audit_vals_rec.old_ship_to_account_id 	:= NUM_COL2_NEW_LIST(i);
                   ELSE
                      l_audit_vals_rec.ship_to_account_id	:= NUM_COL2_NEW_LIST(i);
                      l_audit_vals_rec.old_ship_to_account_id	:= NUM_COL2_ORIG_LIST(i) ;
                   END IF;

                   -- set the last_program_code/old_last_progream_code of audit record
                    l_audit_vals_rec.last_update_program_code 	:= 'ACCOUNT_MERGE' ;
                    l_audit_vals_rec.old_last_update_program_code 	:= l_last_update_program_code (i);
                    l_audit_vals_rec.updated_entity_code 		:= 'SR_HEADER';
                    l_audit_vals_rec.updated_entity_id 		:= PRIMARY_KEY_ID_LIST(I);
                    l_audit_vals_rec.entity_activity_code 		:= 'U' ;
                END IF;

                CS_ServiceRequest_PVT.Create_Audit_Record (
                               p_api_version         	=> 2.0,
                               x_return_status       	=> l_return_status,
                               x_msg_count           	=> l_msg_count,
                               x_msg_data            	=> l_msg_data,
                               p_request_id          	=> PRIMARY_KEY_ID_LIST(I),
                               p_audit_id            	=> NULL,
                               p_audit_vals_rec      	=> l_audit_vals_rec              ,
                               p_user_id             	=> G_USER_ID,
                               p_login_id            	=> G_LOGIN_ID,
                               p_last_update_date    	=> SYSDATE,
                               p_creation_date       	=> SYSDATE,
                               p_comments            	=> NULL,
                               x_audit_id            	=> l_audit_id);

              END LOOP;


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
     arp_message.set_line( 'CS_MERGE_CUST_ACCOUNT_ID');
     RAISE;

END CS_MERGE_CUST_ACCOUNT_ID;

END CS_SR_ACCOUNT_MERGE_PKG  ;


/
