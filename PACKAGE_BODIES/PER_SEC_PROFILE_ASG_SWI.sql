--------------------------------------------------------
--  DDL for Package Body PER_SEC_PROFILE_ASG_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SEC_PROFILE_ASG_SWI" As
/* $Header: peaspswi.pkb 115.1 2003/10/08 23:09 vkonda noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_sec_profile_asg_swi.';
--

-- ----------------------------------------------------------------------------
-- |----------------------< create_security_profile_asg >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_security_profile_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_sec_profile_assignment_id       out nocopy number
  ,p_user_id                      in     number
  ,p_security_group_id            in     number
  ,p_business_group_id            in     number
  ,p_security_profile_id          in     number
  ,p_responsibility_id            in     number
  ,p_responsibility_application_i in     number
  ,p_start_date                   in     date
  ,p_end_date                     in     date      default null
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
  l_proc    varchar2(72) := g_package ||'create_security_profile_asg';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_sec_prf_asg_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;

     hr_utility.trace('  user id ' || p_user_id );
     hr_utility.trace('  Sec Grp Id ' || p_security_group_id);
     hr_utility.trace('  Sec Prf Id ' || p_security_profile_id);
     hr_utility.trace('  Resp Id ' || p_responsibility_id);
     hr_utility.trace('  Resp Appl Id ' || p_responsibility_application_i);
     hr_utility.trace(' Business Group Id ' || p_business_group_id);
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

  per_sec_profile_asg_api.create_security_profile_asg
    (p_validate                     => l_validate
    ,p_sec_profile_assignment_id    => p_sec_profile_assignment_id
    ,p_user_id                      => p_user_id
    ,p_security_group_id            => p_security_group_id
    ,p_business_group_id            => p_business_group_id
    ,p_security_profile_id          => p_security_profile_id
    ,p_responsibility_id            => p_responsibility_id
    ,p_responsibility_application_i => p_responsibility_application_i
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
     hr_utility.trace('  user id ' || p_user_id );
     hr_utility.trace('  Sec Grp Id ' || p_security_group_id);
     hr_utility.trace('  Sec Prf Id ' || p_security_profile_id);
     hr_utility.trace('  Resp Id ' || p_responsibility_id);
     hr_utility.trace('  Resp Appl Id ' || p_responsibility_application_i);

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

    rollback to create_sec_prf_asg_swii;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --


    p_sec_profile_assignment_id    := null;

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
    rollback to create_sec_prf_asg_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --



    p_sec_profile_assignment_id    := null;

    p_object_version_number        := null;

    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_security_profile_asg;


-- ----------------------------------------------------------------------------
-- |----------------------< update_security_profile_asg >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_security_profile_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_sec_profile_assignment_id    in     number
  ,p_user_id                      in     number
  ,p_security_group_id            in     number
  ,p_business_group_id            in     number
  ,p_security_profile_id          in     number
  ,p_responsibility_id            in     number
  ,p_responsibility_application_i in     number
  ,p_start_date                   in     date
  ,p_end_date                     in     date
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

  l_proc    varchar2(72) := g_package ||'update_security_profile_asg';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_sec_prf_asg_swi;
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


  per_sec_profile_asg_api.update_security_profile_asg
    (p_validate                     => l_validate
    ,p_sec_profile_assignment_id    => p_sec_profile_assignment_id
    ,p_user_id                      => p_user_id
    ,p_security_group_id            => p_security_group_id
    ,p_business_group_id            => p_business_group_id
    ,p_security_profile_id          => p_security_profile_id
    ,p_responsibility_id            => p_responsibility_id
    ,p_responsibility_application_i => p_responsibility_application_i
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
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

    rollback to update_sec_prf_asg_swi;
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
    rollback to update_sec_prf_asg_swi;
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
end update_security_profile_asg;

end per_sec_profile_asg_swi;

/
