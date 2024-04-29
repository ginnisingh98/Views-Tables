--------------------------------------------------------
--  DDL for Package Body PAY_NL_TAXOFFICE_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_TAXOFFICE_ARCHIVE" as
/* $Header: pynltosa.pkb 120.2.12000000.4 2007/03/13 12:00:10 summohan noship $ */
g_package  varchar2(33) := ' PAY_NL_TAXOFFICE_ARCHIVE.';


g_error_flag varchar2(30);
g_warning_flag varchar2(30);
g_error_count NUMBER;
g_payroll_action_id	NUMBER;
g_assignment_number  VARCHAR2(30);
g_full_name	     VARCHAR2(150);
g_debug boolean;

/*------------------------------------------------------------------------------
|Name           : GET_PARAMETER    					        |
|Type		: Function							|
|Description    : Funtion to get the parameters of the archive process     	|
-------------------------------------------------------------------------------*/


function get_parameter(
         p_parameter_string in varchar2
        ,p_token            in varchar2
        ,p_segment_number   in number default null )    RETURN varchar2
IS

	l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
	l_start_pos  NUMBER;
	l_delimiter  varchar2(1):=' ';
	l_proc VARCHAR2(400):= g_package||' get parameter ';

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_parameter',50);
	end if;

	l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
	--
	IF l_start_pos = 0 THEN
		l_delimiter := '|';
		l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
	end if;

	IF l_start_pos <> 0 THEN
		l_start_pos := l_start_pos + length(p_token||'=');
		l_parameter := substr(p_parameter_string,
		l_start_pos,
		instr(p_parameter_string||' ',
		l_delimiter,l_start_pos)
		- l_start_pos);
		IF p_segment_number IS NOT NULL THEN
			l_parameter := ':'||l_parameter||':';
			l_parameter := substr(l_parameter,
			instr(l_parameter,':',1,p_segment_number)+1,
			instr(l_parameter,':',1,p_segment_number+1) -1
			- instr(l_parameter,':',1,p_segment_number));
		END IF;
	END IF;
	--
	hr_utility.set_location('Leaving get_parameter',53);
	RETURN l_parameter;

    hr_utility.set_location('Exiting get_parameters',50);
END get_parameter;




/*-----------------------------------------------------------------------------
|Name       : GET_ALL_PARAMETERS                                               |
|Type       : Procedure				                               |
|Description: Procedure which returns all the parameters of the archive	process|
-------------------------------------------------------------------------------*/


-----------------------------------------------------------------------------
-- GET_ALL_PARAMETERS gets all parameters for the payroll action
-----------------------------------------------------------------------------
PROCEDURE get_all_parameters (
          p_payroll_action_id     IN         NUMBER
         ,p_business_group_id     OUT NOCOPY NUMBER
         ,p_effective_date        OUT NOCOPY DATE
         ,p_tax_year              OUT NOCOPY DATE
         ,p_employer              OUT NOCOPY number  ) IS
--         ,p_org_struct_id         OUT NOCOPY number  ) IS
--
	CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
	SELECT fnd_date.canonical_to_date(pay_nl_taxoffice_archive.get_parameter(legislative_parameters,'REPORT_YEAR'))
	      ,pay_nl_taxoffice_archive.get_parameter(legislative_parameters,'EMPLOYER_ID')
--	      ,pay_nl_taxoffice_archive.get_parameter(legislative_parameters,'ORG_HIERARCHY')
	      ,effective_date
	      ,business_group_id
	FROM  pay_payroll_actions
	WHERE payroll_action_id = p_payroll_action_id;
	--
	l_effective_date date;
	l_proc VARCHAR2(400):= g_package||' get_all_parameters ';
	--
BEGIN
  --

	if g_debug then
		hr_utility.set_location('Entering get_all_parameters',51);
	end if;

	OPEN csr_parameter_info (p_payroll_action_id);
	FETCH csr_parameter_info INTO
	p_tax_year, p_employer--, p_org_struct_id
	,p_effective_date,p_business_group_id;
	CLOSE csr_parameter_info;

	if g_debug then
		hr_utility.set_location('Leaving get_all_parameters',54);
	end if;

END;
--



/*-------------------------------------------------------------------------------
|Name           : Mandatory_Check                                           	|
|Type			: Procedure							                            |
|Description    : Procedure to check if the specified Mandatory Field is NULL   |
|                 if so flag a Error message to the Log File                    |
-------------------------------------------------------------------------------*/

Procedure Mandatory_Check(p_message_name varchar2
			 ,p_field varchar2
			 ,p_value varchar2) is
	v_message_text fnd_new_messages.message_text%TYPE;
	v_employee_dat VARCHAR2(255);
	v_label_desc   hr_lookups.meaning%TYPE;
Begin
	if g_debug then
		hr_utility.set_location('Checking Field '||p_field,425);
	end if;

		If p_value is null then
				v_label_desc := hr_general.decode_lookup('HR_NL_REPORT_LABELS', p_field);
                v_employee_dat :=RPAD(SUBSTR(g_assignment_number,1,20),20)
                ||' '||RPAD(SUBSTR(g_full_name,1,25),25)
                ||' '||RPAD(SUBSTR(v_label_desc,1,25),25)
                ||' '||RPAD(SUBSTR(g_error_flag,1,15),15);
                hr_utility.set_message(801,p_message_name);
                v_message_text :=SUBSTR(fnd_message.get,1,70);
                g_error_count := NVL(g_error_count,0) +1;
                FND_FILE.PUT_LINE(FND_FILE.LOG, v_employee_dat||' '||v_message_text);
        end if;

end;

/*--------------------------------------------------------------------
|Name       : RANGE_CODE					      |
|Type	    : Procedure				                      |
|Description: This procedure returns a sql string to select a range of|
|	      assignments eligible for archival			      |
----------------------------------------------------------------------*/

Procedure RANGE_CODE (pactid    IN    NUMBER
                     ,sqlstr    OUT   NOCOPY VARCHAR2) is

	v_log_header   VARCHAR2(255);

BEGIN
	-- g_debug:=TRUE;
	if g_debug then
		hr_utility.trace_on(NULL,'TOA');
		hr_utility.set_location('Entering Range Code',50);
	end if;

	/*Return the SELECT Statement to select a range of assignments
	eligible for archival */

	sqlstr := 'SELECT DISTINCT person_id
	FROM  per_people_f ppf
	,pay_payroll_actions ppa
	WHERE ppa.payroll_action_id = :payroll_action_id
	AND   ppa.business_group_id = ppf.business_group_id
	ORDER BY ppf.person_id';


	--Write to Log File
	v_log_header := RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','NL_ASSIGNMENT_NUMBER'),1,20),20)
	||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','FULL_NAME'),1,25),25)
	||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','FIELD_NAME'),1,25),25)
	||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','ERROR_TYPE'),1,15),15)
	||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','MESSAGE'),1,70),70);
	Fnd_file.put_line(FND_FILE.LOG,v_log_header);

	if g_debug then
		hr_utility.set_location('Leaving Range Code',350);
	end if;

END RANGE_CODE;


/*--------------------------------------------------------------------
|Name       : ASSIGNMENT_ACTION_CODE  	                            |
|Type		: Procedure				            |
|Description: This procedure Fetches,validates and archives	    |
|	      information in the newly created context 		    |
|	      NL ATS EMPLOYEE DETAILS				    |
----------------------------------------------------------------------*/
Procedure ASSIGNMENT_ACTION_CODE (
				 p_payroll_action_id  in number
				,p_start_person_id   in number
				,p_end_person_id     in number
				,p_chunk             in number) IS


	/*Cursor Fetches  All the Employee Assignment Records
	whose Employer matches the one selected in the SRS Request
	and for which a Record has not already been archived.
	 */

	CURSOR Cur_EE_ATS_Archive(lp_business_group_id number,lp_employer_id number,
	lp_Tax_Year_End_Date Date,
	lp_Tax_Year_Start_Date Date,
--	lp_org_struct_version_id number,
	lp_start_person_id number,
	lp_end_person_id number
	) IS
	SELECT
		paa.organization_id,
		pap.person_id ,	paa.assignment_id, paa.assignment_number,
		pap.last_name,	pap.Date_of_Birth, pap.full_name
	FROM
		per_people_f pap
		,per_assignments_f paa
		,pay_all_payrolls_f ppf
--		per_all_people_f pap                     Performance fix 5042871
--		,per_all_assignments_f paa
	WHERE	pap.business_group_id = lp_business_group_id
	and 	pap.person_id = paa.person_id
	and 	paa.person_id BETWEEN lp_start_person_id AND lp_end_person_id
	and 	lp_Tax_Year_End_Date between pap.effective_start_date and pap.effective_end_date
	and 	paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   asg.payroll_id is not NULL
		and   asg.effective_start_date <= lp_Tax_Year_End_Date
		and   nvl(asg.effective_end_date, lp_Tax_Year_End_Date) >= lp_Tax_Year_Start_Date

		)
	and	paa.payroll_id = ppf.payroll_id
	and	ppf.business_group_id = lp_business_group_id
	and	ppf.effective_start_date <= lp_Tax_Year_End_Date
	and	ppf.effective_end_date >= lp_Tax_Year_Start_Date
	and	ppf.prl_information_category   = 'NL'
	and	lp_employer_id = ppf.prl_information1;
	/*and lp_employer_id = hr_nl_org_info.get_tax_org_id(lp_org_struct_version_id,paa.organization_id)
	and not exists
	(select 1 from pay_action_information ee_ats
	WHERE ee_ats.action_context_type='AAP'
	AND ee_ats.action_information_category = 'NL ATS EMPLOYEE DETAILS'
	AND ee_ats.action_information1 = lp_employer_id
	AND ee_ats.action_information2 =pap.person_id
	AND ee_ats.action_information3 =paa.assignment_id
	AND ee_ats.effective_date =lp_Tax_Year_End_Date)
	order by pap.person_id,paa.assignment_id;*/



	l_tax_year_start_date date;
	l_tax_year_end_date date;
	l_tax_year_date number;
	l_person_id per_all_people_f.person_id%TYPE;
	l_asg_start_date varchar2(255);
	l_asg_end_date varchar2(255);
	l_assgt_start_date date;
	l_assgt_end_date date;
	l_asg_dates_flag number;
	l_assignment_id number;
	l_sum_of_balances number;
	l_assgt_act_id number;
	l_business_group_id number;
	l_tax_year date;
	l_effective_date date;
--	l_org_struct_id number;
--	l_org_struct_version_id number;


	l_action_info_id number;
	l_asg_act_id number;
	l_ovn number;
	l_ATS_Process_Date date;
	l_employer_id number;
	l_wage number;
	l_taxable_income number;
	l_deduct_wage_tax_si_cont number;
	l_Labour_Discount number;
	l_Wage_Tax_Discount varchar2(255);
	l_Wage_Tax_Table_Code varchar2(255);
	l_Income_Code varchar2(15);
	l_Special_Indicator varchar2(255);
	l_Amount_Special_Indicator varchar2(255);
	l_SI_Insured_Flag varchar2(10);
	l_ZVW_Contribution number;
	l_ZVW_Basis number;
	l_Net_Expense_Allowance number;
	l_Private_Use_Car number;
	l_Value_Private_Use_Car number := 0;
	l_LSS_Saved_Amount number := 0;
	l_Employer_Part_Child_Care number := 0;
	l_Allowance_On_Disability number := 0;
	l_Applied_LCLD number := 0;
	l_User_Bal_String varchar2(255);
	l_active_asg_flag number := 0;


