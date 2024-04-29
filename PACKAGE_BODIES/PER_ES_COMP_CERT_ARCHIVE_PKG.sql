--------------------------------------------------------
--  DDL for Package Body PER_ES_COMP_CERT_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ES_COMP_CERT_ARCHIVE_PKG" as
/* $Header: peesccar.pkb 120.7 2006/05/12 00:52:18 grchandr noship $ */
--------------------------------------------------------------------------------
-- GET_ALL_PARAMETERS
--------------------------------------------------------------------------------
PROCEDURE get_all_parameters(p_payroll_action_id  IN         NUMBER
                            ,p_business_group_id  OUT NOCOPY NUMBER
                            ,p_start_date         OUT NOCOPY DATE
                            ,p_end_date           OUT NOCOPY DATE
                            ,p_legal_employer     OUT NOCOPY NUMBER) IS
  --
  CURSOR csr_parameter_info (c_payroll_action_id NUMBER) IS
  SELECT get_parameters(c_payroll_action_id, 'Legal_Employer')
        ,start_date
        ,effective_date
        ,business_group_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = c_payroll_action_id;
--
BEGIN
  --
  OPEN csr_parameter_info (p_payroll_action_id);
  FETCH csr_parameter_info INTO  p_legal_employer
                                ,p_start_date
                                ,p_end_date
                                ,p_business_group_id;
  CLOSE csr_parameter_info;
  --
END;
--------------------------------------------------------------------------------
-- GET_PARAMETERS
--------------------------------------------------------------------------------
FUNCTION get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2) RETURN VARCHAR2 IS

  CURSOR csr_parameter_info IS
  SELECT SUBSTR(legislative_parameters,
         INSTR(legislative_parameters,p_token_name)+(LENGTH(p_token_name)+1),
         INSTR(legislative_parameters,' ',
         INSTR(legislative_parameters,p_token_name)))
  FROM   pay_payroll_actions
  WHERE  payroll_action_id = p_payroll_action_id;
  --
  l_token_value                     VARCHAR2(50);
  --
BEGIN
  --
  OPEN csr_parameter_info;
  FETCH csr_parameter_info INTO l_token_value;
  CLOSE csr_parameter_info;
  return(l_token_value);
END get_parameters;
--------------------------------------------------------------------------------
-- RANGE_CODE
--------------------------------------------------------------------------------
PROCEDURE range_code(p_actid IN  NUMBER
                    ,sqlstr OUT NOCOPY VARCHAR2)
IS

  --
  CURSOR csr_legal_employer(c_business_group_id NUMBER, c_legal_employer NUMBER)IS
  SELECT  hoi1.organization_id organization_id
         ,hoi2.org_information1 company_name
         ,hoi2.org_information3 representative_title
         ,hoi2.org_information8 cac
         ,hoi2.org_information2 person_id
  FROM    hr_organization_information hoi1
         ,hr_All_organization_units hou
         ,hr_organization_information hoi2
  WHERE   hou.business_group_id        = c_business_group_id
  AND     hoi1.organization_id         = hou.organization_id
  AND     hoi2.organization_id         = hou.organization_id
  AND     hou.organization_id          = NVL(c_legal_employer,hou.organization_id)
  AND     hoi1.org_information_context = 'CLASS'
  AND     hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
  AND     hoi2.org_information_context = 'ES_STATUTORY_INFO'
  ORDER BY hoi1.organization_id ;
  --
  CURSOR csr_legal_representative_info(c_person_id NUMBER, c_effective_date DATE) IS
  SELECT pap.full_name representative_name
         ,decode(pap.per_information2, 'DNI', pap.per_information2, 'PASSPORT',pap.per_information3,NULL) dni_passport
  FROM   per_all_people_f pap
  WHERE  pap.person_id = c_person_id
  AND    c_effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date;
  --

  l_ovn NUMBER;
  l_action_info_id NUMBER;
  l_business_group_id  hr_organization_units.business_group_id%type;
  l_start_date DATE;
  l_end_date DATE;
  l_legal_employer number;
  l_legal_representative_info csr_legal_representative_info%rowtype;
BEGIN
  --
  -- Return Range Cursor
  -- Note: There must be one and only one entry of :payroll_action_id in
  -- the string, and the statement must be ordered by person_id
  --
  get_all_parameters (p_actid
                     ,l_business_group_id
                     ,l_start_date
                     ,l_end_date
                     ,l_legal_employer);
  --

  --
  sqlstr := 'select distinct person_id '||
            'from per_people_f ppf, '||
            'pay_payroll_actions ppa '||
            'where ppa.payroll_action_id = :payroll_action_id '||
            'and ppa.business_group_id = ppf.business_group_id '||
            'order by ppf.person_id';
  --

  --
  FOR c_rec IN csr_legal_employer(l_business_group_id, l_legal_employer) LOOP

    OPEN csr_legal_representative_info(to_number(c_rec.person_id),l_end_date);
      FETCH csr_legal_representative_info INTO l_legal_representative_info;
    CLOSE csr_legal_representative_info;
    --Archiving Employee Data
    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_actid
    , p_action_context_type          =>  'PA'
    , p_object_version_number        =>  l_ovn
    , p_assignment_id                =>  NULL
    , p_effective_date               =>  l_end_date
    , p_source_id                    =>  NULL
    , p_source_text                  =>  NULL
    , p_action_information_category  =>  'ES_CC_REP_EMPLOYER'
    , p_action_information1          =>  c_rec.organization_id
    , p_action_information4          =>  c_rec.company_name
    , p_action_information5          =>  c_rec.cac
    , p_action_information6          =>  l_legal_representative_info.representative_name
    , p_action_information7          =>  l_legal_representative_info.dni_passport
    , p_action_information8          =>  c_rec.representative_title);

    --
    get_employer_address(c_rec.organization_id
                        ,p_actid
                        ,l_end_date
                        );
  END LOOP;
 --
EXCEPTION
  WHEN OTHERS THEN
    -- Return cursor that selects no rows
    sqlstr := 'select 1 '||
              '/* ERROR - Employer Details Fetch failed with: '||
              sqlerrm(sqlcode)||' */ '||
              'from dual where to_char(:payroll_action_id) = dummy';
    hr_utility.set_location(' Leaving: range code',110);
