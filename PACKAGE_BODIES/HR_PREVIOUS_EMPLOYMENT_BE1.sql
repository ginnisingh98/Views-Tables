--------------------------------------------------------
--  DDL for Package Body HR_PREVIOUS_EMPLOYMENT_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PREVIOUS_EMPLOYMENT_BE1" as 
--Code generated on 29/08/2013 10:00:55
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_previous_employer_a (
p_effective_date               date,
p_previous_employer_id         number,
p_business_group_id            number,
p_person_id                    number,
p_party_id                     number,
p_start_date                   date,
p_end_date                     date,
p_period_years                 number,
p_period_months                number,
p_period_days                  number,
p_employer_name                varchar2,
p_employer_country             varchar2,
p_employer_address             varchar2,
p_employer_type                varchar2,
p_employer_subtype             varchar2,
p_description                  varchar2,
p_all_assignments              varchar2,
p_pem_attribute_category       varchar2,
p_pem_attribute1               varchar2,
p_pem_attribute2               varchar2,
p_pem_attribute3               varchar2,
p_pem_attribute4               varchar2,
p_pem_attribute5               varchar2,
p_pem_attribute6               varchar2,
p_pem_attribute7               varchar2,
p_pem_attribute8               varchar2,
p_pem_attribute9               varchar2,
p_pem_attribute10              varchar2,
p_pem_attribute11              varchar2,
p_pem_attribute12              varchar2,
p_pem_attribute13              varchar2,
p_pem_attribute14              varchar2,
p_pem_attribute15              varchar2,
p_pem_attribute16              varchar2,
p_pem_attribute17              varchar2,
p_pem_attribute18              varchar2,
p_pem_attribute19              varchar2,
p_pem_attribute20              varchar2,
p_pem_attribute21              varchar2,
p_pem_attribute22              varchar2,
p_pem_attribute23              varchar2,
p_pem_attribute24              varchar2,
p_pem_attribute25              varchar2,
p_pem_attribute26              varchar2,
p_pem_attribute27              varchar2,
p_pem_attribute28              varchar2,
p_pem_attribute29              varchar2,
p_pem_attribute30              varchar2,
p_pem_information_category     varchar2,
p_pem_information1             varchar2,
p_pem_information2             varchar2,
p_pem_information3             varchar2,
p_pem_information4             varchar2,
p_pem_information5             varchar2,
p_pem_information6             varchar2,
p_pem_information7             varchar2,
p_pem_information8             varchar2,
p_pem_information9             varchar2,
p_pem_information10            varchar2,
p_pem_information11            varchar2,
p_pem_information12            varchar2,
p_pem_information13            varchar2,
p_pem_information14            varchar2,
p_pem_information15            varchar2,
p_pem_information16            varchar2,
p_pem_information17            varchar2,
p_pem_information18            varchar2,
p_pem_information19            varchar2,
p_pem_information20            varchar2,
p_pem_information21            varchar2,
p_pem_information22            varchar2,
p_pem_information23            varchar2,
p_pem_information24            varchar2,
p_pem_information25            varchar2,
p_pem_information26            varchar2,
p_pem_information27            varchar2,
p_pem_information28            varchar2,
p_pem_information29            varchar2,
p_pem_information30            varchar2,
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
  l_proc varchar2(72):='  hr_previous_employment_be1.create_previous_employer_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.previous_employment.create_previous_employer';
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
    l_text:='<previous_employer_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_previous_employer_id);
    l_text:=l_text||'</previous_employer_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<party_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_party_id);
    l_text:=l_text||'</party_id>';
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
    l_text:='<employer_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employer_name);
    l_text:=l_text||'</employer_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<employer_country>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employer_country);
    l_text:=l_text||'</employer_country>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<employer_address>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employer_address);
    l_text:=l_text||'</employer_address>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<employer_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employer_type);
    l_text:=l_text||'</employer_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<employer_subtype>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employer_subtype);
    l_text:=l_text||'</employer_subtype>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_description);
    l_text:=l_text||'</description>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<all_assignments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_all_assignments);
    l_text:=l_text||'</all_assignments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute_category);
    l_text:=l_text||'</pem_attribute_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute1);
    l_text:=l_text||'</pem_attribute1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute2);
    l_text:=l_text||'</pem_attribute2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute3);
    l_text:=l_text||'</pem_attribute3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute4);
    l_text:=l_text||'</pem_attribute4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute5);
    l_text:=l_text||'</pem_attribute5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute6);
    l_text:=l_text||'</pem_attribute6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute7);
    l_text:=l_text||'</pem_attribute7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute8);
    l_text:=l_text||'</pem_attribute8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute9);
    l_text:=l_text||'</pem_attribute9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute10);
    l_text:=l_text||'</pem_attribute10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute11);
    l_text:=l_text||'</pem_attribute11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute12);
    l_text:=l_text||'</pem_attribute12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute13);
    l_text:=l_text||'</pem_attribute13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute14);
    l_text:=l_text||'</pem_attribute14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute15);
    l_text:=l_text||'</pem_attribute15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute16);
    l_text:=l_text||'</pem_attribute16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute17);
    l_text:=l_text||'</pem_attribute17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute18);
    l_text:=l_text||'</pem_attribute18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute19);
    l_text:=l_text||'</pem_attribute19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute20);
    l_text:=l_text||'</pem_attribute20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute21);
    l_text:=l_text||'</pem_attribute21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute22);
    l_text:=l_text||'</pem_attribute22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute23);
    l_text:=l_text||'</pem_attribute23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute24);
    l_text:=l_text||'</pem_attribute24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute25);
    l_text:=l_text||'</pem_attribute25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute26);
    l_text:=l_text||'</pem_attribute26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute27);
    l_text:=l_text||'</pem_attribute27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute28);
    l_text:=l_text||'</pem_attribute28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute29);
    l_text:=l_text||'</pem_attribute29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_attribute30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_attribute30);
    l_text:=l_text||'</pem_attribute30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information_category);
    l_text:=l_text||'</pem_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information1);
    l_text:=l_text||'</pem_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information2);
    l_text:=l_text||'</pem_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information3);
    l_text:=l_text||'</pem_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information4);
    l_text:=l_text||'</pem_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information5);
    l_text:=l_text||'</pem_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information6);
    l_text:=l_text||'</pem_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information7);
    l_text:=l_text||'</pem_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information8);
    l_text:=l_text||'</pem_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information9);
    l_text:=l_text||'</pem_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information10);
    l_text:=l_text||'</pem_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information11);
    l_text:=l_text||'</pem_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information12);
    l_text:=l_text||'</pem_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information13);
    l_text:=l_text||'</pem_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information14);
    l_text:=l_text||'</pem_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information15);
    l_text:=l_text||'</pem_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information16);
    l_text:=l_text||'</pem_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information17);
    l_text:=l_text||'</pem_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information18);
    l_text:=l_text||'</pem_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information19);
    l_text:=l_text||'</pem_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information20);
    l_text:=l_text||'</pem_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information21);
    l_text:=l_text||'</pem_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information22);
    l_text:=l_text||'</pem_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information23);
    l_text:=l_text||'</pem_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information24);
    l_text:=l_text||'</pem_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information25);
    l_text:=l_text||'</pem_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information26);
    l_text:=l_text||'</pem_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information27);
    l_text:=l_text||'</pem_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information28);
    l_text:=l_text||'</pem_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information29);
    l_text:=l_text||'</pem_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pem_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pem_information30);
    l_text:=l_text||'</pem_information30>';
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
end create_previous_employer_a;
end hr_previous_employment_be1;

/
