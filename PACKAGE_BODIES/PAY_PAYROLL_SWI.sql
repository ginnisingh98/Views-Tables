--------------------------------------------------------
--  DDL for Package Body PAY_PAYROLL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYROLL_SWI" As
/* $Header: pyprlswi.pkb 115.1 2003/12/24 06:20 sdhole noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_payroll_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_payroll >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_payroll
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_payroll_name                 in     varchar2
  ,p_payroll_type                 in     varchar2  default null
  ,p_period_type                  in     varchar2
  ,p_first_period_end_date        in     date
  ,p_number_of_years              in     number
  ,p_pay_date_offset              in     number    default 0
  ,p_direct_deposit_date_offset   in     number    default 0
  ,p_pay_advice_date_offset       in     number    default 0
  ,p_cut_off_date_offset          in     number    default 0
  ,p_midpoint_offset              in     number    default null
  ,p_default_payment_method_id    in     number    default null
  ,p_consolidation_set_id         in     number
  ,p_cost_allocation_keyflex_id   in     number    default null
  ,p_suspense_account_keyflex_id  in     number    default null
  ,p_negative_pay_allowed_flag    in     varchar2  default 'N'
  ,p_gl_set_of_books_id           in     number    default null
  ,p_soft_coding_keyflex_id       in     number    default null
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
  ,p_arrears_flag                 in     varchar2  default 'N'
  ,p_period_reset_years           in     number    default null
  ,p_multi_assignments_flag       in     varchar2  default null
  ,p_organization_id              in     number    default null
  ,p_prl_information_category     in     varchar2  default null
  ,p_prl_information1             in     varchar2  default null
  ,p_prl_information2             in     varchar2  default null
  ,p_prl_information3             in     varchar2  default null
  ,p_prl_information4             in     varchar2  default null
  ,p_prl_information5             in     varchar2  default null
  ,p_prl_information6             in     varchar2  default null
  ,p_prl_information7             in     varchar2  default null
  ,p_prl_information8             in     varchar2  default null
  ,p_prl_information9             in     varchar2  default null
  ,p_prl_information10            in     varchar2  default null
  ,p_prl_information11            in     varchar2  default null
  ,p_prl_information12            in     varchar2  default null
  ,p_prl_information13            in     varchar2  default null
  ,p_prl_information14            in     varchar2  default null
  ,p_prl_information15            in     varchar2  default null
  ,p_prl_information16            in     varchar2  default null
  ,p_prl_information17            in     varchar2  default null
  ,p_prl_information18            in     varchar2  default null
  ,p_prl_information19            in     varchar2  default null
  ,p_prl_information20            in     varchar2  default null
  ,p_prl_information21            in     varchar2  default null
  ,p_prl_information22            in     varchar2  default null
  ,p_prl_information23            in     varchar2  default null
  ,p_prl_information24            in     varchar2  default null
  ,p_prl_information25            in     varchar2  default null
  ,p_prl_information26            in     varchar2  default null
  ,p_prl_information27            in     varchar2  default null
  ,p_prl_information28            in     varchar2  default null
  ,p_prl_information29            in     varchar2  default null
  ,p_prl_information30            in     varchar2  default null
  ,p_payroll_id                   in     number -- made IN
  ,p_org_pay_method_usage_id         out nocopy number
  ,p_prl_object_version_number       out nocopy number
  ,p_opm_object_version_number       out nocopy number
  ,p_prl_effective_start_date        out nocopy date
  ,p_prl_effective_end_date          out nocopy date
  ,p_opm_effective_start_date        out nocopy date
  ,p_opm_effective_end_date          out nocopy date
  ,p_comment_id                      out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_payroll_id number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_payroll';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_payroll_swi;
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
  pay_payroll_api.set_base_key_value
    (p_payroll_id => p_payroll_id
    );
  --
  -- Call API
  --
  pay_payroll_api.create_payroll
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_payroll_name                 => p_payroll_name
    ,p_payroll_type                 => p_payroll_type
    ,p_period_type                  => p_period_type
    ,p_first_period_end_date        => p_first_period_end_date
    ,p_number_of_years              => p_number_of_years
    ,p_pay_date_offset              => p_pay_date_offset
    ,p_direct_deposit_date_offset   => p_direct_deposit_date_offset
    ,p_pay_advice_date_offset       => p_pay_advice_date_offset
    ,p_cut_off_date_offset          => p_cut_off_date_offset
    ,p_midpoint_offset              => p_midpoint_offset
    ,p_default_payment_method_id    => p_default_payment_method_id
    ,p_consolidation_set_id         => p_consolidation_set_id
    ,p_cost_allocation_keyflex_id   => p_cost_allocation_keyflex_id
    ,p_suspense_account_keyflex_id  => p_suspense_account_keyflex_id
    ,p_negative_pay_allowed_flag    => p_negative_pay_allowed_flag
    ,p_gl_set_of_books_id           => p_gl_set_of_books_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
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
    ,p_arrears_flag                 => p_arrears_flag
    ,p_period_reset_years           => p_period_reset_years
    ,p_multi_assignments_flag       => p_multi_assignments_flag
    ,p_organization_id              => p_organization_id
    ,p_prl_information_category     => p_prl_information_category
    ,p_prl_information1             => p_prl_information1
    ,p_prl_information2             => p_prl_information2
    ,p_prl_information3             => p_prl_information3
    ,p_prl_information4             => p_prl_information4
    ,p_prl_information5             => p_prl_information5
    ,p_prl_information6             => p_prl_information6
    ,p_prl_information7             => p_prl_information7
    ,p_prl_information8             => p_prl_information8
    ,p_prl_information9             => p_prl_information9
    ,p_prl_information10            => p_prl_information10
    ,p_prl_information11            => p_prl_information11
    ,p_prl_information12            => p_prl_information12
    ,p_prl_information13            => p_prl_information13
    ,p_prl_information14            => p_prl_information14
    ,p_prl_information15            => p_prl_information15
    ,p_prl_information16            => p_prl_information16
    ,p_prl_information17            => p_prl_information17
    ,p_prl_information18            => p_prl_information18
    ,p_prl_information19            => p_prl_information19
    ,p_prl_information20            => p_prl_information20
    ,p_prl_information21            => p_prl_information21
    ,p_prl_information22            => p_prl_information22
    ,p_prl_information23            => p_prl_information23
    ,p_prl_information24            => p_prl_information24
    ,p_prl_information25            => p_prl_information25
    ,p_prl_information26            => p_prl_information26
    ,p_prl_information27            => p_prl_information27
    ,p_prl_information28            => p_prl_information28
    ,p_prl_information29            => p_prl_information29
    ,p_prl_information30            => p_prl_information30
    ,p_payroll_id                   => l_payroll_id
    ,p_org_pay_method_usage_id      => p_org_pay_method_usage_id
    ,p_prl_object_version_number    => p_prl_object_version_number
    ,p_opm_object_version_number    => p_opm_object_version_number
    ,p_prl_effective_start_date     => p_prl_effective_start_date
    ,p_prl_effective_end_date       => p_prl_effective_end_date
    ,p_opm_effective_start_date     => p_opm_effective_start_date
    ,p_opm_effective_end_date       => p_opm_effective_end_date
    ,p_comment_id                   => p_comment_id
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
    rollback to create_payroll_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_org_pay_method_usage_id      := null;
    p_prl_object_version_number    := null;
    p_opm_object_version_number    := null;
    p_prl_effective_start_date     := null;
    p_prl_effective_end_date       := null;
    p_opm_effective_start_date     := null;
    p_opm_effective_end_date       := null;
    p_comment_id                   := null;
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
    rollback to create_payroll_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_org_pay_method_usage_id      := null;
    p_prl_object_version_number    := null;
    p_opm_object_version_number    := null;
    p_prl_effective_start_date     := null;
    p_prl_effective_end_date       := null;
    p_opm_effective_start_date     := null;
    p_opm_effective_end_date       := null;
    p_comment_id                   := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_payroll;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_payroll >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_payroll
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_payroll_id                   in     number
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
  l_proc    varchar2(72) := g_package ||'delete_payroll';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_payroll_swi;
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
  pay_payroll_api.delete_payroll
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_payroll_id                   => p_payroll_id
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
    rollback to delete_payroll_swi;
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
    rollback to delete_payroll_swi;
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
end delete_payroll;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_payroll >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_payroll
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_payroll_id                   in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_payroll_name                 in     varchar2  default hr_api.g_varchar2
  ,p_number_of_years              in     number    default hr_api.g_number
  ,p_default_payment_method_id    in     number    default hr_api.g_number
  ,p_consolidation_set_id         in     number    default hr_api.g_number
  ,p_cost_allocation_keyflex_id   in     number    default hr_api.g_number
  ,p_suspense_account_keyflex_id  in     number    default hr_api.g_number
  ,p_negative_pay_allowed_flag    in     varchar2  default hr_api.g_varchar2
  ,p_soft_coding_keyflex_id       in     number    default hr_api.g_number
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
  ,p_arrears_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_multi_assignments_flag       in     varchar2  default hr_api.g_varchar2
  ,p_prl_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_prl_information1             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information2             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information3             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information4             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information5             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information6             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information7             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information8             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information9             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information10            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information11            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information12            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information13            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information14            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information15            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information16            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information17            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information18            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information19            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information20            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information21            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information22            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information23            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information24            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information25            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information26            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information27            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information28            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information29            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information30            in     varchar2  default hr_api.g_varchar2
  ,p_prl_effective_start_date        out nocopy date
  ,p_prl_effective_end_date          out nocopy date
  ,p_comment_id                      out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_payroll_id                    number;
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_payroll';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_payroll_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_payroll_id                    := p_payroll_id;
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
  pay_payroll_api.update_payroll
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_payroll_id                   => p_payroll_id
    ,p_object_version_number        => p_object_version_number
    ,p_payroll_name                 => p_payroll_name
    ,p_number_of_years              => p_number_of_years
    ,p_default_payment_method_id    => p_default_payment_method_id
    ,p_consolidation_set_id         => p_consolidation_set_id
    ,p_cost_allocation_keyflex_id   => p_cost_allocation_keyflex_id
    ,p_suspense_account_keyflex_id  => p_suspense_account_keyflex_id
    ,p_negative_pay_allowed_flag    => p_negative_pay_allowed_flag
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
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
    ,p_arrears_flag                 => p_arrears_flag
    ,p_multi_assignments_flag       => p_multi_assignments_flag
    ,p_prl_information_category     => p_prl_information_category
    ,p_prl_information1             => p_prl_information1
    ,p_prl_information2             => p_prl_information2
    ,p_prl_information3             => p_prl_information3
    ,p_prl_information4             => p_prl_information4
    ,p_prl_information5             => p_prl_information5
    ,p_prl_information6             => p_prl_information6
    ,p_prl_information7             => p_prl_information7
    ,p_prl_information8             => p_prl_information8
    ,p_prl_information9             => p_prl_information9
    ,p_prl_information10            => p_prl_information10
    ,p_prl_information11            => p_prl_information11
    ,p_prl_information12            => p_prl_information12
    ,p_prl_information13            => p_prl_information13
    ,p_prl_information14            => p_prl_information14
    ,p_prl_information15            => p_prl_information15
    ,p_prl_information16            => p_prl_information16
    ,p_prl_information17            => p_prl_information17
    ,p_prl_information18            => p_prl_information18
    ,p_prl_information19            => p_prl_information19
    ,p_prl_information20            => p_prl_information20
    ,p_prl_information21            => p_prl_information21
    ,p_prl_information22            => p_prl_information22
    ,p_prl_information23            => p_prl_information23
    ,p_prl_information24            => p_prl_information24
    ,p_prl_information25            => p_prl_information25
    ,p_prl_information26            => p_prl_information26
    ,p_prl_information27            => p_prl_information27
    ,p_prl_information28            => p_prl_information28
    ,p_prl_information29            => p_prl_information29
    ,p_prl_information30            => p_prl_information30
    ,p_prl_effective_start_date     => p_prl_effective_start_date
    ,p_prl_effective_end_date       => p_prl_effective_end_date
    ,p_comment_id                   => p_comment_id
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
    rollback to update_payroll_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_payroll_id                   := l_payroll_id;
    p_object_version_number        := l_object_version_number;
    p_prl_effective_start_date     := null;
    p_prl_effective_end_date       := null;
    p_comment_id                   := null;
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
    rollback to update_payroll_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_payroll_id                   := l_payroll_id;
    p_object_version_number        := l_object_version_number;
    p_prl_effective_start_date     := null;
    p_prl_effective_end_date       := null;
    p_comment_id                   := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_payroll;
end pay_payroll_swi;

/
