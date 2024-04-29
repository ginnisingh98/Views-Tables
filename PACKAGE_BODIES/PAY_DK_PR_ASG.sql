--------------------------------------------------------
--  DDL for Package Body PAY_DK_PR_ASG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_PR_ASG" AS
/* $Header: pydkprasg.pkb 120.12.12000000.2 2007/05/08 07:07:19 saurai noship $ */

	g_debug   boolean   :=  hr_utility.debug_enabled;
	l_business_group_id		NUMBER;
	/* variables to store the input values*/
	l_archive		VARCHAR2(3);
	l_from_date		DATE;
	l_to_date		DATE;
	l_effective_date	DATE;
	l_payroll_id		NUMBER;
	l_assignment_set_id     NUMBER;
	g_err_num		NUMBER;
------------------------------------------------------------------------------------------------
/*Funtion to get the costed code- Bug Fix 4962281*/
FUNCTION COSTED_CODE
	(p_run_result_id IN NUMBER
	,p_input_value_id IN NUMBER)
	RETURN VARCHAR2  IS

l_costed_code VARCHAR2(250);

CURSOR csr_costed_code IS
SELECT
pcak.concatenated_segments cost_code
FROM
pay_costs pc
,pay_cost_allocation_keyflex pcak
WHERE
	NVL (pc.distributed_input_value_id, pc.input_value_id) = p_input_value_id
	AND pc.run_result_id = p_run_result_id
	AND pc.balance_or_cost       = 'C'
	AND pc.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id;
BEGIN
OPEN csr_costed_code;
FETCH csr_costed_code INTO l_costed_code;
CLOSE csr_costed_code;

RETURN l_costed_code;

END COSTED_CODE;

------------------------------------------------------------------------------------------------
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

------------------------------------------------------------------------------------------------
/* GET ALL PARAMETERS */
PROCEDURE GET_ALL_PARAMETERS(
 		 p_payroll_action_id	IN           NUMBER
		,p_business_group_id    OUT  NOCOPY  NUMBER
		,p_effective_date	OUT  NOCOPY  DATE
		,p_archive		OUT  NOCOPY  VARCHAR2
		,p_assignment_set_id    OUT  NOCOPY  NUMBER
		,p_payroll_id		OUT  NOCOPY  NUMBER
		,p_fromdate		OUT NOCOPY DATE
		,p_todate		OUT NOCOPY DATE
		)IS


	CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
	SELECT 	 PAY_DK_PR_ASG.GET_PARAMETER(legislative_parameters,'PAYROLL_ID')
		,PAY_DK_PR_ASG.GET_PARAMETER(legislative_parameters,'ASSIGNMENT_SET_ID')
		,PAY_DK_PR_ASG.GET_PARAMETER(legislative_parameters,'ARCHIVE')
		,fnd_date.canonical_to_date(PAY_DK_PR_ASG.GET_PARAMETER(legislative_parameters,'FROM_DATE'))
		,fnd_date.canonical_to_date(PAY_DK_PR_ASG.GET_PARAMETER(legislative_parameters,'TO_DATE'))
		,effective_date
		,business_group_id
	FROM  pay_payroll_actions
	WHERE payroll_action_id = p_payroll_action_id;

BEGIN

	 OPEN csr_parameter_info (p_payroll_action_id);
	 FETCH csr_parameter_info  INTO	p_payroll_id ,p_assignment_set_id,p_archive,
	 p_fromdate,p_todate,p_effective_date ,p_business_group_id;
	 CLOSE csr_parameter_info;
IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
END IF;

 END GET_ALL_PARAMETERS;

-------------------------------------------------------------------------------------------------------------------------
/*FUNCTION TO GET DEFINED BALANCE ID*/
FUNCTION GET_DEFINED_BALANCE_ID
  (p_input_value_id	    IN  VARCHAR2
  ,p_dbi_suffix     		IN  VARCHAR2)
   RETURN NUMBER IS
  l_defined_balance_id 		NUMBER;

BEGIN

SELECT
    defined_balance_id
INTO
	l_defined_balance_id
FROM
(
SELECT
	pdb.defined_balance_id defined_balance_id
FROM
	pay_defined_balances      pdb
	,pay_balance_types         pbt
	,pay_balance_dimensions    pbd
WHERE
	pbd.database_item_suffix = p_dbi_suffix
	AND    (pbd.legislation_code = 'DK' OR pbt.business_group_id = l_business_group_id)
    AND     pbt.input_value_id = p_input_value_id
	AND    (pbt.legislation_code = 'DK' OR pbt.business_group_id = l_business_group_id)
	AND    pdb.balance_type_id = pbt.balance_type_id
	AND    pdb.balance_dimension_id = pbd.balance_dimension_id
	AND    (pdb.legislation_code = 'DK' OR pbt.business_group_id = l_business_group_id)
)
WHERE ROWNUM < 2;
l_defined_balance_id := NVL(l_defined_balance_id,0);
RETURN l_defined_balance_id ;

