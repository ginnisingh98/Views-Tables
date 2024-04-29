--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_ISETUP_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_ISETUP_SWI" As
/* $Header: hrasgstp.pkb 120.3 2005/09/16 01:33:20 ndorai noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_assignment_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_secondary_apl_asg >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_secondary_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_recruiter_id                 in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_position_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_assignment_status_type_id    in     number    default null
  ,p_payroll_id                   in     number    default null
  ,p_location_id                  in     number    default null
  ,p_person_referred_by_id        in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_special_ceiling_step_id      in     number    default null
  ,p_recruitment_activity_id      in     number    default null
  ,p_source_organization_id       in     number    default null
  ,p_vacancy_id                   in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_change_reason                in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_date_probation_end           in     date      default null
  ,p_default_code_comb_id         in     number    default null
  ,p_employment_category          in     varchar2  default null
  ,p_frequency                    in     varchar2  default null
  ,p_internal_address_line        in     varchar2  default null
  ,p_manager_flag                 in     varchar2  default null
  ,p_normal_hours                 in     number    default null
  ,p_perf_review_period           in     number    default null
  ,p_perf_review_period_frequency in     varchar2  default null
  ,p_probation_period             in     number    default null
  ,p_probation_unit               in     varchar2  default null
  ,p_sal_review_period            in     number    default null
  ,p_sal_review_period_frequency  in     varchar2  default null
  ,p_set_of_books_id              in     number    default null
  ,p_source_type                  in     varchar2  default null
  ,p_time_normal_finish           in     varchar2  default null
  ,p_time_normal_start            in     varchar2  default null
  ,p_bargaining_unit_code         in     varchar2  default null
  ,p_ass_attribute_category       in     varchar2  default null
  ,p_ass_attribute1               in     varchar2  default null
  ,p_ass_attribute2               in     varchar2  default null
  ,p_ass_attribute3               in     varchar2  default null
  ,p_ass_attribute4               in     varchar2  default null
  ,p_ass_attribute5               in     varchar2  default null
  ,p_ass_attribute6               in     varchar2  default null
  ,p_ass_attribute7               in     varchar2  default null
  ,p_ass_attribute8               in     varchar2  default null
  ,p_ass_attribute9               in     varchar2  default null
  ,p_ass_attribute10              in     varchar2  default null
  ,p_ass_attribute11              in     varchar2  default null
  ,p_ass_attribute12              in     varchar2  default null
  ,p_ass_attribute13              in     varchar2  default null
  ,p_ass_attribute14              in     varchar2  default null
  ,p_ass_attribute15              in     varchar2  default null
  ,p_ass_attribute16              in     varchar2  default null
  ,p_ass_attribute17              in     varchar2  default null
  ,p_ass_attribute18              in     varchar2  default null
  ,p_ass_attribute19              in     varchar2  default null
  ,p_ass_attribute20              in     varchar2  default null
  ,p_ass_attribute21              in     varchar2  default null
  ,p_ass_attribute22              in     varchar2  default null
  ,p_ass_attribute23              in     varchar2  default null
  ,p_ass_attribute24              in     varchar2  default null
  ,p_ass_attribute25              in     varchar2  default null
  ,p_ass_attribute26              in     varchar2  default null
  ,p_ass_attribute27              in     varchar2  default null
  ,p_ass_attribute28              in     varchar2  default null
  ,p_ass_attribute29              in     varchar2  default null
  ,p_ass_attribute30              in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_concatenated_segments           out nocopy varchar2
  ,p_contract_id                  in     number    default null
  ,p_establishment_id             in     number    default null
  ,p_collective_agreement_id      in     number    default null
  ,p_notice_period                in     number    default null
  ,p_notice_period_uom            in     varchar2  default null
  ,p_employee_category            in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_post_source_name         in     varchar2  default null
  ,p_applicant_rank               in     number    default null
  ,p_posting_content_id           in     number    default null
  ,p_cagr_grade_def_id            in out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                in     number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_cagr_grade_def_id             number;
  l_people_group_id               number;
  l_soft_coding_keyflex_id        number;
  --
  -- Other variables
  l_assignment_id                number;
  l_proc    varchar2(72) := g_package ||'create_secondary_apl_asg';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_secondary_apl_asg_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_cagr_grade_def_id             := p_cagr_grade_def_id;
  l_people_group_id               := p_people_group_id;
  l_soft_coding_keyflex_id        := p_soft_coding_keyflex_id;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --per_asg_ins.set_base_key_value
  --  (p_assignment_id => p_assignment_id
  --  );
  --
  -- Call API
  --
  hr_assignment_api.create_secondary_apl_asg
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    ,p_organization_id              => p_organization_id
    ,p_recruiter_id                 => p_recruiter_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_person_referred_by_id        => p_person_referred_by_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_recruitment_activity_id      => p_recruitment_activity_id
    ,p_source_organization_id       => p_source_organization_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_concatenated_segments        => p_concatenated_segments
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_notice_period                => p_notice_period
    ,p_notice_period_uom            => p_notice_period_uom
    ,p_employee_category            => p_employee_category
    ,p_work_at_home                 => p_work_at_home
    ,p_job_post_source_name         => p_job_post_source_name
    --,p_applicant_rank               => p_applicant_rank
    --,p_posting_content_id           => p_posting_content_id
    ,p_cagr_grade_def_id            => p_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
    ,p_group_name                   => p_group_name
    ,p_assignment_id                => l_assignment_id
    ,p_people_group_id              => p_people_group_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_comment_id                   => p_comment_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_assignment_sequence          => p_assignment_sequence
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
    rollback to create_secondary_apl_asg_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_concatenated_segments        := null;
    p_cagr_grade_def_id            := l_cagr_grade_def_id;
    p_cagr_concatenated_segments   := null;
    p_group_name                   := null;
    p_people_group_id              := l_people_group_id;
    p_soft_coding_keyflex_id       := l_soft_coding_keyflex_id;
    p_comment_id                   := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_assignment_sequence          := null;
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
    rollback to create_secondary_apl_asg_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_concatenated_segments        := null;
    p_cagr_grade_def_id            := l_cagr_grade_def_id;
    p_cagr_concatenated_segments   := null;
    p_group_name                   := null;
    p_people_group_id              := l_people_group_id;
    p_soft_coding_keyflex_id       := l_soft_coding_keyflex_id;
    p_comment_id                   := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_assignment_sequence          := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_secondary_apl_asg;
-- ----------------------------------------------------------------------------
-- |----------------------------< accept_apl_asg >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE accept_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_proc    varchar2(72) := g_package ||'accept_apl_asg';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint accept_apl_asg_swi;
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
  hr_assignment_api.accept_apl_asg
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_change_reason                => p_change_reason
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to accept_apl_asg_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to accept_apl_asg_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end accept_apl_asg;
-- ----------------------------------------------------------------------------
-- |---------------------------< activate_apl_asg >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE activate_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_proc    varchar2(72) := g_package ||'activate_apl_asg';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint activate_apl_asg_swi;
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
  hr_assignment_api.activate_apl_asg
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_change_reason                => p_change_reason
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to activate_apl_asg_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to activate_apl_asg_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end activate_apl_asg;
-- ----------------------------------------------------------------------------
-- |-----------------------------< offer_apl_asg >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE offer_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_proc    varchar2(72) := g_package ||'offer_apl_asg';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint offer_apl_asg_swi;
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
  hr_assignment_api.offer_apl_asg
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_change_reason                => p_change_reason
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to offer_apl_asg_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to offer_apl_asg_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end offer_apl_asg;
-- ----------------------------------------------------------------------------
-- |---------------------------< terminate_apl_asg >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE terminate_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_proc    varchar2(72) := g_package ||'terminate_apl_asg';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint terminate_apl_asg_swi;
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
  hr_assignment_api.terminate_apl_asg
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to terminate_apl_asg_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to terminate_apl_asg_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end terminate_apl_asg;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_apl_asg >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_recruiter_id                 in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_person_referred_by_id        in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_special_ceiling_step_id      in     number    default hr_api.g_number
  ,p_recruitment_activity_id      in     number    default hr_api.g_number
  ,p_source_organization_id       in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_pay_basis_id                 in     number    default hr_api.g_number
  ,p_application_id               in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_date_probation_end           in     date      default hr_api.g_date
  ,p_default_code_comb_id         in     number    default hr_api.g_number
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2  default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_perf_review_period           in     number    default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2  default hr_api.g_varchar2
  ,p_probation_period             in     number    default hr_api.g_number
  ,p_probation_unit               in     varchar2  default hr_api.g_varchar2
  ,p_sal_review_period            in     number    default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2  default hr_api.g_varchar2
  ,p_set_of_books_id              in     number    default hr_api.g_number
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2  default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_contract_id                  in     number    default hr_api.g_number
  ,p_establishment_id             in     number    default hr_api.g_number
  ,p_collective_agreement_id      in     number    default hr_api.g_number
  ,p_notice_period                in     number    default hr_api.g_number
  ,p_notice_period_uom            in     varchar2  default hr_api.g_varchar2
  ,p_employee_category            in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_job_post_source_name         in     varchar2  default hr_api.g_varchar2
  ,p_posting_content_id           in     number    default hr_api.g_number
  ,p_applicant_rank               in     number    default hr_api.g_number
  ,p_cagr_grade_def_id            in out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_comment_id                      out nocopy number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_cagr_grade_def_id             number;
  l_people_group_id               number;
  l_soft_coding_keyflex_id        number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_apl_asg';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_apl_asg_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  l_cagr_grade_def_id             := p_cagr_grade_def_id;
  l_people_group_id               := p_people_group_id;
  l_soft_coding_keyflex_id        := p_soft_coding_keyflex_id;
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
  hr_assignment_api.update_apl_asg
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_recruiter_id                 => p_recruiter_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_person_referred_by_id        => p_person_referred_by_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_recruitment_activity_id      => p_recruitment_activity_id
    ,p_source_organization_id       => p_source_organization_id
    ,p_organization_id              => p_organization_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_application_id               => p_application_id
    ,p_change_reason                => p_change_reason
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_concatenated_segments        => p_concatenated_segments
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_notice_period                => p_notice_period
    ,p_notice_period_uom            => p_notice_period_uom
    ,p_employee_category            => p_employee_category
    ,p_work_at_home                 => p_work_at_home
    ,p_job_post_source_name         => p_job_post_source_name
    --,p_posting_content_id           => p_posting_content_id
    --,p_applicant_rank               => p_applicant_rank
    ,p_cagr_grade_def_id            => p_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
    ,p_group_name                   => p_group_name
    ,p_comment_id                   => p_comment_id
    ,p_people_group_id              => p_people_group_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to update_apl_asg_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_concatenated_segments        := null;
    p_cagr_grade_def_id            := l_cagr_grade_def_id;
    p_cagr_concatenated_segments   := null;
    p_group_name                   := null;
    p_comment_id                   := null;
    p_people_group_id              := l_people_group_id;
    p_soft_coding_keyflex_id       := l_soft_coding_keyflex_id;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to update_apl_asg_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_concatenated_segments        := null;
    p_cagr_grade_def_id            := l_cagr_grade_def_id;
    p_cagr_concatenated_segments   := null;
    p_group_name                   := null;
    p_comment_id                   := null;
    p_people_group_id              := l_people_group_id;
    p_soft_coding_keyflex_id       := l_soft_coding_keyflex_id;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_apl_asg;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_emp_asg >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_emp_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_assignment_number            in     varchar2  default hr_api.g_varchar2
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_date_probation_end           in     date      default hr_api.g_date
  ,p_default_code_comb_id         in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2  default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_perf_review_period           in     number    default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2  default hr_api.g_varchar2
  ,p_probation_period             in     number    default hr_api.g_number
  ,p_probation_unit               in     varchar2  default hr_api.g_varchar2
  ,p_sal_review_period            in     number    default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2  default hr_api.g_varchar2
  ,p_set_of_books_id              in     number    default hr_api.g_number
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2  default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2  default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2  default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_title                        in     varchar2  default hr_api.g_varchar2
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
  ,p_contract_id                  in     number    default hr_api.g_number
  ,p_establishment_id             in     number    default hr_api.g_number
  ,p_collective_agreement_id      in     number    default hr_api.g_number
  ,p_cagr_id_flex_num             in     number    default hr_api.g_number
  ,p_cag_segment1                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment2                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment3                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment4                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment5                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment6                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment7                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment8                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment9                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment10                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment11                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment12                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment13                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment14                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment15                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment16                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment17                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment18                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment19                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment20                in     varchar2  default hr_api.g_varchar2
  ,p_notice_period                in     number    default hr_api.g_number
  ,p_notice_period_uom            in     varchar2  default hr_api.g_varchar2
  ,p_employee_category            in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_job_post_source_name         in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     varchar2  default hr_api.g_number
  ,p_tax_unit_name                in     varchar2  default hr_api.g_varchar2
  ,p_scl_flex_struc_code          in     varchar2  default hr_api.g_varchar2
  ,p_scl_concatenated_segments    in     varchar2  default hr_api.g_varchar2
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_no_managers_warning           boolean;
  l_other_manager_warning         boolean;
  l_hourly_salaried_warning       boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_emp_asg';
  l_scl_keyflex_id number(15);
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_emp_asg_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  if p_object_version_number is null then
     select object_version_number
       into p_object_version_number
       from per_all_assignments_f
      where assignment_id = p_assignment_id;
  end if;
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- call insert_soft_coding_keyflex to insert record into SCL during migration
  --
  l_scl_keyflex_id := insert_soft_coding_keyflex
                       ( p_bg_id                     => p_business_group_id
                        ,p_tax_unit_name             => p_tax_unit_name
                        ,p_scl_flex_struc_code   => p_scl_flex_struc_code
                        ,p_scl_concat_segments => p_scl_concatenated_segments);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_assignment_api.update_emp_asg
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_supervisor_id                => p_supervisor_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
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
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_cag_segment1                 => p_cag_segment1
    ,p_cag_segment2                 => p_cag_segment2
    ,p_cag_segment3                 => p_cag_segment3
    ,p_cag_segment4                 => p_cag_segment4
    ,p_cag_segment5                 => p_cag_segment5
    ,p_cag_segment6                 => p_cag_segment6
    ,p_cag_segment7                 => p_cag_segment7
    ,p_cag_segment8                 => p_cag_segment8
    ,p_cag_segment9                 => p_cag_segment9
    ,p_cag_segment10                => p_cag_segment10
    ,p_cag_segment11                => p_cag_segment11
    ,p_cag_segment12                => p_cag_segment12
    ,p_cag_segment13                => p_cag_segment13
    ,p_cag_segment14                => p_cag_segment14
    ,p_cag_segment15                => p_cag_segment15
    ,p_cag_segment16                => p_cag_segment16
    ,p_cag_segment17                => p_cag_segment17
    ,p_cag_segment18                => p_cag_segment18
    ,p_cag_segment19                => p_cag_segment19
    ,p_cag_segment20                => p_cag_segment20
    ,p_notice_period                => p_notice_period
    ,p_notice_period_uom            => p_notice_period_uom
    ,p_employee_category            => p_employee_category
    ,p_work_at_home                 => p_work_at_home
    ,p_job_post_source_name         => p_job_post_source_name
    ,p_cagr_grade_def_id            => p_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
    ,p_concatenated_segments        => p_concatenated_segments
   /* ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id */
    ,p_soft_coding_keyflex_id       => l_scl_keyflex_id
    ,p_comment_id                   => p_comment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_no_managers_warning then
      fnd_message.set_name('PER', 'HR_289214_NO_MANAGERS');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  /*
  if l_other_manager_warning then
     fnd_message.set_name('PER', 'HR_289215_DUPLICATE_MANAGERS');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  */
  if l_hourly_salaried_warning then
     fnd_message.set_name('PER', 'HR_289648_CWK_HR_CODE_NOT_NULL');
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
    rollback to update_emp_asg_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_cagr_grade_def_id            := null;
    p_cagr_concatenated_segments   := null;
    p_concatenated_segments        := null;
    p_soft_coding_keyflex_id       := null;
    p_comment_id                   := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to update_emp_asg_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_cagr_grade_def_id            := null;
    p_cagr_concatenated_segments   := null;
    p_concatenated_segments        := null;
    p_soft_coding_keyflex_id       := null;
    p_comment_id                   := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_emp_asg;
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_emp_asg_criteria >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_emp_asg_criteria
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_pay_basis_id                 in     number    default hr_api.g_number
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
  ,p_group_name                      out nocopy varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_people_group_id                 out nocopy number
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_org_now_no_manager_warning    boolean;
  l_other_manager_warning         boolean;
  l_spp_delete_warning            boolean;
  l_tax_district_changed_warning  boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_special_ceiling_step_id       number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_emp_asg_criteria';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_emp_asg_criteria_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
   if p_object_version_number is null then
      select object_version_number
        into p_object_version_number
        from per_all_assignments_f
       where assignment_id = p_assignment_id;
   end if;
  l_object_version_number         := p_object_version_number;
  l_special_ceiling_step_id       := p_special_ceiling_step_id;
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
  hr_assignment_api.update_emp_asg_criteria
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_organization_id              => p_organization_id
    ,p_pay_basis_id                 => p_pay_basis_id
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
    ,p_group_name                   => p_group_name
    ,p_employment_category          => p_employment_category
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_people_group_id              => p_people_group_id
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_spp_delete_warning           => l_spp_delete_warning
    ,p_entries_changed_warning      => p_entries_changed_warning
    ,p_tax_district_changed_warning => l_tax_district_changed_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_org_now_no_manager_warning then
      fnd_message.set_name('PER', 'HR_289214_NO_MANAGERS');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  /*
  if l_other_manager_warning then
     fnd_message.set_name('PER', 'HR_289215_DUPLICATE_MANAGERS');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if; */
  if l_spp_delete_warning then
     fnd_message.set_name('PER', 'HR_289826_SPP_DELETE_WARN_API');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_tax_district_changed_warning then
     fnd_message.set_name('EDIT HERE: APP_CODE', 'EDIT_HERE: MESSAGE_NAME ');
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
    rollback to update_emp_asg_criteria_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_special_ceiling_step_id      := l_special_ceiling_step_id;
    p_group_name                   := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_people_group_id              := null;
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
    rollback to update_emp_asg_criteria_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_special_ceiling_step_id      := l_special_ceiling_step_id;
    p_group_name                   := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_people_group_id              := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_emp_asg_criteria;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< insert_soft_coding_keyflex >---------------------|
