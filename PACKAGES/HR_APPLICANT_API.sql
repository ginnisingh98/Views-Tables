--------------------------------------------------------
--  DDL for Package HR_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICANT_API" AUTHID CURRENT_USER as
/* $Header: peappapi.pkh 120.5.12010000.5 2009/08/04 11:21:03 pannapur ship $ */
/*#
 * This package contains applicant APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Applicant
*/
--
-- ---------------------------------------------------------------------------
-- |--------------------------< create_applicant >---------------------------|
-- ---------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new applicant.
 *
 * The API creates the person details, an application, a default applicant
 * assignment, and if required associated assignment budget values, and a
 * letter request. The API adds the applicant to the security lists so that
 * secure users can see the applicant. If a person_type_id is not specified the
 * API will use the default 'APL' type for the business group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business group must exist. Also a valid person_type_id, with a
 * corresponding system type of 'APL' must be active and in the same business
 * group as that of the applicant being created.
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates the person, application, default applicant
 * assignment and if required associated assignment budget values, and a letter
 * request.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the person, default applicant assignment, associated
 * assignment budget values, and a letter request and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The date an application was received and thus the
 * effective start date of the person, application, and assignment.
 * @param p_business_group_id The applicant's business group.
 * @param p_last_name The applicant's last name.
 * @param p_person_type_id Person type id. If a person_type_id is not specified
 * , then the API will use the default 'APL' type for the business group.
 * @param p_applicant_number Identifies the applicant number. If the number
 * generation method is Manual, then this parameter is mandatory. If the number
 * generation method is Automatic, then the value of this parameter must be
 * null. If p_validate is false and the applicant number generation method is
 * Automatic, then this will be set to the generated applicant number of the
 * person created. If p_validate is false and the applicant number generation
 * method is manual, then this will be set to the same value passed in. If
 * p_validate is true, then this will be set to the same value as passed in.
 * @param p_per_comments Comments for the person record.
 * @param p_date_employee_data_verified The date on which the applicant data
 * was last verified.
 * @param p_date_of_birth Date of birth of the applicant.
 * @param p_email_address E-mail address of the applicant.
 * @param p_expense_check_send_to_addres Address to use as the applicant's
 * mailing address.
 * @param p_first_name Applicant's first name.
 * @param p_known_as Applicant's alternative name.
 * @param p_marital_status Applicant's marital status. Valid values are defined
 * by the 'MAR_STATUS' lookup type.
 * @param p_middle_names Applicant's middle name(s).
 * @param p_nationality Applicant's nationality. Valid values are defined by
 * the 'NATIONALITY' lookup type.
 * @param p_national_identifier Applicant's national identifier.
 * @param p_previous_last_name Applicant's previous last name.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values exist in the 'REGISTERED_DISABLED' lookup type.
 * @param p_sex The sex of the applicant.
 * @param p_title The title of the applicant. Valid values are defined by the
 * 'TITLE' lookup type.
 * @param p_work_telephone Work telephone of the applicant.
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
 * @param p_per_information_category Obsolete parameter, do not use.
 * @param p_per_information1 Developer descriptive flexfield segment.
 * @param p_per_information2 Developer descriptive flexfield segment.
 * @param p_per_information3 Developer descriptive flexfield segment.
 * @param p_per_information4 Developer descriptive flexfield segment.
 * @param p_per_information5 Developer descriptive flexfield segment.
 * @param p_per_information6 Developer descriptive flexfield segment.
 * @param p_per_information7 Developer descriptive flexfield segment.
 * @param p_per_information8 Developer descriptive flexfield segment.
 * @param p_per_information9 Developer descriptive flexfield segment.
 * @param p_per_information10 Developer descriptive flexfield segment.
 * @param p_per_information11 Developer descriptive flexfield segment.
 * @param p_per_information12 Developer descriptive flexfield segment.
 * @param p_per_information13 Developer descriptive flexfield segment.
 * @param p_per_information14 Developer descriptive flexfield segment.
 * @param p_per_information15 Developer descriptive flexfield segment.
 * @param p_per_information16 Developer descriptive flexfield segment.
 * @param p_per_information17 Developer descriptive flexfield segment.
 * @param p_per_information18 Developer descriptive flexfield segment.
 * @param p_per_information19 Developer descriptive flexfield segment.
 * @param p_per_information20 Developer descriptive flexfield segment.
 * @param p_per_information21 Developer descriptive flexfield segment.
 * @param p_per_information22 Developer descriptive flexfield segment.
 * @param p_per_information23 Developer descriptive flexfield segment.
 * @param p_per_information24 Developer descriptive flexfield segment.
 * @param p_per_information25 Developer descriptive flexfield segment.
 * @param p_per_information26 Developer descriptive flexfield segment.
 * @param p_per_information27 Developer descriptive flexfield segment.
 * @param p_per_information28 Developer descriptive flexfield segment.
 * @param p_per_information29 Developer descriptive flexfield segment.
 * @param p_per_information30 Developer descriptive flexfield segment.
 * @param p_background_check_status Indicates whether the person's background
 * has been checked. Valid values exist in the 'YES_NO' lookup type.
 * @param p_background_date_check Date when the background check was performed
 * on the applicant.
 * @param p_correspondence_language Applicant's preferred language for
 * correspondence.
 * @param p_fte_capacity This parameter is currently not supported.
 * @param p_hold_applicant_date_until Date till the applicant's information is
 * to be maintained.
 * @param p_honors Honors or degrees awarded.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Office number of the applicant.
 * @param p_on_military_service Type of military service.
 * @param p_pre_name_adjunct First part of surname such as Van or De.
 * @param p_projected_start_date This parameter is currently not supported.
 * @param p_resume_exists Y/N flag indicating whether the applicant's resume
 * exists in the database.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_student_status Indicates the type of student status. Valid values
 * are defined by the 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Type of work schedule indicating days on which the
 * person works. Valid values are defined by the 'WORK_SCHEDULE' lookup type.
 * @param p_suffix Suffix after the person's last name.
 * @param p_date_of_death Date of death of the applicant.
 * @param p_benefit_group_id Identification number for the benefit group.
 * @param p_receipt_of_death_cert_date Date when the death certificate was
 * received.
 * @param p_coord_ben_med_pln_no Number of the medical plan provided by an
 * external organization.
 * @param p_coord_ben_no_cvg_flag Indicates that the person is not covered by
 * any other benefit plan.
 * @param p_uses_tobacco_flag Tobacco type used by the person. Valid values are
 * defined by 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date on which the dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_town_of_birth Town or city of birth of the applicant.
 * @param p_region_of_birth Geographical region of birth of the applicant.
 * @param p_country_of_birth Country of birth of the applicant.
 * @param p_global_person_id Global identification number for the person.
 * @param p_party_id TCA party ID for whom you create the person record.
 * @param p_vacancy_id Identifies the vacancy for which the person has applied.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_application_id If p_validate is false, this uniquely identifies the
 * application created. If p_validate is true this parameter will be null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then set to
 * null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_apl_object_version_number If p_validate is false, this will be set
 * to the version number of the application created. If p_validate is true this
 * parameter will be set to null.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false, then this will be set to the
 * id of the corresponding person comment row, if any comment text exists. If
 * p_validate is true this will be null.
 * @param p_assignment_sequence If p_validate is false this will be set to the
 * sequence number of the default assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create Applicant
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
-- {End Of Comments}
--
procedure create_applicant
  (p_validate                     in     boolean  default false
  ,p_date_received                in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_person_type_id               in     number   default null
  ,p_applicant_number             in out nocopy varchar2
  ,p_per_comments                 in     varchar2 default null
  ,p_date_employee_data_verified  in     date     default null
  ,p_date_of_birth                in     date     default null
  ,p_email_address                in     varchar2 default null
  ,p_expense_check_send_to_addres in     varchar2 default null
  ,p_first_name                   in     varchar2 default null
  ,p_known_as                     in     varchar2 default null
  ,p_marital_status               in     varchar2 default null
  ,p_middle_names                 in     varchar2 default null
  ,p_nationality                  in     varchar2 default null
  ,p_national_identifier          in     varchar2 default null
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
  ,p_per_information_category     in     varchar2 default null
  -- p_per_information_category - Obsolete parameter, do not use
  ,p_per_information1             in     varchar2 default null
  ,p_per_information2             in     varchar2 default null
  ,p_per_information3             in     varchar2 default null
  ,p_per_information4             in     varchar2 default null
  ,p_per_information5             in     varchar2 default null
  ,p_per_information6             in     varchar2 default null
  ,p_per_information7             in     varchar2 default null
  ,p_per_information8             in     varchar2 default null
  ,p_per_information9             in     varchar2 default null
  ,p_per_information10            in     varchar2 default null
  ,p_per_information11            in     varchar2 default null
  ,p_per_information12            in     varchar2 default null
  ,p_per_information13            in     varchar2 default null
  ,p_per_information14            in     varchar2 default null
  ,p_per_information15            in     varchar2 default null
  ,p_per_information16            in     varchar2 default null
  ,p_per_information17            in     varchar2 default null
  ,p_per_information18            in     varchar2 default null
  ,p_per_information19            in     varchar2 default null
  ,p_per_information20            in     varchar2 default null
  ,p_per_information21            in     varchar2 default null
  ,p_per_information22            in     varchar2 default null
  ,p_per_information23            in     varchar2 default null
  ,p_per_information24            in     varchar2 default null
  ,p_per_information25            in     varchar2 default null
  ,p_per_information26            in     varchar2 default null
  ,p_per_information27            in     varchar2 default null
  ,p_per_information28            in     varchar2 default null
  ,p_per_information29            in     varchar2 default null
  ,p_per_information30            in     varchar2 default null
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
  ,p_town_of_birth                in      varchar2 default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_global_person_id             in      varchar2 default null
  ,p_party_id                     in      number default null
  ,p_vacancy_id                   in      number default null
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
-- |-------------------------< create_gb_applicant >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an applicant in the United Kingdom business group.
 *
 * The API creates the person details including a default primary assignment,
 * and an application for the applicant. The API calls the generic API
 * create_applicant, with the parameters set as appropriate for a British
 * applicant. See the create_applicant API for further documentation as this
 * API is effectively an alternative.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * A valid United Kingdom business group must exist. Also a valid
 * person_type_id, with a corresponding system type of 'APL' must be active and
 * in the same business group as that of the applicant being created.
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates the applicant, default assignment or
 * application.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the applicant, default assignment or application and
 * raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The date an application was received and thus the
 * effective start date of the person, application, and assignment.
 * @param p_business_group_id The applicant's business group.
 * @param p_last_name The applicant's last name.
 * @param p_sex The sex of the applicant.
 * @param p_person_type_id Person type id. If this value is omitted, then the
 * API uses theperson_type_id of the active default `APL' system person type in
 * the applicant's business group.
 * @param p_applicant_number Identifes the applicant number. If the number
 * generation method is Manual, then this parameter is mandatory. If the number
 * generation method is Automatic, then the value of this parameter must be
 * null. If p_validate is false and the applicant number generation method is
 * Automatic, then this will be set to the generated applicant number of the
 * person created. If p_validate is false and the applicant number generation
 * method is manual, then this will be set to the same value passed in. If
 * p_validate is true, then this will be set to the same value as passed in.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified The date on which the applicant data
 * was last verified.
 * @param p_date_of_birth Date of birth of the applicant.
 * @param p_email_address E-mail address of the applicant.
 * @param p_expense_check_send_to_addres Address to use as the applicant's
 * mailing address.
 * @param p_first_name Applicant's first name.
 * @param p_known_as Applicant's alternative name.
 * @param p_marital_status Applicant's marital status. Valid values are defined
 * by the 'MAR_STATUS' lookup type.
 * @param p_middle_names Applicant's middle name(s).
 * @param p_nationality Applicant's nationality. Valid values are defined by
 * the 'NATIONALITY' lookup type.
 * @param p_ni_number Number by which a person is identified in the United
 * Kingdom legislation.
 * @param p_previous_last_name Applicant's previous last name.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values exist in the 'REGISTERED_DISABLED' lookup type.
 * @param p_title The title of the applicant. Valid values are defined by the
 * 'TITLE' lookup type.
 * @param p_work_telephone Work telephone of the applicant.
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
 * @param p_ethnic_origin Applicant's ethnic origin. Valid values are defined
 * by the ETH_TYPE lookup type.
 * @param p_director Indicates whether the person is a company director.
 * @param p_pensioner Indicates whether the person is a pensioner.
 * @param p_work_permit_number Identifies the work permit number of the
 * applicant.
 * @param p_addl_pension_years Additional pension years.
 * @param p_addl_pension_months Additional pension months.
 * @param p_addl_pension_days Additional pension days.
 * @param p_ni_multiple_asg Identifies whether national insurance should be
 * calculated according to the multiple assignments rules. Valid values are
 * defined by the YES_NO lookup type.
 * @param p_background_check_status Indicates whether the person's background
 * has been checked. Valid values exist in the 'YES_NO' lookup type.
 * @param p_background_date_check Date when the background check was performed
 * on the applicant.
 * @param p_correspondence_language Applicant's preferred language for
 * correspondence.
 * @param p_fte_capacity This parameter is currently not supported.
 * @param p_hold_applicant_date_until Date til the applicant's information is
 * to be maintained.
 * @param p_honors Honors or degrees awarded.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Office number of the applicant.
 * @param p_on_military_service Type of military service.
 * @param p_pre_name_adjunct First part of surname such as Van or De.
 * @param p_projected_start_date This parameter is currently not supported.
 * @param p_resume_exists Y/N flag indicating whether the applicant's resume
 * exists in the database.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_student_status Indiciates the type of student status. Valid values
 * are defined by the 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Type of work schedule indicating days on which the
 * person works. Valid values are defined by the 'WORK_SCHEDULE' lookup type.
 * @param p_suffix Suffix after the person's last name.
 * @param p_date_of_death Date of death of the applicant.
 * @param p_benefit_group_id Identification number for the benefit group.
 * @param p_receipt_of_death_cert_date Date when the death certificate was
 * received.
 * @param p_coord_ben_med_pln_no Number of the medical plan provided by an
 * external organization.
 * @param p_coord_ben_no_cvg_flag Indicates that the person is not covered by
 * any other benefit plan.
 * @param p_uses_tobacco_flag Tobacco type used by the person. Valid values are
 * defined by 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date on which the dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_town_of_birth Town or city of birth of the applicant.
 * @param p_region_of_birth Geographical region of birth of the applicant.
 * @param p_country_of_birth Country of birth of the applicant.
 * @param p_global_person_id Global identification number for the person.
 * @param p_party_id TCA party ID for whom you create the person record.
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
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false, then this will be set to the
 * id of the corresponding person comment row, if any comment text exists. If
 * p_validate is true this will be null.
 * @param p_assignment_sequence If p_validate is false this will be set to the
 * sequence number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create Applicant for United Kingdom
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
-- {End Of Comments}
--
procedure create_gb_applicant
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
  ,p_ethnic_origin                 in     varchar2 default null
  ,p_director                      in     varchar2 default 'N'
  ,p_pensioner                     in     varchar2 default 'N'
  ,p_work_permit_number            in     varchar2 default null
  ,p_addl_pension_years            in     varchar2 default null
  ,p_addl_pension_months           in     varchar2 default null
  ,p_addl_pension_days             in     varchar2 default null
  ,p_ni_multiple_asg               in     varchar2 default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_date_of_death                in     date     default null
  ,p_benefit_group_id             in     number   default null
  ,p_receipt_of_death_cert_date   in     date     default null
  ,p_coord_ben_med_pln_no         in     varchar2 default null
  ,p_coord_ben_no_cvg_flag        in     varchar2 default 'N'
  ,p_uses_tobacco_flag            in     varchar2 default null
  ,p_dpdnt_adoption_date          in     date     default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2 default 'N'
  ,p_original_date_of_hire        in     date     default null
  ,p_town_of_birth                in      varchar2 default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_global_person_id             in      varchar2 default null
  ,p_party_id                     in      number   default null
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
  ,p_orig_hire_warning                out nocopy boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_us_applicant >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an applicant in the United States business group.
 *
 * The API creates the person details including a default primary assignment,
 * and an application for the applicant. The API calls the generic API
 * create_applicant, with the parameters set as appropriate for a US applicant.
 * See the create_applicant API for further documentation as this API is
 * effectively an alternative.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * A business group with a legislation of US must exist. Also a valid
 * person_type_id, with a corresponding system type of 'APL' must be active and
 * in the same business group as that of the applicant being created.
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates the person, primary assignment and period of
 * service.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the applicant, default assignment or application and
 * raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The date an application was received and thus the
 * effective start date of the person, application, and assignment.
 * @param p_business_group_id The applicant's business group.
 * @param p_last_name The applicant's last name.
 * @param p_sex The sex of the applicant.
 * @param p_person_type_id Person type id. If this value is omitted, then the
 * API uses theperson_type_id of the active default `APL' system person type in
 * the applicant's business group.
 * @param p_applicant_number Identifies the applicant number. If the number
 * generation method is Manual, then this parameter is mandatory. If the number
 * generation method is Automatic, then the value of this parameter must be
 * null. If p_validate is false and the applicant number generation method is
 * Automatic, then this will be set to the generated applicant number of the
 * person created. If p_validate is false and the applicant number generation
 * method is manual, then this will be set to the same value passed in. If
 * p_validate is true, then this will be set to the same value as passed in.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified The date on which the applicant data
 * was last verified.
 * @param p_date_of_birth Date of birth of the applicant.
 * @param p_email_address E-mail address of the applicant.
 * @param p_expense_check_send_to_addres Address to use as the applicant's
 * mailing address.
 * @param p_first_name Applicant's first name.
 * @param p_known_as Applicant's alternative name.
 * @param p_marital_status Applicant's marital status. Valid values are defined
 * by the 'MAR_STATUS' lookup type.
 * @param p_middle_names Applicant's middle name(s).
 * @param p_nationality Applicant's nationality. Valid values are defined by
 * the 'NATIONALITY' lookup type.
 * @param p_ss_number Social security number of the person.
 * @param p_previous_last_name Applicant's previous last name.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values exist in the 'REGISTERED_DISABLED' lookup type.
 * @param p_title The title of the applicant. Valid values are defined by the
 * 'TITLE' lookup type.
 * @param p_work_telephone Work telephone of the applicant.
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
 * @param p_ethnic_origin Applicant's ethnic origin. Valid values are defined
 * by the ETH_TYPE lookup type.
 * @param p_i_9 Status of I9 Visa. Valid values are defined by the
 * PER_US_I9_STATE lookup type.
 * @param p_i_9_expiration_date I_9 expiration date.
 * @param p_veteran_status Identifies the veteran status of the applicant.
 * @param p_new_hire Status of the new hire. Valid values are defined by the
 * US_NEW_HIRE_STATUS lookup type.
 * @param p_exception_reason New hire exception reason. Valid values are
 * defined by the US_NEW_HIRE_EXCEPTIONS lookup type.
 * @param p_child_support_obligation Flag indicating whether the person has a
 * child support obligation.
 * @param p_opted_for_medicare_flag Flag indicating whether the person has
 * opted for additional medicare.
 * @param p_background_check_status Indicates whether the person's background
 * has been checked. Valid values exist in the 'YES_NO' lookup type.
 * @param p_background_date_check Date when the background check was performed
 * on the applicant.
 * @param p_correspondence_language Applicant's preferred language for
 * correspondence.
 * @param p_fte_capacity This parameter is currently not supported.
 * @param p_hold_applicant_date_until Date till the applicant's information is
 * to be maintained.
 * @param p_honors Honors or degrees awarded.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Office number of the applicant.
 * @param p_on_military_service Type of military service.
 * @param p_pre_name_adjunct First part of surname such as Van or De.
 * @param p_projected_start_date This parameter is currently not supported.
 * @param p_resume_exists Y/N flag indicating whether the applicant's resume
 * exists in the database.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_student_status Indicates the type of student status. Valid values
 * are defined by the 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Type of work schedule indicating days on which the
 * person works. Valid values are defined by the 'WORK_SCHEDULE' lookup type.
 * @param p_suffix Suffix after the person's last name.
 * @param p_date_of_death Date of death of the applicant.
 * @param p_benefit_group_id Identification number for the benefit group.
 * @param p_receipt_of_death_cert_date Date when the death certificate was
 * received.
 * @param p_coord_ben_med_pln_no Number of the medical plan provided by an
 * external organization.
 * @param p_coord_ben_no_cvg_flag Indicates that the person is not covered by
 * any other benefit plan.
 * @param p_uses_tobacco_flag Tobacco type used by the person. Valid values are
 * defined by 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date on which the dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_town_of_birth Town or city of birth of the applicant.
 * @param p_region_of_birth Geographical region of birth of the applicant.
 * @param p_country_of_birth Country of birth of the applicant.
 * @param p_global_person_id Global identification number for the person.
 * @param p_party_id TCA party ID for whom you create the person record.
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
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false, then this will be set to the
 * id of the corresponding person comment row, if any comment text exists. If
 * p_validate is true this will be null.
 * @param p_assignment_sequence If p_validate is false this will be set to the
 * sequence number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP, EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create US Applicant
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_us_applicant
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
  ,p_ss_number                     in     varchar2 default null
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
  ,p_ethnic_origin                 in     varchar2 default null
  ,p_I_9                           in     varchar2 default 'N'
  ,p_I_9_expiration_date           in     varchar2 default null
--  ,p_visa_type                     in     varchar2 default null
  ,p_veteran_status                in     varchar2 default null
  ,p_new_hire                      in     varchar2 default null
  ,p_exception_reason              in     varchar2 default null
  ,p_child_support_obligation      in     varchar2 default 'N'
  ,p_opted_for_medicare_flag       in     varchar2 default 'N'
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_date_of_death                in     date     default null
  ,p_benefit_group_id             in     number   default null
  ,p_receipt_of_death_cert_date   in     date     default null
  ,p_coord_ben_med_pln_no         in     varchar2 default null
  ,p_coord_ben_no_cvg_flag        in     varchar2 default 'N'
  ,p_uses_tobacco_flag            in     varchar2 default null
  ,p_dpdnt_adoption_date          in     date     default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2 default 'N'
  ,p_original_date_of_hire        in     date     default null
  ,p_town_of_birth                in      varchar2 default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_global_person_id             in      varchar2 default null
  ,p_party_id                     in      number   default null
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
  ,p_orig_hire_warning                out nocopy boolean
  );
