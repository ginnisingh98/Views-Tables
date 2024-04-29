--------------------------------------------------------
--  DDL for Package Body OTA_DELEGATE_BOOKING_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_DELEGATE_BOOKING_BE2" as 
--Code generated on 30/08/2013 11:36:00
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_delegate_booking_a (
p_effective_date               date,
p_booking_id                   number,
p_booking_status_type_id       number,
p_delegate_person_id           number,
p_contact_id                   number,
p_business_group_id            number,
p_event_id                     number,
p_customer_id                  number,
p_authorizer_person_id         number,
p_date_booking_placed          date,
p_corespondent                 varchar2,
p_internal_booking_flag        varchar2,
p_number_of_places             number,
p_object_version_number        number,
p_administrator                number,
p_booking_priority             varchar2,
p_comments                     varchar2,
p_contact_address_id           number,
p_delegate_contact_phone       varchar2,
p_delegate_contact_fax         varchar2,
p_third_party_customer_id      number,
p_third_party_contact_id       number,
p_third_party_address_id       number,
p_third_party_contact_phone    varchar2,
p_third_party_contact_fax      varchar2,
p_date_status_changed          date,
p_status_change_comments       varchar2,
p_failure_reason               varchar2,
p_attendance_result            varchar2,
p_language_id                  number,
p_source_of_booking            varchar2,
p_special_booking_instructions varchar2,
p_successful_attendance_flag   varchar2,
p_tdb_information_category     varchar2,
p_tdb_information1             varchar2,
p_tdb_information2             varchar2,
p_tdb_information3             varchar2,
p_tdb_information4             varchar2,
p_tdb_information5             varchar2,
p_tdb_information6             varchar2,
p_tdb_information7             varchar2,
p_tdb_information8             varchar2,
p_tdb_information9             varchar2,
p_tdb_information10            varchar2,
p_tdb_information11            varchar2,
p_tdb_information12            varchar2,
p_tdb_information13            varchar2,
p_tdb_information14            varchar2,
p_tdb_information15            varchar2,
p_tdb_information16            varchar2,
p_tdb_information17            varchar2,
p_tdb_information18            varchar2,
p_tdb_information19            varchar2,
p_tdb_information20            varchar2,
p_update_finance_line          varchar2,
p_tfl_object_version_number    number,
p_finance_header_id            number,
p_currency_code                varchar2,
p_standard_amount              number,
p_unitary_amount               number,
p_money_amount                 number,
p_booking_deal_id              number,
p_booking_deal_type            varchar2,
p_finance_line_id              number,
p_enrollment_type              varchar2,
p_organization_id              number,
p_sponsor_person_id            number,
p_sponsor_assignment_id        number,
p_person_address_id            number,
p_delegate_assignment_id       number,
p_delegate_contact_id          number,
p_delegate_contact_email       varchar2,
p_third_party_email            varchar2,
p_person_address_type          varchar2,
p_line_id                      number,
p_org_id                       number,
p_daemon_flag                  varchar2,
p_daemon_type                  varchar2,
p_old_event_id                 number,
p_quote_line_id                number,
p_interface_source             varchar2,
p_total_training_time          varchar2,
p_content_player_status        varchar2,
p_score                        number,
p_completed_content            number,
p_total_content                number,
p_booking_justification_id     number,
p_is_history_flag              varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  ota_delegate_booking_be2.update_delegate_booking_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.ota.api.delegate_booking.update_delegate_booking';
  l_message:=wf_event.test(l_event_name);
  --
  if (l_message='MESSAGE') then
    hr_utility.set_location(l_proc,20);
    --
    -- get a key for the event
    --
    open get_seq;
    fetch get_seq into l_event_key;
    close get_seq;
    --
    -- build the xml data for the event
    --
    dbms_lob.createTemporary(l_event_data,false,dbms_lob.call);
    l_text:='<?xml version =''1.0'' encoding =''ASCII''?>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<delegate_booking>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<booking_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_booking_id);
    l_text:=l_text||'</booking_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<booking_status_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_booking_status_type_id);
    l_text:=l_text||'</booking_status_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<delegate_person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_delegate_person_id);
    l_text:=l_text||'</delegate_person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<contact_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_contact_id);
    l_text:=l_text||'</contact_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<event_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_event_id);
    l_text:=l_text||'</event_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<customer_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_customer_id);
    l_text:=l_text||'</customer_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<authorizer_person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_authorizer_person_id);
    l_text:=l_text||'</authorizer_person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_booking_placed>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_booking_placed);
    l_text:=l_text||'</date_booking_placed>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<corespondent>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_corespondent);
    l_text:=l_text||'</corespondent>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<internal_booking_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_internal_booking_flag);
    l_text:=l_text||'</internal_booking_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<number_of_places>';
    l_text:=l_text||fnd_number.number_to_canonical(p_number_of_places);
    l_text:=l_text||'</number_of_places>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<administrator>';
    l_text:=l_text||fnd_number.number_to_canonical(p_administrator);
    l_text:=l_text||'</administrator>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<booking_priority>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_booking_priority);
    l_text:=l_text||'</booking_priority>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<contact_address_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_contact_address_id);
    l_text:=l_text||'</contact_address_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<delegate_contact_phone>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_delegate_contact_phone);
    l_text:=l_text||'</delegate_contact_phone>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<delegate_contact_fax>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_delegate_contact_fax);
    l_text:=l_text||'</delegate_contact_fax>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<third_party_customer_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_third_party_customer_id);
    l_text:=l_text||'</third_party_customer_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<third_party_contact_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_third_party_contact_id);
    l_text:=l_text||'</third_party_contact_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<third_party_address_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_third_party_address_id);
    l_text:=l_text||'</third_party_address_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<third_party_contact_phone>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_third_party_contact_phone);
    l_text:=l_text||'</third_party_contact_phone>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<third_party_contact_fax>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_third_party_contact_fax);
    l_text:=l_text||'</third_party_contact_fax>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_status_changed>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_status_changed);
    l_text:=l_text||'</date_status_changed>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<status_change_comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_status_change_comments);
    l_text:=l_text||'</status_change_comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<failure_reason>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_failure_reason);
    l_text:=l_text||'</failure_reason>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attendance_result>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attendance_result);
    l_text:=l_text||'</attendance_result>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<language_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_language_id);
    l_text:=l_text||'</language_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<source_of_booking>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_source_of_booking);
    l_text:=l_text||'</source_of_booking>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<special_booking_instructions>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_special_booking_instructions);
    l_text:=l_text||'</special_booking_instructions>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<successful_attendance_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_successful_attendance_flag);
    l_text:=l_text||'</successful_attendance_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information_category);
    l_text:=l_text||'</tdb_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information1);
    l_text:=l_text||'</tdb_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information2);
    l_text:=l_text||'</tdb_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information3);
    l_text:=l_text||'</tdb_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information4);
    l_text:=l_text||'</tdb_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information5);
    l_text:=l_text||'</tdb_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information6);
    l_text:=l_text||'</tdb_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information7);
    l_text:=l_text||'</tdb_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information8);
    l_text:=l_text||'</tdb_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information9);
    l_text:=l_text||'</tdb_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information10);
    l_text:=l_text||'</tdb_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information11);
    l_text:=l_text||'</tdb_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information12);
    l_text:=l_text||'</tdb_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information13);
    l_text:=l_text||'</tdb_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information14);
    l_text:=l_text||'</tdb_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information15);
    l_text:=l_text||'</tdb_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information16);
    l_text:=l_text||'</tdb_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information17);
    l_text:=l_text||'</tdb_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information18);
    l_text:=l_text||'</tdb_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information19);
    l_text:=l_text||'</tdb_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tdb_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tdb_information20);
    l_text:=l_text||'</tdb_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<update_finance_line>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_update_finance_line);
    l_text:=l_text||'</update_finance_line>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tfl_object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_tfl_object_version_number);
    l_text:=l_text||'</tfl_object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<finance_header_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_finance_header_id);
    l_text:=l_text||'</finance_header_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<currency_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_currency_code);
    l_text:=l_text||'</currency_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<standard_amount>';
    l_text:=l_text||fnd_number.number_to_canonical(p_standard_amount);
    l_text:=l_text||'</standard_amount>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<unitary_amount>';
    l_text:=l_text||fnd_number.number_to_canonical(p_unitary_amount);
    l_text:=l_text||'</unitary_amount>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<money_amount>';
    l_text:=l_text||fnd_number.number_to_canonical(p_money_amount);
    l_text:=l_text||'</money_amount>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<booking_deal_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_booking_deal_id);
    l_text:=l_text||'</booking_deal_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<booking_deal_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_booking_deal_type);
    l_text:=l_text||'</booking_deal_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<finance_line_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_finance_line_id);
    l_text:=l_text||'</finance_line_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<enrollment_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_enrollment_type);
    l_text:=l_text||'</enrollment_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<organization_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_organization_id);
    l_text:=l_text||'</organization_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<sponsor_person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_sponsor_person_id);
    l_text:=l_text||'</sponsor_person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<sponsor_assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_sponsor_assignment_id);
    l_text:=l_text||'</sponsor_assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_address_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_address_id);
    l_text:=l_text||'</person_address_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<delegate_assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_delegate_assignment_id);
    l_text:=l_text||'</delegate_assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<delegate_contact_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_delegate_contact_id);
    l_text:=l_text||'</delegate_contact_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<delegate_contact_email>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_delegate_contact_email);
    l_text:=l_text||'</delegate_contact_email>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<third_party_email>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_third_party_email);
    l_text:=l_text||'</third_party_email>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_address_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_person_address_type);
    l_text:=l_text||'</person_address_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<line_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_line_id);
    l_text:=l_text||'</line_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_org_id);
    l_text:=l_text||'</org_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<daemon_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_daemon_flag);
    l_text:=l_text||'</daemon_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<daemon_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_daemon_type);
    l_text:=l_text||'</daemon_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<old_event_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_old_event_id);
    l_text:=l_text||'</old_event_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<quote_line_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_quote_line_id);
    l_text:=l_text||'</quote_line_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<interface_source>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_interface_source);
    l_text:=l_text||'</interface_source>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<total_training_time>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_total_training_time);
    l_text:=l_text||'</total_training_time>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<content_player_status>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_content_player_status);
    l_text:=l_text||'</content_player_status>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<score>';
    l_text:=l_text||fnd_number.number_to_canonical(p_score);
    l_text:=l_text||'</score>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<completed_content>';
    l_text:=l_text||fnd_number.number_to_canonical(p_completed_content);
    l_text:=l_text||'</completed_content>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<total_content>';
    l_text:=l_text||fnd_number.number_to_canonical(p_total_content);
    l_text:=l_text||'</total_content>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<booking_justification_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_booking_justification_id);
    l_text:=l_text||'</booking_justification_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<is_history_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_is_history_flag);
    l_text:=l_text||'</is_history_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</delegate_booking>';
    --
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    -- raise the event with the event data
    wf_event.raise(p_event_name=>l_event_name
                  ,p_event_key=>l_event_key
                  ,p_event_data=>l_event_data);
  elsif (l_message='KEY') then
    hr_utility.set_location(l_proc,30);
    -- get a key for the event
    open get_seq;
    fetch get_seq into l_event_key;
    close get_seq;
    -- this is a key event, so just raise the event
    -- without the event data
    wf_event.raise(p_event_name=>l_event_name
                  ,p_event_key=>l_event_key);
  elsif (l_message='NONE') then
    hr_utility.set_location(l_proc,40);
    -- no event is required, so do nothing
    null;
  end if;
    hr_utility.set_location('Leaving: '||l_proc,50);
end update_delegate_booking_a;
end ota_delegate_booking_be2;

/
