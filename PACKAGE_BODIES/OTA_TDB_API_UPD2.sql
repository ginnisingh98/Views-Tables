--------------------------------------------------------
--  DDL for Package Body OTA_TDB_API_UPD2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TDB_API_UPD2" as
/* $Header: ottdb02t.pkb 120.22.12010000.2 2009/08/12 14:15:14 smahanka ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := ' ota_tdb_api_upd2.';
g_debug boolean := hr_utility.debug_enabled;  -- Global Debug status variable
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Check Status Change >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Check the delegate booking Status when Updating.
--
--
  procedure Check_Status_Change(p_event_id in number
 	  		       ,p_booking_status_type_id in number
			       ,p_event_status in varchar2
			       ,p_number_of_places in number
			       ,p_maximum_attendees in number) is
  --
  -- Set up local variables
  --

  l_old_booking_status varchar2(30) := ota_tdb_bus.booking_status_type(
				 ota_tdb_shd.g_old_rec.booking_status_type_id);

  l_booking_status varchar2(30) := ota_tdb_bus.booking_status_type(
					p_booking_status_type_id);

  l_booking_status_changed boolean := ota_general.value_changed(
                                  ota_tdb_shd.g_old_rec.booking_status_type_id,
                                  p_booking_status_type_id);

  l_number_of_places_changed boolean := ota_general.value_changed(
                                       ota_tdb_shd.g_old_rec.number_of_places,
                                       p_number_of_places);

  l_vacancies number := ota_evt_bus2.get_vacancies(p_event_id);

  l_old_number_of_places number := ota_tdb_shd.g_old_rec.number_of_places;

  l_old_event_id number := ota_tdb_shd.g_old_rec.event_id;
  --
  l_proc 	varchar2(72);
  --
begin
  --
if g_debug then
  l_proc  := g_package||'check_status_change';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;

--
-- *** In case of Event Change -- Reset Event Status for Old Event ***
--

   if p_event_id <> l_old_event_id and
      l_booking_status in ('A','P','E') and
      ( p_event_status = 'F' or
       ota_evt_bus2.get_vacancies(p_event_id) <
		  p_number_of_places )  then

    fnd_message.set_name('OTA','OTA_13558_TDB_PLACES_INC');
    fnd_message.raise_error;
  --
   end if;
  --
  -- Check for exceeding max attendees.
  --
  if (l_booking_status in ('A','P','E') and
     (ota_evt_bus2.get_vacancies(p_event_id) <
		  (p_number_of_places - l_old_number_of_places)))
     or
     (l_booking_status in ('A','P','E') and
      l_old_booking_status not in ('A','P','E') and
      ota_evt_bus2.get_vacancies(p_event_id) < p_number_of_places)  then
  --
    fnd_message.set_name('OTA','OTA_13558_TDB_PLACES_INC');
    fnd_message.raise_error;
  --
  end if;
  --
  -- Check booking status, if amended.
  --
  if l_booking_status_changed then
  --
  --
    --
    -- Check status change for Planned or Full Events.
    --
    if p_event_status in ('F','P','C') then
    --
      if l_old_booking_status not in ('P','A','E') and
	 l_booking_status in ('P','A','E') then
      --

        if l_old_booking_status = 'W' and
		 l_booking_status in ('P','A','E') and
      ota_evt_bus2.get_vacancies(p_event_id) >= p_number_of_places  then
            null;
	  else
        fnd_message.set_name('OTA','OTA_13521_TDB_CH_STATUS_FP');
        fnd_message.raise_error;
     end if;
	 --
      end if;
    --
    end if;

  --
  -- Check status change for Cancelled Events.
  --
    if p_event_status in ('A') then
    --
      if l_booking_status <> 'C' then
      --
        fnd_message.set_name('OTA','OTA_13522_TDB_CH_STATUS_C');
        fnd_message.raise_error;
      --
      end if;
    --
    end if;
  --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 10);
  end if;
  --
--
end Check_Status_Change;
--
-- ----------------------------------------------------------------------------
 -- |-------------------------< deleteForumNotification >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- PRIVATE
 -- Description: Delete the Forum notification record when a class is cancelled.
 --
 --
 procedure deleteForumNotification(l_event_id in number
                                  ,l_person_id in number
                                  ,l_contact_id in number) is

   --
   -- Set up local variables
   --

   cursor c_get_forum_id is
   select fns.forum_id,fns.object_version_number
   from ota_frm_obj_inclusions foi,ota_frm_notif_subscribers fns
   where foi.object_id = l_event_id
   and foi.object_Type = 'E'
   and foi.forum_id = fns.forum_id
   and (fns.person_id = l_person_id or fns.contact_id = l_contact_id);
   --
   v_forum_id number;
   v_object_version_number number;

 l_proc 	varchar2(72);

 begin
   --
 if g_debug then
   l_proc  := g_package||'deleteForumNotification';
   hr_utility.set_location('Entering:'||l_proc, 5);
 end if;

  --Delete the forum notification record for this class,for this user
    OPEN c_get_forum_id;
    FETCH c_get_forum_id into v_forum_id, v_object_version_number;

    LOOP
    Exit When c_get_forum_id%notfound OR c_get_forum_id%notfound is null;

    ota_fns_del.del
      (
       p_forum_id      => v_forum_id
      ,p_person_id    => l_person_id
      ,p_contact_id   => l_contact_id
      ,p_object_version_number    => v_object_version_number
   );

    FETCH c_get_forum_id into v_forum_id, v_object_version_number;
    End Loop;
   Close c_get_forum_id;

 --
   if g_debug then
     hr_utility.set_location('Leaving:'||l_proc, 10);
   end if;
   --
 --
 end deleteForumNotification;
 --
 -- ----------------------------------------------------------------------------
 -- |-------------------------< createForumNotification >--------------------------|
 -- ----------------------------------------------------------------------------
 --
 -- PRIVATE
 -- Description: Create the Forum notification record when a class is changed.
 --
 --
 procedure createForumNotification(l_event_id in number
                                  ,l_person_id in number
                                  ,l_contact_id in number
                                  ,l_effective_date in date
                                  ,l_booking_status_type_id in number) is

   --
   -- Set up local variables
   --

 Cursor csr_forums_for_class
   is
   Select fr.forum_id, fr.business_group_id from
   ota_forums_b fr,
   ota_frm_obj_inclusions foi
   where fr.forum_id = foi.forum_id
   and foi.object_type = 'E'
   and foi.object_id = l_event_id
   and fr.auto_notification_flag = 'Y';
   --
   v_forum_id number;
   v_business_group_id number;
 l_dummy number;
 l_proc 	varchar2(72);
 l_type ota_booking_status_types.type%type;

 begin
   --
 if g_debug then
   l_proc  := g_package||'createForumNotification';
   hr_utility.set_location('Entering:'||l_proc, 5);
 end if;

 select Type into l_type from ota_booking_status_types where booking_status_type_id=l_booking_status_type_id;

 --create frm_notif_subscriber record for enrollment_status of 'P' or 'A'.
 if l_type = 'P' or l_type = 'A' then
   OPEN csr_forums_for_class;
   FETCH csr_forums_for_class into v_forum_id, v_business_group_id;

   LOOP
   Exit When csr_forums_for_class%notfound OR csr_forums_for_class%notfound is null;

   ota_fns_ins.ins
     (  p_effective_date             => l_effective_date
       ,p_business_group_id          => v_business_group_id
       ,p_forum_id                   => v_forum_id
       ,p_person_id                  => l_person_id
       ,p_contact_id                 => l_contact_id
       ,p_object_version_number      => l_dummy
     );


   FETCH csr_forums_for_class into v_forum_id, v_business_group_id;
   End Loop;
   Close csr_forums_for_class;
 end if;
 --
   if g_debug then
     hr_utility.set_location('Leaving:'||l_proc, 10);
   end if;
   --
/* if therealready exists a frm notif record, and we try to create a new one,
 an exception will be thrown which gets caught here.. We ignore the exception and return*/

 exception
      when OTHERS then
        NULL;

 --
 end createForumNotification;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_daemon_type >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Fetches the daemon type for a cancelled enrollment
