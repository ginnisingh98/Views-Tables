--------------------------------------------------------
--  DDL for Package Body PAY_DK_STATSR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_STATSR_PKG" AS
/* $Header: pydkstatsr.pkb 120.21.12010000.8 2010/01/25 08:33:56 jvaradra ship $ */

--Global parameters
 g_package                  CONSTANT varchar2(33) := 'PAY_DK_STATSR_PKG.';
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
        ,p_span                  OUT  NOCOPY VARCHAR2
        ,p_effective_date        OUT  NOCOPY DATE
        ,p_report_end_date       OUT  NOCOPY DATE
        ,p_archive               OUT  NOCOPY VARCHAR2)
IS

CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
         SELECT
         PAY_DK_STATSR_PKG.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER')
        ,PAY_DK_STATSR_PKG.GET_PARAMETER(legislative_parameters,'PAYROLL')
        ,PAY_DK_STATSR_PKG.GET_PARAMETER(legislative_parameters,'SPAN_RPT')
        ,PAY_DK_STATSR_PKG.GET_PARAMETER(legislative_parameters,'ARCHIVE')
        ,effective_date
        ,fnd_date.canonical_to_date(PAY_DK_STATSR_PKG.GET_PARAMETER(legislative_parameters,'REPORT_END_DATE'))
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
       ,p_span
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


---------------------------------------------------------------------
 -- GET_DEFINED_BALANCE_VALUE  used to fetch value of Defined Balance
--------------------------------------------------------------------

FUNCTION GET_DEFINED_BALANCE_VALUE
  (p_assignment_id              IN NUMBER
  ,p_balance_name               IN VARCHAR2
  ,p_balance_dim                IN VARCHAR2
  ,p_virtual_date               IN DATE) RETURN NUMBER IS

  l_context1 PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
  l_value    NUMBER;


  CURSOR get_dbal_id(p_balance_name VARCHAR2 , p_balance_dim VARCHAR2) IS
  SELECT pdb.defined_balance_id
  FROM   pay_defined_balances  pdb
        ,pay_balance_types  pbt
        ,pay_balance_dimensions  pbd
  WHERE  pbt.legislation_code='DK'
  AND    pbt.balance_name = p_balance_name
  AND    pbd.legislation_code = 'DK'
  AND    pbd.database_item_suffix = p_balance_dim
  AND    pdb.balance_type_id = pbt.balance_type_id
  AND    pdb.balance_dimension_id = pbd.balance_dimension_id;


BEGIN

  OPEN get_dbal_id(p_balance_name, p_balance_dim);
  FETCH get_dbal_id INTO l_context1;
  CLOSE get_dbal_id;

  l_value := pay_balance_pkg.get_value(l_context1,p_assignment_id,p_virtual_date);

  RETURN l_value;

END GET_DEFINED_BALANCE_VALUE ;



---------------------------------------------------------------------------------------
 -- GET_BALANCE_CATEGORY_VALUE  used to fetch value of Balances on a defined Category
---------------------------------------------------------------------------------------
FUNCTION GET_BALANCE_CATEGORY_VALUE
  (p_assignment_id              IN NUMBER
  ,p_balance_cat_name           IN VARCHAR2
  ,p_balance_dim                IN VARCHAR2
  ,p_virtual_date               IN DATE) RETURN NUMBER IS

  l_context1 PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
  l_tot_value    NUMBER;


  CURSOR get_dbal_id(p_balance_cat_name VARCHAR2 , p_balance_dim VARCHAR2) IS
  SELECT pdb.defined_balance_id DBAL_ID
  FROM   pay_defined_balances  pdb
        ,pay_balance_types  pbt
        ,pay_balance_dimensions  pbd
        ,pay_balance_categories_f pbc
  WHERE  pbc.category_name = p_balance_cat_name
  AND    pbt.balance_category_id = pbc.balance_category_id
  AND    pbd.legislation_code = 'DK'
  AND    pbd.database_item_suffix = p_balance_dim
  AND    pdb.balance_type_id = pbt.balance_type_id
  AND    pdb.balance_dimension_id = pbd.balance_dimension_id;


BEGIN

  l_tot_value :=0;

  FOR rec_get_dbal_id IN get_dbal_id(p_balance_cat_name, p_balance_dim)
  LOOP
  l_context1 := rec_get_dbal_id.dbal_id;

  l_tot_value :=  l_tot_value + pay_balance_pkg.get_value(l_context1,p_assignment_id,p_virtual_date);

  END LOOP;

  RETURN  l_tot_value;

END GET_BALANCE_CATEGORY_VALUE ;

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
and nvl(hoi2.org_information1,0)= nvl2(p_sender_id,p_sender_cvr_no,nvl(hoi2.org_information1,0) )
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

--8848543
/* Cursor to fetch the Period dates*/
Cursor csr_pd_dates (p_end_date DATE, p_payroll_id NUMBER)
IS
select *
from
per_time_periods
where
payroll_id = p_payroll_id
and p_end_date between START_DATE AND END_DATE;

l_rec_pd_dates csr_pd_dates%rowtype;

--8848543

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
 PAY_DK_STATSR_PKG.GET_ALL_PARAMETERS(
                 pactid
                ,l_business_group_id
                ,l_payroll_id
                ,l_sender_id
                ,l_span
                ,l_effective_date
                ,l_report_end_date
                ,l_archive) ;

 -- Check if we have to archive again
IF  (l_archive = 'Y')   THEN
-- Check if record for current archive exists
OPEN csr_count;
FETCH csr_count INTO l_count;
CLOSE csr_count;

-- Archive Report Details only if no record exists
   IF (l_count < 1) THEN


        /* To obtain Reporting From and Reporting To Dates from Span specified in parameters */

        l_to_date   := to_char(l_report_end_date,'YYYYMMDD');

        IF (l_span ='Q') THEN

        l_from_date := to_char(trunc(l_report_end_date,'Q'),'YYYYMMDD');

        ELSIF (l_span ='HY') THEN

        l_from_date := to_char(trunc(trunc(l_report_end_date,'Q')-1,'Q'),'YYYYMMDD');

        ELSIF (l_span ='Y') THEN

        l_from_date := to_char(trunc(l_report_end_date,'Y'),'YYYYMMDD');

        END IF;


        /* To set Character Set and Format */

        l_char_set := '3';
        l_format := '1';

        /* To obtain Sender's details */
        /* The Sender would be Service Provider if present in the system or else it would be the Legal Employer Specified */

        OPEN csr_get_sender_details(l_sender_id,fnd_date.canonical_to_date(l_to_date),l_business_group_id);
        FETCH csr_get_sender_details INTO rec_sender_details;
        CLOSE csr_get_sender_details;

        l_sender_cvr_no := rec_sender_details.cvr_no;
        l_sender_name   := rec_sender_details.name;
        l_sender_addr   := rec_sender_details.addr;
        l_sender_pcode  := rec_sender_details.pcode;

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

--8848543
        IF l_span ='P' AND l_payroll_id IS NOT NULL THEN
            OPEN csr_pd_dates (l_report_end_date, l_payroll_id);
            FETCH csr_pd_dates INTO l_rec_pd_dates;
            CLOSE csr_pd_dates;

            l_from_date  := to_char(l_rec_pd_dates.start_date,'YYYYMMDD');
            l_to_date    := to_char(l_rec_pd_dates.end_date,'YYYYMMDD');
        END IF;
--8848543

        -- Archive the REPORT DETAILS

        pay_action_information_api.create_action_information
        (p_action_information_id        => l_action_info_id             -- out parameter
        ,p_object_version_number        => l_ovn                        -- out parameter
        ,p_action_context_id            => pactid                       -- context id = payroll action id (of Archive)
        ,p_action_context_type          => 'PA'                         -- context type
        ,p_effective_date               => l_effective_date             -- Date of Running the Archive
        ,p_action_information_category  => 'EMEA REPORT DETAILS'        -- Information Category
        ,p_tax_unit_id                  => NULL                         -- Legal Employer ID
        ,p_jurisdiction_code            => NULL                         -- Tax Municipality ID
        ,p_action_information1          => 'PYDKSTATSA'                 -- Conc Prg Short Name
        ,p_action_information2          => l_business_group_id          -- Business Group ID
        ,p_action_information3          => l_payroll_id                 -- Payroll ID
        ,p_action_information4          => 'HDR'                        -- Specifies data is for File Header
        ,p_action_information5          => l_span                       -- Span of report
        ,p_action_information6          => l_from_date                  -- Report's from date
        ,p_action_information7          => l_to_date                    -- Report's to date
        ,p_action_information8          => l_char_set                   -- Character Set
        ,p_action_information9          => l_format                     -- Format used
        ,p_action_information10         => l_sender_cvr_no              -- Sender's CVR number
        ,p_action_information11         => l_sender_name                -- Sender's Name
        ,p_action_information12         => l_sender_addr                -- Sender's Address
        ,p_action_information13         => l_sender_pcode               -- Sender's Postal Code
        ,p_action_information14         => l_bg_da_sys_no               -- BG's DA System Number
        ,p_action_information15         => l_sys_name                   -- Payroll System Name
        );


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
                ,p_action_information1          => 'PYDKSTATSA'                 -- Conc Prg Short Name
                ,p_action_information2          => l_business_group_id          -- Business Group ID
                ,p_action_information3          => l_payroll_id                 -- Payroll ID
                ,p_action_information4          => 'CHDR'                       -- Specifies data is for File Sub-Header for Company
                ,p_action_information5          => l_le_cvr_no                  -- LE's CVR number
                ,p_action_information6          => l_le_ds_wpcode               -- LE's DS Workplace Code
                ,p_action_information7          => l_le_da_scode                -- LE's DA Society Code
                ,p_action_information8          => l_le_name                    -- LE's Name
                ,p_action_information9          => l_le_addr                    -- LE's Address
                ,p_action_information10         => l_le_pcode                   -- LE's Postal Code
                ,p_action_information11         => l_le_punit                   -- LE's Production Unit Code
                );

        END LOOP;

        END IF;

 END IF;

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
FROM pay_action_information pai
WHERE action_context_type = 'PA'
AND action_context_id  = p_payroll_action_id
AND action_information_category = 'EMEA REPORT DETAILS'
AND action_information1 = 'PYDKSTATSA'
AND action_information4 = 'HDR';


/* Cursor to fetch useful sub-header information to transfer to body records from already archived sub-header information */
CURSOR csr_get_sub_hdr_info(p_payroll_action_id NUMBER) IS
SELECT tax_unit_id
      ,to_number(action_information3)    PAYROLL_ID
      ,action_information8               LE_NAME
      , action_information11             LE_PUNIT
FROM pay_action_information pai
WHERE action_context_type = 'PA'
AND action_context_id  = p_payroll_action_id
AND action_information_category = 'EMEA REPORT DETAILS'
AND action_information1 = 'PYDKSTATSA'
AND action_information4 = 'CHDR';

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
         ,p_pd_date_to           DATE  --8848543
         ) IS
SELECT   distinct
         paaf.assignment_id              ASG_ID
        ,ppf.payroll_name                PAYROLL_NAME
        ,ppf.payroll_id --8848543
        ,paaf.assignment_number          ASSIGNMENT_NUMBER
        -- For Bug 9002015
        --,to_char(paaf.effective_start_date,'YYYYMMDD')  ASG_START_DATE
        ,paaf.effective_start_date  ASG_START_DATE
        -- Selecting assignments effective end date to fetch correct balance value - Bug 5003744
      ,paaf.effective_end_date  ASG_END_DATE
        ,substr(to_char(papf.national_identifier),1,instr(to_char(papf.national_identifier),'-')-1)||substr(to_char(papf.national_identifier),instr(to_char(papf.national_identifier),'-')+1)  CPR_NO
        ,scl.SEGMENT3                    COND_OF_EMP
        ,scl.SEGMENT4                    EMP_GRP
        ,scl.SEGMENT14                   JOB_OCC_MKODE
        ,scl.SEGMENT15                   JOB_STATUS_MKODE
        ,paaf.NORMAL_HOURS               NORMAL_HOURS
        ,paaf.FREQUENCY                  FREQ
        ,scl.SEGMENT10                   DEFAULT_WORK_PATT
        ,scl.SEGMENT11                   HOURLY_ACCR_RATE
        ,scl.SEGMENT13                   SAL_ALLOW_RATE
        ,decode(ppf.PERIOD_TYPE
                ,'Calendar Month','1'
                ,'Bi-Week'       ,'2'
                ,'Week'          ,'3'
                ,'Lunar Month'   ,'4')  PAYROLL_PERIOD      /*Changes for Lunar Payroll */
        ,scl.SEGMENT16                   SAL_BASIS_MKODE
        ,scl.SEGMENT17                   TIME_OFF_LIEU
      ,paaf.hourly_salaried_code       HOURLY_SALARIED_CODE
      ,paaf.organization_id HR_ORG_ID
      ,paaf.location_id     LOC_ID
