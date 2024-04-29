--------------------------------------------------------
--  DDL for Package Body PER_HU_EMP_CERT_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HU_EMP_CERT_ARCHIVE" as
/* $Header: pehuecar.pkb 120.1 2005/06/27 22:56:38 alikhar noship $ */

--------------------------------------------------------------------------------
-- GET_PARAMETER
--------------------------------------------------------------------------------
FUNCTION get_parameter(
         p_parameter_string IN VARCHAR2
        ,p_token            IN VARCHAR2
         ) RETURN VARCHAR2 IS
--
    l_parameter  pay_payroll_actions.legislative_parameters%TYPE;
    l_start_pos  NUMBER;
    l_delimiter  VARCHAR2(1);
--
BEGIN
    l_parameter := NULL;
    l_delimiter := ' ';
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
-- GET_ALL_PARAMETERS
--------------------------------------------------------------------------------
PROCEDURE get_all_parameters(p_payroll_action_id  IN         NUMBER
                            ,p_business_group_id  OUT NOCOPY NUMBER
                            ,p_start_date         OUT NOCOPY DATE
                            ,p_end_date           OUT NOCOPY DATE
                            ,p_payroll_id         OUT NOCOPY NUMBER
                            ,p_issue_date         OUT NOCOPY DATE
                            ) IS
  --
  CURSOR csr_parameter_info (c_payroll_action_id NUMBER) IS
  SELECT get_parameter(legislative_parameters, 'PAYROLL_ID')
        ,fnd_date.canonical_to_date(get_parameter(legislative_parameters, 'DATE'))
        ,start_date
        ,effective_date
        ,business_group_id
  FROM   pay_payroll_actions
  WHERE  payroll_action_id = c_payroll_action_id;
  --
BEGIN
  --
  OPEN csr_parameter_info (p_payroll_action_id);
  FETCH csr_parameter_info INTO  p_payroll_id
                                ,p_issue_date
                                ,p_start_date
                                ,p_end_date
                                ,p_business_group_id;
  CLOSE csr_parameter_info;
  --
END;
--
--------------------------------------------------------------------------------
-- RANGE_CODE
--------------------------------------------------------------------------------
PROCEDURE range_code(p_actid IN  NUMBER
                    ,sqlstr OUT NOCOPY VARCHAR2)
IS
  --
  CURSOR   csr_comp_address(c_business_group_id NUMBER) IS
  SELECT   hoi.organization_id organization_id
          ,addr.postal_code c_postal_code
          ,addr.town_or_city c_town
          ,nvl(hr_general.decode_lookup('HU_COUNTY', addr.region_2),addr.region_2) c_county
          ,addr.address_line_1 c_location_name
          ,nvl(hr_general.decode_lookup('HU_LOCATION_TYPES', addr.address_line_2),addr.address_line_2) c_location_type
          ,addr.address_line_3 c_street_number
          ,addr.loc_information14 c_building
          ,addr.loc_information15 c_stairway
          ,addr.loc_information16 c_floor
          ,addr.loc_information17 c_door
  FROM     hr_organization_information  hoi
          ,hr_all_organization_units    hou
          ,hr_locations_all             addr
          ,hr_organization_information  hoi1
  WHERE    hou.organization_id          =  c_business_group_id
  AND      hoi.organization_id          =  hou.organization_id
  AND      hoi.org_information_context  = 'HU_COMPANY_INFORMATION_DETAILS'
  AND      hoi1.organization_id         =  hou.organization_id
  AND      hoi1.org_information_context = 'CLASS'
  AND      hoi1.org_information1        = 'HU_COMPANY_INFORMATION'
  AND      hoi1.org_information2        = 'Y'
  AND      hou.location_id              =  addr.location_id (+)
  ORDER BY hoi.organization_id ;

  -- Variables for storing company's address
  l_business_group_id  hr_organization_units.business_group_id%type;
  l_ovn                NUMBER;
  l_action_info_id     NUMBER;
  l_start_date         DATE;
  l_end_date           DATE;
  l_payroll_id         NUMBER;
  l_issue_date         DATE;
  --
