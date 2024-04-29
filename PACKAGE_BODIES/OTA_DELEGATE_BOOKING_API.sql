--------------------------------------------------------
--  DDL for Package Body OTA_DELEGATE_BOOKING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_DELEGATE_BOOKING_API" as
/* $Header: otenrapi.pkb 120.27.12010000.13 2009/12/24 11:20:17 smahanka ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := ' OTA_DELEGATE_BOOKING_API.';
g_debug boolean := hr_utility.debug_enabled;  -- Global Debug status variable
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Check New Status  >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Check the delegate booking Status when Inserting.
--
--
procedure Check_New_Status(p_event_id in number
 			  ,p_booking_status_type_id in number
			  ,p_event_status in varchar2
			  ,p_maximum_attendees in number
			  ,p_number_of_places in number) is
  --
  l_booking_status varchar2(30) := ota_tdb_bus.booking_status_type(
					p_booking_status_type_id);

Cursor   c_eval_info is
   select   decode(nvl(evt_eval.eval_mandatory_flag,'N'), 'Y', 'Y',
              decode(act_eval.evaluation_id,null,'N',decode(nvl(act_eval.eval_mandatory_flag,'N'),'Y','Y','N'))) flag  --bug 7184369
   from     ota_evaluations evt_eval,
            ota_evaluations act_eval,
            ota_events evt
   where    evt_eval.object_id(+) = evt.event_id
   and     (evt_eval.object_type is null or evt_eval.object_type = 'E')
   and      act_eval.object_id(+) = evt.activity_version_id
   and     (act_eval.object_type is null or act_eval.object_type = 'A')
   and      evt.event_id = p_event_id
   and     (evt_eval.evaluation_id is not null or act_eval.evaluation_id is not null);  --Bug7174996

   l_eval_mand varchar2(1);

  Cursor c_sign_info is
      select act.eres_enabled
      from   ota_activity_versions act,ota_Events evt
      where  act.activity_version_id = evt.activity_version_id
      and    evt.event_id = p_event_id;
  --
  l_proc 	varchar2(72) := g_package||'check_new_status';
  --
 l_sign_flag varchar2(1);
begin
  --
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check for exceeding max attendees.
  --

    if p_maximum_attendees is not null then
    --
      if (ota_evt_bus2.get_vacancies(p_event_id) < p_number_of_places) and
          l_booking_status in ('P','A','E') then
      --
       fnd_message.set_name('OTA','OTA_13558_TDB_PLACES_INC');
       fnd_message.raise_error;
      --
      end if;
    --
    end if;

  --
  -- Check new status for Full Events.
  --

  if p_event_status = 'F' and l_booking_status in ('P','A','E','C') then
  --
    fnd_message.set_name('OTA','OTA_13518_TDB_NEW_STATUS_P');
    fnd_message.raise_error;
  --
  end if;

  --
  -- 6683076.Check new status for Events with voluntary or null evaluation.
  --
    open c_eval_info;
    fetch c_eval_info into l_eval_mand;
    close c_eval_info;
    open c_sign_info;
    fetch c_sign_info into l_sign_flag;
    close c_sign_info;
    if ((l_eval_mand is null or l_eval_mand = 'N') and (l_sign_flag is null or l_sign_flag='N') and l_booking_status = 'E') then
    --
      fnd_message.set_name('OTA','OTA_467111_TDB_MAND_EVL_STATUS');
      fnd_message.raise_error;
    --
  end if;

  --
  -- Check new status for Planned Events.
  --

  if p_event_status = 'P' and l_booking_status not in ('W','R') then
  --
    fnd_message.set_name('OTA','OTA_13518_TDB_NEW_STATUS_P');
    fnd_message.raise_error;
  --
  end if;

  --
  -- Check new status for Cancelled or Closed Events.
  --
  if p_event_status in ('A','C') and l_booking_status is not null then
  --
    fnd_message.set_name('OTA','OTA_13519_TDB_NEW_STATUS_A');
    fnd_message.raise_error;
  --
  end if;

  --
  -- Check new status for Normal Events.
  --
  if p_event_status = 'N' and l_booking_status in ('C') then
  --
    fnd_message.set_name('OTA','OTA_13520_TDB_NEW_STATUS_N');
    fnd_message.raise_error;
  --
  end if;

  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
end Check_New_Status;
--


-- ----------------------------------------------------------------------------
-- |-------------------------< create_finance_header >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_finance_header
  ( p_finance_header_id            in number,
    p_result_finance_header_id     out nocopy number,
    p_result_create_finance_line   out nocopy varchar2,
    p_create_finance_line          in  varchar2,
    p_event_id                     in number,
    p_delegate_person_id           in  number,
    p_delegate_assignment_id       in  number,
    p_business_group_id_from       in  number,
    p_booking_status_type_id       in  number
   ) is

  l_auto_create_finance	varchar2(40);
  l_price_basis  ota_events.price_basis%type;
  l_business_group_id_to  	hr_all_organization_units.organization_id%type;
  l_sponsor_organization_id  	hr_all_organization_units.organization_id%type;
  l_event_currency_code      	ota_events.currency_code%type;
  l_event_title   		ota_events.title%type;
  l_course_start_date 		ota_events.course_start_date%type;
  l_course_end_date 		ota_events.course_end_date%type;
  l_owner_id  			ota_events.owner_id%type;
  l_activity_version_id 	ota_activity_versions.activity_version_id%type;
  l_offering_id 		ota_events.offering_id%type;
  l_user number;
  l_cost_allocation_keyflex_id  VARCHAR2(1000);
  l_business_group_id_from	PER_ALL_ASSIGNMENTS_F.business_group_id%TYPE;
  l_organization_id         PER_ALL_ASSIGNMENTS_F.organization_id%TYPE;
  l_booking_status_type varchar2(10);

  fapi_finance_header_id	OTA_FINANCE_LINES.finance_header_id%TYPE;
  fapi_object_version_number	OTA_FINANCE_LINES.object_version_number%TYPE;
  fapi_result			VARCHAR2(40);
  fapi_from			VARCHAR2(5);
  fapi_to			VARCHAR2(5);

CURSOR bg_to IS
SELECT hao.business_group_id,
       evt.organization_id,
       evt.currency_code,
       evt.course_start_date,
       evt.course_end_date,
       evt.Title,
       evt.owner_id,
       off.activity_version_id,
       evt.offering_id,
       nvl(evt.price_basis,NULL)
FROM   OTA_EVENTS_VL 		 evt,
       OTA_OFFERINGS         off,
       HR_ALL_ORGANIZATION_UNITS hao
WHERE  evt.event_id = p_event_id
AND    off.offering_id = evt.parent_offering_id
AND    evt.organization_id = hao.organization_id (+);

CURSOR csr_get_assignment_info IS
SELECT paf.organization_id
FROM per_all_assignments_f paf
WHERE paf.assignment_id = p_delegate_assignment_id;

CURSOR csr_get_cost_center_info IS
SELECT pcak.cost_allocation_keyflex_id
FROM per_all_assignments_f assg,
pay_cost_allocations_f pcaf,
pay_cost_allocation_keyflex pcak
WHERE assg.assignment_id = pcaf.assignment_id
AND assg.assignment_id = p_delegate_assignment_id
AND assg.Primary_flag = 'Y'
AND pcaf.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id
AND pcak.enabled_flag = 'Y'
AND sysdate between nvl(pcaf.effective_start_date,sysdate)
and nvl(pcaf.effective_end_date,sysdate+1)
AND trunc(sysdate) between nvl(assg.effective_start_date,trunc(sysdate))
and nvl(assg.effective_end_date,trunc(sysdate+1));

begin

  if(p_finance_header_id is null) then

     l_auto_create_finance   := FND_PROFILE.value('OTA_AUTO_CREATE_FINANCE');
     l_user 		         := FND_PROFILE.value('USER_ID');

      open  bg_to;
      fetch bg_to into l_business_group_id_to,
                   l_sponsor_organization_id,
                   l_event_currency_code,
                   l_course_start_date,
                   l_course_end_date,
                   l_event_title,
                   l_owner_id,
                   l_activity_version_id,
                   l_offering_id,
                   l_price_basis;
      close bg_to;


      OPEN csr_get_assignment_info;
      FETCH csr_get_assignment_info INTO l_organization_id;
      CLOSE csr_get_assignment_info;

      OPEN csr_get_cost_center_info;
      FETCH csr_get_cost_center_info INTO l_cost_allocation_keyflex_id;
      CLOSE csr_get_cost_center_info;

      select type into l_booking_status_type from ota_booking_status_types
      where booking_status_type_id = p_booking_status_type_id;

      if p_delegate_person_id is not null and l_auto_create_finance = 'Y'
         and l_price_basis <> 'N' and l_event_currency_code is not null
         and l_booking_status_type <> 'R' THEN

          ota_crt_finance_segment.Create_Segment(
                p_assignment_id		        =>	p_delegate_assignment_id,
				p_business_group_id_from    =>	p_business_group_id_from,
				p_business_group_id_to	    =>	l_business_group_id_to,
				p_organization_id	        =>	l_organization_id,
				p_sponsor_organization_id   =>	l_sponsor_organization_id,
				p_event_id		            =>	p_event_id,
				p_person_id		            => 	p_delegate_person_id,
				p_currency_code		        =>	l_event_currency_code,
				p_cost_allocation_keyflex_id=> 	l_cost_allocation_keyflex_id,
				p_user_id		            => 	l_user,
 				p_finance_header_id	        => 	fapi_finance_header_id,
				p_object_version_number	    => 	fapi_object_version_number,
				p_result		            => 	fapi_result,
				p_from_result		        => 	fapi_from,
				p_to_result		            => 	fapi_to );

	     if fapi_result = 'S' then
		    p_result_finance_header_id    := fapi_finance_header_id;
		    p_result_create_finance_line  := 'Y';
	     elsif fapi_result = 'E' then
		    p_result_finance_header_id   := NULL;
		    p_result_create_finance_line := NULL;
	     end if;
      end if;
 else
   p_result_create_finance_line := p_create_finance_line;
   p_result_finance_header_id := p_finance_header_id;
 end if;
end create_finance_header;


FUNCTION process_sign_eval_status(p_event_id IN NUMBER,
                                  p_booking_id IN NUMBER default null,
                                  p_sign_eval_status IN VARCHAR2,
                                  p_booking_status_type_id IN NUMBER)
RETURN VARCHAR2
IS
 Cursor   c_eval_info is
     select   decode(nvl(evt_eval.eval_mandatory_flag,'N'), 'Y', 'Y',
              decode(act_eval.evaluation_id,null,'N',decode(nvl(act_eval.eval_mandatory_flag,'N'),'Y','Y','N'))) flag  --bug 7184369,6935364,7174996
     from     ota_evaluations evt_eval,
              ota_evaluations act_eval,
              ota_events evt
     where    evt_eval.object_id(+) = evt.event_id
     and     (evt_eval.object_type is null or evt_eval.object_type = 'E')
     and      act_eval.object_id(+) = evt.activity_version_id
     and     (act_eval.object_type is null or act_eval.object_type = 'A')
     and      evt.event_id = p_event_id
     and     (evt_eval.evaluation_id is not null or act_eval.evaluation_id is not null);

   l_eval_mand varchar2(1):=null;
   l_proc 	varchar2(72);


  Cursor csr_sign_info is
  select act.eres_enabled
  from ota_events evt, ota_activity_versions act
  where evt.activity_version_id = act.activity_version_id
  and evt.event_id=p_event_id;

  Cursor csr_booking_info is
  select odb.sign_eval_status,bst.type
  from ota_delegate_bookings odb, ota_booking_status_types bst
  where odb.booking_status_type_id = bst.booking_status_type_id
  and odb.booking_id=p_booking_id;

  l_sign_required varchar2(1);
  l_pending_info varchar2(2);
  l_old_sign_eval_status varchar2(2);
  l_new_sign_eval_status varchar2(2);
  l_old_status_type ota_booking_status_types.type%type;
  l_type ota_booking_status_types.type%type;
  l_manual_update boolean:=false;
  l_status_change boolean:=false;
  --p_sign_eval_status varchar2(2) := 'NN';
BEGIN
if g_debug then
  l_proc  := g_package||'process_sign_eval_status';
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.trace('p_sign_eval_status:'||p_sign_eval_status);
end if;

  open csr_sign_info;
  fetch csr_sign_info into l_sign_required;
  close csr_sign_info;

  open c_eval_info;
  fetch c_eval_info into l_eval_mand;
  close c_eval_info;

  open csr_booking_info;
  fetch csr_booking_info into l_old_sign_eval_status, l_old_status_type;
  close csr_booking_info;

  if p_booking_id is not null then
        if l_old_sign_eval_status is null then
            return null;
        elsif p_sign_eval_status is not null then
            return p_sign_eval_status;
        end if;
  end if;
  select Type into l_type from ota_booking_status_types where booking_status_type_id=p_booking_status_type_id;
  l_manual_update:= (p_booking_id is not null) and (p_sign_eval_status is null) and (l_old_sign_eval_status is not null);
  l_status_change:= (p_booking_id is not null) and (l_type <>l_old_status_type);
  if l_manual_update and l_status_change then
     if l_type='A' then
         if (l_old_sign_eval_status in ('SD','SE','UD','UE','VD','VE')) then
            fnd_message.set_name('OTA','OTA_467197_ERES_ENRST_CHNG_ERR');
            fnd_message.raise_error;
         end if;
     elsif l_old_status_type='A' and l_old_sign_eval_status='DD' then
         fnd_message.set_name('OTA','OTA_467198_ERES_COMP_ERR');
         fnd_message.raise_error;
     end if;
  end if;
--9241537
  if l_sign_required is null then
  		l_sign_required := 'N';
  end if;
--end of changes for 9241537.
  if ((p_sign_eval_status is null) and (p_booking_id is null)) or (l_manual_update and l_status_change) then
    l_pending_info := l_sign_required||l_eval_mand;
    case l_pending_info
        when 'YY' then l_new_sign_eval_status := 'S';		--Sign and mandatory evaluation exist.
        when 'YN' then l_new_sign_eval_status := 'V';		--Sign and voluntary(optional) evaluation exist.
        when 'NY' then l_new_sign_eval_status := 'M';		--mandatory evaluation exists.
        when 'NN' then l_new_sign_eval_status := 'O';		--voluntary(optional) evaluation exists.
        when 'Y'  then l_new_sign_eval_status := 'U';		--Sign only exists.
        else l_new_sign_eval_status := null;
    end case;

    if l_new_sign_eval_status is not null then
         if l_type not in('A','E') then
            l_new_sign_eval_status := l_new_sign_eval_status||'D';	--Disabled.
         elsif l_type = 'A' then
            l_new_sign_eval_status := l_new_sign_eval_status||'F';	--Forcibly closed.
         elsif l_type = 'E' then
            l_new_sign_eval_status := l_new_sign_eval_status||'E';	--Enabled
         end if;
    end if;
  elsif p_sign_eval_status is null then
      return null;
  end if;

  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 10);
  end if;

  return l_new_sign_eval_status;

END process_sign_eval_status;

-- ----------------------------------------------------------------------------
-- |-------------------------< create_delegate_booking >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_delegate_booking
  ( p_validate                     in  boolean,
    p_effective_date               in  date,
    p_booking_id                   out nocopy number,
    p_booking_status_type_id       in  number,
    p_delegate_person_id           in  number            ,
    p_contact_id                   in  number,
    p_business_group_id            in  number,
    p_event_id                     in  number,
    p_customer_id                  in  number            ,
    p_authorizer_person_id         in  number            ,
    p_date_booking_placed          in  date,
    p_corespondent                 in  varchar2          ,
    p_internal_booking_flag        in  varchar2,
    p_number_of_places             in  number,
    p_object_version_number        out nocopy number,
    p_administrator                in  number            ,
    p_booking_priority             in  varchar2          ,
    p_comments                     in  varchar2          ,
    p_contact_address_id           in  number            ,
    p_delegate_contact_phone       in  varchar2          ,
    p_delegate_contact_fax         in  varchar2          ,
    p_third_party_customer_id      in  number            ,
    p_third_party_contact_id       in  number            ,
    p_third_party_address_id       in  number            ,
    p_third_party_contact_phone    in  varchar2          ,
    p_third_party_contact_fax      in  varchar2          ,
    p_date_status_changed          in  date              ,
    p_failure_reason               in  varchar2          ,
    p_attendance_result            in  varchar2          ,
    p_language_id                  in  number            ,
    p_source_of_booking            in  varchar2          ,
    p_special_booking_instructions in  varchar2          ,
    p_successful_attendance_flag   in  varchar2          ,
    p_tdb_information_category     in  varchar2          ,
    p_tdb_information1             in  varchar2          ,
    p_tdb_information2             in  varchar2          ,
    p_tdb_information3             in  varchar2          ,
    p_tdb_information4             in  varchar2          ,
    p_tdb_information5             in  varchar2          ,
    p_tdb_information6             in  varchar2          ,
    p_tdb_information7             in  varchar2          ,
    p_tdb_information8             in  varchar2          ,
    p_tdb_information9             in  varchar2          ,
    p_tdb_information10            in  varchar2          ,
    p_tdb_information11            in  varchar2          ,
    p_tdb_information12            in  varchar2          ,
    p_tdb_information13            in  varchar2          ,
    p_tdb_information14            in  varchar2          ,
    p_tdb_information15            in  varchar2          ,
    p_tdb_information16            in  varchar2          ,
    p_tdb_information17            in  varchar2          ,
    p_tdb_information18            in  varchar2          ,
    p_tdb_information19            in  varchar2          ,
    p_tdb_information20            in  varchar2          ,
    p_create_finance_line          in  varchar2          ,
    p_finance_header_id            in  number            ,
    p_currency_code                in  varchar2          ,
    p_standard_amount              in  number            ,
    p_unitary_amount               in  number            ,
    p_money_amount                 in  number            ,
    p_booking_deal_id              in  number            ,
    p_booking_deal_type            in  varchar2          ,
    p_finance_line_id              in  out nocopy number,
    p_enrollment_type              in  varchar2          ,
    p_organization_id              in  number            ,
    p_sponsor_person_id            in  number            ,
    p_sponsor_assignment_id        in  number            ,
    p_person_address_id            in  number            ,
    p_delegate_assignment_id       in  number            ,
    p_delegate_contact_id          in  number            ,
    p_delegate_contact_email       in  varchar2          ,
    p_third_party_email            in  varchar2          ,
    p_person_address_type          in  varchar2          ,
    p_line_id                      in  number            ,
    p_org_id                       in  number            ,
    p_daemon_flag                  in  varchar2          ,
    p_daemon_type                  in  varchar2          ,
    p_old_event_id                 in  number            ,
    p_quote_line_id                in  number            ,
    p_interface_source             in  varchar2          ,
    p_total_training_time          in  varchar2          ,
    p_content_player_status        in  varchar2          ,
    p_score                        in  number            ,
    p_completed_content            in  number            ,
    p_total_content                in  number            ,
    p_booking_justification_id     in number             ,
    p_is_history_flag	 	 in varchar2	       ,
    p_override_prerequisites       in varchar2           ,
    p_override_learner_access      in varchar2           ,
    p_book_from                    in varchar2           ,
    p_is_mandatory_enrollment      in varchar2		   ,
    p_sign_eval_status             in varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_delegate_booking ';

  l_date_booking_placed     date;
  l_date_status_changed     date;
  l_effective_date          date;

  l_object_version_number number;
  l_booking_id number;
  l_dummy number;
  l_event_status 		varchar2(30);
  l_maximum_attendees 		number;
  l_maximum_internal_attendees 	number;
  l_evt_object_version_number 	number;
  l_event_rec			ota_evt_shd.g_rec_type;
  l_event_exists		boolean;

  l_lp_enrollment_ids varchar2(4000);
  l_cert_prd_enrollment_ids varchar2(4000);
  l_item_key     wf_items.item_key%type;

  l_type ota_booking_status_types.type%type;


  l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                                 hr_dflex_utility.l_ignore_dfcode_varray();
  l_ignore_dff_validation varchar2(1);
  v_forum_id        number;
  v_business_group_id   number;

  l_create_finance_line  varchar2(4);
  l_finance_header_id number;
  l_result_create_finance_line  varchar2(4);
  l_result_finance_header_id number;
  l_automatic_transfer_gl varchar2(40);

  Cursor chk_for_comp_upd is
    select ocu.online_flag , off.Learning_object_id from ota_category_usages ocu,
      ota_offerings off , ota_events oev
      where ocu.category_usage_id = off.delivery_mode_id
      and off.offering_id = oev.parent_offering_id
      and oev.event_id = p_event_id;

  Cursor csr_forums_for_class is
    Select fr.forum_id, fr.business_group_id from
    ota_forums_b fr,
    ota_frm_obj_inclusions foi
    where fr.forum_id = foi.forum_id
    and foi.object_type = 'E'
    and foi.object_id = p_event_id
    and fr.auto_notification_flag = 'Y';
    l_comp_upd varchar2(1000) :='MoveToHistoryImage';
    l_on_flag varchar2(100);
    l_LO_id ota_offerings.Learning_object_id%type;

  --Bug 5386501
  Cursor csr_class_data is
    Select title from ota_events_vl
    where event_id = p_event_id;
  l_class_name ota_events_tl.title%type;
  l_incoming_status_type varchar2(30);

  --Bug 6683076
  Cursor   c_eval_info is
     select   decode(nvl(evt_eval.eval_mandatory_flag,'N'), 'Y', 'Y',
              decode(act_eval.evaluation_id,null,'N',decode(nvl(act_eval.eval_mandatory_flag,'N'),'Y','Y','N'))) flag  --bug 7184369,6935364,7174996
     from     ota_evaluations evt_eval,
              ota_evaluations act_eval,
              ota_events evt
     where    evt_eval.object_id(+) = evt.event_id
     and     (evt_eval.object_type is null or evt_eval.object_type = 'E')
     and      act_eval.object_id(+) = evt.activity_version_id
     and     (act_eval.object_type is null or act_eval.object_type = 'A')
     and      evt.event_id = p_event_id
     and     (evt_eval.evaluation_id is not null or act_eval.evaluation_id is not null);  --bug 7174996

   l_eval_mand varchar2(1);

  cursor csr_get_currency_code is
  select currency_code from ota_events
  where event_id = p_event_id;

  l_currency_code  varchar2(40);
  l_new_sign_eval_status ota_delegate_bookings.sign_eval_status%type;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_delegate_booking;

  open csr_get_currency_code;
  fetch csr_get_currency_code into l_currency_code;
  close csr_get_currency_code;

  l_new_sign_eval_status:=process_sign_eval_status(p_event_id,null,p_sign_eval_status,p_booking_status_type_id);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
--  l_date_booking_placed := trunc(p_date_booking_placed);
  l_date_booking_placed := p_date_booking_placed;
  l_date_status_changed := trunc(p_date_status_changed);

  --
    -- Validation in addition to Table Handlers
    --
   -- Prerequisite Validation Code
    -- Can be overridden if p_override_prerequisites parameter is 'Y'
    -- get booking status type

     ota_utility.get_booking_status_type(p_status_type_id=>p_booking_status_type_id,
                                         p_type => l_incoming_status_type);

       If ( p_override_prerequisites = 'N' and nvl(l_incoming_status_type,'-1')<>'C'
            and (p_delegate_person_id is not null or p_delegate_contact_id is not null) ) Then --Bug 4686100
  	     --Call local method
  	      ota_cpr_utility.chk_mandatory_prereqs(p_delegate_person_id, p_delegate_contact_id, p_event_id);
       End If;

    IF p_override_learner_access <> 'Y' THEN
    --
    -- check that the delegate is eligible to be booked on to the event
    --
    ota_tdb_bus.check_delegate_eligible (p_event_id,
                             p_customer_id,
                             p_delegate_contact_id,
                             p_organization_id,
                             p_delegate_person_id,
                             p_delegate_assignment_id);
    -- Added for bug#4606760
    ELSIF p_delegate_person_id IS NOT NULL THEN
      ota_tdb_bus.check_secure_event(p_event_id, p_delegate_person_id);

    END IF;

    --
    -- Lock Event
    --
    OPEN csr_class_data;--Bug 5386501
    FETCH csr_class_data into l_class_name;
    begin
      ota_evt_bus2.lock_event(p_event_id);
      exception
      when others then
        fnd_message.set_name('OTA','OTA_443997_EVT_ROW_LCK_ERR');
        fnd_message.set_token('CLASS_NAME', l_class_name);
        fnd_message.raise_error;
    end;


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
    --  Validation Check on event / booking statuses
    --

    Check_New_Status(p_event_id
                    ,p_booking_Status_type_id
                    ,l_event_rec.event_status
                    ,l_event_rec.maximum_attendees
                    ,p_number_of_places);

  -- Bug#7270603
  create_finance_header(
            p_finance_header_id        => p_finance_header_id,
            p_result_finance_header_id => l_finance_header_id,
            p_result_create_finance_line => l_create_finance_line,
            p_create_finance_line      => p_create_finance_line,
            p_event_id                 => p_event_id,
            p_delegate_person_id       => p_delegate_person_id,
            p_delegate_assignment_id   => p_delegate_assignment_id,
            p_business_group_id_from   => p_business_group_id,
            p_booking_status_type_id   => p_booking_status_type_id);

  --
  -- Call Before Process User Hook
  --
  begin
    ota_delegate_booking_bk1.create_delegate_booking_b
 (p_effective_date             => l_effective_date           ,
  p_booking_status_type_id       => p_booking_status_type_id ,
  p_delegate_person_id           => p_delegate_person_id     ,
  p_contact_id                   => p_contact_id             ,
  p_business_group_id            => p_business_group_id      ,
  p_event_id                     => p_event_id               ,
  p_customer_id                  => p_customer_id            ,
  p_authorizer_person_id         => p_authorizer_person_id   ,
  p_date_booking_placed          => l_date_booking_placed    ,
  p_corespondent                 => p_corespondent           ,
  p_internal_booking_flag        => p_internal_booking_flag  ,
  p_number_of_places             => p_number_of_places       ,
  p_administrator                => p_administrator          ,
  p_booking_priority             => p_booking_priority       ,
  p_comments                     => p_comments               ,
  p_contact_address_id           => p_contact_address_id     ,
  p_delegate_contact_phone       => p_delegate_contact_phone ,
  p_delegate_contact_fax         => p_delegate_contact_fax   ,
  p_third_party_customer_id      => p_third_party_customer_id     ,
  p_third_party_contact_id       => p_third_party_contact_id      ,
  p_third_party_address_id       => p_third_party_address_id      ,
  p_third_party_contact_phone    => p_third_party_contact_phone   ,
  p_third_party_contact_fax      => p_third_party_contact_fax     ,
  p_date_status_changed          => l_date_status_changed         ,
  p_failure_reason               => p_failure_reason              ,
  p_attendance_result            => p_attendance_result           ,
  p_language_id                  => p_language_id                 ,
  p_source_of_booking            => p_source_of_booking           ,
  p_special_booking_instructions =>p_special_booking_instructions ,
  p_successful_attendance_flag   => p_successful_attendance_flag  ,
  p_tdb_information_category     => p_tdb_information_category    ,
  p_tdb_information1             => p_tdb_information1            ,
  p_tdb_information2             => p_tdb_information2            ,
  p_tdb_information3             => p_tdb_information3            ,
  p_tdb_information4             => p_tdb_information4            ,
  p_tdb_information5             => p_tdb_information5            ,
  p_tdb_information6             => p_tdb_information6            ,
  p_tdb_information7             => p_tdb_information7            ,
  p_tdb_information8             => p_tdb_information8            ,
  p_tdb_information9             => p_tdb_information9            ,
  p_tdb_information10            => p_tdb_information10           ,
  p_tdb_information11            => p_tdb_information11           ,
  p_tdb_information12            => p_tdb_information12           ,
  p_tdb_information13            => p_tdb_information13           ,
  p_tdb_information14            => p_tdb_information14           ,
  p_tdb_information15            => p_tdb_information15           ,
  p_tdb_information16            => p_tdb_information16           ,
  p_tdb_information17            => p_tdb_information17           ,
  p_tdb_information18            => p_tdb_information18           ,
  p_tdb_information19            => p_tdb_information19           ,
  p_tdb_information20            => p_tdb_information20           ,
  p_create_finance_line          => l_create_finance_line         ,
  p_finance_header_id            => l_finance_header_id           ,
  p_currency_code                => p_currency_code               ,
  p_standard_amount              => p_standard_amount             ,
  p_unitary_amount               => p_unitary_amount              ,
  p_money_amount                 => p_money_amount                ,
  p_booking_deal_id              => p_booking_deal_id             ,
  p_booking_deal_type            => p_booking_deal_type           ,
  p_finance_line_id              => p_finance_line_id             ,
  p_enrollment_type              => p_enrollment_type             ,
  p_organization_id              => p_organization_id             ,
  p_sponsor_person_id            => p_sponsor_person_id           ,
  p_sponsor_assignment_id        => p_sponsor_assignment_id       ,
  p_person_address_id            =>  p_person_address_id          ,
  p_delegate_assignment_id       => p_delegate_assignment_id      ,
  p_delegate_contact_id          => p_delegate_contact_id         ,
  p_delegate_contact_email       => p_delegate_contact_email      ,
  p_third_party_email            => p_third_party_email           ,
  p_person_address_type          => p_person_address_type         ,
  p_line_id        		 => p_line_id          		  ,
  p_org_id         		 => p_org_id           		  ,
  p_daemon_flag          	 => p_daemon_flag                 ,
  p_daemon_type          	 => p_daemon_type                 ,
  p_old_event_id                 => p_old_event_id                ,
  p_quote_line_id                => p_quote_line_id               ,
  p_interface_source             => p_interface_source            ,
  p_total_training_time          => p_total_training_time         ,
  p_content_player_status        => p_content_player_status       ,
  p_score               	 => p_score                       ,
  p_completed_content       	 => p_completed_content      	  ,
  p_total_content          	 => p_total_content		  ,
  p_booking_justification_id 	 => p_booking_justification_id	  ,
  p_is_history_flag		 => p_is_history_flag ,
  p_is_mandatory_enrollment  => p_is_mandatory_enrollment
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_delegate_booking_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  --
      ota_tdb_ins.ins(
        l_booking_id
      , p_booking_status_type_id
      , p_delegate_person_id
      , p_contact_id
      , p_business_group_id
      , p_event_id
      , p_customer_id
      , p_authorizer_person_id
      , p_date_booking_placed
      , p_corespondent
      , p_internal_booking_flag
      , p_number_of_places
      , l_object_version_number
      , p_administrator
      , p_booking_priority
      , p_comments
      , p_contact_address_id
      , p_delegate_contact_phone
      , p_delegate_contact_fax
      , p_third_party_customer_id
      , p_third_party_contact_id
      , p_third_party_address_id
      , p_third_party_contact_phone
      , p_third_party_contact_fax
      , p_date_status_changed
      , p_failure_reason
      , p_attendance_result
      , p_language_id
      , p_source_of_booking
      , p_special_booking_instructions
      , p_successful_attendance_flag
      , p_tdb_information_category
      , p_tdb_information1
      , p_tdb_information2
      , p_tdb_information3
      , p_tdb_information4
      , p_tdb_information5
      , p_tdb_information6
      , p_tdb_information7
      , p_tdb_information8
      , p_tdb_information9
      , p_tdb_information10
      , p_tdb_information11
      , p_tdb_information12
      , p_tdb_information13
      , p_tdb_information14
      , p_tdb_information15
      , p_tdb_information16
      , p_tdb_information17
      , p_tdb_information18
      , p_tdb_information19
      , p_tdb_information20
      , l_create_finance_line
      , l_finance_header_id
      , p_currency_code
      , p_standard_amount
      , p_unitary_amount
      , p_money_amount
      , p_booking_deal_id
      , p_booking_deal_type
      , p_finance_line_id
      , p_enrollment_type
      , p_validate
      , p_organization_id
      , p_sponsor_person_id
      , p_sponsor_assignment_id
      , p_person_address_id
      , p_delegate_assignment_id
      , p_delegate_contact_id
      , p_delegate_contact_email
      , p_third_party_email
      , p_person_address_type
      , p_line_id
      , p_org_id
      , p_daemon_flag
      , p_daemon_type
      , p_old_event_id
      , p_quote_line_id
      , p_interface_source
      , p_total_training_time
      , p_content_player_status
      , p_score
      , p_completed_content
      , p_total_content
      , p_booking_justification_id
      , p_is_history_flag
      , l_new_sign_eval_status
      , p_is_mandatory_enrollment);
  --

    --
    -- Set all output arguments
    --
    p_booking_id              := l_booking_id;
    p_object_version_number   := l_object_version_number;

    ota_tdb_bus.ota_letter_lines
                   (p_booking_id             => p_booking_id,
                    p_booking_status_type_id => p_booking_status_type_id,
                    p_event_id               => p_event_id,
                    p_delegate_person_id     => p_delegate_person_id);

    ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => p_event_id,
                                                           p_person_id         => p_delegate_person_id,
                                                           p_contact_id        => p_delegate_contact_id,
                                                           p_lp_enrollment_ids => l_lp_enrollment_ids);

    -- update any associated cert member enrollment statuses
    ota_cme_util.update_cme_status(p_event_id          => p_event_id,
                                   p_person_id         => p_delegate_person_id,
                                   p_contact_id        => p_delegate_contact_id,
                                   p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

    select Type into l_type from ota_booking_status_types where booking_status_type_id=p_booking_status_type_id;

    if l_type='A' and p_delegate_contact_id is null and p_contact_id is null then

      -- check whether class is online or not
      if p_successful_attendance_flag = 'Y' then
          ota_competence_ss.create_wf_process(p_process 	=>'OTA_COMPETENCE_UPDATE_JSP_PRC',
              p_itemtype 		=>'HRSSA',
              p_person_id 	=> p_delegate_person_id,
              p_eventid       =>p_event_id,
              p_learningpath_ids => null,
              p_itemkey    =>l_item_key);

       end if;

    end if;

    --
    -- fire learner enrollment notification
          if p_contact_id is null and p_delegate_contact_id is null
             and nvl(p_book_from,'-1') <> 'AME'
	     and l_event_rec.event_type in ('SCHEDULED','SELFPACED')then
              -- call learner ntf process

              OTA_LRNR_ENROLL_UNENROLL_WF.learner_enrollment(p_process => 'OTA_LNR_TRNG_APPROVAL_JSP_PRC',
                                                          p_itemtype => 'HRSSA',
                                                          p_person_id => p_delegate_person_id,
                                                          p_eventid => p_event_id,
                                                          p_booking_id => p_booking_id);
                   --Bug 6683076

   	                     /*open c_eval_info;
		              fetch c_eval_info into l_eval_mand;
		              close c_eval_info; 8893725*/

		              if(l_new_sign_eval_status in('ME','OE')) then
		                    ota_initialization_wf.init_course_eval_notif(p_booking_id);
                       	      end if;

           end if;

    if l_create_finance_line = 'Y' then
    --
     ota_finance.maintain_finance_line(p_finance_header_id => l_finance_header_id,
                                       p_booking_id        => p_booking_id   ,
                                       p_currency_code     => l_currency_code    ,
                                       p_standard_amount   => p_standard_amount,
                                       p_unitary_amount    => p_unitary_amount   ,
                                       p_money_amount      => p_money_amount     ,
                                       p_booking_deal_id   => p_booking_deal_id  ,
                                       p_booking_deal_type => p_booking_deal_type,
                                       p_object_version_number => l_dummy,
                                       p_finance_line_id   => p_finance_line_id);

        l_automatic_transfer_gl := FND_PROFILE.value('OTA_SSHR_AUTO_GL_TRANSFER');
        if l_automatic_transfer_gl = 'Y' AND p_finance_line_id IS NOT NULL THEN
    	   UPDATE ota_finance_lines SET transfer_status = 'AT'
		   WHERE finance_line_id = p_finance_line_id;
	    end if;
    --
    end if;
    --
    --
    hr_utility.set_location(l_proc, 7);

    --
    -- Reset Event Status
    --
    ota_evt_bus2.reset_event_status(p_event_id
                                   ,l_event_rec.object_version_number
                                   ,l_event_rec.event_status
                                   ,l_event_rec.maximum_attendees);
    --
    hr_utility.set_location(l_proc, 8);

    if ( l_ignore_dff_validation = 'Y' ) then
  	  hr_dflex_utility.remove_ignore_df_validation;
    end if;


   --create frm_notif_subscriber record, only if the enrollment status is 'P' or 'A'
   if (l_type='A' OR l_type = 'P') then
     OPEN csr_forums_for_class;
     FETCH csr_forums_for_class into v_forum_id, v_business_group_id;

     LOOP
       Exit When csr_forums_for_class%notfound OR csr_forums_for_class%notfound is null;

       ota_fns_ins.ins
        (  p_effective_date             => l_effective_date
          ,p_business_group_id          => v_business_group_id
          ,p_forum_id                   => v_forum_id
          ,p_person_id                  => p_delegate_person_id
          ,p_contact_id                 => p_delegate_contact_id
          ,p_object_version_number      => p_object_version_number
        );

       FETCH csr_forums_for_class into v_forum_id, v_business_group_id;
     End Loop;
     Close csr_forums_for_class;
   end if;

  /*
  ota_tdb_api_ins2.create_enrollment
 (p_booking_id                   => p_booking_id             ,
  p_booking_status_type_id       => p_booking_status_type_id ,
  p_delegate_person_id           => p_delegate_person_id     ,
  p_contact_id                   => p_contact_id             ,
  p_business_group_id            => p_business_group_id      ,
  p_event_id                     => p_event_id               ,
  p_customer_id                  => p_customer_id            ,
  p_authorizer_person_id         => p_authorizer_person_id   ,
  p_date_booking_placed          => l_date_booking_placed    ,
  p_corespondent                 => p_corespondent           ,
  p_internal_booking_flag        => p_internal_booking_flag  ,
  p_number_of_places             => p_number_of_places       ,
  p_object_version_number        => p_object_version_number  ,
  p_administrator                => p_administrator          ,
  p_booking_priority             => p_booking_priority       ,
  p_comments                     => p_comments               ,
  p_contact_address_id           => p_contact_address_id     ,
  p_delegate_contact_phone       => p_delegate_contact_phone ,
  p_delegate_contact_fax         => p_delegate_contact_fax   ,
  p_third_party_customer_id      => p_third_party_customer_id     ,
  p_third_party_contact_id       => p_third_party_contact_id      ,
  p_third_party_address_id       => p_third_party_address_id      ,
  p_third_party_contact_phone    => p_third_party_contact_phone   ,
  p_third_party_contact_fax      => p_third_party_contact_fax     ,
  p_date_status_changed          => l_date_status_changed         ,
  p_failure_reason               => p_failure_reason              ,
  p_attendance_result            => p_attendance_result           ,
  p_language_id                  => p_language_id                 ,
  p_source_of_booking            => p_source_of_booking           ,
  p_special_booking_instructions =>p_special_booking_instructions ,
  p_successful_attendance_flag   => p_successful_attendance_flag  ,
  p_tdb_information_category     => p_tdb_information_category    ,
  p_tdb_information1             => p_tdb_information1            ,
  p_tdb_information2             => p_tdb_information2            ,
  p_tdb_information3             => p_tdb_information3            ,
  p_tdb_information4             => p_tdb_information4            ,
  p_tdb_information5             => p_tdb_information5            ,
  p_tdb_information6             => p_tdb_information6            ,
  p_tdb_information7             => p_tdb_information7            ,
  p_tdb_information8             => p_tdb_information8            ,
  p_tdb_information9             => p_tdb_information9            ,
  p_tdb_information10            => p_tdb_information10           ,
  p_tdb_information11            => p_tdb_information11           ,
  p_tdb_information12            => p_tdb_information12           ,
  p_tdb_information13            => p_tdb_information13           ,
  p_tdb_information14            => p_tdb_information14           ,
  p_tdb_information15            => p_tdb_information15           ,
  p_tdb_information16            => p_tdb_information16           ,
  p_tdb_information17            => p_tdb_information17           ,
  p_tdb_information18            => p_tdb_information18           ,
  p_tdb_information19            => p_tdb_information19           ,
  p_tdb_information20            => p_tdb_information20           ,
  p_create_finance_line          => p_create_finance_line         ,
  p_finance_header_id            => p_finance_header_id           ,
  p_currency_code                => p_currency_code               ,
  p_standard_amount              => p_standard_amount             ,
  p_unitary_amount               => p_unitary_amount       ,
  p_money_amount                 => p_money_amount                ,
  p_booking_deal_id              => p_booking_deal_id             ,
  p_booking_deal_type            => p_booking_deal_type           ,
  p_finance_line_id              => p_finance_line_id             ,
  p_enrollment_type              => p_enrollment_type             ,
  p_validate                     => p_validate                    ,
  p_organization_id              => p_organization_id             ,
  p_sponsor_person_id            => p_sponsor_person_id           ,
  p_sponsor_assignment_id        => p_sponsor_assignment_id       ,
  p_person_address_id            =>  p_person_address_id          ,
  p_delegate_assignment_id       => p_delegate_assignment_id      ,
  p_delegate_contact_id          => p_delegate_contact_id         ,
  p_delegate_contact_email       => p_delegate_contact_email      ,
  p_third_party_email            => p_third_party_email           ,
  p_person_address_type          => p_person_address_type         ,
  p_line_id                      => p_line_id                     ,
  p_org_id                       => p_org_id                      ,
  p_daemon_flag                  => p_daemon_flag                 ,
  p_daemon_type                   => p_daemon_type                ,
  p_old_event_id                 => p_old_event_id                ,
  p_quote_line_id                => p_quote_line_id               ,
  p_interface_source             => p_interface_source            ,
  p_total_training_time          => p_total_training_time         ,
  p_content_player_status        => p_content_player_status       ,
  p_score                        => p_score                       ,
  p_completed_content            => p_completed_content           ,
  p_total_content                => p_total_content               ,
  p_booking_justification_id     => p_booking_justification_id    ,
  p_override_prerequisites       => p_override_prerequisites      ,
  p_override_learner_access      => p_override_learner_access
);
*/

  --
  -- Call After Process User Hook
  --
  begin
  OTA_delegate_booking_bk1.create_delegate_booking_a
 (p_effective_date               => l_effective_date              ,
  p_booking_status_type_id       => p_booking_status_type_id      ,
  p_delegate_person_id           => p_delegate_person_id          ,
  p_contact_id                   => p_contact_id                  ,
  p_business_group_id            => p_business_group_id           ,
  p_event_id                     => p_event_id                    ,
  p_customer_id                  => p_customer_id                 ,
  p_authorizer_person_id         => p_authorizer_person_id        ,
  p_date_booking_placed          => l_date_booking_placed         ,
  p_corespondent                 => p_corespondent                ,
  p_internal_booking_flag        => p_internal_booking_flag       ,
  p_number_of_places             => p_number_of_places            ,
  p_administrator                => p_administrator               ,
  p_booking_priority             => p_booking_priority            ,
  p_comments                     => p_comments                    ,
  p_contact_address_id           => p_contact_address_id          ,
  p_delegate_contact_phone       => p_delegate_contact_phone      ,
  p_delegate_contact_fax         => p_delegate_contact_fax        ,
  p_third_party_customer_id      => p_third_party_customer_id     ,
  p_third_party_contact_id       => p_third_party_contact_id      ,
  p_third_party_address_id       => p_third_party_address_id      ,
  p_third_party_contact_phone    => p_third_party_contact_phone   ,
  p_third_party_contact_fax      => p_third_party_contact_fax     ,
  p_date_status_changed          => l_date_status_changed         ,
  p_failure_reason               => p_failure_reason              ,
  p_attendance_result            => p_attendance_result           ,
  p_language_id                  => p_language_id                 ,
  p_source_of_booking            => p_source_of_booking           ,
  p_special_booking_instructions =>p_special_booking_instructions ,
  p_successful_attendance_flag   => p_successful_attendance_flag  ,
  p_tdb_information_category     => p_tdb_information_category    ,
  p_tdb_information1             => p_tdb_information1            ,
  p_tdb_information2             => p_tdb_information2            ,
  p_tdb_information3             => p_tdb_information3            ,
  p_tdb_information4             => p_tdb_information4            ,
  p_tdb_information5             => p_tdb_information5            ,
  p_tdb_information6             => p_tdb_information6            ,
  p_tdb_information7             => p_tdb_information7            ,
  p_tdb_information8             => p_tdb_information8            ,
  p_tdb_information9             => p_tdb_information9            ,
  p_tdb_information10            => p_tdb_information10           ,
  p_tdb_information11            => p_tdb_information11           ,
  p_tdb_information12            => p_tdb_information12           ,
  p_tdb_information13            => p_tdb_information13           ,
  p_tdb_information14            => p_tdb_information14           ,
  p_tdb_information15            => p_tdb_information15           ,
  p_tdb_information16            => p_tdb_information16           ,
  p_tdb_information17            => p_tdb_information17           ,
  p_tdb_information18            => p_tdb_information18           ,
  p_tdb_information19            => p_tdb_information19           ,
  p_tdb_information20            => p_tdb_information20           ,
  p_create_finance_line          => l_create_finance_line         ,
  p_finance_header_id            => l_finance_header_id           ,
  p_currency_code                => p_currency_code               ,
  p_standard_amount              => p_standard_amount             ,
  p_unitary_amount               => p_unitary_amount       ,
  p_money_amount                 => p_money_amount                ,
  p_booking_deal_id              => p_booking_deal_id             ,
  p_booking_deal_type            => p_booking_deal_type           ,
  p_finance_line_id              => p_finance_line_id             ,
  p_enrollment_type              => p_enrollment_type             ,
  p_organization_id              => p_organization_id             ,
  p_sponsor_person_id            => p_sponsor_person_id           ,
  p_sponsor_assignment_id        => p_sponsor_assignment_id       ,
  p_person_address_id            =>  p_person_address_id          ,
  p_delegate_assignment_id       => p_delegate_assignment_id      ,
  p_delegate_contact_id          => p_delegate_contact_id         ,
  p_delegate_contact_email       => p_delegate_contact_email      ,
  p_third_party_email            => p_third_party_email           ,
  p_person_address_type          => p_person_address_type         ,
  p_line_id                      => p_line_id                     ,
  p_org_id                       => p_org_id                      ,
  p_daemon_flag                  => p_daemon_flag                 ,
  p_daemon_type                  => p_daemon_type                 ,
  p_old_event_id                 => p_old_event_id                ,
  p_quote_line_id                => p_quote_line_id               ,
  p_interface_source             => p_interface_source            ,
  p_total_training_time          => p_total_training_time         ,
  p_content_player_status        => p_content_player_status       ,
  p_score                        => p_score                       ,
  p_completed_content            => p_completed_content      ,
  p_total_content                => p_total_content,
  p_booking_justification_id     => p_booking_justification_id,
  p_is_history_flag		 => p_is_history_flag ,
  p_is_mandatory_enrollment => p_is_mandatory_enrollment,
  p_booking_id                   => p_booking_id
);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_delegate_booking_a'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_delegate_booking;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number   := null;
    p_booking_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_delegate_booking;
    p_object_version_number :=  null;
    p_booking_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_delegate_booking ;
