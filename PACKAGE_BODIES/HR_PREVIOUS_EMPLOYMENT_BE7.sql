--------------------------------------------------------
--  DDL for Package Body HR_PREVIOUS_EMPLOYMENT_BE7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PREVIOUS_EMPLOYMENT_BE7" as 
--Code generated on 29/08/2013 10:00:58
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_previous_job_usage_a (
p_assignment_id                number,
p_previous_employer_id         number,
p_previous_job_id              number,
p_start_date                   date,
p_end_date                     date,
p_period_years                 number,
p_period_months                number,
p_period_days                  number,
p_pju_attribute_category       varchar2,
p_pju_attribute1               varchar2,
p_pju_attribute2               varchar2,
p_pju_attribute3               varchar2,
p_pju_attribute4               varchar2,
p_pju_attribute5               varchar2,
p_pju_attribute6               varchar2,
p_pju_attribute7               varchar2,
p_pju_attribute8               varchar2,
p_pju_attribute9               varchar2,
p_pju_attribute10              varchar2,
p_pju_attribute11              varchar2,
p_pju_attribute12              varchar2,
p_pju_attribute13              varchar2,
p_pju_attribute14              varchar2,
p_pju_attribute15              varchar2,
p_pju_attribute16              varchar2,
p_pju_attribute17              varchar2,
p_pju_attribute18              varchar2,
p_pju_attribute19              varchar2,
p_pju_attribute20              varchar2,
p_pju_information_category     varchar2,
p_pju_information1             varchar2,
p_pju_information2             varchar2,
p_pju_information3             varchar2,
p_pju_information4             varchar2,
p_pju_information5             varchar2,
p_pju_information6             varchar2,
p_pju_information7             varchar2,
p_pju_information8             varchar2,
p_pju_information9             varchar2,
p_pju_information10            varchar2,
p_pju_information11            varchar2,
p_pju_information12            varchar2,
p_pju_information13            varchar2,
p_pju_information14            varchar2,
p_pju_information15            varchar2,
p_pju_information16            varchar2,
p_pju_information17            varchar2,
p_pju_information18            varchar2,
p_pju_information19            varchar2,
p_pju_information20            varchar2,
p_previous_job_usage_id        number,
p_object_version_number        number) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_previous_employment_be7.create_previous_job_usage_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.previous_employment.create_previous_job_usage';
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
    l_text:='<previous_employment>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_id);
    l_text:=l_text||'</assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<previous_employer_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_previous_employer_id);
    l_text:=l_text||'</previous_employer_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<previous_job_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_previous_job_id);
    l_text:=l_text||'</previous_job_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_start_date);
    l_text:=l_text||'</start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_end_date);
    l_text:=l_text||'</end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<period_years>';
    l_text:=l_text||fnd_number.number_to_canonical(p_period_years);
    l_text:=l_text||'</period_years>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<period_months>';
    l_text:=l_text||fnd_number.number_to_canonical(p_period_months);
    l_text:=l_text||'</period_months>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<period_days>';
    l_text:=l_text||fnd_number.number_to_canonical(p_period_days);
    l_text:=l_text||'</period_days>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute_category);
    l_text:=l_text||'</pju_attribute_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute1);
    l_text:=l_text||'</pju_attribute1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute2);
    l_text:=l_text||'</pju_attribute2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute3);
    l_text:=l_text||'</pju_attribute3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute4);
    l_text:=l_text||'</pju_attribute4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute5);
    l_text:=l_text||'</pju_attribute5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute6);
    l_text:=l_text||'</pju_attribute6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute7);
    l_text:=l_text||'</pju_attribute7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute8);
    l_text:=l_text||'</pju_attribute8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute9);
    l_text:=l_text||'</pju_attribute9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute10);
    l_text:=l_text||'</pju_attribute10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute11);
    l_text:=l_text||'</pju_attribute11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute12);
    l_text:=l_text||'</pju_attribute12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute13);
    l_text:=l_text||'</pju_attribute13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute14);
    l_text:=l_text||'</pju_attribute14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute15);
    l_text:=l_text||'</pju_attribute15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute16);
    l_text:=l_text||'</pju_attribute16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute17);
    l_text:=l_text||'</pju_attribute17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute18);
    l_text:=l_text||'</pju_attribute18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute19);
    l_text:=l_text||'</pju_attribute19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_attribute20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_attribute20);
    l_text:=l_text||'</pju_attribute20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information_category);
    l_text:=l_text||'</pju_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information1);
    l_text:=l_text||'</pju_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information2);
    l_text:=l_text||'</pju_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information3);
    l_text:=l_text||'</pju_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information4);
    l_text:=l_text||'</pju_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information5);
    l_text:=l_text||'</pju_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information6);
    l_text:=l_text||'</pju_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information7);
    l_text:=l_text||'</pju_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information8);
    l_text:=l_text||'</pju_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information9);
    l_text:=l_text||'</pju_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information10);
    l_text:=l_text||'</pju_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information11);
    l_text:=l_text||'</pju_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information12);
    l_text:=l_text||'</pju_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information13);
    l_text:=l_text||'</pju_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information14);
    l_text:=l_text||'</pju_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information15);
    l_text:=l_text||'</pju_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information16);
    l_text:=l_text||'</pju_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information17);
    l_text:=l_text||'</pju_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information18);
    l_text:=l_text||'</pju_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information19);
    l_text:=l_text||'</pju_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pju_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pju_information20);
    l_text:=l_text||'</pju_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<previous_job_usage_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_previous_job_usage_id);
    l_text:=l_text||'</previous_job_usage_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</previous_employment>';
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
end create_previous_job_usage_a;
end hr_previous_employment_be7;

/
