--------------------------------------------------------
--  DDL for Package PAY_AU_REC_DET_PAYSUM_MODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_REC_DET_PAYSUM_MODE" AUTHID CURRENT_USER as
/* $Header: pyaureps.pkh 120.5.12010000.5 2009/12/15 11:41:11 pmatamsr ship $*/
/*
*** ------------------------------------------------------------------------+
*** Program:     PAY_AU_REC_DET_PAYSUM_MODE (Package Specification)
*** This package is used for horizontal archive implementation of Report
*** "Payroll Reconciliation Detail Report - Payment Summary Mode."
*** Change History
***
*** Date       Changed By  Version Bug No   Description of Change
*** ---------  ----------  ------- ------   --------------------------------+
*** 22 DEC 04  avenkatk    1.0     3899641  Initial Version
*** 30 DEC 04  avenkatk    1.1     3899641  Changed Package Name
*** 07 FEB 05  abhkumar    1.2     4142159  Added delete_actions to parameters.
*** 24 FEB 05  avenkatk    1.3     4201894  Introduced Variable g_adjusted_lump_sum_e_pay
***                                         for storing the Retro Payment < $400
*** 04 JUL 05  avenkatk    1.4     3891577  Introduced procedures for Summary Report - Payment Summary Mode
*** 29 OCT 06  hnainani    1.5     5603254  Added Function get_element_payment_hours
*** 29 OCT 06  hnainani    1.6     5603524 Removed function get_element_payment_hours.. used function defined in pay_au_Rec_Det_archive
*** 26 FEB 08  vdabgar     1.7     6839263  Added a new variable for parameters type.
*** 18 MAR 08  avenkatk    1.9     6839263  Backed out changes for Output type in parameters field
*** 27 JAN 09  skshin      1.10    7571001  Removed summary_rep_populate_allowance procedure and p_allowance_exist in archive_element_details
*** 19 NOV 09  skshin      1.12    8711855  Reverted the change back to 115.10
*** 15 Dec 09  pmatamsr    1.13    9190980  Added a new global variable g_adj_lump_sum_pre_tax for storing Retro GT12 Pre Tax < $400
*** ------------------------------------------------------------------------+
*/
TYPE parameters IS RECORD (
            business_group_id   number,
            legal_employer      number,
            payroll_id              varchar2(240),
            assignment_id           varchar2(240),
            employee_type           varchar2(1),
            fin_year_start_date     date,
            fin_year_end_date       date,
            fbt_year_start_date     date,
            fbt_year_end_date       date,
            lst_year_term           varchar2(1),
            delete_actions          varchar2(1), /*Bug 4142159*/
            report_mode             varchar2(1)); /* Bug 3891577 */

g_parameters parameters;

/* To Store the Defined Balance ID for Fringe Benefits */
g_fbt_defined_balance_id  pay_defined_balances.defined_balance_id%TYPE;

/* For BBR */
g_balance_value_tab     pay_balance_pkg.t_balance_value_tab;
g_context_table         pay_balance_pkg.t_context_tab;
g_result_table          pay_balance_pkg.t_detailed_bal_out_tab;

g_fbt_balance_value number;
g_allowance_balance_value number;
g_adjusted_lump_sum_e_pay number; /*Bug 4201894 */
g_adj_lump_sum_pre_tax    number; /*Bug 9190980 */

/* To Store Allowance Balance_type_ID's */
TYPE
   g_bal_type_tab IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;



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

procedure get_fbt_balance(p_assignment_id in pay_assignment_actions.assignment_id%type
                         ,p_start_date in date
			 ,p_end_date in date
			 ,p_action_sequence out nocopy number);

procedure archive_element_details(p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE
                                  ,p_assignment_id in pay_assignment_actions.assignment_id%TYPE
				  ,p_effective_date in date
				  ,p_pre01jul1983_ratio in number
				  ,p_post30jun1983_ratio in number);

/*bug8711855 - p_assignment_action_id and p_registered_employer parameter are added to call
               pay_au_payment_summary.get_retro_lumpsumE_value function */
procedure Adjust_lumpsum_E_payments(p_assignment_id in pay_assignment_actions.assignment_id%type);

procedure get_allowance_balances(p_assignment_id in pay_assignment_actions.assignment_id%type
                                 ,p_run_assignment_action_id in pay_assignment_actions.assignment_action_id%type);

procedure archive_balance_details(p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE
                                  ,p_assignment_id in pay_assignment_actions.assignment_id%TYPE
				  ,p_effective_date in date
				  ,p_pre01jul1983_ratio in number
				  ,p_post30jun1983_ratio in number
				  ,p_run_action_sequence in pay_assignment_actions.action_sequence%type);


/* Bug 3891577 - Procedure to spawn report for Summary Report */
procedure spawn_summary_reports
(p_payroll_action_id in pay_payroll_actions.payroll_action_id%type);


end pay_au_rec_det_paysum_mode;

/
