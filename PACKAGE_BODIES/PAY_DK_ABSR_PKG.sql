--------------------------------------------------------
--  DDL for Package Body PAY_DK_ABSR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_ABSR_PKG" AS
/* $Header: pydkabsr.pkb 120.0.12010000.6 2009/12/08 05:21:20 rsahai noship $ */

--Global parameters
 g_package                  CONSTANT varchar2(33) := 'PAY_DK_ABSR_PKG.';
 g_debug                    BOOLEAN               :=  hr_utility.debug_enabled;
 g_err_num                  NUMBER;


-----------------------------------------------------------------------------
 -- GET_LOOKUP_MEANING function used to get labels of items from a lookup
-----------------------------------------------------------------------------
FUNCTION GET_LOOKUP_MEANING (p_lookup_type varchar2,p_lookup_code varchar2) RETURN VARCHAR2 IS

        CURSOR csr_lookup IS
        SELECT meaning
        FROM   hr_lookups
        WHERE  lookup_type = p_lookup_type
        AND    lookup_code = p_lookup_code
        AND    enabled_flag = 'Y';

l_meaning hr_lookups.meaning%type;

BEGIN
        OPEN csr_lookup;
        FETCH csr_lookup INTO l_Meaning;
        CLOSE csr_lookup;
        RETURN l_meaning;

END GET_LOOKUP_MEANING;


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
        ,p_sender_id             OUT  NOCOPY NUMBER
        ,p_year                  OUT  NOCOPY VARCHAR2
        ,p_effective_date        OUT  NOCOPY DATE
        ,p_report_end_date       OUT  NOCOPY DATE
        ,p_archive               OUT  NOCOPY VARCHAR2)
IS

CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
         SELECT
         PAY_DK_ABSR_PKG.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER')
        ,PAY_DK_ABSR_PKG.GET_PARAMETER(legislative_parameters,'PAYROLL')
        ,PAY_DK_ABSR_PKG.GET_PARAMETER(legislative_parameters,'YEAR')
        ,PAY_DK_ABSR_PKG.GET_PARAMETER(legislative_parameters,'ARCHIVE')
        ,effective_date
        ,fnd_date.canonical_to_date(PAY_DK_ABSR_PKG.GET_PARAMETER(legislative_parameters,'REPORT_END_DATE'))
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
 INTO   p_sender_id
       ,p_payroll_id
       ,p_year
       ,p_archive
       ,p_effective_date
       ,p_report_end_date
       ,p_business_group_id;
 CLOSE csr_parameter_info;
 --
 IF g_debug THEN
      hr_utility.set_location(' Leaving procedure '||l_proc,20);
 END IF;
END GET_ALL_PARAMETERS;

 ----------------------------------------------------
 -- GET_GLOBAL_VALUE  used to fetch Global Values
 ----------------------------------------------------

FUNCTION GET_GLOBAL_VALUE(
        p_global_name           VARCHAR2,
        p_effective_date        DATE)
        RETURN ff_globals_f.global_value%TYPE IS

CURSOR csr_globals IS
        SELECT global_value
        FROM ff_globals_f
        WHERE global_name = p_global_name
        AND legislation_code = 'DK'
        AND p_effective_date BETWEEN effective_start_date AND effective_END_date;

l_global_value ff_globals_f.global_value%TYPE;
l_proc    varchar2(72) := g_package||'get_global_value';

BEGIN
        IF g_debug THEN
                hr_utility.set_location('Entering:'|| l_proc, 1);
        END IF;

        OPEN csr_globals;
                FETCH csr_globals INTO l_global_value;
        CLOSE csr_globals;

        IF g_debug THEN
                hr_utility.set_location('Entering:'|| l_proc, 2);
        END IF;

        RETURN l_global_value;
END GET_GLOBAL_VALUE;


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
        l_sender_id             NUMBER;
        l_span                  VARCHAR(80);
        l_year                  VARCHAR(80);
        l_effective_date        DATE;
        l_report_end_date       DATE;
        l_archive               VARCHAR2(80);

        l_from_date             VARCHAR2(80);
        l_to_date               VARCHAR2(80);

        l_char_set              VARCHAR2(240);
        l_format                VARCHAR2(240);
        l_bg_da_sys_no          VARCHAR2(240);
        l_sys_name              VARCHAR2(240);

        l_le_id                 NUMBER;
        l_le_cvr_no             VARCHAR2(240);
        l_le_ds_wpcode          VARCHAR2(240);
        l_le_da_scode           VARCHAR2(240);
        l_le_name               VARCHAR2(240);
        l_le_addr               VARCHAR2(240);
        l_le_pcode              VARCHAR2(240);
        l_le_punit              VARCHAR2(10);

        l_sender_cvr_no         VARCHAR2(240);
        l_sender_name           VARCHAR2(240);
        l_sender_addr           VARCHAR2(240);
        l_sender_pcode          VARCHAR2(240);


        e_no_da_sys_no          EXCEPTION;
        error_message           BOOLEAN;

/* Cursor to check if Current Archive exists */
CURSOR csr_count is
SELECT count(*)
FROM   pay_action_information
WHERE  action_information_category = 'EMEA REPORT DETAILS'
AND    action_information1         = 'PYDKSTATSA'
AND    action_context_id           = pactid;


/* Cursor to fetch the Sender's Details */
/* If p_sender_id is null=> No Legal Employer selected, hence Service Provider of the BG is the Sender */
CURSOR csr_get_sender_details(p_sender_id NUMBER, p_effective_date DATE, p_business_group_id NUMBER) IS
SELECT   hoi2.org_information1 CVR_NO
        ,hou1.name  NAME
--        ,loc.ADDRESS_LINE_1||' '||loc.ADDRESS_LINE_2||' '||loc.ADDRESS_LINE_3 ADDR
        ,SUBSTR (loc.ADDRESS_LINE_1,1,80)||' '||SUBSTR (loc.ADDRESS_LINE_2,1,80)||' '||SUBSTR (loc.ADDRESS_LINE_3,1,80) ADDR  --Bug Fix-4998649
        ,loc.postal_code PCODE
FROM    HR_ORGANIZATION_UNITS hou1
      , HR_ORGANIZATION_INFORMATION hoi1
      , HR_ORGANIZATION_INFORMATION hoi2
      , HR_LOCATIONS loc
