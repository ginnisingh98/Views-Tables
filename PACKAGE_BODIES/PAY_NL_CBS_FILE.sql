--------------------------------------------------------
--  DDL for Package Body PAY_NL_CBS_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_CBS_FILE" as
/* $Header: pynlcbsf.pkb 120.0.12000000.1 2007/01/17 22:54:38 appldev noship $ */

g_package   varchar2(33) := 'PAY_NL_CBS_FILE';
g_error_flag		varchar2(60);
g_warning_flag		varchar2(30);
g_error_count		NUMBER := 0;
g_payroll_action_id	NUMBER;
g_assignment_number	VARCHAR2(30);
g_full_name		VARCHAR2(150);
g_debug                 boolean ;
g_reporting_date        DATE;
g_message_name          VARCHAR2(255) := ' ';

g_working_hours_formula_exists  BOOLEAN := TRUE;
g_working_hours_formula_cached  BOOLEAN := FALSE;
g_working_hours_formula_id      ff_formulas_f.formula_id%TYPE;
g_working_hours_formula_name    ff_formulas_f.formula_name%TYPE;


/*******************************************************************************
|Name       : GET_ALL_PARAMETERS                                               |
|Type       : Procedure							       |
|Description: Procedure which returns all the parameters of the archive	process|
********************************************************************************/

PROCEDURE get_all_parameters (
          p_payroll_action_id		 IN  NUMBER
         ,p_business_group_id            OUT NOCOPY NUMBER
         ,p_reporting_date               OUT NOCOPY DATE
         ,p_effective_date               OUT NOCOPY DATE
         ,p_employer                     OUT NOCOPY NUMBER
         ,p_si_provider                  OUT NOCOPY NUMBER
         ,p_org_struct_id                OUT NOCOPY NUMBER
         ,p_medium_code			 OUT NOCOPY NUMBER
         ,p_density                      OUT NOCOPY NUMBER
  ) IS
--
  CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
  SELECT fnd_date.canonical_to_date(pay_core_utils.get_parameter('REPORTING_DATE',legislative_parameters))
        ,pay_core_utils.get_parameter('EMPLOYER_ID',legislative_parameters)
        ,pay_core_utils.get_parameter('ORG_STRUCT_ID',legislative_parameters)
        ,pay_core_utils.get_parameter('SI_PROVIDER_ID',legislative_parameters)
        ,pay_core_utils.get_parameter('MEDIUM_CODE',legislative_parameters)
        ,pay_core_utils.get_parameter('DENSITY',legislative_parameters)
        ,effective_date
        ,business_group_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
--
 -- l_effective_date date;
  -- l_proc VARCHAR2(80):= g_package||' get_all_parameters ';
--
BEGIN
  --
 -- hr_utility.set_location('Entered get all parameters',425);

  OPEN csr_parameter_info (p_payroll_action_id);
  FETCH csr_parameter_info INTO
  p_reporting_date,p_employer, p_org_struct_id,p_si_provider,p_medium_code,p_density
  ,p_effective_date,p_business_group_id;
  CLOSE csr_parameter_info;
  g_reporting_date:= p_reporting_date;
  if g_debug then
         hr_utility.set_location('Executed the cursor in get all parameters ',425);
	 hr_utility.set_location('p_reporting_date'||p_reporting_date,425);
	 hr_utility.set_location('p_employer'||p_employer,425);
	 hr_utility.set_location('p_org_struct_id'||p_org_struct_id,425);
	 hr_utility.set_location('p_si_provider'||p_si_provider,425);
	 hr_utility.set_location('p_medium_code'||p_medium_code,425);
	 hr_utility.set_location('p_density'||p_density,425);
	 hr_utility.set_location('p_effective_date'||p_effective_date,425);
	 hr_utility.set_location('p_business_group_id'||p_business_group_id,425);
  end if;
  -- hr_utility.set_location('Leaving get all parameters',425);

  --
END get_all_parameters;
--

/********************************************************************************
|Name           : Mandatory_Check                                           	|
|Type		: Procedure						        |
|Description    : Procedure to check if the specified Mandatory Field is NULL   |
|                 if so flag a Error message to the Log File                    |
*********************************************************************************/

Procedure Mandatory_Check(p_message_name varchar2
			,p_field varchar2
			,p_value varchar2) is
	v_message_text fnd_new_messages.message_text%TYPE;
	v_employee_dat VARCHAR2(255);
	v_log_header   VARCHAR2(255);
	v_label_desc   hr_lookups.meaning%TYPE;

Begin
  -- hr_utility.set_location('Entered Mandatory_check',425);

	if g_debug then
		 hr_utility.set_location('Started Checking Field in Mandatory_Check '||p_field,425);
	end if;

	If p_value is null then
  		v_label_desc := hr_general.decode_lookup('HR_NL_REPORT_LABELS', p_field);
                	v_employee_dat :=RPAD(SUBSTR(g_assignment_number,1,20),20)
                               ||' '||RPAD(SUBSTR(g_full_name,1,35),35)
                               ||' '||RPAD(SUBSTR(v_label_desc,1,35),35);
                              -- ||' '||RPAD(SUBSTR(g_error_flag,1,15),15);
                               hr_utility.set_message(801,p_message_name);
                              -- v_message_text :=SUBSTR(fnd_message.get,1,65);
                               g_error_count := NVL(g_error_count,0) +1;
	        if p_message_name <> g_message_name then
		    if g_message_name = 'PAY_NL_EE_REQUIRED_FIELD' then
		        v_log_header := RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','NL_ASSIGNMENT_NUMBER'),1,20),20)
		    ||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','FULL_NAME'),1,35),35)
	            ||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','FIELD_NAME'),1,35),35)
	            --||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','ERROR_TYPE'),1,15),15)
                    --||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','MESSAGE'),1,70),70
		    ;
                    Fnd_file.put_line(FND_FILE.LOG,v_log_header);
		    end if;
                hr_utility.set_message(801,p_message_name);
                v_message_text := rpad(fnd_message.get,255,' ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,v_message_text);
                g_message_name := p_message_name;
                end if;
           FND_FILE.PUT_LINE(FND_FILE.LOG, v_employee_dat);
        end if;
 -- hr_utility.set_location('Leaving  get all parameters',425);
End Mandatory_Check;

/********************************************************************************
|Name           : get_loc_extra_info                                            |
|Type		: Function						        |
|Description    : This Function returns extra information like Contact and      |
|                 Telephone No for Employer details 		  		|
*********************************************************************************/

Function get_loc_extra_info(p_org_id number
                                           ,p_contact out nocopy varchar2
                                           ,p_telephone out nocopy varchar2
					   ) return number  IS
cursor csr_loc_extra_info(p_org_id number) IS
select lei_information10,lei_information11
from hr_location_extra_info
where information_type = 'NL_POSTAL_ADDRESS'
and  location_id = (select location_id from hr_organization_units where organization_id = p_org_id);
begin
-- hr_utility.set_location('Entering Get_loc_extra_info',600);
open csr_loc_extra_info(p_org_id);
fetch csr_loc_extra_info into p_contact,p_telephone;
close csr_loc_extra_info;
-- hr_utility.set_location('Exiting Get_loc_extra_info',600);
return 1;
end get_loc_extra_info;

/********************************************************************************
|Name           : get_er_sequence                                                  |
|Type		: Function						        |
|Description    : This Function returns the next sequence number for            |
|                 employer                                                      |
*********************************************************************************/

Function Get_er_sequence(p_employer_id number
		     ,p_si_provider_id  number
	             ,p_reporting_date date
                     ,p_sequence out nocopy number ) return number IS

	cursor csr_get_max_sequence IS
	select max(pai.action_information4)
	from    pay_action_information pai
	where pai.action_information1 = fnd_number.number_to_canonical(p_employer_id)
	and   pai.action_information2 = fnd_number.number_to_canonical(p_si_provider_id)
	and  to_char(pai.effective_date,'YYYY') = to_char(p_reporting_date,'YYYY');

	l_max_sequence  varchar2(30);
	l_sequence      number;
BEGIN
-- hr_utility.set_location('Entering Get_er_Sequence',600);
open csr_get_max_sequence;
fetch csr_get_max_sequence into l_max_Sequence;
close csr_get_max_Sequence;
l_sequence := fnd_number.canonical_to_number(l_max_Sequence);
p_sequence := nvl(to_number(l_sequence),0) + 1;
-- hr_utility.set_location('Exiting Get_er_Sequence',600);
return 1;
END Get_er_sequence;

/*******************************************************************************
|Name       : Get_Balances1                                                    |
|Type       : Function							       |
|Description: Function which returns all the balances required for CBS File    |
*******************************************************************************/

function get_balances1(    p_frequency varchar2
                          ,p_assgt_act_id number
                          ,l_holiday_hours out nocopy number
                          ,l_adv_hours out nocopy number
                          ,l_si_wage out nocopy number
                          ,l_unique_payments out nocopy number
                          ,l_pre_tax_deductions out nocopy number
                          ,l_saving_scheme out nocopy number
                          ,l_sickness_days out nocopy number
                          ,l_unpaid_hours out nocopy number
                          ,l_sickness_pay out nocopy number
                          ,l_overtime_hours out nocopy number
 )
return number is

l_pre_tax_only_ded		 NUMBER;
l_pre_si_pre_tax_ded		 NUMBER;
l_si_std_tax			 NUMBER;
l_si_spl_tax			 NUMBER;
l_ret_si_std_tax		 NUMBER;
l_ret_si_spl_tax		 NUMBER;
l_dimension                      VARCHAR2(20);
l_defined_balance                VARCHAR2(150);
l_defined_balance_id             NUMBER;


BEGIN
 -- hr_utility.set_location('Entered get_balances1',425);

if p_frequency = 'K' then
   l_dimension := '_ASG_QTD';
else
  if p_frequency = 'M' then
     l_dimension := '_ASG_MONTH';
  else
       l_dimension := '_ASG_LMONTH';
  end if;
end if;

-- hr_utility.set_location('Fetching Defined Balance ID for CBS_HOLIDAY_HOURS',500);
l_defined_balance := 'CBS_HOLIDAY_HOURS'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_holiday_hours:= nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0);
-- hr_utility.set_location('l_holiday_hours'||l_holiday_hours,425);

