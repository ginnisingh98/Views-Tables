--------------------------------------------------------
--  DDL for Package Body HR_ORGANIZATION_BE9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORGANIZATION_BE9" as 
--Code generated on 30/08/2013 11:36:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_hr_organization_a (
p_effective_date               date,
p_business_group_id            number,
p_name                         varchar2,
p_date_from                    date,
p_language_code                varchar2,
p_location_id                  number,
p_date_to                      date,
p_internal_external_flag       varchar2,
p_internal_address_line        varchar2,
p_type                         varchar2,
p_enabled_flag                 varchar2,
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
p_concat_segments              varchar2,
p_object_version_number_inf    number,
p_object_version_number_org    number,
p_organization_id              number,
p_org_information_id           number,
p_duplicate_org_warning        boolean) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_organization_be9.create_hr_organization_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.organization.create_hr_organization';
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
    l_text:='<organization>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_name);
    l_text:=l_text||'</name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_from>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_from);
    l_text:=l_text||'</date_from>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<language_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_language_code);
    l_text:=l_text||'</language_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<location_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_location_id);
    l_text:=l_text||'</location_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_to>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_to);
    l_text:=l_text||'</date_to>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<internal_external_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_internal_external_flag);
    l_text:=l_text||'</internal_external_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<internal_address_line>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_internal_address_line);
    l_text:=l_text||'</internal_address_line>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_type);
    l_text:=l_text||'</type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<enabled_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_enabled_flag);
    l_text:=l_text||'</enabled_flag>';
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
    l_text:='<concat_segments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_concat_segments);
    l_text:=l_text||'</concat_segments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number_inf>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number_inf);
    l_text:=l_text||'</object_version_number_inf>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number_org>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number_org);
    l_text:=l_text||'</object_version_number_org>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<organization_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_organization_id);
    l_text:=l_text||'</organization_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_information_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_org_information_id);
    l_text:=l_text||'</org_information_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<duplicate_org_warning>';
if(P_DUPLICATE_ORG_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</duplicate_org_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</organization>';
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
end create_hr_organization_a;
end hr_organization_be9;

/
