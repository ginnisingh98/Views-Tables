--------------------------------------------------------
--  DDL for Package OTA_CHAT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_API" AUTHID CURRENT_USER as
/* $Header: otchaapi.pkh 120.5 2006/07/13 11:54:28 niarora noship $ */
/*#
 * This package contains chat related APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Chats
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_chat >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Chat.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Business group must exist.
 *
 * <p><b>Post Success</b><br>
 * The Chat is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a chat record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The unique identifier of the business group that owns this chat.
 * @param p_name The name of the chat.
 * @param p_description The description for the chat.
 * @param p_start_date_active The date on which the learners can begin to subscribe to and
 * enter the category chat or the date on which the learners can enter the class chat.
 * @param p_end_date_active The date on which the chat becomes no longer available to learners.
 * @param p_start_time_active The time from which the learners can begin to subscribe to and enter
 * the category chat or the date on which the learners can enter the class chat.
 * @param p_end_time_active The time after which the chat becomes no longer available to learners.
 * @param p_timezone_code Time Zone code of the Chat. Foreign key to FND_TIMEZONES_B table.
 * @param p_public_flag Indicates whether the chat is public. Permissible values are 'Y' and 'N'.
 * @param p_chat_id The unique identifier for the chat record.
 * @param p_object_version_number If p_validate is false, then set to the version number of the
 * created chat. If p_validate is true, then the value will be null.
 * @rep:displayname Create Chat
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_chat (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2         default null
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date             default null
  ,p_end_date_active              in  date             default null
  ,p_start_time_active            in  varchar2         default null
  ,p_end_time_active              in  varchar2         default NULL
  ,p_timezone_code                in  varchar2         default null
  ,p_public_flag                  in  varchar2         default 'N'
  ,p_chat_id                     out nocopy number
  ,p_object_version_number        out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_chat >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the chat.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The chat record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The chat is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the chat record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are applicable
 * during the start to end active date range. This date does not determine
 * when the changes take effect.
 * @param p_name The name of the chat.
 * @param p_description The description for the chat.
 * @param p_business_group_id The unique identifier of the business group that owns this chat.
 * @param p_start_date_active The date on which the learners can begin to subscribe to and enter
 * the category chat or the date on which the learners can enter the class chat.
 * @param p_end_date_active The date on which the chat becomes no longer available to learners.
 * @param p_start_time_active The time from which the learners can begin to subscribe to and
 * enter the category chat or the date on which the learners can enter the class chat.
 * @param p_end_time_active The time after which the chat becomes no longer available to learners.
 * @param p_timezone_code Time Zone code of the Chat. Foreign key to FND_TIMEZONES_B table.
 * @param p_public_flag Indicates whether the chat is public. Permissible values are 'Y' and 'N'.
 * @param p_chat_id The unique identifier for the chat record.
 * @param p_object_version_number Pass in the current version number of the chat to be
 * updated. When the API completes if p_validate is false, will be set to the new version
 * number of the updated chat. If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Chat
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_chat
  (p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2
  ,p_business_group_id            in  number
  ,p_start_date_active            in  date             default hr_api.g_date
  ,p_end_date_active              in  date             default hr_api.g_date
  ,p_start_time_active            in  varchar2         default hr_api.g_varchar2
  ,p_end_time_active              in  varchar2         default hr_api.g_varchar2
  ,p_timezone_code                IN  VARCHAR2         DEFAULT hr_api.g_varchar2
  ,p_public_flag                  in  varchar2         default hr_api.g_varchar2
  ,p_chat_id                      in  number
  ,p_object_version_number        in out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_chat >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the chat.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The chat record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The chat is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the chat record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_chat_id The unique identifier for the chat record.
 * @param p_object_version_number Current version number of the chat to be deleted.
 * @rep:displayname Delete Chat
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_chat
  (p_validate                      in     boolean  default false
  ,p_chat_id                      in     number
  ,p_object_version_number         in     number
  );

end ota_chat_api;
--

 

/
