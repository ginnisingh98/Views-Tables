--------------------------------------------------------
--  DDL for Package Body OTA_FINANCE_HEADER_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FINANCE_HEADER_SWI" As
/* $Header: ottfhswi.pkb 120.0 2005/05/29 07:41 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_finance_header_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_finance_header >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_finance_header
  (p_finance_header_id            in   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_superceding_header_id        in     number
  ,p_authorizer_person_id         in     number
  ,p_organization_id              in     number
  ,p_administrator                in     number
  ,p_cancelled_flag               in     varchar2
  ,p_currency_code                in     varchar2
  ,p_date_raised                  in     date
  ,p_payment_status_flag          in     varchar2
  ,p_transfer_status              in     varchar2
  ,p_type                         in     varchar2
  ,p_receivable_type              in     varchar2
  ,p_comments                     in     varchar2
  ,p_external_reference           in     varchar2
  ,p_invoice_address              in     varchar2
  ,p_invoice_contact              in     varchar2
  ,p_payment_method               in     varchar2
  ,p_pym_information_category     in     varchar2
  ,p_pym_attribute1               in     varchar2
  ,p_pym_attribute2               in     varchar2
  ,p_pym_attribute3               in     varchar2
  ,p_pym_attribute4               in     varchar2
  ,p_pym_attribute5               in     varchar2
  ,p_pym_attribute6               in     varchar2
  ,p_pym_attribute7               in     varchar2
  ,p_pym_attribute8               in     varchar2
  ,p_pym_attribute9               in     varchar2
  ,p_pym_attribute10              in     varchar2
  ,p_pym_attribute11              in     varchar2
  ,p_pym_attribute12              in     varchar2
  ,p_pym_attribute13              in     varchar2
  ,p_pym_attribute14              in     varchar2
  ,p_pym_attribute15              in     varchar2
  ,p_pym_attribute16              in     varchar2
  ,p_pym_attribute17              in     varchar2
  ,p_pym_attribute18              in     varchar2
  ,p_pym_attribute19              in     varchar2
  ,p_pym_attribute20              in     varchar2
  ,p_transfer_date                in     date
  ,p_transfer_message             in     varchar2
  ,p_vendor_id                    in     number
  ,p_contact_id                   in     number
  ,p_address_id                   in     number
  ,p_customer_id                  in     number
  ,p_tfh_information_category     in     varchar2
  ,p_tfh_information1             in     varchar2
  ,p_tfh_information2             in     varchar2
  ,p_tfh_information3             in     varchar2
  ,p_tfh_information4             in     varchar2
  ,p_tfh_information5             in     varchar2
  ,p_tfh_information6             in     varchar2
  ,p_tfh_information7             in     varchar2
  ,p_tfh_information8             in     varchar2
  ,p_tfh_information9             in     varchar2
  ,p_tfh_information10            in     varchar2
  ,p_tfh_information11            in     varchar2
  ,p_tfh_information12            in     varchar2
  ,p_tfh_information13            in     varchar2
  ,p_tfh_information14            in     varchar2
  ,p_tfh_information15            in     varchar2
  ,p_tfh_information16            in     varchar2
  ,p_tfh_information17            in     varchar2
  ,p_tfh_information18            in     varchar2
  ,p_tfh_information19            in     varchar2
  ,p_tfh_information20            in     varchar2
  ,p_paying_cost_center           in     varchar2
  ,p_receiving_cost_center        in     varchar2
  ,p_transfer_from_set_of_book_id in     number
  ,p_transfer_to_set_of_book_id   in     number
  ,p_from_segment1                in     varchar2
  ,p_from_segment2                in     varchar2
  ,p_from_segment3                in     varchar2
  ,p_from_segment4                in     varchar2
  ,p_from_segment5                in     varchar2
  ,p_from_segment6                in     varchar2
  ,p_from_segment7                in     varchar2
  ,p_from_segment8                in     varchar2
  ,p_from_segment9                in     varchar2
  ,p_from_segment10               in     varchar2
  ,p_from_segment11               in     varchar2
  ,p_from_segment12               in     varchar2
  ,p_from_segment13               in     varchar2
  ,p_from_segment14               in     varchar2
  ,p_from_segment15               in     varchar2
  ,p_from_segment16               in     varchar2
  ,p_from_segment17               in     varchar2
  ,p_from_segment18               in     varchar2
  ,p_from_segment19               in     varchar2
  ,p_from_segment20               in     varchar2
  ,p_from_segment21               in     varchar2
  ,p_from_segment22               in     varchar2
  ,p_from_segment23               in     varchar2
  ,p_from_segment24               in     varchar2
  ,p_from_segment25               in     varchar2
  ,p_from_segment26               in     varchar2
  ,p_from_segment27               in     varchar2
  ,p_from_segment28               in     varchar2
  ,p_from_segment29               in     varchar2
  ,p_from_segment30               in     varchar2
  ,p_to_segment1                  in     varchar2
  ,p_to_segment2                  in     varchar2
  ,p_to_segment3                  in     varchar2
  ,p_to_segment4                  in     varchar2
  ,p_to_segment5                  in     varchar2
  ,p_to_segment6                  in     varchar2
  ,p_to_segment7                  in     varchar2
  ,p_to_segment8                  in     varchar2
  ,p_to_segment9                  in     varchar2
  ,p_to_segment10                 in     varchar2
  ,p_to_segment11                 in     varchar2
  ,p_to_segment12                 in     varchar2
  ,p_to_segment13                 in     varchar2
  ,p_to_segment14                 in     varchar2
  ,p_to_segment15                 in     varchar2
  ,p_to_segment16                 in     varchar2
  ,p_to_segment17                 in     varchar2
  ,p_to_segment18                 in     varchar2
  ,p_to_segment19                 in     varchar2
  ,p_to_segment20                 in     varchar2
  ,p_to_segment21                 in     varchar2
  ,p_to_segment22                 in     varchar2
  ,p_to_segment23                 in     varchar2
  ,p_to_segment24                 in     varchar2
  ,p_to_segment25                 in     varchar2
  ,p_to_segment26                 in     varchar2
  ,p_to_segment27                 in     varchar2
  ,p_to_segment28                 in     varchar2
  ,p_to_segment29                 in     varchar2
  ,p_to_segment30                 in     varchar2
  ,p_transfer_from_cc_id          in     number
  ,p_transfer_to_cc_id            in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_finance_header';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_finance_header_swi;
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
ota_tfh_api_ins.set_base_key_value(finance_header_id => p_finance_header_id  );
  --
  -- Call API
  --
  ota_finance_header_api.create_finance_header
    (p_finance_header_id            => p_finance_header_id
    ,p_object_version_number        => p_object_version_number
    ,p_superceding_header_id        => p_superceding_header_id
    ,p_authorizer_person_id         => p_authorizer_person_id
    ,p_organization_id              => p_organization_id
    ,p_administrator                => p_administrator
    ,p_cancelled_flag               => p_cancelled_flag
    ,p_currency_code                => p_currency_code
    ,p_date_raised                  => p_date_raised
    ,p_payment_status_flag          => p_payment_status_flag
    ,p_transfer_status              => p_transfer_status
    ,p_type                         => p_type
    ,p_receivable_type              => p_receivable_type
    ,p_comments                     => p_comments
    ,p_external_reference           => p_external_reference
    ,p_invoice_address              => p_invoice_address
    ,p_invoice_contact              => p_invoice_contact
    ,p_payment_method               => p_payment_method
    ,p_pym_information_category     => p_pym_information_category
    ,p_pym_attribute1               => p_pym_attribute1
    ,p_pym_attribute2               => p_pym_attribute2
    ,p_pym_attribute3               => p_pym_attribute3
    ,p_pym_attribute4               => p_pym_attribute4
    ,p_pym_attribute5               => p_pym_attribute5
    ,p_pym_attribute6               => p_pym_attribute6
    ,p_pym_attribute7               => p_pym_attribute7
    ,p_pym_attribute8               => p_pym_attribute8
    ,p_pym_attribute9               => p_pym_attribute9
    ,p_pym_attribute10              => p_pym_attribute10
    ,p_pym_attribute11              => p_pym_attribute11
    ,p_pym_attribute12              => p_pym_attribute12
    ,p_pym_attribute13              => p_pym_attribute13
    ,p_pym_attribute14              => p_pym_attribute14
    ,p_pym_attribute15              => p_pym_attribute15
    ,p_pym_attribute16              => p_pym_attribute16
    ,p_pym_attribute17              => p_pym_attribute17
    ,p_pym_attribute18              => p_pym_attribute18
    ,p_pym_attribute19              => p_pym_attribute19
    ,p_pym_attribute20              => p_pym_attribute20
    ,p_transfer_date                => p_transfer_date
    ,p_transfer_message             => p_transfer_message
    ,p_vendor_id                    => p_vendor_id
    ,p_contact_id                   => p_contact_id
    ,p_address_id                   => p_address_id
    ,p_customer_id                  => p_customer_id
    ,p_tfh_information_category     => p_tfh_information_category
    ,p_tfh_information1             => p_tfh_information1
    ,p_tfh_information2             => p_tfh_information2
    ,p_tfh_information3             => p_tfh_information3
    ,p_tfh_information4             => p_tfh_information4
    ,p_tfh_information5             => p_tfh_information5
    ,p_tfh_information6             => p_tfh_information6
    ,p_tfh_information7             => p_tfh_information7
    ,p_tfh_information8             => p_tfh_information8
    ,p_tfh_information9             => p_tfh_information9
    ,p_tfh_information10            => p_tfh_information10
    ,p_tfh_information11            => p_tfh_information11
    ,p_tfh_information12            => p_tfh_information12
    ,p_tfh_information13            => p_tfh_information13
    ,p_tfh_information14            => p_tfh_information14
    ,p_tfh_information15            => p_tfh_information15
    ,p_tfh_information16            => p_tfh_information16
    ,p_tfh_information17            => p_tfh_information17
    ,p_tfh_information18            => p_tfh_information18
    ,p_tfh_information19            => p_tfh_information19
    ,p_tfh_information20            => p_tfh_information20
    ,p_paying_cost_center           => p_paying_cost_center
    ,p_receiving_cost_center        => p_receiving_cost_center
    ,p_transfer_from_set_of_book_id => p_transfer_from_set_of_book_id
    ,p_transfer_to_set_of_book_id   => p_transfer_to_set_of_book_id
    ,p_from_segment1                => p_from_segment1
    ,p_from_segment2                => p_from_segment2
    ,p_from_segment3                => p_from_segment3
    ,p_from_segment4                => p_from_segment4
    ,p_from_segment5                => p_from_segment5
    ,p_from_segment6                => p_from_segment6
    ,p_from_segment7                => p_from_segment7
    ,p_from_segment8                => p_from_segment8
    ,p_from_segment9                => p_from_segment9
    ,p_from_segment10               => p_from_segment10
    ,p_from_segment11               => p_from_segment11
    ,p_from_segment12               => p_from_segment12
    ,p_from_segment13               => p_from_segment13
    ,p_from_segment14               => p_from_segment14
    ,p_from_segment15               => p_from_segment15
    ,p_from_segment16               => p_from_segment16
    ,p_from_segment17               => p_from_segment17
    ,p_from_segment18               => p_from_segment18
    ,p_from_segment19               => p_from_segment19
    ,p_from_segment20               => p_from_segment20
    ,p_from_segment21               => p_from_segment21
    ,p_from_segment22               => p_from_segment22
    ,p_from_segment23               => p_from_segment23
    ,p_from_segment24               => p_from_segment24
    ,p_from_segment25               => p_from_segment25
    ,p_from_segment26               => p_from_segment26
    ,p_from_segment27               => p_from_segment27
    ,p_from_segment28               => p_from_segment28
    ,p_from_segment29               => p_from_segment29
    ,p_from_segment30               => p_from_segment30
    ,p_to_segment1                  => p_to_segment1
    ,p_to_segment2                  => p_to_segment2
    ,p_to_segment3                  => p_to_segment3
    ,p_to_segment4                  => p_to_segment4
    ,p_to_segment5                  => p_to_segment5
    ,p_to_segment6                  => p_to_segment6
    ,p_to_segment7                  => p_to_segment7
    ,p_to_segment8                  => p_to_segment8
    ,p_to_segment9                  => p_to_segment9
    ,p_to_segment10                 => p_to_segment10
    ,p_to_segment11                 => p_to_segment11
    ,p_to_segment12                 => p_to_segment12
    ,p_to_segment13                 => p_to_segment13
    ,p_to_segment14                 => p_to_segment14
    ,p_to_segment15                 => p_to_segment15
    ,p_to_segment16                 => p_to_segment16
    ,p_to_segment17                 => p_to_segment17
    ,p_to_segment18                 => p_to_segment18
    ,p_to_segment19                 => p_to_segment19
    ,p_to_segment20                 => p_to_segment20
    ,p_to_segment21                 => p_to_segment21
    ,p_to_segment22                 => p_to_segment22
    ,p_to_segment23                 => p_to_segment23
    ,p_to_segment24                 => p_to_segment24
    ,p_to_segment25                 => p_to_segment25
    ,p_to_segment26                 => p_to_segment26
    ,p_to_segment27                 => p_to_segment27
    ,p_to_segment28                 => p_to_segment28
    ,p_to_segment29                 => p_to_segment29
    ,p_to_segment30                 => p_to_segment30
    ,p_transfer_from_cc_id          => p_transfer_from_cc_id
    ,p_transfer_to_cc_id            => p_transfer_to_cc_id
    ,p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
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
    rollback to create_finance_header_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_finance_header_id            := null;
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
    rollback to create_finance_header_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_finance_header_id            := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_finance_header;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_finance_header >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_finance_header
  (p_finance_header_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_new_object_version_number       out nocopy number
  ,p_superceding_header_id        in     number
  ,p_authorizer_person_id         in     number
  ,p_organization_id              in     number
  ,p_administrator                in     number
  ,p_cancelled_flag               in     varchar2
  ,p_currency_code                in     varchar2
  ,p_date_raised                  in     date
  ,p_payment_status_flag          in     varchar2
  ,p_transfer_status              in     varchar2
  ,p_type                         in     varchar2
  ,p_receivable_type              in     varchar2
  ,p_comments                     in     varchar2
  ,p_external_reference           in     varchar2
  ,p_invoice_address              in     varchar2
  ,p_invoice_contact              in     varchar2
  ,p_payment_method               in     varchar2
  ,p_pym_information_category     in     varchar2
  ,p_pym_attribute1               in     varchar2
  ,p_pym_attribute2               in     varchar2
  ,p_pym_attribute3               in     varchar2
  ,p_pym_attribute4               in     varchar2
  ,p_pym_attribute5               in     varchar2
  ,p_pym_attribute6               in     varchar2
  ,p_pym_attribute7               in     varchar2
  ,p_pym_attribute8               in     varchar2
  ,p_pym_attribute9               in     varchar2
  ,p_pym_attribute10              in     varchar2
  ,p_pym_attribute11              in     varchar2
  ,p_pym_attribute12              in     varchar2
  ,p_pym_attribute13              in     varchar2
  ,p_pym_attribute14              in     varchar2
  ,p_pym_attribute15              in     varchar2
  ,p_pym_attribute16              in     varchar2
  ,p_pym_attribute17              in     varchar2
  ,p_pym_attribute18              in     varchar2
  ,p_pym_attribute19              in     varchar2
  ,p_pym_attribute20              in     varchar2
  ,p_transfer_date                in     date
  ,p_transfer_message             in     varchar2
  ,p_vendor_id                    in     number
  ,p_contact_id                   in     number
  ,p_address_id                   in     number
  ,p_customer_id                  in     number
  ,p_tfh_information_category     in     varchar2
  ,p_tfh_information1             in     varchar2
  ,p_tfh_information2             in     varchar2
  ,p_tfh_information3             in     varchar2
  ,p_tfh_information4             in     varchar2
  ,p_tfh_information5             in     varchar2
  ,p_tfh_information6             in     varchar2
  ,p_tfh_information7             in     varchar2
  ,p_tfh_information8             in     varchar2
  ,p_tfh_information9             in     varchar2
  ,p_tfh_information10            in     varchar2
  ,p_tfh_information11            in     varchar2
  ,p_tfh_information12            in     varchar2
  ,p_tfh_information13            in     varchar2
  ,p_tfh_information14            in     varchar2
  ,p_tfh_information15            in     varchar2
  ,p_tfh_information16            in     varchar2
  ,p_tfh_information17            in     varchar2
  ,p_tfh_information18            in     varchar2
  ,p_tfh_information19            in     varchar2
  ,p_tfh_information20            in     varchar2
  ,p_paying_cost_center           in     varchar2
  ,p_receiving_cost_center        in     varchar2
  ,p_transfer_from_set_of_book_id in     number
  ,p_transfer_to_set_of_book_id   in     number
  ,p_from_segment1                in     varchar2
  ,p_from_segment2                in     varchar2
  ,p_from_segment3                in     varchar2
  ,p_from_segment4                in     varchar2
  ,p_from_segment5                in     varchar2
  ,p_from_segment6                in     varchar2
  ,p_from_segment7                in     varchar2
  ,p_from_segment8                in     varchar2
  ,p_from_segment9                in     varchar2
  ,p_from_segment10               in     varchar2
  ,p_from_segment11               in     varchar2
  ,p_from_segment12               in     varchar2
  ,p_from_segment13               in     varchar2
  ,p_from_segment14               in     varchar2
  ,p_from_segment15               in     varchar2
  ,p_from_segment16               in     varchar2
  ,p_from_segment17               in     varchar2
  ,p_from_segment18               in     varchar2
  ,p_from_segment19               in     varchar2
  ,p_from_segment20               in     varchar2
  ,p_from_segment21               in     varchar2
  ,p_from_segment22               in     varchar2
  ,p_from_segment23               in     varchar2
  ,p_from_segment24               in     varchar2
  ,p_from_segment25               in     varchar2
  ,p_from_segment26               in     varchar2
  ,p_from_segment27               in     varchar2
  ,p_from_segment28               in     varchar2
  ,p_from_segment29               in     varchar2
  ,p_from_segment30               in     varchar2
  ,p_to_segment1                  in     varchar2
  ,p_to_segment2                  in     varchar2
  ,p_to_segment3                  in     varchar2
  ,p_to_segment4                  in     varchar2
  ,p_to_segment5                  in     varchar2
  ,p_to_segment6                  in     varchar2
  ,p_to_segment7                  in     varchar2
  ,p_to_segment8                  in     varchar2
  ,p_to_segment9                  in     varchar2
  ,p_to_segment10                 in     varchar2
  ,p_to_segment11                 in     varchar2
  ,p_to_segment12                 in     varchar2
  ,p_to_segment13                 in     varchar2
  ,p_to_segment14                 in     varchar2
  ,p_to_segment15                 in     varchar2
  ,p_to_segment16                 in     varchar2
  ,p_to_segment17                 in     varchar2
  ,p_to_segment18                 in     varchar2
  ,p_to_segment19                 in     varchar2
  ,p_to_segment20                 in     varchar2
  ,p_to_segment21                 in     varchar2
  ,p_to_segment22                 in     varchar2
  ,p_to_segment23                 in     varchar2
  ,p_to_segment24                 in     varchar2
  ,p_to_segment25                 in     varchar2
  ,p_to_segment26                 in     varchar2
  ,p_to_segment27                 in     varchar2
  ,p_to_segment28                 in     varchar2
  ,p_to_segment29                 in     varchar2
  ,p_to_segment30                 in     varchar2
  ,p_transfer_from_cc_id          in     number
  ,p_transfer_to_cc_id            in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
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
  l_proc    varchar2(72) := g_package ||'update_finance_header';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_finance_header_swi;
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
  ota_finance_header_api.update_finance_header
    (p_finance_header_id            => p_finance_header_id
    ,p_object_version_number        => p_object_version_number
    ,p_new_object_version_number    => p_new_object_version_number
    ,p_superceding_header_id        => p_superceding_header_id
    ,p_authorizer_person_id         => p_authorizer_person_id
    ,p_organization_id              => p_organization_id
    ,p_administrator                => p_administrator
    ,p_cancelled_flag               => p_cancelled_flag
    ,p_currency_code                => p_currency_code
    ,p_date_raised                  => p_date_raised
    ,p_payment_status_flag          => p_payment_status_flag
    ,p_transfer_status              => p_transfer_status
    ,p_type                         => p_type
    ,p_receivable_type              => p_receivable_type
    ,p_comments                     => p_comments
    ,p_external_reference           => p_external_reference
    ,p_invoice_address              => p_invoice_address
    ,p_invoice_contact              => p_invoice_contact
    ,p_payment_method               => p_payment_method
    ,p_pym_information_category     => p_pym_information_category
    ,p_pym_attribute1               => p_pym_attribute1
    ,p_pym_attribute2               => p_pym_attribute2
    ,p_pym_attribute3               => p_pym_attribute3
    ,p_pym_attribute4               => p_pym_attribute4
    ,p_pym_attribute5               => p_pym_attribute5
    ,p_pym_attribute6               => p_pym_attribute6
    ,p_pym_attribute7               => p_pym_attribute7
    ,p_pym_attribute8               => p_pym_attribute8
    ,p_pym_attribute9               => p_pym_attribute9
    ,p_pym_attribute10              => p_pym_attribute10
    ,p_pym_attribute11              => p_pym_attribute11
    ,p_pym_attribute12              => p_pym_attribute12
    ,p_pym_attribute13              => p_pym_attribute13
    ,p_pym_attribute14              => p_pym_attribute14
    ,p_pym_attribute15              => p_pym_attribute15
    ,p_pym_attribute16              => p_pym_attribute16
    ,p_pym_attribute17              => p_pym_attribute17
    ,p_pym_attribute18              => p_pym_attribute18
    ,p_pym_attribute19              => p_pym_attribute19
    ,p_pym_attribute20              => p_pym_attribute20
    ,p_transfer_date                => p_transfer_date
    ,p_transfer_message             => p_transfer_message
    ,p_vendor_id                    => p_vendor_id
    ,p_contact_id                   => p_contact_id
    ,p_address_id                   => p_address_id
    ,p_customer_id                  => p_customer_id
    ,p_tfh_information_category     => p_tfh_information_category
    ,p_tfh_information1             => p_tfh_information1
    ,p_tfh_information2             => p_tfh_information2
    ,p_tfh_information3             => p_tfh_information3
    ,p_tfh_information4             => p_tfh_information4
    ,p_tfh_information5             => p_tfh_information5
    ,p_tfh_information6             => p_tfh_information6
    ,p_tfh_information7             => p_tfh_information7
    ,p_tfh_information8             => p_tfh_information8
    ,p_tfh_information9             => p_tfh_information9
    ,p_tfh_information10            => p_tfh_information10
    ,p_tfh_information11            => p_tfh_information11
    ,p_tfh_information12            => p_tfh_information12
    ,p_tfh_information13            => p_tfh_information13
    ,p_tfh_information14            => p_tfh_information14
    ,p_tfh_information15            => p_tfh_information15
    ,p_tfh_information16            => p_tfh_information16
    ,p_tfh_information17            => p_tfh_information17
    ,p_tfh_information18            => p_tfh_information18
    ,p_tfh_information19            => p_tfh_information19
    ,p_tfh_information20            => p_tfh_information20
    ,p_paying_cost_center           => p_paying_cost_center
    ,p_receiving_cost_center        => p_receiving_cost_center
    ,p_transfer_from_set_of_book_id => p_transfer_from_set_of_book_id
    ,p_transfer_to_set_of_book_id   => p_transfer_to_set_of_book_id
    ,p_from_segment1                => p_from_segment1
    ,p_from_segment2                => p_from_segment2
    ,p_from_segment3                => p_from_segment3
    ,p_from_segment4                => p_from_segment4
    ,p_from_segment5                => p_from_segment5
    ,p_from_segment6                => p_from_segment6
    ,p_from_segment7                => p_from_segment7
    ,p_from_segment8                => p_from_segment8
    ,p_from_segment9                => p_from_segment9
    ,p_from_segment10               => p_from_segment10
    ,p_from_segment11               => p_from_segment11
    ,p_from_segment12               => p_from_segment12
    ,p_from_segment13               => p_from_segment13
    ,p_from_segment14               => p_from_segment14
    ,p_from_segment15               => p_from_segment15
    ,p_from_segment16               => p_from_segment16
    ,p_from_segment17               => p_from_segment17
    ,p_from_segment18               => p_from_segment18
    ,p_from_segment19               => p_from_segment19
    ,p_from_segment20               => p_from_segment20
    ,p_from_segment21               => p_from_segment21
    ,p_from_segment22               => p_from_segment22
    ,p_from_segment23               => p_from_segment23
    ,p_from_segment24               => p_from_segment24
    ,p_from_segment25               => p_from_segment25
    ,p_from_segment26               => p_from_segment26
    ,p_from_segment27               => p_from_segment27
    ,p_from_segment28               => p_from_segment28
    ,p_from_segment29               => p_from_segment29
    ,p_from_segment30               => p_from_segment30
    ,p_to_segment1                  => p_to_segment1
    ,p_to_segment2                  => p_to_segment2
    ,p_to_segment3                  => p_to_segment3
    ,p_to_segment4                  => p_to_segment4
    ,p_to_segment5                  => p_to_segment5
    ,p_to_segment6                  => p_to_segment6
    ,p_to_segment7                  => p_to_segment7
    ,p_to_segment8                  => p_to_segment8
    ,p_to_segment9                  => p_to_segment9
    ,p_to_segment10                 => p_to_segment10
    ,p_to_segment11                 => p_to_segment11
    ,p_to_segment12                 => p_to_segment12
    ,p_to_segment13                 => p_to_segment13
    ,p_to_segment14                 => p_to_segment14
    ,p_to_segment15                 => p_to_segment15
    ,p_to_segment16                 => p_to_segment16
    ,p_to_segment17                 => p_to_segment17
    ,p_to_segment18                 => p_to_segment18
    ,p_to_segment19                 => p_to_segment19
    ,p_to_segment20                 => p_to_segment20
    ,p_to_segment21                 => p_to_segment21
    ,p_to_segment22                 => p_to_segment22
    ,p_to_segment23                 => p_to_segment23
    ,p_to_segment24                 => p_to_segment24
    ,p_to_segment25                 => p_to_segment25
    ,p_to_segment26                 => p_to_segment26
    ,p_to_segment27                 => p_to_segment27
    ,p_to_segment28                 => p_to_segment28
    ,p_to_segment29                 => p_to_segment29
    ,p_to_segment30                 => p_to_segment30
    ,p_transfer_from_cc_id          => p_transfer_from_cc_id
    ,p_transfer_to_cc_id            => p_transfer_to_cc_id
    ,p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
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
    rollback to update_finance_header_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_new_object_version_number    := null;
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
    rollback to update_finance_header_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_new_object_version_number    := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_finance_header;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_finance_header >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_finance_header
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_finance_header_id            in     number
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
  l_proc    varchar2(72) := g_package ||'delete_finance_header';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_finance_header_swi;
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
  ota_finance_header_api.delete_finance_header
    (p_validate                     => l_validate
    ,p_finance_header_id            => p_finance_header_id
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
    rollback to delete_finance_header_swi;
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
    rollback to delete_finance_header_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_finance_header;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< cancel_header >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- OVERLOADING PROCEDURE
--
-- Description:
--   The update of cancelled_flag is not permitted by any other means
--   than to call this procedure to cancel. This sets the cancelled_flag
--   to 'Y' and creates a cancellation header with the old header_id on
--   the new cancellation header in the supersedes_header_id attribute.
--   The procedure 'CANCEL_LINES_FOR_HEADER', found in the lines API,
--   will then be called.
--
Procedure cancel_header
  (
   p_finance_header_id     in   number
  ,p_cancel_header_id      out  nocopy number
  ,p_date_raised           in   date
  ,p_validate              in   number    default hr_api.g_false_num
  ,p_commit                in   number    default hr_api.g_false_num
  ,p_return_status  out nocopy VARCHAR2
  ) is

    l_validate                      boolean;
    l_commit                        boolean;
  l_proc    varchar2(72) := g_package ||'cancel_header';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
   --
  -- Issue a savepoint
  --
  savepoint cancel_header_swi;
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

    l_commit :=
    hr_api.constant_to_boolean
      (p_constant_value => p_commit);

   ota_tfh_api_business_rules.cancel_header
  (
   p_finance_header_id     => p_finance_header_id
  ,p_cancel_header_id      => p_cancel_header_id
  ,p_date_raised           => p_date_raised
  ,p_validate              => l_validate
  ,p_commit                => l_commit
  );

 p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to cancel_header_swi;
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
    rollback to cancel_header_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;

    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

end cancel_header;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< recancel_header >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
--
-- Description:
--   The update of cancelled_flag is not permitted by any other means
--   than to call this procedure to cancel. This sets the cancelled_flag
--   to 'N' and creates a cancellation header with the old header_id on
--   the new cancellation header in the supersedes_header_id attribute.
--   The procedure 'RECANCEL_LINES_FOR_HEADER', found in the lines API,
--   will then be called.
--
Procedure recancel_header
  (
   p_finance_header_id     in   number
  ,p_validate              in   number    default hr_api.g_false_num
  ,p_commit                in   number    default hr_api.g_false_num
  ,p_return_status  out nocopy VARCHAR2
  ) is
    l_validate                      boolean;
    l_commit                        boolean;
  l_proc    varchar2(72) := g_package ||'recancel_header';
Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
   --
  -- Issue a savepoint
  --
  savepoint recancel_header_swi;
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

    l_commit :=
    hr_api.constant_to_boolean
      (p_constant_value => p_commit);

   ota_tfh_api_business_rules.recancel_header
  (
   p_finance_header_id     => p_finance_header_id
  ,p_validate              => l_validate
  ,p_commit                => l_commit
  );


  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to recancel_header_swi;
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
    rollback to recancel_header_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
         --


end recancel_header;


Procedure cancel_and_recreate
  (
   p_finance_header_id     in   number
  ,p_recreation_header_id  out  nocopy number
  ,p_cancel_header_id      out  nocopy number
  ,p_date_raised           in   date
  ,p_validate              in   number    default hr_api.g_false_num
  ,p_commit                in   number    default hr_api.g_false_num
  ,p_return_status  out nocopy VARCHAR2
  ) is

    l_validate                      boolean;
    l_commit                        boolean;
  l_proc    varchar2(72) := g_package ||'cancel_and_recreate';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
   --
  -- Issue a savepoint
  --
  savepoint cancel_and_recreate_header_swi;
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

    l_commit :=
    hr_api.constant_to_boolean
      (p_constant_value => p_commit);

   ota_tfh_api_business_rules.cancel_and_recreate
  (
   p_finance_header_id     => p_finance_header_id
  ,p_recreation_header_id  => p_recreation_header_id
  ,p_cancel_header_id      => p_cancel_header_id
  ,p_date_raised           => p_date_raised
  ,p_validate              => l_validate
  ,p_commit                => l_commit
  );

 p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to cancel_and_recreate_header_swi;
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
    rollback to cancel_and_recreate_header_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;

    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

end cancel_and_recreate;

end ota_finance_header_swi;

/
