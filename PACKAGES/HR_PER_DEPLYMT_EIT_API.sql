--------------------------------------------------------
--  DDL for Package HR_PER_DEPLYMT_EIT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PER_DEPLYMT_EIT_API" AUTHID CURRENT_USER as
/* $Header: hrpdeapi.pkh 120.1 2006/05/08 02:24:05 adhunter noship $ */
/*#
 * This package contains global deployment extra information APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Deployment Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_per_deplymt_eit >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a deployment person extra information record.
 *
 * The record indicates that for a given employee's deployment, that a
 * specified person extra information record should be recreated in the
 * destination business group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *
 *
 * <p><b>Post Success</b><br>
 * The deployment person extra information is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The deployment person extra information is not created and an error
 * is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_deployment_id Identifies the deployment record to which this
 * deployment extra information applies.
 * @param p_person_extra_info_id The extra information which should be
 * copied when the deployment is initiated.
 * @param p_per_deplymt_eit_id If p_validate is false, then this uniquely
 * identifies the deployment extra information created. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created deployment extra information.
 * If p_validate is true, then the value will be null.
 * @rep:displayname Create Deployment Person Extra Information
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_per_deplymt_eit
  (p_validate                         in     boolean  default false
  ,p_person_deployment_id             in     number
  ,p_person_extra_info_id             in     number
  ,p_per_deplymt_eit_id               out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_per_deplymt_eit >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a deployment person extra information record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The deployment extra information record already exists.
 *
 * <p><b>Post Success</b><br>
 * The deployment extra information record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The deployment extra information record is not deleted, and an error
 * is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_per_deplymt_eit_id Identifies the deployment extra information
 * record to delete.
 * @param p_object_version_number Current version number of the deployment
 * extra informationto be deleted.
 * @rep:displayname Delete Deployment Person Extra Information
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_per_deplymt_eit
  (p_validate                      in     boolean  default false
  ,p_per_deplymt_eit_id            in     number
  ,p_object_version_number         in     number
  );
end HR_PER_DEPLYMT_EIT_API;

 

/
