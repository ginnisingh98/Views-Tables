--------------------------------------------------------
--  DDL for Package Body PAY_NL_TAXOFFICE_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_TAXOFFICE_FILE" as
/* $Header: pynltosf.pkb 120.0.12000000.1 2007/01/17 23:04:56 appldev noship $ */
g_package  varchar2(33) := ' PAY_NL_TAXOFFICE_FILE.';


g_error_flag varchar2(30);
g_warning_flag varchar2(30);
g_error_count NUMBER;
g_payroll_action_id	NUMBER;
g_assignment_number  VARCHAR2(30);
g_full_name		VARCHAR2(150);
g_debug boolean;

/*------------------------------------------------------------------------------
|Name           : GET_PARAMETER    					                           |
|Type		    : Function							                           |
|Description    : Funtion to get the parameters of the archive process     	   |
-------------------------------------------------------------------------------*/

function get_parameter(
         p_parameter_string in varchar2
        ,p_token            in varchar2
        ,p_segment_number   in number default null) RETURN varchar2
IS

	l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
	l_start_pos  NUMBER;
	l_delimiter  varchar2(1):=' ';
	l_proc VARCHAR2(400):= g_package||' get parameter ';

BEGIN
	if g_debug then
		hr_utility.set_location('Entering get_parameter',52);
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
	if g_debug then
		hr_utility.set_location('Leaving get_parameter',53);
	end if;

	RETURN l_parameter;
END get_parameter;

-----------------------------------------------------------------------------
-- GET_ALL_PARAMETERS gets all parameters for the payroll action
-----------------------------------------------------------------------------
PROCEDURE get_all_parameters (
          p_payroll_action_id     IN         NUMBER
         ,p_business_group_id     OUT NOCOPY NUMBER
         ,p_effective_date        OUT NOCOPY DATE
         ,p_tax_year              OUT NOCOPY date
         ,p_employer              OUT NOCOPY number
         ,p_org_struct_id         OUT NOCOPY number) IS
--
  CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
  SELECT fnd_date.canonical_to_date(pay_nl_taxoffice_file.get_parameter(legislative_parameters,'REPORT_YEAR'))
        ,pay_nl_taxoffice_file.get_parameter(legislative_parameters,'EMPLOYER_ID')
        ,pay_nl_taxoffice_file.get_parameter(legislative_parameters,'ORG_HIERARCHY')
        ,effective_date
        ,business_group_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
--
  l_effective_date date;
  l_proc VARCHAR2(400):= g_package||' get_all_parameters ';
--
BEGIN
	if g_debug then
    		hr_utility.set_location('Entering get_all_parameters',51);
    	end if;

	OPEN csr_parameter_info (p_payroll_action_id);
	FETCH csr_parameter_info INTO
	p_tax_year, p_employer, p_org_struct_id
	,p_effective_date,p_business_group_id;
	CLOSE csr_parameter_info;

	if g_debug then
		hr_utility.set_location('Leaving get_all_parameters',54);
	end if;
END;



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
|Name       : RANGE_CODE                                       	    |
|Type		: Procedure							                      |
|Description: This procedure returns a sql string to select a range of|
|		  assignments eligible for archival
----------------------------------------------------------------------*/

