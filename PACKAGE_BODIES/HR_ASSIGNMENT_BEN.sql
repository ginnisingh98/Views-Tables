--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_BEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_BEN" as 
--Code generated on 30/08/2013 11:36:21
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_secondary_cwk_asg_a (
p_effective_date               date,
p_business_group_id            number,
p_person_id                    number,
p_organization_id              number,
p_assignment_number            varchar2,
p_assignment_category          varchar2,
p_assignment_status_type_id    number,
p_change_reason                varchar2,
p_comments                     varchar2,
p_default_code_comb_id         number,
p_establishment_id             number,
p_frequency                    varchar2,
p_internal_address_line        varchar2,
p_job_id                       number,
p_labour_union_member_flag     varchar2,
p_location_id                  number,
p_manager_flag                 varchar2,
p_normal_hours                 number,
p_position_id                  number,
p_grade_id                     number,
p_project_title                varchar2,
p_set_of_books_id              number,
p_source_type                  varchar2,
p_supervisor_id                number,
p_time_normal_finish           varchar2,
p_time_normal_start            varchar2,
p_title                        varchar2,
p_vendor_assignment_number     varchar2,
p_vendor_employee_number       varchar2,
p_vendor_id                    number,
p_vendor_site_id               number,
p_po_header_id                 number,
p_po_line_id                   number,
p_projected_assignment_end     date,
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
p_pgp_segment1                 varchar2,
p_pgp_segment2                 varchar2,
p_pgp_segment3                 varchar2,
p_pgp_segment4                 varchar2,
p_pgp_segment5                 varchar2,
p_pgp_segment6                 varchar2,
p_pgp_segment7                 varchar2,
p_pgp_segment8                 varchar2,
p_pgp_segment9                 varchar2,
p_pgp_segment10                varchar2,
p_pgp_segment11                varchar2,
p_pgp_segment12                varchar2,
p_pgp_segment13                varchar2,
p_pgp_segment14                varchar2,
p_pgp_segment15                varchar2,
p_pgp_segment16                varchar2,
p_pgp_segment17                varchar2,
p_pgp_segment18                varchar2,
p_pgp_segment19                varchar2,
p_pgp_segment20                varchar2,
p_pgp_segment21                varchar2,
p_pgp_segment22                varchar2,
p_pgp_segment23                varchar2,
p_pgp_segment24                varchar2,
p_pgp_segment25                varchar2,
p_pgp_segment26                varchar2,
p_pgp_segment27                varchar2,
p_pgp_segment28                varchar2,
p_pgp_segment29                varchar2,
p_pgp_segment30                varchar2,
p_scl_segment1                 varchar2,
p_scl_segment2                 varchar2,
p_scl_segment3                 varchar2,
p_scl_segment4                 varchar2,
p_scl_segment5                 varchar2,
p_scl_segment6                 varchar2,
p_scl_segment7                 varchar2,
p_scl_segment8                 varchar2,
p_scl_segment9                 varchar2,
p_scl_segment10                varchar2,
p_scl_segment11                varchar2,
p_scl_segment12                varchar2,
p_scl_segment13                varchar2,
p_scl_segment14                varchar2,
p_scl_segment15                varchar2,
p_scl_segment16                varchar2,
p_scl_segment17                varchar2,
p_scl_segment18                varchar2,
p_scl_segment19                varchar2,
p_scl_segment20                varchar2,
p_scl_segment21                varchar2,
p_scl_segment22                varchar2,
p_scl_segment23                varchar2,
p_scl_segment24                varchar2,
p_scl_segment25                varchar2,
p_scl_segment26                varchar2,
p_scl_segment27                varchar2,
p_scl_segment28                varchar2,
p_scl_segment29                varchar2,
p_scl_segment30                varchar2,
p_scl_concat_segments          varchar2,
p_pgp_concat_segments          varchar2,
p_assignment_id                number,
p_object_version_number        number,
p_effective_start_date         date,
p_effective_end_date           date,
p_assignment_sequence          number,
p_comment_id                   number,
p_people_group_id              number,
p_people_group_name            varchar2,
p_other_manager_warning        boolean,
p_hourly_salaried_warning      boolean,
p_soft_coding_keyflex_id       number,
p_supervisor_assignment_id     number) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  hr_assignment_beN.create_secondary_cwk_asg_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.per.api.assignment.create_secondary_cwk_asg';
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
    l_text:='<assignment>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_person_id);
    l_text:=l_text||'</person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<organization_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_organization_id);
    l_text:=l_text||'</organization_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_assignment_number);
    l_text:=l_text||'</assignment_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_assignment_category);
    l_text:=l_text||'</assignment_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_status_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_status_type_id);
    l_text:=l_text||'</assignment_status_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<change_reason>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_change_reason);
    l_text:=l_text||'</change_reason>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<default_code_comb_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_default_code_comb_id);
    l_text:=l_text||'</default_code_comb_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<establishment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_establishment_id);
    l_text:=l_text||'</establishment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<frequency>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_frequency);
    l_text:=l_text||'</frequency>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<internal_address_line>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_internal_address_line);
    l_text:=l_text||'</internal_address_line>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<job_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_job_id);
    l_text:=l_text||'</job_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<labour_union_member_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_labour_union_member_flag);
    l_text:=l_text||'</labour_union_member_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<location_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_location_id);
    l_text:=l_text||'</location_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<manager_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_manager_flag);
    l_text:=l_text||'</manager_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<normal_hours>';
    l_text:=l_text||fnd_number.number_to_canonical(p_normal_hours);
    l_text:=l_text||'</normal_hours>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<position_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_position_id);
    l_text:=l_text||'</position_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<grade_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_grade_id);
    l_text:=l_text||'</grade_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<project_title>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_project_title);
    l_text:=l_text||'</project_title>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<set_of_books_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_set_of_books_id);
    l_text:=l_text||'</set_of_books_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<source_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_source_type);
    l_text:=l_text||'</source_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<supervisor_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_supervisor_id);
    l_text:=l_text||'</supervisor_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<time_normal_finish>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_time_normal_finish);
    l_text:=l_text||'</time_normal_finish>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<time_normal_start>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_time_normal_start);
    l_text:=l_text||'</time_normal_start>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<title>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_title);
    l_text:=l_text||'</title>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<vendor_assignment_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_vendor_assignment_number);
    l_text:=l_text||'</vendor_assignment_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<vendor_employee_number>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_vendor_employee_number);
    l_text:=l_text||'</vendor_employee_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<vendor_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_vendor_id);
    l_text:=l_text||'</vendor_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<vendor_site_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_vendor_site_id);
    l_text:=l_text||'</vendor_site_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<po_header_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_po_header_id);
    l_text:=l_text||'</po_header_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<po_line_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_po_line_id);
    l_text:=l_text||'</po_line_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<projected_assignment_end>';
    l_text:=l_text||fnd_date.date_to_canonical(p_projected_assignment_end);
    l_text:=l_text||'</projected_assignment_end>';
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
    l_text:='<pgp_segment1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment1);
    l_text:=l_text||'</pgp_segment1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment2);
    l_text:=l_text||'</pgp_segment2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment3);
    l_text:=l_text||'</pgp_segment3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment4);
    l_text:=l_text||'</pgp_segment4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment5);
    l_text:=l_text||'</pgp_segment5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment6);
    l_text:=l_text||'</pgp_segment6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment7);
    l_text:=l_text||'</pgp_segment7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment8);
    l_text:=l_text||'</pgp_segment8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment9);
    l_text:=l_text||'</pgp_segment9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment10);
    l_text:=l_text||'</pgp_segment10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment11);
    l_text:=l_text||'</pgp_segment11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment12);
    l_text:=l_text||'</pgp_segment12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment13);
    l_text:=l_text||'</pgp_segment13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment14);
    l_text:=l_text||'</pgp_segment14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment15);
    l_text:=l_text||'</pgp_segment15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment16);
    l_text:=l_text||'</pgp_segment16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment17);
    l_text:=l_text||'</pgp_segment17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment18);
    l_text:=l_text||'</pgp_segment18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment19);
    l_text:=l_text||'</pgp_segment19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment20);
    l_text:=l_text||'</pgp_segment20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment21);
    l_text:=l_text||'</pgp_segment21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment22);
    l_text:=l_text||'</pgp_segment22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment23);
    l_text:=l_text||'</pgp_segment23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment24);
    l_text:=l_text||'</pgp_segment24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment25);
    l_text:=l_text||'</pgp_segment25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment26);
    l_text:=l_text||'</pgp_segment26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment27);
    l_text:=l_text||'</pgp_segment27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment28);
    l_text:=l_text||'</pgp_segment28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment29);
    l_text:=l_text||'</pgp_segment29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_segment30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_segment30);
    l_text:=l_text||'</pgp_segment30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment1);
    l_text:=l_text||'</scl_segment1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment2);
    l_text:=l_text||'</scl_segment2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment3);
    l_text:=l_text||'</scl_segment3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment4);
    l_text:=l_text||'</scl_segment4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment5);
    l_text:=l_text||'</scl_segment5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment6);
    l_text:=l_text||'</scl_segment6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment7);
    l_text:=l_text||'</scl_segment7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment8);
    l_text:=l_text||'</scl_segment8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment9);
    l_text:=l_text||'</scl_segment9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment10);
    l_text:=l_text||'</scl_segment10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment11);
    l_text:=l_text||'</scl_segment11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment12);
    l_text:=l_text||'</scl_segment12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment13);
    l_text:=l_text||'</scl_segment13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment14);
    l_text:=l_text||'</scl_segment14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment15);
    l_text:=l_text||'</scl_segment15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment16);
    l_text:=l_text||'</scl_segment16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment17);
    l_text:=l_text||'</scl_segment17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment18);
    l_text:=l_text||'</scl_segment18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment19);
    l_text:=l_text||'</scl_segment19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment20);
    l_text:=l_text||'</scl_segment20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment21);
    l_text:=l_text||'</scl_segment21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment22);
    l_text:=l_text||'</scl_segment22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment23);
    l_text:=l_text||'</scl_segment23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment24);
    l_text:=l_text||'</scl_segment24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment25);
    l_text:=l_text||'</scl_segment25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment26);
    l_text:=l_text||'</scl_segment26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment27);
    l_text:=l_text||'</scl_segment27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment28);
    l_text:=l_text||'</scl_segment28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment29);
    l_text:=l_text||'</scl_segment29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_segment30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_segment30);
    l_text:=l_text||'</scl_segment30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<scl_concat_segments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_scl_concat_segments);
    l_text:=l_text||'</scl_concat_segments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pgp_concat_segments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_pgp_concat_segments);
    l_text:=l_text||'</pgp_concat_segments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_id);
    l_text:=l_text||'</assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<object_version_number>';
    l_text:=l_text||fnd_number.number_to_canonical(p_object_version_number);
    l_text:=l_text||'</object_version_number>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_start_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_start_date);
    l_text:=l_text||'</effective_start_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<effective_end_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_end_date);
    l_text:=l_text||'</effective_end_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<assignment_sequence>';
    l_text:=l_text||fnd_number.number_to_canonical(p_assignment_sequence);
    l_text:=l_text||'</assignment_sequence>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_comment_id);
    l_text:=l_text||'</comment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<people_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_people_group_id);
    l_text:=l_text||'</people_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<people_group_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_people_group_name);
    l_text:=l_text||'</people_group_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<other_manager_warning>';
if(P_OTHER_MANAGER_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</other_manager_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<hourly_salaried_warning>';
if(P_HOURLY_SALARIED_WARNING) then
l_text:=l_text||'TRUE';
else
l_text:=l_text||'FALSE';
end if;
    l_text:=l_text||'</hourly_salaried_warning>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<soft_coding_keyflex_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_soft_coding_keyflex_id);
    l_text:=l_text||'</soft_coding_keyflex_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<supervisor_assignment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_supervisor_assignment_id);
    l_text:=l_text||'</supervisor_assignment_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='</assignment>';
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
end create_secondary_cwk_asg_a;
end hr_assignment_beN;

/