EXCEPTION WHEN OTHERS THEN
RETURN NULL ;

END get_defined_balance_id;
------------------------------------------------------------------------------------

 /* RANGE CODE */
 PROCEDURE RANGE_CODE (pactid    IN    NUMBER
		      ,sqlstr    OUT   NOCOPY VARCHAR2)
 IS

-- Variable declarations

	l_count			NUMBER := 0;
	l_action_info_id	NUMBER;
	l_ovn			NUMBER;
	l_assignment_set_name VARCHAR2(150);
	l_payroll_name VARCHAR2(150);
	l_organization_name VARCHAR2(150);

--cursor to check current archive exists
cursor csr_count is
SELECT count(*)
FROM
	pay_action_information
WHERE
	action_information_category = 'EMEA REPORT DETAILS'
	AND     action_information1         = 'PYDKPRASGA'
	AND     action_context_id           = pactid;

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

  -- fetch the input parameter values
 PAY_DK_PR_ASG.GET_ALL_PARAMETERS(
		 pactid
		,l_business_group_id
		,l_effective_date
		,l_archive
		,l_assignment_set_id
		,l_payroll_id
		,l_from_date
		,l_to_date) ;

 -- check if we have to archive again
 IF  (l_archive = 'Y')   THEN

   -- check if record for current archive exists
   OPEN csr_count;
   FETCH csr_count INTO l_count;
   CLOSE csr_count;


   -- archive Report Details only if no record exists
  IF (l_count < 1) THEN

---to fetch the assignment set name
   BEGIN
	SELECT has.assignment_set_name INTO
		l_assignment_set_name
	FROM
		hr_assignment_sets has
	WHERE has.assignment_set_id=l_assignment_set_id;
  EXCEPTION
	WHEN OTHERS THEN
	NULL;
   END;

--to fetch the payroll name
BEGIN
	SELECT ppf.payroll_name INTO l_payroll_name
	FROM
	-- Replaced view  pay_payrolls_f with table pay_all_payrolls_f for bug fix 5231458
	--pay_payrolls_f ppf
	pay_all_payrolls_f ppf
	WHERE ppf.payroll_id=l_payroll_id;
EXCEPTION
	WHEN OTHERS THEN
	NULL;
END;

--to fetch the business group name
BEGIN
	SELECT haou.name INTO l_organization_name
	FROM hr_all_organization_units haou
	WHERE haou.organization_id=l_business_group_id;
EXCEPTION
	WHEN OTHERS THEN
	NULL;
END;

-- Archive the REPORT DETAILS

	pay_action_information_api.create_action_information (
	 p_action_information_id        => l_action_info_id	-- out parameter
	,p_object_version_number        => l_ovn		-- out parameter
	,p_action_context_id            => pactid		-- context id = payroll action id (of Archive)
	,p_action_context_type          => 'PA'			-- context type
	,p_effective_date               => l_effective_date	-- Date of running the archive
	,p_action_information_category  => 'EMEA REPORT DETAILS' -- Information Category
	,p_tax_unit_id                  => NULL			-- Legal Employer ID
	,p_jurisdiction_code            => NULL			-- Tax Municipality ID
	,p_action_information1          => 'PYDKPRASGA'	-- Conc Prg Short Name
	,p_action_information2          => l_business_group_id  	-- Business Group ID
	,p_action_information3          => l_from_date		-- Reporting from date
	,p_action_information4          => l_to_date		-- Reporting to date
	,p_action_information5          => l_organization_name	--Businee Group name
	,p_action_information6          => l_payroll_name		--payroll name
	,p_action_information7          => l_assignment_set_name);	-- assignment set name

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

 /* ASSIGNMENT ACTION CODE */
PROCEDURE ASSIGNMENT_ACTION_CODE
 (p_payroll_action_id     IN NUMBER
 ,p_start_person          IN NUMBER
 ,p_end_person            IN NUMBER
 ,p_chunk                 IN NUMBER)
 IS

/* Cursor to select data based on the i/p parameter assignment set*/
CURSOR csr_assignment_set
        (p_payroll_action_id    NUMBER,
         p_start_person      	NUMBER,
         p_end_person           NUMBER)
 IS

SELECT
	asg_id
	,asg_act_id
	,tax_unit_id
	,payroll_id
	,payroll_name
	,ele_type_id
	,ele_name
	,ele_proc_prior
	,input_value_id
	,date_earned
	,costed_code
	,pay_value
	,balance_amount
