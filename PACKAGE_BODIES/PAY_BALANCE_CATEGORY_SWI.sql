--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_CATEGORY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_CATEGORY_SWI" As
/* $Header: pypbcswi.pkb 120.0 2005/05/29 07:20 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_balance_category_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_balance_category >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_balance_category
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_category_name                in     varchar2
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_save_run_balance_enabled     in     varchar2  default null
  ,p_user_category_name           in     varchar2  default null
  ,p_pbc_information_category     in     varchar2  default null
  ,p_pbc_information1             in     varchar2  default null
  ,p_pbc_information2             in     varchar2  default null
  ,p_pbc_information3             in     varchar2  default null
  ,p_pbc_information4             in     varchar2  default null
  ,p_pbc_information5             in     varchar2  default null
  ,p_pbc_information6             in     varchar2  default null
  ,p_pbc_information7             in     varchar2  default null
  ,p_pbc_information8             in     varchar2  default null
  ,p_pbc_information9             in     varchar2  default null
  ,p_pbc_information10            in     varchar2  default null
  ,p_pbc_information11            in     varchar2  default null
  ,p_pbc_information12            in     varchar2  default null
  ,p_pbc_information13            in     varchar2  default null
  ,p_pbc_information14            in     varchar2  default null
  ,p_pbc_information15            in     varchar2  default null
  ,p_pbc_information16            in     varchar2  default null
  ,p_pbc_information17            in     varchar2  default null
  ,p_pbc_information18            in     varchar2  default null
  ,p_pbc_information19            in     varchar2  default null
  ,p_pbc_information20            in     varchar2  default null
  ,p_pbc_information21            in     varchar2  default null
  ,p_pbc_information22            in     varchar2  default null
  ,p_pbc_information23            in     varchar2  default null
  ,p_pbc_information24            in     varchar2  default null
  ,p_pbc_information25            in     varchar2  default null
  ,p_pbc_information26            in     varchar2  default null
  ,p_pbc_information27            in     varchar2  default null
  ,p_pbc_information28            in     varchar2  default null
  ,p_pbc_information29            in     varchar2  default null
  ,p_pbc_information30            in     varchar2  default null
  ,p_balance_category_id             out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_balance_category';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_balance_category_swi;
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
  pay_balance_category_api.create_balance_category
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_category_name                => p_category_name
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_save_run_balance_enabled     => p_save_run_balance_enabled
    ,p_user_category_name           => p_user_category_name
    ,p_pbc_information_category     => p_pbc_information_category
    ,p_pbc_information1             => p_pbc_information1
    ,p_pbc_information2             => p_pbc_information2
    ,p_pbc_information3             => p_pbc_information3
    ,p_pbc_information4             => p_pbc_information4
    ,p_pbc_information5             => p_pbc_information5
    ,p_pbc_information6             => p_pbc_information6
    ,p_pbc_information7             => p_pbc_information7
    ,p_pbc_information8             => p_pbc_information8
    ,p_pbc_information9             => p_pbc_information9
    ,p_pbc_information10            => p_pbc_information10
    ,p_pbc_information11            => p_pbc_information11
    ,p_pbc_information12            => p_pbc_information12
    ,p_pbc_information13            => p_pbc_information13
    ,p_pbc_information14            => p_pbc_information14
    ,p_pbc_information15            => p_pbc_information15
    ,p_pbc_information16            => p_pbc_information16
    ,p_pbc_information17            => p_pbc_information17
    ,p_pbc_information18            => p_pbc_information18
    ,p_pbc_information19            => p_pbc_information19
    ,p_pbc_information20            => p_pbc_information20
    ,p_pbc_information21            => p_pbc_information21
    ,p_pbc_information22            => p_pbc_information22
    ,p_pbc_information23            => p_pbc_information23
    ,p_pbc_information24            => p_pbc_information24
    ,p_pbc_information25            => p_pbc_information25
    ,p_pbc_information26            => p_pbc_information26
    ,p_pbc_information27            => p_pbc_information27
    ,p_pbc_information28            => p_pbc_information28
    ,p_pbc_information29            => p_pbc_information29
    ,p_pbc_information30            => p_pbc_information30
    ,p_balance_category_id          => p_balance_category_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to create_balance_category_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_balance_category_id          := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to create_balance_category_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_balance_category_id          := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_balance_category;
-- ----------------------------------------------------------------------------
-- |------------------------< update_balance_category >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_balance_category
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_balance_category_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_save_run_balance_enabled     in     varchar2  default hr_api.g_varchar2
  ,p_user_category_name           in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pbc_information30            in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_balance_category';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_balance_category_swi;
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
  pay_balance_category_api.update_balance_category
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_balance_category_id          => p_balance_category_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_save_run_balance_enabled     => p_save_run_balance_enabled
    ,p_user_category_name           => p_user_category_name
    ,p_pbc_information_category     => p_pbc_information_category
    ,p_pbc_information1             => p_pbc_information1
    ,p_pbc_information2             => p_pbc_information2
    ,p_pbc_information3             => p_pbc_information3
    ,p_pbc_information4             => p_pbc_information4
    ,p_pbc_information5             => p_pbc_information5
    ,p_pbc_information6             => p_pbc_information6
    ,p_pbc_information7             => p_pbc_information7
    ,p_pbc_information8             => p_pbc_information8
    ,p_pbc_information9             => p_pbc_information9
    ,p_pbc_information10            => p_pbc_information10
    ,p_pbc_information11            => p_pbc_information11
    ,p_pbc_information12            => p_pbc_information12
    ,p_pbc_information13            => p_pbc_information13
    ,p_pbc_information14            => p_pbc_information14
    ,p_pbc_information15            => p_pbc_information15
    ,p_pbc_information16            => p_pbc_information16
    ,p_pbc_information17            => p_pbc_information17
    ,p_pbc_information18            => p_pbc_information18
    ,p_pbc_information19            => p_pbc_information19
    ,p_pbc_information20            => p_pbc_information20
    ,p_pbc_information21            => p_pbc_information21
    ,p_pbc_information22            => p_pbc_information22
    ,p_pbc_information23            => p_pbc_information23
    ,p_pbc_information24            => p_pbc_information24
    ,p_pbc_information25            => p_pbc_information25
    ,p_pbc_information26            => p_pbc_information26
    ,p_pbc_information27            => p_pbc_information27
    ,p_pbc_information28            => p_pbc_information28
    ,p_pbc_information29            => p_pbc_information29
    ,p_pbc_information30            => p_pbc_information30
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
    rollback to update_balance_category_swi;
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
    rollback to update_balance_category_swi;
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
end update_balance_category;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_balance_category >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_balance_category
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_delete_mode        in     varchar2
  ,p_balance_category_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'delete_balance_category';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_balance_category_swi;
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
  pay_balance_category_api.delete_balance_category
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_delete_mode        => p_datetrack_delete_mode
    ,p_balance_category_id          => p_balance_category_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
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
    rollback to delete_balance_category_swi;
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
    rollback to delete_balance_category_swi;
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
end delete_balance_category;
end pay_balance_category_swi;

/
