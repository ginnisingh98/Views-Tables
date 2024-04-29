--------------------------------------------------------
--  DDL for Package Body IRC_PARTY_BE5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PARTY_BE5" as 
--Code generated on 30/08/2013 11:35:53
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_candidate_internal_a (
p_business_group_id            number,
p_last_name                    varchar2,
p_first_name                   varchar2,
p_date_of_birth                date,
p_email_address                varchar2,
p_title                        varchar2,
p_gender                       varchar2,
p_marital_status               varchar2,
p_previous_last_name           varchar2,
p_middle_name                  varchar2,
p_name_suffix                  varchar2,
p_known_as                     varchar2,
p_first_name_phonetic          varchar2,
p_last_name_phonetic           varchar2,
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
p_per_information_category     varchar2,
p_per_information1             varchar2,
p_per_information2             varchar2,
p_per_information3             varchar2,
p_per_information4             varchar2,
p_per_information5             varchar2,
p_per_information6             varchar2,
p_per_information7             varchar2,
p_per_information8             varchar2,
p_per_information9             varchar2,
p_per_information10            varchar2,
p_per_information11            varchar2,
p_per_information12            varchar2,
p_per_information13            varchar2,
p_per_information14            varchar2,
p_per_information15            varchar2,
p_per_information16            varchar2,
p_per_information17            varchar2,
p_per_information18            varchar2,
p_per_information19            varchar2,
p_per_information20            varchar2,
p_per_information21            varchar2,
p_per_information22            varchar2,
p_per_information23            varchar2,
p_per_information24            varchar2,
p_per_information25            varchar2,
p_per_information26            varchar2,
p_per_information27            varchar2,
p_per_information28            varchar2,
p_per_information29            varchar2,
p_per_information30            varchar2,
p_nationality                  varchar2,
p_national_identifier          varchar2,
p_town_of_birth                varchar2,
p_region_of_birth              varchar2,
p_country_of_birth             varchar2,
p_person_id                    number,
p_effective_start_date         date,
p_effective_end_date           date,
p_allow_access                 varchar2,
p_start_date                   date,
p_party_id                     varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  irc_party_be5.create_candidate_internal_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.irc.api.party.create_candidate_internal';
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
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<last_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_last_name);
    l_text:=l_text||'</last_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<first_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_first_name);
    l_text:=l_text||'</first_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_of_birth>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_of_birth);
    l_text:=l_text||'</date_of_birth>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<email_address>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_email_address);
    l_text:=l_text||'</email_address>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<title>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_title);
    l_text:=l_text||'</title>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<gender>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_gender);
    l_text:=l_text||'</gender>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<marital_status>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_marital_status);
    l_text:=l_text||'</marital_status>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<previous_last_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_previous_last_name);
    l_text:=l_text||'</previous_last_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<middle_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_middle_name);
    l_text:=l_text||'</middle_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<name_suffix>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_name_suffix);
    l_text:=l_text||'</name_suffix>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<known_as>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_known_as);
    l_text:=l_text||'</known_as>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<first_name_phonetic>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_first_name_phonetic);
    l_text:=l_text||'</first_name_phonetic>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<last_name_phonetic>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_last_name_phonetic);
    l_text:=l_text||'</last_name_phonetic>';
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
    l_text:='<per_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information_category);
    l_text:=l_text||'</per_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information1);
    l_text:=l_text||'</per_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information2);
    l_text:=l_text||'</per_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information3);
    l_text:=l_text||'</per_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information4);
    l_text:=l_text||'</per_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information5);
    l_text:=l_text||'</per_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information6);
    l_text:=l_text||'</per_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information7);
    l_text:=l_text||'</per_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information8);
    l_text:=l_text||'</per_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information9);
    l_text:=l_text||'</per_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information10);
    l_text:=l_text||'</per_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information11);
    l_text:=l_text||'</per_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information12);
    l_text:=l_text||'</per_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information13);
    l_text:=l_text||'</per_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information14);
    l_text:=l_text||'</per_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information15);
    l_text:=l_text||'</per_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information16);
    l_text:=l_text||'</per_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information17);
    l_text:=l_text||'</per_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information18);
    l_text:=l_text||'</per_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information19);
    l_text:=l_text||'</per_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information20);
    l_text:=l_text||'</per_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information21);
    l_text:=l_text||'</per_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information22);
    l_text:=l_text||'</per_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information23);
    l_text:=l_text||'</per_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information24);
    l_text:=l_text||'</per_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information25);
    l_text:=l_text||'</per_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information26);
    l_text:=l_text||'</per_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information27);
    l_text:=l_text||'</per_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information28);
    l_text:=l_text||'</per_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information29);
    l_text:=l_text||'</per_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_information30);
    l_text:=l_text||'</per_information30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<nationality>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_nationality);
    l_text:=l_text||'</nationality>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<national_identifier>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_national_identifier);
    l_text:=l_text||'</national_identifier>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<town_of_birth>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_town_of_birth);
    l_text:=l_text||'</town_of_birth>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<region_of_birth>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_region_of_birth);
    l_text:=l_text||'</region_of_birth>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<country_of_birth>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_country_of_birth);
    l_text:=l_text||'</country_of_birth>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_start_date);
    l_text:=l_text||'</effective_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_end_date);
    l_text:=l_text||'</effective_end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<allow_access>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_allow_access);
    l_text:=l_text||'</allow_access>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_start_date);
    l_text:=l_text||'</start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<party_id>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_party_id);
    l_text:=l_text||'</party_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</party>';
    --
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    if p_effective_start_date is not NULL and
       p_effective_start_date > trunc(SYSDATE) and
        fnd_profile.value('HR_DEFER_FD_BE_EVENTS') = 'Y' then 
       -- raise the event with the event data, with send date set to effective date
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_event_data=>l_event_data
                     ,p_send_date => p_effective_start_date);
        --
    else 
       -- raise the event with the event data
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_event_data=>l_event_data);
    end if;
  elsif (l_message='KEY') then
    hr_utility.set_location(l_proc,30);
    -- get a key for the event
    open get_seq;
    fetch get_seq into l_event_key;
    close get_seq;
    if p_effective_start_date is not NULL and
       p_effective_start_date > trunc(SYSDATE) and
        fnd_profile.value('HR_DEFER_FD_BE_EVENTS') = 'Y' then 
       -- this is a key event, so just raise the event
       -- without the event data, with send date set to effective date
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_send_date => p_effective_start_date);
       --
    else
       -- this is a key event, so just raise the event
       -- without the event data
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key);
    end if;
  elsif (l_message='NONE') then
    hr_utility.set_location(l_proc,40);
    -- no event is required, so do nothing
    null;
  end if;
    hr_utility.set_location('Leaving: '||l_proc,50);
end create_candidate_internal_a;
end irc_party_be5;

/
