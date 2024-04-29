--------------------------------------------------------
--  DDL for Package HR_POS_HIERARCHY_ELE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POS_HIERARCHY_ELE_API" AUTHID CURRENT_USER as
/* $Header: pepseapi.pkh 120.1.12000000.1 2007/01/22 02:04:37 appldev noship $ */
/*#
 * This package contains APIs that create and maintain position hierarchy
 * elements.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Position Hierarchy Element
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pos_hierarchy_ele >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Position Hierarchy Elements.
 *
 * This business process creates a new parent-child position element. If the
 * child already exists in the hierarchy, the element is deleted and a new
 * element is created in its place.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Position should already exist.
 *
 * <p><b>Post Success</b><br>
 * Position hierarchy element record will be created.
 *
 * <p><b>Post Failure</b><br>
 * Position hierarchy element record will not be created and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_parent_position_id Uniquely identifies the parent position of the
 * parent-child element the process creates.
 * @param p_pos_structure_version_id Uniquely identifies the position hierarchy
 * version associated with the element the process creates.
 * @param p_subordinate_position_id Uniquely identifies the subordinate
 * position of the parent-child element the process creates.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the position hierarchy.
 * @param p_hr_installed Flag specifying if HRMS is installed.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_pos_structure_element_id If p_validate is false, then this uniquely
 * identifies the Position Hierarchy Element created. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Position Hierarchy Element. If p_validate is
 * true, then set to null.
 * @rep:displayname Create Position Hierarchy Element
 * @rep:category BUSINESS_ENTITY PER_POSITION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pos_hierarchy_ele
  (p_validate                      in     boolean  default false
  ,p_parent_position_id            in     number
  ,p_pos_structure_version_id      in     number
  ,p_subordinate_position_id       in     number
  ,p_business_group_id             in     number
  ,p_hr_installed                  in     VARCHAR2
  ,p_effective_date                in     date
  ,p_pos_structure_element_id         out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pos_hierarchy_ele >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a parent to a new child or a child to a new parent.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Position hierarchy element record should exist.
 *
 * <p><b>Post Success</b><br>
 * Position hierarchy element record will be updated.
 *
 * <p><b>Post Failure</b><br>
 * Position hierarchy record will not be updated and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pos_structure_element_id Identifies the position hierarchy element
 * record to update.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_parent_position_id Uniquely identifies the parent position of the
 * parent-child element the process updates.
 * @param p_subordinate_position_id Uniquely identifies the subordinate
 * position of the parent-child element the process updates.
 * @param p_object_version_number Pass in the current version number of the
 * position hierarchy element to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * position hierarchy element. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Position Hierarchy Element
 * @rep:category BUSINESS_ENTITY PER_POSITION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pos_hierarchy_ele
  (p_validate                      in     boolean  default false
  ,p_pos_structure_element_id      in     number
  ,p_effective_date                in     date
  ,p_parent_position_id            in     number   default hr_api.g_number
  ,p_subordinate_position_id       in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pos_hierarchy_ele >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Position Hierarchy Element.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Position hierarchy record should exist.
 *
 * <p><b>Post Success</b><br>
 * Position hierarchy record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Position hierarchy is not deleted and error is returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pos_structure_element_id Uniquely identifies the position hierarchy
 * element record to be deleted.
 * @param p_object_version_number Current version number of the Position
 * Hierarchy Element to be deleted.
 * @param p_hr_installed Flag specifying if HRMS is installed.
 * @rep:displayname Delete Position Hierarchy Element
 * @rep:category BUSINESS_ENTITY PER_POSITION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_pos_hierarchy_ele
  (p_validate                      in     boolean  default false
  ,p_pos_structure_element_id      in     number
  ,p_object_version_number         in     number
  ,p_hr_installed                  in     VARCHAR2
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pos_hier_elem_internal >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This alternative interface creates a new parent-child element. If the child
--   already exists in the hierarchy the element is deleted and a new element
--   is created in its place. It simply calls the create_pos_hierarchy_ele
--   business process with p_validate set to false.
--
-- Prerequisites:
--
-- In Parameters:
--  Name                           Reqd Type     Description
--  p_parent_position_id           yes  number   fk to per_all_positions
--  p_pos_structure_version_id     yes  number   fk to per_pos_structure_versions
--  p_subordinate_position_id      yes  number   fk to per_all_positions
--  p_business_group_id            yes  number   business group context
--  p_hr_installed                 yes  VARCHAR2 check fnd_product_installations
--                                               set to 'I' if installed
--  p_effective_date                    date     effective date.
--
-- Post Success:
--  row is created
--
--
-- Post Failure:
--
--   The procedure will raise an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_pos_hier_elem_internal
  (p_parent_position_id            in     number
  ,p_pos_structure_version_id      in     number
  ,p_subordinate_position_id       in     number
  ,p_business_group_id             in     number
  ,p_hr_installed                  in     VARCHAR2
  ,p_effective_date                in     date
  ,p_pos_structure_element_id         out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_pos_hier_elem_internal >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process is used to update move a parent to a new child
--   or a child to a new parent. When called from here p_validate is
--   always set to false
--
-- Prerequisites:
--   none
--
-- In Parameters:
--  Name                           Reqd Type     Description
--  p_pos_structure_element_id     yes  number   primary key
--  p_parent_position_id           yes  number   fk to per_all_positions
--  p_subordinate_position_id      yes  number   fk to per_all_positions
--  p_object_version_number        yes  number   object version number
--  p_effective_date               yes  date     effective date
--
--
-- Post Success:
--  row is updated
--
-- Post Failure:
--
--   The procedure will raise an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_pos_hier_elem_internal
  (p_pos_structure_element_id      in     number
  ,p_parent_position_id            in     number   default hr_api.g_number
  ,p_subordinate_position_id       in     number   default hr_api.g_number
  ,p_effective_date                in     date
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_pos_hier_elem_internal >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This alternative interface is used to remove an pos hierarchy element
--   When called from here p_validate is always set to false
--
-- Prerequisites:
--   element cannot be deleted if children exist.
--
--
-- In Parameters:
--  Name                           Reqd Type     Description
--  p_pos_structure_element_id     yes  number   primary key
--  p_object_version_number        yes  number   object version number
--  p_hr_installed                 yes  VARCHAR2 check fnd_product_installations
--                                               set to 'I' if installed
--
--
-- Post Success:
--  row is deleted
--
--
-- Post Failure:
--
--   The procedure will raise an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_pos_hier_elem_internal
  (p_pos_structure_element_id      in     number
  ,p_object_version_number         in     number
  ,p_hr_installed                  in     VARCHAR2
  );
--
end hr_pos_hierarchy_ele_api;

 

/
