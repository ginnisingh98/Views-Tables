--------------------------------------------------------
--  DDL for Package Body PAY_NO_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_RULES" as
/* $Header: pynorule.pkb 120.13.12010000.5 2009/08/11 09:43:44 vijranga ship $ */
-----------------------------------------------------------------------------
-- GET_MAIN_TAX_UNIT_ID  fetches the Legal Employer Id of the Local Unit
-- of the Assignment Id
-----------------------------------------------------------------------------
PROCEDURE get_main_tax_unit_id
  (p_assignment_id                 IN     NUMBER
  ,p_effective_date                IN     DATE
  ,p_tax_unit_id                   OUT NOCOPY NUMBER ) IS
	l_local_unit_id  hr_soft_coding_keyflex.SEGMENT2%TYPE        ;
	l_business_group_id  per_all_assignments_f.business_group_id%TYPE        ;
	CURSOR c_local_unit_id IS
	SELECT SCL.segment2 , business_group_id
	FROM
	per_all_assignments_f   PAA   ,
	hr_soft_coding_keyflex          SCL
	WHERE ASSIGNMENT_ID = p_assignment_id
	AND PAA.soft_coding_keyflex_id = SCL.soft_coding_keyflex_id
	AND p_effective_date BETWEEN PAA.effective_start_date AND PAA.effective_end_date  ;
	CURSOR c_tax_unit_id (p_business_group_id NUMBER , p_organization_id NUMBER) IS
	SELECT hoi3.organization_id
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	, hr_organization_information hoi3
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id = p_organization_id
	AND hoi1.org_information1 = 'NO_LOCAL_UNIT'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id = hoi2.org_information1
	AND hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
	AND hoi2.organization_id =  hoi3.organization_id
	AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER' ;
 BEGIN
	  OPEN c_local_unit_id ;
	  FETCH c_local_unit_id INTO l_local_unit_id , l_business_group_id ;
	  CLOSE c_local_unit_id ;
	  OPEN c_tax_unit_id (l_business_group_id , l_local_unit_id);
	  FETCH c_tax_unit_id INTO p_tax_unit_id ;
	  CLOSE c_tax_unit_id;
 EXCEPTION
	WHEN others THEN
	p_tax_unit_id := NULL;
 END get_main_tax_unit_id;
 --
 -------------------------------------------------------------------------------
/*
 PROCEDURE get_source_text_context(p_asg_act_id  NUMBER
                                  ,p_ee_id       NUMBER
                                  ,p_source_text IN OUT NOCOPY VARCHAR2) IS
     --
    CURSOR csr_get_tax_municipality (p_assignment_action_id NUMBER) IS
    SELECT distinct eev.screen_entry_value Tax_Municipality
    FROM   pay_element_entries_f pee
          ,pay_element_entry_values_f eev
          ,pay_input_values_f piv
          ,pay_element_types_f pet
          ,per_all_assignments_f paaf
          ,pay_assignment_actions paa
          ,pay_payroll_actions    ppa
    WHERE  paa.assignment_action_id = p_assignment_action_id
    AND    ppa.payroll_action_id    = paa.payroll_action_id
    AND    pee.element_entry_id     = eev.element_entry_id
    AND    eev.input_value_id + 0   = piv.input_value_id
    AND    piv.name                 = 'Tax Municipality'
    AND    piv.element_type_id      = pet.element_type_id
    AND    ppa.effective_date       BETWEEN piv.effective_start_date
                                    AND     piv.effective_end_date
    AND    pee.assignment_id        = paa.assignment_id
    AND    pet.element_name         = 'Tax Card'
    AND    pet.legislation_code     = 'NO'
    AND    ppa.effective_date       BETWEEN pee.effective_start_date
                                    AND     pee.effective_end_date
    AND    ppa.effective_date       BETWEEN eev.effective_start_date
                                    AND     eev.effective_end_date
    AND    ppa.effective_date       BETWEEN pet.effective_start_date
                                    AND     pet.effective_end_date
    AND    ppa.effective_date       BETWEEN paaf.effective_start_date
                                    AND     paaf.effective_end_date;
     l_tax_municipality VARCHAR2(80);
 BEGIN
     --
     l_tax_municipality := null;
     --
     hr_utility.set_location('pay_no_rules.get_source_text_context',1);
     --
     OPEN  csr_get_tax_municipality(p_asg_act_id);
     FETCH csr_get_tax_municipality INTO l_tax_municipality;
     CLOSE csr_get_tax_municipality;
     --
     p_source_text := NVL(l_tax_municipality,' ');
     --
     hr_utility.set_location('pay_no_rules.get_source_text_context='|| p_source_text,2);
     --
 END get_source_text_context;
*/

-------------------------------------------------------------------------------
-- Procedure : get_third_party_org_context
-- It fetches the third party context of the Assignment Id.
-----------------------------------------------------------------------------
PROCEDURE get_third_party_org_context
(p_asg_act_id           IN     NUMBER
,p_ee_id                IN     NUMBER
,p_third_party_id       IN OUT NOCOPY NUMBER )
IS
        l_element_name PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE;
        CURSOR get_element_name(p_ee_id NUMBER) IS
        -- bug#8752864 fix starts
		SELECT petf.element_name
        FROM   pay_element_types_f petf
             , pay_element_entries_f pee
             , fnd_sessions  fs
        WHERE pee.element_entry_id = p_ee_id
        AND pee.element_type_id = petf.element_type_id
		AND fs.session_id = USERENV('sessionid')
		AND fs.effective_date BETWEEN petf.effective_start_date AND petf.effective_end_date
		AND fs.effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date;
        -- bug#8752864 fix ends

	CURSOR get_details_support_order(p_asg_act_id NUMBER ) IS
	SELECT eev1.screen_entry_value  screen_entry_value
	FROM   per_all_assignments_f      asg1
	,per_all_assignments_f      asg2
	,per_all_people_f           per
	,pay_element_links_f        el
	,pay_element_types_f       et
	,pay_input_values_f         iv1
	,pay_element_entries_f      ee
	,pay_element_entry_values_f eev1
	,pay_assignment_actions   pac
	,fnd_sessions		fs
	,pay_input_values_f_tl ivtl
	WHERE  per.person_id      = asg1.person_id
	AND  asg2.person_id        = per.person_id
	AND  asg2.primary_flag     = 'Y'
	AND  et.element_name       = 'Wage Attachment Support Order'
	AND  et.legislation_code   = 'NO'
	AND  iv1.element_type_id   = et.element_type_id
-- BUG fix 4777716
/*start-conditions added for performance tuning*/
	AND fs.session_id = USERENV('sessionid')

	AND  fs.effective_date BETWEEN per.effective_start_date AND per.effective_end_date
	AND  fs.effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
	AND  fs.effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
	AND  fs.effective_date BETWEEN el.effective_start_date AND el.effective_end_date
	AND  fs.effective_date BETWEEN  ee.effective_start_date AND  ee.effective_end_date

	AND iv1.input_value_id = ivtl.input_value_id
	AND ivtl.language = USERENV('LANG')
	AND  fs.effective_date BETWEEN  iv1.effective_start_date AND iv1.effective_end_date

	AND  fs.effective_date BETWEEN  eev1.effective_start_date AND  eev1.effective_end_date
/*End-conditions added for performance tuning*/

	-- Modified for bug fix 4372257
	AND  iv1.name              = 'Third Party Payee'
	AND  el.business_group_id  = per.business_group_id
	AND  el.element_type_id    = et.element_type_id
	AND  ee.assignment_id      = asg2.assignment_id
	AND  ee.element_link_id    = el.element_link_id
	AND  eev1.element_entry_id = ee.element_entry_id
	AND  eev1.input_value_id   = iv1.input_value_id
	AND  pac.assignment_action_id = p_asg_act_id
	AND  asg1.assignment_id = pac.assignment_id;

  	CURSOR get_details_tax_levy(p_asg_act_id NUMBER ) IS
	SELECT eev1.screen_entry_value  screen_entry_value
	FROM   per_all_assignments_f      asg1
	,per_all_assignments_f      asg2
	,per_all_people_f           per
	,pay_element_links_f        el
	,pay_element_types_f       et
	,pay_input_values_f         iv1
	,pay_element_entries_f      ee
	,pay_element_entry_values_f eev1
	,pay_assignment_actions   pac
	,fnd_sessions		fs
	,pay_input_values_f_tl ivtl
	WHERE  per.person_id      = asg1.person_id
	AND  asg2.person_id        = per.person_id
	AND  asg2.primary_flag     = 'Y'
	AND  et.element_name       = 'Wage Attachment Tax Levy'
	AND  et.legislation_code   = 'NO'
	AND  iv1.element_type_id   = et.element_type_id

