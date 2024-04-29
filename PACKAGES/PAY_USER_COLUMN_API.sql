--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_API" AUTHID CURRENT_USER as
/* $Header: pypucapi.pkh 120.1 2005/10/02 02:33 aroussel $ */
/*#
 * This API creates a new user column for an user table.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname User Column
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_user_column >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a user column.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid user table identified by p_user_table_id must exist. If p_formula_id
 * is not null then a valid formula identified by p_formula_id must exist. The
 * p_business_group_id and p_legislation_code for this row must be consistent
 * with the parent row identified by p_user_table_id.
 *
 * <p><b>Post Success</b><br>
 * The user column will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The user column will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id The user column's business group.
 * @param p_legislation_code The user column's legislation.
 * @param p_user_table_id User Table ID.
 * @param p_formula_id Formula identifier that corresponds to a formula of type
 * - User Table Validation.
 * @param p_user_column_name Name of the user column.
 * @param p_user_column_id If p_validate is false, this uniquely identifies the
 * user column created. If p_validate is true this parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created user column. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create User Column
 * @rep:category BUSINESS_ENTITY PAY_USER_DEFINED_TABLE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_user_column
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_user_table_id                 in     number
  ,p_formula_id                    in     number   default null
  ,p_user_column_name              in     varchar2
  ,p_user_column_id                   out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_user_column >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a user column.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The user column record identified by p_user_column_id and
 * p_object_version_number must exist. If p_formula_id is not null then a valid
 * formula identified by p_formula_id must exist.
 *
 * <p><b>Post Success</b><br>
 * The user column will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The user column will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_user_column_id Unique identifier of the user column.
 * @param p_user_column_name Name of the user column.
 * @param p_formula_id Formula identifier that corresponds to a formula of type
 * - User Table Validation.
 * @param p_object_version_number Pass in the current version number of the
 * user column. to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated user column. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_formula_warning Set to true if the formula_id is also updated.
 * @rep:displayname Update User Column
 * @rep:category BUSINESS_ENTITY PAY_USER_DEFINED_TABLE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_user_column
  (p_validate                      in     boolean  default false
  ,p_user_column_id                in     number
  ,p_user_column_name              in     varchar2 default hr_api.g_varchar2
  ,p_formula_id                    in     number   default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_formula_warning                  out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_user_column >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API removes a user column.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The user column record identified by p_user_column_id and
 * p_object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The user column will have been successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The user column will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_user_column_id Unique identifier of the user column.
 * @param p_object_version_number Pass in the current version number of the
 * user column to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted user column. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Delete User Column
 * @rep:category BUSINESS_ENTITY PAY_USER_DEFINED_TABLE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_user_column
  (p_validate                      in     boolean  default false
  ,p_user_column_id                in     number
  ,p_object_version_number         in out nocopy number
  );
--
end pay_user_column_api;

 

/
