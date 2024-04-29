--------------------------------------------------------
--  DDL for Package Body OTA_TDB_BUS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TDB_BUS2" as
/* $Header: ottdb01t.pkb 120.26.12010000.3 2009/10/12 06:51:15 smahanka ship $ */
g_package  varchar2(33) := '  ota_tdb_bus2.';  -- Global package name
--
--***************************** STARTS HERE **********************************
--
g_event_rec             ota_evt_shd.g_rec_type;
--
--
-- Global package name
--
-- global constants
--
-- Booking Status Types
--
g_wait_list_booking     varchar2(1)     := 'W';
g_placed_booking        varchar2(1)     := 'P';
g_attended_booking      varchar2(1)     := 'A';
g_cancelled_booking     varchar2(1)     := 'C';
g_requested_booking     varchar2(1)     := 'R';
--
-- Event Statuses
--
g_full_event            varchar2(1)     := 'W';
g_normal_event          varchar2(1)     := 'N';
g_planned_event         varchar2(1)     := 'P';
g_closed_event          varchar2(1)     := 'C';
-- ----------------------------------------------------------------------------
-- |-------------------------< check_person_address >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Person Address
--
--              Checks that the given person is registered at the given address
--
Procedure check_person_address (p_person_id           in number,
                                p_address_id          in number,
                                p_delegate_or_contact in varchar2) is
--
  -- Cursor to check that the person and address are associated
  --
  cursor c_address is
    select 'X'
    from per_addresses
    where person_id = p_person_id
      and address_id = p_address_id;
  --
  l_proc        varchar2(72) := 'OTA_TDB_BUS2 '||'check_person_address';
  l_dummy       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_person_id is not null and p_address_id is not null then
  --
    open c_address;
    fetch c_address into l_dummy;
    if c_address%notfound then
    --
      close c_address;
      --
      fnd_message.set_name ('OTA', 'OTA_13236_TDB_NO_PERSON_ADDR');
      fnd_message.set_token ('PERSON_TYPE', p_delegate_or_contact);
      fnd_message.raise_error;
    --
    end if;
    --
    close c_address;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_person_address;
-- ----------------------------------------------------------------------------
-- |-------------------------< other_bookings_clash >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Other Bookings Clash
--
--              Checks if the booking being made clashes with any other
--              bookings for the delegate
--              Note - bookings only clash if they are confirmed
--
Function other_bookings_clash (p_delegate_person_id     in varchar2,
                               p_delegate_contact_id    in varchar2,
                               p_event_id               in number,
                               p_booking_status_type_id in varchar2)
