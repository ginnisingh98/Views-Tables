--------------------------------------------------------
--  DDL for Package Body HR_IN_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IN_PERSON_API" AS
/* $Header: peperini.pkb 120.1 2007/10/05 11:24:33 sivanara noship $ */
g_package  VARCHAR2(33) := 'hr_in_person_api.';
g_trace boolean ;

-- ----------------------------------------------------------------------------
-- |---------------------------< update_in_person >------------------------------|
-- ----------------------------------------------------------------------------

procedure update_in_person
  (p_validate                     in      boolean   default false
  ,p_effective_date               in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in   out nocopy varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_alias_name                   in      varchar2 default hr_api.g_varchar2 --Bugfix 3762728
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_ni_number                    in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
  ,p_registered_disabled_flag     in      varchar2 default hr_api.g_varchar2
  ,p_sex                          in      varchar2 default hr_api.g_varchar2
  ,p_title                        in      varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in      number   default hr_api.g_number
  ,p_work_telephone               in      varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in      varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in      varchar2 default hr_api.g_varchar2
  ,p_pan                          in      varchar2 default hr_api.g_varchar2
  ,p_pan_af                       in      varchar2 default hr_api.g_varchar2
  ,p_ex_serviceman                in      varchar2 default hr_api.g_varchar2 --Bugfix 3762728
  ,p_resident_status              in      varchar2 default hr_api.g_varchar2
  ,p_pf_number                    in      varchar2 default hr_api.g_varchar2
  ,p_esi_number                   in      varchar2 default hr_api.g_varchar2
  ,p_superannuation_number        in      varchar2 default hr_api.g_varchar2
  ,p_group_ins_number             in      varchar2 default hr_api.g_varchar2
  ,p_gratuity_number              in      varchar2 default hr_api.g_varchar2
  ,p_pension_number          	  in      varchar2 default hr_api.g_varchar2
  ,p_NSSN                	  in      varchar2 default hr_api.g_varchar2--Bugfix 6368899.
 -- ,p_employee_category            in      varchar2 default hr_api.g_varchar2
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_honors                       in      varchar2 default hr_api.g_varchar2
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_ext_er         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_pl_name        in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_name  in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_ident in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_cvg_strt_dt    in      date     default hr_api.g_date
  ,p_coord_ben_med_cvg_end_dt     in      date     default hr_api.g_date
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_adjusted_svc_date            in      date     default hr_api.g_date
  ,p_place_of_birth               in      varchar2 default hr_api.g_varchar2 --Bugfix 3762728
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_party_id                     in      number   default hr_api.g_number
  ,p_npw_number                   in      varchar2 default hr_api.g_varchar2
  ,p_effective_start_date         out nocopy     date
  ,p_effective_end_date           out nocopy     date
  ,p_full_name                    out nocopy     varchar2
  ,p_comment_id                   out nocopy     number
  ,p_name_combination_warning     out nocopy     boolean
  ,p_assign_payroll_warning       out nocopy     boolean
  ,p_orig_hire_warning            out nocopy     boolean
  ) IS
  -- Declare cursors and local variables
  --
      l_proc                 VARCHAR2(72) ;
      l_legislation_code     per_business_groups.legislation_code%type;
      cursor check_legislation
          (p_person_id      per_people_f.person_id%TYPE,
           p_effective_date date
          ) IS
          select business_group_id
            from per_people_f
           where person_id  = p_person_id
             and p_effective_date
         between effective_start_date and effective_end_date;

      l_pan_af VARCHAR2(30);
      l_pan    VARCHAR2(30);
  --
  BEGIN
  l_proc  := g_package||'update_in_person';
  g_trace := hr_utility.debug_enabled ;

  if g_trace then
    hr_utility.set_location('Entering: '||l_proc, 10);
  end if ;

  open check_legislation(p_person_id, p_effective_date);
    fetch check_legislation into l_legislation_code;

    if check_legislation%notfound then
      close check_legislation;
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    end if;

  close check_legislation;

  if  hr_general2.IS_BG(l_legislation_code ,'IN') = false then
    hr_utility.set_message(800, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;

  if g_trace then
     hr_utility.set_location(l_proc, 20);
  end if ;


-- Bugfix 3762728 Start

  l_pan :=p_pan;
  l_pan_af :=p_pan_af;


IF  l_pan <>hr_api.g_varchar2 and l_pan_af <>hr_api.g_varchar2 THEN
  NULL;
ELSIF l_pan <>hr_api.g_varchar2 THEN
  l_pan_af :='';
ELSIF l_pan_af <>hr_api.g_varchar2 THEN
  l_pan :='';
END IF;

-- Bugfix 3762728 End
  hr_person_api.update_person
   (p_validate                     => p_validate
   ,p_effective_date               => p_effective_date
   ,p_datetrack_update_mode        => p_datetrack_update_mode
   ,p_person_id                    => p_person_id
   ,p_object_version_number        => p_object_version_number
   ,p_person_type_id               => p_person_type_id
   ,p_last_name                    => p_last_name
   ,p_applicant_number             => p_applicant_number
   ,p_comments                     => p_comments
   ,p_date_employee_data_verified  => p_date_employee_data_verified
   ,p_date_of_birth                => p_date_of_birth
   ,p_email_address                => p_email_address
   ,p_employee_number              => p_employee_number
   ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
   ,p_first_name                   => p_first_name
   ,p_known_as                     => p_alias_name  --Bugfix 3762728
   ,p_marital_status               => p_marital_status
   ,p_middle_names                 => p_middle_names
   ,p_nationality                  => p_nationality
   ,p_national_identifier          => p_ni_number
   ,p_previous_last_name           => p_previous_last_name
   ,p_registered_disabled_flag     => p_registered_disabled_flag
   ,p_sex                          => p_sex
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
   ,p_per_information_category     => 'IN'
   ,p_per_information4             => l_pan
   ,p_per_information5             => l_pan_af
   ,p_per_information6             => p_ex_serviceman    --Bugfix 3762728
   ,p_per_information7             => p_resident_status
   ,p_per_information8             => p_pf_number
   ,p_per_information9             => p_esi_number
   ,p_per_information10            => p_superannuation_number
   ,p_per_information11            => p_group_ins_number
   ,p_per_information12            => p_gratuity_number
   ,p_per_information13  	   => p_pension_number
   ,p_per_information15  	   => p_NSSN
   --,p_per_information14            => p_employee_category
   ,p_date_of_death                => p_date_of_death
   ,p_background_check_status      => p_background_check_status
   ,p_background_date_check        => p_background_date_check
   ,p_blood_type                   => p_blood_type
   ,p_correspondence_language      => p_correspondence_language
   ,p_fast_path_employee           => p_fast_path_employee
   ,p_fte_capacity                 => p_fte_capacity
   ,p_hold_applicant_date_until    => p_hold_applicant_date_until
   ,p_honors                       => p_honors
   ,p_internal_location            => p_internal_location
   ,p_last_medical_test_by         => p_last_medical_test_by
   ,p_last_medical_test_date       => p_last_medical_test_date
   ,p_mailstop                     => p_mailstop
   ,p_office_number                => p_office_number
   ,p_on_military_service          => p_on_military_service
   ,p_pre_name_adjunct             => p_pre_name_adjunct
   ,p_projected_start_date         => p_projected_start_date
   ,p_rehire_authorizor            => p_rehire_authorizor
   ,p_rehire_recommendation        => p_rehire_recommendation
   ,p_resume_exists                => p_resume_exists
   ,p_resume_last_updated          => p_resume_last_updated
   ,p_second_passport_exists       => p_second_passport_exists
   ,p_student_status               => p_student_status
   ,p_work_schedule                => p_work_schedule
   ,p_rehire_reason                => p_rehire_reason
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
   ,p_town_of_birth                => p_place_of_birth  --Bugfix 3762728
   ,p_region_of_birth              => p_region_of_birth
   ,p_country_of_birth             => p_country_of_birth
   ,p_global_person_id             => p_global_person_id
   ,p_party_id                     => p_party_id
   ,p_npw_number                   => p_npw_number
   ,p_effective_start_date         => p_effective_start_date
   ,p_effective_end_date           => p_effective_end_date
   ,p_full_name                    => p_full_name
   ,p_comment_id                   => p_comment_id
   ,p_name_combination_warning     => p_name_combination_warning
   ,p_assign_payroll_warning       => p_assign_payroll_warning
   ,p_orig_hire_warning            => p_orig_hire_warning
  );

  IF g_trace THEN
    hr_utility.set_location('Leaving: '||l_proc, 30);
  END IF ;

  END update_in_person ;
  END hr_in_person_api ;

/