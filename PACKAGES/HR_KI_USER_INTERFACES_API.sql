--------------------------------------------------------
--  DDL for Package HR_KI_USER_INTERFACES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_USER_INTERFACES_API" AUTHID CURRENT_USER as
/* $Header: hritfapi.pkh 120.1 2005/10/02 02:03:16 aroussel $ */
/*#
 * This package contains APIs that maintain definition for the HR Knowledge
 * Integration User Interfaces.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Knowledge Integration User Interface
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_user_interface >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a user interface for knowledge integration mappings.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid type, form name or page region code and region code must exist.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration user interface definition will be successfully
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration user interface definition will not be created and
 * an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_type Type of user interface. Valid values are PUI, SS and P. PUI =
 * Forms, SS=Self Service, P=Portal
 * @param p_form_name Form name if the type is PUI.
 * @param p_page_region_code Page region code of the self service page if the
 * type is SS.
 * @param p_region_code Region code of the self service page if the type is SS.
 * @param p_user_interface_id If p_validate is false, then this uniquely
 * identifies the user interface been created. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the user interface definition record. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create User Interface
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_user_interface
  (
   p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_type                          in     varchar2
  ,p_form_name                     in     varchar2 default null
  ,p_page_region_code              in     varchar2 default null
  ,p_region_code                   in     varchar2 default null
  ,p_user_interface_id             out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_user_interface >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a user interface for knowledge integration mappings.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid user interface id should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration user interface definition will be successfully
 * updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration user interface definition will not be updated and
 * an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_user_interface_id Uniquely identifies the user interface definition
 * record.
 * @param p_type Type of user interface. Valid values are PUI, SS and P. PUI =
 * Forms, SS=Self Service, P=Portal
 * @param p_form_name Form name if the type is PUI.
 * @param p_page_region_code Page region code of the self service page if the
 * type is SS.
 * @param p_region_code Region code of the self service page if the type is SS.
 * @param p_object_version_number Pass in the current version number of the
 * user interface definition to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * user interface definition. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update User Interface
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_user_interface
  (
   p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_user_interface_id             in     number
  ,p_type                          in     varchar2 default hr_api.g_varchar2
  ,p_form_name                     in     varchar2 default hr_api.g_varchar2
  ,p_page_region_code              in     varchar2 default hr_api.g_varchar2
  ,p_region_code                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_user_interface >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a user interface for knowledge integration mappings.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * User interface id and object version number should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration user interface definition will be successfully
 * deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration user interface definition will not be deleted and
 * an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_user_interface_id Uniquely identifies the user interface definition
 * record.
 * @param p_object_version_number Current version number of the user interface
 * to be deleted.
 * @rep:displayname Delete User Interface
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_user_interface
(
 P_VALIDATE                 in boolean	 default false
,P_USER_INTERFACE_ID        in number
,P_OBJECT_VERSION_NUMBER    in number
);
--
end HR_KI_USER_INTERFACES_API;

 

/
