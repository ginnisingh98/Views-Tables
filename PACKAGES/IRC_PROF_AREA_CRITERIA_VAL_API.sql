--------------------------------------------------------
--  DDL for Package IRC_PROF_AREA_CRITERIA_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PROF_AREA_CRITERIA_VAL_API" AUTHID CURRENT_USER as
/* $Header: irpcvapi.pkh 120.4 2008/02/21 14:34:22 viviswan noship $ */
/*#
 * This package contains APIs for creating and deleting professional area
 * value for a given search criteria.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Professional Area Criteria
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_prof_area_criteria >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new professional area value for a given search
 * criteria.
 *
 * You can use this API to add multiple professional area values to a
 * specific search criteria ID.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * A valid search criteria should be present.
 *
 * <p><b>Post Success</b><br>
 * A professional area value is created for the search criteria.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a professional area criteria value and
 * raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_search_criteria_id Identifies the search criteria for which the
 * professional area value will be added.
 * @param p_professional_area Professional area criteria
 * value.
 * @param p_prof_area_criteria_value_id Primary key of the professional
 * area criteria in the IRC_PROF_AREA_CRITERIA_VALUES table.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment detail. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Creates Professional Area Criteria
 * @rep:category BUSINESS_ENTITY IRC_JOB_SEARCH_PROF_AREA
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_PROF_AREA_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_search_criteria_id            in     number
  ,p_professional_area             in     varchar2
  ,p_prof_area_criteria_value_id      out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_prof_area_criteria >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a single professional area value for a given search
 * criteria.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * A valid professional area criteria value ID and object version number.
 *
 * <p><b>Post Success</b><br>
 * The professional area criteria value will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the professional area criteria value and
 * raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_prof_area_criteria_value_id Identifies the professional
 * area criteria value.
 * @param p_object_version_number Current version number of the location
 * criteria to be deleted.
 * @rep:displayname Delete Professional Area Criteria
 * @rep:category BUSINESS_ENTITY IRC_JOB_SEARCH_PROF_AREA
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_PROF_AREA_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_prof_area_criteria_value_id   in     number
  ,p_object_version_number         in     number
  );
--
end IRC_PROF_AREA_CRITERIA_VAL_API;

/