Return boolean is
--
  --
  -- cursor to select any confirmed bookings for events which
  -- clash with the event being booked
  --
  --Bug 5169354
  cursor c_other_person_bookings IS
  /*
       Modified for bug#5498011
       Convert ev dates into evt timezone and then compare
       Common cursor for both person as well as contact
  */
  Select type
  from
  (
   select  bst.TYPE
         ,ota_timezone_util.convert_date(ev.course_start_date, ev.course_start_time, ev.timezone, evt.timezone) ev_course_start_date
	 ,ota_timezone_util.convert_date(ev.course_end_date, nvl(ev.course_end_time,'23:59'), ev.timezone, evt.timezone) ev_course_end_date
	 ,evt.course_start_date evt_course_start_date
	 ,decode(evt.course_start_date, NULL, NULL, nvl(evt.course_start_time,'00:00')) evt_course_start_time
	 ,evt.course_end_date evt_course_end_date
	 ,decode(evt.course_end_date, NULL, NULL, nvl(evt.course_end_time,'23:59'))  evt_course_end_time
    from ota_delegate_bookings db,
         ota_booking_status_types bst,
         ota_events ev,
         ota_events evt
    where (   (p_delegate_contact_id IS NULL AND db.delegate_person_id = p_delegate_person_id
           OR (p_delegate_person_id IS NULL AND db.delegate_contact_id = p_delegate_contact_id)))
      and db.booking_status_type_id = bst.booking_status_type_id
      and bst.type <> g_cancelled_booking
      and db.event_id = ev.event_id
      and evt.event_id = p_event_id
      and ev.event_id <> p_event_id
      and ev.event_type <>'SELFPACED' -- Added for Bug 2241280
  )
  Where
          (
           ((trunc(ev_course_start_date) = trunc(ev_course_end_date) and
           evt_course_start_date = evt_course_end_date and
           trunc(ev_course_start_date) = evt_course_start_date) or
           (
           (trunc(ev_course_start_date) <> trunc(ev_course_end_date) or
           evt_course_start_date <> evt_course_end_date) and
           (trunc(ev_course_start_date) <= evt_course_end_date and
           trunc(ev_course_end_date) >= evt_course_start_date)
           ))
            AND
           (
           (((nvl(evt_course_start_time, '-99:99')
             >  nvl(to_char(ev_course_start_date,'HH24:MI'), '99:99') and
            nvl(evt_course_start_time, '-99:99') <
           nvl(to_char(ev_course_end_date,'HH24:MI'), '99:99'))) OR
           ((nvl(evt_course_end_time, '99:99')
             > nvl(to_char(ev_course_start_date,'HH24:MI'), '99:99') and
           nvl(evt_course_end_time, '99:99') <
            nvl(to_char(ev_course_end_date,'HH24:MI'), '99:99'))) OR
           ((nvl(to_char(ev_course_end_date,'HH24:MI'), '99:99') >
           nvl(evt_course_start_time, '-99:99') and
           nvl(to_char(ev_course_end_date,'HH24:MI'), '99:99') <
           nvl(evt_course_end_time, '-99:99'))) OR
          ((nvl(to_char(ev_course_start_date,'HH24:MI'), '99:99') >
           nvl(evt_course_start_time, '-99:99') and
           nvl(to_char(ev_course_start_date,'HH24:MI'), '99:99') <
           nvl(evt_course_end_time, '-99:99')))) OR
           ((nvl(evt_course_end_time, '-99:99') =
                      nvl(to_char(ev_course_end_date,'HH24:MI'), '-99:99') and
            nvl(evt_course_start_time, '-99:99') =
                      nvl(to_char(ev_course_start_date,'HH24:MI'), '-99:99')))
          )
          )
    order by type;
  --

  /* For Bug 2241280 */
  CURSOR csr_event_type
      IS
      SELECT evt.event_type
      FROM OTA_EVENTS evt
      WHERE evt.event_id= p_event_id;
  --
  l_proc           varchar2(72) := g_package||'other_bookings_clash';
  l_result         boolean;
  l_warn           boolean := false;
  l_booking_status varchar2(80);
  l_dummy          varchar2(80);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Modified for bug#5498011
  -- Common cursor for both person as well as contact
  For event in csr_event_type
    LOOP
    exit when csr_event_type%notfound;
    if event.event_type <>'SELFPACED' then
       open c_other_person_bookings;
       fetch c_other_person_bookings into l_dummy;
       l_result := c_other_person_bookings%found;
       close c_other_person_bookings;
    end if;
    END LOOP;
  --

  if l_result then
  --
    l_booking_status := ota_tdb_bus.booking_status_type(p_booking_status_type_id);

    if l_booking_status in (g_attended_booking, g_placed_booking) and
       l_dummy in (g_attended_booking, g_placed_booking) then
    --
     -- Professional UI requires only a warning message.
     --
      --fnd_message.set_name('OTA', 'OTA_13670_TDB_DOUBLE_BOOKING');
      --fnd_message.raise_error;
      l_warn := true;
    --
    else
    --
      if l_booking_status <> g_cancelled_booking then
      --
        l_warn := true;
      --
      end if;
    --
    end if;
  --
  end if;
  --
  return(l_warn);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End other_bookings_clash;
