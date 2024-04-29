--------------------------------------------------------
--  DDL for Package HR_KW_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KW_PERSON_API" AUTHID CURRENT_USER as
/* $Header: peperkwi.pkh 120.2 2005/10/02 02:44:21 aroussel $ */
/*#
 * This package contains Person APIs for Kuwait.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Person for Kuwait
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_kw_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The following procedure updates a Kuwaiti person.
 *
 * This API updates the person record as identified by p_person_id and
 * p_object_version_number. Note: The business group must have the KW
 * legislation code.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The person will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the person and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date The effective date for this change.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_person_id Identifies the person record to modify.
 * @param p_object_version_number Must already exist to run the procedure. If
 * p_validate is false, set to the new version number of the updated person
 * record. If p_validate is true set to the same value you passed in.
 * @param p_person_type_id Person type ID. Person type changes are separately
 * maintained in per_person_type_usages_f table. So a composite person type is
 * not allowed as input unless it is the same as the type the person is holding
 * on p_effective_date.
 * @param p_family_name Last name.
 * @param p_applicant_number Applicant number.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified Date when the employee data was last
 * verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_employee_number Employee number.
 * @param p_expense_check_send_to_addres Mailing address.
 * @param p_first_name First name.
 * @param p_known_as Known as.
 * @param p_marital_status Marital status.
 * @param p_nationality Nationality.
 * @param p_national_identifier National identifier.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Registered disabled flag.
 * @param p_sex Gender.
 * @param p_title Title.
 * @param p_vendor_id Foreign key to PO_VENDORS.
 * @param p_work_telephone Work telephone.
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
 * @param p_father_name Father's Name.
 * @param p_grandfather_name Grandfather's Name.
 * @param p_alt_first_name Alternate first name.
 * @param p_alt_father_name Father's alternate name.
 * @param p_alt_grandfather_name Grandfather's alternate name.
 * @param p_alt_family_name Alternate family name.
 * @param p_previous_nationality Previous Nationality.
 * @param p_religion Religion.
 * @param p_date_of_death Currently unsupported.
 * @param p_background_check_status Background check status.
 * @param p_background_date_check Background date check.
 * @param p_blood_type Blood group.
 * @param p_correspondence_language Language for correspondence.
 * @param p_fast_path_employee Currently unsupported.
 * @param p_fte_capacity Full-time employment capacity.
 * @param p_hold_applicant_date_until Hold applicant until.
 * @param p_honors Honors.
 * @param p_internal_location Internal location.
 * @param p_last_medical_test_by Last medical test by.
 * @param p_last_medical_test_date Last medical test date.
 * @param p_mailstop Internal mail location.
 * @param p_office_number Office number.
 * @param p_on_military_service On military service.
 * @param p_projected_start_date Currently unsupported.
 * @param p_rehire_authorizor Currently unsupported.
 * @param p_rehire_recommendation Re-hire recommendation.
 * @param p_resume_exists Resume exists.
 * @param p_resume_last_updated Date resume last updated.
 * @param p_second_passport_exists Second passport available flag.
 * @param p_student_status Student status.
 * @param p_work_schedule Work schedule.
 * @param p_rehire_reason Reason for re-hiring.
 * @param p_benefit_group_id Id for benefit group.
 * @param p_receipt_of_death_cert_date Date death certificate was received.
 * @param p_coord_ben_med_pln_no Number of an externally provided medical plan.
 * @param p_coord_ben_no_cvg_flag No other coverage flag.
 * @param p_coord_ben_med_ext_er Secondary medical coverage external employer.
 * @param p_coord_ben_med_pl_name Secondary medical coverage name.
 * @param p_coord_ben_med_insr_crr_name Secondary medical coverage insurance
 * carrier.
 * @param p_coord_ben_med_insr_crr_ident Secondary medical coverage insurance
 * carrier id.
 * @param p_coord_ben_med_cvg_strt_dt Secondary medical coverage effective
 * start date.
 * @param p_coord_ben_med_cvg_end_dt Secondary medical coverage effective end
 * date.
 * @param p_uses_tobacco_flag Uses tobacco flag.Valid values are defined by
 * 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Dependent on voluntary service flag.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_town_of_birth Town or city of birth.
 * @param p_region_of_birth Geographical region of birth.
 * @param p_country_of_birth Country of birth.
 * @param p_global_person_id Global ID for the person.
 * @param p_party_id Party ID for the person.
 * @param p_npw_number Non-payrolled worker number.
 * @param p_effective_start_date If p_validate is false, set to the effective
 * start date of the person. If p_validate is true, set to null.
 * @param p_effective_end_date If p_validate is false, set to the effective end
 * date of the person. If p_validate is true, set to null.
 * @param p_full_name If p_validate is false, set to the complete full name of
 * the person. If p_validate is true, set to null.
 * @param p_comment_id If p_validate is false and any comment text exists, set
 * to the id of the corresponding person comment row. If p_validate is true, or
 * no comment text exists this will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name, and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Update Person for Kuwait
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_kw_person
  (p_validate                     in      boolean   default false
  ,p_effective_date               in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_family_name                  in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_national_identifier          in      varchar2 default hr_api.g_varchar2
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
  ,p_father_name             	  in      varchar2 default hr_api.g_varchar2
  ,p_grandfather_name             in      varchar2 default hr_api.g_varchar2
  ,p_alt_first_name               in      varchar2 default hr_api.g_varchar2
  ,p_alt_father_name              in      varchar2 default hr_api.g_varchar2
  ,p_alt_grandfather_name         in      varchar2 default hr_api.g_varchar2
  ,p_alt_family_name           	  in      varchar2 default hr_api.g_varchar2
  ,p_previous_nationality         in      varchar2 default hr_api.g_varchar2
  ,p_religion			  in      varchar2 default hr_api.g_varchar2
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
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
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
  ,p_effective_start_date            out nocopy  date
  ,p_effective_end_date              out nocopy  date
  ,p_full_name                       out nocopy  varchar2
  ,p_comment_id                      out nocopy  number
  ,p_name_combination_warning        out nocopy  boolean
  ,p_assign_payroll_warning          out nocopy  boolean
  ,p_orig_hire_warning               out nocopy  boolean
  );

end hr_kw_person_api;

 

/
