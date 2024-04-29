--------------------------------------------------------
--  DDL for Package HR_PERSON_BUSINESS_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_BUSINESS_EVENT" AUTHID CURRENT_USER as
/* $Header: peperbev.pkh 120.0.12010000.2 2008/08/27 14:58:05 srgnanas ship $ */


--
-- -----------------------------------------------------------------------------------
-- |--------------------------< person_business_event >--------------------------|
-- -----------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This package raises a business event.
--
-- Prerequisites:
-- None
-- In Parameters:
--   Name                        Reqd      Type         Description
-- p_event                        Y	 varchar2
-- p_datetrack_update_mode        N 	 varchar2
-- p_system_person_type           Y 	 varchar2
-- p_effective_date               Y 	 date
-- p_person_id                    Y 	 number
-- p_object_version_number        Y 	 number
-- p_person_type_id               N 	 number
-- p_last_name                    N 	 varchar2
-- p_applicant_number             N 	 varchar2
-- p_comments                     N 	 varchar2
-- p_date_employee_data_verified  N 	 date
-- p_date_of_birth                N 	 date
-- p_email_address                N 	 varchar2
-- p_employee_number              N 	 varchar2
-- p_expense_check_send_to_addres N 	 varchar2
-- p_first_name                   N 	 varchar2
-- p_known_as                     N 	 varchar2
-- p_marital_status               N 	 varchar2
-- p_middle_names                 N 	 varchar2
-- p_nationality                  N 	 varchar2
-- p_national_identifier          N 	 varchar2
-- p_previous_last_name           N 	 varchar2
-- p_registered_disabled_flag     N 	 varchar2
-- p_sex                          N 	 varchar2
-- p_title                        N 	 varchar2
-- p_vendor_id                    N 	 number
-- p_attribute_category           N 	 varchar2
-- p_attribute1                   N 	 varchar2
-- p_attribute2                   N 	 varchar2
-- p_attribute3                   N 	 varchar2
-- p_attribute4                   N 	 varchar2
-- p_attribute5                   N 	 varchar2
-- p_attribute6                   N 	 varchar2
-- p_attribute7                   N 	 varchar2
-- p_attribute8                   N 	 varchar2
-- p_attribute9                   N 	 varchar2
-- p_attribute10                  N 	 varchar2
-- p_attribute11                  N 	 varchar2
-- p_attribute12                  N 	 varchar2
-- p_attribute13                  N 	 varchar2
-- p_attribute14                  N 	 varchar2
-- p_attribute15                  N 	 varchar2
-- p_attribute16                  N 	 varchar2
-- p_attribute17                  N 	 varchar2
-- p_attribute18                  N 	 varchar2
-- p_attribute19                  N 	 varchar2
-- p_attribute20                  N 	 varchar2
-- p_attribute21                  N 	 varchar2
-- p_attribute22                  N 	 varchar2
-- p_attribute23                  N 	 varchar2
-- p_attribute24                  N 	 varchar2
-- p_attribute25                  N 	 varchar2
-- p_attribute26                  N 	 varchar2
-- p_attribute27                  N 	 varchar2
-- p_attribute28                  N 	 varchar2
-- p_attribute29                  N 	 varchar2
-- p_attribute30                  N 	 varchar2
-- p_per_information_category     N 	 varchar2
-- p_per_information1             N 	 varchar2
-- p_per_information2             N 	 varchar2
-- p_per_information3             N 	 varchar2
-- p_per_information4             N 	 varchar2
-- p_per_information5             N 	 varchar2
-- p_per_information6             N 	 varchar2
-- p_per_information7             N 	 varchar2
-- p_per_information8             N	 varchar2
-- p_per_information9             N	 varchar2
-- p_per_information10            N  	 varchar2
-- p_per_information11            N 	 varchar2
-- p_per_information12            N 	 varchar2
-- p_per_information13            N  	 varchar2
-- p_per_information14            N 	 varchar2
-- p_per_information15            N 	 varchar2
-- p_per_information16            N 	 varchar2
-- p_per_information17            N 	 varchar2
-- p_per_information18            N 	 varchar2
-- p_per_information19            N 	 varchar2
-- p_per_information20            N 	 varchar2
-- p_per_information21            N 	 varchar2
-- p_per_information22            N 	 varchar2
-- p_per_information23            N 	 varchar2
-- p_per_information24            N 	 varchar2
-- p_per_information25            N 	 varchar2
-- p_per_information26            N 	 varchar2
-- p_per_information27            N 	 varchar2
-- p_per_information28            N 	 varchar2
-- p_per_information29            N 	 varchar2
-- p_per_information30            N 	 varchar2
-- p_date_of_death                N 	 date
-- p_background_check_status      N 	 varchar2
-- p_background_date_check        N 	 date
-- p_blood_type                   N       varchar2
-- p_correspondence_language      N 	 varchar2
-- p_fast_path_employee           N  	 varchar2
-- p_fte_capacity                 N	 number
-- p_hold_applicant_date_until    N 	 date
-- p_honors                       N 	 varchar2
-- p_internal_location            N 	 varchar2
-- p_last_medical_test_by         N 	 varchar2
-- p_last_medical_test_date       N 	 date
-- p_mailstop                     N 	 varchar2
-- p_office_number                N 	 varchar2
-- p_on_military_service          N 	 varchar2
-- p_pre_name_adjunct             N 	 varchar2
-- p_projected_start_date         N	 date
-- p_rehire_authorizor            N 	 varchar2
-- p_rehire_recommendation        N 	 varchar2
-- p_resume_exists                N 	 varchar2
-- p_resume_last_updated          N	 date
-- p_second_passport_exists       N 	 varchar2
-- p_student_status               N       varchar2
-- p_work_schedule                N  	 varchar2
-- p_rehire_reason                N 	 varchar2
-- p_suffix                       N 	 varchar2
-- p_benefit_group_id             N 	 number
-- p_receipt_of_death_cert_date   N 	 date
-- p_coord_ben_med_pln_no         N 	 varchar2
-- p_coord_ben_no_cvg_flag        N 	 varchar2
-- p_coord_ben_med_ext_er         N 	 varchar2
-- p_coord_ben_med_pl_name        N 	 varchar2
-- p_coord_ben_med_insr_crr_name  N 	 varchar2
-- p_coord_ben_med_insr_crr_ident N 	 varchar2
-- p_coord_ben_med_cvg_strt_dt    N 	 date
-- p_coord_ben_med_cvg_end_dt     N     	 date
-- p_uses_tobacco_flag            N 	 varchar2
-- p_dpdnt_adoption_date          N 	 date
-- p_dpdnt_vlntry_svce_flag       N 	 varchar2
-- p_original_date_of_hire        N 	 date
-- p_adjusted_svc_date            N 	 date
-- p_effective_start_date         N 	 date
-- p_effective_end_date           N 	 date
-- p_full_name                    N  	 varchar2
-- p_comment_id                   N 	 number
-- p_town_of_birth                N  	 varchar2
-- p_region_of_birth              N 	 varchar2
-- p_country_of_birth             N 	 varchar2
-- p_global_person_id             N 	 varchar2
-- p_party_id                     N 	 number
-- p_npw_number                   N 	 varchar2
-- p_name_combination_warning     N 	 boolean
-- p_assign_payroll_warning       N 	 boolean
-- p_orig_hire_warning            N 	 boolean
-- Post Success:
--  A Business Event will be raised on update of Person.
--
--
-- Post Failure:
-- Business Event will not be raised and an error will be raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}


procedure person_business_event(
p_event                        in  varchar2,
p_datetrack_update_mode        in  varchar2 default hr_api.g_update,
p_system_person_type           in  varchar2,
p_effective_date               in  date,
p_person_id                    in  number,
p_object_version_number        in  number,
p_person_type_id               in  number default hr_api.g_number,
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
p_vendor_id                    in  number default hr_api.g_number,
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
);


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
);


procedure create_appl_business_event(
 p_date_received                 in     date
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
);


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
  ,p_rehire_recommendation         in     varchar2 -- Bug 3210500
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
);

end HR_PERSON_BUSINESS_EVENT;

/