Procedure RANGE_CODE (pactid    IN    NUMBER
                     ,sqlstr    OUT   NOCOPY VARCHAR2) is
	v_log_header   VARCHAR2(255);

	l_business_group_id number;
	l_effective_date date;
	l_tax_year date;
	l_employer_id number;
	l_org_struct_id number;

	l_sender_details number;
	l_sender_tax_rep_name varchar2(255);
	l_sender_tax_reg_number varchar2(255);
	l_tax_rep_name varchar2(255);
	l_tax_reg_number varchar2(255);

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
    	-- g_debug:=TRUE;
    	if g_debug then
    		hr_utility.trace_on(NULL,'TOF');
    		hr_utility.set_location('Entering Range Code',50);
	end if;

	g_error_count  := 0;
  	g_payroll_action_id:=pactid;

	get_all_parameters (pactid
			   ,l_business_group_id
			   ,l_effective_date
			   ,l_tax_year
			   ,l_employer_id
			   ,l_org_struct_id);

	l_sender_details:=GET_TOS_SENDER_DETAILS(l_business_group_id,l_employer_id,l_sender_tax_rep_name,l_sender_tax_reg_number,l_tax_rep_name,l_tax_reg_number);
	l_org_address:=PAY_NL_GENERAL.GET_ORGANIZATION_ADDRESS(l_employer_id,l_business_group_id,l_house_number,l_house_no_add,l_street_name,l_line1,l_line2,l_line3,l_city,l_country,l_postal_code);
	l_sender_address:=PAY_NL_GENERAL.GET_ORGANIZATION_ADDRESS(l_business_group_id,l_business_group_id,l_sen_house_number,l_sen_house_no_add,l_sen_street_name,l_sen_line1,l_sen_line2,l_sen_line3,l_sen_city,l_sen_country,l_sen_postal_code);

	l_sender_address_field := l_sen_street_name || l_sen_house_number || l_sen_house_no_add;
	l_sen_city_field := l_sen_postal_code || l_sen_city;
	l_tax_address_field := l_street_name || l_house_number || l_house_no_add;
	l_tax_city_field := l_postal_code || l_city;



	Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_NAME',l_sender_tax_rep_name);
	Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_ADDR',l_sender_address_field);
	Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_CITY',l_sen_city_field);
	Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_SENDER_REG_NUM',l_sender_tax_reg_number);
	Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_TAX_REPORTING_NAME',l_tax_rep_name);
	Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_ER_ADDR',l_tax_address_field);
	Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_CITY',l_tax_city_field);
	Mandatory_Check('PAY_NL_ER_REQUIRED_FIELD','NL_TAX_REGISTRATION_NUMBER',l_tax_reg_number);


	/*Return the SELECT Statement to select a range of assignments
	eligible for archival */

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



Procedure ARCHIVE_CODE (p_assignment_action_id  IN NUMBER
			,p_effective_date       IN DATE) IS


BEGIN
	--g_debug:=TRUE;
	if g_debug then
		hr_utility.set_location('Entering Archive Code',800);
		hr_utility.set_location('Leaving Archive Code',800);
	end if;

END ARCHIVE_CODE;




/*--------------------------------------------------------------------
|Name       : ASSIGNMENT_ACTION_CODE  	                            |
|Type		: Procedure							                      |
|Description: This procedure Fetches,validates and
|             generates Assignment Action for the File Process
|             Locks the Archive Assignment Action Record.
----------------------------------------------------------------------*/


Procedure ASSIGNMENT_ACTION_CODE (
				 p_payroll_action_id  in number
				,p_start_person_id   in number
				,p_end_person_id     in number
				,p_chunk             in number) IS
	/*Cursor Fetches  All the Archived Assignment Records
	that have not been processed in a previous run of a
	Annual Tax Statement File process for the selected year and the Employer matches
	the one selected in the SRS Request */
	CURSOR Cur_EE_ATS_File(lp_employer_id number,
		lp_Tax_Year_Start_Date Date,
		lp_Tax_Year_End_Date Date,
		lp_start_person_id number,
		lp_end_person_id number) IS
	Select
		 ee_ats.effective_date
		,ee_ats.action_information1 employer_id
		,ee_ats.action_information2 person_id
		,ee_ats.action_information3 assignment_id
		,ee_ats.action_context_id arch_ass_act_id
		,pap.full_name full_name
		,paa.assignment_number assignment_number
	from pay_action_information ee_ats
	    ,per_all_people_f pap
	    ,per_all_assignments_f paa
	WHERE ee_ats.action_context_type='AAP'
	AND ee_ats.action_information_category = 'NL ATS EMPLOYEE DETAILS'
	AND ee_ats.effective_date  =lp_Tax_Year_End_Date
	AND ee_ats.action_information1 =fnd_number.number_to_canonical(lp_employer_id)
	AND fnd_number.canonical_to_number(ee_ats.action_information2) BETWEEN lp_start_person_id AND lp_end_person_id
	AND paa.assignment_id = fnd_number.canonical_to_number(ee_ats.action_information3)
	AND 	paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM per_assignment_status_types past, per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   past.per_system_status = 'ACTIVE_ASSIGN'
		and   asg.assignment_status_type_id = past.assignment_status_type_id
		and   asg.effective_start_date <= lp_Tax_Year_End_Date
		and   nvl(asg.effective_end_date, lp_Tax_Year_End_Date) >= lp_Tax_Year_Start_Date

		)
	AND pap.person_id = fnd_number.canonical_to_number(ee_ats.action_information2)
	AND lp_Tax_Year_End_Date between pap.effective_start_date and pap.effective_end_date
	AND pap.person_id = paa.person_id
	AND not exists
	(select arc_lck.locked_action_id from pay_action_interlocks arc_lck
	where arc_lck.locked_action_id = ee_ats.action_context_id);




	l_business_group_id number;
	l_effective_date date;
	l_tax_year date;
	l_tax_year_date varchar2(100);
	l_tax_year_start_date date;
	l_tax_year_end_date date;
	l_employer_id number;
	l_org_struct_id number;
	l_asg_act_id number;
	l_assignment_id number;
	l_tax_yr date;
	l_locked_aai number;

	l_employee_address number;
	l_ee_house_number varchar2(255);
	l_ee_house_no_add varchar2(255);
	l_ee_street_name varchar2(255);
	l_ee_line1 varchar2(255);
	l_ee_line2 varchar2(255);
	l_ee_line3 varchar2(255);
	l_ee_city varchar2(255);
	l_ee_country varchar2(255);
	l_ee_postal_code varchar2(255);
	l_ee_house_no_field varchar2(255);



