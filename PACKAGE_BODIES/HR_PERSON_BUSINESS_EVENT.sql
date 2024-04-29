--------------------------------------------------------
--  DDL for Package Body HR_PERSON_BUSINESS_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_BUSINESS_EVENT" as
/* $Header: peperbev.pkb 120.1.12010000.2 2008/08/27 14:59:58 srgnanas ship $ */

procedure person_business_event(
p_event                        in  varchar2,
p_datetrack_update_mode        in  varchar2 default hr_api.g_update,
p_system_person_type           in  varchar2,
p_effective_date               in  date,
p_person_id                    in  number,
p_object_version_number        in  number,
p_person_type_id               in  number   default hr_api.g_number,
p_last_name                    in  varchar2 default hr_api.g_varchar2,
p_applicant_number             in  varchar2 default hr_api.g_varchar2,
p_comments                     in  varchar2 default hr_api.g_varchar2,
p_date_employee_data_verified  in  date default hr_api.g_date,
p_date_of_birth                in  date default hr_api.g_date,
p_email_address                in  varchar2 default hr_api.g_varchar2,
p_employee_number              in  varchar2 default hr_api.g_varchar2,
p_expense_check_send_to_addres in  varchar2 default hr_api.g_varchar2,
p_first_name                   in  varchar2 default hr_api.g_varchar2,
p_known_as                     in  varchar2 default hr_api.g_varchar2,
p_marital_status               in  varchar2 default hr_api.g_varchar2,
p_middle_names                 in  varchar2 default hr_api.g_varchar2,
p_nationality                  in  varchar2 default hr_api.g_varchar2,
p_national_identifier          in  varchar2 default hr_api.g_varchar2,
p_previous_last_name           in  varchar2 default hr_api.g_varchar2,
p_registered_disabled_flag     in  varchar2 default hr_api.g_varchar2,
p_sex                          in  varchar2 default hr_api.g_varchar2,
p_title                        in  varchar2 default hr_api.g_varchar2,
p_vendor_id                    in  number   default hr_api.g_number,
p_attribute_category           in  varchar2 default hr_api.g_varchar2,
p_attribute1                   in  varchar2 default hr_api.g_varchar2,
p_attribute2                   in  varchar2 default hr_api.g_varchar2,
p_attribute3                   in  varchar2 default hr_api.g_varchar2,
p_attribute4                   in  varchar2 default hr_api.g_varchar2,
p_attribute5                   in  varchar2 default hr_api.g_varchar2,
p_attribute6                   in  varchar2 default hr_api.g_varchar2,
p_attribute7                   in  varchar2 default hr_api.g_varchar2,
p_attribute8                   in  varchar2 default hr_api.g_varchar2,
p_attribute9                   in  varchar2 default hr_api.g_varchar2,
p_attribute10                  in  varchar2 default hr_api.g_varchar2,
p_attribute11                  in  varchar2 default hr_api.g_varchar2,
p_attribute12                  in  varchar2 default hr_api.g_varchar2,
p_attribute13                  in  varchar2 default hr_api.g_varchar2,
p_attribute14                  in  varchar2 default hr_api.g_varchar2,
p_attribute15                  in  varchar2 default hr_api.g_varchar2,
p_attribute16                  in  varchar2 default hr_api.g_varchar2,
p_attribute17                  in  varchar2 default hr_api.g_varchar2,
p_attribute18                  in  varchar2 default hr_api.g_varchar2,
p_attribute19                  in  varchar2 default hr_api.g_varchar2,
p_attribute20                  in  varchar2 default hr_api.g_varchar2,
p_attribute21                  in  varchar2 default hr_api.g_varchar2,
p_attribute22                  in  varchar2 default hr_api.g_varchar2,
p_attribute23                  in  varchar2 default hr_api.g_varchar2,
p_attribute24                  in  varchar2 default hr_api.g_varchar2,
p_attribute25                  in  varchar2 default hr_api.g_varchar2,
p_attribute26                  in  varchar2 default hr_api.g_varchar2,
p_attribute27                  in  varchar2 default hr_api.g_varchar2,
p_attribute28                  in  varchar2 default hr_api.g_varchar2,
p_attribute29                  in  varchar2 default hr_api.g_varchar2,
p_attribute30                  in  varchar2 default hr_api.g_varchar2,
p_per_information_category     in  varchar2 default hr_api.g_varchar2,
p_per_information1             in  varchar2 default hr_api.g_varchar2,
p_per_information2             in  varchar2 default hr_api.g_varchar2,
p_per_information3             in  varchar2 default hr_api.g_varchar2,
p_per_information4             in  varchar2 default hr_api.g_varchar2,
p_per_information5             in  varchar2 default hr_api.g_varchar2,
p_per_information6             in  varchar2 default hr_api.g_varchar2,
p_per_information7             in  varchar2 default hr_api.g_varchar2,
p_per_information8             in  varchar2 default hr_api.g_varchar2,
p_per_information9             in  varchar2 default hr_api.g_varchar2,
p_per_information10            in  varchar2 default hr_api.g_varchar2,
p_per_information11            in  varchar2 default hr_api.g_varchar2,
p_per_information12            in  varchar2 default hr_api.g_varchar2,
p_per_information13            in  varchar2 default hr_api.g_varchar2,
p_per_information14            in  varchar2 default hr_api.g_varchar2,
p_per_information15            in  varchar2 default hr_api.g_varchar2,
p_per_information16            in  varchar2 default hr_api.g_varchar2,
p_per_information17            in  varchar2 default hr_api.g_varchar2,
p_per_information18            in  varchar2 default hr_api.g_varchar2,
p_per_information19            in  varchar2 default hr_api.g_varchar2,
p_per_information20            in  varchar2 default hr_api.g_varchar2,
p_per_information21            in  varchar2 default hr_api.g_varchar2,
p_per_information22            in  varchar2 default hr_api.g_varchar2,
p_per_information23            in  varchar2 default hr_api.g_varchar2,
p_per_information24            in  varchar2 default hr_api.g_varchar2,
p_per_information25            in  varchar2 default hr_api.g_varchar2,
p_per_information26            in  varchar2 default hr_api.g_varchar2,
p_per_information27            in  varchar2 default hr_api.g_varchar2,
p_per_information28            in  varchar2 default hr_api.g_varchar2,
p_per_information29            in  varchar2 default hr_api.g_varchar2,
p_per_information30            in  varchar2 default hr_api.g_varchar2,
p_date_of_death                in  date default hr_api.g_date,
p_background_check_status      in  varchar2 default hr_api.g_varchar2,
p_background_date_check        in  date default hr_api.g_date,
p_blood_type                   in  varchar2 default hr_api.g_varchar2,
p_correspondence_language      in  varchar2 default hr_api.g_varchar2,
p_fast_path_employee           in  varchar2 default hr_api.g_varchar2,
p_fte_capacity                 in  number default hr_api.g_number,
p_hold_applicant_date_until    in  date default hr_api.g_date,
p_honors                       in  varchar2 default hr_api.g_varchar2,
p_internal_location            in  varchar2 default hr_api.g_varchar2,
p_last_medical_test_by         in  varchar2 default hr_api.g_varchar2,
p_last_medical_test_date       in  date default hr_api.g_date,
p_mailstop                     in  varchar2 default hr_api.g_varchar2,
p_office_number                in  varchar2 default hr_api.g_varchar2,
p_on_military_service          in  varchar2 default hr_api.g_varchar2,
p_pre_name_adjunct             in  varchar2 default hr_api.g_varchar2,
p_projected_start_date         in  date default hr_api.g_date,
p_rehire_authorizor            in  varchar2 default hr_api.g_varchar2,
p_rehire_recommendation        in  varchar2 default hr_api.g_varchar2,
p_resume_exists                in  varchar2 default hr_api.g_varchar2,
p_resume_last_updated          in  date default hr_api.g_date,
p_second_passport_exists       in  varchar2 default hr_api.g_varchar2,
p_student_status               in  varchar2 default hr_api.g_varchar2,
p_work_schedule                in  varchar2 default hr_api.g_varchar2,
p_rehire_reason                in  varchar2 default hr_api.g_varchar2,
p_suffix                       in  varchar2 default hr_api.g_varchar2,
p_benefit_group_id             in  number default hr_api.g_number,
p_receipt_of_death_cert_date   in  date default hr_api.g_date,
p_coord_ben_med_pln_no         in  varchar2 default hr_api.g_varchar2,
p_coord_ben_no_cvg_flag        in  varchar2 default hr_api.g_varchar2,
p_coord_ben_med_ext_er         in  varchar2 default hr_api.g_varchar2,
p_coord_ben_med_pl_name        in  varchar2 default hr_api.g_varchar2,
p_coord_ben_med_insr_crr_name  in  varchar2 default hr_api.g_varchar2,
p_coord_ben_med_insr_crr_ident in  varchar2 default hr_api.g_varchar2,
p_coord_ben_med_cvg_strt_dt    in  date default hr_api.g_date,
p_coord_ben_med_cvg_end_dt     in  date default hr_api.g_date,
p_uses_tobacco_flag            in  varchar2 default hr_api.g_varchar2,
p_dpdnt_adoption_date          in  date default hr_api.g_date,
p_dpdnt_vlntry_svce_flag       in  varchar2 default hr_api.g_varchar2,
p_original_date_of_hire        in  date default hr_api.g_date,
p_adjusted_svc_date            in  date default hr_api.g_date,
p_effective_start_date         in  date default hr_api.g_date,
p_effective_end_date           in  date default hr_api.g_date,
p_full_name                    in  varchar2 default hr_api.g_varchar2,
p_comment_id                   in  number default hr_api.g_number,
p_town_of_birth                in  varchar2 default hr_api.g_varchar2,
p_region_of_birth              in  varchar2 default hr_api.g_varchar2,
p_country_of_birth             in  varchar2 default hr_api.g_varchar2,
p_global_person_id             in  varchar2 default hr_api.g_varchar2,
p_party_id                     in  number default hr_api.g_number,
p_npw_number                   in  varchar2 default hr_api.g_varchar2,
p_name_combination_warning     in  boolean default false,
p_assign_payroll_warning       in  boolean default false,
p_orig_hire_warning            in  boolean default false
)
is