-- hr_utility.set_location('Fetching Defined Balance ID for CBS_ADV_HOURS',500);
l_defined_balance := 'CBS_ADV_HOURS'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_adv_hours:=nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0);
-- hr_utility.set_location('l_adv_hours'||l_adv_hours,425);

-- hr_utility.set_location('Fetching Defined Balance ID for SI_INCOME_STANDARD_TAX',500);
l_defined_balance := 'SI_INCOME_STANDARD_TAX'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_si_std_tax:=nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0);
-- hr_utility.set_location('l_si_std_tax'||l_si_std_tax,425);

-- hr_utility.set_location('Fetching Defined Balance ID for SI_INCOME_SPECIAL_TAX',500);
l_defined_balance := 'SI_INCOME_SPECIAL_TAX'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_si_spl_tax:=nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0);
-- hr_utility.set_location('l_si_spl_tax'||l_si_spl_tax,425);

-- hr_utility.set_location('Fetching Defined Balance ID for RETRO SI_INCOME_STANDARD_TAX',500);
l_defined_balance := 'RETRO_SI_INCOME_STANDARD_TAX'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_ret_si_std_tax :=nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0);
-- hr_utility.set_location('l_ret_si_std_tax'||l_ret_si_std_tax,425);

-- hr_utility.set_location('Fetching Defined Balance ID for RETRO_SI_INCOME_SPECIAL_TAX',500);
l_defined_balance := 'RETRO_SI_INCOME_SPECIAL_TAX'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_ret_si_spl_tax:=nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0);
-- hr_utility.set_location('l_ret_si_spl_tax'||l_ret_si_spl_tax,425);

-- hr_utility.set_location('Fetching Defined Balance ID for CBS_UNIQUE_PAYMENTS',500);
l_defined_balance := 'CBS_UNIQUE_PAYMENTS'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_unique_payments :=round(nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0));
-- hr_utility.set_location('l_unique_payments'||l_unique_payments,425);

-- hr_utility.set_location('Fetching Defined Balance ID for PRE_TAX_ONLY_DEDUCTIONS',500);
l_defined_balance := 'PRE_TAX_ONLY_DEDUCTIONS'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_pre_tax_only_ded:=nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0);
-- hr_utility.set_location('l_pre_tax_only_ded'||l_pre_tax_only_ded,425);

-- hr_utility.set_location('Fetching Defined Balance ID for PRE_TAX_ONLY_DEDUCTIONS',500);
l_defined_balance := 'PRE_TAX_DEDUCTIONS'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_pre_si_pre_tax_ded :=nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0);
-- hr_utility.set_location('l_pre_si_pre_tax_ded'||l_pre_si_pre_tax_ded,425);

-- hr_utility.set_location('Fetching Defined Balance ID for EMPLOYEE_SAVINGS_CONTRIBUTION',500);
l_defined_balance := 'EMPLOYEE_SAVINGS_CONTRIBUTION'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_saving_scheme:=round(nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0));
-- hr_utility.set_location('l_saving_scheme'||l_saving_scheme,425);

-- hr_utility.set_location('Fetching Defined Balance ID for CBS_SICKNESS_DAYS',500);
l_defined_balance := 'CBS_SICKNESS_DAYS'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_sickness_days :=round(nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0));
-- hr_utility.set_location('l_sickness_days'||l_sickness_days,425);

-- hr_utility.set_location('Fetching Defined Balance ID for CBS_SICKNESS_PAY',500);
l_defined_balance := 'CBS_SICKNESS_PAY'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_sickness_pay:=round(nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0));
-- hr_utility.set_location('l_sickness_pay'||l_sickness_pay,425);

-- hr_utility.set_location('Fetching Defined Balance ID for CBS_UNPAID_HOURS',500);
l_defined_balance := 'CBS_UNPAID_HOURS'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_unpaid_hours :=nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0);
-- hr_utility.set_location('l_unpaid_hours'||l_unpaid_hours,425);

-- hr_utility.set_location('Fetching Defined Balance ID for CBS_OVERTIME_HOURS',500);
l_defined_balance := 'CBS_OVERTIME_HOURS'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_overtime_hours:=nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0);
-- hr_utility.set_location('l_overtime_hours'||l_overtime_hours,425);

l_si_wage :=round(NVL(l_si_std_tax,0)+NVL(l_si_spl_tax,0)+NVL(l_ret_si_std_tax,0)+ NVL(l_ret_si_spl_tax,0));
l_pre_tax_deductions := round(NVL(l_pre_si_pre_tax_ded,0)- NVL(l_pre_tax_only_ded,0));

return 1;
 -- hr_utility.set_location('Exited get_balances1',425);

end get_balances1;

/*******************************************************************************
|Name       : Get_Balances2                                                    |
|Type       : Function							       |
|Description: Function which returns all the balances required for CBS File    |
*******************************************************************************/
function get_balances2          ( p_frequency varchar2
                                 ,p_assgt_act_id number
                                 ,l_wage_agreed_by_contract out nocopy number
                                 ,l_number_of_days out nocopy number
                                 ,l_si_days_quarter out nocopy number
                                 ,l_paid_gross_wage out nocopy number
                                 ,l_wage_for_overtime out nocopy number
                                 ) return number is

cursor csr_get_context_id (p_ass_act_id Number) IS
	select ff.context_id   context_id
	      , pact.context_value  Context_value
              , decode(context_value,'ZFW',0,'ZW',1,
               'WEWE',2,'WEWA',3,'WAOD',4,'WAOB',5,6) seq
	from   ff_contexts ff, pay_action_contexts pact
	where  ff.context_name   = 'SOURCE_TEXT'  and
	       ff.context_id = pact.context_id    and
	       pact.assignment_action_id = p_ass_act_id
	ORDER BY decode(context_value,'ZFW',0,'ZW',1,
               'WEWE',2,'WEWA',3,'WAOD',4,'WAOB',5,6)	;


l_context_id		         NUMBER;
l_context_value			 Varchar2(20);
l_context_seq			 NUMBER;
l_dimension                      VARCHAR2(20);
l_defined_balance                VARCHAR2(150);
l_defined_balance_id             NUMBER;


begin
 -- hr_utility.set_location('Exited get_balances2',425);

if p_frequency = 'K' then
   l_dimension := '_ASG_PTD';
else
  if p_frequency = 'M' then
     l_dimension := '_ASG_MONTH';
  else
       l_dimension := '_ASG_LMONTH';
  end if;
end if;

open csr_get_context_id(p_assgt_act_id);
fetch csr_get_context_id into l_context_id , l_context_value , l_context_seq;
close csr_get_context_id;

l_defined_balance := 'CBS_CONTRACT_WAGE'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_wage_agreed_by_contract :=round(nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0));
-- hr_utility.set_location('l_wage_agreed_by_contract'||l_wage_agreed_by_contract,425);

if ( l_context_id is not null and l_context_value is not null ) then
if (p_frequency = 'M') then
-- hr_utility.set_location('Fetching Defined Balance ID for REAL_SOCIAL_INSURANCE_DAYS_ASG_SIT_MONTH',500);
l_defined_balance := 'REAL_SOCIAL_INSURANCE_DAYS_ASG_SIT_MONTH';
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_number_of_days := nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,l_context_value,null,null),0);
-- hr_utility.set_location('l_number_of_days'||l_number_of_days,425);
else
if (p_frequency = 'K') then
-- hr_utility.set_location('Fetching Defined Balance ID for REAL_SOCIAL_INSURANCE_DAYS_ASG_SIT_QTD',500);
l_defined_balance := 'REAL_SOCIAL_INSURANCE_DAYS_ASG_SIT_QTD';
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_number_of_days := nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,l_context_value,null,null),0);
else
-- hr_utility.set_location('Fetching Defined Balance ID for REAL_SOCIAL_INSURANCE_DAYS_ASG_SIT_LMONTH',500);
l_defined_balance := 'REAL_SOCIAL_INSURANCE_DAYS_ASG_SIT_LMONTH';
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_number_of_days := nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,l_context_value,null,null),0);
end if;
end if;

-- hr_utility.set_location('Fetching Defined Balance ID for REAL_SOCIAL_INSURANCE_DAYS_ASG_SIT_QTD',500);
l_defined_balance := 'REAL_SOCIAL_INSURANCE_DAYS_ASG_SIT_QTD';
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_si_days_quarter := nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id,null,null,l_context_id,l_context_value,null,null),0);
-- hr_utility.set_location('l_si_days_quarter'||l_si_days_quarter,425);
else
l_number_of_days := 0;
l_si_days_quarter := 0;
end if;

