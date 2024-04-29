--------------------------------------------------------
--  DDL for Package Body PAY_SE_TAX_DECL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_TAX_DECL" AS
/* $Header: pysetada.pkb 120.8 2008/01/25 11:58:23 rsengupt noship $ */

	g_debug   boolean   :=  hr_utility.debug_enabled;
	l_business_id		NUMBER;
	/* variables to store the input values*/
	l_archive		VARCHAR2(3);
	l_from_date		DATE;
	l_to_date		DATE;
	l_effective_date	DATE;
	l_payroll_id		NUMBER;

	l_legal_employer_id NUMBER ;
	l_legal_employer_name VARCHAR2(240);
	l_element_set_id     NUMBER;
	g_err_num	     NUMBER;

--------------------------------------------------------------------------------------
----------
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
/*IF g_debug THEN
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
			  instr(p_parameter_string||' ', l_delimiter,l_start_pos) -
l_start_pos);

	 IF p_segment_number IS NOT NULL THEN
		l_parameter := ':'||l_parameter||':';
		l_parameter := substr(l_parameter,
		instr(l_parameter,':',1,p_segment_number)+1,
		instr(l_parameter,':',1,p_segment_number+1) -1
		- instr(l_parameter,':',1,p_segment_number));
	END IF;
END IF;

   RETURN l_parameter;*/
l_start_pos := INSTR(' ' || p_parameter_string, l_delimiter || p_token || '=');
  --
  IF l_start_pos = 0 THEN
   l_delimiter := '|';
   l_start_pos := INSTR(' ' || p_parameter_string, l_delimiter || p_token || '=');
  END IF;
  --
  IF l_start_pos <> 0 THEN
  l_delimiter := '|';
   l_start_pos := l_start_pos + LENGTH(p_token || '=');
   l_parameter := SUBSTR(p_parameter_string, l_start_pos, INSTR(p_parameter_string || ' ', l_delimiter, l_start_pos) - l_start_pos);
  END IF;
  RETURN l_parameter;

IF g_debug THEN
	      hr_utility.set_location(' Leaving Function GET_PARAMETER',20);
END IF;
 END GET_PARAMETER;

--------------------------------------------------------------------------------------
----------
/* GET ALL PARAMETERS */
PROCEDURE GET_ALL_PARAMETERS(
 		 p_payroll_action_id	IN           NUMBER
		,p_business_group_id    OUT  NOCOPY  NUMBER
		,p_effective_date	OUT  NOCOPY  DATE
		,p_archive		OUT  NOCOPY  VARCHAR2
		,p_legal_employer_id   OUT  NOCOPY  NUMBER
		,p_month OUT NOCOPY VARCHAR2
		,p_year		OUT  NOCOPY  NUMBER
		,p_administrative_code		OUT NOCOPY VARCHAR2
		,p_information		OUT NOCOPY VARCHAR2
		,p_declaration_due_date OUT NOCOPY DATE
		)IS


	CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
	SELECT
    	 PAY_SE_TAX_DECL.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER')
        ,PAY_SE_TAX_DECL.GET_PARAMETER(legislative_parameters,'MONTH')
        ,PAY_SE_TAX_DECL.GET_PARAMETER(legislative_parameters,'YEAR')

,FND_DATE.canonical_to_date(PAY_SE_TAX_DECL.GET_PARAMETER(legislative_parameters,
'DECLARATION_DUE_DATE'))
        ,PAY_SE_TAX_DECL.GET_PARAMETER(legislative_parameters,'ADMINISTRATIVE_CODE')
	  	,PAY_SE_TAX_DECL.GET_PARAMETER(legislative_parameters,'INFORMATION')
	  	,PAY_SE_TAX_DECL.GET_PARAMETER(legislative_parameters,'ARCHIVE')
		,effective_date
		,business_group_id
	FROM  pay_payroll_actions
	WHERE payroll_action_id = p_payroll_action_id;

BEGIN

	 OPEN csr_parameter_info (p_payroll_action_id);
	 FETCH csr_parameter_info  INTO
     p_legal_employer_id,
     p_month,
     p_year,
     p_declaration_due_date,
     p_administrative_code,
     p_information,
     p_archive,
	 p_effective_date,
     p_business_group_id;
	 CLOSE csr_parameter_info;
IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
END IF;

 END GET_ALL_PARAMETERS;

--------------------------------------------------------------------------------------
-----------------------------------
/*FUNCTION TO GET DEFINED BALANCE ID*/
FUNCTION GET_DEFINED_BALANCE_ID
  (p_balance_name   		IN  VARCHAR2
  ,p_dbi_suffix     		IN  VARCHAR2 )
   RETURN NUMBER IS
  l_defined_balance_id 		NUMBER;

BEGIN

SELECT
	pdb.defined_balance_id
INTO
	l_defined_balance_id
FROM
	pay_defined_balances      pdb
	,pay_balance_types         pbt
	,pay_balance_dimensions    pbd
WHERE
	pbd.database_item_suffix = p_dbi_suffix
	AND    (pbd.legislation_code = 'SE' OR pbt.business_group_id = l_business_id)
	AND    pbt.balance_name = p_balance_name
	AND    (pbt.legislation_code = 'SE' OR pbt.business_group_id = l_business_id)
	AND    pdb.balance_type_id = pbt.balance_type_id
	AND    pdb.balance_dimension_id = pbd.balance_dimension_id
	AND    (pdb.legislation_code = 'SE' OR pbt.business_group_id = l_business_id);

l_defined_balance_id := NVL(l_defined_balance_id,0);

RETURN l_defined_balance_id ;

END get_defined_balance_id;
--------------------------------------------------------------------------------------
-----------------------------------
/*GET BALANCE NAME*/
FUNCTION GET_BALANCE_NAME
  (p_input_value_id	IN  VARCHAR2)
RETURN VARCHAR2
IS
p_balance_name VARCHAR2(240);
BEGIN
SELECT
    DISTINCT pbt.balance_name
INTO p_balance_name
FROM
    pay_balance_types pbt
WHERE
    pbt.input_value_id = p_input_value_id
     AND   ROWNUM < 2;
RETURN
p_balance_name;
EXCEPTION WHEN OTHERS THEN
RETURN NULL ;

END GET_BALANCE_NAME;

--------------------------------------------------------------------------------------
-----------------------------------

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
	l_regular_tax number;
	l_month varchar2(10);
	l_year number;
	l_administrative_code varchar2(50);
	l_information varchar2(50);
    l_Total_Basis_Employer_Tax number(15,2);
    l_Total_Employer_Tax number(15,2);
    l_Tax_Deduction number(15,2);
    l_Deducted_Tax_Pay number(15,2);
    l_declaration_due_date date;
--cursor to check current archive exists

cursor csr_count is
select count(*)
from   pay_action_information
where  action_information_category = 'EMEA REPORT DETAILS'
and    action_information1         = 'PYSETADA'
and    action_context_id           = pactid;

