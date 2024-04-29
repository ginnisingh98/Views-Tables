--------------------------------------------------------
--  DDL for Package PQH_ROLES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROLES_API" AUTHID CURRENT_USER as
/* $Header: pqrlsapi.pkh 120.1 2005/10/02 02:27:36 aroussel $ */
/*#
 * This package contains role APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Role
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_role >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a workflow role that determines whether a user can work on
 * and approve data for a given transaction type.
 *
 * Workflow roles can be created for a specific business or they can be global
 * roles which interact with multiple business groups.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * If the role is created for a specific business group, then that business
 * group must already exist. If the created role is of a specific role type,
 * then that role type must already be defined.
 *
 * <p><b>Post Success</b><br>
 * The workflow role will be successfully created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The workflow role will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_id If p_validate is false, then this uniquely identifies the
 * role created. If p_validate is true, then set to null.
 * @param p_role_name Unique role name
 * @param p_role_type_cd Identifies the role type of the role. Valid values are
 * defined by 'PQH_ROLE_TYPE' lookup_type.
 * @param p_enable_flag Identifies if the role is enabled/disabled. Valid
 * values are defined by 'YES_NO' lookup_type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created role. If p_validate is true, then the value
 * will be null.
 * @param p_business_group_id Business group of the role.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @rep:displayname Create Workflow Role
 * @rep:category BUSINESS_ENTITY HR_ROLE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_role
(
   p_validate                       in boolean    default false
  ,p_role_id                        out nocopy number
  ,p_role_name                      in  varchar2  default null
  ,p_role_type_cd                   in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_object_version_number          out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_effective_date                 in  date
  ,p_information_category           in varchar2   default null
  ,p_information1                   in varchar2   default null
  ,p_information2                   in varchar2   default null
  ,p_information3                   in varchar2   default null
  ,p_information4                   in varchar2   default null
  ,p_information5                   in varchar2   default null
  ,p_information6                   in varchar2   default null
  ,p_information7                   in varchar2   default null
  ,p_information8                   in varchar2   default null
  ,p_information9                   in varchar2   default null
  ,p_information10                  in varchar2   default null
  ,p_information11                  in varchar2   default null
  ,p_information12                  in varchar2   default null
  ,p_information13                  in varchar2   default null
  ,p_information14                  in varchar2   default null
  ,p_information15                  in varchar2   default null
  ,p_information16                  in varchar2   default null
  ,p_information17                  in varchar2   default null
  ,p_information18                  in varchar2   default null
  ,p_information19                  in varchar2   default null
  ,p_information20                  in varchar2   default null
  ,p_information21                  in varchar2   default null
  ,p_information22                  in varchar2   default null
  ,p_information23                  in varchar2   default null
  ,p_information24                  in varchar2   default null
  ,p_information25                  in varchar2   default null
  ,p_information26                  in varchar2   default null
  ,p_information27                  in varchar2   default null
  ,p_information28                  in varchar2   default null
  ,p_information29                  in varchar2   default null
  ,p_information30                  in varchar2   default null
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_role >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the workflow role details.
 *
 * If a workflow role is saved as business group specific or global, it cannot
 * be changed to the other option. Each role name must be unique.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The role to be updated must already exist. If the role type of the role is
 * updated, then that new role type must already be defined.
 *
 * <p><b>Post Success</b><br>
 * The role will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The role will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_id Identifies the role record to be modified.
 * @param p_role_name Unique role name.
 * @param p_role_type_cd Identifies the role type of the role. Valid values are
 * defined by 'PQH_ROLE_TYPE' lookup_type.
 * @param p_enable_flag Identifies if the role is enabled/disabled. Valid
 * values are defined by 'YES_NO' lookup_type.
 * @param p_object_version_number Pass in the current version number of the
 * role to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated role. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_business_group_id Business group of the role.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @rep:displayname Update Workflow Role
 * @rep:category BUSINESS_ENTITY HR_ROLE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_role
  (
   p_validate                       in boolean    default false
  ,p_role_id                        in  number
  ,p_role_name                      in  varchar2  default hr_api.g_varchar2
  ,p_role_type_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_information_category           in varchar2   default hr_api.g_varchar2
  ,p_information1                   in varchar2   default hr_api.g_varchar2
  ,p_information2                   in varchar2   default hr_api.g_varchar2
  ,p_information3                   in varchar2   default hr_api.g_varchar2
  ,p_information4                   in varchar2   default hr_api.g_varchar2
  ,p_information5                   in varchar2   default hr_api.g_varchar2
  ,p_information6                   in varchar2   default hr_api.g_varchar2
  ,p_information7                   in varchar2   default hr_api.g_varchar2
  ,p_information8                   in varchar2   default hr_api.g_varchar2
  ,p_information9                   in varchar2   default hr_api.g_varchar2
  ,p_information10                  in varchar2   default hr_api.g_varchar2
  ,p_information11                  in varchar2   default hr_api.g_varchar2
  ,p_information12                  in varchar2   default hr_api.g_varchar2
  ,p_information13                  in varchar2   default hr_api.g_varchar2
  ,p_information14                  in varchar2   default hr_api.g_varchar2
  ,p_information15                  in varchar2   default hr_api.g_varchar2
  ,p_information16                  in varchar2   default hr_api.g_varchar2
  ,p_information17                  in varchar2   default hr_api.g_varchar2
  ,p_information18                  in varchar2   default hr_api.g_varchar2
  ,p_information19                  in varchar2   default hr_api.g_varchar2
  ,p_information20                  in varchar2   default hr_api.g_varchar2
  ,p_information21                  in varchar2   default hr_api.g_varchar2
  ,p_information22                  in varchar2   default hr_api.g_varchar2
  ,p_information23                  in varchar2   default hr_api.g_varchar2
  ,p_information24                  in varchar2   default hr_api.g_varchar2
  ,p_information25                  in varchar2   default hr_api.g_varchar2
  ,p_information26                  in varchar2   default hr_api.g_varchar2
  ,p_information27                  in varchar2   default hr_api.g_varchar2
  ,p_information28                  in varchar2   default hr_api.g_varchar2
  ,p_information29                  in varchar2   default hr_api.g_varchar2
  ,p_information30                  in varchar2   default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_role >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a workflow role.
 *
 * If a role has routing history it cannot be deleted. If the role is no longer
 * needed it can be disabled instead of being deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The role to be deleted must already exist. The role must not be associated
 * to any user, position or template. The role must not be used as a routing
 * list member. It should not be used as override approver in transaction type
 * setup.
 *
 * <p><b>Post Success</b><br>
 * The role will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The role will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_id Identifies uniquely the role to be deleted.
 * @param p_object_version_number Current version number of the role to be
 * deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Workflow Role
 * @rep:category BUSINESS_ENTITY HR_ROLE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_role
  (
   p_validate                       in boolean        default false
  ,p_role_id                        in  number
  ,p_object_version_number          in number
  ,p_effective_date            in date
  );
--
--
end pqh_roles_api;

 

/
