--------------------------------------------------------
--  DDL for Package Body HR_MX_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MX_EMPLOYEE_API" AS
/* $Header: pemxwree.pkb 120.0 2005/05/31 11:34 appldev noship $ */
--
  g_package  varchar2(33);
  g_debug    boolean;
-- -----------------------------------------------------------------------------
-- |-----------------------< create_mx_employee >------------------------------|
-- -----------------------------------------------------------------------------

PROCEDURE create_mx_employee
  (p_validate                       in      boolean  default false
  ,p_hire_date                      in      date
  ,p_business_group_id              in      number
  ,p_paternal_last_name             in      varchar2
  ,p_sex                            in      varchar2
  ,p_person_type_id                 in      number   default null
  ,p_comments                       in      varchar2 default null
  ,p_date_employee_data_verified    in      date     default null
  ,p_date_of_birth                  in      date     default null
  ,p_email_address                  in      varchar2 default null
  ,p_employee_number                in out  nocopy varchar2
  ,p_expense_check_send_to_addres   in      varchar2 default null
  ,p_first_name                     in      varchar2 default null
  ,p_known_as                       in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
  ,p_second_name                    in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_CURP_id                        in      varchar2 default null
  ,p_registered_disabled_flag       in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_vendor_id                      in      number   default null
  ,p_work_telephone                 in      varchar2 default null
  ,p_attribute_category             in      varchar2 default null
  ,p_attribute1                     in      varchar2 default null
  ,p_attribute2                     in      varchar2 default null
  ,p_attribute3                     in      varchar2 default null
  ,p_attribute4                     in      varchar2 default null
  ,p_attribute5                     in      varchar2 default null
  ,p_attribute6                     in      varchar2 default null
  ,p_attribute7                     in      varchar2 default null
  ,p_attribute8                     in      varchar2 default null
  ,p_attribute9                     in      varchar2 default null
  ,p_attribute10                    in      varchar2 default null
  ,p_attribute11                    in      varchar2 default null
  ,p_attribute12                    in      varchar2 default null
  ,p_attribute13                    in      varchar2 default null
  ,p_attribute14                    in      varchar2 default null
  ,p_attribute15                    in      varchar2 default null
  ,p_attribute16                    in      varchar2 default null
  ,p_attribute17                    in      varchar2 default null
  ,p_attribute18                    in      varchar2 default null
  ,p_attribute19                    in      varchar2 default null
  ,p_attribute20                    in      varchar2 default null
  ,p_attribute21                    in      varchar2 default null
  ,p_attribute22                    in      varchar2 default null
  ,p_attribute23                    in      varchar2 default null
  ,p_attribute24                    in      varchar2 default null
  ,p_attribute25                    in      varchar2 default null
  ,p_attribute26                    in      varchar2 default null
  ,p_attribute27                    in      varchar2 default null
  ,p_attribute28                    in      varchar2 default null
  ,p_attribute29                    in      varchar2 default null
  ,p_attribute30                    in      varchar2 default null
  ,p_maternal_last_name             in      varchar2 default null
  ,p_RFC_id                         in      varchar2 default null
  ,p_SS_id                          in      varchar2 default null
  ,p_IMSS_med_center                in      varchar2 default null
  ,p_fed_gov_affil_id               in      varchar2 default null
  ,p_mil_serv_id                    in      varchar2 default null
  ,p_date_of_death                  in      date     default null
  ,p_background_check_status        in      varchar2 default null
  ,p_background_date_check          in      date     default null
  ,p_blood_type                     in      varchar2 default null
  ,p_correspondence_language        in      varchar2 default null
  ,p_fast_path_employee             in      varchar2 default null
  ,p_fte_capacity                   in      number   default null
  ,p_honors                         in      varchar2 default null
  ,p_internal_location              in      varchar2 default null
  ,p_last_medical_test_by           in      varchar2 default null
  ,p_last_medical_test_date         in      date     default null
  ,p_mailstop                       in      varchar2 default null
  ,p_office_number                  in      varchar2 default null
  ,p_on_military_service            in      varchar2 default null
  ,p_pre_name_adjunct               in      varchar2 default null
  ,p_rehire_recommendation          in      varchar2 default null
  ,p_projected_start_date           in      date     default null
  ,p_resume_exists                  in      varchar2 default null
  ,p_resume_last_updated            in      date     default null
  ,p_second_passport_exists         in      varchar2 default null
  ,p_student_status                 in      varchar2 default null
  ,p_work_schedule                  in      varchar2 default null
  ,p_suffix                         in      varchar2 default null
  ,p_benefit_group_id               in      number   default null
  ,p_receipt_of_death_cert_date     in      date     default null
  ,p_coord_ben_med_pln_no           in      varchar2 default null
  ,p_coord_ben_no_cvg_flag          in      varchar2 default 'N'
  ,p_coord_ben_med_ext_er           in      varchar2 default null
  ,p_coord_ben_med_pl_name          in      varchar2 default null
  ,p_coord_ben_med_insr_crr_name    in      varchar2 default null
  ,p_coord_ben_med_insr_crr_ident   in      varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt      in      date     default null
  ,p_coord_ben_med_cvg_end_dt       in      date     default null
  ,p_uses_tobacco_flag              in      varchar2 default null
  ,p_dpdnt_adoption_date            in      date     default null
  ,p_dpdnt_vlntry_svce_flag         in      varchar2 default 'N'
  ,p_original_date_of_hire          in      date     default null
  ,p_adjusted_svc_date              in      date     default null
  ,p_town_of_birth                  in      varchar2 default null
  ,p_region_of_birth                in      varchar2 default null
  ,p_country_of_birth               in      varchar2 default null
  ,p_global_person_id               in      varchar2 default null
  ,p_party_id                       in      number   default null
  ,p_person_id                      out     nocopy number
  ,p_assignment_id                  out     nocopy number
  ,p_per_object_version_number      out     nocopy number
  ,p_asg_object_version_number      out     nocopy number
  ,p_per_effective_start_date       out     nocopy date
  ,p_per_effective_end_date         out     nocopy date
  ,p_full_name                      out     nocopy varchar2
  ,p_per_comment_id                 out     nocopy number
  ,p_assignment_sequence            out     nocopy number
  ,p_assignment_number              out     nocopy varchar2
  ,p_name_combination_warning       out     nocopy boolean
  ,p_assign_payroll_warning         out     nocopy boolean
  ,p_orig_hire_warning              out     nocopy boolean)
