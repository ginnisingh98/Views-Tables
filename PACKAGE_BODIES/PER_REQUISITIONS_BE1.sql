--------------------------------------------------------
--  DDL for Package Body PER_REQUISITIONS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REQUISITIONS_BE1" as 
--Code generated on 04/01/2007 09:33:07
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure create_requisition_a (
p_business_group_id            number,
p_date_from                    date,
p_name                         varchar2,
p_person_id                    number,
p_comments                     varchar2,
p_date_to                      date,
p_description                  varchar2,
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
p_attribute21                  varchar2,
p_attribute22                  varchar2,
p_attribute23                  varchar2,
p_attribute24                  varchar2,
p_attribute25                  varchar2,
p_attribute26                  varchar2,
p_attribute27                  varchar2,
p_attribute28                  varchar2,
p_attribute29                  varchar2,
p_attribute30                  varchar2,
p_requisition_id               number,
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
  l_proc varchar2(72):='  per_requisitions_be1.create_requisition_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.requisitions.create_requisition';
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
    l_text:='<requisitions>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_from>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_from);
    l_text:=l_text||'</date_from>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_name);
    l_text:=l_text||'</name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_to>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_to);
    l_text:=l_text||'</date_to>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_description);
    l_text:=l_text||'</description>';
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
    l_text:='<attribute21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute21);
    l_text:=l_text||'</attribute21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute22);
    l_text:=l_text||'</attribute22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute23);
    l_text:=l_text||'</attribute23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute24);
    l_text:=l_text||'</attribute24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute25);
    l_text:=l_text||'</attribute25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute26);
    l_text:=l_text||'</attribute26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute27);
    l_text:=l_text||'</attribute27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute28);
    l_text:=l_text||'</attribute28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute29);
    l_text:=l_text||'</attribute29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute30);
    l_text:=l_text||'</attribute30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<requisition_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_requisition_id);
    l_text:=l_text||'</requisition_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</requisitions>';
    --
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    -- raise the event with the event data
    wf_event.raise(p_event_name=>l_event_name
                  ,p_event_key=>l_event_key
                  ,p_event_data=>l_event_data);
    --
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
    --
  elsif (l_message='NONE') then
    hr_utility.set_location(l_proc,40);
    -- no event is required, so do nothing
    null;
  end if;
    hr_utility.set_location('Leaving: '||l_proc,50);
end create_requisition_a;
end per_requisitions_be1;

/
