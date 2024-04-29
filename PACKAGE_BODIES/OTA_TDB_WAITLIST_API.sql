--------------------------------------------------------
--  DDL for Package Body OTA_TDB_WAITLIST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TDB_WAITLIST_API" as
/* $Header: ottdb03t.pkb 120.0 2005/05/29 07:38:15 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_TDB_WAITLIST_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< AUTO_ENROLL_FROM_WAITLIST >-------------------|
-- ----------------------------------------------------------------------------
--
procedure AUTO_ENROLL_FROM_WAITLIST
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_event_id                      in     number   default null
  ) is

  --
  -- Declare cursors and local variables
  --
  type r_rec is record (
    booking_id                number,
    delegate_person_id        number,
    delegate_contact_id       number,
    number_of_places          number,
    object_version_number     number,
    finance_line_id           number,
    tfl_object_version_number number,
    date_booking_placed        date
  );

  type t_table is table of r_rec index by binary_integer;

  t_waitlist_table t_table;

  cursor c_date_waitlist is
  select tdb.booking_id,
         tdb.delegate_person_id,
         tdb.delegate_contact_id,
         tdb.number_of_places,
         tdb.object_version_number,
         tfl.finance_line_id,
         tfl.object_version_number tfl_object_version_number,
         tdb.date_booking_placed  ,
         tdb.internal_booking_flag
  from ota_delegate_bookings tdb,
       ota_booking_status_types bst,
       ota_finance_lines tfl
  where  tfl.booking_id(+) = tdb.booking_id
  and tdb.booking_status_type_id = bst.booking_status_type_id
  and bst.type = 'W'
  and tdb.event_id = p_event_id
  order by tdb.date_booking_placed;

 cursor c_priority_waitlist is
  select tdb.booking_id,
         tdb.delegate_person_id,
         tdb.delegate_contact_id,
         tdb.number_of_places,
         tdb.object_version_number,
         tfl.finance_line_id,
         tfl.object_version_number tfl_object_version_number,
         tdb.date_booking_placed ,
         tdb.internal_booking_flag
  from ota_delegate_bookings tdb,
       ota_booking_status_types bst,
       ota_finance_lines tfl
  where  tfl.booking_id(+)= tdb.booking_id
  and tdb.booking_status_type_id = bst.booking_status_type_id
  and bst.type = 'W'
  and tdb.event_id = p_event_id
  order by tdb.booking_priority,
           tdb.booking_id;

  l_proc                varchar2(72) := g_package||'AUTO_ENROLL_FROM_WAITLIST';
  l_count               number := 0;
  l_vacancies           number;
  l_status_type_id      number;
  l_dummy               boolean;

  e_validation_error exception;
  pragma exception_init(e_validation_error, -20001);

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint
  --
  savepoint AUTO_ENROLL_FROM_WAITLIST;
  hr_utility.set_location(l_proc, 20);

  --
  -- Call Before Process User Hook
  --
  begin
    OTA_TDB_WAITLIST_BK1.AUTO_ENROLL_FROM_WAITLIST_B
      (p_business_group_id             => p_business_group_id
      ,p_event_id                      => p_event_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'AUTO_ENROLL_FROM_WAITLIST'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --



  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --

  l_status_type_id := fnd_profile.value('OTA_AUTO_WAITLIST_BOOKING_STATUS');

  if l_status_type_id is null then
  --
    --
    -- As we don't know what status to set the waitlistees to, we can't continue.
    -- Because of previous checks, this condition should never occur, so we don't take
    -- any further action here.

    null;
  --
  else
  --
    --
    -- Build a representation of the waitlist, correctly ordered, in a table.
    -- This will save on coding, as we will only require one loop to go
    -- through the waitlist.
    --

    if fnd_profile.value('OTA_WAITLIST_SORT_CRITERIA') = 'BP' then
    --
      for l_waitlist_entry in c_priority_waitlist loop
      --
        t_waitlist_table(l_count).number_of_places := l_waitlist_entry.number_of_places;
        t_waitlist_table(l_count).booking_id := l_waitlist_entry.booking_id;
        t_waitlist_table(l_count).delegate_person_id := l_waitlist_entry.delegate_person_id;
        t_waitlist_table(l_count).delegate_contact_id := l_waitlist_entry.delegate_contact_id;
        t_waitlist_table(l_count).object_version_number := l_waitlist_entry.object_version_number;
        t_waitlist_table(l_count).finance_line_id := l_waitlist_entry.finance_line_id;
        t_waitlist_table(l_count).tfl_object_version_number := l_waitlist_entry.tfl_object_version_number;
        t_waitlist_table(l_count).date_booking_placed := l_waitlist_entry.date_booking_placed;


        l_count := l_count+1;
      --
      end loop;
    --
    else
    --
      for l_waitlist_entry in c_date_waitlist loop
      --
        t_waitlist_table(l_count).number_of_places := l_waitlist_entry.number_of_places;
        t_waitlist_table(l_count).booking_id := l_waitlist_entry.booking_id;
        t_waitlist_table(l_count).delegate_person_id := l_waitlist_entry.delegate_person_id;
        t_waitlist_table(l_count).delegate_contact_id := l_waitlist_entry.delegate_contact_id;
        t_waitlist_table(l_count).object_version_number := l_waitlist_entry.object_version_number;
        t_waitlist_table(l_count).finance_line_id := l_waitlist_entry.finance_line_id;
        t_waitlist_table(l_count).tfl_object_version_number := l_waitlist_entry.tfl_object_version_number;
        t_waitlist_table(l_count).date_booking_placed := l_waitlist_entry.date_booking_placed;


        l_count := l_count+1;
      --
      end loop;
    --
    end if;

    for i in t_waitlist_table.first..t_waitlist_table.last loop
    --
      l_vacancies := ota_evt_bus2.get_vacancies(p_event_id);

      if l_vacancies <= 0 then
      --
        exit;
      --
      end if;

      if t_waitlist_table(i).number_of_places <= l_vacancies or
         l_vacancies is null then
      --
hr_utility.set_location('UPDATING DETAILS FOR BOOKING #'||to_char(t_waitlist_table(i).booking_id), 41);
        begin
        --
          l_dummy := ota_tdb_bus2.other_bookings_clash(to_char(t_waitlist_table(i).delegate_person_id),
                                                       to_char(t_waitlist_table(i).delegate_contact_id),
                                                       p_event_id,
                                                       l_status_type_id);

hr_utility.set_location('NEW STATUS = '||to_char(l_status_type_id), 42);

          ota_tdb_api_upd2.update_enrollment(
            p_booking_id                => t_waitlist_table(i).booking_id
           ,p_object_version_number     => t_waitlist_table(i).object_version_number
           ,p_tfl_object_version_number => t_waitlist_table(i).tfl_object_version_number
           ,p_event_id                  => p_event_id
           ,p_finance_line_id           => t_waitlist_table(i).finance_line_id
           ,p_number_of_places          => t_waitlist_table(i).number_of_places
           ,p_date_status_changed       => sysdate    -- bug 1890732
           ,p_booking_status_type_id    => l_status_type_id
           ,p_date_booking_placed        => t_waitlist_table(i).date_booking_placed);


        --
        exception
        when e_validation_error then
          hr_utility.set_location('ENROLLMENT ERROR BEING HANDLED', 49);

          --
          -- This exception handler is executed following any application
          -- error encountered when attempting to enroll a delegate from
          -- the waitlist. (e.g. a double booking was found)
          --
          -- If code is to be added at a later stage to handle notifications
          -- of these errors, this would be the best place to call the code from.
          -- At present, there are no notifications, so we take no action,
          -- other than to proceed onto the next waitlisted booking.
          --

          NULL;
        --
        end;
      --
      end if;
    --
    end loop;
  --
  end if;


  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    OTA_TDB_WAITLIST_BK1.AUTO_ENROLL_FROM_WAITLIST_A
      (p_business_group_id             => p_business_group_id
      ,p_event_id                      => p_event_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'AUTO_ENROLL_FROM_WAITLIST'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to AUTO_ENROLL_FROM_WAITLIST;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to AUTO_ENROLL_FROM_WAITLIST;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end AUTO_ENROLL_FROM_WAITLIST;
--
end OTA_TDB_WAITLIST_API;

/
