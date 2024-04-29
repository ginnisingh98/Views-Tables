--------------------------------------------------------
--  DDL for Package Body PAY_NL_WTS_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_WTS_REPORT" AS
/* $Header: paynlwts.pkb 120.1.12000000.2 2007/08/23 05:17:49 abhgangu noship $ */

/*-------------------------------------------------------------------------------------
Function to get the last assignment_action_id for each person and payroll
--------------------------------------------------------------------------------------*/
FUNCTION GET_LAST_ASG_ACT_ID(l_person_id IN NUMBER,l_payroll_id IN NUMBER,l_date_earned IN DATE)
RETURN NUMBER IS
CURSOR csr_get_last_asg_act_id(l_person_id NUMBER,l_payroll_id NUMBER,l_date_earned DATE) IS
SELECT paa.assignment_action_id assignment_action_id
FROM
	pay_assignment_actions paa,
	pay_payroll_actions ppa,
	per_all_assignments_f pas
WHERE
	pas.person_id = l_person_id
AND 	pas.payroll_id = l_payroll_id
AND 	ppa.date_earned = l_date_earned
AND	pas.assignment_id = paa.assignment_id
AND 	ppa.payroll_id = pas.payroll_id
AND 	paa.payroll_action_id = ppa.payroll_action_id
AND	paa.action_status='C'
AND 	ppa.action_type in ('R','Q','V','B','I')
AND 	ppa.date_earned between pas.effective_start_date and pas.effective_end_date
	and exists(select * from pay_run_results
		   where assignment_action_id=paa.assignment_action_id
		   and (element_type_id in (Get_Element_Type_Id('Wage Tax Subsidy Low Wages'), Get_Element_Type_Id('Wage Tax Subsidy Education')
		       , Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed') , Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))
		   or 	element_type_id in (Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')
		       ,Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))))
		   order by assignment_action_id desc;

l_asg_act_id NUMBER;
BEGIN
OPEN csr_get_last_asg_act_id(l_person_id,l_payroll_id,l_date_earned);
FETCH csr_get_last_asg_act_id INTO l_asg_act_id;
CLOSE csr_get_last_asg_act_id;
RETURN l_asg_act_id;
END;


/*-------------------------------------------------------------------------------------
Function to get the org_struct_version_id.
--------------------------------------------------------------------------------------*/
FUNCTION Get_org_struct_version_id(p_org_struct_id IN NUMBER,p_month_to IN VARCHAR2) RETURN NUMBER IS
cursor Csr_Get_Org_Struct_Version_Id(l_org_struct_id NUMBER,l_month_to VARCHAR2) IS
Select org_structure_version_id
From per_org_structure_versions posv
Where organization_structure_id=l_org_struct_id
and to_date(l_month_to,'MMYYYY') between posv.date_from and nvl(posv.date_to,hr_general.end_of_time);
l_org_struct_ver_id per_org_structure_versions.org_structure_version_id%TYPE;
BEGIN
OPEN Csr_Get_Org_Struct_Version_Id(p_org_struct_id,p_month_to);
FETCH Csr_Get_Org_Struct_Version_Id INTO l_org_struct_ver_id;
CLOSE Csr_Get_Org_Struct_Version_Id;
RETURN l_org_struct_ver_id;
END Get_org_struct_version_id;


/*-------------------------------------------------------------------------------------
Function to get the Element_Type_id.
--------------------------------------------------------------------------------------*/
FUNCTION Get_Element_Type_Id(p_element_name IN VARCHAR2)
RETURN NUMBER IS
cursor Csr_Get_Element_Type_Id(l_element_name varchar2) IS
select element_type_id
from pay_element_types_F
where element_name = l_element_name
and legislation_code = 'NL';
l_Element_Type_Id pay_element_types_F.element_type_id%TYPE;
BEGIN
OPEN Csr_Get_Element_Type_Id(p_element_name);
FETCH Csr_Get_Element_Type_Id INTO l_Element_Type_Id;
CLOSE Csr_Get_Element_Type_Id;
RETURN l_Element_Type_Id;
END Get_Element_Type_Id;


/*-------------------------------------------------------------------------------------
Function to get the Input_Value_id.
--------------------------------------------------------------------------------------*/
FUNCTION Get_Input_Value_Id(p_input_value varchar2,p_element_type_id NUMBER)
RETURN NUMBER IS
cursor Csr_Get_Input_Value_Id(l_input_value varchar2,l_element_type_id NUMBER) IS
select round(input_value_id,2)
from pay_input_values_f
where name=l_input_value
and element_type_id=l_element_type_id
and legislation_code='NL';
l_Input_Value_Id NUMBER;
BEGIN
OPEN Csr_Get_Input_Value_Id(p_input_value,p_element_type_id);
FETCH Csr_Get_Input_Value_Id INTO l_Input_Value_Id;
CLOSE Csr_Get_Input_Value_Id;
RETURN l_Input_Value_Id;
END Get_Input_Value_Id;


/*-------------------------------------------------------------------------------------
Function to get the Defined_Balance_Id
--------------------------------------------------------------------------------------*/
FUNCTION Get_Defined_Balance_Id(p_balance_name IN VARCHAR2)
RETURN NUMBER IS
cursor Csr_Get_Defined_Balance_Id(l_balance_name Varchar2) is
select pdb.defined_balance_id
from	pay_balance_dimensions pbd,
pay_balance_types pbt,
pay_defined_balances pdb
where  pbt.balance_type_id = pdb.balance_type_id
and pbt.balance_name =l_balance_name
and pbd.balance_dimension_id = pdb.balance_dimension_id
and pbd.database_item_suffix='_PER_PAY_PTD'
and pbt.legislation_code='NL';
l_Defined_Balance_Id pay_defined_balances.defined_balance_id%TYPE;
BEGIN
OPEN Csr_Get_Defined_Balance_Id(p_balance_name);
FETCH Csr_Get_Defined_Balance_Id INTO l_Defined_Balance_Id;
CLOSE Csr_Get_Defined_Balance_Id;
RETURN l_Defined_Balance_Id;
END Get_Defined_Balance_Id;


/*-------------------------------------------------------------------------------------
Function to get the Subsidy Type
--------------------------------------------------------------------------------------*/
FUNCTION  GET_SUBSIDY_TYPE_NAME(p_Subsidy_Element_Type_ID IN NUMBER)
RETURN VARCHAR2 IS

l_subsidy_name VARCHAR2(240);

