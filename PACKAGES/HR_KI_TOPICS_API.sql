--------------------------------------------------------
--  DDL for Package HR_KI_TOPICS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_TOPICS_API" AUTHID CURRENT_USER as
/* $Header: hrtpcapi.pkh 120.1 2005/10/02 02:06:41 aroussel $ */
/*#
 * This API maintains definitions of the knowledge integration topics used
 * within integrations.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Knowledge Integration -Topic
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_topic >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a knowledge integration topic.
 *
 * The list of topics will be visible from the UI when accessing an
 * integration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid integration must exist.
 *
 * <p><b>Post Success</b><br>
 * The topic definition will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The topic definition will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_topic_key {@rep:casecolumn HR_KI_TOPICS.TOPIC_KEY}
 * @param p_handler The java class file used to handle the topic.
 * @param p_name Name of the topic.
 * @param p_topic_id If p_validate is false, then this uniquely identifies the
 * topic been created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the topic definition record. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Knowledge Integration Topic
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_topic
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_topic_key                     in     varchar2
  ,p_handler                       in     varchar2
  ,p_name                          in     varchar2
  ,p_topic_id                      out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_topic >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a knowledge integration topic.
 *
 * The list of topics will be visible from the UI when accessing an
 * integration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid topic id should be entered
 *
 * <p><b>Post Success</b><br>
 * The topic definition will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The topic definition will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_handler The java class file used to handle the topic.
 * @param p_name Name of the topic.
 * @param p_topic_id Unique internal identifier of the topic record to update.
 * @param p_object_version_number Pass in the current version number of the
 * topic definition to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the topic definition. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Knowledge Integration Topic
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_topic
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_handler                       in     varchar2 default hr_api.g_varchar2
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_topic_id                      in     number
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_topic >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a knowledge integration topic.
 *
 * The list of topics will be visible from the UI when accessing an
 * integration.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid topic id should be entered.
 *
 * <p><b>Post Success</b><br>
 * The topic definition will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The topic definition will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_topic_id Unique internal identifier of the topic record to delete.
 * @param p_object_version_number Current version number of the topic
 * definition to be deleted.
 * @rep:displayname Delete Knowledge Integration Topic
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_topic
(
 P_VALIDATE                 in boolean	 default false
,P_TOPIC_ID           in number
,P_OBJECT_VERSION_NUMBER    in number
);

--
end HR_KI_TOPICS_API;

 

/
