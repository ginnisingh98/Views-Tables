--------------------------------------------------------
--  DDL for Package PAY_NL_WTS_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_WTS_REPORT" AUTHID CURRENT_USER AS
/* $Header: paynlwts.pkh 120.0.12000000.2 2007/08/23 05:07:58 abhgangu noship $ */

/*-------------------------------------------------------------------------------------
Function to get the last assignment_action_id for each person and payroll
--------------------------------------------------------------------------------------*/
FUNCTION GET_LAST_ASG_ACT_ID(l_person_id IN NUMBER,l_payroll_id IN NUMBER,l_date_earned IN DATE)
RETURN NUMBER;

/*-------------------------------------------------------------------------------------
Function to get the org_struct_version_id.
--------------------------------------------------------------------------------------*/
FUNCTION Get_org_struct_version_id(p_org_struct_id IN NUMBER,p_month_to IN VARCHAR2)
RETURN NUMBER;

/*-------------------------------------------------------------------------------------
Function to get the Element_Type_id.
--------------------------------------------------------------------------------------*/
FUNCTION Get_Element_Type_Id(p_element_name IN VARCHAR2)
RETURN NUMBER;

/*-------------------------------------------------------------------------------------
Function to get the Input_Value_id.
--------------------------------------------------------------------------------------*/
FUNCTION Get_Input_Value_Id(p_input_value varchar2,p_element_type_id NUMBER)
RETURN NUMBER;

/*-------------------------------------------------------------------------------------
Function to get the Defined_Balance_Id
--------------------------------------------------------------------------------------*/
FUNCTION Get_Defined_Balance_Id(p_balance_name IN VARCHAR2)
RETURN NUMBER;

/*-------------------------------------------------------------------------------------
Function to get the Subsidy Type
--------------------------------------------------------------------------------------*/
FUNCTION  GET_SUBSIDY_TYPE_NAME(p_Subsidy_Element_Type_ID IN NUMBER)
RETURN VARCHAR2;

/*-------------------------------------------------------------------------------------
Function to get the Retro Wage Tax Subsidy Amount
--------------------------------------------------------------------------------------*/
FUNCTION get_retro_wts	(p_asg_act_id		IN	NUMBER
			,p_element_type_id	IN	NUMBER
			,p_retro_date		IN	DATE)
RETURN NUMBER;

/*-------------------------------------------------------------------------------------
Procedure to generate XML data for WTS Report
--------------------------------------------------------------------------------------*/
PROCEDURE populate_wts_report_data(p_bg_id IN NUMBER,
                                   p_eff_date IN VARCHAR2,
				   p_month_from IN VARCHAR2,
				   p_month_to IN VARCHAR2,
				   p_org_struct_id IN NUMBER,
				   p_org_struct IN VARCHAR2,
                                   p_top_org_id IN NUMBER,
                                   p_top_org IN VARCHAR2,
                                   p_person_id IN NUMBER,
                                   p_employee IN VARCHAR2,
                                   p_inc_sub_emp IN VARCHAR2,
                                   p_xfdf_blob OUT NOCOPY BLOB);

PROCEDURE record_4712(p_file_id NUMBER);

/*-------------------------------------------------------------------------------------
Procedure to generate XML data for WTS Report using PYXMLEMG
--------------------------------------------------------------------------------------*/
procedure populate_wts_report_data_1(p_bg_id IN NUMBER,
                                   p_eff_date IN VARCHAR2,
				                   p_month_from IN VARCHAR2,
				                   p_month_to IN VARCHAR2,
				                   p_org_struct_id IN NUMBER,
				                   p_org_struct IN VARCHAR2,
                                   p_top_org_id IN NUMBER,
                                   p_top_org IN VARCHAR2,
                                   p_person_id IN NUMBER,
                                   p_employee IN VARCHAR2,
                                   p_inc_sub_emp IN VARCHAR2,
                                   p_dummy_employer IN VARCHAR2,
                                   p_template_name IN VARCHAR2,
                                   p_xml OUT NOCOPY CLOB);

END PAY_NL_WTS_REPORT;

 

/
