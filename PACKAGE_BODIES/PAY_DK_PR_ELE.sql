--------------------------------------------------------
--  DDL for Package Body PAY_DK_PR_ELE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_PR_ELE" AS
/* $Header: pydkprele.pkb 120.11.12000000.2 2007/05/08 07:08:17 saurai noship $ */

	g_debug   boolean   :=  hr_utility.debug_enabled;
	l_business_group_id		NUMBER;
	/* variables to store the input values*/
	l_archive		VARCHAR2(3);
	l_from_date		DATE;
	l_to_date		DATE;
	l_effective_date	DATE;
	l_payroll_id		NUMBER;
	l_legal_employer_id NUMBER ;
	l_legal_employer_name VARCHAR2(240);
	l_element_set_id     NUMBER;
	g_err_num		NUMBER;

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
		,p_element_set_id    OUT  NOCOPY  NUMBER
		,p_payroll_id		OUT  NOCOPY  NUMBER
		,p_fromdate		OUT NOCOPY DATE
		,p_todate		OUT NOCOPY DATE
		)IS


CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
SELECT
	fnd_date.canonical_to_date(PAY_DK_PR_ELE.GET_PARAMETER(legislative_parameters,'FROM_DATE'))
	,fnd_date.canonical_to_date(PAY_DK_PR_ELE.GET_PARAMETER(legislative_parameters,'TO_DATE'))
	,PAY_DK_PR_ELE.GET_PARAMETER(legislative_parameters,'PAYROLL_ID')
	,PAY_DK_PR_ELE.GET_PARAMETER(legislative_parameters,'ELEMENT_SET_ID')
	,PAY_DK_PR_ELE.GET_PARAMETER(legislative_parameters,'ARCHIVE')
	,effective_date
	,business_group_id
FROM
	pay_payroll_actions
WHERE
	payroll_action_id = p_payroll_action_id;

BEGIN

	 OPEN csr_parameter_info (p_payroll_action_id);
	 FETCH csr_parameter_info  INTO	p_fromdate,p_todate,p_payroll_id ,
     p_element_set_id,p_archive,
	 p_effective_date ,p_business_group_id;
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
-------------------------------------------------------------------------------------------------------------------------
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
 /* RANGE CODE */
 PROCEDURE RANGE_CODE (pactid    IN    NUMBER
		      ,sqlstr    OUT   NOCOPY VARCHAR2)
 IS

-- Variable declarations

	l_count			NUMBER := 0;
	l_action_info_id	NUMBER;
	l_ovn			NUMBER;
	l_element_set_name VARCHAR2(240);
	l_payroll_name VARCHAR2(240);
	l_business_group_name VARCHAR2(240);

--cursor to check current archive exists
cursor csr_count is
select count(*)
from   pay_action_information
where  action_information_category = 'EMEA REPORT DETAILS'
and    action_information1         = 'PYDKPRELEA'
and    action_context_id           = pactid;

/*Bug fix 4961408-Cursor to get the element ytd*/
CURSOR csr_pr_ele_ytd
	(p_ele_type_id NUMBER
	,p_payroll_id NUMBER
	,p_from_date DATE
	,p_to_date DATE)
IS
 SELECT
	SUM (pay_balance_pkg.get_value(pay_dk_pr_ele.get_defined_balance_id
        (pivf.input_value_id,'_ASG_RUN')
        	,paa1.assignment_action_id)) ele_ytd
FROM
	per_all_assignments_f  paaf
	,pay_all_payrolls_f ppf
	,pay_assignment_actions paa1
	,pay_assignment_actions paa2
	,pay_payroll_actions ppa1
	,pay_payroll_actions ppa2
	,pay_run_results prr
	,pay_input_values_f pivf
	,pay_element_types_f petf
	,pay_action_interlocks  pai

