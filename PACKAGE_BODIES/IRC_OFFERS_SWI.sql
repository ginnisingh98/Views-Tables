--------------------------------------------------------
--  DDL for Package Body IRC_OFFERS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_OFFERS_SWI" As
/* $Header: iriofswi.pkb 120.24.12010000.6 2009/06/23 10:12:31 vmummidi ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_offers_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_offer >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default null
  ,p_offer_status                 in     varchar2
  ,p_discretionary_job_title      in     varchar2  default null
  ,p_offer_extended_method        in     varchar2  default null
  ,p_respondent_id                in     number    default null
  ,p_expiry_date                  in     date      default null
  ,p_proposed_start_date          in     date      default null
  ,p_offer_letter_tracking_code   in     varchar2  default null
  ,p_offer_postal_service         in     varchar2  default null
  ,p_offer_shipping_date          in     date      default null
  ,p_applicant_assignment_id      in     number
  ,p_offer_assignment_id          in     number
  ,p_address_id                   in     number    default null
  ,p_template_id                  in     number    default null
  ,p_offer_letter_file_type       in     varchar2  default null
  ,p_offer_letter_file_name       in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_status_change_date           in     date      default null
  ,p_offer_id                     in out nocopy number
  ,p_offer_version                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_offer';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_offer_swi;
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
  irc_iof_ins.set_base_key_value
    (p_offer_id => p_offer_id
    );
  --
  -- Call API
  --
  irc_offers_api.create_offer
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_offer_status                 => p_offer_status
    ,p_discretionary_job_title      => p_discretionary_job_title
    ,p_offer_extended_method        => p_offer_extended_method
    ,p_respondent_id                => p_respondent_id
    ,p_expiry_date                  => p_expiry_date
    ,p_proposed_start_date          => p_proposed_start_date
    ,p_offer_letter_tracking_code   => p_offer_letter_tracking_code
    ,p_offer_postal_service         => p_offer_postal_service
    ,p_offer_shipping_date          => p_offer_shipping_date
    ,p_applicant_assignment_id      => p_applicant_assignment_id
    ,p_offer_assignment_id          => p_offer_assignment_id
    ,p_address_id                   => p_address_id
    ,p_template_id                  => p_template_id
    ,p_offer_letter_file_type       => p_offer_letter_file_type
    ,p_offer_letter_file_name       => p_offer_letter_file_name
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
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_status_change_date           => p_status_change_date
    ,p_offer_id                     => p_offer_id
    ,p_offer_version                => p_offer_version
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
    rollback to create_offer_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_offer_version                := null;
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
    rollback to create_offer_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_offer_version                := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_offer;
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_offer >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_offer_status                 in     varchar2  default hr_api.g_varchar2
  ,p_discretionary_job_title      in     varchar2  default hr_api.g_varchar2
  ,p_offer_extended_method        in     varchar2  default hr_api.g_varchar2
  ,p_respondent_id                in     number    default hr_api.g_number
  ,p_expiry_date                  in     date      default hr_api.g_date
  ,p_proposed_start_date          in     date      default hr_api.g_date
  ,p_offer_letter_tracking_code   in     varchar2  default hr_api.g_varchar2
  ,p_offer_postal_service         in     varchar2  default hr_api.g_varchar2
  ,p_offer_shipping_date          in     date      default hr_api.g_date
  ,p_applicant_assignment_id      in     number    default hr_api.g_number
  ,p_offer_assignment_id          in     number    default hr_api.g_number
  ,p_address_id                   in     number    default hr_api.g_number
  ,p_template_id                  in     number    default hr_api.g_number
  ,p_offer_letter_file_type       in     varchar2  default hr_api.g_varchar2
  ,p_offer_letter_file_name       in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_change_reason                in     varchar2  default null
  ,p_decline_reason               in     varchar2  default null
  ,p_note_text                    in     varchar2  default null
  ,p_status_change_date           in     date      default null
  ,p_offer_id                     in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_offer_version                   out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_offer_id                      number;
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_offer';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_offer_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_offer_id                      := p_offer_id;
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
  irc_offers_api.update_offer
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_offer_status                 => p_offer_status
    ,p_discretionary_job_title      => p_discretionary_job_title
    ,p_offer_extended_method        => p_offer_extended_method
    ,p_respondent_id                => p_respondent_id
    ,p_expiry_date                  => p_expiry_date
    ,p_proposed_start_date          => p_proposed_start_date
    ,p_offer_letter_tracking_code   => p_offer_letter_tracking_code
    ,p_offer_postal_service         => p_offer_postal_service
    ,p_offer_shipping_date          => p_offer_shipping_date
    ,p_applicant_assignment_id      => p_applicant_assignment_id
    ,p_offer_assignment_id          => p_offer_assignment_id
    ,p_address_id                   => p_address_id
    ,p_template_id                  => p_template_id
    ,p_offer_letter_file_type       => p_offer_letter_file_type
    ,p_offer_letter_file_name       => p_offer_letter_file_name
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
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_change_reason                => p_change_reason
    ,p_decline_reason               => p_decline_reason
    ,p_note_text                    => p_note_text
    ,p_status_change_date           => p_status_change_date
    ,p_offer_id                     => p_offer_id
    ,p_object_version_number        => p_object_version_number
    ,p_offer_version                => p_offer_version
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
    rollback to update_offer_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_offer_id                     := l_offer_id;
    p_object_version_number        := l_object_version_number;
    p_offer_version                := null;
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
    rollback to update_offer_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_offer_id                     := l_offer_id;
    p_object_version_number        := l_object_version_number;
    p_offer_version                := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_offer;
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_offer >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_object_version_number        in     number
  ,p_offer_id                     in     number
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_offer';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_offer_swi;
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
  irc_offers_api.delete_offer
    (p_validate                     => l_validate
    ,p_object_version_number        => p_object_version_number
    ,p_offer_id                     => p_offer_id
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
    rollback to delete_offer_swi;
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
    rollback to delete_offer_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_offer;
-- ----------------------------------------------------------------------------
-- |------------------------------< close_offer >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE close_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_applicant_assignment_id      in     number    default hr_api.g_number
  ,p_offer_id                     in     number    default hr_api.g_number
  ,p_respondent_id                in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_decline_reason               in     varchar2  default hr_api.g_varchar2
  ,p_note_text                    in     varchar2  default hr_api.g_varchar2
  ,p_status_change_date           in     date      default hr_api.g_date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'close_offer';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint close_offer_swi;
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
  irc_offers_api.close_offer
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_applicant_assignment_id      => p_applicant_assignment_id
    ,p_offer_id                     => p_offer_id
    ,p_respondent_id                => p_respondent_id
    ,p_change_reason                => p_change_reason
    ,p_decline_reason               => p_decline_reason
    ,p_note_text                    => p_note_text
    ,p_status_change_date           => p_status_change_date
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
    rollback to close_offer_swi;
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
    rollback to close_offer_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end close_offer;
-- ----------------------------------------------------------------------------
-- |------------------------------< hold_offer >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE hold_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_offer_id                     in     number
  ,p_respondent_id                in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_status_change_date           in     date      default hr_api.g_date
  ,p_note_text                    in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'hold_offer';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint hold_offer_swi;
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
  irc_offers_api.hold_offer
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_offer_id                     => p_offer_id
    ,p_respondent_id                => p_respondent_id
    ,p_change_reason                => p_change_reason
    ,p_status_change_date           => p_status_change_date
    ,p_note_text                    => p_note_text
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
    rollback to hold_offer_swi;
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
    rollback to hold_offer_swi;
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
end hold_offer;
-- ----------------------------------------------------------------------------
-- |-----------------------------< release_offer >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE release_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_offer_id                     in     number
  ,p_respondent_id                in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_status_change_date           in     date      default hr_api.g_date
  ,p_note_text                    in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'release_offer';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint release_offer_swi;
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
  irc_offers_api.release_offer
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_offer_id                     => p_offer_id
    ,p_respondent_id                => p_respondent_id
    ,p_change_reason                => p_change_reason
    ,p_status_change_date           => p_status_change_date
    ,p_note_text                    => p_note_text
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
    rollback to release_offer_swi;
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
    rollback to release_offer_swi;
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
end release_offer;
-- ----------------------------------------------------------------------------
-- |------------------------< create_offer_assignment >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_offer_assignment
  (p_assignment_id                in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_business_group_id            in     number
  ,p_recruiter_id                 in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_position_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number    default null
  ,p_location_id                  in     number    default null
  ,p_person_referred_by_id        in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_special_ceiling_step_id      in     number    default null
  ,p_person_id                    in     number
  ,p_recruitment_activity_id      in     number    default null
  ,p_source_organization_id       in     number    default null
  ,p_organization_id              in     number
  ,p_people_group_id              in     number    default null
  ,p_soft_coding_keyflex_id       in     number    default null
  ,p_vacancy_id                   in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_type              in     varchar2
  ,p_primary_flag                 in     varchar2
  ,p_application_id               in     number    default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2  default null
  ,p_comment_id                      out nocopy number
  ,p_comments                     in     varchar2  default null
  ,p_date_probation_end           in     date      default null
  ,p_default_code_comb_id         in     number    default null
  ,p_employment_category          in     varchar2  default null
  ,p_frequency                    in     varchar2  default null
  ,p_internal_address_line        in     varchar2  default null
  ,p_manager_flag                 in     varchar2  default null
  ,p_normal_hours                 in     number    default null
  ,p_perf_review_period           in     number    default null
  ,p_perf_review_period_frequency in     varchar2  default null
  ,p_period_of_service_id         in     number    default null
  ,p_probation_period             in     number    default null
  ,p_probation_unit               in     varchar2  default null
  ,p_sal_review_period            in     number    default null
  ,p_sal_review_period_frequency  in     varchar2  default null
  ,p_set_of_books_id              in     number    default null
  ,p_source_type                  in     varchar2  default null
  ,p_time_normal_finish           in     varchar2  default null
  ,p_time_normal_start            in     varchar2  default null
  ,p_bargaining_unit_code         in     varchar2  default null
  ,p_labour_union_member_flag     in     varchar2  default null
  ,p_hourly_salaried_code         in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_ass_attribute_category       in     varchar2  default null
  ,p_ass_attribute1               in     varchar2  default null
  ,p_ass_attribute2               in     varchar2  default null
  ,p_ass_attribute3               in     varchar2  default null
  ,p_ass_attribute4               in     varchar2  default null
  ,p_ass_attribute5               in     varchar2  default null
  ,p_ass_attribute6               in     varchar2  default null
  ,p_ass_attribute7               in     varchar2  default null
  ,p_ass_attribute8               in     varchar2  default null
  ,p_ass_attribute9               in     varchar2  default null
  ,p_ass_attribute10              in     varchar2  default null
  ,p_ass_attribute11              in     varchar2  default null
  ,p_ass_attribute12              in     varchar2  default null
  ,p_ass_attribute13              in     varchar2  default null
  ,p_ass_attribute14              in     varchar2  default null
  ,p_ass_attribute15              in     varchar2  default null
  ,p_ass_attribute16              in     varchar2  default null
  ,p_ass_attribute17              in     varchar2  default null
  ,p_ass_attribute18              in     varchar2  default null
  ,p_ass_attribute19              in     varchar2  default null
  ,p_ass_attribute20              in     varchar2  default null
  ,p_ass_attribute21              in     varchar2  default null
  ,p_ass_attribute22              in     varchar2  default null
  ,p_ass_attribute23              in     varchar2  default null
  ,p_ass_attribute24              in     varchar2  default null
  ,p_ass_attribute25              in     varchar2  default null
  ,p_ass_attribute26              in     varchar2  default null
  ,p_ass_attribute27              in     varchar2  default null
  ,p_ass_attribute28              in     varchar2  default null
  ,p_ass_attribute29              in     varchar2  default null
  ,p_ass_attribute30              in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_validate_df_flex             in     number    default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_contract_id                  in     number    default null
  ,p_establishment_id             in     number    default null
  ,p_collective_agreement_id      in     number    default null
  ,p_cagr_grade_def_id            in     number    default null
  ,p_cagr_id_flex_num             in     number    default null
  ,p_notice_period                in     number    default null
  ,p_notice_period_uom            in     varchar2  default null
  ,p_employee_category            in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_post_source_name         in     varchar2  default null
  ,p_posting_content_id           in     number    default null
  ,p_placement_date_start         in     date      default null
  ,p_vendor_id                    in     number    default null
  ,p_vendor_employee_number       in     varchar2  default null
  ,p_vendor_assignment_number     in     varchar2  default null
  ,p_assignment_category          in     varchar2  default null
  ,p_project_title                in     varchar2  default null
  ,p_applicant_rank               in     number    default null
  ,p_grade_ladder_pgm_id          in     number    default null
  ,p_supervisor_assignment_id     in     number    default null
  ,p_vendor_site_id               in     number    default null
  ,p_po_header_id                 in     number    default null
  ,p_po_line_id                   in     number    default null
  ,p_projected_assignment_end     in     date      default null
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate_df_flex              boolean;
  l_other_manager_warning         boolean;
  l_hourly_salaried_warning       boolean;
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_assignment_number             per_all_assignments_f.assignment_number%TYPE;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_offer_assignment';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_offer_assignment_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_assignment_number             := p_assignment_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate_df_flex :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate_df_flex);
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  per_asg_ins.set_base_key_value
    (p_assignment_id => p_assignment_id
    );
  --
  -- Call API
  --
  irc_offers_api.create_offer_assignment
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_business_group_id            => p_business_group_id
    ,p_recruiter_id                 => p_recruiter_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_person_referred_by_id        => p_person_referred_by_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_person_id                    => p_person_id
    ,p_recruitment_activity_id      => p_recruitment_activity_id
    ,p_source_organization_id       => p_source_organization_id
    ,p_organization_id              => p_organization_id
    ,p_people_group_id              => p_people_group_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_assignment_type              => p_assignment_type
    ,p_primary_flag                 => p_primary_flag
    ,p_application_id               => p_application_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comment_id                   => p_comment_id
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_period_of_service_id         => p_period_of_service_id
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_validate_df_flex             => l_validate_df_flex
    ,p_object_version_number        => p_object_version_number
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_grade_def_id            => p_cagr_grade_def_id
    ,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_notice_period                => p_notice_period
    ,p_notice_period_uom            => p_notice_period_uom
    ,p_employee_category            => p_employee_category
    ,p_work_at_home                 => p_work_at_home
    ,p_job_post_source_name         => p_job_post_source_name
    ,p_posting_content_id           => p_posting_content_id
    ,p_placement_date_start         => p_placement_date_start
    ,p_vendor_id                    => p_vendor_id
    ,p_vendor_employee_number       => p_vendor_employee_number
    ,p_vendor_assignment_number     => p_vendor_assignment_number
    ,p_assignment_category          => p_assignment_category
    ,p_project_title                => p_project_title
    ,p_applicant_rank               => p_applicant_rank
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    ,p_vendor_site_id               => p_vendor_site_id
    ,p_po_header_id                 => p_po_header_id
    ,p_po_line_id                   => p_po_line_id
    ,p_projected_assignment_end     => p_projected_assignment_end
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_other_manager_warning then
     fnd_message.set_name('PER', 'HR_289215_DUPLICATE_MANAGERS');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_hourly_salaried_warning then
     fnd_message.set_name('PER', 'HR_289648_CWK_HR_CODE_NOT_NULL');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
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
    rollback to create_offer_assignment_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_assignment_id                := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_assignment_sequence          := null;
    p_assignment_number            := l_assignment_number;
    p_comment_id                   := null;
    p_object_version_number        := null;
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
    rollback to create_offer_assignment_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_assignment_id                := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_assignment_sequence          := null;
    p_assignment_number            := l_assignment_number;
    p_comment_id                   := null;
    p_object_version_number        := null;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_offer_assignment;
-- ----------------------------------------------------------------------------
-- |------------------------< update_offer_assignment >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_offer_assignment
  (p_assignment_id                in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_business_group_id               out nocopy number
  ,p_recruiter_id                 in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_person_referred_by_id        in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_special_ceiling_step_id      in     number    default hr_api.g_number
  ,p_recruitment_activity_id      in     number    default hr_api.g_number
  ,p_source_organization_id       in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_people_group_id              in     number    default hr_api.g_number
  ,p_soft_coding_keyflex_id       in     number    default hr_api.g_number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_pay_basis_id                 in     number    default hr_api.g_number
  ,p_assignment_type              in     varchar2  default hr_api.g_varchar2
  ,p_primary_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_application_id               in     number    default hr_api.g_number
  ,p_assignment_number            in     varchar2  default hr_api.g_varchar2
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_comment_id                      out nocopy number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_date_probation_end           in     date      default hr_api.g_date
  ,p_default_code_comb_id         in     number    default hr_api.g_number
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2  default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_perf_review_period           in     number    default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2  default hr_api.g_varchar2
  ,p_period_of_service_id         in     number    default hr_api.g_number
  ,p_probation_period             in     number    default hr_api.g_number
  ,p_probation_unit               in     varchar2  default hr_api.g_varchar2
  ,p_sal_review_period            in     number    default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2  default hr_api.g_varchar2
  ,p_set_of_books_id              in     number    default hr_api.g_number
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2  default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2  default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2  default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_ass_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_contract_id                  in     number    default hr_api.g_number
  ,p_establishment_id             in     number    default hr_api.g_number
  ,p_collective_agreement_id      in     number    default hr_api.g_number
  ,p_cagr_grade_def_id            in     number    default hr_api.g_number
  ,p_cagr_id_flex_num             in     number    default hr_api.g_number
  ,p_asg_object_version_number    in out nocopy number
  ,p_notice_period                in     number    default hr_api.g_number
  ,p_notice_period_uom            in     varchar2  default hr_api.g_varchar2
  ,p_employee_category            in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_job_post_source_name         in     varchar2  default hr_api.g_varchar2
  ,p_posting_content_id           in     number    default hr_api.g_number
  ,p_placement_date_start         in     date      default hr_api.g_date
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_vendor_employee_number       in     varchar2  default hr_api.g_varchar2
  ,p_vendor_assignment_number     in     varchar2  default hr_api.g_varchar2
  ,p_assignment_category          in     varchar2  default hr_api.g_varchar2
  ,p_project_title                in     varchar2  default hr_api.g_varchar2
  ,p_applicant_rank               in     number    default hr_api.g_number
  ,p_grade_ladder_pgm_id          in     number    default hr_api.g_number
  ,p_supervisor_assignment_id     in     number    default hr_api.g_number
  ,p_vendor_site_id               in     number    default hr_api.g_number
  ,p_po_header_id                 in     number    default hr_api.g_number
  ,p_po_line_id                   in     number    default hr_api.g_number
  ,p_projected_assignment_end     in     date      default hr_api.g_date
  ,p_payroll_id_updated              out nocopy number
  ,p_validation_start_date           out nocopy date
  ,p_validation_end_date             out nocopy date
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_datetrack_mode               in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_offer_id                     in out nocopy number
  ,p_offer_status                 in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_payroll_id_updated            boolean;
  l_other_manager_warning         boolean;
  l_hourly_salaried_warning       boolean;
  l_no_managers_warning           boolean;
  l_org_now_no_manager_warning    boolean;
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_assignment_id                 number;
  l_asg_object_version_number     number;
  l_offer_id                      number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_offer_assignment';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_offer_assignment_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_assignment_id                 := p_assignment_id;
  l_asg_object_version_number     := p_asg_object_version_number;
  l_offer_id                      := p_offer_id;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_payroll_id_updated :=
    hr_api.constant_to_boolean
      (p_constant_value => p_payroll_id_updated);
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  irc_offers_api.update_offer_assignment
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_business_group_id            => p_business_group_id
    ,p_recruiter_id                 => p_recruiter_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_person_referred_by_id        => p_person_referred_by_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_recruitment_activity_id      => p_recruitment_activity_id
    ,p_source_organization_id       => p_source_organization_id
    ,p_organization_id              => p_organization_id
    ,p_people_group_id              => p_people_group_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_assignment_type              => p_assignment_type
    ,p_primary_flag                 => p_primary_flag
    ,p_application_id               => p_application_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comment_id                   => p_comment_id
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_period_of_service_id         => p_period_of_service_id
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_grade_def_id            => p_cagr_grade_def_id
    ,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_asg_object_version_number    => p_asg_object_version_number
    ,p_notice_period                => p_notice_period
    ,p_notice_period_uom            => p_notice_period_uom
    ,p_employee_category            => p_employee_category
    ,p_work_at_home                 => p_work_at_home
    ,p_job_post_source_name         => p_job_post_source_name
    ,p_posting_content_id           => p_posting_content_id
    ,p_placement_date_start         => p_placement_date_start
    ,p_vendor_id                    => p_vendor_id
    ,p_vendor_employee_number       => p_vendor_employee_number
    ,p_vendor_assignment_number     => p_vendor_assignment_number
    ,p_assignment_category          => p_assignment_category
    ,p_project_title                => p_project_title
    ,p_applicant_rank               => p_applicant_rank
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    ,p_vendor_site_id               => p_vendor_site_id
    ,p_po_header_id                 => p_po_header_id
    ,p_po_line_id                   => p_po_line_id
    ,p_projected_assignment_end     => p_projected_assignment_end
    ,p_payroll_id_updated           => l_payroll_id_updated
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_validation_start_date        => p_validation_start_date
    ,p_validation_end_date          => p_validation_end_date
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_validate                     => l_validate
    ,p_offer_id                     => p_offer_id
    ,p_offer_status                 => p_offer_status
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_other_manager_warning then
     fnd_message.set_name('PER', 'HR_289215_DUPLICATE_MANAGERS');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_hourly_salaried_warning then
     fnd_message.set_name('PER', 'HR_289648_CWK_HR_CODE_NOT_NULL');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_no_managers_warning then
     fnd_message.set_name('PER', 'HR_289214_NO_MANAGERS');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_org_now_no_manager_warning then
     fnd_message.set_name('PER', 'HR_7429_ASG_INV_MANAGER_FLAG');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  --
  -- Convert API non-warning boolean parameter values
  --
  p_payroll_id_updated :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_payroll_id_updated
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
    rollback to update_offer_assignment_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_assignment_id                := l_assignment_id;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_business_group_id            := null;
    p_comment_id                   := null;
    p_asg_object_version_number    := l_asg_object_version_number;
    p_payroll_id_updated           := null;
    p_validation_start_date        := null;
    p_validation_end_date          := null;
    p_offer_id                     := l_offer_id;
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
    rollback to update_offer_assignment_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_assignment_id                := l_assignment_id;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_business_group_id            := null;
    p_comment_id                   := null;
    p_asg_object_version_number    := l_asg_object_version_number;
    p_payroll_id_updated           := null;
    p_validation_start_date        := null;
    p_validation_end_date          := null;
    p_offer_id                     := l_offer_id;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_offer_assignment;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_offer_assignment >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_offer_assignment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_offer_assignment_id          in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_offer_assignment';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_offer_assignment_swi;
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
  irc_offers_api.delete_offer_assignment
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_offer_assignment_id          => p_offer_assignment_id
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
    rollback to delete_offer_assignment_swi;
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
    rollback to delete_offer_assignment_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_offer_assignment;
-- ----------------------------------------------------------------------------
-- |--------------------------< upload_offer_letter >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upload_offer_letter
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_offer_letter                 in     BLOB
  ,p_offer_id                     in     number
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
  l_proc    varchar2(72) := g_package ||'upload_offer_letter';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint upload_offer_letter_swi;
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
  irc_offers_api.upload_offer_letter
    (p_validate                     => l_validate
    ,p_offer_letter                 => p_offer_letter
    ,p_offer_id                     => p_offer_id
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
    rollback to upload_offer_letter_swi;
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
    rollback to upload_offer_letter_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end upload_offer_letter;
-- ----------------------------------------------------------------------------
-- |--------------------< is_run_benmgle_for_irec_reqd >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE is_run_benmgle_for_irec_reqd
  (p_assignment_id                in     number
  ,p_effective_start_date         in     date      default trunc(sysdate)
  ,p_effective_end_date           in     date      default hr_api.g_eot
  ,p_business_group_id            in     number
  ,p_recruiter_id                 in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_position_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number    default null
  ,p_location_id                  in     number    default null
  ,p_person_referred_by_id        in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_special_ceiling_step_id      in     number    default null
  ,p_person_id                    in     number
  ,p_recruitment_activity_id      in     number    default null
  ,p_source_organization_id       in     number    default null
  ,p_organization_id              in     number
  ,p_people_group_id              in     number    default null
  ,p_soft_coding_keyflex_id       in     number    default null
  ,p_vacancy_id                   in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_assignment_sequence          in     number    default 1
  ,p_assignment_type              in     varchar2
  ,p_primary_flag                 in     varchar2
  ,p_application_id               in     number    default null
  ,p_assignment_number            in     varchar2  default null
  ,p_change_reason                in     varchar2  default null
  ,p_comment_id                   in     number    default null
  ,p_date_probation_end           in     date      default null
  ,p_default_code_comb_id         in     number    default null
  ,p_employment_category          in     varchar2  default null
  ,p_frequency                    in     varchar2  default null
  ,p_internal_address_line        in     varchar2  default null
  ,p_manager_flag                 in     varchar2  default null
  ,p_normal_hours                 in     number    default null
  ,p_perf_review_period           in     number    default null
  ,p_perf_review_period_frequency in     varchar2  default null
  ,p_period_of_service_id         in     number    default null
  ,p_probation_period             in     number    default null
  ,p_probation_unit               in     varchar2  default null
  ,p_sal_review_period            in     number    default null
  ,p_sal_review_period_frequency  in     varchar2  default null
  ,p_set_of_books_id              in     number    default null
  ,p_source_type                  in     varchar2  default null
  ,p_time_normal_finish           in     varchar2  default null
  ,p_time_normal_start            in     varchar2  default null
  ,p_bargaining_unit_code         in     varchar2  default null
  ,p_labour_union_member_flag     in     varchar2  default null
  ,p_hourly_salaried_code         in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_ass_attribute_category       in     varchar2  default null
  ,p_ass_attribute1               in     varchar2  default null
  ,p_ass_attribute2               in     varchar2  default null
  ,p_ass_attribute3               in     varchar2  default null
  ,p_ass_attribute4               in     varchar2  default null
  ,p_ass_attribute5               in     varchar2  default null
  ,p_ass_attribute6               in     varchar2  default null
  ,p_ass_attribute7               in     varchar2  default null
  ,p_ass_attribute8               in     varchar2  default null
  ,p_ass_attribute9               in     varchar2  default null
  ,p_ass_attribute10              in     varchar2  default null
  ,p_ass_attribute11              in     varchar2  default null
  ,p_ass_attribute12              in     varchar2  default null
  ,p_ass_attribute13              in     varchar2  default null
  ,p_ass_attribute14              in     varchar2  default null
  ,p_ass_attribute15              in     varchar2  default null
  ,p_ass_attribute16              in     varchar2  default null
  ,p_ass_attribute17              in     varchar2  default null
  ,p_ass_attribute18              in     varchar2  default null
  ,p_ass_attribute19              in     varchar2  default null
  ,p_ass_attribute20              in     varchar2  default null
  ,p_ass_attribute21              in     varchar2  default null
  ,p_ass_attribute22              in     varchar2  default null
  ,p_ass_attribute23              in     varchar2  default null
  ,p_ass_attribute24              in     varchar2  default null
  ,p_ass_attribute25              in     varchar2  default null
  ,p_ass_attribute26              in     varchar2  default null
  ,p_ass_attribute27              in     varchar2  default null
  ,p_ass_attribute28              in     varchar2  default null
  ,p_ass_attribute29              in     varchar2  default null
  ,p_ass_attribute30              in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_object_version_number        in     number    default 1
  ,p_contract_id                  in     number    default null
  ,p_establishment_id             in     number    default null
  ,p_collective_agreement_id      in     number    default null
  ,p_cagr_grade_def_id            in     number    default null
  ,p_cagr_id_flex_num             in     number    default null
  ,p_notice_period                in     number    default null
  ,p_notice_period_uom            in     varchar2  default null
  ,p_employee_category            in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_post_source_name         in     varchar2  default null
  ,p_posting_content_id           in     number    default null
  ,p_placement_date_start         in     date      default null
  ,p_vendor_id                    in     number    default null
  ,p_vendor_employee_number       in     varchar2  default null
  ,p_vendor_assignment_number     in     varchar2  default null
  ,p_assignment_category          in     varchar2  default null
  ,p_project_title                in     varchar2  default null
  ,p_applicant_rank               in     number    default null
  ,p_grade_ladder_pgm_id          in     number    default null
  ,p_supervisor_assignment_id     in     number    default null
  ,p_vendor_site_id               in     number    default null
  ,p_po_header_id                 in     number    default null
  ,p_po_line_id                   in     number    default null
  ,p_projected_assignment_end     in     date      default null
  ,p_effective_date               in     date
  --
  -- pay proposal details
  --
  ,p_pay_proposal_id              in     number
  ,p_event_id                     in     number    default null
  ,p_change_date                  in     date      default null
  ,p_last_change_date             in     date      default null
  ,p_next_perf_review_date        in     date      default null
  ,p_next_sal_review_date         in     date      default null
  ,p_performance_rating           in     varchar2  default null
  ,p_proposal_reason              in     varchar2  default null
  ,p_proposed_salary              in     varchar2  default null
  ,p_review_date                  in     date      default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_pay_proposal_ovn             in     number    default null
  ,p_approved                     in     varchar2  default null
  ,p_multiple_components          in     varchar2  default null
  ,p_forced_ranking               in     number    default null
  ,p_performance_review_id        in     number    default null
  ,p_proposed_salary_n            in     number    default null
  ,p_comments                     in     long      default null
  --
  ,p_is_run_reqd                  out nocopy varchar2
  ,p_return_status                out nocopy varchar2
  ) is
  --
  l_proc                           varchar2(72) := g_package ||'is_run_benmgle_for_irec_reqd';
  l_offer_assignment_record        per_all_assignments_f%rowtype;
  l_pay_proposal_record            per_pay_proposals%rowtype;
  --
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint IS_RUN_BENMGLE_FOR_IREC_REQD;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Create an assignment record
  --
  l_offer_assignment_record.assignment_id               :=  p_assignment_id;
  l_offer_assignment_record.effective_start_date        :=  p_effective_start_date;
  l_offer_assignment_record.effective_end_date          :=  p_effective_end_date;
  l_offer_assignment_record.business_group_id           :=  p_business_group_id;
  l_offer_assignment_record.recruiter_id                :=  p_recruiter_id;
  l_offer_assignment_record.grade_id                    :=  p_grade_id;
  l_offer_assignment_record.position_id                 :=  p_position_id;
  l_offer_assignment_record.job_id                      :=  p_job_id;
  l_offer_assignment_record.assignment_status_type_id   :=  p_assignment_status_type_id;
  l_offer_assignment_record.payroll_id                  :=  p_payroll_id;
  l_offer_assignment_record.location_id                 :=  p_location_id;
  l_offer_assignment_record.person_referred_by_id       :=  p_person_referred_by_id;
  l_offer_assignment_record.supervisor_id               :=  p_supervisor_id;
  l_offer_assignment_record.special_ceiling_step_id     :=  p_special_ceiling_step_id;
  l_offer_assignment_record.person_id                   :=  p_person_id;
  l_offer_assignment_record.recruitment_activity_id     :=  p_recruitment_activity_id;
  l_offer_assignment_record.source_organization_id      :=  p_source_organization_id;
  l_offer_assignment_record.organization_id             :=  p_organization_id;
  l_offer_assignment_record.people_group_id             :=  p_people_group_id;
  l_offer_assignment_record.soft_coding_keyflex_id      :=  p_soft_coding_keyflex_id;
  l_offer_assignment_record.vacancy_id                  :=  p_vacancy_id;
  l_offer_assignment_record.pay_basis_id                :=  p_pay_basis_id;
  l_offer_assignment_record.assignment_sequence         :=  p_assignment_sequence;
  l_offer_assignment_record.assignment_type             :=  p_assignment_type;
  l_offer_assignment_record.primary_flag                :=  p_primary_flag;
  l_offer_assignment_record.application_id              :=  p_application_id;
  l_offer_assignment_record.assignment_number           :=  p_assignment_number;
  l_offer_assignment_record.change_reason               :=  p_change_reason;
  l_offer_assignment_record.comment_id                  :=  p_comment_id;
  l_offer_assignment_record.date_probation_end          :=  p_date_probation_end;
  l_offer_assignment_record.default_code_comb_id        :=  p_default_code_comb_id;
  l_offer_assignment_record.employment_category         :=  p_employment_category;
  l_offer_assignment_record.frequency                   :=  p_frequency;
  l_offer_assignment_record.internal_address_line       :=  p_internal_address_line;
  l_offer_assignment_record.manager_flag                :=  p_manager_flag;
  l_offer_assignment_record.normal_hours                :=  p_normal_hours;
  l_offer_assignment_record.perf_review_period          :=  p_perf_review_period;
  l_offer_assignment_record.perf_review_period_frequency:=  p_perf_review_period_frequency;
  l_offer_assignment_record.period_of_service_id        :=  p_period_of_service_id;
  l_offer_assignment_record.probation_period            :=  p_probation_period;
  l_offer_assignment_record.probation_unit              :=  p_probation_unit;
  l_offer_assignment_record.sal_review_period           :=  p_sal_review_period;
  l_offer_assignment_record.sal_review_period_frequency :=  p_sal_review_period_frequency;
  l_offer_assignment_record.set_of_books_id             :=  p_set_of_books_id;
  l_offer_assignment_record.source_type                 :=  p_source_type;
  l_offer_assignment_record.time_normal_finish          :=  p_time_normal_finish;
  l_offer_assignment_record.time_normal_start           :=  p_time_normal_start;
  l_offer_assignment_record.bargaining_unit_code        :=  p_bargaining_unit_code;
  l_offer_assignment_record.labour_union_member_flag    :=  p_labour_union_member_flag;
  l_offer_assignment_record.hourly_salaried_code        :=  p_hourly_salaried_code;
  l_offer_assignment_record.request_id                  :=  p_request_id;
  l_offer_assignment_record.program_application_id      :=  p_program_application_id;
  l_offer_assignment_record.program_id                  :=  p_program_id;
  l_offer_assignment_record.program_update_date         :=  p_program_update_date;
  l_offer_assignment_record.ass_attribute_category      :=  p_ass_attribute_category;
  l_offer_assignment_record.ass_attribute1              :=  p_ass_attribute1;
  l_offer_assignment_record.ass_attribute2              :=  p_ass_attribute2;
  l_offer_assignment_record.ass_attribute3              :=  p_ass_attribute3;
  l_offer_assignment_record.ass_attribute4              :=  p_ass_attribute4;
  l_offer_assignment_record.ass_attribute5              :=  p_ass_attribute5;
  l_offer_assignment_record.ass_attribute6              :=  p_ass_attribute6;
  l_offer_assignment_record.ass_attribute7              :=  p_ass_attribute7;
  l_offer_assignment_record.ass_attribute8              :=  p_ass_attribute8;
  l_offer_assignment_record.ass_attribute9              :=  p_ass_attribute9;
  l_offer_assignment_record.ass_attribute10             :=  p_ass_attribute10;
  l_offer_assignment_record.ass_attribute11             :=  p_ass_attribute11;
  l_offer_assignment_record.ass_attribute12             :=  p_ass_attribute12;
  l_offer_assignment_record.ass_attribute13             :=  p_ass_attribute13;
  l_offer_assignment_record.ass_attribute14             :=  p_ass_attribute14;
  l_offer_assignment_record.ass_attribute15             :=  p_ass_attribute15;
  l_offer_assignment_record.ass_attribute16             :=  p_ass_attribute16;
  l_offer_assignment_record.ass_attribute17             :=  p_ass_attribute17;
  l_offer_assignment_record.ass_attribute18             :=  p_ass_attribute18;
  l_offer_assignment_record.ass_attribute19             :=  p_ass_attribute19;
  l_offer_assignment_record.ass_attribute20             :=  p_ass_attribute20;
  l_offer_assignment_record.ass_attribute21             :=  p_ass_attribute21;
  l_offer_assignment_record.ass_attribute22             :=  p_ass_attribute22;
  l_offer_assignment_record.ass_attribute23             :=  p_ass_attribute23;
  l_offer_assignment_record.ass_attribute24             :=  p_ass_attribute24;
  l_offer_assignment_record.ass_attribute25             :=  p_ass_attribute25;
  l_offer_assignment_record.ass_attribute26             :=  p_ass_attribute26;
  l_offer_assignment_record.ass_attribute27             :=  p_ass_attribute27;
  l_offer_assignment_record.ass_attribute28             :=  p_ass_attribute28;
  l_offer_assignment_record.ass_attribute29             :=  p_ass_attribute29;
  l_offer_assignment_record.ass_attribute30             :=  p_ass_attribute30;
  l_offer_assignment_record.title                       :=  p_title;
  l_offer_assignment_record.object_version_number       :=  p_object_version_number;
  l_offer_assignment_record.contract_id                 :=  p_contract_id;
  l_offer_assignment_record.establishment_id            :=  p_establishment_id;
  l_offer_assignment_record.collective_agreement_id     :=  p_collective_agreement_id;
  l_offer_assignment_record.cagr_grade_def_id           :=  p_cagr_grade_def_id;
  l_offer_assignment_record.cagr_id_flex_num            :=  p_cagr_id_flex_num;
  l_offer_assignment_record.notice_period               :=  p_notice_period;
  l_offer_assignment_record.notice_period_uom           :=  p_notice_period_uom;
  l_offer_assignment_record.employee_category           :=  p_employee_category;
  l_offer_assignment_record.work_at_home                :=  p_work_at_home;
  l_offer_assignment_record.job_post_source_name        :=  p_job_post_source_name;
  l_offer_assignment_record.posting_content_id          :=  p_posting_content_id;
  l_offer_assignment_record.period_of_placement_date_start  :=  p_placement_date_start;
  l_offer_assignment_record.vendor_id                   :=  p_vendor_id;
  l_offer_assignment_record.vendor_employee_number      :=  p_vendor_employee_number;
  l_offer_assignment_record.vendor_assignment_number    :=  p_vendor_assignment_number;
  l_offer_assignment_record.assignment_category         :=  p_assignment_category;
  l_offer_assignment_record.project_title               :=  p_project_title;
  l_offer_assignment_record.applicant_rank              :=  p_applicant_rank;
  l_offer_assignment_record.grade_ladder_pgm_id         :=  p_grade_ladder_pgm_id;
  l_offer_assignment_record.supervisor_assignment_id    :=  p_supervisor_assignment_id;
  l_offer_assignment_record.vendor_site_id              :=  p_vendor_site_id;
  l_offer_assignment_record.po_header_id                :=  p_po_header_id;
  l_offer_assignment_record.po_line_id                  :=  p_po_line_id;
  l_offer_assignment_record.projected_assignment_end    :=  p_projected_assignment_end;
  --
  -- Create a Pay Proposal Record
  --
  l_pay_proposal_record.pay_proposal_id        := p_pay_proposal_id;
  l_pay_proposal_record.assignment_id          := p_assignment_id;
  l_pay_proposal_record.event_id               := p_event_id;
  l_pay_proposal_record.business_group_id      := p_business_group_id;
  l_pay_proposal_record.change_date            := p_change_date;
  l_pay_proposal_record.last_change_date       := p_last_change_date;
  l_pay_proposal_record.next_perf_review_date  := p_next_perf_review_date;
  l_pay_proposal_record.next_sal_review_date   := p_next_sal_review_date;
  l_pay_proposal_record.performance_rating     := p_performance_rating;
  l_pay_proposal_record.proposal_reason        := p_proposal_reason;
  l_pay_proposal_record.proposed_salary        := p_proposed_salary;
  l_pay_proposal_record.review_date            := p_review_date;
  l_pay_proposal_record.attribute_category     := p_attribute_category;
  l_pay_proposal_record.attribute1             := p_attribute1;
  l_pay_proposal_record.attribute2             := p_attribute2;
  l_pay_proposal_record.attribute3             := p_attribute3;
  l_pay_proposal_record.attribute4             := p_attribute4;
  l_pay_proposal_record.attribute5             := p_attribute5;
  l_pay_proposal_record.attribute6             := p_attribute6;
  l_pay_proposal_record.attribute7             := p_attribute7;
  l_pay_proposal_record.attribute8             := p_attribute8;
  l_pay_proposal_record.attribute9             := p_attribute9;
  l_pay_proposal_record.attribute10            := p_attribute10;
  l_pay_proposal_record.attribute11            := p_attribute11;
  l_pay_proposal_record.attribute12            := p_attribute12;
  l_pay_proposal_record.attribute13            := p_attribute13;
  l_pay_proposal_record.attribute14            := p_attribute14;
  l_pay_proposal_record.attribute15            := p_attribute15;
  l_pay_proposal_record.attribute16            := p_attribute16;
  l_pay_proposal_record.attribute17            := p_attribute17;
  l_pay_proposal_record.attribute18            := p_attribute18;
  l_pay_proposal_record.attribute19            := p_attribute19;
  l_pay_proposal_record.attribute20            := p_attribute20;
  l_pay_proposal_record.object_version_number  := p_pay_proposal_ovn;
  l_pay_proposal_record.approved               := p_approved;
  l_pay_proposal_record.multiple_components    := p_multiple_components;
  l_pay_proposal_record.forced_ranking         := p_forced_ranking;
  l_pay_proposal_record.performance_review_id  := p_performance_review_id;
  l_pay_proposal_record.proposed_salary_n      := p_proposed_salary_n;
  l_pay_proposal_record.comments               := p_comments;
  --
  if(g_old_offer_assignment_record.assignment_id <> p_assignment_id)
  then
    g_old_offer_assignment_record := null;
  end if;

  if(g_old_pay_proposal_record.assignment_id <> p_assignment_id)
  then
    g_old_pay_proposal_record := null;
  end if;
  --
  p_is_run_reqd :=
    ben_irc_util.is_benmngle_for_irec_reqd
    (  p_person_id                 => p_person_id
      ,p_assignment_id             => p_assignment_id
      ,p_business_group_id         => p_business_group_id
      ,p_effective_date            => p_effective_date
      ,p_pay_proposal_rec_old      => g_old_pay_proposal_record
      ,p_pay_proposal_rec_new      => l_pay_proposal_record
      ,p_offer_assignment_rec_old  => g_old_offer_assignment_record
      ,p_offer_assignment_rec_new  => l_offer_assignment_record
    );
  --
  -- Set the old record values to the current ones
  --
  g_old_offer_assignment_record := l_offer_assignment_record;
  g_old_pay_proposal_record     := l_pay_proposal_record;
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
    rollback to IS_RUN_BENMGLE_FOR_IREC_REQD;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    p_is_run_reqd   := 'N';
    --
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to IS_RUN_BENMGLE_FOR_IREC_REQD;
    --
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    p_is_run_reqd   := 'N';
    --
    hr_utility.set_location(' Leaving:' || l_proc,50);
    --
end is_run_benmgle_for_irec_reqd;
-- ----------------------------------------------------------------------------
-- |-------------------------< run_benmgle_for_irec >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE run_benmgle_for_irec
  (p_assignment_id                in     number
  ,p_effective_start_date         in     date      default trunc(sysdate)
  ,p_effective_end_date           in     date      default hr_api.g_eot
  ,p_business_group_id            in     number
  ,p_recruiter_id                 in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_position_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number    default null
  ,p_location_id                  in     number    default null
  ,p_person_referred_by_id        in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_special_ceiling_step_id      in     number    default null
  ,p_person_id                    in     number
  ,p_recruitment_activity_id      in     number    default null
  ,p_source_organization_id       in     number    default null
  ,p_organization_id              in     number
  ,p_people_group_id              in     number    default null
  ,p_soft_coding_keyflex_id       in     number    default null
  ,p_vacancy_id                   in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_assignment_sequence          in     number    default 1
  ,p_assignment_type              in     varchar2
  ,p_primary_flag                 in     varchar2
  ,p_application_id               in     number    default null
  ,p_assignment_number            in     varchar2  default null
  ,p_change_reason                in     varchar2  default null
  ,p_comment_id                   in     number    default null
  ,p_date_probation_end           in     date      default null
  ,p_default_code_comb_id         in     number    default null
  ,p_employment_category          in     varchar2  default null
  ,p_frequency                    in     varchar2  default null
  ,p_internal_address_line        in     varchar2  default null
  ,p_manager_flag                 in     varchar2  default null
  ,p_normal_hours                 in     number    default null
  ,p_perf_review_period           in     number    default null
  ,p_perf_review_period_frequency in     varchar2  default null
  ,p_period_of_service_id         in     number    default null
  ,p_probation_period             in     number    default null
  ,p_probation_unit               in     varchar2  default null
  ,p_sal_review_period            in     number    default null
  ,p_sal_review_period_frequency  in     varchar2  default null
  ,p_set_of_books_id              in     number    default null
  ,p_source_type                  in     varchar2  default null
  ,p_time_normal_finish           in     varchar2  default null
  ,p_time_normal_start            in     varchar2  default null
  ,p_bargaining_unit_code         in     varchar2  default null
  ,p_labour_union_member_flag     in     varchar2  default null
  ,p_hourly_salaried_code         in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_ass_attribute_category       in     varchar2  default null
  ,p_ass_attribute1               in     varchar2  default null
  ,p_ass_attribute2               in     varchar2  default null
  ,p_ass_attribute3               in     varchar2  default null
  ,p_ass_attribute4               in     varchar2  default null
  ,p_ass_attribute5               in     varchar2  default null
  ,p_ass_attribute6               in     varchar2  default null
  ,p_ass_attribute7               in     varchar2  default null
  ,p_ass_attribute8               in     varchar2  default null
  ,p_ass_attribute9               in     varchar2  default null
  ,p_ass_attribute10              in     varchar2  default null
  ,p_ass_attribute11              in     varchar2  default null
  ,p_ass_attribute12              in     varchar2  default null
  ,p_ass_attribute13              in     varchar2  default null
  ,p_ass_attribute14              in     varchar2  default null
  ,p_ass_attribute15              in     varchar2  default null
  ,p_ass_attribute16              in     varchar2  default null
  ,p_ass_attribute17              in     varchar2  default null
  ,p_ass_attribute18              in     varchar2  default null
  ,p_ass_attribute19              in     varchar2  default null
  ,p_ass_attribute20              in     varchar2  default null
  ,p_ass_attribute21              in     varchar2  default null
  ,p_ass_attribute22              in     varchar2  default null
  ,p_ass_attribute23              in     varchar2  default null
  ,p_ass_attribute24              in     varchar2  default null
  ,p_ass_attribute25              in     varchar2  default null
  ,p_ass_attribute26              in     varchar2  default null
  ,p_ass_attribute27              in     varchar2  default null
  ,p_ass_attribute28              in     varchar2  default null
  ,p_ass_attribute29              in     varchar2  default null
  ,p_ass_attribute30              in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_object_version_number        in     number    default 1
  ,p_contract_id                  in     number    default null
  ,p_establishment_id             in     number    default null
  ,p_collective_agreement_id      in     number    default null
  ,p_cagr_grade_def_id            in     number    default null
  ,p_cagr_id_flex_num             in     number    default null
  ,p_notice_period                in     number    default null
  ,p_notice_period_uom            in     varchar2  default null
  ,p_employee_category            in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_post_source_name         in     varchar2  default null
  ,p_posting_content_id           in     number    default null
  ,p_placement_date_start         in     date      default null
  ,p_vendor_id                    in     number    default null
  ,p_vendor_employee_number       in     varchar2  default null
  ,p_vendor_assignment_number     in     varchar2  default null
  ,p_assignment_category          in     varchar2  default null
  ,p_project_title                in     varchar2  default null
  ,p_applicant_rank               in     number    default null
  ,p_grade_ladder_pgm_id          in     number    default null
  ,p_supervisor_assignment_id     in     number    default null
  ,p_vendor_site_id               in     number    default null
  ,p_po_header_id                 in     number    default null
  ,p_po_line_id                   in     number    default null
  ,p_projected_assignment_end     in     date      default null
  ,p_effective_date               in     date
  ,p_return_status                out nocopy varchar2
  ) is
  --
  l_proc                       varchar2(72) := g_package ||'run_benmgle_for_irec';
  l_offer_assignment_record    per_all_assignments_f%rowtype;
  --
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint run_benmgle_for_irec;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Create an assignment record
  --
  l_offer_assignment_record.assignment_id               :=  p_assignment_id;
  l_offer_assignment_record.effective_start_date        :=  p_effective_start_date;
  l_offer_assignment_record.effective_end_date          :=  p_effective_end_date;
  l_offer_assignment_record.business_group_id           :=  p_business_group_id;
  l_offer_assignment_record.recruiter_id                :=  p_recruiter_id;
  l_offer_assignment_record.grade_id                    :=  p_grade_id;
  l_offer_assignment_record.position_id                 :=  p_position_id;
  l_offer_assignment_record.job_id                      :=  p_job_id;
  l_offer_assignment_record.assignment_status_type_id   :=  p_assignment_status_type_id;
  l_offer_assignment_record.payroll_id                  :=  p_payroll_id;
  l_offer_assignment_record.location_id                 :=  p_location_id;
  l_offer_assignment_record.person_referred_by_id       :=  p_person_referred_by_id;
  l_offer_assignment_record.supervisor_id               :=  p_supervisor_id;
  l_offer_assignment_record.special_ceiling_step_id     :=  p_special_ceiling_step_id;
  l_offer_assignment_record.person_id                   :=  p_person_id;
  l_offer_assignment_record.recruitment_activity_id     :=  p_recruitment_activity_id;
  l_offer_assignment_record.source_organization_id      :=  p_source_organization_id;
  l_offer_assignment_record.organization_id             :=  p_organization_id;
  l_offer_assignment_record.people_group_id             :=  p_people_group_id;
  l_offer_assignment_record.soft_coding_keyflex_id      :=  p_soft_coding_keyflex_id;
  l_offer_assignment_record.vacancy_id                  :=  p_vacancy_id;
  l_offer_assignment_record.pay_basis_id                :=  p_pay_basis_id;
  l_offer_assignment_record.assignment_sequence         :=  p_assignment_sequence;
  l_offer_assignment_record.assignment_type             :=  p_assignment_type;
  l_offer_assignment_record.primary_flag                :=  p_primary_flag;
  l_offer_assignment_record.application_id              :=  p_application_id;
  l_offer_assignment_record.assignment_number           :=  p_assignment_number;
  l_offer_assignment_record.change_reason               :=  p_change_reason;
  l_offer_assignment_record.comment_id                  :=  p_comment_id;
  l_offer_assignment_record.date_probation_end          :=  p_date_probation_end;
  l_offer_assignment_record.default_code_comb_id        :=  p_default_code_comb_id;
  l_offer_assignment_record.employment_category         :=  p_employment_category;
  l_offer_assignment_record.frequency                   :=  p_frequency;
  l_offer_assignment_record.internal_address_line       :=  p_internal_address_line;
  l_offer_assignment_record.manager_flag                :=  p_manager_flag;
  l_offer_assignment_record.normal_hours                :=  p_normal_hours;
  l_offer_assignment_record.perf_review_period          :=  p_perf_review_period;
  l_offer_assignment_record.perf_review_period_frequency:=  p_perf_review_period_frequency;
  l_offer_assignment_record.period_of_service_id        :=  p_period_of_service_id;
  l_offer_assignment_record.probation_period            :=  p_probation_period;
  l_offer_assignment_record.probation_unit              :=  p_probation_unit;
  l_offer_assignment_record.sal_review_period           :=  p_sal_review_period;
  l_offer_assignment_record.sal_review_period_frequency :=  p_sal_review_period_frequency;
  l_offer_assignment_record.set_of_books_id             :=  p_set_of_books_id;
  l_offer_assignment_record.source_type                 :=  p_source_type;
  l_offer_assignment_record.time_normal_finish          :=  p_time_normal_finish;
  l_offer_assignment_record.time_normal_start           :=  p_time_normal_start;
  l_offer_assignment_record.bargaining_unit_code        :=  p_bargaining_unit_code;
  l_offer_assignment_record.labour_union_member_flag    :=  p_labour_union_member_flag;
  l_offer_assignment_record.hourly_salaried_code        :=  p_hourly_salaried_code;
  l_offer_assignment_record.request_id                  :=  p_request_id;
  l_offer_assignment_record.program_application_id      :=  p_program_application_id;
  l_offer_assignment_record.program_id                  :=  p_program_id;
  l_offer_assignment_record.program_update_date         :=  p_program_update_date;
  l_offer_assignment_record.ass_attribute_category      :=  p_ass_attribute_category;
  l_offer_assignment_record.ass_attribute1              :=  p_ass_attribute1;
  l_offer_assignment_record.ass_attribute2              :=  p_ass_attribute2;
  l_offer_assignment_record.ass_attribute3              :=  p_ass_attribute3;
  l_offer_assignment_record.ass_attribute4              :=  p_ass_attribute4;
  l_offer_assignment_record.ass_attribute5              :=  p_ass_attribute5;
  l_offer_assignment_record.ass_attribute6              :=  p_ass_attribute6;
  l_offer_assignment_record.ass_attribute7              :=  p_ass_attribute7;
  l_offer_assignment_record.ass_attribute8              :=  p_ass_attribute8;
  l_offer_assignment_record.ass_attribute9              :=  p_ass_attribute9;
  l_offer_assignment_record.ass_attribute10             :=  p_ass_attribute10;
  l_offer_assignment_record.ass_attribute11             :=  p_ass_attribute11;
  l_offer_assignment_record.ass_attribute12             :=  p_ass_attribute12;
  l_offer_assignment_record.ass_attribute13             :=  p_ass_attribute13;
  l_offer_assignment_record.ass_attribute14             :=  p_ass_attribute14;
  l_offer_assignment_record.ass_attribute15             :=  p_ass_attribute15;
  l_offer_assignment_record.ass_attribute16             :=  p_ass_attribute16;
  l_offer_assignment_record.ass_attribute17             :=  p_ass_attribute17;
  l_offer_assignment_record.ass_attribute18             :=  p_ass_attribute18;
  l_offer_assignment_record.ass_attribute19             :=  p_ass_attribute19;
  l_offer_assignment_record.ass_attribute20             :=  p_ass_attribute20;
  l_offer_assignment_record.ass_attribute21             :=  p_ass_attribute21;
  l_offer_assignment_record.ass_attribute22             :=  p_ass_attribute22;
  l_offer_assignment_record.ass_attribute23             :=  p_ass_attribute23;
  l_offer_assignment_record.ass_attribute24             :=  p_ass_attribute24;
  l_offer_assignment_record.ass_attribute25             :=  p_ass_attribute25;
  l_offer_assignment_record.ass_attribute26             :=  p_ass_attribute26;
  l_offer_assignment_record.ass_attribute27             :=  p_ass_attribute27;
  l_offer_assignment_record.ass_attribute28             :=  p_ass_attribute28;
  l_offer_assignment_record.ass_attribute29             :=  p_ass_attribute29;
  l_offer_assignment_record.ass_attribute30             :=  p_ass_attribute30;
  l_offer_assignment_record.title                       :=  p_title;
  l_offer_assignment_record.object_version_number       :=  p_object_version_number;
  l_offer_assignment_record.contract_id                 :=  p_contract_id;
  l_offer_assignment_record.establishment_id            :=  p_establishment_id;
  l_offer_assignment_record.collective_agreement_id     :=  p_collective_agreement_id;
  l_offer_assignment_record.cagr_grade_def_id           :=  p_cagr_grade_def_id;
  l_offer_assignment_record.cagr_id_flex_num            :=  p_cagr_id_flex_num;
  l_offer_assignment_record.notice_period               :=  p_notice_period;
  l_offer_assignment_record.notice_period_uom           :=  p_notice_period_uom;
  l_offer_assignment_record.employee_category           :=  p_employee_category;
  l_offer_assignment_record.work_at_home                :=  p_work_at_home;
  l_offer_assignment_record.job_post_source_name        :=  p_job_post_source_name;
  l_offer_assignment_record.posting_content_id          :=  p_posting_content_id;
  l_offer_assignment_record.period_of_placement_date_start  :=  p_placement_date_start;
  l_offer_assignment_record.vendor_id                   :=  p_vendor_id;
  l_offer_assignment_record.vendor_employee_number      :=  p_vendor_employee_number;
  l_offer_assignment_record.vendor_assignment_number    :=  p_vendor_assignment_number;
  l_offer_assignment_record.assignment_category         :=  p_assignment_category;
  l_offer_assignment_record.project_title               :=  p_project_title;
  l_offer_assignment_record.applicant_rank              :=  p_applicant_rank;
  l_offer_assignment_record.grade_ladder_pgm_id         :=  p_grade_ladder_pgm_id;
  l_offer_assignment_record.supervisor_assignment_id    :=  p_supervisor_assignment_id;
  l_offer_assignment_record.vendor_site_id              :=  p_vendor_site_id;
  l_offer_assignment_record.po_header_id                :=  p_po_header_id;
  l_offer_assignment_record.po_line_id                  :=  p_po_line_id;
  l_offer_assignment_record.projected_assignment_end    :=  p_projected_assignment_end;
  --
  -- Call The benifits wrapper for iRec
  --
  ben_on_line_lf_evt.p_manage_irec_life_events_w
  (
     p_person_id             => p_person_id
    ,p_assignment_id         => p_assignment_id
    ,p_effective_date        => p_effective_date
    ,p_business_group_id     => p_business_group_id
    ,p_offer_assignment_rec  => l_offer_assignment_record
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
    rollback to run_benmgle_for_irec;
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
    rollback to run_benmgle_for_irec;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
    --
end run_benmgle_for_irec;
--
 --Save For Later Code Changes
-- ----------------------------------------------------------------------------
-- |-------------------------< process_offers_api >---------------------------|
-- ----------------------------------------------------------------------------

procedure process_offers_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState VARCHAR2(2);
   l_return_status VARCHAR2(1);
   l_object_version_number number;
   l_commitElement xmldom.DOMElement;
   l_parser xmlparser.Parser;
   l_CommitNode xmldom.DOMNode;
   l_proc    varchar2(72) := g_package || 'process_offers_api';

   -- Variables for OUT parameters
   l_offer_id                      number;
   l_offer_version                 number;
   l_offer_status                  varchar(10);
   l_effective_date                date  :=  trunc(sysdate);
   --
   cursor current_offer_ovn(p_offer_id NUMBER) is
   select object_version_number
     from irc_offers
    where offer_id = p_offer_id;
   --

BEGIN
--
   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);
--
   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));
--
   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');
--
--Get the values for in/out parameters
--
   l_offer_id  :=  hr_transaction_swi.getNumberValue(l_CommitNode,'OfferId');
--
   open current_offer_ovn(l_offer_id);
   fetch current_offer_ovn into l_object_version_number;
   close current_offer_ovn;
--
   l_offer_version  := hr_transaction_swi.getNumberValue(l_CommitNode,'OfferVersion');
   l_offer_status   := hr_transaction_swi.getVarchar2Value(l_CommitNode,'OfferStatus');
--
   if p_effective_date is null
   then
   --
     l_effective_date := trunc(sysdate);
   --
   else
   --
     l_effective_date := p_effective_date;
   --
   end if;
--
   if l_postState = '2' then
     -- call update offer
     --
     update_offer
     (p_validate                     =>       p_validate
     ,p_effective_date               =>       l_effective_date
     ,p_offer_status                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'OfferStatus')
     ,p_discretionary_job_title      =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DiscretionaryJobTitle')
     ,p_offer_extended_method        =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'OfferExtendedMethod')
     ,p_respondent_id                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'RespondentId')
     ,p_expiry_date                  =>       hr_transaction_swi.getDateValue(l_CommitNode,'ExpiryDate')
     ,p_proposed_start_date          =>       hr_transaction_swi.getDateValue(l_CommitNode,'ProposedStartDate')
     ,p_offer_letter_tracking_code   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'OfferLetterTrackingCode')
     ,p_offer_postal_service         =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'OfferPostalService')
     ,p_offer_shipping_date          =>       hr_transaction_swi.getDateValue(l_CommitNode,'OfferShippingDate')
     ,p_applicant_assignment_id      =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ApplicantAssignmentId')
     ,p_offer_assignment_id          =>       hr_transaction_swi.getNumberValue(l_CommitNode,'OfferAssignmentId')
     ,p_address_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'AddressId')
     ,p_template_id                  =>       hr_transaction_swi.getNumberValue(l_CommitNode,'TemplateId')
     ,p_offer_letter_file_type       =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'OfferLetterFileType')
     ,p_offer_letter_file_name       =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'OfferLetterFileName')
     ,p_attribute_category           =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory')
     ,p_attribute1                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1')
     ,p_attribute2                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2')
     ,p_attribute3                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3')
     ,p_attribute4                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4')
     ,p_attribute5                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5')
     ,p_attribute6                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6')
     ,p_attribute7                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7')
     ,p_attribute8                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8')
     ,p_attribute9                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9')
     ,p_attribute10                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10')
     ,p_attribute11                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11')
     ,p_attribute12                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12')
     ,p_attribute13                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13')
     ,p_attribute14                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14')
     ,p_attribute15                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15')
     ,p_attribute16                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16')
     ,p_attribute17                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17')
     ,p_attribute18                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18')
     ,p_attribute19                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19')
     ,p_attribute20                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20')
     ,p_attribute21                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21')
     ,p_attribute22                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22')
     ,p_attribute23                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23')
     ,p_attribute24                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24')
     ,p_attribute25                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25')
     ,p_attribute26                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26')
     ,p_attribute27                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27')
     ,p_attribute28                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28')
     ,p_attribute29                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29')
     ,p_attribute30                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30')
     ,p_change_reason                =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'ChangeReason',null)
     ,p_decline_reason               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DeclineReason',null)
     ,p_note_text                    =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'NoteText',null)
     ,p_status_change_date           =>       hr_transaction_swi.getDateValue(l_CommitNode,'StatusChangeDate',null)
     ,p_offer_id                     =>       l_offer_id
     ,p_object_version_number        =>       l_object_version_number
     ,p_offer_version                =>       l_offer_version
     ,p_return_status                =>       l_return_status
     );
     --
   elsif l_postState = '3' then
     -- call delete offer
     --
     delete_offer
     (p_validate                     =>       p_validate
     ,p_object_version_number        =>       l_object_version_number
     ,p_offer_id                     =>       l_offer_id
     ,p_effective_date               =>       l_effective_date
     ,p_return_status                =>       l_return_status
     );
     --
   end if;
   p_return_status := l_return_status;
   hr_utility.set_location('Exiting:' || l_proc,40);

end process_offers_api;

-- ----------------------------------------------------------------------------
-- |-------------------------< process_asg_api >----------------------------|
-- ----------------------------------------------------------------------------

procedure process_asg_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState VARCHAR2(2);
   l_return_status VARCHAR2(1);
   l_commitElement xmldom.DOMElement;
   l_parser xmlparser.Parser;
   l_CommitNode xmldom.DOMNode;
   l_proc    varchar2(72) := g_package || 'process_asg_api';

   --
   l_assignment_id         number;
   l_offer_id              number;
   l_assignment_sequence   number;
   l_comment_id            number;
   l_assignment_number     number;
   l_effective_start_date  date;
   l_effective_end_date    date;
   --
   l_asg_object_version_number number;
   l_business_group_id         number;
   l_payroll_id_updated        number;
   l_validation_start_date     date;
   l_validation_end_date       date;
   --
   l_effective_date            date  :=  trunc(sysdate);

BEGIN

   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);

   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));

   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');

   --Get the values for in/out parameters
   l_assignment_id  :=  hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentId');
   l_offer_id   :=  hr_transaction_swi.getNumberValue(l_CommitNode,'OfferId');
   l_assignment_sequence  := hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentSequence');
   l_assignment_number := hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentNumber', null);
   l_asg_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');

   if p_effective_date is null
   then
   --
     l_effective_date := trunc(sysdate);
   --
   else
   --
     l_effective_date := p_effective_date;
   --
   end if;

   if l_postState = '2' then
     --
     -- call update offer
     --
     update_offer_assignment
     (p_assignment_id                =>       l_assignment_id
     ,p_effective_start_date         =>       l_effective_start_date
     ,p_effective_end_date           =>       l_effective_end_date
     ,p_business_group_id            =>       l_business_group_id
     ,p_recruiter_id                 =>       hr_transaction_swi.getNumberValue(l_CommitNode,'RecruiterId')
     ,p_grade_id                     =>       hr_transaction_swi.getNumberValue(l_CommitNode,'GradeId')
     ,p_position_id                  =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PositionId')
     ,p_job_id                       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'JobId')
     ,p_assignment_status_type_id    =>       hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentStatusTypeId')
     ,p_payroll_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PayrollId')
     ,p_location_id                  =>       hr_transaction_swi.getNumberValue(l_CommitNode,'LocationId')
     ,p_person_referred_by_id        =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PersonReferredById')
     ,p_supervisor_id                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'SupervisorId')
     ,p_special_ceiling_step_id      =>       hr_transaction_swi.getNumberValue(l_CommitNode,'SpecialCeilingStepId')
     ,p_recruitment_activity_id      =>       hr_transaction_swi.getNumberValue(l_CommitNode,'RecruitmentActivityId')
     ,p_source_organization_id       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'SourceOrganizationId')
     ,p_organization_id              =>       hr_transaction_swi.getNumberValue(l_CommitNode,'OrganizationId')
     ,p_people_group_id              =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PeopleGroupId')
     ,p_soft_coding_keyflex_id       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'SoftCodingKeyflexId')
     ,p_vacancy_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'VacancyId')
     ,p_pay_basis_id                 =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PayBasisId')
     ,p_assignment_type              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssignmentType')
     ,p_primary_flag                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'PrimaryFlag')
     ,p_application_id               =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ApplicationId')
     ,p_assignment_number            =>       l_assignment_number
     ,p_change_reason                =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'ChangeReason')
     ,p_comment_id                   =>       l_comment_id
     ,p_comments                     =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments')
     ,p_date_probation_end           =>       hr_transaction_swi.getDateValue(l_CommitNode,'DateProbationEnd')
     ,p_default_code_comb_id         =>       hr_transaction_swi.getNumberValue(l_CommitNode,'DefaultCodeCombId')
     ,p_employment_category          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EmploymentCategory')
     ,p_frequency                    =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Frequency')
     ,p_internal_address_line        =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'InternalAddressLine')
     ,p_manager_flag                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'ManagerFlag')
     ,p_normal_hours                 =>       hr_transaction_swi.getNumberValue(l_CommitNode,'NormalHours')
     ,p_perf_review_period           =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PerfReviewPeriod')
     ,p_perf_review_period_frequency =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'PerfReviewPeriodFrequency')
     ,p_period_of_service_id         =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PeriodOfServiceId')
     ,p_probation_period             =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ProbationPeriod')
     ,p_probation_unit               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'ProbationUnit')
     ,p_sal_review_period            =>       hr_transaction_swi.getNumberValue(l_CommitNode,'SalReviewPeriod')
     ,p_sal_review_period_frequency  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'SalReviewPeriodFrequency')
     ,p_set_of_books_id              =>       hr_transaction_swi.getNumberValue(l_CommitNode,'SetOfBooksId')
     ,p_source_type                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'SourceType')
     ,p_time_normal_finish           =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'TimeNormalFinish')
     ,p_time_normal_start            =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'TimeNormalStart')
     ,p_bargaining_unit_code         =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'BargainingUnitCode')
     ,p_labour_union_member_flag     =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'LabourUnionMemberFlag')
     ,p_hourly_salaried_code         =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'HourlySalariedCode')
     ,p_request_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'RequestId')
     ,p_program_application_id       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ProgramApplicationId')
     ,p_program_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ProgramId')
     ,p_program_update_date          =>       hr_transaction_swi.getDateValue(l_CommitNode,'ProgramUpdateDate')
     ,p_ass_attribute_category       =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttributeCategory')
     ,p_ass_attribute1               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute1')
     ,p_ass_attribute2               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute2')
     ,p_ass_attribute3               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute3')
     ,p_ass_attribute4               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute4')
     ,p_ass_attribute5               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute5')
     ,p_ass_attribute6               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute6')
     ,p_ass_attribute7               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute7')
     ,p_ass_attribute8               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute8')
     ,p_ass_attribute9               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute9')
     ,p_ass_attribute10              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute10')
     ,p_ass_attribute11              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute11')
     ,p_ass_attribute12              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute12')
     ,p_ass_attribute13              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute13')
     ,p_ass_attribute14              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute14')
     ,p_ass_attribute15              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute15')
     ,p_ass_attribute16              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute16')
     ,p_ass_attribute17              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute17')
     ,p_ass_attribute18              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute18')
     ,p_ass_attribute19              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute19')
     ,p_ass_attribute20              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute20')
     ,p_ass_attribute21              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute21')
     ,p_ass_attribute22              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute22')
     ,p_ass_attribute23              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute23')
     ,p_ass_attribute24              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute24')
     ,p_ass_attribute25              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute25')
     ,p_ass_attribute26              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute26')
     ,p_ass_attribute27              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute27')
     ,p_ass_attribute28              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute28')
     ,p_ass_attribute29              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute29')
     ,p_ass_attribute30              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssAttribute30')
     ,p_title                        =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Title')
     ,p_contract_id                  =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ContractId')
     ,p_establishment_id             =>       hr_transaction_swi.getNumberValue(l_CommitNode,'EstablishmentId')
     ,p_collective_agreement_id      =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CollectiveAgreementId')
     ,p_cagr_grade_def_id            =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CagrGradeDefId')
     ,p_cagr_id_flex_num             =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CagrIdFlexNum')
     ,p_asg_object_version_number    =>       l_asg_object_version_number
     ,p_notice_period                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'NoticePeriod')
     ,p_notice_period_uom            =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'NoticePeriodUom')
     ,p_employee_category            =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EmployeeCategory')
     ,p_work_at_home                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'WorkAtHome')
     ,p_job_post_source_name         =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'JobPostSourceName')
     ,p_posting_content_id           =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PostingContentId')
     ,p_placement_date_start         =>       hr_transaction_swi.getDateValue(l_CommitNode,'PlacementDateStart')
     ,p_vendor_id                    =>       hr_transaction_swi.getNumberValue(l_CommitNode,'VendorId')
     ,p_vendor_employee_number       =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'VendorEmployeeNumber')
     ,p_vendor_assignment_number     =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'VendorAssignmentNumber')
     ,p_assignment_category          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AssignmentCategory')
     ,p_project_title                =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'ProjectTitle')
     ,p_applicant_rank               =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ApplicantRank')
     ,p_grade_ladder_pgm_id          =>       hr_transaction_swi.getNumberValue(l_CommitNode,'GradeLadderPgmId')
     ,p_supervisor_assignment_id     =>       hr_transaction_swi.getNumberValue(l_CommitNode,'SupervisorAssignmentId')
     ,p_vendor_site_id               =>       hr_transaction_swi.getNumberValue(l_CommitNode,'VendorSiteId')
     ,p_po_header_id                 =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PoHeaderId')
     ,p_po_line_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PoLineId')
     ,p_projected_assignment_end     =>       hr_transaction_swi.getDateValue(l_CommitNode,'ProjectedAssignmentEnd')
     ,p_payroll_id_updated           =>       l_payroll_id_updated
     ,p_validation_start_date        =>       l_validation_start_date
     ,p_validation_end_date          =>       l_validation_end_date
     ,p_effective_date               =>       l_effective_date
     ,p_datetrack_mode               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DatetrackMode')
     ,p_validate                     =>       p_validate
     ,p_offer_id                     =>       l_offer_id
     ,p_offer_status                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'OfferStatus',null)
     ,p_return_status                =>       l_return_status
     );
     --

   elsif l_postState = '3' then
     -- call delete offer
     --
     delete_offer_assignment
     (p_validate                     =>       p_validate
     ,p_effective_date               =>       l_effective_date
     ,p_offer_assignment_id          =>       hr_transaction_swi.getNumberValue(l_CommitNode,'OfferAssignmentId',null)
     ,p_return_status                =>       l_return_status
     );
     --
   end if;
   p_return_status := l_return_status;
   hr_utility.set_location('Exiting:' || l_proc,40);

end process_asg_api;
-- ----------------------------------------------------------------------------
-- |-----------------------------< finalize_transaction >---------------------|
-- ----------------------------------------------------------------------------

procedure finalize_transaction
(
 p_transaction_id       in         number
,p_event                in         varchar2
,p_return_status        out nocopy varchar2
)
is
   l_return_status                 varchar2(1);
   l_object_version_number         number;
   l_offer_id                      number;
   l_offer_version                 number;
   l_offer_status                  varchar2(30);
   l_prev_offer_status             varchar2(30);
   l_offer_status_before_hold      varchar2(30);
   l_applicant_assignment_id           number;
   l_expiry_date                   date;
   l_change_reason                 varchar2(30);
   l_close_reason                  varchar2(30);
   l_status                        varchar2(30);
   l_effective_date                date  :=  trunc(sysdate);
   l_proc    varchar2(72) := g_package || 'finalize_transaction';
   --
   cursor csr_offer_details is
      select offer_id
            ,offer_version
            ,offer_status
            ,applicant_assignment_id
            ,expiry_date
            ,object_version_number
      from hr_api_transactions hrt, irc_offers iro
      where hrt.transaction_id = p_transaction_id
            and hrt.transaction_ref_id = iro.offer_id;
   --
   cursor csr_offer_history_details(p_offer_id number) is
    select   offer_status
            ,change_reason
      from irc_offer_status_history HISTORY
      where HISTORY.offer_id = p_offer_id
        and not EXISTS (SELECT 1
           FROM irc_offer_status_history iosh1
          WHERE iosh1.offer_id = HISTORY.offer_id
            AND iosh1.status_change_date > HISTORY.status_change_date
           )
        AND HISTORY.offer_status_history_id =
           (SELECT MAX(iosh2.offer_status_history_id)
              FROM irc_offer_status_history iosh2
             WHERE iosh2.offer_id = HISTORY.offer_id
               AND iosh2.status_change_date = HISTORY.status_change_date
           );
   --
   cursor csr_offer_status_before_hold is
       SELECT ios1.offer_status
       FROM irc_offer_status_history ios1
       WHERE EXISTS ( SELECT 1
                          FROM irc_offer_status_history iosh1
                          WHERE iosh1.offer_id = l_offer_id
                          AND iosh1.status_change_date > ios1.status_change_date
                        )
        AND ios1.offer_status_history_id = (SELECT MAX(iosh2.offer_status_history_id)
                                              FROM irc_offer_status_history iosh2
                                             WHERE iosh2.offer_id = l_offer_id
                                               AND iosh2.status_change_date = ios1.status_change_date
                                            )
        AND 1 =
         (SELECT COUNT(*)
          FROM irc_offer_status_history ios3
          WHERE ios3.offer_id = l_offer_id
          AND ios3.status_change_date > ios1.status_change_date
         );
   --
begin
   --
   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(l_proc || ' Event:' || p_event,13);
   --
   open csr_offer_details;
   fetch csr_offer_details into
        l_offer_id, l_offer_version, l_prev_offer_status,
        l_applicant_assignment_id, l_expiry_date,l_object_version_number;
   if csr_offer_details%found then
     close csr_offer_details;
     --
     hr_utility.set_location(l_proc,15);
     --
     -- Approved or updated offer event handling
     --
     if p_event = 'APPROVED' OR p_event = 'SUBMIT' OR p_event = 'RESUBMIT' then
       hr_utility.set_location(l_proc, 20);
       -- if the transaction is approval of PENDING_EXTENDED, the status
       -- here will be EXTENDED as the update_offer would have converted
       -- the status already.
       if l_prev_offer_status = 'EXTENDED' then
         l_offer_status := NULL;
       --
       elsif l_prev_offer_status = 'HOLD' then
         open  csr_offer_status_before_hold;
         fetch csr_offer_status_before_hold into l_offer_status_before_hold;
         close csr_offer_status_before_hold;
         --
         -- If the offer has been EXTENDED due to approval of PENDING_EXTENDED, and put
         -- back on HOLD, set the offer status to NULL.
         --
         if l_offer_status_before_hold = 'EXTENDED' then
            l_offer_status := NULL;
         elsif l_offer_status_before_hold = 'PENDING' then
            hr_utility.set_location(l_proc, 24);
            l_offer_status := 'APPROVED';
         end if;
       --
       else
         --
         -- This cursor is used to get the offer status and offer close reason
         -- If the close reason is Manager Withdraw or Applicant withdrew their
         -- application offer should not be updated
         hr_utility.set_location(l_proc, 25);
         open csr_offer_history_details(l_offer_id);
         fetch csr_offer_history_details into l_status,l_close_reason;
         if csr_offer_history_details%found then
           hr_utility.set_location(l_proc, 26);
           if l_status='CLOSED' and l_close_reason in ('MGR_WITHDRAW','WITHDRAWAL','MANUAL_CLOSURE','MGR_TERMINATE_APPL','AGENCY_TERMINATE_APPL') then
             hr_utility.set_location(l_proc, 27);
             l_offer_status := NULL;
           else
             hr_utility.set_location(l_proc, 28);
             l_offer_status := 'APPROVED';
           end if;
         else
           hr_utility.set_location(l_proc, 29);
         l_offer_status := 'APPROVED';
       end if;
         close csr_offer_history_details;
       end if;
     --
     -- RFC offer event handling
     --
     elsif p_event = 'RFC' then
       hr_utility.set_location(l_proc, 30);
       open csr_offer_history_details(l_offer_id);
       fetch csr_offer_history_details into l_status,l_close_reason;
       if csr_offer_history_details%found then
          hr_utility.set_location(l_proc, 31);
          if l_status='CLOSED' and (l_close_reason = 'MGR_WITHDRAW' OR l_close_reason = 'WITHDRAWAL') then
            hr_utility.set_location(l_proc, 32);
            l_offer_status := NULL;
          else
            hr_utility.set_location(l_proc, 33);
            l_offer_status := 'CORRECTION';
           end if;
         close csr_offer_history_details;
      else
        hr_utility.set_location(l_proc, 34);
        l_offer_status := 'CORRECTION';
        close csr_offer_history_details;
     end if;
     --
     -- Rejected offer event handling
     --
     elsif p_event = 'REJECTED' OR p_event = 'DELETED' OR p_event = 'CANCEL' then
       if l_prev_offer_status = 'PENDING_EXTENDED'
                 and l_expiry_date >= l_effective_date then
         l_offer_status := 'EXTENDED';
       else
         handleAttachmentsWhenRejected(p_applicant_assignment_id=>l_applicant_assignment_id);
         l_offer_status := 'CLOSED';
         if p_event = 'REJECTED' then
           hr_utility.set_location(l_proc, 40);
           l_change_reason := 'APPROVER_REJECTED';
         else
           -- DELETE, CANCEL
           hr_utility.set_location(l_proc, 50);
           l_change_reason := 'MANUAL_CLOSURE';
         end if;
       end if;
     end if;
     --
     if l_offer_status is not null then
       hr_utility.set_location(l_proc || ' Offer Status:' || l_offer_status, 60);
       update_offer
       (p_effective_date               =>       l_effective_date
       ,p_offer_status                 =>       l_offer_status
       ,p_change_reason                =>       l_change_reason
       ,p_offer_id                     =>       l_offer_id
       ,p_object_version_number        =>       l_object_version_number
       ,p_offer_version                =>       l_offer_version
       ,p_return_status                =>       l_return_status
       );
     end if;
   else
     close csr_offer_details;
   end if;
   --
   p_return_status := l_return_status;
   hr_utility.set_location('Exiting:' || l_proc,70);
   --
end finalize_transaction;

-- ----------------------------------------------------------------------------
-- |-----------------------------< void_ben_records >-------------------------|
-- ----------------------------------------------------------------------------

  procedure void_ben_records
  ( p_applicant_assignment_id   in  number default null
   ,p_offer_assignment_id       in  number default null
   ,p_status_code               in  varchar2 default null
   ,p_effective_date            in  date default trunc(sysdate)
   ,p_transaction_id            in  number default null
   ,p_void_single_per_in_ler    in  varchar2 default 'N'
  )
  is
    --
    l_proc                    varchar2(72) := g_package || 'void_ben_records';
    l_void_per_in_ler_id      ben_pil_assignment.per_in_ler_id%TYPE;
    l_restore_per_in_ler_id   ben_pil_assignment.per_in_ler_id%TYPE := null;
    l_person_id               per_all_assignments_f.person_id%TYPE := null;
    l_applicant_assignment_id hr_api_transactions.assignment_id%TYPE := p_applicant_assignment_id;
    --
    cursor csr_applicant_assignment_id is
    select assignment_id
      from hr_api_transactions
     where transaction_id = p_transaction_id;
    --
    cursor csr_void_per_in_ler_id is
    select max(per_in_ler_id)
      from ben_pil_assignment
     where applicant_assignment_id = l_applicant_assignment_id
       and offer_assignment_id is null;
    --
    cursor csr_person_id is
    select person_id
      from per_all_assignments_f
     where assignment_id = l_applicant_assignment_id
       and trunc(sysdate)
   between effective_start_date
       and effective_end_date;
    --
    cursor csr_restore_per_in_ler_id is
    select max(per_in_ler_id)
      from ben_pil_assignment
     where applicant_assignment_id = l_applicant_assignment_id
       and offer_assignment_id is not null;
    --
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
  begin
    --
    hr_utility.set_location(' Entering:' || l_proc,10);
    --
    if p_applicant_assignment_id is null
    then
      --
      open csr_applicant_assignment_id;
      fetch csr_applicant_assignment_id into l_applicant_assignment_id;
      close csr_applicant_assignment_id;
      --
    end if;
    --
    open csr_void_per_in_ler_id;
    fetch csr_void_per_in_ler_id into l_void_per_in_ler_id;
    if csr_void_per_in_ler_id%found
    then
      --
      close csr_void_per_in_ler_id;
      --
      open csr_restore_per_in_ler_id;
      fetch csr_restore_per_in_ler_id into l_restore_per_in_ler_id;
      close csr_restore_per_in_ler_id;
      --
      open csr_person_id;
      fetch csr_person_id into l_person_id;
      close csr_person_id;
      --
      if p_void_single_per_in_ler = 'N'
      then
        --
        -- Since we need to VOID all the ben records following the latest
        -- ben record associated with an offer assignment, pass NULL for
        -- void_per_in_ler_id
        --
        l_void_per_in_ler_id := null;
        --
      end if;
      --
      ben_irc_util.void_or_restore_life_event
      ( p_person_id               => l_person_id
       ,p_assignment_id           => l_applicant_assignment_id
       ,p_offer_assignment_id     => p_offer_assignment_id
       ,p_void_per_in_ler_id      => l_void_per_in_ler_id
       ,p_restore_per_in_ler_id   => l_restore_per_in_ler_id
       ,p_status_cd               => p_status_code
       ,p_effective_date          => p_effective_date
      );
      --
    else
      --
      close csr_void_per_in_ler_id;
      --
    end if;
    --
    commit;
    --
    exception
      when OTHERS then
        rollback;
    --
    hr_utility.set_location('Exiting:' || l_proc,20);
    --
  end void_ben_records;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenCommit >---------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenCommit(p_applicant_assignment_id in number) is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_proc    varchar2(72) := g_package || 'handleAttachmentsWhenCommit';
 begin
 hr_utility.set_location(' Entering:' || l_proc,10);
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_EXT_OFFER_APPROVED',X_pk1_value=>p_applicant_assignment_id,X_delete_document_flag=>'Y');
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_INT_OFFER_APPROVED',X_pk1_value=>p_applicant_assignment_id,X_delete_document_flag=>'Y');

 fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'IRC_EXT_OFFER',X_from_pk1_value =>p_applicant_assignment_id,X_to_entity_name=>'IRC_EXT_OFFER_APPROVED',X_to_pk1_value=>p_applicant_assignment_id);
 fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'IRC_INT_OFFER',X_from_pk1_value =>p_applicant_assignment_id,X_to_entity_name=>'IRC_INT_OFFER_APPROVED',X_to_pk1_value=>p_applicant_assignment_id);

 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_EXT_OFFER',X_pk1_value=>p_applicant_assignment_id,X_delete_document_flag=>'Y');
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_INT_OFFER',X_pk1_value=>p_applicant_assignment_id,X_delete_document_flag=>'Y');
 commit;
 hr_utility.set_location(' Exiting:' || l_proc,20);
 end;
 --
-- ----------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenRejected >-------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenRejected(p_applicant_assignment_id in number) is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_proc    varchar2(72) := g_package || 'handleAttachmentsWhenRejected';
 begin
 hr_utility.set_location(' Entering:' || l_proc,10);
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_EXT_OFFER',X_pk1_value=>p_applicant_assignment_id,X_delete_document_flag=>'Y');
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_INT_OFFER',X_pk1_value=>p_applicant_assignment_id,X_delete_document_flag=>'Y');
 commit;
  hr_utility.set_location(' Exiting:' || l_proc,20);
 end;

 -- ---------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenEditing >--------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenEdit(p_applicant_assignment_id in number) is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_proc    varchar2(72) := g_package || 'handleAttachmentsWhenEdit';
 begin
 hr_utility.set_location(' Entering:' || l_proc,10);

 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_EXT_OFFER',X_pk1_value=>p_applicant_assignment_id,X_delete_document_flag=>'Y');
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_INT_OFFER',X_pk1_value=>p_applicant_assignment_id,X_delete_document_flag=>'Y');

 fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'IRC_INT_OFFER_APPROVED',X_from_pk1_value =>p_applicant_assignment_id,X_to_entity_name=>'IRC_INT_OFFER',X_to_pk1_value=>p_applicant_assignment_id);
 fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'IRC_EXT_OFFER_APPROVED',X_from_pk1_value =>p_applicant_assignment_id,X_to_entity_name=>'IRC_EXT_OFFER',X_to_pk1_value=>p_applicant_assignment_id);
 commit;
 hr_utility.set_location(' Exiting:' || l_proc,20);
 end;
 --
 --
 -- ----------------------------------------------------------------------------
 -- |-----------------------------< clear_global_data >------------------------|
 -- ----------------------------------------------------------------------------
 procedure clear_global_data
 is
 begin
 --
   g_old_offer_assignment_record := null;
   g_old_pay_proposal_record := null;
 --
 end clear_global_data;
 --
 --
end irc_offers_swi;

/
