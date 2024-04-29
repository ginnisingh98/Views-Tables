--------------------------------------------------------
--  DDL for Package Body HR_OBJECTIVE_LIBRARY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_OBJECTIVE_LIBRARY_SWI" As
/* $Header: pepmlswi.pkb 120.4.12010000.2 2008/11/24 14:51:46 rsykam ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_objective_library_swi.';

--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_library_objective >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_library_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_objective_name               in     varchar2
  ,p_valid_from                   in     date      default null
  ,p_valid_to                     in     date      default null
  ,p_target_date                  in     date      default null
  ,p_next_review_date             in     date      default null
  ,p_group_code                   in     varchar2  default null
  ,p_priority_code                in     varchar2  default null
  ,p_appraise_flag                in     varchar2  default 'Y'
  ,p_weighting_percent            in     number    default null
  ,p_measurement_style_code       in     varchar2  default 'N_M'
  ,p_measure_name                 in     varchar2  default null
  ,p_target_value                 in     number    default null
  ,p_uom_code                     in     varchar2  default null
  ,p_measure_type_code            in     varchar2  default null
  ,p_measure_comments             in     varchar2  default null
  ,p_eligibility_type_code        in     varchar2  default 'N_P'
  ,p_details                      in     varchar2  default null
  ,p_success_criteria             in     varchar2  default null
  ,p_comments                     in     varchar2  default null
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
  ,p_objective_id                 in out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_duplicate_name_warning        boolean;
  l_weighting_over_100_warning    boolean;
  l_weighting_appraisal_warning   boolean;
  l_objective_id number := 0;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_library_objective';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_library_objective_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
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

     per_pml_ins.set_base_key_value
     (p_objective_id => p_objective_id
     );

  --
  -- Call API
  --
  hr_objective_library_api.create_library_objective
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_objective_name               => p_objective_name
    ,p_valid_from                   => p_valid_from
    ,p_valid_to                     => p_valid_to
    ,p_target_date                  => p_target_date
    ,p_next_review_date             => p_next_review_date
    ,p_group_code                   => p_group_code
    ,p_priority_code                => p_priority_code
    ,p_appraise_flag                => p_appraise_flag
    ,p_weighting_percent            => p_weighting_percent
    ,p_measurement_style_code       => p_measurement_style_code
    ,p_measure_name                 => p_measure_name
    ,p_target_value                 => p_target_value
    ,p_uom_code                     => p_uom_code
    ,p_measure_type_code            => p_measure_type_code
    ,p_measure_comments             => p_measure_comments
    ,p_eligibility_type_code        => p_eligibility_type_code
    ,p_details                      => p_details
    ,p_success_criteria             => p_success_criteria
    ,p_comments                     => p_comments
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
    ,p_objective_id                 => p_objective_id
    ,p_object_version_number        => p_object_version_number
    ,p_duplicate_name_warning       => l_duplicate_name_warning
    ,p_weighting_over_100_warning   => l_weighting_over_100_warning
    ,p_weighting_appraisal_warning  => l_weighting_appraisal_warning
    );
  --
    p_return_status := hr_multi_message.get_return_status;
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
if(p_return_status ='S')then
      if l_duplicate_name_warning then
         fnd_message.set_name('PER', 'HR_50181_WPM_OBJ_EXIST_WARN');
          hr_multi_message.add
            (p_message_type => hr_multi_message.g_warning_msg
            );
            p_return_status:='W';
      end if;
      if l_weighting_over_100_warning then
         fnd_message.set_name('PER', 'HR_50198_WPM_WEIGHT_WARN');
          hr_multi_message.add
            (p_message_type => hr_multi_message.g_warning_msg
            );
             p_return_status:='W';

      end if;
      if l_weighting_appraisal_warning then
         fnd_message.set_name('PER', 'HR_50223_WPM_APPRAISE_WARN');
          hr_multi_message.add
            (p_message_type => hr_multi_message.g_warning_msg
            );
             p_return_status:='W';
      end if;  --
   end if;
  --
  --
  hr_multi_message.disable_message_list;
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_library_objective_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    -- p_objective_id                 := null;
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
    rollback to create_library_objective_swi;
    p_return_status := hr_multi_message.get_return_status_disable;
    if p_return_status<>'E' and hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    -- p_objective_id                 := null;
    p_object_version_number        := null;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_library_objective;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_library_objective >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_library_objective
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
  l_proc    varchar2(72) := g_package ||'delete_library_objective';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_library_objective_swi;
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
  hr_objective_library_api.delete_library_objective
    (p_validate                     => l_validate
    ,p_objective_id                 => p_objective_id
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
    rollback to delete_library_objective_swi;
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
    rollback to delete_library_objective_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_library_objective;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_library_objective >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_library_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_objective_id                 in     number
  ,p_objective_name               in     varchar2  default hr_api.g_varchar2
  ,p_valid_from                   in     date      default hr_api.g_date
  ,p_valid_to                     in     date      default hr_api.g_date
  ,p_target_date                  in     date      default hr_api.g_date
  ,p_next_review_date             in     date      default hr_api.g_date
  ,p_group_code                   in     varchar2  default hr_api.g_varchar2
  ,p_priority_code                in     varchar2  default hr_api.g_varchar2
  ,p_appraise_flag                in     varchar2  default hr_api.g_varchar2
  ,p_weighting_percent            in     number    default hr_api.g_number
  ,p_measurement_style_code       in     varchar2  default hr_api.g_varchar2
  ,p_measure_name                 in     varchar2  default hr_api.g_varchar2
  ,p_target_value                 in     number    default hr_api.g_number
  ,p_uom_code                     in     varchar2  default hr_api.g_varchar2
  ,p_measure_type_code            in     varchar2  default hr_api.g_varchar2
  ,p_measure_comments             in     varchar2  default hr_api.g_varchar2
  ,p_eligibility_type_code        in     varchar2  default hr_api.g_varchar2
  ,p_details                      in     varchar2  default hr_api.g_varchar2
  ,p_success_criteria             in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
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
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_duplicate_name_warning        boolean;
  l_weighting_over_100_warning    boolean;
  l_weighting_appraisal_warning   boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_library_objective';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_library_objective_swi;
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
  hr_objective_library_api.update_library_objective
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_objective_id                 => p_objective_id
    ,p_objective_name               => p_objective_name
    ,p_valid_from                   => p_valid_from
    ,p_valid_to                     => p_valid_to
    ,p_target_date                  => p_target_date
    ,p_next_review_date             => p_next_review_date
    ,p_group_code                   => p_group_code
    ,p_priority_code                => p_priority_code
    ,p_appraise_flag                => p_appraise_flag
    ,p_weighting_percent            => p_weighting_percent
    ,p_measurement_style_code       => p_measurement_style_code
    ,p_measure_name                 => p_measure_name
    ,p_target_value                 => p_target_value
    ,p_uom_code                     => p_uom_code
    ,p_measure_type_code            => p_measure_type_code
    ,p_measure_comments             => p_measure_comments
    ,p_eligibility_type_code        => p_eligibility_type_code
    ,p_details                      => p_details
    ,p_success_criteria             => p_success_criteria
    ,p_comments                     => p_comments
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
    ,p_duplicate_name_warning       => l_duplicate_name_warning
    ,p_weighting_over_100_warning   => l_weighting_over_100_warning
    ,p_weighting_appraisal_warning  => l_weighting_appraisal_warning
    );
  --
     p_return_status:=hr_multi_message.get_return_status;
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
 if(p_return_status ='S')then
  if l_duplicate_name_warning then
     fnd_message.set_name('PER', 'HR_50181_WPM_OBJ_EXIST_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
      p_return_status:='W';
  end if;
  if l_weighting_over_100_warning then
     fnd_message.set_name('PER', 'HR_50198_WPM_WEIGHT_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
      p_return_status:='W';
  end if;
  if l_weighting_appraisal_warning then
     fnd_message.set_name('PER', 'HR_50223_WPM_APPRAISE_WARN');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
       p_return_status:='W';
  end if;  --
  end if;
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  hr_multi_message.disable_message_list;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_library_objective_swi;
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
    rollback to update_library_objective_swi;
    p_return_status := hr_multi_message.get_return_status_disable;
    if  p_return_status<>'E' and  hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;

    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_library_objective;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_eligy_profile >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_name                         Yes  varchar2
--   p_elig_pstn_flag               No   varchar2
--   p_elig_grd_flag                No   varchar2
--   p_elig_org_unit_flag           No   varchar2
--   p_elig_job_flag                No   varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure create_eligy_profile
  (p_validate             in    number default hr_api.g_false_num
  ,p_name                 in    varchar2  default null
  ,p_bnft_cagr_prtn_cd    in    varchar2  default null
  ,p_stat_cd              in    varchar2  default null
  ,p_asmt_to_use_cd       in    varchar2  default null
  ,p_eligy_prfl_id        in out  nocopy number
  ,p_elig_grd_flag        in    varchar2  default 'N'
  ,p_elig_org_unit_flag   in    varchar2  default 'N'
  ,p_elig_job_flag        in    varchar2  default 'N'
  ,p_elig_pstn_flag       in    varchar2  default 'N'
  ,p_object_version_number out nocopy number
  ,p_business_group_id    in    number
  ,p_effective_date       in    date
  ,p_effective_start_date   out nocopy date
  ,p_effective_end_date     out nocopy date
  ,p_return_status          out nocopy varchar2
  ) is

  --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_eligy_profile';
  l_eligy_prfl_id number;
  msgName varchar2(100);
begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_eligy_profile_swi;
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
  ben_elp_ins.set_base_key_value(p_eligy_prfl_id => p_eligy_prfl_id);
  --
  -- Call API
  --

    hr_objective_library_api.create_eligy_profile
     (p_validate              =>  l_validate
     ,p_name                  =>  p_name
     ,p_bnft_cagr_prtn_cd     =>  p_bnft_cagr_prtn_cd
     ,p_stat_cd               =>  p_stat_cd
     ,p_asmt_to_use_cd        =>  p_asmt_to_use_cd
     ,p_eligy_prfl_id         =>  l_eligy_prfl_id
     ,p_elig_grd_flag         =>  p_elig_grd_flag
     ,p_elig_org_unit_flag    =>  p_elig_org_unit_flag
     ,p_elig_job_flag         =>  p_elig_job_flag
     ,p_elig_pstn_flag        =>  p_elig_pstn_flag
     ,p_object_version_number =>  p_object_version_number
     ,p_business_group_id     =>  p_business_group_id
     ,p_effective_date        =>  p_effective_date
     ,p_effective_start_date  =>  p_effective_start_date
     ,p_effective_end_date    =>  p_effective_end_date
     );

     p_eligy_prfl_id := l_eligy_prfl_id;
     p_return_status := hr_multi_message.get_return_status_disable;
     hr_utility.set_location(' Leaving:' || l_proc,20);

exception
  when hr_multi_message.error_message_exist then

    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_eligy_profile_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_eligy_prfl_id                := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;

    when others then
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_eligy_profile_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    if(fnd_message.get_number('BEN','BEN_91009_NAME_NOT_UNIQUE') <> null)then
     fnd_message.set_name('PER', 'HR_51795_WPM_ELIGY_NAME_EXIST');
     hr_multi_message.add
        (p_message_type => hr_multi_message.G_ERROR_MSG
        );
    end if;

    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;

    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
end create_eligy_profile;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_eligy_profile >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_profile
 ( p_validate             in    number  default hr_api.g_false_num
  ,p_effective_date       in    date
  ,p_business_group_id    in    number
  ,p_name                 in     varchar2  default null
  ,p_bnft_cagr_prtn_cd     in    varchar2  default null
  ,p_stat_cd               in    varchar2  default null
  ,p_asmt_to_use_cd        in    varchar2  default null
  ,p_elig_grd_flag         in    varchar2  default 'N'
  ,p_elig_org_unit_flag    in    varchar2  default 'N'
  ,p_elig_job_flag         in    varchar2  default 'N'
  ,p_elig_pstn_flag        in    varchar2  default 'N'
  ,p_eligy_prfl_id         in   number
  ,p_object_version_number in out nocopy number
  ,p_effective_start_date   out nocopy date
  ,p_effective_end_date     out nocopy date
  ,p_datetrack_mode   in varchar2
  ,p_return_status          out nocopy varchar2
 ) is
 -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_eligy_position';

 begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_eligy_profile_swi;
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
  l_validate := hr_api.constant_to_boolean(p_constant_value => p_validate);
  --
  HR_OBJECTIVE_LIBRARY_api.update_eligy_profile
    (
       p_validate              =>    l_validate
      ,p_eligy_prfl_id         =>    p_eligy_prfl_id
      ,p_name                  =>    p_name
      ,p_stat_cd               =>    p_stat_cd
      ,p_asmt_to_use_cd        =>    p_asmt_to_use_cd
      ,p_elig_grd_flag         =>    p_elig_grd_flag
      ,p_elig_org_unit_flag    =>    p_elig_org_unit_flag
      ,p_elig_job_flag         =>    p_elig_job_flag
      ,p_elig_pstn_flag        =>    p_elig_pstn_flag
      ,p_object_version_number =>    p_object_version_number
      ,p_effective_start_date  =>    p_effective_start_date
      ,p_effective_end_date    =>    p_effective_end_date
      ,p_datetrack_mode        =>    p_datetrack_mode
      ,p_business_group_id     =>    p_business_group_id
      ,p_effective_date        =>    p_effective_date
   );

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
    rollback to update_eligy_profile_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;

when others then
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_eligy_profile_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    if(fnd_message.get_number('BEN','BEN_91009_NAME_NOT_UNIQUE')<> null)then
     fnd_message.set_name('PER', 'HR_51795_WPM_ELIGY_NAME_EXIST');
     hr_multi_message.add
        (p_message_type => hr_multi_message.G_ERROR_MSG
        );
    end if;

    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;

    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);

end update_eligy_profile;
-- ----------------------------------------------------------------------------
-- |--------------------------< create_eligy_object >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_object
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_obj_id                    in out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number
  ,p_table_name                     in  varchar2
  ,p_column_name                    in  varchar2
  ,p_column_value                   in  varchar2
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 ) is
  --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_eligy_obj';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_eligy_object_swi;
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
     ben_beo_ins.set_base_key_value
     (p_elig_obj_id  => p_elig_obj_id);

  --
  -- Call API
  --
  hr_objective_library_api.create_eligy_object
   (p_validate                =>  l_validate
   ,p_elig_obj_id             =>  p_elig_obj_id
   ,p_effective_start_date    =>  p_effective_start_date
   ,p_effective_end_date      =>  p_effective_end_date
   ,p_business_group_id       =>  p_business_group_id
   ,p_table_name              =>  p_table_name
   ,p_column_name             =>  p_column_name
   ,p_column_value            =>  p_column_value
   ,p_object_version_number   =>  p_object_version_number
   ,p_effective_date          =>  p_effective_date
   );

exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_eligy_object_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_elig_obj_id                  := null;
    p_effective_start_date         := null;
    p_effective_end_date	   := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end create_eligy_object;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_eligy_object >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_object
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_obj_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_table_name                     in  varchar2  default hr_api.g_varchar2
  ,p_column_name                    in  varchar2  default hr_api.g_varchar2
  ,p_column_value                   in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
) is
  --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_eligy_object';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_eligy_object_swi;
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
    hr_objective_library_api.update_eligy_object
     (p_validate                =>  l_validate
     ,p_elig_obj_id             =>  p_elig_obj_id
     ,p_effective_start_date    =>  p_effective_start_date
     ,p_effective_end_date      =>  p_effective_end_date
     ,p_business_group_id       =>  p_business_group_id
     ,p_table_name              =>  p_table_name
     ,p_column_name             =>  p_column_name
     ,p_column_value            =>  p_column_value
     ,p_object_version_number   =>  p_object_version_number
     ,p_effective_date          =>  p_effective_date
     ,p_datetrack_mode          =>  p_datetrack_mode
     );
 hr_utility.set_location(' Leaving:' || l_proc,20);
  --

exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_eligy_object_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end update_eligy_object;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_eligy_object >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_object
  (p_validate                       number default hr_api.g_false_num
  ,p_elig_obj_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ) is
--
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_eligy_object';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_eligy_object_swi;
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
    hr_objective_library_api.delete_eligy_object
     (p_validate                =>  l_validate
     ,p_elig_obj_id             =>  p_elig_obj_id
     ,p_effective_start_date    =>  p_effective_start_date
     ,p_effective_end_date      =>  p_effective_end_date
     ,p_object_version_number   =>  p_object_version_number
     ,p_effective_date          =>  p_effective_date
     ,p_datetrack_mode          =>  p_datetrack_mode
     );
 hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_eligy_object_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end delete_eligy_object;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_elig_obj_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_elig_obj_elig_prfl
  (p_validate                   in    number default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id       in out nocopy number
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ,p_business_group_id          in    number    default null
  ,p_elig_obj_id                in    number    default null
  ,p_elig_prfl_id               in    number    default null
  ,p_object_version_number        out nocopy number
  ,p_effective_date             in    date
 ) is
 --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_elig_obj_elig_prfl';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_elig_obj_elig_prfl_swi;
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
     ben_bep_ins.set_base_key_value
      (p_elig_obj_elig_prfl_id  => p_elig_obj_elig_prfl_id);

  --
  -- Call API
  --
  hr_objective_library_api.create_elig_obj_elig_prfl
    (p_validate                 => l_validate
    ,p_elig_obj_elig_prfl_id    => p_elig_obj_elig_prfl_id
    ,p_effective_start_date     => p_effective_start_date
    ,p_effective_end_date       => p_effective_end_date
    ,p_business_group_id        => p_business_group_id
    ,p_elig_obj_id              => p_elig_obj_id
    ,p_elig_prfl_id             => p_elig_prfl_id
    ,p_object_version_number    => p_object_version_number
    ,p_effective_date           => p_effective_date
    );

   hr_utility.set_location(' Leaving:' || l_proc,20);
  --

exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_elig_obj_elig_prfl_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_elig_obj_elig_prfl_id        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);


end create_elig_obj_elig_prfl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_elig_obj_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_elig_obj_elig_prfl
  (p_validate                       in number default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_elig_obj_id                    in  number    default hr_api.g_number
  ,p_elig_prfl_id                   in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
 --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_elig_obj_elig_prfl';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_elig_obj_elig_prfl_swi;
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
  hr_objective_library_api.update_elig_obj_elig_prfl
    (p_validate                 => l_validate
    ,p_elig_obj_elig_prfl_id    => p_elig_obj_elig_prfl_id
    ,p_effective_start_date     => p_effective_start_date
    ,p_effective_end_date       => p_effective_end_date
    ,p_elig_obj_id              => p_elig_obj_id
    ,p_elig_prfl_id             => p_elig_prfl_id
    ,p_object_version_number    => p_object_version_number
    ,p_effective_date           => p_effective_date
    ,p_datetrack_mode           => p_datetrack_mode
    );
hr_utility.set_location(' Leaving:' || l_proc,20);
  --

exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_elig_obj_elig_prfl_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end update_elig_obj_elig_prfl;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_elig_obj_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_elig_obj_elig_prfl
  (p_validate                       in number default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_elig_obj_elig_prfl';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_elig_obj_elig_prfl_swi;
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
  hr_objective_library_api.delete_elig_obj_elig_prfl
    (p_validate                 => l_validate
    ,p_elig_obj_elig_prfl_id    => p_elig_obj_elig_prfl_id
    ,p_effective_start_date     => p_effective_start_date
    ,p_effective_end_date       => p_effective_end_date
    ,p_object_version_number    => p_object_version_number
    ,p_effective_date           => p_effective_date
    ,p_datetrack_mode           => p_datetrack_mode
    );
hr_utility.set_location(' Leaving:' || l_proc,20);
  --

exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_elig_obj_elig_prfl_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end delete_elig_obj_elig_prfl;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_grade >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_grade
 (p_validate                     in    number default hr_api.g_false_num
 ,p_elig_grd_prte_id             in out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_grade_id                     in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
) is
 --
  -- Variables for API Boolean parameters
  l_validate    boolean;

  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_eligy_grade';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_eligy_grade_swi;
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
  --
   ben_egr_ins.set_base_key_value(p_elig_grd_prte_id  => p_elig_grd_prte_id);

  -- Call API
  --
  hr_objective_library_api.create_eligy_grade
    (p_validate                => l_validate
    ,p_elig_grd_prte_id        => p_elig_grd_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_grade_id                => p_grade_id
    ,p_ordr_num                => p_ordr_num
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
  --

exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_eligy_grade_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_elig_grd_prte_id             := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end create_eligy_grade;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_grade >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_grade
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_grd_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_grade_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
 --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_eligy_grade';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_eligy_grade_swi;
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
  hr_objective_library_api.update_eligy_grade
    (p_validate                => l_validate
    ,p_elig_grd_prte_id        => p_elig_grd_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_grade_id                => p_grade_id
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
--
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_eligy_grade_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end update_eligy_grade;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_grade >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_grade
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_grd_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_eligy_grade';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_eligy_grade_swi;
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
  hr_objective_library_api.delete_eligy_grade
    (p_validate                => l_validate
    ,p_elig_grd_prte_id        => p_elig_grd_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
--
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_eligy_grade_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end delete_eligy_grade;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_org >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_org
 (p_validate                     in    number default hr_api.g_false_num
 ,p_elig_org_unit_prte_id          in out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_organization_id                     in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
) is
 --
  -- Variables for API Boolean parameters
  l_validate    boolean;

  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_eligy_org';
begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_eligy_org_swi;
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
  ben_eou_ins.set_base_key_value(p_elig_org_unit_prte_id  => p_elig_org_unit_prte_id);
  --
  -- Call API
  --
  hr_objective_library_api.create_eligy_org
    (p_validate                => l_validate
    ,p_elig_org_unit_prte_id   => p_elig_org_unit_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_organization_id         => p_organization_id
    ,p_ordr_num                => p_ordr_num
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
  --

exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_eligy_org_swi;
    --
--
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_elig_org_unit_prte_id             := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end create_eligy_org;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_org >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_org
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_org_unit_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_organization_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
 ,p_datetrack_mode                 in  varchar2
  ) is
 --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_eligy_org';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_eligy_org_swi;
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
  hr_objective_library_api.update_eligy_org
    (p_validate                => l_validate
    ,p_elig_org_unit_prte_id        => p_elig_org_unit_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_organization_id         => p_organization_id
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
--
exception
  when hr_multi_message.error_message_exist then
  --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_eligy_org_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end update_eligy_org;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_org >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_org
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_org_unit_prte_id               in  number
  ,p_effective_start_date           out nocopy date
,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_eligy_org';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_eligy_org_swi;
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
  hr_objective_library_api.delete_eligy_org
    (p_validate                => l_validate
    ,p_elig_org_unit_prte_id        => p_elig_org_unit_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
--
exception
  when hr_multi_message.error_message_exist then
   --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_eligy_org_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end delete_eligy_org;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_job >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_job
 (p_validate                     in    number default hr_api.g_false_num
 ,p_elig_job_prte_id              in out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_job_id                     in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
) is
 --
  -- Variables for API Boolean parameters
  l_validate    boolean;

  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_eligy_job';
begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_eligy_job_swi;
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
    ben_ejp_ins.set_base_key_value(p_elig_job_prte_id  => p_elig_job_prte_id);
  -- Call API
  --
  hr_objective_library_api.create_eligy_job
    (p_validate                => l_validate
    ,p_elig_job_prte_id        => p_elig_job_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_job_id                => p_job_id
    ,p_ordr_num                => p_ordr_num
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
  --

exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_eligy_job_swi;
    --
--
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_elig_job_prte_id             := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end create_eligy_job;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_job >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_job
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_job_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_job_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
 ,p_datetrack_mode                 in  varchar2
  ) is
 --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_eligy_job';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_eligy_job_swi;
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
  hr_objective_library_api.update_eligy_job
    (p_validate                => l_validate
    ,p_elig_job_prte_id        => p_elig_job_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_job_id                => p_job_id
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
--
exception
  when hr_multi_message.error_message_exist then
  --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_eligy_job_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end update_eligy_job;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_job >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_job
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_job_prte_id               in  number
  ,p_effective_start_date           out nocopy date
,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_eligy_job';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_eligy_job_swi;
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
  hr_objective_library_api.delete_eligy_job
    (p_validate                => l_validate
    ,p_elig_job_prte_id        => p_elig_job_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
--
exception
  when hr_multi_message.error_message_exist then
   --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_eligy_job_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end delete_eligy_job;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_position>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_position
 (p_validate                     in    number default hr_api.g_false_num
 ,p_elig_pstn_prte_id             in out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_position_id                     in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
) is
 --
  -- Variables for API Boolean parameters
  l_validate    boolean;

  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_eligy_position';
begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_eligy_position_swi;
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
   ben_eps_ins.set_base_key_value(p_elig_pstn_prte_id  => p_elig_pstn_prte_id);
  --
  -- Call API
  --
  hr_objective_library_api.create_eligy_position
    (p_validate                => l_validate
    ,p_elig_pstn_prte_id        => p_elig_pstn_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_position_id                => p_position_id
    ,p_ordr_num                => p_ordr_num
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
  --

exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_eligy_position_swi;
    --
--
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_elig_pstn_prte_id             := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end create_eligy_position;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_position >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_position
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_pstn_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_position_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
 ,p_datetrack_mode                 in  varchar2
  ) is
 --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_eligy_position';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_eligy_position_swi;
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
  hr_objective_library_api.update_eligy_position
    (p_validate                => l_validate
    ,p_elig_pstn_prte_id        => p_elig_pstn_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_business_group_id       => p_business_group_id
    ,p_eligy_prfl_id           => p_eligy_prfl_id
    ,p_position_id             => p_position_id
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
--
exception
  when hr_multi_message.error_message_exist then
  --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_eligy_position_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end update_eligy_position;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_eligy_position >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_position
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_pstn_prte_id               in  number
  ,p_effective_start_date           out nocopy date
,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate    boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_eligy_position';

begin
   hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_eligy_position_swi;
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
  hr_objective_library_api.delete_eligy_position
    (p_validate                => l_validate
    ,p_elig_pstn_prte_id        => p_elig_pstn_prte_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_object_version_number   => p_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    );

hr_utility.set_location(' Leaving:' || l_proc,20);
--
exception
  when hr_multi_message.error_message_exist then
   --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_eligy_position_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;

    hr_utility.set_location(' Leaving:' || l_proc, 30);

end delete_eligy_position;
--

end hr_objective_library_swi;

/
