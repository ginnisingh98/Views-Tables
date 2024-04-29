--------------------------------------------------------
--  DDL for Package Body PAY_NO_SUPPORT_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_SUPPORT_ORDER" AS
/* $Header: pynosupord.pkb 120.4.12000000.1 2007/05/20 09:03:00 rlingama noship $ */
g_debug   boolean   :=  hr_utility.debug_enabled;

------------------------------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------------------------------------------------
/* GET ALL PARAMETERS */
PROCEDURE GET_ALL_PARAMETERS(
 		 p_payroll_action_id	IN           NUMBER
		,p_business_group_id    OUT  NOCOPY  NUMBER
		,p_legal_employer_id	OUT  NOCOPY  NUMBER
		,p_element_type_id	OUT  NOCOPY  NUMBER
		,p_effective_date	OUT  NOCOPY  DATE
		,p_from_date		OUT  NOCOPY  DATE
		,p_to_date		OUT  NOCOPY  DATE
		,p_third_party_id	OUT  NOCOPY  NUMBER
		,p_archive		OUT  NOCOPY  VARCHAR2
		) IS


	CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
	SELECT 	 PAY_NO_SUPPORT_ORDER.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER_ID')
		,PAY_NO_SUPPORT_ORDER.GET_PARAMETER(legislative_parameters,'ELEMENT_TYPE_ID')
		,fnd_date.canonical_to_date(PAY_NO_SUPPORT_ORDER.GET_PARAMETER(legislative_parameters,'FROM_DATE'))
		,fnd_date.canonical_to_date(PAY_NO_SUPPORT_ORDER.GET_PARAMETER(legislative_parameters,'TO_DATE'))
		,PAY_NO_SUPPORT_ORDER.GET_PARAMETER(legislative_parameters,'THIRD_PARTY_PAYEE')
		,PAY_NO_SUPPORT_ORDER.GET_PARAMETER(legislative_parameters,'ARCHIVE')
		,effective_date
		,business_group_id
	FROM  pay_payroll_actions
	WHERE payroll_action_id = p_payroll_action_id;

BEGIN



	 OPEN csr_parameter_info (p_payroll_action_id);
	 FETCH csr_parameter_info
	 INTO  p_legal_employer_id
	      ,p_element_type_id
	      ,p_from_date
	      ,p_to_date
	      ,p_third_party_id
	      ,p_archive
	      ,p_effective_date
	      ,p_business_group_id;
	 CLOSE csr_parameter_info;

IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
END IF;

 END GET_ALL_PARAMETERS;

-------------------------------------------------------------------------------------------------------------------------
 /* RANGE CODE */
 PROCEDURE RANGE_CODE (pactid    IN    NUMBER
		      ,sqlstr    OUT   NOCOPY VARCHAR2)
 IS

-- Variable declarations

	l_count			NUMBER := 0;
	l_archive		VARCHAR2(3);

	l_action_info_id	NUMBER;
	l_ovn			NUMBER;
	l_business_id		NUMBER;
	l_bimonth_year		NUMBER;
	l_bimonth_term		VARCHAR2(10);
	l_le_org_num		VARCHAR2(240);
	l_le_name		VARCHAR2(240);
	l_leg_emp_id		NUMBER;
	l_effective_date	DATE;
	l_third_party_id	NUMBER;
	l_from_date		DATE;
	l_to_date		DATE;
	l_third_party_name	VARCHAR2(240);
	l_ele_type_id		NUMBER;
       	l_element_name		VARCHAR2(240);
	 l_def_bal_id		NUMBER;
	 ipv_third_party	VARCHAR2(240);
	 ipv_pay_value		VARCHAR2(240);
	 ipv_amount		VARCHAR2(240);
	 ipv_percent		VARCHAR2(240);
	 ipv_ref_num		VARCHAR2(240);
	 l_info_id		NUMBER;
	 info_amt		VARCHAR2(240);
	 info_percent		VARCHAR2(240);
	 info_refnum		VARCHAR2(240);
	 l_archived_on		VARCHAR2(240);
	 l_ele_code		VARCHAR2(150);

	 /* Bug Fix 5110016 : New variable l_reporting_name added for storing the reporting name of the element */
	 l_reporting_name	VARCHAR2(240);

-- Cursors


-- cursor to get Legal Employer Name and Org Num

cursor csr_le_details ( l_leg_emp_id  NUMBER ) is
	select hou.name ,hoi.org_information1
	from hr_organization_units          hou
	    ,hr_organization_information    hoi
	where hou.organization_id = l_leg_emp_id
	and   hoi.organization_id = l_leg_emp_id
	and   hoi.org_information_context = to_char('NO_LEGAL_EMPLOYER_DETAILS');



-- cursor to get the element name
CURSOR csr_element_name (l_ele_type_id  NUMBER) IS
	SELECT element_name
	FROM pay_element_types_f
	WHERE ELEMENT_TYPE_ID = l_ele_type_id ;
	--AND   LEGISLATION_CODE = 'NO' ;

/* Bug Fix 5110016 : New cursor csr_reporting_name added for getting the reporting name of the element */

-- cursor to get the reporting name for element
CURSOR csr_reporting_name (l_ele_type_id  NUMBER) IS
	SELECT nvl(REPORTING_NAME , ELEMENT_NAME)
	FROM pay_element_types_f
	WHERE ELEMENT_TYPE_ID = l_ele_type_id ;


/* Bug Fix 5110016 : Added INFORMATION_TYPE check in the cursor csr_element_info_iv. */

-- cursor to get the other input value names for this element