FROM
(SELECT
	paa1.assignment_id asg_id
	,paa1.assignment_action_id	 asg_act_id
	,paa1.tax_unit_id	 tax_unit_id
	,ppf.payroll_id payroll_id
	,ppf.payroll_name payroll_name
	,petf.element_type_id ele_type_id
	,NVL(petf.reporting_name,petf.element_name) ele_name
	,petf.processing_priority ele_proc_prior
	,pivf.input_value_id  input_value_id
	,TO_CHAR (ppa1.date_earned,'DD-MON-YYYY') date_earned
	,pay_dk_pr_asg.costed_code(prr.run_result_id,pivf.input_value_id) costed_code
	,pay_balance_pkg.get_value(pay_dk_pr_asg.get_defined_balance_id
                                (pivf.input_value_id,'_ASG_RUN')
           ,paa1.assignment_action_id) pay_value
	,pay_balance_pkg.get_value(pay_dk_pr_asg.get_defined_balance_id
                                (pivf.input_value_id,'_ASG_YTD')
           ,paa1.assignment_action_id) balance_amount
FROM
	hr_assignment_set_amendments hasa
	,per_all_assignments_f  paaf
	,pay_all_payrolls_f ppf
	,pay_assignment_actions paa1
	,pay_assignment_actions paa2
	,pay_payroll_actions ppa1
	,pay_payroll_actions ppa2
	,pay_action_interlocks  pai
	,pay_run_results prr
	,pay_input_values_f pivf
	,pay_element_types_f petf


WHERE
	paaf.person_id BETWEEN p_start_person AND p_end_person
	AND paaf.business_group_id = l_business_group_id
	AND hasa.assignment_set_id = l_assignment_set_id
     AND paaf.assignment_status_type_id = 1  -- to check for active assignment

	AND paaf.assignment_id = hasa.assignment_id
	AND ppf.payroll_id = NVL(l_payroll_id,ppf.payroll_id)
	AND  paaf.payroll_id = ppf.payroll_id

	AND paa1.assignment_id = paaf.assignment_id
	AND paa1.action_status = 'C'  -- Completed

	--for payroll actions
	AND ppa1.payroll_action_id = paa1.payroll_action_id
	AND ppa1.date_earned between l_from_date and l_to_date --date condition
	AND ppa1.action_type IN ('R','Q')  -- Payroll Run or Quickpay Run


	--for prepayments
	AND    paa2.action_status           = 'C' -- Completed
	AND    paa2.assignment_action_id    = pai.locking_action_id
	AND    paa2.payroll_action_id       = ppa2.payroll_action_id
	AND    ppa2.action_type            IN ('P','U')
	AND    ppa2.date_earned between l_from_date and l_to_date

	AND paa1.ASSIGNMENT_ACTION_ID = pai.locked_action_id
	/*date check*/
	AND    ppa2.date_earned between paaf.effective_start_date and paaf.effective_end_date
	AND    ppa2.date_earned between ppf.effective_start_date and ppf.effective_end_date
	AND    ppa2.date_earned between pivf.effective_start_date and pivf.effective_end_date

	-- for run results
	AND prr.assignment_action_id = paa1.assignment_action_id
	AND prr.element_type_id = pivf.element_type_id
	AND pivf.name='Pay Value'
	AND pivf.element_type_id = petf.element_type_id
	AND (petf.legislation_code = 'DK' OR petf.business_group_id = l_business_group_id)
	AND petf.element_name <> 'Tax'
    AND petf.element_name <> 'Mileage Claim')    --To exclude Tax and Mileage Claim

GROUP BY
	 asg_id
	,asg_act_id
	,tax_unit_id
	,payroll_name
	,payroll_id
	,ele_type_id
	,ele_name
	,ele_proc_prior
	,input_value_id
	,date_earned
	,costed_code
	,pay_value
	,balance_amount
ORDER BY asg_act_id;


/* Cursor to select data if assignmnet set is null-Bug fix 4968059*/
CURSOR csr_all_assignments
        (p_payroll_action_id    NUMBER,
         p_start_person      	NUMBER,
         p_end_person           NUMBER)
 IS

SELECT
	asg_id
	,asg_act_id
	,tax_unit_id
	,payroll_id
	,payroll_name
	,ele_type_id
	,ele_name
	,ele_proc_prior
	,input_value_id
	,date_earned
	,costed_code
	,pay_value
	,balance_amount
