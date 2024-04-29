--------------------------------------------------------
--  DDL for Package Body RLM_CUST_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_CUST_MERGE" AS
/* $Header: RLMCMRGB.pls 120.1 2005/07/17 18:24:51 rlanka noship $ */

--
--

 l_merge_hdrs_lines_msg		VARCHAR2(2000)	:= getMessage('RLM_MERGE_HDRS_LINES');
 l_hdrs_lines_msg_length	NUMBER(5)	:= LENGTHB(l_merge_hdrs_lines_msg);
 l_column_size			NUMBER(5)	:= 4000;
/*2447493*/
 l_profile_val VARCHAR2(30):=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

/*==========================================================================
  PROCEDURE Merge

===========================================================================*/


PROCEDURE Merge(REQ_ID NUMBER, SET_NUM NUMBER, PROCESS_MODE VARCHAR2)
 --
IS
 --
    l_duplicateIdTab		g_number_tbl_type;
    l_customerIdTab		g_number_tbl_type;
    l_duplicateAddressIdTab	g_number_tbl_type;
    l_customerAddressIdTab	g_number_tbl_type;
    l_duplicateSiteIdTab	g_number_tbl_type;
    l_customerSiteIdTab		g_number_tbl_type;

BEGIN
 --

   arp_message.set_line('RLM_CUST_MERGE.Merge_RLM()+' || getTimeStamp);
   --
   --
   IF Process_Mode <> 'LOCK'
   THEN
       SELECT			duplicate_id, customer_id,
                      		duplicate_address_id, customer_address_id,
                      		duplicate_site_id, customer_site_id
       BULK COLLECT INTO	l_duplicateIdTab, l_customerIdTab,
				l_duplicateAddressIdTab, l_customerAddressIdTab,
				l_duplicateSiteIdTab, l_customerSiteIdTab
       FROM              	ra_customer_merges
       WHERE             	process_flag = 'N'
       AND               	request_id   = Req_Id
       AND               	set_number   = Set_Num;
   END IF;
   --
   --
   IF NOT( RLM_CUST_MERGE.IS_RLM_INSTALLED() )
   THEN
     RETURN;
   END IF;
   --
   /* Calls to other internal procedures for customer Merge */
   --
   RLM_CUST_MERGE.Cust_Item_Cum_Keys(Req_Id, Set_Num, Process_Mode);
   --
   RLM_CUST_MERGE.Interface_Lines(Req_Id, Set_Num, Process_Mode);
   --
   RLM_CUST_MERGE.Interface_Headers(Req_Id, Set_Num, Process_Mode);
   --
   RLM_CUST_MERGE.Schedule_Lines(Req_Id, Set_Num, Process_Mode);
   --
   RLM_CUST_MERGE.Schedule_Headers(Req_Id, Set_Num, Process_Mode);
   --
   RLM_CUST_MERGE.Cust_Shipto_Terms(l_duplicateAddressIdTab, l_customerAddressIdTab, l_duplicateIdTab, l_customerIdTab, Req_Id, Set_Num, Process_Mode);
   --
   RLM_CUST_MERGE.Cust_Item_Terms(l_duplicateAddressIdTab, l_customerAddressIdTab, l_duplicateIdTab, l_customerIdTab, Req_Id, Set_Num, Process_Mode);
   --
   arp_message.set_line('RLM_CUST_MERGE.Merge_RLM()-' || getTimeStamp);

END Merge;


/*===========================================================================

  PROCEDURE Cust_Item_Cum_Keys

===========================================================================*/
PROCEDURE Cust_Item_Cum_Keys(REQ_ID NUMBER,
                             SET_NUM NUMBER,
                             PROCESS_MODE VARCHAR2)
 --
IS
 --
        l_cumKeyIdTab g_number_tbl_type;
        l_cumNotesTab g_varchar_tbl_type;
        l_duplicateAddressIdTab g_number_tbl_type;
        l_customerAddressIdTab g_number_tbl_type;
 --
        l_max_message_size NUMBER(5);
	l_merge_cum_keys_msg	VARCHAR2(2000)	:= getMessage('RLM_MERGE_CUM_KEYS');
	l_cum_keys_msg_length	NUMBER(5)	:= LENGTHB(l_merge_cum_keys_msg);
 --
   CURSOR cust_merge_cur IS
   SELECT ck.cum_key_id,
	  ck.cum_note_text,
	  m.duplicate_address_id,
          m.customer_address_id
   FROM   RLM_CUST_ITEM_CUM_KEYS ck,
	  RA_CUSTOMER_MERGES m
   WHERE  m.process_flag = 'N'
   AND	  m.request_id = req_id
   AND    m.set_number = set_num
   AND    (ck.intrmd_ship_to_id	= m.duplicate_address_id
   OR     ck.ship_to_address_id = m.duplicate_address_id
   OR     ck.bill_to_address_id	= m.duplicate_address_id)
   FOR	   update of ck.intrmd_ship_to_id,
		     ck.ship_to_address_id,
		     ck.bill_to_address_id,
		     ck.cum_note_text
		     nowait;
 --
 --
   i NUMBER;
 --
 --
BEGIN
   --
   arp_message.set_line('RLM_CUST_MERGE.Cust_Item_Cum_Keys()+' || getTimeStamp );
   --
   IF (process_mode = 'LOCK') THEN
     --
     setARMessageLockTable('RLM_CUST_ITEM_CUM_KEYS');
     --
     open cust_merge_cur;
     close cust_merge_cur;
     --
   ELSE
     --
        --
     l_max_message_size := l_column_size - ( l_cum_keys_msg_length + 1 );
     --
     open cust_merge_cur;
     --
     FETCH cust_merge_cur BULK COLLECT INTO     l_cumKeyIdTab,
                                                l_cumNotesTab,
                                                l_duplicateAddressIdTab,
                                                l_customerAddressIdTab;
     --
     close cust_merge_cur;
     --
     IF l_cumKeyIdTab.COUNT <> 0 THEN

       FOR i IN l_cumKeyIdTab.FIRST..l_cumKeyIdTab.LAST LOOP
         --
         IF ( LENGTHB(l_cumNotesTab(i)) <= l_max_message_size ) THEN
           --
           l_cumNotesTab(i) := l_cumNotesTab(i) || ' ' || l_merge_cum_keys_msg;
           --
         ELSE
           --
           l_cumNotesTab(i) := SUBSTRB(l_cumNotesTab(i), 1, l_max_message_size) || ' '
   || l_merge_cum_keys_msg;
           --
         END IF;
         --
       END LOOP;
       --
/*2447493*/
       RLM_CUST_ITEM_CUM_KEYS_LOG (
        req_id => req_id,
        set_num=>set_num,
        process_mode=>process_mode) ;
/*2447493*/
       --
       setARMessageUpdateTable('RLM_CUST_ITEM_CUM_KEYS');
       --
       FORALL i IN l_cumKeyIdTab.FIRST..l_cumKeyIdTab.LAST
         --
         UPDATE RLM_CUST_ITEM_CUM_KEYS
         SET    intrmd_ship_to_id       = DECODE(intrmd_ship_to_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 intrmd_ship_to_id
                                                 ),
                ship_to_address_id      = DECODE(ship_to_address_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 ship_to_address_id
                                                ),
                bill_to_address_id      = DECODE(bill_to_address_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 bill_to_address_id
                                                ),
                inactive_flag           = 'Y',
                cum_note_text           = l_cumNotesTab(i),
                last_update_date        = SYSDATE,
                last_updated_by         = arp_standard.profile.user_id,
                last_update_login       = arp_standard.profile.last_update_login,
                request_id              = req_id,
                program_application_id  = arp_standard.profile.program_application_id,
                program_id              = arp_standard.profile.program_id,
                program_update_date     = SYSDATE
       WHERE    cum_key_id              = l_cumKeyIdTab(i);
       --
     setARMessageRowCount( SQL%ROWCOUNT );
     --
     END IF;
   --
   END IF;
   --
   arp_message.set_line('RLM_CUST_MERGE.Cust_Item_Cum_Keys()-' || getTimeStamp );
   --
 EXCEPTION
   --
   WHEN OTHERS THEN
     --
     arp_message.set_error('RLM_CUST_MERGE.Cust_Item_Cum_Keys');
     RAISE;
     --
END Cust_Item_Cum_Keys;

/*===========================================================================

  PROCEDURE Interface_Headers

===========================================================================*/
PROCEDURE Interface_Headers(REQ_ID NUMBER,
                            SET_NUM NUMBER,
                            PROCESS_MODE VARCHAR2)
IS
 --
 	l_headerIdTab g_number_tbl_type;
 	l_headerNotesTab g_varchar_tbl_type;
 	l_duplicateIdTab g_number_tbl_type;
 	l_customerIdTab g_number_tbl_type;
 	l_duplicateAddressIdTab g_number_tbl_type;
 	l_customerAddressIdTab g_number_tbl_type;
        l_customerNameTab      t_CuatomerNameTbl;
 --
        l_max_message_size NUMBER(5);
 --
   CURSOR cust_merge_cur IS
   SELECT ih.header_id,
	  ih.header_note_text,
	  m.duplicate_id,
	  m.customer_id,
	  m.duplicate_address_id,
	  m.customer_address_id,
          --bug 2171856
          m.customer_name
   FROM   RLM_INTERFACE_HEADERS ih,
	  RA_CUSTOMER_MERGES m
   WHERE  m.process_flag = 'N'
   AND    m.request_id = req_id
   AND    m.set_number = set_num
   AND	  (ih.customer_id = m.duplicate_id
   OR     ih.ece_primary_address_id = m.duplicate_address_id)
   FOR    update of ih.header_id,
	  ih.customer_id,
          ih.ece_primary_address_id,
	  ih.header_note_text
	  nowait;

 --
 --
   i NUMBER;
 --
 --
