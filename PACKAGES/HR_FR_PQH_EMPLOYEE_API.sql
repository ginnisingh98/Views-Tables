--------------------------------------------------------
--  DDL for Package HR_FR_PQH_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_PQH_EMPLOYEE_API" AUTHID CURRENT_USER as
/* $Header: pqhpefri.pkh 120.1 2005/10/02 02:26:53 aroussel $ */
/*#
 * This package contains APIs to create employee records in Public Sector
 * France.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Employee for Public Sector France
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_fr_employee >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new employee for a French Public Sector legislation.
 *
 * Details recorded by this API include a default primary assignment and a
 * period of service for the employee. The API calls the generic HRMS API
 * create_employee, with the parameters set as appropriate for a France Public
 * Sector employee. Secure user functionality is not included in this version
 * of the API. As this API is effectively an alternative to the API
 * create_employee, see the HRMS Employee API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group must exist on the effective date. If person_type_id is
 * supplied, it must have a corresponding system person type of EMP and must be
 * active in the same business group as the employee being created.
 *
 * <p><b>Post Success</b><br>
 * The person, primary assignment and period of service records will be
 * created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the employee, default assignment or period of
 * service and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date The employee hire date and thus the effective start date
 * of the person, primary assignment and period of service.
 * @param p_business_group_id The employee's business group.
 * @param p_last_name Employee's last name.
 * @param p_sex Employee's gender..
 * @param p_person_type_id Person type id. If this value is omitted then the
 * person_type_id of the active default `EMP' system person type in the
 * employee's business group is used.
 * @param p_comments Comment text
 * @param p_date_employee_data_verified The date on which the employee data was
 * last verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_employee_number The business group's employee number generation
 * method determines when the API derives and passes out an employee number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is false then will be set to the employee number. If
 * p_validate is true then will be set to the passed value.
 * @param p_expense_check_send_to_addres Address to use as mailing address.
 * @param p_first_name Employee's first name.
 * @param p_known_as Alternative name.
 * @param p_marital_status Marital status.
 * @param p_middle_names Employee's middle names.
 * @param p_nationality Employee's nationality.
 * @param p_ni_number National Identifier Number.
 * @param p_previous_last_name Previous last name.
 * @param p_title Employee's title.
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
 * @param p_maiden_name Maiden name
 * @param p_department_of_birth Department of birth
 * @param p_town_of_birth Town of birth
 * @param p_country_of_birth Country of birth
 * @param p_number_of_dependents Number of dependents
 * @param p_military_status Military status
 * @param p_date_last_school_certificate Date of the last school certificate
 * @param p_school_name Name of the school that issued the certificate
 * @param p_level_of_education Level of education
 * @param p_date_first_entry_into_france Date first entry into France
 * @param p_cpam_name CPAM name
 * @param p_personal_mail_id Personal email ID
 * @param p_correspondence_language Preferred language for correspondence
 * @param p_fast_path_employee Currently unsupported
 * @param p_fte_capacity Full time or part time availability for work
 * @param p_honors Honors or degrees awarded
 * @param p_internal_location Internal location of office
 * @param p_mailstop Office identifier for internal mail
 * @param p_office_number Number of office
 * @param p_pre_name_adjunct First part of surname such as Van or De
 * @param p_projected_start_date Currently unsupported
 * @param p_resume_exists Y/N flag indicating whether resume is on file
 * @param p_resume_last_updated Date resume last updated
 * @param p_student_status Full time/part time status of student
 * @param p_work_schedule Type of work schedule indicating which days person
 * works
 * @param p_suffix Employee's suffix
 * @param p_person_id If p_validate is false, the process returns the unique
 * identifier of the person. If p_validate is true, it returns null.
 * @param p_assignment_id If p_validate is false, the process returns the
 * unique identifier of the created assignment. If p_validate is true, it
 * returns null.
 * @param p_per_object_version_number If p_validate is false, the process
 * returns the version number of the created Employee record . If p_validate is
 * true, it returns null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_per_effective_start_date If p_validate is false, the process
 * returns the effective start date of the person. If p_validate is true, it
 * returns null.
 * @param p_per_effective_end_date If p_validate is false, the process returns
 * the effective end date of the person. If p_validate is true, it returns
 * null.
 * @param p_full_name If p_validate is false, the process returns the complete
 * full name of the person. If p_validate is true, it returns null.
 * @param p_per_comment_id If p_validate is false, the process returns the
 * identifier of the corresponding person comment row, if any comment text
 * exists. If p_validate is true, it returns null.
 * @param p_assignment_sequence If p_validate is false, the process returns the
 * sequence number of the primary assignment. If p_validate is true, it returns
 * null.
 * @param p_assignment_number If p_validate is false, the process returns the
 * assignment number of the primary assignment. If p_validate is true, it
 * returns null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @rep:displayname Create Employee for Public Sector France
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_fr_employee
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
  ,p_ni_number                     in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
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
  ,p_maiden_name                   in     varchar2 default null
  ,p_department_of_birth           in     varchar2 default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_number_of_dependents          in     varchar2 default null
  ,p_military_status               in     varchar2 default null
  ,p_date_last_school_certificate  in     varchar2 default null
  ,p_school_name                   in     varchar2 default null
  ,p_level_of_education            in     varchar2 default null
  ,p_date_first_entry_into_france  in     varchar2 default null
  ,p_cpam_name                     in     varchar2 default null
  ,p_personal_mail_id 		   in 	  varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
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
  );
--
end hr_fr_pqh_employee_api;

 

/
