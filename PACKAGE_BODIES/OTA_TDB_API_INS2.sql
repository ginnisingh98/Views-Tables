--------------------------------------------------------
--  DDL for Package Body OTA_TDB_API_INS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TDB_API_INS2" as
/* $Header: ottdb02t.pkb 120.22.12010000.2 2009/08/12 14:15:14 smahanka ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ota_tdb_api_ins2.';
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
  --
  l_proc 	varchar2(72) := g_package||'check_new_status';
  --
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
-- |--------------------------< Create Enrollment >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Creates an Enrollment.
--
--
procedure Create_Enrollment
  (
  p_booking_id				in out  nocopy number,
  p_booking_status_type_id		in number,
  p_delegate_person_id			in number	default null,
  p_contact_id				in number,
  p_business_group_id			in number,
  p_event_id				in number,
  p_customer_id				in number	default null,
  p_authorizer_person_id		in number	default null,
  p_date_booking_placed			in date,
  p_corespondent			in varchar2	default null,
  p_internal_booking_flag		in varchar2,
  p_number_of_places			in number,
  p_object_version_number		in out nocopy  number,
  p_administrator			in number	default null,
  p_booking_priority			in varchar2	default null,
  p_comments				in varchar2	default null,
  p_contact_address_id			in number	default null,
  p_delegate_contact_phone		in varchar2	default null,
  p_delegate_contact_fax		in varchar2	default null,
  p_third_party_customer_id		in number	default null,
  p_third_party_contact_id		in number	default null,
  p_third_party_address_id		in number	default null,
  p_third_party_contact_phone		in varchar2	default null,
  p_third_party_contact_fax		in varchar2	default null,
  p_date_status_changed			in date		default null,
  p_failure_reason			in varchar2	default null,
  p_attendance_result			in varchar2	default null,
  p_language_id				in number	default null,
  p_source_of_booking			in varchar2	default null,
  p_special_booking_instructions	in varchar2	default null,
  p_successful_attendance_flag		in varchar2	default null,
  p_tdb_information_category		in varchar2	default null,
  p_tdb_information1			in varchar2	default null,
  p_tdb_information2			in varchar2	default null,
  p_tdb_information3			in varchar2	default null,
  p_tdb_information4			in varchar2	default null,
  p_tdb_information5			in varchar2	default null,
  p_tdb_information6			in varchar2	default null,
  p_tdb_information7			in varchar2	default null,
  p_tdb_information8			in varchar2	default null,
  p_tdb_information9			in varchar2	default null,
  p_tdb_information10			in varchar2	default null,
  p_tdb_information11			in varchar2	default null,
  p_tdb_information12			in varchar2	default null,
  p_tdb_information13			in varchar2	default null,
  p_tdb_information14			in varchar2	default null,
  p_tdb_information15			in varchar2	default null,
  p_tdb_information16			in varchar2	default null,
  p_tdb_information17			in varchar2	default null,
  p_tdb_information18			in varchar2	default null,
  p_tdb_information19			in varchar2	default null,
  p_tdb_information20			in varchar2	default null,
  p_create_finance_line			in varchar2	default null,
  p_finance_header_id			in number	default null,
  p_currency_code			in varchar2	default null,
  p_standard_amount			in number	default null,
  p_unitary_amount			in number	default null,
  p_money_amount			in number	default null,
  p_booking_deal_id			in number	default null,
  p_booking_deal_type			in varchar2	default null,
  p_finance_line_id			in out nocopy number,
  p_enrollment_type			in varchar2,
  p_validate				in boolean	default false,
  p_organization_id              	in number	default null,
  p_sponsor_person_id            	in number	default null,
  p_sponsor_assignment_id        	in number	default null,
  p_person_address_id            	in number	default null,
  p_delegate_assignment_id       	in number	default null,
  p_delegate_contact_id          	in number	default null,
  p_delegate_contact_email       	in varchar2	default null,
  p_third_party_email            	in varchar2	default null,
  p_person_address_type          	in varchar2	default null,
  p_line_id					in number       default null,
  p_org_id					in number       default null,
  p_daemon_flag				in varchar2     default null,
  p_daemon_type 				in varchar2     default null,
  p_old_event_id                    in number       default null,
  p_quote_line_id                   in number       default null,
  p_interface_source                in varchar2     default null,
  p_total_training_time             in varchar2 default null,
  p_content_player_status           in varchar2 default null,
  p_score		                  in number   default null,
  p_completed_content			in number   default null,
  p_total_content	                  in number   default null,
  p_booking_justification_id                in number default null,
  p_override_prerequisites                in varchar2 default 'N',
p_book_from in varchar2,
p_override_learner_access in varchar2 ,
p_is_history_flag in varchar2 default 'N',
p_is_mandatory_enrollment             in varchar2 default 'N')
  is

  l_proc 	varchar2(72) := g_package||'create_enrollment';

/*
  l_object_version_number number;
  l_booking_id number;
  l_dummy number;
  l_event_status 		varchar2(30);
  l_maximum_attendees 		number;
  l_maximum_internal_attendees 	number;
  l_evt_object_version_number 	number;
  l_event_rec			ota_evt_shd.g_rec_type;
  l_event_exists		boolean;
  l_effective_date	date;

  l_lp_enrollment_ids varchar2(4000);
  l_cert_prd_enrollment_ids varchar2(4000);
  l_item_key     wf_items.item_key%type;

  l_type ota_booking_status_types.type%type;


  --
  l_proc 	varchar2(72) := g_package||'create_enrollment';

  l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                               hr_dflex_utility.l_ignore_dfcode_varray();
  l_ignore_dff_validation varchar2(1);
  v_forum_id        number;
  v_business_group_id   number;

Cursor chk_for_comp_upd
  is
  select ocu.online_flag , off.Learning_object_id from ota_category_usages ocu,
    ota_offerings off , ota_events oev
    where ocu.category_usage_id = off.delivery_mode_id
    and off.offering_id = oev.parent_offering_id
    and oev.event_id = p_event_id;

Cursor csr_forums_for_class
  is
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

  l_incoming_status_type varchar2(30);

*/
  --
  begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);

  ota_delegate_booking_api.create_delegate_booking(
         p_effective_date                     =>      trunc(sysdate)                ,
         p_booking_id                         =>      p_booking_id                  ,
         p_booking_status_type_id             =>      p_booking_status_type_id      ,
         p_delegate_person_id                 =>      p_delegate_person_id          ,
         p_contact_id                         =>      p_contact_id                  ,
         p_business_group_id                  =>      p_business_group_id           ,
         p_event_id                           =>      p_event_id                    ,
         p_customer_id                        =>      p_customer_id                 ,
         p_authorizer_person_id               =>      p_authorizer_person_id        ,
         p_date_booking_placed                =>      p_date_booking_placed         ,
         p_corespondent                       =>      p_corespondent                ,
         p_internal_booking_flag              =>      p_internal_booking_flag       ,
         p_number_of_places                   =>      p_number_of_places            ,
         p_object_version_number              =>      p_object_version_number       ,
         p_administrator                      =>      p_administrator               ,
         p_booking_priority                   =>      p_booking_priority            ,
         p_comments                           =>      p_comments                    ,
         p_contact_address_id                 =>      p_contact_address_id          ,
         p_delegate_contact_phone             =>      p_delegate_contact_phone      ,
         p_delegate_contact_fax               =>      p_delegate_contact_fax        ,
         p_third_party_customer_id            =>      p_third_party_customer_id     ,
         p_third_party_contact_id             =>      p_third_party_contact_id      ,
         p_third_party_address_id             =>      p_third_party_address_id      ,
         p_third_party_contact_phone          =>      p_third_party_contact_phone   ,
         p_third_party_contact_fax            =>      p_third_party_contact_fax     ,
         p_date_status_changed                =>      p_date_status_changed         ,
         p_failure_reason                     =>      p_failure_reason              ,
         p_attendance_result                  =>      p_attendance_result           ,
         p_language_id                        =>      p_language_id                 ,
         p_source_of_booking                  =>      p_source_of_booking           ,
         p_special_booking_instructions       =>      p_special_booking_instructions,
         p_successful_attendance_flag         =>      p_successful_attendance_flag  ,
         p_tdb_information_category           =>      p_tdb_information_category    ,
         p_tdb_information1                   =>      p_tdb_information1            ,
         p_tdb_information2                   =>      p_tdb_information2            ,
         p_tdb_information3                   =>      p_tdb_information3            ,
         p_tdb_information4                   =>      p_tdb_information4            ,
         p_tdb_information5                   =>      p_tdb_information5            ,
         p_tdb_information6                   =>      p_tdb_information6            ,
         p_tdb_information7                   =>      p_tdb_information7            ,
         p_tdb_information8                   =>      p_tdb_information8            ,
         p_tdb_information9                   =>      p_tdb_information9            ,
         p_tdb_information10                  =>      p_tdb_information10           ,
         p_tdb_information11                  =>      p_tdb_information11           ,
         p_tdb_information12                  =>      p_tdb_information12           ,
         p_tdb_information13                  =>      p_tdb_information13           ,
         p_tdb_information14                  =>      p_tdb_information14           ,
         p_tdb_information15                  =>      p_tdb_information15           ,
         p_tdb_information16                  =>      p_tdb_information16           ,
         p_tdb_information17                  =>      p_tdb_information17           ,
         p_tdb_information18                  =>      p_tdb_information18           ,
         p_tdb_information19                  =>      p_tdb_information19           ,
         p_tdb_information20                  =>      p_tdb_information20           ,
         p_create_finance_line                =>      p_create_finance_line         ,
         p_finance_header_id                  =>      p_finance_header_id           ,
         p_currency_code                      =>      p_currency_code               ,
         p_standard_amount                    =>      p_standard_amount             ,
         p_unitary_amount                     =>      p_unitary_amount              ,
         p_money_amount                       =>      p_money_amount                ,
         p_booking_deal_id                    =>      p_booking_deal_id             ,
         p_booking_deal_type                  =>      p_booking_deal_type           ,
         p_finance_line_id                    =>      p_finance_line_id             ,
         p_enrollment_type                    =>      p_enrollment_type             ,
         p_validate                           =>      p_validate                    ,
         p_organization_id                    =>      p_organization_id             ,
         p_sponsor_person_id                  =>      p_sponsor_person_id           ,
         p_sponsor_assignment_id              =>      p_sponsor_assignment_id       ,
         p_person_address_id                  =>      p_person_address_id           ,
         p_delegate_assignment_id             =>      p_delegate_assignment_id      ,
         p_delegate_contact_id                =>      p_delegate_contact_id         ,
         p_delegate_contact_email             =>      p_delegate_contact_email      ,
         p_third_party_email                  =>      p_third_party_email           ,
         p_person_address_type                =>      p_person_address_type         ,
         p_line_id                            =>      p_line_id                     ,
         p_org_id                             =>      p_org_id                      ,
         p_daemon_flag                        =>      p_daemon_flag                 ,
         p_daemon_type                        =>      p_daemon_type                 ,
         p_old_event_id                       =>      p_old_event_id                ,
         p_quote_line_id                      =>      p_quote_line_id               ,
         p_interface_source                   =>      p_interface_source            ,
         p_total_training_time                =>      p_total_training_time         ,
         p_content_player_status              =>      p_content_player_status       ,
         p_score                              =>      p_score                       ,
         p_completed_content                  =>      p_completed_content           ,
         p_total_content                      =>      p_total_content               ,
         p_booking_justification_id           =>      p_booking_justification_id    ,
         p_is_history_flag	 	      =>      p_is_history_flag	     ,
         p_override_prerequisites 	      =>      p_override_prerequisites      ,
         p_override_learner_access	      =>      p_override_learner_access     ,
         p_book_from 		              =>      p_book_from ,
         p_is_mandatory_enrollment        =>      p_is_mandatory_enrollment
   );

   hr_utility.set_location('Leaving:'||l_proc, 10);

