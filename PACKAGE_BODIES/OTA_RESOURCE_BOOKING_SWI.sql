--------------------------------------------------------
--  DDL for Package Body OTA_RESOURCE_BOOKING_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RESOURCE_BOOKING_SWI" As
/* $Header: ottrbswi.pkb 120.3 2006/03/06 02:31:50 rdola noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_resource_booking_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_resource_booking >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_resource_booking
  (p_effective_date               in     date
  ,p_supplied_resource_id         in     number
  ,p_date_booking_placed          in     date
  ,p_status                       in     varchar2
  ,p_event_id                     in     number    default null
  ,p_absolute_price               in     number    default null
  ,p_booking_person_id            in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_contact_name                 in     varchar2  default null
  ,p_contact_phone_number         in     varchar2  default null
  ,p_delegates_per_unit           in     number    default null
  ,p_quantity                     in     number    default null
  ,p_required_date_from           in     date      default null
  ,p_required_date_to             in     date      default null
  ,p_required_end_time            in     varchar2  default null
  ,p_required_start_time          in     varchar2  default null
  ,p_deliver_to                   in     varchar2  default null
  ,p_primary_venue_flag           in     varchar2  default null
  ,p_role_to_play                 in     varchar2  default null
  ,p_trb_information_category     in     varchar2  default null
  ,p_trb_information1             in     varchar2  default null
  ,p_trb_information2             in     varchar2  default null
  ,p_trb_information3             in     varchar2  default null
  ,p_trb_information4             in     varchar2  default null
  ,p_trb_information5             in     varchar2  default null
  ,p_trb_information6             in     varchar2  default null
  ,p_trb_information7             in     varchar2  default null
  ,p_trb_information8             in     varchar2  default null
  ,p_trb_information9             in     varchar2  default null
  ,p_trb_information10            in     varchar2  default null
  ,p_trb_information11            in     varchar2  default null
  ,p_trb_information12            in     varchar2  default null
  ,p_trb_information13            in     varchar2  default null
  ,p_trb_information14            in     varchar2  default null
  ,p_trb_information15            in     varchar2  default null
  ,p_trb_information16            in     varchar2  default null
  ,p_trb_information17            in     varchar2  default null
  ,p_trb_information18            in     varchar2  default null
  ,p_trb_information19            in     varchar2  default null
  ,p_trb_information20            in     varchar2  default null
  ,p_display_to_learner_flag      in     varchar2  default null
  ,p_book_entire_period_flag    in     varchar2  default null
  --,p_unbook_request_flag    in     varchar2  default null
  ,p_chat_id                      in number
  ,p_forum_id                     in number
  ,p_validate                     in     number
  ,p_resource_booking_id          in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_finance_header_id            in number           default null
  ,p_currency_code                in varchar2         default null
  ,p_money_amount                 in number           default null
  ,p_finance_line_id              out nocopy number
  ,p_finance_line_ovn             out nocopy NUMBER
  ,p_timezone_code                IN VARCHAR2 DEFAULT NULL
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_resource_booking_id          number;
  l_finance_line_id number;
  l_finance_line_ovn number;
  l_proc    varchar2(72) := g_package ||'create_resource_booking';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_resource_booking_swi;
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
  ota_trb_ins.set_base_key_value
    (p_resource_booking_id => p_resource_booking_id
    );
  --
  -- Call API
  --
  ota_resource_booking_api.create_resource_booking
    (p_effective_date               => p_effective_date
    ,p_supplied_resource_id         => p_supplied_resource_id
    ,p_date_booking_placed          => p_date_booking_placed
    ,p_status                       => p_status
    ,p_event_id                     => p_event_id
    ,p_absolute_price               => p_absolute_price
    ,p_booking_person_id            => p_booking_person_id
    ,p_comments                     => p_comments
    ,p_contact_name                 => p_contact_name
    ,p_contact_phone_number         => p_contact_phone_number
    ,p_delegates_per_unit           => p_delegates_per_unit
    ,p_quantity                     => p_quantity
    ,p_required_date_from           => p_required_date_from
    ,p_required_date_to             => p_required_date_to
    ,p_required_end_time            => p_required_end_time
    ,p_required_start_time          => p_required_start_time
    ,p_deliver_to                   => p_deliver_to
    ,p_primary_venue_flag           => p_primary_venue_flag
    ,p_role_to_play                 => p_role_to_play
    ,p_trb_information_category     => p_trb_information_category
    ,p_trb_information1             => p_trb_information1
    ,p_trb_information2             => p_trb_information2
    ,p_trb_information3             => p_trb_information3
    ,p_trb_information4             => p_trb_information4
    ,p_trb_information5             => p_trb_information5
    ,p_trb_information6             => p_trb_information6
    ,p_trb_information7             => p_trb_information7
    ,p_trb_information8             => p_trb_information8
    ,p_trb_information9             => p_trb_information9
    ,p_trb_information10            => p_trb_information10
    ,p_trb_information11            => p_trb_information11
    ,p_trb_information12            => p_trb_information12
    ,p_trb_information13            => p_trb_information13
    ,p_trb_information14            => p_trb_information14
    ,p_trb_information15            => p_trb_information15
    ,p_trb_information16            => p_trb_information16
    ,p_trb_information17            => p_trb_information17
    ,p_trb_information18            => p_trb_information18
    ,p_trb_information19            => p_trb_information19
    ,p_trb_information20            => p_trb_information20
    ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_book_entire_period_flag    => p_book_entire_period_flag
   -- ,p_unbook_request_flag    => p_unbook_request_flag
    ,p_chat_id                      => p_chat_id
    ,p_forum_id                     => p_forum_id
    ,p_validate                     => l_validate
    ,p_resource_booking_id          => l_resource_booking_id
    ,p_object_version_number        => p_object_version_number
    ,p_timezone_code                => p_timezone_code
    );
  --

   --
   if p_money_amount is not null then
      ota_finance.maintain_finance_line
      ( p_finance_header_id    => p_finance_header_id
      , p_currency_code        => p_currency_code
      , p_money_amount         => p_money_amount
      , p_resource_booking_id  => l_resource_booking_id
      , p_finance_line_id      => l_finance_line_id
      , p_object_version_number => l_finance_line_ovn
      );
   --
   p_finance_line_id  := l_finance_line_id;
   p_finance_line_ovn := l_finance_line_ovn;
   --
   end if;



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
    rollback to create_resource_booking_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to create_resource_booking_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_resource_booking;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_resource_booking >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_resource_booking
  (p_resource_booking_id          in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_resource_booking';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_resource_booking_swi;
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
  ota_resource_booking_api.delete_resource_booking
    (p_resource_booking_id          => p_resource_booking_id
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
    rollback to delete_resource_booking_swi;
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
    rollback to delete_resource_booking_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_resource_booking;
-- ----------------------------------------------------------------------------
-- |------------------------< update_resource_booking >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_resource_booking
  (p_effective_date               in     date
  ,p_supplied_resource_id         in     number
  ,p_date_booking_placed          in     date
  ,p_status                       in     varchar2
  ,p_event_id                     in     number    default hr_api.g_number
  ,p_absolute_price               in     number    default hr_api.g_number
  ,p_booking_person_id            in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_contact_name                 in     varchar2  default hr_api.g_varchar2
  ,p_contact_phone_number         in     varchar2  default hr_api.g_varchar2
  ,p_delegates_per_unit           in     number    default hr_api.g_number
  ,p_quantity                     in     number    default hr_api.g_number
  ,p_required_date_from           in     date      default hr_api.g_date
  ,p_required_date_to             in     date      default hr_api.g_date
  ,p_required_end_time            in     varchar2  default hr_api.g_varchar2
  ,p_required_start_time          in     varchar2  default hr_api.g_varchar2
  ,p_deliver_to                   in     varchar2  default hr_api.g_varchar2
  ,p_primary_venue_flag           in     varchar2  default hr_api.g_varchar2
  ,p_role_to_play                 in     varchar2  default hr_api.g_varchar2
  ,p_trb_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_trb_information1             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information2             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information3             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information4             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information5             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information6             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information7             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information8             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information9             in     varchar2  default hr_api.g_varchar2
  ,p_trb_information10            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information11            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information12            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information13            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information14            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information15            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information16            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information17            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information18            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information19            in     varchar2  default hr_api.g_varchar2
  ,p_trb_information20            in     varchar2  default hr_api.g_varchar2
  ,p_display_to_learner_flag      in     varchar2  default hr_api.g_varchar2
  ,p_book_entire_period_flag    in     varchar2  default hr_api.g_varchar2
 -- ,p_unbook_request_flag    in     varchar2  default hr_api.g_varchar2
  ,p_chat_id                      in     number
  ,p_forum_id                     in     number
  ,p_validate                     in     number
  ,p_resource_booking_id          in     number
  ,p_object_version_number        in   out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_finance_header_id            in number           default null
  ,p_currency_code                in varchar2         default null
  ,p_money_amount                 in number           default null
  ,p_finance_line_id              in out nocopy number
  ,p_finance_line_transfer        in varchar2         default null
  ,p_finance_line_ovn             in out nocopy number
  ,p_cancel_finance_line          in varchar2         default null
  ,p_finance_change_flag          in varchar2         default 'N'
  ,p_timezone_code                IN VARCHAR2     DEFAULT hr_api.g_varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_finance_line_id number;
  l_finance_function varchar2(1);
  l_cancelled_flag   varchar2(1);
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_resource_booking';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_resource_booking_swi;
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
  ota_resource_booking_api.update_resource_booking
    (p_effective_date               => p_effective_date
    ,p_supplied_resource_id         => p_supplied_resource_id
    ,p_date_booking_placed          => p_date_booking_placed
    ,p_status                       => p_status
    ,p_event_id                     => p_event_id
    ,p_absolute_price               => p_absolute_price
    ,p_booking_person_id            => p_booking_person_id
    ,p_comments                     => p_comments
    ,p_contact_name                 => p_contact_name
    ,p_contact_phone_number         => p_contact_phone_number
    ,p_delegates_per_unit           => p_delegates_per_unit
    ,p_quantity                     => p_quantity
    ,p_required_date_from           => p_required_date_from
    ,p_required_date_to             => p_required_date_to
    ,p_required_end_time            => p_required_end_time
    ,p_required_start_time          => p_required_start_time
    ,p_deliver_to                   => p_deliver_to
    ,p_primary_venue_flag           => p_primary_venue_flag
    ,p_role_to_play                 => p_role_to_play
    ,p_trb_information_category     => p_trb_information_category
    ,p_trb_information1             => p_trb_information1
    ,p_trb_information2             => p_trb_information2
    ,p_trb_information3             => p_trb_information3
    ,p_trb_information4             => p_trb_information4
    ,p_trb_information5             => p_trb_information5
    ,p_trb_information6             => p_trb_information6
    ,p_trb_information7             => p_trb_information7
    ,p_trb_information8             => p_trb_information8
    ,p_trb_information9             => p_trb_information9
    ,p_trb_information10            => p_trb_information10
    ,p_trb_information11            => p_trb_information11
    ,p_trb_information12            => p_trb_information12
    ,p_trb_information13            => p_trb_information13
    ,p_trb_information14            => p_trb_information14
    ,p_trb_information15            => p_trb_information15
    ,p_trb_information16            => p_trb_information16
    ,p_trb_information17            => p_trb_information17
    ,p_trb_information18            => p_trb_information18
    ,p_trb_information19            => p_trb_information19
    ,p_trb_information20            => p_trb_information20
    ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_book_entire_period_flag    => p_book_entire_period_flag
  --  ,p_unbook_request_flag    => p_unbook_request_flag
    ,p_chat_id                      => p_chat_id
    ,p_forum_id                     => p_forum_id
    ,p_validate                     => l_validate
    ,p_resource_booking_id          => p_resource_booking_id
    ,p_object_version_number        => p_object_version_number
    ,p_timezone_code                => p_timezone_code
    );
  --


hr_utility.set_location('Entering:'||l_proc, 10);
  if p_finance_change_flag = 'Y' then
     if p_finance_line_id is null then
        if p_money_amount is not null then
           l_finance_function := 'I';
        end if;
     elsif
        p_cancel_finance_line = 'Y' then
           l_finance_function := 'C';
     elsif
        p_money_amount is not null then
           l_finance_function := 'U';
     end if;
  end if;
  --
hr_utility.set_location('Entering:'||l_proc, 15);
hr_utility.trace('L_FINANCE_FUNCTION = '||l_finance_function);
  if l_finance_function = 'I' then
   --
         ota_finance.maintain_finance_line
         ( p_finance_header_id    => p_finance_header_id
         , p_currency_code        => p_currency_code
         , p_money_amount         => p_money_amount
         , p_resource_booking_id  => p_resource_booking_id
         , p_finance_line_id      => l_finance_line_id
         , p_object_version_number => p_finance_line_ovn
         );
      --
      p_finance_line_id  := l_finance_line_id;
      --
   elsif l_finance_function = 'U' then
      --
      ota_finance.maintain_finance_line
         ( p_finance_header_id     => p_finance_header_id
         , p_finance_line_id       => p_finance_line_id
         , p_object_version_number => p_finance_line_ovn
         , p_money_amount          => p_money_amount
         );
      --
   elsif l_finance_function = 'C' then
      l_cancelled_flag := 'N';
      ota_tfl_api_business_rules2.cancel_finance_line
         ( p_finance_line_id       => p_finance_line_id
         , p_cancelled_flag        => l_cancelled_flag
         , p_transfer_status       => p_finance_line_transfer
         , p_finance_header_id     => p_finance_header_id
         , p_validate              => FALSE);
   end if;
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
    rollback to update_resource_booking_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to update_resource_booking_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_resource_booking;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_trainer_competence >-----------------------|
-- ----------------------------------------------------------------------------
procedure check_trainer_competence
  (p_event_id                       in              number
  ,p_supplied_resource_id           in              number
  ,p_required_date_from             in              date
  ,p_required_date_to               in              date
  ,p_warning                        out nocopy      varchar2
  ) is
  --
  -- local variables
  --
  l_warning       boolean;
  l_proc          varchar2(72)     := g_package ||'check_trainer_competence';
  l_end_of_time   date;
  --
Begin
  --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  l_end_of_time := hr_api.g_eot;
  --
  ota_trb_api_procedures.check_trainer_competence
    (p_event_id                      =>   p_event_id
    ,p_supplied_resource_id          =>   p_supplied_resource_id
    ,p_required_date_from            =>   p_required_date_from
    ,p_required_date_to              =>   p_required_date_to
    ,p_end_of_time                   =>   l_end_of_time
    ,p_warn                          =>   l_warning
    );
  --
  If l_warning then
    p_warning := 'Y';
  else
    p_warning := 'N';
  End If;
  --
  hr_utility.set_location(' Entering:' || l_proc,20);
  --
End Check_trainer_competence;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Check_double_booking >-------------------------|
-- ----------------------------------------------------------------------------
procedure Check_double_booking
  (p_supplied_resource_id           in              number
  ,p_required_date_from             in              date
  ,p_required_start_time            in              varchar2
  ,p_required_date_to               in              date
  ,p_required_end_time              in              varchar2
  ,p_resource_booking_id            in              number
  ,p_book_entire_period_flag              in              varchar2
  ,p_warning                        out nocopy      VARCHAR2
  ,p_timezone_code                  IN              VARCHAR2
  ) is
  --
  -- Local variables
  --
  l_warning       boolean;
  l_proc          varchar2(72)     := g_package ||'Check_double_booking';
  --
Begin
  --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  l_warning := ota_trb_api_procedures.check_double_booking
                (p_supplied_resource_id       =>    p_supplied_resource_id
                ,p_required_date_from         =>    p_required_date_from
                ,p_required_start_time        =>    p_required_start_time
                ,p_required_date_to           =>    p_required_date_to
                ,p_required_end_time          =>    p_required_end_time
                ,p_resource_booking_id        =>    p_resource_booking_id
		,p_book_entire_period_flag    => p_book_entire_period_flag
		,p_timezone                   => p_timezone_code
                );
  --
  if l_warning then
    --
    p_warning := 'Y';
  else
    --
    p_warning := 'N';
  End If;
  --
  hr_utility.set_location(' Entering:' || l_proc,20);
  --
End Check_double_booking;
--
end ota_resource_booking_swi;

/