--
--
-- Added for bug#4654530
FUNCTION get_daemon_type(p_booking_id IN NUMBER)
RETURN VARCHAR2
IS
 l_hours_until_class_starts NUMBER;
 l_auto_waitlist_days 	NUMBER;
 l_daemon_type VARCHAR2(9) := NULL;

 CURSOR csr_get_class_details IS
 SELECT evt.course_start_time
       ,evt.course_start_date
       ,evt.event_id
 FROM ota_events evt,
      ota_delegate_bookings tdb
 WHERE tdb.event_id = evt.event_id
   AND tdb.booking_id = p_booking_id;

 CURSOR csr_get_waitlist_count(p_event_id NUMBER) IS
 SELECT 1
 FROM ota_delegate_bookings tdb
      ,ota_booking_status_types bst
 WHERE tdb.booking_status_type_id = bst.booking_status_type_id
    AND bst.type = 'W'
    AND tdb.event_id = p_event_id;

 l_course_start_time OTA_EVENTS.course_start_time%TYPE;
 l_course_start_date OTA_EVENTS.course_start_date%TYPE;
 l_event_id OTA_EVENTS.event_id%TYPE;
 l_waitlist_count NUMBER;

BEGIN
  OPEN csr_get_class_details;
  FETCH csr_get_class_details INTO l_course_start_time, l_course_start_date, l_event_id;
  CLOSE csr_get_class_details;
-- bug# 5231470 Date format changed from DD-MON-YYYY to DD/MM/YYYY
  l_hours_until_class_starts := 24*(to_date(to_char(l_course_start_date, 'DD/MM/YYYY')
                  ||''||l_course_start_time, 'DD/MM/YYYYHH24:MI') - SYSDATE);

  l_auto_waitlist_days := TO_NUMBER(fnd_profile.value('OTA_AUTO_WAITLIST_DAYS'));
--
   OPEN csr_get_waitlist_count(l_event_id);
   FETCH csr_get_waitlist_count INTO l_waitlist_count;
   IF (csr_get_waitlist_count%FOUND)
      AND (l_hours_until_class_starts >= l_auto_waitlist_days) THEN
         l_daemon_type := 'W';
      ELSE
         l_daemon_type := NULL;
   END IF;
   CLOSE csr_get_waitlist_count;
   RETURN l_daemon_type;

END get_daemon_type;
-- ----------------------------------------------------------------------------
-- |--------------------------< Update Enrollment >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Updates an Enrollment.
--
--
procedure Update_Enrollment
  (
  p_booking_id                   in number,
  p_booking_status_type_id       in number	default hr_api.g_number,
  p_delegate_person_id           in number	default hr_api.g_number,
  p_contact_id                   in number	default hr_api.g_number,
  p_business_group_id            in number	default hr_api.g_number,
  p_event_id                     in number	default hr_api.g_number,
  p_customer_id                  in number	default hr_api.g_number,
  p_authorizer_person_id         in number	default hr_api.g_number,
  p_date_booking_placed          in date	default hr_api.g_date,
  p_corespondent                 in varchar2	default hr_api.g_varchar2,
  p_internal_booking_flag        in varchar2	default hr_api.g_varchar2,
  p_number_of_places             in number	default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_administrator                in number	default hr_api.g_number,
  p_booking_priority             in varchar2	default hr_api.g_varchar2,
  p_comments                     in varchar2	default hr_api.g_varchar2,
  p_contact_address_id           in number	default hr_api.g_number,
  p_delegate_contact_phone       in varchar2	default hr_api.g_varchar2,
  p_delegate_contact_fax         in varchar2	default hr_api.g_varchar2,
  p_third_party_customer_id      in number	default hr_api.g_number,
  p_third_party_contact_id       in number	default hr_api.g_number,
  p_third_party_address_id       in number	default hr_api.g_number,
  p_third_party_contact_phone    in varchar2	default hr_api.g_varchar2,
  p_third_party_contact_fax      in varchar2	default hr_api.g_varchar2,
  p_date_status_changed          in date	default hr_api.g_date,
  p_status_change_comments       in varchar2	default hr_api.g_varchar2,
  p_failure_reason               in varchar2	default hr_api.g_varchar2,
  p_attendance_result            in varchar2	default hr_api.g_varchar2,
  p_language_id                  in number	default hr_api.g_number,
  p_source_of_booking            in varchar2	default hr_api.g_varchar2,
  p_special_booking_instructions in varchar2	default hr_api.g_varchar2,
  p_successful_attendance_flag   in varchar2	default hr_api.g_varchar2,
  p_tdb_information_category     in varchar2	default hr_api.g_varchar2,
  p_tdb_information1             in varchar2	default hr_api.g_varchar2,
  p_tdb_information2             in varchar2	default hr_api.g_varchar2,
  p_tdb_information3             in varchar2	default hr_api.g_varchar2,
  p_tdb_information4             in varchar2	default hr_api.g_varchar2,
  p_tdb_information5             in varchar2	default hr_api.g_varchar2,
  p_tdb_information6             in varchar2	default hr_api.g_varchar2,
  p_tdb_information7             in varchar2	default hr_api.g_varchar2,
  p_tdb_information8             in varchar2	default hr_api.g_varchar2,
  p_tdb_information9             in varchar2	default hr_api.g_varchar2,
  p_tdb_information10            in varchar2	default hr_api.g_varchar2,
  p_tdb_information11            in varchar2	default hr_api.g_varchar2,
  p_tdb_information12            in varchar2	default hr_api.g_varchar2,
  p_tdb_information13            in varchar2	default hr_api.g_varchar2,
  p_tdb_information14            in varchar2	default hr_api.g_varchar2,
  p_tdb_information15            in varchar2	default hr_api.g_varchar2,
  p_tdb_information16            in varchar2	default hr_api.g_varchar2,
  p_tdb_information17            in varchar2	default hr_api.g_varchar2,
  p_tdb_information18            in varchar2	default hr_api.g_varchar2,
  p_tdb_information19            in varchar2	default hr_api.g_varchar2,
  p_tdb_information20            in varchar2	default hr_api.g_varchar2,
  p_update_finance_line          in varchar2	default 'N',
  p_tfl_object_version_number    in out nocopy number,
  p_finance_header_id            in number	default hr_api.g_number,
  p_finance_line_id              in out nocopy  number,
  p_standard_amount              in number	default hr_api.g_number,
  p_unitary_amount               in number	default hr_api.g_number,
  p_money_amount                 in number	default hr_api.g_number,
  p_currency_code                in varchar2	default hr_api.g_varchar2,
  p_booking_deal_type            in varchar2	default hr_api.g_varchar2,
  p_booking_deal_id              in number	default hr_api.g_number,
  p_enrollment_type              in varchar2	default hr_api.g_varchar2,
  p_validate                     in boolean	default false,
  p_organization_id              in number	default hr_api.g_number,
  p_sponsor_person_id            in number	default hr_api.g_number,
  p_sponsor_assignment_id        in number	default hr_api.g_number,
  p_person_address_id            in number	default hr_api.g_number,
  p_delegate_assignment_id       in number	default hr_api.g_number,
  p_delegate_contact_id          in number	default hr_api.g_number,
  p_delegate_contact_email       in varchar2	default hr_api.g_varchar2,
  p_third_party_email            in varchar2	default hr_api.g_varchar2,
  p_person_address_type          in varchar2	default hr_api.g_varchar2,
  p_line_id			 	   in number	default hr_api.g_number,
  p_org_id			 	   in number	default hr_api.g_number,
  p_daemon_flag			   in varchar2    default hr_api.g_varchar2,
  p_daemon_type			   in varchar2 	default hr_api.g_varchar2,
  p_old_event_id                 in number      default hr_api.g_number,
  p_quote_line_id                in number      default hr_api.g_number,
  p_interface_source             in varchar2    default hr_api.g_varchar2,
  p_total_training_time          in varchar2 	default hr_api.g_varchar2,
  p_content_player_status        in varchar2 	default hr_api.g_varchar2,
  p_score		               in number   	default hr_api.g_number,
  p_completed_content		   in number   	default hr_api.g_number,
  p_total_content	               in number   	default hr_api.g_number,
  p_booking_justification_id                  in number default hr_api.g_number,
  p_source_cancel in varchar2,
  p_override_prerequisites              in varchar2 default 'N',
  p_is_history_flag in varchar2 default hr_api.g_varchar2
 ,p_override_learner_access 	  in 	 varchar2 default 'N',
  p_sign_eval_status              in     varchar2 default null)
