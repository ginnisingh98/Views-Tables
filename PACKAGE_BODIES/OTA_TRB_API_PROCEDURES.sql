--------------------------------------------------------
--  DDL for Package Body OTA_TRB_API_PROCEDURES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRB_API_PROCEDURES" as
/* $Header: ottrb02t.pkb 120.18.12000000.4 2007/07/05 09:18:38 aabalakr noship $ */
--
g_package varchar2(33) := 'ota_trb_api_procedures.';
--
-- The business rules......
--
--
--
-- --------------------------------------------------------------------
-- |---------------------< check_resource_type >-----------------------
-- --------------------------------------------------------------------
-- PRIVATE
-- Description: This function returns a TRUE if the resource type is a
--              venue based upon the given supplied_resource_id. This is
--              only for use by procedures in this package.
--
function check_resource_type(p_supplied_resource_id in number,
			     p_type in varchar2)
return boolean is
--
l_proc        varchar2(72) := g_package||'check_resource_type';
l_exists number;
l_return boolean;
--
-- cursor to make the check
--
cursor chk_type is
select 1
from ota_suppliable_resources
where supplied_resource_id = p_supplied_resource_id
and resource_type = p_type;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_type;
fetch chk_type into l_exists;
IF chk_type%found THEN
  l_return := TRUE;
  ELSE
    l_return := FALSE;
    END IF;
    close chk_type;
--
return (l_return);
--
hr_utility.set_location(' Leaving:'||l_proc, 10);
end check_resource_type;
--
-- ---------------------------------------------------------------------
-- |------------------< check_number_delegates >------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: check number delegates
--
--              When event is not planned the number of delegates per
--              unit should be greater than or equal to max attendees
--              on the event or activity version.
--
--              This function returns FALSE if a warning needs to be
--              issued and TRUE otherwise.
--
/* function check_number_delegates(p_event_id IN NUMBER,
                                p_supplied_resource_id IN NUMBER)
				 return boolean is
--
l_proc varchar2(72) := g_package||'check_number_delegates';
l_plnd varchar2(30);
l_venue varchar2(30);
l_exists number;
l_event_id number := p_event_id;
l_parent_id number;
l_type varchar2(30);
l_return boolean;
--
-- cursor to check if event is PLANNED
--
cursor chk_pland is
select event_status
from ota_events
where event_id = l_event_id;
--
-- cursor to check if resource booking is for a SESSION
--
cursor chk_sess is
select event_type,parent_event_id
from ota_events
where event_id = l_event_id;
--
-- cursor to check numbers of delegates per unit
--
cursor chk_number is
select 1
from ota_suppliable_resources sr,
     ota_events e,
     ota_offerings off
where sr.supplied_resource_id = p_supplied_resource_id
and e.event_id = l_event_id
and off.offering_id = e.parent_offering_id			--bug 3494404
and sr.delegates_per_unit >=
nvl(e.maximum_attendees,off.maximum_attendees);
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_pland;
fetch chk_pland into l_plnd;
close chk_pland;
IF l_plnd IN ('F','N') THEN
  IF check_resource_type(p_supplied_resource_id,
			   'V') THEN
    open chk_sess;
    fetch chk_sess into l_type,l_parent_id;
    close chk_sess;
    IF l_type = 'SESSION' THEN
      l_event_id := l_parent_id;
    END IF;
    open chk_number;
    fetch chk_number into l_exists;
    IF chk_number%notfound THEN
      close chk_number;
      l_return := FALSE;
    ELSE close chk_number;
      l_return := TRUE;
    END IF;
  ELSE l_return := TRUE;
  END IF;
ELSE l_return := TRUE;
END IF;
return (l_return);
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_number_delegates;  */
--
-- ---------------------------------------------------------------------
-- |-------------------< check_role_to_play >---------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: The role_to_play field must be in the domain
--              Trainer Participation.
--
procedure check_role_to_play(p_role_to_play in varchar2) is
--
l_proc        varchar2(72) := g_package||'check_role_to_play';
l_exists number;
--
-- cursor to perform check
--
cursor chk_roleplay is
select 1
from hr_lookups
where lookup_type = 'TRAINER_PARTICIPATION'
and lookup_code = p_role_to_play;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_roleplay;
fetch chk_roleplay into l_exists;
IF chk_roleplay%notfound THEN
  fnd_message.set_name('OTA','OTA_13264_TRB_ROLE_TO_PLAY_TYP');
  close chk_roleplay;
  fnd_message.raise_error;
END IF;
close chk_roleplay;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_role_to_play;
--
-- ---------------------------------------------------------------------
-- |------------------< check_role_res_type_excl >----------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description:
--
procedure check_role_res_type_excl(p_supplied_resource_id in number,
			           p_role_to_play in varchar2) is
--
l_proc        varchar2(72) := g_package||'check_role_res_type_excl';
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
IF p_role_to_play is not null THEN
  IF not check_resource_type(p_supplied_resource_id,
			     'T') THEN
    fnd_message.set_name('OTA','OTA_13264_TRB_ROLE_TO_PLAY_TYP');
    fnd_message.raise_error;
  END IF;
END IF;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_role_res_type_excl;
--
-- ---------------------------------------------------------------------
-- |------------------------< get_total_cost >--------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: get the total cost of all resources required for the
--              event.
--
procedure get_total_cost(p_event_id in number,
			 p_total_cost in out nocopy number) is
--
l_proc        varchar2(72) := g_package||'get_total_cost';
l_exists number;
l_tot number;
l_business_group_id ota_events.business_group_id%type;  -- bug 4304067
--
-- cursor to perform check on currency codes
--
cursor chk_curr (p_business_group_id in number) is -- bug 4304067
select 1
from ota_events e
where business_group_id = p_business_group_id
and exists
(select 1
 from ota_suppliable_resources sr,
      ota_resource_bookings rb
 where rb.event_id = e.event_id
 and sr.business_group_id = p_business_group_id
 and sr.supplied_resource_id = rb.supplied_resource_id
 and sr.currency_code <> e.currency_code);

--
-- cursor to get business_group_id   bug 4304067
--
cursor csr_business_group_id is
select e.business_group_id
from ota_events e
where e.event_id = p_event_id;

--
-- cursor to perform calculations
--
cursor get_rescost is
select sr.cost
from ota_suppliable_resources sr,
     ota_events e,
     ota_resource_bookings rb
where rb.event_id = p_event_id
and rb.status = 'C'
and sr.supplied_resource_id = rb.supplied_resource_id
and e.event_id = p_event_id;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--

open csr_business_group_id ; --bug 4304067
fetch csr_business_group_id into l_business_group_id;
close csr_business_group_id;

open chk_curr(l_business_group_id);
fetch chk_curr into l_exists;
IF chk_curr%notfound THEN
  close chk_curr;
  FOR get_totcost IN get_rescost LOOP
    l_tot := l_tot + get_totcost.cost;
  END LOOP;
  p_total_cost := l_tot;
ELSE close chk_curr;
END IF;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end get_total_cost;
--
-- ---------------------------------------------------------------------
-- |--------------------< check_quantity_entered >----------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: The quantity field must be set to 1 if the resource is
--              a venue of the person is a named trainer
--
procedure check_quantity_entered(p_supplied_resource_id in number,
				 p_quantity in number) is
--
l_proc        varchar2(72) := g_package||'check_quantity_entered';
--l_person_id number;
--
--code commented out as person_id is no longer available from suppliable
--resources KLS 04/09/95
--
-- cursor to check person id
--
--cursor chk_per is
--select person_id
--from ota_suppliable_resources
--where supplied_resource_id = p_supplied_resource_id;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
if p_quantity > 1 then
  if check_resource_type(p_supplied_resource_id,
                           'V') THEN
     fnd_message.set_name('OTA','OTA_13265_TRB_QUANTITY_ENTERED');
    fnd_message.raise_error;
  elsif check_resource_type(p_supplied_resource_id,
			     'T') THEN
    fnd_message.set_name('OTA','OTA_13265_TRB_QUANTITY_ENTERED');
    fnd_message.raise_error;
  else
    null;
    --open chk_per;
    --fetch chk_per into l_person_id;
    --close chk_per;
    --IF l_person_id is not null THEN
       --fnd_message.set_name('OTA','OTA_13265_TRB_QUANTITY_ENTERED');
       --fnd_message.raise_error;
    --end if;
  end if;
end if;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_quantity_entered;
--
-- ---------------------------------------------------------------------
-- |-------------------< check_delivery_address >-----------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Delivery address cannot be entered if resource type is
--              VENUE or TRAINER.
--
procedure check_delivery_address(p_supplied_resource_id in number,
				 p_del_add in varchar2) is
--
l_proc        varchar2(72) := g_package||'check_delivery_address';
l_exists number;
--
cursor chk_type is
select 1
from ota_suppliable_resources sr,
     hr_lookups l
