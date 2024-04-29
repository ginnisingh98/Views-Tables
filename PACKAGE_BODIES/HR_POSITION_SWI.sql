--------------------------------------------------------
--  DDL for Package Body HR_POSITION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_POSITION_SWI" As
/* $Header: hrposswi.pkb 115.2 2003/05/22 08:03:10 ndorai noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_position_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_position >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_position
  (p_position_id                     out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_position_definition_id          out nocopy number
  ,p_name                            out nocopy varchar2
  ,p_object_version_number           out nocopy number
  ,p_job_id                       in     number
  ,p_organization_id              in     number
  ,p_effective_date               in     date
  ,p_date_effective               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_availability_status_id       in     number    default null
  ,p_business_group_id            in     number    default null
  ,p_entry_step_id                in     number    default null
  ,p_entry_grade_rule_id          in     number    default null
  ,p_location_id                  in     number    default null
  ,p_pay_freq_payroll_id          in     number    default null
  ,p_position_transaction_id      in     number    default null
  ,p_prior_position_id            in     number    default null
  ,p_relief_position_id           in     number    default null
  ,p_entry_grade_id               in     number    default null
  ,p_successor_position_id        in     number    default null
  ,p_supervisor_position_id       in     number    default null
  ,p_amendment_date               in     date      default null
  ,p_amendment_recommendation     in     varchar2  default null
  ,p_amendment_ref_number         in     varchar2  default null
  ,p_bargaining_unit_cd           in     varchar2  default null
  ,p_comments                     in     long      default null
  ,p_current_job_prop_end_date    in     date      default null
  ,p_current_org_prop_end_date    in     date      default null
  ,p_avail_status_prop_end_date   in     date      default null
  ,p_date_end                     in     date      default null
  ,p_earliest_hire_date           in     date      default null
  ,p_fill_by_date                 in     date      default null
  ,p_frequency                    in     varchar2  default null
  ,p_fte                          in     number    default null
  ,p_max_persons                  in     number    default null
  ,p_overlap_period               in     number    default null
  ,p_overlap_unit_cd              in     varchar2  default null
  ,p_pay_term_end_day_cd          in     varchar2  default null
  ,p_pay_term_end_month_cd        in     varchar2  default null
  ,p_permanent_temporary_flag     in     varchar2  default null
  ,p_permit_recruitment_flag      in     varchar2  default null
  ,p_position_type                in     varchar2  default null
  ,p_posting_description          in     varchar2  default null
  ,p_probation_period             in     number    default null
  ,p_probation_period_unit_cd     in     varchar2  default null
  ,p_replacement_required_flag    in     varchar2  default null
  ,p_review_flag                  in     varchar2  default null
  ,p_seasonal_flag                in     varchar2  default null
  ,p_security_requirements        in     varchar2  default null
  ,p_status                       in     varchar2  default null
  ,p_term_start_day_cd            in     varchar2  default null
  ,p_term_start_month_cd          in     varchar2  default null
  ,p_time_normal_finish           in     varchar2  default null
  ,p_time_normal_start            in     varchar2  default null
  ,p_update_source_cd             in     varchar2  default null
  ,p_working_hours                in     number    default null
  ,p_works_council_approval_flag  in     varchar2  default null
  ,p_work_period_type_cd          in     varchar2  default null
  ,p_work_term_end_day_cd         in     varchar2  default null
  ,p_work_term_end_month_cd       in     varchar2  default null
  ,p_proposed_fte_for_layoff      in     number    default null
  ,p_proposed_date_for_layoff     in     date      default null
  ,p_pay_basis_id                 in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_information1                 in     varchar2  default null
  ,p_information2                 in     varchar2  default null
  ,p_information3                 in     varchar2  default null
  ,p_information4                 in     varchar2  default null
  ,p_information5                 in     varchar2  default null
  ,p_information6                 in     varchar2  default null
  ,p_information7                 in     varchar2  default null
  ,p_information8                 in     varchar2  default null
  ,p_information9                 in     varchar2  default null
  ,p_information10                in     varchar2  default null
  ,p_information11                in     varchar2  default null
  ,p_information12                in     varchar2  default null
  ,p_information13                in     varchar2  default null
  ,p_information14                in     varchar2  default null
  ,p_information15                in     varchar2  default null
  ,p_information16                in     varchar2  default null
  ,p_information17                in     varchar2  default null
  ,p_information18                in     varchar2  default null
  ,p_information19                in     varchar2  default null
  ,p_information20                in     varchar2  default null
  ,p_information21                in     varchar2  default null
  ,p_information22                in     varchar2  default null
  ,p_information23                in     varchar2  default null
  ,p_information24                in     varchar2  default null
  ,p_information25                in     varchar2  default null
  ,p_information26                in     varchar2  default null
  ,p_information27                in     varchar2  default null
  ,p_information28                in     varchar2  default null
  ,p_information29                in     varchar2  default null
  ,p_information30                in     varchar2  default null
  ,p_information_category         in     varchar2  default null
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
  ,p_attribute_category           in     varchar2  default null
  ,p_segment1                     in     varchar2  default null
  ,p_segment2                     in     varchar2  default null
  ,p_segment3                     in     varchar2  default null
  ,p_segment4                     in     varchar2  default null
  ,p_segment5                     in     varchar2  default null
  ,p_segment6                     in     varchar2  default null
  ,p_segment7                     in     varchar2  default null
  ,p_segment8                     in     varchar2  default null
  ,p_segment9                     in     varchar2  default null
  ,p_segment10                    in     varchar2  default null
  ,p_segment11                    in     varchar2  default null
  ,p_segment12                    in     varchar2  default null
  ,p_segment13                    in     varchar2  default null
  ,p_segment14                    in     varchar2  default null
  ,p_segment15                    in     varchar2  default null
  ,p_segment16                    in     varchar2  default null
  ,p_segment17                    in     varchar2  default null
  ,p_segment18                    in     varchar2  default null
  ,p_segment19                    in     varchar2  default null
  ,p_segment20                    in     varchar2  default null
  ,p_segment21                    in     varchar2  default null
  ,p_segment22                    in     varchar2  default null
  ,p_segment23                    in     varchar2  default null
  ,p_segment24                    in     varchar2  default null
  ,p_segment25                    in     varchar2  default null
  ,p_segment26                    in     varchar2  default null
  ,p_segment27                    in     varchar2  default null
  ,p_segment28                    in     varchar2  default null
  ,p_segment29                    in     varchar2  default null
  ,p_segment30                    in     varchar2  default null
  ,p_concat_segments              in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_security_profile_id          in     number    default null
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_position';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_position_swi;
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
  hr_position_api.create_position
    (p_position_id                  => p_position_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_position_definition_id       => p_position_definition_id
    ,p_name                         => p_name
    ,p_object_version_number        => p_object_version_number
    ,p_job_id                       => p_job_id
    ,p_organization_id              => p_organization_id
    ,p_effective_date               => p_effective_date
    ,p_date_effective               => p_date_effective
    ,p_validate                     => l_validate
    ,p_availability_status_id       => p_availability_status_id
    ,p_business_group_id            => p_business_group_id
    ,p_entry_step_id                => p_entry_step_id
    ,p_entry_grade_rule_id          => p_entry_grade_rule_id
    ,p_location_id                  => p_location_id
    ,p_pay_freq_payroll_id          => p_pay_freq_payroll_id
    ,p_position_transaction_id      => p_position_transaction_id
    ,p_prior_position_id            => p_prior_position_id
    ,p_relief_position_id           => p_relief_position_id
    ,p_entry_grade_id               => p_entry_grade_id
    ,p_successor_position_id        => p_successor_position_id
    ,p_supervisor_position_id       => p_supervisor_position_id
    ,p_amendment_date               => p_amendment_date
    ,p_amendment_recommendation     => p_amendment_recommendation
    ,p_amendment_ref_number         => p_amendment_ref_number
    ,p_bargaining_unit_cd           => p_bargaining_unit_cd
    ,p_comments                     => p_comments
    ,p_current_job_prop_end_date    => p_current_job_prop_end_date
    ,p_current_org_prop_end_date    => p_current_org_prop_end_date
    ,p_avail_status_prop_end_date   => p_avail_status_prop_end_date
    ,p_date_end                     => p_date_end
    ,p_earliest_hire_date           => p_earliest_hire_date
    ,p_fill_by_date                 => p_fill_by_date
    ,p_frequency                    => p_frequency
    ,p_fte                          => p_fte
    ,p_max_persons                  => p_max_persons
    ,p_overlap_period               => p_overlap_period
    ,p_overlap_unit_cd              => p_overlap_unit_cd
    ,p_pay_term_end_day_cd          => p_pay_term_end_day_cd
    ,p_pay_term_end_month_cd        => p_pay_term_end_month_cd
    ,p_permanent_temporary_flag     => p_permanent_temporary_flag
    ,p_permit_recruitment_flag      => p_permit_recruitment_flag
    ,p_position_type                => p_position_type
    ,p_posting_description          => p_posting_description
    ,p_probation_period             => p_probation_period
    ,p_probation_period_unit_cd     => p_probation_period_unit_cd
    ,p_replacement_required_flag    => p_replacement_required_flag
    ,p_review_flag                  => p_review_flag
    ,p_seasonal_flag                => p_seasonal_flag
    ,p_security_requirements        => p_security_requirements
    ,p_status                       => p_status
    ,p_term_start_day_cd            => p_term_start_day_cd
    ,p_term_start_month_cd          => p_term_start_month_cd
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_update_source_cd             => p_update_source_cd
    ,p_working_hours                => p_working_hours
    ,p_works_council_approval_flag  => p_works_council_approval_flag
    ,p_work_period_type_cd          => p_work_period_type_cd
    ,p_work_term_end_day_cd         => p_work_term_end_day_cd
    ,p_work_term_end_month_cd       => p_work_term_end_month_cd
    ,p_proposed_fte_for_layoff      => p_proposed_fte_for_layoff
    ,p_proposed_date_for_layoff     => p_proposed_date_for_layoff
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    ,p_information21                => p_information21
    ,p_information22                => p_information22
    ,p_information23                => p_information23
    ,p_information24                => p_information24
    ,p_information25                => p_information25
    ,p_information26                => p_information26
    ,p_information27                => p_information27
    ,p_information28                => p_information28
    ,p_information29                => p_information29
    ,p_information30                => p_information30
    ,p_information_category         => p_information_category
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
    ,p_attribute_category           => p_attribute_category
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    ,p_concat_segments              => p_concat_segments
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_security_profile_id          => p_security_profile_id
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
    rollback to create_position_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_position_id                  := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_position_definition_id       := null;
    p_name                         := null;
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
    rollback to create_position_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_position_id                  := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_position_definition_id       := null;
    p_name                         := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_position;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_position >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_position
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_position_id                  in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_security_profile_id          in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_position';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_position_swi;
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
  hr_position_api.delete_position
    (p_validate                     => l_validate
    ,p_position_id                  => p_position_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_security_profile_id          => p_security_profile_id
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
    rollback to delete_position_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to delete_position_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_position;
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_position_id                  in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_validation_start_date           out nocopy date
  ,p_validation_end_date             out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'lck';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint lck_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_position_api.lck
    (p_position_id                  => p_position_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_validation_start_date        => p_validation_start_date
    ,p_validation_end_date          => p_validation_end_date
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
    rollback to lck_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_validation_start_date        := null;
    p_validation_end_date          := null;
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
    rollback to lck_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_validation_start_date        := null;
    p_validation_end_date          := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end lck;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_position >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_position
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_position_id                  in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_position_definition_id          out nocopy number
  ,p_name                            out nocopy varchar2
  ,p_availability_status_id       in     number    default hr_api.g_number
  ,p_entry_step_id                in     number    default hr_api.g_number
  ,p_entry_grade_rule_id          in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_pay_freq_payroll_id          in     number    default hr_api.g_number
  ,p_position_transaction_id      in     number    default hr_api.g_number
  ,p_prior_position_id            in     number    default hr_api.g_number
  ,p_relief_position_id           in     number    default hr_api.g_number
  ,p_entry_grade_id               in     number    default hr_api.g_number
  ,p_successor_position_id        in     number    default hr_api.g_number
  ,p_supervisor_position_id       in     number    default hr_api.g_number
  ,p_amendment_date               in     date      default hr_api.g_date
  ,p_amendment_recommendation     in     varchar2  default hr_api.g_varchar2
  ,p_amendment_ref_number         in     varchar2  default hr_api.g_varchar2
  ,p_bargaining_unit_cd           in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     long      default hr_api.g_varchar2
  ,p_current_job_prop_end_date    in     date      default hr_api.g_date
  ,p_current_org_prop_end_date    in     date      default hr_api.g_date
  ,p_avail_status_prop_end_date   in     date      default hr_api.g_date
  ,p_date_effective               in     date      default hr_api.g_date
  ,p_date_end                     in     date      default hr_api.g_date
  ,p_earliest_hire_date           in     date      default hr_api.g_date
  ,p_fill_by_date                 in     date      default hr_api.g_date
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_fte                          in     number    default hr_api.g_number
  ,p_max_persons                  in     number    default hr_api.g_number
  ,p_overlap_period               in     number    default hr_api.g_number
  ,p_overlap_unit_cd              in     varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_day_cd          in     varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_month_cd        in     varchar2  default hr_api.g_varchar2
  ,p_permanent_temporary_flag     in     varchar2  default hr_api.g_varchar2
  ,p_permit_recruitment_flag      in     varchar2  default hr_api.g_varchar2
  ,p_position_type                in     varchar2  default hr_api.g_varchar2
  ,p_posting_description          in     varchar2  default hr_api.g_varchar2
  ,p_probation_period             in     number    default hr_api.g_number
  ,p_probation_period_unit_cd     in     varchar2  default hr_api.g_varchar2
  ,p_replacement_required_flag    in     varchar2  default hr_api.g_varchar2
  ,p_review_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_seasonal_flag                in     varchar2  default hr_api.g_varchar2
  ,p_security_requirements        in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_term_start_day_cd            in     varchar2  default hr_api.g_varchar2
  ,p_term_start_month_cd          in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2  default hr_api.g_varchar2
  ,p_update_source_cd             in     varchar2  default hr_api.g_varchar2
  ,p_working_hours                in     number    default hr_api.g_number
  ,p_works_council_approval_flag  in     varchar2  default hr_api.g_varchar2
  ,p_work_period_type_cd          in     varchar2  default hr_api.g_varchar2
  ,p_work_term_end_day_cd         in     varchar2  default hr_api.g_varchar2
  ,p_work_term_end_month_cd       in     varchar2  default hr_api.g_varchar2
  ,p_proposed_fte_for_layoff      in     number    default hr_api.g_number
  ,p_proposed_date_for_layoff     in     date      default hr_api.g_date
  ,p_pay_basis_id                 in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
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
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_segment1                     in     varchar2  default hr_api.g_varchar2
  ,p_segment2                     in     varchar2  default hr_api.g_varchar2
  ,p_segment3                     in     varchar2  default hr_api.g_varchar2
  ,p_segment4                     in     varchar2  default hr_api.g_varchar2
  ,p_segment5                     in     varchar2  default hr_api.g_varchar2
  ,p_segment6                     in     varchar2  default hr_api.g_varchar2
  ,p_segment7                     in     varchar2  default hr_api.g_varchar2
  ,p_segment8                     in     varchar2  default hr_api.g_varchar2
  ,p_segment9                     in     varchar2  default hr_api.g_varchar2
  ,p_segment10                    in     varchar2  default hr_api.g_varchar2
  ,p_segment11                    in     varchar2  default hr_api.g_varchar2
  ,p_segment12                    in     varchar2  default hr_api.g_varchar2
  ,p_segment13                    in     varchar2  default hr_api.g_varchar2
  ,p_segment14                    in     varchar2  default hr_api.g_varchar2
  ,p_segment15                    in     varchar2  default hr_api.g_varchar2
  ,p_segment16                    in     varchar2  default hr_api.g_varchar2
  ,p_segment17                    in     varchar2  default hr_api.g_varchar2
  ,p_segment18                    in     varchar2  default hr_api.g_varchar2
  ,p_segment19                    in     varchar2  default hr_api.g_varchar2
  ,p_segment20                    in     varchar2  default hr_api.g_varchar2
  ,p_segment21                    in     varchar2  default hr_api.g_varchar2
  ,p_segment22                    in     varchar2  default hr_api.g_varchar2
  ,p_segment23                    in     varchar2  default hr_api.g_varchar2
  ,p_segment24                    in     varchar2  default hr_api.g_varchar2
  ,p_segment25                    in     varchar2  default hr_api.g_varchar2
  ,p_segment26                    in     varchar2  default hr_api.g_varchar2
  ,p_segment27                    in     varchar2  default hr_api.g_varchar2
  ,p_segment28                    in     varchar2  default hr_api.g_varchar2
  ,p_segment29                    in     varchar2  default hr_api.g_varchar2
  ,p_segment30                    in     varchar2  default hr_api.g_varchar2
  ,p_concat_segments              in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_valid_grades_changed_warning  boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_position';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_position_swi;
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
  hr_position_api.update_position
    (p_validate                     => l_validate
    ,p_position_id                  => p_position_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_position_definition_id       => p_position_definition_id
    ,p_valid_grades_changed_warning => l_valid_grades_changed_warning
    ,p_name                         => p_name
    ,p_availability_status_id       => p_availability_status_id
    ,p_entry_step_id                => p_entry_step_id
    ,p_entry_grade_rule_id          => p_entry_grade_rule_id
    ,p_location_id                  => p_location_id
    ,p_pay_freq_payroll_id          => p_pay_freq_payroll_id
    ,p_position_transaction_id      => p_position_transaction_id
    ,p_prior_position_id            => p_prior_position_id
    ,p_relief_position_id           => p_relief_position_id
    ,p_entry_grade_id               => p_entry_grade_id
    ,p_successor_position_id        => p_successor_position_id
    ,p_supervisor_position_id       => p_supervisor_position_id
    ,p_amendment_date               => p_amendment_date
    ,p_amendment_recommendation     => p_amendment_recommendation
    ,p_amendment_ref_number         => p_amendment_ref_number
    ,p_bargaining_unit_cd           => p_bargaining_unit_cd
    ,p_comments                     => p_comments
    ,p_current_job_prop_end_date    => p_current_job_prop_end_date
    ,p_current_org_prop_end_date    => p_current_org_prop_end_date
    ,p_avail_status_prop_end_date   => p_avail_status_prop_end_date
    ,p_date_effective               => p_date_effective
    ,p_date_end                     => p_date_end
    ,p_earliest_hire_date           => p_earliest_hire_date
    ,p_fill_by_date                 => p_fill_by_date
    ,p_frequency                    => p_frequency
    ,p_fte                          => p_fte
    ,p_max_persons                  => p_max_persons
    ,p_overlap_period               => p_overlap_period
    ,p_overlap_unit_cd              => p_overlap_unit_cd
    ,p_pay_term_end_day_cd          => p_pay_term_end_day_cd
    ,p_pay_term_end_month_cd        => p_pay_term_end_month_cd
    ,p_permanent_temporary_flag     => p_permanent_temporary_flag
    ,p_permit_recruitment_flag      => p_permit_recruitment_flag
    ,p_position_type                => p_position_type
    ,p_posting_description          => p_posting_description
    ,p_probation_period             => p_probation_period
    ,p_probation_period_unit_cd     => p_probation_period_unit_cd
    ,p_replacement_required_flag    => p_replacement_required_flag
    ,p_review_flag                  => p_review_flag
    ,p_seasonal_flag                => p_seasonal_flag
    ,p_security_requirements        => p_security_requirements
    ,p_status                       => p_status
    ,p_term_start_day_cd            => p_term_start_day_cd
    ,p_term_start_month_cd          => p_term_start_month_cd
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_update_source_cd             => p_update_source_cd
    ,p_working_hours                => p_working_hours
    ,p_works_council_approval_flag  => p_works_council_approval_flag
    ,p_work_period_type_cd          => p_work_period_type_cd
    ,p_work_term_end_day_cd         => p_work_term_end_day_cd
    ,p_work_term_end_month_cd       => p_work_term_end_month_cd
    ,p_proposed_fte_for_layoff      => p_proposed_fte_for_layoff
    ,p_proposed_date_for_layoff     => p_proposed_date_for_layoff
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    ,p_information21                => p_information21
    ,p_information22                => p_information22
    ,p_information23                => p_information23
    ,p_information24                => p_information24
    ,p_information25                => p_information25
    ,p_information26                => p_information26
    ,p_information27                => p_information27
    ,p_information28                => p_information28
    ,p_information29                => p_information29
    ,p_information30                => p_information30
    ,p_information_category         => p_information_category
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
    ,p_attribute_category           => p_attribute_category
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    ,p_concat_segments              => p_concat_segments
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_valid_grades_changed_warning then
     fnd_message.set_name('PER', 'HR_51095_VGR_POS_GRD_COMBO');
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
    rollback to update_position_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_position_definition_id       := null;
    p_name                         := null;
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
    rollback to update_position_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_position_definition_id       := null;
    p_name                         := null;
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_position;
end hr_position_swi;

/
