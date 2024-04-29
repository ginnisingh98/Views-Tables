--------------------------------------------------------
--  DDL for Package PAY_RUN_TYPE_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RUN_TYPE_USAGE_API" AUTHID CURRENT_USER as
/* $Header: pyrtuapi.pkh 120.1 2005/10/02 02:34:14 aroussel $ */
/*#
 * This package contains APIs for Run Type Usages.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Run Type Usage
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_run_type_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates new run type usages.
 *
 * The created run_type_usages should be based on the existing run types.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * Parent run_type_id with run_method of 'C' must exist, along with another
 * run_type_id which will be the child_run_type_id on the usage.
 *
 * <p><b>Post Success</b><br>
 * The Run Type Usages has been successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the run type usage and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_parent_run_type_id The parent run type is, will have run_method of
 * 'C'.
 * @param p_child_run_type_id The child run type id, no restriction on run
 * method.
 * @param p_sequence Specifies the usage order
 * @param p_business_group_id Business Group of the Record
 * @param p_legislation_code Legislation Code
 * @param p_run_type_usage_id If p_validate is false, this uniquely identifies
 * the run type usage created. If p_validate is set to true, this parameter
 * will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created Run Type Usages. If p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created Run Type Usages. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Run Type Usages. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Run Type Usage
 * @rep:category BUSINESS_ENTITY PAY_RUN_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_run_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_parent_run_type_id            in     number
  ,p_child_run_type_id             in     number
  ,p_sequence                      in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_run_type_usage_id                out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_run_type_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Run Type Usage.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The run type usage as identified by the in parameters p_run_type_usage_id
 * and p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Run Type Usage has been successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the run type usage and raises an error.
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
 * @param p_run_type_usage_id Identifier of the usage being updated
 * @param p_object_version_number Pass in the current version number of the Run
 * Type Usage to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Run Type Usage. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_sequence Specifies the usage order
 * @param p_business_group_id Business Group of the Record
 * @param p_legislation_code Legislation Code
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated Run Type Usage row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated Run Type Usage row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Run Type Usage
 * @rep:category BUSINESS_ENTITY PAY_RUN_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_run_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_run_type_usage_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_sequence                      in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_run_type_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Run Type Usage.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The run type usage as identified by the in parameters p_run_type_usage_id
 * and p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Run Type Usage has been successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the run type usage and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_run_type_usage_id Identifier of the run type usage being deleted.
 * @param p_object_version_number Pass in the current version number of the run
 * type usage to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted run type usage. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_business_group_id Business Group of the Record
 * @param p_legislation_code Legislation Code
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted Run Type Usage row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted Run Type Usage row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Run Type Usage
 * @rep:category BUSINESS_ENTITY PAY_RUN_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_run_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_run_type_usage_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
end pay_run_type_usage_api;

 

/
