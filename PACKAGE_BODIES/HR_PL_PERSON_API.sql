--------------------------------------------------------
--  DDL for Package Body HR_PL_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PL_PERSON_API" as
/* $Header: peperpli.pkb 120.1 2005/09/27 00:08:30 mseshadr noship $ */

--   package variables
g_package  varchar2(33);


procedure update_pl_person
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
  ,p_pesel_value                  in      varchar2 default hr_api.g_varchar2
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
  ,p_nip_value                    in      varchar2 default hr_api.g_varchar2
  ,p_per_information2             in      varchar2 default hr_api.g_varchar2
  ,p_per_information3             in      varchar2 default hr_api.g_varchar2
  ,p_per_information4             in      varchar2 default hr_api.g_varchar2
  ,p_per_information5             in      varchar2 default hr_api.g_varchar2
  ,p_per_information6             in      varchar2 default hr_api.g_varchar2
  ,p_per_information7             in      varchar2 default hr_api.g_varchar2
  ,p_per_information8             in      varchar2 default hr_api.g_varchar2
  ,p_per_information9             in      varchar2 default hr_api.g_varchar2
  ,p_per_information10            in      varchar2 default hr_api.g_varchar2
  ,p_per_information11            in      varchar2 default hr_api.g_varchar2
  ,p_per_information12            in      varchar2 default hr_api.g_varchar2
  ,p_per_information13            in      varchar2 default hr_api.g_varchar2
  ,p_per_information14            in      varchar2 default hr_api.g_varchar2
  ,p_per_information15            in      varchar2 default hr_api.g_varchar2
  ,p_per_information16            in      varchar2 default hr_api.g_varchar2
  ,p_per_information17            in      varchar2 default hr_api.g_varchar2
  ,p_per_information18            in      varchar2 default hr_api.g_varchar2
  ,p_per_information19            in      varchar2 default hr_api.g_varchar2
  ,p_per_information20            in      varchar2 default hr_api.g_varchar2
  ,p_per_information21            in      varchar2 default hr_api.g_varchar2
  ,p_per_information22            in      varchar2 default hr_api.g_varchar2
  ,p_per_information23            in      varchar2 default hr_api.g_varchar2
  ,p_per_information24            in      varchar2 default hr_api.g_varchar2
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
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
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
   l_proc varchar2(72);


