--------------------------------------------------------
--  DDL for Package Body OTA_RESOURCE_BOOKING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RESOURCE_BOOKING" as
/* $Header: ottrb03t.pkb 120.2 2006/03/15 02:21:44 niarora noship $ */
--
Procedure ins
  (
  p_resource_booking_id          out nocopy number,
  p_supplied_resource_id         in number,
  p_event_id                     in number           default null,
  p_date_booking_placed          in date,
  p_object_version_number        out nocopy number,
  p_status                       in varchar2,
  p_absolute_price               in number           default null,
  p_booking_person_id            in number           default null,
  p_comments                     in varchar2         default null,
  p_contact_name                 in varchar2         default null,
  p_contact_phone_number         in varchar2         default null,
  p_delegates_per_unit           in number           default null,
  p_quantity                     in number           default null,
  p_required_date_from           in date             default null,
  p_required_date_to             in date             default null,
  p_required_end_time            in varchar2         default null,
  p_required_start_time          in varchar2         default null,
  p_deliver_to                   in varchar2         default null,
  p_primary_venue_flag           in varchar2         default null,
  p_role_to_play                 in varchar2         default null,
  p_trb_information_category     in varchar2         default null,
  p_trb_information1             in varchar2         default null,
  p_trb_information2             in varchar2         default null,
  p_trb_information3             in varchar2         default null,
  p_trb_information4             in varchar2         default null,
  p_trb_information5             in varchar2         default null,
  p_trb_information6             in varchar2         default null,
  p_trb_information7             in varchar2         default null,
  p_trb_information8             in varchar2         default null,
  p_trb_information9             in varchar2         default null,
  p_trb_information10            in varchar2         default null,
  p_trb_information11            in varchar2         default null,
  p_trb_information12            in varchar2         default null,
  p_trb_information13            in varchar2         default null,
  p_trb_information14            in varchar2         default null,
  p_trb_information15            in varchar2         default null,
  p_trb_information16            in varchar2         default null,
  p_trb_information17            in varchar2         default null,
  p_trb_information18            in varchar2         default null,
  p_trb_information19            in varchar2         default null,
  p_trb_information20            in varchar2         default null,
  p_finance_header_id            in number           default null,
  p_currency_code                in varchar2         default null,
  p_money_amount                 in number           default null,
  p_finance_line_id              out nocopy number,
  p_finance_line_ovn             out nocopy number,
  p_display_to_learner_flag      in varchar2         default null,
  p_book_entire_period_flag      in varchar2         default null,
  p_chat_id                      in number           default null,
  p_forum_id                     in number           default null,
  p_timezone_code          in varchar2         default null
  ) is
--
l_resource_booking_id number;
l_object_version_number number;
l_finance_line_id number;
l_finance_line_ovn number;
--
begin