is

  l_proc 	varchar2(72) := g_package || ' ' || 'create_enrollment';
/*
  --
  l_status_type_id_changed   boolean;
  --Added for Bug#4106893
  l_event_id_changed boolean := false;
  l_person_id_changed boolean := false;
  l_contact_id_changed boolean := false;

  l_cancel_finance_line      boolean;
  l_event_rec			ota_evt_shd.g_rec_type;
  l_event_exists		boolean;
  l_effective_date	date;
  -- Bug 2982183
  l_person_id number;
  -- Bug 2982183
  --Bug 2359495
  l_status_change_comments   ota_booking_status_histories.comments%TYPE;
  --Bug 2359495

  l_lp_enrollment_ids varchar2(4000);
  l_cert_prd_enrollment_ids varchar2(4000);
  l_item_key     wf_items.item_key%type;

  l_type ota_booking_status_types.type%type;
  --
  l_proc 	varchar2(72) ;
  --l_daemon_type OTA_DELEGATE_BOOKINGS.daemon_type%TYPE := p_daemon_type;
  --l_daemon_flag OTA_DELEGATE_BOOKINGS.daemon_flag%TYPE := p_daemon_flag;
  l_daemon_type VARCHAR2(30) := p_daemon_type;
  l_daemon_flag VARCHAR2(30) := p_daemon_flag;

  Cursor is_contact
  is
  Select contact_id,delegate_contact_id from
  Ota_delegate_bookings
  where booking_id= p_booking_id;

  l_delegate_contact_id number(15);
  l_contact_id number(15);
  l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                               hr_dflex_utility.l_ignore_dfcode_varray();
  l_ignore_dff_validation varchar2(1);

  Cursor chk_for_comp_upd
  is
  select ocu.online_flag , off.Learning_object_id from ota_category_usages ocu,
    ota_offerings off , ota_events oev
    where ocu.category_usage_id = off.delivery_mode_id
    and off.offering_id = oev.parent_offering_id
    and oev.event_id = p_event_id;

  l_comp_upd varchar2(1000) :='MoveToHistoryImage';
  l_on_flag varchar2(100);
  l_LO_id ota_offerings.Learning_object_id%type;

  cursor get_status_info is
  select bst.Type
  from ota_booking_status_types bst, ota_delegate_bookings tdb
  where bst.booking_status_type_id= tdb.booking_status_type_id
  and tdb.booking_id = p_booking_id;

  l_enroll_type varchar2(30);
  l_incoming_status_type varchar2(30);

  l_customer_id_changed boolean;
l_organization_id_changed boolean;
l_delegate_person_id_changed boolean;
l_delegate_asg_changed boolean;

l_new_event_id ota_delegate_bookings.event_id%TYPE := p_event_id;
l_new_customer_id ota_delegate_bookings.customer_id%TYPE := p_customer_id;
l_new_delegate_contact_id ota_delegate_bookings.delegate_contact_id%TYPE := p_delegate_contact_id;
l_new_organization_id ota_delegate_bookings.organization_id%TYPE := p_organization_id;
l_new_del_asg_id ota_delegate_bookings.delegate_assignment_id%TYPE := p_delegate_assignment_id;
l_new_delegate_person_id ota_delegate_bookings.delegate_person_id%TYPE := p_delegate_person_id;

CURSOR csr_get_enr_details IS
SELECT event_id, customer_id, organization_id,
      delegate_person_id, delegate_assignment_id,
      delegate_contact_id
FROM  ota_delegate_bookings
WHERE booking_id = p_booking_id;


l_enr_details_rec csr_get_enr_details%ROWTYPE;

l_old_booking_status varchar2(30);
l_evt_status_chg_comments varchar2(1000) := fnd_message.get_string('OTA','OTA_13523_TDB_STATUS_COMMENTS');
*/
  --
  begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  ota_delegate_booking_api.update_delegate_booking(
      p_effective_date                  =>   trunc(sysdate)
    , p_booking_id                      =>   p_booking_id
    , p_booking_status_type_id     	=>   p_booking_status_type_id
    , p_delegate_person_id         	=>   p_delegate_person_id
    , p_contact_id                 	=>   p_contact_id
    , p_business_group_id          	=>   p_business_group_id
    , p_event_id                   	=>   p_event_id
    , p_customer_id                	=>   p_customer_id
    , p_authorizer_person_id       	=>   p_authorizer_person_id
    , p_date_booking_placed        	=>   p_date_booking_placed
    , p_corespondent               	=>   p_corespondent
    , p_internal_booking_flag      	=>   p_internal_booking_flag
    , p_number_of_places           	=>   p_number_of_places
    , p_object_version_number      	=>   p_object_version_number
    , p_administrator              	=>   p_administrator
    , p_booking_priority           	=>   p_booking_priority
    , p_comments                   	=>   p_comments
    , p_contact_address_id         	=>   p_contact_address_id
    , p_delegate_contact_phone     	=>   p_delegate_contact_phone
    , p_delegate_contact_fax       	=>   p_delegate_contact_fax
    , p_third_party_customer_id    	=>   p_third_party_customer_id
    , p_third_party_contact_id     	=>   p_third_party_contact_id
    , p_third_party_address_id     	=>   p_third_party_address_id
    , p_third_party_contact_phone  	=>   p_third_party_contact_phone
    , p_third_party_contact_fax    	=>   p_third_party_contact_fax
    , p_date_status_changed        	=>   p_date_status_changed
    , p_status_change_comments     	=>   p_status_change_comments
    , p_failure_reason             	=>   p_failure_reason
    , p_attendance_result          	=>   p_attendance_result
    , p_language_id                	=>   p_language_id
    , p_source_of_booking            	=>   p_source_of_booking
    , p_special_booking_instructions 	=>   p_special_booking_instructions
    , p_successful_attendance_flag   	=>   p_successful_attendance_flag
    , p_tdb_information_category     	=>   p_tdb_information_category
    , p_tdb_information1             	=>   p_tdb_information1
    , p_tdb_information2             	=>   p_tdb_information2
    , p_tdb_information3             	=>   p_tdb_information3
    , p_tdb_information4             	=>   p_tdb_information4
    , p_tdb_information5             	=>   p_tdb_information5
    , p_tdb_information6             	=>   p_tdb_information6
    , p_tdb_information7             	=>   p_tdb_information7
    , p_tdb_information8             	=>   p_tdb_information8
    , p_tdb_information9             	=>   p_tdb_information9
    , p_tdb_information10            	=>   p_tdb_information10
    , p_tdb_information11            	=>   p_tdb_information11
    , p_tdb_information12            	=>   p_tdb_information12
    , p_tdb_information13            	=>   p_tdb_information13
    , p_tdb_information14            	=>   p_tdb_information14
    , p_tdb_information15            	=>   p_tdb_information15
    , p_tdb_information16            	=>   p_tdb_information16
    , p_tdb_information17            	=>   p_tdb_information17
    , p_tdb_information18            	=>   p_tdb_information18
    , p_tdb_information19            	=>   p_tdb_information19
    , p_tdb_information20            	=>   p_tdb_information20
    , p_update_finance_line          	=>   p_update_finance_line
    , p_tfl_object_version_number    	=>   p_tfl_object_version_number
    , p_finance_header_id            	=>   p_finance_header_id
    , p_finance_line_id              	=>   p_finance_line_id
    , p_standard_amount              	=>   p_standard_amount
    , p_unitary_amount               	=>   p_unitary_amount
    , p_money_amount                 	=>   p_money_amount
    , p_currency_code                	=>   p_currency_code
    , p_booking_deal_type            	=>   p_booking_deal_type
    , p_booking_deal_id              	=>   p_booking_deal_id
    , p_enrollment_type              	=>   p_enrollment_type
    , p_validate                     	=>   p_validate
    , p_organization_id              	=>   p_organization_id
    , p_sponsor_person_id            	=>   p_sponsor_person_id
    , p_sponsor_assignment_id        	=>   p_sponsor_assignment_id
    , p_person_address_id            	=>   p_person_address_id
    , p_delegate_assignment_id       	=>   p_delegate_assignment_id
    , p_delegate_contact_id          	=>   p_delegate_contact_id
    , p_delegate_contact_email       	=>   p_delegate_contact_email
    , p_third_party_email            	=>   p_third_party_email
    , p_person_address_type          	=>   p_person_address_type
    , p_line_id			        =>   p_line_id
    , p_org_id			        =>   p_org_id
    , p_daemon_flag			=>   p_daemon_flag
    , p_daemon_type			=>   p_daemon_type
    , p_old_event_id                 	=>   p_old_event_id
    , p_quote_line_id                	=>   p_quote_line_id
    , p_interface_source             	=>   p_interface_source
    , p_total_training_time          	=>   p_total_training_time
    , p_content_player_status        	=>   p_content_player_status
    , p_score		         	=>   p_score
    , p_completed_content		=>   p_completed_content
    , p_total_content	         	=>   p_total_content
    , p_booking_justification_id     	=>   p_booking_justification_id
    , p_source_cancel 		        =>   p_source_cancel
    , p_override_prerequisites       	=>   p_override_prerequisites
    , p_is_history_flag 		=>   p_is_history_flag
    , p_override_learner_access 	=>   p_override_learner_access
    , p_sign_eval_status            =>   p_sign_eval_status
  );

  hr_utility.set_location('Leaving:'||l_proc, 5);

