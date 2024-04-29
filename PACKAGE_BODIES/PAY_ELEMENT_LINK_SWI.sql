--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_LINK_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_LINK_SWI" As
/* $Header: pypelswi.pkb 115.0 2002/12/31 02:15:03 ndorai noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_element_link_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_element_link >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_element_link
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_element_type_id              in     number
  ,p_business_group_id            in     number
  ,p_costable_type                in     varchar2
  ,p_payroll_id                   in     number    default null
  ,p_job_id                       in     number    default null
  ,p_position_id                  in     number    default null
  ,p_people_group_id              in     number    default null
  ,p_cost_allocation_keyflex_id   in     number    default null
  ,p_organization_id              in     number    default null
  ,p_location_id                  in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_balancing_keyflex_id         in     number    default null
  ,p_element_set_id               in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_link_to_all_payrolls_flag    in     varchar2  default null
  ,p_standard_link_flag           in     varchar2  default null
  ,p_transfer_to_gl_flag          in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_qualifying_age               in     number    default null
  ,p_qualifying_length_of_service in     number    default null
  ,p_qualifying_units             in     varchar2  default null
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
  ,p_cost_segment1                in     varchar2  default null
  ,p_cost_segment2                in     varchar2  default null
  ,p_cost_segment3                in     varchar2  default null
  ,p_cost_segment4                in     varchar2  default null
  ,p_cost_segment5                in     varchar2  default null
  ,p_cost_segment6                in     varchar2  default null
  ,p_cost_segment7                in     varchar2  default null
  ,p_cost_segment8                in     varchar2  default null
  ,p_cost_segment9                in     varchar2  default null
  ,p_cost_segment10               in     varchar2  default null
  ,p_cost_segment11               in     varchar2  default null
  ,p_cost_segment12               in     varchar2  default null
  ,p_cost_segment13               in     varchar2  default null
  ,p_cost_segment14               in     varchar2  default null
  ,p_cost_segment15               in     varchar2  default null
  ,p_cost_segment16               in     varchar2  default null
  ,p_cost_segment17               in     varchar2  default null
  ,p_cost_segment18               in     varchar2  default null
  ,p_cost_segment19               in     varchar2  default null
  ,p_cost_segment20               in     varchar2  default null
  ,p_cost_segment21               in     varchar2  default null
  ,p_cost_segment22               in     varchar2  default null
  ,p_cost_segment23               in     varchar2  default null
  ,p_cost_segment24               in     varchar2  default null
  ,p_cost_segment25               in     varchar2  default null
  ,p_cost_segment26               in     varchar2  default null
  ,p_cost_segment27               in     varchar2  default null
  ,p_cost_segment28               in     varchar2  default null
  ,p_cost_segment29               in     varchar2  default null
  ,p_cost_segment30               in     varchar2  default null
  ,p_balance_segment1             in     varchar2  default null
  ,p_balance_segment2             in     varchar2  default null
  ,p_balance_segment3             in     varchar2  default null
  ,p_balance_segment4             in     varchar2  default null
  ,p_balance_segment5             in     varchar2  default null
  ,p_balance_segment6             in     varchar2  default null
  ,p_balance_segment7             in     varchar2  default null
  ,p_balance_segment8             in     varchar2  default null
  ,p_balance_segment9             in     varchar2  default null
  ,p_balance_segment10            in     varchar2  default null
  ,p_balance_segment11            in     varchar2  default null
  ,p_balance_segment12            in     varchar2  default null
  ,p_balance_segment13            in     varchar2  default null
  ,p_balance_segment14            in     varchar2  default null
  ,p_balance_segment15            in     varchar2  default null
  ,p_balance_segment16            in     varchar2  default null
  ,p_balance_segment17            in     varchar2  default null
  ,p_balance_segment18            in     varchar2  default null
  ,p_balance_segment19            in     varchar2  default null
  ,p_balance_segment20            in     varchar2  default null
  ,p_balance_segment21            in     varchar2  default null
  ,p_balance_segment22            in     varchar2  default null
  ,p_balance_segment23            in     varchar2  default null
  ,p_balance_segment24            in     varchar2  default null
  ,p_balance_segment25            in     varchar2  default null
  ,p_balance_segment26            in     varchar2  default null
  ,p_balance_segment27            in     varchar2  default null
  ,p_balance_segment28            in     varchar2  default null
  ,p_balance_segment29            in     varchar2  default null
  ,p_balance_segment30            in     varchar2  default null
  ,p_cost_concat_segments         in     varchar2
  ,p_balance_concat_segments      in     varchar2
  ,p_element_link_id                 out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_object_version_number           out nocopy number
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
  l_proc    varchar2(72) := g_package ||'create_element_link';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_element_link_swi;
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
  pay_element_link_api.create_element_link
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_element_type_id              => p_element_type_id
    ,p_business_group_id            => p_business_group_id
    ,p_costable_type                => p_costable_type
    ,p_payroll_id                   => p_payroll_id
    ,p_job_id                       => p_job_id
    ,p_position_id                  => p_position_id
    ,p_people_group_id              => p_people_group_id
    ,p_cost_allocation_keyflex_id   => p_cost_allocation_keyflex_id
    ,p_organization_id              => p_organization_id
    ,p_location_id                  => p_location_id
    ,p_grade_id                     => p_grade_id
    ,p_balancing_keyflex_id         => p_balancing_keyflex_id
    ,p_element_set_id               => p_element_set_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_link_to_all_payrolls_flag    => p_link_to_all_payrolls_flag
    ,p_standard_link_flag           => p_standard_link_flag
    ,p_transfer_to_gl_flag          => p_transfer_to_gl_flag
    ,p_comments                     => p_comments
    ,p_employment_category          => p_employment_category
    ,p_qualifying_age               => p_qualifying_age
    ,p_qualifying_length_of_service => p_qualifying_length_of_service
    ,p_qualifying_units             => p_qualifying_units
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
    ,p_cost_segment1                => p_cost_segment1
    ,p_cost_segment2                => p_cost_segment2
    ,p_cost_segment3                => p_cost_segment3
    ,p_cost_segment4                => p_cost_segment4
    ,p_cost_segment5                => p_cost_segment5
    ,p_cost_segment6                => p_cost_segment6
    ,p_cost_segment7                => p_cost_segment7
    ,p_cost_segment8                => p_cost_segment8
    ,p_cost_segment9                => p_cost_segment9
    ,p_cost_segment10               => p_cost_segment10
    ,p_cost_segment11               => p_cost_segment11
    ,p_cost_segment12               => p_cost_segment12
    ,p_cost_segment13               => p_cost_segment13
    ,p_cost_segment14               => p_cost_segment14
    ,p_cost_segment15               => p_cost_segment15
    ,p_cost_segment16               => p_cost_segment16
    ,p_cost_segment17               => p_cost_segment17
    ,p_cost_segment18               => p_cost_segment18
    ,p_cost_segment19               => p_cost_segment19
    ,p_cost_segment20               => p_cost_segment20
    ,p_cost_segment21               => p_cost_segment21
    ,p_cost_segment22               => p_cost_segment22
    ,p_cost_segment23               => p_cost_segment23
    ,p_cost_segment24               => p_cost_segment24
    ,p_cost_segment25               => p_cost_segment25
    ,p_cost_segment26               => p_cost_segment26
    ,p_cost_segment27               => p_cost_segment27
    ,p_cost_segment28               => p_cost_segment28
    ,p_cost_segment29               => p_cost_segment29
    ,p_cost_segment30               => p_cost_segment30
    ,p_balance_segment1             => p_balance_segment1
    ,p_balance_segment2             => p_balance_segment2
    ,p_balance_segment3             => p_balance_segment3
    ,p_balance_segment4             => p_balance_segment4
    ,p_balance_segment5             => p_balance_segment5
    ,p_balance_segment6             => p_balance_segment6
    ,p_balance_segment7             => p_balance_segment7
    ,p_balance_segment8             => p_balance_segment8
    ,p_balance_segment9             => p_balance_segment9
    ,p_balance_segment10            => p_balance_segment10
    ,p_balance_segment11            => p_balance_segment11
    ,p_balance_segment12            => p_balance_segment12
    ,p_balance_segment13            => p_balance_segment13
    ,p_balance_segment14            => p_balance_segment14
    ,p_balance_segment15            => p_balance_segment15
    ,p_balance_segment16            => p_balance_segment16
    ,p_balance_segment17            => p_balance_segment17
    ,p_balance_segment18            => p_balance_segment18
    ,p_balance_segment19            => p_balance_segment19
    ,p_balance_segment20            => p_balance_segment20
    ,p_balance_segment21            => p_balance_segment21
    ,p_balance_segment22            => p_balance_segment22
    ,p_balance_segment23            => p_balance_segment23
    ,p_balance_segment24            => p_balance_segment24
    ,p_balance_segment25            => p_balance_segment25
    ,p_balance_segment26            => p_balance_segment26
    ,p_balance_segment27            => p_balance_segment27
    ,p_balance_segment28            => p_balance_segment28
    ,p_balance_segment29            => p_balance_segment29
    ,p_balance_segment30            => p_balance_segment30
    ,p_cost_concat_segments         => p_cost_concat_segments
    ,p_balance_concat_segments      => p_balance_concat_segments
    ,p_element_link_id              => p_element_link_id
    ,p_comment_id                   => p_comment_id
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
    rollback to create_element_link_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_element_link_id              := null;
    p_comment_id                   := null;
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
    rollback to create_element_link_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_element_link_id              := null;
    p_comment_id                   := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_element_link;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_element_link >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_element_link
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_element_link_id              in     number
  ,p_datetrack_delete_mode        in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_entries_warning               boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_element_link';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_element_link_swi;
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
  pay_element_link_api.delete_element_link
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_element_link_id              => p_element_link_id
    ,p_datetrack_delete_mode        => p_datetrack_delete_mode
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_entries_warning              => l_entries_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_entries_warning then
     /*fnd_message.set_name('EDIT HERE: APP_CODE', 'EDIT_HERE: MESSAGE_NAME ');*/
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
    rollback to delete_element_link_swi;
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
    rollback to delete_element_link_swi;
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
end delete_element_link;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_element_link >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_element_link
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_element_link_id              in     number
  ,p_datetrack_mode               in     varchar2
  ,p_costable_type                in     varchar2  default hr_api.g_varchar2
  ,p_element_set_id               in     number    default hr_api.g_number
  ,p_multiply_value_flag          in     varchar2  default hr_api.g_varchar2
  ,p_standard_link_flag           in     varchar2  default hr_api.g_varchar2
  ,p_transfer_to_gl_flag          in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_comment_id                   in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_qualifying_age               in     number    default hr_api.g_number
  ,p_qualifying_length_of_service in     number    default hr_api.g_number
  ,p_qualifying_units             in     varchar2  default hr_api.g_varchar2
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
  ,p_cost_segment1                in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment2                in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment3                in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment4                in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment5                in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment6                in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment7                in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment8                in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment9                in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment10               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment11               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment12               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment13               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment14               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment15               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment16               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment17               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment18               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment19               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment20               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment21               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment22               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment23               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment24               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment25               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment26               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment27               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment28               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment29               in     varchar2  default hr_api.g_varchar2
  ,p_cost_segment30               in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment1             in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment2             in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment3             in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment4             in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment5             in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment6             in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment7             in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment8             in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment9             in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment10            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment11            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment12            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment13            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment14            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment15            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment16            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment17            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment18            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment19            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment20            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment21            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment22            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment23            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment24            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment25            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment26            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment27            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment28            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment29            in     varchar2  default hr_api.g_varchar2
  ,p_balance_segment30            in     varchar2  default hr_api.g_varchar2
  ,p_cost_concat_segments_in      in     varchar2  default hr_api.g_varchar2
  ,p_balance_concat_segments_in   in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_cost_allocation_keyflex_id      out nocopy number
  ,p_balancing_keyflex_id            out nocopy number
  ,p_cost_concat_segments_out        out nocopy varchar2
  ,p_balance_concat_segments_out     out nocopy varchar2
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
  l_proc    varchar2(72) := g_package ||'update_element_link';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_element_link_swi;
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
  pay_element_link_api.update_element_link
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_element_link_id              => p_element_link_id
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_costable_type                => p_costable_type
    ,p_element_set_id               => p_element_set_id
    ,p_multiply_value_flag          => p_multiply_value_flag
    ,p_standard_link_flag           => p_standard_link_flag
    ,p_transfer_to_gl_flag          => p_transfer_to_gl_flag
    ,p_comments                     => p_comments
    ,p_comment_id                   => p_comment_id
    ,p_employment_category          => p_employment_category
    ,p_qualifying_age               => p_qualifying_age
    ,p_qualifying_length_of_service => p_qualifying_length_of_service
    ,p_qualifying_units             => p_qualifying_units
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
    ,p_cost_segment1                => p_cost_segment1
    ,p_cost_segment2                => p_cost_segment2
    ,p_cost_segment3                => p_cost_segment3
    ,p_cost_segment4                => p_cost_segment4
    ,p_cost_segment5                => p_cost_segment5
    ,p_cost_segment6                => p_cost_segment6
    ,p_cost_segment7                => p_cost_segment7
    ,p_cost_segment8                => p_cost_segment8
    ,p_cost_segment9                => p_cost_segment9
    ,p_cost_segment10               => p_cost_segment10
    ,p_cost_segment11               => p_cost_segment11
    ,p_cost_segment12               => p_cost_segment12
    ,p_cost_segment13               => p_cost_segment13
    ,p_cost_segment14               => p_cost_segment14
    ,p_cost_segment15               => p_cost_segment15
    ,p_cost_segment16               => p_cost_segment16
    ,p_cost_segment17               => p_cost_segment17
    ,p_cost_segment18               => p_cost_segment18
    ,p_cost_segment19               => p_cost_segment19
    ,p_cost_segment20               => p_cost_segment20
    ,p_cost_segment21               => p_cost_segment21
    ,p_cost_segment22               => p_cost_segment22
    ,p_cost_segment23               => p_cost_segment23
    ,p_cost_segment24               => p_cost_segment24
    ,p_cost_segment25               => p_cost_segment25
    ,p_cost_segment26               => p_cost_segment26
    ,p_cost_segment27               => p_cost_segment27
    ,p_cost_segment28               => p_cost_segment28
    ,p_cost_segment29               => p_cost_segment29
    ,p_cost_segment30               => p_cost_segment30
    ,p_balance_segment1             => p_balance_segment1
    ,p_balance_segment2             => p_balance_segment2
    ,p_balance_segment3             => p_balance_segment3
    ,p_balance_segment4             => p_balance_segment4
    ,p_balance_segment5             => p_balance_segment5
    ,p_balance_segment6             => p_balance_segment6
    ,p_balance_segment7             => p_balance_segment7
    ,p_balance_segment8             => p_balance_segment8
    ,p_balance_segment9             => p_balance_segment9
    ,p_balance_segment10            => p_balance_segment10
    ,p_balance_segment11            => p_balance_segment11
    ,p_balance_segment12            => p_balance_segment12
    ,p_balance_segment13            => p_balance_segment13
    ,p_balance_segment14            => p_balance_segment14
    ,p_balance_segment15            => p_balance_segment15
    ,p_balance_segment16            => p_balance_segment16
    ,p_balance_segment17            => p_balance_segment17
    ,p_balance_segment18            => p_balance_segment18
    ,p_balance_segment19            => p_balance_segment19
    ,p_balance_segment20            => p_balance_segment20
    ,p_balance_segment21            => p_balance_segment21
    ,p_balance_segment22            => p_balance_segment22
    ,p_balance_segment23            => p_balance_segment23
    ,p_balance_segment24            => p_balance_segment24
    ,p_balance_segment25            => p_balance_segment25
    ,p_balance_segment26            => p_balance_segment26
    ,p_balance_segment27            => p_balance_segment27
    ,p_balance_segment28            => p_balance_segment28
    ,p_balance_segment29            => p_balance_segment29
    ,p_balance_segment30            => p_balance_segment30
    ,p_cost_concat_segments_in      => p_cost_concat_segments_in
    ,p_balance_concat_segments_in   => p_balance_concat_segments_in
    ,p_object_version_number        => p_object_version_number
    ,p_cost_allocation_keyflex_id   => p_cost_allocation_keyflex_id
    ,p_balancing_keyflex_id         => p_balancing_keyflex_id
    ,p_cost_concat_segments_out     => p_cost_concat_segments_out
    ,p_balance_concat_segments_out  => p_balance_concat_segments_out
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
    rollback to update_element_link_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_cost_allocation_keyflex_id   := null;
    p_balancing_keyflex_id         := null;
    p_cost_concat_segments_out     := null;
    p_balance_concat_segments_out  := null;
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
    rollback to update_element_link_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_cost_allocation_keyflex_id   := null;
    p_balancing_keyflex_id         := null;
    p_cost_concat_segments_out     := null;
    p_balance_concat_segments_out  := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_element_link;
end pay_element_link_swi;

/