l_proc varchar2(72) := 'raise_person_business_event';

begin
hr_utility.set_location('Entering: raise_person_business_event:'|| l_proc, 10);
if p_event = 'UPDATE' then
hr_utility.set_location('Entering: p_event=UPDATE:'|| l_proc, 20);
   	hr_person_be1.update_person_a(
           p_effective_date               => p_effective_date
    	  ,p_person_id                    => p_person_id
    	  ,p_person_type_id               => p_person_type_id
    	  ,p_last_name                    => p_last_name
          ,p_comments                     => p_comments
          ,p_date_employee_data_verified  => p_date_employee_data_verified
          ,p_date_of_birth                => p_date_of_birth
          ,p_email_address                => p_email_address
          ,p_applicant_number             => p_applicant_number
          ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
          ,p_first_name                   => p_first_name
          ,p_known_as                     => p_known_as
          ,p_marital_status               => p_marital_status
          ,p_middle_names                 => p_middle_names
          ,p_nationality                  => p_nationality
          ,p_national_identifier          => p_national_identifier
          ,p_previous_last_name           => p_previous_last_name
          ,p_datetrack_update_mode        => p_datetrack_update_mode
          ,p_registered_disabled_flag     => p_registered_disabled_flag
          ,p_npw_number                   => p_npw_number
          ,p_sex                          => p_sex
          ,p_title                        => p_title
          ,p_vendor_id                    => p_vendor_id
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
          ,p_per_information_category     => p_per_information_category
          ,p_per_information1             => p_per_information1
          ,p_per_information2             => p_per_information2
          ,p_per_information3             => p_per_information3
          ,p_per_information4             => p_per_information4
          ,p_per_information5             => p_per_information5
          ,p_per_information6             => p_per_information6
          ,p_per_information7             => p_per_information7
          ,p_per_information8             => p_per_information8
          ,p_per_information9             => p_per_information9
          ,p_per_information10            => p_per_information10
          ,p_per_information11            => p_per_information11
          ,p_per_information12            => p_per_information12
          ,p_per_information13            => p_per_information13
          ,p_per_information14            => p_per_information14
          ,p_per_information15            => p_per_information15
          ,p_per_information16            => p_per_information16
          ,p_per_information17            => p_per_information17
          ,p_per_information18            => p_per_information18
          ,p_per_information19            => p_per_information19
          ,p_per_information20            => p_per_information20
          ,p_per_information21            => p_per_information21
          ,p_per_information22            => p_per_information22
          ,p_per_information23            => p_per_information23
          ,p_per_information24            => p_per_information24
          ,p_per_information25            => p_per_information25
          ,p_per_information26            => p_per_information26
          ,p_per_information27            => p_per_information27
          ,p_per_information28            => p_per_information28
          ,p_per_information29            => p_per_information29
          ,p_per_information30            => p_per_information30
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
          ,p_adjusted_svc_date            => p_adjusted_svc_date
          ,p_mailstop                     => p_mailstop
          ,p_office_number                => p_office_number
          ,p_on_military_service          => p_on_military_service
          ,p_pre_name_adjunct             => p_pre_name_adjunct
          ,p_projected_start_date         => p_projected_start_date
          ,p_rehire_recommendation        => p_rehire_recommendation
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
          ,p_rehire_reason                => p_rehire_reason
          ,p_rehire_authorizor            => p_rehire_authorizor
          ,p_town_of_birth                => p_town_of_birth
          ,p_region_of_birth              => p_region_of_birth
          ,p_country_of_birth             => p_country_of_birth
          ,p_global_person_id             => p_global_person_id
          ,p_party_id                     => p_party_id
          ,p_employee_number              => p_employee_number
          ,p_hold_applicant_date_until    => p_hold_applicant_date_until
          ,p_effective_start_date         => p_effective_start_date
          ,p_effective_end_date           => p_effective_end_date
          ,p_comment_id                   => p_comment_id
          ,p_full_name                    => p_full_name
          ,p_object_version_number        => p_object_version_number
          ,p_name_combination_warning     => p_name_combination_warning
          ,p_assign_payroll_warning       => p_assign_payroll_warning
          ,p_orig_hire_warning            => p_orig_hire_warning
        );
