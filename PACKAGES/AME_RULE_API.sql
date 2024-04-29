--------------------------------------------------------
--  DDL for Package AME_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULE_API" AUTHID CURRENT_USER as
/* $Header: amrulapi.pkh 120.4 2006/05/05 04:46:56 avarri noship $ */
/*#
 * This package contains the AME Rule APIs.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Rule
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_ame_rule >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a rule and a usage for this rule for the given
 * transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The condition, action, and the application that are used to create a rule
 * should be valid. The condition, action and rule type should be compatible.
 *
 * <p><b>Post Success</b><br>
 * The rule and its usage is created.
 *
 * <p><b>Post Failure</b><br>
 * No rule is created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_rule_key A unique key for the rule.
 * @param p_description The description of the rule.
 * @param p_rule_type The type of the rule. The valid values are defined in
 * the look up AME_RULE_TYPE.
 * @param p_item_class_id This uniquely identifies the item class for which
 * the rule has to be created.
 * @param p_condition_id This uniquely identifies the condition that is used
 * to define the rule. The condition should correspond to the rule type.
 * @param p_action_id This uniquely identifies the action that is used to
 * define the rule. The action should correspond to the rule type.
 * @param p_application_id This uniquely identifies the transaction type
 * for which the rule usage has to be created.
 * @param p_priority The rule priority. This can be used only when
 * Rule Priority Mode is enabled for rule type. Valid values are from
 * 1 to 99999.
 * @param p_approver_category The approver category. The valid values are
 * defined in the look up type AME_APPROVER_CATEGORY.
 * @param p_rul_start_date If p_validate is false, it is set to the start date
 * for the rule definition. If it is set to true, it is set to null.
 * @param p_rul_end_date If p_validate is false, it is set to the end date of
 * the rule definition. If p_validate is true, it is set to null.
 * @param p_rule_id If p_validate is false, it is set to the rule id for
 * the newly created rule. If p_validate is true, it is set to null.
 * @param p_rul_object_version_number If p_validate is false, it is set to the
 * start date of the rule definition. If p_validate is true, it is set to null.
 * @param p_rlu_object_version_number If p_validate is false, it is set to
 * the version number for the rule usage. If p_validate is true,
 * it is set to null.
 * @param p_rlu_start_date If p_validate is false, it is set to the start date
 * for the rule usage. If it is set to true, it is set to null.
 * @param p_rlu_end_date If p_validate is false, it is set to the end date of
 * the rule usage. If p_validate is true, it is set to null.
 * @param p_cnu_object_version_number f p_validate is false, it is set to the
 * version number for the condition usage. If p_validate is true, it is set
 * to null.
 * @param p_cnu_start_date If p_validate is false, it is set to the start date
 * of the condition usage. If p_validate is true, it is set to null.
 * @param p_cnu_end_date If p_validate is false, it is set to the end date of
 * the condition usage. If p_validate is true, it is set to null.
 * @param p_acu_object_version_number If p_validate is false, it is set to the
 * version number for the action usage. If p_validate is true,
 * it is set to null.
 * @param p_acu_start_date If p_validate is false, it is set to the
 * start date of the action usage. If p_validate is true, it is set to null.
 * @param p_acu_end_date If p_validate is false, it is set to the end date
 * of the action usage. If p_validate is true, it is set to null.
 * @rep:displayname Create Ame Rule.
 * @rep:category BUSINESS_ENTITY AME_RULE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_rule
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_rule_key                      in     varchar2
  ,p_description                   in     varchar2
  ,p_rule_type                     in     varchar2
  ,p_item_class_id                 in     number   default null
  ,p_condition_id                  in     number   default null
  ,p_action_id                     in     number   default null
  ,p_application_id                in     number   default null
  ,p_priority                      in     number   default null
  ,p_approver_category             in     varchar2 default null
  ,p_rul_start_date                in out nocopy   date
  ,p_rul_end_date                  in out nocopy   date
  ,p_rule_id                          out nocopy   number
  ,p_rul_object_version_number        out nocopy   number
  ,p_rlu_object_version_number        out nocopy   number
  ,p_rlu_start_date                   out nocopy   date
  ,p_rlu_end_date                     out nocopy   date
  ,p_cnu_object_version_number        out nocopy   number
  ,p_cnu_start_date                   out nocopy   date
  ,p_cnu_end_date                     out nocopy   date
  ,p_acu_object_version_number        out nocopy   number
  ,p_acu_start_date                   out nocopy   date
  ,p_acu_end_date                     out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_ame_rule_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a usage for an existing rule for the given
 * transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The rule and the application should be valid.
 *
 * <p><b>Post Success</b><br>
 * A usage for the rule will be created for the given transaction type.
 *
 * <p><b>Post Failure</b><br>
 * No usage is created and the API will raise an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rule_id This uniquely identifies the rule for which the usage
 * has to be created.
 * @param p_application_id This uniquely identifies the transaction type
 * for which the rule usage has to be created.
 * @param p_priority The rule priority. This can be used only when
 * Rule Priority Mode is enabled for rule type. Valid values are from
 * 1 to 99999.
 * @param p_approver_category The approver category. The valid values are
 * defined in the look up AME_APPROVER_CATEGORY.
 * @param p_start_date If p_validate is false, it is set to the start date of
 * the rule usage. If p_validate is true, it is set to null.
 * @param p_end_date If p_validate is false, it is set to the end date of
 * the rule usage. If p_validate is true, it is set to null.
 * @param p_object_version_number If p_validate is false, it is set to the
 * version number for the rule usage. If p_validate is true, it is set to null.
 * @rep:displayname Create Ame Rule Usage
 * @rep:category BUSINESS_ENTITY AME_RULE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_rule_usage
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_application_id                in     number
  ,p_priority                      in     number   default null
  ,p_approver_category             in     varchar2 default null
  ,p_start_date                    in out nocopy   date
  ,p_end_date                      in out nocopy   date
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_condition_to_rule >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API adds a condition to an existing rule.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The condition and the rule should be valid.
 *
 * <p><b>Post Success</b><br>
 * The condition is added to the given rule.
 *
 * <p><b>Post Failure</b><br>
 * The condition is not added to the rule and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rule_id This uniquely identifies the rule for which the
 * condition usage has to be created.
 * @param p_condition_id This uniquely identifies the condition that has to be
 * added to the rule. The condition should correspond to the rule type.
 * @param p_object_version_number If p_validate is false, it is set to the
 * version number for the condition usage. If p_validate is true,
 * it is set to null.
 * @param p_start_date If p_validate is false, it is set to the start date
 * of the condition usage. If p_validate is true, it is set to null.
 * @param p_end_date If p_validate is false, it is set to the end date of the
 * condition usage. If p_validate is true, it is set to null.
 * @param p_effective_date This parameter is used to pass the effective date
 * from the UI. This parameter is not used when the API is called directly.
 * @rep:displayname Create Ame Condition To Rule
 * @rep:category BUSINESS_ENTITY AME_RULE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_condition_to_rule
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_condition_id                  in     number
  ,p_object_version_number            out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ,p_effective_date                in     date     default  null
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< replace_lm_condition >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API replaces the list modification condition of an existing list
 * modification or substitution rule.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * Both the rule and condition should be valid. The condition should be a
 * list modification condition. The rule type should correspond to the
 * condition.
 *
 * <p><b>Post Success</b><br>
 * The list modification condition associated to the given rule is replaced
 * by the new condition specified.
 *
 * <p><b>Post Failure</b><br>
 * The list modification condition is not replaced and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rule_id This uniquely identifies the rule for which the
 * list modification condition has to be replaced. The rule can either
 * be a list modification or substitution rule.
 * @param p_condition_id This uniquely identifies the new List Modification
 * condition that replaces the existing List Modification condition
 * in the rule.
 * @param p_object_version_number If p_validate is false, it is set to the
 * version number for the condition usage. If p_validate is true, it is
 * set to null.
 * @param p_start_date If p_validate is false, it is set to the start date
 * of the condition usage. If p_validate is true, it is set to null.
 * @param p_end_date If p_validate is false, it is set to the end date
 * of the condition usage. If p_validate is true, it is set to null.
 * @rep:displayname Replace LM Condition
 * @rep:category BUSINESS_ENTITY AME_RULE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure replace_lm_condition
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_condition_id                  in     number
  ,p_object_version_number            out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ame_action_to_rule >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API adds an action to an existing rule.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The action and the rule should be valid.
 *
 * The action's action type should be available for the transaction type
 * containing the rule.
 *
 * <p><b>Post Success</b><br>
 * The action is added to the given rule.
 *
 * <p><b>Post Failure</b><br>
 * The action is not added to the rule and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rule_id This uniquely identifies the rule to which the action
 * has to be added.
 * @param p_action_id This uniquely identifies the action that has to
 * be added to the rule. The action should correspond to the rule type.
 * @param p_object_version_number If p_validate is false, it is set to the
 * version number for the action usage. If p_validate is true,
 * it is set to null.
 * @param p_start_date If p_validate is false, it is set to the start date
 * of the action usage. If p_validate is true, it is set to null.
 * @param p_end_date If p_validate is false, it is set to the end date
 * of the action usage. If p_validate is true, it is set to null.
 * @param p_effective_date This parameter is used to pass the effective date
 * from the UI. This parameter is not used when the API is called directly.
 * @rep:displayname Create Ame Action To Rule
 * @rep:category BUSINESS_ENTITY AME_RULE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_action_to_rule
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_action_id                     in     number
  ,p_object_version_number            out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ,p_effective_date                in     date     default  null
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_ame_rule >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the rule definition.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The rule should be valid.
 *
 * <p><b>Post Success</b><br>
 * The rule is updated.
 *
 * <p><b>Post Failure</b><br>
 * The rule is not updated and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_rule_id This uniquely identifies the rule that has to be updated.
 * @param p_description The description of the rule.
 * @param p_object_version_number Pass in the current version number of the
 * rule to be updated. When the API completes, if p_validate is false,
 * it will be set to the new version number of the updated rule. If
 * p_validate is true, will be set to the same value which was passed in.
 * @param p_start_date If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to the same date, which was passed in.
 * @param p_end_date It is the date up to, which the updated rule is
 * effective. If p_validate is false, it is set to 31-Dec-4712.
 * If p_validate is true, it is set to the same date, which was passed in.
 * @param p_effective_date This parameter is used to pass the effective date
 * from the UI. This parameter is not used when the API is called directly.
 * @rep:displayname Update Ame Rule
 * @rep:category BUSINESS_ENTITY AME_RULE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_ame_rule
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_rule_id                       in     number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                    in out nocopy   date
  ,p_end_date                      in out nocopy   date
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_ame_rule_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the rule usage.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The rule and the rule usage should be valid.
 *
 * <p><b>Post Success</b><br>
 * The rule usage is updated.
 *
 * <p><b>Post Failure</b><br>
 * The rule usage is not updated and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rule_id This uniquely identifies the rule whose usage has to be
 * updated.
 * @param p_application_id This uniquely identifies the transaction type for
 * which the rule usage has to be modified.
 * @param p_priority The rule priority. This can be used only when
 * Rule Priority Mode is enabled for rule type. Valid values are from
 * 1 to 99999.
 * @param p_approver_category The approver category. The valid values are
 * defined in the look up AME_APPROVER_CATEGORY.
 * @param p_old_start_date The start date of the current rule usage.
 * @param p_object_version_number Pass in the current version number of the
 * rule usage to be updated. When the API completes, if p_validate is false,
 * it will be set to the new version number of the updated rule usage. If
 * p_validate is true, will be set to the same value which was passed in.
 * @param p_start_date If p_validate is false, it is set to the start date
 * for the rule usage. If p_validate is true, it is set to null.
 * @param p_end_date It is the date up to, which the updated rule usage is
 * effective. If p_validate is false, it is set to the same date, which is
 * passed in. If p_validate is true, it is set to null.
 * @param p_effective_date This parameter is used to pass the effective date
 * from the UI. This parameter is not used when the API is called directly.
 * @rep:displayname Update Ame Rule Usage
 * @rep:category BUSINESS_ENTITY AME_RULE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_ame_rule_usage
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_application_id                in     number
  ,p_priority                      in     number   default hr_api.g_number
  ,p_approver_category             in     varchar2 default hr_api.g_varchar2
  ,p_old_start_date                in     date
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                    in out nocopy   date
  ,p_end_date                      in out nocopy   date
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_ame_rule_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API removes the rule usage from a given transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The rule usage and the transaction type should be valid.
 *
 * <p><b>Post Success</b><br>
 * The rule usage is removed from the given transaction type.
 *
 * <p><b>Post Failure</b><br>
 * The rule usage is not removed from the given transaction type and
 * an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rule_id This uniquely identifies the rule whose usage has to be
 * deleted.
 * @param p_application_id This uniquely identifies the transaction type from
 * which the rule usage has to be removed.
 * @param p_object_version_number Pass in the current version number of the
 * rule usage to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted rule usage. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_start_date If p_validate is false, it is set to the start date
 * for the rule usage. If p_validate is true, it is set to null.
 * @param p_end_date If p_validate is false, it is set to the end date of the
 * rule usage. If p_validate is true, it is set to null.
 * @rep:displayname Delete Ame Rule Usage
 * @rep:category BUSINESS_ENTITY AME_RULE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_rule_usage
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_application_id                in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                    in out nocopy   date
  ,p_end_date                      in out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ame_rule_condition >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the condition from the rule.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The condition and the rule should be valid. The condition should be
 * associated to the rule.
 *
 * <p><b>Post Success</b><br>
 * The condition usage gets deleted for the rule.
 *
 * <p><b>Post Failure</b><br>
 * The condition usage is not deleted from the rule and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rule_id This uniquely identifies the rule for which the
 * condition usage has to be deleted.
 * @param p_condition_id This uniquely identifies the condition that has to
 * be deleted from the rule.
 * @param p_object_version_number If p_validate is false, it is set to the
 * version number for the condition usage. If p_validate is true,
 * it is set to null.
 * @param p_start_date If p_validate is false, it is set to the start date
 * of the condition usage. If p_validate is true, it is set to null.
 * @param p_end_date If p_validate is false, it is set to the end date of
 * the condition usage. If p_validate is true, it is set to null.
 * @param p_effective_date This parameter is used to pass the effective date
 * from the UI. This parameter is not used when the API is called directly.
 * @rep:displayname Delete Ame Rule Condition
 * @rep:category BUSINESS_ENTITY AME_RULE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_rule_condition
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_condition_id                  in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ,p_effective_date               in     date      default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_ame_rule_action >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an action from a rule.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The action and the rule should be valid. The action should be
 * associated to the rule.
 *
 * <p><b>Post Success</b><br>
 * The action gets deleted from the rule.
 *
 * <p><b>Post Failure</b><br>
 * The action is not deleted from the rule and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rule_id ID (Unique identifier) of the rule for which the
 * action usage has to be deleted.
 * @param p_action_id This uniquely identifies the action that has to be
 * deleted from the rule.
 * @param p_object_version_number If p_validate is false, it is set to the
 * version number for the action usage. If p_validate is true,
 * it is set to null.
 * @param p_start_date If p_validate is false, it is set to the start date
 * of the action usage. If p_validate is true, it is set to null.
 * @param p_end_date If p_validate is false, it is set to the end date of the
 * action usage. If p_validate is true, it is set to null.
 * @param p_effective_date This parameter is used to pass the effective date
 * from the UI. This parameter is not used when the API is called directly.
 * @rep:displayname Delete Ame Rule Action
 * @rep:category BUSINESS_ENTITY AME_RULE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_rule_action
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_action_id                     in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ,p_effective_date               in     date      default null
  );
--
end ame_rule_api;

 

/