/*
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  if p_validate then
  --
    savepoint create_enrollment;
  --
  end if;
   --
  -- Truncate the time portion from all IN date parameters
  --
 -- l_effective_date := trunc(p_effective_date);
  --
  hr_utility.set_location(l_proc, 6);

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
  ota_evt_bus2.lock_event(p_event_id);

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
--
  ota_tdb_ins.ins(
    p_booking_id
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
  , p_object_version_number
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
  , p_create_finance_line
  , p_finance_header_id
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
  ,p_booking_justification_id
  ,p_is_history_flag);
  --

  ota_tdb_bus.ota_letter_lines
                 (p_booking_id             => p_booking_id,
                  p_booking_status_type_id => p_booking_status_type_id,
                  p_event_id               => p_event_id,
                  p_delegate_person_id     => p_delegate_person_id);
/* bug 3795299. changed call to ota_lrng_path_member_util
         ---***added p_delegate_person_id also.Bug 2791524
         ota_trng_plan_comp_ss.update_tpc_enroll_status_chg(p_event_id  => p_event_id,
                                                     p_person_id => p_delegate_person_id,
						    -- Added for Bug#3479186
						     p_contact_id => p_delegate_contact_id,
                                                     p_learning_path_ids => l_learning_path_ids);
*/
/*
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

*/		-- check whether class is online or not
      /*  OPEN chk_for_comp_upd;
        FETCH chk_for_comp_upd INTO l_on_flag,l_LO_id;
        CLOSE chk_for_comp_upd;

       if l_on_flag='Y' then
       -- check whether online class is succesfully completed or not
       l_comp_upd := ota_lo_utility.get_history_button(p_user_id  => p_delegate_person_id,
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
            p_person_id 	=> p_delegate_person_id,
            p_eventid       =>p_event_id,
            p_learningpath_ids => null,
            p_itemkey    =>l_item_key);

        end if;
*/

       /* ota_competence_ss.create_wf_process(p_process 	=>'OTA_COMPETENCE_UPDATE_JSP_PRC',
            p_itemtype 		=>'HRSSA',
            p_person_id 	=> p_delegate_person_id,
            p_eventid       =>p_event_id,
            p_learningpath_ids => null,
            p_itemkey    =>l_item_key);*/