WHERE hou1.business_group_id = p_business_group_id
and hou1.organization_id = nvl(p_sender_id ,hou1.organization_id)
and hou1.location_id = loc.LOCATION_ID(+)
and hoi1.organization_id = hou1.organization_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = nvl2(p_sender_id,'HR_LEGAL_EMPLOYER','DK_SERVICE_PROVIDER')
and hoi1.ORG_INFORMATION2 ='Y'
and hoi2.ORG_INFORMATION_CONTEXT= nvl2(p_sender_id,'DK_LEGAL_ENTITY_DETAILS','DK_SERVICE_PROVIDER_DETAILS')
and hoi2.organization_id =  hoi1.organization_id
and p_effective_date BETWEEN hou1.DATE_FROM and nvl(hou1.DATE_TO, p_effective_date);


/* Cursor to fetch the Legal Employer Details */
CURSOR csr_get_le_details(p_sender_id NUMBER, p_sender_cvr_no VARCHAR2, p_effective_date DATE, p_business_group_id NUMBER) IS
SELECT   hou.organization_id   ORG_ID
        ,hoi2.ORG_INFORMATION1 CVR_NO
        ,hoi2.ORG_INFORMATION2 DS_WPCODE
        ,hoi2.ORG_INFORMATION6 PUNIT
        ,hou.name NAME
--        ,loc.ADDRESS_LINE_1||' '||loc.ADDRESS_LINE_2||' '||loc.ADDRESS_LINE_3 ADDR
        ,SUBSTR (loc.ADDRESS_LINE_1,1,80)||' '||SUBSTR (loc.ADDRESS_LINE_2,1,80)||' '||SUBSTR (loc.ADDRESS_LINE_3,1,80) ADDR  --Bug Fix-4998649
        ,loc.postal_code PCODE
FROM HR_ORGANIZATION_UNITS hou
   , HR_ORGANIZATION_INFORMATION hoi1
   , HR_ORGANIZATION_INFORMATION hoi2
   , HR_LOCATIONS loc
WHERE hou.business_group_id =  p_business_group_id
and hoi1.organization_id = hou.organization_id
and hou.location_id = loc.LOCATION_ID(+)
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi1.ORG_INFORMATION2 = 'Y'
and hoi2.ORG_INFORMATION_CONTEXT='DK_LEGAL_ENTITY_DETAILS'
and hoi2.organization_id =  hoi1.organization_id
--and nvl(hoi2.org_information1,0)= nvl2(p_sender_id,p_sender_cvr_no,nvl(hoi2.org_information1,0) )
and hou.organization_id  = p_sender_id
and p_effective_date BETWEEN hou.DATE_FROM and nvl(hou.DATE_TO, p_effective_date);


/* Cursor to fetch the Legal Employer DA Office Codes */
/* Modified check on context for bug fix 4997786 */
CURSOR csr_get_le_da_off_codes(p_le_id NUMBER, p_effective_date DATE, p_business_group_id NUMBER) IS
SELECT hoi2.ORG_INFORMATION1  DA_SCODE
FROM HR_ORGANIZATION_UNITS hou
   , HR_ORGANIZATION_INFORMATION hoi1
   , HR_ORGANIZATION_INFORMATION hoi2
WHERE hou.business_group_id =  p_business_group_id
and hoi1.organization_id = hou.organization_id
and hoi1.organization_id = p_le_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi1.ORG_INFORMATION2 = 'Y'
-- For bug fix 4997786
and hoi2.ORG_INFORMATION_CONTEXT= 'DK_DA_OFFICE_CODE' --'DK_EMPLOYMENT_DEFAULTS'
and hoi2.organization_id =  hoi1.organization_id
and p_effective_date BETWEEN hou.DATE_FROM and nvl(hou.DATE_TO, p_effective_date);


/* Cursor to fetch the Business Group Details */
CURSOR csr_get_bg_details(p_business_group_id NUMBER, p_effective_date DATE) IS
SELECT hoi2.ORG_INFORMATION1  DA_SYS_NO
FROM HR_ORGANIZATION_UNITS hou
   , HR_ORGANIZATION_INFORMATION hoi1
   , HR_ORGANIZATION_INFORMATION hoi2
WHERE hou.business_group_id =  p_business_group_id
and hoi1.organization_id = hou.organization_id
and hoi1.organization_id = p_business_group_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_BG'
and hoi1.ORG_INFORMATION2 = 'Y'
and hoi2.ORG_INFORMATION_CONTEXT='DK_IDENTIFICATION_CODES'
and hoi2.organization_id =  hoi1.organization_id
and p_effective_date BETWEEN hou.DATE_FROM and nvl(hou.DATE_TO, p_effective_date);


rec_sender_details       csr_get_sender_details%ROWTYPE;
rec_le_details           csr_get_le_details%ROWTYPE;
rec_get_le_da_off_codes  csr_get_le_da_off_codes%ROWTYPE;
rec_bg_details           csr_get_bg_details%ROWTYPE;


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
 PAY_DK_ABSR_PKG.GET_ALL_PARAMETERS(
                 pactid
                ,l_business_group_id
                ,l_payroll_id
                ,l_sender_id
                ,l_year
                ,l_effective_date
                ,l_report_end_date
                ,l_archive) ;


        /* To set Character Set and Format */
       l_from_date := to_char(to_date(l_year||'0101', 'YYYYMMDD'),'YYYYMMDD');
       l_to_date   := to_char(to_date(l_year||'1231', 'YYYYMMDD'),'YYYYMMDD');


        l_char_set := '3';
        l_format := '1';

        /* To obtain Sender's details */
        /* The Sender would be Service Provider if present in the system or else it would be the Legal Employer Specified */
