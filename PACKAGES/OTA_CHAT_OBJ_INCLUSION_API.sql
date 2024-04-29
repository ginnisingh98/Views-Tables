--------------------------------------------------------
--  DDL for Package OTA_CHAT_OBJ_INCLUSION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_OBJ_INCLUSION_API" AUTHID CURRENT_USER as
/*$Header: otcoiapi.pkh 120.2 2006/07/12 10:49:41 niarora noship $*/
/*#
 * This package contains Category Chat and Class Chat association-related APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Chat Inclusion APIs
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_chat_obj_inclusion >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a chat-to-category or chat-to-class association.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The chat record and the category/class record for which this association is being created must be defined.
 *
 * <p><b>Post Success</b><br>
 * An association between the chat and category/class is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the association record between the chat and the category/class, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_id Identifies the category or class with which the chat is being associated.
 * @param p_object_type Identifies the type of association (chat-to-category or chat-to-class).
 * Permissible values are 'C' (chat-to-category) or 'E' (chat-to-class).
 * @param p_primary_flag Primary indicator. Permissible values 'Y' or 'N'.
 * @param p_start_date_active Date from which the association between the chat and category/class becomes active.
 * @param p_end_date_active Date after which the association between the chat and category/class is no longer active.
 * @param p_chat_id Identifies the chat for which the association record is being created.
 * @param p_object_version_number If p_validate is false, then set to the version number of the created chat
 * inclusion record. If p_validate is true, then the value will be null.
 * @rep:displayname Create Chat Association
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_chat_obj_inclusion (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_object_id                    in  number
  ,p_object_type                  in  varchar2
  ,p_primary_flag                 in  varchar2
  ,p_start_date_active            in  date             default sysdate
  ,p_end_date_active              in  date             default null
  ,p_chat_id                      in  number
  ,p_object_version_number        out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |------------------------< update_chat_obj_inclusion >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the chat-to-category or chat-to-class association.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The chat record and the category/class record for which this association is being updated must be defined.
 *
 * <p><b>Post Success</b><br>
 * The association between the chat and cateogry/class is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the association record between the chat and the category/class, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are applicable during the start
 * to end active date range. This date does not determine when the changes take effect.
 * @param p_object_id Identifies the category or class with which the chat is being associated.
 * @param p_object_type Identifies the type of association (chat-to-category or chat-to-class).
 * Permissible values are 'C' (chat-to-category) or 'E' (chat-to-class).
 * @param p_primary_flag Primary indicator. Permissible values 'Y' or 'N'.
 * @param p_start_date_active Date from which the association between the chat and category/class becomes active.
 * @param p_end_date_active Date after which the association between the chat and category/class is no longer active.
 * @param p_chat_id Identifies the chat for which the association record is being updated.
 * @param p_object_version_number Pass in the current version number of the chat inclusion record to be updated.
 * When the API completes if p_validate is false, will be set to the new version number of the updated
 * chat inclusion. If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Chat Association
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_chat_obj_inclusion (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_object_id                    in  number
  ,p_object_type                  in  varchar2
  ,p_primary_flag                 in  varchar2         default hr_api.g_varchar2
  ,p_start_date_active            in  date             default hr_api.g_date
  ,p_end_date_active              in  date             default hr_api.g_date
  ,p_chat_id                      in  number
  ,p_object_version_number        in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_chat_obj_inclusion >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the chat-to-category or chat-to-class association.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The inclusion record, as well as the chat record and the category/class record, must exist.
 *
 * <p><b>Post Success</b><br>
 * The chat-category inclusion or chat-class inclusion is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the association record between the chat and the category/class and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_chat_id Identifies the chat for which the association record is being deleted.
 * @param p_object_id Identifies the category or class with which the chat is associated.
 * @param p_object_type Identifies the type of association (chat-to-category or chat-to-class).
 * Permissible values are 'C' (chat-to-category) or 'E' (chat-to-class).
 * @param p_object_version_number Current version number of the chat inclusion record to be deleted.
 * @rep:displayname Delete Chat Association
 * @rep:category BUSINESS_ENTITY OTA_CHAT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_chat_obj_inclusion
  (p_validate                      in     boolean  default false
  ,p_chat_id                      in     number
  ,p_object_id                    in     number
  ,p_object_type                  in     varchar2
  ,p_object_version_number         in     number
  );
end ota_chat_obj_inclusion_api;

 

/
