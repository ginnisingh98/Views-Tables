--------------------------------------------------------
--  DDL for Package Body PQP_PERASGADD_RIW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PERASGADD_RIW" as
/* $Header: pqpaariw.pkb 120.14.12010000.13 2009/07/20 03:53:01 psengupt ship $ */

-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
  g_pkg                constant varchar2(150) := 'PQP_PerAsgAdd_RIW.';
  g_debug                       boolean;
  g_leg_code                    varchar2(5);
  g_emp_num_gen                 varchar2(5);
  g_apl_num_gen                 varchar2(5);
  g_cwk_num_gen                 varchar2(5);
  g_business_group_id           number(15);

  g_per_rec                     per_all_people_f%rowtype;
  g_scl_rec                     hr_soft_coding_keyflex%rowtype;
  g_add_rec                     per_addresses%rowtype;
  g_grp_rec                     pay_people_groups%rowtype;
  g_asg_rec                     per_all_assignments_f%rowtype;
  g_phn_rec                     per_phones%rowtype;
  g_cnt_rec                     per_contact_relationships%rowtype;
  g_interface_code              varchar2(150);
  g_migration_flag              varchar2(5);

  --$ Added by Dbansal to upload comments
  g_per_comments                varchar2(150);
  g_asg_comments                varchar2(150);
  g_sec_asg_flag                number :=0;
    --$ To upload supervisor id
  g_supervisor_user_key     varchar2(240);
    --$ To Upload Benefit Group Name in HR Pump Batch Lines
  g_benefit_grp_name        varchar2(100);
    --$ Get upload mode - "Create and Update" (C) or "Update Only" (U)
    -- or "View/Download Only" (D)
  g_crt_upd                 varchar2 (1):= 'D'; -- By default 'Download only'
                                                -- i.e. uploading data not allowed
    --$ Exceptions
  e_upl_not_allowed exception; -- when mode is 'View Only'
  e_crt_per_not_allowed exception;
  e_crt_asg_not_allowed exception;
  e_crt_add_not_allowed exception;

  g_upl_err_msg varchar2(100) := 'Upload NOT allowed.';
  g_crt_per_err_msg varchar2(100) := 'Creating new person is NOT allowed.'; -- this includes converting a person
                                           -- to an employee also
  g_crt_asg_err_msg varchar2(100) := 'Creating new assignment is NOT allowed.';
  g_crt_add_err_msg varchar2(100) := 'Creating new address is NOT allowed.';

  type ref_cur_typ is ref cursor;

  type t_hrempapi is record
  (person_id                    per_all_people_f.person_id%type
  ,assignment_id                per_all_assignments_f.assignment_id%type
  ,per_object_version_number    per_all_people_f.object_version_number%type
  ,asg_object_version_number    per_all_assignments_f.object_version_number%type
  ,per_effective_start_date     date
  ,per_effective_end_date       date
  ,full_name                    per_all_people_f.full_name%type
  ,per_comment_id               per_all_people_f.comment_id%type
  ,assignment_sequence          per_all_assignments_f.assignment_sequence%type
  ,assignment_number            per_all_assignments_f.assignment_number%type
  ,pdp_object_version_number    per_all_people_f.object_version_number%type
  ,name_combination_warning     boolean
  ,assign_payroll_warning       boolean
  ,orig_hire_warning            boolean
  );

  type t_asgupdcrit_api is record
  (asg_object_version_number    per_all_assignments_f.object_version_number%type
  ,special_ceiling_step_id      per_all_assignments_f.special_ceiling_step_id%type
  ,people_group_id              per_all_assignments_f.people_group_id%type
  ,soft_coding_keyflex_id       per_all_assignments_f.soft_coding_keyflex_id%type
  ,group_name                   pay_people_groups.group_name%type
  ,asg_effective_start_date     per_all_assignments_f.effective_start_date%type
  ,asg_effective_end_date       per_all_assignments_f.effective_end_date%type
  ,org_now_no_manager_warning   boolean
  ,other_manager_warning        boolean
  ,spp_delete_warning           boolean
  ,entries_changed_warning      varchar2(50)
  ,tax_district_changed_warning boolean
  ,concatenated_segments        hr_soft_coding_keyflex.concatenated_segments%type
  ,gsp_post_process_warning     varchar2(2000)
  ,comment_id                   per_all_assignments_f.comment_id%type
  );

  type t_upd_emp_asg_api is record
  (cagr_grade_def_id            per_all_assignments_f.cagr_grade_def_id%type
  ,cagr_concatenated_segments   varchar2(2000)
  ,concatenated_segments        varchar2(2000)
  ,soft_coding_keyflex_id       per_all_assignments_f.soft_coding_keyflex_id%type
  ,comment_id                   per_all_assignments_f.comment_id%type
  ,effective_start_date         per_all_assignments_f.effective_start_date%type
  ,effective_end_date           per_all_assignments_f.effective_end_date%type
  ,no_managers_warning          boolean
  ,other_manager_warning        boolean
  ,hourly_salaried_warning      boolean
  ,gsp_post_process_warning     varchar2(2000)
  );

  type t_rehireemp_api is record
  (assignment_id                per_all_assignments_f.assignment_id%type
  ,asg_object_version_number    per_all_assignments_f.object_version_number%type
  ,per_effective_start_date     per_all_people_f.effective_start_date%type
  ,per_effective_end_date       per_all_people_f.effective_end_date%type
  ,assignment_sequence          per_all_assignments_f.assignment_sequence%type
  ,assignment_number            per_all_assignments_f.assignment_number%type
  ,assign_payroll_warning       boolean
  );

  type t_updemp_api is record
  (effective_start_date        per_all_people_f.effective_start_date%type
  ,effective_end_date          per_all_people_f.effective_end_date%type
  ,full_name                   per_all_people_f.full_name%type
  ,comment_id                  number
  ,name_combination_warning    boolean
  ,assign_payroll_warning      boolean
  ,orig_hire_warning           boolean
  );

  type t_hrtojob_api is record
  (effective_start_date        per_all_people_f.effective_start_date%type
  ,effective_end_date          per_all_people_f.effective_end_date%type
  ,assignment_id               per_all_assignments_f.assignment_id%type
  ,assign_payroll_warning      boolean
  ,orig_hire_warning           boolean
  );

  type t_hrapp_api is record
  (effective_start_date        per_all_people_f.effective_start_date%type
  ,effective_end_date          per_all_people_f.effective_end_date%type
  ,assign_payroll_warning      boolean
  ,oversubscribed_vacancy_id   number
  );

  type t_createcontact_api is record
  (contact_relationship_id     per_contact_relationships.contact_relationship_id%type
  ,ctr_object_version_number   per_contact_relationships.object_version_number%type
  ,per_person_id               per_contact_relationships.contact_person_id%type
  ,per_object_version_number   per_contact_relationships.object_version_number%type
  ,per_effective_start_date    per_contact_relationships.date_start%type
  ,per_effective_end_date      per_contact_relationships.date_start%type
  ,full_name                   per_all_people_f.full_name%type
  ,per_comment_id              per_all_people_f.comment_id%type
  ,name_combination_warning    boolean
  ,orig_hire_warning           boolean
  );

  type t_asg_wrk_strs is record
  (grade_name        per_grades.name%type
  ,position_name     hr_all_positions_f.name%type
  ,job_name          per_jobs.name%type
  ,payroll_name      pay_all_payrolls_f.payroll_name%type
  ,organization_name hr_all_organization_units.name%type
  ,location_code     hr_locations_all.location_code%type
  ,pay_basis_name    per_pay_bases.name%type
  );

  g_wstr_names       t_asg_wrk_strs;

-- =============================================================================
-- ~ Package Body Cursor variables:
-- =============================================================================

  --$ Cursor to fetch Benefit Group Name from Benefit Group ID to
  -- insert into batch lines

  Cursor csr_get_benefit_name (c_benefit_group_id in number,
                               c_business_group_id in number) is
   select bbg.name
   from   ben_benfts_grp bbg
   where  bbg.benfts_grp_id = c_benefit_group_id
   and    bbg.business_group_id + 0 = c_business_group_id;


   -- Cursor to get the leg. code
   cursor csr_bg_code (c_business_group_id in number) is
   select pbg.legislation_code
         ,pbg.method_of_generation_emp_num
         ,pbg.method_of_generation_apl_num
         ,pbg.method_of_generation_cwk_num
         ,pbg.business_group_id
     from per_business_groups pbg
    where pbg.business_group_id = c_business_group_id;

   -- Cursor to get the meaning and code for a lookup type
   cursor csr_chk_code (c_lookup_type    in varchar2
                       ,c_lookup_code    in varchar2
                       ,c_effective_date in date) is
   select hrl.meaning
         ,hrl.lookup_code
     from hr_lookups hrl
    where hrl.lookup_type = c_lookup_type
      and hrl.lookup_code = c_lookup_code
      and hrl.enabled_flag = 'Y'
      and trunc(c_effective_date)
          between nvl(hrl.start_date_active, trunc(c_effective_date))
              and nvl(hrl.end_date_active,   trunc(c_effective_date));

   -- Cursor to check the valid df context
   cursor csr_style (c_context_code in varchar2) is
   select dfc.descriptive_flex_context_code
     from fnd_descr_flex_contexts dfc
    where dfc.application_id = 800
      and dfc.descriptive_flexfield_name = 'Person Developer DF'
      and dfc.enabled_flag = 'Y';

  -- Cursor to get details of a particular person
  cursor csr_per (c_person_id         in number
                 ,c_business_group_id in number
                 ,c_effective_date    in date ) is
  select *
    from per_all_people_f ppf
   where ppf.person_id = c_person_id
     and ppf.business_group_id = c_business_group_id
     and c_effective_date between ppf.effective_start_date
                              and ppf.effective_end_date;

  -- Check the person or party if exists in hrms
  cursor chk_party (c_party_id       in number
                   ,c_bg_grp_id      in number
                   ,c_person_id      in number
                   ,c_effective_date in date) is
  select ppt.system_person_type
        ,ppf.effective_start_date
        ,ppf.effective_end_date
        ,ppf.employee_number
        ,ppt.person_type_id
        ,ppf.person_id
    from per_all_people_f ppf
        ,per_person_types ppt
   where ppt.person_type_id    = ppf.person_type_id
     and ppf.business_group_id = c_bg_grp_id
     and ppt.business_group_id = ppf.business_group_id
     and ppt.active_flag       = 'Y'
     and ((c_person_id is not null and ppf.person_id = c_person_id) or
          (c_party_id  is not null and ppf.party_id = c_party_id))
     and c_effective_date between ppf.effective_start_date
                              and ppf.effective_end_date;

  -- cursor to get the person types used as of a date
  cursor csr_per_ptu (c_person_id         in number
                     ,c_business_group_id in number
                     ,c_effective_date    in date) is
  select ptu.person_id
        ,ptu.person_type_id
        ,ppt.active_flag
        ,ppt.system_person_type
        ,ppt.user_person_type
    from per_person_type_usages_f ptu
        ,per_person_types         ppt
   where ptu.person_id         = c_person_id
     and ppt.business_group_id = c_business_group_id
     and ppt.person_type_id    = ptu.person_type_id
     and c_effective_date between ptu.effective_start_date
                              and ptu.effective_end_date
     and ppt.system_person_type
         in ('EMP','EMP_APL','EX_EMP',
             'APL','APL_EX_APL','EX_APL','EX_EMP_APL',
             'CWK','EX_CWK')
  order by ptu.effective_start_date desc;

  -- Cursor to check if the person has any future person type
  -- changes of EMP, APL, CWK or OTHER i.e. Contact type
  cursor chk_pertype_usage (c_person_id         in number
                           ,c_effective_date    in date
                           ,c_business_group_id in number) is
  select ptu.person_type_id
        ,ppt.system_person_type
        ,ppt.user_person_type
    from per_person_type_usages_f ptu
        ,per_person_types         ppt
   where ptu.person_id         = c_person_id
     and ppt.person_type_id    = ptu.person_type_id
     and ppt.business_group_id = c_business_group_id
     and ptu.effective_start_date > c_effective_date
     and ppt.system_person_type in
         ('EMP'   ,'CWK'       ,'APL'       ,'EMP_APL',
          'EX_APL','EX_CWK'    ,'EX_EMP_APL',
          'OTHER' ,'APL_EX_APL','EX_EMP'
          );
  --
  -- Cursor to check if the applicant assignment is accepted
  --
  cursor csr_accepted_asgs(c_person_id         in number
                          ,c_business_group_id in number
                          ,c_effective_date    in date
                          ,c_assignment_id     in number
                          ) is
  select asg.assignment_id
        ,asg.object_version_number
        ,asg.vacancy_id
    from per_all_assignments_f       asg
        ,per_assignment_status_types ast
   where asg.assignment_status_type_id = ast.assignment_status_type_id
     and asg.person_id                 = c_person_id
     and asg.business_group_id         = c_business_group_id
     and (c_assignment_id is null or
          asg.assignment_id = c_assignment_id)
     and c_effective_date between asg.effective_start_date
                              and asg.effective_end_date
     and asg.assignment_type   = 'A'
     and ast.per_system_status = 'ACCEPTED';
  --
  -- Cursor to check if the applicant assignment is accepted
  --
  cursor csr_not_accepted_asgs(c_person_id         in number
                              ,c_business_group_id in number
                              ,c_effective_date    in date
                              ,c_assignment_id     in number
                              ) is
  select asg.assignment_id
        ,asg.object_version_number
        ,asg.vacancy_id
    from per_all_assignments_f asg
        ,per_assignment_status_types ast
   where asg.assignment_status_type_id = ast.assignment_status_type_id
     and asg.person_id = c_person_id
     and asg.business_group_id = c_business_group_id
     and (c_assignment_id is null or
          asg.assignment_id = c_assignment_id)
     and c_effective_date between asg.effective_start_date
                              and asg.effective_end_date
     and asg.assignment_type = 'A'
     and ast.per_system_status <> 'ACCEPTED';
  --
  -- Cursor to get the Assignment Status Id of accepted Applicant Assig.
  --
  cursor csr_asg_status (c_leg_code          in varchar2
                        ,c_business_group_id in number
                        ) is
  select assignment_status_type_id
        ,active_flag
        ,per_system_status
   from per_assignment_status_types
  where per_system_status    = 'ACCEPTED'
    and (business_group_id   = c_business_group_id
         or legislation_code = c_leg_code
         or (legislation_code is null
             and business_group_id is null)
         )
    and default_flag = 'Y'
    and active_flag  = 'Y';
  --
  -- Cursor to get the User Person Type
  --
  cursor csr_per_type(c_person_type_id number
                     ,c_business_group_id in number) is
  select ppt.user_person_type
    from per_person_types ppt
   where ppt.person_type_id    = c_person_type_id
     and ppt.business_group_id = c_business_group_id;
  --
  -- Cursor to get the Grade Name
  --
  cursor csr_grade(c_grade_id in number
                  ,c_business_group_id in number
                  ,c_effective_date in date) is
  select gtl.name
    from per_grades    pgr
        ,per_grades_tl gtl
   where pgr.grade_id          = c_grade_id
     and gtl.grade_id          = pgr.grade_id
     and gtl.language          = userenv('LANG')
     and pgr.business_group_id = c_business_group_id
     and c_effective_date between pgr.date_from
                              and nvl(pgr.date_to,c_effective_date);
  --
  -- Cursor to get the Position Name
  --
  cursor csr_position(c_position_id       in number
                     ,c_business_group_id in number
                     ,c_effective_date    in date) is
  select ptl.name
    from hr_all_positions_f    pos
        ,hr_all_positions_f_tl ptl
   where pos.position_id       = c_position_id
     and ptl.position_id       = pos.position_id
     and ptl.language          = userenv('LANG')
     and pos.business_group_id = c_business_group_id
     and c_effective_date between pos.effective_start_date
                              and pos.effective_end_date;
  --
  -- Cursor to get the Job Name
  --
  cursor csr_job(c_job_id            in number
                ,c_business_group_id in number
                ,c_effective_date    in date) is
  select jtl.name
    from per_jobs    pjb
        ,per_jobs_tl jtl
   where pjb.job_id            = c_job_id
     and jtl.job_id            = pjb.job_id
     and jtl.language          = Userenv('LANG')
     and pjb.business_group_id = c_business_group_id
     and c_effective_date between pjb.date_from
                              and NVL(pjb.date_to,c_effective_date);
  --
  -- Cursor to get the Payroll Name
  --
  cursor csr_payroll(c_payroll_id in number
                    ,c_business_group_id in number
                    ,c_effective_date in date) is
  select payroll_name
    from pay_payrolls_f ppf
   where ppf.payroll_id        = c_payroll_id
     and ppf.business_group_id = c_business_group_id
     and c_effective_date between ppf.effective_start_date
                              and ppf.effective_end_date;
  --
  -- Cursor to get the Location Code
  --
  cursor csr_location(c_location_id in number
                     ,c_business_group_id in number
                     ) is
  select htl.location_code
    from hr_locations          hrl
        ,hr_locations_all_tl   htl
   where hrl.location_id        = c_location_id
     and htl.location_id        = hrl.location_id
     and htl.language           = Userenv('LANG')
     and (hrl.business_group_id is null or
          hrl.business_group_id = c_business_group_id);
  --
  -- Cursor to get the Organization Name
  --
  cursor csr_organization(c_organization_id in number
                         ,c_business_group_id in number
                         ,c_effective_date in date
                          ) is
  select htl.name
    from hr_all_organization_units_tl htl
        ,hr_all_organization_units    hao
   where hao.organization_id   = c_organization_id
     and hao.business_group_id = c_business_group_id
     and htl.organization_id   = hao.organization_id
     and htl.language          = Userenv('LANG')
     and c_effective_date between hao.date_from
                              and NVL(hao.date_to,c_effective_date);
  --
  -- Cursor to get the Pay Basis Name
  --
  cursor csr_paybasis(c_pay_basis_id in number
                     ,c_business_group_id in number
                     ) is
  select ppb.name
    from per_pay_bases ppb
   where ppb.pay_basis_id = c_pay_basis_id
     and ppb.business_group_id = c_business_group_id;
  --
  -- Cursor to check if address already exists
  --
  cursor csr_ck_add_xsts (c_person_id         in number
                         ,c_business_group_id in number
                         ,c_effective_date    in date
                         ,c_primary_flag      in varchar2) is
  select *
    from per_addresses
   where person_id = c_person_id
     and business_group_id = c_business_group_id
     and primary_flag = c_primary_flag
     and c_effective_date between date_from
                              and NVL(date_to, c_effective_date);
  --
  -- Cursor to check if Contact for a person already exists
  --
  cursor csr_ck_cont_xsts(c_person_id         in number
                         ,c_business_group_id in number
                         ,c_effective_date    in date) is
  select object_version_number
    from per_contact_relationships
   where person_id = c_person_id
     and business_group_id = c_business_group_id
     and c_effective_date between date_start
                              and NVL(date_end, c_effective_date);
  --
  -- Cursor to get the Employee Number
  --
  cursor csr_get_employee_num(c_person_id   in number) is
  select employee_number
    from per_all_people_f
   where person_id = c_person_id;

-- =============================================================================
-- Default_Record_Values:
-- =============================================================================
function Default_Person_Rec
         return per_all_people_f%rowtype is
  l_proc_name    constant varchar2(150) := g_pkg||'Default_Person_Rec';
  l_per_rec     per_all_people_f%rowtype;
begin

  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
  /*
   ==========================================================================
   g_varchar2  constant varchar2(9) := '$Sys_Def$';
   g_number  constant number        := -987123654;
   g_date  constant date            := to_date('01-01-4712', 'DD-MM-SYYYY');
   ==========================================================================
  */
  l_per_rec.person_type_id                := hr_api.g_number;
  l_per_rec.vendor_id                     := hr_api.g_number;
  --l_per_rec.benefit_group_id              := hr_api.g_number;
  l_per_rec.party_id                      := hr_api.g_number;
  l_per_rec.comment_id                    := hr_api.g_number;

  Hr_Utility.set_location(l_proc_name, 6);

  --l_per_rec.date_employee_data_verified   := hr_api.g_date;
  --l_per_rec.date_of_birth                 := hr_api.g_date;
  --l_per_rec.original_date_of_hire         := hr_api.g_date;
  --l_per_rec.dpdnt_adoption_date           := hr_api.g_date;
  --l_per_rec.coord_ben_med_cvg_strt_dt     := hr_api.g_date;
  --l_per_rec.coord_ben_med_cvg_end_dt      := hr_api.g_date;
  --l_per_rec.receipt_of_death_cert_date    := hr_api.g_date;
  --l_per_rec.resume_last_updated           := hr_api.g_date;
  --l_per_rec.last_medical_test_date        := hr_api.g_date;
  --l_per_rec.hold_applicant_date_until     := hr_api.g_date;
  --l_per_rec.background_date_check         := hr_api.g_date;
  --l_per_rec.date_of_death                 := hr_api.g_date;
  --l_per_rec.projected_start_date          := hr_api.g_date;

  l_per_rec.last_name                     := hr_api.g_varchar2;
  l_per_rec.applicant_number              := hr_api.g_varchar2;
  l_per_rec.email_address                 := hr_api.g_varchar2;
  l_per_rec.expense_check_send_to_address := hr_api.g_varchar2;
  l_per_rec.first_name                    := hr_api.g_varchar2;
  l_per_rec.known_as                      := hr_api.g_varchar2;
  l_per_rec.marital_status                := hr_api.g_varchar2;
  l_per_rec.middle_names                  := hr_api.g_varchar2;
  l_per_rec.nationality                   := hr_api.g_varchar2;
  l_per_rec.national_identifier           := hr_api.g_varchar2;
  l_per_rec.previous_last_name            := hr_api.g_varchar2;
  l_per_rec.registered_disabled_flag      := hr_api.g_varchar2;
  l_per_rec.sex                           := hr_api.g_varchar2;
  l_per_rec.title                         := hr_api.g_varchar2;
  l_per_rec.work_telephone                := hr_api.g_varchar2;

  Hr_Utility.set_location(l_proc_name, 7);

  l_per_rec.attribute_category            := hr_api.g_varchar2;
  l_per_rec.attribute1                    := hr_api.g_varchar2;
  l_per_rec.attribute2                    := hr_api.g_varchar2;
  l_per_rec.attribute3                    := hr_api.g_varchar2;
  l_per_rec.attribute4                    := hr_api.g_varchar2;
  l_per_rec.attribute5                    := hr_api.g_varchar2;
  l_per_rec.attribute6                    := hr_api.g_varchar2;
  l_per_rec.attribute7                    := hr_api.g_varchar2;
  l_per_rec.attribute8                    := hr_api.g_varchar2;
  l_per_rec.attribute9                    := hr_api.g_varchar2;
  l_per_rec.attribute10                   := hr_api.g_varchar2;
  l_per_rec.attribute11                   := hr_api.g_varchar2;
  l_per_rec.attribute12                   := hr_api.g_varchar2;
  l_per_rec.attribute13                   := hr_api.g_varchar2;
  l_per_rec.attribute14                   := hr_api.g_varchar2;
  l_per_rec.attribute15                   := hr_api.g_varchar2;
  l_per_rec.attribute16                   := hr_api.g_varchar2;
  l_per_rec.attribute17                   := hr_api.g_varchar2;
  l_per_rec.attribute18                   := hr_api.g_varchar2;
  l_per_rec.attribute19                   := hr_api.g_varchar2;
  l_per_rec.attribute20                   := hr_api.g_varchar2;
  l_per_rec.attribute21                   := hr_api.g_varchar2;
  l_per_rec.attribute22                   := hr_api.g_varchar2;
  l_per_rec.attribute23                   := hr_api.g_varchar2;
  l_per_rec.attribute24                   := hr_api.g_varchar2;
  l_per_rec.attribute25                   := hr_api.g_varchar2;
  l_per_rec.attribute26                   := hr_api.g_varchar2;
  l_per_rec.attribute27                   := hr_api.g_varchar2;
  l_per_rec.attribute28                   := hr_api.g_varchar2;
  l_per_rec.attribute29                   := hr_api.g_varchar2;
  l_per_rec.attribute30                   := hr_api.g_varchar2;

  Hr_Utility.set_location(l_proc_name, 8);

  l_per_rec.per_information_category      := hr_api.g_varchar2;
  l_per_rec.per_information1              := hr_api.g_varchar2;
  l_per_rec.per_information2              := hr_api.g_varchar2;
  l_per_rec.per_information3              := hr_api.g_varchar2;
  l_per_rec.per_information4              := hr_api.g_varchar2;
  l_per_rec.per_information5              := hr_api.g_varchar2;
  l_per_rec.per_information6              := hr_api.g_varchar2;
  l_per_rec.per_information7              := hr_api.g_varchar2;
  l_per_rec.per_information8              := hr_api.g_varchar2;
  l_per_rec.per_information9              := hr_api.g_varchar2;
  l_per_rec.per_information10             := hr_api.g_varchar2;
  l_per_rec.per_information11             := hr_api.g_varchar2;
  l_per_rec.per_information12             := hr_api.g_varchar2;
  l_per_rec.per_information13             := hr_api.g_varchar2;
  l_per_rec.per_information14             := hr_api.g_varchar2;
  l_per_rec.per_information15             := hr_api.g_varchar2;
  l_per_rec.per_information16             := hr_api.g_varchar2;
  l_per_rec.per_information17             := hr_api.g_varchar2;
  l_per_rec.per_information18             := hr_api.g_varchar2;
  l_per_rec.per_information19             := hr_api.g_varchar2;
  l_per_rec.per_information20             := hr_api.g_varchar2;
  l_per_rec.per_information21             := hr_api.g_varchar2;
  l_per_rec.per_information22             := hr_api.g_varchar2;
  l_per_rec.per_information23             := hr_api.g_varchar2;
  l_per_rec.per_information24             := hr_api.g_varchar2;
  l_per_rec.per_information25             := hr_api.g_varchar2;
  l_per_rec.per_information26             := hr_api.g_varchar2;
  l_per_rec.per_information27             := hr_api.g_varchar2;
  l_per_rec.per_information28             := hr_api.g_varchar2;
  l_per_rec.per_information29             := hr_api.g_varchar2;
  l_per_rec.per_information30             := hr_api.g_varchar2;

  Hr_Utility.set_location(l_proc_name, 9);

  l_per_rec.background_check_status       := hr_api.g_varchar2;
  l_per_rec.blood_type                    := hr_api.g_varchar2;
  l_per_rec.correspondence_language       := hr_api.g_varchar2;
  l_per_rec.fast_path_employee            := hr_api.g_varchar2;
  l_per_rec.honors                        := hr_api.g_varchar2;
  l_per_rec.internal_location             := hr_api.g_varchar2;
  l_per_rec.last_medical_test_by          := hr_api.g_varchar2;
  l_per_rec.mailstop                      := hr_api.g_varchar2;
  l_per_rec.office_number                 := hr_api.g_varchar2;
  l_per_rec.on_military_service           := hr_api.g_varchar2;
  l_per_rec.pre_name_adjunct              := hr_api.g_varchar2;
  l_per_rec.rehire_authorizor             := hr_api.g_varchar2;
  l_per_rec.rehire_recommendation         := hr_api.g_varchar2;
  l_per_rec.resume_exists                 := hr_api.g_varchar2;
  l_per_rec.second_passport_exists        := hr_api.g_varchar2;
  l_per_rec.student_status                := hr_api.g_varchar2;
  l_per_rec.work_schedule                 := hr_api.g_varchar2;
  l_per_rec.rehire_reason                 := hr_api.g_varchar2;
  l_per_rec.suffix                        := hr_api.g_varchar2;
  l_per_rec.coord_ben_med_pln_no          := hr_api.g_varchar2;
  l_per_rec.coord_ben_no_cvg_flag         := hr_api.g_varchar2;
  l_per_rec.coord_ben_med_ext_er          := hr_api.g_varchar2;
  l_per_rec.coord_ben_med_pl_name         := hr_api.g_varchar2;
  l_per_rec.coord_ben_med_insr_crr_name   := hr_api.g_varchar2;
  l_per_rec.coord_ben_med_insr_crr_ident  := hr_api.g_varchar2;
  l_per_rec.uses_tobacco_flag             := hr_api.g_varchar2;
  l_per_rec.dpdnt_vlntry_svce_flag        := hr_api.g_varchar2;
  l_per_rec.town_of_birth                 := hr_api.g_varchar2;
  l_per_rec.region_of_birth               := hr_api.g_varchar2;
  l_per_rec.country_of_birth              := hr_api.g_varchar2;
  l_per_rec.global_person_id              := hr_api.g_varchar2;
  l_per_rec.npw_number                    := hr_api.g_varchar2;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  return l_per_rec;
exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;

end Default_Person_Rec;
-- =============================================================================
-- Get_PerRecord_Values:
-- =============================================================================
function Get_PerRecord_Values
        (p_interface_code in varchar2 default null)
         return per_all_people_f%rowtype is

  cursor bne_cols(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='Y';
     --and bic.interface_col_type <> 2;

  -- Added by pkagrawa to query cols which are not displayed (DFF segments)
   cursor bne_cols_no_disp(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='N';

  l_per_rec            per_all_people_f%rowtype;
  col_name             varchar2(150);
  l_proc_name constant varchar2(150) := g_pkg||'Default_Person_Rec';
begin

  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);

  l_per_rec := Default_Person_Rec;

  for col_rec in bne_cols (g_interface_code)
  loop
   case col_rec.interface_col_name

    when 'p_internal_location' then       -- Added by pkagrawa
          l_per_rec.internal_location := g_per_rec.internal_location; -- Added by pkagrawa
    when 'p_party_id' then
          l_per_rec.party_id := g_per_rec.party_id;
    when 'p_business_group_id' then
          l_per_rec.business_group_id := g_per_rec.business_group_id;
    when 'p_national_identifier' then
          l_per_rec.national_identifier := g_per_rec.national_identifier;
    when 'p_last_name' then
          l_per_rec.last_name := g_per_rec.last_name;
    when 'p_middle_name' then
          l_per_rec.middle_names := g_per_rec.middle_names;
    when 'p_first_name' then
          l_per_rec.first_name := g_per_rec.first_name;
    when 'p_suffix' then
          l_per_rec.suffix := g_per_rec.suffix;
    when 'p_prefix' then
          l_per_rec.pre_name_adjunct := g_per_rec.pre_name_adjunct;
    when 'p_title' then
          l_per_rec.title := g_per_rec.title;
    when 'p_email_address' then
          l_per_rec.email_address := g_per_rec.email_address;
    when 'p_preferred_name' then
          l_per_rec.known_as := g_per_rec.known_as;
    when 'p_marital_status' then
          l_per_rec.marital_status := g_per_rec.marital_status;
    when 'p_sex' then
          l_per_rec.sex := g_per_rec.sex;
    when 'p_nationality' then
          l_per_rec.nationality := g_per_rec.nationality;
    when 'p_date_of_birth' then
          l_per_rec.date_of_birth := g_per_rec.date_of_birth;
    when 'p_date_of_hire' then
          l_per_rec.start_date := g_per_rec.start_date;
    when 'p_user_person_type' then
          l_per_rec.person_type_id := g_per_rec.person_type_id;
    when 'p_date_employee_data_verified' then
          l_per_rec.date_employee_data_verified := g_per_rec.date_employee_data_verified;
    when 'p_expense_check_send_to_addres' then
          l_per_rec.expense_check_send_to_address := g_per_rec.expense_check_send_to_address;
    when 'p_previous_last_name' then
          l_per_rec.previous_last_name := g_per_rec.previous_last_name;
    when 'p_registered_disabled_flag' then
          l_per_rec.registered_disabled_flag := g_per_rec.registered_disabled_flag;
    when 'p_vendor_id' then
          l_per_rec.vendor_id := g_per_rec.vendor_id;
    when 'p_date_of_death' then
          l_per_rec.date_of_death := g_per_rec.date_of_death;
    when 'p_background_check_status' then
          l_per_rec.background_check_status := g_per_rec.background_check_status;
    when 'p_background_date_check' then
          l_per_rec.background_date_check := g_per_rec.background_date_check;
    when 'p_blood_type' then
          l_per_rec.blood_type := g_per_rec.blood_type;
    when 'p_correspondence_language' then
          l_per_rec.correspondence_language := g_per_rec.correspondence_language;
    when 'p_fast_path_employee' then
          l_per_rec.fast_path_employee := g_per_rec.fast_path_employee;
    when 'p_fte_capacity' then
          l_per_rec.fte_capacity := g_per_rec.fte_capacity;
    when 'p_honors' then
          l_per_rec.honors := g_per_rec.honors;
    when 'p_last_medical_test_by' then
          l_per_rec.last_medical_test_by := g_per_rec.last_medical_test_by;
    when 'p_last_medical_test_date' then
          l_per_rec.last_medical_test_date := g_per_rec.last_medical_test_date;
    when 'p_mailstop' then
          l_per_rec.mailstop := g_per_rec.mailstop;
    when 'p_office_number' then
          l_per_rec.office_number := g_per_rec.office_number;
    when 'p_projected_start_date' then
          l_per_rec.projected_start_date := g_per_rec.projected_start_date;
    when 'p_resume_last_updated' then
          l_per_rec.resume_last_updated := g_per_rec.resume_last_updated;
    when 'p_student_status' then
          l_per_rec.student_status := g_per_rec.student_status;
    when 'p_work_schedule' then
          l_per_rec.work_schedule := g_per_rec.work_schedule;
    when 'p_benefit_group_id' then
          l_per_rec.benefit_group_id := g_per_rec.benefit_group_id;
    when 'p_receipt_of_death_cert_date' then
          l_per_rec.receipt_of_death_cert_date := g_per_rec.receipt_of_death_cert_date;
    when 'p_coord_ben_med_pln_no' then
          l_per_rec.coord_ben_med_pln_no := g_per_rec.coord_ben_med_pln_no;
    when 'p_coord_ben_med_ext_er' then
          l_per_rec.coord_ben_med_ext_er := g_per_rec.coord_ben_med_ext_er;
    when 'p_coord_ben_med_pl_name' then
          l_per_rec.coord_ben_med_pl_name := g_per_rec.coord_ben_med_pl_name;
    when 'p_coord_ben_med_insr_crr_name' then
          l_per_rec.coord_ben_med_insr_crr_name := g_per_rec.coord_ben_med_insr_crr_name;
    when 'p_coord_ben_med_insr_crr_ident' then
          l_per_rec.coord_ben_med_insr_crr_ident := g_per_rec.coord_ben_med_insr_crr_ident;
    when 'p_coord_ben_med_cvg_strt_dt' then
          l_per_rec.coord_ben_med_cvg_strt_dt := g_per_rec.coord_ben_med_cvg_strt_dt;
    when 'p_coord_ben_med_cvg_end_dt' then
          l_per_rec.coord_ben_med_cvg_end_dt := g_per_rec.coord_ben_med_cvg_end_dt;
    when 'p_uses_tobacco_flag' then
          l_per_rec.uses_tobacco_flag := g_per_rec.uses_tobacco_flag;
    when 'p_dpdnt_adoption_date' then
          l_per_rec.dpdnt_adoption_date := g_per_rec.dpdnt_adoption_date;
    when 'p_original_date_of_hire' then
          l_per_rec.original_date_of_hire := g_per_rec.original_date_of_hire;
    when 'p_town_of_birth' then
          l_per_rec.town_of_birth := g_per_rec.town_of_birth;
    when 'p_region_of_birth' then
          l_per_rec.region_of_birth := g_per_rec.region_of_birth;
    when 'p_country_of_birth' then
          l_per_rec.country_of_birth := g_per_rec.country_of_birth;
    when 'p_global_person_id' then
          l_per_rec.global_person_id := g_per_rec.global_person_id;
    when 'p_dpdnt_vlntry_svce_flag' then
          l_per_rec.dpdnt_vlntry_svce_flag := g_per_rec.dpdnt_vlntry_svce_flag;
    when 'p_coord_ben_no_cvg_flag' then
          l_per_rec.coord_ben_no_cvg_flag := g_per_rec.coord_ben_no_cvg_flag;
    when 'p_second_passport_exists' then
          l_per_rec.second_passport_exists := g_per_rec.second_passport_exists;
    when 'p_resume_exists' then
          l_per_rec.resume_exists := g_per_rec.resume_exists;
    when 'p_on_military_service' then
          l_per_rec.on_military_service := g_per_rec.on_military_service;
    -- Person User Defined DF
    when 'attribute_category' then
          l_per_rec.attribute_category := g_per_rec.attribute_category;
          if l_per_rec.attribute_category is not null then
          for col_rec1 in bne_cols_no_disp(g_interface_code) loop
    --hr_utility.trace('$$UPD: attribute_category columns: '|| col_rec1.interface_col_name);
             case col_rec1.interface_col_name
             when 'attribute1' then
                   l_per_rec.attribute1 := g_per_rec.attribute1;
             when 'attribute2' then
                   l_per_rec.attribute2 := g_per_rec.attribute2;
             when 'attribute3' then
                   l_per_rec.attribute3 := g_per_rec.attribute3;
             when 'attribute4' then
                   l_per_rec.attribute4 := g_per_rec.attribute4;
             when 'attribute5' then
                   l_per_rec.attribute5 := g_per_rec.attribute5;
             when 'attribute6' then
                   l_per_rec.attribute6 := g_per_rec.attribute6;
             when 'attribute7' then
                   l_per_rec.attribute7 := g_per_rec.attribute7;
             when 'attribute8' then
                   l_per_rec.attribute8 := g_per_rec.attribute8;
             when 'attribute9' then
                   l_per_rec.attribute9 := g_per_rec.attribute9;
             when 'attribute10' then
                   l_per_rec.attribute10 := g_per_rec.attribute10;
             when 'attribute11' then
                   l_per_rec.attribute11 := g_per_rec.attribute11;
             when 'attribute12' then
                   l_per_rec.attribute12 := g_per_rec.attribute12;
             when 'attribute13' then
                   l_per_rec.attribute13 := g_per_rec.attribute13;
             when 'attribute14' then
                   l_per_rec.attribute14 := g_per_rec.attribute14;
             when 'attribute15' then
                   l_per_rec.attribute15 := g_per_rec.attribute15;
             when 'attribute16' then
                   l_per_rec.attribute16 := g_per_rec.attribute16;
             when 'attribute17' then
                   l_per_rec.attribute17 := g_per_rec.attribute17;
             when 'attribute18' then
                   l_per_rec.attribute18 := g_per_rec.attribute18;
             when 'attribute19' then
                   l_per_rec.attribute19 := g_per_rec.attribute19;
             when 'attribute20' then
                   l_per_rec.attribute20 := g_per_rec.attribute20;
             when 'attribute21' then
                   l_per_rec.attribute21 := g_per_rec.attribute21;
             when 'attribute22' then
                   l_per_rec.attribute22 := g_per_rec.attribute22;
             when 'attribute23' then
                   l_per_rec.attribute23 := g_per_rec.attribute23;
             when 'attribute24' then
                   l_per_rec.attribute24 := g_per_rec.attribute24;
             when 'attribute25' then
                   l_per_rec.attribute25 := g_per_rec.attribute25;
             when 'attribute26' then
                   l_per_rec.attribute26 := g_per_rec.attribute26;
             when 'attribute27' then
                   l_per_rec.attribute27 := g_per_rec.attribute27;
             when 'attribute28' then
                   l_per_rec.attribute28 := g_per_rec.attribute28;
             when 'attribute29' then
                   l_per_rec.attribute29 := g_per_rec.attribute29;
             when 'attribute30' then
                   l_per_rec.attribute30 := g_per_rec.attribute30;
             else
                  null;
             end case;
            end loop;
           end if;

    -- Person Legislative DDF
    when 'per_information_category' then
          l_per_rec.per_information_category := g_per_rec.per_information_category;
          if l_per_rec.per_information_category is not null then
    --hr_utility.trace('$$UPD: Inside per_information_category: '||l_per_rec.per_information_category);
            for col_rec1 in bne_cols_no_disp(g_interface_code) loop
    --hr_utility.trace('$$UPD: per_information_category Columns: '||col_rec1.interface_col_name);
             case col_rec1.interface_col_name
             when 'per_information1' then
                   l_per_rec.per_information1 := g_per_rec.per_information1;
             when 'per_information2' then
                   l_per_rec.per_information2 := g_per_rec.per_information2;
             when 'per_information3' then
                   l_per_rec.per_information3 := g_per_rec.per_information3;
             when 'per_information4' then
                   l_per_rec.per_information4 := g_per_rec.per_information4;
             when 'per_information5' then
                   l_per_rec.per_information5 := g_per_rec.per_information5;
             when 'per_information6' then
                   l_per_rec.per_information6 := g_per_rec.per_information6;
             when 'per_information7' then
                   l_per_rec.per_information7 := g_per_rec.per_information7;
             when 'per_information8' then
                   l_per_rec.per_information8 := g_per_rec.per_information8;
             when 'per_information9' then
                   l_per_rec.per_information9 := g_per_rec.per_information9;
             when 'per_information10' then
                   l_per_rec.per_information10 := g_per_rec.per_information10;
             when 'per_information11' then
                   l_per_rec.per_information11 := g_per_rec.per_information11;
             when 'per_information12' then
                   l_per_rec.per_information12 := g_per_rec.per_information12;
             when 'per_information13' then
                   l_per_rec.per_information13 := g_per_rec.per_information13;
             when 'per_information14' then
                   l_per_rec.per_information14 := g_per_rec.per_information14;
             when 'per_information15' then
                   l_per_rec.per_information15 := g_per_rec.per_information15;
             when 'per_information16' then
                   l_per_rec.per_information16 := g_per_rec.per_information16;
             when 'per_information17' then
                   l_per_rec.per_information17 := g_per_rec.per_information17;
             when 'per_information18' then
                   l_per_rec.per_information18 := g_per_rec.per_information18;
             when 'per_information19' then
                   l_per_rec.per_information19 := g_per_rec.per_information19;
             when 'per_information20' then
                   l_per_rec.per_information20 := g_per_rec.per_information20;
             when 'per_information21' then
                   l_per_rec.per_information21 := g_per_rec.per_information21;
             when 'per_information22' then
                   l_per_rec.per_information22 := g_per_rec.per_information22;
             when 'per_information23' then
                   l_per_rec.per_information23 := g_per_rec.per_information23;
             when 'per_information24' then
                   l_per_rec.per_information24 := g_per_rec.per_information24;
             when 'per_information25' then
                   l_per_rec.per_information25 := g_per_rec.per_information25;
             when 'per_information26' then
                   l_per_rec.per_information26 := g_per_rec.per_information26;
             when 'per_information27' then
                   l_per_rec.per_information27 := g_per_rec.per_information27;
             when 'per_information28' then
                   l_per_rec.per_information28 := g_per_rec.per_information28;
             when 'per_information29' then
                   l_per_rec.per_information29 := g_per_rec.per_information29;
             when 'per_information30' then
                   l_per_rec.per_information30 := g_per_rec.per_information30;
             else
                  null;
             end case;
            end loop;
           end if;
   else
      null;
   end case;
  end loop;
  Hr_Utility.set_location(' Leaving: '||l_proc_name, 80);
  return l_per_rec;

end Get_PerRecord_Values;
-- =============================================================================
-- Default_Asg_Rec:
-- =============================================================================
function Default_Assignment_Rec
         return per_all_assignments_f%rowtype is
  l_proc_name    constant varchar2(150) := g_pkg||'Default_Assignment_Rec';
  l_asg_rec     per_all_assignments_f%rowtype;
begin
  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
  /*
   ======================================================================
   g_varchar2 constant varchar2(9):= '$Sys_Def$';
   g_number constant number       := -987123654;
   g_date constant date           := to_date('01-01-4712','DD-MM-SYYYY');
   ======================================================================
  */
  l_asg_rec.grade_id                 := hr_api.g_number;
  l_asg_rec.position_id              := hr_api.g_number;
  l_asg_rec.job_id                   := hr_api.g_number;
  l_asg_rec.payroll_id               := hr_api.g_number;
  l_asg_rec.location_id              := hr_api.g_number;
  l_asg_rec.organization_id          := hr_api.g_number;
  l_asg_rec.pay_basis_id             := hr_api.g_number;
  l_asg_rec.employment_category      := hr_api.g_varchar2;
  l_asg_rec.contract_id              := hr_api.g_number;
  l_asg_rec.establishment_id         := hr_api.g_number;
  l_asg_rec.grade_ladder_pgm_id      := hr_api.g_number;
  l_asg_rec.supervisor_assignment_id := hr_api.g_number;
  l_asg_rec.special_ceiling_step_id  := hr_api.g_number;
  l_asg_rec.people_group_id          := hr_api.g_number;
  l_asg_rec.soft_coding_keyflex_id   := hr_api.g_number;

  Hr_Utility.set_location(l_proc_name, 10);

  l_asg_rec.supervisor_id                := hr_api.g_number;
  l_asg_rec.assignment_number            := hr_api.g_varchar2;
  l_asg_rec.change_reason                := hr_api.g_varchar2;
  l_asg_rec.assignment_status_type_id    := hr_api.g_number;
  l_asg_rec.date_probation_end           := hr_api.g_date;
  l_asg_rec.default_code_comb_id         := hr_api.g_number;
  l_asg_rec.frequency                    := hr_api.g_varchar2;
  l_asg_rec.internal_address_line        := hr_api.g_varchar2;
  l_asg_rec.manager_flag                 := hr_api.g_varchar2;
  l_asg_rec.normal_hours                 := hr_api.g_number;
  l_asg_rec.perf_review_period           := hr_api.g_number;
  l_asg_rec.perf_review_period_frequency := hr_api.g_varchar2;
  l_asg_rec.probation_period             := hr_api.g_number;
  l_asg_rec.probation_unit               := hr_api.g_varchar2;
  l_asg_rec.sal_review_period            := hr_api.g_number;
  l_asg_rec.sal_review_period_frequency  := hr_api.g_varchar2;
  l_asg_rec.set_of_books_id              := hr_api.g_number;
  l_asg_rec.source_type                  := hr_api.g_varchar2;
--  l_asg_rec.time_normal_finish           := hr_api.g_varchar2;
--  l_asg_rec.time_normal_start            := hr_api.g_varchar2;
  l_asg_rec.bargaining_unit_code         := hr_api.g_varchar2;
  l_asg_rec.labour_union_member_flag     := hr_api.g_varchar2;
  l_asg_rec.hourly_salaried_code         := hr_api.g_varchar2;

  Hr_Utility.set_location(l_proc_name, 15);

  l_asg_rec.ass_attribute_category       := hr_api.g_varchar2;
  l_asg_rec.ass_attribute1               := hr_api.g_varchar2;
  l_asg_rec.ass_attribute2               := hr_api.g_varchar2;
  l_asg_rec.ass_attribute3               := hr_api.g_varchar2;
  l_asg_rec.ass_attribute4               := hr_api.g_varchar2;
  l_asg_rec.ass_attribute5               := hr_api.g_varchar2;
  l_asg_rec.ass_attribute6               := hr_api.g_varchar2;
  l_asg_rec.ass_attribute7               := hr_api.g_varchar2;
  l_asg_rec.ass_attribute8               := hr_api.g_varchar2;
  l_asg_rec.ass_attribute9               := hr_api.g_varchar2;
  l_asg_rec.ass_attribute10              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute11              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute12              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute13              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute14              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute15              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute16              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute17              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute18              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute19              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute20              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute21              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute22              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute23              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute24              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute25              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute26              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute27              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute28              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute29              := hr_api.g_varchar2;
  l_asg_rec.ass_attribute30              := hr_api.g_varchar2;

  Hr_Utility.set_location(l_proc_name, 20);

  l_asg_rec.title                        := hr_api.g_varchar2;
  l_asg_rec.contract_id                  := hr_api.g_number;
  l_asg_rec.establishment_id             := hr_api.g_number;
  l_asg_rec.collective_agreement_id      := hr_api.g_number;
  l_asg_rec.notice_period                := hr_api.g_number;
  l_asg_rec.notice_period_uom            := hr_api.g_varchar2;
  l_asg_rec.employee_category            := hr_api.g_varchar2;
  l_asg_rec.supervisor_assignment_id     := hr_api.g_number;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  return l_asg_rec;
exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;

end Default_Assignment_Rec;
-- =============================================================================
-- Get_AsgRecord_Values:
-- =============================================================================
function Get_AsgRecord_Values
        (p_interface_code in varchar2 default null)
         return per_all_assignments_f%rowtype is

  cursor bne_cols(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='Y';

  -- Added by Dbansal to query cols which are not displayed (DFF segments)
   cursor bne_cols_no_disp(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='N';

  l_proc_name    constant varchar2(150) := g_pkg||'Get_AsgRecord_Values';
  l_asg_rec per_all_assignments_f%rowtype;
  col_name  varchar2(150);

begin
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  --$ check if secondary assignment is to be created
  -- If yes (i.e. flag is set to 1 ) then initialize to null else to hr_api variable
   -- type
  if   g_sec_asg_flag <> 1 then
  l_asg_rec := Default_Assignment_Rec;
  elsif g_sec_asg_flag = 1 then
  l_asg_rec := null;
  end if;

  for col_rec in bne_cols (g_interface_code)
  loop
   case col_rec.interface_col_name
    when 'p_business_group_id' then
     l_asg_rec.business_group_id := g_asg_rec.business_group_id;
    when 'p_assign_organization' then
     l_asg_rec.organization_id := g_asg_rec.organization_id;
    when 'p_job' then
     l_asg_rec.job_id := g_asg_rec.job_id;
    when 'p_grade' then
     l_asg_rec.grade_id := g_asg_rec.grade_id;
    when 'p_assign_group' then
     l_asg_rec.people_group_id := g_asg_rec.people_group_id;
    when 'p_position' then
     l_asg_rec.position_id := g_asg_rec.position_id;
    when 'p_payroll' then
     l_asg_rec.payroll_id := g_asg_rec.payroll_id;
    when 'p_salary_basis' then
     l_asg_rec.pay_basis_id := g_asg_rec.pay_basis_id;
    when 'p_status' then
     l_asg_rec.assignment_status_type_id := g_asg_rec.assignment_status_type_id;
    when 'p_assignment_no' then
     l_asg_rec.assignment_number := g_asg_rec.assignment_number;
    when 'p_assign_eff_dt_from' then
     l_asg_rec.effective_start_date := g_asg_rec.effective_start_date;
    when 'p_assign_eff_dt_to' then
     l_asg_rec.effective_end_date := g_asg_rec.effective_end_date;
    when 'p_assignment_category' then
     l_asg_rec.assignment_category := g_asg_rec.assignment_category;
    --Added by dbansal
     l_asg_rec.employment_category := g_asg_rec.assignment_category;
    when 'p_collective_agreement' then
     l_asg_rec.collective_agreement_id :=  g_asg_rec.collective_agreement_id;
    when 'p_employee_category' then
     l_asg_rec.employee_category := g_asg_rec.employee_category;
    when 'p_supervisor_id' then
     l_asg_rec.supervisor_id := g_asg_rec.supervisor_id;
    when 'p_assignment_number' then
     l_asg_rec.assignment_number := g_asg_rec.assignment_number;
    when 'p_change_reason' then
     l_asg_rec.change_reason := g_asg_rec.change_reason;
    when 'p_date_probation_end' then
     l_asg_rec.date_probation_end := g_asg_rec.date_probation_end;
    when 'p_default_code_comb_id' then
     l_asg_rec.default_code_comb_id := g_asg_rec.default_code_comb_id;
    when 'p_frequency' then
     l_asg_rec.frequency := g_asg_rec.frequency;
    when 'p_internal_address_line' then
     l_asg_rec.internal_address_line := g_asg_rec.internal_address_line;
    when 'p_manager_flag' then
     l_asg_rec.manager_flag := g_asg_rec.manager_flag;
    when 'p_normal_hours' then
     l_asg_rec.normal_hours := g_asg_rec.normal_hours;
    when 'p_perf_review_period' then
     l_asg_rec.perf_review_period := g_asg_rec.perf_review_period;
    when 'p_perf_review_period_frequency' then
     l_asg_rec.perf_review_period_frequency := g_asg_rec.perf_review_period_frequency;
    when 'p_probation_period' then
     l_asg_rec.probation_period := g_asg_rec.probation_period;
    when 'p_probation_unit' then
     l_asg_rec.probation_unit := g_asg_rec.probation_unit;
    when 'p_sal_review_period' then
     l_asg_rec.sal_review_period := g_asg_rec.sal_review_period;
    when 'p_sal_review_period_frequency' then
     l_asg_rec.sal_review_period_frequency := g_asg_rec.sal_review_period_frequency;
    when 'p_set_of_books_id' then
     l_asg_rec.set_of_books_id := g_asg_rec.set_of_books_id;
    when 'p_source_type' then
     l_asg_rec.source_type := g_asg_rec.source_type;
    when 'p_time_normal_finish' then
     l_asg_rec.time_normal_finish := g_asg_rec.time_normal_finish;
    when 'p_time_normal_start' then
     l_asg_rec.time_normal_start := g_asg_rec.time_normal_start;
    when 'p_bargaining_unit_code' then
     l_asg_rec.bargaining_unit_code := g_asg_rec.bargaining_unit_code;
    when 'p_labour_union_member_flag' then
     l_asg_rec.labour_union_member_flag := g_asg_rec.labour_union_member_flag;
    when 'p_hourly_salaried_code' then
     l_asg_rec.hourly_salaried_code := g_asg_rec.hourly_salaried_code;
    when 'p_location_id' then
     l_asg_rec.location_id := g_asg_rec.location_id;
    -- Assignment User Defined DF
    when 'ass_attribute_category' then
 --    hr_utility.trace('IN GET_ASGRECORD_VALUES, when ass_att_cat');
      l_asg_rec.ass_attribute_category := g_asg_rec.ass_attribute_category;
--hr_utility.trace('IN GET_ASGRECORD_VALUES ass_attribute_cat='||l_asg_rec.ass_attribute_category);
      if l_asg_rec.ass_attribute_category is not null then
--hr_utility.trace('IN GET_ASGRECORD_VALUES intfcolname'|| col_rec.interface_col_name);

         -- Added by Dbansal -> Another nested loop to set the values of DFF segments
         for col_rec1 in bne_cols_no_disp(g_interface_code) loop
       --   hr_utility.trace('IN GET_ASGRECORD_VALUES Nested:'|| col_rec1.interface_col_name);
           case col_rec1.interface_col_name
            when 'ass_attribute1' then
            l_asg_rec.ass_attribute1 := g_asg_rec.ass_attribute1;
--hr_utility.trace('IN GET_ASGRECORD_VALUES ass_attribute1='||l_asg_rec.ass_attribute1);
            when 'ass_attribute2' then
            l_asg_rec.ass_attribute2 := g_asg_rec.ass_attribute2;
--hr_utility.trace('IN GET_ASGRECORD_VALUES ass_attribute2='||l_asg_rec.ass_attribute2);
            when 'ass_attribute3' then
            l_asg_rec.ass_attribute3 := g_asg_rec.ass_attribute3;
            when 'ass_attribute4' then
            l_asg_rec.ass_attribute4 := g_asg_rec.ass_attribute4;
            when 'ass_attribute5' then
            l_asg_rec.ass_attribute5 := g_asg_rec.ass_attribute5;
            when 'ass_attribute6' then
            l_asg_rec.ass_attribute6 := g_asg_rec.ass_attribute6;
            when 'ass_attribute7' then
            l_asg_rec.ass_attribute7 := g_asg_rec.ass_attribute7;
            when 'ass_attribute8' then
            l_asg_rec.ass_attribute8 := g_asg_rec.ass_attribute8;
            when 'ass_attribute9' then
            l_asg_rec.ass_attribute9 := g_asg_rec.ass_attribute9;
            when 'ass_attribute10' then
            l_asg_rec.ass_attribute10 := g_asg_rec.ass_attribute10;
--hr_utility.trace('IN GET_ASGRECORD_VALUES ass_attribute10='||l_asg_rec.ass_attribute10);
            when 'ass_attribute11' then
            l_asg_rec.ass_attribute11 := g_asg_rec.ass_attribute11;
            when 'ass_attribute12' then
            l_asg_rec.ass_attribute12 := g_asg_rec.ass_attribute12;
--hr_utility.trace('IN GET_ASGRECORD_VALUES ass_attribute12='||l_asg_rec.ass_attribute12);
            when 'ass_attribute13' then
            l_asg_rec.ass_attribute13 := g_asg_rec.ass_attribute13;
            when 'ass_attribute14' then
            l_asg_rec.ass_attribute14 := g_asg_rec.ass_attribute14;
            when 'ass_attribute15' then
            l_asg_rec.ass_attribute15 := g_asg_rec.ass_attribute15;
            when 'ass_attribute16' then
            l_asg_rec.ass_attribute16 := g_asg_rec.ass_attribute16;
            when 'ass_attribute17' then
            l_asg_rec.ass_attribute17 := g_asg_rec.ass_attribute17;
            when 'ass_attribute18' then
            l_asg_rec.ass_attribute18 := g_asg_rec.ass_attribute18;
            when 'ass_attribute19' then
            l_asg_rec.ass_attribute19 := g_asg_rec.ass_attribute19;
            when 'ass_attribute20' then
            l_asg_rec.ass_attribute20 := g_asg_rec.ass_attribute20;
            when 'ass_attribute21' then
            l_asg_rec.ass_attribute21 := g_asg_rec.ass_attribute21;
            when 'ass_attribute22' then
            l_asg_rec.ass_attribute22 := g_asg_rec.ass_attribute22;
            when 'ass_attribute23' then
            l_asg_rec.ass_attribute23 := g_asg_rec.ass_attribute23;
            when 'ass_attribute24' then
            l_asg_rec.ass_attribute24 := g_asg_rec.ass_attribute24;
            when 'ass_attribute25' then
            l_asg_rec.ass_attribute25 := g_asg_rec.ass_attribute25;
            when 'ass_attribute26' then
            l_asg_rec.ass_attribute26 := g_asg_rec.ass_attribute26;
            when 'ass_attribute27' then
            l_asg_rec.ass_attribute27 := g_asg_rec.ass_attribute27;
            when 'ass_attribute28' then
            l_asg_rec.ass_attribute28 := g_asg_rec.ass_attribute28;
            when 'ass_attribute29' then
            l_asg_rec.ass_attribute29 := g_asg_rec.ass_attribute29;
            when 'ass_attribute30' then
            l_asg_rec.ass_attribute30 := g_asg_rec.ass_attribute30;
            else
            null;
          end case;
        end loop;
      end if;
   else
      null;
   end case;
  end loop;

  return l_Asg_rec;
 Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
exception
  when others then
  Hr_Utility.set_location('Error Leaving: '||l_proc_name, 90);
  raise;

end Get_AsgRecord_Values;

-- =============================================================================
-- Default_PpgFlx_Rec:
-- =============================================================================
function Default_PpgFlx_Rec
         return pay_people_groups%rowtype is
  l_proc_name    constant varchar2(150) := g_pkg||'Default_PpgFlx_Rec';
  l_grp_rec     pay_people_groups%rowtype;
begin
  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
  /*
   ======================================================================
   hr_api defaults:
   g_varchar2 constant varchar2(9):= '$Sys_Def$';
   g_number constant number       := -987123654;
   g_date constant date           := to_date('01-01-4712','DD-MM-SYYYY');
   ======================================================================
  */
  l_grp_rec.group_name   := hr_api.g_varchar2;

  Hr_Utility.set_location(' First : Default_PpgFlx_Rec'||l_grp_rec.group_name, 5);

  l_grp_rec.segment1     := hr_api.g_varchar2;
  l_grp_rec.segment2     := hr_api.g_varchar2;
  l_grp_rec.segment3     := hr_api.g_varchar2;
  l_grp_rec.segment4     := hr_api.g_varchar2;
  l_grp_rec.segment5     := hr_api.g_varchar2;
  l_grp_rec.segment6     := hr_api.g_varchar2;
  l_grp_rec.segment7     := hr_api.g_varchar2;
  l_grp_rec.segment8     := hr_api.g_varchar2;
  l_grp_rec.segment9     := hr_api.g_varchar2;
  Hr_Utility.set_location('Default_PpgFlx_Rec', 15);
  l_grp_rec.segment10    := hr_api.g_varchar2;
  l_grp_rec.segment11    := hr_api.g_varchar2;
  l_grp_rec.segment12    := hr_api.g_varchar2;
  l_grp_rec.segment13    := hr_api.g_varchar2;
  l_grp_rec.segment14    := hr_api.g_varchar2;
  l_grp_rec.segment15    := hr_api.g_varchar2;
  l_grp_rec.segment16    := hr_api.g_varchar2;
  l_grp_rec.segment17    := hr_api.g_varchar2;
  l_grp_rec.segment18    := hr_api.g_varchar2;
  l_grp_rec.segment19    := hr_api.g_varchar2;
  Hr_Utility.set_location('Default_PpgFlx_Rec', 20);
  l_grp_rec.segment20    := hr_api.g_varchar2;
  l_grp_rec.segment21    := hr_api.g_varchar2;
  l_grp_rec.segment22    := hr_api.g_varchar2;
  l_grp_rec.segment23    := hr_api.g_varchar2;
  l_grp_rec.segment24    := hr_api.g_varchar2;
  l_grp_rec.segment25    := hr_api.g_varchar2;
  l_grp_rec.segment26    := hr_api.g_varchar2;
  l_grp_rec.segment27    := hr_api.g_varchar2;
  l_grp_rec.segment28    := hr_api.g_varchar2;
  l_grp_rec.segment29    := hr_api.g_varchar2;
  l_grp_rec.segment30    := hr_api.g_varchar2;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  return l_grp_rec;

exception
  when others then
  if g_debug then
     Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  end if;
  raise;

end Default_PpgFlx_Rec;
-- =============================================================================
-- Get_GrpRecord_Values:
-- =============================================================================
function Get_GrpRecord_Values
        (p_interface_code in varchar2 default null)
         return pay_people_groups%rowtype is

  cursor bne_cols(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.group_name = 'PEOPLE_KEYFLEX_GROUP'
     and bic.display_flag ='Y';
     --If the concat segments column is included then each segment value is assigned to the passed value.
     --The segments will always have display flag as 'N'

  l_proc_name    constant varchar2(150) := g_pkg||'Get_GrpRecord_Values';
  l_grp_rec      pay_people_groups%rowtype;
  col_name        varchar2(150);

begin
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  if g_sec_asg_flag <> 1 then
      l_grp_rec := Default_PpgFlx_Rec;
  else
      l_grp_rec := null;
  end if;
  for col_rec in bne_cols (g_interface_code)
  loop
   --$ Assign global values to the People Group segments
   case col_rec.interface_col_name
    when 'p_concat_segments' then
     l_grp_rec.group_name := g_grp_rec.group_name; --l_grp_rec.group_name;
    --when 'segment1' then
     l_grp_rec.segment1 := g_grp_rec.segment1;
    --when 'segment2' then
     l_grp_rec.segment2 := g_grp_rec.segment2;
    --when 'segment3' then
     l_grp_rec.segment3 := g_grp_rec.segment3;
    --when 'segment4' then
     l_grp_rec.segment4 := g_grp_rec.segment4;
    --when 'segment5' then
     l_grp_rec.segment5 := g_grp_rec.segment5;
    --when 'segment6' then
     l_grp_rec.segment6 := g_grp_rec.segment6;
    --when 'segment7' then
     l_grp_rec.segment7 := g_grp_rec.segment7;
    --when 'segment8' then
     l_grp_rec.segment8 := g_grp_rec.segment8;
    --when 'segment9' then
     l_grp_rec.segment9 := g_grp_rec.segment9;
    --when 'segment10' then
     l_grp_rec.segment10 := g_grp_rec.segment10;
    --when 'segment11' then
     l_grp_rec.segment11 := g_grp_rec.segment11;
    --when 'segment12' then
     l_grp_rec.segment12 := g_grp_rec.segment12;
    --when 'segment13' then
     l_grp_rec.segment13 := g_grp_rec.segment13;
    --when 'segment14' then
     l_grp_rec.segment14 := g_grp_rec.segment14;
    --when 'segment15' then
     l_grp_rec.segment15 := g_grp_rec.segment15;
    --when 'segment16' then
     l_grp_rec.segment16 := g_grp_rec.segment16;
    --when 'segment17' then
     l_grp_rec.segment17 := g_grp_rec.segment17;
    --when 'segment18' then
     l_grp_rec.segment18 := g_grp_rec.segment18;
    --when 'segment19' then
     l_grp_rec.segment19 := g_grp_rec.segment19;
    --when 'segment20' then
     l_grp_rec.segment20 := g_grp_rec.segment20;
    --when 'segment21' then
     l_grp_rec.segment21 := g_grp_rec.segment21;
    --when 'segment22' then
     l_grp_rec.segment22 := g_grp_rec.segment22;
    --when 'segment23' then
     l_grp_rec.segment23 := g_grp_rec.segment23;
    --when 'segment24' then
     l_grp_rec.segment24 := g_grp_rec.segment24;
    --when 'segment25' then
     l_grp_rec.segment25 := g_grp_rec.segment25;
    --when 'segment26' then
     l_grp_rec.segment26 := g_grp_rec.segment26;
    --when 'segment27' then
     l_grp_rec.segment27 := g_grp_rec.segment27;
    --when 'segment28' then
     l_grp_rec.segment28 := g_grp_rec.segment28;
    --when 'segment29' then
     l_grp_rec.segment29 := g_grp_rec.segment29;
    --when 'segment30' then
     l_grp_rec.segment30 := g_grp_rec.segment30;
   else
      null;
   end case;
  end loop;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  return l_grp_rec;

exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;

end Get_GrpRecord_Values;

-- =============================================================================
-- Default_Scflx_Rec:
-- =============================================================================
function Default_Scflx_Rec
         return hr_soft_coding_keyflex%rowtype is
  l_proc_name    constant varchar2(150) := g_pkg||'Default_Scflx_Rec';
  l_scl_rec     hr_soft_coding_keyflex%rowtype;
begin
  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
  /*
   ======================================================================
   g_varchar2 constant varchar2(9):= '$Sys_Def$';
   g_number constant number       := -987123654;
   g_date constant date           := to_date('01-01-4712','DD-MM-SYYYY');
   ======================================================================
  */
  l_scl_rec.concatenated_segments := hr_api.g_varchar2;
  l_scl_rec.segment1              := hr_api.g_varchar2;
  l_scl_rec.segment2              := hr_api.g_varchar2;
  l_scl_rec.segment3              := hr_api.g_varchar2;
  l_scl_rec.segment4              := hr_api.g_varchar2;
  l_scl_rec.segment5              := hr_api.g_varchar2;
  l_scl_rec.segment6              := hr_api.g_varchar2;
  l_scl_rec.segment7              := hr_api.g_varchar2;
  l_scl_rec.segment8              := hr_api.g_varchar2;
  l_scl_rec.segment9              := hr_api.g_varchar2;
  Hr_Utility.set_location(l_proc_name, 15);
  l_scl_rec.segment10             := hr_api.g_varchar2;
  l_scl_rec.segment11             := hr_api.g_varchar2;
  l_scl_rec.segment12             := hr_api.g_varchar2;
  l_scl_rec.segment13             := hr_api.g_varchar2;
  l_scl_rec.segment14             := hr_api.g_varchar2;
  l_scl_rec.segment15             := hr_api.g_varchar2;
  l_scl_rec.segment16             := hr_api.g_varchar2;
  l_scl_rec.segment17             := hr_api.g_varchar2;
  l_scl_rec.segment18             := hr_api.g_varchar2;
  l_scl_rec.segment19             := hr_api.g_varchar2;
  Hr_Utility.set_location(l_proc_name, 20);
  l_scl_rec.segment20             := hr_api.g_varchar2;
  l_scl_rec.segment21             := hr_api.g_varchar2;
  l_scl_rec.segment22             := hr_api.g_varchar2;
  l_scl_rec.segment23             := hr_api.g_varchar2;
  l_scl_rec.segment24             := hr_api.g_varchar2;
  l_scl_rec.segment25             := hr_api.g_varchar2;
  l_scl_rec.segment26             := hr_api.g_varchar2;
  l_scl_rec.segment27             := hr_api.g_varchar2;
  l_scl_rec.segment28             := hr_api.g_varchar2;
  l_scl_rec.segment29             := hr_api.g_varchar2;
  l_scl_rec.segment30             := hr_api.g_varchar2;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  return l_scl_rec;
exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;

end Default_Scflx_Rec;

-- =============================================================================
-- Get_ScflxRecord_Values:
-- =============================================================================
function Get_ScflxRecord_Values
        (p_interface_code in varchar2 default null)
         return hr_soft_coding_keyflex%rowtype is

  cursor bne_cols(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
         and bic.SEQUENCE_NUM between 222 and 252 --$ All soft coded KFF segments
   --  and (bic.group_name = 'SOFT_KEYFLEX_GROUP' or
    --      lower(bic.interface_col_name) ='p_gre');

      -- $ Commented this as segments value is not passed due to this flag
     and bic.display_flag ='Y'; --Select only those segments that the user has selected while function creation

  l_proc_name    constant varchar2(150) := g_pkg||'Get_ScflxRecord_Values';
  l_scl_rec      hr_soft_coding_keyflex%rowtype;
  col_name       varchar2(150);

begin
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  if g_sec_asg_flag <> 1 then
      l_scl_rec := Default_Scflx_Rec;
  else
      l_scl_rec := null;
  end if;

  for col_rec in bne_cols (g_interface_code)
  loop
   case col_rec.interface_col_name
    when 'p_soft_segments' then
     l_scl_rec.concatenated_segments := g_scl_rec.concatenated_segments;
    when 's_segment1' then
     l_scl_rec.segment1 := g_scl_rec.segment1;
    when 'p_gre' then
     l_scl_rec.segment1 := g_scl_rec.segment1;
    when 's_segment2' then
     l_scl_rec.segment2 := g_scl_rec.segment2;
    when 's_segment3' then
     l_scl_rec.segment3 := g_scl_rec.segment3;
    when 's_segment4' then
     l_scl_rec.segment4 := g_scl_rec.segment4;
    when 's_segment5' then
     l_scl_rec.segment5 := g_scl_rec.segment5;

    when 's_segment6' then
     l_scl_rec.segment6 := g_scl_rec.segment6;

    when 's_segment7' then
     l_scl_rec.segment7 := g_scl_rec.segment7;

    when 's_segment8' then
     l_scl_rec.segment8 := g_scl_rec.segment8;

    when 's_segment9' then
     l_scl_rec.segment9 := g_scl_rec.segment9;

    when 's_segment10' then
     l_scl_rec.segment10 := g_scl_rec.segment10;

    when 's_segment11' then
     l_scl_rec.segment11 := g_scl_rec.segment11;

    when 's_segment12' then
     l_scl_rec.segment12 := g_scl_rec.segment12;

    when 's_segment13' then
     l_scl_rec.segment13 := g_scl_rec.segment13;

    when 's_segment14' then
     l_scl_rec.segment14 := g_scl_rec.segment14;

    when 's_segment15' then
     l_scl_rec.segment15 := g_scl_rec.segment15;

    when 's_segment16' then
     l_scl_rec.segment16 := g_scl_rec.segment16;

    when 's_segment17' then
     l_scl_rec.segment17 := g_scl_rec.segment17;

    when 's_segment18' then
     l_scl_rec.segment18 := g_scl_rec.segment18;

    when 's_segment19' then
     l_scl_rec.segment19 := g_scl_rec.segment19;

    when 's_segment20' then
     l_scl_rec.segment20 := g_scl_rec.segment20;

    when 's_segment21' then
     l_scl_rec.segment21 := g_scl_rec.segment21;

    when 's_segment22' then
     l_scl_rec.segment22 := g_scl_rec.segment22;

    when 's_segment23' then
     l_scl_rec.segment23 := g_scl_rec.segment23;

    when 's_segment24' then
     l_scl_rec.segment24 := g_scl_rec.segment24;

    when 's_segment25' then
     l_scl_rec.segment25 := g_scl_rec.segment25;

    when 's_segment26' then
     l_scl_rec.segment26 := g_scl_rec.segment26;

    when 's_segment27' then
     l_scl_rec.segment27 := g_scl_rec.segment27;

    when 's_segment28' then
     l_scl_rec.segment28 := g_scl_rec.segment28;

    when 's_segment29' then
     l_scl_rec.segment29 := g_scl_rec.segment29;

    when 's_segment30' then
     l_scl_rec.segment30 := g_scl_rec.segment30;
   else
      null;
   end case;

  end loop;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  return l_scl_rec;

exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;

end Get_ScflxRecord_Values;
-- =============================================================================
-- Get_UnMasked_NI:
-- =============================================================================
function Get_UnMasked_NI
         (p_national_identifier     in varchar2
         ,p_batch_id                in number
         ,p_data_pump_batch_line_id in number
         ,p_web_adi_identifier      in varchar2
         )
         return varchar2 is


  csr_get_unmasked_ni          ref_cur_typ;

  l_proc_name    constant varchar2(150) :='Get_UnMasked_NI';
  l_dyn_sql_qry           varchar2(1000);
  l_national_identifier   per_all_people_f.national_identifier%type;

begin
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  if p_web_adi_identifier = 'DP ERROR' and
    (substrb(p_national_identifier, 1,
             lengthb(p_national_identifier) - 4) =  'XXX-XX-' or
     substrb(p_national_identifier, 3, 2) = 'XX'  or
     substrb(p_national_identifier, 1,
             lengthb(p_national_identifier) - 4) = 'XXXXX') then
     l_dyn_sql_qry :=
        ' select p_national_identifier
            from hrdpv_create_employee
           where batch_id = '   || p_batch_id  ||
          '  and link_value = ' || p_data_pump_batch_line_id ||
        ' union
          select p_national_identifier
            from hrdpv_update_person
           where batch_id = '   || p_batch_id     ||
          '  and link_value = ' || p_data_pump_batch_line_id;

      open  csr_get_unmasked_ni for l_dyn_sql_qry;
      fetch csr_get_unmasked_ni into l_national_identifier;
      close csr_get_unmasked_ni;
  else
      l_national_identifier := p_national_identifier;
  end if;
  if g_debug then
   Hr_Utility.set_location(' p_batch_id: '||p_batch_id, 50);
   Hr_Utility.set_location(' p_data_pump_batch_line_id: '||p_data_pump_batch_line_id, 50);
   Hr_Utility.set_location(' p_web_adi_identifier: '||p_web_adi_identifier, 50);
   Hr_Utility.set_location(' l_national_identifier: '||l_national_identifier, 50);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  end if;
  return l_national_identifier;

end Get_UnMasked_NI;

function Chk_Dup_Person
         (p_national_identifier in varchar2
         ,p_business_group_id   in number
         ,p_effective_date      in date
         ,p_dup_person_id       in number
         ) return number is

  cursor csr_chk_per_exists (c_business_group_id   in number
                            ,c_effective_date      in date) is
  select ppf.person_id
        ,ppf.business_group_id
        ,ppf.employee_number
        ,ppf.applicant_number
        ,ppf.npw_number
        ,ppf.party_id
    from per_all_people_f ppf
   where (ppf.date_of_birth = g_per_rec.date_of_birth
          or ppf.date_of_birth is null
          or g_per_rec.date_of_birth is null)
     and upper(ppf.last_name) = upper(g_per_rec.last_name)
     and (ppf.sex = g_per_rec.sex
          or ppf.sex is null
          or g_per_rec.sex is null)
     and ppf.business_group_id   = c_business_group_id
     and c_effective_date between ppf.effective_start_date
                              and ppf.effective_end_date;

  cursor csr_chk_per_exists_mig (c_business_group_id   in number
                            ,c_effective_date      in date) is
  select ppf.person_id
        ,ppf.business_group_id
        ,ppf.employee_number
        ,ppf.applicant_number
        ,ppf.npw_number
        ,ppf.party_id
    from per_all_people_f ppf
   where ppf.date_of_birth = g_per_rec.date_of_birth
     and upper(ppf.last_name) = upper(g_per_rec.last_name)
     and ppf.sex = g_per_rec.sex
     and ppf.business_group_id   = c_business_group_id
     and c_effective_date between ppf.effective_start_date
                              and ppf.effective_end_date;

 --l_per_rec      csr_chk_ni_exists%rowtype;
  --$
  l_per_exists   csr_chk_per_exists%rowtype;
  l_person_id    per_all_people_f.person_id%type := null;

  l_proc_name    constant varchar2(150) := g_pkg||'Chk_NI_Exists';

  begin

        if g_migration_flag = 'Y' then
        hr_utility.set_location('The migration flag is y', 78);
        open csr_chk_per_exists_mig (c_business_group_id   => p_business_group_id
                                ,c_effective_date      => p_effective_date);
        fetch csr_chk_per_exists_mig into l_per_exists;
        if csr_chk_per_exists_mig%found then
            hr_utility.trace('PERSON EXISTS');
            g_per_rec.person_id         := l_per_exists.person_id;
            g_per_rec.business_group_id := l_per_exists.business_group_id;
             --g_per_rec.employee_number   := l_per_rec.employee_number;
             --g_per_rec.applicant_number  := l_per_rec.applicant_number;
             --g_per_rec.npw_number        := l_per_rec.npw_number;
            g_per_rec.party_id          := l_per_exists.party_id;

            g_add_rec.person_id         := l_per_exists.person_id;
            g_add_rec.business_group_id := l_per_exists.business_group_id;
            g_add_rec.party_id          := l_per_exists.party_id;

            l_person_id := g_per_rec.person_id;
        end if;
        hr_utility.trace('PERSON DOES NOT EXIST');
        close csr_chk_per_exists_mig;
        else
                hr_utility.set_location('The migration flag is n', 78);
        open csr_chk_per_exists (c_business_group_id   => p_business_group_id
                                ,c_effective_date      => p_effective_date);
        fetch csr_chk_per_exists into l_per_exists;
        if csr_chk_per_exists%found then
           hr_utility.set_location('Records are found', 89);
           if csr_chk_per_exists%rowcount = 1 then
--hr_utility.trace('PERSON EXISTS');
            hr_utility.set_location('One record is found', 90);
            g_per_rec.person_id         := l_per_exists.person_id;
            g_per_rec.business_group_id := l_per_exists.business_group_id;
             --g_per_rec.employee_number   := l_per_rec.employee_number;
             --g_per_rec.applicant_number  := l_per_rec.applicant_number;
             --g_per_rec.npw_number        := l_per_rec.npw_number;
            g_per_rec.party_id          := l_per_exists.party_id;

            g_add_rec.person_id         := l_per_exists.person_id;
            g_add_rec.business_group_id := l_per_exists.business_group_id;
            g_add_rec.party_id          := l_per_exists.party_id;

            l_person_id := g_per_rec.person_id;
           else
            hr_utility.set_location('More than one record is found', 91);
            l_person_id := p_dup_person_id;
           end if;
       end if;
       hr_utility.trace('Code has come here');
       close csr_chk_per_exists;
      end if;

      hr_utility.set_location('The person id found is '||l_person_id, 92);
  return l_person_id;
end Chk_Dup_Person;
-- =============================================================================
-- Chk_NI_Exists: Check if NI entered already exists in the system, that implies
-- that user is accidently trying to enter a duplicate.
-- =============================================================================
function Chk_NI_Exists
         (p_national_identifier in varchar2
         ,p_business_group_id   in number
         ,p_effective_date      in date
         ,p_dup_person_id       in number
         ) return number is
  --
  -- Check for Ex-Emp, as we should allow a person to be rehired,
  -- that implies that NI for Ex-Emp may already exist.
  --
  cursor csr_chk_ni_exists (c_national_identifier in varchar2
                           ,c_business_group_id   in number
                           ,c_effective_date      in date) is
  select ppf.person_id
        ,ppf.business_group_id
        ,ppf.employee_number
        ,ppf.applicant_number
        ,ppf.npw_number
        ,ppf.party_id
    from per_all_people_f ppf
   where ppf.national_identifier = c_national_identifier
     and ppf.business_group_id   = c_business_group_id
     and c_effective_date between ppf.effective_start_date
                              and ppf.effective_end_date;

  l_per_rec      csr_chk_ni_exists%rowtype;
  --$
  --l_per_exists   csr_chk_per_exists%rowtype;
  l_person_id    per_all_people_f.person_id%type := null;

  l_proc_name    constant varchar2(150) := g_pkg||'Chk_NI_Exists';
begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);

 --$ If national identifier is available (for US legislation for e.g.)
 -- then use it to check if the person record exists or not
 -- else use Combination of person details to check the same
  if p_national_identifier is not null then

  --hr_utility.trace('NATIONAL IDENTIFIER AVAILABLE');
   hr_utility.set_location('The national identifier is found '||p_national_identifier, 78);
   hr_utility.set_location('The bg id found is '||p_business_group_id, 79);
   hr_utility.set_location('The date found is '||p_effective_date, 80);

  open  csr_chk_ni_exists(c_national_identifier => p_national_identifier
                         ,c_business_group_id   => p_business_group_id
                         ,c_effective_date      => p_effective_date);

  fetch csr_chk_ni_exists into l_per_rec;
  if csr_chk_ni_exists%found then
     hr_utility.set_location('Records are found ', 89);

        hr_utility.trace('PERSON EXISTS by NI');
         g_per_rec.person_id         := l_per_rec.person_id;
         g_per_rec.business_group_id := l_per_rec.business_group_id;
     --g_per_rec.employee_number   := l_per_rec.employee_number;
     --g_per_rec.applicant_number  := l_per_rec.applicant_number;
     --g_per_rec.npw_number        := l_per_rec.npw_number;
         g_per_rec.party_id          := l_per_rec.party_id;

         g_add_rec.person_id         := l_per_rec.person_id;
         g_add_rec.business_group_id := l_per_rec.business_group_id;
         g_add_rec.party_id          := l_per_rec.party_id;

         l_person_id := g_per_rec.person_id;
         hr_utility.set_location('The person id found is ' || l_person_id, 78);
     else
         hr_utility.set_location('No Match found', 22);
         l_person_id := Chk_Dup_Person
                                      (p_national_identifier => p_national_identifier
                                      ,p_business_group_id   => p_business_group_id
                                      ,p_effective_date      => p_effective_date
                                      ,p_dup_person_id       => p_dup_person_id
                                      );
  end if;
  close csr_chk_ni_exists;
  else
         l_person_id := Chk_Dup_Person
                             (p_national_identifier => p_national_identifier
                             ,p_business_group_id   => p_business_group_id
                             ,p_effective_date      => p_effective_date
                             ,p_dup_person_id       => p_dup_person_id
                             );

  end if;

  hr_utility.set_location('The person id found is '|| l_person_id, 66);
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

  return l_person_id ; --$ l_per_rec.person_id;

end Chk_NI_Exists;
-- =============================================================================
-- Get_WrkStrs_Names: The assignment DataPump api accepts name instead of ids
-- for work structures like grade, job, organization etc.
-- =============================================================================
procedure Get_WrkStrs_Names is
  l_proc_name  constant    varchar2(150):= g_pkg ||'Get_WrkStrs_Names';
  l_pay_basis_name         per_pay_bases.name%type;
  l_organization_name      hr_all_organization_units.name%type;
  l_location_code          hr_locations_all.location_code%type;
  l_payroll_name           pay_all_payrolls_f.payroll_name%type;
  l_job_name               per_jobs.name%type;
  l_position_name          hr_all_positions_f.name%type;
  l_grade_name             per_grades.name%type;
begin
  hr_utility.set_location('Entering: ' || l_proc_name, 5);
  g_wstr_names := null;
  -- Get grade name
  open  csr_grade(g_asg_rec.grade_id
                 ,g_asg_rec.business_group_id
                 ,g_per_rec.start_date);
  fetch csr_grade into l_grade_name;
  if csr_grade%notfound then
     hr_utility.set_location('..Grade Name not found Id: ' ||
                              g_asg_rec.grade_id, 6);
  else
     g_wstr_names.grade_name :=  l_grade_name;
  end if;
  close csr_grade;
  -- Get position name
  open  csr_position (g_asg_rec.position_id
                     ,g_asg_rec.business_group_id
                     ,g_per_rec.start_date);
  fetch csr_position into l_position_name;
  if csr_position%notfound then
     hr_utility.set_location('..Position Name not found Id: ' ||
                              g_asg_rec.position_id, 7);
  else
     g_wstr_names.position_name :=  l_position_name;
  end if;
  close csr_position;
  -- Get job name
  open  csr_job(g_asg_rec.job_id
               ,g_asg_rec.business_group_id
               ,g_per_rec.start_date);
  fetch csr_job into l_job_name;
  if csr_job%notfound then
     hr_utility.set_location('..Job Name not found Id: ' ||
                              g_asg_rec.job_id, 8);
  else
     g_wstr_names.job_name :=  l_job_name;
  end if;
  close csr_job;
  -- Get payroll name
  open  csr_payroll(g_asg_rec.payroll_id
                   ,g_asg_rec.business_group_id
                   ,g_per_rec.start_date);
  fetch csr_payroll into l_payroll_name;
  if csr_payroll%notfound then
     hr_utility.set_location('..Payroll Name not found Id: ' ||
                              g_asg_rec.payroll_id, 9);
  else
     g_wstr_names.payroll_name :=  l_payroll_name;
  end if;
  close csr_payroll;
  -- Get location code
  open  csr_location(g_asg_rec.location_id
                    ,g_asg_rec.business_group_id);
  fetch csr_location into l_location_code;
  if csr_location%notfound then
     hr_utility.set_location('..Location Code not found, Id: ' ||
                              g_asg_rec.location_id, 10);
  else
     g_wstr_names.location_code :=  l_location_code;
  end if;
  close csr_location;
  -- Get organization name
  open  csr_organization(g_asg_rec.organization_id
                        ,g_asg_rec.business_group_id
                        ,g_per_rec.start_date);
  fetch csr_organization into l_organization_name;
  if csr_organization%notfound then
     hr_utility.set_location('..Org Name not found, Id: ' ||
                              g_asg_rec.organization_id, 11);
  else
     g_wstr_names.organization_name :=  l_organization_name;
  end if;
  close csr_organization;
  -- Get pay basis name
  open  csr_paybasis(g_asg_rec.pay_basis_id
                    ,g_asg_rec.business_group_id);
  fetch csr_paybasis into l_pay_basis_name;
  if csr_paybasis%notfound then
     hr_utility.set_location('..Org Name not found, Id: ' ||
                              g_asg_rec.pay_basis_id, 12);
  else
     g_wstr_names.pay_basis_name :=  l_pay_basis_name;
  end if;
  close csr_paybasis;

  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

end Get_WrkStrs_Names;
-- =============================================================================
-- ~ EmpAplCwk_NumGen:
-- =============================================================================
procedure EmpAplCwk_NumGen
         (p_employee_number  in varchar2
         ,p_applicant_number in varchar2
         ,p_cwk_number       in varchar2
         ) is
  l_proc_name  constant    varchar2(150):= g_pkg ||'EmpAplCwk_NumGen';
begin
  hr_utility.set_location('Entering: ' || l_proc_name, 5);
  if g_emp_num_gen <> 'A' then
    g_per_rec.employee_number := p_employee_number;
  else
    g_per_rec.employee_number := null;
  end if;

  if g_apl_num_gen <> 'A' then
    g_per_rec.applicant_number := p_applicant_number;
  else
    g_per_rec.applicant_number := null;
  end if;

  if g_cwk_num_gen <> 'A' then
    g_per_rec.npw_number := p_cwk_number;
  else
    g_per_rec.npw_number := null;
  end if;
  if g_debug then
     hr_utility.set_location(' p_employee_number : ' || p_employee_number, 6);
     hr_utility.set_location(' p_applicant_number: ' || p_applicant_number, 6);
     hr_utility.set_location(' p_cwk_number      : ' || p_cwk_number, 6);
     hr_utility.set_location(' g_emp_num_gen: ' || g_emp_num_gen, 6);
     hr_utility.set_location(' g_apl_num_gen: ' || g_apl_num_gen, 6);
     hr_utility.set_location(' g_cwk_num_gen: ' || p_cwk_number, 6);
  end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 80);
end EmpAplCwk_NumGen;
-- =============================================================================
-- ~ Get_DataTrack_Mode:
-- =============================================================================
procedure Get_DataTrack_Mode
          (p_datetrack_update_mode out nocopy varchar2
          ) is
  l_cur_per_rec            csr_per%rowtype;
  l_ptu_rec                chk_perType_usage%rowtype;
  l_datetrack_update_mode  varchar2(50);
  l_dt_correction          boolean;
  l_dt_update              boolean;
  l_dt_upd_override        boolean;
  l_upd_chg_ins            boolean;
  l_error_msg              varchar2(2000);
  l_proc_name  constant    varchar2(150):= g_pkg ||'Get_DataTrack_Mode';
  e_future_chgs_exists     exception;
begin
  hr_utility.set_location('Entering: ' || l_proc_name, 5);
  if g_per_rec.person_id is not null then
    open  csr_per(c_person_id         => g_per_rec.person_id
                 ,c_business_group_id => g_per_rec.business_group_id
                 ,c_effective_date    => g_per_rec.start_date);
    fetch csr_per into l_cur_per_rec;
    close csr_per;
    hr_utility.set_location(' l_cur_per_rec: ' || l_cur_per_rec.person_id, 20);

    Dt_Api.Find_DT_Upd_Modes
    (p_effective_date        => g_per_rec.start_date
    ,p_base_table_name       => 'PER_ALL_PEOPLE_F'
    ,p_base_key_column       => 'PERSON_ID'
    ,p_base_key_value        => l_cur_per_rec.person_id
    ,p_correction            => l_dt_correction
    ,p_update                => l_dt_update
    ,p_update_override       => l_dt_upd_override
    ,p_update_change_insert  => l_upd_chg_ins
     );

    if l_dt_update then
       l_datetrack_update_mode := 'UPDATE';
    elsif l_dt_upd_override or
          l_upd_chg_ins then
          -- Need to check if person type in future is EMP, APL or CWK , if yes
          -- then raise error
          open chk_perType_usage
             (c_person_id         => l_cur_per_rec.person_id
             ,c_effective_date    => g_per_rec.start_date
             ,c_business_group_id => g_per_rec.business_group_id);

          fetch chk_perType_usage into l_ptu_rec;
          if chk_perType_usage%found then
             close chk_perType_usage;
             raise e_future_chgs_exists;
          end if;
          close chk_perType_usage;
         --Else USE Correction Mode
        l_datetrack_update_mode := 'CORRECTION';
    else
       l_datetrack_update_mode := 'CORRECTION';
    end if;

    hr_utility.set_location('l_datetrack_update_mode: ' ||
                             l_datetrack_update_mode, 30);
    g_per_rec.object_version_number := l_cur_per_rec.object_version_number;
    EmpAplCwk_NumGen
    (p_employee_number  => nvl(l_cur_per_rec.employee_number,
                               g_per_rec.employee_number)
    ,p_applicant_number => nvl(l_cur_per_rec.applicant_number,
                               g_per_rec.applicant_number)
    ,p_cwk_number       => nvl(l_cur_per_rec.npw_number,
                               g_per_rec.npw_number)
     );
  end if;
  hr_utility.set_location('Leaving: ' || l_proc_name, 80);
exception
  when e_future_chgs_exists then
    l_error_msg :=
       'This person cannot be created/updated in HRMS as the '||
       'Person has future changes beyond the date: '||g_per_rec.start_date;

    hr_utility.set_location('..Future Update exists for the Student Employee', 90);
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_location('Leaving: ' || l_proc_name, 90);
    hr_utility.raise_error;

end Get_DataTrack_Mode;
-- =============================================================================
-- Chk_Person_InHR:
-- =============================================================================
procedure Chk_Person_InHR
         (p_dup_person_id        in number
         ,p_dup_party_id         in number
         ,p_effective_date       in date
         ,p_business_group_id    in number
         ,p_Input_PerType        out nocopy varchar2
         ,p_hire_Into_Employee   out nocopy boolean
         ,p_Hire_Applicant       out nocopy boolean
         ,p_Convert_To_Applicant out nocopy boolean
         ,p_Apply_For_Job        out nocopy boolean
         ,p_Convert_To_CWK       out nocopy boolean
         ,p_Per_Exists_InHR      out nocopy boolean
         ) is

  cursor csr_type (c_person_type_id in number) is
  select *
    from per_person_types
   where person_type_id = c_person_type_id
     and business_group_id = p_business_group_id;

  l_pty_rec     csr_type%rowtype;

  cursor chk_party (c_party_id       in number
                   ,c_bg_grp_id      in number
                   ,c_person_id      in number
                   ,c_effective_date in date) is
  select ppt.system_person_type
        ,ppt.user_person_type
        ,ppf.effective_start_date
        ,ppf.effective_end_date
        ,ppf.employee_number
        ,ppf.applicant_number
        ,ppf.npw_number
        ,ptu.person_type_id
        ,ppf.person_id
        ,ppf.object_version_number
    from per_all_people_f         ppf
        ,per_person_type_usages_f ptu
        ,per_person_types         ppt
   where ptu.person_type_id = ppf.person_type_id
     and ppt.person_type_id = ptu.person_type_id
     and ppt.business_group_id = ppf.business_group_id
     and ppf.business_group_id = c_bg_grp_id
     and ((c_person_id is not null and ppf.person_id = c_person_id) or
          (c_party_id  is not null and ppf.party_id = c_party_id))
     and c_effective_date between ppf.effective_start_date
                              and ppf.effective_end_date
     and c_effective_date between ptu.effective_start_date
                              and ptu.effective_end_date;

  l_chk_per              chk_party%rowtype;
  l_error_msg            varchar2(2000);
  --
  -- Exceptions
  --
  e_InValid_PerType_Id   exception;
  e_active_empcwk        exception;
  e_active_apl           exception;
  l_person_id            per_all_people_f.person_id%type;
  l_party_id             per_all_people_f.person_id%type;
  l_user_person_type     per_person_types.user_person_type%TYPE;
  l_effective_date       date;
  l_proc_name  constant  varchar2(150):= g_pkg ||'Chk_Person_InHR';
begin
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
    --hr_utility.trace('Inside Chk_Person_InHR');

   open csr_type(g_per_rec.person_type_id);
  fetch csr_type into l_pty_rec;
  close csr_type;

  p_hire_Into_Employee   := false;
  p_Convert_To_Applicant := false;
  p_Convert_To_CWK       := false;
  p_Per_Exists_InHR      := false;
  p_Hire_Applicant       := false;
  p_Apply_For_Job        := false;

  if l_pty_rec.system_person_type is null then
     l_error_msg :=
     'Invalid person type passed. Please select a valid person type.';
     raise e_InValid_PerType_Id;
  end if;

  p_Input_PerType := l_pty_rec.system_person_type;
  l_person_id     := p_dup_person_id;
  l_party_id      := p_dup_party_id;


  if l_person_id is null then
    l_person_id := Chk_NI_Exists
                  (p_national_identifier => g_per_rec.national_identifier
                  ,p_business_group_id   => p_business_group_id
                  ,p_effective_date      => p_effective_date
                  ,p_dup_person_id       => p_dup_person_id
                   );
  end if;

  if l_party_id is null then
     l_party_id := g_per_rec.party_id;
  else
     g_per_rec.party_id := l_party_id;
  end if;


  if (l_person_id is not null or
        l_party_id  is not null) then

      --
      -- Loop thru all the person types that person has as of the
      -- effective date he is being created/updated in HRMS.
      --
            for per_rec in chk_party
                          (c_party_id       => l_party_id
                          ,c_bg_grp_id      => p_business_group_id
                          ,c_person_id      => l_person_id
                          ,c_effective_date => p_effective_date)
      loop


        g_per_rec.person_id := per_rec.person_id;
        if l_pty_rec.system_person_type = 'EMP' then
           -- If person is EMP or CWK raise an error
           if per_rec.system_person_type = 'CWK' then
              l_error_msg :=
              'Person already exits as an: '||per_rec.user_person_type||
              ' as of the '||p_effective_date;
              raise e_active_empcwk;
           elsif per_rec.system_person_type = ('EMP') then
              l_user_person_type := per_rec.user_person_type;
              l_effective_date   := p_effective_date;
              p_Input_PerType := 'UPD_PERSON';
           elsif per_rec.system_person_type in ('EX_EMP','EX_CWK'
                                               ,'EX_APL','OTHER') then
              p_hire_Into_Employee := true;
           elsif per_rec.system_person_type in ('APL') then
              p_hire_Applicant := true;
           end if;

        elsif l_pty_rec.system_person_type = 'APL' then
           -- If perosn is APL, the update person details
           if per_rec.system_person_type in ('APL') then
              l_error_msg :=
              'Person already exits as an: '||per_rec.user_person_type||
              ' as of the '||p_effective_date;
              l_user_person_type := per_rec.user_person_type;
              l_effective_date   := p_effective_date;
              p_Input_PerType := 'UPD_PERSON';
           elsif per_rec.system_person_type in ('EX_EMP','EX_CWK'
                                               ,'EX_APL','OTHER') then
              p_Convert_To_Applicant := true;

           elsif per_rec.system_person_type in ('CWK','EMP') then
              p_Apply_For_Job := true;

           end if;

        elsif l_pty_rec.system_person_type = 'CWK' then
           -- If person is CWK raise error
           if per_rec.system_person_type = 'EMP' then
              l_error_msg :=
              'Person already exits as an: '||per_rec.user_person_type||
              ' as of the '||p_effective_date;
              l_user_person_type := per_rec.user_person_type;
              l_effective_date   := p_effective_date;
              raise e_active_empcwk;
           elsif per_rec.system_person_type = 'CWK' then
              l_user_person_type := per_rec.user_person_type;
              l_effective_date   := p_effective_date;
              p_Input_PerType    := 'UPD_PERSON';

           elsif per_rec.system_person_type in ('EX_EMP','EX_CWK','APL'
                                               ,'EX_APL','OTHER') then
              p_Convert_To_CWK := true;
           end if;

        elsif l_pty_rec.system_person_type = 'OTHER' then
              p_Per_Exists_InHR := true;
        end if;

      end loop;
  end if;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

exception
  when e_InValid_PerType_Id then
    hr_utility.set_message(8303, 'PQP_230492_RIW_INVAL_PER_TYPE');
    hr_utility.set_location('Leaving: ' || l_proc_name, 90);
    hr_utility.raise_error;

  when e_active_empcwk then
    hr_utility.set_message(8303, 'PQP_230493_RIW_PERSON_EXISTS');
    hr_utility.set_message_token('TOKEN1',l_user_person_type );
    hr_utility.set_message_token('TOKEN2',l_effective_date );
    hr_utility.set_location('Leaving: ' || l_proc_name, 90);
    hr_utility.raise_error;

  when e_active_apl then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
    hr_utility.set_location('Leaving: ' || l_proc_name, 90);
    hr_utility.raise_error;

  when Others then
  hr_utility.set_location('SQLERRM[CODE] :' || SQLCODE,90);
  hr_utility.set_location('Leaving: ' || l_proc_name, 90);
  raise;

end Chk_Person_InHR;

-- =============================================================================
-- ~ Upd_Applicant_Asg :
-- =============================================================================
procedure Upd_Applicant_Asg
         (p_effective_date in date
         ,p_asg_crit_out   in out NOCOPY t_AsgUpdCrit_Api
         --,p_UpdEmpAsg_out  IN OUT NOCOPY t_Upd_Emp_Asg_Api
          ) as

  -- Cursor to get Assignment details
  cursor csr_asg (c_effective_date in date
                 ,c_assignment_id  in number
                 ,c_business_group_id in number)is
  select *
    from per_all_assignments_f paf
   where paf.assignment_id = c_assignment_id
     and paf.business_group_id = c_business_group_id
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;

  l_cur_asg_rec            csr_asg%rowtype;

  -- Cursor to get people group flexfield details
  cursor csr_ppg (c_people_grp_id in number) is
  select *
    from pay_people_groups
   where people_group_id = c_people_grp_id;

  l_cur_ppl_grp_rec        pay_people_groups%rowtype;

  -- Cursor to get Soft coding flexfield details
  cursor csr_scl (c_scl_kff_id in number) is
  select *
    from hr_soft_coding_keyflex
   where soft_coding_keyflex_id = c_scl_kff_id;

  l_cur_scl_rec        hr_soft_coding_keyflex%rowtype;

  l_proc_name  constant    varchar2(150):= g_pkg ||'Upd_Applicant_Asg';
  l_error_msg              varchar2(2000);
  l_datetrack_update_mode  varchar2(50);
  l_dt_correction          boolean;
  l_dt_update              boolean;
  l_dt_upd_override        boolean;
  l_upd_chg_ins            boolean;
  e_empasg_notfound        exception;
  l_UpdEmpAsg_out          t_Upd_Emp_Asg_Api;
  l_asg_rec                per_all_assignments_f%rowtype;
  l_grp_rec                pay_people_groups%rowtype;
  l_scl_rec                hr_soft_coding_keyflex%rowtype;
  l_expected_system_status varchar2(20);
  l_return_status          varchar2(100);

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  l_asg_rec := Get_AsgRecord_Values(g_interface_code);
  l_grp_rec := Get_GrpRecord_Values(g_interface_code);
  l_scl_rec := Get_ScflxRecord_Values(g_interface_code);

  open  csr_asg (c_effective_date    => p_effective_date
                ,c_assignment_id     => g_asg_rec.assignment_id
                ,c_business_group_id => g_asg_rec.business_group_id
                 );
  fetch csr_asg into l_cur_asg_rec;
  if csr_asg%notfound then
     close csr_asg;
     raise e_empasg_notfound;
  end if;
  close csr_asg;
  hr_utility.set_location(' l_cur_asg_rec: ' || p_effective_date, 20);
  hr_utility.set_location(' l_cur_asg_rec: ' || g_asg_rec.assignment_id, 20);
  hr_utility.set_location(' l_cur_asg_rec: ' || g_asg_rec.business_group_id, 20);
  --
  -- Check is the People Group Id is passed
  --
  open  csr_ppg(c_people_grp_id => g_asg_rec.people_group_id);
  fetch csr_ppg into l_cur_ppl_grp_rec;
 --$ Do not assign people group id from existing record but from the combination
   -- of the segments obtained from user
   if csr_ppg%found then
     p_asg_crit_out.people_group_id := g_asg_rec.people_group_id;
     l_asg_rec.people_group_id := g_asg_rec.people_group_id;

  /*if csr_ppg%notfound then
     g_asg_rec.people_group_id
       := l_cur_asg_rec.people_group_id;
     l_asg_rec.people_group_id
       := l_cur_asg_rec.people_group_id;*/

  end if;
  close csr_ppg;
  hr_utility.set_location(' people_group_id: ' || g_asg_rec.people_group_id, 30);
  --
  -- check if the Soft-Coding KFF id is passed
  --
  open  csr_scl(c_scl_kff_id => g_asg_rec.soft_coding_keyflex_id);
  fetch csr_scl into l_cur_scl_rec;
  --$ Do not assign soft keyflex id from existing record but from the combination
   -- of the segments obtained from user
 if csr_scl%found then
     p_asg_crit_out.soft_coding_keyflex_id := g_asg_rec.soft_coding_keyflex_id;
     l_asg_rec.soft_coding_keyflex_id := g_asg_rec.soft_coding_keyflex_id;
 /*   if csr_scl%notfound then
     g_asg_rec.soft_coding_keyflex_id
       := l_cur_asg_rec.soft_coding_keyflex_id;
     l_asg_rec.soft_coding_keyflex_id
       := l_cur_asg_rec.soft_coding_keyflex_id; */

  end if;

  close csr_scl;
  hr_utility.set_location(' soft_coding_keyflex_id: ' ||
                            g_asg_rec.soft_coding_keyflex_id, 40);
  --
  -- Get the datetrack mode based on the effective date passed
  --
  Dt_Api.Find_DT_Upd_Modes
  (p_effective_date        =>  p_effective_date
  ,p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F'
  ,p_base_key_column       => 'ASSIGNMENT_ID'
  ,p_base_key_value        => g_asg_rec.assignment_id
  ,p_correction            => l_dt_correction
  ,p_update                => l_dt_update
  ,p_update_override       => l_dt_upd_override
  ,p_update_change_insert  => l_upd_chg_ins
   );

  if l_dt_update then
     l_datetrack_update_mode := 'UPDATE';
  elsif l_dt_upd_override or
        l_upd_chg_ins then
             --Else USE Correction Mode
        l_datetrack_update_mode := 'CORRECTION';
     hr_utility.set_location(' l_dt_upd_override or l_upd_chg_ins ', 50);
  else
     l_datetrack_update_mode := 'CORRECTION';
  end if;
  hr_utility.set_location(' l_datetrack_update_mode: ' ||
                            l_datetrack_update_mode, 60);

  g_asg_rec.cagr_grade_def_id := nvl(g_asg_rec.cagr_grade_def_id,
                                     l_cur_asg_rec.cagr_grade_def_id);
  l_asg_rec.cagr_grade_def_id := g_asg_rec.cagr_grade_def_id;

-- added by psengupt
-- first we need to change the assignment status using hr_assignment_internal package
--then change the other assignment details
   Select PER_SYSTEM_STATUS into l_expected_system_status
     from per_assignment_status_types
    where assignment_status_type_id = l_asg_rec.assignment_status_type_id;

       hr_assignment_swi.update_apl_asg
  (p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_assignment_id                => g_asg_rec.assignment_id
  ,p_object_version_number        => l_cur_asg_rec.object_version_number
  ,p_recruiter_id                 => l_cur_asg_rec.recruiter_id
  ,p_grade_id                     => l_asg_rec.grade_id
  ,p_position_id                  => l_asg_rec.position_id
  ,p_job_id                       => l_asg_rec.job_id
  ,p_payroll_id                   => l_asg_rec.payroll_id
  ,p_location_id                  => l_asg_rec.location_id
  ,p_organization_id              => l_asg_rec.organization_id
  ,p_assignment_status_type_id    => l_asg_rec.assignment_status_type_id
  ,p_person_referred_by_id        => l_cur_asg_rec.person_referred_by_id
  ,p_supervisor_id                => l_asg_rec.supervisor_id
  ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
  ,p_source_organization_id       => l_asg_rec.source_organization_id
  ,p_recruitment_activity_id      => l_cur_asg_rec.recruitment_activity_id
  ,p_vacancy_id                   => l_cur_asg_rec.vacancy_id
  ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
  ,p_application_id               => l_cur_asg_rec.application_id
  ,p_change_reason                => l_asg_rec.change_reason
  ,p_comments                     => g_asg_comments
  ,p_date_probation_end           => l_asg_rec.date_probation_end
  ,p_default_code_comb_id         => l_asg_rec.default_code_comb_id
  ,p_employment_category          => l_asg_rec.employment_category
  ,p_frequency                    => l_asg_rec.frequency
  ,p_normal_hours                 => l_asg_rec.normal_hours
  ,p_internal_address_line        => l_asg_rec.internal_address_line
  ,p_manager_flag                 => l_asg_rec.manager_flag
  ,p_probation_period             => l_asg_rec.probation_period
  ,p_probation_unit               => l_asg_rec.probation_unit
  ,p_perf_review_period           => l_asg_rec.perf_review_period
  ,p_perf_review_period_frequency => l_asg_rec.perf_review_period_frequency
  ,p_sal_review_period            => l_asg_rec.sal_review_period
  ,p_sal_review_period_frequency  => l_asg_rec.sal_review_period_frequency
  ,p_set_of_books_id              => l_asg_rec.set_of_books_id
  ,p_source_type                  => l_asg_rec.source_type
  ,p_bargaining_unit_code         => l_asg_rec.bargaining_unit_code
  ,p_time_normal_finish           => l_asg_rec.time_normal_finish
  ,p_time_normal_start            => l_asg_rec.time_normal_start
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
  ,p_title                        => l_asg_rec.title
  ,p_concatenated_segments        => l_UpdEmpAsg_out.concatenated_segments
  ,p_contract_id                  => l_asg_rec.contract_id
  ,p_establishment_id             => l_asg_rec.establishment_id
  ,p_job_post_source_name         => l_asg_rec.job_post_source_name
  ,p_posting_content_id           => l_asg_rec.posting_content_id
  ,p_applicant_rank               => l_asg_rec.applicant_rank
  ,p_cagr_grade_def_id            => g_asg_rec.cagr_grade_def_id
  --,p_collective_agreement_id      in     number    default hr_api.g_number
  ,p_notice_period                => l_asg_rec.notice_period
  ,p_notice_period_uom            => l_asg_rec.notice_period_uom
  ,p_employee_category            => l_asg_rec.employee_category
  ,p_work_at_home                 => l_asg_rec.work_at_home
  ,p_cagr_concatenated_segments   => l_UpdEmpAsg_out.cagr_concatenated_segments
  ,p_group_name                   => l_UpdEmpAsg_out.concatenated_segments
  ,p_comment_id                   => l_UpdEmpAsg_out.comment_id
  ,p_effective_start_date         => l_UpdEmpAsg_out.effective_start_date
  ,p_effective_end_date           => l_UpdEmpAsg_out.effective_end_date
  ,p_people_group_id              => g_asg_rec.people_group_id
  ,p_soft_coding_keyflex_id       => g_asg_rec.soft_coding_keyflex_id
  ,p_return_status                => l_return_status
  );


  /* if l_expected_system_status = 'TERM_APL' then
       hr_assignment_api.terminate_apl_asg
              (p_validate                   => false
              ,p_effective_date             => p_effective_date
              ,p_assignment_id              => g_asg_rec.assignment_id
              ,p_assignment_status_type_id  => l_asg_rec.assignment_status_type_id
              ,p_object_version_number      => l_cur_asg_rec.object_version_number
              ,p_effective_start_date       => l_UpdEmpAsg_out.effective_start_date
              ,p_effective_end_date         => l_UpdEmpAsg_out.effective_end_date
              );
   else
       hr_utility.set_location('Inside Update Assignment :'||l_asg_rec.assignment_status_type_id, 8);
       hr_assignment_internal.update_status_type_apl_asg
              (p_effective_date             => p_effective_date
              ,p_datetrack_update_mode      => l_datetrack_update_mode
              ,p_assignment_id              => g_asg_rec.assignment_id
              ,p_object_version_number      => l_cur_asg_rec.object_version_number
              ,p_expected_system_status     => l_expected_system_status
              ,p_assignment_status_type_id  => l_asg_rec.assignment_status_type_id
              ,p_change_reason              => l_asg_rec.change_reason
              ,p_effective_start_date       => l_UpdEmpAsg_out.effective_start_date
              ,p_effective_end_date         => l_UpdEmpAsg_out.effective_end_date
              );
   end if;

  Dt_Api.Find_DT_Upd_Modes
  (p_effective_date        =>  p_effective_date
  ,p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F'
  ,p_base_key_column       => 'ASSIGNMENT_ID'
  ,p_base_key_value        => g_asg_rec.assignment_id
  ,p_correction            => l_dt_correction
  ,p_update                => l_dt_update
  ,p_update_override       => l_dt_upd_override
  ,p_update_change_insert  => l_upd_chg_ins
   );

  if l_dt_update then
     l_datetrack_update_mode := 'UPDATE';
  elsif l_dt_upd_override or
        l_upd_chg_ins then
             --Else USE Correction Mode
        l_datetrack_update_mode := 'CORRECTION';
     hr_utility.set_location(' l_dt_upd_override or l_upd_chg_ins ', 50);
  else
     l_datetrack_update_mode := 'CORRECTION';
  end if;


--l_asg_rec.application_id := 1103;
 --l_asg_rec.application_id := l_cur_asg_rec.application_id; -- Changed By Dbansal

  --$ replace l_asg_rec with l_cur_asg_rec
  HR_Assignment_API.Update_APL_Asg
  (p_validate                     => false
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_assignment_id                => g_asg_rec.assignment_id
  ,p_recruiter_id                 => l_cur_asg_rec.recruiter_id
  ,p_recruitment_activity_id      => l_cur_asg_rec.recruitment_activity_id
  ,p_person_referred_by_id        => l_cur_asg_rec.person_referred_by_id
  ,p_vacancy_id                   => l_cur_asg_rec.vacancy_id
  ,p_application_id               => l_cur_asg_rec.application_id
  ,p_grade_id                     => l_asg_rec.grade_id
  ,p_position_id                  => l_asg_rec.position_id
  ,p_job_id                       => l_asg_rec.job_id
  ,p_payroll_id                   => l_asg_rec.payroll_id
  ,p_location_id                  => l_asg_rec.location_id
  ,p_organization_id              => l_asg_rec.organization_id
  ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
  ,p_assignment_status_type_id    => l_asg_rec.assignment_status_type_id
  ,p_supervisor_id                => l_asg_rec.supervisor_id
  ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
  ,p_source_organization_id       => l_asg_rec.source_organization_id
  ,p_employment_category          => l_asg_rec.employment_category
  ,p_frequency                    => l_asg_rec.frequency
  ,p_normal_hours                 => l_asg_rec.normal_hours
  ,p_time_normal_finish           => l_asg_rec.time_normal_finish
  ,p_time_normal_start            => l_asg_rec.time_normal_start
  ,p_probation_period             => l_asg_rec.probation_period
  ,p_probation_unit               => l_asg_rec.probation_unit
  ,p_perf_review_period           => l_asg_rec.perf_review_period
  ,p_perf_review_period_frequency => l_asg_rec.perf_review_period_frequency
  ,p_sal_review_period            => l_asg_rec.sal_review_period
  ,p_sal_review_period_frequency  => l_asg_rec.sal_review_period_frequency
  ,p_change_reason                => l_asg_rec.change_reason
  ,p_notice_period                => l_asg_rec.notice_period
  ,p_notice_period_uom            => l_asg_rec.notice_period_uom
  ,p_employee_category            => l_asg_rec.employee_category
  ,p_work_at_home                 => l_asg_rec.work_at_home
  --$
  ,p_comments                     => g_asg_comments
  ,p_date_probation_end           => l_asg_rec.date_probation_end
  ,p_default_code_comb_id         => l_asg_rec.default_code_comb_id
  ,p_internal_address_line        => l_asg_rec.internal_address_line
  ,p_manager_flag                 => l_asg_rec.manager_flag
  ,p_set_of_books_id              => l_asg_rec.set_of_books_id
  ,p_source_type                  => l_asg_rec.source_type
  ,p_bargaining_unit_code         => l_asg_rec.bargaining_unit_code
  -- Asg DF
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
  ,p_title                        => l_asg_rec.title
  -- Asg Soft Coding KFF
  ,p_scl_segment1                 => l_scl_rec.segment1
  ,p_scl_segment2                 => l_scl_rec.segment2
  ,p_scl_segment3                 => l_scl_rec.segment3
  ,p_scl_segment4                 => l_scl_rec.segment4
  ,p_scl_segment5                 => l_scl_rec.segment5
  ,p_scl_segment6                 => l_scl_rec.segment6
  ,p_scl_segment7                 => l_scl_rec.segment7
  ,p_scl_segment8                 => l_scl_rec.segment8
  ,p_scl_segment9                 => l_scl_rec.segment9
  ,p_scl_segment10                => l_scl_rec.segment10
  ,p_scl_segment11                => l_scl_rec.segment11
  ,p_scl_segment12                => l_scl_rec.segment12
  ,p_scl_segment13                => l_scl_rec.segment13
  ,p_scl_segment14                => l_scl_rec.segment14
  ,p_scl_segment15                => l_scl_rec.segment15
  ,p_scl_segment16                => l_scl_rec.segment16
  ,p_scl_segment17                => l_scl_rec.segment17
  ,p_scl_segment18                => l_scl_rec.segment18
  ,p_scl_segment19                => l_scl_rec.segment19
  ,p_scl_segment20                => l_scl_rec.segment20
  ,p_scl_segment21                => l_scl_rec.segment21
  ,p_scl_segment22                => l_scl_rec.segment22
  ,p_scl_segment23                => l_scl_rec.segment23
  ,p_scl_segment24                => l_scl_rec.segment24
  ,p_scl_segment25                => l_scl_rec.segment25
  ,p_scl_segment26                => l_scl_rec.segment26
  ,p_scl_segment27                => l_scl_rec.segment27
  ,p_scl_segment28                => l_scl_rec.segment28
  ,p_scl_segment29                => l_scl_rec.segment29
  ,p_scl_segment30                => l_scl_rec.segment30
  --,p_scl_concat_segments          => g_scl_rec.
  -- People Group KFF
  ,p_pgp_segment1                 => l_grp_rec.segment1
  ,p_pgp_segment2                 => l_grp_rec.segment2
  ,p_pgp_segment3                 => l_grp_rec.segment3
  ,p_pgp_segment4                 => l_grp_rec.segment4
  ,p_pgp_segment5                 => l_grp_rec.segment5
  ,p_pgp_segment6                 => l_grp_rec.segment6
  ,p_pgp_segment7                 => l_grp_rec.segment7
  ,p_pgp_segment8                 => l_grp_rec.segment8
  ,p_pgp_segment9                 => l_grp_rec.segment9
  ,p_pgp_segment10                => l_grp_rec.segment10
  ,p_pgp_segment11                => l_grp_rec.segment11
  ,p_pgp_segment12                => l_grp_rec.segment12
  ,p_pgp_segment13                => l_grp_rec.segment13
  ,p_pgp_segment14                => l_grp_rec.segment14
  ,p_pgp_segment15                => l_grp_rec.segment15
  ,p_pgp_segment16                => l_grp_rec.segment16
  ,p_pgp_segment17                => l_grp_rec.segment17
  ,p_pgp_segment18                => l_grp_rec.segment18
  ,p_pgp_segment19                => l_grp_rec.segment19
  ,p_pgp_segment20                => l_grp_rec.segment20
  ,p_pgp_segment21                => l_grp_rec.segment21
  ,p_pgp_segment22                => l_grp_rec.segment22
  ,p_pgp_segment23                => l_grp_rec.segment23
  ,p_pgp_segment24                => l_grp_rec.segment24
  ,p_pgp_segment25                => l_grp_rec.segment25
  ,p_pgp_segment26                => l_grp_rec.segment26
  ,p_pgp_segment27                => l_grp_rec.segment27
  ,p_pgp_segment28                => l_grp_rec.segment28
  ,p_pgp_segment29                => l_grp_rec.segment29
  ,p_pgp_segment30                => l_grp_rec.segment30
  ,p_concat_segments                => l_grp_rec.group_name

  ,p_contract_id                  => l_asg_rec.contract_id
  ,p_establishment_id             => l_asg_rec.establishment_id
  ,p_job_post_source_name         => l_asg_rec.job_post_source_name
  ,p_posting_content_id           => l_asg_rec.posting_content_id
  ,p_applicant_rank               => l_asg_rec.applicant_rank
  ,p_grade_ladder_pgm_id          => l_asg_rec.grade_ladder_pgm_id
  ,p_supervisor_assignment_id     => l_asg_rec.supervisor_assignment_id
  -- In/Out
  ,p_cagr_grade_def_id            => g_asg_rec.cagr_grade_def_id
  ,p_people_group_id              => g_asg_rec.people_group_id
  ,p_soft_coding_keyflex_id       => g_asg_rec.soft_coding_keyflex_id
  ,p_object_version_number        => l_cur_asg_rec.object_version_number
  -- Out
  ,p_concatenated_segments        => l_UpdEmpAsg_out.concatenated_segments
  ,p_cagr_concatenated_segments   => l_UpdEmpAsg_out.cagr_concatenated_segments
  ,p_group_name                   => l_UpdEmpAsg_out.concatenated_segments
  ,p_comment_id                   => l_UpdEmpAsg_out.comment_id
  ,p_effective_start_date         => l_UpdEmpAsg_out.effective_start_date
  ,p_effective_end_date           => l_UpdEmpAsg_out.effective_end_date
  );  */

  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

exception
  when e_empasg_notfound  then
   l_error_msg :=
              'Applicant Assignment could not be found as of the effective date';
   hr_utility.set_message(8303, 'PQP_230494_RIW_ASSGN_NOT_FOUND');
   hr_utility.set_message_token('TOKEN','Applicant' );
   hr_utility.set_location('Leaving: ' || l_proc_name, 90);
   hr_utility.raise_error;

  when Others then
   --l_error_msg := SQLERRM;
   hr_utility.set_location('SQLCODE :' || SQLCODE,100);
   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
   hr_utility.set_location('Leaving: ' || l_proc_name, 100);
   --hr_utility.trace('Error Text = ' ||substr(l_error_msg,1,150));

   hr_utility.raise_error;

end Upd_Applicant_Asg;
-- =============================================================================
-- ~ Upd_Contingent_Asg :
-- =============================================================================
procedure Upd_Contingent_Asg
         (p_effective_date in date
         ,p_asg_crit_out   in out NOCOPY t_AsgUpdCrit_Api
         --,p_UpdEmpAsg_out  IN OUT NOCOPY t_Upd_Emp_Asg_Api
          ) as

  -- Cursor to get Assignment details
  cursor csr_asg (c_effective_date in date
                 ,c_assignment_id  in number
                 ,c_business_group_id in number)is
  select *
    from per_all_assignments_f paf
   where paf.assignment_id = c_assignment_id
     and paf.business_group_id = c_business_group_id
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;

  l_cur_asg_rec            csr_asg%rowtype;

  -- Cursor to get people group flexfield details
  cursor csr_ppg (c_people_grp_id in number) is
  select *
    from pay_people_groups
   where people_group_id = c_people_grp_id;

  l_cur_ppl_grp_rec        pay_people_groups%rowtype;

  -- Cursor to get Soft coding flexfield details
  cursor csr_scl (c_scl_kff_id in number) is
  select *
    from hr_soft_coding_keyflex
   where soft_coding_keyflex_id = c_scl_kff_id;

  l_cur_scl_rec        hr_soft_coding_keyflex%rowtype;

  l_proc_name  constant    varchar2(150):= g_pkg ||'Upd_Contingent_Asg';
  l_error_msg              varchar2(2000);
  l_datetrack_update_mode  varchar2(50);
  l_dt_correction          boolean;
  l_dt_update              boolean;
  l_dt_upd_override        boolean;
  l_upd_chg_ins            boolean;
  e_empasg_notfound        exception;
  l_UpdEmpAsg_out          t_Upd_Emp_Asg_Api;
  l_asg_rec                per_all_assignments_f%rowtype;
  l_grp_rec                pay_people_groups%rowtype;
  l_scl_rec                hr_soft_coding_keyflex%rowtype;

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  l_asg_rec := Get_AsgRecord_Values(g_interface_code);
  l_grp_rec := Get_GrpRecord_Values(g_interface_code);
  l_scl_rec := Get_ScflxRecord_Values(g_interface_code);

  open  csr_asg (c_effective_date    => p_effective_date
                ,c_assignment_id     => g_asg_rec.assignment_id
                ,c_business_group_id => g_asg_rec.business_group_id
                 );
  fetch csr_asg into l_cur_asg_rec;
  if csr_asg%notfound then
     close csr_asg;
     raise e_empasg_notfound;
  end if;
  close csr_asg;
  hr_utility.set_location(' l_cur_asg_rec: ' || p_effective_date, 20);
  hr_utility.set_location(' l_cur_asg_rec: ' || g_asg_rec.assignment_id, 20);
  hr_utility.set_location(' l_cur_asg_rec: ' || g_asg_rec.business_group_id, 20);
  --
  -- Check if the People Group Id is passed
  --
  open  csr_ppg(c_people_grp_id => g_asg_rec.people_group_id);
  fetch csr_ppg into l_cur_ppl_grp_rec;
  --$ Do not assign people group id from existing record but from the combination
   -- of the segments obtained from user
   if csr_ppg%found then
     p_asg_crit_out.people_group_id := g_asg_rec.people_group_id;
     l_asg_rec.people_group_id := g_asg_rec.people_group_id;

  /*if csr_ppg%notfound then
     g_asg_rec.people_group_id
       := l_cur_asg_rec.people_group_id;
     l_asg_rec.people_group_id
       := l_cur_asg_rec.people_group_id;*/
  end if;

  close csr_ppg;
  hr_utility.set_location(' people_group_id: ' || g_asg_rec.people_group_id, 30);
  --
  -- check if the Soft-Coding KFF id is passed
  --
  open  csr_scl(c_scl_kff_id => g_asg_rec.soft_coding_keyflex_id);
  fetch csr_scl into l_cur_scl_rec;
  --$ Do not assign soft keyflex id from existing record but from the combination
   -- of the segments obtained from user
 if csr_scl%found then
     p_asg_crit_out.soft_coding_keyflex_id := g_asg_rec.soft_coding_keyflex_id;
     l_asg_rec.soft_coding_keyflex_id := g_asg_rec.soft_coding_keyflex_id;
 /*  if csr_scl%notfound then
     g_asg_rec.soft_coding_keyflex_id
       := l_cur_asg_rec.soft_coding_keyflex_id;
     l_asg_rec.soft_coding_keyflex_id
       := l_cur_asg_rec.soft_coding_keyflex_id; */

  end if;
  close csr_scl;
  hr_utility.set_location(' soft_coding_keyflex_id: ' ||
                            g_asg_rec.soft_coding_keyflex_id, 40);
  --
  -- Get the datetrack mode based on the effective date passed
  --
  Dt_Api.Find_DT_Upd_Modes
  (p_effective_date        =>  p_effective_date
  ,p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F'
  ,p_base_key_column       => 'ASSIGNMENT_ID'
  ,p_base_key_value        => g_asg_rec.assignment_id
  ,p_correction            => l_dt_correction
  ,p_update                => l_dt_update
  ,p_update_override       => l_dt_upd_override
  ,p_update_change_insert  => l_upd_chg_ins
   );

  if l_dt_update then
     l_datetrack_update_mode := 'UPDATE';
  elsif l_dt_upd_override or
        l_upd_chg_ins then
             --Else USE Correction Mode
        l_datetrack_update_mode := 'CORRECTION';
     hr_utility.set_location(' l_dt_upd_override or l_upd_chg_ins ', 50);
  else
     l_datetrack_update_mode := 'CORRECTION';
  end if;
  hr_utility.set_location(' l_datetrack_update_mode: ' ||
                            l_datetrack_update_mode, 60);

  g_asg_rec.cagr_grade_def_id := nvl(g_asg_rec.cagr_grade_def_id,
                                     l_cur_asg_rec.cagr_grade_def_id);
  l_asg_rec.cagr_grade_def_id := g_asg_rec.cagr_grade_def_id;


  HR_Assignment_API.Update_CWK_Asg_Criteria
  (p_validate                     => false
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_assignment_id                => g_asg_rec.assignment_id
  ,p_called_from_mass_update      => false
  ,p_grade_id                     => l_asg_rec.grade_id
  ,p_position_id                  => l_asg_rec.position_id
  ,p_job_id                       => l_asg_rec.job_id
  ,p_location_id                  => l_asg_rec.location_id
  ,p_organization_id              => l_asg_rec.organization_id
  ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
  -- People Group Segments
  ,p_segment1                     => l_grp_rec.segment1
  ,p_segment2                     => l_grp_rec.segment2
  ,p_segment3                     => l_grp_rec.segment3
  ,p_segment4                     => l_grp_rec.segment4
  ,p_segment5                     => l_grp_rec.segment5
  ,p_segment6                     => l_grp_rec.segment6
  ,p_segment7                     => l_grp_rec.segment7
  ,p_segment8                     => l_grp_rec.segment8
  ,p_segment9                     => l_grp_rec.segment9
  ,p_segment10                    => l_grp_rec.segment10
  ,p_segment11                    => l_grp_rec.segment11
  ,p_segment12                    => l_grp_rec.segment12
  ,p_segment13                    => l_grp_rec.segment13
  ,p_segment14                    => l_grp_rec.segment14
  ,p_segment15                    => l_grp_rec.segment15
  ,p_segment16                    => l_grp_rec.segment16
  ,p_segment17                    => l_grp_rec.segment17
  ,p_segment18                    => l_grp_rec.segment18
  ,p_segment19                    => l_grp_rec.segment19
  ,p_segment20                    => l_grp_rec.segment20
  ,p_segment21                    => l_grp_rec.segment21
  ,p_segment22                    => l_grp_rec.segment22
  ,p_segment23                    => l_grp_rec.segment23
  ,p_segment24                    => l_grp_rec.segment24
  ,p_segment25                    => l_grp_rec.segment25
  ,p_segment26                    => l_grp_rec.segment26
  ,p_segment27                    => l_grp_rec.segment27
  ,p_segment28                    => l_grp_rec.segment28
  ,p_segment29                    => l_grp_rec.segment29
  ,p_segment30                    => l_grp_rec.segment30
  ,p_concat_segments              => l_grp_rec.group_name
  -- In/Out
  ,p_object_version_number        => l_cur_asg_rec.object_version_number
  -- Out
  ,p_people_group_name            => p_asg_crit_out.group_name
  ,p_people_group_id              => p_asg_crit_out.people_group_id
  ,p_effective_start_date         => p_asg_crit_out.asg_effective_start_date
  ,p_effective_end_date           => p_asg_crit_out.asg_effective_end_date
  ,p_org_now_no_manager_warning   => p_asg_crit_out.org_now_no_manager_warning
  ,p_other_manager_warning        => p_asg_crit_out.other_manager_warning
  ,p_spp_delete_warning           => p_asg_crit_out.spp_delete_warning
  ,p_entries_changed_warning      => p_asg_crit_out.entries_changed_warning
  ,p_tax_district_changed_warning => p_asg_crit_out.tax_district_changed_warning
   );


  if g_debug then
     hr_utility.set_location(' people_group_id: ' ||
                               p_asg_crit_out.people_group_id, 70);
     hr_utility.set_location(' soft_coding_keyflex_id: ' ||
                               p_asg_crit_out.soft_coding_keyflex_id, 70);
     hr_utility.set_location(' group_name: ' ||
                               p_asg_crit_out.group_name, 70);
     hr_utility.set_location(' asg_effective_start_date: ' ||
                               p_asg_crit_out.asg_effective_start_date, 70);
  end if;
  l_datetrack_update_mode := 'CORRECTION';


  --hr_utility.trace(' Value of l_asg_rec.assignment_id = '||l_asg_rec.assignment_id);
  --hr_utility.trace(' Value of g_asg_rec.assignment_id = '||g_asg_rec.assignment_id);


   HR_Assignment_API.Update_CWK_Asg
  (p_validate                     => false
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_assignment_id                => g_asg_rec.assignment_id -- l_asg_rec.assignment_id => Changed by pkagrawa
  ,p_comments                     => g_asg_comments  --$ null
  ,p_project_title                  => null
  ,p_concat_segments              => null
  ,p_establishment_id             => l_asg_rec.establishment_id
  ,p_supervisor_assignment_id     => l_asg_rec.supervisor_assignment_id
  ,p_title                        => l_asg_rec.title
  ,p_assignment_category          => l_asg_rec.employment_category
  ,p_assignment_number            => l_asg_rec.assignment_number
  ,p_change_reason                => l_asg_rec.change_reason
  ,p_default_code_comb_id         => l_asg_rec.default_code_comb_id
  ,p_frequency                    => l_asg_rec.frequency
  ,p_internal_address_line        => l_asg_rec.internal_address_line
  ,p_labour_union_member_flag     => l_asg_rec.labour_union_member_flag
  ,p_manager_flag                 => l_asg_rec.manager_flag
  ,p_normal_hours                 => l_asg_rec.normal_hours
  ,p_set_of_books_id              => l_asg_rec.set_of_books_id
  ,p_source_type                  => l_asg_rec.source_type
  ,p_supervisor_id                => l_asg_rec.supervisor_id
  ,p_time_normal_finish           => l_asg_rec.time_normal_finish
  ,p_time_normal_start            => l_asg_rec.time_normal_start
  ,p_vendor_assignment_number     => l_asg_rec.vendor_assignment_number
  ,p_vendor_employee_number       => l_asg_rec.vendor_employee_number
  ,p_vendor_id                    => l_asg_rec.vendor_id
  ,p_vendor_site_id               => l_asg_rec.vendor_site_id
  ,p_po_header_id                 => l_asg_rec.po_header_id
  ,p_po_line_id                   => l_asg_rec.po_line_id
  ,p_projected_assignment_end     => l_asg_rec.projected_assignment_end
  ,p_assignment_status_type_id    => l_asg_rec.assignment_status_type_id
  -- Asg DF
  ,p_attribute_category           => l_asg_rec.ass_attribute_category
  ,p_attribute1                   => l_asg_rec.ass_attribute1
  ,p_attribute2                   => l_asg_rec.ass_attribute2
  ,p_attribute3                   => l_asg_rec.ass_attribute3
  ,p_attribute4                   => l_asg_rec.ass_attribute4
  ,p_attribute5                   => l_asg_rec.ass_attribute5
  ,p_attribute6                   => l_asg_rec.ass_attribute6
  ,p_attribute7                   => l_asg_rec.ass_attribute7
  ,p_attribute8                   => l_asg_rec.ass_attribute8
  ,p_attribute9                   => l_asg_rec.ass_attribute9
  ,p_attribute10                  => l_asg_rec.ass_attribute10
  ,p_attribute11                  => l_asg_rec.ass_attribute11
  ,p_attribute12                  => l_asg_rec.ass_attribute12
  ,p_attribute13                  => l_asg_rec.ass_attribute13
  ,p_attribute14                  => l_asg_rec.ass_attribute14
  ,p_attribute15                  => l_asg_rec.ass_attribute15
  ,p_attribute16                  => l_asg_rec.ass_attribute16
  ,p_attribute17                  => l_asg_rec.ass_attribute17
  ,p_attribute18                  => l_asg_rec.ass_attribute18
  ,p_attribute19                  => l_asg_rec.ass_attribute19
  ,p_attribute20                  => l_asg_rec.ass_attribute20
  ,p_attribute21                  => l_asg_rec.ass_attribute21
  ,p_attribute22                  => l_asg_rec.ass_attribute22
  ,p_attribute23                  => l_asg_rec.ass_attribute23
  ,p_attribute24                  => l_asg_rec.ass_attribute24
  ,p_attribute25                  => l_asg_rec.ass_attribute25
  ,p_attribute26                  => l_asg_rec.ass_attribute26
  ,p_attribute27                  => l_asg_rec.ass_attribute27
  ,p_attribute28                  => l_asg_rec.ass_attribute28
  ,p_attribute29                  => l_asg_rec.ass_attribute29
  ,p_attribute30                  => l_asg_rec.ass_attribute30
  -- Soft Coding KFF
  ,p_scl_segment1                 => l_scl_rec.segment1
  ,p_scl_segment2                 => l_scl_rec.segment2
  ,p_scl_segment3                 => l_scl_rec.segment3
  ,p_scl_segment4                 => l_scl_rec.segment4
  ,p_scl_segment5                 => l_scl_rec.segment5
  ,p_scl_segment6                 => l_scl_rec.segment6
  ,p_scl_segment7                 => l_scl_rec.segment7
  ,p_scl_segment8                 => l_scl_rec.segment8
  ,p_scl_segment9                 => l_scl_rec.segment9
  ,p_scl_segment10                => l_scl_rec.segment10
  ,p_scl_segment11                => l_scl_rec.segment11
  ,p_scl_segment12                => l_scl_rec.segment12
  ,p_scl_segment13                => l_scl_rec.segment13
  ,p_scl_segment14                => l_scl_rec.segment14
  ,p_scl_segment15                => l_scl_rec.segment15
  ,p_scl_segment16                => l_scl_rec.segment16
  ,p_scl_segment17                => l_scl_rec.segment17
  ,p_scl_segment18                => l_scl_rec.segment18
  ,p_scl_segment19                => l_scl_rec.segment19
  ,p_scl_segment20                => l_scl_rec.segment20
  ,p_scl_segment21                => l_scl_rec.segment21
  ,p_scl_segment22                => l_scl_rec.segment22
  ,p_scl_segment23                => l_scl_rec.segment23
  ,p_scl_segment24                => l_scl_rec.segment24
  ,p_scl_segment25                => l_scl_rec.segment25
  ,p_scl_segment26                => l_scl_rec.segment26
  ,p_scl_segment27                => l_scl_rec.segment27
  ,p_scl_segment28                => l_scl_rec.segment28
  ,p_scl_segment29                => l_scl_rec.segment29
  ,p_scl_segment30                => l_scl_rec.segment30
  -- In/Out
  ,p_object_version_number        => l_cur_asg_rec.object_version_number
  -- Out
  ,p_org_now_no_manager_warning   => p_asg_crit_out.org_now_no_manager_warning
  ,p_effective_start_date         => l_UpdEmpAsg_out.effective_start_date
  ,p_effective_end_date           => l_UpdEmpAsg_out.effective_end_date
  ,p_comment_id                   => l_UpdEmpAsg_out.comment_id
  ,p_no_managers_warning          => l_UpdEmpAsg_out.no_managers_warning
  ,p_other_manager_warning        => l_UpdEmpAsg_out.other_manager_warning
  ,p_soft_coding_keyflex_id       => l_asg_rec.soft_coding_keyflex_id
  ,p_concatenated_segments        => l_UpdEmpAsg_out.concatenated_segments
  ,p_hourly_salaried_warning      => l_UpdEmpAsg_out.hourly_salaried_warning
   );

  if g_debug then
     hr_utility.set_location(' Asg OVN: ' ||
                               l_cur_asg_rec.object_version_number, 75);
     hr_utility.set_location(' soft_coding_keyflex_id: ' ||
                               p_asg_crit_out.soft_coding_keyflex_id, 75);
     hr_utility.set_location(' group_name: ' ||
                               l_UpdEmpAsg_out.concatenated_segments, 75);
     hr_utility.set_location(' asg_effective_start_date: ' ||
                               l_UpdEmpAsg_out.effective_start_date, 75);
  end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

exception
  when e_empasg_notfound  then
   l_error_msg :=
              'Contingent Assignment could not be found as of the effective date';
   hr_utility.set_message(8303, 'PQP_230494_RIW_ASSGN_NOT_FOUND');
   hr_utility.set_message_token('TOKEN','Contingent' );
   hr_utility.set_location('Leaving: ' || l_proc_name, 90);
   hr_utility.raise_error;

  when Others then
   --l_error_msg := SQLERRM;

   --hr_utility.trace(' Upd_Contingent_Asg Error = '||sqlerrm);

   hr_utility.set_location('SQLCODE :' || SQLCODE,100);
   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
   hr_utility.set_location('Leaving: ' || l_proc_name, 100);
   hr_utility.raise_error;

end Upd_Contingent_Asg;

-- =============================================================================
-- ~ Update_Employee_Asg :
-- =============================================================================
procedure Update_Employee_Asg
         (p_effective_date in date
         ,p_asg_crit_out   in out NOCOPY t_AsgUpdCrit_Api
         --,p_UpdEmpAsg_out  IN OUT NOCOPY t_Upd_Emp_Asg_Api
          ) as

  -- Cursor to get Assignment details
  cursor csr_asg (c_effective_date in date
                 ,c_assignment_id  in number
                 ,c_business_group_id in number)is
  select *
    from per_all_assignments_f paf
   where paf.assignment_id = c_assignment_id
     and paf.business_group_id = c_business_group_id
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;

  l_cur_asg_rec            csr_asg%rowtype;

  -- Cursor to get people group flexfield details
  cursor csr_ppg (c_people_grp_id in number) is
  select *
    from pay_people_groups
   where people_group_id = c_people_grp_id;

  l_cur_ppl_grp_rec        pay_people_groups%rowtype;

  -- Cursor to get Soft coding flexfield details
  cursor csr_scl (c_scl_kff_id in number) is
  select *
    from hr_soft_coding_keyflex
   where soft_coding_keyflex_id = c_scl_kff_id;

  l_cur_scl_rec        hr_soft_coding_keyflex%rowtype;

  l_proc_name  constant    varchar2(150):= g_pkg ||'Update_Employee_Asg';
  l_error_msg              varchar2(2000);
  l_datetrack_update_mode  varchar2(50);
  l_dt_correction          boolean;
  l_dt_update              boolean;
  l_dt_upd_override        boolean;
  l_upd_chg_ins            boolean;
  e_empasg_notfound        exception;
  l_UpdEmpAsg_out          t_Upd_Emp_Asg_Api;
  l_asg_rec                per_all_assignments_f%rowtype;
  l_grp_rec                pay_people_groups%rowtype;
  l_scl_rec                hr_soft_coding_keyflex%rowtype;
begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  l_asg_rec := Get_AsgRecord_Values(g_interface_code);
  l_grp_rec := Get_GrpRecord_Values(g_interface_code);
  l_scl_rec := Get_ScflxRecord_Values(g_interface_code);

  open  csr_asg (c_effective_date    => p_effective_date
                ,c_assignment_id     => g_asg_rec.assignment_id
                ,c_business_group_id => g_asg_rec.business_group_id
                 );
  fetch csr_asg into l_cur_asg_rec;
  if csr_asg%notfound then
     close csr_asg;
     raise e_empasg_notfound;
  end if;
  close csr_asg;
  hr_utility.set_location(' l_cur_asg_rec: ' || p_effective_date, 20);
  hr_utility.set_location(' l_cur_asg_rec: ' || g_asg_rec.assignment_id, 20);
  hr_utility.set_location(' l_cur_asg_rec: ' || g_asg_rec.business_group_id, 20);

  open  csr_ppg(c_people_grp_id => g_asg_rec.people_group_id);
  fetch csr_ppg into l_cur_ppl_grp_rec;
  if csr_ppg%found then
     p_asg_crit_out.people_group_id := g_asg_rec.people_group_id;
     l_asg_rec.people_group_id := g_asg_rec.people_group_id;
  end if;
  close csr_ppg;
  hr_utility.set_location(' people_group_id: ' || g_asg_rec.people_group_id, 30);

  open  csr_scl(c_scl_kff_id => g_asg_rec.soft_coding_keyflex_id);
  fetch csr_scl into l_cur_scl_rec;
  if csr_scl%found then
     p_asg_crit_out.soft_coding_keyflex_id := g_asg_rec.soft_coding_keyflex_id;
     l_asg_rec.soft_coding_keyflex_id := g_asg_rec.soft_coding_keyflex_id;
  end if;
  close csr_scl;
  hr_utility.set_location(' soft_coding_keyflex_id: ' ||
                            g_asg_rec.soft_coding_keyflex_id, 40);

  Dt_Api.Find_DT_Upd_Modes
  (p_effective_date        =>  p_effective_date
  ,p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F'
  ,p_base_key_column       => 'ASSIGNMENT_ID'
  ,p_base_key_value        => g_asg_rec.assignment_id
  ,p_correction            => l_dt_correction
  ,p_update                => l_dt_update
  ,p_update_override       => l_dt_upd_override
  ,p_update_change_insert  => l_upd_chg_ins
   );

  if l_dt_update then
     l_datetrack_update_mode := 'UPDATE';
  elsif l_dt_upd_override or
        l_upd_chg_ins then
     l_datetrack_update_mode := 'CORRECTION' ; --$ 'UPDATE' not possible
     hr_utility.set_location(' l_dt_upd_override or l_upd_chg_ins ', 50);
  else
     l_datetrack_update_mode := 'CORRECTION';
  end if;
  hr_utility.set_location(' l_datetrack_update_mode: ' ||
                            l_datetrack_update_mode, 60);

  Hr_Assignment_Api.Update_Emp_Asg_Criteria
  (p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_assignment_id                => g_asg_rec.assignment_id
  ,p_validate                     => false
  ,p_called_from_mass_update      => false
  ,p_grade_id                     => l_asg_rec.grade_id
  ,p_position_id                  => l_asg_rec.position_id
  ,p_job_id                       => l_asg_rec.job_id
  ,p_payroll_id                   => l_asg_rec.payroll_id
  ,p_location_id                  => l_asg_rec.location_id
  ,p_organization_id              => l_asg_rec.organization_id
  ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
  ,p_employment_category          => l_asg_rec.employment_category

  ,p_segment1                     => l_grp_rec.segment1
  ,p_segment2                     => l_grp_rec.segment2
  ,p_segment3                     => l_grp_rec.segment3
  ,p_segment4                     => l_grp_rec.segment4
  ,p_segment5                     => l_grp_rec.segment5
  ,p_segment6                     => l_grp_rec.segment6
  ,p_segment7                     => l_grp_rec.segment7
  ,p_segment8                     => l_grp_rec.segment8
  ,p_segment9                     => l_grp_rec.segment9
  ,p_segment10                    => l_grp_rec.segment10
  ,p_segment11                    => l_grp_rec.segment11
  ,p_segment12                    => l_grp_rec.segment12
  ,p_segment13                    => l_grp_rec.segment13
  ,p_segment14                    => l_grp_rec.segment14
  ,p_segment15                    => l_grp_rec.segment15
  ,p_segment16                    => l_grp_rec.segment16
  ,p_segment17                    => l_grp_rec.segment17
  ,p_segment18                    => l_grp_rec.segment18
  ,p_segment19                    => l_grp_rec.segment19
  ,p_segment20                    => l_grp_rec.segment20
  ,p_segment21                    => l_grp_rec.segment21
  ,p_segment22                    => l_grp_rec.segment22
  ,p_segment23                    => l_grp_rec.segment23
  ,p_segment24                    => l_grp_rec.segment24
  ,p_segment25                    => l_grp_rec.segment25
  ,p_segment26                    => l_grp_rec.segment26
  ,p_segment27                    => l_grp_rec.segment27
  ,p_segment28                    => l_grp_rec.segment28
  ,p_segment29                    => l_grp_rec.segment29
  ,p_segment30                    => l_grp_rec.segment30
  ,p_concat_segments              => l_grp_rec.group_name

  ,p_scl_segment1                 => l_scl_rec.segment1
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


  if g_debug then
     hr_utility.set_location(' people_group_id: ' ||
                               p_asg_crit_out.people_group_id, 70);
     hr_utility.set_location(' soft_coding_keyflex_id: ' ||
                               p_asg_crit_out.soft_coding_keyflex_id, 70);
     hr_utility.set_location(' group_name: ' ||
                               p_asg_crit_out.group_name, 70);
     hr_utility.set_location(' asg_effective_start_date: ' ||
                               p_asg_crit_out.asg_effective_start_date, 70);
  end if;

  l_datetrack_update_mode := 'CORRECTION';

  g_asg_rec.cagr_grade_def_id := NVL(g_asg_rec.cagr_grade_def_id,
                                     l_cur_asg_rec.cagr_grade_def_id);
  g_asg_rec.soft_coding_keyflex_id := p_asg_crit_out.soft_coding_keyflex_id;
  --
  -- Hr_Assignment_Api.Update_Emp_Asg: Use the overloaded update_emp_asg(NEW3)
  --
 --hr_utility.trace('ass_attribute1 = ' ||l_asg_rec.ass_attribute1);
 --hr_utility.trace('ass_attribute2 = ' ||l_asg_rec.ass_attribute2);
 --hr_utility.trace('ass_attribute3 = ' ||l_asg_rec.ass_attribute3);
 --hr_utility.trace('ass_attribute4 = ' ||l_asg_rec.ass_attribute4);
 --hr_utility.trace('ass_attribute5 = ' ||l_asg_rec.ass_attribute5);
 --hr_utility.trace('ass_attribute6 = ' ||l_asg_rec.ass_attribute6);
 --hr_utility.trace('ass_attribute7 = ' ||l_asg_rec.ass_attribute7);
 --hr_utility.trace('ass_attribute8 = ' ||l_asg_rec.ass_attribute8);
 --hr_utility.trace('ass_attribute9 = ' ||l_asg_rec.ass_attribute9);
 --hr_utility.trace('ass_attribute10 = ' ||l_asg_rec.ass_attribute10);
 --hr_utility.trace('ass_attribute11 = ' ||l_asg_rec.ass_attribute11);
 --hr_utility.trace('ass_attribute12 = ' ||l_asg_rec.ass_attribute12);
 --hr_utility.trace('ass_attribute13 = ' ||l_asg_rec.ass_attribute13);
 --hr_utility.trace('ass_attribute14 = ' ||l_asg_rec.ass_attribute14);
 --hr_utility.trace('ass_attribute15 = ' ||l_asg_rec.ass_attribute15);

  Hr_Assignment_Api.Update_Emp_Asg
  (p_validate                     => false
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_assignment_id                => l_cur_asg_rec.assignment_id
  ,p_object_version_number        => l_cur_asg_rec.object_version_number
  ,p_supervisor_id                => l_asg_rec.supervisor_id
  ,p_assignment_number            => nvl(l_asg_rec.assignment_number,
                                         l_cur_asg_rec.assignment_number)
  ,p_change_reason                => l_asg_rec.change_reason
  ,p_date_probation_end           => l_asg_rec.date_probation_end
  ,p_default_code_comb_id         => l_asg_rec.default_code_comb_id
  ,p_frequency                    => l_asg_rec.frequency
  ,p_internal_address_line        => l_asg_rec.internal_address_line
  ,p_manager_flag                 => l_asg_rec.manager_flag
  ,p_normal_hours                 => l_asg_rec.normal_hours
  ,p_perf_review_period           => l_asg_rec.perf_review_period
  ,p_perf_review_period_frequency => l_asg_rec.perf_review_period_frequency
  ,p_probation_period             => l_asg_rec.probation_period
  ,p_probation_unit               => l_asg_rec.probation_unit
  ,p_sal_review_period            => l_asg_rec.sal_review_period
  ,p_sal_review_period_frequency  => l_asg_rec.sal_review_period_frequency
  ,p_set_of_books_id              => l_asg_rec.set_of_books_id
  ,p_source_type                  => l_asg_rec.source_type
  ,p_time_normal_finish           => l_asg_rec.time_normal_finish
  ,p_time_normal_start            => l_asg_rec.time_normal_start
  ,p_bargaining_unit_code         => l_asg_rec.bargaining_unit_code
  ,p_labour_union_member_flag     => l_asg_rec.labour_union_member_flag
  ,p_hourly_salaried_code         => l_asg_rec.hourly_salaried_code
  ,p_title                        => l_asg_rec.title
  --Added by DBANSAL
  ,p_employee_category            =>  l_asg_rec.employee_category
  ,p_comments                     =>  g_asg_comments
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
  ,p_segment1                     => l_scl_rec.segment1
  ,p_segment2                     => l_scl_rec.segment2
  ,p_segment3                     => l_scl_rec.segment3
  ,p_segment4                     => l_scl_rec.segment4
  ,p_segment5                     => l_scl_rec.segment5
  ,p_segment6                     => l_scl_rec.segment6
  ,p_segment7                     => l_scl_rec.segment7
  ,p_segment8                     => l_scl_rec.segment8
  ,p_segment9                     => l_scl_rec.segment9
  ,p_segment10                    => l_scl_rec.segment10
  ,p_segment11                    => l_scl_rec.segment11
  ,p_segment12                    => l_scl_rec.segment12
  ,p_segment13                    => l_scl_rec.segment13
  ,p_segment14                    => l_scl_rec.segment14
  ,p_segment15                    => l_scl_rec.segment15
  ,p_segment16                    => l_scl_rec.segment16
  ,p_segment17                    => l_scl_rec.segment17
  ,p_segment18                    => l_scl_rec.segment18
  ,p_segment19                    => l_scl_rec.segment19
  ,p_segment20                    => l_scl_rec.segment20
  ,p_segment21                    => l_scl_rec.segment21
  ,p_segment22                    => l_scl_rec.segment22
  ,p_segment23                    => l_scl_rec.segment23
  ,p_segment24                    => l_scl_rec.segment24
  ,p_segment25                    => l_scl_rec.segment25
  ,p_segment26                    => l_scl_rec.segment26
  ,p_segment27                    => l_scl_rec.segment27
  ,p_segment28                    => l_scl_rec.segment28
  ,p_segment29                    => l_scl_rec.segment29
  ,p_segment30                    => l_scl_rec.segment30
  ,p_concat_segments              => l_scl_rec.concatenated_segments
  -- Out Parameters
  ,p_cagr_grade_def_id            => l_asg_rec.cagr_grade_def_id
  ,p_soft_coding_keyflex_id       => g_asg_rec.soft_coding_keyflex_id
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

  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

exception
  when e_empasg_notfound  then
   l_error_msg := 'Employee Assignment could not be found as of the effective date';

   hr_utility.set_message(8303, 'PQP_230494_RIW_ASSGN_NOT_FOUND');
   hr_utility.set_message_token('TOKEN','Employee' );
   hr_utility.set_location('Leaving: ' || l_proc_name, 90);
   hr_utility.raise_error;

  when Others then
   --l_error_msg := SQLERRM;
   hr_utility.set_location('SQLCODE :' || SQLCODE,100);
   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
   hr_utility.set_location('Leaving: ' || l_proc_name, 100);
   hr_utility.raise_error;

end Update_Employee_Asg;
-- =============================================================================
-- ~ Upd_Batch_Person:
-- =============================================================================
procedure Upd_Batch_Person
         (p_batch_id                in number
         ,p_user_sequence           in out nocopy number
         ,p_link_value              in number
         ,p_person_user_key         in varchar2
         ,p_user_person_type        in varchar2
         ,p_datetrack_update_mode   in varchar2
         ,p_adjusted_svc_date       in date default null  -- Added by pkagrawa
          ) is

  l_proc_name  constant    varchar2(150):= g_pkg ||'Upd_Batch_Person';
  l_per_rec                per_all_people_f%rowtype;
  l_cur_per_rec            per_all_people_f%rowtype;
  l_ptu_rec                chk_perType_usage%rowtype;
  l_datetrack_update_mode  varchar2(50);
  l_dt_correction          boolean;
  l_dt_update              boolean;
  l_dt_upd_override        boolean;
  l_upd_chg_ins            boolean;
  e_future_chgs_exists     exception;
  l_error_msg              varchar2(3000);

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 5);

  l_per_rec := Get_PerRecord_Values(g_interface_code);
  if p_datetrack_update_mode is not null then
     l_datetrack_update_mode := p_datetrack_update_mode;
  else
     open  csr_per(c_person_id         => g_per_rec.person_id
                  ,c_business_group_id => g_per_rec.business_group_id
                  ,c_effective_date    => g_per_rec.start_date);
     fetch csr_per into l_cur_per_rec;
     close csr_per;
     hr_utility.set_location(' l_cur_per_rec: ' || l_cur_per_rec.person_id, 20);
     Dt_Api.Find_DT_Upd_Modes
     (p_effective_date        => g_per_rec.start_date
     ,p_base_table_name       => 'PER_ALL_PEOPLE_F'
     ,p_base_key_column       => 'PERSON_ID'
     ,p_base_key_value        => l_cur_per_rec.person_id
     ,p_correction            => l_dt_correction
     ,p_update                => l_dt_update
     ,p_update_override       => l_dt_upd_override
     ,p_update_change_insert  => l_upd_chg_ins
      );
     if l_dt_update then
        l_datetrack_update_mode := 'UPDATE';
     elsif l_dt_upd_override or
           l_upd_chg_ins then
           -- Need to check if person type in future is EMP, APL or CWK , if yes
           -- then raise error
           open chk_perType_usage
              (c_person_id         => l_cur_per_rec.person_id
              ,c_effective_date    => g_per_rec.start_date
              ,c_business_group_id => g_per_rec.business_group_id);
           fetch chk_perType_usage into l_ptu_rec;
           if chk_perType_usage%found then
              close chk_perType_usage;
              raise e_future_chgs_exists;
           end if;
           close chk_perType_usage;
           --$ Else Correction Mode
           l_datetrack_update_mode := 'CORRECTION';
     else
        l_datetrack_update_mode := 'CORRECTION';
     end if;
  end if;
  hr_utility.set_location(' l_datetrack_update_mode: ' ||
                            l_datetrack_update_mode, 30);

  Hrdpp_Update_Person.Insert_Batch_Lines
  (p_batch_id                     => p_batch_id
  ,p_user_sequence                => p_user_sequence
  ,p_link_value                   => p_link_value
  ,p_effective_date               => g_per_rec.start_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_person_user_key              => p_person_user_key
  ,p_user_person_type             => p_user_person_type
  ,p_language_code                => Userenv('lang')
  ,p_party_id                     => nvl(l_per_rec.party_id,
                                         l_cur_per_rec.party_id)
  ,p_employee_number              => nvl(l_per_rec.employee_number,
                                         l_cur_per_rec.employee_number)
  ,p_applicant_number             => nvl(l_per_rec.applicant_number,
                                         l_cur_per_rec.applicant_number)
  ,p_npw_number                   => nvl(l_per_rec.npw_number,
                                         l_cur_per_rec.npw_number)
  ,p_last_name                    => nvl(l_per_rec.last_name,
                                         l_cur_per_rec.last_name)
  ,p_first_name                   => l_per_rec.first_name
  ,p_date_of_birth                => nvl(l_per_rec.date_of_birth,
                                         l_cur_per_rec.date_of_birth)
  ,p_marital_status               => l_per_rec.marital_status
  ,p_middle_names                 => l_per_rec.middle_names
  ,p_sex                          => nvl(l_per_rec.sex,
                                         l_cur_per_rec.sex)
  ,p_title                        => l_per_rec.title
  ,p_nationality                  => l_per_rec.nationality
  ,p_previous_last_name           => l_per_rec.previous_last_name
  ,p_national_identifier          => l_per_rec.national_identifier
  ,p_known_as                     => l_per_rec.known_as
  ,p_email_address                => l_per_rec.email_address
  ,p_registered_disabled_flag     => l_per_rec.registered_disabled_flag
  ,p_date_employee_data_verified  => l_per_rec.date_employee_data_verified
  ,p_expense_check_send_to_addres => l_per_rec.expense_check_send_to_address
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

  ,p_date_of_death                => l_per_rec.date_of_death
  ,p_background_date_check        => l_per_rec.background_date_check
  ,p_hold_applicant_date_until    => l_per_rec.hold_applicant_date_until
  ,p_last_medical_test_date       => l_per_rec.last_medical_test_date
  ,p_projected_start_date         => l_per_rec.projected_start_date
  ,p_resume_last_updated          => l_per_rec.resume_last_updated
  ,p_receipt_of_death_cert_date   => l_per_rec.receipt_of_death_cert_date
  ,p_coord_ben_med_cvg_strt_dt    => l_per_rec.coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt     => l_per_rec.coord_ben_med_cvg_end_dt
  ,p_original_date_of_hire        => l_per_rec.original_date_of_hire
  ,p_dpdnt_adoption_date          => l_per_rec.dpdnt_adoption_date

  ,p_background_check_status      => l_per_rec.background_check_status
  ,p_blood_type                   => l_per_rec.blood_type
  ,p_correspondence_language      => l_per_rec.correspondence_language
  ,p_fte_capacity                 => l_per_rec.fte_capacity
  ,p_honors                       => l_per_rec.honors
  ,p_internal_location            => l_per_rec.internal_location
  ,p_last_medical_test_by         => l_per_rec.last_medical_test_by
  ,p_mailstop                     => l_per_rec.mailstop
  ,p_office_number                => l_per_rec.office_number
  ,p_on_military_service          => l_per_rec.on_military_service
  ,p_pre_name_adjunct             => l_per_rec.pre_name_adjunct
  ,p_rehire_authorizor            => l_per_rec.rehire_authorizor
  ,p_rehire_recommendation        => l_per_rec.rehire_recommendation
  ,p_resume_exists                => l_per_rec.resume_exists
  ,p_second_passport_exists       => l_per_rec.second_passport_exists
  ,p_student_status               => l_per_rec.student_status
  ,p_work_schedule                => l_per_rec.work_schedule
  ,p_rehire_reason                => l_per_rec.rehire_reason
  ,p_suffix                       => l_per_rec.suffix
--$ In Batch Lines Benefit Group Name has to be passed instead of ID
--  ,p_benefit_group                => l_per_rec.benefit_group_id
  ,p_benefit_group                =>  g_benefit_grp_name

  ,p_coord_ben_med_pln_no         => l_per_rec.coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        => l_per_rec.coord_ben_no_cvg_flag
  ,p_coord_ben_med_ext_er         => l_per_rec.coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name        => l_per_rec.coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name  => l_per_rec.coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident => l_per_rec.coord_ben_med_insr_crr_ident
  ,p_uses_tobacco_flag            => l_per_rec.uses_tobacco_flag
  ,p_dpdnt_vlntry_svce_flag       => l_per_rec.dpdnt_vlntry_svce_flag
  ,p_town_of_birth                => l_per_rec.town_of_birth
  ,p_region_of_birth              => l_per_rec.region_of_birth
  ,p_country_of_birth             => l_per_rec.country_of_birth
  ,p_global_person_id             => l_per_rec.global_person_id
  ,p_vendor_name                  => null
  ,p_adjusted_svc_date            => p_adjusted_svc_date --Added By pkagrawa
  );

  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

exception
  when e_future_chgs_exists then
    l_error_msg := 'This person cannot be created in HRMS as a Student '||
                   'Employee due to future changes beyond the date: '||g_per_rec.start_date;

    hr_utility.set_location('..Future Update exists for the Student Employee', 60);
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
    hr_utility.set_location('Leaving: ' || l_proc_name, 60);
    hr_utility.raise_error;

  when Others then
  hr_utility.set_location('SQLERRM :' || SQLCODE,90);
  hr_utility.set_location('Leaving: ' || l_proc_name, 90);
  raise;
end Upd_Batch_Person;
-- =============================================================================
-- InsUpd_Batch_Applicant:
-- =============================================================================
procedure InsUpd_Batch_Applicant
         (p_batch_id                in number
         ,p_data_pump_batch_line_id in number default null
         ,p_user_sequence           in out nocopy number
         ,p_link_value              in number
         ,p_assignment_user_key     in varchar2
         ,p_person_user_key         in varchar2
         ,p_user_person_type        in varchar2
         ,p_action_mode             in varchar2
         ,p_datetrack_update_mode   in varchar2
         ,p_vacancy_user_key        in varchar2
         ,p_application_user_key    in varchar2
          ) is

  l_proc_name  constant     varchar2(150):= g_pkg ||'InsUpd_Batch_Applicant';

begin

  hr_utility.set_location('Entering: ' || l_proc_name, 5);
  hr_utility.set_location('p_action_mode: ' || p_action_mode, 6);

  if p_action_mode = 'CREATE_APPLICANT' then

    Hrdpp_Create_Applicant.Insert_Batch_Lines
    (p_batch_id                     => p_batch_id
    ,p_data_pump_batch_line_id      => p_data_pump_batch_line_id
    ,p_user_sequence                => p_user_sequence
    ,p_link_value                   => p_link_value
    ,p_person_user_key              => p_person_user_key
    ,p_assignment_user_key          => p_assignment_user_key
    ,p_user_person_type             => p_user_person_type
    ,p_application_user_key         => p_application_user_key
    ,p_vacancy_user_key             => p_vacancy_user_key
    ,p_language_code                => Userenv('lang')
    ,p_applicant_number             => g_per_rec.applicant_number

    ,p_date_received                => g_per_rec.start_date
    ,p_last_name                    => g_per_rec.last_name
    ,p_sex                          => g_per_rec.sex
    ,p_date_employee_data_verified  => g_per_rec.date_employee_data_verified
    ,p_date_of_birth                => g_per_rec.date_of_birth
    ,p_email_address                => g_per_rec.email_address
    ,p_expense_check_send_to_addres => g_per_rec.expense_check_send_to_address
    ,p_first_name                   => g_per_rec.first_name
    ,p_known_as                     => g_per_rec.known_as
    ,p_marital_status               => g_per_rec.marital_status
    ,p_middle_names                 => g_per_rec.middle_names
    ,p_nationality                  => g_per_rec.nationality
    ,p_national_identifier          => g_per_rec.national_identifier
    ,p_previous_last_name           => g_per_rec.previous_last_name
    ,p_registered_disabled_flag     => g_per_rec.registered_disabled_flag
    ,p_title                        => g_per_rec.title

    ,p_attribute_category           => g_per_rec.attribute_category
    ,p_attribute1                   => g_per_rec.attribute1
    ,p_attribute2                   => g_per_rec.attribute2
    ,p_attribute3                   => g_per_rec.attribute3
    ,p_attribute4                   => g_per_rec.attribute4
    ,p_attribute5                   => g_per_rec.attribute5
    ,p_attribute6                   => g_per_rec.attribute6
    ,p_attribute7                   => g_per_rec.attribute7
    ,p_attribute8                   => g_per_rec.attribute8
    ,p_attribute9                   => g_per_rec.attribute9
    ,p_attribute10                  => g_per_rec.attribute10
    ,p_attribute11                  => g_per_rec.attribute11
    ,p_attribute12                  => g_per_rec.attribute12
    ,p_attribute13                  => g_per_rec.attribute13
    ,p_attribute14                  => g_per_rec.attribute14
    ,p_attribute15                  => g_per_rec.attribute15
    ,p_attribute16                  => g_per_rec.attribute16
    ,p_attribute17                  => g_per_rec.attribute17
    ,p_attribute18                  => g_per_rec.attribute18
    ,p_attribute19                  => g_per_rec.attribute19
    ,p_attribute20                  => g_per_rec.attribute20
    ,p_attribute21                  => g_per_rec.attribute21
    ,p_attribute22                  => g_per_rec.attribute22
    ,p_attribute23                  => g_per_rec.attribute23
    ,p_attribute24                  => g_per_rec.attribute24
    ,p_attribute25                  => g_per_rec.attribute25
    ,p_attribute26                  => g_per_rec.attribute26
    ,p_attribute27                  => g_per_rec.attribute27
    ,p_attribute28                  => g_per_rec.attribute28
    ,p_attribute29                  => g_per_rec.attribute29
    ,p_attribute30                  => g_per_rec.attribute30

    ,p_per_information_category     => g_per_rec.per_information_category
    ,p_per_information1             => g_per_rec.per_information1
    ,p_per_information2             => g_per_rec.per_information2
    ,p_per_information3             => g_per_rec.per_information3
    ,p_per_information4             => g_per_rec.per_information4
    ,p_per_information5             => g_per_rec.per_information5
    ,p_per_information6             => g_per_rec.per_information6
    ,p_per_information7             => g_per_rec.per_information7
    ,p_per_information8             => g_per_rec.per_information8
    ,p_per_information9             => g_per_rec.per_information9
    ,p_per_information10            => g_per_rec.per_information10
    ,p_per_information11            => g_per_rec.per_information11
    ,p_per_information12            => g_per_rec.per_information12
    ,p_per_information13            => g_per_rec.per_information13
    ,p_per_information14            => g_per_rec.per_information14
    ,p_per_information15            => g_per_rec.per_information15
    ,p_per_information16            => g_per_rec.per_information16
    ,p_per_information17            => g_per_rec.per_information17
    ,p_per_information18            => g_per_rec.per_information18
    ,p_per_information19            => g_per_rec.per_information19
    ,p_per_information20            => g_per_rec.per_information20
    ,p_per_information21            => g_per_rec.per_information21
    ,p_per_information22            => g_per_rec.per_information22
    ,p_per_information23            => g_per_rec.per_information23
    ,p_per_information24            => g_per_rec.per_information24
    ,p_per_information25            => g_per_rec.per_information25
    ,p_per_information26            => g_per_rec.per_information26
    ,p_per_information27            => g_per_rec.per_information27
    ,p_per_information28            => g_per_rec.per_information28
    ,p_per_information29            => g_per_rec.per_information29
    ,p_per_information30            => g_per_rec.per_information30

    ,p_background_check_status      => g_per_rec.background_check_status
    ,p_background_date_check        => g_per_rec.background_date_check
    ,p_fte_capacity                 => g_per_rec.fte_capacity
    ,p_honors                       => g_per_rec.honors
    ,p_on_military_service          => g_per_rec.on_military_service
    ,p_pre_name_adjunct             => g_per_rec.pre_name_adjunct
    ,p_projected_start_date         => g_per_rec.projected_start_date
    ,p_resume_exists                => g_per_rec.resume_exists
    ,p_resume_last_updated          => g_per_rec.resume_last_updated
    ,p_work_schedule                => g_per_rec.work_schedule
    ,p_suffix                       => g_per_rec.suffix
    ,p_uses_tobacco_flag            => g_per_rec.uses_tobacco_flag
    ,p_dpdnt_adoption_date          => g_per_rec.dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag       => g_per_rec.dpdnt_vlntry_svce_flag
    ,p_original_date_of_hire        => g_per_rec.original_date_of_hire
    ,p_town_of_birth                => g_per_rec.town_of_birth
    ,p_region_of_birth              => g_per_rec.region_of_birth
    ,p_country_of_birth             => g_per_rec.country_of_birth
    ,p_global_person_id             => g_per_rec.global_person_id
    ,p_party_id                     => g_per_rec.party_id
    ,p_correspondence_language      => g_per_rec.correspondence_language
 --$ In Batch Lines Benefit Group Name has to be passed instead of ID
    ,p_benefit_group                => g_benefit_grp_name
    );

  end if;
  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

end InsUpd_Batch_Applicant;
-- =============================================================================
-- ~ InsUpd_Batch_ContactPerson:
-- =============================================================================
procedure InsUpd_Batch_ContactPerson
         (p_batch_id                in number
         ,p_data_pump_batch_line_id in number default null
         ,p_user_sequence           in out nocopy number
         ,p_link_value              in number
         ,p_person_user_key         in varchar2
         ,p_user_person_type        in varchar2
          ) is

  l_proc_name  constant     varchar2(150):= g_pkg ||'InsUpd_Batch_ContactPerson';

begin

  hr_utility.set_location('Entering: ' || l_proc_name, 5);

  HrDpp_Create_Person.Insert_Batch_Lines
 (p_batch_id                     => p_batch_id
 ,p_data_pump_batch_line_id      => p_data_pump_batch_line_id
 --,p_data_pump_business_grp_name
 ,p_user_sequence                => p_user_sequence
 ,p_link_value                   => p_link_value
 ,p_person_user_key              => p_person_user_key
 ,p_user_person_type             => p_user_person_type
 ,p_start_date                   => g_per_rec.start_date
 ,p_last_name                    => g_per_rec.last_name
 ,p_sex                          => g_per_rec.sex
 ,p_date_employee_data_verified  => g_per_rec.date_employee_data_verified
 ,p_date_of_birth                => g_per_rec.date_of_birth
 ,p_email_address                => g_per_rec.email_address
 ,p_expense_check_send_to_addres => g_per_rec.expense_check_send_to_address
 ,p_first_name                   => g_per_rec.first_name
 ,p_known_as                     => g_per_rec.known_as
 ,p_marital_status               => g_per_rec.marital_status
 ,p_middle_names                 => g_per_rec.middle_names
 ,p_nationality                  => g_per_rec.nationality
 ,p_national_identifier          => g_per_rec.national_identifier
 ,p_previous_last_name           => g_per_rec.previous_last_name
 ,p_registered_disabled_flag     => g_per_rec.registered_disabled_flag
 ,p_title                        => g_per_rec.title
 ,p_work_telephone               => g_per_rec.work_telephone
 ,p_attribute_category           => g_per_rec.attribute_category
 ,p_attribute1                   => g_per_rec.attribute1
 ,p_attribute2                   => g_per_rec.attribute2
 ,p_attribute3                   => g_per_rec.attribute3
 ,p_attribute4                   => g_per_rec.attribute4
 ,p_attribute5                   => g_per_rec.attribute5
 ,p_attribute6                   => g_per_rec.attribute6
 ,p_attribute7                   => g_per_rec.attribute7
 ,p_attribute8                   => g_per_rec.attribute8
 ,p_attribute9                   => g_per_rec.attribute9
 ,p_attribute10                  => g_per_rec.attribute10
 ,p_attribute11                  => g_per_rec.attribute11
 ,p_attribute12                  => g_per_rec.attribute12
 ,p_attribute13                  => g_per_rec.attribute13
 ,p_attribute14                  => g_per_rec.attribute14
 ,p_attribute15                  => g_per_rec.attribute15
 ,p_attribute16                  => g_per_rec.attribute16
 ,p_attribute17                  => g_per_rec.attribute17
 ,p_attribute18                  => g_per_rec.attribute18
 ,p_attribute19                  => g_per_rec.attribute19
 ,p_attribute20                  => g_per_rec.attribute20
 ,p_attribute21                  => g_per_rec.attribute21
 ,p_attribute22                  => g_per_rec.attribute22
 ,p_attribute23                  => g_per_rec.attribute23
 ,p_attribute24                  => g_per_rec.attribute24
 ,p_attribute25                  => g_per_rec.attribute25
 ,p_attribute26                  => g_per_rec.attribute26
 ,p_attribute27                  => g_per_rec.attribute27
 ,p_attribute28                  => g_per_rec.attribute28
 ,p_attribute29                  => g_per_rec.attribute29
 ,p_attribute30                  => g_per_rec.attribute30

 ,p_per_information_category     => g_per_rec.per_information_category
 ,p_per_information1             => g_per_rec.per_information1
 ,p_per_information2             => g_per_rec.per_information2
 ,p_per_information3             => g_per_rec.per_information3
 ,p_per_information4             => g_per_rec.per_information4
 ,p_per_information5             => g_per_rec.per_information5
 ,p_per_information6             => g_per_rec.per_information6
 ,p_per_information7             => g_per_rec.per_information7
 ,p_per_information8             => g_per_rec.per_information8
 ,p_per_information9             => g_per_rec.per_information9
 ,p_per_information10            => g_per_rec.per_information10
 ,p_per_information11            => g_per_rec.per_information11
 ,p_per_information12            => g_per_rec.per_information12
 ,p_per_information13            => g_per_rec.per_information13
 ,p_per_information14            => g_per_rec.per_information14
 ,p_per_information15            => g_per_rec.per_information15
 ,p_per_information16            => g_per_rec.per_information16
 ,p_per_information17            => g_per_rec.per_information17
 ,p_per_information18            => g_per_rec.per_information18
 ,p_per_information19            => g_per_rec.per_information19
 ,p_per_information20            => g_per_rec.per_information20
 ,p_per_information21            => g_per_rec.per_information21
 ,p_per_information22            => g_per_rec.per_information22
 ,p_per_information23            => g_per_rec.per_information23
 ,p_per_information24            => g_per_rec.per_information24
 ,p_per_information25            => g_per_rec.per_information25
 ,p_per_information26            => g_per_rec.per_information26
 ,p_per_information27            => g_per_rec.per_information27
 ,p_per_information28            => g_per_rec.per_information28
 ,p_per_information29            => g_per_rec.per_information29
 ,p_per_information30            => g_per_rec.per_information30

 ,p_correspondence_language      => g_per_rec.correspondence_language
 ,p_honors                       => g_per_rec.honors
 ,p_on_military_service          => g_per_rec.on_military_service
 ,p_student_status               => g_per_rec.student_status
 ,p_uses_tobacco_flag            => g_per_rec.uses_tobacco_flag
 ,p_coord_ben_no_cvg_flag        => g_per_rec.coord_ben_no_cvg_flag
 ,p_pre_name_adjunct             => g_per_rec.pre_name_adjunct
 ,p_suffix                       => g_per_rec.suffix
 ,p_town_of_birth                => g_per_rec.town_of_birth
 ,p_region_of_birth              => g_per_rec.region_of_birth
 ,p_country_of_birth             => g_per_rec.country_of_birth
 ,p_global_person_id             => g_per_rec.global_person_id
 --,p_vendor_name                  => null

 --$ In Batch Lines Benefit Group Name has to be passed instead of ID
 ,p_benefit_group                => g_benefit_grp_name
 ,p_language_code                => Userenv('lang')
  );
  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

end InsUpd_Batch_ContactPerson;

-- =============================================================================
-- ~ InsUpd_Batch_Employee:
-- =============================================================================
procedure InsUpd_Batch_Employee
         (p_batch_id                in number
         ,p_data_pump_batch_line_id in number default null
         ,p_user_sequence           in out nocopy number
         ,p_link_value              in number
         ,p_assignment_user_key     in varchar2
         ,p_person_user_key         in varchar2
         ,p_user_person_type        in varchar2
         ,p_action_mode             in varchar2
         ,p_datetrack_update_mode   in varchar2
         ,p_cur_rec                 in per_all_people_f%rowtype
         ,p_adjusted_svc_date   in date default null  -- Added by pkagrawa
          ) is

  l_proc_name  constant     varchar2(150):= g_pkg ||'InsUpd_Batch_Employee';

begin

  hr_utility.set_location('Entering: ' || l_proc_name, 5);
  hr_utility.set_location('p_action_mode: ' || p_action_mode, 6);

  if p_action_mode = 'CREATE_EMPLOYEE' then

    Hrdpp_Create_Employee.Insert_Batch_Lines
    (p_batch_id                     => p_batch_id
    ,p_data_pump_batch_line_id      => p_data_pump_batch_line_id
    ,p_user_sequence                => p_user_sequence
    ,p_link_value                   => p_link_value
    ,p_person_user_key              => p_person_user_key
    ,p_assignment_user_key          => p_assignment_user_key
    ,p_user_person_type             => p_user_person_type
    ,p_hire_date                    => g_per_rec.start_date
    ,p_last_name                    => g_per_rec.last_name
    ,p_sex                          => g_per_rec.sex
    ,p_date_employee_data_verified  => g_per_rec.date_employee_data_verified
    ,p_date_of_birth                => g_per_rec.date_of_birth
    ,p_email_address                => g_per_rec.email_address
    ,p_employee_number              => g_per_rec.employee_number
    ,p_expense_check_send_to_addres => g_per_rec.expense_check_send_to_address
    ,p_first_name                   => g_per_rec.first_name
    ,p_known_as                     => g_per_rec.known_as
    ,p_marital_status               => g_per_rec.marital_status
    ,p_middle_names                 => g_per_rec.middle_names
    ,p_nationality                  => g_per_rec.nationality
    ,p_national_identifier          => g_per_rec.national_identifier
    ,p_previous_last_name           => g_per_rec.previous_last_name
    ,p_registered_disabled_flag     => g_per_rec.registered_disabled_flag
    ,p_title                        => g_per_rec.title
    ,p_attribute_category           => g_per_rec.attribute_category
    ,p_attribute1                   => g_per_rec.attribute1
    ,p_attribute2                   => g_per_rec.attribute2
    ,p_attribute3                   => g_per_rec.attribute3
    ,p_attribute4                   => g_per_rec.attribute4
    ,p_attribute5                   => g_per_rec.attribute5
    ,p_attribute6                   => g_per_rec.attribute6
    ,p_attribute7                   => g_per_rec.attribute7
    ,p_attribute8                   => g_per_rec.attribute8
    ,p_attribute9                   => g_per_rec.attribute9
    ,p_attribute10                  => g_per_rec.attribute10
    ,p_attribute11                  => g_per_rec.attribute11
    ,p_attribute12                  => g_per_rec.attribute12
    ,p_attribute13                  => g_per_rec.attribute13
    ,p_attribute14                  => g_per_rec.attribute14
    ,p_attribute15                  => g_per_rec.attribute15
    ,p_attribute16                  => g_per_rec.attribute16
    ,p_attribute17                  => g_per_rec.attribute17
    ,p_attribute18                  => g_per_rec.attribute18
    ,p_attribute19                  => g_per_rec.attribute19
    ,p_attribute20                  => g_per_rec.attribute20
    ,p_attribute21                  => g_per_rec.attribute21
    ,p_attribute22                  => g_per_rec.attribute22
    ,p_attribute23                  => g_per_rec.attribute23
    ,p_attribute24                  => g_per_rec.attribute24
    ,p_attribute25                  => g_per_rec.attribute25
    ,p_attribute26                  => g_per_rec.attribute26
    ,p_attribute27                  => g_per_rec.attribute27
    ,p_attribute28                  => g_per_rec.attribute28
    ,p_attribute29                  => g_per_rec.attribute29
    ,p_attribute30                  => g_per_rec.attribute30
    ,p_per_information_category     => g_per_rec.per_information_category
    ,p_per_information1             => g_per_rec.per_information1
    ,p_per_information2             => g_per_rec.per_information2
    ,p_per_information3             => g_per_rec.per_information3
    ,p_per_information4             => g_per_rec.per_information4
    ,p_per_information5             => g_per_rec.per_information5
    ,p_per_information6             => g_per_rec.per_information6
    ,p_per_information7             => g_per_rec.per_information7
    ,p_per_information8             => g_per_rec.per_information8
    ,p_per_information9             => g_per_rec.per_information9
    ,p_per_information10            => g_per_rec.per_information10
    ,p_per_information11            => g_per_rec.per_information11
    ,p_per_information12            => g_per_rec.per_information12
    ,p_per_information13            => g_per_rec.per_information13
    ,p_per_information14            => g_per_rec.per_information14
    ,p_per_information15            => g_per_rec.per_information15
    ,p_per_information16            => g_per_rec.per_information16
    ,p_per_information17            => g_per_rec.per_information17
    ,p_per_information18            => g_per_rec.per_information18
    ,p_per_information19            => g_per_rec.per_information19
    ,p_per_information20            => g_per_rec.per_information20
    ,p_per_information21            => g_per_rec.per_information21
    ,p_per_information22            => g_per_rec.per_information22
    ,p_per_information23            => g_per_rec.per_information23
    ,p_per_information24            => g_per_rec.per_information24
    ,p_per_information25            => g_per_rec.per_information25
    ,p_per_information26            => g_per_rec.per_information26
    ,p_per_information27            => g_per_rec.per_information27
    ,p_per_information28            => g_per_rec.per_information28
    ,p_per_information29            => g_per_rec.per_information29
    ,p_per_information30            => g_per_rec.per_information30

    ,p_date_of_death                => g_per_rec.date_of_death
    ,p_background_check_status      => g_per_rec.background_check_status
    ,p_background_date_check        => g_per_rec.background_date_check
    ,p_blood_type                   => g_per_rec.blood_type
    ,p_fast_path_employee           => g_per_rec.fast_path_employee
    ,p_fte_capacity                 => g_per_rec.fte_capacity
    ,p_honors                       => g_per_rec.honors
    ,p_internal_location            => g_per_rec.internal_location
    ,p_last_medical_test_by         => g_per_rec.last_medical_test_by
    ,p_last_medical_test_date       => g_per_rec.last_medical_test_date
    ,p_mailstop                     => g_per_rec.mailstop
    ,p_office_number                => g_per_rec.office_number
    ,p_on_military_service          => g_per_rec.on_military_service
    ,p_pre_name_adjunct             => g_per_rec.pre_name_adjunct
    ,p_projected_start_date         => g_per_rec.projected_start_date
    ,p_resume_exists                => g_per_rec.resume_exists
    ,p_resume_last_updated          => g_per_rec.resume_last_updated
    ,p_second_passport_exists       => g_per_rec.second_passport_exists
    ,p_student_status               => g_per_rec.student_status
    ,p_work_schedule                => g_per_rec.work_schedule
    ,p_suffix                       => g_per_rec.suffix
    ,p_receipt_of_death_cert_date   => g_per_rec.receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no         => g_per_rec.coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag        => g_per_rec.coord_ben_no_cvg_flag
    ,p_coord_ben_med_ext_er         => g_per_rec.coord_ben_med_ext_er
    ,p_coord_ben_med_pl_name        => g_per_rec.coord_ben_med_pl_name
    ,p_coord_ben_med_insr_crr_name  => g_per_rec.coord_ben_med_insr_crr_name
    ,p_coord_ben_med_insr_crr_ident => g_per_rec.coord_ben_med_insr_crr_ident
    ,p_coord_ben_med_cvg_strt_dt    => g_per_rec.coord_ben_med_cvg_strt_dt
    ,p_coord_ben_med_cvg_end_dt     => g_per_rec.coord_ben_med_cvg_end_dt
    ,p_uses_tobacco_flag            => g_per_rec.uses_tobacco_flag
    ,p_dpdnt_adoption_date          => g_per_rec.dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag       => g_per_rec.dpdnt_vlntry_svce_flag
    ,p_original_date_of_hire        => g_per_rec.original_date_of_hire
    ,p_town_of_birth                => g_per_rec.town_of_birth
    ,p_region_of_birth              => g_per_rec.region_of_birth
    ,p_country_of_birth             => g_per_rec.country_of_birth
    ,p_global_person_id             => g_per_rec.global_person_id
    ,p_party_id                     => g_per_rec.party_id
    ,p_correspondence_language      => g_per_rec.correspondence_language
--$ In Batch Lines Benefit Group Name has to be passed instead of ID
    ,p_benefit_group                => g_benefit_grp_name
    ,p_language_code                => Userenv('lang')
    --,p_vendor_name                  => null
    ,p_adjusted_svc_date            => p_adjusted_svc_date --Added By pkagrawa
    );

  elsif p_action_mode = 'HIRE_INTO_JOB' then

    hr_pump_utils.add_user_key
      (p_user_key_value => p_person_user_key
      ,p_unique_key_id  => g_per_rec.person_id
       );

    Hrdpp_Hire_Into_Job.Insert_Batch_Lines
    (p_batch_id                     => p_batch_id
    ,p_user_sequence                => p_user_sequence
    ,p_link_value                   => p_link_value
    ,p_effective_date               => g_per_rec.start_date
    ,p_object_version_number        => g_per_rec.object_version_number
    ,p_employee_number              => g_per_rec.employee_number
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_national_identifier          => g_per_rec.national_identifier
    ,p_per_information7             => null
    ,p_person_user_key              => p_person_user_key
    ,p_assignment_user_key          => p_assignment_user_key
    ,p_user_person_type             => p_user_person_type
    ,p_language_code                => Userenv('LANG')
    );

    p_user_sequence := p_user_sequence + 1;

    hr_utility.set_location(' Calling : ' ||
                            'Hrdpp_Update_Person.Insert_Batch_Lines', 7);

    Upd_Batch_Person
    (p_batch_id                => p_batch_id
    ,p_user_sequence           => p_user_sequence
    ,p_link_value              => p_link_value
    ,p_person_user_key         => p_person_user_key
    ,p_user_person_type        => p_user_person_type
    ,p_datetrack_update_mode   => 'CORRECTION'
     );

  end if;
  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

end InsUpd_Batch_Employee;
-- =============================================================================
-- ~ InsUpd_Batch_Address:
-- =============================================================================
procedure InsUpd_Batch_Address
          (p_batch_id             in number
          ,p_user_sequence        in number
          ,p_link_value           in number
          ,p_person_user_key      in varchar2
          ,p_address_user_key     in varchar2
          ) is

--  p_effective_date => g_per_rec.start_date => g_per_rec.start_date := trunc(p_date_of_hire);

  cursor csr_primary_add (c_person_id         in number
		                 ,c_business_group_id in number
		                 ,c_date_from		  in date
		                 ,c_primary_flag      in varchar2) is
  select *
    from per_addresses pad
   where pad.person_id = c_person_id
     and pad.business_group_id = c_business_group_id
     and pad.primary_flag = c_primary_flag
     and c_date_from between pad.date_from
                              and NVL(pad.date_to, c_date_from);

  cursor csr_secondary_add (c_person_id          in number
                 		   ,c_business_group_id  in number
		                   ,c_primary_flag       in varchar2
		                   ,c_style				 in varchar2
		                   ,c_address_type       in varchar2
		                   ,c_date_from			 in date
		                   ,c_effective_date     in date) is
  select *
    from per_addresses pad
   where pad.business_group_id = c_business_group_id
     and pad.person_id = c_person_id
     and pad.primary_flag = c_primary_flag
     and pad.STYLE = c_style
     and nvl(pad.ADDRESS_TYPE,0) = nvl(c_address_type,nvl(pad.ADDRESS_TYPE,0))
     and trunc(pad.date_from) = trunc(c_date_from);
/*     and c_effective_date between pad.date_from
                              and NVL(pad.date_to, c_effective_date); */

  l_cur_add_rec             per_addresses%rowtype;
  l_proc_name  constant     varchar2(150):= g_pkg ||'InsUpd_Batch_Address';
  l_pradd_ovlapval_override boolean;
  l_error_msg               varchar2(2000);

  l_effective_date           date;
begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  l_effective_date := g_add_rec.date_from;

  if g_add_rec.address_line1 is null and g_add_rec.style is null then
      return;
  end if;

--hr_utility.trace('MSG_AD c_person_id='||g_add_rec.person_id);
--hr_utility.trace('MSG_AD c_business_group_id='||g_add_rec.business_group_id);
--hr_utility.trace('MSG_AD c_primary_flag='|| g_add_rec.primary_flag);
--hr_utility.trace('MSG_AD c_effective_date='||l_effective_date);

  l_pradd_ovlapval_override := false;

     if Trunc(g_add_rec.date_from) > Trunc(l_cur_add_rec.date_from) then
        hr_utility.set_location(' g_add_rec.date_from: ' ||g_add_rec.date_from, 40);
        hr_utility.set_location(' g_add_rec.date_to: ' ||g_add_rec.date_to, 40);

        l_pradd_ovlapval_override := true;
     end if;


 IF g_add_rec.primary_flag = 'Y' Then

  open  csr_primary_add(c_person_id         => g_add_rec.person_id
               ,c_business_group_id 		=> g_add_rec.business_group_id
               ,c_date_from			        => g_add_rec.date_from
               ,c_primary_flag      		=> g_add_rec.primary_flag);
  fetch csr_primary_add into l_cur_add_rec;

  if csr_primary_add%notfound then
     hr_utility.set_location(' Primary Address Not found', 20);
     hr_utility.set_location(' Person ID'||g_add_rec.person_id, 25);

--hr_utility.trace('MSG_AD l_effective_date:'||l_effective_date);
--hr_utility.trace('MSG_AD primary_flag:'||g_add_rec.primary_flag);
--hr_utility.trace('MSG_AD address_id:'||g_add_rec.address_id);
--hr_utility.trace('MSG_AD object_version_number:'||g_add_rec.object_version_number);
    if (g_crt_upd = 'C') then
     Hrdpp_Create_Person_Address.Insert_Batch_Lines
    (p_batch_id                 => p_batch_id
    ,p_user_sequence            => p_user_sequence
    ,p_link_value               => p_link_value
    ,p_effective_date           => g_add_rec.date_from
    ,p_pradd_ovlapval_override  => l_pradd_ovlapval_override
    ,p_validate_county          => true
    ,p_primary_flag             => nvl(g_add_rec.primary_flag, 'Y')
    ,p_address_user_key         => p_address_user_key
    ,p_person_user_key          => p_person_user_key
    ,p_style                    => g_add_rec.style
    ,p_date_from                => g_add_rec.date_from
    ,p_date_to                  => g_add_rec.date_to
    ,p_address_type             => g_add_rec.address_type
    ,p_address_line1            => g_add_rec.address_line1
    ,p_address_line2            => g_add_rec.address_line2
    ,p_address_line3            => g_add_rec.address_line3
    ,p_town_or_city             => g_add_rec.town_or_city
    ,p_region_1                 => g_add_rec.region_1
    ,p_region_2                 => g_add_rec.region_2
    ,p_region_3                 => g_add_rec.region_3
    ,p_postal_code              => g_add_rec.postal_code
    ,p_telephone_number_1       => g_add_rec.telephone_number_1
    ,p_telephone_number_2       => g_add_rec.telephone_number_2
    ,p_telephone_number_3       => g_add_rec.telephone_number_3
    ,p_addr_attribute_category  => g_add_rec.addr_attribute_category
    ,p_addr_attribute1          => g_add_rec.addr_attribute1
    ,p_addr_attribute2          => g_add_rec.addr_attribute2
    ,p_addr_attribute3          => g_add_rec.addr_attribute3
    ,p_addr_attribute4          => g_add_rec.addr_attribute4
    ,p_addr_attribute5          => g_add_rec.addr_attribute5
    ,p_addr_attribute6          => g_add_rec.addr_attribute6
    ,p_addr_attribute7          => g_add_rec.addr_attribute7
    ,p_addr_attribute8          => g_add_rec.addr_attribute8
    ,p_addr_attribute9          => g_add_rec.addr_attribute9
    ,p_addr_attribute10         => g_add_rec.addr_attribute10
    ,p_addr_attribute11         => g_add_rec.addr_attribute11
    ,p_addr_attribute12         => g_add_rec.addr_attribute12
    ,p_addr_attribute13         => g_add_rec.addr_attribute13
    ,p_addr_attribute14         => g_add_rec.addr_attribute14
    ,p_addr_attribute15         => g_add_rec.addr_attribute15
    ,p_addr_attribute16         => g_add_rec.addr_attribute16
    ,p_addr_attribute17         => g_add_rec.addr_attribute17
    ,p_addr_attribute18         => g_add_rec.addr_attribute18
    ,p_addr_attribute19         => g_add_rec.addr_attribute19
    ,p_addr_attribute20         => g_add_rec.addr_attribute20
    ,p_add_information13        => g_add_rec.add_information13
    ,p_add_information14        => g_add_rec.add_information14
    ,p_add_information15        => g_add_rec.add_information15
    ,p_add_information16        => g_add_rec.add_information16
    ,p_add_information17        => g_add_rec.add_information17
    ,p_add_information18        => g_add_rec.add_information18
    ,p_add_information19        => g_add_rec.add_information19
    ,p_add_information20        => g_add_rec.add_information20
    ,p_party_id                 => g_add_rec.party_id
    ,p_country                  => g_add_rec.country
    );
    else
        raise e_crt_add_not_allowed;
    end if;
  else
     hr_utility.set_location(' Primary Address found: ' ||
                               l_cur_add_rec.address_id, 30);

     if g_add_rec.date_from is null then
        g_add_rec.date_from := trunc(l_effective_date);
     end if;

--hr_utility.trace('MSG_AD l_effective_date:'||l_effective_date);
--hr_utility.trace('MSG_AD primary_flag:'||g_add_rec.primary_flag);
--hr_utility.trace('MSG_AD address_id:'||g_add_rec.address_id);
--hr_utility.trace('MSG_AD object_version_number:'||g_add_rec.object_version_number);


--hr_utility.trace('MSG_AD 11:'||l_effective_date);

        g_add_rec.address_id := l_cur_add_rec.address_id;
        g_add_rec.object_version_number := l_cur_add_rec.object_version_number;
        g_add_rec.style := l_cur_add_rec.style;

--hr_utility.trace('MSG_AD 12:'||l_effective_date);

    --hr_utility.trace('$$_PSG InsUpd_Batch_Address Y p_address_user_key: '||p_address_user_key);

     hr_pump_utils.add_user_key
     (p_user_key_value => p_address_user_key
     ,p_unique_key_id  => g_add_rec.address_id
      );

     hr_utility.set_location(' HrDpp_Update_Person_Address.Insert_Batch_Lines: ' , 51);
     if (g_crt_upd = 'C' or g_crt_upd = 'U') then
     HrDpp_Update_Person_Address.Insert_Batch_Lines
    (p_batch_id                 => p_batch_id
    ,p_user_sequence            => p_user_sequence
    ,p_link_value               => p_link_value
    --,p_data_pump_batch_line_id     => p_data_pump_batch_line_id
    --,p_data_pump_business_grp_name =>
    ,p_address_user_key         => p_address_user_key
    ,p_effective_date           => g_add_rec.date_from
    ,p_validate_county          => true
    ,p_date_from                => g_add_rec.date_from
    ,p_date_to                  => g_add_rec.date_to
    ,p_primary_flag             => nvl(g_add_rec.primary_flag, 'Y')
    ,p_address_type             => g_add_rec.address_type
    ,p_address_line1            => g_add_rec.address_line1
    ,p_address_line2            => g_add_rec.address_line2
    ,p_address_line3            => g_add_rec.address_line3
    ,p_town_or_city             => g_add_rec.town_or_city
    ,p_region_1                 => g_add_rec.region_1
    ,p_region_2                 => g_add_rec.region_2
    ,p_region_3                 => g_add_rec.region_3
    ,p_postal_code              => g_add_rec.postal_code
    ,p_telephone_number_1       => g_add_rec.telephone_number_1
    ,p_telephone_number_2       => g_add_rec.telephone_number_2
    ,p_telephone_number_3       => g_add_rec.telephone_number_3
    ,p_addr_attribute_category  => g_add_rec.addr_attribute_category
    ,p_addr_attribute1          => g_add_rec.addr_attribute1
    ,p_addr_attribute2          => g_add_rec.addr_attribute2
    ,p_addr_attribute3          => g_add_rec.addr_attribute3
    ,p_addr_attribute4          => g_add_rec.addr_attribute4
    ,p_addr_attribute5          => g_add_rec.addr_attribute5
    ,p_addr_attribute6          => g_add_rec.addr_attribute6
    ,p_addr_attribute7          => g_add_rec.addr_attribute7
    ,p_addr_attribute8          => g_add_rec.addr_attribute8
    ,p_addr_attribute9          => g_add_rec.addr_attribute9
    ,p_addr_attribute10         => g_add_rec.addr_attribute10
    ,p_addr_attribute11         => g_add_rec.addr_attribute11
    ,p_addr_attribute12         => g_add_rec.addr_attribute12
    ,p_addr_attribute13         => g_add_rec.addr_attribute13
    ,p_addr_attribute14         => g_add_rec.addr_attribute14
    ,p_addr_attribute15         => g_add_rec.addr_attribute15
    ,p_addr_attribute16         => g_add_rec.addr_attribute16
    ,p_addr_attribute17         => g_add_rec.addr_attribute17
    ,p_addr_attribute18         => g_add_rec.addr_attribute18
    ,p_addr_attribute19         => g_add_rec.addr_attribute19
    ,p_addr_attribute20         => g_add_rec.addr_attribute20
    ,p_party_id                 => g_add_rec.party_id
    ,p_country                  => g_add_rec.country
    );
    else
       raise e_upl_not_allowed;
    end if;
  end if;

--hr_utility.trace('MSG_AD 13:'||l_effective_date);

--  end if;
  close csr_primary_add;

-- For Secondary Address

 ELSIF g_add_rec.primary_flag = 'N' Then

--hr_utility.trace('Testing cursor');
--hr_utility.trace('c_person_id :'||g_add_rec.person_id);
--hr_utility.trace('c_business_group_id :'||g_add_rec.business_group_id);
--hr_utility.trace('c_primary_flag :'||g_add_rec.primary_flag);
--hr_utility.trace('c_style :'||g_add_rec.style);
--hr_utility.trace('c_address_type :'||g_add_rec.address_type);
--hr_utility.trace('c_date_from :'||g_add_rec.date_from);
--hr_utility.trace('c_effective_date :'||l_effective_date);

    open csr_secondary_add (c_person_id          => g_add_rec.person_id
                 		   ,c_business_group_id  => g_add_rec.business_group_id
		                   ,c_primary_flag       => g_add_rec.primary_flag
		                   ,c_style				 => g_add_rec.style
		                   ,c_address_type       => g_add_rec.address_type
  		                   ,c_date_from			 => g_add_rec.date_from
		                   ,c_effective_date     => l_effective_date);

		  fetch csr_secondary_add into l_cur_add_rec;

  if csr_secondary_add%notfound then
     hr_utility.set_location(' Secondary Address Not found', 40);
     hr_utility.set_location(' Person ID'||g_add_rec.person_id, 45);
     if (g_crt_upd = 'C') then
     Hrdpp_Create_Person_Address.Insert_Batch_Lines
    (p_batch_id                 => p_batch_id
    ,p_user_sequence            => p_user_sequence
    ,p_link_value               => p_link_value
    ,p_effective_date           => g_add_rec.date_from
    ,p_pradd_ovlapval_override  => l_pradd_ovlapval_override
    ,p_validate_county          => true
    ,p_primary_flag             => nvl(g_add_rec.primary_flag, 'Y')
    ,p_address_user_key         => p_address_user_key
    ,p_person_user_key          => p_person_user_key
    ,p_style                    => g_add_rec.style
    ,p_date_from                => g_add_rec.date_from
    ,p_date_to                  => g_add_rec.date_to
    ,p_address_type             => g_add_rec.address_type
    ,p_address_line1            => g_add_rec.address_line1
    ,p_address_line2            => g_add_rec.address_line2
    ,p_address_line3            => g_add_rec.address_line3
    ,p_town_or_city             => g_add_rec.town_or_city
    ,p_region_1                 => g_add_rec.region_1
    ,p_region_2                 => g_add_rec.region_2
    ,p_region_3                 => g_add_rec.region_3
    ,p_postal_code              => g_add_rec.postal_code
    ,p_telephone_number_1       => g_add_rec.telephone_number_1
    ,p_telephone_number_2       => g_add_rec.telephone_number_2
    ,p_telephone_number_3       => g_add_rec.telephone_number_3
    ,p_addr_attribute_category  => g_add_rec.addr_attribute_category
    ,p_addr_attribute1          => g_add_rec.addr_attribute1
    ,p_addr_attribute2          => g_add_rec.addr_attribute2
    ,p_addr_attribute3          => g_add_rec.addr_attribute3
    ,p_addr_attribute4          => g_add_rec.addr_attribute4
    ,p_addr_attribute5          => g_add_rec.addr_attribute5
    ,p_addr_attribute6          => g_add_rec.addr_attribute6
    ,p_addr_attribute7          => g_add_rec.addr_attribute7
    ,p_addr_attribute8          => g_add_rec.addr_attribute8
    ,p_addr_attribute9          => g_add_rec.addr_attribute9
    ,p_addr_attribute10         => g_add_rec.addr_attribute10
    ,p_addr_attribute11         => g_add_rec.addr_attribute11
    ,p_addr_attribute12         => g_add_rec.addr_attribute12
    ,p_addr_attribute13         => g_add_rec.addr_attribute13
    ,p_addr_attribute14         => g_add_rec.addr_attribute14
    ,p_addr_attribute15         => g_add_rec.addr_attribute15
    ,p_addr_attribute16         => g_add_rec.addr_attribute16
    ,p_addr_attribute17         => g_add_rec.addr_attribute17
    ,p_addr_attribute18         => g_add_rec.addr_attribute18
    ,p_addr_attribute19         => g_add_rec.addr_attribute19
    ,p_addr_attribute20         => g_add_rec.addr_attribute20
    ,p_add_information13        => g_add_rec.add_information13
    ,p_add_information14        => g_add_rec.add_information14
    ,p_add_information15        => g_add_rec.add_information15
    ,p_add_information16        => g_add_rec.add_information16
    ,p_add_information17        => g_add_rec.add_information17
    ,p_add_information18        => g_add_rec.add_information18
    ,p_add_information19        => g_add_rec.add_information19
    ,p_add_information20        => g_add_rec.add_information20
    ,p_party_id                 => g_add_rec.party_id
    ,p_country                  => g_add_rec.country
    );
    else
        raise e_crt_add_not_allowed;
    end if;
  else
     hr_utility.set_location(' Secondary Address found: ' ||
                               l_cur_add_rec.address_id, 50);
     if g_add_rec.date_from is null then
        g_add_rec.date_from := trunc(l_effective_date);
     end if;

        g_add_rec.address_id := l_cur_add_rec.address_id;
        g_add_rec.object_version_number := l_cur_add_rec.object_version_number;
        g_add_rec.style := l_cur_add_rec.style;

    --hr_utility.trace('$$_PSG InsUpd_Batch_Address N p_address_user_key: '||p_address_user_key);

     hr_pump_utils.add_user_key
     (p_user_key_value => p_address_user_key
     ,p_unique_key_id  => g_add_rec.address_id
      );

     hr_utility.set_location(' Hrdpp_Create_Person_Address.Insert_Batch_Lines: ' , 51);
     if (g_crt_upd = 'C' or g_crt_upd = 'U') then
     HrDpp_Update_Person_Address.Insert_Batch_Lines
    (p_batch_id                 => p_batch_id
    ,p_user_sequence            => p_user_sequence
    ,p_link_value               => p_link_value
    --,p_data_pump_batch_line_id     => p_data_pump_batch_line_id
    --,p_data_pump_business_grp_name =>
    ,p_address_user_key         => p_address_user_key
    ,p_effective_date           => g_add_rec.date_from
    ,p_validate_county          => true
    ,p_date_from                => g_add_rec.date_from
    ,p_date_to                  => g_add_rec.date_to
    ,p_primary_flag             => nvl(g_add_rec.primary_flag, 'Y')
    ,p_address_type             => g_add_rec.address_type
    ,p_address_line1            => g_add_rec.address_line1
    ,p_address_line2            => g_add_rec.address_line2
    ,p_address_line3            => g_add_rec.address_line3
    ,p_town_or_city             => g_add_rec.town_or_city
    ,p_region_1                 => g_add_rec.region_1
    ,p_region_2                 => g_add_rec.region_2
    ,p_region_3                 => g_add_rec.region_3
    ,p_postal_code              => g_add_rec.postal_code
    ,p_telephone_number_1       => g_add_rec.telephone_number_1
    ,p_telephone_number_2       => g_add_rec.telephone_number_2
    ,p_telephone_number_3       => g_add_rec.telephone_number_3
    ,p_addr_attribute_category  => g_add_rec.addr_attribute_category
    ,p_addr_attribute1          => g_add_rec.addr_attribute1
    ,p_addr_attribute2          => g_add_rec.addr_attribute2
    ,p_addr_attribute3          => g_add_rec.addr_attribute3
    ,p_addr_attribute4          => g_add_rec.addr_attribute4
    ,p_addr_attribute5          => g_add_rec.addr_attribute5
    ,p_addr_attribute6          => g_add_rec.addr_attribute6
    ,p_addr_attribute7          => g_add_rec.addr_attribute7
    ,p_addr_attribute8          => g_add_rec.addr_attribute8
    ,p_addr_attribute9          => g_add_rec.addr_attribute9
    ,p_addr_attribute10         => g_add_rec.addr_attribute10
    ,p_addr_attribute11         => g_add_rec.addr_attribute11
    ,p_addr_attribute12         => g_add_rec.addr_attribute12
    ,p_addr_attribute13         => g_add_rec.addr_attribute13
    ,p_addr_attribute14         => g_add_rec.addr_attribute14
    ,p_addr_attribute15         => g_add_rec.addr_attribute15
    ,p_addr_attribute16         => g_add_rec.addr_attribute16
    ,p_addr_attribute17         => g_add_rec.addr_attribute17
    ,p_addr_attribute18         => g_add_rec.addr_attribute18
    ,p_addr_attribute19         => g_add_rec.addr_attribute19
    ,p_addr_attribute20         => g_add_rec.addr_attribute20
    ,p_party_id                 => g_add_rec.party_id
    ,p_country                  => g_add_rec.country
    );
     else
      raise e_upl_not_allowed;
     end if;
  end if;
    close csr_secondary_add;
 end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 60);

exception
   when Others then
   if  csr_primary_add%isopen then
    close csr_primary_add;
   end if;

   if  csr_secondary_add%isopen then
    close csr_secondary_add;
   end if;

   --l_error_msg := Substr(SQLERRM,1,2000);
   hr_utility.set_location('SQLCODE :' || SQLCODE,90);
   hr_utility.set_location('SQLERRM :' || SQLERRM,90);
   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
   hr_utility.set_location('Leaving: ' || l_proc_name, 90);
   hr_utility.raise_error;

end InsUpd_Batch_Address;

-- =============================================================================
-- ~ InsUpd_Address:
-- =============================================================================
-- Changed procedure
 procedure InsUpd_Address
          (p_effective_date           in date
          ,p_HR_address_id            out NOCOPY number
          ,p_HR_object_version_number out NOCOPY number ) as

--  p_effective_date => g_per_rec.start_date => g_per_rec.start_date := trunc(p_date_of_hire);

  cursor csr_primary_add (c_person_id         in number
		                 ,c_business_group_id in number
		                 ,c_date_from		  in date
		                 ,c_primary_flag      in varchar2) is
  select *
    from per_addresses pad
   where pad.person_id = c_person_id
     and pad.business_group_id = c_business_group_id
     and pad.primary_flag = c_primary_flag
     and c_date_from between pad.date_from
                              and NVL(pad.date_to, c_date_from);

  cursor csr_secondary_add (c_person_id          in number
                 		   ,c_business_group_id  in number
		                   ,c_primary_flag       in varchar2
		                   ,c_style				 in varchar2
		                   ,c_address_type       in varchar2
		                   ,c_date_from			 in date
		                   ,c_effective_date     in date) is
  select *
    from per_addresses pad
   where pad.business_group_id = c_business_group_id
     and pad.person_id = c_person_id
     and pad.primary_flag = c_primary_flag
     and pad.STYLE = c_style
     and nvl(pad.ADDRESS_TYPE,0) = nvl(c_address_type,nvl(pad.ADDRESS_TYPE,0))
     and trunc(pad.date_from) = trunc(c_date_from);
/*     and c_effective_date between pad.date_from
                              and NVL(pad.date_to, c_effective_date); */

  l_cur_add_rec            per_addresses%rowtype;
  l_proc_name  constant    varchar2(150):= g_pkg ||'InsUpd_Address';
  l_error_msg              varchar2(2000);
  l_party_id               per_people_f.party_id%type;


begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  if g_add_rec.address_line1 is null and g_add_rec.style is null then
      return;
  end if;

--hr_utility.trace('MSG_AD c_person_id='||g_add_rec.person_id);
--hr_utility.trace('MSG_AD c_business_group_id='||g_add_rec.business_group_id);
--hr_utility.trace('MSG_AD c_primary_flag='|| g_add_rec.primary_flag);
--hr_utility.trace('MSG_AD c_effective_date='||p_effective_date);


 IF g_add_rec.primary_flag = 'Y' Then

  open  csr_primary_add(c_person_id         => g_add_rec.person_id
               ,c_business_group_id 		=> g_add_rec.business_group_id
               ,c_date_from			        => g_add_rec.date_from
               ,c_primary_flag      		=> g_add_rec.primary_flag);
  fetch csr_primary_add into l_cur_add_rec;

  if csr_primary_add%notfound then
     hr_utility.set_location(' Primary Address Not found', 20);
     hr_utility.set_location(' Person ID'||g_add_rec.person_id, 25);

--hr_utility.trace('MSG_AD p_effective_date:'||p_effective_date);
--hr_utility.trace('MSG_AD primary_flag:'||g_add_rec.primary_flag);
--hr_utility.trace('MSG_AD address_id:'||g_add_rec.address_id);
--hr_utility.trace('MSG_AD object_version_number:'||g_add_rec.object_version_number);
    if (g_crt_upd = 'C') then
     Pqp_Hrtca_Integration.Person_Address_Api
     (p_HR_Address_Rec           => g_add_rec
     ,p_validate                 => false
     ,p_action                   => 'CREATE'
     ,p_effective_date           => p_effective_date
     ,p_pradd_ovlapval_override  => false
     ,p_primary_flag             => NVL(g_add_rec.primary_flag,'Y') --'Y'
     ,p_validate_county          => true
     ,p_HR_address_id            => g_add_rec.address_id
     ,p_HR_object_version_number => g_add_rec.object_version_number
     );
    else
        raise e_crt_add_not_allowed;
    end if;
  else
     hr_utility.set_location(' Primary Address found: ' ||
                               l_cur_add_rec.address_id, 30);

     if g_add_rec.date_from is null then
        g_add_rec.date_from := trunc(p_effective_date);
     end if;

--hr_utility.trace('MSG_AD p_effective_date:'||p_effective_date);
--hr_utility.trace('MSG_AD primary_flag:'||g_add_rec.primary_flag);
--hr_utility.trace('MSG_AD address_id:'||g_add_rec.address_id);
--hr_utility.trace('MSG_AD object_version_number:'||g_add_rec.object_version_number);


--hr_utility.trace('MSG_AD 11:'||p_effective_date);

        g_add_rec.address_id := l_cur_add_rec.address_id;
        g_add_rec.object_version_number := l_cur_add_rec.object_version_number;
        g_add_rec.style := l_cur_add_rec.style;

--hr_utility.trace('MSG_AD 12:'||p_effective_date);
     if (g_crt_upd = 'C' or g_crt_upd = 'U') then
       Pqp_Hrtca_Integration.Person_Address_Api
        (p_HR_Address_Rec           => g_add_rec
        ,p_validate                 => false
        ,p_action                   => 'UPDATE'
        ,p_effective_date           => trunc(g_add_rec.date_from)
        ,p_pradd_ovlapval_override  => false
        ,p_primary_flag             => g_add_rec.primary_flag -- 'Y'
        ,p_validate_county          => true
        ,p_HR_address_id            => g_add_rec.address_id
        ,p_HR_object_version_number => g_add_rec.object_version_number
        );
     else
        raise e_upl_not_allowed;
     end if;
--hr_utility.trace('MSG_AD 13:'||p_effective_date);

  end if;
  close csr_primary_add;
-- For Secondary Address
 ELSIF g_add_rec.primary_flag = 'N' Then

--hr_utility.trace('Testing cursor');
--hr_utility.trace('c_person_id :'||g_add_rec.person_id);
--hr_utility.trace('c_business_group_id :'||g_add_rec.business_group_id);
--hr_utility.trace('c_primary_flag :'||g_add_rec.primary_flag);
--hr_utility.trace('c_style :'||g_add_rec.style);
--hr_utility.trace('c_address_type :'||g_add_rec.address_type);
--hr_utility.trace('c_date_from :'||g_add_rec.date_from);
--hr_utility.trace('c_effective_date :'||p_effective_date);

    open csr_secondary_add (c_person_id          => g_add_rec.person_id
                 		   ,c_business_group_id  => g_add_rec.business_group_id
		                   ,c_primary_flag       => g_add_rec.primary_flag
		                   ,c_style				 => g_add_rec.style
		                   ,c_address_type       => g_add_rec.address_type
  		                   ,c_date_from			 => g_add_rec.date_from
		                   ,c_effective_date     => p_effective_date);

		  fetch csr_secondary_add into l_cur_add_rec;

  if csr_secondary_add%notfound then
     hr_utility.set_location(' Secondary Address Not found', 40);
     hr_utility.set_location(' Person ID'||g_add_rec.person_id, 45);
    if (g_crt_upd = 'C') then
     Pqp_Hrtca_Integration.Person_Address_Api
     (p_HR_Address_Rec           => g_add_rec
     ,p_validate                 => false
     ,p_action                   => 'CREATE'
     ,p_effective_date           => p_effective_date
     ,p_pradd_ovlapval_override  => false
     ,p_primary_flag             => g_add_rec.primary_flag
     ,p_validate_county          => true
     ,p_HR_address_id            => g_add_rec.address_id
     ,p_HR_object_version_number => g_add_rec.object_version_number
     );
    else
        raise e_crt_add_not_allowed;
    end if;
  else
     hr_utility.set_location(' Secondary Address found: ' ||
                               l_cur_add_rec.address_id, 50);
     if g_add_rec.date_from is null then
        g_add_rec.date_from := trunc(p_effective_date);
     end if;

        g_add_rec.address_id := l_cur_add_rec.address_id;
        g_add_rec.object_version_number := l_cur_add_rec.object_version_number;
        g_add_rec.style := l_cur_add_rec.style;
       if (g_crt_upd = 'C' or g_crt_upd = 'U') then
        Pqp_Hrtca_Integration.Person_Address_Api
        (p_HR_Address_Rec           => g_add_rec
        ,p_validate                 => false
        ,p_action                   => 'UPDATE'
        ,p_effective_date           => trunc(g_add_rec.date_from)
        ,p_pradd_ovlapval_override  => false
        ,p_primary_flag             => g_add_rec.primary_flag -- 'N'
        ,p_validate_county          => true
        ,p_HR_address_id            => g_add_rec.address_id
        ,p_HR_object_version_number => g_add_rec.object_version_number
        );
        else
         raise e_upl_not_allowed;
        end if;
  end if;
    close csr_secondary_add;
 end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 60);

exception
   when Others then
   if  csr_primary_add%isopen then
    close csr_primary_add;
   end if;

   if  csr_secondary_add%isopen then
    close csr_secondary_add;
   end if;

   --l_error_msg := Substr(SQLERRM,1,2000);
   hr_utility.set_location('SQLCODE :' || SQLCODE,90);
   hr_utility.set_location('SQLERRM :' || SQLERRM,90);
   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
   hr_utility.set_location('Leaving: ' || l_proc_name, 90);
   hr_utility.raise_error;

end InsUpd_Address;
-- =============================================================================
-- ~ Upd_Person_Details:
-- =============================================================================
procedure Upd_Person_Details
         (p_validate            in boolean
         ,p_effective_date      in date
         ,p_person_id           number
         ,p_adjusted_svc_date   date       default null
         ,p_updper_api_out      out NOCOPY t_UpdEmp_Api
          ) as

  l_cur_per_rec            per_all_people_f%rowtype;
  l_per_rec                per_all_people_f%rowtype;
  l_ptu_rec                chk_perType_usage%rowtype;
  l_datetrack_update_mode  varchar2(50);
  l_dt_correction          boolean;
  l_dt_update              boolean;
  l_dt_upd_override        boolean;
  l_upd_chg_ins            boolean;
  e_future_chgs_exists     exception;
  l_error_msg              varchar2(3000);
  l_proc_name  constant    varchar2(150):= g_pkg ||'Upd_Person_Details';

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  l_per_rec := Get_PerRecord_Values(g_interface_code);

  open  csr_per(c_person_id         => g_per_rec.person_id
               ,c_business_group_id => g_per_rec.business_group_id
               ,c_effective_date    => p_effective_date);
  fetch csr_per into l_cur_per_rec;
  close csr_per;

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

  if l_dt_update then
     l_datetrack_update_mode := 'UPDATE';
  elsif l_dt_upd_override or
        l_upd_chg_ins then
        -- Need to check if person type in future is EMP, APL or CWK , if yes
        -- then raise error
        open chk_perType_usage
           (c_person_id         => l_cur_per_rec.person_id
           ,c_effective_date    => p_effective_date
           ,c_business_group_id => g_per_rec.business_group_id);
        fetch chk_perType_usage into l_ptu_rec;
        if chk_perType_usage%found then
           close chk_perType_usage;
           raise e_future_chgs_exists;
        end if;
        --$ If no change in person type in future CORRECT the record
        l_datetrack_update_mode := 'CORRECTION';
        close chk_perType_usage;
  else
     l_datetrack_update_mode := 'CORRECTION';
  end if;

  hr_utility.set_location(' l_datetrack_update_mode: ' ||
                            l_datetrack_update_mode, 30);
  hr_utility.set_location(' employee_number: ' ||
                            l_cur_per_rec.employee_number, 30);
  hr_utility.set_location(' per ovn: ' ||
                            l_cur_per_rec.object_version_number, 30);

  -- Need to pass the employee number when updating the person
  g_per_rec.object_version_number := l_cur_per_rec.object_version_number;
  l_cur_per_rec.employee_number   := nvl(g_per_rec.employee_number,
                                         l_cur_per_rec.employee_number);
  Hr_Person_Api.Update_Person
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => l_datetrack_update_mode
  ,p_person_id                    => l_cur_per_rec.person_id
  ,p_party_id                     => nvl(g_per_rec.party_id,
                                         l_cur_per_rec.party_id)
  ,p_object_version_number        => l_cur_per_rec.object_version_number
  ,p_employee_number              => l_cur_per_rec.employee_number
  ,p_applicant_number             => nvl(g_per_rec.applicant_number,
                                         l_cur_per_rec.applicant_number)
  ,p_npw_number                   => nvl(g_per_rec.npw_number,
                                         l_cur_per_rec.npw_number)
  ,p_last_name                    => l_per_rec.last_name
  ,p_first_name                   => l_per_rec.first_name
  ,p_date_of_birth                => l_per_rec.date_of_birth
  ,p_marital_status               => l_per_rec.marital_status
  ,p_middle_names                 => l_per_rec.middle_names
  ,p_sex                          => l_per_rec.sex
  ,p_title                        => l_per_rec.title
  ,p_nationality                  => l_per_rec.nationality
  ,p_national_identifier          => l_per_rec.national_identifier
  ,p_previous_last_name           => l_per_rec.previous_last_name
  ,p_known_as                     => l_per_rec.known_as
  ,p_email_address                => l_per_rec.email_address
  ,p_registered_disabled_flag     => l_per_rec.registered_disabled_flag
  ,p_date_employee_data_verified  => l_per_rec.date_employee_data_verified
  ,p_expense_check_send_to_addres => l_per_rec.expense_check_send_to_address
  --Added by Dbansal
  ,p_comments                     => g_per_comments
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

  ,p_date_of_death                => l_per_rec.date_of_death
  ,p_background_check_status      => l_per_rec.background_check_status
  ,p_background_date_check        => l_per_rec.background_date_check
  ,p_blood_type                   => l_per_rec.blood_type
  ,p_correspondence_language      => l_per_rec.correspondence_language
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
  ,p_town_of_birth                => l_per_rec.town_of_birth
  ,p_region_of_birth              => l_per_rec.region_of_birth
  ,p_country_of_birth             => l_per_rec.country_of_birth
  ,p_global_person_id             => l_per_rec.global_person_id
   -- Out Variables
  ,p_effective_start_date         => p_updper_api_out.effective_start_date
  ,p_effective_end_date           => p_updper_api_out.effective_end_date
  ,p_full_name                    => p_updper_api_out.full_name
  ,p_comment_id                   => p_updper_api_out.comment_id
  ,p_name_combination_warning     => p_updper_api_out.name_combination_warning
  ,p_assign_payroll_warning       => p_updper_api_out.assign_payroll_warning
  ,p_orig_hire_warning            => p_updper_api_out.orig_hire_warning
  ,p_adjusted_svc_date            => p_adjusted_svc_date --Uncommented by pkagrawa
  );

  if g_debug then
    hr_utility.set_location('..effective_start_date : ' ||
                             p_updper_api_out.effective_start_date,40);
    hr_utility.set_location('..effective_end_date   : ' ||
                             p_updper_api_out.effective_end_date,40);
    hr_utility.set_location('..full_name            : ' ||
                             p_updper_api_out.full_name,40);
    hr_utility.set_location('Leaving: ' || l_proc_name, 40);
  end if;

exception
  when e_future_chgs_exists then
    l_error_msg := 'This person cannot be created in HRMS as a Student '||
                   'Employee due to future changes beyond the date: '||p_effective_date;

    hr_utility.set_location('..Future Update exists for the Student Employee', 60);
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
    hr_utility.set_location('Leaving: ' || l_proc_name, 60);
    hr_utility.raise_error;

  when Others then
  hr_utility.set_location('SQLERRM :' || SQLCODE,90);
  hr_utility.set_location('Leaving: ' || l_proc_name, 90);
  raise;

end Upd_Person_Details;
-- =============================================================================
-- ~ Hire_Applicant_IntoEmp:
-- =============================================================================
procedure Hire_Applicant_IntoEmp
         (p_validate            boolean  default false
         ,p_hire_date           date
         ,p_person_id           number
         ,p_assignment_id       number
         ,p_adjusted_svc_date   date     default null
         ,p_updper_api_out      out NOCOPY t_UpdEmp_Api
         ,p_HireAppapi_out      out NOCOPY t_HrApp_Api
         ) as

  cursor csr_asg (c_person_id in number
                 ,c_business_group_id in number
                 ,c_effective_date in date
                 ,c_asg_type in varchar2
                 ,c_assignment_id in number) is
  select paf.assignment_id
        ,ppf.person_id
        ,ppf.object_version_number per_ovn
        ,paf.object_version_number asg_ovn
	,paf.effective_start_date -- For Hiring an applicant on the next day
    from per_all_assignments_f paf
        ,per_all_people_f      ppf
   where paf.person_id = c_person_id
     and paf.business_group_id = c_business_group_id
     and paf.assignment_type = c_asg_type
     and paf.assignment_id = c_assignment_id
     and paf.person_id = ppf.person_id
     and c_effective_date between ppf.effective_start_date
                              and ppf.effective_end_date
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;

   cursor diff_date (date1 in date
         	     ,date2 in date) is
   select date1-date2      from dual;

  l_UpdEmp_Api             t_UpdEmp_Api;
  l_perasg_rec             csr_asg%rowtype;
  l_cur_per_rec            csr_per%rowtype;
  l_accpetd_asg_rec        csr_accepted_asgs%rowtype;
  l_asg_status_rec         csr_asg_status%rowtype;
  l_datetrack_update_mode  varchar2(50);
  l_dt_correction          boolean;
  l_dt_update              boolean;
  l_dt_upd_override        boolean;
  l_upd_chg_ins            boolean;
  l_error_msg              varchar2(2000);
  l_proc_name  constant    varchar2(150):= g_pkg ||'Hire_Applicant_IntoEmp';
  l_assignment_id          number;
  l_appl_asg_start_date    date;
  l_appl_asg_end_date      date;
  l_accp_asg_count         number;
  l_hire_all_accepted_asgs varchar2(3);
  l_not_accp_asg_count     number;
  l_tot_appl_asgs          number;
  l_effective_date         date;
  l_unaccepted_asg_del_warning boolean;
  l_diff_date		   number; -- For Hiring applicant on the next day.

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  g_debug := hr_utility.debug_enabled;
  l_effective_date := p_hire_date;

  -- Get the person details for the person
  open  csr_per(c_person_id         => g_per_rec.person_id
               ,c_business_group_id => g_per_rec.business_group_id
               ,c_effective_date    => l_effective_date);
  fetch csr_per into l_cur_per_rec;
  close csr_per;
  hr_utility.set_location(' l_cur_per_rec: ' || l_cur_per_rec.person_id, 20);

  -- Get the Applicant assignment details
  open  csr_asg (c_person_id         => g_per_rec.person_id
                ,c_business_group_id => g_per_rec.business_group_id
                ,c_effective_date    => l_effective_date
                ,c_asg_type          => 'A'
                ,c_assignment_id     => p_assignment_id);
  fetch csr_asg into l_perasg_rec;
  close csr_asg;

  if g_debug then
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
  end if;
  l_accp_asg_count := 0;
  for accp_ags in csr_accepted_asgs
                 (c_person_id         => g_per_rec.person_id
                 ,c_business_group_id => g_per_rec.business_group_id
                 ,c_effective_date    => l_effective_date
                 ,c_assignment_id     => p_assignment_id)
  loop
    l_accp_asg_count := l_accp_asg_count + 1;
  end loop;

  open diff_date (date1 =>l_effective_date
		  ,date2 => l_perasg_rec.effective_start_date);
  fetch diff_date into l_diff_date;

  hr_utility.set_location(' l_diff_date: ' || l_diff_date, 40);

  if l_accp_asg_count < 1 then
    -- Means the Applicant Assignment is not accepted, so update the applicant
    -- as accepted as of the hire date.
    hr_utility.set_location(' Asg Id NOT Accepted : ' || p_assignment_id, 40);
        if l_diff_date = 1 then  -- Means The Applicant Assignment is to be corrected to
    Dt_Api.Find_DT_Upd_Modes -- Accepted.
    (p_effective_date        => l_perasg_rec.effective_start_date
    ,p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F'
    ,p_base_key_column       => 'ASSIGNMENT_ID'
    ,p_base_key_value        => p_assignment_id
    ,p_correction            => l_dt_correction
    ,p_update                => l_dt_update
    ,p_update_override       => l_dt_upd_override
    ,p_update_change_insert  => l_upd_chg_ins
     );
    else
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
     end if;

    -- Get the date-track mode
    if l_dt_update then
       l_datetrack_update_mode := 'UPDATE';
    elsif l_dt_upd_override or
          l_upd_chg_ins then
          -- Need to check if person has future asgs changes, if yes
          -- then raise error
          l_datetrack_update_mode := 'CORRECTION';
    else
       l_datetrack_update_mode := 'CORRECTION';
    end if;
    hr_utility.set_location(' DT Mode for Update of Appl Asg : ' ||
                              l_datetrack_update_mode, 50);

    -- Get the Accepted Applicant Status Id
    open csr_asg_status (c_leg_code          => g_leg_code
                        ,c_business_group_id => g_per_rec.business_group_id
                        );
    fetch csr_asg_status into l_asg_status_rec;
    close csr_asg_status;
    hr_utility.set_location(' Accepted Asg Status ID: ' ||
                              l_asg_status_rec.assignment_status_type_id, 60);

    -- Now accept the Applicant assigment used to hire the person
    HR_Assignment_API.Accept_APL_Asg
    (p_validate                    => false
    ,p_effective_date              => l_effective_date-1
    ,p_datetrack_update_mode       => l_datetrack_update_mode
    ,p_assignment_id               => p_assignment_id
    ,p_object_version_number       => l_perasg_rec.asg_ovn
    ,p_assignment_status_type_id   => l_asg_status_rec.assignment_status_type_id
    ,p_change_reason               => null
    ,p_effective_start_date        => l_appl_asg_start_date
    ,p_effective_end_date          => l_appl_asg_end_date
    );
    if g_debug then
     hr_utility.set_location(' l_appl_asg_start_date: ' ||
                               l_appl_asg_start_date, 70);
     hr_utility.set_location(' l_appl_asg_end_date: ' ||
                               l_appl_asg_end_date, 70);
     hr_utility.set_location(' l_perasg_rec.asg_ovn: ' ||
                               l_perasg_rec.asg_ovn, 70);
    end if;

    -- Get again the person details for the person
    open  csr_per(c_person_id         => g_per_rec.person_id
                 ,c_business_group_id => g_per_rec.business_group_id
                 ,c_effective_date    => l_effective_date);
    fetch csr_per into l_cur_per_rec;
    close csr_per;
    hr_utility.set_location(' per_rec.ovn: ' ||
                              l_cur_per_rec.object_version_number, 80);
  else
    hr_utility.set_location(' Asg Id Accepted Already: ' ||
                              p_assignment_id, 90);
  end if;

  -- Get the count of accepted Applicant Assignments
  l_accp_asg_count := 0;
  for accp_ags in csr_accepted_asgs
                 (c_person_id         => g_per_rec.person_id
                 ,c_business_group_id => g_per_rec.business_group_id
                 ,c_effective_date    => l_effective_date
                 ,c_assignment_id     => null)
  loop
    l_accp_asg_count := l_accp_asg_count +1;
  end loop;

  -- Get the count of not accepted Applicant Assignments
  l_not_accp_asg_count := 0;
  for accp_ags in csr_not_accepted_asgs
                 (c_person_id         => g_per_rec.person_id
                 ,c_business_group_id => g_per_rec.business_group_id
                 ,c_effective_date    => l_effective_date
                 ,c_assignment_id     => null)
  loop
    l_not_accp_asg_count := l_not_accp_asg_count +1;
  end loop;
  -- Get the total no. of Applicant assignments
  l_tot_appl_asgs := l_accp_asg_count + l_not_accp_asg_count;

  if l_tot_appl_asgs = 1 then
     l_hire_all_accepted_asgs := 'Y';
  elsif l_tot_appl_asgs > 2 then
     l_hire_all_accepted_asgs := 'N';
  end if;

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
  if l_dt_update then
     l_datetrack_update_mode := 'UPDATE';
  elsif l_dt_upd_override or
        l_upd_chg_ins then
        -- Need to check if person type in future is EMP, APL or CWK , if yes
        -- then raise error
        l_datetrack_update_mode := 'CORRECTION';
  else
     l_datetrack_update_mode := 'CORRECTION';
  end if;

  hr_utility.set_location(' l_datetrack_update_mode: ' ||
                            l_datetrack_update_mode, 100);
  g_per_rec.object_version_number := l_cur_per_rec.object_version_number;
  if l_tot_appl_asgs = 1 then
     -- As the person has only one applicant assignment then hire person so that
     -- the person type now becomes EMP
     HR_Applicant_API.Hire_Applicant
     (p_validate                   => false
     ,p_hire_date                  => l_effective_date
     ,p_person_id                  => l_cur_per_rec.person_id
     ,p_assignment_id              => p_assignment_id
     ,p_person_type_id             => g_per_rec.person_type_id
     ,p_per_object_version_number  => l_cur_per_rec.object_version_number
     ,p_employee_number            => g_per_rec.employee_number
     ,p_per_effective_start_date   => p_HireAppapi_out.effective_start_date
     ,p_per_effective_end_date     => p_HireAppapi_out.effective_end_date
     ,p_unaccepted_asg_del_warning => l_unaccepted_asg_del_warning
     ,p_assign_payroll_warning     => p_HireAppapi_out.assign_payroll_warning
     ,p_original_date_of_hire      => g_per_rec.original_date_of_hire
     ,p_migrate                    => true
     );
  else
     -- Now hire the person ONLY for the accepted applicant assignment, so that
     -- person type would be EMP_APL
     HR_Employee_Applicant_API.Hire_to_Employee_Applicant
     (p_validate                   => false
     ,p_hire_date                  => l_effective_date
     ,p_person_id                  => l_cur_per_rec.person_id
     ,p_per_object_version_number  => l_cur_per_rec.object_version_number
     ,p_person_type_id             => g_per_rec.person_type_id
     ,p_hire_all_accepted_asgs     => l_hire_all_accepted_asgs
     ,p_assignment_id              => p_assignment_id
     ,p_national_identifier        => g_per_rec.national_identifier
     ,p_employee_number            => g_per_rec.employee_number
     ,p_per_effective_start_date   => p_HireAppapi_out.effective_start_date
     ,p_per_effective_end_date     => p_HireAppapi_out.effective_end_date
     ,p_assign_payroll_warning     => p_HireAppapi_out.assign_payroll_warning
     ,p_oversubscribed_vacancy_id  => p_HireAppapi_out.oversubscribed_vacancy_id
     );
  end if;

  -- Get the new employee assignment created after the person is hired
  open  csr_asg (c_person_id         => l_cur_per_rec.person_id
                ,c_business_group_id => g_per_rec.business_group_id
                ,c_effective_date    => p_HireAppapi_out.effective_start_date
                ,c_asg_type          => 'E'
                ,c_assignment_id     => p_assignment_id);
  fetch csr_asg into l_perasg_rec;
  close csr_asg;
  g_per_rec.object_version_number := l_perasg_rec.per_ovn;

  -- Get the person record after he is hired
  open  csr_per(c_person_id         => g_per_rec.person_id
               ,c_business_group_id => g_per_rec.business_group_id
               ,c_effective_date    => l_effective_date);
  fetch csr_per into l_cur_per_rec;
  close csr_per;

  if g_debug then
    hr_utility.set_location('..effective_start_date      : ' ||
                             p_HireAppapi_out.effective_start_date, 110);
    hr_utility.set_location('..effective_end_date        : ' ||
                             p_HireAppapi_out.effective_end_date, 110);
    hr_utility.set_location('..Old:object_version_number : ' ||
                             l_cur_per_rec.object_version_number, 110);
  end if;
  l_datetrack_update_mode := 'CORRECTION';
  --
  -- Update the person with the rest of the person details, if any passed.
  --
  Upd_Person_Details
  (p_validate            => p_validate
  ,p_effective_date      => p_hire_date
  ,p_person_id           => l_cur_per_rec.person_id
--        ,p_adjusted_svc_date   => null  --Commented by pkagrawa
  ,p_adjusted_svc_date   => p_adjusted_svc_date -- Added by pkagrawa
  ,p_updper_api_out      => l_UpdEmp_Api
  );
  if g_debug then
    hr_utility.set_location('..effective_start_date : ' ||
                             p_updper_api_out.effective_start_date, 120);
    hr_utility.set_location('..effective_end_date   : ' ||
                             p_updper_api_out.effective_end_date, 120);
    hr_utility.set_location('..full_name            : ' ||
                             p_updper_api_out.full_name, 120);
    hr_utility.set_location('Leaving: ' || l_proc_name, 120);
  end if;

     --
     -- Address record
     --
     g_add_rec.person_id             :=  l_cur_per_rec.person_id;
     g_add_rec.date_from             :=  l_cur_per_rec.start_date;
     g_add_rec.date_to               := null;

exception
  when Others then
    if csr_asg%isopen then
      close csr_asg;
    end if;
    if csr_per%isopen then
      close csr_per;
    end if;
    if csr_asg_status%isopen then
      close csr_asg_status;
    end if;
    --l_error_msg := Substr(SQLERRM,1,2000);
    hr_utility.set_location('SQLCODE :' || SQLCODE, 130);
    --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
    hr_utility.set_location('Leaving: ' || l_proc_name, 130);
    hr_utility.raise_error;

end Hire_Applicant_IntoEmp;

-- =============================================================================
-- ~ Hire_Person_IntoEmp:
-- =============================================================================
procedure Hire_Person_IntoEmp
         (p_validate            boolean  default false
         ,p_hire_date           date
         ,p_person_id           number
         ,p_adjusted_svc_date   date     default null
         ,p_updper_api_out      out NOCOPY t_UpdEmp_Api
         ,p_HireToJobapi_out    out NOCOPY t_HrToJob_Api
         ) as
  cursor csr_asg (c_person_id in number
                 ,c_business_group_id in number
                 ,c_effective_date in date) is
  select paf.assignment_id,
         ppf.object_version_number
    from per_all_assignments_f paf
        ,per_all_people_f      ppf
   where paf.person_id         = c_person_id
     and paf.business_group_id = c_business_group_id
     and paf.person_id         = ppf.person_id
     and c_effective_date between ppf.effective_start_date
                              and ppf.effective_end_date
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;
  l_UpdEmp_Api             t_UpdEmp_Api;
  l_cur_per_rec            csr_per%rowtype;
  l_ptu_rec                chk_perType_usage%rowtype;
  l_datetrack_update_mode  varchar2(50);
  l_dt_correction          boolean;
  l_dt_update              boolean;
  l_dt_upd_override        boolean;
  l_upd_chg_ins            boolean;
  l_error_msg              varchar2(2000);
  l_proc_name  constant    varchar2(150):= g_pkg ||'Hire_Person_IntoEmp';
  e_future_chgs_exists     exception;
begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  open  csr_per(c_person_id         => g_per_rec.person_id
               ,c_business_group_id => g_per_rec.business_group_id
               ,c_effective_date    => p_hire_date);
  fetch csr_per into l_cur_per_rec;
  close csr_per;
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

  if l_dt_update then
     l_datetrack_update_mode := 'UPDATE';
  elsif l_dt_upd_override or
        l_upd_chg_ins then
        -- Need to check if person type in future is EMP, APL or CWK , if yes
        -- then raise error
        open chk_perType_usage
           (c_person_id         => l_cur_per_rec.person_id
           ,c_effective_date    => p_hire_date
           ,c_business_group_id => g_per_rec.business_group_id);

        fetch chk_perType_usage into l_ptu_rec;
        if chk_perType_usage%found then
           close chk_perType_usage;
           raise e_future_chgs_exists;
        end if;
        close chk_perType_usage;
        --Else USE Correction Mode
        l_datetrack_update_mode := 'CORRECTION';
  else
     l_datetrack_update_mode := 'CORRECTION';
  end if;

  hr_utility.set_location('l_datetrack_update_mode: ' ||
                           l_datetrack_update_mode, 30);
  g_per_rec.object_version_number := l_cur_per_rec.object_version_number;

  Hr_Employee_Api.Hire_Into_Job
  (p_validate               => false
  ,p_effective_date         => p_hire_date
  ,p_person_id              => l_cur_per_rec.person_id
  ,p_object_version_number  => l_cur_per_rec.object_version_number
  ,p_employee_number        => g_per_rec.employee_number
  ,p_datetrack_update_mode  => l_datetrack_update_mode
  ,p_person_type_id         => g_per_rec.person_type_id
  ,p_national_identifier    => g_per_rec.national_identifier
  ,p_per_information7       => g_per_rec.per_information7
   -- Out Variables
  ,p_effective_start_date   => p_HireToJobapi_out.effective_start_date
  ,p_effective_end_date     => p_HireToJobapi_out.effective_end_date
  ,p_assign_payroll_warning => p_HireToJobapi_out.assign_payroll_warning
  ,p_orig_hire_warning      => p_HireToJobapi_out.orig_hire_warning
  );
  -- Get the new assignment created after the person is hired
  open  csr_asg (c_person_id         => l_cur_per_rec.person_id
                ,c_business_group_id => g_per_rec.business_group_id
                ,c_effective_date    => p_HireToJobapi_out.effective_start_date);
  fetch csr_asg into p_HireToJobapi_out.assignment_id
                    ,g_per_rec.object_version_number;
  close csr_asg;
  -- Get the person record after he is hired
  open  csr_per(c_person_id         => g_per_rec.person_id
               ,c_business_group_id => g_per_rec.business_group_id
               ,c_effective_date    => p_hire_date);
  fetch csr_per into l_cur_per_rec;
  close csr_per;

  if g_debug then
    hr_utility.set_location('..effective_start_date      : ' ||
                             p_HireToJobapi_out.effective_start_date,40);
    hr_utility.set_location('..effective_end_date        : ' ||
                             p_HireToJobapi_out.effective_end_date,40);
    hr_utility.set_location('..New:object_version_number : ' ||
                             g_per_rec.object_version_number,40);
    hr_utility.set_location('..Old:object_version_number : ' ||
                             l_cur_per_rec.object_version_number,40);
    hr_utility.set_location('..New:Assignment Id         : ' ||
                             p_HireToJobapi_out.assignment_id,40);
  end if;
  l_datetrack_update_mode := 'CORRECTION';

  Upd_Person_Details
  (p_validate            => p_validate
  ,p_effective_date      => p_hire_date
  ,p_person_id           => l_cur_per_rec.person_id
  ,p_adjusted_svc_date   => null
  ,p_updper_api_out      => l_UpdEmp_Api
  );
  if g_debug then
    hr_utility.set_location('..effective_start_date : ' ||
                             p_updper_api_out.effective_start_date, 50);
    hr_utility.set_location('..effective_end_date   : ' ||
                             p_updper_api_out.effective_end_date, 50);
    hr_utility.set_location('..full_name            : ' ||
                             p_updper_api_out.full_name, 50);
    hr_utility.set_location('Leaving: ' || l_proc_name, 50);
  end if;

exception
  when e_future_chgs_exists then
    l_error_msg := 'This person cannot be created/updated in HRMS as the '||
                   'Person has future changes beyond the date: '||p_hire_date;

    hr_utility.set_location('..Future Update exists for the Student Employee', 60);
    hr_utility.set_message(8303, 'PQP_230491_RIW_PER_NOT_CREATED');
    hr_utility.set_message_token('TOKEN',p_hire_date );
    hr_utility.set_location('Leaving: ' || l_proc_name, 60);
    hr_utility.raise_error;

  when Others then
   if csr_asg%isopen then
     close csr_asg;
   end if;
   if csr_per%isopen then
     close csr_per;
   end if;
   --l_error_msg := Substr(SQLERRM,1,2000);
   hr_utility.set_location('SQLCODE :' || SQLCODE,90);
   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,50) );
   hr_utility.set_location('Leaving: ' || l_proc_name, 90);
   hr_utility.raise_error;

end Hire_Person_IntoEmp;

-- =============================================================================
-- ~ InsUpd_Employee:
-- =============================================================================
procedure InsUpd_Employee
         (p_validate            boolean  default false
         ,p_action_mode         varchar2 default null
         ,p_effective_date      date
         ,p_adjusted_svc_date   date     default null
         ,p_per_comments        varchar2 default null
         ,p_emp_api_out         out nocopy t_hrEmpApi) as

  l_HireToJobapi_out   t_HrToJob_Api;
  l_updper_api_out     t_UpdEmp_Api;

  l_proc_name constant varchar2(150):= g_pkg ||'InsUpd_Employee';

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  if p_action_mode = 'CREATE_EMPLOYEE' then

   --hr_utility.trace('Before Call to Hr_Employee_Api.Create_Employee:');
   --hr_utility.trace('p_employee_number=>'|| g_per_rec.employee_number);
   --hr_utility.trace('p_assignment_number=>'|| g_asg_rec.assignment_number);


     Hr_Employee_Api.Create_Employee
     (p_validate                     => p_validate
     ,p_hire_date                    => g_per_rec.start_date
     ,p_business_group_id            => g_per_rec.business_group_id
     ,p_last_name                    => g_per_rec.last_name
     ,p_sex                          => g_per_rec.sex
     ,p_person_type_id               => g_per_rec.person_type_id
     ,p_per_comments                 => p_per_comments
     ,p_date_employee_data_verified  => g_per_rec.date_employee_data_verified
     ,p_date_of_birth                => g_per_rec.date_of_birth
     ,p_email_address                => g_per_rec.email_address
     ,p_employee_number              => g_per_rec.employee_number
     ,p_expense_check_send_to_addres => g_per_rec.expense_check_send_to_address
     ,p_first_name                   => g_per_rec.first_name
     ,p_known_as                     => g_per_rec.known_as
     ,p_marital_status               => g_per_rec.marital_status
     ,p_middle_names                 => g_per_rec.middle_names
     ,p_nationality                  => g_per_rec.nationality
     ,p_national_identifier          => g_per_rec.national_identifier
     ,p_previous_last_name           => g_per_rec.previous_last_name
     ,p_registered_disabled_flag     => g_per_rec.registered_disabled_flag
     ,p_title                        => g_per_rec.title
     ,p_vendor_id                    => g_per_rec.vendor_id
     -- DF
     ,p_attribute_category           => g_per_rec.attribute_category
     ,p_attribute1                   => g_per_rec.attribute1
     ,p_attribute2                   => g_per_rec.attribute2
     ,p_attribute3                   => g_per_rec.attribute3
     ,p_attribute4                   => g_per_rec.attribute4
     ,p_attribute5                   => g_per_rec.attribute5
     ,p_attribute6                   => g_per_rec.attribute6
     ,p_attribute7                   => g_per_rec.attribute7
     ,p_attribute8                   => g_per_rec.attribute8
     ,p_attribute9                   => g_per_rec.attribute9
     ,p_attribute10                  => g_per_rec.attribute10
     ,p_attribute11                  => g_per_rec.attribute11
     ,p_attribute12                  => g_per_rec.attribute12
     ,p_attribute13                  => g_per_rec.attribute13
     ,p_attribute14                  => g_per_rec.attribute14
     ,p_attribute15                  => g_per_rec.attribute15
     ,p_attribute16                  => g_per_rec.attribute16
     ,p_attribute17                  => g_per_rec.attribute17
     ,p_attribute18                  => g_per_rec.attribute18
     ,p_attribute19                  => g_per_rec.attribute19
     ,p_attribute20                  => g_per_rec.attribute20
     ,p_attribute21                  => g_per_rec.attribute21
     ,p_attribute22                  => g_per_rec.attribute22
     ,p_attribute23                  => g_per_rec.attribute23
     ,p_attribute24                  => g_per_rec.attribute24
     ,p_attribute25                  => g_per_rec.attribute25
     ,p_attribute26                  => g_per_rec.attribute26
     ,p_attribute27                  => g_per_rec.attribute27
     ,p_attribute28                  => g_per_rec.attribute28
     ,p_attribute29                  => g_per_rec.attribute29
     ,p_attribute30                  => g_per_rec.attribute30
      -- DDF
     ,p_per_information_category     => g_per_rec.per_information_category
     ,p_per_information1             => g_per_rec.per_information1
     ,p_per_information2             => g_per_rec.per_information2
     ,p_per_information3             => g_per_rec.per_information3
     ,p_per_information4             => g_per_rec.per_information4
     ,p_per_information5             => g_per_rec.per_information5
     ,p_per_information6             => g_per_rec.per_information6
     ,p_per_information7             => g_per_rec.per_information7
     ,p_per_information8             => g_per_rec.per_information8
     ,p_per_information9             => g_per_rec.per_information9
     ,p_per_information10            => g_per_rec.per_information10
     ,p_per_information11            => g_per_rec.per_information11
     ,p_per_information12            => g_per_rec.per_information12
     ,p_per_information13            => g_per_rec.per_information13
     ,p_per_information14            => g_per_rec.per_information14
     ,p_per_information15            => g_per_rec.per_information15
     ,p_per_information16            => g_per_rec.per_information16
     ,p_per_information17            => g_per_rec.per_information17
     ,p_per_information18            => g_per_rec.per_information18
     ,p_per_information19            => g_per_rec.per_information19
     ,p_per_information20            => g_per_rec.per_information20
     ,p_per_information21            => g_per_rec.per_information21
     ,p_per_information22            => g_per_rec.per_information22
     ,p_per_information23            => g_per_rec.per_information23
     ,p_per_information24            => g_per_rec.per_information24
     ,p_per_information25            => g_per_rec.per_information25
     ,p_per_information26            => g_per_rec.per_information26
     ,p_per_information27            => g_per_rec.per_information27
     ,p_per_information28            => g_per_rec.per_information28
     ,p_per_information29            => g_per_rec.per_information29
     ,p_per_information30            => g_per_rec.per_information30
     ,p_date_of_death                => g_per_rec.date_of_death
     ,p_background_check_status      => g_per_rec.background_check_status
     ,p_background_date_check        => g_per_rec.background_date_check
     ,p_blood_type                   => g_per_rec.blood_type
     ,p_correspondence_language      => g_per_rec.correspondence_language
     ,p_fast_path_employee           => g_per_rec.fast_path_employee
     ,p_fte_capacity                 => g_per_rec.fte_capacity
     ,p_honors                       => g_per_rec.honors
     ,p_internal_location            => g_per_rec.internal_location
     ,p_last_medical_test_by         => g_per_rec.last_medical_test_by
     ,p_last_medical_test_date       => g_per_rec.last_medical_test_date
     ,p_mailstop                     => g_per_rec.mailstop
     ,p_office_number                => g_per_rec.office_number
     ,p_on_military_service          => g_per_rec.on_military_service
     ,p_pre_name_adjunct             => g_per_rec.pre_name_adjunct
     ,p_rehire_recommendation        => g_per_rec.rehire_recommendation
     ,p_projected_start_date         => g_per_rec.projected_start_date
     ,p_resume_exists                => g_per_rec.resume_exists
     ,p_resume_last_updated          => g_per_rec.resume_last_updated
     ,p_second_passport_exists       => g_per_rec.second_passport_exists
     ,p_student_status               => g_per_rec.student_status
     ,p_work_schedule                => g_per_rec.work_schedule
     ,p_suffix                       => g_per_rec.suffix
     ,p_benefit_group_id             => g_per_rec.benefit_group_id
     ,p_receipt_of_death_cert_date   => g_per_rec.receipt_of_death_cert_date
     ,p_coord_ben_med_pln_no         => g_per_rec.coord_ben_med_pln_no
     ,p_coord_ben_no_cvg_flag        => g_per_rec.coord_ben_no_cvg_flag
     ,p_coord_ben_med_ext_er         => g_per_rec.coord_ben_med_ext_er
     ,p_coord_ben_med_pl_name        => g_per_rec.coord_ben_med_pl_name
     ,p_coord_ben_med_insr_crr_name  => g_per_rec.coord_ben_med_insr_crr_name
     ,p_coord_ben_med_insr_crr_ident => g_per_rec.coord_ben_med_insr_crr_ident
     ,p_coord_ben_med_cvg_strt_dt    => g_per_rec.coord_ben_med_cvg_strt_dt
     ,p_coord_ben_med_cvg_end_dt     => g_per_rec.coord_ben_med_cvg_end_dt
     ,p_uses_tobacco_flag            => g_per_rec.uses_tobacco_flag
     ,p_dpdnt_adoption_date          => g_per_rec.dpdnt_adoption_date
     ,p_dpdnt_vlntry_svce_flag       => g_per_rec.dpdnt_vlntry_svce_flag
     ,p_original_date_of_hire        => g_per_rec.original_date_of_hire
     ,p_adjusted_svc_date            => p_adjusted_svc_date
     ,p_town_of_birth                => g_per_rec.town_of_birth
     ,p_region_of_birth              => g_per_rec.region_of_birth
     ,p_country_of_birth             => g_per_rec.country_of_birth
     ,p_global_person_id             => g_per_rec.global_person_id
     ,p_party_id                     => g_per_rec.party_id
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
     --
     -- Person record
     --
     g_per_rec.person_id             := p_emp_api_out.person_id;
     g_per_rec.object_version_number := p_emp_api_out.per_object_version_number;
     g_per_rec.effective_start_date  := p_emp_api_out.per_effective_start_date;
     g_per_rec.effective_end_date    := p_emp_api_out.per_effective_end_date;
     --
     -- Assignment record
     --
     g_asg_rec.person_id             := g_per_rec.person_id;
     g_asg_rec.assignment_id         := p_emp_api_out.assignment_id;
     g_asg_rec.object_version_number := p_emp_api_out.asg_object_version_number;

--By DBANSAL, use assignment_number obtained from spreadsheet
-- If the assignment_number obtained from spreadsheet is null then use the generated one
   g_asg_rec.assignment_number := NVL(g_asg_rec.assignment_number,
                                         p_emp_api_out.assignment_number);
     g_asg_rec.assignment_sequence   := p_emp_api_out.assignment_sequence;
     --
     -- Address record
     --
     g_add_rec.person_id             := g_per_rec.person_id;
     g_add_rec.date_from             := g_per_rec.start_date;
     g_add_rec.date_to               := null;

   --hr_utility.trace('After Call to Hr_Employee_Api.Create_Employee:');
   --hr_utility.trace('p_employee_number=>'|| g_per_rec.employee_number);
   --hr_utility.trace('p_assignment_number=>'|| g_asg_rec.assignment_number);
   --hr_utility.trace('assignment_sequence =>'|| g_asg_rec.assignment_sequence);

  elsif p_action_mode = 'HIRE_PERSON_INTOEMP' then

        Hire_Person_IntoEmp
       (p_validate            => p_validate
       ,p_hire_date           => g_per_rec.start_date
       ,p_person_id           => g_per_rec.person_id
       ,p_adjusted_svc_date   => p_adjusted_svc_date
        -- Out
       ,p_updper_api_out      => l_updper_api_out
       ,p_HireToJobapi_out    => l_HireToJobapi_out
        );
       --
       -- Person record
       --
       p_emp_api_out.person_id := g_per_rec.person_id;

       p_emp_api_out.per_effective_start_date
           := l_HireToJobapi_out.effective_start_date;
       p_emp_api_out.per_effective_end_date
           := l_HireToJobapi_out.effective_end_date;
       --
       -- Assignment record
       --
       g_asg_rec.person_id      := g_per_rec.person_id;
       g_asg_rec.assignment_id  := l_HireToJobapi_out.assignment_id;
       --
       -- Address record
       --
       g_add_rec.person_id      := g_per_rec.person_id;
       g_add_rec.date_from      := g_per_rec.start_date;
       g_add_rec.date_to        := null;

  end if;

  if g_debug then
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
  end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 30);

exception
  when Others then
  hr_utility.set_location('Leaving: ' || l_proc_name, 40);
  raise;

end InsUpd_Employee;

-- =============================================================================
-- ~ InsUpd_Applicant:
-- =============================================================================
procedure InsUpd_Applicant
         (p_validate            in boolean  default false
         ,p_action_mode         in varchar2 default null
         ,p_effective_date      in date
         ,p_adjusted_svc_date   in date     default null
         ,p_per_comments        in varchar2 default null
         ,p_assignment_id       in number   default null
         ,p_appl_api_out        out nocopy t_hrEmpApi) as

  l_updper_api_out             t_UpdEmp_Api;
  l_HireAppapi_out             t_HrApp_Api;
  l_UpdEmp_Api                 t_UpdEmp_Api;

  l_oversubscribed_vacancy_id  number(15);

  l_application_id             number(15);
--  l_application_id             number(15):=1103; --Changed by pkagrawa

  l_apl_object_version_number  number(15);

  l_unaccepted_asg_del_warning boolean;
  l_appl_override_warning      boolean;
  l_datetrack_update_mode      varchar2(150);

  l_proc_name         constant varchar2(150):= g_pkg ||'InsUpd_Applicant';

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  Get_DataTrack_Mode
  (p_datetrack_update_mode => l_datetrack_update_mode
   );

  if p_action_mode ='CREATE_APPLICANT' then

--hr_utility.trace('Before CREATE_APPLICANT');

     HR_Applicant_API.Create_Applicant
     (p_validate                     => p_validate
     ,p_date_received                => g_per_rec.start_date
     ,p_business_group_id            => g_per_rec.business_group_id
     ,p_last_name                    => g_per_rec.last_name
     ,p_person_type_id               => g_per_rec.person_type_id
     ,p_applicant_number             => g_per_rec.applicant_number
     ,p_per_comments                 => p_per_comments
     ,p_date_employee_data_verified  => g_per_rec.date_employee_data_verified
     ,p_date_of_birth                => g_per_rec.date_of_birth
     ,p_email_address                => g_per_rec.email_address
     ,p_expense_check_send_to_addres => g_per_rec.expense_check_send_to_address
     ,p_first_name                   => g_per_rec.first_name
     ,p_known_as                     => g_per_rec.known_as
     ,p_marital_status               => g_per_rec.marital_status
     ,p_middle_names                 => g_per_rec.middle_names
     ,p_nationality                  => g_per_rec.nationality
     ,p_national_identifier          => g_per_rec.national_identifier
     ,p_previous_last_name           => g_per_rec.previous_last_name
     ,p_registered_disabled_flag     => g_per_rec.registered_disabled_flag
     ,p_sex                          => g_per_rec.sex
     ,p_title                        => g_per_rec.title
     ,p_work_telephone               => g_per_rec.work_telephone
     ,p_background_check_status      => g_per_rec.background_check_status
     ,p_background_date_check        => g_per_rec.background_date_check
     ,p_correspondence_language      => g_per_rec.correspondence_language
     ,p_fte_capacity                 => g_per_rec.fte_capacity
     ,p_hold_applicant_date_until    => g_per_rec.hold_applicant_date_until
     ,p_honors                       => g_per_rec.honors
     ,p_mailstop                     => g_per_rec.mailstop
     ,p_office_number                => g_per_rec.office_number
     ,p_on_military_service          => g_per_rec.on_military_service
     ,p_pre_name_adjunct             => g_per_rec.pre_name_adjunct
     ,p_projected_start_date         => g_per_rec.projected_start_date
     ,p_resume_exists                => g_per_rec.resume_exists
     ,p_resume_last_updated          => g_per_rec.resume_last_updated
     ,p_student_status               => g_per_rec.student_status
     ,p_work_schedule                => g_per_rec.work_schedule
     ,p_suffix                       => g_per_rec.suffix
     ,p_date_of_death                => g_per_rec.date_of_death
     ,p_benefit_group_id             => g_per_rec.benefit_group_id
     ,p_receipt_of_death_cert_date   => g_per_rec.receipt_of_death_cert_date
     ,p_coord_ben_med_pln_no         => g_per_rec.coord_ben_med_pln_no
     ,p_coord_ben_no_cvg_flag        => g_per_rec.coord_ben_no_cvg_flag
     ,p_uses_tobacco_flag            => g_per_rec.uses_tobacco_flag
     ,p_dpdnt_adoption_date          => g_per_rec.dpdnt_adoption_date
     ,p_dpdnt_vlntry_svce_flag       => g_per_rec.dpdnt_vlntry_svce_flag
     ,p_original_date_of_hire        => g_per_rec.original_date_of_hire
     ,p_town_of_birth                => g_per_rec.town_of_birth
     ,p_region_of_birth              => g_per_rec.region_of_birth
     ,p_country_of_birth             => g_per_rec.country_of_birth
     ,p_global_person_id             => g_per_rec.global_person_id
     ,p_party_id                     => g_per_rec.party_id
      -- DF
     ,p_attribute_category           => g_per_rec.attribute_category
     ,p_attribute1                   => g_per_rec.attribute1
     ,p_attribute2                   => g_per_rec.attribute2
     ,p_attribute3                   => g_per_rec.attribute3
     ,p_attribute4                   => g_per_rec.attribute4
     ,p_attribute5                   => g_per_rec.attribute5
     ,p_attribute6                   => g_per_rec.attribute6
     ,p_attribute7                   => g_per_rec.attribute7
     ,p_attribute8                   => g_per_rec.attribute8
     ,p_attribute9                   => g_per_rec.attribute9
     ,p_attribute10                  => g_per_rec.attribute10
     ,p_attribute11                  => g_per_rec.attribute11
     ,p_attribute12                  => g_per_rec.attribute12
     ,p_attribute13                  => g_per_rec.attribute13
     ,p_attribute14                  => g_per_rec.attribute14
     ,p_attribute15                  => g_per_rec.attribute15
     ,p_attribute16                  => g_per_rec.attribute16
     ,p_attribute17                  => g_per_rec.attribute17
     ,p_attribute18                  => g_per_rec.attribute18
     ,p_attribute19                  => g_per_rec.attribute19
     ,p_attribute20                  => g_per_rec.attribute20
     ,p_attribute21                  => g_per_rec.attribute21
     ,p_attribute22                  => g_per_rec.attribute22
     ,p_attribute23                  => g_per_rec.attribute23
     ,p_attribute24                  => g_per_rec.attribute24
     ,p_attribute25                  => g_per_rec.attribute25
     ,p_attribute26                  => g_per_rec.attribute26
     ,p_attribute27                  => g_per_rec.attribute27
     ,p_attribute28                  => g_per_rec.attribute28
     ,p_attribute29                  => g_per_rec.attribute29
     ,p_attribute30                  => g_per_rec.attribute30
      -- DDF
     ,p_per_information_category     => g_per_rec.per_information_category
     ,p_per_information1             => g_per_rec.per_information1
     ,p_per_information2             => g_per_rec.per_information2
     ,p_per_information3             => g_per_rec.per_information3
     ,p_per_information4             => g_per_rec.per_information4
     ,p_per_information5             => g_per_rec.per_information5
     ,p_per_information6             => g_per_rec.per_information6
     ,p_per_information7             => g_per_rec.per_information7
     ,p_per_information8             => g_per_rec.per_information8
     ,p_per_information9             => g_per_rec.per_information9
     ,p_per_information10            => g_per_rec.per_information10
     ,p_per_information11            => g_per_rec.per_information11
     ,p_per_information12            => g_per_rec.per_information12
     ,p_per_information13            => g_per_rec.per_information13
     ,p_per_information14            => g_per_rec.per_information14
     ,p_per_information15            => g_per_rec.per_information15
     ,p_per_information16            => g_per_rec.per_information16
     ,p_per_information17            => g_per_rec.per_information17
     ,p_per_information18            => g_per_rec.per_information18
     ,p_per_information19            => g_per_rec.per_information19
     ,p_per_information20            => g_per_rec.per_information20
     ,p_per_information21            => g_per_rec.per_information21
     ,p_per_information22            => g_per_rec.per_information22
     ,p_per_information23            => g_per_rec.per_information23
     ,p_per_information24            => g_per_rec.per_information24
     ,p_per_information25            => g_per_rec.per_information25
     ,p_per_information26            => g_per_rec.per_information26
     ,p_per_information27            => g_per_rec.per_information27
     ,p_per_information28            => g_per_rec.per_information28
     ,p_per_information29            => g_per_rec.per_information29
     ,p_per_information30            => g_per_rec.per_information30
      -- Out variables
     ,p_person_id                    => p_appl_api_out.person_id
     ,p_assignment_id                => p_appl_api_out.assignment_id
     ,p_application_id               => l_application_id
     ,p_per_object_version_number    => p_appl_api_out.per_object_version_number
     ,p_asg_object_version_number    => p_appl_api_out.asg_object_version_number
     ,p_apl_object_version_number    => l_apl_object_version_number
     ,p_per_effective_start_date     => p_appl_api_out.per_effective_start_date
     ,p_per_effective_end_date       => p_appl_api_out.per_effective_end_date
     ,p_full_name                    => p_appl_api_out.full_name
     ,p_per_comment_id               => p_appl_api_out.per_comment_id
     ,p_assignment_sequence          => p_appl_api_out.assignment_sequence
     ,p_name_combination_warning     => p_appl_api_out.name_combination_warning
     ,p_orig_hire_warning            => p_appl_api_out.orig_hire_warning
      );


--hr_utility.trace('After CREATE_APPLICANT Value of l_application_id'||l_application_id);

     g_asg_rec.application_id := l_application_id; -- Change by pkagrawa
     --
     -- Person record
     --
     g_per_rec.person_id             := p_appl_api_out.person_id;
     g_per_rec.object_version_number := p_appl_api_out.per_object_version_number;
     g_per_rec.effective_start_date  := p_appl_api_out.per_effective_start_date;
     g_per_rec.effective_end_date    := p_appl_api_out.per_effective_end_date;
     --
     -- Assignment record
     --
     g_asg_rec.person_id             := p_appl_api_out.person_id;
     g_asg_rec.assignment_id         := p_appl_api_out.assignment_id;
     g_asg_rec.object_version_number := p_appl_api_out.asg_object_version_number;

    --Changes by DBANSAL
    g_asg_rec.assignment_number := NVL(g_asg_rec.assignment_number,
                                         p_appl_api_out.assignment_number);

     g_asg_rec.assignment_sequence   := p_appl_api_out.assignment_sequence;
     --
     -- Address record
     --
     g_add_rec.person_id             := p_appl_api_out.person_id;
     g_add_rec.date_from             := g_per_rec.start_date;
     g_add_rec.date_to               := null;

  elsif p_action_mode ='CONVERT_TO_APPLICANT' then
       --
       --   This business process converts a person of type EX_APL, EX_EMP
       --   or OTHER to a type of APL_EX_APL, EX_EMP_APL or APL respectively.
       --   This is achieved by
       --     Setting the person type to APL_EX_APL, EX_EMP_APL or APL
       --     Creating an application, Creating a default application
       --     assignment.
       --
       HR_Applicant_API.Convert_To_Applicant
       (p_validate              => p_validate
       ,p_effective_date        => g_per_rec.start_date
       ,p_person_id             => g_per_rec.person_id
       ,p_object_version_number => g_per_rec.object_version_number
       ,p_applicant_number      => g_per_rec.applicant_number
       ,p_person_type_id        => g_per_rec.person_type_id
       ,p_effective_start_date  => g_per_rec.effective_start_date
       ,p_effective_end_date    => g_per_rec.effective_end_date
       ,p_appl_override_warning => l_appl_override_warning
        );
       --
       -- Update Person Details
       --
       Upd_Person_Details
       (p_validate            => false
       ,p_effective_date      => g_per_rec.effective_start_date
       ,p_person_id           => g_per_rec.person_id
       ,p_adjusted_svc_date   => null
       ,p_updper_api_out      => l_UpdEmp_Api
        );
       --
       -- Address required values
       --
        g_add_rec.person_id       := g_per_rec.person_id;
        g_add_rec.date_from       := g_per_rec.start_date;
        g_add_rec.date_to         := null;


  elsif p_action_mode = 'HIRE_APPLICANT' then
       --
       -- This API converts data about a person of type Applicant(APL,
       -- APL_EX_APL  or EX_EMP_APL) to a person of type Employee(EMP).
       -- This is achieved by:
       --    - Terminating the application record.
       --    - Terminating unaccepted applicant assignments.
       --    - Setting person to be an 'EMP'.
       --    - Creating a period of service record.
       --    - Converting accepted applicant assignments to
       --      active employee assignments.
       Hire_Applicant_IntoEmp
       (p_validate            => p_validate
       ,p_hire_date           => g_per_rec.start_date
       ,p_person_id           => g_per_rec.person_id
       ,p_assignment_id       => p_assignment_id
       ,p_adjusted_svc_date   => p_adjusted_svc_date
       ,p_updper_api_out      => l_updper_api_out
       ,p_HireAppapi_out      => l_HireAppapi_out
        );
        p_appl_api_out.per_effective_end_date
            := l_HireAppapi_out.effective_end_date;


        p_appl_api_out.per_effective_start_date
            := l_HireAppapi_out.effective_start_date;

        p_appl_api_out.assign_payroll_warning
            := l_HireAppapi_out.assign_payroll_warning;

        l_oversubscribed_vacancy_id
            := l_HireAppapi_out.oversubscribed_vacancy_id;
     --
     -- Person record
     --
     g_per_rec.object_version_number := p_appl_api_out.per_object_version_number;
     g_per_rec.effective_start_date  := p_appl_api_out.per_effective_start_date;
     g_per_rec.effective_end_date    := p_appl_api_out.per_effective_end_date;
     --
     -- Now that the person is converted into an employee, update the person
     -- details as passed from the spread sheet.
     --
     Upd_Person_Details
     (p_validate            => false
     ,p_effective_date      => g_per_rec.effective_start_date
     ,p_person_id           => g_per_rec.person_id
     ,p_adjusted_svc_date   => null
     ,p_updper_api_out      => l_UpdEmp_Api
      );
     --
     -- Assignment record
     --
     g_asg_rec.person_id             := g_per_rec.person_id;
     g_asg_rec.assignment_id         := p_assignment_id;
     g_asg_rec.object_version_number := p_appl_api_out.asg_object_version_number;
     g_asg_rec.assignment_sequence   := p_appl_api_out.assignment_sequence;
     --
     -- Address record
     --
     g_add_rec.person_id             := g_per_rec.person_id;
     g_add_rec.date_from             := g_per_rec.start_date;
     g_add_rec.date_to               := null;

  elsif p_action_mode = 'APPLY_FOR_JOB' then

      HR_Applicant_API.Apply_For_Job_Anytime
      (p_validate                      => p_validate
      ,p_effective_date                => g_per_rec.start_date
      ,p_person_id                     => g_per_rec.person_id
      --,p_vacancy_id                  => g_per_rec.vacancy_id
      ,p_person_type_id                => g_per_rec.person_type_id
      ,p_assignment_status_type_id     => g_asg_rec.assignment_status_type_id
      -- In/Out
      ,p_applicant_number              => g_per_rec.applicant_number
      ,p_per_object_version_number     => g_per_rec.object_version_number
      -- Out
      ,p_application_id                => l_application_id
      ,p_assignment_id                 => p_appl_api_out.assignment_id
      ,p_apl_object_version_number     => p_appl_api_out.per_object_version_number
      ,p_asg_object_version_number     => p_appl_api_out.asg_object_version_number
      ,p_assignment_sequence           => p_appl_api_out.assignment_sequence
      ,p_per_effective_start_date      => p_appl_api_out.per_effective_start_date
      ,p_per_effective_end_date        => p_appl_api_out.per_effective_end_date
      ,p_appl_override_warning         => l_appl_override_warning
       );
     --
     -- Person record
     --
     g_asg_rec.application_id := l_application_id; -- Change by pkagrawa

     g_per_rec.object_version_number := p_appl_api_out.per_object_version_number;
     g_per_rec.effective_start_date  := p_appl_api_out.per_effective_start_date;
     g_per_rec.effective_end_date    := p_appl_api_out.per_effective_end_date;
     -- Update the person information
     Upd_Person_Details
     (p_validate            => false
     ,p_effective_date      => g_per_rec.effective_start_date
     ,p_person_id           => g_per_rec.person_id
     ,p_adjusted_svc_date   => null
     ,p_updper_api_out      => l_UpdEmp_Api
      );
     --
     -- Assignment record
     --
     g_asg_rec.person_id             := g_per_rec.person_id;
     g_asg_rec.assignment_id         := p_appl_api_out.assignment_id;
     g_asg_rec.object_version_number := p_appl_api_out.asg_object_version_number;
     g_asg_rec.assignment_sequence   := p_appl_api_out.assignment_sequence;
     --
     -- Address record
     --
     g_add_rec.person_id             := g_per_rec.person_id;
     g_add_rec.date_from             := g_per_rec.start_date;
     g_add_rec.date_to               := null;

  end if;

  if g_debug then
    hr_utility.set_location('..person_id                 : ' ||
                             p_appl_api_out.person_id,20);
    hr_utility.set_location('..assignment_id             : ' ||
                             p_appl_api_out.assignment_id,20);
    hr_utility.set_location('..per_object_version_number : ' ||
                             p_appl_api_out.per_object_version_number,20);
    hr_utility.set_location('..asg_object_version_number : ' ||
                             p_appl_api_out.asg_object_version_number,20);
    hr_utility.set_location('..per_effective_start_date  : ' ||
                             p_appl_api_out.per_effective_start_date,20);
    hr_utility.set_location('..per_effective_end_date    : ' ||
                             p_appl_api_out.per_effective_end_date,20);
    hr_utility.set_location('..full_name                 : ' ||
                             p_appl_api_out.full_name,20);
    hr_utility.set_location('..per_comment_id            : ' ||
                             p_appl_api_out.per_comment_id,20);
    hr_utility.set_location('..assignment_sequence       : ' ||
                             p_appl_api_out.assignment_sequence,20);
    hr_utility.set_location('..assignment_number         : ' ||
                             p_appl_api_out.assignment_number,20);
  end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 30);

exception
  when Others then
  hr_utility.set_location('Leaving: ' || l_proc_name, 40);
  raise;

end InsUpd_Applicant;
-- =============================================================================
-- ~ InsUpd_Contingent_Worker:
-- =============================================================================
procedure InsUpd_Contingent_Worker
         (p_validate              in boolean  default false
         ,p_action_mode           in varchar2 default null
         ,p_datetrack_update_mode in varchar2 default null
         ,p_effective_date        in date
         ,p_adjusted_svc_date     in date     default null
         ,p_per_comments          in varchar2 default null
         ,p_cwk_api_out           out nocopy t_hrEmpApi) as

  l_apl_object_version_number  number(15);
  l_application_id             number(15);
  l_datetrack_update_mode      varchar2(150);
  l_proc_name         constant varchar2(150):= g_pkg ||'InsUpd_Contingent_Worker';

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  Get_DataTrack_Mode
  (p_datetrack_update_mode => l_datetrack_update_mode
   );

  --hr_utility.trace('Inside InsUpd_Contingent_Worker before CREATE_CWK');
  --hr_utility.trace('p_person_type_id'||g_per_rec.person_type_id);

  if p_action_mode ='CREATE_CWK' then

    HR_Contingent_Worker_API.Create_CWK
    (p_validate                    => p_validate
    ,p_start_date                  => g_per_rec.start_date
    ,p_business_group_id           => g_per_rec.business_group_id
    ,p_last_name                   => g_per_rec.last_name
    ,p_person_type_id              => g_per_rec.person_type_id
    ,p_npw_number                  => g_per_rec.npw_number
    ,p_background_check_status     => g_per_rec.background_check_status
    ,p_background_date_check       => g_per_rec.background_date_check
    ,p_blood_type                  => g_per_rec.blood_type
    ,p_comments                    => p_per_comments
    ,p_correspondence_language     => g_per_rec.correspondence_language
    ,p_country_of_birth            => g_per_rec.country_of_birth
    ,p_date_of_birth               => g_per_rec.date_of_birth
    ,p_date_of_death               => g_per_rec.date_of_death
    ,p_dpdnt_adoption_date         => g_per_rec.dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag      => g_per_rec.dpdnt_vlntry_svce_flag
    ,p_email_address               => g_per_rec.email_address
    ,p_first_name                  => g_per_rec.first_name
    ,p_fte_capacity                => g_per_rec.fte_capacity
    ,p_honors                      => g_per_rec.honors
    ,p_internal_location           => g_per_rec.internal_location
    ,p_known_as                    => g_per_rec.known_as
    ,p_last_medical_test_by        => g_per_rec.last_medical_test_by
    ,p_last_medical_test_date      => g_per_rec.last_medical_test_date
    ,p_mailstop                    => g_per_rec.mailstop
    ,p_marital_status              => g_per_rec.marital_status
    ,p_middle_names                => g_per_rec.middle_names
    ,p_national_identifier         => g_per_rec.national_identifier
    ,p_nationality                 => g_per_rec.nationality
    ,p_office_number               => g_per_rec.office_number
    ,p_on_military_service         => g_per_rec.on_military_service
    ,p_party_id                    => g_per_rec.party_id
    ,p_pre_name_adjunct            => g_per_rec.pre_name_adjunct
    ,p_previous_last_name          => g_per_rec.previous_last_name
    ,p_receipt_of_death_cert_date  => g_per_rec.receipt_of_death_cert_date
    ,p_region_of_birth             => g_per_rec.region_of_birth
    ,p_registered_disabled_flag    => g_per_rec.registered_disabled_flag
    ,p_resume_exists               => g_per_rec.resume_exists
    ,p_resume_last_updated         => g_per_rec.resume_last_updated
    ,p_second_passport_exists      => g_per_rec.second_passport_exists
    ,p_sex                         => g_per_rec.sex
    ,p_student_status              => g_per_rec.student_status
    ,p_suffix                      => g_per_rec.suffix
    ,p_title                       => g_per_rec.title
    ,p_town_of_birth               => g_per_rec.town_of_birth
    ,p_uses_tobacco_flag           => g_per_rec.uses_tobacco_flag
    ,p_vendor_id                   => g_per_rec.vendor_id
    ,p_work_schedule               => g_per_rec.work_schedule
    ,p_work_telephone              => g_per_rec.work_telephone
    ,p_exp_check_send_to_address   => g_per_rec.expense_check_send_to_address
    ,p_hold_applicant_date_until   => g_per_rec.hold_applicant_date_until
    ,p_date_employee_data_verified => g_per_rec.date_employee_data_verified
    ,p_benefit_group_id            => g_per_rec.benefit_group_id
    ,p_coord_ben_med_pln_no        => g_per_rec.coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag       => g_per_rec.coord_ben_no_cvg_flag
    ,p_original_date_of_hire       => g_per_rec.original_date_of_hire
     -- DF
    ,p_attribute_category          => g_per_rec.attribute_category
    ,p_attribute1                  => g_per_rec.attribute1
    ,p_attribute2                  => g_per_rec.attribute2
    ,p_attribute3                  => g_per_rec.attribute3
    ,p_attribute4                  => g_per_rec.attribute4
    ,p_attribute5                  => g_per_rec.attribute5
    ,p_attribute6                  => g_per_rec.attribute6
    ,p_attribute7                  => g_per_rec.attribute7
    ,p_attribute8                  => g_per_rec.attribute8
    ,p_attribute9                  => g_per_rec.attribute9
    ,p_attribute10                 => g_per_rec.attribute10
    ,p_attribute11                 => g_per_rec.attribute11
    ,p_attribute12                 => g_per_rec.attribute12
    ,p_attribute13                 => g_per_rec.attribute13
    ,p_attribute14                 => g_per_rec.attribute14
    ,p_attribute15                 => g_per_rec.attribute15
    ,p_attribute16                 => g_per_rec.attribute16
    ,p_attribute17                 => g_per_rec.attribute17
    ,p_attribute18                 => g_per_rec.attribute18
    ,p_attribute19                 => g_per_rec.attribute19
    ,p_attribute20                 => g_per_rec.attribute20
    ,p_attribute21                 => g_per_rec.attribute21
    ,p_attribute22                 => g_per_rec.attribute22
    ,p_attribute23                 => g_per_rec.attribute23
    ,p_attribute24                 => g_per_rec.attribute24
    ,p_attribute25                 => g_per_rec.attribute25
    ,p_attribute26                 => g_per_rec.attribute26
    ,p_attribute27                 => g_per_rec.attribute27
    ,p_attribute28                 => g_per_rec.attribute28
    ,p_attribute29                 => g_per_rec.attribute29
    ,p_attribute30                 => g_per_rec.attribute30
     -- DDF
    ,p_per_information_category    => g_per_rec.per_information_category
    ,p_per_information1            => g_per_rec.per_information1
    ,p_per_information2            => g_per_rec.per_information2
    ,p_per_information3            => g_per_rec.per_information3
    ,p_per_information4            => g_per_rec.per_information4
    ,p_per_information5            => g_per_rec.per_information5
    ,p_per_information6            => g_per_rec.per_information6
    ,p_per_information7            => g_per_rec.per_information7
    ,p_per_information8            => g_per_rec.per_information8
    ,p_per_information9            => g_per_rec.per_information9
    ,p_per_information10           => g_per_rec.per_information10
    ,p_per_information11           => g_per_rec.per_information11
    ,p_per_information12           => g_per_rec.per_information12
    ,p_per_information13           => g_per_rec.per_information13
    ,p_per_information14           => g_per_rec.per_information14
    ,p_per_information15           => g_per_rec.per_information15
    ,p_per_information16           => g_per_rec.per_information16
    ,p_per_information17           => g_per_rec.per_information17
    ,p_per_information18           => g_per_rec.per_information18
    ,p_per_information19           => g_per_rec.per_information19
    ,p_per_information20           => g_per_rec.per_information20
    ,p_per_information21           => g_per_rec.per_information21
    ,p_per_information22           => g_per_rec.per_information22
    ,p_per_information23           => g_per_rec.per_information23
    ,p_per_information24           => g_per_rec.per_information24
    ,p_per_information25           => g_per_rec.per_information25
    ,p_per_information26           => g_per_rec.per_information26
    ,p_per_information27           => g_per_rec.per_information27
    ,p_per_information28           => g_per_rec.per_information28
    ,p_per_information29           => g_per_rec.per_information29
    ,p_per_information30           => g_per_rec.per_information30
     -- Out Variables
    ,p_person_id                   => p_cwk_api_out.person_id
    ,p_assignment_id               => p_cwk_api_out.assignment_id
    ,p_per_object_version_number   => p_cwk_api_out.per_object_version_number
    ,p_asg_object_version_number   => p_cwk_api_out.asg_object_version_number
    ,p_per_effective_start_date    => p_cwk_api_out.per_effective_start_date
    ,p_per_effective_end_date      => p_cwk_api_out.per_effective_end_date
    ,p_full_name                   => p_cwk_api_out.full_name
    ,p_comment_id                  => p_cwk_api_out.per_comment_id
    ,p_pdp_object_version_number   => p_cwk_api_out.pdp_object_version_number
    ,p_assignment_sequence         => p_cwk_api_out.assignment_sequence
    ,p_assignment_number           => p_cwk_api_out.assignment_number
    ,p_name_combination_warning    => p_cwk_api_out.name_combination_warning
    );
    --
    -- Person record
    --
    g_per_rec.person_id             := p_cwk_api_out.person_id;
    g_per_rec.object_version_number := p_cwk_api_out.per_object_version_number;
    g_per_rec.effective_start_date  := p_cwk_api_out.per_effective_start_date;
    g_per_rec.effective_end_date    := p_cwk_api_out.per_effective_end_date;
    --
    -- Assignment record
    --
    g_asg_rec.person_id             := p_cwk_api_out.person_id;
    g_asg_rec.assignment_id         := p_cwk_api_out.assignment_id;
    g_asg_rec.object_version_number := p_cwk_api_out.asg_object_version_number;

    -- by DBANSAL , use the assignment number entered by user in spreadsheet
    g_asg_rec.assignment_number := NVL(g_asg_rec.assignment_number,
                                        p_cwk_api_out.assignment_number);

    g_asg_rec.assignment_sequence   := p_cwk_api_out.assignment_sequence;
    --
    -- Address record
    --
    g_add_rec.person_id             := p_cwk_api_out.person_id;
    g_add_rec.date_from             := g_per_rec.start_date;
    g_add_rec.date_to               := null;

  elsif p_action_mode = 'CONVERT_TO_CWK' then

        HR_Contingent_Worker_API.Convert_To_CWK
       (p_validate                      => p_validate
       ,p_effective_date                => g_per_rec.start_date
       ,p_person_id                     => g_per_rec.person_id
       --,p_projected_placement_end     => g_per_rec.
       ,p_person_type_id                => g_per_rec.person_type_id
       ,p_datetrack_update_mode         => l_datetrack_update_mode
        -- In/Out Variables
       ,p_object_version_number         => g_per_rec.object_version_number
       ,p_npw_number                    => g_per_rec.npw_number
        -- Out variables
       ,p_per_effective_start_date      => p_cwk_api_out.per_effective_start_date
       ,p_per_effective_end_date        => p_cwk_api_out.per_effective_end_date
       ,p_pdp_object_version_number     => p_cwk_api_out.pdp_object_version_number
       ,p_assignment_id                 => p_cwk_api_out.assignment_id
       ,p_asg_object_version_number     => p_cwk_api_out.asg_object_version_number
       ,p_assignment_sequence           => p_cwk_api_out.assignment_sequence
        );
       --
       -- Person record
       --
       g_per_rec.effective_start_date  := p_cwk_api_out.per_effective_start_date;
       g_per_rec.effective_end_date    := p_cwk_api_out.per_effective_end_date;
       --
       -- Assignment record
       --
       g_asg_rec.person_id             := g_per_rec.person_id;
       g_asg_rec.assignment_id         := p_cwk_api_out.assignment_id;
       g_asg_rec.object_version_number := p_cwk_api_out.asg_object_version_number;
       g_asg_rec.assignment_number     := p_cwk_api_out.assignment_number;
       g_asg_rec.assignment_sequence   := p_cwk_api_out.assignment_sequence;
       --
       -- Address record
       --
       g_add_rec.person_id             := g_per_rec.person_id;
       g_add_rec.date_from             := g_per_rec.start_date;
       g_add_rec.date_to               := null;

  elsif p_action_mode = 'APPLY_FOR_JOB' then

        HR_Contingent_Worker_API.Apply_For_Job
       (p_validate                      => p_validate
       ,p_effective_date                => g_per_rec.start_date
       ,p_person_id                     => g_per_rec.person_id
       ,p_person_type_id                => g_per_rec.person_type_id
       --,p_vacancy_id                    => g_per_rec.
        -- In/Out
       ,p_object_version_number         => g_per_rec.object_version_number
       ,p_applicant_number              => g_per_rec.applicant_number
        -- Out
       ,p_per_effective_start_date      => p_cwk_api_out.per_effective_start_date
       ,p_per_effective_end_date        => p_cwk_api_out.per_effective_end_date
       ,p_application_id                => l_application_id
       ,p_apl_object_version_number     => l_apl_object_version_number
       ,p_assignment_id                 => p_cwk_api_out.assignment_id
       ,p_asg_object_version_number     => p_cwk_api_out.asg_object_version_number
       ,p_assignment_sequence           => p_cwk_api_out.assignment_sequence
        );
       --
       -- Person record
       --
       g_per_rec.effective_start_date  := p_cwk_api_out.per_effective_start_date;
       g_per_rec.effective_end_date    := p_cwk_api_out.per_effective_end_date;
       --
       -- Assignment record
       --
       g_asg_rec.person_id             := g_per_rec.person_id;
       g_asg_rec.assignment_id         := p_cwk_api_out.assignment_id;
       g_asg_rec.object_version_number := p_cwk_api_out.asg_object_version_number;
       g_asg_rec.assignment_sequence   := p_cwk_api_out.assignment_sequence;
       --
       -- Address record
       --
       g_add_rec.person_id             := g_per_rec.person_id;
       g_add_rec.date_from             := g_per_rec.start_date;
       g_add_rec.date_to               := null;
  end if;

  if g_debug then
    hr_utility.set_location('..person_id                 : ' ||
                             p_cwk_api_out.person_id,20);
    hr_utility.set_location('..assignment_id             : ' ||
                             p_cwk_api_out.assignment_id,20);
    hr_utility.set_location('..per_object_version_number : ' ||
                             p_cwk_api_out.per_object_version_number,20);
    hr_utility.set_location('..asg_object_version_number : ' ||
                             p_cwk_api_out.asg_object_version_number,20);
    hr_utility.set_location('..per_effective_start_date  : ' ||
                             p_cwk_api_out.per_effective_start_date,20);
    hr_utility.set_location('..per_effective_end_date    : ' ||
                             p_cwk_api_out.per_effective_end_date,20);
    hr_utility.set_location('..full_name                 : ' ||
                             p_cwk_api_out.full_name,20);
    hr_utility.set_location('..per_comment_id            : ' ||
                             p_cwk_api_out.per_comment_id,20);
    hr_utility.set_location('..assignment_sequence       : ' ||
                             p_cwk_api_out.assignment_sequence,20);
    hr_utility.set_location('..assignment_number         : ' ||
                             p_cwk_api_out.assignment_number,20);
  end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 30);

exception
  when Others then
  hr_utility.set_location('Leaving: ' || l_proc_name, 40);
  raise;

end InsUpd_Contingent_Worker;
-- =============================================================================
-- ~ InsUpd_Contact_Person:
-- =============================================================================
procedure InsUpd_Contact_Person
         (p_validate            boolean  default false
         ,p_effective_date      date
         ,p_adjusted_svc_date   date     default null
         ,p_per_comments        varchar2 default null
         ,p_contact_api_out     out nocopy t_hrEmpApi) as

  l_proc_name         constant varchar2(150):= g_pkg ||'InsUpd_Contact_Person';

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  Hr_Contact_Api.Create_Person
  (p_validate                     => p_validate
  ,p_start_date                   => g_per_rec.start_date
  ,p_business_group_id            => g_per_rec.business_group_id
  ,p_last_name                    => g_per_rec.last_name
  ,p_sex                          => g_per_rec.sex
  ,p_person_type_id               => g_per_rec.person_type_id
  ,p_comments                     => p_per_comments
  ,p_date_employee_data_verified  => g_per_rec.date_employee_data_verified
  ,p_date_of_birth                => g_per_rec.date_of_birth
  ,p_email_address                => g_per_rec.email_address
  ,p_expense_check_send_to_addres => g_per_rec.expense_check_send_to_address
  ,p_first_name                   => g_per_rec.first_name
  ,p_known_as                     => g_per_rec.known_as
  ,p_marital_status               => g_per_rec.marital_status
  ,p_middle_names                 => g_per_rec.middle_names
  ,p_nationality                  => g_per_rec.nationality
  ,p_national_identifier          => g_per_rec.national_identifier
  ,p_previous_last_name           => g_per_rec.previous_last_name
  ,p_registered_disabled_flag     => g_per_rec.registered_disabled_flag
  ,p_title                        => g_per_rec.title
  ,p_vendor_id                    => g_per_rec.vendor_id
  ,p_work_telephone               => g_per_rec.work_telephone
  ,p_correspondence_language      => g_per_rec.correspondence_language
  ,p_honors                       => g_per_rec.honors
  ,p_benefit_group_id             => g_per_rec.benefit_group_id
  ,p_on_military_service          => g_per_rec.on_military_service
  ,p_student_status               => g_per_rec.student_status
  ,p_uses_tobacco_flag            => g_per_rec.uses_tobacco_flag
  ,p_coord_ben_no_cvg_flag        => g_per_rec.coord_ben_no_cvg_flag
  ,p_pre_name_adjunct             => g_per_rec.pre_name_adjunct
  ,p_suffix                       => g_per_rec.suffix
  ,p_town_of_birth                => g_per_rec.town_of_birth
  ,p_region_of_birth              => g_per_rec.region_of_birth
  ,p_country_of_birth             => g_per_rec.country_of_birth
  ,p_global_person_id             => g_per_rec.global_person_id
   -- DF
  ,p_attribute_category           => g_per_rec.attribute_category
  ,p_attribute1                   => g_per_rec.attribute1
  ,p_attribute2                   => g_per_rec.attribute2
  ,p_attribute3                   => g_per_rec.attribute3
  ,p_attribute4                   => g_per_rec.attribute4
  ,p_attribute5                   => g_per_rec.attribute5
  ,p_attribute6                   => g_per_rec.attribute6
  ,p_attribute7                   => g_per_rec.attribute7
  ,p_attribute8                   => g_per_rec.attribute8
  ,p_attribute9                   => g_per_rec.attribute9
  ,p_attribute10                  => g_per_rec.attribute10
  ,p_attribute11                  => g_per_rec.attribute11
  ,p_attribute12                  => g_per_rec.attribute12
  ,p_attribute13                  => g_per_rec.attribute13
  ,p_attribute14                  => g_per_rec.attribute14
  ,p_attribute15                  => g_per_rec.attribute15
  ,p_attribute16                  => g_per_rec.attribute16
  ,p_attribute17                  => g_per_rec.attribute17
  ,p_attribute18                  => g_per_rec.attribute18
  ,p_attribute19                  => g_per_rec.attribute19
  ,p_attribute20                  => g_per_rec.attribute20
  ,p_attribute21                  => g_per_rec.attribute21
  ,p_attribute22                  => g_per_rec.attribute22
  ,p_attribute23                  => g_per_rec.attribute23
  ,p_attribute24                  => g_per_rec.attribute24
  ,p_attribute25                  => g_per_rec.attribute25
  ,p_attribute26                  => g_per_rec.attribute26
  ,p_attribute27                  => g_per_rec.attribute27
  ,p_attribute28                  => g_per_rec.attribute28
  ,p_attribute29                  => g_per_rec.attribute29
  ,p_attribute30                  => g_per_rec.attribute30
   -- DDF
  ,p_per_information_category     => g_per_rec.per_information_category
  ,p_per_information1             => g_per_rec.per_information1
  ,p_per_information2             => g_per_rec.per_information2
  ,p_per_information3             => g_per_rec.per_information3
  ,p_per_information4             => g_per_rec.per_information4
  ,p_per_information5             => g_per_rec.per_information5
  ,p_per_information6             => g_per_rec.per_information6
  ,p_per_information7             => g_per_rec.per_information7
  ,p_per_information8             => g_per_rec.per_information8
  ,p_per_information9             => g_per_rec.per_information9
  ,p_per_information10            => g_per_rec.per_information10
  ,p_per_information11            => g_per_rec.per_information11
  ,p_per_information12            => g_per_rec.per_information12
  ,p_per_information13            => g_per_rec.per_information13
  ,p_per_information14            => g_per_rec.per_information14
  ,p_per_information15            => g_per_rec.per_information15
  ,p_per_information16            => g_per_rec.per_information16
  ,p_per_information17            => g_per_rec.per_information17
  ,p_per_information18            => g_per_rec.per_information18
  ,p_per_information19            => g_per_rec.per_information19
  ,p_per_information20            => g_per_rec.per_information20
  ,p_per_information21            => g_per_rec.per_information21
  ,p_per_information22            => g_per_rec.per_information22
  ,p_per_information23            => g_per_rec.per_information23
  ,p_per_information24            => g_per_rec.per_information24
  ,p_per_information25            => g_per_rec.per_information25
  ,p_per_information26            => g_per_rec.per_information26
  ,p_per_information27            => g_per_rec.per_information27
  ,p_per_information28            => g_per_rec.per_information28
  ,p_per_information29            => g_per_rec.per_information29
  ,p_per_information30            => g_per_rec.per_information30
  -- Out Variables
  ,p_person_id                    => p_contact_api_out.person_id
  ,p_object_version_number        => p_contact_api_out.per_object_version_number
  ,p_effective_start_date         => p_contact_api_out.per_effective_start_date
  ,p_effective_end_date           => p_contact_api_out.per_effective_end_date
  ,p_full_name                    => p_contact_api_out.full_name
  ,p_comment_id                   => p_contact_api_out.per_comment_id
  ,p_name_combination_warning     => p_contact_api_out.name_combination_warning
  ,p_orig_hire_warning            => p_contact_api_out.orig_hire_warning
   );
  --
  -- Person record
  --
  g_per_rec.person_id             := p_contact_api_out.person_id;
  g_per_rec.object_version_number := p_contact_api_out.per_object_version_number;
  g_per_rec.effective_start_date  := p_contact_api_out.per_effective_start_date;
  g_per_rec.effective_end_date    := p_contact_api_out.per_effective_end_date;
  --
  -- Address record
  --
  g_add_rec.person_id             := p_contact_api_out.person_id;
  g_add_rec.date_from             := g_per_rec.start_date;
  g_add_rec.date_to               := null;

  if g_debug then
    hr_utility.set_location('..person_id                 : ' ||
                             p_contact_api_out.person_id,20);
    hr_utility.set_location('..per_object_version_number : ' ||
                             p_contact_api_out.per_object_version_number,20);
    hr_utility.set_location('..per_effective_start_date  : ' ||
                             p_contact_api_out.per_effective_start_date,20);
    hr_utility.set_location('..per_effective_end_date    : ' ||
                             p_contact_api_out.per_effective_end_date,20);
    hr_utility.set_location('..full_name                 : ' ||
                             p_contact_api_out.full_name,20);
    hr_utility.set_location('..per_comment_id            : ' ||
                             p_contact_api_out.per_comment_id,20);
  end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 30);

exception
  when Others then
  hr_utility.set_location('Leaving: ' || l_proc_name, 40);
  raise;

end InsUpd_Contact_Person;
-- =============================================================================
-- ~ Upd_Batch_Employee_Asg:
-- =============================================================================
procedure Upd_Batch_Employee_Asg
         (p_batch_id              in number
         ,p_user_sequence         in out nocopy number
         ,p_link_value            in number
         ,p_assignment_user_key   in varchar2
         ,p_action_mode           in varchar2
         ,p_datetrack_update_mode in varchar2
          ) is

  l_proc_name constant varchar2(150):= g_pkg ||'Upd_Batch_Employee_Asg';

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 5);

      --$ Update Assignment only if User wants to i.e. he has chosen mandatory column
      -- 'Assign Organization' in the layout and entered a value
     if (g_asg_rec.organization_id is NULL) then
     Hr_Utility.set_location('Leaving: '||l_proc_name, 6);
     return;
     end if;

     --$ Upload supervisor id
     if g_asg_rec.supervisor_id is NOT NULL then
      hr_pump_utils.add_user_key
     (p_user_key_value =>  g_supervisor_user_key
     ,p_unique_key_id  =>  g_asg_rec.supervisor_id
      );
     else
     g_supervisor_user_key := null;
     end if;

    --$ while updating assignment pass assignment effective start date as obtained
   -- from spreadsheet by default and if it is null then use person start date as
   -- assignment effective start date

  Hrdpp_Update_Emp_Asg.Insert_Batch_Lines
  (p_batch_id                      => p_batch_id
  ,p_user_sequence                 => p_user_sequence
  ,p_link_value                    => p_link_value
  ,p_datetrack_update_mode         => p_datetrack_update_mode
  ,p_assignment_user_key           => p_assignment_user_key
  ,p_effective_date                => nvl(g_asg_rec.effective_start_date,g_per_rec.start_date)
  ,p_change_reason                 => g_asg_rec.change_reason
  ,p_date_probation_end            => g_asg_rec.date_probation_end
  ,p_frequency                     => g_asg_rec.frequency
  ,p_internal_address_line         => g_asg_rec.internal_address_line
  ,p_manager_flag                  => g_asg_rec.manager_flag
  ,p_normal_hours                  => g_asg_rec.normal_hours
  ,p_perf_review_period            => g_asg_rec.perf_review_period
  ,p_perf_review_period_frequency  => g_asg_rec.perf_review_period_frequency
  ,p_probation_period              => g_asg_rec.probation_period
  ,p_probation_unit                => g_asg_rec.probation_unit
  ,p_sal_review_period             => g_asg_rec.sal_review_period
  ,p_sal_review_period_frequency   => g_asg_rec.sal_review_period_frequency
  ,p_source_type                   => g_asg_rec.source_type
  ,p_time_normal_finish            => g_asg_rec.time_normal_finish
  ,p_time_normal_start             => g_asg_rec.time_normal_start
  ,p_bargaining_unit_code          => g_asg_rec.bargaining_unit_code
  ,p_labour_union_member_flag      => g_asg_rec.labour_union_member_flag
  ,p_hourly_salaried_code          => g_asg_rec.hourly_salaried_code
  ,p_ass_attribute_category        => g_asg_rec.ass_attribute_category
  ,p_ass_attribute1                => g_asg_rec.ass_attribute1
  ,p_ass_attribute2                => g_asg_rec.ass_attribute2
  ,p_ass_attribute3                => g_asg_rec.ass_attribute3
  ,p_ass_attribute4                => g_asg_rec.ass_attribute4
  ,p_ass_attribute5                => g_asg_rec.ass_attribute5
  ,p_ass_attribute6                => g_asg_rec.ass_attribute6
  ,p_ass_attribute7                => g_asg_rec.ass_attribute7
  ,p_ass_attribute8                => g_asg_rec.ass_attribute8
  ,p_ass_attribute9                => g_asg_rec.ass_attribute9
  ,p_ass_attribute10               => g_asg_rec.ass_attribute10
  ,p_ass_attribute11               => g_asg_rec.ass_attribute11
  ,p_ass_attribute12               => g_asg_rec.ass_attribute12
  ,p_ass_attribute13               => g_asg_rec.ass_attribute13
  ,p_ass_attribute14               => g_asg_rec.ass_attribute14
  ,p_ass_attribute15               => g_asg_rec.ass_attribute15
  ,p_ass_attribute16               => g_asg_rec.ass_attribute16
  ,p_ass_attribute17               => g_asg_rec.ass_attribute17
  ,p_ass_attribute18               => g_asg_rec.ass_attribute18
  ,p_ass_attribute19               => g_asg_rec.ass_attribute19
  ,p_ass_attribute20               => g_asg_rec.ass_attribute20
  ,p_ass_attribute21               => g_asg_rec.ass_attribute21
  ,p_ass_attribute22               => g_asg_rec.ass_attribute22
  ,p_ass_attribute23               => g_asg_rec.ass_attribute23
  ,p_ass_attribute24               => g_asg_rec.ass_attribute24
  ,p_ass_attribute25               => g_asg_rec.ass_attribute25
  ,p_ass_attribute26               => g_asg_rec.ass_attribute26
  ,p_ass_attribute27               => g_asg_rec.ass_attribute27
  ,p_ass_attribute28               => g_asg_rec.ass_attribute28
  ,p_ass_attribute29               => g_asg_rec.ass_attribute29
  ,p_ass_attribute30               => g_asg_rec.ass_attribute30
  ,p_segment1                      => g_scl_rec.segment1
  ,p_segment2                      => g_scl_rec.segment2
  ,p_segment3                      => g_scl_rec.segment3
  ,p_segment4                      => g_scl_rec.segment4
  ,p_segment5                      => g_scl_rec.segment5
  ,p_segment6                      => g_scl_rec.segment6
  ,p_segment7                      => g_scl_rec.segment7
  ,p_segment8                      => g_scl_rec.segment8
  ,p_segment9                      => g_scl_rec.segment9
  ,P_SEGMENT10                     => g_scl_rec.segment10
  ,P_SEGMENT11                     => g_scl_rec.segment11
  ,P_SEGMENT12                     => g_scl_rec.segment12
  ,P_SEGMENT13                     => g_scl_rec.segment13
  ,P_SEGMENT14                     => g_scl_rec.segment14
  ,P_SEGMENT15                     => g_scl_rec.segment15
  ,P_SEGMENT16                     => g_scl_rec.segment16
  ,P_SEGMENT17                     => g_scl_rec.segment17
  ,P_SEGMENT18                     => g_scl_rec.segment18
  ,P_SEGMENT19                     => g_scl_rec.segment19
  ,P_SEGMENT20                     => g_scl_rec.segment20
  ,P_SEGMENT21                     => g_scl_rec.segment21
  ,P_SEGMENT22                     => g_scl_rec.segment22
  ,P_SEGMENT23                     => g_scl_rec.segment23
  ,P_SEGMENT24                     => g_scl_rec.segment24
  ,P_SEGMENT25                     => g_scl_rec.segment25
  ,P_SEGMENT26                     => g_scl_rec.segment26
  ,P_SEGMENT27                     => g_scl_rec.segment27
  ,P_SEGMENT28                     => g_scl_rec.segment28
  ,P_SEGMENT29                     => g_scl_rec.segment29
  ,P_SEGMENT30                     => g_scl_rec.segment30
  --$
  ,P_EMPLOYEE_CATEGORY             => g_asg_rec.employee_category
  ,P_ASSIGNMENT_NUMBER             => g_asg_rec.assignment_number
  ,P_COMMENTS                      => g_asg_comments
  ,P_SUPERVISOR_USER_KEY           => g_supervisor_user_key

  ,p_cagr_grade_def_id             => null
  ,p_con_seg_user_name             => null
  );

   p_user_sequence := p_user_sequence + 1;

   hr_utility.set_location('..Inserted into Hrdpp_Update_Emp_Asg', 10);

   Hrdpp_Update_Emp_Asg_Criteria.Insert_Batch_Lines
  (p_batch_id                => p_batch_id
  ,p_user_sequence           => p_user_sequence
  ,p_link_value              => p_link_value
  ,p_datetrack_update_mode   => 'CORRECTION'
  ,p_assignment_user_key     => p_assignment_user_key
  ,p_effective_date          => nvl(g_asg_rec.effective_start_date,g_per_rec.start_date)
  ,p_segment1                => g_grp_rec.segment1
  ,p_segment2                => g_grp_rec.segment2
  ,p_segment3                => g_grp_rec.segment3
  ,p_segment4                => g_grp_rec.segment4
  ,p_segment5                => g_grp_rec.segment5
  ,p_segment6                => g_grp_rec.segment6
  ,p_segment7                => g_grp_rec.segment7
  ,p_segment8                => g_grp_rec.segment8
  ,p_segment9                => g_grp_rec.segment9
  ,p_segment10               => g_grp_rec.segment10
  ,p_segment11               => g_grp_rec.segment11
  ,p_segment12               => g_grp_rec.segment12
  ,p_segment13               => g_grp_rec.segment13
  ,p_segment14               => g_grp_rec.segment14
  ,p_segment15               => g_grp_rec.segment15
  ,p_segment16               => g_grp_rec.segment16
  ,p_segment17               => g_grp_rec.segment17
  ,p_segment18               => g_grp_rec.segment18
  ,p_segment19               => g_grp_rec.segment19
  ,p_segment20               => g_grp_rec.segment20
  ,p_segment21               => g_grp_rec.segment21
  ,p_segment22               => g_grp_rec.segment22
  ,p_segment23               => g_grp_rec.segment23
  ,p_segment24               => g_grp_rec.segment24
  ,p_segment25               => g_grp_rec.segment25
  ,p_segment26               => g_grp_rec.segment26
  ,p_segment27               => g_grp_rec.segment27
  ,p_segment28               => g_grp_rec.segment28
  ,p_segment29               => g_grp_rec.segment29
  ,p_segment30               => g_grp_rec.segment30
  ,p_special_ceiling_step_id => g_asg_rec.special_ceiling_step_id
  ,p_people_group_id         => g_asg_rec.people_group_id
  ,p_grade_name              => g_wstr_names.grade_name
  ,p_position_name           => g_wstr_names.position_name
  ,p_job_name                => g_wstr_names.job_name
  ,p_payroll_name            => g_wstr_names.payroll_name
  ,p_location_code           => g_wstr_names.location_code
  ,p_organization_name       => g_wstr_names.organization_name
  ,p_pay_basis_name          => g_wstr_names.pay_basis_name
  --$
  ,P_EMPLOYMENT_CATEGORY     => g_asg_rec.assignment_category
  ,p_language_code           => userenv('LANG')
  ,p_con_seg_user_name       => null
   );
  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

end Upd_Batch_Employee_Asg;
-- =============================================================================
-- Update_Batch_Assignment:
-- =============================================================================
procedure Update_Batch_Assignment
         (p_effective_date        in date
         ,p_business_group_id     in number
         ,p_person_id             in number
         ,p_batch_id              in number
         ,p_user_sequence         in out nocopy number
         ,p_link_value            in number
         ,p_assignment_user_key   in varchar2
         ,p_action_mode           in varchar2
         ) as

  cursor csr_asg (c_assignment_number in varchar2
                 ,c_person_id         in number
                 ,c_business_group_id in number
                 ,c_effective_date    in date
                 ) is
  select *
    from per_all_assignments_f paf
   where paf.person_id = c_person_id
     and paf.assignment_number = c_assignment_number
     and paf.business_group_id = c_business_group_id
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;

  cursor csr_asg_id (c_assignment_id in number
                 ,c_person_id         in number
                 ,c_business_group_id in number
                 ,c_effective_date    in date
                 ) is
  select *
    from per_all_assignments_f paf
   where paf.person_id = c_person_id
     and paf.assignment_id = c_assignment_id
     and paf.business_group_id = c_business_group_id
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;

  l_asg_rec                csr_asg%rowtype;
  l_AsgUpdCrit_Api         t_AsgUpdCrit_Api;
  l_proc_name constant     varchar2(150) := g_pkg||'Update_Batch_Assignment';
  l_datetrack_update_mode  varchar2(150);
  l_dt_correction          boolean;
  l_dt_update              boolean;
  l_dt_upd_override        boolean;
  l_upd_chg_ins            boolean;
  --$
  e_sec_asg                exception;
  l_error_mesg              varchar2(2000);
  l_secondary              boolean;
begin
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  if g_asg_rec.organization_id is null or
    --$ Commented the following condition
     -- g_asg_rec.assignment_status_type_id is null or
     g_asg_rec.assignment_number is null then
     Hr_Utility.set_location('Leaving: '||l_proc_name, 6);
     return;
  end if;

  if g_asg_rec.assignment_number is null AND g_migration_flag = 'N' then
          hr_utility.set_location('Inside else ', 7);
          hr_utility.set_location('The assignment id is : '||g_asg_rec.assignment_id, 8);
  	      open csr_asg_id (c_assignment_id => g_asg_rec.assignment_id
              ,c_person_id         => p_person_id
              ,c_business_group_id => p_business_group_id
              ,c_effective_date    => p_effective_date
              );
         fetch csr_asg_id into l_asg_rec;
         if csr_asg_id%notfound then
         close csr_asg_id;
         l_secondary := true;
         else
         close csr_asg_id;
         l_secondary := false;
         end if;
  else
  	  open csr_asg (c_assignment_number => g_asg_rec.assignment_number
               ,c_person_id         => p_person_id
               ,c_business_group_id => p_business_group_id
               ,c_effective_date    => p_effective_date
               );
  	  fetch csr_asg into l_asg_rec;
      if csr_asg%notfound then
          close csr_asg;
          l_secondary := true;
      else
          close csr_asg;
          l_secondary := false;
      end if;
  end if;

 /* if g_migration_flag = 'Y' then
      open csr_asg (c_assignment_number => g_asg_rec.assignment_number
               ,c_person_id         => p_person_id
               ,c_business_group_id => p_business_group_id
               ,c_effective_date    => p_effective_date
               );
      fetch csr_asg into l_asg_rec;
      if csr_asg%notfound then
         close csr_asg;
         l_secondary := true;
      else
         close csr_asg;
         l_secondary := false;
      end if;
  else
      open csr_asg_id (c_assignment_id => g_asg_rec.assignment_id
               ,c_person_id         => p_person_id
               ,c_business_group_id => p_business_group_id
               ,c_effective_date    => p_effective_date
               );
      fetch csr_asg_id into l_asg_rec;
      if csr_asg_id%notfound then
         close csr_asg_id;
         l_secondary := true;
      else
         close csr_asg_id;
         l_secondary := false;
      end if;
  end if ;*/
  if l_secondary then
    Hr_Utility.set_location('Leaving: '||l_proc_name, 7);
    --$
    l_error_mesg := 'Use direct API mode to create secondary assignments';
        raise e_sec_asg;
    return;
  else
    g_asg_rec.person_id := l_asg_rec.person_id;
    g_asg_rec.business_group_id := l_asg_rec.business_group_id;
    g_asg_rec.assignment_id := l_asg_rec.assignment_id;
    --g_asg_rec.assignment_status_type_id := l_asg_rec.assignment_status_type_id;

    Dt_Api.Find_DT_Upd_Modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'PER_ALL_ASSIGNMENTS_F'
    ,p_base_key_column       => 'ASSIGNMENT_ID'
    ,p_base_key_value        => g_asg_rec.assignment_id
    ,p_correction            => l_dt_correction
    ,p_update                => l_dt_update
    ,p_update_override       => l_dt_upd_override
    ,p_update_change_insert  => l_upd_chg_ins
     );
    if l_dt_update then
       l_datetrack_update_mode := 'UPDATE';
    elsif l_dt_upd_override or
          l_upd_chg_ins then
               --Else USE Correction Mode
        l_datetrack_update_mode := 'CORRECTION';
       hr_utility.set_location(' l_dt_upd_override or l_upd_chg_ins ', 8);
    else
       l_datetrack_update_mode := 'CORRECTION';
    end if;
  end if;

  if l_asg_rec.assignment_type ='E' then
     if (g_crt_upd = 'C' or g_crt_upd = 'U') then
     hr_pump_utils.add_user_key
     (p_user_key_value => p_assignment_user_key
     ,p_unique_key_id  => l_asg_rec.assignment_id
      );

     Upd_Batch_Employee_Asg
     (p_batch_id              => p_batch_id
     ,p_user_sequence         => p_user_sequence
     ,p_link_value            => p_link_value
     ,p_assignment_user_key   => p_assignment_user_key
     ,p_action_mode           => p_action_mode
     ,p_datetrack_update_mode => l_datetrack_update_mode
      );
     else
       raise e_upl_not_allowed;
     end if;
  elsif l_asg_rec.assignment_type ='C' then
     null;
  elsif l_asg_rec.assignment_type ='A' then
     null;
  end if;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

  --$
  exception
  when e_sec_asg then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',l_error_mesg);
    hr_utility.set_location('Leaving: ' || l_proc_name, 90);
    hr_utility.raise_error;
end Update_Batch_Assignment;

-- =============================================================================
-- DataPump_API_Call: p_data_pump_batch_line_id is used as link_value_id in the
-- procedure as in future we may have to have it as batch_line_ids concatenated
-- string.
-- =============================================================================
procedure DataPump_API_Call
         (p_data_pump_batch_line_id in varchar2
         ,p_batch_id                in number
         ,p_dup_party_id            in number
         ,p_dup_person_id           in number
         ,p_contact_name            in varchar
         ,p_dp_mode                 in varchar
         ,p_adjusted_svc_date       in date
--$update batch entry
         ,p_batch_link              in number
         ) as
  --
  -- Cursor gets the link_value for the record. It is the value 1
  -- added to the maximum value of Link_Value for that batch_id
  --
  cursor csr_get_link_value (c_batch_id number) is
  select Max(link_value) + 1
    from hr_pump_batch_lines
   where batch_id = c_batch_id;

  l_proc_name  constant     varchar2(150):= g_pkg ||'DataPump_API_Call';
  l_person_user_key         varchar2(240);
  l_assignment_user_key     varchar2(240);
  l_application_user_key    varchar2(240);
  l_address_user_key        varchar2(240);
  l_contact_key             varchar2(240);
  l_xtra_info_key           varchar2(240);
  l_temp                    varchar2(240);
  l_datetrack_update_mode   varchar2(50);

  l_hire_Into_Employee      boolean;
  l_Apply_ForJob            boolean;
  l_Convert_To_CWK          boolean;
  l_Per_Exists_InHR         boolean;
  l_hire_Applicant          boolean;
  l_Convert_To_Applicant    boolean;

  l_Input_PerType           varchar2(90);
  l_action_mode             varchar2(90);
  l_cur_rec                 per_all_people_f%rowtype;

  l_user_person_type        per_person_types.user_person_type%type;
  l_user_sequence           number(10);
  l_link_value              number;
  l_error_mesg              varchar2(2000);
  e_hire_applicant          exception;
  e_apply_for_job           exception;
  e_cwk                     exception;
begin
  hr_utility.set_location('Entering: ' || l_proc_name, 5);

  l_user_sequence := 1;
  --
  -- Creating User Keys for Person, Address, Assignment and Contact
  --
  l_temp := To_Char(Sysdate,'J')||
            to_char(systimestamp, 'HH24MISSFF3')||--To_Char(Sysdate,'HH24MISSD')||
            DBMS_Utility.get_Hash_Value(g_per_rec.last_name||
                                        g_per_rec.sex||
                                        g_per_rec.first_name,0,1000);

--hr_utility.trace('p_batch_id: '||p_batch_id);

  l_person_user_key     := 'HROSS~PER~'||l_temp;
  l_address_user_key    := 'HROSS~ADD~'||l_temp;
  l_assignment_user_key := 'HROSS~ASG~'||l_temp;
  l_application_user_key:= 'HROSS~APL~'||l_temp;
  l_contact_key         := 'HROSS~CNT~'||l_temp;
  l_xtra_info_key       := 'HROSS~XTR~'||l_temp;
  --$ To upload supervisor id use global var
  g_supervisor_user_key := 'HROSS~SUP~'||l_temp;

  if g_debug then
    hr_utility.set_location(' l_person_user_key: ' || l_person_user_key, 10);
    hr_utility.set_location(' l_address_user_key: ' || l_address_user_key, 10);
    hr_utility.set_location(' l_assignment_user_key: ' || l_assignment_user_key, 10);
    hr_utility.set_location(' l_contact_key: ' || l_contact_key, 10);
    hr_utility.set_location(' l_xtra_info_key: ' || l_xtra_info_key, 10);
  end if;
  --
  -- Get the User Person Type for the id passed
  --
  open  csr_per_type(g_per_rec.person_type_id
                    ,g_per_rec.business_group_id);
  fetch csr_per_type into l_user_person_type;
  close csr_per_type;
  --
  -- Get the Link value for this record
  --
  open  csr_get_link_value (p_batch_id);
  fetch csr_get_link_value into l_link_value;
  close csr_get_link_value;
  -- If first record is being entered then link_value returned from cursor
  -- will be null, hence we set it to 1
  if l_link_value is null then
     l_link_value := 1;
  end if;

--$ Update Batch Entry in case Corrections are to be made for a record
  if p_batch_link is not null then
 --Delete old records in batch lines for this batch id and link value
 --There  is a parent-child relationship between tables hr_pump_batch_line_user_keys and hr_pump_batch_lines
 --w.r.t. batch_line_id
 --So, first remove data from hr_pump_batch_line_user_keys and then from hr_pump_batch_lines

 delete from hr_pump_batch_line_user_keys where batch_line_id in (
  select batch_line_id from hr_pump_batch_lines where batch_id = p_batch_id
    and link_value = p_batch_link );

 delete from hr_pump_batch_lines where batch_id = p_batch_id and
         link_value = p_batch_link;
     --Now, use same link value to insert the corrected record and hence
     --new batch lines
     l_link_value := p_batch_link;
  end if;

  if g_debug then
     hr_utility.set_location(' l_user_person_type: '|| l_user_person_type, 15);
     hr_utility.set_location(' l_link_value: '|| l_link_value, 15);
  end if;

  --$ Get the value of "Benefit Group Name" from ID if not null
  if g_per_rec.benefit_group_id is not null then
     open csr_get_benefit_name (g_per_rec.benefit_group_id,
                                g_business_group_id);
     fetch csr_get_benefit_name into g_benefit_grp_name;
     close csr_get_benefit_name;
  else
     g_benefit_grp_name := null;
  end if;

  --
  -- Get the names of Work Structures based on the ids based.
  --
  Get_WrkStrs_Names;
  --
  -- If person id is passed check the creating person type with the person
  -- type of the person present in HRMS, to select the appropiate action.
  --
  Chk_Person_InHR
  (p_dup_person_id        => p_dup_person_id
  ,p_dup_party_id         => p_dup_party_id
  ,p_effective_date       => g_per_rec.start_date
  ,p_business_group_id    => g_business_group_id
  -- Out
  ,p_Input_PerType        => l_Input_PerType
  ,p_hire_Into_Employee   => l_hire_Into_Employee
  ,p_hire_Applicant       => l_hire_Applicant
  ,p_Convert_To_Applicant => l_Convert_To_Applicant
  ,p_Apply_For_Job        => l_Apply_ForJob
  ,p_Convert_To_CWK       => l_Convert_To_CWK
  ,p_Per_Exists_InHR      => l_Per_Exists_InHR
  );
  --
    --hr_utility.trace(' After Chk_Person_InHR call');
    --hr_utility.trace('$$_PSG l_Input_PerType ='||l_Input_PerType);

  Get_DataTrack_Mode
  (p_datetrack_update_mode => l_datetrack_update_mode
    );
  --
  if g_debug then
    hr_utility.set_location(' p_batch_id     : ' || p_batch_id, 20);
    hr_utility.set_location(' l_user_sequence: ' || l_user_sequence, 20);
    hr_utility.set_location(' l_link_value   : ' || l_link_value, 20);
    hr_utility.set_location(' l_datetrack_update_mode: ' || l_datetrack_update_mode, 20);
  end if;
  --
  -- Update existing person
  --
  if l_Input_PerType = 'UPD_PERSON' then
     hr_pump_utils.add_user_key
     (p_user_key_value => l_person_user_key
     ,p_unique_key_id  => g_per_rec.person_id
      );
     if (g_crt_upd = 'C' or g_crt_upd = 'U') then
     Upd_Batch_Person
     (p_batch_id                => p_batch_id
     ,p_user_sequence           => l_user_sequence
     ,p_link_value              => l_link_value
     ,p_person_user_key         => l_person_user_key
     ,p_user_person_type        => l_user_person_type
     ,p_datetrack_update_mode   => l_datetrack_update_mode
     ,p_adjusted_svc_date       =>  p_adjusted_svc_date   --Added by pkagrawa
      );
     else
     raise e_upl_not_allowed;
     end if;
     l_user_sequence := l_user_sequence + 1;


     --
     -- Insert/Update Primary Address
     --
     InsUpd_Batch_Address
     (p_batch_id             => p_batch_id
     ,p_user_sequence        => l_user_sequence
     ,p_link_value           => l_link_value
     ,p_person_user_key      => l_person_user_key
     ,p_address_user_key     => l_address_user_key
     );
     --
     -- Update the Person Assignment(EMP, APL or CWK Asg)
     --
     l_user_sequence := l_user_sequence + 1;

   --$ while updating assignment pass assignment effective start date as obtained
   -- from spreadsheet by default and if it is null then use person start date as
   -- assignment effective start date

     Update_Batch_Assignment
     (p_effective_date        => nvl(g_asg_rec.effective_start_date,g_per_rec.start_date)
     ,p_business_group_id     => g_per_rec.business_group_id
     ,p_person_id             => g_per_rec.person_id
     ,p_batch_id              => p_batch_id
     ,p_user_sequence         => l_user_sequence
     ,p_link_value            => l_link_value
     ,p_assignment_user_key   => l_assignment_user_key
     ,p_action_mode           => l_action_mode
      );
  end if;
  --
  -- Creating an Employee
  --
  if l_Input_PerType = 'EMP' then
     if l_hire_Into_Employee then
        if (g_crt_upd = 'C' or g_crt_upd = 'U') then
        l_action_mode := 'HIRE_INTO_JOB';
        else
        raise e_upl_not_allowed;
        end if;
     elsif l_hire_Applicant then
        if (g_crt_upd = 'C' or g_crt_upd = 'U') then
        l_action_mode := 'HIRE_APPLICANT';
        else
        raise e_upl_not_allowed;
        end if;
     else
        if (g_crt_upd = 'C') then
        l_action_mode := 'CREATE_EMPLOYEE';
        else
        raise e_crt_per_not_allowed;
        end if;
     end if;
     hr_utility.set_location(l_proc_name, 25);
     --

  --hr_utility.trace(' l_action_mode ='||l_action_mode);

     if l_action_mode in ('CREATE_EMPLOYEE',
                          'HIRE_INTO_JOB') then
        InsUpd_Batch_Employee
        (p_batch_id              => p_batch_id
        ,p_user_sequence         => l_user_sequence
        ,p_link_value            => l_link_value
        ,p_assignment_user_key   => l_assignment_user_key
        ,p_person_user_key       => l_person_user_key
        ,p_user_person_type      => l_user_person_type
        ,p_action_mode           => l_action_mode
        ,p_datetrack_update_mode => l_datetrack_update_mode
        ,p_cur_rec               => l_cur_rec
        ,p_adjusted_svc_date       =>  p_adjusted_svc_date   --Added by pkagrawa
         );
     elsif l_action_mode = 'HIRE_APPLICANT' then
        l_error_mesg := 'Use direct API mode call to hire an applicant';
        raise e_hire_applicant;
     end if;
     --
     -- Insert/Update Person Primary Address
     --
     hr_utility.set_location(l_proc_name, 30);
     l_user_sequence := l_user_sequence + 1;
     --
     -- Insert/Update Primary Address
     --
     InsUpd_Batch_Address
     (p_batch_id             => p_batch_id
     ,p_user_sequence        => l_user_sequence
     ,p_link_value           => l_link_value
     ,p_person_user_key      => l_person_user_key
     ,p_address_user_key     => l_address_user_key
      );
     --
     -- Update the Employee Assignment
     --
     hr_utility.set_location(l_proc_name, 35);
     l_datetrack_update_mode := 'CORRECTION';
     l_user_sequence := l_user_sequence + 1;

     if (g_crt_upd = 'C' or g_crt_upd = 'U') then
     Upd_Batch_Employee_Asg
     (p_batch_id              => p_batch_id
     ,p_user_sequence         => l_user_sequence
     ,p_link_value            => l_link_value
     ,p_assignment_user_key   => l_assignment_user_key
     ,p_action_mode           => l_action_mode
     ,p_datetrack_update_mode => l_datetrack_update_mode
      );
     else
       raise e_upl_not_allowed;
     end if;
  end if;
  --
  -- Creating an Applicant for a Job
  --
  --hr_utility.trace(' l_Input_PerType ='||l_Input_PerType);

  if l_Input_PerType = 'APL' then
     if l_Convert_To_Applicant or
        l_Apply_ForJob         then
        l_action_mode := 'APPLY_FOR_JOB';
        l_error_mesg := 'Use direct API mode to convert an existing person
                into an Applicant.';
        raise e_apply_for_job;
     else
      if (g_crt_upd = 'C') then
       l_action_mode := 'CREATE_APPLICANT';
      else
        raise e_crt_per_not_allowed;
      end if;
     end if;
     --
     -- Create/Convert the person into an applicant
     --
     InsUpd_Batch_Applicant
     (p_batch_id                => p_batch_id
     ,p_user_sequence           => l_user_sequence
     ,p_link_value              => l_link_value
     ,p_assignment_user_key     => l_assignment_user_key
     ,p_person_user_key         => l_person_user_key
     ,p_user_person_type        => l_user_person_type
     ,p_action_mode             => l_action_mode
     ,p_datetrack_update_mode   => l_datetrack_update_mode
     ,p_vacancy_user_key        => null
     ,p_application_user_key    => l_application_user_key
      );
     --
     -- Insert/Update Person Primary Address
     --
     hr_utility.set_location(l_proc_name, 30);
     l_user_sequence := l_user_sequence + 1;

     InsUpd_Batch_Address
     (p_batch_id         => p_batch_id
     ,p_user_sequence    => l_user_sequence
     ,p_link_value       => l_link_value
     ,p_person_user_key  => l_person_user_key
     ,p_address_user_key => l_address_user_key
     );
     --
     -- Update the Applicant assignment
     --
  end if;
  --
  -- Create the contact person only if the person does exists
  --
  if l_Input_PerType = 'OTHER' then
     if not l_Per_Exists_InHR then
       if (g_crt_upd = 'C') then
       InsUpd_Batch_ContactPerson
       (p_batch_id                => p_batch_id
       ,p_data_pump_batch_line_id => p_data_pump_batch_line_id
       ,p_user_sequence           => l_user_sequence
       ,p_link_value              => l_link_value
       ,p_person_user_key         => l_person_user_key
       ,p_user_person_type        => l_user_person_type
        );
       else
       raise e_crt_per_not_allowed;
       end if;
     else
       if (g_crt_upd = 'C' or g_crt_upd = 'U') then
       hr_pump_utils.add_user_key
       (p_user_key_value => l_person_user_key
       ,p_unique_key_id  => g_per_rec.person_id
        );
       Upd_Batch_Person
       (p_batch_id                => p_batch_id
       ,p_user_sequence           => l_user_sequence
       ,p_link_value              => l_link_value
       ,p_person_user_key         => l_person_user_key
       ,p_user_person_type        => l_user_person_type
       ,p_datetrack_update_mode   => l_datetrack_update_mode
        );
       else
       raise e_upl_not_allowed;
       end if;
     end if;

     hr_utility.set_location(l_proc_name, 30);
     l_user_sequence := l_user_sequence + 1;
     --
     -- Insert/Update Primary Address
     --
     InsUpd_Batch_Address
     (p_batch_id             => p_batch_id
     ,p_user_sequence        => l_user_sequence
     ,p_link_value           => l_link_value
     ,p_person_user_key      => l_person_user_key
     ,p_address_user_key     => l_address_user_key
     );
  end if;
  --
  -- Creating a Contingent Worker
  --
  if l_Input_PerType = 'CWK' then
     if l_Convert_To_CWK then
       l_action_mode := 'CONVERT_TO_CWK';
     else
       l_action_mode := 'CREATE_CWK';
     end if;
     l_error_mesg := 'Use Direct API mode to create Contingent worker or '||
                     'to convert an existing person into Contingent worker';
     raise e_cwk;
     --
     -- Create/Convert the person into an Contigent Worker
     --

     --
     -- Update/Insert Address
     --

     --
     -- Update the Contingent Worker assignment
     --
  end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 80);

exception
  when e_hire_applicant then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',l_error_mesg);
    hr_utility.set_location('Leaving: ' || l_proc_name, 90);
    hr_utility.raise_error;
  when e_apply_for_job then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',l_error_mesg);
    hr_utility.set_location('Leaving: ' || l_proc_name, 90);
    hr_utility.raise_error;
  when e_cwk then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',l_error_mesg);
    hr_utility.set_location('Leaving: ' || l_proc_name, 90);
    hr_utility.raise_error;
  when Others then
    hr_utility.set_location('Leaving: ' || l_proc_name, 90);
    raise;

end DataPump_API_Call;

-- =============================================================================
-- ~ HR_DataPumpErr:
-- =============================================================================
procedure HR_DataPumpErr
          (p_data_pump_batch_line_id in varchar2
          ,p_batch_id                in number
          ,p_contact_name            in varchar
--          ,p_dp_mode                 IN Varchar
          ,p_adjusted_svc_date       in date
          ) as

  -- Cursor gets the mode in which data was entered intially in
  -- DP interface tables
  cursor csr_get_dp_mode (c_batch_id   in number
                         ,c_link_value in number) is
  select 'CREATE'
    from hr_api_modules
   where module_name    = 'CREATE_EMPLOYEE'
     and module_package = 'HR_EMPLOYEE_API'
     and api_module_id in (select api_module_id
                             from hr_pump_batch_lines
                            where batch_id   = c_batch_id
                              and link_value = c_link_value);

  -- Cursor to get all the api_ids which have LINE_STATUS in status 'E' or 'U'
  cursor csr_get_api_names (c_batch_id   in number
                           ,c_link_value in number) is
  select module_name
    from hr_pump_batch_lines hpbl
        ,hr_api_modules      ham
   where batch_id    = c_batch_id
     and link_value  = c_link_value
     and line_status in ('U', 'E')
     and hpbl.api_module_id = ham.api_module_id;

  -- Cursor to get previous data from hrdpv_hire_into_job
  cursor csr_get_hire_job_data (c_batch_id   in number
                               ,c_link_value in number) is
  select *
    from hrdpv_hire_into_job
   where batch_id   = c_batch_id
     and link_value = c_link_value;

  l_dp_hire_job_rec      hrdpv_hire_into_job%rowtype;

  -- Cursor to get previous data from hrdpv_create_employee
  cursor csr_get_create_emp_data (c_batch_id   in number
                                 ,c_link_value in number) is
  select *
    from hrdpv_create_employee
   where batch_id   = c_batch_id
     and link_value = c_link_value;

  l_dp_crt_emp_rec       hrdpv_create_employee%rowtype;

  -- Cursor to get previous data from hrdpv_update_person
  cursor csr_get_update_per_data (c_batch_id   in number
                                 ,c_link_value in number) is
  select *
    from hrdpv_update_person
   where batch_id   = c_batch_id
     and link_value = c_link_value;

  l_dp_upd_per_rec       hrdpv_update_person%rowtype;

  -- Cursor to get previous data from hrdpv_update_person_address
  cursor csr_get_update_add_data (c_batch_id   in number
                                 ,c_link_value in number) is
  select *
    from hrdpv_update_person_address
   where batch_id   = c_batch_id
     and link_value = c_link_value;

  l_dp_upd_add_rec       hrdpv_update_person_address%rowtype;

  -- Cursor to get previous data from hrdpv_create_person_address
  cursor csr_get_create_add_data (c_batch_id   in number
                                 ,c_link_value in number) is
  select *
    from hrdpv_create_person_address
   where batch_id   = c_batch_id
     and link_value = c_link_value;

  l_dp_crt_add_rec       hrdpv_create_person_address%rowtype;

  -- Cursor to get previous data from hrdpv_update_emp_asg
  cursor csr_get_upd_asg_data (c_batch_id   in number
                              ,c_link_value in number) is
  select *
    from hrdpv_update_emp_asg
   where batch_id   = c_batch_id
     and link_value = c_link_value;

  l_dp_upd_asg_rec       hrdpv_update_emp_asg%rowtype;

  -- Cursor to get previous data from hrdpv_update_emp_asg_criteria
  cursor csr_get_upd_asg_crt_data (c_batch_id   in number
                                  ,c_link_value in number) is
  select *
    from hrdpv_update_emp_asg_criteria
   where batch_id   = c_batch_id
     and link_value = c_link_value;

  l_dp_upd_asg_crt_rec   hrdpv_update_emp_asg_criteria%rowtype;

  -- Cursor to get previous data from hrdpv_create_contact
  cursor csr_get_create_cnt_data (c_batch_id   in number
                                 ,c_link_value in number) is
  select *
    from hrdpv_create_contact
   where batch_id   = c_batch_id
     and link_value = c_link_value;

  l_dp_crt_cnt_rec       hrdpv_create_contact%rowtype;

  -- Cursor to get previous data from hrdpv_update_contact_relations
  cursor csr_get_update_cnt_data (c_batch_id   in number
                                 ,c_link_value in number) is
  select *
    from hrdpv_update_contact_relations
   where batch_id   = c_batch_id
     and link_value = c_link_value;

  l_dp_upd_cnt_rec      hrdpv_update_contact_relations%rowtype;

  l_proc_name  constant    varchar2(150):= g_pkg ||'HR_DataPumpErr';

  l_dp_mode                  varchar2(40);
  l_if_end_dated             varchar2(20);
  l_api_name                 hr_api_modules.module_name%type;
  l_user_person_type         per_person_types.user_person_type%type;
  l_pay_basis_name           per_pay_bases.name%type;
  l_organization_name        hr_all_organization_units.name%type;
  l_location_code            hr_locations_all.location_code%type;
  l_payroll_name             pay_payrolls_f.payroll_name%type;
  l_job_name                 per_jobs.name%type;
  l_position_name            per_positions.name%type;
  l_grade_name               per_grades.name%type;

  l_pradd_ovlapval_override  boolean;

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  -- Check if operation being corrected was insert or update because of
  -- duplicate person id based on the API_MODULE_ID in hr_pump_batch_lines
  -- and then set dp_mode flag respectively

  open csr_get_dp_mode (c_batch_id   => p_batch_id
                       ,c_link_value => p_data_pump_batch_line_id
                       );
  fetch csr_get_dp_mode into l_dp_mode;
  close csr_get_dp_mode;

  if l_dp_mode = null then
     l_dp_mode := 'UPDATE';
  end if;

  -- Cursor to get the User Person Type
  open  csr_per_type(g_per_rec.person_type_id
                    ,g_per_rec.business_group_id);
  fetch csr_per_type into l_user_person_type;
  close csr_per_type;

  -- If User hasn't entered the Employee Number, then get Employee Number
  -- for entered duplicate person id
  if g_per_rec.employee_number = null then
     open  csr_get_employee_num(c_person_id => g_per_rec.person_id);
     fetch csr_get_employee_num into g_per_rec.employee_number;
     close csr_get_employee_num;
  end if;

  -- Call a cursor to get all the API_MODULE_IDs for the respective batch_id
  -- where LINE_STATUS is either in 'E' (error) or in 'U' (unprocessed) mode

  open csr_get_api_names (c_batch_id   => p_batch_id
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


  loop

    fetch csr_get_api_names into l_api_name;
    exit when csr_get_api_names%notfound;


    -- Call if API_ID is 'Hire_Into_Job'
    if l_api_name = 'HIRE_INTO_JOB' then

       -- Call a cursor to get the current data in DP Interface Tables
       open  csr_get_hire_job_data (c_batch_id   => p_batch_id
                                   ,c_link_value => p_data_pump_batch_line_id);
       fetch csr_get_hire_job_data into l_dp_hire_job_rec;
       close csr_get_hire_job_data;

       -- Call Insert_Batch_lines
       Hrdpp_Hire_Into_Job.insert_batch_lines
       (p_batch_id                => p_batch_id
       ,p_data_pump_batch_line_id => l_dp_hire_job_rec.batch_line_id
       ,p_user_sequence           => l_dp_hire_job_rec.user_sequence
       ,p_link_value              => p_data_pump_batch_line_id
       ,p_effective_date          => g_per_rec.start_date
       ,p_object_version_number   => l_dp_hire_job_rec.p_object_version_number
       ,p_datetrack_update_mode   => l_dp_hire_job_rec.p_datetrack_update_mode
       ,p_employee_number         => g_per_rec.employee_number
       ,p_national_identifier     => g_per_rec.national_identifier
       ,p_per_information7        => null
       ,p_person_user_key         => l_dp_hire_job_rec.p_person_user_key
       ,p_user_person_type        => l_user_person_type
       ,p_assignment_user_key     => l_dp_hire_job_rec.p_assignment_user_key
       ,p_language_code           => Userenv('LANG')
       );
       /*
       InsUpd_Batch_Employee
       (p_batch_id                => p_batch_id
       ,p_data_pump_batch_line_id => l_dp_hire_job_rec.batch_line_id
       ,p_user_sequence           => l_dp_hire_job_rec.user_sequence
       ,p_link_value              => p_data_pump_batch_line_id
       ,p_assignment_user_key     => l_dp_hire_job_rec.p_assignment_user_key
       ,p_person_user_key         => l_dp_hire_job_rec.p_person_user_key
       ,p_user_person_type        => l_user_person_type
       ,p_action_mode             => 'HIRE_INTO_JOB'
       ,p_datetrack_update_mode   => l_datetrack_update_mode
       ,p_cur_rec                 => l_cur_rec
        );
        */
    end if;

    -- Call if API_ID is 'Create_Employee'
    if l_api_name = 'CREATE_EMPLOYEE' then

       open  csr_get_create_emp_data
              (c_batch_id   => p_batch_id
              ,c_link_value => p_data_pump_batch_line_id
               );
       fetch csr_get_create_emp_data into l_dp_crt_emp_rec;
       close csr_get_create_emp_data;

       Hrdpp_Create_Employee.Insert_Batch_Lines
       (p_batch_id                     => p_batch_id
       --l_dp_batch_line_id_emp
       ,p_data_pump_batch_line_id      => l_dp_crt_emp_rec.batch_line_id
       ,p_user_sequence                => l_dp_crt_emp_rec.user_sequence
       ,p_link_value                   => p_data_pump_batch_line_id
       ,p_hire_date                    => g_per_rec.start_date
       ,p_last_name                    => g_per_rec.last_name
       ,p_sex                          => g_per_rec.sex
       ,p_date_employee_data_verified  => g_per_rec.date_employee_data_verified
       ,p_date_of_birth                => g_per_rec.date_of_birth
       ,p_email_address                => g_per_rec.email_address
       ,p_employee_number              => g_per_rec.employee_number
       ,p_expense_check_send_to_addres => g_per_rec.expense_check_send_to_address
       ,p_first_name                   => g_per_rec.first_name
       ,p_known_as                     => g_per_rec.known_as
       ,p_marital_status               => g_per_rec.marital_status
       ,p_middle_names                 => g_per_rec.middle_names
       ,p_nationality                  => g_per_rec.nationality
       ,p_national_identifier          => g_per_rec.national_identifier
       ,p_previous_last_name           => g_per_rec.previous_last_name
       ,p_registered_disabled_flag     => g_per_rec.registered_disabled_flag
       ,p_title                        => g_per_rec.title
       ,p_attribute_category           => g_per_rec.attribute_category
       ,p_attribute1                   => g_per_rec.attribute1
       ,p_attribute2                   => g_per_rec.attribute2
       ,p_attribute3                   => g_per_rec.attribute3
       ,p_attribute4                   => g_per_rec.attribute4
       ,p_attribute5                   => g_per_rec.attribute5
       ,p_attribute6                   => g_per_rec.attribute6
       ,p_attribute7                   => g_per_rec.attribute7
       ,p_attribute8                   => g_per_rec.attribute8
       ,p_attribute9                   => g_per_rec.attribute9
       ,p_attribute10                  => g_per_rec.attribute10
       ,p_attribute11                  => g_per_rec.attribute11
       ,p_attribute12                  => g_per_rec.attribute12
       ,p_attribute13                  => g_per_rec.attribute13
       ,p_attribute14                  => g_per_rec.attribute14
       ,p_attribute15                  => g_per_rec.attribute15
       ,p_attribute16                  => g_per_rec.attribute16
       ,p_attribute17                  => g_per_rec.attribute17
       ,p_attribute18                  => g_per_rec.attribute18
       ,p_attribute19                  => g_per_rec.attribute19
       ,p_attribute20                  => g_per_rec.attribute20
       ,p_attribute21                  => g_per_rec.attribute21
       ,p_attribute22                  => g_per_rec.attribute22
       ,p_attribute23                  => g_per_rec.attribute23
       ,p_attribute24                  => g_per_rec.attribute24
       ,p_attribute25                  => g_per_rec.attribute25
       ,p_attribute26                  => g_per_rec.attribute26
       ,p_attribute27                  => g_per_rec.attribute27
       ,p_attribute28                  => g_per_rec.attribute28
       ,p_attribute29                  => g_per_rec.attribute29
       ,p_attribute30                  => g_per_rec.attribute30
       ,p_per_information_category     => g_per_rec.per_information_category
       ,p_per_information1             => g_per_rec.per_information1
       ,p_per_information2             => g_per_rec.per_information2
       ,p_per_information3             => g_per_rec.per_information3
       ,p_per_information4             => g_per_rec.per_information4
       ,p_per_information5             => g_per_rec.per_information5
       ,p_per_information6             => g_per_rec.per_information6
       ,p_per_information7             => g_per_rec.per_information7
       ,p_per_information8             => g_per_rec.per_information8
       ,p_per_information9             => g_per_rec.per_information9
       ,p_per_information10            => g_per_rec.per_information10
       ,p_per_information11            => g_per_rec.per_information11
       ,p_per_information12            => g_per_rec.per_information12
       ,p_per_information13            => g_per_rec.per_information13
       ,p_per_information14            => g_per_rec.per_information14
       ,p_per_information15            => g_per_rec.per_information15
       ,p_per_information16            => g_per_rec.per_information16
       ,p_per_information17            => g_per_rec.per_information17
       ,p_per_information18            => g_per_rec.per_information18
       ,p_per_information19            => g_per_rec.per_information19
       ,p_per_information20            => g_per_rec.per_information20
       ,p_per_information21            => g_per_rec.per_information21
       ,p_per_information22            => g_per_rec.per_information22
       ,p_per_information23            => g_per_rec.per_information23
       ,p_per_information24            => g_per_rec.per_information24
       ,p_per_information25            => g_per_rec.per_information25
       ,p_per_information26            => g_per_rec.per_information26
       ,p_per_information27            => g_per_rec.per_information27
       ,p_per_information28            => g_per_rec.per_information28
       ,p_per_information29            => g_per_rec.per_information29
       ,p_per_information30            => g_per_rec.per_information30
       ,p_date_of_death                => g_per_rec.date_of_death
       ,p_background_check_status      => g_per_rec.background_check_status
       ,p_background_date_check        => g_per_rec.background_date_check
       ,p_blood_type                   => g_per_rec.blood_type
       ,p_fast_path_employee           => g_per_rec.fast_path_employee
       ,p_fte_capacity                 => g_per_rec.fte_capacity
       ,p_honors                       => g_per_rec.honors
       ,p_internal_location            => g_per_rec.internal_location
       ,p_last_medical_test_by         => g_per_rec.last_medical_test_by
       ,p_last_medical_test_date       => g_per_rec.last_medical_test_date
       ,p_mailstop                     => g_per_rec.mailstop
       ,p_office_number                => g_per_rec.office_number
       ,p_on_military_service          => g_per_rec.on_military_service
       ,p_pre_name_adjunct             => g_per_rec.pre_name_adjunct
       ,p_projected_start_date         => g_per_rec.projected_start_date
       ,p_resume_exists                => g_per_rec.resume_exists
       ,p_resume_last_updated          => g_per_rec.resume_last_updated
       ,p_second_passport_exists       => g_per_rec.second_passport_exists
       ,p_student_status               => g_per_rec.student_status
       ,p_work_schedule                => g_per_rec.work_schedule
       ,p_suffix                       => g_per_rec.suffix
       ,p_receipt_of_death_cert_date   => g_per_rec.receipt_of_death_cert_date
       ,p_coord_ben_med_pln_no         => g_per_rec.coord_ben_med_pln_no
       ,p_coord_ben_no_cvg_flag        => g_per_rec.coord_ben_no_cvg_flag
       ,p_coord_ben_med_ext_er         => g_per_rec.coord_ben_med_ext_er
       ,p_coord_ben_med_pl_name        => g_per_rec.coord_ben_med_pl_name
       ,p_coord_ben_med_insr_crr_name  => g_per_rec.coord_ben_med_insr_crr_name
       ,p_coord_ben_med_insr_crr_ident => g_per_rec.coord_ben_med_insr_crr_ident
       ,p_coord_ben_med_cvg_strt_dt    => g_per_rec.coord_ben_med_cvg_strt_dt
       ,p_coord_ben_med_cvg_end_dt     => g_per_rec.coord_ben_med_cvg_end_dt
       ,p_uses_tobacco_flag            => g_per_rec.uses_tobacco_flag
       ,p_dpdnt_adoption_date          => g_per_rec.dpdnt_adoption_date
       ,p_dpdnt_vlntry_svce_flag       => g_per_rec.dpdnt_vlntry_svce_flag
       ,p_original_date_of_hire        => g_per_rec.original_date_of_hire
       ,p_town_of_birth                => g_per_rec.town_of_birth
       ,p_region_of_birth              => g_per_rec.region_of_birth
       ,p_country_of_birth             => g_per_rec.country_of_birth
       ,p_global_person_id             => g_per_rec.global_person_id
       ,p_party_id                     => g_per_rec.party_id
       ,p_correspondence_language      => g_per_rec.correspondence_language
       ,p_benefit_group                => g_per_rec.benefit_group_id
       ,p_person_user_key              => l_dp_crt_emp_rec.p_person_user_key
       ,p_assignment_user_key          => l_dp_crt_emp_rec.p_assignment_user_key
       ,p_user_person_type             => l_user_person_type
       ,p_language_code                => Userenv('lang')
       ,p_vendor_name                  => null
       );
    end if;

    -- Call if API_ID is 'Update_Person'
    if l_api_name = 'UPDATE_PERSON' then

       open  csr_get_update_per_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
       fetch csr_get_update_per_data into l_dp_upd_per_rec;
       close csr_get_update_per_data;

     Hrdpp_Update_Person.insert_batch_lines
     (p_batch_id                     => p_batch_id
     ,p_data_pump_batch_line_id      => l_dp_upd_per_rec.batch_line_id
     ,p_user_sequence                => l_dp_upd_per_rec.user_sequence
     ,p_link_value                   => p_data_pump_batch_line_id
     ,p_effective_date               => g_per_rec.start_date
     ,p_datetrack_update_mode        => l_dp_upd_per_rec.p_datetrack_update_mode
     ,p_party_id                     => g_per_rec.party_id
     ,p_employee_number              => g_per_rec.employee_number
     ,p_last_name                    => g_per_rec.last_name
     ,p_first_name                   => g_per_rec.first_name
     ,p_date_of_birth                => g_per_rec.date_of_birth
     ,p_marital_status               => g_per_rec.marital_status
     ,p_middle_names                 => g_per_rec.middle_names
     ,p_sex                          => g_per_rec.sex
     ,p_title                        => g_per_rec.title
     ,p_nationality                  => g_per_rec.nationality
     ,p_previous_last_name           => g_per_rec.previous_last_name
     ,p_known_as                     => g_per_rec.known_as
     ,p_email_address                => g_per_rec.email_address
     ,p_registered_disabled_flag     => g_per_rec.registered_disabled_flag
     ,p_date_employee_data_verified  => g_per_rec.date_employee_data_verified
     ,p_expense_check_send_to_addres => g_per_rec.expense_check_send_to_address
      -- Person DDF
     ,p_per_information_category     => g_per_rec.per_information_category
     ,p_per_information1             => g_per_rec.per_information1
     ,p_per_information2             => g_per_rec.per_information2
     ,p_per_information3             => g_per_rec.per_information3
     ,p_per_information4             => g_per_rec.per_information4
     ,p_per_information5             => g_per_rec.per_information5
     ,p_per_information6             => g_per_rec.per_information6
     ,p_per_information7             => g_per_rec.per_information7
     ,p_per_information8             => g_per_rec.per_information8
     ,p_per_information9             => g_per_rec.per_information9
     ,p_per_information10            => g_per_rec.per_information10
     ,p_per_information11            => g_per_rec.per_information11
     ,p_per_information12            => g_per_rec.per_information12
     ,p_per_information13            => g_per_rec.per_information13
     ,p_per_information14            => g_per_rec.per_information14
     ,p_per_information15            => g_per_rec.per_information15
     ,p_per_information16            => g_per_rec.per_information16
     ,p_per_information17            => g_per_rec.per_information17
     ,p_per_information18            => g_per_rec.per_information18
     ,p_per_information19            => g_per_rec.per_information19
     ,p_per_information20            => g_per_rec.per_information20
     ,p_per_information21            => g_per_rec.per_information21
     ,p_per_information22            => g_per_rec.per_information22
     ,p_per_information23            => g_per_rec.per_information23
     ,p_per_information24            => g_per_rec.per_information24
     ,p_per_information25            => g_per_rec.per_information25
     ,p_per_information26            => g_per_rec.per_information26
     ,p_per_information27            => g_per_rec.per_information27
     ,p_per_information28            => g_per_rec.per_information28
     ,p_per_information29            => g_per_rec.per_information29
     ,p_per_information30            => g_per_rec.per_information30
      -- Person DF
     ,p_attribute_category           => g_per_rec.attribute_category
     ,p_attribute1                   => g_per_rec.attribute1
     ,p_attribute2                   => g_per_rec.attribute2
     ,p_attribute3                   => g_per_rec.attribute3
     ,p_attribute4                   => g_per_rec.attribute4
     ,p_attribute5                   => g_per_rec.attribute5
     ,p_attribute6                   => g_per_rec.attribute6
     ,p_attribute7                   => g_per_rec.attribute7
     ,p_attribute8                   => g_per_rec.attribute8
     ,p_attribute9                   => g_per_rec.attribute9
     ,p_attribute10                  => g_per_rec.attribute10
     ,p_attribute11                  => g_per_rec.attribute11
     ,p_attribute12                  => g_per_rec.attribute12
     ,p_attribute13                  => g_per_rec.attribute13
     ,p_attribute14                  => g_per_rec.attribute14
     ,p_attribute15                  => g_per_rec.attribute15
     ,p_attribute16                  => g_per_rec.attribute16
     ,p_attribute17                  => g_per_rec.attribute17
     ,p_attribute18                  => g_per_rec.attribute18
     ,p_attribute19                  => g_per_rec.attribute19
     ,p_attribute20                  => g_per_rec.attribute20
     ,p_attribute21                  => g_per_rec.attribute21
     ,p_attribute22                  => g_per_rec.attribute22
     ,p_attribute23                  => g_per_rec.attribute23
     ,p_attribute24                  => g_per_rec.attribute24
     ,p_attribute25                  => g_per_rec.attribute25
     ,p_attribute26                  => g_per_rec.attribute26
     ,p_attribute27                  => g_per_rec.attribute27
     ,p_attribute28                  => g_per_rec.attribute28
     ,p_attribute29                  => g_per_rec.attribute29
     ,p_attribute30                  => g_per_rec.attribute30
     ,p_date_of_death                => g_per_rec.date_of_death
     ,p_background_check_status      => g_per_rec.background_check_status
     ,p_background_date_check        => g_per_rec.background_date_check
     ,p_blood_type                   => g_per_rec.blood_type
     ,p_correspondence_language      => g_per_rec.correspondence_language
     ,p_fte_capacity                 => g_per_rec.fte_capacity
     ,p_hold_applicant_date_until    => g_per_rec.hold_applicant_date_until
     ,p_honors                       => g_per_rec.honors
     ,p_internal_location            => g_per_rec.internal_location
     ,p_last_medical_test_by         => g_per_rec.last_medical_test_by
     ,p_last_medical_test_date       => g_per_rec.last_medical_test_date
     ,p_mailstop                     => g_per_rec.mailstop
     ,p_office_number                => g_per_rec.office_number
     ,p_on_military_service          => g_per_rec.on_military_service
     ,p_pre_name_adjunct             => g_per_rec.pre_name_adjunct
     ,p_projected_start_date         => g_per_rec.projected_start_date
     ,p_rehire_authorizor            => g_per_rec.rehire_authorizor
     ,p_rehire_recommendation        => g_per_rec.rehire_recommendation
     ,p_resume_exists                => g_per_rec.resume_exists
     ,p_resume_last_updated          => g_per_rec.resume_last_updated
     ,p_second_passport_exists       => g_per_rec.second_passport_exists
     ,p_student_status               => g_per_rec.student_status
     ,p_work_schedule                => g_per_rec.work_schedule
     ,p_rehire_reason                => g_per_rec.rehire_reason
     ,p_suffix                       => g_per_rec.suffix
     ,p_benefit_group                => g_per_rec.benefit_group_id
     ,p_receipt_of_death_cert_date   => g_per_rec.receipt_of_death_cert_date
     ,p_coord_ben_med_pln_no         => g_per_rec.coord_ben_med_pln_no
     ,p_coord_ben_no_cvg_flag        => g_per_rec.coord_ben_no_cvg_flag
     ,p_coord_ben_med_ext_er         => g_per_rec.coord_ben_med_ext_er
     ,p_coord_ben_med_pl_name        => g_per_rec.coord_ben_med_pl_name
     ,p_coord_ben_med_insr_crr_name  => g_per_rec.coord_ben_med_insr_crr_name
     ,p_coord_ben_med_insr_crr_ident => g_per_rec.coord_ben_med_insr_crr_ident
     ,p_coord_ben_med_cvg_strt_dt    => g_per_rec.coord_ben_med_cvg_strt_dt
     ,p_coord_ben_med_cvg_end_dt     => g_per_rec.coord_ben_med_cvg_end_dt
     ,p_uses_tobacco_flag            => g_per_rec.uses_tobacco_flag
     ,p_dpdnt_adoption_date          => g_per_rec.dpdnt_adoption_date
     ,p_dpdnt_vlntry_svce_flag       => g_per_rec.dpdnt_vlntry_svce_flag
     ,p_original_date_of_hire        => g_per_rec.original_date_of_hire
     ,p_adjusted_svc_date            => p_adjusted_svc_date
     ,p_town_of_birth                => g_per_rec.town_of_birth
     ,p_region_of_birth              => g_per_rec.region_of_birth
     ,p_country_of_birth             => g_per_rec.country_of_birth
     ,p_global_person_id             => g_per_rec.global_person_id
     ,p_person_user_key              => l_dp_upd_per_rec.p_person_user_key
     ,p_user_person_type             => l_dp_upd_per_rec.p_user_person_type
     ,p_language_code                => Userenv('lang')
     ,p_vendor_name                  => null
     );

    end if;

    -- Call if API_ID is 'Update_Address'
    if l_api_name = 'UPDATE_PERSON_ADDRESS' then
       open  csr_get_update_add_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
       fetch csr_get_update_add_data into l_dp_upd_add_rec;
       close csr_get_update_add_data;

-- Code has been commented as the Logic for Address has changed, hence we no
-- longer require the below logic, will be removed later

--       -- Check if while updating address we end dated the address and then
--       -- created a new address or simply updated the address. To find that
--       -- out, we will check if for the said batch_id and link_value
--       -- we have both Update and Create Address. If that is the case then
--       -- that implies that address was end dated and then new one was created
--       -- else it was simply updated.
--       -- Incase address was updated to end date then, we will use
--       -- "l_dp_upd_add_rec" else we will use "g_add_rec"

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
          ,p_effective_date          => g_per_rec.start_date
          ,p_validate_county         => false
          ,p_primary_flag            => g_add_rec.primary_flag
          ,p_date_from               => g_add_rec.date_from
          ,p_date_to                 => g_add_rec.date_to
          ,p_address_type            => g_add_rec.address_type
          --$
          ,p_comments                => g_add_rec.comments
          ,p_address_line1           => g_add_rec.address_line1
          ,p_address_line2           => g_add_rec.address_line2
          ,p_address_line3           => g_add_rec.address_line3
          ,p_town_or_city            => g_add_rec.town_or_city
          ,p_region_1                => g_add_rec.region_1
          ,p_region_2                => g_add_rec.region_2
          ,p_region_3                => g_add_rec.region_3
          ,p_postal_code             => g_add_rec.postal_code
          ,p_telephone_number_1      => g_add_rec.telephone_number_1
          ,p_telephone_number_2      => g_add_rec.telephone_number_2
          ,p_telephone_number_3      => g_add_rec.telephone_number_3
          ,p_addr_attribute_category => g_add_rec.addr_attribute_category
          ,p_addr_attribute1         => g_add_rec.addr_attribute1
          ,p_addr_attribute2         => g_add_rec.addr_attribute2
          ,p_addr_attribute3         => g_add_rec.addr_attribute3
          ,p_addr_attribute4         => g_add_rec.addr_attribute4
          ,p_addr_attribute5         => g_add_rec.addr_attribute5
          ,p_addr_attribute6         => g_add_rec.addr_attribute6
          ,p_addr_attribute7         => g_add_rec.addr_attribute7
          ,p_addr_attribute8         => g_add_rec.addr_attribute8
          ,p_addr_attribute9         => g_add_rec.addr_attribute9
          ,p_addr_attribute10        => g_add_rec.addr_attribute10
          ,p_addr_attribute11        => g_add_rec.addr_attribute11
          ,p_addr_attribute12        => g_add_rec.addr_attribute12
          ,p_addr_attribute13        => g_add_rec.addr_attribute13
          ,p_addr_attribute14        => g_add_rec.addr_attribute14
          ,p_addr_attribute15        => g_add_rec.addr_attribute15
          ,p_addr_attribute16        => g_add_rec.addr_attribute16
          ,p_addr_attribute17        => g_add_rec.addr_attribute17
          ,p_addr_attribute18        => g_add_rec.addr_attribute18
          ,p_addr_attribute19        => g_add_rec.addr_attribute19
          ,p_addr_attribute20        => g_add_rec.addr_attribute20
          ,p_add_information13       => g_add_rec.add_information13
          ,p_add_information14       => g_add_rec.add_information14
          ,p_add_information15       => g_add_rec.add_information15
          ,p_add_information16       => g_add_rec.add_information16
          ,p_add_information17       => g_add_rec.add_information17
          ,p_add_information18       => g_add_rec.add_information18
          ,p_add_information19       => g_add_rec.add_information19
          ,p_add_information20       => g_add_rec.add_information20
          ,p_party_id                => g_add_rec.party_id
          ,p_address_user_key        => l_dp_upd_add_rec.p_address_user_key
          ,p_country                 => g_add_rec.country
          );
--       END IF;
    end if;

    -- Call if API_ID is 'Create_Address'
    if l_api_name = 'CREATE_PERSON_ADDRESS' then

       open  csr_get_create_add_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
       fetch csr_get_create_add_data into l_dp_crt_add_rec;
       close csr_get_create_add_data;

       -- Convert String value of p_pradd_ovlapval_override to Boolean
       if l_dp_crt_add_rec.p_pradd_ovlapval_override = 'FALSE' then
          l_pradd_ovlapval_override := false;
       else
          l_pradd_ovlapval_override := false;
       end if;

       Hrdpp_Create_Person_Address.Insert_Batch_Lines
       (p_batch_id                       => p_batch_id
       --l_dp_batch_line_id_cr_add
       ,p_data_pump_batch_line_id        => l_dp_crt_add_rec.batch_line_id
       ,p_user_sequence                  => l_dp_crt_add_rec.user_sequence
       ,p_link_value                     => p_data_pump_batch_line_id
       ,p_effective_date                 => g_per_rec.start_date
       ,p_pradd_ovlapval_override        => l_pradd_ovlapval_override
       ,p_validate_county                => false
       ,p_primary_flag                   => g_add_rec.primary_flag
       ,p_style                          => g_add_rec.style
       ,p_date_from                      => g_add_rec.date_from
       ,p_date_to                        => g_add_rec.date_to
       ,p_address_type                   => g_add_rec.address_type
       --$
       ,p_comments                       => g_add_rec.comments
       ,p_address_line1                  => g_add_rec.address_line1
       ,p_address_line2                  => g_add_rec.address_line2
       ,p_address_line3                  => g_add_rec.address_line3
       ,p_town_or_city                   => g_add_rec.town_or_city
       ,p_region_1                       => g_add_rec.region_1
       ,p_region_2                       => g_add_rec.region_2
       ,p_region_3                       => g_add_rec.region_3
       ,p_postal_code                    => g_add_rec.postal_code
       ,p_telephone_number_1             => g_add_rec.telephone_number_1
       ,p_telephone_number_2             => g_add_rec.telephone_number_2
       ,p_telephone_number_3             => g_add_rec.telephone_number_3
       ,p_addr_attribute_category        => g_add_rec.addr_attribute_category
       ,p_addr_attribute1                => g_add_rec.addr_attribute1
       ,p_addr_attribute2                => g_add_rec.addr_attribute2
       ,p_addr_attribute3                => g_add_rec.addr_attribute3
       ,p_addr_attribute4                => g_add_rec.addr_attribute4
       ,p_addr_attribute5                => g_add_rec.addr_attribute5
       ,p_addr_attribute6                => g_add_rec.addr_attribute6
       ,p_addr_attribute7                => g_add_rec.addr_attribute7
       ,p_addr_attribute8                => g_add_rec.addr_attribute8
       ,p_addr_attribute9                => g_add_rec.addr_attribute9
       ,p_addr_attribute10               => g_add_rec.addr_attribute10
       ,p_addr_attribute11               => g_add_rec.addr_attribute11
       ,p_addr_attribute12               => g_add_rec.addr_attribute12
       ,p_addr_attribute13               => g_add_rec.addr_attribute13
       ,p_addr_attribute14               => g_add_rec.addr_attribute14
       ,p_addr_attribute15               => g_add_rec.addr_attribute15
       ,p_addr_attribute16               => g_add_rec.addr_attribute16
       ,p_addr_attribute17               => g_add_rec.addr_attribute17
       ,p_addr_attribute18               => g_add_rec.addr_attribute18
       ,p_addr_attribute19               => g_add_rec.addr_attribute19
       ,p_addr_attribute20               => g_add_rec.addr_attribute20
       ,p_add_information13              => g_add_rec.add_information13
       ,p_add_information14              => g_add_rec.add_information14
       ,p_add_information15              => g_add_rec.add_information15
       ,p_add_information16              => g_add_rec.add_information16
       ,p_add_information17              => g_add_rec.add_information17
       ,p_add_information18              => g_add_rec.add_information18
       ,p_add_information19              => g_add_rec.add_information19
       ,p_add_information20              => g_add_rec.add_information20
       ,p_party_id                       => g_add_rec.party_id
       ,p_address_user_key               => l_dp_crt_add_rec.p_address_user_key
       ,p_person_user_key                => l_dp_crt_add_rec.p_person_user_key
       ,p_country                        => g_add_rec.country
       );

    end if;

    -- Call if API_ID is 'Update_Emp_Asg'
    if l_api_name = 'UPDATE_EMP_ASG' then

       open  csr_get_upd_asg_data(c_batch_id   => p_batch_id
                                 ,c_link_value => p_data_pump_batch_line_id
                                 );
       fetch csr_get_upd_asg_data into l_dp_upd_asg_rec;
       close csr_get_upd_asg_data;

       Hrdpp_Update_Emp_Asg.Insert_Batch_Lines
       (p_batch_id                      => p_batch_id
       -- l_dp_batch_line_id_asg
       ,p_data_pump_batch_line_id       => l_dp_upd_asg_rec.batch_line_id
       ,p_user_sequence                 => l_dp_upd_asg_rec.user_sequence
       ,p_link_value                    => p_data_pump_batch_line_id
       ,p_effective_date                => g_per_rec.start_date
       ,p_datetrack_update_mode         => l_dp_upd_asg_rec.p_datetrack_update_mode
       ,p_change_reason                 => g_asg_rec.change_reason
       ,p_date_probation_end            => g_asg_rec.date_probation_end
       ,p_frequency                     => g_asg_rec.frequency
       ,p_internal_address_line         => g_asg_rec.internal_address_line
       ,p_manager_flag                  => g_asg_rec.manager_flag
       ,p_normal_hours                  => g_asg_rec.normal_hours
       ,p_perf_review_period            => g_asg_rec.perf_review_period
       ,p_perf_review_period_frequency  => g_asg_rec.perf_review_period_frequency
       ,p_probation_period              => g_asg_rec.probation_period
       ,p_probation_unit                => g_asg_rec.probation_unit
       ,p_sal_review_period             => g_asg_rec.sal_review_period
       ,p_sal_review_period_frequency   => g_asg_rec.sal_review_period_frequency
       ,p_source_type                   => g_asg_rec.source_type
       ,p_time_normal_finish            => g_asg_rec.time_normal_finish
       ,p_time_normal_start             => g_asg_rec.time_normal_start
       ,p_bargaining_unit_code          => g_asg_rec.bargaining_unit_code
       ,p_labour_union_member_flag      => g_asg_rec.labour_union_member_flag
       ,p_hourly_salaried_code          => g_asg_rec.hourly_salaried_code
       ,p_ass_attribute_category        => g_asg_rec.ass_attribute_category
       ,p_ass_attribute1                => g_asg_rec.ass_attribute1
       ,p_ass_attribute2                => g_asg_rec.ass_attribute2
       ,p_ass_attribute3                => g_asg_rec.ass_attribute3
       ,p_ass_attribute4                => g_asg_rec.ass_attribute4
       ,p_ass_attribute5                => g_asg_rec.ass_attribute5
       ,p_ass_attribute6                => g_asg_rec.ass_attribute6
       ,p_ass_attribute7                => g_asg_rec.ass_attribute7
       ,p_ass_attribute8                => g_asg_rec.ass_attribute8
       ,p_ass_attribute9                => g_asg_rec.ass_attribute9
       ,p_ass_attribute10               => g_asg_rec.ass_attribute10
       ,p_ass_attribute11               => g_asg_rec.ass_attribute11
       ,p_ass_attribute12               => g_asg_rec.ass_attribute12
       ,p_ass_attribute13               => g_asg_rec.ass_attribute13
       ,p_ass_attribute14               => g_asg_rec.ass_attribute14
       ,p_ass_attribute15               => g_asg_rec.ass_attribute15
       ,p_ass_attribute16               => g_asg_rec.ass_attribute16
       ,p_ass_attribute17               => g_asg_rec.ass_attribute17
       ,p_ass_attribute18               => g_asg_rec.ass_attribute18
       ,p_ass_attribute19               => g_asg_rec.ass_attribute19
       ,p_ass_attribute20               => g_asg_rec.ass_attribute20
       ,p_ass_attribute21               => g_asg_rec.ass_attribute21
       ,p_ass_attribute22               => g_asg_rec.ass_attribute22
       ,p_ass_attribute23               => g_asg_rec.ass_attribute23
       ,p_ass_attribute24               => g_asg_rec.ass_attribute24
       ,p_ass_attribute25               => g_asg_rec.ass_attribute25
       ,p_ass_attribute26               => g_asg_rec.ass_attribute26
       ,p_ass_attribute27               => g_asg_rec.ass_attribute27
       ,p_ass_attribute28               => g_asg_rec.ass_attribute28
       ,p_ass_attribute29               => g_asg_rec.ass_attribute29
       ,p_ass_attribute30               => g_asg_rec.ass_attribute30
       ,p_segment1                      => g_scl_rec.segment1
       ,p_segment2                      => g_scl_rec.segment2
       ,p_segment3                      => g_scl_rec.segment3
       ,p_segment4                      => g_scl_rec.segment4
       ,p_segment5                      => g_scl_rec.segment5
       ,p_segment6                      => g_scl_rec.segment6
       ,p_segment7                      => g_scl_rec.segment7
       ,p_segment8                      => g_scl_rec.segment8
       ,p_segment9                      => g_scl_rec.segment9
       ,p_cagr_grade_def_id             => null
       ,p_assignment_user_key           => l_dp_upd_asg_rec.p_assignment_user_key
       ,p_con_seg_user_name             => null
       );

    end if;

    -- Call if API_ID is 'Update_Emp_Asg_Criteria'
    if l_api_name = 'UPDATE_EMP_ASG_CRITERIA' then

       Get_WrkStrs_Names;
      -- Cursor to get the exisiting Data Pump Interface Table Va;ues for
      -- Update Emp Asg Criteria
      open  csr_get_upd_asg_crt_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
      fetch csr_get_upd_asg_crt_data into l_dp_upd_asg_crt_rec;
      close csr_get_upd_asg_crt_data;

      Hrdpp_Update_Emp_Asg_Criteria.Insert_Batch_Lines
      (p_batch_id                => p_batch_id
      --l_dp_batch_line_id_asg_cri
      ,p_data_pump_batch_line_id => l_dp_upd_asg_crt_rec.batch_line_id
      ,p_user_sequence           => l_dp_upd_asg_crt_rec.user_sequence
      ,p_link_value              => p_data_pump_batch_line_id
      ,p_effective_date          => g_per_rec.start_date
      ,p_datetrack_update_mode   => l_dp_upd_asg_crt_rec.p_datetrack_update_mode
      ,p_segment1                => g_grp_rec.segment1
      ,p_segment2                => g_grp_rec.segment2
      ,p_segment3                => g_grp_rec.segment3
      ,p_segment4                => g_grp_rec.segment4
      ,p_segment5                => g_grp_rec.segment5
      ,p_segment6                => g_grp_rec.segment6
      ,p_segment7                => g_grp_rec.segment7
      ,p_segment8                => g_grp_rec.segment8
      ,p_segment9                => g_grp_rec.segment9
      ,p_segment10               => g_grp_rec.segment10
      ,p_segment11               => g_grp_rec.segment11
      ,p_segment12               => g_grp_rec.segment12
      ,p_segment13               => g_grp_rec.segment13
      ,p_segment14               => g_grp_rec.segment14
      ,p_segment15               => g_grp_rec.segment15
      ,p_segment16               => g_grp_rec.segment16
      ,p_segment17               => g_grp_rec.segment17
      ,p_segment18               => g_grp_rec.segment18
      ,p_segment19               => g_grp_rec.segment19
      ,p_segment20               => g_grp_rec.segment20
      ,p_segment21               => g_grp_rec.segment21
      ,p_segment22               => g_grp_rec.segment22
      ,p_segment23               => g_grp_rec.segment23
      ,p_segment24               => g_grp_rec.segment24
      ,p_segment25               => g_grp_rec.segment25
      ,p_segment26               => g_grp_rec.segment26
      ,p_segment27               => g_grp_rec.segment27
      ,p_segment28               => g_grp_rec.segment28
      ,p_segment29               => g_grp_rec.segment29
      ,p_segment30               => g_grp_rec.segment30
      ,p_special_ceiling_step_id => null
      ,p_people_group_id         => null
      ,p_assignment_user_key     => l_dp_upd_asg_crt_rec.p_assignment_user_key
      ,p_grade_name              => g_wstr_names.grade_name
      ,p_position_name           => g_wstr_names.position_name
      ,p_job_name                => g_wstr_names.job_name
      ,p_payroll_name            => g_wstr_names.payroll_name
      ,p_location_code           => g_wstr_names.location_code
      ,p_organization_name       => g_wstr_names.organization_name
      ,p_pay_basis_name          => g_wstr_names.pay_basis_name
      ,p_language_code           => Userenv('LANG')
      ,p_con_seg_user_name       => null
      );

    end if;

    -- Call if API_ID is 'Create_Contact'
    if l_api_name = 'CREATE_CONTACT' then

       open  csr_get_create_cnt_data(c_batch_id   => p_batch_id
                                    ,c_link_value => p_data_pump_batch_line_id
                                    );
       fetch csr_get_create_cnt_data into l_dp_crt_cnt_rec;
       close csr_get_create_cnt_data;

       Hrdpp_Create_Contact.insert_batch_lines
       (p_batch_id                => p_batch_id
       ,p_data_pump_batch_line_id => l_dp_crt_cnt_rec.batch_line_id
       ,p_user_sequence           => l_dp_crt_cnt_rec.user_sequence
       ,p_link_value              => p_data_pump_batch_line_id
       ,p_start_date              => g_per_rec.start_date
       ,p_contact_type            => g_cnt_rec.contact_type
       ,p_primary_contact_flag    => g_cnt_rec.primary_contact_flag
       ,p_personal_flag           => g_cnt_rec.personal_flag
       ,p_last_name               => p_contact_name
       ,p_per_person_user_key     => l_dp_crt_cnt_rec.p_per_person_user_key
       ,p_person_user_key         => l_dp_crt_cnt_rec.p_person_user_key
       ,p_language_code           => userenv('LANG')
       );

    end if;

    -- Call if API_ID is 'Update_Contact'
    if l_api_name = 'UPDATE_CONTACT_RELATIONSHIP' then

       open  csr_get_update_cnt_data(c_batch_id   => p_batch_id
                                     ,c_link_value => p_data_pump_batch_line_id
                                     );
       fetch csr_get_update_cnt_data into l_dp_upd_cnt_rec;
       close csr_get_update_cnt_data;

       Hrdpp_Update_Contact_Relations.insert_batch_lines
       (p_batch_id                => p_batch_id
       ,p_data_pump_batch_line_id => l_dp_upd_cnt_rec.batch_line_id
       ,p_user_sequence           => l_dp_crt_cnt_rec.user_sequence
       ,p_link_value              => p_data_pump_batch_line_id
       ,p_effective_date          => g_per_rec.start_date
       ,p_contact_type            => g_cnt_rec.contact_type
       ,p_primary_contact_flag    => g_cnt_rec.primary_contact_flag
       ,p_personal_flag           => g_cnt_rec.personal_flag
       ,p_object_version_number   => l_dp_upd_cnt_rec.p_object_version_number
       ,p_contact_user_key        => l_dp_upd_cnt_rec.p_contact_user_key
       ,p_contactee_user_key      => l_dp_upd_cnt_rec.p_contactee_user_key
       );

    end if;

  end loop;

  close csr_get_api_names;

  hr_utility.set_location('Leaving: ' || l_proc_name, 30);

exception
  when Others then
    if csr_get_api_names%isopen then
      close csr_get_api_names;
    end if;
  hr_utility.set_location('Leaving: ' || l_proc_name, 40);
  raise;

end HR_DataPumpErr;

-- =============================================================================
-- ~ Create_Person_Contact:
-- =============================================================================
/*
procedure Create_Person_Contact
         (p_effective_date   in date
         ,p_contact_name     in varchar2
         ,p_legislation_code in varchar2
         ,p_crt_cntct_out    out NOCOPY t_CreateContact_Api
          ) as

  l_proc_name  constant    varchar2(150):= g_pkg ||'Create_Person_Contact';

begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

   Hr_Contact_Rel_Api.create_contact
   (p_start_date                => p_effective_date
   ,p_business_group_id         => g_cnt_rec.business_group_id
   ,p_person_id                 => g_cnt_rec.person_id
   ,p_contact_type              => g_cnt_rec.contact_type
   ,p_last_name                 => p_contact_name
   ,p_primary_contact_flag      => g_cnt_rec.primary_contact_flag
   ,p_personal_flag             => g_cnt_rec.personal_flag
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

end Create_Person_Contact;
*/
-- =============================================================================
-- ~ Update_Person_Contact:
-- =============================================================================
procedure Update_Person_Contact
         (p_effective_date   in date
         ,p_contact_name     in varchar2
         ,p_legislation_code in varchar2
         ,p_crt_cntct_out    out NOCOPY t_CreateContact_Api
         ) as

  l_cont_object_version_num  number;
  l_proc_name  constant      varchar2(150):= g_pkg ||'Update_Person_Contact';
begin
  hr_utility.set_location('Entering: ' || l_proc_name, 10);

  open  csr_ck_cont_xsts(c_person_id         => g_per_rec.person_id
                        ,c_business_group_id => g_add_rec.business_group_id
                        ,c_effective_date    => g_per_rec.start_date);
  fetch csr_ck_cont_xsts into l_cont_object_version_num;

  -- Update the Contact only if Contact exists else create Contact
  if csr_ck_cont_xsts%found then

     -- Right now we are only creating the contact as decision to if we should
     -- actually be updating the Contact or every time be creating a new
     -- contact, irrespective of the fact if it is already existing duplicate
     -- person, hasn't been made
     Hr_Contact_Rel_Api.create_contact
     (p_start_date                => p_effective_date
     ,p_business_group_id         => g_cnt_rec.business_group_id
     ,p_person_id                 => g_cnt_rec.person_id
     ,p_contact_type              => g_cnt_rec.contact_type
     ,p_last_name                 => p_contact_name
     ,p_primary_contact_flag      => g_cnt_rec.primary_contact_flag
     ,p_personal_flag             => g_cnt_rec.personal_flag
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

  else

     Hr_Contact_Rel_Api.create_contact
     (p_start_date                => p_effective_date
     ,p_business_group_id         => g_cnt_rec.business_group_id
     ,p_person_id                 => g_cnt_rec.person_id
     ,p_contact_type              => g_cnt_rec.contact_type
     ,p_last_name                 => p_contact_name
     ,p_primary_contact_flag      => g_cnt_rec.primary_contact_flag
     ,p_personal_flag             => g_cnt_rec.personal_flag
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

  end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 20);

end Update_Person_Contact;

-- =============================================================================
-- ~ Create_DataPump_BatchHeader:
-- =============================================================================
procedure Create_DataPump_BatchHeader
         (p_reference            in varchar2
         ,p_business_group_id    in number
         ,p_batch_process_name   in out nocopy varchar2
         ,p_batch_process_id     out nocopy number) as
  --
  -- Cursor to get the business group name
  --
  cursor csr_get_bg_name (c_bg_grp_id in number) is
  select pbg.name
    from per_business_groups pbg
   where pbg.business_group_id = c_bg_grp_id;

  l_bg_name             per_business_groups.name%type;
  l_proc_name  constant varchar2(170):= g_pkg ||'Create_DataPump_BatchHeader';
  l_reference           varchar2(80);

begin
   hr_utility.set_location('Entering: ' || l_proc_name, 10);
   select hr_pump_batch_headers_s.nextval
     into p_batch_process_id
     from dual;
   --
   -- If batch name is null i.e. user did'nt enter a name, so create one.
   --
   if p_batch_process_name is null then
      p_batch_process_name := 'RIW Web-ADI Batch: ' || p_batch_process_id;
   else
      p_batch_process_name := p_batch_process_name || p_batch_process_id;
   end if;
   --
   -- Assign a default reference
   --
   if trim(p_reference) is null then
      l_reference := 'PQP_RIW_PERASGADD';
   else
      l_reference := p_reference;
   end if;
   --
   -- Get the business group name
   --
   if p_business_group_id is null then
      open csr_get_bg_name(Fnd_Profile.Value('PER_BUSINESS_GROUP_ID'));
     fetch csr_get_bg_name into l_bg_name;
     close csr_get_bg_name;
   else
      open csr_get_bg_name(p_business_group_id);
     fetch csr_get_bg_name into l_bg_name;
     close csr_get_bg_name;
   end if;
   --
   -- Create a row into Data Pump batch header table
   --
   insert into hr_pump_batch_headers
   (batch_id
   ,batch_name
   ,batch_status
   ,business_group_name
   ,reference)
   values
   (p_batch_process_id
   ,p_batch_process_name
   ,'U'
   ,l_bg_name
   --,nvl(l_bg_name,'PQPD115 Business Group') -- remove the NVL()
   ,l_reference);

   hr_utility.set_location('Leaving: ' || l_proc_name, 80);

end Create_DataPump_BatchHeader;
-- =============================================================================
-- Update_Assignment:
-- =============================================================================
procedure Update_Assignment
         (p_effective_date    in date
         ,p_business_group_id in number
         ,p_person_id         in number
         ) as

  --Added by DBANSAL to get the person type
   cursor csr_type (c_person_type_id in number) is
  select *
    from per_person_types
   where person_type_id = c_person_type_id
     and business_group_id = p_business_group_id;

  --$ Cursor to get APL assg details (no assg number)
   cursor csr_apl_asg (c_effective_date in date
                 ,c_person_id         in number
                 ,c_business_group_id in number)is
  select *
    from per_all_assignments_f paf
   where paf.person_id = c_person_id
     and paf.business_group_id = c_business_group_id
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;


  cursor csr_asg (c_assignment_id in varchar2
                 ,c_person_id         in number
                 ,c_business_group_id in number
                 ,c_effective_date    in date
                 ) is
  select *
    from per_all_assignments_f paf
   where paf.person_id = c_person_id
     and paf.assignment_id = c_assignment_id
     and paf.business_group_id = c_business_group_id
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;

  cursor csr_asg_num (c_assignment_number in varchar2
                 ,c_person_id         in number
                 ,c_business_group_id in number
                 ,c_effective_date    in date
                 ) is
  select *
    from per_all_assignments_f paf
   where paf.person_id = c_person_id
     and paf.assignment_number = c_assignment_number
     and paf.business_group_id = c_business_group_id
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;

  l_asg_rec  csr_asg%rowtype;
  l_AsgUpdCrit_Api t_AsgUpdCrit_Api;
  l_proc_name    constant varchar2(150) := g_pkg||'Update_Assignment';

  -- Added by dbansal
  l_hrEmpApi_out          t_hrEmpApi;
  l_UpdEmpAsg_out          t_Upd_Emp_Asg_Api;
  l_asg_rec1               per_all_assignments_f%rowtype;
 l_grp_rec                pay_people_groups%rowtype;
  l_scl_rec                hr_soft_coding_keyflex%rowtype;
  l_pty_rec     csr_type%rowtype;
  l_apl_asg_rec             per_all_assignments_f%rowtype;
  l_appl_override_warning         boolean;
  l_concat_segments        varchar2(2000);
  l_secondary              boolean;
begin
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  --$ check already made before making call to this procedure from
  --the procedure Direct_API_Call. Also as for "APPLICANT" assignment_number
  -- will always be null hence should not be included in the check condition.
  -- Hence,commenting it out
  /*
  if g_asg_rec.organization_id is null or
     g_asg_rec.assignment_status_type_id is null or
     g_asg_rec.assignment_number is null then
     Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
     return;
  end if;
  */

  if g_asg_rec.assignment_number is null then
      if g_migration_flag = 'Y' then
          hr_utility.set_location('Inside else ', 7);
          hr_utility.set_location('The assignment id is : '||g_asg_rec.assignment_id, 8);
  	      open csr_apl_asg (c_person_id         => p_person_id
              ,c_business_group_id => p_business_group_id
              ,c_effective_date    => p_effective_date
              );
         fetch csr_apl_asg into l_asg_rec;
         if csr_apl_asg%notfound then
         close csr_apl_asg;
         l_secondary := true;
         else
         close csr_apl_asg;
         l_secondary := false;
         end if;
      else
          hr_utility.set_location('Inside else ', 7);
          hr_utility.set_location('The assignment id is : '||g_asg_rec.assignment_id, 8);
  	      open csr_asg (c_assignment_id => g_asg_rec.assignment_id
              ,c_person_id         => p_person_id
              ,c_business_group_id => p_business_group_id
              ,c_effective_date    => p_effective_date
              );
         fetch csr_asg into l_asg_rec;
         if csr_asg%notfound then
         close csr_asg;
         l_secondary := true;
         else
         close csr_asg;
         l_secondary := false;
         end if;
      end if;
  else
  	  open csr_asg_num (c_assignment_number => g_asg_rec.assignment_number
               ,c_person_id         => p_person_id
               ,c_business_group_id => p_business_group_id
               ,c_effective_date    => p_effective_date
               );
  	  fetch csr_asg_num into l_asg_rec;
      if csr_asg_num%notfound then
          close csr_asg_num;
          l_secondary := true;
      else
          close csr_asg_num;
          l_secondary := false;
      end if;
  end if;

 /* if g_migration_flag = 'Y' OR (g_migration_flag = 'N' AND g_asg_rec.assignment_id is null) then
  	open csr_asg_num (c_assignment_number => g_asg_rec.assignment_number
               ,c_person_id         => p_person_id
               ,c_business_group_id => p_business_group_id
               ,c_effective_date    => p_effective_date
               );
  	fetch csr_asg_num into l_asg_rec;
    if csr_asg_num%notfound then
        close csr_asg_num;
        l_secondary := true;
    else
        close csr_asg_num;
        l_secondary := false;
    end if;
  else
    hr_utility.set_location('Inside else ', 7);
    hr_utility.set_location('The assignment id is : '||g_asg_rec.assignment_id, 8);
  	open csr_asg (c_assignment_id => g_asg_rec.assignment_id
               ,c_person_id         => p_person_id
               ,c_business_group_id => p_business_group_id
               ,c_effective_date    => p_effective_date
               );
  fetch csr_asg into l_asg_rec;
    if csr_asg%notfound then
        close csr_asg;
        l_secondary := true;
    else
        close csr_asg;
        l_secondary := false;
    end if;
  end if;*/



        /*hr_utility.trace('CURSOR : select * from per_all_assignments_f paf
   where paf.person_id =' ||p_person_id || 'and paf.assignment_number = ' ||
    g_asg_rec.assignment_number || 'and paf.business_group_id = ' || p_business_group_id
    || 'and ' || sysdate|| ' between paf.effective_start_date
                              and paf.effective_end_date' );*/


  if  l_secondary then

   -- If the assignment (assignment number specified) is not there
   -- for that person then create a secondary assignment in case of emp and cwk
   g_sec_asg_flag := 1; -- set secondary assignment flag to 1
   l_asg_rec1 := Get_AsgRecord_Values(g_interface_code);
   l_grp_rec := Get_GrpRecord_Values(g_interface_code);
   l_scl_rec := Get_ScflxRecord_Values(g_interface_code);

   open csr_type(g_per_rec.person_type_id);
   fetch csr_type into l_pty_rec;
   close csr_type;

   if l_pty_rec.system_person_type = 'EMP' then
    if (g_crt_upd = 'C') then -- Should have Create privileges to create sec assignment
	Hr_Assignment_Api.create_secondary_emp_asg
	(p_validate                     => false -- in     boolean  default false
	,p_effective_date               => p_effective_date -- in     date
	,p_person_id                    => p_person_id --  in     number
	,p_organization_id              => g_asg_rec.organization_id   --  in     number
	,p_assignment_number            => g_asg_rec.assignment_number     --   in out nocopy varchar2
	,p_grade_id                     => l_asg_rec1.grade_id
	,p_position_id                  => l_asg_rec1.position_id
	,p_job_id                       => l_asg_rec1.job_id
	--      ,p_assignment_status_type_id    in     number   default null
	,p_payroll_id                   => l_asg_rec1.payroll_id
	,p_location_id                  => l_asg_rec1.location_id
	,p_supervisor_id                => l_asg_rec1.supervisor_id      -- in     number   default null
	,p_pay_basis_id                 => l_asg_rec1.pay_basis_id     --  in     number   default null
	,p_change_reason                => l_asg_rec1.change_reason        --  in     varchar2 default null
	,p_comments                     => g_asg_comments
	,p_date_probation_end           => l_asg_rec1.date_probation_end    --   in     date     default null
	,p_default_code_comb_id         => l_asg_rec1.default_code_comb_id   --   in     number   default null
	,p_employment_category          => l_asg_rec1.employment_category --       in     varchar2 default null
	,p_frequency                    => l_asg_rec1.frequency --       in     varchar2 default null
	,p_internal_address_line        => l_asg_rec1.internal_address_line
	,p_manager_flag                 => l_asg_rec1.manager_flag
	,p_normal_hours                 => l_asg_rec1.normal_hours
	,p_perf_review_period           => l_asg_rec1.perf_review_period
	,p_perf_review_period_frequency => l_asg_rec1.perf_review_period_frequency
	,p_probation_period             => l_asg_rec1.probation_period
	,p_probation_unit               => l_asg_rec1.probation_unit
	,p_sal_review_period            => l_asg_rec1.sal_review_period
	,p_sal_review_period_frequency  => l_asg_rec1.sal_review_period_frequency
	,p_set_of_books_id              => l_asg_rec1.set_of_books_id
	,p_source_type                  => l_asg_rec1.source_type
	,p_time_normal_finish           => l_asg_rec1.time_normal_finish
	,p_time_normal_start            => l_asg_rec1.time_normal_start
	,p_bargaining_unit_code         => l_asg_rec1.bargaining_unit_code
	,p_labour_union_member_flag     => l_asg_rec1.labour_union_member_flag
	,p_hourly_salaried_code         => l_asg_rec1.hourly_salaried_code
	,p_title                        => l_asg_rec1.title
	-- Assignment DF
	,p_ass_attribute_category       => l_asg_rec1.ass_attribute_category
	,p_ass_attribute1               => l_asg_rec1.ass_attribute1
	,p_ass_attribute2               => l_asg_rec1.ass_attribute2
	,p_ass_attribute3               => l_asg_rec1.ass_attribute3
	,p_ass_attribute4               => l_asg_rec1.ass_attribute4
	,p_ass_attribute5               => l_asg_rec1.ass_attribute5
	,p_ass_attribute6               => l_asg_rec1.ass_attribute6
	,p_ass_attribute7               => l_asg_rec1.ass_attribute7
	,p_ass_attribute8               => l_asg_rec1.ass_attribute8
	,p_ass_attribute9               => l_asg_rec1.ass_attribute9
	,p_ass_attribute10              => l_asg_rec1.ass_attribute10
	,p_ass_attribute11              => l_asg_rec1.ass_attribute11
	,p_ass_attribute12              => l_asg_rec1.ass_attribute12
	,p_ass_attribute13              => l_asg_rec1.ass_attribute13
	,p_ass_attribute14              => l_asg_rec1.ass_attribute14
	,p_ass_attribute15              => l_asg_rec1.ass_attribute15
	,p_ass_attribute16              => l_asg_rec1.ass_attribute16
	,p_ass_attribute17              => l_asg_rec1.ass_attribute17
	,p_ass_attribute18              => l_asg_rec1.ass_attribute18
	,p_ass_attribute19              => l_asg_rec1.ass_attribute19
	,p_ass_attribute20              => l_asg_rec1.ass_attribute20
	,p_ass_attribute21              => l_asg_rec1.ass_attribute21
	,p_ass_attribute22              => l_asg_rec1.ass_attribute22
	,p_ass_attribute23              => l_asg_rec1.ass_attribute23
	,p_ass_attribute24              => l_asg_rec1.ass_attribute24
	,p_ass_attribute25              => l_asg_rec1.ass_attribute25
	,p_ass_attribute26              => l_asg_rec1.ass_attribute26
	,p_ass_attribute27              => l_asg_rec1.ass_attribute27
	,p_ass_attribute28              => l_asg_rec1.ass_attribute28
	,p_ass_attribute29              => l_asg_rec1.ass_attribute29
	,p_ass_attribute30              => l_asg_rec1.ass_attribute30
	-- Hr Soft Coding KeyFlex segments
	,p_scl_segment1                  => l_scl_rec.segment1
	,p_scl_segment2                  => l_scl_rec.segment2
	,p_scl_segment3                  => l_scl_rec.segment3
	,p_scl_segment4                  => l_scl_rec.segment4
	,p_scl_segment5                  => l_scl_rec.segment5
	,p_scl_segment6                  => l_scl_rec.segment6
	,p_scl_segment7                  => l_scl_rec.segment7
	,p_scl_segment8                  => l_scl_rec.segment8
	,p_scl_segment9                  => l_scl_rec.segment9
	,p_scl_segment10                 => l_scl_rec.segment10
	,p_scl_segment11                 => l_scl_rec.segment11
	,p_scl_segment12                 => l_scl_rec.segment12
	,p_scl_segment13                 => l_scl_rec.segment13
	,p_scl_segment14                 => l_scl_rec.segment14
	,p_scl_segment15                 => l_scl_rec.segment15
	,p_scl_segment16                 => l_scl_rec.segment16
	,p_scl_segment17                 => l_scl_rec.segment17
	,p_scl_segment18                 => l_scl_rec.segment18
	,p_scl_segment19                 => l_scl_rec.segment19
	,p_scl_segment20                 => l_scl_rec.segment20
	,p_scl_segment21                 => l_scl_rec.segment21
	,p_scl_segment22                 => l_scl_rec.segment22
	,p_scl_segment23                 => l_scl_rec.segment23
	,p_scl_segment24                 => l_scl_rec.segment24
	,p_scl_segment25                 => l_scl_rec.segment25
	,p_scl_segment26                 => l_scl_rec.segment26
	,p_scl_segment27                 => l_scl_rec.segment27
	,p_scl_segment28                 => l_scl_rec.segment28
	,p_scl_segment29                 => l_scl_rec.segment29
	,p_scl_segment30                 => l_scl_rec.segment30
	--         ,p_scl_concat_segments         => l_scl_rec.concatenated_segments    --  in     varchar2 default null
	-- People Group Flex
	,p_pgp_segment1                  => l_grp_rec.segment1
	,p_pgp_segment2                  => l_grp_rec.segment2
	,p_pgp_segment3                  => l_grp_rec.segment3
	,p_pgp_segment4                  => l_grp_rec.segment4
	,p_pgp_segment5                  => l_grp_rec.segment5
	,p_pgp_segment6                  => l_grp_rec.segment6
	,p_pgp_segment7                  => l_grp_rec.segment7
	,p_pgp_segment8                  => l_grp_rec.segment8
	,p_pgp_segment9                  => l_grp_rec.segment9
	,p_pgp_segment10                 => l_grp_rec.segment10
	,p_pgp_segment11                 => l_grp_rec.segment11
	,p_pgp_segment12                 => l_grp_rec.segment12
	,p_pgp_segment13                 => l_grp_rec.segment13
	,p_pgp_segment14                 => l_grp_rec.segment14
	,p_pgp_segment15                 => l_grp_rec.segment15
	,p_pgp_segment16                 => l_grp_rec.segment16
	,p_pgp_segment17                 => l_grp_rec.segment17
	,p_pgp_segment18                 => l_grp_rec.segment18
	,p_pgp_segment19                 => l_grp_rec.segment19
	,p_pgp_segment20                 => l_grp_rec.segment20
	,p_pgp_segment21                 => l_grp_rec.segment21
	,p_pgp_segment22                 => l_grp_rec.segment22
	,p_pgp_segment23                 => l_grp_rec.segment23
	,p_pgp_segment24                 => l_grp_rec.segment24
	,p_pgp_segment25                 => l_grp_rec.segment25
	,p_pgp_segment26                 => l_grp_rec.segment26
	,p_pgp_segment27                 => l_grp_rec.segment27
	,p_pgp_segment28                 => l_grp_rec.segment28
	,p_pgp_segment29                 => l_grp_rec.segment29
	,p_pgp_segment30                 => l_grp_rec.segment30
	,p_pgp_concat_segments           => l_grp_rec.group_name

	,p_employee_category             => l_asg_rec1.employee_category
	-- Out Vars
	,p_special_ceiling_step_id       => l_AsgUpdCrit_Api.special_ceiling_step_id
	,p_group_name                    => l_AsgUpdCrit_Api.group_name
	,p_concatenated_segments         => l_scl_rec.concatenated_segments
	,p_cagr_grade_def_id             => l_asg_rec.cagr_grade_def_id
	,p_cagr_concatenated_segments    => l_UpdEmpAsg_out.cagr_concatenated_segments
	,p_assignment_id                 => g_asg_rec.assignment_id
	,p_soft_coding_keyflex_id        => l_AsgUpdCrit_Api.soft_coding_keyflex_id
	,p_people_group_id               => l_AsgUpdCrit_Api.people_group_id
	,p_object_version_number         => l_hrEmpApi_out.asg_object_version_number
	,p_effective_start_date          => l_AsgUpdCrit_Api.asg_effective_start_date
	,p_effective_end_date            => l_AsgUpdCrit_Api.asg_effective_end_date
	,p_assignment_sequence           => l_hrEmpApi_out.assignment_sequence
	,p_comment_id                    => l_UpdEmpAsg_out.comment_id
	,p_other_manager_warning         => l_UpdEmpAsg_out.other_manager_warning
	,p_hourly_salaried_warning       => l_UpdEmpAsg_out.hourly_salaried_warning
	,p_gsp_post_process_warning      => l_UpdEmpAsg_out.gsp_post_process_warning);
	return;
    else
       raise e_crt_asg_not_allowed;
    end if;

   elsif l_pty_rec.system_person_type = 'CWK' then
    if (g_crt_upd = 'C') then -- Should have Create privileges to create sec assignment
	Hr_Assignment_Api.create_secondary_cwk_asg
	(p_validate                      => false
	,p_effective_date                => p_effective_date
	,p_business_group_id             => g_business_group_id
	,p_person_id                     => p_person_id
	,p_organization_id               => g_asg_rec.organization_id
	,p_assignment_number             => g_asg_rec.assignment_number

	,p_assignment_category           => l_asg_rec1.employment_category
	-- ,p_assignment_status_type_id    in     number
	,p_change_reason                 => l_asg_rec1.change_reason
	,p_comments                      => g_asg_comments
	,p_default_code_comb_id          => l_asg_rec1.default_code_comb_id
	--  ,p_establishment_id             in     number
	,p_frequency                     => l_asg_rec1.frequency
	,p_internal_address_line         => l_asg_rec1.internal_address_line
	,p_job_id                        => l_asg_rec1.job_id
	,p_labour_union_member_flag      => l_asg_rec1.labour_union_member_flag
	,p_location_id                   => l_asg_rec1.location_id
	,p_manager_flag                  => l_asg_rec1.manager_flag
	,p_normal_hours                  => l_asg_rec1.normal_hours
	,p_position_id                   => l_asg_rec1.position_id
	,p_grade_id                      => l_asg_rec1.grade_id
	-- ,p_project_title                in     varchar2
	,p_set_of_books_id               => l_asg_rec1.set_of_books_id
	,p_source_type                   => l_asg_rec1.source_type
	,p_supervisor_id                 => l_asg_rec1.supervisor_id
	,p_time_normal_finish            => l_asg_rec1.time_normal_finish
	,p_time_normal_start             => l_asg_rec1.time_normal_start
	,p_title                         => l_asg_rec1.title
	,p_attribute_category            => l_asg_rec1.ass_attribute_category
	,p_attribute1                    => l_asg_rec1.ass_attribute1
	,p_attribute2                    => l_asg_rec1.ass_attribute2
	,p_attribute3                    => l_asg_rec1.ass_attribute3
	,p_attribute4                    => l_asg_rec1.ass_attribute4
	,p_attribute5                    => l_asg_rec1.ass_attribute5
	,p_attribute6                    => l_asg_rec1.ass_attribute6
	,p_attribute7                    => l_asg_rec1.ass_attribute7
	,p_attribute8                    => l_asg_rec1.ass_attribute8
	,p_attribute9                    => l_asg_rec1.ass_attribute9
	,p_attribute10                   => l_asg_rec1.ass_attribute10
	,p_attribute11                   => l_asg_rec1.ass_attribute11
	,p_attribute12                   => l_asg_rec1.ass_attribute12
	,p_attribute13                   => l_asg_rec1.ass_attribute13
	,p_attribute14                   => l_asg_rec1.ass_attribute14
	,p_attribute15                   => l_asg_rec1.ass_attribute15
	,p_attribute16                   => l_asg_rec1.ass_attribute16
	,p_attribute17                   => l_asg_rec1.ass_attribute17
	,p_attribute18                   => l_asg_rec1.ass_attribute18
	,p_attribute19                   => l_asg_rec1.ass_attribute19
	,p_attribute20                   => l_asg_rec1.ass_attribute20
	,p_attribute21                   => l_asg_rec1.ass_attribute21
	,p_attribute22                   => l_asg_rec1.ass_attribute22
	,p_attribute23                   => l_asg_rec1.ass_attribute23
	,p_attribute24                   => l_asg_rec1.ass_attribute24
	,p_attribute25                   => l_asg_rec1.ass_attribute25
	,p_attribute26                   => l_asg_rec1.ass_attribute26
	,p_attribute27                   => l_asg_rec1.ass_attribute27
	,p_attribute28                   => l_asg_rec1.ass_attribute28
	,p_attribute29                   => l_asg_rec1.ass_attribute29
	,p_attribute30                   => l_asg_rec1.ass_attribute30
	-- People Group Flex
	,p_pgp_segment1                  => l_grp_rec.segment1
	,p_pgp_segment2                  => l_grp_rec.segment2
	,p_pgp_segment3                  => l_grp_rec.segment3
	,p_pgp_segment4                  => l_grp_rec.segment4
	,p_pgp_segment5                  => l_grp_rec.segment5
	,p_pgp_segment6                  => l_grp_rec.segment6
	,p_pgp_segment7                  => l_grp_rec.segment7
	,p_pgp_segment8                  => l_grp_rec.segment8
	,p_pgp_segment9                  => l_grp_rec.segment9
	,p_pgp_segment10                 => l_grp_rec.segment10
	,p_pgp_segment11                 => l_grp_rec.segment11
	,p_pgp_segment12                 => l_grp_rec.segment12
	,p_pgp_segment13                 => l_grp_rec.segment13
	,p_pgp_segment14                 => l_grp_rec.segment14
	,p_pgp_segment15                 => l_grp_rec.segment15
	,p_pgp_segment16                 => l_grp_rec.segment16
	,p_pgp_segment17                 => l_grp_rec.segment17
	,p_pgp_segment18                 => l_grp_rec.segment18
	,p_pgp_segment19                 => l_grp_rec.segment19
	,p_pgp_segment20                 => l_grp_rec.segment20
	,p_pgp_segment21                 => l_grp_rec.segment21
	,p_pgp_segment22                 => l_grp_rec.segment22
	,p_pgp_segment23                 => l_grp_rec.segment23
	,p_pgp_segment24                 => l_grp_rec.segment24
	,p_pgp_segment25                 => l_grp_rec.segment25
	,p_pgp_segment26                 => l_grp_rec.segment26
	,p_pgp_segment27                 => l_grp_rec.segment27
	,p_pgp_segment28                 => l_grp_rec.segment28
	,p_pgp_segment29                 => l_grp_rec.segment29
	,p_pgp_segment30                 => l_grp_rec.segment30
	,p_pgp_concat_segments           => l_grp_rec.group_name
	-- Hr Soft Coding KeyFlex segments
	,p_scl_segment1                  => l_scl_rec.segment1
	,p_scl_segment2                  => l_scl_rec.segment2
	,p_scl_segment3                  => l_scl_rec.segment3
	,p_scl_segment4                  => l_scl_rec.segment4
	,p_scl_segment5                  => l_scl_rec.segment5
	,p_scl_segment6                  => l_scl_rec.segment6
	,p_scl_segment7                  => l_scl_rec.segment7
	,p_scl_segment8                  => l_scl_rec.segment8
	,p_scl_segment9                  => l_scl_rec.segment9
	,p_scl_segment10                 => l_scl_rec.segment10
	,p_scl_segment11                 => l_scl_rec.segment11
	,p_scl_segment12                 => l_scl_rec.segment12
	,p_scl_segment13                 => l_scl_rec.segment13
	,p_scl_segment14                 => l_scl_rec.segment14
	,p_scl_segment15                 => l_scl_rec.segment15
	,p_scl_segment16                 => l_scl_rec.segment16
	,p_scl_segment17                 => l_scl_rec.segment17
	,p_scl_segment18                 => l_scl_rec.segment18
	,p_scl_segment19                 => l_scl_rec.segment19
	,p_scl_segment20                 => l_scl_rec.segment20
	,p_scl_segment21                 => l_scl_rec.segment21
	,p_scl_segment22                 => l_scl_rec.segment22
	,p_scl_segment23                 => l_scl_rec.segment23
	,p_scl_segment24                 => l_scl_rec.segment24
	,p_scl_segment25                 => l_scl_rec.segment25
	,p_scl_segment26                 => l_scl_rec.segment26
	,p_scl_segment27                 => l_scl_rec.segment27
	,p_scl_segment28                 => l_scl_rec.segment28
	,p_scl_segment29                 => l_scl_rec.segment29
	,p_scl_segment30                 => l_scl_rec.segment30
	,p_scl_concat_segments           => l_scl_rec.concatenated_segments

	--  ,p_supervisor_assignment_id     in     number

	,p_assignment_id                 => g_asg_rec.assignment_id
	,p_object_version_number         => l_hrEmpApi_out.asg_object_version_number
	,p_effective_start_date          => l_AsgUpdCrit_Api.asg_effective_start_date
	,p_effective_end_date            => l_AsgUpdCrit_Api.asg_effective_end_date
	,p_assignment_sequence           => l_hrEmpApi_out.assignment_sequence
	,p_comment_id                    => l_UpdEmpAsg_out.comment_id
	,p_people_group_id               => l_AsgUpdCrit_Api.people_group_id
	,p_people_group_name             => l_AsgUpdCrit_Api.group_name
	,p_other_manager_warning         => l_UpdEmpAsg_out.other_manager_warning
	,p_hourly_salaried_warning       => l_UpdEmpAsg_out.hourly_salaried_warning
	,p_soft_coding_keyflex_id        => l_AsgUpdCrit_Api.soft_coding_keyflex_id);
	return;
    else
       raise e_crt_asg_not_allowed;
    end if;
    elsif l_pty_rec.system_person_type = 'APL' then

     if(g_crt_upd = 'C') then
    hr_utility.set_location('Creating secondary assignment', 11);
    hr_assignment_api.create_secondary_apl_asg
  (p_validate                     =>     false
  ,p_effective_date               =>     p_effective_date
  ,p_person_id                    =>     p_person_id
  ,p_organization_id              =>     l_asg_rec1.organization_id
  ,p_recruiter_id                 =>     l_asg_rec1.recruiter_id
  ,p_grade_id                     =>     l_asg_rec1.grade_id
  ,p_position_id                  =>     l_asg_rec1.position_id
  ,p_job_id                       =>     l_asg_rec1.job_id
  ,p_assignment_status_type_id    =>     l_asg_rec1.assignment_status_type_id
  ,p_payroll_id                   =>     l_asg_rec1.payroll_id
  ,p_location_id                  =>     l_asg_rec1.location_id
  ,p_person_referred_by_id        =>     l_asg_rec1.person_referred_by_id
  ,p_supervisor_id                =>     l_asg_rec1.supervisor_id
  ,p_special_ceiling_step_id      =>     l_asg_rec1.special_ceiling_step_id
  ,p_recruitment_activity_id      =>     l_asg_rec1.recruitment_activity_id
  ,p_source_organization_id       =>     l_asg_rec1.source_organization_id
  ,p_vacancy_id                   =>     l_asg_rec1.vacancy_id
  ,p_pay_basis_id                 =>     l_asg_rec1.pay_basis_id
  ,p_change_reason                =>     l_asg_rec1.change_reason
  ,p_comments                     =>     g_asg_comments
  ,p_date_probation_end           =>     l_asg_rec1.date_probation_end
  ,p_default_code_comb_id         =>     l_asg_rec1.default_code_comb_id
  ,p_employment_category          =>     l_asg_rec1.employment_category
  ,p_frequency                    =>     l_asg_rec1.frequency
  ,p_internal_address_line        =>     l_asg_rec1.internal_address_line
  ,p_manager_flag                 =>     l_asg_rec1.manager_flag
  ,p_normal_hours                 =>     l_asg_rec1.normal_hours
  ,p_perf_review_period           =>     l_asg_rec1.perf_review_period
  ,p_perf_review_period_frequency =>     l_asg_rec1.perf_review_period_frequency
  ,p_probation_period             =>     l_asg_rec1.probation_period
  ,p_probation_unit               =>     l_asg_rec1.probation_unit
  ,p_sal_review_period            =>     l_asg_rec1.sal_review_period
  ,p_sal_review_period_frequency  =>     l_asg_rec1.sal_review_period_frequency
  ,p_set_of_books_id              =>     l_asg_rec1.set_of_books_id
  ,p_source_type                  =>     l_asg_rec1.source_type
  ,p_time_normal_finish           =>     l_asg_rec1.time_normal_finish
  ,p_time_normal_start            =>     l_asg_rec1.time_normal_start
  ,p_bargaining_unit_code         =>     l_asg_rec1.bargaining_unit_code
  ,p_ass_attribute_category       => l_asg_rec1.ass_attribute_category
  ,p_ass_attribute1               => l_asg_rec1.ass_attribute1
  ,p_ass_attribute2               => l_asg_rec1.ass_attribute2
  ,p_ass_attribute3               => l_asg_rec1.ass_attribute3
  ,p_ass_attribute4               => l_asg_rec1.ass_attribute4
  ,p_ass_attribute5               => l_asg_rec1.ass_attribute5
  ,p_ass_attribute6               => l_asg_rec1.ass_attribute6
  ,p_ass_attribute7               => l_asg_rec1.ass_attribute7
  ,p_ass_attribute8               => l_asg_rec1.ass_attribute8
  ,p_ass_attribute9               => l_asg_rec1.ass_attribute9
  ,p_ass_attribute10              => l_asg_rec1.ass_attribute10
  ,p_ass_attribute11              => l_asg_rec1.ass_attribute11
  ,p_ass_attribute12              => l_asg_rec1.ass_attribute12
  ,p_ass_attribute13              => l_asg_rec1.ass_attribute13
  ,p_ass_attribute14              => l_asg_rec1.ass_attribute14
  ,p_ass_attribute15              => l_asg_rec1.ass_attribute15
  ,p_ass_attribute16              => l_asg_rec1.ass_attribute16
  ,p_ass_attribute17              => l_asg_rec1.ass_attribute17
  ,p_ass_attribute18              => l_asg_rec1.ass_attribute18
  ,p_ass_attribute19              => l_asg_rec1.ass_attribute19
  ,p_ass_attribute20              => l_asg_rec1.ass_attribute20
  ,p_ass_attribute21              => l_asg_rec1.ass_attribute21
  ,p_ass_attribute22              => l_asg_rec1.ass_attribute22
  ,p_ass_attribute23              => l_asg_rec1.ass_attribute23
  ,p_ass_attribute24              => l_asg_rec1.ass_attribute24
  ,p_ass_attribute25              => l_asg_rec1.ass_attribute25
  ,p_ass_attribute26              => l_asg_rec1.ass_attribute26
  ,p_ass_attribute27              => l_asg_rec1.ass_attribute27
  ,p_ass_attribute28              => l_asg_rec1.ass_attribute28
  ,p_ass_attribute29              => l_asg_rec1.ass_attribute29
  ,p_ass_attribute30              => l_asg_rec1.ass_attribute30
  ,p_title                        => l_asg_rec1.title
  ,p_scl_segment1                 => l_scl_rec.segment1
  ,p_scl_segment2                 => l_scl_rec.segment2
  ,p_scl_segment3                 => l_scl_rec.segment3
  ,p_scl_segment4                 => l_scl_rec.segment4
  ,p_scl_segment5                 => l_scl_rec.segment5
  ,p_scl_segment6                 => l_scl_rec.segment6
  ,p_scl_segment7                 => l_scl_rec.segment7
  ,p_scl_segment8                 => l_scl_rec.segment8
  ,p_scl_segment9                 => l_scl_rec.segment9
  ,p_scl_segment10                => l_scl_rec.segment10
  ,p_scl_segment11                => l_scl_rec.segment11
  ,p_scl_segment12                => l_scl_rec.segment12
  ,p_scl_segment13                => l_scl_rec.segment13
  ,p_scl_segment14                => l_scl_rec.segment14
  ,p_scl_segment15                => l_scl_rec.segment15
  ,p_scl_segment16                => l_scl_rec.segment16
  ,p_scl_segment17                => l_scl_rec.segment17
  ,p_scl_segment18                => l_scl_rec.segment18
  ,p_scl_segment19                => l_scl_rec.segment19
  ,p_scl_segment20                => l_scl_rec.segment20
  ,p_scl_segment21                => l_scl_rec.segment21
  ,p_scl_segment22                => l_scl_rec.segment22
  ,p_scl_segment23                => l_scl_rec.segment23
  ,p_scl_segment24                => l_scl_rec.segment24
  ,p_scl_segment25                => l_scl_rec.segment25
  ,p_scl_segment26                => l_scl_rec.segment26
  ,p_scl_segment27                => l_scl_rec.segment27
  ,p_scl_segment28                => l_scl_rec.segment28
  ,p_scl_segment29                => l_scl_rec.segment29
  ,p_scl_segment30                => l_scl_rec.segment30
  ,p_scl_concat_segments          => l_scl_rec.concatenated_segments
  ,p_concatenated_segments        => l_concat_segments
  ,p_pgp_segment1                 => l_grp_rec.segment1
  ,p_pgp_segment2                 => l_grp_rec.segment2
  ,p_pgp_segment3                 => l_grp_rec.segment3
  ,p_pgp_segment4                 => l_grp_rec.segment4
  ,p_pgp_segment5                 => l_grp_rec.segment5
  ,p_pgp_segment6                 => l_grp_rec.segment6
  ,p_pgp_segment7                 => l_grp_rec.segment7
  ,p_pgp_segment8                 => l_grp_rec.segment8
  ,p_pgp_segment9                 => l_grp_rec.segment9
  ,p_pgp_segment10                => l_grp_rec.segment10
  ,p_pgp_segment11                => l_grp_rec.segment11
  ,p_pgp_segment12                => l_grp_rec.segment12
  ,p_pgp_segment13                => l_grp_rec.segment13
  ,p_pgp_segment14                => l_grp_rec.segment14
  ,p_pgp_segment15                => l_grp_rec.segment15
  ,p_pgp_segment16                => l_grp_rec.segment16
  ,p_pgp_segment17                => l_grp_rec.segment17
  ,p_pgp_segment18                => l_grp_rec.segment18
  ,p_pgp_segment19                => l_grp_rec.segment19
  ,p_pgp_segment20                => l_grp_rec.segment20
  ,p_pgp_segment21                => l_grp_rec.segment21
  ,p_pgp_segment22                => l_grp_rec.segment22
  ,p_pgp_segment23                => l_grp_rec.segment23
  ,p_pgp_segment24                => l_grp_rec.segment24
  ,p_pgp_segment25                => l_grp_rec.segment25
  ,p_pgp_segment26                => l_grp_rec.segment26
  ,p_pgp_segment27                => l_grp_rec.segment27
  ,p_pgp_segment28                => l_grp_rec.segment28
  ,p_pgp_segment29                => l_grp_rec.segment29
  ,p_pgp_segment30                => l_grp_rec.segment30
  ,p_concat_segments              => l_grp_rec.group_name
  ,p_cagr_id_flex_num             =>     null
  ,p_cag_segment1                 =>     null
  ,p_cag_segment2                 =>     null
  ,p_cag_segment3                 =>     null
  ,p_cag_segment4                 =>     null
  ,p_cag_segment5                 =>     null
  ,p_cag_segment6                 =>     null
  ,p_cag_segment7                 =>     null
  ,p_cag_segment8                 =>     null
  ,p_cag_segment9                 =>     null
  ,p_cag_segment10                =>     null
  ,p_cag_segment11                =>     null
  ,p_cag_segment12                =>     null
  ,p_cag_segment13                =>     null
  ,p_cag_segment14                =>     null
  ,p_cag_segment15                =>     null
  ,p_cag_segment16                =>     null
  ,p_cag_segment17                =>     null
  ,p_cag_segment18                =>     null
  ,p_cag_segment19                =>     null
  ,p_cag_segment20                =>     null
  ,p_contract_id                  =>     l_asg_rec1.contract_id
  ,p_establishment_id             =>     l_asg_rec1.establishment_id
  ,p_collective_agreement_id      =>     l_asg_rec1.collective_agreement_id
  ,p_notice_period		            =>    l_asg_rec1.notice_period
  ,p_notice_period_uom		        =>     l_asg_rec1.notice_period_uom
  ,p_employee_category		        =>     l_asg_rec1.employee_category
  ,p_work_at_home		              =>	   l_asg_rec1.work_at_home
  ,p_job_post_source_name         =>     l_asg_rec1.job_post_source_name
  ,p_applicant_rank               =>     l_asg_rec1.applicant_rank
  ,p_posting_content_id           =>     l_asg_rec1.posting_content_id
  ,p_grade_ladder_pgm_id          =>     l_asg_rec1.grade_ladder_pgm_id
  ,p_supervisor_assignment_id     =>     l_asg_rec1.supervisor_assignment_id
	,p_cagr_grade_def_id            => l_asg_rec.cagr_grade_def_id
	,p_cagr_concatenated_segments   => l_UpdEmpAsg_out.cagr_concatenated_segments
	,p_group_name                   => l_AsgUpdCrit_Api.group_name
  ,p_assignment_id                => g_asg_rec.assignment_id
	,p_people_group_id              => l_AsgUpdCrit_Api.people_group_id
	,p_soft_coding_keyflex_id       => l_AsgUpdCrit_Api.soft_coding_keyflex_id
	,p_comment_id                   => l_UpdEmpAsg_out.comment_id
  ,p_object_version_number        => l_hrEmpApi_out.asg_object_version_number
	,p_effective_start_date         => l_AsgUpdCrit_Api.asg_effective_start_date
	,p_effective_end_date            => l_AsgUpdCrit_Api.asg_effective_end_date
	,p_assignment_sequence           => l_hrEmpApi_out.assignment_sequence
  ,p_appl_override_warning         => l_appl_override_warning);
   return;
     else
          raise e_crt_asg_not_allowed;
     end if;

    end if;

  else
	g_asg_rec.person_id := l_asg_rec.person_id;
	g_asg_rec.business_group_id := l_asg_rec.business_group_id;
	g_asg_rec.assignment_id := l_asg_rec.assignment_id;
	--g_asg_rec.assignment_status_type_id := l_asg_rec.assignment_status_type_id;
  end if;


  --hr_utility.trace('BEFORE ENTERING Update_Employee_Asg with assntype as E' );

 if (g_crt_upd = 'C' or g_crt_upd = 'U') then
   if l_asg_rec.assignment_type ='E' then
     Update_Employee_Asg
     (p_effective_date => p_effective_date
     ,p_asg_crit_out   => l_AsgUpdCrit_Api
     );

   --hr_utility.trace('AFTER Update_Employee_Asg with assntype as E' );

   elsif l_asg_rec.assignment_type ='C' then
     Upd_Contingent_Asg
    (p_effective_date => p_effective_date
    ,p_asg_crit_out   => l_AsgUpdCrit_Api
     );
   elsif l_asg_rec.assignment_type ='A' then
     Upd_Applicant_Asg
    (p_effective_date => p_effective_date
    ,p_asg_crit_out   => l_AsgUpdCrit_Api
     );
   end if;
 else
   raise e_upl_not_allowed;
 end if;

 Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

end Update_Assignment;
-- =============================================================================
-- Direct_API_Call:
-- =============================================================================
procedure Direct_API_Call
         (p_dup_person_id       in number
         ,p_dup_party_id        in number
         ,p_appl_asg_id         in number
         ,p_effective_date      in date
         ,p_business_group_id   in number
         ,p_adjusted_svc_date   in date default null  -- Added by pkagrawa
         ) is
  l_hrEmpApi_out          t_hrEmpApi;
  l_asg_crit_out          t_AsgUpdCrit_Api;
  l_UpdEmp_Api            t_UpdEmp_Api;
  l_HrApp_Api             t_HrApp_Api;
  l_AsgUpdCrit_Api        t_AsgUpdCrit_Api;

  l_hire_Into_Employee    boolean;
  l_Apply_ForJob          boolean;
  l_Convert_To_CWK        boolean;
  l_Per_Exists_InHR       boolean;
  l_hire_Applicant        boolean;
  l_Convert_To_Applicant  boolean;

  l_Input_PerType         varchar2(90);
  l_action_mode           varchar2(90);
  l_proc_name    constant varchar2(150) := g_pkg||'Direct_API_Call';

begin
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  --
  -- If person id is passed check the creating person type with the person
  -- type of the person present in HRMS, to select the appropiate action.
  --
    --hr_utility.trace('Inside Direct_API_Call');

  Chk_Person_InHR
  (p_dup_person_id        => p_dup_person_id
  ,p_dup_party_id         => p_dup_party_id
  ,p_effective_date       => p_effective_date
  ,p_business_group_id    => p_business_group_id
  -- Out
  ,p_Input_PerType        => l_Input_PerType
  ,p_hire_Into_Employee   => l_hire_Into_Employee
  ,p_hire_Applicant       => l_hire_Applicant
  ,p_Convert_To_Applicant => l_Convert_To_Applicant
  ,p_Apply_For_Job        => l_Apply_ForJob
  ,p_Convert_To_CWK       => l_Convert_To_CWK
  ,p_Per_Exists_InHR      => l_Per_Exists_InHR
  );
  --
  -- Creating an Employee
  --

      --hr_utility.trace(' l_Input_PerType='||l_Input_PerType);

  if l_Input_PerType = 'EMP' then

           --hr_utility.trace(' Inside PerType=EMP');

     if l_hire_Into_Employee then
        if (g_crt_upd = 'C') then
        l_action_mode := 'HIRE_PERSON_INTOEMP';
        else
        raise e_crt_per_not_allowed;
        end if;
     elsif l_hire_Applicant then
        if (g_crt_upd = 'C' or g_crt_upd = 'U') then
        l_action_mode := 'HIRE_APPLICANT';
        else
        raise e_upl_not_allowed;
        end if;
     else
        if (g_crt_upd = 'C') then
        l_action_mode := 'CREATE_EMPLOYEE';
        else
        raise e_crt_per_not_allowed;
        end if;
     end if;
     --
    --hr_utility.trace(' l_action_mode='||l_action_mode);

     if l_action_mode in ('CREATE_EMPLOYEE',
                          'HIRE_PERSON_INTOEMP') then
        InsUpd_Employee
        (p_validate       => false
        ,p_action_mode    => l_action_mode
        ,p_effective_date => p_effective_date
        --Added by Dbansal
        ,p_per_comments  => g_per_comments
        ,p_emp_api_out    => l_hrEmpApi_out
        ,p_adjusted_svc_date => p_adjusted_svc_date -- Added by pkagrawa
         );
     elsif l_action_mode = 'HIRE_APPLICANT' then
        Hire_Applicant_IntoEmp
        (p_validate            => false
        ,p_hire_date           => p_effective_date
        ,p_person_id           => p_dup_person_id
        ,p_assignment_id       => p_appl_asg_id
--        ,p_adjusted_svc_date   => null  --Commented by pkagrawa
        ,p_adjusted_svc_date   => p_adjusted_svc_date -- Added by pkagrawa
        ,p_updper_api_out      => l_UpdEmp_Api
        ,p_HireAppapi_out      => l_HrApp_Api
        );
     end if;
     --
     -- Insert/Update Person Primary Address
     --
     InsUpd_Address
     (p_effective_date           => g_per_rec.start_date
     ,p_HR_address_id            => g_add_rec.address_id
     ,p_HR_object_version_number => g_add_rec.object_version_number
      );
     --
     -- Update the Employee Assignment
     --
     --$ Update Assignment only if User wants to i.e. he has entered mandatory column
      -- 'Assign Organization'

     --$ while updating assignment pass assignment effective start date as obtained
     -- from spreadsheet by default and if it is null then use person start date as
     -- assignment effective start date
     if (g_asg_rec.organization_id is NOT NULL) then
        if (g_crt_upd = 'C' or g_crt_upd = 'U') then
         Update_Employee_Asg
        (p_effective_date =>  nvl(g_asg_rec.effective_start_date,g_per_rec.start_date)
        ,p_asg_crit_out   => l_asg_crit_out
         );
        else
        raise e_upl_not_allowed;
        end if;
  end if;

  end if;
  --
  -- Creating a Contingent Worker
  --
  if l_Input_PerType = 'CWK' then

           --hr_utility.trace(' Inside PerType=CWK');

     if l_Convert_To_CWK then
        if (g_crt_upd = 'C' or g_crt_upd = 'U') then
        l_action_mode := 'CONVERT_TO_CWK';
        else
        raise e_upl_not_allowed;
        end if;
     else
        if (g_crt_upd = 'C') then
        l_action_mode := 'CREATE_CWK';
        else
        raise e_crt_per_not_allowed;
        end if;
     end if;
     --
     -- Create/Convert the person into an Contigent Worker
     --
     InsUpd_Contingent_Worker
     (p_validate              => false
     ,p_action_mode           => l_action_mode
     ,p_datetrack_update_mode => Null
     ,p_effective_date        => p_effective_date
     ,p_adjusted_svc_date     => null
     ,p_per_comments          => g_per_comments -- null --Changed by Dbansal
     ,p_cwk_api_out           => l_hrEmpApi_out
      );
     --
     -- Update/Insert Address
     --
     InsUpd_Address
     (p_effective_date           => g_per_rec.start_date
     ,p_HR_address_id            => g_add_rec.address_id
     ,p_HR_object_version_number => g_add_rec.object_version_number
      );
     --
     -- Update the Contingent Worker assignment
     --
      --$ Update Assignment only if User wants to i.e. he has entered mandatory column
      -- 'Assign Organization'
      --$ while updating assignment pass assignment effective start date as obtained
      -- from spreadsheet by default and if it is null then use person start date as
      -- assignment effective start date
     if (g_asg_rec.organization_id is NOT NULL) then
       if (g_crt_upd = 'C' or g_crt_upd = 'U') then
       Upd_Contingent_Asg
       (p_effective_date => nvl(g_asg_rec.effective_start_date,g_per_rec.start_date)
       ,p_asg_crit_out   => l_asg_crit_out
        );
       else
       raise e_upl_not_allowed;
       end if;
      end if;
  end if;
  --
  -- Creating an Applicant for a Job
  --


  if l_Input_PerType = 'APL' then

          --hr_utility.trace(' Inside PerType=APL');

     if l_Convert_To_Applicant or
        l_Apply_ForJob         then
       if (g_crt_upd = 'C' or g_crt_upd = 'U') then
       l_action_mode := 'APPLY_FOR_JOB';
       else
       raise e_upl_not_allowed;
       end if;
     else
       if (g_crt_upd = 'C') then
       l_action_mode := 'CREATE_APPLICANT';
       else
       raise e_crt_per_not_allowed;
       end if;
     end if;
     --
     -- Create/Convert the person into an applicant
     --
     InsUpd_Applicant
    (p_validate          => false
    ,p_action_mode       => l_action_mode
    ,p_effective_date    => p_effective_date
    ,p_adjusted_svc_date => null
    ,p_per_comments      => g_per_comments -- null --Changed by Dbansal
    ,p_assignment_id     => p_appl_asg_id
    ,p_appl_api_out      => l_hrEmpApi_out
     );
     --
     -- Update/Insert Address
     --
     InsUpd_Address
    (p_effective_date           => g_per_rec.start_date
    ,p_HR_address_id            => g_add_rec.address_id
    ,p_HR_object_version_number => g_add_rec.object_version_number
     );
     --
     -- Update the Applicant assignment
     --
      --$ Update Assignment only if User wants to i.e. he has entered mandatory column
      -- 'Assign Organization'
      --$ while updating assignment pass assignment effective start date as obtained
      -- from spreadsheet by default and if it is null then use person start date as
      -- assignment effective start date

     if (g_asg_rec.organization_id is NOT NULL) then
       if (g_crt_upd = 'C' or g_crt_upd = 'U') then
       Upd_Applicant_Asg
       (p_effective_date => nvl(g_asg_rec.effective_start_date,g_per_rec.start_date)
       ,p_asg_crit_out   => l_AsgUpdCrit_Api
        );
       else
       raise e_upl_not_allowed;
       end if;
     end if;
     --
  end if;
  --
  -- Create the contact person only if the person does exists
  --

  if l_Input_PerType = 'OTHER' then

        --hr_utility.trace('Inside PerType=OTHER');

     if not l_Per_Exists_InHR then
        if (g_crt_upd = 'C') then
        InsUpd_Contact_Person
        (p_validate            => false
        ,p_effective_date      => p_effective_date
        ,p_adjusted_svc_date   => null
        ,p_per_comments        =>  null
        ,p_contact_api_out     => l_hrEmpApi_out
         );
       else
       raise e_crt_per_not_allowed;
       end if;
     else
        if (g_crt_upd = 'C' or g_crt_upd = 'U') then
        Upd_Person_Details
        (p_validate            => false
        ,p_effective_date      => p_effective_date
        ,p_person_id           => g_per_rec.person_id
        ,p_adjusted_svc_date   => null
        ,p_updper_api_out      => l_UpdEmp_Api
         );
         else
         raise e_upl_not_allowed;
         end if;
     end if;

     g_add_rec.person_id := g_per_rec.person_id;
     g_add_rec.party_id := g_add_rec.party_id;
     g_add_rec.business_group_id := p_business_group_id;

     InsUpd_Address
     (p_effective_date           => g_per_rec.start_date
     ,p_HR_address_id            => g_add_rec.address_id
     ,p_HR_object_version_number => g_add_rec.object_version_number
      );
  end if;
  --
  -- If the person already exists with the same person type then
  -- just update the person details.
  --

  if l_Input_PerType = 'UPD_PERSON' then

    --hr_utility.trace(' Inside PerType=UPD_PERSON');
    if (g_crt_upd = 'C' or g_crt_upd = 'U') then
     Upd_Person_Details
     (p_validate            => false
     ,p_effective_date      => p_effective_date
     ,p_person_id           => g_per_rec.person_id
--    ,p_adjusted_svc_date   => null  --Commented by pkagrawa
     ,p_adjusted_svc_date   => p_adjusted_svc_date -- Added by pkagrawa
     ,p_updper_api_out      => l_UpdEmp_Api
      );
    else
      raise e_upl_not_allowed;
    end if;


     g_add_rec.person_id := g_per_rec.person_id;
     g_add_rec.party_id  := g_per_rec.party_id;
     g_add_rec.business_group_id := p_business_group_id;

     InsUpd_Address
     (p_effective_date           => g_per_rec.start_date
     ,p_HR_address_id            => g_add_rec.address_id
     ,p_HR_object_version_number => g_add_rec.object_version_number
      );

      --$ Update Assignment only if User wants to i.e. he has entered mandatory column
      -- 'Assign Organization'
      --$ while updating assignment pass assignment effective start date as obtained
      -- from spreadsheet by default and if it is null then use person start date as
      -- assignment effective start date

     if (g_asg_rec.organization_id is NOT NULL) then
     Update_Assignment
     (p_effective_date    => nvl(g_asg_rec.effective_start_date,g_per_rec.start_date) --p_effective_date
     ,p_business_group_id => p_business_group_id
     ,p_person_id         => g_per_rec.person_id
      );
      end if;

  end  if;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

end Direct_API_Call;

-- =============================================================================
-- Get_AplAsg_Id:
-- =============================================================================
function Get_AplAsg_Id
         (p_person_id         in number
         ,p_apl_asg_no        in varchar2
         ,p_business_group_id in number
         ,p_effective_date    in date
         ) return number is

  cursor csr_asg (c_assignment_number in varchar2
                 ,c_person_id         in number
                 ,c_business_group_id in number
                 ,c_effective_date    in date
                 ) is
  select paf.assignment_id
    from per_all_assignments_f paf
   where paf.person_id = c_person_id
     and paf.assignment_type = 'A'
     and paf.assignment_number = c_assignment_number
     and paf.business_group_id = c_business_group_id
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;
--$ New cursor for Applicant with no assignment number.
  cursor csr_asg_n (c_person_id         in number
                 ,c_business_group_id in number
                 ,c_effective_date    in date
                 ) is
  select paf.assignment_id
    from per_all_assignments_f paf
   where paf.person_id = c_person_id
     and paf.assignment_type = 'A'
     and paf.business_group_id = c_business_group_id
     and c_effective_date between paf.effective_start_date
                              and paf.effective_end_date;

  l_asg_rec        csr_asg%rowtype;
  l_asg_rec_n	   csr_asg_n%rowtype;
  l_AsgUpdCrit_Api t_AsgUpdCrit_Api;
  l_apl_asg_id     number;
  l_proc_name    constant varchar2(150) := g_pkg||'Get_AplAsg_Id';

begin
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
if p_apl_asg_no is not null then
  open csr_asg (c_assignment_number => p_apl_asg_no
               ,c_person_id         => p_person_id
               ,c_business_group_id => p_business_group_id
               ,c_effective_date    => p_effective_date
               );
  fetch csr_asg into l_asg_rec;

  if  csr_asg%notfound then
    close csr_asg;
    return l_apl_asg_id;
  else
    l_apl_asg_id := l_asg_rec.assignment_id;
  end if;
  close csr_asg;
  return l_apl_asg_id;
else
	open csr_asg_n (c_person_id         => p_person_id
               ,c_business_group_id => p_business_group_id
               ,c_effective_date    => p_effective_date
               );
	fetch csr_asg_n into l_asg_rec_n;
	if  csr_asg_n%notfound then
		 close csr_asg_n;
	return l_apl_asg_id;
	else
	l_apl_asg_id := l_asg_rec_n.assignment_id;
	end if;
	     close csr_asg_n;
	  return l_apl_asg_id;
end if;

 Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

end Get_AplAsg_Id;
-- =============================================================================
-- ~ InsUpd_PerAsgAdd_Rec:
-- =============================================================================
procedure InsUpd_PerAsgAdd_Rec
         (p_last_name                    in varchar2
         ,p_middle_name                  in varchar2
         ,p_first_name                   in varchar2
         ,p_suffix                       in varchar2
         ,p_prefix                       in varchar2
         ,p_title                        in varchar2
         ,p_email_address                in varchar2
         ,p_preferred_name               in varchar2
         ,p_dup_person_id                in number
         ,p_dup_party_id                 in number
         ,p_marital_status               in varchar2
         ,p_sex                          in varchar2
         ,p_nationality                  in varchar2
         ,p_national_identifier          in varchar2
         ,p_date_of_birth                in date
         ,p_date_of_hire                 in date
         ,p_employee_number              in varchar2
         ,p_primary_flag                 in varchar2
         ,p_address_style                in varchar2
         ,p_address_line1                in varchar2
         ,p_address_line2                in varchar2
         ,p_address_line3                in varchar2
         ,p_region1                      in varchar2
         ,p_region2                      in varchar2
         ,p_region3                      in varchar2
         ,p_town_or_city                 in varchar2
         ,p_country                      in varchar2
         ,p_postal_code                  in varchar2
         ,p_telephone_no1                in varchar2
         ,p_telephone_no2                in varchar2
         ,p_telephone_no3                in varchar2
         ,p_address_date_from            in date
         ,p_address_date_to              in date
         ,p_phone_type                   in varchar2
         ,p_phone_number                 in varchar2
         ,p_phone_date_from              in date
         ,p_phone_date_to                in date
         ,p_contact_type                 in varchar2
         ,p_contact_name                 in varchar2
         ,p_primary_contact              in varchar2
         ,p_personal_flag                in varchar2
         ,p_contact_date_from            in date
         ,p_contact_date_to              in date
         ,p_assign_organization          in varchar2
         ,p_job                          in number
         ,p_grade                        in number
         ,p_internal_location            in varchar2
         ,p_assign_group                 in varchar2
         ,p_position                     in number
         ,p_payroll                      in number
         ,p_status                       in varchar2
         ,p_assignment_no                in varchar2
         ,p_assignment_category          in varchar2
         ,p_collective_agreement         in varchar2
         ,p_employee_category            in varchar2
         ,p_user_person_type             in number
         ,p_salary_basis                 in number
         ,p_gre                          in varchar2
         ,p_web_adi_identifier           in varchar2
         ,p_assign_eff_dt_from           in date
         ,p_assign_eff_dt_to             in date
         -- Person DF Information
         ,p_per_attribute_category       in varchar2
         ,p_per_attribute1               in varchar2
         ,p_per_attribute2               in varchar2
         ,p_per_attribute3               in varchar2
         ,p_per_attribute4               in varchar2
         ,p_per_attribute5               in varchar2
         ,p_per_attribute6               in varchar2
         ,p_per_attribute7               in varchar2
         ,p_per_attribute8               in varchar2
         ,p_per_attribute9               in varchar2
         ,p_per_attribute10              in varchar2
         ,p_per_attribute11              in varchar2
         ,p_per_attribute12              in varchar2
         ,p_per_attribute13              in varchar2
         ,p_per_attribute14              in varchar2
         ,p_per_attribute15              in varchar2
         ,p_per_attribute16              in varchar2
         ,p_per_attribute17              in varchar2
         ,p_per_attribute18              in varchar2
         ,p_per_attribute19              in varchar2
         ,p_per_attribute20              in varchar2
         ,p_per_attribute21              in varchar2
         ,p_per_attribute22              in varchar2
         ,p_per_attribute23              in varchar2
         ,p_per_attribute24              in varchar2
         ,p_per_attribute25              in varchar2
         ,p_per_attribute26              in varchar2
         ,p_per_attribute27              in varchar2
         ,p_per_attribute28              in varchar2
         ,p_per_attribute29              in varchar2
         ,p_per_attribute30              in varchar2
         -- Person Legislative Information
         ,p_per_information_category     in varchar2
         ,p_per_information1             in varchar2
         ,p_per_information2             in varchar2
         ,p_per_information3             in varchar2
         ,p_per_information4             in varchar2
         ,p_per_information5             in varchar2
         ,p_per_information6             in varchar2
         ,p_per_information7             in varchar2
         ,p_per_information8             in varchar2
         ,p_per_information9             in varchar2
         ,p_per_information10            in varchar2
         ,p_per_information11            in varchar2
         ,p_per_information12            in varchar2
         ,p_per_information13            in varchar2
         ,p_per_information14            in varchar2
         ,p_per_information15            in varchar2
         ,p_per_information16            in varchar2
         ,p_per_information17            in varchar2
         ,p_per_information18            in varchar2
         ,p_per_information19            in varchar2
         ,p_per_information20            in varchar2
         ,p_per_information21            in varchar2
         ,p_per_information22            in varchar2
         ,p_per_information23            in varchar2
         ,p_per_information24            in varchar2
         ,p_per_information25            in varchar2
         ,p_per_information26            in varchar2
         ,p_per_information27            in varchar2
         ,p_per_information28            in varchar2
         ,p_per_information29            in varchar2
         ,p_per_information30            in varchar2
         -- Assignment DF Information
         ,p_ass_attribute_category       in varchar2
         ,p_ass_attribute1               in varchar2
         ,p_ass_attribute2               in varchar2
         ,p_ass_attribute3               in varchar2
         ,p_ass_attribute4               in varchar2
         ,p_ass_attribute5               in varchar2
         ,p_ass_attribute6               in varchar2
         ,p_ass_attribute7               in varchar2
         ,p_ass_attribute8               in varchar2
         ,p_ass_attribute9               in varchar2
         ,p_ass_attribute10              in varchar2
         ,p_ass_attribute11              in varchar2
         ,p_ass_attribute12              in varchar2
         ,p_ass_attribute13              in varchar2
         ,p_ass_attribute14              in varchar2
         ,p_ass_attribute15              in varchar2
         ,p_ass_attribute16              in varchar2
         ,p_ass_attribute17              in varchar2
         ,p_ass_attribute18              in varchar2
         ,p_ass_attribute19              in varchar2
         ,p_ass_attribute20              in varchar2
         ,p_ass_attribute21              in varchar2
         ,p_ass_attribute22              in varchar2
         ,p_ass_attribute23              in varchar2
         ,p_ass_attribute24              in varchar2
         ,p_ass_attribute25              in varchar2
         ,p_ass_attribute26              in varchar2
         ,p_ass_attribute27              in varchar2
         ,p_ass_attribute28              in varchar2
         ,p_ass_attribute29              in varchar2
         ,p_ass_attribute30              in varchar2
         -- Address Df Information
         ,p_adr_attribute_category       in varchar2
         ,p_adr_attribute1               in varchar2
         ,p_adr_attribute2               in varchar2
         ,p_adr_attribute3               in varchar2
         ,p_adr_attribute4               in varchar2
         ,p_adr_attribute5               in varchar2
         ,p_adr_attribute6               in varchar2
         ,p_adr_attribute7               in varchar2
         ,p_adr_attribute8               in varchar2
         ,p_adr_attribute9               in varchar2
         ,p_adr_attribute10              in varchar2
         ,p_adr_attribute11              in varchar2
         ,p_adr_attribute12              in varchar2
         ,p_adr_attribute13              in varchar2
         ,p_adr_attribute14              in varchar2
         ,p_adr_attribute15              in varchar2
         ,p_adr_attribute16              in varchar2
         ,p_adr_attribute17              in varchar2
         ,p_adr_attribute18              in varchar2
         ,p_adr_attribute19              in varchar2
         ,p_adr_attribute20              in varchar2

         ,p_business_group_id            in number
         ,p_data_pump_flag               in varchar2
         ,p_add_information13            in varchar2
         ,p_add_information14            in varchar2
         ,p_add_information15            in varchar2
         ,p_add_information16            in varchar2
         ,p_add_information17            in varchar2
         ,p_add_information18            in varchar2
         ,p_add_information19            in varchar2
         ,p_add_information20            in varchar2
         -- People Group KFF
         ,p_concat_segments              in varchar2
         ,p_people_segment1              in varchar2
         ,p_people_segment2              in varchar2
         ,p_people_segment3              in varchar2
         ,p_people_segment4              in varchar2
         ,p_people_segment5              in varchar2
         ,p_people_segment6              in varchar2
         ,p_people_segment7              in varchar2
         ,p_people_segment8              in varchar2
         ,p_people_segment9              in varchar2
         ,p_people_segment10             in varchar2
         ,p_people_segment11             in varchar2
         ,p_people_segment12             in varchar2
         ,p_people_segment13             in varchar2
         ,p_people_segment14             in varchar2
         ,p_people_segment15             in varchar2
         ,p_people_segment16             in varchar2
         ,p_people_segment17             in varchar2
         ,p_people_segment18             in varchar2
         ,p_people_segment19             in varchar2
         ,p_people_segment20             in varchar2
         ,p_people_segment21             in varchar2
         ,p_people_segment22             in varchar2
         ,p_people_segment23             in varchar2
         ,p_people_segment24             in varchar2
         ,p_people_segment25             in varchar2
         ,p_people_segment26             in varchar2
         ,p_people_segment27             in varchar2
         ,p_people_segment28             in varchar2
         ,p_people_segment29             in varchar2
         ,p_people_segment30             in varchar2
         -- Soft Coding KFF
         ,p_soft_segments                in varchar2
         ,p_soft_segment1                in varchar2
         ,p_soft_segment2                in varchar2
         ,p_soft_segment3                in varchar2
         ,p_soft_segment4                in varchar2
         ,p_soft_segment5                in varchar2
         ,p_soft_segment6                in varchar2
         ,p_soft_segment7                in varchar2
         ,p_soft_segment8                in varchar2
         ,p_soft_segment9                in varchar2
         ,p_soft_segment10               in varchar2
         ,p_soft_segment11               in varchar2
         ,p_soft_segment12               in varchar2
         ,p_soft_segment13               in varchar2
         ,p_soft_segment14               in varchar2
         ,p_soft_segment15               in varchar2
         ,p_soft_segment16               in varchar2
         ,p_soft_segment17               in varchar2
         ,p_soft_segment18               in varchar2
         ,p_soft_segment19               in varchar2
         ,p_soft_segment20               in varchar2
         ,p_soft_segment21               in varchar2
         ,p_soft_segment22               in varchar2
         ,p_soft_segment23               in varchar2
         ,p_soft_segment24               in varchar2
         ,p_soft_segment25               in varchar2
         ,p_soft_segment26               in varchar2
         ,p_soft_segment27               in varchar2
         ,p_soft_segment28               in varchar2
         ,p_soft_segment29               in varchar2
         ,p_soft_segment30               in varchar2

         ,p_business_group_name          in varchar2
         ,p_batch_id                     in number
         ,p_data_pump_batch_line_id      in varchar2
         ,p_per_comments                 in varchar2
         ,p_date_employee_data_verified  in date
         ,p_expense_check_send_to_addres in varchar2
         ,p_previous_last_name           in varchar2
         ,p_registered_disabled_flag     in varchar2
         ,p_vendor_id                    in number
         ,p_date_of_death                in date
         ,p_background_check_status      in varchar2
         ,p_background_date_check        in date
         ,p_blood_type                   in varchar2
         ,p_correspondence_language      in varchar2
         ,p_fast_path_employee           in varchar2
         ,p_fte_capacity                 in number
         ,p_honors                       in varchar2
         ,p_last_medical_test_by         in varchar2
         ,p_last_medical_test_date       in date
         ,p_mailstop                     in varchar2
         ,p_office_number                in varchar2
         ,p_on_military_service          in varchar2
         ,p_pre_name_adjunct             in varchar2
         ,p_projected_start_date         in date
         ,p_resume_exists                in varchar2
         ,p_resume_last_updated          in date
         ,p_second_passport_exists       in varchar2
         ,p_student_status               in varchar2
         ,p_work_schedule                in varchar2
         ,p_benefit_group_id             in number
         ,p_receipt_of_death_cert_date   in date
         ,p_coord_ben_med_pln_no         in varchar2
         ,p_coord_ben_no_cvg_flag        in varchar2
         ,p_coord_ben_med_ext_er         in varchar2
         ,p_coord_ben_med_pl_name        in varchar2
         ,p_coord_ben_med_insr_crr_name  in varchar2
         ,p_coord_ben_med_insr_crr_ident in varchar2
         ,p_coord_ben_med_cvg_strt_dt    in date
         ,p_coord_ben_med_cvg_end_dt     in date
         ,p_uses_tobacco_flag            in varchar2
         ,p_dpdnt_adoption_date          in date
         ,p_dpdnt_vlntry_svce_flag       in varchar2
         ,p_original_date_of_hire        in date
         ,p_adjusted_svc_date            in date
         ,p_town_of_birth                in varchar2
         ,p_region_of_birth              in varchar2
         ,p_country_of_birth             in varchar2
         ,p_global_person_id             in varchar2
         ,p_party_id                     in number
         ,p_supervisor_id                in number
         ,p_assignment_number            in varchar2
         ,p_change_reason                in varchar2
         ,p_asg_comments                 in varchar2
         ,p_date_probation_end           in date
         ,p_default_code_comb_id         in number
         ,p_frequency                    in varchar2
         ,p_internal_address_line        in varchar2
         ,p_manager_flag                 in varchar2
         ,p_normal_hours                 in number
         ,p_perf_review_period           in number
         ,p_perf_review_period_frequency in varchar2
         ,p_probation_period             in number
         ,p_probation_unit               in varchar2
         ,p_sal_review_period            in number
         ,p_sal_review_period_frequency  in varchar2
         ,p_set_of_books_id              in number
         ,p_source_type                  in varchar2
         ,p_time_normal_finish           in varchar2
         ,p_time_normal_start            in varchar2
         ,p_bargaining_unit_code         in varchar2
         ,p_labour_union_member_flag     in varchar2
         ,p_hourly_salaried_code         in varchar2
         ,p_pradd_ovlapval_override      in varchar2
         ,p_address_type                 in varchar2
         ,p_adr_comments                 in varchar2
         ,p_batch_name                   in varchar2
         ,p_location_id                  in number
         ,p_student_number               in varchar2
         ,p_apl_assignment_id            in varchar2
         ,p_applicant_number             in varchar2
         ,p_cwk_number                   in varchar2
         ,p_interface_code               in varchar2
--$ Update Batch
         ,p_batch_link                   in number
--$ Get the mode ("Create and Update", "Update Only" or "View Only" )
         ,p_crt_upd                      in varchar2
         ,p_assignment_id                in number
          ) as
  --
  -- Dynamic Ref Cursor
  --
  csr_get_party_id         ref_cur_typ;
  --
  -- Record types
  --
  l_emp_api_out            t_hrEmpApi;
  l_asg_crit_out           t_AsgUpdCrit_Api;
  l_updper_api_out         t_UpdEmp_Api;
  l_crt_emp_api_out        t_CreateContact_Api;
  l_HireToJobapi_out       t_HrToJob_Api;
  l_HireAppapi_out         t_HrApp_Api;
  --
  -- Type declarations
  --
  l_chk_per                chk_party%rowtype;
  l_national_identifier    per_people_f.national_identifier%type;
  l_party_id               per_people_f.party_id%type;
  l_dff_ctx                fnd_descr_flex_contexts.descriptive_flex_context_code%type;

  -- added by dbansal
   l_gre_name  HR_ALL_ORGANIZATION_UNITS_TL.name%type;
   temp varchar2(20);
  --
  -- Date variables
  --
  l_effective_date         date;
  --
  -- Number Variables
  --
  l_dup_asg_id             number(15);
  --
  -- String variables
  --
  l_ni_exists              varchar2(10);
  l_pp_error_code          varchar2(50);
  l_visa_error_code        varchar2(50);
  l_visit_error_code       varchar2(50);
  l_oss_error_code         varchar2(50);
  l_party_number           varchar2(100);
  l_dyn_sql_qry            varchar2(500);
  l_sql_qry                varchar2(500);
  l_error_message          varchar2(2000);
  --
  -- Boolean variables
  --
  l_ossDtls_warning        boolean;
  l_active_cwk             boolean;
  l_visit_warning          boolean;
  l_visa_warning           boolean;
  l_passport_warning       boolean;
  --
  -- Constants
  --
  l_apl_assignment_id      number;
  l_person_id              number;
  l_proc_name  constant    varchar2(150):= g_pkg ||'InsUpd_PerAsgAdd_Rec';
  id_flex_num              number(20);

  MSGDATA       varchar2(32000);
  MSGNAME       varchar2(30);
  MSGAPP        varchar2(50);
  MSGENCODED    varchar2(32100);
  MSGENCODEDLEN number(6);
  MSGNAMELOC    number(6);
  MSGTEXTLOC    number(6);

  l_migration_allowed      varchar2(1);
  l_crt_upd                varchar2(1);

begin

  savepoint InsUpd_PerAsgAdd_Rec;
  g_debug := hr_utility.debug_enabled;
  hr_utility.set_location('Entering: ' || l_proc_name, 5);

  l_migration_allowed := SUBSTR(p_crt_upd,3,1);
  g_migration_flag := l_migration_allowed;
  l_crt_upd := SUBSTR(p_crt_upd,1,1);
  hr_utility.trace('l_crt_upd ='||l_crt_upd);

  if (l_crt_upd is not null) then
  g_crt_upd      := l_crt_upd;
  end if;

  if (g_crt_upd = 'D') then
  raise e_upl_not_allowed;
  end if;

  --
  -- Initialize the Person, Assignment, Address, Phones,
  -- People Group KFF and Assignment Soft Coding KFF records.
  --


 --hr_utility.trace_on(null,'TTT');
 --hr_utility.trace('employee_category='||p_employee_category);
 --hr_utility.trace('p_address_style = ' ||p_address_style);
 --hr_utility.trace('P_PRIMARY_FLAG = ' ||P_PRIMARY_FLAG);
 --hr_utility.trace('P_ADDRESS_DATE_FROM = ' ||P_ADDRESS_DATE_FROM);

--hr_utility.trace('p_data_pump_flag .....'        || p_data_pump_flag);
--hr_utility.trace('p_batch_id .....'        || p_batch_id);
 --hr_utility.trace('p_user_person_type = ' ||p_user_person_type);
 --hr_utility.trace('p_employee_number = ' ||p_employee_number);
 --hr_utility.trace('p_assign_organization = ' ||p_assign_organization);
 --hr_utility.trace('p_apl_assignment_id = ' ||p_apl_assignment_id);
 --hr_utility.trace('p_status = ' ||p_status);
 --hr_utility.trace('p_assignment_no = ' ||p_assignment_number);
 --hr_utility.trace('p_business_group_id = ' ||p_business_group_id);
 --hr_utility.trace('p_interface_code = ' ||p_interface_code);
 --hr_utility.trace('p_gre = ' ||p_gre);
 --hr_utility.trace('ass_attribute1 = ' ||p_ass_attribute1);
 --hr_utility.trace('ass_attribute2 = ' ||p_ass_attribute2);
 --hr_utility.trace('ass_attribute3 = ' ||p_ass_attribute3);
 --hr_utility.trace('ass_attribute4 = ' ||p_ass_attribute4);
 --hr_utility.trace('ass_attribute5 = ' ||p_ass_attribute5);
 --hr_utility.trace('ass_attribute6 = ' ||p_ass_attribute6);
 --hr_utility.trace('ass_attribute7 = ' ||p_ass_attribute7);
 --hr_utility.trace('ass_attribute8 = ' ||p_ass_attribute8);
 --hr_utility.trace('ass_attribute9 = ' ||p_ass_attribute9);
 --hr_utility.trace('ass_attribute10 = ' ||p_ass_attribute10);
 --hr_utility.trace('ass_attribute11 = ' ||p_ass_attribute11);
 --hr_utility.trace('ass_attribute12 = ' ||p_ass_attribute12);
 --hr_utility.trace('ass_attribute13 = ' ||p_ass_attribute13);
 --hr_utility.trace('ass_attribute14 = ' ||p_ass_attribute14);
 --hr_utility.trace('ass_attribute15 = ' ||p_ass_attribute15);

 --hr_utility.trace('p_soft_segments = ' ||p_soft_segments);
 --hr_utility.trace('p_soft_segment1 = ' ||p_soft_segment1);
 --hr_utility.trace('p_soft_segment2 = ' ||p_soft_segment2);

 --hr_utility.trace('Person Type = ' ||p_interface_code);

  --hr_utility.trace(' Person id = ' ||P_DUP_PERSON_ID);
  --hr_utility.trace(' Party id = ' ||P_DUP_PARTY_ID);

  --hr_utility.trace(' p_adr_attribute1 = ' ||p_adr_attribute1);
  --hr_utility.trace(' p_adr_attribute2 = ' ||p_adr_attribute2);
  --hr_utility.trace(' p_adr_attribute3 = ' ||p_adr_attribute3);
  --hr_utility.trace(' p_adr_attribute_category = ' ||p_adr_attribute_category);
  --hr_utility.trace(' p_add_information16 = ' ||p_add_information16);

  --hr_utility.trace(' P_INTERNAL_LOCATION = '||P_INTERNAL_LOCATION);
  --hr_utility.trace(' P_ADJUSTED_SVC_DATE = '||P_ADJUSTED_SVC_DATE);
  --hr_utility.trace(' P_COUNTRY_OF_BIRTH = '||P_COUNTRY_OF_BIRTH);

  hr_utility.set_location(' Initializing records ', 5);
  g_per_rec    := null;   g_grp_rec    := null;
  g_scl_rec    := null;   g_asg_rec    := null;
  g_add_rec    := null;   g_phn_rec    := null;
  g_interface_code := nvl(p_interface_code,'PQP_FLEXIBLE_WEBADI_INTF');
  --
  -- Set the effective date as the Hire/Re-hire or effective passed for
  -- date the person which will be used for Assignment  also.
  --
  l_effective_date := p_date_of_hire;
  l_dup_asg_id     := 0;
  l_party_number   := p_student_number;

  --
  -- Get business group id in a pkg global variable
  --
  open  csr_bg_code (p_business_group_id);
  fetch csr_bg_code into g_leg_code
                        ,g_emp_num_gen
                        ,g_apl_num_gen
                        ,g_cwk_num_gen
                        ,g_business_group_id;
  close csr_bg_code;

  if g_debug then
   hr_utility.set_location(' l_effective_date: '||l_effective_date, 10);
   hr_utility.set_location(' g_leg_code      : '||g_leg_code, 10);
   hr_utility.set_location(' g_emp_num_gen   : '||g_emp_num_gen, 10);
   hr_utility.set_location(' l_party_number  : '||l_party_number, 10);
   hr_utility.set_location(' p_business_group_id  : '||p_business_group_id, 10);
   hr_utility.set_location(' p_interface_code  : '||p_interface_code, 10);

  end if;
  --
  -- Get the Un-Masked National Indentifier
  --
  l_national_identifier :=
   Get_UnMasked_NI
  (p_national_identifier     => p_national_identifier
  ,p_batch_id                => p_batch_id
  ,p_data_pump_batch_line_id => p_data_pump_batch_line_id
  ,p_web_adi_identifier      => p_web_adi_identifier
   );
  --
  -- Get Party Id corresponding to Party Number is entered
  --
   hr_utility.set_location('l_party_number '|| l_party_number, 30);
  if (l_party_number is not null) then
      hr_utility.set_location(' Party number is not null ', 30);
      l_sql_qry := 'select party_id
                      from hz_parties
                     where party_number ='||l_party_number;
      open  csr_get_party_id for l_sql_qry;
      fetch csr_get_party_id into l_party_id;
      close csr_get_party_id;
  end if;

  hr_utility.set_location('l_party_id '|| l_party_id, 50);
  hr_utility.set_location('Start of filling person rec ', 50);

  -- ===========================================================================
  -- ~ Person Details
  -- ===========================================================================
  g_per_rec.national_identifier         := l_national_identifier;
  g_per_rec.party_id                    := l_party_id;

  g_per_rec.business_group_id           := p_business_group_id;
  g_per_rec.last_name                   := p_last_name;
  g_per_rec.middle_names                := p_middle_name;
  g_per_rec.first_name                  := p_first_name;
  g_per_rec.suffix                      := p_suffix;
  g_per_rec.pre_name_adjunct            := p_prefix; -- p_pre_name_adjunct ?

  g_per_rec.title                       := p_title;
  g_per_rec.email_address               := p_email_address;
  g_per_rec.known_as                    := p_preferred_name;
  g_per_rec.marital_status              := p_marital_status;
  g_per_rec.sex                         := p_sex;
  g_per_rec.nationality                 := p_nationality;
  g_per_rec.date_of_birth               := trunc(p_date_of_birth);
  g_per_rec.start_date                  := trunc(p_date_of_hire);

  --Added by Dbansal
  g_per_comments := p_per_comments;
  --
  -- Set the Emp, Appl or CWK number based on the bus.group setup
  --
  EmpAplCwk_NumGen
 (p_employee_number  => p_employee_number
 ,p_applicant_number => p_applicant_number
 ,p_cwk_number       => p_cwk_number
  );
  g_per_rec.person_type_id              := p_user_person_type;
  g_per_rec.date_employee_data_verified := p_date_employee_data_verified;
  g_per_rec.expense_check_send_to_address := p_expense_check_send_to_addres;
  g_per_rec.previous_last_name          := p_previous_last_name;
  g_per_rec.registered_disabled_flag    := p_registered_disabled_flag;
  g_per_rec.vendor_id                   := p_vendor_id;
  g_per_rec.date_of_death               := trunc(p_date_of_death);
  g_per_rec.background_check_status     := p_background_check_status;
  g_per_rec.background_date_check       := p_background_date_check;
  g_per_rec.blood_type                  := p_blood_type;
  g_per_rec.correspondence_language     := p_correspondence_language;
  g_per_rec.fast_path_employee          := p_fast_path_employee;
  g_per_rec.fte_capacity                := p_fte_capacity;
  g_per_rec.honors                      := p_honors;
  g_per_rec.last_medical_test_by        := p_last_medical_test_by;
  g_per_rec.last_medical_test_date      := p_last_medical_test_date;
  g_per_rec.mailstop                    := p_mailstop;
  g_per_rec.office_number               := p_office_number;

  g_per_rec.projected_start_date        := trunc(p_projected_start_date);
  g_per_rec.resume_last_updated         := p_resume_last_updated;
  g_per_rec.student_status              := p_student_status;
  g_per_rec.work_schedule               := p_work_schedule;
  g_per_rec.benefit_group_id            := p_benefit_group_id;
  g_per_rec.receipt_of_death_cert_date  := trunc(p_receipt_of_death_cert_date);
  g_per_rec.coord_ben_med_pln_no        := p_coord_ben_med_pln_no;

  g_per_rec.coord_ben_med_ext_er        := p_coord_ben_med_ext_er;
  g_per_rec.coord_ben_med_pl_name       := p_coord_ben_med_pl_name;
  g_per_rec.coord_ben_med_insr_crr_name := p_coord_ben_med_insr_crr_name;
  g_per_rec.coord_ben_med_insr_crr_ident:= p_coord_ben_med_insr_crr_ident;
  g_per_rec.coord_ben_med_cvg_strt_dt   := p_coord_ben_med_cvg_strt_dt;
  g_per_rec.coord_ben_med_cvg_end_dt    := p_coord_ben_med_cvg_end_dt;
  g_per_rec.uses_tobacco_flag           := p_uses_tobacco_flag;
  g_per_rec.dpdnt_adoption_date         := trunc(p_dpdnt_adoption_date);

  g_per_rec.original_date_of_hire       := trunc(p_original_date_of_hire);
  g_per_rec.town_of_birth               := p_town_of_birth;
  g_per_rec.region_of_birth             := p_region_of_birth;
  g_per_rec.country_of_birth            := p_country_of_birth;
  g_per_rec.global_person_id            := p_global_person_id;
  g_per_rec.dpdnt_vlntry_svce_flag      := nvl(p_dpdnt_vlntry_svce_flag,'N');
  g_per_rec.coord_ben_no_cvg_flag       := nvl(p_coord_ben_no_cvg_flag,'N');
  g_per_rec.second_passport_exists      := nvl(p_second_passport_exists,'N');
  g_per_rec.resume_exists               := nvl(p_resume_exists,'N');
  g_per_rec.on_military_service         := nvl(p_on_military_service,'N');
  g_per_rec.internal_location           := P_INTERNAL_LOCATION; -- Added by pkagrawa


  hr_utility.set_location('Person Details assigned to record : g_per_rec ',
                                                                 60);
  -- ===========================================================================
  -- Person DF: Customer defined
  -- ===========================================================================

      --$
       temp := 'p_per_attribute';

  if p_per_attribute_category is null then
       for i in 1..30 loop
         if (temp||to_char(i)) is null then
         --hr_utility.trace('Check PER_ATT NULL'||(temp||to_char(i)));
          null;
         else
       g_per_rec.attribute_category := 'Global Data Elements';
       --hr_utility.trace('Check PER_ATT_CAT NULL - Global Val'||p_per_attribute_category);
            exit;
         end if;
        end loop;
  end if;

  if p_per_attribute_category is not null or
  g_per_rec.attribute_category = 'Global Data Elements' then

     if( p_per_attribute_category is not null ) then
     g_per_rec.attribute_category := p_per_attribute_category;
     end if;

     g_per_rec.attribute1         := p_per_attribute1;
     g_per_rec.attribute2         := p_per_attribute2;
     g_per_rec.attribute3         := p_per_attribute3;
     g_per_rec.attribute4         := p_per_attribute4;
     g_per_rec.attribute5         := p_per_attribute5;
     g_per_rec.attribute6         := p_per_attribute6;
     g_per_rec.attribute7         := p_per_attribute7;
     g_per_rec.attribute8         := p_per_attribute8;
     g_per_rec.attribute9         := p_per_attribute9;
     g_per_rec.attribute10        := p_per_attribute10;
     g_per_rec.attribute11        := p_per_attribute11;
     g_per_rec.attribute12        := p_per_attribute12;
     g_per_rec.attribute13        := p_per_attribute13;
     g_per_rec.attribute14        := p_per_attribute14;
     g_per_rec.attribute15        := p_per_attribute15;
     g_per_rec.attribute16        := p_per_attribute16;
     g_per_rec.attribute17        := p_per_attribute17;
     g_per_rec.attribute18        := p_per_attribute18;
     g_per_rec.attribute19        := p_per_attribute19;
     g_per_rec.attribute20        := p_per_attribute20;
     g_per_rec.attribute21        := p_per_attribute21;
     g_per_rec.attribute22        := p_per_attribute22;
     g_per_rec.attribute23        := p_per_attribute23;
     g_per_rec.attribute24        := p_per_attribute24;
     g_per_rec.attribute25        := p_per_attribute25;
     g_per_rec.attribute26        := p_per_attribute26;
     g_per_rec.attribute27        := p_per_attribute27;
     g_per_rec.attribute28        := p_per_attribute28;
     g_per_rec.attribute29        := p_per_attribute29;
     g_per_rec.attribute30        := p_per_attribute30;
  end if;
  hr_utility.set_location('Person DF assigned to record :g_per_rec ', 70);

  -- ===========================================================================
  -- Person DDF: Different for each legislation
  -- ===========================================================================
  open  csr_style (c_context_code => g_leg_code);
  fetch csr_style into l_dff_ctx;
  if csr_style%found then
     g_per_rec.per_information_category  :=
               nvl(p_per_information_category, g_leg_code);
     g_per_rec.per_information1   := p_per_information1;
     g_per_rec.per_information2   := p_per_information2;
     g_per_rec.per_information3   := p_per_information3;
     g_per_rec.per_information4   := p_per_information4;
     g_per_rec.per_information5   := p_per_information5;
     g_per_rec.per_information6   := p_per_information6;
     g_per_rec.per_information7   := p_per_information7;
     g_per_rec.per_information8   := p_per_information8;
     g_per_rec.per_information9   := p_per_information9;
     g_per_rec.per_information10  := p_per_information10;
     g_per_rec.per_information11  := p_per_information11;
     g_per_rec.per_information12  := p_per_information12;
     g_per_rec.per_information13  := p_per_information13;
     g_per_rec.per_information14  := p_per_information14;
     g_per_rec.per_information15  := p_per_information15;
     g_per_rec.per_information16  := p_per_information16;
     g_per_rec.per_information17  := p_per_information17;
     g_per_rec.per_information18  := p_per_information18;
     g_per_rec.per_information19  := p_per_information19;
     g_per_rec.per_information20  := p_per_information20;
     g_per_rec.per_information21  := p_per_information21;
     g_per_rec.per_information22  := p_per_information22;
     g_per_rec.per_information23  := p_per_information23;
     g_per_rec.per_information24  := p_per_information24;
     g_per_rec.per_information25  := p_per_information25;
     g_per_rec.per_information26  := p_per_information26;
     g_per_rec.per_information27  := p_per_information27;
     g_per_rec.per_information28  := p_per_information28;
     g_per_rec.per_information29  := p_per_information29;
     g_per_rec.per_information30  := p_per_information30;

  end if;
  close csr_style;

  hr_utility.set_location('Person DDF assigned to record : '||
                              p_per_information_category, 80);

  -- ===========================================================================
  -- ~ Person Address Record
  -- ===========================================================================
  if (p_address_style is not null and
      p_primary_flag  is not null and
      p_address_line1 is not null) then

     g_add_rec.party_id            := l_party_id;
     g_add_rec.business_group_id   := p_business_group_id;
     g_add_rec.address_type        := p_address_type;
     g_add_rec.comments            := p_adr_comments;
     g_add_rec.primary_flag        := p_primary_flag;
     g_add_rec.style               := p_address_style;
     g_add_rec.address_line1       := p_address_line1;
     g_add_rec.address_line2       := p_address_line2;
     g_add_rec.address_line3       := p_address_line3;
     g_add_rec.region_1            := p_region1;
     g_add_rec.region_2            := p_region2;
     g_add_rec.region_3            := p_region3;
     g_add_rec.town_or_city        := p_town_or_city;
     g_add_rec.country             := p_country;
     g_add_rec.postal_code         := p_postal_code;
     g_add_rec.telephone_number_1  := p_telephone_no1;
     g_add_rec.telephone_number_2  := p_telephone_no2;
     g_add_rec.telephone_number_3  := p_telephone_no3;
     g_add_rec.date_from           := p_address_date_from;
     g_add_rec.date_to             := p_address_date_to;
     g_add_rec.add_information13   := p_add_information13;
     g_add_rec.add_information14   := p_add_information14;
     g_add_rec.add_information15   := p_add_information15;
     g_add_rec.add_information16   := p_add_information16;
     g_add_rec.add_information17   := p_add_information17;
     g_add_rec.add_information18   := p_add_information18;
     g_add_rec.add_information19   := p_add_information19;
     g_add_rec.add_information20   := p_add_information20;

  end if;

  hr_utility.set_location('Address Style: '||p_address_style, 90);

  -- ===========================================================================
  -- Address DF: Customer defined DF
  -- ===========================================================================

   --$
     temp := 'p_adr_attribute';

  if p_adr_attribute_category is null then
       for i in 1..20 loop
         if (temp||to_char(i)) is null then
         --hr_utility.trace('Check ADDR_ATT NULL'||(temp||to_char(i)));
          null;
         else
       g_add_rec.addr_attribute_category := 'Global Data Elements';
       --hr_utility.trace('Check ADDR_ATT_CAT NULL - Global Val'||p_adr_attribute_category);
            exit;
         end if;
        end loop;
  end if;

  if p_adr_attribute_category is not null or
  g_add_rec.addr_attribute_category = 'Global Data Elements' then

     if( p_adr_attribute_category is not null ) then
     g_add_rec.addr_attribute_category := p_adr_attribute_category;
     end if;

     g_add_rec.addr_attribute1         := p_adr_attribute1;
     g_add_rec.addr_attribute2         := p_adr_attribute2;
     g_add_rec.addr_attribute3         := p_adr_attribute3;
     g_add_rec.addr_attribute4         := p_adr_attribute4;
     g_add_rec.addr_attribute5         := p_adr_attribute5;
     g_add_rec.addr_attribute6         := p_adr_attribute6;
     g_add_rec.addr_attribute7         := p_adr_attribute7;
     g_add_rec.addr_attribute8         := p_adr_attribute8;
     g_add_rec.addr_attribute9         := p_adr_attribute9;
     g_add_rec.addr_attribute10        := p_adr_attribute10;
     g_add_rec.addr_attribute11        := p_adr_attribute11;
     g_add_rec.addr_attribute12        := p_adr_attribute12;
     g_add_rec.addr_attribute13        := p_adr_attribute13;
     g_add_rec.addr_attribute14        := p_adr_attribute14;
     g_add_rec.addr_attribute15        := p_adr_attribute15;
     g_add_rec.addr_attribute16        := p_adr_attribute16;
     g_add_rec.addr_attribute17        := p_adr_attribute17;
     g_add_rec.addr_attribute18        := p_adr_attribute18;
     g_add_rec.addr_attribute19        := p_adr_attribute19;
     g_add_rec.addr_attribute20        := p_adr_attribute20;

  end if;

  hr_utility.set_location('Address DF category: '||p_adr_attribute_category, 100);

  -- ===========================================================================
  -- ~ Person Primary Assignment
  -- ===========================================================================
  g_asg_rec.assignment_id                 := p_assignment_id;
  g_asg_rec.business_group_id             := p_business_group_id;
  g_asg_rec.organization_id               := p_assign_organization;
  g_asg_rec.job_id                        := p_job;
  g_asg_rec.grade_id                      := p_grade;
  g_asg_rec.people_group_id               := p_assign_group;
  g_asg_rec.position_id                   := p_position;
  g_asg_rec.payroll_id                    := p_payroll;
  g_asg_rec.pay_basis_id                  := p_salary_basis;
  g_asg_rec.assignment_status_type_id     := p_status;
  g_asg_rec.assignment_number             := p_assignment_no;
  g_asg_rec.effective_start_date          := p_assign_eff_dt_from;
  g_asg_rec.effective_end_date            := p_assign_eff_dt_to;

  g_asg_rec.assignment_category           := p_assignment_category;
  g_asg_rec.collective_agreement_id       := p_collective_agreement;
  g_asg_rec.employee_category             := p_employee_category;
  g_asg_rec.supervisor_id                 := p_supervisor_id;
  g_asg_rec.assignment_number             := p_assignment_number;
  g_asg_rec.change_reason                 := p_change_reason;
  g_asg_rec.date_probation_end            := p_date_probation_end;
  g_asg_rec.default_code_comb_id          := p_default_code_comb_id;
  g_asg_rec.frequency                     := p_frequency;
  g_asg_rec.internal_address_line         := p_internal_address_line;
  g_asg_rec.manager_flag                  := p_manager_flag;
  g_asg_rec.normal_hours                  := p_normal_hours;
  g_asg_rec.perf_review_period            := p_perf_review_period;
  g_asg_rec.perf_review_period_frequency  := p_perf_review_period_frequency;
  g_asg_rec.probation_period              := p_probation_period;
  g_asg_rec.probation_unit                := p_probation_unit;
  g_asg_rec.sal_review_period             := p_sal_review_period;
  g_asg_rec.sal_review_period_frequency   := p_sal_review_period_frequency;
  g_asg_rec.set_of_books_id               := p_set_of_books_id;
  g_asg_rec.source_type                   := p_source_type;
  g_asg_rec.time_normal_finish            := p_time_normal_finish;
  g_asg_rec.time_normal_start             := p_time_normal_start;
  g_asg_rec.bargaining_unit_code          := p_bargaining_unit_code;
  g_asg_rec.labour_union_member_flag      := p_labour_union_member_flag;
  g_asg_rec.hourly_salaried_code          := p_hourly_salaried_code;
  g_asg_rec.location_id                   := p_location_id;

  --Added by Dbansal
  g_asg_comments   := p_asg_comments;


  --hr_utility.trace('LOCATION_ID = '||g_asg_rec.location_id);
  --hr_utility.trace('g_asg_rec.employee_category='||g_asg_rec.employee_category);
  --hr_utility.trace('g_asg_rec.assignment_category'||g_asg_rec.assignment_category);
  hr_utility.set_location('Primary Assignment details assigned to record', 110);

  -- ===========================================================================
  -- Additional Assignment Details
  -- ===========================================================================

  -- Added by Dbansal
  temp := 'p_ass_attribute';

  if p_ass_attribute_category is null then
       for i in 1..30 loop
         if (temp||to_char(i)) is null then
         --hr_utility.trace('Check ASS_ATT NULL'||(temp||to_char(i)));
          null;
         else
         g_asg_rec.ass_attribute_category := 'Global Data Elements';
       --hr_utility.trace('Check ASS_ATT_CAT NULL - Global Val'||p_ass_attribute_category);
            exit;
         end if;
        end loop;
  end if;


  if p_ass_attribute_category is not null or
  g_asg_rec.ass_attribute_category = 'Global Data Elements' then

     if( p_ass_attribute_category is not null ) then
      g_asg_rec.ass_attribute_category := p_ass_attribute_category;
     end if;

     g_asg_rec.ass_attribute1         := p_ass_attribute1;
     g_asg_rec.ass_attribute2         := p_ass_attribute2;
     g_asg_rec.ass_attribute3         := p_ass_attribute3;
     g_asg_rec.ass_attribute4         := p_ass_attribute4;
     g_asg_rec.ass_attribute5         := p_ass_attribute5;
     g_asg_rec.ass_attribute6         := p_ass_attribute6;
     g_asg_rec.ass_attribute7         := p_ass_attribute7;
     g_asg_rec.ass_attribute8         := p_ass_attribute8;
     g_asg_rec.ass_attribute9         := p_ass_attribute9;
     g_asg_rec.ass_attribute10        := p_ass_attribute10;
     g_asg_rec.ass_attribute11        := p_ass_attribute11;
     g_asg_rec.ass_attribute12        := p_ass_attribute12;
     g_asg_rec.ass_attribute13        := p_ass_attribute13;
     g_asg_rec.ass_attribute14        := p_ass_attribute14;
     g_asg_rec.ass_attribute15        := p_ass_attribute15;
     g_asg_rec.ass_attribute16        := p_ass_attribute16;
     g_asg_rec.ass_attribute17        := p_ass_attribute17;
     g_asg_rec.ass_attribute18        := p_ass_attribute18;
     g_asg_rec.ass_attribute19        := p_ass_attribute19;
     g_asg_rec.ass_attribute20        := p_ass_attribute20;
     g_asg_rec.ass_attribute21        := p_ass_attribute21;
     g_asg_rec.ass_attribute22        := p_ass_attribute22;
     g_asg_rec.ass_attribute23        := p_ass_attribute23;
     g_asg_rec.ass_attribute24        := p_ass_attribute24;
     g_asg_rec.ass_attribute25        := p_ass_attribute25;
     g_asg_rec.ass_attribute26        := p_ass_attribute26;
     g_asg_rec.ass_attribute27        := p_ass_attribute27;
     g_asg_rec.ass_attribute28        := p_ass_attribute28;
     g_asg_rec.ass_attribute29        := p_ass_attribute29;
     g_asg_rec.ass_attribute30        := p_ass_attribute30;

  end if;

  hr_utility.set_location('Assignment DF category: '||p_ass_attribute_category, 120);

  -- ===========================================================================
  -- ~ Contact Details
  -- ===========================================================================

  if p_contact_name is not null then

     g_cnt_rec.business_group_id    := p_business_group_id;
     g_cnt_rec.contact_type         := p_contact_type;
     g_cnt_rec.primary_contact_flag := p_primary_contact;
     g_cnt_rec.personal_flag        := p_personal_flag;

  end if;
  hr_utility.set_location('Contact details assigned to record ', 130);

  -- ===========================================================================
  -- ~ Person Phones
  -- ===========================================================================

  if p_phone_number is not null then
     g_phn_rec.party_id     := l_party_id;
     g_phn_rec.phone_type   := p_phone_type;
     g_phn_rec.phone_number := p_phone_number;
     g_phn_rec.date_from    := p_phone_date_from;
     g_phn_rec.date_to      := p_phone_date_to;
     g_phn_rec.parent_table := 'PER_ALL_PEOPLE_F';
  end if;
  hr_utility.set_location('Phone Details assigned to record ', 140);

  -- ===========================================================================
  -- ~ Soft Coding Keyflex field
  -- ===========================================================================
 --hr_utility.trace('p_soft_segments = ' ||p_soft_segments);
 --hr_utility.trace('p_soft_segment1 = ' ||p_soft_segment1);
 --hr_utility.trace('p_soft_segment2 = ' ||p_soft_segment2);

  g_scl_rec.concatenated_segments := p_soft_segments;
  g_scl_rec.segment1              := nvl(p_soft_segment1, p_gre);
  g_scl_rec.segment2              := p_soft_segment2;
  g_scl_rec.segment3              := p_soft_segment3;
  g_scl_rec.segment4              := p_soft_segment4;
  g_scl_rec.segment5              := p_soft_segment5;
  g_scl_rec.segment6              := p_soft_segment6;
  g_scl_rec.segment7              := p_soft_segment7;
  g_scl_rec.segment8              := p_soft_segment8;
  g_scl_rec.segment9              := p_soft_segment9;
  g_scl_rec.segment10             := p_soft_segment10;
  g_scl_rec.segment11             := p_soft_segment11;
  g_scl_rec.segment12             := p_soft_segment12;
  g_scl_rec.segment13             := p_soft_segment13;
  g_scl_rec.segment14             := p_soft_segment14;
  g_scl_rec.segment15             := p_soft_segment15;
  g_scl_rec.segment16             := p_soft_segment16;
  g_scl_rec.segment17             := p_soft_segment17;
  g_scl_rec.segment18             := p_soft_segment18;
  g_scl_rec.segment19             := p_soft_segment19;
  g_scl_rec.segment20             := p_soft_segment20;
  g_scl_rec.segment21             := p_soft_segment21;
  g_scl_rec.segment22             := p_soft_segment22;
  g_scl_rec.segment23             := p_soft_segment23;
  g_scl_rec.segment24             := p_soft_segment24;
  g_scl_rec.segment25             := p_soft_segment25;
  g_scl_rec.segment26             := p_soft_segment26;
  g_scl_rec.segment27             := p_soft_segment27;
  g_scl_rec.segment28             := p_soft_segment28;
  g_scl_rec.segment29             := p_soft_segment29;
  g_scl_rec.segment30             := p_soft_segment30;

  --Added by psengupt
  --If for the selected business Group Soft coded Flexfield is not defined
  --and still the user has entered the values then we have to set
  --the values to null so that the api does not throw an error.
  Begin
      select plr.rule_mode        into             id_flex_num
        from   pay_legislation_rules               plr,
               per_business_groups_perf            pgr
        where  plr.legislation_code                = pgr.legislation_code
        and    pgr.business_group_id               = p_business_group_id
        and    plr.rule_type                       = 'S'
        and    exists
              (select 1
               from   fnd_segment_attribute_values fsav
               where  fsav.id_flex_num             = plr.rule_mode
               and    fsav.application_id          = 800
               and    fsav.id_flex_code            = 'SCL'
               and    fsav.segment_attribute_type  = 'ASSIGNMENT'
               and    fsav.attribute_value         = 'Y')
        and    exists
              (select 1
               from   pay_legislation_rules        plr2
               where  plr2.legislation_code        = plr.legislation_code
               and    plr2.rule_type               = 'SDL'
               and    plr2.rule_mode               = 'A') ;
  Exception
  when no_data_found then
       g_scl_rec.concatenated_segments := null;
       g_scl_rec.segment1 := p_gre;
       g_scl_rec.segment2 := null;
       g_scl_rec.segment3 := null;
       g_scl_rec.segment4 := null;
       g_scl_rec.segment5 := null;
       g_scl_rec.segment6 := null;
       g_scl_rec.segment7 := null;
       g_scl_rec.segment8 := null;
       g_scl_rec.segment9 := null;
       g_scl_rec.segment10 := null;
       g_scl_rec.segment11 := null;
       g_scl_rec.segment12 := null;
       g_scl_rec.segment13 := null;
       g_scl_rec.segment14 := null;
       g_scl_rec.segment15 := null;
       g_scl_rec.segment16 := null;
       g_scl_rec.segment17 := null;
       g_scl_rec.segment18 := null;
       g_scl_rec.segment19 := null;
       g_scl_rec.segment20 := null;
       g_scl_rec.segment21 := null;
       g_scl_rec.segment22 := null;
       g_scl_rec.segment23 := null;
       g_scl_rec.segment24 := null;
       g_scl_rec.segment25 := null;
       g_scl_rec.segment26 := null;
       g_scl_rec.segment27 := null;
       g_scl_rec.segment28 := null;
       g_scl_rec.segment29 := null;
       g_scl_rec.segment30 := null;
  End;
  -------------------------------------------------------------------------

  hr_utility.set_location('Soft Coding KFF segments assigned to record: ' ||
                                       'g_scl_rec ', 150);
  -- ===========================================================================
  -- ~ People Group Keyflex
  -- ===========================================================================

  g_grp_rec.group_name   := p_concat_segments;
  g_grp_rec.segment1     := p_people_segment1;
  g_grp_rec.segment2     := p_people_segment2;
  g_grp_rec.segment3     := p_people_segment3;
  g_grp_rec.segment4     := p_people_segment4;
  g_grp_rec.segment5     := p_people_segment5;
  g_grp_rec.segment6     := p_people_segment6;
  g_grp_rec.segment7     := p_people_segment7;
  g_grp_rec.segment8     := p_people_segment8;
  g_grp_rec.segment9     := p_people_segment9;
  g_grp_rec.segment10    := p_people_segment10;
  g_grp_rec.segment11    := p_people_segment11;
  g_grp_rec.segment12    := p_people_segment12;
  g_grp_rec.segment13    := p_people_segment13;
  g_grp_rec.segment14    := p_people_segment14;
  g_grp_rec.segment15    := p_people_segment15;
  g_grp_rec.segment16    := p_people_segment16;
  g_grp_rec.segment17    := p_people_segment17;
  g_grp_rec.segment18    := p_people_segment18;
  g_grp_rec.segment19    := p_people_segment19;
  g_grp_rec.segment20    := p_people_segment20;
  g_grp_rec.segment21    := p_people_segment21;
  g_grp_rec.segment22    := p_people_segment22;
  g_grp_rec.segment23    := p_people_segment23;
  g_grp_rec.segment24    := p_people_segment24;
  g_grp_rec.segment25    := p_people_segment25;
  g_grp_rec.segment26    := p_people_segment26;
  g_grp_rec.segment27    := p_people_segment27;
  g_grp_rec.segment28    := p_people_segment28;
  g_grp_rec.segment29    := p_people_segment29;
  g_grp_rec.segment30    := p_people_segment30;

  hr_utility.set_location('People Grp KFF segments assigned to record: ' ||
                                  'g_grp_rec ', 160);
  hr_utility.trace('l_migration_allowed ='||l_migration_allowed);
--$ If migration allowed only call Chk_NI_Exists. Modification for Applicant Issue.
  --if l_migration_allowed ='Y' then
  l_person_id := Chk_NI_Exists
                (p_national_identifier => g_per_rec.national_identifier
                ,p_business_group_id   => p_business_group_id
                ,p_effective_date      => g_per_rec.start_date
                ,p_dup_person_id       => p_dup_person_id
                 );
 /* else
      if p_dup_person_id is null then
        l_person_id := Chk_NI_Exists
                (p_national_identifier => g_per_rec.national_identifier
                ,p_business_group_id   => p_business_group_id
                ,p_effective_date      => g_per_rec.start_date
                 );
      else
         g_per_rec.person_id := p_dup_person_id;
         l_person_id :=	p_dup_person_id;
      end if;
  end if;*/
  l_apl_assignment_id :=
         Get_AplAsg_Id
        (p_person_id         => g_per_rec.person_id
        ,p_apl_asg_no        => p_apl_assignment_id
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => g_per_rec.start_date
                          );

  if g_asg_rec.assignment_id is not null then
      l_apl_assignment_id := g_asg_rec.assignment_id;
  end if;

 --hr_utility.trace(' l_apl_assignment_id = ' ||l_apl_assignment_id);
 -- if g_asg_rec.assignment_id is null then
 -- g_asg_rec.assignment_id := l_apl_assignment_id;
 -- end if;

  if p_data_pump_flag = 'Y' then

  --hr_utility.trace('DataPump_API_Call');

     DataPump_API_Call
     (p_data_pump_batch_line_id => p_data_pump_batch_line_id
     ,p_batch_id                => p_batch_id
     ,p_dup_party_id            => p_dup_party_id
     ,p_dup_person_id           => l_person_id
     ,p_contact_name            => p_contact_name
     ,p_dp_mode                 => null
     ,p_adjusted_svc_date       => p_adjusted_svc_date
--$ Pass Link value in case of updating batch lines
     ,p_batch_link              => p_batch_link
     );
  else
    --hr_utility.trace('Direct_API_Call');

     Direct_API_Call
     (p_dup_person_id       => l_person_id
     ,p_dup_party_id        => p_dup_party_id
     ,p_appl_asg_id         => l_apl_assignment_id
     ,p_effective_date      => g_per_rec.start_date
     ,p_business_group_id   => p_business_group_id
     ,p_adjusted_svc_date   => p_adjusted_svc_date  -- Added by pkagrawa
      );
  end if;


    MSGENCODED := fnd_message.get_encoded();
    MSGENCODEDLEN := LENGTH(MSGENCODED);
    MSGNAMELOC := INSTR(MSGENCODED, chr(0));
    MSGAPP := SUBSTR(MSGENCODED, 1, MSGNAMELOC-1);
    MSGENCODED := SUBSTR(MSGENCODED, MSGNAMELOC+1, MSGENCODEDLEN);
    MSGENCODEDLEN := LENGTH(MSGENCODED);
    MSGTEXTLOC := INSTR(MSGENCODED, chr(0));
    MSGNAME := SUBSTR(MSGENCODED, 1, MSGTEXTLOC-1);
    if(MSGNAME <> 'CONC-SINGLE PENDING REQUEST' OR MSGAPP<>'FND') then
        fnd_message.set_name(MSGAPP, MSGNAME);
    end if;

  hr_utility.set_location('Leaving: ' || l_proc_name, 350);

exception
  when e_upl_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_upl_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc_name, 370);
    hr_utility.raise_error;
  when e_crt_per_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_crt_per_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc_name, 370);
    hr_utility.raise_error;
  when e_crt_asg_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_crt_asg_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc_name, 370);
    hr_utility.raise_error;
  when e_crt_add_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_crt_add_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc_name, 370);
    hr_utility.raise_error;
  when Others then
--   close chk_party;
   hr_utility.set_location('sqlerrm' || substr(sqlerrm,1,50), 370);
   hr_utility.set_location('sqlerrm' || substr(sqlerrm,51,100), 370);
   hr_utility.set_location('sqlerrm' || substr(sqlerrm,101,150), 370);

   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(sqlerrm,1,50) );

   --hr_utility.trace(' Final Error = '||sqlerrm);

   rollback to InsUpd_PerAsgAdd_Rec;
   hr_utility.raise_error;

end InsUpd_PerAsgAdd_Rec;

end PQP_PerAsgAdd_RIW;

/
