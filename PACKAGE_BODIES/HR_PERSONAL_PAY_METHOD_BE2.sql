--------------------------------------------------------
--  DDL for Package Body HR_PERSONAL_PAY_METHOD_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSONAL_PAY_METHOD_BE2" as 
--Code generated on 30/08/2013 11:36:15
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_personal_pay_method_a (
p_effective_date               date,
p_datetrack_update_mode        varchar2,
p_personal_payment_method_id   number,
p_object_version_number        number,
p_amount                       number,
p_comments                     varchar2,
p_percentage                   number,
p_priority                     number,
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
p_territory_code               varchar2,
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
p_payee_type                   varchar2,
p_payee_id                     number,
p_comment_id                   number,
p_external_account_id          number,
p_effective_start_date         date,
p_effective_end_date           date,
p_ppm_information1             varchar2,
p_ppm_information2             varchar2,
p_ppm_information3             varchar2,
p_ppm_information4             varchar2,
p_ppm_information5             varchar2,
p_ppm_information6             varchar2,
p_ppm_information7             varchar2,
p_ppm_information8             varchar2,
p_ppm_information9             varchar2,
p_ppm_information10            varchar2,
p_ppm_information11            varchar2,
p_ppm_information12            varchar2,
p_ppm_information13            varchar2,
p_ppm_information14            varchar2,
p_ppm_information15            varchar2,
p_ppm_information16            varchar2,
p_ppm_information17            varchar2,
p_ppm_information18            varchar2,
p_ppm_information19            varchar2,
p_ppm_information20            varchar2,
p_ppm_information21            varchar2,
p_ppm_information22            varchar2,
p_ppm_information23            varchar2,
p_ppm_information24            varchar2,
p_ppm_information25            varchar2,
p_ppm_information26            varchar2,
p_ppm_information27            varchar2,
p_ppm_information28            varchar2,
p_ppm_information29            varchar2,
p_ppm_information30            varchar2,
p_ppm_information_category     varchar2) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_personal_pay_method_be2.update_personal_pay_method_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.personal_pay_method.update_personal_pay_method';
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
    l_text:='<personal_pay_method>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<datetrack_update_mode>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_datetrack_update_mode);
    l_text:=l_text||'</datetrack_update_mode>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<personal_payment_method_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_personal_payment_method_id);
    l_text:=l_text||'</personal_payment_method_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<amount>';
    l_text:=l_text||fnd_number.number_to_canonical(p_amount);
    l_text:=l_text||'</amount>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<percentage>';
    l_text:=l_text||fnd_number.number_to_canonical(p_percentage);
    l_text:=l_text||'</percentage>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<priority>';
    l_text:=l_text||fnd_number.number_to_canonical(p_priority);
    l_text:=l_text||'</priority>';
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
    l_text:='<territory_code>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_territory_code);
    l_text:=l_text||'</territory_code>';
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
    l_text:='<payee_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_payee_type);
    l_text:=l_text||'</payee_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<payee_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_payee_id);
    l_text:=l_text||'</payee_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_comment_id);
    l_text:=l_text||'</comment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<external_account_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_external_account_id);
    l_text:=l_text||'</external_account_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_start_date);
    l_text:=l_text||'</effective_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_end_date);
    l_text:=l_text||'</effective_end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information1);
    l_text:=l_text||'</ppm_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information2);
    l_text:=l_text||'</ppm_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information3);
    l_text:=l_text||'</ppm_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information4);
    l_text:=l_text||'</ppm_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information5);
    l_text:=l_text||'</ppm_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information6);
    l_text:=l_text||'</ppm_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information7);
    l_text:=l_text||'</ppm_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information8);
    l_text:=l_text||'</ppm_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information9);
    l_text:=l_text||'</ppm_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information10);
    l_text:=l_text||'</ppm_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information11);
    l_text:=l_text||'</ppm_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information12);
    l_text:=l_text||'</ppm_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information13);
    l_text:=l_text||'</ppm_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information14);
    l_text:=l_text||'</ppm_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information15);
    l_text:=l_text||'</ppm_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information16);
    l_text:=l_text||'</ppm_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information17);
    l_text:=l_text||'</ppm_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information18);
    l_text:=l_text||'</ppm_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information19);
    l_text:=l_text||'</ppm_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information20);
    l_text:=l_text||'</ppm_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information21);
    l_text:=l_text||'</ppm_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information22);
    l_text:=l_text||'</ppm_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information23);
    l_text:=l_text||'</ppm_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information24);
    l_text:=l_text||'</ppm_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information25);
    l_text:=l_text||'</ppm_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information26);
    l_text:=l_text||'</ppm_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information27);
    l_text:=l_text||'</ppm_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information28);
    l_text:=l_text||'</ppm_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information29);
    l_text:=l_text||'</ppm_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information30);
    l_text:=l_text||'</ppm_information30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<ppm_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_ppm_information_category);
    l_text:=l_text||'</ppm_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</personal_pay_method>';
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
end update_personal_pay_method_a;
end hr_personal_pay_method_be2;

/