BEGIN

	if g_debug then
		hr_utility.trace_on(NULL,'TOF');
		hr_utility.set_location('Entering ASSIGNMENT_ACTION_CODE',600);
	end if;

	g_error_flag := hr_general.decode_lookup('HR_NL_REPORT_LABELS','ERROR');

	/*Fetch the Process Parameters by invoking the above procedure
	 Get_all_parameters
	*/
	get_all_parameters (
		  p_payroll_action_id,l_business_group_id
		 ,l_effective_date,l_tax_year,l_employer_id,l_org_struct_id);

	hr_utility.set_location('l_business_group_id'||l_business_group_id,425);
	hr_utility.set_location('l_effective_date'||l_effective_date,425);
	hr_utility.set_location('l_tax_year'||l_tax_year,425);
	hr_utility.set_location('l_employer_id'||l_employer_id,425);



	l_tax_year_date:=to_char(l_tax_year,'YYYY');
	l_tax_year_start_date := to_date('01-01-'||l_tax_year_date,'DD-MM-YYYY');
	l_tax_year_end_date:= to_date('31-12-'||l_tax_year_date,'DD-MM-YYYY');

	if g_debug then
		hr_utility.set_location('l_tax_year_end_date'||l_tax_year_end_date,425);
		hr_utility.set_location('l_tax_year_start_date'||l_tax_year_start_date,425);
	end if;


	FOR Cur_EE_ATS_File_rec in Cur_EE_ATS_File(l_employer_id, l_tax_year_start_date, l_tax_year_end_date, p_start_person_id,p_end_person_id)

	LOOP

		l_assignment_id :=Cur_EE_ATS_File_rec.assignment_id;
		g_assignment_number:=Cur_EE_ATS_File_rec.assignment_number;
		g_full_name:=Cur_EE_ATS_File_rec.full_name;
		g_error_count:=0;

		if g_debug then
			hr_utility.set_location('l_assignment_id'||l_assignment_id,425);
			hr_utility.set_location('effective_date'||Cur_EE_ATS_File_rec.effective_date,425);
			hr_utility.set_location('person_id'||Cur_EE_ATS_File_rec.person_id,425);
			hr_utility.set_location('employer_id'||Cur_EE_ATS_File_rec.employer_id,425);
		end if;

		l_locked_aai:=Cur_EE_ATS_File_rec.arch_ass_act_id;
		hr_utility.set_location('l_locked_aai'||l_locked_aai,425);

		if l_locked_aai is not null then

			l_employee_address:=PAY_NL_GENERAL.get_employee_address(Cur_EE_ATS_File_rec.person_id,l_tax_year_end_date,l_ee_house_number,l_ee_house_no_add,l_ee_street_name,l_ee_line1,l_ee_line2,l_ee_line3,l_ee_city,l_ee_country,l_ee_postal_code);

			l_ee_house_no_field := l_ee_house_number || l_ee_house_no_add;


			Mandatory_Check('PAY_NL_ASG_REQUIRED_FIELD','NL_STREET',l_ee_street_name);
			Mandatory_Check('PAY_NL_ASG_REQUIRED_FIELD','NL_HNO_ADD_TO_HNO',l_ee_house_no_field );
			Mandatory_Check('PAY_NL_ASG_REQUIRED_FIELD','NL_CITY',l_ee_city);



			if g_error_count=0 then


				/*Create the Assignment Action for the Assignment
				and Lock the respective Annual tax Statement Archive Assignment Action for the Assignment
				*/
				SELECT pay_assignment_actions_s.NEXTVAL
				INTO   l_asg_act_id
				FROM   dual;
				--
				-- Create the archive assignment action
				--
				hr_nonrun_asact.insact(l_asg_act_id,l_Assignment_ID, p_payroll_action_id,p_chunk,NULL);
				hr_nonrun_asact.insint(l_asg_act_id,l_locked_aai);
			end if;
		end if;

	END LOOP;

	if g_debug then
		hr_utility.set_location('Exiting ASSIGNMENT_ACTION_CODE',600);
	end if;

