--------------------------------------------------------
--  DDL for Package OTA_FORUM_MESSAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_MESSAGE_API" AUTHID CURRENT_USER as
/* $Header: otfmsapi.pkh 120.2 2006/07/12 11:00:03 niarora noship $ */
/*#
 * This package contains forum message-related APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Forum Messages
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_forum_message >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the forum message.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum and the topic under which the message is being posted must exist.
 *
 * <p><b>Post Success</b><br>
 * The forum message is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a forum message record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group owning the forum message record and the forum topic.
 * @param p_forum_id Identifies the forum under which the message is being posted.
 * @param p_forum_thread_id Identifies the topic to which the message is being posted. The topic
 * belongs to the forum specified above.
 * @param p_message_scope Indicates the scope/visibility of the message to the learners/instructors.
 * Permissible values are 'P' (public message, viewable to all learners subscribed to the forum),
 * 'T' (private to a group of learners/instructors, selected during the topic creation.
 * It includes the author), 'U' (private reply between the author and learner/instructor).
 * @param p_message_body The actual message that is being posted.
 * @param p_parent_message_id Identifier of the message, to which the current message is being posted as a reply.
 * @param p_person_id Identifies the person who posted the message.
 * @param p_contact_id Identifies the external learner who posted the message.
 * @param p_target_person_id Identifies the target person to whom the private message is being sent.
 * If this value is not null and message_scope is 'U', it indicates a private message.
 * @param p_target_contact_id Identifies the target external learner to whom the private message is being sent to.
 * If this value is not null and message_scope is 'U', it indicates a private message.
 * @param p_forum_message_id Unique identifier for the forum message record.
 * @param p_object_version_number If p_validate is false, then set to the version number of the created forum
 * message. If p_validate is true, then the value will be null.
 * @rep:displayname Create Forum Message
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure create_forum_message
  (p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_forum_id                       in     number
  ,p_forum_thread_id                in     number
  ,p_business_group_id              in     number
  ,p_message_scope                  in     varchar2
  ,p_message_body                   in     varchar2 default null
  ,p_parent_message_id              in     number   default null
  ,p_person_id                      in     number   default null
  ,p_contact_id                     in     number   default null
  ,p_target_person_id               in     number   default null
  ,p_target_contact_id              in     number   default null
  ,p_forum_message_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_forum_message >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the forum message.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum message record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The forum message is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the forum message record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_forum_id Identifies the forum under which the message is being posted.
 * @param p_forum_thread_id Identifies the topic to which the message is being posted.
 * The topic belongs to the forum specified above.
 * @param p_business_group_id The business group owning the forum message record.
 * @param p_message_scope Indicates the scope/visibility of the message to the learners/instructors.
 * Permissible values are 'P' (public message, viewable to all learners subscribed to the forum),
 * 'T' (private to a group of learners/instructors, selected during the topic creation.
 * It includes the author), 'U' (private reply between the author and learner/instructor).
 * @param p_message_body The actual message that is being posted.
 * @param p_parent_message_id Identifier of the message to which the current message is being posted as a reply.
 * @param p_person_id Identifies the person who posted the message.
 * @param p_contact_id Identifies the external learner who posted the message.
 * @param p_target_person_id Identifies the target person to whom the private message is being sent.
 * If this value is not null and message_scope is 'U', it indicates a private message.
 * @param p_target_contact_id Identifies the target external learner to whom the private message is
 * being sent. If this value is not null and message_scope is 'U', it indicates a private message.
 * @param p_forum_message_id Unique identifier for the forum message record.
 * @param p_object_version_number Pass in the current version number of the forum message to be updated.
 * When the API completes if p_validate is false, will be set to the new version number of the updated forum
 * message. If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Forum Message
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_forum_message
  (p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_forum_id                     in  number   default hr_api.g_number
  ,p_forum_thread_id              in  number   default hr_api.g_number
  ,p_business_group_id            in  number   default hr_api.g_number
  ,p_message_scope                in  varchar2 default hr_api.g_varchar2
  ,p_message_body                 in  varchar2 default hr_api.g_varchar2
  ,p_parent_message_id            in  number   default hr_api.g_number
  ,p_person_id                    in  number   default hr_api.g_number
  ,p_contact_id                   in  number   default hr_api.g_number
  ,p_target_person_id             in  number   default hr_api.g_number
  ,p_target_contact_id            in  number   default hr_api.g_number
  ,p_forum_message_id             in  number
  ,p_object_version_number        in  out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_forum_message >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the forum message.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum message record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The forum message is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the forum message record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_forum_message_id The unique identifier for the forum message record.
 * @param p_object_version_number Current version number of the forum message to be deleted.
 * @rep:displayname Delete Forum Message
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_forum_message
  (p_validate                      in     boolean  default false
  ,p_forum_message_id              in     number
  ,p_object_version_number         in     number
  );
end ota_forum_message_api;

 

/
