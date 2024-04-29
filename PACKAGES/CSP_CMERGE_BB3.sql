--------------------------------------------------------
--  DDL for Package CSP_CMERGE_BB3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_CMERGE_BB3" AUTHID CURRENT_USER as
/* $Header: cscm103s.pls 115.0 99/07/16 08:47:41 porting ship $ */

/* This is the main block for merging the cs_customer_products table.
   This block calls a merge procedure that in turns call the procedures that will
   perform the update on cs_customer_products. The call sequence is
   listed below.

               ---CSP_CMERGE_BB3.MERGE ( table cs_systems )
                             |
                              CS_MERGE_BILL_TO_SITE_ID
			      CS_MERGE_INSTALL_SITE_ID
                              CS_MERGE_SHIP_TO_SITE_ID
                              CS_MERGE_CUSTOMER_ID
                              CS_CHECK_MERGE_DATA

                      								    */

  PROCEDURE MERGE ( req_id       IN NUMBER,
                    set_number   IN NUMBER,
                    process_mode IN VARCHAR2 );

  END CSP_CMERGE_BB3;

 

/
