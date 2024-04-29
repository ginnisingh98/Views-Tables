--------------------------------------------------------
--  DDL for Package Body PER_ES_SS_REP_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ES_SS_REP_ARCHIVE_PKG" AS
/* $Header: peesssar.pkb 120.4 2006/03/02 01:10:21 kseth noship $ */

--
-- Globals
--
g_effective_end_date       DATE;
g_test_flag                VARCHAR2(1);
g_effective_date           DATE;
g_business_group_id        NUMBER;
g_arch_payroll_action_id   NUMBER;
g_organization_id          NUMBER;
--------------------------------------------------------------------------------
-- GET_SS_DETAILS
--------------------------------------------------------------------------------
PROCEDURE get_ss_details (p_assignment_id        NUMBER
                         ,p_reporting_date       DATE
                         ,p_under_repres_women   OUT NOCOPY VARCHAR2
                         ,p_rehired_disabled     OUT NOCOPY VARCHAR2
                         ,p_unemployment_status  OUT NOCOPY VARCHAR2
                         ,p_first_contractor     OUT NOCOPY VARCHAR2
                         ,p_after_two_years      OUT NOCOPY VARCHAR2
                         ,p_active_rent_flag     OUT NOCOPY VARCHAR2
                         ,p_minority_group_flag  OUT NOCOPY VARCHAR2) AS
--
    CURSOR csr_get_ss_details IS
    SELECT e.assignment_id AS Assignment_Id
          ,min(decode(i.name,'Unemployment Status',v.screen_entry_value,NULL)) AS Unemployment_Status_Code
          ,min(decode(i.name,'Contract Indicators',substr(v.screen_entry_value,2,1),NULL)) AS Rehired_Disabled_Code
          ,min(decode(i.name,'Contract Indicators',substr(v.screen_entry_value,3,1),NULL)) AS First_Contractor_Code
          ,min(decode(i.name,'Contract Indicators',substr(v.screen_entry_value,5,1),NULL)) AS Under_Represented_Women_Code
          ,min(decode(i.name,'Contract Indicators',substr(v.screen_entry_value,6,1),NULL)) AS After_Childbirth_Code
          ,min(decode(i.name,'Contract Indicators',substr(v.screen_entry_value,1,1),NULL)) AS Active_Rent_Flag
          ,min(decode(i.name,'Contract Indicators',substr(v.screen_entry_value,4,1),NULL)) AS Minority_Group_Flag
    FROM   pay_element_entries_f e
          ,pay_input_values_f i
          ,pay_element_entry_values_f v
          ,pay_element_types_f t
          ,pay_element_links_f l
    WHERE  e.element_entry_id   = v.element_entry_id
    AND    v.input_value_id     = i.input_value_id
    AND    i.legislation_code   = 'ES'
    AND    i.element_type_id    = t.element_type_id
    AND    t.element_type_id    = l.element_type_id
    AND    l.element_link_id    = e.element_link_id
    AND    t.element_name       = 'Social Security Details'
    AND    t.legislation_code   = 'ES'
    AND    e.assignment_id      = p_assignment_id
    AND    p_reporting_date BETWEEN e.effective_start_date AND e.effective_end_date
    AND    p_reporting_date BETWEEN v.effective_start_date AND v.effective_end_date
    AND    p_reporting_date BETWEEN i.effective_start_date AND i.effective_end_date
    AND    p_reporting_date BETWEEN t.effective_start_date AND t.effective_end_date
    AND    p_reporting_date BETWEEN l.effective_start_date AND l.effective_end_date
    GROUP BY e.assignment_id;
    --
    l_assignment_id per_all_assignments_f.assignment_id%TYPE;
    --
BEGIN
    --
    OPEN csr_get_ss_details;
    FETCH csr_get_ss_details INTO l_assignment_id
                                 ,p_unemployment_status
                                 ,p_rehired_disabled
                                 ,p_first_contractor
                                 ,p_under_repres_women
                                 ,p_after_two_years
                                 ,p_active_rent_flag
                                 ,p_minority_group_flag;
    CLOSE csr_get_ss_details;
    --
END get_ss_details;
--------------------------------------------------------------------------------
-- get_disability_degree
--------------------------------------------------------------------------------
PROCEDURE get_disability_degree (p_assignment_id  IN NUMBER
                                ,p_reporting_date IN DATE
                                ,p_degree         OUT NOCOPY NUMBER) AS
--
    CURSOR csr_get_disability_degree IS
    SELECT   pdf.degree
    FROM     per_all_people_f       pap
            ,per_disabilities_f     pdf
            ,per_all_assignments_f  paa
    WHERE    pap.person_id     = pdf.person_id
    AND      pap.person_id     = paa.person_id
    AND      paa.assignment_id = p_assignment_id
    AND      p_reporting_date  BETWEEN  pdf.effective_start_date
                               AND      pdf.effective_end_date
    AND      p_reporting_date  BETWEEN  pap.effective_start_date
                               AND      pap.effective_end_date
    AND      p_reporting_date  BETWEEN  paa.effective_start_date
                               AND      paa.effective_end_date;
--
BEGIN
    OPEN csr_get_disability_degree;
    FETCH csr_get_disability_degree INTO p_degree;
    CLOSE csr_get_disability_degree;
END get_disability_degree;
--------------------------------------------------------------------------------
-- FUNCTION get_iso_country_code
--------------------------------------------------------------------------------
FUNCTION get_iso_country_code(p_employer_employee  VARCHAR2
                             ,p_lookup_code        VARCHAR2
                             ,p_business_group_id  NUMBER) RETURN VARCHAR2 IS
    --
    CURSOR csr_system_type_cd IS
    SELECT system_type_cd
    FROM   per_shared_types
    WHERE  lookup_type = 'ES_NATIONALITY'
    AND    NVL(business_group_id,p_business_group_id)
             = p_business_group_id
    AND    information1 = p_lookup_code;
    --
    CURSOR csr_iso_country_code IS
    SELECT iso_numeric_code
    FROM   fnd_territories
    WHERE  territory_code = p_lookup_code;
    --
    l_iso_code per_shared_types.system_type_cd%TYPE;
    --
BEGIN
    --
    IF  p_employer_employee = 'EMPLOYEE' THEN
        OPEN  csr_system_type_cd;
        FETCH csr_system_type_cd INTO l_iso_code;
        CLOSE csr_system_type_cd;
    END IF;
    IF  p_employer_employee = 'EMPLOYER' THEN
        OPEN  csr_iso_country_code;
        FETCH csr_iso_country_code INTO l_iso_code;
        CLOSE csr_iso_country_code;
    END IF;
    --
    RETURN l_iso_code;
    --
END get_iso_country_code;
--------------------------------------------------------------------------------
-- GET_PARAMETER
--------------------------------------------------------------------------------
FUNCTION get_parameter(
         p_parameter_string IN VARCHAR2
        ,p_token            IN VARCHAR2) RETURN VARCHAR2 IS
--
    l_parameter  pay_payroll_actions.legislative_parameters%TYPE;
    l_start_pos  NUMBER;
    l_delimiter  VARCHAR2(1);
--
BEGIN
    l_delimiter := ' ';
    l_parameter := NULL;
    l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
    IF l_start_pos = 0 THEN
        l_delimiter := '|';
        l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
    END IF;
    IF l_start_pos <> 0 THEN
        l_start_pos := l_start_pos + length(p_token||'=');
        l_parameter := substr(p_parameter_string,
                              l_start_pos,
                              instr(p_parameter_string||' ',
                              l_delimiter,l_start_pos)
                              - l_start_pos);
    END IF;
    RETURN l_parameter;
END get_parameter;
--------------------------------------------------------------------------------
-- GET_ALL_PARAMETERS                gets all parameters for the payroll action
--------------------------------------------------------------------------------
PROCEDURE get_all_parameters (
          p_payroll_action_id      IN  NUMBER
         ,p_effective_end_Date     OUT NOCOPY DATE
	     ,p_test_flag              OUT NOCOPY VARCHAR2
         ,p_effective_date         OUT NOCOPY DATE
	     ,p_business_group_id      OUT NOCOPY NUMBER
         ,p_organization_id        OUT NOCOPY NUMBER
         ,p_assignment_set_id      OUT NOCOPY NUMBER) IS
    --
    CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
    SELECT effective_date
          ,PER_ES_SS_REP_ARCHIVE_PKG.get_parameter(legislative_parameters, 'TEST_FLAG')
          ,PER_ES_SS_REP_ARCHIVE_PKG.get_parameter(legislative_parameters, 'SES_DATE')
          ,PER_ES_SS_REP_ARCHIVE_PKG.get_parameter(legislative_parameters, 'ORG_ID')
          ,PER_ES_SS_REP_ARCHIVE_PKG.get_parameter(legislative_parameters, 'ASG_SET_ID')
          ,business_group_id
    FROM   pay_payroll_actions
    WHERE  payroll_action_id = p_payroll_action_id;
    --
    l_effective_Date        VARCHAR2(50);
    l_test_flag             VARCHAR2(1);
    --
BEGIN
    OPEN  csr_parameter_info (p_payroll_action_id);
    FETCH csr_parameter_info INTO p_effective_end_date
                                 ,l_test_flag
                                 ,l_effective_date
                                 ,p_organization_id
                                 ,p_assignment_set_id
                                 ,p_business_group_id;
    CLOSE csr_parameter_info;
    --
    p_effective_Date := fnd_date.canonical_to_date(l_effective_date);
    p_test_flag      := l_test_flag;
    --
    EXCEPTION
    WHEN others THEN
    NULL;
END get_all_parameters;
--------------------------------------------------------------------------------
--GET_ALL_PARAMETERS_LOCK
--------------------------------------------------------------------------------
PROCEDURE get_all_parameters_lock (
          p_payroll_action_id      IN  NUMBER
	       ,p_arch_payroll_action_id OUT NOCOPY NUMBER
	       ,p_effective_end_date     OUT NOCOPY DATE) IS
    --
    CURSOR   csr_parameter_info(p_payroll_action_id NUMBER) IS
    SELECT   per_es_ss_rep_archive_pkg.get_parameter(legislative_parameters
                                                  ,'PAYROLL_ACTION_ID')
    FROM     pay_payroll_actions
    WHERE    payroll_action_id = p_payroll_action_id;
    --
    CURSOR   csr_parameter_info_date(p_payroll_action_id NUMBER) IS
    SELECT   effective_date
    FROM     pay_payroll_actions
    WHERE    payroll_action_id = p_payroll_action_id;
    --
    l_payroll_action_id     VARCHAR2(15);
    --
BEGIN
    --
    OPEN csr_parameter_info (p_payroll_action_id);
    FETCH csr_parameter_info INTO l_payroll_action_id;
    CLOSE csr_parameter_info;
    --
    OPEN csr_parameter_info_date (to_number(l_payroll_action_id));
    FETCH csr_parameter_info_date INTO p_effective_end_date;
    CLOSE csr_parameter_info_date;
    --
    p_arch_payroll_action_id := to_number(l_payroll_action_id);
    --
