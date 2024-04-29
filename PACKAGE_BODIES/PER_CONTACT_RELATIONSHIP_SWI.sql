--------------------------------------------------------
--  DDL for Package Body PER_CONTACT_RELATIONSHIP_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CONTACT_RELATIONSHIP_SWI" as
/* $Header: pectrswi.pkb 120.1.12000000.1 2007/02/08 12:04:41 ssutar noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_contact_relationship_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< ins >-----------------------------------|
-- ----------------------------------------------------------------------------

procedure ins(
    p_contact_relationship_id      in number,
    p_business_group_id            in number,
    p_person_id                    in number,
    p_contact_person_id            in number,
    p_contact_type                 in varchar2,
    p_comments                     in long             default null,
    p_primary_contact_flag         in varchar2         default 'N',
    p_request_id                   in number           default null,
    p_program_application_id       in number           default null,
    p_program_id                   in number           default null,
    p_program_update_date          in date             default null,
    p_date_start                   in date             default null,
    p_start_life_reason_id         in number           default null,
    p_date_end                     in date             default null,
    p_end_life_reason_id           in number           default null,
    p_rltd_per_rsds_w_dsgntr_flag  in varchar2         default 'N',
    p_personal_flag                in varchar2         default 'N',
    p_sequence_number              in number           default null,
    p_cont_attribute_category      in varchar2         default null,
    p_cont_attribute1              in varchar2         default null,
    p_cont_attribute2              in varchar2         default null,
    p_cont_attribute3              in varchar2         default null,
    p_cont_attribute4              in varchar2         default null,
    p_cont_attribute5              in varchar2         default null,
    p_cont_attribute6              in varchar2         default null,
    p_cont_attribute7              in varchar2         default null,
    p_cont_attribute8              in varchar2         default null,
    p_cont_attribute9              in varchar2         default null,
    p_cont_attribute10             in varchar2         default null,
    p_cont_attribute11             in varchar2         default null,
    p_cont_attribute12             in varchar2         default null,
    p_cont_attribute13             in varchar2         default null,
    p_cont_attribute14             in varchar2         default null,
    p_cont_attribute15             in varchar2         default null,
    p_cont_attribute16             in varchar2         default null,
    p_cont_attribute17             in varchar2         default null,
    p_cont_attribute18             in varchar2         default null,
    p_cont_attribute19             in varchar2         default null,
    p_cont_attribute20             in varchar2         default null,
    p_cont_information_category    in varchar2         default null,
    p_cont_information1            in varchar2         default null,
    p_cont_information2            in varchar2         default null,
    p_cont_information3            in varchar2         default null,
    p_cont_information4            in varchar2         default null,
    p_cont_information5            in varchar2         default null,
    p_cont_information6            in varchar2         default null,
    p_cont_information7            in varchar2         default null,
    p_cont_information8            in varchar2         default null,
    p_cont_information9            in varchar2         default null,
    p_cont_information10           in varchar2         default null,
    p_cont_information11           in varchar2         default null,
    p_cont_information12           in varchar2         default null,
    p_cont_information13           in varchar2         default null,
    p_cont_information14           in varchar2         default null,
    p_cont_information15           in varchar2         default null,
    p_cont_information16           in varchar2         default null,
    p_cont_information17           in varchar2         default null,
    p_cont_information18           in varchar2         default null,
    p_cont_information19           in varchar2         default null,
    p_cont_information20           in varchar2         default null,
    p_third_party_pay_flag         in varchar2         default 'N',
    p_bondholder_flag              in varchar2         default 'N',
    p_dependent_flag               in varchar2         default 'N',
    p_beneficiary_flag             in varchar2         default 'N',
    p_object_version_number        out nocopy number,
    p_effective_date               in date             default null,
    p_validate                     in number           default hr_api.g_false_num,
    p_return_status                out nocopy varchar2
    ) as

    --
    -- Variables for API Boolean parameters
    l_validate                      boolean;
    --
    -- Variables for IN/OUT parameters
    --
    -- Other variables
    l_contact_relationship_id        number;
    l_proc    varchar2(72) := g_package ||'insert';
    l_per_person_id                  number;
    l_per_object_version_number      number;
    l_per_effective_start_date       date;
    l_per_effective_end_date         date;
    l_full_name                      varchar2(240);
    l_per_comment_id                 number;
    l_name_combination_warning       boolean;
    l_orig_hire_warning              boolean;

begin

    hr_utility.set_location(' Entering:' || l_proc,10);
    --
    -- Issue a savepoint
    --
    savepoint per_ctr_swi_ins;
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

    per_ctr_ins.set_base_key_value (
        p_contact_relationship_id => p_contact_relationship_id
    );

    --
    -- Call API
    --
    hr_contact_rel_api.create_contact(
        P_CONTACT_RELATIONSHIP_ID     => l_contact_relationship_id,
        P_BUSINESS_GROUP_ID           => P_BUSINESS_GROUP_ID,
        P_PERSON_ID                   => P_PERSON_ID,
        P_CONTACT_PERSON_ID           => P_CONTACT_PERSON_ID,
        P_CONTACT_TYPE                => P_CONTACT_TYPE,
        P_CTR_COMMENTS                => P_COMMENTS,
        P_PRIMARY_CONTACT_FLAG        => P_PRIMARY_CONTACT_FLAG,
        P_DATE_START                  => P_DATE_START,
        P_START_LIFE_REASON_ID        => P_START_LIFE_REASON_ID,
        P_DATE_END                    => P_DATE_END,
        P_END_LIFE_REASON_ID          => P_END_LIFE_REASON_ID,
        P_RLTD_PER_RSDS_W_DSGNTR_FLAG => P_RLTD_PER_RSDS_W_DSGNTR_FLAG,
        P_PERSONAL_FLAG               => P_PERSONAL_FLAG,
        P_SEQUENCE_NUMBER             => P_SEQUENCE_NUMBER,
        P_CONT_ATTRIBUTE_CATEGORY     => P_CONT_ATTRIBUTE_CATEGORY,
        P_CONT_ATTRIBUTE1             => P_CONT_ATTRIBUTE1,
        P_CONT_ATTRIBUTE2             => P_CONT_ATTRIBUTE2,
        P_CONT_ATTRIBUTE3             => P_CONT_ATTRIBUTE3,
        P_CONT_ATTRIBUTE4             => P_CONT_ATTRIBUTE4,
        P_CONT_ATTRIBUTE5             => P_CONT_ATTRIBUTE5,
        P_CONT_ATTRIBUTE6             => P_CONT_ATTRIBUTE6,
        P_CONT_ATTRIBUTE7             => P_CONT_ATTRIBUTE7,
        P_CONT_ATTRIBUTE8             => P_CONT_ATTRIBUTE8,
        P_CONT_ATTRIBUTE9             => P_CONT_ATTRIBUTE9,
        P_CONT_ATTRIBUTE10            => P_CONT_ATTRIBUTE10,
        P_CONT_ATTRIBUTE11            => P_CONT_ATTRIBUTE11,
        P_CONT_ATTRIBUTE12            => P_CONT_ATTRIBUTE12,
        P_CONT_ATTRIBUTE13            => P_CONT_ATTRIBUTE13,
        P_CONT_ATTRIBUTE14            => P_CONT_ATTRIBUTE14,
        P_CONT_ATTRIBUTE15            => P_CONT_ATTRIBUTE15,
        P_CONT_ATTRIBUTE16            => P_CONT_ATTRIBUTE16,
        P_CONT_ATTRIBUTE17            => P_CONT_ATTRIBUTE17,
        P_CONT_ATTRIBUTE18            => P_CONT_ATTRIBUTE18,
        P_CONT_ATTRIBUTE19            => P_CONT_ATTRIBUTE19,
        P_CONT_ATTRIBUTE20            => P_CONT_ATTRIBUTE20,
        P_CONT_INFORMATION_CATEGORY   => P_CONT_INFORMATION_CATEGORY,
        P_CONT_INFORMATION1           => P_CONT_INFORMATION1,
        P_CONT_INFORMATION2           => P_CONT_INFORMATION2,
        P_CONT_INFORMATION3           => P_CONT_INFORMATION3,
        P_CONT_INFORMATION4           => P_CONT_INFORMATION4,
        P_CONT_INFORMATION5           => P_CONT_INFORMATION5,
        P_CONT_INFORMATION6           => P_CONT_INFORMATION6,
        P_CONT_INFORMATION7           => P_CONT_INFORMATION7,
        P_CONT_INFORMATION8           => P_CONT_INFORMATION8,
        P_CONT_INFORMATION9           => P_CONT_INFORMATION9,
        P_CONT_INFORMATION10          => P_CONT_INFORMATION10,
        P_CONT_INFORMATION11          => P_CONT_INFORMATION11,
        P_CONT_INFORMATION12          => P_CONT_INFORMATION12,
        P_CONT_INFORMATION13          => P_CONT_INFORMATION13,
        P_CONT_INFORMATION14          => P_CONT_INFORMATION14,
        P_CONT_INFORMATION15          => P_CONT_INFORMATION15,
        P_CONT_INFORMATION16          => P_CONT_INFORMATION16,
        P_CONT_INFORMATION17          => P_CONT_INFORMATION17,
        P_CONT_INFORMATION18          => P_CONT_INFORMATION18,
        P_CONT_INFORMATION19          => P_CONT_INFORMATION19,
        P_CONT_INFORMATION20          => P_CONT_INFORMATION20,
        P_THIRD_PARTY_PAY_FLAG        => P_THIRD_PARTY_PAY_FLAG,
        P_BONDHOLDER_FLAG             => P_BONDHOLDER_FLAG,
        P_DEPENDENT_FLAG              => P_DEPENDENT_FLAG,
        P_BENEFICIARY_FLAG            => P_BENEFICIARY_FLAG,
        P_CTR_OBJECT_VERSION_NUMBER   => P_OBJECT_VERSION_NUMBER,
        P_START_DATE                  => P_EFFECTIVE_DATE,
        P_VALIDATE                    => l_validate,
        P_PER_PERSON_ID               => l_per_person_id,
        P_PER_OBJECT_VERSION_NUMBER   => l_per_object_version_number,
        P_PER_EFFECTIVE_START_DATE    => l_per_effective_start_date,
        P_PER_EFFECTIVE_END_DATE      => l_per_effective_end_date,
        P_FULL_NAME                   => l_full_name,
        P_PER_COMMENT_ID              => l_per_comment_id,
        P_NAME_COMBINATION_WARNING    => l_name_combination_warning,
        P_ORIG_HIRE_WARNING           => l_orig_hire_warning
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
    If l_validate = TRUE Then
        rollback to per_ctr_swi_ins;
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
        rollback to per_ctr_swi_ins;
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
        rollback to per_ctr_swi_ins;
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

end ins;

-- ----------------------------------------------------------------------------
-- |--------------------------------< upd >-----------------------------------|
-- ----------------------------------------------------------------------------

procedure upd (
    p_contact_relationship_id      in number,
    p_contact_type                 in varchar2         default hr_api.g_varchar2,
    p_comments                     in long             default hr_api.g_varchar2,
    p_primary_contact_flag         in varchar2         default hr_api.g_varchar2,
    p_request_id                   in number           default hr_api.g_number,
    p_program_application_id       in number           default hr_api.g_number,
    p_program_id                   in number           default hr_api.g_number,
    p_program_update_date          in date             default hr_api.g_date,
    p_date_start                   in date             default hr_api.g_date,
    p_start_life_reason_id         in number           default hr_api.g_number,
    p_date_end                     in date             default hr_api.g_date,
    p_end_life_reason_id           in number           default hr_api.g_number,
    p_rltd_per_rsds_w_dsgntr_flag  in varchar2         default hr_api.g_varchar2,
    p_personal_flag                in varchar2         default hr_api.g_varchar2,
    p_sequence_number              in number           default hr_api.g_number,
    p_cont_attribute_category      in varchar2         default hr_api.g_varchar2,
    p_cont_attribute1              in varchar2         default hr_api.g_varchar2,
    p_cont_attribute2              in varchar2         default hr_api.g_varchar2,
    p_cont_attribute3              in varchar2         default hr_api.g_varchar2,
    p_cont_attribute4              in varchar2         default hr_api.g_varchar2,
    p_cont_attribute5              in varchar2         default hr_api.g_varchar2,
    p_cont_attribute6              in varchar2         default hr_api.g_varchar2,
    p_cont_attribute7              in varchar2         default hr_api.g_varchar2,
    p_cont_attribute8              in varchar2         default hr_api.g_varchar2,
    p_cont_attribute9              in varchar2         default hr_api.g_varchar2,
    p_cont_attribute10             in varchar2         default hr_api.g_varchar2,
    p_cont_attribute11             in varchar2         default hr_api.g_varchar2,
    p_cont_attribute12             in varchar2         default hr_api.g_varchar2,
    p_cont_attribute13             in varchar2         default hr_api.g_varchar2,
    p_cont_attribute14             in varchar2         default hr_api.g_varchar2,
    p_cont_attribute15             in varchar2         default hr_api.g_varchar2,
    p_cont_attribute16             in varchar2         default hr_api.g_varchar2,
    p_cont_attribute17             in varchar2         default hr_api.g_varchar2,
    p_cont_attribute18             in varchar2         default hr_api.g_varchar2,
    p_cont_attribute19             in varchar2         default hr_api.g_varchar2,
    p_cont_attribute20             in varchar2         default hr_api.g_varchar2,
    p_cont_information_category    in varchar2         default hr_api.g_varchar2,
    p_cont_information1            in varchar2         default hr_api.g_varchar2,
    p_cont_information2            in varchar2         default hr_api.g_varchar2,
    p_cont_information3            in varchar2         default hr_api.g_varchar2,
    p_cont_information4            in varchar2         default hr_api.g_varchar2,
    p_cont_information5            in varchar2         default hr_api.g_varchar2,
    p_cont_information6            in varchar2         default hr_api.g_varchar2,
    p_cont_information7            in varchar2         default hr_api.g_varchar2,
    p_cont_information8            in varchar2         default hr_api.g_varchar2,
    p_cont_information9            in varchar2         default hr_api.g_varchar2,
    p_cont_information10           in varchar2         default hr_api.g_varchar2,
    p_cont_information11           in varchar2         default hr_api.g_varchar2,
    p_cont_information12           in varchar2         default hr_api.g_varchar2,
    p_cont_information13           in varchar2         default hr_api.g_varchar2,
    p_cont_information14           in varchar2         default hr_api.g_varchar2,
    p_cont_information15           in varchar2         default hr_api.g_varchar2,
    p_cont_information16           in varchar2         default hr_api.g_varchar2,
    p_cont_information17           in varchar2         default hr_api.g_varchar2,
    p_cont_information18           in varchar2         default hr_api.g_varchar2,
    p_cont_information19           in varchar2         default hr_api.g_varchar2,
    p_cont_information20           in varchar2         default hr_api.g_varchar2,
    p_third_party_pay_flag         in varchar2         default hr_api.g_varchar2,
    p_bondholder_flag              in varchar2         default hr_api.g_varchar2,
    p_dependent_flag               in varchar2         default hr_api.g_varchar2,
    p_beneficiary_flag             in varchar2         default hr_api.g_varchar2,
    p_object_version_number        in out nocopy number,
    p_effective_date               in date,
    p_validate                     in number           default hr_api.g_false_num,
    p_return_status                out nocopy varchar2
    ) is
    --
    -- Variables for API Boolean parameters
    l_validate                      boolean;
    --
    -- Variables for IN/OUT parameters
    l_object_version_number         number;

    l_proc    varchar2(72) := g_package ||' upd';

begin
    hr_utility.set_location(' Entering:' || l_proc,10);
    --
    -- Issue a savepoint
    --
    savepoint per_ctr_swi_upd;
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
    --
    hr_contact_rel_api.update_contact_relationship(
        P_CONTACT_RELATIONSHIP_ID     => P_CONTACT_RELATIONSHIP_ID,
        P_CONTACT_TYPE                => P_CONTACT_TYPE,
        P_COMMENTS                    => P_COMMENTS,
        P_PRIMARY_CONTACT_FLAG        => P_PRIMARY_CONTACT_FLAG,
        P_DATE_START                  => P_DATE_START,
        P_START_LIFE_REASON_ID        => P_START_LIFE_REASON_ID,
        P_DATE_END                    => P_DATE_END,
        P_END_LIFE_REASON_ID          => P_END_LIFE_REASON_ID,
        P_RLTD_PER_RSDS_W_DSGNTR_FLAG => P_RLTD_PER_RSDS_W_DSGNTR_FLAG,
        P_PERSONAL_FLAG               => P_PERSONAL_FLAG,
        P_SEQUENCE_NUMBER             => P_SEQUENCE_NUMBER,
        P_CONT_ATTRIBUTE_CATEGORY     => P_CONT_ATTRIBUTE_CATEGORY,
        P_CONT_ATTRIBUTE1             => P_CONT_ATTRIBUTE1,
        P_CONT_ATTRIBUTE2             => P_CONT_ATTRIBUTE2,
        P_CONT_ATTRIBUTE3             => P_CONT_ATTRIBUTE3,
        P_CONT_ATTRIBUTE4             => P_CONT_ATTRIBUTE4,
        P_CONT_ATTRIBUTE5             => P_CONT_ATTRIBUTE5,
        P_CONT_ATTRIBUTE6             => P_CONT_ATTRIBUTE6,
        P_CONT_ATTRIBUTE7             => P_CONT_ATTRIBUTE7,
        P_CONT_ATTRIBUTE8             => P_CONT_ATTRIBUTE8,
        P_CONT_ATTRIBUTE9             => P_CONT_ATTRIBUTE9,
        P_CONT_ATTRIBUTE10            => P_CONT_ATTRIBUTE10,
        P_CONT_ATTRIBUTE11            => P_CONT_ATTRIBUTE11,
        P_CONT_ATTRIBUTE12            => P_CONT_ATTRIBUTE12,
        P_CONT_ATTRIBUTE13            => P_CONT_ATTRIBUTE13,
        P_CONT_ATTRIBUTE14            => P_CONT_ATTRIBUTE14,
        P_CONT_ATTRIBUTE15            => P_CONT_ATTRIBUTE15,
        P_CONT_ATTRIBUTE16            => P_CONT_ATTRIBUTE16,
        P_CONT_ATTRIBUTE17            => P_CONT_ATTRIBUTE17,
        P_CONT_ATTRIBUTE18            => P_CONT_ATTRIBUTE18,
        P_CONT_ATTRIBUTE19            => P_CONT_ATTRIBUTE19,
        P_CONT_ATTRIBUTE20            => P_CONT_ATTRIBUTE20,
        P_CONT_INFORMATION_CATEGORY   => P_CONT_INFORMATION_CATEGORY,
        P_CONT_INFORMATION1           => P_CONT_INFORMATION1,
        P_CONT_INFORMATION2           => P_CONT_INFORMATION2,
        P_CONT_INFORMATION3           => P_CONT_INFORMATION3,
        P_CONT_INFORMATION4           => P_CONT_INFORMATION4,
        P_CONT_INFORMATION5           => P_CONT_INFORMATION5,
        P_CONT_INFORMATION6           => P_CONT_INFORMATION6,
        P_CONT_INFORMATION7           => P_CONT_INFORMATION7,
        P_CONT_INFORMATION8           => P_CONT_INFORMATION8,
        P_CONT_INFORMATION9           => P_CONT_INFORMATION9,
        P_CONT_INFORMATION10          => P_CONT_INFORMATION10,
        P_CONT_INFORMATION11          => P_CONT_INFORMATION11,
        P_CONT_INFORMATION12          => P_CONT_INFORMATION12,
        P_CONT_INFORMATION13          => P_CONT_INFORMATION13,
        P_CONT_INFORMATION14          => P_CONT_INFORMATION14,
        P_CONT_INFORMATION15          => P_CONT_INFORMATION15,
        P_CONT_INFORMATION16          => P_CONT_INFORMATION16,
        P_CONT_INFORMATION17          => P_CONT_INFORMATION17,
        P_CONT_INFORMATION18          => P_CONT_INFORMATION18,
        P_CONT_INFORMATION19          => P_CONT_INFORMATION19,
        P_CONT_INFORMATION20          => P_CONT_INFORMATION20,
        P_THIRD_PARTY_PAY_FLAG        => P_THIRD_PARTY_PAY_FLAG,
        P_BONDHOLDER_FLAG             => P_BONDHOLDER_FLAG,
        P_DEPENDENT_FLAG              => P_DEPENDENT_FLAG,
        P_BENEFICIARY_FLAG            => P_BENEFICIARY_FLAG,
        P_OBJECT_VERSION_NUMBER       => P_OBJECT_VERSION_NUMBER,
        P_EFFECTIVE_DATE              => P_EFFECTIVE_DATE,
        P_VALIDATE                    => l_validate
        );

    If l_validate = TRUE Then
        rollback to per_ctr_swi_upd;
    End If;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
    when hr_multi_message.error_message_exist then
        --
        rollback to per_ctr_swi_upd;
        --
        --
        p_object_version_number        := l_object_version_number;
        p_return_status := hr_multi_message.get_return_status_disable;
        hr_utility.set_location(' Leaving:' || l_proc, 30);

    when others then
        --
        rollback to per_ctr_swi_upd;

        if hr_multi_message.unexpected_error_add(l_proc) then
            hr_utility.set_location(' Leaving:' || l_proc,40);
            raise;
        end if;
        --
        p_object_version_number        := l_object_version_number;
        p_return_status := hr_multi_message.get_return_status_disable;
        hr_utility.set_location(' Leaving:' || l_proc,50);

end upd;

-- ----------------------------------------------------------------------------
-- |----------------------------------< del >---------------------------------|
-- ----------------------------------------------------------------------------

procedure del (
    p_contact_relationship_id      in number,
    p_object_version_number        in number,
    p_validate                     in number           default hr_api.g_false_num,
    p_return_status                out nocopy varchar2
    ) is

    --
    -- Variables for API Boolean parameters
    l_validate                      boolean;
    --
    -- Variables for IN/OUT parameters
    --
    -- Other variables
    l_proc    varchar2(72) := g_package ||'del';

begin

    hr_utility.set_location(' Entering:' || l_proc,10);
    -- Issue a savepoint
    savepoint per_ctr_swi_del;
    -- Initialise Multiple Message Detection
    hr_multi_message.enable_message_list;
    -- Convert constant values to their corresponding boolean value
    l_validate := hr_api.constant_to_boolean (p_constant_value => p_validate);
    --
    -- Call API
    hr_contact_rel_api.delete_contact_relationship(
        P_CONTACT_RELATIONSHIP_ID => P_CONTACT_RELATIONSHIP_ID,
        P_OBJECT_VERSION_NUMBER   => P_OBJECT_VERSION_NUMBER,
        P_VALIDATE                => l_validate
        );

    If l_validate = TRUE Then
        rollback to delete_questionnaire_swi;
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
        rollback to per_ctr_swi_del;
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
        rollback to per_ctr_swi_del;
        if hr_multi_message.unexpected_error_add(l_proc) then
           hr_utility.set_location(' Leaving:' || l_proc,40);
           raise;
        end if;
        --
        -- Reset IN OUT and set OUT parameters
        --
        p_return_status := hr_multi_message.get_return_status_disable;
        hr_utility.set_location(' Leaving:' || l_proc,50);
end del;

END per_contact_relationship_swi;

/
