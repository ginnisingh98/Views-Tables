--------------------------------------------------------
--  DDL for Package Body PAY_NO_TAX_LEVY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_TAX_LEVY" AS
/* $Header: pynotaxlevy.pkb 120.4.12000000.1 2007/05/20 08:06:12 rlingama noship $ */
	g_debug   boolean   :=  hr_utility.debug_enabled;
	l_business_id		NUMBER;
	l_leg_emp_id		NUMBER;
	l_effective_date	DATE;
	l_bimonth_term		VARCHAR2(10);
	l_archive		VARCHAR2(3);
	l_payee_org		NUMBER;
	g_err_num		NUMBER;

 /* GET PARAMETER */
 FUNCTION GET_PARAMETER(
	 p_parameter_string IN VARCHAR2
	,p_token            IN VARCHAR2
	,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2
 IS
	   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
	   l_start_pos  NUMBER;
	   l_delimiter  VARCHAR2(1):=' ';

BEGIN
	 IF g_debug THEN
	  hr_utility.set_location(' Entering Function GET_PARAMETER',10);
	 END IF;
	 l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');

	 IF l_start_pos = 0 THEN
		l_delimiter := '|';
		l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
	 END IF;

	 IF l_start_pos <> 0 THEN
		l_start_pos := l_start_pos + length(p_token||'=');
		l_parameter := substr(p_parameter_string, l_start_pos,
		                  instr(p_parameter_string||' ', l_delimiter,l_start_pos) - l_start_pos);

		 IF p_segment_number IS NOT NULL THEN
			l_parameter := ':'||l_parameter||':';
			l_parameter := substr(l_parameter,
			instr(l_parameter,':',1,p_segment_number)+1,
			instr(l_parameter,':',1,p_segment_number+1) -1
			- instr(l_parameter,':',1,p_segment_number));
		END IF;
	END IF;

	RETURN l_parameter;
	 IF g_debug THEN
	      hr_utility.set_location(' Leaving Function GET_PARAMETER',20);
	 END IF;

 END GET_PARAMETER;


/* GET ALL PARAMETERS */
PROCEDURE GET_ALL_PARAMETERS(
 		 p_payroll_action_id	IN           NUMBER
		,p_business_group_id    OUT  NOCOPY  NUMBER
		,p_legal_employer_id	OUT  NOCOPY  NUMBER
		,p_effective_date	OUT  NOCOPY  DATE
		,p_bimonth_term		OUT  NOCOPY  VARCHAR2
		,p_archive		OUT  NOCOPY  VARCHAR2
		,p_payee_org    OUT NOCOPY NUMBER
		)IS


	CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
	SELECT 	 PAY_NO_TAX_LEVY.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER_ID')
		,PAY_NO_TAX_LEVY.GET_PARAMETER(legislative_parameters,'BIMONTH_TERM')
		,PAY_NO_TAX_LEVY.GET_PARAMETER(legislative_parameters,'ARCHIVE')
		,PAY_NO_TAX_LEVY.GET_PARAMETER(legislative_parameters,'THIRD_PARTY_PAYEE')
		,effective_date
		,business_group_id
	FROM  pay_payroll_actions
	WHERE payroll_action_id = p_payroll_action_id;

BEGIN

	 OPEN csr_parameter_info (p_payroll_action_id);
	 FETCH csr_parameter_info  INTO	p_legal_employer_id ,p_bimonth_term ,p_archive,p_payee_org ,p_effective_date ,p_business_group_id;
	 CLOSE csr_parameter_info;
IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
END IF;

 END GET_ALL_PARAMETERS;


 /* RANGE CODE */
 PROCEDURE RANGE_CODE (pactid    IN    NUMBER
		      ,sqlstr    OUT   NOCOPY VARCHAR2)
 IS

-- Variable declarations
	l_count			NUMBER := 0;
	l_action_info_id	NUMBER;
	l_ovn			NUMBER;
	l_bimonth_year		NUMBER;
	l_le_org_num		VARCHAR2(240);
	l_le_name		VARCHAR2(240);
	l_payee_org_name    hr_all_organization_units.NAME%type;


-- cursor to get Legal Employer Name and Org Num

cursor csr_le_name ( l_leg_emp_id  NUMBER ) is
select hou.name
from hr_organization_units          hou
where hou.organization_id = l_leg_emp_id;


cursor csr_org_number ( l_leg_emp_id  NUMBER ) is
select hoi.org_information1
from hr_organization_information    hoi
where  hoi.organization_id = l_leg_emp_id
and   hoi.org_information_context = to_char('NO_LEGAL_EMPLOYER_DETAILS');


--cursor to get the third_party_name
cursor csr_third_party_name(l_payee_org number) is
select distinct haou.name name from hr_all_organization_units haou
where haou.ORGANIZATION_ID=l_payee_org;

--cursor to check current archive exists
cursor csr_count is
select count(*)
from   pay_action_information
where  action_information_category = 'EMEA REPORT DETAILS'
and    action_information1         = 'PYNOTAXLEVYA'
and    action_context_id           = pactid;

--cursor to get the bimonth year
cursor csr_bimonth_year is
select to_char(l_effective_date,'RRRR') from dual;


BEGIN
 IF g_debug THEN
      hr_utility.set_location(' Entering Procedure RANGE_CODE',40);
 END IF;
	 -- the sql string to return
	 sqlstr := 'SELECT DISTINCT person_id
		FROM  per_people_f ppf
		     ,pay_payroll_actions ppa
		WHERE ppa.payroll_action_id = :payroll_action_id
		AND   ppa.business_group_id = ppf.business_group_id
		ORDER BY ppf.person_id';

          -- fetch the data for the REPORT DETAILS
	 PAY_NO_TAX_LEVY.GET_ALL_PARAMETERS(
			pactid
			,l_business_id
			,l_leg_emp_id
			,l_effective_date
			,l_bimonth_term
			,l_archive
			,l_payee_org) ;

	 -- check if we have to archive again
	 if  (l_archive = 'Y') then

	   -- check if record for current archive exists
	   open csr_count;
	   fetch csr_count into l_count;
	   close csr_count;

	   open csr_third_party_name(l_payee_org);
	   fetch csr_third_party_name into l_payee_org_name;
	   close csr_third_party_name;

	   -- archive Report Details only if no record exosts
	   IF (l_count < 1) THEN
	       -- fetch LE name and LE Org Num from LE ID
	       OPEN csr_le_name (l_leg_emp_id) ;
	       FETCH csr_le_name INTO l_le_name ;
	       CLOSE csr_le_name ;

   	       OPEN csr_org_number (l_leg_emp_id) ;
	       FETCH csr_org_number INTO l_le_org_num ;
	       CLOSE csr_org_number ;

	       -- get the bimonth year
		open csr_bimonth_year;
		fetch csr_bimonth_year into l_bimonth_year;
		close csr_bimonth_year;

	       -- archive the report details

	pay_action_information_api.create_action_information (
		 p_action_information_id        => l_action_info_id	-- out parameter
		,p_object_version_number        => l_ovn		-- out parameter
		,p_action_context_id            => pactid		-- context id = payroll action id (of Archive)
		,p_action_context_type          => 'PA'			-- context type
		,p_effective_date               => l_effective_date	-- Date of running the archive
		,p_action_information_category  => 'EMEA REPORT DETAILS' -- Information Category
		,p_tax_unit_id                  => l_leg_emp_id		-- Legal Employer ID
		,p_jurisdiction_code            => NULL			-- Tax Municipality ID
		,p_action_information1          => 'PYNOTAXLEVYA'	-- Conc Prg Short Name
		,p_action_information2          => NULL			-- Local Unit ID
		,p_action_information3          => l_le_name		-- Legal Employer Name
		,p_action_information4          => l_le_org_num		-- Legal Employer Organization Number
		,p_action_information5          => l_bimonth_term	-- Reporting Bimonth Term
		,p_action_information6          => l_bimonth_year	-- Reporting Bimonth Year
		,p_action_information7          => l_business_id  	-- Business Group ID
		,p_action_information8          => l_payee_org		--Third Party id
		,p_action_information9          => l_payee_org_name);	--Third Party name

	   END IF; -- l_count < 1

	 END IF; -- l_archive = 'Y'
 IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);
 END IF;

 END RANGE_CODE;