-- ----------------------------------------------------------------------------
FUNCTION insert_soft_coding_keyflex
  (p_tax_unit_name    in     varchar2
  ,p_bg_id            in     number
  ,p_scl_flex_struc_code  in     varchar2
  ,p_scl_concat_segments  in     varchar2) RETURN NUMBER AS
  --
  l_scl_keyflex_id  hr_soft_coding_keyflex.soft_coding_keyflex_id%type;
  l_id_flex_num fnd_id_flex_structures.id_flex_num%type;
  l_tax_unit_id hr_all_organization_units.organization_id%type;
 --
 --
 begin
 --
 --
  if p_tax_unit_name is not null then
    SELECT id_flex_num INTO l_id_flex_num
      FROM fnd_id_flex_structures
     WHERE id_flex_structure_code = p_scl_flex_struc_code
       AND application_id = 800;

    SELECT organization_id INTO l_tax_unit_id
      FROM hr_all_organization_units
     WHERE name = p_tax_unit_name
       AND business_group_id = p_bg_id;
    --
    begin
      SELECT soft_coding_keyflex_id
        INTO l_scl_keyflex_id
        FROM hr_soft_coding_keyflex
       WHERE segment1 = l_tax_unit_id;
       --concatenated_segments = p_scl_concat_segments;

    exception
      when no_data_found then
         SELECT hr_soft_coding_keyflex_s.nextval
           INTO l_scl_keyflex_id
           FROM dual;
         --
         INSERT INTO hr_soft_coding_keyflex
           (soft_coding_keyflex_id,
            concatenated_segments,
            id_flex_num,
            summary_flag,
            enabled_flag,
            segment1)
          VALUES (l_scl_keyflex_id,
                  p_scl_concat_segments,
                  l_id_flex_num,
                  'N',
                  'Y',
                  l_tax_unit_id);
    end;
  end if;
  return l_scl_keyflex_id;

 end insert_soft_coding_keyflex;
--
--
end hr_assignment_isetup_swi;

/
