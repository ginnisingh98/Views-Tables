--------------------------------------------------------
--  DDL for Package Body OTA_DELEGATE_BOOKING_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_DELEGATE_BOOKING_SWI" As
/* $Header: otenrswi.pkb 120.4.12010000.3 2008/08/05 11:43:55 ubhat ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_delegate_booking_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_delegate_booking >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_delegate_booking
  (p_effective_date               in     date
  ,p_booking_id                   in     number
  ,p_booking_status_type_id       in     number
  ,p_delegate_person_id           in     number    default null
  ,p_contact_id                   in     number
  ,p_business_group_id            in     number
  ,p_event_id                     in     number
  ,p_customer_id                  in     number    default null
  ,p_authorizer_person_id         in     number    default null
  ,p_date_booking_placed          in     date
  ,p_corespondent                 in     varchar2  default null
  ,p_internal_booking_flag        in     varchar2
  ,p_number_of_places             in     number
  ,p_object_version_number           out nocopy number
  ,p_administrator                in     number    default null
  ,p_booking_priority             in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_contact_address_id           in     number    default null
  ,p_delegate_contact_phone       in     varchar2  default null
  ,p_delegate_contact_fax         in     varchar2  default null
  ,p_third_party_customer_id      in     number    default null
  ,p_third_party_contact_id       in     number    default null
  ,p_third_party_address_id       in     number    default null
  ,p_third_party_contact_phone    in     varchar2  default null
  ,p_third_party_contact_fax      in     varchar2  default null
  ,p_date_status_changed          in     date      default null
  ,p_failure_reason               in     varchar2  default null
  ,p_attendance_result            in     varchar2  default null
  ,p_language_id                  in     number    default null
  ,p_source_of_booking            in     varchar2  default null
  ,p_special_booking_instructions in     varchar2  default null
  ,p_successful_attendance_flag   in     varchar2  default null
  ,p_tdb_information_category     in     varchar2  default null
  ,p_tdb_information1             in     varchar2  default null
  ,p_tdb_information2             in     varchar2  default null
  ,p_tdb_information3             in     varchar2  default null
  ,p_tdb_information4             in     varchar2  default null
  ,p_tdb_information5             in     varchar2  default null
  ,p_tdb_information6             in     varchar2  default null
  ,p_tdb_information7             in     varchar2  default null
  ,p_tdb_information8             in     varchar2  default null
  ,p_tdb_information9             in     varchar2  default null
  ,p_tdb_information10            in     varchar2  default null
  ,p_tdb_information11            in     varchar2  default null
  ,p_tdb_information12            in     varchar2  default null
  ,p_tdb_information13            in     varchar2  default null
  ,p_tdb_information14            in     varchar2  default null
  ,p_tdb_information15            in     varchar2  default null
  ,p_tdb_information16            in     varchar2  default null
  ,p_tdb_information17            in     varchar2  default null
  ,p_tdb_information18            in     varchar2  default null
  ,p_tdb_information19            in     varchar2  default null
  ,p_tdb_information20            in     varchar2  default null
  ,p_create_finance_line          in     varchar2  default null
  ,p_finance_header_id            in     number    default null
  ,p_currency_code                in     varchar2  default null
  ,p_standard_amount              in     number    default null
  ,p_unitary_amount               in     number    default null
  ,p_money_amount                 in     number    default null
  ,p_booking_deal_id              in     number    default null
  ,p_booking_deal_type            in     varchar2  default null
  ,p_finance_line_id              in out nocopy number
  ,p_enrollment_type              in     varchar2  default null
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_id              in     number    default null
  ,p_sponsor_person_id            in     number    default null
  ,p_sponsor_assignment_id        in     number    default null
  ,p_person_address_id            in     number    default null
  ,p_delegate_assignment_id       in     number    default null
  ,p_delegate_contact_id          in     number    default null
  ,p_delegate_contact_email       in     varchar2  default null
  ,p_third_party_email            in     varchar2  default null
  ,p_person_address_type          in     varchar2  default null
  ,p_line_id                      in     number    default null
  ,p_org_id                       in     number    default null
  ,p_daemon_flag                  in     varchar2  default null
  ,p_daemon_type                  in     varchar2  default null
  ,p_old_event_id                 in     number    default null
  ,p_quote_line_id                in     number    default null
  ,p_interface_source             in     varchar2  default null
  ,p_total_training_time          in     varchar2  default null
  ,p_content_player_status        in     varchar2  default null
  ,p_score                        in     number    default null
  ,p_completed_content            in     number    default null
  ,p_total_content                in     number    default null
  ,p_return_status                out 	 nocopy    varchar2
  ,p_booking_justification_id 	  in 	 number    default null
  ,p_is_history_flag   		  in 	 varchar2  default 'N'
  ,p_override_prerequisites 	  in 	 varchar2
  ,p_override_learner_access 	  in 	 varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_finance_line_id               number;
  --
  -- Other variables
  l_booking_id                   number;
  l_proc    varchar2(72) := g_package ||'create_delegate_booking';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_delegate_booking_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_finance_line_id               := p_finance_line_id;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  ota_tdb_ins.set_base_key_value
    (p_booking_id => p_booking_id
    );
  --
  -- Call API
  --
  ota_delegate_booking_api.create_delegate_booking
    (p_effective_date               => p_effective_date
    ,p_booking_id                   => l_booking_id
    ,p_booking_status_type_id       => p_booking_status_type_id
    ,p_delegate_person_id           => p_delegate_person_id
    ,p_contact_id                   => p_contact_id
    ,p_business_group_id            => p_business_group_id
    ,p_event_id                     => p_event_id
    ,p_customer_id                  => p_customer_id
    ,p_authorizer_person_id         => p_authorizer_person_id
    ,p_date_booking_placed          => p_date_booking_placed
    ,p_corespondent                 => p_corespondent
    ,p_internal_booking_flag        => p_internal_booking_flag
    ,p_number_of_places             => p_number_of_places
    ,p_object_version_number        => p_object_version_number
    ,p_administrator                => p_administrator
    ,p_booking_priority             => p_booking_priority
    ,p_comments                     => p_comments
    ,p_contact_address_id           => p_contact_address_id
    ,p_delegate_contact_phone       => p_delegate_contact_phone
    ,p_delegate_contact_fax         => p_delegate_contact_fax
    ,p_third_party_customer_id      => p_third_party_customer_id
    ,p_third_party_contact_id       => p_third_party_contact_id
    ,p_third_party_address_id       => p_third_party_address_id
    ,p_third_party_contact_phone    => p_third_party_contact_phone
    ,p_third_party_contact_fax      => p_third_party_contact_fax
    --Bug 6888629:Setting date_status_changed to null in create mode for single enrollment
    -- to maintain consistency with bulk and self enrollment.
    ,p_date_status_changed          => null --p_date_status_changed
    ,p_failure_reason               => p_failure_reason
    ,p_attendance_result            => p_attendance_result
    ,p_language_id                  => p_language_id
    ,p_source_of_booking            => p_source_of_booking
    ,p_special_booking_instructions => p_special_booking_instructions
    ,p_successful_attendance_flag   => p_successful_attendance_flag
    ,p_tdb_information_category     => p_tdb_information_category
    ,p_tdb_information1             => p_tdb_information1
    ,p_tdb_information2             => p_tdb_information2
    ,p_tdb_information3             => p_tdb_information3
    ,p_tdb_information4             => p_tdb_information4
    ,p_tdb_information5             => p_tdb_information5
    ,p_tdb_information6             => p_tdb_information6
    ,p_tdb_information7             => p_tdb_information7
    ,p_tdb_information8             => p_tdb_information8
    ,p_tdb_information9             => p_tdb_information9
    ,p_tdb_information10            => p_tdb_information10
    ,p_tdb_information11            => p_tdb_information11
    ,p_tdb_information12            => p_tdb_information12
    ,p_tdb_information13            => p_tdb_information13
    ,p_tdb_information14            => p_tdb_information14
    ,p_tdb_information15            => p_tdb_information15
    ,p_tdb_information16            => p_tdb_information16
    ,p_tdb_information17            => p_tdb_information17
    ,p_tdb_information18            => p_tdb_information18
    ,p_tdb_information19            => p_tdb_information19
    ,p_tdb_information20            => p_tdb_information20
    ,p_create_finance_line          => p_create_finance_line
    ,p_finance_header_id            => p_finance_header_id
    ,p_currency_code                => p_currency_code
    ,p_standard_amount              => p_standard_amount
    ,p_unitary_amount               => p_unitary_amount
    ,p_money_amount                 => p_money_amount
    ,p_booking_deal_id              => p_booking_deal_id
    ,p_booking_deal_type            => p_booking_deal_type
    ,p_finance_line_id              => p_finance_line_id
    ,p_enrollment_type              => p_enrollment_type
    ,p_validate                     => l_validate
    ,p_organization_id              => p_organization_id
    ,p_sponsor_person_id            => p_sponsor_person_id
    ,p_sponsor_assignment_id        => p_sponsor_assignment_id
    ,p_person_address_id            => p_person_address_id
    ,p_delegate_assignment_id       => p_delegate_assignment_id
    ,p_delegate_contact_id          => p_delegate_contact_id
    ,p_delegate_contact_email       => p_delegate_contact_email
    ,p_third_party_email            => p_third_party_email
    ,p_person_address_type          => p_person_address_type
    ,p_line_id                      => p_line_id
    ,p_org_id                       => p_org_id
    ,p_daemon_flag                  => p_daemon_flag
    ,p_daemon_type                  => p_daemon_type
    ,p_old_event_id                 => p_old_event_id
    ,p_quote_line_id                => p_quote_line_id
    ,p_interface_source             => p_interface_source
    ,p_total_training_time          => p_total_training_time
    ,p_content_player_status        => p_content_player_status
    ,p_score                        => p_score
    ,p_completed_content            => p_completed_content
    ,p_total_content                => p_total_content
    ,p_booking_justification_id     => p_booking_justification_id
    ,p_is_history_flag		    => p_is_history_flag
    ,p_override_prerequisites       => p_override_prerequisites
    ,p_override_learner_access      => p_override_learner_access
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
    rollback to create_delegate_booking_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_finance_line_id              := l_finance_line_id;
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
    rollback to create_delegate_booking_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_finance_line_id              := l_finance_line_id;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_delegate_booking;

-- ----------------------------------------------------------------------------
-- |------------------------< update_delegate_booking >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_delegate_booking
  (p_effective_date               in     date
  ,p_booking_id                   in     number
  ,p_booking_status_type_id       in     number    default hr_api.g_number
  ,p_delegate_person_id           in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_event_id                     in     number    default hr_api.g_number
  ,p_customer_id                  in     number    default hr_api.g_number
  ,p_authorizer_person_id         in     number    default hr_api.g_number
  ,p_date_booking_placed          in     date      default hr_api.g_date
  ,p_corespondent                 in     varchar2  default hr_api.g_varchar2
  ,p_internal_booking_flag        in     varchar2  default hr_api.g_varchar2
  ,p_number_of_places             in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_administrator                in     number    default hr_api.g_number
  ,p_booking_priority             in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_contact_address_id           in     number    default hr_api.g_number
  ,p_delegate_contact_phone       in     varchar2  default hr_api.g_varchar2
  ,p_delegate_contact_fax         in     varchar2  default hr_api.g_varchar2
  ,p_third_party_customer_id      in     number    default hr_api.g_number
  ,p_third_party_contact_id       in     number    default hr_api.g_number
  ,p_third_party_address_id       in     number    default hr_api.g_number
  ,p_third_party_contact_phone    in     varchar2  default hr_api.g_varchar2
  ,p_third_party_contact_fax      in     varchar2  default hr_api.g_varchar2
  ,p_date_status_changed          in     date      default hr_api.g_date
  ,p_status_change_comments       in     varchar2  default hr_api.g_varchar2
  ,p_failure_reason               in     varchar2  default hr_api.g_varchar2
  ,p_attendance_result            in     varchar2  default hr_api.g_varchar2
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_source_of_booking            in     varchar2  default hr_api.g_varchar2
  ,p_special_booking_instructions in     varchar2  default hr_api.g_varchar2
  ,p_successful_attendance_flag   in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information1             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information2             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information3             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information4             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information5             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information6             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information7             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information8             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information9             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information10            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information11            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information12            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information13            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information14            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information15            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information16            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information17            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information18            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information19            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information20            in     varchar2  default hr_api.g_varchar2
  ,p_update_finance_line          in     varchar2  default hr_api.g_varchar2
  ,p_tfl_object_version_number    in out nocopy number
  ,p_finance_header_id            in     number    default hr_api.g_number
  ,p_finance_line_id              in out nocopy number
  ,p_standard_amount              in     number    default hr_api.g_number
  ,p_unitary_amount               in     number    default hr_api.g_number
  ,p_money_amount                 in     number    default hr_api.g_number
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_booking_deal_type            in     varchar2  default hr_api.g_varchar2
  ,p_booking_deal_id              in     number    default hr_api.g_number
  ,p_enrollment_type              in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_sponsor_person_id            in     number    default hr_api.g_number
  ,p_sponsor_assignment_id        in     number    default hr_api.g_number
  ,p_person_address_id            in     number    default hr_api.g_number
  ,p_delegate_assignment_id       in     number    default hr_api.g_number
  ,p_delegate_contact_id          in     number    default hr_api.g_number
  ,p_delegate_contact_email       in     varchar2  default hr_api.g_varchar2
  ,p_third_party_email            in     varchar2  default hr_api.g_varchar2
  ,p_person_address_type          in     varchar2  default hr_api.g_varchar2
  ,p_line_id                      in     number    default hr_api.g_number
  ,p_org_id                       in     number    default hr_api.g_number
  ,p_daemon_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_daemon_type                  in     varchar2  default hr_api.g_varchar2
  ,p_old_event_id                 in     number    default hr_api.g_number
  ,p_quote_line_id                in     number    default hr_api.g_number
  ,p_interface_source             in     varchar2  default hr_api.g_varchar2
  ,p_total_training_time          in     varchar2  default hr_api.g_varchar2
  ,p_content_player_status        in     varchar2  default hr_api.g_varchar2
  ,p_score                        in     number    default hr_api.g_number
  ,p_completed_content            in     number    default hr_api.g_number
  ,p_total_content                in     number    default hr_api.g_number
  ,p_return_status                out 	 nocopy varchar2
  ,p_booking_justification_id     in 	 number    default hr_api.g_number
  ,p_is_history_flag       	  in     varchar2  default hr_api.g_varchar2
  ,p_override_prerequisites 	  in 	 varchar2
  ,p_override_learner_access 	  in 	 varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_tfl_object_version_number     number;
  l_finance_line_id               number;
  --
  l_date_booking_placed ota_delegate_bookings.date_booking_placed%TYPE;
  l_date_status_changed ota_delegate_bookings.date_status_changed%TYPE;

  --Bug6768247:ANY CHANGE BY ADMIN TO ENROLLMENT CAUSED DATE_STATUS_CHANGED UPDATE
  CURSOR booking_csr
  IS
  SELECT b.date_booking_placed,b.date_status_changed
  FROM   ota_delegate_bookings b
  WHERE  b.booking_id = p_booking_id;
  --

  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_delegate_booking';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_delegate_booking_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  l_tfl_object_version_number     := p_tfl_object_version_number;
  l_finance_line_id               := p_finance_line_id;
  --
  --
 /* Bug6768247:ANY CHANGE BY ADMIN TO ENROLLMENT CAUSED DATE_STATUS_CHANGED UPDATE
  OPEN booking_csr;
  FETCH booking_csr INTO l_date_booking_placed;
  CLOSE booking_csr;
  l_date_status_changed := trunc(sysdate);*/

  OPEN booking_csr;
    FETCH booking_csr INTO l_date_booking_placed,l_date_status_changed;
  CLOSE booking_csr;

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
  ota_delegate_booking_api.update_delegate_booking
    (p_effective_date               => p_effective_date
    ,p_booking_id                   => p_booking_id
    ,p_booking_status_type_id       => p_booking_status_type_id
    ,p_delegate_person_id           => p_delegate_person_id
    ,p_contact_id                   => p_contact_id
    ,p_business_group_id            => p_business_group_id
    ,p_event_id                     => p_event_id
    ,p_customer_id                  => p_customer_id
    ,p_authorizer_person_id         => p_authorizer_person_id
    ,p_date_booking_placed          => l_date_booking_placed
    ,p_corespondent                 => p_corespondent
    ,p_internal_booking_flag        => p_internal_booking_flag
    ,p_number_of_places             => p_number_of_places
    ,p_object_version_number        => p_object_version_number
    ,p_administrator                => p_administrator
    ,p_booking_priority             => p_booking_priority
    ,p_comments                     => p_comments
    ,p_contact_address_id           => p_contact_address_id
    ,p_delegate_contact_phone       => p_delegate_contact_phone
    ,p_delegate_contact_fax         => p_delegate_contact_fax
    ,p_third_party_customer_id      => p_third_party_customer_id
    ,p_third_party_contact_id       => p_third_party_contact_id
    ,p_third_party_address_id       => p_third_party_address_id
    ,p_third_party_contact_phone    => p_third_party_contact_phone
    ,p_third_party_contact_fax      => p_third_party_contact_fax
    ,p_date_status_changed          => l_date_status_changed
    ,p_status_change_comments       => p_status_change_comments
    ,p_failure_reason               => p_failure_reason
    ,p_attendance_result            => p_attendance_result
    ,p_language_id                  => p_language_id
    ,p_source_of_booking            => p_source_of_booking
    ,p_special_booking_instructions => p_special_booking_instructions
    ,p_successful_attendance_flag   => p_successful_attendance_flag
    ,p_tdb_information_category     => p_tdb_information_category
    ,p_tdb_information1             => p_tdb_information1
    ,p_tdb_information2             => p_tdb_information2
    ,p_tdb_information3             => p_tdb_information3
    ,p_tdb_information4             => p_tdb_information4
    ,p_tdb_information5             => p_tdb_information5
    ,p_tdb_information6             => p_tdb_information6
    ,p_tdb_information7             => p_tdb_information7
    ,p_tdb_information8             => p_tdb_information8
    ,p_tdb_information9             => p_tdb_information9
    ,p_tdb_information10            => p_tdb_information10
    ,p_tdb_information11            => p_tdb_information11
    ,p_tdb_information12            => p_tdb_information12
    ,p_tdb_information13            => p_tdb_information13
    ,p_tdb_information14            => p_tdb_information14
    ,p_tdb_information15            => p_tdb_information15
    ,p_tdb_information16            => p_tdb_information16
    ,p_tdb_information17            => p_tdb_information17
    ,p_tdb_information18            => p_tdb_information18
    ,p_tdb_information19            => p_tdb_information19
    ,p_tdb_information20            => p_tdb_information20
    ,p_update_finance_line          => p_update_finance_line
    ,p_tfl_object_version_number    => p_tfl_object_version_number
    ,p_finance_header_id            => p_finance_header_id
    ,p_finance_line_id              => p_finance_line_id
    ,p_standard_amount              => p_standard_amount
    ,p_unitary_amount               => p_unitary_amount
    ,p_money_amount                 => p_money_amount
    ,p_currency_code                => p_currency_code
    ,p_booking_deal_type            => p_booking_deal_type
    ,p_booking_deal_id              => p_booking_deal_id
    ,p_enrollment_type              => p_enrollment_type
    ,p_validate                     => l_validate
    ,p_organization_id              => p_organization_id
    ,p_sponsor_person_id            => p_sponsor_person_id
    ,p_sponsor_assignment_id        => p_sponsor_assignment_id
    ,p_person_address_id            => p_person_address_id
    ,p_delegate_assignment_id       => p_delegate_assignment_id
    ,p_delegate_contact_id          => p_delegate_contact_id
    ,p_delegate_contact_email       => p_delegate_contact_email
    ,p_third_party_email            => p_third_party_email
    ,p_person_address_type          => p_person_address_type
    ,p_line_id                      => p_line_id
    ,p_org_id                       => p_org_id
    ,p_daemon_flag                  => p_daemon_flag
    ,p_daemon_type                  => p_daemon_type
    ,p_old_event_id                 => p_old_event_id
    ,p_quote_line_id                => p_quote_line_id
    ,p_interface_source             => p_interface_source
    ,p_total_training_time          => p_total_training_time
    ,p_content_player_status        => p_content_player_status
    ,p_score                        => p_score
    ,p_completed_content            => p_completed_content
    ,p_total_content                => p_total_content
    ,p_booking_justification_id     => p_booking_justification_id
    ,p_is_history_flag		    => p_is_history_flag
    ,p_override_prerequisites 	 => p_override_prerequisites
   ,p_override_learner_access 	 => p_override_learner_access
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
    rollback to update_delegate_booking_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_tfl_object_version_number    := l_tfl_object_version_number;
    p_finance_line_id              := l_finance_line_id;
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
    rollback to update_delegate_booking_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_tfl_object_version_number    := l_tfl_object_version_number;
    p_finance_line_id              := l_finance_line_id;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_delegate_booking;

-- ----------------------------------------------------------------------------
-- |------------------------< delete_delegate_booking >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_delegate_booking
  (p_booking_id                   in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_delegate_booking';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_delegate_booking_swi;
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
  ota_delegate_booking_api.delete_delegate_booking
    (p_booking_id                   => p_booking_id
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => l_validate
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
    rollback to delete_delegate_booking_swi;
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
    rollback to delete_delegate_booking_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_delegate_booking;
end ota_delegate_booking_swi;

/
