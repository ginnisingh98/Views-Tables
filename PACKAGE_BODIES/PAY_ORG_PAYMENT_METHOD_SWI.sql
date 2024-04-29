--------------------------------------------------------
--  DDL for Package Body PAY_ORG_PAYMENT_METHOD_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ORG_PAYMENT_METHOD_SWI" As
/* $Header: pyopmswi.pkb 115.0 2003/09/26 08:29 sdhole noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_org_payment_method_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_org_payment_method >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_org_payment_method
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2  default null
  ,p_business_group_id            in     number
  ,p_org_payment_method_name      in     varchar2
  ,p_payment_type_id              in     number
  ,p_currency_code                in     varchar2  default null
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
  ,p_pmeth_information1           in     varchar2  default null
  ,p_pmeth_information2           in     varchar2  default null
  ,p_pmeth_information3           in     varchar2  default null
  ,p_pmeth_information4           in     varchar2  default null
  ,p_pmeth_information5           in     varchar2  default null
  ,p_pmeth_information6           in     varchar2  default null
  ,p_pmeth_information7           in     varchar2  default null
  ,p_pmeth_information8           in     varchar2  default null
  ,p_pmeth_information9           in     varchar2  default null
  ,p_pmeth_information10          in     varchar2  default null
  ,p_pmeth_information11          in     varchar2  default null
  ,p_pmeth_information12          in     varchar2  default null
  ,p_pmeth_information13          in     varchar2  default null
  ,p_pmeth_information14          in     varchar2  default null
  ,p_pmeth_information15          in     varchar2  default null
  ,p_pmeth_information16          in     varchar2  default null
  ,p_pmeth_information17          in     varchar2  default null
  ,p_pmeth_information18          in     varchar2  default null
  ,p_pmeth_information19          in     varchar2  default null
  ,p_pmeth_information20          in     varchar2  default null
  ,p_comments                     in     varchar2  default null
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
  ,p_gl_segment1                  in     varchar2  default null
  ,p_gl_segment2                  in     varchar2  default null
  ,p_gl_segment3                  in     varchar2  default null
  ,p_gl_segment4                  in     varchar2  default null
  ,p_gl_segment5                  in     varchar2  default null
  ,p_gl_segment6                  in     varchar2  default null
  ,p_gl_segment7                  in     varchar2  default null
  ,p_gl_segment8                  in     varchar2  default null
  ,p_gl_segment9                  in     varchar2  default null
  ,p_gl_segment10                 in     varchar2  default null
  ,p_gl_segment11                 in     varchar2  default null
  ,p_gl_segment12                 in     varchar2  default null
  ,p_gl_segment13                 in     varchar2  default null
  ,p_gl_segment14                 in     varchar2  default null
  ,p_gl_segment15                 in     varchar2  default null
  ,p_gl_segment16                 in     varchar2  default null
  ,p_gl_segment17                 in     varchar2  default null
  ,p_gl_segment18                 in     varchar2  default null
  ,p_gl_segment19                 in     varchar2  default null
  ,p_gl_segment20                 in     varchar2  default null
  ,p_gl_segment21                 in     varchar2  default null
  ,p_gl_segment22                 in     varchar2  default null
  ,p_gl_segment23                 in     varchar2  default null
  ,p_gl_segment24                 in     varchar2  default null
  ,p_gl_segment25                 in     varchar2  default null
  ,p_gl_segment26                 in     varchar2  default null
  ,p_gl_segment27                 in     varchar2  default null
  ,p_gl_segment28                 in     varchar2  default null
  ,p_gl_segment29                 in     varchar2  default null
  ,p_gl_segment30                 in     varchar2  default null
  ,p_gl_concat_segments           in     varchar2  default null
  ,p_sets_of_book_id              in     number    default null
  ,p_third_party_payment          in     varchar2  default null
  ,p_org_payment_method_id        in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_asset_code_combination_id       out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_external_account_id             out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_org_payment_method_id        number;
  l_proc    varchar2(72) := g_package ||'create_org_payment_method';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_org_payment_method_swi;
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
  pay_opm_ins.set_base_key_value
    (p_org_payment_method_id => p_org_payment_method_id
    );
  --
  -- Call API
  --
  pay_org_payment_method_api.create_org_payment_method
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_language_code                => p_language_code
    ,p_business_group_id            => p_business_group_id
    ,p_org_payment_method_name      => p_org_payment_method_name
    ,p_payment_type_id              => p_payment_type_id
    ,p_currency_code                => p_currency_code
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
    ,p_pmeth_information1           => p_pmeth_information1
    ,p_pmeth_information2           => p_pmeth_information2
    ,p_pmeth_information3           => p_pmeth_information3
    ,p_pmeth_information4           => p_pmeth_information4
    ,p_pmeth_information5           => p_pmeth_information5
    ,p_pmeth_information6           => p_pmeth_information6
    ,p_pmeth_information7           => p_pmeth_information7
    ,p_pmeth_information8           => p_pmeth_information8
    ,p_pmeth_information9           => p_pmeth_information9
    ,p_pmeth_information10          => p_pmeth_information10
    ,p_pmeth_information11          => p_pmeth_information11
    ,p_pmeth_information12          => p_pmeth_information12
    ,p_pmeth_information13          => p_pmeth_information13
    ,p_pmeth_information14          => p_pmeth_information14
    ,p_pmeth_information15          => p_pmeth_information15
    ,p_pmeth_information16          => p_pmeth_information16
    ,p_pmeth_information17          => p_pmeth_information17
    ,p_pmeth_information18          => p_pmeth_information18
    ,p_pmeth_information19          => p_pmeth_information19
    ,p_pmeth_information20          => p_pmeth_information20
    ,p_comments                     => p_comments
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
    ,p_gl_segment1                  => p_gl_segment1
    ,p_gl_segment2                  => p_gl_segment2
    ,p_gl_segment3                  => p_gl_segment3
    ,p_gl_segment4                  => p_gl_segment4
    ,p_gl_segment5                  => p_gl_segment5
    ,p_gl_segment6                  => p_gl_segment6
    ,p_gl_segment7                  => p_gl_segment7
    ,p_gl_segment8                  => p_gl_segment8
    ,p_gl_segment9                  => p_gl_segment9
    ,p_gl_segment10                 => p_gl_segment10
    ,p_gl_segment11                 => p_gl_segment11
    ,p_gl_segment12                 => p_gl_segment12
    ,p_gl_segment13                 => p_gl_segment13
    ,p_gl_segment14                 => p_gl_segment14
    ,p_gl_segment15                 => p_gl_segment15
    ,p_gl_segment16                 => p_gl_segment16
    ,p_gl_segment17                 => p_gl_segment17
    ,p_gl_segment18                 => p_gl_segment18
    ,p_gl_segment19                 => p_gl_segment19
    ,p_gl_segment20                 => p_gl_segment20
    ,p_gl_segment21                 => p_gl_segment21
    ,p_gl_segment22                 => p_gl_segment22
    ,p_gl_segment23                 => p_gl_segment23
    ,p_gl_segment24                 => p_gl_segment24
    ,p_gl_segment25                 => p_gl_segment25
    ,p_gl_segment26                 => p_gl_segment26
    ,p_gl_segment27                 => p_gl_segment27
    ,p_gl_segment28                 => p_gl_segment28
    ,p_gl_segment29                 => p_gl_segment29
    ,p_gl_segment30                 => p_gl_segment30
    ,p_gl_concat_segments           => p_gl_concat_segments
    ,p_sets_of_book_id              => p_sets_of_book_id
    ,p_third_party_payment          => p_third_party_payment
    ,p_org_payment_method_id        => l_org_payment_method_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_object_version_number        => p_object_version_number
    ,p_asset_code_combination_id    => p_asset_code_combination_id
    ,p_comment_id                   => p_comment_id
    ,p_external_account_id          => p_external_account_id
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
    rollback to create_org_payment_method_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_asset_code_combination_id    := null;
    p_comment_id                   := null;
    p_external_account_id          := null;
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
    rollback to create_org_payment_method_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_asset_code_combination_id    := null;
    p_comment_id                   := null;
    p_external_account_id          := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_org_payment_method;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_org_payment_method >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_org_payment_method
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_delete_mode        in     varchar2
  ,p_org_payment_method_id        in     number
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
  l_proc    varchar2(72) := g_package ||'delete_org_payment_method';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_org_payment_method_swi;
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
  pay_org_payment_method_api.delete_org_payment_method
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_delete_mode        => p_datetrack_delete_mode
    ,p_org_payment_method_id        => p_org_payment_method_id
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
    rollback to delete_org_payment_method_swi;
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
    rollback to delete_org_payment_method_swi;
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
end delete_org_payment_method;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_org_payment_method >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_org_payment_method
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_org_payment_method_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_org_payment_method_name      in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
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
  ,p_pmeth_information1           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information2           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information3           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information4           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information5           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information6           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information7           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information8           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information9           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information10          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information11          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information12          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information13          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information14          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information15          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information16          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information17          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information18          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information19          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information20          in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
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
  ,p_gl_segment1                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment2                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment3                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment4                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment5                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment6                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment7                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment8                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment9                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment10                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment11                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment12                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment13                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment14                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment15                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment16                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment17                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment18                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment19                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment20                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment21                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment22                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment23                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment24                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment25                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment26                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment27                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment28                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment29                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment30                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_concat_segments           in     varchar2  default hr_api.g_varchar2
  ,p_sets_of_book_id              in     number    default hr_api.g_number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_asset_code_combination_id       out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_external_account_id             out nocopy number
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
  l_proc    varchar2(72) := g_package ||'update_org_payment_method';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_org_payment_method_swi;
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
  pay_org_payment_method_api.update_org_payment_method
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_language_code                => p_language_code
    ,p_org_payment_method_id        => p_org_payment_method_id
    ,p_object_version_number        => p_object_version_number
    ,p_org_payment_method_name      => p_org_payment_method_name
    ,p_currency_code                => p_currency_code
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
    ,p_pmeth_information1           => p_pmeth_information1
    ,p_pmeth_information2           => p_pmeth_information2
    ,p_pmeth_information3           => p_pmeth_information3
    ,p_pmeth_information4           => p_pmeth_information4
    ,p_pmeth_information5           => p_pmeth_information5
    ,p_pmeth_information6           => p_pmeth_information6
    ,p_pmeth_information7           => p_pmeth_information7
    ,p_pmeth_information8           => p_pmeth_information8
    ,p_pmeth_information9           => p_pmeth_information9
    ,p_pmeth_information10          => p_pmeth_information10
    ,p_pmeth_information11          => p_pmeth_information11
    ,p_pmeth_information12          => p_pmeth_information12
    ,p_pmeth_information13          => p_pmeth_information13
    ,p_pmeth_information14          => p_pmeth_information14
    ,p_pmeth_information15          => p_pmeth_information15
    ,p_pmeth_information16          => p_pmeth_information16
    ,p_pmeth_information17          => p_pmeth_information17
    ,p_pmeth_information18          => p_pmeth_information18
    ,p_pmeth_information19          => p_pmeth_information19
    ,p_pmeth_information20          => p_pmeth_information20
    ,p_comments                     => p_comments
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
    ,p_gl_segment1                  => p_gl_segment1
    ,p_gl_segment2                  => p_gl_segment2
    ,p_gl_segment3                  => p_gl_segment3
    ,p_gl_segment4                  => p_gl_segment4
    ,p_gl_segment5                  => p_gl_segment5
    ,p_gl_segment6                  => p_gl_segment6
    ,p_gl_segment7                  => p_gl_segment7
    ,p_gl_segment8                  => p_gl_segment8
    ,p_gl_segment9                  => p_gl_segment9
    ,p_gl_segment10                 => p_gl_segment10
    ,p_gl_segment11                 => p_gl_segment11
    ,p_gl_segment12                 => p_gl_segment12
    ,p_gl_segment13                 => p_gl_segment13
    ,p_gl_segment14                 => p_gl_segment14
    ,p_gl_segment15                 => p_gl_segment15
    ,p_gl_segment16                 => p_gl_segment16
    ,p_gl_segment17                 => p_gl_segment17
    ,p_gl_segment18                 => p_gl_segment18
    ,p_gl_segment19                 => p_gl_segment19
    ,p_gl_segment20                 => p_gl_segment20
    ,p_gl_segment21                 => p_gl_segment21
    ,p_gl_segment22                 => p_gl_segment22
    ,p_gl_segment23                 => p_gl_segment23
    ,p_gl_segment24                 => p_gl_segment24
    ,p_gl_segment25                 => p_gl_segment25
    ,p_gl_segment26                 => p_gl_segment26
    ,p_gl_segment27                 => p_gl_segment27
    ,p_gl_segment28                 => p_gl_segment28
    ,p_gl_segment29                 => p_gl_segment29
    ,p_gl_segment30                 => p_gl_segment30
    ,p_gl_concat_segments           => p_gl_concat_segments
    ,p_sets_of_book_id              => p_sets_of_book_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_asset_code_combination_id    => p_asset_code_combination_id
    ,p_comment_id                   => p_comment_id
    ,p_external_account_id          => p_external_account_id
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
    rollback to update_org_payment_method_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_asset_code_combination_id    := null;
    p_comment_id                   := null;
    p_external_account_id          := null;
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
    rollback to update_org_payment_method_swi;
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
    p_asset_code_combination_id    := null;
    p_comment_id                   := null;
    p_external_account_id          := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_org_payment_method;
end pay_org_payment_method_swi;

/
