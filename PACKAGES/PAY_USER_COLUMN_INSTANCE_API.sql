--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_INSTANCE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_INSTANCE_API" AUTHID CURRENT_USER as
/* $Header: pyuciapi.pkh 120.1 2005/10/02 02:34 aroussel $ */
/*#
 * This package contains the User Column Instance APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname User Column Instance
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_user_column_instance >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a user column instance.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid user row identified by p_user_row_id and a valid user column
 * identified by p_user_column_id must exist. The p_business_group_id and
 * p_legislation_code for this row must be consistent with the parent rows
 * identified by p_user_row_id and p_user_column_id.
 *
 * <p><b>Post Success</b><br>
 * The user column instance will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The user column instance will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_user_row_id User Row ID.
 * @param p_user_column_id User Column ID.
 * @param p_value Stored value.
 * @param p_business_group_id The user column instance's business group.
 * @param p_legislation_code The user column instance's legislation.
 * @param p_user_column_instance_id If p_validate is false, this uniquely
 * identifies the user column instance created. If p_validate is true this
 * parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created user column instance. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created user column instance. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created user column instance. If p_validate is
 * true, then set to null.
 * @rep:displayname Create User Column Instance
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
procedure create_user_column_instance
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_user_row_id                   in     number
,p_user_column_id                in     number
,p_value                         in     varchar2 default null
,p_business_group_id             in     number   default null
,p_legislation_code              in     varchar2 default null
,p_user_column_instance_id          out nocopy number
,p_object_version_number            out nocopy number
,p_effective_start_date             out nocopy date
,p_effective_end_date               out nocopy date
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_user_column_instance >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a user column instance.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid user column instance identified by p_user_column_instance_id and
 * p_object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The user column instance will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The user column instance will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_user_column_instance_id Identifier of user column instance created.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_value Stored value.
 * @param p_object_version_number Pass in the current version number of the
 * user column instance to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated user column
 * instance. If p_validate is true will be set to the same value which was
 * passed in
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated user column instance row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated user column instance row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update User Column Instance
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
procedure update_user_column_instance
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_user_column_instance_id       in     number
,p_datetrack_update_mode         in     varchar2
,p_value                         in     varchar2 default HR_API.G_VARCHAR2
,p_object_version_number         in out nocopy number
,p_effective_start_date             out nocopy date
,p_effective_end_date               out nocopy date
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_user_column_instance >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a user column instance.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid user column instance identified by p_user_column_instance_id and
 * p_object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The user column instance will have been successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The user column instance will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_user_column_instance_id Unique identifier of the user column
 * instance record.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_object_version_number Pass in the current version number of the
 * user column instance to be deleted. When the API completes if p_validate is
 * false, will be set to the new version number of the deleted user column
 * instance. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted user column instance row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted user column instance row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @rep:displayname Delete User Column Instance
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
procedure delete_user_column_instance
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_user_column_instance_id       in     number
,p_datetrack_update_mode         in     varchar2
,p_object_version_number         in out nocopy number
,p_effective_start_date             out nocopy date
,p_effective_end_date               out nocopy date
);

--
end pay_user_column_instance_api;

 

/
