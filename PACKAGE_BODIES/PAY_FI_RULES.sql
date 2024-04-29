--------------------------------------------------------
--  DDL for Package Body PAY_FI_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_RULES" as
/* $Header: pyfirule.pkb 120.12.12000000.2 2007/02/14 06:13:45 dbehera noship $ */

-----------------------------------------------------------------------------
-- GET_MAIN_TAX_UNIT_ID  fetches the Legal Employer Id of the Local Unit
-- of the Assignment Id
-----------------------------------------------------------------------------
       g_custom_context    pay_action_information.action_information_category%type;
       	g_action_ctx_id  NUMBER;

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
	AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id = hoi2.org_information1
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNITS'
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
-----------------------------------------------------------------------------
-- Procedure : get_third_party_org_context
-- It fetches the third party context of the Assignment Id.
-----------------------------------------------------------------------------

PROCEDURE get_third_party_org_context
(p_asg_act_id		IN     NUMBER
,p_ee_id                IN     NUMBER
,p_third_party_id       IN OUT NOCOPY NUMBER )
IS
	l_third_party_id number;
	l_element_name PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE;
	l_local_unit_id  hr_soft_coding_keyflex.SEGMENT2%TYPE        ;
	l_business_group_id  per_all_assignments_f.business_group_id%TYPE        ;
	l_tax_unit_id  hr_organization_units.organization_id%TYPE        ;
        l_pension_group_id hr_organization_information.org_information_id%TYPE;
	l_pension_group hr_organization_information.org_information2%TYPE;
	l_pension_num hr_organization_information.org_information6%TYPE;
	l_pension_provider  hr_organization_units.organization_id%TYPE        ;

	l_effective_date         DATE;


	CURSOR get_element_name(p_ee_id NUMBER , p_effective_date DATE ) IS
	SELECT pet.element_name
	FROM pay_element_types_f pet,
	pay_element_entries_f pee
	WHERE pee.element_entry_id = p_ee_id
	AND pee.element_type_id = pet.element_type_id
	AND  p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
	AND  p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date;