END range_code;
--------------------------------------------------------------------------------
-- ACTION_CREATION_CODE
--------------------------------------------------------------------------------
PROCEDURE action_creation_code (p_actid   IN NUMBER
                               ,stperson  IN NUMBER
                               ,endperson IN NUMBER
                               ,chunk     IN NUMBER) IS

  --
  CURSOR csr_terminated_assignments(stperson            NUMBER
                                   ,endperson           NUMBER
                                   ,c_legal_employer    NUMBER
                                   ,c_start_date        DATE
                                   ,c_end_date          DATE
                                   ,c_business_group_id NUMBER) IS
 SELECT assignment_id
 FROM   per_all_assignments_f asl
        ,per_periods_of_service ppos
        ,hr_soft_coding_keyflex hr
        ,hr_organization_information hoi
 WHERE  asl.person_id BETWEEN stperson AND endperson
 AND    asl.primary_flag = 'Y'
 AND    ppos.period_of_service_id = asl.period_of_service_id
 AND    ppos.actual_termination_date BETWEEN c_start_date AND c_end_date
 AND    asl.effective_end_date = ppos.actual_termination_date
 AND    asl.business_group_id = c_business_group_id
 AND    hr.soft_coding_keyflex_id = asl.soft_coding_keyflex_id
 AND    hr.segment2  = hoi.org_information1
 AND    hoi.org_information_context = 'ES_WORK_CENTER_REF'
 AND    hoi.organization_id = decode(c_legal_employer,NULL,hoi.organization_id,c_legal_employer)
 AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
                     FROM   pay_payroll_actions appa
                            ,pay_assignment_actions act
                            ,pay_action_information pai
                     WHERE  act.assignment_id = asl.assignment_id
                     AND    act.payroll_action_id = appa.payroll_action_id
                     AND    appa.report_category = 'ARCHIVE'
                     AND    appa.action_status = 'C'
                     AND    appa.report_qualifier = 'ES'
                     AND    appa.report_type = 'ES_COMP_CERT'
                     AND    pai.action_context_id = act.assignment_action_id
                     AND    pai.action_information_category  = 'ES_CC_REP_EMPLOYEE'
                     AND    pai.action_information21 = 'T');
 --
 CURSOR csr_td_assignments(c_p_actid           NUMBER
                          ,stperson            NUMBER
                          ,endperson           NUMBER
                          ,c_legal_employer    NUMBER
                          ,c_start_date        DATE
                          ,c_end_date          DATE
                          ,c_business_group_id NUMBER) IS
 SELECT assignment_id
 FROM   per_all_assignments_f asl
        ,hr_soft_coding_keyflex hr
        ,hr_organization_information hoi
        ,per_absence_attendance_types pat
        ,per_absence_attendances paa
        ,pay_payroll_actions ppa
 where  ppa.payroll_action_id   = c_p_actid
 AND    asl.person_id BETWEEN stperson AND endperson
 AND    asl.primary_flag = 'Y'
 AND    asl.business_group_id = ppa.business_group_id
 AND    paa.person_id = asl.person_id
 AND    pat.absence_attendance_type_id = paa.absence_attendance_type_id
 AND    pat.absence_category  = 'TD'
 AND    pat.business_group_id = ppa.business_group_id
 AND    paa.business_group_id = ppa.business_group_id
 AND    paa.date_start between c_start_date AND c_end_date
 AND    hr.soft_coding_keyflex_id = asl.soft_coding_keyflex_id
 AND    hr.segment2  = hoi.org_information1
 AND    hoi.org_information_context = 'ES_WORK_CENTER_REF'
 AND    hoi.organization_id =NVL(c_legal_employer,hoi.organization_id)
 AND    c_end_date between asl.effective_start_date and asl.effective_end_date
 AND    NOT EXISTS (SELECT  NULL
                     FROM   pay_payroll_actions appa
                            ,pay_assignment_actions act
                            ,pay_action_information pai
                     WHERE  act.assignment_id = asl.assignment_id
                     AND    act.payroll_action_id = appa.payroll_action_id
                     AND    appa.report_category = 'ARCHIVE'
                     AND    appa.action_status = 'C'
                     AND    appa.report_type = 'ES_COMP_CERT'
                     AND    appa.report_qualifier = 'ES'
                     AND    pai.action_context_id = act.assignment_action_id
                     AND    pai.action_information_category  = 'ES_CC_REP_EMPLOYEE'
                     AND    pai.action_information21 = 'S'
                     AND    pai.action_information22 =  to_char(paa.absence_attendance_id))
   AND   NOT EXISTS (SELECT  NULL
                     FROM   pay_payroll_actions appa
                            ,pay_assignment_actions act
                     WHERE  appa.payroll_action_id = c_p_actid
                     AND    act.payroll_action_id = appa.payroll_action_id
                     AND    act.assignment_id = asl.assignment_id);
  --
  l_actid                 NUMBER;
  l_legal_employer        NUMBER;
  l_start_date            DATE;
  l_end_date              DATE;
  l_business_group_id     NUMBER;
  --
BEGIN
    --
    get_all_parameters (p_actid
                       ,l_business_group_id
                       ,l_start_date
                       ,l_end_date
                       ,l_legal_employer);
    --
    FOR csr_rec IN csr_terminated_assignments(stperson
                                             ,endperson
                                             ,l_legal_employer
                                             ,l_start_date
                                             ,l_end_date
                                             ,l_business_group_id) LOOP
      --
      SELECT pay_assignment_actions_s.NEXTVAL
      INTO   l_actid
      FROM   dual;
      -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION
      hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,p_actid,chunk,NULL);
    END LOOP;
    --
    FOR csr_rec IN csr_td_assignments(p_actid
                                     ,stperson
                                     ,endperson
                                     ,l_legal_employer
                                     ,l_start_date
                                     ,l_end_date
                                     ,l_business_group_id) LOOP
      --
      SELECT pay_assignment_actions_s.NEXTVAL
      INTO   l_actid
      FROM   dual;
      -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION
      hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,p_actid,chunk,NULL);
    END LOOP;
    --
  END action_creation_code;
--------------------------------------------------------------------------------
-- ARCHIVE_CODE
--------------------------------------------------------------------------------
PROCEDURE archive_code (p_assactid       in number,
                        p_effective_date in date) IS


  l_person_id per_all_people_f.person_id%type;
  l_assignment_id per_all_assignments_f.assignment_id%type;
  l_type VARCHAR2(1);
  l_end_date  DATE;

  BEGIN
  -- get Employee data
    get_employee_data(p_assactid
                     ,l_assignment_id
                     ,p_effective_date
                     ,l_person_id
                     ,l_end_date
                     ,l_type
                     );
    get_person_address(l_person_id
                      ,p_assactid
                      ,l_assignment_id
                      ,l_end_date
                      ,p_effective_date
                      );
   get_element_entries(p_assactid
                      ,l_assignment_id
                      ,l_end_date
                      ,l_type
                      );
  END archive_code;

