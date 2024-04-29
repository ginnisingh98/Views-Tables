--------------------------------------------------------
--  DDL for Package HR_JPBP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JPBP_API" AUTHID CURRENT_USER as
/* $Header: pejpapi.pkh 120.3 2005/11/02 06:12:43 sgottipa noship $ */
/*#
 * This package contains business process APIs for Japan.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Business Process for Japan
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_jp_educ_sit >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a special information record of JP Educational Background
 * for a person identified by person_id for the Japan localization.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A person identified by person_id must exist in a JP business group. Special
 * Information Type of JP Educational Background must be set enabled against
 * the business group.
 *
 * <p><b>Post Success</b><br>
 * The special information will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The special information will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person for whom you create the special
 * information record.
 * @param p_business_group_id Business group id.
 * @param p_effective_date Reference date for validating the person. This date
 * does not determine when the changes take effect.
 * @param p_comments Comment text.
 * @param p_date_from {@rep:casecolumn PER_PERSON_ANALYSES.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PER_PERSON_ANALYSES.DATE_TO}
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
 * @param p_segment1 JP Educ Bkgrd flexfield segment.
 * @param p_segment2 JP Educ Bkgrd flexfield segment.
 * @param p_segment3 JP Educ Bkgrd flexfield segment.
 * @param p_segment4 JP Educ Bkgrd flexfield segment.
 * @param p_segment5 JP Educ Bkgrd flexfield segment.
 * @param p_segment6 JP Educ Bkgrd flexfield segment.
 * @param p_segment7 JP Educ Bkgrd flexfield segment.
 * @param p_segment8 JP Educ Bkgrd flexfield segment.
 * @param p_segment9 JP Educ Bkgrd flexfield segment.
 * @param p_segment10 JP Educ Bkgrd flexfield segment.
 * @param p_segment11 JP Educ Bkgrd flexfield segment.
 * @param p_segment12 JP Educ Bkgrd flexfield segment.
 * @param p_segment13 JP Educ Bkgrd flexfield segment.
 * @param p_segment14 JP Educ Bkgrd flexfield segment.
 * @param p_segment15 JP Educ Bkgrd flexfield segment.
 * @param p_segment16 JP Educ Bkgrd flexfield segment.
 * @param p_segment17 JP Educ Bkgrd flexfield segment.
 * @param p_segment18 JP Educ Bkgrd flexfield segment.
 * @param p_segment19 JP Educ Bkgrd flexfield segment.
 * @param p_segment20 JP Educ Bkgrd flexfield segment.
 * @param p_segment21 JP Educ Bkgrd flexfield segment.
 * @param p_segment22 JP Educ Bkgrd flexfield segment.
 * @param p_segment23 JP Educ Bkgrd flexfield segment.
 * @param p_segment24 JP Educ Bkgrd flexfield segment.
 * @param p_segment25 JP Educ Bkgrd flexfield segment.
 * @param p_segment26 JP Educ Bkgrd flexfield segment.
 * @param p_segment27 JP Educ Bkgrd flexfield segment.
 * @param p_segment28 JP Educ Bkgrd flexfield segment.
 * @param p_segment29 JP Educ Bkgrd flexfield segment.
 * @param p_segment30 JP Educ Bkgrd flexfield segment.
 * @param p_analysis_criteria_id If p_validate is false, this uniquely
 * identifies the combination of the personal analysis flexfield segments
 * created. If p_validate is true this parameter will be null.
 * @param p_person_analysis_id If p_validate is false, this uniquely identifies
 * the special information record created. If p_validate is true this parameter
 * will be null.
 * @param p_pea_object_version_number If p_validate is false, then set to the
 * version number of the created special information record. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Educational Background Special Information Type for Japan
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_jp_educ_sit
 ( p_validate                  in    boolean  default false
  ,p_person_id                 in    number
  ,p_business_group_id         in    number
  ,p_effective_date            in    date
  ,p_comments                  in    varchar2 default null
  ,p_date_from                 in    date     default null
  ,p_date_to                   in    date     default null
  ,p_attribute_category        in    varchar2 default null
  ,p_attribute1                in    varchar2 default null
  ,p_attribute2                in    varchar2 default null
  ,p_attribute3                in    varchar2 default null
  ,p_attribute4                in    varchar2 default null
  ,p_attribute5                in    varchar2 default null
  ,p_attribute6                in    varchar2 default null
  ,p_attribute7                in    varchar2 default null
  ,p_attribute8                in    varchar2 default null
  ,p_attribute9                in    varchar2 default null
  ,p_attribute10               in    varchar2 default null
  ,p_attribute11               in    varchar2 default null
  ,p_attribute12               in    varchar2 default null
  ,p_attribute13               in    varchar2 default null
  ,p_attribute14               in    varchar2 default null
  ,p_attribute15               in    varchar2 default null
  ,p_attribute16               in    varchar2 default null
  ,p_attribute17               in    varchar2 default null
  ,p_attribute18               in    varchar2 default null
  ,p_attribute19               in    varchar2 default null
  ,p_attribute20               in    varchar2 default null
  ,p_segment1                  in    varchar2 default null
  ,p_segment2                  in    varchar2 default null
  ,p_segment3                  in    varchar2 default null
  ,p_segment4                  in    varchar2 default null
  ,p_segment5                  in    varchar2 default null
  ,p_segment6                  in    varchar2 default null
  ,p_segment7                  in    varchar2 default null
  ,p_segment8                  in    varchar2 default null
  ,p_segment9                  in    varchar2 default null
  ,p_segment10                 in    varchar2 default null
  ,p_segment11                 in    varchar2 default null
  ,p_segment12                 in    varchar2 default null
  ,p_segment13                 in    varchar2 default null
  ,p_segment14                 in    varchar2 default null
  ,p_segment15                 in    varchar2 default null
  ,p_segment16                 in    varchar2 default null
  ,p_segment17                 in    varchar2 default null
  ,p_segment18                 in    varchar2 default null
  ,p_segment19                 in    varchar2 default null
  ,p_segment20                 in    varchar2 default null
  ,p_segment21                 in    varchar2 default null
  ,p_segment22                 in    varchar2 default null
  ,p_segment23                 in    varchar2 default null
  ,p_segment24                 in    varchar2 default null
  ,p_segment25                 in    varchar2 default null
  ,p_segment26                 in    varchar2 default null
  ,p_segment27                 in    varchar2 default null
  ,p_segment28                 in    varchar2 default null
  ,p_segment29                 in    varchar2 default null
  ,p_segment30                 in    varchar2 default null
  ,p_analysis_criteria_id      out nocopy   number
  ,p_person_analysis_id        out nocopy   number
  ,p_pea_object_version_number out nocopy   number
 );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_jp_employee_with_sit >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new JP employee including a special information record, a
 * default primary assignment and a period of service for the employee.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * If person_type_id is supplied, it must have a corresponding system person
 * type of 'EMP', must be active and be in the same business group as that of
 * the employee being created. Special Information Type must be set enabled
 * against the business group.
 *
 * <p><b>Post Success</b><br>
 * The person, special information record, primary assignment and period of
 * service will be successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The person, special information record, primary assignment and period of
 * service will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date The employee hire date and the effective start date of
 * the person, primary assignment and period of service.
 * @param p_business_group_id The employee's Business Group ID.
 * @param p_last_name Employee's last name (Kanji).
 * @param p_last_name_kana Employee's last name (Kana).
 * @param p_sex {@rep:casecolumn PER_ALL_PEOPLE_F.SEX}
 * @param p_person_type_id Person type id. If this value is omitted then the
 * person_type_id of the default `EMP' system person type in the employee's
 * business group is used.
 * @param p_per_comments Comments for person record.
 * @param p_date_employee_data_verified The date on which the employee data was
 * last verified.
 * @param p_date_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_BIRTH}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_employee_number The business group's employee number generation
 * method determines when the API derives and passes out an employee number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is false then will be set to the employee number. If
 * p_validate is true then this will be set to the passed value.
 * @param p_expense_check_send_to_addres {@rep:casecolumn
 * PER_ALL_PEOPLE_F.EXPENSE_CHECK_SEND_TO_ADDRESS}
 * @param p_first_name Employee's first name (Kanji).
 * @param p_first_name_kana Employee's first name (Kana).
 * @param p_known_as {@rep:casecolumn PER_ALL_PEOPLE_F.KNOWN_AS}
 * @param p_marital_status {@rep:casecolumn PER_ALL_PEOPLE_F.MARITAL_STATUS}
 * @param p_middle_names Employee's middle name(s).
 * @param p_nationality {@rep:casecolumn PER_ALL_PEOPLE_F.NATIONALITY}
 * @param p_national_identifier {@rep:casecolumn
 * PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER}
 * @param p_previous_last_name Previous last name (Kanji).
 * @param p_previous_last_name_kana Previous last name (Kana).
 * @param p_registered_disabled_flag {@rep:casecolumn
 * PER_ALL_PEOPLE_F.REGISTERED_DISABLED_FLAG}
 * @param p_title Employee's title.
 * @param p_vendor_id {@rep:casecolumn PER_ALL_PEOPLE_F.VENDOR_ID}
 * @param p_work_telephone {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_TELEPHONE}
 * @param p_per_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_per_attribute1 Descriptive flexfield segment.
 * @param p_per_attribute2 Descriptive flexfield segment.
 * @param p_per_attribute3 Descriptive flexfield segment.
 * @param p_per_attribute4 Descriptive flexfield segment.
 * @param p_per_attribute5 Descriptive flexfield segment.
 * @param p_per_attribute6 Descriptive flexfield segment.
 * @param p_per_attribute7 Descriptive flexfield segment.
 * @param p_per_attribute8 Descriptive flexfield segment.
 * @param p_per_attribute9 Descriptive flexfield segment.
 * @param p_per_attribute10 Descriptive flexfield segment.
 * @param p_per_attribute11 Descriptive flexfield segment.
 * @param p_per_attribute12 Descriptive flexfield segment.
 * @param p_per_attribute13 Descriptive flexfield segment.
 * @param p_per_attribute14 Descriptive flexfield segment.
 * @param p_per_attribute15 Descriptive flexfield segment.
 * @param p_per_attribute16 Descriptive flexfield segment.
 * @param p_per_attribute17 Descriptive flexfield segment.
 * @param p_per_attribute18 Descriptive flexfield segment.
 * @param p_per_attribute19 Descriptive flexfield segment.
 * @param p_per_attribute20 Descriptive flexfield segment.
 * @param p_per_attribute21 Descriptive flexfield segment.
 * @param p_per_attribute22 Descriptive flexfield segment.
 * @param p_per_attribute23 Descriptive flexfield segment.
 * @param p_per_attribute24 Descriptive flexfield segment.
 * @param p_per_attribute25 Descriptive flexfield segment.
 * @param p_per_attribute26 Descriptive flexfield segment.
 * @param p_per_attribute27 Descriptive flexfield segment.
 * @param p_per_attribute28 Descriptive flexfield segment.
 * @param p_per_attribute29 Descriptive flexfield segment.
 * @param p_per_attribute30 Descriptive flexfield segment.
 * @param p_date_of_death {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_DEATH}
 * @param p_blood_type {@rep:casecolumn PER_ALL_PEOPLE_F.BLOOD_TYPE}
 * @param p_correspondence_language {@rep:casecolumn
 * PER_ALL_PEOPLE_F.CORRESPONDENCE_LANGUAGE}
 * @param p_fte_capacity {@rep:casecolumn PER_ALL_PEOPLE_F.FTE_CAPACITY}
 * @param p_honors {@rep:casecolumn PER_ALL_PEOPLE_F.HONORS}
 * @param p_internal_location {@rep:casecolumn
 * PER_ALL_PEOPLE_F.INTERNAL_LOCATION}
 * @param p_last_medical_test_by {@rep:casecolumn
 * PER_ALL_PEOPLE_F.LAST_MEDICAL_TEST_BY}
 * @param p_last_medical_test_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.LAST_MEDICAL_TEST_DATE}
 * @param p_mailstop {@rep:casecolumn PER_ALL_PEOPLE_F.MAILSTOP}
 * @param p_office_number {@rep:casecolumn PER_ALL_PEOPLE_F.OFFICE_NUMBER}
 * @param p_on_military_service {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ON_MILITARY_SERVICE}
 * @param p_resume_exists {@rep:casecolumn PER_ALL_PEOPLE_F.RESUME_EXISTS}
 * @param p_resume_last_updated {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RESUME_LAST_UPDATED}
 * @param p_second_passport_exists {@rep:casecolumn
 * PER_ALL_PEOPLE_F.SECOND_PASSPORT_EXISTS}
 * @param p_student_status {@rep:casecolumn PER_ALL_PEOPLE_F.STUDENT_STATUS}
 * @param p_work_schedule {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_SCHEDULE}
 * @param p_original_date_of_hire {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
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
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then this will be set to the identifier of the created person
 * comment record. If p_validate is true or no comment text was provided, then
 * this will be null.
 * @param p_assignment_sequence If p_validate is false this will be set to the
 * sequence number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_assignment_number If p_validate is false this will be set to the
 * assignment number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning This is set to true if the original date of hire
 * is not null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @param p_id_flex_num Id flex number of the Personal Analysis key flexfield
 * structure.
 * @param p_pea_comments Comments.
 * @param p_date_from The date from which the special information record
 * applies.
 * @param p_date_to The date on which the special information record no longer
 * applies.
 * @param p_pea_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_pea_attribute1 Descriptive flexfield segment.
 * @param p_pea_attribute2 Descriptive flexfield segment.
 * @param p_pea_attribute3 Descriptive flexfield segment.
 * @param p_pea_attribute4 Descriptive flexfield segment.
 * @param p_pea_attribute5 Descriptive flexfield segment.
 * @param p_pea_attribute6 Descriptive flexfield segment.
 * @param p_pea_attribute7 Descriptive flexfield segment.
 * @param p_pea_attribute8 Descriptive flexfield segment.
 * @param p_pea_attribute9 Descriptive flexfield segment.
 * @param p_pea_attribute10 Descriptive flexfield segment.
 * @param p_pea_attribute11 Descriptive flexfield segment.
 * @param p_pea_attribute12 Descriptive flexfield segment.
 * @param p_pea_attribute13 Descriptive flexfield segment.
 * @param p_pea_attribute14 Descriptive flexfield segment.
 * @param p_pea_attribute15 Descriptive flexfield segment.
 * @param p_pea_attribute16 Descriptive flexfield segment.
 * @param p_pea_attribute17 Descriptive flexfield segment.
 * @param p_pea_attribute18 Descriptive flexfield segment.
 * @param p_pea_attribute19 Descriptive flexfield segment.
 * @param p_pea_attribute20 Descriptive flexfield segment.
 * @param p_segment1 Key flexfield segment.
 * @param p_segment2 Key flexfield segment.
 * @param p_segment3 Key flexfield segment.
 * @param p_segment4 Key flexfield segment.
 * @param p_segment5 Key flexfield segment.
 * @param p_segment6 Key flexfield segment.
 * @param p_segment7 Key flexfield segment.
 * @param p_segment8 Key flexfield segment.
 * @param p_segment9 Key flexfield segment.
 * @param p_segment10 Key flexfield segment.
 * @param p_segment11 Key flexfield segment.
 * @param p_segment12 Key flexfield segment.
 * @param p_segment13 Key flexfield segment.
 * @param p_segment14 Key flexfield segment.
 * @param p_segment15 Key flexfield segment.
 * @param p_segment16 Key flexfield segment.
 * @param p_segment17 Key flexfield segment.
 * @param p_segment18 Key flexfield segment.
 * @param p_segment19 Key flexfield segment.
 * @param p_segment20 Key flexfield segment.
 * @param p_segment21 Key flexfield segment.
 * @param p_segment22 Key flexfield segment.
 * @param p_segment23 Key flexfield segment.
 * @param p_segment24 Key flexfield segment.
 * @param p_segment25 Key flexfield segment.
 * @param p_segment26 Key flexfield segment.
 * @param p_segment27 Key flexfield segment.
 * @param p_segment28 Key flexfield segment.
 * @param p_segment29 Key flexfield segment.
 * @param p_segment30 Key flexfield segment.
 * @param p_pea_object_version_number If p_validate is false, then set to the
 * version number of the created special information record. If p_validate is
 * true, then the value will be null.
 * @param p_analysis_criteria_id If p_validate is false, this uniquely
 * identifies the combination of the personal analysis flexfield segments
 * created. If p_validate is true this parameter will be null.
 * @param p_person_analysis_id If p_validate is false, this uniquely identifies
 * the special information record created. If p_validate is true this parameter
 * will be null.
 * @param p_english_last_name Employees Last Name in english words.  The value
 * would get stored in per_information21 Developer descriptive flexfield
 * segment.
 * @param p_english_first_name Employees First Name in english words.  The value * would get stored in per_information22 Developer descriptive flexfield
 * segment.
 * @param p_per_information23 Developer descriptive flexfield segment.
 * @param p_per_information24 Developer descriptive flexfield segment.
 * @param p_per_information25 Developer descriptive flexfield segment.
 * @param p_per_information26 Developer descriptive flexfield segment.
 * @param p_per_information27 Developer descriptive flexfield segment.
 * @param p_per_information28 Developer descriptive flexfield segment.
 * @param p_per_information29 Developer descriptive flexfield segment.
 * @param p_per_information30 Developer descriptive flexfield segment.
 * @rep:displayname Create Employee with Special Information for Japan
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_jp_employee_with_sit
  (
   -- for employee
   --
   p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_last_name_kana                in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_first_name_kana               in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_previous_last_name_kana       in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_per_attribute_category        in     varchar2 default null
  ,p_per_attribute1                in     varchar2 default null
  ,p_per_attribute2                in     varchar2 default null
  ,p_per_attribute3                in     varchar2 default null
  ,p_per_attribute4                in     varchar2 default null
  ,p_per_attribute5                in     varchar2 default null
  ,p_per_attribute6                in     varchar2 default null
  ,p_per_attribute7                in     varchar2 default null
  ,p_per_attribute8                in     varchar2 default null
  ,p_per_attribute9                in     varchar2 default null
  ,p_per_attribute10               in     varchar2 default null
  ,p_per_attribute11               in     varchar2 default null
  ,p_per_attribute12               in     varchar2 default null
  ,p_per_attribute13               in     varchar2 default null
  ,p_per_attribute14               in     varchar2 default null
  ,p_per_attribute15               in     varchar2 default null
  ,p_per_attribute16               in     varchar2 default null
  ,p_per_attribute17               in     varchar2 default null
  ,p_per_attribute18               in     varchar2 default null
  ,p_per_attribute19               in     varchar2 default null
  ,p_per_attribute20               in     varchar2 default null
  ,p_per_attribute21               in     varchar2 default null
  ,p_per_attribute22               in     varchar2 default null
  ,p_per_attribute23               in     varchar2 default null
  ,p_per_attribute24               in     varchar2 default null
  ,p_per_attribute25               in     varchar2 default null
  ,p_per_attribute26               in     varchar2 default null
  ,p_per_attribute27               in     varchar2 default null
  ,p_per_attribute28               in     varchar2 default null
  ,p_per_attribute29               in     varchar2 default null
  ,p_per_attribute30               in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_original_date_of_hire         in     date     default null
  ,p_person_id                     out nocopy    number
  ,p_assignment_id                 out nocopy    number
  ,p_per_object_version_number     out nocopy    number
  ,p_asg_object_version_number     out nocopy    number
  ,p_per_effective_start_date      out nocopy    date
  ,p_per_effective_end_date        out nocopy    date
  ,p_full_name                     out nocopy    varchar2
  ,p_per_comment_id                out nocopy    number
  ,p_assignment_sequence           out nocopy    number
  ,p_assignment_number             out nocopy    varchar2
  ,p_name_combination_warning      out nocopy    boolean
  ,p_assign_payroll_warning        out nocopy    boolean
  ,p_orig_hire_warning             out nocopy    boolean

  /* for special information */

  ,p_id_flex_num                   in     number
  ,p_pea_comments                  in     varchar2 default null
  ,p_date_from                     in     date     default null
  ,p_date_to                       in     date     default null
  ,p_pea_attribute_category        in     varchar2 default null
  ,p_pea_attribute1                in     varchar2 default null
  ,p_pea_attribute2                in     varchar2 default null
  ,p_pea_attribute3                in     varchar2 default null
  ,p_pea_attribute4                in     varchar2 default null
  ,p_pea_attribute5                in     varchar2 default null
  ,p_pea_attribute6                in     varchar2 default null
  ,p_pea_attribute7                in     varchar2 default null
  ,p_pea_attribute8                in     varchar2 default null
  ,p_pea_attribute9                in     varchar2 default null
  ,p_pea_attribute10               in     varchar2 default null
  ,p_pea_attribute11               in     varchar2 default null
  ,p_pea_attribute12               in     varchar2 default null
  ,p_pea_attribute13               in     varchar2 default null
  ,p_pea_attribute14               in     varchar2 default null
  ,p_pea_attribute15               in     varchar2 default null
  ,p_pea_attribute16               in     varchar2 default null
  ,p_pea_attribute17               in     varchar2 default null
  ,p_pea_attribute18               in     varchar2 default null
  ,p_pea_attribute19               in     varchar2 default null
  ,p_pea_attribute20               in     varchar2 default null
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_pea_object_version_number     out nocopy    number
  ,p_analysis_criteria_id          out nocopy    number
  ,p_person_analysis_id            out nocopy    number

 /* Additional parameters for Bug:4161160 */

  ,p_english_last_name		   in    varchar2 default null
  ,p_english_first_name		   in    varchar2 default null
  ,p_per_information23	           in    varchar2 default null
  ,p_per_information24	           in    varchar2 default null
  ,p_per_information25	           in    varchar2 default null
  ,p_per_information26	           in    varchar2 default null
  ,p_per_information27	           in    varchar2 default null
  ,p_per_information28	           in    varchar2 default null
  ,p_per_information29	           in    varchar2 default null
  ,p_per_information30	           in    varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_jp_emp_with_educ_add >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new employee for Japan including a special information
 * record of JP Educational Background, a primary JP address, a default primary
 * assignment and a period of service for the employee.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * If person_type_id is supplied, it must have a corresponding system person
 * type of 'EMP', must be active and be in the same business group as that of
 * the employee being created. Special Information Type of JP Educational
 * Background must be set enabled against the business group. The address_type
 * attribute can only be used after QuickCodes have been defined for the
 * 'ADDRESS_TYPE' lookup type.
 *
 * <p><b>Post Success</b><br>
 * The person, special information record, address, primary assignment and
 * period of service will be successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The person, special information record, address, primary assignment or
 * period of service will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date The employee hire date and the effective start date of
 * the person, primary assignment and period of service.
 * @param p_business_group_id The employee's Business Group ID.
 * @param p_last_name Employee's last name (Kanji).
 * @param p_last_name_kana Employee's last name (Kana).
 * @param p_sex {@rep:casecolumn PER_ALL_PEOPLE_F.SEX}
 * @param p_person_type_id Person type id. If this value is omitted then the
 * person_type_id of the default `EMP' system person type in the employee's
 * business group is used.
 * @param p_per_comments Comments for person record.
 * @param p_date_employee_data_verified The date on which the employee data was
 * last verified.
 * @param p_date_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_BIRTH}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_employee_number The business group's employee number generation
 * method determines when the API derives and passes out an employee number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is false then will be set to the employee number. If
 * p_validate is true then will be set to the passed value.
 * @param p_expense_check_send_to_addres {@rep:casecolumn
 * PER_ALL_PEOPLE_F.EXPENSE_CHECK_SEND_TO_ADDRESS}
 * @param p_first_name Employee's first name (Kanji).
 * @param p_first_name_kana Employee's first name (Kana).
 * @param p_known_as {@rep:casecolumn PER_ALL_PEOPLE_F.KNOWN_AS}
 * @param p_marital_status {@rep:casecolumn PER_ALL_PEOPLE_F.MARITAL_STATUS}
 * @param p_middle_names Employee's middle name(s).
 * @param p_nationality Employee's nationality.
 * @param p_national_identifier {@rep:casecolumn
 * PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER}
 * @param p_previous_last_name_kana Previous last name (Kana).
 * @param p_previous_last_name Previous last name (Kanji).
 * @param p_registered_disabled_flag {@rep:casecolumn
 * PER_ALL_PEOPLE_F.REGISTERED_DISABLED_FLAG}
 * @param p_title Employee's title.
 * @param p_vendor_id {@rep:casecolumn PER_ALL_PEOPLE_F.VENDOR_ID}
 * @param p_work_telephone {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_TELEPHONE}
 * @param p_per_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_per_attribute1 Descriptive flexfield segment.
 * @param p_per_attribute2 Descriptive flexfield segment.
 * @param p_per_attribute3 Descriptive flexfield segment.
 * @param p_per_attribute4 Descriptive flexfield segment.
 * @param p_per_attribute5 Descriptive flexfield segment.
 * @param p_per_attribute6 Descriptive flexfield segment.
 * @param p_per_attribute7 Descriptive flexfield segment.
 * @param p_per_attribute8 Descriptive flexfield segment.
 * @param p_per_attribute9 Descriptive flexfield segment.
 * @param p_per_attribute10 Descriptive flexfield segment.
 * @param p_per_attribute11 Descriptive flexfield segment.
 * @param p_per_attribute12 Descriptive flexfield segment.
 * @param p_per_attribute13 Descriptive flexfield segment.
 * @param p_per_attribute14 Descriptive flexfield segment.
 * @param p_per_attribute15 Descriptive flexfield segment.
 * @param p_per_attribute16 Descriptive flexfield segment.
 * @param p_per_attribute17 Descriptive flexfield segment.
 * @param p_per_attribute18 Descriptive flexfield segment.
 * @param p_per_attribute19 Descriptive flexfield segment.
 * @param p_per_attribute20 Descriptive flexfield segment.
 * @param p_per_attribute21 Descriptive flexfield segment.
 * @param p_per_attribute22 Descriptive flexfield segment.
 * @param p_per_attribute23 Descriptive flexfield segment.
 * @param p_per_attribute24 Descriptive flexfield segment.
 * @param p_per_attribute25 Descriptive flexfield segment.
 * @param p_per_attribute26 Descriptive flexfield segment.
 * @param p_per_attribute27 Descriptive flexfield segment.
 * @param p_per_attribute28 Descriptive flexfield segment.
 * @param p_per_attribute29 Descriptive flexfield segment.
 * @param p_per_attribute30 Descriptive flexfield segment.
 * @param p_date_of_death {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_DEATH}
 * @param p_blood_type {@rep:casecolumn PER_ALL_PEOPLE_F.BLOOD_TYPE}
 * @param p_correspondence_language {@rep:casecolumn
 * PER_ALL_PEOPLE_F.CORRESPONDENCE_LANGUAGE}
 * @param p_fte_capacity {@rep:casecolumn PER_ALL_PEOPLE_F.FTE_CAPACITY}
 * @param p_honors {@rep:casecolumn PER_ALL_PEOPLE_F.HONORS}
 * @param p_internal_location {@rep:casecolumn
 * PER_ALL_PEOPLE_F.INTERNAL_LOCATION}
 * @param p_last_medical_test_by {@rep:casecolumn
 * PER_ALL_PEOPLE_F.LAST_MEDICAL_TEST_BY}
 * @param p_last_medical_test_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.LAST_MEDICAL_TEST_DATE}
 * @param p_mailstop {@rep:casecolumn PER_ALL_PEOPLE_F.MAILSTOP}
 * @param p_office_number {@rep:casecolumn PER_ALL_PEOPLE_F.OFFICE_NUMBER}
 * @param p_on_military_service {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ON_MILITARY_SERVICE}
 * @param p_resume_exists {@rep:casecolumn PER_ALL_PEOPLE_F.RESUME_EXISTS}
 * @param p_resume_last_updated {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RESUME_LAST_UPDATED}
 * @param p_second_passport_exists {@rep:casecolumn
 * PER_ALL_PEOPLE_F.SECOND_PASSPORT_EXISTS}
 * @param p_student_status {@rep:casecolumn PER_ALL_PEOPLE_F.STUDENT_STATUS}
 * @param p_work_schedule {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_SCHEDULE}
 * @param p_original_date_of_hire {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then this is set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then this is set to null.
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
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then will be set to the identifier of the created person comment
 * record. If p_validate is true or no comment text was provided, then will be
 * null.
 * @param p_assignment_sequence If p_validate is false this will be set to the
 * sequence number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_assignment_number If p_validate is false this will be set to the
 * assignment number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning This is set to true if the original date of hire
 * is not null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @param p_pea_comments Comments for the special information record.
 * @param p_pea_date_from The date from which the special information record
 * applies.
 * @param p_pea_date_to The date on which the special information record no
 * longer applies.
 * @param p_pea_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_pea_attribute1 Descriptive flexfield segment.
 * @param p_pea_attribute2 Descriptive flexfield segment.
 * @param p_pea_attribute3 Descriptive flexfield segment.
 * @param p_pea_attribute4 Descriptive flexfield segment.
 * @param p_pea_attribute5 Descriptive flexfield segment.
 * @param p_pea_attribute6 Descriptive flexfield segment.
 * @param p_pea_attribute7 Descriptive flexfield segment.
 * @param p_pea_attribute8 Descriptive flexfield segment.
 * @param p_pea_attribute9 Descriptive flexfield segment.
 * @param p_pea_attribute10 Descriptive flexfield segment.
 * @param p_pea_attribute11 Descriptive flexfield segment.
 * @param p_pea_attribute12 Descriptive flexfield segment.
 * @param p_pea_attribute13 Descriptive flexfield segment.
 * @param p_pea_attribute14 Descriptive flexfield segment.
 * @param p_pea_attribute15 Descriptive flexfield segment.
 * @param p_pea_attribute16 Descriptive flexfield segment.
 * @param p_pea_attribute17 Descriptive flexfield segment.
 * @param p_pea_attribute18 Descriptive flexfield segment.
 * @param p_pea_attribute19 Descriptive flexfield segment.
 * @param p_pea_attribute20 Descriptive flexfield segment.
 * @param p_school_type Type of School. Valid values are defined by
 * 'JP_SCHOOL_TYPE' lookup type.
 * @param p_school_id {@rep:casecolumn PER_JP_SCHOOL_LOOKUPS.SCHOOL_ID}
 * @param p_school_name {@rep:casecolumn PER_JP_SCHOOL_LOOKUPS.SCHOOL_NAME}
 * @param p_school_name_kana {@rep:casecolumn
 * PER_JP_SCHOOL_LOOKUPS.SCHOOL_NAME_KANA}
 * @param p_major {@rep:casecolumn PER_JP_SCHOOL_LOOKUPS.MAJOR}
 * @param p_major_kana {@rep:casecolumn PER_JP_SCHOOL_LOOKUPS.MAJOR_KANA}
 * @param p_advisor Department.
 * @param p_graduation_date Graduation Date.
 * @param p_note Note.
 * @param p_last_flag This identifies the last educational background detail.
 * @param p_pea_object_version_number If p_validate is false, then set to the
 * version number of the created special information record. If p_validate is
 * true, then the value will be null.
 * @param p_analysis_criteria_id If p_validate is false, this uniquely
 * identifies the combination of the personal analysis flexfield segments
 * created. If p_validate is true this parameter will be null.
 * @param p_person_analysis_id If p_validate is false, this uniquely identifies
 * the special information record created. If p_validate is true this parameter
 * will be null.
 * @param p_add_date_from The date from which the address applies.
 * @param p_add_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address. Valid values are defined by
 * 'ADDRESS_TYPE' lookup type.
 * @param p_add_comments Comment text for address.
 * @param p_address_line1 Line 1 of address.
 * @param p_address_line2 Line 2 of address.
 * @param p_address_line3 Line 3 of address.
 * @param p_district_code District code.
 * @param p_address_line1_kana Line 1 of address (Kana).
 * @param p_address_line2_kana Line 2 of address (Kana).
 * @param p_address_line3_kana Line 3 of address (Kana).
 * @param p_postcode Postal Code.
 * @param p_country Country.
 * @param p_telephone_number_1 Telephone number.
 * @param p_telephone_number_2 Telephone number.
 * @param p_fax_number Fax Number.
 * @param p_addr_attribute_category This context value determines which
 * flexfield structure to use with the Person Address descriptive flexfield
 * segments.
 * @param p_addr_attribute1 Descriptive flexfield segment.
 * @param p_addr_attribute2 Descriptive flexfield segment.
 * @param p_addr_attribute3 Descriptive flexfield segment.
 * @param p_addr_attribute4 Descriptive flexfield segment.
 * @param p_addr_attribute5 Descriptive flexfield segment.
 * @param p_addr_attribute6 Descriptive flexfield segment.
 * @param p_addr_attribute7 Descriptive flexfield segment.
 * @param p_addr_attribute8 Descriptive flexfield segment.
 * @param p_addr_attribute9 Descriptive flexfield segment.
 * @param p_addr_attribute10 Descriptive flexfield segment.
 * @param p_addr_attribute11 Descriptive flexfield segment.
 * @param p_addr_attribute12 Descriptive flexfield segment.
 * @param p_addr_attribute13 Descriptive flexfield segment.
 * @param p_addr_attribute14 Descriptive flexfield segment.
 * @param p_addr_attribute15 Descriptive flexfield segment.
 * @param p_addr_attribute16 Descriptive flexfield segment.
 * @param p_addr_attribute17 Descriptive flexfield segment.
 * @param p_addr_attribute18 Descriptive flexfield segment.
 * @param p_addr_attribute19 Descriptive flexfield segment.
 * @param p_addr_attribute20 Descriptive flexfield segment.
 * @param p_address_id If p_validate is false, uniquely identifies the address
 * created. If p_validate is true, set to null.
 * @param p_add_object_version_number If p_validate is false, then set to the
 * version number of the created address. If p_validate is true, then the value
 * will be null.
 * @param p_english_last_name Employees Last Name in english words.  The value
 * would get stored in per_information21 Developer descriptive flexfield
 * segment.
 * @param p_english_first_name Employees First Name in english words.  The value
 * would get stored in per_information22 Developer descriptive flexfield
 * segment.
 * @param p_per_information23 Developer descriptive flexfield segment.
 * @param p_per_information24 Developer descriptive flexfield segment.
 * @param p_per_information25 Developer descriptive flexfield segment.
 * @param p_per_information26 Developer descriptive flexfield segment.
 * @param p_per_information27 Developer descriptive flexfield segment.
 * @param p_per_information28 Developer descriptive flexfield segment.
 * @param p_per_information29 Developer descriptive flexfield segment.
 * @param p_per_information30 Developer descriptive flexfield segment.
 * @rep:displayname Create Employee with Education Background and Address for Japan
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_jp_emp_with_educ_add
  (
   -- for employee
   --
   p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_last_name_kana                in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_first_name_kana               in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name_kana       in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_per_attribute_category        in     varchar2 default null
  ,p_per_attribute1                in     varchar2 default null
  ,p_per_attribute2                in     varchar2 default null
  ,p_per_attribute3                in     varchar2 default null
  ,p_per_attribute4                in     varchar2 default null
  ,p_per_attribute5                in     varchar2 default null
  ,p_per_attribute6                in     varchar2 default null
  ,p_per_attribute7                in     varchar2 default null
  ,p_per_attribute8                in     varchar2 default null
  ,p_per_attribute9                in     varchar2 default null
  ,p_per_attribute10               in     varchar2 default null
  ,p_per_attribute11               in     varchar2 default null
  ,p_per_attribute12               in     varchar2 default null
  ,p_per_attribute13               in     varchar2 default null
  ,p_per_attribute14               in     varchar2 default null
  ,p_per_attribute15               in     varchar2 default null
  ,p_per_attribute16               in     varchar2 default null
  ,p_per_attribute17               in     varchar2 default null
  ,p_per_attribute18               in     varchar2 default null
  ,p_per_attribute19               in     varchar2 default null
  ,p_per_attribute20               in     varchar2 default null
  ,p_per_attribute21               in     varchar2 default null
  ,p_per_attribute22               in     varchar2 default null
  ,p_per_attribute23               in     varchar2 default null
  ,p_per_attribute24               in     varchar2 default null
  ,p_per_attribute25               in     varchar2 default null
  ,p_per_attribute26               in     varchar2 default null
  ,p_per_attribute27               in     varchar2 default null
  ,p_per_attribute28               in     varchar2 default null
  ,p_per_attribute29               in     varchar2 default null
  ,p_per_attribute30               in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_original_date_of_hire         in     date     default null
  ,p_person_id                     out nocopy    number
  ,p_assignment_id                 out nocopy    number
  ,p_per_object_version_number     out nocopy    number
  ,p_asg_object_version_number     out nocopy    number
  ,p_per_effective_start_date      out nocopy    date
  ,p_per_effective_end_date        out nocopy    date
  ,p_full_name                     out nocopy    varchar2
  ,p_per_comment_id                out nocopy    number
  ,p_assignment_sequence           out nocopy    number
  ,p_assignment_number             out nocopy    varchar2
  ,p_name_combination_warning      out nocopy    boolean
  ,p_assign_payroll_warning        out nocopy    boolean
  ,p_orig_hire_warning             out nocopy    boolean
  --
  -- for special information
  --
  ,p_pea_comments                  in     varchar2 default null
  ,p_pea_date_from                 in     date     default null
  ,p_pea_date_to                   in     date     default null
  ,p_pea_attribute_category        in     varchar2 default null
  ,p_pea_attribute1                in     varchar2 default null
  ,p_pea_attribute2                in     varchar2 default null
  ,p_pea_attribute3                in     varchar2 default null
  ,p_pea_attribute4                in     varchar2 default null
  ,p_pea_attribute5                in     varchar2 default null
  ,p_pea_attribute6                in     varchar2 default null
  ,p_pea_attribute7                in     varchar2 default null
  ,p_pea_attribute8                in     varchar2 default null
  ,p_pea_attribute9                in     varchar2 default null
  ,p_pea_attribute10               in     varchar2 default null
  ,p_pea_attribute11               in     varchar2 default null
  ,p_pea_attribute12               in     varchar2 default null
  ,p_pea_attribute13               in     varchar2 default null
  ,p_pea_attribute14               in     varchar2 default null
  ,p_pea_attribute15               in     varchar2 default null
  ,p_pea_attribute16               in     varchar2 default null
  ,p_pea_attribute17               in     varchar2 default null
  ,p_pea_attribute18               in     varchar2 default null
  ,p_pea_attribute19               in     varchar2 default null
  ,p_pea_attribute20               in     varchar2 default null
  ,p_school_type                   in     varchar2 default null
  ,p_school_id                     in     varchar2 default null
  ,p_school_name                   in     varchar2 default null
  ,p_school_name_kana              in     varchar2 default null
  ,p_major                         in     varchar2 default null
  ,p_major_kana                    in     varchar2 default null
  ,p_advisor                       in     varchar2 default null
  ,p_graduation_date               in     varchar2 default null
  ,p_note                          in     varchar2 default null
  ,p_last_flag                     in     varchar2 default null
  ,p_pea_object_version_number     out nocopy    number
  ,p_analysis_criteria_id          out nocopy    number
  ,p_person_analysis_id            out nocopy    number
  --
  -- for address
  --
  ,p_add_date_from                 in     date     default null
  ,p_add_date_to                   in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_add_comments                  in     varchar2 default null
  ,p_address_line1                 in     varchar2 default null
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_district_code                 in     varchar2 default null
  ,p_address_line1_kana            in     varchar2 default null
  ,p_address_line2_kana            in     varchar2 default null
  ,p_address_line3_kana            in     varchar2 default null
  ,p_postcode                      in     varchar2 default null
  ,p_country                       in     varchar2 default null
  ,p_telephone_number_1            in     varchar2 default null
  ,p_telephone_number_2            in     varchar2 default null
  ,p_fax_number                    in     varchar2 default null
  ,p_addr_attribute_category       in     varchar2 default null
  ,p_addr_attribute1               in     varchar2 default null
  ,p_addr_attribute2               in     varchar2 default null
  ,p_addr_attribute3               in     varchar2 default null
  ,p_addr_attribute4               in     varchar2 default null
  ,p_addr_attribute5               in     varchar2 default null
  ,p_addr_attribute6               in     varchar2 default null
  ,p_addr_attribute7               in     varchar2 default null
  ,p_addr_attribute8               in     varchar2 default null
  ,p_addr_attribute9               in     varchar2 default null
  ,p_addr_attribute10              in     varchar2 default null
  ,p_addr_attribute11              in     varchar2 default null
  ,p_addr_attribute12              in     varchar2 default null
  ,p_addr_attribute13              in     varchar2 default null
  ,p_addr_attribute14              in     varchar2 default null
  ,p_addr_attribute15              in     varchar2 default null
  ,p_addr_attribute16              in     varchar2 default null
  ,p_addr_attribute17              in     varchar2 default null
  ,p_addr_attribute18              in     varchar2 default null
  ,p_addr_attribute19              in     varchar2 default null
  ,p_addr_attribute20              in     varchar2 default null
  ,p_address_id                    out nocopy number
  ,p_add_object_version_number     out nocopy number

/* Additional parameters for Bug:4161160 */

  ,p_english_last_name		   in    varchar2 default null
  ,p_english_first_name		   in    varchar2 default null
  ,p_per_information23	           in    varchar2 default null
  ,p_per_information24	           in    varchar2 default null
  ,p_per_information25	           in    varchar2 default null
  ,p_per_information26	           in    varchar2 default null
  ,p_per_information27	           in    varchar2 default null
  ,p_per_information28	           in    varchar2 default null
  ,p_per_information29	           in    varchar2 default null
  ,p_per_information30	           in    varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_jp_applicant_with_sit >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new applicant for Japan.
 *
 * The person details, an application, a special information record, a default
 * applicant assignment and if required associated assignment budget values and
 * a letter request are created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business_group_id of a JP legislation. A valid person_type_id, if
 * specified, with a corresponding system type of 'APL', must be active and in
 * the same business group as that of the applicant being created. If a
 * person_type_id is not specified the API will use the default 'APL' type for
 * the business group. Special Information Type must be set enabled against the
 * business group.
 *
 * <p><b>Post Success</b><br>
 * The person, application, special information record, default applicant
 * assignment and if required associated assignment budget values and a letter
 * request will be created.
 *
 * <p><b>Post Failure</b><br>
 * The person, special information record, default applicant assignment,
 * associated assignment budget values and a letter request will not be created
 * and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The date an application was received and thus the
 * effective start date of the person, application and assignment.
 * @param p_business_group_id The applicant's business group.
 * @param p_last_name Applicant's last name (Kanji).
 * @param p_last_name_kana Applicant's last name (Kana).
 * @param p_sex {@rep:casecolumn PER_ALL_PEOPLE_F.SEX}
 * @param p_person_type_id Person type id. If a person_type_id is not specified
 * the API will use the default 'APL' type for the business group.
 * @param p_per_comments Comments for person record.
 * @param p_date_employee_data_verified The date on which the applicant data
 * was last verified.
 * @param p_date_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_BIRTH}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_applicant_number This paramater details the applicant number. If
 * the number generation method is Manual then this parameter is mandatory. If
 * the number generation method is Automatic then the value of this parameter
 * must be NULL. If p_validate is false and the applicant number generation
 * method is Automatic, this will be set to to the generated applicant number
 * of the person created. If p_validate is false and the applicant number
 * generation method is manual, this will be set to the same value passed in.
 * If p_validate is true this will be set to the same value as passed in.
 * @param p_expense_check_send_to_addres {@rep:casecolumn
 * PER_ALL_PEOPLE_F.EXPENSE_CHECK_SEND_TO_ADDRESS}
 * @param p_first_name Applicant's first name (Kanji).
 * @param p_first_name_kana Applicant's first name (Kana).
 * @param p_known_as {@rep:casecolumn PER_ALL_PEOPLE_F.KNOWN_AS}
 * @param p_marital_status {@rep:casecolumn PER_ALL_PEOPLE_F.MARITAL_STATUS}
 * @param p_middle_names Applicant's middle name(s).
 * @param p_nationality Applicant's nationality.
 * @param p_national_identifier {@rep:casecolumn
 * PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER}
 * @param p_previous_last_name Previous last name (Kanji).
 * @param p_previous_last_name_kana Previous last name (Kana).
 * @param p_registered_disabled_flag {@rep:casecolumn
 * PER_ALL_PEOPLE_F.REGISTERED_DISABLED_FLAG}
 * @param p_title Applicant's title.
 * @param p_work_telephone {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_TELEPHONE}
 * @param p_per_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_per_attribute1 Descriptive flexfield segment.
 * @param p_per_attribute2 Descriptive flexfield segment.
 * @param p_per_attribute3 Descriptive flexfield segment.
 * @param p_per_attribute4 Descriptive flexfield segment.
 * @param p_per_attribute5 Descriptive flexfield segment.
 * @param p_per_attribute6 Descriptive flexfield segment.
 * @param p_per_attribute7 Descriptive flexfield segment.
 * @param p_per_attribute8 Descriptive flexfield segment.
 * @param p_per_attribute9 Descriptive flexfield segment.
 * @param p_per_attribute10 Descriptive flexfield segment.
 * @param p_per_attribute11 Descriptive flexfield segment.
 * @param p_per_attribute12 Descriptive flexfield segment.
 * @param p_per_attribute13 Descriptive flexfield segment.
 * @param p_per_attribute14 Descriptive flexfield segment.
 * @param p_per_attribute15 Descriptive flexfield segment.
 * @param p_per_attribute16 Descriptive flexfield segment.
 * @param p_per_attribute17 Descriptive flexfield segment.
 * @param p_per_attribute18 Descriptive flexfield segment.
 * @param p_per_attribute19 Descriptive flexfield segment.
 * @param p_per_attribute20 Descriptive flexfield segment.
 * @param p_per_attribute21 Descriptive flexfield segment.
 * @param p_per_attribute22 Descriptive flexfield segment.
 * @param p_per_attribute23 Descriptive flexfield segment.
 * @param p_per_attribute24 Descriptive flexfield segment.
 * @param p_per_attribute25 Descriptive flexfield segment.
 * @param p_per_attribute26 Descriptive flexfield segment.
 * @param p_per_attribute27 Descriptive flexfield segment.
 * @param p_per_attribute28 Descriptive flexfield segment.
 * @param p_per_attribute29 Descriptive flexfield segment.
 * @param p_per_attribute30 Descriptive flexfield segment.
 * @param p_correspondence_language {@rep:casecolumn
 * PER_ALL_PEOPLE_F.CORRESPONDENCE_LANGUAGE}
 * @param p_fte_capacity {@rep:casecolumn PER_ALL_PEOPLE_F.FTE_CAPACITY}
 * @param p_hold_applicant_date_until {@rep:casecolumn
 * PER_ALL_PEOPLE_F.HOLD_APPLICANT_DATE_UNTIL}
 * @param p_honors {@rep:casecolumn PER_ALL_PEOPLE_F.HONORS}
 * @param p_mailstop {@rep:casecolumn PER_ALL_PEOPLE_F.MAILSTOP}
 * @param p_office_number {@rep:casecolumn PER_ALL_PEOPLE_F.OFFICE_NUMBER}
 * @param p_on_military_service {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ON_MILITARY_SERVICE}
 * @param p_resume_exists {@rep:casecolumn PER_ALL_PEOPLE_F.RESUME_EXISTS}
 * @param p_resume_last_updated {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RESUME_LAST_UPDATED}
 * @param p_student_status {@rep:casecolumn PER_ALL_PEOPLE_F.STUDENT_STATUS}
 * @param p_work_schedule {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_SCHEDULE}
 * @param p_date_of_death {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_DEATH}
 * @param p_original_date_of_hire {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_application_id If p_validate is false, this uniquely identifies the
 * application created. If p_validate is true this parameter will be null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_apl_object_version_number If p_validate is false, this will be set
 * to the version number of the application created. If p_validate is true this
 * parameter will be set to null.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person. If p_validate is true,
 * then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then will be set to the identifier of the created person comment
 * record. If p_validate is true or no comment text was provided, then will be
 * null.
 * @param p_assignment_sequence If p_validate is false this will be set to the
 * sequence number of the default assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning This is set to true if the original date of hire
 * is not null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @param p_id_flex_num Id flex number of the Personal Analysis key flexfield
 * structure.
 * @param p_pea_comments Comments.
 * @param p_date_from The date from which the special information record
 * applies.
 * @param p_date_to The date on which the special information record no longer
 * applies.
 * @param p_pea_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_pea_attribute1 Descriptive flexfield segment.
 * @param p_pea_attribute2 Descriptive flexfield segment.
 * @param p_pea_attribute3 Descriptive flexfield segment.
 * @param p_pea_attribute4 Descriptive flexfield segment.
 * @param p_pea_attribute5 Descriptive flexfield segment.
 * @param p_pea_attribute6 Descriptive flexfield segment.
 * @param p_pea_attribute7 Descriptive flexfield segment.
 * @param p_pea_attribute8 Descriptive flexfield segment.
 * @param p_pea_attribute9 Descriptive flexfield segment.
 * @param p_pea_attribute10 Descriptive flexfield segment.
 * @param p_pea_attribute11 Descriptive flexfield segment.
 * @param p_pea_attribute12 Descriptive flexfield segment.
 * @param p_pea_attribute13 Descriptive flexfield segment.
 * @param p_pea_attribute14 Descriptive flexfield segment.
 * @param p_pea_attribute15 Descriptive flexfield segment.
 * @param p_pea_attribute16 Descriptive flexfield segment.
 * @param p_pea_attribute17 Descriptive flexfield segment.
 * @param p_pea_attribute18 Descriptive flexfield segment.
 * @param p_pea_attribute19 Descriptive flexfield segment.
 * @param p_pea_attribute20 Descriptive flexfield segment.
 * @param p_segment1 Key flexfield segment.
 * @param p_segment2 Key flexfield segment.
 * @param p_segment3 Key flexfield segment.
 * @param p_segment4 Key flexfield segment.
 * @param p_segment5 Key flexfield segment.
 * @param p_segment6 Key flexfield segment.
 * @param p_segment7 Key flexfield segment.
 * @param p_segment8 Key flexfield segment.
 * @param p_segment9 Key flexfield segment.
 * @param p_segment10 Key flexfield segment.
 * @param p_segment11 Key flexfield segment.
 * @param p_segment12 Key flexfield segment.
 * @param p_segment13 Key flexfield segment.
 * @param p_segment14 Key flexfield segment.
 * @param p_segment15 Key flexfield segment.
 * @param p_segment16 Key flexfield segment.
 * @param p_segment17 Key flexfield segment.
 * @param p_segment18 Key flexfield segment.
 * @param p_segment19 Key flexfield segment.
 * @param p_segment20 Key flexfield segment.
 * @param p_segment21 Key flexfield segment.
 * @param p_segment22 Key flexfield segment.
 * @param p_segment23 Key flexfield segment.
 * @param p_segment24 Key flexfield segment.
 * @param p_segment25 Key flexfield segment.
 * @param p_segment26 Key flexfield segment.
 * @param p_segment27 Key flexfield segment.
 * @param p_segment28 Key flexfield segment.
 * @param p_segment29 Key flexfield segment.
 * @param p_segment30 Key flexfield segment.
 * @param p_pea_object_version_number If p_validate is false, then this is set
 * to the version number of the created special information record. If
 * p_validate is true, then the value will be null.
 * @param p_analysis_criteria_id If p_validate is false, this uniquely
 * identifies the combination of the personal analysis flexfield segments
 * created. If p_validate is true this parameter will be null.
 * @param p_person_analysis_id If p_validate is false, this uniquely identifies
 * the special information record created. If p_validate is true this parameter
 * will be null.
 * @rep:displayname Create Applicant with Special Information Type for Japan
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_jp_applicant_with_sit
  (
   -- for applicant
   --
   p_validate                      in     boolean  default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_last_name_kana                in     varchar2
  ,p_sex                           in     varchar2 default null
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_first_name_kana               in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_previous_last_name_kana       in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_work_telephone                in     varchar2 default null
  ,p_per_attribute_category        in     varchar2 default null
  ,p_per_attribute1                in     varchar2 default null
  ,p_per_attribute2                in     varchar2 default null
  ,p_per_attribute3                in     varchar2 default null
  ,p_per_attribute4                in     varchar2 default null
  ,p_per_attribute5                in     varchar2 default null
  ,p_per_attribute6                in     varchar2 default null
  ,p_per_attribute7                in     varchar2 default null
  ,p_per_attribute8                in     varchar2 default null
  ,p_per_attribute9                in     varchar2 default null
  ,p_per_attribute10               in     varchar2 default null
  ,p_per_attribute11               in     varchar2 default null
  ,p_per_attribute12               in     varchar2 default null
  ,p_per_attribute13               in     varchar2 default null
  ,p_per_attribute14               in     varchar2 default null
  ,p_per_attribute15               in     varchar2 default null
  ,p_per_attribute16               in     varchar2 default null
  ,p_per_attribute17               in     varchar2 default null
  ,p_per_attribute18               in     varchar2 default null
  ,p_per_attribute19               in     varchar2 default null
  ,p_per_attribute20               in     varchar2 default null
  ,p_per_attribute21               in     varchar2 default null
  ,p_per_attribute22               in     varchar2 default null
  ,p_per_attribute23               in     varchar2 default null
  ,p_per_attribute24               in     varchar2 default null
  ,p_per_attribute25               in     varchar2 default null
  ,p_per_attribute26               in     varchar2 default null
  ,p_per_attribute27               in     varchar2 default null
  ,p_per_attribute28               in     varchar2 default null
  ,p_per_attribute29               in     varchar2 default null
  ,p_per_attribute30               in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_original_date_of_hire         in     date     default null
  ,p_person_id                     out nocopy    number
  ,p_assignment_id                 out nocopy    number
  ,p_application_id                out nocopy    number
  ,p_per_object_version_number     out nocopy    number
  ,p_asg_object_version_number     out nocopy    number
  ,p_apl_object_version_number     out nocopy    number
  ,p_per_effective_start_date      out nocopy    date
  ,p_per_effective_end_date        out nocopy    date
  ,p_full_name                     out nocopy    varchar2
  ,p_per_comment_id                out nocopy    number
  ,p_assignment_sequence           out nocopy    number
  ,p_name_combination_warning      out nocopy    boolean
  ,p_orig_hire_warning             out nocopy    boolean

  /* for special information */

  ,p_id_flex_num                   in     number
  ,p_pea_comments                  in     varchar2 default null
  ,p_date_from                     in     date     default null
  ,p_date_to                       in     date     default null
  ,p_pea_attribute_category        in     varchar2 default null
  ,p_pea_attribute1                in     varchar2 default null
  ,p_pea_attribute2                in     varchar2 default null
  ,p_pea_attribute3                in     varchar2 default null
  ,p_pea_attribute4                in     varchar2 default null
  ,p_pea_attribute5                in     varchar2 default null
  ,p_pea_attribute6                in     varchar2 default null
  ,p_pea_attribute7                in     varchar2 default null
  ,p_pea_attribute8                in     varchar2 default null
  ,p_pea_attribute9                in     varchar2 default null
  ,p_pea_attribute10               in     varchar2 default null
  ,p_pea_attribute11               in     varchar2 default null
  ,p_pea_attribute12               in     varchar2 default null
  ,p_pea_attribute13               in     varchar2 default null
  ,p_pea_attribute14               in     varchar2 default null
  ,p_pea_attribute15               in     varchar2 default null
  ,p_pea_attribute16               in     varchar2 default null
  ,p_pea_attribute17               in     varchar2 default null
  ,p_pea_attribute18               in     varchar2 default null
  ,p_pea_attribute19               in     varchar2 default null
  ,p_pea_attribute20               in     varchar2 default null
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_pea_object_version_number     out nocopy    number
  ,p_analysis_criteria_id          out nocopy    number
  ,p_person_analysis_id            out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_jp_appl_with_educ_add >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new applicant for Japan.
 *
 * The person details, an application, a special information record of JP
 * Educational Background, a primary JP address, a default applicant assignment
 * and if required associated assignment budget values and a letter request are
 * created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business_group_id of a JP legislation. A valid person_type_id, if
 * specified, with a corresponding system type of 'APL', must be active and in
 * the same business group as that of the applicant being created. If a
 * person_type_id is not specified the API will use the default 'APL' type for
 * the business group. Special Information Type of JP Educational Background
 * must be set enabled against the business group.
 *
 * <p><b>Post Success</b><br>
 * The person, application, special information record, address, default
 * applicant assignment and if required associated assignment budget values and
 * a letter request will be created.
 *
 * <p><b>Post Failure</b><br>
 * The person, special information record, address, default applicant
 * assignment, associated assignment budget values and a letter request will
 * not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The date an application was received and the
 * effective start date of the person, application and assignment.
 * @param p_business_group_id The applicant's business group.
 * @param p_last_name Applicant's last name (Kanji).
 * @param p_last_name_kana Applicant's last name (Kana).
 * @param p_sex {@rep:casecolumn PER_ALL_PEOPLE_F.SEX}
 * @param p_person_type_id Person type id. If a person_type_id is not specified
 * the API will use the default 'APL' type for the business group.
 * @param p_per_comments Comments for person record.
 * @param p_date_employee_data_verified The date on which the applicant data
 * was last verified.
 * @param p_date_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_BIRTH}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_applicant_number This parameter details the applicant number. If
 * the number generation method is Manua,l then this parameter is mandatory. If
 * the number generation method is Automatic, then the value of this parameter
 * must be NULL. If p_validate is false and the applicant number generation
 * method is Automatic, this will be set to to the generated applicant number
 * of the person created. If p_validate is false and the applicant number
 * generation method is manual, this will be set to the same value passed in.
 * If p_validate is true this will be set to the same value as passed in.
 * @param p_expense_check_send_to_addres {@rep:casecolumn
 * PER_ALL_PEOPLE_F.EXPENSE_CHECK_SEND_TO_ADDRESS}
 * @param p_first_name Applicant's first name (Kanji).
 * @param p_first_name_kana Applicant's first name (Kana).
 * @param p_known_as {@rep:casecolumn PER_ALL_PEOPLE_F.KNOWN_AS}
 * @param p_marital_status {@rep:casecolumn PER_ALL_PEOPLE_F.MARITAL_STATUS}
 * @param p_middle_names Applicant's middle name(s).
 * @param p_nationality Applicant's nationality.
 * @param p_national_identifier {@rep:casecolumn
 * PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER}
 * @param p_previous_last_name Previous last name (Kanji).
 * @param p_previous_last_name_kana Previous last name (Kana).
 * @param p_registered_disabled_flag {@rep:casecolumn
 * PER_ALL_PEOPLE_F.REGISTERED_DISABLED_FLAG}
 * @param p_title Applicant's title.
 * @param p_work_telephone {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_TELEPHONE}
 * @param p_per_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_per_attribute1 Descriptive flexfield segment.
 * @param p_per_attribute2 Descriptive flexfield segment.
 * @param p_per_attribute3 Descriptive flexfield segment.
 * @param p_per_attribute4 Descriptive flexfield segment.
 * @param p_per_attribute5 Descriptive flexfield segment.
 * @param p_per_attribute6 Descriptive flexfield segment.
 * @param p_per_attribute7 Descriptive flexfield segment.
 * @param p_per_attribute8 Descriptive flexfield segment.
 * @param p_per_attribute9 Descriptive flexfield segment.
 * @param p_per_attribute10 Descriptive flexfield segment.
 * @param p_per_attribute11 Descriptive flexfield segment.
 * @param p_per_attribute12 Descriptive flexfield segment.
 * @param p_per_attribute13 Descriptive flexfield segment.
 * @param p_per_attribute14 Descriptive flexfield segment.
 * @param p_per_attribute15 Descriptive flexfield segment.
 * @param p_per_attribute16 Descriptive flexfield segment.
 * @param p_per_attribute17 Descriptive flexfield segment.
 * @param p_per_attribute18 Descriptive flexfield segment.
 * @param p_per_attribute19 Descriptive flexfield segment.
 * @param p_per_attribute20 Descriptive flexfield segment.
 * @param p_per_attribute21 Descriptive flexfield segment.
 * @param p_per_attribute22 Descriptive flexfield segment.
 * @param p_per_attribute23 Descriptive flexfield segment.
 * @param p_per_attribute24 Descriptive flexfield segment.
 * @param p_per_attribute25 Descriptive flexfield segment.
 * @param p_per_attribute26 Descriptive flexfield segment.
 * @param p_per_attribute27 Descriptive flexfield segment.
 * @param p_per_attribute28 Descriptive flexfield segment.
 * @param p_per_attribute29 Descriptive flexfield segment.
 * @param p_per_attribute30 Descriptive flexfield segment.
 * @param p_correspondence_language {@rep:casecolumn
 * PER_ALL_PEOPLE_F.CORRESPONDENCE_LANGUAGE}
 * @param p_fte_capacity {@rep:casecolumn PER_ALL_PEOPLE_F.FTE_CAPACITY}
 * @param p_hold_applicant_date_until {@rep:casecolumn
 * PER_ALL_PEOPLE_F.HOLD_APPLICANT_DATE_UNTIL}
 * @param p_honors {@rep:casecolumn PER_ALL_PEOPLE_F.HONORS}
 * @param p_mailstop {@rep:casecolumn PER_ALL_PEOPLE_F.MAILSTOP}
 * @param p_office_number {@rep:casecolumn PER_ALL_PEOPLE_F.OFFICE_NUMBER}
 * @param p_on_military_service {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ON_MILITARY_SERVICE}
 * @param p_resume_exists {@rep:casecolumn PER_ALL_PEOPLE_F.RESUME_EXISTS}
 * @param p_resume_last_updated {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RESUME_LAST_UPDATED}
 * @param p_student_status {@rep:casecolumn PER_ALL_PEOPLE_F.STUDENT_STATUS}
 * @param p_work_schedule {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_SCHEDULE}
 * @param p_date_of_death {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_DEATH}
 * @param p_original_date_of_hire {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then this is set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then this is set to null.
 * @param p_application_id If p_validate is false, this uniquely identifies the
 * application created. If p_validate is true this parameter will be null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_apl_object_version_number If p_validate is false, this will be set
 * to the version number of the application created. If p_validate is true this
 * parameter will be set to null.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person. If p_validate is true,
 * then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then will be set to the identifier of the created person comment
 * record. If p_validate is true or no comment text was provided, then will be
 * null.
 * @param p_assignment_sequence If p_validate is false this will be set to the
 * sequence number of the default assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @param p_pea_comments Comments for the special information record.
 * @param p_pea_date_from The date from which the special information record
 * applies.
 * @param p_pea_date_to The date on which the special information record no
 * longer applies.
 * @param p_pea_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_pea_attribute1 Descriptive flexfield segment.
 * @param p_pea_attribute2 Descriptive flexfield segment.
 * @param p_pea_attribute3 Descriptive flexfield segment.
 * @param p_pea_attribute4 Descriptive flexfield segment.
 * @param p_pea_attribute5 Descriptive flexfield segment.
 * @param p_pea_attribute6 Descriptive flexfield segment.
 * @param p_pea_attribute7 Descriptive flexfield segment.
 * @param p_pea_attribute8 Descriptive flexfield segment.
 * @param p_pea_attribute9 Descriptive flexfield segment.
 * @param p_pea_attribute10 Descriptive flexfield segment.
 * @param p_pea_attribute11 Descriptive flexfield segment.
 * @param p_pea_attribute12 Descriptive flexfield segment.
 * @param p_pea_attribute13 Descriptive flexfield segment.
 * @param p_pea_attribute14 Descriptive flexfield segment.
 * @param p_pea_attribute15 Descriptive flexfield segment.
 * @param p_pea_attribute16 Descriptive flexfield segment.
 * @param p_pea_attribute17 Descriptive flexfield segment.
 * @param p_pea_attribute18 Descriptive flexfield segment.
 * @param p_pea_attribute19 Descriptive flexfield segment.
 * @param p_pea_attribute20 Descriptive flexfield segment.
 * @param p_school_type Type of School. Valid values are defined by
 * 'JP_SCHOOL_TYPE' lookup type.
 * @param p_school_id {@rep:casecolumn PER_JP_SCHOOL_LOOKUPS.SCHOOL_ID}
 * @param p_school_name {@rep:casecolumn PER_JP_SCHOOL_LOOKUPS.SCHOOL_NAME}
 * @param p_school_name_kana {@rep:casecolumn
 * PER_JP_SCHOOL_LOOKUPS.SCHOOL_NAME_KANA}
 * @param p_major {@rep:casecolumn PER_JP_SCHOOL_LOOKUPS.MAJOR}
 * @param p_major_kana {@rep:casecolumn PER_JP_SCHOOL_LOOKUPS.MAJOR_KANA}
 * @param p_advisor Department.
 * @param p_graduation_date Graduation Date.
 * @param p_note Note.
 * @param p_last_flag This identifies the last educational background detail
 * for the applicant.
 * @param p_pea_object_version_number If p_validate is false, then this is set
 * to the version number of the created special information record. If
 * p_validate is true, then the value will be null.
 * @param p_analysis_criteria_id If p_validate is false, this uniquely
 * identifies the combination of the personal analysis flexfield segments
 * created. If p_validate is true this parameter will be null.
 * @param p_person_analysis_id If p_validate is false, this uniquely identifies
 * the special information record created. If p_validate is true this parameter
 * will be null.
 * @param p_add_date_from The date from which the address applies.
 * @param p_add_date_to The date on which the address no longer applies.
 * @param p_address_type Type of address. Valid values are defined by
 * 'ADDRESS_TYPE' lookup type.
 * @param p_add_comments Comment text for address.
 * @param p_address_line1 Line 1 of address.
 * @param p_address_line2 Line 2 of address.
 * @param p_address_line3 Line 3 of address.
 * @param p_district_code District code.
 * @param p_address_line1_kana Line 1 of address (Kana).
 * @param p_address_line2_kana Line 2 of address (Kana).
 * @param p_address_line3_kana Line 3 of address (Kana).
 * @param p_postcode Postal Code.
 * @param p_country Country.
 * @param p_telephone_number_1 Telephone number.
 * @param p_telephone_number_2 Telephone number.
 * @param p_fax_number Fax Number.
 * @param p_addr_attribute_category This context value determines which
 * flexfield structure to use with the Person Address descriptive flexfield
 * segments.
 * @param p_addr_attribute1 Descriptive flexfield segment.
 * @param p_addr_attribute2 Descriptive flexfield segment.
 * @param p_addr_attribute3 Descriptive flexfield segment.
 * @param p_addr_attribute4 Descriptive flexfield segment.
 * @param p_addr_attribute5 Descriptive flexfield segment.
 * @param p_addr_attribute6 Descriptive flexfield segment.
 * @param p_addr_attribute7 Descriptive flexfield segment.
 * @param p_addr_attribute8 Descriptive flexfield segment.
 * @param p_addr_attribute9 Descriptive flexfield segment.
 * @param p_addr_attribute10 Descriptive flexfield segment.
 * @param p_addr_attribute11 Descriptive flexfield segment.
 * @param p_addr_attribute12 Descriptive flexfield segment.
 * @param p_addr_attribute13 Descriptive flexfield segment.
 * @param p_addr_attribute14 Descriptive flexfield segment.
 * @param p_addr_attribute15 Descriptive flexfield segment.
 * @param p_addr_attribute16 Descriptive flexfield segment.
 * @param p_addr_attribute17 Descriptive flexfield segment.
 * @param p_addr_attribute18 Descriptive flexfield segment.
 * @param p_addr_attribute19 Descriptive flexfield segment.
 * @param p_addr_attribute20 Descriptive flexfield segment.
 * @param p_address_id If p_validate is false, this uniquely identifies the
 * address created. If p_validate is true, this is set to null.
 * @param p_add_object_version_number If p_validate is false, then this is set
 * to the version number of the created address. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Applicant with Education Background and Address for Japan
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_jp_appl_with_educ_add
  (
   -- for per_people_f
   --
   p_validate                      in     boolean  default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_last_name_kana                in     varchar2
  ,p_sex                           in     varchar2 default null
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_first_name_kana               in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_previous_last_name_kana       in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_work_telephone                in     varchar2 default null
  ,p_per_attribute_category        in     varchar2 default null
  ,p_per_attribute1                in     varchar2 default null
  ,p_per_attribute2                in     varchar2 default null
  ,p_per_attribute3                in     varchar2 default null
  ,p_per_attribute4                in     varchar2 default null
  ,p_per_attribute5                in     varchar2 default null
  ,p_per_attribute6                in     varchar2 default null
  ,p_per_attribute7                in     varchar2 default null
  ,p_per_attribute8                in     varchar2 default null
  ,p_per_attribute9                in     varchar2 default null
  ,p_per_attribute10               in     varchar2 default null
  ,p_per_attribute11               in     varchar2 default null
  ,p_per_attribute12               in     varchar2 default null
  ,p_per_attribute13               in     varchar2 default null
  ,p_per_attribute14               in     varchar2 default null
  ,p_per_attribute15               in     varchar2 default null
  ,p_per_attribute16               in     varchar2 default null
  ,p_per_attribute17               in     varchar2 default null
  ,p_per_attribute18               in     varchar2 default null
  ,p_per_attribute19               in     varchar2 default null
  ,p_per_attribute20               in     varchar2 default null
  ,p_per_attribute21               in     varchar2 default null
  ,p_per_attribute22               in     varchar2 default null
  ,p_per_attribute23               in     varchar2 default null
  ,p_per_attribute24               in     varchar2 default null
  ,p_per_attribute25               in     varchar2 default null
  ,p_per_attribute26               in     varchar2 default null
  ,p_per_attribute27               in     varchar2 default null
  ,p_per_attribute28               in     varchar2 default null
  ,p_per_attribute29               in     varchar2 default null
  ,p_per_attribute30               in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_original_date_of_hire         in     date     default null
  ,p_person_id                     out nocopy    number
  ,p_assignment_id                 out nocopy    number
  ,p_application_id                out nocopy    number
  ,p_per_object_version_number     out nocopy    number
  ,p_asg_object_version_number     out nocopy    number
  ,p_apl_object_version_number     out nocopy    number
  ,p_per_effective_start_date      out nocopy    date
  ,p_per_effective_end_date        out nocopy    date
  ,p_full_name                     out nocopy    varchar2
  ,p_per_comment_id                out nocopy    number
  ,p_assignment_sequence           out nocopy    number
  ,p_name_combination_warning      out nocopy    boolean
  ,p_orig_hire_warning             out nocopy    boolean
  --
  -- for special information
  --
  ,p_pea_comments                  in     varchar2 default null
  ,p_pea_date_from                 in     date     default null
  ,p_pea_date_to                   in     date     default null
  ,p_pea_attribute_category        in     varchar2 default null
  ,p_pea_attribute1                in     varchar2 default null
  ,p_pea_attribute2                in     varchar2 default null
  ,p_pea_attribute3                in     varchar2 default null
  ,p_pea_attribute4                in     varchar2 default null
  ,p_pea_attribute5                in     varchar2 default null
  ,p_pea_attribute6                in     varchar2 default null
  ,p_pea_attribute7                in     varchar2 default null
  ,p_pea_attribute8                in     varchar2 default null
  ,p_pea_attribute9                in     varchar2 default null
  ,p_pea_attribute10               in     varchar2 default null
  ,p_pea_attribute11               in     varchar2 default null
  ,p_pea_attribute12               in     varchar2 default null
  ,p_pea_attribute13               in     varchar2 default null
  ,p_pea_attribute14               in     varchar2 default null
  ,p_pea_attribute15               in     varchar2 default null
  ,p_pea_attribute16               in     varchar2 default null
  ,p_pea_attribute17               in     varchar2 default null
  ,p_pea_attribute18               in     varchar2 default null
  ,p_pea_attribute19               in     varchar2 default null
  ,p_pea_attribute20               in     varchar2 default null
  ,p_school_type                   in     varchar2 default null
  ,p_school_id                     in     varchar2 default null
  ,p_school_name                   in     varchar2 default null
  ,p_school_name_kana              in     varchar2 default null
  ,p_major                         in     varchar2 default null
  ,p_major_kana                    in     varchar2 default null
  ,p_advisor                       in     varchar2 default null
  ,p_graduation_date               in     varchar2 default null
  ,p_note                          in     varchar2 default null
  ,p_last_flag                     in     varchar2 default null
  ,p_pea_object_version_number     out nocopy    number
  ,p_analysis_criteria_id          out nocopy    number
  ,p_person_analysis_id            out nocopy    number
  --
  -- for per_addresses
  --
  ,p_add_date_from                 in     date     default null
  ,p_add_date_to                   in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_add_comments                  in     varchar2 default null
  ,p_address_line1                 in     varchar2 default null
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_district_code                 in     varchar2 default null
  ,p_address_line1_kana            in     varchar2 default null
  ,p_address_line2_kana            in     varchar2 default null
  ,p_address_line3_kana            in     varchar2 default null
  ,p_postcode                      in     varchar2 default null
  ,p_country                       in     varchar2 default null
  ,p_telephone_number_1            in     varchar2 default null
  ,p_telephone_number_2            in     varchar2 default null
  ,p_fax_number                    in     varchar2 default null
  ,p_addr_attribute_category       in     varchar2 default null
  ,p_addr_attribute1               in     varchar2 default null
  ,p_addr_attribute2               in     varchar2 default null
  ,p_addr_attribute3               in     varchar2 default null
  ,p_addr_attribute4               in     varchar2 default null
  ,p_addr_attribute5               in     varchar2 default null
  ,p_addr_attribute6               in     varchar2 default null
  ,p_addr_attribute7               in     varchar2 default null
  ,p_addr_attribute8               in     varchar2 default null
  ,p_addr_attribute9               in     varchar2 default null
  ,p_addr_attribute10              in     varchar2 default null
  ,p_addr_attribute11              in     varchar2 default null
  ,p_addr_attribute12              in     varchar2 default null
  ,p_addr_attribute13              in     varchar2 default null
  ,p_addr_attribute14              in     varchar2 default null
  ,p_addr_attribute15              in     varchar2 default null
  ,p_addr_attribute16              in     varchar2 default null
  ,p_addr_attribute17              in     varchar2 default null
  ,p_addr_attribute18              in     varchar2 default null
  ,p_addr_attribute19              in     varchar2 default null
  ,p_addr_attribute20              in     varchar2 default null
  ,p_address_id                    out nocopy number
  ,p_add_object_version_number     out nocopy number
  );

--
end HR_JPBP_API;

 

/
