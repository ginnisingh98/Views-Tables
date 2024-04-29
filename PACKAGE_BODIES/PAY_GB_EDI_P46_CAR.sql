--------------------------------------------------------
--  DDL for Package Body PAY_GB_EDI_P46_CAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_EDI_P46_CAR" AS
/* $Header: pygbp46c.pkb 120.7.12010000.3 2009/12/21 12:47:00 namgoyal ship $ */

g_package    CONSTANT VARCHAR2(20):= 'pay_gb_edi_p46_car.';

-- Global Variables for Process Parameters
g_payroll_id                    pay_payrolls_f.payroll_id%TYPE;
g_start_date                    DATE;
g_end_date                      DATE;
g_business_group_id             hr_organization_units.business_group_id%TYPE;
g_tax_ref                       VARCHAR2(20);

-- Global Variables
g_effective_date                DATE;

-- Global Cursors
CURSOR c_allocations(p_assignment_id IN NUMBER) IS
SELECT vehicle_allocation_id,
       Vehicle_repository_id,
       Usage_type,
       effective_start_date,
       effective_end_date
FROM pqp_vehicle_allocations_f va
WHERE va.assignment_id = p_assignment_id
AND ( (va.effective_start_date BETWEEN g_start_date AND g_end_date
       OR va.effective_end_date BETWEEN g_start_date AND g_end_date)
    OR (g_start_date BETWEEN va.effective_start_date AND va.effective_end_date
        AND g_end_date BETWEEN va.effective_start_date AND va.effective_end_date) )
AND 'C' = (SELECT vr.vehicle_type
           FROM pqp_vehicle_repository_f vr
           WHERE vr.vehicle_repository_id =
                    va.vehicle_repository_id
           AND vr.vehicle_ownership = 'C'
           AND va.effective_start_date
               BETWEEN vr.effective_start_date
               AND vr.effective_end_date)
AND va.private_use_flag = 'Y' --Added for bug 9215471
ORDER BY vehicle_allocation_id,
         effective_start_date;
--
CURSOR c_first_asg (p_assignment_id IN NUMBER, p_eff_date IN DATE) IS
SELECT min(paaf.assignment_id) assignment_id
FROM   pay_all_payrolls_f papf,
       hr_soft_coding_keyflex sck,
       per_all_assignments_f paaf,
       per_all_assignments_f paaf2,
       Pqp_vehicle_repository_f vr,
       Pqp_vehicle_allocations_f va
WHERE  paaf2.assignment_id = p_assignment_id
AND    paaf2.person_id = paaf.person_id
AND    p_eff_date
       BETWEEN paaf.effective_start_date
       AND paaf.effective_end_date
AND    papf.payroll_id = paaf.payroll_id
AND    p_eff_date
       BETWEEN papf.effective_start_date
       AND papf.effective_end_date
AND    papf.soft_coding_keyflex_id =
          sck.soft_coding_keyflex_id
AND    sck.segment1 = g_tax_ref
AND    paaf.assignment_id = va.assignment_id
AND    p_eff_date
       BETWEEN va.effective_start_date
       AND va.effective_end_date
AND    va.usage_type = 'P'
AND    va.vehicle_repository_id =
             vr.vehicle_repository_id
AND    p_eff_date
       BETWEEN vr.effective_start_date
       AND vr.effective_end_date
AND    vr.vehicle_ownership = 'C'
AND    vr.vehicle_type = 'C';
--
first_asg_rec   c_first_asg%ROWTYPE;
--
CURSOR c_alloc_dates(p_vehicle_allocation_id NUMBER) IS
SELECT min(effective_start_Date) min_start_date,
       max(effective_end_date) max_end_Date
FROM pqp_vehicle_allocations_f va
WHERE va.vehicle_allocation_id = p_vehicle_allocation_id;
--
alc_dates_rec   c_alloc_dates%ROWTYPE;
--
CURSOR c_primary_car(p_assignment_id IN NUMBER, p_eff_date IN DATE) IS
SELECT va.vehicle_allocation_id,
       vr.vehicle_repository_id
FROM   Pqp_vehicle_repository_f vr,
       Pqp_vehicle_allocations_f va
WHERE  va.assignment_id = p_assignment_id
AND    p_eff_date
       BETWEEN va.effective_start_date
       AND va.effective_end_date
AND    va.usage_type = 'P'
AND    va.vehicle_repository_id =
             vr.vehicle_repository_id
AND    p_eff_date
       BETWEEN vr.effective_start_date
       AND vr.effective_end_date
AND    vr.vehicle_ownership = 'C'
AND    vr.vehicle_type = 'C';
--
primary_car_rec   c_primary_car%ROWTYPE;
--
CURSOR c_prior_prim_car(p_assignment_id IN NUMBER,
                      P_new_car_start_date IN DATE)
IS
SELECT va.vehicle_allocation_id,
       Va.vehicle_repository_id,
       vr.make,
       vr.model,
       vr.engine_capacity_in_cc,
       va.effective_end_date
FROM   Pqp_vehicle_allocations_f va,
       pqp_vehicle_repository_f vr
WHERE  va.assignment_id = p_assignment_id
AND    va.effective_end_date
       BETWEEN (p_new_car_start_date - 30)
       AND (p_new_car_start_date - 1)
AND    va.usage_type = 'P'
AND    va.effective_end_date =
         (SELECT max(va2.effective_end_date)
          FROM   Pqp_vehicle_allocations_f va2
          WHERE  va2.assignment_id = p_assignment_id
          AND    va2.effective_end_date
                 BETWEEN (p_new_car_start_date - 30)
                 AND (p_new_car_start_date - 1)
          AND    va2.usage_type = 'P')
AND    va.vehicle_repository_id = vr.vehicle_repository_id
AND    vr.vehicle_ownership = 'C'
AND    vr.vehicle_type = 'C'
AND    va.effective_end_date
       BETWEEN vr.effective_start_date
       AND vr.effective_end_Date;
--
prior_prim_car_rec   c_prior_prim_car%ROWTYPE;
--
CURSOR c_next_prim_car(p_assignment_id IN NUMBER,
                      P_withdrawn_car_end_date IN DATE)
IS
SELECT va.vehicle_allocation_id,
       Va.vehicle_repository_id,
       vr.make,
       vr.model,
       vr.engine_capacity_in_cc,
       va.effective_end_date
FROM   Pqp_vehicle_allocations_f va,
       pqp_vehicle_repository_f vr
WHERE  va.assignment_id = p_assignment_id
AND    va.effective_start_date
       BETWEEN (p_withdrawn_car_end_date + 1)
       AND least((p_withdrawn_car_end_date + 30), g_end_date)
AND    va.usage_type = 'P'
AND    va.effective_start_date =
         (SELECT min(va2.effective_start_date)
          FROM   Pqp_vehicle_allocations_f va2
          WHERE  va2.assignment_id = p_assignment_id
          AND    va2.effective_start_date
          BETWEEN (p_withdrawn_car_end_date + 1)
          AND least((p_withdrawn_car_end_date + 30), g_end_date)
          AND    va2.usage_type = 'P')
AND    va.vehicle_repository_id = vr.vehicle_repository_id
AND    vr.vehicle_ownership = 'C'
AND    vr.vehicle_type = 'C'
AND    va.effective_end_date
       BETWEEN vr.effective_start_date
       AND vr.effective_end_Date;
--
next_prim_car_rec   c_next_prim_car%ROWTYPE;
--
CURSOR c_vehicle_changes(
              p_vehicle_repository_id IN NUMBER) IS
SELECT effective_start_date,
       effective_end_date,
       h1.description fuel_type
FROM pqp_vehicle_repository_f vr1,
     hr_lookups h1
WHERE vr1.vehicle_repository_id = p_vehicle_repository_id
AND   vr1.effective_start_date BETWEEN g_start_date AND g_end_date
AND   vr1.fuel_type = h1.lookup_code
AND   h1.lookup_type = 'PQP_FUEL_TYPE'
AND   h1.enabled_flag = 'Y'
AND   trunc(sysdate) BETWEEN trunc(nvl(h1.start_date_active, sysdate-1)) AND trunc(nvl(h1.end_date_active,sysdate+1))
AND EXISTS (SELECT 1
            FROM pqp_vehicle_repository_f vr2
            WHERE vr2.vehicle_repository_id =
                           p_vehicle_repository_id
            AND vr2.effective_end_date =
                       vr1.effective_start_date-1
            AND vr2.fuel_type <> vr1.fuel_type)
ORDER BY vr1.effective_start_date;
--
CURSOR c_veh_details(p_assignment_id IN NUMBER,
                        p_eff_date IN DATE) IS
SELECT va.vehicle_allocation_id,
       va.vehicle_repository_id,
       va.usage_type usage_type,
       va.effective_start_date,
       va.effective_end_date
FROM   Pqp_vehicle_repository_f vr,
       Pqp_vehicle_allocations_f va
WHERE  va.assignment_id = p_assignment_id
AND    p_eff_date BETWEEN va.effective_start_date AND va.effective_end_date
AND    va.vehicle_repository_id = vr.vehicle_repository_id
AND    p_eff_date BETWEEN vr.effective_start_date AND vr.effective_end_date
AND    vr.vehicle_ownership = 'C'
AND    vr.vehicle_type = 'C';
--
CURSOR c_tax_ref(p_assignment_id IN NUMBER,
                 p_eff_date IN DATE) IS
SELECT flex.segment1 tax_ref
FROM   hr_soft_coding_keyflex flex,
       per_assignments_f asg,
       Pay_payrolls_f ppf
WHERE  asg.assignment_id = p_assignment_id
AND    p_eff_date BETWEEN asg.effective_start_date AND asg.effective_end_date
AND    asg.payroll_id = ppf.payroll_id
AND    p_eff_date BETWEEN ppf.effective_start_Date and ppf.effective_end_date
AND    ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id;
--
l_previous_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
l_next_tax_ref     hr_soft_coding_keyflex.segment1%TYPE;
--
-----------------------------------------------------
--          FUNCTION CHK_ACTION_ARCHIVED           --
-----------------------------------------------------
FUNCTION chk_action_archived(
                    p_assignment_id IN NUMBER,
                    p_vehicle_allocation_id IN NUMBER,
                    p_allocation_start_date IN DATE,
                    p_action_flag IN VARCHAR2)
RETURN VARCHAR2 IS
   --
   CURSOR c_chk_archive IS
   SELECT 'Y' found_flag
   FROM pay_action_information pai,
        pay_assignment_actions act,
        pay_payroll_actions ppa
   WHERE ppa.report_type = 'P46_CAR_EDI'
   AND   ppa.report_qualifier='GB'
   AND   ppa.report_category ='EDI'
   AND   ppa.action_type = 'X'
   AND   g_business_group_id = ppa.business_group_id
   AND   ppa.payroll_action_id = act.payroll_action_id
   AND   p_assignment_id = act.assignment_id
   AND   act.assignment_action_id = pai.action_context_id
   AND   'AAP' = pai.action_context_type
   AND   'GB P46 CAR EDI ALLOCATION' = pai.action_information_category
   AND   p_action_flag = pai.action_information1
   AND   to_char(p_vehicle_allocation_id) = pai.action_information2
   AND   fnd_date.date_to_canonical(p_allocation_start_date) = pai.action_information3;
   --
   chk_archive_rec c_chk_archive%ROWTYPE;
   --
   l_archived_flag VARCHAR2(1) := 'Y';
   l_proc VARCHAR2(50) := g_package||'CHK_ACTION_ARCHIVED';
BEGIN
   hr_utility.set_location(l_proc, 10);
   hr_utility.trace(l_proc||': p_assignment_id='|| p_assignment_id);
   hr_utility.trace(l_proc||': p_vehicle_allocation_id='|| p_vehicle_allocation_id);
   hr_utility.trace(l_proc||': p_allocation_start_date='|| fnd_date.date_to_displaydate(p_allocation_start_date));
   hr_utility.trace(l_proc||': p_action_flag='|| p_action_flag);
   --
   OPEN c_chk_archive;
   FETCH c_chk_archive INTO chk_archive_rec;
   IF c_chk_archive%NOTFOUND THEN
         hr_utility.set_location(l_proc, 20);
         l_archived_flag := 'N';
   END IF;
   CLOSE c_chk_archive;
   --
   hr_utility.set_location(l_proc, 30);
   RETURN l_archived_flag;
END chk_action_archived;

--For Bug 6652235
-----------------------------------------------------
--          FUNCTION CHK_ACTION_ARCHIVED_V2         --
-----------------------------------------------------
FUNCTION chk_action_archived_v2(
                    p_assignment_id IN NUMBER,
                    p_vehicle_allocation_id IN NUMBER,
                    p_allocation_start_date IN DATE,
                    p_action_flag IN VARCHAR2)
RETURN VARCHAR2 IS
   --
   CURSOR c_chk_archive IS
   SELECT 'Y' found_flag
   FROM pay_action_information pai,
        pay_assignment_actions act,
        pay_payroll_actions ppa
   WHERE ppa.report_type IN ('P46_CAR_EDI_V2','P46_CAR_EDI','P46_CAR_EDI_V3') --Bug 8986543: Added V3
   AND   ppa.report_qualifier='GB'
   AND   ppa.report_category ='EDI'
   AND   ppa.action_type = 'X'
   AND   g_business_group_id = ppa.business_group_id
   AND   ppa.payroll_action_id = act.payroll_action_id
   AND   p_assignment_id = act.assignment_id
   AND   act.assignment_action_id = pai.action_context_id
   AND   'AAP' = pai.action_context_type
   AND   'GB P46 CAR EDI ALLOCATION' = pai.action_information_category
   AND   p_action_flag = pai.action_information1
   AND   to_char(p_vehicle_allocation_id) = pai.action_information2
   AND   fnd_date.date_to_canonical(p_allocation_start_date) = pai.action_information3;
   --
   chk_archive_rec c_chk_archive%ROWTYPE;
   --
   l_archived_flag VARCHAR2(1) := 'Y';
   l_proc VARCHAR2(50) := g_package||'CHK_ACTION_ARCHIVED_V2';
