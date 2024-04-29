--------------------------------------------------------
--  DDL for Package OTA_CHAT_USER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_USER_API" AUTHID CURRENT_USER as
/* $Header: otcusapi.pkh 120.3 2006/07/13 11:56:08 niarora noship $ */
/*#
 * This package contains chat user-related APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Chat Users APIs
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_chat_user >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a chat user record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The chat for which the user record is being created must exist.
 *
 * <p><b>Post Success</b><br>
 * The chat user record is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the chat user record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_business_group_id The business group owning the chat and the learner.
 * @param p_chat_id Identifies the chat that the learner has logged into.
 * @param p_person_id Identifies the person who has logged into the chat.
 * @param p_contact_id Identifies the external learner who has logged into the chat.
 * @param p_login_date Date of logging into the chat.
 * @param p_object_version_number If p_validate is false, then set to the version number
 * of the chat user record. If p_validate is true, then the value will be null.
 * @rep:displayname Create Chat User
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_chat_user (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_chat_id                      in  number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_login_date                     in  date
  ,p_business_group_id            in  number
  ,p_object_version_number        out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_chat_user >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the chat user record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The chat user record which is being updated must be defined.
 *
 * <p><b>Post Success</b><br>
 * The chat user record is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the chat user record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date
 * does not determine when the changes take effect.
 * @param p_chat_id Identifies the chat that the learner has logged into.
 * @param p_person_id Identifies the person who has logged into the chat.
 * @param p_contact_id Identifies the external learner who has logged into the chat.
 * @param p_login_date Date of logging into the chat.
 * @param p_business_group_id The business group owning the chat and the learner.
 * @param p_object_version_number Pass in the current version number of the chat user
 * record to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated chat user. If p_validate is
 * true will be set to the same value which was passed in.
 * @rep:displayname Update Chat User
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_chat_user (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_chat_id                      in  number
  ,p_person_id                    in  number           default hr_api.g_number
  ,p_contact_id                   in  number           default hr_api.g_number
  ,p_login_date                   in  date
  ,p_business_group_id            in  number
  ,p_object_version_number        in out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_chat_user >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the chat user record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The chat user record which is being deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The chat user record is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the chat user record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_chat_id Identifies the chat that the learner has logged into.
 * @param p_person_id Identifies the person who has logged into the chat.
 * @param p_contact_id Identifies the external learner who has logged into the chat.
 * @param p_object_version_number Current version number of the chat user record to be deleted.
 * @rep:displayname Delete Chat User
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_chat_user
  (p_validate                     in     boolean  default false
  ,p_chat_id                      in     number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_object_version_number        in     number
  );
end ota_chat_user_api;

 

/