where sr.supplied_resource_id = p_supplied_resource_id
and sr.resource_type = l.lookup_code
and l.lookup_type in ('VENUE','TRAINER');
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_type;
fetch chk_type into l_exists;
IF l_exists = '1' AND p_del_add is not null THEN
  fnd_message.set_name('OTA','OTA_13266_TRB_DELIVERY_ADDRESS');
  close chk_type;
  fnd_message.raise_error;
END IF;
close chk_type;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_delivery_address;
--
-- ---------------------------------------------------------------------
-- |------------------------< get_resource_booking_id >-----------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Return the RESOURCE BOOKING ID when supplied with only
--              the SUPPLIED RESOURCE ID and EVENT ID.
--
function get_resource_booking_id(p_supplied_resource_id in number,
				 p_event_id in number)
return number is
--
l_proc        varchar2(72) := g_package||'get_resource_booking_id';
l_resbook_id number;
--
-- cursor to retrieve booking id
--
cursor get_book is
select resource_booking_id
from ota_resource_bookings
where supplied_resource_id = p_supplied_resource_id
and event_id = p_event_id;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open get_book;
fetch get_book into l_resbook_id;
IF get_book%notfound THEN
  fnd_message.set_name('OTA','OTA_13267_TRB_BOOKING_ID');
  close get_book;
  fnd_message.raise_error;
END IF;
close get_book;
--
return (l_resbook_id);
--
hr_utility.set_location('Leaving:'||l_proc,10);
end get_resource_booking_id;
--
-- ---------------------------------------------------------------------
-- |-----------------------< resource_booked_for_event >----------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Return a TRUE if any resource bookings have been made
--              for the specified event. Otherwise return a FALSE.
--
function resource_booked_for_event(p_event_id in number)
return boolean is
--
l_proc        varchar2(72) := g_package||'resource_booked_for_event';
l_exists number;
l_return boolean;
--
-- cursor to perform check
--
cursor chk_bookings is
select 1
from ota_resource_bookings
where event_id = p_event_id;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_bookings;
fetch chk_bookings into l_exists;
IF chk_bookings%found THEN l_return := TRUE;
ELSE l_return := FALSE;
END IF;
close chk_bookings;
--
return (l_return);
--
hr_utility.set_location('Leaving:'||l_proc,10);
end resource_booked_for_event;

-- ---------------------------------------------------------------------
-- |----------------------------< check_obj_booking_dates >---------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Required dates must be within boudaries of suppliable
--              resource validity dates.
--
procedure check_obj_booking_dates(p_supplied_resource_id in number,
			  p_req_from in date,
                          p_req_to in date,
                          p_event_id in number,
                          p_chat_id in number,
                          p_forum_id in number,
			  p_timezone_code in varchar2,
			  p_req_time_from in varchar2,
		          p_req_time_to in varchar2,
				  p_warning out nocopy varchar2) is
--
l_proc        varchar2(72) := g_package||'check_obj_booking_dates';
l_exists number;

--cursor to get dates of object

cursor get_event_dates is
select course_start_date,course_end_date,event_type,timezone,course_start_time,course_end_time
from ota_events
where event_id = p_event_id;

cursor get_forum_dates is
select start_date_active,end_date_active
from ota_forums_b
where forum_id = p_forum_id;

cursor get_chat_dates is
select start_date_active,end_date_active,timezone_code
from ota_chats_b
where chat_id = p_chat_id;
--
-- cursor to check date ranges of resource being booked
--

cursor chk_dates_tsr(crs_start_date date,crs_end_date date,crs_timezone varchar2, crs_start_time varchar2, crs_end_time varchar2) is
select 1
from dual
where decode(crs_start_date, null, ota_timezone_util.convert_date(p_req_from, nvl(p_req_time_from,'23:59'), p_timezone_code,crs_timezone), to_date(to_char(to_char(crs_start_date,'dd-mm-yyyy')||' '||nvl(crs_start_time,'23:59')), 'dd-mm-yyyy HH24:MI'))
>= ota_timezone_util.convert_date(p_req_from, nvl(p_req_time_from,'23:59'), p_timezone_code,crs_timezone)
--to_date(to_char(to_char(crs_start_date,'dd-mm-yyyy')||' '||nvl(crs_start_time,'00:00')), 'dd-mm-yyyy HH24:MI') <= ota_timezone_util.convert_date(p_req_from, nvl(p_req_time_from,'00:00'), p_timezone_code,crs_timezone)
and decode(crs_end_date, null, ota_timezone_util.convert_date(p_req_to, nvl(p_req_time_to,'23:59'), p_timezone_code,crs_timezone), to_date(to_char(to_char(crs_end_date,'dd-mm-yyyy')||' '||nvl(crs_end_time,'23:59')), 'dd-mm-yyyy HH24:MI'))
	>= ota_timezone_util.convert_date(p_req_to, nvl(p_req_time_to,'23:59'), p_timezone_code,crs_timezone);


l_start_date date;
l_end_date date;
l_start_time varchar2(10) := null;
l_end_time varchar2(10) :=null;
l_token varchar2(20);
l_event_type varchar2(20);
l_timezone varchar2(30) := null;
l_id_passed boolean := false;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);

if p_event_id is not null then
l_id_passed :=true;
open get_event_dates;
fetch get_event_dates into l_start_date,l_end_date,l_event_type,l_timezone,l_start_time,l_end_time;
close get_event_dates;
if l_event_type <> 'SESSION' then
l_token := ota_utility.get_lookup_meaning('OTA_OBJECT_TYPE','CL',810);
else
l_token := ota_utility.get_lookup_meaning('OTA_OBJECT_TYPE','S',810);
end if;

elsif p_chat_id is not null then
l_id_passed :=true;
open get_chat_dates;
fetch get_chat_dates into l_start_date,l_end_date,l_timezone;
close get_chat_dates;
l_token := ota_utility.get_lookup_meaning('OTA_OBJECT_TYPE','CHT',810);
elsif p_forum_id is not null then
l_id_passed :=true;
open get_forum_dates;
fetch get_forum_dates into l_start_date,l_end_date;
close get_forum_dates;
l_token := ota_utility.get_lookup_meaning('OTA_OBJECT_TYPE','FRM',810);
end if;
--
p_warning := 'N';

if l_id_passed then
open chk_dates_tsr(l_start_date,l_end_date,l_timezone,l_start_time,l_end_time);
fetch chk_dates_tsr into l_exists;
IF chk_dates_tsr%notfound THEN
 p_warning := 'Y';
end if;
close chk_dates_tsr;
end if;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_obj_booking_dates;
--
-- ---------------------------------------------------------------------
-- |----------------------------< check_dates_tsr >---------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Required dates must be within boudaries of suppliable
--              resource validity dates.
--
procedure check_dates_tsr(p_supplied_resource_id in number,
			  p_req_from in date,
                          p_req_to in date,
                          p_req_start_time in varchar2,
			  p_req_end_time in varchar2,
			  p_timezone_code in varchar2) is
--
l_proc        varchar2(72) := g_package||'check_dates_tsr';
l_exists number;
--
-- cursor to check date ranges
--
cursor chk_dates_tsr is
select 1
from ota_suppliable_resources
where supplied_resource_id = p_supplied_resource_id
and start_date <= ota_timezone_util.convert_date(p_req_from, p_req_start_time, p_timezone_code, ota_timezone_util.get_server_timezone_code)
and decode(end_date, null, ota_timezone_util.convert_date(p_req_to, p_req_end_time, p_timezone_code, ota_timezone_util.get_server_timezone_code), end_date)
	>= ota_timezone_util.convert_date(p_req_to, p_req_end_time, p_timezone_code, ota_timezone_util.get_server_timezone_code);


/* commented for bug6078493
cursor chk_dates_tsr is
select 1
from ota_suppliable_resources
where supplied_resource_id = p_supplied_resource_id
and start_date <= ota_timezone_util.convert_date(p_req_from, null, p_timezone_code, ota_timezone_util.get_server_timezone_code)
and decode(end_date, null, ota_timezone_util.convert_date(p_req_to, null, p_timezone_code, ota_timezone_util.get_server_timezone_code), end_date)
	>= ota_timezone_util.convert_date(p_req_to, null, p_timezone_code, ota_timezone_util.get_server_timezone_code);
*/
/*
cursor chk_dates_tsr is
select 1
from ota_suppliable_resources
where supplied_resource_id = p_supplied_resource_id
and start_date <= p_req_from
and nvl(end_date,nvl(p_req_to,hr_api.g_eot)) >= nvl(p_req_to,hr_api.g_eot);
*/

--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_dates_tsr;
fetch chk_dates_tsr into l_exists;
IF chk_dates_tsr%notfound THEN
  fnd_message.set_name('OTA','OTA_13269_TRB_REQUIRED_DATES');
  close chk_dates_tsr;
  fnd_message.raise_error;
