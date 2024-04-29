--------------------------------------------------------
--  DDL for Package Body OTA_EVT_API_UPD2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EVT_API_UPD2" as
/* $Header: otevt02t.pkb 120.6.12010000.2 2010/02/09 06:20:36 pekasi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ota_evt_api_upd2.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Check Status Change >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Check the delegate booking Status when Updating.
--
--
procedure Check_Status_Change(p_event_id in number
			     ,p_event_status in out nocopy varchar2
			     ,p_booking_status_type_id in number
			     ,p_maximum_attendees in number) is
--
-- Bug 3493695
   CURSOR c_attended_enr IS
   SELECT null
     FROM ota_delegate_bookings odb
    WHERE event_id = p_event_id AND
          booking_status_type_id IN
          (SELECT booking_status_type_id
             FROM ota_booking_status_types
            WHERE type = 'A');

  l_att_enr_exists              VARCHAR2(1);
-- Bug 3493695
  l_booking_status varchar2(30) := ota_tdb_bus.booking_status_type(
					p_booking_status_type_id);
  l_event_rec			ota_evt_shd.g_rec_type;
  l_event_exists		boolean;
  l_total_places		number;

--
  l_proc 	varchar2(72) := g_package||'check_status_change';
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get Event Record
  --
    ota_evt_shd.get_event_details (p_event_id,
                                 l_event_rec,
                                 l_event_exists);
  --
  -- Check event status change for No change.
  --
  if l_event_rec.event_status = p_event_status then
     fnd_message.set_name('OTA','OTA_13537_EVT_SAME_STATUS');
     fnd_message.raise_error;
  end if;
  --
  -- Check event status change for Full Events.
  --
  if p_event_status = 'F' then
     fnd_message.set_name('OTA','OTA_13515_EVT_STATUS_F');
     fnd_message.raise_error;
  end if;
  --
  -- Cannot set a full event to Normal via change status.
  --
  if p_event_status = 'N'and l_event_rec.event_status = 'F' then
     fnd_message.set_name('OTA','OTA_13556_EVT_NORMAL_STATUS');
     fnd_message.raise_error;
  end if;
  --
  -- Check enrollment status change for Planned Events.
  --
  if p_event_status in ('P') and l_booking_status not in ('W') then
     fnd_message.set_name('OTA','OTA_13516_EVT_STATUS_P');
     fnd_message.raise_error;
  end if;
  --
  -- Check enrollment status change for Cancelled or Closed Events.
  --
  if p_event_status in ('A','C') and l_booking_status not in ('C') then
     fnd_message.set_name('OTA','OTA_13517_EVT_STATUS_AC');
     fnd_message.raise_error;
  end if;

  --Bug 3493695
  -- Check if there are any attended enrollments for a class being cancelled
  IF p_event_status = 'A' THEN
     OPEN c_attended_enr;
    FETCH c_attended_enr INTO l_att_enr_exists;
       IF c_attended_enr%FOUND THEN
          CLOSE c_attended_enr;
          fnd_message.set_name('OTA','OTA_13067_EVT_ATT_ENR_EXISTS');
          fnd_message.raise_error;
      END IF;
    CLOSE c_attended_enr;
  END IF;
  -- Bug 3493695

  --
  -- If Status Changed to Normal and Max Attendees = total Places taken
  -- Then reset the Event Status to Full.  Would only apply if changing
  -- Event Status from Closed to Normal.
  --
     if p_event_status in ('N') and p_maximum_attendees is not null then
       l_total_places := ota_evt_bus2.get_total_places('ALL',p_event_id);
       if l_total_places = p_maximum_attendees then
         p_event_status := 'F';
       end if;
     end if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end Check_Status_Change;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Check Maximum Attendees >---------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Check maximum attendees is not null and resent the event status
--              accordingly.
--
--
procedure Check_Maximum_Attendees(p_maximum_attendees in number,
				  p_event_status in out nocopy varchar2,
				  p_old_max_attendees in number,
				  p_event_id in number) is
--
  l_total_places number;
  l_proc 	 varchar2(72) := g_package||'check_maximum_attendees';


  l_no_of_waitlist_candidate number;

cursor  c_check_waitlist_candidates is
select  count(*)
from    ota_delegate_bookings odb
where   event_id = p_event_id and
        booking_status_type_id in
        (select booking_status_type_id
         from   ota_booking_status_types
         where  type = 'W');

--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
    if p_maximum_attendees is null then
     --Bug 6640334/6705591:Admin should be able to nullify the maximum attendees set previously.
          --As maximum attendees is set to null,the class status is changed to Normal,if it was Full previously.
          /*fnd_message.set_name('OTA','OTA_13553_MAND_MAX_ATTENDEES');
          fnd_message.raise_error;*/
          if p_event_status = 'F' then
             p_event_status := 'N';
          end if;
    else

     if p_event_status in ('F','N') then
      l_total_places := ota_evt_bus2.get_total_places('ALL',p_event_id);
      if (p_maximum_attendees > p_old_max_attendees) and (l_total_places < p_maximum_attendees)
        and (p_event_status = 'F') then