/*
CURSOR csr_element_info_iv (l_ele_type_id  NUMBER) IS
	select EEI_INFORMATION2	, EEI_INFORMATION3 , EEI_INFORMATION4
	from pay_element_type_extra_info
	where ELEMENT_TYPE_ID = l_ele_type_id ;
*/

CURSOR csr_element_info_iv (l_ele_type_id  NUMBER) IS
	select EEI_INFORMATION2	, EEI_INFORMATION3 , EEI_INFORMATION4
	from pay_element_type_extra_info
	where ELEMENT_TYPE_ID = l_ele_type_id
	and INFORMATION_TYPE = 'NO_EMPLOYEE_DEDUCTION_REPORT';


--cursor get the input value id for the input value names above
CURSOR csr_element_iv_id (l_ele_type_id  NUMBER , l_iv_name VARCHAR2) IS
	select INPUT_VALUE_ID
	from pay_input_values_f
	where ELEMENT_TYPE_ID = l_ele_type_id
	AND NAME = l_iv_name ;


-- cursor to fetch the element details

cursor csr_element_details (p_ele_type_id  NUMBER) IS

	select
	      ipv1.INPUT_VALUE_ID		ipv1_id  -- Third Party Payee
	      ,ipv2.INPUT_VALUE_ID		ipv2_id	 -- Pay Value
	      ,info.ELEMENT_TYPE_EXTRA_INFO_ID	info_id
	      ,info.EEI_INFORMATION5		def_bal_id

	from pay_element_types_f	ele
	,pay_element_type_extra_info	info
	,pay_input_values_f		ipv1
	,pay_input_values_f		ipv2

	where ele.ELEMENT_TYPE_ID = p_ele_type_id
	-- for pay_element_type_extra_info
	AND info.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
	AND info.INFORMATION_TYPE = 'NO_EMPLOYEE_DEDUCTION_REPORT'

	-- for input value Third Party Payee
	AND ipv1.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
	AND ipv1.NAME = 'Third Party Payee'

	-- for input value Pay Value
	AND ipv2.ELEMENT_TYPE_ID = ele.ELEMENT_TYPE_ID
	AND ipv2.NAME = 'Pay Value' ;


 --cursor to get element code
 cursor csr_ele_code(p_ele_type_id  NUMBER
	             ,p_leg_emp_id varchar2) is
	select nvl((select eei_information1 from pay_element_type_extra_info petei
	where petei.information_type='NO_ELEMENT_CODES'
	and element_type_id = p_ele_type_id
	and petei.eei_information2 = p_leg_emp_id
	and rownum=1),
	(select eei_information1 from pay_element_type_extra_info petei
	where petei.information_type='NO_ELEMENT_CODES'
	and element_type_id = p_ele_type_id
	and eei_information2 is null
	and rownum=1)) from dual;


 -- fetch the element details of 'Wage Attachment Support Order'