-- ----------------------------------------------------------------------------
-- |-------------------------< overdraft_exceeded >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Overdraft Exceeded
--
--              Checks if the overdraft is exceeded for a booking using a
--              pre-purchase agreement.
--
Function overdraft_exceeded (p_booking_deal_id in number,
                             p_money_amount    in number)
Return boolean is
  --
  -- cursor to check if pre-purchase agreement has an overdraft limit
  --
  cursor c1 is
    select nvl(overdraft_limit,0)
    from   ota_booking_deals
    where  booking_deal_id = p_booking_deal_id;
  --
  l_proc            varchar2(72) := g_package||'overdraft_exceeded';
  l_overdraft_limit number(9,2);
  l_balance         number(9,2) := ota_tbd_api.tfl_balance(p_booking_deal_id,
                                                           'M');
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- get overdraft limit.
  --
  open c1;
    --
    fetch c1 into l_overdraft_limit;
    --
  close c1;
  --
  hr_utility.set_location('Overdraft Limit '||l_overdraft_limit,10);
  hr_utility.set_location('Balance '||l_balance,10);
  --
  l_balance := l_balance + l_overdraft_limit;
  hr_utility.set_location('Balance '||l_balance,10);
  --
  if l_balance - p_money_amount < 0 then
    return true;
  else
    return false;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end overdraft_exceeded;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_person_visible >------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Check Person Visible
--
--              Checks that the specified person is visible on the given date
--
Procedure check_person_visible (p_person_id            in number,
                                p_date_booking_placed  in date,
                                p_person_type          in varchar2,
                                p_person_address_type in varchar2) is
--
  l_proc        varchar2(72) := g_package||'check_person_visible';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- only perform the check if the person is specified
  --
  if p_person_id is not null then
  --
    hr_utility.trace(p_person_type||' Person ID -> '||to_char(p_person_id));
    if not ota_tdb_bus.check_person (p_person_id,
                                      p_date_booking_placed,
                                      p_person_type,
                                      p_person_address_type) then
      --
      if p_person_address_type = 'INTERNAL' then
         fnd_message.set_name ('OTA', 'OTA_13202_GEN_INVALID_KEY');
         fnd_message.set_token ('TABLE_NAME', 'OTA_PEOPLE_V');
         fnd_message.set_token ('COLUMN_NAME', p_person_type||' Person');
         fnd_message.raise_error;
      elsif p_person_address_type = 'INTERNAL' then
         fnd_message.set_name ('OTA', 'OTA_13202_GEN_INVALID_KEY');
         fnd_message.set_token ('TABLE_NAME', 'OTA_CUST_CONTACTS_V');
         fnd_message.set_token ('COLUMN_NAME', p_person_type||' Person');
         fnd_message.raise_error;
      end if;
      --
    end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_person_visible;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_org_business_group >--------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description: Checks Organization business group information