/*
        OPEN csr_get_sender_details(l_sender_id,fnd_date.canonical_to_date(l_to_date),l_business_group_id);
        FETCH csr_get_sender_details INTO rec_sender_details;
        CLOSE csr_get_sender_details;

        l_sender_cvr_no := rec_sender_details.cvr_no;
        l_sender_name   := rec_sender_details.name;
        l_sender_addr   := rec_sender_details.addr;
        l_sender_pcode  := rec_sender_details.pcode;
*/
        /* To obtain Business Group details */

        OPEN csr_get_bg_details(l_business_group_id,fnd_date.canonical_to_date(l_to_date));
        FETCH csr_get_bg_details INTO rec_bg_details;
        CLOSE csr_get_bg_details;

        l_bg_da_sys_no := rec_bg_details.da_sys_no;
        l_sys_name := GET_LOOKUP_MEANING ('DK_STATSR_LABELS','OP');
        IF l_bg_da_sys_no IS NULL
        THEN
        RAISE e_no_da_sys_no;
        END IF;

        FOR rec_le_details IN csr_get_le_details(l_sender_id,l_sender_cvr_no,fnd_date.canonical_to_date(l_to_date),l_business_group_id)
        LOOP
                 /* To obtain Legal Employer's details from details provided in File Header*/


                l_le_cvr_no     := rec_le_details.cvr_no;
                l_le_ds_wpcode  := rec_le_details.ds_wpcode;
                l_le_name       := rec_le_details.name;
                l_le_addr       := rec_le_details.addr;
                l_le_pcode      := rec_le_details.pcode;
                l_le_id         := rec_le_details.org_id;
                l_le_punit      := rec_le_details.punit;


                 OPEN csr_get_le_da_off_codes(l_le_id,fnd_date.canonical_to_date(l_to_date),l_business_group_id);
                 FETCH csr_get_le_da_off_codes INTO rec_get_le_da_off_codes;
                 CLOSE csr_get_le_da_off_codes;

                l_le_da_scode   := rec_get_le_da_off_codes.da_scode;

                pay_action_information_api.create_action_information
                (
                 p_action_information_id        => l_action_info_id             -- out parameter
                ,p_object_version_number        => l_ovn                        -- out parameter
                ,p_action_context_id            => pactid                       -- context id = payroll action id (of Archive)
                ,p_action_context_type          => 'PA'                         -- context type
                ,p_effective_date               => l_effective_date             -- Date of Running the Archive
                ,p_action_information_category  => 'EMEA REPORT DETAILS'        -- Information Category
                ,p_tax_unit_id                  => l_le_id                      -- Legal Employer ID
                ,p_jurisdiction_code            => NULL                         -- Tax Municipality ID
                ,p_action_information1          => 'PYDKASORA'                  -- Conc Prg Short Name
                ,p_action_information2          => l_business_group_id          -- Business Group ID
                ,p_action_information3          => l_payroll_id                 -- Payroll ID
                ,p_action_information4          => 'HDR'                        -- Specifies data is for File Header
                ,p_action_information5          => l_year                       -- Span of report
                ,p_action_information6          => l_from_date                  -- Report's from date
                ,p_action_information7          => l_to_date                    -- Report's to date
                ,p_action_information8          => l_char_set                   -- Character Set
                ,p_action_information9          => l_format                     -- Format used
                ,p_action_information10         => l_le_cvr_no                  -- LE's CVR number
                ,p_action_information11         => l_le_name                    -- LE's Name
                ,p_action_information12         => l_le_addr                    -- LE's Address
                ,p_action_information13         => l_le_pcode                   -- LE's Postal Code
                ,p_action_information14         => l_bg_da_sys_no               -- BG's DA System Number
                ,p_action_information15         => l_sys_name                   -- Payroll System Name
                ,p_action_information16         => l_le_ds_wpcode               -- LE's DS Workplace Code
                ,p_action_information17         => l_le_da_scode                -- LE's DA Society Code
                ,p_action_information18         => l_le_punit                   -- LE's Production Unit Code
                );

        END LOOP;

IF g_debug THEN
  hr_utility.set_location(' Leaving Procedure RANGE_CODE',20);
END IF;

EXCEPTION WHEN e_no_da_sys_no THEN
    fnd_message.set_name('PAY','PAY_377058_DK_NO_DA_CODE_ERR');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    error_message:=fnd_concurrent.set_completion_status('ERROR','PAY_377058_DK_NO_DA_CODE_ERR');
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
      ,fnd_date.CANONICAL_TO_DATE(action_information6) from_date
      ,fnd_date.CANONICAL_TO_DATE(action_information7) to_date
      ,to_number(action_information2)  business_group_id
      ,tax_unit_id
      ,to_number(action_information3)    PAYROLL_ID
      ,action_information8               LE_NAME
      ,action_information18              LE_PUNIT  --8840262
      ,action_information17              LE_DA_OFFICE_CODE
      ,action_information10              LE_CVR_NUMBER
FROM pay_action_information pai
WHERE action_context_type = 'PA'
AND action_context_id  = p_payroll_action_id
AND action_information_category = 'EMEA REPORT DETAILS'
AND action_information1 = 'PYDKASORA'
AND action_information4 = 'HDR';


/* Cursor to fetch the Legal Employer level Employment Defaults */
CURSOR csr_get_le_emp_dflts(p_le_id NUMBER, p_effective_date DATE, p_business_group_id NUMBER) IS
SELECT hoi2.ORG_INFORMATION1  COND_OF_EMP
      ,hoi2.ORG_INFORMATION2  EMP_GRP
      ,hoi2.ORG_INFORMATION3  WORK_HOURS
      ,hoi2.ORG_INFORMATION4  FREQ
FROM HR_ORGANIZATION_UNITS hou
   , HR_ORGANIZATION_INFORMATION hoi1
   , HR_ORGANIZATION_INFORMATION hoi2
WHERE hou.business_group_id =  p_business_group_id
and hoi1.organization_id = hou.organization_id
and hoi1.organization_id = p_le_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi1.ORG_INFORMATION2 = 'Y'
and hoi2.ORG_INFORMATION_CONTEXT='DK_EMPLOYMENT_DEFAULTS'
and hoi2.organization_id =  hoi1.organization_id
and p_effective_date BETWEEN hou.DATE_FROM and nvl(hou.DATE_TO, p_effective_date);


/* Cursor to fetch the Legal Employer level Holiday Entitlement  */
CURSOR csr_get_hol_entit(p_le_id NUMBER, p_effective_date DATE, p_business_group_id NUMBER) IS
SELECT hoi2.ORG_INFORMATION1  DEFAULT_WORK_PATT
      ,hoi2.ORG_INFORMATION3  HOURLY_ACCR_RATE
      ,hoi2.ORG_INFORMATION4  SAL_ALLOW_RATE
FROM HR_ORGANIZATION_UNITS hou
   , HR_ORGANIZATION_INFORMATION hoi1
   , HR_ORGANIZATION_INFORMATION hoi2
WHERE hou.business_group_id =  p_business_group_id
and hoi1.organization_id = hou.organization_id
and hoi1.organization_id = p_le_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi1.ORG_INFORMATION2 = 'Y'
and hoi2.ORG_INFORMATION_CONTEXT='DK_HOLIDAY_ENTITLEMENT_INFO'
and hoi2.organization_id =  hoi1.organization_id
and p_effective_date BETWEEN hou.DATE_FROM and nvl(hou.DATE_TO, p_effective_date);

/* Cursor to fetch the HR Org level Production Unit Code*/
CURSOR csr_get_hr_org_info(hr_org_id hr_organization_information.organization_id%type)
IS
SELECT hoi2.ORG_INFORMATION6
FROM  hr_organization_information hoi1
	, hr_organization_information hoi2