BEGIN
   --
   arp_message.set_line('RLM_CUST_MERGE.Interface_Headers()+' || getTimeStamp);
   --

   IF (process_mode = 'LOCK') THEN
     --
     setARMessageLockTable('RLM_INTERFACE_HEADERS');
     --
     open cust_merge_cur;
     close cust_merge_cur;
     --
   ELSE
     --
     l_max_message_size := l_column_size - ( l_hdrs_lines_msg_length + 1 );
     --
     open cust_merge_cur;
     --
     FETCH cust_merge_cur BULK COLLECT INTO	l_headerIdTab,
						l_headerNotesTab,
						l_duplicateIdTab,
						l_customerIdTab,
						l_duplicateAddressIdTab,
						l_customerAddressIdTab,
                                                l_customerNameTab;
     --
     close cust_merge_cur;
     --
     IF l_headerIdTab.COUNT <> 0 THEN
     --
       FOR i IN l_headerIdTab.FIRST..l_headerIdTab.LAST LOOP
         --
         IF ( LENGTHB(l_headerNotesTab(i)) <= l_max_message_size ) THEN
	   --
	   l_headerNotesTab(i) := l_headerNotesTab(i) || ' ' || l_merge_hdrs_lines_msg;
	   --
         ELSE
	   --
	   l_headerNotesTab(i) := SUBSTRB(l_headerNotesTab(i), 1, l_max_message_size) || ' ' || l_merge_hdrs_lines_msg;
	   --
         END IF;
       --
       END LOOP;
       --
/*2447493*/
        RLM_INTERFACE_HEADERS_LOG (
       		req_id=>req_id,
        	set_num=>set_num,
        	process_mode=>process_mode);
/*2447493*/
       setARMessageUpdateTable('RLM_INTERFACE_HEADERS');
       --
       FORALL i IN l_headerIdTab.FIRST..l_headerIdTab.LAST
         --
         UPDATE RLM_INTERFACE_HEADERS
         SET    customer_id             = DECODE(customer_id,
                                                 l_duplicateIdTab(i),
                                                 l_customerIdTab(i),
                                                 customer_id
                                                 ),
                cust_name_ext           = DECODE(customer_id,
                                                 l_duplicateIdTab(i),
                                                 l_customerNameTab(i),
                                                 cust_name_ext
                                                 ),
                ece_primary_address_id  = DECODE(ece_primary_address_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 ece_primary_address_id
                                                ),
                header_note_text        = l_headerNotesTab(i),
                last_update_date        = SYSDATE,
                last_updated_by         = arp_standard.profile.user_id,
                last_update_login       = arp_standard.profile.last_update_login,
                request_id              = req_id,
                program_application_id  = arp_standard.profile.program_application_id,
                program_id              = arp_standard.profile.program_id,
                program_update_date     = SYSDATE
         WHERE  header_id               = l_headerIdTab(i);
       --
       setARMessageRowCount( SQL%ROWCOUNT );
       --
     END IF;
     --
   END IF;
     --
   arp_message.set_line('RLM_CUST_MERGE.Interface_Headers()-' || getTimeStamp);

 EXCEPTION
   --
   WHEN OTHERS THEN
     --
     arp_message.set_error('RLM_CUST_MERGE.Interface_Headers');
     RAISE;
     --
END Interface_Headers;

/*===========================================================================

  PROCEDURE Interface_Lines

===========================================================================*/
PROCEDURE Interface_Lines(REQ_ID NUMBER,
                          SET_NUM NUMBER,
                          PROCESS_MODE VARCHAR2)
IS
 --
	l_lineIdTab g_number_tbl_type;
	l_lineNotesTab g_varchar_tbl_type;
	l_duplicateAddressIdTab g_number_tbl_type;
	l_customerAddressIdTab g_number_tbl_type;
	l_duplicateSiteIdTab g_number_tbl_type;
	l_customerSiteIdTab g_number_tbl_type;
        l_DuplicateIdTab   g_number_tbl_type;
        l_ShipToCustomerIdTab   g_number_tbl_type;
 --
        l_max_message_size NUMBER(5);
 --
   CURSOR cust_merge_cur IS
   SELECT il.line_id,
	  il.item_note_text,
	  m.duplicate_address_id,
	  m.customer_address_id,
	  m.duplicate_site_id,
	  m.customer_site_id,
          m.duplicate_id,
          m.customer_id
   FROM   RLM_INTERFACE_LINES il,
	  RA_CUSTOMER_MERGES m
   WHERE  m.process_flag		= 'N'
   AND    m.request_id			= req_id
   AND    m.set_number			= set_num
   AND    (il.bill_to_address_id	= m.duplicate_address_id
   OR     il.intrmd_ship_to_id		= m.duplicate_address_id
   OR     il.ship_to_address_id		= m.duplicate_address_id
   OR     il.ship_to_customer_id        = m.duplicate_id)
   FOR    update of il.bill_to_address_id,
                 il.intrmd_ship_to_id,
                 il.ship_to_address_id,
                 il.item_note_text,
                il.ship_to_customer_id
                 nowait;
 --
   i NUMBER;
 --
 --
BEGIN
   --
   arp_message.set_line('RLM_CUST_MERGE.Interface_Lines()+' || getTimeStamp);
   --
   IF (process_mode = 'LOCK') THEN
     --
     setARMessageLockTable('RLM_INTERFACE_LINES');
     --
     open cust_merge_cur;
     --
     close cust_merge_cur;
     --
   ELSE
     --
     l_max_message_size := l_column_size - ( l_hdrs_lines_msg_length + 1 );
     --
     open cust_merge_cur;
     --
     FETCH cust_merge_cur BULK COLLECT INTO	l_lineIdTab,
						l_lineNotesTab,
						l_duplicateAddressIdTab,
						l_customerAddressIdTab,
						l_duplicateSiteIdTab,
						l_customerSiteIdTab,
                                                l_duplicateIdTab,
                                                l_ShipToCustomerIdTab;
     --
     close cust_merge_cur;
     --
     IF l_lineIdTab.COUNT <> 0 THEN
     --
       FOR i IN l_lineIdTab.FIRST..l_lineIdTab.LAST LOOP
         --
         IF ( LENGTHB(l_lineNotesTab(i)) <= l_max_message_size ) THEN
	   --
	   l_lineNotesTab(i) := l_lineNotesTab(i) || ' ' || l_merge_hdrs_lines_msg;
	   --
         ELSE
	   --
	   l_lineNotesTab(i) := SUBSTRB(l_lineNotesTab(i), 1, l_max_message_size) || ' ' || l_merge_hdrs_lines_msg;
	   --
         END IF;
         --
       END LOOP;
       --
/*2447493*/
       RLM_INTERFACE_LINES_LOG (
        req_id => req_id,
        set_num=>set_num,
        process_mode=>process_mode) ;
/*2447493*/
       setARMessageUpdateTable('RLM_INTERFACE_LINES');
       --
       FORALL i IN l_lineIdTab.FIRST..l_lineIdTab.LAST
         --
         UPDATE RLM_INTERFACE_LINES
         SET
                  ship_to_customer_id    = DECODE(ship_to_customer_id,
                                                 l_duplicateIdTab(i),
                                                 l_ShiptoCustomerIdTab(i),
                                                 ship_to_customer_id
                                                 ),
                  invoice_to_org_id     = DECODE(invoice_to_org_id,
                                                 l_duplicateSiteIdTab(i),
                                                 l_customerSiteIdTab(i),
                                                 invoice_to_org_id
                                                ),
                  bill_to_address_id    = DECODE(bill_to_address_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 bill_to_address_id
                                                 ),
                  intmed_ship_to_org_id = DECODE(intmed_ship_to_org_id,
                                                 l_duplicateSiteIdTab(i),
                                                 l_customerSiteIdTab(i),
                                                 intmed_ship_to_org_id
                                                ),
                  intrmd_ship_to_id     = DECODE(intrmd_ship_to_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 intrmd_ship_to_id
                                                ),
                  ship_to_address_id    = DECODE(ship_to_address_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 ship_to_address_id
                                                 ),
                  ship_to_org_id        = DECODE(ship_to_org_id,
                                                 l_duplicateSiteIdTab(i),
                                                 l_customerSiteIdTab(i),
                                                 ship_to_org_id
                                                ),
                  item_note_text        = l_lineNotesTab(i),
                  last_update_date      = SYSDATE,
                  last_updated_by               = arp_standard.profile.user_id,
                  last_update_login     = arp_standard.profile.last_update_login,
                  request_id            = req_id,
                  program_application_id= arp_standard.profile.program_application_id,
                  program_id            = arp_standard.profile.program_id,
                  program_update_date   = SYSDATE
         WHERE  line_id                 = l_lineIdTab(i);
         --
       setARMessageRowCount( SQL%ROWCOUNT );
       --
     END IF;
       --
   END IF;
   --
   arp_message.set_line('RLM_CUST_MERGE.Interface_Lines()-' || getTimeStamp);
   --
 EXCEPTION
   --
   WHEN others THEN
     --
     arp_message.set_error('RLM_CUST_MERGE.Interface_Lines');
     RAISE;
     --
END Interface_Lines;
/*===========================================================================

  PROCEDURE Schedule_Headers

===========================================================================*/
PROCEDURE Schedule_Headers(REQ_ID NUMBER,
                           SET_NUM NUMBER,
                           PROCESS_MODE VARCHAR2)