WHERE
	paaf.business_group_id = l_business_group_id -- BG Check
	AND ppf.payroll_id = p_payroll_id
	AND petf.element_type_id = p_ele_type_id
	AND (petf.legislation_code = 'DK' OR petf.business_group_id = l_business_group_id)
	AND  paaf.payroll_id = ppf.payroll_id
	AND  paaf.assignment_status_type_id = 1 -- to check for active assignments
	AND paa1.assignment_id = paaf.assignment_id
	AND paa1.action_status = 'C'  -- Completed

	--for payroll actions
	AND ppa1.date_earned between p_from_date and p_to_date --date condition
	AND ppa1.action_type IN ('R','Q')  -- Payroll Run or Quickpay Run
	AND ppa1.payroll_action_id = paa1.payroll_action_id

	--for prepayments
	AND    paa2.action_status           = 'C' -- Completed
	AND    paa2.assignment_action_id    = pai.locking_action_id
	AND    paa2.payroll_action_id       = ppa2.payroll_action_id
	AND    ppa2.action_type            IN ('P','U')
	AND    ppa2.date_earned between p_from_date and p_to_date

	AND paa1.ASSIGNMENT_ACTION_ID = pai.locked_action_id
	/*date check*/
	AND    ppa2.date_earned between paaf.effective_start_date and paaf.effective_end_date
	AND    ppa2.date_earned between ppf.effective_start_date and ppf.effective_end_date
	AND    ppa2.date_earned between pivf.effective_start_date and pivf.effective_end_date

	-- for run results
	AND prr.assignment_action_id = paa1.assignment_action_id

	AND petf.element_type_id = prr.element_type_id
	AND pivf.element_type_id = prr.element_type_id
	AND pivf.name='Pay Value' ;

/* Cursor to get details if element set is null -Bug fix 4968059*/
CURSOR csr_pr_all_ele(p_payroll_action_id NUMBER)
IS
SELECT
	payroll_name
	,payroll_id
	,ele_type_id
	,ele_proc_prior
	,ele_name
	,input_value_id
	,date_earned
	,costed_code
	,SUM(pay_value) pay_value
--	,SUM(balance_amount) balance_amount
 FROM
( SELECT
	paa1.assignment_action_id	 asg_act_id
	,ppf.payroll_name payroll_name
	,ppf.payroll_id payroll_id
	,petf.element_type_id ele_type_id
	,petf.processing_priority ele_proc_prior
        ,NVL(petf.reporting_name,petf.element_name) ele_name
	,pay_dk_pr_ele.costed_code(prr.run_result_id,pivf.input_value_id) costed_code
	,pivf.input_value_id  input_value_id
	,to_char(ppa1.date_earned,'DD-MON-RRRR')    date_earned
	,pay_balance_pkg.get_value(pay_dk_pr_ele.get_defined_balance_id
        (pivf.input_value_id,'_ASG_RUN')
        	,paa1.assignment_action_id) pay_value
/*	,pay_balance_pkg.get_value(pay_dk_pr_ele.get_defined_balance_id
        (pivf.input_value_id,'_ASG_YTD'),
        	paa1.assignment_action_id) balance_amount*/
FROM
	per_all_assignments_f  paaf
	,pay_all_payrolls_f ppf
	,pay_assignment_actions paa1
	,pay_assignment_actions paa2
	,pay_payroll_actions ppa1
	,pay_payroll_actions ppa2
	,pay_run_results prr
	,pay_input_values_f pivf
	,pay_element_types_f petf
	,pay_action_interlocks  pai

WHERE
	paaf.business_group_id = l_business_group_id -- BG Check
	AND ppf.payroll_id = NVL(l_payroll_id,ppf.payroll_id)
	AND  paaf.payroll_id = ppf.payroll_id
	AND  paaf.assignment_status_type_id = 1 -- to check for active assignments
	AND paa1.assignment_id = paaf.assignment_id
	AND paa1.action_status = 'C'  -- Completed

	--for payroll actions
	AND ppa1.date_earned between l_from_date and l_to_date --date condition
	AND ppa1.action_type IN ('R','Q')  -- Payroll Run or Quickpay Run
	AND ppa1.payroll_action_id = paa1.payroll_action_id

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

	AND petf.element_type_id = prr.element_type_id
	AND (petf.legislation_code = 'DK' OR petf.business_group_id = l_business_group_id)
	AND petf.element_name <> 'Tax'    --To exclude Tax
    AND petf.element_name <> 'Mileage Claim' -- To exclude Mileage Claim
	AND pivf.element_type_id = prr.element_type_id
	AND pivf.name='Pay Value' )

