--------------------------------------------------------
--  DDL for Package Body HR_PERF_MGMT_PLAN_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERF_MGMT_PLAN_SWI" As
/* $Header: pepmpswi.pkb 120.2.12010000.3 2010/01/27 15:02:57 rsykam ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_perf_mgmt_plan_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_perf_mgmt_plan >------------------------|
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
  ,p_copy_past_objectives_flag    in     varchar2  default null
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
 ,p_update_library_objectives in varchar2  default null    -- 8740021 bug fix
 ,p_automatic_approval_flag in varchar2  default null
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_duplicate_name_warning        boolean;
  l_no_life_events_warning        boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_plan_id                      number;
  l_proc    varchar2(72) := g_package ||'create_perf_mgmt_plan';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_perf_mgmt_plan_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  per_pmp_ins.set_base_key_value
    (p_plan_id => p_plan_id
    );
  --
  -- Call API
  --
  hr_perf_mgmt_plan_api.create_perf_mgmt_plan
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_plan_name                    => p_plan_name
    ,p_administrator_person_id      => p_administrator_person_id
    ,p_previous_plan_id             => p_previous_plan_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_hierarchy_type_code          => p_hierarchy_type_code
    ,p_supervisor_id                => p_supervisor_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    ,p_organization_structure_id    => p_organization_structure_id
    ,p_org_structure_version_id     => p_org_structure_version_id
    ,p_top_organization_id          => p_top_organization_id
    ,p_position_structure_id        => p_position_structure_id
    ,p_pos_structure_version_id     => p_pos_structure_version_id
    ,p_top_position_id              => p_top_position_id
    ,p_hierarchy_levels             => p_hierarchy_levels
    ,p_automatic_enrollment_flag    => p_automatic_enrollment_flag
    ,p_assignment_types_code        => p_assignment_types_code
    ,p_primary_asg_only_flag        => p_primary_asg_only_flag
    ,p_include_obj_setting_flag     => p_include_obj_setting_flag
    ,p_obj_setting_start_date       => p_obj_setting_start_date
    ,p_obj_setting_deadline         => p_obj_setting_deadline
    ,p_obj_set_outside_period_flag  => p_obj_set_outside_period_flag
    ,p_method_code                  => p_method_code
    ,p_notify_population_flag       => p_notify_population_flag
    ,p_automatic_allocation_flag    => p_automatic_allocation_flag
    ,p_copy_past_objectives_flag    => p_copy_past_objectives_flag
    ,p_sharing_alignment_task_flag  => p_sharing_alignment_task_flag
    ,p_include_appraisals_flag      => p_include_appraisals_flag
 ,p_change_sc_status_flag  => p_change_sc_status_flag
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_plan_id                      => l_plan_id
    ,p_object_version_number        => p_object_version_number
    ,p_status_code                  => p_status_code
    ,p_duplicate_name_warning       => l_duplicate_name_warning
    ,p_no_life_events_warning       => l_no_life_events_warning
   ,p_update_library_objectives    => p_update_library_objectives  -- 8740021 bug fix
   ,p_automatic_approval_flag      => p_automatic_approval_flag
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_duplicate_name_warning then
     fnd_message.set_name('PER', 'HR_50231_WPM_DUP_PLAN_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_no_life_events_warning then
     fnd_message.set_name('PER', 'HR_50247_WPM_PLAN_AUTO_ENROL_W');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_perf_mgmt_plan_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_status_code                  := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_perf_mgmt_plan_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_status_code                  := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_perf_mgmt_plan;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_perf_mgmt_plan >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_perf_mgmt_plan
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_plan_id                      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_perf_mgmt_plan';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_perf_mgmt_plan_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_perf_mgmt_plan_api.delete_perf_mgmt_plan
    (p_validate                     => l_validate
    ,p_plan_id                      => p_plan_id
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_perf_mgmt_plan_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_perf_mgmt_plan_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_perf_mgmt_plan;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_perf_mgmt_plan >------------------------|
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
  ,p_copy_past_objectives_flag    in     varchar2  default hr_api.g_varchar2
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
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_duplicate_name_warning        boolean;
  l_no_life_events_warning        boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_perf_mgmt_plan';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_perf_mgmt_plan_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_perf_mgmt_plan_api.update_perf_mgmt_plan
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_plan_id                      => p_plan_id
    ,p_plan_name                    => p_plan_name
    ,p_administrator_person_id      => p_administrator_person_id
    ,p_previous_plan_id             => p_previous_plan_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_hierarchy_type_code          => p_hierarchy_type_code
    ,p_supervisor_id                => p_supervisor_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    ,p_organization_structure_id    => p_organization_structure_id
    ,p_org_structure_version_id     => p_org_structure_version_id
    ,p_top_organization_id          => p_top_organization_id
    ,p_position_structure_id        => p_position_structure_id
    ,p_pos_structure_version_id     => p_pos_structure_version_id
    ,p_top_position_id              => p_top_position_id
    ,p_hierarchy_levels             => p_hierarchy_levels
    ,p_automatic_enrollment_flag    => p_automatic_enrollment_flag
    ,p_assignment_types_code        => p_assignment_types_code
    ,p_primary_asg_only_flag        => p_primary_asg_only_flag
    ,p_include_obj_setting_flag     => p_include_obj_setting_flag
    ,p_obj_setting_start_date       => p_obj_setting_start_date
    ,p_obj_setting_deadline         => p_obj_setting_deadline
    ,p_obj_set_outside_period_flag  => p_obj_set_outside_period_flag
    ,p_method_code                  => p_method_code
    ,p_notify_population_flag       => p_notify_population_flag
    ,p_automatic_allocation_flag    => p_automatic_allocation_flag
    ,p_copy_past_objectives_flag    => p_copy_past_objectives_flag
    ,p_sharing_alignment_task_flag  => p_sharing_alignment_task_flag
    ,p_include_appraisals_flag      => p_include_appraisals_flag
 ,p_change_sc_status_flag  => p_change_sc_status_flag
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_object_version_number        => p_object_version_number
    ,p_status_code                  => p_status_code
    ,p_duplicate_name_warning       => l_duplicate_name_warning
    ,p_no_life_events_warning       => l_no_life_events_warning
   ,p_update_library_objectives    => p_update_library_objectives  -- 8740021 bug fix
   ,p_automatic_approval_flag      => p_automatic_approval_flag
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_duplicate_name_warning then
     fnd_message.set_name('PER', 'HR_50231_WPM_DUP_PLAN_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_no_life_events_warning then
     fnd_message.set_name('PER', 'HR_50247_WPM_PLAN_AUTO_ENROL_W');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_perf_mgmt_plan_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_status_code                  := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_perf_mgmt_plan_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_status_code                  := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_perf_mgmt_plan;
end hr_perf_mgmt_plan_swi;

/