/*
  --
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    l_proc := g_package||'update_enrollment';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
  --
    savepoint update_enrollment;
  --
  end if;
  -- Truncate the time portion from all IN date parameters
  --
  -- l_effective_date := trunc(p_effective_date);
  --

  --
  -- Validation in addition to Table Handlers
  --
  --
  --
  -- Lock Enrollment (Bug 2468167)
  --
      ota_tdb_shd.lck(p_booking_id,p_object_version_number);
  --
  -- Prerequisite Validation Code
  -- Can be overridden if p_override_prerequisites parameter is 'Y'
  -- get booking status type
   ota_utility.get_booking_status_type(p_status_type_id=>p_booking_status_type_id,
                                                                p_type => l_incoming_status_type);

     If ( p_override_prerequisites = 'N' ) Then
	     --Call local method
	     chk_mandatory_prereqs(p_delegate_person_id, p_delegate_contact_id, p_customer_id, p_event_id, p_booking_status_type_id);
     End If;

     IF p_override_learner_access <> 'Y' THEN
        OPEN csr_get_enr_details;
	FETCH csr_get_enr_details INTO l_enr_details_rec;
	CLOSE csr_get_enr_details;

        -- Modified for bug#4681165
	IF l_new_event_id = hr_api.g_number THEN l_new_event_id := l_enr_details_rec.event_id; END IF;
     	IF l_new_customer_id = hr_api.g_number THEN l_new_customer_id := l_enr_details_rec.customer_id; END IF;
     	IF l_new_delegate_contact_id = hr_api.g_number THEN l_new_delegate_contact_id := l_enr_details_rec.delegate_contact_id; END IF;
	IF l_new_organization_id = hr_api.g_number THEN l_new_organization_id := l_enr_details_rec.organization_id; END IF;
     	IF l_new_del_asg_id = hr_api.g_number THEN l_new_del_asg_id := l_enr_details_rec.delegate_assignment_id; END IF;
     	IF l_new_delegate_person_id = hr_api.g_number THEN l_new_delegate_person_id := l_enr_details_rec.delegate_person_id; END IF;


	l_event_id_changed := ota_general.value_changed( l_enr_details_rec.event_id, l_new_event_id);
	l_customer_id_changed := ota_general.value_changed( l_enr_details_rec.customer_id, l_new_customer_id);
	l_organization_id_changed := ota_general.value_changed( l_enr_details_rec.organization_id, l_new_organization_id);
	l_delegate_person_id_changed := ota_general.value_changed( l_enr_details_rec.delegate_person_id, l_new_delegate_person_id);
	l_delegate_asg_changed := ota_general.value_changed( l_enr_details_rec.delegate_assignment_id, l_new_del_asg_id);

	  if l_event_id_changed or
	     l_customer_id_changed or
	     l_organization_id_changed or
	     l_delegate_person_id_changed or
	     l_delegate_asg_changed then
  	--
  	-- check that the delegate is eligible to be booked on to the event
  	--
		ota_tdb_bus.check_delegate_eligible(
			 p_event_id => l_new_event_id
  		        ,p_customer_id => l_new_customer_id
              		,p_delegate_contact_id => l_new_delegate_contact_id
              		,p_organization_id => l_new_organization_id
              		,p_delegate_person_id => l_new_delegate_person_id
              		,p_delegate_assignment_id => l_new_del_asg_id);
  	 END IF;
  END IF;

  -- Added for bug#4654530
 IF nvl(p_status_change_comments,hr_api.g_varchar2) <> l_evt_status_chg_comments THEN

    OPEN get_status_info;
    FETCH get_status_info INTO l_old_booking_status;
    CLOSE get_status_info;

    IF l_incoming_status_type = 'C'
      AND l_old_booking_status <> 'C'
      AND l_daemon_type IS NULL THEN
            l_daemon_type := get_daemon_type(p_booking_id);
            IF l_daemon_type IS NOT NULL THEN
              l_daemon_flag := 'Y';
            ELSE
              l_daemon_flag := 'N';
            END IF;
   END IF;

   IF l_incoming_status_type <> 'C'
     AND l_old_booking_status = 'C' THEN
      l_daemon_flag := 'N';
      l_daemon_type := NULL;
   END IF;

  END IF;

  -- Lock the Event
  --
     ota_evt_bus2.lock_event(p_event_id);

     -- get booking_status type to fire ntf process
     open get_status_info;
     fetch get_status_info into l_enroll_type;
     close get_status_info;
  --
  -- Get Event record
  --
  ota_evt_shd.get_event_details (p_event_id,
                                 l_event_rec,
                                 l_event_exists);

  -- Ignore Enrollment Dff Validation for some cases
  if ( (l_event_rec.price_basis = 'C' and p_contact_id is not null) or (l_event_rec.line_id is not null) or (p_line_id is not null) ) then
	  l_add_struct_d.extend(1);
	  l_add_struct_d(l_add_struct_d.count) := 'OTA_DELEGATE_BOOKINGS';
	  hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);
          l_ignore_dff_validation := 'Y';
  else
          l_ignore_dff_validation := 'N';
  end if;

  --
  --  Validation Check on booking / event statuses
  --
  Check_Status_Change(p_event_id
                     ,p_booking_Status_type_id
                     ,l_event_rec.event_status
                     ,p_number_of_places
                     ,l_event_rec.maximum_attendees);

  --
  --Bug 2359495
  IF p_status_change_comments IS NULL THEN
     l_status_change_comments := hr_general_utilities.get_lookup_meaning
                                 ('ENROLMENT_STATUS_REASON',
                                  'A');
  ELSE
     l_status_change_comments := p_status_change_comments;
  END IF;
  --Bug 2359495
  -- Force Update
  --
   ota_tdb_upd.upd
   (
     p_booking_id,
     p_booking_status_type_id,
     p_delegate_person_id,
     p_contact_id,
     p_business_group_id,
     p_event_id,
     p_customer_id,
     p_authorizer_person_id,
     p_date_booking_placed,
     p_corespondent,
     p_internal_booking_flag,
     p_number_of_places,
     p_object_version_number,
     p_administrator,
     p_booking_priority,
     p_comments,
     p_contact_address_id,
     p_delegate_contact_phone,
     p_delegate_contact_fax,
     p_third_party_customer_id,
     p_third_party_contact_id,
     p_third_party_address_id,
     p_third_party_contact_phone,
     p_third_party_contact_fax,
     p_date_status_changed,
     l_status_change_comments, --   p_status_change_comments, Bug 2359495
     p_failure_reason,
     p_attendance_result,
     p_language_id,
     p_source_of_booking,
     p_special_booking_instructions,
     p_successful_attendance_flag,
     p_tdb_information_category,
     p_tdb_information1,
     p_tdb_information2,
     p_tdb_information3,
     p_tdb_information4,
     p_tdb_information5,
     p_tdb_information6,
     p_tdb_information7,
     p_tdb_information8,
     p_tdb_information9,
     p_tdb_information10,
     p_tdb_information11,
     p_tdb_information12,
     p_tdb_information13,
     p_tdb_information14,
     p_tdb_information15,
     p_tdb_information16,
     p_tdb_information17,
     p_tdb_information18,
     p_tdb_information19,
     p_tdb_information20,
     p_update_finance_line,
     p_tfl_object_version_number,
     p_finance_header_id,
     p_finance_line_id,
     p_standard_amount,
     p_unitary_amount,
     p_money_amount,
     p_currency_code,
     p_booking_deal_type,
     p_booking_deal_id,
     p_enrollment_type,
     p_validate,
     p_organization_id,
     p_sponsor_person_id,
     p_sponsor_assignment_id,
     p_person_address_id,
     p_delegate_assignment_id,
     p_delegate_contact_id,
     p_delegate_contact_email,
     p_third_party_email,
     p_person_address_type,
     p_line_id,
     p_org_id,
-- Modified for bug#4654530
     l_daemon_flag,
     l_daemon_type,
--     p_daemon_flag,
--     p_daemon_type,
     p_old_event_id,
     p_quote_line_id,
     p_interface_source,
     p_total_training_time,
     p_content_player_status,
     p_score,
     p_completed_content,
     p_total_content,
     p_booking_justification_id,
     p_is_history_flag
);
  --
  l_status_type_id_changed  :=
       ota_general.value_changed (ota_tdb_shd.g_old_rec.booking_status_type_id,
                                  p_booking_status_type_id);

 --Getting the old booking status to manipulate the fourm notification records
   l_old_booking_status := ota_tdb_bus.booking_status_type(
 				 ota_tdb_shd.g_old_rec.booking_status_type_id);

    OPEN is_contact;
    FETCH is_contact INTO l_contact_id,l_delegate_contact_id;
    CLOSE is_contact;

    If (p_delegate_person_id = hr_api.g_number) then
      select delegate_person_id  into l_person_id from ota_delegate_bookings
                                where booking_id = p_booking_id;
    else l_person_id := p_delegate_person_id;
    End If;
    --
    --Added by dbatra
    -- this is to take care of granting competencies attached to LP which are completed
    -- but course under it was not successfully attended intitially.
    if (not l_status_type_id_changed) and p_successful_attendance_flag ='Y' then
    if l_delegate_contact_id is null and l_contact_id is null then

        ota_lrng_path_util.start_comp_proc_success_attnd(p_person_id =>l_person_id
                                                        ,p_event_id => p_event_id);

		ota_cpe_util.crt_comp_upd_succ_att(p_person_id =>l_person_id
                                                        ,p_event_id => p_event_id);

    end if;
    end if;
    --
    if l_status_type_id_changed or p_successful_attendance_flag ='Y' then
    --
    -- Added by dbatra for training plan
    -- Bug 2982183
    if l_delegate_contact_id is null and l_contact_id is null and l_status_type_id_changed then

/* bug 3795299
	ota_trng_plan_comp_ss.update_tpc_enroll_status_chg(p_event_id  => p_event_id,
                                                     p_person_id => l_person_id,
						     -- Added for Bug#3479186
						     p_contact_id => NULL,
                                                     p_learning_path_ids => l_learning_path_ids);
    ELSE-- Added for Bug#3479186
       	ota_trng_plan_comp_ss.update_tpc_enroll_status_chg(p_event_id  => p_event_id,
                                                     p_person_id => NULL,
						     p_contact_id => l_delegate_contact_id,
                                                     p_learning_path_ids => l_learning_path_ids);
*/
/*
         ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => p_event_id,
                                                                p_person_id         => l_person_id,
                                                                p_contact_id        => null,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
   	-- update any associated cert member enrollment statuses
	ota_cme_util.update_cme_status(p_event_id          => p_event_id,
                                       p_person_id         => l_person_id,
                                       p_contact_id        => null,
                                       p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

    ELSif l_delegate_contact_id is not null then
         ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => p_event_id,
                                                                p_person_id         => null,
                                                                p_contact_id        => l_delegate_contact_id,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
	 -- update any associated cert member enrollment statuses
         ota_cme_util.update_cme_status(p_event_id          => p_event_id,
                                        p_person_id         => null,
                                        p_contact_id        => l_delegate_contact_id,
                                        p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

    end if; -- contact_id

      select Type into l_type from ota_booking_status_types where booking_status_type_id=p_booking_status_type_id;

       if l_type='A' and l_delegate_contact_id is null and l_contact_id is null then

	-- check whether class is online or not
*/
/*     OPEN chk_for_comp_upd;
        FETCH chk_for_comp_upd INTO l_on_flag,l_LO_id;
        CLOSE chk_for_comp_upd;

       if l_on_flag='Y' then
       -- check whether online class is succesfully completed or not
       l_comp_upd := ota_lo_utility.get_history_button(p_user_id  => l_person_id,
                            p_lo_id => l_LO_id  ,
                            p_event_id => p_event_id,
                            p_booking_id => p_booking_id);
        elsif p_successful_attendance_flag <>'Y' then
            l_comp_upd := null;
        end if; -- flag */