BEGIN
	-- g_debug:=true;
	if g_debug then

		hr_utility.trace_on(NULL,'TOA');

		hr_utility.set_location('Entering ASSIGNMENT_ACTION_CODE',300);
		hr_utility.set_location('Entering Assignment Action Code',400);
		hr_utility.set_location('p_payroll_action_id'||p_payroll_action_id,400);
	end if;

	get_all_parameters (
		  p_payroll_action_id,l_business_group_id
		 ,l_effective_date,l_tax_year,l_employer_id);--, l_org_struct_id);

	if g_debug then

		hr_utility.set_location('Archive p_payroll_action_id'||p_payroll_action_id,425);
		hr_utility.set_location('Archive p_start_person_id'||p_start_person_id,425);
		hr_utility.set_location('Archive p_end_person_id'||p_end_person_id,425);
		hr_utility.set_location('Archive l_effective_date'||l_effective_date,425);
		hr_utility.set_location('Archive l_business_group_id'||l_business_group_id,425);
		hr_utility.set_location('Archive l_tax_year'||l_tax_year,425);
		hr_utility.set_location('Archive l_employer_id'||l_employer_id,425);
--		hr_utility.set_location('Archive l_org_struct_id'||l_org_struct_id,425);
	end if;
	l_tax_year_date:=to_char(l_tax_year,'YYYY');
	l_tax_year_end_date:= to_date('31/12/'||l_tax_year_date,'DD/MM/YYYY');
	l_tax_year_start_date := to_date('01/01/'||l_tax_year_date,'DD/MM/YYYY');

	populate_UserBal(l_business_group_id,l_tax_year_end_date);

	g_error_flag := hr_general.decode_lookup('HR_NL_REPORT_LABELS','ERROR');

	if g_debug then
		hr_utility.set_location('l_tax_year_date'||l_tax_year_date,425);
		hr_utility.set_location('l_tax_year_end_date'||l_tax_year_end_date,425);
		hr_utility.set_location('l_tax_year_start_date'||l_tax_year_start_date,425);
		hr_utility.set_location('l_ATS_Process_Date'||l_ATS_Process_Date,425);
	end if;

	/*Determining the Org Hierarchy Version Id as on the Tax Year End Date
	i.e 31st December for the Year process is being run*/

--	l_org_struct_version_id:=get_org_hierarchy(l_org_struct_id,l_tax_year_end_date);

--	hr_utility.set_location('l_org_struct_version_id'||l_org_struct_version_id,425);

	--hr_utility.trace_on(NULL,'TOSA');

	FOR Cur_EE_ATS_rec in Cur_EE_ATS_Archive(l_business_group_id,l_employer_id,l_tax_year_end_date,l_tax_year_start_date/*,l_org_struct_version_id*/,p_start_person_id,p_end_person_id)

	LOOP

		l_person_id:=Cur_EE_ATS_rec.person_id;
		l_assignment_id :=Cur_EE_ATS_rec.assignment_id;
		g_error_count:=0;
		g_assignment_number:=Cur_EE_ATS_rec.assignment_number;
		g_full_name:=Cur_EE_ATS_rec.full_name;
		l_wage				:= 0;
		l_taxable_income		:= 0;
		l_deduct_wage_tax_si_cont	:= 0;
		l_Labour_Discount		:= 0;
		l_ZVW_Basis			:= 0;
		l_ZVW_Contribution		:= 0;
		l_Net_Expense_Allowance		:= 0;
		l_Private_Use_Car		:= 0;
		l_Value_Private_Use_Car		:= 0;
		l_LSS_Saved_Amount		:= 0;
		l_Employer_Part_Child_Care	:= 0;
		l_Allowance_On_Disability	:= 0;
		l_Applied_LCLD			:= 0;
		l_active_asg_flag		:= 0;


		hr_utility.set_location('Inside for loop, person id-'||l_person_id,350);
		hr_utility.set_location('Inside for loop, assg no-'||g_assignment_number,350);
		hr_utility.set_location('Inside for loop, name-'||g_full_name,350);

		if g_debug then

		hr_utility.set_location('l_person_id'||l_person_id,350);
		hr_utility.set_location('l_assignment_id'||l_assignment_id,350);

		end if;


		/* fetching the assignment start date and assignment end date for archiving it to
		columns pay_action_information6 and pay_action_information7 respectively */


		/* fetching the max assignment action id for an assignment id in the tax year
		for calculating various ASG_YTD balances */

		l_assgt_act_id := get_max_assgt_act_id(l_assignment_id,l_tax_year_start_date,l_tax_year_end_date);

		if g_debug then
			hr_utility.set_location('l_assgt_act_id'||l_assgt_act_id,425);
		end if;

		if l_assgt_act_id is not null then

			l_ATS_Process_Date:=l_tax_year_end_date;

			l_asg_dates_flag := pay_nl_general.get_period_asg_dates(l_assignment_id,l_tax_year_start_date,l_tax_year_end_date,l_assgt_start_date,l_assgt_end_date);

			if l_assgt_start_date < l_tax_year_start_date then
				l_asg_start_date:=to_char(l_tax_year_start_date,'DDMMYYYY');
			else
				l_asg_start_date:=to_char(l_assgt_start_date,'DDMMYYYY');
			end if;

			if l_assgt_end_date > l_tax_year_end_date then
				l_asg_end_date:=to_char(l_tax_year_end_date,'DDMMYYYY');
			else
				l_asg_end_date:=to_char(l_assgt_end_date,'DDMMYYYY');
			end if;



			if g_debug then
				hr_utility.set_location('l_asg_start_date'||l_asg_start_date,400);
				hr_utility.set_location('l_asg_end_date'||l_asg_end_date,400);
			end if;

			hr_utility.set_location('Fetching balances start',410);

			l_wage:=floor(PAY_NL_TAXOFFICE_ARCHIVE.get_wage(l_assgt_act_id) + PAY_NL_TAXOFFICE_ARCHIVE.get_IZA_contributions(l_assgt_act_id));
			l_taxable_income:=floor(PAY_NL_TAXOFFICE_ARCHIVE.get_taxable_income(l_assgt_act_id));
			l_deduct_wage_tax_si_cont:=PAY_NL_TAXOFFICE_ARCHIVE.get_deduct_wage_tax_si_cont(l_assgt_act_id);
			l_Labour_Discount:=PAY_NL_TAXOFFICE_ARCHIVE.get_labour_discount(l_assgt_act_id);
			l_ZVW_Contribution:=PAY_NL_TAXOFFICE_ARCHIVE.get_ZVW_contributions(l_assgt_act_id);
			l_ZVW_Basis:=PAY_NL_TAXOFFICE_ARCHIVE.get_ZVW_basis(l_assgt_act_id);
			l_Value_Private_Use_Car:=PAY_NL_TAXOFFICE_ARCHIVE.get_VALUE_PRIVATE_USE_CAR(l_assgt_act_id);
			l_LSS_Saved_Amount:=PAY_NL_TAXOFFICE_ARCHIVE.get_LSS_Saved_Amount(l_assgt_act_id);
			l_Employer_Part_Child_Care:=PAY_NL_TAXOFFICE_ARCHIVE.get_Employer_Part_Child_Care(l_assgt_act_id);
			l_Allowance_On_Disability:=PAY_NL_TAXOFFICE_ARCHIVE.get_Allowance_On_Disability(l_assgt_act_id);
			l_Applied_LCLD:=PAY_NL_TAXOFFICE_ARCHIVE.get_Applied_LCLD(l_assgt_act_id);

			hr_utility.set_location('Fetching balances end',420);

			PAY_NL_TAXOFFICE_ARCHIVE.get_special_indicators(l_assgt_act_id,l_assignment_id,l_tax_year_start_date,l_tax_year_end_date,l_Special_Indicator,l_Amount_Special_Indicator);
			PAY_NL_TAXOFFICE_ARCHIVE.get_User_Balances(l_assgt_act_id,l_business_group_id,l_User_Bal_String);



			if g_debug then
				hr_utility.set_location('l_wage'||l_wage,425);
				hr_utility.set_location('l_deduct_wage_tax_si_cont'||l_deduct_wage_tax_si_cont,425);
				hr_utility.set_location('l_Labour_Discount'||l_Labour_Discount,425);
				hr_utility.set_location('l_ZVW_Contribution'||l_ZVW_Contribution,425);
				hr_utility.set_location('l_ZVW_Basis'||l_ZVW_Basis,425);
				hr_utility.set_location('l_Value_Private_Use_Car'||l_Value_Private_Use_Car,425);
				hr_utility.set_location('l_LSS_Saved_Amount'||l_LSS_Saved_Amount,425);
				hr_utility.set_location('l_Employer_Part_Child_Care'||l_Employer_Part_Child_Care,425);
				hr_utility.set_location('l_Allowance_On_Disability'||l_Allowance_On_Disability,425);
				hr_utility.set_location('l_Applied_LCLD'||l_Applied_LCLD,425);
				hr_utility.set_location('l_Special_Indicator'||l_Special_Indicator,425);
				hr_utility.set_location('l_Amount_Special_Indicator'||l_Amount_Special_Indicator,425);
			end if;

			hr_utility.set_location('l_wage'||l_wage,425);
			hr_utility.set_location('l_deduct_wage_tax_si_cont'||l_deduct_wage_tax_si_cont,425);
			hr_utility.set_location('l_Labour_Discount'||l_Labour_Discount,425);
			hr_utility.set_location('l_ZVW_Contribution'||l_ZVW_Contribution,425);
			hr_utility.set_location('l_ZVW_Basis'||l_ZVW_Basis,425);
			hr_utility.set_location('l_Value_Private_Use_Car'||l_Value_Private_Use_Car,425);
			hr_utility.set_location('l_LSS_Saved_Amount'||l_LSS_Saved_Amount,425);
			hr_utility.set_location('l_Employer_Part_Child_Care'||l_Employer_Part_Child_Care,425);
			hr_utility.set_location('l_Allowance_On_Disability'||l_Allowance_On_Disability,425);
			hr_utility.set_location('l_Applied_LCLD'||l_Applied_LCLD,425);
			hr_utility.set_location('l_Special_Indicator'||l_Special_Indicator,425);
			hr_utility.set_location('l_Amount_Special_Indicator'||l_Amount_Special_Indicator,425);


			/* fetching the Wage Tax Discount for the given assignment in the tax year
			it basically returns 0 or 1 depending on the Tax Reduction Flag set to None
			or any other value, concatenated with the period start date, first changed value
			of Tax Reduction Flag, first change start date, second changed value of
			Tax Reduction Flag, second change start date.
			If the changes are more than three, then the latest 3 changed values and
			respective dates are picked up.*/


			l_Wage_Tax_Discount:=PAY_NL_TAXOFFICE_ARCHIVE.get_wage_tax_discount(l_assignment_id,l_tax_year_start_date,l_tax_year_end_date);


			/* fetching the Wage Tax Table Code for the given assignment in the tax year
			This is basically the tax code.It is obtained from the run results for the
			input value Tax Code on the element Standard Tax Deduction.
			If there is a change during the year, then the code that has been set
			for the longest time during the year is shown.*/

			l_Wage_Tax_Table_Code:=PAY_NL_TAXOFFICE_ARCHIVE.get_wage_tax_table_code(l_assignment_id,l_tax_year_start_date,l_tax_year_end_date);

			if g_debug then
				hr_utility.set_location('l_Wage_Tax_Discount'||l_Wage_Tax_Discount,450);
				hr_utility.set_location('l_Wage_Tax_Table_Code'||l_Wage_Tax_Table_Code,450);
			end if;


			/* fetching the income code */

			l_income_code:=get_income_code(l_assignment_id,l_tax_year_start_date,l_tax_year_end_date);

			if g_debug then
				hr_utility.set_location('l_income_code'||l_income_code,450);
			end if;


			/* fetching the SI Insured Flag */

			l_SI_Insured_Flag:=get_si_insured_flag(l_assignment_id,l_tax_year_start_date,l_tax_year_end_date);

			if g_debug then
				hr_utility.set_location('l_SI_Insured_Flag'||l_SI_Insured_Flag,500);
			end if;

			/*fetching the NET_EXPENSE_ALLOWANCE */
			l_NET_EXPENSE_ALLOWANCE := get_NET_EXPENSE_ALLOWANCE(l_assgt_act_id);


			/* fetching the Private Car Use Flag */

			l_Private_Use_Car:=get_PRIVATE_USE_CAR(l_assgt_act_id);


			if g_debug then
				hr_utility.set_location('l_Private_Use_Car'||l_Private_Use_Car,500);
			end if;

 			/* Checking the mandatory fields */
 			Mandatory_Check('PAY_NL_ASG_REQUIRED_FIELD','INCOME_CODE',l_Income_Code);

			if g_error_count=0 then

				/* Creating the archive assignment action */

				SELECT pay_assignment_actions_s.NEXTVAL
				INTO   l_asg_act_id
				FROM   dual;
				--
				-- Create the archive assignment action
				--
				if g_debug then
					hr_utility.set_location('Archive Assignment Action Id'||l_asg_act_id,450);
					hr_utility.set_location('Archive Assignment Id'||l_Assignment_ID,450);
					hr_utility.set_location('Archive Payroll Action Id'||p_payroll_action_id,450);
					hr_utility.set_location('creating the archive asst. action',450);
					hr_utility.set_location('Archive Assignment Action Id'||l_asg_act_id,475);
				end if;




				/*Creating the Assignment Action for the Assignment
				and Locking the Latest Payroll Run Assignment Action for the Assignment
				*/

				hr_nonrun_asact.insact(l_asg_act_id,l_Assignment_ID, p_payroll_action_id,p_chunk,NULL);
				hr_nonrun_asact.insint(l_asg_act_id,l_assgt_act_id);

				if g_debug then
					hr_utility.set_location('Archive Assignment Action Id'||l_asg_act_id,475);
					hr_utility.set_location('Action Information row about to create',450);
					hr_utility.set_location('Coming out of loop',450);
					hr_utility.set_location('Archive Assignment Action Id'||l_asg_act_id,450);
					hr_utility.set_location('Archive Assignment Id'||l_Assignment_ID,450);
					hr_utility.set_location('Archive Payroll Action Id'||p_payroll_action_id,450);
					hr_utility.set_location('l_ovn'||l_ovn,450);
					hr_utility.set_location('l_ATS_Process_Date'||l_ATS_Process_Date,450);
					hr_utility.set_location('l_employer_id'||l_employer_id,450);
					hr_utility.set_location('l_wage'||l_wage,450);
					hr_utility.set_location('l_deduct_wage_tax_si_cont'||l_deduct_wage_tax_si_cont,450);
					hr_utility.set_location('l_asg_start_date'||l_asg_start_date,450);
					hr_utility.set_location('l_asg_end_date'||l_asg_end_date,450);
					hr_utility.set_location('l_Labour_Discount'||l_Labour_Discount,450);
					hr_utility.set_location('l_Wage_Tax_Discount'||l_Wage_Tax_Discount,450);
					hr_utility.set_location('l_Wage_Tax_Table_Code'||l_Wage_Tax_Table_Code,450);
					hr_utility.set_location('l_Income_Code'||l_Income_Code,450);
					hr_utility.set_location('l_Special_Indicator'||l_Special_Indicator,450);
					hr_utility.set_location('l_Amount_Special_Indicator'||l_Amount_Special_Indicator,450);
					hr_utility.set_location('l_ZVW_Contribution'||l_ZVW_Contribution,450);
					hr_utility.set_location('l_SI_Insured_Flag'||l_SI_Insured_Flag,450);
					hr_utility.set_location('l_Net_Expense_Allowance'||l_Net_Expense_Allowance,450);
					hr_utility.set_location('l_Private_Use_Car'||l_Private_Use_Car,450);
					hr_utility.set_location('l_taxable_income'||l_taxable_income,450);
				end if;

				BEGIN

					SELECT	1 INTO l_active_asg_flag
					FROM	per_all_assignments_f asg, per_assignment_status_types past
					WHERE	asg.assignment_id = l_assignment_id
					and	past.assignment_status_type_id = asg.assignment_status_type_id
					and	past.per_system_status = 'ACTIVE_ASSIGN'
					and	asg.effective_start_date <= l_Tax_Year_End_Date
					and	nvl(asg.effective_end_date, l_Tax_Year_End_Date) >= l_Tax_Year_Start_Date;


				EXCEPTION

					WHEN TOO_MANY_ROWS
						THEN l_active_asg_flag := 1;

					WHEN NO_DATA_FOUND
						THEN l_active_asg_flag := 0;

					WHEN OTHERS
						THEN null;

				END;

				IF l_active_asg_flag = 1 OR
				(l_active_asg_flag = 0 AND
					(l_wage <> 0 OR l_taxable_income <> 0 OR l_deduct_wage_tax_si_cont <> 0
					OR l_Labour_Discount <> 0 OR l_ZVW_Basis <> 0 OR l_ZVW_Contribution <> 0
					OR l_Net_Expense_Allowance <> 0 OR l_Private_Use_Car <> 0
					OR l_Value_Private_Use_Car <> 0 OR l_LSS_Saved_Amount <> 0 OR l_Employer_Part_Child_Care <> 0
					OR l_Allowance_On_Disability <> 0 OR l_Applied_LCLD <> 0)) THEN

					pay_action_information_api.create_action_information (
						 p_action_information_id        => l_action_info_id
						,p_action_context_id            => l_asg_act_id
						,p_action_context_type          => 'AAP'
						,p_object_version_number        => l_ovn
						,p_effective_date               => l_ATS_Process_Date
						,p_source_id                    => NULL
						,p_source_text                  => NULL
						,p_action_information_category  => 'NL ATS EMPLOYEE DETAILS'
						,p_action_information1          =>  fnd_number.number_to_canonical(l_employer_id)
						,p_action_information2          =>  fnd_number.number_to_canonical(l_person_id)
						,p_action_information3          =>  fnd_number.number_to_canonical(l_assignment_id)
						,p_action_information4          =>  l_wage
						,p_action_information5          =>  l_deduct_wage_tax_si_cont
						,p_action_information6          =>  l_asg_start_date
						,p_action_information7          =>  l_asg_end_date
						,p_action_information8          =>  l_Labour_Discount
						,p_action_information9          =>  l_Wage_Tax_Discount
						,p_action_information10         =>  l_Wage_Tax_Table_Code
						,p_action_information11         =>  l_Income_Code
						,p_action_information12         =>  l_Special_Indicator
						,p_action_information13         =>  l_Amount_Special_Indicator
						,p_action_information14         =>  l_SI_Insured_Flag
						,p_action_information15         =>  fnd_number.number_to_canonical(l_ZVW_Contribution)
						,p_action_information16         =>  fnd_number.number_to_canonical(l_Net_Expense_Allowance)
						,p_action_information17         =>  fnd_number.number_to_canonical(l_Private_Use_Car)
						,p_action_information18         =>  l_taxable_income
						,p_action_information19		=>  fnd_number.number_to_canonical(l_ZVW_Basis)
						,p_action_information20		=>  fnd_number.number_to_canonical(l_Value_Private_Use_Car)
						,p_action_information21		=>  fnd_number.number_to_canonical(l_LSS_Saved_Amount)
						,p_action_information22		=>  fnd_number.number_to_canonical(l_Employer_Part_Child_Care)
						,p_action_information23		=>  fnd_number.number_to_canonical(l_Allowance_On_Disability)
						,p_action_information24		=>  fnd_number.number_to_canonical(l_Applied_LCLD)
						,p_action_information25		=>  l_User_Bal_String);

				END IF;
			end if;

		end if;

		    hr_utility.set_location('l_action_info_id'||l_action_info_id,450);
		    hr_utility.set_location('l_ovn'||l_ovn,450);

		if g_debug then
		    hr_utility.set_location('l_action_info_id'||l_action_info_id,450);
		    hr_utility.set_location('l_ovn'||l_ovn,450);
		end if;

	END LOOP;

	hr_utility.set_location('Exiting ASSIGNMENT_ACTION_CODE',650);

