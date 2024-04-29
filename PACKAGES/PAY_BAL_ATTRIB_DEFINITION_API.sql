--------------------------------------------------------
--  DDL for Package PAY_BAL_ATTRIB_DEFINITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BAL_ATTRIB_DEFINITION_API" AUTHID CURRENT_USER as
/* $Header: pyatdapi.pkh 120.1 2005/10/02 02:29:17 aroussel $ */
/*#
 * This package contains Pay Balance Attribute definition APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Balance Attribute Definition
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_bal_attrib_definition >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the balance attribute definition.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Requires a valid business group to exist.
 *
 * <p><b>Post Success</b><br>
 * The balance adjustment will be successfully carried out.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the balance attribute definition and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_attribute_name The name for the balance attribute.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_alterable Indicates if the attribute value can be altered by the
 * user for a balance.
 * @param p_user_attribute_name This is the display name for the attribute.
 * @param p_attribute_id If p_validate is false, this uniquely identifies the
 * balance attribute definition created. If p_validate is set to true, this
 * parameter will be null.
 * @rep:displayname Create Balance Attribute Definition
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_bal_attrib_definition
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_attribute_name                in     varchar2
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_alterable                     in     varchar2 default null
  ,p_user_attribute_name           in     varchar2 default null
  ,p_attribute_id                     out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_bal_attrib_definition >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the balance attribute definition.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The balance attribute definition as identified by the in parameter
 * p_attribute_id must already exist.
 *
 * <p><b>Post Success</b><br>
 * The balance attribute definition as identified by the in parameter
 * p_attribute_id will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the balance attribute definition and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_attribute_id {@rep:casecolumn
 * PAY_BAL_ATTRIBUTE_DEFINITIONS.ATTRIBUTE_ID}
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @rep:displayname Delete Balance Attribute Definition
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_bal_attrib_definition
  (p_validate                      in     boolean  default false
  ,p_attribute_id                  in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  );

end PAY_BAL_ATTRIB_DEFINITION_API;

 

/
