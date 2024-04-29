--------------------------------------------------------
--  DDL for Package OTA_FRM_OBJ_INCLUSION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FRM_OBJ_INCLUSION_API" AUTHID CURRENT_USER as
/* $Header: otfoiapi.pkh 120.3 2006/07/13 12:13:58 niarora noship $ */
/*#
 * This package contains Category Forum and Class Forum association-related APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Forum Inclusion APIs
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_frm_obj_inclusion >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a forum-to-category or forum-to-class association.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum record and the category/class record for which this association is being created must be defined.
 *
 * <p><b>Post Success</b><br>
 * An association between the forum and cateogry/class is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the association record between the forum and the category/class, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_object_id Identifies the category or class with which the forum is being associated.
 * @param p_object_type Identifies the type of association (forum-to-category or forum-to-class).
 * Permissible values are 'C' (forum-to-category) or 'E' (forum-to-class).
 * @param p_primary_flag Primary indicator. Permissible values 'Y' or 'N'.
 * @param p_start_date_active Date from which the association between the forum and category/class becomes active.
 * @param p_end_date_active Date after which the association between the forum and category/class is no longer active.
 * @param p_forum_id Identifies the forum for which the association record is being created.
 * @param p_object_version_number If p_validate is false, then set to the version number of the
 * created forum inclusion record. If p_validate is true, then the value will be null.
 * @rep:displayname Create Forum Association
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_frm_obj_inclusion (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_object_id                    in  number
  ,p_object_type                  in  varchar2
  ,p_primary_flag                 in  varchar2
  ,p_start_date_active            in  date             default sysdate
  ,p_end_date_active              in  date             default null
  ,p_forum_id                     in  number
  ,p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_frm_obj_inclusion >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a forum-to-category or forum-to-class association.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The forum record and the category/class record for which this association is being updated must be defined.
 *
 * <p><b>Post Success</b><br>
 * The association between the forum and cateogry/class is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the association record between the forum and the category/class, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_object_id Identifies the category or class with which the forum is being associated.
 * @param p_object_type Identifies the type of association (forum-to-category or
 * forum-to-class). Permissible values are 'C' (forum-to-category) or 'E' (forum-to-class).
 * @param p_primary_flag Primary indicator. Permissible values 'Y' or 'N'.
 * @param p_start_date_active Date from which the association between the forum and category/class becomes active.
 * @param p_end_date_active Date after which the association between the forum and category/class is no longer active.
 * @param p_forum_id Identifies the forum for which the association record is being updated.
 * @param p_object_version_number Pass in the current version number of the forum inclusion record
 * to be updated. When the API completes if p_validate is false, will be set
 * to the new version number of the updated forum inclusion. If p_validate is true will
 * be set to the same value which was passed in.
 * @rep:displayname Update Forum Association
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_frm_obj_inclusion (
   p_validate                     in  boolean          default false
  ,p_effective_date               in  date
  ,p_object_id                    in  number
  ,p_object_type                  in  varchar2
  ,p_primary_flag                 in  varchar2         default hr_api.g_varchar2
  ,p_start_date_active            in  date             default hr_api.g_date
  ,p_end_date_active              in  date             default hr_api.g_date
  ,p_forum_id                     in  number
  ,p_object_version_number        in  out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_frm_obj_inclusion >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a forum-to-category or forum-to-class association.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The inclusion record, as well as the forum record and the category/class record, must exist.
 *
 * <p><b>Post Success</b><br>
 * The forum-category inclusion or forum-class inclusion is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the association record between the forum and the category/class, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_forum_id Identifies the forum for which the association record is being deleted.
 * @param p_object_id Identifies the category or class with which the forum is associated.
 * @param p_object_type Identifies the type of association (forum-to-category or forum-to-class).
 * Permissible values are 'C' (forum-to-category) or 'E' (forum-to-class).
 * @param p_object_version_number Current version number of the forum inclusion record to be deleted.
 * @rep:displayname Delete Forum Association
 * @rep:category BUSINESS_ENTITY OTA_FORUM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_frm_obj_inclusion
  (p_validate                      in     boolean  default false
  ,p_forum_id                      in     number
  ,p_object_id                     in     number
  ,p_object_type                   in     varchar2
  ,p_object_version_number         in     number
  );
end ota_frm_obj_inclusion_api;

 

/