GROUP BY
   	payroll_name
	,payroll_id
	,ele_type_id
	,ele_proc_prior
	,ele_name
	,input_value_id
	,date_earned
	,costed_code
ORDER BY payroll_id,ele_proc_prior,ele_type_id;

/* Cursor to get details if element set is specified*/
CURSOR csr_pr_ele_set(p_payroll_action_id NUMBER)
IS
SELECT
	payroll_name
	,payroll_id
	,ele_type_id
	,ele_proc_prior
	,ele_name
	,input_value_id
	,date_earned
	,costed_code
	,SUM(pay_value) pay_value
--	,SUM(balance_amount) balance_amount
 FROM
( SELECT
	paa1.assignment_action_id	 asg_act_id
	,ppf.payroll_name payroll_name
	,ppf.payroll_id payroll_id
	,petf.element_type_id ele_type_id
	,petf.processing_priority ele_proc_prior
        ,NVL(petf.reporting_name,petf.element_name) ele_name
	,pay_dk_pr_ele.costed_code(prr.run_result_id,pivf.input_value_id) costed_code
	,pivf.input_value_id  input_value_id
	,to_char(ppa1.date_earned,'DD-MON-RRRR')    date_earned
	,pay_balance_pkg.get_value(pay_dk_pr_ele.get_defined_balance_id
        (pivf.input_value_id,'_ASG_RUN')
        	,paa1.assignment_action_id) pay_value
/*	,pay_balance_pkg.get_value(pay_dk_pr_ele.get_defined_balance_id
        (pivf.input_value_id,'_ASG_YTD'),
        	paa1.assignment_action_id) balance_amount*/
FROM

	per_all_assignments_f  paaf
        ,pay_element_set_members pesm
	,pay_all_payrolls_f ppf
	,pay_assignment_actions paa1
	,pay_assignment_actions paa2
	,pay_payroll_actions ppa1
       ,pay_payroll_actions ppa2
	,pay_run_results prr
	,pay_input_values_f pivf
	,pay_element_types_f petf
	,pay_action_interlocks  pai

WHERE
	paaf.business_group_id = l_business_group_id -- BG Check
	AND pesm.element_set_id = l_element_set_id
	AND ppf.payroll_id = NVL(l_payroll_id,ppf.payroll_id)
	AND  paaf.payroll_id = ppf.payroll_id
	AND  paaf.assignment_status_type_id = 1 -- to check for active assignments
	AND paa1.assignment_id = paaf.assignment_id
	AND paa1.action_status = 'C'  -- Completed

	--for payroll actions
	AND ppa1.date_earned between l_from_date and l_to_date --date condition
	AND ppa1.action_type IN ('R','Q')  -- Payroll Run or Quickpay Run
	AND ppa1.payroll_action_id = paa1.payroll_action_id

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

	AND prr.element_type_id = pesm.element_type_id
	AND petf.element_type_id = prr.element_type_id
	AND (petf.legislation_code = 'DK' OR petf.business_group_id = l_business_group_id)
	AND petf.element_name <> 'Tax'    --To exclude Tax
    AND petf.element_name <> 'Mileage Claim' -- To exclude Mileage Claim
	AND pivf.element_type_id = prr.element_type_id
	AND pivf.name='Pay Value' )

