--------------------------------------------------------
--  DDL for Package Body PQP_RIW_ENROLL_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_RIW_ENROLL_WRAPPER" as
/* $Header: pqpriwenwr.pkb 120.0.12010000.5 2009/04/24 08:35:50 psengupt noship $ */

-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
g_package  varchar2(33) := 'enrollment_wrapper_api.';
g_enroll_rec                     ota_delegate_bookings_v%rowtype;
g_interface_code              varchar2(150);

-- =============================================================================
-- Default_Record_Values:
-- =============================================================================
function Default_Enroll_Rec
         return ota_delegate_bookings_v%rowtype is
  l_proc_name    constant varchar2(150) := g_package||'Default_Enroll_Rec';
  l_enroll_rec     ota_delegate_bookings_v%rowtype;

begin

  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
  /*
   ==========================================================================
   g_varchar2  constant varchar2(9) := '$Sys_Def$';
   g_number  constant number        := -987123654;
   g_date  constant date            := to_date('01-01-4712', 'DD-MM-SYYYY');
   ==========================================================================
  */
  Hr_Utility.set_location(' One : ', 5);

  l_enroll_rec.booking_status_type_id       :=  hr_api.g_number      ;
  l_enroll_rec.delegate_person_id           :=  hr_api.g_number      ;
  l_enroll_rec.sponsor_contact_id           :=  hr_api.g_number      ;
  l_enroll_rec.business_group_id            :=  hr_api.g_number      ;
  l_enroll_rec.event_id                     :=  hr_api.g_number      ;
  l_enroll_rec.customer_id                  :=  hr_api.g_number      ;
  l_enroll_rec.authorizer_person_id         :=  hr_api.g_number      ;
  l_enroll_rec.date_booking_placed          :=  hr_api.g_date        ;

  l_enroll_rec.correspondent                 :=  hr_api.g_varchar2    ;
  l_enroll_rec.internal_booking_flag        :=  hr_api.g_varchar2    ;
  l_enroll_rec.number_of_places             :=  hr_api.g_number      ;
  l_enroll_rec.administrator                :=  hr_api.g_number      ;
  l_enroll_rec.booking_priority             :=  hr_api.g_varchar2    ;
  l_enroll_rec.comments                     :=  hr_api.g_varchar2    ;
  l_enroll_rec.contact_address_id           :=  hr_api.g_number      ;

  l_enroll_rec.correspondent_phone       :=  hr_api.g_varchar2    ;
  l_enroll_rec.correspondent_fax         :=  hr_api.g_varchar2    ;
  l_enroll_rec.third_party_customer_id      :=  hr_api.g_number      ;
  l_enroll_rec.third_party_contact_id       :=  hr_api.g_number      ;
  l_enroll_rec.third_party_address_id       :=  hr_api.g_number      ;
  l_enroll_rec.third_party_contact_phone    :=  hr_api.g_varchar2    ;
  l_enroll_rec.third_party_contact_fax      :=  hr_api.g_varchar2    ;
  l_enroll_rec.date_status_changed          :=  hr_api.g_date        ;

--  l_enroll_rec.status_change_comments       :=  hr_api.g_varchar2    ;
  l_enroll_rec.failure_reason               :=  hr_api.g_varchar2    ;
  l_enroll_rec.attendance_result            :=  hr_api.g_varchar2    ;
  l_enroll_rec.language_id                  :=  hr_api.g_number      ;
  l_enroll_rec.source_of_booking            :=  hr_api.g_varchar2    ;
  l_enroll_rec.special_booking_instructions :=  hr_api.g_varchar2    ;
  l_enroll_rec.successful_attendance_flag   :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information_category     :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information1             :=  hr_api.g_varchar2    ;

  l_enroll_rec.tdb_information2             :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information3             :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information4             :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information5             :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information6             :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information7             :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information8             :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information9             :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information10            :=  hr_api.g_varchar2    ;

  l_enroll_rec.tdb_information11            :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information12            :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information13            :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information14            :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information15            :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information16            :=  hr_api.g_varchar2    ;
  l_enroll_rec.tdb_information17            :=  hr_api.g_varchar2 ;
  l_enroll_rec.tdb_information18            :=  hr_api.g_varchar2 ;
  l_enroll_rec.tdb_information19            :=  hr_api.g_varchar2 ;
  l_enroll_rec.tdb_information20            :=  hr_api.g_varchar2 ;
  l_enroll_rec.finance_header_id            :=  hr_api.g_number   ;

  l_enroll_rec.standard_amount              :=  hr_api.g_number   ;

--  l_enroll_rec.unitary_amount               :=  hr_api.g_number   ;

  l_enroll_rec.money_amount                 :=  hr_api.g_number   ;

  l_enroll_rec.currency_code                :=  hr_api.g_varchar2 ;

  l_enroll_rec.booking_deal_type            :=  hr_api.g_varchar2 ;

  l_enroll_rec.booking_deal_id              :=  hr_api.g_number   ;
  Hr_Utility.set_location(' OneThree : ', 5);
--  l_enroll_rec.enrollment_type              :=  hr_api.g_varchar2 ;
  l_enroll_rec.organization_id              :=  hr_api.g_number   ;
  l_enroll_rec.sponsor_person_id            :=  hr_api.g_number   ;
  l_enroll_rec.sponsor_assignment_id        :=  hr_api.g_number   ;
  l_enroll_rec.person_address_id            :=  hr_api.g_number   ;
  l_enroll_rec.delegate_assignment_id       :=  hr_api.g_number   ;
  l_enroll_rec.delegate_contact_id          :=  hr_api.g_number   ;
  l_enroll_rec.correspondent_email       :=  hr_api.g_varchar2 ;
  l_enroll_rec.third_party_email            :=  hr_api.g_varchar2 ;
  l_enroll_rec.correspondent_address_type   :=  hr_api.g_varchar2 ;
  l_enroll_rec.line_id                      :=  hr_api.g_number   ;
  Hr_Utility.set_location(' OneFour : ', 5);
  l_enroll_rec.org_id                       :=  hr_api.g_number   ;
  Hr_Utility.set_location(' 1 : ', 5);
--  l_enroll_rec.daemon_flag                  :=  hr_api.g_varchar2 ;
  Hr_Utility.set_location(' 2 : ', 5);
--  l_enroll_rec.daemon_type                  :=  hr_api.g_varchar2 ;
  Hr_Utility.set_location(' 3 : ', 5);
  l_enroll_rec.old_event_id                 :=  hr_api.g_number   ;
  l_enroll_rec.quote_line_id                :=  hr_api.g_number   ;
  l_enroll_rec.interface_source             :=  hr_api.g_varchar2 ;
  Hr_Utility.set_location(' 4 : ', 5);
  l_enroll_rec.total_training_time          :=  hr_api.g_varchar2 ;
  Hr_Utility.set_location(' 5 : ', 5);
  l_enroll_rec.content_player_status        :=  hr_api.g_varchar2 ;
  l_enroll_rec.score                        :=  hr_api.g_number   ;
  Hr_Utility.set_location(' OneTwo : ', 5);
  l_enroll_rec.completed_content            :=  hr_api.g_number   ;
  Hr_Utility.set_location(' OneFive : ', 5);
  l_enroll_rec.total_content                :=  hr_api.g_number   ;
  l_enroll_rec.booking_justification_id     :=  hr_api.g_number   ;
--  l_enroll_rec.is_history_flag       	    :=  hr_api.g_varchar2 ;


  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  return l_enroll_rec;
exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;

end Default_Enroll_Rec;


