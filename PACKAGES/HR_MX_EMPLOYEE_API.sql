--------------------------------------------------------
--  DDL for Package HR_MX_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_EMPLOYEE_API" AUTHID CURRENT_USER AS
/* $Header: pemxwree.pkh 120.1 2005/10/02 02:43:03 aroussel $ */
/*#
 * This package contains employee APIs for Mexico.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Employee for Mexico
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_mx_employee >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new employee for Mexico.
 *
 * This API creates a default primary assignment and a period of service for
 * the employee. Secure user functionality is included in this version of the
 * API. The employee is visible to secure users in the business group. HR
 * Foundation users can use the following parameters only: p_validate,
 * p_hire_date, p_business_group_id, p_last_name, p_previous_last_name,
 * p_mailstop, p_office_number, p_internal_location, p_correspondence_language,
 * p_known_as, p_sex, p_date_of_birth, p_email_address, p_employee_number,
 * p_expense_check_send_to_addres, p_first_name, p_middle_names,
 * p_national_identifier, p_title, p_attribute_category, and p_attribute1-30.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The business group must exist on the effective date. If person_type_id is
 * supplied, it must have a corresponding system person type of EMP and must be
 * active in the same business group as the employee being created.
 *
 * <p><b>Post Success</b><br>
 * The person, period of service, and default employee assignment are created.
 *
 * <p><b>Post Failure</b><br>
 * The employee is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date Hire Date.
 * @param p_business_group_id Business group of the person.
 * @param p_paternal_last_name Last name.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_person_type_id Type of employee being created.
 * @param p_comments Person comment text.
 * @param p_date_employee_data_verified Date on which the employee data was
 * last verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_employee_number The business group's employee number generation
 * method determines when the API derives and passes out an employee number or
 * when the calling program should pass in a value. When the API call
 * completes, if p_validate is false, then set to the employee number. If
 * p_validate is true, then set to the passed value.
 * @param p_expense_check_send_to_addres Mailing address.
 * @param p_first_name First name.
 * @param p_known_as Preferred name.
 * @param p_marital_status Marital status. Valid values are defined by the
 * MAR_STATUS lookup type.
 * @param p_second_name Second name of the person.
 * @param p_nationality Nationality. Valid values are defined by the
 * NATIONALITY lookup type.
 * @param p_curp_id Mexican National Identifier.
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
 * @param p_maternal_last_name Maternal last name of the person.
 * @param p_rfc_id Federal Contributor Identifier (Registro Federal de
 * Contribuyentes).
 * @param p_ss_id Social Security Identifier.
 * @param p_imss_med_center Social Security Medical Center.
 * @param p_fed_gov_affil_id Federal Government Affiliation Identifier (Clave
 * de Afiliacion).
 * @param p_mil_serv_id Military Service Identifier (Cartilla Militar).
 * @param p_date_of_death Date of death.
 * @param p_background_check_status Flag indicating whether the person's
 * background has been checked.
 * @param p_background_date_check Date on which the background check was
 * performed.
 * @param p_blood_type Blood type.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fast_path_employee Obsolete parameter, do not use.
 * @param p_fte_capacity Obsolete parameter, do not use.
 * @param p_honors Honors awarded.
 * @param p_internal_location Internal location of office.
 * @param p_last_medical_test_by Name of physician who performed the last
 * medical test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Internal mail location.
 * @param p_office_number Office number.
 * @param p_on_military_service Flag indicating whether the person is on
 * military service.
 * @param p_pre_name_adjunct Prefix before the person's name.
 * @param p_rehire_recommendation Obsolete parameter, do not use.
 * @param p_projected_start_date Obsolete parameter, do not use.
 * @param p_resume_exists Flag indicating whether the person's resume is on
 * file.
 * @param p_resume_last_updated Date on which the resume was last updated.
 * @param p_second_passport_exists Flag indicating whether a person has
 * multiple passports.
 * @param p_student_status If this employee is a student, this field is used to
 * capture their status. Valid values are defined by the STUDENT_STATUS lookup
 * type.
 * @param p_work_schedule Days on which this person will work.
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
 * @param p_coord_ben_med_insr_crr_ident Secondary medical coverage insurance
 * carrier identifier. Column used for external processing.
 * @param p_coord_ben_med_cvg_strt_dt Secondary medical coverage effective
 * start date. Column used for external processing.
 * @param p_coord_ben_med_cvg_end_dt Secondary medical coverage effective end
 * date. Column used for external processing.
 * @param p_uses_tobacco_flag Flag indicating whether the person uses tobacco.
 * @param p_dpdnt_adoption_date Date on which the dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Flag indicating whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_town_of_birth Town or city of birth.
 * @param p_region_of_birth Geographical region of birth.
 * @param p_country_of_birth Country of birth.
 * @param p_global_person_id Obsolete parameter, do not use.
 * @param p_party_id TCA party for whom you create the person record.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
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
 * populated and the person type is not &quot;Employee&quot;, &quot;Employee
 * and Applicant&quot;, &quot;Ex-employee&quot; or &quot;Ex-employee and
 * Applicant&quot;.
 * @rep:displayname Create Employee for Mexico
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_mx_employee
  (p_validate                       in      boolean  default false
  ,p_hire_date                      in      date
  ,p_business_group_id              in      number
  ,p_paternal_last_name             in      varchar2
  ,p_sex                            in      varchar2
  ,p_person_type_id                 in      number   default null
  ,p_comments                       in      varchar2 default null
  ,p_date_employee_data_verified    in      date     default null
  ,p_date_of_birth                  in      date     default null
  ,p_email_address                  in      varchar2 default null
  ,p_employee_number                in out  nocopy varchar2
  ,p_expense_check_send_to_addres   in      varchar2 default null
  ,p_first_name                     in      varchar2 default null
  ,p_known_as                       in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
  ,p_second_name                    in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_CURP_id                        in      varchar2 default null
  ,p_registered_disabled_flag       in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_vendor_id                      in      number   default null
  ,p_work_telephone                 in      varchar2 default null
  ,p_attribute_category             in      varchar2 default null
  ,p_attribute1                     in      varchar2 default null
  ,p_attribute2                     in      varchar2 default null
  ,p_attribute3                     in      varchar2 default null
  ,p_attribute4                     in      varchar2 default null
  ,p_attribute5                     in      varchar2 default null
  ,p_attribute6                     in      varchar2 default null
  ,p_attribute7                     in      varchar2 default null
  ,p_attribute8                     in      varchar2 default null
  ,p_attribute9                     in      varchar2 default null
  ,p_attribute10                    in      varchar2 default null
  ,p_attribute11                    in      varchar2 default null
  ,p_attribute12                    in      varchar2 default null
  ,p_attribute13                    in      varchar2 default null
  ,p_attribute14                    in      varchar2 default null
  ,p_attribute15                    in      varchar2 default null
  ,p_attribute16                    in      varchar2 default null
  ,p_attribute17                    in      varchar2 default null
  ,p_attribute18                    in      varchar2 default null
  ,p_attribute19                    in      varchar2 default null
  ,p_attribute20                    in      varchar2 default null
  ,p_attribute21                    in      varchar2 default null
  ,p_attribute22                    in      varchar2 default null
  ,p_attribute23                    in      varchar2 default null
  ,p_attribute24                    in      varchar2 default null
  ,p_attribute25                    in      varchar2 default null
  ,p_attribute26                    in      varchar2 default null
  ,p_attribute27                    in      varchar2 default null
  ,p_attribute28                    in      varchar2 default null
  ,p_attribute29                    in      varchar2 default null
  ,p_attribute30                    in      varchar2 default null
  ,p_maternal_last_name             in      varchar2 default null
  ,p_RFC_id                         in      varchar2 default null
  ,p_SS_id                          in      varchar2 default null
  ,p_IMSS_med_center                in      varchar2 default null
  ,p_fed_gov_affil_id               in      varchar2 default null
  ,p_mil_serv_id                    in      varchar2 default null
  ,p_date_of_death                  in      date     default null
  ,p_background_check_status        in      varchar2 default null
  ,p_background_date_check          in      date     default null
  ,p_blood_type                     in      varchar2 default null
  ,p_correspondence_language        in      varchar2 default null
  ,p_fast_path_employee             in      varchar2 default null
  ,p_fte_capacity                   in      number   default null
  ,p_honors                         in      varchar2 default null
  ,p_internal_location              in      varchar2 default null
  ,p_last_medical_test_by           in      varchar2 default null
  ,p_last_medical_test_date         in      date     default null
  ,p_mailstop                       in      varchar2 default null
  ,p_office_number                  in      varchar2 default null
  ,p_on_military_service            in      varchar2 default null
  ,p_pre_name_adjunct               in      varchar2 default null
  ,p_rehire_recommendation          in      varchar2 default null
  ,p_projected_start_date           in      date     default null
  ,p_resume_exists                  in      varchar2 default null
  ,p_resume_last_updated            in      date     default null
  ,p_second_passport_exists         in      varchar2 default null
  ,p_student_status                 in      varchar2 default null
  ,p_work_schedule                  in      varchar2 default null
  ,p_suffix                         in      varchar2 default null
  ,p_benefit_group_id               in      number   default null
  ,p_receipt_of_death_cert_date     in      date     default null
  ,p_coord_ben_med_pln_no           in      varchar2 default null
  ,p_coord_ben_no_cvg_flag          in      varchar2 default 'N'
  ,p_coord_ben_med_ext_er           in      varchar2 default null
  ,p_coord_ben_med_pl_name          in      varchar2 default null
  ,p_coord_ben_med_insr_crr_name    in      varchar2 default null
  ,p_coord_ben_med_insr_crr_ident   in      varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt      in      date     default null
  ,p_coord_ben_med_cvg_end_dt       in      date     default null
  ,p_uses_tobacco_flag              in      varchar2 default null
  ,p_dpdnt_adoption_date            in      date     default null
  ,p_dpdnt_vlntry_svce_flag         in      varchar2 default 'N'
  ,p_original_date_of_hire          in      date     default null
  ,p_adjusted_svc_date              in      date     default null
  ,p_town_of_birth                  in      varchar2 default null
  ,p_region_of_birth                in      varchar2 default null
  ,p_country_of_birth               in      varchar2 default null
  ,p_global_person_id               in      varchar2 default null
  ,p_party_id                       in      number   default null
  ,p_person_id                      out     nocopy number
  ,p_assignment_id                  out     nocopy number
  ,p_per_object_version_number      out     nocopy number
  ,p_asg_object_version_number      out     nocopy number
  ,p_per_effective_start_date       out     nocopy date
  ,p_per_effective_end_date         out     nocopy date
  ,p_full_name                      out     nocopy varchar2
  ,p_per_comment_id                 out     nocopy number
  ,p_assignment_sequence            out     nocopy number
  ,p_assignment_number              out     nocopy varchar2
  ,p_name_combination_warning       out     nocopy boolean
  ,p_assign_payroll_warning         out     nocopy boolean
  ,p_orig_hire_warning              out     nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< mx_hire_into_job >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 *
 * This API hires a person for Mexico by converting the person of type
 * Applicant to a person of type Employee (EMP).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The applicant must exist in the relevant business group and must have an
 * applicant assignment with the assignment status Accepted. If person_type_id
 * is supplied, it must have a corresponding system person type of EMP and must
 * be active in the same business group as the applicant being changed to
 * employee.
 *
 * <p><b>Post Success</b><br>
 * The applicant has been successfully hired as an employee with a default
 * employee assignment.
 *
 * <p><b>Post Failure</b><br>
 * The applicant is not hired as an employee and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person record to modify.
 * @param p_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_employee_number The business group's employee number generation
 * method determines when you can update the employee value. To keep the
 * existing employee number pass in hr_api.g_varchar2. When the API call
 * completes, if p_validate is false, then set to the employee number. If
 * p_validate is true, then set to the passed value.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_person_type_id Type of employee being created.
 * @param p_curp_id Mexican National Identifier.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning If set to true, an orginal date of hire exists
 * for an applicant who has never been an employee.
 * @rep:displayname Hire Into Job for Mexico
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
PROCEDURE mx_hire_into_job
  (p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_employee_number              IN OUT NOCOPY VARCHAR2
  ,p_datetrack_update_mode        IN     VARCHAR2 DEFAULT NULL
  ,p_person_type_id               IN     NUMBER   DEFAULT NULL
  ,p_CURP_id                      IN     VARCHAR2 DEFAULT NULL
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  ,p_orig_hire_warning               OUT NOCOPY BOOLEAN
  ) ;


END HR_MX_EMPLOYEE_API ;

 

/
