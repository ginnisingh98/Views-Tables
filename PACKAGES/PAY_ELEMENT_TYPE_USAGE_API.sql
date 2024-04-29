--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TYPE_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TYPE_USAGE_API" AUTHID CURRENT_USER as
/* $Header: pyetuapi.pkh 120.1 2005/10/02 02:30:59 aroussel $ */
/*#
 * This package contains element type usage APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Element Type Usage
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_element_type_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates new element type usages.
 *
 * The role of this process is to insert a fully validated row into the
 * pay_element_type_usages_f of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element type must already exist.
 *
 * <p><b>Post Success</b><br>
 * The element type usage will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The element type usage will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_run_type_id {@rep:casecolumn PAY_ELEMENT_TYPE_USAGES_F.RUN_TYPE_ID}
 * @param p_element_type_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID}
 * @param p_inclusion_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPE_USAGES_F.INCLUSION_FLAG}
 * @param p_business_group_id {@rep:casecolumn
 * PAY_ELEMENT_TYPE_USAGES_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PAY_ELEMENT_TYPE_USAGES_F.LEGISLATION_CODE}
 * @param p_usage_type {@rep:casecolumn PAY_ELEMENT_TYPE_USAGES_F.USAGE_TYPE}
 * @param p_element_type_usage_id If p_validate is false, uniquely identifies
 * the element type usage created. If p_validate is set to true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created element type usage. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created element type usage. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created element type usage. If p_validate is
 * true, then set to null.
 * @rep:displayname Create Element Type Usage
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_element_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_run_type_id                   in     number
  ,p_element_type_id               in     number
  ,p_inclusion_flag		   in     varchar2 default 'N'
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_usage_type			   in     varchar2 default null
  ,p_element_type_usage_id            out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_element_type_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates element type usages.
 *
 * The role of this process is to perform a validated, date-effective update of
 * an existing row in the pay_element_type_usages_f table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element type usage as identified by the in parameters
 * p_element_type_usage_id and p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The element type usage will have been successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The element type usage will not be updated and an error will be raised.
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
 * @param p_inclusion_flag {@rep:casecolumn
 * PAY_ELEMENT_TYPE_USAGES_F.INCLUSION_FLAG}
 * @param p_element_type_usage_id {@rep:casecolumn
 * PAY_ELEMENT_TYPE_USAGES_F.ELEMENT_TYPE_USAGE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * element type extra information to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * element type extra information. If p_validate is true will be set to the
 * same value which was passed in.
 * @param p_business_group_id {@rep:casecolumn
 * PAY_ELEMENT_TYPE_USAGES_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PAY_ELEMENT_TYPE_USAGES_F.LEGISLATION_CODE}
 * @param p_usage_type {@rep:casecolumn PAY_ELEMENT_TYPE_USAGES_F.USAGE_TYPE}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated element type usage row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated element type usage row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Element Type Usage
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_element_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_inclusion_flag		   in     varchar2 default hr_api.g_varchar2
  ,p_element_type_usage_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_usage_type			   in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_element_type_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an element type usage.
 *
 * The role of this process is to perform a validated, date-effective delete of
 * an existing row in the pay_element_type_usages_f table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element type usage as identified by the in parameters
 * p_element_type_usage_id and p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The element type usage will have been successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The element type usage will not be deleted and an error will be raised.
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
 * @param p_element_type_usage_id {@rep:casecolumn
 * PAY_ELEMENT_TYPE_USAGES_F.ELEMENT_TYPE_USAGE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * element type usage to be deleted. When the API completes if p_validate is
 * false, will be set to the new version number of the deleted element type
 * usage. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_business_group_id {@rep:casecolumn
 * PAY_ELEMENT_TYPE_USAGES_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PAY_ELEMENT_TYPE_USAGES_F.LEGISLATION_CODE}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted element type usage row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted element type usage row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @rep:displayname Delete Element Type Usage
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_element_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_element_type_usage_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
end pay_element_type_usage_api;

 

/
