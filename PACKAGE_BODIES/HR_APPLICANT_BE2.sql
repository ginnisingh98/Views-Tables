--------------------------------------------------------
--  DDL for Package Body HR_APPLICANT_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPLICANT_BE2" as 
--Code generated on 30/08/2013 11:36:17
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure  hire_applicant_a (
p_hire_date                    date,
p_person_id                    number,
p_assignment_id                number,
p_person_type_id               number,
p_national_identifier          varchar2,
p_per_object_version_number    number,
p_employee_number              varchar2,
p_per_effective_start_date     date,
p_per_effective_end_date       date,
p_unaccepted_asg_del_warning   boolean,
p_assign_payroll_warning       boolean,
p_oversubscribed_vacancy_id    number,
p_original_date_of_hire        date) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_applicant_be2. hire_applicant_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.applicant. hire_applicant';
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
    l_text:='<applicant>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<hire_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_hire_date);
    l_text:=l_text||'</hire_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_id);
    l_text:=l_text||'</assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_type_id);
    l_text:=l_text||'</person_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<national_identifier>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_national_identifier);
    l_text:=l_text||'</national_identifier>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_per_object_version_number);
    l_text:=l_text||'</per_object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<employee_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employee_number);
    l_text:=l_text||'</employee_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_effective_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_per_effective_start_date);
    l_text:=l_text||'</per_effective_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_effective_end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_per_effective_end_date);
    l_text:=l_text||'</per_effective_end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<unaccepted_asg_del_warning>';
if(P_UNACCEPTED_ASG_DEL_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</unaccepted_asg_del_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assign_payroll_warning>';
if(P_ASSIGN_PAYROLL_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</assign_payroll_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<oversubscribed_vacancy_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_oversubscribed_vacancy_id);
    l_text:=l_text||'</oversubscribed_vacancy_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<original_date_of_hire>';
    l_text:=l_text||fnd_date.date_to_canonical(p_original_date_of_hire);
    l_text:=l_text||'</original_date_of_hire>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</applicant>';
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
end  hire_applicant_a;
end hr_applicant_be2;

/