FROM
(SELECT
	paa1.assignment_id asg_id
	,paa1.assignment_action_id	 asg_act_id
	,paa1.tax_unit_id	 tax_unit_id
	,ppf.payroll_id payroll_id
	,ppf.payroll_name payroll_name
	,petf.element_type_id ele_type_id
	,NVL(petf.reporting_name,petf.element_name) ele_name
	,petf.processing_priority ele_proc_prior
	,pivf.input_value_id  input_value_id
	,TO_CHAR (ppa1.date_earned,'DD-MON-YYYY') date_earned
	,pay_dk_pr_asg.costed_code(prr.run_result_id,pivf.input_value_id) costed_code
	,pay_balance_pkg.get_value(pay_dk_pr_asg.get_defined_balance_id
                                (pivf.input_value_id,'_ASG_RUN')
           ,paa1.assignment_action_id) pay_value
	,pay_balance_pkg.get_value(pay_dk_pr_asg.get_defined_balance_id
                                (pivf.input_value_id,'_ASG_YTD')
           ,paa1.assignment_action_id) balance_amount

FROM
--	hr_assignment_set_amendments hasa
	per_all_assignments_f  paaf
	,pay_all_payrolls_f ppf
	,pay_assignment_actions paa1
	,pay_assignment_actions paa2
	,pay_payroll_actions ppa1
	,pay_payroll_actions ppa2
	,pay_action_interlocks  pai
	,pay_run_results prr
	,pay_input_values_f pivf
	,pay_element_types_f petf
WHERE

	paaf.person_id BETWEEN p_start_person AND p_end_person
    AND paaf.business_group_id = l_business_group_id
    AND paaf.assignment_status_type_id = 1  -- to check for active assignment
	AND ppf.payroll_id = NVL(l_payroll_id,ppf.payroll_id)
	AND  paaf.payroll_id = ppf.payroll_id

	AND paa1.assignment_id = paaf.assignment_id
	AND paa1.action_status = 'C'  -- Completed


	--for payroll actions
	AND ppa1.payroll_action_id = paa1.payroll_action_id
	AND ppa1.date_earned between l_from_date and l_to_date --date condition
	AND ppa1.action_type IN ('R','Q')  -- Payroll Run or Quickpay Run


	--for prepayments
	AND    paa2.action_status           = 'C' -- Completed
	AND    paa2.assignment_action_id    = pai.locking_action_id
	AND    paa2.payroll_action_id       = ppa2.payroll_action_id
	AND    ppa2.action_type            IN ('P','U')
	AND    ppa2.date_earned between l_from_date and l_to_date

	AND paa1.ASSIGNMENT_ACTION_ID = pai.locked_action_id
	/*date check*/
	AND    ppa2.date_earned between paaf.effective_start_date and paaf.effective_end_date
	AND    ppa2.date_earned between ppf.effective_start_date and ppf.effective_end_date
	AND    ppa2.date_earned between pivf.effective_start_date and pivf.effective_end_date

	-- for run results
	AND prr.assignment_action_id = paa1.assignment_action_id
	AND prr.element_type_id = pivf.element_type_id
	AND pivf.name='Pay Value'
	AND pivf.element_type_id = petf.element_type_id
	AND (petf.legislation_code = 'DK' OR petf.business_group_id = l_business_group_id)
	AND petf.element_name <> 'Tax'
    AND petf.element_name <> 'Mileage Claim')    --To exclude Tax and Mileage Claim

GROUP BY
	 asg_id
	,asg_act_id
	,tax_unit_id
	,payroll_name
	,payroll_id
	,ele_type_id
	,ele_name
	,ele_proc_prior
	,input_value_id
	,date_earned
	,costed_code
	,pay_value
	,balance_amount
ORDER BY asg_act_id;

l_count			NUMBER := 0;
l_action_info_id	NUMBER;
l_ovn			NUMBER;
l_actid			NUMBER;
l_asgid			NUMBER := -999;
l_asg_act_id    NUMBER := -999;


 BEGIN
 PAY_DK_PR_ASG.GET_ALL_PARAMETERS(
		 p_payroll_action_id
		,l_business_group_id
		,l_effective_date
		,l_archive
		,l_assignment_set_id
		,l_payroll_id
		,l_from_date
		,l_to_date) ;

 IF g_debug THEN
      hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
END IF;

-- check if we have to archive again
IF  (l_archive = 'Y') THEN

-- fetch assignments details
IF (l_assignment_set_id IS NOT NULL ) THEN   -- for a single assignment set

FOR csr_rec IN csr_assignment_set
	( p_payroll_action_id
	 ,p_start_person
	 ,p_end_person)
LOOP

IF (csr_rec.pay_value > 0) THEN -- to archive only elements which have pay value > 0
--check for change of assignment id to create new assignment action id
IF (csr_rec.asg_act_id <> l_asg_act_id) THEN
	BEGIN
		SELECT pay_assignment_actions_s.NEXTVAL INTO l_actid FROM   dual;
	EXCEPTION
		WHEN OTHERS THEN
		NULL ;
	END ;
  -- Create the archive assignment action
  hr_nonrun_asact.insact(l_actid ,csr_rec.asg_id ,p_payroll_action_id ,p_chunk ,NULL);