-- =============================================================================
-- Get_Record_Values:
-- =============================================================================
function Get_Record_Values
        (p_interface_code in varchar2 default null)
         return ota_delegate_bookings_v%rowtype is

  cursor bne_cols(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='Y';
  --and bic.interface_col_type <> 2;

  -- To query cols which are not displayed (DFF segments)
   cursor bne_cols_no_disp(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='N';

  l_enroll_rec            ota_delegate_bookings_v%rowtype;
  col_name             varchar2(150);
  l_proc_name constant varchar2(150) := g_package||'Get_Record_Values';
begin

  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
 hr_utility.set_location('p_interface_code'||p_interface_code, 10);
  l_enroll_rec := Default_Enroll_Rec;
 hr_utility.set_location('p_interface_code'||p_interface_code, 20);
 hr_utility.set_location('g_interface_code'||g_interface_code, 5);


  for col_rec in bne_cols (g_interface_code)
  loop
 hr_utility.set_location(' in loop col_rec.interface_col_name'||col_rec.interface_col_name, 15);
   case col_rec.interface_col_name

    when 'p_booking_status_type_id' then
          l_enroll_rec.booking_status_type_id := g_enroll_rec.booking_status_type_id;
    when 'p_delegate_person_id' then
          l_enroll_rec.delegate_person_id := g_enroll_rec.delegate_person_id;
    when 'p_contact_id' then
          l_enroll_rec.sponsor_contact_id := g_enroll_rec.sponsor_contact_id;
    when 'p_business_grouid' then
          l_enroll_rec.business_group_id := g_enroll_rec.business_group_id;
    when 'p_event_id' then
          l_enroll_rec.event_id := g_enroll_rec.event_id;
    when 'p_customer_id' then
          l_enroll_rec.customer_id := g_enroll_rec.customer_id;
    when 'p_authorizer_person_id' then
          l_enroll_rec.authorizer_person_id := g_enroll_rec.authorizer_person_id;
    when 'p_date_booking_placed' then
          l_enroll_rec.date_booking_placed := g_enroll_rec.date_booking_placed;
    when 'p_corespondent' then
          l_enroll_rec.correspondent := g_enroll_rec.correspondent;
    when 'p_internal_booking_flag' then
          l_enroll_rec.internal_booking_flag := g_enroll_rec.internal_booking_flag;
    when 'p_number_of_places' then
          l_enroll_rec.number_of_places := g_enroll_rec.number_of_places;
    when 'p_administrator' then
          l_enroll_rec.administrator := g_enroll_rec.administrator;
    when 'p_booking_priority' then
          l_enroll_rec.booking_priority := g_enroll_rec.booking_priority;
    when 'p_comments' then
          l_enroll_rec.comments := g_enroll_rec.comments;
    when 'p_contact_address_id' then
          l_enroll_rec.contact_address_id := g_enroll_rec.contact_address_id;
    when 'p_delegate_contact_phone' then
          l_enroll_rec.correspondent_phone := g_enroll_rec.correspondent_phone;
    when 'p_delegate_contact_fax' then
          l_enroll_rec.correspondent_fax := g_enroll_rec.correspondent_fax;
    when 'p_third_party_customer_id' then
          l_enroll_rec.third_party_customer_id := g_enroll_rec.third_party_customer_id;
    when 'p_third_party_contact_id' then
          l_enroll_rec.third_party_contact_id := g_enroll_rec.third_party_contact_id;
    when 'p_third_party_address_id' then
          l_enroll_rec.third_party_address_id := g_enroll_rec.third_party_address_id;
    when 'p_third_party_contact_phone' then
          l_enroll_rec.third_party_contact_phone := g_enroll_rec.third_party_contact_phone;
    when 'p_third_party_contact_fax' then
          l_enroll_rec.third_party_contact_fax := g_enroll_rec.third_party_contact_fax;
    when 'p_date_status_changed' then
          l_enroll_rec.date_status_changed := g_enroll_rec.date_status_changed;
--    when 'p_status_change_comments' then
  --        l_enroll_rec.status_change_comments := g_enroll_rec.status_change_comments;
    when 'p_failure_reason' then
          l_enroll_rec.failure_reason := g_enroll_rec.failure_reason;
    when 'p_attendance_result' then
          l_enroll_rec.attendance_result := g_enroll_rec.attendance_result;
    when 'p_language_id' then
          l_enroll_rec.language_id := g_enroll_rec.language_id;
    when 'p_source_of_booking' then
          l_enroll_rec.source_of_booking := g_enroll_rec.source_of_booking;
    when 'p_special_booking_instructions' then
          l_enroll_rec.special_booking_instructions := g_enroll_rec.special_booking_instructions;
    when 'p_successful_attendance_flag' then
          l_enroll_rec.successful_attendance_flag := g_enroll_rec.successful_attendance_flag;
    when 'p_finance_header_id' then
          l_enroll_rec.finance_header_id := g_enroll_rec.finance_header_id;
    when 'p_standard_amount' then
          l_enroll_rec.standard_amount := g_enroll_rec.standard_amount;
--    when 'p_unitary_amount' then
  --        l_enroll_rec.unitary_amount := g_enroll_rec.unitary_amount;
    when 'p_money_amount' then
          l_enroll_rec.money_amount := g_enroll_rec.money_amount;
    when 'p_currency_code' then
          l_enroll_rec.currency_code := g_enroll_rec.currency_code;
    when 'p_booking_deal_type' then
          l_enroll_rec.booking_deal_type := g_enroll_rec.booking_deal_type;
    when 'p_booking_deal_id' then
          l_enroll_rec.booking_deal_id := g_enroll_rec.booking_deal_id;
--    when 'p_enrollment_type' then
  --        l_enroll_rec.enrollment_type := g_enroll_rec.enrollment_type;
    when 'p_organization_id' then
          l_enroll_rec.organization_id := g_enroll_rec.organization_id;
    when 'p_sponsor_person_id' then
          l_enroll_rec.sponsor_person_id := g_enroll_rec.sponsor_person_id;
    when 'p_sponsor_assignment_id' then
          l_enroll_rec.sponsor_assignment_id := g_enroll_rec.sponsor_assignment_id;
    when 'p_person_address_id' then
          l_enroll_rec.person_address_id := g_enroll_rec.person_address_id;
    when 'p_delegate_assignment_id' then
          l_enroll_rec.delegate_assignment_id := g_enroll_rec.delegate_assignment_id;
    when 'p_delegate_contact_id' then
          l_enroll_rec.delegate_contact_id := g_enroll_rec.delegate_contact_id;
    when 'p_delegate_contact_email' then
          l_enroll_rec.correspondent_email := g_enroll_rec.correspondent_email;
    when 'p_third_party_email' then
          l_enroll_rec.third_party_email := g_enroll_rec.third_party_email;
    when 'p_person_address_type' then
          l_enroll_rec.correspondent_address_type := g_enroll_rec.correspondent_address_type;
    when 'p_line_id' then
          l_enroll_rec.line_id := g_enroll_rec.line_id;
    when 'p_org_id' then
          l_enroll_rec.org_id := g_enroll_rec.org_id;
--    when 'p_daemon_flag' then
  --        l_enroll_rec.daemon_flag := g_enroll_rec.daemon_flag;
    when 'p_old_event_id' then
          l_enroll_rec.old_event_id := g_enroll_rec.old_event_id;
    when 'p_quote_line_id' then
          l_enroll_rec.quote_line_id := g_enroll_rec.quote_line_id;
    when 'p_interface_source' then
          l_enroll_rec.interface_source := g_enroll_rec.interface_source;
    when 'p_total_training_time' then
          l_enroll_rec.total_training_time := g_enroll_rec.total_training_time;
    when 'p_content_player_status' then
          l_enroll_rec.content_player_status := g_enroll_rec.content_player_status;
    when 'p_score' then
          l_enroll_rec.score := g_enroll_rec.score;
    when 'p_completed_content' then
          l_enroll_rec.completed_content := g_enroll_rec.completed_content;
    when 'p_total_content' then
          l_enroll_rec.total_content := g_enroll_rec.total_content;
    when 'p_booking_justification_id' then
          l_enroll_rec.booking_justification_id := g_enroll_rec.booking_justification_id;
--    when 'p_is_history_flag' then
--          l_enroll_rec.is_history_flag := g_enroll_rec.is_history_flag;



    -- DFF
    when 'p_tdb_information_category' then
          l_enroll_rec.tdb_information_category := g_enroll_rec.tdb_information_category;
          if l_enroll_rec.tdb_information_category is not null then
          for col_rec1 in bne_cols_no_disp(g_interface_code) loop

             case col_rec1.interface_col_name
             when 'p_tdb_information1' then
                   l_enroll_rec.tdb_information1 := g_enroll_rec.tdb_information1;
             when 'p_tdb_information2' then
                   l_enroll_rec.tdb_information2 := g_enroll_rec.tdb_information2;
             when 'p_tdb_information3' then
                   l_enroll_rec.tdb_information3 := g_enroll_rec.tdb_information3;
             when 'p_tdb_information4' then
                   l_enroll_rec.tdb_information4 := g_enroll_rec.tdb_information4;
             when 'p_tdb_information5' then
                   l_enroll_rec.tdb_information5 := g_enroll_rec.tdb_information5;
             when 'p_tdb_information6' then
                   l_enroll_rec.tdb_information6 := g_enroll_rec.tdb_information6;
             when 'p_tdb_information7' then
                   l_enroll_rec.tdb_information7 := g_enroll_rec.tdb_information7;
             when 'p_tdb_information8' then
                   l_enroll_rec.tdb_information8 := g_enroll_rec.tdb_information8;
             when 'p_tdb_information9' then
                   l_enroll_rec.tdb_information9 := g_enroll_rec.tdb_information9;
             when 'p_tdb_information10' then
                   l_enroll_rec.tdb_information10 := g_enroll_rec.tdb_information10;
             when 'p_tdb_information11' then
                   l_enroll_rec.tdb_information11 := g_enroll_rec.tdb_information11;
             when 'p_tdb_information12' then
                   l_enroll_rec.tdb_information12 := g_enroll_rec.tdb_information12;
             when 'p_tdb_information13' then
                   l_enroll_rec.tdb_information13 := g_enroll_rec.tdb_information13;
             when 'p_tdb_information14' then
                   l_enroll_rec.tdb_information14 := g_enroll_rec.tdb_information14;
             when 'p_tdb_information15' then
                   l_enroll_rec.tdb_information15 := g_enroll_rec.tdb_information15;
             when 'p_tdb_information16' then
                   l_enroll_rec.tdb_information16 := g_enroll_rec.tdb_information16;
             when 'p_tdb_information17' then
                   l_enroll_rec.tdb_information17 := g_enroll_rec.tdb_information17;
             when 'p_tdb_information18' then
                   l_enroll_rec.tdb_information18 := g_enroll_rec.tdb_information18;
             when 'p_tdb_information19' then
                   l_enroll_rec.tdb_information19 := g_enroll_rec.tdb_information19;
             when 'p_tdb_information20' then
                   l_enroll_rec.tdb_information20 := g_enroll_rec.tdb_information20;
             else
                  null;
             end case;
            end loop;
           end if;
   else
      null;
   end case;
  end loop;
  Hr_Utility.set_location(' Leaving: '||l_proc_name, 80);
  return l_enroll_rec;

end Get_Record_Values;

-- =============================================================================
-- InsUpd_Enroll:
-- =============================================================================
procedure InsUpd_Enroll
( p_effective_date               in     date	   default null
  ,p_booking_id                   in     number
  ,p_booking_status_type_id       in     number
  ,p_delegate_person_id           in     number    default null
  ,p_contact_id                   in     number    default null
  ,p_business_group_id            in     number
  ,p_event_id                     in     number
  ,p_customer_id                  in     number    default null
  ,p_authorizer_person_id         in     number    default null
  ,p_date_booking_placed          in     date
  ,p_corespondent                 in     varchar2  default null
  ,p_internal_booking_flag        in     varchar2
  ,p_number_of_places             in     number
  ,p_object_version_number        in     number
  ,p_administrator                in     number    default null
  ,p_booking_priority             in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_contact_address_id           in     number    default null
  ,p_delegate_contact_phone       in     varchar2  default null
  ,p_delegate_contact_fax         in     varchar2  default null
  ,p_third_party_customer_id      in     number    default null
  ,p_third_party_contact_id       in     number    default null
  ,p_third_party_address_id       in     number    default null
  ,p_third_party_contact_phone    in     varchar2  default null
  ,p_third_party_contact_fax      in     varchar2  default null
  ,p_date_status_changed          in     date      default null
  ,p_failure_reason               in     varchar2  default null
  ,p_attendance_result            in     varchar2  default null
  ,p_language_id                  in     number    default null
  ,p_source_of_booking            in     varchar2  default null
  ,p_special_booking_instructions in     varchar2  default null
  ,p_successful_attendance_flag   in     varchar2  default null
  ,p_tdb_information_category     in     varchar2  default null
  ,p_tdb_information1             in     varchar2  default null
  ,p_tdb_information2             in     varchar2  default null
  ,p_tdb_information3             in     varchar2  default null
  ,p_tdb_information4             in     varchar2  default null
  ,p_tdb_information5             in     varchar2  default null
  ,p_tdb_information6             in     varchar2  default null
  ,p_tdb_information7             in     varchar2  default null
  ,p_tdb_information8             in     varchar2  default null
  ,p_tdb_information9             in     varchar2  default null
  ,p_tdb_information10            in     varchar2  default null
  ,p_tdb_information11            in     varchar2  default null
  ,p_tdb_information12            in     varchar2  default null
  ,p_tdb_information13            in     varchar2  default null
  ,p_tdb_information14            in     varchar2  default null
  ,p_tdb_information15            in     varchar2  default null
  ,p_tdb_information16            in     varchar2  default null
  ,p_tdb_information17            in     varchar2  default null
  ,p_tdb_information18            in     varchar2  default null
  ,p_tdb_information19            in     varchar2  default null
  ,p_tdb_information20            in     varchar2  default null
  ,p_create_finance_line          in     varchar2  default null
  ,p_finance_header_id            in     number    default null
  ,p_currency_code                in     varchar2  default null
  ,p_standard_amount              in     number    default null
  ,p_unitary_amount               in     number    default null
  ,p_money_amount                 in     number    default null
  ,p_booking_deal_id              in     number    default null
  ,p_booking_deal_type            in     varchar2  default null
  ,p_finance_line_id              in out nocopy number
  ,p_enrollment_type              in     varchar2  default null
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_id              in     number    default null
  ,p_sponsor_person_id            in     number    default null
  ,p_sponsor_assignment_id        in     number    default null
  ,p_person_address_id            in     number    default null
  ,p_delegate_assignment_id       in     number    default null
  ,p_delegate_contact_id          in     number    default null
  ,p_delegate_contact_email       in     varchar2  default null
  ,p_third_party_email            in     varchar2  default null
  ,p_person_address_type          in     varchar2  default null
  ,p_line_id                      in     number    default null
  ,p_org_id                       in     number    default null
  ,p_daemon_flag                  in     varchar2  default null
  ,p_daemon_type                  in     varchar2  default null
  ,p_old_event_id                 in     number    default null
  ,p_quote_line_id                in     number    default null
  ,p_interface_source             in     varchar2  default null
  ,p_total_training_time          in     varchar2  default null
  ,p_content_player_status        in     varchar2  default null
  ,p_score                        in     number    default null
  ,p_completed_content            in     number    default null
  ,p_total_content                in     number    default null
  ,p_return_status                out 	 nocopy    varchar2
  ,p_booking_justification_id 	  in 	 number    default null
  ,p_is_history_flag   		  in 	 varchar2  default 'N'
  ,p_override_prerequisites 	  in 	 varchar2  default null
  ,p_override_learner_access 	  in 	 varchar2  default null
  ,P_CRT_UPD			  in 	 varchar2   default null
  ,p_status_change_comments       in	 varchar2  default hr_api.g_varchar2
  ,p_update_finance_line          in 	varchar2  default hr_api.g_varchar2
  ,p_tfl_object_version_number    in    number default null
  ) is

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;

  --
  -- Variables for IN/OUT parameters
  l_finance_line_id               number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'ENROLLMENT_WRAPPER_API';
  l_booking_id                   number;
  l_booking			 number;
  l_create_flag			 number;
  l_error_msg            	 varchar2(4000);
  m_validate 		         number :=0; -- No validation

  --  p_status_change_comments        varchar2(30)  default hr_api.g_varchar2;
  --  p_update_finance_line           varchar2(30)  default hr_api.g_varchar2;
  l_tfl_object_version_number     number;
  l_date_booking_placed ota_delegate_bookings.date_booking_placed%TYPE;
  l_date_status_changed ota_delegate_bookings.date_status_changed%TYPE;
  c_delegate_assignment_id		number default null;
  c_sponsor_assignment_id		number default null;

  --$ Get upload mode - "Create and Update" (C) or "Update Only" (U)
    -- or "View/Download Only" (D)
  g_crt_upd                     varchar2 (1);

  --$ Exceptions
  e_upl_not_allowed exception; -- when mode is 'View Only'
  e_crt_not_allowed exception; -- when mode is 'Update Only'
  g_upl_err_msg varchar2(100) := 'Upload NOT allowed.';
  g_crt_err_msg varchar2(100) := 'Creating NOT allowed.';

  l_bo_id         number(9);
  l_object_version_number    number(3);
  l_obj_ver_num      number(3);

  l_enroll_rec     ota_delegate_bookings_v%rowtype;
  l_interface_code   varchar2(40);
  l_crt_upd_len         number;

      CURSOR booking_csr
        IS
       SELECT b.date_booking_placed
         FROM   ota_delegate_bookings b
       WHERE  b.booking_id = p_booking_id;


      CURSOR deleg_ass_id
        IS
      SELECT asg.assignment_id
        FROM per_assignments_f asg,per_people_f  per,PER_PERSON_TYPES PPT
      WHERE per.person_id = asg.person_id
            and ((asg.primary_flag = 'Y' and ppt.system_person_type in ('EMP','CWK','OTHER'))
            OR (asg.assignment_type = 'A' and ppt.system_person_type ='APL'))
            and (SYSDATE BETWEEN ASG.EFFECTIVE_START_DATE and ASG.EFFECTIVE_END_DATE)
            and (SYSDATE BETWEEN per.EFFECTIVE_START_DATE AND per.EFFECTIVE_END_DATE)
            and ppt.person_type_id = per.person_type_id and ppt.business_group_id = per.business_group_id
            and  per.person_id =p_delegate_person_id;

      CURSOR spon_ass_id
        IS
      SELECT asg.assignment_id
        FROM per_assignments_f asg,per_people_f  per,PER_PERSON_TYPES PPT
      WHERE per.person_id = asg.person_id
            and ((asg.primary_flag = 'Y' and ppt.system_person_type in ('EMP','CWK','OTHER'))
            OR (asg.assignment_type = 'A' and ppt.system_person_type ='APL'))
            and (SYSDATE BETWEEN ASG.EFFECTIVE_START_DATE and ASG.EFFECTIVE_END_DATE)
            and (SYSDATE BETWEEN per.EFFECTIVE_START_DATE AND per.EFFECTIVE_END_DATE)
            and ppt.person_type_id = per.person_type_id and ppt.business_group_id = per.business_group_id
            and  per.person_id =p_sponsor_person_id;

Begin

 -- hr_utility.trace_on(null , 'Enroll_Trace');
  hr_utility.set_location(' Entering:' || l_proc,10);
  hr_utility.trace('delegate person id : ' || p_delegate_person_id);
  hr_utility.trace('P_CRT_UPD : ' || P_CRT_UPD);

  l_crt_upd_len := LENGTH(p_crt_upd);
  g_crt_upd := SUBSTR(p_crt_upd, 1, 1);
  IF l_crt_upd_len > 1 THEN
      l_interface_code := SUBSTR(p_crt_upd, 3);
  ELSE
      l_interface_code := null;
  END IF;



 -- if (P_CRT_UPD is not null) then
 --   g_crt_upd      := P_CRT_UPD;
 -- end if;
  if (p_delegate_person_id is not null) then
     OPEN deleg_ass_id;
     FETCH deleg_ass_id INTO c_delegate_assignment_id;
     CLOSE deleg_ass_id;
  end if;

   if (p_delegate_person_id is not null) then
     OPEN spon_ass_id;
     FETCH spon_ass_id INTO c_sponsor_assignment_id;
     CLOSE spon_ass_id;
   end if;

    hr_utility.trace('c_delegate_assignment_id '|| c_delegate_assignment_id);
    hr_utility.trace('c_sponsor_assignment_id '|| c_sponsor_assignment_id);

  hr_utility.trace('g_crt_upd : ' || g_crt_upd);



  --
  -- Issue a savepoint
  --
  l_create_flag :=1;  -- Default value for creation.
  savepoint enrollment_proc;

  l_booking_id := p_booking_id;
  if l_booking_id is not null then
     l_create_flag := 2;  --update booking
  else
     l_create_flag := 1;  --create booking
  end if;

  hr_utility.set_location('The booking_id is : ', l_booking_id);



hr_utility.trace('l_create_flag'||l_create_flag);


 if (g_crt_upd = 'D') then
   raise e_upl_not_allowed;  -- View only flag is enabled but Trying to Upload
  end if;
  if (g_crt_upd = 'U' and l_create_flag = 1) then
   raise e_crt_not_allowed;  -- Update only flag is enabled but Trying to Create
 end if;


  --
  -- Call API
  --

  if(l_create_flag =1) then
    create_delegate_booking
    (p_effective_date               => p_effective_date
    ,p_booking_id                   => l_bo_id
    ,p_booking_status_type_id       => p_booking_status_type_id
    ,p_delegate_person_id           => p_delegate_person_id
    ,p_contact_id                   => p_contact_id
    ,p_business_group_id            => p_business_group_id
    ,p_event_id                     => p_event_id
    ,p_customer_id                  => p_customer_id
    ,p_authorizer_person_id         => p_authorizer_person_id
    ,p_date_booking_placed          => p_date_booking_placed
    ,p_corespondent                 => p_corespondent
    ,p_internal_booking_flag        => p_internal_booking_flag
    ,p_number_of_places             => p_number_of_places
    ,p_object_version_number        => l_obj_ver_num
    ,p_administrator                => p_administrator
    ,p_booking_priority             => p_booking_priority
    ,p_comments                     => p_comments
    ,p_contact_address_id           => p_contact_address_id
    ,p_delegate_contact_phone       => p_delegate_contact_phone
    ,p_delegate_contact_fax         => p_delegate_contact_fax
    ,p_third_party_customer_id      => p_third_party_customer_id
    ,p_third_party_contact_id       => p_third_party_contact_id
    ,p_third_party_address_id       => p_third_party_address_id
    ,p_third_party_contact_phone    => p_third_party_contact_phone
    ,p_third_party_contact_fax      => p_third_party_contact_fax
    ,p_date_status_changed          => p_date_status_changed
    ,p_failure_reason               => p_failure_reason
    ,p_attendance_result            => p_attendance_result
    ,p_language_id                  => p_language_id
    ,p_source_of_booking            => p_source_of_booking
    ,p_special_booking_instructions => p_special_booking_instructions
    ,p_successful_attendance_flag   => p_successful_attendance_flag
    ,p_tdb_information_category     => p_tdb_information_category
    ,p_tdb_information1             => p_tdb_information1
    ,p_tdb_information2             => p_tdb_information2
    ,p_tdb_information3             => p_tdb_information3
    ,p_tdb_information4             => p_tdb_information4
    ,p_tdb_information5             => p_tdb_information5
    ,p_tdb_information6             => p_tdb_information6
    ,p_tdb_information7             => p_tdb_information7
    ,p_tdb_information8             => p_tdb_information8
    ,p_tdb_information9             => p_tdb_information9
    ,p_tdb_information10            => p_tdb_information10
    ,p_tdb_information11            => p_tdb_information11
    ,p_tdb_information12            => p_tdb_information12
    ,p_tdb_information13            => p_tdb_information13
    ,p_tdb_information14            => p_tdb_information14
    ,p_tdb_information15            => p_tdb_information15
    ,p_tdb_information16            => p_tdb_information16
    ,p_tdb_information17            => p_tdb_information17
    ,p_tdb_information18            => p_tdb_information18
    ,p_tdb_information19            => p_tdb_information19
    ,p_tdb_information20            => p_tdb_information20
    ,p_create_finance_line          => p_create_finance_line
    ,p_finance_header_id            => p_finance_header_id
    ,p_currency_code                => p_currency_code
    ,p_standard_amount              => p_standard_amount
    ,p_unitary_amount               => p_unitary_amount
    ,p_money_amount                 => p_money_amount
    ,p_booking_deal_id              => p_booking_deal_id
    ,p_booking_deal_type            => p_booking_deal_type
    ,p_finance_line_id              => p_finance_line_id
    ,p_enrollment_type              => p_enrollment_type
    ,p_validate                     => m_validate
    ,p_organization_id              => p_organization_id
    ,p_sponsor_person_id            => p_sponsor_person_id
    ,p_sponsor_assignment_id        => c_sponsor_assignment_id
    ,p_person_address_id            => p_person_address_id
    ,p_delegate_assignment_id       => c_delegate_assignment_id
    ,p_delegate_contact_id          => p_delegate_contact_id
    ,p_delegate_contact_email       => p_delegate_contact_email
    ,p_third_party_email            => p_third_party_email
    ,p_person_address_type          => p_person_address_type
    ,p_line_id                      => p_line_id
    ,p_org_id                       => p_org_id
    ,p_daemon_flag                  => p_daemon_flag
    ,p_daemon_type                  => p_daemon_type
    ,p_old_event_id                 => p_old_event_id
    ,p_quote_line_id                => p_quote_line_id
    ,p_interface_source             => p_interface_source
    ,p_total_training_time          => p_total_training_time
    ,p_content_player_status        => p_content_player_status
    ,p_score                        => p_score
    ,p_completed_content            => p_completed_content
    ,p_total_content                => p_total_content
    ,p_return_status	 	    => p_return_status
    ,p_booking_justification_id     => p_booking_justification_id
    ,p_is_history_flag		    => p_is_history_flag
    ,p_override_prerequisites       => p_override_prerequisites
    ,p_override_learner_access      => p_override_learner_access
    );

  end if ;

  if(l_create_flag = 2) then


    hr_utility.trace('SRK in wrapper_proc booking p_booking_id '|| l_booking);

--p_object_version_number := 1;
    hr_utility.trace('SRK in wrapper_proc before update p_object_version_number '|| p_object_version_number);
 g_interface_code := nvl(l_interface_code,'PQP_OLM_ENROL_INTF');
 hr_utility.set_location('g_interface_code'||g_interface_code, 95);

g_enroll_rec.booking_status_type_id       :=  p_booking_status_type_id      ;
g_enroll_rec.delegate_person_id           :=  p_delegate_person_id          ;
g_enroll_rec.sponsor_contact_id           :=  p_contact_id                  ;
g_enroll_rec.business_group_id            :=  p_business_group_id           ;
g_enroll_rec.event_id                     :=  p_event_id                    ;
  hr_utility.trace('global p_event_id : ' || p_event_id);
  hr_utility.trace('g_enroll_rec.event_id : ' || g_enroll_rec.event_id);
g_enroll_rec.customer_id                  :=  p_customer_id                 ;
g_enroll_rec.authorizer_person_id         :=  p_authorizer_person_id        ;
g_enroll_rec.date_booking_placed          :=  p_date_booking_placed         ;
g_enroll_rec.correspondent                 :=  p_corespondent                ;
g_enroll_rec.internal_booking_flag        :=  p_internal_booking_flag       ;
g_enroll_rec.number_of_places             :=  p_number_of_places            ;
g_enroll_rec.administrator                :=  p_administrator               ;
g_enroll_rec.booking_priority             :=  p_booking_priority            ;
g_enroll_rec.comments                     :=  p_comments                    ;
g_enroll_rec.contact_address_id           :=  p_contact_address_id          ;
g_enroll_rec.correspondent_phone          :=  p_delegate_contact_phone      ;
g_enroll_rec.correspondent_fax         :=  p_delegate_contact_fax        ;
g_enroll_rec.third_party_customer_id      :=  p_third_party_customer_id     ;
g_enroll_rec.third_party_contact_id       :=  p_third_party_contact_id      ;
g_enroll_rec.third_party_address_id       :=  p_third_party_address_id      ;
g_enroll_rec.third_party_contact_phone    :=  p_third_party_contact_phone   ;
g_enroll_rec.third_party_contact_fax      :=  p_third_party_contact_fax     ;
g_enroll_rec.date_status_changed          :=  p_date_status_changed         ;
--g_enroll_rec.status_change_comments       :=  p_status_change_comments      ;
g_enroll_rec.failure_reason               :=  p_failure_reason              ;
g_enroll_rec.attendance_result            :=  p_attendance_result           ;
g_enroll_rec.language_id                  :=  p_language_id                 ;
g_enroll_rec.source_of_booking            :=  p_source_of_booking           ;
g_enroll_rec.special_booking_instructions :=  p_special_booking_instructions;
g_enroll_rec.successful_attendance_flag   :=  p_successful_attendance_flag  ;
g_enroll_rec.tdb_information_category     :=  p_tdb_information_category    ;
g_enroll_rec.tdb_information1             :=  p_tdb_information1            ;
g_enroll_rec.tdb_information2             :=  p_tdb_information2            ;
g_enroll_rec.tdb_information3             :=  p_tdb_information3            ;
g_enroll_rec.tdb_information4             :=  p_tdb_information4            ;
g_enroll_rec.tdb_information5             :=  p_tdb_information5            ;
g_enroll_rec.tdb_information6             :=  p_tdb_information6            ;
g_enroll_rec.tdb_information7             :=  p_tdb_information7            ;
g_enroll_rec.tdb_information8             :=  p_tdb_information8            ;
g_enroll_rec.tdb_information9             :=  p_tdb_information9            ;
g_enroll_rec.tdb_information10            :=  p_tdb_information10           ;
g_enroll_rec.tdb_information11            :=  p_tdb_information11           ;
g_enroll_rec.tdb_information12            :=  p_tdb_information12           ;
g_enroll_rec.tdb_information13            :=  p_tdb_information13           ;
g_enroll_rec.tdb_information14            :=  p_tdb_information14           ;
g_enroll_rec.tdb_information15            :=  p_tdb_information15           ;
g_enroll_rec.tdb_information16            :=  p_tdb_information16           ;
g_enroll_rec.tdb_information17            :=  p_tdb_information17           ;
g_enroll_rec.tdb_information18            :=  p_tdb_information18           ;
g_enroll_rec.tdb_information19            :=  p_tdb_information19           ;
g_enroll_rec.tdb_information20            :=  p_tdb_information20           ;
g_enroll_rec.finance_header_id            :=  p_finance_header_id           ;
g_enroll_rec.standard_amount              :=  p_standard_amount             ;
--g_enroll_rec.unitary_amount               :=  p_unitary_amount              ;
g_enroll_rec.money_amount                 :=  p_money_amount                ;
g_enroll_rec.currency_code                :=  p_currency_code               ;
g_enroll_rec.booking_deal_type            :=  p_booking_deal_type           ;
g_enroll_rec.booking_deal_id              :=  p_booking_deal_id             ;
--g_enroll_rec.enrollment_type              :=  p_enrollment_type             ;
g_enroll_rec.organization_id              :=  p_organization_id             ;
g_enroll_rec.sponsor_person_id            :=  p_sponsor_person_id           ;
g_enroll_rec.sponsor_assignment_id        :=  p_sponsor_assignment_id       ;
g_enroll_rec.person_address_id            :=  p_person_address_id           ;
g_enroll_rec.delegate_assignment_id       :=  p_delegate_assignment_id      ;
g_enroll_rec.delegate_contact_id          :=  p_delegate_contact_id         ;
g_enroll_rec.correspondent_email       :=  p_delegate_contact_email      ;
g_enroll_rec.third_party_email            :=  p_third_party_email           ;
g_enroll_rec.correspondent_address_type          :=  p_person_address_type         ;
g_enroll_rec.line_id                      :=  p_line_id                     ;
g_enroll_rec.org_id                       :=  p_org_id                      ;
--g_enroll_rec.daemon_flag                  :=  p_daemon_flag                 ;
--g_enroll_rec.daemon_type                  :=  p_daemon_type                 ;
g_enroll_rec.old_event_id                 :=  p_old_event_id                ;
g_enroll_rec.quote_line_id                :=  p_quote_line_id               ;
g_enroll_rec.interface_source             :=  p_interface_source            ;
g_enroll_rec.total_training_time          :=  p_total_training_time         ;
g_enroll_rec.content_player_status        :=  p_content_player_status       ;
g_enroll_rec.score                        :=  p_score                       ;
g_enroll_rec.completed_content            :=  p_completed_content           ;
g_enroll_rec.total_content                :=  p_total_content               ;
g_enroll_rec.booking_justification_id     :=  p_booking_justification_id    ;
--g_enroll_rec.is_history_flag       	  :=  p_is_history_flag       	;


   select object_version_number into l_object_version_number
    from ota_delegate_bookings where
      booking_id = l_booking_id;

  l_enroll_rec := Get_Record_Values(g_interface_code);
  hr_utility.trace('l_enroll_rec.event_id : ' || l_enroll_rec.event_id);

    update_delegate_booking
    (p_effective_date               => p_effective_date
    ,p_booking_id                   => l_booking_id
    ,p_booking_status_type_id       => l_enroll_rec.booking_status_type_id
    ,p_delegate_person_id           => l_enroll_rec.delegate_person_id
    ,p_contact_id                   => l_enroll_rec.sponsor_contact_id
    ,p_business_group_id            => l_enroll_rec.business_group_id
    ,p_event_id                     => l_enroll_rec.event_id
    ,p_customer_id                  => l_enroll_rec.customer_id
    ,p_authorizer_person_id         => l_enroll_rec.authorizer_person_id
    ,p_date_booking_placed          => l_enroll_rec.date_booking_placed
    ,p_corespondent                 => l_enroll_rec.correspondent
    ,p_internal_booking_flag        => l_enroll_rec.internal_booking_flag
    ,p_number_of_places             => l_enroll_rec.number_of_places
    ,p_object_version_number        => l_object_version_number
    ,p_administrator                => l_enroll_rec.administrator
    ,p_booking_priority             => l_enroll_rec.booking_priority
    ,p_comments                     => l_enroll_rec.comments
    ,p_contact_address_id           => l_enroll_rec.contact_address_id
    ,p_delegate_contact_phone       => l_enroll_rec.correspondent_phone
    ,p_delegate_contact_fax         => l_enroll_rec.correspondent_fax
    ,p_third_party_customer_id      => l_enroll_rec.third_party_customer_id
    ,p_third_party_contact_id       => l_enroll_rec.third_party_contact_id
    ,p_third_party_address_id       => l_enroll_rec.third_party_address_id
    ,p_third_party_contact_phone    => l_enroll_rec.third_party_contact_phone
    ,p_third_party_contact_fax      => l_enroll_rec.third_party_contact_fax
    ,p_date_status_changed          => l_enroll_rec.date_status_changed
--    ,p_status_change_comments       => l_enroll_rec.status_change_comments
    ,p_failure_reason               => l_enroll_rec.failure_reason
    ,p_attendance_result            => l_enroll_rec.attendance_result
    ,p_language_id                  => l_enroll_rec.language_id
    ,p_source_of_booking            => l_enroll_rec.source_of_booking
    ,p_special_booking_instructions => l_enroll_rec.special_booking_instructions
    ,p_successful_attendance_flag   => l_enroll_rec.successful_attendance_flag
    ,p_tdb_information_category     => l_enroll_rec.tdb_information_category
    ,p_tdb_information1             => l_enroll_rec.tdb_information1
    ,p_tdb_information2             => l_enroll_rec.tdb_information2
    ,p_tdb_information3             => l_enroll_rec.tdb_information3
    ,p_tdb_information4             => l_enroll_rec.tdb_information4
    ,p_tdb_information5             => l_enroll_rec.tdb_information5
    ,p_tdb_information6             => l_enroll_rec.tdb_information6
    ,p_tdb_information7             => l_enroll_rec.tdb_information7
    ,p_tdb_information8             => l_enroll_rec.tdb_information8
    ,p_tdb_information9             => l_enroll_rec.tdb_information9
    ,p_tdb_information10            => l_enroll_rec.tdb_information10
    ,p_tdb_information11            => l_enroll_rec.tdb_information11
    ,p_tdb_information12            => l_enroll_rec.tdb_information12
    ,p_tdb_information13            => l_enroll_rec.tdb_information13
    ,p_tdb_information14            => l_enroll_rec.tdb_information14
    ,p_tdb_information15            => l_enroll_rec.tdb_information15
    ,p_tdb_information16            => l_enroll_rec.tdb_information16
    ,p_tdb_information17            => l_enroll_rec.tdb_information17
    ,p_tdb_information18            => l_enroll_rec.tdb_information18
    ,p_tdb_information19            => l_enroll_rec.tdb_information19
    ,p_tdb_information20            => l_enroll_rec.tdb_information20
    ,p_update_finance_line          => l_enroll_rec.finance_header_id
    ,p_tfl_object_version_number    => l_tfl_object_version_number
    ,p_finance_header_id            => l_enroll_rec.finance_header_id
    ,p_finance_line_id              => p_finance_line_id
    ,p_standard_amount              => l_enroll_rec.standard_amount
    ,p_unitary_amount               => p_unitary_amount
    ,p_money_amount                 => l_enroll_rec.money_amount
    ,p_currency_code                => l_enroll_rec.currency_code
    ,p_booking_deal_type            => l_enroll_rec.booking_deal_type
    ,p_booking_deal_id              => l_enroll_rec.booking_deal_id
    ,p_enrollment_type              => p_enrollment_type
    ,p_validate                     => m_validate
    ,p_organization_id              => l_enroll_rec.organization_id
    ,p_sponsor_person_id            => l_enroll_rec.sponsor_person_id
    ,p_sponsor_assignment_id        => l_enroll_rec.sponsor_assignment_id
    ,p_person_address_id            => l_enroll_rec.person_address_id
    ,p_delegate_assignment_id       => l_enroll_rec.delegate_assignment_id
    ,p_delegate_contact_id          => l_enroll_rec.delegate_contact_id
    ,p_delegate_contact_email       => l_enroll_rec.correspondent_email
    ,p_third_party_email            => l_enroll_rec.third_party_email
    ,p_person_address_type          => l_enroll_rec.correspondent_address_type
    ,p_line_id                      => l_enroll_rec.line_id
    ,p_org_id                       => l_enroll_rec.org_id
    ,p_daemon_flag                  => p_daemon_flag
    ,p_daemon_type                  => p_daemon_type
    ,p_old_event_id                 => l_enroll_rec.old_event_id
    ,p_quote_line_id                => l_enroll_rec.quote_line_id
    ,p_interface_source             => l_enroll_rec.interface_source
    ,p_total_training_time          => l_enroll_rec.total_training_time
    ,p_content_player_status        => l_enroll_rec.content_player_status
    ,p_score                        => l_enroll_rec.score
    ,p_completed_content            => l_enroll_rec.completed_content
    ,p_total_content                => l_enroll_rec.total_content
    ,p_return_status	 	    => p_return_status
    ,p_booking_justification_id     => l_enroll_rec.booking_justification_id
    ,p_is_history_flag		    => p_is_history_flag
    ,p_override_prerequisites 	    => p_override_prerequisites
    ,p_override_learner_access 	    => p_override_learner_access
    );
  end if;


exception
--  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    --rollback to enrollment_proc;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
--    p_object_version_number        := null;
  --  p_finance_line_id              := l_finance_line_id;
--    p_return_status := hr_multi_message.get_return_status_disable;
--    hr_utility.set_location(' Leaving:' || l_proc, 30);
--  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
  --  rollback to enrollment_proc;


  when e_upl_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_upl_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc, 90);
    hr_utility.raise_error;
  when e_crt_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_crt_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc, 100);
    hr_utility.raise_error;
  when others then
   --l_error_msg := Substr(SQLERRM,1,2000);
   hr_utility.set_location('SQLCODE :' || SQLCODE,90);
   hr_utility.set_location('SQLERRM :' || SQLERRM,90);
   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,500) );
   hr_utility.set_location('Leaving: ' || l_proc, 110);
   hr_utility.raise_error;
    --if hr_multi_message.unexpected_error_add(l_proc) then
      -- hr_utility.set_location(' Leaving:' || l_proc,40);
       --raise;
    --end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
