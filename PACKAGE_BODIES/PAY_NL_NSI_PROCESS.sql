--------------------------------------------------------
--  DDL for Package Body PAY_NL_NSI_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_NSI_PROCESS" as
/* $Header: pynlnsia.pkb 120.1 2005/09/26 05:09:24 summohan noship $ */
g_package  varchar2(33) := ' PAY_NL_NSI_PROCESS.';


g_error_flag varchar2(30);
g_warning_flag varchar2(30);
g_error_count NUMBER := 0;
g_payroll_action_id	NUMBER;
g_assignment_number  VARCHAR2(30);
g_full_name			 VARCHAR2(150);

/*------------------------------------------------------------------------------
|Name           : GET_PARAMETER    					                           |
|Type		    : Function							                           |
|Description    : Funtion to get the parameters of the archive process     	   |
-------------------------------------------------------------------------------*/

function get_parameter(
         p_parameter_string in varchar2
        ,p_token            in varchar2
        ,p_segment_number   in number default null )    RETURN varchar2
IS

	l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
	l_start_pos  NUMBER;
	l_delimiter  varchar2(1):=' ';
	l_proc VARCHAR2(40):= g_package||' get parameter ';

BEGIN
	--
	hr_utility.set_location('Entering get_parameter',52);
	--
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
END get_parameter;

/*-----------------------------------------------------------------------------
|Name       : GET_ALL_PARAMETERS                                               |
|Type       : Procedure							                               |
|Description: Procedure which returns all the parameters of the archive	process|
-------------------------------------------------------------------------------*/


PROCEDURE get_all_parameters(
       p_payroll_action_id      IN   	    NUMBER
      ,p_business_group_id      OUT  NOCOPY NUMBER
      ,p_employer_id		OUT  NOCOPY VARCHAR2
      ,p_si_provider_id		OUT  NOCOPY VARCHAR2
      ,p_nsi_month              OUT  NOCOPY VARCHAR2
      ,p_output_media_type	OUT  NOCOPY VARCHAR2
      ,p_payroll_id             OUT  NOCOPY VARCHAR2
      ,p_withdraw_asg_set_id    OUT  NOCOPY VARCHAR2
      ,p_report_type            OUT NOCOPY VARCHAR2) IS
	--
	CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS

	SELECT
		PAY_NL_NSI_PROCESS.get_parameter(legislative_parameters,'EMPLOYER_ID')
		,PAY_NL_NSI_PROCESS.get_parameter(legislative_parameters,'SI_PROVIDER_ID')
		,PAY_NL_NSI_PROCESS.get_parameter(legislative_parameters,'NSI_MONTH')
		,PAY_NL_NSI_PROCESS.get_parameter(legislative_parameters,'OUTPUT_MEDIA_TYPE')
		,PAY_NL_NSI_PROCESS.get_parameter(legislative_parameters,'PAYROLL_ID')
		,PAY_NL_NSI_PROCESS.get_parameter(legislative_parameters,'WITHDRAW_ASG_SET_ID')
		,business_group_id
		,report_type
	FROM  pay_payroll_actions
	WHERE payroll_action_id = p_payroll_action_id;

	--

	l_proc VARCHAR2(240):= g_package||' get_all_parameters ';
	--
BEGIN
	--
	  hr_utility.set_location('Entering get_all_parameters',51);

	OPEN csr_parameter_info (p_payroll_action_id);
	FETCH csr_parameter_info INTO
		p_employer_id,p_si_provider_id,p_nsi_month
		,p_output_media_type,p_payroll_id,p_withdraw_asg_set_id
		,p_business_group_id,p_report_type;
	CLOSE csr_parameter_info;
	--
	hr_utility.set_location('Leaving get_all_parameters',54);

END get_all_parameters;

/*-------------------------------------------------------------------------------
|Name           : get_country_name                                           	|
|Type		: Function							|
|Description    : Function to get the country name from FND_TERRITORIES_VL	|
-------------------------------------------------------------------------------*/

FUNCTION get_country_name(p_territory_code VARCHAR2) RETURN VARCHAR2 IS
	CURSOR csr_get_territory_name(p_territory_code VARCHAR2) Is
	SELECT TERRITORY_SHORT_NAME
	FROM FND_TERRITORIES_VL
	WHERE TERRITORY_CODE = p_territory_code;

	l_country FND_TERRITORIES_VL.TERRITORY_SHORT_NAME%TYPE;
BEGIN
	OPEN csr_get_territory_name(p_territory_code);
	FETCH csr_get_territory_name into l_country;
	CLOSE csr_get_territory_name;
RETURN l_country;
END;/*-------------------------------------------------------------------------------
|Name           : Mandatory_Check                                           	|
|Type			: Procedure							                            |
|Description    : Procedure to check if the specified Mandatory Field is NULL   |
|                 if so flag a Error message to the Log File                    |
-------------------------------------------------------------------------------*/

Procedure Mandatory_Check(p_message_name varchar2,p_field varchar2,p_value varchar2) is
	v_message_text fnd_new_messages.message_text%TYPE;
	v_employee_dat VARCHAR2(255);
	v_label_desc   hr_lookups.meaning%TYPE;
Begin
		hr_utility.set_location('Checking Field '||p_field,425);
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
/*-------------------------------------------------------------------------------
|Name           : RANGE_CODE                                       		         |
|Type		: Procedure							                                 |
|Description    : This procedure returns a sql string to select a range of 	     |
|		  assignments eligible for archival		  		                         |
-------------------------------------------------------------------------------*/

Procedure RANGE_CODE (pactid    IN    NUMBER
                     ,sqlstr    OUT   NOCOPY VARCHAR2) is

	--Fetch Org Address - Sender (BG) /Employer
	CURSOR csr_get_address(p_organization_id NUMBER) IS
	SELECT hr_org.NAME                  name
		  ,hr_loc.style		            style
		  ,hr_loc.loc_information14     House_Num
		  ,hr_loc.loc_information15     House_Num_Add
		  ,hr_loc.region_1              street_name
		  ,pay_nl_general.get_postal_code(hr_loc.postal_code)           postal_code
		  ,hr_general.decode_lookup('HR_NL_CITY', hr_loc.town_or_city) city
	FROM   hr_organization_units    hr_org
		  ,hr_locations             hr_loc
	WHERE  hr_org.organization_id   = p_organization_id
	AND    hr_org.location_id    = hr_loc.location_id (+);
	v_csr_get_address  csr_get_address%ROWTYPE;
	v_csr_get_address1 csr_get_address%ROWTYPE;

	v_House_Number   VARCHAR2(15);

	--Fetch Rep Name /Reg Name from HR Org -> Dutch SI Provider
	CURSOR csr_get_sender_det(p_organization_id NUMBER
							,p_si_provider_id NUMBER
							,p_nsi_process_date date) IS
	SELECT
			  DECODE(hoi.org_information3,'ZFW',1,'ZW',2,'WW',3,'WAO',4,'AMI',5,6) sort_order
	        ,hoi.org_information8     Sender_Rep_Name
			,hoi.org_information9     Sender_Reg_Number
			,hoi.org_information10    Employer_Rep_Name
			,hoi.org_information11    Employer_Reg_Number
	FROM   hr_organization_information    hoi
	WHERE  hoi.org_information_context='NL_SIP'
	AND hoi.organization_id  = p_organization_id
	AND hoi.org_information4 = p_si_provider_id
	AND hoi.org_information3 IN('ZFW','ZW','WW','WAO','AMI')
	AND p_nsi_process_date between
	FND_DATE.CANONICAL_TO_DATE(hoi.org_information1) and
    nvl(FND_DATE.CANONICAL_TO_DATE(hoi.org_information2),hr_general.end_of_time)
    ORDER BY ORG_INFORMATION7,DECODE(hoi.org_information3,'ZFW',1,'ZW',2,'WW',3,'WAO',4,'AMI',5,6) ;
	v_csr_get_sender_det csr_get_sender_det%ROWTYPE;
	--
	--
	l_business_group_id	NUMBER;
	l_employer_id		NUMBER;
	l_si_provider_id	NUMBER;
	l_nsi_month         	VARCHAR2(10);
	l_output_media_type		VARCHAR2(10);
	l_payroll_id		NUMBER;
	l_withdraw_asg_set_id   NUMBER;
	l_report_type      pay_payroll_actions.report_type%TYPE;
	--

	--
	l_Sender_Reg_Number    VARCHAR2(15);
	l_NSI_Process_Date     DATE;
	l_Sender_Report_Name   VARCHAR2(22);
	l_Sender_Address       VARCHAR2(150);
	l_Employer_Name        VARCHAR2(22);
	l_Employer_Address     VARCHAR2(150);

	l_Employer_Reg_Number  VARCHAR2(15);

	l_action_info_id       NUMBER;
	l_ovn                  NUMBER;
	l_effective_date       DATE;

	v_log_header   VARCHAR2(255);

Begin

	--
	--hr_utility.trace_on(NULL,'NL_NSI');
	hr_utility.set_location('Entering Range Code',50);
	--
  	--

	g_error_count  := 0;
  	g_payroll_action_id:=pactid;

	PAY_NL_NSI_PROCESS.get_all_parameters
		(p_payroll_action_id    =>  pactid
		,p_business_group_id    =>  l_business_group_id
		,p_employer_id		=>  l_employer_id
		,p_si_provider_id	=>  l_si_provider_id
		,p_nsi_month            =>  l_nsi_month
		,p_output_media_type	=>  l_output_media_type
		,p_payroll_id           =>  l_payroll_id
		,p_withdraw_asg_set_id  =>  l_withdraw_asg_set_id
		,p_report_type          =>  l_report_type
		);

	hr_utility.set_location('g_payroll_action_id    = ' || g_payroll_action_id,55);
	hr_utility.set_location('NSI Archive p_payroll_action_id '||pactid,425);
	hr_utility.set_location('NSI Archive l_business_group_id '||l_business_group_id,425);
	hr_utility.set_location('NSI Archive l_employer_id '||l_employer_id,425);
	hr_utility.set_location('NSI Archive l_si_provider_id '||l_si_provider_id,425);
	hr_utility.set_location('NSI Archive l_nsi_month '||l_nsi_month,425);
	hr_utility.set_location('NSI Archive l_payroll_id '||l_payroll_id,425);
	hr_utility.set_location('NSI Archive l_withdraw_asg_set_id '||l_withdraw_asg_set_id,425);
	hr_utility.set_location('NSI Archive l_NSI_Process_Date '||l_NSI_Process_Date,425);
	hr_utility.set_location('NSI Archive l_report_type '||l_report_type,425);
	--

	--Determine the Process Dates
	l_NSI_Process_Date := LAST_DAY(TO_DATE('01'||l_nsi_month,'DDMMYYYY'));


	--Determine Sender Reporting Name/Reg Num/ER Rep Name/ER Reg Num
	OPEN csr_get_sender_det( l_employer_id,l_si_provider_id,l_NSI_Process_Date);
	FETCH csr_get_sender_det INTO v_csr_get_sender_det;
	IF csr_get_sender_det%FOUND THEN
		l_Sender_Reg_Number := LPAD(v_csr_get_sender_det.Sender_Reg_Number,15,'0') ;
		l_Sender_Report_Name:= RPAD(v_csr_get_sender_det.Sender_Rep_Name,22) ;
		l_Employer_Name:= RPAD(v_csr_get_sender_det.Employer_Rep_Name,22) ;
		l_Employer_Reg_Number	:= LPAD(v_csr_get_sender_det.Employer_Reg_Number,15,'0');
	END IF;
	CLOSE csr_get_sender_det;
	l_Sender_Report_Name := UPPER(RPAD(NVL(l_Sender_Report_Name,' '),22));
	l_Employer_Name := UPPER(RPAD(NVL(l_Employer_Name,' '),22));
	--hr_utility.set_location('l_Sender_Reg_Number :'||l_Sender_Reg_Number,425);
	--hr_utility.set_location('l_Sender_Report_Name :'||l_Sender_Report_Name,425);
	--hr_utility.set_location('l_Employer_Name :'||l_Employer_Name,425);
	--hr_utility.set_location('l_Employer_Reg_Number :'||l_Employer_Reg_Number,425);


	--Determine Sender Address (Business Group - Location)
	OPEN csr_get_address(l_business_group_id);
	FETCH csr_get_address INTO v_csr_get_address;
	CLOSE csr_get_address;

	v_House_Number := v_csr_get_address.House_Num;

	IF v_csr_get_address.House_Num_Add IS NOT NULL
	AND v_House_Number IS NOT NULL THEN
		v_House_Number := v_House_Number||' ';
	END IF;
	v_House_Number := v_House_Number||v_csr_get_address.House_Num_Add;

	IF v_House_Number IS NOT NULL THEN
		l_Sender_Address := SUBSTR(v_csr_get_address.street_name,1,19-NVL(LENGTH(v_House_Number),0));
		l_Sender_Address := l_Sender_Address ||' ';
	ELSE
		l_Sender_Address := SUBSTR(v_csr_get_address.street_name,1,20);
	END IF;
	l_Sender_Address := l_Sender_Address ||v_House_Number;

	IF l_Sender_Address IS NOT NULL THEN
		l_Sender_Address := RPAD(SUBSTR(l_Sender_Address,1,20),20);
	ELSE
		l_Sender_Address := RPAD(' ',20);
	END IF;

	IF v_csr_get_address.Postal_Code||v_csr_get_address.City IS NOT NULL THEN
		l_Sender_Address := l_Sender_Address||
		RPAD(SUBSTR(NVL(v_csr_get_address.Postal_Code,' '),1,6),6)||
		RPAD(SUBSTR(NVL(v_csr_get_address.City,' '),1,14),14);
	ELSE
		l_Sender_Address := l_Sender_Address||RPAD(' ',20);
	END IF;
	l_Sender_Address :=UPPER(l_Sender_Address);
	--hr_utility.set_location('l_Sender_Address :'||l_Sender_Address,425);

	v_House_Number := NULL;
	--v_csr_get_address:= NULL;

	--Determine Employer Address
	OPEN csr_get_address(l_employer_id);
	FETCH csr_get_address INTO v_csr_get_address1;
	CLOSE csr_get_address;
	v_House_Number := v_csr_get_address1.House_Num;

	IF v_csr_get_address1.House_Num_Add IS NOT NULL
	AND v_House_Number IS NOT NULL THEN
		v_House_Number := v_House_Number||' ';
	END IF;
	v_House_Number := v_House_Number||v_csr_get_address1.House_Num_Add;

	IF v_House_Number IS NOT NULL THEN
		l_Employer_Address := SUBSTR(v_csr_get_address1.street_name,1,19-NVL(LENGTH(v_House_Number),0));
		l_Employer_Address := l_Employer_Address ||' ';
	ELSE
		l_Employer_Address := SUBSTR(v_csr_get_address1.street_name,1,20);
	END IF;
	l_Employer_Address := l_Employer_Address ||v_House_Number;

	IF l_Employer_Address IS NOT NULL THEN
		l_Employer_Address := RPAD(SUBSTR(l_Employer_Address,1,20),20);
	ELSE
		l_Employer_Address := RPAD(' ',20);
	END IF;

	IF v_csr_get_address.Postal_Code||v_csr_get_address1.City IS NOT NULL THEN
		l_Employer_Address := l_Employer_Address||
		RPAD(SUBSTR(NVL(v_csr_get_address1.Postal_Code,' '),1,6),6)||
		RPAD(SUBSTR(NVL(v_csr_get_address1.City,' '),1,14),14);
	ELSE
		l_Employer_Address := l_Employer_Address||RPAD(' ',20);
	END IF;
	l_Employer_Address :=UPPER(l_Employer_Address);
	--hr_utility.set_location('l_Employer_Address :'||l_Employer_Address,425);



	-- Validate  Checks for Employer NSI Data
	-- Check For Mandatory Fields
	-- Check for Sender Registration Number,If NULL Raise Error
	Mandatory_Check('PAY_NL_ER_NSI_REQUIRED_FIELD','NL_SENDER_REG_NUM',l_Sender_Reg_Number);

	-- Cadans /Cadans Zorg Specific Validation
	-- Sender Address Mandatory for Cadans Files
	-- Employer Postal Code/City Mandatory
	IF (l_report_type='NL_CAD_NSI_ARCHIVE' OR l_report_type='NL_CADZ_NSI_ARCHIVE') THEN
		--Sender Address details
		Mandatory_Check('PAY_NL_ER_NSI_REQUIRED_FIELD','NL_SENDER_ADDR',SUBSTR(v_csr_get_address.street_name||v_csr_get_address.House_Num||v_csr_get_address.House_Num_Add,1,20));
		Mandatory_Check('PAY_NL_ER_NSI_REQUIRED_FIELD','NL_POSTAL_CODE',SUBSTR(v_csr_get_address.Postal_Code,1,6));
		Mandatory_Check('PAY_NL_ER_NSI_REQUIRED_FIELD','NL_CITY',v_csr_get_address.City);

		--Employer Address details
		Mandatory_Check('PAY_NL_ER_NSI_REQUIRED_FIELD','NL_POSTAL_CODE',SUBSTR(v_csr_get_address1.Postal_Code,1,6));
		Mandatory_Check('PAY_NL_ER_NSI_REQUIRED_FIELD','NL_CITY',v_csr_get_address1.City);
	END IF;

	-- Check for Employer Rep Name or Employer Reg Number,If NULL Raise Error
	Mandatory_Check('PAY_NL_ER_NSI_REQUIRED_FIELD','NL_EMPLOYER_NAME',l_Employer_Name);
	Mandatory_Check('PAY_NL_ER_NSI_REQUIRED_FIELD','NL_ER_REG_NUMBER',l_Employer_Reg_Number);
	Mandatory_Check('PAY_NL_ER_NSI_REQUIRED_FIELD','NL_ER_ADDR',SUBSTR(v_csr_get_address1.street_name||v_csr_get_address1.House_Num||v_csr_get_address1.House_Num_Add,1,20));

	IF g_error_count=0 THEN
		pay_action_information_api.create_action_information (
				p_action_information_id        => l_action_info_id
				,p_action_context_id            => pactid
				,p_action_context_type          => 'PA'
				,p_object_version_number        => l_ovn
				,p_effective_date               => l_NSI_Process_Date
				,p_source_id                    => NULL
				,p_source_text                  => NULL
				,p_action_information_category  => 'NL NSI EMPLOYER DETAILS'
				,p_action_information1          =>  l_si_provider_id
				,p_action_information2          =>  l_employer_id
				,p_action_information3          =>  l_Sender_Reg_Number
				,p_action_information4          =>  l_Sender_Report_Name
				,p_action_information5          =>  l_Sender_Address
				,p_action_information6          =>  l_Employer_Name
				,p_action_information7          =>  l_Employer_Address
				,p_action_information8          =>  l_Employer_Reg_Number
				);
		sqlstr := 'SELECT DISTINCT person_id
		FROM  per_people_f ppf
		,pay_payroll_actions ppa
		WHERE ppa.payroll_action_id = :payroll_action_id
		AND   ppa.business_group_id = ppf.business_group_id
		ORDER BY ppf.person_id';
	ELSE
		sqlstr := 'SELECT DISTINCT person_id
		FROM  per_people_f ppf
		,pay_payroll_actions ppa
		WHERE ppa.payroll_action_id = :payroll_action_id
		AND   1 = 2
		AND   ppa.business_group_id = ppf.business_group_id
		ORDER BY ppf.person_id';
	END IF;
	--
	--
	--Write to Log File
	v_log_header := RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','NL_ASSIGNMENT_NUMBER'),1,20),20)
	||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','FULL_NAME'),1,25),25)
	||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','FIELD_NAME'),1,25),25)
	||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','ERROR_TYPE'),1,15),15)
	||' '||RPAD(SUBSTR(hr_general.decode_lookup('HR_NL_REPORT_LABELS','MESSAGE'),1,70),70);
	Fnd_file.put_line(FND_FILE.LOG,v_log_header);

	hr_utility.set_location('Leaving Range Code',350);

