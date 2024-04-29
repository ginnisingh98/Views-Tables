--------------------------------------------------------
--  DDL for Package Body PQH_FR_VALIDATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_VALIDATIONS_SWI" As
/* $Header: pqvldswi.pkb 115.1 2002/12/05 00:31:04 rpasapul noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_fr_validations_swi.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validation >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_validation
  (p_validation_id                in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is

  cursor c_vp is
  select validation_period_id, object_version_number from pqh_fr_validation_periods
  where validation_id = p_validation_id;

  cursor c_ve is
  select validation_event_id, object_version_number from pqh_fr_validation_events
  where validation_id = p_validation_id;


  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_validation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_validation_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  for vlp in c_vp loop
  pqh_fr_validation_periods_api.delete_validation_period
  (p_validation_period_id         => vlp.validation_period_id
  ,p_object_version_number        => vlp.object_version_number);
  end loop;

  for vle in c_ve loop
  pqh_fr_validation_events_api.delete_validation_event
  (p_validation_event_id          => vle.validation_event_id
  ,p_object_version_number        => vle.object_version_number);
  end loop;

  pqh_fr_validations_api.delete_validation
    (p_validation_id                => p_validation_id
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
    rollback to delete_validation_swi;
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
    rollback to delete_validation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_validation;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validation >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_validation
  (p_effective_date               in     date
  ,p_pension_fund_type_code       in     varchar2
  ,p_pension_fund_id              in     number
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_previously_validated_flag    in     varchar2
  ,p_request_date                 in     date      default null
  ,p_completion_date              in     date      default null
  ,p_previous_employer_id         in     number    default null
  ,p_status                       in     varchar2  default null
  ,p_employer_amount              in     number    default null
  ,p_employer_currency_code       in     varchar2  default null
  ,p_employee_amount              in     number    default null
  ,p_employee_currency_code       in     varchar2  default null
  ,p_deduction_per_period         in     number    default null
  ,p_deduction_currency_code      in     varchar2  default null
  ,p_percent_of_salary            in     number    default null
  ,p_validation_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'insert_validation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint insert_validation_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  pqh_vld_ins.set_base_key_value
    (p_validation_id => p_validation_id
    );
  --
  -- Call API
  --
  pqh_fr_validations_api.insert_validation
    (p_effective_date               => p_effective_date
    ,p_pension_fund_type_code       => p_pension_fund_type_code
    ,p_pension_fund_id              => p_pension_fund_id
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_previously_validated_flag    => p_previously_validated_flag
    ,p_request_date                 => p_request_date
    ,p_completion_date              => p_completion_date
    ,p_previous_employer_id         => p_previous_employer_id
    ,p_status                       => p_status
    ,p_employer_amount              => p_employer_amount
    ,p_employer_currency_code       => p_employer_currency_code
    ,p_employee_amount              => p_employee_amount
    ,p_employee_currency_code       => p_employee_currency_code
    ,p_deduction_per_period         => p_deduction_per_period
    ,p_deduction_currency_code      => p_deduction_currency_code
    ,p_percent_of_salary            => p_percent_of_salary
    ,p_validation_id                => p_validation_id
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
    rollback to insert_validation_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_validation_id                := null;
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
    rollback to insert_validation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_validation_id                := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end insert_validation;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validation >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_validation
  (p_effective_date               in     date
  ,p_validation_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_pension_fund_type_code       in     varchar2  default hr_api.g_varchar2
  ,p_pension_fund_id              in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_previously_validated_flag    in     varchar2  default hr_api.g_varchar2
  ,p_request_date                 in     date      default hr_api.g_date
  ,p_completion_date              in     date      default hr_api.g_date
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_employer_amount              in     number    default hr_api.g_number
  ,p_employer_currency_code       in     varchar2  default hr_api.g_varchar2
  ,p_employee_amount              in     number    default hr_api.g_number
  ,p_employee_currency_code       in     varchar2  default hr_api.g_varchar2
  ,p_deduction_per_period         in     number    default hr_api.g_number
  ,p_deduction_currency_code      in     varchar2  default hr_api.g_varchar2
  ,p_percent_of_salary            in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_validation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_validation_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqh_fr_validations_api.update_validation
    (p_effective_date               => p_effective_date
    ,p_validation_id                => p_validation_id
    ,p_object_version_number        => p_object_version_number
    ,p_pension_fund_type_code       => p_pension_fund_type_code
    ,p_pension_fund_id              => p_pension_fund_id
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_previously_validated_flag    => p_previously_validated_flag
    ,p_request_date                 => p_request_date
    ,p_completion_date              => p_completion_date
    ,p_previous_employer_id         => p_previous_employer_id
    ,p_status                       => p_status
    ,p_employer_amount              => p_employer_amount
    ,p_employer_currency_code       => p_employer_currency_code
    ,p_employee_amount              => p_employee_amount
    ,p_employee_currency_code       => p_employee_currency_code
    ,p_deduction_per_period         => p_deduction_per_period
    ,p_deduction_currency_code      => p_deduction_currency_code
    ,p_percent_of_salary            => p_percent_of_salary
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
    rollback to update_validation_swi;
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
    rollback to update_validation_swi;
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
end update_validation;
end pqh_fr_validations_swi;

/