FROM
 per_all_people_f       papf
,per_all_assignments_f  paaf
,pay_payrolls_f         ppf
,hr_soft_coding_keyflex scl
,pay_assignment_actions paa
,pay_payroll_actions    ppa
,per_time_periods ptp  --8848543
WHERE paaf.person_id BETWEEN p_start_person AND p_end_person
AND papf.PERSON_ID = paaf.PERSON_ID
AND ppf.payroll_id = nvl(p_payroll_id,ppf.payroll_id)
AND paaf.payroll_id = ppf.payroll_id
AND ptp.payroll_id = paaf.payroll_id --8848543
AND ptp.payroll_id = ppf.payroll_id --8848543
AND paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
AND scl.enabled_flag = 'Y'
AND paa.assignment_id = paaf.assignment_id
AND ppa.payroll_action_id = paa.payroll_action_id
AND paa.action_status  = 'C' -- Completed
AND ppa.action_type  IN ('P','U') -- Pre-Payments
--8848543
--AND ppa.effective_date BETWEEN p_date_from AND p_date_to
AND ppa.effective_date BETWEEN NVL(p_date_from,ptp.start_date) and NVL(p_date_to,ptp.end_date)
AND nvl(p_pd_date_to,ptp.start_date)  BETWEEN ptp.start_date and ptp.end_date
--8848543
/* Modified for bug 5003744 - Start */
--AND p_date_to BETWEEN paaf.EFFECTIVE_START_DATE AND paaf.EFFECTIVE_END_DATE
-- Added for Multi Record nprasath
-- For Bug 9192911
-- AND ppa.effective_date <=  paaf.EFFECTIVE_END_DATE
-- AND ppa.effective_date >= paaf.EFFECTIVE_start_DATE
--8848543
--AND paaf.EFFECTIVE_START_DATE <= p_date_to
--AND paaf.EFFECTIVE_END_DATE >= p_date_from
AND paaf.EFFECTIVE_START_DATE <= NVL(p_date_to,ptp.end_date)
AND paaf.EFFECTIVE_END_DATE >= NVL(p_date_from,ptp.start_date)
--8848543
AND papf.current_employee_flag = 'Y'
/* Modified for bug 5003744 - End */
AND scl.segment1 = to_char(p_le_id)
ORDER BY asg_id;

-- Added by nprasath for check the assignment end date for bug 5034129
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
	,p_cond_of_emp           VARCHAR2    -- For Bug 9266075
      ,p_emp_grp               VARCHAR2
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
     or scl.segment3 <> p_cond_of_emp   or scl.segment4 <> p_emp_grp   -- Bug 9266075
     or paaf.location_id <> p_loc_id);

csr_asg_end_check csr_asg_end%ROWTYPE;
rec_hdr_info   csr_get_hdr_info%ROWTYPE;
rec_get_le_emp_dflts csr_get_le_emp_dflts%ROWTYPE;
rec_get_hol_entit csr_get_hol_entit%ROWTYPE;

-- Variable Declarations

l_count                 NUMBER := 0;
l_action_info_id        NUMBER;
l_ovn                   NUMBER;
l_actid                 NUMBER;
l_asgid                 NUMBER := -999;

l_archive               VARCHAR2(240);
l_payroll_id            NUMBER;
l_le_id                 NUMBER;
l_le_name               VARCHAR2(240);
l_effective_date        DATE;
l_date_from             DATE;
l_date_to               DATE;
l_bg_id                 NUMBER;
l_punit                 VARCHAR2(10);
l_loc_punit                 VARCHAR2(10);

l_mkode0100             VARCHAR2(80) := ' ';
l_mkode0200             VARCHAR2(80) := ' ';
l_mkode0600             VARCHAR2(80) := ' ';
l_mkode0610             VARCHAR2(80) := ' ';
l_mkode0620             VARCHAR2(80) := ' ';
l_hours_rate            NUMBER;
l_freq                  VARCHAR2(80);
l_day_max_hrs           NUMBER;
l_old_mkode0600         VARCHAR2(80);

l_dimension             VARCHAR2(80);
l_span                  VARCHAR2(80);
l_asg_id                NUMBER;
l_mul_factor            VARCHAR2(80);

-- For Bug 9002015
l_chk_asg_start_date    DATE;
l_start_date_from       VARCHAR2(10);


l_iltype_0010_bal       NUMBER := 0;
l_iltype_0011_bal       NUMBER := 0;
l_iltype_0013_bal       NUMBER := 0;
l_iltype_0015_bal       NUMBER := 0;
--l_iltype_0021_bal       NUMBER := 0;
l_iltype_0022_bal       NUMBER := 0;
l_iltype_0023_bal       NUMBER := 0;
l_iltype_0024_bal       NUMBER := 0;
l_iltype_0025_bal       NUMBER := 0;
l_iltype_0026_bal       NUMBER := 0;
--l_iltype_0032_bal       NUMBER := 0;
l_iltype_0034_bal       NUMBER := 0;
l_iltype_0036_bal       NUMBER := 0;
l_iltype_0037_bal       NUMBER := 0;

l_iltype_0121_bal       NUMBER := 0;
l_iltype_0122_bal       NUMBER := 0;
l_iltype_0027_bal       NUMBER := 0;
l_iltype_0029_bal       NUMBER := 0;
l_iltype_0035_bal       NUMBER := 0;
l_iltype_0091_bal       NUMBER := 0;
l_iltype_0210_bal       NUMBER := 0;
l_iltype_0132_bal       NUMBER := 0;
l_iltype_0232_bal       NUMBER := 0;
l_iltype_0332_bal       NUMBER := 0;


-- Added for Multiple Records
l_old_iltype_0010_bal       NUMBER := 0;
l_old_iltype_0011_bal       NUMBER := 0;
l_old_iltype_0013_bal       NUMBER := 0;
l_old_iltype_0015_bal       NUMBER := 0;
--l_old_iltype_0021_bal       NUMBER := 0;
l_old_iltype_0022_bal       NUMBER := 0;
l_old_iltype_0023_bal       NUMBER := 0;
l_old_iltype_0024_bal       NUMBER := 0;
l_old_iltype_0025_bal       NUMBER := 0;
l_old_iltype_0026_bal       NUMBER := 0;
--l_old_iltype_0032_bal       NUMBER := 0;
l_old_iltype_0034_bal       NUMBER := 0;
l_old_iltype_0036_bal       NUMBER := 0;
l_old_iltype_0037_bal       NUMBER := 0;

l_old_iltype_0121_bal       NUMBER := 0;
l_old_iltype_0122_bal       NUMBER := 0;
l_old_iltype_0027_bal       NUMBER := 0;
l_old_iltype_0029_bal       NUMBER := 0;
l_old_iltype_0035_bal       NUMBER := 0;
l_old_iltype_0091_bal       NUMBER := 0;
l_old_iltype_0210_bal       NUMBER := 0;
l_old_iltype_0132_bal       NUMBER := 0;
l_old_iltype_0232_bal       NUMBER := 0;
l_old_iltype_0332_bal       NUMBER := 0;

l_iltype_0010_unit       NUMBER := 0;
l_iltype_0011_unit       NUMBER := 0;
l_iltype_0013_unit       NUMBER := 0;
l_iltype_0015_unit       NUMBER := 0;
--l_iltype_0021_unit       NUMBER := 0;
l_iltype_0022_unit       NUMBER := 0;
l_iltype_0023_unit       NUMBER := 0;
l_iltype_0024_unit       NUMBER := 0;
l_iltype_0025_unit       NUMBER := 0;
l_iltype_0026_unit       NUMBER := 0;
--l_iltype_0032_unit       NUMBER := 0;
l_iltype_0034_unit       NUMBER := 0;
l_iltype_0036_unit       NUMBER := 0;
l_iltype_0037_unit       NUMBER := 0;

l_iltype_0121_unit       NUMBER := 0;
l_iltype_0122_unit       NUMBER := 0;
l_iltype_0027_unit       NUMBER := 0;
l_iltype_0029_unit       NUMBER := 0;
l_iltype_0035_unit       NUMBER := 0;
l_iltype_0091_unit       NUMBER := 0;
l_iltype_0210_unit       NUMBER := 0;
l_iltype_0132_unit       NUMBER := 0;
l_iltype_0232_unit       NUMBER := 0;
l_iltype_0332_unit       NUMBER := 0;

l_iltype_0023_hr_rate    NUMBER := 0;

-- nprasath added for Multiple Records
l_s_old_iltype_0010_unit     NUMBER := 0;
l_h_old_iltype_0010_unit     NUMBER := 0;
l_old_iltype_0011_unit       NUMBER := 0;
l_old_iltype_0013_unit       NUMBER := 0;
l_old_iltype_0015_unit       NUMBER := 0;
l_old_iltype_0021_unit       NUMBER := 0;
l_old_iltype_0022_unit       NUMBER := 0;
l_s_old_iltype_0023_unit     NUMBER := 0;
l_h_old_iltype_0023_unit     NUMBER := 0;
l_old_iltype_0024_unit       NUMBER := 0;
l_old_iltype_0025_unit       NUMBER := 0;
l_old_iltype_0026_unit       NUMBER := 0;
l_old_iltype_0032_unit       NUMBER := 0;
l_old_iltype_0034_unit       NUMBER := 0;
l_old_iltype_0036_unit       NUMBER := 0;
l_old_iltype_0037_unit       NUMBER := 0;
l_old_iltype_0023_hr_rate    NUMBER := 0;

l_old_iltype_0121_unit    NUMBER := 0;
l_old_iltype_0122_unit    NUMBER := 0;
l_old_iltype_0027_unit    NUMBER := 0;
l_old_iltype_0029_unit    NUMBER := 0;
l_old_iltype_0035_unit    NUMBER := 0;
l_old_iltype_0091_unit    NUMBER := 0;
l_old_iltype_0210_unit    NUMBER := 0;
l_old_iltype_0132_unit    NUMBER := 0;
l_old_iltype_0232_unit    NUMBER := 0;
l_old_iltype_0332_unit    NUMBER := 0;

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
-- For bug 9192911
l_old_emp_grp       VARCHAR2(40);
l_old_cond_of_emp VARCHAR2(40);

l_bal_todate            DATE;
l_hourly_salaried per_all_assignments_f.hourly_salaried_code%TYPE ;
l_loc_id NUMBER;
l_hr_org_id NUMBER;
l_old_loc_id NUMBER;
l_pd_date_to DATE; --8848543

--8848543
/* Cursor to fetch the Period dates*/
Cursor csr_pd_dts (p_end_date DATE, p_payroll_id NUMBER)
IS
select *
from
per_time_periods
where
payroll_id = p_payroll_id
and p_end_date between START_DATE AND END_DATE;

l_rec_pd_dts csr_pd_dts%rowtype;

--8848543
--
BEGIN
 hr_utility.trace('Inside the Statistics Report');

IF g_debug THEN
      hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',10);
