--------------------------------------------------------
--  DDL for Package Body PYZAMCRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYZAMCRP" as
/* $Header: pyzamcrp.pkb 120.2 2005/06/28 00:07:13 kapalani noship $ */

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
   ) is

   -- Cursor used to update cheque numbers.
   cursor cheque_csr is
      select
         paf.payroll_id,
         ppa.effective_date,
         cdv.branch_code
      from
         pay_payroll_actions ppa,
         pay_assignment_actions paa,
         pay_za_branch_cdv_details cdv,
         pay_pre_payments ppp,
         pay_personal_payment_methods_f ppm,
         pay_external_accounts pea,
         per_assignments_f paf,
         pay_payrolls_f ppf
      where ppa.payroll_action_id = p_payroll_action_id
      and ppf.payroll_name = p_payroll_name
      and cdv.branch_code = p_branch_code
      and paa.serial_number is null
      and ppa.payroll_action_id = paa.payroll_action_id
      and paa.action_status not in ('V', 'E')
      and paa.pre_payment_id = ppp.pre_payment_id
      and paa.assignment_id = paf.assignment_id
      and ppa.effective_date between paf.effective_start_date and paf.effective_end_date
      and ppa.effective_date between ppm.effective_start_date and ppm.effective_end_date
      and ppa.effective_date between ppf.effective_start_date and ppf.effective_end_date
      and ppm.personal_payment_method_id = ppp.personal_payment_method_id
      and ppm.external_account_id = pea.external_account_id
      and cdv.branch_code = pea.segment1
      and paf.payroll_id = ppf.payroll_id
      order by ppf.payroll_name, ppa.effective_date, cdv.bank_name, cdv.branch_name,
               cdv.branch_code
      for update of paa.serial_number;

   l_flag boolean := FALSE;
   v_cheq cheque_csr%ROWTYPE;

   begin

      hr_utility.trace('Entering pyzamcrp.manual_ct_cheque');

      -- Create the cheque.
      for v_cheq in cheque_csr loop

         -- Indicate that we did create a cheque.
         l_flag := TRUE;

         -- Update the assignment action to the current cheque number.
         update pay_assignment_actions
         set serial_number = to_char(p_start_cheque)
         where current of cheque_csr;

      end loop;

      -- Check whether cheque was produced.
      if not l_flag then
         -- Raise an error.
         p_errmsg := 'Cheque already issued or no such clearing number on Credit Transfer.';
         p_errcode := 2; -- Error
         return;
      end if;

      -- Commit the cheque.
      commit;

      hr_utility.trace('Exiting pyzamcrp.manual_ct_cheque');
exception
   when others then
   p_errmsg := null;
   p_errcode := null;
   end manual_ct_cheque;

end pyzamcrp;

/
