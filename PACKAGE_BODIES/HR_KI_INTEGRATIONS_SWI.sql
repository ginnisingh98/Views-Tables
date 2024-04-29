--------------------------------------------------------
--  DDL for Package Body HR_KI_INTEGRATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_INTEGRATIONS_SWI" As
/* $Header: hrintswi.pkb 115.0 2004/01/09 01:42 vkarandi noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_ki_integrations_swi.';
-- ----------------------------------------------------------------------------
-- |-----------------------< validate_integration >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE validate_integration
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_integration_id               in     number
  ,p_object_version_number        in     out nocopy number
  ,p_error                        out    nocopy varchar2
  ,p_return_status                out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'validate_integration';
  l_object_version_number number :=p_object_version_number;
  l_error   varchar2(2000) := null;
  l_index   number := null;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint validate_integration;
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

  -- Call API
  --
  hr_ki_integrations_api.validate_integration
    (p_validate                     => l_validate
    ,p_integration_id               => p_integration_id
    ,p_object_version_number        => l_object_version_number
    );

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

    rollback to validate_integration;
    fnd_msg_pub.get
    (
      p_data          => l_error
     ,p_encoded       => 'F'
     ,p_msg_index_out => l_index

    );
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_error := l_error;
    p_return_status := hr_multi_message.get_return_status_disable;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --

    rollback to validate_integration;

    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;

    fnd_msg_pub.get
    (
      p_data          => l_error
     ,p_encoded       => 'F'
     ,p_msg_index_out => l_index

    );
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    p_object_version_number  := l_object_version_number;
    p_error := l_error;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end validate_integration;
end hr_ki_integrations_swi;

/