CURSOR get_details(p_asg_act_id NUMBER ) IS
SELECT eev1.screen_entry_value  screen_entry_value
	FROM   per_all_assignments_F      asg1
	,per_all_assignments_F      asg2
	,per_all_people_F           per
	,pay_element_links_f        el
	,pay_element_types_f        et
	,pay_input_values_f         iv1
	,pay_element_entries_F      ee
	,pay_element_entry_values_F eev1
	,pay_assignment_actions   pac
	,pay_payroll_actions ppa
	WHERE  per.person_id      = asg1.person_id
	    AND ppa.BUSINESS_GROUP_ID = per.BUSINESS_GROUP_ID
		and ppa.effective_date BETWEEN per.effective_start_date and per.effective_end_date
   	    AND  asg2.person_id        = per.person_id
   	    and ppa.BUSINESS_GROUP_ID = asg1.BUSINESS_GROUP_ID
        and ppa.BUSINESS_GROUP_ID = asg2.BUSINESS_GROUP_ID
        and ppa.effective_date BETWEEN asg1.effective_start_date and asg1.effective_end_date
        and ppa.effective_date BETWEEN asg2.effective_start_date and asg2.effective_end_date
    	AND  asg2.primary_flag     = 'Y'
    	AND  pac.assignment_action_id = p_asg_act_id
		AND  pac.payroll_action_id   =  ppa.payroll_action_id
	AND  asg1.assignment_id = pac.assignment_id
	   AND  et.element_name       = 'Court Order Information'
	and ppa.effective_date BETWEEN et.effective_start_date and et.effective_end_date
	AND  et.legislation_code   = 'FI'
	AND  iv1.element_type_id   = et.element_type_id
	AND  iv1.name              = 'Magistrate Office'
    and ppa.effective_date BETWEEN iv1.effective_start_date and iv1.effective_end_date
	AND  el.business_group_id  = per.business_group_id
	AND  el.element_type_id    = et.element_type_id
    and ppa.effective_date BETWEEN el.effective_start_date and el.effective_end_date
	AND  ee.assignment_id      = asg2.assignment_id
	AND  ee.element_link_id    = el.element_link_id
	and ppa.effective_date BETWEEN ee.effective_start_date and ee.effective_end_date
	AND  eev1.element_entry_id = ee.element_entry_id
	AND  eev1.input_value_id   = iv1.input_value_id
    and ppa.effective_date BETWEEN eev1.effective_start_date and eev1.effective_end_date;


	CURSOR get_union_id(p_asg_act_id NUMBER) IS
	SELECT pap.per_information9
	FROM
	pay_assignment_actions      	pac,
	per_all_assignments             assign,
	per_all_people			pap
	WHERE pac.assignment_action_id = p_asg_act_id
	AND assign.assignment_id = pac.assignment_id
	AND assign.person_id = pap.person_id
    	AND pap.per_information_category = 'FI';

	CURSOR c_local_unit_id(P_ASG_ACT_ID NUMBER) is
	SELECT target.segment2 ,  ASSIGN.business_group_id
	FROM
	hr_soft_coding_keyflex                 target,
	per_all_assignments                  ASSIGN,
	fnd_id_flex_structures     fstruct,
	pay_legislation_rules      leg,
	pay_assignment_actions      pac
	WHERE  fstruct.id_flex_num		= leg.rule_mode
	AND    fstruct.id_flex_code		= 'SCL'
	AND    fstruct.application_id		= 800
	AND    leg.legislation_code		= 'FI'
	AND    fstruct.enabled_flag		= 'Y'
	AND    leg.rule_type			= 'S'
	AND    target.id_flex_num               = fstruct.id_flex_num
	AND    ASSIGN.assignment_id             = pac.assignment_id
	AND    pac.assignment_action_id         = P_ASG_ACT_ID
	AND    target.soft_coding_keyflex_id    = ASSIGN.soft_coding_keyflex_id
	AND    target.enabled_flag              = 'Y';

	CURSOR c_tax_unit_id (p_business_group_id NUMBER , p_organization_id NUMBER) IS
	SELECT hoi3.organization_id
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	, hr_organization_information hoi3
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id = p_organization_id
	AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id = hoi2.org_information1
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNITS'
	AND hoi2.organization_id =  hoi3.organization_id
	AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER' ;

	CURSOR c_accident_insurance_info( p_business_group_id	NUMBER , p_tax_unit_id NUMBER ,p_effective_date DATE ) IS
	SELECT hoi2.org_information3
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  p_tax_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_ACCIDENT_PROVIDERS'
	AND p_effective_date between  fnd_date.canonical_to_date(hoi2.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi2.org_information2),to_date('31/12/4712','DD/MM/YYYY'))   ;


	CURSOR c_effective_date(p_asg_act_id NUMBER ) IS
	SELECT  effective_date
	FROM pay_payroll_actions ppa,  pay_assignment_actions paa
	WHERE paa.assignment_action_id  = p_asg_act_id
	AND   paa.payroll_action_id   =  ppa.payroll_action_id ;

	CURSOR c_person_pension_num(p_asg_act_id  NUMBER ,  p_effective_date DATE) IS
	SELECT PER_INFORMATION24
	FROM   per_all_assignments_f         asg1
		 ,per_all_people_f           per
		 ,pay_assignment_actions      pac
	WHERE  per.person_id         = asg1.person_id
	AND  pac.assignment_action_id = p_asg_act_id
	AND asg1.assignment_id = pac.assignment_id
	AND  p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
	AND  p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date ;


	CURSOR c_pension_provider_info( p_business_group_id	NUMBER , p_tax_unit_id NUMBER , p_pension_num VARCHAR2 ,p_effective_date DATE ) IS
	SELECT hoi2.org_information4
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  p_tax_unit_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_PENSION_PROVIDERS'
	AND hoi2.org_information6 = p_pension_num
	AND p_effective_date between  fnd_date.canonical_to_date(hoi2.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi2.org_information2),to_date('31/12/4712','DD/MM/YYYY'))
	AND hoi2.org_information6 IN
	(
	SELECT NVL(hoi2.org_information1,0 )
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id = p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id = l_local_unit_id
	AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.org_information1 = p_pension_num
	AND hoi2.ORG_INFORMATION_CONTEXT='FI_LU_PENSION_PROVIDERS' );


