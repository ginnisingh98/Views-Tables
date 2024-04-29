--------------------------------------------------------
--  DDL for Package CSP_CMERGE_BB7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_CMERGE_BB7" AUTHID CURRENT_USER as
/* $Header: cscm107s.pls 115.0 99/07/16 08:48:07 porting ship $ */

/* This is the main block for merging the cs_repairs table.
   This block calls a merge procedure that in turns call the procedures that will
   perform the update on cs_repairs. The call sequence is
   listed below.

               ---CSP_CMERGE_BB7.MERGE ( table cs_repairs )
                             |
                              CS_MERGE_CUSTOMER_ID

                      								    */

  PROCEDURE MERGE ( req_id       IN NUMBER,
                    set_number   IN NUMBER,
                    process_mode IN VARCHAR2 );

  END CSP_CMERGE_BB7;

 

/
