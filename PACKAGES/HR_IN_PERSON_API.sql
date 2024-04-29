--------------------------------------------------------
--  DDL for Package HR_IN_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_PERSON_API" AUTHID CURRENT_USER AS
/* $Header: peperini.pkh 120.2 2007/10/05 11:23:04 sivanara noship $ */
/*#
 * The package contains person APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Person for India
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_in_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the person record.
 *
 * This API updates the person record as identified by p_person_id and
 * p_object_version_number. Note: The business group must have the IN
 * legislation code.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person record, identified by p_person_id and p_object_version_number,
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * Updates the person.
 *
 * <p><b>Post Failure</b><br>
 * The API will not update the person and raises an error.
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
 * which needs to be updated.
 * @param p_last_name Last name of the person.
 * @param p_applicant_number Applicant number of the person.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified Date when the employee last verified
 * the data.
 * @param p_date_of_birth Date of birth of the person.
 * @param p_email_address Email address of the person.
 * @param p_employee_number The business group's employee number generation
 * method determines when you can update the employee value. To keep the
 * existing employee number pass in hr_api.g_varchar2. When the API call
 * completes if p_validate is false then will be set to the employee number. If
 * p_validate is true then will be set to the passed value.
 * @param p_expense_check_send_to_addres Mailing address of the person.
 * @param p_first_name First Name of the person.
 * @param p_alias_name Preferred name of the person, if different from first
 * name.
 * @param p_marital_status Marital status of the person. Valid values are
 * defined by 'MAR_STATUS' lookup type.
 * @param p_middle_names Person's middle name(s).
 * @param p_nationality Person's nationality. Valid values are defined by
 * 'NATIONALITY' lookup type.
 * @param p_ni_number National Identifier of the person.
 * @param p_previous_last_name Previous last name of the person.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values are defined by 'REGISTERED_DISABLED' lookup type.
 * @param p_sex Person's sex. Valid values are defined by 'SEX' lookup type.
 * @param p_title Title of the person. Valid values are defined by 'TITLE'
 * lookup type.
 * @param p_vendor_id Identifier of workers supplying organization.
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
 * @param p_NSSN NSSN of the person. Should be 14 digit number.
 * @param p_pan PAN of the person. Should be in correct format (XXXXX9999X).
 * @param p_pan_af PAN Applied for Flag. Valid values are defined by 'YES_NO'
 * lookup type. Has to be null if p_pan is populated.
 * @param p_ex_serviceman Military Status. Valid values are defined by 'YES_NO'
 * lookup type.
 * @param p_resident_status Residential Status of the person. Valid values are
 * defined by 'IN_RESIDENTIAL_STATUS' lookup type.
 * @param p_pf_number PF Number of the person.
 * @param p_esi_number ESI Nnumber of the person.
 * @param p_superannuation_number Superannuation Number of the person.
 * @param p_group_ins_number Group Insurance Number of the person.
 * @param p_gratuity_number Gratuity Number of the person.
 * @param p_pension_number Pension Number of the person.
 * @param p_date_of_death Obsolete Parameter, do not use.
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Type of blood group of the employee. Valid values are
 * defined by 'BLOOD_TYPE' lookup type
 * @param p_correspondence_language Preferred language for correspondance.
 * @param p_fast_path_employee Obsolete Parameter, do not use.
 * @param p_fte_capacity Full-time employment capacity of the person.
 * @param p_hold_applicant_date_until Date until which the applicant should be
 * put on hold.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office of the person.
 * @param p_last_medical_test_by Name of physician who performed last medical
 * test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Internal mail location for the person.
 * @param p_office_number Office Number of the person.
 * @param p_on_military_service Y/N flag indicating whether the person is
 * employed in military service.
 * @param p_pre_name_adjunct Name prefix.
 * @param p_projected_start_date Obsolete Parameter, do not use.
 * @param p_rehire_authorizor Obsolete Parameter, do not use.
 * @param p_rehire_recommendation Re-hire recommendation
 * @param p_resume_exists Y/N flag indicating whether resume is on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_second_passport_exists Y/N flag indicaing whether the person has
 * multiple passports.
 * @param p_student_status Full time/part time status of the person.
 * @param p_work_schedule Type of work schedule indicating which days the
 * person works. Valid values are defined by 'WORK_SCHEDULE' lookup type.
 * @param p_rehire_reason Reason for re-hiring the person.
 * @param p_suffix Person's suffix.
 * @param p_benefit_group_id Identification for benefit group.
 * @param p_receipt_of_death_cert_date Date death certificate is received.
 * @param p_coord_ben_med_pln_no Number of an externally provided medical plan.
 * @param p_coord_ben_no_cvg_flag No other coverage flag.
 * @param p_coord_ben_med_ext_er Secondary medical coverage external employer.
 * @param p_coord_ben_med_pl_name Secondary medical coverage name.
 * @param p_coord_ben_med_insr_crr_name Secondary medical coverage insurance
 * carrier.
 * @param p_coord_ben_med_insr_crr_ident Identifier for secondary medical
 * coverage insurance carrier.
 * @param p_coord_ben_med_cvg_strt_dt Secondary medical coverage effective
 * start date.
 * @param p_coord_ben_med_cvg_end_dt Secondary medical coverage effective end
 * date.
 * @param p_uses_tobacco_flag Tobacco type used by the person. Valid values are
 * defined by 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire of the person.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_place_of_birth Town or city of birth of the person.
 * @param p_region_of_birth Geographical region of birth of the person.
 * @param p_country_of_birth Country of birth of the person. Valid values are
 * defined in FND_TERRITORIES.
 * @param p_global_person_id Global Identification number for the person.
 * @param p_party_id Identifier for the party.
 * @param p_npw_number Number of non-payrolled worker.
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
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL..
 * @rep:displayname Update Person for India
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_in_person
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
  ,p_employee_number              in   out nocopy varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_alias_name                   in      varchar2 default hr_api.g_varchar2  --Bugfix 3762728
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
  ,p_pan                          in      varchar2 default hr_api.g_varchar2
  ,p_pan_af                       in      varchar2 default hr_api.g_varchar2
  ,p_ex_serviceman                in      varchar2 default hr_api.g_varchar2 --Bugfix 3762728
  ,p_resident_status              in      varchar2 default hr_api.g_varchar2
  ,p_pf_number                    in      varchar2 default hr_api.g_varchar2
  ,p_esi_number                   in      varchar2 default hr_api.g_varchar2
  ,p_superannuation_number        in      varchar2 default hr_api.g_varchar2
  ,p_group_ins_number             in      varchar2 default hr_api.g_varchar2
  ,p_gratuity_number              in      varchar2 default hr_api.g_varchar2
  ,p_pension_number          	  in      varchar2 default hr_api.g_varchar2
  ,p_NSSN                	  in      varchar2 default hr_api.g_varchar2
  --,p_employee_category            IN      varchar2 default hr_api.g_varchar2
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
  ,p_place_of_birth                in      varchar2 default hr_api.g_varchar2 --Bugfix 3762728
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
  );

END hr_in_person_api;

/