BEGIN
   hr_utility.set_location(l_proc, 10);
   hr_utility.trace(l_proc||': p_assignment_id='|| p_assignment_id);
   hr_utility.trace(l_proc||': p_vehicle_allocation_id='|| p_vehicle_allocation_id);
   hr_utility.trace(l_proc||': p_allocation_start_date='|| fnd_date.date_to_displaydate(p_allocation_start_date));
   hr_utility.trace(l_proc||': p_action_flag='|| p_action_flag);
   --
   OPEN c_chk_archive;
   FETCH c_chk_archive INTO chk_archive_rec;
   IF c_chk_archive%NOTFOUND THEN
         hr_utility.set_location(l_proc, 20);
         l_archived_flag := 'N';
   END IF;
   CLOSE c_chk_archive;
   --
   hr_utility.set_location(l_proc, 30);
   RETURN l_archived_flag;
END chk_action_archived_v2;

-----------------------------------------------------
--                RANGE_CURSOR                     --
-----------------------------------------------------
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr out nocopy varchar2) IS
--
   CURSOR c_employer IS
   SELECT
       substr(org.org_information3,1,36)    employer_name,
       substr(org.org_information4,1,60)    employer_address_line,
       substr(org.org_information2 ,1,40)   tax_district_name,
       organization_id,
       ppa.effective_date
     FROM
       pay_payroll_actions ppa,
       hr_organization_information org
     WHERE ppa.payroll_action_id = pactid
     AND   org.org_information_context = 'Tax Details References'
     AND   NVL(org.org_information10,'UK') = 'UK'
     AND   org.organization_id = ppa.business_group_id
     AND   substr(ppa.legislative_parameters,
                instr(ppa.legislative_parameters,'TAX_REF=') + 8,
                    instr(ppa.legislative_parameters||' ',' ',
                          instr(ppa.legislative_parameters,'TAX_REF=')+8)
                - instr(ppa.legislative_parameters,'TAX_REF=') - 8)
             = org.org_information1
     AND   ppa.report_type  = 'P46_CAR_EDI'
     AND   report_qualifier = 'GB'
     AND   ppa.report_category = 'EDI';
   --
   employer_rec       c_employer%ROWTYPE;
   l_proc             CONSTANT VARCHAR2(35):= g_package||'range_cursor';
   l_action_info_id   pay_action_information.action_information_id%TYPE;
   l_ovn              pay_action_information.object_version_number%TYPE;
   --
BEGIN
   --
--   hr_utility.trace_on(null, 'RMAKHIJA');
   hr_utility.set_location('Enering: '||l_proc, 10);
   hr_utility.trace(l_proc||': payroll_action_id='||pactid);
   --
   -- Get Employer information
   OPEN c_employer;
   FETCH c_employer INTO employer_rec;
   IF c_employer%NOTFOUND THEN
      hr_utility.set_location(l_proc, 20);
      raise NO_DATA_FOUND;
   END IF;
   CLOSE c_employer;
   --
   g_effective_date := employer_rec.effective_Date;
   --
   hr_utility.trace(l_proc||': employer_name='||employer_rec.employer_name);
   hr_utility.trace(l_proc||': employer_address_line='||employer_rec.employer_address_line);
   hr_utility.trace(l_proc||': tax_district_name='||employer_rec.tax_district_name);
   hr_utility.trace(l_proc||': organization_id='||employer_rec.organization_id);
   hr_utility.trace(l_proc||': effective_Date='||fnd_date.date_to_displaydate(employer_rec.effective_date));
   --
   pay_action_information_api.create_action_information (
       p_action_information_id        =>  l_action_info_id
     , p_action_context_id            =>  pactid
     , p_action_context_type          =>  'PA'
     , p_object_version_number        =>  l_ovn
     , p_assignment_id                =>  NULL
     , p_effective_date               =>  g_effective_date
     , p_source_id                    =>  NULL
     , p_source_text                  =>  NULL
     , p_action_information_category  =>  'GB P46 CAR EDI EMPLOYER DETAIL'
     , p_action_information1          =>  upper(employer_rec.organization_id)
     , p_action_information2          =>  upper(employer_rec.employer_name)
     , p_action_information3          =>  upper(employer_rec.tax_district_name)
     , p_action_information4          =>  upper(employer_rec.employer_address_line));
   --
   hr_utility.set_location(l_proc, 30);
   --
   sqlstr := 'select distinct person_id '||
             'from per_people_f ppf, '||
             'pay_payroll_actions ppa '||
             'where ppa.payroll_action_id = :payroll_action_id '||
             'and ppa.business_group_id = ppf.business_group_id '||
             'order by ppf.person_id';

   --
   hr_utility.set_location('Leaving: '||l_proc, 100);
   --
--    hr_utility.trace_off;
EXCEPTION
  WHEN OTHERS THEN
    -- Return cursor that selects no rows
    sqlstr := 'select 1 '||
              '/* ERROR - Employer Details Fetch failed with: '||
              sqlerrm(sqlcode)||' */ '||
              'from dual where to_char(:payroll_action_id) = dummy';
    hr_utility.set_location(' Leaving: '||l_proc,110);
END range_cursor;

--For Bug 6652235
-----------------------------------------------------
--                RANGE_CODE for V2                     --
-----------------------------------------------------
PROCEDURE range_code (pactid IN NUMBER,
                        sqlstr out nocopy varchar2) IS
--
   CURSOR c_employer IS
   SELECT
       substr(org.org_information3,1,36)    employer_name,
       substr(org.org_information4,1,60)    employer_address_line,
       substr(org.org_information2 ,1,40)   tax_district_name,
       organization_id,
       ppa.effective_date
     FROM
       pay_payroll_actions ppa,
       hr_organization_information org
     WHERE ppa.payroll_action_id = pactid
     AND   org.org_information_context = 'Tax Details References'
     AND   NVL(org.org_information10,'UK') = 'UK'
     AND   org.organization_id = ppa.business_group_id
     AND   substr(ppa.legislative_parameters,
                instr(ppa.legislative_parameters,'TAX_REF=') + 8,
                    instr(ppa.legislative_parameters||' ',' ',
                          instr(ppa.legislative_parameters,'TAX_REF=')+8)
                - instr(ppa.legislative_parameters,'TAX_REF=') - 8)
             = org.org_information1
     AND   ppa.report_type = 'P46_CAR_EDI_V2'
     AND   report_qualifier = 'GB'
     AND   ppa.report_category = 'EDI';
   --
   employer_rec       c_employer%ROWTYPE;
   l_proc             CONSTANT VARCHAR2(35):= g_package||'range_code';
   l_action_info_id   pay_action_information.action_information_id%TYPE;
   l_ovn              pay_action_information.object_version_number%TYPE;
   --
BEGIN
   --
--   hr_utility.trace_on(null, 'RMAKHIJA');
   hr_utility.set_location('Enering: '||l_proc, 10);
   hr_utility.trace(l_proc||': payroll_action_id='||pactid);
   --
   -- Get Employer information
   OPEN c_employer;
   FETCH c_employer INTO employer_rec;
   IF c_employer%NOTFOUND THEN
      hr_utility.set_location(l_proc, 20);
      raise NO_DATA_FOUND;
   END IF;
   CLOSE c_employer;
   --
   g_effective_date := employer_rec.effective_Date;
   --
   hr_utility.trace(l_proc||': employer_name='||employer_rec.employer_name);
   hr_utility.trace(l_proc||': employer_address_line='||employer_rec.employer_address_line);
   hr_utility.trace(l_proc||': tax_district_name='||employer_rec.tax_district_name);
   hr_utility.trace(l_proc||': organization_id='||employer_rec.organization_id);
   hr_utility.trace(l_proc||': effective_Date='||fnd_date.date_to_displaydate(employer_rec.effective_date));
   --
   pay_action_information_api.create_action_information (
       p_action_information_id        =>  l_action_info_id
     , p_action_context_id            =>  pactid
     , p_action_context_type          =>  'PA'
     , p_object_version_number        =>  l_ovn
     , p_assignment_id                =>  NULL
     , p_effective_date               =>  g_effective_date
     , p_source_id                    =>  NULL
     , p_source_text                  =>  NULL
     , p_action_information_category  =>  'GB P46 CAR EDI EMPLOYER DETAIL'
     , p_action_information1          =>  upper(employer_rec.organization_id)
     , p_action_information2          =>  upper(employer_rec.employer_name)
     , p_action_information3          =>  upper(employer_rec.tax_district_name)
     , p_action_information4          =>  upper(employer_rec.employer_address_line));
   --
   hr_utility.set_location(l_proc, 30);
   --
   sqlstr := 'select distinct person_id '||
             'from per_people_f ppf, '||
             'pay_payroll_actions ppa '||
             'where ppa.payroll_action_id = :payroll_action_id '||
             'and ppa.business_group_id = ppf.business_group_id '||
             'order by ppf.person_id';

   --
   hr_utility.set_location('Leaving: '||l_proc, 100);
   --
--    hr_utility.trace_off;
EXCEPTION
  WHEN OTHERS THEN
    -- Return cursor that selects no rows
    sqlstr := 'select 1 '||
              '/* ERROR - Employer Details Fetch failed with: '||
              sqlerrm(sqlcode)||' */ '||
              'from dual where to_char(:payroll_action_id) = dummy';
    hr_utility.set_location(' Leaving: '||l_proc,110);
END range_code;


--For Bug 8986543
-----------------------------------------------------
--                RANGE_CODE_V3                     --
-----------------------------------------------------
PROCEDURE range_code_v3 (pactid IN NUMBER,
                        sqlstr out nocopy varchar2) IS
--
   CURSOR c_employer IS
   SELECT
       substr(org.org_information3,1,36)    employer_name,
       substr(org.org_information4,1,60)    employer_address_line,
       substr(org.org_information2 ,1,40)   tax_district_name,
       organization_id,
       ppa.effective_date
     FROM
       pay_payroll_actions ppa,
       hr_organization_information org
     WHERE ppa.payroll_action_id = pactid
     AND   org.org_information_context = 'Tax Details References'
     AND   NVL(org.org_information10,'UK') = 'UK'
     AND   org.organization_id = ppa.business_group_id
     AND   substr(ppa.legislative_parameters,
                instr(ppa.legislative_parameters,'TAX_REF=') + 8,
                    instr(ppa.legislative_parameters||' ',' ',
                          instr(ppa.legislative_parameters,'TAX_REF=')+8)
                - instr(ppa.legislative_parameters,'TAX_REF=') - 8)
             = org.org_information1
     AND   ppa.report_type = 'P46_CAR_EDI_V3'
     AND   report_qualifier = 'GB'
     AND   ppa.report_category = 'EDI';
   --
   employer_rec       c_employer%ROWTYPE;
   l_proc             CONSTANT VARCHAR2(100):= g_package||'range_code_v3';
   l_action_info_id   pay_action_information.action_information_id%TYPE;
   l_ovn              pay_action_information.object_version_number%TYPE;
   --
BEGIN
   --
   hr_utility.set_location('Enering: '||l_proc, 10);
   hr_utility.trace(l_proc||': payroll_action_id='||pactid);
   --
   -- Get Employer information
   OPEN c_employer;
   FETCH c_employer INTO employer_rec;
   IF c_employer%NOTFOUND THEN
      hr_utility.set_location(l_proc, 20);
      raise NO_DATA_FOUND;
   END IF;
   CLOSE c_employer;
   --
   g_effective_date := employer_rec.effective_Date;
   --
   hr_utility.trace(l_proc||': employer_name='||employer_rec.employer_name);
   hr_utility.trace(l_proc||': employer_address_line='||employer_rec.employer_address_line);
   hr_utility.trace(l_proc||': tax_district_name='||employer_rec.tax_district_name);
   hr_utility.trace(l_proc||': organization_id='||employer_rec.organization_id);
   hr_utility.trace(l_proc||': effective_Date='||fnd_date.date_to_displaydate(employer_rec.effective_date));
   --
   pay_action_information_api.create_action_information (
       p_action_information_id        =>  l_action_info_id
     , p_action_context_id            =>  pactid
     , p_action_context_type          =>  'PA'
     , p_object_version_number        =>  l_ovn
     , p_assignment_id                =>  NULL
     , p_effective_date               =>  g_effective_date
     , p_source_id                    =>  NULL
     , p_source_text                  =>  NULL
     , p_action_information_category  =>  'GB P46 CAR EDI EMPLOYER DETAIL'
     , p_action_information1          =>  upper(employer_rec.organization_id)
     , p_action_information2          =>  upper(employer_rec.employer_name)
     , p_action_information3          =>  upper(employer_rec.tax_district_name)
     , p_action_information4          =>  upper(employer_rec.employer_address_line));
   --
   hr_utility.set_location(l_proc, 30);
   --
   sqlstr := 'select distinct person_id '||
             'from per_people_f ppf, '||
             'pay_payroll_actions ppa '||
             'where ppa.payroll_action_id = :payroll_action_id '||
             'and ppa.business_group_id = ppf.business_group_id '||
             'order by ppf.person_id';

   --
   hr_utility.set_location('Leaving: '||l_proc, 100);
   --
--    hr_utility.trace_off;
EXCEPTION
  WHEN OTHERS THEN
    -- Return cursor that selects no rows
    sqlstr := 'select 1 '||
              '/* ERROR - Employer Details Fetch failed with: '||
              sqlerrm(sqlcode)||' */ '||
              'from dual where to_char(:payroll_action_id) = dummy';
    hr_utility.set_location(' Leaving: '||l_proc,110);
END range_code_v3;

