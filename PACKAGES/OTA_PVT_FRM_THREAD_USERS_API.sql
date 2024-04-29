--------------------------------------------------------
--  DDL for Package OTA_PVT_FRM_THREAD_USERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_PVT_FRM_THREAD_USERS_API" AUTHID CURRENT_USER as
/* $Header: otftuapi.pkh 120.2 2006/07/12 11:01:43 niarora noship $ */
/*#
 * This package contains APIs related to private forum thread users.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Private Forum Thread Users
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pvt_frm_thread_user >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a private forum thread user.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum and the thread for which the private users are created must exist.
 *
 * <p><b>Post Success</b><br>
 * The private forum thread user is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a private forum thread user record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range.
 * This date does not determine when the changes take effect.
 * @param p_business_group_id The business group owning the forum and the forum thread.
 * @param p_forum_thread_id Identifies the forum thread to which the private users are being added.
 * @param p_forum_id Identifies the forum to which the private thread belongs.
 * @param p_person_id Identifies the target persons (including the author) who are included
 * in the private thread. These persons receive private messages from the thread author and
 * they can send private replies to the author.
 * @param  p_contact_id Identifies the target external learners(including the author)
 * who are included in the private thread. These learners receive private messages from the
 * thread author and they can send private replies to the author.
 * @param p_author_person_id Identifies the person (learner or instructor) who is creating
 * the private thread.
 * @param p_author_contact_id Identifies the external learner who is creating the private thread.
 * @param p_object_version_number If p_validate is false, then set to the version number of
 * the created private forum thread user. If p_validate is true, then the value will be null.
 * @rep:displayname Create Private Forum Thread User
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pvt_frm_thread_user(
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_forum_thread_id              in  number
  ,p_forum_id                     in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_business_group_id            in number
  ,p_author_person_id             in number default null
  ,p_author_contact_id            in number default null
  ,p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_pvt_frm_thread_user >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the private forum thread user.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The private forum thread user record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The private forum thread user is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the private forum thread user record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_business_group_id The business group owning the private forum thread user record.
 * @param p_forum_thread_id Identifies the forum thread to which the private users are added.
 * @param p_forum_id Identifies the forum to which the private thread belongs.
 * @param p_person_id Identifies the target persons (including the author) who are
 * included in the private thread. These persons receive private messages from
 * the thread author and they can send private replies to the author.
 * @param p_contact_id Identifies the target external learners
 * (including the author) who are included in the private thread. These learners
 * receive private messages from the thread author and they can send private replies to the author.
 * @param p_author_person_id Identifies the person (learner or instructor) who is creating
 * the private thread.
 * @param p_author_contact_id Identifies the external learner who is creating the private thread.
 * @param p_object_version_number Pass in the current version number of the private forum
 * thread user to be updated. When the API completes if p_validate is false, will be set
 * to the new version number of the updated private forum thread user. If p_validate is
 * true will be set to the same value which was passed in.
 * @rep:displayname Update Private Forum Thread User
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pvt_frm_thread_user(
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_forum_thread_id              in  number
  ,p_forum_id                     in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_business_group_id            in number
  ,p_author_person_id             in number default null
  ,p_author_contact_id            in number default null
  ,p_object_version_number        in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pvt_frm_thread_user >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the private forum thread user.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The private forum thread user record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The private forum thread user is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the private forum thread user record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_forum_thread_id Identifies the forum thread to which the private users are added.
 * @param p_forum_id Identifies the forum to which the private thread belongs.
 * @param p_person_id Identifies the target persons (including the author) who are
 * included in the private thread. These persons receive private messages from
 * the thread author and they can send private replies to the author.
 * @param p_contact_id Identifies the target external learners (including the author)
 * who are included in the private thread. These learners receive private messages
 * from the thread author and they can send private replies to the author.
 * @param p_object_version_number Current version number of the private forum thread user to be deleted.
 * @rep:displayname Delete Private Forum Thread User
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_pvt_frm_thread_user
  (p_validate                      in     boolean  default false
  ,p_forum_thread_id               in     number
  ,p_forum_id                      in     number
  ,p_person_id                     in     number
  ,p_contact_id                    in     number
  ,p_object_version_number         in     number
  );

end ota_pvt_frm_thread_users_api;

 

/