-- hr_utility.set_location('Fetching Defined Balance ID for CBS_PAID_GROSS_WAGE',500);
l_defined_balance := 'CBS_PAID_GROSS_WAGE'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_paid_gross_wage :=round(nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0));
-- hr_utility.set_location('l_paid_gross_wage'||l_paid_gross_wage,425);

-- hr_utility.set_location('Fetching Defined Balance ID for CBS_OVERTIME_WAGE',500);
l_defined_balance := 'CBS_OVERTIME_WAGE'||l_dimension;
l_defined_balance_id:=pay_nl_general.get_defined_balance_id(l_defined_balance);
l_wage_for_overtime :=round(nvl(pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id),0));
-- hr_utility.set_location('l_wage_for_overtime'||l_wage_for_overtime,425);

return 1;
 -- hr_utility.set_location('Exited get_balances2',425);
end get_balances2;

/*******************************************************************************
|Name       : Get_health_insurance                                             |
|Type       : Function							       |
|Description: Function used to pick the si status of the assignment for ZFW    |
|             insurance. If health insurance is from a Private Insurance       |
|	      provider,the provider type of the Private Health Insurance       |
|	      Provider is returned.                                            |
*******************************************************************************/

function get_health_insurance(p_assignment_id in number,
                              p_date in date) RETURN VARCHAR2 IS

cursor csr_get_si_status(p_assignment_id number,
                         p_date date) is
	select pay_nl_si_pkg.get_si_status(p_assignment_id,p_date,'ZFW')
	from dual;

cursor csr_get_phi_information(p_assignment_id number,
                               p_date          date) is
SELECT ORG_INFORMATION1 FROM HR_ORGANIZATION_INFORMATION,PER_ASSIGNMENT_EXTRA_INFO PAEI
WHERE  PAEI.ASSIGNMENT_ID = p_assignment_id
AND PAEI.AEI_INFORMATION_CATEGORY = 'NL_PHI'
 AND ORGANIZATION_ID = PAEI.AEI_INFORMATION3
AND ORG_INFORMATION_CONTEXT = 'NL_PHI_ORG_INFO'
AND p_date between fnd_date.canonical_to_date(PAEI.AEI_INFORMATION1) and nvl(fnd_date.canonical_to_date(PAEI.AEI_INFORMATION2),hr_general.end_of_time);

-- For Fetching IZA Information
cursor csr_get_iza (p_assignment_id number,
                    p_date          date) IS
SELECT ORG_INFORMATION1
FROM HR_ORGANIZATION_INFORMATION HOI,PER_ASSIGNMENT_EXTRA_INFO PAEI
WHERE  PAEI.ASSIGNMENT_ID = p_assignment_id
AND PAEI.AEI_INFORMATION_CATEGORY = 'NL_IZA_INFO'
AND HOI.ORGANIZATION_ID = PAEI.AEI_INFORMATION3
AND HOI.ORG_INFORMATION_CONTEXT = 'NL_PHI_ORG_INFO'
AND p_date between fnd_date.canonical_to_date(PAEI.AEI_INFORMATION1) and nvl(fnd_date.canonical_to_date(PAEI.AEI_INFORMATION2),hr_general.end_of_time);

l_si_status  NUMBER;
l_si_provider VARCHAR2(150);

BEGIN
 -- hr_utility.set_location('Entering Get_health_insurance ',425);

open csr_get_si_status(p_assignment_id,p_date);
-- if csr_get_si_status % found then
fetch csr_get_si_status into l_si_status;
-- end if;
close csr_get_si_status;

 -- hr_utility.set_location('fETCHED l_si_status '|| l_si_status,425);

if l_si_status is not null THEN
  if  l_si_status =4 then
	open csr_get_iza(p_assignment_id,p_date);
    -- hr_utility.set_location('opened the cursor '|| l_si_status,425);
        fetch csr_get_iza into l_si_provider;
        close csr_get_iza;
	    if l_si_provider is null then
		   -- hr_utility.set_location('entered into if loop '|| l_si_status,425);
		   open csr_get_phi_information(p_assignment_id,p_date);
		    -- hr_utility.set_location('opened the cursor '|| l_si_status,425);
		   fetch csr_get_phi_information into l_si_provider;
		    -- hr_utility.set_location('fETCHED l_si_provider from org info '|| l_si_status,425);
		   close csr_get_phi_information;
             end if;
   else
      l_si_provider :='1';
   end if;
     -- hr_utility.set_location('Leaving Get_health_insurance ',425);
return l_si_provider;
else
  return '0';
end if;
 EXCEPTION
  when others then
    hr_utility.set_location('Exception :' ||'health insurance'||SQLERRM(SQLCODE),999);
  -- hr_utility.set_location('Leaving Get_health_insurance ',425);
end;

/*******************************************************************************
|Name       : Get_working_schedule                                             |
|Type       : Function							       |
|Description: Function to get working schedule for the assignment              |
*******************************************************************************/
PROCEDURE Get_working_schedule  (p_assignment_id IN NUMBER,
                                 p_working_schedule OUT NOCOPY NUMBER,
                                 p_reporting_start_date IN DATE,
                                 p_reporting_end_date IN DATE )IS

cursor csr_get_working_schedule is
	select sck.segment6,
	SUM(decode(sign(p_reporting_end_date - paa.effective_end_date),-1,p_reporting_end_date,paa.effective_end_date)-decode(sign(paa.effective_start_date - p_reporting_start_date),-1,p_reporting_start_date,paa.effective_start_date)+1) Days
	from per_all_assignments_f paa,hr_soft_coding_keyflex sck
	where paa.assignment_id = p_assignment_id
	and   (paa.effective_start_date >= p_reporting_start_date or p_reporting_start_date between paa.effective_start_date and paa.effective_end_date)
	and   (paa.effective_end_date <= p_reporting_end_date or paa.effective_start_date <= p_reporting_end_date)
	and   sck.soft_coding_keyflex_id=paa.soft_coding_keyflex_id
	group  by sck.segment6
	order by Days desc;

l_temp_working_schedule         VARCHAR2(10);
l_days                          NUMBER;

BEGIN
 -- hr_utility.set_location('Entering Get_working_schedule ',425);

OPEN csr_get_working_schedule;
FETCH csr_get_working_schedule into l_temp_working_schedule,l_days;
CLOSE csr_get_working_schedule;

If l_temp_working_schedule = 'R' then
   p_working_schedule  := 1;
Else
   If l_temp_working_schedule = 'I' then
      p_working_schedule := 2;
   Else
     p_working_schedule := 3;
  End if;
End if;
 -- hr_utility.set_location('Exiting Get_working_schedule ',425);

END get_working_schedule;

/********************************************************************************
|Name       : Get_dev_work_hours                                                |
|Type       : Function							        |
|Description: Function to get the Deviating Working Hours for the longest period|
*********************************************************************************/
PROCEDURE Get_dev_work_hours (p_assignment_id IN NUMBER,
                                 p_dev_work_hours OUT NOCOPY NUMBER,
                                 p_reporting_start_date IN DATE,
                                 p_reporting_end_date IN DATE )IS

cursor csr_get_dev_work_hrs is
	select sck.segment13,
	SUM(decode(sign(p_reporting_end_date - paa.effective_end_date),-1,p_reporting_end_date,paa.effective_end_date)-decode(sign(paa.effective_start_date - p_reporting_start_date),-1,p_reporting_start_date,paa.effective_start_date)+1) Days
	from per_all_assignments_f paa,hr_soft_coding_keyflex sck
	where paa.assignment_id = p_assignment_id
	and   (paa.effective_start_date >= p_reporting_start_date or p_reporting_start_date between paa.effective_start_date and paa.effective_end_date)
	and   (paa.effective_end_date <= p_reporting_end_date or paa.effective_start_date <= p_reporting_end_date)
	and   sck.soft_coding_keyflex_id=paa.soft_coding_keyflex_id
	group  by sck.segment13
	order by Days desc;

l_temp_dev_work_hrs            VARCHAR2(100);
l_days                          NUMBER;

BEGIN
 -- hr_utility.set_location('Entering Get_dev_work_hours ',425);

OPEN csr_get_dev_work_hrs;
FETCH csr_get_dev_work_hrs into l_temp_dev_work_hrs,l_days;
CLOSE csr_get_dev_work_hrs;

If l_temp_dev_work_hrs is not null then
p_dev_work_hours := fnd_number.canonical_to_number(l_temp_dev_work_hrs);
else
p_dev_work_hours :=0;
End if;
 -- hr_utility.set_location('Leaving Get_dev_work_hours ',425);

END Get_dev_work_hours;


/********************************************************************************
|Name       : Get_Employment_Code                                               |
|Type       : Function							        |
|Description: Function to get the Employment Code                               |
*********************************************************************************/
Function Get_Employment_Code  (p_assignment_id IN NUMBER,
                                 p_employment_code IN OUT NOCOPY NUMBER,
                                 p_reporting_start_date IN DATE,
                                 p_reporting_end_date IN DATE ) return NUMBER IS