BEGIN
  --

  get_all_parameters (p_actid
                     ,l_business_group_id
                     ,l_start_date
                     ,l_end_date
                     ,l_payroll_id
                     ,l_issue_date
                     );
  --
  sqlstr := 'select distinct person_id '||
            'from per_people_f ppf, '||
            'pay_payroll_actions ppa '||
            'where ppa.payroll_action_id = :payroll_action_id '||
            'and ppa.business_group_id = ppf.business_group_id '||
            'order by ppf.person_id';
  --

  --
  FOR c_rec IN csr_comp_address (l_business_group_id) LOOP

    --Archiving Employer Address
    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_actid
    , p_action_context_type          =>  'PA'
    , p_object_version_number        =>  l_ovn
    , p_effective_date               =>  l_issue_date
    , p_action_information_category  =>  'ADDRESS DETAILS'
    , p_action_information1          =>  c_rec.organization_id
    , p_action_information5          =>  c_rec.c_location_name
    , p_action_information6          =>  c_rec.c_location_type
    , p_action_information7          =>  c_rec.c_street_number
    , p_action_information8          =>  c_rec.c_town
    , p_action_information10         =>  c_rec.c_county
    , p_action_information12         =>  c_rec.c_postal_code
    , p_action_information26         =>  c_rec.c_building
    , p_action_information27         =>  c_rec.c_stairway
    , p_action_information28         =>  c_rec.c_floor
    , p_action_information29         =>  c_rec.c_door
    , p_action_information14         =>  'EMPLOYER');
    --
  END LOOP;
  --
  EXCEPTION
  WHEN OTHERS THEN
    -- Return cursor that selects no rows
    sqlstr := 'select 1 '||
              '/* ERROR - Employer Details Fetch failed with: '||
              sqlerrm(sqlcode)||' */ '||
              'from dual where to_char(:payroll_action_id) = dummy';
END range_code;

--------------------------------------------------------------------------------
-- ACTION_CREATION_CODE
--------------------------------------------------------------------------------
PROCEDURE action_creation_code (p_actid   IN NUMBER
                               ,stperson  IN NUMBER
                               ,endperson IN NUMBER
                               ,chunk     IN NUMBER) IS

  --
 CURSOR csr_terminated_assignments(c_pact_id       NUMBER
                                  ,c_stperson      NUMBER
                                  ,c_endperson     NUMBER
                                  ,c_payroll_id    NUMBER
                                   ) IS
 SELECT assignment_id
 FROM   per_all_assignments_f asl
       ,per_periods_of_service ppos
       ,pay_payroll_actions ppa
 WHERE  ppa.payroll_action_id         = c_pact_id
 AND    asl.person_id                 BETWEEN c_stperson AND c_endperson
 AND    asl.primary_flag              = 'Y'
 AND    ppos.period_of_service_id     = asl.period_of_service_id
 AND    ppos.actual_termination_date  BETWEEN asl.effective_end_date
                                      AND asl.effective_end_date
 AND    asl.business_group_id         = ppa.business_group_id
 AND    nvl(asl.payroll_id,0)         = nvl(c_payroll_id,nvl(asl.payroll_id,0))
 AND    ppos.actual_termination_date BETWEEN ppa.start_date
                                     AND ppa.effective_date
 AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
                     FROM   pay_payroll_actions appa
                            ,pay_assignment_actions act             -- Bug Fix 4369797 Changed table order
                            ,pay_action_information pai
                     WHERE  appa.action_status = 'C'
                     AND    appa.report_type = 'HU_EMP_CERT'
                     AND    appa.report_category = 'ARCHIVE'
                     AND    appa.report_qualifier = 'HU'            -- Bug Fix 4369797
		     AND    appa.action_type = 'X'                  -- Added
		     AND    act.action_status = 'C'		    -- some
		     AND    pai.action_context_type = 'AAP'	    -- new conditions
                     AND    pai.action_information_category  = 'HU_EMP_CERTIFICATION'
                     AND    act.assignment_id = asl.assignment_id
                     AND    act.payroll_action_id = appa.payroll_action_id
                     AND    pai.action_context_id = act.assignment_action_id
                     )
  ORDER BY assignment_id;

  l_actid                 NUMBER;
  l_prepay_action_id      NUMBER;
  l_Payroll_id            NUMBER;
  l_start_date            DATE;
  l_end_date              DATE;
  l_business_group_id     NUMBER;
  l_issue_date            DATE;

  BEGIN
    --

    --
    get_all_parameters (p_actid
                       ,l_business_group_id
                       ,l_start_date
                       ,l_end_date
                       ,l_payroll_id
                       ,l_issue_date);
    --
    FOR csr_rec IN csr_terminated_assignments(p_actid
                                             ,stperson
                                             ,endperson
                                             ,l_payroll_id) LOOP
      --
      SELECT pay_assignment_actions_s.NEXTVAL
      INTO   l_actid
      FROM   dual;
      -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION
      hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,p_actid,chunk,NULL);
    END LOOP;