EXCEPTION

	WHEN OTHERS THEN
	hr_utility.set_location('SQLERRM  '||SQLERRM,350);

	-- Return cursor that selects no rows
	sqlstr := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
END RANGE_CODE;

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_NL_NSI_EE_DETAILS                                     |
|Type		    : Procedure							                            |
|Description    : Procedure archives the NL NSI EE DETAILS Context    ,         |
-------------------------------------------------------------------------------*/
Procedure ARCHIVE_NL_NSI_EE_DETAILS(p_business_group_id IN NUMBER
									 ,p_report_type      IN VARCHAR2
									 ,p_payroll_action_id      IN NUMBER
									 ,p_assignment_action_id IN NUMBER
									 ,p_chunk             in number
									 ,p_Starter_Flag     IN VARCHAR2
									 ,p_person_id        IN NUMBER
									 ,p_assignment_id    IN NUMBER
									 ,p_employer_id   IN NUMBER
									 ,p_si_provider_id   IN NUMBER
									 ,p_cur_nsi_process_date IN  DATE
									 ,p_lst_nsi_process_date IN  DATE) IS


	--
	-- Cursor to retrieve All Date Track Changes to Employee Assignment Records.
	-- Between the Last NSI Process Date and the Current NSI Run Process Date.
	-- Also has a Union for Select that selects the Date Track Changes
	-- in the Cadans Extra Info Change- Occupation Code
	-- If the Run is for Cadans- NL_CAD_NSI_ARCHIVE OR NL_CADZ_NSI_ARCHIVE
	CURSOR csr_ee_asg_si_info(lp_report_type varchar2
						,lp_person_id number,lp_assignment_id   number
						,lp_si_provider number
						,lp_last_nsi_process_date date,lp_nsi_process_date date) IS
	SELECT
		paa.person_id ,paa.assignment_id
		,paa.organization_id,paa.effective_start_date ,paa.effective_end_date
		,FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information1) si_eff_start_date
		,NVL(FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information2),hr_general.end_of_time) si_eff_end_date
		,hr_general.start_of_time cad_eff_start_date
		,hr_general.end_of_time cad_eff_end_date
		,scl_flx.SEGMENT2     Employment_Type
		,scl_flx.SEGMENT3     Employment_SubType
		,scl_flx.SEGMENT6     Work_Pattern
		,paa.assignment_status_type_id
		,asg_stat.per_system_status
		,null     occupation_code
		,null 	  other_occupation_name
		,null     collective_agreement_code
		,null     insurance_abp
		,null     risk_fund
	FROM
		per_all_assignments_f paa
		,hr_soft_coding_keyflex scl_flx
		,per_assignment_status_types asg_stat
		,per_assignment_extra_info ee_si
	WHERE   paa.person_id = lp_person_id
	and     paa.assignment_id = lp_assignment_id
	and     scl_flx.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
	and     paa.assignment_status_type_id = asg_stat.assignment_status_type_id
	AND 	paa.assignment_id = ee_si.assignment_id
	AND 	ee_si.aei_information_category='NL_SII'
	AND 	ee_si.aei_information3 IN('ZFW','ZW','WW','WAO','AMI')
	AND 	paa.effective_start_date
			BETWEEN FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information1)
			AND  NVL(FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information2),hr_general.end_of_time)
	and     paa.effective_start_date BETWEEN lp_last_nsi_process_date AND  lp_nsi_process_date
	AND     (lp_report_type = 'NL_GAK_NSI_ARCHIVE'  ) /* Gak Asg Date Track Changes*/
	UNION
	SELECT
		paa.person_id,paa.assignment_id
		,paa.organization_id,paa.effective_start_date,paa.effective_end_date
		,FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information1) si_eff_start_date
		,NVL(FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information2),hr_general.end_of_time) si_eff_end_date
		,hr_general.start_of_time cad_eff_start_date
		,hr_general.end_of_time cad_eff_end_date
		,scl_flx.SEGMENT2     Employment_Type
		,scl_flx.SEGMENT3     Employment_SubType
		,scl_flx.SEGMENT6     Work_Pattern
		,paa.assignment_status_type_id
		,asg_stat.per_system_status
		,null     occupation_code
		,null 	  other_occupation_name
		,null      collective_agreement_code
		,null	  insurance_abp
		,null	  risk_fund
	FROM
		per_all_assignments_f paa
		,hr_soft_coding_keyflex scl_flx
		,per_assignment_status_types asg_stat
		,per_assignment_extra_info ee_si
	WHERE   paa.person_id = lp_person_id
	AND     paa.assignment_id = lp_assignment_id
	AND     scl_flx.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
	AND     paa.assignment_status_type_id = asg_stat.assignment_status_type_id
	AND 	paa.assignment_id = ee_si.assignment_id
	AND 	ee_si.aei_information_category='NL_SII'
	AND 	ee_si.aei_information3 IN('ZFW','ZW','WW','WAO','AMI')
	AND 	lp_nsi_process_date BETWEEN paa.effective_start_date  AND paa.effective_end_date
	AND 	FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information1)
			BETWEEN lp_last_nsi_process_date AND  lp_nsi_process_date /* NL_SII-Code Insurance EIT Date Track Changes*/
	UNION
	SELECT
		paa.person_id,paa.assignment_id
		,paa.organization_id,paa.effective_start_date,paa.effective_end_date
		,FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information1) si_eff_start_date
		,NVL(FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information2),hr_general.end_of_time) si_eff_end_date
		,FND_DATE.CANONICAL_TO_DATE(ee_cadans.aei_information1) cad_eff_start_date
		,NVL(FND_DATE.CANONICAL_TO_DATE(ee_cadans.aei_information2),hr_general.end_of_time) cad_eff_end_date
		,scl_flx.SEGMENT2     Employment_Type
		,scl_flx.SEGMENT3     Employment_SubType
		,scl_flx.SEGMENT6     Work_Pattern
		,paa.assignment_status_type_id
		,asg_stat.per_system_status
		,ee_cadans.aei_information3     occupation_code
		,ee_cadans.aei_information4     other_occupation_name
		,ee_cadans.aei_information5     collective_agreement_code
		,ee_cadans.aei_information6     insurance_abp
		,ee_cadans.aei_information7     risk_fund
	FROM
		per_all_assignments_f paa
		,hr_soft_coding_keyflex scl_flx
		,per_assignment_status_types asg_stat
		,per_assignment_extra_info ee_cadans
		,per_assignment_extra_info ee_si
	WHERE   paa.person_id = lp_person_id
	and     paa.assignment_id = lp_assignment_id
	and     scl_flx.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
	and     paa.assignment_status_type_id = asg_stat.assignment_status_type_id
	AND 	paa.assignment_id = ee_si.assignment_id
	AND 	ee_si.aei_information_category='NL_SII'
	AND     ee_si.aei_information3 IN('ZFW','ZW','WW','WAO','AMI')
	AND 	paa.effective_start_date
			BETWEEN FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information1)
			AND  NVL(FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information2),hr_general.end_of_time)
	AND 	paa.assignment_id = ee_cadans.assignment_id(+)
	AND 	ee_cadans.aei_information_category='NL_CADANS_INFO'
	and     paa.effective_start_date BETWEEN lp_last_nsi_process_date AND  lp_nsi_process_date
	AND 	paa.effective_start_date
			BETWEEN FND_DATE.CANONICAL_TO_DATE(ee_cadans.aei_information1) AND  NVL(FND_DATE.CANONICAL_TO_DATE(ee_cadans.aei_information2),hr_general.end_of_time)
	AND     (lp_report_type = 'NL_CAD_NSI_ARCHIVE' OR lp_report_type='NL_CADZ_NSI_ARCHIVE' ) /* Cadans Asg Date Track Changes*/
	UNION
	SELECT
		paa.person_id,paa.assignment_id
		,paa.organization_id,paa.effective_start_date,paa.effective_end_date
		,FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information1) si_eff_start_date
		,NVL(FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information2),hr_general.end_of_time) si_eff_end_date
		,FND_DATE.CANONICAL_TO_DATE(ee_cadans.aei_information1) cad_eff_start_date
		,NVL(FND_DATE.CANONICAL_TO_DATE(ee_cadans.aei_information2),hr_general.end_of_time) cad_eff_end_date
		,scl_flx.SEGMENT2     Employment_Type
		,scl_flx.SEGMENT3     Employment_SubType
		,scl_flx.SEGMENT6     Work_Pattern
		,paa.assignment_status_type_id
		,asg_stat.per_system_status
		,ee_cadans.aei_information3     occupation_code
		,ee_cadans.aei_information4     other_occupation_name
		,ee_cadans.aei_information5     collective_agreement_code
		,ee_cadans.aei_information6     insurance_abp
		,ee_cadans.aei_information7     risk_fund
	FROM
		per_all_assignments_f paa
		,hr_soft_coding_keyflex scl_flx
		,per_assignment_status_types asg_stat
		,per_assignment_extra_info ee_cadans
		,per_assignment_extra_info ee_si
	WHERE   paa.person_id = lp_person_id
	AND     paa.assignment_id = lp_assignment_id
	AND     scl_flx.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
	AND     (lp_report_type = 'NL_CAD_NSI_ARCHIVE' OR lp_report_type='NL_CADZ_NSI_ARCHIVE' )
	AND     paa.assignment_status_type_id = asg_stat.assignment_status_type_id
	AND 	paa.assignment_id = ee_si.assignment_id
	AND 	ee_si.aei_information_category='NL_SII'
	AND 	ee_si.aei_information3 IN('ZFW','ZW','WW','WAO','AMI')
	AND 	paa.effective_start_date
			BETWEEN FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information1)
			AND  NVL(FND_DATE.CANONICAL_TO_DATE(ee_si.aei_information2),hr_general.end_of_time)
	AND     FND_DATE.CANONICAL_TO_DATE(ee_cadans.aei_information1)
			BETWEEN paa.effective_start_date AND paa.effective_end_date
	AND 	paa.assignment_id = ee_cadans.assignment_id
	AND 	ee_cadans.aei_information_category='NL_CADANS_INFO'
	AND 	FND_DATE.CANONICAL_TO_DATE(ee_cadans.aei_information1)
			BETWEEN lp_last_nsi_process_date AND  lp_nsi_process_date /* Cadans EIT Date Track Changes*/
	order by 1,2,4,5;
	csr_ee_asg_nsi csr_ee_asg_si_info%ROWTYPE;

	l_notify_nsi_date DATE;

	--Select the Most recently sent NSI Record for comparison
	--to determine if a NSI Record needs to be generated or not.
	CURSOR csr_ee_nsi_record (lp_person_id         number
							,lp_assignment_id      number
							,lp_employer_id        number
							,lp_si_provider        number
							,lp_nsi_notify_date   date
							,lp_lst_nsi_process_date date) IS
	SELECT
		nl_ee_nsi.action_information1           Employer_ID
		,nl_ee_nsi.action_information2          Person_ID
		,nl_ee_nsi.action_information3          Assignment_ID
		,nl_ee_nsi.action_information4          SI_Provider_ID
		,nl_ee_nsi.action_information5          Hire_Date
		,nl_ee_nsi.action_information6          Actual_Termination_Date
		,nl_ee_nsi.action_information7          Assignment_Start_Date
		,nl_ee_nsi.action_information8          Assignment_End_Date
		,nl_ee_nsi.action_information9          Notification_a
		,nl_ee_nsi.action_information10         Notification_a_date
		,nl_ee_nsi.action_information11			Notification_b
		,nl_ee_nsi.action_information12			Notification_b_date
		,nl_ee_nsi.action_information13			Code_Insurance
		,nl_ee_nsi.action_information14			Code_Insurance_Basis
		,nl_ee_nsi.action_information15			Code_Occupation
		,nl_ee_nsi.action_information16			Work_Pattern
		,nl_ee_nsi.action_information17			St_Date_Lab_Rel
	FROM PAY_ACTION_INFORMATION nl_ee_nsi
	where nl_ee_nsi.action_context_type='AAP'
	and nl_ee_nsi.action_information_category = 'NL NSI EMPLOYEE DETAILS'
	and nl_ee_nsi.action_information1 = lp_employer_id
	and nl_ee_nsi.action_information2 = lp_person_id
	and nl_ee_nsi.action_information3 = lp_assignment_id
	and nl_ee_nsi.action_information4 = lp_si_provider
	and (nl_ee_nsi.action_information10 = TO_CHAR(lp_nsi_notify_date,'DDMMYYYY')
	OR nl_ee_nsi.action_information12 = TO_CHAR(lp_nsi_notify_date,'DDMMYYYY'))
	and nl_ee_nsi.effective_date <= lp_lst_nsi_process_date
	and nl_ee_nsi.action_information9 <>'4'
	ORDER BY nl_ee_nsi.effective_date DESC;
	v_csr_ee_nsi_record  csr_ee_nsi_record%ROWTYPE;

	--Select the Last NSI Record Notify Dates for comparison
	--to determine if a NSI Record needs to be generated or not
	--in the Current Run.

	CURSOR csr_ee_lat_nsi (lp_employer_id       NUMBER
						   ,lp_si_provider_id  NUMBER
						   ,lp_person_id        NUMBER
						   ,lp_assignment_id    NUMBER
						   ,lp_nsi_process_date DATE) IS
	SELECT
		min(TO_DATE(nl_ee_nsi1.action_information10,'DDMMYYYY')) notify_a_date,
		min(TO_DATE(nl_ee_nsi1.action_information12,'DDMMYYYY')) notify_b_date
	FROM PAY_ACTION_INFORMATION nl_ee_nsi1
	where nl_ee_nsi1.action_context_type='AAP'
	and nl_ee_nsi1.action_information_category = 'NL NSI EMPLOYEE DETAILS'
	and nl_ee_nsi1.action_information1 = lp_employer_id
	and nl_ee_nsi1.action_information2 = lp_person_id
	and nl_ee_nsi1.action_information3 = lp_assignment_id
	and nl_ee_nsi1.effective_date = lp_nsi_process_date
	and nl_ee_nsi1.action_information9 <>'4';
	v_csr_ee_lat_nsi csr_ee_lat_nsi%ROWTYPE;

	--Select EE Assignment Effective Dates
	CURSOR csr_ee_asg_dates (lp_assignment_id     NUMBER) IS
	SELECT TO_CHAR(min(asg.effective_start_date),'DDMMYYYY') asg_start_date
		,TO_CHAR(max(asg.effective_end_date),'DDMMYYYY') asg_end_date
	from   per_all_assignments_f asg,
	per_assignment_status_types past
	where  asg.assignment_id = lp_assignment_id
	and   past.per_system_status = 'ACTIVE_ASSIGN'
	and   asg.assignment_status_type_id = past.assignment_status_type_id;

	--Select EE Termination Details
	CURSOR csr_ee_term (lp_person_id     NUMBER) IS
	SELECT leaving_reason,Actual_Termination_Date
	from   per_periods_of_service pos
	where  pos.person_id = lp_person_id;
	v_csr_ee_term csr_ee_term%ROWTYPE;

	--Select EE Assignment Status
	CURSOR csr_ee_asg_status (lp_assignment_id     NUMBER,l_effective_date date) IS
	SELECT asg.effective_start_date,asg.effective_end_date,past.per_system_status
	from   per_all_assignments_f asg,
	per_assignment_status_types past
	where  asg.assignment_id = lp_assignment_id
	and   asg.assignment_status_type_id = past.assignment_status_type_id
	and  l_effective_date BETWEEN asg.effective_start_date and asg.effective_end_date;
	v_csr_ee_asg_status csr_ee_asg_status%ROWTYPE;

	--Select EE SI Info	- NL_SII
	CURSOR csr_ee_siinfo (lp_assignment_id     NUMBER
						,lp_organization_id    NUMBER
						,lp_effective_date      DATE) IS
	SELECT
		PAY_NL_SI_PKG.Get_Si_Status(lp_assignment_id,lp_effective_date,'ZW')  zw_si_status
		,PAY_NL_SI_PKG.Get_Si_Status(lp_assignment_id,lp_effective_date,'WW')  ww_si_status
		,PAY_NL_SI_PKG.Get_Si_Status(lp_assignment_id,lp_effective_date,'WAO') wao_si_status
		,PAY_NL_SI_PKG.Get_Si_Status(lp_assignment_id,lp_effective_date,'ZFW') zfw_si_status
	FROM   dual ;
	v_csr_ee_siinfo csr_ee_siinfo%ROWTYPE;

	-- Cursor to Determine the SI Provider for the Various SI Types
	-- as on Effective Date
	CURSOR csr_ee_si_prov_info(lp_organization_id number
  							  ,lp_assignment_id number
  							  ,lp_effective_date date
  							  ,lp_zw_si_status Varchar2
  							  ,lp_ww_si_status Varchar2
  							  ,lp_wao_si_status Varchar2
  							  ,lp_zfw_si_status Varchar2) IS
	SELECT
		DECODE(lp_zw_si_status,null,null,HR_NL_ORG_INFO.Get_SI_Provider_Info(lp_organization_id,'ZW',lp_assignment_id)) zw_provider
		,DECODE(lp_ww_si_status,null,null,HR_NL_ORG_INFO.Get_SI_Provider_Info(lp_organization_id,'WEWE',lp_assignment_id)) ww_provider
		,DECODE(lp_wao_si_status,null,null,HR_NL_ORG_INFO.Get_SI_Provider_Info(lp_organization_id,'WAOD',lp_assignment_id)) wao_provider
		,DECODE(lp_zfw_si_status,null,null,HR_NL_ORG_INFO.Get_SI_Provider_Info(lp_organization_id,'ZFW',lp_assignment_id)) zfw_provider
		,DECODE(lp_zw_si_status,null,null,HR_NL_ORG_INFO.Get_ER_SI_Prov_HR_Org_ID(lp_organization_id,'ZW',lp_assignment_id))  zw_er_org_id
		,DECODE(lp_ww_si_status,null,null,HR_NL_ORG_INFO.Get_ER_SI_Prov_HR_Org_ID(lp_organization_id,'WEWE',lp_assignment_id))  ww_er_org_id
		,DECODE(lp_wao_si_status,null,null,HR_NL_ORG_INFO.Get_ER_SI_Prov_HR_Org_ID(lp_organization_id,'WAOD',lp_assignment_id)) wao_er_org_id
		,DECODE(lp_zfw_si_status,null,null,HR_NL_ORG_INFO.Get_ER_SI_Prov_HR_Org_ID(lp_organization_id,'ZFW',lp_assignment_id)) zfw_er_org_id
	FROM DUAL;
	v_csr_ee_si_prov_info csr_ee_si_prov_info%ROWTYPE;


	--Select EE Info : Name/SOFI Number
	CURSOR csr_ee_info (lp_person_id        NUMBER
	                    ,lp_assignment_id        NUMBER
						,lp_effective_date  DATE) IS
	SELECT
	   ee_info.Full_Name
	  ,replace(replace(ee_info.Last_Name,'.',''),',','') Last_Name
	  ,replace(replace(ee_info.Previous_Last_Name,'.',''),',','') Previous_Last_Name
	  ,replace(replace(ee_info.First_Name,'.',''),',','') First_Name
	  ,replace(replace(replace(ee_info.per_information1,'.',''),',',''),' ','') Initials
	  ,replace(replace(replace(ee_info.pre_name_adjunct,'.',''),',',''),' ','') Prefix
	  ,ee_info.National_Identifier SOFI_Number
	  ,ee_info.sex
	  ,ee_info.Marital_Status
	  ,ee_info.Date_Of_Birth
	  ,ee_info.Employee_Number
	  ,paa.Assignment_Number
	FROM   per_all_people_f ee_info
	,per_all_assignments_f paa
	WHERE  ee_info.person_id   = lp_person_id
	AND    ee_info.person_id   = paa.person_id
	AND    paa.assignment_id = lp_assignment_id
	AND    lp_effective_date BETWEEN ee_info.Effective_Start_Date and ee_info.Effective_End_Date
	AND    lp_effective_date BETWEEN paa.Effective_Start_Date and paa.Effective_End_Date;
	v_csr_ee_info csr_ee_info%ROWTYPE;

	--Select EE Spouse Info : Name
	CURSOR csr_ee_sp_info (lp_person_id        NUMBER
	                    ,lp_effective_date  DATE) IS
	SELECT
	  ee_info.Last_Name
	  ,ee_info.Previous_Last_Name
	  ,replace(replace(replace(ee_info.pre_name_adjunct,'.',''),',',''),' ','') Prefix
	FROM   per_all_people_f ee_info,
	per_contact_relationships con
	WHERE  ee_info.person_id   = con.contact_person_id
	AND con.person_id= lp_person_id
	AND con.contact_type='S'
	AND    lp_effective_date BETWEEN ee_info.Effective_Start_Date and ee_info.Effective_End_Date;
	v_csr_ee_sp_info csr_ee_sp_info%ROWTYPE;

	--Select EE Address
	CURSOR csr_ee_addr (lp_person_id        NUMBER
						,lp_address_type    VARCHAR2
						,lp_effective_date  DATE) IS
	SELECT ee_addr.style		 style
	  ,ee_addr.add_information13 House_Num
	  ,ee_addr.add_information14 House_Num_Add
	  ,ee_addr.region_1          street_name
	  ,pay_nl_general.get_postal_code(ee_addr.postal_code)       postal_code
	  ,hr_general.decode_lookup('HR_NL_CITY',  ee_addr.town_or_city) city
	  ,ee_addr.country           country
	FROM   per_addresses ee_addr
	WHERE  ee_addr.person_id   = lp_person_id
	AND lp_effective_date between date_from and NVL(date_to,hr_general.end_of_time)
	AND ((ee_addr.primary_flag ='Y'   AND lp_address_type IS NULL)
	  OR (lp_address_type IS NOT NULL AND ee_addr.address_type = lp_address_type));
	v_csr_ee_addr csr_ee_addr%ROWTYPE;
	v_csr_ee_addr1 csr_ee_addr%ROWTYPE;


	--Select EE Gak Info
	CURSOR csr_ee_gak (lp_person_id        NUMBER
						,lp_assignment_id     NUMBER
						,lp_process_date      DATE) IS
	SELECT
		hr_general.decode_lookup('NL_GAK_OCCUPATION_DESCRIPTION',ee_gak.aei_information3) Occupation_Desc
		,ee_gak.aei_information4     Weekly_4_Exp_SI_Days
	FROM   per_assignment_extra_info ee_gak
	WHERE  ee_gak.assignment_id   = lp_assignment_id
	AND ee_gak.aei_information_category='NL_GAK_INFO'
	AND lp_process_date BETWEEN FND_DATE.CANONICAL_TO_DATE(ee_gak.aei_information1)
	AND NVL(FND_DATE.CANONICAL_TO_DATE(ee_gak.aei_information2),hr_general.END_OF_TIME) ;
	v_csr_ee_gak csr_ee_gak%ROWTYPE;

	--Select EE Cadans Info
	CURSOR csr_ee_cadans (lp_person_id        NUMBER
						,lp_assignment_id     NUMBER
						,lp_process_date      DATE) IS
	SELECT
		ee_cadans.aei_information3      occupation_code
		,ee_cadans.aei_information4     other_occupation_name
		,ee_cadans.aei_information5     collective_agreement_code
		,ee_cadans.aei_information6     insurance_abp
		,ee_cadans.aei_information7     risk_fund
	FROM   per_assignment_extra_info ee_cadans
	WHERE  ee_cadans.assignment_id   = lp_assignment_id
	AND ee_cadans.aei_information_category='NL_CADANS_INFO'
	AND lp_process_date BETWEEN FND_DATE.CANONICAL_TO_DATE(ee_cadans.aei_information1)
	AND NVL(FND_DATE.CANONICAL_TO_DATE(ee_cadans.aei_information2),hr_general.END_OF_TIME) ;
	v_csr_ee_cadans csr_ee_cadans%ROWTYPE;

	l_last_nsi_min_notify_date DATE;


	l_action_info_id 	pay_action_information.action_information_id%TYPE;
	l_ovn				pay_action_information.object_version_number%TYPE;

	l_effective_date            DATE;
	l_Employer_ID			    hr_organization_units.organization_id%TYPE;
	l_Person_ID                 per_all_assignments_f.person_id%TYPE;
	l_Assignment_ID             per_all_assignments_f.assignment_id%TYPE;
	l_Prev_Person_ID            per_all_assignments_f.person_id%TYPE;
	l_Prev_Assignment_ID        per_all_assignments_f.assignment_id%TYPE;

	l_NSI_Process_Date          varchar2(8);
	l_Hire_Date                 DATE;
	l_Asg_Effective_Start_Date	DATE;
	l_Actual_Termination_Date   DATE;
	l_Assignment_Start_Date     VARCHAR2(8);
	l_Assignment_End_Date       VARCHAR2(8);
	l_Notification_a            VARCHAR2(1);
	l_Notification_a_date    	VARCHAR2(8);
	l_Notification_b            VARCHAR2(1);
	l_Notification_b_date    	VARCHAR2(8);
	l_Code_Insurance            VARCHAR2(4);
	l_Code_Ins_Basis            VARCHAR2(15);
	l_Code_Occupation           VARCHAR2(3);
	l_Work_Pattern              VARCHAR2(3);
	l_St_Date_Lab_Rel           VARCHAR2(8);
	l_SOFI_Number               VARCHAR2(9);
	l_Employee_Name             VARCHAR2(150);
	l_Employee_Primary_Add      VARCHAR2(150);
	l_Country_Name		   		FND_TERRITORIES_VL.TERRITORY_SHORT_NAME%TYPE;
	l_Employee_Pop_Reg_Add      VARCHAR2(150);
	l_Gak_Rep_Info              VARCHAR2(150);
	l_Cadans_Rep_Info           VARCHAR2(150);
	l_Employee_Details          VARCHAR2(150);

	l_Prev_Notification_a       VARCHAR2(1);
	l_Prev_Notification_a_date  VARCHAR2(8);
	l_Prev_Notification_b       VARCHAR2(1);
	l_Prev_Notification_b_date  VARCHAR2(8);
	l_Prev_Code_Insurance       VARCHAR2(4);
	l_Prev_Code_Ins_Basis       VARCHAR2(15);
	l_Prev_Code_Occupation      VARCHAR2(3);
	l_Prev_Work_Pattern         VARCHAR2(3);
	l_Prev_St_Date_Lab_Rel      VARCHAR2(8);

	l_Create_NSI                BOOLEAN;--Flag to Control Creation of NSI Record
	l_Multiple_NSI				BOOLEAN;--Flag to Control Creation of Multiple NSI Record
	l_Asg_NSI_Rec_Count		    NUMBER;
	l_asg_act_id				pay_assignment_actions.assignment_action_id%TYPE;
	l_utab_row_value			VARCHAR2(100);
	l_utab_cib_value			VARCHAR2(100);
	l_Starter_Flag              VARCHAR2(50);

