--------------------------------------------------------
--  DDL for Package PAY_AU_PAYTAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PAYTAX_PKG" AUTHID CURRENT_USER AS
/* $Header: pyaupyt.pkh 120.4.12010000.1 2008/07/27 22:06:29 appldev ship $ */

/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  AU HRMS Payroll Tax package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  29 JAN 2001 SHOSKATT  N/A        Created
**  20 Jun 2002 Ragovind  2272424    Modified the Get_Tax Function Declaration
**  03 Dec 2002 Ragovind  2689226    Added NOCOPY for the function get_tax
**  09 AUG 2004 abhkumar  2610141    Added tax_unit_id in function GET_BALANCE for Legal Employer enhancement
**  25 Aug 2005 hnainani  3541814    Added / Modified functions for Payroll Tax Grouping
**  03 Nov 2005 hnainani  4709766    Added Period to the Global Parameters
**  26 Feb 2008 vdabgar   6839263    Added p_output_type to the Parameters type.
**  18 Mar 2008 avenkatk  6839263    Backed out changes to Parameters Record Type
-------------------------------------------------------------------------------*/


procedure get_balances
  (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
   p_registered_employer        in NUMBER,
   p_tax_state                  in varchar2,
   p_salaries_wages             out NOCOPY number,
   p_commission                 out NOCOPY number,
   p_bonus_allowances           out NOCOPY number,
   p_director_fees              out NOCOPY number,
   p_termination_payments       out NOCOPY number,
   p_eligible_term_payments	out NOCOPY number,
   p_Fringe_Benefits            out NOCOPY number,
   p_Superannuation        	out NOCOPY number,
   p_Contractor_Payments 	out NOCOPY number,
   p_Other_Taxable_Income  	out NOCOPY number,
   p_taxable_income 	        out NOCOPY number);


g_balance_value_tab  pay_balance_pkg.t_balance_value_tab;
g_ytd_balance_value_tab  pay_balance_pkg.t_balance_value_tab;
g_context_table         pay_balance_pkg.t_context_tab;
g_result_table          pay_balance_pkg.t_detailed_bal_out_tab;

PROCEDURE populate_defined_balance_ids
          ( p_registered_employer NUMBER);

TYPE parameters IS RECORD ( business_group_id       number,
                            legal_employer          number,
                            period                  date,  /*4709766 */
                            start_date              date,
                            end_date                date,
                            tax_state               varchar2(3),
                            report_type             varchar2(1),
                            report_name             varchar2(30),
                            act_override_threshold  number,
                            vic_override_threshold  number,
                            nsw_override_threshold  number,
                            qld_override_threshold  number,
                            wa_override_threshold   number,
                            nt_override_threshold   number,
                            sa_override_threshold   number,
                            tas_override_threshold  number);

g_parameters parameters;


 FUNCTION GET_TAX(p_no_of_states number,
                   p_dge_state varchar2,
                   p_dge_group_name varchar2,
                   p_state_code varchar2,
                   p_taxable_income NUMBER,
                   p_le_taxable_income NUMBER,
                   p_message out NOCOPY varchar2,
                   p_ot_message out NOCOPY varchar2,
                   p_start_date date,
                   p_End_date date,
                   p_override_threshold NUMBER ) RETURN NUMBER;


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


end pay_au_paytax_pkg;

/