GROUP BY
   	payroll_name
	,payroll_id
	,ele_type_id
	,ele_proc_prior
	,ele_name
	,input_value_id
	,date_earned
	,costed_code
ORDER BY payroll_id,ele_proc_prior,ele_type_id;

--AND paa.source_action_id  IS NOT NULL -- Not Master Action


l_actid			NUMBER;
l_asgid			NUMBER := -999;
l_year_start    DATE ;
l_ele_ytd       NUMBER ;
-----------------------------------------------------------------------------


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
 PAY_DK_PR_ELE.GET_ALL_PARAMETERS(
		 pactid
		,l_business_group_id
		,l_effective_date
		,l_archive
		,l_element_set_id
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

---to fetch the element set name
   BEGIN
	SELECT pes.element_set_name INTO
		l_element_set_name
	FROM
		pay_element_sets pes
	WHERE pes.element_set_id=l_element_set_id;
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

--to fetch the organization name
BEGIN
	SELECT haou.name INTO l_business_group_name
	FROM hr_all_organization_units haou
	WHERE haou.organization_id=l_business_group_id;
EXCEPTION
	WHEN OTHERS THEN
	NULL;
END;

-- Archive the REPORT DETAILS(input Parameters)

	pay_action_information_api.create_action_information (
	 p_action_information_id        => l_action_info_id	-- out parameter
	,p_object_version_number        => l_ovn		-- out parameter
	,p_action_context_id            => pactid		-- context id = payroll action id (of Archive)
	,p_action_context_type          => 'PA'			-- context type
	,p_effective_date               => l_effective_date	-- Date of running the archive
	,p_action_information_category  => 'EMEA REPORT DETAILS' -- Information Category
	,p_tax_unit_id                  => NULL			-- Legal Employer ID
	,p_jurisdiction_code            => NULL			-- Tax Municipality ID
	,p_action_information1          => 'PYDKPRELEA'	-- Conc Prg Short Name
	,p_action_information2          => l_business_group_id  	-- Business Group ID
	,p_action_information3          => l_from_date		-- Reporting from date
	,p_action_information4          => l_to_date		-- Reporting to date
	,p_action_information5          => l_business_group_name --Business Group Name
	,p_action_information6          => l_payroll_name		--payroll name
	,p_action_information8          => l_element_set_name);	-- element set name

   END IF; -- l_count < 1

--------------------------------------------------------------------
l_year_start:= TO_DATE ('01/01'||TO_CHAR(l_from_date,'YYYY'),'DD/MM/YYYY');

IF (l_element_set_id IS NULL) THEN
FOR csr_rec IN csr_pr_all_ele(pactid) LOOP
IF (csr_rec.pay_value > 0) THEN -- to archive only elements which have pay value > 0
	/*Bug fix 4961408*/
	OPEN csr_pr_ele_ytd(csr_rec.ele_type_id
			    ,csr_rec.payroll_id
			    ,l_year_start
			    ,csr_rec.date_earned);
	FETCH csr_pr_ele_ytd INTO l_ele_ytd;
	CLOSE csr_pr_ele_ytd;

  -- Creating  Archive Entries
  pay_action_information_api.create_action_information (

	 p_action_information_id        => l_action_info_id		-- out parameter
	,p_object_version_number        => l_ovn			-- out parameter
	,p_action_context_id            => pactid      	 	        -- context id = assignment action id (of Archive)
	,p_action_context_type          => 'PA'			        -- context type
	,p_effective_date               => l_effective_date		-- Date of running the archive
	,p_assignment_id		=>  NULL		        -- Assignment ID
	,p_action_information_category  => 'EMEA REPORT INFORMATION'	-- Information Category
	,p_tax_unit_id                  => NULL		                -- Legal Employer ID
	,p_jurisdiction_code            => NULL				-- Tax Municipality ID
	,p_action_information1          => 'PYDKPRELEA'		        --Con Program Short Name
	,p_action_information2          => csr_rec.payroll_id		-- payroll ID
	,p_action_information3          => csr_rec.payroll_name		-- payroll name
	,p_action_information4          =>  csr_rec.ele_type_id		-- element type id
	,p_action_information5          =>  csr_rec.ele_proc_prior		-- processing priority
	,p_action_information6          =>  csr_rec.ele_name		-- element name
	,p_action_information7          =>  csr_rec.date_earned		-- date_earned
	,p_action_information8          =>  csr_rec.costed_code		-- Costed value
	/*Storing in Canonical format to fix issues due to varying numeric formats*/
	,p_action_information9          =>  fnd_number.number_to_canonical(csr_rec.pay_value) -- Pay value
	,p_action_information10         =>  fnd_number.number_to_canonical(l_ele_ytd)         -- element YTD
                                                             );
END IF;
END LOOP;

ELSIF (l_element_set_id IS NOT NULL) THEN
FOR csr_rec IN csr_pr_ele_set(pactid) LOOP
IF (csr_rec.pay_value > 0) THEN -- to archive only elements which have pay value > 0

OPEN csr_pr_ele_ytd(csr_rec.ele_type_id
                    ,csr_rec.payroll_id
                    ,l_year_start
                    ,csr_rec.date_earned);
FETCH csr_pr_ele_ytd INTO l_ele_ytd;
CLOSE csr_pr_ele_ytd;

  -- Creating  Archive Entries
  pay_action_information_api.create_action_information (

	 p_action_information_id        => l_action_info_id		-- out parameter
	,p_object_version_number        => l_ovn			-- out parameter
	,p_action_context_id            => pactid      		        -- context id = assignment action id (of Archive)
	,p_action_context_type          => 'PA'			        -- context type
	,p_effective_date               => l_effective_date		-- Date of running the archive
	,p_assignment_id	        =>  NULL		        -- Assignment ID
	,p_action_information_category  => 'EMEA REPORT INFORMATION'	-- Information Category
	,p_tax_unit_id                  => NULL		               -- Legal Employer ID
	,p_jurisdiction_code            => NULL				-- Tax Municipality ID
	,p_action_information1          => 'PYDKPRELEA'		        --Con Program Short Name
	,p_action_information2          => csr_rec.payroll_id		-- payroll ID
	,p_action_information3          => csr_rec.payroll_name		-- payroll name
	,p_action_information4         =>  csr_rec.ele_type_id		-- element type id
	,p_action_information5         =>  csr_rec.ele_proc_prior		-- processing priority
	,p_action_information6         =>  csr_rec.ele_name		-- element name
	,p_action_information7         =>  csr_rec.date_earned		-- date_earned
	,p_action_information8         => csr_rec.costed_code		-- Costed value
	/*Storing in Canonical format to fix issues due to varying numeric formats*/
	,p_action_information9          =>  fnd_number.number_to_canonical(csr_rec.pay_value) -- Pay value
	,p_action_information10         =>  fnd_number.number_to_canonical(l_ele_ytd)         -- element YTD
                                                             );
END IF ;
END LOOP;
END IF ;

END IF; -- l_archive = 'Y'
----------------------------------------------------------------------------
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

------------------------------------------------------------------------------------------------
 /* ASSIGNMENT ACTION CODE */
PROCEDURE ASSIGNMENT_ACTION_CODE
 (p_payroll_action_id     IN NUMBER
 ,p_start_person          IN NUMBER
 ,p_end_person            IN NUMBER
 ,p_chunk                 IN NUMBER)
 IS

BEGIN

IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
END IF;
 END ASSIGNMENT_ACTION_CODE;

------------------------------------------------------------------------------------------------
 /* ARCHIVE CODE */
 PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
		      ,p_effective_date    IN DATE)
 IS
