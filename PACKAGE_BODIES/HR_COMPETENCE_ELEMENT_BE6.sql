--------------------------------------------------------
--  DDL for Package Body HR_COMPETENCE_ELEMENT_BE6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMPETENCE_ELEMENT_BE6" as 
--Code generated on 04/01/2007 09:31:55
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure copy_competencies_a (
p_activity_version_from        number,
p_activity_version_id          number,
p_activity_version_to          number,
p_competence_type              varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_competence_element_be6.copy_competencies_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.competence_element.copy_competencies';
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
    l_text:='<competence_element>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<activity_version_from>';
    l_text:=l_text||fnd_number.number_to_canonical(p_activity_version_from);
    l_text:=l_text||'</activity_version_from>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<activity_version_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_activity_version_id);
    l_text:=l_text||'</activity_version_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<activity_version_to>';
    l_text:=l_text||fnd_number.number_to_canonical(p_activity_version_to);
    l_text:=l_text||'</activity_version_to>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<competence_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_competence_type);
    l_text:=l_text||'</competence_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</competence_element>';
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
end copy_competencies_a;
end hr_competence_element_be6;

/
