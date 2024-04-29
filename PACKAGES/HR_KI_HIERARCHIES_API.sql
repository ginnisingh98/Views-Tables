--------------------------------------------------------
--  DDL for Package HR_KI_HIERARCHIES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_HIERARCHIES_API" AUTHID CURRENT_USER as
/* $Header: hrhrcapi.pkh 120.1 2005/10/02 02:02:57 aroussel $ */
/*#
 * This package contains APIs that maintain the knowledge integration
 * hierarchies.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Knowledge Integration Hierarchy
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_hierarchy_node >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The API creates a knowledge integration hierarchy node.
 *
 * Hierarchy nodes can be created to group and structure available topics.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid Hierarchy Key, Parent hierarchy Id, Hierarchy Name and Source
 * Language should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration hierarchy node will be successfully inserted into
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration hierarchy node will not be created and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_hierarchy_key Uniquely identifies a hierarchy node via a key.
 * @param p_parent_hierarchy_id The parent hierarchy identifier for this child.
 * @param p_name Name of the hierarchy node.
 * @param p_description Description of the hierarchy node.
 * @param p_hierarchy_id If p_validate is false, then this uniquely identifies
 * the knowledge integration hierarchy been created. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the knowledge integration hierarchy record for the
 * knowledge integration hierarchy record. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Hierarchy Node
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_hierarchy_node
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_hierarchy_key                 in     varchar2
  ,p_parent_hierarchy_id           in     number
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_hierarchy_id                  out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_hierarchy_node >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The API updates a knowledge integration hierarchy node.
 *
 * Hierarchy nodes can be updated to group and structure available topics.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid hierarchy id should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration hierarchy node will be successfully updated into
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration hierarchy node will not be updated and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hierarchy_id Unique identifier of the hierarchy.
 * @param p_language_code Specifies the language to which the translation
 * values apply. You can set to base or any installed language. The default
 * value of hr_api.userenv_lang is equivalent to the RDBMS userenv ('LANG')
 * function value.
 * @param p_parent_hierarchy_id Name of the parent hierarchy.
 * @param p_name Name of the hierarchy node.
 * @param p_description Description of the hierarchy node.
 * @param p_object_version_number Pass in the current version number of the
 * knowledge integration hierarchy to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * hierarchy. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Hierarchy Node
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_hierarchy_node
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_parent_hierarchy_id           in     number   default hr_api.g_number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_hierarchy_id                  in     number
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_hierarchy_node >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The API deletes a knowledge integration hierarchy node.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * Hierarchy id and object version number should be entered.
 *
 * <p><b>Post Success</b><br>
 * The knowledge integration hierarchy node will be successfully deleted from
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The knowledge integration hierarchy node will not be deleted and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hierarchy_id Unique identifier of the hierarchy record.
 * @param p_object_version_number Current version number of the knowledge
 * integration hierarchy node map to be deleted.
 * @rep:displayname Delete Hierarchy Node
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_hierarchy_node
(
 P_VALIDATE                 in boolean         default false
,P_HIERARCHY_ID             in number
,P_OBJECT_VERSION_NUMBER    in number
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_topic_hierarchy_map >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a hierarchy node map for topic and hierarchy.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid Hierarchy id and Topic id should be entered.
 *
 * <p><b>Post Success</b><br>
 * The topic hierarchy map will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The topic hierarchy map will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hierarchy_id Unique identifier of the hierarchy.
 * @param p_topic_id {@rep:casecolumn HR_KI_TOPICS.TOPIC_ID}
 * @param p_hierarchy_node_map_id If p_validate is false, then this uniquely
 * identifies the hierarchy node mapping been created. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the topic hierarchy map record. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Topic Hierarchy Map
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_topic_hierarchy_map
  (p_validate                      in     boolean  default false
  ,p_hierarchy_id                  in     number
  ,p_topic_id                      in     number
  ,p_hierarchy_node_map_id         out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ui_hierarchy_map >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a hierarchy node map for the UI and hierarchy.
 *
 * Stores the relationship between the hierarchy and the UI from which the
 * integration can be launched.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid hierarchy and knowledge integration UI must exist.
 *
 * <p><b>Post Success</b><br>
 * The UI hierarchy map will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The UI hierarchy map will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hierarchy_id {@rep:casecolumn HR_KI_HIERARCHIES.HIERARCHY_ID}
 * @param p_user_interface_id {@rep:casecolumn
 * HR_KI_USER_INTERFACES.USER_INTERFACE_ID}
 * @param p_hierarchy_node_map_id If p_validate is false, then this uniquely
 * identifies the hierarchy node mapping been created. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the UI hierarchy map record. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create User Interface Hierarchy Map
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ui_hierarchy_map
  (p_validate                      in     boolean  default false
  ,p_hierarchy_id                  in     number
  ,p_user_interface_id             in     number
  ,p_hierarchy_node_map_id         out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_topic_ui_map >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a hierarchy node map for the UI and topic.
 *
 * Stores the relationship between the topics and the UI from which the
 * integration can be launched.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid topic must exist.
 *
 * <p><b>Post Success</b><br>
 * The UI and topic map will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The UI and topic map will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_topic_id {@rep:casecolumn HR_KI_TOPICS.TOPIC_ID}
 * @param p_user_interface_id {@rep:casecolumn
 * HR_KI_USER_INTERFACES.USER_INTERFACE_ID}
 * @param p_hierarchy_node_map_id Hierarchy node definition.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the UI and topic map record. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Topic User Interface Map
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_topic_ui_map
  (p_validate                      in     boolean  default false
  ,p_topic_id                      in     number
  ,p_user_interface_id             in     number
  ,p_hierarchy_node_map_id         out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_hierarchy_node_map >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a hierarchy node map.
 *
 * Updates the relationship between the hierarchy and the UI from which the
 * integration can be launched.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid hierarchy map id should be entered.
 *
 * <p><b>Post Success</b><br>
 * The hierarchy map will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The hierarchy map will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hierarchy_id {@rep:casecolumn HR_KI_HIERARCHIES.HIERARCHY_ID}
 * @param p_topic_id {@rep:casecolumn HR_KI_TOPICS.TOPIC_ID}
 * @param p_user_interface_id {@rep:casecolumn
 * HR_KI_USER_INTERFACES.USER_INTERFACE_ID}
 * @param p_hierarchy_node_map_id Unique identifier of the hierarchy map.
 * @param p_object_version_number Pass in the current version number of the
 * hierarchy node map to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated hierarchy node
 * map. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Hierarchy Node Map
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_hierarchy_node_map
  (p_validate                      in     boolean  default false
  ,p_hierarchy_id                  in     number   default hr_api.g_number
  ,p_topic_id                      in     number   default hr_api.g_number
  ,p_user_interface_id             in     number   default hr_api.g_number
  ,p_hierarchy_node_map_id         in     number
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_hierarchy_node_map >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a hierarchy node map.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * Hierarchy node map id and object version number should be entered.
 *
 * <p><b>Post Success</b><br>
 * The hierarchy mapping will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The hierarchy mapping will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hierarchy_node_map_id Unique identifier of the hierarchy map.
 * @param p_object_version_number Current version number of the hierarchy node
 * map to be deleted.
 * @rep:displayname Delete Hierarchy Node Map
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_hierarchy_node_map
(
 P_VALIDATE                 in boolean         default false
,P_HIERARCHY_NODE_MAP_ID    in number
,P_OBJECT_VERSION_NUMBER    in number
);
--
end HR_KI_HIERARCHIES_API;

 

/