BEGIN
	 IF g_debug THEN
			hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',80);
	 END IF;
	 IF g_debug THEN
			hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',90);
	 END IF;
END ARCHIVE_CODE;

-------------------------------------------------------------------------------------------------------------------------

PROCEDURE POPULATE_DETAILS
	(p_payroll_action_id in VARCHAR2 ,
	p_template_name in VARCHAR2 ,
	p_xml OUT NOCOPY CLOB )
IS
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
l_payroll_id NUMBER :=-999;
l_tot_ele_run NUMBER := 0;
l_tot_ele_ytd NUMBER :=0;
--l_prev_date_earned VARCHAR2(30):= '-999';
l_IANA_charset VARCHAR2 (50);

cursor csr_pr_ele is

SELECT
	pai1.action_information3||' to '||pai1.action_information4 report_period
	,pai2.action_information2 payroll_id
	,pai2.action_information3 payroll_name
	,pai2.action_information4 ele_type_id
	,pai2.action_information5 ele_proc_prior
	,pai2.action_information6 ele_name
	,pai2.action_information7 date_earned
	,pai2.action_information8 costed_code
	,fnd_number.canonical_to_number(pai2.action_information9) pay_value
	,fnd_number.canonical_to_number(pai2.action_information10) balance_amount

FROM
	pay_action_information pai1,
	pay_action_information pai2