-------------------------------------------------------------------------------------------------------------------------
 /* INITIALIZATION CODE */
 PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
 IS

 BEGIN
  IF g_debug THEN
      hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',80);
 END IF;

	NULL;
IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',90);
END IF;
exception when others then
 g_err_num := SQLCODE;
  IF g_debug THEN
      hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In INITIALIZATION_CODE',180);
  END IF;

 END INITIALIZATION_CODE;

-------------------------------------------------------------------------------------------------------------------------
 /* ASSIGNMENT ACTION CODE */
 PROCEDURE ASSIGNMENT_ACTION_CODE
 (p_payroll_action_id     IN NUMBER
 ,p_start_person          IN NUMBER
 ,p_end_person            IN NUMBER
 ,p_chunk                 IN NUMBER)
 IS

 ---------------------------------------------------------------------------------------------------------------
  CURSOR csr_assignments
        (p_payroll_action_id    NUMBER,
	 p_leg_emp_id		NUMBER,
         p_start_person      	NUMBER,
         p_end_person           NUMBER,
         l_start_date		DATE,
         l_end_date		DATE,
	 p_payee_org		NUMBER)
 IS

	SELECT
	assact.ASSIGNMENT_ID		asg_id
	,assact.assignment_action_id	asg_act_id
	,assact.TAX_UNIT_ID		tax_unit_id
	,prr.LOCAL_UNIT_ID		local_unit_id
	--,prr.JURISDICTION_CODE	tax_mun_id
	,(select act_con.CONTEXT_VALUE  from pay_action_contexts act_con,ff_contexts con
	where con.CONTEXT_NAME = 'JURISDICTION_CODE'
	AND act_con.CONTEXT_ID = con.CONTEXT_ID
	AND act_con.ASSIGNMENT_ACTION_ID = assact.ASSIGNMENT_ACTION_ID
	AND act_con.ASSIGNMENT_ID = assact.ASSIGNMENT_ID) tax_mun_id

	FROM
	pay_assignment_actions	assact
	,pay_assignment_actions	assact1
	,pay_payroll_actions	ppa
	,pay_payroll_actions	ppa2
	,pay_payroll_actions	ppa3
	,per_all_assignments_f	asg
	,pay_element_types_f    ele
	,pay_run_results	prr
	,pay_run_result_values	prrv
	,pay_input_values_f	inpv
	,pay_action_interlocks  pai


	WHERE -- initial conditions

	ppa.payroll_action_id = p_payroll_action_id

	-- for 2nd pay payroll act table
	AND ppa2.date_earned between l_start_date and l_end_date
	AND ppa2.action_type IN ('R','Q')  -- Payroll Run or Quickpay Run

	-- for asg act table
	AND assact.PAYROLL_ACTION_ID = ppa2.PAYROLL_ACTION_ID
	AND assact.TAX_UNIT_ID = p_leg_emp_id
	AND assact.action_status = 'C'  -- Completed
	AND assact.source_action_id  IS NOT NULL -- Not Master Action


	-- for asg table
	AND assact.ASSIGNMENT_ID = asg.ASSIGNMENT_ID
	--AND ppa.date_earned between asg.EFFECTIVE_START_DATE and asg.EFFECTIVE_END_DATE
	--AND ppa.effective_date between asg.EFFECTIVE_START_DATE and asg.EFFECTIVE_END_DATE
	AND ppa2.effective_date between asg.EFFECTIVE_START_DATE and asg.EFFECTIVE_END_DATE -- Bug 5116907 fix
	AND asg.person_id   BETWEEN p_start_person AND p_end_person

	-- for run results
	AND assact.ASSIGNMENT_ACTION_ID = prr.ASSIGNMENT_ACTION_ID

	--for prepayments
	AND    assact1.action_status           = 'C' -- Completed
	AND    assact1.assignment_action_id    = pai.locking_action_id
	AND    assact1.payroll_action_id       = ppa3.payroll_action_id
	AND    ppa3.action_type            IN ('P','U')
	AND    ppa3.date_earned between l_start_date and l_end_date

	AND assact.ASSIGNMENT_ACTION_ID = pai.locked_action_id

	-- for element 'Wage Attachment Tax Levy'
	AND prr.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
	AND ele.ELEMENT_NAME = 'Wage Attachment Tax Levy'
	AND ele.LEGISLATION_CODE = 'NO'
	--AND ppa.date_earned between ele.EFFECTIVE_START_DATE and ele.EFFECTIVE_END_DATE
	AND ppa.effective_date between ele.EFFECTIVE_START_DATE and ele.EFFECTIVE_END_DATE

	AND prr.RUN_RESULT_ID = prrv.RUN_RESULT_ID
	AND inpv.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
	AND inpv.NAME = 'Third Party Payee'
	AND inpv.LEGISLATION_CODE = 'NO'
	--AND ppa.date_earned between inpv.EFFECTIVE_START_DATE and inpv.EFFECTIVE_END_DATE
	AND prrv.INPUT_VALUE_ID = inpv.INPUT_VALUE_ID
	--and haou.organization_id=prrv5.result_value
	AND prrv.result_value like nvl(to_char(p_payee_org),prrv.result_value)


	ORDER BY assact.assignment_id ;