/*
        if p_successful_attendance_flag = 'Y' then
        ota_competence_ss.create_wf_process(p_process 	=>'OTA_COMPETENCE_UPDATE_JSP_PRC',
            p_itemtype 		=>'HRSSA',
            p_person_id 	=> l_person_id,
            p_eventid       =>p_event_id,
            p_learningpath_ids => null,
            p_itemkey    =>l_item_key);

        end if;


        end if;

	--- send ntf to waitlisted learner

 if l_enroll_type = 'W' and l_type = 'P'
 and l_delegate_contact_id is null and l_contact_id is null then

    OTA_INITIALIZATION_WF.initialize_wf(p_process => 'OTA_ENROLL_STATUS_CHNG_JSP_PRC',
            p_item_type 	=> 'OTWF',
            p_eventid 	=> p_event_id,
            p_person_id => l_person_id,
            p_event_fired => 'ENROLL_STATUS_CHNG');

 end if;

 -- send cancel enrollment ntf

 if l_type ='C' and l_delegate_contact_id is null and l_contact_id is null
 and nvl(p_source_cancel,'-1') <> 'AME' then

 OTA_LRNR_ENROLL_UNENROLL_WF.learner_unenrollment
 (p_process => 'OTA_LNR_TRNG_CANCEL_JSP_PRC',
 p_itemtype => 'HRSSA',
 p_person_id => l_person_id,
 p_eventid => p_event_id);

 end if;

    -- Bug 2982183
    --
    ota_tdb_bus.maintain_status_history
                            (p_booking_status_type_id,
                             p_date_status_changed,
                             p_administrator,
                             l_status_change_comments, --p_status_change_comments,Bug 2359495
                             p_booking_id,
                             ota_tdb_shd.g_old_rec.date_status_changed,
                             ota_tdb_shd.g_old_rec.booking_status_type_id,
                             ota_tdb_shd.g_created_by,
                             p_date_booking_placed);
  --
    ota_tdb_bus.ota_letter_lines
                  (p_booking_id             => p_booking_id,
                   p_booking_status_type_id => p_booking_status_type_id,
                   p_event_id               => p_event_id,
                   p_delegate_person_id     => l_person_id);
                --  Modified for bug#3007934.
                --   p_delegate_person_id     => p_delegate_person_id);
                ---***Added p_delegate_person_id. Bug2791524.
  --
  end if;
  --
  --Added for Bug#4106893
  IF p_event_id <> hr_api.g_number
     AND p_event_id <> ota_tdb_shd.g_old_rec.event_id THEN
     l_event_id_changed:= true;
  END IF;

  IF p_delegate_person_id <> hr_api.g_number
    AND p_delegate_person_id <> ota_tdb_shd.g_old_rec.delegate_person_id THEN
      l_person_id_changed := true;
  END IF;

    IF p_delegate_contact_id <> hr_api.g_number
    AND p_delegate_contact_id <> ota_tdb_shd.g_old_rec.delegate_contact_id THEN
      l_contact_id_changed := true;
  END IF;


 --If the new enrollment status is 'C' or 'R' or 'W' then delete the forum notitifcation record
 if l_type = 'C' or l_type = 'R' or l_type = 'W' then
   deleteForumNotification(p_event_id,l_person_id, l_delegate_contact_id);
 end if;

 --If the booking status is changed from 'C','W' or 'R' to 'P' or 'A',
 --then we need to create a new forum notification record.
 if l_old_booking_status = 'C' or l_old_booking_status = 'W' or l_old_booking_status ='R'
         and l_type = 'P' or l_type = 'A' then
   if NOT l_event_id_changed and NOT l_person_id_changed AND NOT l_contact_id_changed THEN
    IF l_person_id IS NOT NULL THEN
       createForumNotification(p_event_id,l_person_id, null, l_effective_date, p_booking_status_type_id);
    ELSIF l_delegate_contact_id IS NOT NULL THEN
       createForumNotification(p_event_id, null, l_delegate_contact_id, l_effective_date, p_booking_status_type_id);
    end if;
   end if;
 end if;
*/

  /**
       When the class name is changed for an enrollment, the lme update must be called
       twice, once for the old class and once for the new class.
       When the learner name is changed for an enrollment, the lme update must be called
       twice, once for the old learner and once for the new learner.
       If both the learner aswell as class associated with an enrollment are changed,
       update lme must be called once for old class, old learner and once for new class and new learner
  **/
