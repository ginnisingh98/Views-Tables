--------------------------------------------------------
--  DDL for Package Body PAY_NO_PACCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_PACCR_PKG" AS
/* $Header: pynopaccr.pkb 120.5.12000000.3 2007/07/05 10:07:34 kseth noship $ */

--Global parameters
 g_package                  CONSTANT varchar2(33) := 'PAY_NO_PACCR_PKG.';
 g_debug                    BOOLEAN               :=  hr_utility.debug_enabled;
 g_err_num                  NUMBER;



 -----------------------------------------------------------------------------
 -- GET_PARAMETER  used in SQL to decode legislative parameters
 -----------------------------------------------------------------------------
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

 --------------------------------------------------------------------------------------
 -- GET_ALL_PARAMETERS  used in SQL to cumulatively decode all legislative parameters
 --------------------------------------------------------------------------------------
PROCEDURE GET_ALL_PARAMETERS
	(p_payroll_action_id     IN   NUMBER
	,p_business_group_id     OUT  NOCOPY NUMBER
	,p_payroll_id            OUT  NOCOPY NUMBER
	,p_le_id                 OUT  NOCOPY NUMBER
	,p_ele_id                OUT  NOCOPY NUMBER
	,p_restr_econtr          OUT  NOCOPY VARCHAR2
	,p_eoy_code              OUT  NOCOPY VARCHAR2
	,p_cost_seg              OUT  NOCOPY VARCHAR2
	,p_effective_date        OUT  NOCOPY DATE
	,p_report_start_date     OUT  NOCOPY DATE
	,p_report_end_date       OUT  NOCOPY DATE
	,p_archive               OUT  NOCOPY VARCHAR2)
IS


CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
         SELECT
         PAY_NO_PACCR_PKG.GET_PARAMETER(legislative_parameters,'PAYROLL')
        ,PAY_NO_PACCR_PKG.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER')
        ,PAY_NO_PACCR_PKG.GET_PARAMETER(legislative_parameters,'RESTRICT_EMPLR_CONTR')
        ,PAY_NO_PACCR_PKG.GET_PARAMETER(legislative_parameters,'ELEMENT_NAME')
        ,PAY_NO_PACCR_PKG.GET_PARAMETER(legislative_parameters,'EOY_CODE')
        ,PAY_NO_PACCR_PKG.GET_PARAMETER(legislative_parameters,'COSTING_SEG')
        ,effective_date
        ,fnd_date.canonical_to_date(PAY_NO_PACCR_PKG.GET_PARAMETER(legislative_parameters,'REPORT_START_DATE'))
        ,fnd_date.canonical_to_date(PAY_NO_PACCR_PKG.GET_PARAMETER(legislative_parameters,'REPORT_END_DATE'))
        ,PAY_NO_PACCR_PKG.GET_PARAMETER(legislative_parameters,'ARCHIVE')
        ,business_group_id
        FROM  pay_payroll_actions
        WHERE payroll_action_id = p_payroll_action_id;

l_proc VARCHAR2(240):= g_package||'.GET_ALL_PARAMETERS ';
--
BEGIN

 IF g_debug THEN
      hr_utility.set_location(' Entering procedure '||l_proc,10);
 END IF;

 OPEN csr_parameter_info (p_payroll_action_id);

 FETCH csr_parameter_info
 INTO    p_payroll_id
        ,p_le_id
	,p_restr_econtr
        ,p_ele_id
        ,p_eoy_code
        ,p_cost_seg
        ,p_effective_date
        ,p_report_start_date
        ,p_report_end_date
        ,p_archive
        ,p_business_group_id;
 CLOSE csr_parameter_info;
 --
 IF g_debug THEN
      hr_utility.set_location(' Leaving procedure '||l_proc,20);
 END IF;
END GET_ALL_PARAMETERS;

 --------------------------------------------------------------------------------------
 -- GET_ELEMENT_CODE to get the element code of an element in a particular year
 --------------------------------------------------------------------------------------

FUNCTION GET_ELE_CODE(
	 l_element_type_id   IN NUMBER
	,l_effective_date    IN DATE) RETURN VARCHAR2
IS
     CURSOR get_code IS
     SELECT etei.eei_information3
     FROM  pay_element_type_extra_info etei
     WHERE etei.element_type_id            = l_element_type_id
     AND   etei.eei_information_category   = 'NO_EOY_REPORTING_CODE_MAPPING'
     AND   to_number(to_char(l_effective_date,'YYYY'))
           between  to_number(etei.eei_information1) and to_number(nvl(etei.eei_information2,'4712'));
--
    l_ele_code pay_element_type_extra_info.eei_information3%TYPE;
--
BEGIN
--
     OPEN get_code;
     FETCH get_code INTO l_ele_code;
     CLOSE get_code;
--
     RETURN l_ele_code;
--
END GET_ELE_CODE;

 --------------------------------------------------------------------------------------
 -- RANGE_CODE to specify ranges of assignments to be processed in the archive.
 --------------------------------------------------------------------------------------

PROCEDURE RANGE_CODE (pactid    IN    NUMBER
		     ,sqlstr    OUT   NOCOPY VARCHAR2)
IS

-- Variable's declarations

	l_count                 NUMBER := 0;
	l_action_info_id        NUMBER;
	l_ovn                   NUMBER;
	l_business_group_id     NUMBER;
	l_payroll_id            NUMBER;

	l_le_id                 NUMBER;
	l_le_name               VARCHAR(80);
	l_le_org_no             VARCHAR(80);

	l_effective_date        DATE;
	l_report_end_date       DATE;
	l_report_start_date     DATE;
	l_archive               VARCHAR2(80);

	l_from_date             VARCHAR2(80);
	l_to_date               VARCHAR2(80);

	l_restr_econtr	        VARCHAR2(80);
	l_ele_type_id           NUMBER;
	l_eoy_code              VARCHAR2(80);
	l_cost_seg  		VARCHAR2(80);
	l_payroll_name	        VARCHAR2(80);
	l_ele_name	        VARCHAR2(80);



/* Cursor to check if Current Archive exists */
CURSOR csr_count is
SELECT count(*)
FROM   pay_action_information
WHERE  action_information_category = 'EMEA REPORT DETAILS'
AND    action_information1         = 'PYNOPACCA'
AND    action_context_id           = pactid;


/* Cursor to fetch the Legal Employer Details */
CURSOR csr_get_le_details(p_le_id NUMBER, p_effective_date DATE, p_business_group_id NUMBER) IS
SELECT  hou.name  NAME
      , hoi.org_information1  ORGANIZATION_NO
FROM hr_organization_units   hou
    ,hr_organization_information   hoi
WHERE hou.business_group_id =  p_business_group_id
and   hoi.organization_id = hou.organization_id
and   hoi.org_information_context = 'NO_LEGAL_EMPLOYER_DETAILS'
and   hou.organization_id = p_le_id
and   p_effective_date BETWEEN hou.DATE_FROM and nvl(hou.DATE_TO, p_effective_date) ;


rec_le_details        csr_get_le_details%ROWTYPE;

BEGIN

IF g_debug THEN
      hr_utility.set_location(' Entering Procedure RANGE_CODE',10);
END IF;


 -- The sql string to return
 sqlstr := 'SELECT DISTINCT person_id
	FROM  per_people_f ppf
	     ,pay_payroll_actions ppa
	WHERE ppa.payroll_action_id = :payroll_action_id
	AND   ppa.business_group_id = ppf.business_group_id
	ORDER BY ppf.person_id';


  -- Fetch the input parameter values
PAY_NO_PACCR_PKG.GET_ALL_PARAMETERS(
		 pactid
	        ,l_business_group_id
		,l_payroll_id
		,l_le_id
		,l_ele_type_id
		,l_restr_econtr
		,l_eoy_code
		,l_cost_seg
		,l_effective_date
		,l_report_start_date
		,l_report_end_date
		,l_archive);


/* To obtain Reporting From and Reporting To Dates from Span specified in parameters */

l_to_date   := to_char(l_report_end_date,'YYYYMMDD');
l_from_date   := to_char(l_report_start_date,'YYYYMMDD');


/* To fetch Legal Employer Details */
OPEN csr_get_le_details(l_le_id ,fnd_date.canonical_to_date(l_to_date),l_business_group_id);
FETCH  csr_get_le_details INTO 	rec_le_details;
CLOSE  csr_get_le_details;

l_le_name :=  rec_le_details.name;
l_le_org_no :=  rec_le_details.organization_no;

/*To fetch the Payroll Name */
BEGIN
	SELECT ppf.payroll_name INTO l_payroll_name
	FROM
	pay_all_payrolls_f ppf
	WHERE ppf.payroll_id=l_payroll_id;
EXCEPTION
	WHEN OTHERS THEN
	NULL;
END;

/*To fetch the Element Name */
-- Modified for bug fix 5239796
BEGIN
	SELECT nvl(petf.reporting_name,petf.element_name) INTO l_ele_name
	FROM
	pay_element_types_f petf
	WHERE petf.element_type_id=l_ele_type_id;
EXCEPTION
	WHEN OTHERS THEN
	NULL;
END;


/* Archive the Header Information */

-- Check if we have to archive again
IF  (l_archive = 'Y')   THEN
-- Check if record for current archive exists
OPEN csr_count;
FETCH csr_count INTO l_count;
CLOSE csr_count;

