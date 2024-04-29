--------------------------------------------------------
--  DDL for Package IRC_LOCATION_CRITERIA_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LOCATION_CRITERIA_VAL_API" AUTHID CURRENT_USER as
/* $Header: irlcvapi.pkh 120.4 2008/02/21 14:32:49 viviswan noship $ */
/*#
 * This package contains APIs for creating and deleting location criteria.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Location Criteria
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_location_criteria >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new derived locale value for a given search criteria.
 *
 * You can use this API to add multiple derived locale values to a specific
 * search criteria ID.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * A valid search criteria should be present.
 *
 * <p><b>Post Success</b><br>
 * A derived locale value is created for the search criteria.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create derived locale criteria value and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_search_criteria_id Search criteria for which the
 * value will be added.
 * @param p_derived_locale Derived locale criteria value.
 * @param p_location_criteria_value_id ID of the derived locale
 * criteria value. Identifies the derived locale criteria value.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment detail. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Location Criteria
 * @rep:category BUSINESS_ENTITY IRC_JOB_SEARCH_LOCATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_LOCATION_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_search_criteria_id            in     number
  ,p_derived_locale                in     varchar2
  ,p_location_criteria_value_id       out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_location_criteria >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a single derived locale value for a given search criteria.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The derived locale criteria value must exist.
 *
 * <p><b>Post Success</b><br>
 * The derived locale criteria value will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete derived locale criteria value and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_location_criteria_value_id  ID of the derived locale
 * criteria value. Identifies the derived locale criteria value.
 * @param p_object_version_number Current version number of the location
 * criteria to be deleted.
 * @rep:displayname Delete Location Criteria
 * @rep:category BUSINESS_ENTITY IRC_JOB_SEARCH_LOCATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_LOCATION_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_location_criteria_value_id    in     number
  ,p_object_version_number         in     number
  );
--
end IRC_LOCATION_CRITERIA_VAL_API;

/
