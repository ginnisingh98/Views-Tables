--------------------------------------------------------
--  DDL for Package Body IRC_SEARCH_CRITERIA_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_SEARCH_CRITERIA_BE1" as 
--Code generated on 29/08/2013 09:58:19
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_saved_search_a (
p_effective_date               date,
p_search_criteria_id           number,
p_person_id                    number,
p_search_name                  varchar2,
p_location                     varchar2,
p_distance_to_location         varchar2,
p_geocode_location             varchar2,
p_geocode_country              varchar2,
p_derived_location             varchar2,
p_location_id                  number,
p_longitude                    number,
p_latitude                     number,
p_employee                     varchar2,
p_contractor                   varchar2,
p_employment_category          varchar2,
p_keywords                     varchar2,
p_travel_percentage            number,
p_min_salary                   number,
p_salary_currency              varchar2,
p_salary_period                varchar2,
p_match_competence             varchar2,
p_match_qualification          varchar2,
p_work_at_home                 varchar2,
p_job_title                    varchar2,
p_department                   varchar2,
p_professional_area            varchar2,
p_use_for_matching             varchar2,
p_description                  varchar2,
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
p_isc_information_category     varchar2,
p_isc_information1             varchar2,
p_isc_information2             varchar2,
p_isc_information3             varchar2,
p_isc_information4             varchar2,
p_isc_information5             varchar2,
p_isc_information6             varchar2,
p_isc_information7             varchar2,
p_isc_information8             varchar2,
p_isc_information9             varchar2,
p_isc_information10            varchar2,
p_isc_information11            varchar2,
p_isc_information12            varchar2,
p_isc_information13            varchar2,
p_isc_information14            varchar2,
p_isc_information15            varchar2,
p_isc_information16            varchar2,
p_isc_information17            varchar2,
p_isc_information18            varchar2,
p_isc_information19            varchar2,
p_isc_information20            varchar2,
p_isc_information21            varchar2,
p_isc_information22            varchar2,
p_isc_information23            varchar2,
p_isc_information24            varchar2,
p_isc_information25            varchar2,
p_isc_information26            varchar2,
p_isc_information27            varchar2,
p_isc_information28            varchar2,
p_isc_information29            varchar2,
p_isc_information30            varchar2,
p_date_posted                  varchar2,
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
  l_proc varchar2(72):='  irc_search_criteria_be1.create_saved_search_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.irc.api.search_criteria.create_saved_search';
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
    l_text:='<search_criteria>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<search_criteria_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_search_criteria_id);
    l_text:=l_text||'</search_criteria_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<search_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_search_name);
    l_text:=l_text||'</search_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<location>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_location);
    l_text:=l_text||'</location>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<distance_to_location>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_distance_to_location);
    l_text:=l_text||'</distance_to_location>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<geocode_location>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_geocode_location);
    l_text:=l_text||'</geocode_location>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<geocode_country>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_geocode_country);
    l_text:=l_text||'</geocode_country>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<derived_location>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_derived_location);
    l_text:=l_text||'</derived_location>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<location_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_location_id);
    l_text:=l_text||'</location_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<longitude>';
    l_text:=l_text||fnd_number.number_to_canonical(p_longitude);
    l_text:=l_text||'</longitude>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<latitude>';
    l_text:=l_text||fnd_number.number_to_canonical(p_latitude);
    l_text:=l_text||'</latitude>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<employee>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employee);
    l_text:=l_text||'</employee>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<contractor>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_contractor);
    l_text:=l_text||'</contractor>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<employment_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employment_category);
    l_text:=l_text||'</employment_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<keywords>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_keywords);
    l_text:=l_text||'</keywords>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<travel_percentage>';
    l_text:=l_text||fnd_number.number_to_canonical(p_travel_percentage);
    l_text:=l_text||'</travel_percentage>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<min_salary>';
    l_text:=l_text||fnd_number.number_to_canonical(p_min_salary);
    l_text:=l_text||'</min_salary>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<salary_currency>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_salary_currency);
    l_text:=l_text||'</salary_currency>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<salary_period>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_salary_period);
    l_text:=l_text||'</salary_period>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<match_competence>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_match_competence);
    l_text:=l_text||'</match_competence>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<match_qualification>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_match_qualification);
    l_text:=l_text||'</match_qualification>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<work_at_home>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_work_at_home);
    l_text:=l_text||'</work_at_home>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<job_title>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_job_title);
    l_text:=l_text||'</job_title>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<department>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_department);
    l_text:=l_text||'</department>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<professional_area>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_professional_area);
    l_text:=l_text||'</professional_area>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<use_for_matching>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_use_for_matching);
    l_text:=l_text||'</use_for_matching>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<description>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_description);
    l_text:=l_text||'</description>';
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
    l_text:='<isc_information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information_category);
    l_text:=l_text||'</isc_information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information1);
    l_text:=l_text||'</isc_information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information2);
    l_text:=l_text||'</isc_information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information3);
    l_text:=l_text||'</isc_information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information4);
    l_text:=l_text||'</isc_information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information5);
    l_text:=l_text||'</isc_information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information6);
    l_text:=l_text||'</isc_information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information7);
    l_text:=l_text||'</isc_information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information8);
    l_text:=l_text||'</isc_information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information9);
    l_text:=l_text||'</isc_information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information10);
    l_text:=l_text||'</isc_information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information11);
    l_text:=l_text||'</isc_information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information12);
    l_text:=l_text||'</isc_information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information13);
    l_text:=l_text||'</isc_information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information14);
    l_text:=l_text||'</isc_information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information15);
    l_text:=l_text||'</isc_information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information16);
    l_text:=l_text||'</isc_information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information17);
    l_text:=l_text||'</isc_information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information18);
    l_text:=l_text||'</isc_information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information19);
    l_text:=l_text||'</isc_information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information20);
    l_text:=l_text||'</isc_information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information21);
    l_text:=l_text||'</isc_information21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information22);
    l_text:=l_text||'</isc_information22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information23);
    l_text:=l_text||'</isc_information23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information24);
    l_text:=l_text||'</isc_information24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information25);
    l_text:=l_text||'</isc_information25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information26);
    l_text:=l_text||'</isc_information26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information27);
    l_text:=l_text||'</isc_information27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information28);
    l_text:=l_text||'</isc_information28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information29);
    l_text:=l_text||'</isc_information29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<isc_information30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_isc_information30);
    l_text:=l_text||'</isc_information30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<date_posted>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_date_posted);
    l_text:=l_text||'</date_posted>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</search_criteria>';
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
end create_saved_search_a;
end irc_search_criteria_be1;

/