-- Archive Report Details only if no record exists
   IF (l_count < 1) THEN

	  -- Archive the REPORT HEADER

	pay_action_information_api.create_action_information
	(p_action_information_id        => l_action_info_id             -- out parameter
	,p_object_version_number        => l_ovn                        -- out parameter
	,p_action_context_id            => pactid                       -- context id = payroll action id (of Archive)
	,p_action_context_type          => 'PA'                         -- context type
	,p_effective_date               => l_effective_date             -- Date of Running the Archive
	,p_action_information_category  => 'EMEA REPORT DETAILS'        -- Information Category
	,p_tax_unit_id                  => l_le_id                      -- Legal Employer ID
	,p_jurisdiction_code            => NULL                         -- Tax Municipality ID
	,p_action_information1          => 'PYNOPACCA'                  -- Conc Prg Short Name
	,p_action_information2          => l_business_group_id          -- Business Group ID
	,p_action_information3          => l_payroll_id                 -- Payroll ID
	,p_action_information4          => 'HDR'                        -- Specifies data is for File Header
	,p_action_information5          => l_from_date                  -- Report's from date
	,p_action_information6          => l_to_date                    -- Report's to date
	,p_action_information7          => l_le_name                    -- LE's Name
	,p_action_information8          => l_le_org_no                  -- LE's Organization Number
	,p_action_information9          => l_cost_seg                   -- Parameter Costing Flexfield Segments
	,p_action_information10         => l_eoy_code                   -- Parameter End Of Year Code
	,p_action_information11         => l_ele_type_id                -- Parameter Element Type ID
	,p_action_information12         => l_report_start_date	        -- Parameter Report Start Date
	,p_action_information13         => l_report_end_date	        -- Parameter Report End Date
        ,p_action_information14         => l_restr_econtr	        -- Parameter Restrict to Employer Contribution
        ,p_action_information15         => l_payroll_name	        -- Parameter Payroll's Name
        ,p_action_information16         => l_ele_name			-- Parameter Element's Name
	);
   END IF;
END IF;
--
IF g_debug THEN
  hr_utility.set_location(' Leaving Procedure RANGE_CODE',20);
END IF;
--
END RANGE_CODE;
 --------------------------------------------------------------------------------------
 -- ASSIGNMENT_ACTION_CODE to create the assignment actions to be processed.
 --------------------------------------------------------------------------------------
PROCEDURE ASSIGNMENT_ACTION_CODE
 (p_payroll_action_id     IN NUMBER
 ,p_start_person          IN NUMBER
 ,p_end_person            IN NUMBER
 ,p_chunk                 IN NUMBER)
 IS
/* Cursor to fetch useful header information to transfer to body records from already archived header information */
CURSOR csr_get_hdr_info(p_payroll_action_id NUMBER) IS
SELECT effective_date
      ,fnd_date.CANONICAL_TO_DATE(action_information5) from_date
      ,fnd_date.CANONICAL_TO_DATE(action_information6) to_date
      ,to_number(action_information2)  business_group_id
      ,to_number(action_information3) payroll_id
      ,action_information10 eoy_code
      ,tax_unit_id
      ,to_number(action_information11) ele_type_id
      ,action_information14  restr_econtr
      ,action_information9  cost_seg
FROM pay_action_information pai
WHERE action_context_type = 'PA'
AND action_context_id  = p_payroll_action_id
AND action_information_category = 'EMEA REPORT DETAILS'
AND action_information1 = 'PYNOPACCA'
AND action_information4 = 'HDR';


/* Cursor to fetch local units for a Legal Employer */
CURSOR csr_get_lu_le (p_le_id NUMBER
		     ,p_bg_id  NUMBER)  IS
SELECT	to_number(hoi.ORG_INFORMATION1)  lu_id
FROM	HR_ORGANIZATION_UNITS hou
      , HR_ORGANIZATION_INFORMATION hoi
WHERE   hou.business_group_id = p_bg_id
AND     hou.organization_id = p_le_id
AND     hoi.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
AND     hoi.organization_id = hou.organization_id;


/* Cursor to fetch Details of Costing information */
CURSOR csr_assignments
         (p_payroll_action_id    NUMBER
         ,p_payroll_id           NUMBER
         ,p_start_person         NUMBER
         ,p_end_person           NUMBER
	 ,p_restr_econtr         VARCHAR2
	 ,p_cost_seg             VARCHAR2
	 ,p_element_type_id	 NUMBER
	 ,p_eoy_code             VARCHAR2
	 ,p_business_group_id    NUMBER
	 ,p_start_date           DATE
	 ,p_end_date             DATE
	 ,p_local_unit           NUMBER
	 ,p_effective_date       DATE) IS
SELECT	distinct  pet.element_type_id			ELE_TYPE_ID
	-- Modified for bug fix 5239796
	,nvl(pet.reporting_name,pet.element_name)	ELE_NAME
--	,pet.element_information1			ELE_EOY_CODE
	,paaf.assignment_id				ASG_ID
	,paaf.assignment_number				ASSIGNMENT_NUMBER
	,ppf.payroll_name				PAYROLL_NAME
	,pcak.concatenated_segments			ELE_COST_SEG
	,pc.cost_allocation_keyflex_id			COST_FLEX_ID
	,pc.debit_or_credit				DEBIT_CREDIT
	,pc.costed_value				COSTED_VALUE
	,ppa.effective_date				EFFECTIVE_DATE
	,pc.balance_or_cost 				COST_OR_BAL
	,papf.full_name					EMP_NAME
	,prr.run_result_id                              RR_ID -- not in use
FROM
  pay_payroll_actions 		  ppa
, pay_payrolls_f		  ppf
, per_all_people_f       	  papf
, per_all_assignments_f 	  paaf
, pay_assignment_actions 	  paa
, hr_soft_coding_keyflex 	  hsck
, pay_element_types_f    	  pet
, pay_input_values_f     	  piv
, pay_run_results		  prr
, pay_costs			  pc
, pay_cost_allocation_keyflex     pcak
WHERE paaf.person_id BETWEEN p_start_person AND p_end_person
AND papf.person_id = paaf.person_id
-- Added for bug 5242754 - Start
AND paaf.effective_start_date <= p_end_date
AND paaf.effective_end_date >= p_start_date
AND papf.current_employee_flag = 'Y'
-- Added for bug 5242754 - End
AND ppf.payroll_id = nvl(p_payroll_id,ppf.payroll_id)
AND paaf.payroll_id = ppf.payroll_id
AND paa.payroll_action_id = ppa.payroll_action_id
AND paa.assignment_id = paaf.assignment_id
AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
AND hsck.enabled_flag = 'Y'
AND hsck.segment2 = nvl(to_char(p_local_unit),hsck.segment2)
AND pet.element_type_id = nvl(p_element_type_id,pet.element_type_id)
-- AND nvl(pet.element_information1,0) = nvl(p_eoy_code,nvl(pet.element_information1,0))
AND (pet.business_group_id = p_business_group_id OR pet.legislation_code='NO')
AND pet.element_type_id = piv.element_type_id
-- Modified for bug fix 5242486
AND pet.classification_id IN
  (select pec2.classification_id
   from	pay_element_classifications     pec1
      , pay_element_classifications     pec2
      -- Added for bug fix 5242486
      , pay_sub_classification_rules_f  pscrf
   where pec2.classification_id = pec1.parent_classification_id	(+)
   and nvl(pec1.classification_name,'0') like decode(p_restr_econtr
                                           , 'Y','%Subject%to%Employer%Contributions%'
                                           , '%')
   and pec2.classification_id = pet.classification_id
   -- Added for bug fix 5242486
   -- Modified for bug fix 6069852
   and pscrf.element_type_id = pet.element_type_id
   --and pscrf.classification_id = pec1.classification_id
   and ppa.date_earned between pscrf.effective_start_date and pscrf.effective_end_date
   -- Added for bug fix 6069852
   UNION ALL
   select pec2.classification_id
   from	pay_element_classifications     pec1
      , pay_element_classifications     pec2
   where pec2.classification_id = pec1.parent_classification_id	(+)
   and nvl(pec1.classification_name,'0') like decode(p_restr_econtr
                                           , 'N','%')
   and pec2.classification_id = pet.classification_id
   )
AND piv.name ='Pay Value'
AND nvl(pc.distributed_input_value_id, pc.input_value_id) = piv.input_value_id
AND prr.element_type_id = pet.element_type_id
AND prr.run_result_id = pc.run_result_id
AND pc.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id
AND pcak.concatenated_segments like replace(nvl(p_cost_seg,'%'),'.','%.')||'%'
AND prr.assignment_action_id = paa.assignment_action_id
AND ppa.date_earned between pet.effective_start_date and pet.effective_end_date
AND ppa.date_earned between p_start_date and p_end_date
AND ppa.date_earned between paaf.effective_start_date and paaf.effective_end_date
AND ppa.date_earned between papf.effective_start_date and papf.effective_end_date
AND ppa.date_earned between piv.effective_start_date and piv.effective_end_date
AND ppa.date_earned between ppf.effective_start_date and ppf.effective_end_date;


/* Cursor to get Element Code */
-- Modified for bug fix 5239796
CURSOR csr_ele_code(p_ele_type_id  NUMBER
		   ,p_leg_emp_id NUMBER) IS
/*SELECT eei_information1  ele_code
FROM pay_element_type_extra_info petei
WHERE information_type='NO_ELEMENT_CODES'
AND nvl(element_type_id,0) = p_ele_type_id
AND nvl(eei_information2,0) = nvl(p_leg_emp_id, 0)
AND rownum <=1;	 */
SELECT nvl((select eei_information1  from pay_element_type_extra_info petei
	    where petei.information_type='NO_ELEMENT_CODES'
	    and element_type_id = p_ele_type_id
	    and petei.eei_information2 = p_leg_emp_id
	    and rownum=1),
	   (select eei_information1  from pay_element_type_extra_info petei
	    where petei.information_type='NO_ELEMENT_CODES'
	    and element_type_id = p_ele_type_id
	    and eei_information2 is null
	    and rownum=1)) ele_code from dual;