-----------------------------------------------------
--         PROCEDURE CREATE_ASG_ACT                --
-----------------------------------------------------
PROCEDURE create_asg_act(pactid IN NUMBER,
                            stperson IN NUMBER,
                            endperson IN NUMBER,
                            chunk IN NUMBER) IS
   --
   l_proc          CONSTANT VARCHAR2(35):= g_package||'create_asg_act';
   l_actid         pay_assignment_actions.assignment_action_id%TYPE;
   l_ovn           pay_action_information.object_version_number%TYPE;
   --
   --
   CURSOR c_param_values IS
   SELECT to_number( pay_gb_eoy_archive.get_parameter(
                          legislative_parameters,
                          'PAYROLL_ID')) payroll_id,
          substr( pay_gb_eoy_archive.get_parameter(
                          legislative_parameters,
                          'TAX_REF'),1,20) tax_ref,
          start_date,
          effective_date,
          fnd_date.canonical_to_date(
             pay_gb_eoy_archive.get_parameter(
                          legislative_parameters,
                              'END_DATE'))  end_date,
          business_group_id
   FROM  pay_payroll_actions
   WHERE payroll_action_id = pactid;
   --
   CURSOR c_asg IS
   SELECT /* USE_INDEX(va,PQP_VEHICLE_ALLOCATIONS_F_N1)
          */
          asg.assignment_id,
          min(asg.effective_start_date) asg_min_start_date,
          max(asg.effective_end_date) asg_max_end_date
   FROM   hr_soft_coding_keyflex flex,
          per_all_assignments_f asg,
          pay_payrolls_f ppf,
          pqp_vehicle_allocations_f va,
          pqp_vehicle_repository_f vr
   WHERE  asg.person_id BETWEEN stperson AND endperson
   AND    asg.business_group_id = g_business_group_id
   AND    asg.payroll_id = nvl(g_payroll_id,asg.payroll_id)
   AND    asg.payroll_id = ppf.payroll_id
   AND    ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = g_tax_ref
   AND    (   g_start_date BETWEEN asg.effective_start_date AND asg.effective_end_date
           OR g_end_date   BETWEEN asg.effective_start_date AND asg.effective_end_date
           OR (    asg.effective_start_date BETWEEN g_start_date AND g_end_Date
               AND asg.effective_end_date  BETWEEN g_start_date AND g_end_Date))
   AND    va.assignment_id = asg.assignment_id
   AND    va.business_group_id = g_business_group_id
   AND    ( (   va.effective_start_date BETWEEN g_start_date AND g_end_date
             OR va.effective_end_date BETWEEN g_start_date AND g_end_date)
             OR (    g_start_date BETWEEN va.effective_start_date AND va.effective_end_date
                 AND g_end_date BETWEEN va.effective_start_date AND va.effective_end_date) )
   AND    vr.vehicle_repository_id = va.vehicle_repository_id
   AND    vr.vehicle_ownership = 'C'
   AND    vr.vehicle_type = 'C'
   AND    va.effective_start_date BETWEEN vr.effective_start_date AND vr.effective_end_date
   GROUP by asg.assignment_id;
   --
   l_create_assact_flag VARCHAR2(1);
   l_action_flag VARCHAR2(1);
   l_archived_flag VARCHAR2(1);