BEGIN
	OPEN c_effective_date(p_asg_act_id);
	FETCH c_effective_date INTO l_effective_date;
	CLOSE c_effective_date;

	OPEN get_element_name(p_ee_id , l_effective_date );
	FETCH get_element_name INTO l_element_name;
	CLOSE get_element_name;

	IF l_element_name = 'Court Order' THEN
		OPEN get_details(p_asg_act_id );
		FETCH get_details INTO p_third_party_id;
		CLOSE get_details;
		IF p_third_party_id IS NULL THEN
			  fnd_message.set_name('PAY', 'HR_376665_FI_THIRD_PARTY_PAYEE');
			  fnd_message.set_token('NAME',hr_general.decode_lookup('FI_FORM_LABELS','COURT_ORDER'), translate => true );
			  hr_utility.raise_error;
		  END IF;

	ELSIF l_element_name = 'Trade Union Membership Fees' THEN
		OPEN get_union_id(p_asg_act_id);
		FETCH get_union_id INTO l_third_party_id;
		p_third_party_id:=l_third_party_id;
		CLOSE get_union_id;
		IF p_third_party_id IS NULL THEN
			 fnd_message.set_name('PAY', 'HR_376665_FI_THIRD_PARTY_PAYEE');
			  fnd_message.set_token('NAME',hr_general.decode_lookup('FI_FORM_LABELS','TRADE_UNION'), translate => true );
			  hr_utility.raise_error;
		END IF;

	ELSIF l_element_name = 'Pension Insurance' THEN

		OPEN c_local_unit_id(p_asg_act_id);
		FETCH c_local_unit_id INTO l_local_unit_id , l_business_group_id ;
		CLOSE c_local_unit_id ;


		OPEN c_tax_unit_id(l_business_group_id , l_local_unit_id);
		FETCH c_tax_unit_id INTO l_tax_unit_id ;
		CLOSE c_tax_unit_id;

		OPEN  c_person_pension_num( p_asg_act_id  ,  l_effective_date ) ;
		FETCH  c_person_pension_num INTO l_pension_num ;
		CLOSE  c_person_pension_num;

		IF   l_pension_num IS NOT NULL  THEN
			OPEN  c_pension_provider_info(  l_business_group_id	, l_tax_unit_id , l_pension_num , l_effective_date ) ;
			 FETCH  c_pension_provider_info INTO p_third_party_id ;
			 CLOSE  c_pension_provider_info;
		END IF;

		IF p_third_party_id IS NULL THEN
			  fnd_message.set_name('PAY', 'HR_376665_FI_THIRD_PARTY_PAYEE');
			  fnd_message.set_token('NAME',hr_general.decode_lookup('FI_FORM_LABELS','PEN_INS'), translate => true );
			  hr_utility.raise_error;
		END IF;


	ELSIF l_element_name IN  ('Unemployment Insurance' , 'Accident Insurance' , 'Group Life Insurance') THEN



		OPEN c_local_unit_id (p_asg_act_id);
		FETCH c_local_unit_id INTO l_local_unit_id , l_business_group_id ;
		CLOSE c_local_unit_id ;
		OPEN c_tax_unit_id (l_business_group_id , l_local_unit_id);
		FETCH c_tax_unit_id INTO l_tax_unit_id ;
		CLOSE c_tax_unit_id;
		OPEN c_accident_insurance_info( l_business_group_id, l_tax_unit_id, l_effective_date);
		FETCH c_accident_insurance_info INTO p_third_party_id ;
		CLOSE c_accident_insurance_info;

	END IF;

	IF p_third_party_id IS NULL THEN
		  fnd_message.set_name('PAY', 'HR_376665_FI_THIRD_PARTY_PAYEE');
		  fnd_message.set_token('NAME',hr_general.decode_lookup('FI_FORM_LABELS','ACC_INS'), translate => true );
		  hr_utility.raise_error;
	END IF;

EXCEPTION
	WHEN others THEN
	raise;

END get_third_party_org_context;


