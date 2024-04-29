--------------------------------------------------------
--  DDL for Package Body CN_CUST_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CUST_MERGE_PVT" AS
  --$Header: cnvctmgb.pls 120.6 2007/10/26 13:55:40 rarajara ship $

PROCEDURE MERGE_CUSTOMER_IN_HEADER (req_id                       NUMBER,
                                    set_num                      NUMBER,
                                    process_mode                 VARCHAR2) IS

   TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
     RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
     INDEX BY BINARY_INTEGER;
   MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

   TYPE COMMISSION_HEADER_ID_LIST_TYPE IS TABLE OF
     CN_COMMISSION_HEADERS.COMMISSION_HEADER_ID%TYPE
     INDEX BY BINARY_INTEGER;
   PRIMARY_KEY_ID_LIST COMMISSION_HEADER_ID_LIST_TYPE;

   TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
     CN_COMMISSION_HEADERS.CUSTOMER_ID%TYPE
     INDEX BY BINARY_INTEGER;
   NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
   NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

   TYPE BILL_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
     CN_COMMISSION_HEADERS.BILL_TO_ADDRESS_ID%TYPE
     INDEX BY BINARY_INTEGER;
   NUM_COL2_ORIG_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;
   NUM_COL2_NEW_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;

   TYPE SHIP_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
     CN_COMMISSION_HEADERS.SHIP_TO_ADDRESS_ID%TYPE
     INDEX BY BINARY_INTEGER;
   NUM_COL3_ORIG_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;
   NUM_COL3_NEW_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;

   l_profile_val VARCHAR2(30);
   l_custmerge_profile_value varchar2(1);

   CURSOR merged_records IS
     SELECT distinct CUSTOMER_MERGE_HEADER_ID
       ,yt.COMMISSION_HEADER_ID
       ,yt.CUSTOMER_ID
       ,yt.BILL_TO_ADDRESS_ID
       ,yt.SHIP_TO_ADDRESS_ID
       FROM CN_COMMISSION_HEADERS_ALL yt, ra_customer_merges m
       WHERE (
       yt.CUSTOMER_ID = m.DUPLICATE_ID
       OR ((yt.BILL_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID)
       AND
       (m.duplicate_site_code = 'BILL_TO'))
       OR ((yt.SHIP_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID)
       AND
       (m.duplicate_site_code = 'SHIP_TO'))
             ) AND   ( m.process_flag = 'N' OR l_custmerge_profile_value = 'N')
       AND    m.request_id = req_id
       AND    m.set_number = set_num
       ;

   CURSOR CUST(p_duplicate_cust_id NUMBER) IS
      SELECT distinct customer_id
      FROM ra_customer_merges
      WHERE set_number = set_num
      AND request_id = req_id
      AND duplicate_id = p_duplicate_cust_id;

   CURSOR ADDR(p_duplicate_addr_id NUMBER) IS
      SELECT distinct customer_address_id
      FROM ra_customer_merges
      WHERE set_number = set_num
      AND request_id = req_id
      AND duplicate_address_id = p_duplicate_addr_id;

   CURSOR SITE(p_duplicate_site_id NUMBER) IS
      SELECT distinct customer_site_id
      FROM ra_customer_merges
      WHERE set_number = set_num
      AND request_id = req_id
      AND duplicate_site_id = p_duplicate_site_id;


     l_last_fetch BOOLEAN := FALSE;
     l_count NUMBER;