IS
 --
 	l_headerIdTab g_number_tbl_type;
 	l_headerNotesTab g_varchar_tbl_type;
 	l_duplicateIdTab g_number_tbl_type;
 	l_customerIdTab g_number_tbl_type;
 	l_duplicateAddressIdTab g_number_tbl_type;
 	l_customerAddressIdTab g_number_tbl_type;
        l_customerNameTab      t_CuatomerNameTbl;
 --
        l_max_message_size NUMBER(5);
 --
   CURSOR cust_merge_cur IS
   SELECT sh.header_id,
          sh.header_note_text,
          m.duplicate_id,
          m.customer_id,
          m.duplicate_address_id,
          m.customer_address_id,
          m.customer_name
   FROM   RLM_SCHEDULE_HEADERS sh,
	  RA_CUSTOMER_MERGES m
	  WHERE  m.process_flag = 'N'
   AND    m.request_id = req_id
   AND    m.set_number = set_num
   AND    (sh.customer_id = m.duplicate_id
   OR     sh.ece_primary_address_id = m.duplicate_address_id)
   FOR    update of sh.header_id,
          sh.customer_id,
          sh.ece_primary_address_id,
          sh.header_note_text nowait;

 --
 --
   i NUMBER;
 --
 --
BEGIN
   --
   arp_message.set_line('RLM_CUST_MERGE.Schedule_Headers()+' || getTimeStamp);
   --
   IF (process_mode = 'LOCK') THEN
     --
     setARMessageLockTable('RLM_SCHEDULE_HEADERS');
     open cust_merge_cur;
     close cust_merge_cur;
     --
   ELSE
     --
     l_max_message_size := l_column_size - ( l_hdrs_lines_msg_length + 1 );
     --
     open cust_merge_cur;
     --
     FETCH cust_merge_cur BULK COLLECT INTO	l_headerIdTab,
						l_headerNotesTab,
						l_duplicateIdTab,
						l_customerIdTab,
						l_duplicateAddressIdTab,
						l_customerAddressIdTab,
                                                l_customerNameTab ;
     --
     close cust_merge_cur;
     --
     IF l_headerIdTab.COUNT <> 0 THEN
     --
       FOR i IN l_headerIdTab.FIRST..l_headerIdTab.LAST LOOP
         --
         IF ( LENGTHB(l_headerNotesTab(i)) <= l_max_message_size ) THEN
    	   --
	   l_headerNotesTab(i) := l_headerNotesTab(i) || ' ' || l_merge_hdrs_lines_msg;
	   --
         ELSE
	   --
	   l_headerNotesTab(i) := SUBSTRB(l_headerNotesTab(i), 1, l_max_message_size) || ' ' || l_merge_hdrs_lines_msg;
	   --
         END IF;
         --
       END LOOP;
       --
/*2447493*/
        RLM_SCHEDULE_HEADERS_LOG (
                req_id=>req_id,
                set_num=>set_num,
                process_mode=>process_mode);
/*2447493*/
       setARMessageUpdateTable('RLM_SCHEDULE_HEADERS');
       --
       FORALL i IN l_headerIdTab.FIRST..l_headerIdTab.LAST
         --
         UPDATE RLM_SCHEDULE_HEADERS
         SET      customer_id           = DECODE(customer_id,
                                                 l_duplicateIdTab(i),
                                                 l_customerIdTab(i),
                                                 customer_id
                                                 ),
                cust_name_ext           = DECODE(customer_id,
                                                 l_duplicateIdTab(i),
                                                 l_customerNameTab(i),
                                                 cust_name_ext
                                                 ),
                  ece_primary_address_id= DECODE(ece_primary_address_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 ece_primary_address_id
                                                ),
                  header_note_text      = l_headerNotesTab(i),
                  last_update_date      = SYSDATE,
                  last_updated_by               = arp_standard.profile.user_id,
                  last_update_login     = arp_standard.profile.last_update_login,
                  request_id            = req_id,
                  program_application_id= arp_standard.profile.program_application_id,
                  program_id            = arp_standard.profile.program_id,
                  program_update_date   = SYSDATE
         WHERE  header_id               = l_headerIdTab(i);
         --
       setARMessageRowCount( SQL%ROWCOUNT );
       --
     END IF;
     --
   END IF;
   --
   arp_message.set_line('RLM_CUST_MERGE.Schedule_Headers()-' || getTimeStamp);

 EXCEPTION
   --
   WHEN others THEN
     --
     arp_message.set_error('RLM_CUST_MERGE.Schedule_Headers');
     RAISE;
     --
END Schedule_Headers;

/*===========================================================================

  PROCEDURE Schedule_Lines

===========================================================================*/
PROCEDURE Schedule_Lines(REQ_ID NUMBER,
                         SET_NUM NUMBER,
                         PROCESS_MODE VARCHAR2)
IS
 --
	l_lineIdTab g_number_tbl_type;
        l_lineNotesTab g_varchar_tbl_type;
        l_duplicateAddressIdTab g_number_tbl_type;
        l_customerAddressIdTab g_number_tbl_type;
        l_duplicateSiteIdTab g_number_tbl_type;
        l_customerSiteIdTab g_number_tbl_type;
        l_duplicateIdTab g_number_tbl_type;
        l_customerShiptoIdTab g_number_tbl_type;
 --
        l_max_message_size NUMBER(5);
 --
   CURSOR cust_merge_cur IS
   SELECT il.line_id,
          il.item_note_text,
          m.duplicate_address_id,
          m.customer_address_id,
          m.duplicate_site_id,
          m.customer_site_id,
          m.duplicate_id,
          m.customer_id
   FROM   RLM_SCHEDULE_LINES il,
          RA_CUSTOMER_MERGES m
   WHERE  m.process_flag		= 'N'
   AND    m.request_id			= req_id
   AND    m.set_number			= set_num
   AND    (il.bill_to_address_id	= m.duplicate_address_id
   OR     il.intrmd_ship_to_id		= m.duplicate_address_id
   OR     il.ship_to_address_id		= m.duplicate_address_id
   OR     il.ship_to_customer_id        = m.duplicate_id)
   FOR    update of il.bill_to_address_id,
		 il.intrmd_ship_to_id,
	         il.ship_to_address_id,
		 il.item_note_text,
                 il.ship_to_customer_id
		 nowait;
 --
 --
   i NUMBER;
 --
 --
BEGIN
   --
   arp_message.set_line('RLM_CUST_MERGE.Schedule_Lines()+' || getTimeStamp);
   --
   IF (process_mode = 'LOCK') THEN
     --
     setARMessageLockTable('RLM_SCHEDULE_LINES');
     --
     open cust_merge_cur;
     --
     close cust_merge_cur;
     --
   ELSE
     --
     l_max_message_size := l_column_size - ( l_hdrs_lines_msg_length + 1 );
     --
     open cust_merge_cur;
     --
     FETCH cust_merge_cur BULK COLLECT INTO     l_lineIdTab,
                                                l_lineNotesTab,
                                                l_duplicateAddressIdTab,
                                                l_customerAddressIdTab,
                                                l_duplicateSiteIdTab,
                                                l_customerSiteIdTab,
						l_duplicateIdTab,
						l_customerShiptoIdTab;
     --
     close cust_merge_cur;
     --
     IF l_lineIdTab.COUNT <> 0 THEN
     --
       FOR i IN l_lineIdTab.FIRST..l_lineIdTab.LAST LOOP
         --
         IF ( LENGTHB(l_lineNotesTab(i)) <= l_max_message_size ) THEN
	   --
	   l_lineNotesTab(i) := l_lineNotesTab(i) || ' ' || l_merge_hdrs_lines_msg;
	   --
         ELSE
	   --
	  l_lineNotesTab(i) := SUBSTRB(l_lineNotesTab(i), 1, l_max_message_size) || ' ' || l_merge_hdrs_lines_msg;
	   --
         END IF;
         --
       END LOOP;
       --
/*2447493*/
       RLM_SCHEDULE_LINES_LOG (
        req_id => req_id,
        set_num=>set_num,
        process_mode=>process_mode) ;
/*2447493*/
       setARMessageUpdateTable('RLM_SCHEDULE_LINES');
       --
       FORALL i IN l_lineIdTab.FIRST..l_lineIdTab.LAST
         --
         UPDATE  RLM_SCHEDULE_LINES
         SET      invoice_to_org_id     = DECODE(invoice_to_org_id,
                                                 l_duplicateSiteIdTab(i),
                                                 l_customerSiteIdTab(i),
                                                 invoice_to_org_id
                                                ),
                  ship_to_customer_id    = DECODE(ship_to_customer_id,
                                                 l_duplicateIdTab(i),
                                                 l_customerShiptoIdTab(i),
                                                 ship_to_customer_id
                                                 ),
                  bill_to_address_id    = DECODE(bill_to_address_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 bill_to_address_id
                                                 ),
                  intmed_ship_to_org_id = DECODE(intmed_ship_to_org_id,
                                                 l_duplicateSiteIdTab(i),
                                                 l_customerSiteIdTab(i),
                                                 intmed_ship_to_org_id
                                                ),
                  intrmd_ship_to_id     = DECODE(intrmd_ship_to_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 intrmd_ship_to_id
                                                ),
                  ship_to_address_id    = DECODE(ship_to_address_id,
                                                 l_duplicateAddressIdTab(i),
                                                 l_customerAddressIdTab(i),
                                                 ship_to_address_id
                                                 ),
                  ship_to_org_id        = DECODE(ship_to_org_id,
                                                 l_duplicateSiteIdTab(i),
                                                 l_customerSiteIdTab(i),
                                                 ship_to_org_id
                                                ),
                  item_note_text        = l_lineNotesTab(i),
                  last_update_date      = SYSDATE,
                  last_updated_by               = arp_standard.profile.user_id,
                  last_update_login     = arp_standard.profile.last_update_login,
                  request_id            = req_id,
                  program_application_id= arp_standard.profile.program_application_id,
                  program_id            = arp_standard.profile.program_id,
                  program_update_date   = SYSDATE
         WHERE   line_id                = l_lineIdTab(i);
       --
       setARMessageRowCount( SQL%ROWCOUNT );
       --
     END IF;
     --
   END IF;
   --
   arp_message.set_line('RLM_CUST_MERGE.Schedule_Lines()-' || getTimeStamp);
   --
 EXCEPTION
   --
   WHEN OTHERS THEN
     --
     arp_message.set_error('RLM_CUST_MERGE.Schedule_Lines');
     RAISE;
     --
