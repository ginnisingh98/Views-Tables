--------------------------------------------------------
--  DDL for Package Body POP_CMERGE_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POP_CMERGE_REQ" as
/* $Header: pocmer2b.pls 120.0 2005/06/01 19:48:34 appldev noship $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/
   g_count               NUMBER := 0;

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

/*--------------------------- PO_REQUISITION_LINES --------------------------*/

procedure PO_RL (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

   CURSOR C1 IS
   SELECT NULL
   FROM   PO_REQUISITION_LINES
   WHERE source_type_code = 'INVENTORY'
	 and deliver_to_location_id in (select location_id
		from po_location_associations
		where customer_id in (select racm.duplicate_id
                           from   ra_customer_merges  racm
                           where  racm.process_flag = 'N'
                           and    racm.request_id = req_id
                           and    racm.set_number = set_num
			   and    racm.customer_id
					<> racm.duplicate_id
   		           and    racm.customer_id in
					(select distinct customer_id
					 from   po_location_associations)))
   FOR UPDATE NOWAIT;

   /* Bug 2447478 START */

/* Bug 4009128: Commenting out following cursor statement. Adding columns
   pla1.location_id, pla2.location_id this cursor so they don't have to
   be retrieved in select statement later. */

/*
-- bug3648471
-- Rewrote merged_records as the original one did not return the records
-- expected

   -- SQL What: Get all the requisitions that has the deliver to location
   --           associated with a customer site to be merged, and the target
   --           site being already associated with some other location
   -- SQL Why:  We will update the deliver to location information of the req
   --           line, as the associated will be deleted later on.

   CURSOR merged_records IS
      SELECT m.CUSTOMER_MERGE_HEADER_ID,
             yt.REQUISITION_LINE_ID
      FROM   PO_REQUISITION_LINES yt,
             ra_customer_merges m,
             po_location_associations pla
      WHERE  yt.source_type_code = 'INVENTORY'
      AND    yt.deliver_to_location_id = pla.location_id
      AND    pla.site_use_id = m.duplicate_site_id
      AND    m.process_flag = 'N'
      AND    m.request_id = req_id
      AND    m.set_number = set_num
      AND    EXISTS (SELECT null
                     FROM   po_location_associations pla1
                     WHERE  m.customer_site_id = pla1.site_use_id);
*/

CURSOR merged_records IS
SELECT m.CUSTOMER_MERGE_HEADER_ID,
       yt.REQUISITION_LINE_ID,
       pla1.location_id,       --new
       pla2.location_id        --old

      FROM   PO_REQUISITION_LINES yt, ra_customer_merges m,
             po_location_associations pla1,po_location_associations pla2
      WHERE  yt.source_type_code = 'INVENTORY'
             and    yt.deliver_to_location_id = pla2.location_id
             and    pla2.site_use_id = m.duplicate_site_id
             and    m.customer_site_id = pla1.site_use_id
             and    m.process_flag = 'N'
             and    m.request_id = req_id
             and    m.set_number = set_num;

/* End Bug 4009128 */


   TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
      RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
   INDEX BY BINARY_INTEGER;
   MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

   TYPE REQUISITION_LINE_ID_LIST_TYPE IS TABLE OF
      PO_REQUISITION_LINES.REQUISITION_LINE_ID%TYPE
   INDEX BY BINARY_INTEGER;
   PRIMARY_KEY_ID_LIST REQUISITION_LINE_ID_LIST_TYPE;

   TYPE DELIVER_TO_LOC_ID_LIST_TYPE IS TABLE OF
      PO_REQUISITION_LINES.DELIVER_TO_LOCATION_ID%TYPE
   INDEX BY BINARY_INTEGER;
   NUM_COL1_ORIG_LIST DELIVER_TO_LOC_ID_LIST_TYPE;
   NUM_COL1_NEW_LIST DELIVER_TO_LOC_ID_LIST_TYPE;

   l_deliver_to_location_id PO_REQUISITION_LINES.DELIVER_TO_LOCATION_ID%TYPE;
   l_profile_val VARCHAR2(30);
   l_last_fetch  BOOLEAN := FALSE;
   /* Bug 2447478 END */

/* Following vars used to hold values from merged_records cursor */
OLD_DELIVER_TO_LOC_LIST DELIVER_TO_LOC_ID_LIST_TYPE;  --Bug 4009128
NEW_DELIVER_TO_LOC_LIST DELIVER_TO_LOC_ID_LIST_TYPE;  --Bug 4009128

BEGIN

   arp_message.set_line( 'POP_CMERGE_REQ.PO_RL()+' );

   /*-----------------------------+
    | PO_REQUISITION_LINES        |
    +-----------------------------*/

   IF (process_mode = 'LOCK') then

      /* try to lock the table first */

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PO_REQUISITION_LINES', FALSE );
      arp_message.flush;

      OPEN C1;
      CLOSE C1;

   ELSE

      /* Modify locations for those lines for which locations are going to change */

      arp_message.set_name('AR', 'AR_UPDATING_TABLE');
      arp_message.set_token('TABLE_NAME', 'PO_REQUISITION_LINES', FALSE);
      arp_message.set_line('Merging locations for merged customers/sites.');

      /* Bug 2447478 START */
      HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

      /* Bug 4009128 - commented below sql */
      /* Get the value for deliver_to_location_id */
      /*
      BEGIN
         select distinct pla1.location_id
         into   l_deliver_to_location_id
         from   po_location_associations pla1,
                po_location_associations pla2,
                ra_customer_merges racm,
                po_requisition_lines yt
         where  yt.deliver_to_location_id = pla2.location_id
         and    pla2.site_use_id = racm.duplicate_site_id
         and    racm.customer_site_id = pla1.site_use_id
         and    racm.process_flag = 'N'
         and    racm.request_id = req_id
         and    racm.set_number = set_num;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            null;
         WHEN OTHERS THEN
            null;
      END;
      */

      /* Open the merged_records cursor */
      open merged_records;

      LOOP
         /* Fetch the data into local variables */
	 /* Bug 4009128 - added fetch of old and new locations */
         FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST,
            PRIMARY_KEY_ID_LIST,
	    NEW_DELIVER_TO_LOC_LIST,
	    OLD_DELIVER_TO_LOC_LIST;

         /*
            If there is no more records, set the flag to true to indicate
            that we are done fetching all records.
         */
         IF merged_records%NOTFOUND THEN
            l_last_fetch := TRUE;
         END IF;

         /*
            If there is no more records to be fetched and
            no data was fetched at all, then exit the procedure call
         */
         IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
            exit;
         END IF;

         /*
            Store the value of the column to be updated to local
            variables.
         */
	   /* Bug 4009128 - comment below assignments */
         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         /* NUM_COL1_ORIG_LIST(I) := l_deliver_to_location_id;
            NUM_COL1_NEW_LIST(I) := NUM_COL1_ORIG_LIST(I); */

		NUM_COL1_ORIG_LIST(I) := NEW_DELIVER_TO_LOC_LIST(I);  --Bug 4009128
            NUM_COL1_NEW_LIST(I) := NUM_COL1_ORIG_LIST(I);        --Bug 4009128

         END LOOP;

         /*
            If auditing has been enabled, insert the changed records
            into the HZ_CUSTOMER_MERGE_LOG table.
         */
         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
               INSERT INTO HZ_CUSTOMER_MERGE_LOG(
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
                  LAST_UPDATED_BY)
               VALUES(
                  HZ_CUSTOMER_MERGE_LOG_s.nextval,
                  'PO_REQUISITION_LINES',
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
                  hz_utility_pub.LAST_UPDATED_BY);
         END IF;

         /*
            Update all corresponding deliver_to_location_id of
            the affected Requisitions due to merged/changed accounts
         */
	   /* Bug 4009128 - modified deliver_to_location assignment */
         FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            UPDATE PO_REQUISITION_LINES yt
            SET    -- DELIVER_TO_LOCATION_ID = l_deliver_to_location_id,
			 DELIVER_TO_LOCATION_ID = NEW_DELIVER_TO_LOC_LIST(I),
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = arp_standard.profile.user_id,
                   LAST_UPDATE_LOGIN = arp_standard.profile.last_update_login,
                   REQUEST_ID = req_id,
                   PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id,
                   PROGRAM_ID = arp_standard.profile.program_id,
                   PROGRAM_UPDATE_DATE = SYSDATE
            WHERE  REQUISITION_LINE_ID = PRIMARY_KEY_ID_LIST(I);

         g_count := g_count + SQL%ROWCOUNT;

         IF l_last_fetch THEN
            EXIT;
         END IF;

      END LOOP;

      /* Close the cursor */
      close merged_records;
      /* Bug 2447478 END */

      /* Number of rows updates */
      arp_message.set_name('AR', 'AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(g_count));

   END IF;

   arp_message.set_line( 'POP_CMERGE_REQ.PO_RL()-' );


EXCEPTION
   when others then
      arp_message.set_error( 'POP_CMERGE_REQ.PO_RL');
      raise;

END;


/*------------------------ PO_LOCATION_ASSOCIATIONS ------------------------*/

PROCEDURE PO_LA (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

   CURSOR C1 IS
   SELECT NULL
   FROM   PO_LOCATION_ASSOCIATIONS
   WHERE  site_use_id in (select racm.duplicate_site_id
                           from   ra_customer_merges  racm
                           where  racm.process_flag = 'N'
                           and    racm.request_id = req_id
                           and    racm.set_number = set_num)
      FOR UPDATE NOWAIT;

   /* Bug 2447478 START */
   TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
      RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
   INDEX BY BINARY_INTEGER;
   MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

   TYPE LOCATION_ID_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.LOCATION_ID%TYPE
   INDEX BY BINARY_INTEGER;
   PRIMARY_KEY_ID_LIST LOCATION_ID_LIST_TYPE;

   TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.CUSTOMER_ID%TYPE
   INDEX BY BINARY_INTEGER;
   NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
   NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

   TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.SITE_USE_ID%TYPE
   INDEX BY BINARY_INTEGER;
   NUM_COL2_ORIG_LIST SITE_USE_ID_LIST_TYPE;
   NUM_COL2_NEW_LIST SITE_USE_ID_LIST_TYPE;

   TYPE ADDRESS_ID_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ADDRESS_ID%TYPE
   INDEX BY BINARY_INTEGER;
   NUM_COL3_ORIG_LIST ADDRESS_ID_LIST_TYPE;
   NUM_COL3_NEW_LIST ADDRESS_ID_LIST_TYPE;

   TYPE ORGANIZATION_ID_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ORGANIZATION_ID%TYPE
   INDEX BY BINARY_INTEGER;
   NUM_COL4_ORIG_LIST ORGANIZATION_ID_LIST_TYPE;
   NUM_COL4_NEW_LIST ORGANIZATION_ID_LIST_TYPE;

   TYPE ORG_ID_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ORG_ID%TYPE
   INDEX BY BINARY_INTEGER;
   NUM_COL5_ORIG_LIST ORG_ID_LIST_TYPE;
   NUM_COL5_NEW_LIST ORG_ID_LIST_TYPE;

   TYPE VENDOR_ID_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.VENDOR_ID%TYPE
   INDEX BY BINARY_INTEGER;
   NUM_COL6_ORIG_LIST VENDOR_ID_LIST_TYPE;
   NUM_COL6_NEW_LIST VENDOR_ID_LIST_TYPE;

   TYPE VENDOR_SITE_ID_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.VENDOR_SITE_ID%TYPE
   INDEX BY BINARY_INTEGER;
   NUM_COL7_ORIG_LIST VENDOR_SITE_ID_LIST_TYPE;
   NUM_COL7_NEW_LIST VENDOR_SITE_ID_LIST_TYPE;

   TYPE SUBINVENTORY_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.SUBINVENTORY%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL1_ORIG_LIST SUBINVENTORY_LIST_TYPE;
   VCHAR_COL1_NEW_LIST SUBINVENTORY_LIST_TYPE;

   TYPE ATTRIBUTE_CATEGORY_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE_CATEGORY%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL2_ORIG_LIST ATTRIBUTE_CATEGORY_LIST_TYPE;
   VCHAR_COL2_NEW_LIST ATTRIBUTE_CATEGORY_LIST_TYPE;

   TYPE ATTRIBUTE1_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE1%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL3_ORIG_LIST ATTRIBUTE1_LIST_TYPE;
   VCHAR_COL3_NEW_LIST ATTRIBUTE1_LIST_TYPE;

   TYPE ATTRIBUTE2_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE2%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL4_ORIG_LIST ATTRIBUTE2_LIST_TYPE;
   VCHAR_COL4_NEW_LIST ATTRIBUTE2_LIST_TYPE;

   TYPE ATTRIBUTE3_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE3%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL5_ORIG_LIST ATTRIBUTE3_LIST_TYPE;
   VCHAR_COL5_NEW_LIST ATTRIBUTE3_LIST_TYPE;

   TYPE ATTRIBUTE4_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE4%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL6_ORIG_LIST ATTRIBUTE4_LIST_TYPE;
   VCHAR_COL6_NEW_LIST ATTRIBUTE4_LIST_TYPE;

   TYPE ATTRIBUTE5_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE5%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL7_ORIG_LIST ATTRIBUTE5_LIST_TYPE;
   VCHAR_COL7_NEW_LIST ATTRIBUTE5_LIST_TYPE;

   TYPE ATTRIBUTE6_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE6%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL8_ORIG_LIST ATTRIBUTE6_LIST_TYPE;
   VCHAR_COL8_NEW_LIST ATTRIBUTE6_LIST_TYPE;

   TYPE ATTRIBUTE7_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE7%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL9_ORIG_LIST ATTRIBUTE7_LIST_TYPE;
   VCHAR_COL9_NEW_LIST ATTRIBUTE7_LIST_TYPE;

   TYPE ATTRIBUTE8_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE8%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL10_ORIG_LIST ATTRIBUTE8_LIST_TYPE;
   VCHAR_COL10_NEW_LIST ATTRIBUTE8_LIST_TYPE;

   TYPE ATTRIBUTE9_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE9%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL11_ORIG_LIST ATTRIBUTE9_LIST_TYPE;
   VCHAR_COL11_NEW_LIST ATTRIBUTE9_LIST_TYPE;

   TYPE ATTRIBUTE10_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE10%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL12_ORIG_LIST ATTRIBUTE10_LIST_TYPE;
   VCHAR_COL12_NEW_LIST ATTRIBUTE10_LIST_TYPE;

   TYPE ATTRIBUTE11_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE11%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL13_ORIG_LIST ATTRIBUTE11_LIST_TYPE;
   VCHAR_COL13_NEW_LIST ATTRIBUTE11_LIST_TYPE;

   TYPE ATTRIBUTE12_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE12%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL14_ORIG_LIST ATTRIBUTE12_LIST_TYPE;
   VCHAR_COL14_NEW_LIST ATTRIBUTE12_LIST_TYPE;

   TYPE ATTRIBUTE13_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE13%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL15_ORIG_LIST ATTRIBUTE13_LIST_TYPE;
   VCHAR_COL15_NEW_LIST ATTRIBUTE13_LIST_TYPE;

   TYPE ATTRIBUTE14_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE14%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL16_ORIG_LIST ATTRIBUTE14_LIST_TYPE;
   VCHAR_COL16_NEW_LIST ATTRIBUTE14_LIST_TYPE;

   TYPE ATTRIBUTE15_LIST_TYPE IS TABLE OF
      PO_LOCATION_ASSOCIATIONS.ATTRIBUTE15%TYPE
   INDEX BY BINARY_INTEGER;
   VCHAR_COL17_ORIG_LIST ATTRIBUTE15_LIST_TYPE;
   VCHAR_COL17_NEW_LIST ATTRIBUTE15_LIST_TYPE;

   NEW_CUST_ID_LIST CUSTOMER_ID_LIST_TYPE;        --Bug 4009128
   NEW_CUST_SITE_ID_LIST SITE_USE_ID_LIST_TYPE;   --Bug 4009128

-- bug3648471
-- Rewrote cursor deleted_records as the original one was not returning
-- the rows we want it to be.

   -- SQL What: Get all the loc associations, if the loc association
   --           satisfies the following criteria
   --           1) The customer site is being merged
   --           2) The target customer site already has an association
   -- SQL Why:  We will delete this association as the site is going away

   CURSOR deleted_records IS
      SELECT m.CUSTOMER_MERGE_HEADER_ID,
             yt.LOCATION_ID,
             m.CUSTOMER_ID,
             yt.SITE_USE_ID,
             yt.ADDRESS_ID,
             yt.ORGANIZATION_ID,
             yt.ORG_ID,
             yt.VENDOR_ID,
             yt.VENDOR_SITE_ID,
             yt.SUBINVENTORY,
             yt.ATTRIBUTE_CATEGORY,
             yt.ATTRIBUTE1,
             yt.ATTRIBUTE2,
             yt.ATTRIBUTE3,
             yt.ATTRIBUTE4,
             yt.ATTRIBUTE5,
             yt.ATTRIBUTE6,
             yt.ATTRIBUTE7,
             yt.ATTRIBUTE8,
             yt.ATTRIBUTE9,
             yt.ATTRIBUTE10,
             yt.ATTRIBUTE11,
             yt.ATTRIBUTE12,
             yt.ATTRIBUTE13,
             yt.ATTRIBUTE14,
             yt.ATTRIBUTE15
      FROM   PO_LOCATION_ASSOCIATIONS yt,
             ra_customer_merges m
      WHERE  yt.site_use_id = m.duplicate_site_id  -- get the records that
                                                   -- need to be merged from
      AND    m.process_flag = 'N'
      AND    m.request_id = req_id
      AND    m.set_number = set_num
      AND    EXISTS (SELECT null
                     FROM   po_location_associations lc
                     WHERE  lc.site_use_id = m.customer_site_id);

/* Start Bug 4009128 - replaced the below cursor statement */

-- bug3648471
-- Rewrote cursor merged_records as the original one was not returning
-- the rows we want it to be.

   -- SQL What: Get all the loc associations, if the loc association
   --           has the customer site that is going to get merged, and
   --           it has not been deleted yet (which means that the target
   --           customer site doesn't have location association
   -- SQL Why:  We will update the association by replacing the old site
   --           with the target site

/*
   CURSOR merged_records IS
      SELECT distinct m.CUSTOMER_MERGE_HEADER_ID,
             yt.LOCATION_ID
      FROM   PO_LOCATION_ASSOCIATIONS yt, ra_customer_merges m
      WHERE  yt.site_use_id = m.duplicate_site_id
      AND    m.process_flag = 'N'
      AND    m.request_id = req_id
      AND    m.set_number = set_num;
*/

CURSOR merged_records IS
SELECT distinct m.CUSTOMER_MERGE_HEADER_ID,
             yt.LOCATION_ID,
             m.customer_id,
             m.customer_site_id
      FROM   PO_LOCATION_ASSOCIATIONS yt, ra_customer_merges m
      where  yt.customer_id = m.duplicate_id
         and    yt.site_use_id = m.duplicate_site_id
         and    m.process_flag = 'N'
         and    m.request_id = req_id
         and    m.set_number = set_num;
/* END Bug 4009128 */

   l_customer_id ra_customer_merges.customer_id%TYPE;
   l_site_use_id ra_customer_merges.customer_site_id%TYPE;
   l_profile_val VARCHAR2(30);
   l_last_fetch  BOOLEAN := FALSE;
   /* Bug 2447478 END */

BEGIN

   arp_message.set_line( 'POP_CMERGE_REQ.PO_LA()+' );

   /*-----------------------------+
    | PO_LOCATION_ASSOCIATIONS    |
    +-----------------------------*/

   IF (process_mode = 'LOCK') then

      /* try to lock the table first */

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PO_LOCATION_ASSOCIATIONS', FALSE );
      arp_message.flush;

      OPEN C1;
      CLOSE C1;

   ELSE

      /* for merged customers/sites */

      arp_message.set_name('AR', 'AR_UPDATING_TABLE');
      arp_message.set_token('TABLE_NAME', 'PO_LOCATION_ASSOCIATIONS', FALSE);
      arp_message.set_line('Deleting merged customers/sites.');

      /* Bug 2447478 START */
      g_count := 0;
      HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

      /* Open the deleted_records cursor */
      open deleted_records;

      LOOP
         /* Fetch the data into local variables */
         FETCH deleted_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST,
            PRIMARY_KEY_ID_LIST,
            NUM_COL1_ORIG_LIST,
            NUM_COL2_ORIG_LIST,
            NUM_COL3_ORIG_LIST,
            NUM_COL4_ORIG_LIST,
            NUM_COL5_ORIG_LIST,
            NUM_COL6_ORIG_LIST,
            NUM_COL7_ORIG_LIST,
            VCHAR_COL1_ORIG_LIST,
            VCHAR_COL2_ORIG_LIST,
            VCHAR_COL3_ORIG_LIST,
            VCHAR_COL4_ORIG_LIST,
            VCHAR_COL5_ORIG_LIST,
            VCHAR_COL6_ORIG_LIST,
            VCHAR_COL7_ORIG_LIST,
            VCHAR_COL8_ORIG_LIST,
            VCHAR_COL9_ORIG_LIST,
            VCHAR_COL10_ORIG_LIST,
            VCHAR_COL11_ORIG_LIST,
            VCHAR_COL12_ORIG_LIST,
            VCHAR_COL13_ORIG_LIST,
            VCHAR_COL14_ORIG_LIST,
            VCHAR_COL15_ORIG_LIST,
            VCHAR_COL16_ORIG_LIST,
            VCHAR_COL17_ORIG_LIST;

         /*
            If there is no more records, set the flag to true to indicate
            that we are done fetching all records.
         */
         IF deleted_records%NOTFOUND THEN
            l_last_fetch := TRUE;
         END IF;

         /*
            If there is no more records to be fetched and
            no data was fetched at all, then exit the procedure call
         */
         IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
            exit;
         END IF;

         /*
            Store the value of the column to be updated to local
            variables.
         */
         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
            NUM_COL1_NEW_LIST(I) := NUM_COL1_ORIG_LIST(I);
            NUM_COL2_NEW_LIST(I) := NUM_COL2_ORIG_LIST(I);
         END LOOP;

         /*
            If auditing has been enabled, insert the changed records
            into the HZ_CUSTOMER_MERGE_LOG table.
         */
         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
               INSERT INTO HZ_CUSTOMER_MERGE_LOG(
                  MERGE_LOG_ID,
                  TABLE_NAME,
                  MERGE_HEADER_ID,
                  PRIMARY_KEY_ID,
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
                  ACTION_FLAG,
                  REQUEST_ID,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATE_LOGIN,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY)
               VALUES(
                  HZ_CUSTOMER_MERGE_LOG_s.nextval,
                  'PO_LOCATION_ASSOCIATIONS',
                  MERGE_HEADER_ID_LIST(I),
                  PRIMARY_KEY_ID_LIST(I),
                  NUM_COL1_ORIG_LIST(I),
                  NUM_COL2_ORIG_LIST(I),
                  NUM_COL3_ORIG_LIST(I),
                  NUM_COL4_ORIG_LIST(I),
                  NUM_COL5_ORIG_LIST(I),
                  NUM_COL6_ORIG_LIST(I),
                  NUM_COL7_ORIG_LIST(I),
                  VCHAR_COL1_ORIG_LIST(I),
                  VCHAR_COL2_ORIG_LIST(I),
                  VCHAR_COL3_ORIG_LIST(I),
                  VCHAR_COL4_ORIG_LIST(I),
                  VCHAR_COL5_ORIG_LIST(I),
                  VCHAR_COL6_ORIG_LIST(I),
                  VCHAR_COL7_ORIG_LIST(I),
                  VCHAR_COL8_ORIG_LIST(I),
                  VCHAR_COL9_ORIG_LIST(I),
                  VCHAR_COL10_ORIG_LIST(I),
                  VCHAR_COL11_ORIG_LIST(I),
                  VCHAR_COL12_ORIG_LIST(I),
                  VCHAR_COL13_ORIG_LIST(I),
                  VCHAR_COL14_ORIG_LIST(I),
                  VCHAR_COL15_ORIG_LIST(I),
                  VCHAR_COL16_ORIG_LIST(I),
                  VCHAR_COL17_ORIG_LIST(I),
                  'D',
                  req_id,
                  hz_utility_pub.CREATED_BY,
                  hz_utility_pub.CREATION_DATE,
                  hz_utility_pub.LAST_UPDATE_LOGIN,
                  hz_utility_pub.LAST_UPDATE_DATE,
                  hz_utility_pub.LAST_UPDATED_BY);
         END IF;

         /*
            Delete all old or redundant records from the affected
            Requisitions due to merged/changed accounts
         */
         FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            DELETE FROM PO_LOCATION_ASSOCIATIONS yt
            WHERE  LOCATION_ID = PRIMARY_KEY_ID_LIST(I);

         g_count := g_count + SQL%ROWCOUNT;

         IF l_last_fetch THEN
            EXIT;
         END IF;
      END LOOP;

      /* Close the cursor */
      close deleted_records;

      /* Bug 2447478 END */

      /* Number of rows updates */
      arp_message.set_name('AR', 'AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS', to_char(g_count));   -- Bug 2447478


      /* for changed customers */

      arp_message.set_name('AR', 'AR_UPDATING_TABLE');
      arp_message.set_token('TABLE_NAME', 'PO_LOCATION_ASSOCIATIONS', FALSE);
      arp_message.set_line('Updating changed customers.');

      /* Bug 2447478 START */
      g_count := 0;

      /* Start Bug 4009128 : commented the below code*/
      /* Obtain the value for customer_id and site_use_id */
	/*
      BEGIN
         select distinct racm.customer_id,
                racm.customer_site_id
         into   l_customer_id,
                l_site_use_id
         from   ra_customer_merges racm,
                PO_LOCATION_ASSOCIATIONS yt
         where  yt.customer_id = racm.duplicate_id
         and    yt.site_use_id = racm.duplicate_site_id
         and    racm.process_flag = 'N'
         and    racm.request_id = req_id
         and    racm.set_number = set_num;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            null;
         WHEN OTHERS THEN
            null;
      END;
	*/

      /* Open the merged_records cursor */
      open merged_records;

      LOOP
         /* Fetch the data into local variables */
	   /* Bug 4009128 - Fetch Ct id and Ct site id */
         FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST,
            PRIMARY_KEY_ID_LIST,
	      NEW_CUST_ID_LIST,
	      NEW_CUST_SITE_ID_LIST;

         /*
            If there is no more records, set the flag to true to indicate
            that we are done fetching all records.
         */
         IF merged_records%NOTFOUND THEN
            l_last_fetch := TRUE;
         END IF;

         /*
            If there is no more records to be fetched and
            no data was fetched at all, then exit the procedure call
         */
         IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
            exit;
         END IF;

         /*
            Store the value of the column to be updated to local
            variables.
         */
         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP

		/*Bug 4009128 - commented below assignment */
         /* NUM_COL1_ORIG_LIST(I) := l_customer_id;
            NUM_COL2_ORIG_LIST(I) := l_site_use_id; */

		NUM_COL1_ORIG_LIST(I) := NEW_CUST_ID_LIST(I);      -- Bug 4009128
            NUM_COL2_ORIG_LIST(I) := NEW_CUST_SITE_ID_LIST(I); -- Bug 4009128
            NUM_COL1_NEW_LIST(I) := NUM_COL1_ORIG_LIST(I);
            NUM_COL2_NEW_LIST(I) := NUM_COL2_ORIG_LIST(I);
         END LOOP;

         /*
            If auditing has been enabled, insert the changed records
            into the HZ_CUSTOMER_MERGE_LOG table.
         */
         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
               INSERT INTO HZ_CUSTOMER_MERGE_LOG(
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
                  LAST_UPDATED_BY)
               VALUES(
                  HZ_CUSTOMER_MERGE_LOG_s.nextval,
                  'PO_LOCATION_ASSOCIATIONS',
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
                  hz_utility_pub.LAST_UPDATED_BY);
         END IF;

         /*
            Update all corresponding customer_id and site_use_id
            due to merged/changed accounts
         */
         FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            UPDATE PO_LOCATION_ASSOCIATIONS yt
            SET    CUSTOMER_ID=NEW_CUST_ID_LIST(I),                      --Bug 4009128
                   SITE_USE_ID=NEW_CUST_SITE_ID_LIST(I),                 --Bug 4009128
                   LAST_UPDATE_DATE = SYSDATE,
                   last_updated_by = arp_standard.profile.user_id,
                   last_update_login = arp_standard.profile.last_update_login,
                   REQUEST_ID = req_id,
                   PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id,
                   PROGRAM_ID = arp_standard.profile.program_id,
                   PROGRAM_UPDATE_DATE = SYSDATE
            WHERE  LOCATION_ID = PRIMARY_KEY_ID_LIST(I);

         g_count := g_count + SQL%ROWCOUNT;

         IF l_last_fetch THEN
            EXIT;
         END IF;
      END LOOP;

      /* Close the cursor */
      close merged_records;

      /* Bug 2447478 END */

      /* Number of rows updates */
      arp_message.set_name('AR', 'AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS', to_char(g_count));   -- Bug 2447478

   END IF;

   arp_message.set_line( 'POP_CMERGE_REQ.PO_LA()-' );


EXCEPTION
   when others then
      arp_message.set_error( 'POP_CMERGE_REQ.PO_LA');
      raise;
END;


/*---------------------------- PUBLIC ROUTINES ------------------------------*/

PROCEDURE MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
BEGIN

   arp_message.set_line( 'POP_CMERGE_REQ.MERGE()+' );

   PO_RL( req_id, set_num, process_mode );
   PO_LA( req_id, set_num, process_mode );

   arp_message.set_line( 'POP_CMERGE_REQ.MERGE()-' );

END MERGE;
end POP_CMERGE_REQ;

/
