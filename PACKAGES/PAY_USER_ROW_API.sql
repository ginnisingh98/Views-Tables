--------------------------------------------------------
--  DDL for Package PAY_USER_ROW_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_ROW_API" AUTHID CURRENT_USER as
/* $Header: pypurapi.pkh 120.8 2008/04/08 11:33:43 salogana noship $ */
/*#
 * This package contains user row APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname User Row
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_user_row >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API inserts a user row record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid user table identified by p_user_table_id must exist. The
 * p_business_group_id and p_legislation_code for this row must be consistent
 * with the parent row identified by p_user_table_id.
 *
 * <p><b>Post Success</b><br>
 * The user row will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The user row will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_user_table_id Primary Key for User Table.
 * @param p_row_low_range_or_name Lower value for range match of user key, or
 * actual value for exact match.
 * @param p_display_sequence Used for ordering the User Rows. If p_validate is
 * false, this will be set to the display sequence of the user row created. If
 * p_validate is true this will be set to the value passed in.
 * @param p_business_group_id The user row's business group.
 * @param p_legislation_code The user row's legislation.
 * @param p_disable_range_overlap_check Applicable only to the product GHR. If
 * false and GHR is installed, then rows that have overlapping values of
 * row_low_range_or_name and row_high_range are not allowed. Defaults to false.
 * @param p_disable_units_check If false, then the value of
 * row_low_range_or_name will be checked against the units in the user table.
 * Defaults to false.
 * @param p_row_high_range Upper value for the range match of the user row.
 * @param p_user_row_id If p_validate is false, this uniquely identifies the
 * user row created. If p_validate is true this parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created user row. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created user row. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the earliest
 * effective start date for the created user row. If p_validate is true, then
 * set to null.
 * @rep:displayname Create User Row
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
procedure create_user_row
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_user_table_id                 in     number
,p_row_low_range_or_name         in     varchar2
,p_display_sequence              in out nocopy NUMBER
,p_business_group_id             in     number   default null
,p_legislation_code              in     varchar2 default null
,p_disable_range_overlap_check   in     boolean  default false
,p_disable_units_check           in     boolean  default false
,p_row_high_range                in     varchar2 default null
,p_user_row_id                      out nocopy number
,p_object_version_number            out nocopy number
,p_effective_start_date             out nocopy date
,p_effective_end_date               out nocopy date
);
--
-- ---------------------------------------------------------------------------
-- |-----------------------------< create_user_row >-------------------------|
-- ---------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API inserts a user row record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid user table identified by p_user_table_id must exist. The
 * p_business_group_id and p_legislation_code for this row must be consistent
 * with the parent row identified by p_user_table_id.
 *
 * <p><b>Post Success</b><br>
 * The user row will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The user row will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_user_table_id Primary Key for User Table.
 * @param p_row_low_range_or_name Lower value for range match of user key, or
 * actual value for exact match.
 * @param p_base_row_low_range_or_name Max value for range match of user key, or
 * actual value for user row key.
 * @param p_display_sequence Used for ordering the User Rows. If p_validate is
 * false, this will be set to the display sequence of the user row created. If
 * p_validate is true this will be set to the value passed in.
 * @param p_business_group_id The user row's business group.
 * @param p_legislation_code The user row's legislation.
 * @param p_disable_range_overlap_check Applicable only to the product GHR. If
 * false and GHR is installed, then rows that have overlapping values of
 * row_low_range_or_name and row_high_range are not allowed. Defaults to false.
 * @param p_disable_units_check If false, then the value of
 * row_low_range_or_name will be checked against the units in the user table.
 * Defaults to false.
 * @param p_row_high_range Upper value for the range match of the user row.
 * @param p_user_row_id If p_validate is false, this uniquely identifies the
 * user row created. If p_validate is true this parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created user row. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created user row. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the earliest
 * effective start date for the created user row. If p_validate is true, then
 * set to null.
 * @rep:displayname Create User Row
 * @rep:category BUSINESS_ENTITY PAY_USER_DEFINED_TABLE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:primaryinstance
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_user_row
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_user_table_id                 in     number
,p_row_low_range_or_name         in     varchar2
,p_display_sequence              in out nocopy NUMBER
,p_business_group_id             in     number   default null
,p_legislation_code              in     varchar2 default null
,p_disable_range_overlap_check   in     boolean  default false
,p_disable_units_check           in     boolean  default false
,p_row_high_range                in     varchar2 default null
,p_user_row_id                      out nocopy number
,p_object_version_number            out nocopy number
,p_effective_start_date             out nocopy date
,p_effective_end_date               out nocopy date
/* Added for bug fix 6735596 */
,p_base_row_low_range_or_name    in varchar2
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_user_row >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a user row record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid user row identified by p_user_row_id and p_object_version_number
 * must exist.
 *
 * <p><b>Post Success</b><br>
 * The user row will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * The user row will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_user_row_id Unique identifier of the user row.
 * @param p_display_sequence Used for ordering the User Rows. If p_validate is
 * false, this will be set to the display sequence of the user row updated. If
 * p_validate is true this will be set to the value passed in.
 * @param p_object_version_number Pass in the current version number of the
 * user row to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated user row. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_row_low_range_or_name Lower value for range match of user key, or
 * actual value for exact match.
 * @param p_base_row_low_range_or_name Base lower value for range match of
 * user key, or actual value for exact match.
 * @param p_disable_range_overlap_check Applicable only to the product GHR. If
 * false and GHR is installed, then rows that have overlapping values of
 * row_low_range_or_name and row_high_range are not allowed. Defaults to false.
 * @param p_disable_units_check If false, then the value of
 * row_low_range_or_name will be checked against the units in the user table.
 * Defaults to false.
 * @param p_row_high_range Upper value for the range match of the user row.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated User Row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated User Row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Update User Row
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
procedure update_user_row
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_datetrack_update_mode         in     varchar2
,p_user_row_id                   in     number
,p_display_sequence              in out nocopy number
,p_object_version_number         in out nocopy number
,p_row_low_range_or_name         in     varchar2 default hr_api.g_varchar2
,p_base_row_low_range_or_name    in     varchar2 default hr_api.g_varchar2
,p_disable_range_overlap_check   in     boolean  default false
,p_disable_units_check           in     boolean  default false
,p_row_high_range                in     varchar2 default hr_api.g_varchar2
,p_effective_start_date             out nocopy date
,p_effective_end_date               out nocopy date
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_user_row >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a user row record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid user row identified by p_user_row_id and p_object_version_number
 * must exist.
 *
 * <p><b>Post Success</b><br>
 * The user row will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The user row will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_user_row_id Unique identifier of the user row.
 * @param p_object_version_number Pass in the current version number of the
 * user row to be deleted. When the API completes if p_validate is false, will
 * be set to the new version number of the deleted user row. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_disable_range_overlap_check Applicable only to the product GHR. If
 * false and GHR is installed, then rows that have overlapping values of
 * row_low_range_or_name and row_high_range are not allowed. Defaults to false.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted User Row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted User Row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @rep:displayname Delete User Row
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
procedure delete_user_row
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_datetrack_update_mode         in     varchar2
,p_user_row_id                   in     number
,p_object_version_number         in out nocopy number
,p_disable_range_overlap_check   in     boolean  default false
,p_effective_start_date             out nocopy date
,p_effective_end_date               out nocopy date
);

--
end pay_user_row_api;

/