WHERE hoi1.organization_id = hoi2.organization_id
AND hoi1.organization_id =   hr_org_id
AND hoi1.org_information1 = 'HR_ORG'
AND hoi1.org_information_context = 'CLASS'
AND hoi2.ORG_INFORMATION_CONTEXT='DK_EMPLOYMENT_DEFAULTS';

rg_csr_get_hr_org_info csr_get_hr_org_info%rowtype;

/* Cursor to fetch the Assgt location level Production Unit Code*/
CURSOR csr_location_info (p_location_id hr_location_extra_info.location_id%TYPE) IS
SELECT lei_information1
FROM hr_location_extra_info
WHERE location_id = p_location_id
AND information_type='DK_LOCATION_INFO';

rg_csr_location_info csr_location_info%ROWTYPE;

/* Cursor to fetch the Assignments, on which pre-payments has been completed */
CURSOR csr_assignments
        ( p_payroll_action_id    NUMBER
         ,p_payroll_id           NUMBER
         ,p_start_person         NUMBER
         ,p_end_person           NUMBER
         ,p_date_from            DATE
         ,p_date_to              DATE
         ,p_le_id                NUMBER
         ,p_effective_date       DATE
         ) IS
SELECT   distinct
         paaf.assignment_id              ASG_ID
        ,ppf.payroll_name                PAYROLL_NAME
        ,paaf.assignment_number          ASSIGNMENT_NUMBER
        ,substr(to_char(papf.national_identifier),1,instr(to_char(papf.national_identifier),'-')-1)||substr(to_char(papf.national_identifier),instr(to_char(papf.national_identifier),'-')+1)  CPR_NO
	    ,paaf.organization_id HR_ORG_ID
	    ,paaf.person_id              PERSON_ID
	    ,paaf.location_id     LOC_ID  --8820009
          ,papf.EMPLOYEE_NUMBER         --8820009
FROM
 per_all_people_f       papf
,per_all_assignments_f  paaf
,pay_payrolls_f         ppf
,hr_soft_coding_keyflex scl
--,pay_assignment_actions paa
--,pay_payroll_actions    ppa
WHERE paaf.person_id BETWEEN p_start_person AND p_end_person
AND papf.PERSON_ID = paaf.PERSON_ID
AND ppf.payroll_id = nvl(p_payroll_id,ppf.payroll_id)
AND paaf.payroll_id = ppf.payroll_id
AND paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
AND scl.enabled_flag = 'Y'
/*
AND paa.assignment_id = paaf.assignment_id
AND ppa.payroll_action_id = paa.payroll_action_id
AND paa.action_status  = 'C' -- Completed
AND ppa.action_type  IN ('P','U') -- Pre-Payments
AND ppa.effective_date BETWEEN p_date_from AND p_date_to
AND ppa.effective_date <=  paaf.EFFECTIVE_END_DATE
AND ppa.effective_date >= paaf.EFFECTIVE_start_DATE
*/
AND paaf.EFFECTIVE_START_DATE <= p_date_to
AND paaf.EFFECTIVE_END_DATE >= p_date_from
AND papf.current_employee_flag = 'Y'
AND scl.segment1 = to_char(p_le_id)
ORDER BY asg_id, person_id;

/*
CURSOR csr_asg_end(
         p_assignment_id1        NUMBER
	,p_date_from1            DATE
        ,p_date_to1              DATE
	,p_job_occ_mkode         VARCHAR2
	,p_job_status_mkode      VARCHAR2
	,p_sal_basis_mkode       VARCHAR2
	,p_time_off_lieu         VARCHAR2
	,p_pre_asg_end_date      DATE
	,p_loc_id                NUMBER
	) is
select
        paaf.effective_start_date ASG_START_DATE
    	,paaf.effective_end_date  ASG_END_DATE
FROM
 per_all_assignments_f  paaf
,hr_soft_coding_keyflex scl
where
  paaf.assignment_id = p_assignment_id1
AND paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
AND scl.enabled_flag = 'Y'
AND paaf.EFFECTIVE_START_DATE <= p_date_to1
AND paaf.EFFECTIVE_START_DATE >= p_pre_asg_end_date
AND paaf.EFFECTIVE_END_DATE >= p_date_from1
AND (scl.SEGMENT14 <> p_job_occ_mkode or scl.SEGMENT15 <> p_job_status_mkode
     or scl.SEGMENT16 <> p_sal_basis_mkode or scl.SEGMENT17 <> p_time_off_lieu
     or paaf.location_id <> p_loc_id);
csr_asg_end_check csr_asg_end%ROWTYPE;
*/

rec_hdr_info   csr_get_hdr_info%ROWTYPE;
rec_get_le_emp_dflts csr_get_le_emp_dflts%ROWTYPE;
rec_get_hol_entit csr_get_hol_entit%ROWTYPE;

--8766712 condition  (Splitting the absence year wise)
CURSOR csr_abs(p_person_id NUMBER
            ,p_business_group_id NUMBER
            ,p_date_from DATE
            ,p_date_to DATE
            ,p_asg_id NUMBER)
IS
select paat.absence_attendance_id, paat.absence_attendance_type_id,
GREATEST(paat.date_start,p_date_from) date_start, LEAST(paat.date_end,p_date_to) date_end,
paat.date_start actual_date_start, paat.date_end actual_date_end,
replace(paat.time_start,':','.') time_start, replace(paat.time_end,':','.') time_end,
paatv.information1 ABS_CODE,
paatv.NAME
FROM
PER_ABSENCE_ATTENDANCES paat,
PER_ABSENCE_ATTENDANCE_TYPES paatv
where
paat.PERSON_ID = p_person_id
and paat.business_group_id = p_business_group_id
and paat.business_group_id = paatv.business_group_id
and paat.absence_attendance_type_id = paatv.absence_attendance_type_id
and nvl(paatv.information_category,'DK') = 'DK'  --8789760
and (paat.date_start between p_date_from AND p_date_to
     OR paat.date_end between p_date_from AND p_date_to
     )
