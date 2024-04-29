--------------------------------------------------------
--  DDL for Package Body OTA_RESOURCE_BOOKING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RESOURCE_BOOKING_API" as
/* $Header: ottrbapi.pkb 120.4 2006/03/06 02:37:26 rdola noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_RESOURCE_BOOKING_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_resource_booking >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_resource_booking
  (p_effective_date                 in     date
  ,p_supplied_resource_id           in     number
  ,p_date_booking_placed            in     date
  ,p_status                         in     varchar2
  ,p_event_id                       in     number   default null
  ,p_absolute_price                 in     number   default null
  ,p_booking_person_id              in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_contact_name                   in     varchar2 default null
  ,p_contact_phone_number           in     varchar2 default null
  ,p_delegates_per_unit             in     number   default null
  ,p_quantity                       in     number   default null
  ,p_required_date_from             in     date     default null
  ,p_required_date_to               in     date     default null
  ,p_required_end_time              in     varchar2 default null
  ,p_required_start_time            in     varchar2 default null
  ,p_deliver_to                     in     varchar2 default null
  ,p_primary_venue_flag             in     varchar2 default null
  ,p_role_to_play                   in     varchar2 default null
  ,p_trb_information_category       in     varchar2 default null
  ,p_trb_information1               in     varchar2 default null
  ,p_trb_information2               in     varchar2 default null
  ,p_trb_information3               in     varchar2 default null
  ,p_trb_information4               in     varchar2 default null
  ,p_trb_information5               in     varchar2 default null
  ,p_trb_information6               in     varchar2 default null
  ,p_trb_information7               in     varchar2 default null
  ,p_trb_information8               in     varchar2 default null
  ,p_trb_information9               in     varchar2 default null
  ,p_trb_information10              in     varchar2 default null
  ,p_trb_information11              in     varchar2 default null
  ,p_trb_information12              in     varchar2 default null
  ,p_trb_information13              in     varchar2 default null
  ,p_trb_information14              in     varchar2 default null
  ,p_trb_information15              in     varchar2 default null
  ,p_trb_information16              in     varchar2 default null
  ,p_trb_information17              in     varchar2 default null
  ,p_trb_information18              in     varchar2 default null
  ,p_trb_information19              in     varchar2 default null
  ,p_trb_information20              in     varchar2 default null
  ,p_display_to_learner_flag      in     varchar2  default null
  ,p_book_entire_period_flag    in     varchar2  default null
 -- ,p_unbook_request_flag          in     varchar2  default null
  ,p_chat_id                        in  number default null
  ,p_forum_id                       in  number default null
  ,p_validate                       in  boolean  default false
  ,p_resource_booking_id            out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_timezone_code                  IN  VARCHAR2 DEFAULT NULL
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_resource_booking ';
  l_object_version_number   number;
  l_effective_date          date;
  l_resource_booking_id     ota_resource_bookings.resource_booking_id%type ;

  l_person_id per_people_f.person_id%type;

cursor get_trainer_id is
select osr.trainer_id from ota_suppliable_resources osr
where
osr.resource_type ='T'
and osr.supplied_resource_id = p_supplied_resource_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_resource_booking;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
  ota_resource_booking_bk1.create_resource_booking_b(
  p_effective_date               => l_effective_date      ,
  p_supplied_resource_id         => p_supplied_resource_id,
  p_date_booking_placed          => p_date_booking_placed ,
  p_status                       => p_status              ,
  p_event_id                     => p_event_id            ,
  p_absolute_price               => p_absolute_price      ,
  p_booking_person_id            => p_booking_person_id   ,
  p_comments                     => p_comments            ,
  p_contact_name                 => p_contact_name        ,
  p_contact_phone_number         => p_contact_phone_number,
  p_delegates_per_unit           => p_delegates_per_unit  ,
  p_quantity                     => p_quantity            ,
  p_required_date_from           => p_required_date_from  ,
  p_required_date_to             => p_required_date_to    ,
  p_required_end_time            => p_required_end_time   ,
  p_required_start_time          => p_required_start_time ,
  p_deliver_to                   => p_deliver_to          ,
  p_primary_venue_flag           => p_primary_venue_flag  ,
  p_role_to_play                 => p_role_to_play        ,
  p_trb_information_category     => p_trb_information_category    ,
  p_trb_information1             => p_trb_information1            ,
  p_trb_information2             => p_trb_information2            ,
  p_trb_information3             => p_trb_information3            ,
  p_trb_information4             => p_trb_information4            ,
  p_trb_information5             => p_trb_information5            ,
  p_trb_information6             => p_trb_information6            ,
  p_trb_information7             => p_trb_information7            ,
  p_trb_information8             => p_trb_information8            ,
  p_trb_information9             => p_trb_information9            ,
  p_trb_information10            => p_trb_information10           ,
  p_trb_information11            => p_trb_information11           ,
  p_trb_information12            => p_trb_information12           ,
  p_trb_information13            => p_trb_information13           ,
  p_trb_information14            => p_trb_information14           ,
  p_trb_information15            => p_trb_information15           ,
  p_trb_information16            => p_trb_information16           ,
  p_trb_information17            => p_trb_information17           ,
  p_trb_information18            => p_trb_information18           ,
  p_trb_information19            => p_trb_information19           ,
  p_trb_information20            => p_trb_information20           ,
  p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_book_entire_period_flag    => p_book_entire_period_flag
--    ,p_unbook_request_flag    => p_unbook_request_flag ,
  ,p_chat_id                     => p_chat_id
  ,p_forum_id                    => p_forum_id
  ,p_resource_booking_id          => l_resource_booking_id         ,
  p_object_version_number        => l_object_version_number
  ,p_timezone_code               => p_timezone_code );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_resource_booking'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_trb_ins.ins(
  p_effective_date               => l_effective_date      ,
  p_supplied_resource_id         => p_supplied_resource_id,
  p_date_booking_placed          => p_date_booking_placed ,
  p_status                       => p_status              ,
  p_event_id                     => p_event_id            ,
  p_absolute_price               => p_absolute_price      ,
  p_booking_person_id            => p_booking_person_id   ,
  p_comments                     => p_comments            ,
  p_contact_name                 => p_contact_name        ,
  p_contact_phone_number         => p_contact_phone_number,
  p_delegates_per_unit           => p_delegates_per_unit  ,
  p_quantity                     => p_quantity            ,
  p_required_date_from           => p_required_date_from  ,
  p_required_date_to             => p_required_date_to    ,
  p_required_end_time            => p_required_end_time   ,
  p_required_start_time          => p_required_start_time ,
  p_deliver_to                   => p_deliver_to          ,
  p_primary_venue_flag           => p_primary_venue_flag  ,
  p_role_to_play                 => p_role_to_play        ,
  p_trb_information_category     => p_trb_information_category    ,
  p_trb_information1             => p_trb_information1            ,
  p_trb_information2             => p_trb_information2            ,
  p_trb_information3             => p_trb_information3            ,
  p_trb_information4             => p_trb_information4            ,
  p_trb_information5             => p_trb_information5            ,
  p_trb_information6             => p_trb_information6            ,
  p_trb_information7             => p_trb_information7            ,
  p_trb_information8             => p_trb_information8            ,
  p_trb_information9             => p_trb_information9            ,
  p_trb_information10            => p_trb_information10           ,
  p_trb_information11            => p_trb_information11           ,
  p_trb_information12            => p_trb_information12           ,
  p_trb_information13            => p_trb_information13           ,
  p_trb_information14            => p_trb_information14           ,
  p_trb_information15            => p_trb_information15           ,
  p_trb_information16            => p_trb_information16           ,
  p_trb_information17            => p_trb_information17           ,
  p_trb_information18            => p_trb_information18           ,
  p_trb_information19            => p_trb_information19           ,
  p_trb_information20            => p_trb_information20           ,
  p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_book_entire_period_flag    => p_book_entire_period_flag
  --  ,p_unbook_request_flag    => p_unbook_request_flag,
 , p_chat_id                     => p_chat_id
 , p_forum_id                    => p_forum_id
 , p_resource_booking_id          => l_resource_booking_id         ,
  p_object_version_number        => l_object_version_number
  ,p_timezone_code               => p_timezone_code);

  --
  -- Call After Process User Hook
  --
  begin
  OTA_resource_booking_bk1.create_resource_booking_a
 (
  p_effective_date               => l_effective_date      ,
  p_supplied_resource_id         => p_supplied_resource_id,
  p_date_booking_placed          => p_date_booking_placed ,
  p_status                       => p_status              ,
  p_event_id                     => p_event_id            ,
  p_absolute_price               => p_absolute_price      ,
  p_booking_person_id            => p_booking_person_id   ,
  p_comments                     => p_comments            ,
  p_contact_name                 => p_contact_name        ,
  p_contact_phone_number         => p_contact_phone_number,
  p_delegates_per_unit           => p_delegates_per_unit  ,
  p_quantity                     => p_quantity            ,
  p_required_date_from           => p_required_date_from  ,
  p_required_date_to             => p_required_date_to    ,
  p_required_end_time            => p_required_end_time   ,
  p_required_start_time          => p_required_start_time ,
  p_deliver_to                   => p_deliver_to          ,
  p_primary_venue_flag           => p_primary_venue_flag  ,
  p_role_to_play                 => p_role_to_play        ,
  p_trb_information_category     => p_trb_information_category    ,
  p_trb_information1             => p_trb_information1            ,
  p_trb_information2             => p_trb_information2            ,
  p_trb_information3             => p_trb_information3            ,
  p_trb_information4             => p_trb_information4            ,
  p_trb_information5             => p_trb_information5            ,
  p_trb_information6             => p_trb_information6            ,
  p_trb_information7             => p_trb_information7            ,
  p_trb_information8             => p_trb_information8            ,
  p_trb_information9             => p_trb_information9            ,
  p_trb_information10            => p_trb_information10           ,
  p_trb_information11            => p_trb_information11           ,
  p_trb_information12            => p_trb_information12           ,
  p_trb_information13            => p_trb_information13           ,
  p_trb_information14            => p_trb_information14           ,
  p_trb_information15            => p_trb_information15           ,
  p_trb_information16            => p_trb_information16           ,
  p_trb_information17            => p_trb_information17           ,
  p_trb_information18            => p_trb_information18           ,
  p_trb_information19            => p_trb_information19           ,
  p_trb_information20            => p_trb_information20           ,
  p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_book_entire_period_flag    => p_book_entire_period_flag
  --  ,p_unbook_request_flag    => p_unbook_request_flag,
  ,p_chat_id                     => p_chat_id
  ,p_forum_id                    => p_forum_id
  ,p_resource_booking_id          => l_resource_booking_id         ,
  p_object_version_number        => l_object_version_number
  ,p_timezone_code               => p_timezone_code);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_resource_booking'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  p_object_version_number   := l_object_version_number;
  p_resource_booking_id := l_resource_booking_id ;


  open get_trainer_id;
  fetch get_trainer_id into l_person_id;
  close get_trainer_id;

  if l_person_id is not null and p_event_id is not null then
  -- call to instructor notification process not for independent resources
  OTA_INITIALIZATION_WF.initialize_instructor_wf(
            p_item_type 	=> 'OTWF',
            p_eventid => p_event_id,
            p_sup_res_id  => p_supplied_resource_id,
            p_start_date => p_required_date_from,
            p_end_date => p_required_date_to,
            p_start_time => p_required_start_time,
            p_end_time => p_required_end_time,
            p_status => p_status,
            p_res_book_id => p_resource_booking_id,
            p_person_id => l_person_id,
            p_event_fired => 'INSTRUCTOR_BOOK');

    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_resource_booking;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_resource_booking;
    p_object_version_number :=  null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_resource_booking ;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_resource_booking >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_resource_booking
  (p_effective_date                 in     date
  ,p_supplied_resource_id           in     number
  ,p_date_booking_placed            in     date
  ,p_status                         in     varchar2
  ,p_event_id                       in     number   default hr_api.g_number
  ,p_absolute_price                 in     number   default hr_api.g_number
  ,p_booking_person_id              in     number   default hr_api.g_number
  ,p_comments                       in     varchar2 default hr_api.g_varchar2
  ,p_contact_name                   in     varchar2 default hr_api.g_varchar2
  ,p_contact_phone_number           in     varchar2 default hr_api.g_varchar2
  ,p_delegates_per_unit             in     number   default hr_api.g_number
  ,p_quantity                       in     number   default hr_api.g_number
  ,p_required_date_from             in     date     default hr_api.g_date
  ,p_required_date_to               in     date     default hr_api.g_date
  ,p_required_end_time              in     varchar2 default hr_api.g_varchar2
  ,p_required_start_time            in     varchar2 default hr_api.g_varchar2
  ,p_deliver_to                     in     varchar2 default hr_api.g_varchar2
  ,p_primary_venue_flag             in     varchar2 default hr_api.g_varchar2
  ,p_role_to_play                   in     varchar2 default hr_api.g_varchar2
  ,p_trb_information_category       in     varchar2 default hr_api.g_varchar2
  ,p_trb_information1               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information2               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information3               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information4               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information5               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information6               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information7               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information8               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information9               in     varchar2 default hr_api.g_varchar2
  ,p_trb_information10              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information11              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information12              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information13              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information14              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information15              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information16              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information17              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information18              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information19              in     varchar2 default hr_api.g_varchar2
  ,p_trb_information20              in     varchar2 default hr_api.g_varchar2
  ,p_display_to_learner_flag      in     varchar2  default hr_api.g_varchar2
  ,p_book_entire_period_flag    in     varchar2  default hr_api.g_varchar2
 -- ,p_unbook_request_flag    in     varchar2  default hr_api.g_varchar2
  ,p_chat_id                        in     number   default hr_api.g_number
  ,p_forum_id                       in     number   default hr_api.g_number
  ,p_validate                       in  boolean
  ,p_resource_booking_id            in  number
  ,p_object_version_number          in out nocopy number
  ,p_timezone_code                  IN VARCHAR2    DEFAULT hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' update_resource_booking ';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;
  l_person_id per_people_f.person_id%type;

  cursor get_res_info
  is
  select orb.status,orb.event_id,orb.required_date_from
  from ota_resource_bookings orb
  where resource_booking_id = p_resource_booking_id;

  cursor get_trainer_id is
select osr.trainer_id from ota_suppliable_resources osr
where
osr.resource_type ='T'
and osr.supplied_resource_id = p_supplied_resource_id;


  l_status varchar2(30);
l_event_id ota_events.event_id%type;
l_date_from date;
l_start_date_changed boolean;

l_notify_days_before number(9) := fnd_profile.value('OTA_INST_REMIND_NTF_DAYS');

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_resource_booking ;

  --get the values req for ntf process

  open get_res_info;
  fetch get_res_info into
  l_status,l_event_id,l_date_from;
  close get_res_info;

  open get_trainer_id;
  fetch get_trainer_id into l_person_id;
  close get_trainer_id;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --

  -- Call Before Process User Hook
  --
  begin
  ota_resource_booking_bk2.update_resource_booking_b (
  p_effective_date               => l_effective_date      ,
  p_resource_booking_id          => p_resource_booking_id ,
  p_object_version_number        => l_object_version_number,
  p_supplied_resource_id         => p_supplied_resource_id ,
  p_date_booking_placed          => p_date_booking_placed ,
  p_status                       => p_status              ,
  p_event_id                     => p_event_id            ,
  p_absolute_price               => p_absolute_price      ,
  p_booking_person_id            => p_booking_person_id   ,
  p_comments                     => p_comments            ,
  p_contact_name                 => p_contact_name        ,
  p_contact_phone_number         => p_contact_phone_number,
  p_delegates_per_unit           => p_delegates_per_unit   ,
  p_quantity                     => p_quantity            ,
  p_required_date_from           => p_required_date_from  ,
  p_required_date_to             => p_required_date_to    ,
  p_required_end_time            => p_required_end_time   ,
  p_required_start_time          => p_required_start_time ,
  p_deliver_to                   => p_deliver_to          ,
  p_primary_venue_flag           => p_primary_venue_flag  ,
  p_role_to_play                 => p_role_to_play        ,
  p_trb_information_category     => p_trb_information_category    ,
  p_trb_information1             => p_trb_information1            ,
  p_trb_information2             => p_trb_information2            ,
  p_trb_information3             => p_trb_information3            ,
  p_trb_information4             => p_trb_information4            ,
  p_trb_information5             => p_trb_information5            ,
  p_trb_information6             => p_trb_information6            ,
  p_trb_information7             => p_trb_information7            ,
  p_trb_information8             => p_trb_information8            ,
  p_trb_information9             => p_trb_information9            ,
  p_trb_information10            => p_trb_information10            ,
  p_trb_information11            => p_trb_information11            ,
  p_trb_information12            => p_trb_information12            ,
  p_trb_information13            => p_trb_information13           ,
  p_trb_information14            => p_trb_information14            ,
  p_trb_information15            => p_trb_information15            ,
  p_trb_information16            => p_trb_information16            ,
  p_trb_information17            => p_trb_information17            ,
  p_trb_information18            => p_trb_information18            ,
  p_trb_information19            => p_trb_information19            ,
  p_trb_information20            => p_trb_information20
  ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_book_entire_period_flag    => p_book_entire_period_flag
 --   ,p_unbook_request_flag    => p_unbook_request_flag
  ,p_chat_id                     => p_chat_id
  ,p_forum_id                    => p_forum_id
  ,p_timezone_code               => p_timezone_code
 );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_resource_booking'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_trb_upd.upd (
  p_effective_date               => l_effective_date      ,
  p_resource_booking_id          => p_resource_booking_id ,
  p_object_version_number        => l_object_version_number,
  p_supplied_resource_id         => p_supplied_resource_id ,
  p_date_booking_placed          => p_date_booking_placed ,
  p_status                       => p_status              ,
  p_event_id                     => p_event_id            ,
  p_absolute_price               => p_absolute_price      ,
  p_booking_person_id            => p_booking_person_id   ,
  p_comments                     => p_comments            ,
  p_contact_name                 => p_contact_name        ,
  p_contact_phone_number         => p_contact_phone_number,
  p_delegates_per_unit           => p_delegates_per_unit   ,
  p_quantity                     => p_quantity            ,
  p_required_date_from           => p_required_date_from  ,
  p_required_date_to             => p_required_date_to    ,
  p_required_end_time            => p_required_end_time   ,
  p_required_start_time          => p_required_start_time ,
  p_deliver_to                   => p_deliver_to          ,
  p_primary_venue_flag           => p_primary_venue_flag  ,
  p_role_to_play                 => p_role_to_play        ,
  p_trb_information_category     => p_trb_information_category    ,
  p_trb_information1             => p_trb_information1            ,
  p_trb_information2             => p_trb_information2            ,
  p_trb_information3             => p_trb_information3            ,
  p_trb_information4             => p_trb_information4            ,
  p_trb_information5             => p_trb_information5            ,
  p_trb_information6             => p_trb_information6            ,
  p_trb_information7             => p_trb_information7            ,
  p_trb_information8             => p_trb_information8            ,
  p_trb_information9             => p_trb_information9            ,
  p_trb_information10            => p_trb_information10           ,
  p_trb_information11            => p_trb_information11           ,
  p_trb_information12            => p_trb_information12           ,
  p_trb_information13            => p_trb_information13           ,
  p_trb_information14            => p_trb_information14           ,
  p_trb_information15            => p_trb_information15           ,
  p_trb_information16            => p_trb_information16           ,
  p_trb_information17            => p_trb_information17           ,
  p_trb_information18            => p_trb_information18           ,
  p_trb_information19            => p_trb_information19           ,
  p_trb_information20            => p_trb_information20
  ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_book_entire_period_flag    => p_book_entire_period_flag
  --  ,p_unbook_request_flag    => p_unbook_request_flag
  ,p_chat_id                     => p_chat_id
  ,p_forum_id                    => p_forum_id
  ,p_timezone_code               => p_timezone_code
  );

  --
  -- Call After Process User Hook
  --
  begin
  OTA_resource_booking_bk2.update_resource_booking_a (
  p_effective_date               => l_effective_date      ,
  p_resource_booking_id          => p_resource_booking_id ,
  p_object_version_number        => l_object_version_number,
  p_supplied_resource_id         => p_supplied_resource_id ,
  p_date_booking_placed          => p_date_booking_placed ,
  p_status                       => p_status              ,
  p_event_id                     => p_event_id            ,
  p_absolute_price               => p_absolute_price      ,
  p_booking_person_id            => p_booking_person_id   ,
  p_comments                     => p_comments            ,
  p_contact_name                 => p_contact_name        ,
  p_contact_phone_number         => p_contact_phone_number,
  p_delegates_per_unit           => p_delegates_per_unit   ,
  p_quantity                     => p_quantity            ,
  p_required_date_from           => p_required_date_from  ,
  p_required_date_to             => p_required_date_to    ,
  p_required_end_time            => p_required_end_time   ,
  p_required_start_time          => p_required_start_time ,
  p_deliver_to                   => p_deliver_to          ,
  p_primary_venue_flag           => p_primary_venue_flag  ,
  p_role_to_play                 => p_role_to_play        ,
  p_trb_information_category     => p_trb_information_category    ,
  p_trb_information1             => p_trb_information1            ,
  p_trb_information2             => p_trb_information2            ,
  p_trb_information3             => p_trb_information3            ,
  p_trb_information4             => p_trb_information4            ,
  p_trb_information5             => p_trb_information5            ,
  p_trb_information6             => p_trb_information6            ,
  p_trb_information7             => p_trb_information7            ,
  p_trb_information8             => p_trb_information8            ,
  p_trb_information9             => p_trb_information9            ,
  p_trb_information10            => p_trb_information10           ,
  p_trb_information11            => p_trb_information11           ,
  p_trb_information12            => p_trb_information12           ,
  p_trb_information13            => p_trb_information13           ,
  p_trb_information14            => p_trb_information14           ,
  p_trb_information15            => p_trb_information15           ,
  p_trb_information16            => p_trb_information16           ,
  p_trb_information17            => p_trb_information17           ,
  p_trb_information18            => p_trb_information18           ,
  p_trb_information19            => p_trb_information19           ,
  p_trb_information20            => p_trb_information20
  ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_book_entire_period_flag    => p_book_entire_period_flag
   -- ,p_unbook_request_flag    => p_unbook_request_flag
 ,p_chat_id                     => p_chat_id
 ,p_forum_id                    => p_forum_id
 ,p_timezone_code               => p_timezone_code
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_resource_booking'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;

    if l_person_id is not null and l_event_id is not null and l_status <> p_status and p_status= 'C'then
  -- call to instructor notification process on status change to confirmation
  OTA_INITIALIZATION_WF.initialize_instructor_wf(
            p_item_type 	=> 'OTWF',
            p_eventid => l_event_id,
            p_res_book_id => p_resource_booking_id,
            p_status => p_status,
            p_event_fired => 'INST_BOOK_CONFIRM');

   end if;

    -- Fire reminder notification to instructor on booking date change

   l_start_date_changed
  := ota_general.value_changed(l_date_from,
			       p_required_date_from);

   if l_person_id is not null and l_event_id is not null
   and l_start_date_changed and l_date_from > trunc(sysdate)
   and p_required_date_from <= (trunc(sysdate) + l_notify_days_before)
   and (l_status = 'C' or p_status= 'C')
   then

	if (ota_utility.is_con_prog_periodic('OTINSTRNTF')) then
   	OTA_INITIALIZATION_WF.initialize_instructor_wf(
            p_item_type 	=> 'OTWF',
            p_eventid => l_event_id,
            p_res_book_id => p_resource_booking_id,
            p_event_fired => 'INSTRUCTOR_REMIND');

  	 end if;

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_resource_booking ;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_resource_booking ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    p_object_version_number := l_object_version_number;
    raise;
end update_resource_booking ;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_resource_booking >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_resource_booking
 (
  p_resource_booking_id                in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' delete_resource_booking ';

  cursor get_res_info
  is
  select orb.required_date_From,orb.required_date_to,
  orb.required_start_time,orb.required_end_time,
  orb.status,orb.supplied_resource_id,orb.event_id
  from ota_resource_bookings orb
  where resource_booking_id = p_resource_booking_id;

  cursor get_trainer_id (crs_sup_res_id number)is
select osr.trainer_id from ota_suppliable_resources osr
where
osr.resource_type ='T'
and osr.supplied_resource_id = crs_sup_res_id;

l_start_date varchar2(100);
l_end_date varchar2(100);
l_start_time ota_events.course_start_time%type;
l_end_time ota_events.course_start_time%type;
l_status varchar2(30);
l_event_id ota_events.event_id%type;
l_sup_res_id ota_resource_bookings.supplied_resource_id%type;
l_person_id per_people_f.person_id%type;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_resource_booking ;

  --get the values req for ntf process

  open get_res_info;
  fetch get_res_info into l_start_date,l_end_date,l_start_time,l_end_time,
  l_status,l_sup_res_id,l_event_id;
  close get_res_info;

  open get_trainer_id (l_sup_res_id);
  fetch get_trainer_id into l_person_id;
  close get_trainer_id;
  --
  -- Call Before Process User Hook
  --
  begin
    OTA_resource_booking_bk3.delete_resource_booking_b
    (p_resource_booking_id    => p_resource_booking_id ,
     p_object_version_number  => p_object_version_number,
     p_validate               => p_validate);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_resource_booking'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  OTA_trb_del.del
   (p_resource_booking_id     => p_resource_booking_id ,
     p_object_version_number  => p_object_version_number
   ) ;
  --
  -- Call After Process User Hook
  --
  begin
  OTA_resource_booking_bk3.delete_resource_booking_a
    (p_resource_booking_id    => p_resource_booking_id ,
     p_object_version_number  => p_object_version_number,
     p_validate               => p_validate);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_resource_booking'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
   -- Set all output arguments
   if l_person_id is not null and l_event_id is not null then

    hr_utility.trace ('before wf ' ||20);
  -- call to instructor notification process
  OTA_INITIALIZATION_WF.initialize_instructor_wf(
            p_item_type 	=> 'OTWF',
            p_eventid => l_event_id,
            p_sup_res_id  => l_sup_res_id,
            p_start_date => l_start_date,
            p_end_date => l_end_date,
            p_start_time => l_start_time,
            p_end_time => l_end_time,
            p_status => l_status,
            p_person_id => l_person_id,
            p_event_fired => 'INSTRUCTOR_CANCEL');
         hr_utility.trace ('after wf ' ||20);

   end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_resource_booking ;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_resource_booking ;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_resource_booking;
--
end ota_resource_booking_api;

/