cursor csr_waso_deatils (p_ele_type_id  NUMBER) is

	select ipv1.INPUT_VALUE_ID		ipv1_id -- Third Party Payee
	      ,ipv2.INPUT_VALUE_ID		ipv2_id -- Fixed Deduction Amount
	      ,ipv3.INPUT_VALUE_ID		ipv3_id -- Deduction Percentage
	      ,ipv4.INPUT_VALUE_ID		ipv4_id -- Reference Number
	      ,ipv5.INPUT_VALUE_ID		ipv5_id -- Pay Value

	from pay_input_values_f		ipv1
	,pay_input_values_f		ipv2
	,pay_input_values_f		ipv3
	,pay_input_values_f		ipv4
	,pay_input_values_f		ipv5

	WHERE
	-- for input value Third Party Payee
	ipv1.ELEMENT_TYPE_ID = p_ele_type_id
	AND ipv1.NAME = 'Third Party Payee'

	-- for input value AMOUNT
	AND ipv2.ELEMENT_TYPE_ID = p_ele_type_id
	AND ipv2.NAME = 'Fixed Deduction Amount'

	-- for input value PERCENTAGE
	AND ipv3.ELEMENT_TYPE_ID = p_ele_type_id
	AND ipv3.NAME = 'Deduction Percentage'

	-- for input value REFERENCE NUMBER
	AND ipv4.ELEMENT_TYPE_ID = p_ele_type_id
	AND ipv4.NAME = 'Reference Number'

	-- for input value PAY VALUE
	AND ipv5.ELEMENT_TYPE_ID = p_ele_type_id
	AND ipv5.NAME = 'Pay Value' ;


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
 PAY_NO_SUPPORT_ORDER.GET_ALL_PARAMETERS(
		pactid
		,l_business_id
		,l_leg_emp_id
		,l_ele_type_id
		,l_effective_date
		,l_from_date
		,l_to_date
		,l_third_party_id
		,l_archive ) ;


 -- check if we have to archive again
 IF  (l_archive = 'Y')

   THEN

   -- check if record for current archive exists
   SELECT count(*)  INTO l_count
   FROM   pay_action_information
   WHERE  action_information_category = 'EMEA REPORT DETAILS'
   AND    action_information1         = 'PYNOSUPORDA'
   AND    action_context_id           = pactid;

   -- archive Report Details only if no record exists
   IF (l_count < 1)

       THEN

      -- fetch LE name and LE Org Num from LE ID
       OPEN csr_le_details (l_leg_emp_id) ;
       FETCH csr_le_details INTO l_le_name , l_le_org_num ;
       CLOSE csr_le_details ;

	-- to get the Third Party Name
	IF (l_third_party_id IS NOT NULL) THEN

		l_third_party_id := to_number(l_third_party_id) ;
		select name into l_third_party_name  from hr_organization_units where organization_id = l_third_party_id ;


	END IF;
	-------------------------------------------------------------------

	-- get the name of the element
	OPEN csr_element_name (l_ele_type_id);
	FETCH csr_element_name INTO l_element_name ;
	CLOSE csr_element_name ;

	-- get the reporting name of the element
	OPEN csr_reporting_name (l_ele_type_id);
	FETCH csr_reporting_name INTO l_reporting_name ;
	CLOSE csr_reporting_name ;


	IF (l_element_name = 'Wage Attachment Support Order')
	  THEN


		/* Bug Fix 5110016 : TOTAL_PAY_ASG_PTD replaced by WAGE_ATTACHMENT_SUPPORT_ORDER_BASE_ASG_PTD
				     to be used as basis for Support Order Calculation */

		-- get the defined balance id for the deduction balance of waso = TOTAL_PAY_ASG_PTD
		/* SELECT pay_no_emp_cont.get_defined_balance_id('Total Pay','_ASG_PTD') INTO l_def_bal_id FROM   dual ; */

		-- deduction balance of waso now changed to WAGE_ATTACHMENT_SUPPORT_ORDER_BASE_ASG_PTD
		SELECT pay_no_emp_cont.get_defined_balance_id('Wage Attachment Support Order Base','_ASG_PTD') INTO l_def_bal_id FROM   dual ;

		OPEN csr_waso_deatils (l_ele_type_id) ;
		FETCH csr_waso_deatils INTO ipv_third_party ,ipv_amount , ipv_percent ,ipv_ref_num , ipv_pay_value ;
		CLOSE csr_waso_deatils ;

		l_info_id :=  NULL;

		open csr_ele_code(l_ele_type_id,l_leg_emp_id);
		fetch csr_ele_code into l_ele_code;
		close csr_ele_code;

	  ELSE -- the element is a user defined element


		-- get the details for this element
		OPEN csr_element_details (l_ele_type_id) ;
		FETCH csr_element_details INTO ipv_third_party , ipv_pay_value , l_info_id , l_def_bal_id ;
		CLOSE csr_element_details ;

		open csr_ele_code(l_ele_type_id,l_leg_emp_id);
		fetch csr_ele_code into l_ele_code;
		close csr_ele_code;


		-- get the other input value names for this element
		OPEN csr_element_info_iv (l_ele_type_id);
		FETCH csr_element_info_iv into info_amt , info_percent , info_refnum ;
		CLOSE csr_element_info_iv ;


		-- get the input value id for the input value 'Amount'
		OPEN csr_element_iv_id (l_ele_type_id , info_amt);
		FETCH csr_element_iv_id into ipv_amount ;
		CLOSE csr_element_iv_id ;

		-- get the input value id for the input value 'Percentage'
		OPEN csr_element_iv_id (l_ele_type_id ,info_percent );
		FETCH csr_element_iv_id into ipv_percent ;
		CLOSE csr_element_iv_id ;


		-- get the input value id for the input value 'Reference Number'
		OPEN csr_element_iv_id (l_ele_type_id , info_refnum);
		FETCH csr_element_iv_id into ipv_ref_num ;
		CLOSE csr_element_iv_id ;


	END IF;

	/* Bug Fix 5110016 : Reporting Name should be displayed instead of element name where available */

	l_element_name := l_reporting_name ;

	l_archived_on := to_char(l_effective_date) || ' (' || to_char(pactid) ||')';

	-------------------------------------------------------------------

       -- Archive the REPORT DETAILS

		pay_action_information_api.create_action_information (
		 p_action_information_id        => l_action_info_id	-- out parameter
		,p_object_version_number        => l_ovn		-- out parameter
		,p_action_context_id            => pactid		-- context id = payroll action id (of Archive)
		,p_action_context_type          => 'PA'			-- context type
		,p_effective_date               => l_effective_date	-- Date of running the archive
		,p_action_information_category  => 'EMEA REPORT DETAILS' -- Information Category
		,p_tax_unit_id                  => l_leg_emp_id		-- Legal Employer ID
		,p_jurisdiction_code            => NULL			-- Tax Municipality ID
		,p_action_information1          => 'PYNOSUPORDA'	-- Conc Prg Short Name
		,p_action_information2          => NULL			-- Local Unit ID
		,p_action_information3          => l_le_name		-- Legal Employer Name
		,p_action_information4          => l_le_org_num		-- Legal Employer Organization Number
		,p_action_information5          => l_from_date		-- Reporting From Date
		,p_action_information6          => l_to_date		-- Reporting To Date
		,p_action_information7          => l_business_id 	-- Business Group ID
		,p_action_information8          => l_third_party_id	-- Third Party Org Id
		,p_action_information9          => l_third_party_name   -- Third Party Org Name
		,p_action_information10         => l_ele_type_id	-- Element Type ID
		,p_action_information11         => l_element_name	-- Element Name
		,p_action_information12         => l_ele_code		-- Element Code
		,p_action_information13         => ipv_third_party	-- Input Value ID 1 = Third Party Payee
		,p_action_information14         => ipv_amount		-- Input Value ID 2 = Amount
		,p_action_information15         => ipv_percent		-- Input Value ID 3 = Percentage
		,p_action_information16         => ipv_ref_num		-- Input Value ID 4 = Reference Number
		,p_action_information17         => ipv_pay_value	-- Input Value ID 5 = Pay Value
		,p_action_information18         => l_def_bal_id		-- Defined Balance ID
		,p_action_information19         => l_info_id		-- ELEMENT_TYPE_EXTRA_INFO_ID for this element
		,p_action_information20         => l_archived_on	-- Archived On
		);


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
	 p_bus_grp_id		NUMBER,
	 p_element_type_id	NUMBER,
	 p_third_party_id	VARCHAR2)

 IS

	SELECT
	assact.ASSIGNMENT_ID		asg_id
	,assact.assignment_action_id	asg_act_id
	,assact.TAX_UNIT_ID		tax_unit_id
	,prr.LOCAL_UNIT_ID		local_unit_id

	FROM
	pay_assignment_actions	assact
	,pay_assignment_actions	assact1
	,pay_payroll_actions	ppa
	,pay_payroll_actions	ppa2
	,pay_payroll_actions	ppa3
	,per_all_assignments_f	asg
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
	-- To pick the terminated assignments.
	AND ppa2.effective_date between asg.EFFECTIVE_START_DATE and asg.EFFECTIVE_END_DATE
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


	-- for element 'Wage Attachment Tax Levy' and USER DEFINED DEDUCTION ELEMENTS
	AND prr.ELEMENT_TYPE_ID = p_element_type_id
	AND prr.RUN_RESULT_ID = prrv.RUN_RESULT_ID
	AND prrv.INPUT_VALUE_ID = inpv.INPUT_VALUE_ID
	AND inpv.ELEMENT_TYPE_ID = p_element_type_id
	AND inpv.NAME = 'Third Party Payee'
	AND prrv.result_value = nvl(p_third_party_id,prrv.result_value)


	ORDER BY assact.assignment_id ;




 -- cursor to get the jurisdiction code (Tax Municipality)

