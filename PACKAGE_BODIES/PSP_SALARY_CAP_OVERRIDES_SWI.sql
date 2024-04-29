--------------------------------------------------------
--  DDL for Package Body PSP_SALARY_CAP_OVERRIDES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_SALARY_CAP_OVERRIDES_SWI" As
/* $Header: PSPSOSWB.pls 120.0 2005/11/20 23:56 dpaudel noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'psp_salary_cap_overrides_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_salary_cap_override >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_salary_cap_override
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_funding_source_code          in     varchar2
  ,p_project_id                   in     number
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_currency_code                in     varchar2
  ,p_annual_salary_cap            in     number
  ,p_object_version_number        in out nocopy number
  ,p_salary_cap_override_id       in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_return_status                 boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_salary_cap_override_id       number;
  l_proc    varchar2(72) := g_package ||'create_salary_cap_override';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_salary_cap_override_swi;
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
  l_return_status :=
    hr_api.constant_to_boolean
      (p_constant_value => p_return_status);
  --
  -- Register Surrogate ID or user key values
  --
  psp_pso_ins.set_base_key_value
    (p_salary_cap_override_id => p_salary_cap_override_id
    );
  --
  -- Call API
  --
  psp_salary_cap_overrides_api.create_salary_cap_override
    (p_validate                     => l_validate
    ,p_funding_source_code          => p_funding_source_code
    ,p_project_id                   => p_project_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_currency_code                => p_currency_code
    ,p_annual_salary_cap            => p_annual_salary_cap
    ,p_object_version_number        => p_object_version_number
    ,p_salary_cap_override_id       => l_salary_cap_override_id
    ,p_return_status                => l_return_status
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  p_return_status :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_return_status
      );
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
    rollback to create_salary_cap_override_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
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
    rollback to create_salary_cap_override_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_salary_cap_override;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_salary_cap_override >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_salary_cap_override
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_salary_cap_override_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_return_status                 boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_salary_cap_override';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_salary_cap_override_swi;
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
  l_return_status :=
    hr_api.constant_to_boolean
      (p_constant_value => p_return_status);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  psp_salary_cap_overrides_api.delete_salary_cap_override
    (p_validate                     => l_validate
    ,p_salary_cap_override_id       => p_salary_cap_override_id
    ,p_object_version_number        => p_object_version_number
    ,p_return_status                => l_return_status
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  p_return_status :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_return_status
      );
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
    rollback to delete_salary_cap_override_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
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
    rollback to delete_salary_cap_override_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_salary_cap_override;
-- ----------------------------------------------------------------------------
-- |----------------------< update_salary_cap_override >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_salary_cap_override
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_salary_cap_override_id       in     number
  ,p_funding_source_code          in     varchar2
  ,p_project_id                   in     number
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_currency_code                in     varchar2
  ,p_annual_salary_cap            in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_return_status                 boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_salary_cap_override';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_salary_cap_override_swi;
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
  l_return_status :=
    hr_api.constant_to_boolean
      (p_constant_value => p_return_status);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  psp_salary_cap_overrides_api.update_salary_cap_override
    (p_validate                     => l_validate
    ,p_salary_cap_override_id       => p_salary_cap_override_id
    ,p_funding_source_code          => p_funding_source_code
    ,p_project_id                   => p_project_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_currency_code                => p_currency_code
    ,p_annual_salary_cap            => p_annual_salary_cap
    ,p_object_version_number        => p_object_version_number
    ,p_return_status                => l_return_status
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  p_return_status :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_return_status
      );
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
    rollback to update_salary_cap_override_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
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
    rollback to update_salary_cap_override_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status                := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_salary_cap_override;
end psp_salary_cap_overrides_swi;

/
