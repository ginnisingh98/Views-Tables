--------------------------------------------------------
--  DDL for Package HR_FR_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_APPLICANT_API" AUTHID CURRENT_USER as
/* $Header: peappfri.pkh 120.1 2005/10/02 02:10:20 aroussel $ */
/*#
 * This package contains an applicant API for France.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Applicant for France
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_fr_applicant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new applicant for France.
 *
 * A default primary assignment and an application for the applicant is
 * created. The API calls the generic API create_applicant, with the parameters
 * set as appropriate for the French applicant. Secure user functionality is
 * not included in this version of the API. For further information see
 * create_applicant API since this API is an alternative for that API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A business group with a legislation code of FR must be specified.
 *
 * <p><b>Post Success</b><br>
 * The person, primary assignment and application are successfully created in
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the applicant, default assignment or application and
 * raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received Date an application was received.
 * @param p_business_group_id Business group of the person.
 * @param p_last_name Last name.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_person_type_id Type of applicant being created.
 * @param p_applicant_number The business group's applicant number generation
 * method determines when the API derives and passes out an applicant number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is true then will be set to the applicant number. If
 * p_validate is true then will be set to the passed value.
 * @param p_comments Person comment text.
 * @param p_date_employee_data_verified Date on which the applicant data was
 * last verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_expense_check_send_to_addres Mailing address.
 * @param p_first_name First name.
 * @param p_known_as Preferred name.
 * @param p_marital_status Marital status. Valid values are defined by the
 * MAR_STATUS lookup type.
 * @param p_middle_names Middle names.
 * @param p_nationality Nationality. Valid values are defined by the
 * NATIONALITY lookup type.
 * @param p_ni_number National Insurance number used to identify an applicant
 * in the format for France.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Flag indicating whether the person is
 * classified as disabled.
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
 * @param p_maiden_name Maiden name
 * @param p_department_of_birth Department of birth. Valid values are defined
 * by the 'FR_DEPARTMENT' lookup type.
 * @param p_town_of_birth Town or city of birth.
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
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fte_capacity Obsolete parameter, do not use.
 * @param p_hold_applicant_date_until Date until when the applicant's
 * information is to be maintained.
 * @param p_honors Honors awarded.
 * @param p_mailstop Internal mail location.
 * @param p_office_number Office number.
 * @param p_pre_name_adjunct First part of the last name.
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
 * @rep:displayname Create Applicant for France
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_fr_applicant
  (p_validate                      in     boolean  default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2 default null
  ,p_person_type_id                in     number   default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_ni_number                     in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
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
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_application_id                   out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  );
--
end hr_fr_applicant_api;

 

/
