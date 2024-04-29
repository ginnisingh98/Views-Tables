--------------------------------------------------------
--  DDL for Package PAY_NO_EMP_CONT_2007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_EMP_CONT_2007" AUTHID CURRENT_USER AS
/* $Header: pynoempcont2007.pkh 120.0.12010000.1 2008/07/27 23:13:59 appldev ship $ */

------------------------------- Definig Globals and initializing ----------------------------------------------------

g_error_flag	BOOLEAN	:= FALSE;

g_error_check	BOOLEAN := FALSE;

--------------------------------Defining record Types------------------------------------------------

-- record type for Main table for Legal Employer and Local Unit

TYPE g_tab_main_rectype IS
   RECORD ( legal_employer_id           NUMBER
           ,local_unit_id           	NUMBER
	   ,zone                        VARCHAR2(10)
	   ,exemption_limit_used	NUMBER
	   ,run_base			NUMBER
	   ,run_contribution            NUMBER );


-- record type for Calculation table for Legal Employer and Local Unit

TYPE g_tab_calc_rectype IS
   RECORD ( zone                        VARCHAR2(10)
           ,under_limit                 VARCHAR2(10)
           ,status                      VARCHAR2(200)
           ,bimonth_base                NUMBER
           ,run_base                    NUMBER
           ,bimonth_contribution        NUMBER
           ,bimonth_contribution_todate NUMBER
           ,run_contribution            NUMBER );



---------------------------------Defining Table Types-----------------------------------------------


-- table type for Main table for Legal Employer and Local Unit

TYPE g_tab_main_tabtype IS TABLE OF g_tab_main_rectype
   INDEX BY BINARY_INTEGER;


-- table type for Calculation table for Legal Employer and Local Unit

TYPE g_tab_calc_tabtype IS TABLE OF g_tab_calc_rectype
   INDEX BY BINARY_INTEGER;

------------------new table types

-- table type for unique LU
TYPE g_lu_tabtype IS TABLE OF NUMBER (20)
   INDEX BY BINARY_INTEGER;

-- table type for unique MU
-- changing type from Number to Varchar for Jurisdiction code (text) / TM

 TYPE g_mu_tabtype IS TABLE OF VARCHAR2 (20)
   INDEX BY BINARY_INTEGER;




---------------------------------Defining Global PL/SQL Table -----------------------------------------------

	g_tab_main		PAY_NO_EMP_CONT_2007.g_tab_main_tabtype;

--------------------------------Cursor Definitions ----------------------------------------------------------

    -- cursor to get Status and Report Separately from Local Unit
	cursor get_lu_details(l_local_unit_id   NUMBER) IS
	select ORG_INFORMATION4 status , ORG_INFORMATION5 report_sep , ORG_INFORMATION6 lu_tax_mun
	from HR_ORGANIZATION_INFORMATION
	where ORGANIZATION_ID = l_local_unit_id
	and org_information_context = 'NO_LOCAL_UNIT_DETAILS';



    -- Cursor to get the payroll_action_id

	cursor csr_payroll_action_id (p_date_earned  DATE ) is
	select ppa.PAYROLL_ACTION_ID
	from pay_payroll_actions	ppa
	    ,pay_run_types_f		prt
	where ppa.RUN_TYPE_ID = prt.RUN_TYPE_ID
	and   prt.LEGISLATION_CODE = 'NO'
	and   prt.RUN_TYPE_NAME IN ('Main','Standard','Process Alone','Pay Separately')
	and   p_date_earned between prt.EFFECTIVE_START_DATE and prt.EFFECTIVE_END_DATE
	and  ppa.effective_date between trunc(Add_months(p_date_earned,MOD(TO_NUMBER(TO_CHAR(p_date_earned,'MM')),2)-1),'MM')
                    	        and     last_day(Add_months(p_date_earned,MOD(TO_NUMBER(TO_CHAR(p_date_earned,'MM')),2)));



	-- Cursor to get the assignment_action_id and assignment_id
	cursor csr_assignment_id (p_tax_unit_id   pay_assignment_actions.TAX_UNIT_ID%TYPE
    	                     ,l_payroll_action_id  pay_payroll_actions.PAYROLL_ACTION_ID%type) is
	select ASSIGNMENT_ID
	      ,ASSIGNMENT_ACTION_ID
	from pay_assignment_actions
	where PAYROLL_ACTION_ID = l_payroll_action_id
	and TAX_UNIT_ID = p_tax_unit_id;

	-- Cursor to get the Local Unit and Tax Municipality

	cursor csr_lu_mu (l_assignment_id   per_all_assignments_f.ASSIGNMENT_ID%type
	                 ,l_assignment_action_id   pay_assignment_actions.ASSIGNMENT_ACTION_ID   %type
			 ,p_date_earned  DATE
			 ,l_ele_type_id	 NUMBER ) is
	SELECT scl.segment2             local_unit_id
    	      ,rr.jurisdiction_code     tax_mun_id
	FROM pay_assignment_actions   assact
	    ,per_all_assignments_f    asg
	    ,hr_soft_coding_keyflex   scl
	    ,pay_run_results          rr
	WHERE assact.assignment_action_id = l_assignment_action_id
	AND   assact.assignment_id = asg.assignment_id
	AND   asg.assignment_id = l_assignment_id
	AND   p_date_earned BETWEEN asg.EFFECTIVE_START_DATE AND asg.EFFECTIVE_END_DATE
	AND   asg.SOFT_CODING_KEYFLEX_ID = scl.SOFT_CODING_KEYFLEX_ID
	AND   assact.assignment_action_id = rr.assignment_action_id
	AND   rr.ELEMENT_TYPE_ID = l_ele_type_id
	AND   rr.ASSIGNMENT_ACTION_ID = l_assignment_action_id ;


	-- cursor to get the Local Units (LU) and Legal Employers (LE) of the current assignments

	cursor csr_get_lu_le
		(p_payroll_action_id  pay_payroll_actions.PAYROLL_ACTION_ID%type
		,p_date_earned  DATE ) is

	SELECT  scl.segment2	loc_unit , assact.tax_unit_id	leg_emp
	FROM pay_assignment_actions	assact
	    ,pay_run_types_f		prt
	    ,per_all_assignments_f	asg
	    ,hr_soft_coding_keyflex	scl
	WHERE	assact.PAYROLL_ACTION_ID = p_payroll_action_id
	and	prt.LEGISLATION_CODE = 'NO'
	and	prt.RUN_TYPE_NAME = 'Employer Contributions'
	and	nvl(assact.RUN_TYPE_ID,-99) <> prt.RUN_TYPE_ID
	and	p_date_earned between prt.EFFECTIVE_START_DATE and prt.EFFECTIVE_END_DATE
	and	asg.assignment_id = assact.assignment_id
	and	asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
	group by scl.segment2 ,assact.tax_unit_id ;


    -- cursor to get Name of Organisation (LE or LU) from org_id

    CURSOR csr_org_name (p_org_id  HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE ,
                         p_bus_group_id  HR_ORGANIZATION_UNITS.BUSINESS_GROUP_ID%TYPE ) IS
    SELECT NAME
    FROM HR_ORGANIZATION_UNITS
    WHERE ORGANIZATION_ID = p_org_id
    AND BUSINESS_GROUP_ID = p_bus_group_id ;


    -- cursor to get STATUS from Legal Employer
    cursor get_le_status(p_tax_unit_id   pay_assignment_actions.TAX_UNIT_ID%TYPE) IS
    select ORG_INFORMATION3
    from HR_ORGANIZATION_INFORMATION
    where ORGANIZATION_ID = p_tax_unit_id
    and org_information_context = 'NO_LEGAL_EMPLOYER_DETAILS';