-- BUG fix 4777716
/*start-conditions added for performance tuning*/
	AND fs.session_id = USERENV('sessionid')

	AND  fs.effective_date BETWEEN per.effective_start_date AND per.effective_end_date
	AND  fs.effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
	AND  fs.effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
	AND  fs.effective_date BETWEEN el.effective_start_date AND el.effective_end_date
	AND  fs.effective_date BETWEEN  ee.effective_start_date AND  ee.effective_end_date

	AND iv1.input_value_id = ivtl.input_value_id
	AND ivtl.language = USERENV('LANG')
	AND  fs.effective_date BETWEEN  iv1.effective_start_date AND iv1.effective_end_date

	AND  fs.effective_date BETWEEN  eev1.effective_start_date AND  eev1.effective_end_date
/*End-conditions added for performance tuning*/

	-- Modified for bug fix 4372257
	AND  iv1.name              = 'Third Party Payee'
	AND  el.business_group_id  = per.business_group_id
	AND  el.element_type_id    = et.element_type_id
	AND  ee.assignment_id      = asg2.assignment_id
	AND  ee.element_link_id    = el.element_link_id
	AND  eev1.element_entry_id = ee.element_entry_id
	AND  eev1.input_value_id   = iv1.input_value_id
	AND  pac.assignment_action_id = p_asg_act_id
	AND  asg1.assignment_id = pac.assignment_id;

	--Added for bug fix 4372257
	CURSOR get_details_union_dues(p_asg_act_id NUMBER ) IS
	SELECT eev1.screen_entry_value  screen_entry_value
	FROM   per_all_assignments_f      asg1
	,per_all_assignments_f      asg2
	,per_all_people_f           per
	,pay_element_links_f        el
	,pay_element_types_f       et
	,pay_input_values_f         iv1
	,pay_element_entries_f      ee
	,pay_element_entry_values_f eev1
	,pay_assignment_actions   pac
	,fnd_sessions		fs
	,pay_input_values_f_tl ivtl
	WHERE  per.person_id      = asg1.person_id
	AND  asg2.person_id        = per.person_id
	AND  asg2.primary_flag     = 'Y'
	AND  et.element_name       = 'Union Dues'
	AND  et.legislation_code   = 'NO'
	AND  iv1.element_type_id   = et.element_type_id

-- BUG fix 4777716
/*start-conditions added for performance tuning*/
	AND fs.session_id = USERENV('sessionid')

	AND  fs.effective_date BETWEEN per.effective_start_date AND per.effective_end_date
	AND  fs.effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
	AND  fs.effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
	AND  fs.effective_date BETWEEN el.effective_start_date AND el.effective_end_date
	AND  fs.effective_date BETWEEN  ee.effective_start_date AND  ee.effective_end_date

	AND iv1.input_value_id = ivtl.input_value_id
	AND ivtl.language = USERENV('LANG')
	AND  fs.effective_date BETWEEN  iv1.effective_start_date AND iv1.effective_end_date

	AND  fs.effective_date BETWEEN  eev1.effective_start_date AND  eev1.effective_end_date
/*End-conditions added for performance tuning*/
	AND  iv1.name              = 'Third Party Payee'
	AND  el.business_group_id  = per.business_group_id
	AND  el.element_type_id    = et.element_type_id
	AND  ee.assignment_id      = asg2.assignment_id
	AND  ee.element_link_id    = el.element_link_id
	AND  eev1.element_entry_id = ee.element_entry_id
	AND  eev1.input_value_id   = iv1.input_value_id
	AND  pac.assignment_action_id = p_asg_act_id
	AND  asg1.assignment_id = pac.assignment_id;

	CURSOR get_details_pension_element(p_asg_act_id NUMBER,p_element_name VARCHAR2 ) IS
	SELECT eev1.screen_entry_value  screen_entry_value
	FROM   per_all_assignments_f      asg1
	,per_all_assignments_f      asg2
	,per_all_people_f           per
	,pay_element_links_f        el
	,pay_element_types_f       et
	,pay_input_values_f         iv1
	,pay_element_entries_f      ee
	,pay_element_entry_values_f eev1
	,pay_assignment_actions   pac
	,fnd_sessions		fs
	,pay_input_values_f_tl ivtl
	WHERE  per.person_id      = asg1.person_id
	AND  asg2.person_id        = per.person_id
	AND  asg2.primary_flag     = 'Y'
	AND  et.element_name       = p_element_name
	AND  et.legislation_code   = 'NO'
	AND  iv1.element_type_id   = et.element_type_id
	AND fs.session_id = USERENV('sessionid')
	AND  fs.effective_date BETWEEN per.effective_start_date AND per.effective_end_date
	AND  fs.effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
	AND  fs.effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
	AND  fs.effective_date BETWEEN el.effective_start_date AND el.effective_end_date
	AND  fs.effective_date BETWEEN  ee.effective_start_date AND  ee.effective_end_date
	AND iv1.input_value_id = ivtl.input_value_id
	AND ivtl.language = USERENV('LANG')
	AND  fs.effective_date BETWEEN  iv1.effective_start_date AND iv1.effective_end_date
	AND  fs.effective_date BETWEEN  eev1.effective_start_date AND  eev1.effective_end_date
	AND  iv1.name              = 'Third Party Payee'
	AND  el.business_group_id  = per.business_group_id
	AND  el.element_type_id    = et.element_type_id
	AND  ee.assignment_id      = asg2.assignment_id
	AND  ee.element_link_id    = el.element_link_id
	AND  eev1.element_entry_id = ee.element_entry_id
	AND  eev1.input_value_id   = iv1.input_value_id
	AND  pac.assignment_action_id = p_asg_act_id
	AND  asg1.assignment_id = pac.assignment_id;
BEGIN
        OPEN get_element_name(p_ee_id);
        FETCH get_element_name INTO l_element_name;
        CLOSE get_element_name;
	IF l_element_name = 'Wage Attachment Support Order' THEN
		OPEN get_details_support_order(p_asg_act_id );
		FETCH get_details_support_order INTO p_third_party_id;
		CLOSE get_details_support_order;
	ELSIF l_element_name = 'Wage Attachment Tax Levy' THEN
		OPEN get_details_tax_levy(p_asg_act_id );
		FETCH get_details_tax_levy INTO p_third_party_id;
		CLOSE get_details_tax_levy;

	-- Added for bug fix 4372257
	ELSIF l_element_name = 'Union Dues' THEN
		OPEN get_details_union_dues(p_asg_act_id );
		FETCH get_details_union_dues INTO p_third_party_id;
		CLOSE get_details_union_dues;
    	END IF;
	IF l_element_name IN ('Pension Insurance Employees Details',
                              'Pension Insurance Employers Details',
                              'Pension Insurance Fixed Employees Details',
                              'Pension Insurance Fixed Employers Details',
                              'Pension Insurance Premium Employers',
                              'Supplemental Collective Life Annuity Employees Details',
                              'Supplemental Collective Life Annuity Employers Details',
                              'Supplemental Collective Life Annuity Premium Employers',
                              'Agreement Based Pension Details',
                              'Agreement Based Pension Premium',
                              'Individual Pension Scheme Details',
                              'Individual Pension Scheme Premium')THEN
		OPEN get_details_pension_element(p_asg_act_id,l_element_name );
		FETCH get_details_pension_element INTO p_third_party_id;
		CLOSE get_details_pension_element;
        End if;
        IF p_third_party_id IS NULL THEN
                p_third_party_id := -999;
        END IF;
EXCEPTION
        WHEN others THEN
        NULL;