--
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

  Cursor   c_eval_info is
     select   decode(nvl(evt_eval.eval_mandatory_flag,'N'), 'Y', 'Y',
              decode(act_eval.evaluation_id,null,'N',decode(nvl(act_eval.eval_mandatory_flag,'N'),'Y','Y','N'))) flag  --bug 7184369
     from     ota_evaluations evt_eval,
              ota_evaluations act_eval,
              ota_events evt
     where    evt_eval.object_id(+) = evt.event_id
     and     (evt_eval.object_type is null or evt_eval.object_type = 'E')
     and      act_eval.object_id(+) = evt.activity_version_id
     and     (act_eval.object_type is null or act_eval.object_type = 'A')
     and      evt.event_id = p_event_id
     and     (evt_eval.evaluation_id is not null or act_eval.evaluation_id is not null);  --Bug7174996

  Cursor c_sign_info is
      select act.eres_enabled
      from   ota_activity_versions act,ota_Events evt
      where  act.activity_version_id = evt.activity_version_id
      and    evt.event_id = p_event_id;

   l_eval_mand varchar2(1);
   l_sign_flag varchar2(1);
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

  --Added for bug 6817203-Error message is displayed when learners with
  --enrollment status Placed or Attended are moved to Planned class.
    if p_event_id <> l_old_event_id and
       l_booking_status in ('A','P') and
       p_event_status = 'P'   then

    	fnd_message.set_name('OTA','OTA_13518_TDB_NEW_STATUS_P');
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
  -- 6683076.Check for Events with voluntary or null evaluation.
  --
    open c_eval_info;
    fetch c_eval_info into l_eval_mand;
    close c_eval_info;
    open c_sign_info;
    fetch c_sign_info into l_sign_flag;
    close c_sign_info;
    if ((l_eval_mand is null or l_eval_mand = 'N') and (l_sign_flag is null or l_sign_flag='N') and l_booking_status = 'E') then
    --
	fnd_message.set_name('OTA','OTA_467111_TDB_MAND_EVL_STATUS');
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
      ota_evt_bus2.get_vacancies(p_event_id) >= p_number_of_places
      and p_event_status <> 'P' then
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
--bug# 5231470 first date format changed from DD-MON-YYYY to DD/MM/YYYY
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
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_delegate_booking >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_delegate_booking
  (
  p_validate                     in  boolean,
  p_effective_date               in  date,
  p_booking_id                   in  number,
  p_booking_status_type_id       in  number,
  p_delegate_person_id           in  number,
  p_contact_id                   in  number,
  p_business_group_id            in  number,
  p_event_id                     in  number,
  p_customer_id                  in  number,
  p_authorizer_person_id         in  number,
  p_date_booking_placed          in  date ,
  p_corespondent                 in  varchar2,
  p_internal_booking_flag        in  varchar2,
  p_number_of_places             in  number,
  p_object_version_number        in  out nocopy number,
  p_administrator                in  number,
  p_booking_priority             in  varchar2,
  p_comments                     in  varchar2,
  p_contact_address_id           in  number,
  p_delegate_contact_phone       in  varchar2,
  p_delegate_contact_fax         in  varchar2,
  p_third_party_customer_id      in  number,
  p_third_party_contact_id       in  number,
  p_third_party_address_id       in  number,
  p_third_party_contact_phone    in  varchar2,
  p_third_party_contact_fax      in  varchar2,
  p_date_status_changed          in  date ,
  p_status_change_comments       in  varchar2,
  p_failure_reason               in  varchar2,
  p_attendance_result            in  varchar2,
  p_language_id                  in  number,
  p_source_of_booking            in  varchar2,
  p_special_booking_instructions in  varchar2,
  p_successful_attendance_flag   in  varchar2,
  p_tdb_information_category     in  varchar2,
  p_tdb_information1             in  varchar2,
  p_tdb_information2             in  varchar2,
  p_tdb_information3             in  varchar2,
  p_tdb_information4             in  varchar2,
  p_tdb_information5             in  varchar2,
  p_tdb_information6             in  varchar2,
  p_tdb_information7             in  varchar2,
  p_tdb_information8             in  varchar2,
  p_tdb_information9             in  varchar2,
  p_tdb_information10            in  varchar2,
  p_tdb_information11            in  varchar2,
  p_tdb_information12            in  varchar2,
  p_tdb_information13            in  varchar2,
  p_tdb_information14            in  varchar2,
  p_tdb_information15            in  varchar2,
  p_tdb_information16            in  varchar2,
  p_tdb_information17            in  varchar2,
  p_tdb_information18            in  varchar2,
  p_tdb_information19            in  varchar2,
  p_tdb_information20            in  varchar2,
  p_update_finance_line          in  varchar2,
  p_tfl_object_version_number    in  out nocopy number,
  p_finance_header_id            in  number,
  p_finance_line_id              in  out nocopy number,
  p_standard_amount              in  number,
  p_unitary_amount               in  number,
  p_money_amount                 in  number,
  p_currency_code                in  varchar2,
  p_booking_deal_type            in  varchar2,
  p_booking_deal_id              in  number,
  p_enrollment_type              in  varchar2,
  p_organization_id              in  number,
  p_sponsor_person_id            in  number,
  p_sponsor_assignment_id        in  number,
  p_person_address_id            in  number,
  p_delegate_assignment_id       in  number,
  p_delegate_contact_id          in  number,
  p_delegate_contact_email       in  varchar2,
  p_third_party_email            in  varchar2,
  p_person_address_type          in  varchar2,
  p_line_id                      in  number,
  p_org_id                       in  number,
  p_daemon_flag                  in  varchar2,
  p_daemon_type                  in  varchar2,
  p_old_event_id                 in  number,
  p_quote_line_id                in  number,
  p_interface_source             in  varchar2,
  p_total_training_time          in  varchar2,
  p_content_player_status        in  varchar2,
  p_score                        in  number,
  p_completed_content            in  number,
  p_total_content                in  number,
  p_booking_justification_id     in  number,
  p_is_history_flag       	 in  varchar2
 ,p_override_prerequisites 	 in  varchar2
 ,p_override_learner_access 	 in  varchar2
 ,p_source_cancel                in  varchar2
 ,p_sign_eval_status             in varchar2
 ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' update_delegate_booking ';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;
  l_date_booking_placed     date;
  l_date_status_changed     date;
  l_tfl_object_version_number number     := p_tfl_object_version_number ;
  l_finance_line_id           number     := p_finance_line_id ;

  l_status_type_id_changed   boolean;
  --Added for Bug#4106893
  l_event_id_changed boolean := false;
  l_person_id_changed boolean := false;
  l_contact_id_changed boolean := false;

  l_cancel_finance_line      boolean;
  l_event_rec			ota_evt_shd.g_rec_type;
  l_event_exists		boolean;
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
  l_daemon_type VARCHAR2(30) := p_daemon_type;
  l_daemon_flag VARCHAR2(30) := p_daemon_flag;

  --bug 603768 changes starts
  l_hours_until_class_starts 	NUMBER := 0;
  l_sysdate 			VARCHAR2(30);
  l_course_start_date     ota_events.course_start_date%TYPE;
  l_course_start_time       ota_events.course_start_time%TYPE;
  l_event_title             ota_events.title%TYPE;
  l_old_event_id ota_delegate_bookings.event_id%TYPE;
  l_owner_id                ota_events.owner_id%TYPE;
  l_username 	fnd_user.user_name%TYPE;
  l_auto_waitlist_days 	NUMBER;
  l_auto_waitlist varchar2(1) := 'N';
  l_waitlist_size NUMBER := 0;


  CURSOR event_csr(p_old_event_id ota_events.event_id%TYPE) IS
  SELECT oet.title,oe.course_start_date,oe.course_start_time,oe.owner_id
  FROM ota_events_tl oet, ota_events oe
  WHERE  oet.event_id = oe.event_id
  AND oe.event_id = p_old_event_id
  AND oet.language = userenv('LANG');


  CURSOR sys_date_csr IS
  SELECT to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS')
  FROM dual;

  CURSOR fnduser_csr(l_owner_id ota_events.owner_id%TYPE) IS
  SELECT user_name
  FROM fnd_user
  WHERE employee_id = l_owner_id
  AND trunc(sysdate) BETWEEN trunc(start_date) AND nvl(trunc(end_date),trunc(sysdate)+1);
  --bug 603768 changes ends

  --Bug6801749:ANY CHANGE BY ADMIN TO ENROLLMENT CAUSED DATE_STATUS_CHANGED UPDATE
  l_booking_status_type_changed boolean := false;
  l_existing_booking_status_id ota_delegate_bookings.booking_status_type_id%TYPE;
  l_new_booking_status_type_id ota_delegate_bookings.booking_status_type_id%TYPE := p_booking_status_type_id;

  CURSOR csr_get_cur_booking_status IS
  SELECT booking_status_type_id
  FROM  ota_delegate_bookings
  WHERE booking_id = p_booking_id;

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

  CURSOR c_get_fin_line_status IS
   SELECT cancelled_flag
   FROM ota_finance_lines
   WHERE finance_line_id = p_finance_line_id;

   l_cancelled_flag ota_finance_lines.cancelled_flag%TYPE;
   --Bug 6683076
   Cursor   c_eval_info is
      select   evt_eval.evaluation_id evt_eval_id,decode(nvl(evt_eval.eval_mandatory_flag,'N'), 'Y', 'Y',
               decode(act_eval.evaluation_id,null,'N',decode(nvl(act_eval.eval_mandatory_flag,'N'),'Y','Y','N'))) flag,  --bug 7184369,6935364,7174996
		   act_eval.evaluation_id act_eval_id
      from     ota_evaluations evt_eval,
               ota_evaluations act_eval,
               ota_events evt
      where    evt_eval.object_id(+) = evt.event_id
      and     (evt_eval.object_type is null or evt_eval.object_type = 'E')
      and      act_eval.object_id(+) = evt.activity_version_id
      and     (act_eval.object_type is null or act_eval.object_type = 'A')
      and      evt.event_id = p_event_id
      and     (evt_eval.evaluation_id is not null or act_eval.evaluation_id is not null);  --Bug7174996

   l_eval_mand varchar2(1);
   l_evt_eval_id ota_tests.test_id%type;
   l_act_eval_id ota_tests.test_id%type;
   l_temp number;

   Cursor c_attempt_info(l_user_id ota_attempts.user_id%type,l_user_type ota_attempts.user_type%type) is
        select  1
        from    ota_attempts
        where   event_id = p_event_id
        and     test_id = l_evt_eval_id
        and     user_id = l_user_id
        and     user_type = l_user_type;

   Cursor c_contact_user_id is
        select rel.subject_id
        from    hz_cust_account_roles acct_role,
                hz_relationships rel,
                hz_cust_accounts role_acct
        where   acct_role.party_id = rel.party_id
        and     acct_role.role_type = 'CONTACT'
        and     acct_role.cust_account_id = role_acct.cust_account_id
        and     role_acct.party_id = rel.object_id
        and     rel.subject_table_name = 'HZ_PARTIES'
        and     rel.object_table_name = 'HZ_PARTIES'
        and     acct_role.cust_account_role_id = nvl(p_delegate_contact_id,p_contact_id);

  CURSOR csr_hr_lookup( p_lookup_type 	VARCHAR2, p_lookup_code	VARCHAR2) IS
    SELECT meaning
    FROM hr_lookups
    WHERE lookup_type = p_lookup_type
    AND lookup_code = p_lookup_code
    AND enabled_flag = 'Y'
    AND sysdate between NVL(start_date_active, sysdate) AND NVL(end_date_active, (sysdate+1));

  CURSOR c_sign_info IS
		SELECT sign_eval_status
    FROM ota_delegate_bookings
    WHERE booking_id = p_booking_id;

l_contact_user_id ota_attempts.user_id%type;
l_old_sign_eval_status ota_delegate_bookings.sign_eval_status%type;
l_new_sign_eval_status ota_delegate_bookings.sign_eval_status%type;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if g_debug then
  --hr_utility.set_location('Entering:'||l_proc, 10);
  HR_UTILITY.TRACE ('SIGN_EVAL_STATUS: ' || p_sign_eval_status);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_delegate_booking ;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --l_date_booking_placed := trunc(p_date_booking_placed);
  l_date_booking_placed := p_date_booking_placed;
  l_date_status_changed := trunc(p_date_status_changed);
  --

  -- Call Before Process User Hook
  --
  begin
    ota_delegate_booking_bk2.update_delegate_booking_b
 (
  p_effective_date               => l_effective_date         ,
  p_booking_id                   => p_booking_id             ,
  p_booking_status_type_id       => p_booking_status_type_id ,
  p_delegate_person_id           => p_delegate_person_id     ,
  p_contact_id                   => p_contact_id             ,
  p_business_group_id            => p_business_group_id      ,
  p_event_id                     => p_event_id               ,
  p_customer_id                  => p_customer_id            ,
  p_authorizer_person_id         => p_authorizer_person_id   ,
  p_date_booking_placed          => l_date_booking_placed    ,
  p_corespondent                 => p_corespondent           ,
  p_internal_booking_flag        => p_internal_booking_flag  ,
  p_number_of_places             => p_number_of_places       ,
  p_object_version_number        => p_object_version_number  ,
  p_administrator                => p_administrator          ,
  p_booking_priority             => p_booking_priority       ,
  p_comments                     => p_comments               ,
  p_contact_address_id           => p_contact_address_id     ,
  p_delegate_contact_phone       => p_delegate_contact_phone ,
  p_delegate_contact_fax         => p_delegate_contact_fax   ,
  p_third_party_customer_id      => p_third_party_customer_id     ,
  p_third_party_contact_id       => p_third_party_contact_id      ,
  p_third_party_address_id       => p_third_party_address_id      ,
  p_third_party_contact_phone    => p_third_party_contact_phone   ,
  p_third_party_contact_fax      => p_third_party_contact_fax     ,
  p_date_status_changed          => l_date_status_changed         ,
  p_status_change_comments       => p_status_change_comments      ,
  p_failure_reason               => p_failure_reason              ,
  p_attendance_result            => p_attendance_result           ,
  p_language_id                  => p_language_id                 ,
  p_source_of_booking            => p_source_of_booking           ,
  p_special_booking_instructions =>p_special_booking_instructions ,
  p_successful_attendance_flag   => p_successful_attendance_flag  ,
  p_tdb_information_category     => p_tdb_information_category    ,
  p_tdb_information1             => p_tdb_information1            ,
  p_tdb_information2             => p_tdb_information2            ,
  p_tdb_information3             => p_tdb_information3            ,
  p_tdb_information4             => p_tdb_information4            ,
  p_tdb_information5             => p_tdb_information5            ,
  p_tdb_information6             => p_tdb_information6            ,
  p_tdb_information7             => p_tdb_information7            ,
  p_tdb_information8             => p_tdb_information8            ,
  p_tdb_information9             => p_tdb_information9            ,
  p_tdb_information10            => p_tdb_information10           ,
  p_tdb_information11            => p_tdb_information11           ,
  p_tdb_information12            => p_tdb_information12           ,
  p_tdb_information13            => p_tdb_information13           ,
  p_tdb_information14            => p_tdb_information14           ,
  p_tdb_information15            => p_tdb_information15           ,
  p_tdb_information16            => p_tdb_information16           ,
  p_tdb_information17            => p_tdb_information17           ,
  p_tdb_information18            => p_tdb_information18           ,
  p_tdb_information19            => p_tdb_information19           ,
  p_tdb_information20            => p_tdb_information20           ,
  p_update_finance_line          => p_update_finance_line         ,
  p_tfl_object_version_number    => p_tfl_object_version_number   ,
  p_finance_header_id            => p_finance_header_id           ,
  p_finance_line_id              => l_finance_line_id             ,
  p_standard_amount              => p_standard_amount             ,
  p_unitary_amount               => p_unitary_amount       ,
  p_money_amount                 => p_money_amount                ,
  p_currency_code                => p_currency_code               ,
  p_booking_deal_type            => p_booking_deal_type           ,
  p_booking_deal_id              => p_booking_deal_id             ,
  p_enrollment_type              => p_enrollment_type             ,
  p_organization_id              => p_organization_id             ,
  p_sponsor_person_id            => p_sponsor_person_id           ,
  p_sponsor_assignment_id        => p_sponsor_assignment_id       ,
  p_person_address_id            =>  p_person_address_id          ,
  p_delegate_assignment_id       => p_delegate_assignment_id      ,
  p_delegate_contact_id          => p_delegate_contact_id         ,
  p_delegate_contact_email       => p_delegate_contact_email      ,
  p_third_party_email            => p_third_party_email           ,
  p_person_address_type          => p_person_address_type         ,
  p_line_id                      => p_line_id          ,
  p_org_id                       => p_org_id           ,
  p_daemon_flag                  => p_daemon_flag                 ,
  p_daemon_type                  => p_daemon_type                 ,
  p_old_event_id                 => p_old_event_id                ,
  p_quote_line_id                => p_quote_line_id               ,
  p_interface_source             => p_interface_source            ,
  p_total_training_time          => p_total_training_time         ,
  p_content_player_status        => p_content_player_status       ,
  p_score                        => p_score                       ,
  p_completed_content            => p_completed_content      ,
  p_total_content                => p_total_content,
  p_booking_justification_id     => p_booking_justification_id,
  p_is_history_flag		 => p_is_history_flag
);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_delegate_booking_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
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

     IF ( p_override_prerequisites = 'N' ) Then
        --Call local method
        chk_mandatory_prereqs(p_delegate_person_id, p_delegate_contact_id, p_customer_id, p_event_id, p_booking_status_type_id);
     END IF;

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

       IF l_event_id_changed or
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

     --Bug6801749
  OPEN csr_get_cur_booking_status;
  FETCH csr_get_cur_booking_status INTO l_existing_booking_status_id;
  CLOSE csr_get_cur_booking_status;

  IF l_new_booking_status_type_id = hr_api.g_number THEN
  	l_new_booking_status_type_id := l_existing_booking_status_id;
  END IF;
  l_booking_status_type_changed := ota_general.value_changed(l_existing_booking_status_id,l_new_booking_status_type_id);

  IF l_booking_status_type_changed then
	l_date_status_changed := trunc(sysdate);
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
       OPEN get_status_info;
       FETCH get_status_info INTO l_enroll_type;
       CLOSE get_status_info;
    --
    -- Get Event record
    --
    ota_evt_shd.get_event_details (p_event_id,
                                   l_event_rec,
                                   l_event_exists);

    -- Ignore Enrollment Dff Validation for some cases
    IF ( (l_event_rec.price_basis = 'C' and p_contact_id is not null) or (l_event_rec.line_id is not null) or (p_line_id is not null) ) then
  	  l_add_struct_d.extend(1);
  	  l_add_struct_d(l_add_struct_d.count) := 'OTA_DELEGATE_BOOKINGS';
  	  hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);
            l_ignore_dff_validation := 'Y';
    ELSE
            l_ignore_dff_validation := 'N';
    END IF;

    --
    --  Validation Check on booking / event statuses
    --
    Check_Status_Change(p_event_id
                       ,p_booking_Status_type_id
                       ,l_event_rec.event_status
                       ,p_number_of_places
                       ,l_event_rec.maximum_attendees);

