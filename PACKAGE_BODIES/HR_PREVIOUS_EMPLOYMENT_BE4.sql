--------------------------------------------------------
--  DDL for Package Body HR_PREVIOUS_EMPLOYMENT_BE4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PREVIOUS_EMPLOYMENT_BE4" as 
--Code generated on 29/08/2013 10:00:57
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_previous_job_a (
p_effective_date               date,
p_previous_job_id              number,
p_previous_employer_id         number,
p_start_date                   date,
p_end_date                     date,
p_period_years                 number,
p_period_months                number,
p_period_days                  number,
p_job_name                     varchar2,
p_employment_category          varchar2,
p_description                  varchar2,
p_all_assignments              varchar2,
p_pjo_attribute_category       varchar2,
p_pjo_attribute1               varchar2,
p_pjo_attribute2               varchar2,
p_pjo_attribute3               varchar2,
p_pjo_attribute4               varchar2,
p_pjo_attribute5               varchar2,
p_pjo_attribute6               varchar2,
p_pjo_attribute7               varchar2,
p_pjo_attribute8               varchar2,
p_pjo_attribute9               varchar2,
p_pjo_attribute10              varchar2,
p_pjo_attribute11              varchar2,
p_pjo_attribute12              varchar2,
p_pjo_attribute13              varchar2,
p_pjo_attribute14              varchar2,
p_pjo_attribute15              varchar2,
p_pjo_attribute16              varchar2,
p_pjo_attribute17              varchar2,
p_pjo_attribute18              varchar2,
p_pjo_attribute19              varchar2,
p_pjo_attribute20              varchar2,
p_pjo_attribute21              varchar2,
p_pjo_attribute22              varchar2,
p_pjo_attribute23              varchar2,
p_pjo_attribute24              varchar2,
p_pjo_attribute25              varchar2,
p_pjo_attribute26              varchar2,
p_pjo_attribute27              varchar2,
p_pjo_attribute28              varchar2,
p_pjo_attribute29              varchar2,
p_pjo_attribute30              varchar2,
p_pjo_information_category     varchar2,
p_pjo_information1             varchar2,
p_pjo_information2             varchar2,
p_pjo_information3             varchar2,
p_pjo_information4             varchar2,
p_pjo_information5             varchar2,
p_pjo_information6             varchar2,
p_pjo_information7             varchar2,
p_pjo_information8             varchar2,
p_pjo_information9             varchar2,
p_pjo_information10            varchar2,
p_pjo_information11            varchar2,
p_pjo_information12            varchar2,
p_pjo_information13            varchar2,
p_pjo_information14            varchar2,
p_pjo_information15            varchar2,
p_pjo_information16            varchar2,
p_pjo_information17            varchar2,
p_pjo_information18            varchar2,
p_pjo_information19            varchar2,
p_pjo_information20            varchar2,
p_pjo_information21            varchar2,
p_pjo_information22            varchar2,
p_pjo_information23            varchar2,
p_pjo_information24            varchar2,
p_pjo_information25            varchar2,
p_pjo_information26            varchar2,
p_pjo_information27            varchar2,
p_pjo_information28            varchar2,
p_pjo_information29            varchar2,
p_pjo_information30            varchar2,
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
  l_proc varchar2(72):='  hr_previous_employment_be4.create_previous_job_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.previous_employment.create_previous_job';
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
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<previous_job_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_previous_job_id);
    l_text:=l_text||'</previous_job_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<previous_employer_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_previous_employer_id);
    l_text:=l_text||'</previous_employer_id>';
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
    l_text:='<job_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_job_name);
    l_text:=l_text||'</job_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<employment_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employment_category);
    l_text:=l_text||'</employment_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_description);
    l_text:=l_text||'</description>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<all_assignments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_all_assignments);
    l_text:=l_text||'</all_assignments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute_category);
    l_text:=l_text||'</pjo_attribute_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute1);
    l_text:=l_text||'</pjo_attribute1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute2);
    l_text:=l_text||'</pjo_attribute2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute3);
    l_text:=l_text||'</pjo_attribute3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute4);
    l_text:=l_text||'</pjo_attribute4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute5);
    l_text:=l_text||'</pjo_attribute5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute6);
    l_text:=l_text||'</pjo_attribute6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute7);
    l_text:=l_text||'</pjo_attribute7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute8);
    l_text:=l_text||'</pjo_attribute8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute9);
    l_text:=l_text||'</pjo_attribute9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute10);
    l_text:=l_text||'</pjo_attribute10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute11);
    l_text:=l_text||'</pjo_attribute11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute12);
    l_text:=l_text||'</pjo_attribute12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute13);
    l_text:=l_text||'</pjo_attribute13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute14);
    l_text:=l_text||'</pjo_attribute14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute15);
    l_text:=l_text||'</pjo_attribute15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute16);
    l_text:=l_text||'</pjo_attribute16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute17);
    l_text:=l_text||'</pjo_attribute17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute18);
    l_text:=l_text||'</pjo_attribute18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute19);
    l_text:=l_text||'</pjo_attribute19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute20);
    l_text:=l_text||'</pjo_attribute20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute21);
    l_text:=l_text||'</pjo_attribute21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute22);
    l_text:=l_text||'</pjo_attribute22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute23);
    l_text:=l_text||'</pjo_attribute23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute24);
    l_text:=l_text||'</pjo_attribute24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute25);
    l_text:=l_text||'</pjo_attribute25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute26);
    l_text:=l_text||'</pjo_attribute26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute27);
    l_text:=l_text||'</pjo_attribute27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute28);
    l_text:=l_text||'</pjo_attribute28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute29);
    l_text:=l_text||'</pjo_attribute29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_attribute30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_attribute30);
    l_text:=l_text||'</pjo_attribute30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information_category);
    l_text:=l_text||'</pjo_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information1);
    l_text:=l_text||'</pjo_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information2);
    l_text:=l_text||'</pjo_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information3);
    l_text:=l_text||'</pjo_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information4);
    l_text:=l_text||'</pjo_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information5);
    l_text:=l_text||'</pjo_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information6);
    l_text:=l_text||'</pjo_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information7);
    l_text:=l_text||'</pjo_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information8);
    l_text:=l_text||'</pjo_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information9);
    l_text:=l_text||'</pjo_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information10);
    l_text:=l_text||'</pjo_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information11);
    l_text:=l_text||'</pjo_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information12);
    l_text:=l_text||'</pjo_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information13);
    l_text:=l_text||'</pjo_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information14);
    l_text:=l_text||'</pjo_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information15);
    l_text:=l_text||'</pjo_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information16);
    l_text:=l_text||'</pjo_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information17);
    l_text:=l_text||'</pjo_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information18);
    l_text:=l_text||'</pjo_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information19);
    l_text:=l_text||'</pjo_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information20);
    l_text:=l_text||'</pjo_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information21);
    l_text:=l_text||'</pjo_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information22);
    l_text:=l_text||'</pjo_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information23);
    l_text:=l_text||'</pjo_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information24);
    l_text:=l_text||'</pjo_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information25);
    l_text:=l_text||'</pjo_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information26);
    l_text:=l_text||'</pjo_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information27);
    l_text:=l_text||'</pjo_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information28);
    l_text:=l_text||'</pjo_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information29);
    l_text:=l_text||'</pjo_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pjo_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pjo_information30);
    l_text:=l_text||'</pjo_information30>';
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
end create_previous_job_a;
end hr_previous_employment_be4;

/