END get_third_party_org_context;
-----------------------------------------------------------------------------
--
/*
 PROCEDURE get_source_context(p_asg_act_id IN NUMBER,
                                p_ee_id      IN NUMBER,
                                p_source_id  IN OUT NOCOPY VARCHAR2)
   IS
     CURSOR csr_get_local_unit (p_assignment_action_id NUMBER) IS
      select scl.segment2
from hr_soft_coding_keyflex scl,
pay_assignment_actions pac,
per_all_assignments_f ASSIGN,
pay_legislation_rules LEG,
fnd_id_flex_structures     fstruct
Where pac.assignment_action_id = p_assignment_action_id
and pac.assignment_id = ASSIGN.assignment_id
and ASSIGN.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and LEG.rule_type = 'S'
and LEG.rule_mode = scl.id_flex_num
and scl.enabled_flag = 'Y'
and LEG.legislation_code = 'NO'
and fstruct.id_flex_num		= leg.rule_mode
AND    fstruct.id_flex_code		= 'SCL'
AND    fstruct.application_id		= 800
AND    fstruct.enabled_flag		= 'Y';
       l_local_unit VARCHAR2(80);
   BEGIN
       --
       l_local_unit:= null;
       --
       hr_utility.set_location('pay_no_rules.get_source_context',1);
       --
       OPEN  csr_get_local_unit(p_asg_act_id);
       FETCH csr_get_local_unit INTO l_local_unit;
       CLOSE csr_get_local_unit;
       --
       p_source_id := NVL(l_local_unit,' ');
       --
       hr_utility.set_location('pay_no_rules.get_source_context='|| p_source_id,2);
       --
END get_source_context;
--
*/
------------------------------------------------------------------------------------------
 PROCEDURE get_main_local_unit_id(p_assignment_id	IN	 NUMBER,
				p_effective_date	IN	DATE,
				p_local_unit_id		OUT NOCOPY NUMBER)
   IS
CURSOR csr_get_local_unit (p_assignment_id NUMBER) IS
select scl.segment2
from hr_soft_coding_keyflex scl,
per_all_assignments_f ASSIGN,
pay_legislation_rules LEG,
fnd_id_flex_structures     fstruct
Where ASSIGN.assignment_id = p_assignment_id
and p_effective_date between ASSIGN.effective_start_date and ASSIGN.effective_end_date
and ASSIGN.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and LEG.rule_type = 'S'
and LEG.rule_mode = scl.id_flex_num
and scl.enabled_flag = 'Y'
and LEG.legislation_code = 'NO'
and fstruct.id_flex_num		= leg.rule_mode
AND    fstruct.id_flex_code		= 'SCL'
AND    fstruct.application_id		= 800
AND    fstruct.enabled_flag		= 'Y';
       l_local_unit VARCHAR2(80);
   BEGIN
       --
       l_local_unit:= null;
       --
       hr_utility.set_location('pay_no_rules.get_main_local_unit_id',1);
       --
       OPEN  csr_get_local_unit(p_assignment_id);
       FETCH csr_get_local_unit INTO l_local_unit;
       CLOSE csr_get_local_unit;
       --
       p_local_unit_id := NVL(l_local_unit,0);
       --
       hr_utility.set_location('pay_no_rules.get_main_local_unit_id='|| p_local_unit_id,2);
       --
END get_main_local_unit_id;
------------------------------------------------------------------------------------------
PROCEDURE get_default_jurisdiction(p_asg_act_id   NUMBER,
                                   p_ee_id        NUMBER,
                                   p_jurisdiction IN OUT NOCOPY VARCHAR2) IS

   -- BUG fix 4474253, commenting the old cursor
   /*
   CURSOR csr_get_tax_municipality (p_assignment_action_id NUMBER) IS
    SELECT distinct eev.screen_entry_value Tax_Municipality
    FROM   pay_element_entries_f pee
          ,pay_element_entry_values_f eev
          ,pay_input_values_f piv
          ,pay_element_types_f pet
          ,per_all_assignments_f paaf
          ,pay_assignment_actions paa
          ,pay_payroll_actions    ppa
    WHERE  paa.assignment_action_id = p_assignment_action_id
    AND    ppa.payroll_action_id    = paa.payroll_action_id
    AND    pee.element_entry_id     = eev.element_entry_id
    AND    eev.input_value_id + 0   = piv.input_value_id
    AND    piv.name                 = 'Tax Municipality'
    AND    piv.element_type_id      = pet.element_type_id
    AND    ppa.effective_date       BETWEEN piv.effective_start_date
                                    AND     piv.effective_end_date
    AND    pee.assignment_id        = paa.assignment_id
    AND    pet.element_name         = 'Tax Card'
    AND    pet.legislation_code     = 'NO'
    AND    ppa.effective_date       BETWEEN pee.effective_start_date
                                    AND     pee.effective_end_date
    AND    ppa.effective_date       BETWEEN eev.effective_start_date
                                    AND     eev.effective_end_date
    AND    ppa.effective_date       BETWEEN pet.effective_start_date
                                    AND     pet.effective_end_date
    AND    ppa.effective_date       BETWEEN paaf.effective_start_date
                                    AND     paaf.effective_end_date;
   */

   -- BUG fix 4474253, new cursor
   -- cursor to get the Primary Assignment ID for the given assignment action id

    CURSOR csr_get_prim_asg_id (p_assignment_action_id NUMBER) IS
    SELECT asg2.assignment_id
          ,assact.payroll_action_id
    FROM   per_all_assignments_f	asg1
          ,per_all_assignments_f	asg2
          ,pay_assignment_actions	assact
    	  ,per_all_people_f		pap
	  ,pay_payroll_actions		ppa
    WHERE assact.assignment_action_id =  p_assignment_action_id
    AND	  asg1.assignment_id = assact.assignment_id
    AND	  pap.person_id	= asg1.person_id
    AND	  asg2.person_id = pap.person_id
    AND   asg2.primary_flag = 'Y'
    AND	  ppa.payroll_action_id = assact.payroll_action_id
    AND   ppa.effective_date   BETWEEN asg1.effective_start_date  AND   asg1.effective_end_date
    AND   ppa.effective_date   BETWEEN pap.effective_start_date   AND   pap.effective_end_date
    AND   ppa.effective_date   BETWEEN asg2.effective_start_date  AND   asg2.effective_end_date;

    -- BUG fix 4474253, new cursor
    -- cursor to get the tax municipality corresponding to the primary assignment id

   CURSOR csr_get_tax_municipality (prim_asg_id	  NUMBER , pay_act_id	NUMBER ) IS
    SELECT distinct eev.screen_entry_value Tax_Municipality
    FROM   pay_element_entries_f	pee
          ,pay_element_entry_values_f	eev
          ,pay_input_values_f		piv
          ,pay_element_types_f		pet
          ,pay_payroll_actions		ppa
    WHERE  ppa.payroll_action_id    = pay_act_id
    AND    pee.element_entry_id     = eev.element_entry_id
    AND    eev.input_value_id + 0   = piv.input_value_id
    AND    piv.name                 = 'Tax Municipality'
    AND    piv.element_type_id      = pet.element_type_id
    AND    ppa.effective_date       BETWEEN piv.effective_start_date AND     piv.effective_end_date
    AND    pee.assignment_id        = prim_asg_id
    AND    pet.element_name         = 'Tax Card'
    AND    pet.legislation_code     = 'NO'
    AND    ppa.effective_date       BETWEEN pee.effective_start_date AND     pee.effective_end_date
    AND    ppa.effective_date       BETWEEN eev.effective_start_date AND     eev.effective_end_date
    AND    ppa.effective_date       BETWEEN pet.effective_start_date AND     pet.effective_end_date;


    -- Legislative changes 2007 : cursor to fetch the payroll action effective date

    CURSOR csr_get_payroll_action_date (p_assignment_action_id NUMBER) IS
    SELECT ppa.effective_date , ppa.payroll_action_id , assact.assignment_id
    FROM  pay_assignment_actions	assact
	  ,pay_payroll_actions		ppa
    WHERE assact.assignment_action_id =  p_assignment_action_id
    AND	  ppa.payroll_action_id = assact.payroll_action_id ;


    -- Legislative changes 2007 : cursor to fetch the Tax Municipality at Local Unit

	CURSOR csr_get_lu_tax_mun (p_assignment_action_id NUMBER) IS
	SELECT ORG_INFORMATION6   lu_tax_mun
	FROM   pay_assignment_actions	assact ,
	       per_all_assignments_f    paa  ,
	       pay_payroll_actions	ppa ,
	       hr_soft_coding_keyflex   scl ,
	       hr_organization_information hoi
	WHERE  assact.assignment_action_id =  p_assignment_action_id
	AND    ppa.payroll_action_id = assact.payroll_action_id
	AND    paa.assignment_id = assact.assignment_id
	AND    ppa.effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date
	AND    paa.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
	AND    hoi.organization_id = scl.segment2
	AND    hoi.org_information_context = 'NO_LOCAL_UNIT_DETAILS' ;

    -- Legislative changes 2007 : cursor to get the tax municipality for Ambulatory operations

   CURSOR csr_get_amb_op_tax_mun (p_asg_id	  NUMBER , pay_act_id	NUMBER ) IS
    SELECT distinct eev.screen_entry_value Tax_Municipality
    FROM   pay_element_entries_f	pee
          ,pay_element_entry_values_f	eev
          ,pay_input_values_f		piv
          ,pay_element_types_f		pet
          ,pay_payroll_actions		ppa
    WHERE  ppa.payroll_action_id    = pay_act_id
    AND    pee.assignment_id        = p_asg_id
    AND    pet.element_name         = 'Employer Contribution Information'
    AND    pet.legislation_code     = 'NO'
    AND    piv.name                 = 'Tax Municipality'
    AND    pee.element_entry_id     = eev.element_entry_id
    AND    eev.input_value_id + 0   = piv.input_value_id
    AND    piv.element_type_id      = pet.element_type_id
    AND    ppa.effective_date       BETWEEN pee.effective_start_date AND     pee.effective_end_date
    AND    ppa.effective_date       BETWEEN eev.effective_start_date AND     eev.effective_end_date
    AND    ppa.effective_date       BETWEEN piv.effective_start_date AND     piv.effective_end_date
    AND    ppa.effective_date       BETWEEN pet.effective_start_date AND     pet.effective_end_date ;


    -- BUG fix 4474253, new variables
     prim_asg_id	NUMBER;
     pay_act_id		NUMBER;


     l_tax_municipality varchar2(80);

     -- Legislative changes 2007 : New variables added

     l_pay_act_eff_date	 DATE ;
     l_asg_id		 NUMBER ;


 BEGIN
     --
     l_tax_municipality := null;
     --
     hr_utility.set_location('pay_no_rules.get_default_jurisdiction',1);
     --
     -- BUG fix 4474253, commenting old cursor call
     /*
     OPEN  csr_get_tax_municipality(p_asg_act_id);
     FETCH csr_get_tax_municipality INTO l_tax_municipality;
     CLOSE csr_get_tax_municipality;
     */

     -- Legislative changes 2007 : From 2007 onwards, the Tax Municipality for Jurisdiction code will be fetched from the
     -- the Local Unit of the assignment

     OPEN csr_get_payroll_action_date (p_asg_act_id) ;
     FETCH csr_get_payroll_action_date INTO l_pay_act_eff_date , pay_act_id , l_asg_id ;
     CLOSE csr_get_payroll_action_date ;

     IF (to_number(to_char(l_pay_act_eff_date,'RRRR')) >= 2007)

	THEN

	     OPEN  csr_get_amb_op_tax_mun (l_asg_id , pay_act_id );
	     FETCH csr_get_amb_op_tax_mun INTO l_tax_municipality;
	     CLOSE csr_get_amb_op_tax_mun;

	     IF ( l_tax_municipality IS NULL )
		THEN
			OPEN  csr_get_lu_tax_mun ( p_asg_act_id );
			FETCH csr_get_lu_tax_mun INTO l_tax_municipality;
			CLOSE csr_get_lu_tax_mun ;
	     END IF ;

	ELSE

	     -- BUG fix 4474253, new cursor call
	     OPEN csr_get_prim_asg_id(p_asg_act_id) ;
	     FETCH csr_get_prim_asg_id INTO prim_asg_id , pay_act_id ;
	     CLOSE csr_get_prim_asg_id;

	     -- BUG fix 4474253, new cursor call
	     OPEN  csr_get_tax_municipality(prim_asg_id	, pay_act_id );
	     FETCH csr_get_tax_municipality INTO l_tax_municipality;
	     CLOSE csr_get_tax_municipality;

	END IF ;

     --
     p_jurisdiction := NVL(l_tax_municipality,' ');

         --
          hr_utility.set_location('pay_no_rules.get_default_jurisdiction='|| p_jurisdiction,2);
          --
 END get_default_jurisdiction;