/*
        end if;

  --
  -- fire learner enrollment notification
        if p_contact_id is null and p_delegate_contact_id is null
        and nvl(p_book_from,'-1') <> 'AME' then
            -- call learner ntf process

            OTA_LRNR_ENROLL_UNENROLL_WF.learner_enrollment(p_process => 'OTA_LNR_TRNG_APPROVAL_JSP_PRC',
                                                        p_itemtype => 'HRSSA',
                                                        p_person_id => p_delegate_person_id,
                                                        p_eventid => p_event_id,
                                                        p_booking_id => p_booking_id);



            end if;

  if p_create_finance_line = 'Y' then
  --
   ota_finance.maintain_finance_line(p_finance_header_id => p_finance_header_id,
                                     p_booking_id        => p_booking_id   ,
                                     p_currency_code     => p_currency_code    ,
                                     p_standard_amount   => p_standard_amount,
                                     p_unitary_amount    => p_unitary_amount   ,
                                     p_money_amount      => p_money_amount     ,
                                     p_booking_deal_id   => p_booking_deal_id  ,
                                     p_booking_deal_type => p_booking_deal_type,
                                     p_object_version_number => l_dummy,
                                     p_finance_line_id   => p_finance_line_id);
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
*/
  /*OTA_FRM_NOTIF_SUBSCRIBER_API.create_frm_notif_subscriber(
  		p_validate                     => p_validate
		    ,p_effective_date               => l_effective_date
		    ,p_business_group_id            => v_business_group_id
		    ,p_forum_id                     => v_forum_id
		    ,p_person_id                    => p_delegate_person_id
		    ,p_contact_id                   => p_delegate_contact_id
    		    ,p_object_version_number        => p_object_version_number
  		);*/
/*
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
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
  --
    raise hr_api.validate_enabled;
  --
  end if;

  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_enrollment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
*/
end Create_Enrollment;
--
end ota_tdb_api_ins2;
--

/