END get_all_parameters_lock;
--------------------------------------------------------------------------------
-- RANGE CURSOR  - Returns the Range Cursor String
--------------------------------------------------------------------------------
PROCEDURE range_cursor_archive(
          pactid                       IN         NUMBER
         ,sqlstr                       OUT NOCOPY VARCHAR) IS

    --
    BAD     EXCEPTION;
    l_text  fnd_lookup_values.meaning%TYPE;
    --
    CURSOR csr_header_details (c_business_group_id NUMBER, c_effective_end_date DATE,c_organization_id NUMBER) IS
    SELECT /* Getting ETI and ETF Information */
           /* Segment Header, Msg Syntax ID, Syntax version, Process Syntax ID and Version are defaulted */
            hoi.org_information12       Authorization_key
           ,hoi.org_information11       Silicon_key
           /* Session Date and time is taken as a parameter */
           /* File extension and Proc. priority code are defaulted */
           /* Test Flag is taken from parameter */
           /* Segment Header is defaulted, New Password and Reserved flag are left blank */
           ,hoi.org_information13       Current_password
           /* Getting EMP Information */
           /* Segment Header defaulted*/
           ,'0111'                            SS_Scheme
           ,substr(hoi.org_information8,1,2)  SS_Province
           ,substr(hoi.org_information8,-9)   SS_Number
           ,'9'                               ID_Type --code for cif
           ,hloc.country                country
           ,hoi.org_information5        Employer_ID
           /* Open, Main CAC SS Scheme, Province, SS Number and Reserved are left blank */
           ,' '                         Action_Event
           /* Segment Header and Cmp Reg Flag are defaulted */
           ,hoi.org_information4        Employer_Type
           ,hoi.org_information1        Registered_Name
           ,hoi.organization_id         Legal_emp_org_id
           /* Reserved, Seg. Hdr, Start and End date are defaulted */
    FROM    hr_all_organization_units   hou
           ,hr_organization_information hoi
           ,hr_locations_all            hloc
    WHERE   hou.business_group_id		= c_business_group_id
    AND     hoi.organization_id		    = hou.organization_id
    AND     hoi.org_information_context	= 'ES_STATUTORY_INFO'
    AND     hloc.location_id (+)		= hou.location_id
    AND     hoi.organization_id         = nvl(c_organization_id,hoi.organization_id)
    AND     EXISTS (SELECT asg_run.assignment_id
                    FROM   per_assignment_extra_info    asg_extra
                          ,per_all_assignments_f        asg_run
                    WHERE  asg_extra.aei_information_category = 'ES_SS_REP'
                    AND    asg_extra.INFORMATION_TYPE = 'ES_SS_REP'
                    AND    asg_extra.aei_information5   = 'Y'
                    AND    asg_run.assignment_id        = asg_extra.assignment_id
                    AND    asg_run.business_group_id    = g_business_group_id
                    AND    fnd_date.canonical_to_date(asg_extra.aei_information7) <= c_effective_end_date);
    --
    l_unused_number         NUMBER;
    l_action_info_id        pay_action_information.action_information_id%TYPE;
    l_ovn                   pay_action_information.object_version_number%TYPE;
    l_test_flag             NUMBER;
    l_assignment_set_id     hr_assignment_sets.assignment_set_id%TYPE;
    --
BEGIN
    --
    l_unused_number := 0;
    l_test_flag     := 0;
    -- Get the legislative parameters used in the call to prove the seed data
    -- retrict the list of addresses
    per_es_ss_rep_archive_pkg.get_all_parameters (
                   p_payroll_action_id     => pactid
                  ,p_effective_end_date    => g_effective_end_date
                  ,p_test_flag             => g_test_flag
                  ,p_effective_date        => g_effective_date
                  ,p_business_group_id     => g_business_group_id
                  ,p_organization_id       => g_organization_id
                  ,p_assignment_set_id     => l_assignment_set_id);
    -- Archive the Header Details
    FOR header_details IN csr_header_details (g_business_group_id
                                             ,g_effective_end_date
                                             ,g_organization_id) LOOP
        --
        l_test_flag := 1;
        pay_action_information_api.create_action_information(
                  p_action_information_id       =>  l_action_info_id
                 ,p_action_context_id           =>  pactid
                 ,p_action_context_type         =>  'PA'
                 ,p_object_version_number       =>  l_ovn
                 ,p_action_information_category =>  'ES_SS_REPORT_ETI'
                 ,p_action_information1         =>  header_details.Authorization_key
                 ,p_action_information2         =>  header_details.Silicon_key
                 ,p_action_information3         =>  fnd_date.date_to_canonical(g_effective_date)
                 ,p_action_information4         =>  '0000'
                 ,p_action_information5         =>  fnd_date.date_to_canonical(g_effective_end_date)
                 ,p_action_information6         =>  'AFI'
                 ,p_action_information7         =>  'N'
                 ,p_action_information8         =>  g_test_flag
                 ,p_action_information9         =>  header_details.Current_password
                 ,p_action_information10        =>  ' ');
        --
        pay_action_information_api.create_action_information(
                  p_action_information_id       =>  l_action_info_id
                 ,p_action_context_id           =>  pactid
                 ,p_action_context_type         =>  'PA'
                 ,p_object_version_number       =>  l_ovn
                 ,p_action_information_category =>  'ES_SS_REPORT_EMP'
                 ,p_action_information1         =>  header_details.SS_Scheme
                 ,p_action_information2         =>  header_details.SS_Province
                 ,p_action_information3         =>  header_details.SS_Number
                 ,p_action_information4         =>  header_details.ID_Type
                 ,p_action_information5         =>  get_iso_country_code('EMPLOYER'
                                                                        ,header_details.Country
                                                                        ,g_business_group_id)
                 ,p_action_information6         =>  header_details.Employer_ID
                 ,p_action_information7         =>  NULL
                 ,p_action_information8         =>  NULL
                 ,p_action_information9         =>  NULL
                 ,p_action_information10        =>  header_details.Action_Event
                 ,p_action_information11        =>  header_details.Employer_Type
                 ,p_action_information12        =>  '0'
                 ,p_action_information13        =>  header_details.Registered_Name
                 ,p_action_information14        =>  '0'
                 ,p_action_information15        =>  '0'
                 ,p_action_information16        =>  header_details.Legal_emp_org_id);
        --
    END LOOP;
    --
    IF l_test_flag = 0 THEN
        sqlstr := 'SELECT 1 FROM dual WHERE to_char(:payroll_action_id) = dummy';
    ELSE
        sqlstr := 'SELECT distinct person_id
                   FROM  per_people_f ppf
                        ,pay_payroll_actions ppa
                   WHERE ppa.payroll_action_id = :payroll_action_id
                   AND   ppa.business_group_id = ppf.business_group_id
                   ORDER BY ppf.person_id';
    END IF;
    --
    EXCEPTION
    WHEN OTHERS THEN
        sqlstr := 'SELECT 1 FROM dual WHERE to_char(:payroll_action_id) = dummy';