BEGIN
	hr_utility.set_location('Entering Archive NL NSI EE Details',350);
	hr_utility.set_location('Payroll Action Id '||p_payroll_action_id,350);

	--Intialize Variables
	l_Asg_NSI_Rec_Count := 0;
	l_asg_act_id := p_assignment_action_id;
	l_Employer_ID :=p_employer_id;
	l_Starter_Flag := P_Starter_Flag;
	IF l_asg_act_id IS NULL THEN
		l_Prev_Person_ID       	:=NULL;
		l_Prev_Assignment_ID   	:=NULL;
	ELSE
		l_Prev_Person_ID       	:=p_person_id;
		l_Prev_Assignment_ID   	:=p_assignment_id;
	END IF;
	g_error_count  := 0;


	hr_utility.set_location('p_person_id '||p_person_id||' p_assignment_id '||p_assignment_id,350);
	hr_utility.set_location(' p_si_provider_id '||p_si_provider_id
	                       ||' p_report_type'||p_report_type,350);
    hr_utility.set_location(' p_cur_nsi_process_date '||p_cur_nsi_process_date
	                       ||' p_lst_nsi_process_date '||p_lst_nsi_process_date
	                       ||' l_Starter_Flag '||l_Starter_Flag,350);
	IF l_Starter_Flag='EXISTING' THEN
		OPEN csr_ee_lat_nsi(p_employer_id,p_si_provider_id
							,p_person_id,p_assignment_id,p_lst_nsi_process_date );
		FETCH csr_ee_lat_nsi INTO v_csr_ee_lat_nsi;
		CLOSE csr_ee_lat_nsi;
		hr_utility.set_location('v_csr_ee_lat_nsi.notify_a_date '||v_csr_ee_lat_nsi.notify_a_date,350);
		hr_utility.set_location('v_csr_ee_lat_nsi.notify_b_date '||v_csr_ee_lat_nsi.notify_b_date,350);

		l_last_nsi_min_notify_date := p_lst_nsi_process_date;

		SELECT LEAST(NVL(v_csr_ee_lat_nsi.notify_a_date,v_csr_ee_lat_nsi.notify_b_date),
					 NVL(v_csr_ee_lat_nsi.notify_b_date,v_csr_ee_lat_nsi.notify_a_date))
		INTO l_last_nsi_min_notify_date FROM DUAL;
	END IF;
	hr_utility.set_location(' l_last_nsi_min_notify_date '||l_last_nsi_min_notify_date,350);

	--Determine EE Termination Details
	OPEN csr_ee_term(p_person_id);
	FETCH csr_ee_term INTO v_csr_ee_term;
	CLOSE csr_ee_term;

	OPEN csr_ee_asg_si_info(p_report_type
							,p_person_id,p_assignment_id
							,p_si_provider_id
							,NVL(l_last_nsi_min_notify_date,hr_general.START_OF_TIME),p_cur_nsi_process_date );
	LOOP
		FETCH csr_ee_asg_si_info INTO csr_ee_asg_nsi;
		EXIT WHEN (csr_ee_asg_si_info%NOTFOUND OR g_error_count>0);
		hr_utility.set_location(' Date Track ee_nsi.Eff_St_Date '||csr_ee_asg_nsi.Effective_Start_Date,350);

		l_Asg_Effective_Start_Date := GREATEST(csr_ee_asg_nsi.Effective_Start_Date
									,csr_ee_asg_nsi.si_eff_start_date
									,csr_ee_asg_nsi.cad_eff_start_date);
		hr_utility.set_location('l_Asg_Effective_Start_Date :'||l_Asg_Effective_Start_Date,450);



		--Intialize all NSI Record Variables
		l_Create_NSI        := FALSE;
		l_Multiple_NSI      := FALSE;
		l_NSI_Process_Date  :=TO_CHAR(p_cur_nsi_process_date,'DDMMYYYY');
		l_Notification_a  := '0';
		l_Notification_a_date := NULL;
		l_Notification_b  := '0';
		l_Notification_b_date := NULL;
		l_Code_Insurance := NULL;
		l_Code_Ins_Basis := NULL;
		l_Code_Occupation := NULL;
		l_Work_Pattern    := NULL;
		l_St_Date_Lab_Rel := NULL;

		l_utab_cib_value  := NULL;
		l_SOFI_Number     := NULL;
		l_Employee_Name   := NULL;
		l_Employee_Primary_Add  := NULL;
		l_Country_Name		   := NULL;
		l_Employee_Pop_Reg_Add  := NULL;
		l_Gak_Rep_Info          := NULL;
		l_Cadans_Rep_Info       := NULL;
		l_Employee_Details      := NULL;

		l_Person_ID       			:=csr_ee_asg_nsi.person_id;
		l_Assignment_ID   			:=csr_ee_asg_nsi.assignment_id;
		l_Assignment_Start_Date   := NULL;
		l_Assignment_End_Date   := NULL;
		v_csr_ee_siinfo       := NULL;
		v_csr_ee_si_prov_info := NULL;
		v_csr_ee_asg_status   := NULL;
		v_csr_ee_gak          := NULL;
		v_csr_ee_cadans       := NULL;
		v_csr_ee_nsi_record   := NULL;

		OPEN csr_ee_asg_dates(l_assignment_id);
		FETCH csr_ee_asg_dates INTO l_Assignment_Start_Date,l_Assignment_End_Date;
		CLOSE csr_ee_asg_dates;


		--Determine the l_Code_Insurance from EE NL_SII Data - Social Insurance Eligibilities
		--Fetch Employee SI Info
		OPEN csr_ee_siinfo(l_assignment_id,csr_ee_asg_nsi.organization_id,l_Asg_Effective_Start_Date);
		FETCH csr_ee_siinfo INTO v_csr_ee_siinfo;
		IF csr_ee_siinfo%FOUND THEN

			--Fetch EE SI Provider Info
			OPEN csr_ee_si_prov_info(csr_ee_asg_nsi.organization_id,l_assignment_id,l_Asg_Effective_Start_Date
			,v_csr_ee_siinfo.zw_si_status,v_csr_ee_siinfo.ww_si_status
			,v_csr_ee_siinfo.wao_si_status,v_csr_ee_siinfo.zfw_si_status);
			FETCH csr_ee_si_prov_info INTO v_csr_ee_si_prov_info;
			CLOSE csr_ee_si_prov_info;

			hr_utility.set_location(' ZW -'||v_csr_ee_si_prov_info.zw_provider||' WW -'||v_csr_ee_si_prov_info.ww_provider
			||' WAO -'||v_csr_ee_si_prov_info.wao_provider||' ZFW - '||v_csr_ee_si_prov_info.zfw_provider,450);


			--Determine Code Insurance
			IF v_csr_ee_si_prov_info.zw_provider=p_si_provider_id
		    	AND v_csr_ee_si_prov_info.zw_er_org_id=l_employer_id
				AND v_csr_ee_siinfo.zw_si_status IS NOT NULL THEN
				l_Code_Insurance := '1';
			ELSE
				l_Code_Insurance := '2';
			END IF;

			IF v_csr_ee_si_prov_info.ww_provider=p_si_provider_id
		    	AND v_csr_ee_si_prov_info.ww_er_org_id=l_employer_id
				AND v_csr_ee_siinfo.ww_si_status IS NOT NULL THEN
				l_Code_Insurance := l_Code_Insurance||'1';
			ELSE
				l_Code_Insurance := l_Code_Insurance||'2';
			END IF;

			IF v_csr_ee_si_prov_info.wao_provider=p_si_provider_id
		    	AND v_csr_ee_si_prov_info.wao_er_org_id=l_employer_id
				AND v_csr_ee_siinfo.wao_si_status IS NOT NULL THEN
				l_Code_Insurance := l_Code_Insurance||'1';
			ELSE
				l_Code_Insurance := l_Code_Insurance||'2';
			END IF;

			IF v_csr_ee_si_prov_info.zfw_provider=p_si_provider_id
		    	AND v_csr_ee_si_prov_info.zfw_er_org_id=l_employer_id
				AND v_csr_ee_siinfo.zfw_si_status IS NOT NULL
				AND v_csr_ee_siinfo.zfw_si_status <>'4'  THEN
				l_Code_Insurance := l_Code_Insurance||'1';
			ELSE
				l_Code_Insurance := l_Code_Insurance||'2';
			END IF;
		END IF;
		CLOSE csr_ee_siinfo;

		-- Determine the l_Code_Ins_Basis from EE Type and EE Sub Type Information
		--
		l_utab_row_value := csr_ee_asg_nsi.Employment_Type||csr_ee_asg_nsi.Employment_SubType;
		BEGIN
			hr_utility.set_location('Tab Value l_utab_row_value :'||l_utab_row_value,450);
			l_utab_cib_value:= hruserdt.get_table_value(p_business_group_id,'NL_EMP_SUB_TYPE_CIB_KOA','GAK_CADANS_CIB',l_utab_row_value,p_cur_nsi_process_date);
		EXCEPTION
			WHEN OTHERS THEN
				hr_utility.set_location('Tab Value Error '||SQLCODE||' : '||SQLERRM(SQLCODE),450);
				l_utab_cib_value:=null;
		END;

		hr_utility.set_location('CIB : l_utab_cib_value '||l_utab_cib_value,450);
		FOR i IN 18..31
		LOOP
			IF i IN(21,24,30) THEN
				l_Code_Ins_Basis:=l_Code_Ins_Basis||'0';
			ELSIF i=l_utab_cib_value THEN
				l_Code_Ins_Basis:=l_Code_Ins_Basis||'1';
			ELSE
				l_Code_Ins_Basis:=l_Code_Ins_Basis||'0';
			END IF;
		END LOOP;

		IF p_report_type='NL_GAK_NSI_ARCHIVE' THEN
			IF csr_ee_asg_nsi.per_system_status ='SUSP_ASSIGN' THEN
				l_Code_Ins_Basis := l_Code_Ins_Basis||'1';
			ELSE
				l_Code_Ins_Basis := l_Code_Ins_Basis||'0';
			END IF;
		END IF;

		-- Determine the Work Pattern
		l_Work_Pattern    := SUBSTR(NVL(csr_ee_asg_nsi.Work_Pattern,'R'),1,1);

		IF P_Report_Type='NL_GAK_NSI_ARCHIVE' THEN
			IF l_Work_Pattern='R' THEN
				l_Work_Pattern:='0';
			ELSE
				l_Work_Pattern:='1';
			END IF;
			--Fetch Employee GAK Rep Info
			OPEN csr_ee_gak(l_Person_ID,l_assignment_id,l_Asg_Effective_Start_Date);
			FETCH csr_ee_gak INTO v_csr_ee_gak;
			CLOSE csr_ee_gak;
			l_Gak_Rep_Info := RPAD(SUBSTR(v_csr_ee_gak.Occupation_Desc||' ',1,12),12);
			l_Gak_Rep_Info :=  l_Gak_Rep_Info||LPAD(SUBSTR(v_csr_ee_gak.Weekly_4_Exp_SI_Days,1,5),3,'0');
		END IF;
		l_Gak_Rep_Info := UPPER(l_Gak_Rep_Info); /* Convert to Upper Case*/
		hr_utility.set_location('l_Gak_Rep_Info : '||l_Gak_Rep_Info,450);

		IF (P_Report_Type='NL_CAD_NSI_ARCHIVE' OR P_Report_Type='NL_CADZ_NSI_ARCHIVE' ) THEN

			IF l_Work_Pattern='R' THEN
				l_Work_Pattern:='1';
			ELSE
				l_Work_Pattern:='0';
			END IF;
			-- Determine the Code Occupation
			--Fetch Employee Cadans Rep Info
			OPEN csr_ee_cadans(l_Person_ID,l_assignment_id,l_Asg_Effective_Start_Date);
			FETCH csr_ee_cadans INTO v_csr_ee_cadans;
			CLOSE csr_ee_cadans;
			l_Code_Occupation := SUBSTR(v_csr_ee_cadans.occupation_code,1,3);
			IF l_Code_Occupation = '129' THEN
				l_Cadans_Rep_Info := RPAD(SUBSTR(NVL(v_csr_ee_cadans.other_occupation_name,' '),1,9),9,' ');
			ELSE
				l_Cadans_Rep_Info := RPAD('0',9,'0');
			END IF;
			l_Cadans_Rep_Info := l_Cadans_Rep_Info||LPAD(SUBSTR(v_csr_ee_cadans.collective_agreement_code||' ',1,4),4,'0');
			l_Cadans_Rep_Info := l_Cadans_Rep_Info||LPAD(SUBSTR(v_csr_ee_cadans.insurance_abp||' ',1,1),1,'0');
			l_Cadans_Rep_Info := l_Cadans_Rep_Info||LPAD(SUBSTR(v_csr_ee_cadans.risk_fund||' ',1,1),1,'2');
		END IF;
		l_Cadans_Rep_Info := UPPER(l_Cadans_Rep_Info); /* Convert to Upper Case*/
		hr_utility.set_location('l_Cadans_Rep_Info : '||l_Cadans_Rep_Info,450);

		l_St_Date_Lab_Rel := l_Assignment_Start_Date;

		hr_utility.set_location('l_Code_Insurance '||l_Code_Insurance,450);
		hr_utility.set_location('l_Code_Ins_Basis '||l_Code_Ins_Basis,450);
		hr_utility.set_location('l_Code_Occupation '||l_Code_Occupation,450);
		hr_utility.set_location('l_Work_Pattern '||l_Work_Pattern,450);
		hr_utility.set_location('l_St_Date_Lab_Rel '||l_St_Date_Lab_Rel,450);


		IF l_Code_Insurance <>'2222' AND length(l_Code_Insurance)=4
		AND csr_ee_asg_nsi.PER_SYSTEM_STATUS <>'TERM_ASSIGN' THEN

			--For a Starter the l_Create_NSI is intially  set to TRUE
			--and Subsequent Date Track Changes ,we would need to chk if a NSI Record is needed or not

			--Check the Status of the Next Date Track Assignment Record

			OPEN csr_ee_asg_status(l_assignment_id,(csr_ee_asg_nsi.effective_end_date+1));
			FETCH csr_ee_asg_status INTO v_csr_ee_asg_status;
			CLOSE csr_ee_asg_status;

			--Check if the Assignment was terminated
			--If so Set Notification B Type (Notif_b) to '1'
			IF v_csr_ee_asg_status.PER_SYSTEM_STATUS='TERM_ASSIGN' THEN
				l_Notification_b            :='1';
				l_Notification_b_date    	:=TO_CHAR(csr_ee_asg_nsi.effective_end_date,'DDMMYYYY');
			ELSE
				hr_utility.set_location('Actual_Termination_Date '||v_csr_ee_term.Actual_Termination_Date,450);
				hr_utility.set_location('effective_end_date '||v_csr_ee_asg_status.effective_end_date,450);
				IF v_csr_ee_term.Actual_Termination_Date IS NOT NULL
				AND v_csr_ee_term.Actual_Termination_Date <= p_cur_nsi_process_date
				AND v_csr_ee_term.Actual_Termination_Date >= csr_ee_asg_nsi.effective_start_date
				AND v_csr_ee_term.Actual_Termination_Date <= csr_ee_asg_nsi.effective_end_date THEN
					IF v_csr_ee_term.Leaving_Reason ='D' THEN
						l_Notification_b            :='2';
						l_Notification_b_date    	:=TO_CHAR(csr_ee_asg_nsi.effective_end_date,'DDMMYYYY');
					ELSIF v_csr_ee_term.Leaving_Reason IS NOT NULL THEN
						l_Notification_b            :='1';
						l_Notification_b_date    	:=TO_CHAR(csr_ee_asg_nsi.effective_end_date,'DDMMYYYY');
					ELSE
						l_Notification_b            :='0';
						l_Notification_b_date    	:=TO_CHAR(csr_ee_asg_nsi.effective_end_date,'DDMMYYYY');
					END IF;
				END IF;
			END IF;

			IF l_Starter_Flag='EXISTING' THEN
				hr_utility.set_location('Fetching NSI Record as on l_Asg_Effective_Start_Date'||l_Asg_Effective_Start_Date,450);

				OPEN csr_ee_nsi_record(p_person_id,p_assignment_id
								,p_employer_id,p_si_provider_id,l_Asg_Effective_Start_Date,p_lst_nsi_process_date);
				FETCH csr_ee_nsi_record INTO v_csr_ee_nsi_record;
				IF csr_ee_nsi_record%FOUND THEN
					hr_utility.set_location('v_csr_ee_nsi_record.Notification_a '||v_csr_ee_nsi_record.Notification_a,450);
					hr_utility.set_location('v_csr_ee_nsi_record.Notification_a_date '||v_csr_ee_nsi_record.Notification_a_date,450);
					hr_utility.set_location('v_csr_ee_nsi_record.Notification_b '||v_csr_ee_nsi_record.Notification_b,450);
					hr_utility.set_location('v_csr_ee_nsi_record.Notification_b_date '||v_csr_ee_nsi_record.Notification_b_date,450);
					hr_utility.set_location('v_csr_ee_nsi_record.Code_Insurance '||v_csr_ee_nsi_record.Code_Insurance,450);
					hr_utility.set_location('v_csr_ee_nsi_record.Code_Insurance_Basis '||v_csr_ee_nsi_record.Code_Insurance_Basis,450);
					hr_utility.set_location('v_csr_ee_nsi_record.Code_Occupation '||v_csr_ee_nsi_record.Code_Occupation,450);
					hr_utility.set_location('v_csr_ee_nsi_record.Work_Pattern '||v_csr_ee_nsi_record.Work_Pattern,450);
					hr_utility.set_location('v_csr_ee_nsi_record.St_Date_Lab_Rel '||v_csr_ee_nsi_record.St_Date_Lab_Rel,450);
					l_Prev_Notification_a        	:= v_csr_ee_nsi_record.Notification_a;
					l_Prev_Notification_a_date   	:= v_csr_ee_nsi_record.Notification_a_date;
					l_Prev_Notification_b        	:= v_csr_ee_nsi_record.Notification_b     ;
					l_Prev_Notification_b_date   	:= v_csr_ee_nsi_record.Notification_b_date;
					l_Prev_Code_Insurance        	:= v_csr_ee_nsi_record.Code_Insurance     ;
					l_Prev_Code_Ins_Basis        	:= v_csr_ee_nsi_record.Code_Insurance_Basis     ;
					l_Prev_Code_Occupation       	:= v_csr_ee_nsi_record.Code_Occupation    ;
					l_Prev_Work_Pattern          	:= v_csr_ee_nsi_record.Work_Pattern        ;
					l_Prev_St_Date_Lab_Rel       	:= v_csr_ee_nsi_record.St_Date_Lab_Rel     ;


					IF (v_csr_ee_nsi_record.Code_Insurance <> l_Code_Insurance)
					OR (SUBSTR(v_csr_ee_nsi_record.Code_Insurance_Basis,1,12) <> SUBSTR(l_Code_Ins_Basis,1,12))
					OR (v_csr_ee_nsi_record.Work_Pattern <> l_Work_Pattern)
					OR (v_csr_ee_nsi_record.Notification_b <> l_Notification_b)
					OR (v_csr_ee_nsi_record.Notification_b_date <> l_Notification_b_date) THEN
						l_Create_NSI := TRUE;
					END IF;

					IF (P_Report_Type='NL_CAD_NSI_ARCHIVE' OR P_Report_Type='NL_CADZ_NSI_ARCHIVE' ) THEN
						IF v_csr_ee_nsi_record.Code_Occupation <> l_Code_Occupation     THEN
							l_Create_NSI := TRUE;
						END IF;
					END IF;
					IF (P_Report_Type='NL_CADZ_NSI_ARCHIVE' ) THEN
						IF v_csr_ee_nsi_record.St_Date_Lab_Rel <> l_St_Date_Lab_Rel     THEN
							l_Create_NSI := TRUE;
						END IF;
					END IF;
					--Set Notification Type (Notif_a) to '3' since it is a Correction to a previous
					--sent NSI Record
					IF l_Create_NSI=TRUE  THEN
						l_Notification_a            :='3';
						l_Notification_a_date    	:=TO_CHAR(l_Asg_Effective_Start_Date,'DDMMYYYY');
					END IF;

					IF  (l_Notification_b IS NOT NULL AND v_csr_ee_nsi_record.Notification_b <> l_Notification_b)
					OR (l_Notification_b_date IS NOT NULL AND v_csr_ee_nsi_record.Notification_b_date <> l_Notification_b_date)  THEN
						l_Create_NSI := TRUE;
					END IF;


				END IF;
				CLOSE csr_ee_nsi_record;
			END IF;

			hr_utility.set_location('l_Prev_Code_Insurance '||l_Prev_Code_Insurance,450);
			hr_utility.set_location('l_Prev_Code_Ins_Basis '||l_Prev_Code_Ins_Basis,450);
			hr_utility.set_location('l_Prev_Code_Occupation '||l_Prev_Code_Occupation,450);
			hr_utility.set_location('l_Prev_Work_Pattern '||l_Prev_Work_Pattern,450);
			hr_utility.set_location('l_Prev_St_Date_Lab_Rel '||l_Prev_St_Date_Lab_Rel,450);

			/* Check if the previous Archived NSI Record is same as the
			NSI Data as on the Effective Date*/
			IF l_Create_NSI=FALSE AND l_Starter_Flag='EXISTING' THEN
				IF (l_Prev_Code_Insurance IS NOT NULL AND l_Prev_Code_Insurance <> l_Code_Insurance)
				OR (l_Prev_Code_Ins_Basis IS NOT NULL AND SUBSTR(l_Prev_Code_Ins_Basis,1,12) <> SUBSTR(l_Code_Ins_Basis,1,12))
				OR (l_Prev_Work_Pattern IS NOT NULL AND l_Prev_Work_Pattern <> l_Work_Pattern)     THEN
					l_Create_NSI := TRUE;
				END IF;

				IF (P_Report_Type='NL_CAD_NSI_ARCHIVE' OR P_Report_Type='NL_CADZ_NSI_ARCHIVE' ) THEN
					IF l_Prev_Code_Occupation IS NOT NULL
					AND l_Prev_Code_Occupation <> l_Code_Occupation     THEN
						l_Create_NSI := TRUE;
					END IF;
				END IF;
				IF (P_Report_Type='NL_CADZ_NSI_ARCHIVE' ) THEN
					IF l_Prev_St_Date_Lab_Rel IS NOT NULL
					AND l_Prev_St_Date_Lab_Rel <> l_St_Date_Lab_Rel     THEN
						l_Create_NSI := TRUE;
					END IF;
				END IF;

				IF l_Create_NSI=TRUE  THEN
					--Set Notification Type (Notif_a) to '2' since it is a Change Record
					--Any Date Track Changes to the NSI Data
					--Notification Type a would be 2

					l_Notification_a            :='2';
					l_Notification_a_date    	:=TO_CHAR(l_Asg_Effective_Start_Date,'DDMMYYYY');
				END IF;
			END IF;
			IF l_Create_NSI= FALSE AND l_Starter_Flag='STARTER' THEN
				--Determine the Notification type
				IF l_Asg_NSI_Rec_Count=0  THEN
						l_Create_NSI := TRUE;

						--Set Notification Type (Notif_a) to '1' since it is a New Record - Starter
						l_Notification_a            :='1';
						l_Notification_a_date    	:=TO_CHAR(csr_ee_asg_nsi.effective_start_date,'DDMMYYYY');

				ELSIF l_Asg_NSI_Rec_Count>0 THEN
						--Set Notification Type (Notif_a) to '2' since it is a Change Record
						--Any Date Track Changes to the NSI Data for a Starter
						--Notification Type a would be 2
						l_Notification_a            :='2';
						l_Notification_a_date    	:=TO_CHAR(l_Asg_Effective_Start_Date,'DDMMYYYY');

				END IF;

				IF l_Prev_Code_Insurance <> l_Code_Insurance
				OR SUBSTR(l_Prev_Code_Ins_Basis,1,12) <> SUBSTR(l_Code_Ins_Basis,1,12)
				OR l_Prev_Work_Pattern  <> l_Work_Pattern     THEN
					l_Create_NSI := TRUE;
				END IF;

				IF (P_Report_Type='NL_CAD_NSI_ARCHIVE' OR P_Report_Type='NL_CADZ_NSI_ARCHIVE' ) THEN
					IF l_Prev_Code_Occupation  <> l_Code_Occupation     THEN
						l_Create_NSI := TRUE;
					END IF;
				END IF;
				IF (P_Report_Type='NL_CADZ_NSI_ARCHIVE' ) THEN
					IF l_Prev_St_Date_Lab_Rel <> l_St_Date_Lab_Rel     THEN
						l_Create_NSI := TRUE;
					END IF;
				END IF;

			END IF;
			hr_utility.set_location('l_Notification_a '||l_Notification_a,450);
			hr_utility.set_location('l_Notification_a_date '||l_Notification_a_date,450);
			hr_utility.set_location('l_Notification_b '||l_Notification_b,450);
			hr_utility.set_location('l_Notification_b_date '||l_Notification_b_date,450);

			IF l_Create_NSI= TRUE THEN
				hr_utility.set_location('Creating NSI EE Record '||p_assignment_action_id,450);

				v_csr_ee_info      := NULL;
				v_csr_ee_sp_info   := NULL;
				v_csr_ee_addr      := NULL;
				v_csr_ee_addr1     := NULL;

				--Fetch Employee Details
				OPEN csr_ee_info(l_Person_ID,l_Assignment_ID,csr_ee_asg_nsi.Effective_Start_Date );
				FETCH csr_ee_info INTO v_csr_ee_info;
				CLOSE csr_ee_info;

				g_assignment_number := v_csr_ee_info.Assignment_Number;
				g_full_name := v_csr_ee_info.Full_Name;

				--hr_utility.set_location('Previous_Last_Name : '||v_csr_ee_info.Previous_Last_Name,450);
				--hr_utility.set_location('Last_Name : '||v_csr_ee_info.Last_Name,450);
				--hr_utility.set_location('Prefix : '||v_csr_ee_info.Prefix,450);
				--hr_utility.set_location('First_Name : '||v_csr_ee_info.First_Name,450);

				l_Employee_Name := RPAD(SUBSTR(NVL(v_csr_ee_info.Previous_Last_Name,v_csr_ee_info.Last_Name),1,49),49);
				l_Employee_Name := l_Employee_Name||RPAD(SUBSTR(v_csr_ee_info.Initials||' ',1,5),5);
				l_Employee_Name := l_Employee_Name||RPAD(SUBSTR(v_csr_ee_info.Prefix||' ',1,8),8);
				l_Employee_Name := l_Employee_Name||RPAD(SUBSTR(v_csr_ee_info.First_Name||' ',1,15),15);
				l_Employee_Name := upper(l_Employee_Name);			/*Convert to Upper Case */

				--Fetch Spouse Employee Details
				OPEN csr_ee_sp_info(l_Person_ID,csr_ee_asg_nsi.Effective_Start_Date);
				FETCH csr_ee_sp_info INTO v_csr_ee_sp_info;
				CLOSE csr_ee_sp_info;

				l_Cadans_Rep_Info := RPAD(SUBSTR(NVL(v_csr_ee_sp_info.Previous_Last_Name,v_csr_ee_sp_info.Last_Name)||' ',1,30),30)
				||RPAD(SUBSTR(v_csr_ee_sp_info.Prefix||' ',1,8),8)
				||l_Cadans_Rep_Info;

				l_Cadans_Rep_Info := UPPER(l_Cadans_Rep_Info); /*Convert to Upper Case */
				--hr_utility.set_location('Spouse Name and Prefix Added l_Cadans_Rep_Info : '||l_Cadans_Rep_Info,450);

				--hr_utility.set_location('l_Employee_Name : '||l_Employee_Name,450);

				l_SOFI_Number := LPAD(SUBSTR(v_csr_ee_info.SOFI_Number,1,9),9,'0');
				--hr_utility.set_location('l_SOFI_Number : '||l_SOFI_Number,450);

				IF v_csr_ee_info.Sex='M' THEN
					l_Employee_Details:= '1';
				ELSIF v_csr_ee_info.Sex='F' THEN
					l_Employee_Details:= '2';
				END IF;
				IF (v_csr_ee_info.Marital_Status='M' OR
						v_csr_ee_info.Marital_Status='REG_PART' OR
						v_csr_ee_info.Marital_Status='LA') THEN
					l_Employee_Details:= l_Employee_Details||'2';
				ELSE
					l_Employee_Details:= l_Employee_Details||'1';
				END IF;
				l_Employee_Details:= l_Employee_Details||TO_CHAR(v_csr_ee_info.Date_Of_Birth,'DDMMYYYY');
				l_Employee_Details:= l_Employee_Details||RPAD(v_csr_ee_info.Employee_Number,30);/*Employee Num*/
				l_Employee_Details:= l_Employee_Details||RPAD(v_csr_ee_info.Assignment_Number,30);/*Asg Num*/

				l_Employee_Details := upper(l_Employee_Details);			/*Convert to Upper Case */


				--hr_utility.set_location('l_Employee_Details-Sex+MaritalStatus+EENum+AsgNum : '||l_Employee_Details,450);

				--hr_utility.set_location('l_Person_ID : '||l_Person_ID,450);

				--Fetch Employee Address
				OPEN csr_ee_addr(l_Person_ID,NULL,csr_ee_asg_nsi.Effective_Start_Date);
				FETCH csr_ee_addr INTO v_csr_ee_addr;
				CLOSE csr_ee_addr;

				l_Employee_Primary_Add := RPAD(SUBSTR(NVL(v_csr_ee_addr.street_name,' '),1,25),25);
				IF P_Report_Type='NL_GAK_NSI_ARCHIVE' THEN
					l_Employee_Primary_Add :=  l_Employee_Primary_Add||LPAD(SUBSTR(NVL(v_csr_ee_addr.House_Num,'0'),1,5),5,'0');
					l_Employee_Primary_Add :=  l_Employee_Primary_Add||RPAD(SUBSTR(NVL(v_csr_ee_addr.House_Num_Add,' '),1,5),5);
				ELSE
					IF LENGTH(v_csr_ee_addr.House_Num||v_csr_ee_addr.House_Num_Add)<10 THEN
						l_Employee_Primary_Add :=  l_Employee_Primary_Add||RPAD(SUBSTR(v_csr_ee_addr.House_Num||' '||v_csr_ee_addr.House_Num_Add,1,10),10,' ');
					ELSE
						l_Employee_Primary_Add :=  l_Employee_Primary_Add||LPAD(SUBSTR(NVL(v_csr_ee_addr.House_Num,'0'),1,5),5,'0');
						l_Employee_Primary_Add :=  l_Employee_Primary_Add||RPAD(SUBSTR(NVL(v_csr_ee_addr.House_Num_Add,' '),1,5),5);
					END IF;
				END IF;
				--hr_utility.set_location('l_EE_Prim_Add : '||l_Employee_Primary_Add,450);

				IF v_csr_ee_addr.Country ='NL' THEN
					l_Employee_Primary_Add :=  l_Employee_Primary_Add||LPAD(SUBSTR(NVL(v_csr_ee_addr.Postal_Code,'0'),1,4),4,'0');
					l_Employee_Primary_Add :=  l_Employee_Primary_Add||RPAD(SUBSTR(NVL(v_csr_ee_addr.Postal_Code,' '),5,2),2);
				ELSE
					l_Employee_Primary_Add :=  l_Employee_Primary_Add||RPAD('0',4,'0');
					l_Employee_Primary_Add :=  l_Employee_Primary_Add||RPAD(' ',2,' ');
				END IF;
				--hr_utility.set_location('l_EE_Prim_Add : '||l_Employee_Primary_Add,450);

				l_Employee_Primary_Add := l_Employee_Primary_Add||RPAD(SUBSTR(nvl(v_csr_ee_addr.City,' '),1,20),20);
				--hr_utility.set_location('l_EE_Prim_Add +City : '||l_Employee_Primary_Add,450);

				l_Country_Name:=get_country_name(v_csr_ee_addr.country);
				--hr_utility.set_location('l_Country_Name : '||l_Country_Name,450);
				IF v_csr_ee_addr.country='NL' THEN
					l_Employee_Primary_Add := l_Employee_Primary_Add||RPAD(' ',15);
				ELSE
					l_Employee_Primary_Add := l_Employee_Primary_Add||RPAD(SUBSTR(l_Country_Name,1,15),15);
				END IF;
				l_Employee_Primary_Add := upper(l_Employee_Primary_Add);/*Convert to Upper Case */

				--hr_utility.set_location('l_Employee_Primary_Add : '||l_Employee_Primary_Add,450);

				--Fetch Employee Population Register Address
				OPEN csr_ee_addr(l_Person_ID,'PRA',csr_ee_asg_nsi.Effective_Start_Date);
				FETCH csr_ee_addr INTO v_csr_ee_addr1;
				CLOSE csr_ee_addr;
				l_Employee_Pop_Reg_Add := RPAD(SUBSTR(v_csr_ee_addr1.street_name,1,25)||' ',25);
				IF P_Report_Type='NL_GAK_NSI_ARCHIVE' THEN
					l_Employee_Pop_Reg_Add :=  l_Employee_Pop_Reg_Add||LPAD(SUBSTR(NVL(v_csr_ee_addr1.House_Num,'0'),1,5),5,'0');
					l_Employee_Pop_Reg_Add :=  l_Employee_Pop_Reg_Add||RPAD(SUBSTR(NVL(v_csr_ee_addr1.House_Num_Add,' '),1,5),5);
					l_Employee_Pop_Reg_Add :=  l_Employee_Pop_Reg_Add||LPAD(SUBSTR(NVL(v_csr_ee_addr1.Postal_Code,'0'),1,4),4,'0');
					l_Employee_Pop_Reg_Add :=  l_Employee_Pop_Reg_Add||RPAD(SUBSTR(NVL(v_csr_ee_addr1.Postal_Code,' '),5,2),2);
				ELSE
					IF LENGTH(v_csr_ee_addr1.House_Num||v_csr_ee_addr1.House_Num_Add)<10 THEN
						l_Employee_Pop_Reg_Add :=  l_Employee_Pop_Reg_Add||RPAD(SUBSTR(v_csr_ee_addr1.House_Num||' '||v_csr_ee_addr1.House_Num_Add,1,10),10,' ');
					ELSE
						l_Employee_Pop_Reg_Add :=  l_Employee_Pop_Reg_Add||RPAD(SUBSTR(v_csr_ee_addr1.House_Num||v_csr_ee_addr1.House_Num_Add,1,10),10,' ');
					END IF;
					l_Employee_Pop_Reg_Add :=  l_Employee_Pop_Reg_Add||RPAD(SUBSTR(NVL(v_csr_ee_addr1.Postal_Code,' '),1,6),6,' ');
				END IF;
				l_Employee_Pop_Reg_Add :=  l_Employee_Pop_Reg_Add||RPAD(SUBSTR(NVL(v_csr_ee_addr1.City,' '),1,20),20);

				l_Employee_Pop_Reg_Add := upper(l_Employee_Pop_Reg_Add);/*Convert to Upper Case */
				--hr_utility.set_location('l_Employee_Pop_Reg_Add : '||l_Employee_Pop_Reg_Add,450);

				---------------------------------------------------------------------------------------
				-- Validation  Checks for Employee NSI Data
				---------------------------------------------------------------------------------------
				-- Check For Mandatory Fields

				-- Check for Date of Birth
				Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_DATE_OF_BIRTH',v_csr_ee_info.Date_Of_Birth);

				-- Check for Employment Type
				Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_EMPLOY_TYPE',csr_ee_asg_nsi.Employment_Type);

				-- Check for Employment Sub Type
				Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_EMPLOY_STYPE',csr_ee_asg_nsi.Employment_SubType);

				-- Check for Code Insurance Basis
				IF csr_ee_asg_nsi.Employment_Type IS NOT NULL
				AND csr_ee_asg_nsi.Employment_SubType IS NOT NULL THEN
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_CODE_INSURANCE_BASIS',l_utab_cib_value);
				END IF;

				-- Check for EE Primary Address,If NULL Raise Error
				Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_STREET_PRIMARY',v_csr_ee_addr.street_name);
				Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_HOUSE_NUMBER',v_csr_ee_addr.House_Num);
				--Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_ADD_TO_HOUSE_NUMBER',v_csr_ee_addr.House_Num_Add);
				--Postal Code is Mandatory only if Country is NL
				IF v_csr_ee_addr.country='NL' THEN
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_POSTAL_CODE',SUBSTR(v_csr_ee_addr.Postal_Code,1,4));
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_POSTAL_CODE',SUBSTR(v_csr_ee_addr.Postal_Code,5,2));
				END IF;
				Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_CITY',v_csr_ee_addr.City);

				-- Check for EE Population Register Address,If NULL Raise Error
				-- Conditional Mandatory
				-- If Street Name is entered, Then
				-- House Num, House Num Add, Postal Code (Num),Postal Code (Char) is set to mandatory.
				IF v_csr_ee_addr1.Street_Name IS NOT NULL THEN
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_HOUSE_NUMBER',v_csr_ee_addr1.House_Num);
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_POSTAL_CODE',SUBSTR(v_csr_ee_addr1.Postal_Code,1,4));
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_POSTAL_CODE',SUBSTR(v_csr_ee_addr1.Postal_Code,5,2));
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_CITY',v_csr_ee_addr1.City);
				END IF;

				-- Check for SOFI Number,If NULL Raise Error
				Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_SOFI_NUMBER',v_csr_ee_info.SOFI_Number);

				-- Gak Specific Validation
				IF (P_Report_Type='NL_GAK_NSI_ARCHIVE') THEN
					-- Check Occupation Description
					IF l_Code_Ins_Basis='000000000000000' THEN
						Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_OCC_DESC',v_csr_ee_gak.Occupation_Desc);
					END IF;

					-- Check 4 Weekly Exp SI Days is Not Null if Work Pattern is set to 1
					IF l_Work_Pattern='1' THEN
						Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_EXPECTED_SI_DAYS',v_csr_ee_gak.Weekly_4_Exp_SI_Days);
					END IF;
				END IF;



				-- Cadans Specific Validation
				IF (P_Report_Type='NL_CAD_NSI_ARCHIVE') THEN
					--Name Spouse is entered,Check if Prefix Name spouse is entered or not
					IF NVL(v_csr_ee_sp_info.Previous_Last_Name,v_csr_ee_sp_info.Last_Name) IS NOT NULL THEN
						Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_PREFIX_SPOUSE',v_csr_ee_sp_info.Prefix);
					END IF;
					-- Check for Marital Status
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_MARITAL_STATUS',v_csr_ee_info.Marital_Status);

					-- Check Code Occupation
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_OCCUPATION_CODE',v_csr_ee_cadans.occupation_code);
					-- Check Occupation Description is Not Null if Occupation Code is set to 129-Others
					IF v_csr_ee_cadans.occupation_code='129' THEN
						Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_OTH_OCC_NAME',v_csr_ee_cadans.other_occupation_name);
					END IF;
				END IF;

				-- Cadans Zorg Specific Validation
				IF (P_Report_Type='NL_CADZ_NSI_ARCHIVE' ) THEN
					--Name Spouse is entered,Check if Prefix Name spouse is entered or not
					IF NVL(v_csr_ee_sp_info.Previous_Last_Name,v_csr_ee_sp_info.Last_Name) IS NOT NULL THEN
						Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_PREFIX_SPOUSE',v_csr_ee_sp_info.Prefix);
					END IF;
					-- Check for Marital Status
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_MARITAL_STATUS',v_csr_ee_info.Marital_Status);

					-- Check Code Occupation,Collective Agreement Code,Code Insurance ABP, Code Risicofunds is NOT NULL
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_OCCUPATION_CODE',v_csr_ee_cadans.occupation_code);
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_COLLECTIVE_AGREEMENT_CODE',v_csr_ee_cadans.collective_agreement_code);
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_INSURANCE_ABP',v_csr_ee_cadans.insurance_abp);
					Mandatory_Check('PAY_NL_ASG_NSI_REQUIRED_FIELD','NL_RISK_FUND',v_csr_ee_cadans.risk_fund);
				END IF;

				IF g_error_count=0 THEN
					-- Create Archive Assignment Action for Assignment
					IF l_Prev_Assignment_ID IS NULL
					OR l_Prev_Assignment_ID <> l_Assignment_ID
					OR l_asg_act_id IS NULL THEN
						SELECT pay_assignment_actions_s.NEXTVAL
						INTO   l_asg_act_id
						FROM   dual;
						--
						-- Create the archive assignment action
						--
						hr_nonrun_asact.insact(l_asg_act_id,l_Assignment_ID, p_payroll_action_id,p_chunk,NULL);

						--
					END IF;
					hr_utility.set_location('NSI Archive Assignment Action Id '||l_asg_act_id,450);

					l_Prev_Notification_a        	:= l_Notification_a;
					l_Prev_Notification_a_date   	:= l_Notification_a_date;
					l_Prev_Notification_b        	:= l_Notification_b     ;
					l_Prev_Notification_b_date   	:= l_Notification_b_date;
					l_Prev_Code_Insurance        	:= l_Code_Insurance     ;
					l_Prev_Code_Ins_Basis        	:= l_Code_Ins_Basis     ;
					l_Prev_Code_Occupation       	:= l_Code_Occupation    ;
					l_Prev_Work_Pattern          	:= l_Work_Pattern        ;
					l_Prev_St_Date_Lab_Rel       	:= l_St_Date_Lab_Rel     ;

					-- Notif_a = 2 must not be combined with Notif_b=1
					-- Generate Two NSI- All Data Same but the Notif attributes set differently
					-- NSI 1 : Notif a = 2, Notif b= NULL
					-- NSI 2 : Notif a = NULL Notif b= 1/2
					l_Multiple_NSI := FALSE;
					IF l_Notification_a='2'
					AND ((l_Notification_b='1' OR l_Notification_b='2')
						OR (l_Notification_b='0' AND l_Notification_b_date IS NOT NULL)) THEN
						l_Notification_b := '0';
						l_Notification_b_date := NULL;
						l_Multiple_NSI := TRUE;
					END IF;

					pay_action_information_api.create_action_information (
							p_action_information_id        => l_action_info_id
							,p_action_context_id            => l_asg_act_id
							,p_action_context_type          => 'AAP'
							,p_object_version_number        => l_ovn
							,p_effective_date               => TO_DATE(l_NSI_Process_Date,'DDMMYYYY')
							,p_source_id                    => NULL
							,p_source_text                  => NULL
							,p_action_information_category  => 'NL NSI EMPLOYEE DETAILS'
							,p_action_information1          =>  l_Employer_ID
							,p_action_information2          =>  l_Person_ID
							,p_action_information3          =>  l_Assignment_ID
							,p_action_information4          =>  p_si_provider_id
							,p_action_information5          =>  l_Hire_Date
							,p_action_information6          =>  l_Actual_Termination_Date
							,p_action_information7          =>  l_Assignment_Start_Date
							,p_action_information8          =>  l_Assignment_End_Date
							,p_action_information9          =>  l_Notification_a
							,p_action_information10         =>  l_Notification_a_date
							,p_action_information11			=> 	l_Notification_b
							,p_action_information12			=> 	l_Notification_b_date
							,p_action_information13			=> 	l_Code_Insurance
							,p_action_information14			=> 	l_Code_Ins_Basis
							,p_action_information15			=> 	l_Code_Occupation
							,p_action_information16			=> 	l_Work_Pattern
							,p_action_information17			=> 	l_St_Date_Lab_Rel
							,p_action_information18			=> 	l_SOFI_Number
							,p_action_information19			=> 	l_Employee_Name
							,p_action_information20			=> 	l_Employee_Primary_Add
							,p_action_information21			=> 	l_Employee_Pop_Reg_Add
							,p_action_information22			=> 	l_Gak_Rep_Info
							,p_action_information23			=> 	l_Cadans_Rep_Info
							,p_action_information24			=> 	l_Employee_Details  );
					hr_utility.set_location('NSI Archive l_action_info_id'||l_action_info_id,450);

					--Create Multiple NSI records with Same Data expect for NSI Notify attributes.
					IF l_Multiple_NSI THEN
						l_Notification_a := '0';
						l_Notification_a_date := NULL;
						l_Notification_b := l_Prev_Notification_b;
						l_Notification_b_date := l_Prev_Notification_b_Date;
						l_Multiple_NSI := FALSE;
						pay_action_information_api.create_action_information (
							p_action_information_id        => l_action_info_id
							,p_action_context_id            => l_asg_act_id
							,p_action_context_type          => 'AAP'
							,p_object_version_number        => l_ovn
							,p_effective_date               => TO_DATE(l_NSI_Process_Date,'DDMMYYYY')
							,p_source_id                    => NULL
							,p_source_text                  => NULL
							,p_action_information_category  => 'NL NSI EMPLOYEE DETAILS'
							,p_action_information1          =>  l_Employer_ID
							,p_action_information2          =>  l_Person_ID
							,p_action_information3          =>  l_Assignment_ID
							,p_action_information4          =>  p_si_provider_id
							,p_action_information5          =>  l_Hire_Date
							,p_action_information6          =>  l_Actual_Termination_Date
							,p_action_information7          =>  l_Assignment_Start_Date
							,p_action_information8          =>  l_Assignment_End_Date
							,p_action_information9          =>  l_Notification_a
							,p_action_information10         =>  l_Notification_a_date
							,p_action_information11			=> 	l_Notification_b
							,p_action_information12			=> 	l_Notification_b_date
							,p_action_information13			=> 	l_Code_Insurance
							,p_action_information14			=> 	l_Code_Ins_Basis
							,p_action_information15			=> 	l_Code_Occupation
							,p_action_information16			=> 	l_Work_Pattern
							,p_action_information17			=> 	l_St_Date_Lab_Rel
							,p_action_information18			=> 	l_SOFI_Number
							,p_action_information19			=> 	l_Employee_Name
							,p_action_information20			=> 	l_Employee_Primary_Add
							,p_action_information21			=> 	l_Employee_Pop_Reg_Add
							,p_action_information22			=> 	l_Gak_Rep_Info
							,p_action_information23			=> 	l_Cadans_Rep_Info
							,p_action_information24			=> 	l_Employee_Details  );
						hr_utility.set_location('NSI Archive Multiple l_action_info_id'||l_action_info_id,450);
					END IF;
				END IF;/* End of g_error_count Check*/
			END IF;	/* End of l_Create_NSI= TRUE Check*/
		END IF;/* End of l_Code_Insurance <>'2222' Check*/

		l_Asg_NSI_Rec_Count := l_Asg_NSI_Rec_Count +1;
		l_Prev_Person_ID       	:=l_Person_ID;
		l_Prev_Assignment_ID   	:=l_Assignment_ID;

	END LOOP;
	hr_utility.set_location('Leaving Archive NL NSI EE Details',350);
