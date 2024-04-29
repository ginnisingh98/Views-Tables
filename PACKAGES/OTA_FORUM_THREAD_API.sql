--------------------------------------------------------
--  DDL for Package OTA_FORUM_THREAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_THREAD_API" AUTHID CURRENT_USER as
/* $Header: otftsapi.pkh 120.3 2006/07/12 10:58:33 niarora noship $ */
/*#
 * This package contains forum thread-related APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Forum Threads
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_forum_thread >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the forum thread.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum under which the thread is being created must exist.
 *
 * <p><b>Post Success</b><br>
 * The forum thread is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a forum thread record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_forum_id Identifies the forum under which the thread is being created.
 * @param p_business_group_id The business group owning the forum thread and the forum.
 * @param p_subject The subject of the discussion thread.
 * @param p_private_thread_flag Indicates if this is a private thread between learners
 * and instructors or public to all users subscribed to the forum.
 * Permissible values are 'Y' and 'N'.
 * @param p_last_post_date Indicates the date of posting of the most recent message under this thread.
 * @param p_reply_count Indicates the number of replies that have been posted to the original
 * thread and the message.
 * @param p_forum_thread_id The unique identifier for the forum thread record.
 * @param p_object_version_number If p_validate is false, then set to the version number of the created
 * forum thread. If p_validate is true, then the value will be null.
 * @rep:displayname Create Forum Thread
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_forum_thread
  (p_validate                       in  boolean          default false
  ,p_effective_date                 in  date
  ,p_forum_id                       in     number
  ,p_business_group_id              in     number
  ,p_subject                        in     varchar2
  ,p_private_thread_flag            in     varchar2
  ,p_last_post_date                 in     date     default null
  ,p_reply_count                    in     number   default null
  ,p_forum_thread_id                out nocopy number
  ,p_object_version_number          out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_forum_thread >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the forum thread.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum thread record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The forum thread is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the forum thread record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_forum_id Identifies the forum under which the thread is being created.
 * @param p_business_group_id Identifies the business group owning the forum thread record.
 * @param p_subject The subject of the discussion thread.
 * @param p_private_thread_flag Indicates if this is a private thread between learners and
 * instructors or public to all users subscribed to the forum.
 * Permissible values are 'Y' and 'N'.
 * @param p_last_post_date Indicates the date of posting of the most recent message under this thread.
 * @param p_reply_count Indicates the number of replies that have been posted to the original
 * thread and the message.
 * @param p_forum_thread_id The unique identifier for the forum thread record.
 * @param p_object_version_number Pass in the current version number of the forum thread to be updated.
 * When the API completes if p_validate is false, will be set to the new version number of the
 * updated forum thread. If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Forum Thread
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_forum_thread
  (p_validate                       in  boolean          default false
  ,p_effective_date                 in  date
  ,p_forum_id                       in     number
  ,p_business_group_id              in     number
  ,p_subject                        in     varchar2
  ,p_private_thread_flag            in     varchar2
  ,p_last_post_date                 in     date     default null
  ,p_reply_count                    in     number   default null
  ,p_forum_thread_id                in     number
  ,p_object_version_number          in out nocopy number
  );


--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_forum_thread >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the forum thread.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum thread record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The forum thread is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the forum thread record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_forum_thread_id The unique identifier for the forum thread record.
 * @param p_object_version_number Current version number of the forum thread to be deleted.
 * @rep:displayname Delete Forum Thread
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_forum_thread
  (p_validate                      in     boolean  default false
  ,p_forum_thread_id              in     number
  ,p_object_version_number         in     number
  );
end ota_forum_thread_api;

 

/
