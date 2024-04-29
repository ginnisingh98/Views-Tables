--------------------------------------------------------
--  DDL for Package HR_AUTHORIA_MAPPING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUTHORIA_MAPPING_API" AUTHID CURRENT_USER as
/* $Header: hrammapi.pkh 120.1 2005/10/02 01:58:49 aroussel $ */
/*#
 * This package contains APIs that maintain mapping information for the
 * Authoria integration.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Authoria Mapping
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_authoria_mapping >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the mapping between Oracle HRMS and Authoria Interface.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The benefits plan and option in plan must have been created.
 *
 * <p><b>Post Success</b><br>
 * The Authoria mapping has successfully been created.
 *
 * <p><b>Post Failure</b><br>
 * The Authoria mapping has not been created and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pl_id {@rep:casecolumn BEN_PL_F.PL_ID}
 * @param p_plip_id {@rep:casecolumn BEN_PLIP_F.PLIP_ID}
 * @param p_open_enrollment_flag Indicator for open enrollment. Valid values
 * can be Y or N.
 * @param p_target_page Authoria target page name.
 * @param p_authoria_mapping_id If p_validate is false, then this uniquely
 * identifies the authoria mapping created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created mapping. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Authoria Mapping
 * @rep:category BUSINESS_ENTITY HR_AUTHORIA_INTEGRATION_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_authoria_mapping
  (p_validate                      in     boolean  default false
  ,p_pl_id                         in     number
  ,p_plip_id                       in     number  default null
  ,p_open_enrollment_flag          in     varchar2
  ,p_target_page                   in     varchar2
  ,p_authoria_mapping_id              out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_authoria_mapping >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Authoria Mapping.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The AUTHORIA_MAPPING_ID must exist within the HR_AUTHORIA_MAPPINGS table.
 *
 * <p><b>Post Success</b><br>
 * The API will successfully update the mapping.
 *
 * <p><b>Post Failure</b><br>
 * This API does not update the mapping for the third party and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_target_page Authoria target page name.
 * @param p_authoria_mapping_id Uniquely identifies the Authoria mapping record
 * to update.
 * @param p_pl_id {@rep:casecolumn BEN_PL_F.PL_ID}
 * @param p_plip_id {@rep:casecolumn BEN_PLIP_F.PLIP_ID}
 * @param p_open_enrollment_flag Indicates whether the Authoria page can be
 * used within an open benefits enrollment period. Valid values are Y or N.
 * @param p_object_version_number Pass in the current version number of the
 * Authoria mapping to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Authoria
 * mapping. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Authoria Mapping
 * @rep:category BUSINESS_ENTITY HR_AUTHORIA_INTEGRATION_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_authoria_mapping
  (p_validate                      in     boolean  default false
  ,p_target_page                   in     varchar2
  ,p_authoria_mapping_id           in     number
  ,p_pl_id                         in     number
  ,p_plip_id                       in     number  default HR_API.G_NUMBER
  ,p_open_enrollment_flag          in     varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_authoria_mapping >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Authoria Mapping.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The AUTHORIA_MAPPING_ID must exist within the HR_AUTHORIA_MAPPINGS table.
 *
 * <p><b>Post Success</b><br>
 * The Authoria mapping will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The Authoria mapping will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_authoria_mapping_id Uniquely identifies the Authoria mapping record
 * to delete.
 * @param p_object_version_number Current version number of the Authoria
 * mapping to be deleted.
 * @rep:displayname Delete Authoria Mapping
 * @rep:category BUSINESS_ENTITY HR_AUTHORIA_INTEGRATION_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_AUTHORIA_MAPPING
  (p_validate                      in     boolean  default false
  ,p_authoria_mapping_id           in     number
  ,p_object_version_number         in     number
  );
--
--
end HR_AUTHORIA_MAPPING_API;

 

/
