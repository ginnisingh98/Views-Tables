--------------------------------------------------------
--  DDL for Package HR_KI_OPTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_OPTIONS_API" AUTHID CURRENT_USER as
/* $Header: hroptapi.pkh 120.1 2005/10/02 02:04:45 aroussel $ */
/*#
 * This package contains APIs to maintain the knowledge integration privilege
 * options.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Knowledge Integration Option
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_option >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a knowledge integration accessibility option.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid Option Type Key, Display Type, Option Name and Source Language
 * should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration options definition will be successfully inserted
 * into the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration options definition will not be created and an
 * error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_option_type_id {@rep:casecolumn HR_KI_OPTION_TYPES.OPTION_TYPE_ID}
 * @param p_option_level The level at which authentication can be set. Valid
 * values are 100 (Site), 80 (Application), 60 (Responsibility) and 20 (User).
 * @param p_option_level_id Identifies the level value for example user_id for
 * a user, responsibility_id for a responsibility.
 * @param p_value Value of the knowledge integration system option.
 * @param p_encrypted Flag to indicate if the option value is encrypted or not.
 * Valid values are Y or N.
 * @param p_integration_id {@rep:casecolumn HR_KI_INTEGRATIONS.INTEGRATION_ID}
 * @param p_option_id If p_validate is false, then this uniquely identifies the
 * user option been created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the options definition record. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Knowledge Integration Option
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_option
  (
   p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_option_type_id                in     number
  ,p_option_level                  in     number
  ,p_option_level_id               in     varchar2 default null
  ,p_value                         in     varchar2 default null
  ,p_encrypted                     in     varchar2 default 'N'
  ,p_integration_id                in     number
  ,p_option_id                     out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_option >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a knowledge integration accessibility option.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid option id should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration options definition will be successfully updated
 * into the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration options definition will not be updated and an
 * error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_option_id Uniquely identifies the options record.
 * @param p_value Value of the knowledge integration system option.
 * @param p_encrypted Flag to indicate if the option value is encrypted or not.
 * Valid values are Y or N.
 * @param p_object_version_number Pass in the current version number of the
 * options definition to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated options
 * definition. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Knowledge Integration Option
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_option
  (
   p_validate                      in     boolean  default false
  ,p_option_id                     in     number
  ,p_value                         in     varchar2 default hr_api.g_varchar2
  ,p_encrypted                     in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_option >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a knowledge integration accessibility option.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * Option id and object version number should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration options definition will be successfully deleted
 * from the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration options definition will not be deleted and an
 * error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_option_id Uniquely identifies the options record.
 * @param p_object_version_number Current version number of the options
 * definition to be deleted.
 * @rep:displayname Delete Knowledge Integration Option
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_option
(
 P_VALIDATE                 in boolean         default false
,P_OPTION_ID                in number
,P_OBJECT_VERSION_NUMBER    in number
);
--
end HR_KI_OPTIONS_API;

 

/