-- *** Check if total places > max attendees + wait list then change the status to 'N' else 'F'

         open  c_check_waitlist_candidates;
         fetch c_check_waitlist_candidates into l_no_of_waitlist_candidate;
         if c_check_waitlist_candidates%notfound then
	        l_no_of_waitlist_candidate := 0;
	    end if;
         close c_check_waitlist_candidates;
/* Start Bug 1712445 */
         if  p_maximum_attendees  <= l_total_places + l_no_of_waitlist_candidate then
           if ota_evt_shd.g_old_rec.maximum_internal_attendees is null then
	        	p_event_status := 'F';
            else
               p_event_status := 'N';

            end if;
         else
	     	p_event_status := 'N';
         end if;
/* End of Bug 1712445 */
-- ***
       elsif (p_maximum_attendees = l_total_places) and (p_event_status = 'N') then
        p_event_status := 'F';
      end if;
     end if;
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end Check_Maximum_Attendees;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Process Event Change >------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Update enrollments for the given Event.
--		The process will include the updating of the booking status, finance
--		lines of enrollments for the given Event.
--
procedure Process_Event_Change(p_event_id in number
			      ,p_event_status in varchar2
			      ,p_update_finance_line in varchar2 default 'N'
			      ,p_booking_status_type_id in varchar2 default null
			      ,p_date_status_changed in date)  is

l_daemon_flag varchar2(1);
l_daemon_type varchar2(1);
l_booking_status varchar2(1);
--
--
cursor  c_get_event_enrollments is
select  tdb.booking_id, tdb.object_version_number, fl.object_version_number tfl_object_version_number,
         fl.finance_line_id,
        date_booking_placed, line_id,org_id,daemon_flag,daemon_type, tdb.booking_status_type_id,
	tdb.delegate_person_id
from    ota_delegate_bookings tdb
,	ota_booking_status_types bst
,     ota_finance_lines fl
where	tdb.event_id = p_event_id
and	tdb.booking_status_type_id = bst.booking_status_type_id
and   fl.booking_id(+) = tdb.booking_id
and	(((p_event_status = 'P') and (bst.type not in ('C','W')))
or	((p_event_status = 'C') and (bst.type in ('R')))
or	((p_event_status = 'A') and (bst.type <> 'C')));  -- Added check for "bst.type <> 'C'" for bug #2065808

CURSOR c_get_booking_status(p_booking_status_type_id in number) is
select type
from ota_booking_status_types
where booking_status_type_id = p_booking_status_type_id;