/*
  IF l_event_id_changed AND NOT l_person_id_changed AND NOT l_contact_id_changed THEN
   IF l_person_id IS NOT NULL THEN
           ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                                                p_person_id         => l_person_id,
                                                                p_contact_id        => null,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
  	   -- update any associated cert member enrollment statuses
           ota_cme_util.update_cme_status(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                          p_person_id         => l_person_id,
                                          p_contact_id        => null,
                                          p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

           ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          =>p_event_id,
                                                                p_person_id         => l_person_id,
                                                                p_contact_id        => null,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
	   -- update any associated cert member enrollment statuses
           ota_cme_util.update_cme_status(p_event_id          => p_event_id,
                                          p_person_id         => l_person_id,
                                          p_contact_id        => null,
                                          p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);
 	--If the event has changed, the forum notification record should be deleted and created for the new event
 	-- FRM Notification should be created only for Placed or Attended status. Not for 'C','W' or 'R'.
 	deleteForumNotification(ota_tdb_shd.g_old_rec.event_id, l_person_id, null);
 	createForumNotification(p_event_id, l_person_id, null, l_effective_date, p_booking_status_type_id);
    ELSIF l_delegate_contact_id IS NOT NULL THEN
           ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                                                p_person_id         => null,
                                                                p_contact_id        => l_delegate_contact_id,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);

  	   -- update any associated cert member enrollment statuses
           ota_cme_util.update_cme_status(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                          p_person_id         => null,
                                          p_contact_id        => l_delegate_contact_id,
                                          p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

           ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => p_event_id,
                                                                p_person_id         => null,
                                                                p_contact_id        => l_delegate_contact_id,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
	   -- update any associated cert member enrollment statuses
           ota_cme_util.update_cme_status(p_event_id          => p_event_id,
                                          p_person_id         => null,
                                          p_contact_id        => l_delegate_contact_id,
                                          p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);
 	deleteForumNotification(ota_tdb_shd.g_old_rec.event_id, null, l_delegate_contact_id);
 	createForumNotification(p_event_id, null, l_delegate_contact_id, l_effective_date, p_booking_status_type_id);
    END IF;
  ELSIF l_event_id_changed THEN
    IF  l_person_id_changed THEN
      ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                                                p_person_id         =>ota_tdb_shd.g_old_rec.delegate_person_id,
                                                                p_contact_id        => null,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);

      -- update any associated cert member enrollment statuses
      ota_cme_util.update_cme_status(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                     p_person_id         => ota_tdb_shd.g_old_rec.delegate_person_id,
                                     p_contact_id        => null,
                                     p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

      ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => p_event_id,
                                                                p_person_id         => l_person_id,
                                                                p_contact_id        => null,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
      -- update any associated cert member enrollment statuses
      ota_cme_util.update_cme_status(p_event_id          => p_event_id,
                                     p_person_id         => l_person_id,
                                     p_contact_id        => null,
                                     p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);
    -- the class and the learner have change.So delete the forum record for old class and person
    --and create a notification record for the new class and new person
 	deleteForumNotification(ota_tdb_shd.g_old_rec.event_id, ota_tdb_shd.g_old_rec.delegate_person_id, null);
 	createForumNotification(p_event_id, l_person_id, null, l_effective_date, p_booking_status_type_id);
    ELSIF l_contact_id_changed THEN
      ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                                                p_person_id         =>  null,
                                                                p_contact_id        =>ota_tdb_shd.g_old_rec.delegate_contact_id,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
      -- update any associated cert member enrollment statuses
      ota_cme_util.update_cme_status(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                     p_person_id         => null,
                                     p_contact_id        => ota_tdb_shd.g_old_rec.delegate_contact_id,
                                     p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

      ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => p_event_id,
                                                                p_person_id         => null,
                                                                p_contact_id        => p_delegate_contact_id,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
      -- update any associated cert member enrollment statuses
      ota_cme_util.update_cme_status(p_event_id          => p_event_id,
                                     p_person_id         => null,
                                     p_contact_id        => p_delegate_contact_id,
                                     p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);
 	deleteForumNotification(ota_tdb_shd.g_old_rec.event_id, null, ota_tdb_shd.g_old_rec.delegate_contact_id);
 	createForumNotification(p_event_id, null, l_delegate_contact_id, l_effective_date, p_booking_status_type_id);
    END IF;
  ELSIF l_person_id_changed THEN
    ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                                                p_person_id         =>ota_tdb_shd.g_old_rec.delegate_person_id,
                                                                p_contact_id        => null,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);

    -- update any associated cert member enrollment statuses
    ota_cme_util.update_cme_status(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                   p_person_id         => ota_tdb_shd.g_old_rec.delegate_person_id,
                                   p_contact_id        => null,
                                   p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

    ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                                                p_person_id         => l_person_id,
                                                                p_contact_id        => null,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
    -- update any associated cert member enrollment statuses
    ota_cme_util.update_cme_status(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                   p_person_id         => l_person_id,
                                   p_contact_id        => null,
                                   p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);
    -- the learner has changed.So delete the forum record for old person
    --and create a notification record for the new person
 	deleteForumNotification(ota_tdb_shd.g_old_rec.event_id, ota_tdb_shd.g_old_rec.delegate_person_id, null);
 	createForumNotification(ota_tdb_shd.g_old_rec.event_id, l_person_id, null, l_effective_date, p_booking_status_type_id);

  ELSIF l_contact_id_changed THEN
    ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                                                p_person_id         =>  null,
                                                                p_contact_id        =>ota_tdb_shd.g_old_rec.delegate_contact_id,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
    -- update any associated cert member enrollment statuses
    ota_cme_util.update_cme_status(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                   p_person_id         => null,
                                   p_contact_id        => ota_tdb_shd.g_old_rec.delegate_contact_id,
                                   p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

    ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                                                p_person_id         => null,
                                                                p_contact_id        => p_delegate_contact_id,
                                                                p_lp_enrollment_ids => l_lp_enrollment_ids);
    -- update any associated cert member enrollment statuses
    ota_cme_util.update_cme_status(p_event_id          => ota_tdb_shd.g_old_rec.event_id,
                                   p_person_id         => null,
                                   p_contact_id        => p_delegate_contact_id,
                                   p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);
 	deleteForumNotification(ota_tdb_shd.g_old_rec.event_id, null, ota_tdb_shd.g_old_rec.delegate_contact_id);
 	createForumNotification(ota_tdb_shd.g_old_rec.event_id, null, p_delegate_contact_id, l_effective_date, p_booking_status_type_id);

  END IF;

  if p_update_finance_line in ('C','Y') then
  --
    l_cancel_finance_line := (p_update_finance_line = 'C');
    ota_finance.maintain_finance_line
                  (p_finance_header_id     => p_finance_header_id,
                   p_booking_id            => p_booking_id   ,
                   p_currency_code         => p_currency_code    ,
                   p_standard_amount       => p_standard_amount,
                   p_unitary_amount        => p_unitary_amount   ,
                   p_money_amount          => p_money_amount     ,
                   p_booking_deal_id       => p_booking_deal_id  ,
                   p_booking_deal_type     => p_booking_deal_type,
                   p_object_version_number => p_tfl_object_version_number,
                   p_finance_line_id       => p_finance_line_id,
		   p_cancel_finance_line   => l_cancel_finance_line);
  --
  end if;

  --
  -- Reset Event Status
  --
  ota_evt_bus2.reset_event_status(p_event_id
                                 ,l_event_rec.object_version_number
                                 ,l_event_rec.event_status
                                 ,l_event_rec.maximum_attendees);
--
-- *** In case of Event Change -- Reset Event Status for Old Event ***
--
   if p_event_id <> ota_tdb_shd.g_old_rec.event_id then
     ota_evt_bus2.lock_event(ota_tdb_shd.g_old_rec.event_id);

      ota_evt_shd.get_event_details (ota_tdb_shd.g_old_rec.event_id,
                                 l_event_rec,
                                 l_event_exists);

      ota_evt_bus2.reset_event_status(ota_tdb_shd.g_old_rec.event_id
                                 ,l_event_rec.object_version_number
                                 ,l_event_rec.event_status
                                 ,l_event_rec.maximum_attendees);

      ota_evt_shd.get_event_details (p_event_id,
                                 l_event_rec,
                                 l_event_exists);
  end if;

  if ( l_ignore_dff_validation = 'Y') then
	  hr_dflex_utility.remove_ignore_df_validation;
  end if;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
  --
    raise hr_api.validate_enabled;
  --
  end if;

  --
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 10);
  end if;
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_enrollment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
*/
end Update_Enrollment;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update Waitlisted >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Updates Waitlisted enrollments from the Waitlist window.
--
--
Procedure Update_Waitlisted (p_booking_id in number
			     ,p_object_version_number in out nocopy number
			     ,p_event_id in number
			     ,p_booking_status_type_id in number
			     ,p_date_status_changed in date
			     ,p_status_change_comments in varchar2
			     ,p_number_of_places in number
			     ,p_finance_line_id in out nocopy number
			     ,p_tfl_object_version_number in out nocopy number
			     ,p_administrator in number
			     ,p_validate in boolean
			     ) is
