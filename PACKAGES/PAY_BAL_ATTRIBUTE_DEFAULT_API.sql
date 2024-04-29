--------------------------------------------------------
--  DDL for Package PAY_BAL_ATTRIBUTE_DEFAULT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BAL_ATTRIBUTE_DEFAULT_API" AUTHID CURRENT_USER as
/* $Header: pypbdapi.pkh 120.1 2005/10/02 02:32:32 aroussel $ */
/*#
 * This package creates the pay balance attribute default.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Balance Attribute Default
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_bal_attribute_default >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the balance attribute default.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Requires a valid business group to be exist. Also requires balance category,
 * balance dimension and balance attribute.
 *
 * <p><b>Post Success</b><br>
 * The balance attribute definition will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the balance attribute default and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_balance_category_id Foreign key to PAY_BALANCE_CATEGORIES
 * @param p_balance_dimension_id Foreign key to PAY_BALANCE_DIMENSIONS
 * @param p_attribute_id Foreign key to PAY_BAL_ATTRIBUTE_DEFINITIONS
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_bal_attribute_default_id If p_validate is false, this uniquely
 * identifies the balance attribute default created. If p_validate is set to
 * true, this parameter will be null.
 * @rep:displayname Create Balance Attribute Default
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_bal_attribute_default
  (p_validate                      in     boolean  default false
  ,p_balance_category_id           in     number
  ,p_balance_dimension_id          in     number
  ,p_attribute_id                  in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_bal_attribute_default_id         out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_bal_attribute_default >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the balance attribute default.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The balance attribute default as identified by the in parameter
 * p_bal_attribute_default_id must already exist.
 *
 * <p><b>Post Success</b><br>
 * The balance attribute default as identified by the in parameter
 * p_bal_attribute_default_id will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the balance attribute default and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_bal_attribute_default_id {@rep:casecolumn
 * PAY_BAL_ATTRIBUTE_DEFAULTS.BAL_ATTRIBUTE_DEFAULT_ID}
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @rep:displayname Delete Balance Attribute Default
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_bal_attribute_default
  (p_validate                      in     boolean  default false
  ,p_bal_attribute_default_id      in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  );

end PAY_BAL_ATTRIBUTE_DEFAULT_API;

 

/