END range_cursor_archive;
--------------------------------------------------------------------------------
-- ACTION CREATION --
--------------------------------------------------------------------------------
PROCEDURE action_creation_archive(pactid    IN NUMBER,
                                  stperson  IN NUMBER,
                                  endperson IN NUMBER,
                                  chunk     IN NUMBER) IS
    --
    CURSOR csr_qualifying_assignments (c_effective_end_date DATE,c_organization_id NUMBER) IS
    SELECT /* Get the TRA Information */
           /* Segment Header is defaulted, Province and SS Number are left blank */
           -- '12' province
           --'0' SS_NUMBER
           DECODE (pap.national_identifier, NULL, DECODE(pap.per_information2, 'DNI', 1, 'Passport', 2, 6), 1) ID_Type
           ,pap.nationality country_of_birth
           ,DECODE (pap.national_identifier, NULL, pap.per_information3, pap.national_identifier) ID_Number
           /* Reserved flags are left blank */
           ,pap.nationality Nationality
           /* Employee flag and reserved are left blank and Segment Header is defaulted */
           ,RPAD(pap.last_name ,20,' ') first_last_name
           ,RPAD(pap.per_information1,20,' ')  second_last_name
           ,RPAD(pap.first_name,15,' ')  name
           /* Reserved flag is left blank */
           ,paa.assignment_id assignment_id
    FROM    per_all_people_f pap
           ,(SELECT DISTINCT asg_run.assignment_id assignment_id, asg_run.person_id person_id
             FROM   per_assignment_extra_info      asg_extra
                   ,per_all_assignments_f          asg_run
             WHERE  asg_extra.aei_information_category = 'ES_SS_REP'
             AND    asg_extra.aei_information5 = 'Y'
             AND    asg_run.business_group_id = g_business_group_id
             AND    asg_run.assignment_id = asg_extra.assignment_id
             AND    fnd_date.canonical_to_date(asg_extra.aei_information7) <= c_effective_end_date
             AND    asg_run.person_id BETWEEN stperson
                                      AND     endperson) paa
    WHERE   pap.person_id           = paa.person_id
    AND     pap.business_group_id   = g_business_group_id
    AND     c_effective_end_date    BETWEEN pap.effective_start_date
                                    AND pap.effective_end_date
    AND     pap.per_information_category = 'ES';
    --
    CURSOR csr_filter_legal_employer(p_assignment_id  NUMBER
                                    ,p_legal_employer NUMBER
                                    ,p_reporting_date DATE
                                    ,p_payroll_id     NUMBER) IS
    SELECT paf.assignment_id assignment_id,
           leg.organization_id legal_employer
    FROM   per_all_assignments_f paf
          ,hr_soft_coding_keyflex sck
          ,hr_organization_information wcr
          ,hr_organization_information leg
    WHERE  paf.effective_start_date    = (SELECT max (paf1.effective_start_date)
                                          FROM   per_all_assignments_f paf1
                                          WHERE  paf.assignment_id = paf1.assignment_id
                                          AND    paf1.effective_start_date <= p_reporting_date)
    AND    sck.soft_coding_keyflex_id  =  paf.soft_coding_keyflex_id
    AND    sck.segment2                =  wcr.org_information1
    AND    wcr.org_information_context = 'ES_WORK_CENTER_REF'
    AND    wcr.organization_id         =  leg.organization_id
    AND    leg.org_information_context = 'CLASS'
    AND    leg.org_information1        = 'HR_LEGAL_EMPLOYER'
    AND    leg.organization_id         =  NVL(p_legal_employer,leg.organization_id)
    AND    paf.assignment_id           =  p_assignment_id
    AND    ((paf.payroll_id IS NULL AND p_payroll_id IS NULL)OR
             paf.payroll_id = nvl(p_payroll_id,paf.payroll_id));

    -- Added for  DAM segment
    CURSOR csr_contract_details(p_assignment_id NUMBER
                               ,p_reporting_date DATE) IS
    SELECT  pcf.effective_start_date
           ,pcf.ctr_information6    replaced_person_id
           ,pcf.ctr_information7    replacement_reason_code
    FROM    per_contracts_f         pcf
           ,per_all_assignments_f   paf
    WHERE   paf.assignment_id       = p_assignment_id
    AND     paf.person_id           = pcf.person_id
    AND     p_reporting_date  BETWEEN paf.effective_start_date AND paf.effective_end_date
    AND     p_reporting_date  BETWEEN pcf.effective_start_date AND pcf.effective_end_date;
    --
    CURSOR csr_get_ss_identifier_per (c_person_id NUMBER,c_reporting_date DATE) IS
    SELECT nvl(pev.screen_entry_value, 'X') screen_entry_value
    FROM   pay_element_entry_values_f  pev
          ,pay_input_values_f          piv
          ,pay_element_types_f         pet
          ,pay_element_entries_f       pee
          ,pay_element_links_f         pel
          ,per_all_assignments_f       paf
    WHERE  paf.person_id            =  c_person_id
    AND    pee.assignment_id        =  paf.assignment_id
    AND    pev.element_entry_id     =  pee.element_entry_id
    AND    piv.input_value_id       =  pev.input_value_id
    AND    piv.name                 = 'Social Security Identifier'
    AND    piv.legislation_code     = 'ES'
    AND    pet.element_type_id      =  piv.element_type_id
    AND    pet.element_name         = 'Social Security Details'
    AND    pet.legislation_code     = 'ES'
    AND    pel.element_type_id      =  pet.element_type_id
    AND    pee.element_link_id      =  pel.element_link_id
    AND    paf.business_group_id    =  pel.business_group_id
    AND    c_reporting_date BETWEEN paf.effective_start_date AND paf.effective_end_date
    AND    c_reporting_date BETWEEN pev.effective_start_date AND pev.effective_end_date
    AND    c_reporting_date BETWEEN pee.effective_start_date AND pee.effective_end_date
    AND    c_reporting_date BETWEEN piv.effective_start_date AND piv.effective_end_date
    AND    c_reporting_date BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND    c_reporting_date BETWEEN pel.effective_start_date AND pel.effective_end_date;
    --
    CURSOR csr_get_ss_identifier_asg (c_assignment_id NUMBER,c_reporting_date DATE) IS
    SELECT nvl(pev.screen_entry_value, 'X') screen_entry_value
    FROM   pay_element_entry_values_f  pev
          ,pay_input_values_f          piv
          ,pay_element_types_f         pet
          ,pay_element_entries_f       pee
          ,pay_element_links_f         pel
    WHERE  pee.assignment_id        =  c_assignment_id
    AND    pev.element_entry_id     =  pee.element_entry_id
    AND    piv.input_value_id       =  pev.input_value_id
    AND    piv.name                 = 'Social Security Identifier'
    AND    piv.legislation_code     = 'ES'
    AND    pet.element_type_id      =  piv.element_type_id
    AND    pet.element_name         = 'Social Security Details'
    AND    pet.legislation_code     = 'ES'
    AND    pel.element_type_id      =  pet.element_type_id
    AND    pee.element_link_id      =  pel.element_link_id
    AND    c_reporting_date BETWEEN pev.effective_start_date AND pev.effective_end_date
    AND    c_reporting_date BETWEEN pee.effective_start_date AND pee.effective_end_date
    AND    c_reporting_date BETWEEN piv.effective_start_date AND piv.effective_end_date
    AND    c_reporting_date BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND    c_reporting_date BETWEEN pel.effective_start_date AND pel.effective_end_date;
    --
    CURSOR csr_get_asg_ss_details(p_assignment_id NUMBER
                                 ,p_reporting_date DATE) IS
    SELECT e.assignment_id AS Assignment_Id
          ,min(decode(i.name,'Special Relationship Type',v.screen_entry_value,NULL)) AS Active_Rent_Flag
          ,min(decode(i.name,'Retirement Age Reduction',v.screen_entry_value,NULL)) AS Minority_Group_Flag
    FROM   pay_element_entries_f        e
          ,pay_input_values_f           i
          ,pay_element_entry_values_f   v
          ,pay_element_types_f          t
          ,pay_element_links_f          l
    WHERE  e.element_entry_id   = v.element_entry_id
    AND    v.input_value_id     = i.input_value_id
    AND    i.element_type_id    = t.element_type_id
    AND    i.legislation_code   = 'ES'
    AND    t.element_type_id    = l.element_type_id
    AND    l.element_link_id    = e.element_link_id
    AND    t.element_name       = 'Multiple Employment Details'
    AND    t.legislation_code   = 'ES'
    AND    e.assignment_id      = p_assignment_id
    AND    p_reporting_date BETWEEN e.effective_start_date AND e.effective_end_date
    AND    p_reporting_date BETWEEN v.effective_start_date AND v.effective_end_date
    AND    p_reporting_date BETWEEN i.effective_start_date AND i.effective_end_date
    AND    p_reporting_date BETWEEN t.effective_start_date AND t.effective_end_date
    AND    p_reporting_date BETWEEN l.effective_start_date AND l.effective_end_date
    GROUP BY e.assignment_id;

    -- Checking whether the employee is already archived or not
    CURSOR check_employee_exists (c_assignment_id NUMBER, c_actid NUMBER) IS
    SELECT count(1)
    FROM   pay_action_information
    WHERE  action_information_category = 'ES_SS_REPORT_TRA'
    AND    action_context_type         = 'AAP'
    AND    action_context_id           = c_actid
    AND    assignment_id               = c_assignment_id;
    --
    --Assignment number to display in the Audit Report
    CURSOR csr_get_asg_details(c_assignment_id NUMBER) IS
    SELECT paf.assignment_number    asg_no
    FROM   per_all_assignments_f    paf
    WHERE  paf.assignment_id        = c_assignment_id
    ORDER BY paf.effective_start_date DESC;
    --
    --Fetching the payroll id for the assignment_set
    CURSOR csr_get_payroll_id(c_assignment_set_id NUMBER,c_business_group_id NUMBER) IS
    SELECT has.payroll_id
    FROM   hr_assignment_sets has
    WHERE  has.assignment_set_id = c_assignment_set_id
    AND    has.business_group_id = c_business_group_id;
    --
    CURSOR csr_incl_excl(c_assignment_id NUMBER,c_assignment_set_id NUMBER) IS
    SELECT include_or_exclude
    FROM   hr_assignment_set_amendments hasa
    WHERE  hasa.assignment_set_id = c_assignment_set_id
    AND    hasa.assignment_id     = c_assignment_id;
    --
    CURSOR csr_province_code(c_assignment_id NUMBER
                            ,c_business_group_id NUMBER
                            ,c_reporting_date DATE) IS
    SELECT region_2
    FROM   per_addresses          pas
          ,per_all_people_f       pap
          ,per_all_assignments_f  paa
    WHERE  paa.person_id         =  pap.person_id
    AND    pas.person_id         =  pap.person_id
    AND    paa.assignment_id     =  c_assignment_id
    AND    pas.business_group_id =  c_business_group_id
    AND    pas.primary_flag      = 'Y'
    AND    c_reporting_date  BETWEEN  pap.effective_start_date
                             AND      pap.effective_end_date
    AND    c_reporting_date  BETWEEN  paa.effective_start_date
                             AND      paa.effective_end_date;
    --
    l_assignment_number        per_all_assignments_f.assignment_number%TYPE;
    l_actid                    pay_assignment_actions.assignment_action_id%TYPE;
    l_unused_number            NUMBER;
    l_action_info_id           pay_action_information.action_information_id%TYPE;
    l_ovn                      pay_action_information.object_version_number%TYPE;
    l_contract_start_date      DATE;
    l_replace_person_id        per_all_people_f.person_id%TYPE;
    l_replacement_reason_code  per_contracts_f.ctr_information7%TYPE;
    l_ss_identifier            pay_element_entry_values_f.screen_entry_value%TYPE;
    l_assignment_id            per_all_assignments_f.assignment_id%TYPE;
    l_relationship_type        pay_element_entry_values_f.screen_entry_value%TYPE;
    l_retirement_age_reduction pay_element_entry_values_f.screen_entry_value%TYPE;
    l_assignment_set_id        hr_assignment_sets.assignment_set_id%TYPE;
    l_payroll_id               hr_assignment_sets.payroll_id%TYPE;
    l_incl_excl                hr_assignment_set_amendments.include_or_exclude%TYPE;
    l_legal_employer           hr_all_organization_units.organization_id%TYPE;
    l_province_code            per_addresses.region_2%TYPE;
    l_ss_number                pay_element_entry_values_f.screen_entry_value%TYPE;
    --
BEGIN
    --
    l_unused_number := 0;
    --
    per_es_ss_rep_archive_pkg.get_all_parameters (
                     p_payroll_action_id     => pactid
                    ,p_effective_end_date    => g_effective_end_date
                    ,p_test_flag             => g_test_flag
                    ,p_effective_date        => g_effective_date
                    ,p_business_group_id     => g_business_group_id
                    ,p_organization_id       => g_organization_id
                    ,p_assignment_set_id     => l_assignment_set_id);

    --- Fetch the payroll_id if any for the assignment_set_id
    IF l_assignment_set_id IS NOT NULL THEN
        OPEN csr_get_payroll_id(l_assignment_set_id,g_business_group_id);
        FETCH csr_get_payroll_id INTO l_payroll_id;
        CLOSE csr_get_payroll_id;
    END IF;
    -- Get any qualifying assignments
    FOR qualifying_assignments IN csr_qualifying_assignments (
                                  g_effective_end_date
                                 ,g_organization_id) LOOP
        --
        IF  l_assignment_set_id IS NOT NULL THEN
            OPEN csr_incl_excl(qualifying_assignments.assignment_id
                              ,l_assignment_set_id);
            FETCH csr_incl_excl INTO l_incl_excl;
            CLOSE csr_incl_excl;
        END IF;
        IF l_incl_excl = 'I' OR l_incl_excl IS NULL OR l_assignment_set_id  IS NULL THEN
            OPEN  csr_filter_legal_employer(qualifying_assignments.assignment_id
                                            ,g_organization_id
                                            ,g_effective_end_date
                                            ,l_payroll_id);
            FETCH csr_filter_legal_employer INTO l_assignment_id,l_legal_employer;

            IF csr_filter_legal_employer%FOUND THEN

                SELECT pay_assignment_actions_s.NEXTVAL
                INTO l_actid
                FROM dual;

                hr_nonrun_asact.insact(l_actid
                                        ,qualifying_assignments.assignment_id
                                        ,pactid
                                        ,chunk
                                        ,NULL);
                /* call the procedure that archives the FAB data into the table for that particular assignment id */
                PER_ES_SS_REP_ARCHIVE_PKG.ARCHIVE_CODE(qualifying_assignments.assignment_id, pactid, l_actid, g_effective_end_date);
                -- Check whether the employee is already archived or not
                OPEN check_employee_exists (qualifying_assignments.assignment_id, l_actid);
                FETCH check_employee_exists INTO l_unused_number;
                CLOSE check_employee_exists;
                IF l_unused_number = 0 THEN
                    l_assignment_number := NULL;
                    OPEN csr_get_asg_details(qualifying_assignments.assignment_id);
                    FETCH csr_get_asg_details INTO l_assignment_number;
                    CLOSE csr_get_asg_details;

                    ---addition for DAM
                    OPEN csr_contract_details(qualifying_assignments.assignment_id,g_effective_end_date);
                    FETCH csr_contract_details INTO l_contract_start_date,l_replace_person_id,l_replacement_reason_code;
                    CLOSE csr_contract_details;

                    OPEN csr_get_ss_identifier_per(l_replace_person_id,g_effective_end_date);
                    FETCH csr_get_ss_identifier_per INTO l_ss_identifier;
                    CLOSE csr_get_ss_identifier_per;

                    OPEN csr_get_asg_ss_details(qualifying_assignments.assignment_id,g_effective_end_date);
                    FETCH csr_get_asg_ss_details INTO l_assignment_id,l_relationship_type,l_retirement_age_reduction;
                    CLOSE csr_get_asg_ss_details;
                    --
                    OPEN csr_province_code(qualifying_assignments.assignment_id
                                          ,g_business_group_id
                                          ,g_effective_end_date);
                    FETCH csr_province_code INTO l_province_code;
                    CLOSE csr_province_code;

                    OPEN csr_get_ss_identifier_asg(qualifying_assignments.assignment_id,g_effective_end_date);
                    FETCH csr_get_ss_identifier_asg INTO l_ss_number;
                    CLOSE csr_get_ss_identifier_asg;
                    --

                    pay_action_information_api.create_action_information(
                        p_action_information_id       =>  l_action_info_id
                       ,p_action_context_id           =>  l_actid
                       ,p_action_context_type         =>  'AAP'
                       ,p_object_version_number       =>  l_ovn
                       ,p_assignment_id               =>  qualifying_assignments.assignment_id
                       ,p_action_information_category =>  'ES_SS_REPORT_TRA'
                       ,p_action_information1         =>  l_province_code
                       ,p_action_information2         =>  l_ss_number
                       ,p_action_information3         =>  qualifying_assignments.ID_Type
                       ,p_action_information4         =>  get_iso_country_code('EMPLOYEE'
                                                                        ,qualifying_assignments.country_of_birth
                                                                        ,g_business_group_id)
                       ,p_action_information5         =>  qualifying_assignments.ID_Number
                       ,p_action_information6         =>  get_iso_country_code('EMPLOYEE'
                                                                        ,qualifying_assignments.Nationality
                                                                        ,g_business_group_id)
                       ,p_action_information7         =>  qualifying_assignments.first_last_name
                       ,p_action_information8         =>  qualifying_assignments.second_last_name
                       ,p_action_information9         =>  qualifying_assignments.name
                       ,p_action_information10        =>  l_assignment_number
                       ,p_action_information11        =>  l_legal_employer
                       ,p_action_information12        =>  fnd_date.date_to_canonical(l_contract_start_date)
                       ,p_action_information13        =>  fnd_date.date_to_canonical(l_contract_start_date)
                       ,p_action_information14        =>  l_relationship_type
                       ,p_action_information15        =>  l_ss_identifier
                       ,p_action_information16        =>  l_replacement_reason_code
                       ,p_action_information17        =>  '0'
                       ,p_action_information18        =>  '0'
                       ,p_action_information19        =>  '0'
                       ,p_action_information20        =>  '0'
                       ,p_action_information21        =>  l_retirement_age_reduction
                       ,p_action_information22        =>  ' ');
                END IF;
                --
            END IF;
        CLOSE csr_filter_legal_employer;
        END IF;
    END LOOP;
    --
