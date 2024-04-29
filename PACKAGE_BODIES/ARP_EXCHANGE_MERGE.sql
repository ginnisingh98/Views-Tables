--------------------------------------------------------
--  DDL for Package Body ARP_EXCHANGE_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_EXCHANGE_MERGE" as
/* $Header: AREXCHMB.pls 120.1 2005/06/16 21:06:48 jhuang ship $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count               NUMBER := 0;

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

procedure cust_merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is


   -- Get orig_system_reference for the two merging customers.
   CURSOR c1 IS
   SELECT
	 ca2.orig_system_reference dup_osr
   FROM
	RA_CUSTOMER_MERGES racm,
	HZ_CUST_ACCOUNTS ca2
   WHERE
 	racm.request_id = req_id
 	and racm.set_number = set_num
 	and racm.process_flag = 'N'
	and racm.duplicate_id = ca2.cust_account_id
	and ca2.orig_system_reference like 'EXCHANGE_CUST%';

   l_merge_not_allowed BOOLEAN := FALSE;
   l_cust_osr varchar2(240);
   l_dup_osr varchar2(240);
   l_error varchar2(2000);
   MERGE_NOT_ALLOWED EXCEPTION;

BEGIN
 arp_message.set_line( 'ARP_EXCHANGE_MERGE.cust_merge()+' );

 IF (process_mode = 'LOCK') then

  /*
   * No locking is necessary, as no updates will be done locally.
   * arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
   * arp_message.set_token( 'TABLE_NAME', 'tablename', FALSE );
   * OPEN C1;
   * CLOSE C1;
   *
   */

	null;

 ELSE

	/* Logic:
	   1. Get info from ra_customer_merges.
	   2. Get orig_system_reference from hz_cust_accounts
	   3. If OSR is like 'EXCHANGE_CUST', veto. This kind of use of OSR
	      by oex billing will soon change when the oex billing
	      design changes.
	*/
	OPEN c1;

	FETCH c1 into l_dup_osr;

	IF (c1%FOUND) THEN
		-- if we are here, that means atleast one merge pair contained an exchange customer.
		-- Fail the whole set
		l_merge_not_allowed := TRUE;
	END IF;

	IF (c1%ISOPEN) THEN
		CLOSE c1;
	END IF;

	IF l_merge_not_allowed THEN
		raise MERGE_NOT_ALLOWED;
	END IF;
 END IF;

  arp_message.set_line( 'ARP_EXCHANGE_MERGE.CUST_MERGE()-' );


EXCEPTION
  WHEN MERGE_NOT_ALLOWED THEN
    arp_message.set_name('AR','HZ_EXCHANGE_MERGE_DISALLOWED');
    arp_message.set_error( 'ARP_EXCHANGE_MERGE.CUST_MERGE');
    raise;
  when others then
    raise;

END;


/*---------------------------- PUBLIC ROUTINES ------------------------------*/

PROCEDURE CMERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
BEGIN

  arp_message.set_line( 'ARP_EXCHANGE_MERGE.CMERGE()+' );

  cust_merge( req_id, set_num, process_mode );

  arp_message.set_line( 'ARP_EXCHANGE_MERGE.CMERGE()-' );

EXCEPTION
  when others then
    raise;

END CMERGE;

end ARP_EXCHANGE_MERGE;

/
