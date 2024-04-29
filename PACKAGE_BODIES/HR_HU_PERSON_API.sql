--------------------------------------------------------
--  DDL for Package Body HR_HU_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HU_PERSON_API" as
/* $Header: peperhui.pkb 115.0 2004/03/18 01:43:16 vikgupta noship $ */
--   package variables
g_package  varchar2(33) := 'hr_hu_person_api.';


procedure update_hu_person
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
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_preferred_name               in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_ss_number                    in      varchar2 default hr_api.g_varchar2
  ,p_maiden_name                  in      varchar2 default hr_api.g_varchar2
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
  ,p_per_information_category     in      varchar2 default hr_api.g_varchar2
  ,p_mothers_maiden_name          in      varchar2 default hr_api.g_varchar2
  ,p_tax_identification_no        in      varchar2 default hr_api.g_varchar2
  ,p_personal_identity_no         in      varchar2 default hr_api.g_varchar2
  ,p_pensioner_registration_no    in      varchar2 default hr_api.g_varchar2
  ,p_contact_employers_name       in      varchar2 default hr_api.g_varchar2
  ,p_per_information6             in      varchar2 default hr_api.g_varchar2
  ,p_service_completed            in     varchar2 default hr_api.g_varchar2
  ,p_reason_not_completed         in     varchar2 default hr_api.g_varchar2
  ,p_service_start_date           in     varchar2 default hr_api.g_varchar2
  ,p_service_end_date             in     varchar2 default hr_api.g_varchar2
  ,p_mandate_code                 in     varchar2 default hr_api.g_varchar2
  ,p_mandate_date                 in     varchar2 default hr_api.g_varchar2
  ,p_command_type                 in     varchar2 default hr_api.g_varchar2
  ,p_command_color                in     varchar2 default hr_api.g_varchar2
  ,p_command_number               in     varchar2 default hr_api.g_varchar2
  ,p_rank                         in     varchar2 default hr_api.g_varchar2
  ,p_position                     in     varchar2 default hr_api.g_varchar2
  ,p_organization                 in     varchar2 default hr_api.g_varchar2
  ,p_local_department             in     varchar2 default hr_api.g_varchar2
  ,p_local_sub_department         in     varchar2 default hr_api.g_varchar2
  ,p_group                        in     varchar2 default hr_api.g_varchar2
  ,p_sub_group                    in     varchar2 default hr_api.g_varchar2
  ,p_ss_start_date                in     varchar2 default hr_api.g_varchar2
  ,p_ss_end_date                  in     varchar2 default hr_api.g_varchar2
  ,p_per_information25            in      varchar2 default hr_api.g_varchar2
  ,p_per_information26            in      varchar2 default hr_api.g_varchar2
  ,p_per_information27            in      varchar2 default hr_api.g_varchar2
  ,p_per_information28            in      varchar2 default hr_api.g_varchar2
  ,p_per_information29            in      varchar2 default hr_api.g_varchar2
  ,p_per_information30            in      varchar2 default hr_api.g_varchar2
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
  ,p_prefix                       in      varchar2 default hr_api.g_varchar2
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
  ,p_place_of_birth               in      varchar2 default hr_api.g_varchar2
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
  ) is

  -- Declare cursors and local variables
   l_proc                 varchar2(72) := g_package||'update_hu_person';


begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Call the person business process

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
  ,p_known_as                     => p_preferred_name
  ,p_marital_status               => p_marital_status
  ,p_middle_names                 => p_middle_names
  ,p_nationality                  => p_nationality
  ,p_national_identifier          => p_ss_number
  ,p_previous_last_name           => p_maiden_name
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
  ,p_attribute19                  =>p_attribute19
  ,p_attribute20                  =>p_attribute20
  ,p_attribute21                  =>p_attribute21
  ,p_attribute22                  => p_attribute22
  ,p_attribute23                  =>p_attribute23
  ,p_attribute24                  =>p_attribute24
  ,p_attribute25                  =>p_attribute25
  ,p_attribute26                  =>p_attribute26
  ,p_attribute27                  =>p_attribute27
  ,p_attribute28                  =>p_attribute28
  ,p_attribute29                  =>p_attribute29
  ,p_attribute30                  =>p_attribute30
  ,p_per_information_category     =>'HU'
  ,p_per_information1             =>p_mothers_maiden_name
  ,p_per_information2             => p_tax_identification_no
  ,p_per_information3             => p_personal_identity_no
  ,p_per_information4             =>p_pensioner_registration_no
  ,p_per_information5             =>p_contact_employers_name
  ,p_per_information6             =>p_per_information6
  ,p_per_information7             => p_service_completed
  ,p_per_information8             => p_reason_not_completed
  ,p_per_information9             => p_service_start_date
  ,p_per_information10            => p_service_end_date
  ,p_per_information11            => p_mandate_code
  ,p_per_information12            => p_mandate_date
  ,p_per_information13            => p_command_type
  ,p_per_information14            => p_command_color
  ,p_per_information15            => p_command_number
  ,p_per_information16            => p_rank
  ,p_per_information17            => p_position
  ,p_per_information18            => p_organization
  ,p_per_information19            => p_local_department
  ,p_per_information20            => p_local_sub_department
  ,p_per_information21            => p_group
  ,p_per_information22            => p_sub_group
  ,p_per_information23            => p_ss_start_date
  ,p_per_information24            => p_ss_end_date
  ,p_per_information25            =>p_per_information25
  ,p_per_information26            =>p_per_information26
  ,p_per_information27            =>p_per_information27
  ,p_per_information28            =>p_per_information28
  ,p_per_information29            =>p_per_information29
  ,p_per_information30            =>p_per_information30
  ,p_date_of_death                =>p_date_of_death
  ,p_background_check_status      =>p_background_check_status
  ,p_background_date_check        =>p_background_date_check
  ,p_blood_type                   =>p_blood_type
  ,p_correspondence_language      =>p_correspondence_language
  ,p_fast_path_employee           =>p_fast_path_employee
  ,p_fte_capacity                 =>p_fte_capacity
  ,p_hold_applicant_date_until    =>p_hold_applicant_date_until
  ,p_honors                       =>p_honors
  ,p_internal_location            =>p_internal_location
  ,p_last_medical_test_by         =>p_last_medical_test_by
  ,p_last_medical_test_date       =>p_last_medical_test_date
  ,p_mailstop                     =>p_mailstop
  ,p_office_number                =>p_office_number
  ,p_on_military_service          =>p_on_military_service
  ,p_pre_name_adjunct             => p_prefix
  ,p_projected_start_date         =>p_projected_start_date
  ,p_rehire_authorizor            =>p_rehire_authorizor
  ,p_rehire_recommendation        =>p_rehire_recommendation
  ,p_resume_exists                =>p_resume_exists
  ,p_resume_last_updated          =>p_resume_last_updated
  ,p_second_passport_exists       =>p_second_passport_exists
  ,p_student_status               =>p_student_status
  ,p_work_schedule                =>p_work_schedule
  ,p_rehire_reason                =>p_rehire_reason
  ,p_suffix                       =>p_suffix
  ,p_benefit_group_id             =>p_benefit_group_id
  ,p_receipt_of_death_cert_date   =>p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no         =>p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        =>p_coord_ben_no_cvg_flag
  ,p_coord_ben_med_ext_er         =>p_coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name        =>p_coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name  =>p_coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident =>p_coord_ben_med_insr_crr_ident
  ,p_coord_ben_med_cvg_strt_dt    =>p_coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt     =>p_coord_ben_med_cvg_end_dt
  ,p_uses_tobacco_flag            =>p_uses_tobacco_flag
  ,p_dpdnt_adoption_date          =>p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag       =>p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire        =>p_original_date_of_hire
  ,p_adjusted_svc_date            =>p_adjusted_svc_date
  ,p_town_of_birth                =>p_place_of_birth
  ,p_region_of_birth              =>p_region_of_birth
  ,p_country_of_birth             =>p_country_of_birth
  ,p_global_person_id             =>p_global_person_id
  ,p_party_id                     =>p_party_id
  ,p_npw_number                   =>p_npw_number
  ,p_effective_start_date         =>p_effective_start_date
  ,p_effective_end_date           =>p_effective_end_date
  ,p_full_name                    =>p_full_name
  ,p_comment_id                   =>p_comment_id
  ,p_name_combination_warning     =>p_name_combination_warning
  ,p_assign_payroll_warning       =>p_assign_payroll_warning
  ,p_orig_hire_warning            =>p_orig_hire_warning
  );

end update_hu_person;

END hr_hu_person_api;

/