----------------------------------------------------------------------------
-- Procedure : get_source_text_context
-- Employment Status +  Employment Type
-----------------------------------------------------------------------------

PROCEDURE get_source_text_context
(p_asg_act_id		IN      NUMBER,
p_ee_id			IN      NUMBER,
p_source_text		IN OUT  NOCOPY VARCHAR2) IS

	l_employment_status varchar2(1);
	l_employment_type     varchar2(1);

	CURSOR get_details(P_ASG_ACT_ID NUMBER) is
	SELECT nvl(target.segment8, '1')
	FROM
	hr_soft_coding_keyflex                 target,
	per_all_assignments                  ASSIGN,
	fnd_id_flex_structures     fstruct,
	pay_legislation_rules      leg,
	pay_assignment_actions      pac
	WHERE  fstruct.id_flex_num		= leg.rule_mode
	AND    fstruct.id_flex_code		= 'SCL'
	AND    fstruct.application_id		= 800
	AND    leg.legislation_code		= 'FI'
	AND    fstruct.enabled_flag		= 'Y'
	AND    leg.rule_type			= 'S'
	AND    target.id_flex_num               = fstruct.id_flex_num
	AND    ASSIGN.assignment_id             = pac.assignment_id
	AND    pac.assignment_action_id         = P_ASG_ACT_ID
	AND    target.soft_coding_keyflex_id    = ASSIGN.soft_coding_keyflex_id
	AND    target.enabled_flag              = 'Y';

CURSOR get_iv_details(P_ASG_ACT_ID NUMBER ) IS
  SELECT eev1.screen_entry_value  screen_entry_value
   FROM   per_all_assignments_f      asg1
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
	 ,pay_assignment_actions      pac
	 ,pay_payroll_actions     ppa
   WHERE  pac.assignment_action_id         = P_ASG_ACT_ID
     AND  ppa.payroll_action_id  = pac.payroll_action_id
      AND   asg1.assignment_id             = pac.assignment_id
     AND ppa.effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND  et.element_name       = 'Tax'
     AND  et.legislation_code   = 'FI'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              =	'Primary Employment'
     AND  el.business_group_id  = asg1.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg1.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND   ppa.effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND   ppa.effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date;


BEGIN
	OPEN get_details(P_ASG_ACT_ID);
	FETCH get_details into l_employment_status;
	CLOSE get_details;

	 OPEN  get_iv_details(P_ASG_ACT_ID);
	 FETCH get_iv_details INTO l_employment_type;
	 CLOSE get_iv_details;

	 IF		l_employment_status =1 AND  l_employment_type = 'Y' THEN
			 P_SOURCE_TEXT:='PEMP';
	 ELSIF	l_employment_status=1 AND  l_employment_type = 'N' THEN
			P_SOURCE_TEXT:='SEMP';
	 ELSIF	l_employment_status=2 AND  l_employment_type = 'Y' THEN
	 		 P_SOURCE_TEXT:='PUNEMP';
	 ELSIF	l_employment_status=2 AND  l_employment_type = 'N' THEN
			 P_SOURCE_TEXT:='SUNEMP';
	 END IF;

EXCEPTION
	WHEN others THEN
	NULL;
END  get_source_text_context;

-----------------------------------------------------------------------------
-- Procedure : get_source_text2_context
-- It fetches the tax category of the Assignment Id
-----------------------------------------------------------------------------


PROCEDURE get_source_text2_context
(p_asg_act_id		IN      NUMBER,
p_ee_id			IN      NUMBER,
p_source_text2		IN OUT  NOCOPY VARCHAR2)  IS

	l_tax_category varchar2(10);
	CURSOR get_details(P_ASG_ACT_ID NUMBER) is
	SELECT nvl(target.segment13,'N')
	FROM
	hr_soft_coding_keyflex                 target,
	per_all_assignments                  ASSIGN,
	fnd_id_flex_structures     fstruct,
	pay_legislation_rules      leg,
	pay_assignment_actions      pac
	WHERE  fstruct.id_flex_num		= leg.rule_mode
	AND    fstruct.id_flex_code		= 'SCL'
	AND    fstruct.application_id		= 800
	AND    leg.legislation_code		= 'FI'
	AND    fstruct.enabled_flag		= 'Y'
	AND    leg.rule_type			= 'S'
	AND    target.id_flex_num               = fstruct.id_flex_num
	AND    ASSIGN.assignment_id             = pac.assignment_id
	AND    pac.assignment_action_id         = P_ASG_ACT_ID
	AND    target.soft_coding_keyflex_id    = ASSIGN.soft_coding_keyflex_id
	AND    target.enabled_flag              = 'Y';