is
    -- Declare cursors and local variables
    l_proc                 VARCHAR2(72);

    --
  BEGIN

    l_proc   :=   g_package||'create_mx_employee';

    if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
    end if;

    --
    -- Validation IN addition to Row Handlers
    --
    hr_mx_utility.check_bus_grp(p_business_group_id, 'MX');

    if g_debug then
        hr_utility.set_location(l_proc, 20);
    end if;

    --
    -- Call the person business process
    --
    hr_employee_api.create_employee
      (p_validate                     => p_validate
      ,p_hire_date                    => p_hire_date
      ,p_business_group_id            => p_business_group_id
      ,p_last_name                    => p_paternal_last_name
      ,p_sex                          => p_sex
      ,p_person_type_id               => p_person_type_id
      ,p_per_comments                 => p_comments
      ,p_date_employee_data_verified  => p_date_employee_data_verified
      ,p_date_of_birth                => p_date_of_birth
      ,p_email_address                => p_email_address
      ,p_employee_number              => p_employee_number
      ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
      ,p_first_name                   => p_first_name
      ,p_known_as                     => p_known_as
      ,p_marital_status               => p_marital_status
      ,p_middle_names                 => p_second_name
      ,p_nationality                  => p_nationality
      ,p_national_identifier          => p_CURP_id
      ,p_registered_disabled_flag     => p_registered_disabled_flag
      ,p_title                        => p_title
      ,p_vendor_id                    => p_vendor_id
      ,p_work_telephone               => p_work_telephone
      ,p_attribute_category           => p_attribute_category
      ,p_attribute1                   => p_attribute1
      ,p_attribute2                   => p_attribute2
      ,p_attribute3                   => p_attribute3
      ,p_attribute4                   => p_attribute4
      ,p_attribute5                   => p_attribute5
      ,p_attribute6                   => p_attribute6
      ,p_attribute7                   => p_attribute7
      ,p_attribute8                   => p_attribute8
      ,p_attribute9                   => p_attribute9
      ,p_attribute10                  => p_attribute10
      ,p_attribute11                  => p_attribute11
      ,p_attribute12                  => p_attribute12
      ,p_attribute13                  => p_attribute13
      ,p_attribute14                  => p_attribute14
      ,p_attribute15                  => p_attribute15
      ,p_attribute16                  => p_attribute16
      ,p_attribute17                  => p_attribute17
      ,p_attribute18                  => p_attribute18
      ,p_attribute19                  => p_attribute19
      ,p_attribute20                  => p_attribute20
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_per_information1             => p_maternal_last_name
      ,p_per_information2             => p_RFC_id
      ,p_per_information3             => p_SS_id
      ,p_per_information4             => p_IMSS_med_center
      ,p_per_information5             => p_fed_gov_affil_id
      ,p_per_information6             => p_mil_serv_id
      ,p_date_of_death                => p_date_of_death
      ,p_background_check_status      => p_background_check_status
      ,p_background_date_check        => p_background_date_check
      ,p_blood_type                   => p_blood_type
      ,p_correspondence_language      => p_correspondence_language
      ,p_fast_path_employee           => p_fast_path_employee
      ,p_fte_capacity                 => p_fte_capacity
      ,p_honors                       => p_honors
      ,p_internal_location            => p_internal_location
      ,p_last_medical_test_by         => p_last_medical_test_by
      ,p_last_medical_test_date       => p_last_medical_test_date
      ,p_mailstop                     => p_mailstop
      ,p_office_number                => p_office_number
      ,p_on_military_service          => p_on_military_service
      ,p_pre_name_adjunct             => p_pre_name_adjunct
      ,p_rehire_recommendation        => p_rehire_recommendation
      ,p_projected_start_date         => p_projected_start_date
      ,p_resume_exists                => p_resume_exists
      ,p_resume_last_updated          => p_resume_last_updated
      ,p_second_passport_exists       => p_second_passport_exists
      ,p_student_status               => p_student_status
      ,p_work_schedule                => p_work_schedule
      ,p_suffix                       => p_suffix
      ,p_benefit_group_id             => p_benefit_group_id
      ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
      ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
      ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
      ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
      ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
      ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
      ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
      ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
      ,p_uses_tobacco_flag            => p_uses_tobacco_flag
      ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
      ,p_original_date_of_hire        => p_original_date_of_hire
      ,p_adjusted_svc_date            => p_adjusted_svc_date
      ,p_town_of_birth                => p_town_of_birth
      ,p_region_of_birth              => p_region_of_birth
      ,p_country_of_birth             => p_country_of_birth
      ,p_global_person_id             => p_global_person_id
      ,p_party_id                     => p_party_id
      ,p_person_id                    => p_person_id
      ,p_assignment_id                => p_assignment_id
      ,p_per_object_version_number    => p_per_object_version_number
      ,p_asg_object_version_number    => p_asg_object_version_number
      ,p_per_effective_start_date     => p_per_effective_start_date
      ,p_per_effective_end_date       => p_per_effective_end_date
      ,p_full_name                    => p_full_name
      ,p_per_comment_id               => p_per_comment_id
      ,p_assignment_sequence          => p_assignment_sequence
      ,p_assignment_number            => p_assignment_number
      ,p_name_combination_warning     => p_name_combination_warning
      ,p_assign_payroll_warning       => p_assign_payroll_warning
      ,p_orig_hire_warning            => p_orig_hire_warning);
  --
  if g_debug then
      hr_utility.set_location('Leaving: '||l_proc, 30);
  end if;
  --
  end create_mx_employee;

