--------------------------------------------------------
--  DDL for Package HR_KI_OPTION_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_OPTION_TYPES_API" AUTHID CURRENT_USER as
/* $Header: hrotyapi.pkh 120.1 2005/10/02 02:05:08 aroussel $ */
/*#
 * This package contains APIs to maintain knowledge integration option types.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Knowledge Integration Option Type
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_option_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a knowledge integration option type.
 *
 * Creates a list of available option types with information to describe how
 * they are displayed in the UI.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid option types of Key, Display Type, Option Name and Source Language,
 * should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration option type definition will be successfully
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration option type definition will not be created and an
 * error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_option_type_key Unique key to identify the record.
 * @param p_display_type The display name that will be visible in the UI.
 * @param p_option_name Name of the option type to be created.
 * @param p_option_type_id If p_validate is false, then this uniquely
 * identifies the option type been created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the option type definition record. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Knowledge Integration Option Type
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_option_type
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_option_type_key               in     varchar2
  ,p_display_type                  in     varchar2
  ,p_option_name                   in     varchar2
  ,p_option_type_id                out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_option_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a knowledge integration option type.
 *
 * Updates a list of available option types with information to describe how
 * they are displayed in the UI.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid option_type_id should be entered
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration option type definition will be successfully
 * updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration option type definition will not be updated and an
 * error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_display_type The display name that will be visible in the UI.
 * @param p_option_name Name of the option type to be updated.
 * @param p_option_type_id Unique internal identifier for the record to be
 * updated.
 * @param p_object_version_number Pass in the current version number of the
 * option type definition to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated option type
 * definition. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Knowledge Integration Option Type
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_option_type
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_display_type                  in     varchar2 default hr_api.g_varchar2
  ,p_option_name                   in     varchar2 default hr_api.g_varchar2
  ,p_option_type_id                in     number
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_option_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a knowledge integration option type.
 *
 * Deletes a list of available option types with information to describe how
 * they are displayed in the UI.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * Option type id and object version number should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration option type definition will be successfully
 * deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration option type definition will not be deleted and an
 * error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_option_type_id Unique internal identifier for the record to be
 * deleted.
 * @param p_object_version_number Current version number of the option type
 * definition to be deleted.
 * @rep:displayname Delete Knowledge Integration Option Type
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_option_type
(
 p_validate                 in boolean         default false
,p_option_type_id           in number
,p_object_version_number    in number
);
--
end HR_KI_OPTION_TYPES_API;

 

/