END ASSIGNMENT_ACTION_CODE;



/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_INIT                                                  |
|Type		    : Procedure							|
|Description    : Initialization Code for Archiver                              |
-------------------------------------------------------------------------------*/
Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER) IS

BEGIN
	if g_debug then
		hr_utility.set_location('Entering Archive Init',600);
		hr_utility.set_location('Leaving Archive Init',700);
	end if;

END ARCHIVE_INIT;



/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_CODE                                            	|
|Type		: Procedure							|
|Description    : Archival code for archiver					|
-------------------------------------------------------------------------------*/


Procedure ARCHIVE_CODE (p_assignment_action_id  IN NUMBER
			,p_effective_date       IN DATE) IS


BEGIN
	if g_debug then

		hr_utility.set_location('Entering Archive Code',700);
		hr_utility.set_location('Leaving Archive Code',700);
	end if;

END ARCHIVE_CODE;

/*-----------------------------------------------------------------------------
|Name       : get_max_assgt_act_id                                             |
|Type       : Function							       |
|Description: Function which returns the max. assignment_action_id for a given |
|	      assignment_id between a given start and end date		       |
-------------------------------------------------------------------------------*/

function get_max_assgt_act_id(p_assignment_id number
                              ,p_date_from date
                              ,p_date_to date)RETURN number IS

	CURSOR csr_max_assgt_act_id IS
	SELECT MAX(assignment_action_id)
	from pay_assignment_actions paa
	    ,pay_payroll_actions ppa
	where paa.payroll_action_id =ppa.payroll_action_id
	and paa.assignment_id = p_assignment_id
	and ppa.date_earned between p_date_from and p_date_to
	and ppa.action_type in ('R','B','Q','I','V');

	l_max_assgt_act_id number;

BEGIN

	if g_debug then
		hr_utility.set_location('Entering get_max_assgt_act_id',700);
	end if;

	OPEN csr_max_assgt_act_id;
	FETCH csr_max_assgt_act_id into l_max_assgt_act_id;
	CLOSE csr_max_assgt_act_id;

	if g_debug then
		hr_utility.set_location('l_max_assgt_act_id'||l_max_assgt_act_id,450);
		hr_utility.set_location('Exiting get_max_assgt_act_id',700);
	end if;

	return l_max_assgt_act_id;

END get_max_assgt_act_id;


/*-----------------------------------------------------------------------------
|Name       : get_context_id                                                   |
|Type       : Function							       |
|Description: Function which returns the context id for a given context neme   |
-------------------------------------------------------------------------------*/

function get_context_id(p_context_name VARCHAR2)return number IS

	CURSOR csr_get_context_id IS
	SELECT context_id
	FROM   ff_contexts              ff
	WHERE  ff.context_name          = p_context_name;

	l_context_id number;

BEGIN

	if g_debug then
		hr_utility.set_location('Entering get_context_id',700);
	end if;

	OPEN csr_get_context_id;
	FETCH  csr_get_context_id into l_context_id;
	CLOSE csr_get_context_id;

	if g_debug then
		hr_utility.set_location('l_context_id'||l_context_id,700);
		hr_utility.set_location('Exiting get_context_id',700);
	end if;

	return l_context_id;


END get_context_id;



/*-----------------------------------------------------------------------------
|Name       : get_wage		                                               |
|Type       : Function							       |
|Description: Function which returns the wage for a given assignment action    |
-------------------------------------------------------------------------------*/

