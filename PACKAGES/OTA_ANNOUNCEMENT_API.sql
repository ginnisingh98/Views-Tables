--------------------------------------------------------
--  DDL for Package OTA_ANNOUNCEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ANNOUNCEMENT_API" AUTHID CURRENT_USER as
/* $Header: otancapi.pkh 120.1 2005/10/02 02:07:19 aroussel $ */
/*#
 * This package contains the Announcement APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Announcement
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_announcement >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an announcement.
 *
 * This business process allows the user to create a record used within the
 * Announcement functionality.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The business group that owns the announcement must exist.
 *
 * <p><b>Post Success</b><br>
 * The announcement is created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a member record, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_announcement_title Announcement Title
 * @param p_announcement_body Announcement Body
 * @param p_business_group_id Business Group of the Announcement
 * @param p_start_date_active Start Date
 * @param p_end_date_active End Date
 * @param p_owner_id Owner of the announcement
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
 * @param p_announcement_id If p_validate is false, then this ID identifies the
 * announcement created. If false, the ID is null.
 * @param p_object_version_number If p_validate is false,then set to version
 * number of the created announcement. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Announcement
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_ANNOUNCEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_announcement
  (p_validate                      in     boolean  default false
  ,p_effective_date               in     date
  ,p_announcement_title           in varchar2
  ,p_announcement_body            in varchar2
  ,p_business_group_id              in     number
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
  ,p_owner_id                       in     number   default null
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
  ,p_announcement_id                   out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_announcement >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an announcement.
 *
 * This business process allows the user to update a member record used within
 * the Announcement functionality.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The announcement must exist
 *
 * <p><b>Post Success</b><br>
 * The announcement is updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the announcement record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_announcement_title Announcement Title
 * @param p_announcement_body Announcement Body
 * @param p_business_group_id Business Group of the Announcement
 * @param p_start_date_active Start Date
 * @param p_end_date_active End Date
 * @param p_owner_id Owner of the announcement
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
 * @param p_announcement_id The unique identifier for the member record.
 * @param p_object_version_number Pass in the current version number of the
 * announcement to be updated. When the API completes, if p_validate is false,
 * the number is set to the new version number of the updated version number.
 * If p_validate is true it remains unchanged.
 * @rep:displayname Update Announcement
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_ANNOUNCEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_announcement
  (p_validate                      in     boolean  default false
  ,p_effective_date               in     date
  ,p_announcement_title           in varchar2
  ,p_announcement_body            in varchar2
  ,p_business_group_id              in     number
  ,p_start_date_active              in     date     default hr_api.g_date
  ,p_end_date_active                in     date     default hr_api.g_date
  ,p_owner_id                       in     number   default hr_api.g_number
  ,p_attribute_category             in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2 default hr_api.g_varchar2
  ,p_announcement_id                in     number
  ,p_object_version_number          in   out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_announcement >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an announcement.
 *
 * This business process allows the user to delete a member record used within
 * the Announcement functionality.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The announcement record should exist
 *
 * <p><b>Post Success</b><br>
 * The announcement record is deleted
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the announcement record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_announcement_id {@rep:casecolumn OTA_ANNOUNCEMENTS.ANNOUNCEMENT_ID}
 * @param p_object_version_number Pass in the current version number of the
 * announcement to be deleted.
 * @rep:displayname Delete Announcement
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_ANNOUNCEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_announcement
  ( p_validate                      in     boolean  default false
  ,p_announcement_id               in     number
  ,p_object_version_number         in     number
  );
end ota_announcement_api;

 

/