and exists
(
select 1
from
pay_element_types_f petf, --8917251
pay_element_entries_f peef,
pay_element_entry_values_f peevf
where
peef.assignment_id = p_asg_id
and petf.element_type_id = peef.element_type_id  --8917251
and petf.business_group_id is NULL  --8917251
and petf.legislation_code = 'DK'  --8917251
and peef.element_entry_id = peevf.element_entry_id
and (peef.effective_start_date between p_date_from AND p_date_to
     or peef.effective_end_date between p_date_from AND p_date_to)
and (peevf.effective_start_date between p_date_from AND p_date_to
     or peevf.effective_end_date between p_date_from AND p_date_to)
and to_char(paat.absence_attendance_id) = peevf.screen_entry_value
)
--8917251
UNION
select paat.absence_attendance_id, paat.absence_attendance_type_id,
GREATEST(paat.date_start,p_date_from) date_start, LEAST(paat.date_end,p_date_to) date_end,
paat.date_start actual_date_start, paat.date_end actual_date_end,
replace(paat.time_start,':','.') time_start, replace(paat.time_end,':','.') time_end,
paatv.information1 ABS_CODE,
paatv.NAME
FROM
PER_ABSENCE_ATTENDANCES paat,
PER_ABSENCE_ATTENDANCE_TYPES paatv
where
paat.PERSON_ID = p_person_id
and paat.business_group_id = p_business_group_id
and paat.business_group_id = paatv.business_group_id
and paat.absence_attendance_type_id = paatv.absence_attendance_type_id
and nvl(paatv.information_category,'DK') = 'DK'  --8789760
and (paat.date_start between p_date_from AND p_date_to
     OR paat.date_end between p_date_from AND p_date_to
     )
and exists
(
select 1
from
pay_element_types_f petf,
pay_element_entries_f peef,
per_business_groups_perf pbg
where
peef.assignment_id = p_asg_id
and petf.element_type_id = peef.element_type_id
and peef.creator_type = 'A'
and petf.business_group_id is NOT NULL
and pbg.business_group_id = petf.business_group_id
and pbg.legislation_code = 'DK'
and (peef.effective_start_date between p_date_from AND p_date_to
     or peef.effective_end_date between p_date_from AND p_date_to)
and to_char(paat.absence_attendance_id) = peef.creator_id
)
Order By 9 Asc;
--8917251

rec_csr_abs   csr_abs%ROWTYPE;

cursor cur_global(p_effective_date DATE)
IS
select global_value
from ff_globals_f
where
global_name = 'DK_HOURS_IN_DAY'
AND p_effective_date between effective_start_date AND effective_end_date;

l_global_value ff_globals_f.global_value%type;

-- Variable Declarations

l_count                 NUMBER := 0;
l_action_info_id        NUMBER;
l_ovn                   NUMBER;
l_actid                 NUMBER;
l_asgid                 NUMBER := -999;
l_perid                 NUMBER := -9999;  --8766712

l_archive               VARCHAR2(240);
l_payroll_id            NUMBER;
l_le_id                 NUMBER;
l_le_name               VARCHAR2(240);
l_effective_date        DATE;
l_date_from             DATE;
l_date_to               DATE;
l_bg_id                 NUMBER;

l_loc_punit                 VARCHAR2(10);

l_le_cvr_no	        pay_action_information.action_information1%type;
l_le_da_scode       pay_action_information.action_information1%type;
l_assg_no           pay_action_information.action_information1%type;
l_cpr_no            pay_action_information.action_information1%type;
l_abs_code          pay_action_information.action_information1%type;
l_time_units        NUMBER;
l_sign_units        pay_action_information.action_information1%type;
l_abs_start_date    date;
l_abs_end_date      date;
l_punit             pay_action_information.action_information1%type;
l_punit_code        pay_action_information.action_information1%type;   --8840262
l_org_punit         pay_action_information.action_information1%type;   --8840262

l_abs_start_time pay_action_information.action_information1%type;
l_abs_end_time	 pay_action_information.action_information1%type;

l_hours_rate            NUMBER;
l_freq                  VARCHAR2(80);
l_day_max_hrs           NUMBER;
l_old_mkode0600         VARCHAR2(80);

l_dimension             VARCHAR2(80);
l_year                  VARCHAR2(80);
l_asg_id                NUMBER;
l_mul_factor            VARCHAR2(80);

l_chk_asg_end_date DATE;
/*Changes for Lunar Payroll */
l_lnr_payroll_period     Varchar2(3);


e_too_many_hours        EXCEPTION;
e_no_emp_dflts          EXCEPTION;
error_message           BOOLEAN;

-- nprasath Added for Multiple Records
l_old_job_occ_mkode VARCHAR2(40);
l_old_job_status_mkode VARCHAR2(40);
l_old_sal_basis_mkode VARCHAR2(40);
l_old_time_off_lieu VARCHAR2(40);

l_loc_id NUMBER;
l_hr_org_id NUMBER;
l_old_loc_id NUMBER;

l_return NUMBER;
l_duration NUMBER;

--8766712
Type tab_per_abs_rec is table of Number index by BINARY_INTEGER;
l_tab_per_abs_rec tab_per_abs_rec;

--
BEGIN
 hr_utility.trace('Inside the Statistics Report');

IF g_debug THEN
      hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',10);
END IF;

        SELECT PAY_DK_ABSR_PKG.GET_PARAMETER(legislative_parameters,'YEAR')
        INTO l_year
        FROM  pay_payroll_actions
        WHERE payroll_action_id = p_payroll_action_id;


		hr_utility.trace(' Before for loop csr_get_hdr_info ');
       -- Fetch Header and Sub-header details
	    l_assg_no		 := NULL;
	    l_cpr_no		 := NULL;
	    l_abs_code		 := NULL;
	    l_time_units	 := NULL;
	    l_sign_units	 := NULL;
	    l_abs_start_date := NULL;
	    l_abs_end_date	 := NULL;
	    l_abs_start_time := NULL;
	    l_abs_end_time := NULL;
	    l_sign_units	 := '+';
