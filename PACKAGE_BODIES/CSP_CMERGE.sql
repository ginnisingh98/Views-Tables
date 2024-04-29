--------------------------------------------------------
--  DDL for Package Body CSP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_CMERGE" as
/* $Header: cscm100b.pls 115.1 99/09/13 16:55:11 porting ship $ */

/* Call all the blocks to update all the table for Service merge.
   Below is a diagram of the calling sequence.

    CSP_CMERGE.MERGE ( all tables for CS )
               |
               |---CSP_CMERGE_BB1.MERGE ( table cs_access_control_templates )
               |             |
               |              CS_MERGE_SYS_INSTALL_SITE_ID
	       |	      CS_MERGE_SYS_SHIP_USE_ID
	       |	      CS_MERGE_CP_INSTALL_SITE_ID
      	       |              CS_MERGE_CP_SHIP_SITE_ID
               |              CS_MERGE_CUSTOMER_ID
               |              CS_CHECK_MERGE_DATA
	       |
               |---CSP_CMERGE_BB2.MERGE ( table cs_customer_products )
               |              |
               |               CS_MERGE_BILL_TO_SITE_ID
	       |	       CS_MERGE_INSTALL_SITE_ID
               |               CS_MERGE_SHIP_TO_SITE_ID
	       |	       CS_MERGE_ORDER_BILL_TO_SITE_ID
      	       |	       CS_MERGE_ORDER_SHIP_TO_SITE_ID
               |               CS_MERGE_CUSTOMER_ID
               |
               |---CSP_CMERGE_BB3.MERGE ( table cs_systems )
               |              |
               |               CS_MERGE_BILL_TO_SITE_ID
	       |	       CS_MERGE_INSTALL_SITE_ID
               |               CS_MERGE_SHIP_TO_SITE_ID
               |               CS_MERGE_CUSTOMER_ID
               |               CS_CHECK_MERGE_DATA
	       |
               |---CSP_CMERGE_BB4.MERGE ( table cs_templates_interface )
               |              |
               |               CS_MERGE_SYS_INSTALL_SITE_ID
               |               CS_MERGE_SYS_SHIP_TO_SITE_ID
	          |	           CS_MERGE_CP_INSTALL_SITE_ID
               |               CS_MERGE_CP_SHIP_TO_SITE_ID

               |               CS_MERGE_CUSTOMER_ID
               |               CS_CHECK_MERGE_DATA
               |
               |---CSP_CMERGE_BB5.MERGE ( table cs_mass_notification_txns_temp )
               |              |
               |              CS_MERGE_CUSTOMER_ID
               |
               |---CSP_CMERGE_BB6.MERGE ( table cs_mass_service_txns_temp )
                              |
               |              CS_MERGE_CUSTOMER_ID
			|
	          |---CSP_CMERGE_BB7.MERGE (table cs_repairs)
			|			|
		     |			RMA_CUSTOMER_ID
               |
               |---CSP_CMERGE_BB8.MERGE (table cs_incidents)
			|              |
	          |			CUSTOMER_ID
		     |			SHIP_TO_SITE_USE_ID
		     | 			BILL_TO_SITE_USE_ID
		     |			INSTALL_TO_SITE_USE_ID



                      								    */

PROCEDURE MERGE ( req_id       IN NUMBER,
                  set_number   IN NUMBER,
                  process_mode IN VARCHAR2 ) IS

/* used to store a free form text to be written to the log file */

        message_text          VARCHAR2(255);

  BEGIN

  /* CS is not functional in base 11i and to avoid any problems in other
	products RETURN is added as first statement in merge procedure. We
	came across a bug#970262. This is because  in earlier versions merge
	updates record in CS_SYSTEM table now this table is a view on
	CS_SYSTEM_B and CS_SYSTEM_TL. This endup in failing customer merge
	in one of the AR's customer merge program. To avoid such kind of
	problems before CS release return is added.
   */

   RETURN;


/* call the package that will merge cs_access_control_templates */

        arp_message.set_line('CP_CMERGE.MERGE()+');

        message_text := '******** -- STARTING THE MERGE PROCESS FOR CUSTOMER SERVICE -- ********';
        arp_message.put_line(message_text);

       CSP_CMERGE_BB1.MERGE ( req_id,
                              set_number,
                              process_mode );

       CSP_CMERGE_BB2.MERGE ( req_id,
                              set_number,
                              process_mode );

       CSP_CMERGE_BB3.MERGE ( req_id,
                              set_number,
                              process_mode );

       CSP_CMERGE_BB4.MERGE ( req_id,
                              set_number,
                              process_mode );

       CSP_CMERGE_BB5.MERGE ( req_id,
                              set_number,
                              process_mode );

       CSP_CMERGE_BB6.MERGE ( req_id,
                              set_number,
                              process_mode );

       CSP_CMERGE_BB7.MERGE ( req_id,
                              set_number,
                              process_mode );

	  CSP_CMERGE_BB8.MERGE ( req_id,
                              set_number,
                              process_mode );

        message_text := '******** -- MERGE PROCESS FOR CUSTOMER SERVICE HAS COMPLETED -- ********';
        arp_message.put_line(message_text);

        arp_message.set_line('CP_CMERGE.MERGE()-');

  END MERGE;


END CSP_CMERGE;

/