--------------------------------------------------------------------------------
-- GET_PERSON_ADDRESS
--------------------------------------------------------------------------------
PROCEDURE get_person_address(p_person_id            IN NUMBER
                            ,p_assactid             IN NUMBER
                            ,p_assignment_id        IN NUMBER
                            ,p_termination_date     IN DATE
                            ,p_effective_date       IN DATE
                            )IS

  CURSOR csr_person_addr  IS
  SELECT addr.address_line1 address_line1
         ,addr.address_line2 address_line2
         ,addr.address_line3 address_line3
         ,addr.town_or_city town_or_city
         ,hr_general.decode_lookup('ES_PROVINCE_CODES',addr.region_2) prov
         ,addr.postal_code postal_code
  FROM   per_addresses addr
  WHERE  addr.person_id = p_person_id
  AND    addr.primary_flag = 'Y'
  AND    p_termination_date between addr.date_from and
         nvl(addr.date_to,fnd_date.canonical_to_date('4712/12/31'));
  --
  l_addr csr_person_addr%rowtype;
  l_found boolean;
  l_province per_addresses.region_2%type ;
  l_action_info_id NUMBER;
  l_ovn NUMBER;
  --
BEGIN
  --
  OPEN csr_person_addr;
  FETCH csr_person_addr INTO l_addr;
  l_found := csr_person_addr%found;
  CLOSE csr_person_addr;
  IF l_found THEN
    -- Archiving Employee Address Information
    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_assactid
    , p_action_context_type          =>  'AAP'
    , p_object_version_number        =>  l_ovn
    , p_assignment_id                =>  p_assignment_id
    , p_effective_date               =>  p_effective_date
    , p_source_id                    =>  NULL
    , p_source_text                  =>  NULL
    , p_action_information_category  =>  'ADDRESS DETAILS'
    , p_action_information1          =>  p_person_id
    , p_action_information5          =>  l_addr.address_line1
    , p_action_information6          =>  l_addr.address_line2
    , p_action_information7          =>  l_addr.address_line3
    , p_action_information8          =>  l_addr.town_or_city
    , p_action_information10         =>  l_addr.prov
    , p_action_information12         =>  l_addr.postal_code);

   END IF;
END get_person_address;
--------------------------------------------------------------------------------
-- GET_EMPLOYER_ADDRESS
--------------------------------------------------------------------------------
PROCEDURE get_employer_address(p_organization_id        IN NUMBER
                               ,p_actid                 IN NUMBER
                               ,p_effective_date        IN DATE
                               ) IS
  --
  CURSOR csr_employer_addr(c_organization_id NUMBER) IS
  SELECT addr.address_line_1||' - '||hr_general.decode_lookup('HR_ES_LOCATION_TYPES',addr.address_line_1) address_line1
         ,addr.address_line_3 address_line3
         ,addr.town_or_city town_or_city
         ,hr_general.decode_lookup('ES_PROVINCE_CODES',addr.region_2) prov
         ,addr.postal_code postal_code
         ,addr.telephone_number_1 telephone_number
  FROM   hr_organization_units hou,
         hr_locations_all addr
  WHERE  hou.organization_id = c_organization_id
  AND    hou.location_id = addr.location_id;
  --
  l_found BOOLEAN;
  l_employer_addr csr_employer_addr%rowtype;
  l_province per_addresses.region_2%type ;
  l_action_info_id NUMBER;
  l_ovn number;
  --
BEGIN
  OPEN csr_employer_addr(p_organization_id);
  FETCH csr_employer_addr INTO l_employer_addr;
  l_found := csr_employer_addr%found;
  CLOSE csr_employer_addr;

  IF l_found THEN
    -- Archiving Legal Employer Address Information
    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_actid
    , p_action_context_type          =>  'PA'
    , p_object_version_number        =>  l_ovn
    , p_effective_date               =>  p_effective_date
    , p_action_information_category  =>  'ADDRESS DETAILS'
    , p_action_information1          =>  p_organization_id
    , p_action_information5          =>  l_employer_addr.address_line1
    , p_action_information7          =>  l_employer_addr.address_line3
    , p_action_information8          =>  l_employer_addr.town_or_city
    , p_action_information10         =>  l_employer_addr.prov
    , p_action_information12         =>  l_employer_addr.postal_code
    , p_action_information26         =>  l_employer_addr.telephone_number);
  END IF;