--
--              Checks whether business group id for an internal enrollment is :
--                      the same as the organization_id
--                      the same as the delegate_person_id
--                      the same as the sponsor_person_id
--                      the same as the delegate_assignment_id
--                      the same as the sponsor_assignment_id
--
Procedure check_org_business_group (p_event_id               in number,
                                    p_business_group_id      in number,
                                    p_organization_id        in number,
                                    p_delegate_person_id     in number,
                                    p_sponsor_person_id      in number,
                                    p_delegate_assignment_id in number,
                                    p_sponsor_assignment_id  in number,
                                    p_date_booking_placed    in date) is
  l_proc         varchar2(72) := g_package||'check_org_business_group';
  l_dummy        varchar2(30);
  l_global_bg ota_delegate_bookings.business_group_id%type :=
                          FND_PROFILE.VALUE('OTA_HR_GLOBAL_BUSINESS_GROUP_ID');
  --
  --
  cursor c_person (l_person_id number) is
    select 1
    from   per_all_people_f
    where  person_id = l_person_id
    and    business_group_id = p_business_group_id;



  --
  cursor c_assignment (l_assignment_id number) is
    select 1
    from   per_assignments_f
    where  assignment_id = l_assignment_id
    and    business_group_id = p_business_group_id;


  --
  cursor c_organization is
    select 1
    from   hr_all_organization_units
    where  organization_id = p_organization_id
    and    business_group_id = p_business_group_id;

  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only perform validation checks if we are dealing with an
  -- internal enrollment, in other words organization id is not null
  --
  if p_organization_id is not null then
   if l_global_bg is null then

    --
    -- Check organization business group
    --
    open c_organization;
      fetch c_organization into l_dummy;
      if not c_organization%found then
        --
        -- This organization has a different business group
        --
        fnd_message.set_name ('OTA','OTA_13510_ORG_BUSINESS_GROUP');
        fnd_message.raise_error;
        --
      end if;
    close c_organization;
    --
    -- Check delegate business group
    --
    if p_delegate_person_id is not null then
      --
      -- Check delegate business group
      --
      open c_person(p_delegate_person_id);
        fetch c_person into l_dummy;
        if not c_person%found then
          --
          -- The delegate has adifferent business group
          --
          fnd_message.set_name ('OTA','OTA_13584_DEL_BUSINESS_GROUP');
          fnd_message.raise_error;
          --
        end if;
      close c_person;
      --
    end if;
    --
    -- Check sponsor business group
    --
    if p_sponsor_person_id is not null then
      --
      -- Check sponsor business group
      --
      open c_person(p_sponsor_person_id);
        fetch c_person into l_dummy;
        if not c_person%found then
          --
          -- The delegate has adifferent business group
          --
          fnd_message.set_name ('OTA','OTA_13585_CON_BUSINESS_GROUP');
          fnd_message.raise_error;
          --
        end if;
      close c_person;
      --
    end if;
    --
    -- Check delegate assignment
    --
    if p_delegate_assignment_id is not null then
      --
      -- Check delegate assignment business group
      --
      open c_assignment(p_delegate_assignment_id);
        fetch c_assignment into l_dummy;
        if not c_assignment%found then
          --
          -- The delegate assignment has a different business group
          --
          fnd_message.set_name ('OTA','OTA_13586_DEL_ASS_BUS_GROUP');
          fnd_message.raise_error;
          --
        end if;
      close c_assignment;
      --
    end if;
    --
    -- Check contact assignment
    --
    if p_sponsor_assignment_id is not null then
      --
      -- Check sponsor assignment business group
      --
      open c_assignment(p_sponsor_assignment_id);
        fetch c_assignment into l_dummy;
        if not c_assignment%found then
          --
          -- The sponsor assignment has a different business group
          --
          fnd_message.set_name ('OTA','OTA_13587_SPON_ASS_BUS_GROUP');
          fnd_message.raise_error;
          --
        end if;
      close c_assignment;
      --
    end if;
   end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_org_business_group;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_contact_address >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Contact Address Id related information
--
--              Checks whether contact address id is not null and that :
--              The address_id is valid for the customer
--
Procedure check_contact_address (p_contact_address_id  in number,
                                 p_customer_id         in number) is
--
  l_proc        varchar2(72) := g_package||'check_contact_address';
  l_dummy       varchar2(30);
  --
-- Bug#2063604 hdshah use ra_addresses_all instead of ra_addresses.
-- Bug#2652833 arkashya replaced cursor query to use HZ_ tables directly instead of ra_  views