CURSOR csr_tax_mun_id (p_assignment_action_id  NUMBER, p_assignment_id  NUMBER) IS

	SELECT act_con.CONTEXT_VALUE	tax_mun_id

	FROM pay_action_contexts  act_con
	    ,ff_contexts	  con

	WHERE  con.CONTEXT_NAME = 'JURISDICTION_CODE'
	AND act_con.CONTEXT_ID = con.CONTEXT_ID
	AND act_con.ASSIGNMENT_ACTION_ID = p_assignment_action_id
	AND act_con.ASSIGNMENT_ID = p_assignment_id ;


l_count			NUMBER := 0;
l_archive		VARCHAR2(3);

l_action_info_id	NUMBER;
l_ovn			NUMBER;

l_business_id		NUMBER;
l_bimonth_year		NUMBER;
l_bimonth_term		VARCHAR2(10);
l_le_org_num		VARCHAR2(240);
l_le_name		VARCHAR2(240);
l_leg_emp_id		NUMBER;
l_effective_date	DATE;
l_start_date		DATE;
l_end_date		DATE;
l_actid			NUMBER;
l_local_unit_id		NUMBER;
l_third_party_id	NUMBER;
l_from_date		DATE;
l_to_date		DATE;
l_tax_mun_id		VARCHAR2(240);
--rec_waso		csr_waso_deatils%rowtype;
l_def_bal_id		NUMBER;
l_ele_type_id		NUMBER;

BEGIN
IF g_debug THEN
      hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
END IF;

      -- fetch the data
	 PAY_NO_SUPPORT_ORDER.GET_ALL_PARAMETERS(
			p_payroll_action_id
			,l_business_id
			,l_leg_emp_id
			,l_ele_type_id
			,l_effective_date
			,l_from_date
			,l_to_date
			,l_third_party_id
			,l_archive ) ;

   	 -- check if we have to archive again
	 IF  (l_archive = 'Y')

	   THEN

		FOR rec_asg IN csr_assignments
				(p_payroll_action_id ,
				 l_leg_emp_id ,
				 p_start_person ,
				 p_end_person ,
				 l_from_date ,
				 l_to_date ,
				 l_business_id ,
				 l_ele_type_id,
				 l_third_party_id     ) LOOP

			OPEN csr_tax_mun_id (rec_asg.asg_act_id , rec_asg.asg_id );
			FETCH csr_tax_mun_id INTO l_tax_mun_id ;
			CLOSE csr_tax_mun_id ;

			SELECT pay_assignment_actions_s.NEXTVAL INTO l_actid FROM   dual;

			  -- Create the archive assignment action
			  hr_nonrun_asact.insact(l_actid ,rec_asg.asg_id ,p_payroll_action_id ,p_chunk ,NULL);


			  -- Creating Initial Archive Entries
			  pay_action_information_api.create_action_information (

				 p_action_information_id        => l_action_info_id		-- out parameter
				,p_object_version_number        => l_ovn			-- out parameter
				,p_action_context_id            => l_actid        		-- context id = assignment action id (of Archive)
				,p_action_context_type          => 'AAP'			-- context type
				,p_effective_date               => l_effective_date		-- Date of running the archive
				,p_assignment_id		=> rec_asg.asg_id		-- Assignment ID
				,p_action_information_category  => 'EMEA REPORT INFORMATION'	-- Information Category
				,p_tax_unit_id                  => l_leg_emp_id			-- Legal Employer ID
				,p_jurisdiction_code            => l_tax_mun_id			-- Tax Municipality ID
				,p_action_information1          => 'PYNOSUPORDA'		-- Conc Prg Short Name
				,p_action_information2          => rec_asg.local_unit_id	-- Local Unit ID
				,p_action_information3          => p_payroll_action_id		-- payroll_action_id (of this archive)
				,p_action_information4          => rec_asg.asg_act_id		-- Original / Main Asg Action ID

				);


		END LOOP; -- rec_asg

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

cursor csr_get_act_info (p_assignment_action_id  NUMBER , p_effective_date DATE , p_leg_emp_id NUMBER) is

	select to_number(ACTION_INFORMATION_ID) action_info_id
	      ,to_number(ACTION_INFORMATION4)	main_asg_act_id
	      ,to_number(ACTION_INFORMATION2)  local_unit_id
	      ,jurisdiction_code
	from pay_action_information
	where ACTION_INFORMATION_CATEGORY = 'EMEA REPORT INFORMATION'
	and   ACTION_INFORMATION1 = 'PYNOSUPORDA'
	and   ACTION_CONTEXT_TYPE = 'AAP'
	and   ACTION_CONTEXT_ID = p_assignment_action_id
	and   EFFECTIVE_DATE = p_effective_date
	and   TAX_UNIT_ID = p_leg_emp_id ;