--
--
  l_status_change_comments varchar2(1000);
  l_proc 	varchar2(72);
  l_places      number;
--
begin
  --
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    l_proc  := g_package||'Update_Waitlisted';
    hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Call the delegate booking update API.
  --

  l_places := ota_evt_bus2.get_vacancies(p_event_id);

  if p_number_of_places <= l_places or
     l_places is null then
  --
  ota_tdb_api_upd2.update_enrollment
	           (p_booking_id => p_booking_id
		   ,p_object_version_number => p_object_version_number
		   ,p_event_id => p_event_id
		   ,p_booking_status_type_id => p_booking_status_type_id
		   ,p_date_status_changed => p_date_status_changed
		   ,p_status_change_comments => p_status_change_comments
		   ,p_number_of_places => p_number_of_places
		   ,p_update_finance_line => 'N'
		   ,p_finance_line_id => p_finance_line_id
		   ,p_tfl_object_version_number => p_tfl_object_version_number
		   ,p_administrator => p_administrator
		   ,p_validate => p_validate
		   );
  --
  -- commit the changes
  --
  commit;
  --
  else
  --
    fnd_message.set_name('OTA','OTA_13558_TDB_PLACES_INC');
    fnd_message.raise_error;
  --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 10);
  end if;
  --
end Update_Waitlisted;