cursor l_address is
    select 1
    from HZ_LOCATIONS loc,
         HZ_CUST_ACCT_SITES acct_site,
         HZ_PARTY_SITES party_site
     where PARTY_SITE.location_id = LOC.location_id
           and ACCT_SITE.party_site_id = PARTY_SITE.party_site_id
           and ACCT_SITE.CUST_ACCOUNT_ID = p_customer_id
           and ACCT_SITE.CUST_ACCT_SITE_ID  = p_contact_address_id
           AND DECODE(fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID'),
                  null, (NVL(ORG_ID , NVL(TO_NUMBER(DECODE(SUBSTRB( USERENV('CLIENT_INFO'),1,1),' ',
                            NULL, SUBSTRB( USERENV('CLIENT_INFO'),1,10))),
                            -99))), 1 ) =
               DECODE(fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID'),
                  null, (NVL(TO_NUMBER(DECODE(SUBSTRB( USERENV('CLIENT_INFO'),1,1),' ',
                            NULL,SUBSTRB(USERENV( 'CLIENT_INFO'),1,10))),
                            -99)),1 );




 --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only perform validation checks if we are dealing with an
  -- external enrollment, in other words customer id is not null
  --
  if p_customer_id is not null and
     p_contact_address_id is not null then
     --
     -- Check if address exists for customer
     --
     open l_address;
       fetch l_address into l_dummy;
       if not l_address%found then
         --
         -- Not a valid address for this customer
         --
         fnd_message.set_name ('OTA','OTA_13509_CONTACT_ADDRESS_INV');
         fnd_message.raise_error;
         --
       end if;
     close l_address;
     --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_contact_address;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_organization_details >------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Organization Id related information
--
--              Checks whether organization id is not null and whether :
--              if sponsor_person_id is not null then
--                      sponsor_assignment_id must be not null
--              if delegate_person_id is not null then
--                      delegate_assignment_id must be not null
--
Procedure check_organization_details(p_organization_id        in number,
                                     p_delegate_person_id     in number,
                                     p_delegate_assignment_id in number,
                                     p_sponsor_person_id      in number,
                                     p_sponsor_assignment_id  in number) is
--
  l_proc        varchar2(72) := g_package||'check_organization_details';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only perform validation checks if we are dealing with an
  -- internal enrollment, in other words organization id is not null
  --
  if p_organization_id is not null then
    --
    if p_sponsor_person_id is not null and
       p_sponsor_assignment_id is null then
       --
       -- Display error message as this should not occur
       -- in this case p_sponsor_assignment_id is mandatory
       --
      fnd_message.set_name ('OTA','OTA_13503_SPONSOR_ASSIGNMENT');
      fnd_message.raise_error;
    end if;
    --
    if p_delegate_person_id is not null and
       p_delegate_assignment_id is null then
       --
       -- Display error message as this should not occur
       -- in this case p_delegate_assignment_id is mandatory
       --
       fnd_message.set_name ('OTA','OTA_13502_DELEGATE_ASSIGNMENT');
       fnd_message.raise_error;
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_organization_details;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_enrollment_type >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Check Enrollment Type
--
--              Checks that the enrollment type is valid for the event type
--
Procedure check_enrollment_type(p_event_id            in number,
                                p_person_id           in number,
                                p_enrollment_type     in varchar2,
                                p_booking_id          in number) is
--
  l_proc        varchar2(72) := g_package||'oheck_enrollment_type';
  l_event_type  ota_events.price_basis%type;
  cursor c1 is
    select price_basis
    from ota_events
    where event_id = p_event_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('Event Id:'||to_char(p_event_id),5);
  --
  -- only perform the check if the person is specified
  --
  open c1;
    fetch c1 into l_event_type;
  close c1;
  if l_event_type = 'C' then
  --
    if p_enrollment_type = 'S' then
      if (p_person_id is not null) and
         (ota_tdb_shd.g_old_rec.delegate_contact_id is null) and
         (p_booking_id is not null) then
         fnd_message.set_name ('OTA','OTA_13485_DELEGATE_MUST_NULL');
         fnd_message.raise_error;
      end if;
      if p_person_id is null then
        --
        fnd_message.set_name ('OTA', 'OTA_13484_DELEGATE_NULL');
        fnd_message.raise_error;
        --
      end if;
    end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_enrollment_type;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_spon_del_validity >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check whether delegate and sponsor are valid at the time
