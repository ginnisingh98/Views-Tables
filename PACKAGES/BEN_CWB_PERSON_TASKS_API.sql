--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_TASKS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_TASKS_API" AUTHID CURRENT_USER as
/* $Header: bectkapi.pkh 120.1 2005/10/02 02:35:52 aroussel $ */
/*#
 * This package contains Compensation Workbench Person Task APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Compensation Workbench Person Task
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_person_task >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates compensation workbench tasks for a person.
 *
 * Any self-service page, which creates task status, uses this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A person with a compensation life event reason in a Compensation Workbench
 * Plan must exist.
 *
 * <p><b>Post Success</b><br>
 * A Compensation Workbench Task will be created in the database.
 *
 * <p><b>Post Failure</b><br>
 * A Compensation Workbench Task will not be created in the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id This parameter identifies the Group Life Event
 * Reason ID of Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_task_id This parameter identifies the Compensation Workbench Task.
 * A sequence generated primary key.
 * @param p_group_pl_id This parameter specifies the compensation workbench
 * group plan.
 * @param p_lf_evt_ocrd_dt This parameter specifies the life event occured date
 * for person processed.
 * @param p_status_cd This parameter specifies the status code for a task.
 * Valid values are defined in 'BEN_SUBMIT_STAT' lookup type.
 * @param p_access_cd This parameter specifies the access code for manager.
 * Valid values are defined by 'BEN_CWB_TASK_ACCESS' lookup type.
 * @param p_task_last_update_date This parameter identifies the date when the
 * task was last updated.
 * @param p_task_last_update_by This parameter the person who updated the task
 * last.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Compensation Workbench Task. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Compensation Workbench Person Task
 * @rep:category BUSINESS_ENTITY BEN_CWB_TASK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_person_task
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_task_id                       in     number
  ,p_group_pl_id                   in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_status_cd                     in     varchar2 default null
  ,p_access_cd                     in     varchar2 default null
  ,p_task_last_update_date         in     date     default null
  ,p_task_last_update_by           in     number   default null
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_person_task >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates compensation workbench tasks for a person.
 *
 * Any self-service page, which updates task status, uses this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Compensation Workbench Task record must exist in the database to update.
 *
 * <p><b>Post Success</b><br>
 * The Compensation Workbench Task will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The Compensation Workbench Task will be not updated in the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id This parameter identifies the Group Life Event
 * Reason ID of Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_task_id This parameter identifies the Compensation Workbench Task.
 * A sequence generates the primary key.
 * @param p_group_pl_id This parameter specifies a Compensation Workbench Group
 * Plan.
 * @param p_lf_evt_ocrd_dt This parameter specifies the life event occured date
 * for person processed.
 * @param p_status_cd This parameter specifies the status code for Task. Valid
 * values are defined in 'BEN_SUBMIT_STAT' lookup type.
 * @param p_access_cd This parameter specifies the access code for manager.
 * Valid values are defined by 'BEN_CWB_TASK_ACCESS' lookup type.
 * @param p_task_last_update_date This parameter identifies the date when the
 * Task was last updated.
 * @param p_task_last_update_by This parameter identifies the person who
 * updated the Task last.
 * @param p_object_version_number Pass in the current version number of the
 * Compensation Workbench Task to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Compensation Workbench Task If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Compensation Workbench Person Task
 * @rep:category BUSINESS_ENTITY BEN_CWB_TASK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_person_task
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_task_id                       in     number
  ,p_group_pl_id                   in     number   default hr_api.g_number
  ,p_lf_evt_ocrd_dt                in     date     default hr_api.g_date
  ,p_status_cd                     in     varchar2 default hr_api.g_varchar2
  ,p_access_cd                     in     varchar2 default hr_api.g_varchar2
  ,p_task_last_update_date         in     date     default hr_api.g_date
  ,p_task_last_update_by           in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_person_task >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes compensation workbench tasks for a person.
 *
 * Any self-service page which deletes task uses this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Compensation Workbench Task record exists in the database to delete.
 *
 * <p><b>Post Success</b><br>
 * The Compensation Workbench Task will be deleted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The Compensation Workbench Task will be not deleted in the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id This parameter identifies the Group Life Event
 * Reason ID of Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_task_id This parameter identifies the Compensation Workbench Task.
 * A sequence generates primary key.
 * @param p_object_version_number Current version number of the Compensation
 * Workbench Task to be deleted.
 * @rep:displayname Delete Compensation Workbench Person Task
 * @rep:category BUSINESS_ENTITY BEN_CWB_TASK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_person_task
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_task_id                       in     number
  ,p_object_version_number         in     number
  );
--
end BEN_CWB_PERSON_TASKS_API;

 

/