END get_employer_address;
--------------------------------------------------------------------------------
-- GET_EMPLOYEE_DATA
--------------------------------------------------------------------------------
PROCEDURE get_employee_data(p_assactid              IN NUMBER
                           ,p_assignment_id         IN OUT NOCOPY NUMBER
                           ,p_effective_date        IN DATE
                           ,p_person_id             IN OUT NOCOPY NUMBER
                           ,p_end_date              IN OUT NOCOPY DATE
                           ,p_type                  IN OUT NOCOPY VARCHAR2
                           ) IS

  CURSOR csr_employee_data IS
  SELECT pap.person_id person_id
        ,paa.assignment_id assignment_id
        ,paa.business_group_id organization_id
        ,pap.full_name emp_name
        ,decode(pap.per_information2, 'NIE', NULL,pap.per_information3) dni_passport
        ,paa.job_id job_id
        ,pps.date_start start_date
        ,pps.actual_termination_date end_date
        ,pps.leaving_reason leaving_reason
        ,hoi.organization_id legal_employer
        ,hr.segment2 work_center_id
        ,hr.segment5 cont_group
        ,hr_general.decode_lookup('ES_PROFESSIONAL_CAT'
                                  ,paa.employee_category) prof_catg
        ,paa.soft_coding_keyflex_id sc_key_id
        ,'T' type
        , 0  abs_attn_id
        ,to_date('01-01-0001','dd-mm-yyyy') sickness_start_date
        ,to_date('31-12-4712','dd-mm-yyyy') sickness_end_date
        ,pps.pds_information5 accrued_vacation
        ,pps.pds_information6 vacation_accrued
        ,pps.pds_information7 vacation_taken
        ,pps.pds_information8 vacation_reamining
        ,fnd_date.canonical_to_date(pps.pds_information9) vacation_from
        ,fnd_date.canonical_to_date(pps.pds_information10) vacation_to
  FROM   per_all_people_f pap
        ,per_all_assignments_f paa
        ,per_periods_of_service pps
        ,pay_assignment_actions paas
        ,pay_payroll_actions ppa
        ,hr_soft_coding_keyflex hr
        ,hr_organization_information hoi
  WHERE  paas.assignment_action_id      = p_assactid
  AND    paas.payroll_action_id         = ppa.payroll_action_id
  AND    paa.assignment_id              = paas.assignment_id
  AND    pap.person_id                  = paa.person_id
  AND    pap.person_id                  = pps.person_id
  AND    pps.period_of_service_id       = paa.period_of_service_id
  AND    hr.soft_coding_keyflex_id      = paa.soft_coding_keyflex_id
  AND    hr.segment2                    = hoi.org_information1
  AND    hoi.org_information_context    = 'ES_WORK_CENTER_REF'
  AND    pps.actual_termination_date    BETWEEN  ppa.start_date
                                        AND      ppa.effective_date
  AND    pps.actual_termination_date    BETWEEN  pap.effective_start_date
                                        AND      pap.effective_end_date
  AND    pps.actual_termination_date    BETWEEN  paa.effective_start_date
                                        AND      paa.effective_end_date
  UNION
  SELECT pap.person_id person_id
        ,paa.assignment_id assignment_id
        ,paa.business_group_id organization_id
        ,pap.full_name emp_name
        ,decode(pap.per_information2, 'NIE', NULL,pap.per_information3) dni_passport
        ,paa.job_id job_id
        ,pps.date_start start_date
        ,pps.actual_termination_date end_date
        ,pps.leaving_reason leaving_reason
        ,hoi.organization_id legal_employer
        ,hr.segment2 work_center_id
        ,hr.segment5 cont_group
        ,hr_general.decode_lookup('ES_PROFESSIONAL_CAT'
                                  ,paa.employee_category) prof_catg
        ,paa.soft_coding_keyflex_id sc_key_id
        ,'S' Type
        ,paat.absence_attendance_id abs_attn_id
        ,paat.date_start sickness_start_date
        ,paat.date_end sickness_end_date
        ,pps.pds_information5 accrued_vacation
        ,pps.pds_information6 vacation_accrued
        ,pps.pds_information7 vacation_taken
        ,pps.pds_information8 vacation_reamining
        ,fnd_date.canonical_to_date(pps.pds_information9) vacation_from
        ,fnd_date.canonical_to_date(pps.pds_information10) vacation_to
  FROM   per_all_people_f pap
        ,per_all_assignments_f paa
        ,pay_assignment_actions paas
        ,pay_payroll_actions ppa
        ,per_periods_of_service pps
        ,hr_soft_coding_keyflex hr
        ,hr_organization_information hoi
        ,per_absence_attendance_types  pat
        ,per_absence_attendances  paat
  WHERE  paas.assignment_action_id = p_assactid
  AND    paas.payroll_action_id = ppa.payroll_action_id
  AND    paa.assignment_id = paas.assignment_id
  AND    pps.period_of_service_id (+)= paa.period_of_service_id
  AND    pap.person_id = paa.person_id
  AND    pap.person_id = pps.person_id
  AND    pap.effective_start_date = (select max(papf.effective_start_date)
                                    from per_all_people_f papf
                                    where papf.person_id = pap.person_id
                                    AND   papf.effective_start_date <= ppa.effective_date)
  AND    paa.effective_start_date = (select max(paaf.effective_start_date)
                                    from per_all_assignments_f paaf
                                    where paaf.assignment_id = paa.Assignment_id
                                    AND   paaf.effective_start_date <= ppa.effective_date)
  AND    hr.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
  AND    hr.segment2  = hoi.org_information1
  AND    hoi.org_information_context = 'ES_WORK_CENTER_REF'
  AND    pat.ABSENCE_ATTENDANCE_TYPE_ID = paat.ABSENCE_ATTENDANCE_TYPE_ID
  AND    pat.ABSENCE_CATEGORY  = 'TD'
  AND    paat.person_id = pap.person_id
  AND    paat.date_start between ppa.start_date AND ppa.effective_date
  order by Type desc;


  CURSOR csr_contract_data(c_person_id number, c_effective_date date) IS
  SELECT  pcf.contract_id contract_id
          ,hr_general.decode_lookup('CONTRACT_TYPE',pcf.type) contract_type
          ,hr_contract_api.get_active_end_date (pcf.contract_id
                               ,p_effective_date,pcf.status) contract_end_date
  FROM    per_contracts_f pcf
  where   pcf.person_id = c_person_id
  AND     c_effective_date BETWEEN  pcf.effective_start_date
          AND pcf.effective_end_date;


  CURSOR  csr_get_ss_id(c_assignment_id number, c_effective_date date) IS
  SELECT  screen_entry_value ss_id
  FROM    pay_element_entries_f peef
          ,pay_element_entry_values_f peev
          ,pay_input_values_f piv
          ,pay_element_types_f pet
  WHERE   pet.element_name =  'Social Security Details'
  AND     piv.element_type_id = pet.element_type_id
  AND     pet.legislation_code = 'ES'
  AND     piv.name  ='Social Security Identifier'
  AND     peef.element_type_id = pet.element_type_id
  AND     peef.assignment_id = c_assignment_id
  AND     peev.element_entry_id = peef.element_entry_id
  AND     peev.input_value_id   = piv.input_value_id
  AND     c_effective_date BETWEEN  pet.effective_start_date
          AND pet.effective_end_date
  AND     c_effective_date BETWEEN  peef.effective_start_date
          AND peef.effective_end_date
  AND     c_effective_date BETWEEN  peev.effective_start_date
          AND peev.effective_end_date
  AND     c_effective_date BETWEEN  piv.effective_start_date
          AND piv.effective_end_date;


  l_found BOOLEAN;
  l_employee_data csr_employee_data%rowtype;
  l_contract_data csr_contract_data%rowtype;
  l_emp_ss_id csr_get_ss_id%rowtype;
  l_leaving_reason per_shared_types.information1%type;
  l_action_info_id number;
  l_emp_occupation per_jobs_tl.name%type;
  l_ovn number;
  l_vac_days number;
  l_sickness_start_date date;


  CURSOR csr_stat_leav_reas_bgspec(c_business_group_id NUMBER) IS
  SELECT hr_general.decode_lookup('STAT_TERM_REASONS',information1) prov
  FROM   per_shared_types
  WHERE  lookup_type       ='LEAV_REAS'
  AND    system_type_cd = l_employee_data.leaving_reason
  AND    business_group_id = c_business_group_id;

  CURSOR csr_stat_leav_reas IS
  SELECT hr_general.decode_lookup('STAT_TERM_REASONS',information1) prov
  FROM   per_shared_types
  WHERE  lookup_type       ='LEAV_REAS'
  AND    system_type_cd = l_employee_data.leaving_reason
  AND    business_group_id IS NULL;

  CURSOR csr_job_name(c_job_id NUMBER) IS
  SELECT jbt.name
  FROM   per_jobs_tl jbt
  WHERE  jbt.language = userenv('LANG')
  AND    jbt.job_id   = c_job_id;

  CURSOR csr_get_wc_prov(c_wc_id NUMBER) IS
  SELECT hr_general.decode_lookup('ES_PROVINCE_CODES',addr.region_2) prov
  FROM   hr_organization_units hou,
         hr_locations_all addr
  WHERE  hou.organization_id = c_wc_id
  AND    hou.location_id = addr.location_id;

  l_wc_prov hr_lookups.meaning%type;

