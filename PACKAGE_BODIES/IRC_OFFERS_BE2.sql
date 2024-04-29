--------------------------------------------------------
--  DDL for Package Body IRC_OFFERS_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_OFFERS_BE2" as 
--Code generated on 30/08/2013 11:35:52
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_offer_a (
p_effective_date               date,
p_offer_id                     number,
p_offer_version                number,
p_latest_offer                 varchar2,
p_offer_status                 varchar2,
p_discretionary_job_title      varchar2,
p_offer_extended_method        varchar2,
p_respondent_id                number,
p_expiry_date                  date,
p_proposed_start_date          date,
p_offer_letter_tracking_code   varchar2,
p_offer_postal_service         varchar2,
p_offer_shipping_date          date,
p_applicant_assignment_id      number,
p_offer_assignment_id          number,
p_address_id                   number,
p_template_id                  number,
p_offer_letter_file_type       varchar2,
p_offer_letter_file_name       varchar2,
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
  l_proc varchar2(72):='  irc_offers_be2.update_offer_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.irc.api.offers.update_offer';
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
    l_text:='<offers>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_offer_id);
    l_text:=l_text||'</offer_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_version>';
    l_text:=l_text||fnd_number.number_to_canonical(p_offer_version);
    l_text:=l_text||'</offer_version>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<latest_offer>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_latest_offer);
    l_text:=l_text||'</latest_offer>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_status>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_offer_status);
    l_text:=l_text||'</offer_status>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<discretionary_job_title>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_discretionary_job_title);
    l_text:=l_text||'</discretionary_job_title>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_extended_method>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_offer_extended_method);
    l_text:=l_text||'</offer_extended_method>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<respondent_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_respondent_id);
    l_text:=l_text||'</respondent_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<expiry_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_expiry_date);
    l_text:=l_text||'</expiry_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<proposed_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_proposed_start_date);
    l_text:=l_text||'</proposed_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_letter_tracking_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_offer_letter_tracking_code);
    l_text:=l_text||'</offer_letter_tracking_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_postal_service>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_offer_postal_service);
    l_text:=l_text||'</offer_postal_service>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_shipping_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_offer_shipping_date);
    l_text:=l_text||'</offer_shipping_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<applicant_assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_applicant_assignment_id);
    l_text:=l_text||'</applicant_assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_offer_assignment_id);
    l_text:=l_text||'</offer_assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<address_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_address_id);
    l_text:=l_text||'</address_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<template_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_template_id);
    l_text:=l_text||'</template_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_letter_file_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_offer_letter_file_type);
    l_text:=l_text||'</offer_letter_file_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<offer_letter_file_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_offer_letter_file_name);
    l_text:=l_text||'</offer_letter_file_name>';
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
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</offers>';
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
end update_offer_a;
end irc_offers_be2;

/
