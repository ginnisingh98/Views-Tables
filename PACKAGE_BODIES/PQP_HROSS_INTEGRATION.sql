--------------------------------------------------------
--  DDL for Package Body PQP_HROSS_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_HROSS_INTEGRATION" as
/* $Header: pqphrossintg.pkb 120.4 2006/09/05 11:31:17 brsinha noship $ */
-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
  g_debug                       Boolean;
  g_pkg                CONSTANT Varchar2(150) := 'PQP_HROSS_Integration.';
  g_leg_code                    Varchar2(5);
  g_emp_num_gen                 Varchar2(5);
  g_debug_on                    Boolean;
  l_per_rec                     per_all_people_f%ROWTYPE;
  l_asg_rec                     per_all_assignments_f%ROWTYPE;
  l_add_rec                     per_addresses%ROWTYPE;
  l_cntct_rec                   per_contact_relationships%ROWTYPE;
  l_phones_rec                  per_phones%ROWTYPE;
  l_hr_soft_rec                 hr_soft_coding_keyflex%ROWTYPE;
  l_ppl_grp_rec                 pay_people_groups%ROWTYPE;

  TYPE t_hrEmpApi IS RECORD
  (person_id                    per_all_people_f.person_id%TYPE
  ,assignment_id                per_all_assignments_f.assignment_id%TYPE
  ,per_object_version_number    per_all_people_f.object_version_number%TYPE
  ,asg_object_version_number    per_all_assignments_f.object_version_number%TYPE
  ,per_effective_start_date     Date
  ,per_effective_end_date       Date
  ,full_name                    per_all_people_f.full_name%TYPE
  ,per_comment_id               per_all_people_f.comment_id%TYPE
  ,assignment_sequence          per_all_assignments_f.assignment_sequence%TYPE
  ,assignment_number            per_all_assignments_f.assignment_number%TYPE
  ,name_combination_warning     Boolean
  ,assign_payroll_warning       Boolean
  ,orig_hire_warning            Boolean
  );

  TYPE t_AsgUpdCrit_Api IS RECORD
  (asg_object_version_number    per_all_assignments_f.object_version_number%TYPE
  ,special_ceiling_step_id    per_all_assignments_f.special_ceiling_step_id%TYPE
  ,people_group_id              per_all_assignments_f.people_group_id%TYPE
  ,soft_coding_keyflex_id      per_all_assignments_f.soft_coding_keyflex_id%TYPE
  ,group_name                   pay_people_groups.group_name%TYPE
  ,asg_effective_start_date     per_all_assignments_f.effective_start_date%TYPE
  ,asg_effective_end_date       per_all_assignments_f.effective_end_date%TYPE
  ,org_now_no_manager_warning   Boolean
  ,other_manager_warning        Boolean
  ,spp_delete_warning           Boolean
  ,entries_changed_warning      Varchar2(50)
  ,tax_district_changed_warning Boolean
  ,concatenated_segments       hr_soft_coding_keyflex.concatenated_segments%TYPE
  ,gsp_post_process_warning     Varchar2(2000)
  ,comment_id                   per_assignments_f.comment_id%TYPE
  );

  TYPE t_Upd_Emp_Asg_Api IS RECORD
  (cagr_grade_def_id            per_all_assignments_f.cagr_grade_def_id%TYPE
  ,cagr_concatenated_segments   Varchar2(2000)
  ,concatenated_segments        Varchar2(2000)
  ,soft_coding_keyflex_id      per_all_assignments_f.soft_coding_keyflex_id%TYPE
  ,comment_id                   per_all_assignments_f.comment_id%TYPE
  ,effective_start_date         per_all_assignments_f.effective_start_date%TYPE
  ,effective_end_date           per_all_assignments_f.effective_end_date%TYPE
  ,no_managers_warning          Boolean
  ,other_manager_warning        Boolean
  ,hourly_salaried_warning      Boolean
  ,gsp_post_process_warning     Varchar2(2000)
  );

  TYPE t_RehireEmp_Api IS RECORD
  (assignment_id                per_all_assignments_f.assignment_id%TYPE
  ,asg_object_version_number    per_all_assignments_f.object_version_number%TYPE
  ,per_effective_start_date     per_all_people_f.effective_start_date%TYPE
  ,per_effective_end_date       per_all_people_f.effective_end_date%TYPE
  ,assignment_sequence          per_all_assignments_f.assignment_sequence%TYPE
  ,assignment_number            per_all_assignments_f.assignment_number%TYPE
  ,assign_payroll_warning       Boolean
  );

  TYPE t_UpdEmp_Api IS RECORD
  (effective_start_date        per_all_people_f.effective_start_date%TYPE
  ,effective_end_date          per_all_people_f.effective_end_date%TYPE
  ,full_name                   per_all_people_f.full_name%TYPE
  ,comment_id                  Number
  ,name_combination_warning    Boolean
  ,assign_payroll_warning      Boolean
  ,orig_hire_warning           Boolean
  );

  TYPE t_HrToJob_Api IS RECORD
  (effective_start_date        per_all_people_f.effective_start_date%TYPE
  ,effective_end_date          per_all_people_f.effective_end_date%TYPE
  ,assignment_id               per_all_assignments_f.assignment_id%TYPE
  ,assign_payroll_warning      Boolean
  ,orig_hire_warning           Boolean
  );

  TYPE t_HrApp_Api IS RECORD
  (effective_start_date        per_all_people_f.effective_start_date%TYPE
  ,effective_end_date          per_all_people_f.effective_end_date%TYPE
  ,assign_payroll_warning      Boolean
  ,oversubscribed_vacancy_id   Number
  );

  TYPE t_CreateContact_Api IS RECORD
 (contact_relationship_id per_contact_relationships.contact_relationship_id%TYPE
 ,ctr_object_version_number per_contact_relationships.object_version_number%TYPE
  ,per_person_id               per_contact_relationships.contact_person_id%TYPE
  ,per_object_version_number
                           per_contact_relationships.object_version_number%TYPE
  ,per_effective_start_date    per_contact_relationships.date_start%TYPE
  ,per_effective_end_date      per_contact_relationships.date_start%TYPE
  ,full_name                   per_all_people_f.full_name%TYPE
  ,per_comment_id              per_all_people_f.comment_id%TYPE
  ,name_combination_warning    Boolean
  ,orig_hire_warning           Boolean
  );

-- =============================================================================
-- ~ Package Body Cursor variables:
-- =============================================================================
   -- Cursor to get the leg. code
   CURSOR csr_bg_code (c_bg_grp_id IN Number) IS
   SELECT pbg.legislation_code
         ,pbg.method_of_generation_emp_num
     FROM per_business_groups pbg
    WHERE pbg.business_group_id = c_bg_grp_id;

   -- Cursor to get the meaning and code for a lookup type
   CURSOR csr_chk_code (c_lookup_type    IN Varchar2
                       ,c_lookup_code    IN Varchar2
                       ,c_effective_date IN Date) IS
   SELECT hrl.meaning
         ,hrl.lookup_code
     FROM hr_lookups hrl
    WHERE hrl.lookup_type = c_lookup_type
      AND hrl.lookup_code = c_lookup_code
      AND hrl.enabled_flag = 'Y'
      AND Trunc(c_effective_date)
          BETWEEN NVL(hrl.start_date_active,Trunc(c_effective_date))
              AND NVL(hrl.end_date_active,  Trunc(c_effective_date));

   -- Cursor to check the valid DF context
   CURSOR csr_style (c_context_code IN Varchar2) IS
   SELECT dfc.descriptive_flex_context_code
     FROM fnd_descr_flex_contexts dfc
    WHERE dfc.application_id = 800
      AND dfc.descriptive_flexfield_name = 'Person Developer DF'
      AND dfc.enabled_flag = 'Y';

  -- Cursor to get details of a particular person
  CURSOR csr_per (c_person_id IN Number
                 ,c_business_group_id IN Number
                 ,c_effective_date IN Date ) IS
  SELECT *
    FROM per_all_people_f ppf
   WHERE ppf.person_id = c_person_id
     AND ppf.business_group_id = c_business_group_id
     AND c_effective_date BETWEEN ppf.effective_start_date
                              AND ppf.effective_end_date;

  -- Check the person or party if exists in HRMS
  CURSOR chk_party (c_party_id       IN Number
                   ,c_bg_grp_id      IN Number
                   ,c_person_id      IN Number
                   ,c_effective_date IN Date) IS
  SELECT ppt.system_person_type
        ,ppf.effective_start_date
        ,ppf.effective_end_date
        ,ppf.employee_number
        ,ppt.person_type_id
        ,ppf.person_id
    FROM per_all_people_f ppf
        ,per_person_types ppt
   WHERE ppt.person_type_id = ppf.person_type_id
     AND ppf.business_group_id = c_bg_grp_id
     AND ppt.business_group_id = ppf.business_group_id
     AND ppt.active_flag = 'Y'
     AND ((c_person_id IS NOT NULL AND ppf.person_id = c_person_id) OR
          (c_party_id IS NOT NULL AND ppf.party_id = c_party_id))
     AND c_effective_date BETWEEN ppf.effective_start_date
                              AND ppf.effective_end_date;

  -- Cursor to get the person types used as of a date
  CURSOR csr_per_ptu (c_person_id         IN Number
                     ,c_business_group_id IN Number
                     ,c_effective_date    IN Date) IS
  SELECT ptu.person_id
        ,ptu.person_type_id
        ,ppt.active_flag
        ,ppt.system_person_type
        ,ppt.user_person_type
    FROM per_person_type_usages_f ptu
        ,per_person_types         ppt
   WHERE ptu.person_id = c_person_id
     AND ppt.business_group_id = c_business_group_id
     AND ppt.person_type_id = ptu.person_type_id
     AND c_effective_date BETWEEN ptu.effective_start_date
                              AND ptu.effective_end_date
     AND ppt.system_person_type
         IN ('EMP','EMP_APL','EX_EMP',
             'APL','APL_EX_APL','EX_APL','EX_EMP_APL',
             'CWK','EX_CWK')
  ORDER BY ptu.effective_start_date desc;

  -- Cursor to check if the person has any future person type
  -- changes of EMP, APL, CWK or OTHER i.e. Contact type
  CURSOR chk_perType_usage (c_person_id         IN NUMBER
                           ,c_effective_date    IN Date
                           ,c_business_group_id IN Number) Is
  SELECT ptu.person_type_id
        ,ppt.system_person_type
        ,ppt.user_person_type
    FROM per_person_type_usages_f ptu
        ,per_person_types         ppt
   WHERE ptu.person_id = c_person_id
     AND ppt.person_type_id = ptu.person_type_id
     AND ppt.business_group_id = c_business_group_id
     AND ptu.effective_start_date > c_effective_date
     AND ppt.system_person_type
           IN ('EMP'   ,'CWK'       ,'APL'       ,'EMP_APL',
               'EX_APL','EX_CWK'    ,'EX_EMP_APL',
               'OTHER' ,'APL_EX_APL','EX_EMP'
               );

  -- Cursor to check if the applicant assignment is accepted
  CURSOR csr_accepted_asgs(c_person_id         IN Number
                          ,c_business_group_id IN Number
                          ,c_effective_date    IN Date
                          ,c_assignment_id     IN Number
                          ) IS
  SELECT asg.assignment_id
        ,asg.object_version_number
        ,asg.vacancy_id
    FROM per_assignments_f asg
        ,per_assignment_status_types ast
   WHERE asg.assignment_status_type_id = ast.assignment_status_type_id
     AND asg.person_id = c_person_id
     AND asg.business_group_id = c_business_group_id
     AND (c_assignment_id IS NULL OR
          asg.assignment_id = c_assignment_id)
     AND c_effective_date BETWEEN asg.effective_start_date
                              AND asg.effective_end_date
     AND asg.assignment_type = 'A'
     AND ast.per_system_status = 'ACCEPTED';

  -- Cursor to check if the applicant assignment is accepted
  CURSOR csr_not_accepted_asgs(c_person_id         IN Number
                              ,c_business_group_id IN Number
                              ,c_effective_date    IN Date
                              ,c_assignment_id     IN Number
                              ) IS
  SELECT asg.assignment_id
        ,asg.object_version_number
        ,asg.vacancy_id
    FROM per_assignments_f asg
        ,per_assignment_status_types ast
   WHERE asg.assignment_status_type_id = ast.assignment_status_type_id
     AND asg.person_id = c_person_id
     AND asg.business_group_id = c_business_group_id
     AND (c_assignment_id IS NULL OR
          asg.assignment_id = c_assignment_id)
     AND c_effective_date BETWEEN asg.effective_start_date
                              AND asg.effective_end_date
     AND asg.assignment_type = 'A'
     AND ast.per_system_status <> 'ACCEPTED';

  -- Cursor to get the Assignment Status Id of accepted Applicant Assig.
  CURSOR csr_asg_status (c_leg_code IN Varchar2
                        ,c_business_group_id IN NUMBER
                        ) IS
  SELECT assignment_status_type_id
        ,active_flag
        ,per_system_status
   FROM per_assignment_status_types
  WHERE per_system_status = 'ACCEPTED'
    AND (business_group_id = c_business_group_id
         OR legislation_code = c_leg_code
         OR (legislation_code IS NULL
             AND business_group_id IS NULL)
         )
    AND default_flag = 'Y'
    AND active_flag  = 'Y';

  -- Cursor to get the User Person Type
  CURSOR csr_per_type(c_person_type_id Number
                     ,c_business_group_id IN Number) IS
  SELECT ppt.user_person_type
    FROM per_person_types ppt
   WHERE ppt.person_type_id    = c_person_type_id
     AND ppt.business_group_id = c_business_group_id;

  -- Cursor to get the Grade Name
  CURSOR csr_grade(c_grade_id IN Number
                  ,c_business_group_id IN Number
                  ,c_effective_date IN Date) IS
  SELECT gtl.NAME
    FROM per_grades    pgr
        ,per_grades_tl gtl
   WHERE pgr.grade_id = c_grade_id
     AND gtl.grade_id = pgr.grade_id
     AND gtl.LANGUAGE = Userenv('LANG')
     AND  pgr.business_group_id = c_business_group_id
     AND c_effective_date BETWEEN pgr.date_from
                              AND NVL(pgr.date_to,c_effective_date);

  -- Cursor to get the Position Name
  CURSOR csr_position(c_position_id IN Number
                     ,c_business_group_id IN Number
                     ,c_effective_date IN Date) IS
  SELECT ptl.NAME
    FROM hr_all_positions_f    pos
        ,hr_all_positions_f_tl ptl
   WHERE pos.position_id = c_position_id
     AND ptl.position_id = pos.position_id
     AND ptl.LANGUAGE = Userenv('LANG')
     AND pos.business_group_id = c_business_group_id
     AND c_effective_date BETWEEN pos.effective_start_date
                              AND pos.effective_end_date;

  -- Cursor to get the Job Name
  CURSOR csr_job(c_job_id IN Number
                ,c_business_group_id IN Number
                ,c_effective_date IN Date) IS
  SELECT jtl.NAME
    FROM per_jobs    pjb
        ,per_jobs_tl jtl
   WHERE pjb.job_id = c_job_id
     AND jtl.job_id = pjb.job_id
     AND jtl.LANGUAGE = Userenv('LANG')
     AND pjb.business_group_id = c_business_group_id
     AND c_effective_date BETWEEN pjb.date_from
                              AND NVL(pjb.date_to,c_effective_date);

  -- Cursor to get the Payroll Name
  CURSOR csr_payroll(c_payroll_id IN Number
                    ,c_business_group_id IN Number
                    ,c_effective_date IN Date) IS
  SELECT payroll_name
    FROM pay_payrolls_f ppf
   WHERE ppf.payroll_id = c_payroll_id
     AND ppf.business_group_id = c_business_group_id
     AND c_effective_date BETWEEN ppf.effective_start_date
                              AND ppf.effective_end_date;

  -- Cursor to get the Location Code
  CURSOR csr_location(c_location_id IN Number
                     ,c_business_group_id IN Number
                     ) IS
  SELECT htl.location_code
    FROM hr_locations          hrl
        ,hr_locations_all_tl   htl
   WHERE hrl.location_id = c_location_id
     AND htl.location_id = hrl.location_id
     AND htl.LANGUAGE = Userenv('LANG')
     AND (hrl.business_group_id IS NULL OR
          hrl.business_group_id = c_business_group_id);

  -- Cursor to get the Organization Name
  CURSOR csr_organization(c_organization_id IN Number
                         ,c_business_group_id IN Number
                         ,c_effective_date IN Date
                          ) IS
  SELECT htl.NAME
    FROM hr_all_organization_units_tl htl
        ,hr_all_organization_units    hao
   WHERE hao.organization_id = c_organization_id
     AND hao.business_group_id = c_business_group_id
     AND htl.organization_id = hao.organization_id
     AND htl.LANGUAGE = Userenv('LANG')
     AND c_effective_date BETWEEN hao.date_from
                              AND NVL(hao.date_to,c_effective_date);

  -- Cursor to get the Pay Basis Name
  CURSOR csr_paybasis(c_pay_basis_id IN Number
                     ,c_business_group_id IN Number
                     ) IS
  SELECT ppb.NAME
    FROM per_pay_bases ppb
   WHERE ppb.pay_basis_id = c_pay_basis_id
     AND ppb.business_group_id = c_business_group_id;

  -- Cursor to check if address already exists
  CURSOR csr_ck_add_xsts (c_person_id         IN Number
                         ,c_business_group_id IN Number
                         ,c_effective_date    IN Date
                         ,c_primary_flag      IN Varchar2) IS
  SELECT *
    FROM per_addresses
   WHERE person_id = c_person_id
     AND business_group_id = c_business_group_id
     AND primary_flag = c_primary_flag
     AND c_effective_date BETWEEN date_from
                              AND NVL(date_to, c_effective_date);

  -- Cursor to check if Contact for a person already exists
  CURSOR csr_ck_cont_xsts(c_person_id         IN Number
                         ,c_business_group_id IN Number
                         ,c_effective_date    IN Date) IS
  SELECT object_version_number
    FROM per_contact_relationships
   WHERE person_id = c_person_id
     AND business_group_id = c_business_group_id
     AND c_effective_date BETWEEN date_start
                              AND NVL(date_end, c_effective_date);

  -- Cursor to get the Employee Number
  CURSOR csr_get_employee_num(c_person_id   IN Number) IS
  SELECT employee_number
    FROM per_people_f
   WHERE person_id = c_person_id;

-- =============================================================================
-- ~ Student_FICA_Status: Procedure to update the FICA status of a student
-- ~ employee. This is only required to US legislation when the user selects the
-- ~ FICA option as Yes on the OAF UI.
-- =============================================================================
PROCEDURE Student_FICA_Status
          (p_assignment_id     IN Number
          ,p_effective_date    IN Date
          ,p_business_group_id IN Number
          ,p_FICA_Status       IN Varchar2) IS

  -- Cursor to get the current FICA status
  CURSOR csr_tax (c_effective_date IN Date
                 ,c_assignment_id  IN Number) IS
  SELECT *
    FROM pay_us_emp_fed_tax_rules_f ftx
   WHERE ftx.assignment_id = c_assignment_id
     AND c_effective_date between ftx.effective_start_date
                              AND ftx.effective_end_date;

  l_fed_rec               csr_tax%Rowtype;
  --
  l_effective_date        Date;
  l_start_effective_date  Date;
  l_end_effective_date    Date;
  --
  l_dt_update             Boolean;
  l_dt_upd_override       Boolean;
  l_upd_chg_ins           Boolean;
  l_dt_correction         Boolean;
  --
  l_Datetrack_mode        Varchar2(50);
  l_error_msg             Varchar2(2000);
  l_proc_name    Constant Varchar2(150) :='Student_FICA_Status';

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  OPEN csr_tax (c_effective_date => p_effective_date
               ,c_assignment_id  => p_assignment_id);
  FETCH csr_tax INTO l_fed_rec;
  Hr_Utility.set_location(' EMP_FED_TAX_RULE_ID: '||l_fed_rec.emp_fed_tax_rule_id, 10);
  IF csr_tax%NOTFOUND THEN
     CLOSE csr_tax;
     RETURN;
  END IF;
  CLOSE csr_tax;

  Dt_Api.Find_DT_Upd_Modes
  (p_effective_date       => p_effective_date
  ,p_base_table_name      => 'PAY_US_EMP_FED_TAX_RULES_F'
  ,p_base_key_column      => 'EMP_FED_TAX_RULE_ID'
  ,p_base_key_value       => l_fed_rec.emp_fed_tax_rule_id
  ,p_correction           => l_dt_correction
  ,p_update               => l_dt_update
  ,p_update_override      => l_dt_upd_override
  ,p_update_change_insert => l_upd_chg_ins
   );

  IF l_dt_update THEN
     l_datetrack_mode := 'UPDATE';
  ELSIF l_dt_upd_override OR
        l_upd_chg_ins THEN
        -- Need to check if person type in future is EMP, APL or CWK , if yes
        -- then raise error
        NULL;
  ELSE
     l_Datetrack_mode := 'CORRECTION';
  END IF;

  Hr_Utility.set_location(' l_datetrack_mode: '||l_datetrack_mode, 15);
  IF l_fed_rec.emp_fed_tax_rule_id IS NOT NULL THEN
     IF NVL(p_FICA_Status,'N') = 'N' THEN
       l_fed_rec.medicare_tax_exempt := 'N';
       l_fed_rec.ss_tax_exempt       := 'N';
     ELSE
       l_fed_rec.medicare_tax_exempt := 'Y';
       l_fed_rec.ss_tax_exempt       := 'Y';
     END IF;

     Pay_Federal_Tax_Rule_Api.UpDate_Fed_Tax_Rule
     (p_validate              => false
     ,p_effective_date        => p_effective_date
     ,p_datetrack_update_mode => l_datetrack_mode
     ,p_emp_fed_tax_rule_id   => l_fed_rec.emp_fed_tax_rule_id
     ,p_object_version_number => l_fed_rec.object_version_number
     ,p_medicare_tax_exempt   => l_fed_rec.medicare_tax_exempt
     ,p_ss_tax_exempt         => l_fed_rec.ss_tax_exempt
     ,p_effective_start_date  => l_start_effective_date
     ,p_effective_end_date    => l_end_effective_date
     );
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

EXCEPTION
  WHEN OTHERS THEN
   IF csr_tax%ISOPEN THEN
      CLOSE csr_tax;
   END IF;
   l_error_msg := sqlerrm;
   Hr_Utility.set_location('SQLCODE :'||SQLCODE,90);
   Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   Hr_Utility.raise_error;

END Student_FICA_Status;
-- =============================================================================
-- ~ FICA_Status: Function to return the FICA status of an employee assignment.
-- ~ This only appicable for US legislation
-- =============================================================================
FUNCTION FICA_Status
         (p_assignment_id     IN Number
         ,p_effective_date    IN Date
          ) RETURN Varchar2 IS

  --Cursor to get the current FICA status
  CURSOR csr_tax (c_effective_date IN DATE
                ,c_assignment_id IN NUMBER) IS
  SELECT *
   FROM pay_us_emp_fed_tax_rules_f ftx
  WHERE ftx.assignment_id = c_assignment_id
    AND c_effective_date between ftx.effective_start_date
                             AND ftx.effective_end_date;

  -- Local Variable to hold the cursor values
  l_fed_rec                   csr_tax%ROWTYPE;

  -- Other local variables
  l_error_message             Varchar2(2000);
  l_return_status             Varchar2(5);
  l_proc_name      CONSTANT   Varchar2(150) := g_pkg||'FICA_Status';

BEGIN
  Hr_utility.set_location('Entering:' || l_proc_name, 10);
  Hr_utility.set_location('p_assignment_id = ' || p_assignment_id, 20);

  l_return_status := 'N';
  OPEN csr_tax(c_effective_date =>  p_effective_date
              ,c_assignment_id  =>  p_assignment_id);
  FETCH csr_tax INTO l_fed_rec;
  IF csr_tax%NOTFOUND THEN
    CLOSE csr_tax;
  ELSE
    Hr_utility.set_location('Tax record found', 30);
    Hr_utility.set_location('SS :'||l_fed_rec.ss_tax_exempt, 30);
    Hr_utility.set_location('Medicare: '||l_fed_rec.medicare_tax_exempt, 30);
    IF NVL(l_fed_rec.medicare_tax_exempt,'N') = 'Y' AND
       NVL(l_fed_rec.ss_tax_exempt,'N') = 'Y' THEN
       l_return_status := 'Y';
    END IF;
  END IF;
  Hr_Utility.set_location('Leaving:' || l_proc_name, 50);
  RETURN l_return_status;

EXCEPTION
  WHEN OTHERS THEN
   IF csr_tax%ISOPEN THEN
      CLOSE csr_tax;
   END IF;
   Hr_Utility.set_location('Leaving:' || l_proc_name, 90);
   RETURN l_return_status;

END FICA_Status;
-- =============================================================================
-- ~ Update_StuEmpAsg_Criteria :
-- =============================================================================
PROCEDURE Update_StuEmpAsg_Criteria
         (p_effective_date IN Date
         ,p_asg_crit_out   IN OUT NOCOPY t_AsgUpdCrit_Api
         --,p_UpdEmpAsg_out  IN OUT NOCOPY t_Upd_Emp_Asg_Api
          ) AS

  -- Cursor to get Assignment details
  CURSOR csr_asg (c_effective_date IN Date
                 ,c_assignment_id  IN Number
                 ,c_business_group_id IN Number)IS
  SELECT *
    FROM per_all_assignments_f paf
   WHERE paf.assignment_id = c_assignment_id
     AND paf.business_group_id = c_business_group_id
     AND c_effective_date BETWEEN paf.effective_start_date
                              AND paf.effective_end_date;

  l_cur_asg_rec            csr_asg%ROWTYPE;

  -- Cursor to get people group flexfield details
  CURSOR csr_ppg (c_people_grp_id IN Number) IS
  SELECT *
    FROM pay_people_groups
   WHERE people_group_id = c_people_grp_id;

  l_cur_ppl_grp_rec        pay_people_groups%ROWTYPE;

  -- Cursor to get Soft coding flexfield details
  CURSOR csr_scl (c_scl_kff_id IN Number) IS
  SELECT *
    FROM hr_soft_coding_keyflex
   WHERE soft_coding_keyflex_id = c_scl_kff_id;

  l_cur_scl_rec        hr_soft_coding_keyflex%ROWTYPE;

  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Update_StuEmpAsg_Criteria';
  l_error_msg              Varchar2(2000);
  l_datetrack_update_mode  Varchar2(50);
  l_dt_correction          Boolean;
  l_dt_update              Boolean;
  l_dt_upd_override        Boolean;
  l_upd_chg_ins            Boolean;
  e_empasg_notfound        EXCEPTION;
  l_UpdEmpAsg_out          t_Upd_Emp_Asg_Api;

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  OPEN  csr_asg (c_effective_date    => p_effective_date
                ,c_assignment_id     => l_asg_rec.assignment_id
                ,c_business_group_id => l_asg_rec.business_group_id
                 );
  FETCH csr_asg INTO l_cur_asg_rec;
  IF csr_asg%NOTFOUND THEN
     CLOSE csr_asg;
     RAISE e_empasg_notfound;
  END IF;
  CLOSE csr_asg;
  hr_utility.set_location(' l_cur_asg_rec: ' || p_effective_date, 20);
  hr_utility.set_location(' l_cur_asg_rec: ' || l_asg_rec.assignment_id, 20);
  hr_utility.set_location(' l_cur_asg_rec: ' || l_asg_rec.business_group_id, 20);

  OPEN  csr_ppg(c_people_grp_id => l_asg_rec.people_group_id);
  FETCH csr_ppg INTO l_cur_ppl_grp_rec;
  IF csr_ppg%FOUND THEN
     p_asg_crit_out.people_group_id := l_asg_rec.people_group_id;
  END IF;
  CLOSE csr_ppg;
  hr_utility.set_location(' people_group_id: ' || l_asg_rec.people_group_id, 30);

  OPEN  csr_scl(c_scl_kff_id => l_asg_rec.soft_coding_keyflex_id);
  FETCH csr_scl INTO l_cur_scl_rec;
  IF csr_scl%FOUND THEN
     p_asg_crit_out.soft_coding_keyflex_id := l_asg_rec.soft_coding_keyflex_id;
  END IF;
  CLOSE csr_scl;
  hr_utility.set_location(' soft_coding_keyflex_id: ' ||
                            l_asg_rec.soft_coding_keyflex_id, 40);

  Dt_Api.Find_DT_Upd_Modes
  (p_effective_date        => p_effective_date
  ,p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F'
  ,p_base_key_column       => 'ASSIGNMENT_ID'
  ,p_base_key_value        => l_asg_rec.assignment_id
  ,p_correction            => l_dt_correction
  ,p_update                => l_dt_update
  ,p_update_override       => l_dt_upd_override
  ,p_update_change_insert  => l_upd_chg_ins
   );

  IF l_dt_update THEN
     l_datetrack_update_mode := 'UPDATE';
  ELSIF l_dt_upd_override OR
        l_upd_chg_ins THEN
        -- Need to check if person type in future is EMP, APL or CWK , if yes
        -- then raise error
     l_datetrack_update_mode := 'UPDATE';
     hr_utility.set_location(' l_dt_upd_override or l_upd_chg_ins ', 50);
  ELSE
     l_datetrack_update_mode := 'CORRECTION';
  END IF;
  hr_utility.set_location(' l_datetrack_update_mode: ' ||
                            l_datetrack_update_mode, 60);

  Hr_Assignment_Api.Update_Emp_Asg_Criteria
  (p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_assignment_id                => l_asg_rec.assignment_id
  ,p_validate                     => FALSE
  ,p_called_from_mass_update      => FALSE
  ,p_grade_id                     => NVL(l_asg_rec.grade_id,
                                         l_cur_asg_rec.grade_id)
  ,p_position_id                  => NVL(l_asg_rec.position_id,
                                         l_cur_asg_rec.position_id)
  ,p_job_id                       => NVL(l_asg_rec.job_id,
                                         l_cur_asg_rec.job_id)
  ,p_payroll_id                   => NVL(l_asg_rec.payroll_id,
                                         l_cur_asg_rec.payroll_id)
  ,p_location_id                  => NVL(l_asg_rec.location_id,
                                         l_cur_asg_rec.location_id)
  ,p_organization_id              => NVL(l_asg_rec.organization_id,
                                         l_cur_asg_rec.organization_id)
  ,p_pay_basis_id                 => NVL(l_asg_rec.pay_basis_id,
                                         l_cur_asg_rec.pay_basis_id)
  ,p_employment_category          => NVL(l_asg_rec.employment_category,
                                         l_cur_asg_rec.employment_category)
  ,p_segment1                     => l_ppl_grp_rec.segment1
  ,p_segment2                     => l_ppl_grp_rec.segment2
  ,p_segment3                     => l_ppl_grp_rec.segment3
  ,p_segment4                     => l_ppl_grp_rec.segment4
  ,p_segment5                     => l_ppl_grp_rec.segment5
  ,p_segment6                     => l_ppl_grp_rec.segment6
  ,p_segment7                     => l_ppl_grp_rec.segment7
  ,p_segment8                     => l_ppl_grp_rec.segment8
  ,p_segment9                     => l_ppl_grp_rec.segment9
  ,p_segment10                    => l_ppl_grp_rec.segment10
  ,p_segment11                    => l_ppl_grp_rec.segment11
  ,p_segment12                    => l_ppl_grp_rec.segment12
  ,p_segment13                    => l_ppl_grp_rec.segment13
  ,p_segment14                    => l_ppl_grp_rec.segment14
  ,p_segment15                    => l_ppl_grp_rec.segment15
  ,p_segment16                    => l_ppl_grp_rec.segment16
  ,p_segment17                    => l_ppl_grp_rec.segment17
  ,p_segment18                    => l_ppl_grp_rec.segment18
  ,p_segment19                    => l_ppl_grp_rec.segment19
  ,p_segment20                    => l_ppl_grp_rec.segment20
  ,p_segment21                    => l_ppl_grp_rec.segment21
  ,p_segment22                    => l_ppl_grp_rec.segment22
  ,p_segment23                    => l_ppl_grp_rec.segment23
  ,p_segment24                    => l_ppl_grp_rec.segment24
  ,p_segment25                    => l_ppl_grp_rec.segment25
  ,p_segment26                    => l_ppl_grp_rec.segment26
  ,p_segment27                    => l_ppl_grp_rec.segment27
  ,p_segment28                    => l_ppl_grp_rec.segment28
  ,p_segment29                    => l_ppl_grp_rec.segment29
  ,p_segment30                    => l_ppl_grp_rec.segment30
  ,p_concat_segments              => l_ppl_grp_rec.group_name
/*
  ,p_contract_id                  IN     NUMBER   DEFAULT Hr_Api.g_number
  ,p_establishment_id             IN     NUMBER   DEFAULT Hr_Api.g_number
  ,p_grade_ladder_pgm_id          IN     NUMBER   DEFAULT Hr_Api.g_number
  ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT Hr_Api.g_number
*/
  ,p_scl_segment1                 => l_hr_soft_rec.segment1
  ,p_object_version_number        => l_cur_asg_rec.object_version_number
  ,p_special_ceiling_step_id      => p_asg_crit_out.special_ceiling_step_id
  ,p_people_group_id              => p_asg_crit_out.people_group_id
  ,p_soft_coding_keyflex_id       => p_asg_crit_out.soft_coding_keyflex_id
  ,p_group_name                   => p_asg_crit_out.group_name
  ,p_effective_start_date         => p_asg_crit_out.asg_effective_start_date
  ,p_effective_end_date           => p_asg_crit_out.asg_effective_end_date
  ,p_org_now_no_manager_warning   => p_asg_crit_out.org_now_no_manager_warning
  ,p_other_manager_warning        => p_asg_crit_out.other_manager_warning
  ,p_spp_delete_warning           => p_asg_crit_out.spp_delete_warning
  ,p_entries_changed_warning      => p_asg_crit_out.entries_changed_warning
  ,p_tax_district_changed_warning => p_asg_crit_out.tax_district_changed_warning
  ,p_concatenated_segments        => p_asg_crit_out.concatenated_segments
  ,p_gsp_post_process_warning     => p_asg_crit_out.gsp_post_process_warning
  );
  IF g_debug_on THEN
     hr_utility.set_location(' people_group_id: ' ||
                               p_asg_crit_out.people_group_id, 70);
     hr_utility.set_location(' soft_coding_keyflex_id: ' ||
                               p_asg_crit_out.soft_coding_keyflex_id, 70);
     hr_utility.set_location(' group_name: ' ||
                               p_asg_crit_out.group_name, 70);
     hr_utility.set_location(' asg_effective_start_date: ' ||
                               p_asg_crit_out.asg_effective_start_date, 70);
  END IF;
  l_datetrack_update_mode := 'CORRECTION';

  l_asg_rec.cagr_grade_def_id := NVL(l_asg_rec.cagr_grade_def_id,
                                     l_cur_asg_rec.cagr_grade_def_id);
  l_asg_rec.soft_coding_keyflex_id := p_asg_crit_out.soft_coding_keyflex_id;
  --
  -- Hr_Assignment_Api.Update_Emp_Asg: Use the overloaded update_emp_asg(NEW3)
  --
  Hr_Assignment_Api.Update_Emp_Asg
  (p_validate                     => FALSE
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_assignment_id                => l_cur_asg_rec.assignment_id
  ,p_object_version_number        => l_cur_asg_rec.object_version_number
  ,p_supervisor_id                => NVL(l_asg_rec.supervisor_id,
                                         l_cur_asg_rec.supervisor_id)
  ,p_assignment_number            => NVL(l_asg_rec.assignment_number,
                                         l_cur_asg_rec.assignment_number)
  ,p_change_reason                => NVL(l_asg_rec.change_reason,
                                         l_cur_asg_rec.change_reason)
  ,p_date_probation_end           => NVL(l_asg_rec.date_probation_end,
                                         l_cur_asg_rec.date_probation_end)
  ,p_default_code_comb_id         => NVL(l_asg_rec.default_code_comb_id,
                                         l_cur_asg_rec.default_code_comb_id)
  ,p_frequency                    => NVL(l_asg_rec.frequency,
                                         l_cur_asg_rec.frequency)
  ,p_internal_address_line        => NVL(l_asg_rec.internal_address_line,
                                         l_cur_asg_rec.internal_address_line)
  ,p_manager_flag                 => NVL(l_asg_rec.manager_flag,
                                         l_cur_asg_rec.manager_flag)
  ,p_normal_hours                 => NVL(l_asg_rec.normal_hours,
                                         l_cur_asg_rec.normal_hours)
  ,p_perf_review_period           => NVL(l_asg_rec.perf_review_period,
                                         l_cur_asg_rec.perf_review_period)
  ,p_perf_review_period_frequency => NVL(l_asg_rec.perf_review_period_frequency,
                                     l_cur_asg_rec.perf_review_period_frequency)
  ,p_probation_period             => NVL(l_asg_rec.probation_period,
                                         l_cur_asg_rec.probation_period)
  ,p_probation_unit               => NVL(l_asg_rec.probation_unit,
                                         l_cur_asg_rec.probation_unit)
  ,p_sal_review_period            => NVL(l_asg_rec.sal_review_period,
                                         l_cur_asg_rec.sal_review_period)
  ,p_sal_review_period_frequency  => NVL(l_asg_rec.sal_review_period_frequency,
                                     l_cur_asg_rec.sal_review_period_frequency)
  ,p_set_of_books_id              => NVL(l_asg_rec.set_of_books_id,
                                         l_cur_asg_rec.set_of_books_id)
  ,p_source_type                  => NVL(l_asg_rec.source_type,
                                         l_cur_asg_rec.source_type)
  ,p_time_normal_finish           => NVL(l_asg_rec.time_normal_finish,
                                         l_cur_asg_rec.time_normal_finish)
  ,p_time_normal_start            => NVL(l_asg_rec.time_normal_start,
                                         l_cur_asg_rec.time_normal_start)
  ,p_bargaining_unit_code         => NVL(l_asg_rec.bargaining_unit_code,
                                         l_cur_asg_rec.bargaining_unit_code)
  ,p_labour_union_member_flag     => NVL(l_asg_rec.labour_union_member_flag,
                                         l_cur_asg_rec.labour_union_member_flag)
  ,p_hourly_salaried_code         => NVL(l_asg_rec.hourly_salaried_code,
                                         l_cur_asg_rec.hourly_salaried_code)
  ,p_title                        => NVL(l_asg_rec.title,
                                         l_cur_asg_rec.title)
  -- Assignment DF
  ,p_ass_attribute_category       => l_asg_rec.ass_attribute_category
  ,p_ass_attribute1               => l_asg_rec.ass_attribute1
  ,p_ass_attribute2               => l_asg_rec.ass_attribute2
  ,p_ass_attribute3               => l_asg_rec.ass_attribute3
  ,p_ass_attribute4               => l_asg_rec.ass_attribute4
  ,p_ass_attribute5               => l_asg_rec.ass_attribute5
  ,p_ass_attribute6               => l_asg_rec.ass_attribute6
  ,p_ass_attribute7               => l_asg_rec.ass_attribute7
  ,p_ass_attribute8               => l_asg_rec.ass_attribute8
  ,p_ass_attribute9               => l_asg_rec.ass_attribute9
  ,p_ass_attribute10              => l_asg_rec.ass_attribute10
  ,p_ass_attribute11              => l_asg_rec.ass_attribute11
  ,p_ass_attribute12              => l_asg_rec.ass_attribute12
  ,p_ass_attribute13              => l_asg_rec.ass_attribute13
  ,p_ass_attribute14              => l_asg_rec.ass_attribute14
  ,p_ass_attribute15              => l_asg_rec.ass_attribute15
  ,p_ass_attribute16              => l_asg_rec.ass_attribute16
  ,p_ass_attribute17              => l_asg_rec.ass_attribute17
  ,p_ass_attribute18              => l_asg_rec.ass_attribute18
  ,p_ass_attribute19              => l_asg_rec.ass_attribute19
  ,p_ass_attribute20              => l_asg_rec.ass_attribute20
  ,p_ass_attribute21              => l_asg_rec.ass_attribute21
  ,p_ass_attribute22              => l_asg_rec.ass_attribute22
  ,p_ass_attribute23              => l_asg_rec.ass_attribute23
  ,p_ass_attribute24              => l_asg_rec.ass_attribute24
  ,p_ass_attribute25              => l_asg_rec.ass_attribute25
  ,p_ass_attribute26              => l_asg_rec.ass_attribute26
  ,p_ass_attribute27              => l_asg_rec.ass_attribute27
  ,p_ass_attribute28              => l_asg_rec.ass_attribute28
  ,p_ass_attribute29              => l_asg_rec.ass_attribute29
  ,p_ass_attribute30              => l_asg_rec.ass_attribute30
  -- Hr Soft Coding KeyFlex segments
  ,p_segment1                     => l_hr_soft_rec.segment1
  ,p_segment2                     => l_hr_soft_rec.segment2
  ,p_segment3                     => l_hr_soft_rec.segment3
  ,p_segment4                     => l_hr_soft_rec.segment4
  ,p_segment5                     => l_hr_soft_rec.segment5
  ,p_segment6                     => l_hr_soft_rec.segment6
  ,p_segment7                     => l_hr_soft_rec.segment7
  ,p_segment8                     => l_hr_soft_rec.segment8
  ,p_segment9                     => l_hr_soft_rec.segment9
  ,p_segment10                    => l_hr_soft_rec.segment10
  ,p_segment11                    => l_hr_soft_rec.segment11
  ,p_segment12                    => l_hr_soft_rec.segment12
  ,p_segment13                    => l_hr_soft_rec.segment13
  ,p_segment14                    => l_hr_soft_rec.segment14
  ,p_segment15                    => l_hr_soft_rec.segment15
  ,p_segment16                    => l_hr_soft_rec.segment16
  ,p_segment17                    => l_hr_soft_rec.segment17
  ,p_segment18                    => l_hr_soft_rec.segment18
  ,p_segment19                    => l_hr_soft_rec.segment19
  ,p_segment20                    => l_hr_soft_rec.segment20
  ,p_segment21                    => l_hr_soft_rec.segment21
  ,p_segment22                    => l_hr_soft_rec.segment22
  ,p_segment23                    => l_hr_soft_rec.segment23
  ,p_segment24                    => l_hr_soft_rec.segment24
  ,p_segment25                    => l_hr_soft_rec.segment25
  ,p_segment26                    => l_hr_soft_rec.segment26
  ,p_segment27                    => l_hr_soft_rec.segment27
  ,p_segment28                    => l_hr_soft_rec.segment28
  ,p_segment29                    => l_hr_soft_rec.segment29
  ,p_segment30                    => l_hr_soft_rec.segment30
  ,p_concat_segments              => l_hr_soft_rec.concatenated_segments
  -- Out Parameters
  ,p_cagr_grade_def_id            => l_asg_rec.cagr_grade_def_id
  ,p_soft_coding_keyflex_id       => l_asg_rec.soft_coding_keyflex_id
  ,p_cagr_concatenated_segments   => l_UpdEmpAsg_out.cagr_concatenated_segments
  ,p_comment_id                   => l_UpdEmpAsg_out.comment_id
  ,p_effective_start_date         => l_UpdEmpAsg_out.effective_start_date
  ,p_effective_end_date           => l_UpdEmpAsg_out.effective_end_date
  ,p_concatenated_segments        => l_UpdEmpAsg_out.concatenated_segments
  ,p_no_managers_warning          => l_UpdEmpAsg_out.no_managers_warning
  ,p_other_manager_warning        => l_UpdEmpAsg_out.other_manager_warning
  ,p_hourly_salaried_warning      => l_UpdEmpAsg_out.hourly_salaried_warning
  ,p_gsp_post_process_warning     => l_UpdEmpAsg_out.gsp_post_process_warning
  );

/*
  ,p_contract_id                  =>
  ,p_establishment_id             =>
  ,p_collective_agreement_id      =>
  ,p_cagr_id_flex_num             =>
  ,p_cag_segment1                 =>
  ,p_cag_segment2                 =>
  ,p_cag_segment3                 =>
  ,p_cag_segment4                 =>
  ,p_cag_segment5                 =>
  ,p_cag_segment6                 =>
  ,p_cag_segment7                 =>
  ,p_cag_segment8                 =>
  ,p_cag_segment9                 =>
  ,p_cag_segment10                =>
  ,p_cag_segment11                =>
  ,p_cag_segment12                =>
  ,p_cag_segment13                =>
  ,p_cag_segment14                =>
  ,p_cag_segment15                =>
  ,p_cag_segment16                =>
  ,p_cag_segment17                =>
  ,p_cag_segment18                =>
  ,p_cag_segment19                =>
  ,p_cag_segment20                =>
  ,p_notice_period                =>
  ,p_notice_period_uom            =>
  ,p_employee_category            =>
  ,p_work_at_home                 =>
  ,p_job_post_source_name         =>
  ,p_supervisor_assignment_id     =>

   -- Out Variables
  ,p_cagr_grade_def_id

  ,p_concatenated_segments        => p_updasg_api_out.concatenated_segments
  ,p_soft_coding_keyflex_id       => NVL(l_asg_rec.soft_coding_keyflex_id
                                        ,l_cur_asg_rec.soft_coding_keyflex_id
  ,p_cagr_concatenated_segments      OUT nocopy Varchar2
  ,p_comment_id                   => p_updasg_api_out.comment_id
  ,p_effective_start_date         => p_updasg_api_out.effective_start_date
  ,p_effective_end_date           => p_updasg_api_out.effective_end_date
  ,p_no_managers_warning          => p_updasg_api_out.no_managers_warning
  ,p_other_manager_warning        => p_updasg_api_out.other_manager_warning
  ,p_hourly_salaried_warning      => p_updasg_api_out.hourly_salaried_warning
  ,p_gsp_post_process_warning     => p_updasg_api_out.gsp_post_process_warning
  )*/

  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

EXCEPTION
  WHEN e_empasg_notfound  THEN
   l_error_msg :=
              'Employee Assignment could not be found as of the effective date';
   hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   hr_utility.set_message_token('GENERIC_TOKEN',l_error_msg );
   hr_utility.set_location('Leaving: ' || l_proc_name, 90);
   hr_utility.raise_error;

  WHEN Others THEN
   l_error_msg := SQLERRM;
   hr_utility.set_location('SQLCODE :' || SQLCODE,100);
   hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   hr_utility.set_message_token('GENERIC_TOKEN',l_error_msg );
   hr_utility.set_location('Leaving: ' || l_proc_name, 100);
   hr_utility.raise_error;

END Update_StuEmpAsg_Criteria;

-- =============================================================================
-- ~ InsUpd_Address:
-- =============================================================================
PROCEDURE InsUpd_Address
          (p_effective_date           IN Date
          ,p_HR_address_id            OUT NOCOPY Number
          ,p_HR_object_version_number OUT NOCOPY Number ) AS

  CURSOR csr_add (c_person_id         IN Number
                 ,c_business_group_id IN Number
                 ,c_effective_date    IN Date
                 ,c_primary_flag      IN Varchar2) IS
  SELECT *
    FROM per_addresses pad
   WHERE pad.person_id = c_person_id
     AND pad.business_group_id = c_business_group_id
     AND pad.primary_flag = c_primary_flag
     AND c_effective_date BETWEEN pad.date_from
                              AND NVL(pad.date_to, c_effective_date);
  l_cur_add_rec            per_addresses%ROWTYPE;
  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'InsUpd_Address';
  l_error_msg              Varchar2(2000);

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  OPEN  csr_add(c_person_id         => l_add_rec.person_id
               ,c_business_group_id => l_add_rec.business_group_id
               ,c_effective_date    => p_effective_date
               ,c_primary_flag      => NVL(l_add_rec.primary_flag,'Y'));
  FETCH csr_add INTO l_cur_add_rec;

  IF csr_add%NOTFOUND THEN
     hr_utility.set_location(' Primary Address Not found', 20);
     Pqp_Hrtca_Integration.Person_Address_Api
     (p_HR_Address_Rec           => l_add_rec
     ,p_validate                 => FALSE
     ,p_action                   => 'CREATE'
     ,p_effective_date           => p_effective_date
     ,p_pradd_ovlapval_override  => FALSE
     ,p_primary_flag             => 'Y'
     ,p_validate_county          => TRUE
     ,p_HR_address_id            => l_add_rec.address_id
     ,p_HR_object_version_number => l_add_rec.object_version_number);
  ELSE
     hr_utility.set_location(' Primary Address found: ' ||
                               l_cur_add_rec.address_id, 30);

     IF Trunc(l_cur_add_rec.date_from) = Trunc(p_effective_date) THEN
        l_add_rec.address_id := l_cur_add_rec.address_id;
        l_add_rec.object_version_number := l_cur_add_rec.object_version_number;
        l_add_rec.style := l_cur_add_rec.style;
        Pqp_Hrtca_Integration.Person_Address_Api
        (p_HR_Address_Rec           => l_add_rec
        ,p_validate                 => FALSE
        ,p_action                   => 'UPDATE'
        ,p_effective_date           => p_effective_date
        ,p_pradd_ovlapval_override  => FALSE
        ,p_primary_flag             => 'Y'
        ,p_validate_county          => TRUE
        ,p_HR_address_id            => l_add_rec.address_id
        ,p_HR_object_version_number => l_add_rec.object_version_number);

     ELSIF Trunc(p_effective_date) > Trunc(l_cur_add_rec.date_from) THEN
        hr_utility.set_location(' l_add_rec.date_from: ' ||
	                          l_add_rec.date_from, 40);
        hr_utility.set_location(' l_add_rec.date_to: ' ||
	                          l_add_rec.date_to, 40);
        Pqp_Hrtca_Integration.Person_Address_Api
        (p_HR_Address_Rec           => l_add_rec
        ,p_validate                 => FALSE
        ,p_action                   => 'CREATE'
        ,p_effective_date           => p_effective_date
        ,p_pradd_ovlapval_override  => TRUE
        ,p_primary_flag             => 'Y'
        ,p_validate_county          => TRUE
        ,p_HR_address_id            => l_add_rec.address_id
        ,p_HR_object_version_number => l_add_rec.object_version_number);
     END IF;
  END IF;
  CLOSE csr_add;

  hr_utility.set_location('Leaving: ' || l_proc_name, 50);

EXCEPTION
   WHEN Others THEN
   IF  csr_add%ISOPEN THEN
    CLOSE csr_add;
   END IF;
   l_error_msg := Substr(SQLERRM,1,2000);
   hr_utility.set_location('SQLCODE :' || SQLCODE,60);
   hr_utility.set_location('SQLERRM :' || SQLERRM,60);
   hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   hr_utility.set_message_token('GENERIC_TOKEN',l_error_msg );
   hr_utility.set_location('Leaving: ' || l_proc_name, 60);
   hr_utility.raise_error;

END InsUpd_Address;

-- =============================================================================
-- ~ Hire_Applicant_IntoEmp:
-- =============================================================================
PROCEDURE Hire_Applicant_IntoEmp
         (p_validate            Boolean  DEFAULT FALSE
         ,p_hire_date           Date
         ,p_person_id           Number
         ,p_assignment_id       Number
         ,p_adjusted_svc_date   Date     DEFAULT NULL
         ,p_updper_api_out      OUT NOCOPY t_UpdEmp_Api
         ,p_HireAppapi_out      OUT NOCOPY t_HrApp_Api
         ) AS

  CURSOR csr_asg (c_person_id IN Number
                 ,c_business_group_id IN Number
                 ,c_effective_date IN DATE
                 ,c_asg_type IN Varchar2
                 ,c_assignment_id IN Number) IS
  SELECT paf.assignment_id
        ,ppf.person_id
        ,ppf.object_version_number per_ovn
        ,paf.object_version_number asg_ovn
    FROM per_all_assignments_f paf
        ,per_all_people_f      ppf
   WHERE paf.person_id = c_person_id
     AND paf.business_group_id = c_business_group_id
     AND paf.assignment_type = c_asg_type
     AND paf.assignment_id = c_assignment_id
     AND paf.person_id = ppf.person_id
     AND c_effective_date BETWEEN ppf.effective_start_date
                              AND ppf.effective_end_date
     AND c_effective_date BETWEEN paf.effective_start_date
                              AND paf.effective_end_date;

  l_perasg_rec             csr_asg%ROWTYPE;
  l_cur_per_rec            csr_per%ROWTYPE;
  l_accpetd_asg_rec        csr_accepted_asgs%ROWTYPE;
  l_asg_status_rec         csr_asg_status%ROWTYPE;
  l_datetrack_update_mode  Varchar2(50);
  l_dt_correction          Boolean;
  l_dt_update              Boolean;
  l_dt_upd_override        Boolean;
  l_upd_chg_ins            Boolean;
  l_error_msg              Varchar2(2000);
  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Hire_Applicant_IntoEmp';
  l_assignment_id          Number;
  l_appl_asg_start_date    Date;
  l_appl_asg_end_date      Date;
  l_accp_asg_count         Number;
  l_hire_all_accepted_asgs Varchar2(3);
  l_not_accp_asg_count     Number;
  l_tot_appl_asgs          Number;
  l_effective_date         Date;
  l_unaccepted_asg_del_warning Boolean;

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  g_debug := hr_utility.debug_enabled;
  l_effective_date := p_hire_date;

  -- Get the person details for the person
  OPEN  csr_per(c_person_id         => l_per_rec.person_id
               ,c_business_group_id => l_per_rec.business_group_id
               ,c_effective_date    => l_effective_date);
  FETCH csr_per INTO l_cur_per_rec;
  CLOSE csr_per;
  hr_utility.set_location(' l_cur_per_rec: ' || l_cur_per_rec.person_id, 20);

  -- Get the Applicant assignment details
  OPEN  csr_asg (c_person_id         => l_per_rec.person_id
                ,c_business_group_id => l_per_rec.business_group_id
                ,c_effective_date    => l_effective_date
                ,c_asg_type          => 'A'
                ,c_assignment_id     => p_assignment_id);
  FETCH csr_asg INTO l_perasg_rec;
  CLOSE csr_asg;

  IF g_debug THEN
   hr_utility.set_location(' l_perasg_rec.person_id: ' ||
                             l_perasg_rec.person_id, 30);
   hr_utility.set_location(' l_perasg_rec.asg_id: ' ||
                             l_perasg_rec.assignment_id, 30);
   hr_utility.set_location(' l_perasg_rec.person_ovn: ' ||
                             l_perasg_rec.per_ovn, 30);
   hr_utility.set_location(' l_perasg_rec.asg_ovn: ' ||
                             l_perasg_rec.asg_ovn, 30);
   hr_utility.set_location(' l_effective_date: ' ||
                             l_effective_date, 30);
  END IF;
  l_accp_asg_count := 0;
  FOR accp_ags IN csr_accepted_asgs
                 (c_person_id         => l_per_rec.person_id
                 ,c_business_group_id => l_per_rec.business_group_id
                 ,c_effective_date    => l_effective_date
                 ,c_assignment_id     => p_assignment_id)
  LOOP
    l_accp_asg_count := l_accp_asg_count +1;
  END LOOP;

  IF l_accp_asg_count < 1 THEN
    -- Means the Applicant Assignment is not accepted, so update the applicant
    -- as accepted as of the hire date.
    hr_utility.set_location(' Asg Id NOT Accepted : ' || p_assignment_id, 40);
    Dt_Api.Find_DT_Upd_Modes
    (p_effective_date        => p_hire_date
    ,p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F'
    ,p_base_key_column       => 'ASSIGNMENT_ID'
    ,p_base_key_value        => p_assignment_id
    ,p_correction            => l_dt_correction
    ,p_update                => l_dt_update
    ,p_update_override       => l_dt_upd_override
    ,p_update_change_insert  => l_upd_chg_ins
     );

    -- Get the date-track mode
    IF l_dt_update THEN
       l_datetrack_update_mode := 'UPDATE';
    ELSIF l_dt_upd_override OR
          l_upd_chg_ins THEN
          -- Need to check if person has future asgs changes, if yes
          -- then raise error
          NULL;
    ELSE
       l_datetrack_update_mode := 'CORRECTION';
    END IF;
    hr_utility.set_location(' DT Mode for Update of Appl Asg : ' ||
                              l_datetrack_update_mode, 50);

    -- Get the Accepted Applicant Status Id
    OPEN csr_asg_status (c_leg_code          => g_leg_code
                        ,c_business_group_id => l_per_rec.business_group_id
                        );
    FETCH csr_asg_status INTO l_asg_status_rec;
    CLOSE csr_asg_status;
    hr_utility.set_location(' Accepted Asg Status ID: ' ||
                              l_asg_status_rec.assignment_status_type_id, 60);

    -- Now accept the Applicant assigment used to hire the person
    HR_Assignment_API.Accept_APL_Asg
    (p_validate                    => False
    ,p_effective_date              => l_effective_date-1
    ,p_datetrack_update_mode       => l_datetrack_update_mode
    ,p_assignment_id               => p_assignment_id
    ,p_object_version_number       => l_perasg_rec.asg_ovn
    ,p_assignment_status_type_id   => l_asg_status_rec.assignment_status_type_id
    ,p_change_reason               => Null
    ,p_effective_start_date        => l_appl_asg_start_date
    ,p_effective_end_date          => l_appl_asg_end_date
    );
    IF g_debug THEN
     hr_utility.set_location(' l_appl_asg_start_date: ' ||
                               l_appl_asg_start_date, 70);
     hr_utility.set_location(' l_appl_asg_end_date: ' ||
                               l_appl_asg_end_date, 70);
     hr_utility.set_location(' l_perasg_rec.asg_ovn: ' ||
                               l_perasg_rec.asg_ovn, 70);
    END IF;

    -- Get again the person details for the person
    OPEN  csr_per(c_person_id         => l_per_rec.person_id
                 ,c_business_group_id => l_per_rec.business_group_id
                 ,c_effective_date    => l_effective_date);
    FETCH csr_per INTO l_cur_per_rec;
    CLOSE csr_per;
    hr_utility.set_location(' per_rec.ovn: ' ||
                              l_cur_per_rec.object_version_number, 80);
  ELSE
    hr_utility.set_location(' Asg Id Accepted Already: ' ||
                              p_assignment_id, 90);
  END IF;

  -- Get the count of accepted Applicant Assignments
  l_accp_asg_count := 0;
  FOR accp_ags IN csr_accepted_asgs
                 (c_person_id         => l_per_rec.person_id
                 ,c_business_group_id => l_per_rec.business_group_id
                 ,c_effective_date    => l_effective_date
                 ,c_assignment_id     => Null)
  LOOP
    l_accp_asg_count := l_accp_asg_count +1;
  END LOOP;

  -- Get the count of not accepted Applicant Assignments
  l_not_accp_asg_count := 0;
  FOR accp_ags IN csr_not_accepted_asgs
                 (c_person_id         => l_per_rec.person_id
                 ,c_business_group_id => l_per_rec.business_group_id
                 ,c_effective_date    => l_effective_date
                 ,c_assignment_id     => Null)
  LOOP
    l_not_accp_asg_count := l_not_accp_asg_count +1;
  END LOOP;
  -- Get the total no. of Applicant assignments
  l_tot_appl_asgs := l_accp_asg_count + l_not_accp_asg_count;

  IF l_tot_appl_asgs = 1 THEN
     l_hire_all_accepted_asgs := 'Y';
  ELSIF l_tot_appl_asgs > 2 THEN
     l_hire_all_accepted_asgs := 'N';
  END IF;

  -- Now get the date-track mode to update the person as an employee
  Dt_Api.Find_DT_Upd_Modes
  (p_effective_date        => l_effective_date
  ,p_base_table_name       => 'PER_ALL_PEOPLE_F'
  ,p_base_key_column       => 'PERSON_ID'
  ,p_base_key_value        => l_cur_per_rec.person_id
  ,p_correction            => l_dt_correction
  ,p_update                => l_dt_update
  ,p_update_override       => l_dt_upd_override
  ,p_update_change_insert  => l_upd_chg_ins
   );

  -- If person has future changes, like becomes CWK, APL i.e. any person
  -- type changes then raise an error, saying that the person has future
  -- dated changes.
  IF l_dt_update THEN
     l_datetrack_update_mode := 'UPDATE';
  ELSIF l_dt_upd_override OR
        l_upd_chg_ins THEN
        -- Need to check if person type in future is EMP, APL or CWK , if yes
        -- then raise error
        NULL;
  ELSE
     l_datetrack_update_mode := 'CORRECTION';
  END IF;

  hr_utility.set_location(' l_datetrack_update_mode: ' ||
                            l_datetrack_update_mode, 100);
  l_per_rec.object_version_number := l_cur_per_rec.object_version_number;
  IF l_tot_appl_asgs = 1 THEN
     -- As the person has only one applicant assignment then hire person so that
     -- the person type now becomes EMP
     HR_Applicant_API.Hire_Applicant
     (p_validate                  => FALSE
     ,p_hire_date                 => l_effective_date
     ,p_person_id                 => l_cur_per_rec.person_id
     ,p_assignment_id             => p_assignment_id
     ,p_person_type_id            => l_per_rec.person_type_id
     ,p_per_object_version_number => l_cur_per_rec.object_version_number
     ,p_employee_number           => l_per_rec.employee_number
     ,p_per_effective_start_date  => p_HireAppapi_out.effective_start_date
     ,p_per_effective_end_date    => p_HireAppapi_out.effective_end_date
     ,p_unaccepted_asg_del_warning => l_unaccepted_asg_del_warning
     ,p_assign_payroll_warning    => p_HireAppapi_out.assign_payroll_warning
     ,p_original_date_of_hire     => NULL
     ,p_migrate                   => TRUE
     );
  ELSE
     -- Now hire the person ONLY for the accepted applicant assignment, so that
     -- person type would be EMP_APL
     HR_Employee_Applicant_API.Hire_to_Employee_Applicant
     (p_validate                  => FALSE
     ,p_hire_date                 => l_effective_date
     ,p_person_id                 => l_cur_per_rec.person_id
     ,p_per_object_version_number => l_cur_per_rec.object_version_number
     ,p_person_type_id            => l_per_rec.person_type_id
     ,p_hire_all_accepted_asgs    => l_hire_all_accepted_asgs
     ,p_assignment_id             => p_assignment_id
     ,p_national_identifier       => l_per_rec.national_identifier
     ,p_employee_number           => l_per_rec.employee_number
     ,p_per_effective_start_date  => p_HireAppapi_out.effective_start_date
     ,p_per_effective_end_date    => p_HireAppapi_out.effective_end_date
     ,p_assign_payroll_warning    => p_HireAppapi_out.assign_payroll_warning
     ,p_oversubscribed_vacancy_id => p_HireAppapi_out.oversubscribed_vacancy_id
     );
    END IF;

  -- Get the new employee assignment created after the person is hired
  OPEN  csr_asg (c_person_id         => l_cur_per_rec.person_id
                ,c_business_group_id => l_per_rec.business_group_id
                ,c_effective_date    => p_HireAppapi_out.effective_start_date
                ,c_asg_type          => 'E'
                ,c_assignment_id     => p_assignment_id);
  FETCH csr_asg INTO l_perasg_rec;
  CLOSE csr_asg;
  l_per_rec.object_version_number := l_perasg_rec.per_ovn;

  -- Get the person record after he is hired
  OPEN  csr_per(c_person_id         => l_per_rec.person_id
               ,c_business_group_id => l_per_rec.business_group_id
               ,c_effective_date    => l_effective_date);
  FETCH csr_per INTO l_cur_per_rec;
  CLOSE csr_per;

  IF g_debug_on THEN
    hr_utility.set_location('..effective_start_date      : ' ||
                             p_HireAppapi_out.effective_start_date, 110);
    hr_utility.set_location('..effective_end_date        : ' ||
                             p_HireAppapi_out.effective_end_date, 110);
    hr_utility.set_location('..Old:object_version_number : ' ||
                             l_cur_per_rec.object_version_number, 110);
  END IF;
  l_datetrack_update_mode := 'CORRECTION';

  Hr_Person_Api.Update_Person
  (p_validate                     => p_validate
  ,p_effective_date               => p_hire_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_person_id                    => l_cur_per_rec.person_id
  ,p_party_id                     => l_per_rec.party_id
  ,p_object_version_number        => l_cur_per_rec.object_version_number
  ,p_employee_number              => l_per_rec.employee_number
  ,p_last_name                    => NVL(l_per_rec.last_name
                                        ,l_cur_per_rec.last_name)
  ,p_first_name                   => NVL(l_per_rec.first_name
                                        ,l_cur_per_rec.first_name)
  ,p_date_of_birth                => NVL(l_per_rec.date_of_birth
                                        ,l_cur_per_rec.date_of_birth)
  ,p_marital_status               => NVL(l_per_rec.marital_status
                                        ,l_cur_per_rec.marital_status)
  ,p_middle_names                 => NVL(l_per_rec.middle_names
                                        ,l_cur_per_rec.middle_names)
  ,p_sex                          => NVL(l_per_rec.sex
                                        ,l_cur_per_rec.sex)
  ,p_title                        => NVL(l_per_rec.title
                                        ,l_cur_per_rec.title)
  ,p_nationality                  => NVL(l_per_rec.nationality
                                        ,l_cur_per_rec.nationality)
  ,p_previous_last_name           => NVL(l_per_rec.previous_last_name
                                        ,l_cur_per_rec.previous_last_name)
  ,p_known_as                     => NVL(l_per_rec.known_as
                                        ,l_cur_per_rec.known_as)
  ,p_email_address                => NVL(l_per_rec.email_address
                                        ,l_cur_per_rec.email_address)
  ,p_registered_disabled_flag     => NVL(l_per_rec.registered_disabled_flag
                                        ,l_cur_per_rec.registered_disabled_flag)
  ,p_date_employee_data_verified  => NVL(l_per_rec.date_employee_data_verified
                                    ,l_cur_per_rec.date_employee_data_verified)
  ,p_expense_check_send_to_addres => NVL(l_per_rec.expense_check_send_to_address
                                   ,l_cur_per_rec.expense_check_send_to_address)
  ,p_per_information_category     => l_per_rec.per_information_category
  ,p_per_information1             => l_per_rec.per_information1
  ,p_per_information2             => l_per_rec.per_information2
  ,p_per_information3             => l_per_rec.per_information3
  ,p_per_information4             => l_per_rec.per_information4
  ,p_per_information5             => l_per_rec.per_information5
  ,p_per_information6             => l_per_rec.per_information6
  ,p_per_information7             => l_per_rec.per_information7
  ,p_per_information8             => l_per_rec.per_information8
  ,p_per_information9             => l_per_rec.per_information9
  ,p_per_information10            => l_per_rec.per_information10
  ,p_per_information11            => l_per_rec.per_information11
  ,p_per_information12            => l_per_rec.per_information12
  ,p_per_information13            => l_per_rec.per_information13
  ,p_per_information14            => l_per_rec.per_information14
  ,p_per_information15            => l_per_rec.per_information15
  ,p_per_information16            => l_per_rec.per_information16
  ,p_per_information17            => l_per_rec.per_information17
  ,p_per_information18            => l_per_rec.per_information18
  ,p_per_information19            => l_per_rec.per_information19
  ,p_per_information20            => l_per_rec.per_information20
  ,p_per_information21            => l_per_rec.per_information21
  ,p_per_information22            => l_per_rec.per_information22
  ,p_per_information23            => l_per_rec.per_information23
  ,p_per_information24            => l_per_rec.per_information24
  ,p_per_information25            => l_per_rec.per_information25
  ,p_per_information26            => l_per_rec.per_information26
  ,p_per_information27            => l_per_rec.per_information27
  ,p_per_information28            => l_per_rec.per_information28
  ,p_per_information29            => l_per_rec.per_information29
  ,p_per_information30            => l_per_rec.per_information30
  -- Person DF
  ,p_attribute_category           => l_per_rec.attribute_category
  ,p_attribute1                   => l_per_rec.attribute1
  ,p_attribute2                   => l_per_rec.attribute2
  ,p_attribute3                   => l_per_rec.attribute3
  ,p_attribute4                   => l_per_rec.attribute4
  ,p_attribute5                   => l_per_rec.attribute5
  ,p_attribute6                   => l_per_rec.attribute6
  ,p_attribute7                   => l_per_rec.attribute7
  ,p_attribute8                   => l_per_rec.attribute8
  ,p_attribute9                   => l_per_rec.attribute9
  ,p_attribute10                  => l_per_rec.attribute10
  ,p_attribute11                  => l_per_rec.attribute11
  ,p_attribute12                  => l_per_rec.attribute12
  ,p_attribute13                  => l_per_rec.attribute13
  ,p_attribute14                  => l_per_rec.attribute14
  ,p_attribute15                  => l_per_rec.attribute15
  ,p_attribute16                  => l_per_rec.attribute16
  ,p_attribute17                  => l_per_rec.attribute17
  ,p_attribute18                  => l_per_rec.attribute18
  ,p_attribute19                  => l_per_rec.attribute19
  ,p_attribute20                  => l_per_rec.attribute20
  ,p_attribute21                  => l_per_rec.attribute21
  ,p_attribute22                  => l_per_rec.attribute22
  ,p_attribute23                  => l_per_rec.attribute23
  ,p_attribute24                  => l_per_rec.attribute24
  ,p_attribute25                  => l_per_rec.attribute25
  ,p_attribute26                  => l_per_rec.attribute26
  ,p_attribute27                  => l_per_rec.attribute27
  ,p_attribute28                  => l_per_rec.attribute28
  ,p_attribute29                  => l_per_rec.attribute29
  ,p_attribute30                  => l_per_rec.attribute30
  ,p_date_of_death                => NVL(l_per_rec.date_of_death
                                        ,l_cur_per_rec.date_of_death)
  ,p_background_check_status      => NVL(l_per_rec.background_check_status
                                        ,l_cur_per_rec.background_check_status)
  ,p_background_date_check        => NVL(l_per_rec.background_date_check
                                        ,l_cur_per_rec.background_date_check)
  ,p_blood_type                   => NVL(l_per_rec.blood_type
                                        ,l_cur_per_rec.blood_type)
  ,p_correspondence_language      => NVL(l_per_rec.correspondence_language
                                        ,l_cur_per_rec.correspondence_language)
  ,p_fte_capacity                 => NVL(l_per_rec.fte_capacity
                                        ,l_cur_per_rec.fte_capacity)
  ,p_hold_applicant_date_until    => NVL(l_per_rec.hold_applicant_date_until
                                    ,l_cur_per_rec.hold_applicant_date_until)
  ,p_honors                       => NVL(l_per_rec.honors
                                        ,l_cur_per_rec.honors)
  ,p_internal_location            => NVL(l_per_rec.internal_location
                                        ,l_cur_per_rec.internal_location)
  ,p_last_medical_test_by         => NVL(l_per_rec.last_medical_test_by
                                        ,l_cur_per_rec.last_medical_test_by)
  ,p_last_medical_test_date       => NVL(l_per_rec.last_medical_test_date
                                        ,l_cur_per_rec.last_medical_test_date)
  ,p_mailstop                     => NVL(l_per_rec.mailstop
                                        ,l_cur_per_rec.mailstop)
  ,p_office_number                => NVL(l_per_rec.office_number
                                        ,l_cur_per_rec.office_number)
  ,p_on_military_service          => NVL(l_per_rec.on_military_service
                                        ,l_cur_per_rec.on_military_service)
  ,p_pre_name_adjunct             => NVL(l_per_rec.pre_name_adjunct
                                        ,l_cur_per_rec.pre_name_adjunct)
  ,p_projected_start_date         => NVL(l_per_rec.projected_start_date
                                        ,l_cur_per_rec.projected_start_date)
  ,p_rehire_authorizor            => NVL(l_per_rec.rehire_authorizor
                                        ,l_cur_per_rec.rehire_authorizor)
  ,p_rehire_recommendation        => NVL(l_per_rec.rehire_recommendation
                                        ,l_cur_per_rec.rehire_recommendation)
  ,p_resume_exists                => NVL(l_per_rec.resume_exists
                                        ,l_cur_per_rec.resume_exists )
  ,p_resume_last_updated          => NVL(l_per_rec.resume_last_updated
                                        ,l_cur_per_rec.resume_last_updated)
  ,p_second_passport_exists       => NVL(l_per_rec.second_passport_exists
                                        ,l_cur_per_rec.second_passport_exists)
  ,p_student_status               => NVL(l_per_rec.student_status
                                        ,l_cur_per_rec.student_status)
  ,p_work_schedule                => NVL(l_per_rec.work_schedule
                                        ,l_cur_per_rec.work_schedule)
  ,p_rehire_reason                => NVL(l_per_rec.rehire_reason
                                        ,l_cur_per_rec.rehire_reason)
  ,p_suffix                       => NVL(l_per_rec.suffix
                                        ,l_cur_per_rec.suffix)
  ,p_benefit_group_id             => NVL(l_per_rec.benefit_group_id
                                        ,l_cur_per_rec.benefit_group_id)
  ,p_receipt_of_death_cert_date   => NVL(l_per_rec.receipt_of_death_cert_date
                                    ,l_cur_per_rec.receipt_of_death_cert_date)
  ,p_coord_ben_med_pln_no         => NVL(l_per_rec.coord_ben_med_pln_no
                                        ,l_cur_per_rec.coord_ben_med_pln_no)
  ,p_coord_ben_no_cvg_flag        => NVL(l_per_rec.coord_ben_no_cvg_flag
                                        ,l_cur_per_rec.coord_ben_no_cvg_flag)
  ,p_coord_ben_med_ext_er         => NVL(l_per_rec.coord_ben_med_ext_er
                                        ,l_cur_per_rec.coord_ben_med_ext_er)
  ,p_coord_ben_med_pl_name        => NVL(l_per_rec.coord_ben_med_pl_name
                                        ,l_cur_per_rec.coord_ben_med_pl_name)
  ,p_coord_ben_med_insr_crr_name  => NVL(l_per_rec.coord_ben_med_insr_crr_name
                                    ,l_cur_per_rec.coord_ben_med_insr_crr_name)
  ,p_coord_ben_med_insr_crr_ident => NVL(l_per_rec.coord_ben_med_insr_crr_ident
                                    ,l_cur_per_rec.coord_ben_med_insr_crr_ident)
  ,p_coord_ben_med_cvg_strt_dt    => NVL(l_per_rec.coord_ben_med_cvg_strt_dt
                                    ,l_cur_per_rec.coord_ben_med_cvg_strt_dt)
  ,p_coord_ben_med_cvg_end_dt     => NVL(l_per_rec.coord_ben_med_cvg_end_dt
                                    ,l_cur_per_rec.coord_ben_med_cvg_end_dt)
  ,p_uses_tobacco_flag            => NVL(l_per_rec.uses_tobacco_flag
                                        ,l_cur_per_rec.uses_tobacco_flag)
  ,p_dpdnt_adoption_date          => NVL(l_per_rec.dpdnt_adoption_date
                                        ,l_cur_per_rec.dpdnt_adoption_date)
  ,p_dpdnt_vlntry_svce_flag       => NVL(l_per_rec.dpdnt_vlntry_svce_flag
                                        ,l_cur_per_rec.dpdnt_vlntry_svce_flag)
  ,p_original_date_of_hire        => NVL(l_per_rec.original_date_of_hire
                                        ,l_cur_per_rec.original_date_of_hire)
  ,p_adjusted_svc_date            => p_adjusted_svc_date
  ,p_town_of_birth                => NVL(l_per_rec.town_of_birth
                                        ,l_cur_per_rec.town_of_birth)
  ,p_region_of_birth              => NVL(l_per_rec.region_of_birth
                                        ,l_cur_per_rec.region_of_birth)
  ,p_country_of_birth             => NVL(l_per_rec.country_of_birth
                                        ,l_cur_per_rec.country_of_birth)
  ,p_global_person_id             => NVL(l_per_rec.global_person_id
                                        ,l_cur_per_rec.global_person_id)
  --Out Variables
  ,p_effective_start_date         => p_updper_api_out.effective_start_date
  ,p_effective_end_date           => p_updper_api_out.effective_end_date
  ,p_full_name                    => p_updper_api_out.full_name
  ,p_comment_id                   => p_updper_api_out.comment_id
  ,p_name_combination_warning     => p_updper_api_out.name_combination_warning
  ,p_assign_payroll_warning       => p_updper_api_out.assign_payroll_warning
  ,p_orig_hire_warning            => p_updper_api_out.orig_hire_warning
  );

  IF g_debug_on THEN
    hr_utility.set_location('..effective_start_date : ' ||
                             p_updper_api_out.effective_start_date, 120);
    hr_utility.set_location('..effective_end_date   : ' ||
                             p_updper_api_out.effective_end_date, 120);
    hr_utility.set_location('..full_name            : ' ||
                             p_updper_api_out.full_name, 120);
    hr_utility.set_location('Leaving: ' || l_proc_name, 120);
  END IF;

EXCEPTION
  WHEN Others THEN
    IF csr_asg%ISOPEN THEN
      CLOSE csr_asg;
    END IF;
    IF csr_per%ISOPEN THEN
      CLOSE csr_per;
    END IF;
    IF csr_asg_status%ISOPEN THEN
      CLOSE csr_asg_status;
    END IF;
    l_error_msg := Substr(SQLERRM,1,2000);
    hr_utility.set_location('SQLCODE :' || SQLCODE, 130);
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    hr_utility.set_location('Leaving: ' || l_proc_name, 130);
    hr_utility.raise_error;

END Hire_Applicant_IntoEmp;

-- =============================================================================
-- ~ Hire_Person_IntoEmp:
-- =============================================================================
PROCEDURE Hire_Person_IntoEmp
         (p_validate            Boolean  DEFAULT FALSE
         ,p_hire_date           Date
         ,p_person_id           Number
         ,p_adjusted_svc_date   Date     DEFAULT NULL
         ,p_updper_api_out      OUT NOCOPY t_UpdEmp_Api
         ,p_HireToJobapi_out    OUT NOCOPY t_HrToJob_Api
         ) AS
  CURSOR csr_asg (c_person_id IN Number
                 ,c_business_group_id IN Number
                 ,c_effective_date IN Date) IS
  SELECT paf.assignment_id,
         ppf.object_version_number
    FROM per_all_assignments_f paf
        ,per_all_people_f      ppf
   WHERE paf.person_id = c_person_id
     AND paf.business_group_id = c_business_group_id
     AND paf.person_id = ppf.person_id
     AND paf.assignment_type = 'E'
     AND c_effective_date BETWEEN ppf.effective_start_date
                              AND ppf.effective_end_date
     AND c_effective_date BETWEEN paf.effective_start_date
                              AND paf.effective_end_date;

  l_cur_per_rec            csr_per%ROWTYPE;
  l_ptu_rec                chk_perType_usage%ROWTYPE;
  l_datetrack_update_mode  Varchar2(50);
  l_dt_correction          Boolean;
  l_dt_update              Boolean;
  l_dt_upd_override        Boolean;
  l_upd_chg_ins            Boolean;
  l_error_msg              Varchar2(2000);
  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Hire_Person_IntoEmp';
  e_future_chgs_exists     Exception;
BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  OPEN  csr_per(c_person_id         => l_per_rec.person_id
               ,c_business_group_id => l_per_rec.business_group_id
               ,c_effective_date    => p_hire_date);
  FETCH csr_per INTO l_cur_per_rec;
  CLOSE csr_per;
  hr_utility.set_location(' l_cur_per_rec: ' || l_cur_per_rec.person_id, 20);

  Dt_Api.Find_DT_Upd_Modes
  (p_effective_date        => p_hire_date
  ,p_base_table_name       => 'PER_ALL_PEOPLE_F'
  ,p_base_key_column       => 'PERSON_ID'
  ,p_base_key_value        => l_cur_per_rec.person_id
  ,p_correction            => l_dt_correction
  ,p_update                => l_dt_update
  ,p_update_override       => l_dt_upd_override
  ,p_update_change_insert  => l_upd_chg_ins
   );

  IF l_dt_update THEN
     l_datetrack_update_mode := 'UPDATE';
  ELSIF l_dt_upd_override OR
        l_upd_chg_ins THEN
        -- Need to check if person type in future is EMP, APL or CWK , if yes
        -- then raise error
        OPEN chk_perType_usage
           (c_person_id         => l_cur_per_rec.person_id
           ,c_effective_date    => p_hire_date
           ,c_business_group_id => l_per_rec.business_group_id);
        FETCH chk_perType_usage INTO l_ptu_rec;
        IF chk_perType_usage%FOUND THEN
           Close chk_perType_usage;
           RAISE e_future_chgs_exists;
        END IF;
        Close chk_perType_usage;
  ELSE
     l_datetrack_update_mode := 'CORRECTION';
  END IF;

  hr_utility.set_location('l_datetrack_update_mode: ' ||
                           l_datetrack_update_mode, 30);
  l_per_rec.object_version_number := l_cur_per_rec.object_version_number;

  Hr_Employee_Api.Hire_Into_Job
  (p_validate               => FALSE
  ,p_effective_date         => p_hire_date
  ,p_person_id              => l_cur_per_rec.person_id
  ,p_object_version_number  => l_cur_per_rec.object_version_number
  ,p_employee_number        => l_per_rec.employee_number
  ,p_datetrack_update_mode  => l_datetrack_update_mode
  ,p_person_type_id         => l_per_rec.person_type_id
  ,p_national_identifier    => l_per_rec.national_identifier
  ,p_per_information7       => l_per_rec.per_information7
  -- Out Variables
  ,p_effective_start_date   => p_HireToJobapi_out.effective_start_date
  ,p_effective_end_date     => p_HireToJobapi_out.effective_end_date
  ,p_assign_payroll_warning => p_HireToJobapi_out.assign_payroll_warning
  ,p_orig_hire_warning      => p_HireToJobapi_out.orig_hire_warning
  );
  -- Get the new assignment created after the person is hired
  OPEN  csr_asg (c_person_id         => l_cur_per_rec.person_id
                ,c_business_group_id => l_per_rec.business_group_id
                ,c_effective_date    =>p_HireToJobapi_out.effective_start_date);
  FETCH csr_asg INTO p_HireToJobapi_out.assignment_id
                    ,l_per_rec.object_version_number;
  CLOSE csr_asg;
  -- Get the person record after he is hired
  OPEN  csr_per(c_person_id         => l_per_rec.person_id
               ,c_business_group_id => l_per_rec.business_group_id
               ,c_effective_date    => p_hire_date);
  FETCH csr_per INTO l_cur_per_rec;
  CLOSE csr_per;

  IF g_debug_on THEN
    hr_utility.set_location('..effective_start_date      : ' ||
                             p_HireToJobapi_out.effective_start_date,40);
    hr_utility.set_location('..effective_end_date        : ' ||
                             p_HireToJobapi_out.effective_end_date,40);
    hr_utility.set_location('..New:object_version_number : ' ||
                             l_per_rec.object_version_number,40);
    hr_utility.set_location('..Old:object_version_number : ' ||
                             l_cur_per_rec.object_version_number,40);
    hr_utility.set_location('..New:Assignment Id         : ' ||
                             p_HireToJobapi_out.assignment_id,40);
  END IF;
  l_datetrack_update_mode := 'CORRECTION';

  Hr_Person_Api.Update_Person
  (p_validate                     => p_validate
  ,p_effective_date               => p_hire_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_person_id                    => l_cur_per_rec.person_id
  ,p_party_id                     => l_per_rec.party_id
  ,p_object_version_number        => l_per_rec.object_version_number
  ,p_employee_number              => l_per_rec.employee_number
  ,p_last_name                    => NVL(l_per_rec.last_name
                                        ,l_cur_per_rec.last_name)
  ,p_first_name                   => NVL(l_per_rec.first_name
                                        ,l_cur_per_rec.first_name)
  ,p_date_of_birth                => NVL(l_per_rec.date_of_birth
                                        ,l_cur_per_rec.date_of_birth)
  ,p_marital_status               => NVL(l_per_rec.marital_status
                                        ,l_cur_per_rec.marital_status)
  ,p_middle_names                 => NVL(l_per_rec.middle_names
                                        ,l_cur_per_rec.middle_names)
  ,p_sex                          => NVL(l_per_rec.sex
                                        ,l_cur_per_rec.sex)
  ,p_title                        => NVL(l_per_rec.title
                                        ,l_cur_per_rec.title)
  ,p_nationality                  => NVL(l_per_rec.nationality
                                        ,l_cur_per_rec.nationality)
  ,p_previous_last_name           => NVL(l_per_rec.previous_last_name
                                        ,l_cur_per_rec.previous_last_name)
  ,p_known_as                     => NVL(l_per_rec.known_as
                                        ,l_cur_per_rec.known_as)
  ,p_email_address                => NVL(l_per_rec.email_address
                                        ,l_cur_per_rec.email_address)
  ,p_registered_disabled_flag     => NVL(l_per_rec.registered_disabled_flag
                                    ,l_cur_per_rec.registered_disabled_flag)
  ,p_date_employee_data_verified  => NVL(l_per_rec.date_employee_data_verified
                                    ,l_cur_per_rec.date_employee_data_verified)
  ,p_expense_check_send_to_addres =>NVL(l_per_rec.expense_check_send_to_address
                                   ,l_cur_per_rec.expense_check_send_to_address)
  ,p_per_information_category     => l_per_rec.per_information_category
  ,p_per_information1             => l_per_rec.per_information1
  ,p_per_information2             => l_per_rec.per_information2
  ,p_per_information3             => l_per_rec.per_information3
  ,p_per_information4             => l_per_rec.per_information4
  ,p_per_information5             => l_per_rec.per_information5
  ,p_per_information6             => l_per_rec.per_information6
  ,p_per_information7             => l_per_rec.per_information7
  ,p_per_information8             => l_per_rec.per_information8
  ,p_per_information9             => l_per_rec.per_information9
  ,p_per_information10            => l_per_rec.per_information10
  ,p_per_information11            => l_per_rec.per_information11
  ,p_per_information12            => l_per_rec.per_information12
  ,p_per_information13            => l_per_rec.per_information13
  ,p_per_information14            => l_per_rec.per_information14
  ,p_per_information15            => l_per_rec.per_information15
  ,p_per_information16            => l_per_rec.per_information16
  ,p_per_information17            => l_per_rec.per_information17
  ,p_per_information18            => l_per_rec.per_information18
  ,p_per_information19            => l_per_rec.per_information19
  ,p_per_information20            => l_per_rec.per_information20
  ,p_per_information21            => l_per_rec.per_information21
  ,p_per_information22            => l_per_rec.per_information22
  ,p_per_information23            => l_per_rec.per_information23
  ,p_per_information24            => l_per_rec.per_information24
  ,p_per_information25            => l_per_rec.per_information25
  ,p_per_information26            => l_per_rec.per_information26
  ,p_per_information27            => l_per_rec.per_information27
  ,p_per_information28            => l_per_rec.per_information28
  ,p_per_information29            => l_per_rec.per_information29
  ,p_per_information30            => l_per_rec.per_information30
  -- Person DF
  ,p_attribute_category           => l_per_rec.attribute_category
  ,p_attribute1                   => l_per_rec.attribute1
  ,p_attribute2                   => l_per_rec.attribute2
  ,p_attribute3                   => l_per_rec.attribute3
  ,p_attribute4                   => l_per_rec.attribute4
  ,p_attribute5                   => l_per_rec.attribute5
  ,p_attribute6                   => l_per_rec.attribute6
  ,p_attribute7                   => l_per_rec.attribute7
  ,p_attribute8                   => l_per_rec.attribute8
  ,p_attribute9                   => l_per_rec.attribute9
  ,p_attribute10                  => l_per_rec.attribute10
  ,p_attribute11                  => l_per_rec.attribute11
  ,p_attribute12                  => l_per_rec.attribute12
  ,p_attribute13                  => l_per_rec.attribute13
  ,p_attribute14                  => l_per_rec.attribute14
  ,p_attribute15                  => l_per_rec.attribute15
  ,p_attribute16                  => l_per_rec.attribute16
  ,p_attribute17                  => l_per_rec.attribute17
  ,p_attribute18                  => l_per_rec.attribute18
  ,p_attribute19                  => l_per_rec.attribute19
  ,p_attribute20                  => l_per_rec.attribute20
  ,p_attribute21                  => l_per_rec.attribute21
  ,p_attribute22                  => l_per_rec.attribute22
  ,p_attribute23                  => l_per_rec.attribute23
  ,p_attribute24                  => l_per_rec.attribute24
  ,p_attribute25                  => l_per_rec.attribute25
  ,p_attribute26                  => l_per_rec.attribute26
  ,p_attribute27                  => l_per_rec.attribute27
  ,p_attribute28                  => l_per_rec.attribute28
  ,p_attribute29                  => l_per_rec.attribute29
  ,p_attribute30                  => l_per_rec.attribute30
  ,p_date_of_death                => NVL(l_per_rec.date_of_death
                                        ,l_cur_per_rec.date_of_death)
  ,p_background_check_status      => NVL(l_per_rec.background_check_status
                                        ,l_cur_per_rec.background_check_status)
  ,p_background_date_check        => NVL(l_per_rec.background_date_check
                                        ,l_cur_per_rec.background_date_check)
  ,p_blood_type                   => NVL(l_per_rec.blood_type
                                        ,l_cur_per_rec.blood_type)
  ,p_correspondence_language      => NVL(l_per_rec.correspondence_language
                                        ,l_cur_per_rec.correspondence_language)
  ,p_fte_capacity                 => NVL(l_per_rec.fte_capacity
                                        ,l_cur_per_rec.fte_capacity)
  ,p_hold_applicant_date_until    => NVL(l_per_rec.hold_applicant_date_until
                                       ,l_cur_per_rec.hold_applicant_date_until)
  ,p_honors                       => NVL(l_per_rec.honors
                                        ,l_cur_per_rec.honors)
  ,p_internal_location            => NVL(l_per_rec.internal_location
                                        ,l_cur_per_rec.internal_location)
  ,p_last_medical_test_by         => NVL(l_per_rec.last_medical_test_by
                                        ,l_cur_per_rec.last_medical_test_by)
  ,p_last_medical_test_date       => NVL(l_per_rec.last_medical_test_date
                                        ,l_cur_per_rec.last_medical_test_date)
  ,p_mailstop                     => NVL(l_per_rec.mailstop
                                        ,l_cur_per_rec.mailstop)
  ,p_office_number                => NVL(l_per_rec.office_number
                                        ,l_cur_per_rec.office_number)
  ,p_on_military_service          => NVL(l_per_rec.on_military_service
                                        ,l_cur_per_rec.on_military_service)
  ,p_pre_name_adjunct             => NVL(l_per_rec.pre_name_adjunct
                                        ,l_cur_per_rec.pre_name_adjunct)
  ,p_projected_start_date         => NVL(l_per_rec.projected_start_date
                                        ,l_cur_per_rec.projected_start_date)
  ,p_rehire_authorizor            => NVL(l_per_rec.rehire_authorizor
                                        ,l_cur_per_rec.rehire_authorizor)
  ,p_rehire_recommendation        => NVL(l_per_rec.rehire_recommendation
                                        ,l_cur_per_rec.rehire_recommendation)
  ,p_resume_exists                => NVL(l_per_rec.resume_exists
                                        ,l_cur_per_rec.resume_exists )
  ,p_resume_last_updated          => NVL(l_per_rec.resume_last_updated
                                        ,l_cur_per_rec.resume_last_updated)
  ,p_second_passport_exists       => NVL(l_per_rec.second_passport_exists
                                        ,l_cur_per_rec.second_passport_exists)
  ,p_student_status               => NVL(l_per_rec.student_status
                                        ,l_cur_per_rec.student_status)
  ,p_work_schedule                => NVL(l_per_rec.work_schedule
                                        ,l_cur_per_rec.work_schedule)
  ,p_rehire_reason                => NVL(l_per_rec.rehire_reason
                                        ,l_cur_per_rec.rehire_reason)
  ,p_suffix                       => NVL(l_per_rec.suffix
                                        ,l_cur_per_rec.suffix)
  ,p_benefit_group_id             => NVL(l_per_rec.benefit_group_id
                                        ,l_cur_per_rec.benefit_group_id)
  ,p_receipt_of_death_cert_date   => NVL(l_per_rec.receipt_of_death_cert_date
                                      ,l_cur_per_rec.receipt_of_death_cert_date)
  ,p_coord_ben_med_pln_no         => NVL(l_per_rec.coord_ben_med_pln_no
                                        ,l_cur_per_rec.coord_ben_med_pln_no)
  ,p_coord_ben_no_cvg_flag        => NVL(l_per_rec.coord_ben_no_cvg_flag
                                        ,l_cur_per_rec.coord_ben_no_cvg_flag)
  ,p_coord_ben_med_ext_er         => NVL(l_per_rec.coord_ben_med_ext_er
                                        ,l_cur_per_rec.coord_ben_med_ext_er)
  ,p_coord_ben_med_pl_name        => NVL(l_per_rec.coord_ben_med_pl_name
                                        ,l_cur_per_rec.coord_ben_med_pl_name)
  ,p_coord_ben_med_insr_crr_name  => NVL(l_per_rec.coord_ben_med_insr_crr_name
                                     ,l_cur_per_rec.coord_ben_med_insr_crr_name)
  ,p_coord_ben_med_insr_crr_ident => NVL(l_per_rec.coord_ben_med_insr_crr_ident
                                    ,l_cur_per_rec.coord_ben_med_insr_crr_ident)
  ,p_coord_ben_med_cvg_strt_dt    => NVL(l_per_rec.coord_ben_med_cvg_strt_dt
                                       ,l_cur_per_rec.coord_ben_med_cvg_strt_dt)
  ,p_coord_ben_med_cvg_end_dt     => NVL(l_per_rec.coord_ben_med_cvg_end_dt
                                        ,l_cur_per_rec.coord_ben_med_cvg_end_dt)
  ,p_uses_tobacco_flag            => NVL(l_per_rec.uses_tobacco_flag
                                        ,l_cur_per_rec.uses_tobacco_flag)
  ,p_dpdnt_adoption_date          => NVL(l_per_rec.dpdnt_adoption_date
                                        ,l_cur_per_rec.dpdnt_adoption_date)
  ,p_dpdnt_vlntry_svce_flag       => NVL(l_per_rec.dpdnt_vlntry_svce_flag
                                        ,l_cur_per_rec.dpdnt_vlntry_svce_flag)
  ,p_original_date_of_hire        => NVL(l_per_rec.original_date_of_hire
                                        ,l_cur_per_rec.original_date_of_hire)
  ,p_adjusted_svc_date            => p_adjusted_svc_date
  ,p_town_of_birth                => NVL(l_per_rec.town_of_birth
                                        ,l_cur_per_rec.town_of_birth)
  ,p_region_of_birth              => NVL(l_per_rec.region_of_birth
                                        ,l_cur_per_rec.region_of_birth)
  ,p_country_of_birth             => NVL(l_per_rec.country_of_birth
                                        ,l_cur_per_rec.country_of_birth)
  ,p_global_person_id             => NVL(l_per_rec.global_person_id
                                        ,l_cur_per_rec.global_person_id)
  --Out Variables
  ,p_effective_start_date         => p_updper_api_out.effective_start_date
  ,p_effective_end_date           => p_updper_api_out.effective_end_date
  ,p_full_name                    => p_updper_api_out.full_name
  ,p_comment_id                   => p_updper_api_out.comment_id
  ,p_name_combination_warning     => p_updper_api_out.name_combination_warning
  ,p_assign_payroll_warning       => p_updper_api_out.assign_payroll_warning
  ,p_orig_hire_warning            => p_updper_api_out.orig_hire_warning
  );
  IF g_debug_on THEN
    hr_utility.set_location('..effective_start_date : ' ||
                             p_updper_api_out.effective_start_date, 50);
    hr_utility.set_location('..effective_end_date   : ' ||
                             p_updper_api_out.effective_end_date, 50);
    hr_utility.set_location('..full_name            : ' ||
                             p_updper_api_out.full_name, 50);
    hr_utility.set_location('Leaving: ' || l_proc_name, 50);
  END IF;

EXCEPTION
  WHEN e_future_chgs_exists THEN
    l_error_msg := 'This person cannot be created in HRMS as a Student '||
                   'Employee due to future changes beyond the date: '||p_hire_date;

    hr_utility.set_location('..Future Update exists for the Student Employee', 60);
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    hr_utility.set_location('Leaving: ' || l_proc_name, 60);
    hr_utility.raise_error;

  WHEN Others THEN
   IF csr_asg%ISOPEN THEN
     CLOSE csr_asg;
   END IF;
   IF csr_per%ISOPEN THEN
     CLOSE csr_per;
   END IF;
   l_error_msg := Substr(SQLERRM,1,2000);
   hr_utility.set_location('SQLCODE :' || SQLCODE,90);
   hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   hr_utility.set_message_token('GENERIC_TOKEN',l_error_msg );
   hr_utility.set_location('Leaving: ' || l_proc_name, 90);
   hr_utility.raise_error;

END Hire_Person_IntoEmp;

-- =============================================================================
-- ~ Rehire_EmpIn_HRMS: don't use, will remove it later.
-- =============================================================================
PROCEDURE Rehire_EmpIn_HRMS
         (p_validate            Boolean  DEFAULT FALSE
         ,p_rehire_date         Date
         ,p_person_id           Number
         ,p_adjusted_svc_date   Date     DEFAULT NULL
         ,p_rehire_api_out      OUT NOCOPY t_RehireEmp_Api
         ,p_updper_api_out      OUT NOCOPY t_UpdEmp_Api
         ) AS

  l_cur_per_rec            csr_per%ROWTYPE;
  l_datetrack_update_mode  Varchar2(50);
  l_dt_correction          Boolean;
  l_dt_update              Boolean;
  l_dt_upd_override        Boolean;
  l_upd_chg_ins            Boolean;

  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Rehire_EmpIn_HRMS';

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  OPEN  csr_per(c_person_id         => l_per_rec.person_id
               ,c_business_group_id => l_per_rec.business_group_id
               ,c_effective_date    => p_rehire_date);
  FETCH csr_per INTO l_cur_per_rec;
  CLOSE csr_per;
  hr_utility.set_location(' l_cur_asg_rec: ' || l_cur_per_rec.person_id, 20);
  Dt_Api.Find_DT_Upd_Modes
  (p_effective_date        => p_rehire_date
  ,p_base_table_name       => 'PER_ALL_PEOPLE_F'
  ,p_base_key_column       => 'PERSON_ID'
  ,p_base_key_value        => l_cur_per_rec.person_id
  ,p_correction            => l_dt_correction
  ,p_update                => l_dt_update
  ,p_update_override       => l_dt_upd_override
  ,p_update_change_insert  => l_upd_chg_ins
   );

  IF NOT(l_dt_update AND
         l_dt_upd_override AND
         l_upd_chg_ins) THEN
     l_datetrack_update_mode := 'CORRECTION';
  ELSIF l_dt_update THEN
     l_datetrack_update_mode := 'UPDATE';
  ELSIF l_dt_upd_override OR
        l_upd_chg_ins THEN
        -- Need to check if person type in future is EMP, APL or CWK , if yes
        -- then raise error
        NULL;
  END IF;
  hr_utility.set_location(' l_datetrack_update_mode: ' ||
                            l_cur_per_rec.person_id, 30);

  Hr_Employee_Api.re_hire_ex_employee
  (p_validate                      => p_validate
  ,p_hire_date                     => p_rehire_date
  ,p_person_id                     => l_cur_per_rec.person_id
  ,p_person_type_id                => l_per_rec.person_type_id
  ,p_rehire_reason                 => NULL
  ,p_per_object_version_number     => l_cur_per_rec.object_version_number
  -- Out Variables
  ,p_assignment_id                 => p_rehire_api_out.assignment_id
  ,p_asg_object_version_number     => p_rehire_api_out.asg_object_version_number
  ,p_per_effective_start_date      => p_rehire_api_out.per_effective_start_date
  ,p_per_effective_end_date        => p_rehire_api_out.per_effective_end_date
  ,p_assignment_sequence           => p_rehire_api_out.assignment_sequence
  ,p_assignment_number             => p_rehire_api_out.assignment_number
  ,p_assign_payroll_warning        => p_rehire_api_out.assign_payroll_warning
  );
  hr_utility.set_location('.. assignment_id            : ' ||
                           p_rehire_api_out.assignment_id,40);
  hr_utility.set_location('.. object_version_number    : ' ||
                           p_rehire_api_out.asg_object_version_number,40);
  hr_utility.set_location('.. per_effective_start_date : ' ||
                           p_rehire_api_out.per_effective_start_date,40);
  hr_utility.set_location('.. per_effective_end_date   : ' ||
                           p_rehire_api_out.per_effective_end_date,40);
  hr_utility.set_location('.. assignment_sequence      : ' ||
                           p_rehire_api_out.assignment_sequence,40);
  hr_utility.set_location('.. assignment_number        : ' ||
                           p_rehire_api_out.assignment_number,40);
  hr_utility.set_location('.. Employee Re-hired        : ' ||
                           l_cur_per_rec.person_id, 40);

  l_per_rec.employee_number := NVL(l_per_rec.employee_number
                                  ,l_cur_per_rec.employee_number);
  l_datetrack_update_mode   := 'CORRECTION';

  Hr_Person_Api.Update_Person
  (p_validate                     => p_validate
  ,p_effective_date               => p_rehire_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_person_id                    => l_cur_per_rec.person_id
  ,p_party_id                     => l_per_rec.party_id
  ,p_object_version_number        => l_cur_per_rec.object_version_number
  ,p_person_type_id               => l_per_rec.person_type_id
  ,p_employee_number              => l_per_rec.employee_number
  ,p_last_name                    => NVL(l_per_rec.last_name
                                        ,l_cur_per_rec.last_name)
  ,p_first_name                   => NVL(l_per_rec.first_name
                                        ,l_cur_per_rec.first_name)
  ,p_date_of_birth                => NVL(l_per_rec.date_of_birth
                                        ,l_cur_per_rec.date_of_birth)
  ,p_marital_status               => NVL(l_per_rec.marital_status
                                        ,l_cur_per_rec.marital_status)
  ,p_middle_names                 => NVL(l_per_rec.middle_names
                                        ,l_cur_per_rec.middle_names)
  ,p_sex                          => NVL(l_per_rec.sex
                                        ,l_cur_per_rec.sex)
  ,p_title                        => NVL(l_per_rec.title
                                        ,l_cur_per_rec.title)
  ,p_nationality                  => NVL(l_per_rec.nationality
                                        ,l_cur_per_rec.nationality)
  ,p_national_identifier          => NVL(l_per_rec.national_identifier
                                        ,l_cur_per_rec.national_identifier)
  ,p_previous_last_name           => NVL(l_per_rec.previous_last_name
                                        ,l_cur_per_rec.previous_last_name)
  ,p_known_as                     => NVL(l_per_rec.known_as
                                        ,l_cur_per_rec.known_as)
  ,p_registered_disabled_flag     => NVL(l_per_rec.registered_disabled_flag
                                        ,l_cur_per_rec.registered_disabled_flag)
/*
  ,p_applicant_number             =>
  ,p_comments                     =>
*/
  ,p_date_employee_data_verified  => NVL(l_per_rec.date_employee_data_verified
                                     ,l_cur_per_rec.date_employee_data_verified)
  ,p_email_address                => NVL(l_per_rec.email_address
                                        ,l_cur_per_rec.email_address)

  ,p_expense_check_send_to_addres => NVL(l_per_rec.expense_check_send_to_address
                                   ,l_cur_per_rec.expense_check_send_to_address)
   -- Person DDF
/*
  ,p_per_information_category     IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information1             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information2             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information3             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information4             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information5             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information6             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information7             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information8             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information9             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information10            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information11            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information12            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information13            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information14            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information15            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information16            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information17            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information18            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information19            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information20            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information21            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information22            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information23            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information24            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information25            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information26            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information27            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information28            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information29            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_per_information30            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  -- Person DF
  ,p_attribute_category           IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute1                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute2                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute3                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute4                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute5                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute6                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute7                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute8                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute9                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute10                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute11                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute12                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute13                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute14                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute15                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute16                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute17                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute18                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute19                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute20                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute21                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute22                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute23                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute24                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute25                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute26                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute27                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute28                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute29                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_attribute30                  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2

  ,p_vendor_id                    IN      NUMBER   DEFAULT Hr_Api.g_number
  ,p_work_telephone               IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_date_of_death                IN      DATE     DEFAULT Hr_Api.g_date
  ,p_background_check_status      IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_background_date_check        IN      DATE     DEFAULT Hr_Api.g_date
  ,p_blood_type                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_correspondence_language      IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_fast_path_employee           IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_fte_capacity                 IN      NUMBER   DEFAULT Hr_Api.g_number
  ,p_hold_applicant_date_until    IN      DATE     DEFAULT Hr_Api.g_date
  ,p_honors                       IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_internal_location            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_last_medical_test_by         IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_last_medical_test_date       IN      DATE     DEFAULT Hr_Api.g_date
  ,p_mailstop                     IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_office_number                IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_on_military_service          IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_pre_name_adjunct             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_projected_start_date         IN      DATE     DEFAULT Hr_Api.g_date
  ,p_rehire_authorizor            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_rehire_recommendation        IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_resume_exists                IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_resume_last_updated          IN      DATE     DEFAULT Hr_Api.g_date
  ,p_second_passport_exists       IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_student_status               IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_work_schedule                IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_rehire_reason                IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_suffix                       IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_benefit_group_id             IN      NUMBER   DEFAULT Hr_Api.g_number
  ,p_receipt_of_death_cert_date   IN      DATE     DEFAULT Hr_Api.g_date
  ,p_coord_ben_med_pln_no         IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_coord_ben_no_cvg_flag        IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_coord_ben_med_ext_er         IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_coord_ben_med_pl_name        IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_coord_ben_med_insr_crr_name  IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_coord_ben_med_insr_crr_ident IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_coord_ben_med_cvg_strt_dt    IN      DATE     DEFAULT Hr_Api.g_date
  ,p_coord_ben_med_cvg_end_dt     IN      DATE     DEFAULT Hr_Api.g_date
  ,p_uses_tobacco_flag            IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_dpdnt_adoption_date          IN      DATE     DEFAULT Hr_Api.g_date
  ,p_dpdnt_vlntry_svce_flag       IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_original_date_of_hire        IN      DATE     DEFAULT Hr_Api.g_date
  ,p_adjusted_svc_date            IN      DATE     DEFAULT Hr_Api.g_date
  ,p_town_of_birth                IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_region_of_birth              IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_country_of_birth             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_global_person_id             IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  ,p_npw_number                   IN      Varchar2 DEFAULT Hr_Api.g_Varchar2
  */
  ,p_effective_start_date         => p_updper_api_out.effective_start_date
  ,p_effective_end_date           => p_updper_api_out.effective_end_date
  ,p_full_name                    => p_updper_api_out.full_name
  ,p_comment_id                   => p_updper_api_out.comment_id
  ,p_name_combination_warning     => p_updper_api_out.name_combination_warning
  ,p_assign_payroll_warning       => p_updper_api_out.assign_payroll_warning
  ,p_orig_hire_warning            => p_updper_api_out.orig_hire_warning
  );

  hr_utility.set_location('.. effective_start_date : ' ||
                           p_updper_api_out.effective_start_date, 50);
  hr_utility.set_location('.. effective_end_date   : ' ||
                           p_updper_api_out.effective_end_date, 50);
  hr_utility.set_location('.. full_name            : ' ||
                           p_updper_api_out.full_name, 50);

  hr_utility.set_location('Leaving: ' || l_proc_name, 50);

EXCEPTION
  WHEN Others THEN
  hr_utility.set_location('Leaving: ' || l_proc_name, 60);
  RAISE;

END Rehire_EmpIn_HRMS;

-- =============================================================================
-- ~ Create_EmpIn_HRMS:
-- =============================================================================
PROCEDURE Create_EmpIn_HRMS
         (p_validate            Boolean  DEFAULT FALSE
         ,p_effective_date      Date
         ,p_adjusted_svc_date   Date     DEFAULT NULL
         ,p_per_comments        Varchar2 DEFAULT NULL
         ,p_emp_api_out         OUT NOCOPY t_hrEmpApi)AS

  l_person_id                  per_all_people_f.person_id%TYPE;
  l_assignment_id              per_all_assignments_f.assignment_id%TYPE;
  l_per_object_version_number  per_all_people_f.object_version_number%TYPE;
  l_asg_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_per_effective_start_date   Date;
  l_per_effective_end_date     Date;
  l_full_name                  per_all_people_f.full_name%TYPE;
  l_per_comment_id             per_all_people_f.comment_id%TYPE;
  l_assignment_sequence        per_all_assignments_f.assignment_sequence%TYPE;
  l_assignment_number          per_all_assignments_f.assignment_number%TYPE;
  l_name_combination_warning   Boolean;
  l_assign_payroll_warning     Boolean;
  l_orig_hire_warning          Boolean;

  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Create_EmpIn_HRMS';

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  IF g_emp_num_gen <> 'M' THEN
     l_per_rec.employee_number := Null;
  END IF;

  Hr_Employee_Api.Create_Employee
  (p_validate                     => p_validate
  ,p_hire_date                    => l_per_rec.start_date
  ,p_business_group_id            => l_per_rec.business_group_id
  ,p_last_name                    => l_per_rec.last_name
  ,p_sex                          => l_per_rec.sex
  ,p_person_type_id               => l_per_rec.person_type_id
  ,p_per_comments                 => p_per_comments
  ,p_date_employee_data_verified  => l_per_rec.date_employee_data_verified
  ,p_date_of_birth                => l_per_rec.date_of_birth
  ,p_email_address                => l_per_rec.email_address
  ,p_employee_number              => l_per_rec.employee_number
  ,p_expense_check_send_to_addres => l_per_rec.expense_check_send_to_address
  ,p_first_name                   => l_per_rec.first_name
  ,p_known_as                     => l_per_rec.known_as
  ,p_marital_status               => l_per_rec.marital_status
  ,p_middle_names                 => l_per_rec.middle_names
  ,p_nationality                  => l_per_rec.nationality
  ,p_national_identifier          => l_per_rec.national_identifier
  ,p_previous_last_name           => l_per_rec.previous_last_name
  ,p_registered_disabled_flag     => l_per_rec.registered_disabled_flag
  ,p_title                        => l_per_rec.title
  ,p_vendor_id                    => l_per_rec.vendor_id
  ,p_attribute_category           => l_per_rec.attribute_category
  ,p_attribute1                   => l_per_rec.attribute1
  ,p_attribute2                   => l_per_rec.attribute2
  ,p_attribute3                   => l_per_rec.attribute3
  ,p_attribute4                   => l_per_rec.attribute4
  ,p_attribute5                   => l_per_rec.attribute5
  ,p_attribute6                   => l_per_rec.attribute6
  ,p_attribute7                   => l_per_rec.attribute7
  ,p_attribute8                   => l_per_rec.attribute8
  ,p_attribute9                   => l_per_rec.attribute9
  ,p_attribute10                  => l_per_rec.attribute10
  ,p_attribute11                  => l_per_rec.attribute11
  ,p_attribute12                  => l_per_rec.attribute12
  ,p_attribute13                  => l_per_rec.attribute13
  ,p_attribute14                  => l_per_rec.attribute14
  ,p_attribute15                  => l_per_rec.attribute15
  ,p_attribute16                  => l_per_rec.attribute16
  ,p_attribute17                  => l_per_rec.attribute17
  ,p_attribute18                  => l_per_rec.attribute18
  ,p_attribute19                  => l_per_rec.attribute19
  ,p_attribute20                  => l_per_rec.attribute20
  ,p_attribute21                  => l_per_rec.attribute21
  ,p_attribute22                  => l_per_rec.attribute22
  ,p_attribute23                  => l_per_rec.attribute23
  ,p_attribute24                  => l_per_rec.attribute24
  ,p_attribute25                  => l_per_rec.attribute25
  ,p_attribute26                  => l_per_rec.attribute26
  ,p_attribute27                  => l_per_rec.attribute27
  ,p_attribute28                  => l_per_rec.attribute28
  ,p_attribute29                  => l_per_rec.attribute29
  ,p_attribute30                  => l_per_rec.attribute30
  ,p_per_information_category     => l_per_rec.per_information_category
  ,p_per_information1             => l_per_rec.per_information1
  ,p_per_information2             => l_per_rec.per_information2
  ,p_per_information3             => l_per_rec.per_information3
  ,p_per_information4             => l_per_rec.per_information4
  ,p_per_information5             => l_per_rec.per_information5
  ,p_per_information6             => l_per_rec.per_information6
  ,p_per_information7             => l_per_rec.per_information7
  ,p_per_information8             => l_per_rec.per_information8
  ,p_per_information9             => l_per_rec.per_information9
  ,p_per_information10            => l_per_rec.per_information10
  ,p_per_information11            => l_per_rec.per_information11
  ,p_per_information12            => l_per_rec.per_information12
  ,p_per_information13            => l_per_rec.per_information13
  ,p_per_information14            => l_per_rec.per_information14
  ,p_per_information15            => l_per_rec.per_information15
  ,p_per_information16            => l_per_rec.per_information16
  ,p_per_information17            => l_per_rec.per_information17
  ,p_per_information18            => l_per_rec.per_information18
  ,p_per_information19            => l_per_rec.per_information19
  ,p_per_information20            => l_per_rec.per_information20
  ,p_per_information21            => l_per_rec.per_information21
  ,p_per_information22            => l_per_rec.per_information22
  ,p_per_information23            => l_per_rec.per_information23
  ,p_per_information24            => l_per_rec.per_information24
  ,p_per_information25            => l_per_rec.per_information25
  ,p_per_information26            => l_per_rec.per_information26
  ,p_per_information27            => l_per_rec.per_information27
  ,p_per_information28            => l_per_rec.per_information28
  ,p_per_information29            => l_per_rec.per_information29
  ,p_per_information30            => l_per_rec.per_information30
  ,p_date_of_death                => l_per_rec.date_of_death
  ,p_background_check_status      => l_per_rec.background_check_status
  ,p_background_date_check        => l_per_rec.background_date_check
  ,p_blood_type                   => l_per_rec.blood_type
  ,p_correspondence_language      => l_per_rec.correspondence_language
  ,p_fast_path_employee           => l_per_rec.fast_path_employee
  ,p_fte_capacity                 => l_per_rec.fte_capacity
  ,p_honors                       => l_per_rec.honors
  ,p_internal_location            => l_per_rec.internal_location
  ,p_last_medical_test_by         => l_per_rec.last_medical_test_by
  ,p_last_medical_test_date       => l_per_rec.last_medical_test_date
  ,p_mailstop                     => l_per_rec.mailstop
  ,p_office_number                => l_per_rec.office_number
  ,p_on_military_service          => l_per_rec.on_military_service
  ,p_pre_name_adjunct             => l_per_rec.pre_name_adjunct
  ,p_rehire_recommendation        => l_per_rec.rehire_recommendation
  ,p_projected_start_date         => l_per_rec.projected_start_date
  ,p_resume_exists                => l_per_rec.resume_exists
  ,p_resume_last_updated          => l_per_rec.resume_last_updated
  ,p_second_passport_exists       => l_per_rec.second_passport_exists
  ,p_student_status               => l_per_rec.student_status
  ,p_work_schedule                => l_per_rec.work_schedule
  ,p_suffix                       => l_per_rec.suffix
  ,p_benefit_group_id             => l_per_rec.benefit_group_id
  ,p_receipt_of_death_cert_date   => l_per_rec.receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no         => l_per_rec.coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        => l_per_rec.coord_ben_no_cvg_flag
  ,p_coord_ben_med_ext_er         => l_per_rec.coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name        => l_per_rec.coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name  => l_per_rec.coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident => l_per_rec.coord_ben_med_insr_crr_ident
  ,p_coord_ben_med_cvg_strt_dt    => l_per_rec.coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt     => l_per_rec.coord_ben_med_cvg_end_dt
  ,p_uses_tobacco_flag            => l_per_rec.uses_tobacco_flag
  ,p_dpdnt_adoption_date          => l_per_rec.dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag       => l_per_rec.dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire        => l_per_rec.original_date_of_hire
  ,p_adjusted_svc_date            => p_adjusted_svc_date
  ,p_town_of_birth                => l_per_rec.town_of_birth
  ,p_region_of_birth              => l_per_rec.region_of_birth
  ,p_country_of_birth             => l_per_rec.country_of_birth
  ,p_global_person_id             => l_per_rec.global_person_id
  ,p_party_id                     => l_per_rec.party_id
  -- Out Variables
  ,p_person_id                    => p_emp_api_out.person_id
  ,p_assignment_id                => p_emp_api_out.assignment_id
  ,p_per_object_version_number    => p_emp_api_out.per_object_version_number
  ,p_asg_object_version_number    => p_emp_api_out.asg_object_version_number
  ,p_per_effective_start_date     => p_emp_api_out.per_effective_start_date
  ,p_per_effective_end_date       => p_emp_api_out.per_effective_end_date
  ,p_full_name                    => p_emp_api_out.full_name
  ,p_per_comment_id               => p_emp_api_out.per_comment_id
  ,p_assignment_sequence          => p_emp_api_out.assignment_sequence
  ,p_assignment_number            => p_emp_api_out.assignment_number
  ,p_name_combination_warning     => p_emp_api_out.name_combination_warning
  ,p_assign_payroll_warning       => p_emp_api_out.assign_payroll_warning
  ,p_orig_hire_warning            => p_emp_api_out.orig_hire_warning
  );

  l_per_rec.person_id             := p_emp_api_out.person_id;
  l_per_rec.object_version_number := p_emp_api_out.per_object_version_number;
  l_per_rec.effective_start_date  := p_emp_api_out.per_effective_start_date;
  l_per_rec.effective_end_date    := p_emp_api_out.per_effective_end_date;

  IF g_debug_on THEN
    hr_utility.set_location('..person_id                 : ' ||
                             p_emp_api_out.person_id,20);
    hr_utility.set_location('..assignment_id             : ' ||
                             p_emp_api_out.assignment_id,20);
    hr_utility.set_location('..per_object_version_number : ' ||
                             p_emp_api_out.per_object_version_number,20);
    hr_utility.set_location('..asg_object_version_number : ' ||
                             p_emp_api_out.asg_object_version_number,20);
    hr_utility.set_location('..per_effective_start_date  : ' ||
                             p_emp_api_out.per_effective_start_date,20);
    hr_utility.set_location('..per_effective_end_date    : ' ||
                             p_emp_api_out.per_effective_end_date,20);
    hr_utility.set_location('..full_name                 : ' ||
                             p_emp_api_out.full_name,20);
    hr_utility.set_location('..per_comment_id            : ' ||
                             p_emp_api_out.per_comment_id,20);
    hr_utility.set_location('..assignment_sequence       : ' ||
                             p_emp_api_out.assignment_sequence,20);
    hr_utility.set_location('..assignment_number         : ' ||
                             p_emp_api_out.assignment_number,20);
  END IF;

  hr_utility.set_location('Leaving: ' || l_proc_name, 30);

EXCEPTION
  WHEN Others THEN
  hr_utility.set_location('Leaving: ' || l_proc_name, 40);
  RAISE;

END Create_EmpIn_HRMS;


-- =============================================================================
-- ~ HR_DataPump_Per_XtraInfo:
-- =============================================================================
PROCEDURE HR_DataPump_Per_XtraInfo
         (p_business_group_id IN Number
         ,p_person_id         IN Number
         ,p_party_id          IN Number
         ,p_effective_date    IN Date
         ,p_batch_id          IN Number
         ,p_user_sequence     IN Number
         ,p_link_value        IN Number
         ,p_xtra_info_key     IN Varchar2
         ,p_person_user_key   IN Varchar2
         ) AS

  -- Existing OSS Person Details
  CURSOR csr_OSS_pe (c_person_id         IN Number
                    ,c_information_type  IN Varchar2) IS
  SELECT pei.pei_information1
        ,pei.pei_information2
        ,pei.pei_information3
        ,pei.pei_information4
        ,pei.pei_information5
        ,pei.object_version_number
        ,pei.person_extra_info_id
    FROM per_people_extra_info pei
   WHERE pei.person_id        = c_person_id
     AND pei.information_type = c_information_type;

  l_OSS_pe             csr_oss_pe%ROWTYPE;

  -- Get Party Number
  CURSOR hz_pe (c_party_id IN Number) IS
  SELECT hzp.party_number
    FROM hz_parties hzp
   WHERE hzp.party_id = c_party_id;

   -- OSS Person Record
  TYPE oss_per_rec IS RECORD
   ( person_id_type      Varchar2(150)
    ,api_person_id       Varchar2(150)
    ,person_number       Varchar2(150)
    ,system_type         Varchar2(150)
    );

  TYPE csr_oss_t  IS REF CURSOR;

  SQLstmt                 Varchar2(2000);
  csr_igs                 csr_oss_t;
  l_oss_per_details       oss_per_rec;
  l_oss_person_details    per_people_extra_info.information_type%TYPE;
  l_person_extra_info_rec per_people_extra_info%ROWTYPE;
  --
  l_proc_name CONSTANT  Varchar2(150) := g_pkg ||'HR_DataPump_Per_XtraInfo';
  --

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  SAVEPOINT oss_per_dtls;

  l_oss_person_details    := 'PQP_OSS_PERSON_DETAILS';
  l_person_extra_info_rec := NULL;

  --
  SQLstmt:=
  '   SELECT igp.person_id_type  ' ||
  '         ,igp.api_person_id   ' ||
  '         ,igp.person_number   ' ||
  '         ,ipt.system_type     ' ||
  '     FROM igs_pe_person_v igp ' ||
  '         ,igs_pe_typ_instances_all pti ' ||
  '         ,igs_pe_person_types      ipt ' ||
  '    WHERE igp.person_id = :c_party_id  ' ||
  '      AND pti.person_type_code = ipt.person_type_code ' ||
  '      AND pti.person_id = igp.person_id ' ||
  '      AND ipt.system_type IN ('||'''STUDENT'''||',' ||
                                '''FACULTY'''||','||'''OTHER''' ||')' ;

  -- Create the OSS Person EIT information
  hr_utility.set_location(' Creating: PQP_OSS_PERSON_DETAILS', 20);

  l_person_extra_info_rec.information_type         := l_oss_person_details;
  l_person_extra_info_rec.pei_information_category := l_oss_person_details;

  -- =====================================================================
  -- OSS Person Type -(R)      = PEI_INFORMATION1
  -- OSS Person Number -(R)    = PEI_INFORMATION2
  -- Alternate Id Type         = PEI_INFORMATION3
  -- Alternate Id No           = PEI_INFORMATION4
  -- Synchronize OSS Data -(R) = PEI_INFORMATION5
  -- =====================================================================

  OPEN csr_igs FOR SQLstmt Using p_party_id;
  FETCH csr_igs INTO l_oss_per_details;
  CLOSE csr_igs;

  hr_utility.set_location(' After Dyn SQL Ref Cursor', 30);

  l_person_extra_info_rec.pei_information1  := NVL(l_oss_per_details.system_type
                                                  ,'STUDENT');
  l_person_extra_info_rec.pei_information2  := l_oss_per_details.person_number;

  -- If person_number is NULL
  IF l_oss_per_details.person_number IS NULL THEN

     OPEN hz_pe(c_party_id => p_party_id);
     FETCH hz_pe INTO l_oss_per_details.person_number;
     CLOSE hz_pe;

     l_person_extra_info_rec.pei_information2:=l_oss_per_details.person_number;
  END IF;

  -- The Alternate ID and Type is not required
  --l_person_extra_info_rec.pei_information3  := l_oss_per_details.person_id_type;
  --l_person_extra_info_rec.pei_information4  := l_oss_per_details.api_person_id;
  l_person_extra_info_rec.pei_information5  := 'Y';

  -- Check if Extra_information for Person already exists
  OPEN  csr_OSS_pe (c_person_id        => p_person_id
                   ,c_information_type => l_oss_person_details);
  FETCH csr_OSS_pe INTO l_OSS_pe;

  IF csr_OSS_pe%NOTFOUND THEN

     hrdpp_create_person_extra_info.insert_batch_lines
     (p_batch_id                   => p_batch_id
     ,p_user_sequence              => p_user_sequence
     ,p_link_value                 => p_link_value
     ,p_information_type           => l_person_extra_info_rec.information_type
     ,p_pei_information_category   =>
                              l_person_extra_info_rec.pei_information_category
     ,p_pei_information1           => l_person_extra_info_rec.pei_information1
     ,p_pei_information2           => l_person_extra_info_rec.pei_information2
     ,p_pei_information3           => l_person_extra_info_rec.pei_information3
     ,p_pei_information4           => l_person_extra_info_rec.pei_information4
     ,p_pei_information5           => l_person_extra_info_rec.pei_information5
     ,p_pei_information6           => l_person_extra_info_rec.pei_information6
     ,p_pei_information7           => l_person_extra_info_rec.pei_information7
     ,p_pei_information8           => l_person_extra_info_rec.pei_information8
     ,p_pei_information9           => l_person_extra_info_rec.pei_information9
     ,p_pei_information10          => l_person_extra_info_rec.pei_information10
     ,p_pei_information11          => l_person_extra_info_rec.pei_information11
     ,p_pei_information12          => l_person_extra_info_rec.pei_information12
     ,p_pei_information13          => l_person_extra_info_rec.pei_information13
     ,p_pei_information14          => l_person_extra_info_rec.pei_information14
     ,p_pei_information15          => l_person_extra_info_rec.pei_information15
     ,p_pei_information16          => l_person_extra_info_rec.pei_information16
     ,p_pei_information17          => l_person_extra_info_rec.pei_information17
     ,p_pei_information18          => l_person_extra_info_rec.pei_information18
     ,p_pei_information19          => l_person_extra_info_rec.pei_information19
     ,p_pei_information20          => l_person_extra_info_rec.pei_information20
     ,p_pei_information21          => l_person_extra_info_rec.pei_information21
     ,p_pei_information22          => l_person_extra_info_rec.pei_information22
     ,p_pei_information23          => l_person_extra_info_rec.pei_information23
     ,p_pei_information24          => l_person_extra_info_rec.pei_information24
     ,p_pei_information25          => l_person_extra_info_rec.pei_information25
     ,p_pei_information26          => l_person_extra_info_rec.pei_information26
     ,p_pei_information27          => l_person_extra_info_rec.pei_information27
     ,p_pei_information28          => l_person_extra_info_rec.pei_information28
     ,p_pei_information29          => l_person_extra_info_rec.pei_information29
     ,p_pei_information30          => l_person_extra_info_rec.pei_information30
     ,p_person_extra_info_user_key => p_xtra_info_key
     ,p_person_user_key            => p_person_user_key
     );

  ELSE

     -- Insert User_Key for People Extra Information ID
     hr_pump_utils.add_user_key
     (p_user_key_value => p_xtra_info_key
     ,p_unique_key_id  =>
      l_person_extra_info_rec.person_extra_info_id
      );

     hrdpp_update_person_extra_info.insert_batch_lines
     (p_batch_id                   => p_batch_id
     ,p_user_sequence              => p_user_sequence
     ,p_link_value                 => p_link_value
     ,p_pei_information_category   =>
         l_person_extra_info_rec.pei_information_category
     ,p_pei_information1           => l_person_extra_info_rec.pei_information1
     ,p_pei_information2           => l_person_extra_info_rec.pei_information2
     ,p_pei_information3           => l_person_extra_info_rec.pei_information3
     ,p_pei_information4           => l_person_extra_info_rec.pei_information4
     ,p_pei_information5           => l_person_extra_info_rec.pei_information5
     ,p_pei_information6           => l_person_extra_info_rec.pei_information6
     ,p_pei_information7           => l_person_extra_info_rec.pei_information7
     ,p_pei_information8           => l_person_extra_info_rec.pei_information8
     ,p_pei_information9           => l_person_extra_info_rec.pei_information9
     ,p_pei_information10          => l_person_extra_info_rec.pei_information10
     ,p_pei_information11          => l_person_extra_info_rec.pei_information11
     ,p_pei_information12          => l_person_extra_info_rec.pei_information12
     ,p_pei_information13          => l_person_extra_info_rec.pei_information13
     ,p_pei_information14          => l_person_extra_info_rec.pei_information14
     ,p_pei_information15          => l_person_extra_info_rec.pei_information15
     ,p_pei_information16          => l_person_extra_info_rec.pei_information16
     ,p_pei_information17          => l_person_extra_info_rec.pei_information17
     ,p_pei_information18          => l_person_extra_info_rec.pei_information18
     ,p_pei_information19          => l_person_extra_info_rec.pei_information19
     ,p_pei_information20          => l_person_extra_info_rec.pei_information20
     ,p_pei_information21          => l_person_extra_info_rec.pei_information21
     ,p_pei_information22          => l_person_extra_info_rec.pei_information22
     ,p_pei_information23          => l_person_extra_info_rec.pei_information23
     ,p_pei_information24          => l_person_extra_info_rec.pei_information24
     ,p_pei_information25          => l_person_extra_info_rec.pei_information25
     ,p_pei_information26          => l_person_extra_info_rec.pei_information26
     ,p_pei_information27          => l_person_extra_info_rec.pei_information27
     ,p_pei_information28          => l_person_extra_info_rec.pei_information28
     ,p_pei_information29          => l_person_extra_info_rec.pei_information29
     ,p_pei_information30          => l_person_extra_info_rec.pei_information30
     ,p_person_extra_info_user_key => p_xtra_info_key
     );

  END IF;
  hr_utility.set_location(' After Cursor :csr_OSS_pe', 40);
  CLOSE csr_OSS_pe;

  hr_utility.set_location('Leaving: ' || l_proc_name, 50);

EXCEPTION
  WHEN Others THEN
       hr_utility.set_location('Leaving: ' || l_proc_name, 60);
       ROLLBACK TO oss_per_dtls;

END HR_DataPump_Per_XtraInfo;


-- =============================================================================
-- ~ HR_DataPump:
--
-- NOTE : p_data_pump_batch_line_id is used as link_value_id in the procedure
--        as in future we may have to have it as batch_line_ids concatenated
--        string
-- =============================================================================
PROCEDURE HR_DataPump
          (p_data_pump_batch_line_id IN Varchar2
          ,p_batch_id                IN Number
          ,p_contact_name            IN Varchar
          ,p_dp_mode                 IN Varchar
          ,p_adjusted_svc_date       IN Date
          ) AS

  -- Cursor gets the link_value for the record. It is the value 1 added to the
  -- maximum value of Link_Value for that batch_id
  CURSOR csr_get_link_value (c_batch_id Number) IS
  SELECT Max(link_value) + 1
    FROM hr_pump_batch_lines
   WHERE batch_id = c_batch_id;

  -- Cursor to get the Assignment details of duplicate person
  CURSOR csr_asg (c_person_id IN Number
                 ,c_business_group_id IN Number
                 ,c_effective_date IN Date) IS
  SELECT paf.assignment_id,
         ppf.object_version_number
    FROM per_all_assignments_f paf
        ,per_all_people_f      ppf
   WHERE paf.person_id = c_person_id
     AND paf.business_group_id = c_business_group_id
     AND paf.person_id = ppf.person_id
     AND c_effective_date BETWEEN ppf.effective_start_date
                              AND ppf.effective_end_date
     AND c_effective_date BETWEEN paf.effective_start_date
                              AND paf.effective_end_date;

  -- Cursor to get Contact Details for a person if it already exists
  CURSOR csr_get_cont_dtls(c_person_id         IN Number
                          ,c_business_group_id IN Number
                          ,c_effective_date    IN Date) IS
  SELECT *
    FROM per_contact_relationships
   WHERE person_id         = c_person_id
     AND business_group_id = c_business_group_id
     AND c_effective_date BETWEEN date_start
                              AND NVL(date_end, c_effective_date);


  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'HR_DataPump';
  l_person_user_key        Varchar2(240);
  l_assignment_user_key    Varchar2(240);
  l_address_user_key       Varchar2(240);
  l_contact_key            Varchar2(240);
  l_xtra_info_key          Varchar2(240);
  l_temp                   Varchar2(240);

  l_cur_per_rec            csr_per%ROWTYPE;
  l_datetrack_update_mode  Varchar2(50);
  l_dt_correction          Boolean;
  l_dt_update              Boolean;
  l_dt_upd_override        Boolean;
  l_upd_chg_ins            Boolean;

  l_cont_object_version_num
                           per_contact_relationships.object_version_number%TYPE;
  l_cur_add_rec             per_addresses%ROWTYPE;
  l_cont_rec                per_contact_relationships%ROWTYPE;
  l_pay_basis_name          per_pay_bases.NAME%TYPE;
  l_organization_name       hr_all_organization_units.NAME%TYPE;
  l_location_code           hr_locations_all.location_code%TYPE;
  l_payroll_name            pay_payrolls_f.payroll_name%TYPE;
  l_job_name                per_jobs.NAME%TYPE;
  l_position_name           per_positions.NAME%TYPE;
  l_grade_name              per_grades.NAME%TYPE;
  l_user_person_type        per_person_types.user_person_type%TYPE;
  l_user_sequence           Number := 1;
  l_link_value              Number;

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  -- Creating User Keys for Person, Address, Assugnment and Contact
  l_temp := To_Char(Sysdate,'J')||
            To_Char(Sysdate,'HH24MISS')||
            Dbms_Utility.get_Hash_Value(l_per_rec.last_name||
                                        l_per_rec.sex||
                                        l_per_rec.first_name,0,1000);

  l_person_user_key     := 'HROSS~PER~'||l_temp;
  l_address_user_key    := 'HROSS~ADD~'||l_temp;
  l_assignment_user_key := 'HROSS~ASG~'||l_temp;
  l_contact_key         := 'HROSS~CNT~'||l_temp;
  l_xtra_info_key       := 'HROSS~XTR~'||l_temp;


  OPEN  csr_per_type(l_per_rec.person_type_id
                    ,l_per_rec.business_group_id);
  FETCH csr_per_type INTO l_user_person_type;
  CLOSE csr_per_type;
  hr_utility.set_location('..l_user_person_type: ' || l_user_person_type, 20);

  -- Get the Link value for this record
  OPEN  csr_get_link_value (p_batch_id);
  FETCH csr_get_link_value INTO l_link_value;
  CLOSE csr_get_link_value;

  -- If first record is being entered then link_value returned from cursor
  -- will be null, hence we set it to 1
  IF l_link_value IS NULL THEN
     l_link_value := 1;
  END IF;

  IF p_dp_mode = 'INSERT' THEN
     Hrdpp_Create_Employee.Insert_Batch_Lines
     (p_batch_id                     => p_batch_id
     ,p_user_sequence                => l_user_sequence
     ,p_link_value                   => l_link_value
     ,p_hire_date                    => l_per_rec.START_DATE
     ,p_last_name                    => l_per_rec.last_name
     ,p_sex                          => l_per_rec.sex
     --,p_per_comments                 => l_per_rec.comments
     ,p_date_employee_data_verified  => l_per_rec.date_employee_data_verified
     ,p_date_of_birth                => l_per_rec.date_of_birth
     ,p_email_address                => l_per_rec.email_address
     ,p_employee_number              => l_per_rec.employee_number
     ,p_expense_check_send_to_addres => l_per_rec.expense_check_send_to_address
     ,p_first_name                   => l_per_rec.first_name
     ,p_known_as                     => l_per_rec.known_as
     ,p_marital_status               => l_per_rec.marital_status
     ,p_middle_names                 => l_per_rec.middle_names
     ,p_nationality                  => l_per_rec.nationality
     ,p_national_identifier          => l_per_rec.national_identifier
     ,p_previous_last_name           => l_per_rec.previous_last_name
     ,p_registered_disabled_flag     => l_per_rec.registered_disabled_flag
     ,p_title                        => l_per_rec.title
     --,p_work_telephone               => p_telephone_no1
     ,p_attribute_category           => l_per_rec.attribute_category
     ,p_attribute1                   => l_per_rec.attribute1
     ,p_attribute2                   => l_per_rec.attribute2
     ,p_attribute3                   => l_per_rec.attribute3
     ,p_attribute4                   => l_per_rec.attribute4
     ,p_attribute5                   => l_per_rec.attribute5
     ,p_attribute6                   => l_per_rec.attribute6
     ,p_attribute7                   => l_per_rec.attribute7
     ,p_attribute8                   => l_per_rec.attribute8
     ,p_attribute9                   => l_per_rec.attribute9
     ,p_attribute10                  => l_per_rec.attribute10
     ,p_attribute11                  => l_per_rec.attribute11
     ,p_attribute12                  => l_per_rec.attribute12
     ,p_attribute13                  => l_per_rec.attribute13
     ,p_attribute14                  => l_per_rec.attribute14
     ,p_attribute15                  => l_per_rec.attribute15
     ,p_attribute16                  => l_per_rec.attribute16
     ,p_attribute17                  => l_per_rec.attribute17
     ,p_attribute18                  => l_per_rec.attribute18
     ,p_attribute19                  => l_per_rec.attribute19
     ,p_attribute20                  => l_per_rec.attribute20
     ,p_attribute21                  => l_per_rec.attribute21
     ,p_attribute22                  => l_per_rec.attribute22
     ,p_attribute23                  => l_per_rec.attribute23
     ,p_attribute24                  => l_per_rec.attribute24
     ,p_attribute25                  => l_per_rec.attribute25
     ,p_attribute26                  => l_per_rec.attribute26
     ,p_attribute27                  => l_per_rec.attribute27
     ,p_attribute28                  => l_per_rec.attribute28
     ,p_attribute29                  => l_per_rec.attribute29
     ,p_attribute30                  => l_per_rec.attribute30
     ,p_per_information_category     => l_per_rec.per_information_category
     ,p_per_information1             => l_per_rec.per_information1
     ,p_per_information2             => l_per_rec.per_information2
     ,p_per_information3             => l_per_rec.per_information3
     ,p_per_information4             => l_per_rec.per_information4
     ,p_per_information5             => l_per_rec.per_information5
     ,p_per_information6             => l_per_rec.per_information6
     ,p_per_information7             => l_per_rec.per_information7
     ,p_per_information8             => l_per_rec.per_information8
     ,p_per_information9             => l_per_rec.per_information9
     ,p_per_information10            => l_per_rec.per_information10
     ,p_per_information11            => l_per_rec.per_information11
     ,p_per_information12            => l_per_rec.per_information12
     ,p_per_information13            => l_per_rec.per_information13
     ,p_per_information14            => l_per_rec.per_information14
     ,p_per_information15            => l_per_rec.per_information15
     ,p_per_information16            => l_per_rec.per_information16
     ,p_per_information17            => l_per_rec.per_information17
     ,p_per_information18            => l_per_rec.per_information18
     ,p_per_information19            => l_per_rec.per_information19
     ,p_per_information20            => l_per_rec.per_information20
     ,p_per_information21            => l_per_rec.per_information21
     ,p_per_information22            => l_per_rec.per_information22
     ,p_per_information23            => l_per_rec.per_information23
     ,p_per_information24            => l_per_rec.per_information24
     ,p_per_information25            => l_per_rec.per_information25
     ,p_per_information26            => l_per_rec.per_information26
     ,p_per_information27            => l_per_rec.per_information27
     ,p_per_information28            => l_per_rec.per_information28
     ,p_per_information29            => l_per_rec.per_information29
     ,p_per_information30            => l_per_rec.per_information30
     ,p_date_of_death                => l_per_rec.date_of_death
     ,p_background_check_status      => l_per_rec.background_check_status
     ,p_background_date_check        => l_per_rec.background_date_check
     ,p_blood_type                   => l_per_rec.blood_type
     ,p_fast_path_employee           => l_per_rec.fast_path_employee
     ,p_fte_capacity                 => l_per_rec.fte_capacity
     ,p_honors                       => l_per_rec.honors
     ,p_internal_location            => l_per_rec.internal_location
     ,p_last_medical_test_by         => l_per_rec.last_medical_test_by
     ,p_last_medical_test_date       => l_per_rec.last_medical_test_date
     ,p_mailstop                     => l_per_rec.mailstop
     ,p_office_number                => l_per_rec.office_number
     ,p_on_military_service          => l_per_rec.on_military_service
     ,p_pre_name_adjunct             => l_per_rec.pre_name_adjunct
     ,p_projected_start_date         => l_per_rec.projected_start_date
     ,p_resume_exists                => l_per_rec.resume_exists
     ,p_resume_last_updated          => l_per_rec.resume_last_updated
     ,p_second_passport_exists       => l_per_rec.second_passport_exists
     ,p_student_status               => l_per_rec.student_status
     ,p_work_schedule                => l_per_rec.work_schedule
     ,p_suffix                       => l_per_rec.suffix
     ,p_receipt_of_death_cert_date   => l_per_rec.receipt_of_death_cert_date
     ,p_coord_ben_med_pln_no         => l_per_rec.coord_ben_med_pln_no
     ,p_coord_ben_no_cvg_flag        => l_per_rec.coord_ben_no_cvg_flag
     ,p_coord_ben_med_ext_er         => l_per_rec.coord_ben_med_ext_er
     ,p_coord_ben_med_pl_name        => l_per_rec.coord_ben_med_pl_name
     ,p_coord_ben_med_insr_crr_name  => l_per_rec.coord_ben_med_insr_crr_name
     ,p_coord_ben_med_insr_crr_ident => l_per_rec.coord_ben_med_insr_crr_ident
     ,p_coord_ben_med_cvg_strt_dt    => l_per_rec.coord_ben_med_cvg_strt_dt
     ,p_coord_ben_med_cvg_end_dt     => l_per_rec.coord_ben_med_cvg_end_dt
     ,p_uses_tobacco_flag            => l_per_rec.uses_tobacco_flag
     ,p_dpdnt_adoption_date          => l_per_rec.dpdnt_adoption_date
     ,p_dpdnt_vlntry_svce_flag       => l_per_rec.dpdnt_vlntry_svce_flag
     ,p_original_date_of_hire        => l_per_rec.original_date_of_hire
     --,p_adjusted_svc_date            => p_adjusted_svc_date
     ,p_town_of_birth                => l_per_rec.town_of_birth
     ,p_region_of_birth              => l_per_rec.region_of_birth
     ,p_country_of_birth             => l_per_rec.country_of_birth
     ,p_global_person_id             => l_per_rec.global_person_id
     ,p_party_id                     => l_per_rec.party_id
     ,p_correspondence_language      => l_per_rec.correspondence_language
     ,p_benefit_group                => l_per_rec.benefit_group_id
     ,p_person_user_key              => l_person_user_key
     ,p_assignment_user_key          => l_assignment_user_key
     ,p_user_person_type             => l_user_person_type
     ,p_language_code                => Userenv('lang')
     ,p_vendor_name                  => NULL
     );

     l_user_sequence := l_user_sequence + 1;

     hr_utility.set_location('..Inserted into Hrdpp_Create_Employee', 30);

  ELSIF p_dp_mode = 'UPDATE' THEN

     -- Cursor to get the Latest Details of Person in System
     OPEN  csr_per(c_person_id         => l_per_rec.person_id
                  ,c_business_group_id => l_per_rec.business_group_id
                  ,c_effective_date    => l_per_rec.START_DATE);
     FETCH csr_per INTO l_cur_per_rec;
     CLOSE csr_per;

     Dt_Api.Find_DT_Upd_Modes
     (p_effective_date        => l_per_rec.START_DATE
     ,p_base_table_name       => 'PER_ALL_PEOPLE_F'
     ,p_base_key_column       => 'PERSON_ID'
     ,p_base_key_value        => l_cur_per_rec.person_id
     ,p_correction            => l_dt_correction
     ,p_update                => l_dt_update
     ,p_update_override       => l_dt_upd_override
     ,p_update_change_insert  => l_upd_chg_ins
      );

     IF NOT(l_dt_update AND
            l_dt_upd_override AND
            l_upd_chg_ins) THEN

        l_datetrack_update_mode := 'CORRECTION';

     ELSIF l_dt_update THEN

        l_datetrack_update_mode := 'UPDATE';

     ELSIF l_dt_upd_override OR
           l_upd_chg_ins THEN
           -- Need to check if person type in future is EMP, APL or CWK ,
	   -- if yes then raise error
            NULL;
     END IF;
     -- If User hasn't entered the Employee Number, then get Employee Number
     -- for entered duplicate person id
     IF l_per_rec.employee_number = NULL THEN

        OPEN  csr_get_employee_num(c_person_id => l_per_rec.person_id);
        FETCH csr_get_employee_num INTO l_per_rec.employee_number;
        CLOSE csr_get_employee_num;

     END IF;

     -- Insert the Person User Key with Person Id in DP User Keys Table
     -- This will be required when DP Engine is run
     hr_pump_utils.add_user_key(p_user_key_value => l_person_user_key
                               ,p_unique_key_id  => l_per_rec.person_id
                               );

     Hrdpp_Hire_Into_Job.insert_batch_lines
     (p_batch_id                     => p_batch_id
     ,p_user_sequence                => l_user_sequence
     ,p_link_value                   => l_link_value
     ,p_effective_date               => l_per_rec.START_DATE
     ,p_object_version_number        => l_cur_per_rec.object_version_number
     ,p_employee_number              => l_per_rec.employee_number
     ,p_datetrack_update_mode        => l_datetrack_update_mode
     ,p_national_identifier          => l_per_rec.national_identifier
     ,p_per_information7             => NULL
     ,p_person_user_key              => l_person_user_key
     ,p_assignment_user_key          => l_assignment_user_key
     ,p_user_person_type             => l_user_person_type
     ,p_language_code                => Userenv('LANG')
     );

     l_user_sequence := l_user_sequence + 1;

     Hrdpp_Update_Person.insert_batch_lines
     (p_batch_id                     => p_batch_id
     ,p_user_sequence                => l_user_sequence
     ,p_link_value                   => l_link_value
     ,p_effective_date               => l_per_rec.START_DATE
     ,p_datetrack_update_mode        => l_datetrack_update_mode
     ,p_party_id                     => l_per_rec.party_id
     ,p_employee_number              => l_per_rec.employee_number
     ,p_last_name                    => NVL(l_per_rec.last_name
                                           ,l_cur_per_rec.last_name)
     ,p_first_name                   => NVL(l_per_rec.first_name
                                           ,l_cur_per_rec.first_name)
     ,p_date_of_birth                => NVL(l_per_rec.date_of_birth
                                           ,l_cur_per_rec.date_of_birth)
     ,p_marital_status               => NVL(l_per_rec.marital_status
                                           ,l_cur_per_rec.marital_status)
     ,p_middle_names                 => NVL(l_per_rec.middle_names
                                           ,l_cur_per_rec.middle_names)
     ,p_sex                          => NVL(l_per_rec.sex
                                           ,l_cur_per_rec.sex)
     ,p_title                        => NVL(l_per_rec.title
                                           ,l_cur_per_rec.title)
     ,p_nationality                  => NVL(l_per_rec.nationality
                                           ,l_cur_per_rec.nationality)
     ,p_previous_last_name           => NVL(l_per_rec.previous_last_name
                                           ,l_cur_per_rec.previous_last_name)
     ,p_national_identifier          => NVL(l_per_rec.national_identifier
                                           ,l_cur_per_rec.national_identifier)
     ,p_known_as                     => NVL(l_per_rec.known_as
                                           ,l_cur_per_rec.known_as)
     ,p_email_address                => NVL(l_per_rec.email_address
                                           ,l_cur_per_rec.email_address)
     ,p_registered_disabled_flag     => NVL(l_per_rec.registered_disabled_flag
                                        ,l_cur_per_rec.registered_disabled_flag)
     ,p_date_employee_data_verified  =>NVL(l_per_rec.date_employee_data_verified
                                     ,l_cur_per_rec.date_employee_data_verified)
    ,p_expense_check_send_to_addres=>NVL(l_per_rec.expense_check_send_to_address
                                   ,l_cur_per_rec.expense_check_send_to_address)
     ,p_per_information_category     => l_per_rec.per_information_category
     ,p_per_information1             => l_per_rec.per_information1
     ,p_per_information2             => l_per_rec.per_information2
     ,p_per_information3             => l_per_rec.per_information3
     ,p_per_information4             => l_per_rec.per_information4
     ,p_per_information5             => l_per_rec.per_information5
     ,p_per_information6             => l_per_rec.per_information6
     ,p_per_information7             => l_per_rec.per_information7
     ,p_per_information8             => l_per_rec.per_information8
     ,p_per_information9             => l_per_rec.per_information9
     ,p_per_information10            => l_per_rec.per_information10
     ,p_per_information11            => l_per_rec.per_information11
     ,p_per_information12            => l_per_rec.per_information12
     ,p_per_information13            => l_per_rec.per_information13
     ,p_per_information14            => l_per_rec.per_information14
     ,p_per_information15            => l_per_rec.per_information15
     ,p_per_information16            => l_per_rec.per_information16
     ,p_per_information17            => l_per_rec.per_information17
     ,p_per_information18            => l_per_rec.per_information18
     ,p_per_information19            => l_per_rec.per_information19
     ,p_per_information20            => l_per_rec.per_information20
     ,p_per_information21            => l_per_rec.per_information21
     ,p_per_information22            => l_per_rec.per_information22
     ,p_per_information23            => l_per_rec.per_information23
     ,p_per_information24            => l_per_rec.per_information24
     ,p_per_information25            => l_per_rec.per_information25
     ,p_per_information26            => l_per_rec.per_information26
     ,p_per_information27            => l_per_rec.per_information27
     ,p_per_information28            => l_per_rec.per_information28
     ,p_per_information29            => l_per_rec.per_information29
     ,p_per_information30            => l_per_rec.per_information30
     -- Person DF
     ,p_attribute_category           => l_per_rec.attribute_category
     ,p_attribute1                   => l_per_rec.attribute1
     ,p_attribute2                   => l_per_rec.attribute2
     ,p_attribute3                   => l_per_rec.attribute3
     ,p_attribute4                   => l_per_rec.attribute4
     ,p_attribute5                   => l_per_rec.attribute5
     ,p_attribute6                   => l_per_rec.attribute6
     ,p_attribute7                   => l_per_rec.attribute7
     ,p_attribute8                   => l_per_rec.attribute8
     ,p_attribute9                   => l_per_rec.attribute9
     ,p_attribute10                  => l_per_rec.attribute10
     ,p_attribute11                  => l_per_rec.attribute11
     ,p_attribute12                  => l_per_rec.attribute12
     ,p_attribute13                  => l_per_rec.attribute13
     ,p_attribute14                  => l_per_rec.attribute14
     ,p_attribute15                  => l_per_rec.attribute15
     ,p_attribute16                  => l_per_rec.attribute16
     ,p_attribute17                  => l_per_rec.attribute17
     ,p_attribute18                  => l_per_rec.attribute18
     ,p_attribute19                  => l_per_rec.attribute19
     ,p_attribute20                  => l_per_rec.attribute20
     ,p_attribute21                  => l_per_rec.attribute21
     ,p_attribute22                  => l_per_rec.attribute22
     ,p_attribute23                  => l_per_rec.attribute23
     ,p_attribute24                  => l_per_rec.attribute24
     ,p_attribute25                  => l_per_rec.attribute25
     ,p_attribute26                  => l_per_rec.attribute26
     ,p_attribute27                  => l_per_rec.attribute27
     ,p_attribute28                  => l_per_rec.attribute28
     ,p_attribute29                  => l_per_rec.attribute29
     ,p_attribute30                  => l_per_rec.attribute30
   --,p_vendor_id                    => l_per_rec.vendor_id
   --,p_work_telephone               => l_per_rec.vendor_id
     ,p_date_of_death                => NVL(l_per_rec.date_of_death
                                           ,l_cur_per_rec.date_of_death)
     ,p_background_check_status      => NVL(l_per_rec.background_check_status
                                        ,l_cur_per_rec.background_check_status)
     ,p_background_date_check        => NVL(l_per_rec.background_date_check
                                           ,l_cur_per_rec.background_date_check)
     ,p_blood_type                   => NVL(l_per_rec.blood_type
                                           ,l_cur_per_rec.blood_type)
     ,p_correspondence_language      => NVL(l_per_rec.correspondence_language
                                        ,l_cur_per_rec.correspondence_language)
   --,p_fast_path_employee           IN  Varchar2 DEFAULT Hr_Api.g_Varchar2
     ,p_fte_capacity                 => NVL(l_per_rec.fte_capacity
                                           ,l_cur_per_rec.fte_capacity)
     ,p_hold_applicant_date_until    => NVL(l_per_rec.hold_applicant_date_until
                                       ,l_cur_per_rec.hold_applicant_date_until)
     ,p_honors                       => NVL(l_per_rec.honors
                                           ,l_cur_per_rec.honors)
     ,p_internal_location            => NVL(l_per_rec.internal_location
                                           ,l_cur_per_rec.internal_location)
     ,p_last_medical_test_by         => NVL(l_per_rec.last_medical_test_by
                                           ,l_cur_per_rec.last_medical_test_by)
     ,p_last_medical_test_date       => NVL(l_per_rec.last_medical_test_date
                                          ,l_cur_per_rec.last_medical_test_date)
     ,p_mailstop                     => NVL(l_per_rec.mailstop
                                           ,l_cur_per_rec.mailstop)
     ,p_office_number                => NVL(l_per_rec.office_number
                                           ,l_cur_per_rec.office_number)
     ,p_on_military_service          => NVL(l_per_rec.on_military_service
                                           ,l_cur_per_rec.on_military_service)
     ,p_pre_name_adjunct             => NVL(l_per_rec.pre_name_adjunct
                                           ,l_cur_per_rec.pre_name_adjunct)
     ,p_projected_start_date         => NVL(l_per_rec.projected_start_date
                                           ,l_cur_per_rec.projected_start_date)
     ,p_rehire_authorizor            => NVL(l_per_rec.rehire_authorizor
                                           ,l_cur_per_rec.rehire_authorizor)
     ,p_rehire_recommendation        => NVL(l_per_rec.rehire_recommendation
                                           ,l_cur_per_rec.rehire_recommendation)
     ,p_resume_exists                => NVL(l_per_rec.resume_exists
                                           ,l_cur_per_rec.resume_exists)
     ,p_resume_last_updated          => NVL(l_per_rec.resume_last_updated
                                           ,l_cur_per_rec.resume_last_updated)
     ,p_second_passport_exists       => NVL(l_per_rec.second_passport_exists
                                          ,l_cur_per_rec.second_passport_exists)
     ,p_student_status               => NVL(l_per_rec.student_status
                                           ,l_cur_per_rec.student_status)
     ,p_work_schedule                => NVL(l_per_rec.work_schedule
                                           ,l_cur_per_rec.work_schedule)
     ,p_rehire_reason                => NVL(l_per_rec.rehire_reason
                                           ,l_cur_per_rec.rehire_reason)
     ,p_suffix                       => NVL(l_per_rec.suffix
                                           ,l_cur_per_rec.suffix)
     ,p_benefit_group                => NVL(l_per_rec.benefit_group_id
                                           ,l_cur_per_rec.benefit_group_id)
     ,p_receipt_of_death_cert_date   => NVL(l_per_rec.receipt_of_death_cert_date
                                      ,l_cur_per_rec.receipt_of_death_cert_date)
     ,p_coord_ben_med_pln_no         => NVL(l_per_rec.coord_ben_med_pln_no
                                           ,l_cur_per_rec.coord_ben_med_pln_no)
     ,p_coord_ben_no_cvg_flag        => NVL(l_per_rec.coord_ben_no_cvg_flag
                                           ,l_cur_per_rec.coord_ben_no_cvg_flag)
     ,p_coord_ben_med_ext_er         => NVL(l_per_rec.coord_ben_med_ext_er
                                           ,l_cur_per_rec.coord_ben_med_ext_er)
     ,p_coord_ben_med_pl_name        => NVL(l_per_rec.coord_ben_med_pl_name
                                           ,l_cur_per_rec.coord_ben_med_pl_name)
     ,p_coord_ben_med_insr_crr_name  =>NVL(l_per_rec.coord_ben_med_insr_crr_name
                                     ,l_cur_per_rec.coord_ben_med_insr_crr_name)
     ,p_coord_ben_med_insr_crr_ident=>NVL(l_per_rec.coord_ben_med_insr_crr_ident
                                    ,l_cur_per_rec.coord_ben_med_insr_crr_ident)
     ,p_coord_ben_med_cvg_strt_dt    => NVL(l_per_rec.coord_ben_med_cvg_strt_dt
                                       ,l_cur_per_rec.coord_ben_med_cvg_strt_dt)
     ,p_coord_ben_med_cvg_end_dt     => NVL(l_per_rec.coord_ben_med_cvg_end_dt
                                        ,l_cur_per_rec.coord_ben_med_cvg_end_dt)
     ,p_uses_tobacco_flag            => NVL(l_per_rec.uses_tobacco_flag
                                           ,l_cur_per_rec.uses_tobacco_flag)
     ,p_dpdnt_adoption_date          => NVL(l_per_rec.dpdnt_adoption_date
                                           ,l_cur_per_rec.dpdnt_adoption_date)
     ,p_dpdnt_vlntry_svce_flag       => NVL(l_per_rec.dpdnt_vlntry_svce_flag
                                         ,l_cur_per_rec.dpdnt_vlntry_svce_flag)
     ,p_original_date_of_hire        => NVL(l_per_rec.original_date_of_hire
                                          ,l_cur_per_rec.original_date_of_hire)
     ,p_adjusted_svc_date            => p_adjusted_svc_date
     ,p_town_of_birth                => NVL(l_per_rec.town_of_birth
                                           ,l_cur_per_rec.town_of_birth)
     ,p_region_of_birth              => NVL(l_per_rec.region_of_birth
                                           ,l_cur_per_rec.region_of_birth)
     ,p_country_of_birth             => NVL(l_per_rec.country_of_birth
                                           ,l_cur_per_rec.country_of_birth)
     ,p_global_person_id             => NVL(l_per_rec.global_person_id
                                           ,l_cur_per_rec.global_person_id)
     ,p_person_user_key              => l_person_user_key
     ,p_user_person_type             => l_user_person_type
     ,p_language_code                => Userenv('lang')
     ,p_vendor_name                  => NULL
     );

     l_user_sequence := l_user_sequence + 1;

  END IF;

  -- Open Cursor to check if Address with Employee Number Already exists
  OPEN  csr_ck_add_xsts(c_person_id         => l_per_rec.person_id
                       ,c_business_group_id => l_add_rec.business_group_id
                       ,c_effective_date    => l_per_rec.START_DATE
                       ,c_primary_flag      => NVL(l_add_rec.primary_flag,
		                                   'Y'));
  FETCH csr_ck_add_xsts INTO l_cur_add_rec;

  -- Create Address if Address Doesn't exist or if it is being created for
  -- new Person
  IF csr_ck_add_xsts%FOUND AND p_dp_mode = 'UPDATE' AND
     l_add_rec.address_line1 IS NOT NULL THEN

     -- Set the p_pradd_ovlapval_override to TURE and create address if address
     -- already exists.But if address record has from_date same as effective
     -- date then update it

     IF Trunc(l_per_rec.START_DATE) =
        Trunc(l_cur_add_rec.date_from) THEN

        Hrdpp_Update_Person_Address.Insert_Batch_Lines
        (p_batch_id                       => p_batch_id
        ,p_user_sequence                  => l_user_sequence
        ,p_link_value                     => l_link_value
        ,p_effective_date                 => l_per_rec.START_DATE
        ,p_validate_county                => TRUE
        ,p_primary_flag                   => NVL(l_add_rec.primary_flag, 'Y')
        ,p_date_from                      => l_add_rec.date_from
        ,p_date_to                        => l_add_rec.date_to
        ,p_address_type                   => l_add_rec.address_type
        --,p_comments                       => p_adr_comments
        ,p_address_line1                  => l_add_rec.address_line1
        ,p_address_line2                  => l_add_rec.address_line2
        ,p_address_line3                  => l_add_rec.address_line3
        ,p_town_or_city                   => l_add_rec.town_or_city
        ,p_region_1                       => l_add_rec.region_1
        ,p_region_2                       => l_add_rec.region_2
        ,p_region_3                       => l_add_rec.region_3
        ,p_postal_code                    => l_add_rec.postal_code
        ,p_telephone_number_1             => l_add_rec.telephone_number_1
        ,p_telephone_number_2             => l_add_rec.telephone_number_2
        ,p_telephone_number_3             => l_add_rec.telephone_number_3
        ,p_addr_attribute_category        => l_add_rec.addr_attribute_category
        ,p_addr_attribute1                => l_add_rec.addr_attribute1
        ,p_addr_attribute2                => l_add_rec.addr_attribute2
        ,p_addr_attribute3                => l_add_rec.addr_attribute3
        ,p_addr_attribute4                => l_add_rec.addr_attribute4
        ,p_addr_attribute5                => l_add_rec.addr_attribute5
        ,p_addr_attribute6                => l_add_rec.addr_attribute6
        ,p_addr_attribute7                => l_add_rec.addr_attribute7
        ,p_addr_attribute8                => l_add_rec.addr_attribute8
        ,p_addr_attribute9                => l_add_rec.addr_attribute9
        ,p_addr_attribute10               => l_add_rec.addr_attribute10
        ,p_addr_attribute11               => l_add_rec.addr_attribute11
        ,p_addr_attribute12               => l_add_rec.addr_attribute12
        ,p_addr_attribute13               => l_add_rec.addr_attribute13
        ,p_addr_attribute14               => l_add_rec.addr_attribute14
        ,p_addr_attribute15               => l_add_rec.addr_attribute15
        ,p_addr_attribute16               => l_add_rec.addr_attribute16
        ,p_addr_attribute17               => l_add_rec.addr_attribute17
        ,p_addr_attribute18               => l_add_rec.addr_attribute18
        ,p_addr_attribute19               => l_add_rec.addr_attribute19
        ,p_addr_attribute20               => l_add_rec.addr_attribute20
        ,p_add_information13              => l_add_rec.add_information13
        ,p_add_information14              => l_add_rec.add_information14
        ,p_add_information15              => l_add_rec.add_information15
        ,p_add_information16              => l_add_rec.add_information16
        ,p_add_information17              => l_add_rec.add_information17
        ,p_add_information18              => l_add_rec.add_information18
        ,p_add_information19              => l_add_rec.add_information19
        ,p_add_information20              => l_add_rec.add_information20
        ,p_party_id                       => l_add_rec.party_id
        ,p_address_user_key               => l_address_user_key
        ,p_country                        => l_add_rec.country
        );

        l_user_sequence := l_user_sequence + 1;

      ELSIF Trunc(l_per_rec.START_DATE) >
            Trunc(l_cur_add_rec.date_from) THEN

      -- Create a person with p_pradd_ovlapval flag set to TRUE

        Hrdpp_Create_Person_Address.Insert_Batch_Lines
        (p_batch_id                       => p_batch_id
        ,p_user_sequence                  => l_user_sequence
        ,p_link_value                     => l_link_value
        ,p_effective_date                 => l_per_rec.START_DATE
        ,p_pradd_ovlapval_override        => TRUE
        ,p_validate_county                => TRUE
        ,p_primary_flag                   => NVL(l_add_rec.primary_flag, 'Y')
        ,p_style                          => l_add_rec.style
        ,p_date_from                      => l_add_rec.date_from
        ,p_date_to                        => l_add_rec.date_to
        ,p_address_type                   => l_add_rec.address_type
        --,p_comments                       => p_adr_comments
        ,p_address_line1                  => l_add_rec.address_line1
        ,p_address_line2                  => l_add_rec.address_line2
        ,p_address_line3                  => l_add_rec.address_line3
        ,p_town_or_city                   => l_add_rec.town_or_city
        ,p_region_1                       => l_add_rec.region_1
        ,p_region_2                       => l_add_rec.region_2
        ,p_region_3                       => l_add_rec.region_3
        ,p_postal_code                    => l_add_rec.postal_code
        ,p_telephone_number_1             => l_add_rec.telephone_number_1
        ,p_telephone_number_2             => l_add_rec.telephone_number_2
        ,p_telephone_number_3             => l_add_rec.telephone_number_3
        ,p_addr_attribute_category        => l_add_rec.addr_attribute_category
        ,p_addr_attribute1                => l_add_rec.addr_attribute1
        ,p_addr_attribute2                => l_add_rec.addr_attribute2
        ,p_addr_attribute3                => l_add_rec.addr_attribute3
        ,p_addr_attribute4                => l_add_rec.addr_attribute4
        ,p_addr_attribute5                => l_add_rec.addr_attribute5
        ,p_addr_attribute6                => l_add_rec.addr_attribute6
        ,p_addr_attribute7                => l_add_rec.addr_attribute7
        ,p_addr_attribute8                => l_add_rec.addr_attribute8
        ,p_addr_attribute9                => l_add_rec.addr_attribute9
        ,p_addr_attribute10               => l_add_rec.addr_attribute10
        ,p_addr_attribute11               => l_add_rec.addr_attribute11
        ,p_addr_attribute12               => l_add_rec.addr_attribute12
        ,p_addr_attribute13               => l_add_rec.addr_attribute13
        ,p_addr_attribute14               => l_add_rec.addr_attribute14
        ,p_addr_attribute15               => l_add_rec.addr_attribute15
        ,p_addr_attribute16               => l_add_rec.addr_attribute16
        ,p_addr_attribute17               => l_add_rec.addr_attribute17
        ,p_addr_attribute18               => l_add_rec.addr_attribute18
        ,p_addr_attribute19               => l_add_rec.addr_attribute19
        ,p_addr_attribute20               => l_add_rec.addr_attribute20
        ,p_add_information13              => l_add_rec.add_information13
        ,p_add_information14              => l_add_rec.add_information14
        ,p_add_information15              => l_add_rec.add_information15
        ,p_add_information16              => l_add_rec.add_information16
        ,p_add_information17              => l_add_rec.add_information17
        ,p_add_information18              => l_add_rec.add_information18
        ,p_add_information19              => l_add_rec.add_information19
        ,p_add_information20              => l_add_rec.add_information20
        ,p_party_id                       => l_add_rec.party_id
        ,p_address_user_key               => l_address_user_key
        ,p_person_user_key                => l_person_user_key
        ,p_country                        => l_add_rec.country
        );

        l_user_sequence := l_user_sequence + 1;

     END IF;
   END IF;

   -- Create Address If it was not found updated when From_Date was same as
   -- effective date. Else in rest all cases where address has been entered
   -- Create Person Address

   IF (l_add_rec.style IS NOT NULL AND
      csr_ck_add_xsts%NOTFOUND AND p_dp_mode = 'UPDATE') OR
      (l_add_rec.style IS NOT NULL AND p_dp_mode = 'INSERT')THEN

      Hrdpp_Create_Person_Address.Insert_Batch_Lines
      (p_batch_id                       => p_batch_id
      ,p_user_sequence                  => l_user_sequence
      ,p_link_value                     => l_link_value
      ,p_effective_date                 => l_per_rec.START_DATE
      ,p_pradd_ovlapval_override        => FALSE
      ,p_validate_county                => TRUE
      ,p_primary_flag                   => NVL(l_add_rec.primary_flag, 'Y')
      ,p_style                          => l_add_rec.style
      ,p_date_from                      => l_add_rec.date_from
      ,p_date_to                        => l_add_rec.date_to
      ,p_address_type                   => l_add_rec.address_type
      --,p_comments                       => p_adr_comments
      ,p_address_line1                  => l_add_rec.address_line1
      ,p_address_line2                  => l_add_rec.address_line2
      ,p_address_line3                  => l_add_rec.address_line3
      ,p_town_or_city                   => l_add_rec.town_or_city
      ,p_region_1                       => l_add_rec.region_1
      ,p_region_2                       => l_add_rec.region_2
      ,p_region_3                       => l_add_rec.region_3
      ,p_postal_code                    => l_add_rec.postal_code
      ,p_telephone_number_1             => l_add_rec.telephone_number_1
      ,p_telephone_number_2             => l_add_rec.telephone_number_2
      ,p_telephone_number_3             => l_add_rec.telephone_number_3
      ,p_addr_attribute_category        => l_add_rec.addr_attribute_category
      ,p_addr_attribute1                => l_add_rec.addr_attribute1
      ,p_addr_attribute2                => l_add_rec.addr_attribute2
      ,p_addr_attribute3                => l_add_rec.addr_attribute3
      ,p_addr_attribute4                => l_add_rec.addr_attribute4
      ,p_addr_attribute5                => l_add_rec.addr_attribute5
      ,p_addr_attribute6                => l_add_rec.addr_attribute6
      ,p_addr_attribute7                => l_add_rec.addr_attribute7
      ,p_addr_attribute8                => l_add_rec.addr_attribute8
      ,p_addr_attribute9                => l_add_rec.addr_attribute9
      ,p_addr_attribute10               => l_add_rec.addr_attribute10
      ,p_addr_attribute11               => l_add_rec.addr_attribute11
      ,p_addr_attribute12               => l_add_rec.addr_attribute12
      ,p_addr_attribute13               => l_add_rec.addr_attribute13
      ,p_addr_attribute14               => l_add_rec.addr_attribute14
      ,p_addr_attribute15               => l_add_rec.addr_attribute15
      ,p_addr_attribute16               => l_add_rec.addr_attribute16
      ,p_addr_attribute17               => l_add_rec.addr_attribute17
      ,p_addr_attribute18               => l_add_rec.addr_attribute18
      ,p_addr_attribute19               => l_add_rec.addr_attribute19
      ,p_addr_attribute20               => l_add_rec.addr_attribute20
      ,p_add_information13              => l_add_rec.add_information13
      ,p_add_information14              => l_add_rec.add_information14
      ,p_add_information15              => l_add_rec.add_information15
      ,p_add_information16              => l_add_rec.add_information16
      ,p_add_information17              => l_add_rec.add_information17
      ,p_add_information18              => l_add_rec.add_information18
      ,p_add_information19              => l_add_rec.add_information19
      ,p_add_information20              => l_add_rec.add_information20
      ,p_party_id                       => l_add_rec.party_id
      ,p_address_user_key               => l_address_user_key
      ,p_person_user_key                => l_person_user_key
      ,p_country                        => l_add_rec.country
      );

      l_user_sequence := l_user_sequence + 1;

      hr_utility.set_location('.Inserted into Hrdpp_Create_Person_Address', 40);

     END IF;
     CLOSE csr_ck_add_xsts ;


     -- If existing person then find datetrack update mode, else it will be
     -- 'CORRECTION'

     l_datetrack_update_mode := 'CORRECTION';

--     IF p_dp_mode = 'UPDATE' THEN
--
--
--        OPEN  csr_asg (c_effective_date    => l_per_rec.start_date
--                      ,c_person_id         => l_per_rec.person_id
--                      ,c_business_group_id => l_per_rec.business_group_id
--                      );
--        FETCH csr_asg INTO l_asg_rec.assignment_id,
--                           l_asg_rec.object_version_number;
--        IF csr_asg%NOTFOUND THEN
--           CLOSE csr_asg;
--           hr_utility.raise_error;
--        END IF;
--        CLOSE csr_asg;

--        hr_utility.set_location(' l_cur_asg_rec: '||
--                                  l_asg_rec.assignment_id, 6);

--        Dt_Api.Find_DT_Upd_Modes
--        (p_effective_date        => l_per_rec.start_date
--        ,p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F'
--        ,p_base_key_column       => 'ASSIGNMENT_ID'
--        ,p_base_key_value        => l_asg_rec.assignment_id
--        ,p_correction            => l_dt_correction
--        ,p_update                => l_dt_update
--        ,p_update_override       => l_dt_upd_override
--        ,p_update_change_insert  => l_upd_chg_ins
--        );

--        IF l_dt_update THEN
--           l_datetrack_update_mode := 'UPDATE';
--        ELSIF l_dt_upd_override OR
--           l_upd_chg_ins THEN
           -- Need to check if person type in future is EMP, APL or CWK , if yes
           -- then raise error
--           l_datetrack_update_mode := 'UPDATE';
--           hr_utility.set_location(' l_dt_upd_override or' ||
--                                   ' l_upd_chg_ins ', 20);
--        ELSE
--           l_datetrack_update_mode := 'CORRECTION';
--        END IF;
--        hr_utility.set_location(' l_datetrack_update_mode: ' ||
--                                  l_datetrack_update_mode, 20);

--     ELSE
--       l_datetrack_update_mode := 'CORRECTION';
--     END IF;

     Hrdpp_Update_Emp_Asg.Insert_Batch_Lines
     (p_batch_id                      => p_batch_id
     ,p_user_sequence                 => l_user_sequence
     ,p_link_value                    => l_link_value
     ,p_effective_date                => l_per_rec.START_DATE
     ,p_datetrack_update_mode         => l_datetrack_update_mode --'CORRECTION'
     ,p_change_reason                 => l_asg_rec.change_reason
     --,p_comments                      => l_asg_rec.asg_comments
     ,p_date_probation_end            => l_asg_rec.date_probation_end
     ,p_frequency                     => l_asg_rec.frequency
     ,p_internal_address_line         => l_asg_rec.internal_address_line
     ,p_manager_flag                  => l_asg_rec.manager_flag
     ,p_normal_hours                  => l_asg_rec.normal_hours
     ,p_perf_review_period            => l_asg_rec.perf_review_period
     ,p_perf_review_period_frequency  => l_asg_rec.perf_review_period_frequency
     ,p_probation_period              => l_asg_rec.probation_period
     ,p_probation_unit                => l_asg_rec.probation_unit
     ,p_sal_review_period             => l_asg_rec.sal_review_period
     ,p_sal_review_period_frequency   => l_asg_rec.sal_review_period_frequency
     ,p_source_type                   => l_asg_rec.source_type
     ,p_time_normal_finish            => l_asg_rec.time_normal_finish
     ,p_time_normal_start             => l_asg_rec.time_normal_start
     ,p_bargaining_unit_code          => l_asg_rec.bargaining_unit_code
     ,p_labour_union_member_flag      => l_asg_rec.labour_union_member_flag
     ,p_hourly_salaried_code          => l_asg_rec.hourly_salaried_code
     ,p_ass_attribute_category        => l_asg_rec.ass_attribute_category
     ,p_ass_attribute1                => l_asg_rec.ass_attribute1
     ,p_ass_attribute2                => l_asg_rec.ass_attribute2
     ,p_ass_attribute3                => l_asg_rec.ass_attribute3
     ,p_ass_attribute4                => l_asg_rec.ass_attribute4
     ,p_ass_attribute5                => l_asg_rec.ass_attribute5
     ,p_ass_attribute6                => l_asg_rec.ass_attribute6
     ,p_ass_attribute7                => l_asg_rec.ass_attribute7
     ,p_ass_attribute8                => l_asg_rec.ass_attribute8
     ,p_ass_attribute9                => l_asg_rec.ass_attribute9
     ,p_ass_attribute10               => l_asg_rec.ass_attribute10
     ,p_ass_attribute11               => l_asg_rec.ass_attribute11
     ,p_ass_attribute12               => l_asg_rec.ass_attribute12
     ,p_ass_attribute13               => l_asg_rec.ass_attribute13
     ,p_ass_attribute14               => l_asg_rec.ass_attribute14
     ,p_ass_attribute15               => l_asg_rec.ass_attribute15
     ,p_ass_attribute16               => l_asg_rec.ass_attribute16
     ,p_ass_attribute17               => l_asg_rec.ass_attribute17
     ,p_ass_attribute18               => l_asg_rec.ass_attribute18
     ,p_ass_attribute19               => l_asg_rec.ass_attribute19
     ,p_ass_attribute20               => l_asg_rec.ass_attribute20
     ,p_ass_attribute21               => l_asg_rec.ass_attribute21
     ,p_ass_attribute22               => l_asg_rec.ass_attribute22
     ,p_ass_attribute23               => l_asg_rec.ass_attribute23
     ,p_ass_attribute24               => l_asg_rec.ass_attribute24
     ,p_ass_attribute25               => l_asg_rec.ass_attribute25
     ,p_ass_attribute26               => l_asg_rec.ass_attribute26
     ,p_ass_attribute27               => l_asg_rec.ass_attribute27
     ,p_ass_attribute28               => l_asg_rec.ass_attribute28
     ,p_ass_attribute29               => l_asg_rec.ass_attribute29
     ,p_ass_attribute30               => l_asg_rec.ass_attribute30
     --,p_title                         => l_asg_rec.title
     ,p_segment1                      => l_hr_soft_rec.segment1
     ,p_segment2                      => l_hr_soft_rec.segment2
     ,p_segment3                      => l_hr_soft_rec.segment3
     ,p_segment4                      => l_hr_soft_rec.segment4
     ,p_segment5                      => l_hr_soft_rec.segment5
     ,p_segment6                      => l_hr_soft_rec.segment6
     ,p_segment7                      => l_hr_soft_rec.segment7
     ,p_segment8                      => l_hr_soft_rec.segment8
     ,p_segment9                      => l_hr_soft_rec.segment9
     ,p_cagr_grade_def_id             => NULL
     ,p_assignment_user_key           => l_assignment_user_key
     ,p_con_seg_user_name             => NULL
     );

     l_user_sequence := l_user_sequence + 1;

     hr_utility.set_location('..Inserted into Hrdpp_Update_Emp_Asg', 50);


     OPEN  csr_grade(l_asg_rec.grade_id
                    ,l_asg_rec.business_group_id
                    ,l_per_rec.START_DATE);
     FETCH csr_grade INTO l_grade_name;
     IF csr_grade%NOTFOUND THEN
        hr_utility.set_location('..Grade Name not found Id: ' ||
	                         l_asg_rec.grade_id, 60);
     END IF;
     CLOSE csr_grade;

     OPEN  csr_position (l_asg_rec.position_id
                        ,l_asg_rec.business_group_id
                        ,l_per_rec.START_DATE);
     FETCH csr_position INTO l_position_name;
     IF csr_position%NOTFOUND THEN
        hr_utility.set_location('..Position Name not found Id: ' ||
                                l_asg_rec.position_id, 70);
     END IF;
     CLOSE csr_position;

     OPEN  csr_job(l_asg_rec.job_id
                  ,l_asg_rec.business_group_id
                  ,l_per_rec.START_DATE);
     FETCH csr_job INTO l_job_name;
     IF csr_job%NOTFOUND THEN
        hr_utility.set_location('..Job Name not found Id: ' ||
                                l_asg_rec.job_id, 80);
     END IF;
     CLOSE csr_job;

     OPEN  csr_payroll(l_asg_rec.payroll_id
                      ,l_asg_rec.business_group_id
                      ,l_per_rec.START_DATE);
     FETCH csr_payroll INTO l_payroll_name;
     IF csr_payroll%NOTFOUND THEN
        hr_utility.set_location('..Payroll Name not found Id: ' ||
                                l_asg_rec.payroll_id, 90);
     END IF;
     CLOSE csr_payroll;

     OPEN  csr_location(l_asg_rec.location_id
                       ,l_asg_rec.business_group_id);
     FETCH csr_location INTO l_location_code;
     IF csr_location%NOTFOUND THEN
        hr_utility.set_location('..Location Code not found, Id: ' ||
                                l_asg_rec.location_id, 100);
     END IF;
     CLOSE csr_location;

     OPEN  csr_organization(l_asg_rec.organization_id
                           ,l_asg_rec.business_group_id
                           ,l_per_rec.START_DATE);
     FETCH csr_organization INTO l_organization_name;
     IF csr_organization%NOTFOUND THEN
        hr_utility.set_location('..Org Name not found, Id: ' ||
                                l_asg_rec.organization_id, 110);
     END IF;
     CLOSE csr_organization;

     OPEN  csr_paybasis(l_asg_rec.pay_basis_id
                       ,l_asg_rec.business_group_id);
     FETCH csr_paybasis INTO l_pay_basis_name;
     IF csr_paybasis%NOTFOUND THEN
        hr_utility.set_location('..Org Name not found, Id: ' ||
                                l_asg_rec.pay_basis_id, 120);
     END IF;
     CLOSE csr_paybasis;

     Hrdpp_Update_Emp_Asg_Criteria.Insert_Batch_Lines
     (p_batch_id                => p_batch_id
     ,p_user_sequence           => l_user_sequence
     ,p_link_value              => l_link_value
     ,p_effective_date          => l_per_rec.START_DATE
     ,p_datetrack_update_mode   => l_datetrack_update_mode --'CORRECTION'
     ,p_segment1                => l_ppl_grp_rec.segment1
     ,p_segment2                => l_ppl_grp_rec.segment2
     ,p_segment3                => l_ppl_grp_rec.segment3
     ,p_segment4                => l_ppl_grp_rec.segment4
     ,p_segment5                => l_ppl_grp_rec.segment5
     ,p_segment6                => l_ppl_grp_rec.segment6
     ,p_segment7                => l_ppl_grp_rec.segment7
     ,p_segment8                => l_ppl_grp_rec.segment8
     ,p_segment9                => l_ppl_grp_rec.segment9
     ,p_segment10               => l_ppl_grp_rec.segment10
     ,p_segment11               => l_ppl_grp_rec.segment11
     ,p_segment12               => l_ppl_grp_rec.segment12
     ,p_segment13               => l_ppl_grp_rec.segment13
     ,p_segment14               => l_ppl_grp_rec.segment14
     ,p_segment15               => l_ppl_grp_rec.segment15
     ,p_segment16               => l_ppl_grp_rec.segment16
     ,p_segment17               => l_ppl_grp_rec.segment17
     ,p_segment18               => l_ppl_grp_rec.segment18
     ,p_segment19               => l_ppl_grp_rec.segment19
     ,p_segment20               => l_ppl_grp_rec.segment20
     ,p_segment21               => l_ppl_grp_rec.segment21
     ,p_segment22               => l_ppl_grp_rec.segment22
     ,p_segment23               => l_ppl_grp_rec.segment23
     ,p_segment24               => l_ppl_grp_rec.segment24
     ,p_segment25               => l_ppl_grp_rec.segment25
     ,p_segment26               => l_ppl_grp_rec.segment26
     ,p_segment27               => l_ppl_grp_rec.segment27
     ,p_segment28               => l_ppl_grp_rec.segment28
     ,p_segment29               => l_ppl_grp_rec.segment29
     ,p_segment30               => l_ppl_grp_rec.segment30
     ,p_special_ceiling_step_id => NULL
     ,p_people_group_id         => NULL
     ,p_assignment_user_key     => l_assignment_user_key
     ,p_grade_name              => l_grade_name
     ,p_position_name           => l_position_name
     ,p_job_name                => l_job_name
     ,p_payroll_name            => l_payroll_name
     ,p_location_code           => l_location_code
     ,p_organization_name       => l_organization_name
     ,p_pay_basis_name          => l_pay_basis_name
     ,p_language_code           => Userenv('LANG')
     ,p_con_seg_user_name       => NULL
     );

     l_user_sequence := l_user_sequence + 1;

     hr_utility.set_location('..Inserted into' ||
                             ' Hrdpp_Update_Emp_Asg_Criteria', 130);

  OPEN  csr_get_cont_dtls(c_person_id         => l_per_rec.person_id
                        ,c_business_group_id => l_add_rec.business_group_id
                        ,c_effective_date    => l_per_rec.START_DATE);
  FETCH csr_get_cont_dtls INTO l_cont_rec;

  -- Create Contact if Contact Doesn't exist or if it is being
  -- created for new Person. Also call the API only if l_cntct_rec.contact_type
  -- is not null
  IF (csr_get_cont_dtls%NOTFOUND OR p_dp_mode = 'INSERT') AND
     l_cntct_rec.contact_type IS NOT NULL THEN

     Hrdpp_Create_Contact.Insert_Batch_Lines
     (p_batch_id             => p_batch_id
     ,p_user_sequence        => l_user_sequence
     ,p_link_value           => l_link_value
     ,p_start_date           => l_per_rec.START_DATE
     ,p_contact_type         => l_cntct_rec.contact_type
     ,p_primary_contact_flag => l_cntct_rec.primary_contact_flag
     ,p_personal_flag        => l_cntct_rec.personal_flag
     ,p_last_name            => p_contact_name
     ,p_per_person_user_key  => l_contact_key
     ,p_person_user_key      => l_person_user_key
     ,p_language_code        => Userenv('LANG')
     );

     l_user_sequence := l_user_sequence + 1;

  ELSIF p_dp_mode = 'UPDATE' AND
     l_cntct_rec.contact_type IS NOT NULL THEN

     hr_pump_utils.add_user_key(p_user_key_value => l_contact_key
                               ,p_unique_key_id  => l_cont_rec.contact_person_id
                               );

     Hrdpp_Update_Contact_Relations.Insert_Batch_Lines
     (p_batch_id              => p_batch_id
     ,p_user_sequence         => l_user_sequence
     ,p_link_value            => l_link_value
     ,p_effective_date        => l_per_rec.START_DATE
     ,p_contact_type          => l_cntct_rec.contact_type
     ,p_primary_contact_flag  => l_cntct_rec.primary_contact_flag
     ,p_personal_flag         => l_cntct_rec.personal_flag
     ,p_object_version_number => l_cont_rec.object_version_number
     ,p_contact_user_key      => l_contact_key --l_person_user_key
     ,p_contactee_user_key    => l_person_user_key
     );

     l_user_sequence := l_user_sequence + 1;

  END IF;
  CLOSE csr_get_cont_dtls;

  hr_utility.set_location('..Inserted into Hrdpp_Create_Contact', 140);

  -- Call to People Extra Information Procedure
  HR_DataPump_Per_XtraInfo
         (p_business_group_id => l_per_rec.business_group_id
         ,p_person_id         => l_per_rec.person_id
         ,p_party_id          => l_per_rec.party_id
         ,p_effective_date    => l_per_rec.START_DATE
         ,p_batch_id          => p_batch_id
         ,p_user_sequence     => l_user_sequence
         ,p_link_value        => l_link_value
         ,p_xtra_info_key     => l_xtra_info_key
         ,p_person_user_key   => l_person_user_key
         );

  l_user_sequence := l_user_sequence + 1;

  hr_utility.set_location('..Called HR_DataPump_Per_XtraInfo', 150);

  hr_utility.set_location('Leaving: ' || l_proc_name, 160);

EXCEPTION
  WHEN Others THEN
       IF csr_asg%ISOPEN THEN
          CLOSE csr_asg;
       END IF;

       IF csr_get_link_value%ISOPEN THEN
          CLOSE csr_get_link_value;
       END IF;

       IF csr_per%ISOPEN THEN
          CLOSE csr_per;
       END IF;

       IF csr_per_type%ISOPEN THEN
          CLOSE csr_per_type;
       END IF;

       IF csr_get_employee_num%ISOPEN THEN
          CLOSE csr_get_employee_num;
       END IF;

       IF csr_ck_add_xsts%ISOPEN THEN
          CLOSE csr_ck_add_xsts;
       END IF;

       IF csr_get_cont_dtls%ISOPEN THEN
          CLOSE csr_get_cont_dtls;
       END IF;

       hr_utility.set_location('Leaving: ' || l_proc_name, 170);

  RAISE;

END HR_DataPump;


-- =============================================================================
-- ~ HR_DataPumpErr:
-- =============================================================================
PROCEDURE HR_DataPumpErr
          (p_data_pump_batch_line_id IN Varchar2
          ,p_batch_id                IN Number
          ,p_contact_name            IN Varchar
--          ,p_dp_mode                 IN Varchar
          ,p_adjusted_svc_date       IN Date
          )
AS

  -- Cursor gets the mode in which data was entered intially in
  -- DP interface tables
  CURSOR csr_get_dp_mode (c_batch_id   IN Number
                         ,c_link_value IN Number) IS
  SELECT 'CREATE'
    FROM hr_api_modules
   WHERE module_name    = 'CREATE_EMPLOYEE'
     AND module_package = 'HR_EMPLOYEE_API'
     AND api_module_id IN (SELECT api_module_id
                             FROM hr_pump_batch_lines
                            WHERE batch_id   = c_batch_id
                              AND link_value = c_link_value);

  -- Cursor to get all the api_ids which have LINE_STATUS in status 'C' or 'U'
  CURSOR csr_get_api_names (c_batch_id   IN Number
                           ,c_link_value IN Number) IS
  SELECT module_name
    FROM hr_pump_batch_lines hpbl, hr_api_modules ham
   WHERE batch_id    = c_batch_id
     AND link_value  = c_link_value
     AND line_status IN ('U', 'E')
     AND hpbl.api_module_id = ham.api_module_id;

-- Not Required, Delete Later
--  -- Cursor to check if Address was End Dated or Updated
--  CURSOR csr_chk_add_end_dated (c_batch_id   IN Number
--                               ,c_link_value IN Number) IS
--  SELECT 'END DATED'
--  FROM dual
--  WHERE
--      'UPDATE_PERSON_ADDRESS' IN
--      (SELECT module_name
--         FROM hr_pump_batch_lines hpbl, hr_api_modules ham
--        WHERE batch_id           = c_batch_id
--          AND link_value         = c_link_value
--          AND hpbl.api_module_id = ham.api_module_id
--          AND line_status     IN ('U', 'E'))
--  AND 'CREATE_PERSON_ADDRESS' IN
--      (SELECT module_name
--         FROM hr_pump_batch_lines hpbl, hr_api_modules ham
--        WHERE batch_id           = c_batch_id
--          AND link_value         = c_link_value
--          AND hpbl.api_module_id = ham.api_module_id
--          AND line_status     IN ('U', 'E'));

  -- Cursor to get previous data from hrdpv_hire_into_job
  CURSOR csr_get_hire_job_data (c_batch_id   IN Number
                               ,c_link_value IN Number) IS
  SELECT *
    FROM hrdpv_hire_into_job
   WHERE batch_id   = c_batch_id
     AND link_value = c_link_value;

  l_dp_hire_job_rec      hrdpv_hire_into_job%ROWTYPE;

  -- Cursor to get previous data from hrdpv_create_employee
  CURSOR csr_get_create_emp_data (c_batch_id   IN Number
                                 ,c_link_value IN Number) IS
  SELECT *
    FROM hrdpv_create_employee
   WHERE batch_id   = c_batch_id
     AND link_value = c_link_value;

  l_dp_crt_emp_rec       hrdpv_create_employee%ROWTYPE;

  -- Cursor to get previous data from hrdpv_update_person
  CURSOR csr_get_update_per_data (c_batch_id   IN Number
                                 ,c_link_value IN Number) IS
  SELECT *
    FROM hrdpv_update_person
   WHERE batch_id   = c_batch_id
     AND link_value = c_link_value;

  l_dp_upd_per_rec       hrdpv_update_person%ROWTYPE;

  -- Cursor to get previous data from hrdpv_update_person_address
  CURSOR csr_get_update_add_data (c_batch_id   IN Number
                                 ,c_link_value IN Number) IS
  SELECT *
    FROM hrdpv_update_person_address
   WHERE batch_id   = c_batch_id
     AND link_value = c_link_value;

  l_dp_upd_add_rec       hrdpv_update_person_address%ROWTYPE;

  -- Cursor to get previous data from hrdpv_create_person_address
  CURSOR csr_get_create_add_data (c_batch_id   IN Number
                                 ,c_link_value IN Number) IS
  SELECT *
    FROM hrdpv_create_person_address
   WHERE batch_id   = c_batch_id
     AND link_value = c_link_value;

  l_dp_crt_add_rec       hrdpv_create_person_address%ROWTYPE;

  -- Cursor to get previous data from hrdpv_update_emp_asg
  CURSOR csr_get_upd_asg_data (c_batch_id   IN Number
                              ,c_link_value IN Number) IS
  SELECT *
    FROM hrdpv_update_emp_asg
   WHERE batch_id   = c_batch_id
     AND link_value = c_link_value;

  l_dp_upd_asg_rec       hrdpv_update_emp_asg%ROWTYPE;

  -- Cursor to get previous data from hrdpv_update_emp_asg_criteria
  CURSOR csr_get_upd_asg_crt_data (c_batch_id   IN Number
                                   ,c_link_value IN Number) IS
  SELECT *
    FROM hrdpv_update_emp_asg_criteria
   WHERE batch_id   = c_batch_id
     AND link_value = c_link_value;

  l_dp_upd_asg_crt_rec   hrdpv_update_emp_asg_criteria%ROWTYPE;

  -- Cursor to get previous data from hrdpv_create_contact
  CURSOR csr_get_create_cnt_data (c_batch_id   IN Number
                                 ,c_link_value IN Number) IS
  SELECT *
    FROM hrdpv_create_contact
   WHERE batch_id   = c_batch_id
     AND link_value = c_link_value;

  l_dp_crt_cnt_rec       hrdpv_create_contact%ROWTYPE;

  -- Cursor to get previous data from hrdpv_update_contact_relations
  CURSOR csr_get_update_cnt_data (c_batch_id   IN Number
                                 ,c_link_value IN Number) IS
  SELECT *
    FROM hrdpv_update_contact_relations
   WHERE batch_id   = c_batch_id
     AND link_value = c_link_value;

  l_dp_upd_cnt_rec      hrdpv_update_contact_relations%ROWTYPE;

  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'HR_DataPumpErr';

  l_dp_mode                  Varchar2(10);
  l_if_end_dated             Varchar2(20);
  l_api_name                 hr_api_modules.module_name%TYPE;
  l_user_person_type         per_person_types.user_person_type%TYPE;
  l_pay_basis_name           per_pay_bases.NAME%TYPE;
  l_organization_name        hr_all_organization_units.NAME%TYPE;
  l_location_code            hr_locations_all.location_code%TYPE;
  l_payroll_name             pay_payrolls_f.payroll_name%TYPE;
  l_job_name                 per_jobs.NAME%TYPE;
  l_position_name            per_positions.NAME%TYPE;
  l_grade_name               per_grades.NAME%TYPE;

  l_pradd_ovlapval_override  Boolean;

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  -- Check if operation being corrected was insert or update because of
  -- duplicate person id based on the API_MODULE_ID in hr_pump_batch_lines
  -- and then set dp_mode flag respectively

  OPEN csr_get_dp_mode (c_batch_id   => p_batch_id
                       ,c_link_value => p_data_pump_batch_line_id
                       );
  FETCH csr_get_dp_mode INTO l_dp_mode;
  CLOSE csr_get_dp_mode;

  IF l_dp_mode = NULL THEN
     l_dp_mode := 'UPDATE';
  END IF;

  -- Cursor to get the User Person Type
  OPEN  csr_per_type(l_per_rec.person_type_id
                    ,l_per_rec.business_group_id);
  FETCH csr_per_type INTO l_user_person_type;
  CLOSE csr_per_type;

  -- If User hasn't entered the Employee Number, then get Employee Number
  -- for entered duplicate person id
  IF l_per_rec.employee_number = NULL THEN
     OPEN  csr_get_employee_num(c_person_id => l_per_rec.person_id);
     FETCH csr_get_employee_num INTO l_per_rec.employee_number;
     CLOSE csr_get_employee_num;
  END IF;

  -- Call a cursor to get all the API_MODULE_IDs for the respective batch_id
  -- where LINE_STATUS is either in 'E' (error) or in 'U' (unprocessed) mode

  OPEN csr_get_api_names (c_batch_id   => p_batch_id
                         ,c_link_value => p_data_pump_batch_line_id
                         );

  -- For all the API_MODULE_IDs hence obtained run the cursor and call
  -- corresponding HR Data Pump Insert_Batch_Lines APIs. Before calling the
  -- Insert_Batch_Lines call the cursor to get the previous values in DP
  -- Interface Tables
  --
  -- NOTE : We will be calling the same "INSERT_BATCH_LINES" for updation
  --        as internally "INSERT_BATCH_LINES" deletes the previous entry
  --        for corresponding Batch_line_Id and makes a fresh entry.
  --        Hence, in the cursor we will temporarily store some of the data
  --        which we will require in newly created entry in HR_PUMP_BATCH_LINES


  LOOP

    FETCH csr_get_api_names INTO l_api_name;
    EXIT WHEN csr_get_api_names%NOTFOUND;


    -- Call if API_ID is 'Hire_Into_Job'
    IF l_api_name = 'HIRE_INTO_JOB' THEN

       -- Call a cursor to get the current data in DP Interface Tables
       OPEN  csr_get_hire_job_data (c_batch_id   => p_batch_id
                                   ,c_link_value => p_data_pump_batch_line_id);
       FETCH csr_get_hire_job_data INTO l_dp_hire_job_rec;
       CLOSE csr_get_hire_job_data;

       -- Call Insert_Batch_lines
       Hrdpp_Hire_Into_Job.insert_batch_lines
       (p_batch_id                => p_batch_id
       --l_dp_batch_line_id_hire
       ,p_data_pump_batch_line_id => l_dp_hire_job_rec.batch_line_id
       ,p_user_sequence           => l_dp_hire_job_rec.user_sequence
       ,p_link_value              => p_data_pump_batch_line_id
       ,p_effective_date          => l_per_rec.start_date
       ,p_object_version_number   => l_dp_hire_job_rec.p_object_version_number
       ,p_datetrack_update_mode   => l_dp_hire_job_rec.p_datetrack_update_mode
       ,p_employee_number         => l_per_rec.employee_number
       ,p_national_identifier     => l_per_rec.national_identifier
       ,p_per_information7        => NULL
       ,p_person_user_key         => l_dp_hire_job_rec.p_person_user_key
       ,p_user_person_type        => l_user_person_type
       ,p_assignment_user_key     => l_dp_hire_job_rec.p_assignment_user_key
       ,p_language_code           => Userenv('LANG')
       );

    END IF;

    -- Call if API_ID is 'Create_Employee'
    IF l_api_name = 'CREATE_EMPLOYEE' THEN

       OPEN  csr_get_create_emp_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
       FETCH csr_get_create_emp_data INTO l_dp_crt_emp_rec;
       CLOSE csr_get_create_emp_data;

       Hrdpp_Create_Employee.Insert_Batch_Lines
       (p_batch_id                     => p_batch_id
       --l_dp_batch_line_id_emp
       ,p_data_pump_batch_line_id      => l_dp_crt_emp_rec.batch_line_id
       ,p_user_sequence                => l_dp_crt_emp_rec.user_sequence
       ,p_link_value                   => p_data_pump_batch_line_id
       ,p_hire_date                    => l_per_rec.start_date
       ,p_last_name                    => l_per_rec.last_name
       ,p_sex                          => l_per_rec.sex
       --,p_per_comments                 => l_per_rec.comments
       ,p_date_employee_data_verified  => l_per_rec.date_employee_data_verified
       ,p_date_of_birth                => l_per_rec.date_of_birth
       ,p_email_address                => l_per_rec.email_address
       ,p_employee_number              => l_per_rec.employee_number
       ,p_expense_check_send_to_addres =>l_per_rec.expense_check_send_to_address
       ,p_first_name                   => l_per_rec.first_name
       ,p_known_as                     => l_per_rec.known_as
       ,p_marital_status               => l_per_rec.marital_status
       ,p_middle_names                 => l_per_rec.middle_names
       ,p_nationality                  => l_per_rec.nationality
       ,p_national_identifier          => l_per_rec.national_identifier
       ,p_previous_last_name           => l_per_rec.previous_last_name
       ,p_registered_disabled_flag     => l_per_rec.registered_disabled_flag
       ,p_title                        => l_per_rec.title
       --,p_work_telephone               => p_telephone_no1
       ,p_attribute_category           => l_per_rec.attribute_category
       ,p_attribute1                   => l_per_rec.attribute1
       ,p_attribute2                   => l_per_rec.attribute2
       ,p_attribute3                   => l_per_rec.attribute3
       ,p_attribute4                   => l_per_rec.attribute4
       ,p_attribute5                   => l_per_rec.attribute5
       ,p_attribute6                   => l_per_rec.attribute6
       ,p_attribute7                   => l_per_rec.attribute7
       ,p_attribute8                   => l_per_rec.attribute8
       ,p_attribute9                   => l_per_rec.attribute9
       ,p_attribute10                  => l_per_rec.attribute10
       ,p_attribute11                  => l_per_rec.attribute11
       ,p_attribute12                  => l_per_rec.attribute12
       ,p_attribute13                  => l_per_rec.attribute13
       ,p_attribute14                  => l_per_rec.attribute14
       ,p_attribute15                  => l_per_rec.attribute15
       ,p_attribute16                  => l_per_rec.attribute16
       ,p_attribute17                  => l_per_rec.attribute17
       ,p_attribute18                  => l_per_rec.attribute18
       ,p_attribute19                  => l_per_rec.attribute19
       ,p_attribute20                  => l_per_rec.attribute20
       ,p_attribute21                  => l_per_rec.attribute21
       ,p_attribute22                  => l_per_rec.attribute22
       ,p_attribute23                  => l_per_rec.attribute23
       ,p_attribute24                  => l_per_rec.attribute24
       ,p_attribute25                  => l_per_rec.attribute25
       ,p_attribute26                  => l_per_rec.attribute26
       ,p_attribute27                  => l_per_rec.attribute27
       ,p_attribute28                  => l_per_rec.attribute28
       ,p_attribute29                  => l_per_rec.attribute29
       ,p_attribute30                  => l_per_rec.attribute30
       ,p_per_information_category     => l_per_rec.per_information_category
       ,p_per_information1             => l_per_rec.per_information1
       ,p_per_information2             => l_per_rec.per_information2
       ,p_per_information3             => l_per_rec.per_information3
       ,p_per_information4             => l_per_rec.per_information4
       ,p_per_information5             => l_per_rec.per_information5
       ,p_per_information6             => l_per_rec.per_information6
       ,p_per_information7             => l_per_rec.per_information7
       ,p_per_information8             => l_per_rec.per_information8
       ,p_per_information9             => l_per_rec.per_information9
       ,p_per_information10            => l_per_rec.per_information10
       ,p_per_information11            => l_per_rec.per_information11
       ,p_per_information12            => l_per_rec.per_information12
       ,p_per_information13            => l_per_rec.per_information13
       ,p_per_information14            => l_per_rec.per_information14
       ,p_per_information15            => l_per_rec.per_information15
       ,p_per_information16            => l_per_rec.per_information16
       ,p_per_information17            => l_per_rec.per_information17
       ,p_per_information18            => l_per_rec.per_information18
       ,p_per_information19            => l_per_rec.per_information19
       ,p_per_information20            => l_per_rec.per_information20
       ,p_per_information21            => l_per_rec.per_information21
       ,p_per_information22            => l_per_rec.per_information22
       ,p_per_information23            => l_per_rec.per_information23
       ,p_per_information24            => l_per_rec.per_information24
       ,p_per_information25            => l_per_rec.per_information25
       ,p_per_information26            => l_per_rec.per_information26
       ,p_per_information27            => l_per_rec.per_information27
       ,p_per_information28            => l_per_rec.per_information28
       ,p_per_information29            => l_per_rec.per_information29
       ,p_per_information30            => l_per_rec.per_information30
       ,p_date_of_death                => l_per_rec.date_of_death
       ,p_background_check_status      => l_per_rec.background_check_status
       ,p_background_date_check        => l_per_rec.background_date_check
       ,p_blood_type                   => l_per_rec.blood_type
       ,p_fast_path_employee           => l_per_rec.fast_path_employee
       ,p_fte_capacity                 => l_per_rec.fte_capacity
       ,p_honors                       => l_per_rec.honors
       ,p_internal_location            => l_per_rec.internal_location
       ,p_last_medical_test_by         => l_per_rec.last_medical_test_by
       ,p_last_medical_test_date       => l_per_rec.last_medical_test_date
       ,p_mailstop                     => l_per_rec.mailstop
       ,p_office_number                => l_per_rec.office_number
       ,p_on_military_service          => l_per_rec.on_military_service
       ,p_pre_name_adjunct             => l_per_rec.pre_name_adjunct
       ,p_projected_start_date         => l_per_rec.projected_start_date
       ,p_resume_exists                => l_per_rec.resume_exists
       ,p_resume_last_updated          => l_per_rec.resume_last_updated
       ,p_second_passport_exists       => l_per_rec.second_passport_exists
       ,p_student_status               => l_per_rec.student_status
       ,p_work_schedule                => l_per_rec.work_schedule
       ,p_suffix                       => l_per_rec.suffix
       ,p_receipt_of_death_cert_date   => l_per_rec.receipt_of_death_cert_date
       ,p_coord_ben_med_pln_no         => l_per_rec.coord_ben_med_pln_no
       ,p_coord_ben_no_cvg_flag        => l_per_rec.coord_ben_no_cvg_flag
       ,p_coord_ben_med_ext_er         => l_per_rec.coord_ben_med_ext_er
       ,p_coord_ben_med_pl_name        => l_per_rec.coord_ben_med_pl_name
       ,p_coord_ben_med_insr_crr_name  => l_per_rec.coord_ben_med_insr_crr_name
       ,p_coord_ben_med_insr_crr_ident => l_per_rec.coord_ben_med_insr_crr_ident
       ,p_coord_ben_med_cvg_strt_dt    => l_per_rec.coord_ben_med_cvg_strt_dt
       ,p_coord_ben_med_cvg_end_dt     => l_per_rec.coord_ben_med_cvg_end_dt
       ,p_uses_tobacco_flag            => l_per_rec.uses_tobacco_flag
       ,p_dpdnt_adoption_date          => l_per_rec.dpdnt_adoption_date
       ,p_dpdnt_vlntry_svce_flag       => l_per_rec.dpdnt_vlntry_svce_flag
       ,p_original_date_of_hire        => l_per_rec.original_date_of_hire
       --,p_adjusted_svc_date            => p_adjusted_svc_date
       ,p_town_of_birth                => l_per_rec.town_of_birth
       ,p_region_of_birth              => l_per_rec.region_of_birth
       ,p_country_of_birth             => l_per_rec.country_of_birth
       ,p_global_person_id             => l_per_rec.global_person_id
       ,p_party_id                     => l_per_rec.party_id
       ,p_correspondence_language      => l_per_rec.correspondence_language
       ,p_benefit_group                => l_per_rec.benefit_group_id
       ,p_person_user_key              => l_dp_crt_emp_rec.p_person_user_key
       ,p_assignment_user_key          => l_dp_crt_emp_rec.p_assignment_user_key
       ,p_user_person_type             => l_user_person_type
       ,p_language_code                => Userenv('lang')
       ,p_vendor_name                  => NULL
       );
    END IF;

    -- Call if API_ID is 'Update_Person'
    IF l_api_name = 'UPDATE_PERSON' THEN

       OPEN  csr_get_update_per_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
       FETCH csr_get_update_per_data INTO l_dp_upd_per_rec;
       CLOSE csr_get_update_per_data;

     Hrdpp_Update_Person.insert_batch_lines
     (p_batch_id                     => p_batch_id
     ,p_data_pump_batch_line_id      => l_dp_upd_per_rec.batch_line_id
     ,p_user_sequence                => l_dp_upd_per_rec.user_sequence
     ,p_link_value                   => p_data_pump_batch_line_id
     ,p_effective_date               => l_per_rec.start_date
     ,p_datetrack_update_mode        => l_dp_upd_per_rec.p_datetrack_update_mode
     ,p_party_id                     => l_per_rec.party_id
     ,p_employee_number              => l_per_rec.employee_number
     ,p_last_name                    => l_per_rec.last_name
     ,p_first_name                   => l_per_rec.first_name
     ,p_date_of_birth                => l_per_rec.date_of_birth
     ,p_marital_status               => l_per_rec.marital_status
     ,p_middle_names                 => l_per_rec.middle_names
     ,p_sex                          => l_per_rec.sex
     ,p_title                        => l_per_rec.title
     ,p_nationality                  => l_per_rec.nationality
     ,p_previous_last_name           => l_per_rec.previous_last_name
     ,p_known_as                     => l_per_rec.known_as
     ,p_email_address                => l_per_rec.email_address
     ,p_registered_disabled_flag     => l_per_rec.registered_disabled_flag
     ,p_date_employee_data_verified  => l_per_rec.date_employee_data_verified
     ,p_expense_check_send_to_addres => l_per_rec.expense_check_send_to_address

      -- Person DDF
     ,p_per_information_category     => l_per_rec.per_information_category
     ,p_per_information1             => l_per_rec.per_information1
     ,p_per_information2             => l_per_rec.per_information2
     ,p_per_information3             => l_per_rec.per_information3
     ,p_per_information4             => l_per_rec.per_information4
     ,p_per_information5             => l_per_rec.per_information5
     ,p_per_information6             => l_per_rec.per_information6
     ,p_per_information7             => l_per_rec.per_information7
     ,p_per_information8             => l_per_rec.per_information8
     ,p_per_information9             => l_per_rec.per_information9
     ,p_per_information10            => l_per_rec.per_information10
     ,p_per_information11            => l_per_rec.per_information11
     ,p_per_information12            => l_per_rec.per_information12
     ,p_per_information13            => l_per_rec.per_information13
     ,p_per_information14            => l_per_rec.per_information14
     ,p_per_information15            => l_per_rec.per_information15
     ,p_per_information16            => l_per_rec.per_information16
     ,p_per_information17            => l_per_rec.per_information17
     ,p_per_information18            => l_per_rec.per_information18
     ,p_per_information19            => l_per_rec.per_information19
     ,p_per_information20            => l_per_rec.per_information20
     ,p_per_information21            => l_per_rec.per_information21
     ,p_per_information22            => l_per_rec.per_information22
     ,p_per_information23            => l_per_rec.per_information23
     ,p_per_information24            => l_per_rec.per_information24
     ,p_per_information25            => l_per_rec.per_information25
     ,p_per_information26            => l_per_rec.per_information26
     ,p_per_information27            => l_per_rec.per_information27
     ,p_per_information28            => l_per_rec.per_information28
     ,p_per_information29            => l_per_rec.per_information29
     ,p_per_information30            => l_per_rec.per_information30

     -- Person DF
     ,p_attribute_category           => l_per_rec.attribute_category
     ,p_attribute1                   => l_per_rec.attribute1
     ,p_attribute2                   => l_per_rec.attribute2
     ,p_attribute3                   => l_per_rec.attribute3
     ,p_attribute4                   => l_per_rec.attribute4
     ,p_attribute5                   => l_per_rec.attribute5
     ,p_attribute6                   => l_per_rec.attribute6
     ,p_attribute7                   => l_per_rec.attribute7
     ,p_attribute8                   => l_per_rec.attribute8
     ,p_attribute9                   => l_per_rec.attribute9
     ,p_attribute10                  => l_per_rec.attribute10
     ,p_attribute11                  => l_per_rec.attribute11
     ,p_attribute12                  => l_per_rec.attribute12
     ,p_attribute13                  => l_per_rec.attribute13
     ,p_attribute14                  => l_per_rec.attribute14
     ,p_attribute15                  => l_per_rec.attribute15
     ,p_attribute16                  => l_per_rec.attribute16
     ,p_attribute17                  => l_per_rec.attribute17
     ,p_attribute18                  => l_per_rec.attribute18
     ,p_attribute19                  => l_per_rec.attribute19
     ,p_attribute20                  => l_per_rec.attribute20
     ,p_attribute21                  => l_per_rec.attribute21
     ,p_attribute22                  => l_per_rec.attribute22
     ,p_attribute23                  => l_per_rec.attribute23
     ,p_attribute24                  => l_per_rec.attribute24
     ,p_attribute25                  => l_per_rec.attribute25
     ,p_attribute26                  => l_per_rec.attribute26
     ,p_attribute27                  => l_per_rec.attribute27
     ,p_attribute28                  => l_per_rec.attribute28
     ,p_attribute29                  => l_per_rec.attribute29
     ,p_attribute30                  => l_per_rec.attribute30

   --,p_vendor_id                    => l_per_rec.vendor_id
   --,p_work_telephone               => l_per_rec.vendor_id
     ,p_date_of_death                => l_per_rec.date_of_death
     ,p_background_check_status      => l_per_rec.background_check_status
     ,p_background_date_check        => l_per_rec.background_date_check
     ,p_blood_type                   => l_per_rec.blood_type
     ,p_correspondence_language      => l_per_rec.correspondence_language
   --,p_fast_path_employee           IN  Varchar2 DEFAULT Hr_Api.g_Varchar2
     ,p_fte_capacity                 => l_per_rec.fte_capacity
     ,p_hold_applicant_date_until    => l_per_rec.hold_applicant_date_until
     ,p_honors                       => l_per_rec.honors
     ,p_internal_location            => l_per_rec.internal_location
     ,p_last_medical_test_by         => l_per_rec.last_medical_test_by
     ,p_last_medical_test_date       => l_per_rec.last_medical_test_date
     ,p_mailstop                     => l_per_rec.mailstop
     ,p_office_number                => l_per_rec.office_number
     ,p_on_military_service          => l_per_rec.on_military_service
     ,p_pre_name_adjunct             => l_per_rec.pre_name_adjunct
     ,p_projected_start_date         => l_per_rec.projected_start_date
     ,p_rehire_authorizor            => l_per_rec.rehire_authorizor
     ,p_rehire_recommendation        => l_per_rec.rehire_recommendation
     ,p_resume_exists                => l_per_rec.resume_exists
     ,p_resume_last_updated          => l_per_rec.resume_last_updated
     ,p_second_passport_exists       => l_per_rec.second_passport_exists
     ,p_student_status               => l_per_rec.student_status
     ,p_work_schedule                => l_per_rec.work_schedule
     ,p_rehire_reason                => l_per_rec.rehire_reason
     ,p_suffix                       => l_per_rec.suffix
     ,p_benefit_group                => l_per_rec.benefit_group_id
     ,p_receipt_of_death_cert_date   => l_per_rec.receipt_of_death_cert_date
     ,p_coord_ben_med_pln_no         => l_per_rec.coord_ben_med_pln_no
     ,p_coord_ben_no_cvg_flag        => l_per_rec.coord_ben_no_cvg_flag
     ,p_coord_ben_med_ext_er         => l_per_rec.coord_ben_med_ext_er
     ,p_coord_ben_med_pl_name        => l_per_rec.coord_ben_med_pl_name
     ,p_coord_ben_med_insr_crr_name  => l_per_rec.coord_ben_med_insr_crr_name
     ,p_coord_ben_med_insr_crr_ident => l_per_rec.coord_ben_med_insr_crr_ident
     ,p_coord_ben_med_cvg_strt_dt    => l_per_rec.coord_ben_med_cvg_strt_dt
     ,p_coord_ben_med_cvg_end_dt     => l_per_rec.coord_ben_med_cvg_end_dt
     ,p_uses_tobacco_flag            => l_per_rec.uses_tobacco_flag
     ,p_dpdnt_adoption_date          => l_per_rec.dpdnt_adoption_date
     ,p_dpdnt_vlntry_svce_flag       => l_per_rec.dpdnt_vlntry_svce_flag
     ,p_original_date_of_hire        => l_per_rec.original_date_of_hire
     ,p_adjusted_svc_date            => p_adjusted_svc_date
     ,p_town_of_birth                => l_per_rec.town_of_birth
     ,p_region_of_birth              => l_per_rec.region_of_birth
     ,p_country_of_birth             => l_per_rec.country_of_birth
     ,p_global_person_id             => l_per_rec.global_person_id
     ,p_person_user_key              => l_dp_upd_per_rec.p_person_user_key
     ,p_user_person_type             => l_dp_upd_per_rec.p_user_person_type
     ,p_language_code                => Userenv('lang')
     ,p_vendor_name                  => NULL
     );

    END IF;

    -- Call if API_ID is 'Update_Address'
    IF l_api_name = 'UPDATE_PERSON_ADDRESS' THEN
       OPEN  csr_get_update_add_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
       FETCH csr_get_update_add_data INTO l_dp_upd_add_rec;
       CLOSE csr_get_update_add_data;

-- Code has been commented as the Logic for Address has changed, hence we no
-- longer require the below logic, will be removed later

--       -- Check if while updating address we end dated the address and then
--       -- created a new address or simply updated the address. To find that
--       -- out, we will check if for the said batch_id and link_value
--       -- we have both Update and Create Address. If that is the case then
--       -- that implies that address was end dated and then new one was created
--       -- else it was simply updated.
--       -- Incase address was updated to end date then, we will use
--       -- "l_dp_upd_add_rec" else we will use "l_add_rec"

--       OPEN  csr_chk_add_end_dated (c_batch_id   => p_batch_id
--                                   ,c_link_value => p_data_pump_batch_line_id
--                                   );
--       FETCH csr_chk_add_end_dated INTO l_if_end_dated;
--       CLOSE csr_chk_add_end_dated;

--       IF l_if_end_dated = 'END DATED' THEN

--          -- Don't do anything since in that case only date_to field was
--          -- updated, which can't be wrong. Rest of the data was previous
--          -- address data which can't be wrong and anyways user is not allowed
--          -- to update that.
--          NULL;

--       ELSE

          Hrdpp_Update_Person_Address.Insert_Batch_Lines
          (p_batch_id                => p_batch_id
           --l_dp_batch_line_id_up_add
          ,p_data_pump_batch_line_id => l_dp_upd_add_rec.batch_line_id
          ,p_user_sequence           => l_dp_upd_add_rec.user_sequence
          ,p_link_value              => p_data_pump_batch_line_id
          ,p_effective_date          => l_per_rec.start_date
          ,p_validate_county         => FALSE
          ,p_primary_flag            => l_add_rec.primary_flag
          ,p_date_from               => l_add_rec.date_from
          ,p_date_to                 => l_add_rec.date_to
          ,p_address_type            => l_add_rec.address_type
          --,p_comments              => p_adr_comments
          ,p_address_line1           => l_add_rec.address_line1
          ,p_address_line2           => l_add_rec.address_line2
          ,p_address_line3           => l_add_rec.address_line3
          ,p_town_or_city            => l_add_rec.town_or_city
          ,p_region_1                => l_add_rec.region_1
          ,p_region_2                => l_add_rec.region_2
          ,p_region_3                => l_add_rec.region_3
          ,p_postal_code             => l_add_rec.postal_code
          ,p_telephone_number_1      => l_add_rec.telephone_number_1
          ,p_telephone_number_2      => l_add_rec.telephone_number_2
          ,p_telephone_number_3      => l_add_rec.telephone_number_3
          ,p_addr_attribute_category => l_add_rec.addr_attribute_category
          ,p_addr_attribute1         => l_add_rec.addr_attribute1
          ,p_addr_attribute2         => l_add_rec.addr_attribute2
          ,p_addr_attribute3         => l_add_rec.addr_attribute3
          ,p_addr_attribute4         => l_add_rec.addr_attribute4
          ,p_addr_attribute5         => l_add_rec.addr_attribute5
          ,p_addr_attribute6         => l_add_rec.addr_attribute6
          ,p_addr_attribute7         => l_add_rec.addr_attribute7
          ,p_addr_attribute8         => l_add_rec.addr_attribute8
          ,p_addr_attribute9         => l_add_rec.addr_attribute9
          ,p_addr_attribute10        => l_add_rec.addr_attribute10
          ,p_addr_attribute11        => l_add_rec.addr_attribute11
          ,p_addr_attribute12        => l_add_rec.addr_attribute12
          ,p_addr_attribute13        => l_add_rec.addr_attribute13
          ,p_addr_attribute14        => l_add_rec.addr_attribute14
          ,p_addr_attribute15        => l_add_rec.addr_attribute15
          ,p_addr_attribute16        => l_add_rec.addr_attribute16
          ,p_addr_attribute17        => l_add_rec.addr_attribute17
          ,p_addr_attribute18        => l_add_rec.addr_attribute18
          ,p_addr_attribute19        => l_add_rec.addr_attribute19
          ,p_addr_attribute20        => l_add_rec.addr_attribute20
          ,p_add_information13       => l_add_rec.add_information13
          ,p_add_information14       => l_add_rec.add_information14
          ,p_add_information15       => l_add_rec.add_information15
          ,p_add_information16       => l_add_rec.add_information16
          ,p_add_information17       => l_add_rec.add_information17
          ,p_add_information18       => l_add_rec.add_information18
          ,p_add_information19       => l_add_rec.add_information19
          ,p_add_information20       => l_add_rec.add_information20
          ,p_party_id                => l_add_rec.party_id
          ,p_address_user_key        => l_dp_upd_add_rec.p_address_user_key
          ,p_country                 => l_add_rec.country
          );
--       END IF;
    END IF;

    -- Call if API_ID is 'Create_Address'
    IF l_api_name = 'CREATE_PERSON_ADDRESS' THEN

       OPEN  csr_get_create_add_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
       FETCH csr_get_create_add_data INTO l_dp_crt_add_rec;
       CLOSE csr_get_create_add_data;

       -- Convert String value of p_pradd_ovlapval_override to Boolean
       IF l_dp_crt_add_rec.p_pradd_ovlapval_override = 'FALSE' THEN
          l_pradd_ovlapval_override := FALSE;
       ELSE
          l_pradd_ovlapval_override := FALSE;
       END IF;

       Hrdpp_Create_Person_Address.Insert_Batch_Lines
       (p_batch_id                       => p_batch_id
       --l_dp_batch_line_id_cr_add
       ,p_data_pump_batch_line_id        => l_dp_crt_add_rec.batch_line_id
       ,p_user_sequence                  => l_dp_crt_add_rec.user_sequence
       ,p_link_value                     => p_data_pump_batch_line_id
       ,p_effective_date                 => l_per_rec.start_date
       ,p_pradd_ovlapval_override        => l_pradd_ovlapval_override
       ,p_validate_county                => FALSE
       ,p_primary_flag                   => l_add_rec.primary_flag
       ,p_style                          => l_add_rec.style
       ,p_date_from                      => l_add_rec.date_from
       ,p_date_to                        => l_add_rec.date_to
       ,p_address_type                   => l_add_rec.address_type
       --,p_comments                       => p_adr_comments
       ,p_address_line1                  => l_add_rec.address_line1
       ,p_address_line2                  => l_add_rec.address_line2
       ,p_address_line3                  => l_add_rec.address_line3
       ,p_town_or_city                   => l_add_rec.town_or_city
       ,p_region_1                       => l_add_rec.region_1
       ,p_region_2                       => l_add_rec.region_2
       ,p_region_3                       => l_add_rec.region_3
       ,p_postal_code                    => l_add_rec.postal_code
       ,p_telephone_number_1             => l_add_rec.telephone_number_1
       ,p_telephone_number_2             => l_add_rec.telephone_number_2
       ,p_telephone_number_3             => l_add_rec.telephone_number_3
       ,p_addr_attribute_category        => l_add_rec.addr_attribute_category
       ,p_addr_attribute1                => l_add_rec.addr_attribute1
       ,p_addr_attribute2                => l_add_rec.addr_attribute2
       ,p_addr_attribute3                => l_add_rec.addr_attribute3
       ,p_addr_attribute4                => l_add_rec.addr_attribute4
       ,p_addr_attribute5                => l_add_rec.addr_attribute5
       ,p_addr_attribute6                => l_add_rec.addr_attribute6
       ,p_addr_attribute7                => l_add_rec.addr_attribute7
       ,p_addr_attribute8                => l_add_rec.addr_attribute8
       ,p_addr_attribute9                => l_add_rec.addr_attribute9
       ,p_addr_attribute10               => l_add_rec.addr_attribute10
       ,p_addr_attribute11               => l_add_rec.addr_attribute11
       ,p_addr_attribute12               => l_add_rec.addr_attribute12
       ,p_addr_attribute13               => l_add_rec.addr_attribute13
       ,p_addr_attribute14               => l_add_rec.addr_attribute14
       ,p_addr_attribute15               => l_add_rec.addr_attribute15
       ,p_addr_attribute16               => l_add_rec.addr_attribute16
       ,p_addr_attribute17               => l_add_rec.addr_attribute17
       ,p_addr_attribute18               => l_add_rec.addr_attribute18
       ,p_addr_attribute19               => l_add_rec.addr_attribute19
       ,p_addr_attribute20               => l_add_rec.addr_attribute20
       ,p_add_information13              => l_add_rec.add_information13
       ,p_add_information14              => l_add_rec.add_information14
       ,p_add_information15              => l_add_rec.add_information15
       ,p_add_information16              => l_add_rec.add_information16
       ,p_add_information17              => l_add_rec.add_information17
       ,p_add_information18              => l_add_rec.add_information18
       ,p_add_information19              => l_add_rec.add_information19
       ,p_add_information20              => l_add_rec.add_information20
       ,p_party_id                       => l_add_rec.party_id
       ,p_address_user_key               => l_dp_crt_add_rec.p_address_user_key
       ,p_person_user_key                => l_dp_crt_add_rec.p_person_user_key
       ,p_country                        => l_add_rec.country
       );

    END IF;

    -- Call if API_ID is 'Update_Emp_Asg'
    IF l_api_name = 'UPDATE_EMP_ASG' THEN

       OPEN  csr_get_upd_asg_data(c_batch_id   => p_batch_id
                                 ,c_link_value => p_data_pump_batch_line_id
                                 );
       FETCH csr_get_upd_asg_data INTO l_dp_upd_asg_rec;
       CLOSE csr_get_upd_asg_data;

       Hrdpp_Update_Emp_Asg.Insert_Batch_Lines
       (p_batch_id                      => p_batch_id
       -- l_dp_batch_line_id_asg
       ,p_data_pump_batch_line_id       => l_dp_upd_asg_rec.batch_line_id
       ,p_user_sequence                 => l_dp_upd_asg_rec.user_sequence
       ,p_link_value                    => p_data_pump_batch_line_id
       ,p_effective_date                => l_per_rec.start_date
       ,p_datetrack_update_mode     => l_dp_upd_asg_rec.p_datetrack_update_mode
       ,p_change_reason                 => l_asg_rec.change_reason
       --,p_comments                      => l_asg_rec.asg_comments
       ,p_date_probation_end            => l_asg_rec.date_probation_end
       ,p_frequency                     => l_asg_rec.frequency
       ,p_internal_address_line         => l_asg_rec.internal_address_line
       ,p_manager_flag                  => l_asg_rec.manager_flag
       ,p_normal_hours                  => l_asg_rec.normal_hours
       ,p_perf_review_period            => l_asg_rec.perf_review_period
       ,p_perf_review_period_frequency  =>l_asg_rec.perf_review_period_frequency
       ,p_probation_period              => l_asg_rec.probation_period
       ,p_probation_unit                => l_asg_rec.probation_unit
       ,p_sal_review_period             => l_asg_rec.sal_review_period
       ,p_sal_review_period_frequency   => l_asg_rec.sal_review_period_frequency
       ,p_source_type                   => l_asg_rec.source_type
       ,p_time_normal_finish            => l_asg_rec.time_normal_finish
       ,p_time_normal_start             => l_asg_rec.time_normal_start
       ,p_bargaining_unit_code          => l_asg_rec.bargaining_unit_code
       ,p_labour_union_member_flag      => l_asg_rec.labour_union_member_flag
       ,p_hourly_salaried_code          => l_asg_rec.hourly_salaried_code
       ,p_ass_attribute_category        => l_asg_rec.ass_attribute_category
       ,p_ass_attribute1                => l_asg_rec.ass_attribute1
       ,p_ass_attribute2                => l_asg_rec.ass_attribute2
       ,p_ass_attribute3                => l_asg_rec.ass_attribute3
       ,p_ass_attribute4                => l_asg_rec.ass_attribute4
       ,p_ass_attribute5                => l_asg_rec.ass_attribute5
       ,p_ass_attribute6                => l_asg_rec.ass_attribute6
       ,p_ass_attribute7                => l_asg_rec.ass_attribute7
       ,p_ass_attribute8                => l_asg_rec.ass_attribute8
       ,p_ass_attribute9                => l_asg_rec.ass_attribute9
       ,p_ass_attribute10               => l_asg_rec.ass_attribute10
       ,p_ass_attribute11               => l_asg_rec.ass_attribute11
       ,p_ass_attribute12               => l_asg_rec.ass_attribute12
       ,p_ass_attribute13               => l_asg_rec.ass_attribute13
       ,p_ass_attribute14               => l_asg_rec.ass_attribute14
       ,p_ass_attribute15               => l_asg_rec.ass_attribute15
       ,p_ass_attribute16               => l_asg_rec.ass_attribute16
       ,p_ass_attribute17               => l_asg_rec.ass_attribute17
       ,p_ass_attribute18               => l_asg_rec.ass_attribute18
       ,p_ass_attribute19               => l_asg_rec.ass_attribute19
       ,p_ass_attribute20               => l_asg_rec.ass_attribute20
       ,p_ass_attribute21               => l_asg_rec.ass_attribute21
       ,p_ass_attribute22               => l_asg_rec.ass_attribute22
       ,p_ass_attribute23               => l_asg_rec.ass_attribute23
       ,p_ass_attribute24               => l_asg_rec.ass_attribute24
       ,p_ass_attribute25               => l_asg_rec.ass_attribute25
       ,p_ass_attribute26               => l_asg_rec.ass_attribute26
       ,p_ass_attribute27               => l_asg_rec.ass_attribute27
       ,p_ass_attribute28               => l_asg_rec.ass_attribute28
       ,p_ass_attribute29               => l_asg_rec.ass_attribute29
       ,p_ass_attribute30               => l_asg_rec.ass_attribute30
       --,p_title                         => l_asg_rec.title
       ,p_segment1                      => l_hr_soft_rec.segment1
       ,p_segment2                      => l_hr_soft_rec.segment2
       ,p_segment3                      => l_hr_soft_rec.segment3
       ,p_segment4                      => l_hr_soft_rec.segment4
       ,p_segment5                      => l_hr_soft_rec.segment5
       ,p_segment6                      => l_hr_soft_rec.segment6
       ,p_segment7                      => l_hr_soft_rec.segment7
       ,p_segment8                      => l_hr_soft_rec.segment8
       ,p_segment9                      => l_hr_soft_rec.segment9
       ,p_cagr_grade_def_id             => NULL
       ,p_assignment_user_key           =>l_dp_upd_asg_rec.p_assignment_user_key
       ,p_con_seg_user_name             => NULL
       );

    END IF;

    -- Call if API_ID is 'Update_Emp_Asg_Criteria'
    IF l_api_name = 'UPDATE_EMP_ASG_CRITERIA' THEN

       OPEN  csr_grade(l_asg_rec.grade_id
                      ,l_asg_rec.business_group_id
                      ,l_per_rec.START_DATE);
       FETCH csr_grade INTO l_grade_name;
       IF csr_grade%NOTFOUND THEN
          hr_utility.set_location('.. DP Error Grade Name not found Id: ' ||
	                           l_asg_rec.grade_id, 20);
       END IF;
       CLOSE csr_grade;

       OPEN  csr_position (l_asg_rec.position_id
                          ,l_asg_rec.business_group_id
                          ,l_per_rec.START_DATE);
       FETCH csr_position INTO l_position_name;
       IF csr_position%NOTFOUND THEN
          hr_utility.set_location('.. DP Error Position Name not found Id: ' ||
	                           l_asg_rec.position_id, 20);
       END IF;
       CLOSE csr_position;

       OPEN  csr_job(l_asg_rec.job_id
                    ,l_asg_rec.business_group_id
                    ,l_per_rec.START_DATE);
       FETCH csr_job INTO l_job_name;
       IF csr_job%NOTFOUND THEN
          hr_utility.set_location('.. DP Error Job Name not found Id: ' ||
                                  l_asg_rec.job_id, 20);
       END IF;
       CLOSE csr_job;

       OPEN  csr_payroll(l_asg_rec.payroll_id
                        ,l_asg_rec.business_group_id
                        ,l_per_rec.START_DATE);
       FETCH csr_payroll INTO l_payroll_name;
       IF csr_payroll%NOTFOUND THEN
          hr_utility.set_location('.. DP Error Payroll Name not found Id: ' ||
                                  l_asg_rec.payroll_id, 20);
       END IF;
       CLOSE csr_payroll;

       OPEN  csr_location(l_asg_rec.location_id
                         ,l_asg_rec.business_group_id);
       FETCH csr_location INTO l_location_code;
       IF csr_location%NOTFOUND THEN
          hr_utility.set_location('.. DP Error Location Code not found, Id: ' ||
                                  l_asg_rec.location_id, 20);
       END IF;
       CLOSE csr_location;

       OPEN  csr_organization(l_asg_rec.organization_id
                             ,l_asg_rec.business_group_id
                             ,l_per_rec.START_DATE);
       FETCH csr_organization INTO l_organization_name;
       IF csr_organization%NOTFOUND THEN
          hr_utility.set_location('.. DP Error Org Name not found, Id: ' ||
                                  l_asg_rec.organization_id, 20);
       END IF;
       CLOSE csr_organization;

       OPEN  csr_paybasis(l_asg_rec.pay_basis_id
                         ,l_asg_rec.business_group_id);
       FETCH csr_paybasis INTO l_pay_basis_name;
       IF csr_paybasis%NOTFOUND THEN
          hr_utility.set_location('.. DP Error Org Name not found, Id: ' ||
                                  l_asg_rec.pay_basis_id, 20);
       END IF;
       CLOSE csr_paybasis;

      -- Cursor to get the exisiting Data Pump Interface Table Va;ues for
      -- Update Emp Asg Criteria
      OPEN  csr_get_upd_asg_crt_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
      FETCH csr_get_upd_asg_crt_data INTO l_dp_upd_asg_crt_rec;
      CLOSE csr_get_upd_asg_crt_data;

      Hrdpp_Update_Emp_Asg_Criteria.Insert_Batch_Lines
      (p_batch_id                => p_batch_id
      --l_dp_batch_line_id_asg_cri
      ,p_data_pump_batch_line_id => l_dp_upd_asg_crt_rec.batch_line_id
      ,p_user_sequence           => l_dp_upd_asg_crt_rec.user_sequence
      ,p_link_value              => p_data_pump_batch_line_id
      ,p_effective_date          => l_per_rec.start_date
      ,p_datetrack_update_mode   => l_dp_upd_asg_crt_rec.p_datetrack_update_mode
      ,p_segment1                => l_ppl_grp_rec.segment1
      ,p_segment2                => l_ppl_grp_rec.segment2
      ,p_segment3                => l_ppl_grp_rec.segment3
      ,p_segment4                => l_ppl_grp_rec.segment4
      ,p_segment5                => l_ppl_grp_rec.segment5
      ,p_segment6                => l_ppl_grp_rec.segment6
      ,p_segment7                => l_ppl_grp_rec.segment7
      ,p_segment8                => l_ppl_grp_rec.segment8
      ,p_segment9                => l_ppl_grp_rec.segment9
      ,p_segment10               => l_ppl_grp_rec.segment10
      ,p_segment11               => l_ppl_grp_rec.segment11
      ,p_segment12               => l_ppl_grp_rec.segment12
      ,p_segment13               => l_ppl_grp_rec.segment13
      ,p_segment14               => l_ppl_grp_rec.segment14
      ,p_segment15               => l_ppl_grp_rec.segment15
      ,p_segment16               => l_ppl_grp_rec.segment16
      ,p_segment17               => l_ppl_grp_rec.segment17
      ,p_segment18               => l_ppl_grp_rec.segment18
      ,p_segment19               => l_ppl_grp_rec.segment19
      ,p_segment20               => l_ppl_grp_rec.segment20
      ,p_segment21               => l_ppl_grp_rec.segment21
      ,p_segment22               => l_ppl_grp_rec.segment22
      ,p_segment23               => l_ppl_grp_rec.segment23
      ,p_segment24               => l_ppl_grp_rec.segment24
      ,p_segment25               => l_ppl_grp_rec.segment25
      ,p_segment26               => l_ppl_grp_rec.segment26
      ,p_segment27               => l_ppl_grp_rec.segment27
      ,p_segment28               => l_ppl_grp_rec.segment28
      ,p_segment29               => l_ppl_grp_rec.segment29
      ,p_segment30               => l_ppl_grp_rec.segment30
      ,p_special_ceiling_step_id => NULL
      ,p_people_group_id         => NULL
      ,p_assignment_user_key     => l_dp_upd_asg_crt_rec.p_assignment_user_key
      ,p_grade_name              => l_grade_name
      ,p_position_name           => l_position_name
      ,p_job_name                => l_job_name
      ,p_payroll_name            => l_payroll_name
      ,p_location_code           => l_location_code
      ,p_organization_name       => l_organization_name
      ,p_pay_basis_name          => l_pay_basis_name
      ,p_language_code           => Userenv('LANG')
      ,p_con_seg_user_name       => NULL
      );

    END IF;

    -- Call if API_ID is 'Create_Contact'
    IF l_api_name = 'CREATE_CONTACT' THEN

       OPEN  csr_get_create_cnt_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
       FETCH csr_get_create_cnt_data INTO l_dp_crt_cnt_rec;
       CLOSE csr_get_create_cnt_data;

       Hrdpp_Create_Contact.insert_batch_lines
       (p_batch_id                => p_batch_id
       ,p_data_pump_batch_line_id => l_dp_crt_cnt_rec.batch_line_id
       ,p_user_sequence           => l_dp_crt_cnt_rec.user_sequence
       ,p_link_value              => p_data_pump_batch_line_id
       ,p_start_date              => l_per_rec.start_date
       ,p_contact_type            => l_cntct_rec.contact_type
       ,p_primary_contact_flag    => l_cntct_rec.primary_contact_flag
       ,p_personal_flag           => l_cntct_rec.personal_flag
       ,p_last_name               => p_contact_name
       ,p_per_person_user_key     => l_dp_crt_cnt_rec.p_per_person_user_key
       ,p_person_user_key         => l_dp_crt_cnt_rec.p_person_user_key
       ,p_language_code           => Userenv('LANG')
       );

    END IF;

    -- Call if API_ID is 'Update_Contact'
    IF l_api_name = 'UPDATE_CONTACT_RELATIONSHIP' THEN

       OPEN  csr_get_update_cnt_data(c_batch_id   => p_batch_id
                                     ,c_link_value => p_data_pump_batch_line_id
                                     );
       FETCH csr_get_update_cnt_data INTO l_dp_upd_cnt_rec;
       CLOSE csr_get_update_cnt_data;

       Hrdpp_Update_Contact_Relations.insert_batch_lines
       (p_batch_id                => p_batch_id
       ,p_data_pump_batch_line_id => l_dp_upd_cnt_rec.batch_line_id
       ,p_user_sequence           => l_dp_crt_cnt_rec.user_sequence
       ,p_link_value              => p_data_pump_batch_line_id
       ,p_effective_date          => l_per_rec.start_date
       ,p_contact_type            => l_cntct_rec.contact_type
       ,p_primary_contact_flag    => l_cntct_rec.primary_contact_flag
       ,p_personal_flag           => l_cntct_rec.personal_flag
       ,p_object_version_number   => l_dp_upd_cnt_rec.p_object_version_number
       ,p_contact_user_key        => l_dp_upd_cnt_rec.p_contact_user_key
       ,p_contactee_user_key      => l_dp_upd_cnt_rec.p_contactee_user_key
       );

    END IF;

  END LOOP;

  CLOSE csr_get_api_names;

  hr_utility.set_location('Leaving: ' || l_proc_name, 30);

EXCEPTION
  WHEN Others THEN
    IF csr_get_api_names%ISOPEN THEN
      CLOSE csr_get_api_names;
    END IF;
  hr_utility.set_location('Leaving: ' || l_proc_name, 40);
  RAISE;

END HR_DataPumpErr;


-- =============================================================================
-- ~ Create_Person_Contact:
-- =============================================================================


PROCEDURE Create_Person_Contact
         (p_effective_date   IN Date
         ,p_contact_name     IN Varchar2
      ,p_legislation_code IN Varchar2
         ,p_crt_cntct_out    OUT NOCOPY t_CreateContact_Api
) AS

  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Create_Person_Contact';

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

   Hr_Contact_Rel_Api.create_contact
   (p_start_date                => p_effective_date
   ,p_business_group_id         => l_cntct_rec.business_group_id
   ,p_person_id                 => l_cntct_rec.person_id
   ,p_contact_type              => l_cntct_rec.contact_type
   ,p_last_name                 => p_contact_name
   ,p_primary_contact_flag      => l_cntct_rec.primary_contact_flag
   ,p_personal_flag             => l_cntct_rec.personal_flag
   ,p_per_information_category  => p_legislation_code
   ,p_contact_relationship_id   => p_crt_cntct_out.contact_relationship_id
   ,p_ctr_object_version_number => p_crt_cntct_out.ctr_object_version_number
   ,p_per_person_id             => p_crt_cntct_out.per_person_id
   ,p_per_object_version_number => p_crt_cntct_out.per_object_version_number
   ,p_per_effective_start_date  => p_crt_cntct_out.per_effective_start_date
   ,p_per_effective_end_date    => p_crt_cntct_out.per_effective_end_date
   ,p_full_name                 => p_crt_cntct_out.full_name
   ,p_per_comment_id            => p_crt_cntct_out.per_comment_id
   ,p_name_combination_warning  => p_crt_cntct_out.name_combination_warning
   ,p_orig_hire_warning         => p_crt_cntct_out.orig_hire_warning
   );

  hr_utility.set_location('Leaving: ' || l_proc_name, 20);

END Create_Person_Contact;

-- =============================================================================
-- ~ Update_Person_Contact:
-- =============================================================================
PROCEDURE Update_Person_Contact
         (p_effective_date   IN Date
         ,p_contact_name     IN Varchar2
      ,p_legislation_code IN Varchar2
         ,p_crt_cntct_out    OUT NOCOPY t_CreateContact_Api
) AS

  l_cont_object_version_num   Number;
  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Update_Person_Contact';

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  OPEN  csr_ck_cont_xsts(c_person_id         => l_per_rec.person_id
                        ,c_business_group_id => l_add_rec.business_group_id
                        ,c_effective_date    => l_per_rec.START_DATE);
  FETCH csr_ck_cont_xsts INTO l_cont_object_version_num;

  -- Update the Contact only if Contact exists else create Contact
  IF csr_ck_cont_xsts%FOUND THEN

     -- Right now we are only creating the contact as decision to if we should
     -- actually be updating the Contact or every time be creating a new
     -- contact, irrespective of the fact if it is already existing duplicate
     -- person, hasn't been made
     Hr_Contact_Rel_Api.create_contact
     (p_start_date                => p_effective_date
     ,p_business_group_id         => l_cntct_rec.business_group_id
     ,p_person_id                 => l_cntct_rec.person_id
     ,p_contact_type              => l_cntct_rec.contact_type
     ,p_last_name                 => p_contact_name
     ,p_primary_contact_flag      => l_cntct_rec.primary_contact_flag
     ,p_personal_flag             => l_cntct_rec.personal_flag
     ,p_per_information_category  => p_legislation_code
     ,p_contact_relationship_id   => p_crt_cntct_out.contact_relationship_id
     ,p_ctr_object_version_number => p_crt_cntct_out.ctr_object_version_number
     ,p_per_person_id             => p_crt_cntct_out.per_person_id
     ,p_per_object_version_number => p_crt_cntct_out.per_object_version_number
     ,p_per_effective_start_date  => p_crt_cntct_out.per_effective_start_date
     ,p_per_effective_end_date    => p_crt_cntct_out.per_effective_end_date
     ,p_full_name                 => p_crt_cntct_out.full_name
     ,p_per_comment_id            => p_crt_cntct_out.per_comment_id
     ,p_name_combination_warning  => p_crt_cntct_out.name_combination_warning
     ,p_orig_hire_warning         => p_crt_cntct_out.orig_hire_warning
     );

  ELSE

     Hr_Contact_Rel_Api.create_contact
     (p_start_date                => p_effective_date
     ,p_business_group_id         => l_cntct_rec.business_group_id
     ,p_person_id                 => l_cntct_rec.person_id
     ,p_contact_type              => l_cntct_rec.contact_type
     ,p_last_name                 => p_contact_name
     ,p_primary_contact_flag      => l_cntct_rec.primary_contact_flag
     ,p_personal_flag             => l_cntct_rec.personal_flag
     ,p_per_information_category  => p_legislation_code
     ,p_contact_relationship_id   => p_crt_cntct_out.contact_relationship_id
     ,p_ctr_object_version_number => p_crt_cntct_out.ctr_object_version_number
     ,p_per_person_id             => p_crt_cntct_out.per_person_id
     ,p_per_object_version_number => p_crt_cntct_out.per_object_version_number
     ,p_per_effective_start_date  => p_crt_cntct_out.per_effective_start_date
     ,p_per_effective_end_date    => p_crt_cntct_out.per_effective_end_date
     ,p_full_name                 => p_crt_cntct_out.full_name
     ,p_per_comment_id            => p_crt_cntct_out.per_comment_id
     ,p_name_combination_warning  => p_crt_cntct_out.name_combination_warning
     ,p_orig_hire_warning         => p_crt_cntct_out.orig_hire_warning
     );

  END IF;

  hr_utility.set_location('Leaving: ' || l_proc_name, 20);

END Update_Person_Contact;


-- =============================================================================
-- ~ Upd_OSS_Person:
-- =============================================================================
PROCEDURE Upd_OSS_Person
         (p_validate            IN Boolean
         ,p_effective_date      IN Date
         ,p_person_id           Number
         ,p_adjusted_svc_date   Date       DEFAULT NULL
         ,p_updper_api_out      OUT NOCOPY t_UpdEmp_Api
          ) AS

  l_cur_per_rec            csr_per%ROWTYPE;
  l_ptu_rec                chk_perType_usage%ROWTYPE;
  l_datetrack_update_mode  Varchar2(50);
  l_dt_correction          Boolean;
  l_dt_update              Boolean;
  l_dt_upd_override        Boolean;
  l_upd_chg_ins            Boolean;
  e_future_chgs_exists     Exception;
  l_error_msg              Varchar2(3000);
  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Upd_OSS_Person';

BEGIN
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  OPEN  csr_per(c_person_id         => l_per_rec.person_id
               ,c_business_group_id => l_per_rec.business_group_id
               ,c_effective_date    => p_effective_date);
  FETCH csr_per INTO l_cur_per_rec;
  CLOSE csr_per;

  hr_utility.set_location(' l_cur_per_rec: ' || l_cur_per_rec.person_id, 20);

  Dt_Api.Find_DT_Upd_Modes
  (p_effective_date        => p_effective_date
  ,p_base_table_name       => 'PER_ALL_PEOPLE_F'
  ,p_base_key_column       => 'PERSON_ID'
  ,p_base_key_value        => l_cur_per_rec.person_id
  ,p_correction            => l_dt_correction
  ,p_update                => l_dt_update
  ,p_update_override       => l_dt_upd_override
  ,p_update_change_insert  => l_upd_chg_ins
   );

  IF l_dt_update THEN
     l_datetrack_update_mode := 'UPDATE';
  ELSIF l_dt_upd_override OR
        l_upd_chg_ins THEN
        -- Need to check if person type in future is EMP, APL or CWK , if yes
        -- then raise error
        OPEN chk_perType_usage
           (c_person_id         => l_cur_per_rec.person_id
           ,c_effective_date    => p_effective_date
           ,c_business_group_id => l_per_rec.business_group_id);
        FETCH chk_perType_usage INTO l_ptu_rec;
        IF chk_perType_usage%FOUND THEN
           Close chk_perType_usage;
           RAISE e_future_chgs_exists;
        END IF;
        Close chk_perType_usage;
  ELSE
     l_datetrack_update_mode := 'CORRECTION';
  END IF;

  hr_utility.set_location(' l_datetrack_update_mode: ' ||
                            l_datetrack_update_mode, 30);
  hr_utility.set_location(' employee_number: ' ||
                            l_cur_per_rec.employee_number, 30);
  hr_utility.set_location(' per ovn: ' ||
                            l_cur_per_rec.object_version_number, 30);

  -- Need to pass the employee number when updating the person
  l_per_rec.object_version_number := l_cur_per_rec.object_version_number;

  Hr_Person_Api.Update_Person
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_person_id                    => l_cur_per_rec.person_id
  ,p_party_id                     => l_per_rec.party_id
  ,p_object_version_number        => l_cur_per_rec.object_version_number
  ,p_employee_number              => l_cur_per_rec.employee_number
  ,p_last_name                    => NVL(l_per_rec.last_name
                                        ,l_cur_per_rec.last_name)
  ,p_first_name                   => NVL(l_per_rec.first_name
                                        ,l_cur_per_rec.first_name)
  ,p_date_of_birth                => NVL(l_per_rec.date_of_birth
                                        ,l_cur_per_rec.date_of_birth)
  ,p_marital_status               => NVL(l_per_rec.marital_status
                                        ,l_cur_per_rec.marital_status)
  ,p_middle_names                 => NVL(l_per_rec.middle_names
                                        ,l_cur_per_rec.middle_names)
  ,p_sex                          => NVL(l_per_rec.sex
                                        ,l_cur_per_rec.sex)
  ,p_title                        => NVL(l_per_rec.title
                                        ,l_cur_per_rec.title)
  ,p_nationality                  => NVL(l_per_rec.nationality
                                        ,l_cur_per_rec.nationality)
  ,p_previous_last_name           => NVL(l_per_rec.previous_last_name
                                        ,l_cur_per_rec.previous_last_name)
  ,p_known_as                     => NVL(l_per_rec.known_as
                                        ,l_cur_per_rec.known_as)
  ,p_email_address                => NVL(l_per_rec.email_address
                                        ,l_cur_per_rec.email_address)
  ,p_registered_disabled_flag     => NVL(l_per_rec.registered_disabled_flag
                                        ,l_cur_per_rec.registered_disabled_flag)
  ,p_date_employee_data_verified  => NVL(l_per_rec.date_employee_data_verified
                                     ,l_cur_per_rec.date_employee_data_verified)
  ,p_expense_check_send_to_addres => NVL(l_per_rec.expense_check_send_to_address
                                   ,l_cur_per_rec.expense_check_send_to_address)
  ,p_per_information_category     => l_per_rec.per_information_category
  ,p_per_information1             => l_per_rec.per_information1
  ,p_per_information2             => l_per_rec.per_information2
  ,p_per_information3             => l_per_rec.per_information3
  ,p_per_information4             => l_per_rec.per_information4
  ,p_per_information5             => l_per_rec.per_information5
  ,p_per_information6             => l_per_rec.per_information6
  ,p_per_information7             => l_per_rec.per_information7
  ,p_per_information8             => l_per_rec.per_information8
  ,p_per_information9             => l_per_rec.per_information9
  ,p_per_information10            => l_per_rec.per_information10
  ,p_per_information11            => l_per_rec.per_information11
  ,p_per_information12            => l_per_rec.per_information12
  ,p_per_information13            => l_per_rec.per_information13
  ,p_per_information14            => l_per_rec.per_information14
  ,p_per_information15            => l_per_rec.per_information15
  ,p_per_information16            => l_per_rec.per_information16
  ,p_per_information17            => l_per_rec.per_information17
  ,p_per_information18            => l_per_rec.per_information18
  ,p_per_information19            => l_per_rec.per_information19
  ,p_per_information20            => l_per_rec.per_information20
  ,p_per_information21            => l_per_rec.per_information21
  ,p_per_information22            => l_per_rec.per_information22
  ,p_per_information23            => l_per_rec.per_information23
  ,p_per_information24            => l_per_rec.per_information24
  ,p_per_information25            => l_per_rec.per_information25
  ,p_per_information26            => l_per_rec.per_information26
  ,p_per_information27            => l_per_rec.per_information27
  ,p_per_information28            => l_per_rec.per_information28
  ,p_per_information29            => l_per_rec.per_information29
  ,p_per_information30            => l_per_rec.per_information30
  -- Person DF
  ,p_attribute_category           => l_per_rec.attribute_category
  ,p_attribute1                   => l_per_rec.attribute1
  ,p_attribute2                   => l_per_rec.attribute2
  ,p_attribute3                   => l_per_rec.attribute3
  ,p_attribute4                   => l_per_rec.attribute4
  ,p_attribute5                   => l_per_rec.attribute5
  ,p_attribute6                   => l_per_rec.attribute6
  ,p_attribute7                   => l_per_rec.attribute7
  ,p_attribute8                   => l_per_rec.attribute8
  ,p_attribute9                   => l_per_rec.attribute9
  ,p_attribute10                  => l_per_rec.attribute10
  ,p_attribute11                  => l_per_rec.attribute11
  ,p_attribute12                  => l_per_rec.attribute12
  ,p_attribute13                  => l_per_rec.attribute13
  ,p_attribute14                  => l_per_rec.attribute14
  ,p_attribute15                  => l_per_rec.attribute15
  ,p_attribute16                  => l_per_rec.attribute16
  ,p_attribute17                  => l_per_rec.attribute17
  ,p_attribute18                  => l_per_rec.attribute18
  ,p_attribute19                  => l_per_rec.attribute19
  ,p_attribute20                  => l_per_rec.attribute20
  ,p_attribute21                  => l_per_rec.attribute21
  ,p_attribute22                  => l_per_rec.attribute22
  ,p_attribute23                  => l_per_rec.attribute23
  ,p_attribute24                  => l_per_rec.attribute24
  ,p_attribute25                  => l_per_rec.attribute25
  ,p_attribute26                  => l_per_rec.attribute26
  ,p_attribute27                  => l_per_rec.attribute27
  ,p_attribute28                  => l_per_rec.attribute28
  ,p_attribute29                  => l_per_rec.attribute29
  ,p_attribute30                  => l_per_rec.attribute30
  ,p_date_of_death                => NVL(l_per_rec.date_of_death
                                        ,l_cur_per_rec.date_of_death)
  ,p_background_check_status      => NVL(l_per_rec.background_check_status
                                        ,l_cur_per_rec.background_check_status)
  ,p_background_date_check        => NVL(l_per_rec.background_date_check
                                        ,l_cur_per_rec.background_date_check)
  ,p_blood_type                   => NVL(l_per_rec.blood_type
                                        ,l_cur_per_rec.blood_type)
  ,p_correspondence_language      => NVL(l_per_rec.correspondence_language
                                        ,l_cur_per_rec.correspondence_language)
  ,p_fte_capacity                 => NVL(l_per_rec.fte_capacity
                                        ,l_cur_per_rec.fte_capacity)
  ,p_hold_applicant_date_until    => NVL(l_per_rec.hold_applicant_date_until
                                       ,l_cur_per_rec.hold_applicant_date_until)
  ,p_honors                       => NVL(l_per_rec.honors
                                        ,l_cur_per_rec.honors)
  ,p_internal_location            => NVL(l_per_rec.internal_location
                                        ,l_cur_per_rec.internal_location)
  ,p_last_medical_test_by         => NVL(l_per_rec.last_medical_test_by
                                        ,l_cur_per_rec.last_medical_test_by)
  ,p_last_medical_test_date       => NVL(l_per_rec.last_medical_test_date
                                        ,l_cur_per_rec.last_medical_test_date)
  ,p_mailstop                     => NVL(l_per_rec.mailstop
                                        ,l_cur_per_rec.mailstop)
  ,p_office_number                => NVL(l_per_rec.office_number
                                        ,l_cur_per_rec.office_number)
  ,p_on_military_service          => NVL(l_per_rec.on_military_service
                                        ,l_cur_per_rec.on_military_service)
  ,p_pre_name_adjunct             => NVL(l_per_rec.pre_name_adjunct
                                        ,l_cur_per_rec.pre_name_adjunct)
  ,p_projected_start_date         => NVL(l_per_rec.projected_start_date
                                        ,l_cur_per_rec.projected_start_date)
  ,p_rehire_authorizor            => NVL(l_per_rec.rehire_authorizor
                                        ,l_cur_per_rec.rehire_authorizor)
  ,p_rehire_recommendation        => NVL(l_per_rec.rehire_recommendation
                                        ,l_cur_per_rec.rehire_recommendation)
  ,p_resume_exists                => NVL(l_per_rec.resume_exists
                                        ,l_cur_per_rec.resume_exists )
  ,p_resume_last_updated          => NVL(l_per_rec.resume_last_updated
                                        ,l_cur_per_rec.resume_last_updated)
  ,p_second_passport_exists       => NVL(l_per_rec.second_passport_exists
                                        ,l_cur_per_rec.second_passport_exists)
  ,p_student_status               => NVL(l_per_rec.student_status
                                        ,l_cur_per_rec.student_status)
  ,p_work_schedule                => NVL(l_per_rec.work_schedule
                                        ,l_cur_per_rec.work_schedule)
  ,p_rehire_reason                => NVL(l_per_rec.rehire_reason
                                        ,l_cur_per_rec.rehire_reason)
  ,p_suffix                       => NVL(l_per_rec.suffix
                                        ,l_cur_per_rec.suffix)
  ,p_benefit_group_id             => NVL(l_per_rec.benefit_group_id
                                        ,l_cur_per_rec.benefit_group_id)
  ,p_receipt_of_death_cert_date   => NVL(l_per_rec.receipt_of_death_cert_date
                                      ,l_cur_per_rec.receipt_of_death_cert_date)
  ,p_coord_ben_med_pln_no         => NVL(l_per_rec.coord_ben_med_pln_no
                                        ,l_cur_per_rec.coord_ben_med_pln_no)
  ,p_coord_ben_no_cvg_flag        => NVL(l_per_rec.coord_ben_no_cvg_flag
                                        ,l_cur_per_rec.coord_ben_no_cvg_flag)
  ,p_coord_ben_med_ext_er         => NVL(l_per_rec.coord_ben_med_ext_er
                                        ,l_cur_per_rec.coord_ben_med_ext_er)
  ,p_coord_ben_med_pl_name        => NVL(l_per_rec.coord_ben_med_pl_name
                                        ,l_cur_per_rec.coord_ben_med_pl_name)
  ,p_coord_ben_med_insr_crr_name  => NVL(l_per_rec.coord_ben_med_insr_crr_name
                                     ,l_cur_per_rec.coord_ben_med_insr_crr_name)
  ,p_coord_ben_med_insr_crr_ident => NVL(l_per_rec.coord_ben_med_insr_crr_ident
                                    ,l_cur_per_rec.coord_ben_med_insr_crr_ident)
  ,p_coord_ben_med_cvg_strt_dt    => NVL(l_per_rec.coord_ben_med_cvg_strt_dt
                                     ,l_cur_per_rec.coord_ben_med_cvg_strt_dt)
  ,p_coord_ben_med_cvg_end_dt     => NVL(l_per_rec.coord_ben_med_cvg_end_dt
                                        ,l_cur_per_rec.coord_ben_med_cvg_end_dt)
  ,p_uses_tobacco_flag            => NVL(l_per_rec.uses_tobacco_flag
                                        ,l_cur_per_rec.uses_tobacco_flag)
  ,p_dpdnt_adoption_date          => NVL(l_per_rec.dpdnt_adoption_date
                                        ,l_cur_per_rec.dpdnt_adoption_date)
  ,p_dpdnt_vlntry_svce_flag       => NVL(l_per_rec.dpdnt_vlntry_svce_flag
                                        ,l_cur_per_rec.dpdnt_vlntry_svce_flag)
  ,p_original_date_of_hire        => NVL(l_per_rec.original_date_of_hire
                                        ,l_cur_per_rec.original_date_of_hire)
  --,p_adjusted_svc_date            => p_adjusted_svc_date
  ,p_town_of_birth                => NVL(l_per_rec.town_of_birth
                                        ,l_cur_per_rec.town_of_birth)
  ,p_region_of_birth              => NVL(l_per_rec.region_of_birth
                                        ,l_cur_per_rec.region_of_birth)
  ,p_country_of_birth             => NVL(l_per_rec.country_of_birth
                                        ,l_cur_per_rec.country_of_birth)
  ,p_global_person_id             => NVL(l_per_rec.global_person_id
                                        ,l_cur_per_rec.global_person_id)
   -- Out Variables
  ,p_effective_start_date         => p_updper_api_out.effective_start_date
  ,p_effective_end_date           => p_updper_api_out.effective_end_date
  ,p_full_name                    => p_updper_api_out.full_name
  ,p_comment_id                   => p_updper_api_out.comment_id
  ,p_name_combination_warning     => p_updper_api_out.name_combination_warning
  ,p_assign_payroll_warning       => p_updper_api_out.assign_payroll_warning
  ,p_orig_hire_warning            => p_updper_api_out.orig_hire_warning
  );

  IF g_debug_on THEN
    hr_utility.set_location('..effective_start_date : ' ||
                             p_updper_api_out.effective_start_date,40);
    hr_utility.set_location('..effective_end_date   : ' ||
                             p_updper_api_out.effective_end_date,40);
    hr_utility.set_location('..full_name            : ' ||
                             p_updper_api_out.full_name,40);
    hr_utility.set_location('Leaving: ' || l_proc_name, 40);
  END IF;

EXCEPTION
  WHEN e_future_chgs_exists THEN
    l_error_msg := 'This person cannot be created in HRMS as a Student '||
                   'Employee due to future changes beyond the date: '||p_effective_date;

    hr_utility.set_location('..Future Update exists for the Student Employee', 60);
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    hr_utility.set_location('Leaving: ' || l_proc_name, 60);
    hr_utility.raise_error;

  WHEN Others THEN
  hr_utility.set_location('SQLERRM :' || SQLCODE,90);
  hr_utility.set_location('Leaving: ' || l_proc_name, 90);
  RAISE;

END Upd_OSS_Person;

-- =============================================================================
-- ~ create_student_employee:
-- =============================================================================
PROCEDURE create_student_employee
         (p_last_name                    IN Varchar2
         ,p_middle_name                  IN Varchar2
         ,p_first_name                   IN Varchar2
         ,p_suffix                       IN Varchar2
         ,p_prefix                       IN Varchar2
         ,p_title                        IN Varchar2
         ,p_email_address                IN Varchar2
         ,p_preferred_name               IN Varchar2
         ,p_dup_person_id                IN Number
         ,p_dup_party_id                 IN Number
         ,p_marital_status               IN Varchar2
         ,p_sex                          IN Varchar2
         ,p_nationality                  IN Varchar2
         ,p_national_identifier          IN Varchar2
         ,p_date_of_birth                IN Date
         ,p_date_of_hire                 IN Date
         ,p_employee_number              IN Varchar2
         ,p_primary_flag                 IN Varchar2
         ,p_address_style                IN Varchar2
         ,p_address_line1                IN Varchar2
         ,p_address_line2                IN Varchar2
         ,p_address_line3                IN Varchar2
         ,p_region1                      IN Varchar2
         ,p_region2                      IN Varchar2
         ,p_region3                      IN Varchar2
         ,p_town_or_city                 IN Varchar2
         ,p_country                      IN Varchar2
         ,p_postal_code                  IN Varchar2
         ,p_telephone_no1                IN Varchar2
         ,p_telephone_no2                IN Varchar2
         ,p_telephone_no3                IN Varchar2
         ,p_address_date_from            IN Date
         ,p_address_date_to              IN Date
         ,p_phone_type                   IN Varchar2
         ,p_phone_number                 IN Varchar2
         ,p_phone_date_from              IN Date
         ,p_phone_date_to                IN Date
         ,p_contact_type                 IN Varchar2
         ,p_contact_name                 IN Varchar2
         ,p_primary_contact              IN Varchar2
         ,p_personal_flag                IN Varchar2
         ,p_contact_date_from            IN Date
         ,p_contact_date_to              IN Date
         ,p_assign_organization          IN Varchar2
         ,p_job                          IN Number
         ,p_grade                        IN Number
         ,p_internal_location            IN Varchar2
         ,p_assign_group                 IN Varchar2
         ,p_position                     IN Number
         ,p_payroll                      IN Number
         ,p_status                       IN Varchar2
         ,p_assignment_no                IN Varchar2
         ,p_assignment_category          IN Varchar2
         ,p_collective_agreement         IN Varchar2
         ,p_employee_category            IN Varchar2
         ,p_user_person_type             IN Number
         ,p_salary_basis                 IN Number
         ,p_gre                          IN Varchar2
         ,p_web_adi_identifier           IN Varchar2
         ,p_assign_eff_dt_from           IN Date
         ,p_assign_eff_dt_to             IN Date
         ,p_per_attribute_category       IN Varchar2
         ,p_per_attribute1               IN Varchar2
         ,p_per_attribute2               IN Varchar2
         ,p_per_attribute3               IN Varchar2
         ,p_per_attribute4               IN Varchar2
         ,p_per_attribute5               IN Varchar2
         ,p_per_attribute6               IN Varchar2
         ,p_per_attribute7               IN Varchar2
         ,p_per_attribute8               IN Varchar2
         ,p_per_attribute9               IN Varchar2
         ,p_per_attribute10              IN Varchar2
         ,p_per_attribute11              IN Varchar2
         ,p_per_attribute12              IN Varchar2
         ,p_per_attribute13              IN Varchar2
         ,p_per_attribute14              IN Varchar2
         ,p_per_attribute15              IN Varchar2
         ,p_per_attribute16              IN Varchar2
         ,p_per_attribute17              IN Varchar2
         ,p_per_attribute18              IN Varchar2
         ,p_per_attribute19              IN Varchar2
         ,p_per_attribute20              IN Varchar2
         ,p_per_attribute21              IN Varchar2
         ,p_per_attribute22              IN Varchar2
         ,p_per_attribute23              IN Varchar2
         ,p_per_attribute24              IN Varchar2
         ,p_per_attribute25              IN Varchar2
         ,p_per_attribute26              IN Varchar2
         ,p_per_attribute27              IN Varchar2
         ,p_per_attribute28              IN Varchar2
         ,p_per_attribute29              IN Varchar2
         ,p_per_attribute30              IN Varchar2
         ,p_per_information_category     IN Varchar2
         ,p_per_information1             IN Varchar2
         ,p_per_information2             IN Varchar2
         ,p_per_information3             IN Varchar2
         ,p_per_information4             IN Varchar2
         ,p_per_information5             IN Varchar2
         ,p_per_information6             IN Varchar2
         ,p_per_information7             IN Varchar2
         ,p_per_information8             IN Varchar2
         ,p_per_information9             IN Varchar2
         ,p_per_information10            IN Varchar2
         ,p_per_information11            IN Varchar2
         ,p_per_information12            IN Varchar2
         ,p_per_information13            IN Varchar2
         ,p_per_information14            IN Varchar2
         ,p_per_information15            IN Varchar2
         ,p_per_information16            IN Varchar2
         ,p_per_information17            IN Varchar2
         ,p_per_information18            IN Varchar2
         ,p_per_information19            IN Varchar2
         ,p_per_information20            IN Varchar2
         ,p_per_information21            IN Varchar2
         ,p_per_information22            IN Varchar2
         ,p_per_information23            IN Varchar2
         ,p_per_information24            IN Varchar2
         ,p_per_information25            IN Varchar2
         ,p_per_information26            IN Varchar2
         ,p_per_information27            IN Varchar2
         ,p_per_information28            IN Varchar2
         ,p_per_information29            IN Varchar2
         ,p_per_information30            IN Varchar2
         ,p_ass_attribute_category       IN Varchar2
         ,p_ass_attribute1               IN Varchar2
         ,p_ass_attribute2               IN Varchar2
         ,p_ass_attribute3               IN Varchar2
         ,p_ass_attribute4               IN Varchar2
         ,p_ass_attribute5               IN Varchar2
         ,p_ass_attribute6               IN Varchar2
         ,p_ass_attribute7               IN Varchar2
         ,p_ass_attribute8               IN Varchar2
         ,p_ass_attribute9               IN Varchar2
         ,p_ass_attribute10              IN Varchar2
         ,p_ass_attribute11              IN Varchar2
         ,p_ass_attribute12              IN Varchar2
         ,p_ass_attribute13              IN Varchar2
         ,p_ass_attribute14              IN Varchar2
         ,p_ass_attribute15              IN Varchar2
         ,p_ass_attribute16              IN Varchar2
         ,p_ass_attribute17              IN Varchar2
         ,p_ass_attribute18              IN Varchar2
         ,p_ass_attribute19              IN Varchar2
         ,p_ass_attribute20              IN Varchar2
         ,p_ass_attribute21              IN Varchar2
         ,p_ass_attribute22              IN Varchar2
         ,p_ass_attribute23              IN Varchar2
         ,p_ass_attribute24              IN Varchar2
         ,p_ass_attribute25              IN Varchar2
         ,p_ass_attribute26              IN Varchar2
         ,p_ass_attribute27              IN Varchar2
         ,p_ass_attribute28              IN Varchar2
         ,p_ass_attribute29              IN Varchar2
         ,p_ass_attribute30              IN Varchar2
         ,p_adr_attribute_category       IN Varchar2
         ,p_adr_attribute1               IN Varchar2
         ,p_adr_attribute2               IN Varchar2
         ,p_adr_attribute3               IN Varchar2
         ,p_adr_attribute4               IN Varchar2
         ,p_adr_attribute5               IN Varchar2
         ,p_adr_attribute6               IN Varchar2
         ,p_adr_attribute7               IN Varchar2
         ,p_adr_attribute8               IN Varchar2
         ,p_adr_attribute9               IN Varchar2
         ,p_adr_attribute10              IN Varchar2
         ,p_adr_attribute11              IN Varchar2
         ,p_adr_attribute12              IN Varchar2
         ,p_adr_attribute13              IN Varchar2
         ,p_adr_attribute14              IN Varchar2
         ,p_adr_attribute15              IN Varchar2
         ,p_adr_attribute16              IN Varchar2
         ,p_adr_attribute17              IN Varchar2
         ,p_adr_attribute18              IN Varchar2
         ,p_adr_attribute19              IN Varchar2
         ,p_adr_attribute20              IN Varchar2
         ,p_business_group_id            IN Number
         ,p_data_pump_flag               IN Varchar2
         ,p_add_information13            IN Varchar2
         ,p_add_information14            IN Varchar2
         ,p_add_information15            IN Varchar2
         ,p_add_information16            IN Varchar2
         ,p_add_information17            IN Varchar2
         ,p_add_information18            IN Varchar2
         ,p_add_information19            IN Varchar2
         ,p_add_information20            IN Varchar2
         ,p_concat_segments              IN Varchar2
         ,p_people_segment1              IN Varchar2
         ,p_people_segment2              IN Varchar2
         ,p_people_segment3              IN Varchar2
         ,p_people_segment4              IN Varchar2
         ,p_people_segment5              IN Varchar2
         ,p_people_segment6              IN Varchar2
         ,p_people_segment7              IN Varchar2
         ,p_people_segment8              IN Varchar2
         ,p_people_segment9              IN Varchar2
         ,p_people_segment10             IN Varchar2
         ,p_people_segment11             IN Varchar2
         ,p_people_segment12             IN Varchar2
         ,p_people_segment13             IN Varchar2
         ,p_people_segment14             IN Varchar2
         ,p_people_segment15             IN Varchar2
         ,p_people_segment16             IN Varchar2
         ,p_people_segment17             IN Varchar2
         ,p_people_segment18             IN Varchar2
         ,p_people_segment19             IN Varchar2
         ,p_people_segment20             IN Varchar2
         ,p_people_segment21             IN Varchar2
         ,p_people_segment22             IN Varchar2
         ,p_people_segment23             IN Varchar2
         ,p_people_segment24             IN Varchar2
         ,p_people_segment25             IN Varchar2
         ,p_people_segment26             IN Varchar2
         ,p_people_segment27             IN Varchar2
         ,p_people_segment28             IN Varchar2
         ,p_people_segment29             IN Varchar2
         ,p_people_segment30             IN Varchar2
         ,p_soft_segments                IN Varchar2
         ,p_soft_segment1                IN Varchar2
         ,p_soft_segment2                IN Varchar2
         ,p_soft_segment3                IN Varchar2
         ,p_soft_segment4                IN Varchar2
         ,p_soft_segment5                IN Varchar2
         ,p_soft_segment6                IN Varchar2
         ,p_soft_segment7                IN Varchar2
         ,p_soft_segment8                IN Varchar2
         ,p_soft_segment9                IN Varchar2
         ,p_soft_segment10               IN Varchar2
         ,p_soft_segment11               IN Varchar2
         ,p_soft_segment12               IN Varchar2
         ,p_soft_segment13               IN Varchar2
         ,p_soft_segment14               IN Varchar2
         ,p_soft_segment15               IN Varchar2
         ,p_soft_segment16               IN Varchar2
         ,p_soft_segment17               IN Varchar2
         ,p_soft_segment18               IN Varchar2
         ,p_soft_segment19               IN Varchar2
         ,p_soft_segment20               IN Varchar2
         ,p_soft_segment21               IN Varchar2
         ,p_soft_segment22               IN Varchar2
         ,p_soft_segment23               IN Varchar2
         ,p_soft_segment24               IN Varchar2
         ,p_soft_segment25               IN Varchar2
         ,p_soft_segment26               IN Varchar2
         ,p_soft_segment27               IN Varchar2
         ,p_soft_segment28               IN Varchar2
         ,p_soft_segment29               IN Varchar2
         ,p_soft_segment30               IN Varchar2
         ,p_business_group_name          IN Varchar2
         ,p_batch_id                     IN Number
         ,p_data_pump_batch_line_id      IN Varchar2
         ,p_per_comments                 IN Varchar2
         ,p_date_employee_data_verified  IN Date
         ,p_expense_check_send_to_addres IN Varchar2
         ,p_previous_last_name           IN Varchar2
         ,p_registered_disabled_flag     IN Varchar2
         ,p_vendor_id                    IN Number
         ,p_date_of_death                IN Date
         ,p_background_check_status      IN Varchar2
         ,p_background_date_check        IN Date
         ,p_blood_type                   IN Varchar2
         ,p_correspondence_language      IN Varchar2
         ,p_fast_path_employee           IN Varchar2
         ,p_fte_capacity                 IN Number
         ,p_honors                       IN Varchar2
         ,p_last_medical_test_by         IN Varchar2
         ,p_last_medical_test_date       IN Date
         ,p_mailstop                     IN Varchar2
         ,p_office_number                IN Varchar2
         ,p_on_military_service          IN Varchar2
         ,p_pre_name_adjunct             IN Varchar2
         ,p_projected_start_date         IN Date
         ,p_resume_exists                IN Varchar2
         ,p_resume_last_updated          IN Date
         ,p_second_passport_exists       IN Varchar2
         ,p_student_status               IN Varchar2
         ,p_work_schedule                IN Varchar2
         ,p_benefit_group_id             IN Number
         ,p_receipt_of_death_cert_date   IN Date
         ,p_coord_ben_med_pln_no         IN Varchar2
         ,p_coord_ben_no_cvg_flag        IN Varchar2
         ,p_coord_ben_med_ext_er         IN Varchar2
         ,p_coord_ben_med_pl_name        IN Varchar2
         ,p_coord_ben_med_insr_crr_name  IN Varchar2
         ,p_coord_ben_med_insr_crr_ident IN Varchar2
         ,p_coord_ben_med_cvg_strt_dt    IN Date
         ,p_coord_ben_med_cvg_end_dt     IN Date
         ,p_uses_tobacco_flag            IN Varchar2
         ,p_dpdnt_adoption_date          IN Date
         ,p_dpdnt_vlntry_svce_flag       IN Varchar2
         ,p_original_date_of_hire        IN Date
         ,p_adjusted_svc_date            IN Date
         ,p_town_of_birth                IN Varchar2
         ,p_region_of_birth              IN Varchar2
         ,p_country_of_birth             IN Varchar2
         ,p_global_person_id             IN Varchar2
         ,p_party_id                     IN Number
         ,p_supervisor_id                IN Number
         ,p_assignment_number            IN Varchar2
         ,p_change_reason                IN Varchar2
         ,p_asg_comments                 IN Varchar2
         ,p_date_probation_end           IN Date
         ,p_default_code_comb_id         IN Number
         ,p_frequency                    IN Varchar2
         ,p_internal_address_line        IN Varchar2
         ,p_manager_flag                 IN Varchar2
         ,p_normal_hours                 IN Number
         ,p_perf_review_period           IN Number
         ,p_perf_review_period_frequency IN Varchar2
         ,p_probation_period             IN Number
         ,p_probation_unit               IN Varchar2
         ,p_sal_review_period            IN Number
         ,p_sal_review_period_frequency  IN Varchar2
         ,p_set_of_books_id              IN Number
         ,p_source_type                  IN Varchar2
         ,p_time_normal_finish           IN Varchar2
         ,p_time_normal_start            IN Varchar2
         ,p_bargaining_unit_code         IN Varchar2
         ,p_labour_union_member_flag     IN Varchar2
         ,p_hourly_salaried_code         IN Varchar2
         ,p_pradd_ovlapval_override      IN Varchar2
         ,p_address_type                 IN Varchar2
         ,p_adr_comments                 IN Varchar2
         ,p_batch_name                   IN Varchar2
         ,p_location_id                  IN Number
         ,p_student_number               IN Varchar2
          ) AS

  -- Checking for EX-EMP as we should allow a person to be rehired, that implies
  -- that NI for EX-Employee may already exist
  CURSOR csr_chk_ni_exists (c_ni       Varchar2
                           ,c_bgid     Number
                           ,c_eff_date Date) IS
  SELECT 'Y'
    FROM per_people_f ppf, per_person_types ppt
   WHERE ppf.national_identifier = c_ni
     AND ppf.business_group_id   = c_bgid
     AND ppf.business_group_id   = ppt.business_group_id
     AND ppf.person_type_id      = ppt.person_type_id
     AND ppt.active_flag         = 'Y'
     AND c_eff_date BETWEEN ppf.effective_start_date
                        AND ppf.effective_end_date;

  -- Cursor to fetch duplicate assignment id using duplicate person id
  CURSOR  get_dup_asg_id (c_dup_per_id         Varchar2
                         ,c_business_group_id  Varchar2
                         ,c_eff_date           Date) IS
  SELECT paf.assignment_id
    FROM per_people_f ppf, per_assignments_f paf
   WHERE paf.person_id          = c_dup_per_id
     AND paf.person_id          = ppf.person_id
     AND paf.business_group_id  = c_business_group_id
     AND paf.business_group_id  = ppf.business_group_id
     AND c_eff_date BETWEEN paf.effective_start_date
                        AND paf.effective_end_date
     AND c_eff_date BETWEEN ppf.effective_start_date
                        AND ppf.effective_end_date;



  -- Dynamic Ref Cursor
  TYPE ref_cur_typ IS REF CURSOR;
  csr_get_unmasked_ni          ref_cur_typ;
  csr_get_party_id             ref_cur_typ;

  l_chk_per                chk_party%ROWTYPE;
  l_dff_ctx          fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE;
  l_emp_api_out            t_hrEmpApi;
  l_asg_crit_out           t_AsgUpdCrit_Api;
  l_updper_api_out         t_UpdEmp_Api;
  l_crt_emp_api_out        t_CreateContact_Api;
  l_HireToJobapi_out       t_HrToJob_Api;
  l_effective_date         Date;
  l_national_identifier    per_people_f.national_identifier%TYPE;
  l_party_id               per_people_f.party_id%TYPE;
  l_ni_exists              Varchar2(10);
  l_dyn_sql_qry            Varchar(500);
  l_sql_qry                Varchar(500);
  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Create_Student_Employee';

  l_pp_error_code          Varchar2(50);
  l_passport_warning       Boolean;
  l_visa_error_code        Varchar2(50);
  l_visa_warning           Boolean;
  l_visit_error_code       Varchar2(50);
  l_visit_warning          Boolean;

  l_oss_error_code         Varchar2(50);
  l_ossDtls_warning        Boolean;

  l_student_number         Varchar2(100);
  l_dup_asg_id             Number;
  l_HireAppapi_out         t_HrApp_Api;
  l_error_message          Varchar2(2000);
  l_active_cwk             Boolean;
  e_active_cwk             Exception;

 --  Function to return correct format of people group segments (Bug 4160812)
 FUNCTION f_formatted_grp_seg_val(p_seg_name IN VARCHAR2,p_seg_val IN VARCHAR2)
   RETURN VARCHAR2
 IS
   l_format_type fnd_flex_value_sets.format_type%TYPE;
 BEGIN
   SELECT format_type  INTO l_format_type
    FROM FND_ID_FLEX_SEGMENTS_VL a, fnd_flex_value_sets b
   WHERE id_flex_num = (SELECT people_group_structure
                       FROM per_business_groups_perf
                       WHERE business_group_id = p_business_group_id)
   AND a.flex_value_set_id = b.flex_value_set_id
   AND 'p_people_'||lower(application_column_name) = p_seg_name;

   IF l_format_type in ('X','Y') THEN
      RETURN fnd_date.date_to_canonical(p_seg_val);
   ELSE
      RETURN p_seg_val;
   END IF;
 EXCEPTION WHEN others THEN
   RETURN p_seg_val;
 END;

BEGIN
    SAVEPOINT create_student_employee;
    g_debug_on := hr_utility.debug_enabled;

    hr_utility.set_location('Entering: ' || l_proc_name, 10);

    l_per_rec        := NULL;
    l_hr_soft_rec    := NULL;
    l_add_rec        := NULL;
    l_ppl_grp_rec    := NULL;
    l_asg_rec        := NULL;
    l_effective_date := p_date_of_hire;
    l_dup_asg_id     := 0;

    -- Get Bus. Group Id in a pkg global variable

    IF (csr_bg_code%ISOPEN) THEN
        CLOSE csr_bg_code;
    END IF;
    OPEN  csr_bg_code (c_bg_grp_id => p_business_group_id);
    FETCH csr_bg_code
       INTO g_leg_code,
            g_emp_num_gen;
    CLOSE csr_bg_code;

  -- Check if NI is masked, If yes then get the actual NI from OSS/DP tables
  -- Right now the logic assumes that NI is for GB and US legislation only
  -- Later we will have a generic logic to identify the masking

    l_student_number := p_student_number;
    IF (substrb(p_national_identifier, 1, lengthb(p_national_identifier) - 4) =
            'XXX-XX-' OR
       substrb(p_national_identifier, 3, 2) = 'XX'  OR
       substrb(p_national_identifier, 1, lengthb(p_national_identifier) - 4) =
            'XXXXX') THEN
     -- Getting the National Identifier only if the student number and last
     -- 4 digits of the masked NI are same. This logic will fail if user
     -- changes NI or Student number. Hence it needs to be documneted

        hr_utility.set_location('Checking NI ', 20);

        IF p_web_adi_identifier <> 'DP ERROR' THEN
            l_dyn_sql_qry := 'SELECT api_person_id '        ||
                            'FROM   igs_pe_person_v '      ||
                            'WHERE  person_number = ''' || l_student_number
                                           || ''' ' ||
                           ' AND api_person_id LIKE ''%' ||
                           SUBSTRB(p_national_identifier,
                           LENGTHB(p_national_identifier) - 3, 4) || '''';
        ELSE
            l_dyn_sql_qry := 'SELECT p_national_identifier ' ||
                            ' FROM hrdpv_create_employee '  ||
                            ' WHERE batch_id = ' || p_batch_id  ||
                            ' AND link_value = ' || p_data_pump_batch_line_id ||
                            ' UNION SELECT p_national_identifier ' ||
                            ' FROM hrdpv_update_person '           ||
                            ' WHERE batch_id = ' || p_batch_id     ||
                            ' AND link_value = ' || p_data_pump_batch_line_id;

        END IF;

        IF (csr_get_unmasked_ni%ISOPEN) THEN
            CLOSE csr_get_unmasked_ni;
        END IF;
        OPEN  csr_get_unmasked_ni FOR l_dyn_sql_qry;
        FETCH csr_get_unmasked_ni INTO l_national_identifier;
        CLOSE csr_get_unmasked_ni;
    ELSE
        l_national_identifier := p_national_identifier;
    END IF;

  -- Check if NI entered already exists in the system, that implies that user is
  -- accidently trying to enter a duplicate. Throw an error for the same
  -- Essentially this over rides the Profile Value used to control the
  -- duplicate NI in system

    IF (csr_chk_ni_exists%ISOPEN) THEN -- {
        CLOSE csr_chk_ni_exists;
    END IF; -- }
    OPEN  csr_chk_ni_exists( c_ni       => l_national_identifier
                           , c_bgid     => p_business_group_id
                           , c_eff_date => p_date_of_hire);

    FETCH csr_chk_ni_exists INTO l_ni_exists;
    CLOSE csr_chk_ni_exists;

    IF l_ni_exists IS NOT NULL AND p_dup_person_id IS NULL THEN -- {
        hr_utility.set_message(8303, 'PQP_230171_OSS_NI_EXISTS');
        hr_utility.raise_error;
    END IF; -- }

  -- Get Party Id corresponding to Student Number. We are assuming that there
  -- will never be a case when student number is not entered

    IF (l_student_number IS NOT NULL) THEN -- {
        hr_utility.set_location('Student number is not null ', 30);
        l_sql_qry := 'SELECT ipe.person_id ' ||
                     ' FROM igs_pe_person_v ipe, hz_party_sites hps '        ||
                     ' WHERE hps.party_id (+)              = ipe.person_id ' ||
                     ' AND hps.identifying_address_flag(+) = ''Y'' '         ||
                     ' AND ipe.person_number = ''' ||
                                         l_student_number || '''';

        hr_utility.set_location('Dynamic query build ', 40);

        IF (csr_get_party_id%ISOPEN) THEN -- {
            CLOSE csr_get_party_id;
        END IF; -- }
        OPEN  csr_get_party_id FOR l_sql_qry;
        FETCH csr_get_party_id INTO l_party_id;
        CLOSE csr_get_party_id;
    END IF; -- }

    hr_utility.set_location('Start of filling person rec ', 50);

  -- ===========================================================================
  -- ~ Person Details
  -- ===========================================================================
    l_per_rec.business_group_id           := p_business_group_id;
    l_per_rec.party_id                    := l_party_id;
    l_per_rec.last_name                   := p_last_name;
    l_per_rec.middle_names                := p_middle_name;
    l_per_rec.first_name                  := p_first_name;
    l_per_rec.suffix                      := p_suffix;
    l_per_rec.pre_name_adjunct            := p_prefix;
    l_per_rec.title                       := p_title;
    l_per_rec.email_address               := p_email_address;
    l_per_rec.known_as                    := p_preferred_name;
    l_per_rec.marital_status              := p_marital_status;
    l_per_rec.sex                         := p_sex;
    l_per_rec.nationality                 := p_nationality;
    l_per_rec.national_identifier         := l_national_identifier;
    l_per_rec.date_of_birth               := p_date_of_birth;
    l_per_rec.start_date                  := p_date_of_hire;
    l_per_rec.employee_number             := p_employee_number;
    l_per_rec.person_type_id              := p_user_person_type;
    l_per_rec.date_employee_data_verified := p_date_employee_data_verified;
    l_per_rec.expense_check_send_to_address := p_expense_check_send_to_addres;
    l_per_rec.previous_last_name          := p_previous_last_name;
    l_per_rec.registered_disabled_flag    := p_registered_disabled_flag;
    l_per_rec.vendor_id                   := p_vendor_id;
    l_per_rec.date_of_death               := p_date_of_death;
    l_per_rec.background_check_status     := p_background_check_status;
    l_per_rec.background_date_check       := p_background_date_check;
    l_per_rec.blood_type                  := p_blood_type;
    l_per_rec.correspondence_language     := p_correspondence_language;
    l_per_rec.fast_path_employee          := p_fast_path_employee;
    l_per_rec.fte_capacity                := p_fte_capacity;
    l_per_rec.honors                      := p_honors;
    l_per_rec.last_medical_test_by        := p_last_medical_test_by;
    l_per_rec.last_medical_test_date      := p_last_medical_test_date;
    l_per_rec.mailstop                    := p_mailstop;
    l_per_rec.office_number               := p_office_number;
    l_per_rec.on_military_service         := NVL(p_on_military_service,'N');
-- pre_name_adjunct is called as prefix in OSS and hence the correct value
-- is picked from the parameter p_prefix and not p_pre_name_adjunct.
--    l_per_rec.pre_name_adjunct            := p_pre_name_adjunct;
    l_per_rec.projected_start_date        := p_projected_start_date;
    l_per_rec.resume_exists               := NVL(p_resume_exists,'N');
    l_per_rec.resume_last_updated         := p_resume_last_updated;
    l_per_rec.second_passport_exists      := NVL(p_second_passport_exists,'N');
    l_per_rec.student_status              := p_student_status;
    l_per_rec.work_schedule               := p_work_schedule;
    l_per_rec.benefit_group_id            := p_benefit_group_id;
    l_per_rec.receipt_of_death_cert_date  := p_receipt_of_death_cert_date;
    l_per_rec.coord_ben_med_pln_no        := p_coord_ben_med_pln_no;
    l_per_rec.coord_ben_no_cvg_flag       := NVL(p_coord_ben_no_cvg_flag,'N');
    l_per_rec.coord_ben_med_ext_er        := p_coord_ben_med_ext_er;
    l_per_rec.coord_ben_med_pl_name       := p_coord_ben_med_pl_name;
    l_per_rec.coord_ben_med_insr_crr_name := p_coord_ben_med_insr_crr_name;
    l_per_rec.coord_ben_med_insr_crr_ident:= p_coord_ben_med_insr_crr_ident;
    l_per_rec.coord_ben_med_cvg_strt_dt   := p_coord_ben_med_cvg_strt_dt;
    l_per_rec.coord_ben_med_cvg_end_dt    := p_coord_ben_med_cvg_end_dt;
    l_per_rec.uses_tobacco_flag           := p_uses_tobacco_flag;
    l_per_rec.dpdnt_adoption_date         := p_dpdnt_adoption_date;
    l_per_rec.dpdnt_vlntry_svce_flag      := NVL(p_dpdnt_vlntry_svce_flag,'N');
    l_per_rec.original_date_of_hire       := p_original_date_of_hire;
    l_per_rec.town_of_birth               := p_town_of_birth;
    l_per_rec.region_of_birth             := p_region_of_birth;
    l_per_rec.country_of_birth            := p_country_of_birth;
    l_per_rec.global_person_id            := p_global_person_id;

    hr_utility.set_location('Person Details assigned to record : l_per_rec ',
                                                                   60);

    -- Person DF: Customer defined

    l_per_rec.attribute_category            := p_per_attribute_category;
    l_per_rec.attribute1                    := p_per_attribute1;
    l_per_rec.attribute2                    := p_per_attribute2;
    l_per_rec.attribute3                    := p_per_attribute3;
    l_per_rec.attribute4                    := p_per_attribute4;
    l_per_rec.attribute5                    := p_per_attribute5;
    l_per_rec.attribute6                    := p_per_attribute6;
    l_per_rec.attribute7                    := p_per_attribute7;
    l_per_rec.attribute8                    := p_per_attribute8;
    l_per_rec.attribute9                    := p_per_attribute9;
    l_per_rec.attribute10                   := p_per_attribute10;
    l_per_rec.attribute11                   := p_per_attribute11;
    l_per_rec.attribute12                   := p_per_attribute12;
    l_per_rec.attribute13                   := p_per_attribute13;
    l_per_rec.attribute14                   := p_per_attribute14;
    l_per_rec.attribute15                   := p_per_attribute15;
    l_per_rec.attribute16                   := p_per_attribute16;
    l_per_rec.attribute17                   := p_per_attribute17;
    l_per_rec.attribute18                   := p_per_attribute18;
    l_per_rec.attribute19                   := p_per_attribute19;
    l_per_rec.attribute20                   := p_per_attribute20;
    l_per_rec.attribute21                   := p_per_attribute21;
    l_per_rec.attribute22                   := p_per_attribute22;
    l_per_rec.attribute23                   := p_per_attribute23;
    l_per_rec.attribute24                   := p_per_attribute24;
    l_per_rec.attribute25                   := p_per_attribute25;
    l_per_rec.attribute26                   := p_per_attribute26;
    l_per_rec.attribute27                   := p_per_attribute27;
    l_per_rec.attribute28                   := p_per_attribute28;
    l_per_rec.attribute29                   := p_per_attribute29;
    l_per_rec.attribute30                   := p_per_attribute30;

    hr_utility.set_location('Person DF assigned to record :l_per_rec ', 70);

    -- Person DDF: Different for each legislation

    IF (csr_style%ISOPEN) THEN -- {
        CLOSE csr_style;
    END IF; -- }
    OPEN  csr_style (c_context_code => g_leg_code);
    FETCH csr_style INTO l_dff_ctx;
    IF csr_style%FOUND THEN
        l_per_rec.per_information_category  :=
                 NVL(p_per_information_category, g_leg_code);
    END IF;
    CLOSE csr_style;

    l_per_rec.per_information1              := p_per_information1;
    l_per_rec.per_information2              := p_per_information2;
    l_per_rec.per_information3              := p_per_information3;
    l_per_rec.per_information4              := p_per_information4;
    l_per_rec.per_information5              := p_per_information5;
    l_per_rec.per_information6              := p_per_information6;
    l_per_rec.per_information7              := p_per_information7;
    l_per_rec.per_information8              := p_per_information8;
    l_per_rec.per_information9              := p_per_information9;
    l_per_rec.per_information10             := p_per_information10;
    l_per_rec.per_information11             := p_per_information11;
    l_per_rec.per_information12             := p_per_information12;
    l_per_rec.per_information13             := p_per_information13;
    l_per_rec.per_information14             := p_per_information14;
    l_per_rec.per_information15             := p_per_information15;
    l_per_rec.per_information16             := p_per_information16;
    l_per_rec.per_information17             := p_per_information17;
    l_per_rec.per_information18             := p_per_information18;
    l_per_rec.per_information19             := p_per_information19;
    l_per_rec.per_information20             := p_per_information20;
    l_per_rec.per_information21             := p_per_information21;
    l_per_rec.per_information22             := p_per_information22;
    l_per_rec.per_information23             := p_per_information23;
    l_per_rec.per_information24             := p_per_information24;
    l_per_rec.per_information25             := p_per_information25;
    l_per_rec.per_information26             := p_per_information26;
    l_per_rec.per_information27             := p_per_information27;
    l_per_rec.per_information28             := p_per_information28;
    l_per_rec.per_information29             := p_per_information29;
    l_per_rec.per_information30             := p_per_information30;

    hr_utility.set_location('Person DDF assigned to record : l_per_rec ', 80);

    -- =======================================================================
    -- ~ Person Address Record
    -- =======================================================================
    l_add_rec.business_group_id             := p_business_group_id;
    l_add_rec.party_id                      := l_party_id;
    l_add_rec.address_type                  := p_address_type;
    l_add_rec.comments                      := p_adr_comments;
    l_add_rec.primary_flag                  := p_primary_flag;
    l_add_rec.style                         := p_address_style;
    l_add_rec.address_line1                 := p_address_line1;
    l_add_rec.address_line2                 := p_address_line2;
    l_add_rec.address_line3                 := p_address_line3;
    l_add_rec.region_1                      := p_region1;
    l_add_rec.region_2                      := p_region2;
    l_add_rec.region_3                      := p_region3;
    l_add_rec.town_or_city                  := p_town_or_city;
    l_add_rec.country                       := p_country;
    l_add_rec.postal_code                   := p_postal_code;
    l_add_rec.telephone_number_1            := p_telephone_no1;
    l_add_rec.telephone_number_2            := p_telephone_no2;
    l_add_rec.telephone_number_3            := p_telephone_no3;
    l_add_rec.date_from                     := p_address_date_from;
    l_add_rec.date_to                       := p_address_date_to;
    l_add_rec.add_information13             := p_add_information13;
    l_add_rec.add_information14             := p_add_information14;
    l_add_rec.add_information15             := p_add_information15;
    l_add_rec.add_information16             := p_add_information16;
    l_add_rec.add_information17             := p_add_information17;
    l_add_rec.add_information18             := p_add_information18;
    l_add_rec.add_information19             := p_add_information19;
    l_add_rec.add_information20             := p_add_information20;

    hr_utility.set_location('Address DDF assigned to record, Style: ' ||
                             p_address_style, 90);
    -- Address DF

    l_add_rec.addr_attribute_category       := p_adr_attribute_category;
    l_add_rec.addr_attribute1               := p_adr_attribute1;
    l_add_rec.addr_attribute2               := p_adr_attribute2;
    l_add_rec.addr_attribute3               := p_adr_attribute3;
    l_add_rec.addr_attribute4               := p_adr_attribute4;
    l_add_rec.addr_attribute5               := p_adr_attribute5;
    l_add_rec.addr_attribute6               := p_adr_attribute6;
    l_add_rec.addr_attribute7               := p_adr_attribute7;
    l_add_rec.addr_attribute8               := p_adr_attribute8;
    l_add_rec.addr_attribute9               := p_adr_attribute9;
    l_add_rec.addr_attribute10              := p_adr_attribute10;
    l_add_rec.addr_attribute11              := p_adr_attribute11;
    l_add_rec.addr_attribute12              := p_adr_attribute12;
    l_add_rec.addr_attribute13              := p_adr_attribute13;
    l_add_rec.addr_attribute14              := p_adr_attribute14;
    l_add_rec.addr_attribute15              := p_adr_attribute15;
    l_add_rec.addr_attribute16              := p_adr_attribute16;
    l_add_rec.addr_attribute17              := p_adr_attribute17;
    l_add_rec.addr_attribute18              := p_adr_attribute18;
    l_add_rec.addr_attribute19              := p_adr_attribute19;
    l_add_rec.addr_attribute20              := p_adr_attribute20;

    hr_utility.set_location('Address DF assigned to record, Style: ' ||
                             p_address_style, 100);
    -- ========================================================================
    -- ~ Person Primary Assignment
    -- ========================================================================
    l_asg_rec.business_group_id             := p_business_group_id;
    l_asg_rec.organization_id               := p_assign_organization;
    l_asg_rec.job_id                        := p_job;
    l_asg_rec.grade_id                      := p_grade;
    l_asg_rec.people_group_id               := p_assign_group;
    l_asg_rec.position_id                   := p_position;
    l_asg_rec.payroll_id                    := p_payroll;
    l_asg_rec.assignment_status_type_id     := p_status;
    l_asg_rec.assignment_number             := p_assignment_no;
    l_asg_rec.assignment_category           := p_assignment_category;
    l_asg_rec.collective_agreement_id       := p_collective_agreement;
    l_asg_rec.employee_category             := p_employee_category;
    l_asg_rec.pay_basis_id                  := p_salary_basis;
    l_asg_rec.effective_start_date          := p_assign_eff_dt_from;
    l_asg_rec.effective_end_date            := p_assign_eff_dt_to;
    l_asg_rec.supervisor_id                 := p_supervisor_id;
    l_asg_rec.assignment_number             := p_assignment_number;
    l_asg_rec.change_reason                 := p_change_reason;
    l_asg_rec.date_probation_end            := p_date_probation_end;
    l_asg_rec.default_code_comb_id          := p_default_code_comb_id;
    l_asg_rec.frequency                     := p_frequency;
    l_asg_rec.internal_address_line         := p_internal_address_line;
    l_asg_rec.manager_flag                  := p_manager_flag;
    l_asg_rec.normal_hours                  := p_normal_hours;
    l_asg_rec.perf_review_period            := p_perf_review_period;
    l_asg_rec.perf_review_period_frequency  := p_perf_review_period_frequency;
    l_asg_rec.probation_period              := p_probation_period;
    l_asg_rec.probation_unit                := p_probation_unit;
    l_asg_rec.sal_review_period             := p_sal_review_period;
    l_asg_rec.sal_review_period_frequency   := p_sal_review_period_frequency;
    l_asg_rec.set_of_books_id               := p_set_of_books_id;
    l_asg_rec.source_type                   := p_source_type;
    l_asg_rec.time_normal_finish            := p_time_normal_finish;
    l_asg_rec.time_normal_start             := p_time_normal_start;
    l_asg_rec.bargaining_unit_code          := p_bargaining_unit_code;
    l_asg_rec.labour_union_member_flag      := p_labour_union_member_flag;
    l_asg_rec.hourly_salaried_code          := p_hourly_salaried_code;
    l_asg_rec.location_id                   := p_location_id;

    hr_utility.set_location('Primary Assignment details assigned to ' ||
                             'record ', 110);

    -- Additional Assignment Details

    l_asg_rec.ass_attribute_category        := p_ass_attribute_category;
    l_asg_rec.ass_attribute1                := p_ass_attribute1;
    l_asg_rec.ass_attribute2                := p_ass_attribute2;
    l_asg_rec.ass_attribute3                := p_ass_attribute3;
    l_asg_rec.ass_attribute4                := p_ass_attribute4;
    l_asg_rec.ass_attribute5                := p_ass_attribute5;
    l_asg_rec.ass_attribute6                := p_ass_attribute6;
    l_asg_rec.ass_attribute7                := p_ass_attribute7;
    l_asg_rec.ass_attribute8                := p_ass_attribute8;
    l_asg_rec.ass_attribute9                := p_ass_attribute9;
    l_asg_rec.ass_attribute10               := p_ass_attribute10;
    l_asg_rec.ass_attribute11               := p_ass_attribute11;
    l_asg_rec.ass_attribute12               := p_ass_attribute12;
    l_asg_rec.ass_attribute13               := p_ass_attribute13;
    l_asg_rec.ass_attribute14               := p_ass_attribute14;
    l_asg_rec.ass_attribute15               := p_ass_attribute15;
    l_asg_rec.ass_attribute16               := p_ass_attribute16;
    l_asg_rec.ass_attribute17               := p_ass_attribute17;
    l_asg_rec.ass_attribute18               := p_ass_attribute18;
    l_asg_rec.ass_attribute19               := p_ass_attribute19;
    l_asg_rec.ass_attribute20               := p_ass_attribute20;
    l_asg_rec.ass_attribute21               := p_ass_attribute21;
    l_asg_rec.ass_attribute22               := p_ass_attribute22;
    l_asg_rec.ass_attribute23               := p_ass_attribute23;
    l_asg_rec.ass_attribute24               := p_ass_attribute24;
    l_asg_rec.ass_attribute25               := p_ass_attribute25;
    l_asg_rec.ass_attribute26               := p_ass_attribute26;
    l_asg_rec.ass_attribute27               := p_ass_attribute27;
    l_asg_rec.ass_attribute28               := p_ass_attribute28;
    l_asg_rec.ass_attribute29               := p_ass_attribute29;
    l_asg_rec.ass_attribute30               := p_ass_attribute30;

    hr_utility.set_location('Additional Assignment Details assigned to ' ||
                            'record ', 120);
    -- =======================================================================
    -- ~ Contact Details
    -- =======================================================================
    l_cntct_rec.business_group_id           := p_business_group_id;
    l_cntct_rec.contact_type                := p_contact_type;
    l_cntct_rec.primary_contact_flag        := p_primary_contact;
    l_cntct_rec.personal_flag               := p_personal_flag;

    hr_utility.set_location('Contact details assigned to record ', 130);
    -- ========================================================================
    -- ~ Person Phones
    -- ========================================================================
    l_phones_rec.phone_type                 := p_phone_type;
    l_phones_rec.phone_number               := p_phone_number;
    l_phones_rec.date_from                  := p_phone_date_from;
    l_phones_rec.date_to                    := p_phone_date_to;
    l_phones_rec.party_id                   := l_party_id;
    l_phones_rec.parent_table               := 'PER_ALL_PEOPLE_F';

    hr_utility.set_location('Phone Details assigned to record ', 140);
    -- ========================================================================
    -- ~ Soft Coding Keyflex field
    -- ========================================================================
    l_hr_soft_rec.concatenated_segments     := p_soft_segments;
    -- Due to issues in WebADI limitation, web-adi will pass p_gre
    l_hr_soft_rec.segment1                  := NVL(p_soft_segment1, p_gre);
    l_hr_soft_rec.segment2                  := p_soft_segment2;
    l_hr_soft_rec.segment3                  := p_soft_segment3;
    l_hr_soft_rec.segment4                  := p_soft_segment4;
    l_hr_soft_rec.segment5                  := p_soft_segment5;
    l_hr_soft_rec.segment6                  := p_soft_segment6;
    l_hr_soft_rec.segment7                  := p_soft_segment7;
    l_hr_soft_rec.segment8                  := p_soft_segment8;
    l_hr_soft_rec.segment9                  := p_soft_segment9;
    l_hr_soft_rec.segment10                 := p_soft_segment10;
    l_hr_soft_rec.segment11                 := p_soft_segment11;
    l_hr_soft_rec.segment12                 := p_soft_segment12;
    l_hr_soft_rec.segment13                 := p_soft_segment13;
    l_hr_soft_rec.segment14                 := p_soft_segment14;
    l_hr_soft_rec.segment15                 := p_soft_segment15;
    l_hr_soft_rec.segment16                 := p_soft_segment16;
    l_hr_soft_rec.segment17                 := p_soft_segment17;
    l_hr_soft_rec.segment18                 := p_soft_segment18;
    l_hr_soft_rec.segment19                 := p_soft_segment19;
    l_hr_soft_rec.segment20                 := p_soft_segment20;
    l_hr_soft_rec.segment21                 := p_soft_segment21;
    l_hr_soft_rec.segment22                 := p_soft_segment22;
    l_hr_soft_rec.segment23                 := p_soft_segment23;
    l_hr_soft_rec.segment24                 := p_soft_segment24;
    l_hr_soft_rec.segment25                 := p_soft_segment25;
    l_hr_soft_rec.segment26                 := p_soft_segment26;
    l_hr_soft_rec.segment27                 := p_soft_segment27;
    l_hr_soft_rec.segment28                 := p_soft_segment28;
    l_hr_soft_rec.segment29                 := p_soft_segment29;
    l_hr_soft_rec.segment30                 := p_soft_segment30;

    hr_utility.set_location('Soft Coding KFF segments assigned to record: ' ||
                                         'l_hr_soft_rec ', 150);
    -- ========================================================================
    -- ~ People Group Keyflex
    -- ========================================================================
    l_ppl_grp_rec.group_name               := p_concat_segments;

    /*********  commented for bug fix 4160812 *********************
    l_ppl_grp_rec.segment1                 := p_people_segment1;
    l_ppl_grp_rec.segment2                 := p_people_segment2;
    l_ppl_grp_rec.segment3                 := p_people_segment3;
    l_ppl_grp_rec.segment4                 := p_people_segment4;
    l_ppl_grp_rec.segment5                 := p_people_segment5;
    l_ppl_grp_rec.segment6                 := p_people_segment6;
    l_ppl_grp_rec.segment7                 := p_people_segment7;
    l_ppl_grp_rec.segment8                 := p_people_segment8;
    l_ppl_grp_rec.segment9                 := p_people_segment9;
    l_ppl_grp_rec.segment10                := p_people_segment10;
    l_ppl_grp_rec.segment11                := p_people_segment11;
    l_ppl_grp_rec.segment12                := p_people_segment12;
    l_ppl_grp_rec.segment13                := p_people_segment13;
    l_ppl_grp_rec.segment14                := p_people_segment14;
    l_ppl_grp_rec.segment15                := p_people_segment15;
    l_ppl_grp_rec.segment16                := p_people_segment16;
    l_ppl_grp_rec.segment17                := p_people_segment17;
    l_ppl_grp_rec.segment18                := p_people_segment18;
    l_ppl_grp_rec.segment19                := p_people_segment19;
    l_ppl_grp_rec.segment20                := p_people_segment20;
    l_ppl_grp_rec.segment21                := p_people_segment21;
    l_ppl_grp_rec.segment22                := p_people_segment22;
    l_ppl_grp_rec.segment23                := p_people_segment23;
    l_ppl_grp_rec.segment24                := p_people_segment24;
    l_ppl_grp_rec.segment25                := p_people_segment25;
    l_ppl_grp_rec.segment26                := p_people_segment26;
    l_ppl_grp_rec.segment27                := p_people_segment27;
    l_ppl_grp_rec.segment28                := p_people_segment28;
    l_ppl_grp_rec.segment29                := p_people_segment29;
    l_ppl_grp_rec.segment30                := p_people_segment30;

    *********  commented for bug fix 4160812 *********************/

    l_ppl_grp_rec.segment1  := f_formatted_grp_seg_val('p_people_segment1',p_people_segment1);
    l_ppl_grp_rec.segment2  := f_formatted_grp_seg_val('p_people_segment2', p_people_segment2);
    l_ppl_grp_rec.segment3  := f_formatted_grp_seg_val('p_people_segment3', p_people_segment3);
    l_ppl_grp_rec.segment4  := f_formatted_grp_seg_val('p_people_segment4', p_people_segment4);
    l_ppl_grp_rec.segment5  := f_formatted_grp_seg_val('p_people_segment5', p_people_segment5);
    l_ppl_grp_rec.segment6  := f_formatted_grp_seg_val('p_people_segment6', p_people_segment6);
    l_ppl_grp_rec.segment7  := f_formatted_grp_seg_val('p_people_segment7', p_people_segment7);
    l_ppl_grp_rec.segment8  := f_formatted_grp_seg_val('p_people_segment8', p_people_segment8);
    l_ppl_grp_rec.segment9  := f_formatted_grp_seg_val('p_people_segment9', p_people_segment9);
    l_ppl_grp_rec.segment10 := f_formatted_grp_seg_val('p_people_segment10',p_people_segment10);
    l_ppl_grp_rec.segment11 := f_formatted_grp_seg_val('p_people_segment11',p_people_segment11);
    l_ppl_grp_rec.segment12 := f_formatted_grp_seg_val('p_people_segment12',p_people_segment12);
    l_ppl_grp_rec.segment13 := f_formatted_grp_seg_val('p_people_segment13',p_people_segment13);
    l_ppl_grp_rec.segment14 := f_formatted_grp_seg_val('p_people_segment14',p_people_segment14);
    l_ppl_grp_rec.segment15 := f_formatted_grp_seg_val('p_people_segment15',p_people_segment15);
    l_ppl_grp_rec.segment16 := f_formatted_grp_seg_val('p_people_segment16',p_people_segment16);
    l_ppl_grp_rec.segment17 := f_formatted_grp_seg_val('p_people_segment17',p_people_segment17);
    l_ppl_grp_rec.segment18 := f_formatted_grp_seg_val('p_people_segment18',p_people_segment18);
    l_ppl_grp_rec.segment19 := f_formatted_grp_seg_val('p_people_segment19',p_people_segment19);
    l_ppl_grp_rec.segment20 := f_formatted_grp_seg_val('p_people_segment20',p_people_segment20);
    l_ppl_grp_rec.segment21 := f_formatted_grp_seg_val('p_people_segment21',p_people_segment21);
    l_ppl_grp_rec.segment22 := f_formatted_grp_seg_val('p_people_segment22',p_people_segment22);
    l_ppl_grp_rec.segment23 := f_formatted_grp_seg_val('p_people_segment23',p_people_segment23);
    l_ppl_grp_rec.segment24 := f_formatted_grp_seg_val('p_people_segment24',p_people_segment24);
    l_ppl_grp_rec.segment25 := f_formatted_grp_seg_val('p_people_segment25',p_people_segment25);
    l_ppl_grp_rec.segment26 := f_formatted_grp_seg_val('p_people_segment26',p_people_segment26);
    l_ppl_grp_rec.segment27 := f_formatted_grp_seg_val('p_people_segment27',p_people_segment27);
    l_ppl_grp_rec.segment28 := f_formatted_grp_seg_val('p_people_segment28',p_people_segment28);
    l_ppl_grp_rec.segment29 := f_formatted_grp_seg_val('p_people_segment29',p_people_segment29);
    l_ppl_grp_rec.segment30 := f_formatted_grp_seg_val('p_people_segment30',p_people_segment30);

    hr_utility.set_location('People Grp KFF segments assigned to record: ' ||
                                    'l_ppl_grp_rec ', 160);

  -- Code handles all the cases if the data coming in is not corrected
  -- erronous data pump data, hence not 'DP ERROR'

    IF p_web_adi_identifier <> 'DP ERROR' THEN --{{
        hr_utility.set_location('IF <> DP Error ', 170);
        IF (chk_party%ISOPEN) THEN -- {
            CLOSE chk_party;
        END IF; -- }
        OPEN  chk_party( c_party_id       => l_per_rec.party_id
                       , c_bg_grp_id      => l_per_rec.business_group_id
                       , c_person_id      => p_dup_person_id
                       , c_effective_date => l_effective_date);

        FETCH chk_party INTO l_chk_per;

        IF (chk_party%NOTFOUND) THEN -- {{
            -- If person doesn't exist in system then create a new person
            hr_utility.set_location(' Creating a new Student Employee', 180);
            IF (p_data_pump_flag = 'Y') THEN -- {
                hr_utility.set_location('If data pump flag = Y', 190);
                -- If person is to be created through Data Pump
                hr_datapump(p_data_pump_batch_line_id =>
                                            p_data_pump_batch_line_id
                           , p_batch_id               => p_batch_id
                           , p_contact_name           => p_contact_name
                           , p_adjusted_svc_date      => p_adjusted_svc_date
                           , p_dp_mode                => 'INSERT');
            ELSE -- }{
                hr_utility.set_location('If data pump flag <> Y', 200);
                -- Else person is to be created through real-time APIs
                -- Create the employee
                create_empin_hrms(p_validate          => FALSE
                                 ,p_effective_date    => l_per_rec.start_date
                                 ,p_adjusted_svc_date => p_adjusted_svc_date
                                 ,p_per_comments      => p_per_comments
                                 ,p_emp_api_out       => l_emp_api_out);

                -- Create the primary address

                l_add_rec.person_id    := l_emp_api_out.person_id;
                l_add_rec.primary_flag := 'Y';

                -- Call Address API only if user has eneterd address details

                IF (p_address_line1 IS NOT NULL AND
                    l_add_rec.style IS NOT NULL    ) THEN -- {
                    hr_utility.set_location('Address line 1 is filled', 210);

                    l_add_rec.date_from := l_per_rec.start_date;
                    l_add_rec.date_to   := Null;
                    insupd_address(p_effective_date     => l_per_rec.start_date
                                  , p_hr_address_id     => l_add_rec.address_id
                                  , p_hr_object_version_number =>
                                            l_add_rec.object_version_number);
                END IF; -- }

                -- Update employee primary assignment

                l_asg_rec.assignment_id         := l_emp_api_out.assignment_id;
                l_asg_rec.object_version_number :=
                                   l_emp_api_out.asg_object_version_number;

                hr_utility.set_location('Updating asg criteria ', 220);
                update_stuempasg_criteria(p_effective_date =>
                                                       l_per_rec.start_date ,
                                          p_asg_crit_out   => l_asg_crit_out);

                hr_utility.set_location('Updated asg criteria', 230);

                -- Create Phones record default to H1=Home

                l_phones_rec.parent_id  := l_emp_api_out.person_id;
                l_phones_rec.date_from  := l_per_rec.start_date;
                -- Create Contact Details
                l_cntct_rec.person_id   := l_emp_api_out.person_id;
                -- Create Contact Type only when Contact Details have been
                -- entered
                IF l_cntct_rec.contact_type IS NOT NULL THEN -- {
                    hr_utility.set_location('Contact type is not null', 240);
                    create_person_contact(p_effective_date=>l_per_rec.start_date
                                         , p_contact_name    => p_contact_name
                                         , p_legislation_code => g_leg_code
                                         , p_crt_cntct_out=>l_crt_emp_api_out);
                END IF; -- }
                IF g_leg_code = 'US' THEN
                  -- Get Passport details from OSS
                  Pqp_Hrtca_Integration.InsUpd_InHR_PassPort
                  (p_business_group_id => l_per_rec.business_group_id
                  ,p_person_id         => l_per_rec.person_id
                  ,p_party_id          => l_per_rec.party_id
                  ,p_effective_date    => l_per_rec.start_date
                  ,p_pp_error_code     => l_pp_error_code
                  ,p_passport_warning  => l_passport_warning
                   );
                  -- Get Visa Details from OSS
                  Pqp_Hrtca_Integration.InsUpd_InHR_Visa
                  (p_business_group_id => l_per_rec.business_group_id
                  ,p_person_id         => l_per_rec.person_id
                  ,p_party_id          => l_per_rec.party_id
                  ,p_effective_date    => l_per_rec.start_date
                  ,p_visa_error_code   => l_visa_error_code
                  ,p_visa_warning      => l_visa_warning
                   );
                  -- Get Visit History details from OSS
                  Pqp_Hrtca_Integration.InsUpd_InHR_Visit
                  (p_business_group_id => l_per_rec.business_group_id
                  ,p_person_id         => l_per_rec.person_id
                  ,p_party_id          => l_per_rec.party_id
                  ,p_effective_date    => l_per_rec.start_date
                  ,p_visit_error_code  => l_visit_error_code
                  ,p_visit_warning     => l_visit_warning
                  );
                END IF;
               -- Create People Exra Information
                IF l_student_number IS NOT NULL THEN -- {
                    hr_utility.set_location('Updating Extra Info', 250);
                    hr_utility.set_location('Error Code ' ||
                                     l_oss_error_code, 255);
                    Pqp_Hrtca_Integration.InsUpd_InHR_OSSPerDtls
                     (p_business_group_id => l_per_rec.business_group_id
                     ,p_person_id         => l_per_rec.person_id
                     ,p_party_id          => l_per_rec.party_id
                     ,p_effective_date    => l_per_rec.start_date
                     ,p_oss_error_code    => l_oss_error_code
                     ,p_ossDtls_warning   => l_ossDtls_warning);
                END IF; -- }
            END IF; -- }

        ELSIF (l_chk_per.system_person_type) IN ('OTHER'  ,
                                                 'EX_EMP' ,
                                                 'EX_APL' ) THEN
            -- If the person already exists in the system
            hr_utility.set_location(' Current person type: ' ||
                                    l_chk_per.system_person_type, 260);

	    --Raise error if contingent worker is being tried to be hired as a student employee
            IF l_chk_per.system_person_type ='OTHER' THEN
               FOR ptu_rec IN  csr_per_ptu
                              (c_person_id         => l_chk_per.person_id
                              ,c_business_group_id => p_business_group_id
                              ,c_effective_date    => l_effective_date)
               LOOP
                  IF ptu_rec.system_person_type = 'CWK' THEN
                     l_active_cwk := TRUE;
                     EXIT;
                  END IF;
               END LOOP;
            END IF;

            IF l_active_cwk THEN
               RAISE e_active_cwk;
            END IF;

            -- Hire the existing person
            l_per_rec.party_id  := l_party_id;
            l_per_rec.person_id := p_dup_person_id;
            -- If person is to be re-hired through Data Pump
            IF (p_data_pump_flag = 'Y') THEN -- {{
                hr_utility.set_location(' Data pump flag = Y' , 270);
                l_add_rec.primary_flag := 'Y';
                hr_datapump(p_data_pump_batch_line_id =>
                                                p_data_pump_batch_line_id
                           ,p_batch_id                => p_batch_id
                           ,p_contact_name            => p_contact_name
                           ,p_adjusted_svc_date       => p_adjusted_svc_date
                           ,p_dp_mode                 => 'UPDATE');
            ELSE -- }{
                -- Else person is to be re-hired through real-time APIs
                hr_utility.set_location(' Data pump flag <> Y' , 280);

                hire_person_intoemp(p_validate          => FALSE
                                   ,p_hire_date         => l_per_rec.start_date
                                   ,p_person_id         => p_dup_person_id
                                   ,p_adjusted_svc_date => p_adjusted_svc_date
                                   ,p_updper_api_out    => l_updper_api_out
                                   ,p_HireToJobapi_out  => l_HireToJobapi_out);
                -- Create the primary address
                l_add_rec.person_id    := p_dup_person_id;
                l_add_rec.primary_flag := 'Y';

                IF (p_address_line1 IS NOT NULL AND
                    l_add_rec.style IS NOT NULL) THEN -- {
                  -- Call Address API only if user has eneterd address details
                    hr_utility.set_location('Address line 1 is not null' , 290);
                    l_add_rec.date_from := l_per_rec.start_date;
                    l_add_rec.date_to   := NULL;

                    InsUpd_Address(p_effective_date => l_per_rec.start_date
                                  ,p_HR_address_id  => l_add_rec.address_id
                                  ,p_HR_object_version_number =>
                                             l_add_rec.object_version_number);
                END IF; -- }
                -- Update employee's primary assignment
                l_asg_rec.assignment_id  := l_HireToJobapi_out.assignment_id;
                hr_utility.set_location('Updating Asg criteria' , 300);
                Update_StuEmpAsg_Criteria(p_effective_date =>
                                                l_per_rec.start_date
                                         ,p_asg_crit_out   => l_asg_crit_out);
                hr_utility.set_location('Updated Asg criteria' , 310);
                -- Create Contact Details
                l_cntct_rec.person_id   := l_emp_api_out.person_id;
                -- Create Contact Type only when Contact Dets have been entered
                IF l_cntct_rec.contact_type IS NOT NULL THEN -- {
                    hr_utility.set_location('Updating Contact Details' , 320);
                    Update_Person_Contact(p_effective_date=>l_per_rec.start_date
                                         ,p_contact_name     => p_contact_name
                                         ,p_legislation_code => g_leg_code
                                         ,p_crt_cntct_out => l_crt_emp_api_out);
                END IF; -- }
                IF g_leg_code = 'US' THEN
                  -- Get Passport details from OSS
                  Pqp_Hrtca_Integration.InsUpd_InHR_PassPort
                  (p_business_group_id => l_per_rec.business_group_id
                  ,p_person_id         => l_per_rec.person_id
                  ,p_party_id          => l_per_rec.party_id
                  ,p_effective_date    => l_per_rec.start_date
                  ,p_pp_error_code     => l_pp_error_code
                  ,p_passport_warning  => l_passport_warning
                   );
                  -- Get Visa Details from OSS
                  Pqp_Hrtca_Integration.InsUpd_InHR_Visa
                  (p_business_group_id => l_per_rec.business_group_id
                  ,p_person_id         => l_per_rec.person_id
                  ,p_party_id          => l_per_rec.party_id
                  ,p_effective_date    => l_per_rec.start_date
                  ,p_visa_error_code   => l_visa_error_code
                  ,p_visa_warning      => l_visa_warning
                   );
                  -- Get Visit History details from OSS
                  Pqp_Hrtca_Integration.InsUpd_InHR_Visit
                  (p_business_group_id => l_per_rec.business_group_id
                  ,p_person_id         => l_per_rec.person_id
                  ,p_party_id          => l_per_rec.party_id
                  ,p_effective_date    => l_per_rec.start_date
                  ,p_visit_error_code  => l_visit_error_code
                  ,p_visit_warning     => l_visit_warning
                  );
                END IF;
                IF l_student_number IS NOT NULL THEN -- {
                    -- Create People Exra Information
                    hr_utility.set_location('Updating Extra Info' , 330);
                    Pqp_Hrtca_Integration.InsUpd_InHR_OSSPerDtls
                       (p_business_group_id => l_per_rec.business_group_id
                       ,p_person_id         => l_per_rec.person_id
                       ,p_party_id          => l_per_rec.party_id
                       ,p_effective_date    => l_per_rec.start_date
                       ,p_oss_error_code    => l_oss_error_code
                       ,p_ossDtls_warning   => l_ossDtls_warning);
                END IF; --}
            END IF; -- }
        ELSIF l_chk_per.system_person_type IN
	      ('EX_EMP_APL','APL_EX_APL','APL') THEN -- {
               hr_utility.set_location('..Applicant being hired as Student' ||
                                       ' Employee', 340);
               hr_utility.set_location(' Current person type: ' ||
                                       l_chk_per.system_person_type, 340);
            l_per_rec.party_id  := l_party_id;
            l_per_rec.person_id := p_dup_person_id;
            -- If person is to be re-hired through Data Pump
            IF (p_data_pump_flag = 'Y') THEN -- {{
                hr_utility.set_location(' Data pump flag = Y' , 350);
                l_add_rec.primary_flag := 'Y';
                hr_datapump(p_data_pump_batch_line_id =>
                                                p_data_pump_batch_line_id
                           ,p_batch_id                => p_batch_id
                           ,p_contact_name            => p_contact_name
                           ,p_adjusted_svc_date       => p_adjusted_svc_date
                           ,p_dp_mode                 => 'UPDATE');
            ELSE
                -- Else person is to be re-hired through real-time APIs
                hr_utility.set_location(' Data pump flag <> Y' , 280);
                l_per_rec.person_id         := l_chk_per.person_id;
                l_per_rec.business_group_id := p_business_group_id;
                l_per_rec.party_id          := l_party_id;
                l_effective_date            := p_date_of_hire;
                l_per_rec.start_date        := l_effective_date;

                --Get the value of duplicate assignment id
		IF (get_dup_asg_id%ISOPEN) THEN
		   CLOSE get_dup_asg_id;
		END IF;
		OPEN get_dup_asg_id(c_dup_per_id         => l_chk_per.person_id
		                   ,c_business_group_id  => p_business_group_id
				   ,c_eff_date           => p_date_of_hire);
                FETCH get_dup_asg_id
		   INTO l_dup_asg_id;
		CLOSE get_dup_asg_id;

                IF NVL(l_dup_asg_id,0) <> 0 then
                   Hire_Applicant_IntoEmp
                   (p_validate           => FALSE
                   ,p_hire_date          => l_effective_date
                   ,p_person_id          => l_chk_per.person_id
                   ,p_assignment_id      => l_dup_asg_id
                   ,p_adjusted_svc_date  => p_adjusted_svc_date
                   ,p_updper_api_out     => l_updper_api_out
                   ,p_HireAppapi_out     => l_HireAppapi_out);
                   l_asg_rec.assignment_id  := l_dup_asg_id;
                ELSE
                   Create_EmpIn_HRMS
                   (p_validate            => FALSE
                   ,p_effective_date      => l_per_rec.START_DATE
                   ,p_adjusted_svc_date   => p_adjusted_svc_date
                   ,p_per_comments        => NULL
                   ,p_emp_api_out         => l_emp_api_out
                   );
                   l_add_rec.person_id    := l_emp_api_out.person_id;
                   l_per_rec.person_id    := l_emp_api_out.person_id;
                   l_cntct_rec.person_id  := l_emp_api_out.person_id;
                   l_phones_rec.parent_id  := l_emp_api_out.person_id;
		   l_asg_rec.assignment_id  := l_emp_api_out.assignment_id;
                END IF;

                -- Create Contact Type only when Contact Details have been entered
                l_cntct_rec.person_id   := l_emp_api_out.person_id;
                -- Create Contact Type only when Contact Dets have been entered
                IF l_cntct_rec.contact_type IS NOT NULL THEN
                    hr_utility.set_location('Updating Contact Details' , 320);
                    Update_Person_Contact(p_effective_date=>l_per_rec.start_date
                                         ,p_contact_name     => p_contact_name
                                         ,p_legislation_code => g_leg_code
                                         ,p_crt_cntct_out => l_crt_emp_api_out);
                    hr_utility.set_location('Updated Contact Details' , 320);
                END IF;

                -- Create the primary address
                l_add_rec.person_id    := p_dup_person_id;
                l_add_rec.primary_flag := 'Y';
                -- Call Address API only if user has eneterd address details
                IF (p_address_line1 IS NOT NULL AND
                    l_add_rec.style IS NOT NULL) THEN
                    hr_utility.set_location('Address line 1 is not null' , 290);
                    l_add_rec.date_from := l_per_rec.start_date;
                    l_add_rec.date_to   := NULL;

                    hr_utility.set_location(' Updating Person Primary Address ', 150);
                    InsUpd_Address(p_effective_date => l_per_rec.start_date
                                  ,p_HR_address_id  => l_add_rec.address_id
                                  ,p_HR_object_version_number =>
                                             l_add_rec.object_version_number);
                    hr_utility.set_location(' Updated Person Primary Address ', 150);
                END IF;

                -- Update employee's primary assignment
                hr_utility.set_location('Updating Asg criteria' , 300);
                Update_StuEmpAsg_Criteria(p_effective_date =>
                                                l_per_rec.start_date
                                         ,p_asg_crit_out   => l_asg_crit_out);
                hr_utility.set_location('Updated Asg criteria' , 310);

                IF g_leg_code = 'US' THEN
                  -- Get Passport details from OSS
                  Pqp_Hrtca_Integration.InsUpd_InHR_PassPort
                  (p_business_group_id => l_per_rec.business_group_id
                  ,p_person_id         => l_per_rec.person_id
                  ,p_party_id          => l_per_rec.party_id
                  ,p_effective_date    => l_per_rec.start_date
                  ,p_pp_error_code     => l_pp_error_code
                  ,p_passport_warning  => l_passport_warning
                   );
                  -- Get Visa Details from OSS
                  Pqp_Hrtca_Integration.InsUpd_InHR_Visa
                  (p_business_group_id => l_per_rec.business_group_id
                  ,p_person_id         => l_per_rec.person_id
                  ,p_party_id          => l_per_rec.party_id
                  ,p_effective_date    => l_per_rec.start_date
                  ,p_visa_error_code   => l_visa_error_code
                  ,p_visa_warning      => l_visa_warning
                   );
                  -- Get Visit History details from OSS
                  Pqp_Hrtca_Integration.InsUpd_InHR_Visit
                  (p_business_group_id => l_per_rec.business_group_id
                  ,p_person_id         => l_per_rec.person_id
                  ,p_party_id          => l_per_rec.party_id
                  ,p_effective_date    => l_per_rec.start_date
                  ,p_visit_error_code  => l_visit_error_code
                  ,p_visit_warning     => l_visit_warning
                  );
                END IF;
                IF l_student_number IS NOT NULL THEN
                    -- Create People Exra Information
                    hr_utility.set_location('Updating Extra Info' , 330);
                    Pqp_Hrtca_Integration.InsUpd_InHR_OSSPerDtls
                       (p_business_group_id => l_per_rec.business_group_id
                       ,p_person_id         => l_per_rec.person_id
                       ,p_party_id          => l_per_rec.party_id
                       ,p_effective_date    => l_per_rec.start_date
                       ,p_oss_error_code    => l_oss_error_code
                       ,p_ossDtls_warning   => l_ossDtls_warning);
                    hr_utility.set_location('Updated Extra Info' , 330);
                END IF;
                    hr_utility.set_location(' Updated Passport, Visa, Visit History' ||
                                            ' details: ', 160);
	    END IF;

	ELSIF l_chk_per.system_person_type IN ('EMP','EMP_APL') THEN

              -- If the person already exists in the system {
              hr_utility.set_location(' Current person type: ' ||
                                    l_chk_per.system_person_type, 260);
              -- Hire the existing person
              l_per_rec.party_id  := l_party_id;
              l_per_rec.person_id := p_dup_person_id;
              -- If person is to be re-hired through Data Pump
              IF (p_data_pump_flag = 'Y') THEN -- {{
                  hr_utility.set_location(' Data pump flag = Y' , 270);
                  l_add_rec.primary_flag := 'Y';
                  hr_datapump(p_data_pump_batch_line_id =>
                                                p_data_pump_batch_line_id
                             ,p_batch_id                => p_batch_id
                             ,p_contact_name            => p_contact_name
                             ,p_adjusted_svc_date       => p_adjusted_svc_date
                             ,p_dp_mode                 => 'UPDATE');
              ELSE -- }{
                   -- Else person is to be re-hired through real-time APIs
                   hr_utility.set_location(' Data pump flag <> Y' , 280);

                   hr_utility.set_location(' Updating person details ', 180);
                   Upd_OSS_Person
                   (p_validate            => FALSE
                   ,p_effective_date      => l_per_rec.start_date
                   ,p_person_id           => l_per_rec.person_id
                   ,p_adjusted_svc_date   => p_adjusted_svc_date
                   ,p_updper_api_out      => l_updper_api_out
                   );
                   hr_utility.set_location(' Updated person details ', 180);

                   -- Call the Address API only if user has eneterd the address details
                  IF (p_address_line1 IS NOT NULL AND
                      l_add_rec.style IS NOT NULL) THEN
		      hr_utility.set_location('Address line 1 is not null' , 290);
                      l_add_rec.person_id    := p_dup_person_id;
                      l_add_rec.primary_flag := 'Y';
                      l_add_rec.date_from := l_per_rec.start_date;
                      l_add_rec.date_to   := NULL;

                      InsUpd_Address(p_effective_date => l_per_rec.start_date
                                    ,p_HR_address_id  => l_add_rec.address_id
                                    ,p_HR_object_version_number =>
                                               l_add_rec.object_version_number);
                  END IF;

                  --Get the value of duplicate assignment id
		  IF (get_dup_asg_id%ISOPEN) THEN
		     CLOSE get_dup_asg_id;
		  END IF;
		  OPEN get_dup_asg_id(c_dup_per_id         => l_chk_per.person_id
		                     ,c_business_group_id  => p_business_group_id
		                     ,c_eff_date           => p_date_of_hire);
                  FETCH get_dup_asg_id
		     INTO l_dup_asg_id;
		  CLOSE get_dup_asg_id;

                  -- Update employee's primary assignment
                  l_asg_rec.assignment_id  := l_dup_asg_id;
                  hr_utility.set_location('Updating Asg criteria' , 300);
                  Update_StuEmpAsg_Criteria(p_effective_date =>
                                                l_per_rec.start_date
                                         ,p_asg_crit_out   => l_asg_crit_out);
                  hr_utility.set_location('Updated Asg criteria' , 310);

                  IF g_leg_code = 'US' THEN
                     -- Get Passport details from OSS
                     Pqp_Hrtca_Integration.InsUpd_InHR_PassPort
                     (p_business_group_id => l_per_rec.business_group_id
                     ,p_person_id         => l_per_rec.person_id
                     ,p_party_id          => l_per_rec.party_id
                     ,p_effective_date    => l_per_rec.start_date
                     ,p_pp_error_code     => l_pp_error_code
                     ,p_passport_warning  => l_passport_warning
                     );
                     -- Get Visa Details from OSS
                     Pqp_Hrtca_Integration.InsUpd_InHR_Visa
                     (p_business_group_id => l_per_rec.business_group_id
                     ,p_person_id         => l_per_rec.person_id
                     ,p_party_id          => l_per_rec.party_id
                     ,p_effective_date    => l_per_rec.start_date
                     ,p_visa_error_code   => l_visa_error_code
                     ,p_visa_warning      => l_visa_warning
                      );
                     -- Get Visit History details from OSS
                     Pqp_Hrtca_Integration.InsUpd_InHR_Visit
                     (p_business_group_id => l_per_rec.business_group_id
                     ,p_person_id         => l_per_rec.person_id
                     ,p_party_id          => l_per_rec.party_id
                     ,p_effective_date    => l_per_rec.start_date
                     ,p_visit_error_code  => l_visit_error_code
                     ,p_visit_warning     => l_visit_warning
                     );
                  END IF;
                  IF l_student_number IS NOT NULL THEN -- {
                     -- Create People Exra Information
                     hr_utility.set_location('Updating Extra Info' , 330);
                     Pqp_Hrtca_Integration.InsUpd_InHR_OSSPerDtls
                        (p_business_group_id => l_per_rec.business_group_id
                        ,p_person_id         => l_per_rec.person_id
                        ,p_party_id          => l_per_rec.party_id
                        ,p_effective_date    => l_per_rec.start_date
                        ,p_oss_error_code    => l_oss_error_code
                        ,p_ossDtls_warning   => l_ossDtls_warning);
                  END IF;

              END IF;

        END IF;

        IF (chk_party%ISOPEN) THEN -- {
            CLOSE chk_party;
        END IF; -- }

    ELSIF p_web_adi_identifier = 'DP ERROR' THEN -- }{
        -- Procedure call which handles if user is trying to correct the
        -- erronous data from Data Pump Interface Tables
        hr_datapumperr( p_data_pump_batch_line_id => p_data_pump_batch_line_id
                      , p_batch_id                => p_batch_id
                      , p_contact_name            => p_contact_name
                      , p_adjusted_svc_date       => p_adjusted_svc_date);

    END IF; -- }}
    hr_utility.set_location('Leaving: ' || l_proc_name, 350);

   EXCEPTION
     WHEN e_active_cwk THEN
       CLOSE chk_party;
       ROLLBACK TO create_student_employee;
       hr_utility.set_location('..CWK being hired as Student Employee', 360);
       hr_utility.set_message(8303, 'PQP_230216_HROSS_ACTIVE_CTW');
       hr_utility.set_location('Leaving: ' || l_proc_name, 360);
       hr_utility.raise_error;

     WHEN Others THEN
       CLOSE chk_party;
       ROLLBACK TO create_student_employee;
       hr_utility.raise_error;

END Create_Student_Employee;

-- =============================================================================
-- ~ Create_Batch_Header_For_Data_Pump:
-- =============================================================================
PROCEDURE Create_BatchHdr_For_DataPump
         (p_batch_process_name   OUT NOCOPY Varchar2
         ,p_batch_process_id     OUT NOCOPY Number) AS

  -- Cursor to get the business group name
   CURSOR csr_get_bg_name (c_bg_grp_id IN Number) IS
   SELECT pbg.NAME
     FROM per_business_groups pbg
    WHERE pbg.business_group_id = c_bg_grp_id;

   l_bg_name                per_business_groups.NAME%TYPE;
   l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||
                                           'Create_BatchHdr_For_DataPump';

BEGIN
   hr_utility.set_location('Entering: ' || l_proc_name, 10);

   SELECT hr_pump_batch_headers_s.nextval
     INTO p_batch_process_id
     FROM dual;
   p_batch_process_name := 'HROSS Batch Process ' || p_batch_process_id;

   OPEN  csr_get_bg_name(Fnd_Profile.VALUE('PER_BUSINESS_GROUP_ID'));
   FETCH csr_get_bg_name INTO l_bg_name;
   CLOSE csr_get_bg_name;

   INSERT INTO hr_pump_batch_headers
   (batch_id
   ,batch_name
   ,batch_status
   ,business_group_name)
   VALUES
   (p_batch_process_id
   ,p_batch_process_name
   ,'U'
   ,l_bg_name);

   hr_utility.set_location('Leaving: ' || l_proc_name, 20);

END Create_BatchHdr_For_DataPump;

-- =============================================================================
-- ~ Create_OSS_Person:
-- =============================================================================
PROCEDURE Create_OSS_Person
         (p_business_group_id            IN Number
         ,p_dup_person_id                IN Number
         ,p_effective_date               IN Date
         -- Person Details: Per_All_People_F
         ,p_party_id                     IN Number
         ,p_last_name                    IN Varchar2
         ,p_middle_name                  IN Varchar2
         ,p_first_name                   IN Varchar2
         ,p_suffix                       IN Varchar2
         ,p_prefix                       IN Varchar2
         ,p_title                        IN Varchar2
         ,p_email_address                IN Varchar2
         ,p_preferred_name               IN Varchar2
         ,p_marital_status               IN Varchar2
         ,p_sex                          IN Varchar2
         ,p_nationality                  IN Varchar2
         ,p_national_identifier          IN Varchar2
         ,p_date_of_birth                IN Date
         ,p_date_of_hire                 IN Date
         ,p_employee_number              IN Varchar2
         ,p_person_type_id               IN Number
         ,p_date_employee_data_verified  IN Date
         ,p_expense_check_send_to_addres IN Varchar2
         ,p_previous_last_name           IN Varchar2
         ,p_registered_disabled_flag     IN Varchar2
         ,p_vendor_id                    IN Number
         ,p_date_of_death                IN Date
         ,p_background_check_status      IN Varchar2
         ,p_background_date_check        IN Date
         ,p_blood_type                   IN Varchar2
         ,p_correspondence_language      IN Varchar2
         ,p_fast_path_employee           IN Varchar2
         ,p_fte_capacity                 IN Number
         ,p_honors                       IN Varchar2
         ,p_last_medical_test_by         IN Varchar2
         ,p_last_medical_test_date       IN Date
         ,p_mailstop                     IN Varchar2
         ,p_office_number                IN Varchar2
         ,p_on_military_service          IN Varchar2
         ,p_pre_name_adjunct             IN Varchar2
         ,p_projected_start_date         IN Date
         ,p_resume_exists                IN Varchar2
         ,p_resume_last_updated          IN Date
         ,p_second_passport_exists       IN Varchar2
         ,p_student_status               IN Varchar2
         ,p_work_schedule                IN Varchar2
         ,p_benefit_group_id             IN Number
         ,p_receipt_of_death_cert_date   IN Date
         ,p_coord_ben_med_pln_no         IN Varchar2
         ,p_coord_ben_no_cvg_flag        IN Varchar2
         ,p_coord_ben_med_ext_er         IN Varchar2
         ,p_coord_ben_med_pl_name        IN Varchar2
         ,p_coord_ben_med_insr_crr_name  IN Varchar2
         ,p_coord_ben_med_insr_crr_ident IN Varchar2
         ,p_coord_ben_med_cvg_strt_dt    IN Date
         ,p_coord_ben_med_cvg_end_dt     IN Date
         ,p_uses_tobacco_flag            IN Varchar2
         ,p_dpdnt_adoption_date          IN Date
         ,p_dpdnt_vlntry_svce_flag       IN Varchar2
         ,p_original_date_of_hire        IN Date
         ,p_adjusted_svc_date            IN Date
         ,p_town_of_birth                IN Varchar2
         ,p_region_of_birth              IN Varchar2
         ,p_country_of_birth             IN Varchar2
         ,p_global_person_id             IN Varchar2
         -- Person DF
         ,p_per_attribute_category       IN Varchar2
         ,p_per_attribute1               IN Varchar2
         ,p_per_attribute2               IN Varchar2
         ,p_per_attribute3               IN Varchar2
         ,p_per_attribute4               IN Varchar2
         ,p_per_attribute5               IN Varchar2
         ,p_per_attribute6               IN Varchar2
         ,p_per_attribute7               IN Varchar2
         ,p_per_attribute8               IN Varchar2
         ,p_per_attribute9               IN Varchar2
         ,p_per_attribute10              IN Varchar2
         ,p_per_attribute11              IN Varchar2
         ,p_per_attribute12              IN Varchar2
         ,p_per_attribute13              IN Varchar2
         ,p_per_attribute14              IN Varchar2
         ,p_per_attribute15              IN Varchar2
         ,p_per_attribute16              IN Varchar2
         ,p_per_attribute17              IN Varchar2
         ,p_per_attribute18              IN Varchar2
         ,p_per_attribute19              IN Varchar2
         ,p_per_attribute20              IN Varchar2
         ,p_per_attribute21              IN Varchar2
         ,p_per_attribute22              IN Varchar2
         ,p_per_attribute23              IN Varchar2
         ,p_per_attribute24              IN Varchar2
         ,p_per_attribute25              IN Varchar2
         ,p_per_attribute26              IN Varchar2
         ,p_per_attribute27              IN Varchar2
         ,p_per_attribute28              IN Varchar2
         ,p_per_attribute29              IN Varchar2
         ,p_per_attribute30              IN Varchar2
         -- Person DDF
         ,p_per_information_category     IN Varchar2
         ,p_per_information1             IN Varchar2
         ,p_per_information2             IN Varchar2
         ,p_per_information3             IN Varchar2
         ,p_per_information4             IN Varchar2
         ,p_per_information5             IN Varchar2
         ,p_per_information6             IN Varchar2
         ,p_per_information7             IN Varchar2
         ,p_per_information8             IN Varchar2
         ,p_per_information9             IN Varchar2
         ,p_per_information10            IN Varchar2
         ,p_per_information11            IN Varchar2
         ,p_per_information12            IN Varchar2
         ,p_per_information13            IN Varchar2
         ,p_per_information14            IN Varchar2
         ,p_per_information15            IN Varchar2
         ,p_per_information16            IN Varchar2
         ,p_per_information17            IN Varchar2
         ,p_per_information18            IN Varchar2
         ,p_per_information19            IN Varchar2
         ,p_per_information20            IN Varchar2
         ,p_per_information21            IN Varchar2
         ,p_per_information22            IN Varchar2
         ,p_per_information23            IN Varchar2
         ,p_per_information24            IN Varchar2
         ,p_per_information25            IN Varchar2
         ,p_per_information26            IN Varchar2
         ,p_per_information27            IN Varchar2
         ,p_per_information28            IN Varchar2
         ,p_per_information29            IN Varchar2
         ,p_per_information30            IN Varchar2
         -- Primary Address: Per_Addresses
         ,p_pradd_ovlapval_override      IN Varchar2
         ,p_address_type                 IN Varchar2
         ,p_adr_comments                 IN Varchar2
         ,p_primary_flag                 IN Varchar2
         ,p_address_style                IN Varchar2
         ,p_address_line1                IN Varchar2
         ,p_address_line2                IN Varchar2
         ,p_address_line3                IN Varchar2
         ,p_region1                      IN Varchar2
         ,p_region2                      IN Varchar2
         ,p_region3                      IN Varchar2
         ,p_town_or_city                 IN Varchar2
         ,p_country                      IN Varchar2
         ,p_postal_code                  IN Varchar2
         ,p_telephone_no1                IN Varchar2
         ,p_telephone_no2                IN Varchar2
         ,p_telephone_no3                IN Varchar2
         ,p_address_date_from            IN Date
         ,p_address_date_to              IN Date
         ,p_adr_attribute_category       IN Varchar2
         ,p_adr_attribute1               IN Varchar2
         ,p_adr_attribute2               IN Varchar2
         ,p_adr_attribute3               IN Varchar2
         ,p_adr_attribute4               IN Varchar2
         ,p_adr_attribute5               IN Varchar2
         ,p_adr_attribute6               IN Varchar2
         ,p_adr_attribute7               IN Varchar2
         ,p_adr_attribute8               IN Varchar2
         ,p_adr_attribute9               IN Varchar2
         ,p_adr_attribute10              IN Varchar2
         ,p_adr_attribute11              IN Varchar2
         ,p_adr_attribute12              IN Varchar2
         ,p_adr_attribute13              IN Varchar2
         ,p_adr_attribute14              IN Varchar2
         ,p_adr_attribute15              IN Varchar2
         ,p_adr_attribute16              IN Varchar2
         ,p_adr_attribute17              IN Varchar2
         ,p_adr_attribute18              IN Varchar2
         ,p_adr_attribute19              IN Varchar2
         ,p_adr_attribute20              IN Varchar2
         ,p_add_information13            IN Varchar2
         ,p_add_information14            IN Varchar2
         ,p_add_information15            IN Varchar2
         ,p_add_information16            IN Varchar2
         ,p_add_information17            IN Varchar2
         ,p_add_information18            IN Varchar2
         ,p_add_information19            IN Varchar2
         ,p_add_information20            IN Varchar2
         -- Person Phones: Per_Phones
         ,p_phone_type                   IN Varchar2
         ,p_phone_number                 IN Varchar2
         ,p_phone_date_from              IN Date
         ,p_phone_date_to                IN Date
         -- Person Contact: Per_Contact_Relationships
         ,p_contact_type                 IN Varchar2
         ,p_contact_name                 IN Varchar2
         ,p_primary_contact              IN Varchar2
         ,p_primary_relationship         IN Varchar2
         ,p_contact_date_from            IN Date
         ,p_contact_date_to              IN Date
         ,p_return_status                OUT NOCOPY Varchar2
         ,p_dup_asg_id                   IN Number
         ,p_mode_type                    IN Varchar2
        ) AS
  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Create_OSS_Person';
  l_effective_date         Date;
  l_chk_per                chk_party%ROWTYPE;
  l_dff_ctx          fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE;
  l_emp_api_out            t_hrEmpApi;
  l_updper_api_out         t_UpdEmp_Api;
  l_HireToJobapi_out       t_HrToJob_Api;
  l_crt_emp_api_out        t_CreateContact_Api;
  l_pp_error_code          Varchar2(50);
  l_passport_warning       Boolean;
  l_visa_error_code        Varchar2(50);
  l_visa_warning           Boolean;
  l_visit_error_code       Varchar2(50);
  l_visit_warning          Boolean;
  l_oss_error_code         Varchar2(50);
  l_ossDtls_warning        Boolean;
  l_error_message          Varchar2(2000);
  l_per_ptu_rec            csr_per_ptu%ROWTYPE;
  l_HireAppapi_out         t_HrApp_Api;
  l_active_cwk             Boolean;
  e_active_cwk             Exception;

BEGIN
  SAVEPOINT create_upd_person;
  g_debug_on := hr_utility.debug_enabled;

  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  IF g_debug_on THEN
     hr_utility.set_location('..p_business_group_id :' || p_business_group_id,20);
     hr_utility.set_location('..p_dup_person_id :' || p_dup_person_id,20);
     hr_utility.set_location('..p_party_id :' || p_party_id,20);
     hr_utility.set_location('..p_last_name :' || p_last_name,20);
     hr_utility.set_location('..p_marital_status :' || p_marital_status,20);
     hr_utility.set_location('..p_sex :' || p_sex,20);
     hr_utility.set_location('..p_date_of_birth :' || p_date_of_birth,20);
     hr_utility.set_location('..p_date_of_hire :' || p_date_of_hire,20);
     hr_utility.set_location('..p_employee_number :' || p_employee_number,20);
     hr_utility.set_location('..p_person_type_id :' || p_person_type_id,20);
     hr_utility.set_location('..p_effective_date :' || p_effective_date,20);
  END IF;

  l_per_rec     := NULL;
  l_hr_soft_rec := NULL;
  l_add_rec     := NULL;
  l_ppl_grp_rec := NULL;
  l_asg_rec     := NULL;

  l_effective_date := p_date_of_hire;

  -- Get Bus. Group Id in a pkg global variable
  OPEN  csr_bg_code (c_bg_grp_id => p_business_group_id);
  FETCH csr_bg_code INTO g_leg_code,g_emp_num_gen;
  CLOSE csr_bg_code;
  -- ===========================================================================
  -- ~ Person Details
  -- ===========================================================================
  l_per_rec.business_group_id             := p_business_group_id;
  l_per_rec.party_id                      := p_party_id;
  l_per_rec.last_name                     := p_last_name;
  l_per_rec.middle_names                  := p_middle_name;
  l_per_rec.first_name                    := p_first_name;
  l_per_rec.suffix                        := p_suffix;
  l_per_rec.pre_name_adjunct              := p_prefix;
  l_per_rec.title                         := p_title;
  l_per_rec.email_address                 := p_email_address;
  l_per_rec.known_as                      := p_preferred_name;
  l_per_rec.marital_status                := p_marital_status;
  l_per_rec.sex                           := p_sex;
  l_per_rec.nationality                   := p_nationality;
  l_per_rec.national_identifier           := p_national_identifier;
  l_per_rec.date_of_birth                 := p_date_of_birth;
  l_per_rec.start_date                    := p_date_of_hire;
  IF g_emp_num_gen <> 'A' THEN
    l_per_rec.employee_number := p_employee_number;
  ELSE
    l_per_rec.employee_number := Null;
  END IF;
  l_per_rec.person_type_id                := p_person_type_id;
  l_per_rec.date_employee_data_verified   := p_date_employee_data_verified;
  l_per_rec.expense_check_send_to_address := p_expense_check_send_to_addres;
  l_per_rec.previous_last_name            := p_previous_last_name;
  l_per_rec.registered_disabled_flag      := p_registered_disabled_flag;
  l_per_rec.vendor_id                     := p_vendor_id;
  l_per_rec.date_of_death                 := p_date_of_death;
  l_per_rec.background_check_status       := p_background_check_status;
  l_per_rec.background_date_check         := p_background_date_check;
  l_per_rec.blood_type                    := p_blood_type;
  l_per_rec.correspondence_language       := p_correspondence_language;
  l_per_rec.fast_path_employee            := p_fast_path_employee;
  l_per_rec.fte_capacity                  := p_fte_capacity;
  l_per_rec.honors                        := p_honors;
  l_per_rec.last_medical_test_by          := p_last_medical_test_by;
  l_per_rec.last_medical_test_date        := p_last_medical_test_date;
  l_per_rec.mailstop                      := p_mailstop;
  l_per_rec.office_number                 := p_office_number;
  l_per_rec.on_military_service           := NVL(p_on_military_service,'N');
  l_per_rec.pre_name_adjunct              := p_pre_name_adjunct;
  l_per_rec.projected_start_date          := p_projected_start_date;
  l_per_rec.resume_exists                 := NVL(p_resume_exists,'N');
  l_per_rec.resume_last_updated           := p_resume_last_updated;
  l_per_rec.second_passport_exists        := NVL(p_second_passport_exists,'N');
  l_per_rec.student_status                := p_student_status;
  l_per_rec.work_schedule                 := p_work_schedule;
  l_per_rec.benefit_group_id              := p_benefit_group_id;
  l_per_rec.receipt_of_death_cert_date    := p_receipt_of_death_cert_date;
  l_per_rec.coord_ben_med_pln_no          := p_coord_ben_med_pln_no;
  l_per_rec.coord_ben_no_cvg_flag         := NVL(p_coord_ben_no_cvg_flag,'N');
  l_per_rec.coord_ben_med_ext_er          := p_coord_ben_med_ext_er;
  l_per_rec.coord_ben_med_pl_name         := p_coord_ben_med_pl_name;
  l_per_rec.coord_ben_med_insr_crr_name   := p_coord_ben_med_insr_crr_name;
  l_per_rec.coord_ben_med_insr_crr_ident  := p_coord_ben_med_insr_crr_ident;
  l_per_rec.coord_ben_med_cvg_strt_dt     := p_coord_ben_med_cvg_strt_dt;
  l_per_rec.coord_ben_med_cvg_end_dt      := p_coord_ben_med_cvg_end_dt;
  l_per_rec.uses_tobacco_flag             := p_uses_tobacco_flag;
  l_per_rec.dpdnt_adoption_date           := p_dpdnt_adoption_date;
  l_per_rec.dpdnt_vlntry_svce_flag        := NVL(p_dpdnt_vlntry_svce_flag,'N');
  l_per_rec.original_date_of_hire         := p_original_date_of_hire;
  l_per_rec.town_of_birth                 := p_town_of_birth;
  l_per_rec.region_of_birth               := p_region_of_birth;
  l_per_rec.country_of_birth              := p_country_of_birth;
  l_per_rec.global_person_id              := p_global_person_id;

  hr_utility.set_location('Person Details assigned to record :l_per_rec ', 30);

  -- Person DF: Customer defined
  l_per_rec.attribute_category            := p_per_attribute_category;
  l_per_rec.attribute1                    := p_per_attribute1;
  l_per_rec.attribute2                    := p_per_attribute2;
  l_per_rec.attribute3                    := p_per_attribute3;
  l_per_rec.attribute4                    := p_per_attribute4;
  l_per_rec.attribute5                    := p_per_attribute5;
  l_per_rec.attribute6                    := p_per_attribute6;
  l_per_rec.attribute7                    := p_per_attribute7;
  l_per_rec.attribute8                    := p_per_attribute8;
  l_per_rec.attribute9                    := p_per_attribute9;
  l_per_rec.attribute10                   := p_per_attribute10;
  l_per_rec.attribute11                   := p_per_attribute11;
  l_per_rec.attribute12                   := p_per_attribute12;
  l_per_rec.attribute13                   := p_per_attribute13;
  l_per_rec.attribute14                   := p_per_attribute14;
  l_per_rec.attribute15                   := p_per_attribute15;
  l_per_rec.attribute16                   := p_per_attribute16;
  l_per_rec.attribute17                   := p_per_attribute17;
  l_per_rec.attribute18                   := p_per_attribute18;
  l_per_rec.attribute19                   := p_per_attribute19;
  l_per_rec.attribute20                   := p_per_attribute20;
  l_per_rec.attribute21                   := p_per_attribute21;
  l_per_rec.attribute22                   := p_per_attribute22;
  l_per_rec.attribute23                   := p_per_attribute23;
  l_per_rec.attribute24                   := p_per_attribute24;
  l_per_rec.attribute25                   := p_per_attribute25;
  l_per_rec.attribute26                   := p_per_attribute26;
  l_per_rec.attribute27                   := p_per_attribute27;
  l_per_rec.attribute28                   := p_per_attribute28;
  l_per_rec.attribute29                   := p_per_attribute29;
  l_per_rec.attribute30                   := p_per_attribute30;

  hr_utility.set_location('Person DF assigned to record :l_per_rec ', 40);

  -- Person DDF: Different for each legislation
  OPEN  csr_style (c_context_code => g_leg_code);
  FETCH csr_style INTO l_dff_ctx;
  IF csr_style%FOUND THEN
     l_per_rec.per_information_category  :=
       NVL(p_per_information_category,g_leg_code);
  END IF;
  CLOSE csr_style;
  l_per_rec.per_information1              := p_per_information1;
  l_per_rec.per_information2              := p_per_information2;
  l_per_rec.per_information3              := p_per_information3;
  l_per_rec.per_information4              := p_per_information4;
  l_per_rec.per_information5              := p_per_information5;
  l_per_rec.per_information6              := p_per_information6;
  l_per_rec.per_information7              := p_per_information7;
  l_per_rec.per_information8              := p_per_information8;
  l_per_rec.per_information9              := p_per_information9;
  l_per_rec.per_information10             := p_per_information10;
  l_per_rec.per_information11             := p_per_information11;
  l_per_rec.per_information12             := p_per_information12;
  l_per_rec.per_information13             := p_per_information13;
  l_per_rec.per_information14             := p_per_information14;
  l_per_rec.per_information15             := p_per_information15;
  l_per_rec.per_information16             := p_per_information16;
  l_per_rec.per_information17             := p_per_information17;
  l_per_rec.per_information18             := p_per_information18;
  l_per_rec.per_information19             := p_per_information19;
  l_per_rec.per_information20             := p_per_information20;
  l_per_rec.per_information21             := p_per_information21;
  l_per_rec.per_information22             := p_per_information22;
  l_per_rec.per_information23             := p_per_information23;
  l_per_rec.per_information24             := p_per_information24;
  l_per_rec.per_information25             := p_per_information25;
  l_per_rec.per_information26             := p_per_information26;
  l_per_rec.per_information27             := p_per_information27;
  l_per_rec.per_information28             := p_per_information28;
  l_per_rec.per_information29             := p_per_information29;
  l_per_rec.per_information30             := p_per_information30;

  hr_utility.set_location('Person DDF assigned to record :l_per_rec ', 50);

  -- ===========================================================================
  -- ~ Person Address Record
  -- ===========================================================================
  -- p_pradd_ovlapval_override;
  l_add_rec.business_group_id             := p_business_group_id;
  l_add_rec.party_id                      := p_party_id;
  l_add_rec.address_type                  := p_address_type;
  l_add_rec.comments                      := p_adr_comments;
  l_add_rec.primary_flag                  := NVL(p_primary_flag,'Y');
  l_add_rec.style                         := p_address_style;
  l_add_rec.address_line1                 := p_address_line1;
  l_add_rec.address_line2                 := p_address_line2;
  l_add_rec.address_line3                 := p_address_line3;
  l_add_rec.region_1                      := p_region1;
  l_add_rec.region_2                      := p_region2;
  l_add_rec.region_3                      := p_region3;
  l_add_rec.town_or_city                  := p_town_or_city;
  l_add_rec.country                       := p_country;
  l_add_rec.postal_code                   := p_postal_code;
  l_add_rec.telephone_number_1            := p_telephone_no1;
  l_add_rec.telephone_number_2            := p_telephone_no2;
  l_add_rec.telephone_number_3            := p_telephone_no3;
  l_add_rec.add_information13             := p_add_information13;
  l_add_rec.add_information14             := p_add_information14;
  l_add_rec.add_information15             := p_add_information15;
  l_add_rec.add_information16             := p_add_information16;
  l_add_rec.add_information18             := p_add_information17;
  l_add_rec.add_information18             := p_add_information18;
  l_add_rec.add_information19             := p_add_information19;
  l_add_rec.add_information20             := p_add_information20;

  hr_utility.set_location('Address DDF assigned to record, Style: ' ||
                           p_address_style, 60);

  -- Address DF
  l_add_rec.addr_attribute_category       := p_adr_attribute_category;
  l_add_rec.addr_attribute1               := p_adr_attribute1;
  l_add_rec.addr_attribute2               := p_adr_attribute2;
  l_add_rec.addr_attribute3               := p_adr_attribute3;
  l_add_rec.addr_attribute4               := p_adr_attribute4;
  l_add_rec.addr_attribute5               := p_adr_attribute5;
  l_add_rec.addr_attribute6               := p_adr_attribute6;
  l_add_rec.addr_attribute7               := p_adr_attribute7;
  l_add_rec.addr_attribute8               := p_adr_attribute8;
  l_add_rec.addr_attribute9               := p_adr_attribute9;
  l_add_rec.addr_attribute10              := p_adr_attribute10;
  l_add_rec.addr_attribute11              := p_adr_attribute11;
  l_add_rec.addr_attribute12              := p_adr_attribute12;
  l_add_rec.addr_attribute13              := p_adr_attribute13;
  l_add_rec.addr_attribute14              := p_adr_attribute14;
  l_add_rec.addr_attribute15              := p_adr_attribute15;
  l_add_rec.addr_attribute16              := p_adr_attribute16;
  l_add_rec.addr_attribute17              := p_adr_attribute17;
  l_add_rec.addr_attribute18              := p_adr_attribute18;
  l_add_rec.addr_attribute19              := p_adr_attribute19;
  l_add_rec.addr_attribute20              := p_adr_attribute20;

  hr_utility.set_location('Address DF assigned to record, Style: ' ||
                           p_address_style, 70);

  OPEN  chk_party (c_party_id       => l_per_rec.party_id
                  ,c_bg_grp_id      => l_per_rec.business_group_id
                  ,c_person_id      => p_dup_person_id
                  ,c_effective_date => l_effective_date
                   );
  FETCH chk_party INTO l_chk_per;
  IF chk_party%NOTFOUND THEN
     hr_utility.set_location(' Creating a new Student Employee', 80);
     -- Create the employee
     l_effective_date     := p_date_of_hire;
     l_per_rec.start_date := l_effective_date;

     Create_EmpIn_HRMS
     (p_validate            => FALSE
     ,p_effective_date      => l_per_rec.START_DATE
     ,p_adjusted_svc_date   => p_adjusted_svc_date
     ,p_per_comments        => NULL
     ,p_emp_api_out         => l_emp_api_out
     );

     -- Create the primary address
     l_add_rec.person_id    := l_emp_api_out.person_id;
     l_add_rec.primary_flag := 'Y';
     hr_utility.set_location(' Creating Primary Address', 90);
     -- Call the Address API only if user has eneterd the address details
     IF p_address_line1 IS NOT NULL AND
        l_add_rec.style IS NOT NULL THEN

       l_add_rec.date_from  := l_effective_date;
       l_add_rec.date_to    := p_address_date_to;

       InsUpd_Address
       (p_effective_date           => l_effective_date
       ,p_HR_address_id            => l_add_rec.address_id
       ,p_HR_object_version_number => l_add_rec.object_version_number
       );
     END IF;

     -- Create Phones record default to H1=Home
     hr_utility.set_location(' Creating Phones record', 100);
     l_phones_rec.parent_id  := l_emp_api_out.person_id;
     l_phones_rec.date_from  := l_effective_date;

     -- Create Contact Details
     l_cntct_rec.person_id   := l_emp_api_out.person_id;
     hr_utility.set_location(' Creating Contact details', 110);

     -- Create Contact Type only when Contact Details have been entered
     IF l_cntct_rec.contact_type IS NOT NULL THEN
        Create_Person_Contact
        (p_effective_date   => l_effective_date
        ,p_contact_name     => p_contact_name
        ,p_legislation_code => g_leg_code
        ,p_crt_cntct_out    => l_crt_emp_api_out
        );
     END IF;
     IF g_leg_code = 'US' THEN
       -- Get Passport details from OSS
       Pqp_Hrtca_Integration.InsUpd_InHR_PassPort
       (p_business_group_id => p_business_group_id
       ,p_person_id         => l_per_rec.person_id
       ,p_party_id          => p_party_id
       ,p_effective_date    => l_effective_date
       ,p_pp_error_code     => l_pp_error_code
       ,p_passport_warning  => l_passport_warning
        );
       -- Get Visa Details from OSS
       Pqp_Hrtca_Integration.InsUpd_InHR_Visa
       (p_business_group_id => p_business_group_id
       ,p_person_id         => l_per_rec.person_id
       ,p_party_id          => p_party_id
       ,p_effective_date    => l_effective_date
       ,p_visa_error_code   => l_visa_error_code
       ,p_visa_warning      => l_visa_warning
        );
       -- Get Visit History details from OSS
       Pqp_Hrtca_Integration.InsUpd_InHR_Visit
       (p_business_group_id => p_business_group_id
       ,p_person_id         => l_per_rec.person_id
       ,p_party_id          => p_party_id
       ,p_effective_date    => l_effective_date
       ,p_visit_error_code  => l_visit_error_code
       ,p_visit_warning     => l_visit_warning
       );
     END IF;
     -- Create the Person EIT to specify the person as an
     -- OSS Person along with the Person number, party id.
     Pqp_Hrtca_Integration.InsUpd_InHR_OSSPerDtls
     (p_business_group_id => p_business_group_id
     ,p_person_id         => l_per_rec.person_id
     ,p_party_id          => p_party_id
     ,p_effective_date    => l_effective_date
     ,p_oss_error_code    => l_oss_error_code
     ,p_ossDtls_warning   => l_ossDtls_warning
      );

  ELSIF l_chk_per.system_person_type IN
         ('OTHER','EX_EMP','EX_APL') THEN

     hr_utility.set_location(' Current person type: ' ||
                              l_chk_per.system_person_type, 120);
     -- Hire the existing person
     l_per_rec.person_id  := l_chk_per.person_id;
     l_per_rec.business_group_id := p_business_group_id;
     l_per_rec.party_id   := p_party_id;
     l_effective_date     := p_date_of_hire;
     l_per_rec.start_date := l_effective_date;

     IF l_chk_per.system_person_type ='OTHER' THEN
        FOR ptu_rec IN  csr_per_ptu
                        (c_person_id         => l_chk_per.person_id
                        ,c_business_group_id => p_business_group_id
                        ,c_effective_date    => l_effective_date)
        LOOP
           IF ptu_rec.system_person_type = 'CWK' THEN
              l_active_cwk := TRUE;
              EXIT;
           END IF;
        END LOOP;
     END IF;

     IF l_active_cwk THEN
        RAISE e_active_cwk;
     END IF;

     -- Hire the Contact, Ex-Employee, Ex-Applicant or Ex-Contingent Worker
     Hire_Person_IntoEmp
     (p_validate            => FALSE
     ,p_hire_date           => l_per_rec.start_date
     ,p_person_id           => p_dup_person_id
     ,p_adjusted_svc_date   => p_adjusted_svc_date
     ,p_updper_api_out      => l_updper_api_out
     ,p_HireToJobapi_out    => l_HireToJobapi_out
      );
     -- Create the primary address
     l_add_rec.person_id    := p_dup_person_id;
     l_add_rec.primary_flag := 'Y';

     -- Call the Address API only if user has eneterd the address details
     IF p_address_line1 IS NOT NULL AND
        l_add_rec.style IS NOT NULL THEN
       l_add_rec.date_from  := l_effective_date;
       l_add_rec.date_to    := p_address_date_to;

       InsUpd_Address
       (p_effective_date           => l_effective_date
       ,p_HR_address_id            => l_add_rec.address_id
       ,p_HR_object_version_number => l_add_rec.object_version_number
       );
     END IF;

     -- Create Contact Details
     l_cntct_rec.person_id   := l_emp_api_out.person_id;

     -- Create Contact Type only when Contact Details have been entered
     IF l_cntct_rec.contact_type IS NOT NULL THEN
       Create_Person_Contact
        (p_effective_date   => l_effective_date
        ,p_contact_name     => p_contact_name
        ,p_legislation_code => g_leg_code
        ,p_crt_cntct_out    => l_crt_emp_api_out
        );
     END IF;
     IF g_leg_code = 'US' THEN
        -- Get Passport details from OSS
        Pqp_Hrtca_Integration.InsUpd_InHR_PassPort
        (p_business_group_id => p_business_group_id
        ,p_person_id         => l_per_rec.person_id
        ,p_party_id          => p_party_id
        ,p_effective_date    => l_effective_date
        ,p_pp_error_code     => l_pp_error_code
        ,p_passport_warning  => l_passport_warning
         );
        -- Get Visa Details from OSS
        Pqp_Hrtca_Integration.InsUpd_InHR_Visa
        (p_business_group_id => p_business_group_id
        ,p_person_id         => l_per_rec.person_id
        ,p_party_id          => p_party_id
        ,p_effective_date    => l_effective_date
        ,p_visa_error_code   => l_visa_error_code
        ,p_visa_warning      => l_visa_warning
         );
        -- Get Visit History details from OSS
        Pqp_Hrtca_Integration.InsUpd_InHR_Visit
        (p_business_group_id => p_business_group_id
        ,p_person_id         => l_per_rec.person_id
        ,p_party_id          => p_party_id
        ,p_effective_date    => l_effective_date
        ,p_visit_error_code  => l_visit_error_code
        ,p_visit_warning     => l_visit_warning
        );
     END IF;
     -- Create the Person EIT to specify the person as an
     -- OSS Person along with the Person number, party id.
     Pqp_Hrtca_Integration.InsUpd_InHR_OSSPerDtls
     (p_business_group_id => p_business_group_id
     ,p_person_id         => l_per_rec.person_id
     ,p_party_id          => p_party_id
     ,p_effective_date    => l_effective_date
     ,p_oss_error_code    => l_oss_error_code
     ,p_ossDtls_warning   => l_ossDtls_warning
      );


  ELSIF l_chk_per.system_person_type IN
        ('EX_EMP_APL','APL_EX_APL','APL') THEN
     hr_utility.set_location(' Current person type: ' ||
                              l_chk_per.system_person_type, 130);
     hr_utility.set_location('..Applicant being hired as Student' ||
                             ' Employee', 130);

     l_per_rec.person_id         := l_chk_per.person_id;
     l_per_rec.business_group_id := p_business_group_id;
     l_per_rec.party_id          := p_party_id;
     l_effective_date            := p_date_of_hire;
     l_per_rec.start_date        := l_effective_date;
     -- Hire the Applicant Assignment
     IF NVL(p_dup_asg_id,0) <> 0 then
        Hire_Applicant_IntoEmp
        (p_validate           => FALSE
        ,p_hire_date          => l_effective_date
        ,p_person_id          => l_chk_per.person_id
        ,p_assignment_id      => p_dup_asg_id
        ,p_adjusted_svc_date  => p_adjusted_svc_date
        ,p_updper_api_out     => l_updper_api_out
        ,p_HireAppapi_out     => l_HireAppapi_out);
	--passed the value of person to add_rec
	--Bug 5447808
        l_add_rec.person_id    := l_chk_per.person_id;
	--
     ELSE
         Create_EmpIn_HRMS
         (p_validate            => FALSE
         ,p_effective_date      => l_per_rec.START_DATE
         ,p_adjusted_svc_date   => p_adjusted_svc_date
         ,p_per_comments        => NULL
         ,p_emp_api_out         => l_emp_api_out
         );
         l_add_rec.person_id    := l_emp_api_out.person_id;
         l_per_rec.person_id    := l_emp_api_out.person_id;
         l_cntct_rec.person_id  := l_emp_api_out.person_id;
         l_phones_rec.parent_id  := l_emp_api_out.person_id;
     END IF;
     -- Create Contact Type only when Contact Details have been entered
     IF l_cntct_rec.contact_type IS NOT NULL THEN
       Create_Person_Contact
        (p_effective_date   => l_effective_date
        ,p_contact_name     => p_contact_name
        ,p_legislation_code => g_leg_code
        ,p_crt_cntct_out    => l_crt_emp_api_out
        );
     END IF;
     hr_utility.set_location(' Updated person details ', 140);
     -- Call the Address API only if user has eneterd the address details
     IF p_address_line1 IS NOT NULL AND

       l_add_rec.style IS NOT NULL THEN
       --Moved to  NVL(p_dup_asg_id,0) <> 0 block
      -- l_add_rec.person_id := l_per_rec.person_id;
       l_add_rec.business_group_id := l_per_rec.business_group_id;
       l_add_rec.primary_flag := 'Y';

       l_add_rec.date_from  := l_effective_date;
       l_add_rec.date_to    := NULL;

       hr_utility.set_location(' Updating Person Primary Address ', 150);
       InsUpd_Address
       (p_effective_date           => l_effective_date
       ,p_HR_address_id            => l_add_rec.address_id
       ,p_HR_object_version_number => l_add_rec.object_version_number
       );
     END IF;

     IF g_leg_code = 'US' THEN
        -- Get Passport details from OSS
        Pqp_Hrtca_Integration.InsUpd_InHR_PassPort
        (p_business_group_id => p_business_group_id
        ,p_person_id         => l_per_rec.person_id
        ,p_party_id          => p_party_id
        ,p_effective_date    => l_effective_date
        ,p_pp_error_code     => l_pp_error_code
        ,p_passport_warning  => l_passport_warning
         );
        -- Get Visa Details from OSS
        Pqp_Hrtca_Integration.InsUpd_InHR_Visa
        (p_business_group_id => p_business_group_id
        ,p_person_id         => l_per_rec.person_id
        ,p_party_id          => p_party_id
        ,p_effective_date    => l_effective_date
        ,p_visa_error_code   => l_visa_error_code
        ,p_visa_warning      => l_visa_warning
         );
        -- Get Visit History details from OSS
        Pqp_Hrtca_Integration.InsUpd_InHR_Visit
        (p_business_group_id => p_business_group_id
        ,p_person_id         => l_per_rec.person_id
        ,p_party_id          => p_party_id
        ,p_effective_date    => l_effective_date
        ,p_visit_error_code  => l_visit_error_code
        ,p_visit_warning     => l_visit_warning
        );
     END IF;

     -- Create the Person EIT to specify the person as an
     -- OSS Person along with the Person number, party id.
     Pqp_Hrtca_Integration.InsUpd_InHR_OSSPerDtls
     (p_business_group_id => p_business_group_id
     ,p_person_id         => l_per_rec.person_id
     ,p_party_id          => p_party_id
     ,p_effective_date    => l_effective_date
     ,p_oss_error_code    => l_oss_error_code
     ,p_ossDtls_warning   => l_ossDtls_warning
      );

     hr_utility.set_location(' Updated Passport, Visa, Visit History' ||
                             ' details: ', 160);

  ELSIF l_chk_per.system_person_type IN ('EMP','EMP_APL') THEN

     hr_utility.set_location(' Current person type: ' ||
                               l_chk_per.system_person_type, 170);

     l_per_rec.person_id := l_chk_per.person_id;
     l_per_rec.business_group_id := p_business_group_id;
     l_per_rec.party_id  := p_party_id;
     l_effective_date    := p_effective_date;

     Upd_OSS_Person
     (p_validate            => FALSE
     ,p_effective_date      => l_effective_date
     ,p_person_id           => l_per_rec.person_id
     ,p_adjusted_svc_date   => p_adjusted_svc_date
     ,p_updper_api_out      => l_updper_api_out
      );

     hr_utility.set_location(' Updated person details ', 180);

     -- Call the Address API only if user has eneterd the address details
     IF p_address_line1 IS NOT NULL AND

       l_add_rec.style IS NOT NULL THEN
       l_add_rec.person_id := l_per_rec.person_id;
       l_add_rec.business_group_id := l_per_rec.business_group_id;
       l_add_rec.primary_flag := 'Y';

       l_add_rec.date_from  := l_effective_date;
       l_add_rec.date_to    := NULL;

       hr_utility.set_location(' Updating Person Primary Address ', 190);
       InsUpd_Address
       (p_effective_date           => l_effective_date
       ,p_HR_address_id            => l_add_rec.address_id
       ,p_HR_object_version_number => l_add_rec.object_version_number
       );

     END IF;

     IF g_leg_code = 'US'       AND
        p_mode_type <> 'UPDATE' THEN
        -- Get Passport details from OSS
        Pqp_Hrtca_Integration.InsUpd_InHR_PassPort
        (p_business_group_id => p_business_group_id
        ,p_person_id         => l_per_rec.person_id
        ,p_party_id          => p_party_id
        ,p_effective_date    => l_effective_date
        ,p_pp_error_code     => l_pp_error_code
        ,p_passport_warning  => l_passport_warning
         );
        -- Get Visa Details from OSS
        Pqp_Hrtca_Integration.InsUpd_InHR_Visa
        (p_business_group_id => p_business_group_id
        ,p_person_id         => l_per_rec.person_id
        ,p_party_id          => p_party_id
        ,p_effective_date    => l_effective_date
        ,p_visa_error_code   => l_visa_error_code
        ,p_visa_warning      => l_visa_warning
         );
        -- Get Visit History details from OSS
        Pqp_Hrtca_Integration.InsUpd_InHR_Visit
        (p_business_group_id => p_business_group_id
        ,p_person_id         => l_per_rec.person_id
        ,p_party_id          => p_party_id
        ,p_effective_date    => l_effective_date
        ,p_visit_error_code  => l_visit_error_code
        ,p_visit_warning     => l_visit_warning
        );

        -- Create the Person EIT to specify the person as an
        -- OSS Person along with the Person number, party id.
        Pqp_Hrtca_Integration.InsUpd_InHR_OSSPerDtls
        (p_business_group_id => p_business_group_id
        ,p_person_id         => l_per_rec.person_id
        ,p_party_id          => p_party_id
        ,p_effective_date    => l_effective_date
        ,p_oss_error_code    => l_oss_error_code
        ,p_ossDtls_warning   => l_ossDtls_warning
        );
     END IF;

     hr_utility.set_location(' Updated Passport, Visa, Visit History' ||
                             ' details: ', 200);

  END IF;
  CLOSE chk_party;

  hr_utility.set_location('Leaving: ' || l_proc_name, 210);

EXCEPTION
   WHEN e_active_cwk THEN
    CLOSE chk_party;
    ROLLBACK TO create_upd_person;
    l_error_message := 'Active Contingent Worker cannot be hired as a ' ||
                        'Student Employee';
    l_error_message:= l_per_rec.first_name ||' '||l_per_rec.last_name ||': '||
                      l_error_message;
    l_error_message := Replace(l_error_message,'ORA-20001:',' ');
    hr_utility.set_location('..CWK being hired as Student Employee', 220);
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',l_error_message );
    hr_utility.set_location('Leaving: ' || l_proc_name, 220);
    hr_utility.raise_error;

   WHEN Others THEN
    CLOSE chk_party;
    ROLLBACK TO create_upd_person;
    hr_utility.set_location('SQLCODE :' || SQLCODE, 230);
    l_error_message := SQLERRM;
    l_error_message:= l_per_rec.first_name ||' '||l_per_rec.last_name|| ': '||
                      l_error_message;
    l_error_message := Replace(l_error_message,'ORA-20001:',' ');
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',l_error_message );
    hr_utility.set_location('Leaving: ' || l_proc_name, 230);
    hr_utility.raise_error;

END Create_OSS_Person;

-- =============================================================================
-- ~ Upd_OSS_Person_Asg:
-- =============================================================================
PROCEDURE Upd_OSS_Person_Asg
          (p_effective_date               IN     Date
          ,p_datetrack_update_mode        IN     Varchar2
          ,p_assignment_id                IN     Number
          ,p_party_id                     IN     Number
          ,p_business_group_id            IN     Number
          ,p_valiDate                     IN     Boolean
          ,p_called_from_mass_upDate      IN     Boolean
          --
          ,p_grade_id                     IN     Number
          ,p_position_id                  IN     Number
          ,p_job_id                       IN     Number
          ,p_payroll_id                   IN     Number
          ,p_location_id                  IN     Number
          ,p_organization_id              IN     Number
          ,p_pay_basis_id                 IN     Number
          ,p_employment_category          IN     Varchar2
          ,p_assignment_category          IN     Varchar2
          --
          ,p_supervisor_id                IN     Number
          ,p_assignment_number            IN     Varchar2
          ,p_change_reason                IN     Varchar2
          ,p_assignment_status_type_id    IN     Number
          ,p_comments                     IN     Varchar2
          ,p_Date_probation_end           IN     Date
          ,p_default_code_comb_id         IN     Number
          ,p_frequency                    IN     Varchar2
          ,p_internal_address_line        IN     Varchar2
          ,p_manager_flag                 IN     Varchar2
          ,p_normal_hours                 IN     Number
          ,p_perf_review_period           IN     Number
          ,p_perf_review_period_frequency IN     Varchar2
          ,p_probation_period             IN     Number
          ,p_probation_unit               IN     Varchar2
          ,p_sal_review_period            IN     Number
          ,p_sal_review_period_frequency  IN     Varchar2
          ,p_set_of_books_id              IN     Number
          ,p_source_type                  IN     Varchar2
          ,p_time_normal_finish           IN     Varchar2
          ,p_time_normal_start            IN     Varchar2
          ,p_bargaining_unit_code         IN     Varchar2
          ,p_labour_union_member_flag     IN     Varchar2
          ,p_hourly_salaried_code         IN     Varchar2
          ,p_title                        IN     Varchar2
          ,p_notice_period                IN     Number
          ,p_notice_period_uom            IN     Varchar2
          ,p_employee_category            IN     Varchar2
          ,p_work_at_home                 IN     Varchar2
          ,p_job_post_source_name         IN     Varchar2
          ,p_supervisor_assignment_id     IN     Number
          --People Group Keyflex Field
          ,p_people_group_id              IN     Number
          ,p_pgrp_segment1                IN     Varchar2
          ,p_pgrp_segment2                IN     Varchar2
          ,p_pgrp_segment3                IN     Varchar2
          ,p_pgrp_segment4                IN     Varchar2
          ,p_pgrp_segment5                IN     Varchar2
          ,p_pgrp_segment6                IN     Varchar2
          ,p_pgrp_segment7                IN     Varchar2
          ,p_pgrp_segment8                IN     Varchar2
          ,p_pgrp_segment9                IN     Varchar2
          ,p_pgrp_segment10               IN     Varchar2
          ,p_pgrp_segment11               IN     Varchar2
          ,p_pgrp_segment12               IN     Varchar2
          ,p_pgrp_segment13               IN     Varchar2
          ,p_pgrp_segment14               IN     Varchar2
          ,p_pgrp_segment15               IN     Varchar2
          ,p_pgrp_segment16               IN     Varchar2
          ,p_pgrp_segment17               IN     Varchar2
          ,p_pgrp_segment18               IN     Varchar2
          ,p_pgrp_segment19               IN     Varchar2
          ,p_pgrp_segment20               IN     Varchar2
          ,p_pgrp_segment21               IN     Varchar2
          ,p_pgrp_segment22               IN     Varchar2
          ,p_pgrp_segment23               IN     Varchar2
          ,p_pgrp_segment24               IN     Varchar2
          ,p_pgrp_segment25               IN     Varchar2
          ,p_pgrp_segment26               IN     Varchar2
          ,p_pgrp_segment27               IN     Varchar2
          ,p_pgrp_segment28               IN     Varchar2
          ,p_pgrp_segment29               IN     Varchar2
          ,p_pgrp_segment30               IN     Varchar2
          ,p_pgrp_concat_segments         IN     Varchar2
          --Soft Coding KeyflexId
          ,p_soft_coding_keyflex_id       IN     Number
          ,p_soft_concat_segments         IN     Varchar2
          ,p_scl_segment1                 IN     Varchar2
          ,p_scl_segment2                 IN     Varchar2
          ,p_scl_segment3                 IN     Varchar2
          ,p_scl_segment4                 IN     Varchar2
          ,p_scl_segment5                 IN     Varchar2
          ,p_scl_segment6                 IN     Varchar2
          ,p_scl_segment7                 IN     Varchar2
          ,p_scl_segment8                 IN     Varchar2
          ,p_scl_segment9                 IN     Varchar2
          ,p_scl_segment10                IN     Varchar2
          ,p_scl_segment11                IN     Varchar2
          ,p_scl_segment12                IN     Varchar2
          ,p_scl_segment13                IN     Varchar2
          ,p_scl_segment14                IN     Varchar2
          ,p_scl_segment15                IN     Varchar2
          ,p_scl_segment16                IN     Varchar2
          ,p_scl_segment17                IN     Varchar2
          ,p_scl_segment18                IN     Varchar2
          ,p_scl_segment19                IN     Varchar2
          ,p_scl_segment20                IN     Varchar2
          ,p_scl_segment21                IN     Varchar2
          ,p_scl_segment22                IN     Varchar2
          ,p_scl_segment23                IN     Varchar2
          ,p_scl_segment24                IN     Varchar2
          ,p_scl_segment25                IN     Varchar2
          ,p_scl_segment26                IN     Varchar2
          ,p_scl_segment27                IN     Varchar2
          ,p_scl_segment28                IN     Varchar2
          ,p_scl_segment29                IN     Varchar2
          ,p_scl_segment30                IN     Varchar2
          -- Assignment DF Information
          ,p_ass_attribute_category       IN     Varchar2
          ,p_ass_attribute1               IN     Varchar2
          ,p_ass_attribute2               IN     Varchar2
          ,p_ass_attribute3               IN     Varchar2
          ,p_ass_attribute4               IN     Varchar2
          ,p_ass_attribute5               IN     Varchar2
          ,p_ass_attribute6               IN     Varchar2
          ,p_ass_attribute7               IN     Varchar2
          ,p_ass_attribute8               IN     Varchar2
          ,p_ass_attribute9               IN     Varchar2
          ,p_ass_attribute10              IN     Varchar2
          ,p_ass_attribute11              IN     Varchar2
          ,p_ass_attribute12              IN     Varchar2
          ,p_ass_attribute13              IN     Varchar2
          ,p_ass_attribute14              IN     Varchar2
          ,p_ass_attribute15              IN     Varchar2
          ,p_ass_attribute16              IN     Varchar2
          ,p_ass_attribute17              IN     Varchar2
          ,p_ass_attribute18              IN     Varchar2
          ,p_ass_attribute19              IN     Varchar2
          ,p_ass_attribute20              IN     Varchar2
          ,p_ass_attribute21              IN     Varchar2
          ,p_ass_attribute22              IN     Varchar2
          ,p_ass_attribute23              IN     Varchar2
          ,p_ass_attribute24              IN     Varchar2
          ,p_ass_attribute25              IN     Varchar2
          ,p_ass_attribute26              IN     Varchar2
          ,p_ass_attribute27              IN     Varchar2
          ,p_ass_attribute28              IN     Varchar2
          ,p_ass_attribute29              IN     Varchar2
          ,p_ass_attribute30              IN     Varchar2
          --
          ,p_grade_ladder_pgm_id          IN     Number
          ,p_special_ceiling_step_id      IN     Number
          ,p_cagr_grade_def_id            IN     Number
          ,p_contract_id                  IN     Number
          ,p_establishment_id             IN     Number
          ,p_collective_agreement_id      IN     Number
          ,p_cagr_id_flex_num             IN     Number
          ,p_cag_segment1                 IN     Varchar2
          ,p_cag_segment2                 IN     Varchar2
          ,p_cag_segment3                 IN     Varchar2
          ,p_cag_segment4                 IN     Varchar2
          ,p_cag_segment5                 IN     Varchar2
          ,p_cag_segment6                 IN     Varchar2
          ,p_cag_segment7                 IN     Varchar2
          ,p_cag_segment8                 IN     Varchar2
          ,p_cag_segment9                 IN     Varchar2
          ,p_cag_segment10                IN     Varchar2
          ,p_cag_segment11                IN     Varchar2
          ,p_cag_segment12                IN     Varchar2
          ,p_cag_segment13                IN     Varchar2
          ,p_cag_segment14                IN     Varchar2
          ,p_cag_segment15                IN     Varchar2
          ,p_cag_segment16                IN     Varchar2
          ,p_cag_segment17                IN     Varchar2
          ,p_cag_segment18                IN     Varchar2
          ,p_cag_segment19                IN     Varchar2
          ,p_cag_segment20                IN     Varchar2
          ,p_return_status                OUT NOCOPY Varchar2
          ,p_FICA_exempt                  IN     Varchar2
          ) AS
  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'Upd_OSS_Person_Asg';
  l_asg_crit_out           t_AsgUpdCrit_Api;
  l_error_msg              Varchar2(2000);
  l_FICA_exempt            Varchar2(5);
BEGIN
  g_debug_on := hr_utility.debug_enabled;
  hr_utility.set_location('Entering: ' || l_proc_name,10);
  -- Get Bus. Group Id in a pkg global variable
  OPEN  csr_bg_code (c_bg_grp_id => p_business_group_id);
  FETCH csr_bg_code INTO g_leg_code,g_emp_num_gen;
  CLOSE csr_bg_code;
  IF p_FICA_exempt Is NULL THEN
     l_FICA_exempt := 'N';
  ELSE
     l_FICA_exempt := p_FICA_exempt;
  END IF;
  IF g_debug_on THEN
    hr_utility.set_location('..p_business_group_id :' || p_business_group_id, 20);
    hr_utility.set_location('..p_assignment_id     :' || p_assignment_id ,20);
    hr_utility.set_location('..p_organization_id   :' || p_organization_id ,20);
    hr_utility.set_location('..p_job_id            :' || p_job_id ,20);
    hr_utility.set_location('..p_pay_basis_id      :' || p_pay_basis_id ,20);
    hr_utility.set_location('..p_grade_id          :' || p_grade_id ,20);
    hr_utility.set_location('..p_position_id       :' || p_position_id ,20);
    hr_utility.set_location('..p_payroll_id        :' || p_payroll_id ,20);
    hr_utility.set_location('..p_effective_date    :' || p_effective_date ,20);
  END IF;

  -- ===========================================================================
  -- ~ Person Primary Assignment
  -- ===========================================================================
  l_asg_rec.business_group_id             := p_business_group_id;
  l_asg_rec.assignment_id                 := p_assignment_id;
  l_asg_rec.organization_id               := p_organization_id;
  l_asg_rec.job_id                        := p_job_id;
  l_asg_rec.grade_id                      := p_grade_id;
  l_asg_rec.position_id                   := p_position_id;
  l_asg_rec.payroll_id                    := p_payroll_id;
  l_asg_rec.assignment_status_type_id     := p_assignment_status_type_id;
  l_asg_rec.assignment_number             := p_assignment_number;

  l_asg_rec.assignment_category           := p_assignment_category;
  l_asg_rec.employment_category           := p_employment_category;
  l_asg_rec.employee_category             := p_employee_category;

  l_asg_rec.collective_agreement_id       := p_collective_agreement_id;
  l_asg_rec.pay_basis_id                  := p_pay_basis_id;
  l_asg_rec.supervisor_id                 := p_supervisor_id;
  l_asg_rec.change_reason                 := p_change_reason;
  l_asg_rec.date_probation_end            := p_date_probation_end;
  l_asg_rec.default_code_comb_id          := p_default_code_comb_id;
  l_asg_rec.frequency                     := p_frequency;
  l_asg_rec.internal_address_line         := p_internal_address_line;
  l_asg_rec.manager_flag                  := p_manager_flag;
  l_asg_rec.normal_hours                  := p_normal_hours;
  l_asg_rec.perf_review_period            := p_perf_review_period;
  l_asg_rec.perf_review_period_frequency  := p_perf_review_period_frequency;
  l_asg_rec.probation_period              := p_probation_period;
  l_asg_rec.probation_unit                := p_probation_unit;
  l_asg_rec.sal_review_period             := p_sal_review_period;
  l_asg_rec.sal_review_period_frequency   := p_sal_review_period_frequency;
  l_asg_rec.set_of_books_id               := p_set_of_books_id;
  l_asg_rec.source_type                   := p_source_type;
  l_asg_rec.time_normal_finish            := p_time_normal_finish;
  l_asg_rec.time_normal_start             := p_time_normal_start;
  l_asg_rec.bargaining_unit_code          := p_bargaining_unit_code;
  l_asg_rec.labour_union_member_flag      := p_labour_union_member_flag;
  l_asg_rec.hourly_salaried_code          := p_hourly_salaried_code;
  l_asg_rec.location_id                   := p_location_id;

  hr_utility.set_location('Person Primary Assignment segments assigned to ' ||
                          'record: l_asg_rec ', 30);
  -- Additional Assignment Details
  l_asg_rec.ass_attribute_category        := p_ass_attribute_category;
  l_asg_rec.ass_attribute1                := p_ass_attribute1;
  l_asg_rec.ass_attribute2                := p_ass_attribute2;
  l_asg_rec.ass_attribute3                := p_ass_attribute3;
  l_asg_rec.ass_attribute4                := p_ass_attribute4;
  l_asg_rec.ass_attribute5                := p_ass_attribute5;
  l_asg_rec.ass_attribute6                := p_ass_attribute6;
  l_asg_rec.ass_attribute7                := p_ass_attribute7;
  l_asg_rec.ass_attribute8                := p_ass_attribute8;
  l_asg_rec.ass_attribute9                := p_ass_attribute9;
  l_asg_rec.ass_attribute10               := p_ass_attribute10;
  l_asg_rec.ass_attribute11               := p_ass_attribute11;
  l_asg_rec.ass_attribute12               := p_ass_attribute12;
  l_asg_rec.ass_attribute13               := p_ass_attribute13;
  l_asg_rec.ass_attribute14               := p_ass_attribute14;
  l_asg_rec.ass_attribute15               := p_ass_attribute15;
  l_asg_rec.ass_attribute16               := p_ass_attribute16;
  l_asg_rec.ass_attribute17               := p_ass_attribute17;
  l_asg_rec.ass_attribute18               := p_ass_attribute18;
  l_asg_rec.ass_attribute19               := p_ass_attribute19;
  l_asg_rec.ass_attribute20               := p_ass_attribute20;
  l_asg_rec.ass_attribute21               := p_ass_attribute21;
  l_asg_rec.ass_attribute22               := p_ass_attribute22;
  l_asg_rec.ass_attribute23               := p_ass_attribute23;
  l_asg_rec.ass_attribute24               := p_ass_attribute24;
  l_asg_rec.ass_attribute25               := p_ass_attribute25;
  l_asg_rec.ass_attribute26               := p_ass_attribute26;
  l_asg_rec.ass_attribute27               := p_ass_attribute27;
  l_asg_rec.ass_attribute28               := p_ass_attribute28;
  l_asg_rec.ass_attribute29               := p_ass_attribute29;
  l_asg_rec.ass_attribute30               := p_ass_attribute30;

  hr_utility.set_location('Additional Assignment Details assigned to ' ||
                          'record: l_asg_rec ', 40);

  -- ===========================================================================
  -- ~ Soft Coding Keyflex field
  -- ===========================================================================
  l_asg_rec.soft_coding_keyflex_id        := p_soft_coding_keyflex_id;
  l_hr_soft_rec.concatenated_segments     := p_soft_concat_segments;
  l_hr_soft_rec.segment1                  := p_scl_segment1;
  l_hr_soft_rec.segment2                  := p_scl_segment2;
  l_hr_soft_rec.segment3                  := p_scl_segment3;
  l_hr_soft_rec.segment4                  := p_scl_segment4;
  l_hr_soft_rec.segment5                  := p_scl_segment5;
  l_hr_soft_rec.segment6                  := p_scl_segment6;
  l_hr_soft_rec.segment7                  := p_scl_segment7;
  l_hr_soft_rec.segment8                  := p_scl_segment8;
  l_hr_soft_rec.segment9                  := p_scl_segment9;
  l_hr_soft_rec.segment10                 := p_scl_segment10;
  l_hr_soft_rec.segment11                 := p_scl_segment11;
  l_hr_soft_rec.segment12                 := p_scl_segment12;
  l_hr_soft_rec.segment13                 := p_scl_segment13;
  l_hr_soft_rec.segment14                 := p_scl_segment14;
  l_hr_soft_rec.segment15                 := p_scl_segment15;
  l_hr_soft_rec.segment16                 := p_scl_segment16;
  l_hr_soft_rec.segment17                 := p_scl_segment17;
  l_hr_soft_rec.segment18                 := p_scl_segment18;
  l_hr_soft_rec.segment19                 := p_scl_segment19;
  l_hr_soft_rec.segment20                 := p_scl_segment20;
  l_hr_soft_rec.segment21                 := p_scl_segment21;
  l_hr_soft_rec.segment22                 := p_scl_segment22;
  l_hr_soft_rec.segment23                 := p_scl_segment23;
  l_hr_soft_rec.segment24                 := p_scl_segment24;
  l_hr_soft_rec.segment25                 := p_scl_segment25;
  l_hr_soft_rec.segment26                 := p_scl_segment26;
  l_hr_soft_rec.segment27                 := p_scl_segment27;
  l_hr_soft_rec.segment28                 := p_scl_segment28;
  l_hr_soft_rec.segment29                 := p_scl_segment29;
  l_hr_soft_rec.segment30                 := p_scl_segment30;

  hr_utility.set_location('Soft Coding KFF segments assigned to record: ' ||
                          'l_hr_soft_rec ', 50);

  -- ===========================================================================
  -- ~ People Group Keyflex
  -- ===========================================================================
  l_asg_rec.people_group_id              := p_people_group_id;
  l_ppl_grp_rec.group_name               := p_pgrp_concat_segments;
  l_ppl_grp_rec.segment1                 := p_pgrp_segment1;
  l_ppl_grp_rec.segment2                 := p_pgrp_segment2;
  l_ppl_grp_rec.segment3                 := p_pgrp_segment3;
  l_ppl_grp_rec.segment4                 := p_pgrp_segment4;
  l_ppl_grp_rec.segment5                 := p_pgrp_segment5;
  l_ppl_grp_rec.segment6                 := p_pgrp_segment6;
  l_ppl_grp_rec.segment7                 := p_pgrp_segment7;
  l_ppl_grp_rec.segment8                 := p_pgrp_segment8;
  l_ppl_grp_rec.segment9                 := p_pgrp_segment9;
  l_ppl_grp_rec.segment10                := p_pgrp_segment10;
  l_ppl_grp_rec.segment11                := p_pgrp_segment11;
  l_ppl_grp_rec.segment12                := p_pgrp_segment12;
  l_ppl_grp_rec.segment13                := p_pgrp_segment13;
  l_ppl_grp_rec.segment14                := p_pgrp_segment14;
  l_ppl_grp_rec.segment15                := p_pgrp_segment15;
  l_ppl_grp_rec.segment16                := p_pgrp_segment16;
  l_ppl_grp_rec.segment17                := p_pgrp_segment17;
  l_ppl_grp_rec.segment18                := p_pgrp_segment18;
  l_ppl_grp_rec.segment19                := p_pgrp_segment19;
  l_ppl_grp_rec.segment20                := p_pgrp_segment20;
  l_ppl_grp_rec.segment21                := p_pgrp_segment21;
  l_ppl_grp_rec.segment22                := p_pgrp_segment22;
  l_ppl_grp_rec.segment23                := p_pgrp_segment23;
  l_ppl_grp_rec.segment24                := p_pgrp_segment24;
  l_ppl_grp_rec.segment25                := p_pgrp_segment25;
  l_ppl_grp_rec.segment26                := p_pgrp_segment26;
  l_ppl_grp_rec.segment27                := p_pgrp_segment27;
  l_ppl_grp_rec.segment28                := p_pgrp_segment28;
  l_ppl_grp_rec.segment29                := p_pgrp_segment29;
  l_ppl_grp_rec.segment30                := p_pgrp_segment30;

  hr_utility.set_location('People Grp KFF segments assigned to record: ' ||
                          'l_ppl_grp_rec ', 60);

  Update_StuEmpAsg_Criteria
  (p_effective_date => p_effective_date
  ,p_asg_crit_out   => l_asg_crit_out
   );
  -- If Leg. Code is US then check if the student is exempt from FICA.
  hr_utility.set_location('p_FICA_exempt: ' ||p_FICA_exempt, 60);

  IF (g_leg_code ='US' AND
      l_FICA_exempt IS NOT NULL )THEN
    Student_FICA_Status
    (p_assignment_id     => p_assignment_id
    ,p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_FICA_Status       => l_FICA_exempt);
  END IF;
  hr_utility.set_location('Leaving : ' || l_proc_name,70);

EXCEPTION
  WHEN Others THEN
  hr_utility.set_location('SQLCODE :' || SQLCODE,80);
  l_error_msg := SQLERRM;
  hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
  hr_utility.set_message_token('GENERIC_TOKEN',l_error_msg );
  hr_utility.set_location('Leaving: ' || l_proc_name, 80);
  hr_utility.raise_error;

END Upd_OSS_Person_Asg;

-- =============================================================================
-- ~ Get_Person_Type:
-- =============================================================================
FUNCTION Get_Person_Type
        (p_person_id         IN Number
        ,p_business_group_id IN Number
        ,p_effective_date    IN Date) Return Varchar2 Is


  CURSOR csr_per_type (c_person_id         IN Number
                      ,c_business_group_id IN Number
                      ,c_effective_date    IN Date) IS
  SELECT ppt.system_person_type
        ,ppt.user_person_type
        ,ppt.person_type_id
    FROM per_people_f ppf
        ,per_person_types ppt
   WHERE ppt.person_type_id = ppf.person_type_id
     AND c_effective_date BETWEEN ppf.effective_start_date
                              AND ppf.effective_end_date
     AND ppf.person_id = c_person_id
     AND ppt.business_group_id = c_business_group_id
     AND ppf.business_group_id = ppt.business_group_id;

  l_return_value  Varchar(600);
  l_per_type_rec  csr_per_type%ROWTYPE;

BEGIN
  l_return_value := null;
  OPEN csr_per_type (c_person_id         => p_person_id
                    ,c_business_group_id => p_business_group_id
                    ,c_effective_date    => p_effective_date);
  FETCH csr_per_type INTO l_per_type_rec;
  CLOSE csr_per_type;

  FOR per_type IN csr_per_ptu
                  (c_person_id         => p_person_id
                  ,c_business_group_id => p_business_group_id
                  ,c_effective_date    => p_effective_date)
  LOOP
    IF l_return_value IS NOT NULL THEN
      l_return_value := l_return_value ||'.'||per_type.user_person_type;
    ELSE
      l_return_value := per_type.user_person_type;
    END IF;
  END LOOP;

  IF l_per_type_rec.system_person_type Is Not Null AND
     l_per_type_rec.system_person_type = 'OTHER' THEN
     IF l_return_value Is Null THEN
        l_return_value := l_per_type_rec.user_person_type;
     END IF;
  END IF;

  RETURN NVL(l_return_value,'0');

END Get_Person_Type;

END Pqp_Hross_Integration;

/
