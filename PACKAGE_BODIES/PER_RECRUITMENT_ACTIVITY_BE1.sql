--------------------------------------------------------
--  DDL for Package Body PER_RECRUITMENT_ACTIVITY_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RECRUITMENT_ACTIVITY_BE1" as 
--Code generated on 04/01/2007 09:33:04
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure create_recruitment_activity_a (
p_business_group_id            number,
p_authorising_person_id        number,
p_run_by_organization_id       number,
p_internal_contact_person_id   number,
p_parent_recruitment_activity  number,
p_currency_code                varchar2,
p_date_start                   date,
p_name                         varchar2,
p_actual_cost                  varchar2,
p_comments                     long,
p_contact_telephone_number     varchar2,
p_date_closing                 date,
p_date_end                     date,
p_external_contact             varchar2,
p_planned_cost                 varchar2,
p_recruiting_site_id           number,
p_recruiting_site_response     varchar2,
p_last_posted_date             date,
p_type                         varchar2,
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
p_posting_content_id           number,
p_status                       varchar2,
p_object_version_number        number,
p_recruitment_activity_id      number) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  per_recruitment_activity_be1.create_recruitment_activity_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.recruitment_activity.create_recruitment_activity';
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
    l_text:='<recruitment_activity>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<authorising_person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_authorising_person_id);
    l_text:=l_text||'</authorising_person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<run_by_organization_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_run_by_organization_id);
    l_text:=l_text||'</run_by_organization_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<internal_contact_person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_internal_contact_person_id);
    l_text:=l_text||'</internal_contact_person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<parent_recruitment_activity>';
    l_text:=l_text||fnd_number.number_to_canonical(p_parent_recruitment_activity);
    l_text:=l_text||'</parent_recruitment_activity>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<currency_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_currency_code);
    l_text:=l_text||'</currency_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_start>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_start);
    l_text:=l_text||'</date_start>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_name);
    l_text:=l_text||'</name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<actual_cost>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_actual_cost);
    l_text:=l_text||'</actual_cost>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<contact_telephone_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_contact_telephone_number);
    l_text:=l_text||'</contact_telephone_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_closing>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_closing);
    l_text:=l_text||'</date_closing>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_end>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_end);
    l_text:=l_text||'</date_end>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<external_contact>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_external_contact);
    l_text:=l_text||'</external_contact>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<planned_cost>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_planned_cost);
    l_text:=l_text||'</planned_cost>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<recruiting_site_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_recruiting_site_id);
    l_text:=l_text||'</recruiting_site_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<recruiting_site_response>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_recruiting_site_response);
    l_text:=l_text||'</recruiting_site_response>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<last_posted_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_last_posted_date);
    l_text:=l_text||'</last_posted_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_type);
    l_text:=l_text||'</type>';
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
    l_text:='<posting_content_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_posting_content_id);
    l_text:=l_text||'</posting_content_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<status>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_status);
    l_text:=l_text||'</status>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<recruitment_activity_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_recruitment_activity_id);
    l_text:=l_text||'</recruitment_activity_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</recruitment_activity>';
    --
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    -- raise the event with the event data
    wf_event.raise(p_event_name=>l_event_name
                  ,p_event_key=>l_event_key
                  ,p_event_data=>l_event_data);
    --
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
    --
  elsif (l_message='NONE') then
    hr_utility.set_location(l_proc,40);
    -- no event is required, so do nothing
    null;
  end if;
    hr_utility.set_location('Leaving: '||l_proc,50);
end create_recruitment_activity_a;
end per_recruitment_activity_be1;

/
