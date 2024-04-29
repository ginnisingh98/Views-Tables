--------------------------------------------------------
--  DDL for Package Body HR_PREVIOUS_EMPLOYMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PREVIOUS_EMPLOYMENT_SWI" As
/* $Header: hrpemswi.pkb 115.6 2003/11/17 23:42:05 jvembuna ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_previous_employment_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_previous_employer >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_previous_employer
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_party_id                     in     number
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_period_years                 in     number    default null
  ,p_period_months                in     number    default null
  ,p_period_days                  in     number    default null
  ,p_employer_name                in     varchar2  default null
  ,p_employer_country             in     varchar2  default null
  ,p_employer_address             in     varchar2  default null
  ,p_employer_type                in     varchar2  default null
  ,p_employer_subtype             in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_all_assignments              in     varchar2  default null
  ,p_pem_attribute_category       in     varchar2  default null
  ,p_pem_attribute1               in     varchar2  default null
  ,p_pem_attribute2               in     varchar2  default null
  ,p_pem_attribute3               in     varchar2  default null
  ,p_pem_attribute4               in     varchar2  default null
  ,p_pem_attribute5               in     varchar2  default null
  ,p_pem_attribute6               in     varchar2  default null
  ,p_pem_attribute7               in     varchar2  default null
  ,p_pem_attribute8               in     varchar2  default null
  ,p_pem_attribute9               in     varchar2  default null
  ,p_pem_attribute10              in     varchar2  default null
  ,p_pem_attribute11              in     varchar2  default null
  ,p_pem_attribute12              in     varchar2  default null
  ,p_pem_attribute13              in     varchar2  default null
  ,p_pem_attribute14              in     varchar2  default null
  ,p_pem_attribute15              in     varchar2  default null
  ,p_pem_attribute16              in     varchar2  default null
  ,p_pem_attribute17              in     varchar2  default null
  ,p_pem_attribute18              in     varchar2  default null
  ,p_pem_attribute19              in     varchar2  default null
  ,p_pem_attribute20              in     varchar2  default null
  ,p_pem_attribute21              in     varchar2  default null
  ,p_pem_attribute22              in     varchar2  default null
  ,p_pem_attribute23              in     varchar2  default null
  ,p_pem_attribute24              in     varchar2  default null
  ,p_pem_attribute25              in     varchar2  default null
  ,p_pem_attribute26              in     varchar2  default null
  ,p_pem_attribute27              in     varchar2  default null
  ,p_pem_attribute28              in     varchar2  default null
  ,p_pem_attribute29              in     varchar2  default null
  ,p_pem_attribute30              in     varchar2  default null
  ,p_pem_information_category     in     varchar2  default null
  ,p_pem_information1             in     varchar2  default null
  ,p_pem_information2             in     varchar2  default null
  ,p_pem_information3             in     varchar2  default null
  ,p_pem_information4             in     varchar2  default null
  ,p_pem_information5             in     varchar2  default null
  ,p_pem_information6             in     varchar2  default null
  ,p_pem_information7             in     varchar2  default null
  ,p_pem_information8             in     varchar2  default null
  ,p_pem_information9             in     varchar2  default null
  ,p_pem_information10            in     varchar2  default null
  ,p_pem_information11            in     varchar2  default null
  ,p_pem_information12            in     varchar2  default null
  ,p_pem_information13            in     varchar2  default null
  ,p_pem_information14            in     varchar2  default null
  ,p_pem_information15            in     varchar2  default null
  ,p_pem_information16            in     varchar2  default null
  ,p_pem_information17            in     varchar2  default null
  ,p_pem_information18            in     varchar2  default null
  ,p_pem_information19            in     varchar2  default null
  ,p_pem_information20            in     varchar2  default null
  ,p_pem_information21            in     varchar2  default null
  ,p_pem_information22            in     varchar2  default null
  ,p_pem_information23            in     varchar2  default null
  ,p_pem_information24            in     varchar2  default null
  ,p_pem_information25            in     varchar2  default null
  ,p_pem_information26            in     varchar2  default null
  ,p_pem_information27            in     varchar2  default null
  ,p_pem_information28            in     varchar2  default null
  ,p_pem_information29            in     varchar2  default null
  ,p_pem_information30            in     varchar2  default null
  ,p_previous_employer_id         in     number
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
  l_previous_employer_id         number;
  l_proc    varchar2(72) := g_package ||'create_previous_employer';
  l_party_id   per_all_people_f.party_id%type := p_party_id;
  --
  cursor csr_get_party_id is
  select party_id
  from    per_all_people_f per
    where   per.person_id = p_person_id
    and     trunc(p_effective_date)
    between per.effective_start_date
    and     per.effective_end_date;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_previous_employer_swi;
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
  per_pem_ins.set_base_key_value
    (p_previous_employer_id => p_previous_employer_id
    );
  --
  -- Workaround to set the party id if it is not passed in
  -- till the bug 3261173 is fixed
  --
  if (l_party_id is null) then
    open csr_get_party_id;
    fetch csr_get_party_id into l_party_id;
    close csr_get_party_id;
  end if;
  --
  -- Call API
  --
  hr_previous_employment_api.create_previous_employer
    (p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_party_id                     => l_party_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_period_years                 => p_period_years
    ,p_period_months                => p_period_months
    ,p_period_days                  => p_period_days
    ,p_employer_name                => p_employer_name
    ,p_employer_country             => p_employer_country
    ,p_employer_address             => p_employer_address
    ,p_employer_type                => p_employer_type
    ,p_employer_subtype             => p_employer_subtype
    ,p_description                  => p_description
    ,p_all_assignments              => p_all_assignments
    ,p_pem_attribute_category       => p_pem_attribute_category
    ,p_pem_attribute1               => p_pem_attribute1
    ,p_pem_attribute2               => p_pem_attribute2
    ,p_pem_attribute3               => p_pem_attribute3
    ,p_pem_attribute4               => p_pem_attribute4
    ,p_pem_attribute5               => p_pem_attribute5
    ,p_pem_attribute6               => p_pem_attribute6
    ,p_pem_attribute7               => p_pem_attribute7
    ,p_pem_attribute8               => p_pem_attribute8
    ,p_pem_attribute9               => p_pem_attribute9
    ,p_pem_attribute10              => p_pem_attribute10
    ,p_pem_attribute11              => p_pem_attribute11
    ,p_pem_attribute12              => p_pem_attribute12
    ,p_pem_attribute13              => p_pem_attribute13
    ,p_pem_attribute14              => p_pem_attribute14
    ,p_pem_attribute15              => p_pem_attribute15
    ,p_pem_attribute16              => p_pem_attribute16
    ,p_pem_attribute17              => p_pem_attribute17
    ,p_pem_attribute18              => p_pem_attribute18
    ,p_pem_attribute19              => p_pem_attribute19
    ,p_pem_attribute20              => p_pem_attribute20
    ,p_pem_attribute21              => p_pem_attribute21
    ,p_pem_attribute22              => p_pem_attribute22
    ,p_pem_attribute23              => p_pem_attribute23
    ,p_pem_attribute24              => p_pem_attribute24
    ,p_pem_attribute25              => p_pem_attribute25
    ,p_pem_attribute26              => p_pem_attribute26
    ,p_pem_attribute27              => p_pem_attribute27
    ,p_pem_attribute28              => p_pem_attribute28
    ,p_pem_attribute29              => p_pem_attribute29
    ,p_pem_attribute30              => p_pem_attribute30
    ,p_pem_information_category     => p_pem_information_category
    ,p_pem_information1             => p_pem_information1
    ,p_pem_information2             => p_pem_information2
    ,p_pem_information3             => p_pem_information3
    ,p_pem_information4             => p_pem_information4
    ,p_pem_information5             => p_pem_information5
    ,p_pem_information6             => p_pem_information6
    ,p_pem_information7             => p_pem_information7
    ,p_pem_information8             => p_pem_information8
    ,p_pem_information9             => p_pem_information9
    ,p_pem_information10            => p_pem_information10
    ,p_pem_information11            => p_pem_information11
    ,p_pem_information12            => p_pem_information12
    ,p_pem_information13            => p_pem_information13
    ,p_pem_information14            => p_pem_information14
    ,p_pem_information15            => p_pem_information15
    ,p_pem_information16            => p_pem_information16
    ,p_pem_information17            => p_pem_information17
    ,p_pem_information18            => p_pem_information18
    ,p_pem_information19            => p_pem_information19
    ,p_pem_information20            => p_pem_information20
    ,p_pem_information21            => p_pem_information21
    ,p_pem_information22            => p_pem_information22
    ,p_pem_information23            => p_pem_information23
    ,p_pem_information24            => p_pem_information24
    ,p_pem_information25            => p_pem_information25
    ,p_pem_information26            => p_pem_information26
    ,p_pem_information27            => p_pem_information27
    ,p_pem_information28            => p_pem_information28
    ,p_pem_information29            => p_pem_information29
    ,p_pem_information30            => p_pem_information30
    ,p_previous_employer_id         => l_previous_employer_id
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
    rollback to create_previous_employer_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to create_previous_employer_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_previous_employer;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_previous_employer >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_previous_employer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_previous_employer_id         in     number
  ,p_object_version_number        in out nocopy number
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
  l_proc    varchar2(72) := g_package ||'delete_previous_employer';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_previous_employer_swi;
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
  hr_previous_employment_api.delete_previous_employer
    (p_validate                     => l_validate
    ,p_previous_employer_id         => p_previous_employer_id
    ,p_object_version_number        => l_object_version_number
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
    rollback to delete_previous_employer_swi;
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
    rollback to delete_previous_employer_swi;
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
end delete_previous_employer;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_previous_employer >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_previous_employer
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_previous_employer_id         in     number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_employer_name                in     varchar2  default hr_api.g_varchar2
  ,p_employer_country             in     varchar2  default hr_api.g_varchar2
  ,p_employer_address             in     varchar2  default hr_api.g_varchar2
  ,p_employer_type                in     varchar2  default hr_api.g_varchar2
  ,p_employer_subtype             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_all_assignments              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_pem_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pem_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information30            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
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
  l_proc    varchar2(72) := g_package ||'update_previous_employer';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_previous_employer_swi;
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
  hr_previous_employment_api.update_previous_employer
    (p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_previous_employer_id         => p_previous_employer_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_period_years                 => p_period_years
    ,p_period_months                => p_period_months
    ,p_period_days                  => p_period_days
    ,p_employer_name                => p_employer_name
    ,p_employer_country             => p_employer_country
    ,p_employer_address             => p_employer_address
    ,p_employer_type                => p_employer_type
    ,p_employer_subtype             => p_employer_subtype
    ,p_description                  => p_description
    ,p_all_assignments              => p_all_assignments
    ,p_pem_attribute_category       => p_pem_attribute_category
    ,p_pem_attribute1               => p_pem_attribute1
    ,p_pem_attribute2               => p_pem_attribute2
    ,p_pem_attribute3               => p_pem_attribute3
    ,p_pem_attribute4               => p_pem_attribute4
    ,p_pem_attribute5               => p_pem_attribute5
    ,p_pem_attribute6               => p_pem_attribute6
    ,p_pem_attribute7               => p_pem_attribute7
    ,p_pem_attribute8               => p_pem_attribute8
    ,p_pem_attribute9               => p_pem_attribute9
    ,p_pem_attribute10              => p_pem_attribute10
    ,p_pem_attribute11              => p_pem_attribute11
    ,p_pem_attribute12              => p_pem_attribute12
    ,p_pem_attribute13              => p_pem_attribute13
    ,p_pem_attribute14              => p_pem_attribute14
    ,p_pem_attribute15              => p_pem_attribute15
    ,p_pem_attribute16              => p_pem_attribute16
    ,p_pem_attribute17              => p_pem_attribute17
    ,p_pem_attribute18              => p_pem_attribute18
    ,p_pem_attribute19              => p_pem_attribute19
    ,p_pem_attribute20              => p_pem_attribute20
    ,p_pem_attribute21              => p_pem_attribute21
    ,p_pem_attribute22              => p_pem_attribute22
    ,p_pem_attribute23              => p_pem_attribute23
    ,p_pem_attribute24              => p_pem_attribute24
    ,p_pem_attribute25              => p_pem_attribute25
    ,p_pem_attribute26              => p_pem_attribute26
    ,p_pem_attribute27              => p_pem_attribute27
    ,p_pem_attribute28              => p_pem_attribute28
    ,p_pem_attribute29              => p_pem_attribute29
    ,p_pem_attribute30              => p_pem_attribute30
    ,p_pem_information_category     => p_pem_information_category
    ,p_pem_information1             => p_pem_information1
    ,p_pem_information2             => p_pem_information2
    ,p_pem_information3             => p_pem_information3
    ,p_pem_information4             => p_pem_information4
    ,p_pem_information5             => p_pem_information5
    ,p_pem_information6             => p_pem_information6
    ,p_pem_information7             => p_pem_information7
    ,p_pem_information8             => p_pem_information8
    ,p_pem_information9             => p_pem_information9
    ,p_pem_information10            => p_pem_information10
    ,p_pem_information11            => p_pem_information11
    ,p_pem_information12            => p_pem_information12
    ,p_pem_information13            => p_pem_information13
    ,p_pem_information14            => p_pem_information14
    ,p_pem_information15            => p_pem_information15
    ,p_pem_information16            => p_pem_information16
    ,p_pem_information17            => p_pem_information17
    ,p_pem_information18            => p_pem_information18
    ,p_pem_information19            => p_pem_information19
    ,p_pem_information20            => p_pem_information20
    ,p_pem_information21            => p_pem_information21
    ,p_pem_information22            => p_pem_information22
    ,p_pem_information23            => p_pem_information23
    ,p_pem_information24            => p_pem_information24
    ,p_pem_information25            => p_pem_information25
    ,p_pem_information26            => p_pem_information26
    ,p_pem_information27            => p_pem_information27
    ,p_pem_information28            => p_pem_information28
    ,p_pem_information29            => p_pem_information29
    ,p_pem_information30            => p_pem_information30
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
    rollback to update_previous_employer_swi;
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
    rollback to update_previous_employer_swi;
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
end update_previous_employer;
-- ----------------------------------------------------------------------------
-- |--------------------------< create_previous_job >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_previous_job
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_previous_employer_id         in     number
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_period_years                 in     number    default null
  ,p_period_months                in     number    default null
  ,p_period_days                  in     number    default null
  ,p_job_name                     in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_all_assignments              in     varchar2  default null
  ,p_pjo_attribute_category       in     varchar2  default null
  ,p_pjo_attribute1               in     varchar2  default null
  ,p_pjo_attribute2               in     varchar2  default null
  ,p_pjo_attribute3               in     varchar2  default null
  ,p_pjo_attribute4               in     varchar2  default null
  ,p_pjo_attribute5               in     varchar2  default null
  ,p_pjo_attribute6               in     varchar2  default null
  ,p_pjo_attribute7               in     varchar2  default null
  ,p_pjo_attribute8               in     varchar2  default null
  ,p_pjo_attribute9               in     varchar2  default null
  ,p_pjo_attribute10              in     varchar2  default null
  ,p_pjo_attribute11              in     varchar2  default null
  ,p_pjo_attribute12              in     varchar2  default null
  ,p_pjo_attribute13              in     varchar2  default null
  ,p_pjo_attribute14              in     varchar2  default null
  ,p_pjo_attribute15              in     varchar2  default null
  ,p_pjo_attribute16              in     varchar2  default null
  ,p_pjo_attribute17              in     varchar2  default null
  ,p_pjo_attribute18              in     varchar2  default null
  ,p_pjo_attribute19              in     varchar2  default null
  ,p_pjo_attribute20              in     varchar2  default null
  ,p_pjo_attribute21              in     varchar2  default null
  ,p_pjo_attribute22              in     varchar2  default null
  ,p_pjo_attribute23              in     varchar2  default null
  ,p_pjo_attribute24              in     varchar2  default null
  ,p_pjo_attribute25              in     varchar2  default null
  ,p_pjo_attribute26              in     varchar2  default null
  ,p_pjo_attribute27              in     varchar2  default null
  ,p_pjo_attribute28              in     varchar2  default null
  ,p_pjo_attribute29              in     varchar2  default null
  ,p_pjo_attribute30              in     varchar2  default null
  ,p_pjo_information_category     in     varchar2  default null
  ,p_pjo_information1             in     varchar2  default null
  ,p_pjo_information2             in     varchar2  default null
  ,p_pjo_information3             in     varchar2  default null
  ,p_pjo_information4             in     varchar2  default null
  ,p_pjo_information5             in     varchar2  default null
  ,p_pjo_information6             in     varchar2  default null
  ,p_pjo_information7             in     varchar2  default null
  ,p_pjo_information8             in     varchar2  default null
  ,p_pjo_information9             in     varchar2  default null
  ,p_pjo_information10            in     varchar2  default null
  ,p_pjo_information11            in     varchar2  default null
  ,p_pjo_information12            in     varchar2  default null
  ,p_pjo_information13            in     varchar2  default null
  ,p_pjo_information14            in     varchar2  default null
  ,p_pjo_information15            in     varchar2  default null
  ,p_pjo_information16            in     varchar2  default null
  ,p_pjo_information17            in     varchar2  default null
  ,p_pjo_information18            in     varchar2  default null
  ,p_pjo_information19            in     varchar2  default null
  ,p_pjo_information20            in     varchar2  default null
  ,p_pjo_information21            in     varchar2  default null
  ,p_pjo_information22            in     varchar2  default null
  ,p_pjo_information23            in     varchar2  default null
  ,p_pjo_information24            in     varchar2  default null
  ,p_pjo_information25            in     varchar2  default null
  ,p_pjo_information26            in     varchar2  default null
  ,p_pjo_information27            in     varchar2  default null
  ,p_pjo_information28            in     varchar2  default null
  ,p_pjo_information29            in     varchar2  default null
  ,p_pjo_information30            in     varchar2  default null
  ,p_previous_job_id              in     number
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
  l_previous_job_id              number;
  l_proc    varchar2(72) := g_package ||'create_previous_job';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_previous_job_swi;
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
  per_pjo_ins.set_base_key_value
    (p_previous_job_id => p_previous_job_id
    );
  --
  -- Call API
  --
  hr_previous_employment_api.create_previous_job
    (p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_previous_employer_id         => p_previous_employer_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_period_years                 => p_period_years
    ,p_period_months                => p_period_months
    ,p_period_days                  => p_period_days
    ,p_job_name                     => p_job_name
    ,p_employment_category          => p_employment_category
    ,p_description                  => p_description
    ,p_all_assignments              => p_all_assignments
    ,p_pjo_attribute_category       => p_pjo_attribute_category
    ,p_pjo_attribute1               => p_pjo_attribute1
    ,p_pjo_attribute2               => p_pjo_attribute2
    ,p_pjo_attribute3               => p_pjo_attribute3
    ,p_pjo_attribute4               => p_pjo_attribute4
    ,p_pjo_attribute5               => p_pjo_attribute5
    ,p_pjo_attribute6               => p_pjo_attribute6
    ,p_pjo_attribute7               => p_pjo_attribute7
    ,p_pjo_attribute8               => p_pjo_attribute8
    ,p_pjo_attribute9               => p_pjo_attribute9
    ,p_pjo_attribute10              => p_pjo_attribute10
    ,p_pjo_attribute11              => p_pjo_attribute11
    ,p_pjo_attribute12              => p_pjo_attribute12
    ,p_pjo_attribute13              => p_pjo_attribute13
    ,p_pjo_attribute14              => p_pjo_attribute14
    ,p_pjo_attribute15              => p_pjo_attribute15
    ,p_pjo_attribute16              => p_pjo_attribute16
    ,p_pjo_attribute17              => p_pjo_attribute17
    ,p_pjo_attribute18              => p_pjo_attribute18
    ,p_pjo_attribute19              => p_pjo_attribute19
    ,p_pjo_attribute20              => p_pjo_attribute20
    ,p_pjo_attribute21              => p_pjo_attribute21
    ,p_pjo_attribute22              => p_pjo_attribute22
    ,p_pjo_attribute23              => p_pjo_attribute23
    ,p_pjo_attribute24              => p_pjo_attribute24
    ,p_pjo_attribute25              => p_pjo_attribute25
    ,p_pjo_attribute26              => p_pjo_attribute26
    ,p_pjo_attribute27              => p_pjo_attribute27
    ,p_pjo_attribute28              => p_pjo_attribute28
    ,p_pjo_attribute29              => p_pjo_attribute29
    ,p_pjo_attribute30              => p_pjo_attribute30
    ,p_pjo_information_category     => p_pjo_information_category
    ,p_pjo_information1             => p_pjo_information1
    ,p_pjo_information2             => p_pjo_information2
    ,p_pjo_information3             => p_pjo_information3
    ,p_pjo_information4             => p_pjo_information4
    ,p_pjo_information5             => p_pjo_information5
    ,p_pjo_information6             => p_pjo_information6
    ,p_pjo_information7             => p_pjo_information7
    ,p_pjo_information8             => p_pjo_information8
    ,p_pjo_information9             => p_pjo_information9
    ,p_pjo_information10            => p_pjo_information10
    ,p_pjo_information11            => p_pjo_information11
    ,p_pjo_information12            => p_pjo_information12
    ,p_pjo_information13            => p_pjo_information13
    ,p_pjo_information14            => p_pjo_information14
    ,p_pjo_information15            => p_pjo_information15
    ,p_pjo_information16            => p_pjo_information16
    ,p_pjo_information17            => p_pjo_information17
    ,p_pjo_information18            => p_pjo_information18
    ,p_pjo_information19            => p_pjo_information19
    ,p_pjo_information20            => p_pjo_information20
    ,p_pjo_information21            => p_pjo_information21
    ,p_pjo_information22            => p_pjo_information22
    ,p_pjo_information23            => p_pjo_information23
    ,p_pjo_information24            => p_pjo_information24
    ,p_pjo_information25            => p_pjo_information25
    ,p_pjo_information26            => p_pjo_information26
    ,p_pjo_information27            => p_pjo_information27
    ,p_pjo_information28            => p_pjo_information28
    ,p_pjo_information29            => p_pjo_information29
    ,p_pjo_information30            => p_pjo_information30
    ,p_previous_job_id              => l_previous_job_id
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
    rollback to create_previous_job_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to create_previous_job_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_previous_job;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_previous_job >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_previous_job
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_previous_job_id              in     number
  ,p_object_version_number        in out nocopy number
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
  l_proc    varchar2(72) := g_package ||'delete_previous_job';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_previous_job_swi;
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
  hr_previous_employment_api.delete_previous_job
    (p_validate                     => l_validate
    ,p_previous_job_id              => p_previous_job_id
    ,p_object_version_number        => l_object_version_number
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
    rollback to delete_previous_job_swi;
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
    rollback to delete_previous_job_swi;
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
end delete_previous_job;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_previous_job >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_previous_job
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_previous_job_id              in     number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_job_name                     in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_all_assignments              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information30            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
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
  l_proc    varchar2(72) := g_package ||'update_previous_job';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_previous_job_swi;
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
  hr_previous_employment_api.update_previous_job
    (p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_previous_job_id              => p_previous_job_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_period_years                 => p_period_years
    ,p_period_months                => p_period_months
    ,p_period_days                  => p_period_days
    ,p_job_name                     => p_job_name
    ,p_employment_category          => p_employment_category
    ,p_description                  => p_description
    ,p_all_assignments              => p_all_assignments
    ,p_pjo_attribute_category       => p_pjo_attribute_category
    ,p_pjo_attribute1               => p_pjo_attribute1
    ,p_pjo_attribute2               => p_pjo_attribute2
    ,p_pjo_attribute3               => p_pjo_attribute3
    ,p_pjo_attribute4               => p_pjo_attribute4
    ,p_pjo_attribute5               => p_pjo_attribute5
    ,p_pjo_attribute6               => p_pjo_attribute6
    ,p_pjo_attribute7               => p_pjo_attribute7
    ,p_pjo_attribute8               => p_pjo_attribute8
    ,p_pjo_attribute9               => p_pjo_attribute9
    ,p_pjo_attribute10              => p_pjo_attribute10
    ,p_pjo_attribute11              => p_pjo_attribute11
    ,p_pjo_attribute12              => p_pjo_attribute12
    ,p_pjo_attribute13              => p_pjo_attribute13
    ,p_pjo_attribute14              => p_pjo_attribute14
    ,p_pjo_attribute15              => p_pjo_attribute15
    ,p_pjo_attribute16              => p_pjo_attribute16
    ,p_pjo_attribute17              => p_pjo_attribute17
    ,p_pjo_attribute18              => p_pjo_attribute18
    ,p_pjo_attribute19              => p_pjo_attribute19
    ,p_pjo_attribute20              => p_pjo_attribute20
    ,p_pjo_attribute21              => p_pjo_attribute21
    ,p_pjo_attribute22              => p_pjo_attribute22
    ,p_pjo_attribute23              => p_pjo_attribute23
    ,p_pjo_attribute24              => p_pjo_attribute24
    ,p_pjo_attribute25              => p_pjo_attribute25
    ,p_pjo_attribute26              => p_pjo_attribute26
    ,p_pjo_attribute27              => p_pjo_attribute27
    ,p_pjo_attribute28              => p_pjo_attribute28
    ,p_pjo_attribute29              => p_pjo_attribute29
    ,p_pjo_attribute30              => p_pjo_attribute30
    ,p_pjo_information_category     => p_pjo_information_category
    ,p_pjo_information1             => p_pjo_information1
    ,p_pjo_information2             => p_pjo_information2
    ,p_pjo_information3             => p_pjo_information3
    ,p_pjo_information4             => p_pjo_information4
    ,p_pjo_information5             => p_pjo_information5
    ,p_pjo_information6             => p_pjo_information6
    ,p_pjo_information7             => p_pjo_information7
    ,p_pjo_information8             => p_pjo_information8
    ,p_pjo_information9             => p_pjo_information9
    ,p_pjo_information10            => p_pjo_information10
    ,p_pjo_information11            => p_pjo_information11
    ,p_pjo_information12            => p_pjo_information12
    ,p_pjo_information13            => p_pjo_information13
    ,p_pjo_information14            => p_pjo_information14
    ,p_pjo_information15            => p_pjo_information15
    ,p_pjo_information16            => p_pjo_information16
    ,p_pjo_information17            => p_pjo_information17
    ,p_pjo_information18            => p_pjo_information18
    ,p_pjo_information19            => p_pjo_information19
    ,p_pjo_information20            => p_pjo_information20
    ,p_pjo_information21            => p_pjo_information21
    ,p_pjo_information22            => p_pjo_information22
    ,p_pjo_information23            => p_pjo_information23
    ,p_pjo_information24            => p_pjo_information24
    ,p_pjo_information25            => p_pjo_information25
    ,p_pjo_information26            => p_pjo_information26
    ,p_pjo_information27            => p_pjo_information27
    ,p_pjo_information28            => p_pjo_information28
    ,p_pjo_information29            => p_pjo_information29
    ,p_pjo_information30            => p_pjo_information30
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
    rollback to update_previous_job_swi;
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
    rollback to update_previous_job_swi;
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
end update_previous_job;
end hr_previous_employment_swi;

/
