--------------------------------------------------------
--  DDL for Package IRC_SAVED_SEARCH_CRITERIA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SAVED_SEARCH_CRITERIA_API" AUTHID CURRENT_USER as
/* $Header: irissapi.pkh 120.1 2008/02/21 14:26:50 viviswan noship $ */
/*#
 * This package contains APIs for maintaining Saved Search Criteria
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Save Search Criteria
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_search_criteria >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new  Search Criteria.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * search criteria  is created only for BGs that have Applicant
 * Tracking enabled.
 *
 * <p><b>Post Success</b><br>
 * Search Criteria is successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Search Criteria and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.

 * @param p_vacancy_id Vacancy id of the Vacancy.
 * @param p_saved_search_criteria_id If p_validate is false, then this uniquely
 * identifies the Search Criteria created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created search criteria. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Save Search Criteria
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_search_criteria
  (p_validate				in     boolean  default false
  ,p_vacancy_id				in     number
  ,p_saved_search_criteria_id           out    nocopy   number
  ,p_object_version_number		out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_search_criteria >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Saved Search Criteria.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Saved Search criteria should exist.
 *
 * <p><b>Post Success</b><br>
 * Successfully updates the Saved Search Criteria.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Saved Search Criteria and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_vacancy_id Vacancy id of the Vacancy.
 * @param p_saved_search_criteria_id If p_validate is false, then this uniquely
 * identifies the Search Criteria is saved. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the saved search criteria. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Update Saved Search Criteria
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_search_criteria
  (p_validate				in     boolean  default false
  ,p_vacancy_id				in     number
  ,p_saved_search_criteria_id           in out nocopy   number
  ,p_object_version_number		in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_search_criteria >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing Saved Search Criteria.
 *
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Saved Search criteria should exist.
 *
 * <p><b>Post Success</b><br>
 * Successfully deletes the Saved Search Criteria.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Saved Search Criteria and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_vacancy_id Vacancy id of the Vacancy.
 * @param p_saved_search_criteria_id If p_validate is false, then this uniquely
 * identifies the Search Criteria is saved. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the saved search criteria. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Update Saved Search Criteria
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--
procedure delete_search_criteria
  (p_validate				in     boolean  default false
   ,p_vacancy_id			in     number
   ,p_saved_search_criteria_id          in     number
   ,p_object_version_number		in     number
  );
end irc_saved_search_criteria_api;

/
