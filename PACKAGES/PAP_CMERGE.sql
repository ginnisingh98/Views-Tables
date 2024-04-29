--------------------------------------------------------
--  DDL for Package PAP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAP_CMERGE" AUTHID CURRENT_USER AS
-- $Header: PAPCMR3S.pls 115.4 2003/08/20 06:14:36 bchandra ship $
--
-- Pakage to perform customer merge for Project accounting
--
   var_project_id          pa_project_customers.project_id%TYPE;
   var_customer_id         pa_project_customers.customer_id%TYPE;
   old_customer_id         ra_customer_merges.duplicate_id%TYPE;
   new_customer_id         ra_customer_merges.customer_id%TYPE;
   var_customer_bill_split pa_project_customers.customer_bill_split%TYPE;
   new_customer_bill_split pa_project_customers.customer_bill_split%TYPE;
   g_audit_profile         VARCHAR2(1);

   PROCEDURE MERGE ( req_id IN NUMBER, set_no IN NUMBER, process_mode IN VARCHAR2 );
--
END PAP_CMERGE;

 

/
