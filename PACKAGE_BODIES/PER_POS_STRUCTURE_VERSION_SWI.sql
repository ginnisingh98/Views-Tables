--------------------------------------------------------
--  DDL for Package Body PER_POS_STRUCTURE_VERSION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POS_STRUCTURE_VERSION_SWI" As
/* $Header: pepsvswi.pkb 115.4 2003/05/22 08:12:24 ndorai noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_pos_structure_version_swi.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_pos_structure_version >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_pos_structure_version
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_position_structure_id        in     number
  ,p_date_from                    in     date
  ,p_version_number               in     number
  ,p_copy_structure_version_id    in     number    default null
  ,p_date_to                      in     date      default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_pos_structure_version_id        out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_gap_warning                   boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_pos_structure_version';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_posstructureversion_swi;
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
  per_pos_structure_version_api.create_pos_structure_version
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_position_structure_id        => p_position_structure_id
    ,p_date_from                    => p_date_from
    ,p_version_number               => p_version_number
    ,p_copy_structure_version_id    => p_copy_structure_version_id
    ,p_date_to                      => p_date_to
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_pos_structure_version_id     => p_pos_structure_version_id
    ,p_object_version_number        => p_object_version_number
    ,p_gap_warning                  => l_gap_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_gap_warning then
     fnd_message.set_name('PAY', 'HR_PO_POS_GAP');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
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
    rollback to create_posstructureversion_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_pos_structure_version_id     := null;
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
    rollback to create_posstructureversion_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_pos_structure_version_id     := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_pos_structure_version;
-- ----------------------------------------------------------------------------
-- |---------------------< delete_pos_structure_version >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_pos_structure_version
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pos_structure_version_id     in     number
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
  l_proc    varchar2(72) := g_package ||'delete_pos_structure_version';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_posstructureversion_swi;
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
  per_pos_structure_version_api.delete_pos_structure_version
    (p_validate                     => l_validate
    ,p_pos_structure_version_id     => p_pos_structure_version_id
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
    rollback to delete_posstructureversion_swi;
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
    rollback to delete_posstructureversion_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_pos_structure_version;
-- ----------------------------------------------------------------------------
-- |---------------------< update_pos_structure_version >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_pos_structure_version
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_date_from                    in     date
  ,p_version_number               in     number
  ,p_copy_structure_version_id    in     number    default hr_api.g_number
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_pos_structure_version_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_gap_warning                   boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_pos_structure_version';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_posstructureversion_swi;
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
  per_pos_structure_version_api.update_pos_structure_version
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_date_from                    => p_date_from
    ,p_version_number               => p_version_number
    ,p_copy_structure_version_id    => p_copy_structure_version_id
    ,p_date_to                      => p_date_to
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_pos_structure_version_id     => p_pos_structure_version_id
    ,p_object_version_number        => p_object_version_number
    ,p_gap_warning                  => l_gap_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_gap_warning then
     fnd_message.set_name('PAY', 'HR_PO_POS_GAP');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
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
    rollback to update_posstructureversion_swi;
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
    rollback to update_posstructureversion_swi;
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
end update_pos_structure_version;
end per_pos_structure_version_swi;

/