--------------------------------------------------------------------------------
cursor csr_Tax_Decl is
select
ou.Name Organization_Name,
hoi2.org_information2 Organization_Number,
TO_CHAR(TO_DATE(hoi4.org_information1,'MM'),'MONTH') Month,
hoi4.org_information2 Year,
nvl(pay_balance_pkg.get_value(get_defined_balance_id
        ('Gross Pay','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Gross_Pay,
nvl(pay_balance_pkg.get_value(get_defined_balance_id
        ('Employer Taxable Benefits in Kind','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Benefit,
--hoi4.org_information3 Reduction,
nvl(pay_balance_pkg.get_value(get_defined_balance_id
        ('Cost Reduction','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Reduction,
nvl(pay_balance_pkg.get_value(get_defined_balance_id
        ('Regular Employer Taxable Base','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Regular_Taxable_Base,
nvl(pay_balance_pkg.get_value(get_defined_balance_id
        ('Regular Employer Tax','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Regular_Tax,
nvl(pay_balance_pkg.get_value(get_defined_balance_id
        ('Special Taxation Age 65 Taxable Base','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Special_65_Taxable_Base,
nvl(pay_balance_pkg.get_value(get_defined_balance_id
        ('Special Taxation Age 65 Tax','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Special_65_Tax,
nvl(pay_balance_pkg.get_value(get_defined_balance_id
        ('Special Taxation Year 1937 Taxable Base','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Special_1937_Taxable_Base,
nvl(pay_balance_pkg.get_value(pay_se_tax_decl.get_defined_balance_id
        ('Special Taxation Year 1937 Tax','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Special_1937_Tax,
nvl(pay_balance_pkg.get_value(pay_se_tax_decl.get_defined_balance_id
        ('Foreigners Below 65 Employer Taxable Base','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Comp_Without_Lu,
nvl(pay_balance_pkg.get_value(pay_se_tax_decl.get_defined_balance_id
        ('Foreigners Below 65 Employer Tax','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Comp_Without_Lu_29,
nvl(pay_balance_pkg.get_value(pay_se_tax_decl.get_defined_balance_id
        ('Foreigners Below 25 Employer Taxable Base','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Comp_Without_Lu_25_Below,
nvl(pay_balance_pkg.get_value(pay_se_tax_decl.get_defined_balance_id
        ('Foreigners Below 25 Employer Tax','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Comp_Without_Lu_29_25_below,
	nvl(pay_balance_pkg.get_value(pay_se_tax_decl.get_defined_balance_id
        ('Foreigners Above 65 Employer Taxable Base','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Comp_Without_Lu_65_above,
nvl(pay_balance_pkg.get_value(pay_se_tax_decl.get_defined_balance_id
        ('Foreigners Above 65 Employer Tax','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Comp_Without_Lu_29_65_above,
nvl(pay_balance_pkg.get_value(pay_se_tax_decl.get_defined_balance_id
        ('Special Taxation Age 25 below Taxable Base','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Special_25_below_Taxable_Base,
nvl(pay_balance_pkg.get_value(pay_se_tax_decl.get_defined_balance_id
        ('Special Taxation Age 25 below Tax','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Special_25_below_Tax,
nvl(hoi4.org_information4,0) Certain_Insurances,
nvl(hoi4.org_information5,0) Certain_Insurances_29,
nvl(hoi4.org_information6,0) Code,
nvl(hoi4.org_information7,0) Canada,
--
nvl(hoi4.org_information8,0) Special_Canada,
-- nvl(hoi4.org_information9,0) Comp_Support,      --EOY 2008
-- nvl(hoi4.org_information10,0) Comp_Support_5,   --EOY 2008
nvl(hoi4.org_information11,0) Ext_Comp_Support,
nvl(hoi4.org_information12,0) Ext_Comp_Support_10,
--
nvl(pay_balance_pkg.get_value(get_defined_balance_id
        ('Taxable Base','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0)
Taxable_Base,
nvl(pay_balance_pkg.get_value(get_defined_balance_id
        ('Employee Tax','_LE_MONTH'),NULL,l_legal_employer_id,
	NULL,NULL,NULL,l_effective_date),0) Employee_Tax,
nvl(hoi4.org_information13,0) Pension,
nvl(hoi4.org_information14,0) Ded_Pension,
nvl(hoi4.org_information15,0) Interest,
nvl(hoi4.org_information16,0) Ded_Interest,
hoi3.org_information3 Contact,
hoi5.org_information3 Phone
from
hr_organization_units ou,
hr_organization_information hoi1,
hr_organization_information hoi2,
hr_organization_information hoi3,
hr_organization_information hoi4,
hr_organization_information hoi5,
pay_assignment_actions paa,
pay_payroll_actions ppa
where
ou.organization_id=hoi1.organization_id
and hoi1.org_information_context='CLASS'
and hoi1.org_information1='HR_LEGAL_EMPLOYER'
and hoi1.organization_id=hoi2.organization_id
and hoi2.org_information_context='SE_LEGAL_EMPLOYER_DETAILS'
and hoi2.organization_id=hoi3.organization_id
and hoi3.org_information_context='SE_ORG_CONTACT_DETAILS'
and hoi3.org_information1 ='PERSON'
and hoi3.organization_id=hoi4.organization_id
and hoi4.org_information_context='SE_TAX_DECLARATION_DETAILS'
and hoi4.org_information1=l_month
and hoi4.org_information2 =l_year
and hoi4.organization_id=hoi5.organization_id
and hoi5.org_information_context='SE_ORG_CONTACT_DETAILS'
and hoi5.org_information1 ='PHONE'
and hoi5.organization_id=ou.organization_id
and ou.organization_id=l_legal_employer_id;

rg_Tax_Decl csr_Tax_Decl%rowtype;

l_actid			NUMBER;
l_asgid			NUMBER := -999;
--------------------------------------------------------------------------------

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
 PAY_SE_TAX_DECL.GET_ALL_PARAMETERS(
		 pactid
		,l_business_id
		,l_effective_date
		,l_archive
 		,l_legal_employer_id
 		,l_month
		,l_year
		,l_administrative_code
		,l_information
        ,l_declaration_due_date
            ) ;

 -- check if we have to archive again
 IF  (l_archive = 'Y')   THEN

   -- check if record for current archive exists
   OPEN csr_count;
   FETCH csr_count INTO l_count;
   CLOSE csr_count;


   -- archive Report Details only if no record exists
  IF (l_count < 1) THEN
  BEGIN

		pay_balance_pkg.set_context('TAX_UNIT_ID',l_legal_employer_id);

pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(l_effective_date)
);
		pay_balance_pkg.set_context('JURISDICTION_CODE',NULL);
		pay_balance_pkg.set_context('SOURCE_ID',NULL);
		pay_balance_pkg.set_context('TAX_GROUP',NULL);
  END;




OPEN csr_Tax_Decl;
    FETCH csr_Tax_Decl INTO rg_Tax_Decl;
close csr_Tax_Decl;
    l_Total_Basis_Employer_Tax:=rg_Tax_Decl.Gross_Pay +
rg_Tax_Decl.Benefit-rg_Tax_Decl.Reduction;
    l_Total_Employer_Tax:=rg_Tax_Decl.Regular_Tax + rg_Tax_Decl.Special_65_Tax +
rg_Tax_Decl.Special_1937_Tax + rg_Tax_Decl.Comp_Without_Lu_29 +
rg_Tax_Decl.Comp_Without_Lu_29_65_above + rg_Tax_Decl.Comp_Without_Lu_29_25_below +
  rg_Tax_Decl.Special_25_below_Tax +rg_Tax_Decl.Certain_Insurances_29 - rg_Tax_Decl.Ext_Comp_Support_10;
    l_Tax_Deduction:=rg_Tax_Decl.Taxable_Base + rg_Tax_Decl.Pension +
rg_Tax_Decl.Interest;
    l_Deducted_Tax_Pay:=rg_Tax_Decl.Employee_Tax + rg_Tax_Decl.Ded_Pension +
rg_Tax_Decl.Ded_Interest;
-- Archive the REPORT DETAILS


IF ((rg_Tax_Decl.month is not null) and (rg_Tax_Decl.Year is not null) and (rg_Tax_Decl.Gross_Pay>0)) then

	pay_action_information_api.create_action_information (
	 p_action_information_id        => l_action_info_id	-- out parameter
	,p_object_version_number        => l_ovn		-- out parameter
	,p_action_context_id            => pactid		-- context id = payroll action id (of Archive)
	,p_action_context_type          => 'PA'			-- context type
	,p_effective_date               => l_effective_date	-- Date of running the archive
	,p_action_information_category  => 'EMEA REPORT DETAILS' -- Information Category
	,p_tax_unit_id                  => NULL			-- Legal Employer ID
	,p_jurisdiction_code            => NULL			-- Tax Municipality ID
	,p_action_information1          => 'PYSETADA'	-- Conc Prg Short Name
	,p_action_information2          => l_legal_employer_id
	,p_action_information3          => rg_Tax_Decl.organization_name
	,p_action_information4          => rg_Tax_Decl.month
	,p_action_information5          => rg_Tax_Decl.year
	,p_action_information6          => l_administrative_code
	,p_action_information7          => l_information
    ,p_action_information8          => l_declaration_due_date);


	  pay_action_information_api.create_action_information (

	 p_action_information_id        => l_action_info_id		-- out parameter
	,p_object_version_number        => l_ovn			-- out parameter
	,p_action_context_id            => pactid      			-- context id = assignment action id (of Archive)
	,p_action_context_type          => 'PA'				-- context type
	,p_effective_date               => l_effective_date		-- Date of running the archive
	,p_assignment_id		=> NULL			-- Assignment ID
	,p_action_information_category  => 'EMEA REPORT INFORMATION'	-- Information Category
	,p_tax_unit_id                  => l_legal_employer_id    -- Legal Employer ID
	,p_jurisdiction_code            => NULL			-- Tax Municipality ID
	,p_action_information1          => 'PYSETADA'		 --Con Program Short Name
	,p_action_information2          => 'INF'
	,p_action_information3          => rg_Tax_Decl.Organization_Number
	,p_action_information4          => rg_Tax_Decl.Reduction
	,p_action_information7         =>  rg_Tax_Decl.Code
	,p_action_information8         =>  rg_Tax_Decl.Canada
	,p_action_information9         =>  rg_Tax_Decl.Special_Canada
	--  ,p_action_information10        =>  rg_Tax_Decl.Comp_Support         --EOY 2008
	--  ,p_action_information11        =>  rg_Tax_Decl.Comp_Support_5	--EOY 2008
	,p_action_information12        =>  rg_Tax_Decl.Ext_Comp_Support
	,p_action_information13        =>  rg_Tax_Decl.Ext_Comp_Support_10
	,p_action_information14        =>  rg_Tax_Decl.Pension
	,p_action_information15        =>  rg_Tax_Decl.Ded_Pension
	,p_action_information16        =>  rg_Tax_Decl.Interest
	,p_action_information17        =>  rg_Tax_Decl.ded_Interest
	,p_action_information18        =>  rg_Tax_Decl.Contact
	,p_action_information19        =>  rg_Tax_Decl.Phone
	,p_action_information20        =>  rg_Tax_Decl.Certain_Insurances     --EOY 2008
	,p_action_information21        =>  rg_Tax_Decl.Certain_Insurances_29     --EOY 2008



	);


	  pay_action_information_api.create_action_information (

	 p_action_information_id        => l_action_info_id
	,p_object_version_number        => l_ovn
	,p_action_context_id            => pactid
	,p_action_context_type          => 'PA'
	,p_effective_date               => l_effective_date
	,p_assignment_id		=> NULL
	,p_action_information_category  => 'EMEA REPORT INFORMATION'
	,p_tax_unit_id                  => l_legal_employer_id
	,p_jurisdiction_code            => NULL
	,p_action_information1          => 'PYSETADA'
	,p_action_information2          => 'BAL'
	,p_action_information3          => rg_Tax_Decl.Gross_Pay
	,p_action_information4          => rg_Tax_Decl.Benefit
	,p_action_information5          => l_Total_Basis_Employer_Tax
	,p_action_information6          => rg_Tax_Decl.Regular_Taxable_Base
	,p_action_information7          => rg_Tax_Decl.Regular_Tax
	,p_action_information8          => rg_Tax_Decl.Special_65_Taxable_Base
	,p_action_information9          => rg_Tax_Decl.Special_65_Tax
	,p_action_information10         => rg_Tax_Decl.Special_1937_Taxable_Base
	,p_action_information11         => rg_Tax_Decl.Special_1937_Tax
	,p_action_information12         => l_Total_Employer_Tax
	,p_action_information13         => rg_Tax_Decl.Taxable_Base
	,p_action_information14         => rg_Tax_Decl.Employee_Tax
	,p_action_information15         => l_Tax_Deduction
	,p_action_information16         => l_Deducted_Tax_Pay
	,p_action_information17		=> rg_Tax_Decl.Comp_Without_Lu
	,p_action_information18		=> rg_Tax_Decl.Comp_Without_Lu_29
	,p_action_information19		=> rg_Tax_Decl.Comp_Without_Lu_65_above
	,p_action_information20		=> rg_Tax_Decl.Comp_Without_Lu_29_65_above
	,p_action_information21		=> rg_Tax_Decl.Special_25_below_Taxable_Base
	,p_action_information22		=> rg_Tax_Decl.Special_25_below_Tax
	,p_action_information23		=> rg_Tax_Decl.Comp_Without_Lu_25_below
	,p_action_information24		=> rg_Tax_Decl.Comp_Without_Lu_29_25_below

);


END IF;

   END IF;
----------------------------------------------------------



END IF;
---------------------------------------------------------------------------

IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);
 END IF;

 END RANGE_CODE;

--------------------------------------------------------------------------------------
-----------------------------------
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
      hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In
INITIALIZATION_CODE',180);
END IF;

 END INITIALIZATION_CODE;

--------------------------------------------------------------------------------------
----------
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

--------------------------------------------------------------------------------------
----------
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

END PAY_SE_TAX_DECL;

/
