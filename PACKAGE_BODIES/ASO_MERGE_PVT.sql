--------------------------------------------------------
--  DDL for Package Body ASO_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_MERGE_PVT" As
/* $Header: asovmrgb.pls 120.0.12010000.4 2016/01/07 18:46:54 vidsrini ship $ */

/*----------------------------------------------------------------------------*
 |                                                                            |
 | DESCRIPTION                                                                |
 |             This package contains APIs for customer merge and party        |
 |             merge for Order Capture.                                       |
 | REQUIRES                                                                   |
 |                                                                            |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |  Harish Ekkirala Created 03/27/2001.                                       |
 |  Veeru Tarikere  07/18/2002  Rewrote Customer_merge, update_quote_lines    |
 |                              and update_shipments.Removed Globals          |
 |                                                                            |
 *----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |             CUSTOMER_MERGE                                                 |
 | DESCRIPTION                                                                |
 |             This API should be called from TCA customer merge concurrent   |
 |             program and will merge records in Order Capture tables for     |
 |             customers that being merged.                                   |
 | REQUIRES                                                                   |
 |                                                                            |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                  DIFFERENT_PARTIES -- Raises an exception when the owner   |
 |                                       parties are different for the cust   |
 |                                       accounts that are being merged.      |
 |                  removed (vtariker)                                        |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |  Harish Ekkirala Created 03/27/2001.                                       |
 |  Vtariker 07/18/2002 Rewrote Customer_Merge                                |
 |                                                                            |
 *----------------------------------------------------------------------------*/

PROCEDURE CUSTOMER_MERGE(
                req_id                       NUMBER,
                set_num                      NUMBER,
                process_mode                 VARCHAR2
               )
IS


  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE QUOTE_HEADER_ID_LIST_TYPE IS TABLE OF
         ASO_QUOTE_HEADERS.QUOTE_HEADER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST QUOTE_HEADER_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         ASO_QUOTE_HEADERS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE INV_TO_CUST_ACCT_ID_LIST_TYPE IS TABLE OF
         ASO_QUOTE_HEADERS.INVOICE_TO_CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST INV_TO_CUST_ACCT_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST INV_TO_CUST_ACCT_ID_LIST_TYPE;

  TYPE END_CUST_ACCT_ID_LIST_TYPE IS TABLE OF
         ASO_QUOTE_HEADERS.END_CUSTOMER_CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST END_CUST_ACCT_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST END_CUST_ACCT_ID_LIST_TYPE;
-- bug 9869147
  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT /*+ leading(M) use_nl(M,YT) USE_CONCAT */
	distinct CUSTOMER_MERGE_HEADER_ID
              ,QUOTE_HEADER_ID
              ,CUST_ACCOUNT_ID
              ,INVOICE_TO_CUST_ACCOUNT_ID
              ,END_CUSTOMER_CUST_ACCOUNT_ID
         FROM ASO_QUOTE_HEADERS yt, ra_customer_merges m
         WHERE (
            yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
            OR yt.INVOICE_TO_CUST_ACCOUNT_ID = m.DUPLICATE_ID
            OR yt.END_CUSTOMER_CUST_ACCOUNT_ID = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ASO_QUOTE_HEADERS',FALSE);
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
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL3_ORIG_LIST(I));
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
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'ASO_QUOTE_HEADERS',
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
      UPDATE ASO_QUOTE_HEADERS yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          ,INVOICE_TO_CUST_ACCOUNT_ID=NUM_COL2_NEW_LIST(I)
          ,END_CUSTOMER_CUST_ACCOUNT_ID=NUM_COL3_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE QUOTE_HEADER_ID=PRIMARY_KEY_ID_LIST(I)
         ;

      l_count := l_count + SQL%ROWCOUNT;

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

  END IF;

  ASO_MERGE_PVT.UPDATE_QUOTE_LINES(
                req_id            => req_id,
                set_num           => set_num,
                process_mode      => process_mode
              );

  ASO_MERGE_PVT.UPDATE_SHIPMENTS(
                req_id            => req_id,
                set_num           => set_num,
                process_mode      => process_mode
              );