END IF;
close chk_dates_tsr;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_dates_tsr;
--
-- ---------------------------------------------------------------------
-- |-------------------------< check_evt_tsr_bus_grp >------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: The events business group id must be the same as that of
--              the suppliable resource.
--
-- NB: This business rule may well disappear in the future as the
--     structure of organizations for OTA may change with the
--     addition of a VENDORS table. Suppliable Resources table may
--     well then contain a business_group_id column anyway.
--     KLS 24/11/94.
--
procedure check_evt_tsr_bus_grp(p_event_id in number,
				p_supplied_resource_id in number) is
--
l_proc        varchar2(72) := g_package||'check_evt_tsr_bus_grp';
l_exists number;
--
-- cursor to check business group id's
--
cursor chk_bgroup is
select 1
from ota_events e,
     ota_suppliable_resources sr
where sr.supplied_resource_id = p_supplied_resource_id
and e.event_id = p_event_id
and sr.business_group_id = e.business_group_id;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
   open chk_bgroup;
   fetch chk_bgroup into l_exists;
   IF chk_bgroup%notfound THEN
     fnd_message.set_name('OTA','OTA_13270_BUS_GROUP_EQUAL');
     close chk_bgroup;
     fnd_message.raise_error;
   END IF;
   close chk_bgroup;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_evt_tsr_bus_grp;
--
-- ---------------------------------------------------------------------
-- |---------------------------< check_from_to_dates >------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: required date from must be less than or equal to the
--              required date to.
--
procedure check_from_to_dates(p_req_from in date,
			      p_req_to in date) is
--
l_proc        varchar2(72) := g_package||'check_from_to_dates';
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
IF p_req_from <= nvl(p_req_to,hr_api.g_eot) THEN null;
ELSE  fnd_message.set_name('OTA','OTA_13271_TRB_FROM_TO_DATES');
      fnd_message.raise_error;
END IF;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_from_to_dates;
--
-- ---------------------------------------------------------------------
-- |----------------------------< check_update_tra >--------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Update of required dates must not invalidate any
--              resource allocations.
--
procedure check_update_tra(p_resource_booking_id in number,
			   p_req_date_from in date,
			   p_req_date_to in date) is
--
l_proc        varchar2(72) := g_package||'check_update_tra';
l_exists number;
--
-- cursor to perform the check
--
cursor chk_dates is
select 1
from ota_resource_allocations
where (trainer_resource_booking_id = p_resource_booking_id
       OR equipment_resource_booking_id = p_resource_booking_id)
and (start_date < p_req_date_from OR end_date > p_req_date_to);
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_dates;
fetch chk_dates into l_exists;
IF chk_dates%found THEN
  fnd_message.set_name('OTA','OTA_13278_TRB_CHECK_TRA_DATES');
  close chk_dates;
  fnd_message.raise_error;
END IF;
close chk_dates;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_update_tra;
--
-- ---------------------------------------------------------------------
-- |------------------------< check_tra_trainer_exists >----------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: A resource booking may not be deleted if a row exists
--              in OTA_RESOURCE_ALLOCATIONS with this resource booking
--              id.
--
procedure check_tra_trainer_exists(p_resource_booking_id in number) is
--
l_proc        varchar2(72) := g_package||'check_tra_trainer_exists';
l_exists number;
--
-- cursor to perform check
--
cursor chk_trn is
select 1
from ota_resource_allocations
where trainer_resource_booking_id = p_resource_booking_id;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_trn;
fetch chk_trn into l_exists;
IF chk_trn%found THEN
  fnd_message.set_name('OTA','OTA_13272_TRB_ALLOCATION_EXIST');
  close chk_trn;
  fnd_message.raise_error;
END IF;
close chk_trn;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_tra_trainer_exists;
--
-- ---------------------------------------------------------------------
-- |--------------------< check_tra_resource_exists >-------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: A resource booking may not be deleted if in use as a
--              EQUIPMENT_RESOURCE_BOOKING_ID in
--              OTA_RESOURCE_ALLOCATIONS.
--
procedure check_tra_resource_exists(p_resource_booking_id in number) is
--
l_proc        varchar2(72) := g_package||'check_tra_resource_exists';
l_exists number;
--
-- cursor to perform check
--
cursor chk_res is
select 1
from ota_resource_allocations
where equipment_resource_booking_id = p_resource_booking_id;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_res;
fetch chk_res into l_exists;
IF chk_res%found THEN
  fnd_message.set_name('OTA','OTA_13272_TRB_ALLOCATION_EXIST');
  close chk_res;
  fnd_message.raise_error;
END IF;
close chk_res;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_tra_resource_exists;
--
-- ---------------------------------------------------------------------
-- |------------------------< check_status >----------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: The user status must be in the domain RESOURCE BOOKING
--              STATUS.
--
procedure check_status(p_status in varchar2) is
--
l_proc        varchar2(72) := g_package||'check_status';
l_exists number;
--
-- cursor to perform check
--
cursor chk_status is
select 1
from hr_lookups l
where lookup_type = 'RESOURCE_BOOKING_STATUS'
and lookup_code = p_status;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_status;
fetch chk_status into l_exists;
IF chk_status%notfound THEN
  fnd_message.set_name('OTA','OTA_13204_GEN_INVALID_LOOKUP');
  fnd_message.set_token('FIELD','Status');
  fnd_message.set_token('LOOKUP_TYPE','RESOURCE_BOOKING_STATUS');
  close chk_status;
  fnd_message.raise_error;
END IF;
close chk_status;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_status;
--
-- ---------------------------------------------------------------------
-- |-----------------------< check_status_value >-----------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: If status is confirmed then check that its valid to have
--              confirmed resource bookings against this event.
--
procedure check_status_value is
--
l_proc        varchar2(72) := g_package||'check_status_value';
--
-- left for now until API for events entity written so code can be
-- shared. KLS 25/11/94.
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
null;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_status_value;
--
-- ---------------------------------------------------------------------
-- |---------------------< check_primary_venue >------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Only one venue resource booking may be a primary venue.
--
procedure check_primary_venue(p_event_id in number,
                              p_resource_booking_id in number,
			      p_prim_ven in varchar2,
       			      p_req_from in date,
			      p_req_to in date) is
--
l_proc        varchar2(72) := g_package||'check_primary_venue';
l_exists number;
--
-- cursor to perform check
--
cursor chk_primven is
select 1
from ota_resource_bookings rb,
     ota_events e,
     ota_offerings off
where e.event_id = rb.event_id
and off.offering_id = e.parent_offering_id			--bug 3494404
and ((rb.required_date_from  between
    p_req_from and p_req_to)
or  (rb.required_date_to between
    p_req_from and p_req_to))
and rb.primary_venue_flag = 'Y'
and rb.event_id = p_event_id
and rb.resource_booking_id <> nvl(p_resource_booking_id, -1);
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
IF p_prim_ven = 'Y' THEN
  open chk_primven;
  fetch chk_primven into l_exists;
  IF chk_primven%found THEN
    fnd_message.set_name('OTA','OTA_13273_TRB_PRIMARY_VENUE');
    close chk_primven;
    fnd_message.raise_error;
  END IF;
  close chk_primven;
END IF;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_primary_venue;

-- ---------------------------------------------------------------------
-- |--------------------< check_booking_conflict >-----------------------|
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Function returning Y if is another CONFIRMEDor Planned booking
--      for the resource is found
--
--
function check_booking_conflict(p_supplied_resource_id in number
                             ,p_required_date_from in Date
                             ,p_required_start_time in varchar2
                             ,p_required_date_to in Date
                             ,p_required_end_time in varchar2
			     ,p_timezone in varchar2
                             ,p_resource_booking_id in number
			     ,p_book_entire_period_flag in varchar2
                             )return varchar2 IS
--
l_proc        varchar2(72) := g_package||'check_booking_conflict';
l_exists number;
l_book_entire_period varchar2(1);



  l_resource_type varchar2(30);

  l_return_value varchar2(1) := 'N';

  cursor get_resource_type is
  select resource_type
  from   ota_suppliable_resources
  where  supplied_resource_id = p_supplied_resource_id;


-- For entire duration flag null or N
cursor double_booking is
select 1
from ota_resource_bookings trb
where trb.supplied_resource_id = p_supplied_resource_id
and   (
(p_required_date_from    <= trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone))
        and   p_required_date_to      >= trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
        and   nvl(p_required_start_time, '00:00') <= ota_timezone_util.convert_dateDT_time(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)
        and   nvl(p_required_end_time, '23:59') >= ota_timezone_util.convert_dateDT_time(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone)
)
/*or
(to_date( to_char(nvl(p_required_date_from,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
           || nvl(p_required_start_time, '00:00'),'YYYY/MM/DD HH24:MI')      <= ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)
and   to_date( to_char(nvl(p_required_date_to,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
           || nvl(p_required_end_time, '23:59'),'YYYY/MM/DD HH24:MI')      >= ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone)
)*/)
and  (p_resource_booking_id is null
 or (p_resource_booking_id is not null
 and p_resource_booking_id <> trb.resource_booking_id));



 Cursor csr_chk_date_overlap is
