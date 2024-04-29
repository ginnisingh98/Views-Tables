--------------------------------------------------------
--  DDL for Package HR_NL_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_EMPLOYEE_API" AUTHID CURRENT_USER as
/* $Header: peempnli.pkh 120.1 2005/10/02 02:16:29 aroussel $ */
/*#
 * This package contains employee APIs for the Netherlands.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Employee for Netherlands
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_nl_employee >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new employee for the Netherlands.
 *
 * The creation of a new Dutch employee includes a default primary assignment
 * and a period of service for the employee. The API calls the generic API
 * create_employee, with the parameters set as appropriate for a Dutch
 * employee. Secure user functionality is not included in this version of the
 * API. As this API is effectively an alternative to the API create_employee,
 * see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_employee.
 *
 * <p><b>Post Success</b><br>
 * When the person, primary assignment and period of service have been
 * successfully inserted, the following out parameters are set.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the employee, default assignment or period of
 * service, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date Hire Date.
 * @param p_business_group_id Business group of the person.
 * @param p_last_name Last name.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_person_type_id Type of employee being created.
 * @param p_comments Employee comment text.
 * @param p_date_employee_data_verified The date on which the employee data was
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
 * @param p_sofi_number SOFI Number. Subject to 11-proof validation.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Flag indicating whether the person is
 * classified as disabled.
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
 * @param p_date_of_death Date of death.
 * @param p_background_check_status Flag indicating whether the person's
 * background has been checked.
 * @param p_background_date_check Date on which the background check was
 * performed.
 * @param p_blood_type Blood type.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fast_path_employee New parameter, available on the latest version
 * of this API.
 * @param p_fte_capacity Obsolete parameter, do not use.
 * @param p_academic_title Honors or degrees awarded. Valid values are defined
 * by the lookup type 'HR_NL_ACADEMIC_TITLE'.
 * @param p_internal_location Internal location of office.
 * @param p_mailstop Internal mail location.
 * @param p_last_medical_test_by Name of physician who performed the last
 * medical test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_office_number Office number.
 * @param p_on_military_service Flag indicating whether the person is on
 * military service.
 * @param p_pre_name_adjunct First part of the last name.
 * @param p_rehire_recommendation New parameter, available on the latest
 * version of this API.
 * @param p_projected_start_date Obsolete parameter, do not use.
 * @param p_resume_exists Flag indicating whether the person's resume is on
 * file.
 * @param p_resume_last_updated Date on which the resume was last updated.
 * @param p_second_passport_exists Flag indicating whether a person has
 * multiple passports.
 * @param p_student_status If this employee is a student, this field is used to
 * capture their status. Valid values are defined by the STUDENT_STATUS lookup
 * type.
 * @param p_work_schedule The days on which this person will work.
 * @param p_suffix Suffix after the person's last name e.g. Sr., Jr., III.
 * @param p_benefit_group_id Benefit group to which this person will belong.
 * @param p_receipt_of_death_cert_date Date death certificate was received.
 * @param p_coord_ben_med_pln_no Secondary medical plan name. Column used for
 * external processing.
 * @param p_coord_ben_no_cvg_flag No secondary medical plan coverage. Column
 * used for external processing.
 * @param p_coord_ben_med_ext_er Secondary external medical coverage. Column
 * used for external processing.
 * @param p_coord_ben_med_pl_name Secondary medical coverage name. Column used
 * for external processing.
 * @param p_coord_ben_med_insr_crr_name Secondary medical coverage insurance
 * carrier name. Column used for external processing.
 * @param p_coord_ben_med_insr_crr_ident Identifies the secondary medical
 * coverage insurance carrier. Column used for external processing.
 * @param p_coord_ben_med_cvg_strt_dt Secondary medical coverage effective
 * start date. Column used for external processing.
 * @param p_coord_ben_med_cvg_end_dt Secondary medical coverage effective end
 * date. Column used for external processing.
 * @param p_uses_tobacco_flag Flag indicating whether the person uses tobacco.
 * @param p_dpdnt_adoption_date Date on which the dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Flag indicating whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_adjusted_svc_date New parameter, available on the latest version of
 * this API.
 * @param p_town_of_birth Town or city of birth.
 * @param p_region_of_birth Geographical region of birth.
 * @param p_country_of_birth Country of birth.
 * @param p_global_person_id Obsolete parameter, do not use.
 * @param p_party_id TCA party for whom you create the person record.
 * @param p_initials Initials of person.
 * @param p_special_title Special Title. Valid values are defined by the lookup
 * type 'HR_NL_SPECIAL_TITLE'.
 * @param p_subsequent_academic_title Subsequent Academic Title. Valid values
 * are defined by the lookup type 'HR_NL_SUB_ACADEMIC_TITLE'.
 * @param p_fullname_format Full Name Format. Valid values are defined by the
 * lookup type 'HR_NL_FULL_NAME_FORMAT'.
 * @param p_partner_prefix Partner Prefix.
 * @param p_partner_surname Partner Surname.
 * @param p_objection_received Objection Received Indicator. Valid values are
 * defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_objection_statement Objection Statement. A statement made by the
 * employee explaining why they object to the ethnic origin information being
 * held.
 * @param p_target_group Target Group Indicator as to whether an employee is
 * classed as being in a target group or not. Valid values are defined by the
 * lookup type 'HR_NL_YES_NO'.
 * @param p_birth_country_father Birth Country Father. Valid values are the
 * same as for parameter p_country_of_birth.
 * @param p_birth_country_mother Birth Country Mother. Valid values are the
 * same as for parameter p_country_of_birth.
 * @param p_addressing_female_employee Addressing Female Employee. How this is
 * done. Valid values are defined by the lookup type
 * 'NL_ADDRESSING_FEMALE_EMP'.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then set to
 * null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person. If p_validate is true,
 * then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, then set to the complete full
 * name of the person. If p_validate is true, then set to null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then will be set to the identifier of the created person comment
 * record. If p_validate is true or no comment text was provided, then will be
 * null.
 * @param p_assignment_sequence If p_validate is false, then set to the
 * sequence number of the default assignment. If p_validate is true, then set
 * to null.
 * @param p_assignment_number If p_validate is false, then set to the
 * assignment number of the default assignment. If p_validate is true, then set
 * to null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning Set to true if the original hire date is
 * populated and the person type is not "Employee", "Employee and Applicant",
 * "Ex-employee" or "Ex-employee and Applicant".
 * @param p_contract_at_other_company New parameter, available on the latest
 * version of this API.
 * @param p_work_abroad_exceeding_year New parameter, available on the latest
 * version of this API.
 * @param p_iza_participant_number New parameter, available on the latest
 * version of this API.
 * @rep:displayname Create Employee for Netherlands
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_nl_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_sofi_number                   in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in	  varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status	   in     varchar2 default null
  ,p_background_date_check	   in     varchar2 default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_academic_title                in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_rehire_recommendation         in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date default null
  ,p_coord_ben_med_cvg_end_dt      in     date default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in      varchar2 default null
  ,p_region_of_birth               in      varchar2 default null
  ,p_country_of_birth              in      varchar2 default null
  ,p_global_person_id              in      varchar2 default null
  ,p_party_id                      in      number   default null
  ,p_initials                      in      varchar2 default null
  ,p_special_title                 in      varchar2 default null
  ,p_subsequent_academic_title     in      varchar2 default null
  ,p_fullname_format               in      varchar2
  ,p_partner_prefix                in      varchar2 default null
  ,p_partner_surname               in      varchar2 default null
  ,p_objection_received            in      varchar2 default null
  ,p_objection_statement           in      varchar2 default null
  ,p_target_group                  in      varchar2 default null
  ,p_birth_country_father          in      varchar2 default null
  ,p_birth_country_mother          in      varchar2 default null
  ,p_addressing_female_employee    in      varchar2 default null
  ,p_work_abroad_exceeding_year    in      varchar2 default 'N'
  ,p_iza_participant_number        in      number   default null
  ,p_contract_at_other_company     in      varchar2 default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy boolean
  ,p_assign_payroll_warning           out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  );
--
end hr_nl_employee_api;

 

/