END IF ;


  -- Creating Initial Archive Entries
  pay_action_information_api.create_action_information (

	 p_action_information_id        => l_action_info_id		-- out parameter
	,p_object_version_number        => l_ovn			-- out parameter
	,p_action_context_id            => l_actid        		-- context id = assignment action id (of Archive)
	,p_action_context_type          => 'AAP'			-- context type
	,p_effective_date               => l_effective_date		-- Date of running the archive
	,p_assignment_id	  	=> csr_rec.asg_id		-- Assignment ID
	,p_action_information_category  => 'EMEA REPORT INFORMATION'	-- Information Category
	,p_tax_unit_id                  => csr_rec.tax_unit_id		-- Legal Employer ID
	,p_jurisdiction_code            => NULL				-- Tax Municipality ID
	,p_action_information1          => 'PYDKPRASGA'		 --Con Program Short Name
	,p_action_information2          => csr_rec.payroll_id		-- payroll id
	,p_action_information3          => p_payroll_action_id		-- payroll action id (of Archive)
	,p_action_information4          => csr_rec.asg_act_id		-- Original / Main Asg Action ID
	,p_action_information5          => csr_rec.payroll_name		-- Payroll Name
	,p_action_information6         => csr_rec.ele_type_id		-- element type id
	,p_action_information7         => csr_rec.ele_proc_prior	-- element processing priority
	,p_action_information8         => csr_rec.ele_name		       -- element name
	,p_action_information9         => csr_rec.input_value_id	-- input value id
	,p_action_information10         => csr_rec.date_earned		-- date_earned
	,p_action_information11         => csr_rec.costed_code		-- costed code
	/*Storing in Canonical format to fix issues due to varying numeric formats*/
	,p_action_information17         => fnd_number.number_to_canonical(csr_rec.pay_value) -- pay value
	,p_action_information18         => fnd_number.number_to_canonical(csr_rec.balance_amount)       -- balance amount


	);

l_asg_act_id := csr_rec.asg_act_id;
END IF ;
END LOOP;

ELSIF (l_assignment_set_id IS NULL) THEN  -- if assignmnet set is null

FOR csr_rec IN csr_all_assignments
	( p_payroll_action_id
	 ,p_start_person
	 ,p_end_person)
LOOP
IF (csr_rec.pay_value > 0) THEN -- to archive only elements which have pay value > 0
--check for change of assignment id to create new assignment action id
IF (csr_rec.asg_act_id <> l_asg_act_id) THEN
	BEGIN
		SELECT pay_assignment_actions_s.NEXTVAL INTO l_actid FROM   dual;
	EXCEPTION
		WHEN OTHERS THEN
		NULL ;
	END ;
  -- Create the archive assignment action
  hr_nonrun_asact.insact(l_actid ,csr_rec.asg_id ,p_payroll_action_id ,p_chunk ,NULL);
END IF ;


  -- Creating Initial Archive Entries
  pay_action_information_api.create_action_information (

	 p_action_information_id        => l_action_info_id		-- out parameter
	,p_object_version_number        => l_ovn			-- out parameter
	,p_action_context_id            => l_actid        		-- context id = assignment action id (of Archive)
	,p_action_context_type          => 'AAP'			-- context type
	,p_effective_date               => l_effective_date		-- Date of running the archive
	,p_assignment_id	  	         => csr_rec.asg_id		-- Assignment ID
	,p_action_information_category  => 'EMEA REPORT INFORMATION'	-- Information Category
	,p_tax_unit_id                  => csr_rec.tax_unit_id		-- Legal Employer ID
	,p_jurisdiction_code            => NULL				-- Tax Municipality ID
	,p_action_information1          => 'PYDKPRASGA'		 --Con Program Short Name
	,p_action_information2          => csr_rec.payroll_id		-- payroll id
	,p_action_information3          => p_payroll_action_id		-- payroll action id (of Archive)
	,p_action_information4          => csr_rec.asg_act_id		-- Original / Main Asg Action ID
	,p_action_information5          => csr_rec.payroll_name		-- Payroll Name
	,p_action_information6         => csr_rec.ele_type_id		-- element type id
	,p_action_information7         => csr_rec.ele_proc_prior	-- element processing priority
	,p_action_information8         => csr_rec.ele_name		       -- element name
--	,p_action_information9         => csr_rec.input_value_id	-- input value id
	,p_action_information10         => csr_rec.date_earned		-- date_earned
	,p_action_information11         => csr_rec.costed_code		-- costed code
	/*Storing in Canonical format to fix issues due to varying numeric formats*/
	,p_action_information17         => fnd_number.number_to_canonical(csr_rec.pay_value) -- pay value
	,p_action_information18         => fnd_number.number_to_canonical(csr_rec.balance_amount)       -- balance amount

	);