BEGIN
IF p_Subsidy_Element_Type_ID IN (Get_Element_Type_Id('Wage Tax Subsidy Low Wages')
                                 ,Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')) THEN
	RETURN hr_general.decode_lookup('NL_FORM_LABELS','LOW_WAGES');

ELSIF p_Subsidy_Element_Type_ID IN (Get_Element_Type_Id('Wage Tax Subsidy Education')
	                            ,Get_Element_Type_Id('Retro Wage Tax Subsidy Education')) THEN
	RETURN hr_general.decode_lookup('NL_FORM_LABELS','EDUCATION');

ELSIF p_Subsidy_Element_Type_ID IN (Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')
				   ,Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')) THEN
	RETURN hr_general.decode_lookup('NL_FORM_LABELS','LONG_TERM_UNEMP');

ELSIF p_Subsidy_Element_Type_ID IN (Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave')
                		    ,Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave')) THEN
	RETURN hr_general.decode_lookup('NL_FORM_LABELS','PAID_PARENTAL_LEAVE');
ELSE RETURN NULL;

END IF;

END GET_SUBSIDY_TYPE_NAME;


/*-------------------------------------------------------------------------------------
Function to get the Retro Wage Tax Subsidy Amount
--------------------------------------------------------------------------------------*/
FUNCTION get_retro_wts	(p_asg_act_id		IN	NUMBER
			,p_element_type_id	IN	NUMBER
			,p_retro_date		IN	DATE)
RETURN NUMBER IS

CURSOR	csr_get_retro_wts(l_asg_act_id NUMBER, l_element_type_id NUMBER, l_retro_date DATE) is
select	DISTINCT
	prr.run_result_id,
	to_number(pay_nl_general.GET_RUN_RESULT_VALUE(paa.assignment_action_id,l_element_type_id,
        decode(l_element_type_id,
        Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Pay Value',Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')),
        Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Pay Value',Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')),
        Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Input_Value_Id('Pay Value',Get_Element_Type_Id('Retro Wage Tax Subsidy Education')),
        Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),Get_Input_value_Id('Pay Value',Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))), prr.run_result_id, 'M')) retro_wts
from	pay_assignment_actions	paa,
	pay_assignment_actions	paa1,
	per_all_assignments_f	pas,
	per_all_assignments_f	pas1,
	pay_payroll_actions	ppa,
	pay_payroll_actions	ppa1,
	pay_run_results		prr
where	paa1.assignment_action_id = l_asg_act_id
and	pas1.assignment_id = paa1.assignment_id
and	pas.person_id = pas1.person_id
and	paa.assignment_id = pas.assignment_id
and	ppa1.payroll_action_id = paa1.payroll_action_id
and	ppa.payroll_action_id = paa.payroll_action_id
and	ppa.payroll_id = pas.payroll_id
and	paa.action_status = 'C'
and	ppa.action_type in ('R','Q','V','B','I')
and	ppa.date_earned between pas.effective_start_date and pas.effective_end_date
and	ppa.time_period_id = ppa1.time_period_id
and	prr.assignment_action_id = paa.assignment_action_id
and	prr.element_type_id = l_element_type_id
and	nvl(pay_nl_general.get_retro_period(prr.source_id,ppa.date_earned),ppa.date_earned) = l_retro_date;



l_retro_wts NUMBER := 0;
v_csr_get_retro_wts csr_get_retro_wts%ROWTYPE;

BEGIN

	hr_utility.set_location('p_asg_sct_id-'||to_char(p_asg_act_id)||' p_element_type_id-'||to_char(p_element_type_id)||' p_retro_date-'||to_char(p_retro_date,'DD-MON-RRRR'),999);

	FOR v_csr_get_retro_wts IN csr_get_retro_wts(p_asg_act_id, p_element_type_id, p_retro_date)
	LOOP

		l_retro_wts := l_retro_wts + v_csr_get_retro_wts.retro_wts;

	END LOOP;

	return l_retro_wts;

END get_retro_wts;


/*-------------------------------------------------------------------------------------
Procedure to generate XML data for WTS Report
--------------------------------------------------------------------------------------*/
procedure populate_wts_report_data(p_bg_id IN NUMBER,
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
                                   p_xfdf_blob OUT NOCOPY BLOB) IS
CURSOR csr_get_record_details is
SELECT	DISTINCT
	hou.name employer_name,
	pap.full_name||'('||pap.employee_number||')' employee,
	hoi.org_information3 tax_office_id,
	hoi.org_information4 tax_reg,
	ppa.business_group_id business_group_id,
                hou1.name,
	paa.person_id,
	ppa.date_earned,
	ppa.payroll_id
from
	per_assignments_f paa,
	pay_payroll_actions ppa,
	per_people_f     pap,
	hr_organization_units hou,
        hr_organization_units hou1,
	hr_organization_information hoi,
	pay_assignment_actions asg_act
where
	ppa.business_group_id=p_bg_id
	and paa.assignment_id = asg_act.assignment_id
	and pap.person_id = paa.person_id
	and ppa.payroll_action_id = asg_act.payroll_action_id
	and asg_act.action_status='C'
	and ppa.action_type in ('R','Q','V','B','I')
	and ppa.date_earned between to_date(p_month_from,'MMYYYY')  AND LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))
	and ppa.date_earned between paa.effective_start_date and paa.effective_end_date
	and paa.organization_id in
                ((SELECT pose.organization_id_child
                  FROM   per_org_structure_elements pose
                  WHERE pose.org_structure_version_id = GET_ORG_STRUCT_VERSION_ID(p_org_struct_id,p_month_to)
                  START with pose.organization_id_parent = nvl(p_top_org_id,p_bg_id)
	          CONNECT BY prior organization_id_child = organization_id_parent )
                  union
                 (select nvl(p_top_org_id,p_bg_id) from dual))
                and pap.person_id=nvl(p_person_id,pap.person_id)
                and   ((p_top_org_id is NULL)  or (nvl(p_inc_sub_emp,'N') = 'N' and hr_nl_org_info.get_tax_org_id(GET_ORG_STRUCT_VERSION_ID(p_org_struct_id,p_month_to),paa.organization_id)=p_top_org_id) or (nvl(p_inc_sub_emp,'N') = 'Y'))
	and hr_nl_org_info.get_tax_org_id(GET_ORG_STRUCT_VERSION_ID(p_org_struct_id,p_month_to),paa.organization_id) is
	not null
	and LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))  between pap.effective_start_date and pap.effective_end_date
	and hou.business_group_id=p_bg_id
                and hou1.organization_id = hoi.org_information3
	and hou.organization_id=hr_nl_org_info.get_tax_org_id(GET_ORG_STRUCT_VERSION_ID(p_org_struct_id,p_month_to),paa.organization_id)
	and hoi.organization_id=hou.organization_id
                and hoi.org_information3 IS NOT NULL
                and hoi.org_information4 IS NOT NULL
	and hoi.org_information_context='NL_ORG_INFORMATION'
	and exists(select * from pay_run_results
		   where assignment_action_id=asg_act.assignment_action_id
		   and (element_type_id in (Get_Element_Type_Id('Wage Tax Subsidy Low Wages'), Get_Element_Type_Id('Wage Tax Subsidy Education') , Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')
		       , Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))
		   or 	element_type_id in (Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Element_Type_Id('Retro Wage Tax Subsidy Education')
		       ,Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))))
	order by employer_name , paa.person_id,ppa.payroll_id,ppa.date_earned;
