--------------------------------------------------------
--  DDL for Package PAY_PAYROLL_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYROLL_EXTRACT" AUTHID CURRENT_USER as
/* $Header: payextract.pkh 120.1 2006/10/06 00:59:53 jgoswami noship $ */

--   FUNCTION get_xmldoc_clob
--     ( p_payroll_action_id IN varchar2 ) RETURN CLOB;

   FUNCTION get_xmldoc_clob
     ( p_payroll_action_id IN varchar2,
       p_process_type IN Varchar2,
       p_assignment_set_id IN Varchar2,
       p_element_set_id IN Varchar2) RETURN CLOB;

  debug_mesg varchar2(2000);

END PAY_PAYROLL_EXTRACT;


 

/
