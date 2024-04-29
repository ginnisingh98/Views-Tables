--------------------------------------------------------
--  DDL for Package CSP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_CMERGE" AUTHID CURRENT_USER as
/* $Header: cscm100s.pls 115.0 99/07/16 08:47:19 porting ship $ */

/* This is the main process that calls all the building blocks for the
   customer merge for the service data base.
   There are three blocks, each block is reponsible for doing a complete
   merge of a  table to be merged. Within each building block there is
   a procedure 'merge' that calls locall routines that merge the different
   fields of the table. Below is a diagram of the calling sequence.

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
               |               |
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
               |             |
               |             CS_MERGE_CUSTOMER_ID
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
                    process_mode IN VARCHAR2 );


  END CSP_CMERGE;

 

/