rec_hdr_info		csr_get_hdr_info%ROWTYPE;
rec_ele_code		csr_ele_code%ROWTYPE;

-- Variable Declarations

l_count                 NUMBER := 0;
l_action_info_id        NUMBER;
l_ovn                   NUMBER;
l_actid                 NUMBER;
l_asgid                 NUMBER := -999;

l_archive               VARCHAR2(240);
l_payroll_id            NUMBER;

l_le_id                 NUMBER;
l_local_unit_id         NUMBER;
l_restr_econtr          VARCHAR2(80);
l_cost_seg              VARCHAR2(80);
l_ele_type_id           NUMBER;
l_ele_code              VARCHAR2(80);
-- Uncommenting for bug fix 6069852
--l_cost_value           	NUMBER;
l_eoy_code              VARCHAR2(80);

l_effective_date        DATE;
l_date_from             DATE;
l_date_to               DATE;
l_bg_id                 NUMBER;



BEGIN
--Hr_utility.trace_on(null,'PRR');
Hr_utility.trace('#-ASSIGNMENT_ACTION_CODE ');
IF g_debug THEN
      hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',10);
END IF;
Hr_utility.trace('#-Before fetching csr header details ');
Hr_utility.trace('#-p_payroll_action_id '|| p_payroll_action_id);
       -- Fetch Header details
	OPEN csr_get_hdr_info(p_payroll_action_id);
	FETCH csr_get_hdr_info INTO rec_hdr_info;
	CLOSE csr_get_hdr_info;
    Hr_utility.trace('#-rec_hdr_info.effective_date '|| rec_hdr_info.effective_date);
	l_effective_date := rec_hdr_info.effective_date;
    Hr_utility.trace('#-l_effective_date '|| l_effective_date);
	--
    Hr_utility.trace('#-rec_hdr_info.business_group_id '|| rec_hdr_info.business_group_id);
    l_bg_id          := rec_hdr_info.business_group_id;
    Hr_utility.trace('#-l_bg_id '|| l_bg_id);
    --
    Hr_utility.trace('#-rec_hdr_info.tax_unit_id '|| rec_hdr_info.tax_unit_id);
	l_le_id          := rec_hdr_info.tax_unit_id;
    Hr_utility.trace('#-l_le_id '|| l_le_id);
    --
    Hr_utility.trace('#-rec_hdr_info.from_date '|| rec_hdr_info.from_date);
	l_date_from      := rec_hdr_info.from_date;
    Hr_utility.trace('#-l_date_from '|| l_date_from);
    --
    Hr_utility.trace('#-rec_hdr_info.to_date '|| rec_hdr_info.to_date);
	l_date_to        := rec_hdr_info.to_date;
    Hr_utility.trace('#-l_date_to '|| l_date_to);
    --
    Hr_utility.trace('#-rec_hdr_info.payroll_id '|| rec_hdr_info.payroll_id);
	l_payroll_id     := rec_hdr_info.payroll_id;
    Hr_utility.trace('#-l_payroll_id '|| l_payroll_id);
    --
    Hr_utility.trace('#-rec_hdr_info.restr_econtr '|| rec_hdr_info.restr_econtr);
	l_restr_econtr   := rec_hdr_info.restr_econtr;
    Hr_utility.trace('#-l_restr_econtr '|| l_restr_econtr);
    --
    Hr_utility.trace('#-rec_hdr_info.cost_seg '|| rec_hdr_info.cost_seg);
	l_cost_seg       := rec_hdr_info.cost_seg;
    Hr_utility.trace('#-l_cost_seg '|| l_cost_seg);
    --
    Hr_utility.trace('#-rec_hdr_info.ele_type_id '|| rec_hdr_info.ele_type_id);
	l_ele_type_id    := rec_hdr_info.ele_type_id;
    Hr_utility.trace('#-l_ele_type_id '|| l_ele_type_id);
    --
    Hr_utility.trace('#-rec_hdr_info.eoy_code '|| rec_hdr_info.eoy_code);
	l_eoy_code       := rec_hdr_info.eoy_code;
    Hr_utility.trace('#-l_eoy_code '|| l_eoy_code);
    --
    Hr_utility.trace('#-Before fetching csr csr_get_lu_le ');
    Hr_utility.trace('#-with l_le_id '||l_le_id);
    Hr_utility.trace('#-with l_bg_id '||l_bg_id);
    --
	/* To fetch all Local Units belonging to the Legal Employer */
	FOR rec_get_lu_le IN csr_get_lu_le(l_le_id,l_bg_id)

	-- Fetch all Local Units belonging to the Legal Employer
	LOOP
    Hr_utility.trace('#-Rec found in csr_get_lu_le');
    Hr_utility.trace('#-rec_get_lu_le.lu_id '||rec_get_lu_le.lu_id);
	l_local_unit_id :=  rec_get_lu_le.lu_id;
    Hr_utility.trace('#-l_local_unit_id '||l_local_unit_id);

		-- Fetch Assignment's details for Detailed Report
        Hr_utility.trace('#-Before fetching csr csr_assignments ');
        Hr_utility.trace('#-with p_pay roll_action_id '||p_payroll_action_id);
        Hr_utility.trace('#-with l_payroll_id '||l_payroll_id);
        Hr_utility.trace('#-with p_start_person '||p_start_person);
        Hr_utility.trace('#-with p_end_person '||p_end_person);
        Hr_utility.trace('#-with l_restr_econtr '||l_restr_econtr);
        Hr_utility.trace('#-with l_cost_seg '||l_cost_seg);
        Hr_utility.trace('#-with l_ele_type_id '||l_ele_type_id);
        Hr_utility.trace('#-with l_eoy_code '||l_eoy_code);
        Hr_utility.trace('#-with l_bg_id '||l_bg_id);
        Hr_utility.trace('#-with l_date_from '||l_date_from);
        Hr_utility.trace('#-with l_date_to '||l_date_to);
        Hr_utility.trace('#-with l_local_unit_id '||l_local_unit_id);
        Hr_utility.trace('#-with l_effective_date '||l_effective_date);

		FOR csr_rec IN csr_assignments( p_payroll_action_id
					       ,l_payroll_id
					       ,p_start_person
					       ,p_end_person
					       ,l_restr_econtr
					       ,l_cost_seg
					       ,l_ele_type_id
					       ,l_eoy_code
					       ,l_bg_id
					       ,l_date_from
					       ,l_date_to
					       ,l_local_unit_id
					       ,l_effective_date )
		LOOP
        Hr_utility.trace('#-record found in csr csr_assignments ');
        Hr_utility.trace('#-p_pay roll_action_id '||p_payroll_action_id);
        Hr_utility.trace('#-l_payroll_id '||l_payroll_id);
        Hr_utility.trace('#-p_start_person '||p_start_person);
        Hr_utility.trace('#-p_end_person '||p_end_person);
        Hr_utility.trace('#-l_restr_econtr '||l_restr_econtr);
        Hr_utility.trace('#-l_cost_seg '||l_cost_seg);
        Hr_utility.trace('#-l_ele_type_id '||l_ele_type_id);
        Hr_utility.trace('#-l_eoy_code '||l_eoy_code);
        Hr_utility.trace('#-l_bg_id '||l_bg_id);
        Hr_utility.trace('#-l_date_from '||l_date_from);
        Hr_utility.trace('#-l_date_to '||l_date_to);
        Hr_utility.trace('#-l_local_unit_id '||l_local_unit_id);
        Hr_utility.trace('#-l_effective_date '||l_effective_date);

		/*Check for Change of Assignment ID to Create New Assignment Action ID
		 and for Archiving the data */
           Hr_utility.trace('#- get the next seq val');
			BEGIN
				SELECT pay_assignment_actions_s.NEXTVAL INTO l_actid FROM  dual;
			EXCEPTION
				WHEN OTHERS THEN
				NULL ;
			END ;
           Hr_utility.trace('#- l_actid '||l_actid);

		  -- Create the archive assignment action
          Hr_utility.trace('#- create asg act code');
          Hr_utility.trace('#- l_actid '||l_actid);
          Hr_utility.trace('#- csr_rec.asg_id '||csr_rec.asg_id);
          Hr_utility.trace('#- p_payroll_action_id '||p_payroll_action_id);
          Hr_utility.trace('#- p_chunk '||p_chunk);
		  hr_nonrun_asact.insact(l_actid ,csr_rec.asg_id ,p_payroll_action_id ,p_chunk,null);
          Hr_utility.trace('#- done with create asg act code');
          Hr_utility.trace('#- l_actid '||l_actid);
          Hr_utility.trace('#- csr_rec.asg_id '||csr_rec.asg_id);
          Hr_utility.trace('#- p_payroll_action_id '||p_payroll_action_id);
          Hr_utility.trace('#- p_chunk '||p_chunk);
            --
            Hr_utility.trace('#- going to fetch from csr csr_ele_code ');
            Hr_utility.trace('#- with csr_rec.ele_type_id' || csr_rec.ele_type_id );
            Hr_utility.trace('#- with l_le_id ' || l_le_id );
		    OPEN  csr_ele_code(csr_rec.ele_type_id,l_le_id);
		    FETCH csr_ele_code INTO rec_ele_code;
		    CLOSE csr_ele_code;
            Hr_utility.trace('#- record found in csr csr_ele_code ');
            --
            Hr_utility.trace('#- rec_ele_code.ele_code '||rec_ele_code.ele_code);
		    l_ele_code      := 	rec_ele_code.ele_code;
            Hr_utility.trace('#- l_ele_code '||l_ele_code);
            --
            Hr_utility.trace('#- csr_rec.costed_value '||csr_rec.costed_value);
            Hr_utility.trace('#- FND_NUMBER.NUMBER_TO_CANONICAL..csr_rec.costed_value '||FND_NUMBER.NUMBER_TO_CANONICAL(csr_rec.costed_value));
	    -- Uncommenting this part for bug fix 6069852
	    --l_cost_value := FND_NUMBER.NUMBER_TO_CANONICAL(csr_rec.costed_value);
            Hr_utility.trace('#- l_ele_code '||l_ele_code);
		    --
            Hr_utility.trace('#- l_eoy_code '||l_eoy_code);
            Hr_utility.trace('#- csr_rec.ele_type_id '||csr_rec.ele_type_id);
            Hr_utility.trace('#- csr_rec.effective_date '||csr_rec.effective_date);
            Hr_utility.trace('#- get_ele_code(csr_rec.ele_type_id, csr_rec.effective_date) '||get_ele_code(csr_rec.ele_type_id, csr_rec.effective_date));
            Hr_utility.trace('#- going to call if 1 ');
            IF (l_eoy_code IS NULL) OR
            (l_eoy_code = get_ele_code(csr_rec.ele_type_id, csr_rec.effective_date)) THEN
                -- Creating Initial Archive Entries
                Hr_utility.trace('#- qualified in if 1 ');
                Hr_utility.trace('#- archiving DETL ');
                --
                Hr_utility.set_location('#- l_action_info_id '|| l_action_info_id,21 );
                Hr_utility.set_location('#- l_ovn '|| l_ovn ,22);
                Hr_utility.set_location('#- l_actid '|| l_actid,23 );
                Hr_utility.set_location('#- l_effective_date '|| l_effective_date,24 );
                Hr_utility.set_location('#- csr_rec.asg_id '|| csr_rec.asg_id,25 );
                Hr_utility.set_location('#- l_le_id '|| l_le_id ,26);
                Hr_utility.set_location('#- csr_rec.payroll_name '|| csr_rec.payroll_name,27 );
                Hr_utility.set_location('#- p_payroll_action_id '|| p_payroll_action_id,28 );
                Hr_utility.set_location('#- csr_rec.assignment_number '|| csr_rec.assignment_number,29 );
                Hr_utility.set_location('#- l_local_unit_id '|| l_local_unit_id,30 );
                Hr_utility.set_location('#- csr_rec.ele_type_id '|| csr_rec.ele_type_id,31 );
                Hr_utility.set_location('#- csr_rec.ele_name '|| csr_rec.ele_name,32 );
                Hr_utility.set_location('#- int l_eoy_code '|| l_eoy_code,33 );
                Hr_utility.set_location('#- int csr_rec.ele_type_id '|| csr_rec.ele_type_id,34 );
                Hr_utility.set_location('#- int csr_rec.effective_date '|| csr_rec.effective_date,35 );