END action_creation_code;
--------------------------------------------------------------------------------
-- ARCHIVE_CODE
--------------------------------------------------------------------------------
PROCEDURE archive_code (p_assactid       in number,
                        p_effective_date in date) IS


  l_person_id         per_all_people_f.person_id%TYPE;
  l_assignment_id     per_all_assignments_f.assignment_id%TYPE;
  l_end_date          DATE;

  BEGIN

    -- get Employee data
    get_employee_data(p_assactid
                     ,l_assignment_id
                     ,p_effective_date
                     ,l_person_id
                     ,l_end_date
                     );

    get_person_address(l_person_id
                      ,p_assactid
                      ,l_assignment_id
                      ,l_end_date
                      ,p_effective_date
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
  SELECT addr.postal_code
         ,addr.town_or_city town
         ,addr.address_line1 location_name
         ,nvl(hr_general.decode_lookup('HU_LOCATION_TYPES', addr.address_line2),addr.address_line2) location_type
         ,addr.address_line3 street_number
         ,addr.add_information14 building
         ,addr.add_information15 stairway
         ,addr.add_information16 floor
         ,addr.add_information17 door
  FROM   per_addresses addr
  WHERE  addr.person_id = p_person_id
  AND    addr.primary_flag = 'Y'
  AND    p_termination_date between addr.date_from and
         nvl(addr.date_to,fnd_date.canonical_to_date('4712/12/31'));

  l_addr           csr_person_addr%ROWTYPE;
  l_found          BOOLEAN;
  l_action_info_id NUMBER;
  l_ovn            NUMBER;
BEGIN

  OPEN csr_person_addr;
  FETCH csr_person_addr INTO l_addr;
  l_found := csr_person_addr%FOUND;
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
    , p_action_information_category  =>  'ADDRESS DETAILS'
    , p_action_information1          =>  p_person_id
    , p_action_information5          =>  l_addr.location_name
    , p_action_information6          =>  l_addr.location_type
    , p_action_information7          =>  l_addr.street_number
    , p_action_information8          =>  l_addr.town
    , p_action_information12         =>  l_addr.postal_code
    , p_action_information26         =>  l_addr.building
    , p_action_information27         =>  l_addr.stairway
    , p_action_information28         =>  l_addr.floor
    , p_action_information29         =>  l_addr.door
    , p_action_information14         =>  'EMPLOYEE'
    );
   END IF;
END get_person_address;