select Book_entire_period_flag,required_end_time,required_start_time,
required_date_from,required_date_to,timezone_code
from ota_resource_bookings trb
where trb.supplied_resource_id = p_supplied_resource_id
and    (
(p_required_date_from  between
trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
and
trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)))
or
(p_required_date_to  between
trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
and
trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)))
or
((p_required_date_from  <= trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone)))
and
(p_required_date_to  >= trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone))))
 )
--and   trb.status = 'C'
and  (p_resource_booking_id is null
 or (p_resource_booking_id is not null
 and p_resource_booking_id <> trb.resource_booking_id));



--
begin
hr_utility.set_location('Entering:'||l_proc,5);


--
 open get_resource_type;
 fetch get_resource_type into l_resource_type;
 close get_resource_type;

 if(l_resource_type = 'T' or l_resource_type = 'V') then


  open double_booking;
  fetch double_booking into l_exists;

  if double_booking%found then
  --
    close double_booking;
    l_return_value :='Y';
    return l_return_value;
  else
  close double_booking;

  for rec in csr_chk_date_overlap
    loop

  /*Fetch csr_chk_trainer_date_overlap into l_book_entire_period;
	if csr_chk_trainer_date_overlap%NotFound then
		close csr_chk_trainer_date_overlap;
		--No date overlap
		return FALSE;
	else
		close csr_chk_trainer_date_overlap;*/
		--Date overlap present
		-- Check new or existing either one is book enire period Y

		if ((p_required_date_from <> p_required_date_to)
        and (rec.required_date_from <> rec.required_date_to)) then
		if rec.book_entire_period_flag = 'Y' or p_book_entire_period_flag = 'Y'  then
		--check time overlap
		  if (
          (p_required_date_from  = trunc(ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone))
		  and nvl(p_required_start_time, '00:00') > ota_timezone_util.convert_dateDT_time(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone))
                or
          (p_required_date_to  = trunc(ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
                and   nvl(p_required_end_time, '23:59') < ota_timezone_util.convert_dateDT_time(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
              ) then

               l_return_value :='N';
                --return l_return_value;
              else
                l_return_value :='Y';
                return l_return_value;
              end if;

         end if;
--bug 5152139
	  elsif(
    (p_required_date_from = p_required_date_to and rec.book_entire_period_flag = 'Y')
        or (rec.required_date_from = rec.required_date_to and p_book_entire_period_flag = 'Y')
        ) then

			--since first cursor didn't give problem this means new and old record dates cannot be equal
			--and time
			if(
            (p_required_date_from = trunc(ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone)) and
             nvl(p_required_end_time, '23:59') < ota_timezone_util.convert_dateDT_time(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
            or
            (p_required_date_to = trunc(ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone)) and
            nvl(p_required_start_time, '00:00') > ota_timezone_util.convert_dateDT_time(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone)
            )
              ) then

           l_return_value :='N';


            else

            l_return_value :='Y';
                return l_return_value;
	    	end if;
	--bug 5116223
	elsif((p_required_date_from = p_required_date_to or rec.required_date_from = rec.required_date_to) and rec.timezone_code <> p_timezone  ) then
	  if(trunc(ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
	  <> trunc(ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone))) then
		if((to_date( to_char(nvl(p_required_date_from,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
			|| nvl(p_required_start_time, '00:00'),'YYYY/MM/DD HH24:MI')      <= ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone)
			and   to_date( to_char(nvl(p_required_date_to,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
			|| nvl(p_required_end_time, '23:59'),'YYYY/MM/DD HH24:MI')      >= ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
		  ) then
		l_return_value :='Y';
                return l_return_value;
		end if;
	  end if;
	end if;
    end loop;


  end if;
else
  return l_return_value;
end if; -- for 'T' or 'V'

  --close double_booking;
  return l_return_value;
--
hr_utility.set_location('Leaving:'||l_proc,10);

end check_booking_conflict;



-- ---------------------------------------------------------------------
-- |--------------------< is_booking_conflict >-----------------------|
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Function returning Y if is another CONFIRMEDor Planned booking
--      for the resource is found
--
--
function is_booking_conflict(p_supplied_resource_id in number
                             ,p_required_date_from in Date
                             ,p_required_start_time in varchar2
                             ,p_required_date_to in Date
                             ,p_required_end_time in varchar2
			     ,p_timezone in varchar2
                             ,p_target_resource_booking_id in number
			     ,p_book_entire_period_flag in varchar2
                             )return varchar2 IS
--
l_proc        varchar2(72) := g_package||'is_booking_conflict';
l_exists number;
l_book_entire_period varchar2(1);

/*p_required_date_from Date := to_date(param_required_date_from,g_date_format);
p_required_date_to Date := to_date(param_required_date_to,g_date_format);
p_required_start_time varchar2(50) := param_required_start_time;
p_required_end_time varchar2(50) := param_required_end_time;*/

  l_resource_type varchar2(30);

  l_return_value varchar2(1) := 'N';

  cursor get_resource_type is
  select resource_type
  from   ota_suppliable_resources
  where  supplied_resource_id = p_supplied_resource_id;


-- For entire duration flag null or N
cursor double_booking is
select 1
from ota_resource_bookings trb
where trb.supplied_resource_id = p_supplied_resource_id
and   (
(p_required_date_from    <= trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone))
        and   p_required_date_to      >= trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
        and   nvl(p_required_start_time, '00:00') <= ota_timezone_util.convert_dateDT_time(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)
        and   nvl(p_required_end_time, '23:59') >= ota_timezone_util.convert_dateDT_time(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone)
)
/*or
(to_date( to_char(nvl(p_required_date_from,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
           || nvl(p_required_start_time, '00:00'),'YYYY/MM/DD HH24:MI')      <= ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)
and   to_date( to_char(nvl(p_required_date_to,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
           || nvl(p_required_end_time, '23:59'),'YYYY/MM/DD HH24:MI')      >= ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone)
)*/)
 and trb.resource_booking_id = p_target_resource_booking_id;



 Cursor csr_chk_date_overlap is
select Book_entire_period_flag,required_end_time,required_start_time,
required_date_from,required_date_to,timezone_code
from ota_resource_bookings trb
where trb.supplied_resource_id = p_supplied_resource_id
and    (
(p_required_date_from  between
trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
and
trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)))
or
(p_required_date_to  between
trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
and
trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)))
or
((p_required_date_from  <= trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone)))
and
(p_required_date_to  >= trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone))))
 )
 and trb.resource_booking_id = p_target_resource_booking_id;



--
begin
hr_utility.set_location('Entering:'||l_proc,5);


