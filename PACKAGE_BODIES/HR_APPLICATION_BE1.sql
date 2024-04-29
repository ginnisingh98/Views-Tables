--------------------------------------------------------
--  DDL for Package Body HR_APPLICATION_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPLICATION_BE1" as 
--Code generated on 04/01/2007 09:31:33
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure update_apl_details_a (
p_application_id               number,
p_object_version_number        number,
p_effective_date               date,
p_comments                     varchar2,
p_current_employer             varchar2,
p_projected_hire_date          date,
p_termination_reason           varchar2,
p_appl_attribute_category      varchar2,
p_appl_attribute1              varchar2,
p_appl_attribute2              varchar2,
p_appl_attribute3              varchar2,
p_appl_attribute4              varchar2,
p_appl_attribute5              varchar2,
p_appl_attribute6              varchar2,
p_appl_attribute7              varchar2,
p_appl_attribute8              varchar2,
p_appl_attribute9              varchar2,
p_appl_attribute10             varchar2,
p_appl_attribute11             varchar2,
p_appl_attribute12             varchar2,
p_appl_attribute13             varchar2,
p_appl_attribute14             varchar2,
p_appl_attribute15             varchar2,
p_appl_attribute16             varchar2,
p_appl_attribute17             varchar2,
p_appl_attribute18             varchar2,
p_appl_attribute19             varchar2,
p_appl_attribute20             varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_application_be1.update_apl_details_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.application.update_apl_details';
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
    l_text:='<application>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<application_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_application_id);
    l_text:=l_text||'</application_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<current_employer>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_current_employer);
    l_text:=l_text||'</current_employer>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<projected_hire_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_projected_hire_date);
    l_text:=l_text||'</projected_hire_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<termination_reason>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_termination_reason);
    l_text:=l_text||'</termination_reason>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute_category);
    l_text:=l_text||'</appl_attribute_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute1);
    l_text:=l_text||'</appl_attribute1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute2);
    l_text:=l_text||'</appl_attribute2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute3);
    l_text:=l_text||'</appl_attribute3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute4);
    l_text:=l_text||'</appl_attribute4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute5);
    l_text:=l_text||'</appl_attribute5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute6);
    l_text:=l_text||'</appl_attribute6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute7);
    l_text:=l_text||'</appl_attribute7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute8);
    l_text:=l_text||'</appl_attribute8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute9);
    l_text:=l_text||'</appl_attribute9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute10);
    l_text:=l_text||'</appl_attribute10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute11);
    l_text:=l_text||'</appl_attribute11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute12);
    l_text:=l_text||'</appl_attribute12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute13);
    l_text:=l_text||'</appl_attribute13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute14);
    l_text:=l_text||'</appl_attribute14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute15);
    l_text:=l_text||'</appl_attribute15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute16);
    l_text:=l_text||'</appl_attribute16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute17);
    l_text:=l_text||'</appl_attribute17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute18);
    l_text:=l_text||'</appl_attribute18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute19);
    l_text:=l_text||'</appl_attribute19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appl_attribute20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_appl_attribute20);
    l_text:=l_text||'</appl_attribute20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</application>';
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
end update_apl_details_a;
end hr_application_be1;

/
