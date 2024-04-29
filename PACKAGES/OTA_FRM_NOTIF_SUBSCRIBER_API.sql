--------------------------------------------------------
--  DDL for Package OTA_FRM_NOTIF_SUBSCRIBER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FRM_NOTIF_SUBSCRIBER_API" AUTHID CURRENT_USER as
/* $Header: otfnsapi.pkh 120.1 2006/07/12 11:14:25 niarora noship $ */
/*#
 * This package contains forum notification subscriber-related APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Forum Notification Subscribers
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_frm_notif_subscriber >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the forum notification subscriber record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum to which the user is subscribing for notifications must exist.
 *
 * <p><b>Post Success</b><br>
 * The forum notification subscriber record is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a forum notification subscriber record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not determine when the changes take effect.
 * @param p_business_group_id The business group owning the notification subscriber record and the forum.
 * @param p_forum_id Identifies the forum to which the user has subscribed for notifications.
 * @param p_person_id Identifies the person who has subscribed for forum notifications.
 * @param p_contact_id Identifies the external learner who has subscribed for forum notifications.
 * @param p_object_version_number If p_validate is false, then set to the version number of the
 * created forum notification subscriber record. If p_validate is true, then the value will be null.
 * @rep:displayname Create Forum Notification Subscriber
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_frm_notif_subscriber
  ( p_validate                     in boolean          default false
    ,p_effective_date               in     date
   ,p_business_group_id              in     number
   ,p_forum_id                          in  number
   ,p_person_id                         in  number
   ,p_contact_id                        in  number
   ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_frm_notif_subscriber >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the forum notification subscriber record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum notification subscriber record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The forum notification subscriber record is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the forum notification subscriber record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group owning the notification subscriber record.
 * @param p_forum_id Identifies the forum to which the user has subscribed for notifications.
 * @param p_person_id Identifies the person who has subscribed for forum notifications.
 * @param p_contact_id Identifies the external learner who has subscribed for forum notifications.
 * @param p_object_version_number Pass in the current version number of the  forum notification
 * subscriber record to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the  forum notification subscriber record. If p_validate
 * is true will be set to the same value which was passed in.
 * @rep:displayname Update Forum Notification Subscriber
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_frm_notif_subscriber
  (p_validate                     in boolean          default false
    ,p_effective_date               in     date
  ,p_forum_id                     in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_frm_notif_subscriber >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the forum notification subscriber record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum notification subscriber record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The forum notification subscriber record is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the forum notification subscriber record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_forum_id Identifies the forum to which the user has subscribed for notifications.
 * @param p_person_id Identifies the person who has subscribed for forum notifications.
 * @param p_contact_id Identifies the external learner who has subscribed for forum notifications.
 * @param p_object_version_number Current version number of the forum notification subscriber
 * record to be deleted.
 * @rep:displayname Delete Forum Notification Subscriber
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_frm_notif_subscriber
( p_validate                      in     boolean  default false
  ,p_forum_id                             in     number
  ,p_person_id                            in     number
  ,p_contact_id                           in     number
  ,p_object_version_number                in     number
  );
  end ota_frm_notif_subscriber_api;

 

/