hr_utility.set_location('Leaving: p_event=UPDATE:'|| l_proc, 30);

end if;
hr_utility.set_location('Leaving:'|| l_proc, 40);
end person_business_event;


procedure create_cwk_business_event(
P_START_DATE                    in DATE
,P_BUSINESS_GROUP_ID            in NUMBER
,P_LAST_NAME                    in VARCHAR2
,P_PERSON_TYPE_ID               in NUMBER   default hr_api.g_number
,P_NPW_NUMBER                   in VARCHAR2 default hr_api.g_varchar2
,P_BACKGROUND_CHECK_STATUS      in VARCHAR2 default hr_api.g_varchar2
,P_BACKGROUND_DATE_CHECK        in DATE
,P_BLOOD_TYPE                   in VARCHAR2
,P_COMMENTS                     in VARCHAR2
,P_CORRESPONDENCE_LANGUAGE      in VARCHAR2
,P_COUNTRY_OF_BIRTH             in VARCHAR2
,P_DATE_OF_BIRTH                in DATE
,P_DATE_OF_DEATH                in DATE
,P_DPDNT_ADOPTION_DATE          in DATE
,P_DPDNT_VLNTRY_SVCE_FLAG       in VARCHAR2
,P_EMAIL_ADDRESS                in VARCHAR2
,P_FIRST_NAME                   in VARCHAR2
,P_FTE_CAPACITY                 in NUMBER
,P_HONORS                       in VARCHAR2
,P_INTERNAL_LOCATION            in VARCHAR2
,P_KNOWN_AS                     in VARCHAR2
,P_LAST_MEDICAL_TEST_BY         in VARCHAR2
,P_LAST_MEDICAL_TEST_DATE       in DATE
,P_MAILSTOP                     in VARCHAR2
,P_MARITAL_STATUS               in VARCHAR2
,P_MIDDLE_NAMES                 in VARCHAR2
,P_NATIONAL_IDENTIFIER          in VARCHAR2
,P_NATIONALITY                  in VARCHAR2
,P_OFFICE_NUMBER                in VARCHAR2
,P_ON_MILITARY_SERVICE          in VARCHAR2
,P_PARTY_ID                     in NUMBER
,P_PRE_NAME_ADJUNCT             in VARCHAR2
,P_PREVIOUS_LAST_NAME           in VARCHAR2
,P_PROJECTED_PLACEMENT_END      in DATE
,P_RECEIPT_OF_DEATH_CERT_DATE   in DATE
,P_REGION_OF_BIRTH              in VARCHAR2
,P_REGISTERED_DISABLED_FLAG     in VARCHAR2
,P_RESUME_EXISTS                in VARCHAR2
,P_RESUME_LAST_UPDATED          in DATE
,P_SECOND_PASSPORT_EXISTS       in VARCHAR2
,P_SEX                          in VARCHAR2
,P_STUDENT_STATUS               in VARCHAR2
,P_SUFFIX                       in VARCHAR2
,P_TITLE                        in VARCHAR2
,P_TOWN_OF_BIRTH                in VARCHAR2
,P_USES_TOBACCO_FLAG            in VARCHAR2
,P_VENDOR_ID                    in NUMBER
,P_WORK_SCHEDULE                in VARCHAR2
,P_WORK_TELEPHONE               in VARCHAR2
,P_EXP_CHECK_SEND_TO_ADDRESS    in VARCHAR2
,P_HOLD_APPLICANT_DATE_UNTIL    in DATE
,P_DATE_EMPLOYEE_DATA_VERIFIED  in DATE
,P_BENEFIT_GROUP_ID             in NUMBER
,P_COORD_BEN_MED_PLN_NO         in VARCHAR2
,P_COORD_BEN_NO_CVG_FLAG        in VARCHAR2
,P_ORIGINAL_DATE_OF_HIRE        in DATE
,P_ATTRIBUTE_CATEGORY           in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE1                   in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE2                   in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE3                   in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE4                   in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE5                   in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE6                   in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE7                   in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE8                   in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE9                   in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE10                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE11                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE12                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE13                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE14                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE15                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE16                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE17                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE18                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE19                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE20                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE21                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE22                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE23                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE24                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE25                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE26                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE27                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE28                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE29                  in VARCHAR2 default hr_api.g_varchar2
,P_ATTRIBUTE30                  in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION_CATEGORY     in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION1             in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION2             in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION3             in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION4             in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION5             in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION6             in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION7             in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION8             in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION9             in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION10            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION11            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION12            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION13            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION14            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION15            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION16            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION17            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION18            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION19            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION20            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION21            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION22            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION23            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION24            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION25            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION26            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION27            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION28            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION29            in VARCHAR2 default hr_api.g_varchar2
,P_PER_INFORMATION30            in VARCHAR2 default hr_api.g_varchar2
,P_PERSON_ID                    in NUMBER
,P_PER_OBJECT_VERSION_NUMBER    in NUMBER
,P_PER_EFFECTIVE_START_DATE     in DATE
,P_PER_EFFECTIVE_END_DATE       in DATE
,P_PDP_OBJECT_VERSION_NUMBER    in NUMBER
,P_FULL_NAME                    in VARCHAR2
,P_COMMENT_ID                   in NUMBER
,P_ASSIGNMENT_ID                in NUMBER
,P_ASG_OBJECT_VERSION_NUMBER    in NUMBER
,P_ASSIGNMENT_SEQUENCE          in NUMBER
,P_ASSIGNMENT_NUMBER            in VARCHAR2
,P_NAME_COMBINATION_WARNING     in BOOLEAN
)
is
l_proc varchar2(72) := 'raise_create_cwk_business_event';