--              of the enrollment and at the time when the event started.
--              They must exist as employees around the time periods above.
--
--              Checks whether organization id is not null and whether :
--              if sponsor_person_id is not null then
--                      sponsor_person_id must exist on
--                      the day of the enrollment
--              if delegate_person_id is not null then
--                      delegate_person_id must exist from before the
--                      event start date and on the day of the enrollment
--
Procedure check_spon_del_validity (p_event_id               in number,
                                   p_organization_id        in number,
                                   p_delegate_person_id     in number,
                                   p_sponsor_person_id      in number,
                                   p_date_booking_placed    in date) is
--
  l_proc        varchar2(72) := g_package||'check_spon_del_validity';
  l_event_start_date    date;
  l_delegate_start_date date;
  l_delegate_end_date   date;
  l_sponsor_start_date  date;
  l_sponsor_end_date    date;
  --
  cursor c_event is
    select course_start_date
    from ota_events
    where event_id = p_event_id;
  --
  /* Modified p_date_booking_placed to trunc(p_date_booking_placed)for bug 6402358*/

  cursor c_delegate is
    select effective_start_date, effective_end_date
    from per_all_people_f
    where person_id = p_delegate_person_id
    and trunc(p_date_booking_placed)
    between effective_start_date
    and     nvl(effective_end_date,hr_api.g_eot);
  --
  cursor c_sponsor is
    select effective_start_date, effective_end_date
    from per_all_people_f
    where person_id = p_sponsor_person_id
    and p_date_booking_placed
    between effective_start_date
    and     nvl(effective_end_date,hr_api.g_eot);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only perform check if we are dealing with an internal enrollment
  -- In other words check if p_organization_id is not null
  --
  if p_organization_id is not null then
    --
    -- Get event start_date
    --
    open c_event;
      fetch c_event into l_event_start_date;
    close c_event;
    --
    -- get delegate start_date
    --
    if p_delegate_person_id is not null then
      open c_delegate;
        fetch c_delegate into l_delegate_start_date,l_delegate_end_date;
        if c_delegate%notfound then
         fnd_message.set_name ('OTA','OTA_13505_DELEGATE_VALID');
         fnd_message.raise_error;
        end if;
      close c_delegate;
      --
      -- Check if delegate is valid for event and date booking placed date
      --
      hr_utility.set_location('Delegate start date '||to_char(l_delegate_start_date),5);
      hr_utility.set_location('Delegate end date '||to_char(l_delegate_end_date),5);
      hr_utility.set_location('date Booking Placed '||to_char(p_date_booking_placed),5);
      hr_utility.set_location('Event Start Date'||to_char(l_event_start_date),5);

      /*
      if (l_delegate_start_date > p_date_booking_placed) or
         (nvl(l_delegate_end_date,hr_api.g_eot)
          < p_date_booking_placed) or
         (l_delegate_start_date > l_event_start_date) then
         */
         --
         -- Delegate is not valid, display error
         --
         /*
         fnd_message.set_name ('OTA','OTA_13505_DELEGATE_VALID');
         fnd_message.raise_error;
      end if;
      */
    end if;
    --
    -- get sponsor start_date
    --
    if p_sponsor_person_id is not null then
      open c_sponsor;
        fetch c_sponsor into l_sponsor_start_date,l_sponsor_end_date;
      close c_sponsor;
      --
      -- Check if sponsor is valid for session dates
      --
      if (l_sponsor_start_date > p_date_booking_placed) or
         (nvl(l_sponsor_end_date,hr_api.g_eot)
         < p_date_booking_placed) then
         --
         -- Sponsor is not valid, display error
         --
         fnd_message.set_name ('OTA','OTA_13504_SPONSOR_VALID');
         fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_spon_del_validity;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_customer_details >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check whether delegate_contact_id and contact_id
