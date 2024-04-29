--------------------------------------------------------
--  DDL for Package Body OTA_EVENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EVENT_SWI" As
/* $Header: otevtswi.pkb 120.4.12010000.2 2009/05/05 12:39:18 pekasi ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_event_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_event >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_event
  (p_effective_date               in     date      default sysdate
  ,p_event_id                     in     number
  ,p_vendor_id                    in     number    default null
  ,p_activity_version_id          in     number    default null
  ,p_business_group_id            in     number
  ,p_organization_id              in     number    default null
  ,p_event_type                   in     varchar2
  ,p_object_version_number        out nocopy number
  ,p_title                        in     varchar2
  ,p_budget_cost                  in     number    default null
  ,p_actual_cost                  in     number    default null
  ,p_budget_currency_code         in     varchar2  default null
  ,p_centre                       in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_course_end_date              in     date      default null
  ,p_course_end_time              in     varchar2  default null
  ,p_course_start_date            in     date      default null
  ,p_course_start_time            in     varchar2  default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_enrolment_end_date           in     date      default null
  ,p_enrolment_start_date         in     date      default null
  ,p_language_id                  in     number    default null
  ,p_user_status                  in     varchar2  default null
  ,p_development_event_type       in     varchar2  default null
  ,p_event_status                 in     varchar2  default null
  ,p_price_basis                  in     varchar2  default null
  ,p_currency_code                in     varchar2  default null
  ,p_maximum_attendees            in     number    default null
  ,p_maximum_internal_attendees   in     number    default null
  ,p_minimum_attendees            in     number    default null
  ,p_standard_price               in     number    default null
  ,p_category_code                in     varchar2  default null
  ,p_parent_event_id              in     number    default null
  ,p_book_independent_flag        in     varchar2  default null
  ,p_public_event_flag            in     varchar2  default null
  ,p_secure_event_flag            in     varchar2  default null
  ,p_evt_information_category     in     varchar2  default null
  ,p_evt_information1             in     varchar2  default null
  ,p_evt_information2             in     varchar2  default null
  ,p_evt_information3             in     varchar2  default null
  ,p_evt_information4             in     varchar2  default null
  ,p_evt_information5             in     varchar2  default null
  ,p_evt_information6             in     varchar2  default null
  ,p_evt_information7             in     varchar2  default null
  ,p_evt_information8             in     varchar2  default null
  ,p_evt_information9             in     varchar2  default null
  ,p_evt_information10            in     varchar2  default null
  ,p_evt_information11            in     varchar2  default null
  ,p_evt_information12            in     varchar2  default null
  ,p_evt_information13            in     varchar2  default null
  ,p_evt_information14            in     varchar2  default null
  ,p_evt_information15            in     varchar2  default null
  ,p_evt_information16            in     varchar2  default null
  ,p_evt_information17            in     varchar2  default null
  ,p_evt_information18            in     varchar2  default null
  ,p_evt_information19            in     varchar2  default null
  ,p_evt_information20            in     varchar2  default null
  ,p_project_id                   in     number    default null
  ,p_owner_id                     in     number    default null
  ,p_line_id                      in     number    default null
  ,p_org_id                       in     number    default null
  ,p_training_center_id           in     number    default null
  ,p_location_id                  in     number    default null
  ,p_offering_id                  in     number    default null
  ,p_timezone                     in     varchar2  default null
  ,p_parent_offering_id           in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default null
  ,p_event_availability           in     varchar2  default null
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  l_event_id                      ota_events.event_id%TYPE;
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_event';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_event_swi;
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

      -- Ignore dff validation

      IF  p_event_type = 'SELFPACED' THEN



      ota_utility.ignore_dff_validation(p_dff_name => 'OTA_EVENTS');

      END IF;
  --
  -- Register Surrogate ID or user key values
  --
    ota_evt_ins.set_base_key_value
    (p_event_id => p_event_id
    );
  --
  -- Call API
  --
  ota_event_api.create_class
    (p_effective_date               => p_effective_date
    ,p_event_id                     => l_event_id
    ,p_vendor_id                    => p_vendor_id
    ,p_activity_version_id          => p_activity_version_id
    ,p_business_group_id            => p_business_group_id
    ,p_organization_id              => p_organization_id
    ,p_event_type                   => p_event_type
    ,p_object_version_number        => p_object_version_number
    ,p_title                        => p_title
    ,p_budget_cost                  => p_budget_cost
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_centre                       => p_centre
    ,p_comments                     => p_comments
    ,p_course_end_date              => p_course_end_date
    ,p_course_end_time              => p_course_end_time
    ,p_course_start_date            => p_course_start_date
    ,p_course_start_time            => p_course_start_time
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_enrolment_end_date           => p_enrolment_end_date
    ,p_enrolment_start_date         => p_enrolment_start_date
    ,p_language_id                  => p_language_id
    ,p_user_status                  => p_user_status
    ,p_development_event_type       => p_development_event_type
    ,p_event_status                 => p_event_status
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_standard_price               => p_standard_price
    ,p_category_code                => p_category_code
    ,p_parent_event_id              => p_parent_event_id
    ,p_book_independent_flag        => p_book_independent_flag
    ,p_public_event_flag            => p_public_event_flag
    ,p_secure_event_flag            => p_secure_event_flag
    ,p_evt_information_category     => p_evt_information_category
    ,p_evt_information1             => p_evt_information1
    ,p_evt_information2             => p_evt_information2
    ,p_evt_information3             => p_evt_information3
    ,p_evt_information4             => p_evt_information4
    ,p_evt_information5             => p_evt_information5
    ,p_evt_information6             => p_evt_information6
    ,p_evt_information7             => p_evt_information7
    ,p_evt_information8             => p_evt_information8
    ,p_evt_information9             => p_evt_information9
    ,p_evt_information10            => p_evt_information10
    ,p_evt_information11            => p_evt_information11
    ,p_evt_information12            => p_evt_information12
    ,p_evt_information13            => p_evt_information13
    ,p_evt_information14            => p_evt_information14
    ,p_evt_information15            => p_evt_information15
    ,p_evt_information16            => p_evt_information16
    ,p_evt_information17            => p_evt_information17
    ,p_evt_information18            => p_evt_information18
    ,p_evt_information19            => p_evt_information19
    ,p_evt_information20            => p_evt_information20
    ,p_project_id                   => p_project_id
    ,p_owner_id                     => p_owner_id
    ,p_line_id                      => p_line_id
    ,p_org_id                       => p_org_id
    ,p_training_center_id           => p_training_center_id
    ,p_location_id                  => p_location_id
    ,p_offering_id                  => p_offering_id
    ,p_timezone                     => p_timezone
    ,p_parent_offering_id           => p_parent_offering_id
    ,p_validate                     => l_validate
    ,p_data_source                  => p_data_source
    ,p_event_availability           => p_event_availability
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
    rollback to create_event_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
   -- p_event_id                     := null;
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
    rollback to create_event_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    --p_event_id                     := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_event;
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_event >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_event
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_event_id                     in     number
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
  l_proc    varchar2(72) := g_package ||'delete_event';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_event_swi;
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
  ota_event_api.delete_class
    (p_validate                     => l_validate
    ,p_event_id                     => p_event_id
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
    rollback to delete_event_swi;
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
    rollback to delete_event_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_event;
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_event >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_event
  (p_event_id                     in     number
  ,p_effective_date               in     date      default trunc(sysdate)
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_event_type                   in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_budget_cost                  in     number    default hr_api.g_number
  ,p_actual_cost                  in     number    default hr_api.g_number
  ,p_budget_currency_code         in     varchar2  default hr_api.g_varchar2
  ,p_centre                       in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_course_end_date              in     date      default hr_api.g_date
  ,p_course_end_time              in     varchar2  default hr_api.g_varchar2
  ,p_course_start_date            in     date      default hr_api.g_date
  ,p_course_start_time            in     varchar2  default hr_api.g_varchar2
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_enrolment_end_date           in     date      default hr_api.g_date
  ,p_enrolment_start_date         in     date      default hr_api.g_date
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_user_status                  in     varchar2  default hr_api.g_varchar2
  ,p_development_event_type       in     varchar2  default hr_api.g_varchar2
  ,p_event_status                 in     varchar2  default hr_api.g_varchar2
  ,p_price_basis                  in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_maximum_attendees            in     number    default hr_api.g_number
  ,p_maximum_internal_attendees   in     number    default hr_api.g_number
  ,p_minimum_attendees            in     number    default hr_api.g_number
  ,p_standard_price               in     number    default hr_api.g_number
  ,p_category_code                in     varchar2  default hr_api.g_varchar2
  ,p_parent_event_id              in     number    default hr_api.g_number
  ,p_book_independent_flag        in     varchar2  default hr_api.g_varchar2
  ,p_public_event_flag            in     varchar2  default hr_api.g_varchar2
  ,p_secure_event_flag            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_evt_information1             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information2             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information3             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information4             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information5             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information6             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information7             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information8             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information9             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information10            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information11            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information12            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information13            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information14            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information15            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information16            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information17            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information18            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information19            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information20            in     varchar2  default hr_api.g_varchar2
  ,p_project_id                   in     number    default hr_api.g_number
  ,p_owner_id                     in     number    default hr_api.g_number
  ,p_line_id                      in     number    default hr_api.g_number
  ,p_org_id                       in     number    default hr_api.g_number
  ,p_training_center_id           in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_offering_id                  in     number    default hr_api.g_number
  ,p_timezone                     in     varchar2  default hr_api.g_varchar2
  ,p_parent_offering_id           in     number    default hr_api.g_number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default hr_api.g_varchar2
  ,p_event_availability           in     varchar2  default null
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_event';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_event_swi;
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
  ota_event_api.update_class
    (p_event_id                     => p_event_id
    ,p_effective_date               => p_effective_date
    ,p_vendor_id                    => p_vendor_id
    ,p_activity_version_id          => p_activity_version_id
    ,p_business_group_id            => p_business_group_id
    ,p_organization_id              => p_organization_id
    ,p_event_type                   => p_event_type
    ,p_object_version_number        => p_object_version_number
    ,p_title                        => p_title
    ,p_budget_cost                  => p_budget_cost
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_centre                       => p_centre
    ,p_comments                     => p_comments
    ,p_course_end_date              => p_course_end_date
    ,p_course_end_time              => p_course_end_time
    ,p_course_start_date            => p_course_start_date
    ,p_course_start_time            => p_course_start_time
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_enrolment_end_date           => p_enrolment_end_date
    ,p_enrolment_start_date         => p_enrolment_start_date
    ,p_language_id                  => p_language_id
    ,p_user_status                  => p_user_status
    ,p_development_event_type       => p_development_event_type
    ,p_event_status                 => p_event_status
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_standard_price               => p_standard_price
    ,p_category_code                => p_category_code
    ,p_parent_event_id              => p_parent_event_id
    ,p_book_independent_flag        => p_book_independent_flag
    ,p_public_event_flag            => p_public_event_flag
    ,p_secure_event_flag            => p_secure_event_flag
    ,p_evt_information_category     => p_evt_information_category
    ,p_evt_information1             => p_evt_information1
    ,p_evt_information2             => p_evt_information2
    ,p_evt_information3             => p_evt_information3
    ,p_evt_information4             => p_evt_information4
    ,p_evt_information5             => p_evt_information5
    ,p_evt_information6             => p_evt_information6
    ,p_evt_information7             => p_evt_information7
    ,p_evt_information8             => p_evt_information8
    ,p_evt_information9             => p_evt_information9
    ,p_evt_information10            => p_evt_information10
    ,p_evt_information11            => p_evt_information11
    ,p_evt_information12            => p_evt_information12
    ,p_evt_information13            => p_evt_information13
    ,p_evt_information14            => p_evt_information14
    ,p_evt_information15            => p_evt_information15
    ,p_evt_information16            => p_evt_information16
    ,p_evt_information17            => p_evt_information17
    ,p_evt_information18            => p_evt_information18
    ,p_evt_information19            => p_evt_information19
    ,p_evt_information20            => p_evt_information20
    ,p_project_id                   => p_project_id
    ,p_owner_id                     => p_owner_id
    ,p_line_id                      => p_line_id
    ,p_org_id                       => p_org_id
    ,p_training_center_id           => p_training_center_id
    ,p_location_id                  => p_location_id
    ,p_offering_id                  => p_offering_id
    ,p_timezone                     => p_timezone
    ,p_parent_offering_id           => p_parent_offering_id
    ,p_validate                     => l_validate
    ,p_data_source                  => p_data_source
    ,p_event_availability           => p_event_availability
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
    rollback to update_event_swi;
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
    rollback to update_event_swi;
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
end update_event;

-- ----------------------------------------------------------------------------
-- |-----------------------------< update_enrollment >------------------------|
-- ----------------------------------------------------------------------------

procedure update_enrollment     (p_booking_id 	IN	NUMBER,
					             p_daemon_flag	IN	VARCHAR2,
					             p_daemon_type	IN	VARCHAR2,
					             p_booking_status_type_id        IN    NUMBER,
                                 p_event_id IN NUMBER,
                                 p_object_version_number  IN NUMBER,
					             p_return_status out nocopy varchar2) is

l_proc    varchar2(72) := g_package ||'update_enrollment';

l_object_version_number number;
l_tfl_object_version_number number;
l_finance_line_id number;
begin
     savepoint update_enrollment;
     --
    hr_multi_message.enable_message_list;
  l_object_version_number  := p_object_version_number ;
  ota_tdb_api_upd2.update_enrollment
  (
  p_booking_id                   => p_booking_id,
  p_booking_status_type_id       => p_booking_status_type_id ,
  P_event_id                     => p_event_id,
  p_enrollment_type              => 'S' ,
  p_daemon_flag                  => p_daemon_flag  ,
  p_daemon_type                  => p_daemon_type ,
    p_object_version_number	     =>    l_object_version_number,
  p_tfl_object_version_number        =>    l_tfl_object_version_number,
  p_finance_line_id                  =>    l_finance_line_id
  );
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,20);


exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_enrollment;
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
    rollback to update_enrollment;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --

    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_enrollment;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< upd2_update_event >------------------------|
-- ----------------------------------------------------------------------------

 procedure upd2_update_event
  (
  p_event			             in varchar2,
  p_event_id                     in number,
  p_object_version_number        in out nocopy number,
  p_event_status                 in out nocopy varchar2,
  p_validate                     in number default hr_api.g_false_num,
  p_reset_max_attendees		     in number default hr_api.g_false_num,
  p_update_finance_line		     in varchar2 default 'N',
  p_booking_status_type_id	     in number default null,
  p_date_status_changed 	     in date default null,
  p_maximum_attendees		     in number default null,
  p_change_status		         in varchar2 default 'A',
  p_return_status                out nocopy varchar2,
  p_check_for_warning            in varchar2 default 'Y',
  p_message_name                 out nocopy varchar2) is
  --
  --
  l_event_type 		varchar2(30);
  l_invalid_profile     boolean;
  l_waitlist_hours      number;
l_maximum_attendees_old number;

l_different_hours   number(13,2);
l_current_date      date;
l_event_date        date;
l_event_title       ota_events.title%type;
l_owner_id          ota_events.owner_id%type;
l_sysdate           varchar2(60);
l_boolean           boolean;

CURSOR C_EVENT_DATE (p_event_id ota_events.event_ID%type) IS
SELECT to_date(to_char(evt.Course_start_date,'DD-MM-YYYY')||EVT.Course_start_time,'DD-MM-YYYYHH24:MI'),EVENT_TYPE,TITLE,OWNER_ID,MAXIMUM_ATTENDEES
FROM   OTA_EVENTS  EVT
WHERE  evt.event_id = p_event_id;

CURSOR C_DATE IS
SELECT SYSDATE
FROM DUAL;


business_group_id	hr_all_organization_units.organization_id%TYPE;  --- ** Globalization changes

 l_validate boolean;
 l_reset_max_attendees  boolean;
 l_proc    varchar2(72) := g_package ||'upd2_update_event';

--
begin
      hr_utility.set_location(' Entering:' || l_proc,10);
	  --
	  -- Issue a savepoint
	  --
       savepoint upd2_update_event;
	  --
	  -- Initialise Multiple Message Detection
      --
     hr_multi_message.enable_message_list;

     OPEN c_event_date(p_event_id);
     FETCH c_event_date into l_event_date,l_event_type,l_event_title,l_owner_id,l_maximum_attendees_old;
     CLOSE c_event_date;
     if p_check_for_warning = 'Y' then

       if p_change_status = 'S' and p_event_status = 'A'
             then
            p_message_name := 'OTA_13557_EVT_CANCEL_TDB';
            p_return_status := hr_multi_message.get_return_status_disable;
            hr_utility.set_location(' Leaving:' || l_proc,20);
            return;
       end if;

       if p_change_status = 'S' and
            ota_evt_bus2.resource_booking_exists(p_event_id) then
            p_message_name := 'OTA_13525_EVT_CANCEL_RESOURCE';
            p_return_status := hr_multi_message.get_return_status_disable;
            hr_utility.set_location(' Leaving:' || l_proc,20);
            return;
       end if;

       IF p_change_status = 'A' AND
          p_maximum_attendees <> l_maximum_attendees_old THEN
            p_message_name := 'OTA_13699_EVT_PRICING';
            p_return_status := hr_multi_message.get_return_status_disable;
            hr_utility.set_location(' Leaving:' || l_proc,20);
            return;
       END IF;

     end if;

     l_validate := hr_api.constant_to_boolean
      (p_constant_value => p_validate);

     l_reset_max_attendees := hr_api.constant_to_boolean
      (p_constant_value => p_reset_max_attendees);

     OTA_EVT_API_UPD2.UPDATE_EVENT (
    P_EVENT			 => p_event,
    P_EVENT_ID                   => p_event_id,
    P_OBJECT_VERSION_NUMBER      => p_object_version_number  ,
    P_EVENT_STATUS               => p_event_status  ,
    P_VALIDATE		         => l_validate   ,
    P_BOOKING_STATUS_TYPE_ID     => p_booking_status_type_id,
    P_UPDATE_FINANCE_LINE	 => p_update_finance_line,
    P_RESET_MAX_ATTENDEES        => 	l_reset_max_attendees,
    P_DATE_STATUS_CHANGED	 => p_date_status_changed ,
    P_maximum_attendees		 => p_maximum_attendees	);

    commit;

    if ota_evt_bus2.wait_list_required(p_event_type => 'EVENT'
                                    ,p_event_id => p_event_id
                                    ,p_event_status => p_event_status
                                    ,p_booking_status_type_id => 1) then
  --


    begin
    --
      l_waitlist_hours := to_number(fnd_profile.value('OTA_AUTO_WAITLIST_DAYS'));
      l_invalid_profile := false;
    --
    exception
    when OTHERS then
      l_invalid_profile := true;
    --
    end;

    if fnd_profile.value('OTA_AUTO_WAITLIST_ACTIVE') = 'Y'   then


       OPEN C_DATE;
       FETCH C_DATE INTO l_CURRENT_DATE;
       close c_date;

       l_different_hours := l_event_date - l_current_date ;
       l_different_hours  := l_different_hours  * 24 ;

      IF (not l_invalid_profile) and
         fnd_profile.value('OTA_AUTO_WAITLIST_BOOKING_STATUS') is not null then
    --
         IF l_different_hours > nvl(l_waitlist_hours,0) THEN
	    business_group_id := OTA_GENERAL.get_business_group_id;
            ota_tdb_waitlist_api.auto_enroll_from_waitlist (
             p_validate          => false
            ,p_business_group_id => business_group_id
            ,p_event_id          => p_event_id
            );

       ELSE

	select to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS') into l_sysdate from dual;

        OTA_INITIALIZATION_WF.MANUAL_ENROLL_WAITLIST(
          	            p_itemtype 		=> 'OTWF',
				p_process		=> 'OTA_MANUAL_ENROLL_WAITLIST',
				p_Event_title	=> p_event_id,          --Enh 5606090: Language support for Event Details.
				p_item_key        => p_event_id||':'||l_sysdate,
         			p_owner_id 	      => l_owner_id
				);

       END IF;


         --   if l_event_type = 'SCHEDULED' then
            if (l_event_type ='SCHEDULED' or l_event_type ='SELFPACED') then
        --
        --
        -- We require an explicit commit if the enrollment has been
        -- performed by way of increasing the max on the events form.
        -- This is because the update has been carried out independently of
        -- the forms commit process, and no implicit commit has been done.
        --
              commit;
      --
            end if;

     END IF;

  else
       p_message_name := 'OTA_13553_WAITLIST_EXISTS';
       p_return_status := hr_multi_message.get_return_status_disable;
       hr_utility.set_location(' Leaving:' || l_proc,20);
       return;

-- ***
    --
  --
  end if;
  --
 end if;
--
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to upd2_update_event;
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
    rollback to upd2_update_event;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --

    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end upd2_update_event;


--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_session_overlap >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_session_overlap
  ( p_event_id IN NUMBER
   ,p_parent_event_id IN NUMBER
   ,p_session_date IN DATE
   ,p_session_start_time IN VARCHAR2
   ,p_session_end_time IN VARCHAR2
   ,p_warning OUT NOCOPY VARCHAR2)  IS

  cursor c_get_session is
  select nvl(course_start_time, '-99:99') course_start_time,
         nvl(course_end_time, '99:99') course_end_time
  from ota_events
  where event_id <> p_event_id
  and parent_event_id = p_parent_event_id
  and nvl(course_start_date, sysdate) = nvl(p_session_date, sysdate)
  and event_type = 'SESSION';

  BEGIN
  p_warning := 'N';
  for l_session in c_get_session loop
  --
    if nvl(p_session_start_time,'-99:99') <= l_session.course_end_time and
       nvl(p_session_end_time,'99:99') >= l_session.course_start_time then
    --
         p_warning := 'Y';
    --
    end if;
  --
  end loop;
--
  END check_session_overlap;


end ota_event_swi;

/
