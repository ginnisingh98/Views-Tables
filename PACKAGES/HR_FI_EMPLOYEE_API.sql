--------------------------------------------------------
--  DDL for Package HR_FI_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FI_EMPLOYEE_API" AUTHID CURRENT_USER AS
/* $Header: peempfii.pkh 120.5.12010000.1 2008/07/28 04:34:56 appldev ship $ */
/*#
 * This package contains employee APIs for Finland.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Employee for Finland
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_fi_employee >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new employee record with a default primary assignment and
 * a period of service for the employee.
 *
 * This API is effectively an alternative to the API create_employee. If
 * p_validate is set to false, an employee is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * When creating an employee, a business group for the Finland legislation must
 * already exist. Also, a valid person_type_id, with a corresponding system
 * type of 'EMP' must be active and in the same business group as the employee
 * being created.
 *
 * <p><b>Post Success</b><br>
 * The person, primary assignment, and period of service will be successfully
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The person, primary assignment or period of service will not be created and
 * an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date Hire Date.
 * @param p_business_group_id The employee's business group.
 * @param p_last_name The employee's last name.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_person_type_id The person type id. If this value is omitted, then
 * the person_type_id of the default `EMP' system person type in the employee's
 * business group is used.
 * @param p_comments Employee comment text.
 * @param p_date_employee_data_verified The date on which the employee data was
 * last verified.
 * @param p_date_of_birth The employee's date of birth.
 * @param p_email_address The employee's email address.
 * @param p_employee_number The employee's number. If the number generation
 * method is Manual, then this parameter is mandatory. If the number generation
 * method is Automatic, then the value of this parameter must be NULL. If
 * p_validate is false and the employee number generation method is Automatic,
 * then this will be set to the generated employee number of the person
 * created. If p_validate is false and the employee number generation method is
 * Manual, then this will be set to the same value. If p_validate is true, then
 * this will be set to the same value.
 * @param p_expense_check_send_to_addres The employee's mailing address.
 * @param p_first_name The employee's first name.
 * @param p_known_as The employee's alternative name.
 * @param p_marital_status The employee's marital status. Valid values are
 * defined in the 'MAR_STATUS' lookup type.
 * @param p_nationality The employee's nationality.
 * @param p_national_identifier The employee's national identifier.
 * @param p_previous_last_name The employee's previous last name.
 * @param p_registered_disabled_flag Flag indicating whether the person is
 * classified as disabled.
 * @param p_title The employee's title. Valid values are defined in the 'TITLE'
 * lookup type.
 * @param p_vendor_id Obsolete parameter, do not use.
 * @param p_work_telephone The employee's work telephone.
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
 * @param p_place_of_residence The employee's place of residence.
 * @param p_secondary_email The employee's secondary e-mail address.
 * @param p_epost_address The employee's e-post address.
 * @param p_speed_dial_number The employee's speed dial number.
 * @param p_qualification The employee's qualification.
 * @param p_level The level values are defined in the 'FI_QUAL_LEVEL' lookup
 * type.
 * @param p_field The field values are defined by 'FI_QUAL_FIELD' lookup type.
 * @param p_retirement_date The employee's retirement date.
 * @param p_date_of_death The employee's date of death.
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date on which the background check was
 * performed.
 * @param p_blood_type Blood Type.
 * @param p_correspondence_language The employee's preferred language for
 * correspondence.
 * @param p_fast_path_employee Obsolete parameter, do not use.
 * @param p_fte_capacity Full time/part time availability for work.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office.
 * @param p_last_medical_test_by Name of physician who performed last medical
 * test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Office number.
 * @param p_on_military_service Y/N flag indicating whether person is employed
 * in military service.
 * @param p_projected_start_date Obsolete parameter, do not use.
 * @param p_resume_exists Y/N flag indicating whether resume is on file.
 * @param p_resume_last_updated Date resume last updated.
 * @param p_second_passport_exists Y/N flag indicating whether the person has
 * multiple passports.
 * @param p_student_status Full time/part time status of student.
 * @param p_work_schedule Type of work schedule indicating which days a person
 * works.Valid values are defined in the 'WORK_SCHEDULE' lookup type.
 * @param p_benefit_group_id Benefit group id.
 * @param p_receipt_of_death_cert_date Date the death certificate is received.
 * @param p_coord_ben_med_pln_no Secondary medical plan name. Column used for
 * external processing.
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
 * @param p_uses_tobacco_flag Type of tobacco used by the employee. Valid
 * values are defined in the 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Dependent's adoption date.
 * @param p_dpdnt_vlntry_svce_flag Dependent's voluntary service flag.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_town_of_birth Town or city of birth.
 * @param p_region_of_birth Geographical region of birth.
 * @param p_country_of_birth Country of birth.
 * @param p_global_person_id Global ID for the person.
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
 * @param p_per_effective_start_date If p_validate is false, then this will be
 * set to the effective start date of the person. If p_validate is true, then
 * this will be null.
 * @param p_per_effective_end_date If p_validate is false, then this will be
 * set to the effective end date of the person. If p_validate is true, then
 * this will be null.
 * @param p_full_name If p_validate is false, then this will be set to the
 * complete full name of the person. If p_validate is true, then this will be
 * null.
 * @param p_per_comment_id If p_validate is false, then this will be set to the
 * id of the corresponding person comment row, if any comment text exists. If
 * p_validate is true, then this will be null.
 * @param p_assignment_sequence If p_validate is false, then this will be set
 * to the sequence number of the primary assignment. If p_validate is true,
 * then this will be null.
 * @param p_assignment_number If p_validate is false, then this will be set to
 * the assignment number of the primary assignment. If p_validate is true, then
 * this will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning If set to true, an orginal date of hire exists
 * for a person who has never been an employee.
 * @param p_union_name Name of the Trade Union to which the employee belongs.
 * @param p_membership_number Employee's Trade Union membership number.
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
 * @rep:displayname Create Employee for Finland
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_fi_employee
  (p_validate                       in      boolean  default false
  ,p_hire_date                      in      date
  ,p_business_group_id              in      number
  ,p_last_name                      in      varchar2
  ,p_sex                            in      varchar2
  ,p_person_type_id                 in      number   default null
  ,p_comments                       in      varchar2 default null
  ,p_date_employee_data_verified    in      date     default null
  ,p_date_of_birth                  in      date     default null
  ,p_email_address                  in      varchar2 default null
  ,p_employee_number                in out  nocopy varchar2
  ,p_expense_check_send_to_addres   in      varchar2 default null
  ,p_first_name                     in      varchar2
  ,p_known_as                       in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
  ,p_nationality                    in      varchar2
  ,p_national_identifier            in      varchar2 default null
  ,p_previous_last_name             in      varchar2 default null
  ,p_registered_disabled_flag       in      varchar2 default null
  ,p_title                          in      varchar2
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
  ,p_place_of_residence             in      varchar2 default null
  ,p_secondary_email        	    in      varchar2 default null
  ,p_epost_address 		    in      varchar2 default null
  ,p_speed_dial_number        	    in      varchar2 default null
  ,p_qualification                  in      varchar2 default null
  ,p_level	        	    in      varchar2 default null
  ,p_field	        	    in      varchar2 default null
  ,p_retirement_date        	    in      varchar2 default null
  ,p_union_name                   in      varchar2 default null
  ,p_membership_number            in      varchar2 default null
  ,p_payment_mode                 in      varchar2 default null
  ,p_fixed_amount                 in      varchar2 default null
  ,p_percentage                   in      varchar2 default null
  ,p_pension_joining_date         in      varchar2 default null
  ,p_pension_type                 in      varchar2 default null
  ,p_pension_group                in      varchar2 default null
  ,p_planned_retirement_age       in      varchar2 default null
  ,p_membership_start_date         in      varchar2     default null
  ,p_membership_end_date	   in	  varchar2     default null
  ,p_termination_date         in      varchar2     default null
  ,p_termination_reason	   in	  varchar2     default null
  ,p_mother_tongue         in      varchar2     default null
  ,p_foreign_personal_id	   in	  varchar2     default null
  ,p_pension_insurance_number	in	  varchar2     default null
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
  ,p_projected_start_date           in      date     default null
  ,p_resume_exists                  in      varchar2 default null
  ,p_resume_last_updated            in      date     default null
  ,p_second_passport_exists         in      varchar2 default null
  ,p_student_status                 in      varchar2 default null
  ,p_work_schedule                  in      varchar2 default null
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



END HR_FI_EMPLOYEE_API;

/
