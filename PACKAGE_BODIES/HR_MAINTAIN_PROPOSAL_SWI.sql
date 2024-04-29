--------------------------------------------------------
--  DDL for Package Body HR_MAINTAIN_PROPOSAL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MAINTAIN_PROPOSAL_SWI" As
/* $Header: hrpypswi.pkb 120.3.12010000.2 2008/12/04 17:27:36 schowdhu ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_maintain_proposal_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< approve_salary_proposal >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE approve_salary_proposal
  (p_pay_proposal_id              in     number
  ,p_change_date                  in     date      default hr_api.g_date
  ,p_proposed_salary_n            in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_error_text                      out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_inv_next_sal_date_warning     boolean;
  l_proposed_salary_warning       boolean;
  l_approved_warning              boolean;
  l_payroll_warning               boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'approve_salary_proposal';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint approve_salary_proposal_swi;
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
  hr_maintain_proposal_api.approve_salary_proposal
    (p_pay_proposal_id              => p_pay_proposal_id
    ,p_change_date                  => p_change_date
    ,p_proposed_salary_n            => p_proposed_salary_n
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => l_validate
    ,p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning
    ,p_proposed_salary_warning      => l_proposed_salary_warning
    ,p_approved_warning             => l_approved_warning
    ,p_payroll_warning              => l_payroll_warning
    ,p_error_text                   => p_error_text
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
    rollback to approve_salary_proposal_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_error_text                   := null;
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
    rollback to approve_salary_proposal_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_error_text                   := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end approve_salary_proposal;
-- ----------------------------------------------------------------------------
-- |----------------------< cre_or_upd_salary_proposal >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE cre_or_upd_salary_proposal
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pay_proposal_id              in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_change_date                  in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_next_sal_review_date         in     date      default hr_api.g_date
  ,p_proposal_reason              in     varchar2  default hr_api.g_varchar2
  ,p_proposed_salary_n            in     number    default hr_api.g_number
  ,p_forced_ranking               in     number    default hr_api.g_number
  ,p_date_to			  in     date      default hr_api.g_date
  ,p_performance_review_id        in     number    default hr_api.g_number
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
  ,p_multiple_components          in     varchar2  default hr_api.g_varchar2
  ,p_approved                     in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_inv_next_sal_date_warning     boolean;
  l_proposed_salary_warning       boolean;
  l_approved_warning              boolean;
  l_payroll_warning               boolean;
  --
  -- Variables for IN/OUT parameters
  l_pay_proposal_id               number;
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'cre_or_upd_salary_proposal';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint cre_or_upd_salary_proposal_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_pay_proposal_id               := p_pay_proposal_id;
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
  hr_maintain_proposal_api.cre_or_upd_salary_proposal
    (p_validate                     => l_validate
    ,p_pay_proposal_id              => p_pay_proposal_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_assignment_id                => p_assignment_id
    ,p_change_date                  => p_change_date
    ,p_comments                     => p_comments
    ,p_next_sal_review_date         => p_next_sal_review_date
    ,p_proposal_reason              => p_proposal_reason
    ,p_proposed_salary_n            => p_proposed_salary_n
    ,p_forced_ranking               => p_forced_ranking
    ,p_date_to			    => p_date_to
    ,p_performance_review_id        => p_performance_review_id
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
    ,p_multiple_components          => p_multiple_components
    ,p_approved                     => p_approved
    ,p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning
    ,p_proposed_salary_warning      => l_proposed_salary_warning
    ,p_approved_warning             => l_approved_warning
    ,p_payroll_warning              => l_payroll_warning
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
    rollback to cre_or_upd_salary_proposal_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_pay_proposal_id              := l_pay_proposal_id;
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
    rollback to cre_or_upd_salary_proposal_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_pay_proposal_id              := l_pay_proposal_id;
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end cre_or_upd_salary_proposal;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_proposal_component >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_proposal_component
  (p_component_id                 in     number
  ,p_validation_strength          in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_proposal_component';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_proposal_component_swi;
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
  hr_maintain_proposal_api.delete_proposal_component
    (p_component_id                 => p_component_id
    ,p_validation_strength          => p_validation_strength
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => l_validate
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
    rollback to delete_proposal_component_swi;
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
    rollback to delete_proposal_component_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_proposal_component;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_salary_proposal >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_salary_proposal
  (p_pay_proposal_id              in     number
  ,p_business_group_id            in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_salary_warning                boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_salary_proposal';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_salary_proposal_swi;
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
  hr_maintain_proposal_api.delete_salary_proposal
    (p_pay_proposal_id              => p_pay_proposal_id
    ,p_business_group_id            => p_business_group_id
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => l_validate
    ,p_salary_warning               => l_salary_warning
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
    rollback to delete_salary_proposal_swi;
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
    rollback to delete_salary_proposal_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_salary_proposal;
-- ----------------------------------------------------------------------------
-- |-----------------------< insert_proposal_component >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_proposal_component
  (p_component_id                    out nocopy number
  ,p_pay_proposal_id              in     number
  ,p_business_group_id            in     number
  ,p_approved                     in     varchar2
  ,p_component_reason             in     varchar2
  ,p_change_amount_n              in     number    default hr_api.g_number
  ,p_change_percentage            in     number    default hr_api.g_number
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
  ,p_validation_strength          in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number           out nocopy number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'insert_proposal_component';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint insert_proposal_component_swi;
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
  hr_maintain_proposal_api.insert_proposal_component
    (p_component_id                 => p_component_id
    ,p_pay_proposal_id              => p_pay_proposal_id
    ,p_business_group_id            => p_business_group_id
    ,p_approved                     => p_approved
    ,p_component_reason             => p_component_reason
    ,p_change_amount_n              => p_change_amount_n
    ,p_change_percentage            => p_change_percentage
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
    ,p_validation_strength          => p_validation_strength
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => l_validate
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
    rollback to insert_proposal_component_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_component_id                 := null;
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
    rollback to insert_proposal_component_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_component_id                 := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end insert_proposal_component;
-- ----------------------------------------------------------------------------
-- |------------------------< insert_salary_proposal >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_salary_proposal
  (p_pay_proposal_id              in number
  ,p_assignment_id                in     number
  ,p_business_group_id            in     number
  ,p_change_date                  in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_next_sal_review_date         in     date      default hr_api.g_date
  ,p_proposal_reason              in     varchar2  default hr_api.g_varchar2
  ,p_proposed_salary_n            in     number    default hr_api.g_number
  ,p_forced_ranking               in     number    default hr_api.g_number
  ,p_date_to            	  in     date      default hr_general.end_of_time
  ,p_performance_review_id        in     number    default hr_api.g_number
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
  ,p_object_version_number           out nocopy number
  ,p_multiple_components          in     varchar2  default hr_api.g_varchar2
  ,p_approved                     in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_element_entry_id             in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_inv_next_sal_date_warning     boolean;
  l_proposed_salary_warning       boolean;
  l_approved_warning              boolean;
  l_payroll_warning               boolean;
  --
  -- Variables for IN/OUT parameters
  l_element_entry_id              number;
  l_pay_proposal_id               number := p_pay_proposal_id;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'insert_salary_proposal';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
--setting the global variable to Y as the proposed
--proposals have already been deleted through OA.
--schowdhu -04-Dec-2008

HR_MAINTAIN_PROPOSAL_API.g_deleted_from_oa:='Y';


  --
  -- Issue a savepoint
  --
  savepoint insert_salary_proposal_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_element_entry_id              := p_element_entry_id;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  per_pyp_ins.set_base_key_value
    (p_pay_proposal_id => p_pay_proposal_id
    );
  --
  -- Call API
  --
  hr_maintain_proposal_api.insert_salary_proposal
    (p_pay_proposal_id              => l_pay_proposal_id
    ,p_assignment_id                => p_assignment_id
    ,p_business_group_id            => p_business_group_id
    ,p_change_date                  => p_change_date
    ,p_comments                     => p_comments
    ,p_next_sal_review_date         => p_next_sal_review_date
    ,p_proposal_reason              => p_proposal_reason
    ,p_proposed_salary_n            => p_proposed_salary_n
    ,p_forced_ranking               => p_forced_ranking
    ,p_date_to			    => p_date_to
    ,p_performance_review_id        => p_performance_review_id
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
    ,p_object_version_number        => p_object_version_number
    ,p_multiple_components          => p_multiple_components
    ,p_approved                     => p_approved
    ,p_validate                     => l_validate
    ,p_element_entry_id             => p_element_entry_id
    ,p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning
    ,p_proposed_salary_warning      => l_proposed_salary_warning
    ,p_approved_warning             => l_approved_warning
    ,p_payroll_warning              => l_payroll_warning
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
    rollback to insert_salary_proposal_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
--    p_pay_proposal_id              := null;
    p_object_version_number        := null;
    p_element_entry_id             := l_element_entry_id;
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
    rollback to insert_salary_proposal_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    -- p_pay_proposal_id              := null;
    p_object_version_number        := null;
    p_element_entry_id             := l_element_entry_id;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end insert_salary_proposal;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_proposal_component >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_proposal_component
  (p_component_id                 in     number
  ,p_approved                     in     varchar2  default hr_api.g_varchar2
  ,p_component_reason             in     varchar2  default hr_api.g_varchar2
  ,p_change_amount_n              in     number    default hr_api.g_number
  ,p_change_percentage            in     number    default hr_api.g_number
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
  ,p_validation_strength          in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_validate                     in     number    default hr_api.g_false_num
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
  l_proc    varchar2(72) := g_package ||'update_proposal_component';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_proposal_component_swi;
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
  hr_maintain_proposal_api.update_proposal_component
    (p_component_id                 => p_component_id
    ,p_approved                     => p_approved
    ,p_component_reason             => p_component_reason
    ,p_change_amount_n              => p_change_amount_n
    ,p_change_percentage            => p_change_percentage
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
    ,p_validation_strength          => p_validation_strength
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => l_validate
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
    rollback to update_proposal_component_swi;
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
    rollback to update_proposal_component_swi;
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
end update_proposal_component;
-- ----------------------------------------------------------------------------
-- |------------------------< update_salary_proposal >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_salary_proposal
  (p_pay_proposal_id              in     number
  ,p_change_date                  in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_next_sal_review_date         in     date      default hr_api.g_date
  ,p_proposal_reason              in     varchar2  default hr_api.g_varchar2
  ,p_proposed_salary_n            in     number    default hr_api.g_number
  ,p_forced_ranking               in     number    default hr_api.g_number
  ,p_date_to			  in     date      default hr_api.g_date
  ,p_performance_review_id        in     number    default hr_api.g_number
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
  ,p_object_version_number        in out nocopy number
  ,p_multiple_components          in     varchar2  default hr_api.g_varchar2
  ,p_approved                     in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_inv_next_sal_date_warning     boolean;
  l_proposed_salary_warning       boolean;
  l_approved_warning              boolean;
  l_payroll_warning               boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_salary_proposal';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

--setting the global variable to Y as the proposed
--proposals have already been deleted through OA.
--schowdhu -04-Dec-2008

HR_MAINTAIN_PROPOSAL_API.g_deleted_from_oa:='Y';

  --
  -- Issue a savepoint
  --
  savepoint update_salary_proposal_swi;
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
  hr_maintain_proposal_api.update_salary_proposal
    (p_pay_proposal_id              => p_pay_proposal_id
    ,p_change_date                  => p_change_date
    ,p_comments                     => p_comments
    ,p_next_sal_review_date         => p_next_sal_review_date
    ,p_proposal_reason              => p_proposal_reason
    ,p_proposed_salary_n            => p_proposed_salary_n
    ,p_forced_ranking               => p_forced_ranking
    ,p_date_to			    => p_date_to
    ,p_performance_review_id        => p_performance_review_id
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
    ,p_object_version_number        => p_object_version_number
    ,p_multiple_components          => p_multiple_components
    ,p_approved                     => p_approved
    ,p_validate                     => l_validate
    ,p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning
    ,p_proposed_salary_warning      => l_proposed_salary_warning
    ,p_approved_warning             => l_approved_warning
    ,p_payroll_warning              => l_payroll_warning
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
    rollback to update_salary_proposal_swi;
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
    rollback to update_salary_proposal_swi;
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
end update_salary_proposal;

-- ----------------------------------------------------------------------------
-- |----------------------------< process_api >-------------------------------|
-- ----------------------------------------------------------------------------
procedure process_api
(
  p_document            in         CLOB
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

   --
   l_pay_proposal_id  number;
   l_element_entry_id number;
   --

BEGIN

   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);

   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));

   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');

   --Get in/out parameters
   l_pay_proposal_id  :=  hr_transaction_swi.getNumberValue(l_CommitNode,'PayProposalId');
   l_element_entry_id  := null;--hr_transaction_swi.getNumberValue(l_CommitNode,'ElementEntryId');
   l_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');

   if l_postState = '2' then
     --
     hr_maintain_proposal_swi.update_salary_proposal
     (p_pay_proposal_id              =>       l_pay_proposal_id
     ,p_change_date                  =>       hr_transaction_swi.getDateValue(l_CommitNode,'ChangeDate')
     ,p_comments                     =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments')
     ,p_next_sal_review_date         =>       hr_transaction_swi.getDateValue(l_CommitNode,'NextSalReviewDate')
     ,p_proposal_reason              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'ProposalReason')
     ,p_proposed_salary_n            =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ProposedSalaryN')
     ,p_forced_ranking               =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ForcedRanking')
     ,p_date_to			     =>       hr_transaction_swi.getDateValue(l_CommitNode,'DateTo')
     ,p_performance_review_id        =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PerformanceReviewId')
     ,p_attribute_category           =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory')
     ,p_attribute1                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1')
     ,p_attribute2                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2')
     ,p_attribute3                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3')
     ,p_attribute4                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4')
     ,p_attribute5                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5')
     ,p_attribute6                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6')
     ,p_attribute7                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7')
     ,p_attribute8                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8')
     ,p_attribute9                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9')
     ,p_attribute10                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10')
     ,p_attribute11                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11')
     ,p_attribute12                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12')
     ,p_attribute13                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13')
     ,p_attribute14                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14')
     ,p_attribute15                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15')
     ,p_attribute16                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16')
     ,p_attribute17                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17')
     ,p_attribute18                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18')
     ,p_attribute19                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19')
     ,p_attribute20                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20')
     ,p_object_version_number        =>       l_object_version_number
     ,p_multiple_components          =>       'N'--hr_transaction_swi.getVarchar2Value(l_CommitNode,'MultipleComponents')
     ,p_approved                     =>       'N'--hr_transaction_swi.getVarchar2Value(l_CommitNode,'Approved')
     ,p_validate                     =>       p_validate
     ,p_return_status                =>       l_return_status
     );

     --
   elsif l_postState = '3' then
     -- call delete offer
     --
     hr_maintain_proposal_swi.delete_salary_proposal
     (p_pay_proposal_id              =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PayProposalId')
     ,p_business_group_id            =>       hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId')
     ,p_object_version_number        =>       l_object_version_number
     ,p_validate                     =>       p_validate
     ,p_return_status                =>       l_return_status
     );
     --
   end if;
   p_return_status := l_return_status;
   hr_utility.set_location('Exiting:' || l_proc,40);

end process_api;

end hr_maintain_proposal_swi;

/
