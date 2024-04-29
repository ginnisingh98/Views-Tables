--------------------------------------------------------
--  DDL for Package PER_JOB_GROUP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_GROUP_API" AUTHID CURRENT_USER as
/* $Header: pejgrapi.pkh 120.1 2005/10/02 02:18:06 aroussel $ */
/*#
 * This package contains APIs that create and maintain job group information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Job Group
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_job_group >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a job group.
 *
 * Every job must be a member of a job group. There is also a special job group
 * called the 'Default HR Job Group'. In the HR Application, users can only see
 * jobs within this default job group. (Example: the 'Job' list of values on
 * the assignment form.) Creating a business group in HR creates the Default HR
 * Job Group, not this API. You can use other job groups to partition jobs into
 * different families for use in Oracle Projects, or when creating
 * supplementary roles. A job group can be global in scope, or business-group
 * specific.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * A job group will be created.
 *
 * <p><b>Post Failure</b><br>
 * A job group will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Uniquely identifies the business group in which
 * the job group is created. Leave the value null to specify that the job group
 * is global.
 * @param p_legislation_code The legislation code linked to the Job Group. If
 * passed in, it must be the same as the legislation for the business group
 * (null if the business group is null).
 * @param p_internal_name The internal system name of the Job Group. System
 * processing uses this as a developer key. Oracle recommends you set this to
 * the same value as the 'displayed name'. The internal name is set to
 * 'HR_&lt;business group id&gt;' for the HR Default Job Group. You cannot
 * update it.
 * @param p_displayed_name The displayed name of the Job Group. This will be
 * the name, the application displays in user interfaces.
 * @param p_id_flex_num Uniquely identifies the Job Key Flexfield structure
 * associated with the Job Group.
 * @param p_master_flag Indicates whether the Job Group is the Master Job Group
 * in the business group. Only the Oracle Projects application uses this
 * designation, and it has no relevance in Oracle HRMS.
 * @param p_job_group_id If p_validate is false, this uniquely identifies the
 * Job Group created. If p_validate is true, this parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created job group. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Job Group
 * @rep:category BUSINESS_ENTITY PER_JOB_GROUP
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_JOB_GROUP
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_internal_name                 in     varchar2
  ,p_displayed_name                in     varchar2
  ,p_id_flex_num                   in     number
  ,p_master_flag                   in     varchar2 default 'N'
  ,p_job_group_id                  out nocopy    number
  ,p_object_version_number         out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_job_group >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a job group.
 *
 * Every job must be a member of a job group. There is also a special job group
 * called the 'Default HR Job Group'. In the HR Application, users can only see
 * jobs within this default job group. (Example: the 'Job' list of values on
 * the assignment form.) Creating a business group in HR creates the Default HR
 * Job Group, not this API. You can use other job groups to partition jobs into
 * different families for use in Oracle Projects, or when creating
 * supplementary roles. A job group can be global in scope, or business-group
 * specific.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The Job Group record must exist.
 *
 * <p><b>Post Success</b><br>
 * The Job Group will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The Job Group will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_job_group_id Uniquely identifies the job group to be updated.
 * @param p_business_group_id Uniquely identifies the business group in which
 * the job group is created. Leave the value null to specify that the job group
 * is global. You cannot update it, so Oracle recommends that you don't pass
 * this value to the API.
 * @param p_legislation_code The legislation code linked to the Job Group. If
 * passed in, it must be the same as the legislation for the business group
 * (null if the business group is null).
 * @param p_internal_name The internal system name of the Job Group. System
 * processing uses this as a developer key. Oracle recommends you set this to
 * the same value as the 'displayed name'. The internal name is set to
 * 'HR_&lt;business group id&gt;' for the HR Default Job Group. You cannot
 * update it, so Oracle recommends you don't pass to this API.
 * @param p_displayed_name The displayed name of the Job Group. This will be
 * the name the application displays in user interfaces. Unlike the internal
 * name, you can update it.
 * @param p_id_flex_num Uniquely identifies the Job Key Flexfield structure
 * associated with the Job Group. You cannot update it, so Oracle recommends
 * that you don't pass this value to the API.
 * @param p_master_flag Indicates whether the Job Group is the Master Job Group
 * in the business group. Only the Oracle Projects application uses this
 * designation, and it has no relevance in Oracle HRMS.
 * @param p_object_version_number Passes in the current version number of the
 * job group to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated job group. If p_validate is
 * true will be set to the same value which was passed in.
 * @rep:displayname Update Job Group
 * @rep:category BUSINESS_ENTITY PER_JOB_GROUP
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_JOB_GROUP
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_job_group_id                  in     number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_internal_name                 in     varchar2
  ,p_displayed_name                in     varchar2
  ,p_id_flex_num                   in     number
  ,p_master_flag                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_job_group >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a job group.
 *
 * Every job must be a member of a job group. There is also a special job group
 * called the 'Default HR Job Group'. In the HR Application, users can only see
 * jobs within this default job group. (Example: the 'Job' list of values on
 * the assignment form.) Creating a business group in HR creates the Default HR
 * Job Group, not this API. You can use other job groups to partition jobs into
 * different families for use in Oracle Projects, or when creating
 * supplementary roles. A job group can be global in scope, or business-group
 * specific.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The job group must be exist. A job group cannot be deleted if there are jobs
 * within it.
 *
 * <p><b>Post Success</b><br>
 * The job group is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The job group is not deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_job_group_id Uniquely identifes the job group to be deleted.
 * @param p_object_version_number Current version number of the job group to be
 * deleted.
 * @rep:displayname Delete Job Group
 * @rep:category BUSINESS_ENTITY PER_JOB_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_JOB_GROUP
  (p_validate                      in     boolean  default false
  ,p_job_group_id                  in     number
  ,p_object_version_number         in     number
  );
--
end PER_JOB_GROUP_API;

 

/