--
--------------------------------------------------------------------------------
--    Name        : LOAD_XML
--    Description : This Function returns the XML data with the tag names.
--    Parameters  : P_NODE_TYPE       This parameter can take one of these values: -
--                                        1. CS - This signifies that string contained in
--                                                P_NODE parameter is start of container
--                                                node. P_DATA parameter is ignored in this
--                                                mode.
--                                        2. CE - This signifies that string contained in
--                                                P_NODE parameter is end of container
--                                                node. P_DATA parameter is ignored in this
--                                                mode.
--                                        3. D  - This signifies that string contained in
--                                                P_NODE parameter is data node and P_DATA
--                                                carries actual data to be contained by
--                                                tag specified by P_NODE parameter.
--
--                  P_CONTEXT_CODE    Context code of Action Information DF.
--
--                  P_NODE            Name of XML tag, or, application column name of flex segment.
--
--                  P_DATA            Data to be contained by tag specified by P_NODE parameter.
--                                    P_DATA is not used unless P_NODE_TYPE = D.
--------------------------------------------------------------------------------
--
FUNCTION load_xml  (p_node_type     VARCHAR2,
                    p_context_code  VARCHAR2,
                    p_node          VARCHAR2,
                    p_data          VARCHAR2) RETURN VARCHAR2 IS
    --
    CURSOR csr_get_tag_name IS
    SELECT TRANSLATE (UPPER(end_user_column_name), ' /','__') tag_name
    FROM  fnd_descr_flex_col_usage_vl
    WHERE descriptive_flexfield_name    = 'Action Information DF'
    AND   descriptive_flex_context_code = p_context_code
    AND   application_column_name       = UPPER (p_node);
    --
    l_tag_name  VARCHAR2(500);
    l_data      pay_action_information.action_information1%TYPE;
    l_node      pay_action_information.action_information1%TYPE;
    --
BEGIN
    --
    IF p_node_type = 'CS' THEN
        l_node :=  TRANSLATE(p_node, ' /', '__');
        RETURN  '<'||l_node||'>' ;
    ELSIF p_node_type = 'CE' THEN
        l_node :=  TRANSLATE(p_node, ' /', '__');
        RETURN  '</'||l_node||'>';
    ELSIF p_node_type = 'D' THEN
        --
        -- Fetch segment names
        --
        OPEN csr_get_tag_name;
            FETCH csr_get_tag_name INTO l_tag_name;
        CLOSE csr_get_tag_name;
        --
        l_node := nvl( l_tag_name,TRANSLATE(p_node, ' /', '__')) ;
        /* Handle special charaters in data */
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
        --
        RETURN  '<'||l_node||'>'||l_data||'</'||l_node||'>';
    END IF;
    --
END load_xml;


-------------------------------------------------------------------------------
-- flex_seg_enabled
-------------------------------------------------------------------------------
FUNCTION flex_seg_enabled(p_context_code              VARCHAR2,
                          p_application_column_name   VARCHAR2) RETURN BOOLEAN AS
    --
    CURSOR csr_seg_enabled IS
    SELECT 'Y'
    FROM fnd_descr_flex_col_usage_vl
    WHERE descriptive_flexfield_name  LIKE 'Action Information DF'
    AND descriptive_flex_context_code    =  p_context_code
    AND application_column_name       LIKE  p_application_column_name
    AND enabled_flag                     =  'Y';
    --
    l_proc_name varchar2(100);
    l_exists    varchar2(1);
    --
BEGIN
    --
    OPEN csr_seg_enabled;
        FETCH csr_seg_enabled INTO l_exists;
    CLOSE csr_seg_enabled;
    --
    IF l_exists = 'Y' THEN
        RETURN (TRUE);
    ELSE
        RETURN (FALSE);
    END IF;
    --
