--------------------------------------------------------
--  DDL for Package HR_PERF_MGMT_PLAN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERF_MGMT_PLAN_API" AUTHID CURRENT_USER as
/* $Header: pepmpapi.pkh 120.2.12010000.3 2010/01/27 15:18:26 rsykam ship $ */
/*#
 * This package contains performance management plan APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Performance Management Plan
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_perf_mgmt_plan >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a performance management plan.
 *
 * The plan remains a draft until it is explicitly published.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The plan administrator must already exist.
 * The previous plan must already exist.
 *
 * <p><b>Post Success</b><br>
 * The performance management plan is created.
 *
 * <p><b>Post Failure</b><br>
 * The performance management plan is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values and
 * other datetracked entities. This date does not determine when the changes
 * take effect.
 * @param p_plan_name {@rep:casecolumn PER_PERF_MGMT_PLANS.PLAN_NAME}
 * @param p_administrator_person_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.ADMINISTRATOR_PERSON_ID}
 * @param p_previous_plan_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.PREVIOUS_PLAN_ID}
 * @param p_start_date {@rep:casecolumn PER_PERF_MGMT_PLANS.START_DATE}
 * @param p_end_date {@rep:casecolumn PER_PERF_MGMT_PLANS.END_DATE}
 * @param p_hierarchy_type_code {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.HIERARCHY_TYPE_CODE}
 * @param p_supervisor_id {@rep:casecolumn PER_PERF_MGMT_PLANS.SUPERVISOR_ID}
 * @param p_supervisor_assignment_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.SUPERVISOR_ASSIGNMENT_ID}
 * @param p_organization_structure_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.ORGANIZATION_STRUCTURE_ID}
 * @param p_org_structure_version_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.ORG_STRUCTURE_VERSION_ID}
 * @param p_top_organization_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.TOP_ORGANIZATION_ID}
 * @param p_position_structure_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.POSITION_STRUCTURE_ID}
 * @param p_pos_structure_version_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.POS_STRUCTURE_VERSION_ID}
 * @param p_top_position_id  {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.TOP_POSITION_ID}
 * @param p_hierarchy_levels {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.HIERARCHY_LEVELS}
 * @param p_automatic_enrollment_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.AUTOMATIC_ENROLLMENT_FLAG}
 * @param p_assignment_types_code {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.ASSIGNMENT_TYPES_CODE}
 * @param p_primary_asg_only_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.PRIMARY_ASG_ONLY_FLAG}
 * @param p_include_obj_setting_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.INCLUDE_OBJ_SETTING_FLAG}
 * @param p_obj_setting_start_date {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.OBJ_SETTING_START_DATE}
 * @param p_obj_setting_deadline {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.OBJ_SETTING_DEADLINE}
 * @param p_obj_set_outside_period_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.SET_OUTSIDE_PERIOD_FLAG}
 * @param p_method_code {@rep:casecolumn PER_PERF_MGMT_PLANS.METHOD_CODE}
 * @param p_notify_population_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.NOTIFY_POPULATION_FLAG}
 * @param p_automatic_allocation_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.AUTOMATIC_ALLOCATION_FLAG}
 * @param p_copy_past_objectives_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.COPY_PAST_OBJECTIVES_FLAG}
 * @param p_sharing_alignment_task_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.SHARING_ALIGNMENT_TASK_FLAG}
 * @param p_include_appraisals_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.INCLUDE_APPRAISALS_FLAG}
 * @param p_change_sc_status_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.CHANGE_SC_STATUS_FLAG}
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_plan_id If p_validate is false, then this uniquely identifies the
 * performance management plan created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created performance management plan. If p_validate is
 * true, then the value will be null.
 * @param p_status_code The status of the performance management plan, always
 * 'DRAFT' when creating a plan.
 * @param p_duplicate_name_warning Set to true if another performance management
 * plan has the same name and overlapping dates.
 * @param p_no_life_events_warning Set to true when there are no WPM life events
 * enabled for the business groups to which the population belong.
 * @rep:displayname Create Performance Management Plan
 * @rep:category BUSINESS_ENTITY PER_PERF_MGMT_PLAN
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure create_perf_mgmt_plan
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_plan_name                     in   varchar2
  ,p_administrator_person_id       in   number
  ,p_previous_plan_id              in   number     default null
  ,p_start_date                    in   date
  ,p_end_date                      in   date
  ,p_hierarchy_type_code           in   varchar2   default null
  ,p_supervisor_id                 in   number     default null
  ,p_supervisor_assignment_id      in   number     default null
  ,p_organization_structure_id     in   number     default null
  ,p_org_structure_version_id      in   number     default null
  ,p_top_organization_id           in   number     default null
  ,p_position_structure_id         in   number     default null
  ,p_pos_structure_version_id      in   number     default null
  ,p_top_position_id               in   number     default null
  ,p_hierarchy_levels              in   number     default null
  ,p_automatic_enrollment_flag     in   varchar2   default 'N'
  ,p_assignment_types_code         in   varchar2   default 'E'
  ,p_primary_asg_only_flag         in   varchar2   default 'Y'
  ,p_include_obj_setting_flag      in   varchar2   default 'Y'
  ,p_obj_setting_start_date        in   date       default null
  ,p_obj_setting_deadline          in   date       default null
  ,p_obj_set_outside_period_flag   in   varchar2   default 'N'
  ,p_method_code                   in   varchar2   default 'CAS'
  ,p_notify_population_flag        in   varchar2   default 'Y'
  ,p_automatic_allocation_flag     in   varchar2   default 'N'
  ,p_copy_past_objectives_flag     in   varchar2   default 'N'
  ,p_sharing_alignment_task_flag   in   varchar2   default 'Y'
  ,p_include_appraisals_flag       in   varchar2   default 'Y'
  ,p_change_sc_status_flag  in   varchar2   default 'N'
  ,p_attribute_category            in   varchar2   default null
  ,p_attribute1                    in   varchar2   default null
  ,p_attribute2                    in   varchar2   default null
  ,p_attribute3                    in   varchar2   default null
  ,p_attribute4                    in   varchar2   default null
  ,p_attribute5                    in   varchar2   default null
  ,p_attribute6                    in   varchar2   default null
  ,p_attribute7                    in   varchar2   default null
  ,p_attribute8                    in   varchar2   default null
  ,p_attribute9                    in   varchar2   default null
  ,p_attribute10                   in   varchar2   default null
  ,p_attribute11                   in   varchar2   default null
  ,p_attribute12                   in   varchar2   default null
  ,p_attribute13                   in   varchar2   default null
  ,p_attribute14                   in   varchar2   default null
  ,p_attribute15                   in   varchar2   default null
  ,p_attribute16                   in   varchar2   default null
  ,p_attribute17                   in   varchar2   default null
  ,p_attribute18                   in   varchar2   default null
  ,p_attribute19                   in   varchar2   default null
  ,p_attribute20                   in   varchar2   default null
  ,p_attribute21                   in   varchar2   default null
  ,p_attribute22                   in   varchar2   default null
  ,p_attribute23                   in   varchar2   default null
  ,p_attribute24                   in   varchar2   default null
  ,p_attribute25                   in   varchar2   default null
  ,p_attribute26                   in   varchar2   default null
  ,p_attribute27                   in   varchar2   default null
  ,p_attribute28                   in   varchar2   default null
  ,p_attribute29                   in   varchar2   default null
  ,p_attribute30                   in   varchar2   default null
  ,p_plan_id                          out nocopy   number
  ,p_object_version_number            out nocopy   number
  ,p_status_code                      out nocopy   varchar2
  ,p_duplicate_name_warning           out nocopy   boolean
  ,p_no_life_events_warning           out nocopy   boolean
  ,p_update_library_objectives in varchar2  default null    -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2  default null
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_perf_mgmt_plan >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a performance management plan.
 *
 * If the plan is currently published, using this API will update the plan's
 * status to updated. If the plan's status is currently draft or updated, this
 * API will not change its status.  Using the Publish API to publish a draft
 * or updated plan.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The performance management plan must exist.
 *
 * <p><b>Post Success</b><br>
 * The performance management plan will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The performance management plan will not have been updated and an error
 * will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values and
 * other datetracked entities. This date does not determine when the changes
 * take effect.
 * @param p_plan_id Identifies the performance management plan to be modified.
 * @param p_object_version_number Pass in the current version number of
 * the performance management plan to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * personal scorecard. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_plan_name {@rep:casecolumn PER_PERF_MGMT_PLANS.PLAN_NAME}
 * @param p_administrator_person_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.ADMINISTRATOR_PERSON_ID}
 * @param p_previous_plan_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.PREVIOUS_PLAN_ID}
 * @param p_start_date {@rep:casecolumn PER_PERF_MGMT_PLANS.START_DATE}
 * @param p_end_date {@rep:casecolumn PER_PERF_MGMT_PLANS.END_DATE}
 * @param p_hierarchy_type_code {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.HIERARCHY_TYPE_CODE}
 * @param p_supervisor_id {@rep:casecolumn PER_PERF_MGMT_PLANS.SUPERVISOR_ID}
 * @param p_supervisor_assignment_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.SUPERVISOR_ASSIGNMENT_ID}
 * @param p_organization_structure_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.ORGANIZATION_STRUCTURE_ID}
 * @param p_org_structure_version_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.ORG_STRUCTURE_VERSION_ID}
 * @param p_top_organization_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.TOP_ORGANIZATION_ID}
 * @param p_position_structure_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.POSITION_STRUCTURE_ID}
 * @param p_pos_structure_version_id {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.POS_STRUCTURE_VERSION_ID}
 * @param p_top_position_id  {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.TOP_POSITION_ID}
 * @param p_hierarchy_levels {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.HIERARCHY_LEVELS}
 * @param p_automatic_enrollment_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.AUTOMATIC_ENROLLMENT_FLAG}
 * @param p_assignment_types_code {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.ASSIGNMENT_TYPES_CODE}
 * @param p_primary_asg_only_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.PRIMARY_ASG_ONLY_FLAG}
 * @param p_include_obj_setting_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.INCLUDE_OBJ_SETTING_FLAG}
 * @param p_obj_setting_start_date {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.OBJ_SETTING_START_DATE}
 * @param p_obj_setting_deadline {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.OBJ_SETTING_DEADLINE}
 * @param p_obj_set_outside_period_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.SET_OUTSIDE_PERIOD_FLAG}
 * @param p_method_code {@rep:casecolumn PER_PERF_MGMT_PLANS.METHOD_CODE}
 * @param p_notify_population_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.NOTIFY_POPULATION_FLAG}
 * @param p_automatic_allocation_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.AUTOMATIC_ALLOCATION_FLAG}
 * @param p_copy_past_objectives_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.COPY_PAST_OBJECTIVES_FLAG}
 * @param p_sharing_alignment_task_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.SHARING_ALIGNMENT_TASK_FLAG}
 * @param p_include_appraisals_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.INCLUDE_APPRAISALS_FLAG}
 * @param p_change_sc_status_flag {@rep:casecolumn
 * PER_PERF_MGMT_PLANS.CHANGE_SC_STATUS_FLAG}
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_status_code The status of the performance management plan.
 * @param p_duplicate_name_warning Set to true if another performance management
 * plan has the same name and overlapping dates.
 * @param p_no_life_events_warning Set to true when there are no WPM life events
 * enabled for the business groups to which the population belong.
 * @rep:displayname Update Performance Management Plan
 * @rep:category BUSINESS_ENTITY PER_PERF_MGMT_PLAN
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure update_perf_mgmt_plan
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_plan_id                       in   number
  ,p_plan_name                     in   varchar2   default hr_api.g_varchar2
  ,p_administrator_person_id       in   number     default hr_api.g_number
  ,p_previous_plan_id              in   number     default hr_api.g_number
  ,p_start_date                    in   date       default hr_api.g_date
  ,p_end_date                      in   date       default hr_api.g_date
  ,p_hierarchy_type_code           in   varchar2   default hr_api.g_varchar2
  ,p_supervisor_id                 in   number     default hr_api.g_number
  ,p_supervisor_assignment_id      in   number     default hr_api.g_number
  ,p_organization_structure_id     in   number     default hr_api.g_number
  ,p_org_structure_version_id      in   number     default hr_api.g_number
  ,p_top_organization_id           in   number     default hr_api.g_number
  ,p_position_structure_id         in   number     default hr_api.g_number
  ,p_pos_structure_version_id      in   number     default hr_api.g_number
  ,p_top_position_id               in   number     default hr_api.g_number
  ,p_hierarchy_levels              in   number     default hr_api.g_number
  ,p_automatic_enrollment_flag     in   varchar2   default hr_api.g_varchar2
  ,p_assignment_types_code         in   varchar2   default hr_api.g_varchar2
  ,p_primary_asg_only_flag         in   varchar2   default hr_api.g_varchar2
  ,p_include_obj_setting_flag      in   varchar2   default hr_api.g_varchar2
  ,p_obj_setting_start_date        in   date       default hr_api.g_date
  ,p_obj_setting_deadline          in   date       default hr_api.g_date
  ,p_obj_set_outside_period_flag   in   varchar2   default hr_api.g_varchar2
  ,p_method_code                   in   varchar2   default hr_api.g_varchar2
  ,p_notify_population_flag        in   varchar2   default hr_api.g_varchar2
  ,p_automatic_allocation_flag     in   varchar2   default hr_api.g_varchar2
  ,p_copy_past_objectives_flag     in   varchar2   default hr_api.g_varchar2
  ,p_sharing_alignment_task_flag   in   varchar2   default hr_api.g_varchar2
  ,p_include_appraisals_flag       in   varchar2   default hr_api.g_varchar2
  ,p_change_sc_status_flag  in   varchar2   default hr_api.g_varchar2
  ,p_attribute_category            in   varchar2   default hr_api.g_varchar2
  ,p_attribute1                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute2                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute3                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute4                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute5                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute6                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute7                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute8                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute9                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute10                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute11                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute12                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute13                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute14                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute15                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute16                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute17                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute18                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute19                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute20                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute21                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute22                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute23                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute24                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute25                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute26                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute27                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute28                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute29                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute30                   in   varchar2   default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ,p_status_code                      out nocopy   varchar2
  ,p_duplicate_name_warning           out nocopy   boolean
  ,p_no_life_events_warning           out nocopy   boolean
  ,p_update_library_objectives in varchar2  default hr_api.g_varchar2     -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_perf_mgmt_plan >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a performance management plan.
 *
 * Plans that are published cannot be deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The performance management plan must exist.
 *
 * <p><b>Post Success</b><br>
 * The performance management plan will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The performance management plan will not be deleted and an error will be
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_plan_id Identifies the performance management plan to be deleted.
 * @param p_object_version_number Current version number of the performance
 * management plan to be deleted.
 * @rep:displayname Delete Performance Management Plan
 * @rep:category BUSINESS_ENTITY PER_PERF_MGMT_PLAN
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure delete_perf_mgmt_plan
  (p_validate                      in   boolean default false
  ,p_plan_id                       in   number
  ,p_object_version_number         in   number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< publish_plan >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API publishes a performance management plan.
 *
 * Publishing a plan: creates or updates personal scorecards for the
 * population; can automatically allocate objectives from the objectives
 * library to eligible members of the plan population; notifies individuals
 * who should start the objective-setting process.
 *
 * Note: this process performs many actions so the publish plan concurrent
 * program can be used as an alternative to this API.
 *
 * Warning: this process can be difficult to reverse.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The performance management plan must exist, and must have a draft or
 * updated status.
 *
 * <p><b>Post Success</b><br>
 * The performance management plan will have been published.
 *
 * <p><b>Post Failure</b><br>
 * The performance management plan will not be deleted and an error will be
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date This is used for: a) validating lookup values,
 * b) determining the plan population and objective eligibility, and c)
 * end-dating personal scorecards and objectives for members that are no
 * longer part of the population. The lsat item only applies to publishing
 * an updated plan.
 * @param p_plan_id Identifies the performance management plan to be published.
 * @param p_object_version_number Current version number of the performance
 * management plan to be published.
 * @rep:displayname Publish Performance Management Plan
 * @rep:category BUSINESS_ENTITY PER_PERF_MGMT_PLAN
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure publish_plan
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_plan_id                       in   number
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< reverse_publish_plan >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API reverses the publication of a performance management plan.
 *
 * Warning: this API attempts to delete all personal scorecards, appraisals
 * and objectives associated with the performance management plan. It does
 * not end-date these objects it deletes them from the database.  This
 * should only be used when a plan has been published by error.  When an
 * objective has been given performance ratings, the objective cannot be
 * deleted, which means that this API will fail.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The performance management plan must exist, and must have a published
 * status.
 *
 * <p><b>Post Success</b><br>
 * The publication of the performance management plan will have been reversed.
 *
 * <p><b>Post Failure</b><br>
 * The publication of the performance management plan will not be reversed and
 * an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_plan_id Identifies the performance management plan where
 * publication should be reversed.
 * @param p_object_version_number Current version number of the performance
 * management plan to be reverse published.
 * @rep:displayname Reverse Publish Performance Management Plan
 * @rep:category BUSINESS_ENTITY PER_PERF_MGMT_PLAN
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure reverse_publish_plan
  (p_validate                      in   boolean    default false
  ,p_plan_id                       in   number
  ,p_object_version_number         in out nocopy   number
  );
--
end HR_PERF_MGMT_PLAN_API;

/
