--------------------------------------------------------
--  DDL for Package Body OTA_FINANCE_LINE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FINANCE_LINE_SWI" As
/* $Header: ottflswi.pkb 120.0 2005/05/29 07:43 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_finance_line_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_finance_line >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_finance_line
  (p_finance_line_id              in  number
  ,p_finance_header_id            in     number
  ,p_cancelled_flag               in     varchar2
  ,p_date_raised                  in out nocopy date
  ,p_line_type                    in     varchar2
  ,p_object_version_number           out nocopy number
  ,p_sequence_number              in out nocopy number
  ,p_transfer_status              in     varchar2
  ,p_comments                     in     varchar2
  ,p_currency_code                in     varchar2
  ,p_money_amount                 in     number
  ,p_standard_amount              in     number
  ,p_trans_information_category   in     varchar2
  ,p_trans_information1           in     varchar2
  ,p_trans_information10          in     varchar2
  ,p_trans_information11          in     varchar2
  ,p_trans_information12          in     varchar2
  ,p_trans_information13          in     varchar2
  ,p_trans_information14          in     varchar2
  ,p_trans_information15          in     varchar2
  ,p_trans_information16          in     varchar2
  ,p_trans_information17          in     varchar2
  ,p_trans_information18          in     varchar2
  ,p_trans_information19          in     varchar2
  ,p_trans_information2           in     varchar2
  ,p_trans_information20          in     varchar2
  ,p_trans_information3           in     varchar2
  ,p_trans_information4           in     varchar2
  ,p_trans_information5           in     varchar2
  ,p_trans_information6           in     varchar2
  ,p_trans_information7           in     varchar2
  ,p_trans_information8           in     varchar2
  ,p_trans_information9           in     varchar2
  ,p_transfer_date                in     date
  ,p_transfer_message             in     varchar2
  ,p_unitary_amount               in     number
  ,p_booking_deal_id              in     number
  ,p_booking_id                   in     number
  ,p_resource_allocation_id       in     number
  ,p_resource_booking_id          in     number
  ,p_last_update_date             in     date
  ,p_last_updated_by              in     number
  ,p_last_update_login            in     number
  ,p_created_by                   in     number
  ,p_creation_date                in     date
  ,p_tfl_information_category     in     varchar2
  ,p_tfl_information1             in     varchar2
  ,p_tfl_information2             in     varchar2
  ,p_tfl_information3             in     varchar2
  ,p_tfl_information4             in     varchar2
  ,p_tfl_information5             in     varchar2
  ,p_tfl_information6             in     varchar2
  ,p_tfl_information7             in     varchar2
  ,p_tfl_information8             in     varchar2
  ,p_tfl_information9             in     varchar2
  ,p_tfl_information10            in     varchar2
  ,p_tfl_information11            in     varchar2
  ,p_tfl_information12            in     varchar2
  ,p_tfl_information13            in     varchar2
  ,p_tfl_information14            in     varchar2
  ,p_tfl_information15            in     varchar2
  ,p_tfl_information16            in     varchar2
  ,p_tfl_information17            in     varchar2
  ,p_tfl_information18            in     varchar2
  ,p_tfl_information19            in     varchar2
  ,p_tfl_information20            in     varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_finance_line_id  number;
  l_date_raised                   date;
  l_sequence_number               number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_finance_line';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_finance_line_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_date_raised                   := p_date_raised;
  l_sequence_number               := p_sequence_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
    ota_tfl_api_ins.set_base_key_value(finance_line_id => p_finance_line_id  );
  --
  -- Call API
  --
  ota_finance_line_api.create_finance_line
    (p_finance_line_id              => l_finance_line_id
    ,p_finance_header_id            => p_finance_header_id
    ,p_cancelled_flag               => p_cancelled_flag
    ,p_date_raised                  => p_date_raised
    ,p_line_type                    => p_line_type
    ,p_object_version_number        => p_object_version_number
    ,p_sequence_number              => p_sequence_number
    ,p_transfer_status              => p_transfer_status
    ,p_comments                     => p_comments
    ,p_currency_code                => p_currency_code
    ,p_money_amount                 => p_money_amount
    ,p_standard_amount              => p_standard_amount
    ,p_trans_information_category   => p_trans_information_category
    ,p_trans_information1           => p_trans_information1
    ,p_trans_information10          => p_trans_information10
    ,p_trans_information11          => p_trans_information11
    ,p_trans_information12          => p_trans_information12
    ,p_trans_information13          => p_trans_information13
    ,p_trans_information14          => p_trans_information14
    ,p_trans_information15          => p_trans_information15
    ,p_trans_information16          => p_trans_information16
    ,p_trans_information17          => p_trans_information17
    ,p_trans_information18          => p_trans_information18
    ,p_trans_information19          => p_trans_information19
    ,p_trans_information2           => p_trans_information2
    ,p_trans_information20          => p_trans_information20
    ,p_trans_information3           => p_trans_information3
    ,p_trans_information4           => p_trans_information4
    ,p_trans_information5           => p_trans_information5
    ,p_trans_information6           => p_trans_information6
    ,p_trans_information7           => p_trans_information7
    ,p_trans_information8           => p_trans_information8
    ,p_trans_information9           => p_trans_information9
    ,p_transfer_date                => p_transfer_date
    ,p_transfer_message             => p_transfer_message
    ,p_unitary_amount               => p_unitary_amount
    ,p_booking_deal_id              => p_booking_deal_id
    ,p_booking_id                   => p_booking_id
    ,p_resource_allocation_id       => p_resource_allocation_id
    ,p_resource_booking_id          => p_resource_booking_id
    ,p_last_update_date             => p_last_update_date
    ,p_last_updated_by              => p_last_updated_by
    ,p_last_update_login            => p_last_update_login
    ,p_created_by                   => p_created_by
    ,p_creation_date                => p_creation_date
    ,p_tfl_information_category     => p_tfl_information_category
    ,p_tfl_information1             => p_tfl_information1
    ,p_tfl_information2             => p_tfl_information2
    ,p_tfl_information3             => p_tfl_information3
    ,p_tfl_information4             => p_tfl_information4
    ,p_tfl_information5             => p_tfl_information5
    ,p_tfl_information6             => p_tfl_information6
    ,p_tfl_information7             => p_tfl_information7
    ,p_tfl_information8             => p_tfl_information8
    ,p_tfl_information9             => p_tfl_information9
    ,p_tfl_information10            => p_tfl_information10
    ,p_tfl_information11            => p_tfl_information11
    ,p_tfl_information12            => p_tfl_information12
    ,p_tfl_information13            => p_tfl_information13
    ,p_tfl_information14            => p_tfl_information14
    ,p_tfl_information15            => p_tfl_information15
    ,p_tfl_information16            => p_tfl_information16
    ,p_tfl_information17            => p_tfl_information17
    ,p_tfl_information18            => p_tfl_information18
    ,p_tfl_information19            => p_tfl_information19
    ,p_tfl_information20            => p_tfl_information20
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
    rollback to create_finance_line_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_date_raised                  := l_date_raised;
    p_object_version_number        := null;
    p_sequence_number              := l_sequence_number;
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
    rollback to create_finance_line_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_date_raised                  := l_date_raised;
    p_object_version_number        := null;
    p_sequence_number              := l_sequence_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_finance_line;

-- ----------------------------------------------------------------------------
-- |--------------------------< update_finance_line >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_finance_line
  (p_finance_line_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_new_object_version_number       out nocopy number
  ,p_finance_header_id            in     number
  ,p_cancelled_flag               in     varchar2
  ,p_date_raised                  in out nocopy date
  ,p_line_type                    in     varchar2
  ,p_sequence_number              in out nocopy number
  ,p_transfer_status              in     varchar2
  ,p_comments                     in     varchar2
  ,p_currency_code                in     varchar2
  ,p_money_amount                 in     number
  ,p_standard_amount              in     number
  ,p_trans_information_category   in     varchar2
  ,p_trans_information1           in     varchar2
  ,p_trans_information10          in     varchar2
  ,p_trans_information11          in     varchar2
  ,p_trans_information12          in     varchar2
  ,p_trans_information13          in     varchar2
  ,p_trans_information14          in     varchar2
  ,p_trans_information15          in     varchar2
  ,p_trans_information16          in     varchar2
  ,p_trans_information17          in     varchar2
  ,p_trans_information18          in     varchar2
  ,p_trans_information19          in     varchar2
  ,p_trans_information2           in     varchar2
  ,p_trans_information20          in     varchar2
  ,p_trans_information3           in     varchar2
  ,p_trans_information4           in     varchar2
  ,p_trans_information5           in     varchar2
  ,p_trans_information6           in     varchar2
  ,p_trans_information7           in     varchar2
  ,p_trans_information8           in     varchar2
  ,p_trans_information9           in     varchar2
  ,p_transfer_date                in     date
  ,p_transfer_message             in     varchar2
  ,p_unitary_amount               in     number
  ,p_booking_deal_id              in     number
  ,p_booking_id                   in     number
  ,p_resource_allocation_id       in     number
  ,p_resource_booking_id          in     number
  ,p_last_update_date             in     date
  ,p_last_updated_by              in     number
  ,p_last_update_login            in     number
  ,p_created_by                   in     number
  ,p_creation_date                in     date
  ,p_tfl_information_category     in     varchar2
  ,p_tfl_information1             in     varchar2
  ,p_tfl_information2             in     varchar2
  ,p_tfl_information3             in     varchar2
  ,p_tfl_information4             in     varchar2
  ,p_tfl_information5             in     varchar2
  ,p_tfl_information6             in     varchar2
  ,p_tfl_information7             in     varchar2
  ,p_tfl_information8             in     varchar2
  ,p_tfl_information9             in     varchar2
  ,p_tfl_information10            in     varchar2
  ,p_tfl_information11            in     varchar2
  ,p_tfl_information12            in     varchar2
  ,p_tfl_information13            in     varchar2
  ,p_tfl_information14            in     varchar2
  ,p_tfl_information15            in     varchar2
  ,p_tfl_information16            in     varchar2
  ,p_tfl_information17            in     varchar2
  ,p_tfl_information18            in     varchar2
  ,p_tfl_information19            in     varchar2
  ,p_tfl_information20            in     varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_transaction_type             in     varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_date_raised                   date;
  l_sequence_number               number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_finance_line';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_finance_line_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  l_date_raised                   := p_date_raised;
  l_sequence_number               := p_sequence_number;
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
  ota_finance_line_api.update_finance_line
    (p_finance_line_id              => p_finance_line_id
    ,p_object_version_number        => p_object_version_number
    ,p_new_object_version_number    => p_new_object_version_number
    ,p_finance_header_id            => p_finance_header_id
    ,p_cancelled_flag               => p_cancelled_flag
    ,p_date_raised                  => p_date_raised
    ,p_line_type                    => p_line_type
    ,p_sequence_number              => p_sequence_number
    ,p_transfer_status              => p_transfer_status
    ,p_comments                     => p_comments
    ,p_currency_code                => p_currency_code
    ,p_money_amount                 => p_money_amount
    ,p_standard_amount              => p_standard_amount
    ,p_trans_information_category   => p_trans_information_category
    ,p_trans_information1           => p_trans_information1
    ,p_trans_information10          => p_trans_information10
    ,p_trans_information11          => p_trans_information11
    ,p_trans_information12          => p_trans_information12
    ,p_trans_information13          => p_trans_information13
    ,p_trans_information14          => p_trans_information14
    ,p_trans_information15          => p_trans_information15
    ,p_trans_information16          => p_trans_information16
    ,p_trans_information17          => p_trans_information17
    ,p_trans_information18          => p_trans_information18
    ,p_trans_information19          => p_trans_information19
    ,p_trans_information2           => p_trans_information2
    ,p_trans_information20          => p_trans_information20
    ,p_trans_information3           => p_trans_information3
    ,p_trans_information4           => p_trans_information4
    ,p_trans_information5           => p_trans_information5
    ,p_trans_information6           => p_trans_information6
    ,p_trans_information7           => p_trans_information7
    ,p_trans_information8           => p_trans_information8
    ,p_trans_information9           => p_trans_information9
    ,p_transfer_date                => p_transfer_date
    ,p_transfer_message             => p_transfer_message
    ,p_unitary_amount               => p_unitary_amount
    ,p_booking_deal_id              => p_booking_deal_id
    ,p_booking_id                   => p_booking_id
    ,p_resource_allocation_id       => p_resource_allocation_id
    ,p_resource_booking_id          => p_resource_booking_id
    ,p_last_update_date             => p_last_update_date
    ,p_last_updated_by              => p_last_updated_by
    ,p_last_update_login            => p_last_update_login
    ,p_created_by                   => p_created_by
    ,p_creation_date                => p_creation_date
    ,p_tfl_information_category     => p_tfl_information_category
    ,p_tfl_information1             => p_tfl_information1
    ,p_tfl_information2             => p_tfl_information2
    ,p_tfl_information3             => p_tfl_information3
    ,p_tfl_information4             => p_tfl_information4
    ,p_tfl_information5             => p_tfl_information5
    ,p_tfl_information6             => p_tfl_information6
    ,p_tfl_information7             => p_tfl_information7
    ,p_tfl_information8             => p_tfl_information8
    ,p_tfl_information9             => p_tfl_information9
    ,p_tfl_information10            => p_tfl_information10
    ,p_tfl_information11            => p_tfl_information11
    ,p_tfl_information12            => p_tfl_information12
    ,p_tfl_information13            => p_tfl_information13
    ,p_tfl_information14            => p_tfl_information14
    ,p_tfl_information15            => p_tfl_information15
    ,p_tfl_information16            => p_tfl_information16
    ,p_tfl_information17            => p_tfl_information17
    ,p_tfl_information18            => p_tfl_information18
    ,p_tfl_information19            => p_tfl_information19
    ,p_tfl_information20            => p_tfl_information20
    ,p_validate                     => l_validate
    ,p_transaction_type             => p_transaction_type
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
    rollback to update_finance_line_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_new_object_version_number    := null;
    p_date_raised                  := l_date_raised;
    p_sequence_number              := l_sequence_number;
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
    rollback to update_finance_line_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_new_object_version_number    := null;
    p_date_raised                  := l_date_raised;
    p_sequence_number              := l_sequence_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_finance_line;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_finance_line >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_finance_line
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_finance_line_id              in     number
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
  l_proc    varchar2(72) := g_package ||'delete_finance_line';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_finance_line_swi;
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
  ota_finance_line_api.delete_finance_line
    (p_validate                     => l_validate
    ,p_finance_line_id              => p_finance_line_id
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
    rollback to delete_finance_line_swi;
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
    rollback to delete_finance_line_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_finance_line;
end ota_finance_line_swi;

/
