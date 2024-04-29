--------------------------------------------------------
--  DDL for Package Body XLE_LEGAL_ADDRESS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_LEGAL_ADDRESS_SWI" AS
/* $Header: xleaddrb.pls 120.5.12010000.5 2010/01/19 10:29:23 srampure ship $ */

g_package CONSTANT  VARCHAR2(33) := 'xle_legal_address_swi.';

PROCEDURE create_legal_address
  (p_validate                     in     number
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2
  ,p_location_code                in     varchar2
  ,p_description                  in     varchar2  default null
  ,p_address_line_1               in     varchar2  default null
  ,p_address_line_2               in     varchar2  default null
  ,p_address_line_3               in     varchar2  default null
  ,p_country                      in     varchar2  default null
  ,p_inactive_date                in     date      default null
  ,p_postal_code                  in     varchar2   default null
  ,p_region_1                     in     varchar2  default null
  ,p_region_2                     in     varchar2  default null
  ,p_region_3                     in     varchar2  default null
  ,p_style                        in     varchar2  default null
  ,p_town_or_city                 in     varchar2  default NULL
  -- Added for ER: 6116752
  ,p_telephone_number_1           in     varchar2  default null
  ,p_telephone_number_2           in     varchar2  default null
  ,p_telephone_number_3           in     varchar2  default null
  ,p_loc_information13            in     varchar2  default null
  ,p_loc_information14            in     varchar2  default null
  ,p_loc_information15            in     varchar2  default null
  ,p_loc_information16            in     varchar2  default null
  ,p_loc_information17            in     varchar2  default null
  ,p_loc_information18            in     varchar2  default null
  ,p_loc_information19            in     varchar2  default null
  ,p_loc_information20            in     varchar2  default null
  --ER: 6116752 END
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
  ,p_business_group_id            in     number    default null
  ,p_location_id                  OUT NOCOPY number
  ,p_object_version_number        OUT NOCOPY number
  ) is

  -- Variables for API Boolean parameters
  l_validate                      boolean;

  -- Variables for IN/OUT parameters

  l_location_id                     number;
  l_object_version_number           number;
  p_return_status                   varchar(1);
  VALIDATE_ADDRESS_FAIL    EXCEPTION;
  l_proc  CONSTANT  VARCHAR2(72) := g_package ||'create_legal_address';
Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint xle_legal_address_swi;
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
--  hr_loc_ins.set_base_key_value
--    (p_phone_id => p_phone_id
--    );


--  hr_lot_ins.set_base_key_value
--    (p_phone_id => p_phone_id
--    );

  --
  -- Call API
  --
  hr_location_api.create_location_legal_adr
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_language_code                => p_language_code
    ,p_location_code                => p_location_code
    ,p_description                  => p_description
    ,p_address_line_1               => p_address_line_1
    ,p_address_line_2               => p_address_line_2
    ,p_address_line_3               => p_address_line_3
    ,p_country                      => p_country
    ,p_inactive_date                => p_inactive_date
    ,p_postal_code                  => p_postal_code
    ,p_region_1                     => p_region_1
    ,p_region_2                     => p_region_2
    ,p_region_3                     => p_region_3
    ,p_style                        => p_style
    ,p_town_or_city                 => p_town_or_city
	-- Added for ER: 6116752
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
    ,p_loc_information13            => p_loc_information13
    ,p_loc_information14            => p_loc_information14
    ,p_loc_information15            => p_loc_information15
    ,p_loc_information16            => p_loc_information16
    ,p_loc_information17            => p_loc_information17
    ,p_loc_information18            => p_loc_information18
    ,p_loc_information19            => p_loc_information19
    ,p_loc_information20            => p_loc_information20
	-- ER: 6116752 END
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
    ,p_location_id                  => l_location_id
    ,p_object_version_number        => l_object_version_number
--    ,p_duplicate_warning            => l_duplicate_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
--  if l_duplicate_warning then
--    fnd_message.set_name('EDIT_HERE: APP_CODE', 'EDIT_HERE: MESSAGE_NAME');
--    hr_multi_message.add
--      (p_message_type => hr_multi_message.g_warning_msg
--      );
--  end if;
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_location_id := l_location_id;
  p_object_version_number := l_object_version_number;
  p_return_status := hr_multi_message.get_return_status_disable;


  hr_utility.set_location(' Leaving:' || l_proc,20);
  -- Bug: 8434653
  IF( p_return_status = 'E') then
    raise VALIDATE_ADDRESS_FAIL;
  END IF;
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to xle_legal_address_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_location_id        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when VALIDATE_ADDRESS_FAIL then

    rollback to xle_legal_address_swi;
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to xle_legal_address_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_location_id                  := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_legal_address;

