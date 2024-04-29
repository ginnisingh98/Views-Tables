--------------------------------------------------------
--  DDL for Package PAY_USER_TABLE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_TABLE_API" AUTHID CURRENT_USER as
/* $Header: pyputapi.pkh 120.1 2005/10/02 02:33:41 aroussel $ */
/*#
 * This package contains User Table APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname User Table
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_user_table >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a user table record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group where this record to be created should exist.
 *
 * <p><b>Post Success</b><br>
 * The user table will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The user table will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id The user table's business group.
 * @param p_legislation_code The user table's legislation.
 * @param p_range_or_match Indicates whether the user key is exact match (M) or
 * within range (R). Defaults to M.
 * @param p_user_key_units The data type of the user key number (N), date (D),
 * text (T)). Defaults to N.
 * @param p_user_table_name Name of the user table.
 * @param p_user_row_title The user title for the rows.
 * @param p_user_table_id If p_validate is false, this uniquely identifies the
 * user table created. If p_validate is true this parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created user table. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create User Table
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
procedure create_user_table
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_range_or_match                in     varchar2 default 'M'
  ,p_user_key_units                in     varchar2 default 'N'
  ,p_user_table_name               in     varchar2
  ,p_user_row_title                in     varchar2 default null
  ,p_user_table_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_user_table >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a user table.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The user table record identified by p_user_table_id and
 * p_object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The user table will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The user table will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_user_table_id Unique identifier of the user table.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_user_table_name Name of the user table.
 * @param p_user_row_title The user title for the rows.
 * @param p_object_version_number Pass in the current version number of the
 * user table to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated user table. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update User Table
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
procedure update_user_table
  (p_validate                      in     boolean  default false
  ,p_user_table_id                 in     number
  ,p_effective_date                in     date
  ,p_user_table_name               in     varchar2 default hr_api.g_varchar2
  ,p_user_row_title                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_user_table >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a user table record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The user table record identified by p_user_table_id and
 * p_object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The user table will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The user table will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_user_table_id Unique identifier of the user table.
 * @param p_object_version_number Pass in the current version number of the
 * user table to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted user table. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Delete User Table
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
procedure delete_user_table
  (p_validate                      in     boolean  default false
  ,p_user_table_id                 in     number
  ,p_object_version_number         in out nocopy number
  );
--
end pay_user_table_api;

 

/
