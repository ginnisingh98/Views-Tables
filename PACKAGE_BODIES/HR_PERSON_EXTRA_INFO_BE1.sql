--------------------------------------------------------
--  DDL for Package Body HR_PERSON_EXTRA_INFO_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_EXTRA_INFO_BE1" as 
--Code generated on 29/08/2013 10:00:55
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_person_extra_info_a (
p_person_extra_info_id         number,
p_person_id                    number,
p_information_type             varchar2,
p_pei_attribute_category       varchar2,
p_pei_attribute1               varchar2,
p_pei_attribute2               varchar2,
p_pei_attribute3               varchar2,
p_pei_attribute4               varchar2,
p_pei_attribute5               varchar2,
p_pei_attribute6               varchar2,
p_pei_attribute7               varchar2,
p_pei_attribute8               varchar2,
p_pei_attribute9               varchar2,
p_pei_attribute10              varchar2,
p_pei_attribute11              varchar2,
p_pei_attribute12              varchar2,
p_pei_attribute13              varchar2,
p_pei_attribute14              varchar2,
p_pei_attribute15              varchar2,
p_pei_attribute16              varchar2,
p_pei_attribute17              varchar2,
p_pei_attribute18              varchar2,
p_pei_attribute19              varchar2,
p_pei_attribute20              varchar2,
p_pei_information_category     varchar2,
p_pei_information1             varchar2,
p_pei_information2             varchar2,
p_pei_information3             varchar2,
p_pei_information4             varchar2,
p_pei_information5             varchar2,
p_pei_information6             varchar2,
p_pei_information7             varchar2,
p_pei_information8             varchar2,
p_pei_information9             varchar2,
p_pei_information10            varchar2,
p_pei_information11            varchar2,
p_pei_information12            varchar2,
p_pei_information13            varchar2,
p_pei_information14            varchar2,
p_pei_information15            varchar2,
p_pei_information16            varchar2,
p_pei_information17            varchar2,
p_pei_information18            varchar2,
p_pei_information19            varchar2,
p_pei_information20            varchar2,
p_pei_information21            varchar2,
p_pei_information22            varchar2,
p_pei_information23            varchar2,
p_pei_information24            varchar2,
p_pei_information25            varchar2,
p_pei_information26            varchar2,
p_pei_information27            varchar2,
p_pei_information28            varchar2,
p_pei_information29            varchar2,
p_pei_information30            varchar2,
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
  l_proc varchar2(72):='  hr_person_extra_info_be1.create_person_extra_info_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.person_extra_info.create_person_extra_info';
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
    l_text:='<person_extra_info>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<person_extra_info_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_extra_info_id);
    l_text:=l_text||'</person_extra_info_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information_type);
    l_text:=l_text||'</information_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute_category);
    l_text:=l_text||'</pei_attribute_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute1);
    l_text:=l_text||'</pei_attribute1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute2);
    l_text:=l_text||'</pei_attribute2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute3);
    l_text:=l_text||'</pei_attribute3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute4);
    l_text:=l_text||'</pei_attribute4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute5);
    l_text:=l_text||'</pei_attribute5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute6);
    l_text:=l_text||'</pei_attribute6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute7);
    l_text:=l_text||'</pei_attribute7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute8);
    l_text:=l_text||'</pei_attribute8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute9);
    l_text:=l_text||'</pei_attribute9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute10);
    l_text:=l_text||'</pei_attribute10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute11);
    l_text:=l_text||'</pei_attribute11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute12);
    l_text:=l_text||'</pei_attribute12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute13);
    l_text:=l_text||'</pei_attribute13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute14);
    l_text:=l_text||'</pei_attribute14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute15);
    l_text:=l_text||'</pei_attribute15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute16);
    l_text:=l_text||'</pei_attribute16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute17);
    l_text:=l_text||'</pei_attribute17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute18);
    l_text:=l_text||'</pei_attribute18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute19);
    l_text:=l_text||'</pei_attribute19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_attribute20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_attribute20);
    l_text:=l_text||'</pei_attribute20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information_category);
    l_text:=l_text||'</pei_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information1);
    l_text:=l_text||'</pei_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information2);
    l_text:=l_text||'</pei_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information3);
    l_text:=l_text||'</pei_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information4);
    l_text:=l_text||'</pei_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information5);
    l_text:=l_text||'</pei_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information6);
    l_text:=l_text||'</pei_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information7);
    l_text:=l_text||'</pei_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information8);
    l_text:=l_text||'</pei_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information9);
    l_text:=l_text||'</pei_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information10);
    l_text:=l_text||'</pei_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information11);
    l_text:=l_text||'</pei_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information12);
    l_text:=l_text||'</pei_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information13);
    l_text:=l_text||'</pei_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information14);
    l_text:=l_text||'</pei_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information15);
    l_text:=l_text||'</pei_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information16);
    l_text:=l_text||'</pei_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information17);
    l_text:=l_text||'</pei_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information18);
    l_text:=l_text||'</pei_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information19);
    l_text:=l_text||'</pei_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information20);
    l_text:=l_text||'</pei_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information21);
    l_text:=l_text||'</pei_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information22);
    l_text:=l_text||'</pei_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information23);
    l_text:=l_text||'</pei_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information24);
    l_text:=l_text||'</pei_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information25);
    l_text:=l_text||'</pei_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information26);
    l_text:=l_text||'</pei_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information27);
    l_text:=l_text||'</pei_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information28);
    l_text:=l_text||'</pei_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information29);
    l_text:=l_text||'</pei_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pei_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pei_information30);
    l_text:=l_text||'</pei_information30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</person_extra_info>';
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
end create_person_extra_info_a;
end hr_person_extra_info_be1;

/
