--------------------------------------------------------
--  DDL for Package CSP_CMERGE_BB6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_CMERGE_BB6" AUTHID CURRENT_USER as
/* $Header: cscm106s.pls 115.0 99/07/16 08:48:01 porting ship $ */

/* This is the main block for merging the cs_mass_service_txns_temp table.
   This block calls a merge procedure that in turns call the procedures that will
   perform the update on cs_mass_service_txns_temp. The call sequence is
   listed below.

               ---CSP_CMERGE_BB6.MERGE ( table cs_mass_service_txns_temp )
                             |
                              CS_MERGE_CUSTOMER_ID

                      								    */

  PROCEDURE MERGE ( req_id       IN NUMBER,
                    set_number   IN NUMBER,
                    process_mode IN VARCHAR2 );

  END CSP_CMERGE_BB6;

 

/
