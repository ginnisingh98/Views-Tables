--------------------------------------------------------
--  DDL for Package HR_MX_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_APPLICANT_API" AUTHID CURRENT_USER AS
/* $Header: hrmxwraa.pkh 120.1 2005/10/02 02:36:06 aroussel $ */
/*#
 * This package contains applicant APIs for Mexico.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Applicant for Mexico
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_mx_applicant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new applicant for Mexico.
 *
 * This API creates person details, an application, a default applicant
 * assignment, and (if required) associated assignment budget values and a
 * letter request. The process adds the applicant to the security lists so that
 * secure users can see the applicant.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The business group must exist on the effective date. The APL type must be
 * active in the same business group as the applicant you are creating. If you
 * do not specify a person_type_id, the API uses the default APL type for the
 * business group.
 *
 * <p><b>Post Success</b><br>
 * The application, default applicant assignment, and (if required) associated
 * assignment budget values and a letter request are created.
 *
 * <p><b>Post Failure</b><br>
 * The applicant is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received Date an application was received.
 * @param p_business_group_id Business group of the person.
 * @param p_paternal_last_name Paternal Last Name of the person.
 * @param p_person_type_id Type of applicant being created.
 * @param p_applicant_number Identifies the applicant number. If the number
 * generation method is Manual, then this parameter is mandatory. If the number
 * generation method is Automatic, then the value of this parameter must be
 * null. If p_validate is false and the applicant number generation method is
 * Automatic, then this will be set to the generated applicant number of the
 * person created. If p_validate is false and the applicant number generation
 * method is manual, then this will be set to the same value passed in. If
 * p_validate is true, then this will be set to the same value as passed in.
 * @param p_per_comments Person comment text.
 * @param p_date_employee_data_verified Date on which the applicant data was
 * last verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_expense_check_send_to_addres Mailing address.
 * @param p_first_name First name.
 * @param p_known_as Preferred name.
 * @param p_marital_status Marital status. Valid values are defined by the
 * MAR_STATUS lookup type.
 * @param p_second_name Second name.
 * @param p_nationality Nationality. Valid values are defined by the
 * NATIONALITY lookup type.
 * @param p_curp_id Mexican National Identifier
 * @param p_previous_last_name Obsolete parameter, do not use.
 * @param p_registered_disabled_flag Flag indicating whether the person is
 * classified as disabled.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_title Title. Valid values are defined by the TITLE lookup type.
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
 * @param p_maternal_last_name Maternal Last Name of the person.
 * @param p_rfc_id Federal Contributor Identifier (Registro Federal de
 * Contribuyentes).
 * @param p_ss_id Social Security Identifier.
 * @param p_imss_med_center Social Security Medical Center.
 * @param p_fed_gov_affil_id Federal Government Affiliation Identifier (Clave
 * de Afiliacion).
 * @param p_mil_serv_id Military Service Identifier (Cartilla Militar).
 * @param p_background_check_status Flag indicating whether the person's
 * background has been checked.
 * @param p_background_date_check Date on which the background check was
 * performed.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fte_capacity Obsolete parameter, do not use.
 * @param p_hold_applicant_date_until Date until when the applicant's
 * information is to be maintained.
 * @param p_honors Honors awarded.
 * @param p_mailstop Internal mail location.
 * @param p_office_number Office number.
 * @param p_on_military_service Flag indicating whether the person is on
 * military service.
 * @param p_pre_name_adjunct Prefix before the person's name.
 * @param p_projected_start_date Obsolete parameter, do not use.
 * @param p_resume_exists Flag indicating whether the person's resume is on
 * file.
 * @param p_resume_last_updated Date on which the resume was last updated.
 * @param p_student_status If this applicant is a student, this field is used
 * to capture their status. Valid values are defined by the STUDENT_STATUS
 * lookup type.
 * @param p_work_schedule Days on which this person will work.
 * @param p_suffix Suffix after the person's last name e.g. Sr., Jr., III.
 * @param p_date_of_death Date of death.
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
 * @param p_town_of_birth Town or city of birth.
 * @param p_region_of_birth Geographical region of birth.
 * @param p_country_of_birth Country of birth.
 * @param p_global_person_id Obsolete parameter, do not use.
 * @param p_party_id TCA party for whom you create the person record.
 * @param p_vacancy_id Identifies the vacancy for which this person has
 * applied.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_application_id If p_validate is false, then this uniquely
 * identifies the application created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then set to
 * null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_apl_object_version_number If p_validate is false, then set to the
 * version number of the created application. If p_validate is true, then set
 * to null.
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
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning If set to true, an orginal date of hire exists
 * for an applicant who has never been an employee.
 * @rep:displayname Create Applicant for Mexico
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_mx_applicant
      (p_validate                     in     boolean  default false
      ,p_date_received                in     date
      ,p_business_group_id            in     number
      ,p_paternal_last_name           in     varchar2
      ,p_person_type_id               in     number   default null
      ,p_applicant_number             in out nocopy varchar2
      ,p_per_comments                 in     varchar2 default null
      ,p_date_employee_data_verified  in     date     default null
      ,p_date_of_birth                in     date     default null
      ,p_email_address                in     varchar2 default null
      ,p_expense_check_send_to_addres in     varchar2 default null
      ,p_first_name                   in     varchar2 default null /* Bug 3695738 */
      ,p_known_as                     in     varchar2 default null
      ,p_marital_status               in     varchar2 default null
      ,p_second_name                  in     varchar2 default null
      ,p_nationality                  in     varchar2 default null
      ,p_curp_id                      in     varchar2 default null
      ,p_previous_last_name           in     varchar2 default null
      ,p_registered_disabled_flag     in     varchar2 default null
      ,p_sex                          in     varchar2 default null
      ,p_title                        in     varchar2 default null
      ,p_work_telephone               in     varchar2 default null
      ,p_attribute_category           in     varchar2 default null
      ,p_attribute1                   in     varchar2 default null
      ,p_attribute2                   in     varchar2 default null
      ,p_attribute3                   in     varchar2 default null
      ,p_attribute4                   in     varchar2 default null
      ,p_attribute5                   in     varchar2 default null
      ,p_attribute6                   in     varchar2 default null
      ,p_attribute7                   in     varchar2 default null
      ,p_attribute8                   in     varchar2 default null
      ,p_attribute9                   in     varchar2 default null
      ,p_attribute10                  in     varchar2 default null
      ,p_attribute11                  in     varchar2 default null
      ,p_attribute12                  in     varchar2 default null
      ,p_attribute13                  in     varchar2 default null
      ,p_attribute14                  in     varchar2 default null
      ,p_attribute15                  in     varchar2 default null
      ,p_attribute16                  in     varchar2 default null
      ,p_attribute17                  in     varchar2 default null
      ,p_attribute18                  in     varchar2 default null
      ,p_attribute19                  in     varchar2 default null
      ,p_attribute20                  in     varchar2 default null
      ,p_attribute21                  in     varchar2 default null
      ,p_attribute22                  in     varchar2 default null
      ,p_attribute23                  in     varchar2 default null
      ,p_attribute24                  in     varchar2 default null
      ,p_attribute25                  in     varchar2 default null
      ,p_attribute26                  in     varchar2 default null
      ,p_attribute27                  in     varchar2 default null
      ,p_attribute28                  in     varchar2 default null
      ,p_attribute29                  in     varchar2 default null
      ,p_attribute30                  in     varchar2 default null
      ,p_maternal_last_name           in     varchar2 default null
      ,p_rfc_id                       in     varchar2 default null
      ,p_ss_id                        in     varchar2 default null
      ,p_imss_med_center              in     varchar2 default null
      ,p_fed_gov_affil_id             in     varchar2 default null
      ,p_mil_serv_id                  in     varchar2 default null
      ,p_background_check_status      in     varchar2 default null
      ,p_background_date_check        in     date     default null
      ,p_correspondence_language      in     varchar2 default null
      ,p_fte_capacity                 in     number   default null
      ,p_hold_applicant_date_until    in     date     default null
      ,p_honors                       in     varchar2 default null
      ,p_mailstop                     in     varchar2 default null
      ,p_office_number                in     varchar2 default null
      ,p_on_military_service          in     varchar2 default null
      ,p_pre_name_adjunct             in     varchar2 default null
      ,p_projected_start_date         in     date     default null
      ,p_resume_exists                in     varchar2 default null
      ,p_resume_last_updated          in     date     default null
      ,p_student_status               in     varchar2 default null
      ,p_work_schedule                in     varchar2 default null
      ,p_suffix                       in     varchar2 default null
      ,p_date_of_death                in     date     default null
      ,p_benefit_group_id             in     number   default null
      ,p_receipt_of_death_cert_date   in     date     default null
      ,p_coord_ben_med_pln_no         in     varchar2 default null
      ,p_coord_ben_no_cvg_flag        in     varchar2 default 'N'
      ,p_uses_tobacco_flag            in     varchar2 default null
      ,p_dpdnt_adoption_date          in     date     default null
      ,p_dpdnt_vlntry_svce_flag       in     varchar2 default 'N'
      ,p_original_date_of_hire        in     date     default null
      ,p_town_of_birth                in     varchar2 default null
      ,p_region_of_birth              in     varchar2 default null
      ,p_country_of_birth             in     varchar2 default null
      ,p_global_person_id             in     varchar2 default null
      ,p_party_id                     in     number default null
      ,p_vacancy_id                   in     number default null
      ,p_person_id                       out nocopy number
      ,p_assignment_id                   out nocopy number
      ,p_application_id                  out nocopy number
      ,p_per_object_version_number       out nocopy number
      ,p_asg_object_version_number       out nocopy number
      ,p_apl_object_version_number       out nocopy number
      ,p_per_effective_start_date        out nocopy date
      ,p_per_effective_end_date          out nocopy date
      ,p_full_name                       out nocopy varchar2
      ,p_per_comment_id                  out nocopy number
      ,p_assignment_sequence             out nocopy number
      ,p_name_combination_warning        out nocopy boolean
      ,p_orig_hire_warning               out nocopy boolean
      );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< hire_mx_applicant >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API converts an applicant to an employee.
 *
 * This API converts data about a person of type Applicant (APL, APL_EX_APL or
 * EX_EMP_APL) to a person of type Employee (EMP). This conversion involves:
 * terminating the application record; terminating unaccepted applicant
 * assignments; setting the person type to EMP; creating a period of service
 * record; and converting accepted applicant assignments to active employee
 * assignments.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The applicant must exist in the relevant business group. If person_type_id
 * is supplied, it must have a corresponding system person type of EMP and be
 * active in the same business group as the applicant being changed to
 * employee.
 *
 * <p><b>Post Success</b><br>
 * The person, application, have been succesfully updated to employee with
 * default employee assignment and period of service inserted.
 *
 * <p><b>Post Failure</b><br>
 * The applicant is not hired as an employee and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date The person hire date and thus the effective start date of
 * the person, assignment, and period of service.
 * @param p_person_id Identifies the person record to modify.
 * @param p_assignment_id Identifies the assignment for which you create the
 * person record.
 * @param p_person_type_id Person type id. The default value is null. . If this
 * value is omitted, then the API uses the person_type_id of the default `EMP'
 * system person type in the employee's business group.
 * @param p_curp_id Mexican National Identifier
 * @param p_per_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_employee_number The business group's employee number generation
 * method determines when the API derives and passes out an employee number or
 * when the calling program should pass in a value. When the API call
 * completes, if p_validate is false, then set to the employee number. If
 * p_validate is true, then set to the passed value.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_unaccepted_asg_del_warning If set to true, then the unaccepted
 * applicant assignments have been terminated. It is set to false if the
 * unaccepted applicant assignments do not exist.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_oversubscribed_vacancy_id If one of the vacancies that the
 * applicant was hired from is now oversubscribed, this will contain the id of
 * the vacancy, otherwise it will be null for the applicant. The default is
 * null.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_migrate When True, will migrate global data of applicant to the
 * local use (addresses, phones, previous employers, qualifications etc).
 * @rep:displayname Hire Applicant for Mexico
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
*/
--
-- {End Of Comments}
--
PROCEDURE HIRE_MX_APPLICANT
  (p_validate                  in     boolean default false,
   p_hire_date                 in     date,
   p_person_id                 in     per_all_people_f.person_id%TYPE,
   p_assignment_id             in     number default null,
   p_person_type_id            in     number default null,
   p_curp_id                   in     per_all_people_f.national_identifier%type default hr_api.g_varchar2,
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_employee_number           in out nocopy  per_all_people_f.employee_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean,
   p_oversubscribed_vacancy_id    out nocopy  number,
   p_original_date_of_hire     in     date default null,
   p_migrate                   in     boolean default true
);

END HR_MX_APPLICANT_API;

 

/
