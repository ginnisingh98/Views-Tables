--------------------------------------------------------
--  DDL for Package PER_QUALIFICATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUALIFICATIONS_API" AUTHID CURRENT_USER as
/* $Header: pequaapi.pkh 120.1.12010000.3 2009/03/12 11:30:11 dparthas ship $ */
/*#
 * This package contains Qualification APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Qualification
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_qualification >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates qualification.
 *
 * A qualification is a record of an educational qualification, certificates,
 * licenses, etc that a person holds or is acquiring.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Person for whom the qualification is being created must exist. A valid
 * QUALIFICATION_TYPE must exist.
 *
 * <p><b>Post Success</b><br>
 * Qualification record is created.
 *
 * <p><b>Post Failure</b><br>
 * Qualification is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_qualification_type_id Identifies the qualification type.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_business_group_id Identifies the business group of the person
 * @param p_person_id Identifies the person who holds the qualification.
 * @param p_title Title (name) of the qualification.
 * @param p_grade_attained Grade attained for the qualification.
 * @param p_status Status of this qualification. Valid values are defined by
 * PER_SUBJECT_STATUSES lookup type.
 * @param p_awarded_date Date qualification awarded
 * @param p_fee Cost of qualification (tuition fee).
 * @param p_fee_currency Currency in which fee is paid.
 * @param p_training_completed_amount Amount of training completed
 * @param p_reimbursement_arrangements Reimbursement condition information.
 * @param p_training_completed_units Holds the current unit of training
 * @param p_total_training_amount Total number of training units
 * @param p_start_date Start date of training
 * @param p_end_date End date of training
 * @param p_license_number Number of license
 * @param p_expiry_date Date license expires
 * @param p_license_restrictions License restrictions
 * @param p_projected_completion_date Projected completion date of
 * qualification.
 * @param p_awarding_body Awarding body.
 * @param p_tuition_method Method of tuition. Valid values are defined by
 * PER_TUITION_METHODS lookup type.
 * @param p_group_ranking Ranking within study group
 * @param p_comments Comment text.
 * @param p_attendance_id Identifies the attendance record for this
 * qualification.
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
 * @param p_party_id Identifies the Party associated with this qualification.
 * @param p_qua_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield segments
 * @param p_qua_information1 Developer Descriptive flexfield segment.
 * @param p_qua_information2 Developer Descriptive flexfield segment.
 * @param p_qua_information3 Developer Descriptive flexfield segment.
 * @param p_qua_information4 Developer Descriptive flexfield segment.
 * @param p_qua_information5 Developer Descriptive flexfield segment.
 * @param p_qua_information6 Developer Descriptive flexfield segment.
 * @param p_qua_information7 Developer Descriptive flexfield segment.
 * @param p_qua_information8 Developer Descriptive flexfield segment.
 * @param p_qua_information9 Developer Descriptive flexfield segment.
 * @param p_qua_information10 Developer Descriptive flexfield segment.
 * @param p_qua_information11 Developer Descriptive flexfield segment.
 * @param p_qua_information12 Developer Descriptive flexfield segment.
 * @param p_qua_information13 Developer Descriptive flexfield segment.
 * @param p_qua_information14 Developer Descriptive flexfield segment.
 * @param p_qua_information15 Developer Descriptive flexfield segment.
 * @param p_qua_information16 Developer Descriptive flexfield segment.
 * @param p_qua_information17 Developer Descriptive flexfield segment.
 * @param p_qua_information18 Developer Descriptive flexfield segment.
 * @param p_qua_information19 Developer Descriptive flexfield segment.
 * @param p_qua_information20 Developer Descriptive flexfield segment.
 * @param p_professional_body_name Name of professional body associated with
 * this qualification.
 * @param p_membership_number Membership number for professional body
 * associated with this qualification.
 * @param p_membership_category Membership category of the professional body
 * which is associated with this qualification.
 * @param p_subscription_payment_method Method of payment of subscription
 * charge for professional body belonged to this qualification.
 * @param p_qualification_id If p_validate is false, then this uniquely
 * identifies the qualification created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created qualification. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Qualification
 * @rep:category BUSINESS_ENTITY PER_QUALIFICATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_QUALIFICATION
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
  ,p_qua_information_category      in     varchar2 default null
  ,p_qua_information1              in     varchar2 default null
  ,p_qua_information2              in     varchar2 default null
  ,p_qua_information3              in     varchar2 default null
  ,p_qua_information4              in     varchar2 default null
  ,p_qua_information5              in     varchar2 default null
  ,p_qua_information6              in     varchar2 default null
  ,p_qua_information7              in     varchar2 default null
  ,p_qua_information8              in     varchar2 default null
  ,p_qua_information9              in     varchar2 default null
  ,p_qua_information10             in     varchar2 default null
  ,p_qua_information11             in     varchar2 default null
  ,p_qua_information12             in     varchar2 default null
  ,p_qua_information13             in     varchar2 default null
  ,p_qua_information14             in     varchar2 default null
  ,p_qua_information15             in     varchar2 default null
  ,p_qua_information16             in     varchar2 default null
  ,p_qua_information17             in     varchar2 default null
  ,p_qua_information18             in     varchar2 default null
  ,p_qua_information19             in     varchar2 default null
  ,p_qua_information20             in     varchar2 default null
  ,p_professional_body_name        in     varchar2 default null
  ,p_membership_number             in     varchar2 default null
  ,p_membership_category           in     varchar2 default null
  ,p_subscription_payment_method   in     varchar2 default null
  ,p_qualification_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_qualification >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates qualification.
 *
 * A qualification is a record of educational qualification, certificates,
 * licenses, etc that a person holds or is acquiring.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment and Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must be created and have a type of 'EMPLOYEE', the
 * QUALIFICATION_TYPE_ID must exist in PER_QUALIFICATION_TYPES and the
 * QUALIFICATION_ID must exist in PER_QUALIFICATIONS.
 *
 * <p><b>Post Success</b><br>
 * Qualification is updated.
 *
 * <p><b>Post Failure</b><br>
 * Qualification is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_qualification_id Identifies the qualification record to be updated.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_qualification_type_id Identifies the qualification type.
 * @param p_title Title (name) of the qualification.
 * @param p_grade_attained Grade attained for the qualification.
 * @param p_status Status of this qualification. Valid values are defined by
 * PER_SUBJECT_STATUSES lookup type.
 * @param p_awarded_date Date qualification awarded
 * @param p_fee Cost of qualification (tuition fee).
 * @param p_fee_currency Currency in which fee is paid.
 * @param p_training_completed_amount Amount of training completed
 * @param p_reimbursement_arrangements Reimbursement condition information.
 * @param p_training_completed_units Holds the current unit of training
 * @param p_total_training_amount Total number of training units
 * @param p_start_date Start date of training
 * @param p_end_date End date of training
 * @param p_license_number Number of license
 * @param p_expiry_date Date license expires
 * @param p_license_restrictions License restrictions
 * @param p_projected_completion_date Projected completion date of
 * qualification.
 * @param p_awarding_body Awarding body
 * @param p_tuition_method Method of tuition. Valid values are defined by
 * PER_TUITION_METHODS lookup type.
 * @param p_group_ranking Ranking within study group
 * @param p_comments Comment text.
 * @param p_attendance_id Identifies the attendance record for this
 * qualification.
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
 * @param p_qua_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield segments
 * @param p_qua_information1 Developer Descriptive flexfield segment.
 * @param p_qua_information2 Developer Descriptive flexfield segment.
 * @param p_qua_information3 Developer Descriptive flexfield segment.
 * @param p_qua_information4 Developer Descriptive flexfield segment.
 * @param p_qua_information5 Developer Descriptive flexfield segment.
 * @param p_qua_information6 Developer Descriptive flexfield segment.
 * @param p_qua_information7 Developer Descriptive flexfield segment.
 * @param p_qua_information8 Developer Descriptive flexfield segment.
 * @param p_qua_information9 Developer Descriptive flexfield segment.
 * @param p_qua_information10 Developer Descriptive flexfield segment.
 * @param p_qua_information11 Developer Descriptive flexfield segment.
 * @param p_qua_information12 Developer Descriptive flexfield segment.
 * @param p_qua_information13 Developer Descriptive flexfield segment.
 * @param p_qua_information14 Developer Descriptive flexfield segment.
 * @param p_qua_information15 Developer Descriptive flexfield segment.
 * @param p_qua_information16 Developer Descriptive flexfield segment.
 * @param p_qua_information17 Developer Descriptive flexfield segment.
 * @param p_qua_information18 Developer Descriptive flexfield segment.
 * @param p_qua_information19 Developer Descriptive flexfield segment.
 * @param p_qua_information20 Developer Descriptive flexfield segment.
 * @param p_professional_body_name Name of professional body associated with
 * this qualification.
 * @param p_membership_number Membership number for professional body
 * associated with this qualification.
 * @param p_membership_category Category of membership for the professional
 * body associated with this qualification.
 * @param p_subscription_payment_method Method of payment of subscription
 * charge for professional body associated with this qualification.
 * @param p_object_version_number Pass in the current version number of the
 * qualification to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated qualification. If
 * p_validate is true will be set to the same value which was passed in
 * @rep:displayname Update Qualification
 * @rep:category BUSINESS_ENTITY PER_QUALIFICATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_QUALIFICATION
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
  ,p_qua_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_qua_information1              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information2              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information3              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information4              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information5              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information6              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information7              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information8              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information9              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information10             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information11             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information12             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information13             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information14             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information15             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information16             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information17             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information18             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information19             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information20             in     varchar2 default hr_api.g_varchar2
  ,p_professional_body_name        in     varchar2 default hr_api.g_varchar2
  ,p_membership_number             in     varchar2 default hr_api.g_varchar2
  ,p_membership_category           in     varchar2 default hr_api.g_varchar2
  ,p_subscription_payment_method   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_qualification >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes qualification.
 *
 * A qualification is a record of educational qualification, certificates,
 * licenses, etc that a person holds or is acquiring.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment and Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The qualification to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The record will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The record will not be deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_qualification_id Identifies the qualification to be deleted.
 * @param p_object_version_number Current version number of the qualification
 * to be deleted.
 * @rep:displayname Delete Qualification
 * @rep:category BUSINESS_ENTITY PER_QUALIFICATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_QUALIFICATION
  (p_validate                      in     boolean  default false
  ,p_qualification_id              in     number
  ,p_object_version_number         in     number
  );


end PER_QUALIFICATIONS_API;

/