BEGIN
	OPEN get_details(P_ASG_ACT_ID);
	FETCH get_details into l_tax_category;
	P_SOURCE_TEXT2:=l_tax_category;
	CLOSE get_details;
EXCEPTION
	WHEN others THEN
	NULL;

END get_source_text2_context;

-----------------------------------------------------------------------------
-- Procedure : get_main_local_unit_id
-- It fetches the tax category of the Assignment Id
-----------------------------------------------------------------------------


PROCEDURE get_main_local_unit_id
(p_assignment_id	IN      NUMBER,
p_effective_date	IN      DATE ,
p_local_unit_id		IN OUT  NOCOPY VARCHAR2) IS

	CURSOR c_local_unit_id(p_assignment_id NUMBER , p_effective_date DATE ) is
	SELECT target.segment2
	FROM
	hr_soft_coding_keyflex                 target,
	per_all_assignments_f                  ASSIGN,
	fnd_id_flex_structures     fstruct,
	pay_legislation_rules      leg
	WHERE  fstruct.id_flex_num		= leg.rule_mode
	AND    fstruct.id_flex_code		= 'SCL'
	AND    fstruct.application_id		= 800
	AND    leg.legislation_code		= 'FI'
	AND    fstruct.enabled_flag		= 'Y'
	AND    leg.rule_type			= 'S'
	AND    target.id_flex_num               = fstruct.id_flex_num
	AND    ASSIGN.assignment_id             = p_assignment_id
	AND    target.soft_coding_keyflex_id    = ASSIGN.soft_coding_keyflex_id
	AND  p_effective_date BETWEEN ASSIGN.effective_start_date AND ASSIGN.effective_end_date
	AND    target.enabled_flag              = 'Y';

BEGIN
	OPEN c_local_unit_id(p_assignment_id , p_effective_date ) ;
	FETCH c_local_unit_id into p_local_unit_id	;
	CLOSE c_local_unit_id;
EXCEPTION
	WHEN others THEN
	p_local_unit_id := NULL;

END get_main_local_unit_id;

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

PROCEDURE LOAD_XML (
    P_NODE_TYPE     varchar2,
    P_CONTEXT_CODE  varchar2,
    P_NODE          varchar2,
    P_DATA          varchar2
) AS

    CURSOR csr_get_tag_name IS
        SELECT TRANSLATE (UPPER(end_user_column_name), ' /','__') tag_name
          FROM fnd_descr_flex_col_usage_vl
         WHERE descriptive_flexfield_name = 'Action Information DF'
           AND descriptive_flex_context_code = p_context_code
           AND application_column_name = UPPER (p_node);

    CURSOR csr_get_chk_no IS
        SELECT paa_chk.serial_number
          FROM pay_assignment_actions paa_xfr,
               pay_action_interlocks pai_xfr,
               pay_action_interlocks pai_chk,
               pay_assignment_actions paa_chk,
               pay_payroll_actions ppa_chk
         WHERE paa_xfr.assignment_action_id = pai_xfr.locking_action_id
           AND pai_xfr.locked_action_id = pai_chk.locked_action_id
           AND pai_chk.locking_action_id = paa_chk.assignment_action_id
           AND paa_chk.payroll_action_id = ppa_chk.payroll_action_id
           AND ppa_chk.action_type = 'H'
           AND paa_xfr.assignment_action_id = g_action_ctx_id;

    l_tag_name  varchar2(500);
    l_chk_no    pay_assignment_actions.serial_number%type;
    l_data      pay_action_information.action_information1%type;

PROCEDURE LOAD_XML_INTERNAL (
    P_NODE_TYPE         varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
) AS

    l_data      pay_action_information.action_information1%type;