WHERE

        -- Removing to_char for bug fix 5231458
	--TO_CHAR(pai1.action_context_id)=l_payroll_action_id
        pai1.action_context_id = l_payroll_action_id
	AND pai1.action_information_category='EMEA REPORT DETAILS'
	--AND TO_CHAR(pai2.action_context_id)= l_payroll_action_id
	AND pai2.action_context_id = l_payroll_action_id
	AND pai2.action_information_category='EMEA REPORT INFORMATION'
ORDER BY
	TO_NUMBER(pai2.action_information2)
	,TO_NUMBER(pai2.action_information5)
	,TO_NUMBER(pai2.action_information4)
	,fnd_date.string_to_date(pai2.action_information7,'DD-MON-RRRR');

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

FOR csr_rec IN csr_pr_ele LOOP

IF (csr_rec.payroll_id <> l_payroll_id) THEN
  IF (csr_pr_ele%rowcount <> 1) THEN
    p_xml:=p_xml || '<Tot_ele_run>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_run,2),'999G999G990D99')),' ') || '</Tot_ele_run>';
    p_xml:=p_xml || '<Tot_ele_ytd>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_ytd,2),'999G999G990D99')),' ') || '</Tot_ele_ytd>';
     l_tot_ele_run := 0;
    l_tot_ele_ytd := 0;
	p_xml:= p_xml || '</ELEMENT_RECORD>';
	p_xml := p_xml ||'</PAYROLL_RECORD>';
	p_xml := p_xml ||'<PAYROLL_RECORD>';
	p_xml:= p_xml || '<ELEMENT_RECORD>';
	p_xml:=p_xml || '<Report_period>' || csr_rec.report_period || '</Report_period>';
	p_xml:=p_xml || '<Element_Name>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(csr_rec.ele_name) || '</Element_Name>';
	p_xml:=p_xml || '<Payroll_Name>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(csr_rec.payroll_name) || '</Payroll_Name>';
  END IF;
END IF;

IF( l_ele_type_id <> csr_rec.ele_type_id AND csr_rec.payroll_id = l_payroll_id)
   THEN
    p_xml:=p_xml || '<Tot_ele_run>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_run,2),'999G999G990D99')),' ') || '</Tot_ele_run>';
    p_xml:=p_xml || '<Tot_ele_ytd>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_ytd,2),'999G999G990D99')),' ') || '</Tot_ele_ytd>';
    l_tot_ele_run := 0;
    l_tot_ele_ytd := 0;
	p_xml:= p_xml || '</ELEMENT_RECORD>';
	p_xml:= p_xml || '<ELEMENT_RECORD>';
	p_xml:=p_xml || '<Report_period>' || csr_rec.report_period || '</Report_period>';
	p_xml:=p_xml || '<Element_Name>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(csr_rec.ele_name) || '</Element_Name>';
	p_xml:=p_xml || '<Payroll_Name>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(csr_rec.payroll_name) || '</Payroll_Name>';