cursor csr_get_employmetnt_code is
	select sck.segment6,paa.employment_category,
	SUM(decode(sign(p_reporting_end_date - paa.effective_end_date),-1,p_reporting_end_date,paa.effective_end_date)-decode(sign(paa.effective_start_date - p_reporting_start_date),-1,p_reporting_start_date,paa.effective_start_date)+1) Days
	from per_all_assignments_f paa,hr_soft_coding_keyflex sck
	where paa.assignment_id = p_assignment_id
	and   (paa.effective_start_date >= p_reporting_start_date or p_reporting_start_date between paa.effective_start_date and paa.effective_end_date)
	and   (paa.effective_end_date <= p_reporting_end_date or paa.effective_start_date <= p_reporting_end_date)
	and   sck.soft_coding_keyflex_id=paa.soft_coding_keyflex_id
	group  by sck.segment6,paa.employment_category
	order by Days desc;

l_temp_working_schedule        VARCHAR2(20);
l_emp_category                 VARCHAR2(20);
l_days                         NUMBER;

BEGIN
 -- hr_utility.set_location('Entering Get_Employment_Code ',425);

OPEN csr_get_employmetnt_code;
FETCH csr_get_employmetnt_code into l_temp_working_schedule,l_emp_category,l_days;
CLOSE csr_get_employmetnt_code;

If (l_emp_category = 'PR' or l_emp_category = 'PT' or l_emp_category = 'NL_TRAINEE')
   AND (l_temp_working_schedule = 'I' or l_temp_working_schedule = 'S') then
   p_employment_code  := 3;
   return 1;
Else
   If (l_emp_category = 'PR' or l_emp_category = 'PT' or l_emp_category = 'NL_TRAINEE_PT')
      AND (l_temp_working_schedule = 'R') then
      p_employment_code := 2;
      return 1;
Else
   If (l_emp_category = 'FR' or l_emp_category = 'FT' or l_emp_category = 'NL_TRAINEE') then
   p_employment_code := 1;
   return 1;
   End if;
  End if;
   p_employment_code :=0;
   return 1;
 End if;

 -- hr_utility.set_location('leaving Get_Employment_Code ',425);

END Get_Employment_Code;



/********************************************************************************
|Name       : Get_cbs_Working_Hours                                                 |
|Type       : Function				  			        |
|Description: Function to get the Working Hours                                 |
*********************************************************************************/
FUNCTION Get_cbs_Working_Hours(p_business_group_id IN NUMBER,
			       p_assignment_id IN NUMBER ,
                               p_reporting_date IN DATE
			       ) RETURN  NUMBER  is

cursor csr_get_freq_ind_hours(l_assignment_id number ,l_reporting_date date) IS
select sck.segment28, paa.frequency
from PER_ALL_ASSIGNMENTS_F paa,HR_SOFT_CODING_KEYFLEX sck
where paa.assignment_id = l_assignment_id
and   paa.SOFT_CODING_KEYFLEX_ID = sck.SOFT_CODING_KEYFLEX_ID
and   l_reporting_date between paa.effective_start_date and paa.effective_end_date;

l_inputs  ff_exec.inputs_t;
l_outputs ff_exec.outputs_t;
l_formula_exists  BOOLEAN := TRUE;
l_formula_cached  BOOLEAN := FALSE;
l_formula_id      ff_formulas_f.formula_id%TYPE;
l_formula_name    ff_formulas_f.formula_name%TYPE;
l_weekly_working_hours  NUMBER;
l_ind_work_hours    NUMBER;
l_ind_work_hours2   varchar2(10);
l_frequency         varchar2(10);
weeks_per_month     VARCHAR2(20);


BEGIN
--
-- hr_utility.set_location('--In Get Working Hours ',10);
  g_working_hours_formula_name := 'NL_WEEKLY_WORKING_HOURS';
  IF g_working_hours_formula_exists = TRUE THEN
IF g_working_hours_formula_cached = FALSE THEN
   PAY_NL_GENERAL.cache_formula('NL_WEEKLY_WORKING_HOURS',p_business_group_id,p_reporting_date,l_formula_id,l_formula_exists,l_formula_cached);
	    g_working_hours_formula_exists:=l_formula_exists;
	    g_working_hours_formula_cached:=l_formula_cached;
	    g_working_hours_formula_id:=l_formula_id;
	 END IF;
 END IF;

IF g_working_hours_formula_exists = TRUE THEN

l_inputs(1).name  := 'BUSINESS_GROUP_ID';
l_inputs(1).value := p_business_group_id;
l_inputs(2).name  := 'ASSIGNMENT_ID';
l_inputs(2).value := p_assignment_id;

l_outputs(1).name := 'WEEKLY_WORKING_HOURS';

	PAY_NL_GENERAL.run_formula(p_formula_id       => g_working_hours_formula_id,
	            p_effective_date   => g_reporting_date,
		    p_formula_name     => g_working_hours_formula_name,
                    p_inputs           => l_inputs,
		    p_outputs          => l_outputs);

 l_weekly_working_hours := fnd_number.canonical_to_number(l_outputs(1).value);

 if l_weekly_working_hours is null then
 l_weekly_working_hours := 0;
 end if;
 return l_weekly_working_hours;
 ELSE
    -- hr_utility.set_location('--In the ELSE Part of get working hours '|| p_assignment_id || p_reporting_date ,10);
    OPEN csr_get_freq_ind_hours(p_assignment_id,p_reporting_date);
    fetch csr_get_freq_ind_hours into l_ind_work_hours2,l_frequency;
    close csr_get_freq_ind_hours;
  l_ind_work_hours := fnd_number.canonical_to_number(l_ind_work_hours2);
  weeks_per_month := pay_nl_general.get_global_value(p_reporting_date,'NL_TAX_WEEKS_PER_MONTH');
   if l_frequency = 'M' then
      l_weekly_working_hours := l_ind_work_hours/fnd_number.canonical_to_number(weeks_per_month);
   else
	if l_frequency = 'D' then
           l_weekly_working_hours := l_ind_work_hours * 5;
        else l_weekly_working_hours := l_ind_work_hours;
	end if;

	 if l_weekly_working_hours is null then
	l_weekly_working_hours := 0;
	 end if;
   end if;
   	  -- hr_utility.set_location('--In the ELSE Part of get working hours '|| l_weekly_working_hours,10);
          return l_weekly_working_hours;
END IF;
 -- hr_utility.set_location('Leaving Get_CBS_Working_Hours ',425);

 EXCEPTION
  when others then
    hr_utility.set_location('Exception :' ||'cbs working hours'||SQLERRM(SQLCODE),999);
End Get_CBS_Working_Hours;

/*******************************************************************************
|Name       : GET_CAO_CODE                                                     |
|Type       : Procedure							       |
|Description: Function to get the collective agreement for the given assignmnent|
*******************************************************************************/
PROCEDURE GET_CAO_CODE (p_assignment_id in number,
              p_cao_code    in out nocopy number,
	      p_rep_date     in DATE) IS

CURSOR csr_get_cao_code(l_assignment_id NUMBER) IS
select AEI_INFORMATION5 from per_assignment_extra_info aei
WHERE aei.information_type like 'NL_CADANS_INFO' and aei.assignment_id = l_assignment_id
and  p_rep_date between fnd_date.canonical_to_date(aei.AEI_INFORMATION1) and nvl(fnd_date.canonical_to_date(aei.AEI_INFORMATION2),hr_general.end_of_time);

l_cao_code          VARCHAR2(50);

begin

 -- hr_utility.set_location('Entering GET_CAO_CODE ',425);

OPEN csr_get_cao_code(p_assignment_id);
FETCH  csr_get_cao_code  INTO l_cao_code;
CLOSE  csr_get_cao_code;
p_cao_code := fnd_number.canonical_to_number(l_cao_code);

 -- hr_utility.set_location('Leaving GET_CAO_CODE ',425);

END GET_CAO_CODE;

/********************************************************************************
|Name       : get_grade_salary_number                                           |
|Type       : Function							        |
|Description: Function to get the grade and salary numbers                      |
********************************************************************************/

Function get_grade_salary_number(p_assignment_id     in number,
                                 P_business_group_id in number,
				 p_org_id            in number,
				 P_grade_id          in number,
                                 P_reporting_date    in date,
				 P_public_sector     in varchar2,
                                 P_grade_number      out nocopy varchar2,
                                 P_salary_number     out nocopy varchar2) return number is

-- Cursor to get the grade number
Cursor csr_get_grade_number(p_grade_id number,p_business_group_id number) is
Select sequence from per_grades pg
Where pg.grade_id = p_grade_id
And pg.business_group_id = p_business_group_id;

-- Cursor to get the ceiling
Cursor csr_get_ceiling(p_grade_id number,p_business_group_id number,p_reporting_date date) is
Select max(sequence) from per_spinal_point_steps_f psps
Where psps.grade_spine_id = (select grade_spine_id from per_grade_spines_f pgs
			     Where grade_id = p_grade_id
			     And p_reporting_date between pgs.effective_start_date and pgs.effective_end_date
			     and pgs.business_Group_id = p_businesS_group_id)
And p_reporting_date between psps.effective_start_date and psps.effective_end_date
And psps.business_group_id = p_business_group_id;

-- Cursor to get the salary sequence
Cursor csr_get_salary_sequence (p_grade_id number, p_business_group_id number,
p_assignment_id number,p_reporting_date date) is
Select sequence
from per_spinal_point_steps_f psps
Where psps.grade_spine_id = (select grade_spine_id from per_grade_spines_f pgs
			    Where grade_id = p_grade_id
			    And p_reporting_date between pgs.effective_start_date and  pgs.effective_end_date
			    and pgs.business_Group_id = p_business_group_id)
