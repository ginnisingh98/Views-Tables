--------------------------------------------------------
--  DDL for Package PQH_RULE_SETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RULE_SETS_API" AUTHID CURRENT_USER as
/* $Header: pqrstapi.pkh 120.2 2005/10/28 17:59:06 deenath noship $ */
/*#
 * This package contains rule set APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rule Set
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_rule_set >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a rule set containing one or more business rules.
 *
 * When creating a new rule set, the user can define the process level of rules
 * in the rule set to display a warning, halt processing, or ignore validation
 * failures. Also, the rule set can be defined at either the global level or
 * business group level or organization hierarchy level or organization level.
 * Business rules configured at the organization level take precedence over
 * those configured at the organization hierarchy/starting organization level.
 * If the application finds no configuration rule for the organization or its
 * organization hierarchy, the application uses the rules associated with the
 * business group. Finding no configured rules, the application uses the global
 * default status of Warning.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group/organization hierarchy/organization for which the rules
 * are to be configured must already exist. The pre-defined rule sets must
 * already exist for referencing in rule category 'Assignment Modification' and
 * 'Budget Preparation'.
 *
 * <p><b>Post Success</b><br>
 * The rule set will be successfully created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The rule set will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id Business group of the record
 * @param p_rule_set_id If p_validate is false, then this uniquely identifies
 * the rule set created. If p_validate is true, then set to null.
 * @param p_rule_set_name Unique rule set name
 * @param p_description Obsolete parameter, do not use.
 * @param p_organization_structure_id {@rep:casecolumn
 * PQH_RULE_SETS.ORGANIZATION_STRUCTURE_ID}
 * @param p_organization_id If the organization hierarchy is specified, then
 * this identifies the starting node of the organization hierarchy to which the
 * business rules in a rule set are applied. If the organization hierarchy is
 * not specified, then this identifies the organization to which the business
 * rule in a rule set are applied.
 * @param p_referenced_rule_set_id {@rep:casecolumn
 * PQH_RULE_SETS.REFERENCED_RULE_SET_ID}
 * @param p_rule_level_cd Identifies the error level of the business rules in
 * the rule set. Valid values are defined by 'PQH_RULE_LEVEL' lookup type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created rule set. If p_validate is true, then the
 * value will be null.
 * @param p_short_name Short name of rule set.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_rule_applicability Identifies whether the rule applies only to
 * over-budgeted entities (Donors) or to under-budgeted entities (Receivers) in
 * a budget reallocation transaction. Valid values are defined by
 * 'PQH_CBR_APPLICABILITY' lookup type.
 * @param p_rule_category Identifies the target system for which the rule is
 * applicable.
 * @param p_starting_organization_id Starting organization for the Organization
 * Hierarchy defined.
 * @param p_seeded_rule_flag Indicates if the rule set was seeded.
 * @param p_status Indicates whether Budget Reallocation rule definition is
 * Complete or Incomplete.
 * @rep:displayname Create Rule Set
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_BUSINESS_RULE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_RULE_SET
(
   p_validate                       in boolean    default false
  ,p_business_group_id              in  number
  ,p_rule_set_id                    out nocopy number
  ,p_rule_set_name                  in  varchar2
  ,p_description		    in  varchar2
  ,p_organization_structure_id      in  number    default null
  ,p_organization_id                in  number    default null
  ,p_referenced_rule_set_id         in  number    default null
  ,p_rule_level_cd                  in  varchar2
  ,p_object_version_number          out nocopy number
  ,p_short_name                     in  varchar2
  ,p_effective_date                 in  date
  ,p_language_code                  in varchar2   default hr_api.userenv_lang
  ,p_rule_applicability		   in varchar2
  ,p_rule_category		   in varchar2
  ,p_starting_organization_id	   in number      default null
  ,p_seeded_rule_flag		   in varchar2	  default 'N'
  ,p_status     		   in varchar2	  default null
 );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_rule_set >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the rule set details.
 *
 * The scope of the rule set and the error level of the business rules can be
 * updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rule set to be updated must already exist. The business
 * group/organization hierarchy/organization for which the rules are to be
 * configured must already exist.
 *
 * <p><b>Post Success</b><br>
 * The rule set is updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The rule set is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id Business group of record
 * @param p_rule_set_id Identifies uniquely the rule set to be modified.
 * @param p_rule_set_name Unique rule set name.
 * @param p_description Obsolete parameter, do not use.
 * @param p_organization_structure_id {@rep:casecolumn
 * PQH_RULE_SETS.ORGANIZATION_STRUCTURE_ID}
 * @param p_organization_id If the organization hierarchy is specified, then
 * this identifies the starting node of the organization hierarchy to which the
 * business rules in a rule set are applied. If the organization hierarchy is
 * not specified, then this identifies the organization to which the business
 * rule in a rule set are applied.
 * @param p_referenced_rule_set_id {@rep:casecolumn
 * PQH_RULE_SETS.REFERENCED_RULE_SET_ID}
 * @param p_rule_level_cd Identifies the error level of the business rules in
 * the rule set. Valid values are defined by 'PQH_RULE_LEVEL' lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * rule set to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated rule set. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_short_name Short name of rule set.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_rule_applicability Identifies whether the rule applies only to
 * over-budgeted entities (Donors) or to under-budgeted entities (Receivers) in
 * a budget reallocation transaction. Valid values are defined by
 * 'PQH_CBR_APPLICABILITY' lookup type.
 * @param p_rule_category Identifies the target system for which the rule is
 * applicable.
 * @param p_starting_organization_id Starting organization for the Organization
 * Hierarchy defined.
 * @param p_seeded_rule_flag Indicates if the rule set was seeded.
 * @param p_status Indicates whether Budget Reallocation rule definition is
 * Complete or Incomplete.
 * @rep:displayname Update Rule Set
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_BUSINESS_RULE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_RULE_SET
  (
   p_validate                       in boolean    default false
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_rule_set_id                    in  number
  ,p_rule_set_name                  in  varchar2  default hr_api.g_varchar2
  ,p_description		    in  varchar2  default hr_api.g_varchar2
  ,p_organization_structure_id      in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_referenced_rule_set_id         in  number    default hr_api.g_number
  ,p_rule_level_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_language_code                  in varchar2   default hr_api.userenv_lang
 ,p_rule_applicability		   in varchar2    default hr_api.g_varchar2
 ,p_rule_category		   in varchar2    default hr_api.g_varchar2
 ,p_starting_organization_id	   in number    default hr_api.g_number
 ,p_seeded_rule_flag		   in varchar2  default hr_api.g_varchar2
 ,p_status       		   in varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_rule_set >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a rule set.
 *
 * The seeded global rule sets cannot be deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rule set to be deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The rule set is deleted successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The rule set is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rule_set_id Identifies uniquely the rule set to be deleted.
 * @param p_object_version_number Current version number of the rule set to be
 * deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Rule Set
 * @rep:category BUSINESS_ENTITY PQH_POS_CTRL_BUSINESS_RULE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_RULE_SET
  (
   p_validate                       in boolean        default false
  ,p_rule_set_id                    in  number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
--
end pqh_RULE_SETS_api;

 

/