END flex_seg_enabled;
--

-------------------------------------------------------------------------------
-- add_custom_xml
-------------------------------------------------------------------------------
PROCEDURE add_custom_xml (p_assignment_action_id        NUMBER
                         ,p_action_information_category VARCHAR2
                         ,p_document_type               VARCHAR2) IS

/*
----- cursor to get the element information for earnings and deductions elements ----------------

    CURSOR csr_element_info(p_action_context_id   NUMBER
                           ,p_pa_category         VARCHAR2
                           ,p_aap_category        VARCHAR2) IS
	SELECT pai.action_information2 element_type_id
		  ,pai.action_information3 input_value_id
		  ,decode(pai1.action_information8,NULL,pai.action_information4,
		  		    pai.action_information4||'('||pai1.action_information8||')') Name
		  ,pai.action_information5 type
		  ,pai.action_information6 uom
		  --,pai1.action_information8 record_count
		  --,sum(pai1.action_information4) value
		  ,pai1.action_information4 value
	FROM pay_action_information pai
		,pay_action_information pai1
		,pay_assignment_actions paa
	WHERE pai.action_context_type = 'PA'
	AND pai.action_information_category = p_pa_category
	AND pai1.action_context_type = 'AAP'
	AND pai.action_information5 <> 'F'
	AND pai1.action_information3 <> 'F'
	AND ( pai1.action_context_id  in ( SELECT paa.assignment_action_id
					   FROM pay_assignment_actions paa
					   WHERE paa.source_action_id = p_action_context_id
					   AND paa.assignment_id 	  = pai1.assignment_id
					 )
		 OR pai1.action_context_id = 	p_action_context_id)
	and pai1.action_information_category = p_aap_category
	and pai.action_information2 = pai1.action_information1
	and pai.action_information3 = pai1.action_information2 -- This condition is not there for balances
	and pai.action_context_id    = paa.payroll_action_id
	and pai1.action_context_id   = paa.assignment_action_id
    group by pai.action_information2
            ,pai.action_information3
            ,pai.action_information4
            ,pai.action_information5
            ,pai.action_information6
            ,pai1.action_information8
            ,pai1.action_information4
    ORDER BY pai.action_information5,pai1.action_information8 DESC;

*/

----- cursor to get the element information for main elements ----------------

    CURSOR csr_element_info(p_action_context_id   NUMBER
                           ,p_pa_category         VARCHAR2
                           ,p_aap_category        VARCHAR2) IS
	SELECT pai.action_information2 element_type_id
		  ,pai.action_information3 input_value_id
		  ,decode(pai1.action_information8,NULL,pai.action_information4,
		  		    pai.action_information4||'('||pai1.action_information8||')') Name
		  ,pai.action_information5 type
		  ,pai.action_information6 uom
		  --,pai1.action_information8 record_count
		  --,sum(pai1.action_information4) value
		  ,pai1.action_information4 value
		  ,pai1.action_information13 element_code
		  ,pai1.action_information14 payslip_info
		  ,pai1.action_information12 bal_val_ytd
		  ,pai.action_information10  hol_basis_text
		  ,pai.action_information11  tax_basis_text
		  ,pai.action_information12  ele_class
	FROM pay_action_information pai
		,pay_action_information pai1
		,pay_assignment_actions paa
	WHERE pai.action_context_type = 'PA'
	AND pai.action_information_category = p_pa_category
	AND pai1.action_context_type = 'AAP'
	AND pai.action_information5 <> 'F'
	AND pai1.action_information3 <> 'F'
        -- Tuned Cursors FOR Bug - 8345827
	/*AND ( pai1.action_context_id  in ( SELECT paa.assignment_action_id
					   FROM pay_assignment_actions paa
					   WHERE paa.source_action_id = p_action_context_id
					   AND paa.assignment_id 	  = pai1.assignment_id
					 )
		 OR pai1.action_context_id = 	p_action_context_id)*/
	and pai1.action_information_category = p_aap_category
	and pai.action_information2 = pai1.action_information1
	and pai.action_information3 = pai1.action_information2 -- This condition is not there for balances
	and pai.action_context_id    = paa.payroll_action_id
	and pai1.action_context_id   = paa.assignment_action_id
	and paa.assignment_action_id = p_action_context_id  -- New Added
       -- ORDER BY pai.action_information5,pai1.action_information8 DESC; -- Tuned Cursor FOR Bug - 8345827
       ORDER BY pai.action_information5 DESC,fnd_number.canonical_to_number(pai1.action_information8); -- Added FOR Bug - 8345827

/*
----- cursor to get the element information for additional elements ----------------

    CURSOR csr_add_element_info(p_action_context_id   NUMBER
                           ,p_pa_category         VARCHAR2
                           ,p_aap_category        VARCHAR2) IS
	SELECT pai.action_information2 element_type_id
		  ,pai.action_information3 input_value_id
		  ,decode(pai1.action_information8,NULL,pai.action_information4,
		  		    pai.action_information4||'('||pai1.action_information8||')') Name
		  ,pai.action_information5 type
		  ,pai.action_information6 uom
		  --,pai1.action_information8 record_count
		  --,sum(pai1.action_information4) value
		  ,pai1.action_information4 value
	FROM pay_action_information pai
		,pay_action_information pai1
		,pay_assignment_actions paa
	WHERE pai.action_context_type = 'PA'
	AND pai.action_information_category = p_pa_category
	AND pai1.action_context_type = 'AAP'
	AND pai.action_information5 = 'F'
	AND pai1.action_information3 = 'F'
	AND ( pai1.action_context_id  in ( SELECT paa.assignment_action_id
                                           FROM pay_assignment_actions paa
					   WHERE paa.source_action_id = p_action_context_id
					   AND paa.assignment_id 	  = pai1.assignment_id
					  )
		 OR pai1.action_context_id = 	p_action_context_id)
	and pai1.action_information_category = p_aap_category
	and pai.action_information2 = pai1.action_information1
	and pai.action_information3 = pai1.action_information2 -- This condition is not there for balances
	and pai.action_context_id    = paa.payroll_action_id
	and pai1.action_context_id   = paa.assignment_action_id
    group by pai.action_information2
            ,pai.action_information3
            ,pai.action_information4
            ,pai.action_information5
            ,pai.action_information6
	    ,pai1.action_information4
            ,pai1.action_information8
    ORDER BY pai.action_information5,pai1.action_information8 DESC;

*/

----- cursor to get the element information for additional elements ----------------

    CURSOR csr_add_element_info(p_action_context_id   NUMBER
                           ,p_pa_category         VARCHAR2
                           ,p_aap_category        VARCHAR2) IS
	SELECT pai.action_information2 element_type_id
		  ,pai.action_information3 input_value_id
		  ,decode(pai1.action_information8,NULL,pai.action_information4,
		  		    pai.action_information4||'('||pai1.action_information8||')') Name
		  ,pai.action_information5 type
		  ,pai.action_information6 uom
		  --,pai1.action_information8 record_count
		  --,sum(pai1.action_information4) value
		  ,pai1.action_information4 value
  		  ,pai1.action_information13 element_code
		  ,pai1.action_information14 payslip_info
		  ,pai1.action_information12 bal_val_ytd
		  ,pai.action_information10  hol_basis_text
		  ,pai.action_information11  tax_basis_text
		  ,pai.action_information12  ele_class
	FROM pay_action_information pai
		,pay_action_information pai1
		,pay_assignment_actions paa
	WHERE pai.action_context_type = 'PA'
	AND pai.action_information_category = p_pa_category
	AND pai1.action_context_type = 'AAP'
	AND pai.action_information5 = 'F'
	AND pai1.action_information3 = 'F'
	-- Tuned Cursor FOR Bug - 8345827
	/* AND ( pai1.action_context_id  in ( SELECT paa.assignment_action_id
                                           FROM pay_assignment_actions paa
					   WHERE paa.source_action_id = p_action_context_id
					   AND paa.assignment_id 	  = pai1.assignment_id
					  )
		 OR pai1.action_context_id = 	p_action_context_id)*/
	and pai1.action_information_category = p_aap_category
	and pai.action_information2 = pai1.action_information1
	and pai.action_information3 = pai1.action_information2 -- This condition is not there for balances
	and pai.action_context_id    = paa.payroll_action_id
	and pai1.action_context_id   = paa.assignment_action_id
	and paa.assignment_action_id = p_action_context_id
    --ORDER BY pai.action_information5,pai1.action_information8 DESC; Changed to below -- Tuned Cursor FOR Bug - 8345827
    ORDER BY pai.action_information5 DESC,fnd_number.canonical_to_number(pai1.action_information8); -- Added  FOR Bug - 8345827