begin
hr_utility.set_location('Entering: '|| l_proc, 20);
HR_CONTINGENT_WORKER_BE1.CREATE_CWK_A
    (
    P_START_DATE 					=>			 	P_START_DATE
    ,P_BUSINESS_GROUP_ID 			=> 			 	P_BUSINESS_GROUP_ID
    ,P_LAST_NAME					=> 			 	P_LAST_NAME
    ,P_PERSON_TYPE_ID 				=>				P_PERSON_TYPE_ID
    ,P_NPW_NUMBER 					=> 				P_NPW_NUMBER
    ,P_BACKGROUND_CHECK_STATUS 		=>				P_BACKGROUND_CHECK_STATUS
    ,P_BACKGROUND_DATE_CHECK 		=>				P_BACKGROUND_DATE_CHECK
    ,P_BLOOD_TYPE 					=>				P_BLOOD_TYPE
    ,P_COMMENTS 					=>				P_COMMENTS
    ,P_CORRESPONDENCE_LANGUAGE 		=>				P_CORRESPONDENCE_LANGUAGE
    ,P_COUNTRY_OF_BIRTH 			=>				P_COUNTRY_OF_BIRTH
    ,P_DATE_OF_BIRTH 				=>				P_DATE_OF_BIRTH
    ,P_DATE_OF_DEATH 				=>				P_DATE_OF_DEATH
    ,P_DPDNT_ADOPTION_DATE			=>				P_DPDNT_ADOPTION_DATE
    ,P_DPDNT_VLNTRY_SVCE_FLAG 		=>				P_DPDNT_VLNTRY_SVCE_FLAG
    ,P_EMAIL_ADDRESS 				=>				P_EMAIL_ADDRESS
    ,P_FIRST_NAME 					=>				P_FIRST_NAME
    ,P_FTE_CAPACITY 				=>				P_FTE_CAPACITY
    ,P_HONORS 						=>				P_HONORS
    ,P_INTERNAL_LOCATION 			=>				P_INTERNAL_LOCATION
    ,P_KNOWN_AS 					=>				P_KNOWN_AS
    ,P_LAST_MEDICAL_TEST_BY 		=>				P_LAST_MEDICAL_TEST_BY
    ,P_LAST_MEDICAL_TEST_DATE 		=>				P_LAST_MEDICAL_TEST_DATE
    ,P_MAILSTOP 					=>				P_MAILSTOP
    ,P_MARITAL_STATUS 				=>				P_MARITAL_STATUS
    ,P_MIDDLE_NAMES 				=>				P_MIDDLE_NAMES
    ,P_NATIONAL_IDENTIFIER 			=>				P_NATIONAL_IDENTIFIER
    ,P_NATIONALITY 					=>				P_NATIONALITY
    ,P_OFFICE_NUMBER 				=>				P_OFFICE_NUMBER
    ,P_ON_MILITARY_SERVICE 			=>				P_ON_MILITARY_SERVICE
    ,P_PARTY_ID 					=>				P_PARTY_ID
    ,P_PRE_NAME_ADJUNCT 			=>				P_PRE_NAME_ADJUNCT
    ,P_PREVIOUS_LAST_NAME 			=>				P_PREVIOUS_LAST_NAME
    ,P_PROJECTED_PLACEMENT_END 		=>				P_PROJECTED_PLACEMENT_END
    ,P_RECEIPT_OF_DEATH_CERT_DATE 	=>				P_RECEIPT_OF_DEATH_CERT_DATE
    ,P_REGION_OF_BIRTH 				=>				P_REGION_OF_BIRTH
    ,P_REGISTERED_DISABLED_FLAG 	=>				P_REGISTERED_DISABLED_FLAG
    ,P_RESUME_EXISTS 				=>				P_RESUME_EXISTS
    ,P_RESUME_LAST_UPDATED 			=>				P_RESUME_LAST_UPDATED
    ,P_SECOND_PASSPORT_EXISTS 		=>				P_SECOND_PASSPORT_EXISTS
    ,P_SEX 							=>				P_SEX
    ,P_STUDENT_STATUS 				=>				P_STUDENT_STATUS
    ,P_SUFFIX 						=>				P_SUFFIX
    ,P_TITLE 						=>				P_TITLE
    ,P_TOWN_OF_BIRTH 				=>				P_TOWN_OF_BIRTH
    ,P_USES_TOBACCO_FLAG 			=>				P_USES_TOBACCO_FLAG
    ,P_VENDOR_ID 					=>				P_VENDOR_ID
    ,P_WORK_SCHEDULE 				=>				P_WORK_SCHEDULE
    ,P_WORK_TELEPHONE 				=>				P_WORK_TELEPHONE
    ,P_EXP_CHECK_SEND_TO_ADDRESS 	=>				P_EXP_CHECK_SEND_TO_ADDRESS
    ,P_HOLD_APPLICANT_DATE_UNTIL 	=>				P_HOLD_APPLICANT_DATE_UNTIL
    ,P_DATE_EMPLOYEE_DATA_VERIFIED 	=>				P_DATE_EMPLOYEE_DATA_VERIFIED
    ,P_BENEFIT_GROUP_ID 			=>				P_BENEFIT_GROUP_ID
    ,P_COORD_BEN_MED_PLN_NO 		=>				P_COORD_BEN_MED_PLN_NO
    ,P_COORD_BEN_NO_CVG_FLAG 		=>				P_COORD_BEN_NO_CVG_FLAG
    ,P_ORIGINAL_DATE_OF_HIRE 		=>				P_ORIGINAL_DATE_OF_HIRE
    ,P_ATTRIBUTE_CATEGORY 			=>				P_ATTRIBUTE_CATEGORY
    ,P_ATTRIBUTE1 					=>				P_ATTRIBUTE1
    ,P_ATTRIBUTE2 					=>				P_ATTRIBUTE2
    ,P_ATTRIBUTE3 					=>				P_ATTRIBUTE3
    ,P_ATTRIBUTE4 					=>				P_ATTRIBUTE4
    ,P_ATTRIBUTE5 					=>				P_ATTRIBUTE5
    ,P_ATTRIBUTE6 					=>				P_ATTRIBUTE6
    ,P_ATTRIBUTE7 					=>				P_ATTRIBUTE7
    ,P_ATTRIBUTE8 					=>				P_ATTRIBUTE8
    ,P_ATTRIBUTE9 					=>				P_ATTRIBUTE9
    ,P_ATTRIBUTE10 					=>				P_ATTRIBUTE10
    ,P_ATTRIBUTE11 					=>				P_ATTRIBUTE11
    ,P_ATTRIBUTE12 					=>				P_ATTRIBUTE12
    ,P_ATTRIBUTE13 					=>				P_ATTRIBUTE13
    ,P_ATTRIBUTE14 					=>				P_ATTRIBUTE14
    ,P_ATTRIBUTE15 					=>				P_ATTRIBUTE15
    ,P_ATTRIBUTE16 					=>				P_ATTRIBUTE16
    ,P_ATTRIBUTE17 					=>				P_ATTRIBUTE17
    ,P_ATTRIBUTE18 					=>				P_ATTRIBUTE18
    ,P_ATTRIBUTE19         		    =>				P_ATTRIBUTE19
    ,P_ATTRIBUTE20 					=>				P_ATTRIBUTE20
    ,P_ATTRIBUTE21 					=>				P_ATTRIBUTE21
    ,P_ATTRIBUTE22 					=>				P_ATTRIBUTE22
    ,P_ATTRIBUTE23 					=>				P_ATTRIBUTE23
    ,P_ATTRIBUTE24 					=>				P_ATTRIBUTE24
    ,P_ATTRIBUTE25 					=>				P_ATTRIBUTE25
    ,P_ATTRIBUTE26 					=>				P_ATTRIBUTE26
    ,P_ATTRIBUTE27 					=>				P_ATTRIBUTE27
    ,P_ATTRIBUTE28 					=>				P_ATTRIBUTE28
    ,P_ATTRIBUTE29 					=>				P_ATTRIBUTE29
    ,P_ATTRIBUTE30 					=>				P_ATTRIBUTE30
    ,P_PER_INFORMATION_CATEGORY 	=>				P_PER_INFORMATION_CATEGORY
    ,P_PER_INFORMATION1 			=>				P_PER_INFORMATION1
    ,P_PER_INFORMATION2 			=>				P_PER_INFORMATION2
    ,P_PER_INFORMATION3 			=>				P_PER_INFORMATION3
    ,P_PER_INFORMATION4 			=>				P_PER_INFORMATION4
    ,P_PER_INFORMATION5 			=>				P_PER_INFORMATION5
    ,P_PER_INFORMATION6 			=>				P_PER_INFORMATION6
    ,P_PER_INFORMATION7 			=>				P_PER_INFORMATION7
    ,P_PER_INFORMATION8 			=>				P_PER_INFORMATION8
    ,P_PER_INFORMATION9  			=>				P_PER_INFORMATION9
    ,P_PER_INFORMATION10 			=>				P_PER_INFORMATION10
    ,P_PER_INFORMATION11 			=>				P_PER_INFORMATION11
    ,P_PER_INFORMATION12 			=>				P_PER_INFORMATION12
    ,P_PER_INFORMATION13 			=>				P_PER_INFORMATION13
    ,P_PER_INFORMATION14 			=>				P_PER_INFORMATION14
    ,P_PER_INFORMATION15 			=>				P_PER_INFORMATION15
    ,P_PER_INFORMATION16 			=>				P_PER_INFORMATION16
    ,P_PER_INFORMATION17     		=>				P_PER_INFORMATION17
    ,P_PER_INFORMATION18  			=>				P_PER_INFORMATION18
    ,P_PER_INFORMATION19 			=>				P_PER_INFORMATION19
    ,P_PER_INFORMATION20 			=>				P_PER_INFORMATION20
    ,P_PER_INFORMATION21 			=>				P_PER_INFORMATION21
    ,P_PER_INFORMATION22 			=>				P_PER_INFORMATION22
    ,P_PER_INFORMATION23 			=>				P_PER_INFORMATION23
    ,P_PER_INFORMATION24 			=>				P_PER_INFORMATION24
    ,P_PER_INFORMATION25 			=>				P_PER_INFORMATION25
    ,P_PER_INFORMATION26 			=>				P_PER_INFORMATION26
    ,P_PER_INFORMATION27 			=>				P_PER_INFORMATION27
    ,P_PER_INFORMATION28 			=>				P_PER_INFORMATION28
    ,P_PER_INFORMATION29 			=>				P_PER_INFORMATION29
    ,P_PER_INFORMATION30 			=>				P_PER_INFORMATION30
    ,P_PERSON_ID 					=>				P_PERSON_ID
    ,P_PER_OBJECT_VERSION_NUMBER 	=>				P_PER_OBJECT_VERSION_NUMBER
    ,P_PER_EFFECTIVE_START_DATE 	=>				P_PER_EFFECTIVE_START_DATE
    ,P_PER_EFFECTIVE_END_DATE 		=>				P_PER_EFFECTIVE_END_DATE
    ,P_PDP_OBJECT_VERSION_NUMBER 	=>				P_PDP_OBJECT_VERSION_NUMBER
    ,P_FULL_NAME 					=>				P_FULL_NAME
    ,P_COMMENT_ID 					=>				P_COMMENT_ID
    ,P_ASSIGNMENT_ID 				=>				P_ASSIGNMENT_ID
    ,P_ASG_OBJECT_VERSION_NUMBER 	=>				P_ASG_OBJECT_VERSION_NUMBER
    ,P_ASSIGNMENT_SEQUENCE 			=>				P_ASSIGNMENT_SEQUENCE
    ,P_ASSIGNMENT_NUMBER 			=>				P_ASSIGNMENT_NUMBER
    ,P_NAME_COMBINATION_WARNING 	=>				P_NAME_COMBINATION_WARNING
);
hr_utility.set_location('Leaving: '|| l_proc, 10);
end create_cwk_business_event;


