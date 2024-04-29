--------------------------------------------------------
--  DDL for Package Body HR_DOCUMENT_EXTRA_INFO_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DOCUMENT_EXTRA_INFO_BE2" as 
--Code generated on 30/08/2013 11:36:16
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_doc_extra_info_a (
p_document_extra_info_id       number,
p_person_id                    number,
p_document_type_id             number,
p_date_from                    date,
p_date_to                      date,
p_document_number              varchar2,
p_issued_by                    varchar2,
p_issued_at                    varchar2,
p_issued_date                  date,
p_issuing_authority            varchar2,
p_verified_by                  number,
p_verified_date                date,
p_related_object_name          varchar2,
p_related_object_id_col        varchar2,
p_related_object_id            number,
p_dei_attribute_category       varchar2,
p_dei_attribute1               varchar2,
p_dei_attribute2               varchar2,
p_dei_attribute3               varchar2,
p_dei_attribute4               varchar2,
p_dei_attribute5               varchar2,
p_dei_attribute6               varchar2,
p_dei_attribute7               varchar2,
p_dei_attribute8               varchar2,
p_dei_attribute9               varchar2,
p_dei_attribute10              varchar2,
p_dei_attribute11              varchar2,
p_dei_attribute12              varchar2,
p_dei_attribute13              varchar2,
p_dei_attribute14              varchar2,
p_dei_attribute15              varchar2,
p_dei_attribute16              varchar2,
p_dei_attribute17              varchar2,
p_dei_attribute18              varchar2,
p_dei_attribute19              varchar2,
p_dei_attribute20              varchar2,
p_dei_attribute21              varchar2,
p_dei_attribute22              varchar2,
p_dei_attribute23              varchar2,
p_dei_attribute24              varchar2,
p_dei_attribute25              varchar2,
p_dei_attribute26              varchar2,
p_dei_attribute27              varchar2,
p_dei_attribute28              varchar2,
p_dei_attribute29              varchar2,
p_dei_attribute30              varchar2,
p_dei_information_category     varchar2,
p_dei_information1             varchar2,
p_dei_information2             varchar2,
p_dei_information3             varchar2,
p_dei_information4             varchar2,
p_dei_information5             varchar2,
p_dei_information6             varchar2,
p_dei_information7             varchar2,
p_dei_information8             varchar2,
p_dei_information9             varchar2,
p_dei_information10            varchar2,
p_dei_information11            varchar2,
p_dei_information12            varchar2,
p_dei_information13            varchar2,
p_dei_information14            varchar2,
p_dei_information15            varchar2,
p_dei_information16            varchar2,
p_dei_information17            varchar2,
p_dei_information18            varchar2,
p_dei_information19            varchar2,
p_dei_information20            varchar2,
p_dei_information21            varchar2,
p_dei_information22            varchar2,
p_dei_information23            varchar2,
p_dei_information24            varchar2,
p_dei_information25            varchar2,
p_dei_information26            varchar2,
p_dei_information27            varchar2,
p_dei_information28            varchar2,
p_dei_information29            varchar2,
p_dei_information30            varchar2,
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
  l_proc varchar2(72):='  hr_document_extra_info_be2.update_doc_extra_info_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.document_extra_info.update_doc_extra_info';
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
    l_text:='<document_extra_info>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<document_extra_info_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_document_extra_info_id);
    l_text:=l_text||'</document_extra_info_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<document_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_document_type_id);
    l_text:=l_text||'</document_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_from>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_from);
    l_text:=l_text||'</date_from>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_to>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_to);
    l_text:=l_text||'</date_to>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<document_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_document_number);
    l_text:=l_text||'</document_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<issued_by>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_issued_by);
    l_text:=l_text||'</issued_by>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<issued_at>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_issued_at);
    l_text:=l_text||'</issued_at>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<issued_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_issued_date);
    l_text:=l_text||'</issued_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<issuing_authority>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_issuing_authority);
    l_text:=l_text||'</issuing_authority>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<verified_by>';
    l_text:=l_text||fnd_number.number_to_canonical(p_verified_by);
    l_text:=l_text||'</verified_by>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<verified_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_verified_date);
    l_text:=l_text||'</verified_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<related_object_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_related_object_name);
    l_text:=l_text||'</related_object_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<related_object_id_col>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_related_object_id_col);
    l_text:=l_text||'</related_object_id_col>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<related_object_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_related_object_id);
    l_text:=l_text||'</related_object_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute_category);
    l_text:=l_text||'</dei_attribute_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute1);
    l_text:=l_text||'</dei_attribute1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute2);
    l_text:=l_text||'</dei_attribute2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute3);
    l_text:=l_text||'</dei_attribute3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute4);
    l_text:=l_text||'</dei_attribute4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute5);
    l_text:=l_text||'</dei_attribute5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute6);
    l_text:=l_text||'</dei_attribute6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute7);
    l_text:=l_text||'</dei_attribute7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute8);
    l_text:=l_text||'</dei_attribute8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute9);
    l_text:=l_text||'</dei_attribute9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute10);
    l_text:=l_text||'</dei_attribute10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute11);
    l_text:=l_text||'</dei_attribute11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute12);
    l_text:=l_text||'</dei_attribute12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute13);
    l_text:=l_text||'</dei_attribute13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute14);
    l_text:=l_text||'</dei_attribute14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute15);
    l_text:=l_text||'</dei_attribute15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute16);
    l_text:=l_text||'</dei_attribute16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute17);
    l_text:=l_text||'</dei_attribute17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute18);
    l_text:=l_text||'</dei_attribute18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute19);
    l_text:=l_text||'</dei_attribute19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute20);
    l_text:=l_text||'</dei_attribute20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute21);
    l_text:=l_text||'</dei_attribute21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute22);
    l_text:=l_text||'</dei_attribute22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute23);
    l_text:=l_text||'</dei_attribute23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute24);
    l_text:=l_text||'</dei_attribute24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute25);
    l_text:=l_text||'</dei_attribute25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute26);
    l_text:=l_text||'</dei_attribute26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute27);
    l_text:=l_text||'</dei_attribute27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute28);
    l_text:=l_text||'</dei_attribute28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute29);
    l_text:=l_text||'</dei_attribute29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_attribute30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_attribute30);
    l_text:=l_text||'</dei_attribute30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information_category);
    l_text:=l_text||'</dei_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information1);
    l_text:=l_text||'</dei_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information2);
    l_text:=l_text||'</dei_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information3);
    l_text:=l_text||'</dei_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information4);
    l_text:=l_text||'</dei_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information5);
    l_text:=l_text||'</dei_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information6);
    l_text:=l_text||'</dei_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information7);
    l_text:=l_text||'</dei_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information8);
    l_text:=l_text||'</dei_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information9);
    l_text:=l_text||'</dei_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information10);
    l_text:=l_text||'</dei_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information11);
    l_text:=l_text||'</dei_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information12);
    l_text:=l_text||'</dei_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information13);
    l_text:=l_text||'</dei_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information14);
    l_text:=l_text||'</dei_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information15);
    l_text:=l_text||'</dei_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information16);
    l_text:=l_text||'</dei_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information17);
    l_text:=l_text||'</dei_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information18);
    l_text:=l_text||'</dei_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information19);
    l_text:=l_text||'</dei_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information20);
    l_text:=l_text||'</dei_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information21);
    l_text:=l_text||'</dei_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information22);
    l_text:=l_text||'</dei_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information23);
    l_text:=l_text||'</dei_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information24);
    l_text:=l_text||'</dei_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information25);
    l_text:=l_text||'</dei_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information26);
    l_text:=l_text||'</dei_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information27);
    l_text:=l_text||'</dei_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information28);
    l_text:=l_text||'</dei_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information29);
    l_text:=l_text||'</dei_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dei_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dei_information30);
    l_text:=l_text||'</dei_information30>';
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
    l_text:='</document_extra_info>';
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
end update_doc_extra_info_a;
end hr_document_extra_info_be2;

/