--
 open get_resource_type;
 fetch get_resource_type into l_resource_type;
 close get_resource_type;

 if(l_resource_type = 'T' or l_resource_type = 'V') then


  open double_booking;
  fetch double_booking into l_exists;

  if double_booking%found then
  --
    close double_booking;
    l_return_value :='Y';
    return l_return_value;
  else
  close double_booking;

  for rec in csr_chk_date_overlap
    loop

  /*Fetch csr_chk_trainer_date_overlap into l_book_entire_period;
	if csr_chk_trainer_date_overlap%NotFound then
		close csr_chk_trainer_date_overlap;
		--No date overlap
		return FALSE;
	else
		close csr_chk_trainer_date_overlap;*/
		--Date overlap present
		-- Check new or existing either one is book enire period Y

		if ((p_required_date_from <> p_required_date_to)
        and (rec.required_date_from <> rec.required_date_to)) then
		if rec.book_entire_period_flag = 'Y' or p_book_entire_period_flag = 'Y'  then
		--check time overlap
		  if (
          (p_required_date_from  = trunc(ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone))
		  and nvl(p_required_start_time, '00:00') > ota_timezone_util.convert_dateDT_time(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone))
                or
          (p_required_date_to  = trunc(ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
                and   nvl(p_required_end_time, '23:59') < ota_timezone_util.convert_dateDT_time(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
              ) then

               l_return_value :='N';
                --return l_return_value;
              else
                l_return_value :='Y';
                return l_return_value;
              end if;

         end if;

	--bug 5152139
	  elsif(
    (p_required_date_from = p_required_date_to and rec.book_entire_period_flag = 'Y')
        or (rec.required_date_from = rec.required_date_to and p_book_entire_period_flag = 'Y')
        ) then

			--since first cursor didn't give problem this means new and old record dates cannot be equal
			--and time
			if(
            (p_required_date_from = trunc(ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone)) and
             nvl(p_required_end_time, '23:59') < ota_timezone_util.convert_dateDT_time(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
            or
            (p_required_date_to = trunc(ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone)) and
            nvl(p_required_start_time, '00:00') > ota_timezone_util.convert_dateDT_time(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone)
            )
              ) then

           l_return_value :='N';


            else

            l_return_value :='Y';
                return l_return_value;
	    	end if;
	--bug 5116223
	elsif((p_required_date_from = p_required_date_to or rec.required_date_from = rec.required_date_to )and rec.timezone_code <> p_timezone) then
	  if(trunc(ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
	  <> trunc(ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone))) then
		if((to_date( to_char(nvl(p_required_date_from,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
			|| nvl(p_required_start_time, '00:00'),'YYYY/MM/DD HH24:MI')      <= ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone)
			and   to_date( to_char(nvl(p_required_date_to,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
			|| nvl(p_required_end_time, '23:59'),'YYYY/MM/DD HH24:MI')      >= ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
		  ) then
		l_return_value :='Y';
                return l_return_value;
		end if;
	  end if;
	end if;
    end loop;


  end if;
else
  return l_return_value;
end if; -- for 'T' or 'V'

  --close double_booking;
  return l_return_value;
--
hr_utility.set_location('Leaving:'||l_proc,10);

end is_booking_conflict;


function check_SS_double_booking(p_supplied_resource_id in number
                             ,p_required_date_from in date
                             ,p_required_start_time in varchar2
                             ,p_required_date_to in date
                             ,p_required_end_time in varchar2
                             ,p_resource_booking_id in number
			     ,p_book_entire_period_flag in varchar2
			     ,p_timezone in varchar2
                             )return varchar2 IS

l_return_value varchar2(5):='N';
begin

if check_double_booking (p_supplied_resource_id
                                ,p_required_date_from
                                ,p_required_start_time
                                ,p_required_date_to
                                ,p_required_end_time
                                ,p_resource_booking_id
				,p_book_entire_period_flag
				,p_timezone ) then
         l_return_value := 'Y';
      end if;

      return l_return_value;
end check_SS_double_booking;
--

--
-- ---------------------------------------------------------------------
-- |--------------------< check_double_booking >-----------------------|
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Function returning TRUE is another CONFIRMED booking for the
--              resource is found
--
--
function check_double_booking(p_supplied_resource_id in number
                             ,p_required_date_from in date
                             ,p_required_start_time in varchar2
                             ,p_required_date_to in date
                             ,p_required_end_time in varchar2
                             ,p_resource_booking_id in number
			     ,p_book_entire_period_flag in varchar2
			     ,p_timezone in varchar2
                             ,p_last_res_bkng_id in number)return boolean IS
--
l_proc        varchar2(72) := g_package||'check_double_booking';
l_exists number;
l_book_entire_period varchar2(1);


  l_resource_type varchar2(30);

  cursor get_resource_type is
  select resource_type
  from   ota_suppliable_resources
  where  supplied_resource_id = p_supplied_resource_id;


-- For entire duration flag null or N
cursor double_booking is
select 1
from ota_resource_bookings trb
where trb.supplied_resource_id = p_supplied_resource_id
and   (
(p_required_date_from    <= trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone))
        and   p_required_date_to      >= trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
        and   nvl(p_required_start_time, '00:00') <= ota_timezone_util.convert_dateDT_time(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)
        and   nvl(p_required_end_time, '23:59') >= ota_timezone_util.convert_dateDT_time(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone)
)
/*or
(to_date( to_char(nvl(p_required_date_from,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
           || nvl(p_required_start_time, '00:00'),'YYYY/MM/DD HH24:MI')      <= ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)
and   to_date( to_char(nvl(p_required_date_to,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
           || nvl(p_required_end_time, '23:59'),'YYYY/MM/DD HH24:MI')      >= ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone)
)*/)
and   trb.status = 'C'
and  (p_resource_booking_id is null
 or (p_resource_booking_id is not null
 and p_resource_booking_id <> trb.resource_booking_id
 and trb.resource_booking_id > nvl(p_last_res_bkng_id,0)));

-- Modified to exclude forum and chat related bookings
-- For entire duration flag null or N
cursor trainer_double_booking is
select 1
from ota_resource_bookings trb
where trb.supplied_resource_id = p_supplied_resource_id
and   (
(p_required_date_from    <= trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone))
and   p_required_date_to      >= trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
and   nvl(p_required_start_time, '00:00') <= ota_timezone_util.convert_dateDT_time(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)
and   nvl(p_required_end_time, '23:59') >= ota_timezone_util.convert_dateDT_time(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
/*or
(to_date( to_char(nvl(p_required_date_from,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
           || nvl(p_required_start_time, '00:00'),'YYYY/MM/DD HH24:MI')      <= ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)
and   to_date( to_char(nvl(p_required_date_to,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
           || nvl(p_required_end_time, '23:59'),'YYYY/MM/DD HH24:MI')      >= ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
*/)
and   trb.status = 'C'
and   trb.chat_id is null
and   trb.forum_id is null
and  (p_resource_booking_id is null
 or (p_resource_booking_id is not null
 and p_resource_booking_id <> trb.resource_booking_id
 and trb.resource_booking_id > nvl(p_last_res_bkng_id,0)));
 --bug 5110895


 Cursor csr_chk_date_overlap is
select Book_entire_period_flag,required_end_time,required_start_time,
required_date_from,required_date_to,timezone_code
from ota_resource_bookings trb
where trb.supplied_resource_id = p_supplied_resource_id
and     p_required_date_from <= trunc (ota_timezone_util.convert_date
         (trb.required_date_to, nvl (trb.required_end_time, '23:59'),
         trb.timezone_code, p_timezone))
and p_required_date_to >= trunc (ota_timezone_util.convert_date
         (trb.required_date_from, nvl (trb.required_start_time, '00:00'),
         trb.timezone_code, p_timezone))
and   trb.status = 'C'
and  (p_resource_booking_id is null
 or (p_resource_booking_id is not null
 and p_resource_booking_id <> trb.resource_booking_id
 and trb.resource_booking_id > nvl(p_last_res_bkng_id,0)));


-- Modified to exclude forum and chat related bookings
 Cursor csr_chk_trainer_date_overlap is
select Book_entire_period_flag,required_end_time,required_start_time,
required_date_from,required_date_to,timezone_code
from ota_resource_bookings trb
where trb.supplied_resource_id = p_supplied_resource_id
and    (
(p_required_date_from  between
trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
and
trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)))
or
(p_required_date_to  between
trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone))
and
trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone)))
or
((p_required_date_from  <= trunc(ota_timezone_util.convert_date(trb.required_date_from,nvl(trb.required_start_time, '00:00'),trb.timezone_code,p_timezone)))
and
(p_required_date_to  >= trunc(ota_timezone_util.convert_date(trb.required_date_to,nvl(trb.required_end_time, '23:59'),trb.timezone_code,p_timezone))))
 )
and   trb.status = 'C'
and   trb.chat_id is null
and   trb.forum_id is null
and  (p_resource_booking_id is null
 or (p_resource_booking_id is not null
 and p_resource_booking_id <> trb.resource_booking_id
 and trb.resource_booking_id > nvl(p_last_res_bkng_id,0)));


--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
 open get_resource_type;
 fetch get_resource_type into l_resource_type;
 close get_resource_type;

 if (l_resource_type = 'T') then

  open trainer_double_booking;
  fetch trainer_double_booking into l_exists;

  if trainer_double_booking%found then
  --
    close trainer_double_booking;
    return TRUE;
  else
  close trainer_double_booking;

  for trainer_rec in csr_chk_trainer_date_overlap
    loop

  /*Fetch csr_chk_trainer_date_overlap into l_book_entire_period;
	if csr_chk_trainer_date_overlap%NotFound then
		close csr_chk_trainer_date_overlap;
		--No date overlap
		return FALSE;
	else
		close csr_chk_trainer_date_overlap;*/
		--Date overlap present
		-- Check new or existing either one is book enire period Y

		if ((p_required_date_from <> p_required_date_to)
        and (trainer_rec.required_date_from <> trainer_rec.required_date_to)) then
		if trainer_rec.book_entire_period_flag = 'Y' or p_book_entire_period_flag = 'Y'  then
		--check time overlap
		  if (
          (p_required_date_from  = trunc(ota_timezone_util.convert_date(trainer_rec.required_date_to,nvl(trainer_rec.required_end_time, '23:59'),trainer_rec.timezone_code,p_timezone))
		  and nvl(p_required_start_time, '00:00') > ota_timezone_util.convert_dateDT_time(trainer_rec.required_date_to,nvl(trainer_rec.required_end_time, '23:59'),trainer_rec.timezone_code,p_timezone))
                or
          (p_required_date_to  = trunc(ota_timezone_util.convert_date(trainer_rec.required_date_from,nvl(trainer_rec.required_start_time, '00:00'),trainer_rec.timezone_code,p_timezone))
                and   nvl(p_required_end_time, '23:59') < ota_timezone_util.convert_dateDT_time(trainer_rec.required_date_from,nvl(trainer_rec.required_start_time, '00:00'),trainer_rec.timezone_code,p_timezone))
              ) then

              return false;
              else
                return TRUE ;
              end if;

         end if;