procedure create_appl_business_event(
   p_date_received                in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_person_type_id               in     number
  ,p_applicant_number             in     varchar2
  ,p_per_comments                 in     varchar2
  ,p_date_employee_data_verified  in     date
  ,p_date_of_birth                in     date
  ,p_email_address                in     varchar2
  ,p_expense_check_send_to_addres in     varchar2
  ,p_first_name                   in     varchar2
  ,p_known_as                     in     varchar2
  ,p_marital_status               in     varchar2
  ,p_middle_names                 in     varchar2
  ,p_nationality                  in     varchar2
  ,p_national_identifier          in     varchar2
  ,p_previous_last_name           in     varchar2
  ,p_registered_disabled_flag     in     varchar2
  ,p_sex                          in     varchar2
  ,p_title                        in     varchar2
  ,p_work_telephone               in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_attribute21                  in     varchar2
  ,p_attribute22                  in     varchar2
  ,p_attribute23                  in     varchar2
  ,p_attribute24                  in     varchar2
  ,p_attribute25                  in     varchar2
  ,p_attribute26                  in     varchar2
  ,p_attribute27                  in     varchar2
  ,p_attribute28                  in     varchar2
  ,p_attribute29                  in     varchar2
  ,p_attribute30                  in     varchar2
  ,p_per_information_category     in     varchar2
  ,p_per_information1             in     varchar2
  ,p_per_information2             in     varchar2
  ,p_per_information3             in     varchar2
  ,p_per_information4             in     varchar2
  ,p_per_information5             in     varchar2
  ,p_per_information6             in     varchar2
  ,p_per_information7             in     varchar2
  ,p_per_information8             in     varchar2
  ,p_per_information9             in     varchar2
  ,p_per_information10            in     varchar2
  ,p_per_information11            in     varchar2
  ,p_per_information12            in     varchar2
  ,p_per_information13            in     varchar2
  ,p_per_information14            in     varchar2
  ,p_per_information15            in     varchar2
  ,p_per_information16            in     varchar2
  ,p_per_information17            in     varchar2
  ,p_per_information18            in     varchar2
  ,p_per_information19            in     varchar2
  ,p_per_information20            in     varchar2
  ,p_per_information21            in     varchar2
  ,p_per_information22            in     varchar2
  ,p_per_information23            in     varchar2
  ,p_per_information24            in     varchar2
  ,p_per_information25            in     varchar2
  ,p_per_information26            in     varchar2
  ,p_per_information27            in     varchar2
  ,p_per_information28            in     varchar2
  ,p_per_information29            in     varchar2
  ,p_per_information30            in     varchar2
  ,p_background_check_status      in     varchar2
  ,p_background_date_check        in     date
  ,p_correspondence_language      in     varchar2
  ,p_fte_capacity                 in     number
  ,p_hold_applicant_date_until    in     date
  ,p_honors                       in     varchar2
  ,p_mailstop                     in     varchar2
  ,p_office_number                in     varchar2
  ,p_on_military_service          in     varchar2
  ,p_pre_name_adjunct             in     varchar2
  ,p_projected_start_date         in     date
  ,p_resume_exists                in     varchar2
  ,p_resume_last_updated          in     date
  ,p_student_status               in     varchar2
  ,p_work_schedule                in     varchar2
  ,p_suffix                       in     varchar2
  ,p_date_of_death                in     date
  ,p_benefit_group_id             in     number
  ,p_receipt_of_death_cert_date   in     date
  ,p_coord_ben_med_pln_no         in     varchar2
  ,p_coord_ben_no_cvg_flag        in     varchar2
  ,p_uses_tobacco_flag            in     varchar2
  ,p_dpdnt_adoption_date          in     date
  ,p_dpdnt_vlntry_svce_flag       in     varchar2
  ,p_original_date_of_hire        in     date
  ,p_person_id                    in     number
  ,p_assignment_id                in     number
  ,p_application_id               in     number
  ,p_per_object_version_number    in     number
  ,p_asg_object_version_number    in     number
  ,p_apl_object_version_number    in     number
  ,p_per_effective_start_date     in     date
  ,p_per_effective_end_date       in     date
  ,p_full_name                    in     varchar2
  ,p_per_comment_id               in     number
  ,p_assignment_sequence          in     number
  ,p_name_combination_warning     in     boolean
  ,p_orig_hire_warning            in     boolean
  ,p_town_of_birth                in     varchar2
  ,p_region_of_birth              in     varchar2
  ,p_country_of_birth             in     varchar2
  ,p_global_person_id             in     varchar2
  ,p_party_id                     in     varchar2
  ,p_vacancy_id                   in     number
)
is
l_proc varchar2(72) := 'create_appl_business_event';
begin
hr_utility.set_location('Entering: '|| l_proc, 20);
HR_APPLICANT_BK1.create_applicant_a(
  p_date_received                   		=> p_date_received
  ,p_business_group_id            			=> p_business_group_id
  ,p_last_name                    			=> p_last_name
  ,p_person_type_id               			=> p_person_type_id
  ,p_applicant_number             			=> p_applicant_number
  ,p_per_comments                 			=> p_per_comments
  ,p_date_employee_data_verified  			=> p_date_employee_data_verified
  ,p_date_of_birth                			=> p_date_of_birth
  ,p_email_address                			=> p_email_address
  ,p_expense_check_send_to_addres 			=> p_expense_check_send_to_addres
  ,p_first_name                   			=> p_first_name
  ,p_known_as                     			=> p_known_as
  ,p_marital_status               			=> p_marital_status
  ,p_middle_names                 			=> p_middle_names
  ,p_nationality                  			=> p_nationality
  ,p_national_identifier          			=> p_national_identifier
  ,p_previous_last_name           			=>  p_previous_last_name
  ,p_registered_disabled_flag     			=> p_registered_disabled_flag
  ,p_sex                         			=> p_sex
  ,p_title                        			=> p_title
  ,p_work_telephone               			=> p_work_telephone
  ,p_attribute_category           			=> p_attribute_category
  ,p_attribute1                   			=> p_attribute1
  ,p_attribute2                   			=> p_attribute2
  ,p_attribute3                   			=> p_attribute3
  ,p_attribute4                   			=> p_attribute4
  ,p_attribute5                   			=> p_attribute5
  ,p_attribute6                   			=> p_attribute6
  ,p_attribute7                   			=> p_attribute7
  ,p_attribute8                   			=> p_attribute8
  ,p_attribute9                   			=> p_attribute9
  ,p_attribute10                  			=> p_attribute10
  ,p_attribute11                  			=> p_attribute11
  ,p_attribute12                  			=> p_attribute12
  ,p_attribute13                  			=> p_attribute13
  ,p_attribute14                  			=> p_attribute14
  ,p_attribute15                  			=> p_attribute15
  ,p_attribute16                  			=> p_attribute16
  ,p_attribute17                  			=> p_attribute17
  ,p_attribute18                  			=> p_attribute18
  ,p_attribute19                  			=> p_attribute19
  ,p_attribute20                  			=> p_attribute20
  ,p_attribute21                  			=> p_attribute21
  ,p_attribute22                  			=> p_attribute22
  ,p_attribute23                  			=> p_attribute23
  ,p_attribute24                  			=> p_attribute24
  ,p_attribute25                  			=> p_attribute25
  ,p_attribute26                  			=> p_attribute26
  ,p_attribute27                  			=> p_attribute27
  ,p_attribute28                  			=> p_attribute28
  ,p_attribute29                  			=> p_attribute29
  ,p_attribute30                  			=> p_attribute30
  ,p_per_information_category     			=> p_per_information_category
  ,p_per_information1             			=> p_per_information1
  ,p_per_information2             			=> p_per_information2
  ,p_per_information3             			=> p_per_information3
  ,p_per_information4             			=> p_per_information4
  ,p_per_information5             			=> p_per_information5
  ,p_per_information6             			=> p_per_information6
  ,p_per_information7             			=> p_per_information7
  ,p_per_information8             			=> p_per_information8
  ,p_per_information9             			=> p_per_information9
  ,p_per_information10            			=> p_per_information10
  ,p_per_information11            			=> p_per_information11
  ,p_per_information12            			=> p_per_information12
  ,p_per_information13            			=> p_per_information13
  ,p_per_information14            			=> p_per_information14
  ,p_per_information15            			=> p_per_information15
  ,p_per_information16            			=> p_per_information16
  ,p_per_information17            			=> p_per_information17
  ,p_per_information18            			=> p_per_information18
  ,p_per_information19            			=> p_per_information19
  ,p_per_information20            			=> p_per_information20
  ,p_per_information21            			=> p_per_information21
  ,p_per_information22            			=> p_per_information22
  ,p_per_information23            			=> p_per_information23
  ,p_per_information24            			=> p_per_information24
  ,p_per_information25            			=> p_per_information25
  ,p_per_information26            			=> p_per_information26
  ,p_per_information27            			=> p_per_information27
  ,p_per_information28            			=> p_per_information28
  ,p_per_information29            			=> p_per_information29
  ,p_per_information30            			=> p_per_information30
  ,p_background_check_status      			=> p_background_check_status
  ,p_background_date_check        			=> p_background_date_check
  ,p_correspondence_language      			=> p_correspondence_language
  ,p_fte_capacity                 			=> p_fte_capacity
  ,p_hold_applicant_date_until    			=> p_hold_applicant_date_until
  ,p_honors                       			=> p_honors
  ,p_mailstop                     			=> p_mailstop
  ,p_office_number                			=> p_office_number
  ,p_on_military_service          			=> p_on_military_service
  ,p_pre_name_adjunct             			=> p_pre_name_adjunct
  ,p_projected_start_date         			=> p_projected_start_date
  ,p_resume_exists                			=> p_resume_exists
  ,p_resume_last_updated          			=> p_resume_last_updated
  ,p_student_status               			=> p_student_status
  ,p_work_schedule                			=> p_work_schedule
  ,p_suffix                       			=> p_suffix
  ,p_date_of_death                			=> p_date_of_death
  ,p_benefit_group_id             			=> p_benefit_group_id
  ,p_receipt_of_death_cert_date   			=> p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no         			=> p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        			=> p_coord_ben_no_cvg_flag
  ,p_uses_tobacco_flag            			=> p_uses_tobacco_flag
  ,p_dpdnt_adoption_date          			=> p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag       			=> p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire        			=> p_original_date_of_hire
  ,p_person_id                    			=> p_person_id
  ,p_assignment_id                			=> p_assignment_id
  ,p_application_id               			=> p_application_id
  ,p_per_object_version_number    			=> p_per_object_version_number
  ,p_asg_object_version_number    			=> p_asg_object_version_number
  ,p_apl_object_version_number    			=> p_apl_object_version_number
  ,p_per_effective_start_date     			=> p_per_effective_start_date
  ,p_per_effective_end_date       			=> p_per_effective_end_date
  ,p_full_name                    			=> p_full_name
  ,p_per_comment_id               			=> p_per_comment_id
  ,p_assignment_sequence          			=> p_assignment_sequence
  ,p_name_combination_warning     			=> p_name_combination_warning
  ,p_orig_hire_warning            			=> p_orig_hire_warning
  ,p_town_of_birth                			=> p_town_of_birth
  ,p_region_of_birth              			=> p_region_of_birth
  ,p_country_of_birth             			=> p_country_of_birth
  ,p_global_person_id             			=> p_global_person_id
  ,p_party_id                     			=> p_party_id
  ,p_vacancy_id                   			=> p_vacancy_id
);
hr_utility.set_location('Leaving: '|| l_proc, 20);
end create_appl_business_event;