BEGIN

   l_custmerge_profile_value := FND_PROFILE.VALUE('CN_CUSTOMER_MERGE_ONLINE');

   IF l_custmerge_profile_value is null OR l_custmerge_profile_value = fnd_api.g_miss_CHAR THEN
   	l_custmerge_profile_value := 'Y';
   END IF;

   IF process_mode='LOCK' THEN
      NULL;
   ELSE

      IF l_custmerge_profile_value = 'Y' THEN
      	ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      	ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CN_COMMISSION_HEADERS',FALSE);
      	HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
      END IF;

      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');


      open merged_records;
      LOOP
         FETCH merged_records BULK COLLECT INTO
           MERGE_HEADER_ID_LIST
           , PRIMARY_KEY_ID_LIST
           , NUM_COL1_ORIG_LIST
           , NUM_COL2_ORIG_LIST
           , NUM_COL3_ORIG_LIST
           limit 1000;
         IF merged_records%NOTFOUND THEN

            l_last_fetch := TRUE;
         END IF;

         IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
            exit;
         END IF;



         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
            IF 'Y' = l_custmerge_profile_value THEN --replace this with profile value
            NUM_COL1_NEW_LIST(I) :=
              HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
            NUM_COL2_NEW_LIST(I) :=
              HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));
            NUM_COL3_NEW_LIST(I) :=
              HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL3_ORIG_LIST(I));
           ELSE

             open CUST(NUM_COL1_ORIG_LIST(I));
             open ADDR(NUM_COL2_ORIG_LIST(I));
             open SITE(NUM_COL3_ORIG_LIST(I));
                fetch CUST into NUM_COL1_NEW_LIST(I);
		IF CUST%NOTFOUND THEN
		NUM_COL1_NEW_LIST(I) := NULL;
		END IF;
		fetch ADDR into NUM_COL2_NEW_LIST(I);
		IF ADDR%NOTFOUND THEN
		NUM_COL2_NEW_LIST(I) := NULL;
		END IF;
		fetch SITE into NUM_COL3_NEW_LIST(I);
		IF SITE%NOTFOUND THEN
		NUM_COL3_NEW_LIST(I) := NULL;
                END IF;
             close CUST;
             close ADDR;
             close SITE;
            END IF;

         END LOOP;


         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
              INSERT INTO HZ_CUSTOMER_MERGE_LOG
              (
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
              ACTION_FLAG,
              REQUEST_ID,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY
              ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
              'CN_COMMISSION_HEADERS',
              MERGE_HEADER_ID_LIST(I),
              PRIMARY_KEY_ID_LIST(I),
              NUM_COL1_ORIG_LIST(I),
              NUM_COL1_NEW_LIST(I),
              NUM_COL2_ORIG_LIST(I),
              NUM_COL2_NEW_LIST(I),
              NUM_COL3_ORIG_LIST(I),
              NUM_COL3_NEW_LIST(I),
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
           UPDATE CN_COMMISSION_HEADERS_ALL yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
           ,BILL_TO_ADDRESS_ID=NUM_COL2_NEW_LIST(I)
           ,SHIP_TO_ADDRESS_ID=NUM_COL3_NEW_LIST(I)
           , LAST_UPDATE_DATE=SYSDATE
           , last_updated_by=arp_standard.profile.user_id
           , last_update_login=arp_standard.profile.last_update_login
           WHERE COMMISSION_HEADER_ID=PRIMARY_KEY_ID_LIST(I)
           ;
         l_count := l_count + SQL%ROWCOUNT;
         IF l_last_fetch THEN
            EXIT;
         END IF;
      END LOOP;

      IF l_custmerge_profile_value = 'Y' THEN
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
--     arp_message.set_line( 'MERGE_CUSTOMER_IN_HEADER');
     RAISE;
END MERGE_CUSTOMER_IN_HEADER;

PROCEDURE MERGE_CUSTOMER_IN_API (req_id                       NUMBER,
                                 set_num                      NUMBER,
                                 process_mode                 VARCHAR2) IS

   TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
     RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
     INDEX BY BINARY_INTEGER;
   MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

   TYPE COMM_LINES_API_ID_LIST_TYPE IS TABLE OF
     CN_COMM_LINES_API.COMM_LINES_API_ID%TYPE
     INDEX BY BINARY_INTEGER;
   PRIMARY_KEY_ID_LIST COMM_LINES_API_ID_LIST_TYPE;

   TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
     CN_COMM_LINES_API.CUSTOMER_ID%TYPE
     INDEX BY BINARY_INTEGER;
   NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
   NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

   TYPE BILL_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
     CN_COMM_LINES_API.BILL_TO_ADDRESS_ID%TYPE
     INDEX BY BINARY_INTEGER;
   NUM_COL2_ORIG_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;
   NUM_COL2_NEW_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;

   TYPE SHIP_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
     CN_COMM_LINES_API.SHIP_TO_ADDRESS_ID%TYPE
     INDEX BY BINARY_INTEGER;
   NUM_COL3_ORIG_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;
   NUM_COL3_NEW_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;

   l_profile_val VARCHAR2(30);
   l_custmerge_profile_value VARCHAR2(1);

   CURSOR merged_records IS
     SELECT distinct CUSTOMER_MERGE_HEADER_ID
       ,yt.COMM_LINES_API_ID
       ,yt.CUSTOMER_ID
       ,yt.BILL_TO_ADDRESS_ID
       ,yt.SHIP_TO_ADDRESS_ID
       FROM CN_COMM_LINES_API_ALL yt, ra_customer_merges m
       WHERE (
       yt.CUSTOMER_ID = m.DUPLICATE_ID
       OR ((yt.BILL_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID)
       AND
       (m.duplicate_site_code = 'BILL_TO'))
       OR ((yt.SHIP_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID)
       AND
       (m.duplicate_site_code = 'SHIP_TO'))
             ) AND    ( m.process_flag = 'N' OR l_custmerge_profile_value = 'N')
       AND    m.request_id = req_id
       AND    m.set_number = set_num;

   CURSOR CUST(p_duplicate_cust_id NUMBER) IS
      SELECT distinct customer_id
      FROM ra_customer_merges
      WHERE set_number = set_num
      AND request_id = req_id
      AND DUPLICATE_ID = p_duplicate_cust_id;

   CURSOR ADDR(p_duplicate_addr_id NUMBER) IS
      SELECT distinct customer_address_id
      FROM ra_customer_merges
      WHERE set_number = set_num
      AND request_id = req_id
      AND duplicate_address_id = p_duplicate_addr_id;

   CURSOR SITE(p_duplicate_site_id NUMBER) IS
      SELECT distinct customer_site_id
      FROM ra_customer_merges
      WHERE set_number = set_num
      AND request_id = req_id
      AND duplicate_site_id = p_duplicate_site_id;

     l_last_fetch BOOLEAN := FALSE;
     l_count NUMBER;
BEGIN
   l_custmerge_profile_value := FND_PROFILE.VALUE('CN_CUSTOMER_MERGE_ONLINE');

   IF l_custmerge_profile_value is null OR l_custmerge_profile_value = fnd_api.g_miss_CHAR THEN
      	l_custmerge_profile_value := 'Y';
   END IF;

   IF process_mode='LOCK' THEN
      NULL;
   ELSE

   IF l_custmerge_profile_value = 'Y' THEN
      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CN_COMM_LINES_API',FALSE);
      HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
   END IF;

      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

      open merged_records;
      LOOP
         FETCH merged_records BULK COLLECT INTO
           MERGE_HEADER_ID_LIST
           , PRIMARY_KEY_ID_LIST
           , NUM_COL1_ORIG_LIST
           , NUM_COL2_ORIG_LIST
           , NUM_COL3_ORIG_LIST
           limit 1000;
         IF merged_records%NOTFOUND THEN
            l_last_fetch := TRUE;
         END IF;

         IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
            exit;
         END IF;

         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
            IF 'Y' =  l_custmerge_profile_value THEN --replace this with profile value
                NUM_COL1_NEW_LIST(I) :=
                HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
                NUM_COL2_NEW_LIST(I) :=
                HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));
                NUM_COL3_NEW_LIST(I) :=
                HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL3_ORIG_LIST(I));
            ELSE
             open CUST(NUM_COL1_ORIG_LIST(I));
             open ADDR(NUM_COL2_ORIG_LIST(I));
             open SITE(NUM_COL3_ORIG_LIST(I));
                fetch CUST into NUM_COL1_NEW_LIST(I);
                IF CUST%NOTFOUND THEN
                NUM_COL1_NEW_LIST(I) := NULL;
                END IF;
                fetch ADDR into NUM_COL2_NEW_LIST(I);
                IF ADDR%NOTFOUND THEN
		NUM_COL2_NEW_LIST(I) := NULL;
                END IF;
                fetch SITE into NUM_COL3_NEW_LIST(I);
                IF SITE%NOTFOUND THEN
		NUM_COL3_NEW_LIST(I) := NULL;
                END IF;
             close CUST;
             close ADDR;
             close SITE;

            END IF;

         END LOOP;


         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
              INSERT INTO HZ_CUSTOMER_MERGE_LOG
              (
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
              ACTION_FLAG,
              REQUEST_ID,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY
              ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
              'CN_COMM_LINES_API',
              MERGE_HEADER_ID_LIST(I),
              PRIMARY_KEY_ID_LIST(I),
              NUM_COL1_ORIG_LIST(I),
              NUM_COL1_NEW_LIST(I),
              NUM_COL2_ORIG_LIST(I),
              NUM_COL2_NEW_LIST(I),
              NUM_COL3_ORIG_LIST(I),
              NUM_COL3_NEW_LIST(I),
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
           UPDATE CN_COMM_LINES_API_ALL yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
           ,BILL_TO_ADDRESS_ID=NUM_COL2_NEW_LIST(I)
           ,SHIP_TO_ADDRESS_ID=NUM_COL3_NEW_LIST(I)
           , LAST_UPDATE_DATE=SYSDATE
           , last_updated_by=arp_standard.profile.user_id
           , last_update_login=arp_standard.profile.last_update_login
           WHERE COMM_LINES_API_ID=PRIMARY_KEY_ID_LIST(I)
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
     arp_message.set_line( 'MERGE_CUSTOMER_IN_API');
     RAISE;
END MERGE_CUSTOMER_IN_API;


PROCEDURE populate_customer_merge(req_id                       NUMBER,
                                 set_num                      NUMBER,
                                 process_mode                 VARCHAR2) IS
          l_profile_val VARCHAR2(30);
          l_count number;
BEGIN
   IF process_mode='LOCK' THEN
      NULL;
   ELSE

      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CN_CUST_MERGE_INTERFACE',FALSE);

      Insert into   CN_CUST_MERGE_INTERFACE
      (
       request_id
      ,set_number
      ,process_mode
      ,STATUS
      )
      values
       (req_id
       ,set_num
       ,process_mode
       ,'I'
       );

   END IF;
EXCEPTION
   WHEN OTHERS THEN

     --arp_message.set_line( 'MERGE_CUSTOMER_IN_API');
     RAISE;
END populate_customer_merge;

procedure customer_merge (req_id NUMBER,
                          set_number NUMBER,
                          process_mode VARCHAR2) IS
          l_custmerge_profile_value VARCHAR2(1);
BEGIN
   --removed code base from here
   -- moved to two procs - auto generated by TCA perl script.
   -- MERGE_CUSTOMER_IN_HEADER
   -- MERGE_CUSTOMER_IN_API

	l_custmerge_profile_value := FND_PROFILE.VALUE('CN_CUSTOMER_MERGE_ONLINE');
   IF l_custmerge_profile_value is null OR l_custmerge_profile_value = fnd_api.g_miss_char THEN
      	l_custmerge_profile_value := 'Y';
   END IF;

   IF 'Y' = l_custmerge_profile_value THEN
   merge_customer_in_header(req_id, set_number, process_mode);
   merge_customer_in_api(req_id, set_number, process_mode);
   ELSE
   populate_customer_merge(req_id, set_number, process_mode);
   END IF;
END customer_merge;

procedure submit_merge_request(errbuf OUT nocopy VARCHAR2,
				     retcode OUT nocopy NUMBER) IS

CURSOR mergerecords IS
SELECT request_id,set_number,process_mode
FROM CN_CUST_MERGE_INTERFACE
WHERE STATUS='I';

l_custmerge_profile_value VARCHAR2(1);
BEGIN
for c1 in mergerecords loop
   merge_customer_in_header(c1.request_id, c1.set_number, c1.process_mode);
   merge_customer_in_api(c1.request_id, c1.set_number, c1.process_mode);
   UPDATE 	CN_CUST_MERGE_INTERFACE
   SET STATUS='C'
   WHERE request_id=c1.request_id;
end loop;
EXCEPTION
   WHEN  OTHERS THEN
      --ROLLBACK TO populate_srp_tables_runner;
      errbuf := substr(sqlerrm,1,250);
      retcode := 2;
END submit_merge_request;

END cn_cust_merge_pvt;

/
