--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_LINK_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_LINK_BE1" as 
--Code generated on 29/08/2013 10:00:32
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_element_link_a (
p_effective_date               date,
p_element_type_id              number,
p_business_group_id            number,
p_costable_type                varchar2,
p_payroll_id                   number,
p_job_id                       number,
p_position_id                  number,
p_people_group_id              number,
p_cost_allocation_keyflex_id   number,
p_organization_id              number,
p_location_id                  number,
p_grade_id                     number,
p_balancing_keyflex_id         number,
p_element_set_id               number,
p_pay_basis_id                 number,
p_link_to_all_payrolls_flag    varchar2,
p_standard_link_flag           varchar2,
p_transfer_to_gl_flag          varchar2,
p_comments                     varchar2,
p_employment_category          varchar2,
p_qualifying_age               number,
p_qualifying_length_of_service number,
p_qualifying_units             varchar2,
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
p_cost_segment1                varchar2,
p_cost_segment2                varchar2,
p_cost_segment3                varchar2,
p_cost_segment4                varchar2,
p_cost_segment5                varchar2,
p_cost_segment6                varchar2,
p_cost_segment7                varchar2,
p_cost_segment8                varchar2,
p_cost_segment9                varchar2,
p_cost_segment10               varchar2,
p_cost_segment11               varchar2,
p_cost_segment12               varchar2,
p_cost_segment13               varchar2,
p_cost_segment14               varchar2,
p_cost_segment15               varchar2,
p_cost_segment16               varchar2,
p_cost_segment17               varchar2,
p_cost_segment18               varchar2,
p_cost_segment19               varchar2,
p_cost_segment20               varchar2,
p_cost_segment21               varchar2,
p_cost_segment22               varchar2,
p_cost_segment23               varchar2,
p_cost_segment24               varchar2,
p_cost_segment25               varchar2,
p_cost_segment26               varchar2,
p_cost_segment27               varchar2,
p_cost_segment28               varchar2,
p_cost_segment29               varchar2,
p_cost_segment30               varchar2,
p_balance_segment1             varchar2,
p_balance_segment2             varchar2,
p_balance_segment3             varchar2,
p_balance_segment4             varchar2,
p_balance_segment5             varchar2,
p_balance_segment6             varchar2,
p_balance_segment7             varchar2,
p_balance_segment8             varchar2,
p_balance_segment9             varchar2,
p_balance_segment10            varchar2,
p_balance_segment11            varchar2,
p_balance_segment12            varchar2,
p_balance_segment13            varchar2,
p_balance_segment14            varchar2,
p_balance_segment15            varchar2,
p_balance_segment16            varchar2,
p_balance_segment17            varchar2,
p_balance_segment18            varchar2,
p_balance_segment19            varchar2,
p_balance_segment20            varchar2,
p_balance_segment21            varchar2,
p_balance_segment22            varchar2,
p_balance_segment23            varchar2,
p_balance_segment24            varchar2,
p_balance_segment25            varchar2,
p_balance_segment26            varchar2,
p_balance_segment27            varchar2,
p_balance_segment28            varchar2,
p_balance_segment29            varchar2,
p_balance_segment30            varchar2,
p_cost_concat_segments         varchar2,
p_balance_concat_segments      varchar2,
p_element_link_id              number,
p_comment_id                   number,
p_object_version_number        number,
p_effective_start_date         date,
p_effective_end_date           date) is
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  --
  cursor get_seq is
  select per_wf_events_s.nextval from dual;
  --
  l_proc varchar2(72):='  pay_element_link_be1.create_element_link_a';