--Added for 7046809.
    open chk_for_comp_upd;
    fetch chk_for_comp_upd into l_on_flag,l_LO_id ;
    close chk_for_comp_upd;

    open c_eval_info;
    fetch c_eval_info into l_evt_eval_id,l_eval_mand,l_act_eval_id;
    close c_eval_info;
    l_evt_eval_id := nvl(l_evt_eval_id,l_act_eval_id);
    if l_incoming_status_type = 'E' and l_booking_status_type_changed and l_on_flag = 'N' then
        if p_delegate_contact_id is null and p_contact_id is null then
               open c_attempt_info(p_delegate_person_id,'E');
               fetch c_attempt_info into l_temp;
               close c_attempt_info;
        else
               open c_contact_user_id;
               fetch c_contact_user_id into l_contact_user_id;
               close c_contact_user_id;
               open c_attempt_info(l_contact_user_id,'C');
               fetch c_attempt_info into l_temp;
               close c_attempt_info;
        end if;
        if l_temp=1 then
            fnd_message.set_name('OTA','OTA_467126_STAT_CHG_PE_ERR');
            fnd_message.raise_error;
        end if;
    end if;
--end of changes for 7046809.
--8893725
  	open c_sign_info;
  	fetch c_sign_info into l_old_sign_eval_status;
  	close c_sign_info;