l_asg_act_id := csr_rec.asg_act_id;
END IF ;
END LOOP;

END IF;
END IF; -- l_archive = 'Y'

IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
END IF;
END ASSIGNMENT_ACTION_CODE;

------------------------------------------------------------------------------------------------
 /* ARCHIVE CODE */
 PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
 		      ,p_effective_date    IN DATE)
 IS

-- Cursor to get the action_information_id and original/main assignment_action_id and input value id


CURSOR csr_get_act_info (p_assignment_action_id  NUMBER , p_effective_date DATE) is
SELECT
	TO_NUMBER (ACTION_INFORMATION_ID) action_info_id
FROM
pay_action_information
WHERE
	ACTION_INFORMATION_CATEGORY = 'EMEA REPORT INFORMATION'
	AND    ACTION_INFORMATION1 = 'PYDKPRASGA'
	AND    ACTION_CONTEXT_TYPE = 'AAP'
	AND    ACTION_CONTEXT_ID = p_assignment_action_id
	AND    EFFECTIVE_DATE = p_effective_date ;


--cursor to get the employee details and assignment number
CURSOR csr_emp_details (p_assignment_action_id	NUMBER)
IS
SELECT
    haou.NAME organization_name
	,papf.employee_number emp_num
--	,papf.order_name ename
	/*Name format- last name, first name middle name*/
	,SUBSTR (papf.last_name,1,90)||', '||SUBSTR(papf.first_name,1,90)||NVL2(papf.middle_names,' '||papf.middle_names,NULL) ename
	,pj.name job_title
	,paaf.assignment_number asg_num

FROM
	per_all_people_f papf
	,per_all_assignments_f  paaf
	,pay_assignment_actions paa
	,per_jobs pj
,hr_all_organization_units haou
WHERE

	paa.assignment_action_id = p_assignment_action_id
	AND paa.assignment_id = paaf.assignment_id
	AND papf.person_id=paaf.person_id
	and paaf.job_id=pj.job_id(+)
	AND paaf.organization_id = haou.organization_id

ORDER BY papf.person_id;


-- Variable declaration

l_action_info_id	NUMBER;
l_ovn			NUMBER;
l_ele_type_id		NUMBER;
l_count			NUMBER := 0;
l_payroll_action_id	NUMBER;

rec_emp_details csr_emp_details%rowtype;

 BEGIN
 IF g_debug THEN
 		hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',380);
 END IF;
	BEGIN
		SELECT payroll_action_id
		INTO l_payroll_action_id
		FROM pay_assignment_actions
		WHERE assignment_action_id = p_assignment_action_id ;
	EXCEPTION
	WHEN  OTHERS  THEN
	NULL ;
	END ;


 -- check if we have to archive again
 IF  (l_archive = 'Y')  THEN


--fetch employee details
OPEN csr_emp_details(p_assignment_action_id);
FETCH csr_emp_details INTO rec_emp_details;
CLOSE csr_emp_details;

FOR csr_get_act_info_rec IN csr_get_act_info (p_assignment_action_id , p_effective_date ) LOOP

  -- Updating the Initial Archive Entries
	pay_action_information_api.update_action_information (
	 p_action_information_id        => csr_get_act_info_rec.action_info_id		-- in parameter
	,p_object_version_number        => l_ovn			                        -- in out parameter
	,p_action_information12          => rec_emp_details.organization_name	 --organization name)
	,p_action_information13          => rec_emp_details.emp_num		         -- employee number
	,p_action_information14          => rec_emp_details.ename		         -- employee name
	,p_action_information15          => rec_emp_details.asg_num	             -- assignment number
	,p_action_information16          => rec_emp_details.job_title             -- job title
   );

--END LOOP;
END LOOP;

END IF; -- l_archive = 'Y'

 IF g_debug THEN
 		hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',390);
 END IF;

END ARCHIVE_CODE;

PROCEDURE POPULATE_DETAILS(p_payroll_action_id in VARCHAR2 ,
		  			       p_template_name in VARCHAR2 ,
						   p_xml OUT NOCOPY CLOB ) IS

l_employer hr_all_organization_units.name%type;
l_orgnumber hr_organization_information.org_information1%type;
l_from_date DATE;
l_to_date DATE;
-- For bug fix 5231458
--l_payroll_action_id varchar2(150);
l_payroll_action_id NUMBER;
l_archiver varchar2(150);
l_ele_type_id NUMBER:=-999;
l_flag NUMBER :=0;
l_asg_id per_all_assignments_f.assignment_number%TYPE := -999;
l_tot_ele_run NUMBER := 0;
l_tot_ele_ytd NUMBER :=0;
l_tot_asg_run NUMBER := 0;
l_tot_asg_ytd NUMBER :=0;
l_prev_date_earned VARCHAR2(30):= '-999';
l_IANA_charset VARCHAR2 (50);

