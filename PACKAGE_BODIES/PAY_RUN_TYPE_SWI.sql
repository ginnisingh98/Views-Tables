--------------------------------------------------------
--  DDL for Package Body PAY_RUN_TYPE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RUN_TYPE_SWI" As
/* $Header: pyprtswi.pkb 120.0 2005/05/29 07:53 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_run_type_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_run_type >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_run_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2  default null
  ,p_run_type_name                in     varchar2
  ,p_run_method                   in     varchar2
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_shortname                    in     varchar2  default null
  ,p_srs_flag                     in     varchar2  default null
  ,p_run_information_category     in     varchar2  default null
  ,p_run_information1             in     varchar2  default null
  ,p_run_information2             in     varchar2  default null
  ,p_run_information3             in     varchar2  default null
  ,p_run_information4             in     varchar2  default null
  ,p_run_information5             in     varchar2  default null
  ,p_run_information6             in     varchar2  default null
  ,p_run_information7             in     varchar2  default null
  ,p_run_information8             in     varchar2  default null
  ,p_run_information9             in     varchar2  default null
  ,p_run_information10            in     varchar2  default null
  ,p_run_information11            in     varchar2  default null
  ,p_run_information12            in     varchar2  default null
  ,p_run_information13            in     varchar2  default null
  ,p_run_information14            in     varchar2  default null
  ,p_run_information15            in     varchar2  default null
  ,p_run_information16            in     varchar2  default null
  ,p_run_information17            in     varchar2  default null
  ,p_run_information18            in     varchar2  default null
  ,p_run_information19            in     varchar2  default null
  ,p_run_information20            in     varchar2  default null
  ,p_run_information21            in     varchar2  default null
  ,p_run_information22            in     varchar2  default null
  ,p_run_information23            in     varchar2  default null
  ,p_run_information24            in     varchar2  default null
  ,p_run_information25            in     varchar2  default null
  ,p_run_information26            in     varchar2  default null
  ,p_run_information27            in     varchar2  default null
  ,p_run_information28            in     varchar2  default null
  ,p_run_information29            in     varchar2  default null
  ,p_run_information30            in     varchar2  default null
  ,p_run_type_id                     out nocopy number
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
  l_proc    varchar2(72) := g_package ||'create_run_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_run_type_swi;
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
  pay_run_type_api.create_run_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_language_code                => p_language_code
    ,p_run_type_name                => p_run_type_name
    ,p_run_method                   => p_run_method
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_shortname                    => p_shortname
    ,p_srs_flag                     => p_srs_flag
    ,p_run_information_category     => p_run_information_category
    ,p_run_information1             => p_run_information1
    ,p_run_information2             => p_run_information2
    ,p_run_information3             => p_run_information3
    ,p_run_information4             => p_run_information4
    ,p_run_information5             => p_run_information5
    ,p_run_information6             => p_run_information6
    ,p_run_information7             => p_run_information7
    ,p_run_information8             => p_run_information8
    ,p_run_information9             => p_run_information9
    ,p_run_information10            => p_run_information10
    ,p_run_information11            => p_run_information11
    ,p_run_information12            => p_run_information12
    ,p_run_information13            => p_run_information13
    ,p_run_information14            => p_run_information14
    ,p_run_information15            => p_run_information15
    ,p_run_information16            => p_run_information16
    ,p_run_information17            => p_run_information17
    ,p_run_information18            => p_run_information18
    ,p_run_information19            => p_run_information19
    ,p_run_information20            => p_run_information20
    ,p_run_information21            => p_run_information21
    ,p_run_information22            => p_run_information22
    ,p_run_information23            => p_run_information23
    ,p_run_information24            => p_run_information24
    ,p_run_information25            => p_run_information25
    ,p_run_information26            => p_run_information26
    ,p_run_information27            => p_run_information27
    ,p_run_information28            => p_run_information28
    ,p_run_information29            => p_run_information29
    ,p_run_information30            => p_run_information30
    ,p_run_type_id                  => p_run_type_id
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
    rollback to create_run_type_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_run_type_id                  := null;
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
    rollback to create_run_type_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_run_type_id                  := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_run_type;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_run_type >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_run_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_run_type_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_shortname                    in     varchar2  default hr_api.g_varchar2
  ,p_srs_flag                     in     varchar2  default hr_api.g_varchar2
  ,p_run_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_run_information1             in     varchar2  default hr_api.g_varchar2
  ,p_run_information2             in     varchar2  default hr_api.g_varchar2
  ,p_run_information3             in     varchar2  default hr_api.g_varchar2
  ,p_run_information4             in     varchar2  default hr_api.g_varchar2
  ,p_run_information5             in     varchar2  default hr_api.g_varchar2
  ,p_run_information6             in     varchar2  default hr_api.g_varchar2
  ,p_run_information7             in     varchar2  default hr_api.g_varchar2
  ,p_run_information8             in     varchar2  default hr_api.g_varchar2
  ,p_run_information9             in     varchar2  default hr_api.g_varchar2
  ,p_run_information10            in     varchar2  default hr_api.g_varchar2
  ,p_run_information11            in     varchar2  default hr_api.g_varchar2
  ,p_run_information12            in     varchar2  default hr_api.g_varchar2
  ,p_run_information13            in     varchar2  default hr_api.g_varchar2
  ,p_run_information14            in     varchar2  default hr_api.g_varchar2
  ,p_run_information15            in     varchar2  default hr_api.g_varchar2
  ,p_run_information16            in     varchar2  default hr_api.g_varchar2
  ,p_run_information17            in     varchar2  default hr_api.g_varchar2
  ,p_run_information18            in     varchar2  default hr_api.g_varchar2
  ,p_run_information19            in     varchar2  default hr_api.g_varchar2
  ,p_run_information20            in     varchar2  default hr_api.g_varchar2
  ,p_run_information21            in     varchar2  default hr_api.g_varchar2
  ,p_run_information22            in     varchar2  default hr_api.g_varchar2
  ,p_run_information23            in     varchar2  default hr_api.g_varchar2
  ,p_run_information24            in     varchar2  default hr_api.g_varchar2
  ,p_run_information25            in     varchar2  default hr_api.g_varchar2
  ,p_run_information26            in     varchar2  default hr_api.g_varchar2
  ,p_run_information27            in     varchar2  default hr_api.g_varchar2
  ,p_run_information28            in     varchar2  default hr_api.g_varchar2
  ,p_run_information29            in     varchar2  default hr_api.g_varchar2
  ,p_run_information30            in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_run_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_run_type_swi;
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
  pay_run_type_api.update_run_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_language_code                => p_language_code
    ,p_run_type_id                  => p_run_type_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_shortname                    => p_shortname
    ,p_srs_flag                     => p_srs_flag
    ,p_run_information_category     => p_run_information_category
    ,p_run_information1             => p_run_information1
    ,p_run_information2             => p_run_information2
    ,p_run_information3             => p_run_information3
    ,p_run_information4             => p_run_information4
    ,p_run_information5             => p_run_information5
    ,p_run_information6             => p_run_information6
    ,p_run_information7             => p_run_information7
    ,p_run_information8             => p_run_information8
    ,p_run_information9             => p_run_information9
    ,p_run_information10            => p_run_information10
    ,p_run_information11            => p_run_information11
    ,p_run_information12            => p_run_information12
    ,p_run_information13            => p_run_information13
    ,p_run_information14            => p_run_information14
    ,p_run_information15            => p_run_information15
    ,p_run_information16            => p_run_information16
    ,p_run_information17            => p_run_information17
    ,p_run_information18            => p_run_information18
    ,p_run_information19            => p_run_information19
    ,p_run_information20            => p_run_information20
    ,p_run_information21            => p_run_information21
    ,p_run_information22            => p_run_information22
    ,p_run_information23            => p_run_information23
    ,p_run_information24            => p_run_information24
    ,p_run_information25            => p_run_information25
    ,p_run_information26            => p_run_information26
    ,p_run_information27            => p_run_information27
    ,p_run_information28            => p_run_information28
    ,p_run_information29            => p_run_information29
    ,p_run_information30            => p_run_information30
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
    rollback to update_run_type_swi;
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
    rollback to update_run_type_swi;
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
end update_run_type;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_run_type >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_run_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_delete_mode        in     varchar2
  ,p_run_type_id                  in     number
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
  l_proc    varchar2(72) := g_package ||'delete_run_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_run_type_swi;
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
  pay_run_type_api.delete_run_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_delete_mode        => p_datetrack_delete_mode
    ,p_run_type_id                  => p_run_type_id
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
    rollback to delete_run_type_swi;
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
    rollback to delete_run_type_swi;
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
end delete_run_type;
end pay_run_type_swi;

/
