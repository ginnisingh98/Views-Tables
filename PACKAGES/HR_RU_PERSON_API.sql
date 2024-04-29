--------------------------------------------------------
--  DDL for Package HR_RU_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RU_PERSON_API" AUTHID CURRENT_USER as
/* $Header: peperrui.pkh 120.1 2005/10/02 02:44:40 aroussel $ */
/*#
 * This package contains update person APIs for Russia.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Update Person for Russia
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_ru_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the various person types for Russia.
 *
 * This API is effectively an alternative to the API update_person. If
 * p_validate is set to false, then the person record is updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person record must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The person entry will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the person and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_person_id Identifies the person record to modify.
 * @param p_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_person_type_id The person type identification of the person record
 * that needs to be updated.
 * @param p_last_name Person's last name.
 * @param p_applicant_number Applicant number of the person.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified The date on which the person last
 * verified the data.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address E-mail address of the person.
 * @param p_employee_number The business group's person number generation
 * method determines when you can update the person value. To keep the existing
 * person number pass in hr_api.g_varchar2. When the API call completes if
 * p_validate is false then will be set to the person number. If p_validate is
 * true then will be set to the passed value.
 * @param p_expense_check_send_to_addres Type of mailing address. Valid values
 * are defined by the 'HOME_OFFICE' lookup type.
 * @param p_first_name Person's first name.
 * @param p_known_as Alternative name of the person.
 * @param p_marital_status Marital status of the person. Valid values are
 * defined by the 'MAR_STATUS' lookup type.
 * @param p_middle_names Person's middle name(s).
 * @param p_nationality Person's nationality. Valid values are defined by the
 * 'NATIONALITY' lookup type.
 * @param p_inn National identifier.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values are defined by the 'REGISTERED_DISABLED' lookup type.
 * @param p_sex Person's sex.
 * @param p_title Person's title. Valid values are defined by the 'TITLE'
 * lookup type.
 * @param p_vendor_id Unique identifier of supplier.
 * @param p_work_telephone Work telephone of the person.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_place_of_birth Person's place of birth.Valid values are defined by
 * the 'RU_OKATO' lookup type.
 * @param p_references References for the person in case of rehire.
 * @param p_local_coefficient Valid for persons who live in Last North or
 * regions that are equated to the Last North region.
 * @param p_citizenship Person's citizenship. Valid values exist in the
 * 'RU_CITIZENSHIP' lookup type.
 * @param p_military_doc Military documents for the person. Valid values exist
 * in the 'RU_MILITARY_DOC_TYPE' lookup type.
 * @param p_reserve_category Reserve category of the person. Valid values exist
 * in 'RU_RESERVE_CATEGORY' lookup type.
 * @param p_military_rank Military rank of the person. Valid values exist in
 * 'RU_MILITARY_RANK' lookup type.
 * @param p_military_profile Military profile of the person. Valid values exist
 * in 'RU_MILITARY_PROFILE' lookup type.
 * @param p_military_reg_code Military registration board code of the person.
 * @param p_mil_srvc_readiness_category Military readiness service category of
 * the person. Valid values exist in 'RU_MILITARY_SERVICE_READINESS' lookup
 * type.
 * @param p_military_commissariat Military commissariat of the person.
 * @param p_quitting_mark Conscription dismissal mark of the person. Valid
 * values exist in 'RU_QUITTING_MARK' lookup type.
 * @param p_military_unit_number Military unit number of the person.
 * @param p_military_reg_type Military registration type. Valid values exist in
 * the 'RU_MILITARY_REGISTRATION' lookup type.
 * @param p_military_reg_details Military registration details.
 * @param p_pension_fund_number Pension fund number of the person.
 * @param p_date_of_death Date of death of the person.
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Type of blood group of the person. Valid values are
 * defined by the 'BLOOD_TYPE' lookup type.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fast_path_employee This parameter is currently unsupported.
 * @param p_fte_capacity Full time/part time availability for work.
 * @param p_hold_applicant_date_until Date until which the applicant should be
 * put on hold.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office.
 * @param p_last_medical_test_by Name of the physician who performed the last
 * medical test.
 * @param p_last_medical_test_date Date of the last medical test.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Office number of the person.
 * @param p_on_military_service Y/N flag indicating whether the person is
 * employed in military service.
 * @param p_genitive_last_name Genitive last name of the person
 * @param p_projected_start_date This parameter is currently unsupported.
 * @param p_rehire_authorizor This parameter is currently unsupported.
 * @param p_rehire_recommendation Rehire recommendation.
 * @param p_resume_exists Y/N flag indicating whether resume is on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_second_passport_exists Y/N flag indicating whether person has
 * multiple passports.
 * @param p_student_status Full time/part time status of student. Valid values
 * are defined by the 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Type of work schedule indicating which days the
 * person works. Valid values are defined by the 'WORK_SCHEDULE' lookup type.
 * @param p_rehire_reason Reason for rehiring the person.
 * @param p_suffix This parameter is currently unsupported.
 * @param p_benefit_group_id Identifies the benefit group.
 * @param p_receipt_of_death_cert_date Date when the death certificate was
 * received.
 * @param p_coord_ben_med_pln_no Coordination of benefits medical group plan
 * number.
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag.
 * @param p_coord_ben_med_ext_er Secondary medical coverage external employer.
 * @param p_coord_ben_med_pl_name Secondary medical coverage name.
 * @param p_coord_ben_med_insr_crr_name Secondary medical coverage insurance
 * carrier name.
 * @param p_coord_ben_med_insr_crr_ident Identifier for secondary medical
 * coverage insurance carrier.
 * @param p_coord_ben_med_cvg_strt_dt Secondary medical coverage effective
 * start date.
 * @param p_coord_ben_med_cvg_end_dt Secondary medical coverage effective end
 * date.
 * @param p_uses_tobacco_flag Tobacco type used by the person. Valid values are
 * defined by the 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire of the person.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_town_of_birth Town or city of birth of the person.
 * @param p_region_of_birth Geographical region of birth of the person.
 * @param p_country_of_birth Country of birth of the person.
 * @param p_global_person_id Global identification number for the person.
 * @param p_party_id Identifier for the party.
 * @param p_npw_number Number of non-payrolled worker.
 * @param p_effective_start_date If p_validate is false, this will be set to
 * the effective start date of the person. If p_validate is true, this will be
 * null.
 * @param p_effective_end_date If p_validate is false, this will be set to the
 * effective end date of the person. If p_validate is true, this will be null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true, this will be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created person record. If
 * p_validate is true or no comment text was provided, then this will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP, EMP_APL, EX_EMP, or EX_EMP_APL.
 * @rep:displayname Update Person for Russia
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ru_person
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
  ,p_expense_check_send_to_addres in      varchar2  default hr_api.g_varchar2
  ,p_first_name                   in      varchar2  default hr_api.g_varchar2
  ,p_known_as                     in      varchar2  default hr_api.g_varchar2
  ,p_marital_status               in      varchar2  default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2  default hr_api.g_varchar2
  ,p_nationality                  in      varchar2  default hr_api.g_varchar2
  ,p_inn		          in      varchar2  default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2  default hr_api.g_varchar2
  ,p_registered_disabled_flag     in      varchar2  default hr_api.g_varchar2
  ,p_sex                          in      varchar2  default hr_api.g_varchar2
  ,p_title                        in      varchar2  default hr_api.g_varchar2
  ,p_vendor_id                    in      number    default hr_api.g_number
  ,p_work_telephone               in      varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in      varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in      varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in      varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in      varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in      varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in      varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in      varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in      varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in      varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in      varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in      varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in      varchar2  default hr_api.g_varchar2
  ,p_place_of_birth               in      varchar2  default hr_api.g_varchar2
  ,p_references                   in      varchar2  default hr_api.g_varchar2
  ,p_local_coefficient            in      varchar2  default hr_api.g_varchar2
  ,p_citizenship                  in      varchar2  default hr_api.g_varchar2
  ,p_military_doc                 in      varchar2  default hr_api.g_varchar2
  ,p_reserve_category             in      varchar2  default hr_api.g_varchar2
  ,p_military_rank                in      varchar2  default hr_api.g_varchar2
  ,p_military_profile             in      varchar2  default hr_api.g_varchar2
  ,p_military_reg_code            in      varchar2  default hr_api.g_varchar2
  ,p_mil_srvc_readiness_category  in      varchar2  default hr_api.g_varchar2
  ,p_military_commissariat        in      varchar2  default hr_api.g_varchar2
  ,p_quitting_mark                in      varchar2  default hr_api.g_varchar2
  ,p_military_unit_number         in      varchar2  default hr_api.g_varchar2
  ,p_military_reg_type		  in      varchar2  default  hr_api.g_varchar2
  ,p_military_reg_details	  in      varchar2  default  hr_api.g_varchar2
  ,p_pension_fund_number          in      varchar2  default hr_api.g_varchar2
  ,p_date_of_death                in      date      default hr_api.g_date
  ,p_background_check_status      in      varchar2  default hr_api.g_varchar2
  ,p_background_date_check        in      date      default hr_api.g_date
  ,p_blood_type                   in      varchar2  default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2  default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2  default hr_api.g_varchar2
  ,p_fte_capacity                 in      number    default hr_api.g_number
  ,p_hold_applicant_date_until    in      date      default hr_api.g_date
  ,p_honors                       in      varchar2  default hr_api.g_varchar2
  ,p_internal_location            in      varchar2  default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2  default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date      default hr_api.g_date
  ,p_mailstop                     in      varchar2  default hr_api.g_varchar2
  ,p_office_number                in      varchar2  default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2  default hr_api.g_varchar2
  ,p_genitive_last_name           in      varchar2  default hr_api.g_varchar2
  ,p_projected_start_date         in      date      default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2  default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2  default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2  default hr_api.g_varchar2
  ,p_resume_last_updated          in      date      default hr_api.g_date
  ,p_second_passport_exists       in      varchar2  default hr_api.g_varchar2
  ,p_student_status               in      varchar2  default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2  default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2  default hr_api.g_varchar2
  ,p_suffix                       in      varchar2  default hr_api.g_varchar2
  ,p_benefit_group_id             in      number    default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date      default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2  default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_ext_er         in      varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_pl_name        in      varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_name  in      varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_ident in      varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_cvg_strt_dt    in      date      default hr_api.g_date
  ,p_coord_ben_med_cvg_end_dt     in      date      default hr_api.g_date
  ,p_uses_tobacco_flag            in      varchar2  default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date      default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2  default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date      default hr_api.g_date
  ,p_adjusted_svc_date            in      date      default hr_api.g_date
  ,p_town_of_birth                in      varchar2  default hr_api.g_varchar2
  ,p_region_of_birth              in      varchar2  default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2  default hr_api.g_varchar2
  ,p_global_person_id             in      varchar2  default hr_api.g_varchar2
  ,p_party_id                     in      number    default hr_api.g_number
  ,p_npw_number                   in      varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         out nocopy     date
  ,p_effective_end_date           out nocopy     date
  ,p_full_name                    out nocopy     varchar2
  ,p_comment_id                   out nocopy     number
  ,p_name_combination_warning     out nocopy     boolean
  ,p_assign_payroll_warning       out nocopy     boolean
  ,p_orig_hire_warning            out nocopy     boolean
  ) ;
end hr_ru_person_api;


 

/
