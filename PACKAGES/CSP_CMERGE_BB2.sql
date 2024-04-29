--------------------------------------------------------
--  DDL for Package CSP_CMERGE_BB2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_CMERGE_BB2" AUTHID CURRENT_USER as
/* $Header: cscm102s.pls 115.2 2003/04/11 10:55:37 axsubram ship $ */

/* This is the main block for merging the cs_customer_products table.
   This block calls a merge procedure that in turns call the procedures that will
   perform the update on cs_customer_products. The call sequence is
   listed below.

               ---CSP_CMERGE_BB2.MERGE ( table cs_customer_products )
                             |
                              CS_MERGE_BILL_TO_SITE_ID
			      CS_MERGE_INSTALL_SITE_ID
                              CS_MERGE_SHIP_TO_SITE_ID
			      CS_MERGE_ORDER_BILL_TO_SITE_ID
      			      CS_MERGE_ORDER_SHIP_TO_SITE_ID
                              CS_MERGE_CUSTOMER_ID
                              CS_CHECK_MERGE_DATA

                      								    */

  PROCEDURE MERGE ( req_id       IN NUMBER,
                    set_number   IN NUMBER,
                    process_mode IN VARCHAR2 );

  END CSP_CMERGE_BB2;

 

/