--bug 5152139
	elsif(
    (p_required_date_from = p_required_date_to and trainer_rec.book_entire_period_flag = 'Y')
        or (trainer_rec.required_date_from = trainer_rec.required_date_to and p_book_entire_period_flag = 'Y')
        ) then

			--since first cursor didn't give problem this means new and old record dates cannot be equal
			--and time
			if(
            (p_required_date_from = trunc(ota_timezone_util.convert_date(trainer_rec.required_date_from,nvl(trainer_rec.required_start_time, '00:00'),trainer_rec.timezone_code,p_timezone)) and
             nvl(p_required_end_time, '23:59') < ota_timezone_util.convert_dateDT_time(trainer_rec.required_date_from,nvl(trainer_rec.required_start_time, '00:00'),trainer_rec.timezone_code,p_timezone))
            or
            (p_required_date_to = trunc(ota_timezone_util.convert_date(trainer_rec.required_date_to,nvl(trainer_rec.required_end_time, '23:59'),trainer_rec.timezone_code,p_timezone)) and
            nvl(p_required_start_time, '00:00') > ota_timezone_util.convert_dateDT_time(trainer_rec.required_date_to,nvl(trainer_rec.required_end_time, '23:59'),trainer_rec.timezone_code,p_timezone)
            )
              ) then

            return false;

            else

            return True;
	    	end if;