/*
   -- cursor to get the Exemption Limit of Legal Employer or Local Unit
	cursor csr_get_exemption_limit (p_org_id NUMBER , p_date_earned DATE) is
	select nvl(to_number(ORG_INFORMATION1),0)
	from hr_organization_information
	where ORGANIZATION_ID = p_org_id
	and ORG_INFORMATION_CONTEXT = 'NO_NI_EXEMPTION_LIMIT'
	and p_date_earned between fnd_date.canonical_to_date(ORG_INFORMATION2) and fnd_date.canonical_to_date(ORG_INFORMATION3);

*/

   -- 2007 Legislative changes for Economic support to Employer
   -- a new field 'Economic Aid' (ORG_INFORMATION4) has been added

   -- cursor to get the Exemption Limit of Legal Employer or Local Unit

/*
	cursor csr_get_exemption_limit (p_org_id NUMBER , p_date_earned DATE) is
	select nvl(fnd_number.canonical_to_number(ORG_INFORMATION1),0) exemption_limit
	      ,nvl(fnd_number.canonical_to_number(ORG_INFORMATION4),0) economic_aid
	from hr_organization_information
	where ORGANIZATION_ID = p_org_id
	and ORG_INFORMATION_CONTEXT = 'NO_NI_EXEMPTION_LIMIT'
	and p_date_earned between fnd_date.canonical_to_date(ORG_INFORMATION2) and fnd_date.canonical_to_date(ORG_INFORMATION3);

*/

   -- cursor to get the Exemption Limit And Economic Aid of Legal Employer or Local Unit
   -- modified the cursor to fetch the sum of exemption limit and economic aid values over the entire year

	cursor csr_get_exemption_limit (p_org_id NUMBER , p_date_earned DATE) is
	select sum(nvl(fnd_number.canonical_to_number(ORG_INFORMATION1),0)) exemption_limit
	      ,sum(nvl(fnd_number.canonical_to_number(ORG_INFORMATION4),0)) economic_aid
	from hr_organization_information
	where ORGANIZATION_ID = p_org_id
	and ORG_INFORMATION_CONTEXT = 'NO_NI_EXEMPTION_LIMIT'
	and fnd_date.canonical_to_date(ORG_INFORMATION2) between trunc(p_date_earned,'YYYY') and add_months(trunc(p_date_earned,'YYYY')-1,12)
	and fnd_date.canonical_to_date(ORG_INFORMATION3) between trunc(p_date_earned,'YYYY') and add_months(trunc(p_date_earned,'YYYY')-1,12);