--    p_object_version_number        := null;
--    p_finance_line_id              := l_finance_line_id;
    --p_return_status := hr_multi_message.get_return_status_disable;
 --   hr_utility.set_location(' Leaving:' || l_proc,50);

end InsUpd_Enroll;


PROCEDURE create_delegate_booking
  (p_effective_date               in     date	 default null
  ,p_booking_id                   in     number
  ,p_booking_status_type_id       in     number
  ,p_delegate_person_id           in     number    default null
  ,p_contact_id                   in     number
  ,p_business_group_id            in     number
  ,p_event_id                     in     number
  ,p_customer_id                  in     number    default null
  ,p_authorizer_person_id         in     number    default null
  ,p_date_booking_placed          in     date
  ,p_corespondent                 in     varchar2  default null
  ,p_internal_booking_flag        in     varchar2
  ,p_number_of_places             in     number
  ,p_object_version_number           out nocopy number
  ,p_administrator                in     number    default null
  ,p_booking_priority             in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_contact_address_id           in     number    default null
  ,p_delegate_contact_phone       in     varchar2  default null
  ,p_delegate_contact_fax         in     varchar2  default null
  ,p_third_party_customer_id      in     number    default null
  ,p_third_party_contact_id       in     number    default null
  ,p_third_party_address_id       in     number    default null
  ,p_third_party_contact_phone    in     varchar2  default null
  ,p_third_party_contact_fax      in     varchar2  default null
  ,p_date_status_changed          in     date      default null
  ,p_failure_reason               in     varchar2  default null
  ,p_attendance_result            in     varchar2  default null
  ,p_language_id                  in     number    default null
  ,p_source_of_booking            in     varchar2  default null
  ,p_special_booking_instructions in     varchar2  default null
  ,p_successful_attendance_flag   in     varchar2  default null
  ,p_tdb_information_category     in     varchar2  default null
  ,p_tdb_information1             in     varchar2  default null
  ,p_tdb_information2             in     varchar2  default null
  ,p_tdb_information3             in     varchar2  default null
  ,p_tdb_information4             in     varchar2  default null
  ,p_tdb_information5             in     varchar2  default null
  ,p_tdb_information6             in     varchar2  default null
  ,p_tdb_information7             in     varchar2  default null
  ,p_tdb_information8             in     varchar2  default null
  ,p_tdb_information9             in     varchar2  default null
  ,p_tdb_information10            in     varchar2  default null
  ,p_tdb_information11            in     varchar2  default null
  ,p_tdb_information12            in     varchar2  default null
  ,p_tdb_information13            in     varchar2  default null
  ,p_tdb_information14            in     varchar2  default null
  ,p_tdb_information15            in     varchar2  default null
  ,p_tdb_information16            in     varchar2  default null
  ,p_tdb_information17            in     varchar2  default null
  ,p_tdb_information18            in     varchar2  default null
  ,p_tdb_information19            in     varchar2  default null
  ,p_tdb_information20            in     varchar2  default null
  ,p_create_finance_line          in     varchar2  default null
  ,p_finance_header_id            in     number    default null
  ,p_currency_code                in     varchar2  default null
  ,p_standard_amount              in     number    default null
  ,p_unitary_amount               in     number    default null
  ,p_money_amount                 in     number    default null
  ,p_booking_deal_id              in     number    default null
  ,p_booking_deal_type            in     varchar2  default null
  ,p_finance_line_id              in out nocopy number
  ,p_enrollment_type              in     varchar2  default null
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_id              in     number    default null
  ,p_sponsor_person_id            in     number    default null
  ,p_sponsor_assignment_id        in     number    default null
  ,p_person_address_id            in     number    default null
  ,p_delegate_assignment_id       in     number    default null
  ,p_delegate_contact_id          in     number    default null
  ,p_delegate_contact_email       in     varchar2  default null
  ,p_third_party_email            in     varchar2  default null
  ,p_person_address_type          in     varchar2  default null
  ,p_line_id                      in     number    default null
  ,p_org_id                       in     number    default null
  ,p_daemon_flag                  in     varchar2  default null
  ,p_daemon_type                  in     varchar2  default null
  ,p_old_event_id                 in     number    default null
  ,p_quote_line_id                in     number    default null
  ,p_interface_source             in     varchar2  default null
  ,p_total_training_time          in     varchar2  default null
  ,p_content_player_status        in     varchar2  default null
  ,p_score                        in     number    default null
  ,p_completed_content            in     number    default null
  ,p_total_content                in     number    default null
  ,p_return_status                out 	 nocopy    varchar2
  ,p_booking_justification_id 	  in 	 number    default null
  ,p_is_history_flag   		  in 	 varchar2  default 'N'
  ,p_override_prerequisites 	  in 	 varchar2  default null
  ,p_override_learner_access 	  in 	 varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_finance_line_id               number;
  --
  -- Other variables
  l_booking_id                   number;
  l_proc    varchar2(72) := g_package ||'create_delegate_booking';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_delegate_booking;
  --
  -- Initialise Multiple Message Detection
  --
--  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_finance_line_id               := p_finance_line_id;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  ota_tdb_ins.set_base_key_value
    (p_booking_id => p_booking_id
    );
  --
  -- Call API
  --
  ota_delegate_booking_api.create_delegate_booking
    (p_effective_date               => p_effective_date
    ,p_booking_id                   => l_booking_id
    ,p_booking_status_type_id       => p_booking_status_type_id
    ,p_delegate_person_id           => p_delegate_person_id
    ,p_contact_id                   => p_contact_id
    ,p_business_group_id            => p_business_group_id
    ,p_event_id                     => p_event_id
    ,p_customer_id                  => p_customer_id
    ,p_authorizer_person_id         => p_authorizer_person_id
    ,p_date_booking_placed          => p_date_booking_placed
    ,p_corespondent                 => p_corespondent
    ,p_internal_booking_flag        => p_internal_booking_flag
    ,p_number_of_places             => p_number_of_places
    ,p_object_version_number        => p_object_version_number
    ,p_administrator                => p_administrator
    ,p_booking_priority             => p_booking_priority
    ,p_comments                     => p_comments
    ,p_contact_address_id           => p_contact_address_id
    ,p_delegate_contact_phone       => p_delegate_contact_phone
    ,p_delegate_contact_fax         => p_delegate_contact_fax
    ,p_third_party_customer_id      => p_third_party_customer_id
    ,p_third_party_contact_id       => p_third_party_contact_id
    ,p_third_party_address_id       => p_third_party_address_id
    ,p_third_party_contact_phone    => p_third_party_contact_phone
    ,p_third_party_contact_fax      => p_third_party_contact_fax
    ,p_date_status_changed          => p_date_status_changed
    ,p_failure_reason               => p_failure_reason
    ,p_attendance_result            => p_attendance_result
    ,p_language_id                  => p_language_id
    ,p_source_of_booking            => p_source_of_booking
    ,p_special_booking_instructions => p_special_booking_instructions
    ,p_successful_attendance_flag   => p_successful_attendance_flag
    ,p_tdb_information_category     => p_tdb_information_category
    ,p_tdb_information1             => p_tdb_information1
    ,p_tdb_information2             => p_tdb_information2
    ,p_tdb_information3             => p_tdb_information3
    ,p_tdb_information4             => p_tdb_information4
    ,p_tdb_information5             => p_tdb_information5
    ,p_tdb_information6             => p_tdb_information6
    ,p_tdb_information7             => p_tdb_information7
    ,p_tdb_information8             => p_tdb_information8
    ,p_tdb_information9             => p_tdb_information9
    ,p_tdb_information10            => p_tdb_information10
    ,p_tdb_information11            => p_tdb_information11
    ,p_tdb_information12            => p_tdb_information12
    ,p_tdb_information13            => p_tdb_information13
    ,p_tdb_information14            => p_tdb_information14
    ,p_tdb_information15            => p_tdb_information15
    ,p_tdb_information16            => p_tdb_information16
    ,p_tdb_information17            => p_tdb_information17
    ,p_tdb_information18            => p_tdb_information18
    ,p_tdb_information19            => p_tdb_information19
    ,p_tdb_information20            => p_tdb_information20
    ,p_create_finance_line          => p_create_finance_line
    ,p_finance_header_id            => p_finance_header_id
    ,p_currency_code                => p_currency_code
    ,p_standard_amount              => p_standard_amount
    ,p_unitary_amount               => p_unitary_amount
    ,p_money_amount                 => p_money_amount
    ,p_booking_deal_id              => p_booking_deal_id
    ,p_booking_deal_type            => p_booking_deal_type
    ,p_finance_line_id              => p_finance_line_id
    ,p_enrollment_type              => p_enrollment_type
    ,p_validate                     => l_validate
    ,p_organization_id              => p_organization_id
    ,p_sponsor_person_id            => p_sponsor_person_id
    ,p_sponsor_assignment_id        => p_sponsor_assignment_id
    ,p_person_address_id            => p_person_address_id
    ,p_delegate_assignment_id       => p_delegate_assignment_id
    ,p_delegate_contact_id          => p_delegate_contact_id
    ,p_delegate_contact_email       => p_delegate_contact_email
    ,p_third_party_email            => p_third_party_email
    ,p_person_address_type          => p_person_address_type
    ,p_line_id                      => p_line_id
    ,p_org_id                       => p_org_id
    ,p_daemon_flag                  => p_daemon_flag
    ,p_daemon_type                  => p_daemon_type
    ,p_old_event_id                 => p_old_event_id
    ,p_quote_line_id                => p_quote_line_id
    ,p_interface_source             => p_interface_source
    ,p_total_training_time          => p_total_training_time
    ,p_content_player_status        => p_content_player_status
    ,p_score                        => p_score
    ,p_completed_content            => p_completed_content
    ,p_total_content                => p_total_content
    ,p_booking_justification_id     => p_booking_justification_id
    ,p_is_history_flag		    => p_is_history_flag
    ,p_override_prerequisites       => p_override_prerequisites
    ,p_override_learner_access      => p_override_learner_access
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_delegate_booking;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_finance_line_id              := l_finance_line_id;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_delegate_booking;
--    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
--    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_finance_line_id              := l_finance_line_id;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_delegate_booking;


PROCEDURE update_delegate_booking
  (p_effective_date               in     date	  default null
  ,p_booking_id                   in     number
  ,p_booking_status_type_id       in     number    default hr_api.g_number
  ,p_delegate_person_id           in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_event_id                     in     number    default hr_api.g_number
  ,p_customer_id                  in     number    default hr_api.g_number
  ,p_authorizer_person_id         in     number    default hr_api.g_number
  ,p_date_booking_placed          in     date      default hr_api.g_date
  ,p_corespondent                 in     varchar2  default hr_api.g_varchar2
  ,p_internal_booking_flag        in     varchar2  default hr_api.g_varchar2
  ,p_number_of_places             in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_administrator                in     number    default hr_api.g_number
  ,p_booking_priority             in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_contact_address_id           in     number    default hr_api.g_number
  ,p_delegate_contact_phone       in     varchar2  default hr_api.g_varchar2
  ,p_delegate_contact_fax         in     varchar2  default hr_api.g_varchar2
  ,p_third_party_customer_id      in     number    default hr_api.g_number
  ,p_third_party_contact_id       in     number    default hr_api.g_number
  ,p_third_party_address_id       in     number    default hr_api.g_number
  ,p_third_party_contact_phone    in     varchar2  default hr_api.g_varchar2
  ,p_third_party_contact_fax      in     varchar2  default hr_api.g_varchar2
  ,p_date_status_changed          in     date      default hr_api.g_date
  ,p_status_change_comments       in     varchar2  default hr_api.g_varchar2
  ,p_failure_reason               in     varchar2  default hr_api.g_varchar2
  ,p_attendance_result            in     varchar2  default hr_api.g_varchar2
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_source_of_booking            in     varchar2  default hr_api.g_varchar2
  ,p_special_booking_instructions in     varchar2  default hr_api.g_varchar2
  ,p_successful_attendance_flag   in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information1             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information2             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information3             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information4             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information5             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information6             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information7             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information8             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information9             in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information10            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information11            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information12            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information13            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information14            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information15            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information16            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information17            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information18            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information19            in     varchar2  default hr_api.g_varchar2
  ,p_tdb_information20            in     varchar2  default hr_api.g_varchar2
  ,p_update_finance_line          in     varchar2  default hr_api.g_varchar2
  ,p_tfl_object_version_number    in out nocopy number
  ,p_finance_header_id            in     number    default hr_api.g_number
  ,p_finance_line_id              in out nocopy number
  ,p_standard_amount              in     number    default hr_api.g_number
  ,p_unitary_amount               in     number    default hr_api.g_number
  ,p_money_amount                 in     number    default hr_api.g_number
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_booking_deal_type            in     varchar2  default hr_api.g_varchar2
  ,p_booking_deal_id              in     number    default hr_api.g_number
  ,p_enrollment_type              in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_sponsor_person_id            in     number    default hr_api.g_number
  ,p_sponsor_assignment_id        in     number    default hr_api.g_number
  ,p_person_address_id            in     number    default hr_api.g_number
  ,p_delegate_assignment_id       in     number    default hr_api.g_number
  ,p_delegate_contact_id          in     number    default hr_api.g_number
  ,p_delegate_contact_email       in     varchar2  default hr_api.g_varchar2
  ,p_third_party_email            in     varchar2  default hr_api.g_varchar2
  ,p_person_address_type          in     varchar2  default hr_api.g_varchar2
  ,p_line_id                      in     number    default hr_api.g_number
  ,p_org_id                       in     number    default hr_api.g_number
  ,p_daemon_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_daemon_type                  in     varchar2  default hr_api.g_varchar2
  ,p_old_event_id                 in     number    default hr_api.g_number
  ,p_quote_line_id                in     number    default hr_api.g_number
  ,p_interface_source             in     varchar2  default hr_api.g_varchar2
  ,p_total_training_time          in     varchar2  default hr_api.g_varchar2
  ,p_content_player_status        in     varchar2  default hr_api.g_varchar2
  ,p_score                        in     number    default hr_api.g_number
  ,p_completed_content            in     number    default hr_api.g_number
  ,p_total_content                in     number    default hr_api.g_number
  ,p_return_status                out 	 nocopy varchar2
  ,p_booking_justification_id     in 	 number    default hr_api.g_number
  ,p_is_history_flag       	  in     varchar2  default hr_api.g_varchar2
  ,p_override_prerequisites 	  in 	 varchar2
  ,p_override_learner_access 	  in 	 varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_tfl_object_version_number     number;
  l_finance_line_id               number;
  --
  l_date_booking_placed ota_delegate_bookings.date_booking_placed%TYPE;
  l_date_status_changed ota_delegate_bookings.date_status_changed%TYPE;



  CURSOR booking_csr
  IS
  SELECT b.date_booking_placed
  FROM   ota_delegate_bookings b
  WHERE  b.booking_id = p_booking_id;
  --

  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_delegate_booking';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_delegate_booking;
  --
  -- Initialise Multiple Message Detection
  --
 -- hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  l_tfl_object_version_number     := p_tfl_object_version_number;
  l_finance_line_id               := p_finance_line_id;
  --
  --
    hr_utility.trace('SRK in update_deleg_booki booking p_booking_id '|| p_booking_id);
  OPEN booking_csr;
  FETCH booking_csr INTO l_date_booking_placed;
  CLOSE booking_csr;
  l_date_status_changed := trunc(sysdate);
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
    hr_utility.trace('SRK in update_deleg_booki before the api call p_booking_id '|| p_booking_id);
  ota_delegate_booking_api.update_delegate_booking
    (p_effective_date               => p_effective_date
    ,p_booking_id                   => p_booking_id
    ,p_booking_status_type_id       => p_booking_status_type_id
    ,p_delegate_person_id           => p_delegate_person_id
    ,p_contact_id                   => p_contact_id
    ,p_business_group_id            => p_business_group_id
    ,p_event_id                     => p_event_id
    ,p_customer_id                  => p_customer_id
    ,p_authorizer_person_id         => p_authorizer_person_id
    ,p_date_booking_placed          => l_date_booking_placed
    ,p_corespondent                 => p_corespondent
    ,p_internal_booking_flag        => p_internal_booking_flag
    ,p_number_of_places             => p_number_of_places
    ,p_object_version_number        => p_object_version_number
    ,p_administrator                => p_administrator
    ,p_booking_priority             => p_booking_priority
    ,p_comments                     => p_comments
    ,p_contact_address_id           => p_contact_address_id
    ,p_delegate_contact_phone       => p_delegate_contact_phone
    ,p_delegate_contact_fax         => p_delegate_contact_fax
    ,p_third_party_customer_id      => p_third_party_customer_id
    ,p_third_party_contact_id       => p_third_party_contact_id
    ,p_third_party_address_id       => p_third_party_address_id
    ,p_third_party_contact_phone    => p_third_party_contact_phone
    ,p_third_party_contact_fax      => p_third_party_contact_fax
    ,p_date_status_changed          => l_date_status_changed
    ,p_status_change_comments       => p_status_change_comments
    ,p_failure_reason               => p_failure_reason
    ,p_attendance_result            => p_attendance_result
    ,p_language_id                  => p_language_id
    ,p_source_of_booking            => p_source_of_booking
    ,p_special_booking_instructions => p_special_booking_instructions
    ,p_successful_attendance_flag   => p_successful_attendance_flag
    ,p_tdb_information_category     => p_tdb_information_category
    ,p_tdb_information1             => p_tdb_information1
    ,p_tdb_information2             => p_tdb_information2
    ,p_tdb_information3             => p_tdb_information3
    ,p_tdb_information4             => p_tdb_information4
    ,p_tdb_information5             => p_tdb_information5
    ,p_tdb_information6             => p_tdb_information6
    ,p_tdb_information7             => p_tdb_information7
    ,p_tdb_information8             => p_tdb_information8
    ,p_tdb_information9             => p_tdb_information9
    ,p_tdb_information10            => p_tdb_information10
    ,p_tdb_information11            => p_tdb_information11
    ,p_tdb_information12            => p_tdb_information12
    ,p_tdb_information13            => p_tdb_information13
    ,p_tdb_information14            => p_tdb_information14
    ,p_tdb_information15            => p_tdb_information15
    ,p_tdb_information16            => p_tdb_information16
    ,p_tdb_information17            => p_tdb_information17
    ,p_tdb_information18            => p_tdb_information18
    ,p_tdb_information19            => p_tdb_information19
    ,p_tdb_information20            => p_tdb_information20
    ,p_update_finance_line          => p_update_finance_line
    ,p_tfl_object_version_number    => l_tfl_object_version_number
    ,p_finance_header_id            => p_finance_header_id
    ,p_finance_line_id              => p_finance_line_id
    ,p_standard_amount              => p_standard_amount
    ,p_unitary_amount               => p_unitary_amount
    ,p_money_amount                 => p_money_amount
    ,p_currency_code                => p_currency_code
    ,p_booking_deal_type            => p_booking_deal_type
    ,p_booking_deal_id              => p_booking_deal_id
    ,p_enrollment_type              => p_enrollment_type
    ,p_validate                     => l_validate
    ,p_organization_id              => p_organization_id
    ,p_sponsor_person_id            => p_sponsor_person_id
    ,p_sponsor_assignment_id        => p_sponsor_assignment_id
    ,p_person_address_id            => p_person_address_id
    ,p_delegate_assignment_id       => p_delegate_assignment_id
    ,p_delegate_contact_id          => p_delegate_contact_id
    ,p_delegate_contact_email       => p_delegate_contact_email
    ,p_third_party_email            => p_third_party_email
    ,p_person_address_type          => p_person_address_type
    ,p_line_id                      => p_line_id
    ,p_org_id                       => p_org_id
    ,p_daemon_flag                  => p_daemon_flag
    ,p_daemon_type                  => p_daemon_type
    ,p_old_event_id                 => p_old_event_id
    ,p_quote_line_id                => p_quote_line_id
    ,p_interface_source             => p_interface_source
    ,p_total_training_time          => p_total_training_time
    ,p_content_player_status        => p_content_player_status
    ,p_score                        => p_score
    ,p_completed_content            => p_completed_content
    ,p_total_content                => p_total_content
    ,p_booking_justification_id     => p_booking_justification_id
    ,p_is_history_flag		    => p_is_history_flag
    ,p_override_prerequisites 	 => p_override_prerequisites
   ,p_override_learner_access 	 => p_override_learner_access
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
end update_delegate_booking;




end pqp_riw_enroll_wrapper;

/
