--------------------------------------------------------
--  DDL for Package PAY_AU_REC_DET_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_REC_DET_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pyaurecd.pkh 120.6 2008/03/18 13:27:04 avenkatk noship $*/
/*

*** ------------------------------------------------------------------------+
*** Program:     pay_au_rec_det_archive (Package Specification)
***
*** Change History
***
*** Date       Changed By  Version  Bug No   Description of Change
*** ---------  ----------  -------  ------  --------------------------------+
*** 25 DEC 03   avenkatk     1.0    3064269   Initial version
*** 16 APR 04   punmehta     1.1     3538810   Modified for GSCC standards
*** 04 JUN 04   abhkumar     1.2    3662449   Added function check_termination to check termination status.
*** 25-JAN-05   abhkumar     1.3    4142159   Added "delete_actions" to parameters
*** 16-OCT-06   priupadh     1.4    5603254   Added Function get_element_payment_hours
*** 27-OCT-06   hnainani      1.7              Backing out changes made due to bug 5599310
*** 3-MAR-07i   hnainani     1.8    5599310   Added function get_element_payment_rate
*** 26-FEB-08   vdabgar      1.9    6839263   Added a variable for parameters.
*** 18-MAR-08   avenkatk     1.10   6839263   Backed out changes for parameters
*** ------------------------------------------------------------------------+
*/

TYPE parameters IS RECORD (payroll_id 		number,
			org_id 			number,
			business_group_id 	number,
			start_date 		date,
			end_date 		date,
			pact_id 		number,
			legal_employer 		number,
                        assignment_id           number,
			sort_order_1 		varchar2(50),
			sort_order_2 		varchar2(50),
			sort_order_3 		varchar2(50),
			sort_order_4 		varchar2(50),
			period_end_date 	date,
			ytd_totals 		varchar2(1),
			zero_records	 	varchar2(1),
			negative_records        varchar2(1),
			employee_type           varchar2(1),
			delete_actions          varchar2(1)); /*Bug# 4142159*/

g_parameters parameters;



g_def_bal_c pay_balance_pkg.t_balance_value_tab;   -- To Populate the Defined Balance IDs


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

/*Bug#3662449*/
function check_termination
  (p_sys_status per_assignment_status_types.per_system_status%TYPE,
   p_emp_type varchar2)
   return varchar2;

/*Bug#5603254 */
function get_element_payment_hours
(
   p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE,
   p_element_type_id IN pay_element_entries_f.element_entry_id%TYPE,
   p_run_result_id   IN pay_run_results.run_result_ID%TYPE,
   p_effective_date  IN pay_payroll_actions.effective_date%TYPE
)
return number;

/* Bug 5599310 */

function get_element_payment_rate
(
   p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE,
   p_element_type_id IN pay_element_entries_f.element_entry_id%TYPE,
   p_run_result_id   IN pay_run_results.run_result_ID%TYPE,
   p_effective_date  IN pay_payroll_actions.effective_date%TYPE
)
return number;

end pay_au_rec_det_archive;

/