procedure create_emp_business_event(
   p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number
  ,p_per_comments                  in     varchar2
  ,p_date_employee_data_verified   in     date
  ,p_date_of_birth                 in     date
  ,p_email_address                 in     varchar2
  ,p_employee_number               in     varchar2
  ,p_expense_check_send_to_addres  in     varchar2
  ,p_first_name                    in     varchar2
  ,p_known_as                      in     varchar2
  ,p_marital_status                in     varchar2
  ,p_middle_names                  in     varchar2
  ,p_nationality                   in     varchar2
  ,p_national_identifier           in     varchar2
  ,p_previous_last_name            in     varchar2
  ,p_registered_disabled_flag      in     varchar2
  ,p_title                         in     varchar2
  ,p_vendor_id                     in     number
  ,p_work_telephone                in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_per_information_category      in     varchar2
  ,p_per_information1              in     varchar2
  ,p_per_information2              in     varchar2
  ,p_per_information3              in     varchar2
  ,p_per_information4              in     varchar2
  ,p_per_information5              in     varchar2
  ,p_per_information6              in     varchar2
  ,p_per_information7              in     varchar2
  ,p_per_information8              in     varchar2
  ,p_per_information9              in     varchar2
  ,p_per_information10             in     varchar2
  ,p_per_information11             in     varchar2
  ,p_per_information12             in     varchar2
  ,p_per_information13             in     varchar2
  ,p_per_information14             in     varchar2
  ,p_per_information15             in     varchar2
  ,p_per_information16             in     varchar2
  ,p_per_information17             in     varchar2
  ,p_per_information18             in     varchar2
  ,p_per_information19             in     varchar2
  ,p_per_information20             in     varchar2
  ,p_per_information21             in     varchar2
  ,p_per_information22             in     varchar2
  ,p_per_information23             in     varchar2
  ,p_per_information24             in     varchar2
  ,p_per_information25             in     varchar2
  ,p_per_information26             in     varchar2
  ,p_per_information27             in     varchar2
  ,p_per_information28             in     varchar2
  ,p_per_information29             in     varchar2
  ,p_per_information30             in     varchar2
  ,p_date_of_death                 in     date
  ,p_background_check_status       in     varchar2
  ,p_background_date_check         in     date
  ,p_blood_type                    in     varchar2
  ,p_correspondence_language       in     varchar2
  ,p_fast_path_employee            in     varchar2
  ,p_fte_capacity                  in     number
  ,p_honors                        in     varchar2
  ,p_internal_location             in     varchar2
  ,p_last_medical_test_by          in     varchar2
  ,p_last_medical_test_date        in     date
  ,p_mailstop                      in     varchar2
  ,p_office_number                 in     varchar2
  ,p_on_military_service           in     varchar2
  ,p_pre_name_adjunct              in     varchar2
  ,p_rehire_recommendation         in     varchar2
  ,p_projected_start_date          in     date
  ,p_resume_exists                 in     varchar2
  ,p_resume_last_updated           in     date
  ,p_second_passport_exists        in     varchar2
  ,p_student_status                in     varchar2
  ,p_work_schedule                 in     varchar2
  ,p_suffix                        in     varchar2
  ,p_benefit_group_id              in     number
  ,p_receipt_of_death_cert_date    in     date
  ,p_coord_ben_med_pln_no          in     varchar2
  ,p_coord_ben_no_cvg_flag         in     varchar2
  ,p_coord_ben_med_ext_er          in     varchar2
  ,p_coord_ben_med_pl_name         in     varchar2
  ,p_coord_ben_med_insr_crr_name   in     varchar2
  ,p_coord_ben_med_insr_crr_ident  in     varchar2
  ,p_coord_ben_med_cvg_strt_dt     in     date
  ,p_coord_ben_med_cvg_end_dt      in     date
  ,p_uses_tobacco_flag             in     varchar2
  ,p_dpdnt_adoption_date           in     date
  ,p_dpdnt_vlntry_svce_flag        in     varchar2
  ,p_original_date_of_hire         in     date
  ,p_adjusted_svc_date             in     date
  ,p_person_id                     in     number
  ,p_assignment_id                 in     number
  ,p_per_object_version_number     in     number
  ,p_asg_object_version_number     in     number
  ,p_per_effective_start_date      in     date
  ,p_per_effective_end_date        in     date
  ,p_full_name                     in     varchar2
  ,p_per_comment_id                in     number
  ,p_assignment_sequence           in     number
  ,p_assignment_number             in     varchar2
  ,p_town_of_birth                 in     varchar2
  ,p_region_of_birth               in     varchar2
  ,p_country_of_birth              in     varchar2
  ,p_global_person_id              in     varchar2
  ,p_party_id                      in     number
  ,p_name_combination_warning      in     boolean
  ,p_assign_payroll_warning        in     boolean
  ,p_orig_hire_warning             in     boolean
)
is
l_proc varchar2(72) := 'create_emp_business_event';
begin
hr_utility.set_location('Entering: '|| l_proc, 20);
HR_EMPLOYEE_BK1.create_employee_a(
   p_hire_date                     => p_hire_date
  ,p_business_group_id             => p_business_group_id
  ,p_last_name                     => p_last_name
  ,p_sex                           => p_sex
  ,p_person_type_id                => p_person_type_id
  ,p_per_comments                  => p_per_comments
  ,p_date_employee_data_verified   => p_date_employee_data_verified
  ,p_date_of_birth                 => p_date_of_birth
  ,p_email_address                 => p_email_address
  ,p_employee_number               => p_employee_number
  ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
  ,p_first_name                    => p_first_name
  ,p_known_as                      => p_known_as
  ,p_marital_status                => p_marital_status
  ,p_middle_names                  => p_middle_names
  ,p_nationality                   => p_nationality
  ,p_national_identifier           => p_national_identifier
  ,p_previous_last_name            => p_previous_last_name
  ,p_registered_disabled_flag      => p_registered_disabled_flag
  ,p_title                         => p_title
  ,p_vendor_id                     => p_vendor_id
  ,p_work_telephone                => p_work_telephone
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_per_information_category      => p_per_information_category
  ,p_per_information1              => p_per_information1
  ,p_per_information2              => p_per_information2
  ,p_per_information3              => p_per_information3
  ,p_per_information4              => p_per_information4
  ,p_per_information5              => p_per_information5
  ,p_per_information6              => p_per_information6
  ,p_per_information7              => p_per_information7
  ,p_per_information8              => p_per_information8
  ,p_per_information9              => p_per_information9
  ,p_per_information10             => p_per_information10
  ,p_per_information11             => p_per_information11
  ,p_per_information12             => p_per_information12
  ,p_per_information13             => p_per_information13
  ,p_per_information14             => p_per_information14
  ,p_per_information15             => p_per_information15
  ,p_per_information16             => p_per_information16
  ,p_per_information17             => p_per_information17
  ,p_per_information18             => p_per_information18
  ,p_per_information19             => p_per_information19
  ,p_per_information20             => p_per_information20
  ,p_per_information21             => p_per_information21
  ,p_per_information22             => p_per_information22
  ,p_per_information23             => p_per_information23
  ,p_per_information24             => p_per_information24
  ,p_per_information25             => p_per_information25
  ,p_per_information26             => p_per_information26
  ,p_per_information27             => p_per_information27
  ,p_per_information28             => p_per_information28
  ,p_per_information29             => p_per_information29
  ,p_per_information30             => p_per_information30
  ,p_date_of_death                 => p_date_of_death
  ,p_background_check_status       => p_background_check_status
  ,p_background_date_check         => p_background_date_check
  ,p_blood_type                    => p_blood_type
  ,p_correspondence_language       => p_correspondence_language
  ,p_fast_path_employee            => p_fast_path_employee
  ,p_fte_capacity                  => p_fte_capacity
  ,p_honors                        => p_honors
  ,p_internal_location             => p_internal_location
  ,p_last_medical_test_by          => p_last_medical_test_by
  ,p_last_medical_test_date        => p_last_medical_test_date
  ,p_mailstop                      => p_mailstop
  ,p_office_number                 => p_office_number
  ,p_on_military_service           => p_on_military_service
  ,p_pre_name_adjunct              => p_pre_name_adjunct
  ,p_rehire_recommendation         => p_rehire_recommendation
  ,p_projected_start_date          => p_projected_start_date
  ,p_resume_exists                 => p_resume_exists
  ,p_resume_last_updated           => p_resume_last_updated
  ,p_second_passport_exists        => p_second_passport_exists
  ,p_student_status                => p_student_status
  ,p_work_schedule                 => p_work_schedule
  ,p_suffix                        => p_suffix
  ,p_benefit_group_id              => p_benefit_group_id
  ,p_receipt_of_death_cert_date    => p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no          => p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
  ,p_coord_ben_med_ext_er          => p_coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name         => p_coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name   => p_coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident  => p_coord_ben_med_insr_crr_ident
  ,p_coord_ben_med_cvg_strt_dt     => p_coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt      => p_coord_ben_med_cvg_end_dt
  ,p_uses_tobacco_flag             => p_uses_tobacco_flag
  ,p_dpdnt_adoption_date           => p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag        => p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire         => p_original_date_of_hire
  ,p_adjusted_svc_date             => p_adjusted_svc_date
  ,p_person_id                     => p_person_id
  ,p_assignment_id                 => p_assignment_id
  ,p_per_object_version_number     => p_per_object_version_number
  ,p_asg_object_version_number     => p_asg_object_version_number
  ,p_per_effective_start_date      => p_per_effective_start_date
  ,p_per_effective_end_date        => p_per_effective_end_date
  ,p_full_name                     => p_full_name
  ,p_per_comment_id                => p_per_comment_id
  ,p_assignment_sequence           => p_assignment_sequence
  ,p_assignment_number             => p_assignment_number
  ,p_town_of_birth                 => p_town_of_birth
  ,p_region_of_birth               => p_region_of_birth
  ,p_country_of_birth              => p_country_of_birth
  ,p_global_person_id              => p_global_person_id
  ,p_party_id                      => p_party_id
  ,p_name_combination_warning      => p_name_combination_warning
  ,p_assign_payroll_warning        => p_assign_payroll_warning
  ,p_orig_hire_warning             => p_orig_hire_warning
);
hr_utility.set_location('Leaving: '|| l_proc, 20);
end create_emp_business_event;

end HR_PERSON_BUSINESS_EVENT;

/