begin
  hr_utility.set_location('Entering: '||l_proc,10);
  -- check the status of the business event
  l_event_name:='oracle.apps.pay.api.element_link.create_element_link';
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
    l_text:='<element_link>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    --
    l_text:='<effective_date>';
    l_text:=l_text||fnd_date.date_to_canonical(p_effective_date);
    l_text:=l_text||'</effective_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_type_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_element_type_id);
    l_text:=l_text||'</element_type_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<business_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_business_group_id);
    l_text:=l_text||'</business_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<costable_type>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_costable_type);
    l_text:=l_text||'</costable_type>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<payroll_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_payroll_id);
    l_text:=l_text||'</payroll_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<job_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_job_id);
    l_text:=l_text||'</job_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<position_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_position_id);
    l_text:=l_text||'</position_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<people_group_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_people_group_id);
    l_text:=l_text||'</people_group_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_allocation_keyflex_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_cost_allocation_keyflex_id);
    l_text:=l_text||'</cost_allocation_keyflex_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<organization_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_organization_id);
    l_text:=l_text||'</organization_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<location_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_location_id);
    l_text:=l_text||'</location_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<grade_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_grade_id);
    l_text:=l_text||'</grade_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balancing_keyflex_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_balancing_keyflex_id);
    l_text:=l_text||'</balancing_keyflex_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_set_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_element_set_id);
    l_text:=l_text||'</element_set_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<pay_basis_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_pay_basis_id);
    l_text:=l_text||'</pay_basis_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<link_to_all_payrolls_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_link_to_all_payrolls_flag);
    l_text:=l_text||'</link_to_all_payrolls_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<standard_link_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_standard_link_flag);
    l_text:=l_text||'</standard_link_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<transfer_to_gl_flag>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_transfer_to_gl_flag);
    l_text:=l_text||'</transfer_to_gl_flag>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_comments);
    l_text:=l_text||'</comments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<employment_category>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_employment_category);
    l_text:=l_text||'</employment_category>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<qualifying_age>';
    l_text:=l_text||fnd_number.number_to_canonical(p_qualifying_age);
    l_text:=l_text||'</qualifying_age>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<qualifying_length_of_service>';
    l_text:=l_text||fnd_number.number_to_canonical(p_qualifying_length_of_service);
    l_text:=l_text||'</qualifying_length_of_service>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<qualifying_units>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_qualifying_units);
    l_text:=l_text||'</qualifying_units>';
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
    l_text:='<cost_segment1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment1);
    l_text:=l_text||'</cost_segment1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment2);
    l_text:=l_text||'</cost_segment2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment3);
    l_text:=l_text||'</cost_segment3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment4);
    l_text:=l_text||'</cost_segment4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment5);
    l_text:=l_text||'</cost_segment5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment6);
    l_text:=l_text||'</cost_segment6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment7);
    l_text:=l_text||'</cost_segment7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment8);
    l_text:=l_text||'</cost_segment8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment9);
    l_text:=l_text||'</cost_segment9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment10);
    l_text:=l_text||'</cost_segment10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment11);
    l_text:=l_text||'</cost_segment11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment12);
    l_text:=l_text||'</cost_segment12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment13);
    l_text:=l_text||'</cost_segment13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment14);
    l_text:=l_text||'</cost_segment14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment15);
    l_text:=l_text||'</cost_segment15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment16);
    l_text:=l_text||'</cost_segment16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment17);
    l_text:=l_text||'</cost_segment17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment18);
    l_text:=l_text||'</cost_segment18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment19);
    l_text:=l_text||'</cost_segment19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment20);
    l_text:=l_text||'</cost_segment20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment21);
    l_text:=l_text||'</cost_segment21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment22);
    l_text:=l_text||'</cost_segment22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment23);
    l_text:=l_text||'</cost_segment23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment24);
    l_text:=l_text||'</cost_segment24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment25);
    l_text:=l_text||'</cost_segment25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment26);
    l_text:=l_text||'</cost_segment26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment27);
    l_text:=l_text||'</cost_segment27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment28);
    l_text:=l_text||'</cost_segment28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment29);
    l_text:=l_text||'</cost_segment29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_segment30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_segment30);
    l_text:=l_text||'</cost_segment30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment1>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment1);
    l_text:=l_text||'</balance_segment1>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment2>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment2);
    l_text:=l_text||'</balance_segment2>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment3>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment3);
    l_text:=l_text||'</balance_segment3>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment4>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment4);
    l_text:=l_text||'</balance_segment4>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment5>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment5);
    l_text:=l_text||'</balance_segment5>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment6>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment6);
    l_text:=l_text||'</balance_segment6>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment7>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment7);
    l_text:=l_text||'</balance_segment7>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment8>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment8);
    l_text:=l_text||'</balance_segment8>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment9>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment9);
    l_text:=l_text||'</balance_segment9>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment10>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment10);
    l_text:=l_text||'</balance_segment10>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment11>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment11);
    l_text:=l_text||'</balance_segment11>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment12>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment12);
    l_text:=l_text||'</balance_segment12>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment13>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment13);
    l_text:=l_text||'</balance_segment13>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment14>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment14);
    l_text:=l_text||'</balance_segment14>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment15>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment15);
    l_text:=l_text||'</balance_segment15>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment16>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment16);
    l_text:=l_text||'</balance_segment16>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment17>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment17);
    l_text:=l_text||'</balance_segment17>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment18>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment18);
    l_text:=l_text||'</balance_segment18>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment19>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment19);
    l_text:=l_text||'</balance_segment19>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment20>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment20);
    l_text:=l_text||'</balance_segment20>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment21>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment21);
    l_text:=l_text||'</balance_segment21>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment22>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment22);
    l_text:=l_text||'</balance_segment22>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment23>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment23);
    l_text:=l_text||'</balance_segment23>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment24>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment24);
    l_text:=l_text||'</balance_segment24>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment25>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment25);
    l_text:=l_text||'</balance_segment25>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment26>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment26);
    l_text:=l_text||'</balance_segment26>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment27>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment27);
    l_text:=l_text||'</balance_segment27>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment28>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment28);
    l_text:=l_text||'</balance_segment28>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment29>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment29);
    l_text:=l_text||'</balance_segment29>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_segment30>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_segment30);
    l_text:=l_text||'</balance_segment30>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<cost_concat_segments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_cost_concat_segments);
    l_text:=l_text||'</cost_concat_segments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<balance_concat_segments>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_balance_concat_segments);
    l_text:=l_text||'</balance_concat_segments>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<element_link_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_element_link_id);
    l_text:=l_text||'</element_link_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
    l_text:='<comment_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_comment_id);
    l_text:=l_text||'</comment_id>';
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
    l_text:='</element_link>';
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
end create_element_link_a;
end pay_element_link_be1;

/
