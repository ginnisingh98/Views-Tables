--------------------------------------------------------
--  DDL for Package Body INV_CMERGE_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CMERGE_ITEMS" as
/* $Header: invcmib.pls 120.1 2006/02/22 03:44:24 swshukla noship $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count               NUMBER := 0;

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

/*---------------------------- PUBLIC ROUTINES ------------------------------*/

PROCEDURE MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CUSTOMER_ITEM_ID_LIST_TYPE IS TABLE OF
         MTL_CUSTOMER_ITEMS.CUSTOMER_ITEM_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST CUSTOMER_ITEM_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         MTL_CUSTOMER_ITEMS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE ADDRESS_ID_LIST_TYPE IS TABLE OF
         MTL_CUSTOMER_ITEMS.ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ADDRESS_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST ADDRESS_ID_LIST_TYPE;

-- Bug 4135064.
  TYPE CUSTOMER_ITEM_NUMBER_LIST_TYPE IS TABLE OF
         MTL_CUSTOMER_ITEMS.CUSTOMER_ITEM_NUMBER%TYPE
        INDEX BY BINARY_INTEGER;
  CUST_ITEM_NUM_LIST CUSTOMER_ITEM_NUMBER_LIST_TYPE;

  TYPE CUST_CATEGORY_CODE_LIST_TYPE IS TABLE OF
         MTL_CUSTOMER_ITEMS.CUSTOMER_CATEGORY_CODE%TYPE
        INDEX BY BINARY_INTEGER;
  CUST_CATEGORY_CODE_LIST CUST_CATEGORY_CODE_LIST_TYPE;

  TYPE ITEM_DEF_LEVEL_LIST_TYPE IS TABLE OF
         MTL_CUSTOMER_ITEMS.ITEM_DEFINITION_LEVEL%TYPE
        INDEX BY BINARY_INTEGER;
  ITEM_DEF_LEVEL_LIST ITEM_DEF_LEVEL_LIST_TYPE;
-- Bug 4135064

  l_profile_val VARCHAR2(30);
  -- Bug 4135064. Added additional columns in the select statement.
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,CUSTOMER_ITEM_ID
--Selecting the customer_id,address_id according to functionality
              ,decode(yt.CUSTOMER_ID,m.DUPLICATE_ID,m.CUSTOMER_ID,yt.CUSTOMER_ID)
              ,decode(yt.ADDRESS_ID,m.DUPLICATE_ADDRESS_ID,
		decode(yt.item_definition_level,3,m.CUSTOMER_ADDRESS_ID,yt.ADDRESS_ID),yt.ADDRESS_ID)
	      , customer_item_number
	      , customer_category_code
	      , item_definition_level
         FROM MTL_CUSTOMER_ITEMS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
            OR yt.ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN

   arp_message.set_line( 'INV_CMERGE_ITEMS.MERGE()+' );
/*-----------------------+
 | MTL_CUSTOMER_ITEMS |
 +-----------------------*/
 /* try to lock the table first */

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','MTL_CUSTOMER_ITEMS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
	  , CUST_ITEM_NUM_LIST
	  , CUST_CATEGORY_CODE_LIST
	  , ITEM_DEF_LEVEL_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));

      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     /* inserting in log table */
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
         'MTL_CUSTOMER_ITEMS',
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

    END IF;

   -- Bug 4135064. Delete the records which on update will result in unique
   -- constraint violation error in mtl_customer_items_U1.
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
       DELETE FROM MTL_CUSTOMER_ITEMS mci
       WHERE CUSTOMER_ITEM_ID=PRIMARY_KEY_ID_LIST(I)
       AND EXISTS (SELECT 1 FROM MTL_CUSTOMER_ITEMS yt
                   WHERE yt.CUSTOMER_ID = NUM_COL1_NEW_LIST(I)
		   AND  NVL(yt.ADDRESS_ID, -999) = NVL(NUM_COL2_NEW_LIST(I), -999)
		   AND  yt.CUSTOMER_ITEM_NUMBER = CUST_ITEM_NUM_LIST(I)
		   AND  NVL(yt.CUSTOMER_CATEGORY_CODE, '@@@') = NVL(CUST_CATEGORY_CODE_LIST(I), '@@@')
		   AND  yt.ITEM_DEFINITION_LEVEL = ITEM_DEF_LEVEL_LIST(I)
		   AND  yt.rowid <> mci.rowid                 --Bug: 5054179 Added this clause based on rowids
                   );

    /* customer level update */
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE MTL_CUSTOMER_ITEMS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          ,ADDRESS_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE CUSTOMER_ITEM_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;
   /* Number of rows updates */
    arp_message.set_line( 'INV_CMERGE_ITEMS.MERGE()-' );
    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'INV_CMERGE_ITEMS.MERGE');
    arp_message.set_line( substrb(SQLERRM,1,200) );
    RAISE;
END MERGE;

end INV_CMERGE_ITEMS;

/