END Schedule_Lines;

/*===========================================================================

  PROCEDURE Cust_Shipto_Terms

===========================================================================*/
PROCEDURE Cust_Shipto_Terms(p_duplicateAddressIdTab g_number_tbl_type,
                            p_customerAddressIdTab g_number_tbl_type,
                            p_duplicateIdTab g_number_tbl_type,
                            p_customerIdTab g_number_tbl_type,
                            REQ_ID NUMBER,
                            SET_NUM NUMBER,
                            PROCESS_MODE VARCHAR2)
 --
IS
 --
   CURSOR cust_merge_cur IS
   SELECT address_id,
	  customer_id
   FROM   RLM_CUST_SHIPTO_TERMS
   WHERE  customer_id in
          (select m.duplicate_id
           from     ra_customer_merges m
           where    m.process_flag = 'N'
           and m.request_id = req_id
           and m.set_number = set_num)
   OR     address_id in
          (select m.duplicate_address_id
           from     ra_customer_merges m
           where    m.process_flag = 'N'
           and m.request_id = req_id
           and m.set_number = set_num)
   FOR	   update nowait;

/*2447493*/
  CURSOR merge_records_cur IS
       SELECT distinct CUSTOMER_MERGE_HEADER_ID
       FROM rlm_cust_shipto_terms yt,ra_customer_merges m
       where yt.customer_id = m.duplicate_id
       AND    m.process_flag = 'N'
       AND    m.request_id = req_id
       AND    m.set_number = set_num;

  CURSOR cust_shipto_terms_cur is
       SELECT * from rlm_cust_shipto_terms
		        where customer_id in
		   	(select m.duplicate_id
		           	from     ra_customer_merges m
		           	where    m.process_flag = 'N'
		           	and m.request_id = req_id
		           	and m.set_number = set_num)
		   OR     	address_id in
		          	(select m.duplicate_address_id
		           	from     ra_customer_merges m
		           	where    m.process_flag = 'N'
		           	and m.request_id = req_id
		           	and m.set_number = set_num)
		   FOR	update nowait;


  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

 --
   i NUMBER;
   l_last_fetch BOOLEAN := FALSE;
 --
 --
BEGIN
   --
   arp_message.set_line('RLM_CUST_MERGE.Cust_Shipto_Terms()+' || getTimeStamp);
   --
   IF (process_mode = 'LOCK') THEN
     --
     setARMessageLockTable('RLM_CUST_SHIPTO_TERMS');
     --
     open cust_merge_cur;
     close cust_merge_cur;
     --
   ELSE
     --
     open merge_records_cur;

  FETCH merge_records_cur BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
 	 limit 1000;


  IF merge_records_cur%NOTFOUND THEN
         l_last_fetch := TRUE;
  END IF;
  close merge_records_cur;

  /*IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
	   exit;
  END IF;*/
 IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
 --
 FOR I in 1..MERGE_HEADER_ID_LIST.COUNT
  LOOP
  --
  FOR cust_shipto_terms in cust_shipto_terms_cur
   --
   LOOP

   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
     	 MERGE_LOG_ID,
     	 TABLE_NAME,
     	 MERGE_HEADER_ID,
         DEL_COL1,
	 DEL_COL2,
	 DEL_COL3 ,
	 DEL_COL4 ,
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
	 DEL_COL34 ,
	 DEL_COL35,
	 DEL_COL36,
	 DEL_COL37,
	 DEL_COL38,
	 DEL_COL39,
	 DEL_COL40,
	 DEL_COL41,
	 DEL_COL42,
	 DEL_COL43,
	 DEL_COL44,
	 DEL_COL45,
	 DEL_COL46,
	 DEL_COL47,
	 DEL_COL48,
	 DEL_COL49,
	 DEL_COL50,
	 DEL_COL51,
	 DEL_COL52,
	 DEL_COL53,
	 DEL_COL54,
	 DEL_COL55,
	 DEL_COL56,
	 DEL_COL57,
	 DEL_COL58,
	 DEL_COL59,
	 DEL_COL60,
	 DEL_COL61,
	 DEL_COL62,
	 DEL_COL63,
	 DEL_COL64,
	 DEL_COL65,
	 DEL_COL66,
	 DEL_COL67,
	 DEL_COL68,
	 DEL_COL69,
	 DEL_COL70,
	 DEL_COL71,
	 DEL_COL72,
	 DEL_COL73,
	 DEL_COL74,
	 DEL_COL75,
	 DEL_COL76,
	 DEL_COL77,
	 DEL_COL78,
	 DEL_COL79,
	 DEL_COL80,
	 DEL_COL81,
	 DEL_COL82,
	 DEL_COL83,
	 DEL_COL84,
	 DEL_COL85,
	 DEL_COL86,
	 DEL_COL87,
	 DEL_COL88,
	 DEL_COL89,
	 DEL_COL90,
	 DEL_COL91,
	 DEL_COL92,
	 DEL_COL93,
	 DEL_COL94,
	 DEL_COL95,
	 DEL_COL96,
	 DEL_COL97,
	 DEL_COL98,
	 DEL_COL99,
	 DEL_COL100,
	 DEL_COL101,
	 DEL_COL102,
	 DEL_COL103,
	 DEL_COL104,
	 DEL_COL105,
	 DEL_COL106,
	 DEL_COL107,
	 DEL_COL108,
	 DEL_COL109,
	 DEL_COL110,
	 DEL_COL111,
	 DEL_COL112,
         DEL_COL113,
         DEL_COL114,
	 DEL_COL115,
	 DEL_COL116,
         DEL_COL117,
         DEL_COL118,
         DEL_COL119,
        ACTION_FLAG,
	REQUEST_ID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY)