--              exist for a customer.
--
--              Checks whether customer_id is not null and whether :
--              if contact_id is not null then
--                      contact_id must exist for the customer
--              if delegate_contact_id is not null then
--                      delegate_contact_id must exist for the customer
--
Procedure check_customer_details (p_customer_id         in number,
                                  p_delegate_contact_id in number,
                                  p_sponsor_contact_id  in number) is
--
  l_proc        varchar2(72) := g_package||'check_customer_details';
  l_dummy       varchar2(30);
  --


--arkashya Bug no: 2652833 replaced the select queries in c_delegate, c_sponsor to use HZ_ tables directly instead of ra_ views.

cursor c_delegate is
    select 1

     from     HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
              HZ_RELATIONSHIPS REL,
              HZ_CUST_ACCOUNTS ROLE_ACCT

     where ACCT_ROLE.PARTY_ID = REL.PARTY_ID
           AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
           AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
           AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
           AND ACCT_ROLE.CUST_ACCOUNT_ID = ROLE_ACCT.CUST_ACCOUNT_ID
           AND ROLE_ACCT.PARTY_ID       = REL.OBJECT_ID
           AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_delegate_contact_id
           AND ACCT_ROLE.CUST_ACCOUNT_ID = p_customer_id;



    cursor c_sponsor is
    select 1

     from HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
          HZ_RELATIONSHIPS REL,
          HZ_CUST_ACCOUNTS      ROLE_ACCT

     where ACCT_ROLE.PARTY_ID = REL.PARTY_ID
           AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
           AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
           AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
           AND ACCT_ROLE.CUST_ACCOUNT_ID = ROLE_ACCT.CUST_ACCOUNT_ID
           AND ROLE_ACCT.PARTY_ID       = REL.OBJECT_ID
           AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_sponsor_contact_id
           AND ACCT_ROLE.CUST_ACCOUNT_ID = p_customer_id;


  --
 --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only perform check if we are dealing with an external enrollment
  --
  if p_customer_id is not null then
    --
    -- check if delegate_contact_id exists for customer
    --
    if p_delegate_contact_id is not null then
      open c_delegate;
        fetch c_delegate into l_dummy;
        if not c_delegate%found then
         --
         -- Delegate contact is not valid, display error
         --
         fnd_message.set_name ('OTA','OTA_13507_DELEGATE_CONTACT_INV');
         fnd_message.raise_error;
        end if;
      close c_delegate;
    end if;
    --
    -- check if sponsor_contact_id is exists for customer
    --
    if p_sponsor_contact_id is not null then
      open c_sponsor;
        fetch c_sponsor into l_dummy;
        if not c_sponsor%found then
         --
         -- Sponsor contact is not valid, display error
         --
         fnd_message.set_name ('OTA','OTA_13508_SPONSOR_CONTACT_INV');
         fnd_message.raise_error;
        end if;
      close c_sponsor;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_customer_details;

--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_old_event_changed  >------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will check whether the event id is changed.
Procedure chk_old_event_changed
  (p_booking_id                         in number
   ,p_event_id          in number
  ) is

l_old_event_id  NUMBER;

CURSOR C_EVENT
IS
SELECT OLD_EVENT_ID,DAEMON_TYPE
FROM  OTA_DELEGATE_BOOKINGS
WHERE
BOOKING_ID = p_booking_id;

 l_proc  varchar2(72) := g_package||'chk_event_changed';
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  FOR C_EVENT_REC in C_EVENT
  LOOP
   hr_utility.set_location('Entering:'||l_proc, 20);
   IF C_EVENT_REC.old_event_id is not null then
      if p_event_id is not null and
         p_event_id <> C_EVENT_REC.old_event_id then

         fnd_message.set_name('OTA', 'OTA_13905_UPDATE_EVENT_FAILURE');
         fnd_message.raise_error;


      end if;
   END IF;
   END LOOP;
   hr_utility.set_location('Leaving:'||l_proc, 30);