-- -----------------------------------------------------------------------------
-- |-----------------------< mx_hire_into_job >------------------------------|
-- -----------------------------------------------------------------------------

PROCEDURE mx_hire_into_job
  (p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_employee_number              IN OUT NOCOPY VARCHAR2
  ,p_datetrack_update_mode        IN     VARCHAR2 DEFAULT NULL
  ,p_person_type_id               IN     NUMBER   DEFAULT NULL
  ,p_CURP_id                      IN     VARCHAR2 DEFAULT NULL
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  ,p_orig_hire_warning               OUT NOCOPY BOOLEAN
  ) IS
    -- Declare cursors and local variables
    l_proc                 VARCHAR2(72);
    l_business_group_id    per_all_people_f.business_group_id%TYPE;

    --
  BEGIN

    l_proc := g_package||'mx_hire_into_job';

    if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
    end if;

    -----------------------------------------------------------------
    -- Check that the business group of the person is in 'MX'
    -- legislation.
    -----------------------------------------------------------------
    l_business_group_id := hr_mx_utility.get_bg_from_person(p_person_id);

   if g_debug then
    hr_utility.set_location(l_proc, 20);
   end if;

    hr_mx_utility.check_bus_grp(l_business_group_id, 'MX');

   if g_debug then
    hr_utility.set_location(l_proc, 30);
   end if;

    -----------------------------------------------------------------
    -- Call the person business process
    -----------------------------------------------------------------
    hr_employee_api.hire_into_job
  (p_validate                     =>	p_validate
  ,p_effective_date               =>	p_effective_date
  ,p_person_id                    =>	p_person_id
  ,p_object_version_number        =>	p_object_version_number
  ,p_employee_number              =>	p_employee_number
  ,p_datetrack_update_mode        =>	p_datetrack_update_mode
  ,p_person_type_id               =>	p_person_type_id
  ,p_national_identifier          =>	p_CURP_id
  ,p_effective_start_date         =>	p_effective_start_date
  ,p_effective_end_date           =>	p_effective_end_date
  ,p_assign_payroll_warning       =>	p_assign_payroll_warning
  ,p_orig_hire_warning            =>	p_orig_hire_warning );
   --
   if g_debug then
       hr_utility.set_location('Leaving: '||l_proc, 40);
   end if;
   --
 end mx_hire_into_job;

BEGIN

  g_package  :=  'hr_mx_employee_api.';
  g_debug    :=  hr_utility.debug_enabled;

END hr_mx_employee_api;

/
