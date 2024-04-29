--------------------------------------------------------
--  DDL for Package Body HR_OBJECTIVES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_OBJECTIVES_SWI" As
/* $Header: peobjswi.pkb 120.15.12010000.3 2009/01/23 10:41:54 psugumar ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_objectives_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_cascading >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_cascading
  (
   p_aligned_with_obj_id IN number
  ,p_objective_id        IN number
  ,p_scorecard_id        IN number
  )
AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
  cursor chk_obj_shared is
  SELECT scorecard_id
        ,sharing_access_code
        ,object_version_number
  FROM per_objectives
  WHERE objective_id = p_aligned_with_obj_id;

  l_mgr_scorecard_id        number;
  l_access_code             per_objectives.sharing_access_code%TYPE;
  l_mgr_obj_ovn             number;
  l_weightin_over_warn      boolean :=FALSE;
  l_weightin_appraisal_warn boolean :=FALSE;
  l_align_access            per_objectives.sharing_access_code%TYPE := 'ALIGN';
--
  cursor chk_shr_instance(p_mgr_scorecard_id in number)
  is
  SELECT 'Y'
  FROM per_scorecard_sharing shr
      ,per_personal_scorecards  psc
  WHERE shr.scorecard_id = p_mgr_scorecard_id
  AND   psc.scorecard_id = p_scorecard_id
  AND   shr.person_id    = psc.person_id;
  --
  l_exists varchar2(1);
--
  cursor csr_get_emp_personid is
  select person_id from per_personal_scorecards
  where scorecard_id = p_scorecard_id;
  --
  l_person_id           number;
  l_cur_person_ovn      number;
  l_sharing_instance_id number;
  --
begin
  --
  open chk_obj_shared;
  fetch chk_obj_shared into l_mgr_scorecard_id,l_access_code,l_mgr_obj_ovn;
  close chk_obj_shared;
  --
  if nvl(l_access_code,'9Z') <> 'ALIGN' then
    --
    -- Update aligned with objective record to mark for aligning
    --
     hr_objectives_api.update_objective
       (p_effective_date               => trunc(sysdate),
        p_objective_id                 => p_aligned_with_obj_id,
        p_sharing_access_code          => l_align_access,
        p_object_version_number        => l_mgr_obj_ovn,
        p_weighting_over_100_warning   => l_weightin_over_warn,
        p_weighting_appraisal_warning  => l_weightin_appraisal_warn
       );
  --
  end if;
  --
  -- Check whether the objective is shared to the current person
  --
  open chk_shr_instance(l_mgr_scorecard_id);
  fetch chk_shr_instance into l_exists;
  close chk_shr_instance;
  if nvl(l_exists,'N') <>'Y' THEN
    --
    -- Objective is not shared. Get the current objective person_id
    -- to be able to mark this person to sharing instance
    --
    open csr_get_emp_personid;
    fetch csr_get_emp_personid into l_person_id;
    close csr_get_emp_personid;
    --
    -- Create Scorecard Sharing for this person
    --
    hr_scorecard_sharing_api.create_sharing_instance
        (
         p_scorecard_id          => l_mgr_scorecard_id
        ,p_person_id             => l_person_id
        ,p_sharing_instance_id   => l_sharing_instance_id
        ,p_object_version_number => l_cur_person_ovn
        );
    --
  end if;
  --
  commit;
exception
  when others then
    raise;
end chk_cascading;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_objective >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_name                         in     varchar2
  ,p_start_date                   in     date
  ,p_owning_person_id             in     number
  ,p_target_date                  in     date      default null
  ,p_achievement_date             in     date      default null
  ,p_detail                       in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_success_criteria             in     varchar2  default null
  ,p_appraisal_id                 in     number    default null
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
  ,p_scorecard_id                 in     number    default null
  ,p_copied_from_library_id       in     number    default null
  ,p_copied_from_objective_id     in     number    default null
  ,p_aligned_with_objective_id    in     number    default null
  ,p_next_review_date             in     date      default null
  ,p_group_code                   in     varchar2  default null
  ,p_priority_code                in     varchar2  default null
  ,p_appraise_flag                in     varchar2  default null
  ,p_verified_flag                in     varchar2  default null
  ,p_target_value                 in     number    default null
  ,p_actual_value                 in     number    default null
  ,p_weighting_percent            in     number    default null
  ,p_complete_percent             in     number    default null
  ,p_uom_code                     in     varchar2  default null
  ,p_measurement_style_code       in     varchar2  default null
  ,p_measure_name                 in     varchar2  default null
  ,p_measure_type_code            in     varchar2  default null
  ,p_measure_comments             in     varchar2  default null
  ,p_sharing_access_code          in     varchar2  default null

  ,p_objective_id                 in	 number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_objective_id number;
  --
  -- Variables for IN/OUT parameters
  l_weighting_over_100_warning    boolean;
  l_weighting_appraisal_warning   boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_objective';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_objective_swi;
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
  per_obj_ins.set_base_key_value
      (p_objective_id => p_objective_id
    );
--

--
  IF ((nvl(p_copied_from_objective_id,-1) = nvl(p_aligned_with_objective_id,-2))
      and not (nvl(p_scorecard_id,-1) = -1) and p_appraisal_id is null)
  THEN

    chk_cascading (p_aligned_with_obj_id => p_aligned_with_objective_id
                   ,p_objective_id       => p_objective_id
                   ,p_scorecard_id       => p_scorecard_id
                  );
  END IF;

--
  --
  -- Call API
  --
  hr_objectives_api.create_objective
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => p_name
    ,p_start_date                   => p_start_date
    ,p_owning_person_id             => p_owning_person_id
    ,p_target_date                  => p_target_date
    ,p_achievement_date             => p_achievement_date
    ,p_detail                       => p_detail
    ,p_comments                     => p_comments
    ,p_success_criteria             => p_success_criteria
    ,p_appraisal_id                 => p_appraisal_id
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
    ,p_scorecard_id                 => p_scorecard_id
    ,p_copied_from_library_id       => p_copied_from_library_id
    ,p_copied_from_objective_id     => p_copied_from_objective_id
    ,p_aligned_with_objective_id    => p_aligned_with_objective_id
    ,p_next_review_date             => p_next_review_date
    ,p_group_code                   => p_group_code
    ,p_priority_code                => p_priority_code
    ,p_appraise_flag                => p_appraise_flag
    ,p_verified_flag                => p_verified_flag
    ,p_target_value                 => p_target_value
    ,p_actual_value                 => p_actual_value
    ,p_weighting_percent            => p_weighting_percent
    ,p_complete_percent             => p_complete_percent
    ,p_uom_code                     => p_uom_code
    ,p_measurement_style_code       => p_measurement_style_code
    ,p_measure_name                 => p_measure_name
    ,p_measure_type_code            => p_measure_type_code
    ,p_measure_comments             => p_measure_comments
    ,p_sharing_access_code          => p_sharing_access_code

    ,p_weighting_over_100_warning   => l_weighting_over_100_warning
    ,p_weighting_appraisal_warning  => l_weighting_appraisal_warning

    ,p_objective_id                 => l_objective_id
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_weighting_over_100_warning then
     fnd_message.set_name('PER', 'HR_50198_WPM_WEIGHT_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_weighting_appraisal_warning then
     fnd_message.set_name('PER', 'HR_50223_WPM_APPRAISE_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
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
    rollback to create_objective_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
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
    rollback to create_objective_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_objective;
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_objective >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_objective_id                 in     number
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
  l_proc    varchar2(72) := g_package ||'delete_objective';
  l_object_version_number per_objectives.object_version_number%TYPE;

  cursor get_object_version_number(p_obj_id per_objectives.objective_id%TYPE) is
  select object_version_number from per_objectives
  where objective_id = p_obj_id;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_objective_swi;
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

  l_object_version_number := p_object_version_number;

  if(p_object_version_number is null or p_object_version_number < 0) then
    open get_object_version_number(p_objective_id);
    fetch get_object_version_number into l_object_version_number;
    close get_object_version_number;
  end if;


  hr_objectives_api.delete_objective
    (p_validate                     => l_validate
    ,p_objective_id                 => p_objective_id
    ,p_object_version_number        => l_object_version_number
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
    rollback to delete_objective_swi;
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
    rollback to delete_objective_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_objective;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_objective >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_objective_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_target_date                  in     date      default hr_api.g_date
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_achievement_date             in     date      default hr_api.g_date
  ,p_detail                       in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_success_criteria             in     varchar2  default hr_api.g_varchar2
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
  ,p_scorecard_id                 in     number    default hr_api.g_number
  ,p_copied_from_library_id       in     number    default hr_api.g_number
  ,p_copied_from_objective_id     in     number    default hr_api.g_number
  ,p_aligned_with_objective_id    in     number    default hr_api.g_number
  ,p_next_review_date             in     date      default hr_api.g_date
  ,p_group_code                   in     varchar2  default hr_api.g_varchar2
  ,p_priority_code                in     varchar2  default hr_api.g_varchar2
  ,p_appraise_flag                in     varchar2  default hr_api.g_varchar2
  ,p_verified_flag                in     varchar2  default hr_api.g_varchar2
  ,p_target_value                 in     number    default hr_api.g_number
  ,p_actual_value                 in     number    default hr_api.g_number
  ,p_weighting_percent            in     number    default hr_api.g_number
  ,p_complete_percent             in     number    default hr_api.g_number
  ,p_uom_code                     in     varchar2  default hr_api.g_varchar2
  ,p_measurement_style_code       in     varchar2  default hr_api.g_varchar2
  ,p_measure_name                 in     varchar2  default hr_api.g_varchar2
  ,p_measure_type_code            in     varchar2  default hr_api.g_varchar2
  ,p_measure_comments             in     varchar2  default hr_api.g_varchar2
  ,p_sharing_access_code          in     varchar2  default hr_api.g_varchar2
  ,p_appraisal_id                 in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_weighting_over_100_warning    boolean;
  l_weighting_appraisal_warning   boolean;
  l_copied_from_objective_id number;
  l_aligned_with_objective_id number;
  l_appraisal_id number;
  l_scorecard_id number;
  t_copied_from_objective_id number;
  t_aligned_with_objective_id number;
  t_appraisal_id number;
  t_scorecard_id number;

  cursor get_obj_info is
  select copied_from_objective_id, aligned_with_objective_id, scorecard_id, appraisal_id
  from per_objectives
  where objective_id = p_objective_id;

  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_objective';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_objective_swi;
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

  open get_obj_info;
  fetch get_obj_info into t_copied_from_objective_id, t_aligned_with_objective_id, t_scorecard_id, t_appraisal_id;
  close get_obj_info;


  l_copied_from_objective_id := p_copied_from_objective_id;
  l_aligned_with_objective_id := p_aligned_with_objective_id;
  l_scorecard_id := p_scorecard_id;
  l_appraisal_id := p_appraisal_id;

  if(p_copied_from_objective_id = hr_api.g_number) then
    l_copied_from_objective_id := t_copied_from_objective_id;
  end if;

  if(p_aligned_with_objective_id = hr_api.g_number) then
    l_aligned_with_objective_id := t_aligned_with_objective_id;
  end if;

  if(p_scorecard_id = hr_api.g_number) then
    l_scorecard_id := t_scorecard_id;
  end if;

  if(p_appraisal_id = hr_api.g_number) then
    l_appraisal_id := t_appraisal_id;
  end if;

--
  IF ((nvl(l_copied_from_objective_id,-1) = nvl(l_aligned_with_objective_id,-2))
      and not (nvl(l_scorecard_id,-1) = -1) and l_appraisal_id is null)
  THEN

    chk_cascading (p_aligned_with_obj_id => p_aligned_with_objective_id
                   ,p_objective_id       => p_objective_id
                   ,p_scorecard_id       => p_scorecard_id
                  );
  END IF;

--
  --
  -- Call API
  --
  hr_objectives_api.update_objective
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_objective_id                 => p_objective_id
    ,p_object_version_number        => p_object_version_number
    ,p_name                         => p_name
    ,p_target_date                  => p_target_date
    ,p_start_date                   => p_start_date
    ,p_achievement_date             => p_achievement_date
    ,p_detail                       => p_detail
    ,p_comments                     => p_comments
    ,p_success_criteria             => p_success_criteria
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
    ,p_scorecard_id                 => p_scorecard_id
    ,p_copied_from_library_id       => p_copied_from_library_id
    ,p_copied_from_objective_id     => p_copied_from_objective_id
    ,p_aligned_with_objective_id    => p_aligned_with_objective_id
    ,p_next_review_date             => p_next_review_date
    ,p_group_code                   => p_group_code
    ,p_priority_code                => p_priority_code
    ,p_appraise_flag                => p_appraise_flag
    ,p_verified_flag                => p_verified_flag
    ,p_target_value                 => p_target_value
    ,p_actual_value                 => p_actual_value
    ,p_weighting_percent            => p_weighting_percent
    ,p_complete_percent             => p_complete_percent
    ,p_uom_code                     => p_uom_code
    ,p_measurement_style_code       => p_measurement_style_code
    ,p_measure_name                 => p_measure_name
    ,p_measure_type_code            => p_measure_type_code
    ,p_measure_comments             => p_measure_comments
    ,p_sharing_access_code          => p_sharing_access_code

    ,p_weighting_over_100_warning   => l_weighting_over_100_warning
    ,p_weighting_appraisal_warning  => l_weighting_appraisal_warning
    ,p_appraisal_id                 => p_appraisal_id

    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_weighting_over_100_warning then
     fnd_message.set_name('PER', 'HR_50198_WPM_WEIGHT_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_weighting_appraisal_warning then
     fnd_message.set_name('PER', 'HR_50223_WPM_APPRAISE_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
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
    rollback to update_objective_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
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
    rollback to update_objective_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_objective;

-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------

Procedure process_api
( p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState VARCHAR2(2);
   l_return_status VARCHAR2(1);
   l_object_version_number number;
   l_commitElement xmldom.DOMElement;
   l_parser xmlparser.Parser;
   l_CommitNode xmldom.DOMNode;
   l_proc    varchar2(72) := g_package || 'process_api';
   l_aligned_with_objective_id per_objectives.aligned_with_objective_id%type;

   cursor chk_aligned_with_obj_id(p_obj_id per_objectives.objective_id%type ) is
   SELECT aligned_with_objective_id
   FROM per_objectives
   WHERE objective_id = p_obj_id;


BEGIN

   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);

   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));

   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');
   l_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');

   if l_postState = '0' then

        create_objective
      ( p_validate                     => p_validate
       ,p_effective_date               => p_effective_date
       ,p_business_group_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId',null)
       ,p_name                         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Name',null)
       ,p_start_date                   => hr_transaction_swi.getDateValue(l_CommitNode,'StartDate',null)
       ,p_owning_person_id             => hr_transaction_swi.getNumberValue(l_CommitNode,'OwningPersonId',null)
       ,p_target_date                  => hr_transaction_swi.getDateValue(l_CommitNode,'TargetDate',null)
       ,p_achievement_date             => hr_transaction_swi.getDateValue(l_CommitNode,'AchievementDate',null)
       ,p_detail                       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Detail',null)
       ,p_comments                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments',null)
       ,p_success_criteria             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SuccessCriteria',null)
       ,p_appraisal_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'AppraisalId',null)
       ,p_attribute_category           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',null)
       ,p_attribute1                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',null)
       ,p_attribute2                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',null)
       ,p_attribute3                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',null)
       ,p_attribute4                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',null)
       ,p_attribute5                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',null)
       ,p_attribute6                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',null)
       ,p_attribute7                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',null)
       ,p_attribute8                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',null)
       ,p_attribute9                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',null)
       ,p_attribute10                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',null)
       ,p_attribute11                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',null)
       ,p_attribute12                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',null)
       ,p_attribute13                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',null)
       ,p_attribute14                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',null)
       ,p_attribute15                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',null)
       ,p_attribute16                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',null)
       ,p_attribute17                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',null)
       ,p_attribute18                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',null)
       ,p_attribute19                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',null)
       ,p_attribute20                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',null)

       ,p_attribute21                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21',null)
       ,p_attribute22                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22',null)
       ,p_attribute23                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23',null)
       ,p_attribute24                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24',null)
       ,p_attribute25                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25',null)
       ,p_attribute26                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26',null)
       ,p_attribute27                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27',null)
       ,p_attribute28                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28',null)
       ,p_attribute29                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29',null)
       ,p_attribute30                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30',null)

        ,p_scorecard_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'ScorecardId',null)
        ,p_copied_from_library_id       => hr_transaction_swi.getNumberValue(l_CommitNode,'CopiedFromLibraryId',null)
        ,p_copied_from_objective_id     => hr_transaction_swi.getNumberValue(l_CommitNode,'CopiedFromObjectiveId',null)
        ,p_aligned_with_objective_id    => hr_transaction_swi.getNumberValue(l_CommitNode,'AlignedWithObjectiveId',null)
        ,p_next_review_date             => hr_transaction_swi.getDateValue(l_CommitNode,'NextReviewDate',null)
        ,p_group_code                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'GroupCode',null)
        ,p_priority_code                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PriorityCode',null)
        ,p_appraise_flag                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AppraiseFlag',null)
        ,p_verified_flag                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'VerifiedFlag',null)
        ,p_target_value                 => hr_transaction_swi.getNumberValue(l_CommitNode,'TargetValue',null)
        ,p_actual_value                 => hr_transaction_swi.getNumberValue(l_CommitNode,'ActualValue',null)
        ,p_weighting_percent            => hr_transaction_swi.getNumberValue(l_CommitNode,'WeightingPercent',null)
        ,p_complete_percent             => hr_transaction_swi.getNumberValue(l_CommitNode,'CompletePercent',null)
        ,p_uom_code                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'UomCode',null)
        ,p_measurement_style_code       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'MeasurementStyleCode',null)
        ,p_measure_name                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'MeasureName',null)
        ,p_measure_type_code            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'MeasureTypeCode',null)
        ,p_measure_comments             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'MeasureComments',null)
        ,p_sharing_access_code          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SharingAccessCode',null)

       ,p_objective_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectiveId',null)
       ,p_object_version_number        => l_object_version_number
       ,p_return_status                => l_return_status
      );

   elsif l_postState = '2' then

   --7795134 check_cascade will directly process the AlignedWithObjectiveId from transaction doc.Changed the value before calling the api

   if( hr_transaction_swi.getNumberValue(l_CommitNode,'AlignedWithObjectiveId',null) = hr_api.g_number ) then
      open chk_aligned_with_obj_id(hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectiveId'));
       fetch chk_aligned_with_obj_id into l_aligned_with_objective_id;
      close chk_aligned_with_obj_id;
   end if;

        update_objective
      ( p_validate                     => p_validate
       ,p_effective_date               => p_effective_date
       ,p_objective_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectiveId')
       ,p_object_version_number        => l_object_version_number
       ,p_name                         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Name')
       ,p_target_date                  => hr_transaction_swi.getDateValue(l_CommitNode,'TargetDate')
       ,p_start_date                   => hr_transaction_swi.getDateValue(l_CommitNode,'StartDate')
       ,p_achievement_date             => hr_transaction_swi.getDateValue(l_CommitNode,'AchievementDate')
       ,p_detail                       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Detail')
       ,p_comments                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments')
       ,p_success_criteria             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SuccessCriteria')
       ,p_attribute_category           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory')
       ,p_attribute1                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1')
       ,p_attribute2                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2')
       ,p_attribute3                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3')
       ,p_attribute4                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4')
       ,p_attribute5                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5')
       ,p_attribute6                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6')
       ,p_attribute7                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7')
       ,p_attribute8                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8')
       ,p_attribute9                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9')
       ,p_attribute10                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10')
       ,p_attribute11                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11')
       ,p_attribute12                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12')
       ,p_attribute13                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13')
       ,p_attribute14                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14')
       ,p_attribute15                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15')
       ,p_attribute16                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16')
       ,p_attribute17                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17')
       ,p_attribute18                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18')
       ,p_attribute19                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19')
       ,p_attribute20                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20')

       ,p_attribute21                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21')
       ,p_attribute22                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22')
       ,p_attribute23                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23')
       ,p_attribute24                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24')
       ,p_attribute25                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25')
       ,p_attribute26                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26')
       ,p_attribute27                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27')
       ,p_attribute28                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28')
       ,p_attribute29                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29')
       ,p_attribute30                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30')
       ,p_scorecard_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'ScorecardId')
       ,p_copied_from_library_id       => hr_transaction_swi.getNumberValue(l_CommitNode,'CopiedFromLibraryId')
       ,p_copied_from_objective_id     => hr_transaction_swi.getNumberValue(l_CommitNode,'CopiedFromObjectiveId')
--      ,p_aligned_with_objective_id    => hr_transaction_swi.getNumberValue(l_CommitNode,'AlignedWithObjectiveId')
       ,p_aligned_with_objective_id    => l_aligned_with_objective_id
       ,p_next_review_date             => hr_transaction_swi.getDateValue(l_CommitNode,'NextReviewDate')
       ,p_group_code                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'GroupCode')
       ,p_priority_code                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PriorityCode')
       ,p_appraise_flag                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AppraiseFlag')
       ,p_verified_flag                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'VerifiedFlag')
       ,p_target_value                 => hr_transaction_swi.getNumberValue(l_CommitNode,'TargetValue')
       ,p_actual_value                 => hr_transaction_swi.getNumberValue(l_CommitNode,'ActualValue')
       ,p_weighting_percent            => hr_transaction_swi.getNumberValue(l_CommitNode,'WeightingPercent')
       ,p_complete_percent             => hr_transaction_swi.getNumberValue(l_CommitNode,'CompletePercent')
       ,p_uom_code                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'UomCode')
       ,p_measurement_style_code       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'MeasurementStyleCode')
       ,p_measure_name                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'MeasureName')
       ,p_measure_type_code            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'MeasureTypeCode')
       ,p_measure_comments             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'MeasureComments')
       ,p_sharing_access_code          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SharingAccessCode')
       ,p_appraisal_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'AppraisalId')
       ,p_return_status                => l_return_status
      );

   elsif l_postState = '3' then

      delete_objective
      ( p_validate                     => p_validate
       ,p_objective_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectiveId')
       ,p_object_version_number        => l_object_version_number
       ,p_return_status                => l_return_status
      );

      p_return_status := l_return_status;

   end if;

   hr_utility.set_location('Exiting:' || l_proc,40);

END process_api;

end hr_objectives_swi;

/
