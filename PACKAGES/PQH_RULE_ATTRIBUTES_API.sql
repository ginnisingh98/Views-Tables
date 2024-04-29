--------------------------------------------------------
--  DDL for Package PQH_RULE_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RULE_ATTRIBUTES_API" AUTHID CURRENT_USER as
/* $Header: pqrlaapi.pkh 120.1 2005/10/02 02:27:26 aroussel $ */
/*#
 * This package contains rule attribute APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rule Attribute
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_rule_attribute >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a rule attribute.
 *
 * The value defined for the attribute selected in the rule will be used for
 * validating budget reallocation transaction attribute values. The API ensures
 * that duplicate rule attributes are not saved for the same rule set,
 * attribute, operation code and attribute values. It also ensures that number
 * value is stored for attributes that are of number data type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The attribute for which the rule is being defined must already exist. The
 * valid list of operation codes must already be defined.
 *
 * <p><b>Post Success</b><br>
 * The rule attribute is created successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The rule attribute is not created and an error is raised.
 * @param p_rule_set_id Identifies the rule set under which the rule attribute
 * is grouped.
 * @param p_attribute_code Identifies the attribute for which the rule is
 * defined.
 * @param p_operation_code Identifies the operator to use for comparing the
 * transaction attribute value to the attribute value defined in the rule.
 * Valid values are defined by 'PQH_CBR_OPERATION_CODE' lookup type.
 * @param p_attribute_value The value for the selected attribute.
 * @param p_rule_attribute_id If p_validate is false, then this uniquely
 * identifies the rule attribute created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created rule attribute. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Rule Attribute
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_BUSINESS_RULE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Insert_Rule_Attribute
  (p_rule_set_id                    in     number
  ,p_attribute_code                 in     varchar2 default null
  ,p_operation_code                 in     varchar2 default null
  ,p_attribute_value                in     varchar2 default null
  ,p_rule_attribute_id                 out nocopy number
  ,p_object_version_number             out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_rule_attribute >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a rule attribute.
 *
 * The API allows updating the value of the attribute for which the rule is
 * defined. It ensures that duplicate rule attributes are not saved for the
 * same rule set, attribute, operation code and attribute values. It also
 * ensures that number value is stored for attributes that are of number data
 * type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rule attribute that is to be updated must already exist. If the
 * operation code is to be changed, then the valid list of operation codes must
 * already be defined.
 *
 * <p><b>Post Success</b><br>
 * The rule attribute is updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The rule attribute is not updated and an error is raised.
 * @param p_rule_attribute_id Identifies uniquely the rule attribute to be
 * modified.
 * @param p_object_version_number Pass in the current version number of the
 * rule attribute to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated rule attribute. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_rule_set_id Identifies the rule set under which the rule attribute
 * is grouped.
 * @param p_attribute_code Identifies the attribute for which the rule is
 * defined.
 * @param p_operation_code Identifies the operator to use for comparing the
 * transaction attribute value to the attribute value defined in the rule.
 * Valid values are defined by 'PQH_CBR_OPERATION_CODE' lookup type.
 * @param p_attribute_value The value for the selected attribute.
 * @rep:displayname Update Rule Attribute
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_BUSINESS_RULE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_Rule_Attribute
  (p_rule_attribute_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_rule_set_id                  in     number    default hr_api.g_number
  ,p_attribute_code               in     varchar2  default hr_api.g_varchar2
  ,p_operation_code               in     varchar2  default hr_api.g_varchar2
  ,p_attribute_value              in     varchar2  default hr_api.g_varchar2
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_rule_attribute >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a rule attribute.
 *
 * Deleting the rule attribute removes the validation that must be performed
 * for that attribute in a budget reallocation transaction.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rule attribute which is to be deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The rule attribute is deleted successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The rule attribute is not deleted and an error is raised.
 * @param p_rule_attribute_id Identifies uniquely the rule attribute to be
 * deleted.
 * @param p_object_version_number Current version number of the rule attribute
 * to be deleted.
 * @rep:displayname Delete Rule Attribute
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_BUSINESS_RULE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure Delete_Rule_Attribute
  (p_rule_attribute_id                    in     number
  ,p_object_version_number                in     number);
--
end  PQH_RULE_ATTRIBUTES_API;

 

/