--to get the next action_id
cursor csr_actid is
 SELECT pay_assignment_actions_s.NEXTVAL  FROM   dual;
 ---------------------------------------------------------------------------------------------------------------
	l_count			NUMBER := 0;
	l_action_info_id	NUMBER;
	l_ovn			NUMBER;
	l_bimonth_year		NUMBER;
	l_le_org_num		VARCHAR2(240);
	l_le_name		VARCHAR2(240);
	l_start_date		DATE;
	l_end_date		DATE;
	l_actid			NUMBER;
	l_tax_mun_id		NUMBER;
	l_local_unit_id		NUMBER;



BEGIN
IF g_debug THEN
      hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
END IF;
          -- fetch the data for the REPORT DETAILS
	 PAY_NO_TAX_LEVY.GET_ALL_PARAMETERS(
			p_payroll_action_id
			,l_business_id
			,l_leg_emp_id
			,l_effective_date
			,l_bimonth_term
			,l_archive
			,l_payee_org) ;

   	 -- check if we have to archive again
 IF  (l_archive = 'Y')

   THEN
	--fnd_file.put_line(fnd_file.log,'SUGARG: l_archive = Y');

	-- get the period start and end dates

	select to_date(decode(l_bimonth_term,'01','JAN','02','MAR','03','MAY','04','JUL','05','SEP','06','NOV','00','JAN')
				||to_char(l_effective_date,'YY'),'MONYY') into l_start_date from dual;

	IF l_bimonth_term IS NOT NULL AND l_bimonth_term <> '00' THEN

	select last_day(to_date(decode(l_bimonth_term,'01','FEB','02','APR','03','JUN','04','AUG','05','OCT','06','DEC','DEC')
				||to_char(l_effective_date,'YY'),'MONYY')) into l_end_date from dual;
	ELSE
		l_end_date := l_effective_date;

 END IF;

      -- fetch assignments details

      FOR csr_rec IN csr_assignments
		( p_payroll_action_id
		 ,l_leg_emp_id
		 ,p_start_person
		 ,p_end_person
		 ,l_start_date
		 ,l_end_date
		 ,l_payee_org)
      LOOP
      open csr_actid;
      fetch csr_actid into l_actid;
      close csr_actid;

  -- Create the archive assignment action
  hr_nonrun_asact.insact(l_actid ,csr_rec.asg_id ,p_payroll_action_id ,p_chunk ,NULL);

	  -- Creating Initial Archive Entries
  pay_action_information_api.create_action_information (

	 p_action_information_id        => l_action_info_id		-- out parameter
	,p_object_version_number        => l_ovn			-- out parameter
	,p_action_context_id            => l_actid        		-- context id = assignment action id (of Archive)
	,p_action_context_type          => 'AAP'			-- context type
	,p_effective_date               => l_effective_date		-- Date of running the archive
	,p_assignment_id		=> csr_rec.asg_id		-- Assignment ID
	,p_action_information_category  => 'EMEA REPORT INFORMATION'	-- Information Category
	,p_tax_unit_id                  => l_leg_emp_id			-- Legal Employer ID
	,p_jurisdiction_code            => csr_rec.tax_mun_id		-- Tax Municipality ID
	,p_action_information1          => 'PYNOTAXLEVYA'		-- Conc Prg Short Name
	,p_action_information2          => csr_rec.local_unit_id	-- Local Unit ID
	,p_action_information3         => p_payroll_action_id		-- payroll action id (of Archive)
	,p_action_information4          => csr_rec.asg_act_id		-- Original / Main Asg Action ID

	);

      END LOOP;

 END IF; -- l_archive = 'Y'

 IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
 END IF;

 END ASSIGNMENT_ACTION_CODE;


