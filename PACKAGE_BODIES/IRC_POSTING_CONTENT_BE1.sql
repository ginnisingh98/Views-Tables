--------------------------------------------------------
--  DDL for Package Body IRC_POSTING_CONTENT_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_POSTING_CONTENT_BE1" as 
--Code generated on 29/08/2013 09:58:18
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_posting_content_a (
p_display_manager_info         varchar2,
p_display_recruiter_info       varchar2,
p_language_code                varchar2,
p_name                         varchar2,
p_org_name                     varchar2,
p_org_description              varchar2,
p_job_title                    varchar2,
p_brief_description            varchar2,
p_detailed_description         varchar2,
p_job_requirements             varchar2,
p_additional_details           varchar2,
p_how_to_apply                 varchar2,
p_benefit_info                 varchar2,
p_image_url                    varchar2,
p_alt_image_url                varchar2,
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
p_ipc_information_category     varchar2,
p_ipc_information1             varchar2,
p_ipc_information2             varchar2,
p_ipc_information3             varchar2,
p_ipc_information4             varchar2,
p_ipc_information5             varchar2,
p_ipc_information6             varchar2,
p_ipc_information7             varchar2,
p_ipc_information8             varchar2,
p_ipc_information9             varchar2,
p_ipc_information10            varchar2,
p_ipc_information11            varchar2,
p_ipc_information12            varchar2,
p_ipc_information13            varchar2,
p_ipc_information14            varchar2,
p_ipc_information15            varchar2,
p_ipc_information16            varchar2,
p_ipc_information17            varchar2,
p_ipc_information18            varchar2,
p_ipc_information19            varchar2,
p_ipc_information20            varchar2,
p_ipc_information21            varchar2,
p_ipc_information22            varchar2,
p_ipc_information23            varchar2,
p_ipc_information24            varchar2,
p_ipc_information25            varchar2,
p_ipc_information26            varchar2,
p_ipc_information27            varchar2,
p_ipc_information28            varchar2,
p_ipc_information29            varchar2,
p_ipc_information30            varchar2,
p_posting_content_id           number,
p_object_version_number        number,
p_date_approved                date) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  irc_posting_content_be1.create_posting_content_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.irc.api.posting_content.create_posting_content';
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
    l_text:='<posting_content>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<display_manager_info>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_display_manager_info);
    l_text:=l_text||'</display_manager_info>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<display_recruiter_info>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_display_recruiter_info);
    l_text:=l_text||'</display_recruiter_info>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<language_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_language_code);
    l_text:=l_text||'</language_code>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_name);
    l_text:=l_text||'</name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_name);
    l_text:=l_text||'</org_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<org_description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_org_description);
    l_text:=l_text||'</org_description>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<job_title>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_job_title);
    l_text:=l_text||'</job_title>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<brief_description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_brief_description);
    l_text:=l_text||'</brief_description>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<detailed_description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_detailed_description);
    l_text:=l_text||'</detailed_description>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<job_requirements>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_job_requirements);
    l_text:=l_text||'</job_requirements>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<additional_details>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_additional_details);
    l_text:=l_text||'</additional_details>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<how_to_apply>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_how_to_apply);
    l_text:=l_text||'</how_to_apply>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<benefit_info>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_benefit_info);
    l_text:=l_text||'</benefit_info>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<image_url>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_image_url);
    l_text:=l_text||'</image_url>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<alt_image_url>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_alt_image_url);
    l_text:=l_text||'</alt_image_url>';
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
    l_text:='<ipc_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information_category);
    l_text:=l_text||'</ipc_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information1);
    l_text:=l_text||'</ipc_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information2);
    l_text:=l_text||'</ipc_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information3);
    l_text:=l_text||'</ipc_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information4);
    l_text:=l_text||'</ipc_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information5);
    l_text:=l_text||'</ipc_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information6);
    l_text:=l_text||'</ipc_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information7);
    l_text:=l_text||'</ipc_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information8);
    l_text:=l_text||'</ipc_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information9);
    l_text:=l_text||'</ipc_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information10);
    l_text:=l_text||'</ipc_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information11);
    l_text:=l_text||'</ipc_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information12);
    l_text:=l_text||'</ipc_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information13);
    l_text:=l_text||'</ipc_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information14);
    l_text:=l_text||'</ipc_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information15);
    l_text:=l_text||'</ipc_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information16);
    l_text:=l_text||'</ipc_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information17);
    l_text:=l_text||'</ipc_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information18);
    l_text:=l_text||'</ipc_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information19);
    l_text:=l_text||'</ipc_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information20);
    l_text:=l_text||'</ipc_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information21);
    l_text:=l_text||'</ipc_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information22);
    l_text:=l_text||'</ipc_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information23);
    l_text:=l_text||'</ipc_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information24);
    l_text:=l_text||'</ipc_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information25);
    l_text:=l_text||'</ipc_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information26);
    l_text:=l_text||'</ipc_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information27);
    l_text:=l_text||'</ipc_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information28);
    l_text:=l_text||'</ipc_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information29);
    l_text:=l_text||'</ipc_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ipc_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ipc_information30);
    l_text:=l_text||'</ipc_information30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<posting_content_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_posting_content_id);
    l_text:=l_text||'</posting_content_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_approved>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_approved);
    l_text:=l_text||'</date_approved>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</posting_content>';
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
end create_posting_content_a;
end irc_posting_content_be1;

/
