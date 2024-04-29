--------------------------------------------------------
--  DDL for Package OTA_CERTIFICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERTIFICATION_API" AUTHID CURRENT_USER as
/* $Header: otcrtapi.pkh 120.5 2006/07/14 09:29:45 niarora noship $ */
/*#
 * This package contains learning certification APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Learning Certification
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_certification >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a learning certification.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Business group record must exist.
 *
 * <p><b>Post Success</b><br>
 * The learning certification is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create learning certification record, and raises an error.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_name The name of the learning certification.
 * @param p_business_group_id The business group for the certification.
 * @param p_public_flag This flag determines that no learner access is defined and
 * grants access to all learners within a business group.
 * @param p_initial_completion_date The initial date by which learners must complete the learning certification.
 * @param p_initial_completion_duration The initial duration provided to learners to complete
 * the learning certification.
 * @param p_initial_compl_duration_units The duration units for initial completion duration.
 * @param p_renewal_duration The renewal duration provided to learners to re-certify the learning certification.
 * @param p_renewal_duration_units The duration units for renewal duration.
 * @param p_notify_days_before_expire Learners are notified this number of days before
 * certification initial completion/expiration.
 * @param p_start_date_active Learning certification active start date.
 * @param p_end_date_active Learning certification active end date. After this date the object is not active anymore.
 * @param p_description The description for learning certification.
 * @param p_objectives The objectives for learning certification.
 * @param p_purpose The purpose of the learning certification.
 * @param p_keywords The keywords for learning certification.
 * @param p_end_date_comments The comments for end date field.
 * @param p_initial_period_comments The comments for initial completion.
 * @param p_renewal_period_comments The comments for renewal completion.
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
 * @param p_validity_duration The duration certification would be valid once completed.
 * @param p_validity_duration_units The units for validity duration.
 * @param p_renewable_flag The flag to determine certification as renewable.
 * @param p_validity_start_type The flag to determine validity start.
 * @param p_competency_update_level The flag to detemine competency updation.
 * @param p_certification_id The unique identifier for the learning certification record.
 * @param p_object_version_number If p_validate is false, then set to the version number
 * of the created learning certification. If p_validate is true, then the value will be null.
 * @rep:displayname Create Learning Certification
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_certification
  (p_effective_date                 in     date
  ,p_validate                       in     boolean   default false
  ,p_name                           in     varchar2
  ,p_business_group_id              in     number
  ,p_public_flag                    in     varchar2 default 'Y'
  ,p_initial_completion_date        in     date     default null
  ,p_initial_completion_duration    in     number   default null
  ,p_initial_compl_duration_units   in     varchar2 default null
  ,p_renewal_duration               in     number   default null
  ,p_renewal_duration_units         in     varchar2 default null
  ,p_notify_days_before_expire      in     number   default null
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
  ,p_description                    in     varchar2 default null
  ,p_objectives                     in     varchar2 default null
  ,p_purpose                        in     varchar2 default null
  ,p_keywords                       in     varchar2 default null
  ,p_end_date_comments              in     varchar2 default null
  ,p_initial_period_comments        in     varchar2 default null
  ,p_renewal_period_comments        in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_VALIDITY_DURATION              in     NUMBER   default null
  ,p_VALIDITY_DURATION_UNITS        in     VARCHAR2 default null
  ,p_RENEWABLE_FLAG                 in     VARCHAR2 default null
  ,p_VALIDITY_START_TYPE            in     VARCHAR2 default null
  ,p_COMPETENCY_UPDATE_LEVEL        in     VARCHAR2 default null
  ,p_certification_id                  out nocopy number
  ,p_object_version_number             out nocopy number
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_certification >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the certification.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The certification record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The certification is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the certification record, and raises an error.
 *
 * @param p_effective_date Reference date for validating lookup values are applicable
 * during the start to end active date range. This date does not determine when
 * the changes take effect.
 * @param p_certification_id The unique identifier for the learning certification record.
 * @param p_object_version_number Pass in the current version number of the Certification to
 * be updated. When the API completes if p_validate is false, will be set to the new
 * version number of the updated Certification. If p_validate is true will be set
 * to the same value which was passed in.
 * @param p_name The name of the learning certification.
 * @param p_public_flag This flag determines that no learner access is defined and grants
 * access to all learners within a business group.
 * @param p_initial_completion_date The initial date by which learners must complete the learning certification.
 * @param p_initial_completion_duration The initial duration provided to learners to complete the learning certification.
 * @param p_initial_compl_duration_units The duration units for initial completion duration.
 * @param p_renewal_duration The renewal duration provided to learners to re-certify the learning certification.
 * @param p_renewal_duration_units The duration units for renewal duration.
 * @param p_notify_days_before_expire Learners are notified this number of days before
 * certification initial completion/expiration.
 * @param p_start_date_active Learning certification active start date.
 * @param p_end_date_active Learning certification active end date. After this date the object is not active anymore.
 * @param p_description The description for learning certification.
 * @param p_objectives The objectives for learning certification.
 * @param p_purpose The purpose of the learning certification.
 * @param p_keywords The keywords for learning certification.
 * @param p_end_date_comments The comments for end date field.
 * @param p_initial_period_comments The comments for initial completion.
 * @param p_renewal_period_comments The comments for renewal completion.
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
 * @param p_business_group_id The business group for the certification record.
 * @param p_validity_duration The duration certification would be valid once completed.
 * @param p_validity_duration_units The units for validity duration.
 * @param p_renewable_flag The flag to determine certification as renewable.
 * @param p_validity_start_type The flag to determine validity start.
 * @param p_competency_update_level The flag to detemine competency updation.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Update Learning Certification
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_certification
  (p_effective_date                 in     date
  ,p_certification_id               in     number
  ,p_object_version_number          in out nocopy number
  ,p_name                           in     varchar2  default hr_api.g_varchar2
  ,p_public_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_initial_completion_date        in     date      default hr_api.g_date
  ,p_initial_completion_duration    in     number    default hr_api.g_number
  ,p_initial_compl_duration_units   in     varchar2  default hr_api.g_varchar2
  ,p_renewal_duration               in     number    default  hr_api.g_number
  ,p_renewal_duration_units         in     varchar2  default hr_api.g_varchar2
  ,p_notify_days_before_expire      in     number    default hr_api.g_number
  ,p_start_date_active              in     date      default hr_api.g_date
  ,p_end_date_active                in     date      default hr_api.g_date
  ,p_description                    in     varchar2  default hr_api.g_varchar2
  ,p_objectives                     in     varchar2  default hr_api.g_varchar2
  ,p_purpose                        in     varchar2  default hr_api.g_varchar2
  ,p_keywords                       in     varchar2  default hr_api.g_varchar2
  ,p_end_date_comments              in     varchar2  default hr_api.g_varchar2
  ,p_initial_period_comments        in     varchar2  default hr_api.g_varchar2
  ,p_renewal_period_comments        in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in     number    default hr_api.g_number
  ,p_VALIDITY_DURATION              in     NUMBER    default hr_api.g_number
  ,p_VALIDITY_DURATION_UNITS        in     VARCHAR2  default hr_api.g_varchar2
  ,p_RENEWABLE_FLAG                 in     VARCHAR2  default hr_api.g_varchar2
  ,p_VALIDITY_START_TYPE            in     VARCHAR2  default hr_api.g_varchar2
  ,p_COMPETENCY_UPDATE_LEVEL        in     VARCHAR2  default hr_api.g_varchar2
  ,p_validate                       in     boolean   default false
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_certification >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the certification.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The certification record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The certification enrollment is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the certification record, and raises an error.
 *
 * @param p_certification_id The unique identifier for the certification record.
 * @param p_object_version_number Current version number of the certification to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Certification
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_certification
  (p_certification_id              in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false
  );
end ota_certification_api;

 

/
