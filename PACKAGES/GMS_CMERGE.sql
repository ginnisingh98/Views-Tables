--------------------------------------------------------
--  DDL for Package GMS_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_CMERGE" AUTHID CURRENT_USER AS
-- $Header: gmscmrgs.pls 120.1 2005/07/26 14:21:44 appldev ship $

-- Package to perform customer merge for Grants accounting


   var_award_id            	gms_awards_all.award_id%TYPE;
   var_customer_id         	gms_awards_all.funding_source_id%TYPE;
   var_bill_to_customer_id 	gms_awards_all.bill_to_customer_id%TYPE;
   old_customer_id         	ra_customer_merges.duplicate_id%TYPE;
   new_customer_id         	ra_customer_merges.customer_id%TYPE;
   old_loc_customer_id        	ra_customer_merges.duplicate_id%TYPE;
   new_loc_customer_id        	ra_customer_merges.customer_id%TYPE;

   PROCEDURE MERGE ( req_id IN NUMBER, set_no IN NUMBER, process_mode IN VARCHAR2 );
--
END GMS_CMERGE;

 

/