--
l_status_change_comments varchar(1000) := fnd_message.get_string('OTA','OTA_13523_TDB_STATUS_COMMENTS');
l_proc 	varchar2(72) := g_package||'process_event_change';
--
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --
    FOR c_get_enrollment in c_get_event_enrollments LOOP
  --
  --
   /* For bug 1763422 */
       l_booking_status  := null;
       l_daemon_type := null;
	 l_daemon_flag := null;

    if p_event_status = 'A' or p_event_status = 'C' then
       if  c_get_enrollment.daemon_flag is null  then
           For enr_status in c_get_booking_status(c_get_enrollment.booking_status_type_id)
           Loop
             l_booking_status  := enr_status.type;
           end loop;
           if l_booking_status <> 'C' then
              l_daemon_type :='W';
              l_daemon_flag := 'Y';
           else
              l_daemon_type := null;
		  l_daemon_flag := null;
           end if;
       else
           l_daemon_type := c_get_enrollment.daemon_type ;
           l_daemon_flag := c_get_enrollment.daemon_flag ;
       end if;
    end if;
     /*  End For bug 1763422 */
       ota_tdb_api_upd2.update_enrollment(p_booking_id		=> c_get_enrollment.booking_id
		      ,p_object_version_number	=> c_get_enrollment.object_version_number
		      ,p_finance_line_id	=> c_get_enrollment.finance_line_id
		      ,p_event_id       	=> p_event_id
		      ,p_booking_status_type_id	=> p_booking_status_type_id
		      ,p_status_change_comments => l_status_change_comments
		      ,p_date_booking_placed    => c_get_enrollment.date_booking_placed
		      ,p_update_finance_line	=> p_update_finance_line
		      ,p_tfl_object_version_number => c_get_enrollment.tfl_object_version_number
		      ,p_date_status_changed	=> p_date_status_changed
                  ,p_line_id              => c_get_enrollment.line_id
                  ,p_org_id			=> c_get_enrollment.org_id
		      ,p_daemon_flag		=> l_daemon_flag
		      ,p_daemon_type          => l_daemon_type);

	if p_event_status ='A' then
              --send notification to the learner for class cancelletion
   OTA_INITIALIZATION_WF.initialize_wf(p_process => 'OTA_CLASS_CANCEL_JSP_PRC',
            p_item_type 	=> 'OTWF',
            p_person_id 	=> c_get_enrollment.delegate_person_id,
            p_eventid 	=> p_event_id,
            p_event_fired => 'CLASS_CANCEL');

    end if;
  --
    END LOOP get_enrollment;
  --
    hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
--
end Process_Event_Change;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Reset Max Attendees >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Reset Maximum_Attendees and Maximum_Internal_Attendees columns.
--
--
procedure Reset_Max_Attendees (p_event_id in number
			     ,p_event_status in varchar2
			     ,p_reset_max_attendees in boolean default false
			     ,p_maximum_attendees in out nocopy number
			     ,p_maximum_internal_attendees in out nocopy number) is
--
l_total_places number;
l_total_internal_places number;
--
  l_proc 	varchar2(72) := g_package||'reset_max_attendees';
--
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- If reset_max_attendees selected then only fire When new event Status is
  -- Closed.
  --
  if p_event_status in ('C') then
    if p_reset_max_attendees then
      l_total_places := ota_evt_bus2.get_total_places('ALL',p_event_id);
      l_total_internal_places := ota_evt_bus2.get_total_places('INTERNAL',p_event_id);
      if p_maximum_internal_attendees > l_total_places then
        p_maximum_internal_attendees := l_total_places;
        p_maximum_attendees := l_total_places;
      else
 	 p_maximum_attendees := l_total_places;
      end if;
    end if;
  end if;
  --
    hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end Reset_Max_Attendees;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update Event >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Updates an Event.  May also cascade changes to enrollments for
--		the given Event.
--
procedure update_event
  (
  p_event			 in varchar2,
  p_event_id                     in number,
  p_object_version_number        in out nocopy number,
  p_event_status                 in out nocopy varchar2,
  p_validate                     in boolean default false,
  p_reset_max_attendees		 in boolean default false,
  p_update_finance_line		 in varchar2 default 'N',
  p_booking_status_type_id	 in number default null,
  p_date_status_changed 	 in date default null,
  p_maximum_attendees		 in number default null) is
--
  l_event_rec			ota_evt_shd.g_rec_type;
  l_event_rec_ovn               ota_evt_shd.g_rec_type;
  l_event_exists		boolean;
  l_event_exists_ovn            boolean;
  l_event_status		varchar2(30);