END IF;

        SELECT PAY_DK_STATSR_PKG.GET_PARAMETER(legislative_parameters,'SPAN_RPT')
               ,fnd_date.canonical_to_date(PAY_DK_STATSR_PKG.GET_PARAMETER(legislative_parameters,'REPORT_END_DATE'))  --8848543
        INTO l_span, l_pd_date_to  --8848543
        FROM  pay_payroll_actions
        WHERE payroll_action_id = p_payroll_action_id;
--8848543
        IF l_span <> 'P' THEN
          l_pd_date_to := NULL;
        END IF;
--8848543

       -- Fetch Header and Sub-header details
        FOR rec_sub_hdr_info IN csr_get_sub_hdr_info(p_payroll_action_id)
        LOOP

        l_le_id          := rec_sub_hdr_info.tax_unit_id;
        l_le_name        := rec_sub_hdr_info.le_name;
        l_payroll_id     := rec_sub_hdr_info.payroll_id;
        l_punit          := rec_sub_hdr_info.le_punit; -- default if not present at hr_org/location

        OPEN csr_get_hdr_info(p_payroll_action_id);
        FETCH csr_get_hdr_info INTO rec_hdr_info;
        CLOSE csr_get_hdr_info;

        l_effective_date := rec_hdr_info.effective_date;
        --l_date_from      := to_date(rec_hdr_info.from_date);
        --l_date_to        := to_date(rec_hdr_info.to_date);
        l_bg_id          := rec_hdr_info.business_group_id;

      --Fixed for gscc error
      --8848543
        IF l_span <> 'P' THEN
          l_date_from      := rec_hdr_info.from_date;
          l_date_to        := rec_hdr_info.to_date;
        ELSIF l_span = 'P' THEN
          l_date_from      := NULL;
          l_date_to        := NULL;
        END IF;
        --8848543

                -- Fetch Assignment's details

                FOR csr_rec IN csr_assignments( p_payroll_action_id
                                               ,l_payroll_id
                                               ,p_start_person
                                               ,p_end_person
                                               ,l_date_from
                                               ,l_date_to
                                               ,l_le_id
                                               ,l_effective_date
                                               ,l_pd_date_to)  --8848543
                LOOP

--8848543
                  IF l_span = 'P' THEN
                        OPEN csr_pd_dts (l_pd_date_to, csr_rec.payroll_id);
                        FETCH csr_pd_dts INTO l_rec_pd_dts;
                        CLOSE csr_pd_dts;

                        l_date_from      := l_rec_pd_dts.start_date;
                        l_date_to        := l_rec_pd_dts.end_date;
                  END IF;
--8848543


                  -- For Bug 9002015 BEGIN
			-- Check if assignment Start date is greater than Report Start Date
			-- Archive the greatest of Report start date or the assignment start date
                  l_chk_asg_start_date := csr_rec.ASG_START_DATE;

                  IF l_chk_asg_start_date < l_date_from
                  THEN
                     l_start_date_from := to_char(l_date_from,'YYYYMMDD');
                  ELSE
                     l_start_date_from := to_char(csr_rec.ASG_START_date,'YYYYMMDD');
                  END IF;
                  -- For Bug 9002015 END


                -- Bug 5003744 - If the assignment end date is <= report end date then use assignment end date
            -- else use report end date while fetching balance values.
        l_loc_id := csr_rec.loc_id;
        l_hr_org_id := csr_rec.hr_org_id;

            l_hourly_salaried := csr_rec.hourly_salaried_code;
            IF l_hourly_salaried IS NULL THEN
                    IF csr_rec.payroll_period = 1 THEN
                    l_hourly_salaried := 'S';
                    ELSE
                    l_hourly_salaried := 'H';
                    END IF ;
            END IF ;

             l_chk_asg_end_date := csr_rec.asg_end_date;

                IF csr_rec.asg_end_date <> hr_general.end_of_time Then
            --Bug 5034129 Check for any changes occured on Job Occupation Employee Code or Job Status Employee Code or Salary Basis Employee Code or Time Off in Lieu

                    open csr_asg_end(csr_rec.asg_id,
                                    l_date_from,
                                    l_date_to,
                                    csr_rec.job_occ_mkode,
                                    csr_rec.job_status_mkode,
                                    csr_rec.sal_basis_mkode,
                                    csr_rec.time_off_lieu,
                                    csr_rec.asg_end_date,
                                    csr_rec.loc_id,
						csr_rec.cond_of_emp,  -- For Bug 9266075
						csr_rec.emp_grp
                                    );

                     Fetch csr_asg_end into  csr_asg_end_check;

                     IF csr_asg_end%NOTFOUND THEN
                        l_chk_asg_end_date := hr_general.end_of_time;
                     End if;
                    close csr_asg_end;

            End If;

            IF l_chk_asg_end_date <= l_date_to THEN
               l_bal_todate := l_chk_asg_end_date;
            ELSE
               l_bal_todate := l_date_to;
            END IF;

            /*Check for Change of Assignment ID to Create New Assignment Action ID
             and for Archiving the data Bug Fix-5003220*/
             -- nprasath added for Multiple Records
            IF (csr_rec.asg_id <> l_asgid) THEN

            hr_utility.trace(' ***** Intializing the old variables **** ');

                  l_old_iltype_0010_bal  := 0;
                  l_old_iltype_0011_bal  := 0;
                  l_old_iltype_0013_bal  := 0;
                  l_old_iltype_0015_bal  := 0;
--                l_old_iltype_0021_bal  := 0;
                  l_old_iltype_0121_bal  := 0;
                  l_old_iltype_0122_bal  := 0;
                  l_old_iltype_0022_bal  := 0;
                  l_old_iltype_0023_bal  := 0;
                  l_old_iltype_0024_bal  := 0;
                  l_old_iltype_0025_bal  := 0;
                  l_old_iltype_0026_bal  := 0;
                  l_old_iltype_0027_bal  := 0;
                  l_old_iltype_0029_bal  := 0;
--                l_old_iltype_0032_bal  := 0;
                  l_old_iltype_0034_bal  := 0;
                  l_old_iltype_0035_bal  := 0;
                  l_old_iltype_0036_bal  := 0;
                  l_old_iltype_0037_bal  := 0;
                  l_old_iltype_0091_bal  := 0;
                  l_old_iltype_0210_bal  := 0;
                  l_old_iltype_0132_bal  := 0;
                  l_old_iltype_0232_bal  := 0;
                  l_old_iltype_0332_bal  := 0;

                  l_s_old_iltype_0010_unit  := 0;
                  l_h_old_iltype_0010_unit  := 0;
                  l_old_iltype_0011_unit    := 0;
                  l_old_iltype_0013_unit    := 0;
                  l_old_iltype_0015_unit    := 0;
--                l_old_iltype_0021_unit    := 0;
                  l_old_iltype_0121_unit    := 0;
                  l_old_iltype_0122_unit    := 0;
                  l_old_iltype_0022_unit    := 0;
                  l_s_old_iltype_0023_unit  := 0;
                  l_h_old_iltype_0023_unit  := 0;
                  l_old_iltype_0024_unit    := 0;
                  l_old_iltype_0025_unit    := 0;
                  l_old_iltype_0026_unit    := 0;
                  l_old_iltype_0027_unit    := 0;
                  l_old_iltype_0029_unit    := 0;
--                l_old_iltype_0032_unit    := 0;
                  l_old_iltype_0034_unit    := 0;
                  l_old_iltype_0035_unit    := 0;
                  l_old_iltype_0036_unit    := 0;
                  l_old_iltype_0037_unit    := 0;
                  l_old_iltype_0091_unit    := 0;
                  l_old_iltype_0210_unit    := 0;
                  l_old_iltype_0132_unit    := 0;
                  l_old_iltype_0232_unit    := 0;
                  l_old_iltype_0332_unit    := 0;
                  l_old_iltype_0023_hr_rate := 0;
            End if;

             -- nprasath added for Multiple Records


       IF (csr_rec.asg_id <> l_asgid)
             or (csr_rec.asg_id = l_asgid
                and ( csr_rec.job_occ_mkode <> l_old_job_occ_mkode
                  or csr_rec.job_status_mkode <> l_old_job_status_mkode
                    or csr_rec.sal_basis_mkode <> l_old_sal_basis_mkode
                  or csr_rec.time_off_lieu <> l_old_time_off_lieu
			  -- For Bug 9192911
			  or csr_rec.emp_grp <> l_old_emp_grp
                  or csr_rec.cond_of_emp <> l_old_cond_of_emp
            or csr_rec.loc_id <> l_old_loc_id)
               ) THEN


                        BEGIN
                                SELECT pay_assignment_actions_s.NEXTVAL INTO l_actid FROM  dual;
                        EXCEPTION
                                WHEN OTHERS THEN
                                NULL ;
                        END ;
                  -- Create the archive assignment action
                hr_nonrun_asact.insact(l_actid ,csr_rec.asg_id ,p_payroll_action_id ,p_chunk,null);

                OPEN csr_get_le_emp_dflts(l_le_id,l_date_to,l_bg_id) ;
                FETCH csr_get_le_emp_dflts INTO rec_get_le_emp_dflts;
                IF csr_get_le_emp_dflts%NOTFOUND THEN
                /* For bug fix 4997994 */
            /* Added check to check if corresponding assignment level details are present */
            --RAISE e_no_emp_dflts;
                  IF(csr_rec.cond_of_emp IS NULL OR csr_rec.emp_grp IS NULL OR csr_rec.normal_hours IS NULL
                     OR csr_rec.freq IS NULL) THEN
                  RAISE e_no_emp_dflts;
                  END IF;
                END IF;
                CLOSE csr_get_le_emp_dflts;

                OPEN csr_get_hol_entit(l_le_id,l_date_to,l_bg_id) ;
                FETCH csr_get_hol_entit INTO rec_get_hol_entit;
                CLOSE csr_get_hol_entit;

                IF l_loc_id IS NOT NULL THEN
                  OPEN csr_location_info (l_loc_id);
                  FETCH csr_location_info INTO rg_csr_location_info;
                  IF csr_location_info%FOUND THEN
                    l_loc_punit  := rg_csr_location_info.lei_information1;
                  END IF;
                  CLOSE csr_location_info;
                END IF;
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

                /************** Access the values for the IPTYPE values **************/
                /* Logic for selecting mkode0100 */

                IF( nvl(csr_rec.cond_of_emp, rec_get_le_emp_dflts.cond_of_emp) IN('3','4')) THEN
                l_mkode0100 := '2';
                ELSE
                l_mkode0100 := '1';
                END IF;
                /* Logic for selecting mkode0200 */
                IF( nvl(csr_rec.emp_grp, rec_get_le_emp_dflts.emp_grp) = '1') THEN
                l_mkode0200 := '1';
                ELSIF ( nvl(csr_rec.emp_grp, rec_get_le_emp_dflts.emp_grp) = '2') THEN
                l_mkode0200 := '2';
                ELSE
                l_mkode0200 := '3';
                END IF;

                /* Logic for selecting mkode0600 */
            /* Bug 5030983 Fixes - Start */
            /* For salary record mkode0600,if salary basis not in 81,82,83,84 and payroll period is weekly
               and biweekly then get working hours balance and divide by 13, 26 or 52 based on report span. */
                IF (l_span ='Q') THEN
                        l_dimension := '_ASG_LE_QTD';
                ELSIF (l_span ='HY') THEN
                        l_dimension := '_ASG_LE_HYTD';
                ELSIF (l_span ='Y') THEN
                        l_dimension := '_ASG_LE_YTD';
--8848543
                ELSIF (l_span ='P') THEN
                        l_dimension := '_ASG_PTD';