Procedure chk_mandatory_prereqs
         (p_delegate_person_id ota_delegate_bookings.delegate_person_id%TYPE,
	  p_delegate_contact_id ota_delegate_bookings.delegate_contact_id%TYPE,
	  p_customer_id ota_delegate_bookings.customer_id%TYPE,
	  p_event_id ota_events.event_id%TYPE,
          p_booking_status_type_id in ota_delegate_bookings.booking_status_type_id%TYPE
         ) IS

  l_delegate_person_id ota_delegate_bookings.delegate_person_id%TYPE;
  l_delegate_contact_id ota_delegate_bookings.delegate_contact_id%TYPE;
  l_customer_id ota_delegate_bookings.customer_id%TYPE;
  l_event_id ota_events.event_id%TYPE;
  l_booking_status_type_id ota_delegate_bookings.booking_status_type_id%TYPE;
  l_check_prereq boolean;
  l_old_status_type varchar2(30);
  l_new_status_type varchar2(30);

Begin
  -- Prerequisite Validation Code
  l_check_prereq := false;

  If ( p_delegate_person_id = hr_api.g_number ) Then
	l_delegate_person_id := ota_tdb_shd.g_old_rec.delegate_person_id;
  Else
	l_delegate_person_id := p_delegate_person_id;
  End If;

  If ( p_delegate_contact_id = hr_api.g_number ) Then
	l_delegate_contact_id := ota_tdb_shd.g_old_rec.delegate_contact_id;
  Else
	l_delegate_contact_id := p_delegate_contact_id;
  End If;

  If ( p_customer_id = hr_api.g_number ) Then
	l_customer_id := ota_tdb_shd.g_old_rec.customer_id;
  Else
	l_customer_id := p_customer_id;
  End If;

  If ( p_event_id = hr_api.g_number ) Then
	l_event_id := ota_tdb_shd.g_old_rec.event_id;
  Else
	l_event_id := p_event_id;
  End If;

  If ( p_booking_status_type_id = hr_api.g_number ) Then
	l_booking_status_type_id := ota_tdb_shd.g_old_rec.booking_status_type_id;
  Else
	l_booking_status_type_id := p_booking_status_type_id;
  End If;

  If (ota_general.value_changed (ota_tdb_shd.g_old_rec.delegate_person_id, l_delegate_person_id) ) Then
	l_check_prereq := true;
  End If;

  If (ota_general.value_changed (ota_tdb_shd.g_old_rec.delegate_contact_id, l_delegate_contact_id) ) Then
	l_check_prereq := true;
  End If;

  If (ota_general.value_changed (ota_tdb_shd.g_old_rec.customer_id, l_customer_id) ) Then
	l_check_prereq := true;
  End If;

  If (ota_general.value_changed (ota_tdb_shd.g_old_rec.event_id, l_event_id) ) Then
	l_check_prereq := true;
  End If;

  ota_utility.get_booking_status_type(p_status_type_id => ota_tdb_shd.g_old_rec.booking_status_type_id,
                                      p_type => l_old_status_type);

  ota_utility.get_booking_status_type(p_status_type_id => l_booking_status_type_id,
                                      p_type => l_new_status_type);

  If ( l_old_status_type = 'C' and l_new_status_type <> 'C'  ) Then
	l_check_prereq := true;
  End If;

  If ( l_check_prereq and (l_delegate_person_id is not null or l_delegate_contact_id is not null) ) Then
	ota_cpr_utility.chk_mandatory_prereqs(l_delegate_person_id, l_delegate_contact_id, l_event_id);
  End If;
--
End chk_mandatory_prereqs;

--
end ota_tdb_api_upd2;

/