And p_reporting_date between psps.effective_start_date and psps.effective_end_date
And psps.business_group_id = p_business_group_id
And psps.step_id = (select step_id
		    from per_spinal_point_placements_f  psp
		    where assignment_id = p_assignment_id
		    and p_reporting_date between psp.effective_start_date and psp.effective_end_date
		    and psp.business_group_id = p_business_group_id);


l_public_sector_org		varchar2(10);
l_ceiling			number;
l_salary_sequence		number;
l_salary_number			number;
l_grade_number			number;

Begin

--	l_public_sector_org := hr_nl_org_info.Get_Public_Sector_Org(p_org_id);
-- hr_utility.set_location('--Entering get_grade_salary_number ',10);

	if P_public_sector = 'Y' then
		Open csr_get_grade_number(p_grade_id,p_business_group_id);
		Fetch csr_get_grade_number into l_grade_number;
		Close csr_get_grade_number;
	  if l_grade_number is null then
		  l_grade_number := 999;
	  end if;
	else
		l_grade_number := 000;
	end if;

	Open csr_get_ceiling(p_grade_id,p_business_group_id,p_reporting_date);
	Fetch csr_get_ceiling into l_ceiling;
	Close csr_get_ceiling;

	Open csr_get_salary_sequence(p_grade_id,p_business_group_id,p_assignment_id,p_reporting_date);
	Fetch csr_get_salary_sequence into l_salary_sequence;
	Close csr_get_salary_sequence;
	if ( l_salary_sequence is null or l_ceiling is null) then
		if P_public_sector = 'Y' then
		l_salary_number := 999;
		else
		l_salary_number := 000;
		end if;
	else
	l_salary_number := to_char(NVL(l_salary_sequence,0) - (NVL(l_ceiling,0) - NVL(l_salary_sequence,0)));
	end if;
	p_grade_number  := lpad(to_char(l_grade_number),3,'0');
	p_salary_number := lpad(to_char(l_salary_number),3,'0');

	Return 1;
	 -- hr_utility.set_location('Leaving get_grade_salary_number ',425);

End get_grade_salary_number;


/*******************************************************************************
|Name       : Get_tax_details                                                  |
|Type       : Function							       |
|Description: Function to get the tax details                                  |
*******************************************************************************/
Function Get_tax_details(p_max_assgt_act_id number
                        ,p_wage_tax_discount OUT NOCOPY varchar2
                        ,p_tax_code OUT NOCOPY VARCHAR2
                        ,p_labour_relation_code OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

cursor csr_get_date_earned(p_asg_act_id number) is
select date_earned
from pay_payroll_actions ppa,pay_assignment_Actions paa
where
ppa.payroll_action_id = paa.payroll_action_id
and paa.assignment_action_id = p_max_assgt_act_id;

cursor csr_run_result_id(p_assignment_action_id number, p_element_type_id number) is
select prr.run_result_id
from pay_run_results prr
where
prr.element_type_id=p_element_type_id and
prr.assignment_action_id=p_assignment_action_id;

l_date_earned                date;
l_run_result_id		     NUMBER;
l_element_type_id	     NUMBER;
l_tax_discount_input_id      NUMBER;
l_tax_code_input_id          NUMBER;
l_labour_relation_code_id    NUMBER;

BEGIN
-- hr_utility.set_location('-- Entering Get_tax_details ',10);

open csr_get_date_earned(p_max_assgt_act_id);
fetch csr_get_date_earned into l_date_earned;
close csr_get_date_Earned;

l_element_type_id:=pay_nl_general.get_element_type_id('Standard Tax Deduction',l_date_earned);
l_tax_discount_input_id:=pay_nl_general.get_input_value_id(l_element_type_id,'Tax Reduction Flag',l_date_earned);
l_tax_code_input_id := pay_nl_general.get_input_value_id(l_element_type_id,'Tax Code',l_date_earned);
l_labour_relation_code_id:=pay_nl_general.get_input_value_id(l_element_type_id,'Labour Tax Reduction Flag',l_date_earned);

open csr_run_result_id ( p_max_assgt_act_id ,l_element_type_id) ;
fetch csr_run_result_id into l_run_result_id;
close csr_run_Result_id;

if pay_nl_general.get_run_result_value(p_max_assgt_act_id,l_element_type_id,l_tax_discount_input_id,l_run_result_id,'C')  = 'NL_NONE' then
      p_wage_tax_discount := '00';
else
      p_wage_tax_discount := '01';
end if;

p_tax_code := pay_nl_general.get_run_result_value(p_max_assgt_act_id,l_element_type_id,l_tax_code_input_id,l_run_result_id,'C');

if pay_nl_general.get_run_result_value(p_max_assgt_act_id,l_element_type_id,l_labour_relation_code_id,l_run_result_id,'C') = 'N' then
    p_labour_relation_code := '00';
else
    p_labour_relation_code := '01';
end if;

return 1;
-- hr_utility.set_location('-- Leaving Get_tax_details ',10);

end get_tax_details;

/********************************************************************************
|Name           : RANGE_CODE                                       		|
|Type		: Procedure							|
|Description    : This procedure returns a sql string to select a range of 	|
|		  assignments eligible for archival		  		|
*********************************************************************************/

Procedure RANGE_CODE (pactid    IN    NUMBER
                     ,sqlstr    OUT   NOCOPY VARCHAR2) IS
--
--      Variables for GET ALL PARAMETERS
--
        l_business_group_id		 NUMBER;
	l_employer_id			 NUMBER;
	l_si_provider_id		 NUMBER;
	l_payroll_id			 NUMBER;
	l_report_type		         pay_payroll_actions.report_type%TYPE;
	l_effective_date		 DATE;
	l_employer			 NUMBER;
	l_si_provider			 NUMBER;
	l_org_struct_id			 NUMBER;
	l_medium_code			 NUMBER;
	l_density			 NUMBER;
	l_reporting_date                 DATE;

--
--     Variables for Sender and Org Details
--
	l_Sender_Rep_Name_bg		VARCHAR2(255);
        l_Sender_Reg_Number_bg		VARCHAR2(255);
	l_Wage_Tax_Rep_Name_org		VARCHAR2(255);
        l_Wage_Tax_Reg_Number_org	VARCHAR2(255);
--
--      Variables for Sender and Org Details
--
       l_Sender_Rep_Name_sip            VARCHAR2(255);
       l_Sender_Reg_Number_sip 		VARCHAR2(255);
       l_Employer_Rep_Name_sip 		VARCHAR2(255);
       l_Employer_Reg_Number_sip 	VARCHAR2(255);
--
--      Variables for Mandatory Data
--
       l_employer_contact               VARCHAR2(255);
       l_employer_telephone             VARCHAR2(255);
--
--      Variables for Sender Address
--
       l_sen_house_number		VARCHAR2(255);
       l_sen_house_no_add               VARCHAR2(255);
       l_sen_street_name                VARCHAR2(255);
       l_sen_line1                      VARCHAR2(255);
       l_sen_line2                      VARCHAR2(255);
       l_sen_line3                      VARCHAR2(255);
       l_sen_city                       VARCHAR2(255);
       l_sen_country                    VARCHAR2(255);
       l_sen_postal_code                VARCHAR2(255);
--
--      Variables for Address
--
       l_house_number                   VARCHAR2(255);
       l_house_no_add                   VARCHAR2(255);
       l_street_name                    VARCHAR2(255);
       l_line1                          VARCHAR2(255);
       l_line2                          VARCHAR2(255);
       l_line3                          VARCHAR2(255);
       l_city                           VARCHAR2(255);
       l_country                        VARCHAR2(255);
       l_postal_code                    VARCHAR2(255);
--
--      Variables for  Mandatory Data
--
       l_sender_address_field           VARCHAR2(255);
       l_sen_city_field                 VARCHAR2(255);
       l_tax_address_field              VARCHAR2(255);
       l_tax_city_field                 VARCHAR2(255);
       l_org_struct_version_id          VARCHAR2(255);
       l_frequency                      VARCHAR2(255);
       l_customer_number                VARCHAR2(255);

--
--     Variables for Archival Code
--
        l_return_value			NUMBER;
	l_action_info_id		NUMBER;
	l_ovn				NUMBER;
	l_sender_address		NUMBER;
	l_org_address			NUMBER;
	l_sequence			NUMBER;
        v_log_header                    VARCHAR2(1000);



 BEGIN

 g_debug := FALSE ;
  if g_debug then
		hr_utility.trace_on(NULL,'CBS');
		hr_utility.set_location('Entering GET ALL PARAMETERS of Range Code ',600);
	end if;

	g_error_flag := hr_general.decode_lookup('HR_NL_REPORT_LABELS','ERROR');

    PAY_NL_CBS_FILE.get_all_parameters(pactid,
                                          P_business_group_id     =>  l_business_group_id,
                                          P_reporting_date        =>  l_reporting_date,
                                          P_effective_date        =>  l_effective_date,
                                          P_employer              =>  l_employer,
                                          P_si_provider           =>  l_si_provider,
                                          P_org_struct_id         =>  l_org_struct_id,
                                          P_medium_code           =>  l_medium_code,
                                          P_density               =>  l_density);

hr_utility.set_location('exited GET ALL PARAMETERS',600);

       l_return_value := PAY_NL_TAXOFFICE_FILE.GET_TOS_SENDER_DETAILS
					(l_Business_Group_Id,
					 l_Employer,
					 l_Sender_Rep_Name_bg,
					 l_Sender_Reg_Number_bg,
					 l_Wage_Tax_Rep_Name_org,
					 l_Wage_Tax_Reg_Number_org);

      	hr_utility.set_location('Executing Get_SIP_Details',600);

      l_return_value := PAY_NL_ANNUAL_SI_FILE.Get_SIP_Details
					( l_employer
					 ,l_si_provider
					 ,l_reporting_date
					 ,l_Sender_Rep_Name_sip
					 ,l_Sender_Reg_Number_sip
					 ,l_Employer_Rep_Name_sip
					 ,l_Employer_Reg_Number_sip
					 );

      l_return_value :=  get_loc_extra_info
                                         (l_employer,
                                          p_contact  => l_employer_contact,
                                          p_telephone => l_employer_telephone);

	-- hr_utility.set_location('Executing GET BG ADDRESS',600);

      l_sender_address:=PAY_NL_GENERAL.GET_ORGANIZATION_ADDRESS
                                         (l_business_group_id,
					  l_business_group_id,
					  l_sen_house_number,
					  l_sen_house_no_add,
					  l_sen_street_name,
					  l_sen_line1,
					  l_sen_line2,
					  l_sen_line3,
					  l_sen_city,
					  l_sen_country,
					  l_sen_postal_code);

		-- hr_utility.set_location('Executing GET ORG ADDRESS',600);

      l_org_address:=PAY_NL_GENERAL.GET_ORGANIZATION_ADDRESS
                                         (l_employer
					  ,l_business_group_id
					  ,l_house_number
					  ,l_house_no_add
					  ,l_street_name
					  ,l_line1
					  ,l_line2
					  ,l_line3
					  ,l_city
					  ,l_country
					  ,l_postal_code);

-- hr_utility.set_location('Going to retrieve all the address fields',600);

l_sender_address_field := l_sen_street_name || l_sen_house_number || l_sen_house_no_add;
l_sen_city_field := l_sen_postal_code || l_sen_city;
l_tax_address_field := l_street_name || l_house_number || l_house_no_add;
l_tax_city_field := l_postal_code || l_city;
-- hr_utility.set_location('Going to retrieve the Data of org struct id,frequency and cust no'||l_reporting_date,600);
l_org_struct_version_id := pay_nl_taxoffice_archive.get_org_hierarchy(l_org_struct_id,l_reporting_date);
l_frequency := hr_nl_org_info.get_reporting_frequency(l_employer);
l_customer_number := hr_nl_org_info.get_customer_number(l_employer);

-- hr_utility.set_location('Going to perform mandatory check the Data in Range Code',600);

Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_NAME',      l_Sender_Rep_Name_bg);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_ADDR',      l_sender_address_field);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_CITY',      l_sen_city_field);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_REG_NUM',   l_Sender_Reg_Number_bg);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_REPORTING_FREQUENCY', l_frequency);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_CUSTOMER_NUMBER',  l_customer_number);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_TAX_REPORTING_NAME',l_Wage_Tax_Rep_Name_org);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_ER_ADDR',          l_tax_address_field);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_CITY',             l_tax_city_field);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_TAX_REGISTRATION_NUMBER',l_Wage_Tax_Reg_Number_org);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_ER_SI_REG_NUMBER',l_Employer_Reg_Number_sip);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_ER_CONTACT',l_employer_contact);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_ER_TELEPHONE',l_employer_telephone);


