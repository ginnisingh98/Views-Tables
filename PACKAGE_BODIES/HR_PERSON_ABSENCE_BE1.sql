--------------------------------------------------------
--  DDL for Package Body HR_PERSON_ABSENCE_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_ABSENCE_BE1" as 
--Code generated on 30/08/2013 11:36:17
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_person_absence_a (
p_effective_date               date,
p_person_id                    number,
p_business_group_id            number,
p_absence_attendance_type_id   number,
p_abs_attendance_reason_id     number,
p_comments                     long,
p_date_notification            date,
p_date_projected_start         date,
p_time_projected_start         varchar2,
p_date_projected_end           date,
p_time_projected_end           varchar2,
p_date_start                   date,
p_time_start                   varchar2,
p_date_end                     date,
p_time_end                     varchar2,
p_absence_days                 number,
p_absence_hours                number,
p_authorising_person_id        number,
p_replacement_person_id        number,
p_attribute_category           varchar2,
p_attribute1                   varchar2,
p_attribute2                   varchar2,
p_attribute3                   varchar2,
p_attribute4                   varchar2,
p_attribute5                   varchar2,
p_attribute6                   varchar2,
p_attribute7                   varchar2,
p_attribute8                   varchar2,
p_attribute9                   varchar2,
p_attribute10                  varchar2,
p_attribute11                  varchar2,
p_attribute12                  varchar2,
p_attribute13                  varchar2,
p_attribute14                  varchar2,
p_attribute15                  varchar2,
p_attribute16                  varchar2,
p_attribute17                  varchar2,
p_attribute18                  varchar2,
p_attribute19                  varchar2,
p_attribute20                  varchar2,
p_occurrence                   number,
p_period_of_incapacity_id      number,
p_ssp1_issued                  varchar2,
p_maternity_id                 number,
p_sickness_start_date          date,
p_sickness_end_date            date,
p_pregnancy_related_illness    varchar2,
p_reason_for_notification_dela varchar2,
p_accept_late_notification_fla varchar2,
p_linked_absence_id            number,
p_batch_id                     number,
p_create_element_entry         boolean,
p_abs_information_category     varchar2,
p_abs_information1             varchar2,
p_abs_information2             varchar2,
p_abs_information3             varchar2,
p_abs_information4             varchar2,
p_abs_information5             varchar2,
p_abs_information6             varchar2,
p_abs_information7             varchar2,
p_abs_information8             varchar2,
p_abs_information9             varchar2,
p_abs_information10            varchar2,
p_abs_information11            varchar2,
p_abs_information12            varchar2,
p_abs_information13            varchar2,
p_abs_information14            varchar2,
p_abs_information15            varchar2,
p_abs_information16            varchar2,
p_abs_information17            varchar2,
p_abs_information18            varchar2,
p_abs_information19            varchar2,
p_abs_information20            varchar2,
p_abs_information21            varchar2,
p_abs_information22            varchar2,
p_abs_information23            varchar2,
p_abs_information24            varchar2,
p_abs_information25            varchar2,
p_abs_information26            varchar2,
p_abs_information27            varchar2,
p_abs_information28            varchar2,
p_abs_information29            varchar2,
p_abs_information30            varchar2,
p_absence_case_id              number,
p_absence_attendance_id        number,
p_object_version_number        number,
p_dur_dys_less_warning         boolean,
p_dur_hrs_less_warning         boolean,
p_exceeds_pto_entit_warning    boolean,
p_exceeds_run_total_warning    boolean,
p_abs_overlap_warning          boolean,
p_abs_day_after_warning        boolean,
p_dur_overwritten_warning      boolean) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_person_absence_be1.create_person_absence_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.person_absence.create_person_absence';
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
    l_text:='<person_absence>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<absence_attendance_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_absence_attendance_type_id);
    l_text:=l_text||'</absence_attendance_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_attendance_reason_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_abs_attendance_reason_id);
    l_text:=l_text||'</abs_attendance_reason_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_notification>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_notification);
    l_text:=l_text||'</date_notification>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_projected_start>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_projected_start);
    l_text:=l_text||'</date_projected_start>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<time_projected_start>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_time_projected_start);
    l_text:=l_text||'</time_projected_start>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_projected_end>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_projected_end);
    l_text:=l_text||'</date_projected_end>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<time_projected_end>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_time_projected_end);
    l_text:=l_text||'</time_projected_end>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_start>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_start);
    l_text:=l_text||'</date_start>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<time_start>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_time_start);
    l_text:=l_text||'</time_start>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_end>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_end);
    l_text:=l_text||'</date_end>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<time_end>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_time_end);
    l_text:=l_text||'</time_end>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<absence_days>';
    l_text:=l_text||fnd_number.number_to_canonical(p_absence_days);
    l_text:=l_text||'</absence_days>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<absence_hours>';
    l_text:=l_text||fnd_number.number_to_canonical(p_absence_hours);
    l_text:=l_text||'</absence_hours>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<authorising_person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_authorising_person_id);
    l_text:=l_text||'</authorising_person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<replacement_person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_replacement_person_id);
    l_text:=l_text||'</replacement_person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute_category);
    l_text:=l_text||'</attribute_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute1);
    l_text:=l_text||'</attribute1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute2);
    l_text:=l_text||'</attribute2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute3);
    l_text:=l_text||'</attribute3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute4);
    l_text:=l_text||'</attribute4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute5);
    l_text:=l_text||'</attribute5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute6);
    l_text:=l_text||'</attribute6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute7);
    l_text:=l_text||'</attribute7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute8);
    l_text:=l_text||'</attribute8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute9);
    l_text:=l_text||'</attribute9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute10);
    l_text:=l_text||'</attribute10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute11);
    l_text:=l_text||'</attribute11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute12);
    l_text:=l_text||'</attribute12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute13);
    l_text:=l_text||'</attribute13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute14);
    l_text:=l_text||'</attribute14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute15);
    l_text:=l_text||'</attribute15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute16);
    l_text:=l_text||'</attribute16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute17);
    l_text:=l_text||'</attribute17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute18);
    l_text:=l_text||'</attribute18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute19);
    l_text:=l_text||'</attribute19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute20);
    l_text:=l_text||'</attribute20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<occurrence>';
    l_text:=l_text||fnd_number.number_to_canonical(p_occurrence);
    l_text:=l_text||'</occurrence>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<period_of_incapacity_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_period_of_incapacity_id);
    l_text:=l_text||'</period_of_incapacity_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ssp1_issued>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ssp1_issued);
    l_text:=l_text||'</ssp1_issued>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<maternity_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_maternity_id);
    l_text:=l_text||'</maternity_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<sickness_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_sickness_start_date);
    l_text:=l_text||'</sickness_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<sickness_end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_sickness_end_date);
    l_text:=l_text||'</sickness_end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pregnancy_related_illness>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pregnancy_related_illness);
    l_text:=l_text||'</pregnancy_related_illness>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<reason_for_notification_dela>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_reason_for_notification_dela);
    l_text:=l_text||'</reason_for_notification_dela>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<accept_late_notification_fla>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_accept_late_notification_fla);
    l_text:=l_text||'</accept_late_notification_fla>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<linked_absence_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_linked_absence_id);
    l_text:=l_text||'</linked_absence_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<batch_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_batch_id);
    l_text:=l_text||'</batch_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<create_element_entry>';