BEGIN
   --hr_utility.trace_on(null, 'KTHAMPAN');
   hr_utility.set_location('Entering '||l_proc, 10);
   --
   OPEN c_param_values;
   FETCH c_param_values INTO g_payroll_id,
                             g_tax_ref,
                             g_start_date,
                             g_effective_date,
                             g_end_date,
                             g_business_group_id;
   CLOSE c_param_values;
   --
   hr_utility.set_location(l_proc, 15);
   hr_utility.trace(l_proc||': g_payroll_id='||g_payroll_id);
   hr_utility.trace(l_proc||': g_tax_ref='||g_tax_ref);
   hr_utility.trace(l_proc||': g_start_date='||fnd_date.date_to_displaydate(g_start_date));
   hr_utility.trace(l_proc||': g_effective_date='||fnd_date.date_to_displaydate(g_effective_date));
   hr_utility.trace(l_proc||': g_end_date='||fnd_date.date_to_displaydate(g_end_date));
   hr_utility.trace(l_proc||': g_business_group_id='||g_business_group_id);
   For asg_rec IN c_asg
   LOOP
      -- Loop through all assignments
      hr_utility.set_location(l_proc, 20);
      hr_utility.trace(l_proc||': assignment_id='||asg_rec.assignment_id);
      hr_utility.trace(l_proc||': asg_min_start_date='||fnd_date.date_to_displaydate(asg_rec.asg_min_start_date));
      hr_utility.trace(l_proc||': asg_max_end_date='||fnd_date.date_to_displaydate(asg_rec.asg_max_end_date));
      --
      l_create_assact_flag := 'N';
      --
      FOR alc_rec IN c_allocations(asg_rec.assignment_id) LOOP
         -- Loop through all vehicle allocations
         -- over the date range
         hr_utility.set_location(l_proc, 30);
         hr_utility.trace(l_proc||': vehicle_allocation_id='||alc_rec.vehicle_allocation_id);
         hr_utility.trace(l_proc||': usage_type='||alc_rec.usage_type);
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         OPEN c_alloc_dates(alc_rec.vehicle_allocation_id);
         FETCH c_alloc_dates INTO alc_dates_rec;
         CLOSE c_alloc_dates;
         --
         hr_utility.set_location(l_proc, 40);
         hr_utility.trace(l_proc||': min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
         hr_utility.trace(l_proc||': max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
         --
         -- Check whether vehicle was allocated or
         -- Withdrawn within the date range also
         -- check that this allocation or withdrawal
         -- happened when assignment was with input tax ref
         IF (alc_dates_rec.min_start_date BETWEEN g_start_date AND g_end_Date) AND
            (alc_dates_rec.min_start_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            -- This is a New Car or replacement action
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  -- This is the first car allocation
                  -- of this employee in this tax ref
                  -- therefore check if it has replaced
                  -- any prior car
                  OPEN c_prior_prim_car(asg_rec.assignment_id, Alc_dates_rec.min_start_date);
                  FETCH c_prior_prim_car INTO prior_prim_car_rec;
                  IF c_prior_prim_car%FOUND THEN
                     L_action_flag := 'R';
                  ELSE
                     L_action_flag := 'N';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_prior_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as new car
                  L_action_flag := 'N';
               END IF;
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a primary car therefore mark
               -- it as new car allocation action
               l_action_flag := 'N';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         --
         IF (alc_dates_rec.max_end_date BETWEEN g_start_date AND g_end_Date) AND
               (alc_dates_rec.max_end_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  --
                  OPEN c_next_prim_car(asg_rec.assignment_id, Alc_dates_rec.max_end_date);
                  FETCH c_next_prim_car INTO next_prim_car_rec;
                  IF c_next_prim_car%FOUND THEN
                     -- There is a replacement action to
                     -- Report this car therefore
                     -- No need to archive this action
                     NULL;
                  ELSE
                     -- This is a withdrawal action
                     L_action_flag := 'W';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_next_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as withdrawal car
                  L_action_flag := 'W';
               END IF;
               --
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a first car therefore mark
               -- it as withdrawal car action
               l_action_flag := 'W';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
            END IF;
         END IF;
         -- Check if fuel type has changed within
         -- the date range.
         FOR vehicle_changes_rec IN c_vehicle_changes(alc_rec.vehicle_repository_id) LOOP
            -- Fuel type has changed therefore make sure
            -- this change occured after the vehicle was
            -- allocated to this assignment
            --
            hr_utility.set_location(l_proc, 110);
            hr_utility.trace(l_proc||': effective_start_date='|| vehicle_changes_rec.effective_start_date);
            hr_utility.trace(l_proc||': fuel_type='|| vehicle_changes_rec.fuel_type);
            --
            IF (vehicle_changes_rec.effective_start_date
                   BETWEEN alc_dates_rec.min_start_date+1 AND alc_dates_rec.max_end_date) AND
               (vehicle_changes_rec.effective_start_date
                   BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
               --
               -- Check if this fuel change has been
               -- already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          vehicle_changes_rec.effective_start_date,
                          'F');
               --
               hr_utility.set_location(l_proc, 120);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
                  --
               END IF;
            END IF;
         END LOOP;
         --
         hr_utility.set_location(l_proc, 130);
         --
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         ----------------------------------------------------
         -- If tax ref has changed within the given date   --
         -- range then check whether it should be reported --
         -- as a new allocation or withdrawal              --
         ----------------------------------------------------
         IF (asg_rec.asg_min_start_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
               AND (asg_rec.asg_min_start_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has started on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- start date therefore check whether it is a transfer
            -- from another tax ref
            hr_utility.set_location(l_proc, 160);
            l_previous_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_min_start_date-1);
            FETCH c_tax_ref INTO l_previous_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 170);
            hr_utility.trace(l_proc||', l_previous_tax_ref='||l_previous_tax_ref);
            --
            IF l_previous_tax_ref is NOT NULL AND l_previous_tax_ref <> g_tax_ref THEN
               -- This assignment has a different prior tax ref
               -- therefore it should be reported as a new car
               -- allocation on this EDI message.
               hr_utility.set_location(l_proc, 180);
               l_action_flag := 'N';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_min_start_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 190);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
               --
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         IF (asg_rec.asg_max_end_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
            AND (asg_rec.asg_max_end_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has ended on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- end date therefore check whether it is a transfer
            -- to another tax ref
            hr_utility.set_location(l_proc, 200);
            l_next_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_max_end_date+1);
            FETCH c_tax_ref INTO l_next_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 210);
            hr_utility.trace(l_proc||', l_next_tax_ref='||l_next_tax_ref);
            --
            IF l_next_tax_ref is NOT NULL AND l_next_tax_ref <> g_tax_ref THEN
               -- This assignment has a different tax ref after end date
               -- therefore it should be reported as allocation withdrawal
               -- on this EDI message.
               hr_utility.set_location(l_proc, 220);
               l_action_flag := 'W';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_max_end_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 230);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
               --
            END IF;
         END IF;
         --
         hr_utility.set_location(l_proc, 240);
         --
         hr_utility.set_location(l_proc, 250);
      END LOOP;
      --
      hr_utility.set_location(l_proc, 260);
      --
      -- If flag is set then create action
      IF l_create_assact_flag = 'Y' THEN
         --
         SELECT pay_assignment_actions_s.nextval
         INTO l_actid
         FROM dual;

         hr_utility.set_location(l_proc, 270);
         hr_utility.trace(l_proc||': l_actid='||l_actid);
         hr_utility.trace(l_proc||': asg_rec.assignment_id='||asg_rec.assignment_id);
         hr_utility.trace(l_proc||': pactid='||pactid);
         hr_utility.trace(l_proc||': chunk='||chunk);
         --
         hr_nonrun_asact.insact(l_actid,
                                asg_rec.assignment_id,
                                pactid,
                                chunk, NULL);
         --
         hr_utility.set_location(l_proc, 280);
         --
      END IF;
   END LOOP;
   --
   hr_utility.set_location('Leaving: '||l_proc,290);
   -- hr_utility.trace_off;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving: '||l_proc,300);
--    hr_utility.trace_off;
    raise;
END Create_asg_act;


--For Bug 6652235
-----------------------------------------------------
--         PROCEDURE CREATE_ASG_ACT_V2                --
-----------------------------------------------------
PROCEDURE create_asg_act_v2(pactid IN NUMBER,
                            stperson IN NUMBER,
                            endperson IN NUMBER,
                            chunk IN NUMBER) IS
   --
   l_proc          CONSTANT VARCHAR2(35):= g_package||'create_asg_act';
   l_actid         pay_assignment_actions.assignment_action_id%TYPE;
   l_ovn           pay_action_information.object_version_number%TYPE;
   --
   --
   CURSOR c_param_values IS
   SELECT to_number( pay_gb_eoy_archive.get_parameter(
                          legislative_parameters,
                          'PAYROLL_ID')) payroll_id,
          substr( pay_gb_eoy_archive.get_parameter(
                          legislative_parameters,
                          'TAX_REF'),1,20) tax_ref,
          start_date,
          effective_date,
          fnd_date.canonical_to_date(
             pay_gb_eoy_archive.get_parameter(
                          legislative_parameters,
                              'END_DATE'))  end_date,
          business_group_id
   FROM  pay_payroll_actions
   WHERE payroll_action_id = pactid;
   --
   CURSOR c_asg IS
   SELECT /* USE_INDEX(va,PQP_VEHICLE_ALLOCATIONS_F_N1)
          */
          asg.assignment_id,
          min(asg.effective_start_date) asg_min_start_date,
          max(asg.effective_end_date) asg_max_end_date
   FROM   hr_soft_coding_keyflex flex,
          per_all_assignments_f asg,
          pay_payrolls_f ppf,
          pqp_vehicle_allocations_f va,
          pqp_vehicle_repository_f vr
   WHERE  asg.person_id BETWEEN stperson AND endperson
   AND    asg.business_group_id = g_business_group_id
   AND    asg.payroll_id = nvl(g_payroll_id,asg.payroll_id)
   AND    asg.payroll_id = ppf.payroll_id
   AND    ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = g_tax_ref
   AND    (   g_start_date BETWEEN asg.effective_start_date AND asg.effective_end_date
           OR g_end_date   BETWEEN asg.effective_start_date AND asg.effective_end_date
           OR (    asg.effective_start_date BETWEEN g_start_date AND g_end_Date
               AND asg.effective_end_date  BETWEEN g_start_date AND g_end_Date))
   AND    va.assignment_id = asg.assignment_id
   AND    va.business_group_id = g_business_group_id
   AND    ( (   va.effective_start_date BETWEEN g_start_date AND g_end_date
             OR va.effective_end_date BETWEEN g_start_date AND g_end_date)
             OR (    g_start_date BETWEEN va.effective_start_date AND va.effective_end_date
                 AND g_end_date BETWEEN va.effective_start_date AND va.effective_end_date) )
   AND    vr.vehicle_repository_id = va.vehicle_repository_id
   AND    vr.vehicle_ownership = 'C'
   AND    vr.vehicle_type = 'C'
   AND    va.effective_start_date BETWEEN vr.effective_start_date AND vr.effective_end_date
   GROUP by asg.assignment_id;
   --
   l_create_assact_flag VARCHAR2(1);
   l_action_flag VARCHAR2(1);
   l_archived_flag VARCHAR2(1);
BEGIN
   --hr_utility.trace_on(null, 'KTHAMPAN');
   hr_utility.set_location('Entering '||l_proc, 10);
   --
   OPEN c_param_values;
   FETCH c_param_values INTO g_payroll_id,
                             g_tax_ref,
                             g_start_date,
                             g_effective_date,
                             g_end_date,
                             g_business_group_id;
   CLOSE c_param_values;
   --
   hr_utility.set_location(l_proc, 15);
   hr_utility.trace(l_proc||': g_payroll_id='||g_payroll_id);
   hr_utility.trace(l_proc||': g_tax_ref='||g_tax_ref);
   hr_utility.trace(l_proc||': g_start_date='||fnd_date.date_to_displaydate(g_start_date));
   hr_utility.trace(l_proc||': g_effective_date='||fnd_date.date_to_displaydate(g_effective_date));
   hr_utility.trace(l_proc||': g_end_date='||fnd_date.date_to_displaydate(g_end_date));
   hr_utility.trace(l_proc||': g_business_group_id='||g_business_group_id);
   For asg_rec IN c_asg
   LOOP
      -- Loop through all assignments
      hr_utility.set_location(l_proc, 20);
      hr_utility.trace(l_proc||': assignment_id='||asg_rec.assignment_id);
      hr_utility.trace(l_proc||': asg_min_start_date='||fnd_date.date_to_displaydate(asg_rec.asg_min_start_date));
      hr_utility.trace(l_proc||': asg_max_end_date='||fnd_date.date_to_displaydate(asg_rec.asg_max_end_date));
      --
      l_create_assact_flag := 'N';
      --
      FOR alc_rec IN c_allocations(asg_rec.assignment_id) LOOP
         -- Loop through all vehicle allocations
         -- over the date range
         hr_utility.set_location(l_proc, 30);
         hr_utility.trace(l_proc||': vehicle_allocation_id='||alc_rec.vehicle_allocation_id);
         hr_utility.trace(l_proc||': usage_type='||alc_rec.usage_type);
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         OPEN c_alloc_dates(alc_rec.vehicle_allocation_id);
         FETCH c_alloc_dates INTO alc_dates_rec;
         CLOSE c_alloc_dates;
         --
         hr_utility.set_location(l_proc, 40);
         hr_utility.trace(l_proc||': min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
         hr_utility.trace(l_proc||': max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
         --
         -- Check whether vehicle was allocated or
         -- Withdrawn within the date range also
         -- check that this allocation or withdrawal
         -- happened when assignment was with input tax ref
         IF (alc_dates_rec.min_start_date BETWEEN g_start_date AND g_end_Date) AND
            (alc_dates_rec.min_start_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            -- This is a New Car or replacement action
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  -- This is the first car allocation
                  -- of this employee in this tax ref
                  -- therefore check if it has replaced
                  -- any prior car
                  OPEN c_prior_prim_car(asg_rec.assignment_id, Alc_dates_rec.min_start_date);
                  FETCH c_prior_prim_car INTO prior_prim_car_rec;
                  IF c_prior_prim_car%FOUND THEN
                     L_action_flag := 'R';
                  ELSE
                     L_action_flag := 'N';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_prior_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as new car
                  L_action_flag := 'N';
               END IF;
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a primary car therefore mark
               -- it as new car allocation action
               l_action_flag := 'N';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         --
         IF (alc_dates_rec.max_end_date BETWEEN g_start_date AND g_end_Date) AND
               (alc_dates_rec.max_end_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  --
                  OPEN c_next_prim_car(asg_rec.assignment_id, Alc_dates_rec.max_end_date);
                  FETCH c_next_prim_car INTO next_prim_car_rec;
                  IF c_next_prim_car%FOUND THEN
                     -- There is a replacement action to
                     -- Report this car therefore
                     -- No need to archive this action
                     NULL;
                  ELSE
                     -- This is a withdrawal action
                     L_action_flag := 'W';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_next_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as withdrawal car
                  L_action_flag := 'W';
               END IF;
               --
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a first car therefore mark
               -- it as withdrawal car action
               l_action_flag := 'W';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
            END IF;
         END IF;
         -- Check if fuel type has changed within
         -- the date range.
         FOR vehicle_changes_rec IN c_vehicle_changes(alc_rec.vehicle_repository_id) LOOP
            -- Fuel type has changed therefore make sure
            -- this change occured after the vehicle was
            -- allocated to this assignment
            --
            hr_utility.set_location(l_proc, 110);
            hr_utility.trace(l_proc||': effective_start_date='|| vehicle_changes_rec.effective_start_date);
            hr_utility.trace(l_proc||': fuel_type='|| vehicle_changes_rec.fuel_type);
            --
            IF (vehicle_changes_rec.effective_start_date
                   BETWEEN alc_dates_rec.min_start_date+1 AND alc_dates_rec.max_end_date) AND
               (vehicle_changes_rec.effective_start_date
                   BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
               --
               -- Check if this fuel change has been
               -- already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          vehicle_changes_rec.effective_start_date,
                          'F');
               --
               hr_utility.set_location(l_proc, 120);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
                  --
               END IF;
            END IF;
         END LOOP;
         --
         hr_utility.set_location(l_proc, 130);
         --
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         ----------------------------------------------------
         -- If tax ref has changed within the given date   --
         -- range then check whether it should be reported --
         -- as a new allocation or withdrawal              --
         ----------------------------------------------------
         IF (asg_rec.asg_min_start_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
               AND (asg_rec.asg_min_start_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has started on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- start date therefore check whether it is a transfer
            -- from another tax ref
            hr_utility.set_location(l_proc, 160);
            l_previous_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_min_start_date-1);
            FETCH c_tax_ref INTO l_previous_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 170);
            hr_utility.trace(l_proc||', l_previous_tax_ref='||l_previous_tax_ref);
            --
            IF l_previous_tax_ref is NOT NULL AND l_previous_tax_ref <> g_tax_ref THEN
               -- This assignment has a different prior tax ref
               -- therefore it should be reported as a new car
               -- allocation on this EDI message.
               hr_utility.set_location(l_proc, 180);
               l_action_flag := 'N';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_min_start_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 190);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
               --
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         IF (asg_rec.asg_max_end_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
            AND (asg_rec.asg_max_end_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has ended on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- end date therefore check whether it is a transfer
            -- to another tax ref
            hr_utility.set_location(l_proc, 200);
            l_next_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_max_end_date+1);
            FETCH c_tax_ref INTO l_next_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 210);
            hr_utility.trace(l_proc||', l_next_tax_ref='||l_next_tax_ref);
            --
            IF l_next_tax_ref is NOT NULL AND l_next_tax_ref <> g_tax_ref THEN
               -- This assignment has a different tax ref after end date
               -- therefore it should be reported as allocation withdrawal
               -- on this EDI message.
               hr_utility.set_location(l_proc, 220);
               l_action_flag := 'W';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_max_end_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 230);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
               --
            END IF;
         END IF;
         --
         hr_utility.set_location(l_proc, 240);
         --
         hr_utility.set_location(l_proc, 250);
      END LOOP;
      --
      hr_utility.set_location(l_proc, 260);
      --
      -- If flag is set then create action
      IF l_create_assact_flag = 'Y' THEN
         --
         SELECT pay_assignment_actions_s.nextval
         INTO l_actid
         FROM dual;

         hr_utility.set_location(l_proc, 270);
         hr_utility.trace(l_proc||': l_actid='||l_actid);
         hr_utility.trace(l_proc||': asg_rec.assignment_id='||asg_rec.assignment_id);
         hr_utility.trace(l_proc||': pactid='||pactid);
         hr_utility.trace(l_proc||': chunk='||chunk);
         --
         hr_nonrun_asact.insact(l_actid,
                                asg_rec.assignment_id,
                                pactid,
                                chunk, NULL);
         --
         hr_utility.set_location(l_proc, 280);
         --
      END IF;
   END LOOP;
   --
   hr_utility.set_location('Leaving: '||l_proc,290);
   -- hr_utility.trace_off;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving: '||l_proc,300);
--    hr_utility.trace_off;
    raise;
END Create_asg_act_v2;


--For Bug 8986543
-----------------------------------------------------
--         PROCEDURE CREATE_ASG_ACT_V3                --
-----------------------------------------------------
PROCEDURE create_asg_act_v3(pactid IN NUMBER,
                            stperson IN NUMBER,
                            endperson IN NUMBER,
                            chunk IN NUMBER) IS
   --
   l_proc          CONSTANT VARCHAR2(100):= g_package||'create_asg_act_v3';
   l_actid         pay_assignment_actions.assignment_action_id%TYPE;
   l_ovn           pay_action_information.object_version_number%TYPE;
   --
   --
   CURSOR c_param_values IS
   SELECT to_number( pay_gb_eoy_archive.get_parameter(
                          legislative_parameters,
                          'PAYROLL_ID')) payroll_id,
          substr( pay_gb_eoy_archive.get_parameter(
                          legislative_parameters,
                          'TAX_REF'),1,20) tax_ref,
          start_date,
          effective_date,
          fnd_date.canonical_to_date(
             pay_gb_eoy_archive.get_parameter(
                          legislative_parameters,
                              'END_DATE'))  end_date,
          business_group_id
   FROM  pay_payroll_actions
   WHERE payroll_action_id = pactid;
   --
   CURSOR c_asg IS
   SELECT /* USE_INDEX(va,PQP_VEHICLE_ALLOCATIONS_F_N1)
          */
          asg.assignment_id,
          min(asg.effective_start_date) asg_min_start_date,
          max(asg.effective_end_date) asg_max_end_date
   FROM   hr_soft_coding_keyflex flex,
          per_all_assignments_f asg,
          pay_payrolls_f ppf,
          pqp_vehicle_allocations_f va,
          pqp_vehicle_repository_f vr
   WHERE  asg.person_id BETWEEN stperson AND endperson
   AND    asg.business_group_id = g_business_group_id
   AND    asg.payroll_id = nvl(g_payroll_id,asg.payroll_id)
   AND    asg.payroll_id = ppf.payroll_id
   AND    ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = g_tax_ref
   AND    (   g_start_date BETWEEN asg.effective_start_date AND asg.effective_end_date
           OR g_end_date   BETWEEN asg.effective_start_date AND asg.effective_end_date
           OR (    asg.effective_start_date BETWEEN g_start_date AND g_end_Date
               AND asg.effective_end_date  BETWEEN g_start_date AND g_end_Date))
   AND    va.assignment_id = asg.assignment_id
   AND    va.business_group_id = g_business_group_id
   AND    ( (   va.effective_start_date BETWEEN g_start_date AND g_end_date
             OR va.effective_end_date BETWEEN g_start_date AND g_end_date)
             OR (    g_start_date BETWEEN va.effective_start_date AND va.effective_end_date
                 AND g_end_date BETWEEN va.effective_start_date AND va.effective_end_date) )
   AND    vr.vehicle_repository_id = va.vehicle_repository_id
   AND    vr.vehicle_ownership = 'C'
   AND    vr.vehicle_type = 'C'
   AND    va.effective_start_date BETWEEN vr.effective_start_date AND vr.effective_end_date
   GROUP by asg.assignment_id;
   --
   l_create_assact_flag VARCHAR2(1);
   l_action_flag VARCHAR2(1);
   l_archived_flag VARCHAR2(1);
BEGIN
   --hr_utility.trace_on(null, 'KTHAMPAN');
   hr_utility.set_location('Entering '||l_proc, 10);
   --
   OPEN c_param_values;
   FETCH c_param_values INTO g_payroll_id,
                             g_tax_ref,
                             g_start_date,
                             g_effective_date,
                             g_end_date,
                             g_business_group_id;
   CLOSE c_param_values;
   --
   hr_utility.set_location(l_proc, 15);
   hr_utility.trace(l_proc||': g_payroll_id='||g_payroll_id);
   hr_utility.trace(l_proc||': g_tax_ref='||g_tax_ref);
   hr_utility.trace(l_proc||': g_start_date='||fnd_date.date_to_displaydate(g_start_date));
   hr_utility.trace(l_proc||': g_effective_date='||fnd_date.date_to_displaydate(g_effective_date));
   hr_utility.trace(l_proc||': g_end_date='||fnd_date.date_to_displaydate(g_end_date));
   hr_utility.trace(l_proc||': g_business_group_id='||g_business_group_id);
   For asg_rec IN c_asg
   LOOP
      -- Loop through all assignments
      hr_utility.set_location(l_proc, 20);
      hr_utility.trace(l_proc||': assignment_id='||asg_rec.assignment_id);
      hr_utility.trace(l_proc||': asg_min_start_date='||fnd_date.date_to_displaydate(asg_rec.asg_min_start_date));
      hr_utility.trace(l_proc||': asg_max_end_date='||fnd_date.date_to_displaydate(asg_rec.asg_max_end_date));
      --
      l_create_assact_flag := 'N';
      --
      FOR alc_rec IN c_allocations(asg_rec.assignment_id) LOOP
         -- Loop through all vehicle allocations
         -- over the date range
         hr_utility.set_location(l_proc, 30);
         hr_utility.trace(l_proc||': vehicle_allocation_id='||alc_rec.vehicle_allocation_id);
         hr_utility.trace(l_proc||': usage_type='||alc_rec.usage_type);
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         OPEN c_alloc_dates(alc_rec.vehicle_allocation_id);
         FETCH c_alloc_dates INTO alc_dates_rec;
         CLOSE c_alloc_dates;
         --
         hr_utility.set_location(l_proc, 40);
         hr_utility.trace(l_proc||': min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
         hr_utility.trace(l_proc||': max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
         --
         -- Check whether vehicle was allocated or
         -- Withdrawn within the date range also
         -- check that this allocation or withdrawal
         -- happened when assignment was with input tax ref
         IF (alc_dates_rec.min_start_date BETWEEN g_start_date AND g_end_Date) AND
            (alc_dates_rec.min_start_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            -- This is a New Car or replacement action
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  -- This is the first car allocation
                  -- of this employee in this tax ref
                  -- therefore check if it has replaced
                  -- any prior car
                  OPEN c_prior_prim_car(asg_rec.assignment_id, Alc_dates_rec.min_start_date);
                  FETCH c_prior_prim_car INTO prior_prim_car_rec;
                  IF c_prior_prim_car%FOUND THEN
                     L_action_flag := 'R';
                  ELSE
                     L_action_flag := 'N';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_prior_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as new car
                  L_action_flag := 'N';
               END IF;
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a primary car therefore mark
               -- it as new car allocation action
               l_action_flag := 'N';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action

                  --Assignment action not required for
                  --replaced car as per new requirements of V3
                  IF L_action_flag <> 'R'
                  THEN
                       l_create_assact_flag := 'Y';
                  END IF;

               END IF;
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         --
         IF (alc_dates_rec.max_end_date BETWEEN g_start_date AND g_end_Date) AND
               (alc_dates_rec.max_end_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  --
                  OPEN c_next_prim_car(asg_rec.assignment_id, Alc_dates_rec.max_end_date);
                  FETCH c_next_prim_car INTO next_prim_car_rec;
                  IF c_next_prim_car%FOUND THEN
                     -- There is a replacement action to
                     -- Report this car therefore
                     -- No need to archive this action
                     NULL;
                  ELSE
                     -- This is a withdrawal action
                     L_action_flag := 'W';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_next_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as withdrawal car
                  L_action_flag := 'W';
               END IF;
               --
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a Primary car therefore mark
               -- it as withdrawal car action
               l_action_flag := 'W';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
            END IF;
         END IF;
         -- Check if fuel type has changed within
         -- the date range.
         FOR vehicle_changes_rec IN c_vehicle_changes(alc_rec.vehicle_repository_id) LOOP
            -- Fuel type has changed therefore make sure
            -- this change occured after the vehicle was
            -- allocated to this assignment
            --
            hr_utility.set_location(l_proc, 110);
            hr_utility.trace(l_proc||': effective_start_date='|| vehicle_changes_rec.effective_start_date);
            hr_utility.trace(l_proc||': fuel_type='|| vehicle_changes_rec.fuel_type);
            --
            IF (vehicle_changes_rec.effective_start_date
                   BETWEEN alc_dates_rec.min_start_date+1 AND alc_dates_rec.max_end_date) AND
               (vehicle_changes_rec.effective_start_date
                   BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
               --
               -- Check if this fuel change has been
               -- already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          vehicle_changes_rec.effective_start_date,
                          'F');
               --
               hr_utility.set_location(l_proc, 120);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
                  --
               END IF;
            END IF;
         END LOOP;
         --
         hr_utility.set_location(l_proc, 130);
         --
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         ----------------------------------------------------
         -- If tax ref has changed within the given date   --
         -- range then check whether it should be reported --
         -- as a new allocation or withdrawal              --
         ----------------------------------------------------
         IF (asg_rec.asg_min_start_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
               AND (asg_rec.asg_min_start_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has started on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- start date therefore check whether it is a transfer
            -- from another tax ref
            hr_utility.set_location(l_proc, 160);
            l_previous_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_min_start_date-1);
            FETCH c_tax_ref INTO l_previous_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 170);
            hr_utility.trace(l_proc||', l_previous_tax_ref='||l_previous_tax_ref);
            --
            IF l_previous_tax_ref is NOT NULL AND l_previous_tax_ref <> g_tax_ref THEN
               -- This assignment has a different prior tax ref
               -- therefore it should be reported as a new car
               -- allocation on this EDI message.
               hr_utility.set_location(l_proc, 180);
               l_action_flag := 'N';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_min_start_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 190);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
               --
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         IF (asg_rec.asg_max_end_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
            AND (asg_rec.asg_max_end_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has ended on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- end date therefore check whether it is a transfer
            -- to another tax ref
            hr_utility.set_location(l_proc, 200);
            l_next_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_max_end_date+1);
            FETCH c_tax_ref INTO l_next_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 210);
            hr_utility.trace(l_proc||', l_next_tax_ref='||l_next_tax_ref);
            --
            IF l_next_tax_ref is NOT NULL AND l_next_tax_ref <> g_tax_ref THEN
               -- This assignment has a different tax ref after end date
               -- therefore it should be reported as allocation withdrawal
               -- on this EDI message.
               hr_utility.set_location(l_proc, 220);
               l_action_flag := 'W';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_max_end_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 230);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore create assignment action
                  l_create_assact_flag := 'Y';
               END IF;
               --
            END IF;
         END IF;
         --
         hr_utility.set_location(l_proc, 240);
         --
         hr_utility.set_location(l_proc, 250);
      END LOOP;
      --
      hr_utility.set_location(l_proc, 260);
      --
      -- If flag is set then create action
      IF l_create_assact_flag = 'Y' THEN
         --
         SELECT pay_assignment_actions_s.nextval
         INTO l_actid
         FROM dual;

         hr_utility.set_location(l_proc, 270);
         hr_utility.trace(l_proc||': l_actid='||l_actid);
         hr_utility.trace(l_proc||': asg_rec.assignment_id='||asg_rec.assignment_id);
         hr_utility.trace(l_proc||': pactid='||pactid);
         hr_utility.trace(l_proc||': chunk='||chunk);
         --
         hr_nonrun_asact.insact(l_actid,
                                asg_rec.assignment_id,
                                pactid,
                                chunk, NULL);
         --
         hr_utility.set_location(l_proc, 280);
         --
      END IF;
   END LOOP;
   --
   hr_utility.set_location('Leaving: '||l_proc,290);
   -- hr_utility.trace_off;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving: '||l_proc,300);
--    hr_utility.trace_off;
    raise;
END Create_asg_act_v3;


-----------------------------------------------------
--     PROCEDURE ARCHIVE_ALLOCATION_ACTION         --
-----------------------------------------------------
PROCEDURE archive_allocation_action(
            p_assignment_id IN NUMBER,
            p_asg_act_id IN NUMBER,
            p_vehicle_allocation_id IN NUMBER,
            p_vehicle_repository_id IN NUMBER,
            p_action_flag IN VARCHAR2,
            p_fuel_type_change_date IN DATE DEFAULT NULL,
            p_allocation_start_date IN DATE,
            p_allocation_end_date IN DATE) IS
--
l_eff_date DATE;
l_tax_year_start DATE;
l_date_first_avail PAY_ACTION_INFORMATION.ACTION_INFORMATION14%TYPE;
l_second_car_flag PAY_ACTION_INFORMATION.ACTION_INFORMATION15%TYPE;
--
CURSOR c_person(p_assignment_id IN NUMBER) IS
SELECT p.last_name
     , p.title
     , p.first_name
     , p.middle_names
     , p.person_id
     , p.national_identifier
     , p.date_of_birth   --For Bug 6652235
	 , p.sex             --For Bug 6652235
FROM per_people_f p, per_assignments_f a
WHERE a.assignment_id = p_assignment_id
AND   l_eff_date between
                   a.effective_start_date and a.effective_end_date
AND   a.person_id = p.person_id
AND   l_eff_date between
                   p.effective_start_date and p.effective_end_date;
--
person_rec c_person%ROWTYPE;
--
CURSOR c_addr(p_person_id IN NUMBER) IS
SELECT addr.address_line1,
       addr.address_line2,
       addr.address_line3,
       addr.town_or_city,
       substr(hr_general.decode_lookup('GB_COUNTY',
         addr.region_1), 1, 35) region_1,
       addr.country,
       addr.postal_code
 FROM  per_addresses addr
 WHERE addr.person_id = p_person_id
 AND   addr.primary_flag = 'Y'
 AND   l_eff_date  BETWEEN addr.date_from
                   AND  nvl(addr.date_to, fnd_date.canonical_to_date('4712/12/31'));
--
addr_rec c_addr%ROWTYPE;
--
CURSOR c_alloc IS
SELECT capital_contribution,
       private_contribution,
       fuel_benefit
FROM   pqp_vehicle_allocations_f
WHERE  vehicle_allocation_id = p_vehicle_allocation_id
AND    l_eff_date  between effective_start_date
       and effective_end_Date;
--
alloc_rec c_alloc%ROWTYPE;
--
CURSOR c_car IS
SELECT registration_number,
       vehicle_type,
       vehicle_id_number,
       make,
       model,
       initial_registration,
       last_registration_renew_date,
       engine_capacity_in_cc,
       h1.description fuel_type,
       currency_code,
       list_price ,
       accessory_value_at_startdate,
       accessory_value_added_later,
       market_value_classic_car,
       fiscal_ratings,
       fiscal_ratings_uom,
       shared_vehicle,
       vehicle_status,
       taxation_method
FROM pqp_vehicle_repository_f,
     hr_lookups h1
WHERE vehicle_repository_id = p_vehicle_repository_id
AND   l_eff_date BETWEEN effective_start_date AND effective_end_Date
AND   fuel_type = h1.lookup_code
AND   h1.lookup_type = 'PQP_FUEL_TYPE'
AND   h1.enabled_flag = 'Y'
AND   trunc(sysdate) BETWEEN trunc(nvl(h1.start_date_active, sysdate-1)) AND trunc(nvl(h1.end_date_active,sysdate+1));
--
car_rec c_car%ROWTYPE;
--
l_action_info_id PAY_ACTION_INFORMATION.ACTION_INFORMATION_ID%TYPE;
l_ovn PAY_ACTION_INFORMATION.OBJECT_VERSION_NUMBER%TYPE;
l_proc          CONSTANT VARCHAR2(50):= g_package||'archive_allocation_action';
--
BEGIN
   hr_utility.set_location('Entering '||l_proc, 10);
   hr_utility.trace('p_assignment_id='||p_assignment_id);
   hr_utility.trace('p_asg_act_id='||p_asg_act_id);
   hr_utility.trace('p_vehicle_allocation_id='||p_vehicle_allocation_id);
   hr_utility.trace('p_vehicle_repository_id='||p_vehicle_repository_id);
   hr_utility.trace('p_action_flag='||p_action_flag);
   hr_utility.trace('p_fuel_type_change_date='||fnd_date.date_to_displaydate(p_fuel_type_change_date));
   hr_utility.trace('p_allocation_start_date='||fnd_date.date_to_displaydate(p_allocation_start_date));
   hr_utility.trace('p_allocation_end_date='||fnd_date.date_to_displaydate(p_allocation_end_date));
   -- Get data as of the action date within
   -- the date range, effective date is:
   IF p_action_flag = 'F' THEN
      -- Get data as of the fuel type change date
      l_eff_date := p_fuel_type_Change_date;
   ELSIF p_action_flag in ('N', 'R') THEN
      l_eff_date := p_allocation_start_date;
   ELSIF p_action_flag = 'W' THEN
      l_eff_date := p_allocation_end_date;
   END IF;
   hr_utility.set_location(l_proc, 20);
   hr_utility.trace('l_eff_date='||fnd_date.date_to_displaydate(l_eff_date));
   --
   -- Get person details
   OPEN c_person(p_assignment_id);
   FETCH c_person INTO person_rec;
   CLOSE c_person;
   --
   hr_utility.set_location(l_proc, 30);
   -- Get Address Details
   OPEN c_addr(person_rec.person_id);
   FETCH c_addr INTO addr_rec;
   CLOSE c_addr;
   --
   hr_utility.set_location(l_proc, 40);
   -- Get Allocation details
   OPEN c_alloc;
   FETCH c_alloc INTO alloc_rec;
   CLOSE c_alloc;
   --
   hr_utility.set_location(l_proc, 50);
   -- Get Car details
   OPEN c_car;
   FETCH c_car INTO car_rec;
   CLOSE c_car;
   --
   hr_utility.set_location(l_proc, 60);
   ---------------------------------------------
   -- Archive Person and Address details      --
   ---------------------------------------------
    hr_utility.trace('Person ID : ' || person_rec.person_id);
    hr_utility.trace('Last Name : ' || person_rec.last_name);
    hr_utility.trace('First Nme : ' || person_rec.first_name);
    hr_utility.trace('Title     : ' || person_rec.title);
    hr_utility.trace('NINO      : ' || person_rec.national_identifier);
    hr_utility.trace('ADDR1     : ' || addr_rec.address_line1);
    hr_utility.trace('ADDR1     : ' || addr_rec.address_line2);
    hr_utility.trace('ADDR1     : ' || addr_rec.address_line3);
    hr_utility.trace('City/Town : ' || addr_rec.town_or_city);
    hr_utility.trace('Regioin_1 : ' || addr_rec.region_1);
    hr_utility.trace('Postal    : ' || addr_rec.postal_code);
    hr_utility.trace('DOB       : ' || fnd_date.date_to_canonical(person_rec.date_of_birth)); --For Bug 6652235
    hr_utility.trace('Gender    : ' || person_rec.sex); --For Bug 6652235

    pay_action_information_api.create_action_information (
    p_action_information_id        =>  l_action_info_id
  , p_action_context_id            =>  p_asg_act_id
  , p_action_context_type          =>  'AAP'
  , p_object_version_number        =>  l_ovn
  , p_assignment_id                =>  p_assignment_id
  , p_effective_date               =>  g_effective_date
  , p_source_id                    =>  NULL
  , p_source_text                  =>  NULL
  , p_action_information_category  =>  'GB P46 CAR EDI EMPLOYEE DETAIL'
  , p_action_information1          =>  person_rec.person_id
  , p_action_information2          =>  upper(person_rec.last_name)
  , p_action_information3          =>  upper(person_rec.first_name)
  , p_action_information4          =>  upper(person_rec.title)
  , p_action_information5          =>  nvl(person_rec.national_identifier, 'NONE')
  , p_action_information6          =>  upper(addr_rec.address_line1)
  , p_action_information7          =>  upper(addr_rec.address_line2)
  , p_action_information8          =>  upper(addr_rec.address_line3)
  , p_action_information9          =>  upper(addr_rec.town_or_city)
  , p_action_information10         =>  upper(addr_rec.region_1)
  , p_action_information11         =>  upper(addr_rec.postal_code)
  , p_action_information12         =>  fnd_date.date_to_canonical(person_rec.date_of_birth)  --For Bug 6652235
  , p_action_information13         =>  upper(person_rec.sex));   --For Bug 6652235
   --
   hr_utility.set_location(l_proc, 70);
   ---------------------------------------------
   -- Archive Vehicle Allocation Details      --
   ---------------------------------------------
   IF g_effective_date <
      fnd_date.canonical_to_date(
          to_char(g_effective_date, 'YYYY')||'04/06') THEN
      -- Effective Date between 1st Jan
      -- to 5th Apr of the calendar year
      l_tax_year_start := fnd_date.canonical_to_date(
                       to_char(to_number(to_char(g_effective_date, 'YYYY')) -1)
                       ||'04/06');
   ELSE
      -- Effective Date between 06th Apr
      -- to 31st Dec of the calendar year
      l_tax_year_start := fnd_date.canonical_to_date(
                       to_char(g_effective_date, 'YYYY')||'04/06');
   END IF;
   --
   hr_utility.set_location(l_proc, 80);
   --
   IF p_allocation_start_date >= l_tax_year_start THEN
      -- Car was first allocated in this tax year
      -- Archive Date Car First Available
      l_date_first_avail := fnd_date.date_to_canonical(p_allocation_start_date);
   ELSE
      l_date_first_avail := NULL;
   END IF;
   --
   hr_utility.set_location(l_proc, 90);
   hr_utility.trace('l_date_first_avail='||l_date_first_avail);
   --
   ---------------------------------------------
   -- Check whether it's the primary car of   --
   -- the employee                            --
   ---------------------------------------------
   -- Get first assignment of this person
   -- in the tax_ref
   OPEN c_first_asg(p_assignment_id, l_eff_date);
   FETCH c_first_asg INTO first_asg_rec;
   CLOSE c_first_asg;
   --
   hr_utility.set_location(l_proc, 100);
   --
   -- Get primary car allocation of the
   -- first assignment of this person
   -- in this tax ref
   OPEN c_primary_car(first_asg_rec.assignment_id, l_eff_date);
   FETCH c_primary_car INTO primary_car_rec;
   CLOSE c_primary_car;
   --
   hr_utility.set_location(l_proc, 110);
   --
   IF primary_car_rec.vehicle_allocation_id
       = p_vehicle_allocation_id THEN
      -- This is the primary car allocation
      -- of this employee in this tax ref
      l_second_car_flag := 'N';
   ELSE
      -- This is not primary car allocation
      -- therefore mark it as a second car.
      l_second_car_flag := 'Y';
   END IF;
   --
   hr_utility.set_location(l_proc, 120);
   hr_utility.trace('l_second_car_flag='||l_second_car_flag);
   --
   IF p_action_flag = 'N' THEN
     hr_utility.set_location(l_proc, 130);
     --
     pay_action_information_api.create_action_information (
       p_action_information_id        =>  l_action_info_id
     , p_action_context_id            =>  p_asg_act_id
     , p_action_context_type          =>  'AAP'
     , p_object_version_number        =>  l_ovn
     , p_assignment_id                =>  p_assignment_id
     , p_effective_date               =>  g_effective_date
     , p_source_id                    =>  NULL
     , p_source_text                  =>  NULL
     , p_action_information_category  =>  'GB P46 CAR EDI ALLOCATION'
     , p_action_information1          =>  p_action_flag
     , p_action_information2          =>  p_vehicle_allocation_id
     , p_action_information3          =>  fnd_date.date_to_canonical(p_allocation_start_date)
     , p_action_information4          =>  fnd_date.date_to_canonical(p_allocation_end_date)
     , p_action_information5          =>  p_vehicle_repository_id
     , p_action_information6          =>  to_char(nvl(car_rec.list_price,0)*100)
     , p_action_information7          =>  to_char(nvl(car_rec.accessory_value_at_startdate,0)*100)
     , p_action_information8          =>  to_char(nvl(alloc_rec.capital_contribution,0)*100)
     , p_action_information9          =>  to_char(nvl(alloc_rec.private_contribution,0)*100)
     , p_action_information10          =>  car_rec.fuel_type
     , p_action_information11          =>  car_rec.fiscal_ratings
     , p_action_information12         =>  alloc_rec.fuel_benefit
     , p_action_information13         =>  fnd_date.date_to_canonical(car_rec.initial_registration)
     , p_action_information14         =>  l_date_first_avail
     , p_action_information15         =>  l_second_car_flag
     , p_action_information16         =>  upper(car_rec.make || ' ' || car_rec.model)
     , p_action_information17         =>  to_char(car_rec.engine_capacity_in_cc));
     --
     hr_utility.set_location(l_proc, 140);
   ELSIF p_action_flag = 'R' THEN
     hr_utility.set_location(l_proc, 150);
     --
     pay_action_information_api.create_action_information (
       p_action_information_id        =>  l_action_info_id
     , p_action_context_id            =>  p_asg_act_id
     , p_action_context_type          =>  'AAP'
     , p_object_version_number        =>  l_ovn
     , p_assignment_id                =>  p_assignment_id
     , p_effective_date               =>  g_effective_date
     , p_source_id                    =>  NULL
     , p_source_text                  =>  NULL
     , p_action_information_category  =>  'GB P46 CAR EDI ALLOCATION'
     , p_action_information1          =>  p_action_flag
     , p_action_information2          =>  p_vehicle_allocation_id
     , p_action_information3          =>  fnd_date.date_to_canonical(p_allocation_start_date)
     , p_action_information4          =>  fnd_date.date_to_canonical(p_allocation_end_date)
     , p_action_information5          =>  p_vehicle_repository_id
     , p_action_information6          =>  to_char(nvl(car_rec.list_price,0)*100)
     , p_action_information7          =>  to_char(nvl(car_rec.accessory_value_at_startdate,0)*100)
     , p_action_information8          =>  to_char(nvl(alloc_rec.capital_contribution,0)*100)
     , p_action_information9          =>  to_char(nvl(alloc_rec.private_contribution,0)*100)
     , p_action_information10          =>  car_rec.fuel_type
     , p_action_information11          =>  car_rec.fiscal_ratings
     , p_action_information12         =>  alloc_rec.fuel_benefit
     , p_action_information13         =>  fnd_date.date_to_canonical(car_rec.initial_registration)
     , p_action_information14         =>  l_date_first_avail
     , p_action_information15         =>  l_second_car_flag
     , p_action_information16         =>  upper(car_rec.make || ' ' || car_rec.model)
     , p_action_information17         =>  to_char(car_rec.engine_capacity_in_cc)
     , p_action_information18         =>  upper(ltrim(rtrim(prior_prim_car_rec.make)) || ' ' || ltrim(rtrim(prior_prim_car_rec.model)))
     , p_action_information19         =>  to_char(prior_prim_car_rec.engine_capacity_in_cc)
     , p_action_information20         =>  to_char(prior_prim_car_rec.vehicle_allocation_id)
     , p_action_information21         =>  fnd_date.date_to_canonical(prior_prim_car_rec.effective_end_date)
     );
     --
     hr_utility.set_location(l_proc, 160);
   ELSIF p_action_flag = 'W' THEN
     hr_utility.set_location(l_proc, 170);
     --
     pay_action_information_api.create_action_information (
       p_action_information_id        =>  l_action_info_id
     , p_action_context_id            =>  p_asg_act_id
     , p_action_context_type          =>  'AAP'
     , p_object_version_number        =>  l_ovn
     , p_assignment_id                =>  p_assignment_id
     , p_effective_date               =>  g_effective_date
     , p_source_id                    =>  NULL
     , p_source_text                  =>  NULL
     , p_action_information_category  =>  'GB P46 CAR EDI ALLOCATION'
     , p_action_information1          =>  p_action_flag
     , p_action_information2          =>  p_vehicle_allocation_id
     , p_action_information3          =>  fnd_date.date_to_canonical(p_allocation_start_date)
     , p_action_information4          =>  fnd_date.date_to_canonical(p_allocation_end_date)
     , p_action_information5          =>  p_vehicle_repository_id
     , p_action_information6          =>  to_char(nvl(car_rec.list_price,0)*100)
     , p_action_information7          =>  to_char(nvl(car_rec.accessory_value_at_startdate,0)*100)
     , p_action_information8          =>  to_char(nvl(alloc_rec.capital_contribution,0)*100)
     , p_action_information9          =>  to_char(nvl(alloc_rec.private_contribution,0)*100)
     , p_action_information10          =>  car_rec.fuel_type
     , p_action_information11          =>  car_rec.fiscal_ratings
     , p_action_information12         =>  alloc_rec.fuel_benefit
     , p_action_information13         =>  fnd_date.date_to_canonical(car_rec.initial_registration)
     , p_action_information14         =>  NULL
     , p_action_information15         =>  NULL
     , p_action_information16         =>  upper(car_rec.make || ' ' || car_rec.model)
     , p_action_information17         =>  to_char(car_rec.engine_capacity_in_cc)
     );
     --
     hr_utility.set_location(l_proc, 180);
   ELSIF p_action_flag = 'F' THEN
     hr_utility.set_location(l_proc, 190);
     --
     pay_action_information_api.create_action_information (
       p_action_information_id        =>  l_action_info_id
     , p_action_context_id            =>  p_asg_act_id
     , p_action_context_type          =>  'AAP'
     , p_object_version_number        =>  l_ovn
     , p_assignment_id                =>  p_assignment_id
     , p_effective_date               =>  g_effective_date
     , p_source_id                    =>  NULL
     , p_source_text                  =>  NULL
     , p_action_information_category  =>  'GB P46 CAR EDI ALLOCATION'
     , p_action_information1          =>  p_action_flag
     , p_action_information2          =>  p_vehicle_allocation_id
     , p_action_information3          =>  fnd_date.date_to_canonical(p_fuel_type_change_Date)
     , p_action_information4          =>  fnd_date.date_to_canonical(p_allocation_end_date)
     , p_action_information5          =>  p_vehicle_repository_id
     , p_action_information6          =>  to_char(nvl(car_rec.list_price,0)*100)
     , p_action_information7          =>  to_char(nvl(car_rec.accessory_value_at_startdate,0)*100)
     , p_action_information8          =>  to_char(nvl(alloc_rec.capital_contribution,0)*100)
     , p_action_information9          =>  to_char(nvl(alloc_rec.private_contribution,0)*100)
     , p_action_information10          =>  car_rec.fuel_type
     , p_action_information11          =>  car_rec.fiscal_ratings
     , p_action_information12         =>  alloc_rec.fuel_benefit
     , p_action_information13         =>  fnd_date.date_to_canonical(car_rec.initial_registration)
     , p_action_information14         =>  l_date_first_avail
     , p_action_information15         =>  l_second_car_flag
     , p_action_information16         =>  upper(car_rec.make || ' ' || car_rec.model)
     , p_action_information17         =>  to_char(car_rec.engine_capacity_in_cc)
     , p_action_information18         =>  upper(car_rec.make || ' ' || car_rec.model)
     , p_action_information19         =>  to_char(car_rec.engine_capacity_in_cc)
     , p_action_information20         =>  to_char(p_vehicle_allocation_id)
     , p_action_information21         =>  fnd_date.date_to_canonical(p_fuel_type_change_date-1)
     );
     --
     hr_utility.set_location(l_proc, 200);
   END IF;
   --
   hr_utility.set_location('Leaving '||l_proc, 300);
END archive_allocation_action;

-----------------------------------------------------
--         PROCEDURE ARCHIVE_CODE                  --
-----------------------------------------------------
PROCEDURE archive_code(p_assactid IN NUMBER,
                            p_effective_date IN DATE) IS
   --
   l_proc          CONSTANT VARCHAR2(35):= g_package||'archive_code';
   --
   --
   CURSOR c_asg IS
   SELECT asg.assignment_id,
          min(asg.effective_start_date) asg_min_start_date,
          max(asg.effective_end_date) asg_max_end_date
   FROM   hr_soft_coding_keyflex flex,
          per_all_assignments_f asg,
          Pay_payrolls_f ppf,
          pay_assignment_actions act
   WHERE  act.assignment_action_id = p_assactid
   AND    act.assignment_id = asg.assignment_id
   AND    asg.payroll_id +0 = nvl(g_payroll_id,asg.payroll_id)
   AND    asg.payroll_id = ppf.payroll_id
   AND    ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = g_tax_ref
   AND   ( g_start_date BETWEEN asg.effective_start_date AND asg.effective_end_date
         OR g_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date
         OR (asg.effective_start_date BETWEEN g_start_date AND g_end_Date
             AND asg.effective_end_date BETWEEN g_start_date AND g_end_Date))
   GROUP by asg.assignment_id;
   --
   l_action_flag   VARCHAR2(1);
   l_archived_flag VARCHAR2(1);
   --
BEGIN
   --hr_utility.trace_on(null, 'KTHAMPAN');
   hr_utility.set_location('Entering '||l_proc, 10);
   --
   For asg_rec IN c_asg
   LOOP
      -- Loop through all assignments
      hr_utility.set_location(l_proc, 20);
      hr_utility.trace(l_proc||': assignment_id='||asg_rec.assignment_id);
      hr_utility.trace(l_proc||': asg_min_start_date='||fnd_date.date_to_displaydate(asg_rec.asg_min_start_date));
      hr_utility.trace(l_proc||': asg_max_end_date='||fnd_date.date_to_displaydate(asg_rec.asg_max_end_date));
      --
      FOR alc_rec IN c_allocations(asg_rec.assignment_id) LOOP
         -- Loop through all vehicle allocations
         -- over the date range
         hr_utility.set_location(l_proc, 30);
         hr_utility.trace(l_proc||': vehicle_allocation_id='||alc_rec.vehicle_allocation_id);
         hr_utility.trace(l_proc||': usage_type='||alc_rec.usage_type);
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         OPEN c_alloc_dates(alc_rec.vehicle_allocation_id);
         FETCH c_alloc_dates INTO alc_dates_rec;
         CLOSE c_alloc_dates;
         --
         hr_utility.set_location(l_proc, 40);
         hr_utility.trace(l_proc||': min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
         hr_utility.trace(l_proc||': max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
         --
         -- Check whether vehicle was allocated or
         -- Withdrawn within the date range also
         -- check that this allocation or withdrawal
         -- happened when assignment was with input tax ref
         IF (alc_dates_rec.min_start_date BETWEEN g_start_date AND g_end_Date) AND
            (alc_dates_rec.min_start_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            -- This is a New Car or replacement action
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  -- This is the first car allocation
                  -- of this employee in this tax ref
                  -- therefore check if it has replaced
                  -- any prior car
                  OPEN c_prior_prim_car(asg_rec.assignment_id, Alc_dates_rec.min_start_date);
                  FETCH c_prior_prim_car INTO prior_prim_car_rec;
                  IF c_prior_prim_car%FOUND THEN
                     L_action_flag := 'R';
                  ELSE
                     L_action_flag := 'N';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_prior_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as new car
                  L_action_flag := 'N';
               END IF;
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a primary car therefore mark
               -- it as new car allocation action
               l_action_flag := 'N';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  hr_utility.set_location(l_proc, 105);
                  hr_utility.trace(l_proc||': p_assactid='|| p_assactid);
                  hr_utility.trace(l_proc||': vehicle_allocation_id='|| alc_rec.vehicle_allocation_id);
                  hr_utility.trace(l_proc||': vehicle_repository_id='|| alc_rec.vehicle_repository_id);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  hr_utility.trace(l_proc||': alc_dates_rec.min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
                  hr_utility.trace(l_proc||': alc_dates_rec.max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
                  --
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                            p_asg_act_id => p_assactid,
                                            p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                            p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                            p_action_flag => l_action_flag,
                                            p_allocation_start_date => alc_dates_rec.min_start_date,
                                            p_allocation_end_date => alc_dates_rec.max_end_date);
               END IF;
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         IF (alc_dates_rec.max_end_date BETWEEN g_start_date AND g_end_Date) AND
               (alc_dates_rec.max_end_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  --
                  OPEN c_next_prim_car(asg_rec.assignment_id, Alc_dates_rec.max_end_date);
                  FETCH c_next_prim_car INTO next_prim_car_rec;
                  IF c_next_prim_car%FOUND THEN
                     -- There is a replacement action to
                     -- Report this car therefore
                     -- No need to archive this action
                     NULL;
                  ELSE
                     -- This is a withdrawal action
                     L_action_flag := 'W';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_next_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as withdrawal car
                  L_action_flag := 'W';
               END IF;
               --
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a first car therefore mark
               -- it as withdrawal car action
               l_action_flag := 'W';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  hr_utility.set_location(l_proc, 105);
                  hr_utility.trace(l_proc||': p_assactid='|| p_assactid);
                  hr_utility.trace(l_proc||': vehicle_allocation_id='|| alc_rec.vehicle_allocation_id);
                  hr_utility.trace(l_proc||': vehicle_repository_id='|| alc_rec.vehicle_repository_id);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  hr_utility.trace(l_proc||': alc_dates_rec.min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
                  hr_utility.trace(l_proc||': alc_dates_rec.max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
                  --
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                            p_asg_act_id => p_assactid,
                                            p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                            p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                            p_action_flag => l_action_flag,
                                            p_allocation_start_date => alc_dates_rec.min_start_date,
                                            p_allocation_end_date => alc_dates_rec.max_end_date);
               END IF;
            END IF;
         END IF;
         -- Check if fuel type has changed within
         -- the date range.
         FOR vehicle_changes_rec IN c_vehicle_changes(alc_rec.vehicle_repository_id) LOOP
            -- Fuel type has changed therefore make sure
            -- this change occured after the vehicle was
            -- allocated to this assignment
            --
            hr_utility.set_location(l_proc, 110);
            hr_utility.trace(l_proc||': effective_start_date='|| vehicle_changes_rec.effective_start_date);
            hr_utility.trace(l_proc||': fuel_type='|| vehicle_changes_rec.fuel_type);
            --
            IF (vehicle_changes_rec.effective_start_date
                   BETWEEN alc_dates_rec.min_start_date+1 AND alc_dates_rec.max_end_date) AND
               (vehicle_changes_rec.effective_start_date
                   BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
               --
               -- Check if this fuel change has been
               -- already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          vehicle_changes_rec.effective_start_date,
                          'F');
               --
               hr_utility.set_location(l_proc, 120);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                         p_asg_act_id => p_assactid,
                                         p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                         p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                         p_fuel_type_change_date => vehicle_changes_rec.effective_start_date,
                                         p_action_flag => 'F',
                                         p_allocation_start_date => alc_dates_rec.min_start_date,
                                         p_allocation_end_date => alc_dates_rec.max_end_date);
                  --
               END IF;
            END IF;
         END LOOP;
         --
         hr_utility.set_location(l_proc, 130);
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         ----------------------------------------------------
         -- If tax ref has changed within the given date   --
         -- range then check whether it should be reported --
         -- as a new allocation or withdrawal              --
         ----------------------------------------------------
         IF (asg_rec.asg_min_start_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
            AND (asg_rec.asg_min_start_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has started on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- start date therefore check whether it is a transfer
            -- from another tax ref
            hr_utility.set_location(l_proc, 160);
            l_previous_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_min_start_date-1);
            FETCH c_tax_ref INTO l_previous_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 170);
            hr_utility.trace(l_proc||', l_previous_tax_ref='||l_previous_tax_ref);
            --
            IF l_previous_tax_ref is NOT NULL AND l_previous_tax_ref <> g_tax_ref THEN
               -- This assignment has a different prior tax ref
               -- therefore it should be reported as a new car
               -- allocation on this EDI message.
               hr_utility.set_location(l_proc, 180);
               l_action_flag := 'N';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_min_start_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 190);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                      p_asg_act_id => p_assactid,
                                      p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                      p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                      p_action_flag => l_action_flag,
                                      p_allocation_start_date => asg_rec.asg_min_start_date,
                                      p_allocation_end_date => asg_rec.asg_max_end_date);
               END IF;
               --
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         IF (asg_rec.asg_max_end_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
            AND (asg_rec.asg_max_end_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has ended on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- end date therefore check whether it is a transfer
            -- to another tax ref
            hr_utility.set_location(l_proc, 200);
            l_next_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_max_end_date+1);
            FETCH c_tax_ref INTO l_next_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 210);
            hr_utility.trace(l_proc||', l_next_tax_ref='||l_next_tax_ref);
            --
            IF l_next_tax_ref is NOT NULL AND l_next_tax_ref <> g_tax_ref THEN
               -- This assignment has a different tax ref after end date
               -- therefore it should be reported as allocation withdrawal
               -- on this EDI message.
               hr_utility.set_location(l_proc, 220);
               l_action_flag := 'W';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_max_end_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 230);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                         p_asg_act_id => p_assactid,
                                         p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                         p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                         p_action_flag => l_action_flag,
                                         p_allocation_start_date => asg_rec.asg_min_start_date,
                                         p_allocation_end_date => asg_rec.asg_max_end_date);
               END IF;
               --
            END IF;
         END IF;
         --
         hr_utility.set_location(l_proc, 240);
         --
         hr_utility.set_location(l_proc, 250);
      END LOOP;
      --
      hr_utility.set_location(l_proc, 260);
      --
   END LOOP;
   --
   hr_utility.set_location('Leaving: '||l_proc,290);
   --hr_utility.trace_off;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving: '||l_proc,300);
--    hr_utility.trace_off;
    raise;
END archive_code;
--

--For Bug 6652235
-----------------------------------------------------
--         PROCEDURE ARCHIVE_CODE_V2                --
-----------------------------------------------------
PROCEDURE archive_code_v2(p_assactid IN NUMBER,
                            p_effective_date IN DATE) IS
   --
   l_proc          CONSTANT VARCHAR2(35):= g_package||'archive_code_v2';
   --
   --
   CURSOR c_asg IS
   SELECT asg.assignment_id,
          min(asg.effective_start_date) asg_min_start_date,
          max(asg.effective_end_date) asg_max_end_date
   FROM   hr_soft_coding_keyflex flex,
          per_all_assignments_f asg,
          Pay_payrolls_f ppf,
          pay_assignment_actions act
   WHERE  act.assignment_action_id = p_assactid
   AND    act.assignment_id = asg.assignment_id
   AND    asg.payroll_id +0 = nvl(g_payroll_id,asg.payroll_id)
   AND    asg.payroll_id = ppf.payroll_id
   AND    ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = g_tax_ref
   AND   ( g_start_date BETWEEN asg.effective_start_date AND asg.effective_end_date
         OR g_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date
         OR (asg.effective_start_date BETWEEN g_start_date AND g_end_Date
             AND asg.effective_end_date BETWEEN g_start_date AND g_end_Date))
   GROUP by asg.assignment_id;
   --
   l_action_flag   VARCHAR2(1);
   l_archived_flag VARCHAR2(1);
   --
BEGIN
   --hr_utility.trace_on(null, 'KTHAMPAN');
   hr_utility.set_location('Entering '||l_proc, 10);
   --
   For asg_rec IN c_asg
   LOOP
      -- Loop through all assignments
      hr_utility.set_location(l_proc, 20);
      hr_utility.trace(l_proc||': assignment_id='||asg_rec.assignment_id);
      hr_utility.trace(l_proc||': asg_min_start_date='||fnd_date.date_to_displaydate(asg_rec.asg_min_start_date));
      hr_utility.trace(l_proc||': asg_max_end_date='||fnd_date.date_to_displaydate(asg_rec.asg_max_end_date));
      --
      FOR alc_rec IN c_allocations(asg_rec.assignment_id) LOOP
         -- Loop through all vehicle allocations
         -- over the date range
         hr_utility.set_location(l_proc, 30);
         hr_utility.trace(l_proc||': vehicle_allocation_id='||alc_rec.vehicle_allocation_id);
         hr_utility.trace(l_proc||': usage_type='||alc_rec.usage_type);
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         OPEN c_alloc_dates(alc_rec.vehicle_allocation_id);
         FETCH c_alloc_dates INTO alc_dates_rec;
         CLOSE c_alloc_dates;
         --
         hr_utility.set_location(l_proc, 40);
         hr_utility.trace(l_proc||': min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
         hr_utility.trace(l_proc||': max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
         --
         -- Check whether vehicle was allocated or
         -- Withdrawn within the date range also
         -- check that this allocation or withdrawal
         -- happened when assignment was with input tax ref
         IF (alc_dates_rec.min_start_date BETWEEN g_start_date AND g_end_Date) AND
            (alc_dates_rec.min_start_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            -- This is a New Car or replacement action
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  -- This is the first car allocation
                  -- of this employee in this tax ref
                  -- therefore check if it has replaced
                  -- any prior car
                  OPEN c_prior_prim_car(asg_rec.assignment_id, Alc_dates_rec.min_start_date);
                  FETCH c_prior_prim_car INTO prior_prim_car_rec;
                  IF c_prior_prim_car%FOUND THEN
                     L_action_flag := 'R';
                  ELSE
                     L_action_flag := 'N';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_prior_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as new car
                  L_action_flag := 'N';
               END IF;
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a primary car therefore mark
               -- it as new car allocation action
               l_action_flag := 'N';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  hr_utility.set_location(l_proc, 105);
                  hr_utility.trace(l_proc||': p_assactid='|| p_assactid);
                  hr_utility.trace(l_proc||': vehicle_allocation_id='|| alc_rec.vehicle_allocation_id);
                  hr_utility.trace(l_proc||': vehicle_repository_id='|| alc_rec.vehicle_repository_id);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  hr_utility.trace(l_proc||': alc_dates_rec.min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
                  hr_utility.trace(l_proc||': alc_dates_rec.max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
                  --
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                            p_asg_act_id => p_assactid,
                                            p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                            p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                            p_action_flag => l_action_flag,
                                            p_allocation_start_date => alc_dates_rec.min_start_date,
                                            p_allocation_end_date => alc_dates_rec.max_end_date);
               END IF;
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         IF (alc_dates_rec.max_end_date BETWEEN g_start_date AND g_end_Date) AND
               (alc_dates_rec.max_end_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  --
                  OPEN c_next_prim_car(asg_rec.assignment_id, Alc_dates_rec.max_end_date);
                  FETCH c_next_prim_car INTO next_prim_car_rec;
                  IF c_next_prim_car%FOUND THEN
                     -- There is a replacement action to
                     -- Report this car therefore
                     -- No need to archive this action
                     NULL;
                  ELSE
                     -- This is a withdrawal action
                     L_action_flag := 'W';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_next_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as withdrawal car
                  L_action_flag := 'W';
               END IF;
               --
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a first car therefore mark
               -- it as withdrawal car action
               l_action_flag := 'W';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  hr_utility.set_location(l_proc, 105);
                  hr_utility.trace(l_proc||': p_assactid='|| p_assactid);
                  hr_utility.trace(l_proc||': vehicle_allocation_id='|| alc_rec.vehicle_allocation_id);
                  hr_utility.trace(l_proc||': vehicle_repository_id='|| alc_rec.vehicle_repository_id);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  hr_utility.trace(l_proc||': alc_dates_rec.min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
                  hr_utility.trace(l_proc||': alc_dates_rec.max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
                  --
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                            p_asg_act_id => p_assactid,
                                            p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                            p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                            p_action_flag => l_action_flag,
                                            p_allocation_start_date => alc_dates_rec.min_start_date,
                                            p_allocation_end_date => alc_dates_rec.max_end_date);
               END IF;
            END IF;
         END IF;
         -- Check if fuel type has changed within
         -- the date range.
         FOR vehicle_changes_rec IN c_vehicle_changes(alc_rec.vehicle_repository_id) LOOP
            -- Fuel type has changed therefore make sure
            -- this change occured after the vehicle was
            -- allocated to this assignment
            --
            hr_utility.set_location(l_proc, 110);
            hr_utility.trace(l_proc||': effective_start_date='|| vehicle_changes_rec.effective_start_date);
            hr_utility.trace(l_proc||': fuel_type='|| vehicle_changes_rec.fuel_type);
            --
            IF (vehicle_changes_rec.effective_start_date
                   BETWEEN alc_dates_rec.min_start_date+1 AND alc_dates_rec.max_end_date) AND
               (vehicle_changes_rec.effective_start_date
                   BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
               --
               -- Check if this fuel change has been
               -- already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          vehicle_changes_rec.effective_start_date,
                          'F');
               --
               hr_utility.set_location(l_proc, 120);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                         p_asg_act_id => p_assactid,
                                         p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                         p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                         p_fuel_type_change_date => vehicle_changes_rec.effective_start_date,
                                         p_action_flag => 'F',
                                         p_allocation_start_date => alc_dates_rec.min_start_date,
                                         p_allocation_end_date => alc_dates_rec.max_end_date);
                  --
               END IF;
            END IF;
         END LOOP;
         --
         hr_utility.set_location(l_proc, 130);
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         ----------------------------------------------------
         -- If tax ref has changed within the given date   --
         -- range then check whether it should be reported --
         -- as a new allocation or withdrawal              --
         ----------------------------------------------------
         IF (asg_rec.asg_min_start_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
            AND (asg_rec.asg_min_start_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has started on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- start date therefore check whether it is a transfer
            -- from another tax ref
            hr_utility.set_location(l_proc, 160);
            l_previous_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_min_start_date-1);
            FETCH c_tax_ref INTO l_previous_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 170);
            hr_utility.trace(l_proc||', l_previous_tax_ref='||l_previous_tax_ref);
            --
            IF l_previous_tax_ref is NOT NULL AND l_previous_tax_ref <> g_tax_ref THEN
               -- This assignment has a different prior tax ref
               -- therefore it should be reported as a new car
               -- allocation on this EDI message.
               hr_utility.set_location(l_proc, 180);
               l_action_flag := 'N';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_min_start_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 190);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                      p_asg_act_id => p_assactid,
                                      p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                      p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                      p_action_flag => l_action_flag,
                                      p_allocation_start_date => asg_rec.asg_min_start_date,
                                      p_allocation_end_date => asg_rec.asg_max_end_date);
               END IF;
               --
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         IF (asg_rec.asg_max_end_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
            AND (asg_rec.asg_max_end_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has ended on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- end date therefore check whether it is a transfer
            -- to another tax ref
            hr_utility.set_location(l_proc, 200);
            l_next_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_max_end_date+1);
            FETCH c_tax_ref INTO l_next_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 210);
            hr_utility.trace(l_proc||', l_next_tax_ref='||l_next_tax_ref);
            --
            IF l_next_tax_ref is NOT NULL AND l_next_tax_ref <> g_tax_ref THEN
               -- This assignment has a different tax ref after end date
               -- therefore it should be reported as allocation withdrawal
               -- on this EDI message.
               hr_utility.set_location(l_proc, 220);
               l_action_flag := 'W';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_max_end_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 230);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                         p_asg_act_id => p_assactid,
                                         p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                         p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                         p_action_flag => l_action_flag,
                                         p_allocation_start_date => asg_rec.asg_min_start_date,
                                         p_allocation_end_date => asg_rec.asg_max_end_date);
               END IF;
               --
            END IF;
         END IF;
         --
         hr_utility.set_location(l_proc, 240);
         --
         hr_utility.set_location(l_proc, 250);
      END LOOP;
      --
      hr_utility.set_location(l_proc, 260);
      --
   END LOOP;
   --
   hr_utility.set_location('Leaving: '||l_proc,290);
   --hr_utility.trace_off;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving: '||l_proc,300);
--    hr_utility.trace_off;
    raise;
END archive_code_v2;

--For Bug 8986543
-----------------------------------------------------
--         PROCEDURE ARCHIVE_CODE_V3                --
-----------------------------------------------------
PROCEDURE archive_code_v3(p_assactid IN NUMBER,
                            p_effective_date IN DATE) IS
   --
   l_proc          CONSTANT VARCHAR2(100):= g_package||'archive_code_v3';
   --
   --
   CURSOR c_asg IS
   SELECT asg.assignment_id,
          min(asg.effective_start_date) asg_min_start_date,
          max(asg.effective_end_date) asg_max_end_date
   FROM   hr_soft_coding_keyflex flex,
          per_all_assignments_f asg,
          Pay_payrolls_f ppf,
          pay_assignment_actions act
   WHERE  act.assignment_action_id = p_assactid
   AND    act.assignment_id = asg.assignment_id
   AND    asg.payroll_id +0 = nvl(g_payroll_id,asg.payroll_id)
   AND    asg.payroll_id = ppf.payroll_id
   AND    ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    flex.segment1 = g_tax_ref
   AND   ( g_start_date BETWEEN asg.effective_start_date AND asg.effective_end_date
         OR g_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date
         OR (asg.effective_start_date BETWEEN g_start_date AND g_end_Date
             AND asg.effective_end_date BETWEEN g_start_date AND g_end_Date))
   GROUP by asg.assignment_id;
   --
   l_action_flag   VARCHAR2(1);
   l_archived_flag VARCHAR2(1);
   --
BEGIN
   --hr_utility.trace_on(null, 'KTHAMPAN');
   hr_utility.set_location('Entering '||l_proc, 10);
   --
   For asg_rec IN c_asg
   LOOP
      -- Loop through all assignments
      hr_utility.set_location(l_proc, 20);
      hr_utility.trace(l_proc||': assignment_id='||asg_rec.assignment_id);
      hr_utility.trace(l_proc||': asg_min_start_date='||fnd_date.date_to_displaydate(asg_rec.asg_min_start_date));
      hr_utility.trace(l_proc||': asg_max_end_date='||fnd_date.date_to_displaydate(asg_rec.asg_max_end_date));
      --
      FOR alc_rec IN c_allocations(asg_rec.assignment_id) LOOP
         -- Loop through all vehicle allocations
         -- over the date range
         hr_utility.set_location(l_proc, 30);
         hr_utility.trace(l_proc||': vehicle_allocation_id='||alc_rec.vehicle_allocation_id);
         hr_utility.trace(l_proc||': usage_type='||alc_rec.usage_type);
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         OPEN c_alloc_dates(alc_rec.vehicle_allocation_id);
         FETCH c_alloc_dates INTO alc_dates_rec;
         CLOSE c_alloc_dates;
         --
         hr_utility.set_location(l_proc, 40);
         hr_utility.trace(l_proc||': min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
         hr_utility.trace(l_proc||': max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
         --
         -- Check whether vehicle was allocated or
         -- Withdrawn within the date range also
         -- check that this allocation or withdrawal
         -- happened when assignment was with input tax ref
         IF (alc_dates_rec.min_start_date BETWEEN g_start_date AND g_end_Date) AND
            (alc_dates_rec.min_start_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            -- This is a New Car or replacement action
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.min_start_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  -- This is the first car allocation
                  -- of this employee in this tax ref
                  -- therefore check if it has replaced
                  -- any prior car
                  OPEN c_prior_prim_car(asg_rec.assignment_id, Alc_dates_rec.min_start_date);
                  FETCH c_prior_prim_car INTO prior_prim_car_rec;
                  IF c_prior_prim_car%FOUND THEN
                     L_action_flag := 'R';
                  ELSE
                     L_action_flag := 'N';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_prior_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as new car
                  L_action_flag := 'N';
               END IF;
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a primary car therefore mark
               -- it as new car allocation action
               l_action_flag := 'N';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF (l_archived_flag = 'N' AND l_action_flag <> 'R') --No need to archive replaced car as per new requirements of V3
               THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  hr_utility.set_location(l_proc, 105);
                  hr_utility.trace(l_proc||': p_assactid='|| p_assactid);
                  hr_utility.trace(l_proc||': vehicle_allocation_id='|| alc_rec.vehicle_allocation_id);
                  hr_utility.trace(l_proc||': vehicle_repository_id='|| alc_rec.vehicle_repository_id);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  hr_utility.trace(l_proc||': alc_dates_rec.min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
                  hr_utility.trace(l_proc||': alc_dates_rec.max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
                  --
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                            p_asg_act_id => p_assactid,
                                            p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                            p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                            p_action_flag => l_action_flag,
                                            p_allocation_start_date => alc_dates_rec.min_start_date,
                                            p_allocation_end_date => alc_dates_rec.max_end_date);
               END IF;
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         IF (alc_dates_rec.max_end_date BETWEEN g_start_date AND g_end_Date) AND
               (alc_dates_rec.max_end_date BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
            --
            IF alc_rec.usage_type = 'P' THEN
               ---------------------------------------------
               -- It's a primary car for the assignment   --
               -- therefore check whether it's the first  --
               -- car of the employee                     --
               ---------------------------------------------
               -- Get first assignment of this person
               -- in the tax_ref
               OPEN c_first_asg(asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_first_asg INTO first_asg_rec;
               CLOSE c_first_asg;
               --
               hr_utility.set_location(l_proc, 50);
               hr_utility.trace(l_proc||': First Assignment='|| first_asg_rec.assignment_id);
               -- Get primary car allocation of the
               -- first assignment of this person
               -- in this tax ref
               OPEN c_primary_car(first_asg_rec.assignment_id, alc_dates_rec.max_end_date);
               FETCH c_primary_car INTO primary_car_rec;
               CLOSE c_primary_car;
               --
               hr_utility.set_location(l_proc, 60);
               hr_utility.trace(l_proc||': Primary Car Allocation='|| primary_car_rec.vehicle_allocation_id);
               --
               IF primary_car_rec.vehicle_allocation_id = alc_rec.vehicle_allocation_id THEN
                  --
                  OPEN c_next_prim_car(asg_rec.assignment_id, Alc_dates_rec.max_end_date);
                  FETCH c_next_prim_car INTO next_prim_car_rec;
                  IF c_next_prim_car%FOUND THEN
                     -- There is a replacement action to
                     -- Report this car therefore
                     -- No need to archive this action
                     NULL;
                  ELSE
                     -- This is a withdrawal action
                     L_action_flag := 'W';
                  END IF;
                  --
                  hr_utility.set_location(l_proc, 70);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  --
                  CLOSE c_next_prim_car;
               ELSE
                  -- Not the first car of the employee
                  -- report this as withdrawal car
                  L_action_flag := 'W';
               END IF;
               --
               --
               hr_utility.set_location(l_proc, 80);
               hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
               --
            ELSE
               -- Not a first car therefore mark
               -- it as withdrawal car action
               l_action_flag := 'W';
            END IF;
            --
            hr_utility.set_location(l_proc, 90);
            hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
            --
            IF L_action_flag <> 'X' THEN
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          alc_dates_rec.min_start_date,
                          l_action_flag);
               --
               hr_utility.set_location(l_proc, 100);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  hr_utility.set_location(l_proc, 105);
                  hr_utility.trace(l_proc||': p_assactid='|| p_assactid);
                  hr_utility.trace(l_proc||': vehicle_allocation_id='|| alc_rec.vehicle_allocation_id);
                  hr_utility.trace(l_proc||': vehicle_repository_id='|| alc_rec.vehicle_repository_id);
                  hr_utility.trace(l_proc||': l_action_flag='|| l_action_flag);
                  hr_utility.trace(l_proc||': alc_dates_rec.min_start_date='|| fnd_date.date_to_displaydate(alc_dates_rec.min_start_date));
                  hr_utility.trace(l_proc||': alc_dates_rec.max_end_date='|| fnd_date.date_to_displaydate(alc_dates_rec.max_end_date));
                  --
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                            p_asg_act_id => p_assactid,
                                            p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                            p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                            p_action_flag => l_action_flag,
                                            p_allocation_start_date => alc_dates_rec.min_start_date,
                                            p_allocation_end_date => alc_dates_rec.max_end_date);
               END IF;
            END IF;
         END IF;
         -- Check if fuel type has changed within
         -- the date range.
         FOR vehicle_changes_rec IN c_vehicle_changes(alc_rec.vehicle_repository_id) LOOP
            -- Fuel type has changed therefore make sure
            -- this change occured after the vehicle was
            -- allocated to this assignment
            --
            hr_utility.set_location(l_proc, 110);
            hr_utility.trace(l_proc||': effective_start_date='|| vehicle_changes_rec.effective_start_date);
            hr_utility.trace(l_proc||': fuel_type='|| vehicle_changes_rec.fuel_type);
            --
            IF (vehicle_changes_rec.effective_start_date
                   BETWEEN alc_dates_rec.min_start_date+1 AND alc_dates_rec.max_end_date) AND
               (vehicle_changes_rec.effective_start_date
                   BETWEEN asg_rec.asg_min_start_date AND asg_rec.asg_max_end_date) THEN
               --
               -- Check if this fuel change has been
               -- already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                          alc_rec.vehicle_allocation_id,
                          vehicle_changes_rec.effective_start_date,
                          'F');
               --
               hr_utility.set_location(l_proc, 120);
               hr_utility.trace(l_proc||': l_archived_flag='|| l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                         p_asg_act_id => p_assactid,
                                         p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                         p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                         p_fuel_type_change_date => vehicle_changes_rec.effective_start_date,
                                         p_action_flag => 'F',
                                         p_allocation_start_date => alc_dates_rec.min_start_date,
                                         p_allocation_end_date => alc_dates_rec.max_end_date);
                  --
               END IF;
            END IF;
         END LOOP;
         --
         hr_utility.set_location(l_proc, 130);
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         ----------------------------------------------------
         -- If tax ref has changed within the given date   --
         -- range then check whether it should be reported --
         -- as a new allocation or withdrawal              --
         ----------------------------------------------------
         IF (asg_rec.asg_min_start_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
            AND (asg_rec.asg_min_start_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has started on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- start date therefore check whether it is a transfer
            -- from another tax ref
            hr_utility.set_location(l_proc, 160);
            l_previous_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_min_start_date-1);
            FETCH c_tax_ref INTO l_previous_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 170);
            hr_utility.trace(l_proc||', l_previous_tax_ref='||l_previous_tax_ref);
            --
            IF l_previous_tax_ref is NOT NULL AND l_previous_tax_ref <> g_tax_ref THEN
               -- This assignment has a different prior tax ref
               -- therefore it should be reported as a new car
               -- allocation on this EDI message.
               hr_utility.set_location(l_proc, 180);
               l_action_flag := 'N';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_min_start_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 190);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                      p_asg_act_id => p_assactid,
                                      p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                      p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                      p_action_flag => l_action_flag,
                                      p_allocation_start_date => asg_rec.asg_min_start_date,
                                      p_allocation_end_date => asg_rec.asg_max_end_date);
               END IF;
               --
            END IF;
         END IF;
         --
         L_action_flag := 'X';
         l_archived_flag := 'Y';
         --
         IF (asg_rec.asg_max_end_date BETWEEN alc_dates_rec.min_start_date AND alc_dates_rec.max_end_date)
            AND (asg_rec.asg_max_end_date BETWEEN g_start_Date and g_end_Date) THEN
            -- Assignment has ended on this payroll or tax ref during the
            -- input date range and this car allocation was active on the
            -- end date therefore check whether it is a transfer
            -- to another tax ref
            hr_utility.set_location(l_proc, 200);
            l_next_tax_ref := NULL;
            --
            OPEN c_tax_ref(asg_rec.assignment_id, asg_rec.asg_max_end_date+1);
            FETCH c_tax_ref INTO l_next_tax_ref;
            CLOSE c_tax_ref;
            --
            hr_utility.set_location(l_proc, 210);
            hr_utility.trace(l_proc||', l_next_tax_ref='||l_next_tax_ref);
            --
            IF l_next_tax_ref is NOT NULL AND l_next_tax_ref <> g_tax_ref THEN
               -- This assignment has a different tax ref after end date
               -- therefore it should be reported as allocation withdrawal
               -- on this EDI message.
               hr_utility.set_location(l_proc, 220);
               l_action_flag := 'W';
               --
               -- Check whether this allocation action
               -- has been already archived
               l_archived_flag := 'Y';
               l_archived_flag := chk_action_archived_v2(asg_rec.assignment_id,
                                  alc_rec.vehicle_allocation_id,
                                  asg_rec.asg_max_end_date,
                                  l_action_flag);
               --
               hr_utility.set_location(l_proc, 230);
               hr_utility.trace(l_proc||', l_archived_flag='||l_archived_flag);
               --
               IF l_archived_flag = 'N' THEN
                  -- Action has not been archived already
                  -- therefore archive it.
                  archive_allocation_action(p_assignment_id => asg_rec.assignment_id,
                                         p_asg_act_id => p_assactid,
                                         p_vehicle_allocation_id => alc_rec.vehicle_allocation_id,
                                         p_vehicle_repository_id => alc_rec.vehicle_repository_id,
                                         p_action_flag => l_action_flag,
                                         p_allocation_start_date => asg_rec.asg_min_start_date,
                                         p_allocation_end_date => asg_rec.asg_max_end_date);
               END IF;
               --
            END IF;
         END IF;
         --
         hr_utility.set_location(l_proc, 240);
         --
         hr_utility.set_location(l_proc, 250);
      END LOOP;
      --
      hr_utility.set_location(l_proc, 260);
      --
   END LOOP;
   --
   hr_utility.set_location('Leaving: '||l_proc,290);
   --hr_utility.trace_off;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving: '||l_proc,300);
--    hr_utility.trace_off;
    raise;
END archive_code_v3;


END pay_gb_edi_p46_car;

/