--8848543
                END IF;

                pay_balance_pkg.set_context('TAX_UNIT_ID',l_le_id);

                l_asg_id :=csr_rec.asg_id;
            IF csr_rec.SAL_BASIS_MKODE IN ('81','82','83','84') THEN
             /*Changes for Lunar Payroll */
                IF csr_rec.payroll_period IN ('1', '2', '3','4') THEN
                l_day_max_hrs := 24;
                l_hours_rate := nvl(csr_rec.normal_hours,rec_get_le_emp_dflts.work_hours) ;
                l_freq       := nvl(csr_rec.freq,rec_get_le_emp_dflts.freq);
                     IF(l_freq = 'D') THEN
                         IF(l_hours_rate > l_day_max_hrs) THEN
                         RAISE e_too_many_hours;
                         ELSE
                        l_mul_factor :=5;
                         END IF;
                     ELSIF (l_freq = 'W') THEN
                         IF(l_hours_rate > l_day_max_hrs*7) THEN
                         RAISE e_too_many_hours;
                         ELSE
                        l_mul_factor :=1;
                         END IF;
                     ELSIF (l_freq = 'M') THEN
                         IF(l_hours_rate > l_day_max_hrs*31) THEN
                         RAISE e_too_many_hours;
                         ELSE
                        l_mul_factor := 5/22;
                         END IF;
                     ELSIF (l_freq = 'Y') THEN
                         IF(l_hours_rate > l_day_max_hrs*366) THEN
                         RAISE e_too_many_hours;
                         END IF;
                     ELSE
                         l_mul_factor :=5/260;
                     END IF;

                l_mkode0600      := ROUND(l_hours_rate * l_mul_factor,2);
                END IF;

                ELSE -- MKODE not in 81,82,83,84
                /*IF csr_rec.payroll_period = '1' THEN*/
                IF l_hourly_salaried = 'S' THEN
                l_day_max_hrs := 24;
                l_hours_rate := nvl(csr_rec.normal_hours,rec_get_le_emp_dflts.work_hours) ;
                l_freq       := nvl(csr_rec.freq,rec_get_le_emp_dflts.freq);
                     IF(l_freq = 'D') THEN
                         IF(l_hours_rate > l_day_max_hrs) THEN
                         RAISE e_too_many_hours;
                         ELSE
                        l_mul_factor :=5;
                         END IF;
                     ELSIF (l_freq = 'W') THEN
                         IF(l_hours_rate > l_day_max_hrs*7) THEN
                         RAISE e_too_many_hours;
                         ELSE
                        l_mul_factor :=1;
                         END IF;
                     ELSIF (l_freq = 'M') THEN
                         IF(l_hours_rate > l_day_max_hrs*31) THEN
                         RAISE e_too_many_hours;
                         ELSE
                        l_mul_factor := 5/22;
                         END IF;
                     ELSIF (l_freq = 'Y') THEN
                         IF(l_hours_rate > l_day_max_hrs*366) THEN
                         RAISE e_too_many_hours;
                         END IF;
                     ELSE
                         l_mul_factor :=5/260;
                     END IF;

                l_mkode0600      := ROUND(l_hours_rate * l_mul_factor,2);

                /*Changes for Lunar Payroll */

                /*ELSIF csr_rec.payroll_period IN ('2','3','4') THEN*/
                ELSIF l_hourly_salaried = 'H' THEN
                      l_mkode0600 := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Worked Hours',l_dimension ,l_bal_todate) - l_old_mkode0600; -- l_date_to);
                  l_old_mkode0600 := l_mkode0600 + l_old_mkode0600;

                  IF l_span = 'Q' THEN
                     l_mkode0600 := l_mkode0600 / 13;
                  ELSIF l_span = 'HY' THEN
                     l_mkode0600 := l_mkode0600 / 26;
                  ELSIF l_span = 'Y' THEN
                     l_mkode0600 := l_mkode0600 / 52;
--8848543
                  ELSIF l_span = 'P' THEN
                     l_mkode0600 := l_mkode0600 / 1;