cursor csr_asg is
SELECT
	pai1.action_information3||' to '||pai1.action_information4 report_period
	,pai2.action_information2 payroll_id
	,pai2.action_information5 payroll_name
	,pai2.action_information12 org_name
	,pai2.action_information13 emp_numn
	,pai2.action_information14 ename
	,pai2.assignment_id asg_id
	,pai2.action_information15 asg_num
	,pai2.action_information16 job_title
	,pai2.action_information6 ele_type_id
	,pai2.action_information7 ele_proc_prior
	,pai2.action_information8 ele_name
	,pai2.action_information10 date_earned
	,pai2.action_information11 costed_code
	,fnd_number.canonical_to_number(pai2.action_information17) pay_value
	,fnd_number.canonical_to_number(pai2.action_information18) balance_amount


FROM
pay_action_information pai1,pay_action_information pai2
WHERE
        -- Removing to_char for bug fix 5231458
	-- Added to_char for bug fix 5236372
	--TO_CHAR(pai1.action_context_id)=l_payroll_action_id
        pai1.action_context_id = l_payroll_action_id
	AND pai1.action_information_category='EMEA REPORT DETAILS'
	AND pai2.action_information3 = TO_CHAR(pai1.action_context_id)
	--AND pai2.action_information3 = pai1.action_context_id
	AND pai2.action_information_category='EMEA REPORT INFORMATION'
ORDER BY
	TO_NUMBER (pai2.action_information2),
	TO_NUMBER (pai2.action_information13),
	pai2.action_information15,
	TO_NUMBER (pai2.action_information7),
	TO_NUMBER (pai2.action_information6),
	fnd_date.string_to_date(pai2.action_information10,'DD-MON-YYYY');

BEGIN
IF p_payroll_action_id  IS NULL THEN

BEGIN
SELECT
	payroll_action_id
INTO
	l_payroll_action_id
FROM
	pay_payroll_actions ppa,
	fnd_conc_req_summary_v fcrs,
	fnd_conc_req_summary_v fcrs1
WHERE
	fcrs.request_id = FND_GLOBAL.CONC_REQUEST_ID
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

l_IANA_charset :=PAY_DK_GENERAL.get_IANA_charset ;
/*Setting the Character Set Dynamically*/
--p_xml := '<?xml version = "1.0" encoding = "UTF-8"?>';
p_xml := '<?xml version = "1.0" encoding = "'||l_IANA_charset||'"?>';

p_xml:=p_xml || '<START>';
FOR asg_rec IN csr_asg LOOP
IF (asg_rec.asg_id <> l_asg_id) THEN
  IF (csr_asg%rowcount <> 1) THEN
    p_xml:=p_xml || '<Tot_ele_run>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_run,2),'999G999G990D99')),' ') || '</Tot_ele_run>';
    p_xml:=p_xml || '<Tot_ele_ytd>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_ytd,2),'999G999G990D99')),' ') || '</Tot_ele_ytd>';
    l_tot_asg_run := l_tot_asg_run + l_tot_ele_run;
    l_tot_asg_ytd := l_tot_asg_ytd + l_tot_ele_ytd;
    l_tot_ele_run := 0;
    l_tot_ele_ytd := 0;
    l_prev_date_earned:=-999;
    p_xml:= p_xml || '</ELEMENT_RECORD>';
    p_xml:=p_xml || '<Tot_asg_run>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_asg_run,2),'999G999G990D99')),' ') || '</Tot_asg_run>';
    p_xml:=p_xml || '<Tot_asg_ytd>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_asg_ytd,2),'999G999G990D99')),' ') || '</Tot_asg_ytd>';
    l_tot_asg_run := 0;
    l_tot_asg_ytd := 0;
	p_xml:= p_xml || '</ASSIGNMENT_RECORD>';
  END IF;
	p_xml:= p_xml || '<ASSIGNMENT_RECORD>';
	p_xml:=p_xml || '<Report_period>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(asg_rec.report_period) || '</Report_period>';
	p_xml:=p_xml || '<Employee_Number>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(asg_rec.emp_numn) || '</Employee_Number>';
	p_xml:=p_xml || '<Employee_Name>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(asg_rec.ename) || '</Employee_Name>';
	p_xml:=p_xml || '<Assignment_Number>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(asg_rec.asg_num) || '</Assignment_Number>';
	p_xml:=p_xml || '<Job_Title>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(asg_rec.job_title) || '</Job_Title>';
	p_xml:=p_xml || '<Organization_Name>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(asg_rec.org_name) || '</Organization_Name>';
	p_xml:=p_xml || '<Payroll_Name>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(asg_rec.payroll_name) || '</Payroll_Name>';
