--------------------------------------------------------
--  DDL for Package Body FUN_CUSTOMERMERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_CUSTOMERMERGE_PKG" AS
/* $Header: funntcmb.pls 120.2 2006/01/25 14:11:13 asrivats noship $ */

PROCEDURE Merge_Customer (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE NETTING_CUSTOMER_ID_LIST_TYPE IS TABLE OF
         FUN_NET_CUSTOMERS_ALL.NETTING_CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST NETTING_CUSTOMER_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         FUN_NET_CUSTOMERS_ALL.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE CUST_SITE_USE_ID_LIST_TYPE IS TABLE OF
         FUN_NET_CUSTOMERS_ALL.CUST_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST CUST_SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUST_SITE_USE_ID_LIST_TYPE;

  TYPE CUSTOMER_PRIORITY_LIST_TYPE IS TABLE OF
         FUN_NET_CUSTOMERS_ALL.CUST_PRIORITY%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST CUSTOMER_PRIORITY_LIST_TYPE;
  NUM_COL3_NEW_LIST CUSTOMER_PRIORITY_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,NETTING_CUSTOMER_ID
              ,CUST_ACCOUNT_ID
              ,CUST_SITE_USE_ID
              ,CUST_PRIORITY
         FROM FUN_NET_CUSTOMERS_ALL yt, ra_customer_merges m
         WHERE (
            yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
            OR yt.CUST_SITE_USE_ID = m.DUPLICATE_SITE_ID
         )
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FUN_NET_CUSTOMERS_ALL',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);

    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := NUM_COL3_ORIG_LIST(I);
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
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (
          HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'FUN_NET_CUSTOMERS_ALL',
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

      UPDATE FUN_NET_CUSTOMERS_ALL yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          ,CUST_SITE_USE_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE NETTING_CUSTOMER_ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

/* If there is more than one record that has the same agreement_id,cust_account_id and cust_site_use_id then update the customer priority of the records to the highest priority amongst them */
BEGIN
	UPDATE FUN_NET_CUSTOMERS_ALL yt SET
        CUST_PRIORITY= (SELECT MIN(CUST_PRIORITY)
                                FROM FUN_NET_CUSTOMERS_ALL
                                WHERE AGREEMENT_ID = yt.AGREEMENT_ID
                                AND  CUST_ACCOUNT_ID = yt.CUST_ACCOUNT_ID
                                AND nvl(CUST_SITE_USE_ID,0) = DECODE(
                                yt.CUST_SITE_USE_ID,NULL,0,yt.CUST_SITE_USE_ID)
                                )
    	WHERE  EXISTS (SELECT 1
		  FROM FUN_NET_CUSTOMERS_ALL
                  WHERE  yt.agreement_id = agreement_id
                  AND 	 yt.cust_account_id = cust_account_id
                  AND    nvl(CUST_SITE_USE_ID,0) = DECODE(
                                yt.CUST_SITE_USE_ID,NULL
				,0,yt.CUST_SITE_USE_ID)
                 GROUP BY agreement_id,cust_account_id,cust_site_use_id
                 HAVING count(agreement_id) > 1);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		null;
END;

 /* If there is more than one row that has the same agreement_id , customer_priority,cust_account_id and cust_site_use_id , delete the record that has the minimum of the netting customer id */

	BEGIN
	        DELETE FROM FUN_NET_CUSTOMERS_ALL yt
        	WHERE NETTING_CUSTOMER_ID  = (
			SELECT MIN(NETTING_CUSTOMER_ID)
                        FROM FUN_NET_CUSTOMERS_ALL
                        WHERE
                         yt.AGREEMENT_ID = AGREEMENT_ID
                        AND yt.CUST_ACCOUNT_ID = CUST_ACCOUNT_ID
                        AND nvl(yt.CUST_SITE_USE_ID,0) = nvl(CUST_SITE_USE_ID,0)
                        AND yt.CUST_PRIORITY = CUST_PRIORITY
                        GROUP BY AGREEMENT_ID,
                              CUST_ACCOUNT_ID,
                             CUST_SITE_USE_ID,
                                CUST_PRIORITY
                        HAVING COUNT(NETTING_CUSTOMER_ID) > 1);

	EXCEPTION
        	WHEN NO_DATA_FOUND THEN
                	null;
	END;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'Merge_Customer');
    RAISE;
END Merge_Customer;
END FUN_CustomerMerge_PKG;

/
