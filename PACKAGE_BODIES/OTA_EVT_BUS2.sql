--------------------------------------------------------
--  DDL for Package Body OTA_EVT_BUS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EVT_BUS2" as
/* $Header: otevt02t.pkb 120.6.12010000.2 2010/02/09 06:20:36 pekasi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_evt_bus2.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Lock_Event >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Locks the Event
--
--
procedure LOCK_EVENT (p_event_id in number)  is
--
l_evt_object_version_number number;
--
cursor get_event is
select  object_version_number
from    ota_events
where event_id = p_event_id;
--
  l_proc	varchar2(72) := g_package||'lock_event';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open get_event;
  fetch get_event into l_evt_object_version_number;
  if get_event%notfound then
     null;
  end if;
  --
  ota_evt_shd.lck(p_event_id
  ,l_evt_object_version_number);
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end LOCK_EVENT;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Get Total Places >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Get total number of placed delegates.
--
--
function Get_Total_Places(p_all_or_internal in varchar2
			 ,p_event_id in number) return number is
--
l_tdb_total_places  number;
--
cursor get_total_places is
select  nvl(sum(number_of_places),0)
from    ota_delegate_bookings tdb
,	ota_booking_status_types bst
,	ota_events evt
where	tdb.event_id = p_event_id
and	evt.event_id = p_event_id
and	tdb.booking_status_type_id = bst.booking_status_type_id
and	bst.type in ('P','A','E')
and	tdb.internal_booking_flag = decode(p_all_or_internal,
				      'INTERNAL','Y',tdb.internal_booking_flag)
and	((price_basis = 'C' and  delegate_contact_id is null)
	or (price_basis <> 'C'));
--
  l_proc	varchar2(72) := g_package||'get_total_places';
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open  get_total_places;
  fetch get_total_places into l_tdb_total_places;
  close get_total_places;
  --
  return l_tdb_total_places;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end Get_Total_Places;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Check Places >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Checks the Maximum_Attendees and Maximum_Internal_Attendees
--		when updated.
--
--
procedure Check_Places(p_event_id in number
		      ,p_maximum_attendees in number
		      ,p_maximum_internal_attendees in number)  is
--
--
l_total_places 		number :=	ota_evt_bus2.get_total_places('ALL',p_event_id);
l_total_internal_places number :=	ota_evt_bus2.get_total_places('INTERNAL',p_event_id);
--
  l_proc	varchar2(72) := g_package||'check_places';
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_maximum_attendees is not null and p_maximum_internal_attendees is not null then
    if p_maximum_internal_attendees > p_maximum_attendees then
       fnd_message.set_name('OTA','OTA_13512_EVT_MAX_ATT');
       fnd_message.raise_error;
    end if;
  end if;
  --
  if p_maximum_attendees is not null then
    if l_total_places > p_maximum_attendees then
       fnd_message.set_name('OTA','OTA_13513_EVT_MAX_INT_ATT');
       fnd_message.raise_error;
    end if;
  end if;
  --
  if p_maximum_internal_attendees is not null then
    if l_total_internal_places > p_maximum_internal_attendees then
       fnd_message.set_name('OTA','OTA_13514_EVT_MAX_NORM_ATT');
       fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end Check_Places;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< Reset_Event_Status >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Reset Event Status
--
--              Resets the Event Status for the event record if event is reached
--		to full.
--
procedure Reset_Event_Status(p_event_id in number
			    ,p_object_version_number in out nocopy number
			    ,p_event_status in varchar2
			    ,p_maximum_attendees in number)  is
--
l_total_places number;
l_new_event_status varchar2(30);
--
--
  l_proc	varchar2(72) := g_package||'reset_event_status';
--
  l_no_of_waitlist_candidate          number;
  l_no_of_int_waitlist_can number;

cursor  c_check_waitlist_candidates is
select  count(rowid)
from    ota_delegate_bookings odb
where   event_id = p_event_id and
        booking_status_type_id in
        (select booking_status_type_id
         from   ota_booking_status_types
         where  type = 'W');


cursor  c_check_int_waitlist_can is
select  count(rowid)
from    ota_delegate_bookings odb
where   event_id = p_event_id and
	   internal_booking_flag = 'Y' and
        booking_status_type_id in
        (select booking_status_type_id
         from   ota_booking_status_types
         where  type = 'W' );

--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_event_status in ('N','F') then
    if p_maximum_attendees is not null then
      l_total_places := get_total_places('ALL',p_event_id);
  --
      if l_total_places = p_maximum_attendees and p_event_status in ('N') then
	l_new_event_status := 'F';
      elsif l_total_places < p_maximum_attendees then



       if fnd_profile.value('OTA_AUTO_WAITLIST_ACTIVE') = 'Y' then

         open  c_check_waitlist_candidates;
         fetch c_check_waitlist_candidates into l_no_of_waitlist_candidate;
         close c_check_waitlist_candidates;

         open  c_check_int_waitlist_can;
         fetch c_check_int_waitlist_can into l_no_of_int_waitlist_can;
         close c_check_int_waitlist_can;

         if l_no_of_waitlist_candidate - l_no_of_int_waitlist_can > 0 then
            l_new_event_status := 'F';
         else
            l_new_event_status := 'N';
         end if;
       else
          l_new_event_status := 'N';
       end if;

     end if;
  --
      if p_event_status <> l_new_event_status then
	ota_evt_upd.upd(p_event_id => p_event_id
		       ,p_object_version_number => p_object_version_number
		       ,p_event_status => l_new_event_status);
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end Reset_Event_Status;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Resource Bookings Exists >--------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Checks whether Resource bookings exists for a particular event.
--
--
Function Resource_Booking_Exists (p_event_id in number) return boolean is
--
cursor  c_check_resource_bookings is
select  count(resource_booking_id)
from    ota_resource_bookings res
where	res.event_id = p_event_id;
--
  l_resource_booking_exists number;
  l_proc 	varchar2(72) := g_package||'resource_booking_exists';
--
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check if resource_booking exists.
  --
  open c_check_resource_bookings;
  fetch c_check_resource_bookings into l_resource_booking_exists;
  close c_check_resource_bookings;
  --
  if l_resource_booking_exists = 0 then
    return false;
  else
    return true;
  end if;
  --
    hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end Resource_Booking_Exists;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Finance Line Exists >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Checks whether a finance line exists for a particular booking_Id.
--
--
Function Finance_Line_Exists (p_booking_id in number
			     ,p_cancelled_flag in varchar2) return boolean is
--
cursor  c_check_finance_line is
select  nvl(sum(booking_id),0)
from    ota_finance_lines tfl
where	tfl.booking_id = p_booking_id
and	tfl.cancelled_flag = p_cancelled_flag;
l_finance_line_exists number;
--
  l_proc 	varchar2(72) := g_package||'finance_line_exists';
--
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check if finance line exists.
  --
  open c_check_finance_line;
  fetch c_check_finance_line into l_finance_line_exists;
  close c_check_finance_line;
  --
  if l_finance_line_exists = 0 then
    return false;
  else
    return true;
  end if;
  --
    hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end Finance_Line_Exists;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Get Vacancies >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Get Vacancies
--
--              Get current vacancies for a particular event.
--
Function Get_Vacancies(p_event_id in number) return number is
--
p_rec 		ota_evt_shd.g_rec_type;
p_event_exists 	boolean;
l_vacancies	number;
l_total_places  number := ota_evt_bus2.get_total_places('ALL',p_event_id);
l_proc 	varchar2(72) := g_package||'get_vacancies';
--
--
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  ota_evt_shd.get_event_details(p_event_id,p_rec,p_event_exists);
  --
  if p_rec.maximum_attendees is not null then
    l_vacancies := p_rec.maximum_attendees - l_total_places;
  else
    l_vacancies := null;
  end if;
  --
  return l_vacancies;
  --
    hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end Get_Vacancies;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Wait List Required >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check if Wait List window is required.
--
--              Returns Boolean - True for Yes.
--
Function Wait_List_Required     (p_event_type in varchar2
				,p_event_id in number
				,p_event_status in varchar2
				,p_booking_status_type_id  in number default null)
Return Boolean is
--
l_rec 		ota_evt_shd.g_rec_type;
l_event_exists 	boolean;
l_old_booking_status varchar2(30);
l_new_booking_status varchar2(30);
l_total_attendees number := ota_evt_bus2.get_total_places('ALL',p_event_id);
l_total_waitlisted number :=
	ota_tdb_bus.places_for_status(p_event_id => p_event_id
				     ,p_all_or_internal => 'ALL'
				     ,p_status_type => 'W');
l_proc 	varchar2(72) := g_package||'wait_list_required';
--
Begin
  --
  ota_evt_shd.get_event_details(p_event_id,l_rec,l_event_exists);
  --
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --
    if p_event_type = 'ENROLLMENT' then
  --
    l_old_booking_status := ota_tdb_bus.booking_status_type(
				ota_tdb_shd.g_old_rec.booking_status_type_id);
    l_new_booking_status := ota_tdb_bus.booking_status_type(
					p_booking_status_type_id);
    if l_old_booking_status in ('P','A','E') and --6683076.Added 'E' as new status.
       l_new_booking_status in ('W','C','R') and
       l_total_waitlisted <> 0 then
       return (true);
    else
       return (false);
    end if;
  --
  elsif p_event_type = 'EVENT' then
  --
-- ***
    if (p_event_status = 'N' or p_event_status = 'F')
       and l_rec.maximum_attendees > l_total_attendees
       and l_total_waitlisted <> 0 then
       return (true);
    else
       return (false);
    end if;
  --
  else
  --
    return (false);
  --
  end if;
  --
    hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end Wait_List_Required;
--
-- --------------------------------------------------------------------------------------------
-- |--------------------------< Check if Mandatory Associations exists for a particular event >--------------------------------|
-- ------------------------------------------------------------------------------------------
--
function mandatory_associations_exists(p_event_id in number)return boolean is

      cursor check_mandatory_assoc is
      select count(*)
      from
      ota_event_associations
      where
      nvl(mandatory_enrollment_flag,'N')= 'Y' and
      event_id = p_event_id;

l_proc varchar2(72) := g_package ||'mandatory_associations_exists';
l_mandatory_assoc_exists number;

begin

hr_utility.set_location('Leaving:'|| l_proc, 5);
--  check if mandatory associations are defined for the class
  OPEN check_mandatory_assoc;
  FETCH check_mandatory_assoc into l_mandatory_assoc_exists;
  CLOSE check_mandatory_assoc;

  if l_mandatory_assoc_exists = 0 then
	   return false;
  else
       return true;
  end if;

hr_utility.set_location('Leaving:'|| l_proc, 10);

end mandatory_associations_exists;



-- ----------------------------------------------------------------------------
-- |--------------------------< Check Mandatory Associations >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Checks if mandatory enrollment type of event association has been defined
--while updating the Maximum_Attendees and Maximum_Internal_Attendees.This is performed as mandatory enrollments
--can be created for a class only if Maximum_Attendees and Maximum_Internal_Attendees are not defined for
--the class
--
--
procedure Check_Mandatory_Associations(p_event_id in number
		      ,p_maximum_attendees in number
		      ,p_maximum_internal_attendees in number)  is
--
--
l_mandatory_association_exists boolean   := ota_evt_bus2.mandatory_associations_exists(p_event_id);

l_proc	varchar2(72) := g_package||'check_mandatory_associations';
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_maximum_attendees is not null or p_maximum_internal_attendees is not null then
       if ((l_mandatory_association_exists and  p_maximum_attendees >= 0) or
       (l_mandatory_association_exists and  p_maximum_internal_attendees >= 0)) then
       fnd_message.set_name('OTA','OTA_467070_MANDATORY_ENR_ERR');
       fnd_message.raise_error;
    end if;

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end Check_Mandatory_Associations;
end ota_evt_bus2;

/