Values
(	HZ_CUSTOMER_MERGE_LOG_s.nextval,
 	'RLM_CUST_SHIPTO_TERMS',
	MERGE_HEADER_ID_LIST(I),
	cust_shipto_terms.CUST_SHIPTO_TERMS_ID,
 	cust_shipto_terms.ADDRESS_ID,
 	cust_shipto_terms.CUSTOMER_ID,
 	cust_shipto_terms.SHIP_FROM_ORG_ID,
 	cust_shipto_terms.CUM_CONTROL_CODE,
 	cust_shipto_terms.SHIP_METHOD,
 	cust_shipto_terms.INTRANSIT_TIME,
 	cust_shipto_terms.TIME_UOM_CODE,
 	cust_shipto_terms.SHIP_DELIVERY_RULE_NAME,
 	cust_shipto_terms.CUM_CURRENT_RECORD_YEAR,
 	cust_shipto_terms.CUM_PREVIOUS_RECORD_YEAR,
 	cust_shipto_terms.CUM_CURRENT_START_DATE,
 	cust_shipto_terms.CUM_PREVIOUS_START_DATE,
 	cust_shipto_terms.CUM_ORG_LEVEL_CODE,
 	cust_shipto_terms.CUM_SHIPMENT_RULE_CODE,
 	cust_shipto_terms.CUM_YESTERD_TIME_CUTOFF,
 	cust_shipto_terms.CUST_ASSIGN_SUPPLIER_CD,
 	cust_shipto_terms.CUSTOMER_RCV_CALENDAR_CD,
 	cust_shipto_terms.FREIGHT_CODE,
 	cust_shipto_terms.SUPPLIER_SHP_CALENDAR_CD,
 	cust_shipto_terms.UNSHIP_FIRM_CUTOFF_DAYS,
 	cust_shipto_terms.UNSHIPPED_FIRM_DISP_CD,
 	cust_shipto_terms.USE_EDI_SDP_CODE_FLAG,
	cust_shipto_terms.DEMAND_TOLERANCE_ABOVE,
	cust_shipto_terms.DEMAND_TOLERANCE_BELOW,
	cust_shipto_terms.INACTIVE_DATE,
	cust_shipto_terms.HEADER_ID,
 	cust_shipto_terms.PRICE_LIST_ID,
 	cust_shipto_terms.CRITICAL_ATTRIBUTE_KEY,
 	cust_shipto_terms.CUSTOMER_CONTACT_ID,
 	cust_shipto_terms.PLN_FIRM_DAY_FROM,
 	cust_shipto_terms.PLN_FIRM_DAY_TO,
 	cust_shipto_terms.PLN_FORECAST_DAY_FROM,
 	cust_shipto_terms.PLN_FORECAST_DAY_TO,
 	cust_shipto_terms.PLN_FROZEN_DAY_TO,
 	cust_shipto_terms.PLN_FROZEN_DAY_FROM,
 	cust_shipto_terms.SEQ_FIRM_DAY_FROM,
 	cust_shipto_terms.SEQ_FIRM_DAY_TO,
 	cust_shipto_terms.SEQ_FORECAST_DAY_TO,
 	cust_shipto_terms.SEQ_FORECAST_DAY_FROM,
 	cust_shipto_terms.SEQ_FROZEN_DAY_FROM,
 	cust_shipto_terms.SEQ_FROZEN_DAY_TO,
 	cust_shipto_terms.SHP_FIRM_DAY_FROM,
 	cust_shipto_terms.SHP_FIRM_DAY_TO,
 	cust_shipto_terms.SHP_FROZEN_DAY_TO,
 	cust_shipto_terms.SHP_FROZEN_DAY_FROM,
 	cust_shipto_terms.SHP_FORECAST_DAY_TO,
 	cust_shipto_terms.ROUND_TO_STD_PACK_FLAG,
 	cust_shipto_terms.SUPPLIER_CONTACT_ID,
 	cust_shipto_terms.AGREEMENT_NAME,
 	cust_shipto_terms.STD_PACK_QTY,
 	cust_shipto_terms.FUTURE_AGREEMENT_NAME,
 	cust_shipto_terms.SHP_FORECAST_DAY_FROM,
 	cust_shipto_terms.SCHEDULE_HIERARCHY_CODE,
 	cust_shipto_terms.COMMENTS,
	cust_shipto_terms.LAST_UPDATED_BY,
 	cust_shipto_terms.LAST_UPDATE_DATE,
 	cust_shipto_terms.CREATION_DATE,
 	cust_shipto_terms.CREATED_BY,
 	cust_shipto_terms.ATTRIBUTE_CATEGORY,
 	cust_shipto_terms.ATTRIBUTE1,
 	cust_shipto_terms.ATTRIBUTE2,
 	cust_shipto_terms.ATTRIBUTE3,
 	cust_shipto_terms.ATTRIBUTE4,
 	cust_shipto_terms.ATTRIBUTE5,
 	cust_shipto_terms.ATTRIBUTE6,
 	cust_shipto_terms.ATTRIBUTE7,
 	cust_shipto_terms.ATTRIBUTE8,
 	cust_shipto_terms.ATTRIBUTE9,
 	cust_shipto_terms.ATTRIBUTE10,
 	cust_shipto_terms.ATTRIBUTE11,
 	cust_shipto_terms.ATTRIBUTE12,
 	cust_shipto_terms.ATTRIBUTE13,
 	cust_shipto_terms.ATTRIBUTE14,
 	cust_shipto_terms.ATTRIBUTE15,
 	cust_shipto_terms.LAST_UPDATE_LOGIN,
 	cust_shipto_terms.REQUEST_ID,
 	cust_shipto_terms.PROGRAM_APPLICATION_ID,
 	cust_shipto_terms.PROGRAM_ID,
 	cust_shipto_terms.PROGRAM_UPDATE_DATE,
 	cust_shipto_terms.TP_ATTRIBUTE1,
 	cust_shipto_terms.TP_ATTRIBUTE2,
 	cust_shipto_terms.TP_ATTRIBUTE3,
 	cust_shipto_terms.TP_ATTRIBUTE4,
	cust_shipto_terms.TP_ATTRIBUTE5,
 	cust_shipto_terms.TP_ATTRIBUTE6,
 	cust_shipto_terms.TP_ATTRIBUTE7,
 	cust_shipto_terms.TP_ATTRIBUTE8,
 	cust_shipto_terms.TP_ATTRIBUTE9,
 	cust_shipto_terms.TP_ATTRIBUTE10,
 	cust_shipto_terms.TP_ATTRIBUTE11,
 	cust_shipto_terms.TP_ATTRIBUTE12,
 	cust_shipto_terms.TP_ATTRIBUTE13,
 	cust_shipto_terms.TP_ATTRIBUTE14,
 	cust_shipto_terms.TP_ATTRIBUTE15,
 	cust_shipto_terms.TP_ATTRIBUTE_CATEGORY,
 	cust_shipto_terms.MATCH_ACROSS_KEY,
 	cust_shipto_terms.MATCH_WITHIN_KEY,
 	cust_shipto_terms.PLN_MRP_FORECAST_DAY_FROM,
 	cust_shipto_terms.PLN_MRP_FORECAST_DAY_TO,
 	cust_shipto_terms.SHP_MRP_FORECAST_DAY_FROM,
 	cust_shipto_terms.SHP_MRP_FORECAST_DAY_TO,
 	cust_shipto_terms.SEQ_MRP_FORECAST_DAY_FROM,
 	cust_shipto_terms.SEQ_MRP_FORECAST_DAY_TO,
 	cust_shipto_terms.INTRANSIT_CALC_BASIS,
 	cust_shipto_terms.DEFAULT_SHIP_FROM,
 	cust_shipto_terms.PLN_FROZEN_FLAG,
 	cust_shipto_terms.SHP_FROZEN_FLAG,
 	cust_shipto_terms.SEQ_FROZEN_FLAG,
	cust_shipto_terms.ISSUE_WARNING_DROP_PARTS_FLAG,
	cust_shipto_terms.ORG_ID,
	cust_shipto_terms.BLANKET_NUMBER,
	cust_shipto_terms.RELEASE_RULE,
	cust_shipto_terms.RELEASE_TIME_FRAME,
	cust_shipto_terms.RELEASE_TIME_FRAME_UOM,
	cust_shipto_terms.AGREEMENT_ID,
	cust_shipto_terms.FUTURE_AGREEMENT_ID,
        cust_shipto_terms.EXCLUDE_NON_WORKDAYS_FLAG,
        cust_shipto_terms.DISABLE_CREATE_CUM_KEY_FLAG,
        'D',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY);

    END LOOP;
    --
    END LOOP;
    --
   END IF;

    IF p_duplicateIdTab.COUNT <> 0 THEN
     --
     setARMessageDeleteTable('RLM_CUST_SHIPTO_TERMS');

     --
       FORALL i IN p_duplicateIdTab.FIRST..p_duplicateIdTab.LAST

         DELETE	RLM_CUST_SHIPTO_TERMS
         WHERE    (address_id              = p_duplicateAddressIdTab(i)
         OR       customer_id             = DECODE(p_duplicateIdTab(i),
	  					   p_customerIdTab(i),
						   -3.1428571,
						   p_duplicateIdTab(i)
						   ));
       --
       setARMessageRowCount( SQL%ROWCOUNT );
     --
     END IF;
     --
   END IF;
   --
   arp_message.set_line('RLM_CUST_MERGE.Cust_Shipto_Terms()-' || getTimeStamp);
   --
 EXCEPTION
   --
   WHEN others THEN
     --
     arp_message.set_error('RLM_CUST_MERGE.Cust_Shipto_Terms');
     RAISE;
     --
END Cust_Shipto_Terms;

/*==========================================================================

  PROCEDURE Cust_Item_Terms

===========================================================================*/
PROCEDURE Cust_Item_Terms(p_duplicateAddressIdTab g_number_tbl_type,
                          p_customerAddressIdTab g_number_tbl_type,
                          p_duplicateIdTab g_number_tbl_type,
                          p_customerIdTab g_number_tbl_type,
                          REQ_ID NUMBER,
                          SET_NUM NUMBER,
                          PROCESS_MODE VARCHAR2)
 --
IS
 --
   CURSOR cust_merge_cur IS
   SELECT address_id,
          customer_id
   FROM   RLM_CUST_ITEM_TERMS
   WHERE  customer_id in
          (select m.duplicate_id
           from     ra_customer_merges m
           where    m.process_flag = 'N'
           and m.request_id = req_id
           and m.set_number = set_num)
   OR     address_id in
          (select m.duplicate_address_id
           from     ra_customer_merges m
           where    m.process_flag = 'N'
           and m.request_id = req_id
           and m.set_number = set_num)
   FOR     update nowait;

/*2447493*/
  CURSOR merge_records_cur IS
       SELECT distinct CUSTOMER_MERGE_HEADER_ID
       FROM rlm_cust_shipto_terms yt,ra_customer_merges m
       where yt.customer_id = m.duplicate_id
       AND    m.process_flag = 'N'
       AND    m.request_id = req_id
       AND    m.set_number = set_num;

  CURSOR cust_item_terms_cur is
       SELECT * from rlm_cust_item_terms
		        where customer_id in
		   	(select m.duplicate_id
		           	from     ra_customer_merges m
		           	where    m.process_flag = 'N'
		           	and m.request_id = req_id
		           	and m.set_number = set_num)
		   OR     	address_id in
		          	(select m.duplicate_address_id
		           	from     ra_customer_merges m
		           	where    m.process_flag = 'N'
		           	and m.request_id = req_id
		           	and m.set_number = set_num)
		   FOR	update nowait;


  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;


 --
 --
   i NUMBER;
   l_last_fetch BOOLEAN := FALSE;
 --
 --
