--------------------------------------------------------
--  DDL for Package Body HR_CONTINGENT_WORKER_BE5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CONTINGENT_WORKER_BE5" as 
--Code generated on 29/08/2013 10:00:56
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure reverse_terminate_placement_a (
p_validate                     boolean,
p_person_id                    number,
p_actual_termination_date      date,
p_clear_details                varchar2,
p_fut_actns_exist_warning      boolean) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_contingent_worker_be5.reverse_terminate_placement_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.contingent_worker.reverse_terminate_placement';
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
    l_text:='<contingent_worker>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<validate>';
if(P_VALIDATE) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</validate>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<actual_termination_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_actual_termination_date);
    l_text:=l_text||'</actual_termination_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<clear_details>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_clear_details);
    l_text:=l_text||'</clear_details>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<fut_actns_exist_warning>';
if(P_FUT_ACTNS_EXIST_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</fut_actns_exist_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</contingent_worker>';
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
end reverse_terminate_placement_a;
end hr_contingent_worker_be5;

/
