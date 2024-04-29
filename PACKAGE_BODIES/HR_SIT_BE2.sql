--------------------------------------------------------
--  DDL for Package Body HR_SIT_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SIT_BE2" as 
--Code generated on 29/08/2013 10:00:57
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_sit_a (
p_person_analysis_id           number,
p_pea_object_version_number    number,
p_comments                     varchar2,
p_date_from                    date,
p_date_to                      date,
p_request_id                   number,
p_program_application_id       number,
p_program_id                   number,
p_program_update_date          date,
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
p_analysis_criteria_id         number) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_sit_be2.update_sit_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.sit.update_sit';
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
    l_text:='<sit>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<person_analysis_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_analysis_id);
    l_text:=l_text||'</person_analysis_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pea_object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_pea_object_version_number);
    l_text:=l_text||'</pea_object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_from>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_from);
    l_text:=l_text||'</date_from>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_to>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_to);
    l_text:=l_text||'</date_to>';
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
    l_text:='<analysis_criteria_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_analysis_criteria_id);
    l_text:=l_text||'</analysis_criteria_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</sit>';
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
end update_sit_a;
end hr_sit_be2;

/