BEGIN
   --
   arp_message.set_line('RLM_CUST_MERGE.Cust_Item_Terms()+' || getTimeStamp);
   --
   IF (process_mode = 'LOCK') THEN
     --
     setARMessageLockTable('RLM_CUST_ITEM_TERMS');
     --
     open cust_merge_cur;
     --
     close cust_merge_cur;
     --
   ELSE
     --
     open merge_records_cur;

  FETCH merge_records_cur BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
	 limit 1000;

  IF merge_records_cur%NOTFOUND THEN
         l_last_fetch := TRUE;
  END IF;

  close merge_records_cur;

 /* IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
	   exit;
  END IF;*/

 IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
  FOR I in 1..MERGE_HEADER_ID_LIST.COUNT
  LOOP
  --
  FOR cust_item_terms in cust_item_terms_cur
   --
   LOOP

   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
     	 MERGE_LOG_ID,
     	 TABLE_NAME,
     	 MERGE_HEADER_ID,
         DEL_COL1,
	 DEL_COL2,
	 DEL_COL3 ,
	 DEL_COL4 ,
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
	 DEL_COL34 ,
	 DEL_COL35,
	 DEL_COL36,
	 DEL_COL37,
	 DEL_COL38,
	 DEL_COL39,
	 DEL_COL40,
	 DEL_COL41,
	 DEL_COL42,
	 DEL_COL43,
	 DEL_COL44,
	 DEL_COL45,
	 DEL_COL46,
	 DEL_COL47,
	 DEL_COL48,
	 DEL_COL49,
	 DEL_COL50,
	 DEL_COL51,
	 DEL_COL52,
	 DEL_COL53,
	 DEL_COL54,
	 DEL_COL55,
	 DEL_COL56,
	 DEL_COL57,
	 DEL_COL58,
	 DEL_COL59,
	 DEL_COL60,
	 DEL_COL61,
	 DEL_COL62,
	 DEL_COL63,
	 DEL_COL64,
	 DEL_COL65,
	 DEL_COL66,
	 DEL_COL67,
	 DEL_COL68,
	 DEL_COL69,
	 DEL_COL70,
	 DEL_COL71,
	 DEL_COL72,
	 DEL_COL73,
	 DEL_COL74,
	 DEL_COL75,
	 DEL_COL76,
	 DEL_COL77,
	 DEL_COL78,
	 DEL_COL79,
	 DEL_COL80,
	 DEL_COL81,
	 DEL_COL82,
	 DEL_COL83,
	 DEL_COL84,
	 DEL_COL85,
	 DEL_COL86,
	 DEL_COL87,
	 DEL_COL88,
	 DEL_COL89,
	 DEL_COL90,
	 DEL_COL91,
	 DEL_COL92,
	 DEL_COL93,
	 DEL_COL94,
	 DEL_COL95,
	 DEL_COL96,
	 DEL_COL97,
	 DEL_COL98,
	 DEL_COL99,
	 DEL_COL100,
	DEL_COL101,
	DEL_COL102,
	DEL_COL103,
	DEL_COL104,
	DEL_COL105,
	DEL_COL106,
        ACTION_FLAG,
	REQUEST_ID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY)
Values
(	HZ_CUSTOMER_MERGE_LOG_s.nextval,
 	'RLM_CUST_ITEM_TERMS',
	MERGE_HEADER_ID_LIST(I),
	cust_item_terms.CUST_ITEM_TERMS_ID,
	 cust_item_terms.CUSTOMER_ITEM_ID,
	 cust_item_terms.SHIP_FROM_ORG_ID,
	 cust_item_terms.ADDRESS_ID,
	 cust_item_terms.HEADER_ID,
	 cust_item_terms.AGREEMENT_NAME,
	 cust_item_terms.FUTURE_AGREEMENT_NAME,
	 cust_item_terms.CALC_CUM_FLAG,
	 cust_item_terms.CUM_CURRENT_START_DATE,
	 cust_item_terms.CUM_PREVIOUS_START_DATE,
	 cust_item_terms.CUST_ITEM_STATUS_CODE,
	 cust_item_terms.ROUND_TO_STD_PACK_FLAG,
	 cust_item_terms.SHIP_DELIVERY_RULE_NAME,
	 cust_item_terms.SHIP_METHOD,
	 cust_item_terms.INTRANSIT_TIME,
	 cust_item_terms.STD_PACK_QTY,
	 cust_item_terms.TIME_UOM_CODE,
	 cust_item_terms.PRICE_LIST_ID,
	 cust_item_terms.DEMAND_TOLERANCE_ABOVE,
	 cust_item_terms.USE_EDI_SDP_CODE_FLAG,
	 cust_item_terms.LAST_UPDATE_DATE,
	 cust_item_terms.LAST_UPDATED_BY,
	 cust_item_terms.CREATION_DATE,
	 cust_item_terms.CREATED_BY,
	 cust_item_terms.PLN_FIRM_DAY_TO,
	 cust_item_terms.ATTRIBUTE_CATEGORY,
	 cust_item_terms.PLN_FORECAST_DAY_FROM,
	 cust_item_terms.PLN_FORECAST_DAY_TO,
	 cust_item_terms.PLN_FROZEN_DAY_TO,
	 cust_item_terms.PLN_FROZEN_DAY_FROM,
	 cust_item_terms.ATTRIBUTE1,
	 cust_item_terms.SEQ_FIRM_DAY_FROM,
	 cust_item_terms.SEQ_FIRM_DAY_TO,
	 cust_item_terms.ATTRIBUTE2,
	 cust_item_terms.SEQ_FORECAST_DAY_TO,
	 cust_item_terms.SEQ_FORECAST_DAY_FROM,
	 cust_item_terms.ATTRIBUTE3,
	 cust_item_terms.SEQ_FROZEN_DAY_FROM,
	 cust_item_terms.SEQ_FROZEN_DAY_TO,
	 cust_item_terms.ATTRIBUTE4,
	 cust_item_terms.SHP_FIRM_DAY_FROM,
	 cust_item_terms.SHP_FIRM_DAY_TO,
	 cust_item_terms.ATTRIBUTE5,
	 cust_item_terms.SHP_FROZEN_DAY_TO,
	 cust_item_terms.SHP_FROZEN_DAY_FROM,
	 cust_item_terms.ATTRIBUTE6,
	 cust_item_terms.SHP_FORECAST_DAY_TO,
	 cust_item_terms.SHP_FORECAST_DAY_FROM,
	 cust_item_terms.ATTRIBUTE7,
	 cust_item_terms.ATTRIBUTE8,
	 cust_item_terms.ATTRIBUTE9,
	 cust_item_terms.ATTRIBUTE10,
	 cust_item_terms.ATTRIBUTE11,
	 cust_item_terms.ATTRIBUTE12,
	 cust_item_terms.ATTRIBUTE13,
	 cust_item_terms.ATTRIBUTE14,
	 cust_item_terms.ATTRIBUTE15,
	 cust_item_terms.LAST_UPDATE_LOGIN,
	 cust_item_terms.REQUEST_ID,
	 cust_item_terms.PROGRAM_APPLICATION_ID,
	 cust_item_terms.PROGRAM_ID,
	 cust_item_terms.PROGRAM_UPDATE_DATE,
	 cust_item_terms.DEMAND_TOLERANCE_BELOW,
	 cust_item_terms.CUSTOMER_CONTACT_ID,
	 cust_item_terms.CUSTOMER_ID,
	 cust_item_terms.FREIGHT_CODE,
	 cust_item_terms.PLN_FIRM_DAY_FROM,
	 cust_item_terms.SUPPLIER_CONTACT_ID,
	 cust_item_terms.TP_ATTRIBUTE1,
	 cust_item_terms.TP_ATTRIBUTE2,
	 cust_item_terms.TP_ATTRIBUTE3,
	 cust_item_terms.TP_ATTRIBUTE4,
	 cust_item_terms.TP_ATTRIBUTE5,
	 cust_item_terms.TP_ATTRIBUTE6,
	 cust_item_terms.TP_ATTRIBUTE7,
	 cust_item_terms.TP_ATTRIBUTE8,
	 cust_item_terms.TP_ATTRIBUTE9,
	 cust_item_terms.TP_ATTRIBUTE10,
	 cust_item_terms.TP_ATTRIBUTE11,
	 cust_item_terms.TP_ATTRIBUTE12,
	 cust_item_terms.TP_ATTRIBUTE13,
	 cust_item_terms.TP_ATTRIBUTE14,
	 cust_item_terms.TP_ATTRIBUTE15,
	 cust_item_terms.TP_ATTRIBUTE_CATEGORY,
	 cust_item_terms.INACTIVE_DATE,
	 cust_item_terms.COMMENTS,
	 cust_item_terms.DEFAULT_SHIP_FROM,
	 cust_item_terms.PLN_MRP_FORECAST_DAY_FROM,
	 cust_item_terms.PLN_MRP_FORECAST_DAY_TO,
	 cust_item_terms.SHP_MRP_FORECAST_DAY_FROM,
	 cust_item_terms.SHP_MRP_FORECAST_DAY_TO,
	 cust_item_terms.SEQ_MRP_FORECAST_DAY_FROM,
	 cust_item_terms.SEQ_MRP_FORECAST_DAY_TO,
	 cust_item_terms.PLN_FROZEN_FLAG,
	 cust_item_terms.SHP_FROZEN_FLAG,
	 cust_item_terms.SEQ_FROZEN_FLAG,
	 cust_item_terms.ISSUE_WARNING_DROP_PARTS_FLAG,
	 cust_item_terms.ORG_ID,
	 cust_item_terms.BLANKET_NUMBER,
	 cust_item_terms.RELEASE_RULE,
	 cust_item_terms.RELEASE_TIME_FRAME,
	 cust_item_terms.RELEASE_TIME_FRAME_UOM,
	 cust_item_terms.AGREEMENT_ID,
	 cust_item_terms.FUTURE_AGREEMENT_ID,
         cust_item_terms.EXCLUDE_NON_WORKDAYS_FLAG,
         cust_item_terms.DISABLE_CREATE_CUM_KEY_FLAG,
         'D',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY);
    END LOOP;
   --
   END LOOP;
   --
   END IF;

     IF p_duplicateIdTab.COUNT <> 0 THEN
     --
       setARMessageDeleteTable('RLM_CUST_ITEM_TERMS');
       --
       FORALL i IN p_duplicateIdTab.FIRST..p_duplicateIdTab.LAST
         --
         DELETE	RLM_CUST_ITEM_TERMS
         WHERE	(address_id		= p_duplicateAddressIdTab(i)
         OR     customer_id		= DECODE(p_duplicateIdTab(i),
						 p_customerIdTab(i),
						 -3.1428571,
						 p_duplicateIdTab(i)
						 ));
       --
       setARMessageRowCount( SQL%ROWCOUNT );
     --
     END IF;
   --
   END IF;
   --
   arp_message.set_line('RLM_CUST_MERGE.Cust_Item_Terms()-' || getTimeStamp);
   --
 EXCEPTION
   --
   WHEN others THEN
     --
     arp_message.set_error('RLM_CUST_MERGE.Cust_Item_Terms');
     RAISE;
     --
