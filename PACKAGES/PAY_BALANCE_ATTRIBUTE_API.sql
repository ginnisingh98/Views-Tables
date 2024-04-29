--------------------------------------------------------
--  DDL for Package PAY_BALANCE_ATTRIBUTE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_ATTRIBUTE_API" AUTHID CURRENT_USER as
/* $Header: pypbaapi.pkh 120.1 2005/10/02 02:32:22 aroussel $ */
/*#
 * Pay Balance Attribute API.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Balance Attribute
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_balance_attribute >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This >API creates the balance attribute.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The defined balance and balance attribute must exists for the same business
 * group as this record is to be created.
 *
 * <p><b>Post Success</b><br>
 * The balance attribute will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the balance attribute raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_attribute_id {@rep:casecolumn
 * PAY_BAL_ATTRIBUTE_DEFINITIONS.ATTRIBUTE_ID}
 * @param p_defined_balance_id {@rep:casecolumn
 * PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID}
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_balance_attribute_id If p_validate is false, this uniquely
 * identifies the balance attribute created. If p_validate is set to true, this
 * parameter will be null.
 * @rep:displayname Create Balance Attribute
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_balance_attribute
  (p_validate                      in            boolean  default false
  ,p_attribute_id                  in            number
  ,p_defined_balance_id            in            number
  ,p_business_group_id             in            number   default null
  ,p_legislation_code              in            varchar2 default null
  ,p_balance_attribute_id             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_balance_attribute >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a balance attribute.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The balance attribute as identified by the in parameter
 * p_balance_attribute_id must already exist.
 *
 * <p><b>Post Success</b><br>
 * The balance attribute as identified by the in parameter
 * p_balance_attribute_id will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the balance attribute and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_balance_attribute_id {@rep:casecolumn
 * PAY_BALANCE_ATTRIBUTES.BALANCE_ATTRIBUTE_ID}
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @rep:displayname Delete Balance Attribute
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_balance_attribute
  (p_validate                      in     boolean  default false
  ,p_balance_attribute_id          in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  );

end PAY_BALANCE_ATTRIBUTE_API;

 

/
