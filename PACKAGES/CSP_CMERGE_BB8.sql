--------------------------------------------------------
--  DDL for Package CSP_CMERGE_BB8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_CMERGE_BB8" AUTHID CURRENT_USER as
/* $Header: cscm108s.pls 115.0 99/07/16 08:48:13 porting ship $ */

/* This is the main block for merging the cs_incidents table.
   This block calls a merge procedure that in turns call the procedures that will
   perform the update on cs_incidents. The call sequence is
   listed below.

               ---CSP_CMERGE_BB8.MERGE ( table cs_incidents )
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

  END CSP_CMERGE_BB8;

 

/