END Cust_Item_Terms;
/*============================================================================

  FUNCTION getTimeStamp

 ============================================================================*/
FUNCTION getTimeStamp RETURN VARCHAR2
 --
IS
 --
BEGIN
 --
   RETURN TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS');
   --
 EXCEPTION
   --
   WHEN OTHERS THEN
     --
     RAISE;
     --
END getTimeStamp;

/*============================================================================

  PROCEDURE setARMessageUpdateTable

 ============================================================================*/
PROCEDURE setARMessageUpdateTable(p_tableName IN VARCHAR2)
 --
IS
 --
BEGIN
 --
   arp_message.set_name('AR','AR_UPDATING_TABLE');
   arp_message.set_token('TABLE_NAME', p_tableName, FALSE);
   --
 EXCEPTION
   --
   WHEN OTHERS THEN
     --
     RAISE;
     --
END setARMessageUpdateTable;
/*============================================================================

  PROCEDURE setARMessageDeleteTable

 ============================================================================*/
PROCEDURE setARMessageDeleteTable(p_tableName IN VARCHAR2)
 --
IS
 --
BEGIN
 --
   arp_message.set_name('AR','AR_DELETING_TABLE');
   arp_message.set_token('TABLE_NAME', p_tableName, FALSE);
   --
 EXCEPTION
   --
   WHEN OTHERS THEN
     --
     RAISE;
     --
END setARMessageDeleteTable;
/*============================================================================

  PROCEDURE setARMessageLockTable

 ============================================================================*/
PROCEDURE setARMessageLockTable(p_tableName IN VARCHAR2)
 --
IS
 --
BEGIN
 --
   arp_message.set_name('AR','AR_LOCKING_TABLE');
   arp_message.set_token('TABLE_NAME', p_tableName, FALSE);
   --
 EXCEPTION
   --
   WHEN OTHERS THEN
     --
     RAISE;
     --
END setARMessageLockTable;

/*============================================================================

  PROCEDURE setARMessageRowCount

 ============================================================================*/
PROCEDURE setARMessageRowCount(p_rowCount IN NUMBER)
 --
IS
 --
BEGIN
 --
       arp_message.set_name('AR','AR_ROWS_UPDATED');
       arp_message.set_token('NUM_ROWS', to_char(p_rowCount));
   --
 EXCEPTION
   --
   WHEN OTHERS THEN
     --
     RAISE;
     --
END setARMessageRowCount;

/*============================================================================

  FUNCTION setARMessageRowCount

 ============================================================================*/
FUNCTION getMessage
        (
          p_messageName IN VARCHAR2,
          p_token1      IN VARCHAR2,
          p_value1      IN VARCHAR2,
          p_token2      IN VARCHAR2,
          p_value2      IN VARCHAR2,
          p_token3      IN VARCHAR2,
          p_value3      IN VARCHAR2
        )
RETURN VARCHAR2
 --
IS
 --
BEGIN
 --
   FND_MESSAGE.SET_NAME('RLM',p_messageName);
   --
   --
   --
   IF p_token1 IS NOT NULL
   AND p_value1 IS NOT NULL
   THEN
        FND_MESSAGE.SET_TOKEN(p_token1, p_value1);
   END IF;
   --
   --
   IF p_token2 IS NOT NULL
   AND p_value2 IS NOT NULL
   THEN
        FND_MESSAGE.SET_TOKEN(p_token2, p_value2);
   END IF;
   --
   --
   IF p_token3 IS NOT NULL
   AND p_value3 IS NOT NULL
   THEN
        FND_MESSAGE.SET_TOKEN(p_token3, p_value3);
   END IF;
   --
   --
   RETURN( FND_MESSAGE.GET );
   --
 EXCEPTION
   --
   WHEN OTHERS THEN
     --
     RAISE;
     --
END getMessage;

/*---------------------------------------------------------------------------
  NOTE Values for installation status are
                  I - Product is installed
                  S - Product is partially installed
                  N - Product is not installed
                  L - Product is a local (custom) application
----------------------------------------------------------------------------*/
/*===========================================================================

  FUNCTION IS_RLM_INSTALLED

===========================================================================*/
FUNCTION IS_RLM_INSTALLED
RETURN BOOLEAN
 --
IS
 --
    x_install      BOOLEAN;
    rlm_status     VARCHAR2(1);
    x_org          VARCHAR2(1);
BEGIN
   --
   x_install := fnd_installation.get(662,662,rlm_status,x_org);
   --
   IF rlm_status = 'I'
   THEN
       --
       RETURN TRUE;
       --
   ELSE
       --
       arp_message.set_line(getMessage('RLM_INSTALL_STATUS'));
       RETURN FALSE;
       --
  END IF;
   --
END IS_RLM_INSTALLED;

/*2447493*/

PROCEDURE RLM_CUST_ITEM_CUM_KEYS_LOG (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE CUM_KEY_ID_LIST_TYPE IS TABLE OF
         RLM_CUST_ITEM_CUM_KEYS.CUM_KEY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST CUM_KEY_ID_LIST_TYPE;

  TYPE INTRMD_SHIP_TO_ID_LIST_TYPE IS TABLE OF
         RLM_CUST_ITEM_CUM_KEYS.INTRMD_SHIP_TO_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST INTRMD_SHIP_TO_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST INTRMD_SHIP_TO_ID_LIST_TYPE;

  TYPE SHIP_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
         RLM_CUST_ITEM_CUM_KEYS.SHIP_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;

  TYPE BILL_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
         RLM_CUST_ITEM_CUM_KEYS.BILL_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;

  TYPE CUM_NOTE_TEXT_LIST_TYPE IS TABLE OF
         RLM_CUST_ITEM_CUM_KEYS.CUM_NOTE_TEXT%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL1_ORIG_LIST CUM_NOTE_TEXT_LIST_TYPE;
  VCHAR_COL1_NEW_LIST CUM_NOTE_TEXT_LIST_TYPE;

  TYPE INACTIVE_FLAG_LIST_TYPE IS TABLE OF
         RLM_CUST_ITEM_CUM_KEYS.INACTIVE_FLAG%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL2_ORIG_LIST INACTIVE_FLAG_LIST_TYPE;
  VCHAR_COL2_NEW_LIST INACTIVE_FLAG_LIST_TYPE;

  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,CUM_KEY_ID
              ,INTRMD_SHIP_TO_ID
              ,SHIP_TO_ADDRESS_ID
              ,BILL_TO_ADDRESS_ID
              ,CUM_NOTE_TEXT
              ,INACTIVE_FLAG
         FROM RLM_CUST_ITEM_CUM_KEYS yt, ra_customer_merges m
         WHERE (
            yt.INTRMD_SHIP_TO_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.SHIP_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.BILL_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;

BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','RLM_CUST_ITEM_CUM_KEYS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
          , VCHAR_COL1_ORIG_LIST
          , VCHAR_COL2_ORIG_LIST
            limit 1000
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL1_ORIG_LIST(I));

         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));

         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL3_ORIG_LIST(I));

         VCHAR_COL1_NEW_LIST(I) := VCHAR_COL1_ORIG_LIST(I);
         VCHAR_COL2_NEW_LIST(I) := VCHAR_COL2_ORIG_LIST(I);
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
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'RLM_CUST_ITEM_CUM_KEYS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
         VCHAR_COL1_ORIG_LIST(I),
         VCHAR_COL1_NEW_LIST(I),
         VCHAR_COL2_ORIG_LIST(I),
         VCHAR_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'RLM_CUST_ITEM_CUM_KEYS_LOG');
    RAISE;
END RLM_CUST_ITEM_CUM_KEYS_LOG;

PROCEDURE RLM_INTERFACE_HEADERS_LOG (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  cust_name	varchar2(100);

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE HEADER_ID_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_HEADERS.HEADER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST HEADER_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_HEADERS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE ECE_PRIMARY_ADD_ID_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_HEADERS.ECE_PRIMARY_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ECE_PRIMARY_ADD_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST ECE_PRIMARY_ADD_ID_LIST_TYPE;

  TYPE CUST_NAME_EXT_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_HEADERS.CUST_NAME_EXT%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL1_ORIG_LIST CUST_NAME_EXT_LIST_TYPE;
  VCHAR_COL1_NEW_LIST CUST_NAME_EXT_LIST_TYPE;

  TYPE HEADER_NOTE_TEXT_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_HEADERS.HEADER_NOTE_TEXT%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL2_ORIG_LIST HEADER_NOTE_TEXT_LIST_TYPE;
  VCHAR_COL2_NEW_LIST HEADER_NOTE_TEXT_LIST_TYPE;

  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,HEADER_ID
              ,yt.CUSTOMER_ID
              ,ECE_PRIMARY_ADDRESS_ID
              ,CUST_NAME_EXT
              ,HEADER_NOTE_TEXT
         FROM RLM_INTERFACE_HEADERS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
            OR yt.ECE_PRIMARY_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','RLM_INTERFACE_HEADERS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , VCHAR_COL1_ORIG_LIST
          , VCHAR_COL2_ORIG_LIST
	    limit 1000
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

          select distinct customer_name into cust_name
	  from  ra_customer_merges
	  where customer_id = NUM_COL1_NEW_LIST(I)
          and request_id = req_id;

        VCHAR_COL1_NEW_LIST(I) := cust_name;
         VCHAR_COL2_NEW_LIST(I) := VCHAR_COL2_ORIG_LIST(I);
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
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'RLM_INTERFACE_HEADERS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         VCHAR_COL1_ORIG_LIST(I),
         VCHAR_COL1_NEW_LIST(I),
         VCHAR_COL2_ORIG_LIST(I),
         VCHAR_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'RLM_INTERFACE_HEADERS_LOG');
    RAISE;