-- cursor to get the element details from information archived in EMEA REPORT DETAILS

cursor csr_get_ele_info (p_payroll_action_id  NUMBER , p_effective_date DATE, p_leg_emp_id NUMBER) is

	select to_number(ACTION_INFORMATION10)	ele_type_id       -- Elemeny Type ID
	      ,to_number(ACTION_INFORMATION13)	ipv_third_party	  -- Input Value ID 1 = Third Party Payee
	      ,to_number(ACTION_INFORMATION14)	ipv_amount	  -- Input Value ID 2 = Amount
	      ,to_number(ACTION_INFORMATION15)	ipv_percent	  -- Input Value ID 3 = Percentage
	      ,to_number(ACTION_INFORMATION16)	ipv_ref_num	  -- Input Value ID 4 = Reference Number
	      ,to_number(ACTION_INFORMATION17)	ipv_pay_value	  -- Input Value ID 5 = Pay Value
	      ,to_number(ACTION_INFORMATION18)	def_bal_id	  -- Deduction Basis Balance : Defined Balance ID

	from pay_action_information

	where ACTION_INFORMATION_CATEGORY = 'EMEA REPORT DETAILS'
	and   ACTION_INFORMATION1 = 'PYNOSUPORDA'
	and   ACTION_CONTEXT_TYPE = 'PA'
	and   ACTION_CONTEXT_ID = p_payroll_action_id
	and   EFFECTIVE_DATE = p_effective_date
	and   TAX_UNIT_ID = p_leg_emp_id ;


-- cursor to get the assignment,person details and run values

CURSOR csr_asg_details
	(p_assignment_action_id	NUMBER
	,p_ele_typ_id		NUMBER
	,p_ipvid_1		NUMBER
	,p_ipvid_2		NUMBER 	) IS
	SELECT
	 per.last_name			per_last_name
	,per.first_name			per_first_name
	,per.ORDER_NAME			per_order_name
	,per.PERSON_ID			per_id
	,per.NATIONAL_IDENTIFIER	per_ni
	,per.EMPLOYEE_NUMBER		emp_no
	,per.DATE_OF_BIRTH		per_dob
	,per.ORIGINAL_DATE_OF_HIRE	per_doh
	,per.TITLE			per_title
	,per.business_group_id		bg_id
	,prrv1.result_value		res_val_1 -- Third Party Payee
	,prrv2.result_value		res_val_2 -- Pay Value
	,prr.RUN_RESULT_ID		run_res_id
	,ppa.payroll_id			payroll_id  --payroll_id to set the context
	,ppa.date_earned		date_earned --date_earned to set the context
	,prr.source_id			original_entry_id --source_id to set the context

	FROM
	pay_assignment_actions	assact
	,pay_payroll_actions	ppa
	,per_all_assignments_f	asg
	,per_all_people_f	per
	,pay_run_results	prr
	,pay_run_result_values	prrv1
	,pay_run_result_values	prrv2

	WHERE assact.ASSIGNMENT_ACTION_ID = p_assignment_action_id
	AND assact.ASSIGNMENT_ID = asg.ASSIGNMENT_ID
	AND ppa.date_earned between asg.EFFECTIVE_START_DATE and asg.EFFECTIVE_END_DATE
	AND asg.PERSON_ID = per.PERSON_ID
	AND ppa.date_earned between per.EFFECTIVE_START_DATE and per.EFFECTIVE_END_DATE
	AND assact.PAYROLL_ACTION_ID = ppa.PAYROLL_ACTION_ID
	AND assact.ASSIGNMENT_ACTION_ID = prr.ASSIGNMENT_ACTION_ID

	-- for element
	AND prr.ELEMENT_TYPE_ID = p_ele_typ_id

	-- for input value 'Third Party Payee'
	AND prr.RUN_RESULT_ID = prrv1.RUN_RESULT_ID
	AND prrv1.INPUT_VALUE_ID = p_ipvid_1

	-- for input value 'Pay Value'
	AND prr.RUN_RESULT_ID = prrv2.RUN_RESULT_ID
	AND prrv2.INPUT_VALUE_ID = p_ipvid_2 ;


-- cursor to get the assignment,person details and run values

CURSOR csr_result_values ( p_run_res_id NUMBER , p_inp_val_id NUMBER ) IS
	SELECT result_value
	FROM pay_run_result_values
	WHERE RUN_RESULT_ID = p_run_res_id
	AND INPUT_VALUE_ID = p_inp_val_id ;



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




-- Variable declaration

l_action_info_id	NUMBER;
l_ovn			NUMBER;
l_main_asg_act_id	NUMBER;

rec_asg_detail		csr_asg_details%rowtype;
rec_loc_detail		csr_third_party_loc%rowtype;

l_count			NUMBER := 0;
l_archive		VARCHAR2(3);
l_business_id		NUMBER;
l_bimonth_term		VARCHAR2(10);
l_leg_emp_id		NUMBER;
l_effective_date	DATE;