END ASSIGNMENT_ACTION_CODE;

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_INIT                                            	    |
|Type		    : Procedure							                            |
|Description    : Initialization Code for Archiver                              |
-------------------------------------------------------------------------------*/

Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER) IS

BEGIN
	if g_debug then
		hr_utility.set_location('Entering Archive Init',600);
		hr_utility.set_location('Leaving Archive Init',700);
	end if;

END ARCHIVE_INIT;

/*-----------------------------------------------------------------------------
|Name       : Get_TOS_Sender_Details                                           |
|Type       : Function							       |
|Description: Function which returns Tax office and Sender Details	       |
-------------------------------------------------------------------------------*/

FUNCTION Get_TOS_Sender_Details(P_Business_Group_Id in number
				,P_Employer_ID in number
				,P_Sender_Tax_Rep_Name out nocopy varchar2
				,P_Sender_Tax_Reg_Number out nocopy varchar2
				,P_Tax_Rep_Name out nocopy varchar2
				,P_Tax_Reg_Number out nocopy varchar2) return number IS

	CURSOR csr_Sender_tax_Details IS
	select ORG_INFORMATION3,ORG_INFORMATION4
	from hr_organization_information
	where ORG_INFORMATION_CONTEXT='NL_BG_INFO' and
	organization_id=P_Business_Group_Id;

	CURSOR csr_tax_details IS
	select hoi.ORG_INFORMATION14,hoi.ORG_INFORMATION4
	from hr_organization_units hou,hr_organization_information hoi
	where
	hoi.org_information_context= 'NL_ORG_INFORMATION'
	and hou.business_group_id=p_business_group_id
	and hou.organization_id= hoi.organization_id
	and hou.organization_id = P_Employer_ID;

	l_number number;

BEGIN

	hr_utility.set_location('Entering Get_TOS_Sender_Details',600);

	OPEN csr_Sender_tax_Details;
	FETCH csr_Sender_tax_Details into P_Sender_Tax_Rep_Name,P_Sender_Tax_Reg_Number;
	CLOSE csr_Sender_tax_Details;

	if g_debug then
		hr_utility.set_location('P_Sender_Tax_Rep_Name'||P_Sender_Tax_Rep_Name,425);
		hr_utility.set_location('P_Sender_Tax_Reg_Number'||P_Sender_Tax_Reg_Number,425);
	end if;

	OPEN csr_tax_details;
	FETCH csr_tax_details into P_Tax_Rep_Name,P_Tax_Reg_Number;
	CLOSE csr_tax_details;

	if g_debug then
		hr_utility.set_location('P_Tax_Rep_Name'||P_Tax_Rep_Name,425);
		hr_utility.set_location('P_Tax_Reg_Number'||P_Tax_Reg_Number,425);

		hr_utility.set_location('Leaving Get_TOS_Sender_Details',700);
	end if;

	l_number:=1;
	return l_number;

END Get_TOS_Sender_Details;


END PAY_NL_TAXOFFICE_FILE ;

/
