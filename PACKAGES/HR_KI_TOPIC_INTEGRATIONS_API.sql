--------------------------------------------------------
--  DDL for Package HR_KI_TOPIC_INTEGRATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_TOPIC_INTEGRATIONS_API" AUTHID CURRENT_USER as
/* $Header: hrtisapi.pkh 120.2 2008/01/25 13:49:50 avarri ship $ */
/*#
 * This package contains APIs that maintain definitions of the knowledge
 * integration topics linked to integrations.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Knowledge Integration - Topic Integration
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_topic_integration_key >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the knowledge integration topic key.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid topic and integration must exist.
 *
 * <p><b>Post Success</b><br>
 * The integration and topic definition will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The integration and topic definition will not be created and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_topic_key {@rep:casecolumn HR_KI_TOPICS.TOPIC_ID}
 * @param p_integration_key {@rep:casecolumn
 * HR_KI_INTEGRATIONS.INTEGRATION_KEY}
 * @param p_param_name1 Parameter1 Name for topic or integration.
 * @param p_param_value1 Parameter1 Value for topic or integration.
 * @param p_param_name2 Parameter2 Name for topic or integration.
 * @param p_param_value2 Parameter2 Value for topic or integration.
 * @param p_param_name3 Parameter3 Name for topic or integration.
 * @param p_param_value3 Parameter3 Value for topic or integration.
 * @param p_param_name4 Parameter4 Name for topic or integration.
 * @param p_param_value4 Parameter4 Value for topic or integration.
 * @param p_param_name5 Parameter5 Name for topic or integration.
 * @param p_param_value5 Parameter5 Value for topic or integration.
 * @param p_param_name6 Parameter6 Name for topic or integration.
 * @param p_param_value6 Parameter6 Value for topic or integration.
 * @param p_param_name7 Parameter7 Name for topic or integration.
 * @param p_param_value7 Parameter7 Value for topic or integration.
 * @param p_param_name8 Parameter8 Name for topic or integration.
 * @param p_param_value8 Parameter8 Value for topic or integration.
 * @param p_param_name9 Parameter9 Name for topic or integration.
 * @param p_param_value9 Parameter9 Value for topic or integration.
 * @param p_param_name10 Parameter10 Name for topic or integration.
 * @param p_param_value10 Parameter10 Value for topic or integration.
 * @param p_topic_integrations_id If p_validate is false, then this uniquely
 * identifies the topic integration been created. If p_validate is true, then
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the integration and topic key definition record. If
 * p_validate is true, then the value will be null.
 * @rep:displayname Create Topic Integration Key
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_topic_integration_key
  (
   p_validate                      in     boolean  default false
  ,p_topic_key                     in     varchar2
  ,p_integration_key               in     varchar2
  ,p_param_name1                   in     varchar2 default null
  ,p_param_value1                  in     varchar2 default null
  ,p_param_name2                   in     varchar2 default null
  ,p_param_value2                  in     varchar2 default null
  ,p_param_name3                   in     varchar2 default null
  ,p_param_value3                  in     varchar2 default null
  ,p_param_name4                   in     varchar2 default null
  ,p_param_value4                  in     varchar2 default null
  ,p_param_name5                   in     varchar2 default null
  ,p_param_value5                  in     varchar2 default null
  ,p_param_name6                   in     varchar2 default null
  ,p_param_value6                  in     varchar2 default null
  ,p_param_name7                   in     varchar2 default null
  ,p_param_value7                  in     varchar2 default null
  ,p_param_name8                   in     varchar2 default null
  ,p_param_value8                  in     varchar2 default null
  ,p_param_name9                   in     varchar2 default null
  ,p_param_value9                  in     varchar2 default null
  ,p_param_name10                  in     varchar2 default null
  ,p_param_value10                 in     varchar2 default null
  ,p_topic_integrations_id         out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_topic_integration >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a knowledge integration topic mapping.
 *
 * This information defines the link between an integration and a topic.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid topic and integration must exist.
 *
 * <p><b>Post Success</b><br>
 * The integration and topic definition will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The integration and topic definition will not be created and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_topic_id {@rep:casecolumn HR_KI_TOPICS.TOPIC_ID}
 * @param p_integration_id {@rep:casecolumn HR_KI_INTEGRATIONS.INTEGRATION_ID}
 * @param p_param_name1 Parameter1 Name for topic or integration.
 * @param p_param_value1 Parameter1 Value for topic or integration.
 * @param p_param_name2 Parameter2 Name for topic or integration.
 * @param p_param_value2 Parameter2 Value for topic or integration.
 * @param p_param_name3 Parameter3 Name for topic or integration.
 * @param p_param_value3 Parameter3 Value for topic or integration.
 * @param p_param_name4 Parameter4 Name for topic or integration.
 * @param p_param_value4 Parameter4 Value for topic or integration.
 * @param p_param_name5 Parameter5 Name for topic or integration.
 * @param p_param_value5 Parameter5 Value for topic or integration.
 * @param p_param_name6 Parameter6 Name for topic or integration.
 * @param p_param_value6 Parameter6 Value for topic or integration.
 * @param p_param_name7 Parameter7 Name for topic or integration.
 * @param p_param_value7 Parameter7 Value for topic or integration.
 * @param p_param_name8 Parameter8 Name for topic or integration.
 * @param p_param_value8 Parameter8 Value for topic or integration.
 * @param p_param_name9 Parameter9 Name for topic or integration.
 * @param p_param_value9 Parameter9 Value for topic or integration.
 * @param p_param_name10 Parameter10 Name for topic or integration.
 * @param p_param_value10 Parameter10 Value for topic or integration.
 * @param p_topic_integrations_id If p_validate is false, then this uniquely
 * identifies the topic integration been created. If p_validate is true, then
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the integration and topic definition record. If p_validate
 * is true, then the value will be null.
 * @rep:displayname Create Topic Integration
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_topic_integration
  (
   p_validate                      in     boolean  default false
  ,p_topic_id                      in     number
  ,p_integration_id                in     number
  ,p_param_name1                   in     varchar2 default null
  ,p_param_value1                  in     varchar2 default null
  ,p_param_name2                   in     varchar2 default null
  ,p_param_value2                  in     varchar2 default null
  ,p_param_name3                   in     varchar2 default null
  ,p_param_value3                  in     varchar2 default null
  ,p_param_name4                   in     varchar2 default null
  ,p_param_value4                  in     varchar2 default null
  ,p_param_name5                   in     varchar2 default null
  ,p_param_value5                  in     varchar2 default null
  ,p_param_name6                   in     varchar2 default null
  ,p_param_value6                  in     varchar2 default null
  ,p_param_name7                   in     varchar2 default null
  ,p_param_value7                  in     varchar2 default null
  ,p_param_name8                   in     varchar2 default null
  ,p_param_value8                  in     varchar2 default null
  ,p_param_name9                   in     varchar2 default null
  ,p_param_value9                  in     varchar2 default null
  ,p_param_name10                  in     varchar2 default null
  ,p_param_value10                 in     varchar2 default null
  ,p_topic_integrations_id         out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_topic_integration_key >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the knowledge integration topic key.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid topic and integration must exist.
 *
 * <p><b>Post Success</b><br>
 * The integration and topic key definition will be successfully updated into
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The integration and topic key definition will not be updated and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_topic_integrations_id Unique internal identifier for the record.
 * @param p_topic_key {@rep:casecolumn HR_KI_TOPICS.TOPIC_ID}
 * @param p_integration_key {@rep:casecolumn
 * HR_KI_INTEGRATIONS.INTEGRATION_KEY}
 * @param p_param_name1 Parameter1 Name for topic or integration.
 * @param p_param_value1 Parameter1 Value for topic or integration.
 * @param p_param_name2 Parameter2 Name for topic or integration.
 * @param p_param_value2 Parameter2 Value for topic or integration.
 * @param p_param_name3 Parameter3 Name for topic or integration.
 * @param p_param_value3 Parameter3 Value for topic or integration.
 * @param p_param_name4 Parameter4 Name for topic or integration.
 * @param p_param_value4 Parameter4 Value for topic or integration.
 * @param p_param_name5 Parameter5 Name for topic or integration.
 * @param p_param_value5 Parameter5 Value for topic or integration.
 * @param p_param_name6 Parameter6 Name for topic or integration.
 * @param p_param_value6 Parameter6 Value for topic or integration.
 * @param p_param_name7 Parameter7 Name for topic or integration.
 * @param p_param_value7 Parameter7 Value for topic or integration.
 * @param p_param_name8 Parameter8 Name for topic or integration.
 * @param p_param_value8 Parameter8 Value for topic or integration.
 * @param p_param_name9 Parameter9 Name for topic or integration.
 * @param p_param_value9 Parameter9 Value for topic or integration.
 * @param p_param_name10 Parameter10 Name for topic or integration.
 * @param p_param_value10 Parameter10 Value for topic or integration.
 * @param p_object_version_number Pass in the current version number of the
 * integration and topic key definition to be updated. When the API completes
 * if p_validate is false, will be set to the new version number of the updated
 * integration and topic key definition. If p_validate is true will be set to
 * the same value which was passed in.
 * @rep:displayname Update Topic Integration Key
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_topic_integration_key
  (
   p_validate                      in     boolean  default false
  ,p_topic_integrations_id         in     number
  ,p_topic_key                     in     varchar2 default hr_api.g_varchar2
  ,p_integration_key               in     varchar2 default hr_api.g_varchar2
  ,p_param_name1                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value1                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name2                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value2                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name3                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value3                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name4                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value4                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name5                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value5                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name6                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value6                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name7                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value7                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name8                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value8                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name9                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value9                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name10                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value10                 in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_topic_integration >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a knowledge integration topic mapping.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid topic_integrations_id should be entered.
 *
 * <p><b>Post Success</b><br>
 * The integration and topic definition will be successfully updated into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The integration and topic definition will not be updated and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_topic_integrations_id Unique internal identifier for the record.
 * @param p_topic_id {@rep:casecolumn HR_KI_TOPICS.TOPIC_ID}
 * @param p_integration_id {@rep:casecolumn HR_KI_INTEGRATIONS.INTEGRATION_ID}
 * @param p_param_name1 Parameter1 Name for topic or integration.
 * @param p_param_value1 Parameter1 Value for topic or integration.
 * @param p_param_name2 Parameter2 Name for topic or integration.
 * @param p_param_value2 Parameter2 Value for topic or integration.
 * @param p_param_name3 Parameter3 Name for topic or integration.
 * @param p_param_value3 Parameter3 Value for topic or integration.
 * @param p_param_name4 Parameter4 Name for topic or integration.
 * @param p_param_value4 Parameter4 Value for topic or integration.
 * @param p_param_name5 Parameter5 Name for topic or integration.
 * @param p_param_value5 Parameter5 Value for topic or integration.
 * @param p_param_name6 Parameter6 Name for topic or integration.
 * @param p_param_value6 Parameter6 Value for topic or integration.
 * @param p_param_name7 Parameter7 Name for topic or integration.
 * @param p_param_value7 Parameter7 Value for topic or integration.
 * @param p_param_name8 Parameter8 Name for topic or integration.
 * @param p_param_value8 Parameter8 Value for topic or integration.
 * @param p_param_name9 Parameter9 Name for topic or integration.
 * @param p_param_value9 Parameter9 Value for topic or integration.
 * @param p_param_name10 Parameter10 Name for topic or integration.
 * @param p_param_value10 Parameter10 Value for topic or integration.
 * @param p_object_version_number Pass in the current version number of the
 * integration and topic definition to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * integration and topic definition. If p_validate is true will be set to the
 * same value which was passed in.
 * @rep:displayname Update Topic Integration
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_topic_integration
  (
   p_validate                      in     boolean  default false
  ,p_topic_integrations_id         in     number
  ,p_topic_id                      in     number default hr_api.g_number
  ,p_integration_id                in     number default hr_api.g_number
  ,p_param_name1                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value1                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name2                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value2                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name3                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value3                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name4                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value4                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name5                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value5                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name6                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value6                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name7                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value7                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name8                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value8                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name9                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value9                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name10                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value10                 in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_topic_integration >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a knowledge integration topic mapping.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * Enter topic integrations id and object version numbers.
 *
 * <p><b>Post Success</b><br>
 * The integration and topic definition will be successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The integration and topic definition will not be deleted and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_topic_integrations_id Unique internal identifier for the record.
 * @param p_object_version_number Current version number of the integration and
 * topic mapping definition to be deleted.
 * @rep:displayname Delete Topic Integration
 * @rep:category BUSINESS_ENTITY HR_KI_MAP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_topic_integration
(
 P_VALIDATE                 in boolean         default false
,P_TOPIC_INTEGRATIONS_ID    in number
,P_OBJECT_VERSION_NUMBER    in number
);
--
end HR_KI_TOPIC_INTEGRATIONS_API;

/
