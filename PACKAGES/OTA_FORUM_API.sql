--------------------------------------------------------
--  DDL for Package OTA_FORUM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_API" AUTHID CURRENT_USER as
/* $Header: otfrmapi.pkh 120.2 2006/07/12 10:53:33 niarora noship $ */
/*#
 * This package contains forum-related APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Forum
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_forum >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the forum.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The business group must exist.
 *
 * <p><b>Post Success</b><br>
 * The forum is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a forum record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group owning the forum.
 * @param p_name The name of the forum.
 * @param p_description The description for the forum.
 * @param p_start_date_active The date on which the learners can begin to subscribe to
 * the category forum and post messages to the category forum/class forum.
 * @param p_end_date_active The date on which the forum becomes no longer available to learners.
 * @param p_message_type_flag Indicates if public/private messages can be posted to the
 * forum. Permissible values are 'P'(public messages'), 'V'(private messages), 'B'(both).
 * @param p_allow_html_flag Indicates if html markup type is allowed. Permissible values are 'Y' and 'N'.
 * @param p_allow_attachment_flag Indicates if attachments can be uploaded with messages.
 * Permissible values are 'Y' and 'N'.
 * @param p_auto_notification_flag Indicates if notifications should be automatically received
 * when new messages are posted to the forum. Permissible values are 'Y' and 'N'.
 * @param p_public_flag Indicates whether the forum is public. Permissible values are 'Y' and 'N'.
 * @param p_forum_id The unique identifier for the forum.
 * @param p_object_version_number If p_validate is false, then set to the version number of the
 * created forum. If p_validate is true, then the value will be null.
 * @rep:displayname Create Forum
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_forum
  (p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2         default null
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date             default null
  ,p_end_date_active              in  date             default null
  ,p_message_type_flag            in  varchar2         default 'P'
  ,p_allow_html_flag              in  varchar2         default 'N'
  ,p_allow_attachment_flag        in  varchar2         default 'N'
  ,p_auto_notification_flag       in  varchar2         default 'N'
  ,p_public_flag                  in  varchar2         default 'N'
  ,p_forum_id                     out nocopy number
  ,p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_forum >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the forum.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The forum is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the forum record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are applicable
 * during the start to end active date range. This date does not determine when
 * the changes take effect.
 * @param p_name The name of the forum.
 * @param p_description The description for the forum.
 * @param p_business_group_id The unique identifier of the business group that owns this forum.
 * @param p_start_date_active The date on which the learners can begin to subscribe to
 * the category forum and post messages to the category forum/class forum.
 * @param p_end_date_active The date on which the forum becomes no longer available to learners.
 * @param p_message_type_flag Indicates if public/private messages can be posted to the forum.
 * Permissible values are 'P'(public messages'), 'V'(private messages), 'B'(both).
 * @param p_allow_html_flag Indicates if html markup type is allowed. Permissible values
 * are 'Y' and 'N'.
 * @param p_allow_attachment_flag Indicates if attachments can be uploaded with messages.
 * Permissible values are 'Y' and 'N'.
 * @param p_auto_notification_flag Indicates if notifications should be automatically received
 * when new messages are posted to the forum. Permissible values are 'Y' and 'N'.
 * @param p_public_flag Indicates whether the forum is public. Permissible values are 'Y' and 'N'.
 * @param p_forum_id The unique identifier for the forum.
 * @param p_object_version_number Pass in the current version number of the forum to be updated.
 * When the API completes if p_validate is false, will be set to the new version number of the
 * updated forum. If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Forum
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_forum
  (p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date             default hr_api.g_date
  ,p_end_date_active              in  date             default hr_api.g_date
  ,p_message_type_flag            in  varchar2         default hr_api.g_varchar2
  ,p_allow_html_flag              in  varchar2         default hr_api.g_varchar2
  ,p_allow_attachment_flag        in  varchar2         default hr_api.g_varchar2
  ,p_auto_notification_flag       in  varchar2         default hr_api.g_varchar2
  ,p_public_flag                  in  varchar2         default hr_api.g_varchar2
  ,p_forum_id                     in  number
  ,p_object_version_number        in out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_forum >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the forum.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The forum is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the forum record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_forum_id The unique identifier for the forum record.
 * @param p_object_version_number Current version number of the forum to be deleted.
 * @rep:displayname Delete Forum
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_forum
  (p_validate                      in     boolean  default false
  ,p_forum_id                      in     number
  ,p_object_version_number         in     number
  );
end ota_forum_api;

 

/
