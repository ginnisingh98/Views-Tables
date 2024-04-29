--------------------------------------------------------
--  DDL for Package Body OTA_OM_TDB_WAITLIST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OM_TDB_WAITLIST_API" as
/* $Header: ottomint.pkb 120.43.12010000.13 2009/08/31 13:50:06 smahanka ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_OM_TDB_WAITLIST_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< AUTO_ENROLL_FROM_WAITLIST >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
-- p_validate
-- p_business_group_id
-- p_event_id
--
-- Out Parameters
-- p_return_status
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure AUTO_ENROLL_FROM_WAITLIST
  (p_validate                      in     boolean
--Remove default for gscc warning  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_event_id                      in     number
-- remove default for gscc warning ,p_event_id                      in     number   default null
  ,p_return_status           out nocopy    varchar2
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
    date_booking_placed        date,
    internal_booking_flag     varchar2(1)  );

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

  cursor   c_max_internal is
    select maximum_internal_attendees
    from   ota_events
    where  event_id = p_event_id;

  cursor   c_places_taken (p_booking_id in number) is
    select sum(a.number_of_places)
    from   ota_delegate_bookings a,
           ota_booking_status_types b
    where  a.event_id = p_event_id
    and    a.booking_status_type_id = b.booking_status_type_id
    and    b.type in ('P','A')
    and    a.internal_booking_flag = 'Y'
    and    a.booking_id <> nvl(p_booking_id, hr_api.g_number);


  l_proc                varchar2(72) := g_package||'AUTO_ENROLL_FROM_WAITLIST';
  l_count               number(9) := 1;
  l_vacancies           number(10);
  l_status_type_id      ota_delegate_bookings.booking_status_type_id%type;
  l_dummy               boolean;
  l_return_status       varchar2(1) := 'T';
  l_warn                boolean := False;
  l_booking_ovn         number;
  l_finance_ovn         number;
  l_finance_line_id     number;
  l_error_num             VARCHAR2(30) := '';
  l_error_msg             VARCHAR2(1000) := '';

  l_max_internal     number;
  l_number_taken     number;
  l_enroll           varchar2(1);

l_waitlist_entry  c_priority_waitlist%rowtype;
   e_validation_error exception;
  pragma exception_init(e_validation_error, -20002);

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  p_return_status := 'T';
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
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||
      ','||'No Default booking status is found');

    RAISE e_validation_error ;
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
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Auto waitlist processing, Waitlist Sort Criteria :' ||
                        fnd_profile.value('OTA_WAITLIST_SORT_CRITERIA') );
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
        t_waitlist_table(l_count).internal_booking_flag := l_waitlist_entry.internal_booking_flag;



      l_count := l_count+1;
      --
      end loop;
      --
    else
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Auto waitlist processing, For other Waitlist Sort Criteria');
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
         t_waitlist_table(l_count).internal_booking_flag := l_waitlist_entry.internal_booking_flag;
        l_count := l_count+1;
      --
      end loop;
    --
    end if;



  --  for i in t_waitlist_table.first..t_waitlist_table.last loop
   for i in 1..t_waitlist_table.COUNT loop

    --

      l_vacancies := ota_evt_bus2.get_vacancies(p_event_id);

      if nvl(l_vacancies,0) <= 0 then
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


        /*  ota_utility.other_bookings_clash(to_char(t_waitlist_table(i).delegate_person_id),
                                                       to_char(t_waitlist_table(i).delegate_contact_id),
                                                       p_event_id,
                                                       l_status_type_id,
                                                       l_dummy,
                                                       l_warn);
      */
        if t_waitlist_table(i).delegate_person_id is not null or
         t_waitlist_table(i).delegate_contact_id is not null then
               l_warn := ota_tdb_bus2.other_bookings_clash(to_char(t_waitlist_table(i).delegate_person_id),
                                           to_char(t_waitlist_table(i).delegate_contact_id),
                                           p_event_id,
                                           l_status_type_id);

          end if;
        if l_warn = True then
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_proc||':'||
           to_char(t_waitlist_table(i).booking_id)||','||'Cannot book the person onto the event as they are
                              already booked onto another event on the same day.');


            hr_utility.set_location('NEW STATUS = '||to_char(l_status_type_id), 42);
            else

            l_booking_ovn  :=   t_waitlist_table(i).object_version_number ;
            l_finance_ovn  :=   t_waitlist_table(i).tfl_object_version_number;
            l_finance_line_id :=  t_waitlist_table(i).finance_line_id;

    /* Start Bug 1720734 */
            l_enroll := 'Y';
            if  t_waitlist_table(i).internal_booking_flag = 'Y' then

               open c_max_internal;
            --
               fetch c_max_internal into l_max_internal;
            --
         close c_max_internal;
         --
          -- If max internal is null then we can enroll freely without worrying
          -- about limits on the event.
          --
          if l_max_internal is not null then
           --
           -- Check how many places we want to allocate are available as
           -- internal places.
              --
                    open c_places_taken(t_waitlist_table(i).booking_id);
               --
               fetch c_places_taken into l_number_taken;
               --
               close c_places_taken;

               if l_number_taken is null then
                  l_number_taken := 0;
                  end if;

                --
                -- Check if number of places available is exceeded by number required
                --
                if t_waitlist_table(i).number_of_places > (l_max_internal - l_number_taken) then
                            FND_FILE.PUT_LINE(FND_FILE.LOG,l_proc||' '||
               'Booking Id :'||t_waitlist_table(i).booking_id||','||
               'The maximum number of internal delegates for this event has been exceed by this booking. '||
                              'Either reduce the number of places for the booking or increase the maximum amount of '||
                              'internal delegates for the event.');
                            l_enroll := 'N';
                         end if;
                   end if;
            end if;
            /* End Bug 1720734 */

           if l_enroll = 'Y' then
            ota_tdb_shd.lck(t_waitlist_table(i).booking_id ,l_booking_ovn);
    --

            FND_FILE.PUT_LINE(FND_FILE.LOG,'Move Booking id :'||t_waitlist_table(i).booking_id ||
                              '.. From waitlist..');
             ota_tdb_api_upd2.update_enrollment(
                      p_booking_id                => t_waitlist_table(i).booking_id
                     ,p_object_version_number     => l_booking_ovn
                     ,p_tfl_object_version_number => l_finance_ovn
                     ,p_event_id                  => p_event_id
                     ,p_finance_line_id           => l_finance_line_id
                     ,p_booking_status_type_id    => l_status_type_id
                  ,p_number_of_places        => t_waitlist_table(i).number_of_places
                     ,p_date_status_changed       => sysdate   -- Added for bug# 1708632
                     ,p_date_booking_placed       => t_waitlist_table(i).date_booking_placed  -- Added for bug# 1708632
           ,p_status_change_comments    => null); /* Bug# 3469326 */


           end if;
       end if;
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
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||
      to_char(t_waitlist_table(i).booking_id)||','||'Error found when try to move a student from waitlisted');

            p_return_status := 'F';
          --
      return;

        when others then
    --
    -- A validation or unexpected error has occured
    --
       --rollback to AUTO_ENROLL_FROM_WAITLIST;
       hr_utility.set_location(' Leaving:'||l_proc, 80);
       p_return_status := 'F';
       l_error_num := SQLCODE;
       l_error_msg := SUBSTR(SQLERRM, 1, 300);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc||' '||
               'Booking Id :'||t_waitlist_table(i).booking_id||','||
               l_error_num||':'||l_error_msg);
          --
     -- FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception other error:');

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
 --   rollback to AUTO_ENROLL_FROM_WAITLIST;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to AUTO_ENROLL_FROM_WAITLIST;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    p_return_status := 'F';
    raise;
end AUTO_ENROLL_FROM_WAITLIST;
--
end OTA_OM_TDB_WAITLIST_API;

/