--8840262
l_punit_code := NULL;
l_loc_punit := NULL;
l_org_punit := NULL;
--8840262

	FOR rec_hdr_info IN csr_get_hdr_info(p_payroll_action_id)
	LOOP

		hr_utility.trace(' Inside for loop csr_get_hdr_info :');
		l_le_id          := rec_hdr_info.tax_unit_id;
		hr_utility.trace(' l_le_id :'||l_le_id);
		l_le_name        := rec_hdr_info.le_name;
		hr_utility.trace(' l_le_name :'||l_le_name);
		l_payroll_id     := rec_hdr_info.payroll_id;
		hr_utility.trace(' l_payroll_id :'||l_payroll_id);
		l_punit          := rec_hdr_info.le_punit;
		hr_utility.trace(' l_punit :'||l_punit);

		hr_utility.trace('Variables Initialisations New ');

		l_le_cvr_no		 := to_char(rec_hdr_info.LE_CVR_NUMBER);
		l_le_da_scode	 := to_char(rec_hdr_info.LE_DA_OFFICE_CODE);

		hr_utility.trace(' After Variables Initialisations. ');
		/*
		OPEN csr_get_hdr_info(p_payroll_action_id);
		FETCH csr_get_hdr_info INTO rec_hdr_info;
		CLOSE csr_get_hdr_info;
		*/

		l_effective_date := rec_hdr_info.effective_date;
		--l_date_from      := to_date(rec_hdr_info.from_date);
		--l_date_to        := to_date(rec_hdr_info.to_date);
		l_bg_id          := rec_hdr_info.business_group_id;

		--Fixed for gscc error
		l_date_from      := rec_hdr_info.from_date;
		l_date_to        := rec_hdr_info.to_date;

		OPEN cur_global(l_effective_date);
		FETCH cur_global INTO l_global_value;
		CLOSE cur_global;
		hr_utility.trace(' l_global_value :'||l_global_value);
                -- Fetch Assignment's details

		FOR csr_rec IN csr_assignments( p_payroll_action_id
						     ,l_payroll_id
						     ,p_start_person
						     ,p_end_person
						     ,l_date_from
						     ,l_date_to
						     ,l_le_id
						     ,l_effective_date )
		LOOP

			hr_utility.trace(' Inside loop  csr_assignments');
			l_loc_id := csr_rec.loc_id;  --8820009
			l_hr_org_id := csr_rec.hr_org_id;
			/*
			l_hourly_salaried := csr_rec.hourly_salaried_code;
			IF l_hourly_salaried IS NULL THEN
				  IF csr_rec.payroll_period = 1 THEN
				  l_hourly_salaried := 'S';
				  ELSE
				  l_hourly_salaried := 'H';
				  END IF ;
			END IF ;
			*/
			hr_utility.trace(' l_asgid :'||l_asgid);
			hr_utility.trace(' csr_rec.asg_id :'||csr_rec.asg_id);

			IF (csr_rec.asg_id <> l_asgid) THEN

				hr_utility.trace(' ***** Intializing the old variables **** ');

				l_assg_no		 := NULL;
				l_cpr_no		 := NULL;
				l_abs_code		 := NULL;
				l_time_units	 := NULL;
				l_sign_units	 := NULL;
				l_abs_start_date := NULL;
				l_abs_end_date	 := NULL;
				l_abs_start_time := NULL;
				l_abs_end_time   := NULL;
				l_sign_units	 := '+';