-------- cursor to get the payroll information -----------------------------

	CURSOR csr_payroll_info(p_action_context_id    NUMBER
	                       ,p_category            VARCHAR2
	) IS

    SELECT ppf.payroll_name         payroll_name
	,ptp.period_name     period_name
	,ptp.period_type     period_type
	,ptp.start_date      start_date
	,ptp.end_date         end_date
	--,pai.effective_date  payment_date
	,ptp.default_dd_date  payment_date
	FROM per_time_periods ptp
	,pay_payrolls_f   ppf
	,pay_action_information pai
	WHERE ppf.payroll_id = ptp.payroll_id
	AND pai.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
	AND ptp.time_period_id = pai.action_information16
	AND pai.action_context_type  = 'AAP'
	AND pai.action_information_category  = p_category
	AND pai.action_context_id=p_action_context_id; -- Tuned Cursor FOR Bug - 8345827
        -- Removed the query below for Bug 8345827
	/* AND (pai.action_context_id    =  p_action_context_id
	OR pai.action_context_id = ( SELECT paa.source_action_id
	                             FROM   pay_assignment_actions paa
                                 WHERE paa.assignment_action_id =  p_action_context_id
                             	 AND   paa.assignment_id       =  pai.Assignment_ID
	)); */

---------------

    -- l_total_earnings    NUMBER := 0;
    -- l_total_deductions  NUMBER := 0;

    l_total_salary_ptd		NUMBER := 0;
    l_total_oth_rem_ptd		NUMBER := 0;
    l_total_oth_dedn_ptd	NUMBER := 0;
    l_total_with_tax_ptd	NUMBER := 0;

    l_total_salary_ytd		NUMBER := 0;
    l_total_oth_rem_ytd		NUMBER := 0;
    l_total_oth_dedn_ytd	NUMBER := 0;
    l_total_with_tax_ytd	NUMBER := 0;


    l_total_pay         NUMBER;
    cntr_flex_col       NUMBER;
    l_flex_col_num      NUMBER;
    temp                VARCHAR2(100);
    cntr                NUMBER;
    l_uom               VARCHAR2(240);
    l_cntr_sql          NUMBER;
    sqlstr              DBMS_SQL.VARCHAR2S;
    csr                 NUMBER;
    ret                 NUMBER;

---------------

    -- Private Procedure to build dynamic sql

    PROCEDURE build_sql(p_sqlstr_tab    IN OUT NOCOPY DBMS_SQL.VARCHAR2S,
                        p_cntr          IN OUT NOCOPY NUMBER,
                        p_string        VARCHAR2) AS

    l_proc_name varchar2(100);

    BEGIN
        p_sqlstr_tab(p_cntr) := p_string;
        p_cntr               := p_cntr + 1;
    END;

----------------

BEGIN

    --hr_utility.trace_on(null,'no_payslip');
    hr_utility.trace('Entering Pay_NO_RULES.add_custom_xml');
    hr_utility.trace('p_assignment_action_id '|| p_assignment_action_id);
    hr_utility.trace('p_action_information_category '|| p_action_information_category);
    hr_utility.trace('p_document_type '|| p_document_type);


if ( (p_document_type = 'PAYSLIP') AND (p_action_information_category is null) ) then

    hr_utility.trace('doc type is PAYSLIP and category is NULL ');

    -- ELEMENT DETAILS

    hr_utility.trace('ELEMENT DEATILS : start ');

    -- Main Elements

    hr_utility.trace('Main Elements : start ');

    FOR csr_element_info_rec IN csr_element_info (p_assignment_action_id,'NO ELEMENT DEFINITION','NO ELEMENT INFO') LOOP
        --
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CS', NULL, 'ELEMENT DETAILS', NULL) ;
        --

	/*
	IF csr_element_info_rec.type = 'E' THEN
           l_total_earnings := l_total_earnings + csr_element_info_rec.value ;
        END IF ;

        IF csr_element_info_rec.type = 'D' THEN
           l_total_deductions := l_total_deductions + csr_element_info_rec.value ;
        END IF ;

	*/

	/*
	-- Total Salary
	IF csr_element_info_rec.type = 'S' THEN
           l_total_salary_ptd := l_total_salary_ptd + csr_element_info_rec.value ;
           l_total_salary_ytd := l_total_salary_ytd + csr_element_info_rec.bal_val_ytd ;
        END IF ;

	-- Total Othere Remuneration/reimbursements
	IF csr_element_info_rec.type = 'OR' THEN
           l_total_oth_rem_ptd := l_total_oth_rem_ptd + csr_element_info_rec.value ;
           l_total_oth_rem_ytd := l_total_oth_rem_ytd + csr_element_info_rec.bal_val_ytd ;
        END IF ;

	-- Total Other Deductions
	IF csr_element_info_rec.type = 'OD' THEN
           l_total_oth_dedn_ptd := l_total_oth_dedn_ptd + csr_element_info_rec.value ;
           l_total_oth_dedn_ytd := l_total_oth_dedn_ytd + csr_element_info_rec.bal_val_ytd ;
        END IF ;

	-- Total Withholding Tax
	IF csr_element_info_rec.type = 'WT' THEN
           l_total_with_tax_ptd := l_total_with_tax_ptd + csr_element_info_rec.value ;
           l_total_with_tax_ytd := l_total_with_tax_ytd + csr_element_info_rec.bal_val_ytd ;
        END IF ;

	*/

	-- Bug Fix : 5909587, using fnd_number.canonical_to_number before summing up values for payslip.

	IF ( csr_element_info_rec.value IS NOT NULL ) THEN

		IF csr_element_info_rec.type = 'S' THEN  -- Total Salary
		   -- l_total_salary_ptd := l_total_salary_ptd + csr_element_info_rec.value ;
		   l_total_salary_ptd := l_total_salary_ptd + fnd_number.canonical_to_number (csr_element_info_rec.value) ;

		ELSIF csr_element_info_rec.type = 'OR' THEN  -- Total Othere Remuneration/reimbursements
		   -- l_total_oth_rem_ptd := l_total_oth_rem_ptd + csr_element_info_rec.value ;
		   l_total_oth_rem_ptd := l_total_oth_rem_ptd + fnd_number.canonical_to_number (csr_element_info_rec.value) ;

		ELSIF csr_element_info_rec.type = 'OD' THEN  -- Total Other Deductions
		   -- l_total_oth_dedn_ptd := l_total_oth_dedn_ptd + csr_element_info_rec.value ;
		   l_total_oth_dedn_ptd := l_total_oth_dedn_ptd + fnd_number.canonical_to_number (csr_element_info_rec.value) ;

		ELSIF csr_element_info_rec.type = 'WT' THEN  -- Total Withholding Tax
		   -- l_total_with_tax_ptd := l_total_with_tax_ptd + csr_element_info_rec.value ;
		   l_total_with_tax_ptd := l_total_with_tax_ptd + fnd_number.canonical_to_number (csr_element_info_rec.value) ;

		END IF ;

	END IF ;

	IF ( csr_element_info_rec.bal_val_ytd IS NOT NULL ) THEN

		IF csr_element_info_rec.type = 'S' THEN  -- Total Salary
		   -- l_total_salary_ytd := l_total_salary_ytd + csr_element_info_rec.bal_val_ytd ;
		   l_total_salary_ytd := l_total_salary_ytd + fnd_number.canonical_to_number (csr_element_info_rec.bal_val_ytd) ;

		ELSIF csr_element_info_rec.type = 'OR' THEN  -- Total Othere Remuneration/reimbursements
		   -- l_total_oth_rem_ytd := l_total_oth_rem_ytd + csr_element_info_rec.bal_val_ytd ;
		   l_total_oth_rem_ytd := l_total_oth_rem_ytd + fnd_number.canonical_to_number (csr_element_info_rec.bal_val_ytd) ;

		ELSIF csr_element_info_rec.type = 'OD' THEN  -- Total Other Deductions
		   -- l_total_oth_dedn_ytd := l_total_oth_dedn_ytd + csr_element_info_rec.bal_val_ytd ;
		   l_total_oth_dedn_ytd := l_total_oth_dedn_ytd + fnd_number.canonical_to_number (csr_element_info_rec.bal_val_ytd) ;

		ELSIF csr_element_info_rec.type = 'WT' THEN  -- Total Withholding Tax
		   -- l_total_with_tax_ytd := l_total_with_tax_ytd + csr_element_info_rec.bal_val_ytd ;
		   l_total_with_tax_ytd := l_total_with_tax_ytd + fnd_number.canonical_to_number (csr_element_info_rec.bal_val_ytd) ;

		END IF ;

	END IF ;


	--
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION2',csr_element_info_rec.element_type_id );
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION3',csr_element_info_rec.input_value_id );
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION4',csr_element_info_rec.Name);
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION5',csr_element_info_rec.type );

        l_uom := hr_general.decode_lookup('UNITS',csr_element_info_rec.uom);

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION6',l_uom );
        --

        --pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        --  load_xml('D', 'NO ELEMENT INFO', 'ACTION_INFORMATION4',csr_element_info_rec.value );

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT INFO', 'ACTION_INFORMATION4',fnd_number.canonical_to_number(csr_element_info_rec.value) );


	---- new additions

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT INFO', 'ACTION_INFORMATION13',csr_element_info_rec.element_code );

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT INFO', 'ACTION_INFORMATION14',csr_element_info_rec.payslip_info );

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT INFO', 'ACTION_INFORMATION12',fnd_number.canonical_to_number(csr_element_info_rec.bal_val_ytd ));


	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION10',csr_element_info_rec.hol_basis_text );

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION11',csr_element_info_rec.tax_basis_text );

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION12',csr_element_info_rec.ele_class );

	----- end new additions

	--
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CE', NULL, 'ELEMENT DETAILS', NULL);
        --
    END LOOP;
    --    --

    hr_utility.trace('Main Elements : end ');

    -- Additional Elements

    hr_utility.trace('Additional Elements : start ');

    FOR csr_element_info_rec IN csr_add_element_info (p_assignment_action_id,'NO ELEMENT DEFINITION','NO ELEMENT INFO') LOOP
        --
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CS', NULL, 'ELEMENT DETAILS', NULL) ;
        --
	--
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION2',csr_element_info_rec.element_type_id );
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION3',csr_element_info_rec.input_value_id );
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION4',csr_element_info_rec.Name);
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION5',csr_element_info_rec.type );

        l_uom := hr_general.decode_lookup('UNITS',csr_element_info_rec.uom);

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION6',l_uom );
        --

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'NO ELEMENT INFO', 'ACTION_INFORMATION4',csr_element_info_rec.value );

	---- new additions

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT INFO', 'ACTION_INFORMATION13',csr_element_info_rec.element_code );

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT INFO', 'ACTION_INFORMATION14',csr_element_info_rec.payslip_info );

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT INFO', 'ACTION_INFORMATION12',fnd_number.canonical_to_number(csr_element_info_rec.bal_val_ytd ));


	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION10',csr_element_info_rec.hol_basis_text );

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION11',csr_element_info_rec.tax_basis_text );

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
		   load_xml('D', 'NO ELEMENT DEFINITION', 'ACTION_INFORMATION12',csr_element_info_rec.ele_class );

	----- end new additions


	--
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CE', NULL, 'ELEMENT DETAILS', NULL);
        --
    END LOOP;
    --    --


   hr_utility.trace('Additional Elements : end ');

   hr_utility.trace('ELEMENT DEATILS : end ');

    -- PAYROLL PROCESSING INFORMATION

    hr_utility.trace('PAYROLL PROCESSING INFORMATION : start ');


