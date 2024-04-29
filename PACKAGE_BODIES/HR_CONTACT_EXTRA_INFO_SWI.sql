--------------------------------------------------------
--  DDL for Package Body HR_CONTACT_EXTRA_INFO_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CONTACT_EXTRA_INFO_SWI" as
/* $Header: pereiswi.pkb 120.0.12000000.1 2007/02/08 10:26:13 ssutar noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_contact_extra_info_swi.';
--
----------------------------------------------------------------------------
procedure create_contact_extra_info(
    p_validate                    IN      NUMBER,
    p_contact_extra_info_id       IN      NUMBER,
    p_effective_date              IN      DATE,
    p_contact_relationship_id     IN      NUMBER,
    p_information_type            IN      VARCHAR2,
    p_cei_information_category    IN      VARCHAR2        DEFAULT NULL,
    p_cei_information1            IN      VARCHAR2        DEFAULT NULL,
    p_cei_information2            IN      VARCHAR2        DEFAULT NULL,
    p_cei_information3            IN      VARCHAR2        DEFAULT NULL,
    p_cei_information4            IN      VARCHAR2        DEFAULT NULL,
    p_cei_information5            IN      VARCHAR2        DEFAULT NULL,
    p_cei_information6            IN      VARCHAR2        DEFAULT NULL,
    p_cei_information7            IN      VARCHAR2        DEFAULT NULL,
    p_cei_information8            IN      VARCHAR2        DEFAULT NULL,
    p_cei_information9            IN      VARCHAR2        DEFAULT NULL,
    p_cei_information10           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information11           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information12           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information13           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information14           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information15           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information16           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information17           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information18           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information19           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information20           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information21           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information22           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information23           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information24           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information25           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information26           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information27           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information28           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information29           IN      VARCHAR2        DEFAULT NULL,
    p_cei_information30           IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute_category      IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute1              IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute2              IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute3              IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute4              IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute5              IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute6              IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute7              IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute8              IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute9              IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute10             IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute11             IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute12             IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute13             IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute14             IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute15             IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute16             IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute17             IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute18             IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute19             IN      VARCHAR2        DEFAULT NULL,
    p_cei_attribute20             IN      VARCHAR2        DEFAULT NULL,
    p_object_version_number       OUT     NOCOPY NUMBER,
    p_effective_start_date        OUT     NOCOPY DATE,
    p_effective_end_date          OUT     NOCOPY DATE,
    p_return_status               OUT     NOCOPY VARCHAR2
) as

    --
    -- Variables for API Boolean parameters
    l_validate                      boolean;
    --
    -- Variables for IN/OUT parameters
    --
    -- Other variables
    l_contact_extra_info_id        number;
    l_proc    varchar2(72) := g_package ||'insert';

begin

    hr_utility.set_location(' Entering:' || l_proc,10);
    --
    -- Issue a savepoint
    --
    savepoint create_contact_extra_info_swi;
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
    l_validate := hr_api.constant_to_boolean (p_constant_value => p_validate);
    --
    -- Register Surrogate ID or user key values
    --

    per_rei_ins.set_base_key_value (
        p_contact_extra_info_id => p_contact_extra_info_id
    );

    --
    -- Call API
    --

    hr_contact_extra_info_api.create_contact_extra_info(
        p_validate                     => l_validate,
        p_effective_date               => p_effective_date,
        p_contact_relationship_id      => p_contact_relationship_id,
        p_information_type             => p_information_type,
        p_cei_information_category     => p_cei_information_category,
        p_cei_information1             => p_cei_information1,
        p_cei_information2             => p_cei_information2,
        p_cei_information3             => p_cei_information3,
        p_cei_information4             => p_cei_information4,
        p_cei_information5             => p_cei_information5,
        p_cei_information6             => p_cei_information6,
        p_cei_information7             => p_cei_information7,
        p_cei_information8             => p_cei_information8,
        p_cei_information9             => p_cei_information9,
        p_cei_information10            => p_cei_information10,
        p_cei_information11            => p_cei_information11,
        p_cei_information12            => p_cei_information12,
        p_cei_information13            => p_cei_information13,
        p_cei_information14            => p_cei_information14,
        p_cei_information15            => p_cei_information15,
        p_cei_information16            => p_cei_information16,
        p_cei_information17            => p_cei_information17,
        p_cei_information18            => p_cei_information18,
        p_cei_information19            => p_cei_information19,
        p_cei_information20            => p_cei_information20,
        p_cei_information21            => p_cei_information21,
        p_cei_information22            => p_cei_information22,
        p_cei_information23            => p_cei_information23,
        p_cei_information24            => p_cei_information24,
        p_cei_information25            => p_cei_information25,
        p_cei_information26            => p_cei_information26,
        p_cei_information27            => p_cei_information27,
        p_cei_information28            => p_cei_information28,
        p_cei_information29            => p_cei_information29,
        p_cei_information30            => p_cei_information30,
        p_cei_attribute_category       => p_cei_attribute_category,
        p_cei_attribute1               => p_cei_attribute1,
        p_cei_attribute2               => p_cei_attribute2,
        p_cei_attribute3               => p_cei_attribute3,
        p_cei_attribute4               => p_cei_attribute4,
        p_cei_attribute5               => p_cei_attribute5,
        p_cei_attribute6               => p_cei_attribute6,
        p_cei_attribute7               => p_cei_attribute7,
        p_cei_attribute8               => p_cei_attribute8,
        p_cei_attribute9               => p_cei_attribute9,
        p_cei_attribute10              => p_cei_attribute10,
        p_cei_attribute11              => p_cei_attribute11,
        p_cei_attribute12              => p_cei_attribute12,
        p_cei_attribute13              => p_cei_attribute13,
        p_cei_attribute14              => p_cei_attribute14,
        p_cei_attribute15              => p_cei_attribute15,
        p_cei_attribute16              => p_cei_attribute16,
        p_cei_attribute17              => p_cei_attribute17,
        p_cei_attribute18              => p_cei_attribute18,
        p_cei_attribute19              => p_cei_attribute19,
        p_cei_attribute20              => p_cei_attribute20,
        p_contact_extra_info_id        => l_contact_extra_info_id,
        p_object_version_number        => p_object_version_number,
        p_effective_start_date         => p_effective_start_date,
        p_effective_end_date           => p_effective_end_date);

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
    If l_validate = TRUE Then
        rollback to create_contact_extra_info_swi;
    End If;
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
        rollback to create_contact_extra_info_swi;
        --
        -- Reset IN OUT parameters and set OUT parameters
        --
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
        rollback to create_contact_extra_info_swi;
        if hr_multi_message.unexpected_error_add(l_proc) then
           hr_utility.set_location(' Leaving:' || l_proc,40);
           raise;
        end if;
        --
        -- Reset IN OUT and set OUT parameters
        --
        p_object_version_number        := null;
        p_effective_start_date         := null;
        p_effective_end_date           := null;
        p_return_status := hr_multi_message.get_return_status_disable;
        hr_utility.set_location(' Leaving:' || l_proc,50);

end create_contact_extra_info;

----------------------------------------------------------------------------

procedure update_contact_extra_info(
    p_validate                    IN      NUMBER,
    p_effective_date              IN      DATE,
    p_datetrack_update_mode       IN      VARCHAR2,
    p_contact_extra_info_id       IN      NUMBER,
    p_contact_relationship_id     IN      NUMBER          DEFAULT hr_api.g_number,
    p_information_type            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_object_version_number       IN      OUT NOCOPY NUMBER,
    p_cei_information_category    IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information1            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information2            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information3            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information4            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information5            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information6            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information7            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information8            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information9            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information10           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information11           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information12           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information13           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information14           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information15           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information16           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information17           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information18           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information19           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information20           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information21           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information22           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information23           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information24           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information25           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information26           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information27           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information28           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information29           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_information30           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute_category      IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute1              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute2              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute3              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute4              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute5              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute6              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute7              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute8              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute9              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute10             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute11             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute12             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute13             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute14             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute15             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute16             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute17             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute18             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute19             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_cei_attribute20             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
    p_effective_start_date        OUT     NOCOPY DATE,
    p_effective_end_date          OUT     NOCOPY DATE,
    p_return_status               OUT     NOCOPY VARCHAR2)
is
    --
    -- Variables for API Boolean parameters
    l_validate                      boolean;
    --
    -- Variables for IN/OUT parameters
    l_object_version_number         number;

    l_proc    varchar2(72) := g_package ||' update_contact_extra_info';

begin
    hr_utility.set_location(' Entering:' || l_proc,10);
    --
    -- Issue a savepoint
    --
    savepoint update_contact_extra_info_swi;
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
    l_validate := hr_api.constant_to_boolean (p_constant_value => p_validate);
    --
    -- API call

    hr_contact_extra_info_api.update_contact_extra_info(
        p_validate                    => l_validate,
        p_effective_date              => p_effective_date,
        p_datetrack_update_mode       => p_datetrack_update_mode,
        p_contact_extra_info_id       => p_contact_extra_info_id,
        p_contact_relationship_id     => p_contact_relationship_id,
        p_information_type            => p_information_type,
        p_object_version_number       => p_object_version_number,
        p_cei_information_category    => p_cei_information_category,
        p_cei_information1            => p_cei_information1,
        p_cei_information2            => p_cei_information2,
        p_cei_information3            => p_cei_information3,
        p_cei_information4            => p_cei_information4,
        p_cei_information5            => p_cei_information5,
        p_cei_information6            => p_cei_information6,
        p_cei_information7            => p_cei_information7,
        p_cei_information8            => p_cei_information8,
        p_cei_information9            => p_cei_information9,
        p_cei_information10           => p_cei_information10,
        p_cei_information11           => p_cei_information11,
        p_cei_information12           => p_cei_information12,
        p_cei_information13           => p_cei_information13,
        p_cei_information14           => p_cei_information14,
        p_cei_information15           => p_cei_information15,
        p_cei_information16           => p_cei_information16,
        p_cei_information17           => p_cei_information17,
        p_cei_information18           => p_cei_information18,
        p_cei_information19           => p_cei_information19,
        p_cei_information20           => p_cei_information20,
        p_cei_information21           => p_cei_information21,
        p_cei_information22           => p_cei_information22,
        p_cei_information23           => p_cei_information23,
        p_cei_information24           => p_cei_information24,
        p_cei_information25           => p_cei_information25,
        p_cei_information26           => p_cei_information26,
        p_cei_information27           => p_cei_information27,
        p_cei_information28           => p_cei_information28,
        p_cei_information29           => p_cei_information29,
        p_cei_information30           => p_cei_information30,
        p_cei_attribute_category      => p_cei_attribute_category,
        p_cei_attribute1              => p_cei_attribute1,
        p_cei_attribute2              => p_cei_attribute2,
        p_cei_attribute3              => p_cei_attribute3,
        p_cei_attribute4              => p_cei_attribute4,
        p_cei_attribute5              => p_cei_attribute5,
        p_cei_attribute6              => p_cei_attribute6,
        p_cei_attribute7              => p_cei_attribute7,
        p_cei_attribute8              => p_cei_attribute8,
        p_cei_attribute9              => p_cei_attribute9,
        p_cei_attribute10             => p_cei_attribute10,
        p_cei_attribute11             => p_cei_attribute11,
        p_cei_attribute12             => p_cei_attribute12,
        p_cei_attribute13             => p_cei_attribute13,
        p_cei_attribute14             => p_cei_attribute14,
        p_cei_attribute15             => p_cei_attribute15,
        p_cei_attribute16             => p_cei_attribute16,
        p_cei_attribute17             => p_cei_attribute17,
        p_cei_attribute18             => p_cei_attribute18,
        p_cei_attribute19             => p_cei_attribute19,
        p_cei_attribute20             => p_cei_attribute20,
        p_effective_start_date        => p_effective_start_date,
        p_effective_end_date          => p_effective_end_date
    );

    If l_validate = TRUE Then
        rollback to update_contact_extra_info_swi;
    End If;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
    when hr_multi_message.error_message_exist then
        --
        rollback to update_contact_extra_info_swi;
        --
        --
        p_object_version_number        := l_object_version_number;
        p_effective_start_date         := null;
        p_effective_end_date           := null;

        p_return_status := hr_multi_message.get_return_status_disable;
        hr_utility.set_location(' Leaving:' || l_proc, 30);

    when others then
        --
        rollback to update_contact_extra_info_swi;

        if hr_multi_message.unexpected_error_add(l_proc) then
            hr_utility.set_location(' Leaving:' || l_proc,40);
            raise;
        end if;
        --
        p_object_version_number        := l_object_version_number;
        p_effective_start_date         := null;
        p_effective_end_date           := null;

        p_return_status := hr_multi_message.get_return_status_disable;
        hr_utility.set_location(' Leaving:' || l_proc,50);

end update_contact_extra_info;

----------------------------------------------------------------------------

procedure delete_contact_extra_info(
    p_validate                    in      number,
    p_effective_date              in      date,
    p_datetrack_delete_mode       in      varchar2,
    p_contact_extra_info_id       in      number,
    p_object_version_number       in      out nocopy number,
    p_effective_start_date        out     nocopy date,
    p_effective_end_date          out     nocopy date,
    p_return_status               out     nocopy varchar2)
is

    --
    -- Variables for API Boolean parameters
    l_validate                      boolean;
    --
    -- Variables for IN/OUT parameters
    --
    -- Other variables
    l_proc    varchar2(72) := g_package ||'delete_contact_extra_info';

begin

    hr_utility.set_location(' Entering:' || l_proc,10);
    -- Issue a savepoint
    savepoint delete_contact_extra_info_swi;
    -- Initialise Multiple Message Detection
    hr_multi_message.enable_message_list;
    -- Convert constant values to their corresponding boolean value
    l_validate := hr_api.constant_to_boolean (p_constant_value => p_validate);
    --
    -- Call API
    hr_contact_extra_info_api.delete_contact_extra_info(
        p_validate                    => l_validate,
        p_effective_date              => p_effective_date,
        p_datetrack_delete_mode       => p_datetrack_delete_mode,
        p_contact_extra_info_id       => p_contact_extra_info_id,
        p_object_version_number       => p_object_version_number,
        p_effective_start_date        => p_effective_start_date,
        p_effective_end_date          => p_effective_end_date);

    If l_validate = TRUE Then
        rollback to delete_contact_extra_info_swi;
    End If;

    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,20);

exception
    when hr_multi_message.error_message_exist then
        --
        -- Catch the Multiple Message List exception which
        -- indicates API processing has been aborted because
        -- at least one message exists in the list.
        --
        rollback to delete_contact_extra_info_swi;
        --
        -- Reset IN OUT parameters and set OUT parameters
        --
        p_return_status         := hr_multi_message.get_return_status_disable;
        p_effective_start_date  := null;
        p_effective_end_date    := null;

        hr_utility.set_location(' Leaving:' || l_proc, 30);
    when others then
        --
        -- When Multiple Message Detection is enabled catch
        -- any Application specific or other unexpected
        -- exceptions.  Adding appropriate details to the
        -- Multiple Message List.  Otherwise re-raise the
        -- error.
        --
        rollback to delete_contact_extra_info_swi;
        if hr_multi_message.unexpected_error_add(l_proc) then
           hr_utility.set_location(' Leaving:' || l_proc,40);
           raise;
        end if;
        --
        -- Reset IN OUT and set OUT parameters
        --
        p_return_status := hr_multi_message.get_return_status_disable;
        p_effective_start_date  := null;
        p_effective_end_date    := null;

        hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_contact_extra_info;

end hr_contact_extra_info_swi;

/
