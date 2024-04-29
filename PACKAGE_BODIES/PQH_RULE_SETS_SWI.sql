--------------------------------------------------------
--  DDL for Package Body PQH_RULE_SETS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RULE_SETS_SWI" As
/* $Header: pqrstswi.pkb 120.0 2005/05/29 02:39:21 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_rule_sets_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_rule_set >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_rule_set
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number    default null
  ,p_rule_set_id                     out nocopy number
  ,p_rule_set_name                in     varchar2
  ,p_description		  in     varchar2
  ,p_organization_structure_id    in     number    default null
  ,p_organization_id              in     number    default null
  ,p_referenced_rule_set_id       in     number    default null
  ,p_rule_level_cd                in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_short_name                   in     varchar2
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2  default hr_api.userenv_lang
  ,p_rule_applicability           in     varchar2
  ,p_rule_category                in     varchar2
  ,p_starting_organization_id     in     number    default null
  ,p_seeded_rule_flag             in     varchar2  default 'N'
  ,p_status                       in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_rule_set';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_rule_set_swi;
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
  pqh_rule_sets_api.create_rule_set
    (p_validate                     => l_validate
    ,p_business_group_id            => p_business_group_id
    ,p_rule_set_id                  => p_rule_set_id
    ,p_rule_set_name                => p_rule_set_name
    ,p_description		    => p_description
    ,p_organization_structure_id    => p_organization_structure_id
    ,p_organization_id              => p_organization_id
    ,p_referenced_rule_set_id       => p_referenced_rule_set_id
    ,p_rule_level_cd                => p_rule_level_cd
    ,p_object_version_number        => p_object_version_number
    ,p_short_name                   => p_short_name
    ,p_effective_date               => p_effective_date
    ,p_language_code                => p_language_code
    ,p_rule_applicability           => p_rule_applicability
    ,p_rule_category                => p_rule_category
    ,p_starting_organization_id     => p_starting_organization_id
    ,p_seeded_rule_flag             => p_seeded_rule_flag
    ,p_status                       => p_status
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
    rollback to create_rule_set_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_rule_set_id                  := null;
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
    rollback to create_rule_set_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_rule_set_id                  := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_rule_set;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_rule_set >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_rule_set
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_set_id                  in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_rule_set';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rule_set_swi;
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
  pqh_rule_sets_api.delete_rule_set
    (p_validate                     => l_validate
    ,p_rule_set_id                  => p_rule_set_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
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
    rollback to delete_rule_set_swi;
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
    rollback to delete_rule_set_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_rule_set;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_rule_set >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_rule_set
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_rule_set_id                  in     number
  ,p_rule_set_name                in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_organization_structure_id    in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_referenced_rule_set_id       in     number    default hr_api.g_number
  ,p_rule_level_cd                in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_short_name                   in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2  default hr_api.userenv_lang
  ,p_rule_applicability           in     varchar2  default hr_api.g_varchar2
  ,p_rule_category                in     varchar2  default hr_api.g_varchar2
  ,p_starting_organization_id     in     number    default hr_api.g_number
  ,p_seeded_rule_flag             in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_rule_set';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_rule_set_swi;
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
  pqh_rule_sets_api.update_rule_set
    (p_validate                     => l_validate
    ,p_business_group_id            => p_business_group_id
    ,p_rule_set_id                  => p_rule_set_id
    ,p_rule_set_name                => p_rule_set_name
    ,p_description		    => p_description
    ,p_organization_structure_id    => p_organization_structure_id
    ,p_organization_id              => p_organization_id
    ,p_referenced_rule_set_id       => p_referenced_rule_set_id
    ,p_rule_level_cd                => p_rule_level_cd
    ,p_object_version_number        => p_object_version_number
    ,p_short_name                   => p_short_name
    ,p_effective_date               => p_effective_date
    ,p_language_code                => p_language_code
    ,p_rule_applicability           => p_rule_applicability
    ,p_rule_category                => p_rule_category
    ,p_starting_organization_id     => p_starting_organization_id
    ,p_seeded_rule_flag             => p_seeded_rule_flag
    ,p_status                       => p_status
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
    rollback to update_rule_set_swi;
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
    rollback to update_rule_set_swi;
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
end update_rule_set;
end pqh_rule_sets_swi;

/