--                Hr_utility.trace('#- int csr_rec.effective_date '|| csr_rec.effective_date );
                Hr_utility.set_location('#- get_ele_code(csr_rec.ele_type_id, csr_rec.effective_date )) '|| get_ele_code(csr_rec.ele_type_id, csr_rec.effective_date ),36 );
                Hr_utility.set_location('#- csr_rec.ele_cost_seg '|| csr_rec.ele_cost_seg,37 );
                Hr_utility.set_location('#- csr_rec.cost_flex_id '|| csr_rec.cost_flex_id,38 );
                Hr_utility.set_location('#- csr_rec.debit_credit '|| csr_rec.debit_credit,39 );
                Hr_utility.set_location('#- l_ele_code '|| l_ele_code,40 );
                Hr_utility.set_location('#- csr_rec.costed_value '|| csr_rec.costed_value,41 );
                Hr_utility.set_location('#- csr_rec.cost_or_bal '|| csr_rec.cost_or_bal,42 );
                Hr_utility.set_location('#- csr_rec.effective_date '|| csr_rec.effective_date,43 );
                Hr_utility.set_location('#- csr_rec.emp_name '|| csr_rec.emp_name,44 );
                --
              pay_action_information_api.create_action_information
                (p_action_information_id        => l_action_info_id             -- OUT parameter
                ,p_object_version_number        => l_ovn                        -- OUT parameter
                ,p_action_context_id            => l_actid                      -- Context id = assignment action id (of Archive)
                ,p_action_context_type          => 'AAP'                        -- Context type
                ,p_effective_date               => l_effective_date             -- Date of running the archive
                ,p_assignment_id                => csr_rec.asg_id               -- Assignment ID
                ,p_action_information_category  => 'EMEA REPORT INFORMATION'    -- Information Category
                ,p_tax_unit_id                  => l_le_id                      -- Legal Employer ID
                ,p_jurisdiction_code            => NULL                         -- Tax Municipality ID
                ,p_action_information1          => 'PYNOPACCA'                  -- Con Program Short Name
                ,p_action_information2          => csr_rec.payroll_name         -- Payroll Name
                ,p_action_information3          => p_payroll_action_id          -- Payroll action id (of Archive)
                ,p_action_information4          => 'DETL'                       -- Specifies data is for Detail
                ,p_action_information5          => csr_rec.assignment_number    -- Assignment Number
                ,p_action_information6          => l_local_unit_id              -- Local Unit ID
                ,p_action_information7          => csr_rec.ele_type_id          -- Element Type ID
                ,p_action_information8          => csr_rec.ele_name             -- Element Name
                ,p_action_information9          => nvl(l_eoy_code,
                                                   get_ele_code(csr_rec.ele_type_id, csr_rec.effective_date )) -- Element EOY Code
                ,p_action_information10         => csr_rec.ele_cost_seg         -- Element Costing Flexfield Segments
                ,p_action_information11         => csr_rec.cost_flex_id         -- Costing Flexfield ID
                ,p_action_information12         => csr_rec.debit_credit         -- Debit or Credit Flag
                ,p_action_information13         => l_ele_code                   -- Element Code
                ,p_action_information14         => fnd_number.number_to_canonical(csr_rec.costed_value)         -- Individual Costing Value
                ,p_action_information15         => csr_rec.cost_or_bal          -- Cost or Balance Flag
                ,p_action_information16         => csr_rec.effective_date       -- Costing Effective Date
                ,p_action_information17         => csr_rec.emp_name             -- Employee Name
                );
                Hr_utility.trace('#- archived DETL successfully');
              END IF;
              Hr_utility.trace('#- qualified in end if 1 ');
              --
              Hr_utility.trace('#- csr_rec.asg_id '||csr_rec.asg_id);
		l_asgid := csr_rec.asg_id;
        Hr_utility.trace('#- l_asgid '||l_asgid);

		END LOOP; -- csr_assignments
        Hr_utility.trace('#- end of loop csr_assignments ');

	END LOOP; -- csr_get_lu_le
    Hr_utility.trace('#- end of loop csr_get_lu_le ');

IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',20);
END IF;
Hr_utility.trace('#- end of ASSIGNMENT_ACTION_CODE');
END ASSIGNMENT_ACTION_CODE;


PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
IS


BEGIN

NULL;

IF g_debug THEN
   hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',10);
END IF;

IF g_debug THEN
  hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',20);
END IF;

EXCEPTION WHEN OTHERS THEN
g_err_num := SQLCODE;

IF g_debug THEN
 hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In INITIALIZATION_CODE',30);
END IF;

END INITIALIZATION_CODE;


PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
                      ,p_effective_date       IN DATE)
IS

BEGIN
 IF g_debug THEN
    hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',10);
 END IF;

 IF g_debug THEN
    hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',20);
 END IF;

END ARCHIVE_CODE;


PROCEDURE DEINITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
IS

CURSOR csr_costing_summary(p_payroll_action_id	NUMBER ) IS
SELECT   to_number(action_information7)  	element_type_id
		,action_information8			element_name
		,action_information9			eoy_code
		,action_information10			concatenated_segments
		,to_number(action_information11)	cost_allocation_keyflex_id
		,action_information12			debit_or_credit
		,sum(fnd_number.canonical_to_number(action_information14))	costed_value
		,action_information15			balance_or_cost
		,tax_unit_id                            leg_emp_id
		,to_number(action_information6)		local_unit_id
		,effective_date
FROM pay_action_information pai
WHERE action_context_type = 'AAP'
AND action_information3 = to_char(p_payroll_action_id)
AND action_information_category = 'EMEA REPORT INFORMATION'
AND action_information1 = 'PYNOPACCA'
AND action_information4 = 'DETL'
GROUP BY action_information10
,action_information11
,action_information9
,action_information7
,action_information8
,action_information15
,action_information12
,tax_unit_id
,action_information6
,effective_date;

-- Cursor to get Element Code
-- Modified for bug fix 5239796
CURSOR csr_ele_code(p_ele_type_id  NUMBER
		   ,p_leg_emp_id NUMBER) IS
/*SELECT eei_information1  ele_code
FROM pay_element_type_extra_info petei
WHERE information_type='NO_ELEMENT_CODES'
AND nvl(element_type_id,0) = p_ele_type_id
AND nvl(eei_information2,0) = nvl(p_leg_emp_id, 0)
AND rownum <=1;	*/
SELECT nvl((select eei_information1  from pay_element_type_extra_info petei
	    where petei.information_type='NO_ELEMENT_CODES'
	    and element_type_id = p_ele_type_id
	    and petei.eei_information2 = p_leg_emp_id
	    and rownum=1),
	   (select eei_information1  from pay_element_type_extra_info petei
	    where petei.information_type='NO_ELEMENT_CODES'
	    and element_type_id = p_ele_type_id
	    and eei_information2 is null
	    and rownum=1))  ele_code from dual;