--
  l_proc 	varchar2(72) := g_package||'update_event';
--
  begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    if p_validate then
      savepoint update_enrollment;
    end if;
  --
    hr_utility.set_location(l_proc, 6);
  --
  -- Validation in addition to Table Handlers.
  -- Lock Event
  --
    ota_evt_shd.lck(p_event_id, p_object_version_number);
  --
  -- Get Event record.
  --
    ota_evt_shd.get_event_details (p_event_id,
                                 l_event_rec,
                                 l_event_exists);
  --
  if p_event = 'STATUS' then
  --
  -- Check validation of status change.
  --
    Check_Status_Change(p_event_id => p_event_id
 		       ,p_event_status => p_event_status
		       ,p_booking_status_type_id => p_booking_status_type_id
		       ,p_maximum_attendees => l_event_rec.maximum_attendees);
  --
  --
    hr_utility.set_location(l_proc, 7);
  --
  -- Process Event Status change.
  --
    Process_Event_Change(p_event_id => p_event_id
		        ,p_event_status => p_event_status
		        ,p_update_finance_line => p_update_finance_line
		        ,p_booking_status_type_id => p_booking_status_type_id
		      	,p_date_status_changed => p_date_status_changed);

  --
    hr_utility.set_location(l_proc, 8);
  --
  -- Reset Max Attendees and Max Internal Attendees.  Only when Closed Event
  -- Status is selected.
  --
    if p_event_status in ('C') then
      Reset_Max_Attendees (p_event_id => p_event_id
  		        ,p_event_status => p_event_status
		        ,p_reset_max_attendees => p_reset_max_attendees
		        ,p_maximum_attendees => l_event_rec.maximum_attendees
		        ,p_maximum_internal_attendees => l_event_rec.maximum_internal_attendees);
    end if;
  --
    hr_utility.set_location(l_proc, 9);
  --
  --
  --
  else
    Check_Maximum_Attendees(p_maximum_Attendees => p_maximum_attendees,
			    p_event_status => p_event_status,
			    p_old_max_attendees => l_event_rec.maximum_attendees,
			    p_event_id => p_event_id);
    l_event_rec.maximum_attendees := p_maximum_attendees;
  end if;

  -- Bug 463742.
  -- Requery event record, as object version number
  -- may have changed.

  ota_evt_shd.get_event_details(p_event_id,
				l_event_rec_ovn,
				l_event_exists_ovn);

  -- Force Event update
  --
/* Bug#9300792
    ota_evt_upd.upd
      (p_event_id => p_event_id
      ,p_object_version_number => l_event_rec_ovn.object_version_number
      ,p_event_status => p_event_status
      ,p_maximum_attendees => l_event_rec.maximum_attendees
      ,p_maximum_internal_attendees => l_event_rec.maximum_internal_attendees
      ,p_validate => p_validate);
*/
    ota_event_api.update_class
      (p_event_id => p_event_id
      ,p_effective_date => sysdate
      ,p_object_version_number => l_event_rec_ovn.object_version_number
      ,p_event_status => p_event_status
      ,p_maximum_attendees => l_event_rec.maximum_attendees
      ,p_maximum_internal_attendees => l_event_rec.maximum_internal_attendees
      ,p_validate => p_validate);

  --
  -- Commit the Changes
  --
-- Enh# 1753511 hdshah Commented out the commit so that we can use update_event procedure for this enhancement.
-- Included app_form.quietcommit in OTAEVENT.pll.
--    commit;
  --
    hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;

-- call ntf to instructor and learners for cancelled class
  if p_event_status = 'A' and p_event = 'STATUS' then
    --send notification to all instructors for class cancelletion
   OTA_INITIALIZATION_WF.initialize_instructor_wf(
            p_item_type 	=> 'OTWF',
            p_eventid 	=> p_event_id,
            p_event_fired => 'CLASS_CANCEL');

  end if;

  --
  exception
    when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
      ROLLBACK TO update_event;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  end Update_Event;
--
end ota_evt_api_upd2;

/