BEGIN
  OPEN csr_employee_data;
  FETCH csr_employee_data INTO l_employee_data;
  l_found := csr_employee_data%found;
  CLOSE csr_employee_data;

  IF l_found THEN

    p_assignment_id := l_employee_data.assignment_id;
    p_person_id     := l_employee_data.person_id;
    p_end_date      := l_employee_data.end_date;
    p_type          := l_employee_data.type;

    l_vac_days := nvl(l_employee_data.vacation_accrued,0) - nvl(l_employee_data.vacation_taken,0);
    IF l_employee_data.vacation_accrued IS NULL
      AND l_employee_data.vacation_taken IS NULL THEN
      l_vac_days := NULL;
    END IF;

    IF p_type = 'S' THEN
      p_end_date      := l_employee_data.sickness_start_date;
    END IF;

    l_sickness_start_date := l_employee_data.sickness_start_date;

    IF l_employee_data.sickness_start_date = to_date('01-01-0001','dd-mm-yyyy')
       AND l_employee_data.sickness_end_date = to_date('31-12-4712','dd-mm-yyyy')  then
       l_sickness_start_date := null;
    END IF;

    OPEN csr_job_name(l_employee_data.job_id);
      FETCH csr_job_name INTO l_emp_occupation;
    CLOSE csr_job_name;

    OPEN csr_get_wc_prov(l_employee_data.work_center_id);
      FETCH csr_get_wc_prov INTO l_wc_prov;
    CLOSE csr_get_wc_prov;

    OPEN csr_stat_leav_reas_bgspec(l_employee_data.organization_id);
    FETCH csr_stat_leav_reas_bgspec INTO l_leaving_reason;
      IF  csr_stat_leav_reas_bgspec%NOTFOUND THEN
          OPEN csr_stat_leav_reas;
          FETCH csr_stat_leav_reas INTO l_leaving_reason;
          IF  csr_stat_leav_reas%NOTFOUND THEN
              l_leaving_reason := NULL;
          END IF;
          CLOSE csr_stat_leav_reas;
      END IF;
    CLOSE csr_stat_leav_reas_bgspec;

    OPEN csr_contract_data(l_employee_data.person_id, p_end_date);
    FETCH csr_contract_data INTO l_contract_data;
        l_found := csr_contract_data%found;
    CLOSE csr_contract_data;

    OPEN csr_get_ss_id(l_employee_data.assignment_id, p_end_date);
    FETCH csr_get_ss_id INTO l_emp_ss_id;
        l_found := csr_get_ss_id%found;
    CLOSE csr_get_ss_id;

    -- Archiving Employee Data
    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_assactid
    , p_action_context_type          =>  'AAP'
    , p_object_version_number        =>  l_ovn
    , p_assignment_id                =>  l_employee_data.assignment_id
    , p_effective_date               =>  p_effective_date
    , p_action_information_category  =>  'ES_CC_REP_EMPLOYEE'
    , p_action_information1          =>  l_employee_data.person_id
    , p_action_information2          =>  l_employee_data.legal_employer
    , p_action_information3          =>  l_employee_data.emp_name
    , p_action_information4          =>  l_employee_data.dni_passport
    , p_action_information5          =>  l_emp_ss_id.ss_id
    , p_action_information6          =>  l_employee_data.cont_group
    , p_action_information7          =>  l_employee_data.prof_catg
    , p_action_information8          =>  l_emp_occupation
    , p_action_information9          =>  fnd_date.date_to_displaydate(l_employee_data.start_date)
    , p_action_information10         =>  fnd_date.date_to_displaydate(l_employee_data.end_date)
    , p_action_information11         =>  fnd_date.date_to_displaydate(l_contract_data.contract_end_date)
    , p_action_information12         =>  l_leaving_reason
    , p_action_information13         =>  l_employee_data.accrued_vacation
    , p_action_information14         =>  l_vac_days
    , p_action_information15         =>  fnd_date.date_to_displaydate(l_employee_data.vacation_from)
    , p_action_information16         =>  fnd_date.date_to_displaydate(l_employee_data.vacation_to)
    , p_action_information17         =>  fnd_date.date_to_displaydate(l_sickness_start_date)
    , p_action_information20         =>  l_contract_data.contract_type
    , p_action_information21         =>  l_employee_data.type
    , p_action_information22         =>  l_employee_data.abs_attn_id
    , p_action_information23         =>  l_wc_prov);

  END IF;
END get_employee_data;

--------------------------------------------------------------------------------
-- GET_ELEMENT_ENTRIES
--------------------------------------------------------------------------------
PROCEDURE get_element_entries(p_assactid              IN NUMBER
                             ,p_assignment_id         IN NUMBER
                             ,p_effective_date        IN DATE
                             ,p_type                  IN VARCHAR2
                             ) IS

  CURSOR csr_Contribution_base(c_assignment_id number, c_effective_date date) IS
  SELECT  pee.rowid row_id
         ,pee.element_entry_id
         ,min(decode(piv.name, 'Year', eev.screen_entry_value, null)) year
         ,min(decode(piv.name, 'Month', hr_general.decode_lookup('ES_MONTH_NAMES',eev.screen_entry_value), null)) month
         ,min(decode(piv.name, 'Contribution Days', eev.screen_entry_value, null)) contribution_days
         ,min(decode(piv.name, 'Regular Situation Base', eev.screen_entry_value, null)) rs_cont_base
         ,min(decode(piv.name, 'IA ID Contribution', eev.screen_entry_value, null)) ia_id_contribution
         ,min(decode(piv.name, 'Note', eev.screen_entry_value, null)) note
         ,min(decode(p_type,'S',decode(piv.name, 'Last TD Report Paid', eev.screen_entry_value, null),null)) last_TD_date
  FROM    pay_element_entries_f pee
         ,pay_element_entry_values_f eev
         ,pay_input_values_f piv
         ,pay_element_types_f pet
  WHERE   pee.element_entry_id    = eev.element_entry_id
  AND     c_effective_date        BETWEEN pee.effective_start_date AND pee.effective_end_date
  AND     eev.input_value_id + 0  = piv.input_value_id
  AND     c_effective_date        BETWEEN eev.effective_start_date AND eev.effective_end_date
  AND     piv.element_type_id     = pet.element_type_id
  AND     c_effective_date        BETWEEN piv.effective_start_date AND piv.effective_end_date
  AND     pee.assignment_id       = c_assignment_id
  AND     pet.element_name        = decode(p_type,'T','Employee Termination Contribution Bases','Employee Temporary Disability  Contribution Bases')
  AND     pet.legislation_code    = 'ES'
  AND     c_effective_date        BETWEEN pet.effective_start_date AND pet.effective_end_date
  GROUP BY pee.rowid
          ,pee.element_entry_id;

  l_action_info_id number;
  l_ovn number;

BEGIN
  --
  FOR l_cont_base IN csr_Contribution_base(p_assignment_id, p_effective_date)LOOP

    -- Archiving Element Data

    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_assactid
    , p_action_context_type          =>  'AAP'
    , p_object_version_number        =>  l_ovn
    , p_assignment_id                =>  p_assignment_id
    , p_effective_date               =>  p_effective_date
    , p_action_information_category  =>  'ES_CC_REP_ELEMENT_INFO'
    , p_action_information5          =>  p_type
    , p_action_information6          =>  l_cont_base.year
    , p_action_information7          =>  l_cont_base.month
    , p_action_information8          =>  l_cont_base.contribution_days
    , p_action_information9          =>  l_cont_base.RS_cont_base
    , p_action_information10         =>  l_cont_base.IA_ID_Contribution
    , p_action_information11         =>  l_cont_base.note
    , p_action_information12         =>  fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_cont_base.last_td_date))
    );

  END LOOP;