l_third_party_id	NUMBER;
l_third_party_name	VARCHAR2(240);
l_third_party_dest_acc	VARCHAR2(150);
l_dedn_basis		NUMBER;
l_payroll_action_id	NUMBER;
l_from_date		DATE;
l_to_date		DATE;
rec_info		csr_get_act_info%rowtype;
ele_info		csr_get_ele_info%rowtype;
l_emp_ni		VARCHAR2(240);
l_ele_type_id		NUMBER;
ipv_third_party	NUMBER;
ipv_amount	NUMBER;
ipv_percent	NUMBER;
ipv_ref_num	NUMBER;
ipv_pay_value	NUMBER;
l_def_bal_id	NUMBER;
l_amt		NUMBER;
l_percent	NUMBER;
l_ref_num	VARCHAR2(240);


 BEGIN
IF g_debug THEN
 		hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',380);
 END IF;

	SELECT payroll_action_id
	INTO l_payroll_action_id
	FROM pay_assignment_actions
	WHERE assignment_action_id = p_assignment_action_id ;


       -- fetch the data
	 PAY_NO_SUPPORT_ORDER.GET_ALL_PARAMETERS(
			l_payroll_action_id
			,l_business_id
			,l_leg_emp_id
			,l_ele_type_id
			,l_effective_date
			,l_from_date
			,l_to_date
			,l_third_party_id
			,l_archive ) ;


   	 -- check if we have to archive again
	 IF  (l_archive = 'Y')

	   THEN


		-- get the action_information_id and original/main assignment_action_id for this asg_act_id
		OPEN csr_get_act_info (p_assignment_action_id  , p_effective_date , l_leg_emp_id );
		FETCH csr_get_act_info  INTO rec_info;
		CLOSE csr_get_act_info ;

		--fnd_file.put_line(fnd_file.log,'SUGARG: after csr_get_act_info');

		--  get the element details from information archived in EMEA REPORT DETAILS
		OPEN csr_get_ele_info (l_payroll_action_id , p_effective_date , l_leg_emp_id) ;
		FETCH csr_get_ele_info  INTO ele_info;
		CLOSE csr_get_ele_info ;

		--fnd_file.put_line(fnd_file.log,'SUGARG: after csr_get_ele_info');



		-- fetch assignment details
		OPEN csr_asg_details
			(rec_info.main_asg_act_id
			 ,ele_info.ele_type_id
			 ,ele_info.ipv_third_party
			 --,ele_info.ipv_amount
			 --,ele_info.ipv_percent
			 --,ele_info.ipv_ref_num
			 ,ele_info.ipv_pay_value  ) ;

		FETCH csr_asg_details INTO rec_asg_detail ;
		CLOSE csr_asg_details ;


		-- get the result values 'Amount'
		OPEN csr_result_values ( rec_asg_detail.run_res_id , ele_info.ipv_amount ) ;
		FETCH csr_result_values INTO l_amt ;
		CLOSE csr_result_values ;

		-- get the result values 'Percentage'
		OPEN csr_result_values ( rec_asg_detail.run_res_id , ele_info.ipv_percent  ) ;
		FETCH csr_result_values INTO l_percent ;
		CLOSE csr_result_values ;

		-- get the result values 'Reference Number'
		OPEN csr_result_values ( rec_asg_detail.run_res_id , ele_info.ipv_ref_num  ) ;
		FETCH csr_result_values INTO l_ref_num ;
		CLOSE csr_result_values ;



		l_third_party_id := to_number(rec_asg_detail.res_val_1) ;

		--fnd_file.put_line(fnd_file.log,'SUGARG: after l_third_party_id' || to_char(l_third_party_id));

		-- to get the Third Party Name
		select name into l_third_party_name  from hr_organization_units where organization_id = l_third_party_id ;


		-- to get the third party Destination acc no.
		OPEN csr_third_party_dest_acc (l_third_party_id) ;
		FETCH csr_third_party_dest_acc INTO l_third_party_dest_acc ;
		CLOSE csr_third_party_dest_acc ;


		-- to get the third party location details
		OPEN csr_third_party_loc (l_third_party_id) ;
		FETCH csr_third_party_loc INTO rec_loc_detail;
		CLOSE csr_third_party_loc ;

		pay_balance_pkg.set_context('TAX_UNIT_ID', l_leg_emp_id);
		pay_balance_pkg.set_context('JURISDICTION_CODE', rec_info.jurisdiction_code);
		pay_balance_pkg.set_context('DATE_EARNED', to_char(rec_asg_detail.date_earned, 'YYYY/MM/DD HH24:MI:SS'));
		pay_balance_pkg.set_context('LOCAL_UNIT_ID',rec_info.local_unit_id);
		pay_balance_pkg.set_context('PAYROLL_ID', rec_asg_detail.payroll_id);
		pay_balance_pkg.set_context('ORGANIZATION_ID', l_third_party_id);
		pay_balance_pkg.set_context('ORIGINAL_ENTRY_ID', rec_asg_detail.original_entry_id);




		-- to fetch the balance value of DEDUCTION BASIS balance
		select pay_balance_pkg.get_value(ele_info.def_bal_id , rec_info.main_asg_act_id)
		into l_dedn_basis
		from dual;


		l_third_party_dest_acc := substr(l_third_party_dest_acc,1,4)||'.'||
		                          substr(l_third_party_dest_acc,5,2)||'.'||
					  substr(l_third_party_dest_acc,7,5) ;


		l_emp_ni := substr(rec_asg_detail.per_ni,1,6)||'-'||
		            substr(rec_asg_detail.per_ni,7,5) ;

		  -- Updating the Initial Archive Entries
			pay_action_information_api.update_action_information (
			 p_action_information_id        => rec_info.action_info_id 	-- in parameter
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
			,p_action_information15         => rec_asg_detail.per_last_name	--Person Lastname
			,p_action_information16         => rec_asg_detail.per_first_name --Person FirstName
			,p_action_information17         => rec_asg_detail.per_order_name --Person Order Name
			,p_action_information18         => rec_asg_detail.emp_no 	--Person Employee Number
			,p_action_information19         => rec_asg_detail.per_dob 	--Person Date of Birth - DOB
			,p_action_information20         => rec_asg_detail.per_doh	--Person Date of Hire - DOH
			,p_action_information21         => rec_asg_detail.per_title	--Person Title
			,p_action_information22         => l_ref_num			--Reference Number
			,p_action_information23         => l_percent			--Percentage (Input Value)
			,p_action_information24         => l_amt			--Amount (Input Value)
			,p_action_information25         => rec_asg_detail.res_val_2	--Deducted This Period (Input Value)
			,p_action_information26         => l_dedn_basis			--Deduction Basis (Balance Value)

			);


	 END IF; -- l_archive = 'Y'

	--fnd_file.put_line(fnd_file.log,'SUGARG: leaving ARCHIVE_CODE');
 IF g_debug THEN
 		hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',390);
 END IF;
 END ARCHIVE_CODE;

