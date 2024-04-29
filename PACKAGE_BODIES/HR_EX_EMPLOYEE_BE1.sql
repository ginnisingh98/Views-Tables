--------------------------------------------------------
--  DDL for Package Body HR_EX_EMPLOYEE_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EX_EMPLOYEE_BE1" as 
--Code generated on 30/08/2013 11:36:15
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure actual_termination_emp_a (
p_effective_date               date,
p_period_of_service_id         number,
p_object_version_number        number,
p_actual_termination_date      date,
p_last_standard_process_date   date,
p_person_type_id               number,
p_assignment_status_type_id    number,
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
p_pds_information_category     varchar2,
p_pds_information1             varchar2,
p_pds_information2             varchar2,
p_pds_information3             varchar2,
p_pds_information4             varchar2,
p_pds_information5             varchar2,
p_pds_information6             varchar2,
p_pds_information7             varchar2,
p_pds_information8             varchar2,
p_pds_information9             varchar2,
p_pds_information10            varchar2,
p_pds_information11            varchar2,
p_pds_information12            varchar2,
p_pds_information13            varchar2,
p_pds_information14            varchar2,
p_pds_information15            varchar2,
p_pds_information16            varchar2,
p_pds_information17            varchar2,
p_pds_information18            varchar2,
p_pds_information19            varchar2,
p_pds_information20            varchar2,
p_pds_information21            varchar2,
p_pds_information22            varchar2,
p_pds_information23            varchar2,
p_pds_information24            varchar2,
p_pds_information25            varchar2,
p_pds_information26            varchar2,
p_pds_information27            varchar2,
p_pds_information28            varchar2,
p_pds_information29            varchar2,
p_pds_information30            varchar2,
p_last_std_process_date_out    date,
p_supervisor_warning           boolean,
p_event_warning                boolean,
p_interview_warning            boolean,
p_review_warning               boolean,
p_recruiter_warning            boolean,
p_asg_future_changes_warning   boolean,
p_entries_changed_warning      varchar2,
p_pay_proposal_warning         boolean,
p_dod_warning                  boolean,
p_business_group_id            number,
p_person_id                    number) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_ex_employee_be1.actual_termination_emp_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.ex_employee.actual_termination_emp';
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
    l_text:='<ex_employee>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<period_of_service_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_period_of_service_id);
    l_text:=l_text||'</period_of_service_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<actual_termination_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_actual_termination_date);
    l_text:=l_text||'</actual_termination_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<last_standard_process_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_last_standard_process_date);
    l_text:=l_text||'</last_standard_process_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_type_id);
    l_text:=l_text||'</person_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_status_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_status_type_id);
    l_text:=l_text||'</assignment_status_type_id>';
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
    l_text:='<pds_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information_category);
    l_text:=l_text||'</pds_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information1);
    l_text:=l_text||'</pds_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information2);
    l_text:=l_text||'</pds_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information3);
    l_text:=l_text||'</pds_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information4);
    l_text:=l_text||'</pds_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information5);
    l_text:=l_text||'</pds_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information6);
    l_text:=l_text||'</pds_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information7);
    l_text:=l_text||'</pds_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information8);
    l_text:=l_text||'</pds_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information9);
    l_text:=l_text||'</pds_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information10);
    l_text:=l_text||'</pds_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information11);
    l_text:=l_text||'</pds_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information12);
    l_text:=l_text||'</pds_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information13);
    l_text:=l_text||'</pds_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information14);
    l_text:=l_text||'</pds_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information15);
    l_text:=l_text||'</pds_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information16);
    l_text:=l_text||'</pds_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information17);
    l_text:=l_text||'</pds_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information18);
    l_text:=l_text||'</pds_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information19);
    l_text:=l_text||'</pds_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information20);
    l_text:=l_text||'</pds_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information21);
    l_text:=l_text||'</pds_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information22);
    l_text:=l_text||'</pds_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information23);
    l_text:=l_text||'</pds_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information24);
    l_text:=l_text||'</pds_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information25);
    l_text:=l_text||'</pds_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information26);
    l_text:=l_text||'</pds_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information27);
    l_text:=l_text||'</pds_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information28);
    l_text:=l_text||'</pds_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information29);
    l_text:=l_text||'</pds_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pds_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pds_information30);
    l_text:=l_text||'</pds_information30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<last_std_process_date_out>';
    l_text:=l_text||fnd_date.date_to_canonical(p_last_std_process_date_out);
    l_text:=l_text||'</last_std_process_date_out>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<supervisor_warning>';
if(P_SUPERVISOR_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</supervisor_warning>';
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
    l_text:='<recruiter_warning>';
if(P_RECRUITER_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</recruiter_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<asg_future_changes_warning>';
if(P_ASG_FUTURE_CHANGES_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</asg_future_changes_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<entries_changed_warning>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_entries_changed_warning);
    l_text:=l_text||'</entries_changed_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pay_proposal_warning>';
if(P_PAY_PROPOSAL_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</pay_proposal_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dod_warning>';
if(P_DOD_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</dod_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</ex_employee>';
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
end actual_termination_emp_a;
end hr_ex_employee_be1;

/