BEGIN

IF p_node_type = 'CS' THEN

	pay_payroll_xml_extract_pkg.g_custom_xml (pay_payroll_xml_extract_pkg.g_custom_xml.count() + 1) := '<'||p_node||'>';

ELSIF p_node_type = 'CE' THEN

	pay_payroll_xml_extract_pkg.g_custom_xml (pay_payroll_xml_extract_pkg.g_custom_xml.count() + 1) := '</'||p_node||'>';

ELSIF p_node_type = 'D' THEN

	/* Handle special charaters in data */
	l_data := REPLACE (p_data, '&', '&amp;');
	l_data := REPLACE (l_data, '>', '&gt;');
	l_data := REPLACE (l_data, '<', '&lt;');
	l_data := REPLACE (l_data, '''', '&apos;');
	l_data := REPLACE (l_data, '"', '&quot;');
	pay_payroll_xml_extract_pkg.g_custom_xml (pay_payroll_xml_extract_pkg.g_custom_xml.count() + 1) := '<'||p_node||'>'||l_data||'</'||p_node||'>';
END IF;
END LOAD_XML_INTERNAL;


BEGIN

    IF p_node_type = 'D' THEN

        /* Fetch segment names */
        OPEN csr_get_tag_name;
            FETCH csr_get_tag_name INTO l_tag_name;
        CLOSE csr_get_tag_name;

        /* Fetch cheque number */
        IF p_context_code = 'EMPLOYEE NET PAY DISTRIBUTION' AND
           l_tag_name = 'CHECK_DEPOSIT_NUMBER' THEN
            OPEN csr_get_chk_no;
                FETCH csr_get_chk_no INTO l_chk_no;
            CLOSE csr_get_chk_no;
        END IF;
    END IF;

    IF UPPER(p_node) NOT LIKE '?XML%' AND UPPER(p_node) NOT LIKE 'XAPI%' THEN
        l_tag_name := nvl(l_tag_name, TRANSLATE(p_node, ' /', '__'));
        IF p_node_type IN ('CS', 'CE') THEN
            l_tag_name := nvl(g_custom_context, TRANSLATE(p_node, ' /', '__'));
        END IF;
    ELSE
        l_tag_name := p_node;
    END IF;

    l_data := nvl(l_chk_no, p_data);
    load_xml_internal (p_node_type, l_tag_name, l_data);
END LOAD_XML;


 PROCEDURE add_custom_xml
       (p_assignment_action_id number,
        p_action_information_category varchar2,
        p_document_type varchar2) as

	  CURSOR csr_payroll_info(p_action_context_id    NUMBER
                           ,p_category1            VARCHAR2
                           ,p_category2            VARCHAR2) IS
    SELECT ppf.payroll_name	   payroll_name
    	  ,ptp.period_name     period_name
	      ,ptp.period_type     period_type
          ,ptp.start_date      start_date
          ,ptp.end_date	       end_date
     	  ,pai.effective_date  payment_date
    FROM per_time_periods ptp
    	,pay_payrolls_f   ppf
        ,pay_action_information pai
    WHERE ppf.payroll_id = ptp.payroll_id
	AND pai.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
	AND ptp.time_period_id = pai.action_information16
	AND pai.action_context_type  = 'AAP'
    AND pai.action_information_category  = p_category1
    AND pai.action_context_id    =  p_action_context_id
   UNION
    SELECT ppf.payroll_name	   payroll_name
    	  ,ptp.period_name     period_name
	      ,ptp.period_type     period_type
          ,ptp.start_date      start_date
          ,ptp.end_date	       end_date
     	  ,pai.effective_date  payment_date
    FROM per_time_periods ptp
    	,pay_payrolls_f   ppf
        ,pay_action_information pai
        ,pay_assignment_actions paa
    WHERE ppf.payroll_id = ptp.payroll_id
	AND pai.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
	AND ptp.time_period_id = pai.action_information16
	AND pai.action_context_type  = 'AAP'
    AND pai.action_information_category  = p_category1
    AND pai.action_context_id = paa.source_action_id
    AND paa.assignment_action_id =  p_action_context_id
    AND   paa.assignment_id 	 =  pai.assignment_id ;
/*Fix for 5505812
      SELECT ppf.payroll_name	   payroll_name
		  ,ptp.period_name     period_name
		  ,ptp.period_type     period_type
          ,ptp.start_date      start_date
          ,ptp.end_date	       end_date
     	  ,pai.effective_date  payment_date
--                  ,pai1.action_information4 ss_days
    FROM per_time_periods ptp
	,pay_payrolls_f   ppf
        ,pay_action_information pai
--        ,pay_action_information pai1
    WHERE ppf.payroll_id = ptp.payroll_id
	AND pai.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
	AND ptp.time_period_id = pai.action_information16
	AND pai.action_context_type  = 'AAP'
--	AND pai1.action_context_type = 'AAP'
    AND pai.action_information_category  = p_category1
--    AND pai1.action_information_category = p_category2
    AND (pai.action_context_id    =  p_action_context_id
         OR pai.action_context_id = ( SELECT paa.source_action_id
                                      FROM   pay_assignment_actions paa
                                      WHERE paa.assignment_action_id =  p_action_context_id
                                      AND   paa.assignment_id 	     =  pai.Assignment_ID
                                    ));
*/

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
		   ,sum(fnd_number.canonical_to_number(pai1.action_information4)) value
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
    ORDER BY pai.action_information5,pai1.action_information8 DESC;


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


        l_xml                        CLOB;
	cntr_flex_col    NUMBER;
	l_flex_col_num   NUMBER;
       sqlstr              DBMS_SQL.VARCHAR2S;
       csr              NUMBER;
       ret              NUMBER;
       l_cntr_sql         NUMBER;
       l_total_pay  NUMBER;
       l_total_earnings  NUMBER;
       l_total_deductions NUMBER;


PROCEDURE build_sql(p_sqlstr_tab    IN OUT NOCOPY DBMS_SQL.VARCHAR2S,
                    p_cntr          IN OUT NOCOPY NUMBER,
                    p_string        VARCHAR2) AS
    --
    l_proc_name varchar2(100);
    --
BEGIN
    p_sqlstr_tab(p_cntr) := p_string;
    p_cntr               := p_cntr + 1;
END;

   BEGIN
	l_flex_col_num := 30;

	IF   p_action_information_category IS NULL AND p_document_type ='PAYSLIP' THEN

		l_total_earnings:=0 ;
		l_total_deductions :=0;
		g_action_ctx_id     := p_assignment_action_id ;

		FOR payroll_info_rec IN csr_payroll_info (p_assignment_action_id,'EMPLOYEE DETAILS','ADDL EMPLOYEE DETAILS')
			LOOP

  				load_xml('CS', NULL, 'PAYROLL PROCESSING INFORMATION', NULL);
				load_xml('D', NULL, 'PAYROLL_NAME', payroll_info_rec.payroll_name );
				load_xml('D', NULL, 'PERIOD_NAME', payroll_info_rec.period_name);
				load_xml('D', NULL, 'PERIOD_TYPE', payroll_info_rec.period_type);
				load_xml('D', NULL, 'START_DATE', payroll_info_rec.start_date);
				load_xml('D', NULL, 'END_DATE', payroll_info_rec.end_date);
				load_xml('D', NULL, 'PAYMENT_DATE', payroll_info_rec.payment_date);
				load_xml('CE', NULL, 'PAYROLL PROCESSING INFORMATION', NULL);

				load_xml('CS', NULL, 'SALARY CERTIFICATE', NULL);
				load_xml('D', NULL, 'PERIOD_START_END', payroll_info_rec.start_date||'  - '||payroll_info_rec.end_date);
				load_xml('D', NULL, 'YTD_START_END', trunc(payroll_info_rec.start_date,'Y') ||'  - '||payroll_info_rec.end_date);
				load_xml('D', NULL, 'PREV_YTD_START_END', add_months(trunc(payroll_info_rec.start_date,'Y'), -12) ||'  - '||LAST_DAY(ADD_MONTHS(trunc(payroll_info_rec.end_date,'Y'),-1)));
				load_xml('CE', NULL, 'SALARY CERTIFICATE', NULL);

		END LOOP;

		FOR element_info_rec IN csr_element_info(p_assignment_action_id , 'EMEA ELEMENT DEFINITION' , 'EMEA ELEMENT INFO')
			LOOP

				load_xml('CS', NULL, 'ELEMENT DETAILS', NULL);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION2', element_info_rec.element_type_id);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION3', element_info_rec.input_value_id);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION4', element_info_rec.Name);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION5', element_info_rec.type);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION6', element_info_rec.uom);
				load_xml('D', 'EMEA ELEMENT INFO', 'ACTION_INFORMATION4', fnd_number.canonical_to_number(element_info_rec.value));
				load_xml('CE', NULL, 'ELEMENT DETAILS', NULL);

				       IF element_info_rec.type = 'E' THEN
					       l_total_earnings := fnd_number.canonical_to_number(l_total_earnings) + fnd_number.canonical_to_number(nvl(element_info_rec.value,0)) ;
				       ELSIF element_info_rec.type = 'D' THEN
						l_total_deductions := fnd_number.canonical_to_number(l_total_deductions) + fnd_number.canonical_to_number(nvl(element_info_rec.value,0)) ;
					END IF ;
					l_total_pay := l_total_earnings - l_total_deductions ;

			END LOOP;

			FOR add_element_info_rec IN csr_add_element_info(p_assignment_action_id , 'EMEA ELEMENT DEFINITION' , 'EMEA ELEMENT INFO')
			LOOP

				load_xml('CS', NULL, 'ELEMENT DETAILS', NULL);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION2', add_element_info_rec.element_type_id);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION3', add_element_info_rec.input_value_id);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION4', add_element_info_rec.Name);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION5', add_element_info_rec.type);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION6', add_element_info_rec.uom);
				load_xml('D', 'EMEA ELEMENT INFO', 'ACTION_INFORMATION4', add_element_info_rec.value);
				load_xml('CE', NULL, 'ELEMENT DETAILS', NULL);

			END LOOP;



			load_xml('CS', NULL, 'SUMMARY OF PAYMENTS', NULL);
                        load_xml('D', NULL, 'TOTAL_EARNINGS', l_total_earnings);
                        load_xml('D', NULL, 'TOTAL_DEDUCTIONS', l_total_deductions);
                        load_xml('D', NULL, 'TOTAL_PAY', l_total_pay);
			load_xml('CE', NULL, 'SUMMARY OF PAYMENTS', NULL);

	    -- BALANCE DETAILS
			l_cntr_sql      := 1;
			build_sql(sqlstr, l_cntr_sql, ' Begin FOR csr_balance_info_rec IN pay_fi_rules.csr_balance_info ('||p_assignment_action_id||',''EMEA BALANCE DEFINITION'',''EMEA BALANCES'') LOOP ');
			build_sql(sqlstr, l_cntr_sql, ' pay_fi_rules.load_xml(''CS'', NULL, ''BALANCE DETAILS'', NULL); ');
			FOR cntr in 1..30
			LOOP
				IF flex_seg_enabled ('EMEA BALANCE DEFINITION', 'ACTION_INFORMATION'||cntr) THEN
					build_sql(sqlstr, l_cntr_sql, ' pay_fi_rules.load_xml(''D'', ''EMEA BALANCE DEFINITION'', ''ACTION_INFORMATION'||cntr||''', csr_balance_info_rec.a'||cntr||'); ');
				END IF;
			        IF flex_seg_enabled ('EMEA BALANCES', 'ACTION_INFORMATION'||cntr) THEN
					 build_sql(sqlstr, l_cntr_sql, ' pay_fi_rules.load_xml(''D'', ''EMEA BALANCES'', ''ACTION_INFORMATION'||cntr||''', csr_balance_info_rec.aa'||cntr||'); ');
				END IF;
			END LOOP;
			build_sql(sqlstr, l_cntr_sql, ' pay_fi_rules.load_xml(''CE'', NULL, ''BALANCE DETAILS'', NULL); ');
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




	END IF;

   END;

END PAY_FI_RULES;

/
