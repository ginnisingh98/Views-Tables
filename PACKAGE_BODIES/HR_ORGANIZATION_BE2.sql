--------------------------------------------------------
--  DDL for Package Body HR_ORGANIZATION_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORGANIZATION_BE2" as 
--Code generated on 30/08/2013 11:36:17
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_org_information_a (
p_effective_date               date,
p_org_info_type_code           varchar2,
p_org_information1             varchar2,
p_org_information2             varchar2,
p_org_information3             varchar2,
p_org_information4             varchar2,
p_org_information5             varchar2,
p_org_information6             varchar2,
p_org_information7             varchar2,
p_org_information8             varchar2,
p_org_information9             varchar2,
p_org_information10            varchar2,
p_org_information11            varchar2,
p_org_information12            varchar2,
p_org_information13            varchar2,
p_org_information14            varchar2,
p_org_information15            varchar2,
p_org_information16            varchar2,
p_org_information17            varchar2,
p_org_information18            varchar2,
p_org_information19            varchar2,
p_org_information20            varchar2,
p_org_information_id           number,
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
  l_proc varchar2(72):='  hr_organization_be2.update_org_information_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.organization.update_org_information';
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
    l_text:='<organization>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_info_type_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_info_type_code);
    l_text:=l_text||'</org_info_type_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information1);
    l_text:=l_text||'</org_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information2);
    l_text:=l_text||'</org_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information3);
    l_text:=l_text||'</org_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information4);
    l_text:=l_text||'</org_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information5);
    l_text:=l_text||'</org_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information6);
    l_text:=l_text||'</org_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information7);
    l_text:=l_text||'</org_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information8);
    l_text:=l_text||'</org_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information9);
    l_text:=l_text||'</org_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information10);
    l_text:=l_text||'</org_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information11);
    l_text:=l_text||'</org_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information12);
    l_text:=l_text||'</org_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information13);
    l_text:=l_text||'</org_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information14);
    l_text:=l_text||'</org_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information15);
    l_text:=l_text||'</org_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information16);
    l_text:=l_text||'</org_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information17);
    l_text:=l_text||'</org_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information18);
    l_text:=l_text||'</org_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information19);
    l_text:=l_text||'</org_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_information20);
    l_text:=l_text||'</org_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_org_information_id);
    l_text:=l_text||'</org_information_id>';
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
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</organization>';
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
end update_org_information_a;
end hr_organization_be2;

/
