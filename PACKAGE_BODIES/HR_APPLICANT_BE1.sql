--------------------------------------------------------
--  DDL for Package Body HR_APPLICANT_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPLICANT_BE1" as 
--Code generated on 30/08/2013 11:36:16
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_applicant_a (
p_date_received                date,
p_business_group_id            number,
p_last_name                    varchar2,
p_person_type_id               number,
p_applicant_number             varchar2,
p_per_comments                 varchar2,
p_date_employee_data_verified  date,
p_date_of_birth                date,
p_email_address                varchar2,
p_expense_check_send_to_addres varchar2,
p_first_name                   varchar2,
p_known_as                     varchar2,
p_marital_status               varchar2,
p_middle_names                 varchar2,
p_nationality                  varchar2,
p_national_identifier          varchar2,
p_previous_last_name           varchar2,
p_registered_disabled_flag     varchar2,
p_sex                          varchar2,
p_title                        varchar2,
p_work_telephone               varchar2,
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
p_background_check_status      varchar2,
p_background_date_check        date,
p_correspondence_language      varchar2,
p_fte_capacity                 number,
p_hold_applicant_date_until    date,
p_honors                       varchar2,
p_mailstop                     varchar2,
p_office_number                varchar2,
p_on_military_service          varchar2,
p_pre_name_adjunct             varchar2,
p_projected_start_date         date,
p_resume_exists                varchar2,
p_resume_last_updated          date,
p_student_status               varchar2,
p_work_schedule                varchar2,
p_suffix                       varchar2,
p_date_of_death                date,
p_benefit_group_id             number,
p_receipt_of_death_cert_date   date,
p_coord_ben_med_pln_no         varchar2,
p_coord_ben_no_cvg_flag        varchar2,
p_uses_tobacco_flag            varchar2,
p_dpdnt_adoption_date          date,
p_dpdnt_vlntry_svce_flag       varchar2,
p_original_date_of_hire        date,
p_person_id                    number,
p_assignment_id                number,
p_application_id               number,
p_per_object_version_number    number,
p_asg_object_version_number    number,
p_apl_object_version_number    number,
p_per_effective_start_date     date,
p_per_effective_end_date       date,
p_full_name                    varchar2,
p_per_comment_id               number,
p_assignment_sequence          number,
p_name_combination_warning     boolean,
p_orig_hire_warning            boolean,
p_town_of_birth                varchar2,
p_region_of_birth              varchar2,
p_country_of_birth             varchar2,
p_global_person_id             varchar2,
p_party_id                     varchar2,
p_vacancy_id                   number) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_applicant_be1.create_applicant_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.applicant.create_applicant';
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
    l_text:='<applicant>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<date_received>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_received);
    l_text:=l_text||'</date_received>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<last_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_last_name);
    l_text:=l_text||'</last_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_type_id);
    l_text:=l_text||'</person_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<applicant_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_applicant_number);
    l_text:=l_text||'</applicant_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_per_comments);
    l_text:=l_text||'</per_comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_employee_data_verified>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_employee_data_verified);
    l_text:=l_text||'</date_employee_data_verified>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_of_birth>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_of_birth);
    l_text:=l_text||'</date_of_birth>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<email_address>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_email_address);
    l_text:=l_text||'</email_address>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<expense_check_send_to_addres>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_expense_check_send_to_addres);
    l_text:=l_text||'</expense_check_send_to_addres>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<first_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_first_name);
    l_text:=l_text||'</first_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<known_as>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_known_as);
    l_text:=l_text||'</known_as>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<marital_status>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_marital_status);
    l_text:=l_text||'</marital_status>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<middle_names>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_middle_names);
    l_text:=l_text||'</middle_names>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<nationality>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_nationality);
    l_text:=l_text||'</nationality>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<national_identifier>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_national_identifier);
    l_text:=l_text||'</national_identifier>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<previous_last_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_previous_last_name);
    l_text:=l_text||'</previous_last_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<registered_disabled_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_registered_disabled_flag);
    l_text:=l_text||'</registered_disabled_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<sex>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_sex);
    l_text:=l_text||'</sex>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<title>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_title);
    l_text:=l_text||'</title>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<work_telephone>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_work_telephone);
    l_text:=l_text||'</work_telephone>';
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
    l_text:='<background_check_status>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_background_check_status);
    l_text:=l_text||'</background_check_status>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<background_date_check>';
    l_text:=l_text||fnd_date.date_to_canonical(p_background_date_check);
    l_text:=l_text||'</background_date_check>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<correspondence_language>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_correspondence_language);
    l_text:=l_text||'</correspondence_language>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<fte_capacity>';
    l_text:=l_text||fnd_number.number_to_canonical(p_fte_capacity);
    l_text:=l_text||'</fte_capacity>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<hold_applicant_date_until>';
    l_text:=l_text||fnd_date.date_to_canonical(p_hold_applicant_date_until);
    l_text:=l_text||'</hold_applicant_date_until>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<honors>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_honors);
    l_text:=l_text||'</honors>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<mailstop>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_mailstop);
    l_text:=l_text||'</mailstop>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<office_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_office_number);
    l_text:=l_text||'</office_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<on_military_service>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_on_military_service);
    l_text:=l_text||'</on_military_service>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pre_name_adjunct>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pre_name_adjunct);
    l_text:=l_text||'</pre_name_adjunct>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<projected_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_projected_start_date);
    l_text:=l_text||'</projected_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<resume_exists>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_resume_exists);
    l_text:=l_text||'</resume_exists>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<resume_last_updated>';
    l_text:=l_text||fnd_date.date_to_canonical(p_resume_last_updated);
    l_text:=l_text||'</resume_last_updated>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<student_status>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_student_status);
    l_text:=l_text||'</student_status>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<work_schedule>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_work_schedule);
    l_text:=l_text||'</work_schedule>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<suffix>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_suffix);
    l_text:=l_text||'</suffix>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_of_death>';
    l_text:=l_text||fnd_date.date_to_canonical(p_date_of_death);
    l_text:=l_text||'</date_of_death>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<benefit_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_benefit_group_id);
    l_text:=l_text||'</benefit_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<receipt_of_death_cert_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_receipt_of_death_cert_date);
    l_text:=l_text||'</receipt_of_death_cert_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<coord_ben_med_pln_no>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_coord_ben_med_pln_no);
    l_text:=l_text||'</coord_ben_med_pln_no>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<coord_ben_no_cvg_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_coord_ben_no_cvg_flag);
    l_text:=l_text||'</coord_ben_no_cvg_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<uses_tobacco_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_uses_tobacco_flag);
    l_text:=l_text||'</uses_tobacco_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dpdnt_adoption_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_dpdnt_adoption_date);
    l_text:=l_text||'</dpdnt_adoption_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<dpdnt_vlntry_svce_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_dpdnt_vlntry_svce_flag);
    l_text:=l_text||'</dpdnt_vlntry_svce_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<original_date_of_hire>';
    l_text:=l_text||fnd_date.date_to_canonical(p_original_date_of_hire);
    l_text:=l_text||'</original_date_of_hire>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_id);
    l_text:=l_text||'</assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<application_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_application_id);
    l_text:=l_text||'</application_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_per_object_version_number);
    l_text:=l_text||'</per_object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<asg_object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_asg_object_version_number);
    l_text:=l_text||'</asg_object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<apl_object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_apl_object_version_number);
    l_text:=l_text||'</apl_object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_effective_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_per_effective_start_date);
    l_text:=l_text||'</per_effective_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_effective_end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_per_effective_end_date);
    l_text:=l_text||'</per_effective_end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<full_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_full_name);
    l_text:=l_text||'</full_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<per_comment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_per_comment_id);
    l_text:=l_text||'</per_comment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_sequence>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_sequence);
    l_text:=l_text||'</assignment_sequence>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<name_combination_warning>';