-------------------------------------------------------------------------------------------------------------------------
 /* ARCHIVE CODE */
 PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
 		      ,p_effective_date    IN DATE)
 IS

-- Cursor to get the action_information_id and original/main assignment_action_id

cursor csr_get_act_info (p_assignment_action_id  NUMBER , p_effective_date DATE) is
select to_number(ACTION_INFORMATION_ID) , to_number(ACTION_INFORMATION4)
,to_number(ACTION_INFORMATION3)
from pay_action_information
where ACTION_INFORMATION_CATEGORY = 'EMEA REPORT INFORMATION'
and   ACTION_INFORMATION1 = 'PYNOTAXLEVYA'
and   ACTION_CONTEXT_TYPE = 'AAP'
and   ACTION_CONTEXT_ID = p_assignment_action_id
and   EFFECTIVE_DATE = p_effective_date ;

--varibale declaration
l_third_party_id	NUMBER;
l_main_asg_act_id	NUMBER;
l_payroll_action_id NUMBER ;

-- cursor to get the assignment,person details and run values

 CURSOR csr_asg_details (p_assignment_action_id	NUMBER) IS
SELECT
 per.last_name last_name
,per.first_name first_name
,per.order_name order_Name
,per.title per_title
,per.date_of_birth dob
,per.original_date_of_hire doh
,per.PERSON_ID			per_id
,per.NATIONAL_IDENTIFIER	per_ni
,per.EMPLOYEE_NUMBER		emp_no
,per.business_group_id		bg_id
,prrv1.result_value		res_val_1 -- Pay Value
,prrv2.result_value		res_val_2 -- Income Year
,prrv3.result_value		res_val_3 -- Deduction Percentage
,prrv4.result_value		res_val_4 -- Fixed Deduction Amount
,prrv5.result_value		res_val_5 -- Third Party Payee

FROM
pay_assignment_actions	assact
,pay_payroll_actions	ppa
,per_all_assignments_f	asg
,per_all_people_f	per
,pay_element_types_f    ele
,pay_input_values_f	inpv1
,pay_input_values_f	inpv2
,pay_input_values_f	inpv3
,pay_input_values_f	inpv4
,pay_input_values_f	inpv5
,pay_run_results	prr
,pay_run_result_values	prrv1
,pay_run_result_values	prrv2
,pay_run_result_values	prrv3
,pay_run_result_values	prrv4
,pay_run_result_values	prrv5


