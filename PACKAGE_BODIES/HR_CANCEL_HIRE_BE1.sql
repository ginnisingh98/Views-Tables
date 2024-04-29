--------------------------------------------------------
--  DDL for Package Body HR_CANCEL_HIRE_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CANCEL_HIRE_BE1" as 
--Code generated on 30/08/2013 11:36:15
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure cancel_hire_a (
p_person_id                    number,
p_effective_date               date,
p_supervisor_warning           boolean,
p_recruiter_warning            boolean,
p_event_warning                boolean,
p_interview_warning            boolean,
p_review_warning               boolean,
p_vacancy_warning              boolean,
p_requisition_warning          boolean,
p_budget_warning               boolean,
p_payment_warning              boolean) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_cancel_hire_be1.cancel_hire_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.cancel_hire.cancel_hire';
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
    l_text:='<cancel_hire>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<supervisor_warning>';
if(P_SUPERVISOR_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</supervisor_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<recruiter_warning>';
if(P_RECRUITER_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</recruiter_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<event_warning>';
if(P_EVENT_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</event_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<interview_warning>';
if(P_INTERVIEW_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</interview_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<review_warning>';
if(P_REVIEW_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</review_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<vacancy_warning>';
if(P_VACANCY_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</vacancy_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<requisition_warning>';
if(P_REQUISITION_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</requisition_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<budget_warning>';
if(P_BUDGET_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</budget_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<payment_warning>';
if(P_PAYMENT_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</payment_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</cancel_hire>';
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
end cancel_hire_a;
end hr_cancel_hire_be1;

/
