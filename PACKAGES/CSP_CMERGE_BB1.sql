--------------------------------------------------------
--  DDL for Package CSP_CMERGE_BB1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_CMERGE_BB1" AUTHID CURRENT_USER as
/* $Header: cscm101s.pls 115.0 99/07/16 08:47:25 porting ship $ */

/* This is the main block for merging the cs_access_control_templates table.
   This block calls a merge procedure that in turns call the procedures that will
   perform the update on cs_access_control_templates. The call sequence is
   listed below.

               ---CSP_CMERGE_BB1.MERGE ( table cs_access_control_templates )
                             |
                              CS_MERGE_SYS_INSTALL_SITE_ID
			      CS_MERGE_SYS_SHIP_USE_ID
			      CS_MERGE_CP_INSTALL_SITE_ID
      			      CS_MERGE_CP_SHIP_SITE_ID
                              CS_MERGE_CUSTOMER_ID
                              CS_CHECK_MERGE_DATA

                      								    */

  PROCEDURE MERGE ( req_id       IN NUMBER,
                    set_number   IN NUMBER,
                    process_mode IN VARCHAR2 );

  END CSP_CMERGE_BB1;

 

/