END get_element_entries;

-------------------------------------------------------------------------------
-- WRITETOCLOB
--------------------------------------------------------------------------------
/*PROCEDURE WritetoCLOB (
        p_xfdf_blob out nocopy blob)
IS
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

BEGIN

	l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
	       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields> ' ;
	l_str2 := '<field name="';
	l_str3 := '">';
	l_str4 := '<value>' ;
	l_str5 := '</value> </field>' ;
	l_str6 := '</fields> </xfdf>';
	l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
		       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields>
       			 </fields> </xfdf>';
	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

	IF vXMLTable.count > 0 THEN
    dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
   	FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
   		l_str8 := vXMLTable(ctr_table).TagName;
   		l_str9 := vXMLTable(ctr_table).TagValue;
      --
   		IF (l_str9 is not null) THEN
        dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
				dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
				dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
				dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
			ELSE
  			null;
			END IF;
		END LOOP;
		dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
	ELSE
		dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
  END IF;

	DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
	clob_to_blob(l_xfdf_string,p_xfdf_blob);
	--return p_xfdf_blob;
	EXCEPTION
		WHEN OTHERS then
	    HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	    HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;*/
PROCEDURE WritetoCLOB (p_xfdf_blob out nocopy blob
                      ,p_xfdf_string out nocopy clob)
IS
  l_str1 varchar2(1000);
  l_str2 varchar2(20);
  l_str3 varchar2(20);
  l_str4 varchar2(20);
  l_str5 varchar2(20);
  l_str6 varchar2(30);
  l_str7 varchar2(1000);
  l_str8 varchar2(240);
  l_str9 varchar2(240);