End ARCHIVE_NL_NSI_EE_DETAILS;

/*-----------------------------------------------------------------------------
|Name           : WITHDRAW_NL_NSI_EE_NOTIF                                     |
|Type		    : Procedure							                           |
|Description    : Procedure Withdraws the Last NL NSI EE DETAILS Context       |
-------------------------------------------------------------------------------*/
Procedure WITHDRAW_NL_NSI_EE_NOTIF(p_payroll_action_id      IN NUMBER
								 ,p_chunk            IN NUMBER
								 ,p_person_id        IN NUMBER
								 ,p_assignment_id    IN NUMBER
								 ,p_employer_id      IN NUMBER
								 ,p_si_provider_id   IN NUMBER
								 ,p_cur_nsi_process_date IN  DATE
								 ,p_lst_nsi_process_date IN  OUT NOCOPY DATE
								 ,p_assignment_action_id OUT NOCOPY NUMBER
								 ,p_Withdraw_New_Hire IN OUT NOCOPY BOOLEAN) IS
	--Select the Most recently sent NSI Record for comparison
	--to determine if a NSI Record needs to be generated or not.
	CURSOR csr_ee_nsi_record (lp_person_id         number
							,lp_assignment_id      number
							,lp_employer_id        number
							,lp_si_provider        number
							,lp_nsi_notify_date   date) IS
	SELECT
		nl_ee_nsi.action_information1           Employer_ID
		,nl_ee_nsi.action_information2          Person_ID
		,nl_ee_nsi.action_information3          Assignment_ID
		,nl_ee_nsi.action_information4          SI_Provider_ID
		,nl_ee_nsi.action_information5          Hire_Date
		,nl_ee_nsi.action_information6          Actual_Termination_Date
		,nl_ee_nsi.action_information7          Assignment_Start_Date
		,nl_ee_nsi.action_information8          Assignment_End_Date
		,nl_ee_nsi.action_information9          Notification_a
		,nl_ee_nsi.action_information10         Notification_a_date
		,nl_ee_nsi.action_information11			Notification_b
		,nl_ee_nsi.action_information12			Notification_b_date
		,nl_ee_nsi.action_information13			Code_Insurance
		,nl_ee_nsi.action_information14			Code_Insurance_Basis
		,nl_ee_nsi.action_information15			Code_Occupation
		,nl_ee_nsi.action_information16			Work_Pattern
		,nl_ee_nsi.action_information17			St_Date_Lab_Rel
		,nl_ee_nsi.action_information18         Sofi_Number
		,nl_ee_nsi.action_information19         Employee_Name
		,nl_ee_nsi.action_information20         Employee_Primary_Address
		,nl_ee_nsi.action_information21         Employee_Pop_Reg_Add
		,nl_ee_nsi.action_information22         Gak_Rep_Info
		,nl_ee_nsi.action_information23         Cadans_Rep_Info
		,nl_ee_nsi.action_information24         Employee_Details
	FROM PAY_ACTION_INFORMATION nl_ee_nsi
	where nl_ee_nsi.action_context_type='AAP'
	and nl_ee_nsi.action_information_category = 'NL NSI EMPLOYEE DETAILS'
	and nl_ee_nsi.action_information1 = lp_employer_id
	and nl_ee_nsi.action_information2 = lp_person_id
	and nl_ee_nsi.action_information3 = lp_assignment_id
	and nl_ee_nsi.action_information4 = lp_si_provider
	and nl_ee_nsi.effective_date = lp_nsi_notify_date
	and nl_ee_nsi.action_information9 <>'4'
	ORDER BY nl_ee_nsi.effective_date DESC;
	v_csr_ee_nsi_record  csr_ee_nsi_record%ROWTYPE;

	--Once the Previous NSI Record Process Date for assignment
	--is withdrawn,Fetch the Previous NSI Effective Date
	CURSOR csr_ee_prev_nsi (lp_employer_id     NUMBER
						   ,lp_si_provider_id  NUMBER
						   ,lp_person_id         number
						   ,lp_assignment_id      number
						   ,lp_nsi_process_date date) IS
	SELECT
		max(effective_date) prev_nsi_process_date
	FROM PAY_ACTION_INFORMATION nl_ee_nsi1
	where nl_ee_nsi1.action_context_type='AAP'
	and nl_ee_nsi1.action_information_category = 'NL NSI EMPLOYEE DETAILS'
	and nl_ee_nsi1.action_information1 = lp_employer_id
	and nl_ee_nsi1.action_information2 = lp_person_id
	and nl_ee_nsi1.action_information3 = lp_assignment_id
	and nl_ee_nsi1.action_information4 = lp_si_provider_id
	and nl_ee_nsi1.action_information9 <>'4'
	and nl_ee_nsi1.effective_date < lp_nsi_process_date;
 	v_csr_ee_prev_nsi csr_ee_prev_nsi%ROWTYPE;


	l_asg_act_id        pay_assignment_actions.assignment_action_id%TYPE;
	l_action_info_id 	pay_action_information.action_information_id%TYPE;
	l_ovn				pay_action_information.object_version_number%TYPE;
	l_withdrawn_action_count NUMBER :=0;
