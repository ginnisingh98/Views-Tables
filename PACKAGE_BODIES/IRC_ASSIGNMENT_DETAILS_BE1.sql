--------------------------------------------------------
--  DDL for Package Body IRC_ASSIGNMENT_DETAILS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ASSIGNMENT_DETAILS_BE1" as 
--Code generated on 30/08/2013 11:35:51
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_assignment_details_a (
p_effective_date               date,
p_assignment_details_id        number,
p_assignment_id                number,
p_attempt_id                   number,
p_details_version              number,
p_latest_details               varchar2,
p_effective_start_date         date,
p_effective_end_date           date,
p_object_version_number        number,
p_qualified                    varchar2,
p_considered                   varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  irc_assignment_details_be1.create_assignment_details_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.irc.api.assignment_details.create_assignment_details';
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
    l_text:='<assignment_details>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_details_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_details_id);
    l_text:=l_text||'</assignment_details_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_id);
    l_text:=l_text||'</assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attempt_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_attempt_id);
    l_text:=l_text||'</attempt_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<details_version>';
    l_text:=l_text||fnd_number.number_to_canonical(p_details_version);
    l_text:=l_text||'</details_version>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<latest_details>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_latest_details);
    l_text:=l_text||'</latest_details>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_start_date);
    l_text:=l_text||'</effective_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_end_date);
    l_text:=l_text||'</effective_end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<qualified>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_qualified);
    l_text:=l_text||'</qualified>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<considered>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_considered);
    l_text:=l_text||'</considered>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</assignment_details>';
    --
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    if p_effective_start_date is not NULL and
       p_effective_start_date > trunc(SYSDATE) and
        fnd_profile.value('HR_DEFER_FD_BE_EVENTS') = 'Y' then 
       -- raise the event with the event data, with send date set to effective date
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_event_data=>l_event_data
                     ,p_send_date => p_effective_start_date);
        --
    else 
       -- raise the event with the event data
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_event_data=>l_event_data);
    end if;
  elsif (l_message='KEY') then
    hr_utility.set_location(l_proc,30);
    -- get a key for the event
    open get_seq;
    fetch get_seq into l_event_key;
    close get_seq;
    if p_effective_start_date is not NULL and
       p_effective_start_date > trunc(SYSDATE) and
        fnd_profile.value('HR_DEFER_FD_BE_EVENTS') = 'Y' then 
       -- this is a key event, so just raise the event
       -- without the event data, with send date set to effective date
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_send_date => p_effective_start_date);
       --
    else
       -- this is a key event, so just raise the event
       -- without the event data
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key);
    end if;
  elsif (l_message='NONE') then
    hr_utility.set_location(l_proc,40);
    -- no event is required, so do nothing
    null;
  end if;
    hr_utility.set_location('Leaving: '||l_proc,50);
end create_assignment_details_a;
end irc_assignment_details_be1;

/
