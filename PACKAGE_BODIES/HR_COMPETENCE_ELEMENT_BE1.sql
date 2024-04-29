--------------------------------------------------------
--  DDL for Package Body HR_COMPETENCE_ELEMENT_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMPETENCE_ELEMENT_BE1" as 
--Code generated on 04/01/2007 09:31:45
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure create_competence_element_a (
p_competence_element_id        number,
p_object_version_number        number,
p_type                         varchar2,
p_business_group_id            number,
p_enterprise_id                number,
p_competence_id                number,
p_proficiency_level_id         number,
p_high_proficiency_level_id    number,
p_weighting_level_id           number,
p_rating_level_id              number,
p_person_id                    number,
p_job_id                       number,
p_valid_grade_id               number,
p_position_id                  number,
p_organization_id              number,
p_parent_competence_element_id number,
p_activity_version_id          number,
p_assessment_id                number,
p_assessment_type_id           number,
p_mandatory                    varchar2,
p_effective_date_from          date,
p_effective_date_to            date,
p_group_competence_type        varchar2,
p_competence_type              varchar2,
p_normal_elapse_duration       number,
p_normal_elapse_duration_unit  varchar2,
p_sequence_number              number,
p_source_of_proficiency_level  varchar2,
p_line_score                   number,
p_certification_date           date,
p_certification_method         varchar2,
p_next_certification_date      date,
p_comments                     varchar2,
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
p_effective_date               date,
p_object_id                    number,
p_object_name                  varchar2,
p_party_id                     number,
p_qualification_type_id        number,
p_unit_standard_type           varchar2,
p_status                       varchar2,
p_information_category         varchar2,
p_information1                 varchar2,
p_information2                 varchar2,
p_information3                 varchar2,
p_information4                 varchar2,
p_information5                 varchar2,
p_information6                 varchar2,
p_information7                 varchar2,
p_information8                 varchar2,
p_information9                 varchar2,
p_information10                varchar2,
p_information11                varchar2,
p_information12                varchar2,
p_information13                varchar2,
p_information14                varchar2,
p_information15                varchar2,
p_information16                varchar2,
p_information17                varchar2,
p_information18                varchar2,
p_information19                varchar2,
p_information20                varchar2,
p_achieved_date                date,
p_appr_line_score              number) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_competence_element_be1.create_competence_element_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.competence_element.create_competence_element';
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
    l_text:='<competence_element>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<competence_element_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_competence_element_id);
    l_text:=l_text||'</competence_element_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_type);
    l_text:=l_text||'</type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<enterprise_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_enterprise_id);
    l_text:=l_text||'</enterprise_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<competence_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_competence_id);
    l_text:=l_text||'</competence_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<proficiency_level_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_proficiency_level_id);
    l_text:=l_text||'</proficiency_level_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<high_proficiency_level_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_high_proficiency_level_id);
    l_text:=l_text||'</high_proficiency_level_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<weighting_level_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_weighting_level_id);
    l_text:=l_text||'</weighting_level_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<rating_level_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_rating_level_id);
    l_text:=l_text||'</rating_level_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<job_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_job_id);
    l_text:=l_text||'</job_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<valid_grade_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_valid_grade_id);
    l_text:=l_text||'</valid_grade_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<position_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_position_id);
    l_text:=l_text||'</position_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<organization_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_organization_id);
    l_text:=l_text||'</organization_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<parent_competence_element_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_parent_competence_element_id);
    l_text:=l_text||'</parent_competence_element_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<activity_version_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_activity_version_id);
    l_text:=l_text||'</activity_version_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assessment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assessment_id);
    l_text:=l_text||'</assessment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assessment_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assessment_type_id);
    l_text:=l_text||'</assessment_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<mandatory>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_mandatory);
    l_text:=l_text||'</mandatory>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_date_from>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date_from);
    l_text:=l_text||'</effective_date_from>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_date_to>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date_to);
    l_text:=l_text||'</effective_date_to>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<group_competence_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_group_competence_type);
    l_text:=l_text||'</group_competence_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<competence_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_competence_type);
    l_text:=l_text||'</competence_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<normal_elapse_duration>';
    l_text:=l_text||fnd_number.number_to_canonical(p_normal_elapse_duration);
    l_text:=l_text||'</normal_elapse_duration>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<normal_elapse_duration_unit>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_normal_elapse_duration_unit);
    l_text:=l_text||'</normal_elapse_duration_unit>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<sequence_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_sequence_number);
    l_text:=l_text||'</sequence_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<source_of_proficiency_level>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_source_of_proficiency_level);
    l_text:=l_text||'</source_of_proficiency_level>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<line_score>';
    l_text:=l_text||fnd_number.number_to_canonical(p_line_score);
    l_text:=l_text||'</line_score>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<certification_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_certification_date);
    l_text:=l_text||'</certification_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<certification_method>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_certification_method);
    l_text:=l_text||'</certification_method>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<next_certification_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_next_certification_date);
    l_text:=l_text||'</next_certification_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
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
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_id);
    l_text:=l_text||'</object_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_object_name);
    l_text:=l_text||'</object_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<party_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_party_id);
    l_text:=l_text||'</party_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<qualification_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_qualification_type_id);
    l_text:=l_text||'</qualification_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<unit_standard_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_unit_standard_type);
    l_text:=l_text||'</unit_standard_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<status>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_status);
    l_text:=l_text||'</status>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information_category);
    l_text:=l_text||'</information_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information1);
    l_text:=l_text||'</information1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information2);
    l_text:=l_text||'</information2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information3);
    l_text:=l_text||'</information3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information4);
    l_text:=l_text||'</information4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information5);
    l_text:=l_text||'</information5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information6);
    l_text:=l_text||'</information6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information7);
    l_text:=l_text||'</information7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information8);
    l_text:=l_text||'</information8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information9);
    l_text:=l_text||'</information9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information10);
    l_text:=l_text||'</information10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information11);
    l_text:=l_text||'</information11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information12);
    l_text:=l_text||'</information12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information13);
    l_text:=l_text||'</information13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information14);
    l_text:=l_text||'</information14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information15);
    l_text:=l_text||'</information15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information16);
    l_text:=l_text||'</information16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information17);
    l_text:=l_text||'</information17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information18);
    l_text:=l_text||'</information18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information19);
    l_text:=l_text||'</information19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<information20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_information20);
    l_text:=l_text||'</information20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<achieved_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_achieved_date);
    l_text:=l_text||'</achieved_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<appr_line_score>';
    l_text:=l_text||fnd_number.number_to_canonical(p_appr_line_score);
    l_text:=l_text||'</appr_line_score>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</competence_element>';
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
end create_competence_element_a;
end hr_competence_element_be1;

/