--8893725
	l_new_sign_eval_status:=process_sign_eval_status(p_event_id,p_booking_id,p_sign_eval_status,p_booking_status_type_id);

    --
    --Bug 2359495
    IF ( p_status_change_comments IS NULL or p_status_change_comments = hr_api.g_varchar2) THEN --Bug 5586486
       open csr_hr_lookup('ENROLMENT_STATUS_REASON', 'A');  --Bug#7476314
       fetch csr_hr_lookup into l_status_change_comments;
       close csr_hr_lookup;
	/*l_status_change_comments := hr_general_utilities.get_lookup_meaning
                                   ('ENROLMENT_STATUS_REASON',
                                    'A');*/
    ELSE
       l_status_change_comments := p_status_change_comments;
  END IF;

  --
  -- Process Logic
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
       l_date_status_changed,   --p_date_status_changed,Bug6801749
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
    -- p_daemon_flag,
    -- p_daemon_type,
       p_old_event_id,
       p_quote_line_id,
       p_interface_source,
       p_total_training_time,
       p_content_player_status,
       p_score,
       p_completed_content,
       p_total_content,
       p_booking_justification_id,
       p_is_history_flag,
       l_new_sign_eval_status
  );

  --
/*
  ota_tdb_api_upd2.update_enrollment
 (p_booking_id                   => p_booking_id           ,
  p_booking_status_type_id       => p_booking_status_type_id ,
  p_delegate_person_id           => p_delegate_person_id     ,
  p_contact_id                   => p_contact_id             ,
  p_business_group_id            => p_business_group_id      ,
  p_event_id                     => p_event_id               ,
  p_customer_id                  => p_customer_id            ,
  p_authorizer_person_id         => p_authorizer_person_id   ,
  p_date_booking_placed          => l_date_booking_placed    ,
  p_corespondent                 => p_corespondent           ,
  p_internal_booking_flag        => p_internal_booking_flag  ,
  p_number_of_places             => p_number_of_places       ,
  p_object_version_number        => p_object_version_number  ,
  p_administrator                => p_administrator          ,
  p_booking_priority             => p_booking_priority       ,
  p_comments                     => p_comments               ,
  p_contact_address_id           => p_contact_address_id     ,
  p_delegate_contact_phone       => p_delegate_contact_phone ,
  p_delegate_contact_fax         => p_delegate_contact_fax   ,
  p_third_party_customer_id      => p_third_party_customer_id     ,
  p_third_party_contact_id       => p_third_party_contact_id      ,
  p_third_party_address_id       => p_third_party_address_id      ,
  p_third_party_contact_phone    => p_third_party_contact_phone   ,
  p_third_party_contact_fax      => p_third_party_contact_fax     ,
  p_date_status_changed          => l_date_status_changed         ,
  p_status_change_comments       => p_status_change_comments      ,
  p_failure_reason               => p_failure_reason              ,
  p_attendance_result            => p_attendance_result           ,
  p_language_id                  => p_language_id                 ,
  p_source_of_booking            => p_source_of_booking           ,
  p_special_booking_instructions =>p_special_booking_instructions ,
  p_successful_attendance_flag   => p_successful_attendance_flag  ,
  p_tdb_information_category     => p_tdb_information_category    ,
  p_tdb_information1             => p_tdb_information1            ,
  p_tdb_information2             => p_tdb_information2            ,
  p_tdb_information3             => p_tdb_information3            ,
  p_tdb_information4             => p_tdb_information4            ,
  p_tdb_information5             => p_tdb_information5            ,
  p_tdb_information6             => p_tdb_information6            ,
  p_tdb_information7             => p_tdb_information7            ,
  p_tdb_information8             => p_tdb_information8            ,
  p_tdb_information9             => p_tdb_information9            ,
  p_tdb_information10            => p_tdb_information10           ,
  p_tdb_information11            => p_tdb_information11           ,
  p_tdb_information12            => p_tdb_information12           ,
  p_tdb_information13            => p_tdb_information13           ,
  p_tdb_information14            => p_tdb_information14           ,
  p_tdb_information15            => p_tdb_information15           ,
  p_tdb_information16            => p_tdb_information16           ,
  p_tdb_information17            => p_tdb_information17           ,
  p_tdb_information18            => p_tdb_information18           ,
  p_tdb_information19            => p_tdb_information19           ,
  p_tdb_information20            => p_tdb_information20           ,
  p_update_finance_line          => p_update_finance_line         ,
  p_tfl_object_version_number    => p_tfl_object_version_number   ,
  p_finance_header_id            => p_finance_header_id           ,
  p_currency_code                => p_currency_code               ,
  p_standard_amount              => p_standard_amount             ,
  p_unitary_amount               => p_unitary_amount       ,
  p_money_amount                 => p_money_amount                ,
  p_booking_deal_id              => p_booking_deal_id             ,
  p_booking_deal_type            => p_booking_deal_type           ,
  p_finance_line_id              => l_finance_line_id             ,
  p_enrollment_type              => p_enrollment_type             ,
  p_validate                     => p_validate                    ,
  p_organization_id              => p_organization_id             ,
  p_sponsor_person_id            => p_sponsor_person_id           ,
  p_sponsor_assignment_id        => p_sponsor_assignment_id       ,
  p_person_address_id            =>  p_person_address_id          ,
  p_delegate_assignment_id       => p_delegate_assignment_id      ,
  p_delegate_contact_id          => p_delegate_contact_id         ,
  p_delegate_contact_email       => p_delegate_contact_email      ,
  p_third_party_email            => p_third_party_email           ,
  p_person_address_type          => p_person_address_type         ,
  p_line_id        => p_line_id          ,
  p_org_id         => p_org_id           ,
  p_daemon_flag          => p_daemon_flag                 ,
  p_daemon_type          => p_daemon_type                 ,
  p_old_event_id                 => p_old_event_id                ,
  p_quote_line_id                => p_quote_line_id               ,
  p_interface_source             => p_interface_source            ,
  p_total_training_time          => p_total_training_time         ,
  p_content_player_status        => p_content_player_status       ,
  p_score               => p_score                       ,
  p_completed_content       => p_completed_content      ,
  p_total_content          => p_total_content,
  p_booking_justification_id => p_booking_justification_id,
  p_is_history_flag  => p_is_history_flag
 ,p_override_prerequisites 	 => p_override_prerequisites
 ,p_override_learner_access 	 => p_override_learner_access
);
*/
  --
  l_status_type_id_changed  :=
       ota_general.value_changed (ota_tdb_shd.g_old_rec.booking_status_type_id,
                                  p_booking_status_type_id);

  -- Getting the old booking status to manipulate the fourm notification records
  l_old_booking_status := ota_tdb_bus.booking_status_type(
 				 ota_tdb_shd.g_old_rec.booking_status_type_id);

  OPEN is_contact;
  FETCH is_contact INTO l_contact_id,l_delegate_contact_id;
  CLOSE is_contact;

  IF (p_delegate_person_id = hr_api.g_number) THEN
      select delegate_person_id  into l_person_id from ota_delegate_bookings
                                where booking_id = p_booking_id;
    else l_person_id := p_delegate_person_id;
  END IF;

  --
  -- Added by dbatra
  -- this is to take care of granting competencies attached to LP which are completed
  -- but course under it was not successfully attended intitially.

  IF (not l_status_type_id_changed) and p_successful_attendance_flag ='Y' THEN
    IF l_delegate_contact_id is null and l_contact_id is null THEN

      ota_lrng_path_util.start_comp_proc_success_attnd(p_person_id =>l_person_id
                                                      ,p_event_id => p_event_id);

      ota_cpe_util.crt_comp_upd_succ_att(p_person_id =>l_person_id
                                        ,p_event_id => p_event_id);

    END IF;
  END IF;

  --
  IF l_status_type_id_changed or p_successful_attendance_flag ='Y' THEN
    --
    -- Added by dbatra for training plan
    -- Bug 2982183
    IF l_delegate_contact_id is null and l_contact_id is null and l_status_type_id_changed THEN

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

      ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => p_event_id,
                                                             p_person_id         => l_person_id,
                                                             p_contact_id        => null,
                                                             p_lp_enrollment_ids => l_lp_enrollment_ids);

   	-- update any associated cert member enrollment statuses
       ota_cme_util.update_cme_status(p_event_id          => p_event_id,
                                      p_person_id         => l_person_id,
                                      p_contact_id        => null,
                                      p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

    ELSIF l_delegate_contact_id IS NOT NULL THEN
       ota_lrng_path_member_util.update_lme_enroll_status_chg(p_event_id          => p_event_id,
                                                              p_person_id         => null,
                                                              p_contact_id        => l_delegate_contact_id,
                                                              p_lp_enrollment_ids => l_lp_enrollment_ids);
       -- update any associated cert member enrollment statuses
       ota_cme_util.update_cme_status(p_event_id          => p_event_id,
                                      p_person_id         => null,
                                      p_contact_id        => l_delegate_contact_id,
                                      p_cert_prd_enrollment_ids => l_cert_prd_enrollment_ids);

    END IF; -- contact_id

    select Type into l_type from ota_booking_status_types where booking_status_type_id=p_booking_status_type_id;

    IF l_type='A' and l_delegate_contact_id is null and l_contact_id IS NULL THEN

	-- check whether class is online or not
     /* OPEN chk_for_comp_upd;
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

        IF p_successful_attendance_flag = 'Y' THEN
          ota_competence_ss.create_wf_process(p_process 	 =>'OTA_COMPETENCE_UPDATE_JSP_PRC',
                                              p_itemtype  	 =>'HRSSA',
                                              p_person_id  	 => l_person_id,
                                              p_eventid          =>p_event_id,
                                              p_learningpath_ids => null,
                                              p_itemkey          =>l_item_key);

        END IF;


     END IF;

    -- fire learner enrollment notification --Bug#7111940
          if (p_contact_id is null
             and p_delegate_contact_id is null
             --and nvl(p_book_from,'-1') <> 'AME'
	         and l_event_rec.event_type in ('SCHEDULED','SELFPACED')
             and l_type = 'P') then
               -- call learner ntf process
               OTA_LRNR_ENROLL_UNENROLL_WF.learner_enrollment(p_process => 'OTA_LNR_TRNG_APPROVAL_JSP_PRC',
                                                          p_itemtype => 'HRSSA',
                                                          p_person_id => p_delegate_person_id,
                                                          p_eventid => p_event_id,
                                                          p_booking_id => p_booking_id);

           end if;

     --- send ntf to waitlisted learner

     IF l_enroll_type = 'W' and l_type = 'P'
        and l_delegate_contact_id is null and l_contact_id is null then

        OTA_INITIALIZATION_WF.initialize_wf(p_process     => 'OTA_ENROLL_STATUS_CHNG_JSP_PRC',
                                            p_item_type   => 'OTWF',
                                            p_eventid 	  => p_event_id,
                                            p_person_id   => l_person_id,
                                            p_event_fired => 'ENROLL_STATUS_CHNG');

     END IF;

     -- send cancel enrollment ntf

     IF l_type ='C' and l_delegate_contact_id is null and l_contact_id IS NULL
        and nvl(p_source_cancel,'-1') <> 'AME'
	and l_event_rec.event_type in ('SCHEDULED','SELFPACED') then

       OTA_LRNR_ENROLL_UNENROLL_WF.learner_unenrollment(p_process   => 'OTA_LNR_TRNG_CANCEL_JSP_PRC',
                                                        p_itemtype  => 'HRSSA',
                                                        p_person_id => l_person_id,
                                                        p_eventid   => p_event_id);

     END IF;

    -- Bug 2982183
    --Bug 5452795
    if l_status_type_id_changed then
    ota_tdb_bus.maintain_status_history
                            (p_booking_status_type_id,
                             l_date_status_changed, --p_date_status_changed,Bug6801749
                             p_administrator,
                             l_status_change_comments, --p_status_change_comments,Bug 2359495
                             p_booking_id,
                             ota_tdb_shd.g_old_rec.date_status_changed,
                             ota_tdb_shd.g_old_rec.booking_status_type_id,
                             ota_tdb_shd.g_created_by,
                             p_date_booking_placed);
  end if;
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
  END IF;
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

  --bug 603768 changes starts
  --Send ntf to class owner if any enrollment has been cancelled
  --or deleted or class changed
   l_old_event_id := ota_tdb_shd.g_old_rec.event_id;
   l_auto_waitlist :=  fnd_profile.value('OTA_AUTO_WAITLIST_ACTIVE');
   l_waitlist_size := ota_utility.students_on_waitlist(l_old_event_id);

   if (l_auto_waitlist = 'Y' and l_waitlist_size > 0) then

        if(l_old_booking_status = 'P' or l_old_booking_status = 'A' ) then

          OPEN event_csr (l_old_event_id);
          FETCH event_csr INTO l_event_title,l_course_start_date,l_course_start_time,l_owner_id;
          CLOSE event_csr;

          if ( l_course_start_date is not null ) then
            l_hours_until_class_starts := 24*(to_date(to_char(l_course_start_date, 'DD-MM-YYYY')||''||l_course_start_time, 'DD/MM/YYYYHH24:MI') - SYSDATE);
          end if;

          l_auto_waitlist_days := TO_NUMBER(fnd_profile.value('OTA_AUTO_WAITLIST_DAYS'));

          if (l_hours_until_class_starts <= nvl(l_auto_waitlist_days,0) )then

             OPEN sys_date_csr;
             FETCH sys_date_csr INTO l_sysdate;
             CLOSE sys_date_csr;

             if (l_owner_id is null) then
                l_owner_id := fnd_profile.value('OTA_DEFAULT_EVENT_OWNER');
             end if;

             OPEN fnduser_csr(l_owner_id);
             FETCH fnduser_csr INTO l_username;
             CLOSE fnduser_csr;

            if(l_event_id_changed) then

                OTA_INITIALIZATION_WF.MANUAL_WAITLIST(
          	                    p_itemtype 		=> 'OTWF',
				                p_process	=> 'OTA_ENROLLMENT_EVENT_CHANGED',
				                p_Event_title	=> l_event_title,
				                p_event_id      => l_old_event_id,
				                p_item_key 	=> p_booking_id ||':'||l_sysdate,
				                p_user_name	=> l_username);

            else
              if( l_type is not null and (l_type = 'C' or l_type = 'R') ) then

                 OTA_INITIALIZATION_WF.MANUAL_WAITLIST(
          	                    p_itemtype 		=> 'OTWF',
		                		p_process		=> 'OTA_MANUAL_WAITLIST',
				                p_Event_title	=> l_event_title,
				                p_event_id      => l_old_event_id,
				                p_item_key 	=> p_booking_id ||':'||l_sysdate,
				                p_user_name	=> l_username);
              end if;
            end if;
          end if;
        end if;
    end if;
  --bug 603768 changes ends
  --If the new enrollment status is 'C' or 'R' or 'W' then delete the forum notitifcation record
  IF l_type = 'C' or l_type = 'R' or l_type = 'W' then
    deleteForumNotification(p_event_id,l_person_id, l_delegate_contact_id);
  END IF;

  --If the booking status is changed from 'C','W' or 'R' to 'P' or 'A',
  --then we need to create a new forum notification record.
  IF l_old_booking_status = 'C' or l_old_booking_status = 'W' or l_old_booking_status ='R'
         and l_type = 'P' or l_type = 'A' THEN
   IF NOT l_event_id_changed and NOT l_person_id_changed AND NOT l_contact_id_changed THEN
    IF l_person_id IS NOT NULL THEN
       createForumNotification(p_event_id,l_person_id, null, l_effective_date, p_booking_status_type_id);
    ELSIF l_delegate_contact_id IS NOT NULL THEN
       createForumNotification(p_event_id, null, l_delegate_contact_id, l_effective_date, p_booking_status_type_id);
    END IF;
   END IF;
 END IF;

  /**
       When the class name is changed for an enrollment, the lme update must be called
       twice, once for the old class and once for the new class.
       When the learner name is changed for an enrollment, the lme update must be called
       twice, once for the old learner and once for the new learner.
       If both the learner aswell as class associated with an enrollment are changed,
       update lme must be called once for old class, old learner and once for new class and new learner
  **/
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
      -- and create a notification record for the new class and new person
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

  --bug#6683076.Added for sending notifications to learners for
    -- taking evaluations.
  if (l_old_sign_eval_status is not null and (l_old_sign_eval_status<>l_new_sign_eval_status)) then  --bug#8893725

			if(l_new_sign_eval_status in('ME','OE')) then
		        ota_initialization_wf.init_course_eval_notif(p_booking_id);
      		end if;
  end if;

 --end of changes for evaluations.

  IF p_update_finance_line in ('C','Y') THEN
  --
    l_cancel_finance_line := (p_update_finance_line = 'C');
    -- Added for bug#5519140
    OPEN c_get_fin_line_status;
    FETCH c_get_fin_line_status INTO l_cancelled_flag;

    IF l_cancelled_flag <> 'Y' OR c_get_fin_line_status%NOTFOUND THEN
      IF (p_update_finance_line = 'C') THEN
        OTA_LEARNER_ENROLL_SS.cancel_finance(p_booking_id); --Bug#7110214
      ELSE
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
      END IF;
    END IF;
    CLOSE c_get_fin_line_status;
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
  IF p_event_id <> ota_tdb_shd.g_old_rec.event_id THEN
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
  END IF;

  IF ( l_ignore_dff_validation = 'Y') THEN
	  hr_dflex_utility.remove_ignore_df_validation;
  END IF;

  --
  -- Call After Process User Hook
  --
  begin
  OTA_delegate_booking_bk2.update_delegate_booking_a
  (p_effective_date             => l_effective_date           ,
  p_booking_id                   => p_booking_id              ,
  p_booking_status_type_id       => p_booking_status_type_id ,
  p_delegate_person_id           => p_delegate_person_id     ,
  p_contact_id                   => p_contact_id             ,
  p_business_group_id            => p_business_group_id      ,
  p_event_id                     => p_event_id               ,
  p_customer_id                  => p_customer_id            ,
  p_authorizer_person_id         => p_authorizer_person_id   ,
  p_date_booking_placed          => l_date_booking_placed    ,
  p_corespondent                 => p_corespondent           ,
  p_internal_booking_flag        => p_internal_booking_flag  ,
  p_number_of_places             => p_number_of_places       ,
  p_object_version_number        => p_object_version_number  ,
  p_administrator                => p_administrator          ,
  p_booking_priority             => p_booking_priority       ,
  p_comments                     => p_comments               ,
  p_contact_address_id           => p_contact_address_id     ,
  p_delegate_contact_phone       => p_delegate_contact_phone ,
  p_delegate_contact_fax         => p_delegate_contact_fax   ,
  p_third_party_customer_id      => p_third_party_customer_id     ,
  p_third_party_contact_id       => p_third_party_contact_id      ,
  p_third_party_address_id       => p_third_party_address_id      ,
  p_third_party_contact_phone    => p_third_party_contact_phone   ,
  p_third_party_contact_fax      => p_third_party_contact_fax     ,
  p_date_status_changed          => l_date_status_changed         ,
  p_status_change_comments       => p_status_change_comments      ,
  p_failure_reason               => p_failure_reason              ,
  p_attendance_result            => p_attendance_result           ,
  p_language_id                  => p_language_id                 ,
  p_source_of_booking            => p_source_of_booking           ,
  p_special_booking_instructions =>p_special_booking_instructions ,
  p_successful_attendance_flag   => p_successful_attendance_flag  ,
  p_tdb_information_category     => p_tdb_information_category    ,
  p_tdb_information1             => p_tdb_information1            ,
  p_tdb_information2             => p_tdb_information2            ,
  p_tdb_information3             => p_tdb_information3            ,
  p_tdb_information4             => p_tdb_information4            ,
  p_tdb_information5             => p_tdb_information5            ,
  p_tdb_information6             => p_tdb_information6            ,
  p_tdb_information7             => p_tdb_information7            ,
  p_tdb_information8             => p_tdb_information8            ,
  p_tdb_information9             => p_tdb_information9            ,
  p_tdb_information10            => p_tdb_information10           ,
  p_tdb_information11            => p_tdb_information11           ,
  p_tdb_information12            => p_tdb_information12           ,
  p_tdb_information13            => p_tdb_information13           ,
  p_tdb_information14            => p_tdb_information14           ,
  p_tdb_information15            => p_tdb_information15           ,
  p_tdb_information16            => p_tdb_information16           ,
  p_tdb_information17            => p_tdb_information17           ,
  p_tdb_information18            => p_tdb_information18           ,
  p_tdb_information19            => p_tdb_information19           ,
  p_tdb_information20            => p_tdb_information20           ,
  p_update_finance_line          => p_update_finance_line         ,
  p_tfl_object_version_number    => p_tfl_object_version_number   ,
  p_finance_header_id            => p_finance_header_id           ,
  p_finance_line_id              => l_finance_line_id             ,
  p_standard_amount              => p_standard_amount             ,
  p_unitary_amount               => p_unitary_amount       ,
  p_money_amount                 => p_money_amount                ,
  p_currency_code                => p_currency_code               ,
  p_booking_deal_type            => p_booking_deal_type           ,
  p_booking_deal_id              => p_booking_deal_id             ,
  p_enrollment_type              => p_enrollment_type             ,
  p_organization_id              => p_organization_id             ,
  p_sponsor_person_id            => p_sponsor_person_id           ,
  p_sponsor_assignment_id        => p_sponsor_assignment_id       ,
  p_person_address_id            =>  p_person_address_id          ,
  p_delegate_assignment_id       => p_delegate_assignment_id      ,
  p_delegate_contact_id          => p_delegate_contact_id         ,
  p_delegate_contact_email       => p_delegate_contact_email      ,
  p_third_party_email            => p_third_party_email           ,
  p_person_address_type          => p_person_address_type         ,
  p_line_id        => p_line_id          ,
  p_org_id         => p_org_id           ,
  p_daemon_flag          => p_daemon_flag                 ,
  p_daemon_type          => p_daemon_type                 ,
  p_old_event_id                 => p_old_event_id                ,
  p_quote_line_id                => p_quote_line_id               ,
  p_interface_source             => p_interface_source            ,
  p_total_training_time          => p_total_training_time         ,
  p_content_player_status        => p_content_player_status       ,
  p_score               => p_score                       ,
  p_completed_content       => p_completed_content      ,
  p_total_content          => p_total_content,
  p_booking_justification_id => p_booking_justification_id,
  p_is_history_flag		=> p_is_history_flag
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_delegate_booking_a'
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
  -- p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_delegate_booking ;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_delegate_booking ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    -- p_object_version_number := l_object_version_number;
    raise;
end update_delegate_booking ;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_delegate_booking >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_delegate_booking
 (
  p_validate                           in boolean,
  p_booking_id                         in number,
  p_object_version_number              in number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' delete_delegate_booking ';

  --bug 6063768 changes starts

  l_hours_until_class_starts 	NUMBER := 0;
  l_sysdate 			VARCHAR2(30) ;
  l_course_start_date     ota_events.course_start_date%TYPE;
  l_course_start_time       ota_events.course_start_time%TYPE;
  l_event_title             ota_events.title%TYPE;
  l_owner_id                ota_events.owner_id%TYPE;
  l_event_id ota_delegate_bookings.event_id%TYPE;
  l_booking_status_type_id ota_delegate_bookings.booking_status_type_id%TYPE;
  l_booking_status ota_booking_status_types.type%TYPE;
  l_username 	fnd_user.user_name%TYPE;
  l_auto_waitlist_days 	NUMBER;
  l_auto_waitlist VARCHAR2(2) := 'N';
  l_waitlist_size NUMBER := 0;

  CURSOR event_csr(p_event_id ota_events.event_id%TYPE) IS
  SELECT oet.title,oe.course_start_date,oe.course_start_time,oe.owner_id
  FROM ota_events_tl oet, ota_events oe
  WHERE  oet.event_id = oe.event_id
  AND oe.event_id = p_event_id
  AND oet.language = userenv('LANG');

  CURSOR sys_date_csr IS
  SELECT to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS')
  FROM dual;

  CURSOR fnduser_csr(l_owner_id ota_events.owner_id%TYPE) IS
  SELECT user_name
  FROM fnd_user
  WHERE employee_id = l_owner_id
  AND trunc(sysdate) BETWEEN trunc(start_date) AND nvl(trunc(end_date),trunc(sysdate)+1);

  CURSOR booking_csr(p_booking_id NUMBER) IS
  SELECT event_id,booking_status_type_id
  FROM ota_delegate_bookings
  WHERE booking_id = p_booking_id;

  CURSOR booking_status_csr(l_booking_status_type_id ota_delegate_bookings.booking_status_type_id%TYPE) IS
  SELECT type
  FROM ota_booking_status_types
  WHERE booking_status_type_id = l_booking_status_type_id;

  --bug 603768 changes ends

  CURSOR get_person_info IS
  select delegate_person_id
  from ota_delegate_bookings
  where BOOKING_ID = p_booking_id ;

  l_person_id number := -1;

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

   OPEN get_person_info;
   FETCH get_person_info INTO l_person_id;
   CLOSE get_person_info;
  --
  -- Issue a savepoint
  --
  savepoint delete_delegate_booking ;
  --
  -- Call Before Process User Hook
  --
  begin
    OTA_delegate_booking_bk3.delete_delegate_booking_b
    (p_booking_id             => p_booking_id ,
     p_object_version_number  => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_delegate_booking_b'
        ,p_hook_type   => 'BP'
        );
  end;

  -- 6063768 changes starts
  --Send ntf to class owner if any enrollment has been deleted
  l_auto_waitlist :=  fnd_profile.value('OTA_AUTO_WAITLIST_ACTIVE');
  l_auto_waitlist_days := TO_NUMBER(fnd_profile.value('OTA_AUTO_WAITLIST_DAYS'));

  if (l_auto_waitlist is not null and l_auto_waitlist = 'Y' ) then

    OPEN booking_csr (p_booking_id);
    FETCH booking_csr INTO l_event_id,l_booking_status_type_id;
    CLOSE booking_csr;

    l_waitlist_size := ota_utility.students_on_waitlist(l_event_id);

    if(l_waitlist_size > 0) then

       OPEN booking_status_csr (l_booking_status_type_id);
       FETCH booking_status_csr INTO l_booking_status;
       CLOSE booking_status_csr;

       if(l_booking_status = 'P' or l_booking_status = 'A' ) then

          OPEN event_csr (l_event_id);
          FETCH event_csr INTO l_event_title,l_course_start_date,l_course_start_time,l_owner_id;
          CLOSE event_csr;

          if ( l_course_start_date is not null ) then
            l_hours_until_class_starts := 24*(to_date(to_char(l_course_start_date, 'DD-MM-YYYY')||''||l_course_start_time, 'DD/MM/YYYYHH24:MI') - SYSDATE);
          end if;

          if (l_hours_until_class_starts <= nvl(l_auto_waitlist_days,0) )then

             OPEN sys_date_csr;
             FETCH sys_date_csr INTO l_sysdate;
             CLOSE sys_date_csr;

             if (l_owner_id is null) then
                l_owner_id := fnd_profile.value('OTA_DEFAULT_EVENT_OWNER');
             end if;

             OPEN fnduser_csr(l_owner_id);
             FETCH fnduser_csr INTO l_username;
             CLOSE fnduser_csr;

            OTA_INITIALIZATION_WF.MANUAL_WAITLIST(
                                                p_itemtype 		=> 'OTWF',
	                 			p_process		=> 'OTA_MANUAL_WAITLIST',
				                p_Event_title	=> l_event_title,
				                p_event_id      => l_event_id,
				                p_item_key 	=> p_booking_id ||':'||l_sysdate,
				                p_user_name	=> l_username);

			     end if;
           end if;
       end if;
  end if;
  --bug 603768 changes ends
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  OTA_tdb_del.del
   (p_booking_id              => p_booking_id ,
     p_object_version_number  => p_object_version_number,
     p_validate               => p_validate) ;
  --
  -- Call After Process User Hook
  --
  begin
  OTA_delegate_booking_bk3.delete_delegate_booking_a
    (p_booking_id             => p_booking_id ,
     p_object_version_number  => p_object_version_number,
     p_person_id              => l_person_id);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_delegate_booking_a'
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
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_delegate_booking ;
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
    rollback to delete_delegate_booking ;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_delegate_booking;
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
         (p_delegate_person_id in number,
	  p_delegate_contact_id in number,
	  p_customer_id in number,
	  p_event_id in number,
          p_booking_status_type_id in number
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
--

end ota_delegate_booking_api;

/
