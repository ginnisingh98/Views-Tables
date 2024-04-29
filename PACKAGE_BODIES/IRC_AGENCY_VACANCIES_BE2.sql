--------------------------------------------------------
--  DDL for Package Body IRC_AGENCY_VACANCIES_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_AGENCY_VACANCIES_BE2" as 
--Code generated on 29/08/2013 09:58:18
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_agency_vacancy_a (
p_agency_vacancy_id            number,
p_agency_id                    number,
p_vacancy_id                   number,
p_start_date                   date,
p_end_date                     date,
p_max_allowed_applicants       number,
p_manage_applicants_allowed    varchar2,
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
p_attribute21                  varchar2,
p_attribute22                  varchar2,
p_attribute23                  varchar2,
p_attribute24                  varchar2,
p_attribute25                  varchar2,
p_attribute26                  varchar2,
p_attribute27                  varchar2,
p_attribute28                  varchar2,
p_attribute29                  varchar2,
p_attribute30                  varchar2,
p_object_version_number        varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  irc_agency_vacancies_be2.update_agency_vacancy_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.irc.api.agency_vacancies.update_agency_vacancy';
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
    l_text:='<agency_vacancies>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<agency_vacancy_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_agency_vacancy_id);
    l_text:=l_text||'</agency_vacancy_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<agency_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_agency_id);
    l_text:=l_text||'</agency_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<vacancy_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_vacancy_id);
    l_text:=l_text||'</vacancy_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_start_date);
    l_text:=l_text||'</start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_end_date);
    l_text:=l_text||'</end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<max_allowed_applicants>';
    l_text:=l_text||fnd_number.number_to_canonical(p_max_allowed_applicants);
    l_text:=l_text||'</max_allowed_applicants>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<manage_applicants_allowed>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_manage_applicants_allowed);
    l_text:=l_text||'</manage_applicants_allowed>';
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
    l_text:='<attribute21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute21);
    l_text:=l_text||'</attribute21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute22);
    l_text:=l_text||'</attribute22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute23);
    l_text:=l_text||'</attribute23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute24);
    l_text:=l_text||'</attribute24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute25);
    l_text:=l_text||'</attribute25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute26);
    l_text:=l_text||'</attribute26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute27);
    l_text:=l_text||'</attribute27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute28);
    l_text:=l_text||'</attribute28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute29);
    l_text:=l_text||'</attribute29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<attribute30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_attribute30);
    l_text:=l_text||'</attribute30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</agency_vacancies>';
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
end update_agency_vacancy_a;
end irc_agency_vacancies_be2;

/