--bug 5116223
	elsif((p_required_date_from = p_required_date_to or trainer_rec.required_date_from = trainer_rec.required_date_to ) and trainer_rec.timezone_code <> p_timezone)then
	  if(trunc(ota_timezone_util.convert_date(trainer_rec.required_date_from,nvl(trainer_rec.required_start_time, '00:00'),trainer_rec.timezone_code,p_timezone))
	  <> trunc(ota_timezone_util.convert_date(trainer_rec.required_date_to,nvl(trainer_rec.required_end_time, '23:59'),trainer_rec.timezone_code,p_timezone))) then
		if((to_date( to_char(nvl(p_required_date_from,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
			|| nvl(p_required_start_time, '00:00'),'YYYY/MM/DD HH24:MI')      <= ota_timezone_util.convert_date(trainer_rec.required_date_to,nvl(trainer_rec.required_end_time, '23:59'),trainer_rec.timezone_code,p_timezone)
			and   to_date( to_char(nvl(p_required_date_to,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
			|| nvl(p_required_end_time, '23:59'),'YYYY/MM/DD HH24:MI')      >= ota_timezone_util.convert_date(trainer_rec.required_date_from,nvl(trainer_rec.required_start_time, '00:00'),trainer_rec.timezone_code,p_timezone))
		  ) then
		 return true;
		end if;
	  end if;
	end if;
    end loop;

  end if;

 else

  open double_booking;
  fetch double_booking into l_exists;

  if double_booking%found then
  --
    close double_booking;
    return TRUE;
  else
  close double_booking;
  -- not sure if still conflict or not depending on book_entire_period_flag of existing or new record

  --get date overlap record

  for rec in csr_chk_date_overlap
  loop

  /*Fetch csr_chk_trainer_date_overlap into l_book_entire_period;
	if csr_chk_trainer_date_overlap%NotFound then
		close csr_chk_trainer_date_overlap;
		--No date overlap
		return FALSE;
	else
		close csr_chk_trainer_date_overlap;*/
		--Date overlap present
		-- Check new or existing either one is book enire period Y

	/*	if ((p_required_date_from <> p_required_date_to)
        and (rec.required_date_from <> rec.required_date_to)) then*/
		if rec.book_entire_period_flag = 'Y' or p_book_entire_period_flag = 'Y'  then
		--check time overlap
		  if (
          (p_required_date_from  = trunc(ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone))
		  and nvl(p_required_start_time, '00:00') > ota_timezone_util.convert_dateDT_time(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone))
                or
          (p_required_date_to  = trunc(ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
                and   nvl(p_required_end_time, '23:59') < ota_timezone_util.convert_dateDT_time(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
              ) then

              return false;
              else
                return TRUE ;
              end if;

         elsif(
    (p_required_date_from = p_required_date_to and rec.book_entire_period_flag = 'Y')
        or (rec.required_date_from = rec.required_date_to and p_book_entire_period_flag = 'Y')
        ) then

			--since first cursor didn't give problem this means new and old record dates cannot be equal
			--and time
			if(
            (p_required_date_from = trunc(ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone)) and
             nvl(p_required_end_time, '23:59') < ota_timezone_util.convert_dateDT_time(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
            or
            (p_required_date_to = trunc(ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone)) and
            nvl(p_required_start_time, '00:00') > ota_timezone_util.convert_dateDT_time(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone)
            )
              ) then

            return false;

            else

            return True;
	    	end if;
	--bug 5116223
	elsif((p_required_date_from = p_required_date_to or rec.required_date_from = rec.required_date_to) and rec.timezone_code <> p_timezone  ) then
	  if(trunc(ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
	  <> trunc(ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone))) then
		if((to_date( to_char(nvl(p_required_date_from,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
			|| nvl(p_required_start_time, '00:00'),'YYYY/MM/DD HH24:MI')      <= ota_timezone_util.convert_date(rec.required_date_to,nvl(rec.required_end_time, '23:59'),rec.timezone_code,p_timezone)
			and   to_date( to_char(nvl(p_required_date_to,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' '
			|| nvl(p_required_end_time, '23:59'),'YYYY/MM/DD HH24:MI')      >= ota_timezone_util.convert_date(rec.required_date_from,nvl(rec.required_start_time, '00:00'),rec.timezone_code,p_timezone))
		  ) then
		 return true;
		end if;
	  end if;
	end if;
    end loop;

  end if;

 end if;


  --close double_booking;
  return FALSE;
--
hr_utility.set_location('Leaving:'||l_proc,10);

end check_double_booking;

--
-- ---------------------------------------------------------------------
-- -------------------< check_trainer_venue_book >----------------------
-- ---------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check that Trainers and Venues cannot be double booked
--              if Confirmed
--
--
procedure check_trainer_venue_book
                             (p_supplied_resource_id in number
                             ,p_required_date_from in date
                             ,p_required_start_time in varchar2
                             ,p_required_date_to in date
                             ,p_required_end_time in varchar2
                             ,p_resource_booking_id in number
			     ,p_book_entire_period_flag in varchar2
			     ,p_timezone in varchar2
			     ) IS
--
  cursor get_resource_type is
  select resource_type
  from   ota_suppliable_resources
  where  supplied_resource_id = p_supplied_resource_id;
  --
  l_resource_type varchar2(30);
l_proc        varchar2(72) := g_package||'check_trainer_venue_book';
--
begin
--
   open get_resource_type;
   fetch get_resource_type into l_resource_type;
   close get_resource_type;
   --
   if l_resource_type in ('T','V') then
      if check_double_booking   (p_supplied_resource_id
                                ,p_required_date_from
                                ,p_required_start_time
                                ,p_required_date_to
                                ,p_required_end_time
                                ,p_resource_booking_id
				,p_book_entire_period_flag
				,p_timezone
				 ) then
         fnd_message.set_name('OTA','OTA_13395_TRB_RES_DOUBLEBOOK');
         fnd_message.raise_error;
      end if;
   end if;
--
end check_trainer_venue_book;
-- ---------------------------------------------------------------------
-- |------------------< deduct_consumable_stock_check >-----------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Check that the quantity required can be deducted from
--              the stock level on SUPPLIABLE_RESOURCES without causing
--              a negative stock level.
--
--              returns True if stock levels OK and false if not.
--
/* function deduct_consumable_stock_check(p_supplied_resource_id in number,
				       p_quantity in number)
return boolean is
--
l_proc        varchar2(72) := g_package||'deduct_consumable_stock';
l_sign number;
l_return boolean;
--
-- cursor to perform check on consumable stock levels
--
cursor chk_slevels is
select sign(sr.stock - p_quantity)
from ota_suppliable_resources sr
where sr.supplied_resource_id = p_supplied_resource_id
and sr.consumable_flag = 'Y';
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_slevels;
fetch chk_slevels into l_sign;
IF chk_slevels%found THEN
  IF l_sign < 0 THEN
    l_return := FALSE;
  ELSE l_return := TRUE;
  END IF;
END IF;
close chk_slevels;
return (l_return);
--
hr_utility.set_location('Leaving:'||l_proc,10);
end deduct_consumable_stock_check;  */
--
-- ---------------------------------------------------------------------
-- |---------------------< deduct_consumable_stock >--------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Deduct the quantity of a consumable resource booked from
--              the stock level on SUPPLIABLE_RESOURCES.
--
/* procedure deduct_consumable_stock(p_supplied_resource_id in number,
				  p_quantity in number) is
--
l_proc        varchar2(72) := g_package||'deduct_consumable_stock';
l_new_stock number;
--
-- cursor to calculate third party update to OTA_SUPPLIABLE_RESOURCES
--
cursor calc_newstock is
select tsr.stock - p_quantity
from ota_suppliable_resources tsr
where tsr.supplied_resource_id = p_supplied_resource_id
and tsr.consumable_flag = 'Y';
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open calc_newstock;
fetch calc_newstock into l_new_stock;
close calc_newstock;
--
-- perform update
--
update ota_suppliable_resources
set stock = l_new_stock
where supplied_resource_id = p_supplied_resource_id;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end deduct_consumable_stock;   */
--
-- ---------------------------------------------------------------------
-- |---------------------< check_if_tfl_exists >------------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: If finance lines exist for the booking it may not be
--              deleted.
--
procedure check_if_tfl_exists(p_resource_booking_id in number) is
--
l_proc        varchar2(72) := g_package||'check_if_tfl_exists';
l_exists number;
--
-- cursor to perform check
--
cursor chk_tfl is
select 1
from ota_finance_lines
where resource_booking_id = p_resource_booking_id;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_tfl;
fetch chk_tfl into l_exists;
IF chk_tfl%found THEN
  fnd_message.set_name('OTA','OTA_13274_TRB_TFL_EXIST');
  close chk_tfl;
  fnd_message.raise_error;
ELSE close chk_tfl;
END IF;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_if_tfl_exists;
--
-- -------------------------------------------------------------------
-- |-------------------< check_event_type >---------------------------
-- -------------------------------------------------------------------
-- PUBLIC
-- Description: Resource bookings may be made for the following event
--              types: SCEDULED, SESSION, PROGRAMME MEMBER, DEVELOPMENT
--
procedure check_event_type(p_event_id in number) is
--
l_proc varchar2(72) := g_package||'check_event_type';
l_exists number;
--
-- cursor to perform check on event type
--
cursor chk_type is
select 1
from ota_events
where event_id = p_event_id
and event_type in
  ('SCHEDULED','SESSION','PROGRAMME MEMBER','DEVELOPMENT','SELFPACED');
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open chk_type;
fetch chk_type into l_exists;
IF chk_type%notfound THEN
  close chk_type;
  fnd_message.set_name('OTA','OTA_13275_TRB_WRONG_EVENT_TYPE');
  fnd_message.raise_error;
ELSE close chk_type;
END IF;
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_event_type;
--
-- -------------------------------------------------------------------
-- |-------------------< check_update_quant_del >---------------------
-- -------------------------------------------------------------------
-- PUBLIC
-- Description: If the Quantity or Delegates_per_unit fields are upated
--              then a check needs to made to ensure that their sum is
--              not exceeded by the number of resource allocations made
--              to the booking.
--
--               Returns TRUE if no. of allocations is ok or the
--               calculation cannot be performed due to one of the
--               variables being null. Returns FALSE if no. of
--               allocations not ok.
--
function check_update_quant_del(p_resource_booking_id in number,
			        p_quantity in number,
			        p_del_per_unit in number)
return boolean is
--
l_proc varchar2(72) := g_package||'check_update_quant_del';
l_count number;
l_calc number;
l_return boolean;
--
-- cursor to perform count
--
cursor get_count is
select count(*)
from ota_resource_allocations
where equipment_resource_booking_id = p_resource_booking_id;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
IF p_quantity is not null AND p_del_per_unit is not null THEN
  l_calc := p_quantity * p_del_per_unit;
  open get_count;
  fetch get_count into l_count;
  close get_count;
  IF l_count <= l_calc THEN
    l_return := TRUE;
  ELSE l_return := FALSE;
  END IF;
ELSE l_return := TRUE;
END IF;
return (l_return);
--
hr_utility.set_location('Leaving:'||l_proc,10);
end check_update_quant_del;
--
-- ------------------------------------------------------------------
-- |---------------------< get_required_resources >------------------
-- ------------------------------------------------------------------
-- Description: Get the mandatory resources defined for an event

Procedure get_required_resources(p_activity_version_id in number,
				 p_event_id in number,
				 p_date_booking_placed in date,
				 p_event_start_date in date,
				 p_event_end_date in date) is
--
l_resource_booking_id number(38);
l_ovn  number(38);
l_finance_line_id number(38);
l_finance_line_ovn number(38);
l_proc  varchar2(72) := g_package||'get_required_resources';
l_supplied_resource_id  number(38);
l_quantity number(38);
l_event_timezone varchar2(30);
--
Cursor get_resources is
Select
       rud.supplied_resource_id,
       rud.quantity
From
      ota_resource_usages rud
Where rud.offering_id = (select evt.parent_offering_id from ota_events evt 	-- bug 3494404
				where evt.event_id = p_event_id)		-- bug 3494404
and   p_event_start_date between
        nvl(rud.start_date, hr_api.g_sot) and nvl(rud.end_date, hr_api.g_eot)
and   rud.supplied_resource_id is not null
and   rud.required_flag = 'Y'
and   not exists
       	 (Select null
	  From   ota_resource_bookings trb
          Where
	     trb.supplied_resource_id = rud.supplied_resource_id
	     and trb.event_id = p_event_id);
--

Cursor get_event_timezone is                         --Bug#5126185
select timezone
from ota_events
where event_id=p_event_id;

--
Begin
--
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  Open get_resources;
  --
  Loop
  --
     Fetch get_resources into l_supplied_resource_id,
		              l_quantity;
     --
      Exit when get_resources%notfound or get_resources%notfound is null;
      open get_event_timezone;
      fetch get_event_timezone into l_event_timezone;
      close get_event_timezone;

	-- bug 3891115
	ota_utility.ignore_dff_validation('OTA_RESOURCE_BOOKINGS');
      --
      ota_resource_booking.ins(p_resource_booking_id => l_resource_booking_id,
			       p_supplied_resource_id => l_supplied_resource_id,
			       p_event_id => p_event_id,
			       p_date_booking_placed => p_date_booking_placed,
			       p_object_version_number => l_ovn,
			       p_status => 'P',
			       p_quantity => l_quantity,
			       p_required_date_from => p_event_start_date,
			       p_required_date_to => p_event_end_date,
			       p_primary_venue_flag => 'N',
			       p_finance_line_id => l_finance_line_id,
			       p_finance_line_ovn => l_finance_line_ovn,
			       p_booking_person_id => fnd_profile.value('USER_ID'),
			       p_display_to_learner_flag => 'Y',
			       p_book_entire_period_flag => 'Y',
			       p_timezone_code =>l_event_timezone                      --Bug#5126185
			       );
   End Loop;
   Close get_resources;
   --
   commit;

hr_utility.set_location('Leaving:'||l_proc,10);
end get_required_resources;

-- -------------------------------------------------------------------
-- |----------------------< get_evt_defaults >------------------------
-- -------------------------------------------------------------------
-- PUBLIC
procedure get_evt_defaults(p_event_id in number,
			   p_event_title in out nocopy varchar2,
			   p_event_start_date in out nocopy date,
			   p_event_end_date in out nocopy date,
			   p_event_start_time in out nocopy varchar2,
			   p_event_end_time in out nocopy varchar2,
			   p_curr_code in out nocopy varchar2,
			   p_curr_meaning in out nocopy varchar2) is
--
l_proc varchar2(72) := g_package||'get_evt_defaults';
--
-- cursor to get defaults
--
cursor get_defs is
select evt.title,
       evt.course_start_date,
       evt.course_end_date,
       evt.course_start_time,
       evt.course_end_time,
       evt.currency_code,
       fnd.name
from ota_events_vl evt, -- MLS change _vl added
     fnd_currencies_vl fnd
where evt.event_id = p_event_id
and fnd.currency_code = evt.currency_code;
--
begin
hr_utility.set_location('Entering:'||l_proc,5);
--
open get_defs;
fetch get_defs into p_event_title,
		    p_event_start_date,
		    p_event_end_date,
		    p_event_start_time,
		    p_event_end_time,
		    p_curr_code,
		    p_curr_meaning;
close get_defs;
--
--
hr_utility.set_location('Leaving:'||l_proc,10);
end get_evt_defaults;

-- ---------------------------------------------------------------------
-- |--------------------< check_start_end_times >-----------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Start time must be before end time.
--
procedure check_start_end_times(p_start_time in varchar2,
                                p_end_time in varchar2) is
--
l_proc        varchar2(72) := g_package||'check_start_end_times';
--
begin
--
hr_utility.set_location('Entering:'||l_proc,5);
--
  if to_number(substr(p_start_time, 1, 2)) >
     to_number(substr(p_end_time, 1, 2))
  or (to_number(substr(p_start_time, 1, 2)) =
        to_number(substr(p_end_time, 1, 2))
  and   to_number(substr(p_start_time, 4, 2)) >
        to_number(substr(p_end_time, 4, 2))) then
  --
    fnd_message.set_name('OTA','OTA_13640_TRB_START_END_TIMES');
    fnd_message.raise_error;
  --
  end if;
--
hr_utility.set_location('Leaving:'||l_proc,10);
--
end check_start_end_times;
--
----------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- |--------------------< check_trainer_competence >--------------------
-- ---------------------------------------------------------------------
-- PUBLIC
-- Description: Check trainer competence match the activity.
--
procedure check_trainer_competence (p_event_id in number,
                                    p_supplied_resource_id in number,
				    p_required_date_from IN DATE,
				    p_required_date_to   IN DATE,
				    p_end_of_time IN DATE,
						p_warn   out nocopy boolean) is
--
l_proc        varchar2(72) := g_package|| 'check_trainer_competence';
--
l_resource_type   varchar2(1);
l_trainer_id  number;
l_competence  varchar2(3000);
l_person_id  number;
l_event_type  ota_events.event_type%type;
l_parent_event ota_events.event_id%type;
l_event_id  ota_events.event_id%type;
--l_language_id ota_events.language_id%type; -- 2733966
l_competence_id per_competence_elements.competence_id%type;
l_proficiency_level_id per_competence_elements.proficiency_level_id%type;
l_step_value  number := null;
l_language_code ota_offerings.language_code%type;

cursor c_resource
IS
SELECT resource_type, trainer_id
FROM ota_suppliable_resources
WHERE supplied_resource_id = p_supplied_resource_id ;

Cursor
C_Trainer_comp (p_event_id in number)
IS
SELECT pce.competence_id ,
       nvl(pce.proficiency_level_id,0) proficiency_level_id ,
       nvl(rat.step_value,0) step_value
FROM per_competence_elements pce, per_rating_levels rat
WHERE  nvl(pce.effective_date_from, p_required_date_from ) <=  p_required_date_from  	--bug 3332972
   AND nvl(pce.effective_date_to,p_required_date_to)  >= p_required_date_to		--bug 3332972
   AND rat.rating_level_id = pce.proficiency_level_id
   AND pce.type = 'OTA_OFFERING'						        --bug 3494404
   AND pce.Object_id in (
SELECT parent_offering_id								--bug 3494404
FROM ota_events
WHERE event_id = p_event_id);

Cursor
c_event_type
IS
SELECT ev.event_type,ev.parent_event_id ,off.language_code
FROM
OTA_EVENTS ev,
OTA_OFFERINGS_VL off
WHERE ev.EVENT_ID = p_event_id
AND ev.parent_offering_id = off.offering_id;

Cursor
c_event_lang (p_event_id number)
IS
select off.language_code
From OTA_EVENTS ev,
OTA_OFFERINGS_VL off
WHERE EVENT_ID = p_event_id
AND ev.parent_offering_id = off.offering_id;

cursor c_comp_lang(p_language_code in varchar2)
IS
Select ocl.competence_id,
nvl(ocl.min_proficiency_level_id,0) min_proficiency_level_id,
nvl(rat.step_value,0)  step_value
From ota_competence_languages ocl,
     per_rating_levels rat
Where
ocl.language_code = p_language_code and
ocl.business_group_id = ota_general.get_business_group_id and
nvl(rat.rating_level_id,0) = nvl(ocl.min_proficiency_level_id,0);


cursor c_wo_level(p_language_code in varchar2)
IS
Select ocl.competence_id
From ota_competence_languages ocl
Where
ocl.language_code = p_language_code and
ocl.business_group_id = ota_general.get_business_group_id;


begin
--
hr_utility.set_location('Entering:'||l_proc,5);
p_warn := false;
IF p_event_id is not null then
 For a in c_resource LOOP
    l_resource_type := a.resource_type;
    l_trainer_id := a.trainer_id;
 end loop ;

 For event in c_event_type LOOP
     l_event_type := event.event_type;
     l_parent_event := event.parent_event_id;
     l_language_code := event.language_code;
 end loop;

 If l_resource_type = 'T' then
    hr_utility.set_location('Entering:'||l_proc,10);
    if l_parent_event is not null and
       l_event_type = 'SESSION'  then
       l_event_id := l_parent_event;

       For evt_lang in c_event_lang(l_event_id)
       Loop
         l_language_code := evt_lang.language_code;
       End Loop;

    else
       l_event_id := p_event_id;

    end if;

   if l_trainer_id is not null then
    For b in c_trainer_comp(l_event_id)
           LOOP
	     if l_competence is null then
                l_competence := ' select pce.person_id from per_competence_elements pce ,' ||
                                ' per_rating_levels rat  '||
                                ' where ' ||
                                ' pce.competence_id = '||b.competence_id ||
                                ' and rat.rating_level_id = pce.proficiency_level_id ' ||
                                ' and pce.person_id = :person_id ' ||
				' and pce.effective_date_from <= '''||p_required_date_from||
				''' and NVL(pce.effective_date_to,'''||p_end_of_time||''') >= '''||p_required_date_to||
					  ''' and nvl(rat.step_value,0) >= '|| b.step_value;

           else

                l_competence := l_competence || ' AND ' ||
                                ' pce.person_id in ('||
                                ' select pce.person_id from per_competence_elements pce , '||
                                ' per_rating_levels rat ' ||
 				        ' where' ||
                                ' pce.competence_id = '||b.competence_id ||
				' and pce.effective_date_from <= '''||p_required_date_from||
				''' and NVL(pce.effective_date_to,'''||p_end_of_time||''') >= '''||p_required_date_to||
					  ''' and rat.rating_level_id = pce.proficiency_level_id ' ||
  					  ' and nvl(rat.step_value,0) >= '|| b.step_value || ')';

           end if;

           end loop;


     if l_language_code is not null then

	    For lang_comp in c_comp_lang(l_language_code)
           LOOP
	        if l_competence is null then
                l_competence := ' select pce.person_id from per_competence_elements pce, '||
					  ' per_rating_levels rat ' ||
					  ' where' ||
                                ' pce.competence_id = '||lang_comp.competence_id ||
				' and pce.effective_date_from <= '''||p_required_date_from||
				''' and NVL(pce.effective_date_to,'''||p_end_of_time||''') >= '''||p_required_date_to||
					  ''' and rat.rating_level_id = pce.proficiency_level_id ' ||
                                ' and pce.person_id = :person_id ' ||
					  ' and nvl(rat.step_value,0) >= '|| lang_comp.step_value ;
				--	  ' and nvl(proficiency_level_id,0) = '|| lang_comp.min_proficiency_level_id;
 	          l_step_value := lang_comp.step_value ;
           else

                l_competence := l_competence || ' AND ' ||
                                ' pce.person_id in ('||
                                ' select person_id from per_competence_elements pce , '||
					  ' per_rating_levels rat ' ||
					  ' where' ||
                                ' pce.competence_id = '||lang_comp.competence_id ||
				' and pce.effective_date_from <= '''||p_required_date_from||
				''' and NVL(pce.effective_date_to,'''||p_end_of_time||''') >= '''||p_required_date_to||
					 ''' and rat.rating_level_id = pce.proficiency_level_id ' ||
          				  ' and nvl(rat.step_value,0) >= '|| lang_comp.step_value || ')';
  				--	  ' and nvl(proficiency_level_id,0) = '|| lang_comp.min_proficiency_level_id || ')';


                l_step_value := lang_comp.step_value ;
           end if;

           END LOOP;


           if l_step_value is null then

              For e in c_wo_level(l_language_code)
           	  LOOP
	     	   if l_competence is null then
                  l_competence := ' select pce.person_id from per_competence_elements pce ' ||
                                ' where ' ||
                                ' pce.competence_id = '||e.competence_id ||
				' and pce.effective_date_from <= '''||p_required_date_from||
				''' and NVL(pce.effective_date_to,'''||p_end_of_time||''') >= '''||p_required_date_to||
                                ''' and pce.person_id = :person_id ' ;


               else

                l_competence := l_competence || ' AND ' ||
                                ' pce.person_id in ('||
                                ' select pce.person_id from per_competence_elements pce '||
 				        ' where' ||
				' pce.effective_date_from <= '''||p_required_date_from||
				''' and NVL(pce.effective_date_to,'''||p_end_of_time||''') >= '''||p_required_date_to||
                                ''' and pce.competence_id = '||e.competence_id || ')';

               end if;

             end loop;


           end if;

       end if;
     IF l_competence is not null then
         hr_utility.set_location('Entering:'||l_proc,15);

        BEGIN


  	         execute immediate l_competence
          		 into l_person_id
         		 using l_trainer_id;
          		 EXCEPTION WHEN NO_DATA_FOUND Then
                   p_warn := TRUE;
        END;
     ELSE
 	 p_warn := FALSE;  --Bug 2039862. Added Else clause.
     END IF;
   else
       -- Bug 2039862. Modified the return value of p_warn.
       --      p_warn := TRUE;
       p_warn := FALSE;
   end if;
 end if;
end if;
hr_utility.set_location('leaving:'||l_proc,20);
end check_trainer_competence;

end ota_trb_api_procedures;

/