--

procedure create_us_applicant
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
  ,p_ss_number                     in     varchar2 default null
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
  ,p_ethnic_origin                 in     varchar2 default null
  ,p_I_9                           in     varchar2 default 'N'
  ,p_I_9_expiration_date           in     varchar2 default null
--  ,p_visa_type                   in     varchar2 default null
  ,p_veteran_status                in     varchar2 default null
  ,p_vets100A                      in     varchar2
  ,p_new_hire                      in     varchar2 default null
  ,p_exception_reason              in     varchar2 default null
  ,p_child_support_obligation      in     varchar2 default 'N'
  ,p_opted_for_medicare_flag       in     varchar2 default 'N'
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_date_of_death                in     date     default null
  ,p_benefit_group_id             in     number   default null
  ,p_receipt_of_death_cert_date   in     date     default null
  ,p_coord_ben_med_pln_no         in     varchar2 default null
  ,p_coord_ben_no_cvg_flag        in     varchar2 default 'N'
  ,p_uses_tobacco_flag            in     varchar2 default null
  ,p_dpdnt_adoption_date          in     date     default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2 default 'N'
  ,p_original_date_of_hire        in     date     default null
  ,p_town_of_birth                in      varchar2 default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_global_person_id             in      varchar2 default null
  ,p_party_id                     in      number   default null
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
  ,p_orig_hire_warning                out nocopy boolean
  );

