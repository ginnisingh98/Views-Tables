--------------------------------------------------------
--  DDL for Package Body HR_PERSON_ADDRESS_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_ADDRESS_BE3" as 
--Code generated on 30/08/2013 11:36:16
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_pers_addr_with_style_a (
p_effective_date               date,
p_validate_county              boolean,
p_address_id                   number,
p_object_version_number        number,
p_date_from                    date,
p_date_to                      date,
p_address_type                 varchar2,
p_comments                     long,
p_address_line1                varchar2,
p_address_line2                varchar2,
p_address_line3                varchar2,
p_town_or_city                 varchar2,
p_region_1                     varchar2,
p_region_2                     varchar2,
p_region_3                     varchar2,
p_postal_code                  varchar2,
p_country                      varchar2,
p_telephone_number_1           varchar2,
p_telephone_number_2           varchar2,
p_telephone_number_3           varchar2,
p_addr_attribute_category      varchar2,
p_addr_attribute1              varchar2,
p_addr_attribute2              varchar2,
p_addr_attribute3              varchar2,
p_addr_attribute4              varchar2,
p_addr_attribute5              varchar2,
p_addr_attribute6              varchar2,
p_addr_attribute7              varchar2,
p_addr_attribute8              varchar2,
p_addr_attribute9              varchar2,
p_addr_attribute10             varchar2,
p_addr_attribute11             varchar2,
p_addr_attribute12             varchar2,
p_addr_attribute13             varchar2,
p_addr_attribute14             varchar2,
p_addr_attribute15             varchar2,
p_addr_attribute16             varchar2,
p_addr_attribute17             varchar2,
p_addr_attribute18             varchar2,
p_addr_attribute19             varchar2,
p_addr_attribute20             varchar2,
p_add_information13            varchar2,
p_add_information14            varchar2,
p_add_information15            varchar2,
p_add_information16            varchar2,
p_add_information17            varchar2,
p_add_information18            varchar2,
p_add_information19            varchar2,
p_add_information20            varchar2,
p_style                        varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_person_address_be3.update_pers_addr_with_style_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.person_address.update_pers_addr_with_style';
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
    l_text:='<person_address>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<validate_county>';
if(P_VALIDATE_COUNTY) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</validate_county>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<address_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_address_id);
    l_text:=l_text||'</address_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_from>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_from);
    l_text:=l_text||'</date_from>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_to>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_to);
    l_text:=l_text||'</date_to>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<address_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_address_type);
    l_text:=l_text||'</address_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<address_line1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_address_line1);
    l_text:=l_text||'</address_line1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<address_line2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_address_line2);
    l_text:=l_text||'</address_line2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<address_line3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_address_line3);
    l_text:=l_text||'</address_line3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<town_or_city>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_town_or_city);
    l_text:=l_text||'</town_or_city>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<region_1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_region_1);
    l_text:=l_text||'</region_1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<region_2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_region_2);
    l_text:=l_text||'</region_2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<region_3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_region_3);
    l_text:=l_text||'</region_3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<postal_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_postal_code);
    l_text:=l_text||'</postal_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<country>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_country);
    l_text:=l_text||'</country>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<telephone_number_1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_telephone_number_1);
    l_text:=l_text||'</telephone_number_1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<telephone_number_2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_telephone_number_2);
    l_text:=l_text||'</telephone_number_2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<telephone_number_3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_telephone_number_3);
    l_text:=l_text||'</telephone_number_3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute_category);
    l_text:=l_text||'</addr_attribute_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute1);
    l_text:=l_text||'</addr_attribute1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute2);
    l_text:=l_text||'</addr_attribute2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute3);
    l_text:=l_text||'</addr_attribute3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute4);
    l_text:=l_text||'</addr_attribute4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute5);
    l_text:=l_text||'</addr_attribute5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute6);
    l_text:=l_text||'</addr_attribute6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute7);
    l_text:=l_text||'</addr_attribute7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute8);
    l_text:=l_text||'</addr_attribute8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute9);
    l_text:=l_text||'</addr_attribute9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute10);
    l_text:=l_text||'</addr_attribute10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute11);
    l_text:=l_text||'</addr_attribute11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute12);
    l_text:=l_text||'</addr_attribute12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute13);
    l_text:=l_text||'</addr_attribute13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute14);
    l_text:=l_text||'</addr_attribute14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute15);
    l_text:=l_text||'</addr_attribute15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute16);
    l_text:=l_text||'</addr_attribute16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute17);
    l_text:=l_text||'</addr_attribute17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute18);
    l_text:=l_text||'</addr_attribute18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute19);
    l_text:=l_text||'</addr_attribute19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<addr_attribute20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_addr_attribute20);
    l_text:=l_text||'</addr_attribute20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<add_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_add_information13);
    l_text:=l_text||'</add_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<add_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_add_information14);
    l_text:=l_text||'</add_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<add_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_add_information15);
    l_text:=l_text||'</add_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<add_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_add_information16);
    l_text:=l_text||'</add_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<add_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_add_information17);
    l_text:=l_text||'</add_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<add_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_add_information18);
    l_text:=l_text||'</add_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<add_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_add_information19);
    l_text:=l_text||'</add_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<add_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_add_information20);
    l_text:=l_text||'</add_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<style>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_style);
    l_text:=l_text||'</style>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</person_address>';
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
end update_pers_addr_with_style_a;
end hr_person_address_be3;

/
