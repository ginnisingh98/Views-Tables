--------------------------------------------------------
--  DDL for Package Body HR_PERSON_ADDRESS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_ADDRESS_SWI" As
/* $Header: hraddswi.pkb 120.0 2005/05/30 22:33:49 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_person_address_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_address >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_person_address
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_pradd_ovlapval_override      in     number    default null
  ,p_validate_county              in     number    default null
  ,p_person_id                    in     number    default null
  ,p_primary_flag                 in     varchar2
  ,p_style                        in     varchar2
  ,p_date_from                    in     date
  ,p_date_to                      in     date      default null
  ,p_address_type                 in     varchar2  default null
  ,p_comments                     in     long      default null
  ,p_address_line1                in     varchar2  default null
  ,p_address_line2                in     varchar2  default null
  ,p_address_line3                in     varchar2  default null
  ,p_town_or_city                 in     varchar2  default null
  ,p_region_1                     in     varchar2  default null
  ,p_region_2                     in     varchar2  default null
  ,p_region_3                     in     varchar2  default null
  ,p_postal_code                  in     varchar2  default null
  ,p_country                      in     varchar2  default null
  ,p_telephone_number_1           in     varchar2  default null
  ,p_telephone_number_2           in     varchar2  default null
  ,p_telephone_number_3           in     varchar2  default null
  ,p_addr_attribute_category      in     varchar2  default null
  ,p_addr_attribute1              in     varchar2  default null
  ,p_addr_attribute2              in     varchar2  default null
  ,p_addr_attribute3              in     varchar2  default null
  ,p_addr_attribute4              in     varchar2  default null
  ,p_addr_attribute5              in     varchar2  default null
  ,p_addr_attribute6              in     varchar2  default null
  ,p_addr_attribute7              in     varchar2  default null
  ,p_addr_attribute8              in     varchar2  default null
  ,p_addr_attribute9              in     varchar2  default null
  ,p_addr_attribute10             in     varchar2  default null
  ,p_addr_attribute11             in     varchar2  default null
  ,p_addr_attribute12             in     varchar2  default null
  ,p_addr_attribute13             in     varchar2  default null
  ,p_addr_attribute14             in     varchar2  default null
  ,p_addr_attribute15             in     varchar2  default null
  ,p_addr_attribute16             in     varchar2  default null
  ,p_addr_attribute17             in     varchar2  default null
  ,p_addr_attribute18             in     varchar2  default null
  ,p_addr_attribute19             in     varchar2  default null
  ,p_addr_attribute20             in     varchar2  default null
  ,p_add_information13            in     varchar2  default null
  ,p_add_information14            in     varchar2  default null
  ,p_add_information15            in     varchar2  default null
  ,p_add_information16            in     varchar2  default null
  ,p_add_information17            in     varchar2  default null
  ,p_add_information18            in     varchar2  default null
  ,p_add_information19            in     varchar2  default null
  ,p_add_information20            in     varchar2  default null
  ,p_party_id                     in     number    default null
  ,p_address_id                   in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_pradd_ovlapval_override       boolean;
  l_validate_county               boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_address_id                   number;
  l_proc    varchar2(72) := g_package ||'create_person_address';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_person_address_swi;
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
  l_pradd_ovlapval_override :=
    hr_api.constant_to_boolean
      (p_constant_value => p_pradd_ovlapval_override);
  l_validate_county :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate_county);
  --
  -- Register Surrogate ID or user key values
  --
  per_add_ins.set_base_key_value
    (p_address_id => p_address_id
    );
  --
  -- Call API
  --
  hr_person_address_api.create_person_address
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_pradd_ovlapval_override      => l_pradd_ovlapval_override
    ,p_validate_county              => l_validate_county
    ,p_person_id                    => p_person_id
    ,p_primary_flag                 => p_primary_flag
    ,p_style                        => p_style
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_address_line1                => p_address_line1
    ,p_address_line2                => p_address_line2
    ,p_address_line3                => p_address_line3
    ,p_town_or_city                 => p_town_or_city
    ,p_region_1                     => p_region_1
    ,p_region_2                     => p_region_2
    ,p_region_3                     => p_region_3
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
    ,p_addr_attribute_category      => p_addr_attribute_category
    ,p_addr_attribute1              => p_addr_attribute1
    ,p_addr_attribute2              => p_addr_attribute2
    ,p_addr_attribute3              => p_addr_attribute3
    ,p_addr_attribute4              => p_addr_attribute4
    ,p_addr_attribute5              => p_addr_attribute5
    ,p_addr_attribute6              => p_addr_attribute6
    ,p_addr_attribute7              => p_addr_attribute7
    ,p_addr_attribute8              => p_addr_attribute8
    ,p_addr_attribute9              => p_addr_attribute9
    ,p_addr_attribute10             => p_addr_attribute10
    ,p_addr_attribute11             => p_addr_attribute11
    ,p_addr_attribute12             => p_addr_attribute12
    ,p_addr_attribute13             => p_addr_attribute13
    ,p_addr_attribute14             => p_addr_attribute14
    ,p_addr_attribute15             => p_addr_attribute15
    ,p_addr_attribute16             => p_addr_attribute16
    ,p_addr_attribute17             => p_addr_attribute17
    ,p_addr_attribute18             => p_addr_attribute18
    ,p_addr_attribute19             => p_addr_attribute19
    ,p_addr_attribute20             => p_addr_attribute20
    ,p_add_information13            => p_add_information13
    ,p_add_information14            => p_add_information14
    ,p_add_information15            => p_add_information15
    ,p_add_information16            => p_add_information16
    ,p_add_information17            => p_add_information17
    ,p_add_information18            => p_add_information18
    ,p_add_information19            => p_add_information19
    ,p_add_information20            => p_add_information20
    ,p_party_id                     => p_party_id
    ,p_address_id                   => l_address_id
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
    --  at least one error message exists in the list.
    --
    rollback to create_person_address_swi;
    --
    -- Reset IN OUT paramters and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise
    -- the error.
    --
    rollback to create_person_address_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc, 40);
       raise;
    end if;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving: ' || l_proc, 50);
end create_person_address;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_person_address >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_person_address
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_validate_county              in     number    default hr_api.g_true_num
  ,p_address_id                   in     number
  ,p_object_version_number        in out nocopy number
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_address_type                 in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     long      default hr_api.g_varchar2
  ,p_address_line1                in     varchar2  default hr_api.g_varchar2
  ,p_address_line2                in     varchar2  default hr_api.g_varchar2
  ,p_address_line3                in     varchar2  default hr_api.g_varchar2
  ,p_town_or_city                 in     varchar2  default hr_api.g_varchar2
  ,p_region_1                     in     varchar2  default hr_api.g_varchar2
  ,p_region_2                     in     varchar2  default hr_api.g_varchar2
  ,p_region_3                     in     varchar2  default hr_api.g_varchar2
  ,p_postal_code                  in     varchar2  default hr_api.g_varchar2
  ,p_country                      in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_1           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_2           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_3           in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute20             in     varchar2  default hr_api.g_varchar2
  ,p_add_information13            in     varchar2  default hr_api.g_varchar2
  ,p_add_information14            in     varchar2  default hr_api.g_varchar2
  ,p_add_information15            in     varchar2  default hr_api.g_varchar2
  ,p_add_information16            in     varchar2  default hr_api.g_varchar2
  ,p_add_information17            in     varchar2  default hr_api.g_varchar2
  ,p_add_information18            in     varchar2  default hr_api.g_varchar2
  ,p_add_information19            in     varchar2  default hr_api.g_varchar2
  ,p_add_information20            in     varchar2  default hr_api.g_varchar2
  ,p_party_id                     in     number    default hr_api.g_number
  ,p_style                        in     varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_validate_county               boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_person_address';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_person_address_swi;
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
  l_validate_county :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate_county);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
    hr_person_address_api.update_pers_addr_with_style
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_validate_county              => l_validate_county
    ,p_address_id                   => p_address_id
    ,p_object_version_number        => p_object_version_number
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_address_line1                => p_address_line1
    ,p_address_line2                => p_address_line2
    ,p_address_line3                => p_address_line3
    ,p_town_or_city                 => p_town_or_city
    ,p_region_1                     => p_region_1
    ,p_region_2                     => p_region_2
    ,p_region_3                     => p_region_3
    ,p_postal_code                  => p_postal_code
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
    ,p_addr_attribute_category      => p_addr_attribute_category
    ,p_addr_attribute1              => p_addr_attribute1
    ,p_addr_attribute2              => p_addr_attribute2
    ,p_addr_attribute3              => p_addr_attribute3
    ,p_addr_attribute4              => p_addr_attribute4
    ,p_addr_attribute5              => p_addr_attribute5
    ,p_addr_attribute6              => p_addr_attribute6
    ,p_addr_attribute7              => p_addr_attribute7
    ,p_addr_attribute8              => p_addr_attribute8
    ,p_addr_attribute9              => p_addr_attribute9
    ,p_addr_attribute10             => p_addr_attribute10
    ,p_addr_attribute11             => p_addr_attribute11
    ,p_addr_attribute12             => p_addr_attribute12
    ,p_addr_attribute13             => p_addr_attribute13
    ,p_addr_attribute14             => p_addr_attribute14
    ,p_addr_attribute15             => p_addr_attribute15
    ,p_addr_attribute16             => p_addr_attribute16
    ,p_addr_attribute17             => p_addr_attribute17
    ,p_addr_attribute18             => p_addr_attribute18
    ,p_addr_attribute19             => p_addr_attribute19
    ,p_addr_attribute20             => p_addr_attribute20
    ,p_add_information13            => p_add_information13
    ,p_add_information14            => p_add_information14
    ,p_add_information15            => p_add_information15
    ,p_add_information16            => p_add_information16
    ,p_add_information17            => p_add_information17
    ,p_add_information18            => p_add_information18
    ,p_add_information19            => p_add_information19
    ,p_add_information20            => p_add_information20
    ,p_party_id                     => p_party_id
    ,p_style                        => p_style
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
    --  at least one error message exists in the list.
    --
    rollback to update_person_address_swi;
    --
    -- Reset IN OUT paramters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise
    -- the error.
    --
    rollback to update_person_address_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc, 40);
       raise;
    end if;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving: ' || l_proc, 50);
end update_person_address;
end hr_person_address_swi;

/