--------------------------------------------------------------------------------
-- GET_EMPLOYEE_DATA
--------------------------------------------------------------------------------
PROCEDURE get_employee_data(p_assactid              IN NUMBER
                           ,p_assignment_id         IN OUT NOCOPY NUMBER
                           ,p_effective_date        IN DATE
                           ,p_person_id             IN OUT NOCOPY NUMBER
                           ,p_end_date              IN OUT NOCOPY DATE
                           ) IS

  CURSOR csr_employee_data IS
  SELECT   pap.person_id
          ,pap.full_name
          ,pap.previous_last_name Maiden_name
          ,pap.national_identifier social_security_code
          ,pap.town_of_birth place_of_birth
          ,fnd_date.date_to_chardate(pap.date_of_birth) date_of_birth
          ,pap.per_information1 mother_maiden_name
          ,fnd_date.date_to_chardate(ppf.date_start) hire_date
          ,fnd_date.date_to_chardate(ppf.actual_termination_date) termination_date
          ,ppf.actual_termination_date actual_termination_date
          ,paa.assignment_id
          ,decode(hr.segment2,'Y','Yes','No') railway_benefit
          ,hoi.organization_id organization_id
          ,hoi.org_information1 company_name
          ,paas.payroll_action_id
  FROM     per_all_people_F pap
          ,per_periods_of_service ppf
          ,per_all_assignments_f paa
          ,pay_assignment_actions paas
          ,hr_soft_coding_keyflex hr
          ,hr_organization_information hoi
  WHERE    paas.assignment_action_id    = p_assactid
  AND      paas.assignment_id           = paa.assignment_id
  AND      pap.person_id                = ppf.person_id
  AND      ppf.business_group_id        = paa.business_group_id
  AND      pap.person_id                = paa.person_id
  AND      paa.period_of_service_id     = ppf.period_of_service_id
  AND      hoi.organization_id          = paa.business_group_id
  AND      hoi.org_information_context  = 'HU_COMPANY_INFORMATION_DETAILS'
  AND      paa.soft_coding_keyflex_id   = hr.soft_coding_keyflex_id (+)
  AND      ppf.actual_termination_date  BETWEEN pap.effective_start_date
                                        AND pap.effective_end_date
  AND      ppf.actual_termination_date  BETWEEN paa.effective_start_date
                                        AND paa.effective_end_date;

  CURSOR csr_pension_data(c_assignment_id number, c_effective_date date, c_type varchar2) IS
  SELECT  eev.screen_entry_value   start_date
         ,pee.element_entry_id     ppf_element_entry_id
         ,pei.eei_information1     pf_scheme_name
         ,hou.name                 provider_name
         ,hou.organization_id      provider_code
         ,decode(addr.town_or_city,NULL,NULL,addr.town_or_city||',')
            ||decode(addr.postal_code,NULL,NULL,' '||addr.postal_code)
            ||decode(addr.address_line_1, NULL, NULL, ' '||addr.address_line_1)
            ||decode(addr.address_line_2, NULL, NULL
                      , ' '||nvl(hr_general.decode_lookup('HU_LOCATION_TYPES', addr.address_line_2),addr.address_line_2))
            ||decode(addr.address_line_3, NULL, NULL, ' '||addr.address_line_3||'. ')
            ||decode(addr.loc_information14, NULL, NULL, addr.loc_information14||'.')
            ||decode(addr.loc_information15, NULL, NULL, addr.loc_information15||'.')
            ||decode(addr.loc_information16, NULL, NULL, addr.loc_information16||'.')
            ||decode(addr.loc_information17, NULL, NULL, addr.loc_information17||'.') address
         ,pee.personal_payment_method_id   payment_method_id
  FROM   pay_element_entries_f            pee
        ,pay_element_entry_values_f       eev
        ,pay_input_values_f               piv
        ,pay_element_types_f              pet
        ,pay_element_type_extra_info      pei
        ,hr_organization_units            hou
        ,hr_locations_all                 addr
  WHERE  pee.element_entry_id           = eev.element_entry_id
  AND    eev.input_value_id + 0         = piv.input_value_id
  AND    piv.element_type_id            = pet.element_type_id
  AND    pee.assignment_id              = c_assignment_id
  AND    piv.name                       = 'Override Start Date'
  AND    pet.element_type_id            = pei.element_type_id
  AND    pei.eei_information_category   = 'HU_PENSION_SCHEME_INFO'
  AND    pei.eei_information4           = c_type
  AND    pei.eei_information2           = hou.organization_id
  AND    hou.location_id                = addr.location_id (+)
  AND    c_effective_date               BETWEEN eev.effective_start_date
                                        AND eev.effective_end_date
  AND    c_effective_date               BETWEEN piv.effective_start_date
                                        AND piv.effective_end_date
  AND    c_effective_date               BETWEEN pet.effective_start_date
                                        AND pet.effective_end_date
  AND    c_effective_date               BETWEEN pee.effective_start_date
                                        AND pee.effective_end_date;
  --
  CURSOR csr_account_details(c_effective_date date,c_payment_method_id number)IS
  SELECT pea.segment2 bank_ac_no
  FROM   pay_personal_payment_methods_f   ppp
        ,pay_external_accounts            pea
  WHERE  ppp.personal_payment_method_id = c_payment_method_id
  AND    ppp.external_account_id        = pea.external_account_id
  AND    c_effective_date               BETWEEN ppp.effective_start_date
                                        AND     ppp.effective_end_date;

  --
  CURSOR csr_element_start_date(p_element_entry_id NUMBER) IS
  SELECT min(pee.effective_start_date)
  FROM   pay_element_entries_f       pee
  WHERE  pee.element_entry_id        =  p_element_entry_id;
  --
  CURSOR csr_absence_days(c_person_id        NUMBER
                         ,c_termination_year VARCHAR2) IS
  SELECT SUM(paat.absence_days)
  FROM   per_absence_attendance_types  pat
        ,per_absence_attendances       paat
  WHERE  pat.absence_attendance_type_id =  paat.absence_attendance_type_id
  AND    pat.absence_category           = 'S'
  AND    paat.person_id                 =  c_person_id
  AND    to_char(paat.date_end,'YYYY')  =  c_termination_year;

  --
  CURSOR csr_sickness_holiday_taken(c_person_id number
                                   ,c_termination_year varchar2
                                   ,c_termination_date date
                                    ) IS
  SELECT sum(decode(sign(c_termination_date - paat.date_end),-1, c_termination_date, paat.date_end)
             - decode(to_char(paat.date_start,'yyyy'),c_termination_year
             ,paat.date_start, to_date('01-01-'||c_termination_year,'dd-mm-YYYY'))
             + 1
         ) sickness_leave_taken
  FROM   per_absence_attendance_types  pat
        ,per_absence_attendances  paat
  WHERE  pat.ABSENCE_ATTENDANCE_TYPE_ID = paat.ABSENCE_ATTENDANCE_TYPE_ID
  AND    pat.ABSENCE_CATEGORY  = 'S'
  AND    paat.person_id = c_person_id
  AND    to_char(paat.date_end,'YYYY') =  c_termination_year;

  --
  CURSOR  csr_pre_emp_sickness_holiday(c_person_id         NUMBER
                                      ,c_termination_year  VARCHAR2
                                      ,c_business_group_id NUMBER) IS
  SELECT  pem_information1
  FROM    per_previous_employers
  WHERE   business_group_id        = c_business_group_id
  AND     person_id                = c_person_id
  AND     to_char(end_date,'YYYY') = c_termination_year
  ORDER BY end_date DESC;

  --
  CURSOR csr_pension_provider_code(c_meaning VARCHAR)IS
  SELECT hrl.lookup_code
  FROM   hr_lookups hrl
  WHERE  hrl.lookup_type   = 'HU_PENSION_PROVIDERS'
  AND    hrl.meaning       = c_meaning
  AND    hrl.enabled_flag  = 'Y' ;
  --
  l_found BOOLEAN;
  l_employee_data csr_employee_data%rowtype;
  l_action_info_id number;
  l_ovn number;

  l_ppension_data csr_pension_data%rowtype;
  l_vpension_data csr_pension_data%rowtype;

  l_Payroll_id                NUMBER;
  l_start_date                DATE;
  l_end_date                  DATE;
  l_business_group_id         NUMBER;
  l_issue_date                DATE;
  l_pension_provider_code     hr_lookups.lookup_code%TYPE;
  l_ele_entry_start_date      pay_element_entries_f.effective_start_date%TYPE;
  l_pre_emp_sickness_holiday  per_previous_employers.pem_information1%TYPE;
  l_total_sickness_holiday    NUMBER;
  l_account_no                pay_external_accounts.segment2%TYPE;
  l_absence_days              NUMBER;

  TYPE t_vpp_name IS TABLE OF hr_organization_units.name%type INDEX BY BINARY_INTEGER;
  l_vpp_name t_vpp_name;
  lctr number;
  --
