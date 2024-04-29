--------------------------------------------------------
--  DDL for Package PAY_AU_RECONCILIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_RECONCILIATION_PKG" AUTHID CURRENT_USER as
/* $Header: pyaurecs.pkh 120.0 2005/05/29 03:09:59 appldev noship $ */

procedure get_au_rec_balances
  (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
   p_registered_employer        in NUMBER, --2610141
   p_gross_earnings             out NOCOPY number,  /*Bug 3953706*/
   p_non_taxable_earnings       out NOCOPY number,
   p_pre_tax_deductions         out NOCOPY number, /*Bug 3953706*/
   p_taxable_earnings           out NOCOPY number,
   p_tax    			out NOCOPY number,
   p_deductions			out NOCOPY number,
   p_direct_payments            out NOCOPY number, /*Bug 3953706*/
   p_net_payment        	out NOCOPY number,
   p_employer_charges 		out NOCOPY number);

procedure get_ytd_au_rec_balances
  (p_assignment_action_id  	in pay_assignment_actions.assignment_action_id%type,
   p_registered_employer        in NUMBER, --2610141
   p_ytd_gross_earnings         out NOCOPY number,   /*Bug 3953706*/
   p_ytd_non_taxable_earnings   out NOCOPY number,
   p_ytd_pre_tax_deductions     out NOCOPY number,   /*Bug 3953706*/
   p_ytd_taxable_earnings       out NOCOPY number,
   p_ytd_tax    		out NOCOPY number,
   p_ytd_deductions		out NOCOPY number,
   p_ytd_direct_payments        out NOCOPY number,   /*Bug 3953706*/
   p_ytd_net_payment        	out NOCOPY number,
   p_ytd_employer_charges 	out NOCOPY number);

g_balance_value_tab  pay_balance_pkg.t_balance_value_tab;
g_ytd_balance_value_tab  pay_balance_pkg.t_balance_value_tab; /*Bug 4040688*/
g_context_table         pay_balance_pkg.t_context_tab;  -- Bug 2610141
g_result_table          pay_balance_pkg.t_detailed_bal_out_tab; -- Bug 2610141

PROCEDURE populate_defined_balance_ids
          (p_ytd_totals   IN varchar2,
  	   p_registered_employer NUMBER); --2610141

g_parameters pay_au_rec_det_archive.parameters;

procedure range_code
(p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type
,p_sql                      out NOCOPY varchar2
);

procedure initialization_code
(p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type);

procedure assignment_action_code
(p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type
,p_start_person             in per_all_people_f.person_id%type
,p_end_person               in per_all_people_f.person_id%type
,p_chunk                    in number
);

procedure archive_code
(p_assignment_action_id     in pay_assignment_actions.assignment_action_id%type
,p_effective_date           in pay_payroll_actions.effective_date%type
);

procedure spawn_archive_reports
(p_payroll_action_id in pay_payroll_actions.payroll_action_id%type);

procedure check_report_parameters
          (p_start_date      IN date,
           p_end_date        IN date,
           p_period_end_date IN date);

end pay_au_reconciliation_pkg;

 

/
