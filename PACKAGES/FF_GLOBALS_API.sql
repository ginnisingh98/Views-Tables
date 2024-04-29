--------------------------------------------------------
--  DDL for Package FF_GLOBALS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_GLOBALS_API" AUTHID CURRENT_USER as
/* $Header: fffglapi.pkh 120.0.12010000.3 2008/10/31 12:26:02 pvelugul ship $ */
/*#
 * This package contains the FF Global APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname FF Global
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_global >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a FF Global.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid Global identified by identified by p_global_id
 * must exist. The p_business_group_id and
 * p_legislation_code for this row must be consistent.
 *
 * <p><b>Post Success</b><br>
 * The Global will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The Global will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_global_name Global Name.
 * @param p_global_description Global Description.
 * @param p_value Stored value.
 * @param p_data_type Data Type.
 * @param p_business_group_id The global's business group.
 * @param p_legislation_code The global's legislation.
 * @param p_global_id If p_validate is false, this uniquely
 * identifies the global created. If p_validate is true this
 * parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created global. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created global. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created global. If p_validate is
 * true, then set to null.
 * @rep:displayname Create Global
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_global
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_global_name                   in     varchar2
,p_global_description            in     varchar2
,p_data_type                     IN     varchar2
,p_value                         in     varchar2 default null
,p_business_group_id             in     number   default null
,p_legislation_code              in     varchar2 default null
,p_global_id                        out nocopy number
,p_object_version_number            out nocopy number
,p_effective_start_date             out nocopy date
,p_effective_end_date               out nocopy date
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_global >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a global.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid global identified by p_global_id and
 * p_object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The global will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The global will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_global_id Identifier of global created.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_value Stored value.
 * @param p_object_version_number Pass in the current version number of the
 * global to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated global.
 * If p_validate is true will be set to the same value which was
 * passed in
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated global row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated global row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Global
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_global
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_global_id                     in     number
,p_datetrack_update_mode         in     varchar2
,p_value                         in     varchar2 default HR_API.G_VARCHAR2
,p_description                   in     varchar2 default HR_API.G_VARCHAR2
,p_object_version_number         in out nocopy number
,p_effective_start_date             out nocopy date
,p_effective_end_date               out nocopy date
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_global >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a global.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid global identified by p_global_id and
 * p_object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The global will have been successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The global will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_global_id Unique identifier of the global record.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_object_version_number Pass in the current version number of the
 * global to be deleted. When the API completes if p_validate is
 * false, will be set to the new version number of the deleted global.
 * If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted global row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted global row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @rep:displayname Delete Global
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_global
(p_validate                      in     boolean  default false
,p_effective_date                in     date
,p_global_id                     in     number
,p_datetrack_update_mode         in     varchar2
,p_object_version_number         in out nocopy number
,p_effective_start_date             out nocopy date
,p_effective_end_date               out nocopy date
);

--
end ff_globals_api;

/