CURSOR csr_get_wts_elements(l_asg_act_id NUMBER)  IS
SELECT	DISTINCT
	pap.full_name||' ('||pap.employee_number||')' employee_name,
        to_char(ppa.date_earned,'MonthYYYY') current_period,
	paa.assignment_id,
	pay.payroll_name payroll_name,
	ppa.date_earned,
	abs(pay_balance_pkg.get_value(decode(prr.element_type_id,
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Defined_Balance_Id('Wage Tax Subsidy Low Wages'),
	Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Defined_Balance_Id('Wage Tax Subsidy Education'),
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Defined_Balance_Id('Wage Tax Subsidy Long Term Unemployed'),
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),Get_Defined_Balance_Id('Wage Tax Subsidy Paid Parental Leave')),asg_act.assignment_action_id)) Wage_Tax_Subsidy,
	paa.assignment_number,
        to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,
	prr.Element_Type_Id,decode(prr.element_type_id,
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Wage Tax Subsidy Education')) ,
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Parental Leave Hours',Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))),prr.run_result_id,'N')) Working_Hours
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,
	prr.Element_Type_Id,decode(prr.element_type_id,
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'), Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))),prr.run_result_id,'M')) Part_Time_Percentage
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,
	prr.Element_Type_Id,decode(prr.element_type_id,
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))),prr.run_result_id,'M')) Wage_Limit
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,
	prr.Element_Type_Id,decode(prr.element_type_id,
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))),prr.run_result_id,'M')) Basis_Salary,
	prr.element_type_id Subsidy_Element_Type_ID,
	decode(prr.element_type_id,
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),1,
	Get_Element_Type_Id('Wage Tax Subsidy Education'),2,
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),3,
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),4) Sequence
from
	per_assignments_f paa,
	pay_payroll_actions ppa,
	per_people_f pap,
	pay_assignment_actions asg_act,
	pay_run_results prr,
	pay_all_payrolls_f pay
where
	ppa.business_group_id=p_bg_id
	and asg_act.assignment_action_id = l_asg_act_id
	and paa.assignment_id = asg_act.assignment_id
	and pay.payroll_id = ppa.payroll_id
	and pap.person_id = paa.person_id
	and ppa.payroll_action_id = asg_act.payroll_action_id
	and asg_act.action_status='C'
	and ppa.action_type in ('R','Q','V','B','I')
	and ppa.date_earned between to_date(p_month_from,'MMYYYY')  AND LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))
	and ppa.date_earned between paa.effective_start_date and paa.effective_end_date
	and prr.assignment_action_id=asg_act.assignment_action_id
	and LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))  between pap.effective_start_date and pap.effective_end_date
	and prr.element_type_id in (Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))
	and exists(select * from pay_run_results where assignment_action_id=asg_act.assignment_action_id and element_type_id in (Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Element_Type_Id('Wage Tax Subsidy Education')
	                                                                   ,Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave')))
	and (to_number(pay_nl_general.get_run_result_value(asg_act.assignment_action_id,prr.Element_Type_Id,
	              decode(prr.element_type_id,Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Low Wages')),Get_Element_Type_Id('Wage Tax Subsidy Education')
	              ,Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Education')),Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'))
	              ,Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))),prr.run_result_id,'M'))) is not null
	order by employee_name, ppa.date_earned , Sequence;

CURSOR csr_get_retro_wts_elements(l_asg_act_id NUMBER) IS
SELECT	DISTINCT
	pap.full_name||' ('||pap.employee_number||')' employee_name,
	get_retro_wts(prr.assignment_action_id, prr.element_type_id, nvl(pay_nl_general.get_retro_period(prr.source_id,ppa.date_earned),ppa.date_earned))*(-1) Retro_WTS,
	paa.assignment_number,
	pay.payroll_name payroll_name,
	paa.assignment_id,
        to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,prr.Element_Type_Id,
        decode(prr.element_type_id,
        Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')),
        Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')),
        Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Retro Wage Tax Subsidy Education')),
        Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),Get_Input_value_Id('Parental Leave Hours',Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))), prr.run_result_id,'N')) Retro_Working_Hours
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,prr.Element_Type_Id,
	decode(prr.element_type_id,
	Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Input_value_Id('Part time Percentage',Get_Element_Type_Id('Retro Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))), prr.run_result_id,'M')) Retro_Part_Time_Percentage
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,prr.Element_Type_Id,
	decode(prr.element_type_id,
	Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Retro Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))), prr.run_result_id,'M')) Retro_Wage_Limit
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,prr.Element_Type_Id,
	decode(prr.element_type_id,
	Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Retro Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))), prr.run_result_id,'M')) Retro_Basis_Salary
	                     ,to_char(nvl(pay_nl_general.get_retro_period(prr.source_id,ppa.date_earned),ppa.date_earned),'MonthYYYY') Retro_Period
	,nvl(pay_nl_general.get_retro_period(prr.source_id,ppa.date_earned),ppa.date_earned) RDate,
	nvl(pay_nl_general.get_retro_period(prr.source_id,ppa.date_earned),ppa.date_earned) Retro_Date,
	prr.element_type_id Retro_Subsidy_Element_Type_ID,
	decode(prr.element_type_id,
	Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),1,Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),3,
	Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),2,Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),4) Sequence
from
	per_assignments_f paa,
	per_people_f     pap,
	pay_assignment_actions asg_act,
	pay_run_results prr,
	pay_payroll_actions ppa,
	pay_all_payrolls_f pay
