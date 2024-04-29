--------------------------------------------------------
--  DDL for Package Body IRC_PARTY_BE6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PARTY_BE6" as 
--Code generated on 30/08/2013 11:35:53
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure self_register_user_a (
p_current_email_address        varchar2,
p_responsibility_id            number,
p_resp_appl_id                 number,
p_security_group_id            number,
p_first_name                   varchar2,
p_last_name                    varchar2,
p_middle_names                 varchar2,
p_previous_last_name           varchar2,
p_employee_number              varchar2,
p_national_identifier          varchar2,
p_date_of_birth                date,
p_email_address                varchar2,
p_home_phone_number            varchar2,
p_work_phone_number            varchar2,
p_address_line_1               varchar2,
p_manager_last_name            varchar2,
p_allow_access                 varchar2,
p_language                     varchar2,
p_user_name                    varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  irc_party_be6.self_register_user_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.irc.api.party.self_register_user';
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
    l_text:='<party>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<current_email_address>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_current_email_address);
    l_text:=l_text||'</current_email_address>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<responsibility_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_responsibility_id);
    l_text:=l_text||'</responsibility_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<resp_appl_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_resp_appl_id);
    l_text:=l_text||'</resp_appl_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<security_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_security_group_id);
    l_text:=l_text||'</security_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<first_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_first_name);
    l_text:=l_text||'</first_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<last_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_last_name);
    l_text:=l_text||'</last_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<middle_names>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_middle_names);
    l_text:=l_text||'</middle_names>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<previous_last_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_previous_last_name);
    l_text:=l_text||'</previous_last_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<employee_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employee_number);
    l_text:=l_text||'</employee_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<national_identifier>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_national_identifier);
    l_text:=l_text||'</national_identifier>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_of_birth>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_of_birth);
    l_text:=l_text||'</date_of_birth>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<email_address>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_email_address);
    l_text:=l_text||'</email_address>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<home_phone_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_home_phone_number);
    l_text:=l_text||'</home_phone_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<work_phone_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_work_phone_number);
    l_text:=l_text||'</work_phone_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<address_line_1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_address_line_1);
    l_text:=l_text||'</address_line_1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<manager_last_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_manager_last_name);
    l_text:=l_text||'</manager_last_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<allow_access>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_allow_access);
    l_text:=l_text||'</allow_access>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<language>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_language);
    l_text:=l_text||'</language>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<user_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_user_name);
    l_text:=l_text||'</user_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</party>';
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
end self_register_user_a;
end irc_party_be6;

/
