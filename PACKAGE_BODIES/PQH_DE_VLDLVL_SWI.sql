--------------------------------------------------------
--  DDL for Package Body PQH_DE_VLDLVL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_VLDLVL_SWI" As
/* $Header: pqlvlswi.pkb 115.1 2002/12/03 00:08:57 rpasapul noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_de_vldlvl_swi.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_vldtn_lvl >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_vldtn_lvl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_wrkplc_vldtn_lvlnum_id       in     number
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
  l_proc    varchar2(72) := g_package ||'delete_vldtn_lvl';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vldtn_lvl_swi;
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
  pqh_de_vldlvl_api.delete_vldtn_lvl
    (p_validate                     => l_validate
    ,p_wrkplc_vldtn_lvlnum_id       => p_wrkplc_vldtn_lvlnum_id
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
    rollback to delete_vldtn_lvl_swi;
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
    rollback to delete_vldtn_lvl_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_vldtn_lvl;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_vldtn_lvl >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_vldtn_lvl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_wrkplc_vldtn_ver_id          in     number
  ,p_level_number_id              in     number
  ,p_level_code_id                in     number
  ,p_wrkplc_vldtn_lvlnum_id          out nocopy number
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
  l_proc    varchar2(72) := g_package ||'insert_vldtn_lvl';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint insert_vldtn_lvl_swi;
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
  pqh_lvl_ins.set_base_key_value
    (p_wrkplc_vldtn_lvlnum_id => p_wrkplc_vldtn_lvlnum_id
    );
  --
  -- Call API
  --
  pqh_de_vldlvl_api.insert_vldtn_lvl
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_wrkplc_vldtn_ver_id          => p_wrkplc_vldtn_ver_id
    ,p_level_number_id              => p_level_number_id
    ,p_level_code_id                => p_level_code_id
    ,p_wrkplc_vldtn_lvlnum_id       => p_wrkplc_vldtn_lvlnum_id
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
    rollback to insert_vldtn_lvl_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_wrkplc_vldtn_lvlnum_id       := null;
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
    rollback to insert_vldtn_lvl_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_wrkplc_vldtn_lvlnum_id       := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end insert_vldtn_lvl;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_vldtn_lvl >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_vldtn_lvl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_wrkplc_vldtn_ver_id          in     number    default hr_api.g_number
  ,p_level_number_id              in     number    default hr_api.g_number
  ,p_level_code_id                in     number    default hr_api.g_number
  ,p_wrkplc_vldtn_lvlnum_id       in     number
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
  l_proc    varchar2(72) := g_package ||'update_vldtn_lvl';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_vldtn_lvl_swi;
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
  pqh_de_vldlvl_api.update_vldtn_lvl
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_wrkplc_vldtn_ver_id          => p_wrkplc_vldtn_ver_id
    ,p_level_number_id              => p_level_number_id
    ,p_level_code_id                => p_level_code_id
    ,p_wrkplc_vldtn_lvlnum_id       => p_wrkplc_vldtn_lvlnum_id
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
    rollback to update_vldtn_lvl_swi;
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
    rollback to update_vldtn_lvl_swi;
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
end update_vldtn_lvl;
end pqh_de_vldlvl_swi;

/
