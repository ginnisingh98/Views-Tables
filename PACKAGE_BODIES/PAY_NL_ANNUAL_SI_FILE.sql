--------------------------------------------------------
--  DDL for Package Body PAY_NL_ANNUAL_SI_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_ANNUAL_SI_FILE" as
/* $Header: pynlasif.pkb 120.0.12000000.1 2007/01/17 22:54:30 appldev noship $ */

g_package  varchar2(33) := ' PAY_NL_ANNUAL_SI_FILE';
g_debug    BOOLEAN;
g_error_flag varchar2(30);
g_warning_flag varchar2(30);
g_error_count NUMBER;
g_payroll_action_id	NUMBER;
g_assignment_number  VARCHAR2(30);
g_full_name	     VARCHAR2(150);
g_message_name VARCHAR2(150) := ' ';


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
                ||' '||RPAD(SUBSTR(v_label_desc,1,30),30)
                ||' '||RPAD(SUBSTR(g_error_flag,1,15),15);
                g_error_count := NVL(g_error_count,0) +1;

                if p_message_name <> g_message_name then
                    hr_utility.set_message(801,p_message_name);
                    v_message_text := rpad(fnd_message.get,255,' ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG,v_message_text);
                    g_message_name := p_message_name;
                end if;

                FND_FILE.PUT_LINE(FND_FILE.LOG, v_employee_dat);
                end if;

end;



/*-----------------------------------------------------------------------------
|Name       : GET_SI_WAGE                                                      |
|Type       : Function							       |
|Description: Function returns SI Wage - sum of SI_INCOME_STANDARD_TAX,        |
|             SI_INCOME_SPECIAL_TAX , RETRO_SI_INCOME_STANDARD_TAX ,           |
|              RETRO_SI_INCOME_SPECIAL_TAX                                     |
|                        SIP,ORG levels                                        |
-------------------------------------------------------------------------------*/

function get_si_wage(p_assgt_act_id number)RETURN number IS
	l_sum_of_balances number;
	l_balance_value number;
	l_defined_balance_id number;
	l_si_wage number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_wage',800);
	end if;

	l_sum_of_balances:=0;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('SI_INCOME_STANDARD_TAX_ASG_YTD');
	--hr_utility.trace('L_DEFINED_BALANCE_ID'||l_defined_balance_id);
	--hr_utility.trace('ASSIGNMENT_ACTION_ID'||p_assgt_act_id);
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

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_SI_INCOME_STANDARD_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('WAGE_IN_MONEY_STANDARD_TAX_ONLY_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('RETRO_SI_INCOME_SPECIAL_TAX_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('WAGE_IN_MONEY_SPECIAL_TAX_ONLY_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_si_wage:=floor(l_sum_of_balances);

	return l_si_wage;

END get_si_wage;


/*-----------------------------------------------------------------------------
|Name       : GET_SI_SUPPLEMENTARY_DAYS                                        |
|Type       : Function							       |
|Description: Function returns SI Supplementary Days -                         |
|             balance SI_SUPPLEMENATRY_DAYS                                    |
-------------------------------------------------------------------------------*/

function get_si_supplementary_days(p_assgt_act_id number)RETURN number IS
	l_sum_of_balances number;
	l_balance_value number;
	l_defined_balance_id number;
	l_si_supplementary_days number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_wage',800);
	end if;

	l_sum_of_balances:=0;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('SI_SUPPLEMENTARY_DAYS_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('SI_SUPPLEMENTARY_DAYS_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_si_supplementary_days:=l_sum_of_balances;

	return l_si_supplementary_days;

END get_si_supplementary_days;

/*-----------------------------------------------------------------------------
|Name       : GET_SI_AMOUNT_ALLOWANCE                                          |
|Type       : Function							       |
|Description: Function returns SI Amount Allowance -                           |
|             balance SI_AMOUNT_ALLOWANCE                                      |
-------------------------------------------------------------------------------*/

function get_si_amount_allowance(p_assgt_act_id number)RETURN number IS
	l_sum_of_balances number;
	l_balance_value number;
	l_defined_balance_id number;
	l_si_amount_allowance number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_wage',800);
	end if;

	l_sum_of_balances:=0;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('SI_AMOUNT_ALLOWANCE_ASG_YTD');
	l_balance_value:=pay_balance_pkg.get_value(l_defined_balance_id,p_assgt_act_id);
	l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('SI_AMOUNT_ALLOWANCE_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_si_amount_allowance:=floor(l_sum_of_balances);

	return l_si_amount_allowance;

END get_si_amount_allowance;

function get_org_name(p_org_id number
                      ,l_org_name OUT NOCOPY VARCHAR2)RETURN NUMBER IS
cursor csr_get_org_name(p_org_id NUMBER) IS
SELECT name from hr_organization_units
where organization_id = p_org_id;

l_number NUMBER;

BEGIN
OPEN csr_get_org_name(p_org_id);
FETCH csr_get_org_name INTO l_org_name;
CLOSE csr_get_org_name;

l_number := 1;
return l_number;

END get_org_name;



/*-----------------------------------------------------------------------------
|Name       : GET_SI_SPECIAL_INDICATOR                                         |
|Type       : Procedure 						       |
|Description: Function fetches the SI Special Indicator                        |
-------------------------------------------------------------------------------*/

PROCEDURE get_si_special_indicator(p_assignment_id IN NUMBER,
                                  l_si_special_indicator OUT NOCOPY VARCHAR2 )IS
CURSOR get_scl_id(p_assignment_id NUMBER) IS
SELECT soft_coding_keyflex_id FROM per_all_assignments_f
WHERE assignment_id = p_assignment_id AND
effective_start_date =
(SELECT max(effective_start_date)
FROM per_all_assignments_f asg,per_assignment_status_types past
WHERE past.per_system_status = 'ACTIVE_ASSIGN'
AND asg.assignment_status_type_id = past.assignment_status_type_id and assignment_id = p_assignment_id);

CURSOR get_si_special_indicator(p_scl_id NUMBER) IS
SELECT segment30 from hr_soft_Coding_keyflex where soft_coding_keyflex_id = p_scl_id;

l_scl_id NUMBER;


BEGIN

OPEN get_scl_id(p_assignment_id);
FETCH get_scl_id into l_scl_id;
CLOSE get_scl_id;

OPEN get_si_special_indicator(l_scl_id);
FETCH get_si_special_indicator INTO l_si_special_indicator;
CLOSE get_si_special_indicator;

IF l_si_special_indicator IS NULL THEN
   l_si_special_indicator :='00';
END IF;

END get_si_special_indicator;

/*-----------------------------------------------------------------------------
|Name       : GET_NUMBER_OF_DAYS                                               |
|Type       : Function							       |
|Description: Function returns Number Of Days -                                |
|             balance REAL_SOCIAL_INSURANCE_DAYS                               |
-------------------------------------------------------------------------------*/

function get_number_of_days(p_assgt_act_id number)RETURN number IS

CURSOR csr_get_context_id(p_context_name  		VARCHAR2
			 ,p_assignment_action_id	NUMBER) IS
SELECT ff.context_id     context_id
      ,pact.context_value   context_value
      , decode(context_value,'ZFW',0,'ZW',1,
               'WEWE',2,'WEWA',3,'WAOD',4,'WAOB',5,6) seq
FROM   ff_contexts         ff
      ,pay_action_contexts pact
WHERE  ff.context_name   = p_context_name
AND    pact.context_id   = ff.context_id
AND    pact.assignment_action_id=p_assignment_action_id
ORDER  BY decode(context_value,'ZFW',0,'ZW',1,
          'WEWE',2,'WEWA',3,'WAOD',4,'WAOB',5,6);

l_context_id			NUMBER;
l_context_value			pay_action_contexts.context_value%TYPE;
l_seq				VARCHAR2(60);
l_sum_of_balances number;
l_balance_value number;
l_defined_balance_id number;
l_si_amount_allowance number;
l_number_of_days number;

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_wage',800);
	end if;

	l_sum_of_balances:=0;


	l_defined_balance_id:=pay_nl_general.get_defined_balance_id('REAL_SOCIAL_INSURANCE_DAYS_ASG_SIT_YTD');
	OPEN csr_get_context_id('SOURCE_TEXT',p_assgt_act_id);
	FETCH csr_get_context_id INTO l_context_id,l_context_value,l_seq;
	CLOSE csr_get_context_id;

	IF l_context_id IS NOT NULL THEN
		l_balance_value := pay_balance_pkg.get_value(l_defined_balance_id
		                       			       ,p_assgt_act_id
							       ,NULL
							       ,NULL
							       ,l_context_id
							       ,l_context_value
							       ,NULL
							       ,NULL);
	END IF;
        l_sum_of_balances:=l_sum_of_balances + l_balance_value;

	if g_debug then
		hr_utility.set_location('SI_AMOUNT_ALLOWANCE_ASG_YTD',425);
		hr_utility.set_location('l_defined_balance_id'||l_defined_balance_id,425);
		hr_utility.set_location('l_balance_value'||l_balance_value,425);
		hr_utility.set_location('l_sum_of_balances'||l_sum_of_balances,425);
	end if;

	l_number_of_days:=floor(l_sum_of_balances);

	return l_number_of_days;

END get_number_of_days;

/*-----------------------------------------------------------------------------
|Name       : Get_SIP_Details                                                  |
|Type       : Function		                               		       |
|Description: Procedure gets Reg Number , reporting name details at            |
|                        SIP level                                             |
-------------------------------------------------------------------------------*/
FUNCTION Get_SIP_Details
( P_Employer_ID IN NUMBER
 ,P_SI_PROVIDER_ID IN NUMBER
 ,P_Process_Date IN DATE
 ,p_Sender_Rep_Name_sip OUT NOCOPY VARCHAR2
 ,p_Sender_Reg_Number_sip OUT NOCOPY VARCHAR2
 ,p_Employer_Rep_Name_sip OUT NOCOPY VARCHAR2
 ,p_Employer_Reg_Number_sip OUT NOCOPY VARCHAR2
 ) RETURN NUMBER IS
--

   CURSOR csr_sip_details(p_employer_id NUMBER , p_si_provider_id NUMBER) IS
   SELECT org_information8 SRepName,org_information9 SRegNo,
   org_information10 ERRepName,org_information11 ERRegNo,
   DECODE(org_information3,'ZFW',1,'ZW',2,'WW',3,'WAO',4,'AMI',5,6) sort_order
   FROM hr_organization_information
   where organization_id = p_employer_id
   and org_information_context = 'NL_SIP'
   and org_information4 = p_si_provider_id
   AND p_process_date between
   FND_DATE.CANONICAL_TO_DATE(org_information1) and
   nvl(FND_DATE.CANONICAL_TO_DATE(org_information2),hr_general.end_of_time)
   ORDER BY ORG_INFORMATION7,DECODE(org_information3,'ZFW',1,'ZW',2,'WW',3,'WAO',4,'AMI',5,6) ;

   l_number NUMBER;
   l_si_type number;

 BEGIN


  OPEN csr_sip_details(p_employer_id,p_si_provider_id);
  FETCH csr_sip_details INTO p_Sender_Rep_Name_sip,p_Sender_Reg_Number_sip,
                             p_Employer_Rep_Name_sip,p_Employer_Reg_Number_sip,l_si_type;
  CLOSE csr_sip_details;
  l_number := 1;
  return l_number;

 END;


/*-----------------------------------------------------------------------------
|Name       : GET_ALL_PARAMETERS                                               |
|Type       : Procedure							                               |
|Description: Procedure which returns all the parameters of the archive	process|
-------------------------------------------------------------------------------*/


-----------------------------------------------------------------------------
-- GET_ALL_PARAMETERS gets all parameters for the payroll action
-----------------------------------------------------------------------------
PROCEDURE get_all_parameters (
          p_payroll_action_id     IN         NUMBER
         ,p_business_group_id     OUT NOCOPY NUMBER
         ,p_si_provider_id        OUT NOCOPY NUMBER
         ,p_effective_date        OUT NOCOPY DATE
         ,p_tax_year              OUT NOCOPY DATE
         ,p_employer              OUT NOCOPY NUMBER
         ,p_org_struct_id         OUT NOCOPY NUMBER  ) IS
--
  CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
  SELECT fnd_date.canonical_to_date(pay_core_utils.get_parameter('TAX_YEAR',legislative_parameters))
        ,pay_core_utils.get_parameter('EMPLOYER_ID',legislative_parameters)
        ,pay_core_utils.get_parameter('ORG_HIERARCHY',legislative_parameters)
        ,pay_core_utils.get_parameter('SI_PROVIDER_ID',legislative_parameters)
        ,effective_date
        ,business_group_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
--
  l_effective_date date;
  l_proc VARCHAR2(80):= g_package||' get_all_parameters ';
--
BEGIN
  --
  OPEN csr_parameter_info (p_payroll_action_id);
  FETCH csr_parameter_info INTO
  p_tax_year,p_employer, p_org_struct_id,p_si_provider_id
 ,p_effective_date,p_business_group_id;
  CLOSE csr_parameter_info;
  --
  --hr_utility.trace('YEAR'||p_tax_year);
  --hr_utility.trace('EMPLOYER'||p_employer);
  --hr_utility.trace('ORG STRUCT'||p_org_struct_id);
  --hr_utility.trace('EFFECTIVE_DATE'||p_effective_date);
  --hr_utility.trace('BUSINESS_GROUP'||p_business_group_id);
END get_all_parameters;
--

/*--------------------------------------------------------------------
|Name       : RANGE_CODE                                       	    |
|Type		: Procedure							                      |
|Description: This procedure returns a sql string to select a range of|
|		  assignments eligible for archival
----------------------------------------------------------------------*/

Procedure RANGE_CODE (pactid    IN    NUMBER
                     ,sqlstr    OUT   NOCOPY VARCHAR2) is

v_log_header   VARCHAR2(255);
l_number number;
l_return_value number;
l_business_group_id NUMBER;
l_si_provider_id NUMBER;
l_effective_date DATE;
l_tax_year_date DATE;
l_tax_year  NUMBER;
l_tax_year_start_date date;
l_tax_year_end_date date;
l_employer_id NUMBER;
l_org_struct_id NUMBER;
l_max_assgt_act_id NUMBER;
l_asg_act_id NUMBER;
l_Sender_Rep_Name_sip VARCHAR2(100);
l_Sender_Reg_Number_sip VARCHAR2(100);
l_Employer_Rep_Name_sip VARCHAR2(100);
l_Employer_Reg_Number_sip VARCHAR2(100);
l_Wage_Tax_Reg_Number_org VARCHAR2(100);
l_Wage_Tax_Rep_Name_org  VARCHAR2(100);
l_Sender_Rep_Name_bg VARCHAR2(100);
l_Sender_Reg_Number_bg VARCHAR2(100);
l_org_struct_version_id NUMBER;
l_assignment_id NUMBER;
l_ovn NUMBER;
l_ASI_Process_Date DATE;
l_action_info_id NUMBER;
l_si_wage NUMBER;
l_si_supplementary_days NUMBER;
l_si_amount_allowance NUMBER;
l_si_special_indicator VARCHAR2(10);
l_number_of_days NUMBER;
l_person_id NUMBER;

l_org_address number;
l_house_number varchar2(255);
l_house_no_add varchar2(255);
l_street_name varchar2(255);
l_line1 varchar2(255);
l_line2 varchar2(255);
l_line3 varchar2(255);
l_city varchar2(255);
l_country varchar2(255);
l_postal_code varchar2(255);

l_sender_address number;
l_sen_house_number varchar2(255);
l_sen_house_no_add varchar2(255);
l_sen_street_name varchar2(255);
l_sen_line1 varchar2(255);
l_sen_line2 varchar2(255);
l_sen_line3 varchar2(255);
l_sen_city varchar2(255);
l_sen_country varchar2(255);
l_sen_postal_code varchar2(255);
l_sender_address_field varchar2(255);
l_sen_city_field varchar2(255);
l_tax_address_field varchar2(255);
l_tax_city_field varchar2(255);

BEGIN

g_error_count  := 0;
g_payroll_action_id:=pactid;


/*Return the SELECT Statement to select a range of assignments
eligible for archival */

get_all_parameters
          (
          pactid,
          l_business_group_id,
          l_si_provider_id,
          l_effective_date,
          l_tax_year_date,
          l_employer_id,
          l_org_struct_id
          );

l_tax_year := to_char(l_tax_year_date,'YYYY');
l_tax_year_start_date := to_date('01/01/'||l_tax_year,'DD/MM/YYYY');
l_tax_year_end_date := to_date('31/12/'||l_tax_year,'DD/MM/YYYY');
l_org_struct_version_id:=pay_nl_taxoffice_archive.get_org_hierarchy(l_org_struct_id,l_tax_year_end_date);
l_ASI_Process_Date := l_tax_year_end_date;


--hr_utility.trace(l_tax_year_start_date);
--hr_utility.trace(l_tax_year_end_date);
--hr_utility.trace(l_ASI_Process_Date);

l_return_value := Get_SIP_Details
( l_Employer_ID
 ,l_SI_PROVIDER_ID
 ,l_ASI_Process_Date
 ,l_Sender_Rep_Name_sip
 ,l_Sender_Reg_Number_sip
 ,l_Employer_Rep_Name_sip
 ,l_Employer_Reg_Number_sip
 );

l_return_value := PAY_NL_TAXOFFICE_FILE.GET_TOS_SENDER_DETAILS
(l_Business_Group_Id,
 l_Employer_ID,
 l_Sender_Rep_Name_bg,
 l_Sender_Reg_Number_bg,
 l_Wage_Tax_Rep_Name_org,
 l_Wage_Tax_Reg_Number_org);

l_org_address:=PAY_NL_GENERAL.GET_ORGANIZATION_ADDRESS(l_employer_id,l_business_group_id,l_house_number,l_house_no_add,l_street_name,l_line1,l_line2,l_line3,l_city,l_country,l_postal_code);
l_sender_address:=PAY_NL_GENERAL.GET_ORGANIZATION_ADDRESS(l_business_group_id,l_business_group_id,l_sen_house_number,l_sen_house_no_add,l_sen_street_name,l_sen_line1,l_sen_line2,l_sen_line3,l_sen_city,l_sen_country,l_sen_postal_code);

l_sender_address_field := l_sen_street_name || l_sen_house_number || l_sen_house_no_add;
l_sen_city_field := l_sen_postal_code || l_sen_city;
l_tax_address_field := l_street_name || l_house_number || l_house_no_add;
l_tax_city_field := l_postal_code || l_city;



Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_ADDR',l_sender_address_field);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_CITY',l_sen_city_field);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_REG_NUM',l_Sender_Reg_Number_bg);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_ER_ADDR',l_tax_address_field);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_CITY',l_tax_city_field);
Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_TAX_REGISTRATION_NUMBER',l_Wage_Tax_Reg_Number_org);
Mandatory_Check('PAY_NL_SIP_REQUIRED_FIELD','NL_ER_REG_NUMBER',l_Employer_Reg_Number_sip);
Mandatory_Check('PAY_NL_SIP_REQUIRED_FIELD','NL_SEN_REP_NAME',l_Sender_Rep_Name_sip);
Mandatory_Check('PAY_NL_SIP_REQUIRED_FIELD','NL_SENDER_REG_NUM',l_Sender_Reg_Number_sip);
Mandatory_Check('PAY_NL_SIP_REQUIRED_FIELD','NL_ER_REP_NAME',l_Employer_Rep_Name_sip);

IF g_error_count=0 THEN
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


ELSE
       sqlstr := 'SELECT DISTINCT person_id
       FROM  per_people_f ppf
       ,pay_payroll_actions ppa
       WHERE ppa.payroll_action_id = :payroll_action_id
       AND   1 = 2
       AND   ppa.business_group_id = ppf.business_group_id
       ORDER BY ppf.person_id';
END IF;


END RANGE_CODE;


/*--------------------------------------------------------------------
|Name       : ASSIGNMENT_ACTION_CODE  	                            |
|Type		: Procedure				            |
|Description: This procedure Fetches,validates and archives	    |
|	      information in the newly created context 		    |
|	      NL ATS EMPLOYEE DETAILS				    |
----------------------------------------------------------------------*/

Procedure ASSIGNMENT_ACTION_CODE (p_payroll_action_id  in number
				  ,p_start_person_id   in number
				  ,p_end_person_id     in number
				  ,p_chunk             in number) IS


Cursor csr_process_assignments
(p_business_group_id number,
 p_employer_id number,
 p_tax_year_date date,
 p_tax_year_start_date date,
 p_tax_year_end_date date,
 p_org_struct_version_id number,
 p_si_provider_id number
)
is
Select
        paa.organization_id,
        paa.soft_coding_keyflex_id,
        pap.person_id,
        paa.assignment_id,
        pap.last_name,
        paa.assignment_number,
        pap.full_name,
        pap.Date_of_Birth,
        pap.national_identifier
from
 per_all_people_f pap
,per_all_assignments_f paa
,hr_soft_coding_keyflex scl_flx
where
pap.business_group_id =p_business_group_id
and pap.person_id = paa.person_id
and paa.person_id BETWEEN p_start_person_id AND p_end_person_id
and scl_flx.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
and p_Tax_Year_End_Date between pap.effective_start_date and pap.effective_end_date
and paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM per_assignment_status_types past, per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   past.per_system_status = 'ACTIVE_ASSIGN'
		and   asg.assignment_status_type_id = past.assignment_status_type_id
		and   asg.effective_start_date <= p_Tax_Year_End_Date
		and   nvl(asg.effective_end_date, p_Tax_Year_End_Date) >= p_Tax_Year_Start_Date
		)
and p_employer_id in
(select hr_nl_org_info.get_tax_org_id(p_org_struct_version_id,paa.organization_id) from dual)
and not exists
(select 1
from
pay_action_information ee_ats
WHERE ee_ats.action_context_type='AAP'
AND ee_ats.action_information_category = 'NL ASI EMPLOYEE DETAILS'
AND ee_ats.action_information1  =p_employer_id
AND ee_ats.action_information4  =pap.person_id
AND ee_ats.action_information2  =paa.assignment_id
AND ee_ats.action_information3  =p_si_provider_id
AND ee_ats.effective_date          =p_tax_year_end_date)
AND
(p_si_provider_id = HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(paa.organization_id,'ZFW',paa.assignment_id)
 OR p_si_provider_id = HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(paa.organization_id,'ZW',paa.assignment_id)
 OR p_si_provider_id = HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(paa.organization_id,'WEWE',paa.assignment_id)
 OR p_si_provider_id = HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(paa.organization_id,'WEWA',paa.assignment_id)
 OR p_si_provider_id = HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(paa.organization_id,'WAOB',paa.assignment_id)
 OR p_si_provider_id = HR_NL_ORG_INFO.GET_SI_PROVIDER_INFO(paa.organization_id,'WAOD',paa.assignment_id)
);


l_number number;
l_return_value number;
l_business_group_id NUMBER;
l_si_provider_id NUMBER;
l_effective_date DATE;
l_tax_year_date DATE;
l_tax_year  NUMBER;
l_tax_year_start_date date;
l_tax_year_end_date date;
l_employer_id NUMBER;
l_org_struct_id NUMBER;
l_max_assgt_act_id NUMBER;
l_asg_act_id NUMBER;
l_org_struct_version_id NUMBER;
l_assignment_id NUMBER;
l_ovn NUMBER;
l_ASI_Process_Date DATE;
l_action_info_id NUMBER;
l_si_wage NUMBER;
l_si_supplementary_days NUMBER;
l_si_amount_allowance NUMBER;
l_si_special_indicator VARCHAR2(10);
l_number_of_days NUMBER;
l_person_id NUMBER;



BEGIN

g_error_flag := hr_general.decode_lookup('HR_NL_REPORT_LABELS','ERROR');

get_all_parameters
          (
          p_payroll_action_id,
          l_business_group_id,
          l_si_provider_id,
          l_effective_date,
          l_tax_year_date,
          l_employer_id,
          l_org_struct_id
          );

l_tax_year := to_char(l_tax_year_date,'YYYY');
l_tax_year_start_date := to_date('01/01/'||l_tax_year,'DD/MM/YYYY');
l_tax_year_end_date := to_date('31/12/'||l_tax_year,'DD/MM/YYYY');
l_org_struct_version_id:=pay_nl_taxoffice_archive.get_org_hierarchy(l_org_struct_id,l_tax_year_end_date);
l_ASI_Process_Date := l_tax_year_end_date;


--hr_utility.trace(l_tax_year_start_date);
--hr_utility.trace(l_tax_year_end_date);
--hr_utility.trace(l_ASI_Process_Date);



    FOR process_rec in csr_process_assignments
   (l_business_group_id ,
    l_employer_id ,
    l_tax_year_date ,
    l_tax_year_start_date ,
    l_tax_year_end_date ,
    l_org_struct_version_id ,
    l_si_provider_id ) LOOP

 	l_assignment_id := process_rec.assignment_id;
 	l_person_id := process_rec.person_id;
 	g_assignment_number:=process_rec.assignment_number;
	g_full_name:=process_rec.full_name;
        g_error_count := 0;
 	-- Fetch Action to be locked into l_max_assgt_act_id

	l_max_assgt_act_id := pay_nl_taxoffice_archive.get_max_assgt_act_id(l_assignment_id,l_tax_year_start_date,l_tax_year_end_date);
	IF l_max_assgt_act_id IS NOT NULL THEN
 	/*Create the Assignment Action for the Assignment
	and Lock the Latest Payroll Run Assignment Action for the Assignment
	*/
	SELECT pay_assignment_actions_s.NEXTVAL
	INTO   l_asg_act_id
	FROM   dual;
	--
	-- Create the archive assignment action
	--
	hr_nonrun_asact.insact(l_asg_act_id,l_Assignment_ID, p_payroll_action_id,p_chunk,NULL);


	--hr_utility.trace('ASSIGNMENT_DETAILS'||TO_CHAR(l_assignment_id)||' '||to_char(l_max_assgt_act_id));

	-- Now Create the locking actions
	IF l_max_assgt_act_id IS NOT NULL THEN
	   hr_nonrun_asact.insint(l_asg_act_id,l_max_assgt_act_id);
	END IF;


	/*Archive the Employee Fiscal Record Details in the
	NL ATS EMPLOYEE DETAILS Context of the Pay Action Information Table
	*/

	/* Obtain the following

	      l_number_of_days := Sum of balances as specified in the earlier details table.
	      l_si_wage := Sum of balances as specified
	      l_sup_days:=Balance value of SI Supplementary Days
	      l_allowance_amount := Balance value of SI Amount Allowance
	      l_spl_indicator := New Code Special Indicator  */

	l_si_wage := NVL(PAY_NL_ANNUAL_SI_FILE.get_si_wage(l_max_assgt_act_id),0);
	l_si_supplementary_days := NVL(PAY_NL_ANNUAL_SI_FILE.get_si_supplementary_days(l_max_assgt_act_id),0);
	l_si_amount_allowance := NVL(PAY_NL_ANNUAL_SI_FILE.get_si_amount_Allowance(l_max_assgt_act_id),0);
	PAY_NL_ANNUAL_SI_FILE.get_si_special_indicator(l_assignment_id,l_si_special_indicator);
	l_number_of_days := NVL(PAY_NL_ANNUAL_SI_FILE.get_number_of_days(l_max_assgt_act_id),0);
	--hr_utility.trace('NUMBER OF DAYS'||to_char(l_number_of_days));

	pay_action_information_api.create_action_information
	(
		p_action_information_id      => l_action_info_id
		,p_action_context_id         => l_asg_act_id
		,p_action_context_type       => 'AAP'
		,p_object_version_number     => l_ovn
		,p_effective_date            => l_ASI_Process_Date
		,p_source_id                 => NULL
		,p_source_text               => NULL
		,p_action_information_category  => 'NL ASI EMPLOYEE DETAILS'
		,p_action_information1          =>  l_employer_id
		,p_action_information2          =>  l_assignment_id
		,p_action_information3          =>  l_si_provider_id
		,p_action_information4          =>  l_person_id
		,p_action_information5          =>  fnd_number.number_to_canonical(l_number_of_days)
		,p_action_information6          =>  fnd_number.number_to_canonical(l_si_wage)
		,p_action_information7          =>  fnd_number.number_to_canonical(l_si_supplementary_days)
		,p_action_information8          =>  fnd_number.number_to_canonical(l_si_amount_allowance)
		,p_action_information9          =>  fnd_number.number_to_canonical(l_si_special_indicator)
	 );

     END IF;
    END LOOP;




END;

/*----------------------------------------------------------------------------------
|Name           : ARCHIVE_INIT                                            	   |
|Type		    : Procedure							   |
|Description    : Initialization Code for Archiver				   |
-----------------------------------------------------------------------------------*/

Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER)IS
l_number number;
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

Procedure ARCHIVE_CODE (p_assignment_action_id                 IN NUMBER
	     	       ,p_effective_date                       IN DATE) IS
l_number number;
BEGIN
       if g_debug then

		hr_utility.set_location('Entering Archive Code',700);
		hr_utility.set_location('Leaving Archive Code',700);
	end if;

END ARCHIVE_CODE;




END PAY_NL_ANNUAL_SI_FILE;

/
