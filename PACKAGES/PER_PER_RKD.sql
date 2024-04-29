--------------------------------------------------------
--  DDL for Package PER_PER_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PER_RKD" AUTHID CURRENT_USER as
/* $Header: peperrhi.pkh 120.2.12010000.1 2008/07/28 05:14:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_datetrack_mode               in varchar2
  ,p_person_id                    in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_object_version_number        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_person_type_id_o             in number
  ,p_last_name_o                  in varchar2
  ,p_start_date_o                 in date
  ,p_applicant_number_o           in varchar2
  ,p_comment_id_o                 in number
  ,p_current_applicant_flag_o     in varchar2
  ,p_current_emp_or_apl_flag_o    in varchar2
  ,p_current_employee_flag_o      in varchar2
  ,p_date_employee_data_verifie_o in date
  ,p_date_of_birth_o              in date
  ,p_email_address_o              in varchar2
  ,p_employee_number_o            in varchar2
  ,p_expense_check_send_to_addr_o in varchar2
  ,p_first_name_o                 in varchar2
  ,p_full_name_o                  in varchar2
  ,p_known_as_o                   in varchar2
  ,p_marital_status_o             in varchar2
  ,p_middle_names_o               in varchar2
  ,p_nationality_o                in varchar2
  ,p_national_identifier_o        in varchar2
  ,p_previous_last_name_o         in varchar2
  ,p_registered_disabled_flag_o   in varchar2
  ,p_sex_o                        in varchar2
  ,p_title_o                      in varchar2
  ,p_vendor_id_o                  in number
  ,p_work_telephone_o             in varchar2
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  ,p_per_information_category_o   in varchar2
  ,p_per_information1_o           in varchar2
  ,p_per_information2_o           in varchar2
  ,p_per_information3_o           in varchar2
  ,p_per_information4_o           in varchar2
  ,p_per_information5_o           in varchar2
  ,p_per_information6_o           in varchar2
  ,p_per_information7_o           in varchar2
  ,p_per_information8_o           in varchar2
  ,p_per_information9_o           in varchar2
  ,p_per_information10_o          in varchar2
  ,p_per_information11_o          in varchar2
  ,p_per_information12_o          in varchar2
  ,p_per_information13_o          in varchar2
  ,p_per_information14_o          in varchar2
  ,p_per_information15_o          in varchar2
  ,p_per_information16_o          in varchar2
  ,p_per_information17_o          in varchar2
  ,p_per_information18_o          in varchar2
  ,p_per_information19_o          in varchar2
  ,p_per_information20_o          in varchar2
  ,p_suffix_o                     in varchar2
  ,p_DATE_OF_DEATH_o              in date
  ,p_BACKGROUND_CHECK_STATUS_o    in varchar2
  ,p_BACKGROUND_DATE_CHECK_o      in date
  ,p_BLOOD_TYPE_o                 in varchar2
  ,p_CORRESPONDENCE_LANGUAGE_o    in varchar2
  ,p_FAST_PATH_EMPLOYEE_o         in varchar2
  ,p_FTE_CAPACITY_o               in number
  ,p_HOLD_APPLICANT_DATE_UNTIL_o  in date
  ,p_HONORS_o                     in varchar2
  ,p_INTERNAL_LOCATION_o          in varchar2
  ,p_LAST_MEDICAL_TEST_BY_o       in varchar2
  ,p_LAST_MEDICAL_TEST_DATE_o     in date
  ,p_MAILSTOP_o                   in varchar2
  ,p_OFFICE_NUMBER_o              in varchar2
  ,p_ON_MILITARY_SERVICE_o        in varchar2
  ,p_ORDER_NAME_o                 in varchar2
  ,p_PRE_NAME_ADJUNCT_o           in varchar2
  ,p_PROJECTED_START_DATE_o       in date
  ,p_REHIRE_AUTHORIZOR_o          in varchar2
  ,p_REHIRE_RECOMMENDATION_o      in varchar2
  ,p_RESUME_EXISTS_o              in varchar2
  ,p_RESUME_LAST_UPDATED_o        in date
  ,p_SECOND_PASSPORT_EXISTS_o     in varchar2
  ,p_STUDENT_STATUS_o             in varchar2
  ,p_WORK_SCHEDULE_o              in varchar2
  ,p_PER_INFORMATION21_o          in varchar2
  ,p_PER_INFORMATION22_o          in varchar2
  ,p_PER_INFORMATION23_o          in varchar2
  ,p_PER_INFORMATION24_o          in varchar2
  ,p_PER_INFORMATION25_o          in varchar2
  ,p_PER_INFORMATION26_o          in varchar2
  ,p_PER_INFORMATION27_o          in varchar2
  ,p_PER_INFORMATION28_o          in varchar2
  ,p_PER_INFORMATION29_o          in varchar2
  ,p_PER_INFORMATION30_o          in varchar2
  ,p_REHIRE_REASON_o              in varchar2
  ,p_BENEFIT_GROUP_ID_o           in varchar2
  ,p_RECEIPT_OF_DEATH_CERT_DATE_o in date
  ,p_COORD_BEN_MED_PLN_NO_o       in varchar2
  ,p_COORD_BEN_NO_CVG_FLAG_o      in varchar2
  ,p_coord_ben_med_ext_er_o       in varchar2
  ,p_coord_ben_med_pl_name_o      in varchar2
  ,p_coord_ben_med_insr_crr_nam_o in varchar2
  ,p_coord_ben_med_insr_crr_ide_o in varchar2
  ,p_coord_ben_med_cvg_strt_dt_o  in date
  ,p_coord_ben_med_cvg_end_dt_o   in date
  ,p_USES_TOBACCO_FLAG_o          in varchar2
  ,p_DPDNT_ADOPTION_DATE_o        in date
  ,p_DPDNT_VLNTRY_SVCE_FLAG_o     in varchar2
  ,p_ORIGINAL_DATE_OF_HIRE_o      in date
  ,p_town_of_birth_o              in varchar2
  ,p_region_of_birth_o            in varchar2
  ,p_country_of_birth_o           in varchar2
  ,p_global_person_id_o           in varchar2
  ,p_party_id_o                   in number
  ,p_npw_number_o                 in varchar2
  ,p_current_npw_flag_o           in varchar2
  ,p_global_name_o                in varchar2  -- #3889584
  ,p_local_name_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_per_rkd;

/
