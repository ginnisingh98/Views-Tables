--------------------------------------------------------
--  DDL for Package HR_NO_QUALIFICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NO_QUALIFICATION_API" AUTHID CURRENT_USER AS
/* $Header: pequanoi.pkh 120.1 2005/10/02 02:44 aroussel $ */
/*#
 * This package contains Qualification APIs for Norway.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Qualification APIs for Norway.
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_no_qualification >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure creates a qualification for Norway.
 *
 * This API is provided to allow creation of new qualifications for a person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist. The qualification type must exist.
 *
 * <p><b>Post Success</b><br>
 * A new qualification will be sucessfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a qualification for the employee and raises an
 * error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_qualification_type_id The type of qualification.Valid values are
 * defined by 'PER_QUALIFICATION_TYPES' lookup type.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_business_group_id The business group the person.
 * @param p_person_id Identifies the person for whom you create the
 * qualification record.
 * @param p_title Title of the qualification.
 * @param p_grade_attained Level of qualification.
 * @param p_status Status of the qualification. Status of the
 * qualification.Valid values are defined by 'PER_SUBJECT_STATUSES' lookup
 * type.
 * @param p_awarded_date Date qualification awarded.
 * @param p_fee Cost of qualification.
 * @param p_fee_currency Currency fee paid in.
 * @param p_training_completed_amount Amount of training completed.
 * @param p_reimbursement_arrangements Details of arrangements.
 * @param p_training_completed_units Holds the unit of training.
 * @param p_total_training_amount Number of training units.
 * @param p_start_date Start date of training.
 * @param p_end_date End date of training.
 * @param p_license_number Number of license.
 * @param p_expiry_date Date license expires.
 * @param p_license_restrictions Licence restrictions.
 * @param p_projected_completion_date Projected completion date.
 * @param p_awarding_body Awarding body.
 * @param p_tuition_method Method of tuition.Valid values are defined by
 * 'PER_TUITION_METHODS' lookup type.
 * @param p_group_ranking Ranking within study group.
 * @param p_comments Comment text.
 * @param p_attendance_id Attendance id for the qualification.
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
 * @param p_party_id Party identifier.
 * @param p_nus2000_code NUS-2000 Code.
 * @param p_highest_level Highest Level. Preferred level.Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_grade_point_avg Grade point average.
 * @param p_no_of_credits Number of credits.
 * @param p_professional_body_name Professional body name.
 * @param p_membership_number Membership number.
 * @param p_membership_category Membership category.
 * @param p_subscription_payment_method Payment method.
 * @param p_qualification_id PK of PER_QUALIFICATIONS
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created qualification. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Qualification for Norway.
 * @rep:category BUSINESS_ENTITY PER_QUALIFICATION
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_NO_QUALIFICATION
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_qualification_type_id         in     number
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_business_group_id             in     number   default null
  ,p_person_id                     in     number   default null
  ,p_title                         in     varchar2 default null
  ,p_grade_attained                in     varchar2 default null
  ,p_status                        in     varchar2 default null
  ,p_awarded_date                  in     date     default null
  ,p_fee                           in     number   default null
  ,p_fee_currency                  in     varchar2 default null
  ,p_training_completed_amount     in     number   default null
  ,p_reimbursement_arrangements    in     varchar2 default null
  ,p_training_completed_units      in     varchar2 default null
  ,p_total_training_amount         in     number   default null
  ,p_start_date                    in     date     default null
  ,p_end_date                      in     date     default null
  ,p_license_number                in     varchar2 default null
  ,p_expiry_date                   in     date     default null
  ,p_license_restrictions          in     varchar2 default null
  ,p_projected_completion_date     in     date     default null
  ,p_awarding_body                 in     varchar2 default null
  ,p_tuition_method                in     varchar2 default null
  ,p_group_ranking                 in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_attendance_id                 in     number   default null
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
  ,p_party_id                      in     number   default null
  ,p_nus2000_code                  in     varchar2 default null
  ,p_highest_level                 in     varchar2 default null
  ,p_grade_point_avg               in     varchar2 default null
  ,p_no_of_credits                 in     varchar2 default null
  ,p_professional_body_name        in     varchar2 default null
  ,p_membership_number             in     varchar2 default null
  ,p_membership_category           in     varchar2 default null
  ,p_subscription_payment_method   in     varchar2 default null
  ,p_qualification_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_no_qualification >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure updates a qualification for Norway identified by
 * qualification_id.
 *
 * This API is provided to allow the details relating to a qualification for a
 * person to be updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must be created. The qualification_type_id must exist in
 * PER_QUALIFICATION_TYPES. The qualification_id must exist in
 * PER_QUALIFICATIONS.
 *
 * <p><b>Post Success</b><br>
 * The qualification will be sucessfully inserted and the out parameter
 * p_object_version_number will be set.
 *
 * <p><b>Post Failure</b><br>
 * The API does not increment the OVN, the details relating to the
 * qualification remain unchanged, and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_qualification_id PK of PER_QUALIFICATIONS
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_qualification_type_id The type of qualification.Valid values are
 * defined by 'PER_QUALIFICATION_TYPES' lookup type.
 * @param p_title Title of the qualification.
 * @param p_grade_attained Level of qualification.
 * @param p_status Status of the qualification.Valid values are defined by
 * 'PER_SUBJECT_STATUSES' lookup type.
 * @param p_awarded_date Date qualification awarded.
 * @param p_fee Cost of qualification.
 * @param p_fee_currency Currency fee paid in.
 * @param p_training_completed_amount Amount of training completed.
 * @param p_reimbursement_arrangements Details of arrangements.
 * @param p_training_completed_units Holds the unit of training.
 * @param p_total_training_amount Number of training units.
 * @param p_start_date Start date of training.
 * @param p_end_date End date of training.
 * @param p_license_number Number of license.
 * @param p_expiry_date Date license expires.
 * @param p_license_restrictions Licence restrictions.
 * @param p_projected_completion_date Projected completion date.
 * @param p_awarding_body Awarding body.
 * @param p_tuition_method Method of tuition.Valid values are defined by
 * 'PER_TUITION_METHODS' lookup type.
 * @param p_group_ranking Ranking within study group.
 * @param p_comments Comment text.
 * @param p_attendance_id Attendance id.Valid values are defined by
 * 'PER_ESTABLISHMENT_ATTENDANCES' lookup type.
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
 * @param p_nus2000_code NUS-2000 Code.
 * @param p_highest_level Highest Level.Preferred level.Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_grade_point_avg Grade Point Average.
 * @param p_no_of_credits Number of Credits.
 * @param p_professional_body_name Professional body name.
 * @param p_membership_number Membership number.
 * @param p_membership_category Membership category.
 * @param p_subscription_payment_method Payment method.
 * @param p_object_version_number Pass in the current version number of the
 * qualification to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated qualification. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update qualification for Norway.
 * @rep:category BUSINESS_ENTITY PER_QUALIFICATION
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_NO_QUALIFICATION
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_qualification_id              in     number
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_qualification_type_id         in     number   default hr_api.g_number
  ,p_title                         in     varchar2 default hr_api.g_varchar2
  ,p_grade_attained                in     varchar2 default hr_api.g_varchar2
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_awarded_date                  in     date     default hr_api.g_date
  ,p_fee                           in     number   default hr_api.g_number
  ,p_fee_currency                  in     varchar2 default hr_api.g_varchar2
  ,p_training_completed_amount     in     number   default hr_api.g_number
  ,p_reimbursement_arrangements    in     varchar2 default hr_api.g_varchar2
  ,p_training_completed_units      in     varchar2 default hr_api.g_varchar2
  ,p_total_training_amount         in     number   default hr_api.g_number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_license_number                in     varchar2 default hr_api.g_varchar2
  ,p_expiry_date                   in     date     default hr_api.g_date
  ,p_license_restrictions          in     varchar2 default hr_api.g_varchar2
  ,p_projected_completion_date     in     date     default hr_api.g_date
  ,p_awarding_body                 in     varchar2 default hr_api.g_varchar2
  ,p_tuition_method                in     varchar2 default hr_api.g_varchar2
  ,p_group_ranking                 in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_attendance_id                 in     number   default hr_api.g_number
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
  ,p_nus2000_code                  in     varchar2 default hr_api.g_varchar2
  ,p_highest_level                 in     varchar2 default hr_api.g_varchar2
  ,p_grade_point_avg               in     varchar2 default hr_api.g_varchar2
  ,p_no_of_credits                 in     varchar2 default hr_api.g_varchar2
  ,p_professional_body_name        in     varchar2 default hr_api.g_varchar2
  ,p_membership_number             in     varchar2 default hr_api.g_varchar2
  ,p_membership_category           in     varchar2 default hr_api.g_varchar2
  ,p_subscription_payment_method   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );

END HR_NO_QUALIFICATION_API;

 

/