END action_creation_archive;
-------------------------------------------------------------------------------
--ARCHIVE CODE
-------------------------------------------------------------------------------
PROCEDURE archive_code
                  (p_assignment_id            IN    NUMBER
		              ,pactid                     IN    NUMBER
  		            ,p_assignment_action_id     IN    NUMBER
   		            ,p_effective_end_date       IN    DATE) IS
    --
    CURSOR csr_get_eit_values (c_assignment_id  NUMBER
                              ,c_effective_end_date DATE) IS
    SELECT   aei_information2           effective_report_date,
             aei_information3           event,
             nvl(aei_information4, 'X') value,
             aei_information6           action_type,
             aei_information7           first_changed_date
    FROM     per_assignment_extra_info
    WHERE    assignment_id              = c_assignment_id
    AND      aei_information5           = 'Y'
    AND      fnd_date.canonical_to_date(aei_information7) <= c_effective_end_date
    ORDER BY aei_information3;
    --
    CURSOR csr_get_asg_values (c_assignment_id  NUMBER
                              ,c_effective_start_date VARCHAR2) IS
    SELECT pap.date_of_birth
          ,pap.sex
          ,paa.assignment_status_type_id
          ,nvl(paa.employment_category, 'X') employment_category
          ,paa.soft_coding_keyflex_id
          ,paa.employee_category employee_category
          ,paa.collective_agreement_id
    FROM   per_all_assignments_f paa
          ,per_all_people_f      pap
    WHERE  paa.assignment_id          = c_assignment_id
    AND    paa.person_id              = pap.person_id
    AND    paa.effective_start_date   = fnd_date.canonical_to_date(c_effective_start_date)
    AND    paa.effective_start_date   BETWEEN pap.effective_start_date
                                      AND     pap.effective_end_date;
    --
    CURSOR csr_get_contribution_group(c_soft_coding_keyflex_id NUMBER) IS
    SELECT nvl(sck.segment5,'X') contribution_group
    FROM   hr_soft_coding_keyflex sck
    WHERE  sck.soft_coding_keyflex_id = c_soft_coding_keyflex_id;
    --
    CURSOR csr_get_element_values (c_assignment_id NUMBER,c_effective_start_date VARCHAR2) IS
    SELECT pee.assignment_id  AS assignment_Id
          ,min(decode(piv.name,'SS Epigraph Code',nvl(pev.screen_entry_value, 'X'),NULL)) AS epigraph_code
          ,min(decode(piv.name,'Contract Key',nvl(pev.screen_entry_value, 'X'),NULL)) AS Contract_Key
    FROM   pay_element_entry_values_f  pev
          ,pay_input_values_f          piv
          ,pay_element_types_f         pet
          ,pay_element_entries_f       pee
          ,pay_element_links_f         pel
    WHERE  pev.element_entry_id     =  pee.element_entry_id
    AND    pee.assignment_id        =  c_assignment_id
    AND    pev.input_value_id       =  piv.input_value_id
    AND    piv.element_type_id      =  pet.element_type_id
    AND    piv.legislation_code     = 'ES'
    AND    pet.element_type_id      =  pel.element_type_id
    AND    pel.element_link_id      =  pee.element_link_id
    AND    pet.element_name         = 'Social Security Details'
    AND    pet.legislation_code     = 'ES'
    AND    pev.effective_start_date = fnd_date.canonical_to_date(c_effective_start_date)
    AND    pev.effective_start_date BETWEEN piv.effective_start_date
                                    AND     piv.effective_end_date
    AND    pev.effective_start_date BETWEEN pet.effective_start_date
                                    AND     pet.effective_end_date
    AND    pev.effective_start_date BETWEEN pee.effective_start_date
                                    AND     pee.effective_end_date
    GROUP BY pee.assignment_id;
    --
    CURSOR csr_asg_status_type(c_assignment_status_type_id NUMBER) IS
    SELECT per_system_status
    FROM   per_assignment_status_types
    WHERE  assignment_status_type_id = c_assignment_status_type_id;
    --
    l_effective_report_date effective_report_date_list;
    l_event                 event_list;
    l_value                 value_list;
    l_action_type           action_type_list;
    l_first_changed_date    first_changed_date_list;
    l_asg_status_type_id    NUMBER;
    l_contribution_group    VARCHAR2(30);
    l_employment_category   VARCHAR2(30);
    l_action_info_id        pay_action_information.action_information_id%TYPE;
    l_ovn                   pay_action_information.object_version_number%TYPE;
    l_screen_entry_value_1  pay_element_entry_values_f.screen_entry_value%TYPE;
    l_screen_entry_value_2  pay_element_entry_values_f.screen_entry_value%TYPE;
    l_epi_value             pay_element_entry_values_f.screen_entry_value%TYPE;
    l_unused_number         NUMBER;
    sql_str                 VARCHAR2(4000);
    l_ec_value              VARCHAR2(60);
    l_soft_keyflex_id       hr_soft_coding_keyflex.soft_coding_keyflex_id%TYPE;
    l_under_repres_women    pay_element_entry_values_f.screen_entry_value%TYPE;
    l_rehired_disabled      pay_element_entry_values_f.screen_entry_value%TYPE;
    l_unemployment_status   pay_element_entry_values_f.screen_entry_value%TYPE;
    l_first_contractor      pay_element_entry_values_f.screen_entry_value%TYPE;
    l_after_two_years       pay_element_entry_values_f.screen_entry_value%TYPE;
    l_minority_group_flag   pay_element_entry_values_f.screen_entry_value%TYPE;
    l_active_rent_flag      pay_element_entry_values_f.screen_entry_value%TYPE;
    l_employee_category     VARCHAR2(30);
    l_collective_agreement  NUMBER;
    l_disability_degree     NUMBER;
    l_date_of_birth         per_all_people_f.date_of_birth%TYPE;
    l_sex                   per_all_people_f.sex%TYPE;
    l_system_status         per_assignment_status_types.per_system_status%TYPE;
    l_assignment_id         per_all_assignments_f.assignment_id%TYPE;
    l_contract_key          pay_element_entry_values_f.screen_entry_value%TYPE;
    --