function get_wage(p_assgt_act_id number)RETURN number IS
	l_context_id number;
	l_sum_of_balances number;
	l_balance_value number;
	l_defined_balance_id number;
	l_pre_tax_ded number;
	l_retro_pre_tax_ded number;
	l_wage number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_wage',800);
	end if;

	l_sum_of_balances:=0;
	l_pre_tax_ded:=0;
	l_retro_pre_tax_ded:=0;
	l_context_id:=get_context_id('SOURCE_TEXT');


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('SI_INCOME_STANDARD_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('SI_INCOME_STANDARD_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('SI_INCOME_SPECIAL_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('SI_INCOME_SPECIAL_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('WAGE_IN_MONEY_STANDARD_TAX_ONLY_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('WAGE_IN_MONEY_STANDARD_TAX_ONLY_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('WAGE_IN_MONEY_SPECIAL_TAX_ONLY_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('WAGE_IN_MONEY_SPECIAL_TAX_ONLY_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('WAGE_IN_KIND_STANDARD_TAX_ONLY_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('WAGE_IN_KIND_STANDARD_TAX_ONLY_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('WAGE_IN_KIND_SPECIAL_TAX_ONLY_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;


	if g_debug then
		hr_utility.set_location('WAGE_IN_KIND_SPECIAL_TAX_ONLY_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_SI_INCOME_STANDARD_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_SI_INCOME_STANDARD_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_SI_INCOME_SPECIAL_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_SI_INCOME_SPECIAL_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_WAGE_IN_MONEY_STANDARD_TAX_ONLY_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_WAGE_IN_MONEY_STANDARD_TAX_ONLY_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_WAGE_IN_MONEY_SPECIAL_TAX_ONLY_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_WAGE_IN_MONEY_SPECIAL_TAX_ONLY_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_WAGE_IN_KIND_STANDARD_TAX_ONLY_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_WAGE_IN_KIND_STANDARD_TAX_ONLY_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_WAGE_IN_KIND_SPECIAL_TAX_ONLY_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_WAGE_IN_KIND_SPECIAL_TAX_ONLY_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_ZVW_CONTRIBUTION_STANDARD_TAX_ASG_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZVW',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('EMPLOYER_ZVW_CONTRIBUTION_STANDARD_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_ZVW_CONTRIBUTION_SPECIAL_TAX_ASG_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZVW',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('EMPLOYER_ZVW_CONTRIBUTION_SPECIAL_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_ZVW_CONTRIBUTION_STANDARD_TAX_ASG_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZVW',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_ZVW_CONTRIBUTION_STANDARD_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_ZVW_CONTRIBUTION_SPECIAL_TAX_ASG_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZVW',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_ZVW_CONTRIBUTION_SPECIAL_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('EMPLOYER_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'WEWE',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'WEWA',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'WEWE',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'WEWA',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'WEWE',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'WEWA',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;



	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'WEWE',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'WEWA',null,null);
	END IF;
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('PRE_TAX_ONLY_DEDUCTIONS_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;

	if g_debug then
		hr_utility.set_location('PRE_TAX_ONLY_DEDUCTIONS_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_PRE_TAX_ONLY_DEDUCTIONS_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_PRE_TAX_ONLY_DEDUCTIONS_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('STANDARD_TAX_REDUCTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;

	if g_debug then
		hr_utility.set_location('STANDARD_TAX_REDUCTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('SPECIAL_TAX_REDUCTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;

	if g_debug then
		hr_utility.set_location('SPECIAL_TAX_REDUCTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_STANDARD_TAX_REDUCTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_STANDARD_TAX_REDUCTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_SPECIAL_TAX_REDUCTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances - l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_SPECIAL_TAX_REDUCTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);

		hr_utility.set_location('Exiting get_wage',950);
	end if;


	l_wage:=l_sum_of_balances;


	return l_wage;

END get_wage;


/*-----------------------------------------------------------------------------
|Name       : get_taxable_income                                               |
|Type       : Function							       |
|Description: Function which returns the taxable income for a given assignment |
|             action                                                           |
-------------------------------------------------------------------------------*/

function get_taxable_income(p_assgt_act_id number)RETURN number

 IS
	l_sum_of_balances number;
	l_balance_value number;
	l_defined_balance_id number;
	l_taxable_income number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_taxable_income',800);
	end if;

	l_sum_of_balances:=0;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('STANDARD_TAXABLE_INCOME_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('STANDARD_TAXABLE_INCOME_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('SPECIAL_TAXABLE_INCOME_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('SPECIAL_TAXABLE_INCOME_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_STANDARD_TAXABLE_INCOME_CURRENT_QUARTER_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_STANDARD_TAXABLE_INCOME_CURRENT_QUARTER_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_STANDARD_TAXABLE_INCOME_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_STANDARD_TAXABLE_INCOME_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_SPECIAL_TAXABLE_INCOME_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_SPECIAL_TAXABLE_INCOME_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;


	l_taxable_income:=l_sum_of_balances;


	return l_taxable_income;

END get_taxable_income;


/*-----------------------------------------------------------------------------
|Name       : get_deduct_wage_tax_si_cont                                      |
|Type       : Function							       |
|Description: Function which returns the deduct_wage_tax value                 |
|	      for a given assignment action    				       |
-------------------------------------------------------------------------------*/

function get_deduct_wage_tax_si_cont(p_assgt_act_id number) return number IS

	l_wt_and_ni_cont number;
	l_balance_value number;
	l_defined_balance_id number;
	l_deduct_wage_tax_si_cont number;

BEGIN

	if g_debug then
		hr_utility.set_location('Entering get_deduct_wage_tax_si_cont',1000);
	end if;

	l_wt_and_ni_cont:=0;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('STANDARD_TAX_DEDUCTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_wt_and_ni_cont:= l_wt_and_ni_cont + l_balance_value;


	if g_debug then
		hr_utility.set_location('STANDARD_TAX_DEDUCTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_wt_and_ni_cont'||l_wt_and_ni_cont,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('SPECIAL_TAX_DEDUCTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_wt_and_ni_cont:= l_wt_and_ni_cont + l_balance_value;


	if g_debug then
		hr_utility.set_location('SPECIAL_TAX_DEDUCTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_wt_and_ni_cont'||l_wt_and_ni_cont,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_STANDARD_TAX_DEDUCTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_wt_and_ni_cont:= l_wt_and_ni_cont + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_STANDARD_TAX_DEDUCTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_wt_and_ni_cont'||l_wt_and_ni_cont,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_SPECIAL_TAX_DEDUCTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_wt_and_ni_cont:= l_wt_and_ni_cont + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_SPECIAL_TAX_DEDUCTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_wt_and_ni_cont'||l_wt_and_ni_cont,425);
	END IF;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_STANDARD_TAX_DEDUCTION_CURRENT_QUARTER_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_wt_and_ni_cont:= l_wt_and_ni_cont + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_STANDARD_TAX_DEDUCTION_CURRENT_QUARTER_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_wt_and_ni_cont'||l_wt_and_ni_cont,425);
	END IF;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('STANDARD_TAX_CORRECTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_wt_and_ni_cont:= l_wt_and_ni_cont + l_balance_value;


	if g_debug then
		hr_utility.set_location('STANDARD_TAX_CORRECTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_wt_and_ni_cont'||l_wt_and_ni_cont,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('SPECIAL_TAX_CORRECTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_wt_and_ni_cont:= l_wt_and_ni_cont + l_balance_value;


	if g_debug then
		hr_utility.set_location('SPECIAL_TAX_CORRECTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_wt_and_ni_cont'||l_wt_and_ni_cont,425);
	end if;


	l_deduct_wage_tax_si_cont:=ceil(l_wt_and_ni_cont);


	if g_debug then
		hr_utility.set_location('l_wt_and_ni_cont'||l_wt_and_ni_cont,425);
		hr_utility.set_location('Exiting get_deduct_wage_tax_si_cont',1050);
	end if;
	return l_deduct_wage_tax_si_cont;

end get_deduct_wage_tax_si_cont;


/*-----------------------------------------------------------------------------
|Name       : get_labour_discount                                              |
|Type       : Function							       |
|Description: Function which returns the labour discount value                 |
|	      for a given assignment action    				       |
-------------------------------------------------------------------------------*/

function get_labour_discount(p_assgt_act_id number) return number IS

	l_labour_discount number;
	l_balance_value number;
	l_defined_balance_id number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_labour_discount',1050);
	end if;

	l_labour_discount:=0;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('LABOUR_TAX_REDUCTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_labour_discount:= l_labour_discount + l_balance_value;


	if g_debug then
		hr_utility.set_location('LABOUR_TAX_REDUCTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_labour_discount'||l_labour_discount,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_LABOUR_TAX_REDUCTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_labour_discount:= l_labour_discount + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_LABOUR_TAX_REDUCTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_labour_discount'||l_labour_discount,425);
	end if;

	l_labour_discount:= ceil(l_labour_discount);


	if g_debug then
		hr_utility.set_location('l_labour_discount'||l_labour_discount,425);
		hr_utility.set_location('Exiting get_labour_discount',1050);
	end if;

	return l_labour_discount;

end get_labour_discount;


/*-----------------------------------------------------------------------------
|Name       : get_ZFW_PHI_contributions				               |
|Type       : Function							       |
|Description: Function which returns the ZFW PHI contributions	 	       |
-------------------------------------------------------------------------------*/

function get_ZFW_PHI_contributions(p_assgt_act_id number) return number IS

	l_ZFW_PHI_contribution number;
	l_context_id number;
	l_balance_value number;
	l_defined_balance_id number;

BEGIN

	hr_utility.set_location('Entering get_ZFW_PHI_Contribution',1050);

	l_ZFW_PHI_contribution:=0;

	l_context_id:=get_context_id('SOURCE_TEXT');



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYEE_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYER_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYEE_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_PRIVATE_HEALTH_CONTRIBUTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_IZA_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYEE_IZA_CONTRIBUTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_IZA_CONTRIBUTION_STANDARD_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYER_IZA_CONTRIBUTION_STANDARD_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_IZA_CONTRIBUTION_SPECIAL_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYER_IZA_CONTRIBUTION_SPECIAL_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_IZA_CONTRIBUTION_NON_TAXABLE_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYER_IZA_CONTRIBUTION_NON_TAXABLE_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_IZA_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYEE_IZA_CONTRIBUTION_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_IZA_CONTRIBUTION_STANDARD_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_IZA_CONTRIBUTION_STANDARD_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_IZA_CONTRIBUTION_SPECIAL_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_IZA_CONTRIBUTION_SPECIAL_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_IZA_CONTRIBUTION_NON_TAXABLE_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_IZA_CONTRIBUTION_NON_TAXABLE_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('NET_EMPLOYEE_SI_CONTRIBUTION_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('NET_EMPLOYEE_SI_CONTRIBUTION_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;

	if g_debug then
		hr_utility.set_location('EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_SI_CONTRIBUTION_NON_TAXABLE_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYEE_SI_CONTRIBUTION_NON_TAXABLE_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_SI_CONTRIBUTION_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYER_SI_CONTRIBUTION_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYER_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYER_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_SI_CONTRIBUTION_NON_TAXABLE_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;

	if g_debug then
		hr_utility.set_location('EMPLOYER_SI_CONTRIBUTION_NON_TAXABLE_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_NET_EMPLOYEE_SI_CONTRIBUTION_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_NET_EMPLOYEE_SI_CONTRIBUTION_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;




	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_SI_CONTRIBUTION_NON_TAXABLE_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYEE_SI_CONTRIBUTION_NON_TAXABLE_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_SI_CONTRIBUTION_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_SI_CONTRIBUTION_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_SI_CONTRIBUTION_NON_TAXABLE_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZFW',null,null);
	END IF;
	l_ZFW_PHI_Contribution:=l_ZFW_PHI_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_SI_CONTRIBUTION_NON_TAXABLE_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZFW_PHI_Contribution'||l_ZFW_PHI_Contribution,425);
	end if;


	l_ZFW_PHI_Contribution:=round(l_ZFW_PHI_Contribution,2);

	return l_ZFW_PHI_Contribution;


END get_ZFW_PHI_contributions;


/*-----------------------------------------------------------------------------
|Name       : get_special_indicators                                           |
|Type       : Procedure							       |
|Description: Procedure which returns the special indicators string            |
-------------------------------------------------------------------------------*/

Procedure get_special_indicators(p_assgt_act_id in number
				,p_assignment_id in number
				,p_tax_year_start_date in date
				,p_tax_year_end_date in date
                                ,p_special_indicator out nocopy varchar2
                                ,p_Amount_Special_indicator out nocopy varchar2) IS

	cursor csr_tax_year_assgn_act_id is
	select paa.assignment_action_id,ppa.date_earned
	from pay_assignment_actions paa
	    ,pay_payroll_actions ppa
	where
	paa.assignment_id = p_assignment_id and
	ppa.payroll_action_id = paa.payroll_action_id and
	ppa.date_earned between p_tax_year_start_date and p_tax_year_end_date
	and   ppa.action_type in ('R','Q')
	and   ppa.action_status = 'C';

	cursor csr_run_result_id(lp_assignment_action_id number, lp_element_type_id number) is
	select prr.run_result_id
	from pay_run_results prr
	where
	prr.element_type_id=lp_element_type_id and
	prr.assignment_action_id=lp_assignment_action_id;

	l_balance_value number;
	l_defined_balance_id number;
	l_spl_indicator1 varchar2(2);
	l_spl_indicator1_amount varchar2(9);
	l_spl_indicator2 varchar2(2);
	l_spl_indicator2_amount varchar2(9);
	l_spl_indicator3 varchar2(2);
	l_spl_indicator3_amount varchar2(9);
	l_spl_indicator4 varchar2(2);
	l_spl_indicator4_amount varchar2(9);
	l_spl_indicator5 varchar2(2);
	l_spl_indicator5_amount varchar2(9);
	l_spl_indicator6 varchar2(2);
	l_spl_indicator6_amount varchar2(9);
	l_comp_car varchar2(1);
	l_element_type_id number;
	l_input_value_id number;
	l_run_result_id number;
	l_run_result_value varchar2(255);
	l_eff_date date;

BEGIN

	--if g_debug then
		hr_utility.set_location('Entering get_special_indicators',1200);
	--end if;

	/*for csr_tax_year_assgn_act_id_rec in csr_tax_year_assgn_act_id
	loop
		l_element_type_id:=pay_nl_general.get_element_type_id('Standard Tax Deduction',csr_tax_year_assgn_act_id_rec.date_earned);
		l_input_value_id:=pay_nl_general.get_input_value_id(l_element_type_id,'Special Indicators',csr_tax_year_assgn_act_id_rec.date_earned);

		OPEN csr_run_result_id(csr_tax_year_assgn_act_id_rec.assignment_action_id,l_element_type_id);
		FETCH csr_run_result_id into l_run_result_id;
		CLOSE csr_run_result_id;

		l_run_result_value:=pay_nl_general.get_run_result_value(csr_tax_year_assgn_act_id_rec.assignment_action_id,l_element_type_id,l_input_value_id,l_run_result_id,'C');

			IF substr (l_run_result_value, 1, 2) = '01'  OR
			   substr (l_run_result_value, 3, 2) = '01'  OR
			   substr (l_run_result_value, 5, 2) = '01'  OR
			   substr (l_run_result_value, 7, 2) = '01'  OR
			   substr (l_run_result_value, 9, 2) = '01'  OR
			   substr (l_run_result_value, 11, 2) = '01' OR
			   substr (l_run_result_value, 13, 2) = '01' OR
			   substr (l_run_result_value, 15, 2) = '01' OR
			   substr (l_run_result_value, 17, 2) = '01' OR
			   substr (l_run_result_value, 19, 2) = '01' OR
			   substr (l_run_result_value, 21, 2) = '01' OR
			   substr (l_run_result_value, 23, 2) = '01' OR
			   substr (l_run_result_value, 25, 2) = '01' THEN

			   l_comp_car_spl_indicator := 'Y';
			   exit;
			ELSE
			   l_comp_car_spl_indicator := 'N';
			END IF;
	end loop;*/

	BEGIN

		select	ppa.date_earned
		into	l_eff_date
		from	pay_payroll_actions ppa,
			pay_assignment_actions paa
		where	paa.assignment_action_id = p_assgt_act_id
		and	ppa.payroll_action_id = paa.payroll_action_id;

	EXCEPTION

		WHEN NO_DATA_FOUND
			THEN null;

		WHEN OTHERS
			THEN null;

	END;
	--if g_debug then
		hr_utility.set_location('l_eff_date - '||l_eff_date,427);
	--end if;

	BEGIN

		SELECT peev.screen_entry_value
		INTO   l_comp_car
		FROM   pay_element_types_f pet
		      ,pay_input_values_f piv
		      ,pay_element_entries_f peef
		      ,pay_element_entry_values_f peev
		WHERE  pet.element_name = 'Company Car Private Usage'
		AND    pet.element_type_id = piv.element_type_id
		AND    piv.name = 'Code Usage'
		AND    pet.legislation_code  = 'NL'
		AND    piv.legislation_code  = 'NL'
		AND    peef.assignment_id    = p_assignment_id
		AND    peef.element_entry_id = peev.element_entry_id
		AND    peef.element_type_id  = pet.element_type_id
		AND    peev.input_value_id   = piv.input_value_id
		AND    l_eff_date            BETWEEN piv.effective_start_date
		                                 AND piv.effective_end_date
		AND    l_eff_date            BETWEEN pet.effective_start_date
		                                 AND pet.effective_end_date
		AND    l_eff_date            BETWEEN peev.effective_start_date
		                                 AND peev.effective_end_date
		AND    l_eff_date            BETWEEN peef.effective_start_date
		                                 AND peef.effective_end_date;

	EXCEPTION

		WHEN NO_DATA_FOUND
			THEN l_comp_car:=' ';

		WHEN OTHERS
			THEN l_comp_car:=' ';

	END;
	--if g_debug then
		hr_utility.set_location('l_comp_car - '||l_comp_car,427);
	--end if;

	g_debug:=true;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('TAX_TRAVEL_ALLOWANCE_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	if l_balance_value <> 0 then
	l_spl_indicator1 := '04';
	l_spl_indicator1_amount := l_balance_value;
	else
	l_spl_indicator1 := '00';
	l_spl_indicator1_amount := '000000';
	end if;

	if g_debug then
		hr_utility.set_location('TAX_TRAVEL_ALLOWANCE_ASG_YTD',427);
		hr_utility.set_location('l_spl_indicator1'||l_spl_indicator1,427);
		hr_utility.set_location('l_spl_indicator1_amount'||l_spl_indicator1_amount,427);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('TAX_SEA_DAYS_DISCOUNT_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	if l_balance_value <> 0 then
	l_spl_indicator2 := '17';
	l_spl_indicator2_amount := l_balance_value;
	else
	l_spl_indicator2 := '00';
	l_spl_indicator2_amount := '000000';
	end if;

	if g_debug then
		hr_utility.set_location('l_spl_indicator2'||l_spl_indicator2,427);
		hr_utility.set_location('l_spl_indicator2_amount'||l_spl_indicator2_amount,427);
		hr_utility.set_location('TAX_SEA_DAYS_DISCOUNT_ASG_YTD',427);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('TAX_ABW_ALLOWANCE_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	if l_balance_value <> 0 then
	l_spl_indicator3 := '25';
	l_spl_indicator3_amount := l_balance_value;
	else
	l_spl_indicator3 := '00';
	l_spl_indicator3_amount := '000000';
	end if;


	if g_debug then
		hr_utility.set_location('TAX_ABW_ALLOWANCE_ASG_YTD',427);
		hr_utility.set_location('l_spl_indicator3'||l_spl_indicator3,427);
		hr_utility.set_location('l_spl_indicator3_amount'||l_spl_indicator3_amount,427);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('TAX_ABW_ALLOWANCE_STOPPAGE_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	if l_balance_value <> 0 then
	l_spl_indicator4 := '26';
	l_spl_indicator4_amount := l_balance_value;
	else
	l_spl_indicator4 := '00';
	l_spl_indicator4_amount := '000000';
	end if;


	if g_debug then
		hr_utility.set_location('TAX_ABW_ALLOWANCE_STOPPAGE_ASG_YTD',427);
		hr_utility.set_location('l_spl_indicator4'||l_spl_indicator4,427);
		hr_utility.set_location('l_spl_indicator4_amount'||l_spl_indicator4_amount,427);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('TAX_WAO_ALLOWANCE_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	if l_balance_value <> 0 then
	l_spl_indicator5 := '61';
	l_spl_indicator5_amount := l_balance_value;
	else
	l_spl_indicator5 := '00';
	l_spl_indicator5_amount := '000000';
	end if;

	if g_debug then
		hr_utility.set_location('TAX_WAO_ALLOWANCE_ASG_YTD',427);
		hr_utility.set_location('l_spl_indicator5'||l_spl_indicator5,427);
		hr_utility.set_location('l_spl_indicator5_amount'||l_spl_indicator5_amount,427);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('TAX_TOTAL_ZFW_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	if l_balance_value <> 0 then
	l_spl_indicator6 := '64';
	l_spl_indicator6_amount := l_balance_value;
	else
	l_spl_indicator6 := '00';
	l_spl_indicator6_amount := '000000';
	end if;

	if g_debug then
		hr_utility.set_location('TAX_TOTAL_ZFW_CONTRIBUTION_ASG_YTD',427);
		hr_utility.set_location('l_spl_indicator6'||l_spl_indicator6,427);
		hr_utility.set_location('l_spl_indicator6_amount'||l_spl_indicator6_amount,427);
	end if;


	p_special_indicator:=l_spl_indicator1||l_spl_indicator2||l_spl_indicator3||l_spl_indicator4||l_spl_indicator5||l_spl_indicator6 || l_comp_car;

	if g_debug then
		hr_utility.set_location('p_special_indicator'||p_special_indicator,427);
	end if;

	l_spl_indicator1_amount:=FLOOR(l_spl_indicator1_amount);
	if l_spl_indicator1_amount < 0 then
	l_spl_indicator1_amount:='-'||lpad(l_spl_indicator1_amount*(-1),5,0);
	else
	l_spl_indicator1_amount:=lpad(l_spl_indicator1_amount,6,0);
	end if;

	if g_debug then
		hr_utility.set_location('l_spl_indicator1_amount'||l_spl_indicator1_amount,427);
	end if;

	l_spl_indicator2_amount:=FLOOR(l_spl_indicator2_amount);
	if l_spl_indicator2_amount < 0 then
	l_spl_indicator2_amount:='-'||lpad(l_spl_indicator2_amount*(-1),5,0);
	else
	l_spl_indicator2_amount:=lpad(l_spl_indicator2_amount,6,0);
	end if;

	if g_debug then
		hr_utility.set_location('l_spl_indicator2_amount'||l_spl_indicator2_amount,427);
	end if;

	l_spl_indicator3_amount:=FLOOR(l_spl_indicator3_amount);
	if l_spl_indicator3_amount < 0 then
	l_spl_indicator3_amount:='-'||lpad(l_spl_indicator3_amount*(-1),5,0);
	else
	l_spl_indicator3_amount:=lpad(l_spl_indicator3_amount,6,0);
	end if;

	if g_debug then
		hr_utility.set_location('l_spl_indicator3_amount'||l_spl_indicator3_amount,427);
	end if;

	l_spl_indicator4_amount:=FLOOR(l_spl_indicator4_amount);
	if l_spl_indicator4_amount < 0 then
	l_spl_indicator4_amount:='-'||lpad(l_spl_indicator4_amount*(-1),5,0);
	else
	l_spl_indicator4_amount:=lpad(l_spl_indicator4_amount,6,0);
	end if;

	if g_debug then
		hr_utility.set_location('l_spl_indicator4_amount'||l_spl_indicator4_amount,427);
	end if;

	l_spl_indicator5_amount:=FLOOR(l_spl_indicator5_amount);
	if l_spl_indicator5_amount < 0 then
	l_spl_indicator5_amount:='-'||lpad(l_spl_indicator5_amount*(-1),5,0);
	else
	l_spl_indicator5_amount:=lpad(l_spl_indicator5_amount,6,0);
	end if;

	if g_debug then
		hr_utility.set_location('l_spl_indicator5_amount'||l_spl_indicator5_amount,427);
	end if;

	l_spl_indicator6_amount:=FLOOR(l_spl_indicator6_amount);
	if l_spl_indicator6_amount < 0 then
	l_spl_indicator6_amount:='-'||lpad(l_spl_indicator6_amount*(-1),5,0);
	else
	l_spl_indicator6_amount:=lpad(l_spl_indicator6_amount,6,0);
	end if;

	if g_debug then
		hr_utility.set_location('l_spl_indicator6_amount'||l_spl_indicator6_amount,427);
	end if;

	p_Amount_Special_indicator := l_spl_indicator1_amount || l_spl_indicator2_amount || l_spl_indicator3_amount || l_spl_indicator4_amount || l_spl_indicator5_amount || l_spl_indicator6_amount;

	if g_debug then
		hr_utility.set_location('p_Amount_Special_indicator'||p_Amount_Special_indicator,427);
		hr_utility.set_location('Exiting get_special_indicators',1300);
	end if;
	g_debug:=false;

END get_special_indicators;

/*-----------------------------------------------------------------------------
|Name       : get_PRIVATE_USE_CAR				               |
|Type       : Function							       |
|Description: Function which returns the private use car balance value 	       |
-------------------------------------------------------------------------------*/

function get_PRIVATE_USE_CAR(p_assgt_act_id number) return number IS
	l_balance_value number;
	l_defined_balance_id number;
	l_Private_Use_Car number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_PRIVATE_USE_CAR',1300);
	end if;

	l_Private_Use_Car:=0;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('PRIVATE_USE_CAR_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_Private_Use_Car:=l_balance_value;
	hr_utility.set_location('l_Private_Use_Car'||l_Private_Use_Car,425);

	if g_debug then
		hr_utility.set_location('Exiting get_PRIVATE_USE_CAR',1300);
	end if;
	return l_Private_Use_Car;


END get_PRIVATE_USE_CAR;


/*-----------------------------------------------------------------------------
|Name       : get_NET_EXPENSE_ALLOWANCE				               |
|Type       : Function							       |
|Description: Function which returns the NET EXPENSE ALLOWANCE balance value   |
-------------------------------------------------------------------------------*/

function get_NET_EXPENSE_ALLOWANCE(p_assgt_act_id number) return number IS
	l_balance_value number;
	l_defined_balance_id number;
	l_NET_EXPENSE_ALLOWANCE number;

BEGIN

	if g_debug then
		hr_utility.set_location('Entering get_NET_EXPENSE_ALLOWANCE',1350);
	end if;

	l_NET_EXPENSE_ALLOWANCE:=0;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('NET_EXPENSE_ALLOWANCE_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_Net_Expense_Allowance:=l_balance_value;

	if g_debug then
		hr_utility.set_location('l_Net_Expense_Allowance'||l_Net_Expense_Allowance,425);
	end if;


	if g_debug then
		hr_utility.set_location('Exiting get_NET_EXPENSE_ALLOWANCE',1350);
	end if;

	return l_NET_EXPENSE_ALLOWANCE;


END get_NET_EXPENSE_ALLOWANCE;

/*-----------------------------------------------------------------------------
|Name       : get_wage_tax_discount				               |
|Type       : Function							       |
|Description: Function which returns the wage tax discount value               |
-------------------------------------------------------------------------------*/

function get_wage_tax_discount(p_assignment_id number
                              ,p_tax_year_start_date date
                              ,p_tax_year_end_date date) return varchar2 IS

	TYPE wtd_rec IS RECORD (
	    date_earned      DATE,
	    code             VARCHAR2(20) ,
	    period_start_date DATE );

	TYPE wtd_filter_rec IS RECORD (
	    date_earned      DATE,
	    code             VARCHAR2(20),
	    period_start_date DATE);

	TYPE wtd_table IS TABLE OF wtd_rec INDEX BY BINARY_INTEGER;
	TYPE wtd_filter_table IS TABLE OF wtd_filter_rec INDEX BY BINARY_INTEGER;

	l_wtd_table wtd_table;
	l_wtd_filter_table wtd_filter_table;

	CURSOR csr_wtd_code is
/*	select decode(prrv.result_value,'NL_NONE','0','1') code,ppa.date_earned,paa.assignment_action_id,ptp.start_date  --,prrv.result_value
	from
	pay_payroll_actions ppa,
	pay_assignment_actions paa,
	pay_element_types_f pet,
	pay_input_values_f piv,
	pay_run_results prr,
	pay_run_result_values prrv,
	per_time_periods ptp
	where
	pet.element_name='Standard Tax Deduction' and
	pet.element_type_id=piv.element_type_id and
	piv.name='Tax Reduction Flag' and
	ppa.date_earned between p_tax_year_start_date and p_tax_year_end_date and
	ppa.payroll_action_id=paa.payroll_action_id and
	paa.assignment_id = p_assignment_id and
	prrv.input_value_id=piv.input_value_id and
	ppa.date_earned between pet.effective_start_date and pet.effective_end_date and
	ppa.date_earned between piv.effective_start_date and piv.effective_end_date and
	paa.assignment_action_id=prr.assignment_action_id and
	prrv.run_result_id=prr.run_result_id and
	ptp.time_period_id=ppa.time_period_id
	order by date_earned,paa.assignment_action_id; */

/* 14934380*/

select  /*+ORDERED INDEX(ptp PER_TIME_PERIODS_PK) */  decode(prrv.result_value,'NL_NONE','0','1') code,ppa.date_earned,paa.assignment_action_id,ptp.start_date  --,prrv.result_value
	from
	pay_assignment_actions paa,
	pay_payroll_actions ppa,
	pay_element_types_f pet,
	pay_input_values_f piv,
	pay_run_results prr,
	pay_run_result_values prrv,
	per_time_periods ptp
	where
	pet.element_name='Standard Tax Deduction' and
	pet.element_type_id=piv.element_type_id and
	piv.name='Tax Reduction Flag' and
	ppa.date_earned between p_tax_year_start_date and p_tax_year_end_date and
	ppa.payroll_action_id=paa.payroll_action_id and
	paa.assignment_id = p_assignment_id and
	-- ppa.business_group_id = p_bg_id and
	prrv.input_value_id=piv.input_value_id and
	ppa.date_earned between pet.effective_start_date and pet.effective_end_date and
	ppa.date_earned between piv.effective_start_date and piv.effective_end_date and
	paa.assignment_action_id=prr.assignment_action_id and
	prrv.run_result_id=prr.run_result_id and
	ptp.time_period_id=ppa.time_period_id and
	ptp.payroll_id = ppa.payroll_id
	order by date_earned,paa.assignment_action_id;



	l_index number;
	l_index1 number;
	l_loop_count number;
	l_wts_code1 varchar2(1);
	l_wts_date1 varchar2(4);
	l_wts_code2 varchar2(1);
	l_wts_date2 varchar2(4);
	l_wts_code3 varchar2(1);
	l_wts_date3 varchar2(4);
	l_code varchar2(1);
	l_date_earned date;
	l_period_start_date date;
	l_filter_table_count number;
	l_wage_tax_discount varchar2(255);

BEGIN

	if g_debug then
		hr_utility.set_location('Entering get_wage_tax_discount',1400);
	end if;

	l_index:=0;
	l_index1:=0;
	l_loop_count:=0;
	l_wts_code1:='0';
	l_wts_date1:='0000';
	l_wts_code2:='0';
	l_wts_date2:='0000';
	l_wts_code3:='0';
	l_wts_date3:='0000';

	for csr_wtd_code_rec in csr_wtd_code

	loop
	l_loop_count:=l_loop_count+1;
	l_code:=csr_wtd_code_rec.code;
	l_date_earned:=csr_wtd_code_rec.date_earned;
	l_period_start_date:=csr_wtd_code_rec.start_date;

	if l_loop_count=1 then
	    l_wtd_table(l_index).code:=csr_wtd_code_rec.code;


	    l_wtd_table(l_index).period_start_date:=csr_wtd_code_rec.start_date;



	    l_wtd_table(l_index).date_earned:=csr_wtd_code_rec.date_earned;


	end if;
	if l_loop_count>1 then


	    if l_date_earned=l_wtd_table(l_index).date_earned then
		l_wtd_table(l_index).code:=l_code;
		l_wtd_table(l_index).date_earned:=l_date_earned;
		l_wtd_table(l_index).period_start_date:=l_period_start_date;
	    else
		l_index:=l_index+1;

		l_wtd_table(l_index).code:=l_code;
		l_wtd_table(l_index).date_earned:=l_date_earned;
		l_wtd_table(l_index).period_start_date:=l_period_start_date;

	    end if;
	end if;
	end loop;

	FOR l_count IN 1 .. l_wtd_table.count


	LOOP


	    if l_count=1 then
		l_wtd_filter_table(l_index1).date_earned:=l_wtd_table(l_index1).date_earned;
		l_wtd_filter_table(l_index1).code:=l_wtd_table(l_index1).code;
		l_wtd_filter_table(l_index1).period_start_date:=l_wtd_table(l_index1).period_start_date;
	    end if;
	    if l_count>1 then

		if l_wtd_table(l_count-1).code<>l_wtd_filter_table(l_index1).code then
		    l_index1:=l_index1+1;
		    l_wtd_filter_table(l_index1).code:=l_wtd_table(l_count-1).code;
		    l_wtd_filter_table(l_index1).date_earned:=l_wtd_table(l_count-1).date_earned;
		    l_wtd_filter_table(l_index1).period_start_date:=l_wtd_table(l_count-1).period_start_date;
		end if;
	    end if;


	END LOOP;

	l_filter_table_count:=l_wtd_filter_table.count;
	IF l_filter_table_count>3 then
	    l_wts_code1:=l_wtd_filter_table(l_filter_table_count-3).code;
	    l_wts_date1:=to_char(l_wtd_filter_table(l_filter_table_count-3).period_start_date,'DDMM');
	    l_wts_code2:=l_wtd_filter_table(l_filter_table_count-2).code;
	    l_wts_date2:=to_char(l_wtd_filter_table(l_filter_table_count-2).period_start_date,'DDMM');
	    l_wts_code3:=l_wtd_filter_table(l_filter_table_count-1).code;
	    l_wts_date3:=to_char(l_wtd_filter_table(l_filter_table_count-1).period_start_date,'DDMM');
	ELSE
	    if l_filter_table_count=3 then
		l_wts_code1:=l_wtd_filter_table(0).code;
		l_wts_date1:=to_char(l_wtd_filter_table(0).period_start_date,'DDMM');
		l_wts_code2:=l_wtd_filter_table(1).code;
		l_wts_date2:=to_char(l_wtd_filter_table(1).period_start_date,'DDMM');
		l_wts_code3:=l_wtd_filter_table(2).code;
		l_wts_date3:=to_char(l_wtd_filter_table(2).period_start_date,'DDMM');
	    elsif l_filter_table_count=2 then
		l_wts_code1:=l_wtd_filter_table(0).code;
		l_wts_date1:=to_char(l_wtd_filter_table(0).period_start_date,'DDMM');
		l_wts_code2:=l_wtd_filter_table(1).code;
		l_wts_date2:=to_char(l_wtd_filter_table(1).period_start_date,'DDMM');
	    elsif l_filter_table_count=1 then
		l_wts_code1:=l_wtd_filter_table(0).code;
		l_wts_date1:=to_char(l_wtd_filter_table(0).period_start_date,'DDMM');
	    end if;
	END IF;

	if g_debug then
		hr_utility.set_location('l_wts_code1'||l_wts_code1,425);
		hr_utility.set_location('l_wts_code2'||l_wts_code2,425);
		hr_utility.set_location('l_wts_date2'||l_wts_date2,425);
		hr_utility.set_location('l_wts_code3'||l_wts_code3,425);
		hr_utility.set_location('l_wts_date3'||l_wts_date3,425);
	end if;

	l_wage_tax_discount:=l_wts_code1 || l_wts_date1 || l_wts_code2 || l_wts_date2 || l_wts_code3 || l_wts_date3;

	if g_debug then
		hr_utility.set_location('l_wage_tax_discount'||l_wage_tax_discount,1500);
		hr_utility.set_location('Exiting get_wage_tax_discount',1500);
	end if;

	return l_wage_tax_discount;



END get_wage_tax_discount;

/*-----------------------------------------------------------------------------
|Name       : get_wage_tax_table_code				               |
|Type       : Function							       |
|Description: Function which returns the wage tax table code 		       |
-------------------------------------------------------------------------------*/

function get_wage_tax_table_code(p_assignment_id number
				,p_tax_year_start_date date
				,p_tax_year_end_date date)return varchar2 IS

	CURSOR csr_wage_tax_table_code is
/*	select count(prrv.result_value) counter,prrv.result_value
	from
	pay_payroll_actions ppa,
	pay_assignment_actions paa,
	pay_element_types_f pet,
	pay_input_values_f piv,
	pay_run_results prr,
	pay_run_result_values prrv
	where
	pet.element_name='Standard Tax Deduction' and
	pet.element_type_id=piv.element_type_id and
	piv.name='Tax Code' and
	ppa.date_earned between p_tax_year_start_date and p_tax_year_end_date and
	ppa.payroll_action_id=paa.payroll_action_id and
	paa.assignment_id = p_assignment_id and
	prrv.input_value_id=piv.input_value_id
	and
	paa.assignment_action_id=prr.assignment_action_id and
	ppa.date_earned between pet.effective_start_date and pet.effective_end_date and
	ppa.date_earned between piv.effective_start_date and piv.effective_end_date and
	prrv.run_result_id=prr.run_result_id
	group by prrv.result_value
	order by counter desc; */

/* 14934399*/
select  /*+ ORDERED */ count(prrv.result_value) counter,prrv.result_value
	from
	pay_assignment_actions paa,
	pay_payroll_actions ppa,
	pay_element_types_f pet,
	pay_input_values_f piv,
	pay_run_results prr,
	pay_run_result_values prrv
	where
	pet.element_name='Standard Tax Deduction' and
	pet.element_type_id=piv.element_type_id and
	piv.name='Tax Code' and
	--ppa.business_group_id = p_bg_id and
	ppa.date_earned between p_tax_year_start_date and p_tax_year_end_date and
	ppa.payroll_action_id=paa.payroll_action_id and
	paa.assignment_id = p_assignment_id and
	prrv.input_value_id=piv.input_value_id
	and
	paa.assignment_action_id=prr.assignment_action_id and
	ppa.date_earned between pet.effective_start_date and pet.effective_end_date and
	ppa.date_earned between piv.effective_start_date and piv.effective_end_date and
	prrv.run_result_id=prr.run_result_id
	group by prrv.result_value
	order by counter desc;



	l_wage_tax_table_code varchar2(5);
	l_count number;

BEGIN

	if g_debug then
		hr_utility.set_location('Entering get_wage_tax_table_code',1500);
	end if;

	OPEN csr_wage_tax_table_code;
	FETCH csr_wage_tax_table_code into l_count,l_wage_tax_table_code;
	CLOSE csr_wage_tax_table_code;

	if g_debug then
		hr_utility.set_location('l_count'||l_count,1500);
		hr_utility.set_location('l_wage_tax_table_code'||l_wage_tax_table_code,1500);
	end if;

	return l_wage_tax_table_code;

	if g_debug then
		hr_utility.set_location('Exiting get_wage_tax_table_code',1500);
	end if;
END get_wage_tax_table_code;


/*-----------------------------------------------------------------------------
|Name       : get_si_insured_flag				               |
|Type       : Function							       |
|Description: Function which returns the si insured flag string		       |
-------------------------------------------------------------------------------*/

function get_si_insured_flag(p_assignment_id number
			    ,p_tax_year_start_date date
			    ,p_tax_year_end_date date) return varchar2 is

	CURSOR csr_si_insured_flag(lp_element_name varchar2) is
 	/* 14934414 */
	select 1 from dual
	where exists
	(select /*+ USE_NL(paa, ppa, pet,prr) */  prr.run_result_id,ppa.date_earned from pay_payroll_actions ppa
	      ,pay_assignment_actions paa
	      ,pay_run_results prr
	      ,pay_element_types_f pet
	 where ppa.payroll_action_id = paa.payroll_action_id
	 and paa.assignment_id = p_assignment_id
	 and paa.assignment_action_id = paa.assignment_action_id
	 and ppa.date_earned between p_tax_year_start_date and p_tax_year_end_date
	 and ppa.action_type in ('R','Q','B','I','V')
	 and paa.assignment_action_id=prr.assignment_action_id
	 and pet.element_type_id=prr.element_type_id
	 and pet.element_name=lp_element_name
	 and ppa.date_earned between pet.effective_start_date and pet.effective_end_date);

	l_si_insured_flag varchar2(2);
	l_SI_Insured_Flag1 varchar2(1);
	l_SI_Insured_Flag2 varchar2(1);
	l_flag varchar2(20);


BEGIN

	if g_debug then
		hr_utility.set_location('Entering l_SI_Insured_Flag',425);
	end if;


	OPEN csr_si_insured_flag('WAO Basis Social Insurance');
	FETCH csr_si_insured_flag into l_flag;
	if l_flag is not null then
		l_SI_Insured_Flag1:='1';
	else
		l_SI_Insured_Flag1:='0';
	end if;
	CLOSE csr_si_insured_flag;

	l_flag:=NULL;


	/*OPEN csr_si_insured_flag('ZFW Social Insurance');
	FETCH csr_si_insured_flag into l_flag;
	if l_flag is not null then
		l_SI_Insured_Flag2:='1';
	else
		l_SI_Insured_Flag2:='0';
	end if;
	CLOSE csr_si_insured_flag;


	l_SI_Insured_Flag:= l_SI_Insured_Flag1||l_SI_Insured_Flag2;

	if g_debug then
		hr_utility.set_location('l_SI_Insured_Flag'||l_SI_Insured_Flag,425);
		hr_utility.set_location('l_SI_Insured_Flag1'||l_SI_Insured_Flag1,425);
		hr_utility.set_location('l_SI_Insured_Flag2'||l_SI_Insured_Flag2,425);
		hr_utility.set_location('Exiting l_SI_Insured_Flag',425);
	end if;*/

	return l_SI_Insured_Flag1;

END get_si_insured_flag;


/*-----------------------------------------------------------------------------
|Name       : get_income_code					               |
|Type       : Function							       |
|Description: Function which returns the income code 			       |
-------------------------------------------------------------------------------*/

function get_income_code(p_assignment_id number
			,p_tax_year_start_date date
			,p_tax_year_end_date date)return varchar2 is


	cursor csr_get_income_code is
	select sck.segment8,SUM(decode(sign(p_tax_year_end_date - paa.effective_end_date),-1,p_tax_year_end_date,paa.effective_end_date)-decode(sign(paa.effective_start_date - p_tax_year_start_date),-1,p_tax_year_start_date,paa.effective_start_date)+1) Days
	from per_all_assignments_f paa,hr_soft_coding_keyflex sck
	where paa.assignment_id = p_assignment_id
	and   (paa.effective_start_date >= p_tax_year_start_date or p_tax_year_start_date between paa.effective_start_date and paa.effective_end_date)
	and   (paa.effective_end_date <= p_tax_year_end_date or paa.effective_start_date <= p_tax_year_end_date)
	and   sck.soft_coding_keyflex_id=paa.soft_coding_keyflex_id
	group by sck.segment8
	order by Days desc;


	l_income_code varchar2(10);
	l_days number;

BEGIN


	OPEN csr_get_income_code;
	FETCH csr_get_income_code into l_income_code,l_days;
	CLOSE csr_get_income_code;

	return l_income_code;

END get_income_code;


/*-----------------------------------------------------------------------------
|Name       : get_org_hierarchy					               |
|Type       : Function							       |
|Description: Function which returns organization structure version id         |
-------------------------------------------------------------------------------*/

function get_org_hierarchy(p_org_struct_id varchar2
			  ,p_tax_year_end_date date) return number IS

	cursor csr_org_hierarchy IS
	select
	posv.org_structure_version_id
	from
	per_organization_structures pos,
	per_org_structure_versions posv
	where pos.organization_structure_id = posv.organization_structure_id
	and to_char(pos.organization_structure_id) = p_org_struct_id
	and p_tax_year_end_date between posv.date_from and nvl(posv.date_to,hr_general.End_of_time);

	l_org_structure_version_id number;

BEGIN
	OPEN csr_org_hierarchy;
	FETCH csr_org_hierarchy INTO l_org_structure_version_id;
	CLOSE csr_org_hierarchy;

	hr_utility.set_location('l_org_structure_version_id'||l_org_structure_version_id,425);

	return l_org_structure_version_id;

END get_org_hierarchy;



function get_IZA_contributions(p_assgt_act_id number) return number IS

	l_IZA_contributions number;
	l_balance_value number;
	l_defined_balance_id number;

BEGIN

	hr_utility.set_location('Entering get_IZA_contributions',1050);

	l_IZA_contributions:=0;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_IZA_CONTRIBUTION_STANDARD_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_IZA_contributions:=l_IZA_contributions + l_balance_value;

	if g_debug then
		hr_utility.set_location('EMPLOYER_IZA_CONTRIBUTION_STANDARD_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_IZA_contributions'||l_IZA_contributions,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_IZA_CONTRIBUTION_SPECIAL_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_IZA_contributions:=l_IZA_contributions + l_balance_value;

	if g_debug then
		hr_utility.set_location('EMPLOYER_IZA_CONTRIBUTION_SPECIAL_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_IZA_contributions'||l_IZA_contributions,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_IZA_CONTRIBUTION_STANDARD_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_IZA_contributions:=l_IZA_contributions + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_IZA_CONTRIBUTION_STANDARD_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_IZA_contributions'||l_IZA_contributions,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYER_IZA_CONTRIBUTION_SPECIAL_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_IZA_contributions:=l_IZA_contributions + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYER_IZA_CONTRIBUTION_SPECIAL_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_IZA_contributions'||l_IZA_contributions,425);

		hr_utility.set_location('Exiting get_IZA_contributions',950);
	end if;


	return l_IZA_contributions;

END get_IZA_contributions;


function get_ZVW_basis(p_assgt_act_id number) return number IS

	l_ZVW_basis number := 0;
	l_balance_value number := 0;
	l_defined_balance_id number;

BEGIN

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('ZVW_INCOME_STANDARD_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZVW_basis:=l_ZVW_basis + l_balance_value;

	if g_debug then
		hr_utility.set_location('ZVW_INCOME_STANDARD_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZVW_basis'||l_ZVW_basis,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('ZVW_INCOME_SPECIAL_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZVW_basis:=l_ZVW_basis + l_balance_value;

	if g_debug then
		hr_utility.set_location('ZVW_INCOME_SPECIAL_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZVW_basis'||l_ZVW_basis,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_ZVW_INCOME_STANDARD_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZVW_basis:=l_ZVW_basis + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_ZVW_INCOME_STANDARD_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZVW_basis'||l_ZVW_basis,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_ZVW_INCOME_SPECIAL_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_ZVW_basis:=l_ZVW_basis + l_balance_value;

	if g_debug then
		hr_utility.set_location('RETRO_ZVW_INCOME_SPECIAL_TAX_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZVW_basis'||l_ZVW_basis,425);
	end if;

	l_ZVW_basis := floor(l_ZVW_basis);
	return l_ZVW_basis;

END get_ZVW_basis;


function get_ZVW_contributions(p_assgt_act_id number) return number IS

	l_ZVW_contribution number;
	l_context_id number;
	l_balance_value number;
	l_defined_balance_id number;

BEGIN

	hr_utility.set_location('Entering get_ZVW_Contribution',1050);

	l_ZVW_Contribution:=0;

	l_context_id:=get_context_id('SOURCE_TEXT');


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('NET_EMPLOYEE_SI_CONTRIBUTION_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZVW',null,null);
	END IF;
	l_ZVW_Contribution:=l_ZVW_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('NET_EMPLOYEE_SI_CONTRIBUTION_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZVW_Contribution'||l_ZVW_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZVW',null,null);
	END IF;
	l_ZVW_Contribution:=l_ZVW_Contribution + l_balance_value;

	if g_debug then
		hr_utility.set_location('EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZVW_Contribution'||l_ZVW_Contribution,425);
	end if;



	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZVW',null,null);
	END IF;
	l_ZVW_Contribution:=l_ZVW_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZVW_Contribution'||l_ZVW_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_NET_EMPLOYEE_SI_CONTRIBUTION_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZVW',null,null);
	END IF;
	l_ZVW_Contribution:=l_ZVW_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_NET_EMPLOYEE_SI_CONTRIBUTION_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZVW_Contribution'||l_ZVW_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZVW',null,null);
	END IF;
	l_ZVW_Contribution:=l_ZVW_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYEE_SI_CONTRIBUTION_STANDARD_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZVW_Contribution'||l_ZVW_Contribution,425);
	end if;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD');
	IF l_context_id IS NULL then
		l_balance_value:=0;
	ELSE
		l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,'ZVW',null,null);
	END IF;
	l_ZVW_Contribution:=l_ZVW_Contribution + l_balance_value;


	if g_debug then
		hr_utility.set_location('RETRO_EMPLOYEE_SI_CONTRIBUTION_SPECIAL_TAX_ASG_SIT_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_ZVW_Contribution'||l_ZVW_Contribution,425);
	end if;

	l_ZVW_Contribution:=ceil(l_ZVW_Contribution);

	return l_ZVW_Contribution;


END get_ZVW_Contributions;


/*-----------------------------------------------------------------------------
|Name       : get_VALUE_PRIVATE_USE_CAR					       |
|Type       : Function							       |
|Description: Function which returns the value private use car balance value   |
-------------------------------------------------------------------------------*/

function get_VALUE_PRIVATE_USE_CAR(p_assgt_act_id number) return number IS
	l_balance_value number;
	l_defined_balance_id number;
	l_Value_Private_Use_Car number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_VALUE_PRIVATE_USE_CAR',1300);
	end if;

	l_Value_Private_Use_Car:=0;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('VALUE_PRIVATE_USAGE_COMPANY_CAR_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_Value_Private_Use_Car:=l_balance_value;
	hr_utility.set_location('l_Value_Private_Use_Car'||l_Value_Private_Use_Car,425);

	if g_debug then
		hr_utility.set_location('Exiting get_VALUE_PRIVATE_USE_CAR',1300);
	end if;
	return l_Value_Private_Use_Car;


END get_VALUE_PRIVATE_USE_CAR;


/*-----------------------------------------------------------------------------
|Name       : get_LSS_Saved_Amount				               |
|Type       : Function							       |
|Description: Function which returns the saved amount for life saving scheme   |
-------------------------------------------------------------------------------*/

function get_LSS_Saved_Amount(p_assgt_act_id number) return number IS
	l_balance_value number;
	l_defined_balance_id number;
	l_LSS_Saved_Amount number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_LSS_Saved_Amount',1300);
	end if;

	l_LSS_Saved_Amount:=0;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYEE_LIFE_SAVINGS_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_LSS_Saved_Amount:=l_LSS_Saved_Amount + l_balance_value;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('EMPLOYER_LIFE_SAVINGS_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_LSS_Saved_Amount:=l_LSS_Saved_Amount + l_balance_value;

	hr_utility.set_location('l_LSS_Saved_Amount'||l_LSS_Saved_Amount,425);

	if g_debug then
		hr_utility.set_location('Exiting get_LSS_Saved_Amount',1300);
	end if;
	return l_LSS_Saved_Amount;


END get_LSS_Saved_Amount;


/*-----------------------------------------------------------------------------
|Name       : get_Employer_Part_Child_Care			               |
|Type       : Function							       |
|Description: Function which returns the Employer part Child Care balance value|
-------------------------------------------------------------------------------*/

function get_Employer_Part_Child_Care(p_assgt_act_id number) return number IS
	l_balance_value number;
	l_defined_balance_id number;
	l_Employer_Part_Child_Care number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_Employer_Part_Child_Care',1300);
	end if;

	l_Employer_Part_Child_Care:=0;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('CHILD_CARE_EMPLOYER_CONTRIBUTION_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_Employer_Part_Child_Care:=l_balance_value;
	hr_utility.set_location('l_Employer_Part_Child_Care'||l_Employer_Part_Child_Care,425);

	if g_debug then
		hr_utility.set_location('Exiting get_Employer_Part_Child_Care',1300);
	end if;
	return l_Employer_Part_Child_Care;


END get_Employer_Part_Child_Care;


/*-----------------------------------------------------------------------------
|Name       : get_Allowance_On_Disability			               |
|Type       : Function							       |
|Description: Function which returns the paid allowance on Disability Allowance|
-------------------------------------------------------------------------------*/

function get_Allowance_On_Disability(p_assgt_act_id number) return number IS
	l_balance_value number;
	l_defined_balance_id number;
	l_Allowance_On_Disability number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_Allowance_On_Disability',1300);
	end if;

	l_Allowance_On_Disability:=0;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('PAID_DISABILITY_ALLOWANCE_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_Allowance_On_Disability:=l_balance_value;
	hr_utility.set_location('l_Allowance_On_Disability'||l_Allowance_On_Disability,425);

	if g_debug then
		hr_utility.set_location('Exiting get_Allowance_On_Disability',1300);
	end if;
	return l_Allowance_On_Disability;


END get_Allowance_On_Disability;


/*-----------------------------------------------------------------------------
|Name       : get_Applied_LCLD					               |
|Type       : Function							       |
|Description: Function which returns the Applied Life Cycle Leave Discount     |
-------------------------------------------------------------------------------*/

function get_Applied_LCLD(p_assgt_act_id number) return number IS
	l_balance_value number;
	l_defined_balance_id number;
	l_Applied_LCLD number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_Applied_LCLD',1300);
	end if;

	l_Applied_LCLD:=0;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('LIFE_CYCLE_LEAVE_DISCOUNT_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_Applied_LCLD:=l_Applied_LCLD + l_balance_value;

/*	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_LIFE_CYCLE_LEAVE_DISCOUNT_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_Applied_LCLD:=l_Applied_LCLD + l_balance_value;*/

	hr_utility.set_location('l_Applied_LCLD'||l_Applied_LCLD,425);

	if g_debug then
		hr_utility.set_location('Exiting get_Applied_LCLD',1300);
	end if;
	return l_Applied_LCLD;


END get_Applied_LCLD;


/*-----------------------------------------------------------------------------
|Name       : populate_UserBal					               |
|Type       : Procedure							       |
|Description: Procedure which populates pl/sql table with user defined balance |
|             names and tag names                                              |
-------------------------------------------------------------------------------*/

PROCEDURE populate_UserBal(p_bg_id number, p_effective_date DATE) IS

CURSOR	csr_get_rows IS
select	pur.user_row_id
from	pay_user_rows_f pur,
	pay_user_tables put
where	put.user_table_name='NL_ATS_USER_BALANCES'
and	put.legislation_code='NL'
and	pur.user_table_id=put.user_table_id
and	p_effective_date between pur.effective_start_date and pur.effective_end_date;

v_csr_get_rows	csr_get_rows%ROWTYPE;
vCtr		NUMBER;
vBalColId	NUMBER;
vTagColId	NUMBER;
vBalName	VARCHAR2(1000);
vTagName	VARCHAR2(1000);

BEGIN

	vUserBalTable.DELETE;
	vCtr := 0;
	vBalColId := null;
	vTagColId := null;

	BEGIN

		SELECT	puc.user_column_id
		INTO	vBalColId
		FROM	pay_user_columns	puc,
			pay_user_tables		put
		WHERE	put.user_table_name='NL_ATS_USER_BALANCES'
		and	put.legislation_code='NL'
		and	put.user_table_id=puc.user_table_id
		and	puc.user_column_name='BAL_NAME';

	EXCEPTION

		WHEN NO_DATA_FOUND
			THEN vBalColId := null;

		WHEN OTHERS
			THEN vBalColId := null;

	END;

	BEGIN

		SELECT	puc.user_column_id
		INTO	vTagColId
		FROM	pay_user_columns	puc,
			pay_user_tables		put
		WHERE	put.user_table_name='NL_ATS_USER_BALANCES'
		and	put.legislation_code='NL'
		and	put.user_table_id=puc.user_table_id
		and	puc.user_column_name='TAG_NAME';

	EXCEPTION

		WHEN NO_DATA_FOUND
			THEN vTagColId := null;

		WHEN OTHERS
			THEN vTagColId := null;

	END;

	IF vBalColId is NOT NULL and vTagColId is NOT NULL THEN

		FOR v_csr_get_rows IN csr_get_rows
		LOOP

			vBalName := null;
			vTagName := null;

			BEGIN

				SELECT	puci.value
				INTO	vBalName
				FROM	pay_user_column_instances_f puci
				WHERE	puci.user_row_id=v_csr_get_rows.user_row_id
				AND	puci.user_column_id=vBalColId
				AND	p_effective_date between puci.effective_start_date and puci.effective_end_date;

			EXCEPTION

				WHEN NO_DATA_FOUND
					THEN vBalName := null;

				WHEN OTHERS
					THEN vBalName := null;

			END;

			BEGIN

				SELECT	puci.value
				INTO	vTagName
				FROM	pay_user_column_instances_f puci
				WHERE	puci.user_row_id=v_csr_get_rows.user_row_id
				AND	puci.user_column_id=vTagColId
				AND	p_effective_date between puci.effective_start_date and puci.effective_end_date;

			EXCEPTION

				WHEN NO_DATA_FOUND
					THEN vTagName := null;

				WHEN OTHERS
					THEN vTagName := null;

			END;

			IF vBalName is not NULL and vTagName is not NULL THEN

				vUserBalTable(vCtr).BalName := replace(upper(vBalName),' ','_')||'_ASG_YTD';
				vUserBalTable(vCtr).TagName := replace(vTagName,' ','');
				vCtr := vCtr + 1;

			END IF;

		END LOOP;

	END IF;

END populate_UserBal;

/*-----------------------------------------------------------------------------
|Name       : get_User_Balances                                                |
|Type       : Procedure							       |
|Description: Procedure which returns the User Defined Balances                |
-------------------------------------------------------------------------------*/

PROCEDURE get_User_Balances	(p_assgt_act_id in number
				,p_bg_id in number
                                ,p_User_Bal_String out nocopy varchar2) IS

l_defined_balance_id number;
l_balance_value number;
l_balance_string varchar2(255) := null;
l_ctr_table number;

BEGIN

	IF vUserBalTable.count > 0 THEN

		FOR l_ctr_table IN vUserBalTable.FIRST .. vUserBalTable.LAST LOOP

			l_defined_balance_id := null;
			l_balance_value := 0;

			l_defined_balance_id:=get_User_Defined_Balance_Id(vUserBalTable(l_ctr_table).BalName,p_bg_id);

			IF l_defined_balance_id is NULL THEN
				l_balance_value := 0;
			ELSE
				l_balance_value := pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
			END IF;

			l_balance_string := l_balance_string||fnd_number.number_to_canonical(ceil(l_balance_value))||'|';

		END LOOP;

		p_User_Bal_String := l_balance_string;

	END IF;

END get_User_Balances;


/*-----------------------------------------------------------------------------
|Name       : get_User_Defined_Balance_Id                                      |
|Type       : Procedure							       |
|Description: Procedure which returns the User Defined Balance Id              |
-------------------------------------------------------------------------------*/

FUNCTION get_User_Defined_Balance_Id	(p_user_name IN VARCHAR2, p_bg_id IN NUMBER) RETURN NUMBER IS
	/* Cursor to retrieve User Defined Balance Id */
	CURSOR csr_def_bal_id(p_user_name VARCHAR2) IS
	SELECT  u.creator_id
	FROM    ff_user_entities  u,
		ff_database_items d
	WHERE   d.user_name = p_user_name
	AND     u.user_entity_id = d.user_entity_id
	AND     (u.legislation_code is NULL )
	AND     (u.business_group_id = p_bg_id )
	AND     u.creator_type = 'B';

	l_defined_balance_id ff_user_entities.user_entity_id%TYPE;

BEGIN
	OPEN csr_def_bal_id(p_user_name);
	FETCH csr_def_bal_id INTO l_defined_balance_id;
	CLOSE csr_def_bal_id;
	RETURN l_defined_balance_id;

END get_User_Defined_Balance_Id;

END PAY_NL_TAXOFFICE_ARCHIVE;

/
