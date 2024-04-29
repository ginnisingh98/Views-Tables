--------------------------------------------------------
--  DDL for Package Body IRC_PARTY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PARTY_SWI" As
/* $Header: irhzpswi.pkb 120.3.12010000.3 2009/06/04 10:16:27 vmummidi ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_party_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_candidate_internal >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_candidate_internal
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_id                    in     number
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_first_name                   in     varchar2  default null
  ,p_date_of_birth                in     date      default null
  ,p_email_address                in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_gender                       in     varchar2  default null
  ,p_marital_status               in     varchar2  default null
  ,p_previous_last_name           in     varchar2  default null
  ,p_middle_name                  in     varchar2  default null
  ,p_name_suffix                  in     varchar2  default null
  ,p_known_as                     in     varchar2  default null
  ,p_first_name_phonetic          in     varchar2  default null
  ,p_last_name_phonetic           in     varchar2  default null
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
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_nationality                  in     varchar2  default null
  ,p_national_identifier          in     varchar2  default null
  ,p_town_of_birth                in     varchar2  default null
  ,p_region_of_birth              in     varchar2  default null
  ,p_country_of_birth             in     varchar2  default null
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ,p_object_version_number        out nocopy number
  ,p_return_status                out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  l_person_id number;
  l_person_ovn number;
  --
  cursor csr_person_ovn(p_person_id number) is
  select object_version_number
  from per_all_people_f
  where person_id = p_person_id;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_candidate_internal';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_candidate_internal_swi;
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
  -- Register Person ID
  --
  per_per_ins.set_base_key_value(p_person_id => p_person_id);
  --
  -- Call API
  --
  irc_party_api.create_candidate_internal
    (p_validate                     => l_validate
    ,p_business_group_id            => p_business_group_id
    ,p_last_name                    => p_last_name
    ,p_first_name                   => p_first_name
    ,p_date_of_birth                => p_date_of_birth
    ,p_email_address                => p_email_address
    ,p_title                        => p_title
    ,p_gender                       => p_gender
    ,p_marital_status               => p_marital_status
    ,p_previous_last_name           => p_previous_last_name
    ,p_middle_name                  => p_middle_name
    ,p_name_suffix                  => p_name_suffix
    ,p_known_as                     => p_known_as
    ,p_first_name_phonetic          => p_first_name_phonetic
    ,p_last_name_phonetic           => p_last_name_phonetic
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_per_information_category     => p_per_information_category
    ,p_per_information1             => p_per_information1
    ,p_per_information2             => p_per_information2
    ,p_per_information3             => p_per_information3
    ,p_per_information4             => p_per_information4
    ,p_per_information5             => p_per_information5
    ,p_per_information6             => p_per_information6
    ,p_per_information7             => p_per_information7
    ,p_per_information8             => p_per_information8
    ,p_per_information9             => p_per_information9
    ,p_per_information10            => p_per_information10
    ,p_per_information11            => p_per_information11
    ,p_per_information12            => p_per_information12
    ,p_per_information13            => p_per_information13
    ,p_per_information14            => p_per_information14
    ,p_per_information15            => p_per_information15
    ,p_per_information16            => p_per_information16
    ,p_per_information17            => p_per_information17
    ,p_per_information18            => p_per_information18
    ,p_per_information19            => p_per_information19
    ,p_per_information20            => p_per_information20
    ,p_per_information21            => p_per_information21
    ,p_per_information22            => p_per_information22
    ,p_per_information23            => p_per_information23
    ,p_per_information24            => p_per_information24
    ,p_per_information25            => p_per_information25
    ,p_per_information26            => p_per_information26
    ,p_per_information27            => p_per_information27
    ,p_per_information28            => p_per_information28
    ,p_per_information29            => p_per_information29
    ,p_per_information30            => p_per_information30
    ,p_nationality                  => p_nationality
    ,p_national_identifier          => p_national_identifier
    ,p_town_of_birth                => p_town_of_birth
    ,p_region_of_birth              => p_region_of_birth
    ,p_country_of_birth             => p_country_of_birth
    ,p_person_id                    => l_person_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    );
  --
  -- get object version number
  --
  open csr_person_ovn(p_person_id);
  fetch csr_person_ovn into l_person_ovn;
  close csr_person_ovn;
  p_object_version_number := l_person_ovn;
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
    rollback to create_candidate_internal_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to create_candidate_internal_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_candidate_internal;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_registered_user >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_registered_user
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_last_name                    in     varchar2
  ,p_first_name                   in     varchar2  default null
  ,p_date_of_birth                in     date      default null
  ,p_title                        in     varchar2  default null
  ,p_gender                       in     varchar2  default null
  ,p_marital_status               in     varchar2  default null
  ,p_previous_last_name           in     varchar2  default null
  ,p_middle_name                  in     varchar2  default null
  ,p_name_suffix                  in     varchar2  default null
  ,p_known_as                     in     varchar2  default null
  ,p_first_name_phonetic          in     varchar2  default null
  ,p_last_name_phonetic           in     varchar2  default null
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
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ,p_person_id                    out nocopy number
  ,p_return_status                out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_registered_user';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_registered_user_swi;
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
  irc_party_api.create_registered_user
    (p_validate                     => l_validate
    ,p_last_name                    => p_last_name
    ,p_first_name                   => p_first_name
    ,p_date_of_birth                => p_date_of_birth
    ,p_title                        => p_title
    ,p_gender                       => p_gender
    ,p_marital_status               => p_marital_status
    ,p_previous_last_name           => p_previous_last_name
    ,p_middle_name                  => p_middle_name
    ,p_name_suffix                  => p_name_suffix
    ,p_known_as                     => p_known_as
    ,p_first_name_phonetic          => p_first_name_phonetic
    ,p_last_name_phonetic           => p_last_name_phonetic
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_per_information_category     => p_per_information_category
    ,p_per_information1             => p_per_information1
    ,p_per_information2             => p_per_information2
    ,p_per_information3             => p_per_information3
    ,p_per_information4             => p_per_information4
    ,p_per_information5             => p_per_information5
    ,p_per_information6             => p_per_information6
    ,p_per_information7             => p_per_information7
    ,p_per_information8             => p_per_information8
    ,p_per_information9             => p_per_information9
    ,p_per_information10            => p_per_information10
    ,p_per_information11            => p_per_information11
    ,p_per_information12            => p_per_information12
    ,p_per_information13            => p_per_information13
    ,p_per_information14            => p_per_information14
    ,p_per_information15            => p_per_information15
    ,p_per_information16            => p_per_information16
    ,p_per_information17            => p_per_information17
    ,p_per_information18            => p_per_information18
    ,p_per_information19            => p_per_information19
    ,p_per_information20            => p_per_information20
    ,p_per_information21            => p_per_information21
    ,p_per_information22            => p_per_information22
    ,p_per_information23            => p_per_information23
    ,p_per_information24            => p_per_information24
    ,p_per_information25            => p_per_information25
    ,p_per_information26            => p_per_information26
    ,p_per_information27            => p_per_information27
    ,p_per_information28            => p_per_information28
    ,p_per_information29            => p_per_information29
    ,p_per_information30            => p_per_information30
    ,p_person_id                    => p_person_id
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
    rollback to create_registered_user_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_person_id                    := null;
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
    rollback to create_registered_user_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_person_id                    := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_registered_user;
-- ----------------------------------------------------------------------------
-- |----------------------< registered_user_application >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE registered_user_application
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_recruitment_person_id        in     number
  ,p_person_id                    in     number
  ,p_assignment_id                in     number
  ,p_application_received_date    in     date      default null
  ,p_vacancy_id                   in     number    default null
  ,p_posting_content_id           in     number    default null
  ,p_per_information4             in     per_all_people_f.per_information4%type   default null
  ,p_per_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_recruitment_person_ovn          out nocopy number
  ,p_applicant_number                out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  -- Added for turn off key flex field validation
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_recruitment_person_ovn number;
  l_proc    varchar2(72) := g_package ||'registered_user_application';
  --
  cursor csr_person_ovn(p_person_id number
                       ,p_effective_date date) is
  select object_version_number
  from per_all_people_f
  where person_id = p_person_id
  and p_effective_date between effective_start_date and effective_end_date;
  --
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint registered_user_application;
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

  irc_party_api.registered_user_application
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_recruitment_person_id        => p_recruitment_person_id
    ,p_person_id                    => p_person_id
    ,p_application_received_date    => p_application_received_date
    ,p_vacancy_id                   => p_vacancy_id
    ,p_posting_content_id           => p_posting_content_id
    ,p_assignment_id                => p_assignment_id
    ,p_per_object_version_number    => p_per_object_version_number
    ,p_asg_object_version_number    => p_asg_object_version_number
    ,p_applicant_number             => p_applicant_number
    ,p_per_information4             => p_per_information4
    );
  --
  open csr_person_ovn(p_recruitment_person_id,p_effective_date);
  fetch csr_person_ovn into l_recruitment_person_ovn;
  close csr_person_ovn;
  p_recruitment_person_ovn := l_recruitment_person_ovn;
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
    rollback to registered_user_application;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_per_object_version_number    := null;
    p_asg_object_version_number    := null;
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
    rollback to registered_user_application;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_per_object_version_number    := null;
    p_asg_object_version_number    := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end registered_user_application;
-- ----------------------------------------------------------------------------
-- |------------------------< update_registered_user >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_registered_user
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_first_name                   in     varchar2  default hr_api.g_varchar2
  ,p_last_name                    in     varchar2  default hr_api.g_varchar2
  ,p_date_of_birth                in     date      default hr_api.g_date
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_gender                       in     varchar2  default hr_api.g_varchar2
  ,p_marital_status               in     varchar2  default hr_api.g_varchar2
  ,p_previous_last_name           in     varchar2  default hr_api.g_varchar2
  ,p_middle_name                  in     varchar2  default hr_api.g_varchar2
  ,p_name_suffix                  in     varchar2  default hr_api.g_varchar2
  ,p_known_as                     in     varchar2  default hr_api.g_varchar2
  ,p_first_name_phonetic          in     varchar2  default hr_api.g_varchar2
  ,p_last_name_phonetic           in     varchar2  default hr_api.g_varchar2
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
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_per_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_per_information1             in     varchar2  default hr_api.g_varchar2
  ,p_per_information2             in     varchar2  default hr_api.g_varchar2
  ,p_per_information3             in     varchar2  default hr_api.g_varchar2
  ,p_per_information4             in     varchar2  default hr_api.g_varchar2
  ,p_per_information5             in     varchar2  default hr_api.g_varchar2
  ,p_per_information6             in     varchar2  default hr_api.g_varchar2
  ,p_per_information7             in     varchar2  default hr_api.g_varchar2
  ,p_per_information8             in     varchar2  default hr_api.g_varchar2
  ,p_per_information9             in     varchar2  default hr_api.g_varchar2
  ,p_per_information10            in     varchar2  default hr_api.g_varchar2
  ,p_per_information11            in     varchar2  default hr_api.g_varchar2
  ,p_per_information12            in     varchar2  default hr_api.g_varchar2
  ,p_per_information13            in     varchar2  default hr_api.g_varchar2
  ,p_per_information14            in     varchar2  default hr_api.g_varchar2
  ,p_per_information15            in     varchar2  default hr_api.g_varchar2
  ,p_per_information16            in     varchar2  default hr_api.g_varchar2
  ,p_per_information17            in     varchar2  default hr_api.g_varchar2
  ,p_per_information18            in     varchar2  default hr_api.g_varchar2
  ,p_per_information19            in     varchar2  default hr_api.g_varchar2
  ,p_per_information20            in     varchar2  default hr_api.g_varchar2
  ,p_per_information21            in     varchar2  default hr_api.g_varchar2
  ,p_per_information22            in     varchar2  default hr_api.g_varchar2
  ,p_per_information23            in     varchar2  default hr_api.g_varchar2
  ,p_per_information24            in     varchar2  default hr_api.g_varchar2
  ,p_per_information25            in     varchar2  default hr_api.g_varchar2
  ,p_per_information26            in     varchar2  default hr_api.g_varchar2
  ,p_per_information27            in     varchar2  default hr_api.g_varchar2
  ,p_per_information28            in     varchar2  default hr_api.g_varchar2
  ,p_per_information29            in     varchar2  default hr_api.g_varchar2
  ,p_per_information30            in     varchar2  default hr_api.g_varchar2
  ,p_person_ovn                   out nocopy number
  ,p_return_status                out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_registered_user';
  --
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_registered_user_swi;
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
  -- Set the person_id global
  --
  irc_party_api.g_person_id := p_person_id;
  --
  --
  -- Call API
  --
  irc_party_api.update_registered_user
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    ,p_first_name                   => p_first_name
    ,p_last_name                    => p_last_name
    ,p_date_of_birth                => p_date_of_birth
    ,p_title                        => p_title
    ,p_gender                       => p_gender
    ,p_marital_status               => p_marital_status
    ,p_previous_last_name           => p_previous_last_name
    ,p_middle_name                  => p_middle_name
    ,p_name_suffix                  => p_name_suffix
    ,p_known_as                     => p_known_as
    ,p_first_name_phonetic          => p_first_name_phonetic
    ,p_last_name_phonetic           => p_last_name_phonetic
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_per_information_category     => p_per_information_category
    ,p_per_information1             => p_per_information1
    ,p_per_information2             => p_per_information2
    ,p_per_information3             => p_per_information3
    ,p_per_information4             => p_per_information4
    ,p_per_information5             => p_per_information5
    ,p_per_information6             => p_per_information6
    ,p_per_information7             => p_per_information7
    ,p_per_information8             => p_per_information8
    ,p_per_information9             => p_per_information9
    ,p_per_information10            => p_per_information10
    ,p_per_information11            => p_per_information11
    ,p_per_information12            => p_per_information12
    ,p_per_information13            => p_per_information13
    ,p_per_information14            => p_per_information14
    ,p_per_information15            => p_per_information15
    ,p_per_information16            => p_per_information16
    ,p_per_information17            => p_per_information17
    ,p_per_information18            => p_per_information18
    ,p_per_information19            => p_per_information19
    ,p_per_information20            => p_per_information20
    ,p_per_information21            => p_per_information21
    ,p_per_information22            => p_per_information22
    ,p_per_information23            => p_per_information23
    ,p_per_information24            => p_per_information24
    ,p_per_information25            => p_per_information25
    ,p_per_information26            => p_per_information26
    ,p_per_information27            => p_per_information27
    ,p_per_information28            => p_per_information28
    ,p_per_information29            => p_per_information29
    ,p_per_information30            => p_per_information30
    );
  --
  -- Set the person_ovn out parameter
  --
  p_person_ovn := irc_party_api.g_ovn_for_person;
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
    rollback to update_registered_user_swi;
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
    rollback to update_registered_user_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_registered_user;
-- ----------------------------------------------------------------------------
-- |------------------------< create_user >-----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_user
   (p_user_name                 IN     varchar2
   ,p_password                  IN     varchar2
   ,p_start_date                IN     date
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_email                     IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
  ,p_last_name                    in     varchar2  default null
  ,p_first_name                   in     varchar2  default null
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_return_status                OUT nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_user';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_user_swi;
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
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  irc_party_api.create_user
    (p_user_name           => p_user_name
    ,p_password            => p_password
    ,p_start_date          => p_start_date
    ,p_responsibility_id   => p_responsibility_id
    ,p_resp_appl_id        => p_resp_appl_id
    ,p_security_group_id   => p_security_group_id
    ,p_email               => p_email
    ,p_language            => p_language
    ,p_last_name                    => p_last_name
    ,p_first_name                   => p_first_name
    ,p_per_information_category     => p_per_information_category
    ,p_per_information1             => p_per_information1
    ,p_per_information2             => p_per_information2
    ,p_per_information3             => p_per_information3
    ,p_per_information4             => p_per_information4
    ,p_per_information5             => p_per_information5
    ,p_per_information6             => p_per_information6
    ,p_per_information7             => p_per_information7
    ,p_per_information8             => p_per_information8
    ,p_per_information9             => p_per_information9
    ,p_per_information10            => p_per_information10
    ,p_per_information11            => p_per_information11
    ,p_per_information12            => p_per_information12
    ,p_per_information13            => p_per_information13
    ,p_per_information14            => p_per_information14
    ,p_per_information15            => p_per_information15
    ,p_per_information16            => p_per_information16
    ,p_per_information17            => p_per_information17
    ,p_per_information18            => p_per_information18
    ,p_per_information19            => p_per_information19
    ,p_per_information20            => p_per_information20
    ,p_per_information21            => p_per_information21
    ,p_per_information22            => p_per_information22
    ,p_per_information23            => p_per_information23
    ,p_per_information24            => p_per_information24
    ,p_per_information25            => p_per_information25
    ,p_per_information26            => p_per_information26
    ,p_per_information27            => p_per_information27
    ,p_per_information28            => p_per_information28
    ,p_per_information29            => p_per_information29
    ,p_per_information30            => p_per_information30
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
    rollback to create_user_swi;
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
    rollback to create_user_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_user;
-- ---------------------------------------------------------------------------
-- |------------------------< self_register_user >---------------------------|
-- ---------------------------------------------------------------------------
procedure self_register_user
   (p_validate                  IN     number   default hr_api.g_false_num
   ,p_current_email_address     IN     varchar2
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_first_name                IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_middle_names              IN     varchar2 default null
   ,p_previous_last_name        IN     varchar2 default null
   ,p_employee_number           IN     varchar2 default null
   ,p_national_identifier       IN     varchar2 default null
   ,p_date_of_birth             IN     date     default null
   ,p_email_address             IN     varchar2 default null
   ,p_home_phone_number         IN     varchar2 default null
   ,p_work_phone_number         IN     varchar2 default null
   ,p_address_line_1            IN     varchar2 default null
   ,p_manager_last_name         IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default 'N'
   ,p_language                  IN     varchar2 default null
   ,p_user_name                 IN     varchar2 default null
   ,p_return_status                OUT nocopy varchar2
   ) is
  --
  -- Variables for API Boolean parameters
  --
  l_validate boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'self_register_user';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint self_register_user_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
    IRC_PARTY_API.SELF_REGISTER_USER
    (p_validate                              => l_validate
    ,p_current_email_address                 => p_current_email_address
    ,p_responsibility_id                     => p_responsibility_id
    ,p_resp_appl_id                          => p_resp_appl_id
    ,p_security_group_id                     => p_security_group_id
    ,p_first_name                            => p_first_name
    ,p_last_name                             => p_last_name
    ,p_middle_names                          => p_middle_names
    ,p_previous_last_name                    => p_previous_last_name
    ,p_employee_number                       => p_employee_number
    ,p_national_identifier                   => p_national_identifier
    ,p_date_of_birth                         => p_date_of_birth
    ,p_email_address                         => p_email_address
    ,p_home_phone_number                     => p_home_phone_number
    ,p_work_phone_number                     => p_work_phone_number
    ,p_address_line_1                        => p_address_line_1
    ,p_manager_last_name                     => p_manager_last_name
    ,p_allow_access                          => p_allow_access
    ,p_language                              => p_language
    ,p_user_name                             => p_user_name
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
    rollback to self_register_user_swi;
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
    rollback to self_register_user_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end self_register_user;
-- -------------------------------------------------------------------
-- |------------------------< get_first_page >-----------------------|
-- -------------------------------------------------------------------
procedure get_first_page(p_responsibility_key in     varchar2
                        ,p_oasf                  out nocopy varchar2
                        ,p_oahp                  out nocopy varchar2) is
--
cursor get_function_id is
select fe.function_id
from fnd_menu_entries fe
where fe.function_id is not null
start with fe.menu_id=
(select resp.menu_id from fnd_responsibility resp
where resp.responsibility_key=p_responsibility_key)
connect by prior fe.sub_menu_id= fe.menu_id
and fe.grant_flag='Y'
order by level,fe.entry_sequence;
--
cursor get_function_info(p_function_id number) is
select fff.function_name
from fnd_form_functions fff
where fff.function_id=p_function_id;
--
cursor get_homepage is
select fe.menu_id
from fnd_menu_entries fe
where 'HOMEPAGE'=(select fm.type from fnd_menus fm
where fm.menu_id=fe.menu_id)
start with fe.menu_id=
(select resp.menu_id from fnd_responsibility resp
where resp.responsibility_key=p_responsibility_key)
connect by prior fe.sub_menu_id= fe.menu_id
and fe.grant_flag='Y'
order by level,fe.entry_sequence;
--
cursor get_menu_info(p_menu_id number) is
select fm.menu_name
from fnd_menus fm
where fm.menu_id=p_menu_id;
--
l_function_id fnd_menu_entries.function_id%type;
l_function_name fnd_form_functions.function_name%type;
l_menu_id fnd_menu_entries.menu_id%type;
l_menu_name fnd_menus.menu_name%type;
--
begin
open get_function_id;
fetch get_function_id into l_function_id;
if get_function_id%notfound then
  close get_function_id;
else
  close get_function_id;
  open get_function_info(l_function_id);
  fetch get_function_info into l_function_name;
  close get_function_info;
end if;
--
open get_homepage;
fetch get_homepage into l_menu_id;
if get_homepage%notfound then
  close get_homepage;
else
  close get_homepage;
  open get_menu_info(l_menu_id);
  fetch get_menu_info into l_menu_name;
  close get_menu_info;
end if;
p_oasf:=l_function_name;
p_oahp:=l_menu_name;
end get_first_page;
-- ---------------------------------------------------------------------------
-- |------------------------< create_partial_user >--------------------------|
-- ---------------------------------------------------------------------------
PROCEDURE create_partial_user
  (p_user_name                  IN      varchar2
  ,p_start_date                 IN      date     default null
  ,p_email                      IN      varchar2 default null
  ,p_language                   IN      varchar2 default null
  ,p_last_name                  IN      varchar2 default null
  ,p_first_name                 IN      varchar2 default null
  ,p_reg_bg_id                  IN      number
  ,p_responsibility_id          IN      number
  ,p_resp_appl_id               IN      number
  ,p_security_group_id          IN      number
  ,p_allow_access               IN      varchar2 default null
  ,p_return_status              OUT     nocopy varchar2
  ) is
    --
    -- Variables for API Boolean parameters
    --
    -- Variables for IN/OUT parameters
    --
    -- Other variables
    l_proc    varchar2(72) := g_package ||'create_partial_user';
Begin
    hr_utility.set_location(' Entering:' || l_proc,10);
    --
    -- Issue a savepoint
    --
    savepoint create_partial_user_swi;
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
    -- Register Surrogate ID or user key values
    --
    --
    -- Call API
    --
    irc_party_api.create_partial_user
    (p_user_name           => p_user_name
    ,p_start_date          => p_start_date
    ,p_email               => p_email
    ,p_language            => p_language
    ,p_last_name           => p_last_name
    ,p_first_name          => p_first_name
    ,p_reg_bg_id               => p_reg_bg_id
    ,p_responsibility_id   => p_responsibility_id
    ,p_resp_appl_id        => p_resp_appl_id
    ,p_security_group_id   => p_security_group_id
    ,p_allow_access        => p_allow_access
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
    rollback to create_partial_user_swi;
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
    rollback to create_partial_user_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_partial_user;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_user_byReferral >-----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_user_byReferral
   (p_user_name                 IN     varchar2
   ,p_password                  IN     varchar2
   ,p_start_date                IN     date
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_email                     IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
  ,p_last_name                    in     varchar2  default null
  ,p_first_name                   in     varchar2  default null
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_person_id                    in     number    default null
  ,p_return_status                OUT nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_user_byReferral';
Begin
  --hr_utility.trace_on(null,'VMUMMIDI');
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_user_swi;
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
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  irc_party_api.create_user_byReferral
    (p_user_name           => p_user_name
    ,p_password            => p_password
    ,p_start_date          => p_start_date
    ,p_responsibility_id   => p_responsibility_id
    ,p_resp_appl_id        => p_resp_appl_id
    ,p_security_group_id   => p_security_group_id
    ,p_email               => p_email
    ,p_language            => p_language
    ,p_last_name                    => p_last_name
    ,p_first_name                   => p_first_name
    ,p_per_information_category     => p_per_information_category
    ,p_per_information1             => p_per_information1
    ,p_per_information2             => p_per_information2
    ,p_per_information3             => p_per_information3
    ,p_per_information4             => p_per_information4
    ,p_per_information5             => p_per_information5
    ,p_per_information6             => p_per_information6
    ,p_per_information7             => p_per_information7
    ,p_per_information8             => p_per_information8
    ,p_per_information9             => p_per_information9
    ,p_per_information10            => p_per_information10
    ,p_per_information11            => p_per_information11
    ,p_per_information12            => p_per_information12
    ,p_per_information13            => p_per_information13
    ,p_per_information14            => p_per_information14
    ,p_per_information15            => p_per_information15
    ,p_per_information16            => p_per_information16
    ,p_per_information17            => p_per_information17
    ,p_per_information18            => p_per_information18
    ,p_per_information19            => p_per_information19
    ,p_per_information20            => p_per_information20
    ,p_per_information21            => p_per_information21
    ,p_per_information22            => p_per_information22
    ,p_per_information23            => p_per_information23
    ,p_per_information24            => p_per_information24
    ,p_per_information25            => p_per_information25
    ,p_per_information26            => p_per_information26
    ,p_per_information27            => p_per_information27
    ,p_per_information28            => p_per_information28
    ,p_per_information29            => p_per_information29
    ,p_per_information30            => p_per_information30
    ,p_person_id                    => p_person_id
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
    rollback to create_user_swi;
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
    rollback to create_user_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_user_byReferral;
--
end irc_party_swi;

/