BEGIN
    --
    OPEN csr_get_eit_values(p_assignment_id, p_effective_end_date);
    FETCH csr_get_eit_values BULK COLLECT
    INTO l_effective_report_date, l_event, l_value, l_action_type, l_first_changed_date;
    CLOSE csr_get_eit_values;
    --
    IF l_action_type.exists(1) THEN
        IF l_action_type(1) = 'I' THEN
            --
            OPEN csr_get_asg_values (p_assignment_id, l_effective_report_date(1));
            FETCH csr_get_asg_values INTO l_date_of_birth,l_sex,l_asg_status_type_id
                                         ,l_employment_category,l_soft_keyflex_id
                                         ,l_employee_category,l_collective_agreement;
            CLOSE csr_get_asg_values;
            --
            OPEN csr_get_contribution_group(l_soft_keyflex_id);
            FETCH csr_get_contribution_group INTO l_contribution_group;
            CLOSE csr_get_contribution_group;
            --
            OPEN csr_asg_status_type(l_asg_status_type_id);
            FETCH csr_asg_status_type INTO l_system_status;
            CLOSE csr_asg_status_type;
            --
            per_es_ss_rep_archive_pkg.get_disability_degree(p_assignment_id
                                                           ,p_effective_end_date
                                                           ,l_disability_degree);
            per_es_ss_rep_archive_pkg.get_ss_details(p_assignment_id
                                                    ,p_effective_end_date
                                                    ,l_under_repres_women
                                                    ,l_rehired_disabled
                                                    ,l_unemployment_status
                                                    ,l_first_contractor
                                                    ,l_after_two_years
                                                    ,l_active_rent_flag
                                                    ,l_minority_group_flag);

            IF l_value.EXISTS(3) THEN
                OPEN csr_get_element_values (p_assignment_id, l_effective_report_date(1));
                FETCH csr_get_element_values
                INTO l_assignment_id,l_screen_entry_value_1,l_screen_entry_value_2;
                CLOSE csr_get_element_values;
            END IF;

            IF l_value.EXISTS(4) THEN
                OPEN csr_get_element_values (p_assignment_id, l_effective_report_date(1));
                FETCH csr_get_element_values
                INTO l_assignment_id,l_screen_entry_value_1,l_screen_entry_value_2;
                CLOSE csr_get_element_values;
            END IF;

            IF l_value.EXISTS(1) and l_event(1) = 'AS' THEN
                IF l_value(1) <> l_asg_status_type_id THEN
                    l_value(1) := l_asg_status_type_id;
                END IF;
            END IF;

            IF l_value.EXISTS(2) and l_event(2) = 'CG' THEN
                IF l_value(2) <> l_contribution_group THEN
                    l_value(2) := l_contribution_group;
                END IF;
                IF l_contribution_group = 'X' THEN
                    l_contribution_group := NULL;
                END IF;
            END IF;

            IF l_value.EXISTS(3) THEN
                IF l_event(3) = 'EC' THEN
                     IF l_value(3) <> l_screen_entry_value_2 THEN
                         l_value(3) := l_screen_entry_value_2;
                         l_contract_key := l_screen_entry_value_2;
                     END IF;
                ELSIF l_event(3) = 'EP' THEN
                     IF l_value(3) <> l_screen_entry_value_1 THEN
                         l_value(3) := l_screen_entry_value_1;
                         l_epi_value := l_screen_entry_value_1;
                     END IF;
                END IF;
                IF l_value(3) = 'X' THEN
                    l_contract_key := NULL;
                    l_epi_value    := NULL;
                END IF;
            ELSE
                l_contract_key := NULL;
                l_epi_value    := NULL;
            END IF;

            IF l_value.EXISTS(4) AND l_event(4) = 'EP' THEN
                IF l_value(4) <> l_screen_entry_value_1 THEN
                    l_value(4) := l_screen_entry_value_1;
                    l_epi_value := l_screen_entry_value_1;
                END IF;
            END IF;
            IF l_value.EXISTS(4) THEN
                IF l_value(4) = 'X' THEN
                    l_epi_value := NULL;
                END IF;
            ELSE
                l_epi_value := NULL;
            END IF;

            IF l_value.EXISTS(1) AND l_event(1) = 'AS' AND l_system_status = 'ACTIVE_ASSIGN' THEN
                pay_action_information_api.create_action_information(
                   p_action_information_id       =>  l_action_info_id
                  ,p_action_context_id           =>   p_assignment_action_id
                  ,p_action_context_type         =>  'AAP'
                  ,p_object_version_number       =>  l_ovn
                  ,p_action_information_category =>  'ES_SS_REPORT_FAB'
                  ,p_effective_date              =>  fnd_date.canonical_to_date(l_effective_report_date(1))
                  ,p_action_information1         =>  'MA'
                  ,p_action_information2         =>  '0'
                  ,p_action_information3         =>  l_effective_report_date(1)
                  ,p_action_information4         =>  l_asg_status_type_id
                  ,p_action_information5         =>  l_contract_key
                  ,p_action_information6         =>  l_epi_value
                  ,p_action_information7         =>  l_unemployment_status
                  ,p_action_information8         =>  l_under_repres_women
                  ,p_action_information9         =>  fnd_date.date_to_canonical(l_date_of_birth)
                  ,p_action_information10        =>  l_sex
                  ,p_action_information11        =>  l_rehired_disabled
                  ,p_action_information12        =>  l_first_contractor
                  ,p_action_information13        =>  l_disability_degree
                  ,p_action_information14        =>  '0'
                  ,p_action_information15        =>  l_minority_group_flag
                  ,p_action_information16        =>  l_active_rent_flag
                  ,p_action_information17        =>  l_after_two_years
                  ,p_action_information18        =>  l_contribution_group
                  ,p_action_information19        =>  '0'
                  ,p_action_information20        =>  l_collective_agreement
                  ,p_action_information21        =>  l_employee_category);
            END IF;
        END IF;
    END IF;
    --
    l_unused_number := 1;
    --
    WHILE l_action_type.exists(l_unused_number) LOOP
        --
        IF l_event(l_unused_number) = 'AS' THEN
            sql_str := 'select paa.assignment_status_type_id asg_value
                               ,paa.effective_start_date      actual_date
                               ,pap.date_of_birth             date_of_birth
                               ,pap.sex                       sex
                         from   per_all_assignments_f paa
                               ,per_all_people_f pap
                               ,per_assignment_status_types pas
                         where  paa.assignment_id = '||p_assignment_id||'
                         and    paa.person_id = pap.person_id
                         and    paa.assignment_status_type_id = pas.assignment_status_type_id
                         and    pas.per_system_status = ''ACTIVE_ASSIGN''
                         and    fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(p_effective_end_date) ||''')
                                between  pap.effective_start_date
                                and      pap.effective_end_date
                         and    paa.effective_start_date
                                between fnd_date.canonical_to_date('''||l_first_changed_date(l_unused_number)||''')
                                and fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(p_effective_end_date) ||''')
                         order by paa.effective_start_date';

             get_other_values(l_value(l_unused_number),
                              l_event(l_unused_number),
                              p_assignment_id,
                              pactid,
                              p_assignment_action_id,
                              p_effective_end_date,
                              sql_str);

        ELSIF l_event(l_unused_number) = 'EC' THEN
            sql_str := 'select distinct nvl(pev.screen_entry_value, ''X'') screen_entry_value
                                ,pev.effective_start_date                  actual_date
                                ,pap.date_of_birth                         date_of_birth
                                ,pap.sex                                   sex
                          from   pay_element_entry_values_f  pev
                                ,pay_input_values_f          piv
                                ,pay_element_types_f         pet
                                ,pay_element_entries_f       pee
                                ,per_all_assignments_f       paa
                                ,per_all_people_f            pap
                          where  pev.element_entry_id     =  pee.element_entry_id
                          and    paa.person_id            =  pap.person_id
                          and    paa.assignment_id        =  pee.assignment_id
                          and    pee.assignment_id        =  '||p_assignment_id||'
                          and    pev.input_value_id       =  piv.input_value_id
                          and    piv.element_type_id      =  pet.element_type_id
                          and    pet.element_name         = ''Social Security Details''
                          and    pet.legislation_code     = ''ES''
                          and    piv.name                 = ''Contract Key''
                          AND    piv.legislation_code     = ''ES''
			  and    pee.element_type_id      =  pet.element_type_id
                          and    pev.effective_start_date
                                 between fnd_date.canonical_to_date('''||l_first_changed_date(l_unused_number)||''')
                                 and fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(p_effective_end_date) ||''')
                          and   fnd_date.canonical_to_date('''||l_first_changed_date(l_unused_number)||''')
                                  between  pap.effective_start_date
                                  and      pap.effective_end_date
                          and   fnd_date.canonical_to_date('''||l_first_changed_date(l_unused_number)||''')
                                  between  paa.effective_start_date
                                  and      paa.effective_end_date
                          AND    pev.effective_start_date BETWEEN piv.effective_start_date AND piv.effective_end_date
                          AND    pev.effective_start_date BETWEEN pet.effective_start_date AND pet.effective_end_date
                          AND    pev.effective_start_date BETWEEN pee.effective_start_date AND pee.effective_end_date
                          order by pev.effective_start_date';
            get_other_values(l_value(l_unused_number),
                             l_event(l_unused_number),
                             p_assignment_id,
                             pactid,
                             p_assignment_action_id,
                             p_effective_end_date,
                             sql_str);

        ELSIF l_event(l_unused_number) = 'CG' THEN
            sql_str := 'select nvl(sck.segment5, ''X'')        asg_value
                               ,paa.effective_start_date        actual_date
                               ,pap.date_of_birth               date_of_birth
                               ,pap.sex                         sex
                         from   per_all_assignments_f paa
                               ,per_all_people_f pap
                               ,hr_soft_coding_keyflex sck
                         where  paa.assignment_id = '||p_assignment_id||'
                         and    paa.person_id = pap.person_id
                         and    paa.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
                         and    fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(p_effective_end_date) ||''')
                                between  pap.effective_start_date
                                and      pap.effective_end_date
                         and    paa.effective_start_date
                                between fnd_date.canonical_to_date('''||l_first_changed_date(l_unused_number)||''')
                                and fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(p_effective_end_date) ||''')
                         order by paa.effective_start_date';

             get_other_values(l_value(l_unused_number),
                             l_event(l_unused_number),
                             p_assignment_id,
                             pactid,
                             p_assignment_action_id,
                             p_effective_end_date,
                             sql_str);

        ELSIF l_event(l_unused_number) = 'TS' THEN
             sql_str := 'select paa.assignment_status_type_id      asg_value
                                ,pps.actual_termination_date        actual_date
                                ,pap.date_of_birth                  date_of_birth
                                ,pap.sex                            sex
                          from   per_all_assignments_f paa
                                ,per_all_people_f pap
                                ,per_periods_of_service pps
                          where  paa.assignment_id = '||p_assignment_id||'
                          and    paa.person_id = pap.person_id
                          and    pps.person_id = pap.person_id
                          and    paa.period_of_service_id = pps.period_of_service_id
                          and    pps.actual_termination_date is not null
                          and   fnd_date.canonical_to_date('''||l_first_changed_date(l_unused_number)||''')
                                 between paa.effective_start_date
                                 and paa.effective_end_date
                          and  fnd_date.canonical_to_date('''||l_first_changed_date(l_unused_number)||''')
                                 between pap.effective_start_date
                                 and pap.effective_end_date
                          order by paa.effective_start_date';

            get_other_values(l_value(l_unused_number),
                             l_event(l_unused_number),
                             p_assignment_id,
                             pactid,
                             p_assignment_action_id,
                             p_effective_end_date,
                             sql_str);

        ELSIF l_event(l_unused_number) = 'EP' THEN
              sql_str := 'select distinct nvl(pev.screen_entry_value, ''X'') screen_entry_value
                                ,pev.effective_start_date                actual_date
                                ,pap.date_of_birth                       date_of_birth
                                ,pap.sex                                 sex
                          from   pay_element_entry_values_f  pev
                                ,pay_input_values_f          piv
                                ,pay_element_types_f         pet
                                ,pay_element_entries_f       pee
                                ,per_all_assignments_f       paa
                                ,per_all_people_f            pap
                          where  pev.element_entry_id     =  pee.element_entry_id
                          and    paa.person_id            =  pap.person_id
                          and    paa.assignment_id        =  pee.assignment_id
                          and    pee.assignment_id        =  '||p_assignment_id||'
                          and    pev.input_value_id       =  piv.input_value_id
                          and    piv.element_type_id      =  pet.element_type_id
                          and    pet.element_name         = ''Social Security Details''
                          and    pet.legislation_code     = ''ES''
                          and    piv.name                 = ''SS Epigraph Code''
			  and    pee.element_type_id      =  pet.element_type_id
                          AND    piv.legislation_code     = ''ES''
                          and    pev.effective_start_date
                                 between fnd_date.canonical_to_date('''||l_first_changed_date(l_unused_number)||''')
                                 and fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(p_effective_end_date) ||''')
                          and   fnd_date.canonical_to_date('''||l_first_changed_date(l_unused_number)||''')
                                  between  pap.effective_start_date
                                  and      pap.effective_end_date
                          and   fnd_date.canonical_to_date('''||l_first_changed_date(l_unused_number)||''')
                                  between  paa.effective_start_date
                                  and      paa.effective_end_date
                          AND    pev.effective_start_date BETWEEN piv.effective_start_date AND piv.effective_end_date
                          AND    pev.effective_start_date BETWEEN pet.effective_start_date AND pet.effective_end_date
                          AND    pev.effective_start_date BETWEEN pee.effective_start_date AND pee.effective_end_date
                          order by pev.effective_start_date';

              get_other_values(l_value(l_unused_number),
                             l_event(l_unused_number),
                             p_assignment_id,
                             pactid,
                             p_assignment_action_id,
                             p_effective_end_date,
                             sql_str);
     END IF;
    l_unused_number := l_unused_number + 1;
    END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
    NULL;