ota_resource_booking_api.create_resource_booking
  (  sysdate
  ,p_supplied_resource_id
 ,p_date_booking_placed
 ,p_status
 ,p_event_id
 ,p_absolute_price
 ,p_booking_person_id
 ,p_comments
 ,p_contact_name
 ,p_contact_phone_number
 ,p_delegates_per_unit
 ,p_quantity
 ,p_required_date_from
 ,p_required_date_to
 ,p_required_end_time
 ,p_required_start_time
 ,p_deliver_to
 ,p_primary_venue_flag
 ,p_role_to_play
 ,p_trb_information_category
 ,p_trb_information1
 ,p_trb_information2
 ,p_trb_information3
 ,p_trb_information4
 ,p_trb_information5
 ,p_trb_information6
 ,p_trb_information7
 ,p_trb_information8
 ,p_trb_information9
 ,p_trb_information10
 ,p_trb_information11
 ,p_trb_information12
 ,p_trb_information13
 ,p_trb_information14
 ,p_trb_information15
 ,p_trb_information16
 ,p_trb_information17
 ,p_trb_information18
 ,p_trb_information19
 ,p_trb_information20
 ,p_display_to_learner_flag
 ,p_book_entire_period_flag
 ,p_chat_id
 ,p_forum_id
 ,FALSE
 ,l_resource_booking_id
 ,l_object_version_number,
 p_timezone_code
 );
   --
   p_resource_booking_id   := l_resource_booking_id;
   p_object_version_number := l_object_version_number;
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
--
end ins;
-------------------------------------------------------------------
Procedure upd
  (
  p_resource_booking_id          in number,
  p_supplied_resource_id         in number,
  p_event_id                     in number           default null,
  p_date_booking_placed          in date,
  p_object_version_number        in out nocopy number,
  p_status                       in varchar2,
  p_absolute_price               in number           default null,
  p_booking_person_id            in number           default null,
  p_comments                     in varchar2         default null,
  p_contact_name                 in varchar2         default null,
  p_contact_phone_number         in varchar2         default null,
  p_delegates_per_unit           in number           default null,
  p_quantity                     in number           default null,
  p_required_date_from           in date             default null,
  p_required_date_to             in date             default null,
  p_required_end_time            in varchar2         default null,
  p_required_start_time          in varchar2         default null,
  p_deliver_to                   in varchar2         default null,
  p_primary_venue_flag           in varchar2         default null,
  p_role_to_play                 in varchar2         default null,
  p_trb_information_category     in varchar2         default null,
  p_trb_information1             in varchar2         default null,
  p_trb_information2             in varchar2         default null,
  p_trb_information3             in varchar2         default null,
  p_trb_information4             in varchar2         default null,
  p_trb_information5             in varchar2         default null,
  p_trb_information6             in varchar2         default null,
  p_trb_information7             in varchar2         default null,
  p_trb_information8             in varchar2         default null,
  p_trb_information9             in varchar2         default null,
  p_trb_information10            in varchar2         default null,
  p_trb_information11            in varchar2         default null,
  p_trb_information12            in varchar2         default null,
  p_trb_information13            in varchar2         default null,
  p_trb_information14            in varchar2         default null,
  p_trb_information15            in varchar2         default null,
  p_trb_information16            in varchar2         default null,
  p_trb_information17            in varchar2         default null,
  p_trb_information18            in varchar2         default null,
  p_trb_information19            in varchar2         default null,
  p_trb_information20            in varchar2         default null,
  p_finance_header_id            in number           default null,
  p_currency_code                in varchar2         default null,
  p_money_amount                 in number           default null,
  p_finance_line_id              in out nocopy number,
  p_finance_line_transfer        in varchar2         default null,
  p_finance_line_ovn             in out nocopy number,
  p_cancel_finance_line          in varchar2         default null,
  p_finance_change_flag          in varchar2         default 'N',
  p_display_to_learner_flag      in varchar2         default hr_api.g_varchar2,
  p_book_entire_period_flag      in varchar2         default hr_api.g_varchar2,
  p_chat_id                      in number           default null,
  p_forum_id                     in number           default null,
  p_timezone_code          in varchar2         default hr_api.g_varchar2
  ) is
--
l_object_version_number number;
l_finance_line_id number;
l_finance_function varchar2(1);
l_cancelled_flag   varchar2(1);
--
l_proc varchar2(80) := 'ota_resource_booking.upd';
--
begin
--
l_object_version_number := p_object_version_number;

hr_utility.set_location('Entering:'||l_proc, 5);
  ota_resource_booking_api.update_resource_booking
  (  sysdate
 ,p_supplied_resource_id
 ,p_date_booking_placed
 ,p_status
  ,p_event_id
 ,p_absolute_price
 ,p_booking_person_id
 ,p_comments
 ,p_contact_name
 ,p_contact_phone_number
 ,p_delegates_per_unit
 ,p_quantity
 ,p_required_date_from
 ,p_required_date_to
 ,p_required_end_time
 ,p_required_start_time
 ,p_deliver_to
 ,p_primary_venue_flag
 ,p_role_to_play
 ,p_trb_information_category
 ,p_trb_information1
 ,p_trb_information2
 ,p_trb_information3
 ,p_trb_information4
 ,p_trb_information5
 ,p_trb_information6
 ,p_trb_information7
 ,p_trb_information8
 ,p_trb_information9
 ,p_trb_information10
 ,p_trb_information11
 ,p_trb_information12
 ,p_trb_information13
 ,p_trb_information14
 ,p_trb_information15
 ,p_trb_information16
 ,p_trb_information17
 ,p_trb_information18
 ,p_trb_information19
 ,p_trb_information20
 ,p_display_to_learner_flag
 ,p_book_entire_period_flag
 ,p_chat_id
 ,p_forum_id
 ,FALSE
 ,P_resource_booking_id
 ,l_object_version_number,
 p_timezone_code
);
 --
p_object_version_number := l_object_version_number;

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
end upd;
--
end ota_resource_booking;

/
