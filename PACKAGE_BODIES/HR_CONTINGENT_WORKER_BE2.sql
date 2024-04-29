--------------------------------------------------------
--  DDL for Package Body HR_CONTINGENT_WORKER_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CONTINGENT_WORKER_BE2" as 
--Code generated on 29/08/2013 10:00:55
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure convert_to_cwk_a (
p_effective_date               date,
p_person_id                    number,
p_object_version_number        number,
p_npw_number                   varchar2,
p_projected_placement_end      date,
p_person_type_id               number,
p_datetrack_update_mode        varchar2,
p_per_effective_start_date     date,
p_per_effective_end_date       date,
p_pdp_object_version_number    number,
p_assignment_id                number,
p_asg_object_version_number    number,
p_assignment_sequence          number) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_contingent_worker_be2.convert_to_cwk_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.contingent_worker.convert_to_cwk';
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
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<npw_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_npw_number);
    l_text:=l_text||'</npw_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<projected_placement_end>';
    l_text:=l_text||fnd_date.date_to_canonical(p_projected_placement_end);
    l_text:=l_text||'</projected_placement_end>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_type_id);
    l_text:=l_text||'</person_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<datetrack_update_mode>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_datetrack_update_mode);
    l_text:=l_text||'</datetrack_update_mode>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_effective_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_per_effective_start_date);
    l_text:=l_text||'</per_effective_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_effective_end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_per_effective_end_date);
    l_text:=l_text||'</per_effective_end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pdp_object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_pdp_object_version_number);
    l_text:=l_text||'</pdp_object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_id);
    l_text:=l_text||'</assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<asg_object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_asg_object_version_number);
    l_text:=l_text||'</asg_object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_sequence>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_sequence);
    l_text:=l_text||'</assignment_sequence>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</contingent_worker>';
    --
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    if p_per_effective_start_date is not NULL and
       p_per_effective_start_date > trunc(SYSDATE) and
        fnd_profile.value('HR_DEFER_FD_BE_EVENTS') = 'Y' then 
       -- raise the event with the event data, with send date set to effective date
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_event_data=>l_event_data
                     ,p_send_date => p_per_effective_start_date);
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
    if p_per_effective_start_date is not NULL and
       p_per_effective_start_date > trunc(SYSDATE) and
        fnd_profile.value('HR_DEFER_FD_BE_EVENTS') = 'Y' then 
       -- this is a key event, so just raise the event
       -- without the event data, with send date set to effective date
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_send_date => p_per_effective_start_date);
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
end convert_to_cwk_a;
end hr_contingent_worker_be2;

/