IF g_error_count=0 THEN
    --  l_return_value := Pay_nl_cbs_file.Get_er_sequence(l_employer,l_si_provider,l_reporting_date,l_sequence);
	-- hr_utility.set_location('Fetched the sequence, employer = '||l_employer||'si provider='||l_si_provider,600);
	l_sequence :=1;
        Pay_Action_information_api.create_action_information(
					P_action_information_id 	 =>     l_action_info_id
					,p_action_context_id             =>     pactid
					,p_action_context_type           =>     'PA'
					,p_object_version_number         =>     l_ovn
					,p_effective_date                =>     l_reporting_date
					,p_source_id	                 =>     NULL
					,p_source_text	                 =>     NULL
					,p_action_information_category   =>    'NL CBS EMPLOYER DETAILS'
					,p_action_information1           =>     l_employer
					,p_action_information2	         =>     l_si_provider
					,p_action_information4	         =>     l_sequence);

-- hr_utility.set_location('Completed the Employer Archive',600);

-- hr_utility.set_location('Generating the query for assignment actiond ids',600);

sqlstr := 'SELECT DISTINCT person_id
	FROM  per_people_f ppf
	,pay_payroll_actions ppa
	WHERE ppa.payroll_action_id = :payroll_action_id
	AND   ppa.business_group_id = ppf.business_group_id
        ORDER BY ppf.person_id';

	--and   ppf.person_id = 13916';

  /*   v_log_header := RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','NL_ASSIGNMENT_NUMBER'),1,20),20)
		    ||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','FULL_NAME'),1,35),35)
	            ||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','FIELD_NAME'),1,35),35)
	            --||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','ERROR_TYPE'),1,15),15)
                    --||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','MESSAGE'),1,70),70
		    );

     Fnd_file.put_line(FND_FILE.LOG,v_log_header);*/

     if g_debug then
	  hr_utility.set_location('Leaving Range Code',350);
     end if;

ELSE
/*If  mandatory data is missing do not return any person ids*/
       sqlstr := 'SELECT DISTINCT person_id
       FROM  per_people_f ppf
       ,pay_payroll_actions ppa
       WHERE ppa.payroll_action_id = :payroll_action_id
       AND   1 = 2
       AND   ppa.business_group_id = ppf.business_group_id
       ORDER BY ppf.person_id';
END IF;
    -- hr_utility.set_location('Exiting Range Code',600);

END RANGE_CODE;

/*******************************************************************************|
|Name           : check_Asg_si_provider                                      	|
|Type		: FUNCTION							|
|Description    : This FUNCTION checks whether the given assignment corresponds |
|		: to the si provider or not                                     |
*********************************************************************************/
FUNCTION check_Asg_si_provider(p_organization_id IN NUMBER
			  ,p_si_provider_id  IN NUMBER
			  ,p_assignment_id   IN NUMBER )
			  RETURN NUMBER  IS

l_si_provider_id NUMBER;
 BEGIN

    -- hr_utility.set_location('Entering check_Asg_si_provider funciton ',600);

 l_si_provider_id := HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(p_organization_id,'ZFW',p_assignment_id);
 IF ( l_si_provider_id = p_si_provider_id) THEN
     RETURN 1;
 END IF;
  l_si_provider_id := HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(p_organization_id,'ZW',p_assignment_id);
 IF ( l_si_provider_id = p_si_provider_id) THEN
     RETURN 1;
 END IF;
 l_si_provider_id := HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(p_organization_id,'WEWE',p_assignment_id);
 IF ( l_si_provider_id = p_si_provider_id) THEN
     RETURN 1;
 END IF;
 l_si_provider_id := HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(p_organization_id,'WEWA',p_assignment_id);
 IF ( l_si_provider_id = p_si_provider_id) THEN
     RETURN 1;
 END IF;
 l_si_provider_id := HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(p_organization_id,'WAOB',p_assignment_id);
 IF ( l_si_provider_id = p_si_provider_id) THEN
     RETURN 1;
 END IF;
 l_si_provider_id := HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(p_organization_id,'WAOD',p_assignment_id);
 IF ( l_si_provider_id = p_si_provider_id) THEN
     RETURN 1;
 else
  return 0;
  end if;
-- hr_utility.set_location('Exiting check_Asg_si_provider funciton ',600);

end check_Asg_si_provider;


/*******************************************************************************|
|Name           : chekck_asg_terminate                                      	|
|Type		: FUNCTION							|
|Description    : This FUNCTION checks whether the given assignment terminated  |
|		: on the given date                                             |
*********************************************************************************/

Function check_asg_terminate ( p_assignment_id NUMBER,
                                p_rep_date      DATE)  return NUMBER IS

cursor csr_asg_term is
	select max(asg.effective_end_date) asg_end_date
	from   per_all_assignments_f asg,
	per_assignment_status_types past
	where  asg.assignment_id = p_assignment_id
	and   past.per_system_status = 'ACTIVE_ASSIGN'
	and   asg.assignment_status_type_id = past.assignment_status_type_id
	and    asg.effective_start_date <= p_rep_date
	and    asg.effective_end_date = p_rep_date;
  l_eff_date Date;

BEGIN

-- hr_utility.set_location('Entering chekck_asg_terminate funciton ',600);

    OPEN csr_asg_term ;
    fetch csr_asg_term into l_eff_date;
     if csr_asg_term % found and l_eff_date = p_rep_date then
	   return 1;
     else return 0;
     end if;
     close csr_asg_term;
     -- hr_utility.set_location('Exiting chekck_asg_terminate funciton ',600);
end check_asg_terminate;

/*******************************************************************************|
|Name           : ASSIGNMENT_ACTION_CODE                                      	|
|Type		: Procedure							|
|Description    : This procedure further restricts the assignment id's returned |
|		  by the range code.                                            |
*********************************************************************************/

