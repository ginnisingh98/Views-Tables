--------------------------------------------------------
--  DDL for Package PAY_SG_DEDUCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_DEDUCTIONS" AUTHID CURRENT_USER AS
/*  $Header: pysgdedn.pkh 120.0.12010000.2 2008/08/06 08:22:03 ubhat ship $
**
**  Copyright (c) 2002 Oracle Corporation
**  All Rights Reserved
**
**  Procedures and functions used in SG deduction formula
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  =========== ======== ========= =====================
**  26 Jun 2000 makelly  115.0     Initial
**  23 Mar 2002 Ragovind 115.1     Added sg_get_prorator declaration
**  28 Jun 2002 SRussell 115.3     Add functions for CPF Retropay
**  02 Sep 2002 Ragovind 115.4     Added get_prev_year_ord_ytd declaration
**  11 Dec 2002 Apunekar 115.5     Added nocopy to out or in out parameters
**  20 Dec 2002 Ragovind 115.6     Added CPF Report Coding. Bug#2475324
**  11 Feb 2003 Ragovind 115.7     Modified the CPF Report code for Correct CPF for Terminated Employees.Bug#2796093
**  21 Jan 2004 agore    115.8     Added new function get_cur_year_ord_ytd ( )
**  18 May 2004 Nanuradh 115.9     Added new function spl_amount( ) to calculate S Pass Levy.
**  22 Feb 2008 Jalin    115.10    Removed parameter ass_act_id from get_retro_earnings function
**  ============== Formula Fuctions ====================
**  Package containing addition processing required by
**  formula in SG localisation
*/

/*  Global Values used for the CPF Report bugno:2475324*/
-- variable to decide whether formula SG_STAT is called from the
-- report PAYSGCPF or from from the payroll.This is defaulted to Payroll
g_sgstat_called_from varchar2(7) ;

-- If formula SG_STAT is called from the report then
-- below variable will have value as last date of the
-- called year
g_year_end_date_for_cpf_report date;

-- inputs for the SG_STAT formula
g_inputs   ff_exec.inputs_t;

-- outputs for the SG_STAT formula
g_outputs  ff_exec.outputs_t;

/* Sturucture to declare the cpf_calc_inputs */
type cpf_calc_inputs is record
(
  person_id number,   -- stores person_id
  cpf_diff     number      -- difference between cpf paid (values of the balances) and calculate cpf via SG_STAT with SAEOY
);
type cpf_inputs_table is table of cpf_calc_inputs index by binary_integer;

cpf_inputs_t cpf_inputs_table;

/* declaration for bugno:2475324 ends */

/*
**  wp_days_in_month - returns the number of days in a month
**  that an employee has a valid work permit
*/

function  fwl_amount ( p_business_group_id in     number
                     , p_date_earned       in     date
                     , p_assignment_id     in     number
                     , p_start_date        in     date
                     , p_end_date          in     date   )
          return number;

/* Bug: 3595103 - New function to calculate S Pass Levy */
function  spl_amount ( p_business_group_id in     number
                     , p_date_earned       in     date
                     , p_assignment_id     in     number
                     , p_start_date        in     date
                     , p_end_date          in     date   )
          return number;

function sg_get_prorator ( p_assignment_id         in  number,
                             p_date_earned         in  date,
                             p_pay_proc_start_date in  date,
			     p_pay_proc_end_date   in  date,
                             p_wac		   in  varchar2,
                             p_cpf_calc_type       out nocopy varchar2
     			  )
           return number ;

function check_if_retro
         (
           p_element_entry_id  in pay_element_entries_f.element_entry_id%TYPE,
           p_date_earned in pay_payroll_actions.date_earned%TYPE
         ) return varchar2;

function which_retro_method
        (
           p_assignment_id    in pay_assignment_actions.assignment_id%TYPE,
           p_date_earned      in pay_payroll_actions.date_earned%TYPE,
           p_element_entry_id  in pay_element_entries_f.element_entry_id%TYPE
         ) return varchar2;

function earnings_type
         (
           p_element_type_id  in pay_element_types_f.element_type_id%TYPE
         ) return varchar2;

function get_prev_year_ord_ytd
	(
	   p_assignment_id   in pay_assignment_actions.assignment_id%TYPE,
	   p_date_earned     in pay_payroll_actions.date_earned%TYPE
	) return number;
-----------------------------------------
-- Added for Bug# 3279235
-----------------------------------------
function get_cur_year_ord_ytd
        (
           p_assignment_id   in pay_assignment_actions.assignment_id%TYPE,
           p_date_earned     in pay_payroll_actions.date_earned%TYPE
        )
return number;

function get_retro_earnings( p_assignment_id   in pay_assignment_actions.assignment_id%TYPE,
                             p_date_earned     in date )
return number;

/* declarations for PAYSGCPF report bugno:2475324*/

/* Below procedure will initialize all the contexts required for SG_STAT*/

Procedure init_formula (p_formula_name in varchar2, p_effective_date in date);

/* Below function will calculate CPF aditional earnings YTD for the given assignment
  using SAEOY as cpf calculation method*/

function calc_cpf_add_YTD (p_date_earned        in date
                             ,p_assignment_id      in number
                             ,p_process_type       in varchar2
                             ,p_tax_unit_id        in number
                             ,p_asg_action_id      in number
                             ,p_business_group_id  in number
                             ,p_payroll_action_id   in number
                             ,p_payroll_id   in number
                             ,p_balance_date        in date
                            )return number;

/* Returns whether the SG_STAT is called from the REPORT or PAYROLL Run*/

function  get_SG_STAT_CALLED_FROM return varchar2;

/* In the before report trigger of PAYSGCPF the global g_sgstat_called_from
 is set to REPORT*/
procedure set_SG_STAT_CALLED_FROM (p_running in varchar2);

/* Populates the pl/sql table with assignment id and difference of CPF paid (values of the balances)
 and calculated CPF from SG_STAT with SAEOY*/
procedure populate_cpf_table (p_person_id in number,
                              p_cpf_diff number );

/* If the assignment exists in the cpf pl/sql table (populated by populate_cpf_table)
,return 1 else 0. Used in the where clause of the report query*/
function get_assignment_from_cpf_table(p_person_id in number) return number;

/* Get the overpaid value for the assignment passed from the pl/sql table populated by
populate_cpf_table above*/
function get_cpf_difference(p_person_id in number) return number;


/* set the g_year_end_date_for_cpf_report as the last date of the year*/
procedure set_year_end_date(p_year_end_date in date);

/* Return last date of the year (stored in g_year_end_date_for_cpf_report)
, used in the SG_STAT*/
function GET_YEAR_END_DATE return date;


end pay_sg_deductions;

/