BEGIN
  --

  OPEN csr_employee_data;
  FETCH csr_employee_data INTO l_employee_data;
  l_found := csr_employee_data%found;
  CLOSE csr_employee_data;

  IF l_found THEN
    p_assignment_id := l_employee_data.assignment_id;
    p_person_id     := l_employee_data.person_id;
    p_end_date      := l_employee_data.actual_termination_date ;


    get_all_parameters (l_employee_data.payroll_action_id
                     ,l_business_group_id
                     ,l_start_date
                     ,l_end_date
                     ,l_payroll_id
                     ,l_issue_date);

    OPEN csr_pension_data (l_employee_data.assignment_id, l_employee_data.termination_date, 'PPF');
    FETCH csr_pension_data INTO  l_ppension_data;
    CLOSE csr_pension_data;
    --

    OPEN csr_account_details(l_employee_data.termination_date,l_ppension_data.payment_method_id);
    FETCH csr_account_details INTO l_account_no;
    CLOSE  csr_account_details;
    --

    OPEN csr_element_start_date(l_ppension_data.ppf_element_entry_id);
    FETCH csr_element_start_date INTO l_ele_entry_start_date;
    CLOSE csr_element_start_date;
    --

    OPEN csr_pension_provider_code(l_ppension_data.provider_name);
    FETCH csr_pension_provider_code INTO l_pension_provider_code;
    CLOSE csr_pension_provider_code;
    --
    lctr := 1;
    FOR v_pension_data IN csr_pension_data (l_employee_data.assignment_id, l_employee_data.termination_date, 'VPF') loop
      l_vpp_name(lctr) := v_pension_data.provider_name;
      lctr := lctr + 1;
    END LOOP;

    LOOP
      EXIT WHEN lctr > 5;
        l_vpp_name(lctr) := ' ';
        lctr := lctr + 1;
    END LOOP;
    --
    l_absence_days := NULL;

    OPEN csr_absence_days (l_employee_data.person_id, to_char(l_employee_data.actual_termination_date,'YYYY'));
    FETCH csr_absence_days INTO l_absence_days;
    CLOSE csr_absence_days;

    IF l_absence_days IS NULL THEN
        OPEN csr_sickness_holiday_taken (l_employee_data.person_id, to_char(l_employee_data.actual_termination_date,'YYYY')
                                     ,l_employee_data.actual_termination_date);
        FETCH csr_sickness_holiday_taken INTO  l_absence_days;
        CLOSE csr_sickness_holiday_taken;
    END IF;
    --
    OPEN csr_pre_emp_sickness_holiday(l_employee_data.person_id
                                     ,to_char(l_employee_data.actual_termination_date,'YYYY')
                                     ,l_business_group_id);
    FETCH csr_pre_emp_sickness_holiday INTO l_pre_emp_sickness_holiday;
    CLOSE csr_pre_emp_sickness_holiday;
    --

    l_total_sickness_holiday := NVL(l_absence_days,0) + to_number(NVL(l_pre_emp_sickness_holiday,'0')) ;

    -- Archiving Employee Data
    pay_action_information_api.create_action_information (
      p_action_information_id        =>  l_action_info_id
    , p_action_context_id            =>  p_assactid
    , p_action_context_type          =>  'AAP'
    , p_object_version_number        =>  l_ovn
    , p_assignment_id                =>  l_employee_data.assignment_id
    , p_effective_date               =>  p_effective_date
    , p_action_information_category  =>  'HU_EMP_CERTIFICATION'
    , p_action_information1          =>  l_employee_data.person_id
    , p_action_information2          =>  l_employee_data.organization_id
    , p_action_information5          =>  l_employee_data.company_name
    , p_action_information6          =>  l_employee_data.full_name
    , p_action_information7          =>  l_employee_data.Maiden_name
    , p_action_information8          =>  l_employee_data.social_security_code
    , p_action_information9          =>  l_employee_data.place_of_birth
    , p_action_information10         =>  l_employee_data.date_of_birth
    , p_action_information11         =>  l_employee_data.mother_maiden_name
    , p_action_information12         =>  l_employee_data.hire_date
    , p_action_information13         =>  l_employee_data.Termination_date
    , p_action_information14         =>  l_total_sickness_holiday
    , p_action_information15         =>  l_employee_data.railway_benefit
    , p_action_information16         =>  fnd_date.date_to_displaydate(nvl(fnd_date.canonical_to_date(l_ppension_data.start_date),l_ele_entry_start_date))
    , p_action_information17         =>  l_pension_provider_code
    , p_action_information18         =>  l_ppension_data.provider_name
    , p_action_information19         =>  l_ppension_data.address
    , p_action_information20         =>  l_account_no
    , p_action_information21         =>  l_vpp_name(1)
    , p_action_information22         =>  l_vpp_name(2)
    , p_action_information23         =>  l_vpp_name(3)
    , p_action_information24         =>  l_vpp_name(4)
    , p_action_information25         =>  l_vpp_name(5)
    , p_action_information26         =>  fnd_date.date_to_displaydate(l_issue_date)
    );
  END IF;
END get_employee_data;

END per_hu_emp_cert_archive;

/