BEGIN
	hr_utility.set_location('Entering Withdraw NSI Notification',360);

	hr_utility.set_location(' p_person_id '||p_person_id||' p_assignment_id '||p_assignment_id,360);
	hr_utility.set_location(' p_employer_id '|| p_employer_id ||' p_si_provider_id '||p_si_provider_id,360);
	hr_utility.set_location(' p_lst_nsi_process_date '|| p_lst_nsi_process_date,360);
	hr_utility.set_location(' p_cur_nsi_process_date '|| p_cur_nsi_process_date,360);
	FOR v_csr_ee_nsi_record IN csr_ee_nsi_record(p_person_id,p_assignment_id
								,p_employer_id,p_si_provider_id,p_lst_nsi_process_date )
	LOOP
		--Increment the Withdrawn Action count.
		l_withdrawn_action_count := l_withdrawn_action_count+1;
		--If a Previous NSI is Notif-a=1,then retrun TRUE
		IF v_csr_ee_nsi_record.Notification_a='1' THEN
			p_Withdraw_New_Hire:= TRUE;
		END IF;
		-- Create Archive Assignment Action for Assignment
		IF l_asg_act_id IS NULL THEN
			SELECT pay_assignment_actions_s.NEXTVAL
			INTO   l_asg_act_id
			FROM   dual;
			--
			-- Create the archive assignment action
			--
			hr_nonrun_asact.insact(l_asg_act_id,p_assignment_id, p_payroll_action_id,p_chunk,NULL);

			--
		END IF;
		hr_utility.set_location('NSI Archive Assignment Action Id '||l_asg_act_id,450);


		pay_action_information_api.create_action_information (
				p_action_information_id        => l_action_info_id
				,p_action_context_id            => l_asg_act_id
				,p_action_context_type          => 'AAP'
				,p_object_version_number        => l_ovn
				,p_effective_date               => p_cur_nsi_process_date
				,p_source_id                    => NULL
				,p_source_text                  => NULL
				,p_action_information_category  => 'NL NSI EMPLOYEE DETAILS'
				,p_action_information1          =>  p_employer_id
				,p_action_information2          =>  p_Person_ID
				,p_action_information3          =>  p_Assignment_ID
				,p_action_information4          =>  p_si_provider_id
				,p_action_information5          =>  v_csr_ee_nsi_record.Hire_Date
				,p_action_information6          =>  v_csr_ee_nsi_record.Actual_Termination_Date
				,p_action_information7          =>  v_csr_ee_nsi_record.Assignment_Start_Date
				,p_action_information8          =>  v_csr_ee_nsi_record.Assignment_End_Date
				,p_action_information9          =>  '4'
				,p_action_information10         =>  v_csr_ee_nsi_record.Notification_a_date
				,p_action_information11			=> 	'0'
				,p_action_information12			=> 	v_csr_ee_nsi_record.Notification_b_date
				,p_action_information13			=> 	v_csr_ee_nsi_record.Code_Insurance
				,p_action_information14			=> 	v_csr_ee_nsi_record.Code_Insurance_Basis
				,p_action_information15			=> 	v_csr_ee_nsi_record.Code_Occupation
				,p_action_information16			=> 	v_csr_ee_nsi_record.Work_Pattern
				,p_action_information17			=> 	v_csr_ee_nsi_record.St_Date_Lab_Rel
				,p_action_information18			=> 	v_csr_ee_nsi_record.SOFI_Number
				,p_action_information19			=> 	v_csr_ee_nsi_record.Employee_Name
				,p_action_information20			=> 	v_csr_ee_nsi_record.Employee_Primary_Address
				,p_action_information21			=> 	v_csr_ee_nsi_record.Employee_Pop_Reg_Add
				,p_action_information22			=> 	v_csr_ee_nsi_record.Gak_Rep_Info
				,p_action_information23			=> 	v_csr_ee_nsi_record.Cadans_Rep_Info
				,p_action_information24			=> 	v_csr_ee_nsi_record.Employee_Details  );
		hr_utility.set_location('NSI Archive l_action_info_id'||l_action_info_id,450);

	END LOOP;

	IF l_withdrawn_action_count >0 then
		OPEN csr_ee_prev_nsi(p_employer_id,p_si_provider_id
						,p_Person_ID,p_Assignment_ID,p_lst_nsi_process_date);
		FETCH csr_ee_prev_nsi INTO v_csr_ee_prev_nsi;
		CLOSE csr_ee_prev_nsi;
	END IF;
	p_lst_nsi_process_date :=v_csr_ee_prev_nsi.prev_nsi_process_date;
	p_assignment_action_id := l_asg_act_id;
	hr_utility.set_location('Leaving Withdraw NSI Notification',370);
