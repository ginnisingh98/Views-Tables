--------------------------------------------------------
--  DDL for Package PAY_WCI_OCCUPATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WCI_OCCUPATIONS_API" AUTHID CURRENT_USER as
/* $Header: pypwoapi.pkh 120.1 2005/10/02 02:33:51 aroussel $ */
/*#
 * This package contains Workers compensation Occupation APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Workers Compensation Occupation
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_wci_occupation >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates occupation for a Job for a Workers compensation rate.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rate_id and job_id should exist. The rate_id should exist in
 * pay_wci_rates and job_id should exist in per_jobs table
 *
 * <p><b>Post Success</b><br>
 * Occupation will be created in pay_wci_occupations table for a Workers
 * compensation rate
 *
 * <p><b>Post Failure</b><br>
 * Occupation will not be created
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_rate_id Rate_id for which the occupation is being created
 * @param p_job_id Job_id for which the occupation is being created
 * @param p_comments Comment text
 * @param p_occupation_id The occupation_id of the occupation created
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created WCI occupation. If p_validate is true, then
 * the value will be null
 * @rep:displayname Create Occupation for Worker Compensation Rate
 * @rep:category BUSINESS_ENTITY PAY_WORKERS_COMPENSATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_wci_occupation
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rate_id                       in     number
  ,p_job_id                        in     number
  ,p_comments                      in     varchar2 default null
  ,p_occupation_id                 out    nocopy number
  ,p_object_version_number         out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_wci_occupation >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an occupation created for a Workers compensation.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rate_id,job_id and the occupation_id should already exist
 *
 * <p><b>Post Success</b><br>
 * The occupation will be successfully updated
 *
 * <p><b>Post Failure</b><br>
 * The occupation will not be updated
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_occupation_id The occupation_id of the occupation to be updated
 * @param p_object_version_number Pass in the current version number of the WCI
 * occupation to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated WCI occupation. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_job_id Job_id for which the occupation is being updated.
 * @param p_comments Comment text
 * @rep:displayname Update Occupation for Worker Compensation Rate
 * @rep:category BUSINESS_ENTITY PAY_WORKERS_COMPENSATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_wci_occupation
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_occupation_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_job_id                        in     number   default hr_api.g_number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_wci_occupation >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a occupation created for a Workers compensation.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The occupation should already exist
 *
 * <p><b>Post Success</b><br>
 * The occupation will be successfully deleted
 *
 * <p><b>Post Failure</b><br>
 * The occupation will not be deleted
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_occupation_id The occupation_id of the occupation to be deleted
 * @param p_object_version_number Current version number of the Workers
 * compensation occupation to be deleted.
 * @rep:displayname Delete Occupation for Worker Compensation Rate
 * @rep:category BUSINESS_ENTITY PAY_WORKERS_COMPENSATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_wci_occupation
  (p_validate                      in     boolean  default false
  ,p_occupation_id                 in     number
  ,p_object_version_number         in     number
  );
--
end pay_wci_occupations_api;

 

/
