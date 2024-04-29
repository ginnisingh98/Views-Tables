--------------------------------------------------------
--  DDL for Package AME_CONFIG_VAR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONFIG_VAR_API" AUTHID CURRENT_USER as
/* $Header: amcfvapi.pkh 120.3 2006/12/23 09:58:54 avarri noship $ */
/*#
 * This package contains AME configuration variable APIs.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Configuration Variable
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_ame_config_variable >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API updates the configuration variable for the specified
 * transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The transaction type should be valid.
 *
 * <p><b>Post Success</b><br>
 * Configuration variable is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The configuration variable is not updated and error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_APPLICATION_ID This uniquely identifies the transaction type for
 * which configuration variable is to be updated.
 * @param P_VARIABLE_NAME Name of the configuration variable.
 * @param P_VARIABLE_VALUE The value for the configuration variable.
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number of the
 * configuration variable to be updated. When the API completes, if p_validate
 * is false, it will be set to the new version number of the updated
 * configuration variable. If p_validate is true, will be set to the same value
 * which was passed in.
 * @param P_START_DATE Date from which the updated configuration variable is
 * effective, set to p_effective_date.
 * @param P_END_DATE It is the date up to, which the configuration variable
 * is effective. If p_validate is false, then it is set to 31-Dec-4712.
 * If p_validate is true, then it is set to null.
 * @rep:displayname Update Ame configuration Variable
 * @rep:category BUSINESS_ENTITY AME_CONFIG_VAR
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_ame_config_variable
  (p_validate                    in     boolean   default false
  ,p_application_id              in     number
  ,p_variable_name               in     varchar2
  ,p_variable_value              in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number       in out nocopy    number
  ,p_start_date                     out nocopy    date
  ,p_end_date                       out nocopy    date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< delete_ame_config_variable >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API deletes the configuration variable for the specified
 * transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The transaction type should be valid.
 *
 * <p><b>Post Success</b><br>
 * The configuration variable is deleted from the given transaction type.
 *
 * <p><b>Post Failure</b><br>
 * The configuration variable is not deleted and error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_APPLICATION_ID This uniquely identifies the transaction type for
 * which configuration variable is to be deleted.
 * @param P_VARIABLE_NAME Name of the configuration variable.
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number of the
 * configuration variable to be deleted. When the API completes, if p_validate
 * is false, it will be set to the new version number of the deleted
 * configuration variable. If p_validate is true, will be set to the same value
 * which was passed in.
 * @param P_START_DATE If p_validate is false, it is set to the date from
 * which the deleted configuration variable was effective. If p_validate
 * is true, it is set to the same date which was passed in.
 * @param P_END_DATE If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to the same date which was passed in.
 * @rep:displayname Deletes Ame configuration variable
 * @rep:category BUSINESS_ENTITY AME_CONFIG_VAR
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_config_variable
                         (p_validate              in     boolean  default false
                         ,p_application_id        in     number
                         ,p_variable_name         in     varchar2
                         ,p_object_version_number in out nocopy   number
                         ,p_start_date               out nocopy   date
                         ,p_end_date                 out nocopy   date
                         );
--
end AME_CONFIG_VAR_API;

/