if(P_NAME_COMBINATION_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</name_combination_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<orig_hire_warning>';
if(P_ORIG_HIRE_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</orig_hire_warning>';
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
    l_text:='<global_person_id>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_global_person_id);
    l_text:=l_text||'</global_person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<party_id>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_party_id);
    l_text:=l_text||'</party_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<vacancy_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_vacancy_id);
    l_text:=l_text||'</vacancy_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</applicant>';
    --
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    if p_per_effective_start_date is not NULL and
       p_per_effective_start_date > trunc(SYSDATE) and
        fnd_profile.value('HR_DEFER_FD_BE_EVENTS') = 'Y' then 
       -- raise the event with the event data, with send date set to effective date
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_event_data=>l_event_data
                     ,p_send_date => p_per_effective_start_date);
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
    if p_per_effective_start_date is not NULL and
       p_per_effective_start_date > trunc(SYSDATE) and
        fnd_profile.value('HR_DEFER_FD_BE_EVENTS') = 'Y' then 
       -- this is a key event, so just raise the event
       -- without the event data, with send date set to effective date
       wf_event.raise(p_event_name=>l_event_name
                     ,p_event_key=>l_event_key
                     ,p_send_date => p_per_effective_start_date);
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
end create_applicant_a;
end hr_applicant_be1;

/
