--------------------------------------------------------
--  DDL for Package OTA_OPEN_FC_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OPEN_FC_ENROLLMENT_API" AUTHID CURRENT_USER as
/* $Header: otfceapi.pkh 120.2 2006/07/12 10:55:20 niarora noship $ */
/*#
 * This package contains category-forum and category-chat enrollments related APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Open Forum Chat Enrollments
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_open_fc_enrollment >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a forum or chat enrollment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum or chat for which the enrollment is being created must exist.
 *
 * <p><b>Post Success</b><br>
 * The forum/chat enrollment record is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a forum/chat enrollment record and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_business_group_id The business group owning the forum/chat
 * enrollment record as well as the forum/chat correspondingly.
 * @param p_forum_id Identifies the category forum to which the learner is subscribing.
 * @param p_person_id Identifies the person who is subscribing to the forum or chat.
 * @param p_contact_id Identifies the external learner who is subscribing to the forum or chat.
 * @param p_chat_id Identifies the category chat to which the learner is subscribing.
 * @param p_enrollment_id The unique identifier for the enrollment/subscription record.
 * @param p_object_version_number If p_validate is false, then set to the version number
 * of the created enrollment record. If p_validate is true, then the value will be null.
 * @rep:displayname Create Forum Chat Enrollment
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_open_fc_enrollment
  ( p_validate                     in boolean          default false
    ,p_effective_date               in     date
    ,p_business_group_id              in     number
    ,p_forum_id                       in     number   default null
    ,p_person_id                      in     number   default null
    ,p_contact_id                     in     number   default null
    ,p_chat_id                        in     number   default null
    ,p_enrollment_id                     out nocopy number
    ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_open_fc_enrollment >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the corresponding forum or chat enrollment record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The enrollment record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The enrollment record is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the forum/chat enrollment record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_enrollment_id The unique identifier for the enrollment record.
 * @param p_business_group_id The business group owning the enrollment record.
 * @param p_forum_id Identifies the category forum to which the learner is subscribing.
 * @param p_person_id Identifies the person who is subscribing to the forum or chat.
 * @param p_contact_id Identifies the external learner who is subscribing to the forum or chat.
 * @param p_chat_id Identifies the category chat to which the learner is subscribing.
 * @param p_object_version_number Pass in the current version number of the enrollment record
 * to be updated. When the API completes if p_validate is false, will be set to the new
 * version number of the updated enrollment. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Forum Chat Enrollment
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_open_fc_enrollment
  (p_validate                     in boolean          default false
    ,p_effective_date               in     date
    ,p_enrollment_id                in     number
    ,p_business_group_id            in     number    default hr_api.g_number
    ,p_forum_id                     in     number    default hr_api.g_number
    ,p_person_id                    in     number    default hr_api.g_number
    ,p_contact_id                   in     number    default hr_api.g_number
    ,p_chat_id                      in     number    default hr_api.g_number
    ,p_object_version_number        in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_open_fc_enrollment >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the forum or chat enrollment record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum/chat enrollment record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The forum/chat enrollment record is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the forum/chat enrollment record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_enrollment_id The unique identifier for the enrollment record.
 * @param p_object_version_number Current version number of the enrollment record to be deleted.
 * @rep:displayname Delete Forum Chat Enrollment
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_open_fc_enrollment
  (p_validate                      in     boolean  default false
  ,p_enrollment_id        in     number
  ,p_object_version_number         in     number
  );
end ota_open_fc_enrollment_api;

 

/
