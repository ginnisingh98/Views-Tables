--------------------------------------------------------
--  DDL for Package HR_JP_ID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JP_ID_PKG" AUTHID CURRENT_USER as
/* $Header: hrjpid.pkh 120.0 2005/05/30 20:58:21 appldev noship $ */
	C_DEFAULT_BUS	CONSTANT NUMBER := -1;
	C_ALL_BUS	CONSTANT NUMBER := -2;
	C_DEFAULT_LEG	CONSTANT VARCHAR2(2) := 'X';
--------------------------------------------------------------------------------
	FUNCTION LATEST_SQL RETURN VARCHAR2;
--------------------------------------------------------------------------------
	FUNCTION keyflex_combination_id(
			p_appl_short_name		IN VARCHAR2,
			p_id_flex_code			IN VARCHAR2,
			p_id_flex_num			IN NUMBER,
			p_concatenated_segments		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION business_group_rec(
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_BUSINESS_GROUPS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION legislation_code(
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN VARCHAR2;
--------------------------------------------------------------
	FUNCTION id_flex_num(
			p_business_group_id		IN NUMBER,
			p_id_flex_code			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION default_currency_code(
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN VARCHAR2;
--------------------------------------------------------------------------------
	FUNCTION default_currency_code(
			p_legislation_code		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN VARCHAR2;
--------------------------------------------------------------------------------
-- ID with BUSINESS_GROUP_ID and LEGISLATION_CODE
--------------------------------------------------------------------------------
	FUNCTION element_set_rec(
			p_element_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_SETS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION element_set_id(
			p_element_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION backpay_set_rec(
			p_backpay_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BACKPAY_SETS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION backpay_set_id(
			p_backpay_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION classification_rec(
			p_classification_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_CLASSIFICATIONS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION classification_id(
			p_classification_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION element_type_rec(
			p_element_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_TYPES_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION element_type_id(
			p_element_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION balance_type_rec(
			p_balance_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BALANCE_TYPES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION balance_type_id(
			p_balance_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION balance_dimension_rec(
			p_dimension_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BALANCE_DIMENSIONS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION balance_dimension_id(
			p_dimension_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION assignment_status_type_rec(
			p_user_status			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ASSIGNMENT_STATUS_TYPES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION assignment_status_type_id(
			p_user_status			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION user_table_rec(
			p_user_table_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_USER_TABLES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION user_table_id(
			p_user_table_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
-- ID with BUSINESS_GROUP_ID
--------------------------------------------------------------------------------
	FUNCTION location_rec(
			p_location_code			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN HR_LOCATIONS_ALL%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION location_id(
			p_location_code			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION organization_rec(
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN HR_ALL_ORGANIZATION_UNITS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION organization_id(
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION org_payment_method_rec(
			p_org_payment_method_name	IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ORG_PAYMENT_METHODS_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION org_payment_method_id(
			p_org_payment_method_name	IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION payroll_rec(
			p_payroll_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ALL_PAYROLLS_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION payroll_id(
			p_payroll_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION consolidation_set_rec(
			p_consolidation_set_name	IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_CONSOLIDATION_SETS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION consolidation_set_id(
			p_consolidation_set_name	IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION assignment_set_rec(
			p_assignment_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN HR_ASSIGNMENT_SETS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION assignment_set_id(
			p_assignment_set_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION pay_basis_rec(
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_PAY_BASES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION pay_basis_id(
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION person_type_rec(
			p_user_person_type		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_PERSON_TYPES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION person_type_id(
			p_user_person_type		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION emp_person_rec(
			p_employee_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ALL_PEOPLE_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION emp_person_id(
			p_employee_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION apl_person_rec(
			p_applicant_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ALL_PEOPLE_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION apl_person_id(
			p_applicant_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION emp_assignment_rec(
			p_assignment_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ALL_ASSIGNMENTS_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION emp_assignment_id(
			p_assignment_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION rate_id(
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION job_rec(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_JOBS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION job_id(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION position_rec(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_POSITIONS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION position_id(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION grade_rec(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_GRADES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION grade_id(
			p_concatenated_segments		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
-- ID with special case.
--------------------------------------------------------------------------------
	FUNCTION input_value_rec(
			p_element_type_id		IN NUMBER,
			p_name				IN VARCHAR2,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_INPUT_VALUES_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION input_value_id(
			p_element_type_id		IN NUMBER,
			p_name				IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION input_value_rec(
			p_element_name			IN VARCHAR2,
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_INPUT_VALUES_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION input_value_id(
			p_element_name			IN VARCHAR2,
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION defined_balance_rec(
			p_balance_type_id		IN NUMBER,
			p_balance_dimension_id		IN NUMBER,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_DEFINED_BALANCES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION defined_balance_id(
			p_balance_type_id		IN NUMBER,
			p_balance_dimension_id		IN NUMBER,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION defined_balance_rec(
			p_balance_name			IN VARCHAR2,
			p_dimension_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_DEFINED_BALANCES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION defined_balance_id(
			p_balance_name			IN VARCHAR2,
			p_dimension_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION balance_feed_rec(
			p_balance_type_id		IN NUMBER,
			p_input_value_id		IN NUMBER,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BALANCE_FEEDS_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION balance_feed_id(
			p_balance_type_id		IN NUMBER,
			p_input_value_id		IN NUMBER,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION balance_feed_rec(
			p_balance_name			IN VARCHAR2,
			p_element_name			IN VARCHAR2,
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BALANCE_FEEDS_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION balance_feed_id(
			p_balance_name			IN VARCHAR2,
			p_element_name			IN VARCHAR2,
			p_name				IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION business_group_rec(
			p_name				IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_BUSINESS_GROUPS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION business_group_id(
			p_name				IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION formula_type_rec(
			p_formula_type_name		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN FF_FORMULA_TYPES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION formula_type_id(
			p_formula_type_name		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION formula_rec(
			p_formula_name			IN VARCHAR2,
			p_formula_type_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN FF_FORMULAS_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION formula_id(
			p_formula_name			IN VARCHAR2,
			p_formula_type_name		IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION function_rec(
			p_name				IN VARCHAR2,
			p_data_type			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN FF_FUNCTIONS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION function_id(
			p_name				IN VARCHAR2,
			p_data_type			IN VARCHAR2,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION status_processing_rule_rec(
			p_element_type_id		IN NUMBER,
			p_assignment_status_type_id	IN NUMBER	DEFAULT NULL,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_STATUS_PROCESSING_RULES_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION status_processing_rule_id(
			p_element_type_id		IN NUMBER,
			p_assignment_status_type_id	IN NUMBER	DEFAULT NULL,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION formula_result_rule_rec(
			p_status_processing_rule_id	IN NUMBER,
			p_result_name			IN VARCHAR2,
			p_result_rule_type		IN VARCHAR2,
			p_element_type_id		IN NUMBER	DEFAULT NULL,
			p_input_value_id		IN NUMBER	DEFAULT NULL,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_FORMULA_RESULT_RULES_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION formula_result_rule_id(
			p_status_processing_rule_id	IN NUMBER,
			p_result_name			IN VARCHAR2,
			p_result_rule_type		IN VARCHAR2,
			p_element_type_id		IN NUMBER	DEFAULT NULL,
			p_input_value_id		IN NUMBER	DEFAULT NULL,
			p_business_group_id		IN NUMBER	DEFAULT NULL,
			p_legislation_code		IN VARCHAR2	DEFAULT NULL,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION sub_classification_rule_rec(
			p_element_type_id		IN NUMBER,
			p_classification_id		IN NUMBER,
			p_business_group_id		IN NUMBER,
			p_legislation_code		IN VARCHAR2,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_SUB_CLASSIFICATION_RULES_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION sub_classification_rule_id(
			p_element_type_id		IN NUMBER,
			p_classification_id		IN NUMBER,
			p_business_group_id		IN NUMBER,
			p_legislation_code		IN VARCHAR2,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION element_link_id(
			p_assignment_id			IN NUMBER,
			p_element_type_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION element_link_id(
			p_assignment_number		IN VARCHAR2,
			p_element_name			IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION org_information_rec(
			p_organization_id		IN NUMBER,
			p_org_information_context	IN VARCHAR2,
			p_org_information1		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN HR_ORGANIZATION_INFORMATION%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION org_information_id(
			p_organization_id		IN NUMBER,
			p_org_information_context	IN VARCHAR2,
			p_org_information1		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION org_information_rec(
			p_name				IN VARCHAR2,
			p_org_information_context	IN VARCHAR2,
			p_org_information1		IN VARCHAR2	DEFAULT NULL,
			p_business_group_id		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN HR_ORGANIZATION_INFORMATION%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION org_information_id(
			p_name				IN VARCHAR2,
			p_org_information_context	IN VARCHAR2,
			p_org_information1		IN VARCHAR2	DEFAULT NULL,
			p_business_group_id		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION payment_defined_balance_rec(
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_DEFINED_BALANCES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION payment_defined_balance_id(
			p_business_group_id		IN NUMBER,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION legislation_rule_mode(
			p_legislation_code		IN VARCHAR2,
			p_rule_type			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN VARCHAR2;
--------------------------------------------------------------------------------
	FUNCTION payment_type_rec(
			p_payment_type_name		IN VARCHAR2,
			p_territory_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_PAYMENT_TYPES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION payment_type_id(
			p_payment_type_name		IN VARCHAR2,
			p_territory_code		IN VARCHAR2	DEFAULT NULL,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN VARCHAR2;
--------------------------------------------------------------------------------
	FUNCTION grade_rule_rec(
			p_rate_id			IN NUMBER,
			p_grade_id			IN NUMBER,
--			p_rate_type			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_GRADE_RULES_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION grade_rule_id(
			p_rate_id			IN NUMBER,
			p_grade_id			IN NUMBER,
--			p_rate_type			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION flex_value_set_rec(
			p_flex_value_set_name		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN FND_FLEX_VALUE_SETS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION flex_value_set_id(
			p_flex_value_set_name		IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION flex_value_rec(
			p_flex_value_set_id		IN NUMBER,
			p_flex_value			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN FND_FLEX_VALUES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION flex_value_id(
			p_flex_value_set_id		IN NUMBER,
			p_flex_value			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION period_of_service_rec(
			p_employee_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_PERIODS_OF_SERVICE%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION element_entry_rec(
			p_assignment_id			IN VARCHAR2,
			p_element_type_id		IN VARCHAR2,
			p_entry_type			IN VARCHAR2	DEFAULT 'E',
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_ENTRIES_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION element_entry_rec(
			p_assignment_number		IN VARCHAR2,
			p_element_name			IN VARCHAR2,
			p_entry_type			IN VARCHAR2	DEFAULT 'E',
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_ENTRIES_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION primary_address_rec(
		-- This function is valid when address_type is not NULL.
			p_person_id			IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION address_rec(
		-- This function is valid when address_type is not NULL.
			p_person_id			IN NUMBER,
			p_address_type			IN VARCHAR2,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION emp_primary_address_rec(
		-- This function is valid when address_type is not NULL.
			p_employee_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION emp_address_rec(
		-- This function is valid when address_type is not NULL.
			p_employee_number		IN VARCHAR2,
			p_address_type			IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION apl_primary_address_rec(
		-- This function is valid when address_type is not NULL.
			p_applicant_number		IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION apl_address_rec(
		-- This function is valid when address_type is not NULL.
			p_applicant_number		IN VARCHAR2,
			p_address_type			IN VARCHAR2,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_ADDRESSES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION personal_payment_method_rec(
			p_assignment_id			IN NUMBER,
			p_priority			IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_PERSONAL_PAYMENT_METHODS_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION personal_payment_method_rec(
			p_assignment_number		IN VARCHAR2,
			p_priority			IN NUMBER,
			p_business_group_id		IN NUMBER,
			p_effective_date		IN DATE		DEFAULT hr_api.g_sys,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_PERSONAL_PAYMENT_METHODS_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION JP_BANK_REC(
			P_BANK_CODE			IN VARCHAR2,
			P_BRANCH_CODE			IN VARCHAR2,
			p_error_when_not_exist		IN VARCHAR2	DEFAULT 'TRUE') RETURN PER_JP_BANK_LOOKUPS%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION element_link_rec(
			P_ELEMENT_TYPE_ID		IN NUMBER,
			P_ORGANIZATION_ID		IN NUMBER	DEFAULT NULL,
			P_PEOPLE_GROUP_ID		IN NUMBER	DEFAULT NULL,
			P_JOB_ID			IN NUMBER	DEFAULT NULL,
			P_POSITION_ID			IN NUMBER	DEFAULT NULL,
			P_GRADE_ID			IN NUMBER	DEFAULT NULL,
			P_LOCATION_ID			IN NUMBER	DEFAULT NULL,
			P_EMPLOYMENT_CATEGORY		IN VARCHAR2	DEFAULT NULL,
			P_PAYROLL_ID			IN NUMBER	DEFAULT NULL,
			P_LINK_TO_ALL_PAYROLLS_FLAG	IN VARCHAR2	DEFAULT 'N',
			P_PAY_BASIS_ID			IN NUMBER	DEFAULT NULL,
			P_BUSINESS_GROUP_ID		IN NUMBER,
			P_EFFECTIVE_DATE		IN DATE		DEFAULT hr_api.g_sys,
			P_ERROR_WHEN_NOT_EXIST		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ELEMENT_LINKS_F%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION element_link_id(
			P_ELEMENT_TYPE_ID		IN NUMBER,
			P_ORGANIZATION_ID		IN NUMBER	DEFAULT NULL,
			P_PEOPLE_GROUP_ID		IN NUMBER	DEFAULT NULL,
			P_JOB_ID			IN NUMBER	DEFAULT NULL,
			P_POSITION_ID			IN NUMBER	DEFAULT NULL,
			P_GRADE_ID			IN NUMBER	DEFAULT NULL,
			P_LOCATION_ID			IN NUMBER	DEFAULT NULL,
			P_EMPLOYMENT_CATEGORY		IN VARCHAR2	DEFAULT NULL,
			P_PAYROLL_ID			IN NUMBER	DEFAULT NULL,
			P_LINK_TO_ALL_PAYROLLS_FLAG	IN VARCHAR2	DEFAULT 'N',
			P_PAY_BASIS_ID			IN NUMBER	DEFAULT NULL,
			P_BUSINESS_GROUP_ID		IN NUMBER,
			P_EFFECTIVE_DATE		IN DATE		DEFAULT hr_api.g_sys,
			P_ERROR_WHEN_NOT_EXIST		IN VARCHAR2	DEFAULT 'TRUE') RETURN NUMBER;
--------------------------------------------------------------------------------
	FUNCTION backpay_rule_rec(
			P_BACKPAY_SET_ID		IN NUMBER,
			P_DEFINED_BALANCE_ID		IN NUMBER,
			P_INPUT_VALUE_ID		IN NUMBER,
			P_ERROR_WHEN_NOT_EXIST		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_BACKPAY_RULES%ROWTYPE;
--------------------------------------------------------------------------------
	FUNCTION org_pay_method_usage_rec(
			P_PAYROLL_ID			IN NUMBER,
			P_ORG_PAYMENT_METHOD_ID		IN NUMBER,
			P_EFFECTIVE_DATE		IN DATE		DEFAULT hr_api.g_sys,
			P_ERROR_WHEN_NOT_EXIST		IN VARCHAR2	DEFAULT 'TRUE') RETURN PAY_ORG_PAY_METHOD_USAGES_F%ROWTYPE;
--------------------------------------------------------------------------------
end;

 

/