END archive_code;
-------------------------------------------------------------------------------------------------
----GET OTHER VALUES
-------------------------------------------------------------------------------------------------
PROCEDURE get_other_values (p_value                  IN OUT NOCOPY VARCHAR2
                           ,p_event                  IN VARCHAR2
                           ,p_assignment_id          IN NUMBER
			                     ,pactid                   IN NUMBER
			                     ,p_assignment_action_id   IN NUMBER
			                     ,p_effective_end_date     IN DATE
			                     ,sql_str                  IN VARCHAR2) IS
    --
    CURSOR csr_get_asg_values (c_assignment_id  NUMBER, c_reporting_date DATE) IS
    SELECT paa.employee_category  employee_category
          ,paa.collective_agreement_id
    FROM   per_all_assignments_f paa
    WHERE  paa.assignment_id = c_assignment_id
    AND    c_reporting_date BETWEEN paa.effective_start_date
                            AND     paa.effective_end_date;
    --
    CURSOR csr_leave_reason(c_assignment_id         NUMBER
                           ,c_business_group_id     NUMBER
                           ,c_actual_termination_dt DATE ) IS
    SELECT leaving_reason
    FROM   per_periods_of_service  pps
          ,per_all_assignments_f   paa
    WHERE  paa.period_of_service_id = pps.period_of_service_id
    AND    paa.assignment_id        = c_assignment_id
    AND    pps.business_group_id    = c_business_group_id
    AND    c_actual_termination_dt BETWEEN paa.effective_start_date
                                   AND     paa.effective_end_date;
    --
    CURSOR csr_stat_leav_reas_bgspec(c_leaving_reason    VARCHAR2
                                    ,c_business_group_id NUMBER  ) IS
    SELECT information1
    FROM   per_shared_types
    WHERE  lookup_type        ='LEAV_REAS'
    AND    system_type_cd     = c_leaving_reason
    AND    business_group_id  = c_business_group_id;
    --
    CURSOR csr_stat_leav_reas(c_leaving_reason VARCHAR2)IS
    SELECT information1
    FROM   per_shared_types
    WHERE  lookup_type       ='LEAV_REAS'
    AND    system_type_cd    = c_leaving_reason
    AND    business_group_id IS NULL;
    --

    l_action_info_id            pay_action_information.action_information_id%TYPE;
    l_ovn                       pay_action_information.object_version_number%TYPE;
    l_unused_value              pay_action_information.action_information4%TYPE;
    l_unused_number             NUMBER;
    l_value                     pay_action_information.action_information4%TYPE;
    l_actual_date               DATE;
    l_date_of_birth             per_all_people_f.date_of_birth%TYPE;
    l_sex                       per_all_people_f.sex%TYPE;
    --
    get_csr_event_values        csr_event_values;
    --
    l_under_repres_women        pay_element_entry_values_f.screen_entry_value%TYPE;
    l_rehired_disabled          pay_element_entry_values_f.screen_entry_value%TYPE;
    l_unemployment_status       pay_element_entry_values_f.screen_entry_value%TYPE;
    l_first_contractor          pay_element_entry_values_f.screen_entry_value%TYPE;
    l_after_two_years           pay_element_entry_values_f.screen_entry_value%TYPE;
    l_minority_group_flag       pay_element_entry_values_f.screen_entry_value%TYPE;
    l_active_rent_flag          pay_element_entry_values_f.screen_entry_value%TYPE;
    l_employee_category         VARCHAR2(30);
    l_collective_agreement      NUMBER;
    l_disability_degree         NUMBER;
    l_under_repres_women_ter    pay_element_entry_values_f.screen_entry_value%TYPE;
    l_rehired_disabled_ter      pay_element_entry_values_f.screen_entry_value%TYPE;
    l_unemployment_status_ter   pay_element_entry_values_f.screen_entry_value%TYPE;
    l_first_contractor_ter      pay_element_entry_values_f.screen_entry_value%TYPE;
    l_after_two_years_ter       pay_element_entry_values_f.screen_entry_value%TYPE;
    l_minority_group_flag_ter   pay_element_entry_values_f.screen_entry_value%TYPE;
    l_active_rent_flag_ter      pay_element_entry_values_f.screen_entry_value%TYPE;
    l_employee_category_ter     VARCHAR2(30);
    l_collective_agreement_ter  NUMBER;
    l_disability_degree_ter     NUMBER;
    l_leaving_reason            per_periods_of_service.leaving_reason%TYPE;
    l_leave_reason_code         per_shared_types.information1%TYPE;
--
BEGIN
    OPEN csr_get_asg_values(p_assignment_id, p_effective_end_date);
    FETCH csr_get_asg_values INTO l_employee_category, l_collective_agreement;
    CLOSE csr_get_asg_values;
    per_es_ss_rep_archive_pkg.get_disability_degree
                                            (p_assignment_id
                                            ,p_effective_end_date
                                            ,l_disability_degree);
    per_es_ss_rep_archive_pkg.get_ss_details(p_assignment_id
                                            ,p_effective_end_date
                                            ,l_under_repres_women
                                            ,l_rehired_disabled
                                            ,l_unemployment_status
                                            ,l_first_contractor
                                            ,l_after_two_years
                                            ,l_minority_group_flag
                                            ,l_active_rent_flag );
    OPEN get_csr_event_values FOR sql_str;
    LOOP
        FETCH get_csr_event_values into l_value, l_actual_date, l_date_of_birth, l_sex;
        EXIT WHEN get_csr_event_values%NOTFOUND;
        IF p_event = 'AS' AND l_value <> p_value THEN
            p_value := l_value;
            pay_action_information_api.create_action_information(
                      p_action_information_id       =>  l_action_info_id
                     ,p_action_context_id           =>   p_assignment_action_id
                     ,p_action_context_type         =>  'AAP'
                     ,p_object_version_number       =>  l_ovn
                     ,p_action_information_category =>  'ES_SS_REPORT_FAB'
				             ,p_effective_date              =>  l_actual_date
                     ,p_action_information1         =>  'MA'
                     ,p_action_information2         =>  '0'
                     ,p_action_information3         =>  fnd_date.date_to_canonical(l_actual_date)
                     ,p_action_information4         =>  p_value
                     ,p_action_information7         =>  l_unemployment_status
                     ,p_action_information8         =>  l_under_repres_women
                     ,p_action_information9         =>  fnd_date.date_to_canonical(l_date_of_birth)
                     ,p_action_information10        =>  l_sex
                     ,p_action_information11        =>  l_rehired_disabled
                     ,p_action_information12        =>  l_first_contractor
                     ,p_action_information13        =>  l_disability_degree
                     ,p_action_information14        =>  '0'
                     ,p_action_information15        =>  l_minority_group_flag
                     ,p_action_information16        =>  l_active_rent_flag
                     ,p_action_information17        =>  l_after_two_years
                     ,p_action_information19        =>  '0'
                     ,p_action_information20        =>  l_collective_agreement
                     ,p_action_information21        =>  l_employee_category);
        ELSIF p_event = 'TS' AND l_value <> p_value THEN
            OPEN csr_get_asg_values(p_assignment_id, l_actual_date);
            FETCH csr_get_asg_values INTO l_employee_category_ter, l_collective_agreement_ter;
            CLOSE csr_get_asg_values;

            OPEN  csr_leave_reason(p_assignment_id
                                  ,g_business_group_id
                                  ,l_actual_date);
            FETCH csr_leave_reason INTO l_leaving_reason;
            CLOSE csr_leave_reason;

            OPEN  csr_stat_leav_reas_bgspec(l_leaving_reason,g_business_group_id);
            FETCH csr_stat_leav_reas_bgspec INTO l_leave_reason_code;
            IF csr_stat_leav_reas_bgspec%NOTFOUND THEN
                OPEN csr_stat_leav_reas(l_leaving_reason);
                FETCH csr_stat_leav_reas INTO l_leave_reason_code;
                IF csr_stat_leav_reas%NOTFOUND THEN
                    l_leave_reason_code := ' ';
                END IF;
                CLOSE csr_stat_leav_reas;
            END IF;
            CLOSE csr_stat_leav_reas_bgspec;

            PER_ES_SS_REP_ARCHIVE_PKG.get_disability_degree
                                                    (p_assignment_id
                                                    ,l_actual_date
                                                    ,l_disability_degree_ter);
            PER_ES_SS_REP_ARCHIVE_PKG.get_ss_details(p_assignment_id
                                                    ,l_actual_date
                                                    ,l_under_repres_women_ter
                                                    ,l_rehired_disabled_ter
                                                    ,l_unemployment_status_ter
                                                    ,l_first_contractor_ter
                                                    ,l_after_two_years_ter
                                                    ,l_minority_group_flag_ter
                                                    ,l_active_rent_flag_ter);
            pay_action_information_api.create_action_information(
                     p_action_information_id        =>   l_action_info_id
                    ,p_action_context_id           =>   p_assignment_action_id
                    ,p_action_context_type         =>  'AAP'
                    ,p_object_version_number       =>   l_ovn
                    ,p_action_information_category =>  'ES_SS_REPORT_FAB'
                    ,p_effective_date              =>   l_actual_date
                    ,p_action_information1         =>  'MB'
                    ,p_action_information2         =>   l_leave_reason_code
                    ,p_action_information3         =>   fnd_date.Date_to_canonical(l_actual_date)
                    ,p_action_information4         =>   p_value
                    ,p_action_information7         =>   l_unemployment_status_ter
                    ,p_action_information8         =>   l_under_repres_women_ter
                    ,p_action_information9         =>   fnd_date.Date_to_canonical(l_date_of_birth)
                    ,p_action_information10        =>   l_sex
                    ,p_action_information11        =>   l_rehired_disabled_ter
                    ,p_action_information12        =>   l_first_contractor_ter
                    ,p_action_information13        =>   l_disability_degree_ter
                    ,p_action_information14        =>   '0'
                    ,p_action_information15        =>   l_minority_group_flag_ter
                    ,p_action_information16        =>   l_active_rent_flag_ter
                    ,p_action_information17        =>   l_after_two_years_ter
                    ,p_action_information19        =>   '0'
                    ,p_action_information20        =>   l_collective_agreement_ter
                    ,p_action_information21        =>   l_employee_category_ter);
        ELSIF p_event = 'EC' AND l_value <> p_value THEN
             p_value := l_value;
             IF p_value = 'X' THEN
                 l_unused_value := NULL;
             ELSE
                 l_unused_value := p_value;
             END IF;
             pay_action_information_api.create_action_information(
                     p_action_information_id       =>  l_action_info_id
                    ,p_action_context_id           =>   p_assignment_action_id
                    ,p_action_context_type         =>  'AAP'
                    ,p_object_version_number       =>  l_ovn
                    ,p_action_information_category =>  'ES_SS_REPORT_FAB'
                    ,p_effective_date              =>  l_actual_date
                    ,p_action_information1         =>  'MC'
                    ,p_action_information2         =>  '0'
                    ,p_action_information3         =>  fnd_date.Date_to_canonical(l_actual_date)
                    ,p_action_information5         =>  l_unused_value
                    ,p_action_information7         =>  l_unemployment_status
                    ,p_action_information8         =>  l_under_repres_women
                    ,p_action_information9         =>  fnd_date.Date_to_canonical(l_date_of_birth)
                    ,p_action_information10        =>  l_sex
                    ,p_action_information11        =>  l_rehired_disabled
                    ,p_action_information12        =>  l_first_contractor
                    ,p_action_information13        =>  l_disability_degree
                    ,p_action_information14        =>  '0'
                    ,p_action_information15        =>  l_minority_group_flag
                    ,p_action_information16        =>  l_active_rent_flag
                    ,p_action_information17        =>  l_after_two_years
                    ,p_action_information19        =>  '0'
                    ,p_action_information20        =>  l_collective_agreement
                    ,p_action_information21        =>  l_employee_category);
        ELSIF p_event = 'CG' AND l_value <> p_value THEN
            p_value := l_value;
            IF p_value = 'X' THEN
                l_unused_value := NULL;
            ELSE
                l_unused_value := p_value;
            END IF;
            pay_action_information_api.create_action_information(
                     p_action_information_id       =>  l_action_info_id
                    ,p_action_context_id           =>   p_assignment_action_id
                    ,p_action_context_type         =>  'AAP'
                    ,p_object_version_number       =>  l_ovn
                    ,p_action_information_category =>  'ES_SS_REPORT_FAB'
                    ,p_effective_date              =>  l_actual_date
                    ,p_action_information1         =>  'MG'
                    ,p_action_information2         =>  '0'
                    ,p_action_information3         =>  fnd_date.Date_to_canonical(l_actual_date)
                    ,p_action_information7         =>  l_unemployment_status
                    ,p_action_information8         =>  l_under_repres_women
                    ,p_action_information9         =>  fnd_date.Date_to_canonical(l_date_of_birth)
                    ,p_action_information10        =>  l_sex
                    ,p_action_information11        =>  l_rehired_disabled
                    ,p_action_information12        =>  l_first_contractor
                    ,p_action_information13        =>  l_disability_degree
                    ,p_action_information14        =>  '0'
                    ,p_action_information15        =>  l_minority_group_flag
                    ,p_action_information16        =>  l_active_rent_flag
                    ,p_action_information17        =>  l_after_two_years
                    ,p_action_information18        =>  l_unused_value
                    ,p_action_information19        =>  '0'
                    ,p_action_information20        =>  l_collective_agreement
                    ,p_action_information21        =>  l_employee_category);
        ELSIF p_event = 'EP' AND l_value <> p_value THEN
             p_value := l_value;
             IF p_value = 'X' THEN
                 l_unused_value := NULL;
             ELSE
                 l_unused_value := p_value;
             END IF;
             pay_action_information_api.create_action_information(
                     p_action_information_id       =>  l_action_info_id
                    ,p_action_context_id           =>   p_assignment_action_id
                    ,p_action_context_type         =>  'AAP'
                    ,p_object_version_number       =>  l_ovn
                    ,p_action_information_category =>  'ES_SS_REPORT_FAB'
                    ,p_effective_date              =>  l_actual_date
                    ,p_action_information1         =>  'MT'
                    ,p_action_information2         =>  '0'
                    ,p_action_information3         =>  fnd_date.Date_to_canonical(l_actual_date)
                    ,p_action_information6         =>  l_unused_value
                    ,p_action_information7         =>  l_unemployment_status
                    ,p_action_information8         =>  l_under_repres_women
                    ,p_action_information9         =>  fnd_date.Date_to_canonical(l_date_of_birth)
                    ,p_action_information10        =>  '1'
                    ,p_action_information11        =>  l_rehired_disabled
                    ,p_action_information12        =>  l_first_contractor
                    ,p_action_information13        =>  l_disability_degree
                    ,p_action_information14        =>  '0'
                    ,p_action_information15        =>  l_minority_group_flag
                    ,p_action_information16        =>  l_active_rent_flag
                    ,p_action_information17        =>  l_after_two_years
                    ,p_action_information19        =>  '0'
                    ,p_action_information20        =>  l_collective_agreement
                    ,p_action_information21        =>  l_employee_category);
        END IF;
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
NULL;
END get_other_values;
----------------------------------------------------------------------------------------------
-- RANGE CURSOR for locking
---------------------------------------------------------------------------------------------------
PROCEDURE range_cursor_lock (pactid         IN NUMBER
                            ,sqlstr         OUT NOCOPY VARCHAR) IS
    --
    BAD                     EXCEPTION;
    l_text                  fnd_lookup_values.meaning%TYPE;
    l_unused_number         NUMBER;
    --