-- Variable Declarations

l_ele_type_id           NUMBER;
l_ele_name              VARCHAR2(80);
l_ele_eoy_code          VARCHAR2(80);
l_ele_cost_seg          VARCHAR2(80);
l_cost_flex_id          NUMBER;
l_debit_credit          VARCHAR2(80);
l_sum_cost_value        VARCHAR2(80);
l_cost_or_bal           VARCHAR2(80);
l_ele_code              VARCHAR2(80);
l_le_id                 NUMBER;
l_local_unit_id         NUMBER;
l_effective_date        DATE;
l_action_info_id        NUMBER;
l_ovn                   NUMBER;
l_business_group_id     NUMBER;
l_payroll_id            NUMBER;
rec_ele_code		csr_ele_code%ROWTYPE;
BEGIN

IF g_debug THEN
   hr_utility.set_location(' Entering Procedure DEINITIALIZATION_CODE',10);
END IF;

     -- Fetch Summary of Detailed Costing Information
     FOR  rec_costing_summary IN  csr_costing_summary(p_payroll_action_id)
     LOOP
	    l_ele_type_id    :=  rec_costing_summary.element_type_id;
	    l_ele_name       :=  rec_costing_summary.element_name;
	    l_ele_eoy_code   :=  rec_costing_summary.eoy_code;
	    l_ele_cost_seg   :=  rec_costing_summary.concatenated_segments;
	    l_cost_flex_id   :=  rec_costing_summary.cost_allocation_keyflex_id;
	    l_debit_credit   :=  rec_costing_summary.debit_or_credit;
--	    l_sum_cost_value :=	 rec_costing_summary.costed_value; --not reqd
	    l_cost_or_bal    :=  rec_costing_summary.balance_or_cost;
	    l_le_id          :=	 rec_costing_summary.leg_emp_id;
	    l_effective_date :=  rec_costing_summary.effective_date;
	    OPEN  csr_ele_code(l_ele_type_id,l_le_id);
	    FETCH csr_ele_code INTO rec_ele_code;
	    CLOSE csr_ele_code;
	    l_ele_code      := 	rec_ele_code.ele_code;
	    l_sum_cost_value := fnd_number.number_to_canonical(rec_costing_summary.costed_value);
		  -- Archive the SUMMARY REPORT DETAILS
		pay_action_information_api.create_action_information
		(p_action_information_id        => l_action_info_id             -- out parameter
		,p_object_version_number        => l_ovn                        -- out parameter
		,p_action_context_id            => p_payroll_action_id          -- context id = payroll action id (of Archive)
		,p_action_context_type          => 'PA'                         -- context type
		,p_effective_date               => l_effective_date             -- Date of Running the Archive
		,p_action_information_category  => 'EMEA REPORT DETAILS'        -- Information Category
		,p_tax_unit_id                  => l_le_id                      -- Legal Employer ID
		,p_jurisdiction_code            => NULL                         -- Tax Municipality ID
		,p_action_information1          => 'PYNOPACCA'                  -- Conc Prg Short Name
		,p_action_information2          => l_business_group_id          -- Business Group ID
		,p_action_information3          => l_payroll_id                 -- Payroll ID
		,p_action_information4          => 'SUMM'                       -- Specifies data is for Summary
		,p_action_information5          => l_local_unit_id              -- Local Unit ID
		,p_action_information6          => l_ele_type_id                -- Element Type ID
		,p_action_information7          => l_ele_name                   -- Element Name
		,p_action_information8          => l_ele_eoy_code               -- Element EOY Code
		,p_action_information9          => l_ele_cost_seg               -- Element Costing Flexfield Segments
		,p_action_information10         => l_cost_flex_id               -- Costing Flexfield ID
		,p_action_information11         => l_debit_credit               -- Debit or Credit Flag
		,p_action_information12         => l_ele_code                   -- Element Code
		,p_action_information13         => l_sum_cost_value             -- Total Costing Value
		,p_action_information14         => l_cost_or_bal                -- Cost or Balance Flag
		);
    Hr_utility.set_location('#- l_business_group_id '|| l_business_group_id,45 );
    Hr_utility.set_location('#- l_payroll_id '|| l_payroll_id,46 );
    Hr_utility.set_location('#- l_local_unit_id '|| l_local_unit_id,47 );
    Hr_utility.set_location('#- l_ele_type_id '|| l_ele_type_id,48 );
    Hr_utility.set_location('#- l_ele_name '|| l_ele_name,49 );
    Hr_utility.set_location('#- l_ele_eoy_code '|| l_ele_eoy_code,50 );
    Hr_utility.set_location('#- l_ele_cost_seg '|| l_ele_cost_seg,51 );
    Hr_utility.set_location('#- l_cost_flex_id '|| l_cost_flex_id,52 );
    Hr_utility.set_location('#- l_debit_credit '|| l_debit_credit,53 );
    Hr_utility.set_location('#- l_ele_code '|| l_ele_code,54 );
    Hr_utility.set_location('#- l_sum_cost_value '|| l_sum_cost_value,55 );
    Hr_utility.set_location('#- l_cost_or_bal '|| l_cost_or_bal,56 );

    END LOOP; --csr_costing_summary

IF g_debug THEN
  hr_utility.set_location(' Leaving Procedure DEINITIALIZATION_CODE',20);
END IF;

EXCEPTION WHEN OTHERS THEN
g_err_num := SQLCODE;

IF g_debug THEN
 hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In DEINITIALIZATION_CODE',30);
END IF;

END DEINITIALIZATION_CODE;


PROCEDURE POPULATE_DATA_SUMMARY
        (p_business_group_id     IN NUMBER,
         p_payroll_action_id     IN VARCHAR2 ,
         p_template_name         IN VARCHAR2,
         p_xml                   OUT NOCOPY CLOB)
IS


/* Cursor to fetch Header Information */
CURSOR csr_get_hdr_info(p_payroll_action_id NUMBER)
IS
SELECT *
FROM pay_action_information pai
WHERE action_context_type = 'PA'
AND action_context_id  = p_payroll_action_id
AND action_information_category = 'EMEA REPORT DETAILS'
AND action_information1 = 'PYNOPACCA'
AND action_information4 = 'HDR';

/* Cursor to fetch Costing Summary Information */
CURSOR csr_get_summ_info(p_payroll_action_id NUMBER, p_tax_unit_id NUMBER)
IS
SELECT *
FROM pay_action_information pai
WHERE action_context_type = 'PA'
AND action_context_id  = p_payroll_action_id
AND action_information_category = 'EMEA REPORT DETAILS'
AND action_information1 = 'PYNOPACCA'
AND tax_unit_id = p_tax_unit_id
AND action_information4 = 'SUMM';
/*
ORDER BY action_information9
,action_information8
,action_information7
,action_information14
,action_information11;
*/

rec_get_hdr_info csr_get_hdr_info%ROWTYPE;

l_counter             NUMBER := 0;
l_count               NUMBER := 0;
l_payroll_action_id   NUMBER;

l_prev_cost_seg       VARCHAR2(80) := ' ';
l_prev_eoy_code       VARCHAR2(80) := ' ';
l_total_cost_credit   NUMBER       := 0;
l_total_cost_debit    NUMBER       := 0;

--Added for bug fix 5244886
l_total_net_credit   NUMBER       := 0;
l_total_net_debit    NUMBER       := 0;

BEGIN
--
IF p_payroll_action_id  IS NULL THEN
  BEGIN
    SELECT payroll_action_id
    INTO  l_payroll_action_id
    FROM pay_payroll_actions ppa,
    fnd_conc_req_summary_v fcrs,
    fnd_conc_req_summary_v fcrs1
    WHERE  fcrs.request_id = fnd_global.conc_request_id
    AND fcrs.priority_request_id = fcrs1.priority_request_id
    AND ppa.request_id between fcrs1.request_id  and fcrs.request_id
    AND ppa.request_id = fcrs1.request_id;
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END ;
ELSE
  l_payroll_action_id  := p_payroll_action_id;
