--------------------------------------------------------
--  DDL for Package HR_FI_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FI_PERSON_API" AUTHID CURRENT_USER as
/* $Header: peperfii.pkh 120.5.12010000.1 2008/07/28 05:13:32 appldev ship $ */
/*#
 * This package contains person APIs for Finland.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Person for Finland
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_fi_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The following procedure updates the record of a Finnish Person.
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
 * The person will have been updated.
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
 * @param p_person_id Person whose record needs to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_person_type_id Person Type id.
 * @param p_last_name Last name of the person.
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
 * method determines when you can update the employee value. To keep the
 * existing employee number pass in hr_api.g_varchar2. When the API call
 * completes if p_validate is false then will be set to the employee number. If
 * p_validate is true then will be set to the passed value.
 * @param p_expense_check_send_to_addres Address to use as mailing address.
 * @param p_first_name Person's first name.
 * @param p_known_as Alternative name.
 * @param p_marital_status Marital status. Valid values are defined by
 * 'MAR_STATUS' lookup type.
 * @param p_nationality Person's nationality. Valid values are defined by
 * 'NATIONALITY' lookup type.
 * @param p_national_identifier National identifier.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Registered disabled flag.Valid values are
 * defined by 'REGISTERED_DISABLED' lookup type.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_title Person's title. Valid values are defined by 'TITLE' lookup
 * type.
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
 * @param p_place_of_residence Place of residence.
 * @param p_secondary_email Secondary e-mail.
 * @param p_epost_address E-post address.
 * @param p_speed_dial_number Speed dial number.
 * @param p_qualification Qualification.
 * @param p_level Level.Valid values are defined by 'FI_QUAL_LEVEL' lookup
 * type.
 * @param p_field Field.Valid values are defined by 'FI_QUAL_FIELD' lookup
 * type.
 * @param p_retirement_date Retirement date.
 * @param p_date_of_death Date of death.
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Blood group.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fast_path_employee Obsolete parameter, do not use.
 * @param p_fte_capacity Currently unsupported.
 * @param p_hold_applicant_date_until Date until when the applicant's
 * information is to be maintained.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office.
 * @param p_last_medical_test_by Name of physician who performed last medical
 * test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Internal mail location.
 * @param p_office_number Office number.
 * @param p_on_military_service Type of military service.
 * @param p_projected_start_date Currently unsupported.
 * @param p_rehire_authorizor Currently unsupported.
 * @param p_rehire_recommendation Rehire recommendation.
 * @param p_resume_exists Y/N flag indicating whether resume is on file.
 * @param p_resume_last_updated Date on which the resume was last updated.
 * @param p_second_passport_exists Y/N flag indicating whether person has
 * multiple passports.
 * @param p_student_status Type of student status.Valid values are defined by
 * 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Type of work schedule indicating which days person
 * works.Valid values are defined by 'WORK_SCHEDULE' lookup type.
 * @param p_rehire_reason Reason for re-hiring.
 * @param p_benefit_group_id Benefit group id.
 * @param p_receipt_of_death_cert_date Date the death certificate is received.
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
 * @param p_uses_tobacco_flag Uses tobacco list of values.Valid values are
 * defined by 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Dependent's adoption date.
 * @param p_dpdnt_vlntry_svce_flag Dependent's voluntary service flag.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_town_of_birth Town or city of birth.
 * @param p_region_of_birth Geographical region of birth.
 * @param p_country_of_birth Country of birth.
 * @param p_global_person_id Global ID for the person.
 * @param p_party_id Party ID for the person.
 * @param p_npw_number Non-payrolled worker number.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_full_name If p_validate is false, set to the complete full name of
 * the person. If p_validate is true, set to null.
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then will be set to the identifier of the person comment record. If
 * p_validate is true or no comment text exists, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning If set to true, an orginal date of hire exists
 * for a person who has never been an employee.
 * @param p_union_name Name of the Trade Union to which the person belongs.
 * @param p_membership_number Person's Trade Union membership number.
 * @param p_payment_mode Mode of Payment. The lookup type
 * 'FI_TRADE_UNION_FEE_TYPE' defines the valid values.
 * @param p_fixed_amount Amount  to deducted as Union membership
 * fees.
 * @param p_percentage Percentage of gross salary to deducted as Union
 * membership fees.
 * @param p_pension_joining_date Pension joining date.
 * @param p_pension_type Type of Pension. The lookup type
 * 'FI_PENSION_TYPES defines the valid values.
 * @param p_pension_group Pension Group.
 * @param p_planned_retirement_age Planned retirement date.
 * @param p_membership_start_date Union membership start date.
 * @param p_membership_end_date Union membership end date.
 * @param p_termination_date Termination date.
 * @param p_termination_reason Termination reason.
 * @param p_mother_tongue Mother Tongue
 * @param p_foreign_personal_id Foreign Personal ID
 * @param p_pension_insurance_number Pension Insurance Number
 * @rep:displayname Update Person for Finland
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_fi_person
  (p_validate                     in      boolean   default false
  ,p_effective_date               in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                  in      varchar2 default hr_api.g_varchar2
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
  ,p_place_of_residence        	  in      varchar2 default hr_api.g_varchar2
  ,p_secondary_email        	  in      varchar2 default hr_api.g_varchar2
  ,p_epost_address         	  in      varchar2 default hr_api.g_varchar2
  ,p_speed_dial_number        	  in      varchar2 default hr_api.g_varchar2
  ,p_qualification                in      varchar2 default hr_api.g_varchar2
  ,p_level	        	  in      varchar2 default hr_api.g_varchar2
  ,p_field	        	  in      varchar2 default hr_api.g_varchar2
  ,p_retirement_date        	  in      varchar2 default hr_api.g_varchar2
   ,p_union_name                   in      varchar2 default hr_api.g_varchar2
  ,p_membership_number            in      varchar2 default hr_api.g_varchar2
  ,p_payment_mode                 in      varchar2 default hr_api.g_varchar2
  ,p_fixed_amount                 in      varchar2 default hr_api.g_varchar2
  ,p_percentage                   in      varchar2 default hr_api.g_varchar2
  ,p_pension_joining_date         in      varchar2 default hr_api.g_varchar2
  ,p_pension_type                 in      varchar2 default hr_api.g_varchar2
  ,p_pension_group                in      varchar2 default hr_api.g_varchar2
  ,p_planned_retirement_age       in      varchar2 default hr_api.g_varchar2
  ,p_membership_start_date         in      varchar2 default hr_api.g_varchar2
  ,p_membership_end_date	   in      varchar2 default hr_api.g_varchar2
  ,p_termination_date         in      varchar2 default hr_api.g_varchar2
  ,p_termination_reason	   in	  varchar2     default hr_api.g_varchar2
   ,p_mother_tongue         in      varchar2     default hr_api.g_varchar2
  ,p_foreign_personal_id	   in	  varchar2     default hr_api.g_varchar2
   ,p_pension_insurance_number	in	  varchar2     default hr_api.g_varchar2
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

end HR_FI_PERSON_API;

/