--8848543
                      END IF;
                END IF;

            END IF;     /* Bug 5030983 Fixes - End */

                /* Logic for selecting mkode0610 */
                IF( nvl(csr_rec.default_work_patt,rec_get_hol_entit.default_work_patt) = '5DAY') THEN
                l_mkode0610 := to_char(PAY_DK_STATSR_PKG.GET_GLOBAL_VALUE('DK_5DAY_WEEK_HOLIDAY_ENTITLEMENT', l_date_to));
                ELSIF ( nvl(csr_rec.default_work_patt,rec_get_hol_entit.default_work_patt) = '6DAY') THEN
                l_mkode0610 := to_char(PAY_DK_STATSR_PKG.GET_GLOBAL_VALUE('DK_6DAY_WEEK_HOLIDAY_ENTITLEMENT', l_date_to));
            /* Added new condition for bug fix 5003621 */
            ELSE
                l_mkode0610 := to_char(PAY_DK_STATSR_PKG.GET_GLOBAL_VALUE('DK_5DAY_WEEK_HOLIDAY_ENTITLEMENT', l_date_to));
                END IF;

                /* Logic for selecting l_mkode0620 */
                /*Changes for Lunar Payroll */
                /*IF(csr_rec.payroll_period = '2' OR csr_rec.payroll_period = '3' OR csr_rec.payroll_period = '4') THEN*/
            IF l_hourly_salaried = 'H' THEN
                  l_mkode0620 := nvl(nvl(csr_rec.hourly_accr_rate,rec_get_hol_entit.hourly_accr_rate)
                                     ,PAY_DK_STATSR_PKG.GET_GLOBAL_VALUE('DK_HOLIDAY_PAY_LEGSL_PERCENTAGE', l_date_to));
                /*ELSIF(csr_rec.payroll_period = '1') THEN*/
                 ELSIF l_hourly_salaried = 'S' THEN
                  l_mkode0620 := nvl(nvl(csr_rec.sal_allow_rate,rec_get_hol_entit.sal_allow_rate)
                                    ,PAY_DK_STATSR_PKG.GET_GLOBAL_VALUE('DK_HOLIDAY_ALLOWANCE_LEGSL_PERCENTAGE', l_date_to));
                END IF;

                /************** Access the balance values for the ILTYPE balances **************/

                /* Logic for fetching l_iltype_0010_bal */
                l_iltype_0010_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Total Income',l_dimension ,l_bal_todate) - l_old_iltype_0010_bal; -- l_date_to);
            l_old_iltype_0010_bal  := l_old_iltype_0010_bal + l_iltype_0010_bal;
                /* Bug 5030983 Fixes - Start */
            IF csr_rec.SAL_BASIS_MKODE IN ('81','82','83','84') THEN
               l_iltype_0010_unit := 0;
            ELSE
                /* Take the calculated values from mkode600 and bring to Monthly Payroll Frequency */
                /*IF(csr_rec.payroll_period = '1') THEN*/
                IF l_hourly_salaried = 'S' THEN
                      /* Changed this for bug fix 5034129 */
                      /*l_iltype_0010_unit := ROUND(l_hours_rate * l_mul_factor * 22/5,2);*/
                      l_iltype_0010_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Total ATP Hours',l_dimension ,l_bal_todate)
                                      - PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Worked Hours',l_dimension ,l_bal_todate) - l_s_old_iltype_0010_unit;
                      l_s_old_iltype_0010_unit := l_iltype_0010_unit + l_s_old_iltype_0010_unit;
                  /*Changes for Lunar Payroll */
                /*ELSIF(csr_rec.payroll_period = '2' OR csr_rec.payroll_period = '3' OR csr_rec.payroll_period = '4') THEN*/
                  ELSIF l_hourly_salaried = 'H' THEN
                      l_iltype_0010_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Worked Hours',l_dimension ,l_bal_todate) - l_h_old_iltype_0010_unit; -- l_date_to);
                      l_h_old_iltype_0010_unit := l_h_old_iltype_0010_unit + l_iltype_0010_unit;
                END IF;
                END IF; /* Bug 5030983 Fixes - End */
                /* Logic for fetching l_iltype_0011_bal */
                l_iltype_0011_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Special Pay',l_dimension ,l_bal_todate) - l_old_iltype_0011_bal; -- l_date_to);
                l_old_iltype_0011_bal  := l_iltype_0011_bal + l_old_iltype_0011_bal;
                l_iltype_0011_unit := 1;

                /* Logic for fetching l_iltype_0013_bal */
                l_iltype_0013_bal := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Holidayable Pay',l_dimension ,l_bal_todate) - l_old_iltype_0013_bal; -- l_date_to);
            l_old_iltype_0013_bal := l_old_iltype_0013_bal + l_iltype_0013_bal;
                /* Added for bug 5050964*/
            l_iltype_0013_unit := l_iltype_0010_unit;

                /* Logic for fetching l_iltype_0015_bal */
                l_iltype_0015_bal := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Total Benefits in Kind',l_dimension ,l_bal_todate) - l_old_iltype_0015_bal; -- l_date_to);
              l_old_iltype_0015_bal := l_old_iltype_0015_bal + l_iltype_0015_bal;
                l_iltype_0015_unit := 1;

                /* Logic for fetching l_iltype_0021_bal */
                /*
                l_iltype_0021_bal := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Employee ATP Deductions',l_dimension ,l_bal_todate) -- l_date_to)
                                    +PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Employer ATP Deductions',l_dimension ,l_bal_todate) -- l_date_to)
                                    +PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Employee Pension Deductions',l_dimension ,l_bal_todate) -- l_date_to)
                                    +PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Employer Pension Deductions',l_dimension ,l_bal_todate)
                            - l_old_iltype_0021_bal; -- l_date_to);
            l_old_iltype_0021_bal := l_iltype_0021_bal + l_old_iltype_0021_bal;
                l_iltype_0021_unit := 1;*/
                /* IL Type 0121 */
                l_iltype_0121_bal := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Employee ATP Deductions',l_dimension ,l_bal_todate) -- l_date_to)
                                    +PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Employee Pension Deductions',l_dimension ,l_bal_todate) -- l_date_to)
                            - l_old_iltype_0121_bal; -- l_date_to);
            l_old_iltype_0121_bal := l_iltype_0121_bal + l_old_iltype_0121_bal;
                l_iltype_0121_unit := 1;
                /* IL Type 0122 */
                l_iltype_0122_bal := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Employer ATP Deductions',l_dimension ,l_bal_todate) -- l_date_to)
                                    +PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Employer Pension Deductions',l_dimension ,l_bal_todate)
                            - l_old_iltype_0122_bal; -- l_date_to);
            l_old_iltype_0122_bal := l_iltype_0122_bal + l_old_iltype_0122_bal;
                l_iltype_0122_unit := 1;


            /* Added condition for bug fix 4998238 */
            /*Changes for Lunar Payroll */
                /*IF(csr_rec.payroll_period = '2' OR csr_rec.payroll_period = '3' OR csr_rec.payroll_period = '4') THEN*/
      /*    IF l_hourly_salaried = 'H' THEN
                l_iltype_0021_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Worked Hours',l_dimension ,l_bal_todate) - l_old_iltype_0021_unit; -- l_date_to);
                l_old_iltype_0021_unit := l_iltype_0021_unit + l_old_iltype_0021_unit;
            END IF;*/

                /* Logic for fetching l_iltype_0022_bal */
                l_iltype_0022_bal := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Total G_Dage Pay',l_dimension ,l_bal_todate) - l_old_iltype_0022_bal; -- l_date_to);
            l_old_iltype_0022_bal := l_iltype_0022_bal + l_old_iltype_0022_bal;
                /* After FS changes, now for both salaried and non-salaried, to report Total G_Dage_Days_ASG_XXX as units
                , earlier was Total G_Dage Hours for non-salaried */
                /* Commenting code below and re-writing to achieve this */
                /*IF(csr_rec.payroll_period = '1') THEN
                        l_iltype_0022_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Total G_Dage Days',l_dimension ,l_date_to);
                ELSIF(csr_rec.payroll_period = '2' OR csr_rec.payroll_period = '3') THEN
                        l_iltype_0022_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Total G_Dage Hours',l_dimension ,l_date_to);
                END IF;*/
                l_iltype_0022_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Total G_Dage Days',l_dimension ,l_bal_todate) - l_old_iltype_0022_unit; -- l_date_to);
            l_old_iltype_0022_unit := l_iltype_0022_unit + l_old_iltype_0022_unit;
                /*Bug 5026906 fix- Changing the '<' operator to '=' in order to display
                  the negative values*/
               -- IF(l_iltype_0022_unit <0) THEN
              IF(l_iltype_0022_unit = 0) THEN
                l_iltype_0022_unit := 1;
                END IF;

                /* Logic for fetching l_iltype_0023_bal */
                /*IF(csr_rec.payroll_period = '1' ) THEN*/
            IF l_hourly_salaried = 'S' THEN
                l_iltype_0023_unit := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Salaried Paid Absence Hours',l_dimension ,l_bal_todate) - l_s_old_iltype_0023_unit; -- l_date_to);
            l_s_old_iltype_0023_unit := l_s_old_iltype_0023_unit + l_iltype_0023_unit;

                /* Calculate Hourly Rate Modified with if clause to avoid zero divide error */
                if l_iltype_0010_unit <> 0 then
               l_iltype_0023_hr_rate := ROUND((PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Salary Reporting',l_dimension ,l_bal_todate) - l_old_iltype_0023_hr_rate)/l_iltype_0010_unit,2);
               l_old_iltype_0023_hr_rate := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Salary Reporting',l_dimension ,l_bal_todate);
            end if;

                l_iltype_0023_bal := l_iltype_0023_hr_rate*l_iltype_0023_unit;
            /*Changes for Lunar Payroll */
                /*ELSIF(csr_rec.payroll_period = '2' OR csr_rec.payroll_period = '3' OR csr_rec.payroll_period = '4') THEN*/
            ELSIF l_hourly_salaried = 'H' THEN
                l_iltype_0023_bal  := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Hourly Paid Absence Pay',l_dimension ,l_bal_todate) - l_old_iltype_0023_bal; -- l_date_to);
            l_old_iltype_0023_bal := l_iltype_0023_bal + l_old_iltype_0023_bal;
                l_iltype_0023_unit := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Hourly Paid Absence Hours',l_dimension ,l_bal_todate) - l_h_old_iltype_0023_unit; -- l_date_to);
            l_h_old_iltype_0023_unit := l_iltype_0023_unit + l_h_old_iltype_0023_unit;
                END IF;
                /* Logic for fetching l_iltype_0024_bal */
                /* After FS changes, it is now valid only for non-salaried ppl with balance Holiday_Accrual_Amount_ASG_XXX
                , whereas earlier it was valid only for salaried ppl with 'Holiday Allowance Paid' as balance
                and Holiday Absence Days as units.*/
                /* Commenting code below and re-writing to achieve this */
                /*
                IF(csr_rec.payroll_period = '1' ) THEN
                l_iltype_0024_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Holiday Allowance Paid',l_dimension ,l_date_to);
            l_iltype_0024_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Holiday Absence Days',l_dimension ,l_date_to);
                */
                /*Changes for Lunar Payroll */
                /*IF(csr_rec.payroll_period = '2' OR csr_rec.payroll_period = '3' OR csr_rec.payroll_period = '4') THEN*/
            IF l_hourly_salaried = 'H' THEN
                  /* Changed for bug 5012411*/
                  l_iltype_0024_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Holiday Bank Pay',l_dimension ,l_bal_todate) - l_old_iltype_0024_bal; -- l_date_to);
                  l_old_iltype_0024_bal := l_iltype_0024_bal + l_old_iltype_0024_bal;
                      l_iltype_0024_unit := 1;
                END IF;

                /* Logic for fetching l_iltype_0025_bal */
                /* After FS changes, , it is now valid only for salaried ppl with balance with balance Holiday_Accrual_Amount_ASG_XXX,
                whereas earlier it was valid only for non-salaried ppl with balance Holiday Bank Pay
                and units Holiday Absence Hours */
                /* Commenting code below and re-writing to achieve this */
                /*
                IF(csr_rec.payroll_period = '2' OR csr_rec.payroll_period = '3') THEN
                l_iltype_0025_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Holiday Bank Pay',l_dimension ,l_date_to);
                l_iltype_0025_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Holiday Absence Hours',l_dimension ,l_date_to);
                */
                /*IF(csr_rec.payroll_period = '1' ) THEN*/
            IF l_hourly_salaried = 'S' THEN
                l_iltype_0025_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Holiday Accrual Amount',l_dimension ,l_bal_todate) - l_old_iltype_0025_bal; -- l_date_to);
            l_old_iltype_0025_bal := l_old_iltype_0025_bal + l_iltype_0025_bal;
                l_iltype_0025_unit := 1;
                END IF;

                /* Logic for fetching l_iltype_0026_bal */
                l_iltype_0026_bal := 0;
		    /* For Bug 9072985 . Bug 9278107
		      Currently 0026 field is been archived with the unpaid holiday days available rather than the unpaid holidays spent
			Changed the balance name, such that it reported the Unpaid holidays taken rather than those available */
               -- l_iltype_0026_unit  :=  PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Holiday Unpaid Days',l_dimension ,l_bal_todate) - l_old_iltype_0026_unit; -- l_date_to);
		   -- l_iltype_0026_unit  :=  PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Holiday Absence Days',l_dimension ,l_bal_todate) - l_old_iltype_0026_unit; -- l_date_to);
   		      l_iltype_0026_unit  :=  trunc(PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Holiday Unpaid Days Taken',l_dimension ,l_bal_todate)) - l_old_iltype_0026_unit; -- l_date_to);
            l_old_iltype_0026_unit := l_iltype_0026_unit + l_old_iltype_0026_unit;

                   /* IL Type 0027 */
               l_iltype_0027_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Other Absence Amount',l_dimension ,l_bal_todate) - l_old_iltype_0027_bal; -- l_date_to);
            l_old_iltype_0027_bal := l_old_iltype_0027_bal + l_iltype_0027_bal;
                l_iltype_0027_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Other Absence Days',l_dimension ,l_bal_todate) - l_old_iltype_0027_unit;
            l_old_iltype_0027_unit := l_old_iltype_0027_unit + l_iltype_0027_unit;

                   /* IL Type 0029 */
               l_iltype_0029_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Elective Scheme Amount',l_dimension ,l_bal_todate) - l_old_iltype_0029_bal; -- l_date_to);
            l_old_iltype_0029_bal := l_old_iltype_0029_bal + l_iltype_0029_bal;
            l_iltype_0029_unit := 1;

                /* Logic for fetching l_iltype_0032_bal */
                /*
                l_iltype_0032_bal  := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Other Pay',l_dimension ,l_bal_todate) - l_old_iltype_0032_bal; -- l_date_to);
            l_old_iltype_0032_bal := l_old_iltype_0032_bal + l_iltype_0032_bal;
                l_iltype_0032_unit := 1;
                */
                /* Logic for fetching l_iltype_0132_bal */
                l_iltype_0132_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Performance Irregular Payments',l_dimension ,l_bal_todate) - l_old_iltype_0132_bal; -- l_date_to);
            l_old_iltype_0132_bal := l_old_iltype_0132_bal + l_iltype_0132_bal;
                l_iltype_0132_unit := 1;

                /* Logic for fetching l_iltype_0232_bal */
                l_iltype_0232_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Compensation Irregular Payments',l_dimension ,l_bal_todate) - l_old_iltype_0232_bal; -- l_date_to);
            l_old_iltype_0232_bal := l_old_iltype_0232_bal + l_iltype_0232_bal;
                l_iltype_0232_unit := 1;

                /* Logic for fetching l_iltype_0332_bal */
                l_iltype_0332_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Other Irregular Payments',l_dimension ,l_bal_todate) - l_old_iltype_0332_bal; -- l_date_to);
            l_old_iltype_0332_bal := l_old_iltype_0332_bal + l_iltype_0332_bal;
                l_iltype_0332_unit := 1;

                /* Logic for fetching l_iltype_0034_bal */
                /* After FS changes, now applicable  to Salaried Payrolls only now, earlier was for all*/
                /* Adding new condition, to achieve this */
                /*IF(csr_rec.payroll_period = '1') THEN*/
            IF l_hourly_salaried = 'S' THEN
                l_iltype_0034_bal  := 0;
                /* For Bug 9072985
                   IL0034 absence with payment (except holiday) should report in days and not in hours and Holidays should not be included.
                   A seeded balance is now provided and user can feed the elements accordingly */
		    -- l_iltype_0034_unit := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Salaried Paid Absence Hours',l_dimension ,l_bal_todate) - l_old_iltype_0034_unit; -- l_date_to);
   		       l_iltype_0034_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Salaried Paid Absence Balance',l_dimension ,l_bal_todate) - l_old_iltype_0034_unit; -- l_date_to);
            l_old_iltype_0034_unit := l_iltype_0034_unit + l_old_iltype_0034_unit;
                END IF;

                   /* IL Type 0035 */
               l_iltype_0035_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Nuisance Pay',l_dimension ,l_bal_todate) - l_old_iltype_0035_bal; -- l_date_to);
            l_old_iltype_0035_bal := l_old_iltype_0035_bal + l_iltype_0035_bal;
            l_iltype_0035_unit := 1;

                /* Logic for fetching l_iltype_0036_bal */
                /* After FS changes, now applicable  to non-salaried Payrolls only now, earlier was for all*/
                /* Commenting code and putting everything into the first IF condition, to achieve this */
                /*l_iltype_0036_unit := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Hourly Overtime Pay',l_dimension ,l_date_to);*/
                /*Changes for Lunar Payroll */
                /*IF(csr_rec.payroll_period = '2' OR csr_rec.payroll_period = '3' OR csr_rec.payroll_period = '4') THEN*/
            IF l_hourly_salaried = 'H' THEN
                /*l_iltype_0036_bal  := 0;
                ELSIF(csr_rec.payroll_period = '1' ) THEN */
            /*Bug 5020527 fix - Assigning the 'Hourly Overtime Hours' balance value to l_iltype_0036_unit
            and 'Hourly Overtime Pay' balance value to l_iltype_0036_bal*/
                /*l_iltype_0036_bal  := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Hourly Overtime Hours',l_dimension ,l_date_to);
                l_iltype_0036_unit := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Hourly Overtime Pay',l_dimension ,l_date_to);*/

                l_iltype_0036_unit := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Hourly Overtime Hours',l_dimension ,l_bal_todate) - l_old_iltype_0036_unit; -- l_date_to);
            l_old_iltype_0036_unit := l_iltype_0036_unit + l_old_iltype_0036_unit;
                l_iltype_0036_bal  := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Hourly Overtime Pay',l_dimension ,l_bal_todate) - l_old_iltype_0036_bal; -- l_date_to);
            l_old_iltype_0036_bal := l_old_iltype_0036_bal + l_iltype_0036_bal;
                /*Bug 5026906 fix- Changing the '<' operator to '=' in order to display
                  the negative values*/
                 -- IF(l_iltype_0036_unit <0) THEN
              IF(l_iltype_0036_unit = 0) THEN
                        l_iltype_0036_unit := 1;
                  END IF;
                END IF;

                /* Logic for fetching l_iltype_0037_bal */
                /* After FS changes, now applicable  to Salaried Payrolls only now, earlier was for all*/
                /* Adding new condition, to achieve this */
                /*IF(csr_rec.payroll_period = '1') THEN*/
            IF l_hourly_salaried = 'S' THEN
                l_iltype_0037_bal  := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Salaried Overtime Pay',l_dimension ,l_bal_todate) - l_old_iltype_0037_bal; -- l_date_to);
            l_old_iltype_0037_bal := l_old_iltype_0037_bal + l_iltype_0037_bal;
                l_iltype_0037_unit := PAY_DK_STATSR_PKG.GET_BALANCE_CATEGORY_VALUE(l_asg_id, 'Salaried Overtime Hours',l_dimension ,l_bal_todate) - l_old_iltype_0037_unit; -- l_date_to);
            l_old_iltype_0037_unit := l_old_iltype_0037_unit + l_iltype_0037_unit;
                /*Bug 5026906 fix- Changing the '<' operator to '=' in order to display
                  the negative values*/
                --IF(l_iltype_0037_unit <0) THEN
            IF(l_iltype_0037_unit = 0) THEN
                        l_iltype_0037_unit := 1;
                  END IF;
                END IF;

            /* IL Type 0091 */
        l_iltype_0091_bal  := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Gross Deduction',l_dimension ,l_bal_todate) - l_old_iltype_0091_bal;
            l_old_iltype_0091_bal := l_old_iltype_0091_bal + l_iltype_0091_bal;
            l_iltype_0091_unit := 1;

            /* IL Type 0210 */
        l_iltype_0210_bal  := 0;
            l_iltype_0210_unit := PAY_DK_STATSR_PKG.GET_DEFINED_BALANCE_VALUE(l_asg_id, 'Paid Work Hours',l_dimension ,l_bal_todate) - l_old_iltype_0210_unit;
        l_old_iltype_0210_unit := l_old_iltype_0210_unit + l_iltype_0210_unit;

/* Added to fix issues due to varying numeric formats */
l_mkode0600          :=  fnd_number.number_to_canonical(l_mkode0600 );
l_mkode0610          :=  fnd_number.number_to_canonical(l_mkode0610);
l_mkode0620          :=  fnd_number.number_to_canonical(l_mkode0620);
l_iltype_0010_bal    :=  fnd_number.number_to_canonical(l_iltype_0010_bal);
l_iltype_0011_bal    :=  fnd_number.number_to_canonical(l_iltype_0011_bal);
l_iltype_0013_bal    :=  fnd_number.number_to_canonical(l_iltype_0013_bal);
l_iltype_0015_bal    :=  fnd_number.number_to_canonical(l_iltype_0015_bal);
--l_iltype_0021_bal    :=      fnd_number.number_to_canonical(l_iltype_0021_bal);
l_iltype_0121_bal    :=  fnd_number.number_to_canonical(l_iltype_0121_bal);
l_iltype_0122_bal    :=  fnd_number.number_to_canonical(l_iltype_0122_bal);
l_iltype_0027_bal    :=  fnd_number.number_to_canonical(l_iltype_0027_bal);
l_iltype_0022_bal    :=  fnd_number.number_to_canonical(l_iltype_0022_bal);
l_iltype_0023_bal    :=  fnd_number.number_to_canonical(l_iltype_0023_bal);
l_iltype_0024_bal    :=  fnd_number.number_to_canonical(l_iltype_0024_bal);
l_iltype_0025_bal    :=  fnd_number.number_to_canonical(l_iltype_0025_bal);
l_iltype_0026_bal    :=  fnd_number.number_to_canonical(l_iltype_0026_bal);
l_iltype_0029_bal    :=  fnd_number.number_to_canonical(l_iltype_0029_bal);
--l_iltype_0032_bal    :=      fnd_number.number_to_canonical(l_iltype_0032_bal);
l_iltype_0034_bal    :=  fnd_number.number_to_canonical(l_iltype_0034_bal);
l_iltype_0035_bal    :=  fnd_number.number_to_canonical(l_iltype_0035_bal);
l_iltype_0036_bal    :=  fnd_number.number_to_canonical(l_iltype_0036_bal);
l_iltype_0037_bal    :=  fnd_number.number_to_canonical(l_iltype_0037_bal);
l_iltype_0091_bal    :=  fnd_number.number_to_canonical(l_iltype_0091_bal);
l_iltype_0210_bal    :=  fnd_number.number_to_canonical(l_iltype_0210_bal);
l_iltype_0132_bal    :=  fnd_number.number_to_canonical(l_iltype_0132_bal);
l_iltype_0232_bal    :=  fnd_number.number_to_canonical(l_iltype_0232_bal);
l_iltype_0332_bal    :=  fnd_number.number_to_canonical(l_iltype_0332_bal);

l_iltype_0010_unit   :=  fnd_number.number_to_canonical(l_iltype_0010_unit);
l_iltype_0011_unit   :=  fnd_number.number_to_canonical(l_iltype_0011_unit);
l_iltype_0013_unit   :=  fnd_number.number_to_canonical(l_iltype_0013_unit);
l_iltype_0015_unit   :=  fnd_number.number_to_canonical(l_iltype_0015_unit);
--l_iltype_0021_unit   :=      fnd_number.number_to_canonical(l_iltype_0021_unit);
l_iltype_0121_unit   :=  fnd_number.number_to_canonical(l_iltype_0121_unit);
l_iltype_0122_unit   :=  fnd_number.number_to_canonical(l_iltype_0122_unit);
l_iltype_0022_unit   :=  fnd_number.number_to_canonical(l_iltype_0022_unit);
l_iltype_0023_unit   :=  fnd_number.number_to_canonical(l_iltype_0023_unit);
l_iltype_0024_unit   :=  fnd_number.number_to_canonical(l_iltype_0024_unit);
l_iltype_0025_unit   :=  fnd_number.number_to_canonical(l_iltype_0025_unit);
l_iltype_0026_unit   :=  fnd_number.number_to_canonical(l_iltype_0026_unit);
l_iltype_0027_unit   :=  fnd_number.number_to_canonical(l_iltype_0027_unit);
l_iltype_0029_unit   :=  fnd_number.number_to_canonical(l_iltype_0029_unit);
--l_iltype_0032_unit   :=      fnd_number.number_to_canonical(l_iltype_0032_unit);
l_iltype_0034_unit   :=  fnd_number.number_to_canonical(l_iltype_0034_unit);
l_iltype_0035_unit   :=  fnd_number.number_to_canonical(l_iltype_0035_unit);
l_iltype_0036_unit   :=  fnd_number.number_to_canonical(l_iltype_0036_unit);
l_iltype_0037_unit   :=  fnd_number.number_to_canonical(l_iltype_0037_unit);
l_iltype_0091_unit   :=  fnd_number.number_to_canonical(l_iltype_0091_unit);
l_iltype_0210_unit   :=  fnd_number.number_to_canonical(l_iltype_0210_unit);
l_iltype_0132_unit   :=  fnd_number.number_to_canonical(l_iltype_0132_unit);
l_iltype_0232_unit   :=  fnd_number.number_to_canonical(l_iltype_0232_unit);
l_iltype_0332_unit   :=  fnd_number.number_to_canonical(l_iltype_0332_unit);

                   -- Creating Initial Archive Entries
                   /*Changes for Lunar Payroll */
                   If csr_rec.payroll_period = '4' then
                        l_lnr_payroll_period := '1';
                   Else
                        l_lnr_payroll_period := csr_rec.payroll_period;
                   End if;

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
                        ,p_action_information1          => 'PYDKSTATSA'                 -- Con Program Short Name
                        ,p_action_information2          => csr_rec.payroll_name         -- Payroll Name
                        ,p_action_information3          => p_payroll_action_id          -- Payroll action id (of Archive)
                        ,p_action_information4          => csr_rec.assignment_number    -- Assignment Number
                        ,p_action_information5          => csr_rec.cpr_no               -- CPR Number of Employee
                        ,p_action_information6          => 'PART1'                      -- Archive part 1 on context AAP
                        ,p_action_information7          => l_mkode0100                  -- MKODE of IPTYPE 0100
                        ,p_action_information8          => l_mkode0200                  -- MKODE of IPTYPE 0200
                        ,p_action_information9          => csr_rec.job_occ_mkode        -- MKODE of IPTYPE 0300
                        ,p_action_information10         => csr_rec.job_status_mkode     -- MKODE of IPTYPE 0400
                        ,p_action_information11         => l_mkode0600                  -- MKODE of IPTYPE 0600
                        ,p_action_information12         => l_mkode0610                  -- MKODE of IPTYPE 0610
                        ,p_action_information13         => l_mkode0620                  -- MKODE of IPTYPE 0620
                        ,p_action_information14         => to_char(l_lnr_payroll_period)         -- MKODE of IPTYPE 0700            /*Changes for Lunar Payroll */
                        ,p_action_information15         => csr_rec.sal_basis_mkode      -- MKODE of IPTYPE 0800
                        ,p_action_information16         => l_iltype_0010_bal            -- Balance for ILTYPE 0010
                        ,p_action_information17         => l_iltype_0011_bal            -- Balance for ILTYPE 0011
                        ,p_action_information18         => l_iltype_0013_bal            -- Balance for ILTYPE 0013
                        ,p_action_information19         => l_iltype_0015_bal            -- Balance for ILTYPE 0015
                        ,p_action_information20         => NULL            -- Balance for ILTYPE 0021
                        ,p_action_information21         => l_iltype_0022_bal            -- Balance for ILTYPE 0022
                        ,p_action_information22         => l_iltype_0023_bal            -- Balance for ILTYPE 0023
                        ,p_action_information23         => l_iltype_0024_bal            -- Balance for ILTYPE 0024
                        ,p_action_information24         => l_iltype_0025_bal            -- Balance for ILTYPE 0025
                        ,p_action_information25         => l_iltype_0026_bal            -- Balance for ILTYPE 0026
                        ,p_action_information26         => NULL            -- Balance for ILTYPE 0032
                        ,p_action_information27         => l_iltype_0034_bal            -- Balance for ILTYPE 0034
                        ,p_action_information28         => l_iltype_0036_bal            -- Balance for ILTYPE 0036
                        ,p_action_information29         => l_iltype_0037_bal            -- Balance for ILTYPE 0037
                        ,p_action_information30         => l_hourly_salaried            -- Hourly/Salaried
                        );

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
                        ,p_action_information1          => 'PYDKSTATSA'                 -- Con Program Short Name
                        ,p_action_information2          => csr_rec.payroll_name         -- Payroll Name
                        ,p_action_information3          => p_payroll_action_id          -- Payroll action id (of Archive)
                        ,p_action_information4          => csr_rec.time_off_lieu        -- Time Off in Lieu
                        ,p_action_information5          => l_start_date_from  -- csr_rec.asg_start_date  -- Assignment Start Date - For Bug 9002015
                        ,p_action_information6          => 'PART2'                       -- Archive part 2 on context AAP
                        ,p_action_information7          => l_iltype_0010_unit            -- Units for ILTYPE 0010
                        ,p_action_information8          => l_iltype_0011_unit            -- Units for ILTYPE 0011
                        ,p_action_information9          => l_iltype_0013_unit            -- Units for ILTYPE 0013
                        ,p_action_information10         => l_iltype_0015_unit            -- Units for ILTYPE 0015
                        ,p_action_information11         => NULL            -- Units for ILTYPE 0021
                        ,p_action_information12         => l_iltype_0022_unit            -- Units for ILTYPE 0022
                        ,p_action_information13         => l_iltype_0023_unit            -- Units for ILTYPE 0023
                        ,p_action_information14         => l_iltype_0024_unit            -- Units for ILTYPE 0024
                        ,p_action_information15         => l_iltype_0025_unit            -- Units for ILTYPE 0025
                        ,p_action_information16         => l_iltype_0026_unit            -- Units for ILTYPE 0026
                        ,p_action_information17         => NULL            -- Units for ILTYPE 0032
                        ,p_action_information18         => l_iltype_0034_unit            -- Units for ILTYPE 0034
                        ,p_action_information19         => l_iltype_0036_unit            -- Units for ILTYPE 0036
                        ,p_action_information20         => l_iltype_0037_unit            -- Units for ILTYPE 0037
                  ,p_action_information21         => to_char(l_bal_todate,'YYYYMMDD') -- Added for bug 5003220 to display end date instead of ass end date
                                    ,p_action_information22         => l_punit -- Assignment_level Production Unit Code
                        --8848543
                        ,p_action_information23         => l_start_date_from  -- For Bug 9266075 to_char(l_date_from,'YYYYMMDD')
                        ,p_action_information24         => to_char(l_bal_todate,'YYYYMMDD') -- For Bug 9266075  to_char(l_date_to,'YYYYMMDD')
                        --8848543
                        );

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
                        ,p_action_information1          => 'PYDKSTATSA'                 -- Con Program Short Name
                        ,p_action_information2          => csr_rec.payroll_name         -- Payroll Name
                        ,p_action_information3          => p_payroll_action_id          -- Payroll action id (of Archive)
                        ,p_action_information4          => null
                        ,p_action_information5          => null
                        ,p_action_information6          => 'PART3'
                        ,p_action_information7          => l_iltype_0121_unit
                        ,p_action_information8          => l_iltype_0122_unit
                        ,p_action_information9          => l_iltype_0027_unit
                        ,p_action_information10         => l_iltype_0029_unit
                        ,p_action_information11         => l_iltype_0035_unit
                        ,p_action_information12         => l_iltype_0091_unit
                        ,p_action_information13         => l_iltype_0210_unit
                        ,p_action_information14         => l_iltype_0132_unit
                        ,p_action_information15         => l_iltype_0232_unit
                        ,p_action_information16         => l_iltype_0332_unit
                        ,p_action_information17         => NULL                   -- Reserved for future use
                        ,p_action_information18         => NULL                   -- Reserved for future use
                        ,p_action_information19         => l_iltype_0121_bal
                        ,p_action_information20         => l_iltype_0122_bal
                        ,p_action_information21         => l_iltype_0027_bal
                        ,p_action_information22         => l_iltype_0029_bal
                              ,p_action_information23         => l_iltype_0035_bal
                                    ,p_action_information24         => l_iltype_0091_bal
                                    ,p_action_information25         => l_iltype_0210_bal
                                    ,p_action_information26         => l_iltype_0132_bal
                                    ,p_action_information27         => l_iltype_0232_bal
                                    ,p_action_information28         => l_iltype_0332_bal
                        ,p_action_information29         => NULL                   -- Reserved for future use
                        ,p_action_information30         => NULL                   -- Reserved for future use
                        );


      END IF; --Bug Fix 5003220,Archiving the data only once for an assignment

            l_asgid := csr_rec.asg_id;
            l_old_job_occ_mkode := csr_rec.job_occ_mkode;
            l_old_job_status_mkode := csr_rec.job_status_mkode;
            l_old_sal_basis_mkode := csr_rec.sal_basis_mkode;
            l_old_time_off_lieu := csr_rec.time_off_lieu;
            l_old_loc_id := csr_rec.loc_id;
		-- For bug 9192911
            l_old_emp_grp := csr_rec.emp_grp;
            l_old_cond_of_emp := csr_rec.cond_of_emp;


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
AND action_information1 = 'PYDKSTATSA'
AND action_information4 = 'HDR';