END IF;
--
hr_utility.set_location('Entered Procedure GETDATA',10);
--
/* Get the File Header Information */
OPEN csr_get_hdr_info(l_payroll_action_id);
FETCH csr_get_hdr_info INTO rec_get_hdr_info;
CLOSE csr_get_hdr_info;
--
hr_utility.set_location('Before populating pl/sql table',20);
--
xml_tab(l_counter).TagName  :='FILE_HEADER_START';
xml_tab(l_counter).TagValue :='FILE_HEADER_START';
l_counter := l_counter + 1;
--
hr_utility.set_location('LE_NAME'||rec_get_hdr_info.action_information7,21);
xml_tab(l_counter).TagName  :='LE_NAME';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information7;
l_counter := l_counter + 1;
--
hr_utility.set_location('LE_ORG_NO'||rec_get_hdr_info.action_information8,22);
xml_tab(l_counter).TagName  :='LE_ORG_NO';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information8;
l_counter := l_counter + 1;
--
hr_utility.set_location('REPORT_START_DATE'||rec_get_hdr_info.action_information12,23);
xml_tab(l_counter).TagName  :='REPORT_START_DATE';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information12;
l_counter := l_counter + 1;
--
hr_utility.set_location('REPORT_END_DATE'||rec_get_hdr_info.action_information13,24);
xml_tab(l_counter).TagName  :='REPORT_END_DATE';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information13;
l_counter := l_counter + 1;
--
hr_utility.set_location('PARAM_COST_SEG'||rec_get_hdr_info.action_information9,25);
xml_tab(l_counter).TagName  :='PARAM_COST_SEG';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information9;
l_counter := l_counter + 1;
--
hr_utility.set_location('PARAM_EOY_CODE'||rec_get_hdr_info.action_information10,26);
xml_tab(l_counter).TagName  :='PARAM_EOY_CODE';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information10;
l_counter := l_counter + 1;
--
hr_utility.set_location('PARAM_RESTR_ECONTR'||rec_get_hdr_info.action_information14,27);
xml_tab(l_counter).TagName  :='PARAM_RESTR_ECONTR';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information14;
l_counter := l_counter + 1;
--
hr_utility.set_location('PARAM_PAYROLL_NAME'||rec_get_hdr_info.action_information15,28);
xml_tab(l_counter).TagName  :='PARAM_PAYROLL_NAME';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information15;
l_counter := l_counter + 1;
--
hr_utility.set_location('PARAM_ELE_NAME'||rec_get_hdr_info.action_information16,29);
xml_tab(l_counter).TagName  :='PARAM_ELE_NAME';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information16;
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='COST_RECO_START';
xml_tab(l_counter).TagValue :='COST_RECO_START';
l_counter := l_counter + 1;
--
hr_utility.set_location('FOR LOOP STARTING csr_get_summ_info',31);
FOR rec_get_summ_info IN csr_get_summ_info(l_payroll_action_id,rec_get_hdr_info.tax_unit_id)
LOOP
  /* Counter to count records fetched */
  l_count :=  l_count + 1 ;
  /*Check cost_seg for grouping */
  hr_utility.set_location('Record found',32);
  hr_utility.set_location('l_count'||l_count,32);
  hr_utility.set_location('l_prev_cost_seg'||l_prev_cost_seg,33);
  hr_utility.set_location('rec_get_summ_info.action_information9'||rec_get_summ_info.action_information9,34);
  --
	IF(l_count = 1  OR rec_get_summ_info.action_information9 <> l_prev_cost_seg ) THEN
    IF(l_count <> 1) THEN
		  xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
			xml_tab(l_counter).TagValue :='EOY_CODE_GRP_END';
			l_counter := l_counter + 1;
      --
      hr_utility.set_location('l_total_cost_credit'||l_total_cost_credit,34);
      hr_utility.set_location('l_total_cost_credit'||l_total_cost_credit,35);
      --
			IF( l_total_cost_credit <> 0 ) THEN
			  xml_tab(l_counter).TagName  :='COST_SEG_GRP_TOT_CREDIT';
			  xml_tab(l_counter).TagValue := l_total_cost_credit;
			  l_counter := l_counter + 1;
			END IF;

			IF( l_total_cost_debit <> 0 ) THEN
        xml_tab(l_counter).TagName  :='COST_SEG_GRP_TOT_DEBIT';
        xml_tab(l_counter).TagValue := l_total_cost_debit;
        l_counter := l_counter + 1;
			END IF;

			-- Added for bug fix 5244886
			l_total_net_credit := GREATEST(l_total_cost_credit - l_total_cost_debit,0);
			l_total_net_debit := GREATEST(l_total_cost_debit - l_total_cost_credit,0);
      hr_utility.set_location('l_total_net_credit'||l_total_net_credit,35);
			IF( l_total_net_credit <> 0 ) THEN
        xml_tab(l_counter).TagName  :='COST_SEG_NET_TOT_CREDIT';
        xml_tab(l_counter).TagValue := l_total_net_credit;
        l_counter := l_counter + 1;
			END IF;
      hr_utility.set_location('l_total_net_debit'||l_total_net_debit,35);
			IF( l_total_net_debit <> 0 ) THEN
        xml_tab(l_counter).TagName  :='COST_SEG_NET_TOT_DEBIT';
        xml_tab(l_counter).TagValue := l_total_net_debit;
        l_counter := l_counter + 1;
			END IF;
			-- End of bug fix 5244886
			xml_tab(l_counter).TagName  :='COST_SEG_GRP_START';
			xml_tab(l_counter).TagValue :='COST_SEG_GRP_END';
			l_counter := l_counter + 1;
		END IF;
    --
		l_total_cost_credit :=0;
		l_total_cost_debit :=0;
		--Added for bug fix 5244886
		l_total_net_credit :=0;
		l_total_net_debit :=0;
    --
		xml_tab(l_counter).TagName  :='COST_SEG_GRP_START';
		xml_tab(l_counter).TagValue :='COST_SEG_GRP_START';
		l_counter := l_counter + 1;
    --
		xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
		xml_tab(l_counter).TagValue :='EOY_CODE_GRP_START';
		l_counter := l_counter + 1;
    --
		/*Check eoy_code for grouping if no change in cost segments */
	ELSIF( l_count = 1 OR rec_get_summ_info.action_information8 <> l_prev_eoy_code ) THEN
    hr_utility.set_location('ELSIF',36);
    hr_utility.set_location('l_count'||l_count,37);
		IF(l_count <> 1) THEN
			xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
			xml_tab(l_counter).TagValue :='EOY_CODE_GRP_END';
			l_counter := l_counter + 1;
		END IF;
  	xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
		xml_tab(l_counter).TagValue :='EOY_CODE_GRP_START';
		l_counter := l_counter + 1;
	END IF;
	--
	xml_tab(l_counter).TagName  :='COSTING_START';
	xml_tab(l_counter).TagValue :='COSTING_START';
	l_counter := l_counter + 1;

	-- Suppress same Cost Flexfield value appearing in a group
  hr_utility.set_location('l_count'||l_count,38);
  hr_utility.set_location('rec_get_summ_info.action_information9'||rec_get_summ_info.action_information9,39);
  hr_utility.set_location('l_prev_cost_seg'||l_prev_cost_seg,40);
	IF( l_count = 1 OR rec_get_summ_info.action_information9 <> l_prev_cost_seg ) THEN
		xml_tab(l_counter).TagName  :='COST_SEG';
		xml_tab(l_counter).TagValue := rec_get_summ_info.action_information9;
		l_counter := l_counter + 1;
  END IF;
  --
  hr_utility.set_location('EOY_CODE'||rec_get_summ_info.action_information8,41);
	xml_tab(l_counter).TagName  :='EOY_CODE';
	xml_tab(l_counter).TagValue := rec_get_summ_info.action_information8;
	l_counter := l_counter + 1;
  --
  hr_utility.set_location('ELE_CODE'||rec_get_summ_info.action_information12,42);
	xml_tab(l_counter).TagName  :='ELE_CODE';
	xml_tab(l_counter).TagValue := rec_get_summ_info.action_information12;
	--
  IF( rec_get_summ_info.action_information12 IS NOT NULL) THEN
  	xml_tab(l_counter).TagValue := ' ,' ||xml_tab(l_counter).TagValue;
	END IF;
	l_counter := l_counter + 1;
  --
  hr_utility.set_location('ELE_NAME'||rec_get_summ_info.action_information7,43);
	xml_tab(l_counter).TagName  :='ELE_NAME';
	xml_tab(l_counter).TagValue := rec_get_summ_info.action_information7;
	l_counter := l_counter + 1;
  --
  hr_utility.set_location('COST_OR_BAL'||rec_get_summ_info.action_information14,44);
	xml_tab(l_counter).TagName  :='COST_OR_BAL';
	xml_tab(l_counter).TagValue :=rec_get_summ_info.action_information14;
	l_counter := l_counter + 1;
  --
  hr_utility.set_location('COST_DEBIT/COST_CREDIT'||fnd_number.canonical_to_number(rec_get_summ_info.action_information13),45);
  hr_utility.set_location('C/D'||rec_get_summ_info.action_information11,46);
	IF( rec_get_summ_info.action_information11 = 'D') THEN
		xml_tab(l_counter).TagName  :='COST_DEBIT';
		xml_tab(l_counter).TagValue := fnd_number.canonical_to_number(rec_get_summ_info.action_information13);
		l_counter := l_counter + 1;
  	l_total_cost_debit := l_total_cost_debit + fnd_number.canonical_to_number(rec_get_summ_info.action_information13);
	ELSIF( rec_get_summ_info.action_information11 ='C') THEN
		xml_tab(l_counter).TagName  :='COST_CREDIT';
		xml_tab(l_counter).TagValue := fnd_number.canonical_to_number(rec_get_summ_info.action_information13);
		l_counter := l_counter + 1;
  	l_total_cost_credit := l_total_cost_credit + fnd_number.canonical_to_number(rec_get_summ_info.action_information13);
  END IF;
  --
  xml_tab(l_counter).TagName  :='COSTING_START';
	xml_tab(l_counter).TagValue :='COSTING_END';
	l_counter := l_counter + 1;
  --
  l_prev_eoy_code := rec_get_summ_info.action_information8;
	l_prev_cost_seg :=  rec_get_summ_info.action_information9;
  --
END LOOP;
hr_utility.set_location('END LOOP',47);
hr_utility.set_location('l_count'||l_count,48);
IF(l_count = 0) THEN
  xml_tab(l_counter).TagName  :='COST_SEG_GRP_START';
  xml_tab(l_counter).TagValue :='COST_SEG_GRP_START';
  l_counter := l_counter + 1;
  --
  xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
  xml_tab(l_counter).TagValue :='EOY_CODE_GRP_START';
  l_counter := l_counter + 1;