WHERE assact.ASSIGNMENT_ACTION_ID = p_assignment_action_id
AND assact.ASSIGNMENT_ID = asg.ASSIGNMENT_ID
AND ppa.date_earned between asg.EFFECTIVE_START_DATE and asg.EFFECTIVE_END_DATE
AND asg.PERSON_ID = per.PERSON_ID
AND ppa.date_earned between per.EFFECTIVE_START_DATE and per.EFFECTIVE_END_DATE
AND assact.PAYROLL_ACTION_ID = ppa.PAYROLL_ACTION_ID
AND assact.ASSIGNMENT_ACTION_ID = prr.ASSIGNMENT_ACTION_ID

-- for element 'Wage Attachment Tax Levy'
AND prr.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
AND ele.ELEMENT_NAME = 'Wage Attachment Tax Levy'
AND ele.LEGISLATION_CODE = 'NO'
AND ppa.date_earned between ele.EFFECTIVE_START_DATE and ele.EFFECTIVE_END_DATE

-- for input value 'Pay Value'
AND prr.RUN_RESULT_ID = prrv1.RUN_RESULT_ID
AND inpv1.NAME = 'Pay Value'
AND inpv1.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
AND inpv1.LEGISLATION_CODE = 'NO'
AND ppa.date_earned between inpv1.EFFECTIVE_START_DATE and inpv1.EFFECTIVE_END_DATE
AND prrv1.INPUT_VALUE_ID = inpv1.INPUT_VALUE_ID

-- for input value 'Income Year'
AND prr.RUN_RESULT_ID = prrv2.RUN_RESULT_ID
AND inpv2.NAME = 'Income Year'
AND inpv2.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
AND inpv2.LEGISLATION_CODE = 'NO'
AND ppa.date_earned between inpv2.EFFECTIVE_START_DATE and inpv2.EFFECTIVE_END_DATE
AND prrv2.INPUT_VALUE_ID = inpv2.INPUT_VALUE_ID

-- for input value 'Deduction Percentage'
AND prr.RUN_RESULT_ID = prrv3.RUN_RESULT_ID
AND inpv3.NAME = 'Deduction Percentage'
AND inpv3.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
AND inpv3.LEGISLATION_CODE = 'NO'
AND ppa.date_earned between inpv3.EFFECTIVE_START_DATE and inpv3.EFFECTIVE_END_DATE
AND prrv3.INPUT_VALUE_ID = inpv3.INPUT_VALUE_ID

-- for input value 'Fixed Deduction Amount'
AND prr.RUN_RESULT_ID = prrv4.RUN_RESULT_ID
AND inpv4.NAME = 'Fixed Deduction Amount'
AND inpv4.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
AND inpv4.LEGISLATION_CODE = 'NO'
AND ppa.date_earned between inpv4.EFFECTIVE_START_DATE and inpv4.EFFECTIVE_END_DATE
AND prrv4.INPUT_VALUE_ID = inpv4.INPUT_VALUE_ID

-- for input value 'Third Party Payee'
AND prr.RUN_RESULT_ID = prrv5.RUN_RESULT_ID
AND inpv5.NAME = 'Third Party Payee'
AND inpv5.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
AND inpv5.LEGISLATION_CODE = 'NO'
AND ppa.date_earned between inpv5.EFFECTIVE_START_DATE and inpv5.EFFECTIVE_END_DATE
AND prrv5.INPUT_VALUE_ID = inpv5.INPUT_VALUE_ID;



-- cursor to get Third Party Destination Acc Number

cursor csr_third_party_dest_acc (p_organization_id	NUMBER) is
select  segment6
from pay_external_accounts	acc
,pay_org_payment_methods_f	pay_org
,hr_organization_information	hoi
where hoi.organization_id = p_organization_id
and hoi.org_information_context = 'NO_THIRD_PARTY_PAYMENT'
and pay_org.org_payment_method_id = hoi.org_information2
and pay_org.pmeth_information1 = 'DESTINATION'
and acc.external_account_id = pay_org.external_account_id;


-- cursor to get the third party loaction

cursor csr_third_party_loc (p_organization_id	NUMBER) is
select loc.address_line_1	line_1
,loc.address_line_2		line_2
,loc.address_line_3		line_3
,hr_general.decode_fnd_comm_lookup('NO_POSTAL_CODE',loc.postal_code) post_code
from hr_locations_all		loc
,hr_all_organization_units	hou
where hou.organization_id = p_organization_id
and loc.location_id = hou.location_id
and loc.style = 'NO';

--cursor to get the payroll_action_id
cursor 	csr_payroll_action_id is
SELECT payroll_action_id
FROM pay_assignment_actions
WHERE assignment_action_id = p_assignment_action_id ;

--cursor to get the third party name
cursor csr_third_party_name is
select name from hr_organization_units
where organization_id = l_third_party_id ;

-- cursor to fetch the balance value of TAX DEDUCTION BASIS
cursor csr_tax_dedn_basis is
select
pay_balance_pkg.get_value(pay_no_emp_cont.get_defined_balance_id('Tax Deduction Basis','_ASG_PTD'),
                          l_main_asg_act_id)
from dual;

-- Variable declaration

l_action_info_id	NUMBER;
l_ovn			NUMBER;