/* Cursor to fetch Company Start and End Record Information */
CURSOR csr_get_chdr_info(p_payroll_action_id NUMBER)
IS
SELECT *
FROM pay_action_information pai
WHERE action_context_type = 'PA'
AND action_context_id  = p_payroll_action_id
AND action_information_category = 'EMEA REPORT DETAILS'
AND action_information1 = 'PYDKSTATSA'
AND action_information4 = 'CHDR';


/* Cursors to fetch Personal and Salary Record Information */
CURSOR csr_get_body_info1(p_payroll_action_id NUMBER, p_tax_unit_id NUMBER)
IS
SELECT *
FROM pay_action_information pai
WHERE action_context_type = 'AAP'
AND action_information3 = to_char(p_payroll_action_id)
AND action_information_category = 'EMEA REPORT INFORMATION'
AND action_information1 = 'PYDKSTATSA'
AND action_information6 ='PART1'
AND tax_unit_id = p_tax_unit_id
-- Add check on MKODE800 not being 91 or 92
AND action_information15 NOT IN('91','92');

CURSOR csr_get_body_info2(p_payroll_action_id NUMBER, p_tax_unit_id NUMBER,p_action_context_id NUMBER, p_effective_date DATE, p_assignment_id NUMBER)
IS
SELECT *
FROM pay_action_information pai
WHERE action_context_type = 'AAP'
AND action_information3 = p_payroll_action_id
AND action_information_category = 'EMEA REPORT INFORMATION'
AND action_information1 = 'PYDKSTATSA'
AND action_information6 ='PART2'
AND tax_unit_id = p_tax_unit_id
AND action_context_id = p_action_context_id
AND effective_date = p_effective_date
AND assignment_id = p_assignment_id;

