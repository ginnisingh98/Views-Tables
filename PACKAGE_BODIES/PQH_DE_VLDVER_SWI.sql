--------------------------------------------------------
--  DDL for Package Body PQH_DE_VLDVER_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_VLDVER_SWI" As
/* $Header: pqverswi.pkb 115.1 2002/12/05 00:30:48 rpasapul noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_de_vldver_swi.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_vldtn_vern >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_vldtn_vern
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_wrkplc_vldtn_ver_id          in     number
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
  l_proc    varchar2(72) := g_package ||'delete_vldtn_vern';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vldtn_vern_swi;
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
  pqh_de_vldver_api.delete_vldtn_vern
    (p_validate                     => l_validate
    ,p_wrkplc_vldtn_ver_id          => p_wrkplc_vldtn_ver_id
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
    rollback to delete_vldtn_vern_swi;
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
    rollback to delete_vldtn_vern_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_vldtn_vern;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_vldtn_vern >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_vldtn_vern
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_wrkplc_vldtn_id              in     number
  ,p_version_number               in     number    default NULL
  ,p_remuneration_job_description in     varchar2  default NULL
  ,p_tariff_contract_code         in     varchar2
  ,p_tariff_group_code            in     varchar2
  ,p_job_group_id                 in     number    default NULL
  ,p_remuneration_job_id          in     number    default NULL
  ,p_derived_grade_id             in     number    default NULL
  ,p_derived_case_group_id        in     number    default NULL
  ,p_derived_subcasgrp_id         in     number    default NULL
  ,p_user_enterable_grade_id      in     number    default NULL
  ,p_user_enterable_case_group_id in     number    default NULL
  ,p_user_enterable_subcasgrp_id  in     number    default NULL
  ,p_freeze                       in     varchar2  default NULL
  ,p_wrkplc_vldtn_ver_id             out nocopy number
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
  l_proc    varchar2(72) := g_package ||'insert_vldtn_vern';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint insert_vldtn_vern_swi;
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
  pqh_ver_ins.set_base_key_value
    (p_wrkplc_vldtn_ver_id => p_wrkplc_vldtn_ver_id
    );
  --
  -- Call API
  --
  pqh_de_vldver_api.insert_vldtn_vern
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_wrkplc_vldtn_id              => p_wrkplc_vldtn_id
    ,p_version_number               => p_version_number
    ,p_remuneration_job_description => p_remuneration_job_description
    ,p_tariff_contract_code         => p_tariff_contract_code
    ,p_tariff_group_code            => p_tariff_group_code
    ,p_job_group_id                 => p_job_group_id
    ,p_remuneration_job_id          => p_remuneration_job_id
    ,p_derived_grade_id             => p_derived_grade_id
    ,p_derived_case_group_id        => p_derived_case_group_id
    ,p_derived_subcasgrp_id         => p_derived_subcasgrp_id
    ,p_user_enterable_grade_id      => p_user_enterable_grade_id
    ,p_user_enterable_case_group_id => p_user_enterable_case_group_id
    ,p_user_enterable_subcasgrp_id  => p_user_enterable_subcasgrp_id
    ,p_freeze                       => p_freeze
    ,p_wrkplc_vldtn_ver_id          => p_wrkplc_vldtn_ver_id
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
    rollback to insert_vldtn_vern_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_wrkplc_vldtn_ver_id          := null;
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
    rollback to insert_vldtn_vern_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_wrkplc_vldtn_ver_id          := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end insert_vldtn_vern;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_vldtn_vern >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_vldtn_vern
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_wrkplc_vldtn_id              in     number    default hr_api.g_number
  ,p_version_number               in     number    default hr_api.g_number
  ,p_remuneration_job_description in     varchar2  default hr_api.g_varchar2
  ,p_tariff_contract_code         in     varchar2  default hr_api.g_varchar2
  ,p_tariff_group_code            in     varchar2  default hr_api.g_varchar2
  ,p_job_group_id                 in     number    default hr_api.g_number
  ,p_remuneration_job_id          in     number    default hr_api.g_number
  ,p_derived_grade_id             in     number    default hr_api.g_number
  ,p_derived_case_group_id        in     number    default hr_api.g_number
  ,p_derived_subcasgrp_id         in     number    default hr_api.g_number
  ,p_user_enterable_grade_id      in     number    default hr_api.g_number
  ,p_user_enterable_case_group_id in     number    default hr_api.g_number
  ,p_user_enterable_subcasgrp_id  in     number    default hr_api.g_number
  ,p_freeze                       in     varchar2  default hr_api.g_varchar2
  ,p_wrkplc_vldtn_ver_id          in     number
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
  l_proc    varchar2(72) := g_package ||'update_vldtn_vern';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_vldtn_vern_swi;
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
  pqh_de_vldver_api.update_vldtn_vern
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_wrkplc_vldtn_id              => p_wrkplc_vldtn_id
    ,p_version_number               => p_version_number
    ,p_remuneration_job_description => p_remuneration_job_description
    ,p_tariff_contract_code         => p_tariff_contract_code
    ,p_tariff_group_code            => p_tariff_group_code
    ,p_job_group_id                 => p_job_group_id
    ,p_remuneration_job_id          => p_remuneration_job_id
    ,p_derived_grade_id             => p_derived_grade_id
    ,p_derived_case_group_id        => p_derived_case_group_id
    ,p_derived_subcasgrp_id         => p_derived_subcasgrp_id
    ,p_user_enterable_grade_id      => p_user_enterable_grade_id
    ,p_user_enterable_case_group_id => p_user_enterable_case_group_id
    ,p_user_enterable_subcasgrp_id  => p_user_enterable_subcasgrp_id
    ,p_freeze                       => p_freeze
    ,p_wrkplc_vldtn_ver_id          => p_wrkplc_vldtn_ver_id
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
    rollback to update_vldtn_vern_swi;
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
    rollback to update_vldtn_vern_swi;
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
end update_vldtn_vern;
end pqh_de_vldver_swi;

/