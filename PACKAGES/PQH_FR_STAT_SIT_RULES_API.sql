--------------------------------------------------------
--  DDL for Package PQH_FR_STAT_SIT_RULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_STAT_SIT_RULES_API" AUTHID CURRENT_USER as
/* $Header: pqstrapi.pkh 120.1 2005/10/02 02:28 aroussel $ */
/*#
 * This package contains APIs to validate, create, update and delete statutory
 * situation rules.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Statutory Situation Rule for France
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_stat_situation_rule >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates and creates a statutory situation rule record.
 *
 * Statutory situation is an important employment indicator for civil servants
 * in French Public Sector. The API records the eligibility rule for a
 * statutory situation. The record is created in PQH_FR_STAT_SITUATION_RULES
 * table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A statutory situation rule can be created only for an existing statutory
 * situation.
 *
 * <p><b>Post Success</b><br>
 * A statutory situation rule record is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * A statutory situation rule record is not created in the database and an
 * error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_statutory_situation_id {@rep:casecolumn
 * PQH_FR_STAT_SITUATION_RULES.STATUTORY_SITUATION_ID}
 * @param p_processing_sequence {@rep:casecolumn
 * PQH_FR_STAT_SITUATION_RULES.PROCESSING_SEQUENCE}
 * @param p_txn_category_attribute_id Selected transaction category attribute
 * identifier. Valid transaction category is FR_PQH_STAT_SIT_TXN.
 * @param p_from_value If the category attribute accepts an exact value, then
 * the value should be from the predefined set of values. Otherwise its value
 * must be greater than 0
 * @param p_to_value This value should be provided only if the category
 * attribute accepts a range of values, and must be greater than the from_value
 * @param p_enabled_flag Flag that identifies whether the rule is enabled
 * currently or not
 * @param p_required_flag Flag that identifies whether an employee needs to
 * meet this rule before being eligible to be placed on the corresponding
 * statutory situation.
 * @param p_exclude_flag If set to true, then the employee satisfying this rule
 * will be excluded from being placed on this statutory situation
 * @param p_stat_situation_rule_id The process returns the unique statutory
 * situation identifier generated for the new statutory situation record.
 * @param p_object_version_number If p_validate is false, the process returns
 * the version number of the created statutory situation rule. If p_validate is
 * true, it returns null.
 * @rep:displayname Create Statutory Situation Rule
 * @rep:category BUSINESS_ENTITY PQH_FR_STATUTORY_SITUATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_stat_situation_rule
  (p_validate                      in     boolean  default false
  ,p_effective_date                 in     date    default sysdate
  ,p_statutory_situation_id         in     number
  ,p_processing_sequence            in     number
  ,p_txn_category_attribute_id      in     number
  ,p_from_value                     in     varchar2
  ,p_to_value                       in     varchar2 default null
  ,p_enabled_flag                   in     varchar2 default null
  ,p_required_flag                  in     varchar2 default null
  ,p_exclude_flag                   in     varchar2 default null
  ,p_stat_situation_rule_id            out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_stat_situation_rule >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the record when an existing statutory situation rule is
 * changed and updates the record in the database.
 *
 * Statutory situation is an important employment indicator for civil servants
 * in French Public Sector. The API updates the eligibility rule for a
 * statutory situation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A statutory situation rule must exist with the specified object version
 * number.
 *
 * <p><b>Post Success</b><br>
 * The existing statutory situation rule record is updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The existing statutory situation rule is not changed in the database and an
 * error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_stat_situation_rule_id Statutory situation rule identifier assigned
 * to this record when created as the primary key
 * @param p_object_version_number Passes in the current version number of the
 * statutory situation rule to be updated. When the API completes if p_validate
 * is false, the process returns the new version number of the updated
 * statutory situation rule If p_validate is true, it returns the same value
 * which was passed in
 * @param p_statutory_situation_id {@rep:casecolumn
 * PQH_FR_STAT_SITUATION_RULES.STATUTORY_SITUATION_ID}
 * @param p_processing_sequence {@rep:casecolumn
 * PQH_FR_STAT_SITUATION_RULES.PROCESSING_SEQUENCE}
 * @param p_txn_category_attribute_id Selected transaction category attribute
 * identifier. Valid transaction category is FR_PQH_STAT_SIT_TXN.
 * @param p_from_value If the category attribute accepts an exact value, then
 * the value should be from the predefined set of values. Otherwise its value
 * must be greater than 0
 * @param p_to_value This value should be provided only if the category
 * attribute accepts a range of values, and must be greater than the from_value
 * @param p_enabled_flag Flag that identifies whether the rule is enabled
 * currently or not
 * @param p_required_flag Flag that identifies whether an employee needs to
 * meet this rule before being eligible to be placed on the corresponding
 * statutory situation.
 * @param p_exclude_flag If set to true, then the employee satisfying this rule
 * will be excluded from being placed on this statutory situation
 * @rep:displayname Update Statutory Situation Rule
 * @rep:category BUSINESS_ENTITY PQH_FR_STATUTORY_SITUATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_stat_situation_rule
  (p_validate                      in     boolean  default false
  ,p_effective_date               in     date      default sysdate
  ,p_stat_situation_rule_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_statutory_situation_id       in     number    default hr_api.g_number
  ,p_processing_sequence          in     number    default hr_api.g_number
  ,p_txn_category_attribute_id    in     number    default hr_api.g_number
  ,p_from_value                   in     varchar2  default hr_api.g_varchar2
  ,p_to_value                     in     varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_required_flag                in     varchar2  default hr_api.g_varchar2
  ,p_exclude_flag                 in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_stat_situation_rule >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a statutory situation rule record from the database.
 *
 * The record is deleted from PQH_FR_STAT_SITUATION_RULES table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The statutory situation rule must exist with the specified object version
 * number.
 *
 * <p><b>Post Success</b><br>
 * The statutory situation rule is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The statutory situation rule is not deleted from the database and an error
 * is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_stat_situation_rule_id Statutory situation rule identifier assigned
 * to this record when creation as the primary key
 * @param p_object_version_number Current version number of the statutory
 * situation rule record to be deleted
 * @rep:displayname Delete Statutory Situation Rule
 * @rep:category BUSINESS_ENTITY PQH_FR_STATUTORY_SITUATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_stat_situation_rule
  (p_validate                      in     boolean  default false
  ,p_stat_situation_rule_id               in     number
  ,p_object_version_number                in     number
  );
--

end pqh_fr_stat_sit_rules_api;

 

/