CURSOR csr_get_body_info3(p_payroll_action_id NUMBER, p_tax_unit_id NUMBER,p_action_context_id NUMBER, p_effective_date DATE, p_assignment_id NUMBER)
IS
SELECT *
FROM pay_action_information pai
WHERE action_context_type = 'AAP'
AND action_information3 = p_payroll_action_id
AND action_information_category = 'EMEA REPORT INFORMATION'
AND action_information1 = 'PYDKSTATSA'
AND action_information6 ='PART3'
AND tax_unit_id = p_tax_unit_id
AND action_context_id = p_action_context_id
AND effective_date = p_effective_date
AND assignment_id = p_assignment_id;

rec_get_hdr_info csr_get_hdr_info%ROWTYPE;
rec_get_body_info2 csr_get_body_info2%ROWTYPE;
rec_get_body_info3 csr_get_body_info3%ROWTYPE;

l_counter             NUMBER := 0;
l_le_count            NUMBER := 0;
l_payroll_action_id   NUMBER;

l_sign                VARCHAR2(80);
l_bal                 VARCHAR2(80);

TYPE iptype_rec_type IS RECORD
(
    iptype VARCHAR2(240) := ' ',
    mkode  VARCHAR2(240) := ' '
);

TYPE iltype_rec_type IS RECORD
(
    iltype VARCHAR2(240) := ' ',
    bal    VARCHAR2(240) := ' ',
    units  VARCHAR2(240) := ' '
);


TYPE iptype_tab_type
IS TABLE OF iptype_rec_type
INDEX BY BINARY_INTEGER;


TYPE iltype_tab_type
IS TABLE OF  iltype_rec_type
INDEX BY BINARY_INTEGER;


iptype_tab iptype_tab_type;
iltype_tab iltype_tab_type;

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

        xml_tab(l_counter).TagName  :='FILE_HEADER_FOOTER_START';
        xml_tab(l_counter).TagValue :='FILE_HEADER_FOOTER_START';
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='CHAR_SET';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information8;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='FILE_FORMAT';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information9;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='SENDER_CVR_NO';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information10;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='SENDER_NAME';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information11;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='SENDER_ADDR';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information12;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='SENDER_PCODE';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information13;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='ITYPE_FILE_START';
        xml_tab(l_counter).TagValue := '1';
        l_counter := l_counter + 1;

        FOR rec_get_chdr_info IN csr_get_chdr_info(l_payroll_action_id)
        LOOP

                xml_tab(l_counter).TagName  :='COMPANY_HEADER_FOOTER_START';
                xml_tab(l_counter).TagValue :='COMPANY_HEADER_FOOTER_START';
                l_counter := l_counter + 1;

                l_le_count := 0;

                xml_tab(l_counter).TagName  :='LE_CVR_NO';
                xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information5;
                l_counter := l_counter + 1;

                xml_tab(l_counter).TagName  :='LE_DS_WCODE';
                xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information6;
                l_counter := l_counter + 1;

                xml_tab(l_counter).TagName  :='LE_DA_SCODE';
                xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information7;
                l_counter := l_counter + 1;

                xml_tab(l_counter).TagName  :='LE_NAME';
                xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information8;
                l_counter := l_counter + 1;

                xml_tab(l_counter).TagName  :='LE_ADDR';
                xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information9;
                l_counter := l_counter + 1;

                xml_tab(l_counter).TagName  :='LE_PCODE';
                xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information10;
                l_counter := l_counter + 1;

                xml_tab(l_counter).TagName  :='LE_PUNIT';
                xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information11;
                l_counter := l_counter + 1;

                xml_tab(l_counter).TagName  :='ITYPE_COMPANY_START';
                xml_tab(l_counter).TagValue := '2';
                l_counter := l_counter + 1;

                FOR rec_get_body_info IN csr_get_body_info1(l_payroll_action_id,rec_get_chdr_info.tax_unit_id)
                LOOP

                OPEN csr_get_body_info2(l_payroll_action_id ,rec_get_body_info.tax_unit_id,rec_get_body_info.action_context_id, rec_get_body_info.effective_date, rec_get_body_info.assignment_id);
                FETCH csr_get_body_info2 INTO rec_get_body_info2;
                CLOSE csr_get_body_info2;

                OPEN csr_get_body_info3(l_payroll_action_id ,rec_get_body_info.tax_unit_id,rec_get_body_info.action_context_id, rec_get_body_info.effective_date, rec_get_body_info.assignment_id);
                FETCH csr_get_body_info3 INTO rec_get_body_info3;
                CLOSE csr_get_body_info3;

                iptype_tab(1).iptype := '0100';
                iptype_tab(1).mkode := rec_get_body_info.action_information7;

                iptype_tab(2).iptype := '0200';
                iptype_tab(2).mkode := rec_get_body_info.action_information8;

                -- For Bug 9192751
                --iptype_tab(3).iptype := '0300';
		    iptype_tab(3).iptype := '0350';
                iptype_tab(3).mkode := rec_get_body_info.action_information9;

                iptype_tab(4).iptype := '0400';
                iptype_tab(4).mkode := rec_get_body_info.action_information10;

                iptype_tab(5).iptype := '0600';
                /* Modified for bug number 4998056. Multiply the amount with 100 to avoid decimal point */
            iptype_tab(5).mkode := nvl(round(FND_NUMBER.CANONICAL_TO_NUMBER(trim(rec_get_body_info.action_information11)),2) * 100,0);

                iptype_tab(6).iptype := '0610';
                /* Modified for bug number 4998056. Multiply the amount with 100 to avoid decimal point */
            iptype_tab(6).mkode := nvl(round(FND_NUMBER.CANONICAL_TO_NUMBER(trim(rec_get_body_info.action_information12)),2) * 100,0);

                iptype_tab(7).iptype := '0620';
                /* Modified for bug number 4998056. Multiply the amount with 100 to avoid decimal point */
            iptype_tab(7).mkode := nvl(round(FND_NUMBER.CANONICAL_TO_NUMBER(trim(rec_get_body_info.action_information13)),2) * 100,0);

                iptype_tab(8).iptype := '0700';
                iptype_tab(8).mkode := rec_get_body_info.action_information14;

                iptype_tab(9).iptype := '0800';
                iptype_tab(9).mkode := rec_get_body_info.action_information15;

                /* Fixed to be 0010 for bug fix 4998180 */
                iltype_tab(1).iltype := '0010'; --'0100';
                iltype_tab(1).bal := rec_get_body_info.action_information16;
                iltype_tab(1).units := rec_get_body_info2.action_information7;

                iltype_tab(2).iltype := '0011';
                iltype_tab(2).bal := rec_get_body_info.action_information17;
                iltype_tab(2).units := rec_get_body_info2.action_information8;

                iltype_tab(3).iltype := '0013';
                iltype_tab(3).bal := rec_get_body_info.action_information18;
                iltype_tab(3).units := rec_get_body_info2.action_information9;

                iltype_tab(4).iltype := '0015';
                iltype_tab(4).bal := rec_get_body_info.action_information19;
                iltype_tab(4).units := rec_get_body_info2.action_information10;

                /*
                iltype_tab(5).iltype := '0021';
                iltype_tab(5).bal := rec_get_body_info.action_information20;
                iltype_tab(5).units := rec_get_body_info2.action_information11;*/

                iltype_tab(5).iltype := '0121';
                iltype_tab(5).bal := rec_get_body_info3.action_information19;
                iltype_tab(5).units := rec_get_body_info3.action_information7;

                iltype_tab(6).iltype := '0122';
                iltype_tab(6).bal := rec_get_body_info3.action_information20;
                iltype_tab(6).units := rec_get_body_info3.action_information8;

                iltype_tab(7).iltype := '0022';
                iltype_tab(7).bal := rec_get_body_info.action_information21;
                iltype_tab(7).units := rec_get_body_info2.action_information12;

                iltype_tab(8).iltype := '0023';
                iltype_tab(8).bal := rec_get_body_info.action_information22;
                iltype_tab(8).units := rec_get_body_info2.action_information13;

                iltype_tab(9).iltype := '0024';
                iltype_tab(9).bal := rec_get_body_info.action_information23;
                iltype_tab(9).units := rec_get_body_info2.action_information14;

                iltype_tab(10).iltype := '0025';
                iltype_tab(10).bal := rec_get_body_info.action_information24;
                iltype_tab(10).units := rec_get_body_info2.action_information15;

                iltype_tab(11).iltype := '0026';
                iltype_tab(11).bal := rec_get_body_info.action_information25;
                iltype_tab(11).units := rec_get_body_info2.action_information16;

                iltype_tab(12).iltype := '0027';
                iltype_tab(12).bal := rec_get_body_info3.action_information21;
                iltype_tab(12).units := rec_get_body_info3.action_information9;

                iltype_tab(13).iltype := '0029';
                iltype_tab(13).bal := rec_get_body_info3.action_information22;
                iltype_tab(13).units := rec_get_body_info3.action_information10;

                iltype_tab(14).iltype := '0032';
                iltype_tab(14).bal := rec_get_body_info.action_information26;
                iltype_tab(14).units := rec_get_body_info2.action_information17;

                iltype_tab(15).iltype := '0034';
                iltype_tab(15).bal := rec_get_body_info.action_information27;
                iltype_tab(15).units := rec_get_body_info2.action_information18;

                iltype_tab(16).iltype := '0035';
                iltype_tab(16).bal := rec_get_body_info3.action_information23;
                iltype_tab(16).units := rec_get_body_info3.action_information11;

                iltype_tab(17).iltype := '0036';
                iltype_tab(17).bal := rec_get_body_info.action_information28;
                iltype_tab(17).units := rec_get_body_info2.action_information19;

                iltype_tab(18).iltype := '0037';
                iltype_tab(18).bal := rec_get_body_info.action_information29;
                iltype_tab(18).units := rec_get_body_info2.action_information20;

                iltype_tab(19).iltype := '0091';
                iltype_tab(19).bal := rec_get_body_info3.action_information24;
                iltype_tab(19).units := rec_get_body_info3.action_information12;

                iltype_tab(20).iltype := '0210';
                iltype_tab(20).bal := rec_get_body_info3.action_information25;
                iltype_tab(20).units := rec_get_body_info3.action_information13;

                iltype_tab(21).iltype := '0132';
                iltype_tab(21).bal := rec_get_body_info3.action_information26;
                iltype_tab(21).units := rec_get_body_info3.action_information14;

                iltype_tab(22).iltype := '0232';
                iltype_tab(22).bal := rec_get_body_info3.action_information27;
                iltype_tab(22).units := rec_get_body_info3.action_information15;

                iltype_tab(23).iltype := '0332';
                iltype_tab(23).bal := rec_get_body_info3.action_information28;
                iltype_tab(23).units := rec_get_body_info3.action_information16;

                    FOR i IN 1..iptype_tab.COUNT
                    LOOP

