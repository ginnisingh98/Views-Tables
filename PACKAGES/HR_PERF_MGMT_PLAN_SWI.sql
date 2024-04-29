--------------------------------------------------------
--  DDL for Package HR_PERF_MGMT_PLAN_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERF_MGMT_PLAN_SWI" AUTHID CURRENT_USER As
/* $Header: pepmpswi.pkh 120.2.12010000.3 2010/01/27 15:01:08 rsykam ship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_perf_mgmt_plan >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_perf_mgmt_plan_api.create_perf_mgmt_plan
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_perf_mgmt_plan
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_plan_name                    in     varchar2
  ,p_administrator_person_id      in     number
  ,p_previous_plan_id             in     number    default null
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_hierarchy_type_code          in     varchar2  default null
  ,p_supervisor_id                in     number    default null
  ,p_supervisor_assignment_id     in     number    default null
  ,p_organization_structure_id    in     number    default null
  ,p_org_structure_version_id     in     number    default null
  ,p_top_organization_id          in     number    default null
  ,p_position_structure_id        in     number    default null
  ,p_pos_structure_version_id     in     number    default null
  ,p_top_position_id              in     number    default null
  ,p_hierarchy_levels             in     number    default null
  ,p_automatic_enrollment_flag    in     varchar2  default null
  ,p_assignment_types_code        in     varchar2  default null
  ,p_primary_asg_only_flag        in     varchar2  default null
  ,p_include_obj_setting_flag     in     varchar2  default null
  ,p_obj_setting_start_date       in     date      default null
  ,p_obj_setting_deadline         in     date      default null
  ,p_obj_set_outside_period_flag  in     varchar2  default null
  ,p_method_code                  in     varchar2  default null
  ,p_notify_population_flag       in     varchar2  default null
  ,p_automatic_allocation_flag    in     varchar2  default null
  ,p_copy_past_objectives_flag     in   varchar2   default null
  ,p_sharing_alignment_task_flag  in     varchar2  default null
  ,p_include_appraisals_flag      in     varchar2  default null
  ,p_change_sc_status_flag in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_plan_id                      in     number
  ,p_object_version_number           out nocopy number
  ,p_status_code                     out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_update_library_objectives in varchar2  default null     -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2  default null
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_perf_mgmt_plan >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_perf_mgmt_plan_api.delete_perf_mgmt_plan
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_perf_mgmt_plan
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_plan_id                      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_perf_mgmt_plan >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_perf_mgmt_plan_api.update_perf_mgmt_plan
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_perf_mgmt_plan
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_plan_id                      in     number
  ,p_plan_name                    in     varchar2  default hr_api.g_varchar2
  ,p_administrator_person_id      in     number    default hr_api.g_number
  ,p_previous_plan_id             in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_hierarchy_type_code          in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_supervisor_assignment_id     in     number    default hr_api.g_number
  ,p_organization_structure_id    in     number    default hr_api.g_number
  ,p_org_structure_version_id     in     number    default hr_api.g_number
  ,p_top_organization_id          in     number    default hr_api.g_number
  ,p_position_structure_id        in     number    default hr_api.g_number
  ,p_pos_structure_version_id     in     number    default hr_api.g_number
  ,p_top_position_id              in     number    default hr_api.g_number
  ,p_hierarchy_levels             in     number    default hr_api.g_number
  ,p_automatic_enrollment_flag    in     varchar2  default hr_api.g_varchar2
  ,p_assignment_types_code        in     varchar2  default hr_api.g_varchar2
  ,p_primary_asg_only_flag        in     varchar2  default hr_api.g_varchar2
  ,p_include_obj_setting_flag     in     varchar2  default hr_api.g_varchar2
  ,p_obj_setting_start_date       in     date      default hr_api.g_date
  ,p_obj_setting_deadline         in     date      default hr_api.g_date
  ,p_obj_set_outside_period_flag  in     varchar2  default hr_api.g_varchar2
  ,p_method_code                  in     varchar2  default hr_api.g_varchar2
  ,p_notify_population_flag       in     varchar2  default hr_api.g_varchar2
  ,p_automatic_allocation_flag    in     varchar2  default hr_api.g_varchar2
  ,p_copy_past_objectives_flag     in    varchar2  default hr_api.g_varchar2
  ,p_sharing_alignment_task_flag  in     varchar2  default hr_api.g_varchar2
  ,p_include_appraisals_flag      in     varchar2  default hr_api.g_varchar2
  ,p_change_sc_status_flag in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_status_code                     out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_update_library_objectives in varchar2  default hr_api.g_varchar2     -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2  default hr_api.g_varchar2
  );
 end hr_perf_mgmt_plan_swi;

/
