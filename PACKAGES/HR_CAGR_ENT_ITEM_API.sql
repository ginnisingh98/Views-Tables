--------------------------------------------------------
--  DDL for Package HR_CAGR_ENT_ITEM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_ENT_ITEM_API" AUTHID CURRENT_USER as
/* $Header: peceiapi.pkh 120.2 2006/10/18 08:49:35 grreddy noship $ */
/*#
 * This package contains APIs that maintain collective agreement entitlement
 * items.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Collective Agreement Entitlement Item
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_cagr_entitlement_item >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a collective agreement entitlement item.
 *
 * An entitlement item is a basic unit of a collective agreement relating to a
 * specific term of employment that employees receive. For example, the Normal
 * Working Hours entitlement item holds meta-data that describes working hours
 * as a term of employment on the assignment. A collective agreement is likely
 * to comprise of many different entitlement items, grouped into categories, to
 * represent its varied terms. An entitlement item may be used in one or more
 * collective agreements.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * An entitlement item record will be created.
 *
 * <p><b>Post Failure</b><br>
 * The entitlement item record will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_business_group_id The business group of the record.
 * @param p_item_name The Name of the Entitlement Item (in the language
 * specified by the language_code parameter).
 * @param p_element_type_id The element type to which this item corresponds, if
 * the item is of category 'Payroll'.
 * @param p_input_value_id The input value to which this item corresponds, if
 * the item is of category 'Payroll'.
 * @param p_column_type The data type of the entitlement item. Valid values are
 * defined by the 'CAGR_PARAM_TYPES' lookup type.
 * @param p_column_size The maximum size of the entitlement item, for the
 * column type (data type).
 * @param p_legislation_code The legislation code of the entitlement item.
 * @param p_beneficial_rule The beneficial rule for the entitlement item. Valid
 * values are defined by the 'CAGR_BENEFICIAL_RULE' lookup type.
 * @param p_cagr_api_param_id The API parameter that will be used to propagate
 * the entitlement item's value during collective agreement processing.
 * @param p_category_name The category of the entitlement item. Valid values
 * are defined by the 'CAGR_CATEGORIES' lookup type.
 * @param p_beneficial_formula_id The fast formula to be used to determine the
 * beneficial rule.
 * @param p_uom The unit of measure the entitlement item value is expressed in.
 * Valid values are defined by the 'UNITS' lookup type.
 * @param p_flex_value_set_id The value set supplying values for the
 * entitlement item.
 * @param p_ben_rule_value_set_id The value set determining the beneficial
 * rule.
 * @param p_mult_entries_allowed_flag Indicates whether more than one element
 * entry may be modified for the element type parameter, during collective
 * agreement processing.
 * @param p_auto_create_entries_flag Indicates whether an element entry should
 * be created for the element type parameter, where one does not already exist,
 * during collective agreement processing.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created entitlement item. If p_validate is true, then
 * the value will be null.
 * @param p_cagr_entitlement_item_id If p_validate is false, then this uniquely
 * identifies the entitlement item created. If p_validate is true, then set to
 * null.
 * @param p_opt_id If p_validate is false, then this uniquely identifies the
 * option compensation object created. If p_validate is true, then set to null.
 * @rep:displayname Create Collective Agreement Entitlement Item
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT_ITEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cagr_entitlement_item
  (p_validate                       in     boolean   default false
  ,p_effective_date                 in     date
  ,p_language_code                  IN     varchar2  default hr_api.userenv_lang
  ,p_business_group_id              in     number    default null
  ,p_item_name                      in     varchar2
  ,p_element_type_id                in     number    default null
  ,p_input_value_id                 in     varchar2  default null
  ,p_column_type                    in     varchar2
  ,p_column_size                    in     number    default 2000
  ,p_legislation_code               in     varchar2  default null
  ,p_beneficial_rule                in     varchar2  default null
  ,p_cagr_api_param_id              in     number    default null
  ,p_category_name                  in     varchar2
  ,p_beneficial_formula_id          in     number    default null
  ,p_uom                            in     varchar2
  ,p_flex_value_set_id              in     number    default null
  ,p_ben_rule_value_set_id	        in     number    default null
  ,p_mult_entries_allowed_flag      in     varchar2  default null
  ,p_auto_create_entries_flag       in     varchar2  default null -- CEI Enh
  ,p_object_version_number             out nocopy number
  ,p_cagr_entitlement_item_id          out nocopy number
  ,p_opt_id                            out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_cagr_entitlement_item >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a collective agreement entitlement item.
 *
 * An entitlement item is a basic unit of a collective agreement relating to a
 * specific term of employment that employees receive. For example, the Normal
 * Working Hours entitlement item holds meta-data that describes working hours
 * as a term of employment on the assignment. A collective agreement is likely
 * to comprise of many different entitlement items, grouped into categories, to
 * represent its varied terms. An entitlement item may be used in one or more
 * collective agreements.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The entitlement item record to be updated must exist.
 *
 * <p><b>Post Success</b><br>
 * An entitlement item record will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The entitlement item record will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_cagr_entitlement_item_id This uniquely identifies the entitlement
 * item to be updated.
 * @param p_business_group_id The business group of the record.
 * @param p_item_name The Name of the Entitlement Item (in the language
 * specified by the language_code parameter).
 * @param p_element_type_id The element type to which this item corresponds, if
 * the item is of category 'Payroll'.
 * @param p_input_value_id The input value to which this item corresponds, if
 * the item is of category 'Payroll'.
 * @param p_column_type The data type of the entitlement item. Valid values are
 * defined by the 'CAGR_PARAM_TYPES' lookup type.
 * @param p_column_size The maximum size of the entitlement item, for the
 * column type (data type).
 * @param p_legislation_code The legislation code of the entitlement item.
 * @param p_beneficial_rule The beneficial rule for the entitlement item. Valid
 * values are defined by the 'CAGR_BENEFICIAL_RULE' lookup type.
 * @param p_cagr_api_param_id The API parameter that will be used to propagate
 * the entitlement item's value during collective agreement processing.
 * @param p_category_name The category of the entitlement item. Valid values
 * are defined by the 'CAGR_CATEGORIES' lookup type.
 * @param p_beneficial_formula_id The fast formula to be used to determine the
 * beneficial rule.
 * @param p_uom The unit of measure the entitlement item value is expressed in.
 * Valid values are defined by the 'UNITS' lookup type.
 * @param p_flex_value_set_id The value set supplying values for the
 * entitlement item.
 * @param p_ben_rule_value_set_id The value set determining the beneficial
 * rule.
 * @param p_mult_entries_allowed_flag Indicates whether more than one element
 * entry may be modified for the element type parameter, during collective
 * agreement processing.
 * @param p_object_version_number Pass in the current version number of the
 * entitlement item to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated person. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Collective Agreement Entitlement Item
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT_ITEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_cagr_entitlement_item
  (p_validate                       in     boolean    default false
  ,p_effective_date                 in     date
  ,p_language_code                  in     varchar2  default hr_api.userenv_lang
  ,p_cagr_entitlement_item_id       in     number    default hr_api.g_number
  ,p_business_group_id              in     number    default hr_api.g_number
  ,p_item_name                      in     varchar2  default hr_api.g_varchar2
  ,p_element_type_id                in     number    default hr_api.g_number
  ,p_input_value_id                 in     varchar2  default hr_api.g_varchar2
  ,p_column_type                    in     varchar2  default hr_api.g_varchar2
  ,p_column_size                    in     number    default hr_api.g_number
  ,p_legislation_code               in     varchar2  default hr_api.g_varchar2
  ,p_beneficial_rule                in     varchar2  default hr_api.g_varchar2
  ,p_cagr_api_param_id              in     number    default hr_api.g_number
  ,p_category_name                  in     varchar2  default hr_api.g_varchar2
  ,p_beneficial_formula_id          in     number    default hr_api.g_number
  ,p_uom                            in     varchar2  default hr_api.g_varchar2
  ,p_flex_value_set_id              in     number    default hr_api.g_number
  ,p_ben_rule_value_set_id	        in     number    default hr_api.g_number
  ,p_mult_entries_allowed_flag      in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_cagr_entitlement_item >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a collective agreement entitlement item.
 *
 * An entitlement item is a basic unit of a collective agreement relating to a
 * specific term of employment that employees receive. For example, the Normal
 * Working Hours entitlement item holds meta-data that describes working hours
 * as a term of employment on the assignment. A collective agreement is likely
 * to comprise of many different entitlement items, grouped into categories, to
 * represent its varied terms. An entitlement item may be used in one or more
 * collective agreements.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The entitlement item must exist.
 *
 * <p><b>Post Success</b><br>
 * The entitlement item record will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The entitlement item record will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cagr_entitlement_item_id This uniquely identifies the entitlement
 * item to be deleted.
 * @param p_object_version_number Current object version number of the
 * entitlement item to be deleted.
 * @rep:displayname Delete Collective Agreement Entitlement Item
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT_ITEM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_cagr_entitlement_item
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_cagr_entitlement_item_id       in     number
  ,p_object_version_number          in out nocopy number
  );
--
end hr_cagr_ent_item_api;

/
