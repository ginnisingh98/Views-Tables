--------------------------------------------------------
--  DDL for Package Body HR_LOCATION_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOCATION_BE2" as 
--Code generated on 30/08/2013 11:36:16
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_location_a (
p_effective_date               date,
p_language_code                varchar2,
p_location_id                  number,
p_location_code                varchar2,
p_description                  varchar2,
p_timezone_code                varchar2,
p_tp_header_id                 number,
p_ece_tp_location_code         varchar2,
p_address_line_1               varchar2,
p_address_line_2               varchar2,
p_address_line_3               varchar2,
p_bill_to_site_flag            varchar2,
p_country                      varchar2,
p_designated_receiver_id       number,
p_in_organization_flag         varchar2,
p_inactive_date                date,
p_operating_unit_id            number,
p_inventory_organization_id    number,
p_office_site_flag             varchar2,
p_postal_code                  varchar2,
p_receiving_site_flag          varchar2,
p_region_1                     varchar2,
p_region_2                     varchar2,
p_region_3                     varchar2,
p_ship_to_location_id          number,
p_ship_to_site_flag            varchar2,
p_style                        varchar2,
p_tax_name                     varchar2,
p_telephone_number_1           varchar2,
p_telephone_number_2           varchar2,
p_telephone_number_3           varchar2,
p_town_or_city                 varchar2,
p_loc_information13            varchar2,
p_loc_information14            varchar2,
p_loc_information15            varchar2,
p_loc_information16            varchar2,
p_loc_information17            varchar2,
p_loc_information18            varchar2,
p_loc_information19            varchar2,
p_loc_information20            varchar2,
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
p_global_attribute_category    varchar2,
p_global_attribute1            varchar2,
p_global_attribute2            varchar2,
p_global_attribute3            varchar2,
p_global_attribute4            varchar2,
p_global_attribute5            varchar2,
p_global_attribute6            varchar2,
p_global_attribute7            varchar2,
p_global_attribute8            varchar2,
p_global_attribute9            varchar2,
p_global_attribute10           varchar2,
p_global_attribute11           varchar2,
p_global_attribute12           varchar2,
p_global_attribute13           varchar2,
p_global_attribute14           varchar2,
p_global_attribute15           varchar2,
p_global_attribute16           varchar2,
p_global_attribute17           varchar2,
p_global_attribute18           varchar2,
p_global_attribute19           varchar2,
p_global_attribute20           varchar2,
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
  l_proc varchar2(72):='  hr_location_be2.update_location_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.location.update_location';
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
    l_text:='<location>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<language_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_language_code);
    l_text:=l_text||'</language_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<location_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_location_id);
    l_text:=l_text||'</location_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<location_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_location_code);
    l_text:=l_text||'</location_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_description);
    l_text:=l_text||'</description>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<timezone_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_timezone_code);
    l_text:=l_text||'</timezone_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tp_header_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_tp_header_id);
    l_text:=l_text||'</tp_header_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ece_tp_location_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ece_tp_location_code);
    l_text:=l_text||'</ece_tp_location_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<address_line_1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_address_line_1);
    l_text:=l_text||'</address_line_1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<address_line_2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_address_line_2);
    l_text:=l_text||'</address_line_2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<address_line_3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_address_line_3);
    l_text:=l_text||'</address_line_3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<bill_to_site_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_bill_to_site_flag);
    l_text:=l_text||'</bill_to_site_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<country>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_country);
    l_text:=l_text||'</country>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<designated_receiver_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_designated_receiver_id);
    l_text:=l_text||'</designated_receiver_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<in_organization_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_in_organization_flag);
    l_text:=l_text||'</in_organization_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<inactive_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_inactive_date);
    l_text:=l_text||'</inactive_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<operating_unit_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_operating_unit_id);
    l_text:=l_text||'</operating_unit_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<inventory_organization_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_inventory_organization_id);
    l_text:=l_text||'</inventory_organization_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<office_site_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_office_site_flag);
    l_text:=l_text||'</office_site_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<postal_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_postal_code);
    l_text:=l_text||'</postal_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<receiving_site_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_receiving_site_flag);
    l_text:=l_text||'</receiving_site_flag>';
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
    l_text:='<ship_to_location_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_ship_to_location_id);
    l_text:=l_text||'</ship_to_location_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ship_to_site_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ship_to_site_flag);
    l_text:=l_text||'</ship_to_site_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<style>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_style);
    l_text:=l_text||'</style>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<tax_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_tax_name);
    l_text:=l_text||'</tax_name>';
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
    l_text:='<town_or_city>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_town_or_city);
    l_text:=l_text||'</town_or_city>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<loc_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_loc_information13);
    l_text:=l_text||'</loc_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<loc_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_loc_information14);
    l_text:=l_text||'</loc_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<loc_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_loc_information15);
    l_text:=l_text||'</loc_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<loc_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_loc_information16);
    l_text:=l_text||'</loc_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<loc_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_loc_information17);
    l_text:=l_text||'</loc_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<loc_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_loc_information18);
    l_text:=l_text||'</loc_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<loc_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_loc_information19);
    l_text:=l_text||'</loc_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<loc_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_loc_information20);
    l_text:=l_text||'</loc_information20>';
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
    l_text:='<global_attribute_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute_category);
    l_text:=l_text||'</global_attribute_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute1);
    l_text:=l_text||'</global_attribute1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute2);
    l_text:=l_text||'</global_attribute2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute3);
    l_text:=l_text||'</global_attribute3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute4);
    l_text:=l_text||'</global_attribute4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute5);
    l_text:=l_text||'</global_attribute5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute6);
    l_text:=l_text||'</global_attribute6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute7);
    l_text:=l_text||'</global_attribute7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute8);
    l_text:=l_text||'</global_attribute8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute9);
    l_text:=l_text||'</global_attribute9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute10);
    l_text:=l_text||'</global_attribute10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute11);
    l_text:=l_text||'</global_attribute11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute12);
    l_text:=l_text||'</global_attribute12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute13);
    l_text:=l_text||'</global_attribute13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute14);
    l_text:=l_text||'</global_attribute14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute15);
    l_text:=l_text||'</global_attribute15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute16);
    l_text:=l_text||'</global_attribute16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute17);
    l_text:=l_text||'</global_attribute17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute18);
    l_text:=l_text||'</global_attribute18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute19);
    l_text:=l_text||'</global_attribute19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<global_attribute20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_attribute20);
    l_text:=l_text||'</global_attribute20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</location>';
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
end update_location_a;
end hr_location_be2;

/
