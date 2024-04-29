--------------------------------------------------------
--  DDL for Package HR_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTINGENT_WORKER_API" AUTHID CURRENT_USER as
/* $Header: pecwkapi.pkh 120.1.12010000.1 2008/07/28 04:28:14 appldev ship $ */
/*#
 * This package contains contingent worker APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Contingent Worker
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< create_cwk >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new contingent worker.
 *
 * This API creates a person record, a default contingent worker assignment,
 * and a period of placement for a new contingent worker. The process adds the
 * contingent worker to the security lists so that secure users can see the
 * contingent worker.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group must exist on the effective date. A valid
 * business_group_id, a valid person_type_id (if specified), and a
 * corresponding system type of CWK are required. The CWK type must be active
 * in the same business group as the contingent worker you are creating. If you
 * do not specify a person_type_id, the API uses the default CWK type for the
 * business group.
 *
 * <p><b>Post Success</b><br>
 * The API creates person details, a period of placement, and a default
 * contingent worker assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the contingent worker, primary assignment, or period
 * of placement and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date Start Date.
 * @param p_business_group_id Business group of the person.
 * @param p_last_name Last name.
 * @param p_person_type_id Type of contingent worker being created.
 * @param p_npw_number The business group's contingent worker number generation
 * method determines when the API derives and passes out a contingent worker
 * number or when the calling program should pass in a value. When the API call
 * completes if p_validate is true then will be set to the contingent worker
 * number. If p_validate is true then will be set to the passed value.
 * @param p_background_check_status Flag indicating whether the person's
 * background has been checked.
 * @param p_background_date_check Date on which the background check was
 * performed.
 * @param p_blood_type Blood type.
 * @param p_comments Comment text.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_country_of_birth Country of birth.
 * @param p_date_of_birth Date of birth.
 * @param p_date_of_death Date of death.
 * @param p_dpdnt_adoption_date Date on which the dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Flag indicating whether the dependent is on
 * voluntary service.
 * @param p_email_address Email address.
 * @param p_first_name First name.
 * @param p_fte_capacity Obsolete parameter, do not use.
 * @param p_honors Honors awarded.
 * @param p_internal_location Internal location of office.
 * @param p_known_as Preferred name.
 * @param p_last_medical_test_by Name of physician who performed last medical
 * test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Internal mail location.
 * @param p_marital_status Marital status. Valid values are defined by the
 * MAR_STATUS lookup type.
 * @param p_middle_names Middle names.
 * @param p_national_identifier Number by which a person is identified in a
 * given legislation.
 * @param p_nationality Nationality. Valid values are defined by the
 * NATIONALITY lookup type.
 * @param p_office_number Office number.
 * @param p_on_military_service Flag indicating whether the person is on
 * military service.
 * @param p_party_id TCA party for whom you create the person record.
 * @param p_pre_name_adjunct First part of the last name.
 * @param p_previous_last_name Previous last name.
 * @param p_projected_placement_end Obsolete parameter, do not use.
 * @param p_receipt_of_death_cert_date Date death certificate was received.
 * @param p_region_of_birth Geographical region of birth.
 * @param p_registered_disabled_flag Flag indicating whether the person is
 * classified as disabled.
 * @param p_resume_exists Flag indicating whether the person's resume is on
 * file.
 * @param p_resume_last_updated Date on which the resume was last updated.
 * @param p_second_passport_exists Flag indicating whether a person has
 * multiple passports.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_student_status If this contingent worker is a student, this field
 * is used to capture their status. Valid values are defined by the
 * STUDENT_STATUS lookup type.
 * @param p_suffix Suffix after the person's last name e.g. Sr., Jr., III.
 * @param p_title Title. Valid values are defined by the TITLE lookup type.
 * @param p_town_of_birth Town or city of birth.
 * @param p_uses_tobacco_flag Flag indicating whether the person uses tobacco.
 * @param p_vendor_id Obsolete parameter, do not use.
 * @param p_work_schedule Days on which this person will work.
 * @param p_work_telephone Obsolete parameter, do not use.
 * @param p_exp_check_send_to_address Mailing address.
 * @param p_hold_applicant_date_until Date until when the applicant's
 * information is to be maintained.
 * @param p_date_employee_data_verified Date on which the contingent worker
 * data was last verified.
 * @param p_benefit_group_id Benefit group to which this person will belong.
 * @param p_coord_ben_med_pln_no Secondary medical plan name. Column used for
 * external processing.
 * @param p_coord_ben_no_cvg_flag No secondary medical plan coverage. Column
 * used for external processing.
 * @param p_original_date_of_hire Original date of hire.
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
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then set to
 * null.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person. If p_validate is true,
 * then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person. If p_validate is true, then set
 * to null.
 * @param p_pdp_object_version_number If p_validate is false, this will be set
 * to the version number of the person created. If p_validate is true this
 * parameter will be set to null.
 * @param p_full_name If p_validate is false, then set to the complete full
 * name of the person. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created person comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_assignment_sequence If p_validate is false, then set to the
 * sequence number of the default assignment. If p_validate is true, then set
 * to null.
 * @param p_assignment_number If p_validate is false, then set to the
 * assignment number of the default assignment. If p_validate is true, then set
 * to null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @rep:displayname Create Contingent Worker
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cwk
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_npw_number                    in out nocopy varchar2
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_date_of_birth                 in     date     default null
  ,p_date_of_death                 in     date     default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default null
  ,p_email_address                 in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_party_id                      in     number   default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_projected_placement_end       in     date     default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_sex                           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_work_telephone                in     varchar2 default null
  ,p_exp_check_send_to_address     in     varchar2 default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_benefit_group_id              in     number   default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_original_date_of_hire         in     date     default null
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
  ,p_per_information_category      in     varchar2 default null
  -- p_per_information_category - Obsolete parameter, do not use
  ,p_per_information1              in     varchar2 default null
  ,p_per_information2              in     varchar2 default null
  ,p_per_information3              in     varchar2 default null
  ,p_per_information4              in     varchar2 default null
  ,p_per_information5              in     varchar2 default null
  ,p_per_information6              in     varchar2 default null
  ,p_per_information7              in     varchar2 default null
  ,p_per_information8              in     varchar2 default null
  ,p_per_information9              in     varchar2 default null
  ,p_per_information10             in     varchar2 default null
  ,p_per_information11             in     varchar2 default null
  ,p_per_information12             in     varchar2 default null
  ,p_per_information13             in     varchar2 default null
  ,p_per_information14             in     varchar2 default null
  ,p_per_information15             in     varchar2 default null
  ,p_per_information16             in       varchar2 default null
  ,p_per_information17             in       varchar2 default null
  ,p_per_information18             in       varchar2 default null
  ,p_per_information19             in       varchar2 default null
  ,p_per_information20             in       varchar2 default null
  ,p_per_information21             in       varchar2 default null
  ,p_per_information22             in       varchar2 default null
  ,p_per_information23             in       varchar2 default null
  ,p_per_information24             in       varchar2 default null
  ,p_per_information25             in       varchar2 default null
  ,p_per_information26             in       varchar2 default null
  ,p_per_information27             in       varchar2 default null
  ,p_per_information28             in       varchar2 default null
  ,p_per_information29             in       varchar2 default null
  ,p_per_information30             in       varchar2 default null
  ,p_person_id                        out nocopy   number
  ,p_per_object_version_number        out nocopy   number
  ,p_per_effective_start_date         out nocopy   date
  ,p_per_effective_end_date           out nocopy   date
  ,p_pdp_object_version_number        out nocopy   number
  ,p_full_name                        out nocopy   varchar2
  ,p_comment_id                       out nocopy   number
  ,p_assignment_id                    out nocopy   number
  ,p_asg_object_version_number        out nocopy   number
  ,p_assignment_sequence              out nocopy   number
  ,p_assignment_number                out nocopy   varchar2
  ,p_name_combination_warning         out nocopy   boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< convert_to_cwk >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API converts an existing person to a contingent worker.
 *
 * This API updates person details, creates a period of placement, and creates
 * a default contingent worker assignment. The process adds the contingent
 * worker to the security lists so that secure users can see the contingent
 * worker. If you do not specify a person_type_id, the API uses the default CWK
 * type for the business group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The period of placement and default contingent worker assignment are
 * created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not convert the person to a contingent worker and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Person whose record needs to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_npw_number The business group's contingent worker number generation
 * method determines when the API derives and passes out a contingent worker
 * number or when the calling program should pass in a value. When the API call
 * completes if p_validate is true then will be set to the contingent worker
 * number. If p_validate is true then will be set to the passed value.
 * @param p_projected_placement_end Obsolete parameter, do not use.
 * @param p_person_type_id Type of contingent worker being created.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_pdp_object_version_number If p_validate is false, this will be set
 * to the version number of the person created. If p_validate is true this
 * parameter will be set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_assignment_sequence If p_validate is false, then set to the
 * sequence number of the default assignment. If p_validate is true, then set
 * to null.
 * @rep:displayname Convert to Contingent Worker
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure convert_to_cwk
  (p_validate                      in     boolean default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_object_version_number         in out nocopy number
  ,p_npw_number                    in out nocopy varchar2
  ,p_projected_placement_end       in     date    default null
  ,p_person_type_id                in     number  default null
  ,p_datetrack_update_mode         in     varchar2
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_pdp_object_version_number        out nocopy   number
  ,p_assignment_id                    out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_assignment_sequence              out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< apply_for_job >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API converts an existing contingent worker to an applicant.
 *
 * The API updates person details, creates an application, and creates a
 * default applicant assignment. The process adds the applicant to the security
 * lists so that secure users can see the applicant. If you do not specify a
 * person_type_id, the API uses the default APL type for the business group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The application, default applicant assignment, and (if required) associated
 * assignment budget values and a letter request are created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not convert the person to an applicant and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Person whose record needs to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_applicant_number The business group's applicant number generation
 * method determines when the API derives and passes out an applicant number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is true then will be set to the applicant number. If
 * p_validate is true then will be set to the passed value.
 * @param p_person_type_id Type of applicant being created.
 * @param p_vacancy_id Vacancy for which this person has applied.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_application_id If p_validate is false, then this uniquely
 * identifies the application created. If p_validate is true, then set to null.
 * @param p_apl_object_version_number If p_validate is false, then set to the
 * version number of the created application. If p_validate is true, then set
 * to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_assignment_sequence If p_validate is false, then set to the
 * sequence number of the default assignment. If p_validate is true, then set
 * to null.
 * @rep:displayname Apply for Job
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure apply_for_job
  (p_validate                      in     boolean default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_object_version_number         in out nocopy number
  ,p_applicant_number              in out nocopy varchar2
  ,p_person_type_id                in     number  default null
  ,p_vacancy_id                    in     number  default null
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_application_id                   out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_assignment_sequence              out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< actual_termination_placement >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API covers the first step in terminating a period of placement and
--   all current assignments for a cwk, identified by person_id and date_start.
--
--   You can use the API to set the actual termination date, the last standard
--   process date, the new assignment status and the new person type.
--
--   Note: If you want to select only one current assignment to terminate you
--         should use the 'actual_termination_cwk_asg' API.
--
--   The new person type must have a corresponding system type of EX_CWK if
--   currently CWK.  If a type is not supplied, the API uses the default
--   person type for the business group. The new person_type takes affect on
--   the day after the actual termination date.
--
--   The new assignment status must have a corresponding system status of
--   TERM_CWK_ASG.  If a status is not supplied, the API uses the default
--   TERM_CWK_ASG status for the business group.  The new status applies to
--   all current assignments and takes effect on the day after the actual
--   termination date.
--
--   If you want to change the actual termination date after it has been
--   entered, you must cancel the termination and then reapply the termination
--   as of the new date.
--
--   If the leaving reason is set to 'Deceased' and the actual termination
--   date if not null then if the date of death on per_all_people_f is not
--   null it is updated to the actual termination date.
--
--   Element entries for the assignment that have an element
--   termination rule of 'Actual Termination' are date effectively
--   deleted as of the actual termination date.
--
--   Element entries for the assignment that have an element
--   termination rule of 'Final Close' are not modified by this API.
--   These entries are modified by the 'final_process_placement' API.
--
--   For a US legislation, the element termination rule of 'Last Standard
--   Process' is not used.  You must set the p_last_standard_process_date
--   parameter to null.
--
--   For non-US legislations, element entries for the
--   assignment that have an element termination rule of 'Last Standard
--   Process' are date effectively deleted using the value specified
--   by p_last_standard_process_date.  If no value is specified
--   the API defaults the date according to the following rules:
--         If no assignments include a payroll, the entries are deleted as
--         of the actual termination date.
--         If one assignment includes a payroll, the entries are deleted
--         as of the end date of the payroll period in which the actual
--         termination date occurs.
--         If there is more than one assignment that includes a payroll then
--         the latest period end date is used for all assignments.
--
--   The person is added to the security lists so that they will be visible as
--   an ex-contingent worker.
--
-- Prerequisites:
--   The period of placement record, identified by p_person_id, p_date_start
--   and p_object_version_number, must exist and must have a blank
--   actual termination date.
--   There must be no date-effective changes to the Person record after the
--   actual_termination_date.
--   There must be no employee assignments in this period of placement with an
--   initial start date on or after the actual_termination_date.
--   For a US legislation the last standard process date must be null.
--   For non-US legislations the last standard process date must be on or
--   after the actual termination date.
--   The person type, p_person_type_id, must exist for the same business group
--   as the person, must be active and must have a system type of EX_CWK.
--   The assignment status, p_assignment_status_type_id, must exist for
--   the same business group as the person, must be active and must have a
--   system status of TERM_CWK_ASG.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged.  If false
--                                                then the period of placement,
--                                                person, assignment and
--                                                element entries are
--                                                updated.
--   p_person_id                    Yes  number   ID of the person.
--   p_date_start                   Yes  date     Date placement started.
--   p_object_version_number        Yes  number   Version number of the
--                                                period of placement.
--   p_actual_termination_date      Yes  date     Actual termination date
--   p_last_standard_process_date   No   date     Last standard process date
--   p_person_type_id               No   number   Person type
--   p_assignment_status_type_id    No   number   Assignment status
--
-- Post Success:
--   The API updates the period of placement, modifies the person, assignments,
--   element entries and sets the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the new version number of the
--                                           updated period of placement record.
--                                           If p_validate is true, set to the
--                                           same value you passed in.
--   p_last_standard_process_date   date     If p_validate is false, set to
--                                           the derived last standard process
--                                           date.  If p_validate is true, set
--                                           to the same value you passed in.
--   p_supervisor_warning           boolean  Set to true if this person is a
--                                           supervisor for another assignment,
--                                           currently or in the future.
--                                           Set to false if this person is not
--                                           a supervisor now or in the future.
--   p_event_warning                boolean  Set to true if this person is
--                                           booked on at least one event in
--                                           the past, present or future.  Set
--                                           to false if this person is not
--                                           booked on any events.
--   p_interview_warning            boolean  Set to true if this person is
--                                           scheduled to be an interviewer or
--                                           has interviews booked in the past,
--                                           present or future.  Set to false
--                                           if this person does not have any
--                                           interviewer or interview sessions.
--   p_review_warning               boolean  Set to true if this person has a
--                                           review scheduled.  Set to false if
--                                           there are no reviews scheduled.
--   p_recruiter_warning            boolean  Set to true if this person is a
--                                           recruiter for a vacancy in the past,
--                                           future or present.  Set to false
--                                           if this person is not a recruiter.
--   p_asg_future_changes_warning   boolean  Set to true if at least one
--                                           assignment change, after the
--                                           actual termination date, has been
--                                           overwritten with the new
--                                           assignment status.  Set to
--                                           false when there are no changes
--                                           in the future.
--   p_entries_changed_warning      varchar2 Set to 'Y' when at least one
--                                           element entry is affected by
--                                           the assignment change.
--                                           Set to 'S' if at least one salary
--                                           element entry is affected.  (This
--                                           (is a more specific case than
--                                           'Y'.) Otherwise set to 'N', when
--                                           no element entries are affected.
--   p_pay_proposal_warning         varchar2 Set to 'Y' when at least one
--                                           pay proposal existing after the
--                                           actual termination date was
--                                           deleted. Otherwise set to 'N' when
--                                           no pay proposals were deleted.
--   p_dod_warning                  boolean  Set to TRUE when the date of death
--                                           is set upon terminating a cwk.
--
-- Post Failure:
--   The API does not update the period of placement, person, assignments, or
--   element entries and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure actual_termination_placement
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_date_start                    in     date
  ,p_object_version_number         in out nocopy number
  ,p_actual_termination_date       in     date
  ,p_last_standard_process_date    in out nocopy date
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_termination_reason            in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< final_process_placement >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API covers the second step in terminating a period of placement and
--   all current assignments for an cwk.  It updates the period of placement
--   details and date-effectively deletes all the contingent worker assignments
--   as of the final process date.
--
--   Note: If you want to select only one current assignment to terminate you
--         should use the 'final_process_cwk_asg' API.
--
--   If a final process date is not specified, the API derived the value.
--   For a US legislation, it uses the actual termination date.
--   For non-US legislations, it uses the last standard process date.
--
--   If you want to change the final process date after it has been
--   entered, you must cancel the termination and then reapply the termination
--   as of the new date.
--
--   Element entries for any assignment that have an element termination rule of
--   'Final Close' are date effectively deleted as of the final process
--   date.
--
--   Cost allocations, grade step/point placements, cobra coverage benefits
--   and personal payment methods for all assignments are date effectively
--   deleted as of the final process date.
--
--   The person is added to the security lists so that they will be visible as
--   an ex-cwk.
--
-- Prerequisites:
--   The period of placement record, identified by p_person_id, p_date_start
--   and p_object_version_number, must exist and must have an actual
--   termination date and a blank final process date.
--   The final process date must not be earlier than the actual termination
--   date.
--   For a US legislation there must be no COBRA coverage benefits after
--   the final process date.
--   For non-US legislations the final process date must not be earlier than
--   the last standard process date.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the period of service,
--                                                assignments and element
--                                                entries will be changed.
--   p_person_id                    Yes  number   ID of the person.
--   p_date_start                   Yes  number   Start date of the placement.
--   p_object_version_number        Yes  number   Version number of the
--                                                period of placement
--   p_final_process_date           No   date     Final Process Date
--
-- Post Success:
--   The API will update the period of placement, modify the assignments,
--   element entries and set the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the new version number of the
--                                           updated period of placement record.
--                                           If p_validate is true, set to the
--                                           same value you passed in.
--   p_final_process_date           date     If p_validate is false, set to
--                                           the value passed in or the derived
--                                           date. If p_validate is true, set
--                                           to the value passed in.
--   p_org_now_no_manager_warning   boolean  Set to true if this assignment
--                                           had the manager flag set to 'Y'
--                                           and there are no other managers
--                                           in the assignment's organization.
--                                           Set to false if there is another
--                                           manager in the assignment's
--                                           organization or if this assignment
--                                           did not have the manager flag set
--                                           to 'Y'.
--                                           The warning value only applies as
--                                           of the final process date.
--   p_asg_future_changes_warning   boolean  Set to true if at least one
--                                           assignment change, after the final
--                                           process date, has been deleted
--                                           as a result of terminating the
--                                           employee. (The only change
--                                           that can be made after the
--                                           actual termination date is to
--                                           set the assignment status to another
--                                           TERM_CWK_ASG status.) Set to false
--                                           when there were no changes after
--                                           final process date.
--   p_entries_changed_warning      varchar2 Set to 'Y' when at least one
--                                           element entry is affected by
--                                           the assignment change.
--                                           Set to 'S' if at least one salary
--                                           element entry is affected. (This
--                                           (is a more specific case than
--                                           'Y'.) Otherwise set to 'N', when
--                                           no element entries are affected.
--
-- Post Failure:
--   The API does not update the period of placement, assignments or element
--   entries and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure final_process_placement
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_date_start                    in     date
  ,p_object_version_number         in out nocopy number
  ,p_final_process_date            in out nocopy date
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< terminate_placement >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API terminates a contingent worker.
 *
 * This API converts a person of type Contingent Worker to a person of type
 * Ex-Contigent Worker. The person's period of placement and any contingent
 * worker assignments are ended.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contingent worker must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The contingent worker is terminated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The contigent worker is not terminated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Person who is being terminated.
 * @param p_date_start Start date.
 * @param p_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_person_type_id Type of contingent worker being terminated.
 * @param p_assignment_status_type_id Status of a contingent worker in a
 * specific assignment.
 * @param p_actual_termination_date Actual termination date.
 * @param p_final_process_date Obsolete parameter, do not use.
 * @param p_last_standard_process_date Obsolete parameter, do not use.
 * @param p_termination_reason Termination Reason. Valid values are defined by
 * the HR_CWK_TERMINATION_REASONS lookup type.
 * @param p_projected_termination_date Projected termination date.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_supervisor_warning If set to true, then this person is a supervisor
 * for another, current or future assignment.
 * @param p_event_warning If set to true, then this person is booked on at
 * least one event in the past, present or future.
 * @param p_interview_warning If set to true, then this person is scheduled to
 * be an interviewer or has interviews booked in the past, present or future.
 * @param p_review_warning If set to true, then this person has a review
 * scheduled.
 * @param p_recruiter_warning If set to true, then this person is a recruiter
 * for a vacancy in the past, future or present.
 * @param p_asg_future_changes_warning If set to true, then at least one
 * assignment change, after the actual termination date, has been overwritten
 * with the new assignment status.
 * @param p_entries_changed_warning Set to Y when at least one element entry is
 * affected by the assignment change. Set to S if at least one salary element
 * entry is affected. Otherwise, set to N.
 * @param p_pay_proposal_warning If set to true, then there is at least one pay
 * proposal existing after the actual termination date of this assignment.
 * @param p_dod_warning If set to true, then the date of death has been set on
 * terminating the person.
 * @param p_org_now_no_manager_warning If set to true, then from the final
 * process date of this assignment there are no other managers in the
 * assignment's organization.
 * @param p_addl_rights_warning If set to true, it indicates that this person
 * has additional rights due to their supplementary roles.
 * @rep:displayname Terminate Placement
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure terminate_placement
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_date_start                    in     date
  ,p_object_version_number         in out nocopy number
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_actual_termination_date       in     date     default hr_api.g_date

/*
   The following two parameters are available for internal-use only until
   payroll support for contingent workers is introduced. Setting them has
   no impact.
*/
  ,p_final_process_date            in out nocopy date
  ,p_last_standard_process_date    in out nocopy date

  ,p_termination_reason            in     varchar2 default hr_api.g_varchar2
  ,p_projected_termination_date    in     date     default hr_api.g_date
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_addl_rights_warning              out nocopy boolean -- Fix 1370960
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< reverse_terminate_placement >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API reverses a contingent worker termination.
 *
 * This API removes the end date from the period of placement and the
 * contingent worker assignments, and reverts the person type to Contingent
 * Worker.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The API updates the period of placement, modifies the person, assignments,
 * and element entries, and reverses any other termination actions.
 *
 * <p><b>Post Failure</b><br>
 * The API does not reverse the termination and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Person whose record needs to be modified.
 * @param p_actual_termination_date Actual termination date.
 * @param p_clear_details Flag indicating whether the details can be cleared.
 * @param p_fut_actns_exist_warning If set to true, then this person has future
 * payroll actions.
 * @rep:displayname Reverse Termination Placement
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure reverse_terminate_placement
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_actual_termination_date       in     date
  ,p_clear_details                 in     varchar2 default 'N'
  ,p_fut_actns_exist_warning       out nocopy    boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Get_Length_of_Placement >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This routine can be called to get the length of a contingent worker's
--   placement.  The person_id and date_start (user key) are passed in
--   and the total length of placement in years and months is returned.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Session date.
--   p_business_group_id            Yes  number   ID of the Business Group.
--   p_person_id                    Yes  number   ID of the person.
--   p_date_start                   Yes  number   Date the placement started.
--   p_object_version_number        Yes  number   Version number of the
--                                                period of placement
--
-- Post Success:
--   This procedure returns the total length of the placement.
--
--   Name                           Type     Description
--   p_total_years                  number   Total length of placement in
--                                           years.
--   p_total_months                 number   Total length of placement in
--                                           months.
--
-- Post Failure:
--   The placement could not be found so an error is raised.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure get_length_of_placement
  (p_effective_date     in    date
  ,p_business_group_id  in    number
  ,p_person_id          in    number
  ,p_date_start         in    date
  ,p_total_years        out nocopy   number
  ,p_total_months       out nocopy   number);
--
end hr_contingent_worker_api;

/