--8840262
l_punit_code := NULL;
l_loc_punit := NULL;
l_org_punit := NULL;
--8840262

			End if;

			hr_utility.trace(' l_perid :'||l_perid);
			hr_utility.trace(' csr_rec.person_id :'||csr_rec.person_id);
			--8766712
			IF l_perid <> csr_rec.person_id
			THEN
				--clear the pl_sql_table;
				l_tab_per_abs_rec.DELETE;
			END IF;

		 -- nprasath added for Multiple Records
			IF (csr_rec.asg_id <> l_asgid)
			/*
			or (csr_rec.asg_id = l_asgid
			and ( csr_rec.job_occ_mkode <> l_old_job_occ_mkode
			or csr_rec.job_status_mkode <> l_old_job_status_mkode
			or csr_rec.sal_basis_mkode <> l_old_sal_basis_mkode
			or csr_rec.time_off_lieu <> l_old_time_off_lieu
			or csr_rec.loc_id <> l_old_loc_id)
			) */
			THEN

				hr_utility.trace(' Inside if  csr_rec.asg_id <> l_asgid');
				FOR rec_csr_abs IN csr_abs(csr_rec.person_id
							     ,l_bg_id
							     ,l_date_from
							     ,l_date_to
							     ,csr_rec.asg_id)
				LOOP

				--8766712
				IF NOT l_tab_per_abs_rec.EXISTS(rec_csr_abs.absence_attendance_id) THEN
				l_tab_per_abs_rec(rec_csr_abs.absence_attendance_id) := csr_rec.person_id;

				hr_utility.trace(' Inside IF NOT l_tab_per_abs_rec.EXISTS');

					l_assg_no		 := csr_rec.ASSIGNMENT_NUMBER;
					l_cpr_no		 := csr_rec.CPR_NO;
					l_abs_code		 := rec_csr_abs.ABS_CODE;
					l_abs_start_date := rec_csr_abs.date_start;
					l_abs_end_date	 := rec_csr_abs.date_end;

					l_abs_start_time := rec_csr_abs.time_start;
					l_abs_end_time	 := rec_csr_abs.time_end;

					IF l_abs_start_time IS NOT NULL OR l_abs_end_time IS NOT NULL  THEN

						hr_utility.trace(' Inside Hour hr_loc_work_schedule');

						l_return := hr_loc_work_schedule.calc_sch_based_dur (	csr_rec.asg_id ,
								'H' ,
								'Y' ,
								l_abs_start_date    ,
								l_abs_end_date     ,
								l_abs_start_time    ,
								l_abs_end_time      ,
								l_duration );

						l_duration := l_duration * 100 ;

					ELSE

						hr_utility.trace(' Inside Day hr_loc_work_schedule');

						l_return := hr_loc_work_schedule.calc_sch_based_dur (	csr_rec.asg_id ,
								'D' ,
								'Y' ,
								l_abs_start_date    ,
								l_abs_end_date     ,
								'00.01'    ,
								'23.59'      ,
								l_duration );

						l_duration := l_duration * NVL(l_global_value,7.4) * 100 ;

					END IF;

					l_time_units	 := l_duration;

					hr_utility.trace(' l_time_units:'||l_time_units);

					IF l_time_units < 0
					THEN
						l_sign_units	 := '-';
					ELSE
						l_sign_units	 := '+';
					END IF;

					hr_utility.trace(' Inside if  csr_rec.asg_id <> l_asgid after variable initialized');

					BEGIN
						  SELECT pay_assignment_actions_s.NEXTVAL INTO l_actid FROM  dual;
					EXCEPTION
						  WHEN OTHERS THEN
						  NULL ;
					END ;
					-- Create the archive assignment action
					hr_nonrun_asact.insact(l_actid ,csr_rec.asg_id ,p_payroll_action_id ,p_chunk,null);

					hr_utility.trace('After hr_nonrun_asact.insact');

                    hr_utility.trace(' csr_rec.asg_id l_loc_punit:'||l_loc_punit||'-'||csr_rec.asg_id );
                    hr_utility.trace(' csr_rec.asg_id l_org_punit:'||l_org_punit||'-'||csr_rec.asg_id );
					hr_utility.trace(' csr_rec.asg_id l_punit:'||l_punit||'-'||csr_rec.asg_id );
					hr_utility.trace(' csr_rec.asg_id l_punit_code:'||l_punit_code||'-'||csr_rec.asg_id );
					--8820009
					IF l_loc_id IS NOT NULL THEN
					  OPEN csr_location_info (l_loc_id);
					  FETCH csr_location_info INTO rg_csr_location_info;
					  IF csr_location_info%FOUND THEN
					   l_loc_punit  := rg_csr_location_info.lei_information1;
					   hr_utility.trace(' csr_rec.asg_id l_loc_punit:'||l_loc_punit||'-'||csr_rec.asg_id );
					  END IF;
					  CLOSE csr_location_info;
                    END IF;
                    --8840262
					IF l_hr_org_id IS NOT NULL THEN
					  OPEN csr_get_hr_org_info (l_hr_org_id);
					  FETCH csr_get_hr_org_info INTO rg_csr_get_hr_org_info;
					  IF csr_get_hr_org_info%FOUND THEN
					   l_org_punit := rg_csr_get_hr_org_info.org_information6;
					   hr_utility.trace(' csr_rec.asg_id l_loc_punit:'||l_org_punit||'-'||csr_rec.asg_id );
					  END IF;
					  CLOSE csr_get_hr_org_info;
                    END IF;

                   IF l_loc_punit IS NOT NULL THEN
                     l_punit_code := l_loc_punit;
                   ELSIF l_org_punit IS NOT NULL THEN
                     l_punit_code := l_org_punit;
                   ELSE
                     l_punit_code := l_punit;
                   END IF;

					/*
					IF l_loc_id IS NULL OR l_loc_punit IS NULL THEN
					  OPEN csr_get_hr_org_info (l_hr_org_id);
					  FETCH csr_get_hr_org_info INTO rg_csr_get_hr_org_info;
					  IF csr_get_hr_org_info%FOUND THEN
					   l_punit := nvl(rg_csr_get_hr_org_info.org_information6, l_punit);
					  END IF;
					  CLOSE csr_get_hr_org_info;
					ELSE
					  l_punit := l_loc_punit;
					END IF;
					*/
					--8840262
					--8820009
                    hr_utility.trace(' csr_rec.asg_id l_loc_punit2:'||l_loc_punit||'-'||csr_rec.asg_id );
                    hr_utility.trace(' csr_rec.asg_id l_punit2:'||l_punit||'-'||csr_rec.asg_id );
					hr_utility.trace(' csr_rec.asg_id l_loc_id2:'||l_loc_id||'-'||csr_rec.asg_id );

					hr_utility.trace('l_punit: '||l_punit );

					IF l_time_units <> 0 AND l_abs_code IS NOT NULL THEN  --8789760

					hr_utility.trace(' creating pay_action_information_api.create_action_information ');

						pay_action_information_api.create_action_information
						     ( p_action_information_id        => l_action_info_id             -- OUT parameter
							,p_object_version_number        => l_ovn                        -- OUT parameter
							,p_action_context_id            => l_actid                      -- Context id = assignment action id (of Archive)
							,p_action_context_type          => 'AAP'                        -- Context type
							,p_effective_date               => l_effective_date             -- Date of running the archive
							,p_assignment_id                => csr_rec.asg_id               -- Assignment ID
							,p_action_information_category  => 'EMEA REPORT INFORMATION'    -- Information Category
							,p_tax_unit_id                  => l_le_id                      -- Legal Employer ID
							,p_jurisdiction_code            => NULL                         -- Tax Municipality ID
							,p_action_information1          => 'PYDKASORA'                  -- Con Program Short Name
							,p_action_information2          => csr_rec.payroll_name         -- Payroll Name
							,p_action_information3          => p_payroll_action_id          -- Payroll action id (of Archive)
							,p_action_information4          => csr_rec.assignment_number    -- Assignment Number
							,p_action_information5          => csr_rec.cpr_no               -- CPR Number of Employee
							,p_action_information6          => 'ABS_DETAILS'                -- Archive part 1 on context AAP
							,p_action_information7          => l_le_cvr_no			    --LE's CVR Number
							,p_action_information8          => l_le_da_scode		    --LE's DA Office Code
							,p_action_information9          => l_assg_no			    --Assignment Number
							,p_action_information10         => l_cpr_no			    --CPR number
							,p_action_information11         => l_abs_code			    --Absence Code
							,p_action_information12         => l_time_units			    --Time Unit (Number of hours)
							,p_action_information13         => l_sign_units			    --Sign of the time unit (+/-)
							,p_action_information14         => to_char(l_abs_start_date, 'YYYYMMDD')	--Start date of Absence(YYYYMMDD)
							,p_action_information15         => to_char(l_abs_end_date, 'YYYYMMDD')		--End date of Absence(YYYYMMDD)
							,p_action_information16         => nvl(l_punit_code,l_punit)			    --LE's P Unit Code  --8840262
							,p_action_information17         => l_abs_start_time		    --Start time of Absence
							,p_action_information18         => l_abs_end_time	          --End time of Absence
							);
					hr_utility.trace('After pay_action_information_api.create_action_information ' );

					END IF;

					--8789760
					IF l_abs_code IS NULL THEN
						fnd_message.set_name('PER','HR_377107_DK_ABSENCE_REPORT');
						fnd_message.set_token('PER_ID',csr_rec.employee_number);  --8820009
						fnd_message.set_token('ABS_TYPE',rec_csr_abs.NAME);
						Fnd_file.put_line(FND_FILE.LOG,fnd_message.get);

						error_message := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',
						'Report completed with warning(s).');
					END IF;

				END IF; --8766712

				END LOOP;

				l_abs_code		 := NULL;
				l_time_units	 := NULL;
				l_sign_units	 := NULL;
				l_abs_start_date   := NULL;
				l_abs_end_date	 := NULL;
				l_abs_start_time   := NULL;
				l_abs_end_time     := NULL;
				l_sign_units	 := '+';
--8840262
l_punit_code := NULL;
l_loc_punit := NULL;
l_org_punit := NULL;
--8840262

			END IF;

			l_asgid := csr_rec.asg_id;
			l_perid := csr_rec.person_id;  --8766712
			/*
			l_old_job_occ_mkode := csr_rec.job_occ_mkode;
			l_old_job_status_mkode := csr_rec.job_status_mkode;
			l_old_sal_basis_mkode := csr_rec.sal_basis_mkode;
			l_old_time_off_lieu := csr_rec.time_off_lieu;
			l_old_loc_id := csr_rec.loc_id;
			*/

		END LOOP;

	END LOOP;


IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',20);
END IF;

EXCEPTION
WHEN e_too_many_hours THEN
    fnd_message.set_name('PAY','PAY_377033_DK_TOO_MANY_WKG_HRS');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    error_message:=fnd_concurrent.set_completion_status('ERROR','PAY_377033_DK_TOO_MANY_WKG_HRS');