-------------------------------------------------------------------------------------------------------------------------





-- PROCEDURE for writing the xml report

PROCEDURE populate_details(p_payroll_action_id in NUMBER,
		  	   p_template_name in VARCHAR2,
			   p_xml out nocopy CLOB) is

------------------------------------

-- cursor to get Legal Employer and other details for the report header

cursor csr_legalemployer (p_payroll_action_id	NUMBER) is
	select action_information3 employer
	,action_information4 orgnumber
	,action_information5 from_date
	,action_information6 to_date
	,action_information11 ele_name
	,action_information12 ele_code
	,action_information20 archived_on
	from pay_action_information
	where action_context_id = p_payroll_action_id ;


-- cursor to get assignment and person details

cursor csr_emp (p_payroll_action_id	NUMBER) is
	select action_information6 thirdparty_name
	,action_information5 thirdparty_id
	,', '||action_information7||', '
	     ||action_information8||', '
	     ||action_information9||', '
	     ||action_information10 thirdparty_address
	,action_information11 bankaccountno
	,action_information14 emp_ni
	,action_information15 last_name
	,action_information16 first_name
	,action_information17 order_name
	,action_information18 emp_no
	,action_information19 emp_dob
	,action_information20 emp_doh
	,action_information21 emp_title
	,action_information22 refno
	,action_information23 percentage
	,action_information24 amount
	,action_information25 deductedthisperiod
	,action_information26 deductionBasis
	from pay_action_information pai
	where action_information3 = to_char(p_payroll_action_id)
	order by thirdparty_name , order_name;


xml_ctr			NUMBER;
l_payroll_action_id	NUMBER;
l_employer		VARCHAR2(240);
l_orgnumber		VARCHAR2(240);
l_from_date		VARCHAR2(240);
l_to_date		VARCHAR2(240);
l_ele_name		varchar2(240);
l_ele_code		varchar2(240);
l_archived_on		varchar2(240);
l_thirdparty_id		pay_action_information.ACTION_INFORMATION5%TYPE := '-999';
l_IANA_charset VARCHAR2 (50);

BEGIN


xml_ctr := 0;
/*pgopal - picking the charset dynamically from the db*/
l_IANA_charset := HR_NO_UTILITY.get_IANA_charset ;
--xml_tab(xml_ctr).xmlstring := '<?xml version="1.0" encoding="utf-8"?>';
xml_tab(xml_ctr).xmlstring := '<?xml version = "1.0" encoding = "'||l_IANA_charset||'"?>';
xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<START>';
xml_ctr := xml_ctr +1;

-- getting the pay_action_id if the current archive if no archive has been mentioned


IF p_payroll_action_id  IS NULL THEN

	BEGIN

		--fnd_file.put_line(fnd_file.log,'SUGARG: p_payroll_action_id  IS NULL ');
		SELECT payroll_action_id
		INTO  l_payroll_action_id
		FROM pay_payroll_actions ppa,
		     fnd_conc_req_summary_v fcrs,
		     fnd_conc_req_summary_v fcrs1
		WHERE  fcrs.request_id = FND_GLOBAL.CONC_REQUEST_ID
		AND fcrs.priority_request_id = fcrs1.priority_request_id
		AND ppa.request_id between fcrs1.request_id  and fcrs.request_id
		AND ppa.request_id = fcrs1.request_id;

		--fnd_file.put_line(fnd_file.log,'SUGARG: inside IF -> l_payroll_action_id = '||l_payroll_action_id);

	EXCEPTION
	WHEN others THEN
	NULL;
	END ;
ELSE
	l_payroll_action_id := p_payroll_action_id ;

END IF;


-- Get Legal Employer and other details for the report header
OPEN csr_legalemployer (l_payroll_action_id) ;
FETCH csr_legalemployer INTO l_employer,l_orgnumber,l_from_date,l_to_date , l_ele_name , l_ele_code , l_archived_on;
CLOSE csr_legalemployer;


FOR emp_rec IN csr_emp (l_payroll_action_id) LOOP