rec_asg_detail		csr_asg_details%rowtype;
rec_loc_detail		csr_third_party_loc%rowtype;

l_count			NUMBER := 0;
l_third_party_name	VARCHAR2(240);
l_third_party_dest_acc	VARCHAR2(150);
l_tax_dedn_basis	NUMBER;
l_new_payroll_action_id	NUMBER; -- To store the payroll action id created.


 BEGIN
 IF g_debug THEN
 		hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',380);
 END IF;

 	-- get the action_information_id and original/main assignment_action_id for this asg_act_id
	OPEN csr_get_act_info (p_assignment_action_id  , p_effective_date );
	FETCH csr_get_act_info  INTO l_action_info_id , l_main_asg_act_id ,l_new_payroll_action_id;
	CLOSE csr_get_act_info ;

           -- fetch the data for the REPORT DETAILS
	 PAY_NO_TAX_LEVY.GET_ALL_PARAMETERS(
			l_new_payroll_action_id
			,l_business_id
			,l_leg_emp_id
			,l_effective_date
			,l_bimonth_term
			,l_archive
			,l_payee_org) ;


	open csr_payroll_action_id;
	fetch csr_payroll_action_id into l_payroll_action_id;
	close csr_payroll_action_id;

-- fetch the data

 -- check if we have to archive again
 IF  (l_archive = 'Y')

   THEN

	-- fetch assignment details
	OPEN csr_asg_details (l_main_asg_act_id) ;
	FETCH csr_asg_details INTO rec_asg_detail ;
	CLOSE csr_asg_details ;

	l_third_party_id := to_number(rec_asg_detail.res_val_5) ;

	-- to get the Third Party Name
	open csr_third_party_name;
	fetch csr_third_party_name into l_third_party_name;
	close csr_third_party_name;

	-- to get the third party Destination acc no.
	OPEN csr_third_party_dest_acc (l_third_party_id) ;
	FETCH csr_third_party_dest_acc INTO l_third_party_dest_acc ;
	CLOSE csr_third_party_dest_acc ;


	-- to get the third party location details
	OPEN csr_third_party_loc (l_third_party_id) ;
	FETCH csr_third_party_loc INTO rec_loc_detail;
	CLOSE csr_third_party_loc ;

	-- to fetch the balance value of TAX DEDUCTION BASIS
	open csr_tax_dedn_basis;
	fetch csr_tax_dedn_basis into l_tax_dedn_basis;
	close csr_tax_dedn_basis;

	l_third_party_dest_acc := substr(l_third_party_dest_acc,1,4)||'.'||
	                          substr(l_third_party_dest_acc,5,2)||'.'||
				  substr(l_third_party_dest_acc,7,5) ;

  -- Updating the Initial Archive Entries
	pay_action_information_api.update_action_information (
	 p_action_information_id        => l_action_info_id		-- in parameter
	,p_object_version_number        => l_ovn			-- in out parameter
	,p_action_information5          => l_third_party_id		--Third Party ID (Tax Collector ID)
	,p_action_information6          => l_third_party_name		--Third Party Name (Tax Collector's Name)
	,p_action_information7          => rec_loc_detail.line_1	--Third Party Address Line 1
	,p_action_information8          => rec_loc_detail.line_2	--Third Party Address Line 2
	,p_action_information9          => rec_loc_detail.line_3	--Third Party Address Line 3
	,p_action_information10         => rec_loc_detail.post_code	--Third Party Postal Code + City
	,p_action_information11         => l_third_party_dest_acc	--Third Party Destination Bank Account Number (Formatted)
	,p_action_information12         => rec_asg_detail.bg_id		--Business Group ID
	,p_action_information13         => rec_asg_detail.per_id	--PERSON_ID
	,p_action_information14         => rec_asg_detail.per_ni	--Person NATIONAL_IDENTIFIER
	,p_action_information15         => rec_asg_detail.last_name	--Person Lastname
	,p_action_information16         => rec_asg_detail.first_name	--Person Firstname
	,p_action_information17         => rec_asg_detail.order_name	--Person Ordername
	,p_action_information18         => rec_asg_detail.emp_no	--Person Employee number
	,p_action_information19         => rec_asg_detail.dob		--Person date of birth
	,p_action_information20         => rec_asg_detail.doh		--Person date of hiring
	,p_action_information21         => rec_asg_detail.per_title	--Person title
	,p_action_information22         => rec_asg_detail.res_val_2 	--Income Year (Input Value)
	,p_action_information23         => rec_asg_detail.res_val_3 	--Percentage (Input Value)
	,p_action_information24         => rec_asg_detail.res_val_4 	--Amount (Input Value)
	,p_action_information25         => rec_asg_detail.res_val_1 	--Deducted This Period (Input Value)
	,p_action_information26         => l_tax_dedn_basis		--Tax Deduction Basis (Balance Value)
	,p_action_information27         => NULL );


 END IF; -- l_archive = 'Y'


 IF g_debug THEN
 		hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',390);
 END IF;

 END ARCHIVE_CODE;

-------------------------------------------------------------------------------------------------------------------------
procedure populate_details(p_payroll_action_id in varchar2,
		  	   p_template_name in varchar2,
			   p_xml out nocopy clob) is

l_employer hr_all_organization_units.name%type;
l_orgnumber hr_organization_information.org_information1%type;
l_term varchar2(30);
l_year varchar2(8);
l_thirdparty_id pay_action_information.ACTION_INFORMATION5%type:='-999';
l_payroll_action_id varchar2(150);
l_archiver varchar2(150);
xml_ctr  number;
l_IANA_charset VARCHAR2 (50);

cursor csr_legalemployer is
select  pai.action_information3 employer,pai.action_information4 orgnumber,
pai.action_information5 term,pai.action_information6 year,
pai.effective_date || ' (' ||pai.action_context_id||')' archiver
from pay_action_information pai
where to_char(pai.action_context_id)=l_payroll_action_id;

--Bug 5116700 fix - Taking the sum of TaxDeductionBasis
cursor csr_emp is
select thirdparty_id,thirdparty_name,thirdparty_address,
bankaccountno,ni,last_name,first_name,order_name,
emp_no,emp_dob,emp_doh,emp_title,
sum(TaxDeductionBasis) TaxDeductionBasis,
incomeyear,percentage,amount,
sum(deductedthisperiod) deductedthisperiod from
(select pai.action_information5 thirdparty_id
,pai.action_information6 thirdparty_name,
decode(pai.action_information7,null,'',',')
||pai.action_information7||
decode(pai.action_information8,null,'',',')
||pai.action_information8||
decode(pai.action_information9,null,'',',')
||pai.action_information9||
decode(pai.action_information10,null,'',',')
||pai.action_information10 thirdparty_address
,pai.action_information11 bankaccountno
,pai.action_information14 ni
,action_information15 last_name
,action_information16 first_name
,action_information17 order_name
,action_information18 emp_no
,action_information19 emp_dob
,action_information20 emp_doh
,action_information21 emp_title
,pai.action_information26 TaxDeductionBasis
,pai.action_information22 incomeyear
,pai.action_information23 percentage
,pai.action_information24 amount
,pai.action_information25 deductedthisperiod
from pay_action_information pai
where pai.action_information3=l_payroll_action_id)
group by
thirdparty_id,thirdparty_name,thirdparty_address,
bankaccountno,ni,last_name,first_name,order_name,
emp_no,emp_dob,emp_doh,emp_title,
incomeyear,percentage,amount
order by thirdparty_id,order_name;




begin

xml_ctr := 0;
/*pgopal - picking the charset dynamically from the db*/
l_IANA_charset := HR_NO_UTILITY.get_IANA_charset ;
--xml_tab(xml_ctr).xmlstring := '<?xml version="1.0" encoding="utf-8"?>';
xml_tab(xml_ctr).xmlstring := '<?xml version = "1.0" encoding = "'||l_IANA_charset||'"?>';
xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<START>';
xml_ctr := xml_ctr +1;

IF p_payroll_action_id  IS NULL THEN

	BEGIN

	SELECT payroll_action_id
	INTO  l_payroll_action_id
	FROM pay_payroll_actions ppa,
	fnd_conc_req_summary_v fcrs,
	fnd_conc_req_summary_v fcrs1
	WHERE  fcrs.request_id = FND_GLOBAL.CONC_REQUEST_ID
	AND fcrs.priority_request_id = fcrs1.priority_request_id
	AND ppa.request_id between fcrs1.request_id  and fcrs.request_id
	AND ppa.request_id = fcrs1.request_id;

	EXCEPTION
	WHEN others THEN
	NULL;
	END ;
	ELSE
		l_payroll_action_id:=p_payroll_action_id;
	END IF;



for emp_rec in csr_emp loop

if (l_thirdparty_id <> emp_rec.thirdparty_id) then

  if csr_emp%rowcount = 1 then
   open csr_legalemployer;
   fetch csr_legalemployer into l_employer,l_orgnumber,l_term,l_year,l_archiver;
   close csr_legalemployer;
   xml_tab(xml_ctr).xmlstring := '<LEGALEMPLOYER_RECORD>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<Employer>'||l_employer||'</Employer>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Organizationnumber>'||l_orgnumber||'</Organizationnumber>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<Term>'||l_term||'</Term>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<Year>'||l_year||'</Year>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<Archiver>'||l_archiver||'</Archiver>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '</LEGALEMPLOYER_RECORD>';
   xml_ctr := xml_ctr +1;
   xml_tab(xml_ctr).xmlstring := '<THIRDPARTY_RECORD>';
  else
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '</THIRDPARTY_RECORD>';
   xml_ctr := xml_ctr + 1;
   xml_tab(xml_ctr).xmlstring := '<THIRDPARTY_RECORD>';
end if ;

   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Thirdparty_Name>'||emp_rec.thirdparty_name||'</Thirdparty_Name>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Thirdparty_address>'||emp_rec.thirdparty_address||'</Thirdparty_address>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<BankAccountno>'||emp_rec.bankaccountno||'</BankAccountno>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EMP_RECORD>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<NI-number>'||emp_rec.ni||'</NI-number>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Name>'||emp_rec.order_name||'</Name>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<TaxDeductionBasis>'||emp_rec.taxdeductionbasis||'</TaxDeductionBasis>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Incomeyear>'||emp_rec.incomeyear||'</Incomeyear>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Percentage>'||emp_rec.percentage||'</Percentage>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Amount>'||emp_rec.amount||'</Amount>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Deductedthisperiod>'||emp_rec.deductedthisperiod||'</Deductedthisperiod>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeLastName>'|| emp_rec.last_name ||'</EmployeeLastName>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeFirstName>'|| emp_rec.first_name ||'</EmployeeFirstName>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOB>'|| emp_rec.emp_dob ||'</EmployeeDOB>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOH>'|| emp_rec.emp_doh ||'</EmployeeDOH>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeTitle>'|| emp_rec.emp_title ||'</EmployeeTitle>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Emp-number>'||emp_rec.emp_no||'</Emp-number>';

   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring||'</EMP_RECORD>';
 l_thirdparty_id := emp_rec.thirdparty_id;
else
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EMP_RECORD>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<NI-number>'||emp_rec.ni||'</NI-number>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Name>'||emp_rec.order_name||'</Name>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<TaxDeductionBasis>'||emp_rec.taxdeductionbasis||'</TaxDeductionBasis>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Incomeyear>'||emp_rec.incomeyear||'</Incomeyear>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Percentage>'||emp_rec.percentage||'</Percentage>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Amount>'||emp_rec.amount||'</Amount>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Deductedthisperiod>'||emp_rec.deductedthisperiod||'</Deductedthisperiod>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeLastName>'|| emp_rec.last_name ||'</EmployeeLastName>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeFirstName>'|| emp_rec.first_name ||'</EmployeeFirstName>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Emp-number>'||emp_rec.emp_no||'</Emp-number>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOB>'|| emp_rec.emp_dob ||'</EmployeeDOB>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOH>'|| emp_rec.emp_doh ||'</EmployeeDOH>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeTitle>'|| emp_rec.emp_title ||'</EmployeeTitle>';
  xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring||'</EMP_RECORD>';
 l_thirdparty_id := emp_rec.thirdparty_id;
end if ;
end loop;

if(xml_tab(xml_ctr).xmlstring is null) THEN
raise no_data_found;
else
xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring||'</THIRDPARTY_RECORD>';
xml_ctr := xml_ctr +1;
xml_tab(xml_ctr).xmlstring := '</START>';
end if;

write_to_clob(p_xml);

exception when no_data_found then
 xml_tab(xml_ctr).xmlstring := '<LEGALEMPLOYER_RECORD>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<Employer>'||'</Employer>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Organizationnumber>'||'</Organizationnumber>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<Term>'||'</Term>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<Year>'||'</Year>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<Archiver>'||l_archiver||'</Archiver>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '</LEGALEMPLOYER_RECORD>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<THIRDPARTY_RECORD>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Thirdparty_Name>'||'</Thirdparty_Name>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Thirdparty_address>'||'</Thirdparty_address>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<BankAccountno>'||'</BankAccountno>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EMP_RECORD>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<NI-number>'||'</NI-number>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Name>'||'</Name>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<TaxDeductionBasis>'||'</TaxDeductionBasis>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Incomeyear>'||'</Incomeyear>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Percentage>'||'</Percentage>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Amount>'||'</Amount>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Deductedthisperiod>'||'</Deductedthisperiod>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeLastName>'|| '</EmployeeLastName>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeFirstName>'|| '</EmployeeFirstName>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOB>'|| '</EmployeeDOB>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOH>'|| '</EmployeeDOH>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Emp-number>'||'</Emp-number>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeTitle>'|| '</EmployeeTitle>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring||'</EMP_RECORD>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'</THIRDPARTY_RECORD>';
 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'</START>';

write_to_clob(p_xml);

end populate_details;


------------------------------------------------------------------------------------------------------------

procedure write_to_clob (p_xml out nocopy clob) is
l_xfdf_string clob;
begin
dbms_lob.createtemporary(p_xml,false,dbms_lob.call);
dbms_lob.open(p_xml,dbms_lob.lob_readwrite);
if xml_tab.count > 0 then
 for ctr_table in xml_tab.first .. xml_tab.last loop
 dbms_lob.writeappend( p_xml, length(xml_tab(ctr_table).xmlstring), xml_tab(ctr_table).xmlstring );
 end loop;
end if;
--dbms_lob.createtemporary(p_xml,true);
--clob_to_blob(l_xfdf_string,p_xml);
exception
when others then
hr_utility.trace('sqleerm ' || sqlerrm);
hr_utility.raise_error;

end write_to_clob;

-------------------------------------------------------------------------------------------------------------------------
 END PAY_NO_TAX_LEVY;

/