-- ---------------------------------------------------------------------------
-- |--------------------------< hire_applicant >---------------------------|
-- ---------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure hire_applicant
  (p_validate                  in      boolean   default false,
   p_hire_date                 in      date,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_assignment_id             in      number default null,
   p_person_type_id            in      number   default null,
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_employee_number           in out nocopy  per_all_people_f.employee_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean,
   p_original_date_of_hire     in      date default null,
   p_migrate                   in      boolean   default true,
   p_source 		       in      boolean   default false
);
--
--
-- ---------------------------------------------------------------------------
-- |--------------------------< hire_applicant >---------------------------|
-- ---------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API converts an applicant to an employee.
 *
 * This API converts data about a person of type applicant (APL, APL_EX_APL or
 * EX_EMP_APL) to a person type of employee (EMP). This procedure is overloaded
 * to keep the parameters in line with the base release. This is achieved by:
 * terminating the application record, terminating unaccepted applicant
 * assignments, setting person to an EMP, creating a period of service record,
 * and converting accepted applicant assignments to active employee
 * assignments.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * If person_type_id is supplied, then it must have an active corresponding
 * system person type of 'EMP' and must be in the same business group as that
 * of the applicant being changed to employee.
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
 * @param p_hire_date The person hire date and thus the effective start date of
 * the person, assignment, and period of service.
 * @param p_person_id Identifies the person record to be modified.
 * @param p_assignment_id Identifies the assignment for which you create the
 * person record.
 * @param p_person_type_id Person type id. The default value is null. . If this
 * value is omitted, then the API uses the person_type_id of the default `EMP'
 * system person type in the employee's business group.
 * @param p_national_identifier Applicant's national identifier.
 * @param p_per_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_employee_number The business group's employee number generation
 * method determines when you can update the employee value. To keep the
 * existing employee number pass in hr_api.g_varchar2. When the API call
 * completes if p_validate is true then will be set to the employee number. If
 * p_validate is true then will be set to the passed value.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_unaccepted_asg_del_warning If set to true, then the unaccepted
 * applicant assignments are terminated. Set to false if the unaccepted
 * applicant assignments do not exist.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_oversubscribed_vacancy_id If one of the vacancies that the
 * applicant was hired from is now oversubscribed, this will contain the id of
 * the vacancy, otherwise it will be null for the applicant. The default is
 * null.
 * @param p_original_date_of_hire Original date of hire.
 * @param p_migrate Default True. When True, will migrate global data of
 * @param p_source default false . Used to identify whether the api is called from SSHR or not.
 * applicant to the local use (addresses, phones, previous employers,
 * qualifications etc).
 * @rep:displayname Hire Applicant
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure hire_applicant
  (p_validate                  in      boolean   default false,
   p_hire_date                 in      date,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_assignment_id             in      number default null,
   p_person_type_id            in      number   default null,
   p_national_identifier       in      per_all_people_f.national_identifier%type default hr_api.g_varchar2,
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_employee_number           in out nocopy  per_all_people_f.employee_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean,
   p_oversubscribed_vacancy_id    out nocopy  number,
   p_original_date_of_hire     in      date default null,
   p_migrate                   in      boolean   default true,
   p_source 		       in      boolean   default false
);
--
--
-- -----------------------------------------------------------------------------
-- |--------------------------< terminate_applicant >--------------------------|
-- -----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
PROCEDURE terminate_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT hr_api.g_number
  ,p_termination_reason           IN     per_applications.termination_reason%TYPE    DEFAULT NULL
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  );
-- -----------------------------------------------------------------------------
-- |-----------------------< terminate_applicant(New) >------------------------|
-- -----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
PROCEDURE terminate_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT hr_api.g_number
  ,p_termination_reason           IN     per_applications.termination_reason%TYPE    DEFAULT NULL
  ,p_assignment_status_type_id    IN     per_all_assignments_f.assignment_status_type_id%TYPE --#3371944
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< terminate_applicant(New2) >----------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
PROCEDURE terminate_applicant
  (p_validate                     IN     BOOLEAN
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE
  ,p_termination_reason           IN     per_applications.termination_reason%TYPE
  ,p_assignment_status_type_id    IN     per_all_assignments_f.assignment_status_type_id%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_remove_fut_asg_warning          OUT NOCOPY BOOLEAN  -- 3652025
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< terminate_applicant(New3) >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start of Comments}
/*#
 * This API terminates an applicant.
 *
 * This API converts a person of type Applicant to a person of type
 * Ex-Applicant. The person's application and any applicant assignments are
 * ended.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The applicant must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The applicant is terminated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The applicant is not terminated and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_person_type_id Person type the person is to become. If this value
 * is omitted the person type id of the default system person type required in
 * the person's business group is used.
 * @param p_termination_reason Reason for terminating the applicant. Valid
 * values are defined by the TERM_APL_REASON lookup type.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_assignment_status_type_id Identifies the applicant assignment
 * status.
 * @param p_status_change_comments required for IRC tables.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_remove_fut_asg_warning If p_validate is false, set to TRUE if
 * future-dated assignments and/or assignment future datetrack changes have
 * been removed, otherwise is set to FALSE. If p_validate is true, set to null.
 * @rep:displayname Terminate Applicant
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End of Comments}
--
--
PROCEDURE terminate_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT hr_api.g_number
  ,p_termination_reason           IN     per_applications.termination_reason%TYPE    DEFAULT NULL
  ,p_assignment_status_type_id    IN     per_all_assignments_f.assignment_status_type_id%TYPE DEFAULT hr_api.g_number
  ,p_change_reason                IN     per_all_assignments_f.change_reason%TYPE -- 4066579
  ,p_status_change_comments       IN  irc_assignment_statuses.status_change_comments%TYPE DEFAULT NULL -- bug8732296
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_remove_fut_asg_warning          OUT NOCOPY BOOLEAN  -- 3652025
  );
--
-- -----------------------------------------------------------------------------
-- |------------------------< convert_to_applicant >---------------------------|
-- -----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
PROCEDURE convert_to_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_applicant_number             IN OUT NOCOPY per_all_people_f.applicant_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT NULL
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  );
-- NEW
-- -----------------------------------------------------------------------------
-- |------------------------< convert_to_applicant >---------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API converts a person into an applicant.
 *
 * The API sets the the person type to APL type. It creates an application or
 * updates an existing one. It also creates a default application assignment
 * and updates the security lists.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The API updates the person and application records.
 *
 * <p><b>Post Failure</b><br>
 * The API does not convert the person to an applicant and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_applicant_number Identifies the applicant number. The API ignores
 * this if the person already has an applicant number. This parameter is
 * required if the number generation method is manual. It must be null if the
 * number generation method is automatic. If p_validate is false, set to the
 * applicant number of the person. If p_validate is true, set to the value
 * passed in.
 * @param p_person_type_id Person type id the person is to become. If this
 * value is omitted the person type id of the default system person type
 * required in the person's business group is used.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_appl_override_warning If p_validate is false, this is set to TRUE
 * if future applications have been overwritten. If p_validate is true this is
 * set to null.
 * @rep:displayname Convert To Applicant
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE convert_to_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_applicant_number             IN OUT NOCOPY per_all_people_f.applicant_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT NULL
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_appl_override_warning           OUT NOCOPY boolean                -- 3652025
  );
--
-- ----------------------------------------------------------------------------+
-- |---------------------< apply_for_job_anytime >-----------------------------|
-- ----------------------------------------------------------------------------+
--
-- {Start Of Comments}
/*#
 * This API converts an existing person into an applicant.
 *
 * The API creates a new applicant assignment and an application for the
 * person. If person has been an applicant, the application might be reopened
 * depending on the effective date. The process updates the security lists.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist in the system.
 *
 * <p><b>Post Success</b><br>
 * When the person is successfully updated, applicant assignment and
 * application are successfully inserted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the person or create the applicant assignment or
 * application and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person record to be modified.
 * @param p_applicant_number Identifies the applicant number. If the number
 * generation method is Manual, then this parameter is mandatory. If the number
 * generation is Automatic, then the value of this parameter defaults to null
 * and the application will provide the corresponding value.
 * @param p_per_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_vacancy_id Identifies the vacancy for which the person has applied.
 * @param p_person_type_id Person Type ID of 'APL' flavor. If set to null, the
 * application will retrieve the default APL person type.
 * @param p_assignment_status_type_id Applicant assignment status type id. If
 * set to null, then the application will use the default status defined for
 * the person's business group.
 * @param p_application_id If p_validate is false, this uniquely identifies the
 * application created or reopened . If p_validate is true this parameter is
 * null.
 * @param p_assignment_id Identifies the assignment for which you create the
 * person record.
 * @param p_apl_object_version_number If p_validate is false, this will be set
 * to the version number of the application created or updated. If p_validate
 * is true this parameter is set to null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_assignment_sequence If p_validate is false, this will be set to the
 * assignment sequence of the assignment created. If p_validate is true, this
 * parameter is set to null.
 * @param p_per_effective_start_date If p_validate is false, this is set to the
 * effective start date of the person. If p_validate is true this is null.
 * @param p_per_effective_end_date If p_validate is false, this is set to the
 * effective end date of the person. If p_validate is true this is set null.
 * @param p_appl_override_warning if set to true, future applications existed
 * prior to calling this API. These applications have been removed after
 * successful conversion of the person into applicant. If set to false, then no
 * future applications were found.
 * @rep:displayname Apply For Job Anytime
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure apply_for_job_anytime
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_applicant_number              in out nocopy varchar2
  ,p_per_object_version_number     in out nocopy number
  ,p_vacancy_id                    in     number   default null
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number
  ,p_application_id                   out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_appl_override_warning            out nocopy boolean
  );
--
end hr_applicant_api;

/