END RLM_INTERFACE_HEADERS_LOG;


PROCEDURE RLM_INTERFACE_LINES_LOG (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE LINE_ID_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_LINES.LINE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST LINE_ID_LIST_TYPE;

  TYPE INTRMD_SHIP_TO_ID_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_LINES.INTRMD_SHIP_TO_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST INTRMD_SHIP_TO_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST INTRMD_SHIP_TO_ID_LIST_TYPE;

  TYPE SHIP_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_LINES.SHIP_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;

  TYPE BILL_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_LINES.BILL_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;

  TYPE SHIP_TO_ORG_ID_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_LINES.SHIP_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST SHIP_TO_ORG_ID_LIST_TYPE;
  NUM_COL4_NEW_LIST SHIP_TO_ORG_ID_LIST_TYPE;

  TYPE INVOICE_TO_ORG_ID_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_LINES.INVOICE_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL5_ORIG_LIST INVOICE_TO_ORG_ID_LIST_TYPE;
  NUM_COL5_NEW_LIST INVOICE_TO_ORG_ID_LIST_TYPE;

  TYPE INT_SHIP_TO_ORG_ID_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_LINES.INTMED_SHIP_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL6_ORIG_LIST INT_SHIP_TO_ORG_ID_LIST_TYPE;
  NUM_COL6_NEW_LIST INT_SHIP_TO_ORG_ID_LIST_TYPE;

  TYPE ITEM_NOTE_TEXT_LIST_TYPE IS TABLE OF
         RLM_INTERFACE_LINES.ITEM_NOTE_TEXT%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL1_ORIG_LIST ITEM_NOTE_TEXT_LIST_TYPE;
  VCHAR_COL1_NEW_LIST ITEM_NOTE_TEXT_LIST_TYPE;

  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,LINE_ID
              ,INTRMD_SHIP_TO_ID
              ,SHIP_TO_ADDRESS_ID
              ,BILL_TO_ADDRESS_ID
              ,SHIP_TO_ORG_ID
              ,INVOICE_TO_ORG_ID
              ,INTMED_SHIP_TO_ORG_ID
              ,ITEM_NOTE_TEXT
         FROM RLM_INTERFACE_LINES yt, ra_customer_merges m
         WHERE (
            yt.INTRMD_SHIP_TO_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.SHIP_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.BILL_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.SHIP_TO_ORG_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.INVOICE_TO_ORG_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.INTMED_SHIP_TO_ORG_ID = m.DUPLICATE_ADDRESS_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','RLM_INTERFACE_LINES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);

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
          , VCHAR_COL1_ORIG_LIST
	    limit 1000
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL1_ORIG_LIST(I));

         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));

         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL3_ORIG_LIST(I));

         NUM_COL4_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL4_ORIG_LIST(I));

         NUM_COL5_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL5_ORIG_LIST(I));

         NUM_COL6_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL6_ORIG_LIST(I));

         VCHAR_COL1_NEW_LIST(I) := VCHAR_COL1_ORIG_LIST(I);
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
         'RLM_INTERFACE_LINES',
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

    END IF;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'RLM_INTERFACE_LINES_LOG');
    RAISE;
END RLM_INTERFACE_LINES_LOG;

PROCEDURE RLM_SCHEDULE_HEADERS_LOG (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  cust_name	varchar2(100);

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE HEADER_ID_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_HEADERS.HEADER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST HEADER_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_HEADERS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE ECE_PRIMARY_ADD_ID_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_HEADERS.ECE_PRIMARY_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ECE_PRIMARY_ADD_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST ECE_PRIMARY_ADD_ID_LIST_TYPE;

  TYPE CUST_NAME_EXT_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_HEADERS.CUST_NAME_EXT%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL1_ORIG_LIST CUST_NAME_EXT_LIST_TYPE;
  VCHAR_COL1_NEW_LIST CUST_NAME_EXT_LIST_TYPE;

  TYPE HEADER_NOTE_TEXT_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_HEADERS.HEADER_NOTE_TEXT%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL2_ORIG_LIST HEADER_NOTE_TEXT_LIST_TYPE;
  VCHAR_COL2_NEW_LIST HEADER_NOTE_TEXT_LIST_TYPE;

  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,HEADER_ID
              ,yt.CUSTOMER_ID
              ,ECE_PRIMARY_ADDRESS_ID
              ,CUST_NAME_EXT
              ,HEADER_NOTE_TEXT
         FROM RLM_SCHEDULE_HEADERS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
            OR yt.ECE_PRIMARY_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','RLM_SCHEDULE_HEADERS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , VCHAR_COL1_ORIG_LIST
          , VCHAR_COL2_ORIG_LIST
            limit 1000
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

         select distinct customer_name into cust_name
	 from ra_customer_merges
	 where customer_id = NUM_COL1_NEW_LIST(I)
         and request_id = req_id;

         VCHAR_COL1_NEW_LIST(I) := cust_name;
         VCHAR_COL2_NEW_LIST(I) := VCHAR_COL2_ORIG_LIST(I);
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
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'RLM_SCHEDULE_HEADERS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         VCHAR_COL1_ORIG_LIST(I),
         VCHAR_COL1_NEW_LIST(I),
         VCHAR_COL2_ORIG_LIST(I),
         VCHAR_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'RLM_SCHEDULE_HEADERS_LOG');
    RAISE;
END RLM_SCHEDULE_HEADERS_LOG;


PROCEDURE RLM_SCHEDULE_LINES_LOG (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE LINE_ID_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_LINES.LINE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST LINE_ID_LIST_TYPE;

  TYPE INTRMD_SHIP_TO_ID_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_LINES.INTRMD_SHIP_TO_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST INTRMD_SHIP_TO_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST INTRMD_SHIP_TO_ID_LIST_TYPE;

  TYPE SHIP_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_LINES.SHIP_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SHIP_TO_ADDRESS_ID_LIST_TYPE;

  TYPE BILL_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_LINES.BILL_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST BILL_TO_ADDRESS_ID_LIST_TYPE;

  TYPE SHIP_TO_ORG_ID_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_LINES.SHIP_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST SHIP_TO_ORG_ID_LIST_TYPE;
  NUM_COL4_NEW_LIST SHIP_TO_ORG_ID_LIST_TYPE;

  TYPE INVOICE_TO_ORG_ID_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_LINES.INVOICE_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL5_ORIG_LIST INVOICE_TO_ORG_ID_LIST_TYPE;
  NUM_COL5_NEW_LIST INVOICE_TO_ORG_ID_LIST_TYPE;

  TYPE INT_SHIP_TO_ORG_ID_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_LINES.INTMED_SHIP_TO_ORG_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL6_ORIG_LIST INT_SHIP_TO_ORG_ID_LIST_TYPE;
  NUM_COL6_NEW_LIST INT_SHIP_TO_ORG_ID_LIST_TYPE;

  TYPE ITEM_NOTE_TEXT_LIST_TYPE IS TABLE OF
         RLM_SCHEDULE_LINES.ITEM_NOTE_TEXT%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL1_ORIG_LIST ITEM_NOTE_TEXT_LIST_TYPE;
  VCHAR_COL1_NEW_LIST ITEM_NOTE_TEXT_LIST_TYPE;

  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,LINE_ID
              ,INTRMD_SHIP_TO_ID
              ,SHIP_TO_ADDRESS_ID
              ,BILL_TO_ADDRESS_ID
              ,SHIP_TO_ORG_ID
              ,INVOICE_TO_ORG_ID
              ,INTMED_SHIP_TO_ORG_ID
              ,ITEM_NOTE_TEXT
         FROM RLM_SCHEDULE_LINES yt, ra_customer_merges m
         WHERE (
            yt.INTRMD_SHIP_TO_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.SHIP_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.BILL_TO_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.SHIP_TO_ORG_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.INVOICE_TO_ORG_ID = m.DUPLICATE_ADDRESS_ID
            OR yt.INTMED_SHIP_TO_ORG_ID = m.DUPLICATE_ADDRESS_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','RLM_SCHEDULE_LINES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);

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
          , VCHAR_COL1_ORIG_LIST
	    limit 1000
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL1_ORIG_LIST(I));

         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));

         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL3_ORIG_LIST(I));

         NUM_COL4_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL4_ORIG_LIST(I));

         NUM_COL5_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL5_ORIG_LIST(I));

         NUM_COL6_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL6_ORIG_LIST(I));

         VCHAR_COL1_NEW_LIST(I) := VCHAR_COL1_ORIG_LIST(I);
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
         'RLM_SCHEDULE_LINES',
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

    END IF;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;
  END IF;
EXCEPTION

  WHEN OTHERS THEN
    arp_message.set_line( 'RLM_SCHEDULE_LINES_LOG');
    RAISE;
END RLM_SCHEDULE_LINES_LOG;

/*2447493*/

END RLM_CUST_MERGE;

/
