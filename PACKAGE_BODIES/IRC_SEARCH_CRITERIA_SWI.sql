--------------------------------------------------------
--  DDL for Package Body IRC_SEARCH_CRITERIA_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_SEARCH_CRITERIA_SWI" As
/* $Header: iriscswi.pkb 120.1 2006/03/13 02:34:15 cnholmes noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_search_criteria_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_saved_search >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_saved_search
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_search_name                  in     varchar2
  ,p_location                     in     varchar2  default null
  ,p_distance_to_location         in     varchar2  default null
  ,p_geocode_location             in     varchar2 default null
  ,p_geocode_country              in     varchar2 default null
  ,p_derived_location             in     varchar2 default null
  ,p_location_id                  in     number   default null
  ,p_longitude                    in     number   default null
  ,p_latitude                     in     number   default null
  ,p_employee                     in     varchar2  default null
  ,p_contractor                   in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_travel_percentage            in     number    default null
  ,p_min_salary                   in     number    default null
  ,p_salary_currency              in     varchar2  default null
  ,p_salary_period                in     varchar2  default null
  ,p_match_competence             in     varchar2  default null
  ,p_match_qualification          in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_title                    in     varchar2  default null
  ,p_department                   in     varchar2  default null
  ,p_professional_area            in     varchar2  default null
  ,p_use_for_matching             in     varchar2  default null
  ,p_description                  in     varchar2  default null
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
  ,p_isc_information_category     in     varchar2  default null
  ,p_isc_information1             in     varchar2  default null
  ,p_isc_information2             in     varchar2  default null
  ,p_isc_information3             in     varchar2  default null
  ,p_isc_information4             in     varchar2  default null
  ,p_isc_information5             in     varchar2  default null
  ,p_isc_information6             in     varchar2  default null
  ,p_isc_information7             in     varchar2  default null
  ,p_isc_information8             in     varchar2  default null
  ,p_isc_information9             in     varchar2  default null
  ,p_isc_information10            in     varchar2  default null
  ,p_isc_information11            in     varchar2  default null
  ,p_isc_information12            in     varchar2  default null
  ,p_isc_information13            in     varchar2  default null
  ,p_isc_information14            in     varchar2  default null
  ,p_isc_information15            in     varchar2  default null
  ,p_isc_information16            in     varchar2  default null
  ,p_isc_information17            in     varchar2  default null
  ,p_isc_information18            in     varchar2  default null
  ,p_isc_information19            in     varchar2  default null
  ,p_isc_information20            in     varchar2  default null
  ,p_isc_information21            in     varchar2  default null
  ,p_isc_information22            in     varchar2  default null
  ,p_isc_information23            in     varchar2  default null
  ,p_isc_information24            in     varchar2  default null
  ,p_isc_information25            in     varchar2  default null
  ,p_isc_information26            in     varchar2  default null
  ,p_isc_information27            in     varchar2  default null
  ,p_isc_information28            in     varchar2  default null
  ,p_isc_information29            in     varchar2  default null
  ,p_isc_information30            in     varchar2  default null
  ,p_date_posted                  in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_search_criteria_id           in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_search_criteria_id           number;
  l_proc    varchar2(72) := g_package ||'create_saved_search';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_saved_search_swi;
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
  irc_isc_ins.set_base_key_value
    (p_search_criteria_id => p_search_criteria_id
    );
  --
  -- Call API
  --
  irc_search_criteria_api.create_saved_search
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    ,p_search_name                  => p_search_name
    ,p_location                     => p_location
    ,p_distance_to_location         => p_distance_to_location
    ,p_geocode_location             => p_geocode_location
    ,p_geocode_country              => p_geocode_country
    ,p_derived_location             => p_derived_location
    ,p_location_id                  => p_location_id
    ,p_longitude                    => p_longitude
    ,p_latitude                     => p_latitude
    ,p_employee                     => p_employee
    ,p_contractor                   => p_contractor
    ,p_employment_category          => p_employment_category
    ,p_keywords                     => p_keywords
    ,p_travel_percentage            => p_travel_percentage
    ,p_min_salary                   => p_min_salary
    ,p_salary_currency              => p_salary_currency
    ,p_salary_period                => p_salary_period
    ,p_match_competence             => p_match_competence
    ,p_match_qualification          => p_match_qualification
    ,p_work_at_home                 => p_work_at_home
    ,p_job_title                    => p_job_title
    ,p_department                   => p_department
    ,p_professional_area            => p_professional_area
    ,p_use_for_matching             => p_use_for_matching
    ,p_description                  => p_description
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
    ,p_isc_information_category     => p_isc_information_category
    ,p_isc_information1             => p_isc_information1
    ,p_isc_information2             => p_isc_information2
    ,p_isc_information3             => p_isc_information3
    ,p_isc_information4             => p_isc_information4
    ,p_isc_information5             => p_isc_information5
    ,p_isc_information6             => p_isc_information6
    ,p_isc_information7             => p_isc_information7
    ,p_isc_information8             => p_isc_information8
    ,p_isc_information9             => p_isc_information9
    ,p_isc_information10            => p_isc_information10
    ,p_isc_information11            => p_isc_information11
    ,p_isc_information12            => p_isc_information12
    ,p_isc_information13            => p_isc_information13
    ,p_isc_information14            => p_isc_information14
    ,p_isc_information15            => p_isc_information15
    ,p_isc_information16            => p_isc_information16
    ,p_isc_information17            => p_isc_information17
    ,p_isc_information18            => p_isc_information18
    ,p_isc_information19            => p_isc_information19
    ,p_isc_information20            => p_isc_information20
    ,p_isc_information21            => p_isc_information21
    ,p_isc_information22            => p_isc_information22
    ,p_isc_information23            => p_isc_information23
    ,p_isc_information24            => p_isc_information24
    ,p_isc_information25            => p_isc_information25
    ,p_isc_information26            => p_isc_information26
    ,p_isc_information27            => p_isc_information27
    ,p_isc_information28            => p_isc_information28
    ,p_isc_information29            => p_isc_information29
    ,p_isc_information30            => p_isc_information30
    ,p_date_posted                  => p_date_posted
    ,p_object_version_number        => p_object_version_number
    ,p_search_criteria_id           => l_search_criteria_id
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
    rollback to create_saved_search_swi;
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
    rollback to create_saved_search_swi;
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
end create_saved_search;
-- ----------------------------------------------------------------------------
-- |------------------------< create_vacancy_criteria >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_vacancy_criteria
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_vacancy_id                   in     number
  ,p_effective_date               in     date
  ,p_location                     in     varchar2  default null
  ,p_employee                     in     varchar2  default null
  ,p_contractor                   in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_travel_percentage            in     number    default null
  ,p_min_salary                   in     number    default null
  ,p_max_salary                   in     number    default null
  ,p_salary_currency              in     varchar2  default null
  ,p_salary_period                in     varchar2  default null
  ,p_professional_area            in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_min_qual_level               in     number    default null
  ,p_max_qual_level               in     number    default null
  ,p_description                  in     varchar2  default null
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
  ,p_isc_information_category     in     varchar2  default null
  ,p_isc_information1             in     varchar2  default null
  ,p_isc_information2             in     varchar2  default null
  ,p_isc_information3             in     varchar2  default null
  ,p_isc_information4             in     varchar2  default null
  ,p_isc_information5             in     varchar2  default null
  ,p_isc_information6             in     varchar2  default null
  ,p_isc_information7             in     varchar2  default null
  ,p_isc_information8             in     varchar2  default null
  ,p_isc_information9             in     varchar2  default null
  ,p_isc_information10            in     varchar2  default null
  ,p_isc_information11            in     varchar2  default null
  ,p_isc_information12            in     varchar2  default null
  ,p_isc_information13            in     varchar2  default null
  ,p_isc_information14            in     varchar2  default null
  ,p_isc_information15            in     varchar2  default null
  ,p_isc_information16            in     varchar2  default null
  ,p_isc_information17            in     varchar2  default null
  ,p_isc_information18            in     varchar2  default null
  ,p_isc_information19            in     varchar2  default null
  ,p_isc_information20            in     varchar2  default null
  ,p_isc_information21            in     varchar2  default null
  ,p_isc_information22            in     varchar2  default null
  ,p_isc_information23            in     varchar2  default null
  ,p_isc_information24            in     varchar2  default null
  ,p_isc_information25            in     varchar2  default null
  ,p_isc_information26            in     varchar2  default null
  ,p_isc_information27            in     varchar2  default null
  ,p_isc_information28            in     varchar2  default null
  ,p_isc_information29            in     varchar2  default null
  ,p_isc_information30            in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_search_criteria_id           in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_search_criteria_id           number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_vacancy_criteria';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_vacancy_criteria_swi;
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
  irc_isc_ins.set_base_key_value
    (p_search_criteria_id => p_search_criteria_id
    );
  --
  -- Call API
  --
  irc_search_criteria_api.create_vacancy_criteria
    (p_validate                     => l_validate
    ,p_vacancy_id                   => p_vacancy_id
    ,p_effective_date               => p_effective_date
    ,p_location                     => p_location
    ,p_employee                     => p_employee
    ,p_contractor                   => p_contractor
    ,p_employment_category          => p_employment_category
    ,p_keywords                     => p_keywords
    ,p_travel_percentage            => p_travel_percentage
    ,p_min_salary                   => p_min_salary
    ,p_max_salary                   => p_max_salary
    ,p_salary_currency              => p_salary_currency
    ,p_salary_period                => p_salary_period
    ,p_professional_area            => p_professional_area
    ,p_work_at_home                 => p_work_at_home
    ,p_min_qual_level               => p_min_qual_level
    ,p_max_qual_level               => p_max_qual_level
    ,p_description                  => p_description
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
    ,p_isc_information_category     => p_isc_information_category
    ,p_isc_information1             => p_isc_information1
    ,p_isc_information2             => p_isc_information2
    ,p_isc_information3             => p_isc_information3
    ,p_isc_information4             => p_isc_information4
    ,p_isc_information5             => p_isc_information5
    ,p_isc_information6             => p_isc_information6
    ,p_isc_information7             => p_isc_information7
    ,p_isc_information8             => p_isc_information8
    ,p_isc_information9             => p_isc_information9
    ,p_isc_information10            => p_isc_information10
    ,p_isc_information11            => p_isc_information11
    ,p_isc_information12            => p_isc_information12
    ,p_isc_information13            => p_isc_information13
    ,p_isc_information14            => p_isc_information14
    ,p_isc_information15            => p_isc_information15
    ,p_isc_information16            => p_isc_information16
    ,p_isc_information17            => p_isc_information17
    ,p_isc_information18            => p_isc_information18
    ,p_isc_information19            => p_isc_information19
    ,p_isc_information20            => p_isc_information20
    ,p_isc_information21            => p_isc_information21
    ,p_isc_information22            => p_isc_information22
    ,p_isc_information23            => p_isc_information23
    ,p_isc_information24            => p_isc_information24
    ,p_isc_information25            => p_isc_information25
    ,p_isc_information26            => p_isc_information26
    ,p_isc_information27            => p_isc_information27
    ,p_isc_information28            => p_isc_information28
    ,p_isc_information29            => p_isc_information29
    ,p_isc_information30            => p_isc_information30
    ,p_object_version_number        => p_object_version_number
    ,p_search_criteria_id           => l_search_criteria_id
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
    rollback to create_vacancy_criteria_swi;
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
    rollback to create_vacancy_criteria_swi;
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
end create_vacancy_criteria;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_saved_search >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_saved_search
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_search_criteria_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_saved_search';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_saved_search_swi;
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
  irc_search_criteria_api.delete_saved_search
    (p_validate                     => l_validate
    ,p_search_criteria_id           => p_search_criteria_id
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
    rollback to delete_saved_search_swi;
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
    rollback to delete_saved_search_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_saved_search;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_vacancy_criteria >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_vacancy_criteria
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_search_criteria_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_vacancy_criteria';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vacancy_criteria_swi;
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
  irc_search_criteria_api.delete_vacancy_criteria
    (p_validate                     => l_validate
    ,p_search_criteria_id           => p_search_criteria_id
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
    rollback to delete_vacancy_criteria_swi;
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
    rollback to delete_vacancy_criteria_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_vacancy_criteria;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_saved_search >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_saved_search
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_search_criteria_id           in     number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_search_name                  in     varchar2  default hr_api.g_varchar2
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_distance_to_location         in     varchar2  default hr_api.g_varchar2
  ,p_geocode_location             in     varchar2  default hr_api.g_varchar2
  ,p_geocode_country              in     varchar2  default hr_api.g_varchar2
  ,p_derived_location             in     varchar2  default hr_api.g_varchar2
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_longitude                    in     number    default hr_api.g_number
  ,p_latitude                     in     number    default hr_api.g_number
  ,p_employee                     in     varchar2  default hr_api.g_varchar2
  ,p_contractor                   in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_travel_percentage            in     number    default hr_api.g_number
  ,p_min_salary                   in     number    default hr_api.g_number
  ,p_salary_currency              in     varchar2  default hr_api.g_varchar2
  ,p_salary_period                in     varchar2  default hr_api.g_varchar2
  ,p_match_competence             in     varchar2  default hr_api.g_varchar2
  ,p_match_qualification          in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_job_title                    in     varchar2  default hr_api.g_varchar2
  ,p_department                   in     varchar2  default hr_api.g_varchar2
  ,p_professional_area            in     varchar2  default hr_api.g_varchar2
  ,p_use_for_matching             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
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
  ,p_isc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_isc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information30            in     varchar2  default hr_api.g_varchar2
  ,p_date_posted                  in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_saved_search';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_saved_search_swi;
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
  irc_search_criteria_api.update_saved_search
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_search_criteria_id           => p_search_criteria_id
    ,p_person_id                    => p_person_id
    ,p_search_name                  => p_search_name
    ,p_location                     => p_location
    ,p_distance_to_location         => p_distance_to_location
    ,p_geocode_location             => p_geocode_location
    ,p_geocode_country              => p_geocode_country
    ,p_derived_location             => p_derived_location
    ,p_location_id                  => p_location_id
    ,p_longitude                    => p_longitude
    ,p_latitude                     => p_latitude
    ,p_employee                     => p_employee
    ,p_contractor                   => p_contractor
    ,p_employment_category          => p_employment_category
    ,p_keywords                     => p_keywords
    ,p_travel_percentage            => p_travel_percentage
    ,p_min_salary                   => p_min_salary
    ,p_salary_currency              => p_salary_currency
    ,p_salary_period                => p_salary_period
    ,p_match_competence             => p_match_competence
    ,p_match_qualification          => p_match_qualification
    ,p_work_at_home                 => p_work_at_home
    ,p_job_title                    => p_job_title
    ,p_department                   => p_department
    ,p_professional_area            => p_professional_area
    ,p_use_for_matching             => p_use_for_matching
    ,p_description                  => p_description
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
    ,p_isc_information_category     => p_isc_information_category
    ,p_isc_information1             => p_isc_information1
    ,p_isc_information2             => p_isc_information2
    ,p_isc_information3             => p_isc_information3
    ,p_isc_information4             => p_isc_information4
    ,p_isc_information5             => p_isc_information5
    ,p_isc_information6             => p_isc_information6
    ,p_isc_information7             => p_isc_information7
    ,p_isc_information8             => p_isc_information8
    ,p_isc_information9             => p_isc_information9
    ,p_isc_information10            => p_isc_information10
    ,p_isc_information11            => p_isc_information11
    ,p_isc_information12            => p_isc_information12
    ,p_isc_information13            => p_isc_information13
    ,p_isc_information14            => p_isc_information14
    ,p_isc_information15            => p_isc_information15
    ,p_isc_information16            => p_isc_information16
    ,p_isc_information17            => p_isc_information17
    ,p_isc_information18            => p_isc_information18
    ,p_isc_information19            => p_isc_information19
    ,p_isc_information20            => p_isc_information20
    ,p_isc_information21            => p_isc_information21
    ,p_isc_information22            => p_isc_information22
    ,p_isc_information23            => p_isc_information23
    ,p_isc_information24            => p_isc_information24
    ,p_isc_information25            => p_isc_information25
    ,p_isc_information26            => p_isc_information26
    ,p_isc_information27            => p_isc_information27
    ,p_isc_information28            => p_isc_information28
    ,p_isc_information29            => p_isc_information29
    ,p_isc_information30            => p_isc_information30
    ,p_date_posted                  => p_date_posted
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
    rollback to update_saved_search_swi;
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
    rollback to update_saved_search_swi;
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
end update_saved_search;
-- ----------------------------------------------------------------------------
-- |------------------------< update_vacancy_criteria >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_vacancy_criteria
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_search_criteria_id           in     number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_effective_date               in     date
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_employee                     in     varchar2  default hr_api.g_varchar2
  ,p_contractor                   in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_travel_percentage            in     number    default hr_api.g_number
  ,p_min_salary                   in     number    default hr_api.g_number
  ,p_max_salary                   in     number    default hr_api.g_number
  ,p_salary_currency              in     varchar2  default hr_api.g_varchar2
  ,p_salary_period                in     varchar2  default hr_api.g_varchar2
  ,p_professional_area            in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_min_qual_level               in     number    default hr_api.g_number
  ,p_max_qual_level               in     number    default hr_api.g_number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
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
  ,p_isc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_isc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information30            in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_vacancy_criteria';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_vacancy_criteria_swi;
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
  irc_search_criteria_api.update_vacancy_criteria
    (p_validate                     => l_validate
    ,p_search_criteria_id           => p_search_criteria_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_effective_date               => p_effective_date
    ,p_location                     => p_location
    ,p_employee                     => p_employee
    ,p_contractor                   => p_contractor
    ,p_employment_category          => p_employment_category
    ,p_keywords                     => p_keywords
    ,p_travel_percentage            => p_travel_percentage
    ,p_min_salary                   => p_min_salary
    ,p_max_salary                   => p_max_salary
    ,p_salary_currency              => p_salary_currency
    ,p_salary_period                => p_salary_period
    ,p_professional_area            => p_professional_area
    ,p_work_at_home                 => p_work_at_home
    ,p_min_qual_level               => p_min_qual_level
    ,p_max_qual_level               => p_max_qual_level
    ,p_description                  => p_description
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
    ,p_isc_information_category     => p_isc_information_category
    ,p_isc_information1             => p_isc_information1
    ,p_isc_information2             => p_isc_information2
    ,p_isc_information3             => p_isc_information3
    ,p_isc_information4             => p_isc_information4
    ,p_isc_information5             => p_isc_information5
    ,p_isc_information6             => p_isc_information6
    ,p_isc_information7             => p_isc_information7
    ,p_isc_information8             => p_isc_information8
    ,p_isc_information9             => p_isc_information9
    ,p_isc_information10            => p_isc_information10
    ,p_isc_information11            => p_isc_information11
    ,p_isc_information12            => p_isc_information12
    ,p_isc_information13            => p_isc_information13
    ,p_isc_information14            => p_isc_information14
    ,p_isc_information15            => p_isc_information15
    ,p_isc_information16            => p_isc_information16
    ,p_isc_information17            => p_isc_information17
    ,p_isc_information18            => p_isc_information18
    ,p_isc_information19            => p_isc_information19
    ,p_isc_information20            => p_isc_information20
    ,p_isc_information21            => p_isc_information21
    ,p_isc_information22            => p_isc_information22
    ,p_isc_information23            => p_isc_information23
    ,p_isc_information24            => p_isc_information24
    ,p_isc_information25            => p_isc_information25
    ,p_isc_information26            => p_isc_information26
    ,p_isc_information27            => p_isc_information27
    ,p_isc_information28            => p_isc_information28
    ,p_isc_information29            => p_isc_information29
    ,p_isc_information30            => p_isc_information30
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
    rollback to update_vacancy_criteria_swi;
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
    rollback to update_vacancy_criteria_swi;
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
end update_vacancy_criteria;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_work_choices >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_work_choices
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_location                     in     varchar2  default null
  ,p_distance_to_location         in     varchar2  default null
  ,p_geocode_location             in     varchar2  default null
  ,p_geocode_country              in     varchar2  default null
  ,p_derived_location             in     varchar2  default null
  ,p_location_id                  in     number    default null
  ,p_longitude                    in     number    default null
  ,p_latitude                     in     number    default null
  ,p_employee                     in     varchar2  default null
  ,p_contractor                   in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_travel_percentage            in     number    default null
  ,p_min_salary                   in     number    default null
  ,p_salary_currency              in     varchar2  default null
  ,p_salary_period                in     varchar2  default null
  ,p_match_competence             in     varchar2  default null
  ,p_match_qualification          in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_title                    in     varchar2  default null
  ,p_department                   in     varchar2  default null
  ,p_professional_area            in     varchar2  default null
  ,p_description                  in     varchar2  default null
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
  ,p_isc_information_category     in     varchar2  default null
  ,p_isc_information1             in     varchar2  default null
  ,p_isc_information2             in     varchar2  default null
  ,p_isc_information3             in     varchar2  default null
  ,p_isc_information4             in     varchar2  default null
  ,p_isc_information5             in     varchar2  default null
  ,p_isc_information6             in     varchar2  default null
  ,p_isc_information7             in     varchar2  default null
  ,p_isc_information8             in     varchar2  default null
  ,p_isc_information9             in     varchar2  default null
  ,p_isc_information10            in     varchar2  default null
  ,p_isc_information11            in     varchar2  default null
  ,p_isc_information12            in     varchar2  default null
  ,p_isc_information13            in     varchar2  default null
  ,p_isc_information14            in     varchar2  default null
  ,p_isc_information15            in     varchar2  default null
  ,p_isc_information16            in     varchar2  default null
  ,p_isc_information17            in     varchar2  default null
  ,p_isc_information18            in     varchar2  default null
  ,p_isc_information19            in     varchar2  default null
  ,p_isc_information20            in     varchar2  default null
  ,p_isc_information21            in     varchar2  default null
  ,p_isc_information22            in     varchar2  default null
  ,p_isc_information23            in     varchar2  default null
  ,p_isc_information24            in     varchar2  default null
  ,p_isc_information25            in     varchar2  default null
  ,p_isc_information26            in     varchar2  default null
  ,p_isc_information27            in     varchar2  default null
  ,p_isc_information28            in     varchar2  default null
  ,p_isc_information29            in     varchar2  default null
  ,p_isc_information30            in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_search_criteria_id           in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_search_criteria_id           number;
  l_proc    varchar2(72) := g_package ||'create_work_choices';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_work_choices_swi;
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
  irc_isc_ins.set_base_key_value
    (p_search_criteria_id => p_search_criteria_id
    );
  --
  -- Call API
  --
  irc_search_criteria_api.create_work_choices
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    ,p_location                     => p_location
    ,p_distance_to_location         => p_distance_to_location
    ,p_geocode_location             => p_geocode_location
    ,p_geocode_country              => p_geocode_country
    ,p_derived_location             => p_derived_location
    ,p_location_id                  => p_location_id
    ,p_longitude                    => p_longitude
    ,p_latitude                     => p_latitude
    ,p_employee                     => p_employee
    ,p_contractor                   => p_contractor
    ,p_employment_category          => p_employment_category
    ,p_keywords                     => p_keywords
    ,p_travel_percentage            => p_travel_percentage
    ,p_min_salary                   => p_min_salary
    ,p_salary_currency              => p_salary_currency
    ,p_salary_period                => p_salary_period
    ,p_match_competence             => p_match_competence
    ,p_match_qualification          => p_match_qualification
    ,p_work_at_home                 => p_work_at_home
    ,p_job_title                    => p_job_title
    ,p_department                   => p_department
    ,p_professional_area            => p_professional_area
    ,p_description                  => p_description
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
    ,p_isc_information_category     => p_isc_information_category
    ,p_isc_information1             => p_isc_information1
    ,p_isc_information2             => p_isc_information2
    ,p_isc_information3             => p_isc_information3
    ,p_isc_information4             => p_isc_information4
    ,p_isc_information5             => p_isc_information5
    ,p_isc_information6             => p_isc_information6
    ,p_isc_information7             => p_isc_information7
    ,p_isc_information8             => p_isc_information8
    ,p_isc_information9             => p_isc_information9
    ,p_isc_information10            => p_isc_information10
    ,p_isc_information11            => p_isc_information11
    ,p_isc_information12            => p_isc_information12
    ,p_isc_information13            => p_isc_information13
    ,p_isc_information14            => p_isc_information14
    ,p_isc_information15            => p_isc_information15
    ,p_isc_information16            => p_isc_information16
    ,p_isc_information17            => p_isc_information17
    ,p_isc_information18            => p_isc_information18
    ,p_isc_information19            => p_isc_information19
    ,p_isc_information20            => p_isc_information20
    ,p_isc_information21            => p_isc_information21
    ,p_isc_information22            => p_isc_information22
    ,p_isc_information23            => p_isc_information23
    ,p_isc_information24            => p_isc_information24
    ,p_isc_information25            => p_isc_information25
    ,p_isc_information26            => p_isc_information26
    ,p_isc_information27            => p_isc_information27
    ,p_isc_information28            => p_isc_information28
    ,p_isc_information29            => p_isc_information29
    ,p_isc_information30            => p_isc_information30
    ,p_object_version_number        => p_object_version_number
    ,p_search_criteria_id           => l_search_criteria_id
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
    rollback to create_work_choices_swi;
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
    rollback to create_work_choices_swi;
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
end create_work_choices;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_work_choices >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_work_choices
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_search_criteria_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_work_choices';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_work_choices_swi;
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
  irc_search_criteria_api.delete_work_choices
    (p_validate                     => l_validate
    ,p_search_criteria_id           => p_search_criteria_id
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
    rollback to delete_work_choices_swi;
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
    rollback to delete_work_choices_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_work_choices;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_work_choices >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_work_choices
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_search_criteria_id           in     number
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_distance_to_location         in     varchar2  default hr_api.g_varchar2
  ,p_geocode_location             in     varchar2  default hr_api.g_varchar2
  ,p_geocode_country              in     varchar2  default hr_api.g_varchar2
  ,p_derived_location             in     varchar2  default hr_api.g_varchar2
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_longitude                    in     number    default hr_api.g_number
  ,p_latitude                     in     number    default hr_api.g_number
  ,p_employee                     in     varchar2  default hr_api.g_varchar2
  ,p_contractor                   in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_travel_percentage            in     number    default hr_api.g_number
  ,p_min_salary                   in     number    default hr_api.g_number
  ,p_salary_currency              in     varchar2  default hr_api.g_varchar2
  ,p_salary_period                in     varchar2  default hr_api.g_varchar2
  ,p_match_competence             in     varchar2  default hr_api.g_varchar2
  ,p_match_qualification          in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_job_title                    in     varchar2  default hr_api.g_varchar2
  ,p_department                   in     varchar2  default hr_api.g_varchar2
  ,p_professional_area            in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
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
  ,p_isc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_isc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information30            in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_work_choices';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_work_choices_swi;
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
  irc_search_criteria_api.update_work_choices
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_search_criteria_id           => p_search_criteria_id
    ,p_location                     => p_location
    ,p_distance_to_location         => p_distance_to_location
    ,p_geocode_location             => p_geocode_location
    ,p_geocode_country              => p_geocode_country
    ,p_derived_location             => p_derived_location
    ,p_location_id                  => p_location_id
    ,p_longitude                    => p_longitude
    ,p_latitude                     => p_latitude
    ,p_employee                     => p_employee
    ,p_contractor                   => p_contractor
    ,p_employment_category          => p_employment_category
    ,p_keywords                     => p_keywords
    ,p_travel_percentage            => p_travel_percentage
    ,p_min_salary                   => p_min_salary
    ,p_salary_currency              => p_salary_currency
    ,p_salary_period                => p_salary_period
    ,p_match_competence             => p_match_competence
    ,p_match_qualification          => p_match_qualification
    ,p_work_at_home                 => p_work_at_home
    ,p_job_title                    => p_job_title
    ,p_department                   => p_department
    ,p_professional_area            => p_professional_area
    ,p_description                  => p_description
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
    ,p_isc_information_category     => p_isc_information_category
    ,p_isc_information1             => p_isc_information1
    ,p_isc_information2             => p_isc_information2
    ,p_isc_information3             => p_isc_information3
    ,p_isc_information4             => p_isc_information4
    ,p_isc_information5             => p_isc_information5
    ,p_isc_information6             => p_isc_information6
    ,p_isc_information7             => p_isc_information7
    ,p_isc_information8             => p_isc_information8
    ,p_isc_information9             => p_isc_information9
    ,p_isc_information10            => p_isc_information10
    ,p_isc_information11            => p_isc_information11
    ,p_isc_information12            => p_isc_information12
    ,p_isc_information13            => p_isc_information13
    ,p_isc_information14            => p_isc_information14
    ,p_isc_information15            => p_isc_information15
    ,p_isc_information16            => p_isc_information16
    ,p_isc_information17            => p_isc_information17
    ,p_isc_information18            => p_isc_information18
    ,p_isc_information19            => p_isc_information19
    ,p_isc_information20            => p_isc_information20
    ,p_isc_information21            => p_isc_information21
    ,p_isc_information22            => p_isc_information22
    ,p_isc_information23            => p_isc_information23
    ,p_isc_information24            => p_isc_information24
    ,p_isc_information25            => p_isc_information25
    ,p_isc_information26            => p_isc_information26
    ,p_isc_information27            => p_isc_information27
    ,p_isc_information28            => p_isc_information28
    ,p_isc_information29            => p_isc_information29
    ,p_isc_information30            => p_isc_information30
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
    rollback to update_work_choices_swi;
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
    rollback to update_work_choices_swi;
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
end update_work_choices;

-- ----------------------------------------------------------------------------
-- |------------------------< process_vacancy_api >---------------------------|
-- ----------------------------------------------------------------------------

procedure process_vacancy_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState               VARCHAR2(2);
   l_return_status           VARCHAR2(1);
   l_object_version_number   number;
   l_search_criteria_id      number;
   l_commitElement           xmldom.DOMElement;
   l_parser                  xmlparser.Parser;
   l_CommitNode              xmldom.DOMNode;

   l_proc               varchar2(72)  := g_package || 'process_offers_api';
   l_effective_date     date          :=  trunc(sysdate);

BEGIN
--
   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);
--
   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));
--
   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');
--
--Get the values for in/out parameters
--
   l_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');
   l_search_criteria_id    := hr_transaction_swi.getNumberValue(l_CommitNode,'SearchCriteriaId');
--
   if p_effective_date is null then
     l_effective_date := trunc(sysdate);
   else
     l_effective_date := p_effective_date;
   end if;
--
   if l_postState = '0' then
--
   hr_utility.set_location('creating :' || l_proc,30);
     --
     create_vacancy_criteria
     (p_validate                   => p_validate
     ,p_vacancy_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectId',NULL)
     ,p_effective_date             => l_effective_date
     ,p_location                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Location',NULL)
     ,p_employee                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Employee',NULL)
     ,p_contractor                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Contractor',NULL)
     ,p_employment_category        => hr_transaction_swi.getVarchar2Value(l_CommitNode,'EmploymentCategory',NULL)
     ,p_keywords                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Keywords',NULL)
     ,p_travel_percentage          => hr_transaction_swi.getNumberValue(l_CommitNode,'TravelPercentage',NULL)
     ,p_min_salary                 => hr_transaction_swi.getNumberValue(l_CommitNode,'MinSalary',NULL)
     ,p_max_salary                 => hr_transaction_swi.getNumberValue(l_CommitNode,'MaxSalary',NULL)
     ,p_salary_currency            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SalaryCurrency',NULL)
     ,p_salary_period              => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SalaryPeriod',NULL)
     ,p_professional_area          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ProfessionalArea',NULL)
     ,p_work_at_home               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'WorkAtHome',NULL)
     ,p_min_qual_level             => hr_transaction_swi.getNumberValue(l_CommitNode,'MinQualLevel',NULL)
     ,p_max_qual_level             => hr_transaction_swi.getNumberValue(l_CommitNode,'MaxQualLevel',NULL)
     ,p_description                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Description',NULL)
     ,p_attribute_category         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',NULL)
     ,p_attribute1                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',NULL)
     ,p_attribute2                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',NULL)
     ,p_attribute3                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',NULL)
     ,p_attribute4                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',NULL)
     ,p_attribute5                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',NULL)
     ,p_attribute6                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',NULL)
     ,p_attribute7                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',NULL)
     ,p_attribute8                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',NULL)
     ,p_attribute9                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',NULL)
     ,p_attribute10                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',NULL)
     ,p_attribute11                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',NULL)
     ,p_attribute12                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',NULL)
     ,p_attribute13                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',NULL)
     ,p_attribute14                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',NULL)
     ,p_attribute15                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',NULL)
     ,p_attribute16                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',NULL)
     ,p_attribute17                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',NULL)
     ,p_attribute18                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',NULL)
     ,p_attribute19                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',NULL)
     ,p_attribute20                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',NULL)
     ,p_attribute21                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21',NULL)
     ,p_attribute22                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22',NULL)
     ,p_attribute23                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23',NULL)
     ,p_attribute24                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24',NULL)
     ,p_attribute25                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25',NULL)
     ,p_attribute26                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26',NULL)
     ,p_attribute27                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27',NULL)
     ,p_attribute28                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28',NULL)
     ,p_attribute29                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29',NULL)
     ,p_attribute30                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30',NULL)
     ,p_isc_information_category   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformationCategory',NULL)
     ,p_isc_information1           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation1',NULL)
     ,p_isc_information2           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation2',NULL)
     ,p_isc_information3           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation3',NULL)
     ,p_isc_information4           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation4',NULL)
     ,p_isc_information5           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation5',NULL)
     ,p_isc_information6           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation6',NULL)
     ,p_isc_information7           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation7',NULL)
     ,p_isc_information8           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation8',NULL)
     ,p_isc_information9           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation9',NULL)
     ,p_isc_information10          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation10',NULL)
     ,p_isc_information11          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation11',NULL)
     ,p_isc_information12          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation12',NULL)
     ,p_isc_information13          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation13',NULL)
     ,p_isc_information14          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation14',NULL)
     ,p_isc_information15          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation15',NULL)
     ,p_isc_information16          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation16',NULL)
     ,p_isc_information17          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation17',NULL)
     ,p_isc_information18          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation18',NULL)
     ,p_isc_information19          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation19',NULL)
     ,p_isc_information20          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation20',NULL)
     ,p_isc_information21          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation21',NULL)
     ,p_isc_information22          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation22',NULL)
     ,p_isc_information23          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation23',NULL)
     ,p_isc_information24          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation24',NULL)
     ,p_isc_information25          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation25',NULL)
     ,p_isc_information26          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation26',NULL)
     ,p_isc_information27          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation27',NULL)
     ,p_isc_information28          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation28',NULL)
     ,p_isc_information29          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation29',NULL)
     ,p_isc_information30          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation30',NULL)
     ,p_search_criteria_id         => l_search_criteria_id
     ,p_object_version_number      => l_object_version_number
     ,p_return_status              => l_return_status
     );
     --
   elsif l_postState = '2' then
--
   hr_utility.set_location('updating :' || l_proc,32);
     --
     update_vacancy_criteria
     (p_validate                  => p_validate
     ,p_effective_date            => l_effective_date
     ,p_search_criteria_id        => l_search_criteria_id
     ,p_vacancy_id                => hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectId',NULL)
     ,p_location                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Location',NULL)
     ,p_employee                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Employee',NULL)
     ,p_contractor                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Contractor',NULL)
     ,p_employment_category       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'EmploymentCategory',NULL)
     ,p_keywords                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Keywords',NULL)
     ,p_travel_percentage         => hr_transaction_swi.getNumberValue(l_CommitNode,'TravelPercentage',NULL)
     ,p_min_salary                => hr_transaction_swi.getNumberValue(l_CommitNode,'MinSalary',NULL)
     ,p_max_salary                => hr_transaction_swi.getNumberValue(l_CommitNode,'MaxSalary',NULL)
     ,p_salary_currency           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SalaryCurrency',NULL)
     ,p_salary_period             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SalaryPeriod',NULL)
     ,p_professional_area         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ProfessionalArea',NULL)
     ,p_work_at_home              => hr_transaction_swi.getVarchar2Value(l_CommitNode,'WorkAtHome',NULL)
     ,p_min_qual_level            => hr_transaction_swi.getNumberValue(l_CommitNode,'MinQualLevel',NULL)
     ,p_max_qual_level            => hr_transaction_swi.getNumberValue(l_CommitNode,'MaxQualLevel',NULL)
     ,p_description               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Description',NULL)
     ,p_attribute_category        => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',NULL)
     ,p_attribute1                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',NULL)
     ,p_attribute2                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',NULL)
     ,p_attribute3                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',NULL)
     ,p_attribute4                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',NULL)
     ,p_attribute5                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',NULL)
     ,p_attribute6                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',NULL)
     ,p_attribute7                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',NULL)
     ,p_attribute8                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',NULL)
     ,p_attribute9                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',NULL)
     ,p_attribute10               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',NULL)
     ,p_attribute11               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',NULL)
     ,p_attribute12               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',NULL)
     ,p_attribute13               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',NULL)
     ,p_attribute14               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',NULL)
     ,p_attribute15               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',NULL)
     ,p_attribute16               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',NULL)
     ,p_attribute17               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',NULL)
     ,p_attribute18               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',NULL)
     ,p_attribute19               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',NULL)
     ,p_attribute20               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',NULL)
     ,p_attribute21               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21',NULL)
     ,p_attribute22               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22',NULL)
     ,p_attribute23               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23',NULL)
     ,p_attribute24               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24',NULL)
     ,p_attribute25               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25',NULL)
     ,p_attribute26               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26',NULL)
     ,p_attribute27               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27',NULL)
     ,p_attribute28               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28',NULL)
     ,p_attribute29               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29',NULL)
     ,p_attribute30               => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30',NULL)
     ,p_isc_information_category  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformationCategory',NULL)
     ,p_isc_information1          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation1',NULL)
     ,p_isc_information2          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation2',NULL)
     ,p_isc_information3          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation3',NULL)
     ,p_isc_information4          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation4',NULL)
     ,p_isc_information5          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation5',NULL)
     ,p_isc_information6          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation6',NULL)
     ,p_isc_information7          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation7',NULL)
     ,p_isc_information8          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation8',NULL)
     ,p_isc_information9          => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation9',NULL)
     ,p_isc_information10         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation10',NULL)
     ,p_isc_information11         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation11',NULL)
     ,p_isc_information12         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation12',NULL)
     ,p_isc_information13         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation13',NULL)
     ,p_isc_information14         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation14',NULL)
     ,p_isc_information15         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation15',NULL)
     ,p_isc_information16         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation16',NULL)
     ,p_isc_information17         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation17',NULL)
     ,p_isc_information18         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation18',NULL)
     ,p_isc_information19         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation19',NULL)
     ,p_isc_information20         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation20',NULL)
     ,p_isc_information21         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation21',NULL)
     ,p_isc_information22         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation22',NULL)
     ,p_isc_information23         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation23',NULL)
     ,p_isc_information24         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation24',NULL)
     ,p_isc_information25         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation25',NULL)
     ,p_isc_information26         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation26',NULL)
     ,p_isc_information27         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation27',NULL)
     ,p_isc_information28         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation28',NULL)
     ,p_isc_information29         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation29',NULL)
     ,p_isc_information30         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'IscInformation30',NULL)
     ,p_object_version_number     => l_object_version_number
     ,p_return_status             => l_return_status
     );
     --
   elsif l_postState = '3' then
--
   hr_utility.set_location('deleting :' || l_proc,33);
     --
     delete_vacancy_criteria
     (p_validate               => p_validate
     ,p_object_version_number  => l_object_version_number
     ,p_search_criteria_id     => l_search_criteria_id
     ,p_return_status          => l_return_status
     );
     --
   end if;
   p_return_status := l_return_status;

   hr_utility.set_location
     ('Exiting :'|| l_proc || ': return status :'|| l_return_status || ':',40);
--
end process_vacancy_api;
--
end irc_search_criteria_swi;

/