----------------------------------Function declarations----------------------------------------------


-- Function to calculate the Employer Contributions

FUNCTION GET_EMPLOYER_DEDUCTION
  (p_tax_unit_id    		IN  NUMBER
  ,p_local_unit_id  		IN  NUMBER
  ,p_jurisdiction_code		IN  VARCHAR2
  ,p_payroll_id     		IN  NUMBER
  ,p_payroll_action_id		IN  NUMBER
  ,p_date_earned    		IN  DATE
  ,p_asg_act_id     		IN  NUMBER
  ,p_bus_group_id		IN  NUMBER
  ,p_under_age_high_rate	IN  NUMBER
  ,p_over_age_high_rate		IN  NUMBER
  ,p_run_base			OUT NOCOPY  NUMBER
  ,p_run_contribution      	OUT NOCOPY  NUMBER
  ,p_curr_exemption_limit_used	OUT NOCOPY  NUMBER) RETURN NUMBER  ;


-- Function to get defined balance id

FUNCTION get_defined_balance_id
  (p_balance_name   		IN  VARCHAR2
  ,p_dbi_suffix     		IN  VARCHAR2 ) RETURN NUMBER ;


FUNCTION populate_tables
  (p_tax_unit_id    IN  NUMBER
  ,p_payroll_id     IN  NUMBER
  ,p_date_earned    IN  DATE
  ,g_lu_tab    	    IN  OUT NOCOPY PAY_NO_EMP_CONT_2007.g_lu_tabtype
  ,g_mu_tab  	    IN  OUT NOCOPY PAY_NO_EMP_CONT_2007.g_mu_tabtype ) RETURN NUMBER ;


-- function to get the lookup meaning
  FUNCTION get_lookup_meaning (p_lookup_type IN varchar2,p_lookup_code IN varchar2) RETURN VARCHAR2 ;

-- Function to look up the corresponding cell number in he table g_tab_calc
FUNCTION lookup_cell
  (g_tab_calc  IN  PAY_NO_EMP_CONT_2007.g_tab_calc_tabtype
  ,l_zone      IN  VARCHAR2 ) RETURN NUMBER ;


-- function for main calculation

FUNCTION ec_main_calculation

  (g_tab_calc  			IN  OUT NOCOPY 	PAY_NO_EMP_CONT_2007.g_tab_calc_tabtype
  ,g_tab_main  			IN  OUT NOCOPY  PAY_NO_EMP_CONT_2007.g_tab_main_tabtype
  ,p_tax_unit_id    		IN  NUMBER
  ,p_local_unit_id 		IN  NUMBER
  ,p_exemption_limit_used 	IN  NUMBER
  ,p_org_status 		IN  VARCHAR2
  ,p_bus_group_id      		IN  NUMBER
  ,p_date_earned    		IN  DATE
  ,p_under_age_high_rate	IN  NUMBER
  ,p_over_age_high_rate		IN  NUMBER
  ,l_curr_zone			IN  VARCHAR2
  ) RETURN NUMBER ;


-- function to get the ec rate

FUNCTION get_ec_rate

  (p_zone			IN  VARCHAR2
  ,p_under_limit		IN  VARCHAR2
  ,p_org_status 		IN  VARCHAR2
  ,p_bus_group_id      		IN  NUMBER
  ,p_date_earned    		IN  DATE
  ,p_under_age_high_rate	IN  NUMBER
  ,p_over_age_high_rate		IN  NUMBER ) RETURN NUMBER ;


-- function to display table values of g_tab_calc

FUNCTION display_table_calc
  (g_tab_calc  IN  PAY_NO_EMP_CONT_2007.g_tab_calc_tabtype ) RETURN NUMBER ;


-- function to get the average NI Base Rate Value

FUNCTION avg_ni_base_rate (p_date_earned  IN  DATE , p_bus_grp_id NUMBER ) RETURN NUMBER ;


-- Function to look up the corresponding cell number in he table g_tab_main

FUNCTION main_lookup_cell
  (g_tab_main  		IN  PAY_NO_EMP_CONT_2007.g_tab_main_tabtype
  ,start_main_index	IN  NUMBER
  ,l_zone      		IN  VARCHAR2 ) RETURN NUMBER ;


-- Function to check if any exemption limit error exists

FUNCTION chk_exemption_limit_err
  (p_date_earned	IN  DATE
  ,p_bus_grp_id		IN  NUMBER
  ,p_payroll_action_id  IN  NUMBER )  RETURN NUMBER ;


-- function to get the employer contribution rate
FUNCTION get_emp_contr_rate

  (p_bus_group_id		IN NUMBER,
  p_tax_unit_id			IN NUMBER,
  p_local_unit_id		IN NUMBER,
  p_jurisdiction_code		IN VARCHAR2,
  p_date_earned			IN DATE,
  p_asg_act_id			IN NUMBER,
  p_under_age_high_rate		IN NUMBER,
  p_over_age_high_rate		IN NUMBER,
  p_under_limit			IN VARCHAR2 ) RETURN NUMBER;


--------------------------------------------------------------------------------



END PAY_NO_EMP_CONT_2007 ;

/