--
END IF;
--
xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
xml_tab(l_counter).TagValue :='EOY_CODE_GRP_END';
l_counter := l_counter + 1;
hr_utility.set_location('l_total_cost_credit'||l_total_cost_credit,49);
IF ( l_total_cost_credit <> 0 ) THEN
	xml_tab(l_counter).TagName  :='COST_SEG_GRP_TOT_CREDIT';
	xml_tab(l_counter).TagValue := l_total_cost_credit;
	l_counter := l_counter + 1;
END IF;
hr_utility.set_location('l_total_cost_debit'||l_total_cost_debit,51);
IF ( l_total_cost_debit <> 0 ) THEN
  xml_tab(l_counter).TagName  :='COST_SEG_GRP_TOT_DEBIT';
	xml_tab(l_counter).TagValue := l_total_cost_debit;
	l_counter := l_counter + 1;
END IF;

-- Added for bug fix 5244886
l_total_net_credit := GREATEST(l_total_cost_credit - l_total_cost_debit,0);
l_total_net_debit := GREATEST(l_total_cost_debit - l_total_cost_credit,0);
hr_utility.set_location('l_total_cost_debit'||l_total_cost_debit,51);
IF( l_total_net_credit <> 0 ) THEN
  xml_tab(l_counter).TagName  :='COST_SEG_NET_TOT_CREDIT';
  xml_tab(l_counter).TagValue := l_total_net_credit;
  l_counter := l_counter + 1;
END IF;
hr_utility.set_location('l_total_net_debit'||l_total_net_debit,52);
IF( l_total_net_debit <> 0 ) THEN
	xml_tab(l_counter).TagName  :='COST_SEG_NET_TOT_DEBIT';
	xml_tab(l_counter).TagValue := l_total_net_debit;
	l_counter := l_counter + 1;
END IF;
-- End of bug fix 5244886
xml_tab(l_counter).TagName  :='COST_SEG_GRP_START';
xml_tab(l_counter).TagValue :='COST_SEG_GRP_END';
l_counter := l_counter + 1;

xml_tab(l_counter).TagName  :='COST_RECO_START';
xml_tab(l_counter).TagValue :='COST_RECO_END';
l_counter := l_counter + 1;

xml_tab(l_counter).TagName  :='FILE_HEADER_START';
xml_tab(l_counter).TagValue :='FILE_HEADER_END';
l_counter := l_counter + 1;

hr_utility.set_location('After populating pl/sql table',30);
hr_utility.set_location('Entered Procedure GETDATA',10);

WritetoCLOB (p_xml );

END POPULATE_DATA_SUMMARY;
--
--
--
PROCEDURE POPULATE_DATA_DETAIL
        (p_business_group_id     IN NUMBER,
         p_payroll_action_id     IN VARCHAR2 ,
         p_template_name         IN VARCHAR2,
         p_xml                   OUT NOCOPY CLOB)
IS


/* Cursor to fetch Header Information */
CURSOR csr_get_hdr_info(p_payroll_action_id NUMBER)
IS
SELECT *
FROM pay_action_information pai
WHERE action_context_type = 'PA'
AND action_context_id  = p_payroll_action_id
AND action_information_category = 'EMEA REPORT DETAILS'
AND action_information1 = 'PYNOPACCA'
AND action_information4 = 'HDR';


/* Cursors to fetch Costing Detail Information */
CURSOR csr_get_det_info(p_payroll_action_id NUMBER, p_tax_unit_id NUMBER)
IS
SELECT   action_information7		--ELE_TYPE_ID
	,action_information8		--ELE_NAME
	,action_information9		--ELE_EOY_CODE
	,assignment_id			--ASSIGNMENT_ID
	,action_information5		--ASSIGNMENT_NUMBER
	,action_information2		--PAYROLL_NAME
	,action_information10		--ELE_COST_SEG
	,action_information11		--COST_FLEX_ID
	,action_information12		--DEBIT_CREDIT
	,action_information14		--COSTED_VALUE
	,effective_date			--EFFECTIVE_DATE
	,action_information15 		--COST_OR_BAL
	,action_information13           --ELE_CODE
	,action_information16           --COST_EFFECTIVE_DATE
	,action_information17           --EMP_NAME
FROM pay_action_information pai
WHERE action_context_type = 'AAP'
AND action_information3 = to_char(p_payroll_action_id)
AND action_information_category = 'EMEA REPORT INFORMATION'
AND action_information1 = 'PYNOPACCA'
AND tax_unit_id = p_tax_unit_id
AND action_information4 = 'DETL'
ORDER BY action_information10
,action_information9
,action_information8
,action_information15
,action_information12
,action_information5
,fnd_date.date_to_canonical(action_information16)
,fnd_number.canonical_to_number(action_information14)
,effective_date;


rec_get_hdr_info csr_get_hdr_info%ROWTYPE;

l_counter             NUMBER := 0;
l_count               NUMBER := 0;
l_payroll_action_id   NUMBER;

l_prev_cost_seg       VARCHAR2(80) := ' ';
l_prev_eoy_code       VARCHAR2(80) := ' ';
l_total_cost_credit   NUMBER       := 0;
l_total_cost_debit    NUMBER       := 0;


BEGIN
--
IF p_payroll_action_id  IS NULL THEN
  --
  BEGIN
    SELECT payroll_action_id
    INTO  l_payroll_action_id
    FROM pay_payroll_actions ppa,
    fnd_conc_req_summary_v fcrs,
    fnd_conc_req_summary_v fcrs1
    WHERE  fcrs.request_id = fnd_global.conc_request_id
    AND fcrs.priority_request_id = fcrs1.priority_request_id
    AND ppa.request_id between fcrs1.request_id  and fcrs.request_id
    AND ppa.request_id = fcrs1.request_id;
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END ;
  --
ELSE
  l_payroll_action_id  := p_payroll_action_id;
