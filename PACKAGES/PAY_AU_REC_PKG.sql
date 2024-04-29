--------------------------------------------------------
--  DDL for Package PAY_AU_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_REC_PKG" AUTHID CURRENT_USER as
/* $Header: pyaurec.pkh 115.7 2002/12/04 08:47:50 ragovind ship $ */

  procedure run_balances
    (p_assignment_id         in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_effective_date        in date,
     p_balance_name          in pay_balance_types.balance_name%type,
     p_run_balance           out NOCOPY number);

  procedure balance_totals
    (p_assignment_id               in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id        in pay_assignment_actions.assignment_action_id%type,
     p_effective_date              in date,
     p_gross_this_pay             out NOCOPY number,
     p_other_deductions_this_pay  out NOCOPY number,
     p_tax_deductions_this_pay    out NOCOPY number,
     p_direct_payments_this_pay   out NOCOPY number,
     p_pre_tax_deductions_this_pay   out NOCOPY  number);
end;

 

/