WHEN e_no_emp_dflts THEN
    fnd_message.set_name('PAY','PAY_377061_DK_NO_LE_EMP_DFLTS');
    fnd_message.set_token('ITEM',l_le_name);
    fnd_file.put_line(fnd_file.log,substr(fnd_message.get,1,254));
    error_message:=fnd_concurrent.set_completion_status('ERROR','PAY_377061_DK_NO_LE_EMP_DFLTS');

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



/* ARCHIVE CODE */
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


PROCEDURE POPULATE_DATA
        (p_business_group_id     IN NUMBER,
         p_payroll_action_id     IN VARCHAR2 ,
         p_template_name         IN VARCHAR2,
         p_xml                   OUT NOCOPY CLOB)
IS

/* Cursor to fetch File Start and End Record Information */
CURSOR csr_get_hdr_info(p_payroll_action_id NUMBER)
IS
SELECT *
FROM pay_action_information pai
WHERE action_context_type = 'PA'
AND action_context_id  = p_payroll_action_id
AND action_information_category = 'EMEA REPORT DETAILS'
AND action_information1 = 'PYDKASORA'
AND action_information4 = 'HDR';


/* Cursors to fetch Personal and Salary Record Information */
CURSOR csr_get_body_info(p_payroll_action_id NUMBER, p_tax_unit_id NUMBER)
IS
SELECT pai.*
FROM
pay_payroll_actions ppa,
Pay_assignment_actions paa,
pay_action_information pai
WHERE
ppa.payroll_action_id = p_payroll_action_id
AND ppa.payroll_action_id = paa.payroll_action_id
AND paa.assignment_action_id = pai.action_context_id
AND pai.action_context_type = 'AAP'
AND pai.action_information_category = 'EMEA REPORT INFORMATION'
AND pai.action_information1 = 'PYDKASORA'
AND pai.action_information6 = 'ABS_DETAILS'
AND pai.action_information3 = to_char(p_payroll_action_id)
AND pai.tax_unit_id = p_tax_unit_id;


rec_get_hdr_info csr_get_hdr_info%ROWTYPE;
rec_get_body_info csr_get_body_info%ROWTYPE;

l_counter             NUMBER := 0;
l_le_count            NUMBER := 0;
l_payroll_action_id   NUMBER;

BEGIN

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

        EXCEPTION
        WHEN OTHERS THEN
        NULL;
        END ;

        ELSE

                l_payroll_action_id  :=p_payroll_action_id;

        END IF;
        hr_utility.set_location('Entered Procedure GETDATA',10);

        /* Get the File Start and End Record Information */
        OPEN csr_get_hdr_info(l_payroll_action_id);
        FETCH csr_get_hdr_info INTO rec_get_hdr_info;
        CLOSE csr_get_hdr_info;

        hr_utility.set_location('Before populating pl/sql table',20);

----------------------------------HEADER

        xml_tab(l_counter).TagName  :='FILE_HEADER_FOOTER_START';
        xml_tab(l_counter).TagValue :='FILE_HEADER_FOOTER_START';
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='CHAR_SET';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information8;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='FILE_FORMAT';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information9;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='COMPANY_CVR_NO';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information10;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='COMPANY_NAME';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information11;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='COMPANY_ADDR';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information12;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='COMPANY_PCODE';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information13;
        l_counter := l_counter + 1;

        FOR i IN csr_get_body_info(l_payroll_action_id, rec_get_hdr_info.tax_unit_id)
        LOOP
        xml_tab(l_counter).TagName  :='ABSENCE_RECO_START';
        xml_tab(l_counter).TagValue :='ABSENCE_RECO_START';
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='LE_CVR_NO';
        xml_tab(l_counter).TagValue := i.action_information7;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='LE_DA_SCODE';
        xml_tab(l_counter).TagValue := i.action_information8;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='ASSG_NO';
        xml_tab(l_counter).TagValue := i.action_information9;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='CPR_NO';
        xml_tab(l_counter).TagValue := i.action_information10;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='ABS_CODE';
        xml_tab(l_counter).TagValue := i.action_information11;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='TIME_UNITS';
        xml_tab(l_counter).TagValue := i.action_information12;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='SIGN_UNITS';
        xml_tab(l_counter).TagValue := i.action_information13;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='START_DATE';
        xml_tab(l_counter).TagValue := i.action_information14;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='END_DATE';
        xml_tab(l_counter).TagValue := i.action_information15;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='P_NUMBER';
        xml_tab(l_counter).TagValue := i.action_information16;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='ABSENCE_RECO_START';
        xml_tab(l_counter).TagValue :='ABSENCE_RECO_END';
        l_counter := l_counter + 1;

        END LOOP;
----------------------------------FOOTER

        xml_tab(l_counter).TagName  :='SENDER_CVR_NO';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information10;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='BG_DA_SYS_NO';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information14;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='UPDATE_DATE';
        xml_tab(l_counter).TagValue := to_char(rec_get_hdr_info.effective_date,'YYYYMMDD');
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='PAYROLL_SYS_NAME';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information15;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='FILE_HEADER_FOOTER_START';
        xml_tab(l_counter).TagValue :='FILE_HEADER_FOOTER_END';
        l_counter := l_counter + 1;

        hr_utility.set_location('After populating pl/sql table',30);
        hr_utility.set_location('Entered Procedure GETDATA',10);

        WritetoCLOB (p_xml );

END POPULATE_DATA;
/********************************************************/

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
       l_IANA_charset :=PAY_DK_GENERAL.get_IANA_charset ;
        --l_str1 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT><STATSR>' ;
        l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT><STATSR>';
        l_str2 := '<';
        l_str3 := '>';
        l_str4 := '</';
        l_str5 := '>';
        l_str6 := '</STATSR></ROOT>';
        --l_str7 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT></ROOT>';
        l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';
        l_str10 := '<STATSR>';
        l_str11 := '</STATSR>';


        dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
        dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

        current_index := 0;

              IF xml_tab.count > 0 THEN

                        dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );


                        FOR table_counter IN xml_tab.FIRST .. xml_tab.LAST LOOP

                                l_str8 := xml_tab(table_counter).TagName;
                                l_str9 := xml_tab(table_counter).TagValue;

                                IF l_str9 IN ('FILE_HEADER_FOOTER_START', 'FILE_HEADER_FOOTER_END','ABSENCE_RECO_START' ,'ABSENCE_RECO_END')
					  THEN

                                                IF l_str9 IN ('FILE_HEADER_FOOTER_START' , 'ABSENCE_RECO_START' ) THEN
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
                                           l_str9 := hr_dk_utility.REPLACE_SPECIAL_CHARS(l_str9); /* Place the check after not null check*/
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

END PAY_DK_ABSR_PKG;

/