EXCEPTION

  WHEN OTHERS THEN

    arp_message.set_line( 'CUSTOMER_MERGE');
    RAISE;

END CUSTOMER_MERGE;



/*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |                  UPDATE_QUOTE_LINES                                        |
 | DESCRIPTION                                                                |
 |             This is a private procedure to update ASO_QUOTE_LINES_ALL      |
 |             table with merged to cust account id. When two cust accounts   |
 |             are merged.                                                    |
 | REQUIRES                                                                   |
 |                                                                            |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |  Harish Ekkirala Created 03/27/2001.                                       |
 |  Vtariker 07/18/2002 Rewrote Update_Quote_lines                            |
 |                                                                            |
 *----------------------------------------------------------------------------*/
PROCEDURE UPDATE_QUOTE_LINES(
                req_id                       NUMBER,
                set_num                      NUMBER,
                process_mode                 VARCHAR2
              ) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE QUOTE_LINE_ID_LIST_TYPE IS TABLE OF
         ASO_QUOTE_LINES.QUOTE_LINE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST QUOTE_LINE_ID_LIST_TYPE;

  TYPE INV_TO_CUST_ACCT_ID_LIST_TYPE IS TABLE OF
         ASO_QUOTE_LINES.INVOICE_TO_CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST INV_TO_CUST_ACCT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST INV_TO_CUST_ACCT_ID_LIST_TYPE;

  TYPE END_CUST_ACCT_ID_LIST_TYPE IS TABLE OF
         ASO_QUOTE_LINES.END_CUSTOMER_CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST END_CUST_ACCT_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST END_CUST_ACCT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
        SELECT /*+ leading(M) use_nl(M,YT) USE_CONCAT */
	distinct CUSTOMER_MERGE_HEADER_ID
              ,QUOTE_LINE_ID
              ,INVOICE_TO_CUST_ACCOUNT_ID
              ,END_CUSTOMER_CUST_ACCOUNT_ID
         FROM ASO_QUOTE_LINES yt, ra_customer_merges m
         WHERE (
            yt.INVOICE_TO_CUST_ACCOUNT_ID = m.DUPLICATE_ID
            OR yt.END_CUSTOMER_CUST_ACCOUNT_ID = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ASO_QUOTE_LINES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

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

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
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
         'ASO_QUOTE_LINES',
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

    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE ASO_QUOTE_LINES yt SET
           INVOICE_TO_CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          , END_CUSTOMER_CUST_ACCOUNT_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE QUOTE_LINE_ID=PRIMARY_KEY_ID_LIST(I)
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

    arp_message.set_line( 'UPDATE_QUOTE_LINES');
    RAISE;

END UPDATE_QUOTE_LINES;



/*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |                  UPDATE_SHIPMENTS                                          |
 | DESCRIPTION                                                                |
 |             This is a private procedure to update ASO_SHIPMENTS            |
 |             table with merged to cust account id. When two cust accounts   |
 |             are merged.                                                    |
 | REQUIRES                                                                   |
 |                                                                            |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |  Harish Ekkirala Created 03/27/2001.                                       |
 |  Vtariker 07/18/2002 Rewrote Update_Shipments                              |
 |                                                                            |
 *----------------------------------------------------------------------------*/
PROCEDURE UPDATE_SHIPMENTS(
                req_id                       NUMBER,
                set_num                      NUMBER,
                process_mode                 VARCHAR2
              ) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE SHIPMENT_ID_LIST_TYPE IS TABLE OF
         ASO_SHIPMENTS.SHIPMENT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST SHIPMENT_ID_LIST_TYPE;

  TYPE SHIP_TO_CUST_ACCT_ID_LIST_TYPE IS TABLE OF
         ASO_SHIPMENTS.SHIP_TO_CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST SHIP_TO_CUST_ACCT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST SHIP_TO_CUST_ACCT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,SHIPMENT_ID
              ,SHIP_TO_CUST_ACCOUNT_ID
         FROM ASO_SHIPMENTS yt, ra_customer_merges m
         WHERE (
            yt.SHIP_TO_CUST_ACCOUNT_ID = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','ASO_SHIPMENTS',FALSE);
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
         'ASO_SHIPMENTS',
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


    END IF;

    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE ASO_SHIPMENTS yt SET
           SHIP_TO_CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE SHIPMENT_ID=PRIMARY_KEY_ID_LIST(I)
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

    arp_message.set_line( 'UPDATE_SHIPMENTS');
    RAISE;

END UPDATE_SHIPMENTS;



/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_QUOTE_HEADERS -- 				                 |
|			 When in ERP Parties are merged the	      	            |
|               The Foriegn keys to party_id and other columns               |
|			 should also be updated in iStore tables.  		            |
|               This procedure will update ASO_QUOTE_HEADERS_ALL table       |
|                  and will be called from party Merge concurrent program.   |
| DESCRIPTION                                                                |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_QUOTE_HEADERS(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			OUT NOCOPY   NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT NOCOPY  VARCHAR2
				)  IS

l_merge_reason_code 	VARCHAR2(30);
l_count                 NUMBER(10)   := 0;

RESOURCE_BUSY           EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN

arp_message.set_line('ASO_MERGE_PVT.MERGE_QUOTE_HEADERS()+');

x_return_status :=  FND_API.G_RET_STS_SUCCESS;

/* Perform the merge operation */

/* If the parent has NOT Changed(i.e Parent is getting transfered), then nothing needs to be done. Set Merge To id same
   as Merged from id and return */

   if p_from_fk_id = p_to_fk_id then
		x_to_id := p_from_id;
		return;
   End If;


/* If the Parent has changed(i.e. Parent is getting merged), then transfer the dependent record to the new parent. */

   if p_from_fk_id <> p_to_fk_id Then

	IF p_parent_entity_name = 'HZ_PARTIES' Then

          arp_message.set_name('AR', 'AR_UPDATING_TABLE');
          arp_message.set_token('TABLE_NAME','ASO_QUOTE_HEADERS_ALL', FALSE);

		UPDATE ASO_QUOTE_HEADERS_ALL SET
				party_id = DECODE(party_id,p_from_fk_id,p_to_fk_id,party_id),
				invoice_to_party_id = DECODE(invoice_to_party_id,p_from_fk_id,p_to_fk_id,invoice_to_party_id),
				cust_party_id = DECODE(cust_party_id,p_from_fk_id,p_to_fk_id,cust_party_id),
				invoice_to_cust_party_id = DECODE(invoice_to_cust_party_id,p_from_fk_id,p_to_fk_id,invoice_to_cust_party_id),
				End_Customer_party_id = DECODE(End_Customer_party_id,p_from_fk_id,p_to_fk_id,End_Customer_party_id),
				End_Customer_cust_party_id = DECODE(End_Customer_cust_party_id,p_from_fk_id,p_to_fk_id,End_Customer_cust_party_id),
				last_update_date = hz_utility_pub.last_update_date,
				last_updated_by  = hz_utility_pub.user_id,
				last_update_login = hz_utility_pub.last_update_login,
				request_id = hz_utility_pub.request_id,
				program_application_id = hz_utility_pub.program_application_id,
				program_id = hz_utility_pub.program_id,
				program_update_date = sysdate
		Where party_id = p_from_fk_id
		OR invoice_to_party_id = p_from_fk_id
		OR cust_party_id = p_from_fk_id
		OR invoice_to_cust_party_id = p_from_fk_id
		--Bug 22494590
		OR End_Customer_party_id = p_from_fk_id
                OR End_Customer_cust_party_id = p_from_fk_id;


		l_count := sql%rowcount;

		arp_message.set_name('AR', 'AR_ROWS_UPDATED');
		arp_message.set_token('NUM_ROWS', to_char(l_count) );

		return;

	ELSIF p_parent_entity_name = 'HZ_PARTY_SITES' THEN

		arp_message.set_name('AR', 'AR_UPDATING_TABLE');
	 	arp_message.set_token('TABLE_NAME','ASO_QUOTE_HEADERS_ALL', FALSE);

		UPDATE ASO_QUOTE_HEADERS_ALL SET
				invoice_to_party_site_id = DECODE(invoice_to_party_site_id,p_from_fk_id,p_to_fk_id,invoice_to_party_site_id),
				End_Customer_party_site_id = DECODE(End_Customer_party_site_id,p_from_fk_id,p_to_fk_id,End_Customer_party_site_id),
				sold_to_party_site_id = DECODE(sold_to_party_site_id,p_from_fk_id,p_to_fk_id,sold_to_party_site_id),
				last_update_date = hz_utility_pub.last_update_date,
				last_updated_by  = hz_utility_pub.user_id,
				last_update_login = hz_utility_pub.last_update_login,
				request_id = hz_utility_pub.request_id,
				program_application_id = hz_utility_pub.program_application_id,
				program_id = hz_utility_pub.program_id,
				program_update_date = sysdate
		Where invoice_to_party_site_id = p_from_fk_id
          OR End_Customer_party_site_id = p_from_fk_id
		OR sold_to_party_site_id = p_from_fk_id;

		l_count := sql%rowcount;

		arp_message.set_name('AR', 'AR_ROWS_UPDATED');
		arp_message.set_token('NUM_ROWS', to_char(l_count) );

		return;

	ELSIF p_parent_entity_name = 'HZ_ORG_CONTACTS' THEN

		arp_message.set_name('AR', 'AR_UPDATING_TABLE');
	 	arp_message.set_token('TABLE_NAME','ASO_QUOTE_HEADERS_ALL', FALSE);

		UPDATE ASO_QUOTE_HEADERS_ALL SET
				org_contact_id = p_to_fk_id,
				last_update_date = hz_utility_pub.last_update_date,
				last_updated_by  = hz_utility_pub.user_id,
				last_update_login = hz_utility_pub.last_update_login,
				request_id = hz_utility_pub.request_id,
				program_application_id = hz_utility_pub.program_application_id,
				program_id = hz_utility_pub.program_id,
				program_update_date = sysdate
		Where org_contact_id = p_from_fk_id;

		l_count := sql%rowcount;

		arp_message.set_name('AR', 'AR_ROWS_UPDATED');
		arp_message.set_token('NUM_ROWS', to_char(l_count) );

		return;


	END IF;

End If;

arp_message.set_line('ASO_MERGE_PVT.MERGE_QUOTE_HEADERS()-');

Exception
	When RESOURCE_BUSY Then
		arp_message.set_line('ASO_MERGE_PVT.MERGE_QUOTE_HEADERS; Could not obtain lock'||
					'on table ASO_QUOTE_HEADERS_ALL');

		 x_return_status :=  FND_API.G_RET_STS_ERROR;
		 raise;
	When Others Then
		arp_message.set_line('ASO_MERGE_PVT.MERGE_QUOTE_HEADERS'||sqlerrm);
		x_return_status :=  FND_API.G_RET_STS_ERROR;
		raise;
END MERGE_QUOTE_HEADERS;

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_QUOTE_LINES -- 				           	  |
|			 When in ERP Parties are merged the	      	            |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		            |
|                  This procedure will update ASO_QUOTE_LINES_ALL table      |
|                  and will be called from party Merge concurrent program.   |
| DESCRIPTION                                                                |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_QUOTE_LINES(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			OUT NOCOPY   NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT NOCOPY  VARCHAR2
				)  IS

l_merge_reason_code 	VARCHAR2(30);
l_count                 NUMBER(10)   := 0;

RESOURCE_BUSY           EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN

arp_message.set_line('ASO_MERGE_PVT.MERGE_QUOTE_LINES()+');

x_return_status :=  FND_API.G_RET_STS_SUCCESS;

/* Perform the merge operation */

/* If the parent has NOT Changed(i.e Parent is getting transfered), then nothing needs to be done. Set Merge To id same
   as Merged from id and return */

   if p_from_fk_id = p_to_fk_id then
		x_to_id := p_from_id;
		return;
   End If;


/* If the Parent has changed(i.e. Parent is getting merged), then transfer the dependent record to the new parent. */

   if p_from_fk_id <> p_to_fk_id Then

	If p_parent_entity_name = 'HZ_PARTIES' Then

		arp_message.set_name('AR', 'AR_UPDATING_TABLE');
	 	arp_message.set_token('TABLE_NAME','ASO_QUOTE_LINES_ALL', FALSE);

		UPDATE ASO_QUOTE_LINES_ALL SET
				invoice_to_party_id = DECODE(invoice_to_party_id,p_from_fk_id,p_to_fk_id,invoice_to_party_id),
				invoice_to_cust_party_id = DECODE(invoice_to_cust_party_id,p_from_fk_id,p_to_fk_id,invoice_to_cust_party_id),
				End_Customer_party_id = DECODE(End_Customer_party_id,p_from_fk_id,p_to_fk_id,End_Customer_party_id),
				End_Customer_cust_party_id = DECODE(End_Customer_cust_party_id,p_from_fk_id,p_to_fk_id,End_Customer_cust_party_id),
				last_update_date = hz_utility_pub.last_update_date,
				last_updated_by  = hz_utility_pub.user_id,
				last_update_login = hz_utility_pub.last_update_login,
				request_id = hz_utility_pub.request_id,
				program_application_id = hz_utility_pub.program_application_id,
				program_id = hz_utility_pub.program_id,
				program_update_date = sysdate
		Where invoice_to_party_id = p_from_fk_id
		OR invoice_to_cust_party_id = p_from_fk_id
		OR End_Customer_cust_party_id = p_from_fk_id;

		l_count := sql%rowcount;

		arp_message.set_name('AR', 'AR_ROWS_UPDATED');
		arp_message.set_token('NUM_ROWS', to_char(l_count) );

		return;

	Elsif p_parent_entity_name = 'HZ_PARTY_SITES' Then

		arp_message.set_name('AR', 'AR_UPDATING_TABLE');
	 	arp_message.set_token('TABLE_NAME','ASO_QUOTE_LINES_ALL', FALSE);

		UPDATE ASO_QUOTE_LINES_ALL SET
				invoice_to_party_site_id = p_to_fk_id,
				End_Customer_party_site_id = p_to_fk_id,
				last_update_date = hz_utility_pub.last_update_date,
				last_updated_by  = hz_utility_pub.user_id,
				last_update_login = hz_utility_pub.last_update_login,
				request_id = hz_utility_pub.request_id,
				program_application_id = hz_utility_pub.program_application_id,
				program_id = hz_utility_pub.program_id,
				program_update_date = sysdate
		Where invoice_to_party_site_id = p_from_fk_id
          OR End_Customer_party_site_id = p_from_fk_id;

		l_count := sql%rowcount;

		arp_message.set_name('AR', 'AR_ROWS_UPDATED');
		arp_message.set_token('NUM_ROWS', to_char(l_count) );

		return;

	End If;

End If;

arp_message.set_line('ASO_MERGE_PVT.MERGE_QUOTE_LINES()-');

Exception
	When RESOURCE_BUSY Then
		arp_message.set_line('ASO_MERGE_PVT.MERGE_QUOTE_LINES; Could not obtain lock'||
					'on table ASO_QUOTE_LINES_ALL');

		 x_return_status :=  FND_API.G_RET_STS_ERROR;
		 raise;
	When Others Then
		arp_message.set_line('ASO_MERGE_PVT.MERGE_QUOTE_LINES'||sqlerrm);
		x_return_status :=  FND_API.G_RET_STS_ERROR;
		raise;

END MERGE_QUOTE_LINES;

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_SHIPMENTS-- 					                 |
|			 When in ERP Parties are merged the	      	            |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		            |
|                  This procedure will update ASO_SHIPMENTS table    	       |
|                  and will be called from party Merge concurrent program.   |
| DESCRIPTION                                                                |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_SHIPMENTS(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			OUT NOCOPY   NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT NOCOPY  VARCHAR2
				)  IS

l_merge_reason_code 	VARCHAR2(30);
l_count                 NUMBER(10)   := 0;

RESOURCE_BUSY           EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN

arp_message.set_line('ASO_MERGE_PVT.MERGE_SHIPMENTS()+');

x_return_status :=  FND_API.G_RET_STS_SUCCESS;

/* Perform the merge operation */

/* If the parent has NOT Changed(i.e Parent is getting transfered), then nothing needs to be done. Set Merge To id same
   as Merged from id and return */

   if p_from_fk_id = p_to_fk_id then
		x_to_id := p_from_id;
		return;
   End If;


/* If the Parent has changed(i.e. Parent is getting merged), then transfer the dependent record to the new parent. */

   if p_from_fk_id <> p_to_fk_id Then

	If p_parent_entity_name = 'HZ_PARTIES' Then

		arp_message.set_name('AR', 'AR_UPDATING_TABLE');
	 	arp_message.set_token('TABLE_NAME','ASO_SHIPMENTS', FALSE);

		UPDATE ASO_SHIPMENTS SET
				ship_to_party_id = DECODE(ship_to_party_id,p_from_fk_id,p_to_fk_id,ship_to_party_id),
				ship_to_cust_party_id = DECODE(ship_to_cust_party_id,p_from_fk_id,p_to_fk_id,ship_to_cust_party_id),
				last_update_date = hz_utility_pub.last_update_date,
				last_updated_by  = hz_utility_pub.user_id,
				last_update_login = hz_utility_pub.last_update_login,
				request_id = hz_utility_pub.request_id,
				program_application_id = hz_utility_pub.program_application_id,
				program_id = hz_utility_pub.program_id,
				program_update_date = sysdate
		Where ship_to_party_id = p_from_fk_id
		OR ship_to_cust_party_id = p_from_fk_id;

		l_count := sql%rowcount;

		arp_message.set_name('AR', 'AR_ROWS_UPDATED');
		arp_message.set_token('NUM_ROWS', to_char(l_count) );

		return;

	Elsif p_parent_entity_name = 'HZ_PARTY_SITES' Then

		arp_message.set_name('AR', 'AR_UPDATING_TABLE');
	 	arp_message.set_token('TABLE_NAME','ASO_SHIPMENTS', FALSE);

		UPDATE ASO_SHIPMENTS SET
				ship_to_party_site_id = p_to_fk_id,
				last_update_date = hz_utility_pub.last_update_date,
				last_updated_by  = hz_utility_pub.user_id,
				last_update_login = hz_utility_pub.last_update_login,
				request_id = hz_utility_pub.request_id,
				program_application_id = hz_utility_pub.program_application_id,
				program_id = hz_utility_pub.program_id,
				program_update_date = sysdate
		Where ship_to_party_site_id = p_from_fk_id;

		l_count := sql%rowcount;

		arp_message.set_name('AR', 'AR_ROWS_UPDATED');
		arp_message.set_token('NUM_ROWS', to_char(l_count) );

		return;

	End If;

End If;

arp_message.set_line('ASO_MERGE_PVT.MERGE_SHIPMENTS()-');

Exception
	When RESOURCE_BUSY Then
		arp_message.set_line('ASO_MERGE_PVT.MERGE_SHIPMENTS; Could not obtain lock'||
					'on table ASO_SHIPMENTS');

		 x_return_status :=  FND_API.G_RET_STS_ERROR;
		 raise;
	When Others Then
		arp_message.set_line('ASO_MERGE_PVT.MERGE_SHIPMENTS'||sqlerrm);
		x_return_status :=  FND_API.G_RET_STS_ERROR;
		raise;

END MERGE_SHIPMENTS;

END ASO_MERGE_PVT;

/
