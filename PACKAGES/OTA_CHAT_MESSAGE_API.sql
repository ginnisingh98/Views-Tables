--------------------------------------------------------
--  DDL for Package OTA_CHAT_MESSAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_MESSAGE_API" AUTHID CURRENT_USER as
/*$Header: otcmsapi.pkh 120.4 2006/07/13 11:58:44 niarora noship $*/
/*#
 * This package contains chat messages related APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Chat Message
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_chat_message >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the chat message.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The chat record with which the message is associated must exist.
 *
 * <p><b>Post Success</b><br>
 * The chat message is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a chat message record and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The unique identifier of the business group that owns this chat message.
 * @param p_chat_id Identifies the chat for which the message is posted.
 * @param p_person_id Identifies the person who created the message.
 * @param p_contact_id Identifies the external learner who created the message.
 * @param p_target_person_id Identifies the target person to whom the message is posted.
 * If not null, indicates that the message is a private message; else it is public to all.
 * @param p_target_contact_id Identifies the target external learner to whom the message
 * is posted. If not null, indicates that the message is a private message; else it is public to all.
 * @param p_message_text The text of the message being posted.
 * @param p_chat_message_id The unique identifier for the chat message record.
 * @param p_object_version_number If p_validate is false, then set to the version number of the
 * created chat message. If p_validate is true, then the value will be null.
 * @rep:displayname Create Chat Message
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_chat_message (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_chat_id                      in  number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_target_person_id             in  number
  ,p_target_contact_id            in  number
  ,p_message_text                 in  varchar2
  ,p_business_group_id            in  number
  ,p_chat_message_id              out nocopy number
  ,p_object_version_number        out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_chat_message >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the chat message.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The chat message record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The chat message is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the chat message record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are applicable
 * during the start to end active date range. This date does not determine when the changes take effect.
 * @param p_chat_id Identifies the chat for which the message is posted.
 * @param p_person_id Identifies the person who created the message.
 * @param p_contact_id Identifies the external learner who created the message.
 * @param p_target_person_id Identifies the target person to whom the message is posted. If not
 * Null, indicates that the message is a private message; else it is public to all.
 * @param p_target_contact_id Identifies the target external learner to whom the message is posted.
 * If not null, indicates that the message is a private message; else it is public to all.
 * @param p_message_text The text of the message being posted.
 * @param p_business_group_id The unique identifier of the business group that owns this chat message.
 * @param p_chat_message_id The unique identifier for the chat message record.
 * @param p_object_version_number Pass in the current version number of the chat message to be updated.
 * When the API completes if p_validate is false, will be set to the new version number of the updated
 * chat message. If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Chat Message
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_chat_message (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_chat_id                      in  number
  ,p_person_id                    in  number           default hr_api.g_number
  ,p_contact_id                   in  number           default hr_api.g_number
  ,p_target_person_id             in  number           default hr_api.g_number
  ,p_target_contact_id            in  number           default hr_api.g_number
  ,p_message_text                 in  varchar2         default hr_api.g_varchar2
  ,p_business_group_id            in  number
  ,p_chat_message_id              in  number
  ,p_object_version_number        in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_chat_message >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the chat message.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The chat message record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The chat message is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the chat message record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_chat_message_id The unique identifier for the chat message record.
 * @param p_object_version_number Current version number of the chat message to be deleted.
 * @rep:displayname Delete Chat Message
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_chat_message
  (p_validate                      in     boolean  default false
  ,p_chat_message_id               in     number
  ,p_object_version_number         in     number
  );
end ota_chat_message_api;

 

/