where
	ppa.business_group_id=p_bg_id
	and paa.assignment_id = asg_act.assignment_id
	and pap.person_id = paa.person_id
	and pay.payroll_id = ppa.payroll_id
	and asg_act.assignment_action_id = l_asg_act_id
	and ppa.payroll_action_id = asg_act.payroll_action_id
	and asg_act.action_status='C'
	and ppa.action_type in ('R','Q','V','B','I')
	and ppa.date_earned between to_date(p_month_from,'MMYYYY')  AND LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))
	and ppa.date_earned between paa.effective_start_date and paa.effective_end_date
	and prr.assignment_action_id=asg_act.assignment_action_id
	and LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))  between pap.effective_start_date and pap.effective_end_date
	and prr.element_type_id  in (Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),
	                             Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Element_Type_Id('Retro Wage Tax Subsidy Education')
	                             ,Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))
	and exists(select * from pay_run_results where assignment_action_id=asg_act.assignment_action_id and 	element_type_id
	                  in (Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')
	                      ,Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave')) )
	order by employee_name, RDate , Sequence;
v_csr_get_record_details csr_get_record_details%ROWTYPE;
v_csr_get_wts_elements csr_get_wts_elements%ROWTYPE;
v_csr_get_retro_wts_elements csr_get_retro_wts_elements%ROWTYPE;

CURSOR csr_get_bg_name(l_bg_id IN NUMBER) is
SELECT name FROM per_business_groups
WHERE
BUSINESS_GROUP_ID = l_bg_id;

vCtr NUMBER := 0;
l_bg_name per_business_groups.NAME%TYPE;
l_asg_act_id NUMBER;
l_rp_tot_ed_subsidy NUMBER;
l_rp_tot_lw_subsidy NUMBER;
l_rp_tot_ltu_subsidy NUMBER;
l_rp_tot_ppl_subsidy NUMBER;
l_employer_name     VARCHAR2(240);
l_emp_total_subsidy NUMBER;
l_subsidy_name VARCHAR2(240);
l_sub_employers	     VARCHAR2(10);
l_payroll_id 	    NUMBER := NULL;
l_person_id 	NUMBER := NULL;
l_flag BOOLEAN := TRUE;
l_emp VARCHAR2(240):= ' ';
l_payroll VARCHAR2(240) := ' ';
l_period VARCHAR2(240) := ' ';
l_format VARCHAR2(40);

BEGIN

IF FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS') = ',.' THEN
	execute immediate ('alter session set nls_numeric_characters ='',.''');
ELSE
	execute immediate ('alter session set nls_numeric_characters =''.,''');
END IF;
l_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
execute immediate 'alter session set nls_date_format = ''' ||l_format ||'''';
--hr_utility.trace_on(null,'WTS_bug');
hr_utility.set_location('Inside populate_wts_report_data',2000);

OPEN csr_get_bg_name(p_bg_id);
FETCH csr_get_bg_name INTO l_bg_name;
CLOSE csr_get_bg_name;
hr_utility.set_location('Inside populate_wts_report_data: l_bg_name'||l_bg_name,2040);

	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'BG_NAME';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_bg_name;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EFF_DATE';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(fnd_date.canonical_to_date(p_eff_date));
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ORG_HIERARCHY';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := p_org_struct;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EMPLOYER';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := p_top_org;
	IF p_inc_sub_emp = 'N' THEN
		l_sub_employers := 'No';

	ELSIF p_inc_sub_emp = 'Y' THEN
	 	l_sub_employers := 'Yes';
	END IF;


	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'SUB_EMPLOYERS';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_sub_employers;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'MONTH_FROM';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(to_date(p_month_from,'MMYYYY'),'Month YYYY');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'MONTH_TO';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(LAST_DAY(to_date(P_MONTH_TO,'MMYYYY')),'Month YYYY');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EMP_NAME';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := p_employee;
	l_rp_tot_ed_subsidy := 0;
	l_rp_tot_lw_subsidy := 0;
	l_rp_tot_ltu_subsidy:= 0;
	l_rp_tot_ppl_subsidy:= 0;
	l_employer_name     := ' ';
	l_emp_total_subsidy := 0;

FOR  v_csr_get_record_details IN csr_get_record_details
LOOP
	hr_utility.set_location('Inside populate_wts_report_data: Each Record: Employer: '||v_csr_get_record_details.employer_name,2050);
	IF ((NVL(l_payroll_id,-1) <> v_csr_get_record_details.payroll_id
	   AND l_payroll_id IS NOT NULL )
	   OR (NVL(l_person_id,-1)<> v_csr_get_record_details.person_id
	   AND l_person_id IS NOT NULL)) AND  l_flag = FALSE THEN
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_TOTAL';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_emp_total_subsidy,2),'99G999G999D90MI'); /*Bug 4506936*/
		l_emp_total_subsidy:=0;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMPLOYEE';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
		l_emp := ' ';
		l_payroll := ' ';
		l_period := ' ';
	END IF;

	IF v_csr_get_record_details.employer_name <> l_employer_name AND l_flag = FALSE THEN
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMPLOYER';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
	END IF;
	l_flag := FALSE;
        IF v_csr_get_record_details.employer_name <> l_employer_name THEN
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMPLOYER';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMPLOYER1';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_record_details.employer_name;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'TAX_OFFICE1';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_record_details.name;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'TAX_REG_NUM1';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_record_details.tax_reg;
	END IF;
	IF 	NVL(l_payroll_id,-1) <> v_csr_get_record_details.payroll_id
	     OR NVL(l_person_id,-1) <>v_csr_get_record_details.person_id THEN
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMPLOYEE';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;
	END IF;
	l_asg_act_id := GET_LAST_ASG_ACT_ID(v_csr_get_record_details.person_id,v_csr_get_record_details.payroll_id,v_csr_get_record_details.date_earned);

	FOR v_csr_get_wts_elements
	IN csr_get_wts_elements(l_asg_act_id)
	LOOP
--	IF v_csr_get_wts_elements.Wage_Tax_Subsidy <> 0	 THEN
		l_subsidy_name := GET_SUBSIDY_TYPE_NAME(v_csr_get_wts_elements.Subsidy_Element_Type_ID);
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMP_REC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;

		IF l_emp <> v_csr_get_wts_elements.employee_name THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_NAME';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_wts_elements.employee_name;
			l_emp := v_csr_get_wts_elements.employee_name;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_NAME';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		IF l_payroll <> v_csr_get_wts_elements.payroll_name THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PAYROLL';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_wts_elements.payroll_name;
			l_payroll := v_csr_get_wts_elements.payroll_name ;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PAYROLL';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		IF l_period <> v_csr_get_wts_elements.current_period THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PERIOD';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_wts_elements.current_period;
			l_period := v_csr_get_wts_elements.current_period;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PERIOD';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'SUBSIDY_TYPE';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_subsidy_name;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'TAX_SALARY';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_wts_elements.Basis_Salary,2),'99G999G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PART_TIME_PERC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_wts_elements.Part_Time_Percentage,4),'999D9990MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'WORKING_LEAVE_HRS';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_wts_elements.Working_Hours,2),'999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'WAGE_LIMIT';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_wts_elements.Wage_Limit,2),'99G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'SUBSIDY';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2),'99G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMP_REC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','LOW_WAGES') THEN
			l_rp_tot_lw_subsidy  := l_rp_tot_lw_subsidy + ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','EDUCATION') THEN
			l_rp_tot_ed_subsidy  := l_rp_tot_ed_subsidy + ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','LONG_TERM_UNEMP') THEN
			l_rp_tot_ltu_subsidy := l_rp_tot_ltu_subsidy + ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','PAID_PARENTAL_LEAVE') THEN
			l_rp_tot_ppl_subsidy := l_rp_tot_ppl_subsidy + ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2);
		END IF;
		l_emp_total_subsidy:= l_emp_total_subsidy+ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2);
--	END IF;
	END LOOP;
	FOR v_csr_get_retro_wts_elements
	IN  csr_get_retro_wts_elements(l_asg_act_id)
	LOOP
		l_subsidy_name := GET_SUBSIDY_TYPE_NAME(v_csr_get_retro_wts_elements.Retro_Subsidy_Element_Type_ID); /* Bug 4517173*/
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMP_REC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;

		IF l_emp <> v_csr_get_retro_wts_elements.employee_name THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_NAME';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_retro_wts_elements.employee_name;
			l_emp := v_csr_get_retro_wts_elements.employee_name;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_NAME';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		IF l_payroll <> v_csr_get_retro_wts_elements.payroll_name THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PAYROLL';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_retro_wts_elements.payroll_name;
			l_payroll := v_csr_get_retro_wts_elements.payroll_name;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PAYROLL';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		IF l_period <> v_csr_get_retro_wts_elements.Retro_Period THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PERIOD';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_retro_wts_elements.Retro_Period;
			l_period := v_csr_get_retro_wts_elements.Retro_Period;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PERIOD';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'SUBSIDY_TYPE';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := GET_SUBSIDY_TYPE_NAME(v_csr_get_retro_wts_elements.Retro_Subsidy_Element_Type_ID);
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'TAX_SALARY';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_retro_wts_elements.Retro_Basis_Salary,2),'99G999G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PART_TIME_PERC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_retro_wts_elements.Retro_Part_Time_Percentage,4),'999D9990MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'WORKING_LEAVE_HRS';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_retro_wts_elements.Retro_Working_Hours,2),'999G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'WAGE_LIMIT';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_retro_wts_elements.Retro_Wage_Limit,2),'999G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'SUBSIDY';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2),'999G999D90');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMP_REC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','LOW_WAGES') THEN
			l_rp_tot_lw_subsidy  := l_rp_tot_lw_subsidy + ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','EDUCATION') THEN
			l_rp_tot_ed_subsidy  := l_rp_tot_ed_subsidy + ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','LONG_TERM_UNEMP') THEN
			l_rp_tot_ltu_subsidy := l_rp_tot_ltu_subsidy + ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','PAID_PARENTAL_LEAVE') THEN
			l_rp_tot_ppl_subsidy := l_rp_tot_ppl_subsidy + ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2);
		END IF;
		l_emp_total_subsidy := l_emp_total_subsidy+ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2);
	END LOOP;

	l_person_id := v_csr_get_record_details.person_id;
	l_payroll_id := v_csr_get_record_details.payroll_id;
	l_employer_name := v_csr_get_record_details.employer_name;
END LOOP;

IF l_flag = FALSE THEN
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_TOTAL';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_emp_total_subsidy,2),'999G999D90MI');
	l_emp_total_subsidy:=0;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMPLOYEE';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';

	hr_utility.set_location('Outside populate_wts_report_data: Employer Loop',2100);
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMPLOYER';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
END IF;
vCtr := vCtr + 1;
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'REP_TOT_LOW_WAGES';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_rp_tot_lw_subsidy,2),'99G999G999G999D90MI');
vCtr := vCtr + 1;
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'REP_TOT_EDUCATION';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_rp_tot_ed_subsidy,2),'99G999G999G999D90MI');
vCtr := vCtr + 1;
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'REP_TOT_LONG_TERM';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_rp_tot_ltu_subsidy,2),'99G999G999G999D90MI');
vCtr := vCtr + 1;
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'REP_TOT_PARENTAL';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_rp_tot_ppl_subsidy,2),'99G999G999G999D90MI');

hr_utility.set_location('Outside populate_wts_report_data: WritetoCLOB_rtf',2150);
pay_nl_xdo_Report.WritetoCLOB_rtf(p_xfdf_blob );

END populate_wts_report_data;


/*-------------------------------------------------------------------------------------
Procedure to generate XML data for WTS Report for PYXMLEMG
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
                                   p_xml OUT NOCOPY CLOB) IS

CURSOR csr_get_record_details is
SELECT	DISTINCT
	hou.name employer_name,
	pap.full_name||'('||pap.employee_number||')' employee,
	hoi.org_information3 tax_office_id,
	hoi.org_information4 tax_reg,
	ppa.business_group_id business_group_id,
                hou1.name,
	paa.person_id,
	ppa.date_earned,
	ppa.payroll_id
from
	per_assignments_f paa,
	pay_payroll_actions ppa,
	per_people_f     pap,
	hr_organization_units hou,
        hr_organization_units hou1,
	hr_organization_information hoi,
	pay_assignment_actions asg_act
where
	ppa.business_group_id=p_bg_id
	and paa.assignment_id = asg_act.assignment_id
	and pap.person_id = paa.person_id
	and ppa.payroll_action_id = asg_act.payroll_action_id
	and asg_act.action_status='C'
	and ppa.action_type in ('R','Q','V','B','I')
	and ppa.date_earned between to_date(p_month_from,'MMYYYY')  AND LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))
	and ppa.date_earned between paa.effective_start_date and paa.effective_end_date
	and paa.organization_id in
                ((SELECT pose.organization_id_child
                  FROM   per_org_structure_elements pose
                  WHERE pose.org_structure_version_id = GET_ORG_STRUCT_VERSION_ID(p_org_struct_id,p_month_to)
                  START with pose.organization_id_parent = nvl(p_top_org_id,p_bg_id)
	          CONNECT BY prior organization_id_child = organization_id_parent )
                  union
                 (select nvl(p_top_org_id,p_bg_id) from dual))
                and pap.person_id=nvl(p_person_id,pap.person_id)
                and   ((p_top_org_id is NULL)  or (nvl(p_inc_sub_emp,'N') = 'N' and hr_nl_org_info.get_tax_org_id(GET_ORG_STRUCT_VERSION_ID(p_org_struct_id,p_month_to),paa.organization_id)=p_top_org_id) or (nvl(p_inc_sub_emp,'N') = 'Y'))
	and hr_nl_org_info.get_tax_org_id(GET_ORG_STRUCT_VERSION_ID(p_org_struct_id,p_month_to),paa.organization_id) is
	not null
	and LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))  between pap.effective_start_date and pap.effective_end_date
	and hou.business_group_id=p_bg_id
        and hou1.organization_id = hoi.org_information3
	and hou.organization_id=hr_nl_org_info.get_tax_org_id(GET_ORG_STRUCT_VERSION_ID(p_org_struct_id,p_month_to),paa.organization_id)
	and hoi.organization_id=hou.organization_id
	and hoi.org_information3 IS NOT NULL
	and hoi.org_information4 IS NOT NULL
	and hoi.org_information_context='NL_ORG_INFORMATION'
	and exists(select *
		   from pay_run_results
		   where assignment_action_id=asg_act.assignment_action_id
		   and (element_type_id in (Get_Element_Type_Id('Wage Tax Subsidy Low Wages')
		   			   ,Get_Element_Type_Id('Wage Tax Subsidy Education')
		   			   ,Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')
		   			   ,Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave')
		   			   --RSS
		   			   ,Get_Element_Type_Id('Wage Tax Subsidy EVC')
		   			   --RSS
		   			   )
		   or 	element_type_id in (Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')
		   			   ,Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')
		   			   ,Get_Element_Type_Id('Retro Wage Tax Subsidy Education')
		       			   ,Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave')
		       			   --RSS
		       			   ,Get_Element_Type_Id('Retro Wage Tax Subsidy EVC')
		       			   --RSS
		       			   )
		       )
		 )
	order by employer_name , paa.person_id,ppa.payroll_id,ppa.date_earned;

CURSOR csr_get_wts_elements(l_asg_act_id NUMBER)  IS
SELECT	DISTINCT
	pap.full_name||' ('||pap.employee_number||')' employee_name,
        to_char(ppa.date_earned,'MonthYYYY') current_period,
	paa.assignment_id,
	pay.payroll_name payroll_name,
	ppa.date_earned,
	abs(pay_balance_pkg.get_value(decode(prr.element_type_id,
	--RSS
	Get_Element_Type_Id('Wage Tax Subsidy EVC'),Get_Defined_Balance_Id('Wage Tax Subsidy EVC'),
	--RSS
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Defined_Balance_Id('Wage Tax Subsidy Low Wages'),
	Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Defined_Balance_Id('Wage Tax Subsidy Education'),
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Defined_Balance_Id('Wage Tax Subsidy Long Term Unemployed'),
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),Get_Defined_Balance_Id('Wage Tax Subsidy Paid Parental Leave')),asg_act.assignment_action_id)) Wage_Tax_Subsidy,
	paa.assignment_number,
        to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,
	prr.Element_Type_Id,decode(prr.element_type_id,
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Wage Tax Subsidy Education')) ,
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Parental Leave Hours',Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))),prr.run_result_id,'N')) Working_Hours
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,
	prr.Element_Type_Id,decode(prr.element_type_id,
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'), Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))),prr.run_result_id,'M')) Part_Time_Percentage
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,
	prr.Element_Type_Id,decode(prr.element_type_id,
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))),prr.run_result_id,'M')) Wage_Limit
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,
	prr.Element_Type_Id,decode(prr.element_type_id,
	Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'))),prr.run_result_id,'M')) Basis_Salary,
	prr.element_type_id Subsidy_Element_Type_ID,
	decode(prr.element_type_id
	,Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),1
	,Get_Element_Type_Id('Wage Tax Subsidy Education'),2
	,Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),3
	,Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),4
	--RSS
	,Get_Element_Type_Id('Wage Tax Subsidy EVC'),5
	--RSS
	) Sequence
from
	per_assignments_f paa,
	pay_payroll_actions ppa,
	per_people_f pap,
	pay_assignment_actions asg_act,
	pay_run_results prr,
	pay_all_payrolls_f pay
where
	ppa.business_group_id=p_bg_id
	and asg_act.assignment_action_id = l_asg_act_id
	and paa.assignment_id = asg_act.assignment_id
	and pay.payroll_id = ppa.payroll_id
	and pap.person_id = paa.person_id
	and ppa.payroll_action_id = asg_act.payroll_action_id
	and asg_act.action_status='C'
	and ppa.action_type in ('R','Q','V','B','I')
	and ppa.date_earned between to_date(p_month_from,'MMYYYY')  AND LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))
	and ppa.date_earned between paa.effective_start_date and paa.effective_end_date
	and prr.assignment_action_id=asg_act.assignment_action_id
	and LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))  between pap.effective_start_date and pap.effective_end_date
	and prr.element_type_id in (Get_Element_Type_Id('Wage Tax Subsidy Low Wages')
				   ,Get_Element_Type_Id('Wage Tax Subsidy Education')
				   ,Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')
				   ,Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave')
				   --RSS
				   ,Get_Element_Type_Id('Wage Tax Subsidy EVC')
				   --RSS
				   )
	and exists(select *
		   from pay_run_results
		   where assignment_action_id=asg_act.assignment_action_id
		   and element_type_id in (Get_Element_Type_Id('Wage Tax Subsidy Low Wages')
		   			  ,Get_Element_Type_Id('Wage Tax Subsidy Education')
	                                  ,Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')
	                                  ,Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave')
	                                   --RSS
	                                  ,Get_Element_Type_Id('Wage Tax Subsidy EVC')
	                                   --RSS
	                                  )
	          )
	and (to_number(pay_nl_general.get_run_result_value(asg_act.assignment_action_id
							   ,prr.Element_Type_Id
							   ,decode(prr.element_type_id,
							   	   Get_Element_Type_Id('Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Low Wages')),
							   	   Get_Element_Type_Id('Wage Tax Subsidy Education'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Education')),
							   	   Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Long Term Unemployed')),
	              						   Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Wage Tax Subsidy Paid Parental Leave')),
	              						   --RSS
	              						   Get_Element_Type_Id('Wage Tax Subsidy EVC'),Get_Input_Value_Id('Pay Value',Get_Element_Type_Id('Wage Tax Subsidy EVC'))
	              						   --RSS
	              						   )
	              					   ,prr.run_result_id
	              					   ,'M'
	              					  )
	     	      )
	     ) is not null
	order by employee_name, ppa.date_earned , Sequence;

CURSOR csr_get_retro_wts_elements(l_asg_act_id NUMBER) IS
SELECT	DISTINCT
	pap.full_name||' ('||pap.employee_number||')' employee_name,
	get_retro_wts(prr.assignment_action_id, prr.element_type_id, nvl(pay_nl_general.get_retro_period(prr.source_id,ppa.date_earned),ppa.date_earned))*(-1) Retro_WTS,
	paa.assignment_number,
	pay.payroll_name payroll_name,
	paa.assignment_id,
        to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,prr.Element_Type_Id,
        decode(prr.element_type_id,
        Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')),
        Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')),
        Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Input_Value_Id('Working Hours',Get_Element_Type_Id('Retro Wage Tax Subsidy Education')),
        Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),Get_Input_value_Id('Parental Leave Hours',Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))), prr.run_result_id,'N')) Retro_Working_Hours
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,prr.Element_Type_Id,
	decode(prr.element_type_id,
	Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Input_value_Id('Part time Percentage',Get_Element_Type_Id('Retro Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Part time Percentage',Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))), prr.run_result_id,'M')) Retro_Part_Time_Percentage
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,prr.Element_Type_Id,
	decode(prr.element_type_id,
	Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Retro Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Wage Limit',Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))), prr.run_result_id,'M')) Retro_Wage_Limit
	,to_number(pay_nl_general.GET_RUN_RESULT_VALUE(prr.assignment_action_id,prr.Element_Type_Id,
	decode(prr.element_type_id,
	Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Retro Wage Tax Subsidy Education')),
	Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),Get_Input_Value_Id('Basis Salary',Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'))), prr.run_result_id,'M')) Retro_Basis_Salary
	,to_char(nvl(pay_nl_general.get_retro_period(prr.source_id,ppa.date_earned),ppa.date_earned),'MonthYYYY') Retro_Period
	,nvl(pay_nl_general.get_retro_period(prr.source_id,ppa.date_earned),ppa.date_earned) RDate,
	nvl(pay_nl_general.get_retro_period(prr.source_id,ppa.date_earned),ppa.date_earned) Retro_Date,
	prr.element_type_id Retro_Subsidy_Element_Type_ID,
	decode(prr.element_type_id
	,Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),1
	,Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),3
	,Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),2
	,Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),4
	--RSS
	,Get_Element_Type_Id('Retro Wage Tax Subsidy EVC'),5
	--RSS
	) Sequence
from
	per_assignments_f paa,
	per_people_f     pap,
	pay_assignment_actions asg_act,
	pay_run_results prr,
	pay_payroll_actions ppa,
	pay_all_payrolls_f pay
where
	ppa.business_group_id=p_bg_id
	and paa.assignment_id = asg_act.assignment_id
	and pap.person_id = paa.person_id
	and pay.payroll_id = ppa.payroll_id
	and asg_act.assignment_action_id = l_asg_act_id
	and ppa.payroll_action_id = asg_act.payroll_action_id
	and asg_act.action_status='C'
	and ppa.action_type in ('R','Q','V','B','I')
	and ppa.date_earned between to_date(p_month_from,'MMYYYY')  AND LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))
	and ppa.date_earned between paa.effective_start_date and paa.effective_end_date
	and prr.assignment_action_id=asg_act.assignment_action_id
	and LAST_DAY(to_date(P_MONTH_TO,'MMYYYY'))  between pap.effective_start_date and pap.effective_end_date
	and prr.element_type_id  in (Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),
	                             Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),
	                             Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),
	                             Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),
	                             --RSS
	                             Get_Element_Type_Id('Retro Wage Tax Subsidy EVC')
	                             --RSS
	                            )
	and exists(select *
			from pay_run_results
			where assignment_action_id=asg_act.assignment_action_id
			and element_type_id
	                in 	(Get_Element_Type_Id('Retro Wage Tax Subsidy Low Wages'),
	                	 Get_Element_Type_Id('Retro Wage Tax Subsidy Long Term Unemployed'),
	                      	 Get_Element_Type_Id('Retro Wage Tax Subsidy Education'),
	                      	 Get_Element_Type_Id('Retro Wage Tax Subsidy Paid Parental Leave'),
	                      	 --RSS
	                      	 Get_Element_Type_Id('Retro Wage Tax Subsidy EVC')
	                      	 --RSS
	                      	)
	          )
	order by employee_name, RDate , Sequence;
v_csr_get_record_details csr_get_record_details%ROWTYPE;
v_csr_get_wts_elements csr_get_wts_elements%ROWTYPE;
v_csr_get_retro_wts_elements csr_get_retro_wts_elements%ROWTYPE;

CURSOR csr_get_bg_name(l_bg_id IN NUMBER) is
SELECT name FROM per_business_groups
WHERE
BUSINESS_GROUP_ID = l_bg_id;

vCtr NUMBER := 0;
l_bg_name per_business_groups.NAME%TYPE;
l_asg_act_id NUMBER;
l_rp_tot_ed_subsidy NUMBER;
l_rp_tot_lw_subsidy NUMBER;
l_rp_tot_ltu_subsidy NUMBER;
l_rp_tot_ppl_subsidy NUMBER;
l_employer_name     VARCHAR2(240);
l_emp_total_subsidy NUMBER;
l_subsidy_name VARCHAR2(240);
l_sub_employers	     VARCHAR2(10);
l_payroll_id 	    NUMBER := NULL;
l_person_id 	NUMBER := NULL;
l_flag BOOLEAN := TRUE;
l_emp VARCHAR2(240):= ' ';
l_payroll VARCHAR2(240) := ' ';
l_period VARCHAR2(240) := ' ';
l_format VARCHAR2(40);

BEGIN

IF FND_PROFILE.VALUE('ICX_NUMERIC_CHARACTERS') = ',.' THEN
	execute immediate ('alter session set nls_numeric_characters ='',.''');
ELSE
	execute immediate ('alter session set nls_numeric_characters =''.,''');
END IF;
l_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
execute immediate 'alter session set nls_date_format = ''' ||l_format ||'''';
--hr_utility.trace_on(null,'WTS_bug');
hr_utility.set_location('Inside populate_wts_report_data',2000);

OPEN csr_get_bg_name(p_bg_id);
FETCH csr_get_bg_name INTO l_bg_name;
CLOSE csr_get_bg_name;
hr_utility.set_location('Inside populate_wts_report_data: l_bg_name'||l_bg_name,2040);

	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'BG_NAME';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_bg_name;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EFF_DATE';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(fnd_date.canonical_to_date(p_eff_date));
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ORG_HIERARCHY';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := p_org_struct;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EMPLOYER';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := p_top_org;
	IF p_inc_sub_emp = 'N' THEN
		l_sub_employers := 'No';

	ELSIF p_inc_sub_emp = 'Y' THEN
	 	l_sub_employers := 'Yes';
	END IF;


	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'SUB_EMPLOYERS';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_sub_employers;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'MONTH_FROM';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(to_date(p_month_from,'MMYYYY'),'Month YYYY');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'MONTH_TO';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(LAST_DAY(to_date(P_MONTH_TO,'MMYYYY')),'Month YYYY');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EMP_NAME';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := p_employee;
	l_rp_tot_ed_subsidy := 0;
	l_rp_tot_lw_subsidy := 0;
	l_rp_tot_ltu_subsidy:= 0;
	l_rp_tot_ppl_subsidy:= 0;
	l_employer_name     := ' ';
	l_emp_total_subsidy := 0;

FOR  v_csr_get_record_details IN csr_get_record_details
LOOP
	hr_utility.set_location('Inside populate_wts_report_data: Each Record: Employer: '||v_csr_get_record_details.employer_name,2050);
	IF ((NVL(l_payroll_id,-1) <> v_csr_get_record_details.payroll_id
	   AND l_payroll_id IS NOT NULL )
	   OR (NVL(l_person_id,-1)<> v_csr_get_record_details.person_id
	   AND l_person_id IS NOT NULL)) AND  l_flag = FALSE THEN
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_TOTAL';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_emp_total_subsidy,2),'99G999G999D90MI'); /*Bug 4506936*/
		l_emp_total_subsidy:=0;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMPLOYEE';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
		l_emp := ' ';
		l_payroll := ' ';
		l_period := ' ';
	END IF;

	IF v_csr_get_record_details.employer_name <> l_employer_name AND l_flag = FALSE THEN
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMPLOYER';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
	END IF;
	l_flag := FALSE;
        IF v_csr_get_record_details.employer_name <> l_employer_name THEN
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMPLOYER';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMPLOYER1';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_record_details.employer_name;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'TAX_OFFICE1';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_record_details.name;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'TAX_REG_NUM1';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_record_details.tax_reg;
	END IF;
	IF 	NVL(l_payroll_id,-1) <> v_csr_get_record_details.payroll_id
	     OR NVL(l_person_id,-1) <>v_csr_get_record_details.person_id THEN
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMPLOYEE';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;
	END IF;
	l_asg_act_id := GET_LAST_ASG_ACT_ID(v_csr_get_record_details.person_id,v_csr_get_record_details.payroll_id,v_csr_get_record_details.date_earned);

	FOR v_csr_get_wts_elements
	IN csr_get_wts_elements(l_asg_act_id)
	LOOP
--	IF v_csr_get_wts_elements.Wage_Tax_Subsidy <> 0	 THEN
		l_subsidy_name := GET_SUBSIDY_TYPE_NAME(v_csr_get_wts_elements.Subsidy_Element_Type_ID);
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMP_REC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;

		IF l_emp <> v_csr_get_wts_elements.employee_name THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_NAME';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_wts_elements.employee_name;
			l_emp := v_csr_get_wts_elements.employee_name;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_NAME';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		IF l_payroll <> v_csr_get_wts_elements.payroll_name THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PAYROLL';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_wts_elements.payroll_name;
			l_payroll := v_csr_get_wts_elements.payroll_name ;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PAYROLL';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		IF l_period <> v_csr_get_wts_elements.current_period THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PERIOD';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_wts_elements.current_period;
			l_period := v_csr_get_wts_elements.current_period;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PERIOD';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'SUBSIDY_TYPE';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_subsidy_name;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'TAX_SALARY';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_wts_elements.Basis_Salary,2),'99G999G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PART_TIME_PERC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_wts_elements.Part_Time_Percentage,4),'999D9990MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'WORKING_LEAVE_HRS';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_wts_elements.Working_Hours,2),'999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'WAGE_LIMIT';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_wts_elements.Wage_Limit,2),'99G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'SUBSIDY';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2),'99G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMP_REC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';

		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','LOW_WAGES') THEN
			l_rp_tot_lw_subsidy  := l_rp_tot_lw_subsidy + ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','EDUCATION') THEN
			l_rp_tot_ed_subsidy  := l_rp_tot_ed_subsidy + ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','LONG_TERM_UNEMP') THEN
			l_rp_tot_ltu_subsidy := l_rp_tot_ltu_subsidy + ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','PAID_PARENTAL_LEAVE') THEN
			l_rp_tot_ppl_subsidy := l_rp_tot_ppl_subsidy + ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2);
		END IF;
		l_emp_total_subsidy:= l_emp_total_subsidy+ROUND(v_csr_get_wts_elements.Wage_Tax_Subsidy,2);
--	END IF;
	END LOOP;
	FOR v_csr_get_retro_wts_elements
	IN  csr_get_retro_wts_elements(l_asg_act_id)
	LOOP
		l_subsidy_name := GET_SUBSIDY_TYPE_NAME(v_csr_get_retro_wts_elements.Retro_Subsidy_Element_Type_ID); /* Bug 4517173*/
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMP_REC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;

		IF l_emp <> v_csr_get_retro_wts_elements.employee_name THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_NAME';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_retro_wts_elements.employee_name;
			l_emp := v_csr_get_retro_wts_elements.employee_name;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_NAME';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		IF l_payroll <> v_csr_get_retro_wts_elements.payroll_name THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PAYROLL';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_retro_wts_elements.payroll_name;
			l_payroll := v_csr_get_retro_wts_elements.payroll_name;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PAYROLL';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		IF l_period <> v_csr_get_retro_wts_elements.Retro_Period THEN
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PERIOD';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_csr_get_retro_wts_elements.Retro_Period;
			l_period := v_csr_get_retro_wts_elements.Retro_Period;
		ELSE
			vCtr := vCtr + 1;
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PERIOD';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		END IF;

		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'SUBSIDY_TYPE';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := GET_SUBSIDY_TYPE_NAME(v_csr_get_retro_wts_elements.Retro_Subsidy_Element_Type_ID);
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'TAX_SALARY';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_retro_wts_elements.Retro_Basis_Salary,2),'99G999G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'PART_TIME_PERC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_retro_wts_elements.Retro_Part_Time_Percentage,4),'999D9990MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'WORKING_LEAVE_HRS';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_retro_wts_elements.Retro_Working_Hours,2),'999G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'WAGE_LIMIT';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_retro_wts_elements.Retro_Wage_Limit,2),'999G999D90MI');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'SUBSIDY';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2),'999G999D90');
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMP_REC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','LOW_WAGES') THEN
			l_rp_tot_lw_subsidy  := l_rp_tot_lw_subsidy + ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','EDUCATION') THEN
			l_rp_tot_ed_subsidy  := l_rp_tot_ed_subsidy + ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','LONG_TERM_UNEMP') THEN
			l_rp_tot_ltu_subsidy := l_rp_tot_ltu_subsidy + ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2);
		END IF;
		IF l_subsidy_name = hr_general.decode_lookup('NL_FORM_LABELS','PAID_PARENTAL_LEAVE') THEN
			l_rp_tot_ppl_subsidy := l_rp_tot_ppl_subsidy + ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2);
		END IF;
		l_emp_total_subsidy := l_emp_total_subsidy+ROUND(v_csr_get_retro_wts_elements.Retro_WTS,2);
	END LOOP;

	l_person_id := v_csr_get_record_details.person_id;
	l_payroll_id := v_csr_get_record_details.payroll_id;
	l_employer_name := v_csr_get_record_details.employer_name;
END LOOP;

IF l_flag = FALSE THEN
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'EMP_TOTAL';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_emp_total_subsidy,2),'999G999D90MI');
	l_emp_total_subsidy:=0;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMPLOYEE';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';

	hr_utility.set_location('Outside populate_wts_report_data: Employer Loop',2100);
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'G_CONTAINER_EMPLOYER';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
END IF;
vCtr := vCtr + 1;
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'REP_TOT_LOW_WAGES';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_rp_tot_lw_subsidy,2),'99G999G999G999D90MI');
vCtr := vCtr + 1;
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'REP_TOT_EDUCATION';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_rp_tot_ed_subsidy,2),'99G999G999G999D90MI');
vCtr := vCtr + 1;
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'REP_TOT_LONG_TERM';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_rp_tot_ltu_subsidy,2),'99G999G999G999D90MI');
vCtr := vCtr + 1;
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := 'REP_TOT_PARENTAL';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := TO_CHAR(ROUND(l_rp_tot_ppl_subsidy,2),'99G999G999G999D90MI');

hr_utility.set_location('Outside populate_wts_report_data: WritetoCLOB_rtf',2150);
pay_nl_xdo_Report.WritetoCLOB_rtf_1(p_xml);

END populate_wts_report_data_1;




PROCEDURE record_4712(p_file_id NUMBER) IS
	l_upload_name       VARCHAR2(1000);
	l_file_name         VARCHAR2(1000);
	l_start_date        DATE := TO_DATE('01/01/0001', 'dd/mm/yyyy');
	l_end_date          DATE := TO_DATE('31/12/4712', 'dd/mm/yyyy');
BEGIN
	-- program_name will be used to store the file_name
	-- this is bcos the file_name in fnd_lobs contains
	-- the full patch of the doc and not just the file name
	SELECT program_name
	INTO l_file_name
	FROM fnd_lobs
	WHERE file_id = p_file_id;
	-- the delete will ensure that the patch is rerunnable
	DELETE FROM per_gb_xdo_templates
	WHERE file_name = l_file_name AND
	effective_start_date = l_start_date AND
	effective_end_date = l_end_date;
	INSERT INTO per_gb_xdo_templates
	(file_id,
	file_name,
	file_description,
	effective_start_date,
	effective_end_date)
	SELECT p_file_id, l_file_name, 'Template for year 0001-4712',
	l_start_date, l_end_date
	FROM fnd_lobs
	WHERE file_id = p_file_id;
END;
END PAY_NL_WTS_REPORT;

/