begin
g_package := 'hr_pl_person_api.';
l_proc := g_package||'update_pl_person old';
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Call the person business process
/*4340576 Replaced with call to new overloaded procedure
hr_person_api.update_person*/
hr_pl_person_api.update_pl_person
  (p_validate                      =>p_validate
  ,p_effective_date                =>p_effective_date
  ,p_datetrack_update_mode         =>p_datetrack_update_mode
  ,p_person_id                     =>p_person_id
  ,p_object_version_number         =>p_object_version_number
  ,p_person_type_id                =>p_person_type_id
  ,p_last_name                     =>p_last_name
  ,p_applicant_number              =>p_applicant_number                                                              ,p_comments                      =>p_comments
  ,p_date_employee_data_verified   =>p_date_employee_data_verified
  ,p_date_of_birth                 =>p_date_of_birth
  ,p_email_address                 =>p_email_address
  ,p_employee_number               =>p_employee_number
  ,p_expense_check_send_to_addres  =>p_expense_check_send_to_addres
  ,p_first_name                    =>p_first_name
  ,p_preferred_name                =>p_preferred_name
  ,p_marital_status                =>p_marital_status
  ,p_middle_names                  =>p_middle_names
  ,p_nationality                   =>p_nationality
  ,p_pesel                         =>p_pesel_value
  ,p_maiden_name                   =>p_maiden_name
  ,p_registered_disabled_flag      =>p_registered_disabled_flag
  ,p_sex                           =>p_sex
  ,p_title                         =>p_title
  ,p_vendor_id                     =>p_vendor_id
  ,p_work_telephone                =>p_work_telephone
  ,p_attribute_category            =>p_attribute_category
  ,p_attribute1                    =>p_attribute1
  ,p_attribute2                    =>p_attribute2
  ,p_attribute3                    =>p_attribute3
  ,p_attribute4                    =>p_attribute4
  ,p_attribute5                    =>p_attribute5
  ,p_attribute6                    =>p_attribute6
  ,p_attribute7                    =>p_attribute7
  ,p_attribute8                    =>p_attribute8
  ,p_attribute9                    =>p_attribute9
  ,p_attribute10                   =>p_attribute10
  ,p_attribute11                   =>p_attribute11
  ,p_attribute12                   =>p_attribute12
  ,p_attribute13                   =>p_attribute13
  ,p_attribute14                   =>p_attribute14
  ,p_attribute15                   =>p_attribute15
  ,p_attribute16                   =>p_attribute16
  ,p_attribute17                   =>p_attribute17
  ,p_attribute18                   =>p_attribute18
  ,p_attribute19                   =>p_attribute19
  ,p_attribute20                   =>p_attribute20
  ,p_attribute21                   =>p_attribute21
  ,p_attribute22                   =>p_attribute22
  ,p_attribute23                   =>p_attribute23
  ,p_attribute24                   =>p_attribute24
  ,p_attribute25                   =>p_attribute25
  ,p_attribute26                   =>p_attribute26
  ,p_attribute27                   =>p_attribute27
  ,p_attribute28                   =>p_attribute28
  ,p_attribute29                   =>p_attribute29
  ,p_attribute30                   =>p_attribute30
  ,p_per_information_category      =>p_per_information_category
  ,p_nip                           =>p_nip_value
  ,p_insured_by_employee           =>p_per_information2
  ,p_inheritor                     =>p_per_information3
  ,p_oldage_pension_rights         =>p_per_information4
  ,p_national_fund_of_health       =>p_per_information5
  ,p_tax_office                    =>p_per_information6
  ,p_legal_employer                =>p_per_information7
  ,p_citizenship                   =>p_per_information8
  ,p_date_of_death                 =>p_date_of_death
  ,p_background_check_status       =>p_background_check_status
  ,p_background_date_check         =>p_background_date_check
  ,p_blood_type                    =>p_blood_type
  ,p_correspondence_language       =>p_correspondence_language
  ,p_fast_path_employee            =>p_fast_path_employee
  ,p_fte_capacity                  =>p_fte_capacity
  ,p_hold_applicant_date_until     =>p_hold_applicant_date_until
  ,p_honors                        =>p_honors
  ,p_internal_location             =>p_internal_location
  ,p_last_medical_test_by          =>p_last_medical_test_by
  ,p_last_medical_test_date        =>p_last_medical_test_date
  ,p_mailstop                      =>p_mailstop
  ,p_office_number                 =>p_office_number
  ,p_on_military_service           =>p_on_military_service
  ,p_prefix                        =>p_prefix
  ,p_projected_start_date          =>p_projected_start_date
  ,p_rehire_authorizor             =>p_rehire_authorizor
  ,p_rehire_recommendation         =>p_rehire_recommendation
  ,p_resume_exists                 =>p_resume_exists
  ,p_resume_last_updated           =>p_resume_last_updated
  ,p_second_passport_exists        =>p_second_passport_exists
  ,p_student_status                =>p_student_status
  ,p_work_schedule                 =>p_work_schedule
  ,p_rehire_reason                 =>p_rehire_reason
  ,p_suffix                        =>p_suffix
  ,p_benefit_group_id              =>p_benefit_group_id
  ,p_receipt_of_death_cert_date    =>p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no          =>p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag         =>p_coord_ben_no_cvg_flag
  ,p_coord_ben_med_ext_er          =>p_coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name         =>p_coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name   =>p_coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident  =>p_coord_ben_med_insr_crr_ident
  ,p_coord_ben_med_cvg_strt_dt     =>p_coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt      =>p_coord_ben_med_cvg_end_dt
  ,p_uses_tobacco_flag             =>p_uses_tobacco_flag
  ,p_dpdnt_adoption_date           =>p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag        =>p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire         =>p_original_date_of_hire
  ,p_adjusted_svc_date             =>p_adjusted_svc_date
  ,p_town_of_birth                 =>p_town_of_birth
  ,p_region_of_birth               =>p_region_of_birth
  ,p_country_of_birth              =>p_country_of_birth
  ,p_global_person_id              =>p_global_person_id
  ,p_party_id                      =>p_party_id
  ,p_npw_number                    =>p_npw_number
  ,p_effective_start_date          =>p_effective_start_date
  ,p_effective_end_date            =>p_effective_end_date
  ,p_full_name                     =>p_full_name
  ,p_comment_id                    =>p_comment_id
  ,p_name_combination_warning      =>p_name_combination_warning
  ,p_assign_payroll_warning        =>p_assign_payroll_warning
  ,p_orig_hire_warning             =>p_orig_hire_warning );



end update_pl_person;

procedure update_pl_person
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
  ,p_pesel                        in      varchar2 default hr_api.g_varchar2
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
  ,p_nip                          in      varchar2 default hr_api.g_varchar2
  ,p_insured_by_employee          in      varchar2 default hr_api.g_varchar2
  ,p_inheritor                    in      varchar2 default hr_api.g_varchar2
  ,p_oldage_pension_rights        in      varchar2 default hr_api.g_varchar2
  ,p_national_fund_of_health      in      varchar2 default hr_api.g_varchar2
  ,p_tax_office                   in      varchar2 default hr_api.g_varchar2
  ,p_legal_employer               in      varchar2 default hr_api.g_varchar2
  ,p_citizenship                  in      varchar2 default hr_api.g_varchar2
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
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
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
  )is
  -- Declare cursors and local variables
   l_proc varchar2(72);

begin
g_package := 'hr_pl_person_api.';
l_proc := g_package||'update_pl_person';
hr_utility.set_location('Entering:'|| l_proc, 5);
  -- Call the person business process
 hr_person_api.update_person
 (p_validate                      => p_validate
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
  ,p_national_identifier          => p_pesel
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
  ,p_per_information_category     => 'PL'
  ,p_per_information1             => p_nip
  ,p_per_information2             => p_insured_by_employee
  ,p_per_information3             => p_inheritor
  ,p_per_information4             => p_oldage_pension_rights
  ,p_per_information5             => p_national_fund_of_health
  ,p_per_information6             => p_tax_office
  ,p_per_information7             => p_legal_employer
  ,p_per_information8             => p_citizenship
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
  ,p_pre_name_adjunct             => p_prefix
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
  ,p_town_of_birth                => p_town_of_birth
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

 END update_pl_person;
END hr_pl_person_api;

/
