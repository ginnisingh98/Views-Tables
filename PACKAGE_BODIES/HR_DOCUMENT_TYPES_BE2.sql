--------------------------------------------------------
--  DDL for Package Body HR_DOCUMENT_TYPES_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DOCUMENT_TYPES_BE2" as 
--Code generated on 29/08/2013 10:00:52
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_document_type_a (
p_document_type_id             number,
p_effective_date               date,
p_document_type                varchar2,
p_language_code                varchar2,
p_description                  varchar2,
p_category_code                varchar2,
p_active_inactive_flag         varchar2,
p_multiple_occurences_flag     varchar2,
p_authorization_required       varchar2,
p_sub_category_code            varchar2,
p_legislation_code             varchar2,
p_warning_period               number,
p_request_id                   number,
p_program_application_id       number,
p_program_id                   number,
p_program_update_date          date,
p_object_version_number        number) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_document_types_be2.update_document_type_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.document_types.update_document_type';
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
    l_text:='<document_types>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<document_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_document_type_id);
    l_text:=l_text||'</document_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<document_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_document_type);
    l_text:=l_text||'</document_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<language_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_language_code);
    l_text:=l_text||'</language_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_description);
    l_text:=l_text||'</description>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<category_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_category_code);
    l_text:=l_text||'</category_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<active_inactive_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_active_inactive_flag);
    l_text:=l_text||'</active_inactive_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<multiple_occurences_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_multiple_occurences_flag);
    l_text:=l_text||'</multiple_occurences_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<authorization_required>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_authorization_required);
    l_text:=l_text||'</authorization_required>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<sub_category_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_sub_category_code);
    l_text:=l_text||'</sub_category_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<legislation_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_legislation_code);
    l_text:=l_text||'</legislation_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<warning_period>';
    l_text:=l_text||fnd_number.number_to_canonical(p_warning_period);
    l_text:=l_text||'</warning_period>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<request_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_request_id);
    l_text:=l_text||'</request_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<program_application_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_program_application_id);
    l_text:=l_text||'</program_application_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<program_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_program_id);
    l_text:=l_text||'</program_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<program_update_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_program_update_date);
    l_text:=l_text||'</program_update_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</document_types>';
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
end update_document_type_a;
end hr_document_types_be2;

/
