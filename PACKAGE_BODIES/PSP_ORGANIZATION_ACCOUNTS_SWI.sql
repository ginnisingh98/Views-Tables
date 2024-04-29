--------------------------------------------------------
--  DDL for Package Body PSP_ORGANIZATION_ACCOUNTS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ORGANIZATION_ACCOUNTS_SWI" As
/* $Header: PSPOASWB.pls 120.0 2005/11/20 23:57 dpaudel noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'psp_organization_accounts_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_organization_account >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_organization_account
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_gl_code_combination_id       in     number
  ,p_project_id                   in     number
  ,p_expenditure_organization_id  in     number
  ,p_expenditure_type             in     varchar2
  ,p_task_id                      in     number
  ,p_award_id                     in     number
  ,p_comments                     in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_account_type_code            in     varchar2
  ,p_start_date_active            in     date
  ,p_business_group_id            in     number
  ,p_end_date_active              in     date
  ,p_organization_id              in     number
  ,p_poeta_start_date             in     date default null
  ,p_poeta_end_date               in     date default null
  ,p_funding_source_code          in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_organization_account_id      in     number
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
  l_organization_account_id      number;
  l_proc    varchar2(72) := g_package ||'create_organization_account';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_org_account_swi;
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
  psp_poa_ins.set_base_key_value
    (p_organization_account_id => p_organization_account_id
    );
  --
  -- Call API
  --
  psp_organization_accounts_api.create_organization_account
    (p_validate                     => l_validate
    ,p_gl_code_combination_id       => p_gl_code_combination_id
    ,p_project_id                   => p_project_id
    ,p_expenditure_organization_id  => p_expenditure_organization_id
    ,p_expenditure_type             => p_expenditure_type
    ,p_task_id                      => p_task_id
    ,p_award_id                     => p_award_id
    ,p_comments                     => p_comments
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
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_account_type_code            => p_account_type_code
    ,p_start_date_active            => p_start_date_active
    ,p_business_group_id            => p_business_group_id
    ,p_end_date_active              => p_end_date_active
    ,p_organization_id              => p_organization_id
    ,p_poeta_start_date             => p_poeta_start_date
    ,p_poeta_end_date               => p_poeta_end_date
    ,p_funding_source_code          => p_funding_source_code
    ,p_object_version_number        => p_object_version_number
    ,p_organization_account_id      => l_organization_account_id
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
    rollback to create_org_account_swi;
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
    rollback to create_org_account_swi;
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
end create_organization_account;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_organization_account >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_organization_account
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_account_id      in     number
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
  l_proc    varchar2(72) := g_package ||'delete_organization_account';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_org_account_swi;
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
  psp_organization_accounts_api.delete_organization_account
    (p_validate                     => l_validate
    ,p_organization_account_id      => p_organization_account_id
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
    rollback to delete_org_account_swi;
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
    rollback to delete_org_account_swi;
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
end delete_organization_account;
-- ----------------------------------------------------------------------------
-- |----------------------< update_organization_account >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_organization_account
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_account_id      in     number
  ,p_gl_code_combination_id       in     number
  ,p_project_id                   in     number
  ,p_expenditure_organization_id  in     number
  ,p_expenditure_type             in     varchar2
  ,p_task_id                      in     number
  ,p_award_id                     in     number
  ,p_comments                     in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_account_type_code            in     varchar2
  ,p_start_date_active            in     date
  ,p_business_group_id            in     number
  ,p_end_date_active              in     date
  ,p_organization_id              in     number
  ,p_poeta_start_date             in     date default null
  ,p_poeta_end_date               in     date default null
  ,p_funding_source_code          in     varchar2
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
  l_proc    varchar2(72) := g_package ||'update_organization_account';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_org_account_swi;
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
  psp_organization_accounts_api.update_organization_account
    (p_validate                     => l_validate
    ,p_organization_account_id      => p_organization_account_id
    ,p_gl_code_combination_id       => p_gl_code_combination_id
    ,p_project_id                   => p_project_id
    ,p_expenditure_organization_id  => p_expenditure_organization_id
    ,p_expenditure_type             => p_expenditure_type
    ,p_task_id                      => p_task_id
    ,p_award_id                     => p_award_id
    ,p_comments                     => p_comments
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
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_account_type_code            => p_account_type_code
    ,p_start_date_active            => p_start_date_active
    ,p_business_group_id            => p_business_group_id
    ,p_end_date_active              => p_end_date_active
    ,p_organization_id              => p_organization_id
    ,p_poeta_start_date             => p_poeta_start_date
    ,p_poeta_end_date               => p_poeta_end_date
    ,p_funding_source_code          => p_funding_source_code
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
    rollback to update_org_account_swi;
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
    rollback to update_org_account_swi;
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
end update_organization_account;
end psp_organization_accounts_swi;

/