END IF;

IF (csr_pr_ele%ROWCOUNT = 1) THEN
	p_xml := p_xml ||'<PAYROLL_RECORD>';
	p_xml:= p_xml || '<ELEMENT_RECORD>';
	p_xml:=p_xml || '<Report_period>' || csr_rec.report_period || '</Report_period>';
	p_xml:=p_xml || '<Element_Name>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(csr_rec.ele_name) || '</Element_Name>';
	p_xml:=p_xml || '<Payroll_Name>' || hr_dk_utility.REPLACE_SPECIAL_CHARS(csr_rec.payroll_name) || '</Payroll_Name>';
END IF;

	p_xml:= p_xml || '<ELEMENT_RECORD_PER_RUN>';
	p_xml:=p_xml || '<Costed_code>' || NVL(csr_rec.costed_code,' ') || '</Costed_code>';
	p_xml:=p_xml || '<Pay_Value>' || NVL(TRIM(TO_CHAR(ROUND(csr_rec.pay_value,2),'999G999G990D99')),' ')|| '</Pay_Value>';
	p_xml:=p_xml || '<Date_Earned>' || csr_rec.date_earned || '</Date_Earned>';
	/*Bug fix - 4961779*/
	/*Bug fix-4961408 As seperate cursor csr_pr_ele_ytd has been written this code is no more required*/
/*	IF (l_prev_date_earned = csr_rec.date_earned OR l_prev_date_earned = '-999') THEN
	    l_tot_ele_ytd := l_tot_ele_ytd + NVL(csr_rec.balance_amount,0);
	ELSIF (l_prev_date_earned <> csr_rec.date_earned) THEN
	    l_tot_ele_ytd :=nvl(csr_rec.balance_amount,0);
	END IF ;
	l_prev_date_earned := csr_rec.date_earned;*/
	p_xml:=p_xml || '<Balance_Amount>' || NVL(TRIM(TO_CHAR(ROUND(csr_rec.balance_amount,2),'999G999G990D99')),' ') || '</Balance_Amount>';
	p_xml:= p_xml || '</ELEMENT_RECORD_PER_RUN>';
l_tot_ele_run := l_tot_ele_run +  nvl(csr_rec.pay_value,0);
l_tot_ele_ytd := NVL(csr_rec.balance_amount,0); -- To get the last balance value which will be the total for that element.
l_ele_type_id := csr_rec.ele_type_id;
l_payroll_id:=csr_rec.payroll_id;
l_flag :=1;
END LOOP;

IF (l_flag = 1) THEN
    p_xml:=p_xml || '<Tot_ele_run>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_run,2),'999G999G990D99')),' ') || '</Tot_ele_run>';
    p_xml:=p_xml || '<Tot_ele_ytd>' || NVL(TRIM(TO_CHAR(ROUND(l_tot_ele_ytd,2),'999G999G990D99')),' ') || '</Tot_ele_ytd>';
     l_tot_ele_run := 0;
    l_tot_ele_ytd := 0;
   	p_xml:=p_xml || '</ELEMENT_RECORD>';
	p_xml:=p_xml || '</PAYROLL_RECORD>';
	p_xml:=p_xml || '</START>';
ELSIF (l_flag = 0) THEN
p_xml:=p_xml||'<PAYROLL_RECORD><ELEMENT_RECORD><ELEMENT_RECORD_PER_RUN></ELEMENT_RECORD_PER_RUN></ELEMENT_RECORD></PAYROLL_RECORD></START>';
END IF;

END POPULATE_DETAILS;
END PAY_DK_PR_ELE;

/
