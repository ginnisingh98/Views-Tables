--------------------------------------------------------
--  DDL for Package Body IRC_REC_TEAM_MEMBERS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_REC_TEAM_MEMBERS_BE1" as 
--Code generated on 29/08/2013 09:58:19
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_rec_team_member_a (
p_rec_team_member_id           number,
p_person_id                    number,
p_vacancy_id                   number,
p_job_id                       number,
p_start_date                   date,
p_end_date                     date,
p_update_allowed               varchar2,
p_delete_allowed               varchar2,
p_object_version_number        number,
p_interview_security           varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  irc_rec_team_members_be1.create_rec_team_member_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.irc.api.rec_team_members.create_rec_team_member';
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
    l_text:='<rec_team_members>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<rec_team_member_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_rec_team_member_id);
    l_text:=l_text||'</rec_team_member_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<vacancy_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_vacancy_id);
    l_text:=l_text||'</vacancy_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<job_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_job_id);
    l_text:=l_text||'</job_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_start_date);
    l_text:=l_text||'</start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_end_date);
    l_text:=l_text||'</end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<update_allowed>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_update_allowed);
    l_text:=l_text||'</update_allowed>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<delete_allowed>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_delete_allowed);
    l_text:=l_text||'</delete_allowed>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<interview_security>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_interview_security);
    l_text:=l_text||'</interview_security>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</rec_team_members>';
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
end create_rec_team_member_a;
end irc_rec_team_members_be1;

/