FOR payroll_info_rec IN csr_payroll_info(p_assignment_action_id , 'EMPLOYEE DETAILS' )
	LOOP

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CS', NULL, 'PAYROLL PROCESSING INFORMATION', NULL) ;

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'PAYROLL_NAME',payroll_info_rec.payroll_name );

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'PERIOD_NAME',payroll_info_rec.period_name );

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'PERIOD_TYPE',payroll_info_rec.period_type);

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'START_DATE',payroll_info_rec.start_date );

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'END_DATE',payroll_info_rec.end_date );

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'PAYMENT_DATE',payroll_info_rec.payment_date );
        --
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CE', NULL, 'PAYROLL PROCESSING INFORMATION', NULL);
        --

END LOOP;

   hr_utility.trace('PAYROLL PROCESSING INFORMATION : end ');

    -- SUMMARY OF PAYMENTS

    -- l_total_pay := l_total_earnings - l_total_deductions ;

    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('CS', NULL, 'SUMMARY_OF_PAYMENTS', NULL);
    --
    /*
    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_EARNINGS', fnd_number.canonical_to_number(l_total_earnings) );
    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_DEDUCTIONS', fnd_number.canonical_to_number(l_total_deductions) );
    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_PAY', fnd_number.canonical_to_number(l_total_pay) );

    */

    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_SALARY_PTD', fnd_number.canonical_to_number(l_total_salary_ptd) );

    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_SALARY_YTD', fnd_number.canonical_to_number(l_total_salary_ytd) );



    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_OTH_REM_PTD', fnd_number.canonical_to_number(l_total_oth_rem_ptd) );

    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_OTH_REM_YTD', fnd_number.canonical_to_number(l_total_oth_rem_ytd) );



    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_OTH_DEDN_PTD', fnd_number.canonical_to_number(l_total_oth_dedn_ptd) );

    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_OTH_DEDN_YTD', fnd_number.canonical_to_number(l_total_oth_dedn_ytd) );



    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_WITHHOLDING_TAX_PTD', fnd_number.canonical_to_number(l_total_with_tax_ptd) );

    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_WITHHOLDING_TAX_YTD', fnd_number.canonical_to_number(l_total_with_tax_ytd) );

    --
    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('CE', NULL, 'SUMMARY_OF_PAYMENTS', NULL);
    --
    -- BALANCE DETAILS
    --
    l_cntr_sql      := 1;

    -- new
    build_sql(sqlstr, l_cntr_sql, ' Begin FOR run_types_rec IN pay_no_rules.csr_run_types ('||p_assignment_action_id||') LOOP ');
	build_sql(sqlstr, l_cntr_sql, ' FOR csr_balance_info_rec IN pay_no_rules.csr_balance_info (run_types_rec.assignment_action_id,''EMEA BALANCE DEFINITION'',''EMEA BALANCES'') LOOP ');
    -- end new
    -- build_sql(sqlstr, l_cntr_sql, ' Begin FOR csr_balance_info_rec IN pay_no_rules.csr_balance_info ('||p_assignment_action_id||',''EMEA BALANCE DEFINITION'',''EMEA BALANCES'') LOOP ');
    build_sql(sqlstr, l_cntr_sql, ' pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=  pay_no_rules.load_xml(''CS'', NULL, ''BALANCE DETAILS'', NULL); ');
        FOR cntr in 1..30 LOOP

	    IF pay_no_rules.flex_seg_enabled ('EMEA BALANCE DEFINITION', 'ACTION_INFORMATION'||cntr) THEN
                 build_sql(sqlstr, l_cntr_sql, ' pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
						pay_no_rules.load_xml(''D'', ''EMEA BALANCE DEFINITION'', ''ACTION_INFORMATION'||cntr||''', csr_balance_info_rec.a'||cntr||'); ');
            END IF;

	    IF pay_no_rules.flex_seg_enabled ('EMEA BALANCES', 'ACTION_INFORMATION'||cntr) THEN
                 build_sql(sqlstr, l_cntr_sql, ' pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
						pay_no_rules.load_xml(''D'', ''EMEA BALANCES'', ''ACTION_INFORMATION'||cntr||''', csr_balance_info_rec.aa'||cntr||'); ');
            END IF;

        END LOOP;
    build_sql(sqlstr, l_cntr_sql, ' pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=  pay_no_rules.load_xml(''CE'', NULL, ''BALANCE DETAILS'', NULL); ');
    -- new
    build_sql(sqlstr, l_cntr_sql, ' END LOOP;  ');
    -- end new
    build_sql(sqlstr, l_cntr_sql, ' END LOOP; End; ');
    --
    csr := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(csr
                  ,sqlstr
                  ,sqlstr.first()
                  ,sqlstr.last()
                  ,FALSE
                  ,DBMS_SQL.V7);
    ret := DBMS_SQL.EXECUTE(csr);
    DBMS_SQL.CLOSE_CURSOR(csr);
--
end if;
    --hr_utility.trace_off();

END add_custom_xml;

-----

PROCEDURE get_source_text_context
(p_asg_act_id		IN      NUMBER,
p_ee_id			IN      NUMBER,
p_source_text		IN OUT  NOCOPY VARCHAR2) IS

cursor csr_ssb_codes is
select row_low_range_or_name
from pay_user_tables put,
        pay_user_rows_f pur,
        fnd_sessions fs
where
        put.user_table_name ='NO_SSB_CODE_RULES'
and put.user_table_id = pur.user_table_id
and fs.session_id = userenv('sessionid')
and fs.effective_date between pur.effective_start_date
and pur.effective_end_date
order by row_low_range_or_name;

l_source_text VARCHAR2(150);
BEGIN

hr_utility.set_location('in pay_no_rules',10);

IF pay_no_ssb_codes.g_next_ssb_code IS NULL THEN
    OPEN csr_ssb_codes;
    FETCH csr_ssb_codes INTO l_source_text;
    CLOSE csr_ssb_codes;
ELSE
    l_source_text := pay_no_ssb_codes.g_next_ssb_code;
END IF;

 p_source_text := l_source_text;

END get_source_text_context;


------------------------------------------------------------------------------------------

PROCEDURE get_source_text2_context
(p_asg_act_id		IN		NUMBER
,p_ee_id		IN		NUMBER
,p_source_text2		IN OUT  NOCOPY VARCHAR2)  IS

   -- cursor to get the Primary Assignment ID for the given assignment action id

    CURSOR csr_get_prim_asg_id (p_assignment_action_id NUMBER) IS
    SELECT asg2.assignment_id
          ,assact.payroll_action_id
    FROM   per_all_assignments_f	asg1
          ,per_all_assignments_f	asg2
          ,pay_assignment_actions	assact
    	  ,per_all_people_f		pap
	  ,pay_payroll_actions		ppa
    WHERE assact.assignment_action_id =  p_assignment_action_id
    AND	  asg1.assignment_id = assact.assignment_id
    AND	  pap.person_id	= asg1.person_id
    AND	  asg2.person_id = pap.person_id
    AND   asg2.primary_flag = 'Y'
    AND	  ppa.payroll_action_id = assact.payroll_action_id
    AND   ppa.effective_date   BETWEEN asg1.effective_start_date  AND   asg1.effective_end_date
    AND   ppa.effective_date   BETWEEN pap.effective_start_date   AND   pap.effective_end_date
    AND   ppa.effective_date   BETWEEN asg2.effective_start_date  AND   asg2.effective_end_date;

    -- cursor to get the tax municipality corresponding to the primary assignment id

   CURSOR csr_get_tax_municipality (prim_asg_id	  NUMBER , pay_act_id	NUMBER ) IS
    SELECT distinct eev.screen_entry_value Tax_Municipality
    FROM   pay_element_entries_f	pee
          ,pay_element_entry_values_f	eev
          ,pay_input_values_f		piv
          ,pay_element_types_f		pet
          ,pay_payroll_actions		ppa
    WHERE  ppa.payroll_action_id    = pay_act_id
    AND    pee.element_entry_id     = eev.element_entry_id
    AND    eev.input_value_id + 0   = piv.input_value_id
    AND    piv.name                 = 'Tax Municipality'
    AND    piv.element_type_id      = pet.element_type_id
    AND    ppa.effective_date       BETWEEN piv.effective_start_date AND     piv.effective_end_date
    AND    pee.assignment_id        = prim_asg_id
    AND    pet.element_name         = 'Tax Card'
    AND    pet.legislation_code     = 'NO'
    AND    ppa.effective_date       BETWEEN pee.effective_start_date AND     pee.effective_end_date
    AND    ppa.effective_date       BETWEEN eev.effective_start_date AND     eev.effective_end_date
    AND    ppa.effective_date       BETWEEN pet.effective_start_date AND     pet.effective_end_date;


     prim_asg_id	NUMBER;
     pay_act_id		NUMBER;
     l_tax_municipality VARCHAR2(80);

BEGIN

     --
     l_tax_municipality := null;
     --
     hr_utility.set_location('pay_no_rules.get_source_text2_context',1);
     --

	     OPEN csr_get_prim_asg_id(p_asg_act_id) ;
	     FETCH csr_get_prim_asg_id INTO prim_asg_id , pay_act_id ;
	     CLOSE csr_get_prim_asg_id;

	     OPEN  csr_get_tax_municipality(prim_asg_id	, pay_act_id );
	     FETCH csr_get_tax_municipality INTO l_tax_municipality;
	     CLOSE csr_get_tax_municipality;

     --
     p_source_text2 := NVL(l_tax_municipality,' ');

         --
          hr_utility.set_location('pay_no_rules.get_source_text2_context='|| p_source_text2,2);

EXCEPTION
	WHEN others THEN
	NULL;

END get_source_text2_context;

-------------------------------------------------------------------------------
-- get_payslip_sort_order1
-------------------------------------------------------------------------------
--
FUNCTION get_payslip_sort_order1 RETURN VARCHAR2 IS
  l_bg_id VARCHAR2(20);
  l_sort_flag VARCHAR2(2);
BEGIN
--
  fnd_profile.get('PER_BUSINESS_GROUP_ID',l_bg_id);
  hr_utility.set_location('### get_payslip_sort_order1',1);
  --
  BEGIN
   SELECT org_information1 --Local Unit ID flag
     INTO l_sort_flag
     FROM hr_organization_information
    WHERE organization_id = to_number(l_bg_id)
      AND org_information_context = 'NO_PAYSLIP_SORT_DETAILS'
      AND rownum <= 1;
   EXCEPTION WHEN OTHERS THEN
   l_sort_flag := 'N';
  END;
  --
  hr_utility.set_location('### get_payslip_sort_order1',10);
  --
  IF l_sort_flag = 'Y' THEN
    return 'SEGMENT2'; -- Local Unit ID
  ELSE
    return NULL;
  END IF;
--
END get_payslip_sort_order1;
--
-------------------------------------------------------------------------------
-- get_payslip_sort_order2
-------------------------------------------------------------------------------
--
FUNCTION get_payslip_sort_order2 RETURN VARCHAR2 IS
  l_bg_id VARCHAR2(20);
  l_sort_flag VARCHAR2(2);
BEGIN
--
  fnd_profile.get('PER_BUSINESS_GROUP_ID',l_bg_id);
  hr_utility.set_location('### get_payslip_sort_order2',1);
  --
  BEGIN
   SELECT org_information2 --Org ID flag
     INTO l_sort_flag
     FROM hr_organization_information
    WHERE organization_id = to_number(l_bg_id)
      AND org_information_context = 'NO_PAYSLIP_SORT_DETAILS'
      AND rownum <= 1;
   EXCEPTION WHEN OTHERS THEN
   l_sort_flag := 'N';
  END;
  --
  hr_utility.set_location('### get_payslip_sort_order2',10);
  --
  IF l_sort_flag = 'Y' THEN
    return 'ORGANIZATION_ID';
  ELSE
    return NULL;
  END IF;
--
END get_payslip_sort_order2;
-------------------------------------------------------------------------------
-- get_payslip_sort_order2
-------------------------------------------------------------------------------
--
FUNCTION get_payslip_sort_order3 RETURN VARCHAR2 IS
BEGIN
--
    return 'LAST_NAME'; -- Last Name of person
--
END get_payslip_sort_order3;

END PAY_NO_RULES;

/
