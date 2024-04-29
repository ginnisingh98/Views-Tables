--------------------------------------------------------
--  DDL for Package Body HR_COMP_ELEMENT_OUTCOME_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMP_ELEMENT_OUTCOME_SWI" As
/* $Header: hrceoswi.pkb 120.0 2005/09/30 00:34 hpandya noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_comp_element_outcome_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_element_outcome >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_element_outcome
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_competence_element_id        in     number
  ,p_outcome_id                   in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date      default null
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
  ,p_information_category         in     varchar2  default null
  ,p_information1                 in     varchar2  default null
  ,p_information2                 in     varchar2  default null
  ,p_information3                 in     varchar2  default null
  ,p_information4                 in     varchar2  default null
  ,p_information5                 in     varchar2  default null
  ,p_information6                 in     varchar2  default null
  ,p_information7                 in     varchar2  default null
  ,p_information8                 in     varchar2  default null
  ,p_information9                 in     varchar2  default null
  ,p_information10                in     varchar2  default null
  ,p_information11                in     varchar2  default null
  ,p_information12                in     varchar2  default null
  ,p_information13                in     varchar2  default null
  ,p_information14                in     varchar2  default null
  ,p_information15                in     varchar2  default null
  ,p_information16                in     varchar2  default null
  ,p_information17                in     varchar2  default null
  ,p_information18                in     varchar2  default null
  ,p_information19                in     varchar2  default null
  ,p_information20                in     varchar2  default null
  ,p_comp_element_outcome_id      in     number
  ,p_object_version_number        out nocopy number
  ,p_return_status                out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_competence_element_id         number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_comp_element_outcome_id      number;
  l_proc    varchar2(72) := g_package ||'create_element_outcome';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_element_outcome_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
   -- Heena: In Enter New Level of competency, Outcome can be in Create as well as Update mode.
   if (( HR_COMPETENCE_ELEMENT_SWI.g_competence_element_id is not null) and
                (HR_COMPETENCE_ELEMENT_SWI.g_session_id= ICX_SEC.G_SESSION_ID)) then
         l_competence_element_id := HR_COMPETENCE_ELEMENT_SWI.g_competence_element_id;
   else
         l_competence_element_id := p_competence_element_id;
   end if;
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
  if p_comp_element_outcome_id is not null then
    per_ceo_ins.set_base_key_value
      (p_comp_element_outcome_id => p_comp_element_outcome_id
      );
  end if;
  --
  -- Call API
  --
  hr_comp_element_outcome_api.create_element_outcome
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_competence_element_id        => l_competence_element_id
    ,p_outcome_id                   => p_outcome_id
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
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
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    ,p_comp_element_outcome_id      => l_comp_element_outcome_id
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
    rollback to create_element_outcome_swi;
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
    rollback to create_element_outcome_swi;
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
end create_element_outcome;
-- ----------------------------------------------------------------------------
-- |------------------------< update_element_outcome >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_element_outcome
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_comp_element_outcome_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_competence_element_id        in     number    default hr_api.g_number
  ,p_outcome_id                   in     number    default hr_api.g_number
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
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
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_return_status                out nocopy varchar2
--   ,p_datetrack_update_mode        in     varchar2  default hr_api.g_correction
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_competence_element_id       number;
  l_comp_element_outcome_id     number;
  l_effective_date_to           date;
  l_datetrack_update_mode       varchar2(10);
  l_proc    varchar2(72)       := g_package ||'update_element_outcome';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_element_outcome_swi;
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
  -- Heena : Evaluating the possibility of not using p_datetrack_update_mode.
  -- Heena: In Enter New Level of competency, Outcome can be in Create as well as Update mode.
   if (( HR_COMPETENCE_ELEMENT_SWI.g_competence_element_id is not null) and
                (HR_COMPETENCE_ELEMENT_SWI.g_session_id= ICX_SEC.G_SESSION_ID)) then
         l_competence_element_id := HR_COMPETENCE_ELEMENT_SWI.g_competence_element_id;
         l_datetrack_update_mode := 'UPDATE';
   else
         l_competence_element_id := p_competence_element_id;
         l_datetrack_update_mode := 'CORRECT';
   end if;

  if ( l_datetrack_update_mode = 'CORRECT') then

  hr_comp_element_outcome_api.update_element_outcome
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_comp_element_outcome_id      => p_comp_element_outcome_id
    ,p_object_version_number        => p_object_version_number
    ,p_competence_element_id        => p_competence_element_id
    ,p_outcome_id                   => p_outcome_id
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
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
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    );

/*  hr_comp_element_outcome_api.update_element_outcome
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_comp_element_outcome_id      => p_comp_element_outcome_id
    ,p_object_version_number        => p_object_version_number
    ,p_competence_element_id        => p_competence_element_id
    ,p_outcome_id                   => p_outcome_id
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
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
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    );*/
 else -- if  (p_datetrack_update_mode =hr_api.g_update) then
   -- Heena: We do not end date the outcode.
   -- We want to maintain history by end-dating the previous row and  inserting a new Row.
   -- This is date Track update
     -- l_effective_date_to:=p_date_from - 1;
     -- End-date the existing row
     /*hr_comp_element_outcome_api.update_element_outcome(
      p_comp_element_outcome_id      => p_comp_element_outcome_id
     ,p_object_version_number        => p_object_version_number
     ,p_date_to                      =>l_effective_date_to
     ,p_effective_date               => p_effective_date
     );*/
    --  Add new row
     hr_comp_element_outcome_api.create_element_outcome
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_competence_element_id        => l_competence_element_id
    ,p_outcome_id                   => p_outcome_id
    ,p_date_from                    => p_date_from
    ,p_date_to                      =>  p_date_to
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
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_information11                => p_information11
    ,p_information12                => p_information12
    ,p_information13                => p_information13
    ,p_information14                => p_information14
    ,p_information15                => p_information15
    ,p_information16                => p_information16
    ,p_information17                => p_information17
    ,p_information18                => p_information18
    ,p_information19                => p_information19
    ,p_information20                => p_information20
    ,p_comp_element_outcome_id      => l_comp_element_outcome_id
    ,p_object_version_number        => p_object_version_number
   );
   end if;

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
    rollback to update_element_outcome_swi;
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
    rollback to update_element_outcome_swi;
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
end update_element_outcome;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_element_outcome >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_element_outcome
  (p_validate                     in     number
  ,p_comp_element_outcome_id      in     number
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
  l_proc    varchar2(72) := g_package ||'delete_element_outcome';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_element_outcome_swi;
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
  hr_comp_element_outcome_api.delete_element_outcome
    (p_validate                     => l_validate
    ,p_comp_element_outcome_id      => p_comp_element_outcome_id
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
    rollback to delete_element_outcome_swi;
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
    rollback to delete_element_outcome_swi;
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
end delete_element_outcome;

Procedure process_api
( p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState VARCHAR2(2);
   l_return_status VARCHAR2(1);
   l_commitElement xmldom.DOMElement;
   l_object_version_number number;
   l_parser xmlparser.Parser;
   l_CommitNode xmldom.DOMNode;
   l_proc    varchar2(72) := g_package || 'process_api';

BEGIN

   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);

   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));

   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');
   l_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');

   if l_postState = '0' then

	 create_element_outcome
	(p_validate                     => p_validate
	,p_effective_date               => p_effective_date
	,p_competence_element_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'CompetenceElementId',null)
	,p_outcome_id                   => hr_transaction_swi.getNumberValue(l_CommitNode,'OutcomeId',null)
	,p_date_from                    => hr_transaction_swi.getDateValue(l_CommitNode,'DateFrom',null)
	,p_date_to                      => hr_transaction_swi.getDateValue(l_CommitNode,'DateTo',null)
	,p_attribute_category           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',null)
	,p_attribute1                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',null)
	,p_attribute2                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',null)
	,p_attribute3                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',null)
	,p_attribute4                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',null)
	,p_attribute5                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',null)
	,p_attribute6                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',null)
	,p_attribute7                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',null)
	,p_attribute8                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',null)
	,p_attribute9                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',null)
	,p_attribute10                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',null)
	,p_attribute11                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',null)
	,p_attribute12                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',null)
	,p_attribute13                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',null)
	,p_attribute14                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',null)
	,p_attribute15                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',null)
	,p_attribute16                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',null)
	,p_attribute17                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',null)
	,p_attribute18                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',null)
	,p_attribute19                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',null)
	,p_attribute20                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',null)
	,p_information_category         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'InformationCategory',null)
	,p_information1                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information1',null)
	,p_information2                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information2',null)
	,p_information3                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information3',null)
	,p_information4                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information4',null)
	,p_information5                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information5',null)
	,p_information6                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information6',null)
	,p_information7                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information7',null)
	,p_information8                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information8',null)
	,p_information9                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information9',null)
	,p_information10                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information10',null)
	,p_information11                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information11',null)
	,p_information12                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information12',null)
	,p_information13                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information13',null)
	,p_information14                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information14',null)
	,p_information15                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information15',null)
	,p_information16                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information16',null)
	,p_information17                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information17',null)
	,p_information18                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information18',null)
	,p_information19                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information19',null)
	,p_information20                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information20',null)
	,p_comp_element_outcome_id      => hr_transaction_swi.getNumberValue(l_CommitNode,'CompElementOutcomeId',null)
	,p_object_version_number        => l_object_version_number
	,p_return_status                => l_return_status
	);
   elsif l_postState = '2' then
	  update_element_outcome
	  (p_validate                     =>     p_validate
	  ,p_effective_date               =>     p_effective_date
	  ,p_comp_element_outcome_id      =>     hr_transaction_swi.getNumberValue(l_CommitNode,'CompElementOutcomeId')
	  ,p_object_version_number        =>     l_object_version_number
	  ,p_competence_element_id        =>     hr_transaction_swi.getNumberValue(l_CommitNode,'CompetenceElementId')
	  ,p_outcome_id                   =>     hr_transaction_swi.getNumberValue(l_CommitNode,'OutcomeId')
	  ,p_date_from                    =>     hr_transaction_swi.getDateValue(l_CommitNode,'DateFrom')
	  ,p_date_to                      =>     hr_transaction_swi.getDateValue(l_CommitNode,'DateTo')
	  ,p_attribute_category           =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory')
	  ,p_attribute1                   =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1')
	  ,p_attribute2                   =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2')
	  ,p_attribute3                   =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3')
	  ,p_attribute4                   =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4')
	  ,p_attribute5                   =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5')
	  ,p_attribute6                   =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6')
	  ,p_attribute7                   =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7')
	  ,p_attribute8                   =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8')
	  ,p_attribute9                   =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9')
	  ,p_attribute10                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10')
	  ,p_attribute11                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11')
	  ,p_attribute12                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12')
	  ,p_attribute13                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13')
	  ,p_attribute14                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14')
	  ,p_attribute15                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15')
	  ,p_attribute16                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16')
	  ,p_attribute17                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17')
	  ,p_attribute18                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18')
	  ,p_attribute19                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19')
	  ,p_attribute20                  =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20')
	  ,p_information_category         =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'InformationCategory')
	  ,p_information1                 =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information1')
	  ,p_information2                 =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information2')
	  ,p_information3                 =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information3')
	  ,p_information4                 =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information4')
	  ,p_information5                 =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information5')
	  ,p_information6                 =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information6')
	  ,p_information7                 =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information7')
	  ,p_information8                 =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information8')
	  ,p_information9                 =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information9')
	  ,p_information10                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information10')
	  ,p_information11                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information11')
	  ,p_information12                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information12')
	  ,p_information13                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information13')
	  ,p_information14                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information14')
	  ,p_information15                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information15')
	  ,p_information16                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information16')
	  ,p_information17                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information17')
	  ,p_information18                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information18')
	  ,p_information19                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information19')
	  ,p_information20                =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information20')
	  ,p_return_status                =>     l_return_status
--	  ,p_datetrack_update_mode        =>     hr_transaction_swi.getVarchar2Value(l_CommitNode,'DatetrackUpdate',hr_api.g_correction)
	  );

   elsif l_postState = '3' then

    delete_element_outcome
    (p_validate                     => p_validate
    ,p_comp_element_outcome_id      => hr_transaction_swi.getNumberValue(l_CommitNode,'CompElementOutcomeId')
    ,p_object_version_number        => l_object_version_number
    ,p_return_status                => l_return_status
    );

   end if;

   p_return_status := l_return_status;

   hr_utility.set_location('Exiting:' || l_proc,40);


END process_api;

end hr_comp_element_outcome_swi;

/
