--------------------------------------------------------
--  DDL for Package PYZAMCRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYZAMCRP" AUTHID CURRENT_USER as
/* $Header: pyzamcrp.pkh 120.2 2005/06/28 00:07:32 kapalani noship $ */

   -----------------------------------------------------------------------------
   -- NAME
   --  manual_ct_cheque
   -- PURPOSE
   --  Issues Manual Credit Transfer Cheques.
   -- ARGUMENTS
   --  p_errmsg            - Returned error message.
   --  p_errcode           - Returned error code.
   --  p_payroll_action_id - The Payroll action to process.
   --  p_payroll_name      - The Payroll name.
   --  p_branch_code       - The Clearing number of the bank to process.
   --  p_start_cheque      - The cheque number of the cheque to produce.
   -- USES
   -- NOTES
   --
   -----------------------------------------------------------------------------
   procedure manual_ct_cheque
   (
      p_errmsg out nocopy varchar2,
      p_errcode out nocopy number,
      p_payroll_action_id number,
      p_payroll_name varchar2,
      p_branch_code varchar2,
      p_start_cheque number
   );

end pyzamcrp;

 

/