END IF;
hr_utility.set_location('Entered Procedure GETDATA',10);
--
/* Get the File Header Information */
OPEN csr_get_hdr_info(l_payroll_action_id);
FETCH csr_get_hdr_info INTO rec_get_hdr_info;
CLOSE csr_get_hdr_info;
--
hr_utility.set_location('Before populating pl/sql table',20);
--
xml_tab(l_counter).TagName  :='FILE_HEADER_START';
xml_tab(l_counter).TagValue :='FILE_HEADER_START';
l_counter := l_counter + 1;
--
hr_utility.set_location('LE_NAME'||rec_get_hdr_info.action_information7,53);
xml_tab(l_counter).TagName  :='LE_NAME';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information7;
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='LE_ORG_NO';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information8;
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='REPORT_START_DATE';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information12;
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='REPORT_END_DATE';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information13;
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='PARAM_COST_SEG';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information9;
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='PARAM_EOY_CODE';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information10;
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='PARAM_RESTR_ECONTR';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information14;
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='PARAM_PAYROLL_NAME';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information15;
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='PARAM_ELE_NAME';
xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information16;
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='COST_RECO_START';
xml_tab(l_counter).TagValue :='COST_RECO_START';
l_counter := l_counter + 1;
hr_utility.set_location('HEADER INFO DONE',54);
--
hr_utility.set_location('CSR csr_get_det_info',55);
FOR rec_get_det_info IN csr_get_det_info(l_payroll_action_id,rec_get_hdr_info.tax_unit_id)
LOOP
--
  /* Counter to count records fetched */
  hr_utility.set_location('record found csr_get_det_info',56);
  hr_utility.set_location('l_count'||l_count,57);
	l_count :=  l_count + 1 ;
	/*Check cost_seg for grouping */
  hr_utility.set_location('rec_get_det_info.action_information10'||rec_get_det_info.action_information10,58);
  hr_utility.set_location('l_prev_cost_seg'||l_prev_cost_seg,59);
	IF(l_count = 1  OR rec_get_det_info.action_information10 <> l_prev_cost_seg ) THEN
  --
    IF(l_count <> 1) THEN
      xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
      xml_tab(l_counter).TagValue :='EOY_CODE_GRP_END';
      l_counter := l_counter + 1;
      --
        hr_utility.set_location('l_total_cost_credit'||l_total_cost_credit,61);
      IF( l_total_cost_credit <> 0 ) THEN
        xml_tab(l_counter).TagName  :='COST_SEG_GRP_TOT_CREDIT';
        xml_tab(l_counter).TagValue := l_total_cost_credit;
        l_counter := l_counter + 1;
      END IF;
      --
        hr_utility.set_location('l_total_cost_debit'||l_total_cost_debit,62);
      IF( l_total_cost_debit <> 0 ) THEN
        xml_tab(l_counter).TagName  :='COST_SEG_GRP_TOT_DEBIT';
        xml_tab(l_counter).TagValue := l_total_cost_debit;
        l_counter := l_counter + 1;
      END IF;
      --
      xml_tab(l_counter).TagName  :='COST_SEG_GRP_START';
      xml_tab(l_counter).TagValue :='COST_SEG_GRP_END';
      l_counter := l_counter + 1;
		END IF;
    --
		l_total_cost_credit :=0;
		l_total_cost_debit :=0;
    --
		xml_tab(l_counter).TagName  :='COST_SEG_GRP_START';
		xml_tab(l_counter).TagValue :='COST_SEG_GRP_START';
		l_counter := l_counter + 1;
    --
		xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
		xml_tab(l_counter).TagValue :='EOY_CODE_GRP_START';
		l_counter := l_counter + 1;
		/*Check eoy_code for grouping if no change in cost segments */
  ELSIF( l_count = 1  OR rec_get_det_info.action_information9 <> l_prev_eoy_code ) THEN
	  --
    hr_utility.set_location('ELSIF',63);
    hr_utility.set_location('l_count'||l_count,64);
		IF(l_count <> 1) THEN
		  xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
		  xml_tab(l_counter).TagValue :='EOY_CODE_GRP_END';
		  l_counter := l_counter + 1;
		END IF;
    --
		xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
		xml_tab(l_counter).TagValue :='EOY_CODE_GRP_START';
		l_counter := l_counter + 1;
  --
	END IF;
  --
  xml_tab(l_counter).TagName  :='COSTING_START';
	xml_tab(l_counter).TagValue :='COSTING_START';
	l_counter := l_counter + 1;
	-- Suppress same Cost Flexfield value appearing in a group
  hr_utility.set_location('l_count'||l_count,65);
  hr_utility.set_location('rec_get_det_info.action_information10'||rec_get_det_info.action_information10,66);
  hr_utility.set_location('l_prev_cost_seg'||l_prev_cost_seg,67);
	IF( l_count = 1 OR rec_get_det_info.action_information10 <> l_prev_cost_seg  ) THEN
		xml_tab(l_counter).TagName  :='COST_SEG';
		xml_tab(l_counter).TagValue := rec_get_det_info.action_information10;
		l_counter := l_counter + 1;
	END IF;
  --
  hr_utility.set_location('EOY_CODE'||rec_get_det_info.action_information9,68);
	xml_tab(l_counter).TagName  :='EOY_CODE';
	xml_tab(l_counter).TagValue := rec_get_det_info.action_information9;
	l_counter := l_counter + 1;
  --
  hr_utility.set_location('ELE_CODE'||rec_get_det_info.action_information13,69);
	xml_tab(l_counter).TagName  :='ELE_CODE';
	xml_tab(l_counter).TagValue := rec_get_det_info.action_information13;
	--
  hr_utility.set_location('rec_get_det_info.action_information13'||rec_get_det_info.action_information13,71);
  IF( rec_get_det_info.action_information13 IS NOT NULL) THEN
	  xml_tab(l_counter).TagValue := ' ,' ||xml_tab(l_counter).TagValue;
	END IF;
	l_counter := l_counter + 1;
  --
  hr_utility.set_location('ELE_NAME'||rec_get_det_info.action_information8,72);
	xml_tab(l_counter).TagName  :='ELE_NAME';
	xml_tab(l_counter).TagValue := rec_get_det_info.action_information8;
	l_counter := l_counter + 1;
  --
  hr_utility.set_location('ASSG_NO'||rec_get_det_info.action_information5,73);
	xml_tab(l_counter).TagName  :='ASSG_NO';
	xml_tab(l_counter).TagValue := rec_get_det_info.action_information5;
	l_counter := l_counter + 1;
  --
  hr_utility.set_location('EMP_NAME'||rec_get_det_info.action_information17,74);
	xml_tab(l_counter).TagName  :='EMP_NAME';
	xml_tab(l_counter).TagValue := rec_get_det_info.action_information17;
	l_counter := l_counter + 1;
  --
  hr_utility.set_location('COST_OR_BAL'||rec_get_det_info.action_information15,75);
	xml_tab(l_counter).TagName  :='COST_OR_BAL';
	xml_tab(l_counter).TagValue := rec_get_det_info.action_information15;
	l_counter := l_counter + 1;
  --
  hr_utility.set_location('COST_DEBIT/COST_CREDIT'||fnd_number.canonical_to_number(rec_get_det_info.action_information14),76);
  hr_utility.set_location('C/D'||rec_get_det_info.action_information12,77);
	IF( rec_get_det_info.action_information12 = 'D') THEN
		xml_tab(l_counter).TagName  :='COST_DEBIT';
		xml_tab(l_counter).TagValue := fnd_number.canonical_to_number(rec_get_det_info.action_information14);
		l_counter := l_counter + 1;
		l_total_cost_debit := l_total_cost_debit + fnd_number.canonical_to_number(rec_get_det_info.action_information14);
	ELSIF( rec_get_det_info.action_information12 ='C') THEN
  	xml_tab(l_counter).TagName  :='COST_CREDIT';
		xml_tab(l_counter).TagValue := fnd_number.canonical_to_number(rec_get_det_info.action_information14);
		l_counter := l_counter + 1;
		l_total_cost_credit := l_total_cost_credit + fnd_number.canonical_to_number(rec_get_det_info.action_information14);
	END IF;
  hr_utility.set_location('l_total_cost_debit'||l_total_cost_debit,78);
  hr_utility.set_location('l_total_cost_credit'||l_total_cost_credit,79);
  --
  hr_utility.set_location('COST_EFF_DATE'||rec_get_det_info.action_information16,81);
	xml_tab(l_counter).TagName  :='COST_EFF_DATE';
	xml_tab(l_counter).TagValue := rec_get_det_info.action_information16;
	l_counter := l_counter + 1;
  --
	xml_tab(l_counter).TagName  :='COSTING_START';
	xml_tab(l_counter).TagValue :='COSTING_END';
	l_counter := l_counter + 1;
  --
  l_prev_eoy_code := rec_get_det_info.action_information9;
  l_prev_cost_seg :=  rec_get_det_info.action_information10;
END LOOP;
hr_utility.set_location('END LOOP',82);
hr_utility.set_location('l_count'||l_count,83);
--
IF(l_count = 0) THEN
	xml_tab(l_counter).TagName  :='COST_SEG_GRP_START';
	xml_tab(l_counter).TagValue :='COST_SEG_GRP_START';
	l_counter := l_counter + 1;
  --
	xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
	xml_tab(l_counter).TagValue :='EOY_CODE_GRP_START';
	l_counter := l_counter + 1;
END IF;
--
xml_tab(l_counter).TagName  :='EOY_CODE_GRP_START';
xml_tab(l_counter).TagValue :='EOY_CODE_GRP_END';
l_counter := l_counter + 1;
--
hr_utility.set_location('l_total_cost_credit'||l_total_cost_credit,84);
IF( l_total_cost_credit <> 0 ) THEN
  xml_tab(l_counter).TagName  :='COST_SEG_GRP_TOT_CREDIT';
  xml_tab(l_counter).TagValue := l_total_cost_credit;
  l_counter := l_counter + 1;
END IF;
--
hr_utility.set_location('l_total_cost_debit'||l_total_cost_debit,85);
IF( l_total_cost_debit <> 0 ) THEN
  xml_tab(l_counter).TagName  :='COST_SEG_GRP_TOT_DEBIT';
  xml_tab(l_counter).TagValue := l_total_cost_debit;
  l_counter := l_counter + 1;
END IF;
--
xml_tab(l_counter).TagName  :='COST_SEG_GRP_START';
xml_tab(l_counter).TagValue :='COST_SEG_GRP_END';
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='COST_RECO_START';
xml_tab(l_counter).TagValue :='COST_RECO_END';
l_counter := l_counter + 1;
--
xml_tab(l_counter).TagName  :='FILE_HEADER_START';
xml_tab(l_counter).TagValue :='FILE_HEADER_END';
l_counter := l_counter + 1;
--
hr_utility.set_location('After populating pl/sql table',30);
hr_utility.set_location('Entered Procedure GETDATA',10);
--
WritetoCLOB (p_xml );
--
END POPULATE_DATA_DETAIL;
--
--
--
PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB) is
l_xfdf_string clob;
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(240);
l_str9 varchar2(240);
l_str10 varchar2(20);
l_str11 varchar2(20);
l_IANA_charset VARCHAR2 (50);

current_index pls_integer;

BEGIN

hr_utility.set_location('Entering WritetoCLOB ',10);


       l_IANA_charset := HR_NO_UTILITY.get_IANA_charset ;
        l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT><PAACR>';
        l_str2 := '<';
        l_str3 := '>';
        l_str4 := '</';
        l_str5 := '>';
        l_str6 := '</PAACR></ROOT>';
        l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';
        l_str10 := '<PAACR>';
        l_str11 := '</PAACR>';


        dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
        dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

        current_index := 0;

              IF xml_tab.count > 0 THEN

                        dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );


                        FOR table_counter IN xml_tab.FIRST .. xml_tab.LAST LOOP

                                l_str8 := xml_tab(table_counter).TagName;
                                l_str9 := xml_tab(table_counter).TagValue;

                                IF l_str9 IN ('FILE_HEADER_START', 'FILE_HEADER_END','COST_RECO_START','COST_RECO_END'
				               ,'COST_SEG_GRP_START','COST_SEG_GRP_END','EOY_CODE_GRP_START','EOY_CODE_GRP_END','COSTING_START','COSTING_END') THEN

                                                IF l_str9 IN ('FILE_HEADER_START','COST_RECO_START','EOY_CODE_GRP_START','COST_SEG_GRP_START','COSTING_START') THEN
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
                                                ELSE
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);
                                                END IF;

                                ELSE

                                         if l_str9 is not null then

                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str9), l_str9);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);
                                         else

                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                                           dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);

                                         end if;

                                END IF;

                        END LOOP;

                        dbms_lob.writeAppend(l_xfdf_string, length(l_str6), l_str6 );

                ELSE
                        dbms_lob.writeAppend(l_xfdf_string, length(l_str7), l_str7 );
                END IF;

                p_xfdf_clob := l_xfdf_string;

                hr_utility.set_location('Leaving WritetoCLOB ',20);

        EXCEPTION
                WHEN OTHERS then
                HR_UTILITY.TRACE('sqlerrm ' || SQLERRM);
                HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;


END PAY_NO_PACCR_PKG;

/