if(P_CREATE_ELEMENT_ENTRY) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</create_element_entry>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information_category);
    l_text:=l_text||'</abs_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information1);
    l_text:=l_text||'</abs_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information2);
    l_text:=l_text||'</abs_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information3);
    l_text:=l_text||'</abs_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information4);
    l_text:=l_text||'</abs_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information5);
    l_text:=l_text||'</abs_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information6);
    l_text:=l_text||'</abs_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information7);
    l_text:=l_text||'</abs_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information8);
    l_text:=l_text||'</abs_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information9);
    l_text:=l_text||'</abs_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information10);
    l_text:=l_text||'</abs_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information11);
    l_text:=l_text||'</abs_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information12);
    l_text:=l_text||'</abs_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information13);
    l_text:=l_text||'</abs_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information14);
    l_text:=l_text||'</abs_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information15);
    l_text:=l_text||'</abs_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information16);
    l_text:=l_text||'</abs_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information17);
    l_text:=l_text||'</abs_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information18);
    l_text:=l_text||'</abs_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information19);
    l_text:=l_text||'</abs_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information20);
    l_text:=l_text||'</abs_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information21);
    l_text:=l_text||'</abs_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information22);
    l_text:=l_text||'</abs_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information23);
    l_text:=l_text||'</abs_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information24);
    l_text:=l_text||'</abs_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information25);
    l_text:=l_text||'</abs_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information26);
    l_text:=l_text||'</abs_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information27);
    l_text:=l_text||'</abs_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information28);
    l_text:=l_text||'</abs_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information29);
    l_text:=l_text||'</abs_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_abs_information30);
    l_text:=l_text||'</abs_information30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<absence_case_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_absence_case_id);
    l_text:=l_text||'</absence_case_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<absence_attendance_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_absence_attendance_id);
    l_text:=l_text||'</absence_attendance_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dur_dys_less_warning>';
if(P_DUR_DYS_LESS_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</dur_dys_less_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dur_hrs_less_warning>';
if(P_DUR_HRS_LESS_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</dur_hrs_less_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<exceeds_pto_entit_warning>';
if(P_EXCEEDS_PTO_ENTIT_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</exceeds_pto_entit_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<exceeds_run_total_warning>';
if(P_EXCEEDS_RUN_TOTAL_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</exceeds_run_total_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_overlap_warning>';
if(P_ABS_OVERLAP_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</abs_overlap_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<abs_day_after_warning>';
if(P_ABS_DAY_AFTER_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</abs_day_after_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dur_overwritten_warning>';
if(P_DUR_OVERWRITTEN_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</dur_overwritten_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</person_absence>';
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
end create_person_absence_a;
end hr_person_absence_be1;

/