END IF;

IF (csr_asg%ROWCOUNT =1 OR asg_rec.asg_id <> l_asg_id) THEN
	p_xml:= p_xml || '<ELEMENT_RECORD>';
ELSIF( l_ele_type_id <> asg_rec.ele_type_id AND asg_rec.asg_id = l_asg_id) THEN
    p_xml:=p_xml || '<Tot_ele_run>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_run,2),'999G999G990D99')),' ') || '</Tot_ele_run>';
    p_xml:=p_xml || '<Tot_ele_ytd>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_ytd,2),'999G999G990D99')),' ') || '</Tot_ele_ytd>';
    l_tot_asg_run := l_tot_asg_run + l_tot_ele_run;
    l_tot_asg_ytd := l_tot_asg_ytd + l_tot_ele_ytd;
    l_tot_ele_run := 0;
    l_tot_ele_ytd := 0;
    l_prev_date_earned:=-999;
	p_xml:= p_xml || '</ELEMENT_RECORD>';
	p_xml:= p_xml || '<ELEMENT_RECORD>';
END IF;
	p_xml:= p_xml || '<ELEMENT_RECORD_PER_RUN>';
	p_xml:=p_xml || '<Element_Name>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(asg_rec.ele_name) || '</Element_Name>';
	p_xml:=p_xml || '<Date_Earned>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(asg_rec.date_earned) || '</Date_Earned>';
	p_xml:=p_xml || '<Costed_code>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(NVL(asg_rec.costed_code,' ')) || '</Costed_code>';
	p_xml:=p_xml || '<Pay_Value>' || NVL(TRIM(TO_CHAR(ROUND(asg_rec.pay_value,2),'999G999G990D99')),' ')|| '</Pay_Value>';
	p_xml:=p_xml || '<Balance_Amount>' || NVL(TRIM(TO_CHAR(ROUND(asg_rec.balance_amount,2),'999G999G990D99')),' ') || '</Balance_Amount>';
	/*Bug fix - 4961779*/
 /*IF (l_prev_date_earned = asg_rec.date_earned OR l_prev_date_earned = '-999') THEN
	    l_tot_ele_ytd := l_tot_ele_ytd + NVL(asg_rec.balance_amount,0);
	ELSIF (l_prev_date_earned <> asg_rec.date_earned) THEN
	    l_tot_ele_ytd :=nvl(asg_rec.balance_amount,0);
	END IF ;
	l_prev_date_earned := asg_rec.date_earned;*/
	p_xml:= p_xml || '</ELEMENT_RECORD_PER_RUN>';
/*To handle mulitple element entry situations*/
IF (l_prev_date_earned <> asg_rec.date_earned OR l_prev_date_earned = '-999') THEN
l_tot_ele_run := l_tot_ele_run +  nvl(asg_rec.pay_value,0);
END IF ;
l_prev_date_earned := asg_rec.date_earned;
l_tot_ele_ytd := NVL(asg_rec.balance_amount,0); -- To get the last balance value which will be the total for that element.
l_ele_type_id := asg_rec.ele_type_id;
l_asg_id:=asg_rec.asg_id;
l_flag :=1;
END LOOP;

IF (l_flag = 1) THEN
    p_xml:=p_xml || '<Tot_ele_run>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_run,2),'999G999G990D99')),' ') || '</Tot_ele_run>';
    p_xml:=p_xml || '<Tot_ele_ytd>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_ytd,2),'999G999G990D99')),' ') || '</Tot_ele_ytd>';
    l_tot_asg_run := l_tot_asg_run + l_tot_ele_run;
    l_tot_asg_ytd := l_tot_asg_ytd + l_tot_ele_ytd;
    l_tot_ele_run := 0;
    l_tot_ele_ytd := 0;
    l_prev_date_earned:=-999;
    p_xml:=p_xml || '</ELEMENT_RECORD>';
    p_xml:=p_xml || '<Tot_asg_run>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_asg_run,2),'999G999G990D99')),' ') || '</Tot_asg_run>';
    p_xml:=p_xml || '<Tot_asg_ytd>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_asg_ytd,2),'999G999G990D99')),' ') || '</Tot_asg_ytd>';
    l_tot_asg_run := 0;
    l_tot_asg_ytd := 0;
	p_xml:= p_xml || '</ASSIGNMENT_RECORD>';
	p_xml:=p_xml || '</START>';
ELSIF (l_flag = 0) THEN
p_xml:=p_xml||'<ASSIGNMENT_RECORD><ELEMENT_RECORD></ELEMENT_RECORD></ASSIGNMENT_RECORD></START>';
END IF;
END POPULATE_DETAILS;
END PAY_DK_PR_ASG;

/