BEGIN
	l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
	       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields> ' ;
	l_str2 := '<field name="';
	l_str3 := '">';
	l_str4 := '<value><![CDATA[' ;
	l_str5 := ']]></value> </field>' ;
	l_str6 := '</fields> </xfdf>';
	l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
		       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields>
       			 </fields> </xfdf>';
	dbms_lob.createtemporary(p_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(p_xfdf_string,dbms_lob.lob_readwrite);
	IF vXMLTable.count > 0 THEN
    dbms_lob.writeAppend( p_xfdf_string, length(l_str1), l_str1 );
   	FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
   		l_str8 := vXMLTable(ctr_table).TagName;
   		l_str9 := vXMLTable(ctr_table).TagValue;
      --
   		IF (l_str9 is not null) THEN
        dbms_lob.writeAppend( p_xfdf_string, length(l_str2), l_str2 );
				dbms_lob.writeAppend( p_xfdf_string, length(l_str8),l_str8);
				dbms_lob.writeAppend( p_xfdf_string, length(l_str3), l_str3 );
				dbms_lob.writeAppend( p_xfdf_string, length(l_str4), l_str4 );
				dbms_lob.writeAppend( p_xfdf_string, length(l_str9), l_str9);
				dbms_lob.writeAppend( p_xfdf_string, length(l_str5), l_str5 );
			ELSE
  			null;
			END IF;
		END LOOP;
		dbms_lob.writeAppend( p_xfdf_string, length(l_str6), l_str6 );
	ELSE
		dbms_lob.writeAppend( p_xfdf_string, length(l_str7), l_str7 );
  END IF;
	DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
	clob_to_blob(p_xfdf_string,p_xfdf_blob);
	--return p_xfdf_blob;
	EXCEPTION
		WHEN OTHERS then
	    HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	    HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;
--------------------------------------------------------------------------------
-- CLOB_TO_BLOB
--------------------------------------------------------------------------------
PROCEDURE  clob_to_blob(p_clob CLOB
                       ,p_blob IN OUT NOCOPY BLOB) IS
    --
    l_length_clob NUMBER;
    l_offset pls_integer;
    l_varchar_buffer VARCHAR2(32767);
    l_raw_buffer RAW(32767);
    l_buffer_len NUMBER;
    l_chunk_len  NUMBER;
    l_blob blob;
    g_nls_db_char VARCHAR2(60);
    --
    l_raw_buffer_len pls_integer;
    l_blob_offset pls_integer := 1;
    --
BEGIN
    --
    hr_utility.set_location('Entered Procedure clob to blob',120);
    --
    SELECT userenv('LANGUAGE') INTO g_nls_db_char FROM dual;
    --
    l_buffer_len :=  20000;
    l_length_clob := dbms_lob.getlength(p_clob);
    l_offset := 1;
    --
    while l_length_clob > 0 loop
        --
        IF l_length_clob < l_buffer_len THEN
            l_chunk_len := l_length_clob;
        ELSE
            l_chunk_len := l_buffer_len;
        END IF;
        --
        DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
        --
        l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.AL32UTF8',g_nls_db_char);
        l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.AL32UTF8',g_nls_db_char));
        dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
        --
        l_blob_offset := l_blob_offset + l_raw_buffer_len;
        l_offset := l_offset + l_chunk_len;
        l_length_clob := l_length_clob - l_chunk_len;
        --
    END LOOP;
    hr_utility.set_location('Finished Procedure clob to blob ',130);
END;
--------------------------------------------------------------------------------
-- FETCH_PDF_BLOB
--------------------------------------------------------------------------------
PROCEDURE fetch_pdf_blob
	(p_pdf_blob OUT NOCOPY blob)

IS

BEGIN

  SELECT file_data INTO p_pdf_blob
	FROM fnd_lobs
	WHERE file_id = (SELECT MAX(file_id) FROM per_gb_xdo_templates
                   WHERE file_name like '%ES_company_cert.pdf%');
EXCEPTION
  WHEN no_data_found THEN
  	NULL;
END fetch_pdf_blob;
--
--------------------------------------------------------------------------------
-- POPULATE_COMP_CERT
--------------------------------------------------------------------------------
PROCEDURE populate_comp_cert
  (p_request_id IN      NUMBER
  ,p_payroll_action_id  NUMBER
  ,p_legal_employer     NUMBER
  ,p_person_id          NUMBER
  ,p_xfdf_blob          OUT NOCOPY BLOB
  )IS
  p_xfdf_string clob;
BEGIN
  populate_plsql_table( p_request_id
                       ,p_payroll_action_id
                       ,p_legal_employer
                       ,p_person_id);
  WritetoCLOB (p_xfdf_blob,p_xfdf_string);
END populate_comp_cert;

--------------------------------------------------------------------------------
-- POPULATE_PLSQL_TABLE
--------------------------------------------------------------------------------
PROCEDURE populate_plsql_table
  (p_request_id IN      NUMBER
  ,p_payroll_action_id  NUMBER
  ,p_legal_employer     NUMBER
  ,p_person_id          NUMBER
  )IS

CURSOR csr_get_data IS
 SELECT substr(pai1.action_information4,1,40) company_name
        ,substr(pai1.action_information5,1,15) CAC
        ,substr(pai1.action_information6,1,40) representative_name
        ,pai1.action_information7 representative_DNI
        ,substr(pai1.action_information8,1,45) representative_Position
        ,substr(pai2.action_information5,1,40) cloc_type
        ,substr(pai2.action_information7,1,10) cloc_no
        ,substr(pai2.action_information8,1,16) ccity
        ,substr(pai2.action_information10,1,24) cprov_name
        ,substr(pai2.action_information12,1,7) cpostal_code
        ,substr(pai2.action_information26,1,16) ctel_no
        ,substr(pai3.action_information3,1,34)  emp_name
        ,substr(pai3.action_information4,1,15)  dni_passport
        ,pai3.action_information5  social_security_identifier
        ,pai3.action_information6  cont_grp
        ,substr(pai3.action_information7,1,15)  prof_catg
        ,substr(pai3.action_information8,1,25)  emp_occupation
        ,pai3.action_information9  start_date
        ,pai3.action_information10  end_date
        ,pai3.action_information11  contract_end_date
        ,substr(pai3.action_information12,1,30) leaving_reason
        ,pai3.action_information13  accured_vac
        ,pai3.action_information14  no_vac_days
        ,pai3.action_information15  vac_from
        ,pai3.action_information16  vac_till
        ,pai3.action_information17  sick_leave_start_date
        ,pai3.action_information18  number1
        ,pai3.action_information19  date1
        ,substr(pai3.action_information20,1,14)  contract_type
        ,substr(pai3.action_information23,1,10) wc_prov
        ,substr(pai4.action_information5,1,15) eloc_type
        ,substr(pai4.action_information6,1,10) eloc_name
        ,substr(pai4.action_information7,1,8) eloc_no
        ,substr(pai4.action_information8,1,15) ecity
        ,substr(pai4.action_information10,1,13) eprov_name
        ,substr(pai4.action_information12,1,6) epostal_code
        ,paa.assignment_action_id
 FROM   pay_payroll_actions ppa
        ,pay_assignment_actions paa
        ,pay_action_information pai1 --Employer rec
        ,pay_action_information pai2 --Employer Address
        ,pay_action_information pai3 --Employee rec
        ,pay_action_information pai4 --Employee address
 WHERE  ppa.payroll_action_id              = p_payroll_action_id
 AND    ppa.payroll_action_id              = paa.payroll_action_id
 AND    pai1.action_context_id             = ppa.payroll_action_id
 AND    pai2.action_context_id          (+)= pai1.action_context_id
 AND    pai1.action_context_type           = 'PA'
 AND    pai2.action_context_type        (+)= 'PA'
 AND    pai1.action_information_category   = 'ES_CC_REP_EMPLOYER'
 AND    pai2.action_information_category(+)= 'ADDRESS DETAILS'
 AND    pai1.action_information1           = pai2.action_information1(+)
 AND    pai3.action_context_type           = 'AAP'
 AND    pai3.action_context_id             = paa.assignment_action_id
 AND    pai4.action_context_id          (+)= pai3.action_context_id
 AND    pai4.action_context_type        (+)= 'AAP'
 AND    pai3.action_information_category   = 'ES_CC_REP_EMPLOYEE'
 AND    pai4.action_information_category(+)= 'ADDRESS DETAILS'
 AND    pai3.action_information1          = pai4.action_information1(+)
 AND    pai3.action_information2          = pai1.action_information1
 AND    pai1.action_information1          = NVL(p_legal_employer,pai1.action_information1)
 AND    pai3.action_information1          = NVL(p_person_id,pai3.action_information1);



 CURSOR get_element_details(c_assignment_action_id number) IS
 SELECT pai1.action_information5 Type
        ,pai1.action_information6 Year
        ,substr(pai1.action_information7,1,12) Month
        ,pai1.action_information8 contribution_days
        ,pai1.action_information9 contribution_base
        ,pai1.action_information10 ia_id_cont
        ,substr(pai1.action_information11,1,20) note
 FROM   pay_action_information pai1
 WHERE  pai1.action_context_id            = c_assignment_action_id
 AND    pai1.action_context_type          = 'AAP'
 AND    pai1.action_information_category  = 'ES_CC_REP_ELEMENT_INFO'
 AND    pai1.action_information5          = 'T';


  CURSOR get_emp_sickness_details(c_assignment_action_id number) IS
  SELECT pai1.action_information5 Type
        ,pai1.action_information6 Year
        ,substr(pai1.action_information7,1,12) Month
        ,pai1.action_information8 contribution_days
        ,pai1.action_information9 contribution_base
        ,pai1.action_information10 ia_id_cont
        ,substr(pai1.action_information11,1,20) note
        ,pai1.action_information12 last_td_date
 FROM   pay_action_information pai1
 WHERE  pai1.action_context_id            = c_assignment_action_id
 AND    pai1.action_context_type          = 'AAP'
 AND    pai1.action_information_category  = 'ES_CC_REP_ELEMENT_INFO'
 AND    pai1.action_information5          = 'S';


 lctr NUMBER;
 l_last_td_date VARCHAR2(30);
 l_sum_cont_days NUMBER;
 l_sum_cont_base NUMBER;
 l_sum_ia_id_cont NUMBER;
BEGIN

  vXMLTable.DELETE;
  vCtr := 1;

  FOR c_rec in csr_get_data LOOP
    l_sum_cont_days  := NULL;
    l_sum_cont_base  := NULL;
    l_sum_ia_id_cont := NULL;
    l_last_td_date := null;
    vXMLTable(vCtr).TagName := 'CC_WC_PROV';
    vXMLTable(vCtr).TagValue := upper(c_rec.wc_prov);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_COMP_REPRESENTATIVE_NAME';
    vXMLTable(vCtr).TagValue := (c_rec.representative_name);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_ REPRESENTATIVE_DNI';
    vXMLTable(vCtr).TagValue := (c_rec.representative_DNI);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_ REPRESENTATIVE_POS';
    vXMLTable(vCtr).TagValue := (c_rec.representative_Position);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_COMP_NAME';
    vXMLTable(vCtr).TagValue := (c_rec.company_name);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_CAC';
    vXMLTable(vCtr).TagValue := (c_rec.CAC);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC-CLOC_TYPE';
    vXMLTable(vCtr).TagValue := (c_rec.cloc_type);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_CLOC_NO';
    vXMLTable(vCtr).TagValue := (c_rec.cloc_no);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_CPOSTAL_CODE';
    vXMLTable(vCtr).TagValue := (c_rec.cpostal_code);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_CCITY';
    vXMLTable(vCtr).TagValue := (c_rec.ccity);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_CPROV_NAME';
    vXMLTable(vCtr).TagValue := (c_rec.cprov_name);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_C_TEL_NO';
    vXMLTable(vCtr).TagValue := (c_rec.ctel_no);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_EMP_NAME';
    vXMLTable(vCtr).TagValue := (c_rec.emp_name);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_EMP_DNI';
    vXMLTable(vCtr).TagValue := (c_rec.dni_passport);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_ELOC_TYPE';
    vXMLTable(vCtr).TagValue := (c_rec.eloc_type);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_ELOC_NAME';
    vXMLTable(vCtr).TagValue := (c_rec.eloc_name);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_ELOC_NO';
    vXMLTable(vCtr).TagValue := (c_rec.eloc_no);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_ECITY';
    vXMLTable(vCtr).TagValue := (c_rec.ecity);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_EPROV_NAME';
    vXMLTable(vCtr).TagValue := (c_rec.eprov_name);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_EPOSTAL_CODE';
    vXMLTable(vCtr).TagValue := (c_rec.epostal_code);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_SSN';
    vXMLTable(vCtr).TagValue := (c_rec.social_security_identifier);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_CONT_GRP';
    vXMLTable(vCtr).TagValue := (c_rec.cont_grp);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_PROF_CATG';
    vXMLTable(vCtr).TagValue := (c_rec.prof_catg);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_OCCUPATION';
    vXMLTable(vCtr).TagValue := (c_rec.emp_occupation);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_START_DATE';
    vXMLTable(vCtr).TagValue := (c_rec.start_date);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_END_DATE';
    vXMLTable(vCtr).TagValue := (c_rec.end_date);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_CONTRACT_END_DATE';
    vXMLTable(vCtr).TagValue := (c_rec.contract_end_date);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_CONTRACT_TYPE';
    vXMLTable(vCtr).TagValue := (c_rec.contract_type);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_LEAVING_REASON';
    vXMLTable(vCtr).TagValue := (c_rec.leaving_reason);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_ACCURED_VACATION';
    vXMLTable(vCtr).TagValue := (c_rec.accured_vac);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_NO_ACC_VAC';
    vXMLTable(vCtr).TagValue := (c_rec.no_vac_days);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_VAC_FROM';
    vXMLTable(vCtr).TagValue := (c_rec.vac_from);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_VAC_TO';
    vXMLTable(vCtr).TagValue := (c_rec.vac_till);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_TD_START_DATE';
    vXMLTable(vCtr).TagValue := (c_rec.sick_leave_start_date);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_NUMBER';
    vXMLTable(vCtr).TagValue := (null);
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_DATE';
    vXMLTable(vCtr).TagValue := (null);
    vCtr := vCtr + 1;
    lctr := 1;
    FOR c_element_details IN get_element_Details(c_rec.assignment_action_id) LOOP
      vXMLTable(vCtr).TagName := 'CC_YEAR'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (c_element_details.Year);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_MONTH'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (c_element_details.Month);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_CONT_DAYS'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (fnd_number.canonical_to_number(c_element_details.contribution_days));
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_IA_ID_CONT'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (fnd_number.canonical_to_number(c_element_details.ia_id_cont));
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_NOTE'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (c_element_details.note);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_CONT_BASE'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (fnd_number.canonical_to_number(c_element_details.contribution_base));
      vCtr := vCtr + 1;
      lctr := lctr + 1;
    END LOOP;
    LOOP
      EXIT WHEN lctr > 3;
      vXMLTable(vCtr).TagName := 'CC_YEAR'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_MONTH'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_CONT_DAYS'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_IA_ID_CONT'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_NOTE'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_CONT_BASE'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      lctr := lctr + 1;
    END LOOP;
    FOR c_element_details IN get_emp_sickness_Details(c_rec.assignment_action_id) LOOP
      IF lctr = 4 THEN
        l_sum_cont_days  := 0;
        l_sum_cont_base  := 0;
        l_sum_ia_id_cont := 0;
      END IF;
      vXMLTable(vCtr).TagName := 'CC_YEAR'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (c_element_details.Year);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_MONTH'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (c_element_details.Month);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_CONT_DAYS'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (fnd_number.canonical_to_number(c_element_details.contribution_days));
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_IA_ID_CONT'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (fnd_number.canonical_to_number(c_element_details.ia_id_cont));
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_NOTE'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (c_element_details.note);
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_CONT_BASE'||to_char(lctr);
      vXMLTable(vCtr).TagValue := (fnd_number.canonical_to_number(c_element_details.contribution_base));
      vCtr := vCtr + 1;
      lctr := lctr + 1;
      IF c_element_details.last_td_date IS NOT NULL THEN
        l_last_td_date := c_element_details.last_td_date;
      END IF;
      l_sum_cont_days  := l_sum_cont_days  + nvl(fnd_number.canonical_to_number(c_element_details.contribution_days),0);
      l_sum_cont_base  := l_sum_cont_base  + nvl(fnd_number.canonical_to_number(c_element_details.contribution_base),0);
      l_sum_ia_id_cont := l_sum_ia_id_cont + nvl(fnd_number.canonical_to_number(c_element_details.ia_id_cont),0);
    END LOOP;

    LOOP
      EXIT WHEN lctr > 11;
      vXMLTable(vCtr).TagName := 'CC_YEAR'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_MONTH'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_CONT_DAYS'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_IA_ID_CONT'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_NOTE'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      vXMLTable(vCtr).TagName := 'CC_CONT_BASE'||to_char(lctr);
      vXMLTable(vCtr).TagValue := ' ';
      vCtr := vCtr + 1;
      lctr := lctr + 1;
    END LOOP;

    vXMLTable(vCtr).TagName := 'CC_YEAR'||to_char(lctr);
    vXMLTable(vCtr).TagValue := ' ';
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_MONTH'||to_char(lctr);
    vXMLTable(vCtr).TagValue := ' ';
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_CONT_DAYS'||to_char(lctr);
    vXMLTable(vCtr).TagValue := l_sum_cont_days;
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_IA_ID_CONT'||to_char(lctr);
    vXMLTable(vCtr).TagValue := l_sum_ia_id_cont;
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_NOTE'||to_char(lctr);
    vXMLTable(vCtr).TagValue := ' ';
    vCtr := vCtr + 1;
    vXMLTable(vCtr).TagName := 'CC_CONT_BASE'||to_char(lctr);
    vXMLTable(vCtr).TagValue := l_sum_cont_base;

    vXMLTable(vCtr).TagName := 'CC_LAST_TD_REPORT';
    vXMLTable(vCtr).TagValue := nvl(l_last_td_date,' ');
    vCtr := vCtr + 1;

  END LOOP;
END populate_plsql_table;
--
END per_es_comp_cert_archive_pkg;

/
