--------------------------------------------------------
--  DDL for Package PAY_GB_PAYROLL_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_PAYROLL_ACTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pypra04t.pkh 120.0.12010000.3 2009/06/23 10:37:35 rlingama ship $ */
--
PROCEDURE total_payment(p_assignment_action_id in number,
			p_total_payment out nocopy number);
PROCEDURE total_deduct(p_assignment_action_id in number,
       		       p_total_deduct out nocopy number);

procedure get_database_items (p_assignment_id     in     number,
                              p_run_assignment_action_id in number,
                              p_date_earned       in     varchar2,
                              p_payroll_action_id in     number,
                              p_tax_period        in out nocopy varchar2,
                              p_tax_refno         in out nocopy varchar2,
                              p_tax_code          in out nocopy varchar2,
                              p_tax_basis         in out nocopy varchar2,
                              p_ni_category       in out nocopy varchar2);

PROCEDURE get_report_db_items (p_assignment_id     in     number,
                               p_run_assignment_action_id in number,
			       p_date_earned       in     varchar2,
			       p_payroll_action_id in     number,
			       p_tax_period        in out nocopy varchar2,
			       p_tax_refno         in out nocopy varchar2,
			       p_tax_phone         in out nocopy varchar2,
			       p_tax_code          in out nocopy varchar2,
			       p_tax_basis         in out nocopy varchar2,
			       p_ni_category       in out nocopy varchar2);

PROCEDURE get_balance_items (p_assignment_action_id in     number,
			     p_gross_pay            in out nocopy number,
			     p_taxable_pay          in out nocopy number,
			     p_paye                 in out nocopy number,
			     p_niable_pay           in out nocopy number,
			     p_ni_paid              in out nocopy number);

FUNCTION report_balance_items (p_balance_name         in varchar2,
                               p_dimension            in varchar2,
                               p_assignment_action_id in number)
                               return number;

-- overloaded version (definition prior to 99 EOY3)
PROCEDURE get_report_balances (p_assignment_action_id in     number,
			       p_label_1              in out nocopy varchar2,
			       p_value_1              in out nocopy number,
			       p_label_2              in out nocopy varchar2,
			       p_value_2              in out nocopy number,
			       p_label_3              in out nocopy varchar2,
			       p_value_3              in out nocopy number,
			       p_label_4              in out nocopy varchar2,
			       p_value_4              in out nocopy number,
			       p_label_5              in out nocopy varchar2,
			       p_value_5              in out nocopy number,
			       p_label_6              in out nocopy varchar2,
			       p_value_6              in out nocopy number,
			       p_label_7              in out nocopy varchar2,
			       p_value_7              in out nocopy number,
			       p_label_8              in out nocopy varchar2,
			       p_value_8              in out nocopy number,
			       p_label_9              in out nocopy varchar2,
			       p_value_9              in out nocopy number,
			       p_label_a              in out nocopy varchar2,
			       p_value_a              in out nocopy number,
			       p_label_b              in out nocopy varchar2,
			       p_value_b              in out nocopy number,
			       p_label_c              in out nocopy varchar2,
			       p_value_c              in out nocopy number);

procedure formula_inputs_wf (p_session_date             in     date,
			     p_payroll_exists           in out nocopy varchar2,
			     p_assignment_action_id     in out nocopy number,
			     p_run_assignment_action_id in out nocopy number,
			     p_assignment_id            in     number,
			     p_payroll_action_id        in out nocopy number,
			     p_date_earned              in out nocopy varchar2);

procedure formula_inputs_hc (p_assignment_action_id   in out nocopy number,
			     p_run_assignment_action_id in out nocopy number,
			     p_assignment_id          in out nocopy number,
                             p_payroll_action_id      in out nocopy number,
			     p_date_earned            in out nocopy varchar2);

procedure get_home_add(p_person_id IN NUMBER,
                       p_add1 IN out nocopy VARCHAR2,
                       p_add2 IN out nocopy VARCHAR2,
                       p_add3 IN out nocopy VARCHAR2,
		       p_reg1 IN out nocopy VARCHAR2,
		       p_reg2 IN out nocopy VARCHAR2,
		       p_reg3 IN out nocopy VARCHAR2,
                       p_twnc IN out nocopy VARCHAR2);

procedure get_work_add(p_location_id IN NUMBER,
                       p_add1 IN out nocopy VARCHAR2,
                       p_add2 IN out nocopy VARCHAR2,
                       p_add3 IN out nocopy VARCHAR2,
                       p_reg1 IN out nocopy VARCHAR2,
                       p_reg2 IN out nocopy VARCHAR2,
                       p_reg3 IN out nocopy VARCHAR2,
                       p_twnc IN out nocopy VARCHAR2);

FUNCTION get_tax_details(p_run_assignment_action_id number,
			 p_input_value_id number,
                         p_paye_input_value_id number,
                         p_date_earned varchar2)
                           return varchar2;

procedure get_input_values_id;

------------------------------------------------------------
function GET_SALARY (	p_pay_basis_id number,
			p_assignment_id number,
			p_effective_date date )
			return varchar2;
pragma restrict_references (get_salary, WNPS, WNDS);
-------------------------------------------------------------------

function report_all_ni_balance (p_balance_name         in varchar2,
                                p_assignment_action_id in number,
                                p_dimension            in varchar2)
                                return number;

function report_employer_balance (p_assignment_action_id in number)
                                 return number;
PROCEDURE get_report_balances (p_assignment_action_id in     number,
			       p_business_group_id    in     number,
			       p_label_1              in out nocopy varchar2,
			       p_value_1              in out nocopy number,
			       p_label_2              in out nocopy varchar2,
			       p_value_2              in out nocopy number,
			       p_label_3              in out nocopy varchar2,
			       p_value_3              in out nocopy number,
			       p_label_4              in out nocopy varchar2,
			       p_value_4              in out nocopy number,
			       p_label_5              in out nocopy varchar2,
			       p_value_5              in out nocopy number,
			       p_label_6              in out nocopy varchar2,
			       p_value_6              in out nocopy number,
			       p_label_7              in out nocopy varchar2,
			       p_value_7              in out nocopy number,
			       p_label_8              in out nocopy varchar2,
			       p_value_8              in out nocopy number,
			       p_label_9              in out nocopy varchar2,
			       p_value_9              in out nocopy number,
			       p_label_a              in out nocopy varchar2,
			       p_value_a              in out nocopy number,
			       p_label_b              in out nocopy varchar2,
			       p_value_b              in out nocopy number,
			       p_label_c              in out nocopy varchar2,
			       p_value_c              in out nocopy number);

/* Start of bug 8497345*/

/* Defined the PL/SQL table in specifaction to access in PAYGBSOE form */
TYPE balance_name_table IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE balance_value_table IS TABLE OF NUMBER(12,2) INDEX BY BINARY_INTEGER;
/* Created overloaded procedure same as get_report_balances */
PROCEDURE get_report_balances (p_assignment_action_id in     number,
			       p_business_group_id    in     number,
			       g_displayed_balance    in out nocopy balance_name_table,
                               g_displayed_value      in out nocopy balance_value_table);
/* End of bug 8497345*/

procedure add_new_soe_balance (p_business_group_id in number,
	  	               p_balance_name 	   in varchar2,
	     	               p_dimension_name	   in varchar2);

procedure add_new_soe_balance (p_balance_name 	 in varchar2,
	     	               p_dimension_name	 in varchar2);

END PAY_GB_PAYROLL_ACTIONS_PKG;

/