END WITHDRAW_NL_NSI_EE_NOTIF;
/*-------------------------------------------------------------------------------
|NAME           : ASSIGNMENT_ACTION_CODE                                      	|
|TYPE		    : PROCEDURE							                            |
|DESCRIPTION    : THIS PROCEDURE FURTHER RESTRICTS THE ASSIGNMENT ID'S RETURNED |
|		  BY THE RANGE CODE.                                           	        |
-------------------------------------------------------------------------------*/

Procedure ASSIGNMENT_ACTION_CODE (
				 p_payroll_action_id  in number
				,p_start_person_id   in number
				,p_end_person_id     in number
				,p_chunk             in number) IS

	-- Cursor to fetch the Org Hierarachy Version ID
	-- as on Process Date
	CURSOR csr_org_hierarchy(lp_business_group_id number,lp_process_date date) IS
	select
	posv.org_structure_version_id
	from
	per_organization_structures pos,
	per_org_structure_versions posv
	where pos.organization_structure_id = posv.organization_structure_id
	and to_char(pos.organization_structure_id) IN (select org_information1
	from hr_organization_information hoi where hoi.org_information_context='NL_BG_INFO'
	and hoi.organization_id=lp_business_group_id)
	and lp_process_date between posv.date_from and nvl(posv.date_to,hr_general.End_of_time);
	v_csr_org_hierarchy csr_org_hierarchy%ROWTYPE;
	-- Cursor to retrieve All Employee SI Records.
	-- as on Process Date
	CURSOR csr_employee_si_info(lp_business_group_id number
								,lp_employer_id number
								,lp_structure_version_id number
								,lp_start_person_id number
								,lp_end_person_id   number
								,lp_payroll_id     number
								,lp_si_provider   number
								,lp_nsi_process_date date) IS
	SELECT
	paa.person_id,paa.assignment_id
	,paa.organization_id,paa.effective_start_date,paa.effective_end_date
	,PAY_NL_SI_PKG.Get_Si_Status(paa.assignment_id,lp_nsi_process_date,'ZW')  zw_si_status
	,PAY_NL_SI_PKG.Get_Si_Status(paa.assignment_id,lp_nsi_process_date,'WW')  ww_si_status
	,PAY_NL_SI_PKG.Get_Si_Status(paa.assignment_id,lp_nsi_process_date,'WAO') wao_si_status
	,PAY_NL_SI_PKG.Get_Si_Status(paa.assignment_id,lp_nsi_process_date,'ZFW') zfw_si_status
	,scl_flx.SEGMENT2     Employment_Type
	,scl_flx.SEGMENT3     Employment_SubType
	,scl_flx.SEGMENT6     Work_Pattern
	FROM
		per_all_assignments_f paa
		,per_all_people_f pap
		,hr_soft_coding_keyflex scl_flx
	WHERE   paa.business_group_id = lp_business_group_id
	and     paa.person_id
	BETWEEN lp_start_person_id AND     lp_end_person_id
	and     (paa.payroll_id = lp_payroll_id OR lp_payroll_id IS NULL)
	and     paa.person_id =pap.person_id
	and     paa.organization_id IN (
		SELECT  pose.organization_id_child	FROM
		per_org_structure_elements pose
		CONNECT BY  pose.organization_id_parent = prior pose.organization_id_child
		AND pose.org_structure_version_id =lp_structure_version_id
		START WITH pose.organization_id_parent=lp_employer_id
		AND pose.org_structure_version_id =lp_structure_version_id
		UNION
		SELECT  lp_employer_id FROM DUAL
		)
	and     scl_flx.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
	and     ((lp_nsi_process_date >= paa.effective_start_date AND lp_nsi_process_date <= paa.effective_end_date)
	or	(lp_nsi_process_date >= pap.effective_start_date AND lp_nsi_process_date <= pap.effective_end_date))
	order by paa.person_id,paa.assignment_id,paa.effective_start_date,paa.effective_end_date;


	-- Cursor to Determine the SI Provider Info for the Various SI Types
	-- as on Process Date
	CURSOR csr_ee_si_prov_info(lp_organization_id number
  							  ,lp_assignment_id number
  							  ,lp_nsi_process_date date
  							  ,lp_zw_si_status Varchar2
  							  ,lp_ww_si_status Varchar2
  							  ,lp_wao_si_status Varchar2
  							  ,lp_zfw_si_status Varchar2) IS
	SELECT
		DECODE(lp_zw_si_status,null,null,HR_NL_ORG_INFO.Get_SI_Provider_Info(lp_organization_id,'ZW',lp_assignment_id)) zw_provider
		,DECODE(lp_ww_si_status,null,null,HR_NL_ORG_INFO.Get_SI_Provider_Info(lp_organization_id,'WEWE',lp_assignment_id)) ww_provider
		,DECODE(lp_wao_si_status,null,null,HR_NL_ORG_INFO.Get_SI_Provider_Info(lp_organization_id,'WAOD',lp_assignment_id)) wao_provider
		,DECODE(lp_zfw_si_status,null,null,HR_NL_ORG_INFO.Get_SI_Provider_Info(lp_organization_id,'ZFW',lp_assignment_id)) zfw_provider
		,DECODE(lp_zw_si_status,null,null,HR_NL_ORG_INFO.Get_ER_SI_Prov_HR_Org_ID(lp_organization_id,'ZW',lp_assignment_id))  zw_er_org_id
		,DECODE(lp_ww_si_status,null,null,HR_NL_ORG_INFO.Get_ER_SI_Prov_HR_Org_ID(lp_organization_id,'WEWE',lp_assignment_id))  ww_er_org_id
		,DECODE(lp_wao_si_status,null,null,HR_NL_ORG_INFO.Get_ER_SI_Prov_HR_Org_ID(lp_organization_id,'WAOD',lp_assignment_id)) wao_er_org_id
		,DECODE(lp_zfw_si_status,null,null,HR_NL_ORG_INFO.Get_ER_SI_Prov_HR_Org_ID(lp_organization_id,'ZFW',lp_assignment_id)) zfw_er_org_id
	FROM DUAL;
	v_csr_ee_si_prov_info csr_ee_si_prov_info%ROWTYPE;

	--Select the Last NSI Record Proces Date for comparison
	--to determine if a NSI Record needs to be generated or not
	--in the Current Run.
	CURSOR csr_ee_lat_nsi (lp_employer_id     NUMBER
						   ,lp_si_provider_id  NUMBER
						   ,lp_person_id         number
						   ,lp_assignment_id      number
						   ,lp_nsi_process_date date) IS
	SELECT
		max(effective_date) nsi_process_date
	FROM PAY_ACTION_INFORMATION nl_ee_nsi1
	where nl_ee_nsi1.action_context_type='AAP'
	and nl_ee_nsi1.action_information_category = 'NL NSI EMPLOYEE DETAILS'
	and nl_ee_nsi1.action_information1 = lp_employer_id
	and nl_ee_nsi1.action_information2 = lp_person_id
	and nl_ee_nsi1.action_information3 = lp_assignment_id
	and nl_ee_nsi1.action_information4 = lp_si_provider_id
	and nl_ee_nsi1.action_information9 <>'4'
	and nl_ee_nsi1.effective_date <= lp_nsi_process_date;
 	v_csr_ee_lat_nsi csr_ee_lat_nsi%ROWTYPE;

	--Check if the Assignment is in the Withdrwal Assignment Set Id
	CURSOR csr_withdraw_asg (
							lp_withdraw_asg_set_id number
							,lp_assignment_id       number) IS
	SELECT
		asg_set.assignment_id
	FROM hr_assignment_set_amendments asg_set
	WHERE asg_set.assignment_set_id=lp_withdraw_asg_set_id
	AND asg_set.assignment_id=lp_assignment_id;

 	v_csr_withdraw_asg csr_withdraw_asg%ROWTYPE;

	--
	l_business_group_id		NUMBER;
	l_employer_id			NUMBER;
	l_si_provider_id		NUMBER;
	l_nsi_month         	VARCHAR2(10);
	l_output_media_type		VARCHAR2(10);
	l_payroll_id			NUMBER;
	l_withdraw_asg_set_id   NUMBER;
	l_report_type      pay_payroll_actions.report_type%TYPE;

	--
	--
	l_prepay_action_id	NUMBER;


	l_action_info_id 	pay_action_information.action_information_id%TYPE;
	l_ovn				pay_action_information.object_version_number%TYPE;
	l_asg_act_id		pay_assignment_actions.assignment_action_id%TYPE;

	l_Create_NSI               BOOLEAN;--Flag to Control Creation of NSI Record
	v_Skip_Asg                 BOOLEAN;--Flag to control if processed asg can be skipped
	l_Withdraw_New_Hire 	   BOOLEAN;--Flag returned by Withdraw Asg Proc if a Notif a=1 is withdrawn
	l_Prev_Person_ID           per_all_assignments_f.person_id%TYPE;
	l_Prev_Assignment_ID       per_all_assignments_f.person_id%TYPE;
	l_Prev_SIProvider_ID       per_all_assignments_f.person_id%TYPE;

	l_effective_date            DATE;
	l_Registration_Number       hr_organization_information.ORG_INFORMATION6%TYPE;
	l_Person_ID                 per_all_assignments_f.person_id%TYPE;
	l_Assignment_ID             per_all_assignments_f.person_id%TYPE;
	l_NSI_Process_Date          DATE;
	l_Hire_Date                 DATE;
	l_Actual_Termination_Date   DATE;
	l_Assignment_Start_Date     DATE;
	l_Assignment_End_Date       DATE;
	l_Notification_a            VARCHAR2(1);
	l_Notification_a_date    	VARCHAR2(8);
	l_Notification_b            VARCHAR2(1);
	l_Notification_b_date    	VARCHAR2(8);
	l_Code_Insurance            VARCHAR2(4);
	l_Code_Ins_Basis      		VARCHAR2(15);
	l_Code_Occupation           VARCHAR2(3);
	l_Work_Pattern              VARCHAR2(3);
	l_St_Date_Lab_Rel           VARCHAR2(1);