PROCEDURE update_legal_address
  (p_validate                     in     number
  ,p_effective_date               in     date
  ,p_location_id                  in     number
  ,p_description                  in     varchar2
  ,p_address_line_1               in     varchar2
  ,p_address_line_2               in     varchar2
  ,p_address_line_3               in     varchar2
  ,p_inactive_date                in     date
  ,p_postal_code                  in     varchar2
  ,p_region_1                     in     varchar2
  ,p_region_2                     in     varchar2
  ,p_region_3                     in     varchar2
  ,p_style                        in     varchar2
  ,p_town_or_city                 in     varchar2
  -- Added for ER: 6116752
  ,p_telephone_number_1           in     varchar2
  ,p_telephone_number_2           in     varchar2
  ,p_telephone_number_3           in     varchar2
  ,p_loc_information13            in     varchar2
  ,p_loc_information14            in     varchar2
  ,p_loc_information15            in     varchar2
  ,p_loc_information16            in     varchar2
  ,p_loc_information17            in     varchar2
  ,p_loc_information18            in     varchar2
  ,p_loc_information19            in     varchar2
  ,p_loc_information20            in     varchar2
  -- ER: 6116752 END
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_object_version_number        in out nocopy number
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --l_duplicate_warning             boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_object_version_number           number;
  p_return_status                   varchar(1);
  l_temp_ovn CONSTANT  number(9) := p_object_version_number;
  l_proc   CONSTANT varchar2(72) := g_package ||'create_legal_address';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint
  --
  savepoint xle_legal_address_swi;
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
--  hr_loc_ins.set_base_key_value
--    (p_phone_id => p_phone_id
--    );


--  hr_lot_ins.set_base_key_value
--    (p_phone_id => p_phone_id
--    );

  --
  -- Call API
  --
  hr_location_api.update_location_legal_adr
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_location_id                  => p_location_id
    ,p_description                  => p_description
    ,p_address_line_1               => p_address_line_1
    ,p_address_line_2               => p_address_line_2
    ,p_address_line_3               => p_address_line_3
--  For Bug # 6329263
--    ,p_inactive_date                => p_inactive_date
    ,p_postal_code                  => p_postal_code
    ,p_region_1                     => p_region_1
    ,p_region_2                     => p_region_2
    ,p_region_3                     => p_region_3
    ,p_style                        => p_style
    ,p_town_or_city                 => p_town_or_city
	-- Added for ER: 6116752
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
    ,p_loc_information13            => p_loc_information13
    ,p_loc_information14            => p_loc_information14
    ,p_loc_information15            => p_loc_information15
    ,p_loc_information16            => p_loc_information16
    ,p_loc_information17            => p_loc_information17
    ,p_loc_information18            => p_loc_information18
    ,p_loc_information19            => p_loc_information19
    ,p_loc_information20            => p_loc_information20
	-- ER: 6116752 END
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
    ,p_object_version_number        => l_object_version_number
--    ,p_duplicate_warning            => l_duplicate_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
--  if l_duplicate_warning then
--    fnd_message.set_name('EDIT_HERE: APP_CODE', 'EDIT_HERE: MESSAGE_NAME');
--    hr_multi_message.add
--      (p_message_type => hr_multi_message.g_warning_msg
--      );
--  end if;
  --

  -- Added for bug 8248634
  hr_multi_message.end_validation_set;

  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --

  p_object_version_number := l_object_version_number;
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
    rollback to xle_legal_address_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_temp_ovn;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
	--raise;
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to xle_legal_address_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_temp_ovn;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
	--raise;
end update_legal_address;


-- ER: 7445275
PROCEDURE enable_legal_address_flag
  (p_location_id                     in     number
  ) is
  -- variables
  l_object_version_number           number;
  l_legal_address_flag              hr_locations.legal_address_flag%TYPE;
  l_return_status                   varchar(1);
  l_temp_ovn number(9);
  l_proc   CONSTANT varchar2(72) := g_package ||'enable_legal_address_flag';
Begin

     select object_version_number, legal_address_flag
     into l_object_version_number, l_legal_address_flag
     from hr_locations
     where location_id = p_location_id;

     if(l_legal_address_flag is null) then
        l_legal_address_flag := 'N';
     end if;

    if( l_legal_address_flag <> 'Y') then

        Begin

        hr_utility.set_location(' Entering:' || l_proc,10);

         l_temp_ovn := l_object_version_number;
          --
          -- Issue a savepoint
          --
          savepoint xle_legal_address_swi;
          --
          -- Initialise Multiple Message Detection
          --
          hr_multi_message.enable_message_list;
          --
          -- Call API
          --

         hr_location_api.enable_location_legal_adr
          (   p_validate => false
             ,p_effective_date => sysdate
             ,p_location_id   => p_location_id
             ,p_object_version_number  =>l_object_version_number
          );

          -- Convert API non-warning boolean parameter values
          --
          --
          -- Derive the API return status value based on whether
          -- messages of any type exist in the Multiple Message List.
          -- Also disable Multiple Message Detection.
          --

          l_return_status := hr_multi_message.get_return_status_disable;

          hr_utility.set_location(' Leaving:' || l_proc,20);

        exception
          when hr_multi_message.error_message_exist then

            --
            -- Catch the Multiple Message List exception which
            -- indicates API processing has been aborted because
            -- at least one message exists in the list.
            --
            rollback to xle_legal_address_swi;
            --
            -- Reset IN OUT parameters and set OUT parameters
            --
            l_object_version_number        := l_temp_ovn;
            l_return_status := hr_multi_message.get_return_status_disable;
            hr_utility.set_location(' Leaving:' || l_proc, 30);
                --raise;
          when others then
            --
            -- When Multiple Message Detection is enabled catch
            -- any Application specific or other unexpected
            -- exceptions.  Adding appropriate details to the
            -- Multiple Message List.  Otherwise re-raise the
            -- error.
            --
            rollback to xle_legal_address_swi;
            if hr_multi_message.unexpected_error_add(l_proc) then
               hr_utility.set_location(' Leaving:' || l_proc,40);
               raise;
            end if;
            --
            -- Reset IN OUT and set OUT parameters
            --
            l_object_version_number        := l_temp_ovn;
            l_return_status := hr_multi_message.get_return_status_disable;
            hr_utility.set_location(' Leaving:' || l_proc,50);
                --raise;
           end;
    end if;
end enable_legal_address_flag;

   -- Enter further code below as specified in the Package spec.
END;

/
