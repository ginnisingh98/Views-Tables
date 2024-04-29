--------------------------------------------------------
--  DDL for Package Body HR_APPLICATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPLICATION_SWI" As
/* $Header: hraplswi.pkb 115.2 2002/12/03 06:13:31 hjonnala ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_application_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_apl_details >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_apl_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_current_employer             in     varchar2  default hr_api.g_varchar2
  ,p_projected_hire_date          in     date      default hr_api.g_date
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_appl_attribute20             in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_apl_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_apl_details_swi;
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
  hr_application_api.update_apl_details
    (p_validate                     => l_validate
    ,p_application_id               => p_application_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_comments                     => p_comments
    ,p_current_employer             => p_current_employer
    ,p_projected_hire_date          => p_projected_hire_date
    ,p_termination_reason           => p_termination_reason
    ,p_appl_attribute_category      => p_appl_attribute_category
    ,p_appl_attribute1              => p_appl_attribute1
    ,p_appl_attribute2              => p_appl_attribute2
    ,p_appl_attribute3              => p_appl_attribute3
    ,p_appl_attribute4              => p_appl_attribute4
    ,p_appl_attribute5              => p_appl_attribute5
    ,p_appl_attribute6              => p_appl_attribute6
    ,p_appl_attribute7              => p_appl_attribute7
    ,p_appl_attribute8              => p_appl_attribute8
    ,p_appl_attribute9              => p_appl_attribute9
    ,p_appl_attribute10             => p_appl_attribute10
    ,p_appl_attribute11             => p_appl_attribute11
    ,p_appl_attribute12             => p_appl_attribute12
    ,p_appl_attribute13             => p_appl_attribute13
    ,p_appl_attribute14             => p_appl_attribute14
    ,p_appl_attribute15             => p_appl_attribute15
    ,p_appl_attribute16             => p_appl_attribute16
    ,p_appl_attribute17             => p_appl_attribute17
    ,p_appl_attribute18             => p_appl_attribute18
    ,p_appl_attribute19             => p_appl_attribute19
    ,p_appl_attribute20             => p_appl_attribute20
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
    rollback to update_apl_details_swi;
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
    rollback to update_apl_details_swi;
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
end update_apl_details;
end hr_application_swi;

/