END chk_old_event_changed  ;

--
-- ----------------------------------------------------------------------------
-- |---------------------------<  check_commitment_date  >------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will check whether the event_end_date is after commitment_end_date.
-- If it is, then an error is raised.
Procedure check_commitment_date
  (p_line_id                    in number
   ,p_event_id          in number
  ) is
l_commitment_id         ra_customer_trx_all.customer_trx_id%TYPE;
l_commitment_number     ra_customer_trx_all.trx_number%TYPE;
l_commitment_end_date   ra_customer_trx_all.end_date_commitment%TYPE;
l_commitment_start_date ra_customer_trx_all.start_date_commitment%TYPE;
l_event_end_date        ota_events.course_end_date%TYPE;
--
CURSOR c_event
    IS SELECT course_end_date
  FROM ota_events
 WHERE event_id = p_event_id;
 l_proc VARCHAR2(72) := g_package||'check_commitment_date';
BEGIN
hr_utility.set_location('Entering:'||l_proc,5);
FOR c_event_rec IN c_event
LOOP
hr_utility.set_location('Entering:'||l_proc,20);
l_event_end_date := c_event_rec.course_end_date;
END LOOP;
 ota_utility.get_commitment_detail(p_line_id,
                                   l_commitment_id,
                                   l_commitment_number,
                                   l_commitment_start_date,
                                   l_commitment_end_date);
IF l_commitment_end_date IS NOT NULL AND
   l_event_end_date > l_commitment_end_date THEN
fnd_message.set_name('OTA','OTA_OM_COMMITMENT');
fnd_message.set_token('COMMITMENT_NUMBER',l_commitment_number);
fnd_message.set_token('COMMITMENT_END_DATE',fnd_date.date_to_chardate(l_commitment_end_date));
END IF;
hr_utility.set_location('Leaving:'||l_proc,30);
END check_commitment_date;

-- ----------------------------------------------------------------------------
-- |-------------------------< Check Location  >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check the event location when Inserting or updating. Compare the
--              country for event location to the country for OM org. If the country
--              is not the same, raise an error.
--
procedure Check_Location(p_event_id IN NUMBER,
                    p_om_org_id IN VARCHAR2) IS
  --
CURSOR org_country_cr IS
SELECT org.name,
       org.organization_id,
       loc.country,
       loc.location_id
  FROM hr_all_organization_units_tl org,
       hr_all_organization_units org1,
       hr_locations_all loc
 WHERE org.organization_id = org1.organization_id
   AND loc.location_id(+) = org1.location_id
   AND org.language = USERENV('LANG')
   AND org1.organization_id = p_om_org_id;

CURSOR evt_country_cr IS
SELECT loc.country
  FROM hr_locations_all loc
 WHERE loc.location_id = ota_utility.get_event_location(p_event_id);
  --
  --
  l_org_country                    hr_locations_all.country%TYPE := null;
  l_evt_country                    hr_locations_all.country%TYPE := null;
  l_proc                           VARCHAR2(72) := g_package||'check_location';
  --
begin
  --
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- get country for OM org
    if p_om_org_id is not null then
    --
   FOR org_country IN org_country_cr
       LOOP
       l_org_country := org_country.country;
   END LOOP;
      end if;
    --
  --
  -- Get country for event
  --
    if p_event_id is not null then
    --
   FOR evt_country IN evt_country_cr
       LOOP
       l_evt_country := evt_country.country;
   END LOOP;
      end if;
  IF l_evt_country IS NOT NULL AND l_org_country IS NOT NULL THEN
    --check if the countries are same
    IF l_evt_country <> l_org_country THEN
    --
    fnd_message.set_name('OTA','OTA_13956_TDB_CHECK_LOCATION');
    fnd_message.raise_error;
    --
    END IF;
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end Check_location;
--
end ota_tdb_bus2;

/