--                     IF(iptype_tab(i).mkode <> ' ') THEN
                       /* Bug Fix 5030983 - Commented the if condition below which is restricting the
                          display of personal record 0600 with payroll period as weekly and biweekly.*/
--                       IF NOT(iptype_tab(i).iptype ='0600' AND rec_get_body_info.action_information14 IN('2','3')) THEN

                        xml_tab(l_counter).TagName  :='PERSON_RECO_START';
                        xml_tab(l_counter).TagValue :='PERSON_RECO_START';
                        l_counter := l_counter + 1;

                l_le_count := l_le_count + 1;

                        xml_tab(l_counter).TagName  :='LE_CVR_NO';
                        xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information5;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='LE_DS_WCODE';
                        xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information6;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='LE_DA_SCODE';
                        xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information7;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='ASSG_NO';
                        xml_tab(l_counter).TagValue := rec_get_body_info.action_information4;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='CPR_NO';
                        xml_tab(l_counter).TagValue := rec_get_body_info.action_information5;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='IPTYPE';
                        xml_tab(l_counter).TagValue := iptype_tab(i).iptype;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='MKODE';
                        xml_tab(l_counter).TagValue := iptype_tab(i).mkode;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='EFF_DATE';
                        xml_tab(l_counter).TagValue := rec_get_body_info2.action_information5;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='DATE_FROM';
                        xml_tab(l_counter).TagValue := rec_get_body_info2.action_information23;    --rec_get_hdr_info.action_information6;  --8848543
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='DATE_TO';
                        xml_tab(l_counter).TagValue := rec_get_body_info2.action_information24;    --rec_get_hdr_info.action_information7;  --8848543
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='ITYPE_PERSON';
                        xml_tab(l_counter).TagValue := '3';
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='ASG_PUNIT';
                        xml_tab(l_counter).TagValue := rec_get_body_info2.action_information22;
                        l_counter := l_counter + 1;


                        xml_tab(l_counter).TagName  :='PERSON_RECO_START';
                        xml_tab(l_counter).TagValue :='PERSON_RECO_END';
                        l_counter := l_counter + 1;

--                       END IF; -- Bug Fix 5030983 - Commented

                    END LOOP;
                    FOR j IN 1..iltype_tab.COUNT
                    LOOP

                    /* Modified condition to show balances only if they are non-zero after FS changes */

                        /*IF NOT(iltype_tab(j).iltype IN ('0011','0015','0022','0024','0026','0032','0036') AND iltype_tab(j).bal = '0')
                            OR (iltype_tab(j).iltype = '0037' AND rec_get_body_info.action_information4 <>'N')
                            OR (iltype_tab(j).iltype = '0024' AND rec_get_body_info.action_information14 IN('2','3'))
                            OR (iltype_tab(j).iltype = '0025' AND rec_get_body_info.action_information14 ='1')
                            */
                      /*Modified with or clause for 0026 for bug5009836 */
                       /* IF  ( iltype_tab(j).bal <> '0'
                            OR (iltype_tab(j).iltype = '0037' AND rec_get_body_info.action_information4 ='N')
                            OR (iltype_tab(j).iltype = '0024' AND rec_get_body_info.action_information14 IN('2','3'))
                            OR (iltype_tab(j).iltype = '0025' AND rec_get_body_info.action_information14 ='1')
                            OR (iltype_tab(j).iltype = '0026') )
                        THEN*/
                  /* pgopal - Bug 5747199 fix - Checking Hourly/Salaried*/
                  /*Bug fix 5009836 include a check on unit for record 026 */
                        IF  ( iltype_tab(j).bal <> '0'
                            OR (iltype_tab(j).iltype = '0037' AND rec_get_body_info.action_information4 ='N')
                            OR (iltype_tab(j).iltype = '0024' AND rec_get_body_info.action_information30 ='H')
                            OR (iltype_tab(j).iltype = '0025' AND rec_get_body_info.action_information30 ='S')
                            OR (iltype_tab(j).iltype IN ('0026', '0210', '0034') AND iltype_tab(j).units <> '0') )  --8848543
                        THEN

                        xml_tab(l_counter).TagName  :='SALARY_RECO_START';
                        xml_tab(l_counter).TagValue :='SALARY_RECO_START';
                        l_counter := l_counter + 1;

                        l_le_count := l_le_count + 1;

                        xml_tab(l_counter).TagName  :='LE_CVR_NO';
                        xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information5;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='LE_DS_WCODE';
                        xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information6;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='LE_DA_SCODE';
                        xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information7;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='ASSG_NO';
                        xml_tab(l_counter).TagValue := rec_get_body_info.action_information4;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='CPR_NO';
                        xml_tab(l_counter).TagValue := rec_get_body_info.action_information5;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='ILTYPE';
                        xml_tab(l_counter).TagValue := iltype_tab(j).iltype;
                        l_counter := l_counter + 1;

                        IF (substr(iltype_tab(j).units,1,1) = '-') THEN
                         l_sign := '-';
                         l_bal  := substr(iltype_tab(j).units,2);
                        ELSE
                         l_sign := '+';
                         l_bal  := iltype_tab(j).units;
                        END IF;

                        xml_tab(l_counter).TagName  :='TIME_UNITS';
                        /* Modified for bug number 4997824. Multiply the balances with 100 to avoid decimal point */
                  xml_tab(l_counter).TagValue := round(FND_NUMBER.CANONICAL_TO_NUMBER(l_bal),2) * 100;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='SIGN_UNITS';
                        xml_tab(l_counter).TagValue := l_sign;
                        l_counter := l_counter + 1;


                        IF (substr(iltype_tab(j).bal,1,1) = '-') THEN
                         l_sign := '-';
                         l_bal  := substr(iltype_tab(j).bal,2);
                        ELSE
                         l_sign := '+';
                         l_bal  := iltype_tab(j).bal;
                        END IF;

                        xml_tab(l_counter).TagName  :='ILTYPE_BAL';
                        /* Modified for bug number 4997824. Multiply the amount with 100 to avoid decimal point */
                        xml_tab(l_counter).TagValue := round(FND_NUMBER.CANONICAL_TO_NUMBER(l_bal),2) * 100;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='SIGN_BAL';
                        xml_tab(l_counter).TagValue := l_sign;
                        l_counter := l_counter + 1;
               -- Changed for bug 5003220 to display end date instead of ass end date
                        xml_tab(l_counter).TagName  :='DATE_FROM';
                        xml_tab(l_counter).TagValue := rec_get_body_info2.action_information5;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='DATE_TO';
                        xml_tab(l_counter).TagValue := rec_get_body_info2.action_information21;
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='ITYPE_SALARY';
                        xml_tab(l_counter).TagValue := '4';
                        l_counter := l_counter + 1;

                        xml_tab(l_counter).TagName  :='ASG_PUNIT';
                        xml_tab(l_counter).TagValue := rec_get_body_info2.action_information22;
                        l_counter := l_counter + 1;


                        xml_tab(l_counter).TagName  :='SALARY_RECO_START';
                        xml_tab(l_counter).TagValue :='SALARY_RECO_END';
                        l_counter := l_counter + 1;

                        END IF;

                    END LOOP;

                END LOOP;

                xml_tab(l_counter).TagName  :='ITYPE_COMPANY_END';
                xml_tab(l_counter).TagValue := '7';
                l_counter := l_counter + 1;

                xml_tab(l_counter).TagName  :='COUNT_LE';
                xml_tab(l_counter).TagValue := l_le_count;
                l_counter := l_counter + 1;

                xml_tab(l_counter).TagName  :='LE_PUNIT';
                xml_tab(l_counter).TagValue := rec_get_chdr_info.action_information11;
                l_counter := l_counter + 1;

                xml_tab(l_counter).TagName  :='COMPANY_HEADER_FOOTER_START';
                xml_tab(l_counter).TagValue :='COMPANY_HEADER_FOOTER_END';
                l_counter := l_counter + 1;

        END LOOP;

        xml_tab(l_counter).TagName  :='ITYPE_FILE_END';
        xml_tab(l_counter).TagValue := '9';
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='BG_DA_SYS_NO';
        xml_tab(l_counter).TagValue := rec_get_hdr_info.action_information14;
        l_counter := l_counter + 1;

        xml_tab(l_counter).TagName  :='UPDATE_DATE';
        xml_tab(l_counter).TagValue :=  to_char(rec_get_hdr_info.effective_date,'YYYYMMDD');
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

                                IF l_str9 IN ('FILE_HEADER_FOOTER_START', 'FILE_HEADER_FOOTER_END','COMPANY_HEADER_FOOTER_START' ,'COMPANY_HEADER_FOOTER_END'
                                ,'PERSON_RECO_START','PERSON_RECO_END','SALARY_RECO_START','SALARY_RECO_END') THEN

                                                IF l_str9 IN ('FILE_HEADER_FOOTER_START' , 'COMPANY_HEADER_FOOTER_START' , 'PERSON_RECO_START','SALARY_RECO_START') THEN
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

END PAY_DK_STATSR_PKG;

/