BEGIN
     --
     l_unused_number := 0;
     --
     PER_ES_SS_REP_ARCHIVE_PKG.get_all_parameters_lock (
                  p_payroll_action_id      => pactid
		             ,p_arch_payroll_action_id => g_arch_payroll_action_id
		             ,p_effective_end_date     => g_effective_end_date);
      --
     -- Return the select string
     --
     sqlstr := 'select distinct person_id
                from   per_people_f ppf
                      ,pay_payroll_actions ppa
                where  ppa.payroll_action_id = :payroll_action_id
                and    ppa.business_group_id = ppf.business_group_id
                order by ppf.person_id';
    EXCEPTION
    WHEN OTHERS THEN
        sqlstr := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
    --
END range_cursor_lock;
--------------------------------------------------------------------------------
-- ACTION CREATION -- Data Lock Process
--------------------------------------------------------------------------------
PROCEDURE action_creation_lock(pactid    IN NUMBER,
                               stperson  IN NUMBER,
                               endperson IN NUMBER,
                               chunk     IN NUMBER) IS
    --
    CURSOR csr_get_assignments (c_payroll_action_id NUMBER) IS
    SELECT   asg_run.assignment_id              assignment_id
            ,pai.action_context_id              action_context_id
            ,pai.action_information1            action_status
            ,max(pai.effective_date)            current_reporting_date
    FROM     pay_payroll_actions     ppa
            ,pay_assignment_actions  paa
            ,per_all_assignments_f   asg_run
            ,pay_action_information  pai
    WHERE    ppa.payroll_action_id    = c_payroll_action_id
    AND      paa.payroll_action_id    = ppa.payroll_action_id
    AND      asg_run.business_group_id = ppa.business_group_id
    AND      asg_run.assignment_id    = paa.assignment_id
    AND      asg_run.person_id BETWEEN stperson
                               AND     endperson
    AND      pai.action_context_id    = paa.assignment_action_id
    AND      pai.action_context_type  = 'AAP'
    AND      pai.action_information_category = 'ES_SS_REPORT_FAB'
    GROUP BY asg_run.assignment_id, pai.action_context_id, pai.action_information1
    ORDER BY asg_run.assignment_id, current_reporting_date;
    --
    CURSOR csr_action_info_values(c_action_context_id      NUMBER
                                 ,c_action_status          VARCHAR2
                                 ,c_current_reporting_date DATE) IS
    SELECT   pai.action_information4       assignment_status_type_id
            ,pai.action_information5       employment_category
            ,pai.action_information6       epigraph_code
            ,pai.action_information18      contribution_group
    FROM     pay_action_information        pai
    WHERE    pai.action_context_id         = c_action_context_id
    AND      pai.action_information1       = c_action_status
    AND      effective_date                = c_current_reporting_date;
    --
    l_assignment_status_type_id  per_assignment_extra_info.aei_information4%TYPE;
    l_employment_category        per_assignment_extra_info.aei_information4%TYPE;
    l_contribution_group         per_assignment_extra_info.aei_information4%TYPE;
    l_epigraph_code              per_assignment_extra_info.aei_information4%TYPE;
    l_actid                      pay_assignment_actions.assignment_action_id%TYPE;
    l_action_info_id             pay_action_information.action_information_id%TYPE;
    l_ovn                        pay_action_information.object_version_number%TYPE;
    l_unused_number              NUMBER;
    l_effective_start_date       DATE;
    --
