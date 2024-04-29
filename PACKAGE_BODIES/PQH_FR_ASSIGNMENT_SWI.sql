--------------------------------------------------------
--  DDL for Package Body PQH_FR_ASSIGNMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_ASSIGNMENT_SWI" As
/* $Header: pqastswi.pkb 120.0 2005/05/29 01:26 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_fr_assignment_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_affectation >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_affectation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_organization_id              in     number
  ,p_position_id                  in     number
  ,p_person_id                    in     number
  ,p_job_id                       in     number
  ,p_supervisor_id                in     number    default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_assignment_status_type_id    in     number
  ,p_identifier                   in     varchar2
  ,p_affectation_type             in     varchar2
  ,p_percent_effected             in     varchar2
  ,p_primary_affectation          in     varchar2  default null
  ,p_group_name                      out nocopy varchar2
  ,p_scl_concat_segments          in     varchar2  default null
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
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
  l_assignment_number             varchar2(100);
  l_soft_coding_keyflex_id        number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_affectation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_affectation_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_assignment_number             := p_assignment_number;
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
  pqh_fr_assignment_api.create_affectation
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_organization_id              => p_organization_id
    ,p_position_id                  => p_position_id
    ,p_person_id                    => p_person_id
    ,p_job_id                       => p_job_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_assignment_number            => p_assignment_number
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_identifier                   => p_identifier
    ,p_affectation_type             => p_affectation_type
    ,p_percent_effected             => p_percent_effected
    ,p_primary_affectation          => p_primary_affectation
    ,p_group_name                   => p_group_name
    ,p_scl_concat_segments          => p_scl_concat_segments
    ,p_assignment_id                => p_assignment_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
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
    rollback to create_affectation_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_assignment_number            := l_assignment_number;
    p_group_name                   := null;
    p_assignment_id                := null;
    p_soft_coding_keyflex_id       := l_soft_coding_keyflex_id;
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
    rollback to create_affectation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_assignment_number            := l_assignment_number;
    p_group_name                   := null;
    p_assignment_id                := null;
    p_soft_coding_keyflex_id       := l_soft_coding_keyflex_id;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_assignment_sequence          := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_affectation;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_affectation >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_affectation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_datetrack_update_mode        in     varchar2
  ,p_effective_date               in     date
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_person_id                    in     number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_assignment_number            in     varchar2  default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_identifier                   in     varchar2  default hr_api.g_varchar2
  ,p_affectation_type             in     varchar2  default hr_api.g_varchar2
  ,p_percent_effected             in     varchar2  default hr_api.g_varchar2
  ,p_primary_affectation          in     varchar2  default hr_api.g_varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_scl_concat_segments          in     varchar2  default hr_api.g_varchar2
  ,p_assignment_id                in     number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_object_version_number        in out nocopy number
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
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_affectation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_affectation_swi;
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
  pqh_fr_assignment_api.update_affectation
    (p_validate                     => l_validate
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_effective_date               => p_effective_date
    ,p_organization_id              => p_organization_id
    ,p_position_id                  => p_position_id
    ,p_person_id                    => p_person_id
    ,p_job_id                       => p_job_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_assignment_number            => p_assignment_number
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_identifier                   => p_identifier
    ,p_affectation_type             => p_affectation_type
    ,p_percent_effected             => p_percent_effected
    ,p_primary_affectation          => p_primary_affectation
    ,p_group_name                   => p_group_name
    ,p_scl_concat_segments          => p_scl_concat_segments
    ,p_assignment_id                => p_assignment_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
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
    rollback to update_affectation_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_group_name                   := null;
    p_soft_coding_keyflex_id       := null;
    p_object_version_number        := l_object_version_number;
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
    rollback to update_affectation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_group_name                   := null;
    p_soft_coding_keyflex_id       := null;
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_assignment_sequence          := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_affectation;
-- ----------------------------------------------------------------------------
-- |------------------------< update_employment_terms >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_employment_terms
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_datetrack_update_mode        in     varchar2
  ,p_effective_date               in     date
  ,p_assignment_id                in     number
  ,p_establishment_id             in     number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_assignment_category          in     varchar2
  ,p_reason_for_parttime          in     varchar2  default hr_api.g_varchar2
  ,p_working_hours_share          in     varchar2  default hr_api.g_varchar2
  ,p_contract_id                  in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_object_version_number        in out nocopy number
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
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_employment_terms';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_employment_terms_swi;
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
  pqh_fr_assignment_api.update_employment_terms
    (p_validate                     => l_validate
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_effective_date               => p_effective_date
    ,p_assignment_id                => p_assignment_id
    ,p_establishment_id             => p_establishment_id
    ,p_comments                     => p_comments
    ,p_assignment_category          => p_assignment_category
    ,p_reason_for_parttime          => p_reason_for_parttime
    ,p_working_hours_share          => p_working_hours_share
    ,p_contract_id                  => p_contract_id
    ,p_change_reason                => p_change_reason
    ,p_normal_hours                 => p_normal_hours
    ,p_frequency                    => p_frequency
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
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
    rollback to update_employment_terms_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_soft_coding_keyflex_id       := null;
    p_object_version_number        := l_object_version_number;
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
    rollback to update_employment_terms_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_soft_coding_keyflex_id       := null;
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_assignment_sequence          := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_employment_terms;
-- ----------------------------------------------------------------------------
-- |---------------------< update_administrative_career >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_administrative_career
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_datetrack_update_mode        in     varchar2
  ,p_effective_date               in     date
  ,p_assignment_id                in     number
  ,p_corps_id                     in     number
  ,p_grade_id                     in     number
  ,p_step_id                      in     number
  ,p_progression_speed           in     varchar2
  ,p_personal_gross_index         in     varchar2
  ,p_employee_category            in     varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_object_version_number        in out nocopy number
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
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_administrative_career';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_admin_career_swi;
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
  pqh_fr_assignment_api.update_administrative_career
    (p_validate                     => l_validate
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_effective_date               => p_effective_date
    ,p_assignment_id                => p_assignment_id
    ,p_corps_id                     => p_corps_id
    ,p_grade_id                     => p_grade_id
    ,p_step_id                      => p_step_id
    ,p_progression_speed            => p_progression_speed
    ,p_personal_gross_index         => p_personal_gross_index
    ,p_employee_category            => p_employee_category
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
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
    rollback to update_admin_career_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_soft_coding_keyflex_id       := null;
    p_object_version_number        := l_object_version_number;
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
    rollback to update_admin_career_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_soft_coding_keyflex_id       := null;
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_assignment_sequence          := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_administrative_career;

PROCEDURE terminate_affectation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
  ,p_primary_affectation          in     varchar2  default null
  ,p_group_name                      out nocopy varchar2
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
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'terminate_affectation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint terminate_affectation_swi;
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
  pqh_fr_assignment_api.terminate_affectation
    (p_validate                     => l_validate
    ,p_assignment_id                => p_assignment_id
    ,p_effective_date               => p_effective_date
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_primary_affectation          => p_primary_affectation
    ,p_group_name                   => p_group_name
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
    rollback to terminate_affectation_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_group_name                   := null;
    p_object_version_number        := null;
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
    rollback to terminate_affectation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --

    p_group_name                   := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

end terminate_affectation;

PROCEDURE suspend_affectation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
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
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'suspend_affectation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint suspend_affectation_swi;
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
  pqh_fr_assignment_api.suspend_affectation
    (p_validate                     => l_validate
    ,p_assignment_id                => p_assignment_id
    ,p_effective_date               => p_effective_date
    ,p_assignment_status_type_id    => p_assignment_status_type_id
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
    rollback to suspend_affectation_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
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
    rollback to suspend_affectation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --


    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

end suspend_affectation;

PROCEDURE activate_affectation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
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
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'suspend_affectation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint activate_affectation_swi;
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
  pqh_fr_assignment_api.activate_affectation
    (p_validate                     => l_validate
    ,p_assignment_id                => p_assignment_id
    ,p_effective_date               => p_effective_date
    ,p_assignment_status_type_id    => p_assignment_status_type_id
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
    rollback to activate_affectation_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
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
    rollback to activate_affectation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --


    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

end activate_affectation;

end pqh_fr_assignment_swi;

/
