--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_BEO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_BEO" as 
--Code generated on 30/08/2013 11:36:22
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_cwk_asg_criteria_a (
p_effective_date               date,
p_datetrack_update_mode        varchar2,
p_assignment_id                number,
p_object_version_number        number,
p_grade_id                     number,
p_position_id                  number,
p_job_id                       number,
p_location_id                  number,
p_organization_id              number,
p_pay_basis_id                 number,
p_segment1                     varchar2,
p_segment2                     varchar2,
p_segment3                     varchar2,
p_segment4                     varchar2,
p_segment5                     varchar2,
p_segment6                     varchar2,
p_segment7                     varchar2,
p_segment8                     varchar2,
p_segment9                     varchar2,
p_segment10                    varchar2,
p_segment11                    varchar2,
p_segment12                    varchar2,
p_segment13                    varchar2,
p_segment14                    varchar2,
p_segment15                    varchar2,
p_segment16                    varchar2,
p_segment17                    varchar2,
p_segment18                    varchar2,
p_segment19                    varchar2,
p_segment20                    varchar2,
p_segment21                    varchar2,
p_segment22                    varchar2,
p_segment23                    varchar2,
p_segment24                    varchar2,
p_segment25                    varchar2,
p_segment26                    varchar2,
p_segment27                    varchar2,
p_segment28                    varchar2,
p_segment29                    varchar2,
p_segment30                    varchar2,
p_people_group_name            varchar2,
p_effective_start_date         date,
p_effective_end_date           date,
p_people_group_id              number,
p_org_now_no_manager_warning   boolean,
p_other_manager_warning        boolean,
p_spp_delete_warning           boolean,
p_entries_changed_warning      varchar2,
p_tax_district_changed_warning boolean,
p_concat_segments              varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_assignment_beO.update_cwk_asg_criteria_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.assignment.update_cwk_asg_criteria';
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
    l_text:='<assignment>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<datetrack_update_mode>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_datetrack_update_mode);
    l_text:=l_text||'</datetrack_update_mode>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_id);
    l_text:=l_text||'</assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<grade_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_grade_id);
    l_text:=l_text||'</grade_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<position_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_position_id);
    l_text:=l_text||'</position_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<job_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_job_id);
    l_text:=l_text||'</job_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<location_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_location_id);
    l_text:=l_text||'</location_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<organization_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_organization_id);
    l_text:=l_text||'</organization_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pay_basis_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_pay_basis_id);
    l_text:=l_text||'</pay_basis_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment1);
    l_text:=l_text||'</segment1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment2);
    l_text:=l_text||'</segment2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment3);
    l_text:=l_text||'</segment3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment4);
    l_text:=l_text||'</segment4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment5);
    l_text:=l_text||'</segment5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment6);
    l_text:=l_text||'</segment6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment7);
    l_text:=l_text||'</segment7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment8);
    l_text:=l_text||'</segment8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment9);
    l_text:=l_text||'</segment9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment10);
    l_text:=l_text||'</segment10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment11);
    l_text:=l_text||'</segment11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment12);
    l_text:=l_text||'</segment12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment13);
    l_text:=l_text||'</segment13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment14);
    l_text:=l_text||'</segment14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment15);
    l_text:=l_text||'</segment15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment16);
    l_text:=l_text||'</segment16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment17);
    l_text:=l_text||'</segment17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment18);
    l_text:=l_text||'</segment18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment19);
    l_text:=l_text||'</segment19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment20);
    l_text:=l_text||'</segment20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment21);
    l_text:=l_text||'</segment21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment22);
    l_text:=l_text||'</segment22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment23);
    l_text:=l_text||'</segment23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment24);
    l_text:=l_text||'</segment24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment25);
    l_text:=l_text||'</segment25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment26);
    l_text:=l_text||'</segment26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment27);
    l_text:=l_text||'</segment27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment28);
    l_text:=l_text||'</segment28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment29);
    l_text:=l_text||'</segment29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<segment30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_segment30);
    l_text:=l_text||'</segment30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<people_group_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_people_group_name);
    l_text:=l_text||'</people_group_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_start_date);
    l_text:=l_text||'</effective_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_end_date);
    l_text:=l_text||'</effective_end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<people_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_people_group_id);
    l_text:=l_text||'</people_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_now_no_manager_warning>';
if(P_ORG_NOW_NO_MANAGER_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</org_now_no_manager_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<other_manager_warning>';
if(P_OTHER_MANAGER_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</other_manager_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<spp_delete_warning>';
if(P_SPP_DELETE_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</spp_delete_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<entries_changed_warning>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_entries_changed_warning);
    l_text:=l_text||'</entries_changed_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tax_district_changed_warning>';
if(P_TAX_DISTRICT_CHANGED_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</tax_district_changed_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<concat_segments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_concat_segments);
    l_text:=l_text||'</concat_segments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</assignment>';
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
end update_cwk_asg_criteria_a;
end hr_assignment_beO;

/