BEGIN
	--
	--hr_utility.trace_on(NULL,'NL_NSI');

	hr_utility.set_location('Entering Assignment Action Code',400);
	--
	g_error_flag := hr_general.decode_lookup('HR_NL_REPORT_LABELS','ERROR');
	g_warning_flag := hr_general.decode_lookup('HR_NL_REPORT_LABELS','WARNING');

	PAY_NL_NSI_PROCESS.get_all_parameters
		(p_payroll_action_id    =>  p_payroll_action_id
		,p_business_group_id    =>  l_business_group_id
		,p_employer_id		    =>  l_employer_id
		,p_si_provider_id	    =>  l_si_provider_id
		,p_nsi_month            =>  l_nsi_month
		,p_output_media_type	=>  l_output_media_type
		,p_payroll_id           =>  l_payroll_id
		,p_withdraw_asg_set_id  =>  l_withdraw_asg_set_id
		,p_report_type          =>  l_report_type          );

	--Determine the Process Dates
	l_NSI_Process_Date := LAST_DAY(TO_DATE('01'||l_nsi_month,'DDMMYYYY'));

	--
	OPEN csr_org_hierarchy(l_business_group_id,l_NSI_Process_Date);
	FETCH csr_org_hierarchy INTO v_csr_org_hierarchy;
	CLOSE csr_org_hierarchy;

	l_prepay_action_id := 0;
	--

	--hr_utility.set_location('NSI Archive p_payroll_action_id '||p_payroll_action_id,425);
	--hr_utility.set_location('NSI Archive l_business_group_id '||l_business_group_id,425);
	--hr_utility.set_location('NSI Archive l_employer_id '||l_employer_id,425);
	--hr_utility.set_location('NSI Archive l_si_provider_id '||l_si_provider_id,425);
	--hr_utility.set_location('NSI Archive l_nsi_month '||l_nsi_month,425);
	--hr_utility.set_location('NSI Archive l_payroll_id '||l_payroll_id,425);
	--hr_utility.set_location('NSI Archive l_withdraw_asg_set_id '||l_withdraw_asg_set_id,425);
	--hr_utility.set_location('NSI Archive l_NSI_Process_Date '||l_NSI_Process_Date,425);
	--hr_utility.set_location('NSI Archive l_report_type '||l_report_type,425);

	l_Prev_Person_ID       := NULL;
	l_Prev_Assignment_ID   := NULL;


	FOR csr_ee_rec IN csr_employee_si_info(
						l_business_group_id,l_employer_id,v_csr_org_hierarchy.org_structure_version_id
						,p_start_person_id,p_end_person_id
						,l_payroll_id,l_si_provider_id
						,l_NSI_Process_Date)
	LOOP
		--
		--Intialize all NSI Record Variables
		l_Code_Insurance := NULL;
		l_Person_ID:= csr_ee_rec.Person_ID;
		l_Assignment_ID:= csr_ee_rec.Assignment_ID;
		hr_utility.set_location('l_Person_ID '||l_Person_ID||' l_Assignment_ID '||l_Assignment_ID,450);

		IF l_Prev_Person_ID = l_Person_ID
		AND l_Prev_Assignment_ID   = l_Assignment_ID THEN
			v_Skip_Asg := TRUE;
		ELSE
			v_Skip_Asg := FALSE;
		END IF;
		--Proceed only if a New Person/Assignment Record is being processed
		IF v_Skip_Asg=FALSE THEN

		v_csr_ee_si_prov_info := NULL;
		v_csr_ee_lat_nsi      := NULL;
		v_csr_withdraw_asg    := NULL;
		l_Withdraw_New_Hire   := FALSE;

		OPEN csr_ee_lat_nsi(csr_ee_rec.organization_id,l_si_provider_id
							,csr_ee_rec.person_id,csr_ee_rec.assignment_id,l_NSI_Process_Date);
		FETCH csr_ee_lat_nsi INTO v_csr_ee_lat_nsi;
		CLOSE csr_ee_lat_nsi;
		hr_utility.set_location('v_csr_ee_lat_nsi.nsi_process_date: '||v_csr_ee_lat_nsi.nsi_process_date,450);


		--Withdraw the Assignment,if included in the specified Withdraw Asg Set
		IF l_withdraw_asg_set_id IS NOT NULL THEN
			OPEN csr_withdraw_asg(l_withdraw_asg_set_id ,l_Assignment_ID);
			FETCH csr_withdraw_asg INTO v_csr_withdraw_asg;
			IF csr_withdraw_asg%FOUND THEN
				hr_utility.set_location('Asg in Withdrawal Set '||l_Assignment_ID,450);
				IF v_csr_ee_lat_nsi.nsi_process_date IS NOT NULL THEN
					WITHDRAW_NL_NSI_EE_NOTIF(p_payroll_action_id,p_chunk
						 ,csr_ee_rec.person_id,csr_ee_rec.assignment_id
						 ,csr_ee_rec.organization_id,l_si_provider_id
						 ,l_NSI_Process_Date,v_csr_ee_lat_nsi.nsi_process_date,l_asg_act_id,l_Withdraw_New_Hire);
					hr_utility.set_location('l_asg_act_id: '||l_asg_act_id,450);
				END IF;

			END IF;
			CLOSE csr_withdraw_asg;
		END IF;
		hr_utility.set_location('After Withdraw v_csr_ee_lat_nsi.nsi_process_date: '||v_csr_ee_lat_nsi.nsi_process_date,450);

		IF l_Withdraw_New_Hire THEN
			--If Previous NSI Record- Notif-a is withdrawn
			--Fresh NSI Notif -a with 1 needs to be generated.
			v_csr_ee_lat_nsi.nsi_process_date:=NULL;
		END IF;

		--Fetch EE SI Provider Info
		OPEN csr_ee_si_prov_info(csr_ee_rec.organization_id,csr_ee_rec.assignment_id,l_NSI_Process_Date
								,csr_ee_rec.zw_si_status,csr_ee_rec.ww_si_status
								,csr_ee_rec.wao_si_status,csr_ee_rec.zfw_si_status);
		FETCH csr_ee_si_prov_info INTO v_csr_ee_si_prov_info;
		CLOSE csr_ee_si_prov_info;

		hr_utility.set_location(' ZW -'||v_csr_ee_si_prov_info.zw_provider||' WW -'||v_csr_ee_si_prov_info.ww_provider
				             ||' WAO -'||v_csr_ee_si_prov_info.wao_provider||' ZFW - '||v_csr_ee_si_prov_info.zfw_provider,450);

		--Determine Code Insurance
		IF v_csr_ee_si_prov_info.zw_provider=l_si_provider_id
		    AND v_csr_ee_si_prov_info.zw_er_org_id=l_employer_id
			AND csr_ee_rec.zw_si_status IS NOT NULL THEN
			l_Code_Insurance := '1';
		ELSE
			l_Code_Insurance := '2';
		END IF;

		IF v_csr_ee_si_prov_info.ww_provider=l_si_provider_id
		    AND v_csr_ee_si_prov_info.ww_er_org_id=l_employer_id
			AND csr_ee_rec.ww_si_status IS NOT NULL THEN
			l_Code_Insurance := l_Code_Insurance||'1';
		ELSE
			l_Code_Insurance := l_Code_Insurance||'2';
		END IF;

		IF v_csr_ee_si_prov_info.wao_provider=l_si_provider_id
		    AND v_csr_ee_si_prov_info.wao_er_org_id=l_employer_id
			AND csr_ee_rec.wao_si_status IS NOT NULL THEN
			l_Code_Insurance := l_Code_Insurance||'1';
		ELSE
			l_Code_Insurance := l_Code_Insurance||'2';
		END IF;

		IF v_csr_ee_si_prov_info.zfw_provider=l_si_provider_id
			AND v_csr_ee_si_prov_info.zfw_er_org_id=l_employer_id
			AND csr_ee_rec.zfw_si_status IS NOT NULL
			AND csr_ee_rec.zfw_si_status <>'4'  THEN
			l_Code_Insurance := l_Code_Insurance||'1';
		ELSE
			l_Code_Insurance := l_Code_Insurance||'2';
		END IF;

		hr_utility.set_location('l_Code_Insurance '||l_Code_Insurance,450);
		--

		IF l_Code_Insurance <>'2222' AND length(l_Code_Insurance)=4 THEN
			hr_utility.set_location('l_Prev_Person_ID '||l_Prev_Person_ID||' l_Person_ID '||l_Person_ID,450);
			hr_utility.set_location('l_Prev_Assignment_ID '||l_Prev_Assignment_ID||' l_Assignment_ID '||l_Assignment_ID,450);
			hr_utility.set_location('l_Prev_SIProvider_ID '||l_Prev_SIProvider_ID||' l_si_provider_id '||l_si_provider_id,450);

			l_Create_NSI := TRUE;--Reset the NSI Record Creation Flag
			IF l_Prev_Person_ID = l_Person_ID
			AND l_Prev_Assignment_ID <> l_Assignment_ID
			AND l_Prev_SIProvider_ID = l_si_provider_id THEN
				l_Create_NSI := FALSE;
			END IF;

			IF l_Create_NSI THEN
				hr_utility.set_location('l_Create_NSI  TRUE '||l_withdraw_asg_set_id||' Asg Id: '||l_Assignment_ID,450);
				IF v_csr_ee_lat_nsi.nsi_process_date IS NULL THEN
					l_Create_NSI := TRUE;--Archive NSI Record Not Found.Hence Creating NSI

					hr_utility.set_location('Calling ARCHIVE_NL_NSI_EE_DETAILS in STARTER Rec Mode ',450);
					ARCHIVE_NL_NSI_EE_DETAILS
							(l_business_group_id,l_report_type,p_payroll_action_id,l_asg_act_id,p_chunk,'STARTER'
							,csr_ee_rec.person_id,csr_ee_rec.assignment_id
							,csr_ee_rec.organization_id,l_si_provider_id
							,l_NSI_Process_Date,v_csr_ee_lat_nsi.nsi_process_date);
				ELSE
					hr_utility.set_location('Calling ARCHIVE_NL_NSI_EE_DETAILS in EXISTING Rec Mode ',450);
					ARCHIVE_NL_NSI_EE_DETAILS
						(l_business_group_id,l_report_type,p_payroll_action_id,l_asg_act_id,p_chunk,'EXISTING'
						,csr_ee_rec.person_id,csr_ee_rec.assignment_id
						,csr_ee_rec.organization_id,l_si_provider_id
						,l_NSI_Process_Date,v_csr_ee_lat_nsi.nsi_process_date);
				END IF;
				l_Prev_Person_ID       := l_Person_ID;
				l_Prev_Assignment_ID   := l_Assignment_ID;
				l_Prev_SIProvider_ID   := l_si_provider_id;
			END IF;	--End of if for Create_NSI Check
		END IF;--End of if for NSI Record Creation

		END IF;--End of IF for Skip Asg Check
	END LOOP;
--
hr_utility.set_location('Leaving Assignment Action Code',500);
--
END ASSIGNMENT_ACTION_CODE;



/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_INIT                                            	    |
|Type		    : Procedure							                            |
|Description    : Initialization Code for Archiver                              |
-------------------------------------------------------------------------------*/
Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER) IS

BEGIN
	--
	hr_utility.set_location('Entering Archive Init',600);
	hr_utility.set_location('Leaving Archive Init',700);
	--
END ARCHIVE_INIT;



/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_CODE                                            	    |
|Type		: Procedure							                                |
|Description    : This is the main procedure which calls the several procedures |
|		  to archive the data.						                            |
-------------------------------------------------------------------------------*/


Procedure ARCHIVE_CODE (p_assignment_action_id  IN NUMBER
						,p_effective_date       IN DATE) IS


BEGIN
	--
	hr_utility.set_location('Entering Archive Code',800);
	hr_utility.set_location('Leaving Archive Code',800);
	--
END ARCHIVE_CODE;

END PAY_NL_NSI_PROCESS;

/