Procedure ASSIGNMENT_ACTION_CODE (p_payroll_action_id  in number
				  ,p_start_person_id   in number
				  ,p_end_person_id     in number
				  ,p_chunk             in number) IS

Cursor csr_process_assignments
(p_business_group_id number,
 p_employer_id number,
 p_reporting_start_date date,
 p_reporting_end_date date,
 p_org_struct_version_id number,
 p_si_provider_id number,
 p_frequency varchar2
) IS
Select
        paa.organization_id,
        paa.soft_coding_keyflex_id,
        pap.person_id,
        paa.assignment_id,
        pap.last_name,
        paa.assignment_number,
        pap.full_name,
        pap.Date_of_Birth,
        pap.national_identifier,
	paa.grade_id
from
 per_all_people_f pap
,per_all_assignments_f paa
,hr_soft_coding_keyflex scl_flx
where
pap.business_group_id =p_business_group_id
and pap.person_id = paa.person_id
and paa.person_id BETWEEN p_start_person_id AND p_end_person_id
and scl_flx.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
and p_reporting_end_Date between pap.effective_start_date and pap.effective_end_date
and paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM per_assignment_status_types past, per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   past.per_system_status = 'ACTIVE_ASSIGN'
		and   asg.assignment_status_type_id = past.assignment_status_type_id
		and   asg.effective_start_date <= p_reporting_End_Date
		and   nvl(asg.effective_end_date, p_reporting_End_Date) >= p_reporting_Start_Date
		)
and p_employer_id in
(select hr_nl_org_info.get_tax_org_id(p_org_struct_version_id,paa.organization_id) from dual)
and not exists
(select 1
from
pay_action_information ee_ats
WHERE ee_ats.action_context_type='AAP'
AND ee_ats.action_information_category = 'NL CBS EMPLOYEE DETAILS'
AND ee_ats.action_information1  =p_employer_id
AND ee_ats.action_information4  =pap.person_id
AND ee_ats.action_information2  =p_si_provider_id
AND ee_ats.action_information3  =paa.assignment_id
AND ee_ats.effective_date       =p_reporting_end_date);


	l_asg_act_id			 number;
	l_dummy				 number;
	l_assignment_id			 number;

-- Variables for Get All Parameters.
        l_business_group_id		 NUMBER;
	l_employer_id			 NUMBER;
	l_si_provider_id		 NUMBER;
	l_payroll_id			 NUMBER;
	l_report_type		         pay_payroll_actions.report_type%TYPE;
	l_effective_date		 DATE;
	l_employer			 NUMBER;
	l_si_provider			 NUMBER;
	l_org_struct_id			 NUMBER;
	l_medium_code			 NUMBER;
	l_density			 NUMBER;
	l_reporting_date                 DATE;
--
--
	l_org_struct_version_id          NUMBER;
	l_asg_employer_id                NUMBER;
        l_frequency                      VARCHAR2(100);
	l_reporting_start_date           DATE;
	l_reporting_end_date             DATE;
	l_soft_coding_keyflex_id         NUMBER;

--  Variables for Balances.
        l_holiday_hours			NUMBER;
	l_adv_hours			NUMBER;
	l_si_wage			NUMBER;
	l_unique_payments		NUMBER;
	l_pre_tax_deductions		NUMBER;
	l_saving_scheme			NUMBER;
	l_sickness_days			NUMBER;
	l_unpaid_hours			NUMBER;
	l_sickness_pay			NUMBER;
	l_overtime_hours		NUMBER;
	l_wage_agreed_by_contract       NUMBER;
        l_number_of_days                NUMBER;
        l_si_days_quarter               NUMBER;
        l_paid_gross_wage               NUMBER;
        l_wage_for_overtime             NUMBER;
        l_employment                    NUMBER :=0;
	l_ovn                           NUMBER;
	l_number                        NUMBER;
	l_unpaid_hours1                 VARCHAR2(20);
	l_overtime_hours1               VARCHAR2(20);
-- Variables for other values.
       l_income_code                    VARCHAR2(80);
       l_health_insurance               VARCHAR2(200);

-- Variables for Archiving the data
        l_grade_salary_info             VARCHAR2(12);
        l_person_id                     NUMBER;
        l_max_assgt_act_id		NUMBER;
        l_action_info_id                NUMBER;
	l_employment_code               NUMBER :=0;
	l_wage_tax_discount             VARCHAR2(20);
	l_tax_code                      VARCHAR2(20);
	l_labour_relation_code          VARCHAR2(20);
	l_working_schedule              VARCHAR2(20);
	l_tax_info                      VARCHAR2(40);
	l_work_times                    VARCHAR2(40);
        l_cao_code                      NUMBER;
	l_si_provider_check             NUMBER;
        l_grade_number                  VARCHAR2(10);
	l_salary_number                 VARCHAR2(10);
	l_deviating_working_hours       number;
	l_grade_id                      NUMBER;
	l_public_sector                 VARCHAR2(10);
	l_asg_term                      NUMBER;


BEGIN
   --

 g_debug := FALSE;
 if g_debug then
		-- hr_utility.trace_on(NULL,'CBS');
                hr_utility.set_location('Entering Assignment Action Code',600);
		hr_utility.set_location('p_payroll_action_id'||p_payroll_action_id,400);
 end if;

g_error_flag := hr_general.decode_lookup('HR_NL_REPORT_LABELS','ERROR');

/*Get concurrent program parameters*/
 PAY_NL_CBS_FILE.get_all_parameters(p_payroll_action_id,
                                          P_business_group_id     =>  l_business_group_id,
                                          P_reporting_date        =>  l_reporting_date,
                                          P_effective_date        =>  l_effective_date,
                                          P_employer              =>  l_employer_id,
                                          P_si_provider           =>  l_si_provider_id,
                                          P_org_struct_id         =>  l_org_struct_id,
                                          P_medium_code           =>  l_medium_code,
                                          P_density               =>  l_density);

	if g_debug then
	 hr_utility.set_location('Executed the cursor in get all parameters ',425);
	 hr_utility.set_location('p_reporting_date'||l_reporting_date,425);
	 hr_utility.set_location('p_employer'||l_employer_id,425);
	 hr_utility.set_location('p_org_struct_id'||l_org_struct_id,425);
	 hr_utility.set_location('p_si_provider'||l_si_provider_id,425);
	 hr_utility.set_location('p_medium_code'||l_medium_code,425);
	 hr_utility.set_location('p_density'||l_density,425);
	 hr_utility.set_location('p_effective_date'||l_effective_date,425);
	 hr_utility.set_location('p_business_group_id'||l_business_group_id,425);
	end if;

l_org_struct_version_id:=pay_nl_taxoffice_archive.get_org_hierarchy(l_org_struct_id,l_reporting_date);
l_frequency := hr_nl_org_info.get_reporting_frequency(l_employer_id);

-- hr_utility.set_location('l_frequency'||l_frequency,425);
if l_frequency = 'K' then
   l_reporting_start_date := ADD_MONTHS(l_reporting_date,-3);
else
   if l_frequency = 'M' then
      l_reporting_start_date := ADD_MONTHS(l_reporting_date,-1);
   else
      if l_frequency = 'P' then
         l_reporting_start_date := l_reporting_date - 28;
      END IF;
   end if;
end if;

-- hr_utility.set_location('l_reporting_start_date'||l_reporting_start_date,425);
l_reporting_end_date := l_reporting_date;
-- hr_utility.set_location('l_reporting_end_date'||l_reporting_end_date,425);


FOR csr_process_rec in csr_process_assignments
(l_business_group_id,
 l_employer_id,
 l_reporting_start_date,
 l_reporting_end_date,
 l_org_struct_version_id,
 l_si_provider_id,
 l_frequency) LOOP

        l_assignment_id := csr_process_rec.assignment_id;
          -- hr_utility.set_location('l_assignment_id'||l_assignment_id,425);
	l_person_id := csr_process_rec.person_id;
          -- hr_utility.set_location('l_person_id'||l_person_id,425);
        l_asg_employer_id := csr_process_rec.organization_id;
         -- hr_utility.set_location('l_asg_employer_id'||l_asg_employer_id,425);
	g_assignment_number:=csr_process_rec.assignment_number;
	g_full_name:=csr_process_rec.full_name;
	l_soft_coding_keyflex_id := csr_process_rec.soft_coding_keyflex_id;
	l_grade_id := csr_process_rec.grade_id;

        g_error_count := 0;
        l_si_provider_check := check_Asg_si_provider(l_asg_employer_id,l_si_provider_id,l_assignment_id);
        -- hr_utility.set_location('l_si_provider_check'||l_si_provider_check,500);
 	-- Fetch maximum assignment action id in the reporting period
	l_max_assgt_act_id := pay_nl_taxoffice_archive.get_max_assgt_act_id(l_assignment_id,l_reporting_start_date,l_reporting_end_date);
        -- hr_utility.set_location('max assignmentid'||l_max_assgt_act_id,600);

        IF (l_si_provider_check = 1 AND l_max_assgt_act_id is not null) THEN
		l_number := get_tax_details(l_max_assgt_act_id,l_wage_tax_discount,l_tax_code,l_labour_relation_code);
		l_income_code := pay_nl_taxoffice_archive.get_income_code(l_assignment_id,l_reporting_start_date,l_reporting_end_date);
		l_health_insurance := get_health_insurance(l_assignment_id,l_reporting_date);
		--l_work_pattern := get_work_pattern(l_soft_coding_keyflex_id);
                       -- hr_utility.set_location('FETCHED HEALTH INSURANCE'||l_health_insurance,400);
		get_working_schedule(l_assignment_id,l_working_schedule,l_reporting_start_date,l_reporting_end_date);
                       -- hr_utility.set_location('FETCHED WORKING SCHEDULE',600);
		l_asg_term :=  check_asg_terminate ( l_assignment_id , l_reporting_start_date );
		                       -- hr_utility.set_location('CHECKED ASG TERM'||l_asg_term,600);

	   if l_asg_term = 1 then

		   l_holiday_hours	:= 0;
		   l_adv_hours		:= 0;
		   l_si_wage		:= 0;
		   l_unique_payments	 := 0;
		   l_pre_tax_deductions  := 0;
		   l_saving_scheme	:= 0;
		   l_sickness_days	:= 0;
		   l_unpaid_hours	:= 0;
		   l_sickness_pay	:= 0;
		   l_overtime_hours	:= 0;
		   l_wage_agreed_by_contract  := 0;
		   l_number_of_days           := 0;
		   l_si_days_quarter          := 0;
		   l_paid_gross_wage	      := 0;
		   l_wage_for_overtime        := 0;