IF (l_thirdparty_id <> emp_rec.thirdparty_id) then
   if csr_emp%rowcount = 1 then
     xml_tab(xml_ctr).xmlstring := '<LEGALEMPLOYER_RECORD>';
     xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<LegalEmployer>'||l_employer||'</LegalEmployer>';
     xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<OrgNumber>'||l_orgnumber||'</OrgNumber>';
     xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<FromPeriod>'||l_from_date||'</FromPeriod>';
     xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ToPeriod>'||l_to_date||'</ToPeriod>';
     xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ElementName>'|| l_ele_name ||'</ElementName>';
     xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ElementCode>'|| l_ele_code ||'</ElementCode>';
     xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ArchivedOn>'||  l_archived_on ||'</ArchivedOn>';
     xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '</LEGALEMPLOYER_RECORD>';
     xml_ctr := xml_ctr +1;
     xml_tab(xml_ctr).xmlstring := '<THIRDPARTY_RECORD>';
   else
     xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '</THIRDPARTY_RECORD>';
     --xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '</LEGALEMPLOYER_RECORD>';
     xml_ctr := xml_ctr + 1;
     xml_tab(xml_ctr).xmlstring := '<THIRDPARTY_RECORD>';
   end if ;

   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ThirdPartyName>'||emp_rec.thirdparty_name||'</ThirdPartyName>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ThirdPartyAddress>'||emp_rec.thirdparty_address||'</ThirdPartyAddress>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<BankAccNumber>'||emp_rec.bankaccountno||'</BankAccNumber>';

   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EMP_RECORD>';

   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<NI-Number>'|| emp_rec.emp_ni ||'</NI-Number>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeName>'|| emp_rec.order_name ||'</EmployeeName>';

   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeLastName>'|| emp_rec.last_name ||'</EmployeeLastName>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeFirstName>'|| emp_rec.first_name ||'</EmployeeFirstName>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeNumber>'|| emp_rec.emp_no ||'</EmployeeNumber>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOB>'|| emp_rec.emp_dob ||'</EmployeeDOB>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOH>'|| emp_rec.emp_doh ||'</EmployeeDOH>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeTitle>'|| emp_rec.emp_title ||'</EmployeeTitle>';



   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ReferenceNumber>'||emp_rec.refno||'</ReferenceNumber>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<DeductionBasis>'||emp_rec.deductionBasis||'</DeductionBasis>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Percentage>'||emp_rec.percentage||'</Percentage>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Amount>'||emp_rec.amount||'</Amount>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<DeductedThisPeriod>'||emp_rec.deductedthisperiod||'</DeductedThisPeriod>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring||'</EMP_RECORD>';

   l_thirdparty_id := emp_rec.thirdparty_id;

ELSE

   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EMP_RECORD>';

   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<NI-Number>'|| emp_rec.emp_ni ||'</NI-Number>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeName>'|| emp_rec.order_name ||'</EmployeeName>';

   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeLastName>'|| emp_rec.last_name ||'</EmployeeLastName>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeFirstName>'|| emp_rec.first_name ||'</EmployeeFirstName>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeNumber>'|| emp_rec.emp_no ||'</EmployeeNumber>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOB>'|| emp_rec.emp_dob ||'</EmployeeDOB>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOH>'|| emp_rec.emp_doh ||'</EmployeeDOH>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeTitle>'|| emp_rec.emp_title ||'</EmployeeTitle>';

   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ReferenceNumber>'||emp_rec.refno||'</ReferenceNumber>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<DeductionBasis>'||emp_rec.deductionBasis||'</DeductionBasis>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Percentage>'||emp_rec.percentage||'</Percentage>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Amount>'||emp_rec.amount||'</Amount>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<DeductedThisPeriod>'||emp_rec.deductedthisperiod||'</DeductedThisPeriod>';
   xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring||'</EMP_RECORD>';

   l_thirdparty_id := emp_rec.thirdparty_id;

END IF ;

END LOOP;

--hr_utility.trace('SUP_ORD: after FOR loop ');

IF (xml_tab(xml_ctr).xmlstring is null)
	THEN  raise no_data_found;
ELSE
	xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring||'</THIRDPARTY_RECORD>';
	xml_ctr := xml_ctr +1;
	xml_tab(xml_ctr).xmlstring := '</START>';
END IF;

write_to_clob(p_xml);

exception when no_data_found then
	 xml_tab(xml_ctr).xmlstring := '<LEGALEMPLOYER_RECORD>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '<LegalEmployer>'|| '</LegalEmployer>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<OrgNumber>'|| '</OrgNumber>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<FromPeriod>'|| '</FromPeriod>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ToPeriod>'|| '</ToPeriod>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ElementName>'|| '</ElementName>';
         xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ElementCode>'|| '</ElementCode>';
         xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ArchivedOn>'|| '</ArchivedOn>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring || '</LEGALEMPLOYER_RECORD>';

	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<THIRDPARTY_RECORD>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ThirdPartyName>'||'</ThirdPartyName>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ThirdPartyAddress>'||'</ThirdPartyAddress>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<BankAccNumber>'||'</BankAccNumber>';

	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EMP_RECORD>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<NI-Number>'||'</NI-Number>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeName>'||'</EmployeeName>';

         xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeLastName>'|| '</EmployeeLastName>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeFirstName>'|| '</EmployeeFirstName>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeNumber>'|| '</EmployeeNumber>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOB>'|| '</EmployeeDOB>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeDOH>'|| '</EmployeeDOH>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<EmployeeTitle>'|| '</EmployeeTitle>';

	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<ReferenceNumber>'||'</ReferenceNumber>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<DeductionBasis>'||'</DeductionBasis>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Percentage>'||'</Percentage>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<Amount>'||'</Amount>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'<DeductedThisPeriod>'||'</DeductedThisPeriod>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring||'</EMP_RECORD>';

	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'</THIRDPARTY_RECORD>';
	 xml_tab(xml_ctr).xmlstring := xml_tab(xml_ctr).xmlstring ||'</START>';

         write_to_clob(p_xml);


END populate_details;




------------------------------------------------------------------------------------------------------------

-- PROCEDURE for writing the xml to clob

PROCEDURE write_to_clob (p_xml out nocopy clob) is

l_xfdf_string clob;

BEGIN

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

END write_to_clob;


-------------------------------------------------------------------------------------------------------------------------
 END PAY_NO_SUPPORT_ORDER;

/
