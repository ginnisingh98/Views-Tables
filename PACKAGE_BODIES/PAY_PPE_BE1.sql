--------------------------------------------------------
--  DDL for Package Body PAY_PPE_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPE_BE1" as 
--Code generated on 29/08/2013 10:00:33
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_process_event_a (
p_assignment_id                number,
p_effective_date               date,
p_change_type                  varchar2,
p_status                       varchar2,
p_description                  varchar2,
p_process_event_id             number,
p_object_version_number        number,
p_event_update_id              number,
p_org_process_event_group_id   number,
p_business_group_id            number,
p_surrogate_key                varchar2,
p_calculation_date             date,
p_retroactive_status           varchar2,
p_noted_value                  varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  pay_ppe_be1.create_process_event_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.pay.api.ppe.create_process_event';
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
    l_text:='<ppe>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_id);
    l_text:=l_text||'</assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<change_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_change_type);
    l_text:=l_text||'</change_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<status>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_status);
    l_text:=l_text||'</status>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_description);
    l_text:=l_text||'</description>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<process_event_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_process_event_id);
    l_text:=l_text||'</process_event_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<event_update_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_event_update_id);
    l_text:=l_text||'</event_update_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_process_event_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_org_process_event_group_id);
    l_text:=l_text||'</org_process_event_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<surrogate_key>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_surrogate_key);
    l_text:=l_text||'</surrogate_key>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<calculation_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_calculation_date);
    l_text:=l_text||'</calculation_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<retroactive_status>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_retroactive_status);
    l_text:=l_text||'</retroactive_status>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<noted_value>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_noted_value);
    l_text:=l_text||'</noted_value>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</ppe>';
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
end create_process_event_a;
end pay_ppe_be1;

/
