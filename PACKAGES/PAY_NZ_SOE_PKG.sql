--------------------------------------------------------
--  DDL for Package PAY_NZ_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_SOE_PKG" AUTHID CURRENT_USER as
/* $Header: pynzsoe.pkh 120.0.12000000.1 2007/01/17 23:22:14 appldev noship $ */

/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  NZ HRMS statement of earnings package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  10 MAY 2000 JMHATRE  N/A        Created
**  04 AUG 2000 NDOMA    N/A       Added two procedures which is required
**                                 for NZ SOE window(get_details and
**                                 get_asg_latest_pay).
**  21 AUG 2000 NDOMA    N/A       Added new procedure(final_balance_totals)
**                                 Which is used to get the cumulative run
**                                 balances if the prepayments is run for
**                                 selected run or prepayments.
**  03 DEC 2002 SRRAJAGO 2689221   Included 'nocopy' options for the 'out' and 'in out'
**                                 parameters of all the procedures.
*/

-------------------------------------------------------------------------------
 procedure get_home_address(p_person_id    IN     NUMBER,
                            p_addr_line1   OUT NOCOPY VARCHAR2,
                            p_addr_line2   OUT NOCOPY VARCHAR2,
                            p_addr_line3   OUT NOCOPY VARCHAR2,
                            p_town_city    OUT NOCOPY VARCHAR2,
                            p_postal_code  OUT NOCOPY VARCHAR2,
                            p_country_name OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------

 procedure get_work_address(p_location_id  IN     NUMBER,
                            p_addr_line1   OUT NOCOPY VARCHAR2,
                            p_addr_line2   OUT NOCOPY VARCHAR2,
                            p_addr_line3   OUT NOCOPY VARCHAR2,
                            p_town_city    OUT NOCOPY VARCHAR2,
                            p_postal_code  OUT NOCOPY VARCHAR2,
                            p_country_name OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------

FUNCTION get_tax_code(p_run_assignment_action_id number) return varchar2 ;

-------------------------------------------------------------------------------

function get_salary (	p_pay_basis_id number,
			p_assignment_id number,
			p_effective_date date )
			return varchar2;

-------------------------------------------------------------------------------

procedure balance_totals
    (p_assignment_id               in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id        in pay_assignment_actions.assignment_action_id%type,
     p_effective_date              in date,
     p_gross_this_pay              out nocopy number,
     p_other_deductions_this_pay   out nocopy number,
     p_tax_deductions_this_pay     out nocopy number,
     p_gross_ytd                   out nocopy number,
     p_other_deductions_ytd        out nocopy number,
     p_tax_deductions_ytd          out nocopy number,
      p_non_tax_allow_this_pay     out nocopy number,
     p_non_tax_allow_ytd           out nocopy number,
     p_pre_tax_deductions_this_pay out nocopy number,
     p_pre_tax_deductions_ytd      out nocopy number);


function business_currency_code
    (p_business_group_id  in hr_organization_units.business_group_id%type)
  return fnd_currencies.currency_code%type;

 procedure run_and_ytd_balances
    (p_assignment_id         in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_effective_date        in date,
     p_balance_name          in pay_balance_types.balance_name%type,
     p_run_balance           out nocopy number,
     p_ytd_balance           out nocopy number);

procedure get_asg_latest_pay(p_session_date in     date,
                 p_payroll_exists           in out nocopy varchar2,
                 p_assignment_action_id     in out nocopy number,
                 p_run_assignment_action_id in out nocopy number,
                 p_assignment_id            in     number,
                 p_payroll_id               out nocopy number,
                 p_payroll_action_id        in out nocopy number,
                 p_date_earned              in out nocopy varchar2,
                 p_time_period_id           out nocopy number,
                 p_period_name              out nocopy varchar2,
                 p_pay_advice_date          out nocopy date,
                 p_pay_advice_message       out nocopy varchar2);

procedure get_details (p_assignment_action_id in out nocopy number,
                      p_run_assignment_action_id in out nocopy number,
                      p_assignment_id        in out nocopy number,
                      p_payroll_id              out nocopy number,
                      p_payroll_action_id    in out nocopy number,
                      p_date_earned          in out nocopy date,
                      p_time_period_id          out nocopy number,
                      p_period_name             out nocopy varchar2,
                      p_pay_advice_date         out nocopy date,
                      p_pay_advice_message      out nocopy varchar2);
procedure final_balance_totals
    (p_assignment_id           in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id    in pay_assignment_actions.assignment_action_id%type,
     p_effective_date              in date,
     p_gross_this_pay              out nocopy number,
     p_other_deductions_this_pay   out nocopy number,
     p_tax_deductions_this_pay     out nocopy number,
     p_gross_ytd                   out nocopy number,
     p_other_deductions_ytd        out nocopy number,
     p_tax_deductions_ytd          out nocopy number,
     p_non_tax_allow_this_pay      out nocopy number,
     p_non_tax_allow_ytd           out nocopy number,
     p_pre_tax_deductions_this_pay out nocopy number,
     p_pre_tax_deductions_ytd      out nocopy number);

END pay_nz_soe_pkg ;

 

/
