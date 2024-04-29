--------------------------------------------------------
--  DDL for Package PER_PER_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PER_RKI" AUTHID CURRENT_USER as
/* $Header: peperrhi.pkh 120.2.12010000.1 2008/07/28 05:14:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_name_combination_warning     in boolean
  ,p_dob_null_warning             in boolean
  ,p_orig_hire_warning            in boolean
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_person_id                    in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_person_type_id               in number
  ,p_last_name                    in varchar2
  ,p_start_date                   in date
  ,p_applicant_number             in varchar2
  ,p_comment_id                   in number
  ,p_current_applicant_flag       in varchar2
  ,p_current_emp_or_apl_flag      in varchar2
  ,p_current_employee_flag        in varchar2
  ,p_date_employee_data_verified  in date
  ,p_date_of_birth                in date
  ,p_email_address                in varchar2
  ,p_employee_number              in varchar2
  ,p_expense_check_send_to_addres in varchar2
  ,p_first_name                   in varchar2
  ,p_full_name                    in varchar2
  ,p_known_as                     in varchar2
  ,p_marital_status               in varchar2
  ,p_middle_names                 in varchar2
  ,p_nationality                  in varchar2
  ,p_national_identifier          in varchar2
  ,p_previous_last_name           in varchar2
  ,p_registered_disabled_flag     in varchar2
  ,p_sex                          in varchar2
  ,p_title                        in varchar2
  ,p_vendor_id                    in number
  ,p_work_telephone               in varchar2
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
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
  ,p_suffix                       in varchar2
  ,p_DATE_OF_DEATH                in date
  ,p_BACKGROUND_CHECK_STATUS      in varchar2
  ,p_BACKGROUND_DATE_CHECK        in date
  ,p_BLOOD_TYPE                   in varchar2
  ,p_CORRESPONDENCE_LANGUAGE      in varchar2
  ,p_FAST_PATH_EMPLOYEE           in varchar2
  ,p_FTE_CAPACITY                 in number
  ,p_HOLD_APPLICANT_DATE_UNTIL    in date
  ,p_HONORS                       in varchar2
  ,p_INTERNAL_LOCATION            in varchar2
  ,p_LAST_MEDICAL_TEST_BY         in varchar2
  ,p_LAST_MEDICAL_TEST_DATE       in date
  ,p_MAILSTOP                     in varchar2
  ,p_OFFICE_NUMBER                in varchar2
  ,p_ON_MILITARY_SERVICE          in varchar2
  ,p_ORDER_NAME                   in varchar2
  ,p_PRE_NAME_ADJUNCT             in varchar2
  ,p_PROJECTED_START_DATE         in date
  ,p_REHIRE_AUTHORIZOR            in varchar2
  ,p_REHIRE_RECOMMENDATION        in varchar2
  ,p_RESUME_EXISTS                in varchar2
  ,p_RESUME_LAST_UPDATED          in date
  ,p_SECOND_PASSPORT_EXISTS       in varchar2
  ,p_STUDENT_STATUS               in varchar2
  ,p_WORK_SCHEDULE                in varchar2
  ,p_PER_INFORMATION21            in varchar2
  ,p_PER_INFORMATION22            in varchar2
  ,p_PER_INFORMATION23            in varchar2
  ,p_PER_INFORMATION24            in varchar2
  ,p_PER_INFORMATION25            in varchar2
  ,p_PER_INFORMATION26            in varchar2
  ,p_PER_INFORMATION27            in varchar2
  ,p_PER_INFORMATION28            in varchar2
  ,p_PER_INFORMATION29            in varchar2
  ,p_PER_INFORMATION30            in varchar2
  ,p_REHIRE_REASON                in varchar2
  ,p_BENEFIT_GROUP_ID             in varchar2
  ,p_RECEIPT_OF_DEATH_CERT_DATE   in date
  ,p_COORD_BEN_MED_PLN_NO         in varchar2
  ,p_COORD_BEN_NO_CVG_FLAG        in varchar2
  ,p_coord_ben_med_ext_er         in varchar2
  ,p_coord_ben_med_pl_name        in varchar2
  ,p_coord_ben_med_insr_crr_name  in varchar2
  ,p_coord_ben_med_insr_crr_ident in varchar2
  ,p_coord_ben_med_cvg_strt_dt    in date
  ,p_coord_ben_med_cvg_end_dt     in date
  ,p_USES_TOBACCO_FLAG            in varchar2
  ,p_DPDNT_ADOPTION_DATE          in date
  ,p_DPDNT_VLNTRY_SVCE_FLAG       in varchar2
  ,p_ORIGINAL_DATE_OF_HIRE        in date
  ,p_town_of_birth                in varchar2
  ,p_region_of_birth              in varchar2
  ,p_country_of_birth             in varchar2
  ,p_global_person_id             in varchar2
  ,p_party_id                     in number
  ,p_npw_number                   in varchar2
  ,p_current_npw_flag             in varchar2
  ,p_global_name                  in varchar2 -- #3889584
  ,p_local_name                   in varchar2
  ,p_object_version_number        in number
  );
end per_per_rki;

/
