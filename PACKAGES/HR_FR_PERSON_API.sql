--------------------------------------------------------
--  DDL for Package HR_FR_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_PERSON_API" AUTHID CURRENT_USER as
/* $Header: peperfri.pkh 120.1 2005/10/02 02:20:54 aroussel $ */
/*#
 * This package contains an API to maintain a person record for France.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person for France
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_fr_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a person in a business group for France.
 *
 * This API updates the French person record as identified by p_person_id and
 * p_object_version_number. Note: The business group must have the FR
 * legislation code. This API is an alternative to the update_person API. See
 * update_person API for further details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person record, identified by p_person_id and p_object_version_number,
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * The person record is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API will not update the person and raises an error.
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
 * @param p_person_id Person whose record needs to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_person_type_id Type of person being updated.
 * @param p_last_name Last name.
 * @param p_applicant_number The business group's applicant number generation
 * method determines when the API derives and passes out an applicant number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is true then will be set to the applicant number. If
 * p_validate is true then will be set to the passed value.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified The date on which the person data was
 * last verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_employee_number The business group's employee number generation
 * method determines when the API derives and passes out an employee number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is false then will be set to the employee number. If
 * p_validate is true then will be set to the passed value.
 * @param p_expense_check_send_to_addres Mailing address.
 * @param p_first_name First name.
 * @param p_known_as Preferred name.
 * @param p_marital_status Marital status. Valid values are defined by the
 * MAR_STATUS lookup type.
 * @param p_middle_names Middle names.
 * @param p_nationality Nationality. Valid values are defined by the
 * NATIONALITY lookup type.
 * @param p_ni_number National Insurance number used to identify a person in
 * the format for France.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Flag indicating whether the person is
 * classified as disabled.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_title Title. Valid values are defined by the TITLE lookup type.
 * @param p_vendor_id Obsolete parameter, do not use.
 * @param p_work_telephone Obsolete parameter, do not use.
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
 * @param p_maiden_name Maiden name
 * @param p_department_of_birth Department. Valid values exist in the
 * 'FR_DEPARTMENT' lookup type.
 * @param p_town_of_birth Town of birth
 * @param p_country_of_birth Country of birth. Valid values are defined by
 * values in FND_TERRITORIES.
 * @param p_number_of_dependents Number of dependents
 * @param p_military_status Military status. Valid values are defined by the
 * 'FR_MILITARY_SERVICE_STATUS' lookup type.
 * @param p_date_last_school_certificate Date of last school certificate
 * @param p_school_name School name
 * @param p_level_of_education Level of education. Valid values exist in
 * PER_QUALIFICATION_TYPES.
 * @param p_date_first_entry_into_france Date of first entry into France
 * @param p_cpam_name A valid CPAM organization name defined in your business
 * group.
 * @param p_date_of_death Date of death.
 * @param p_background_check_status Flag indicating whether the person's
 * background has been checked.
 * @param p_background_date_check Date on which the background check was
 * performed.
 * @param p_blood_type Blood type.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fast_path_employee Obsolete parameter, do not use.
 * @param p_fte_capacity Obsolete parameter, do not use.
 * @param p_hold_applicant_date_until Date until when the applicant's
 * information is to be maintained.
 * @param p_honors Honors awarded.
 * @param p_internal_location Internal location of office.
 * @param p_last_medical_test_by Name of physician who performed the last
 * medical test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Internal mail location.
 * @param p_office_number Office number.
 * @param p_on_military_service Flag indicating whether the person is on
 * military service.
 * @param p_pre_name_adjunct First part of the last name.
 * @param p_projected_start_date Obsolete parameter, do not use.
 * @param p_rehire_authorizor Obsolete parameter, do not use.
 * @param p_rehire_recommendation Flag indicating whether this person should be
 * considered for rehire. Valid values are defined in YES_NO lookup type.
 * @param p_resume_exists Flag indicating whether the person's resume is on
 * file.
 * @param p_resume_last_updated Date on which the resume was last updated.
 * @param p_second_passport_exists Flag indicating whether a person has
 * multiple passports.
 * @param p_student_status If this person is a student, this field is used to
 * capture their status. Valid values are defined by the STUDENT_STATUS lookup
 * type.
 * @param p_work_schedule Days on which this person will work.
 * @param p_rehire_reason Rehire reason.
 * @param p_suffix Suffix after the person's last name e.g. Sr., Jr., III.
 * @param p_benefit_group_id Benefit group to which this person will belong.
 * @param p_receipt_of_death_cert_date Date death certificate was received.
 * @param p_coord_ben_med_pln_no Secondary medical plan name. Column used for
 * external processing.
 * @param p_coord_ben_no_cvg_flag No secondary medical plan coverage. Column
 * used for external processing.
 * @param p_uses_tobacco_flag Flag indicating whether the person uses tobacco.
 * @param p_dpdnt_adoption_date Date on which the dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Flag indicating whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_full_name If p_validate is false, then set to the complete full
 * name of the person. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created person comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning If set to true, an orginal date of hire exists
 * for a person who has never been an employee.
 * @rep:displayname Update Person for France
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure update_fr_person
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
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
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
  ,p_maiden_name                  in      varchar2 default hr_api.g_varchar2
  ,p_department_of_birth           in     varchar2 default hr_api.g_varchar2
  ,p_town_of_birth                 in     varchar2 default hr_api.g_varchar2
  ,p_country_of_birth              in     varchar2 default hr_api.g_varchar2
  ,p_number_of_dependents          in     varchar2 default hr_api.g_varchar2
  ,p_military_status               in     varchar2 default hr_api.g_varchar2
  ,p_date_last_school_certificate  in     varchar2 default hr_api.g_varchar2
  ,p_school_name                   in     varchar2 default hr_api.g_varchar2
  ,p_level_of_education            in     varchar2 default hr_api.g_varchar2
  ,p_date_first_entry_into_france  in     varchar2 default hr_api.g_varchar2
  ,p_cpam_name                     in     varchar2 default hr_api.g_varchar2
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
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_adjusted_svc_date            in      date     default hr_api.g_date
  ,p_effective_start_date         out nocopy     date
  ,p_effective_end_date           out nocopy     date
  ,p_full_name                    out nocopy     varchar2
  ,p_comment_id                   out nocopy     number
  ,p_name_combination_warning     out nocopy     boolean
  ,p_assign_payroll_warning       out nocopy     boolean
  ,p_orig_hire_warning            out nocopy     boolean
  );
--
end hr_fr_person_api;

 

/