BEGIN
    per_es_ss_rep_archive_pkg.get_all_parameters_lock (
                 p_payroll_action_id      => pactid
		            ,p_arch_payroll_action_id => g_arch_payroll_action_id
		            ,p_effective_end_date     => g_effective_end_date);
    --
    FOR qualifying_assignments IN csr_get_assignments (g_arch_payroll_action_id) LOOP
        --
        -- create a new action and lock the fetched one
        --
        SELECT pay_assignment_actions_s.NEXTVAL
        INTO l_actid
        FROM dual;
        --
        hr_nonrun_asact.insact(l_actid
                              ,qualifying_assignments.action_context_id
                              ,pactid
                              ,chunk
                              ,NULL);
        -- Lock the assignment action
        hr_nonrun_asact.insint(
                              lockingactid => l_actid
                             ,lockedactid  => qualifying_assignments.action_context_id);
        OPEN csr_action_info_values
             (qualifying_assignments.action_context_id
             ,qualifying_assignments.action_status
             ,qualifying_assignments.current_reporting_date);
        FETCH csr_action_info_values INTO l_assignment_status_type_id
                                         ,l_employment_category
                                         ,l_epigraph_code
                                         ,l_contribution_group;
        CLOSE csr_action_info_values;

        IF qualifying_assignments.action_status = 'MA' THEN

          l_unused_number := 0;
	        SELECT  count(assignment_status_type_id), min(effective_start_date)
	        INTO    l_unused_number, l_effective_start_date
          FROM    per_all_assignments_f
          WHERE   assignment_status_type_id <> l_assignment_status_type_id
	        AND     effective_start_date >= qualifying_assignments.current_reporting_date
	        AND     assignment_id = qualifying_assignments.assignment_id;

          IF l_unused_number = 0 THEN
   	          UPDATE per_assignment_extra_info
     	        SET     aei_information4 = l_assignment_status_type_id
	                   ,aei_information6 = 'U'
	                   ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		               ,aei_information7 = fnd_date.date_to_canonical(g_effective_end_date)
		               ,aei_information5 = 'N'
              WHERE  assignment_id = qualifying_assignments.assignment_id
	            AND    aei_information3 = 'AS';
	        ELSE
   	          UPDATE per_assignment_extra_info
     	        SET    aei_information4 = l_assignment_status_type_id
	                  ,aei_information6 = 'U'
	                  ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		              ,aei_information7 = fnd_date.date_to_canonical(l_effective_start_date)
              WHERE  assignment_id = qualifying_assignments.assignment_id
	            AND    aei_information3 = 'AS';
	        END IF;

            l_unused_number := 0;
            --
	         /* SELECT  count(employment_category), min(effective_start_date)
	          INTO    l_unused_number, l_effective_start_date
            FROM    per_all_assignments_f
            WHERE   nvl(employment_category, 'X') <> nvl(l_employment_category, 'X')
	          AND     effective_start_date >= qualifying_assignments.current_reporting_date
	          AND     assignment_id = qualifying_assignments.assignment_id;*/

            --
            SELECT count(pev.screen_entry_value), min(pev.effective_start_date)
            INTO  l_unused_number , l_effective_start_date
            FROM   pay_element_entry_values_f  pev
                  ,pay_input_values_f          piv
                  ,pay_element_types_f         pet
                  ,pay_element_entries_f       pee
            WHERE  pev.element_entry_id     =  pee.element_entry_id
            AND    pev.screen_entry_value   <> l_employment_category
            AND    pee.assignment_id        =  qualifying_assignments.assignment_id
            AND    pev.input_value_id       =  piv.input_value_id
            AND    piv.element_type_id      =  pet.element_type_id
	    AND    pee.element_type_id      =  pet.element_type_id
            AND    pet.element_name         =  'Social Security Details'
            AND    pet.legislation_code     =  'ES'
            AND    piv.name                 =  'Contract Key'
            AND    piv.legislation_code     =  'ES'
            AND    pev.effective_start_date >= qualifying_assignments.current_reporting_date
            AND    pev.effective_start_date BETWEEN piv.effective_start_date AND piv.effective_end_date
            AND    pev.effective_start_date BETWEEN pet.effective_start_date AND pet.effective_end_date
            AND    pev.effective_start_date BETWEEN pee.effective_start_date AND pee.effective_end_date;
            IF l_unused_number = 0 THEN
  	            UPDATE per_assignment_extra_info
                SET    aei_information4 = l_employment_category
	                    ,aei_information6 = 'U'
	                    ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information7 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information5 = 'N'
                WHERE  assignment_id = qualifying_assignments.assignment_id
                AND    aei_information3 = 'EC';
	          ELSE
  	            UPDATE per_assignment_extra_info
                SET    aei_information4 = l_employment_category
	                    ,aei_information6 = 'U'
	                    ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information7 = fnd_date.date_to_canonical(l_effective_start_date)
                WHERE  assignment_id = qualifying_assignments.assignment_id
	              AND    aei_information3 = 'EC';
	          END IF;

            l_unused_number := 0;
	          SELECT  count(sck.segment5), min(paa.effective_start_date)
	          INTO    l_unused_number, l_effective_start_date
            FROM    per_all_assignments_f paa
                   ,hr_soft_coding_keyflex sck
            WHERE   nvl(sck.segment5,'X') <> nvl(l_contribution_group,'X')
	          AND     paa.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
            AND     paa.effective_start_date >= qualifying_assignments.current_reporting_date
	          AND     paa.assignment_id = qualifying_assignments.assignment_id;
            IF l_unused_number = 0 THEN
	            UPDATE per_assignment_extra_info
       	      SET    aei_information4 = l_contribution_group
	                  ,aei_information6 = 'U'
	                  ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		                ,aei_information7 = fnd_date.date_to_canonical(g_effective_end_date)
		                ,aei_information5 = 'N'
              WHERE  assignment_id = qualifying_assignments.assignment_id
	            AND    aei_information3 = 'CG';
	         ELSE
	            UPDATE per_assignment_extra_info
       	      SET    aei_information4 = l_contribution_group
	                  ,aei_information6 = 'U'
	                  ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		                ,aei_information7 = fnd_date.date_to_canonical(l_effective_start_date)
              WHERE  assignment_id = qualifying_assignments.assignment_id
	            AND    aei_information3 = 'CG';
	         END IF;

           l_unused_number := 0;
           SELECT count(pev.screen_entry_value), min(pev.effective_start_date)
           INTO  l_unused_number , l_effective_start_date
           FROM   pay_element_entry_values_f  pev
                 ,pay_input_values_f          piv
                 ,pay_element_types_f         pet
                 ,pay_element_entries_f       pee
           WHERE  pev.element_entry_id     =  pee.element_entry_id
           AND    pev.screen_entry_value   <> l_epigraph_code
           AND    pee.assignment_id        =  qualifying_assignments.assignment_id
           AND    pev.input_value_id       =  piv.input_value_id
           AND    piv.element_type_id      =  pet.element_type_id
	   AND    pee.element_type_id      =  pet.element_type_id
           AND    pet.element_name         =  'Social Security Details'
           AND    pet.legislation_code     =  'ES'
           AND    piv.name                 =  'SS Epigraph Code'
           AND    piv.legislation_code     =  'ES'
           AND    pev.effective_start_date >= qualifying_assignments.current_reporting_date
           AND    pev.effective_start_date BETWEEN piv.effective_start_date AND piv.effective_end_date
           AND    pev.effective_start_date BETWEEN pet.effective_start_date AND pet.effective_end_date
           AND    pev.effective_start_date BETWEEN pee.effective_start_date AND pee.effective_end_date;
           --
           IF l_unused_number = 0 THEN
               UPDATE per_assignment_extra_info
               SET    aei_information4 = l_epigraph_code
                     ,aei_information6 = 'U'
                     ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
                     ,aei_information7 = fnd_date.date_to_canonical(g_effective_end_date)
	                   ,aei_information5 = 'N'
               WHERE  assignment_id    = qualifying_assignments.assignment_id
               AND    aei_information3 = 'EP';
            ELSE
                UPDATE per_assignment_extra_info
                SET    aei_information4 = l_epigraph_code
	                    ,aei_information6 = 'U'
	                    ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
	                    ,aei_information7 = fnd_date.date_to_canonical(l_effective_start_date)
                WHERE  assignment_id    = qualifying_assignments.assignment_id
                AND    aei_information3 = 'EP';
            END IF;
          ELSIF qualifying_assignments.action_status = 'MA' THEN
            l_unused_number := 0;
	          SELECT  count(assignment_status_type_id), min(effective_start_date)
	          INTO    l_unused_number, l_effective_start_date
            FROM    per_all_assignments_f
            WHERE   assignment_status_type_id <> l_assignment_status_type_id
	          AND     effective_start_date >= qualifying_assignments.current_reporting_date
	          AND     assignment_id = qualifying_assignments.assignment_id;
	          IF l_unused_number = 0 THEN
   	            UPDATE per_assignment_extra_info
  	            SET    aei_information4 = l_assignment_status_type_id
	                    ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
     		              ,aei_information7 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information5 = 'N'
                WHERE  assignment_id = qualifying_assignments.assignment_id
	              AND    aei_information3 = 'AS';
	          ELSE
   	            UPDATE per_assignment_extra_info
     	          SET    aei_information4 = l_assignment_status_type_id
	                    ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information7 = fnd_date.date_to_canonical(l_effective_start_date)
                WHERE  assignment_id = qualifying_assignments.assignment_id
	              AND    aei_information3 = 'AS';
	          END IF;
          ELSIF qualifying_assignments.action_status = 'MB' THEN
             /* The AEI_INFORMATION3 CAN HAVE THE VALUE TS OR AS because
               while a person is terminated the AS report flag changes to Y
               and once the leaver is reported the flag shud be
               updated back to N*/
             --
             UPDATE per_assignment_extra_info
     	       SET    aei_information4 = l_assignment_status_type_id
	                 ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		               ,aei_information7 = fnd_date.date_to_canonical(g_effective_end_date)
		               ,aei_information5 = 'N'
             WHERE  assignment_id = qualifying_assignments.assignment_id
             AND    aei_information3   IN ('TS','AS');
             --
          ELSIF qualifying_assignments.action_status = 'MC' THEN
             --
             l_unused_number := 0;
	          /*SELECT  count(employment_category), min(effective_start_date)
	            INTO    l_unused_number, l_effective_start_date
              FROM    per_all_assignments_f
              WHERE   nvl(employment_category, 'X') <> nvl(l_employment_category, 'X')
	            AND     effective_start_date >= qualifying_assignments.current_reporting_date
	            AND     assignment_id = qualifying_assignments.assignment_id;*/
	            SELECT count(pev.screen_entry_value), min(pev.effective_start_date)
              INTO  l_unused_number , l_effective_start_date
              FROM  pay_element_entry_values_f  pev
                   ,pay_input_values_f          piv
                   ,pay_element_types_f         pet
                   ,pay_element_entries_f       pee
              WHERE  pev.element_entry_id     =  pee.element_entry_id
              AND    pev.screen_entry_value   <> l_employment_category
              AND    pee.assignment_id        =  qualifying_assignments.assignment_id
              AND    pev.input_value_id       =  piv.input_value_id
              AND    piv.element_type_id      =  pet.element_type_id
              AND    pee.element_type_id      =  pet.element_type_id
              AND    pet.element_name         =  'Social Security Details'
              AND    pet.legislation_code     =  'ES'
              AND    piv.name                 =  'Contract Key'
              AND    piv.legislation_code     =  'ES'
              AND    pev.effective_start_date >= qualifying_assignments.current_reporting_date
              AND    pev.effective_start_date BETWEEN piv.effective_start_date AND piv.effective_end_date
              AND    pev.effective_start_date BETWEEN pet.effective_start_date AND pet.effective_end_date
              AND    pev.effective_start_date BETWEEN pee.effective_start_date AND pee.effective_end_date;

            --
            IF l_unused_number = 0 THEN
  	            UPDATE per_assignment_extra_info
                SET    aei_information4 = l_employment_category
	                    ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
	                    ,aei_information7 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information5 = 'N'
                WHERE  assignment_id = qualifying_assignments.assignment_id
	              AND    aei_information3 = 'EC';
	          ELSE
  	            UPDATE per_assignment_extra_info
                SET    aei_information4 = l_employment_category
	                    ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information7 = fnd_date.date_to_canonical(l_effective_start_date)
                WHERE  assignment_id = qualifying_assignments.assignment_id
	              AND    aei_information3 = 'EC';
	          END IF;
        ELSIF qualifying_assignments.action_status = 'MG' THEN
            --
            l_unused_number := 0;
	          SELECT  count(sck.segment5), min(paa.effective_start_date)
	          INTO    l_unused_number, l_effective_start_date
            FROM    per_all_assignments_f paa
                   ,hr_soft_coding_keyflex sck
            WHERE   nvl(sck.segment5, 'X') <> nvl(l_contribution_group, 'X')
	          AND     paa.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
            AND     paa.effective_start_date >= qualifying_assignments.current_reporting_date
	          AND     paa.assignment_id = qualifying_assignments.assignment_id;
            --
            IF l_unused_number = 0 THEN
	              UPDATE per_assignment_extra_info
       	        SET    aei_information4 = l_contribution_group
                      ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information7 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information5 = 'N'
                WHERE  assignment_id = qualifying_assignments.assignment_id
	              AND    aei_information3 = 'CG';
	          ELSE
	              UPDATE per_assignment_extra_info
       	        SET    aei_information4 = l_contribution_group
	                    ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information7 = fnd_date.date_to_canonical(l_effective_start_date)
                WHERE  assignment_id = qualifying_assignments.assignment_id
	              AND    aei_information3 = 'CG';
	        END IF;
        ELSIF qualifying_assignments.action_status = 'MT' THEN
            l_unused_number := 0;
	          SELECT count(pev.screen_entry_value), min(pev.effective_start_date)
            INTO  l_unused_number , l_effective_start_date
            FROM   pay_element_entry_values_f  pev
                  ,pay_input_values_f         piv
                  ,pay_element_types_f        pet
                  ,pay_element_entries_f      pee
            WHERE  pev.element_entry_id     =  pee.element_entry_id
            AND    pev.screen_entry_value   <> l_epigraph_code
            AND    pee.assignment_id        =  qualifying_assignments.assignment_id
            AND    pev.input_value_id       =  piv.input_value_id
            AND    piv.element_type_id      =  pet.element_type_id
            AND    pee.element_type_id      =  pet.element_type_id
            AND    pet.element_name         =  'Social Security Details'
            AND    pet.legislation_code     =  'ES'
            AND    piv.name                 =  'SS Epigraph Code'
            AND    piv.legislation_code     =  'ES'
            AND    pev.effective_start_date >= qualifying_assignments.current_reporting_date
            AND    pev.effective_start_date BETWEEN piv.effective_start_date AND piv.effective_end_date
            AND    pev.effective_start_date BETWEEN pet.effective_start_date AND pet.effective_end_date
            AND    pev.effective_start_date BETWEEN pee.effective_start_date AND pee.effective_end_date;
            --
	          IF l_unused_number = 0 THEN
   	            UPDATE per_assignment_extra_info
  	            SET    aei_information4 = l_epigraph_code
	                    ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information7 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information5 = 'N'
                WHERE  assignment_id = qualifying_assignments.assignment_id
	              AND    aei_information3 = 'EP';
	          ELSE
   	            UPDATE per_assignment_extra_info
  	            SET    aei_information4 = l_epigraph_code
	                    ,aei_information2 = fnd_date.date_to_canonical(g_effective_end_date)
		                  ,aei_information7 = fnd_date.date_to_canonical(l_effective_start_date)
                WHERE  assignment_id = qualifying_assignments.assignment_id
	              AND    aei_information3 = 'EP';
            END IF;
        END IF;
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
NULL;
END action_creation_lock;
END per_es_ss_rep_archive_pkg;

/