-- Check for the Full sickness wage paid at the org level
          if (hr_nl_org_info.Get_Full_Sickness_Wage_Paid (l_employer_id) <> 'Y')
	  then l_sickness_days := 99;
	       l_sickness_pay := 9999999;
	  end if;
		                       -- hr_utility.set_location('fetched full sickness wage paid'||l_asg_term,600);

           else
	           l_number := get_balances1(l_frequency
					 ,l_max_assgt_act_id
					 ,l_holiday_hours
					 ,l_adv_hours
					 ,l_si_wage
					 ,l_unique_payments
					 ,l_pre_tax_deductions
					 ,l_saving_scheme
					 ,l_sickness_days
					 ,l_unpaid_hours
					 ,l_sickness_pay
					 ,l_overtime_hours );


       -- hr_utility.set_location('l_holiday_hours'||l_holiday_hours,600);

		l_number := get_balances2(l_frequency
					 ,l_max_assgt_act_id
					 ,l_wage_agreed_by_contract
					 ,l_number_of_days
					 ,l_si_days_quarter
					 ,l_paid_gross_wage
					 ,l_wage_for_overtime);

          if (hr_nl_org_info.Get_Full_Sickness_Wage_Paid (l_employer_id) <> 'Y')
	  then l_sickness_days := 99;
	       l_sickness_pay := 9999999;
	  end if;

	   end if;


         -- hr_utility.set_location('l_wage_agreed_by_contract'||l_wage_agreed_by_contract,600);
         get_cao_code(l_assignment_id,l_cao_code,l_reporting_date);
         get_dev_work_hours(l_assignment_id,l_deviating_working_hours,l_reporting_start_date,l_reporting_end_date);

	 l_number:= get_employment_code(l_assignment_id,l_employment_code,l_reporting_start_date,l_reporting_end_date);
	 l_public_sector := hr_nl_org_info.Get_Public_Sector_Org(l_employer_id);
	 l_number := get_grade_salary_number(l_assignment_id,l_business_group_id,l_employer_id,l_grade_id,l_reporting_date
                                            ,l_public_sector,l_grade_number,l_salary_number);
         l_unpaid_hours1 := fnd_number.number_to_canonical(l_unpaid_hours);
	 l_overtime_hours1 := fnd_number.number_to_canonical(l_overtime_hours);

		Mandatory_Check('PAY_NL_EE_REQUIRED_FIELD','NL_EMPLOY_TYPE',l_employment_code);
		Mandatory_Check('PAY_NL_EE_REQUIRED_FIELD','NL_GRADE_NUMBER',l_grade_number);
		Mandatory_Check('PAY_NL_EE_REQUIRED_FIELD','NL_SALARY_NUMBER',l_salary_number);
		Mandatory_Check('PAY_NL_EE_REQUIRED_FIELD','NL_WAGE_TAX_DISC',l_wage_tax_discount);
		Mandatory_Check('PAY_NL_EE_REQUIRED_FIELD','NL_TAX_TABLE',l_tax_code);
		Mandatory_Check('PAY_NL_EE_REQUIRED_FIELD','INCOME_CODE',l_income_code);
		Mandatory_Check('PAY_NL_EE_REQUIRED_FIELD','NL_LABOUR_RELATION',l_labour_relation_code);
		Mandatory_Check('PAY_NL_EE_REQUIRED_FIELD','NL_HEALTH_INSURANCE',l_health_insurance);
		Mandatory_Check('PAY_NL_EE_REQUIRED_FIELD','NL_WORK_SCHEDULE',l_working_schedule);
		Mandatory_Check('PAY_NL_EE_REQUIRED_FIELD','NL_DEV_WORK_HOURS',l_deviating_working_hours);

          l_grade_salary_info := l_grade_number || l_salary_number;
	  l_tax_info := lpad(l_wage_tax_discount,2,'0') || l_tax_code ||l_income_code||lpad(l_labour_relation_code,2,'0');
	  l_work_times := l_working_schedule || l_deviating_working_hours || lpad(to_char(l_holiday_hours),3,'0') || lpad(to_char(l_adv_hours),3,'0') ;

         IF g_error_count = 0 then
            IF l_max_assgt_act_id IS NOT NULL THEN
 	    /*Create the Assignment Action for the Assignments */

	      -- hr_utility.set_location('creating asg_act_id'||l_asg_act_id,600);

	    SELECT pay_assignment_actions_s.NEXTVAL
	    INTO   l_asg_act_id
	    FROM   dual;

	      -- hr_utility.set_location('new l_asg_act_id'||l_asg_act_id,600);
	    --
	    -- Create the archive assignment action
	    --
       	    -- hr_utility.set_location('Before Inserting new assignment action id',600);

	    hr_nonrun_asact.insact(l_asg_act_id,l_Assignment_ID, p_payroll_action_id,p_chunk,NULL);
       	    -- hr_utility.set_location('Inserted new assignment action id',600);
             end if;

          -- hr_utility.set_location('Going to archive the ee data',600);
       	pay_action_information_api.create_action_information
	       ( p_action_information_id           => l_action_info_id
		,p_action_context_id              =>  l_asg_act_id
		,p_action_context_type            => 'AAP'
		,p_object_version_number          => l_ovn
                ,p_effective_date                 => l_reporting_end_date
		,p_source_id                      => NULL
		,p_source_text                    => NULL
		,p_action_information_category    => 'NL CBS EMPLOYEE DETAILS'
		,p_action_information1            =>  l_employer_id
		,p_action_information2            =>  l_si_provider_id
		,p_action_information3            =>  l_assignment_id
		,p_action_information4            =>  l_person_id
		,p_action_information5            =>  l_grade_salary_info
		,p_action_information6            =>  l_tax_info  -- (Wage tax discount,tax table code,Income code,Labour relation code)
		,p_action_information7            =>  l_health_insurance
		,p_action_information8            =>  l_employment_code
		,p_action_information9            =>  l_work_times --(Working schedule,deviating working hours,holiday hours, adv hours)
		,p_action_information10           =>  l_cao_code
		,p_action_information11           =>  l_number_of_days
		,p_action_information12           =>  l_unpaid_hours1
		,p_action_information13           =>  l_overtime_hours1
		,p_action_information14           =>  l_wage_agreed_by_contract
		,p_action_information15           =>  l_paid_gross_wage
		,p_action_information16           =>  l_wage_for_overtime
		,p_action_information17           =>  l_si_wage
		,p_action_information18           =>  l_unique_payments
		,p_action_information19           =>  l_pre_tax_deductions
		,p_action_information20           =>  l_saving_scheme
		,p_action_information21           =>  l_sickness_pay
		,p_action_information22           =>  l_sickness_days
		,p_action_information23           =>  l_si_days_quarter
	 );
   	      -- hr_utility.set_location('Finished the archival process',600);
    END IF;
   END IF;
  END LOOP;
 END ASSIGNMENT_ACTION_CODE;

/********************************************************************************
|Name           : ARCHIVE_INIT                                            	|
|Type		: Procedure							|
|Description    : Procedure sets the global tables g_statutory_balance_table,   |
|		  g_stat_element_table,g_user_balance_table,g_element_table.	|
*********************************************************************************/

Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER) IS
l_dummy number;
BEGIN
  if g_debug then
		   hr_utility.trace_on(NULL,'CBS');
                hr_utility.set_location('Entering ARCHIVE_INIT ',600);
end if;

END ARCHIVE_INIT;

/********************************************************************************
|Name           : ARCHIVE_CODE                                            	|
|Type		: Procedure							|
|Description    : This is the main procedure which calls the several procedures |
|		  to archive the data.						|
*********************************************************************************/

Procedure ARCHIVE_CODE (p_assignment_action_id                 IN NUMBER
	     	       ,p_effective_date                       IN DATE) IS
l_dummy number;
BEGIN

  if g_debug then
		 hr_utility.trace_on(NULL,'CBS');
                 hr_utility.set_location('Entering ARCHIVE_INIT ',600);
end if;

END ARCHIVE_CODE;
end PAY_NL_CBS_FILE;


/
